import { MongoClient } from 'mongodb';

const uri = process.env.MONGO_URI;
let cachedClient = null;
let cachedDb = null;

async function connectToDatabase() {
    if (cachedClient && cachedDb) return { client: cachedClient, db: cachedDb };
    const client = new MongoClient(uri);
    await client.connect();
    const db = client.db('unibg_tedx_2026');
    cachedClient = client;
    cachedDb = db;
    return { client, db };
}

export const handler = async (event) => {
    try {
        const currentVideoId = event.current_video_id;

        if (!currentVideoId) {
            return { statusCode: 400, headers: {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'}, body: JSON.stringify({ error: "Parametro 'current_video_id' mancante." }) };
        }

        const { db } = await connectToDatabase();
        const talksCollection = db.collection('tedx_data'); 

        const talk = await talksCollection.findOne(
            { _id: currentVideoId.toString() },
            { projection: { related_videos: 1, _id: 0 } }
        );

        if (!talk) {
            return { statusCode: 404, headers: {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'}, body: JSON.stringify({ error: "Talk non trovato." }) };
        }

        return {
            statusCode: 200,
            headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
            body: JSON.stringify(talk.related_videos || [])
        };

    } catch (error) {
        return { statusCode: 500, headers: {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'}, body: JSON.stringify({ error: error.message }) };
    }
};