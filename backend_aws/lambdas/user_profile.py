import json
import os
from pymongo import MongoClient

# Recupera la stringa di connessione dalle variabili d'ambiente di AWS Lambda
MONGO_URI = os.environ.get('MONGO_URI')
client = MongoClient(MONGO_URI) if MONGO_URI else None

def lambda_handler(event, context):
    try:
        # 1. Estrazione dinamica dell'utente da Amazon Cognito tramite API Gateway Authorizer
        request_context = event.get('requestContext', {})
        authorizer = request_context.get('authorizer', {})
        claims = authorizer.get('claims', {})
        
        username = claims.get('cognito:username') or claims.get('username') or ""
        email = claims.get('email') or ""

        user_data = None
        
        # Cerca sul database MongoDB solo se lo username estratto è valido e il client è connesso
        if client and username:
            db = client['unibg_tedx_2026'] 
            user_collection = db['user_history']
            user_data = user_collection.find_one({"username": username}, {"_id": 0})
        
        # 2. Se l'utente si è appena registrato, inizializza il profilo senza generi fittizi
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