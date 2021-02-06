# Pretty GAMELEON : Pretty General Agent-based Model (for) Epidemiological (and) Logistical Enquiries On Networks
## Covid19 Multi Agent Epidemic Modelling - City of Toronto 


## Dati [Google Drive](https://drive.google.com/drive/folders/1U4CRamdenX-lpAS9oQFKIzZzWV3VjLcH?usp=sharing): 

* [API TomTom Move](https://ts.tomtom.com/) , dati di traffico a livello di ogni strada (primarie e secondarie) della città di Toronto, aggregati per ogni giornata del mese di Aprile 2019, potrebbe essere un buon riferimento per la mobilità pre-covid. Features : ['newSegmentId', 'speedLimit', 'frc', 'streetName', 'distance',   'segmentTimeResults', 'geometry']

* Casi di Covid a livello di Quartiere (ci sono 140 quartieri) nella [città di Toronto](https://open.toronto.ca/dataset/covid-19-cases-in-toronto/) , con le seguenti features : ['_id', 'Assigned_ID', 'Outbreak Associated', 'Age Group',
 'Neighbourhood Name', 'FSA', 'Source of Infection', 'Classification',     'Episode Date', 'Reported Date', 'Client Gender', 'Outcome' ,  ‘Currently Hospitalized', 'Currently in ICU', 'Currently Intubated',   'Ever Hospitalized', 'Ever in ICU', 'Ever Intubated'] 


* Toronto OpenStreetMap (OSM) layers, filtrati dalla regione dell’Ontario che può essere scaricata tramite [geofabrik](https://download.geofabrik.de/north-america/canada.html) utilizzando [polygons](http://polygons.openstreetmap.fr/?id=324211) . Dove *id = 324211* rappresenta [l’area amministrativa di Toronto]((https://www.openstreetmap.org/relation/324211#map=11/43.7175/-79.3762)), estratta tramite OSM 

*  Dati altezza palazzi: [3D Massing Data](https://ckan0.cf.opendata.inter.prod-toronto.ca/tl/dataset/3d-massing)). Avendo l'altezza di tutte le costruzioni a Toronto sarà possibile stimare (in maniera cruda, ma meglio di niente) quante persone possono stare in ogni palazzo. Fondamentale integrare questi dati con i dati di popolazione per quartiere. 

* Dati di caratteristica sulle zone [Zoning By Laws](https://ckan0.cf.opendata.inter.prod-toronto.ca/dataset/zoning-by-law), da questi si può capire se l'edificio è residenziale oppure commerciale, industriale etc.. 

* Dati su congestione traffico, media settimanale a Toronto nell'anno 2019, scraped from https://www.tomtom.com/en_gb/traffic-index/toronto-traffic/


*  [Dati mobilità Apple](https://covid19.apple.com/mobility), search for “Toronto, Ontario, Canada”.  Aggregati sulla Città intera, divisi per “driving”, “walking” e “transit”. Potrebbero essere un buon modo per ridurre il traffico a livello di città intera durante il lockdown simulato. 

## Quick recap dei file in questa repo

* [GIS_Data_Toronto.ipynb](https://github.com/sazio/MultiAgentCovid/blob/master/GIS_Data_Toronto.ipynb) : Notebook in cui vengono preprocessati i dati dell'Ontario (filtrando solo l'area utile : città di Toronto) per i diversi layer presenti da OpenStreetMap (OSM), che potete trovare nella [cartella seguente](https://drive.google.com/drive/u/0/folders/1pb9tC2ceYZoz_5SUKnjecjBal6To06g6). Breve Exploratory Data Analysis (EDA) su dati di traffico (li trovate [qui](https://drive.google.com/drive/u/0/folders/1lEN1dhSCvjQlzbkPAmawNulMngBXfYa2)) e su [dati di casi](https://github.com/sazio/MultiAgentCovid/blob/master/Data/CasesToronto.csv) e di quartiere: su [abitanti](https://github.com/sazio/MultiAgentCovid/blob/master/Data/neighbourhood-profiles-2016-csv.csv) e su [confini geometrici di ognuno](https://github.com/sazio/MultiAgentCovid/blob/master/Data/toronto_neigh.geojson)

* [Data/](https://github.com/sazio/MultiAgentCovid/tree/master/Data) : Contiene i dati (esclusi i file grandi che sono sul drive linkato prima) 
  * [CasesToronto.csv](https://github.com/sazio/MultiAgentCovid/blob/master/Data/CasesToronto.csv) : Casi Positivi al Covid con le seguenti features --> ['_id', 'Assigned_ID', 'Outbreak Associated', 'Age Group', 'Neighbourhood Name', 'FSA', 'Source of Infection', 'Classification', 'Episode Date', 'Reported Date', 'Client Gender', 'Outcome','Currently Hospitalized', 'Currently in ICU', 'Currently Intubated','Ever Hospitalized', 'Ever in ICU', 'Ever Intubated']
  * [Toronto.geojson](https://github.com/sazio/MultiAgentCovid/blob/master/Data/Toronto.geojson): Poligono che determina il limite amministrativo della città di Toronto, utilizzato per filtrare i dati geografici
  * [neighbourhood-profiles-2016-csv.csv](https://github.com/sazio/MultiAgentCovid/blob/master/Data/neighbourhood-profiles-2016-csv.csv): Dati di abitanti a livello di quartiere (con divisione per gruppi di età, sesso... )per  Toronto (aggiornati al 2016 - sono gli ultimi che ho trovato, se trovate di meglio aggiornate) 
  * [toronto_neigh.geojson](https://github.com/sazio/MultiAgentCovid/blob/master/Data/toronto_neigh.geojson): Poligoni che determinano i confini di ogni quartiere, utili per aggregare i dati di traffico e infetti nel modello con GAMA
  
  
* [GAMA/](https://github.com/sazio/MultiAgentCovid/tree/master/GAMA): Contiene il codice da eseguire con GAMA
  * [RoadNet_Toronto.gaml](https://github.com/sazio/MultiAgentCovid/blob/master/GAMA/RoadNet_Toronto.gaml): Codice per importare i diversi layer geografici della città di Toronto, eseguendolo potrete vedere la mappa, ovvero l'ambiente per i nostri agenti


* [Img/](https://github.com/sazio/MultiAgentCovid/tree/master/Img): Immagini utili per visualizzazioni da mettere nel paper per l'esame 
  * [Toronto_Net.png](https://github.com/sazio/MultiAgentCovid/blob/master/Img/Toronto_Net.png) : Mappa di Toronto con i diversi layer geografici in risoluzione non troppo alta 
  * [Toronto_Traffic_Density.png](https://github.com/sazio/MultiAgentCovid/blob/master/Img/Toronto_Traffic_Density.png): Rete stradale di Toronto, pesata in base alle macchine transitanti. 

## Modello Traffico Stradale 

### Intro

Vedi [tutorial su GAMA](https://gama-platform.github.io/wiki/RoadTrafficModel) per spunti.

### Rete Stradale

* Nella sezione **Traffic** di [GIS_Data_Toronto.ipynb](https://github.com/sazio/MultiAgentCovid/blob/master/GIS_Data_Toronto.ipynb) vengono ripuliti (e ulteriormente compressi) i dati presi dall' API di TomTom Move e mandata in output - vd. [Toronto_Traffic_Density.png](https://github.com/sazio/MultiAgentCovid/blob/master/Img/Toronto_Traffic_Density.png), fatta sul giorno 01-Apr-2019 - la rete pesata (tramite *log(#macchine)* che passano su un determinato link = strada)

![Traffic](https://raw.githubusercontent.com/sazio/MultiAgentCovid/master/Img/Toronto_Traffic_Density.png?token=ADFSHLEQM3TZTDHVOLJO47C7UXTTK)


### Distribuzione del traffico orario (empirica) 
Per questa, possiamo integrare i dati TomTom giornalieri con la curva della congestione settimanale di traffico come densità di probabilità delle macchine che vanno in giro. In questo modo avremmo un ottimo modello per il traffico pre-covid
![traffic_congestion](https://raw.githubusercontent.com/sazio/MultiAgentCovid/master/Img/traffic_congestion.png?token=ADFSHLGRSAUWKU2UEJXQJO27UXTXE)

# Modello Epidemico 

### Intro
SIR, considerando che una percentuale dei positivi finirà in ospedale e alcuni invece dovranno fare la quarantena in casa a un certo punto. Questa evidenza potrebbe essere modellata introducendo un parametro (in stile fitness del modello generativo Bianconi-Barabasi) per la **carica virale**. 

Per ora, dopo il lungo preprocessing, abbiamo dati specifici su ogni palazzo, riguardo al suo volume fisico (utile per stimare quante persone ci stanno dentro) e la categoria (residenziale, commerciale, industriale). In questo modo la distribuzione iniziale delle persone dovrebbe essere soddisfacente. 

Oltre al dato sul numero degli abitanti, sono disponibili gli abitanti per fascia di età: 

* Children (0-14 years) 
* Youth (15-24 years)	
* Working Age (25-54 years)
* Pre-retirement (55-64 years)	
* Seniors (65+ years)
* Older Seniors (85+ years)

Per quanto riguarda i casi totali, abbiamo la seguente curva epidemica. 
![Cases](https://raw.githubusercontent.com/sazio/MultiAgentCovid/master/Img/cases.png?token=ADFSHLFKYLM5BDMUUDPDW5C7UXTQ2)

Anche qui, con la massima anonimizzazione, è stata fatta una divisione per fasce di età e per quartiere di residenza, specificando inoltre, se la *source of infection* e se lo specifico paziente abbia usufruito della terapia intensiva.

![ex_infected_data](https://raw.githubusercontent.com/sazio/MultiAgentCovid/master/Img/ex_infected_cases.png?token=ADFSHLDDX2DG27ZXBV63ERS7UXTPU)

## Stima della popolazione per palazzo 

Per stimare quante persone vivono (o lavorano) in una costruzione, possiamo integrare i dati di popolazione x quartiere con quelli di area + altezza ( [3D Massing Data](https://ckan0.cf.opendata.inter.prod-toronto.ca/tl/dataset/3d-massing)) delle costruzioni. Insieme a questi, integrare i dati di caratteristica sulle zone ([Zoning By Laws](https://ckan0.cf.opendata.inter.prod-toronto.ca/dataset/zoning-by-law)) sarà essenziale per replicare una distribuzione di popolazione simile a quella effettiva. 

![Height_Buildings](https://raw.githubusercontent.com/sazio/MultiAgentCovid/master/Img/height_buildings.png?token=ADFSHLBBRWJ4HAVZW7SUIVK7UXTN2)

### Ricostruzione Nuclei Familiari 

Dai dati per quartiere, forniti dalla città di Toronto, è disponibile l'informazione sul numero di nuclei formati da 1, 2, 3, 4, 5 + persone.

![1to5+people](https://raw.githubusercontent.com/sazio/MultiAgentCovid/master/Img/1_to_5_people.png?token=ADFSHLCU3RF6HSNH7HPNBIC7UXTKO)

Quello che è stato fatto, per permettere una migliore disposizione degli agenti a t = 0 è stato disaggregare i nuclei 5+ in nuclei composti da 5, 6, 7, 8, 9, 10 persone. In questo modo possiamo permetterci di ricreare dinamiche di contagio "familiari" per il luogo di residenza, vincolando gli agenti a stare in un determinato luogo di residenza e spostandosi per lavoro etc. 

![5to10people](https://raw.githubusercontent.com/sazio/MultiAgentCovid/master/Img/5_to_10_people.png?token=ADFSHLEUPTKIPTMOUYYZNTC7UXTK6)


