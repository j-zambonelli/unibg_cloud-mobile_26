import json
import os
from pymongo import MongoClient

def lambda_handler(event, context):
    """
    Interroga la collezione aggregata 'tedx_data' usando i tag estratti.
    """
    if isinstance(event.get('body'), str):
        body = json.loads(event['body'])
    else:
        body = event.get('body', event)
        
    search_tags = body.get('search_tags', [])
    
    if not search_tags:
        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
            'body': json.dumps([])
        }
        
    mongo_uri = os.environ.get('MONGO_URI')
    if not mongo_uri:
        return {
            'statusCode': 500,
            'body': json.dumps({"error": "MONGO_URI non configurata nelle variabili d'ambiente."})
        }
        
    client = MongoClient(mongo_uri)
    db = client['unibg_tedx_2026']
    talks_col = db['tedx_data']
    
    # Cerchiamo i talk dove l'array 'tags' contiene almeno uno dei tag cercati
    query = {"tags": {"$in": search_tags}}
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
        
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps(recommended_talks)
    }