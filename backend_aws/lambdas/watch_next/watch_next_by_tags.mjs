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
        const targetTag = event.tag;

        if (!targetTag) {
            return { statusCode: 400, headers: {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'}, body: JSON.stringify({ error: "Parametro 'tag' mancante." }) };
        }

        const { db } = await connectToDatabase();
        const talksCollection = db.collection('tedx_data'); 

        // Rovesciamo la ricerca sull'array dei tag nativo
        const cursor = talksCollection.find(
            { tags: targetTag },
            { projection: { _id: 1, title: 1, slug: 1, duration: 1 } }
        ).limit(5);

        const tematiciList = [];
        await cursor.forEach((doc) => {
            tematiciList.push({
                id: doc._id,
                title: doc.title,
                slug: doc.slug,
                duration: doc.duration
            });
        });

        return {
            statusCode: 200,
            headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
            body: JSON.stringify(tematiciList)
        };

    } catch (error) {
        return { statusCode: 500, headers: {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'}, body: JSON.stringify({ error: error.message }) };
    }
};