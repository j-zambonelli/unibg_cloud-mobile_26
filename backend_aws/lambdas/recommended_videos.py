import json
import os
from pymongo import MongoClient

MONGO_URI = os.environ.get('MONGO_URI')
client = MongoClient(MONGO_URI)

db = client['unibg_tedx_2026']
videos_collection = db['tedx_data']

def lambda_handler(event, context):
    try:
        body = json.loads(event.get('body', '{}')) if event.get('body') else {}
        search_tags = body.get('search_tags', [])
        
        query = {"tags": {"$in": search_tags}} if search_tags else {}
            
        videos_cursor = videos_collection.find(query, {"_id": 0}).limit(10)
        videos_list = list(videos_cursor)
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'  
            },
            'body': json.dumps(videos_list)
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }