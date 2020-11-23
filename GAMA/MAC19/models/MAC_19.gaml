/**
* Name: NewModel
* Based on the internal empty template. 
* Author: simon
* Tags: 
*/

// Per caricare file GIS 
model load_shape_file 
 
global {
	
	// Environment  ------------------------------------------------------------------------
	// Roads, buildings shapefiles import 
    file roads_shapefile <- file("C:/Users/simon/Desktop/MAS/Data/Traffic/Filtered_1st_neigh/2019-04-01-Toronto.shp");
    file buildings_shapefile <- file("C:/Users/simon/Desktop/MAS/Data/Buildings/buildings_shp/height_buildings_1st_neigh.shp");
     
    
    // Instantiating Road Network 
    geometry shape <- envelope(roads_shapefile);
    graph road_network;
    
    
    // People  ------------------------------------------------------------------------
    // Step temporale e numero di persone
    int nb_people <- 33312;
    //int nb_infected_init <- 5;
    float step <- 5 #mn;
  
    init {
	    //create building from: buildings_shapefile;
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
		
    
    
    
	    create road from: roads_shapefile;
	    road_network <- as_edge_graph(road);
		 
		    
    
	    create people number:nb_people {
	        location <- any_location_in(one_of(building));
	        
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

// Strade di Torino 
species road {
    aspect geom {
    draw shape color: #black;
    }
}



// Persone
species people {
    rgb color <- #fuchsia ;
    
    aspect base {
    draw circle(1) color: color border: #fuchsia;
    }
}


// Costruzione interfaccia grafica
experiment main_experiment type:gui{
	parameter "Number of people agents" var: nb_people category: "People" ;

    output {
    display map {
    	species building aspect: base; 
    	//species hospitals aspect: base;
        species road aspect:geom; 
        species people aspect: base;      
    }
    }
}

/* Insert your model definition here */
