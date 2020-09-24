# Covid19 Multi Agent Epidemic Modelling - City of Toronto 


## Dati [Google Drive](https://drive.google.com/drive/folders/1U4CRamdenX-lpAS9oQFKIzZzWV3VjLcH?usp=sharing): 

* [API TomTom Move](https://ts.tomtom.com/) , dati di traffico a livello di ogni strada (primarie e secondarie) della città di Toronto, aggregati per ogni giornata del mese di Aprile 2019, potrebbe essere un buon riferimento per la mobilità pre-covid. Features : ['newSegmentId', 'speedLimit', 'frc', 'streetName', 'distance',   'segmentTimeResults', 'geometry']

* Casi di Covid a livello di Quartiere (ci sono 140 quartieri) nella [città di Toronto](https://open.toronto.ca/dataset/covid-19-cases-in-toronto/) , con le seguenti features : ['_id', 'Assigned_ID', 'Outbreak Associated', 'Age Group',
 'Neighbourhood Name', 'FSA', 'Source of Infection', 'Classification',     'Episode Date', 'Reported Date', 'Client Gender', 'Outcome' ,  ‘Currently Hospitalized', 'Currently in ICU', 'Currently Intubated',   'Ever Hospitalized', 'Ever in ICU', 'Ever Intubated'] 


* Toronto OpenStreetMap (OSM) layers, filtrati dalla regione dell’Ontario che può essere scaricata tramite [geofabrik](https://download.geofabrik.de/north-america/canada.html) utilizzando [polygons](http://polygons.openstreetmap.fr/?id=324211) . Dove id = 324211 rappresenta [l’area amministrativa di Toronto]((https://www.openstreetmap.org/relation/324211#map=11/43.7175/-79.3762)), estratta tramite OSM 


*  [Dati mobilità Apple](https://covid19.apple.com/mobility), search for “Toronto, Ontario, Canada”.  Aggregati sulla Città intera, divisi per “driving”, “walking” e “transit”. Potrebbero essere un buon modo per ridurre il traffico a livello di città intera durante il lockdown simulato. 


## Quick recap dei file in questa repo

* [GIS_Data_Toronto.ipynb](https://github.com/sazio/MultiAgentCovid/blob/master/GIS_Data_Toronto.ipynb) : Notebook in cui vengono preprocessati i dati dell'Ontario (filtrando solo l'area utile : città di Toronto) per i diversi layer presenti da OpenStreetMap (OSM), che potete trovare nella [cartella seguente](https://drive.google.com/drive/u/0/folders/1pb9tC2ceYZoz_5SUKnjecjBal6To06g6). Breve Exploratory Data Analysis (EDA) su dati di traffico (li trovate [qui](https://drive.google.com/drive/u/0/folders/1lEN1dhSCvjQlzbkPAmawNulMngBXfYa2)) e su [dati di casi](https://github.com/sazio/MultiAgentCovid/blob/master/Data/CasesToronto.csv) e di quartiere: su [abitanti](https://github.com/sazio/MultiAgentCovid/blob/master/Data/neighbourhood-profiles-2016-csv.csv) e su [confini geometrici di ognuno](https://github.com/sazio/MultiAgentCovid/blob/master/Data/toronto_neigh.geojson)

* Data/ : Contiene i dati (esclusi i file grandi che sono sul drive linkato prima) 
  * d




## Modello Epidemico 
SIR su rete stradale, considerando che una percentuale dei positivi finirà in ospedale e alcuni invece dovranno fare la quarantena in casa a un certo punto ( vedi tutorial su GAMA per spunti, https://gama-platform.github.io/wiki/LuneraysFlu )

## Modello Traffico Stradale 

Modello Epidemico: SIR su rete stradale, considerando che una percentuale dei positivi finirà in ospedale e alcuni invece dovranno fare la quarantena in casa a un certo punto ( vedi tutorial su GAMA per spunti, https://gama-platform.github.io/wiki/LuneraysFlu )
