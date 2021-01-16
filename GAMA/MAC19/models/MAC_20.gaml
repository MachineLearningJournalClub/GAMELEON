/**
* Name: MultiAgentCovid_19
* Based on the internal empty template. 
* Author: Simone Azeglio, Matteo Fordiani
* Tags: epidemics, covid19, multiplex, machinelearning
*/

// Per caricare file GIS 
model load_shape_file 
 
global {
	// Global Variables 
	// Global Variables 
	//Number of susceptible host at init
    int number_S <- 10000 ;
    //Number of infected host at init
    int number_I <- 7 ;
    //Number of resistant host at init
    int number_R <- 0 ;
    //Rate for the infection success 
	float beta <- 0.10;
	//Mortality rate for the host
	float nu <- 0.03;
	//Rate for resistance 
	float delta <- 0.95;
	//Number total of hosts <- sostituisco in number of people
	// int numberHosts <- number_S+number_I+number_R;
	float infection_time <- 72 #h;
	float R0 ;
	float step <- 60 #mn;
	date starting_date <- date("2020-01-22-00-00-00");	
	int nb_people <- number_S+number_I+number_R;
	int min_work_start <- 6;
	int max_work_start <- 9;
	int min_work_end <- 16; 
	int max_work_end <- 20; 
	float min_speed <- 15.0 #km / #h;
	float max_speed <- 50.0 #km / #h; 
	
	
	float staying_coeff update: 10.0 ^ (1 + min([abs(current_date.hour - 9), abs(current_date.hour - 12), abs(current_date.hour - 18)]));
	
	// Environment  ------------------------------------------------------------------------
	// Roads, buildings shapefiles import 
    //file roads_shapefile <- file("D:/MultiAgentCovid/Data/Traffic/Filtered_1st_neigh/2019-04-01-Toronto.shp");
    //file buildings_shapefile <- file("D:/MultiAgentCovid/Data/Buildings/buildings_shp/height_buildings_1st_neigh.shp");
    file roads_shapefile <- file("/Users/simoneazeglio/Desktop/MAS/Data/Traffic/Filtered_1st_neigh/2019-04-01-Toronto.shp");
    file buildings_shapefile <- file("/Users/simoneazeglio/Desktop/MAS/Data/Buildings/buildings_shp/height_buildings_1st_neigh.shp");
    
    // Instantiating Road Network 
    geometry shape <- envelope(roads_shapefile);
    graph road_network;
    
    
  
    init {
	    //create building from: buildings_shapefile; ----------------------------------------------------
	    create building from: buildings_shapefile with: [type::string(read ("ZN_ZONE_EX"))] {
	    	// Residential buildings are split up in the following categories:
				if type="Residential" or type="Residential Detached"  or type="Residential Apartment" or type="Commercial Residential"
				or type= "Residential Multiple Dwelling" or type="Residential Apartment Commercial" or type="Residential Semi Detached"
				or type="Residential Townhouse"{
					color <- #blue ;
					is_toobig <- true;
				}
				
				else if type="Residential"  or type="Residential Apartment"
				or type= "Residential Multiple Dwelling" or type="Residential Apartment Commercial" {
					color <- #aqua;
					is_toobig <- true;
					
				}
			// Employement buildings
				else if type ="Employment Industrial" or type="Employment Light Industrial" or type="Employment Heavy Industrial" 
				or type="Employment Industrial Office" or type="Employment Industrial Commercial"{
					color <- #green ;
				}
			// Commercial buildings 
				else if type ="Commercial Residential Employment" or type="Commercial Local"{
					color <- #lime ;
				}
			// Open space places 
				else if type ="Open Space" or type ="Open Space Recreation" or type="Open Space Natural"{
					color <- #yellow ;
				}
				
			// Institutional Education --> Schools + Universities 
				else if type ="Institutional School" or type ="Institutional Education"{
					color <- #orange ;
				}
				
			// Place of Worship --> Churches, temples ...  	
				else if type ="Institutional Place of Worship" {
					color <- #maroon ;
				}
				
			// Institutional General --> Governement & similar
			
				else if type="Institutional General"{
					color <- #aqua;		
				}
			// Hospitals 	
				else if type ="Institutional Hospital" {
					color <- #red ;
				}
				
			// Open Space Golf, Open Space Marina, Utility & Transportation, Uility, UNKNOWN
			}
    
    	list<building> residential_buildings <- building where (each.type="Residential" or each.type="Residential Detached"
    		or each.type="Residential Apartment" or each.type="Commercial Residential" or each.type="Residential Multiple Dwelling"
    		or each.type="Residential Apartment Commercial" or each.type="Residential Semi Detached" or each.type="Residential Townhouse");
    		
		list<building> employement_buildings <- building  where (each.type ="Employment Industrial" or each.type="Employment Light Industrial" 
			or each.type="Employment Heavy Industrial" or each.type="Employment Industrial Office" or each.type="Employment Industrial Commercial") ;
		
		list<building> commercial_buildings <- building  where (each.type ="Commercial Residential Employment" or each.type="Commercial Local") ;
		
		list<building> open_space_buildings <- building  where (each.type ="Open Space" or each.type ="Open Space Recreation" 
			or each.type="Open Space Natural");
		
		list<building> education_buildings <- building  where (each.type ="Institutional School" or each.type ="Institutional Education") ;
		
		list<building> worship_buildings <- building  where (each.type ="Institutional Place of Worship") ;
		
		list<building> government_buildings <- building  where (each.type="Institutional General") ;
		
		list<building> hospital_buildings <- building  where (each.type ="Institutional Hospital") ;
		
    	
   
    	// Weighted road network 
	    create road from:roads_shapefile with:[weight::float(read("weight"))];
	    
	    map<road, float> weights_map <- road as_map (each::each.weight);
	    //write weights_map;  // check - it works! 
	    road_network <- as_edge_graph(road) with_weights weights_map;
	     
	    
	    
	    
		 
		    
    
	    create people number:number_S {
	        speed <- rnd(min_speed, max_speed);
	        
			start_work <- rnd (min_work_start, max_work_start);
			end_work <- rnd(min_work_end, max_work_end);
			
			living_place <- one_of(residential_buildings);  
			working_place <- one_of(employement_buildings);
			objective <- "resting";
			 
			location <- any_location_in(living_place); 
			
	     	is_susceptible <- true;
        	is_infected <-  false;
            is_immune <-  false; 
            color <-  #green;
        
	        }
       create people number:number_I {
     	  	speed <- rnd(min_speed, max_speed);
	        
			start_work <- rnd (min_work_start, max_work_start);
			end_work <- rnd(min_work_end, max_work_end);
			
			living_place <- one_of(residential_buildings);  
			working_place <- one_of(employement_buildings);
			objective <- "resting";
			 
			location <- any_location_in(living_place); 
			
			is_susceptible <-  false;
            is_infected <-  true;
            is_immune <-  false; 
            color <-  #red; 
			
        
        }
        
      create people number:number_R {
        	speed <- rnd(min_speed, max_speed);
	        
			start_work <- rnd (min_work_start, max_work_start);
			end_work <- rnd(min_work_end, max_work_end);
			
			living_place <- one_of(residential_buildings);  
			working_place <- one_of(employement_buildings);
			objective <- "resting";
			 
			location <- any_location_in(living_place); 
			living_place <- one_of(residential_buildings) ;  
		
			location <- any_location_in(living_place); 
			
			is_susceptible <-  false;
            is_infected <-  false;
            is_immune <-  true; 
            color <-  #fuchsia; 
        
        }
	    }
	    
	    /* 
	    //Save the agents on each cycle (1 cycle = 1 hour here) 
	reflex save_agent_attribute{ //when: cycle = 10 {
		ask people {
			// save the values of the variables name, location etc.. to the csv file; the rewrite facet is set to false to continue to write in the same file
			save [name, cycle, location, living_place, working_place, stuff_place, is_susceptible, is_infected, is_immune] to: "/Volumes/DATA/MAS/Data/Agents/Agents_"+ string(cycle) +".csv" type:"csv" rewrite: false;
			// save all the attributes values of the agent in a file. The file is overwritten at every save
			// save people to: "/Users/simoneazeglio/Desktop/MAS/Data/Agents.csv" type:"csv" rewrite: true;
		}
		//Pause the model as the data are saved
		//do pause;
	}
	*/
	
	//  Save buildings location, run once 
	/*
	reflex save_building_attribute when: cycle = 1 {
		ask building {
			// save the values of the variables name, location etc.. to the csv file; the rewrite facet is set to false to continue to write in the same file
			save [name, location] to: "/Users/simoneazeglio/Desktop/MAS/Data/Buildings.csv" type:"csv" rewrite: false;
			// save all the attributes values of the agent in a file. The file is overwritten at every save
			// save people to: "/Users/simoneazeglio/Desktop/MAS/Data/Agents.csv" type:"csv" rewrite: true;
		}
		//Pause the model as the data are saved
		//do pause;
	}
	*/
	    
	}
