# Covid19 Multi Agent Epidemic Modelling - City of Toronto 


## Dati [Google Drive](https://drive.google.com/drive/folders/1U4CRamdenX-lpAS9oQFKIzZzWV3VjLcH?usp=sharing): 

* [API TomTom Move](https://ts.tomtom.com/) , dati di traffico a livello di ogni strada (primarie e secondarie) della città di Toronto, aggregati per ogni giornata del mese di Aprile 2019, potrebbe essere un buon riferimento per la mobilità pre-covid. Features : ['newSegmentId', 'speedLimit', 'frc', 'streetName', 'distance',   'segmentTimeResults', 'geometry']

* Casi di Covid a livello di Quartiere (ci sono 140 quartieri) nella [città di Toronto](https://open.toronto.ca/dataset/covid-19-cases-in-toronto/) , con le seguenti features : ['_id', 'Assigned_ID', 'Outbreak Associated', 'Age Group',
 'Neighbourhood Name', 'FSA', 'Source of Infection', 'Classification',     'Episode Date', 'Reported Date', 'Client Gender', 'Outcome' ,  ‘Currently Hospitalized', 'Currently in ICU', 'Currently Intubated',   'Ever Hospitalized', 'Ever in ICU', 'Ever Intubated'] 


* Toronto OpenStreetMap (OSM) layers, filtrati dalla regione dell’Ontario che può essere scaricata tramite [geofabrik](https://download.geofabrik.de/north-america/canada.html) utilizzando [polygons](http://polygons.openstreetmap.fr/?id=324211) . Dove *id = 324211* rappresenta [l’area amministrativa di Toronto]((https://www.openstreetmap.org/relation/324211#map=11/43.7175/-79.3762)), estratta tramite OSM 


*  [Dati mobilità Apple](https://covid19.apple.com/mobility), search for “Toronto, Ontario, Canada”.  Aggregati sulla Città intera, divisi per “driving”, “walking” e “transit”. Potrebbero essere un buon modo per ridurre il traffico a livello di città intera durante il lockdown simulato. 

* [Dati altezza buildings](https://critchley-ryerson.carto.com/tables/odmassing_2014_wgs_w_address_missadd_zone/public) Avendo l'altezza di tutte le costruzioni a Toronto sarà possibile stimare (in maniera cruda, ma meglio di niente) quante persone possono stare in ogni palazzo. Fondamentale integrare questi dati con i dati di popolazione per quartiere. 


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

### Rete Pesata 

* Nella sezione **Traffic** di [GIS_Data_Toronto.ipynb](https://github.com/sazio/MultiAgentCovid/blob/master/GIS_Data_Toronto.ipynb) vengono ripuliti (e ulteriormente compressi) i dati presi dall' API di TomTom Move e mandata in output - vd. [Toronto_Traffic_Density.png](https://github.com/sazio/MultiAgentCovid/blob/master/Img/Toronto_Traffic_Density.png), fatta sul giorno 01-Apr-2019 - la rete pesata (tramite *log(#macchine)* che passano su un determinato link = strada)



### Distribuzione del traffico orario (empirica) 
* Paper

## Modello Epidemico 

### Intro
SIR su rete stradale, considerando che una percentuale dei positivi finirà in ospedale e alcuni invece dovranno fare la quarantena in casa a un certo punto ( vedi tutorial su GAMA per spunti, https://gama-platform.github.io/wiki/LuneraysFlu )

### Stima della popolazione per palazzo 

Per stimare quante persone vivono (o lavorano) in una costruzione, possiamo integrare i dati di popolazione x quartiere con quelli di area + altezza ([Dati altezza buildings](https://critchley-ryerson.carto.com/tables/odmassing_2014_wgs_w_address_missadd_zone/public)) delle costruzioni. 
