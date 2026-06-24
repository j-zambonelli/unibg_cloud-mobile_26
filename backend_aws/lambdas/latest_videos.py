import json
import os
from pymongo import MongoClient

MONGO_URI = os.environ.get('MONGO_URI')
client = MongoClient(MONGO_URI)

db = client['unibg_tedx_2026']
videos_collection = db['tedx_data']

def lambda_handler(event, context):
    try:
        videos_cursor = videos_collection.find({}, {'_id': 0}).sort('year', -1).limit(10)
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