// Edifici nella città di Toronto

species building {
    string type;
    bool is_toobig <- false;
    rgb color <- #gray;
    float infection_time;
    list<people> people_in_building update: people inside self;
    list<list<people>> families <- nil;
    int n_inf <- 0 update: self.people_in_building count each.is_infected;
    int n_tot <- 0 update: length(self.people_in_building);
    
    aspect base {
    	draw shape color: color ;
   	
    }
    reflex init_families when: (time = 1.0) {
    	loop index from: 0 to: length(people_in_building) - 1 step: 3 {
    		add people_in_building[index] to: families[int(index/3)];
    		add people_in_building[index + 1] to: families[int(index/3)];
    		add people_in_building[index + 2] to: families[int(index/3)];
    	}
    }
    
    reflex infect_families when: (is_toobig and time > 1.0 and n_inf > 0 and current_date.hour = 0) {
    	 
		loop index from: 0 to: length(families) - 1 step: 1 {
		    		bool is_infectfamily <- false;
		    		loop indexf from: 0 to: length(families[index]) -1 step: 1 {
		    			if (families[index][indexf].is_infected) {
		    				bool is_infectfamily <- true;
		    				break;
		    			}
		    		}
		    		
		    		if (is_infectfamily) {
		    			loop indexf from: 0 to: length(families[index]) - 1 step: 1 {
		    				if(families[index][indexf].is_susceptible and flip(beta*0.25)) {
		    					families[index][indexf].is_infected <- true;
		    					families[index][indexf].is_susceptible <- false;
		    					families[index][indexf].is_immune <- false;
		    					families[index][indexf].infection_time <- time;
		    					
		    				}
		    			}
		    		}
    		
    	}
    	
    }
    
//    reflex get_people {
//    	self.people_in_building <- people inside self;
//    }
    
    reflex infect when: (n_inf > 0) {
    	if (!(type="Residential"  or type="Residential Apartment"
				or type= "Residential Multiple Dwelling" or type="Residential Apartment Commercial")) {
    	
	    	loop index from: 0 to: length(people_in_building) - 1 step: 1 {
	    		people agt <- people_in_building[index];
	    		if ((!agt.is_immune) and agt.is_susceptible and flip(beta*n_inf/length(people_in_building))) {
		    		agt.is_infected <- true;
		    		agt.is_susceptible <- false;
		    		agt.is_immune <- false;	   
		    		agt.infection_time <- time; 		
	    		}
	    	}
    	
    	}
    	
	}
}

