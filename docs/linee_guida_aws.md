# **LINEE GUIDA AWS**
## **BUCKET**
> Contenitore S3 per lo storage grezzo dei dati (CSV) e dei log di esecuzione


| NOME | FILE RELATIVO | CARATTERISTICHE  |
| ---- | --------------- | ------------- |
| tedx-data-jz |`../backend_aws/infrastucture.yml` | importare i file csv in `../data/raw` |
| tedx-log-jz |`../backend_aws/infrastucture.yml`|  |
| tedx-script-jz |`../backend_aws/infrastucture.yml` | | 

Per la creazione automatica dei bucket inserire i pezzi di codice (../backend_aws/infrastucture.yml) con **CLOUD FORMATION**

## **CLOUD FORMATION**
> Servizio per il provisioning dell'infrastruttura. Usato per automatizzare la creazione dei bucket e delle policy senza click manuali.

- creazione di uno stack TEDX-inf-1 e caricamento di `../backend_aws/infrastucture.yml`
- per le fasi successivo cliccare su *Aggiorna stack $\rightarrow$ crea un set di modifiche* e caricare il file aggiornato

## **LAMBDA FUNCTION**
> In ambito AWS, una Lambda Function è un servizio di calcolo "serverless" che permette di eseguire codice senza dover gestire o configurare alcun server.

| NOME | FILE RELATIVO | Caratteristiche |
| ---- | --------------- | ------------- |
|get_kindle_recommendations |`../backend_aws/lambdas/watch_next/get_kindle_recommendations.mjs` | Node.js 22.x , index.handler, x86_64 |
|watch_next_by_id |`../backend_aws/lambdas/watch_next/watch_next_by_id.mjs` | Node.js 22.x , index.handler, x86_64 |
|watch_next_by_tags  |`../backend_aws/lambdas/watch_next/watch_next_by_tags.mjs` | | Node.js 22.x , index.handler, x86_64 |
|TedxGetRecommendedVideos|`../backend_aws/lambdas/zip/recommended_video.zip`| Python 3.12, recommended_videos.lambda_handler, x86_64, livello pymongo-layer|
|TedxGetUserProfile|`../backend_aws/lambdas/zip/user_profile.zip`| Python 3.12, user_profile.lambda_handler, x86_64, livello pymongo-layer|
|TedxGetLatestVideos|`../backend_aws/lambdas/zip/latest_videos.zip`| Python 3.12, latest_videos.lambda_handler, x86_64, livello pymongo-layer|



tutte le lambda presentano nella voce *variabili di ambiente* la seguente relazione: 
|CHIAVE | VALORE |
| ----  | ------ |
| MONGO_URI | mongodb+srv://unibg2026:unibg2026@cluster0.0jtalde.mongodb.net/unibg_tedx_2026?appName=Cluster0 |

## **AWS GLUE**
> AWS Glue è un servizio di integrazione dati completamente gestito, di tipo "serverless", progettato per semplificare le attività di ETL (Extract, Transform, Load). In parole semplici, serve a prendere i dati da fonti diverse, pulirli, trasformarli e caricarli in una destinazione finale (come un data warehouse o un data lake) per poterli analizzare.

Con AWS GLUE si crea un nuovo job nel quale viene incollato il file `../backend_aws/glue_jobs/tedx_load_aggregate_model.py`
Nella voce Job Details vengono inserite le seguenti impostazioni: 
- IAM ROLE: LabRole
- Glue 5.1 - Supports sparks 3.5, Scala 2, Python 3
- Language: Python 3 
- Worker type: G 1X
- Requested number of workers: 10 
- Job timeout: 480 

**Job parameters**
|CHIAVE | VALORE |
| ----  | ------ |
| --DETAILS_PATH | s3://tedx-data-jz/details.csv |
| --FINAL_LIST_PATH | s3://tedx-data-jz/final_list.csv |
| --RELATED_VIDEOS_PATH |s3://tedx-data-jz/related_videos.csv |
| --TAGS_PATH |s3://tedx-data-jz/tags.csv |

## **API GATEWAY**
> Servizio per pubblicare, mantenere, monitorare e proteggere le API che fanno da ponte tra il frontend Flutter e le funzioni Lambda.

- Tipo: REST API
- Nome: TedxploreAPI

| RISORSE | OPERAZIONI |
| ------- | -------- |
| latest  | GET e OPTIONS |
| recommended | OPTIONS e POST |
| user/profile| GET e OPTIONS | 

- Nome: Get_Talks_By_Tag-API
- Nome: watch_next_by_id-API
- Nome: watch_next_by_tags-API

In seguito per ogni risorsa è necessario *abilitare il CORS* e implementare l'API sulla fase *prod*

## **AMAZON COGNITO**
> Servizio di gestione identità per autenticare e autorizzare l'accesso degli utenti.

- Nome: Tedxplore-App
- Identificativo di accesso: email

- User pool - ig7c5w
- ID client: 2o1mgslcfpl69k43vvloa752uk

altre informazioni 
| URL di callback permessi | URL di disconnessione consentiti | Ambiti OpenID |
| ------- | -------- | ---------- |
| http://localhost:49273 | http://localhost:49273 | email |
| http://localhost:49273/ |http://localhost:49273/ | openId |
| tedxplore://callback | tedxplore://signout | name |
|  |  |  profile |

