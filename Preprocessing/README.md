# Wear a Mask before entering! 

<p align="center">
  <a href="https://github.com/sazio/GAMELEON">
    <img src="https://github.com/sazio/GAMELEON/blob/master/Img/GAMELEON_Masked.png?raw=true" alt="Logo" width="480" height="380">
  </a>
</p>


###  ```GIS_Data_Toronto.ipynb ``` Preprocessing all the datasets:
 * Covid-19 data by Neighborhood 
 * Traffic mobility data by TomTomAPI & Traffic Index
 * Demographic Data (Neighborhood Profiles) from 2016 census 
 * 3D Massing & Zoning by laws 
 * Apple Mobility Data 


*  ``` GameleonCurfewBatch_1k.gaml ``` Testing Curfew for West Humber-Clairville (Toronto Neighborhood of choice) in the idealized case (agents = 1020), both by imposing Curfew_Time = 6 p.m (or 7.p.m., or 8 p.m.) , i.e. the daily time after which the curfew starts, and curfew_delay = 5 (or 10): the curfew is effective 5 or 10  after the start of the simulation.

*  ``` GameleonInvasionBatch.gaml ``` Testing the number of initial infected agents among 5, 10, 20, 30, 50.

*  ``` GameleonTuningBatch.gaml ``` Testing different Betas, corresponding to the transmission rate of the epidemics for the realistic case (agents = 30030)

*  ``` GameleonTuningBatch_1k.gaml ``` Testing different Betas, corresponding to the transmission rate of the epidemics for the idealized case (agents = 1020)
