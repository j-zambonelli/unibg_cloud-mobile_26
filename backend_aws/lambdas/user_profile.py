import json
import os
from pymongo import MongoClient

# Recupera la stringa di connessione dalle variabili d'ambiente di AWS
MONGO_URI = os.environ.get('MONGO_URI')
client = MongoClient(MONGO_URI)

# Selezione del database e della collezione
db = client['unibg_tedx_2026'] 
user_collection = db['user_history']

def lambda_handler(event, context):
    try:
        user_data = user_collection.find_one({"username": "j-zambonelli"}, {"_id": 0})
        
        if not user_data:
            user_data = {
                "username": "j-zambonelli",
                "email": "j.zambonelli@studenti.unibg.it",
                "percentualiGeneri": {
                    "Scienza": 0.25,
                    "Tecnologia e Ingegneria": 0.35,
                    "Ambiente e sostenibilità": 0.40
                }
            }
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'  # Permette le chiamate CORS da localhost
            },
            'body': json.dumps(user_data)
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }