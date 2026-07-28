import { MongoClient, ObjectId } from 'mongodb';

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
        let requestBody = event;
        if (event.body) {
            requestBody = JSON.parse(event.body);
        }
        
        const currentVideoId = requestBody.current_video_id;
        const currentVideoTitle = requestBody.current_video_title;

        if (!currentVideoId && !currentVideoTitle) {
            return { 
                statusCode: 400, 
                headers: {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'}, 
                body: JSON.stringify({ error: "Parametri identificativi mancanti." }) 
            };
        }

        const { db } = await connectToDatabase();
        const talksCollection = db.collection('tedx_data'); 

        // 1. Cerca il video principale
        let queryConditions = [];
        if (currentVideoId) {
            queryConditions.push({ _id: currentVideoId });
            queryConditions.push({ id: currentVideoId });
            if (/^[0-9a-fA-F]{24}$/.test(currentVideoId.toString())) {
                queryConditions.push({ _id: new ObjectId(currentVideoId.toString()) });
            } else if (!isNaN(currentVideoId)) {
                queryConditions.push({ id: parseInt(currentVideoId) });
            }
        }
        if (currentVideoTitle) {
            queryConditions.push({ title: currentVideoTitle });
        }

        const talk = await talksCollection.findOne(
            { $or: queryConditions },
            { projection: { related_videos: 1, _id: 0 } }
        );

        if (!talk || !talk.related_videos || talk.related_videos.length === 0) {
            return { statusCode: 200, headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' }, body: JSON.stringify([]) };
        }

        // 2. Estrai gli ID dei video correlati dall'array
        const rawRelated = talk.related_videos;
        const relatedIds = rawRelated.map(v => v.related_id).filter(id => id != null);

        // Prepara le condizioni di ricerca per pescare le schede complete dei correlati
        let searchIds = [];
        relatedIds.forEach(id => {
            searchIds.push(id.toString());
            if (!isNaN(id)) searchIds.push(parseInt(id));
            if (/^[0-9a-fA-F]{24}$/.test(id.toString())) searchIds.push(new ObjectId(id.toString()));
        });

        // 3. Esegui la query per recuperare le Thumbnail reali dai documenti padri
        const fullDocs = await talksCollection.find({
            $or: [
                { _id: { $in: searchIds } },
                { id: { $in: searchIds } }
            ]
        }).limit(5).toArray();

        // 4. Mappa i dati: arricchisci i related_videos con la Thumbnail reale trovata nel DB
        const enrichedRelated = rawRelated.map(item => {
            const matchedDoc = fullDocs.find(doc => 
                (doc._id && doc._id.toString() === item.related_id?.toString()) ||
                (doc.id && doc.id.toString() === item.related_id?.toString())
            );

            return {
                id: item.related_id,
                title: item.related_title,
                duration: item.related_duration,
                url: item.related_slug ? `https://www.ted.com/talks/${item.related_slug}` : '',
                // Se trova il documento completo usa la sua thumbnail, altrimenti applica una di fallback
                thumbnail: matchedDoc && matchedDoc.thumbnail ? matchedDoc.thumbnail : 
                           (matchedDoc && matchedDoc.image ? matchedDoc.image : 
                           "https://pi.tedcdn.com/r/talkstar-photos.s3.amazonaws.com/uploads/72bda89f-8bbf-4685-910a-2f151c4f0762/BillGates_2015-embed.jpg")
            };
        });

        return {
            statusCode: 200,
            headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
            body: JSON.stringify(enrichedRelated)
        };

    } catch (error) {
        return { statusCode: 500, headers: {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'}, body: JSON.stringify({ error: error.message }) };
    }
};