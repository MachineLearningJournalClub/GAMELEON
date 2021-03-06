/**
* Name: MultiAgentCovid_19
* Based on the internal empty template. 
* Author: Simone Azeglio, Matteo Fordiani
* Tags: 
*/

// Per caricare file GIS 
model load_shape_file 
 
global {
	// Global Variables 
	float step <- 60 #mn;
	date starting_date <- date("2020-01-22-00-00-00");	
	int nb_people <- 100; //33312;
	int min_work_start <- 6;
	int max_work_start <- 9;
	int min_work_end <- 16; 
	int max_work_end <- 20; 
	float min_speed <- 1.0 #km / #h;
	float max_speed <- 5.0 #km / #h; 
	
	float staying_coeff update: 10.0 ^ (1 + min([abs(current_date.hour - 9), abs(current_date.hour - 12), abs(current_date.hour - 18)]));
	
	
	// Environment  ------------------------------------------------------------------------
	// Roads, buildings shapefiles import 
    file roads_shapefile <- file("C:/Users/simon/Desktop/MAS/Data/Traffic/Filtered_1st_neigh/2019-04-01-Toronto.shp");
    file buildings_shapefile <- file("C:/Users/simon/Desktop/MAS/Data/Buildings/buildings_shp/height_buildings_1st_neigh.shp");
     
    
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
	     
	    
	    
	    
		 
		    
    
	    create people number:nb_people {
	        speed <- rnd(min_speed, max_speed);
	        
			start_work <- rnd (min_work_start, max_work_start);
			end_work <- rnd(min_work_end, max_work_end);
			
			living_place <- one_of(residential_buildings) ;  
			working_place <- one_of(employement_buildings) ;
			objective <- "resting";
			
			location <- any_location_in(living_place); 
	        
	        }
	    }
	}
// Edifici nella città di Toronto

species building {
    string type; 
    rgb color <- #gray  ;
    
    aspect base {
    draw shape color: color ;
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
	
    rgb color <- #fuchsia ;
    
    building living_place <- nil ;
    building working_place <- nil ;
     
	
	int start_work ;
	int end_work  ;
	string objective ; 
	point target <- nil;
 
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

    output {
    display map {
    	species building aspect: base; 
        species road aspect:geom; 
        species people aspect: base;      
    }
    }
}



