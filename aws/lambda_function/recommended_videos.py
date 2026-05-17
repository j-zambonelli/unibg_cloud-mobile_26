"""
This function handles the video recommendation query. 
It receives the array of mapped TEDx tags from previous step, connects to the MongoDB Atlas cluster, 
and searches for talks that match any of those tags. 
To ensure fast response times for the mobile application, result are capped at a maximum of five videos
"""
import json
import os
from pymongo import MongoClient

def lambda_handler(event, context):
    # Queries the aggregated MongoDB collection using extracted tags to return matching talks.
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
    
    # Finds talks where the 'tags' array contains at least one of the input search tags, excluding videos the user has already seen 
    query = {"tags": {"$in": search_tags}, 
             "_id": {"$nin": watched_video_ids}}
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