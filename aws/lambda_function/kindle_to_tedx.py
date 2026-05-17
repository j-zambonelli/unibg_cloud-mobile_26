import json

def lambda_handler(event, context):
    """
    Mappa i generi letterari Kindle nei tag TEDx corrispondenti.
    """
    if isinstance(event.get('body'), str):
        body = json.loads(event['body'])
    else:
        body = event.get('body', event)
        
    kindle_genres = body.get('kindle_genres', [])
    
    # Il dizionario di mappatura per abbattere la Filter Bubble
    mapping_bridge = {
        "Scienza e Tecnologia": ["science", "technology", "innovation", "future"],
        "Biografie": ["biography", "history", "personal growth", "identity"],
        "Saggistica": ["society", "culture", "politics", "global issues"],
        "Self-help": ["psychology", "mental health", "happiness", "motivation"],
        "Economia": ["business", "economics", "finance", "work"],
        "Thriller": ["crime", "mystery", "human nature"]
    }
    
    tedx_tags_to_search = []
    for genre in kindle_genres:
        if genre in mapping_bridge:
            tedx_tags_to_search.extend(mapping_bridge[genre])
            
    unique_tags = list(set(tedx_tags_to_search))
    
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({
            'search_tags': unique_tags,
            'original_genres': kindle_genres
        })
    }