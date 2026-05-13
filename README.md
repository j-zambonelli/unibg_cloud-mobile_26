# TEDxplore: dai libri alle idee
TEDxplore è un'applicazione mobile progettata per abbattere la `"Filter Bubble"` culturale dei lettori digitali. 
Collegandosi al tuo account Amazon Kindle, l'app analizza i tuoi generi letterari preferiti per offrirti una selezione curata di talk TEDx, trasformando un interesse passivo in curiosità attiva. 

I lettori digitali tendono a rimanere confinati in generi familiari, limitando l'esposizione a nuove prospettive. 
TEDxplore funge da "ponte intelligente" tra il mondo della lettura e l'ispirazione digitale.  


### Stack Tecnologico
- **`Frontend`**: Flutter (cross-platform iOS/Android/Web).  
- **`Backend`**: AWS Lambda (App Logic & ETL).  
- **`Database`**: MongoDB Atlas per l'archiviazione dei dati strutturati e indicizzati.  
- **`Data Pipeline`**: AWS Glue per la gestione del catalogo dati e processi ETL.  
- **`Auth`**: Amazon Cognito per la gestione sicura dell'identità utente.  

### Struttura del Repository
```Plaintext
UNIBG_CLOUD-MOBILE_26/
├── aws/
│   ├── lambda/         # Include gli script per il filtraggio dei generi Kindle e la logica di raccomandazione dei talk.
│   └── glue/           # Contiene i processi ETL per la pulizia e il caricamento dei dati su MongoDB Atlas.
├── data/               # Dataset estratti (CSV) e file di mapping 
|   ├── mappings/       # File JSON/CSV per la corrispondenza dei generi Kindle con i Tag TEDx
│   └── raw/            # Contiene i dataset originali TEDx relativi a dettagli, tag, immagini e video correlati.
├── database_MongoDB/   # Script per la creazione di indici su MongoDB Atlas
├── docs/               # Documentazione tecnica e architettura di sistema
└── frontend/           # Codice sorgente dell'app Flutter
```
### Architettura del Sistema
Il sistema segue un flusso di dati moderno:
- Ingestione: I dati TEDx (titoli, tag, descrizioni) vengono caricati su Amazon S3.  
- Elaborazione: AWS Glue e Lambda puliscono e mappano i tag dei video ai generi letterari.  
- Raccomandazione: Un motore di ricerca su MongoDB Atlas incrocia lo storico Kindle con i metadati dei talk.  

### Team (Università di Bergamo)
- Gandolfi Leonardo - 1086657   
- Morgera Claudio - 1093069 
- Zambonelli Julia - 1093775   
