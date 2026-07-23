# **TEDxplore: dai libri alle idee**
TEDxplore è un'applicazione mobile innovativa progettata per abbattere la **"Filter Bubble"** culturale dei lettori digitali. Collegandosi all'account Amazon Kindle, l'app analizza i generi letterari preferiti dell'utente per offrire una selezione curata di talk TEDx, trasformando un interesse passivo in curiosità attiva.

Il progetto nasce come soluzione al problema della segregazione algoritmica: i lettori digitali tendono a rimanere confinati in generi familiari, limitando l'esposizione a nuove prospettive. TEDxplore funge da "ponte intelligente" tra il mondo della lettura e l'ispirazione digitale.

## **Stack Tecnologico**
* **Frontend**: Flutter (cross-platform iOS/Android/Web).
* **Backend**: AWS Lambda (App Logic & ETL).
* **Database**: MongoDB Atlas per l'archiviazione di dati strutturati e indicizzati.
* **Data Pipeline**: AWS Glue per la gestione del catalogo dati e processi ETL.
* **Auth**: Amazon Cognito per la gestione sicura dell'identità utente.

## **Struttura del Repository**
```text
UNIBG_CLOUD-MOBILE_26/
├── aws/                    # Backend: Logica serverless e ETL
│   ├── glue/               # Processi ETL per la pulizia e il caricamento su MongoDB
│   └── lambda/             # API Lambda (Node.js/Python) per il filtraggio e le raccomandazioni
├── data/                   # Dataset e configurazioni
│   ├── mappings/           # Mapping JSON/CSV (Generi Kindle -> Tag TEDx)
│   └── raw/                # Dataset originali (CSV): dettagli, tag, immagini, correlazioni
├── database_MongoDB/       # Script per la configurazione degli indici su MongoDB Atlas
├── docs/                   # Documentazione tecnica e presentazioni (PPT)
└── tedxplore/              # Frontend: codice sorgente dell'app Flutter
    └── lib/                # Logica applicativa, UI e modelli dati
```

## Architettura del Sistema
Il sistema segue un flusso di dati moderno:
- Ingestione: I dati TEDx (titoli, tag, descrizioni) vengono caricati su Amazon S3.  
- Elaborazione: AWS Glue e Lambda puliscono e mappano i tag dei video ai generi letterari.  
- Raccomandazione: Un motore di ricerca su MongoDB Atlas incrocia lo storico Kindle con i metadati dei talk.  

### Team (Università di Bergamo)
- Gandolfi Leonardo - 1086657   
- Morgera Claudio - 1093069 
- Zambonelli Julia - 1093775   
