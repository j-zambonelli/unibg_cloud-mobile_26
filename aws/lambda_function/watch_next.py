import json
import os
from pymongo import MongoClient

def lambda_handler(event, context):
    """
    Restituisce i video correlati (Watch Next) per il talk attualmente visualizzato.
    """
    if isinstance(event.get('body'), str):
        body = json.loads(event['body'])
    else:
        body = event.get('body', event)
        
    # Recupera l'ID del video che l'utente sta guardando in questo momento nell'app
    current_video_id = body.get('current_video_id')
    
    if not current_video_id:
        return {
            'statusCode': 400,
            'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({"error": "Parametro 'current_video_id' mancante."})
        }
        
    mongo_uri = os.environ.get('MONGO_URI')
    if not mongo_uri:
        return {
            'statusCode': 500,
            'body': json.dumps({"error": "MONGO_URI non configurata."})
        }
        
    client = MongoClient(mongo_uri)
    db = client['unibg_tedx_2026']
    talks_col = db['tedx_data']
    
    # Cerchiamo il talk specifico tramite la sua chiave primaria _id
    talk = talks_col.find_one({"_id": str(current_video_id)})
    
    if not talk:
        return {
            'statusCode': 404,
            'headers': {'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*'},
            'body': json.dumps({"error": "Talk non trovato."})
        }
        
    # Estraiamo l'array strutturato generato dal nostro script Glue
    watch_next_list = talk.get('related_videos', [])
    
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps(watch_next_list)
    }