import pandas as pd
from pymongo import MongoClient
from pymongo import UpdateOne

MONGO_URI = "mongodb+srv://unibg2026:unibg2026@cluster0.0jtalde.mongodb.net/unibg_tedx_2026?appName=Cluster0"
DB_NAME = "unibg_tedx_2026"
COLLECTION_NAME = "tedx_data"

def update_mongodb_thumbnails():
    print("Caricamento dei file CSV in corso...")
    final_list = pd.read_csv('final_list.csv')
    images = pd.read_csv('images.csv')

    images_16x9 = images[images['url'].str.contains('16x9|thumbnail', case=False, na=False)].drop_duplicates(subset=['id'])
    images_fallback = images.drop_duplicates(subset=['id'])
    
    merged_images = pd.merge(images_16x9, images_fallback, on=['id', 'slug'], how='right', suffixes=('_16x9', '_default'))
    merged_images['thumbnail_url'] = merged_images['url_16x9'].fillna(merged_images['url_default'])

    complete_df = pd.merge(final_list, merged_images[['id', 'thumbnail_url']], on='id', how='left')

    print("Connessione a MongoDB Atlas...")
    client = MongoClient(MONGO_URI)
    db = client[DB_NAME]
    collection = db[COLLECTION_NAME]

    print("Preparazione dell'aggiornamento massivo...")
    operations = []
    for _, row in complete_df.iterrows():
        thumbnail_url = row['thumbnail_url']
        if pd.notna(thumbnail_url):
            operations.append(
                UpdateOne(
                    {"slug": row['slug']},
                    {"$set": {"thumbnail": thumbnail_url}},
                    upsert=False
                )
            )

    if operations:
        print(f"Invio di {len(operations)} aggiornamenti a MongoDB in corso...")
        result = collection.bulk_write(operations)
        print(f"Fatto! Documenti aggiornati con successo: {result.modified_count}")
    else:
        print("Nessuna immagine trovata.")

if __name__ == "__main__":
    update_mongodb_thumbnails()