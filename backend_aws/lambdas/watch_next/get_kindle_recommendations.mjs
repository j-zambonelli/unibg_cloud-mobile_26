import { MongoClient } from 'mongodb';

const uri = process.env.MONGO_URI;
let cachedClient = null;
let cachedDb = null;

async function connectToDatabase() {
    if (cachedClient && cachedDb) return { client: cachedClient, db: cachedDb };
    if (!uri) throw new Error("La variabile d'ambiente MONGO_URI non è configurata.");
    
    const client = new MongoClient(uri);
    await client.connect();
    const db = client.db('unibg_tedx_2026');
    
    cachedClient = client;
    cachedDb = db;
    return { client, db };
}

export const handler = async (event) => {
    try {
        // ESTRAZIONE DATI DIRETTAMENTE DALL'EVENTO (Mapping Template)
        const kindleGenres = event.kindle_genres || [];
        const watchedVideoIds = event.watched_video_ids || [];

        if (kindleGenres.length === 0) {
            return {
                statusCode: 400,
                headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
                body: JSON.stringify({ error: "Parametro 'kindle_genres' mancante o vuoto nell'evento." })
            };
        }

        // DIZIONARIO DI MAPPATURA (KINDLE -> TEDX)
        const mappingBridge = {
            "Scienza e Tecnologia": ["science", "technology", "innovation", "future"],
            "Biografie": ["biography", "history", "personal growth", "identity"],
            "Saggistica": ["society", "culture", "politics", "global issues"],
            "Self-help": ["psychology", "mental health", "happiness", "motivation"],
            "Economia": ["business", "economics", "finance", "work"],
            "Thriller": ["crime", "mystery", "human nature"]
        };

        let tedxTagsToSearch = [];
        kindleGenres.forEach(genre => {
            if (mappingBridge[genre]) {
                tedxTagsToSearch.push(...mappingBridge[genre]);
            }
        });

        const uniqueTags = [...new Set(tedxTagsToSearch)];

        if (uniqueTags.length === 0) {
            return {
                statusCode: 200,
                headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
                body: JSON.stringify({ recommendations: [], message: "Nessun tag corrispondente trovato." })
            };
        }

        // CONNESSIONE E QUERY SU MONGODB ATLAS
        const { db } = await connectToDatabase();
        const talksCol = db.collection('tedx_data');

        const stringWatchedIds = watchedVideoIds.map(id => id.toString());

        const query = {
            tags: { $in: uniqueTags },
            _id: { $nin: stringWatchedIds }
        };

        const projection = { _id: 1, title: 1, slug: 1, url: 1, description: 1, duration: 1 };
        
        const cursor = talksCol.find(query).project(projection).limit(5);
        const recommendedTalks = [];

        await cursor.forEach((doc) => {
            recommendedTalks.push({
                id: doc._id,
                title: doc.title,
                slug: doc.slug,
                url: doc.url,
                description: doc.description || '',
                duration: doc.duration
            });
        });

        // RISPOSTA AL FRONTEND FLUTTER
        return {
            statusCode: 200,
            headers: {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            body: JSON.stringify({
                tags_used_for_search: uniqueTags,
                recommendations: recommendedTalks
            })
        };

    } catch (error) {
        console.error("Errore nella Lambda get_kindle_recommendations:", error);
        return {
            statusCode: 500,
            headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
            body: JSON.stringify({ error: "Errore interno del server", dettagli: error.message })
        };
    }
};