// Strade di Toronto
species road {
	float weight;
    aspect geom {
    	draw shape color: #black;
    }
     
}



// Persone
species people skills:[moving]{
	float speed; 
	int staying_counter; 
	
	bool adult <- false;
	bool senior <- false;
	bool juvenile <- false;
	
    rgb color <- #fuchsia ;
    
    building living_place <- nil ;
    building working_place <- nil ;
    building school <- nil;
    building worship_place <- nil;
    building stuff_place <- nil;
    
	float infection_time <-nil;
	float hospitalization_time <- nil;
	int start_work ;
	int end_work  ;
	string objective ; 
	point target <- nil;
	
	//Booleans to represent the state of the host agent
	bool is_susceptible <- false;
	bool is_infected <- false;
    bool is_immune <- false;
    bool is_dead <- false;
    bool is_hospitalized <- false;     
    bool can_recover <- true;  
 
	// Qua si possono metter diversi reflex in base a quali posti
	// vogliamo far visitare all'agente: chiesa, parco... con orari precisi o 
	// probabilità associata all'azione in base all'ora / giorno 
	
	reflex time_to_work when: current_date.hour = start_work and objective = "resting"{
		objective <- "working" ;
		target <- any_location_in (working_place);
	}
		
	reflex time_to_go_home when: current_date.hour = end_work and objective = "working"{
		objective <- "resting" ;
		target <- any_location_in (living_place); 
	} 
	
	
	reflex staying when: target = nil {
		staying_counter <- staying_counter + 1;
		if flip(staying_counter / staying_coeff) {
			target <- any_location_in(one_of(building));
		}
	}
	
	// Importante, in questo modo salviamo i cammini di ogni agente!!
	// sarebbe bene impostare abitudini (ad esempio, stesso posto per andare a lavoro 
	// e stessa casa) 	
	reflex move when: target != nil{
		path path_to_store <- goto(target:target, on:road_network, return_path:true);
		//write path_to_store; // check - it works! 
			 if (location = target) {
				target <- nil;
				staying_counter <- 0;
			}  
			
		}
		
    
    //Reflex to make the agent recovered if it is infected and if it success the probability
    reflex become_immune when: is_infected and ((time - infection_time) > 10*24*3600) and can_recover {
    	if (flip(delta)) {
	    	is_susceptible <- false;
	    	is_infected <- false;
	        is_immune <- true;
	        can_recover <- false;
        } else {
        	is_hospitalized <- true;
        	is_infected <- true;
        	is_immune <- false;
        	can_recover <- true;
        	hospitalization_time <- time;
        }
    }
    
    reflex dismissed when: is_hospitalized and ((time - hospitalization_time) > 14*24*3600) {
    	if(flip(0.4)) {
    		is_hospitalized <- false;
    		is_infected <- false;
    		is_susceptible <- false;
    		is_immune <- true;
    	} else {
    		is_hospitalized <- false;
    		is_infected <- false;
    		is_susceptible <- false;
    		is_immune <- false;
    		is_dead <- true;
    	}
    	
    }
//    Reflex to kill the agent according to the probability of dying
//    reflex shallDie when: !is_dead and is_infected and flip(nu) {
//    	//Create another agent
//		create species(self)  {
//			target <- myself.target ;
//			location <- myself.location ;
//			is_infected <- false;
//			is_susceptible <- true;
//			is_immune <- false;
//			self.is_dead <- true;
//			 
//		}
//       	do die;
//    }
	
	
	
	
	aspect base {
		draw circle(10) color: color border: #fuchsia;
	}
}



