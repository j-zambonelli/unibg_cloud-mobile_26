import json
import os
from pymongo import MongoClient

def lambda_handler(event, context):
    # 1. ESTRAZIONE DATI DALLA RICHIESTA DELL'APP
    if isinstance(event.get('body'), str):
        body = json.loads(event['body'])
    else:
        body = event.get('body', event)
        
    kindle_genres = body.get('kindle_genres', [])
    watched_video_ids = body.get('watched_video_ids', []) # Bug fixato: ora lo prende dal payload in modo sicuro
    
    if not kindle_genres:
        return {
            'statusCode': 400,
            'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({"error": "Parametro 'kindle_genres' mancante o vuoto."})
        }

    # 2. DIZIONARIO DI MAPPATURA (KINDLE -> TEDX)
    mapping_bridge = {
        "Scienza e Tecnologia": ["science", "technology", "innovation", "future"],
        "Biografie": ["biography", "history", "personal growth", "identity"],
        "Saggistica": ["society", "culture", "politics", "global issues"],
        "Self-help": ["psychology", "mental health", "happiness", "motivation"],
        "Economia": ["business", "economics", "finance", "work"],
        "Thriller": ["crime", "mystery", "human nature"]
    }
    
    tedx_tags_to_search = []
    for genre in kindle_genres:
        if genre in mapping_bridge:
            tedx_tags_to_search.extend(mapping_bridge[genre])
            
    unique_tags = list(set(tedx_tags_to_search))
    
    # Se non c'è nessun match con i tag, ritorno lista vuota
    if not unique_tags:
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({"recommendations": [], "message": "Nessun tag corrispondente trovato."})
        }

    # 3. CONNESSIONE A MONGODB
    mongo_uri = os.environ.get('MONGO_URI')
    if not mongo_uri:
        return {
            'statusCode': 500,
            'body': json.dumps({"error": "MONGO_URI non configurata nelle variabili d'ambiente."})
        }
        
    client = MongoClient(mongo_uri)
    db = client['unibg_tedx_2026']
    talks_col = db['tedx_data']
    
    # 4. INTERROGAZIONE DEL DATA WAREHOUSE
    # Cerca i video che hanno i tag richiesti, escludendo quelli che l'utente ha già visto
    query = {
        "tags": {"$in": unique_tags}, 
        "_id": {"$nin": watched_video_ids}
    }
    
    # Prende massimo 5 risultati per mantenere l'app veloce
    results = talks_col.find(query).limit(5)
    
    recommended_talks = []
    for talk in results:
        recommended_talks.append({
            "id": talk.get('_id'),
            "title": talk.get('title'),
            "slug": talk.get('slug'),
            "url": talk.get('url'),
            "description": talk.get('description', ''),
            "duration": talk.get('duration')
        })
        
    # 5. RISPOSTA AL FRONTEND FLUTTER
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*' # Essenziale per evitare errori CORS
        },
        'body': json.dumps({
            'tags_used_for_search': unique_tags,
            'recommendations': recommended_talks
        })
    }