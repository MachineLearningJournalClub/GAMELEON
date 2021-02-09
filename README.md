# Pretty GAMELEON : Pretty General Agent-based Model (for) Epidemiological (and) Logistical Enquiries On Networks
## Covid19 Multi Agent Epidemic Modelling - City of Toronto 

![GAMELEON](https://raw.githubusercontent.com/sazio/GAMELEON/master/Img/GAMELEON.png)

Data & Preprocessing
====================

Over the last few years we have been entering a new era of information
technologies, and despite the evident potential of open data, the
incessantly growing amounts of information being gathered by governments
and industries is rarely accessible for scientists and researchers.

There is a substantial vicious circle in the development of tools based
on the vast ocean of data that we are facing nowadays: on one side there
are lots of unstructured data that could be employed in scientific
models for public service; on the other side, most of the times,
researchers do not have at their disposal a sufficient amount of data to
pinpoint their models.

There is a certain amount of questions that need to be answered in order
to circumvent such an issue and circumscribe its pros and cons: what
kind of social and economical transformations has open data brought
about, so far, and what transformations might it trigger in the future?
How — and under which circumstances — has it been most effective? How
have open-data practitioners mitigated risks (e.g. to privacy) while
maximizing social good? [18]

Open data are an open problem in science: especially when it comes to
quantitative epidemic simulations, if your model aims at being effective
for policy-makers at the spatial scale of a city, you would necessarily
need data at a finer spatial scale - i.e. neighborhood. An analogous
argument can be made for the temporal scale: if one’s decide to include,
let us say, traffic mobility dynamics, daily data are not enough to
capture humans behaviour.

Luckily, for some cities - the list is surprisingly very short - it is
possible to gather open data at a fine spatial scale, both for
zoning-by-laws and, in our case, for Sars-Cov-2 spread. Given the
accessibility and huge amount of open data, we decided to build our
model on the metropolitan area of Toronto - Canada.

Here follows a brief overview of the different services (APIs) and
datasets we employed to devise our model.

Covid-19 Data - Toronto by Neighborhood
---------------------------------------

This dataset [19] contains demographic, geographic, and severity
information - at the spatial scale of each neighborhood - for all
confirmed and probable cases reported to and managed by Toronto Public
Health since the first case was reported in January 2020. This includes
cases that are sporadic (occurring in the community) and
outbreak-associated. The data are extracted from the provincial
communicable disease reporting system (iPHIS) and Toronto’s custom
COVID-19 case management system (CORES) and combined for reporting.


TomTom Move API
---------------

TomTom, one of the leaders in location technologies, recently decided to
develop an API service [20] in order to let their data be ready to use
for different purposes. It is possible to select and download traffic
mobility data for entire cities with a daily time resolution. With
respect to the spatial scale, TomTom’s API cover every existing street
and road. Given this granularity, we decided to sample data from a
pre-Covid time range, i.e. April 01-28 ,2019.

In order to simulate the daily evolution of Sars-Cov-2 we needed some
other data for extrapolating the hourly evolution of traffic mobility.
For this purpose, we employed the historical TomTom *Traffic Index* [21]
- on the time range that we have previously selected - , which basically
reports the hourly traffic congestion averaged over the whole area of
interest.

OpenStreetMap (OSM) Layers
--------------------------

OpenStreetMap [22] is an astounding example of how open data - GIS in
this case - are crucial. OSM basically lets you export worldwide geodata
for every map. In our case we employed *GeoFabrik*[23] and *OSM
Polygons*[24] to, respectively, download and extract the administrative
area of Toronto and all its layers, such as Railways, Transport Lines
(Subways, Bus routes), Airports; which turned out to be useful in
constructing our MAS model.

Toronto’s Neighborhood Profiles
-------------------------------

This dataset contains Neighbourhood Profiles which are based on data
collected by Statistics Canada in its 2016 Census of Population. Data is
gathered from the Census Profile as well as a number of other tables,
including Core Housing Need, living arrangements and income sources.

3D Massing Data
---------------

This dataset [25] is part of the impactful project of the City of
Toronto in creating city-wide open source data in accessible formats. By
exploring such a way of sharing information, a direct consequence is an
improvement in the planning process, from different perspectives. In our
case we are interested in this dataset since it provides a variety of 3D
digital models, readily available to the public.

Essentially, it provides us with 3D models of buildings, which might be
useful in re-creating the population distribution in a realistic manner,
by giving us the chance to roughly reproduce apartments and families
dispositions.

Zoning by Laws Data
-------------------

This dataset [26] contains *ESRI shapefiles* that are part of the
*Zoning By-law 569-2013*. Basically data are divided in zones which are
assigned to a specific category, e.g. Residential, Open Space,
Commercial, Institutional and many more.

Apple Mobility Trends Reports
-----------------------------

Since TomTom’s mobility data are extracted from a pre-Covid-19 period,
it might be essential to find a way to constrain eventual lockdown or
partial-lockdown strategies by affecting mobility. Apple publishes [27],
with the highest level of privacy, daily reports which reflect requests
for directions on Apple Maps. In particular, since some days were
missing, we opted for a *geometric progression* imputing, in order to
preserve the general trend of the time series.

Methods
=======

GIS Data Preprocessing
----------------------

In order to build a realistic environment for our agents, we needed to
merge two GIS datasets, namely: *3D Massing* and *Zoning by Laws*. By
using *geopandas*[28] Python library, we have been able to, firstly
match coordinates projection (epsg : 4326) and secondly to preprocess
both datasets. The last step in this process has been to intersect
zoning polygons with buildings, in order to extract each building
category.

In this way we obtained an environment where each building is assigned
to some specific category, de facto making an agent’s life easier in
choosing where to head to.


As a proof of concept, we decided to investigate the application of our
model on a restricted area environment. Instead of employing the whole
city of Toronto, which is definitely a medium-large sized city, we
decided to focus our attention on a single neighborhood: *West
Humber-Clairville*. Again, by employing *geopandas* it is not difficult
to retrieve a specific neighborhood and extract its perimeter for
further processing of demographic Data.

Demographic Data Preprocessing
------------------------------

*Neighborhood Profiles* have been useful to determine the population for
each specific neighborhood, as well as the age distribution. Luckily
there were information regarding the distribution of households, but up
to 4 members. To build a more realistic environment, we decided to
empirically estimate households with 5 and more members: by fitting an
exponential function on the number of households from 1 to 5, we have
been able to impute the missing data.

Traffic Data Preprocessing
--------------------------

Roads exhibit a network structure, and traffic can be envisioned as a
time evolving process on a network. The starting point has been to
employ OSM Layers and specifically the road layer as the skeleton or
static network of our model.

In order to replicate realistic mobility patterns, we decided to employ
TomTom API’s data as a building block for outlining a weighted network
approach. One fundamental feature, named *sampleSize*, has been employed
as a criterion for extracting reliable weights. The *sampleSize* feature
is basically the daily number of vehicles going down a specific street.
We needed to integrate the *Traffic Index* so that to get an hourly
weighted network. By doing that, the result wasn’t significantly
different: daily weights and hourly weights were pretty much the same
(up to the 5th decimal), that’s why we decided to stick to the first one
and we assumed that weights are static during the day.

Having such a weighted network allows us to extend our current model to
include public transports with realistic travel time and thus realistic
infection conditions.
