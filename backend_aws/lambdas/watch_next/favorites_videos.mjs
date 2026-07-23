import { MongoClient, ObjectId } from 'mongodb';

const MONGODB_URI = process.env.MONGODB_URI; 
let cachedDb = null;

async function connectToDatabase() {
    if (cachedDb) return cachedDb;
    const client = new MongoClient(MONGODB_URI);
    await client.connect();
    cachedDb = client.db('tedxplore'); 
    return cachedDb;
}

export const handler = async (event) => {
    try {
        const db = await connectToDatabase();
        
        const claims = event.requestContext?.authorizer?.claims || {};
        const userId = claims['sub'] || claims['email'] || 'test_user';

        const method = event.httpMethod;

        // Cerca l'utente usando 'user_id' come nel documento MongoDB
        if (method === 'GET') {
            let userDoc = await db.collection('users').findOne({ user_id: userId });
            if (!userDoc) {
                // Fallback di test se usi un utente di prova
                userDoc = await db.collection('users').findOne({ user_id: 'user_test_2026' });
            }
            
            const favoriteIds = userDoc?.watched_videos || userDoc?.favoriteIds || [];

            if (favoriteIds.length === 0) {
                return {
                    statusCode: 200,
                    headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
                    body: JSON.stringify([])
                };
            }

            const videoQueryIds = favoriteIds.map(id => {
                try { return new ObjectId(id); } catch { return id; }
            });

            const favoriteVideos = await db.collection('videos')
                .find({ _id: { $in: videoQueryIds } })
                .toArray();

            const formattedVideos = favoriteVideos.map(v => ({
                id: v._id.toString(),
                title: v.title,
                speaker: v.speaker,
                thumbnail: v.thumbnail,
                duration: v.duration,
                views: v.views,
                year: v.year
            }));

            return {
                statusCode: 200,
                headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
                body: JSON.stringify(formattedVideos)
            };
        }

        if (method === 'POST') {
            const body = JSON.parse(event.body || '{}');
            const videoId = body.videoId;

            if (!videoId) {
                return {
                    statusCode: 400,
                    headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
                    body: JSON.stringify({ message: "videoId mancante" })
                };
            }

            let userDoc = await db.collection('users').findOne({ user_id: userId });
            const targetUserId = userDoc ? userId : 'user_test_2026';
            
            userDoc = await db.collection('users').findOne({ user_id: targetUserId });
            const favoriteIds = userDoc?.watched_videos || userDoc?.favoriteIds || [];
            const isFavorite = favoriteIds.includes(videoId);

            let updateOperation = isFavorite 
                ? { $pull: { watched_videos: videoId, favoriteIds: videoId } }
                : { $addToSet: { watched_videos: videoId, favoriteIds: videoId } };

            await db.collection('users').updateOne(
                { user_id: targetUserId },
                updateOperation,
                { upsert: true }
            );

            return {
                statusCode: 200,
                headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
                body: JSON.stringify({ success: true, isFavorite: !isFavorite })
            };
        }

        return {
            statusCode: 405,
            body: JSON.stringify({ message: "Metodo non consentito" })
        };

    } catch (error) {
        console.error("Errore Lambda Preferiti:", error);
        return {
            statusCode: 500,
            headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
            body: JSON.stringify({ error: error.message })
        };
    }
};