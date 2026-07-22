import json
import os
import base64
from pymongo import MongoClient

MONGO_URI = os.environ.get('MONGO_URI')
client = MongoClient(MONGO_URI) if MONGO_URI else None

def lambda_handler(event, context):
    try:
        headers = event.get('headers', {}) or {}
        auth_header = headers.get('Authorization') or headers.get('authorization') or ""
        
        username = ""
        email = ""
        
        if auth_header.startswith('Bearer '):
            token = auth_header.split(' ')[1]
            try:
                parts = token.split('.')
                if len(parts) > 1:
                    payload_base64 = parts[1]
                    payload_base64 += '=' * (-len(payload_base64) % 4)
                    payload_bytes = base64.urlsafe_b64decode(payload_base64)
                    payload = json.loads(payload_bytes.decode('utf-8'))
                    
                    username = payload.get('cognito:username') or payload.get('username') or payload.get('sub') or ""
                    email = payload.get('email') or ""
            except Exception as decode_err:
                print(f"Errore decodifica token: {decode_err}")

        user_data = None
        
        # Cerca sul database MongoDB
        if client and username:
            db = client['unibg_tedx_2026'] 
            user_collection = db['user_history']
            user_data = user_collection.find_one({"username": username}, {"_id": 0})
        
        if not user_data:
            user_data = {
                "username": username if username else "Nuovo Utente",
                "email": email,
                "percentualiGeneri": {}
            }
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET,OPTIONS'
            },
            'body': json.dumps(user_data)
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({'error': str(e)})
        }