// Costruzione interfaccia grafica
experiment main_experiment type:gui{
	parameter "Number of people agents" var: nb_people category: "People" ;
	parameter "Earliest hour to start work" var: min_work_start category: "People" min: 2 max: 8;
    parameter "Latest hour to start work" var: max_work_start category: "People" min: 8 max: 12;
    parameter "Earliest hour to end work" var: min_work_end category: "People" min: 12 max: 16;
    parameter "Latest hour to end work" var: max_work_end category: "People" min: 16 max: 23;
    parameter "minimal speed" var: min_speed category: "People" min: 0.1 #km/#h ;
    parameter "maximal speed" var: max_speed category: "People" max: 5 #km/#h;
    parameter "Number of people agents" var: nb_people category: "People" ;
	parameter "Number of Susceptible" var: number_S ;// The number of susceptible
    parameter "Number of Infected" var: number_I ;	// The number of infected
    parameter "Number of Resistant" var:number_R ;	// The number of removed
	parameter "Beta (S->I)" var:beta; 	// The parameter Beta
	parameter "Mortality" var:nu ;	// The parameter Nu
	parameter "Delta (I->R)" var: delta; // The parameter Delta
	
    output {
    	layout #split;
    display map {
    	species building aspect: base; 
        species road aspect:geom; 
        species people aspect: base;      
    }
    
    display chart_people refresh: every(10#cycles) {
			chart "People" type: series background: #lightgray style: exploded {
				data "infectedp" value: people count (each.is_infected) color: #red;
				data "immunep" value: people count (each.is_immune) color: #blue;
			}
		}
		
	display chart_building refresh: every(10#cycles) {
		chart "Buildings" type: series background: #lightgray style: exploded {
			data "infectedb" value: building count (each.n_inf > 0) color: #red;
			
			}
		}
    }
}
    
    





