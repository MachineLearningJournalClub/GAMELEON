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
// Number of susceptible host at init
	int number_S <- 0;
	//Number of infected host at init
	int number_I <- 30;
	//Number of resistant host at init
	int number_R <- 0;
	//Rate for the infection success 
	float beta <- 0.1; // andare da 0.001 a 0.1 tipo 0.001 --> 0.005 --> 0.010 --> 0.020 --> 0.030 --> 0.040 --> 0.050 --> 0.060... 0.1 0.11
	//Modifier for the baseline prob
	float beta_baseline <- 0.0;
	//Mortality rate for the host
	float nu <- 0.6;
	//Rate for resistance 
	float delta <- 0.95;
	// Time for curfew;
	bool curfew <- false;
	int curfew_time <- 22;
	int curfew_delay <- 10;
	// main lockdown var
	bool lockdown <- false;
	// accessory lockdown vars
	//TODO: qui i dati sulle caratteristiche del lockdown https://cmajnews.com/2020/06/12/coronavirus-1095847/
	bool lockschools <- false;
	bool lockcommercial <- false;
	bool lockoffices <- false;
	bool lockchurches <- false;
	float lockfrequency <- 0.15;
	//Mean time for recovery;
	int mean_recovery <- 14 * 24; // la aggiustiamo a 0, 7, 14.
	int variance_recovery <- 7 * 24; // la aggiustiamo a 0, 3, 7.
	int min_hosp_time <- 10 * 24;
	//Number total of hosts <- sostituisco in number of people
	// int numberHosts <- number_S+number_I+number_R;
	float step <- 60 #mn;
	date starting_date <- date("2020-01-22-00-00-00");
	int nb_people <- number_S + number_I + number_R;
	int min_work_start <- 6;
	int max_work_start <- 9;
	int min_work_end <- 16;
	int max_work_end <- 20;
	int min_worship_start <- 8;
	int max_worship_start <- 20;
	float min_speed <- 15.0 #km / #h;
	float max_speed <- 50.0 #km / #h;
	float staying_coeff update: current_date.day_of_week > 5 ? 10.0 ^ (1 + min([abs(current_date.hour - 9), abs(current_date.hour - 12), abs(current_date.hour - 18)])) : 10.0 ^
	(1 + 10 * min([abs(current_date.hour - 9), abs(current_date.hour - 12), abs(current_date.hour - 18)]));


	// Environment  ------------------------------------------------------------------------
	// Roads, buildings shapefiles import 
	file roads_shapefile <- file("D:/MultiAgentCovid/Data/Traffic/Filtered_1st_neigh/2019-04-01-Toronto.shp");
	file buildings_shapefile <- file("D:/MultiAgentCovid/Data/Buildings/buildings_shp/height_buildings_1st_neigh.shp");
	file churches_shapefile <- file("D:/MultiAgentCovid/Data/Buildings/buildings_shp/Churches_Toronto.shp");

	// Instantiating Road Network 
	geometry shape <- envelope(roads_shapefile);
	graph road_network;

	// int n_inf
	// reflex globale che fa ask buildings e somma gli n_inf
	init {
	//create building from: buildings_shapefile; ----------------------------------------------------
		create building from: buildings_shapefile with: [type:: string(read("ZN_ZONE_EX"))] {
		// Residential buildings are split up in the following categories:
			if type = "Residential" or type = "Residential Detached" or type = "Residential Apartment" or type = "Residential Multiple Dwelling" or type = "Residential Apartment Commercial"
			or type = "Residential Semi Detached" or type = "Residential Townhouse" {
				color <- #blue;
				is_residential <- true;
			} else if type = "Residential" or type = "Residential Apartment" or type = "Residential Multiple Dwelling" or type = "Residential Apartment Commercial" {
				color <- #aqua;
				is_toobig <- true;
			} else if type = "Employment Industrial" or type = "Employment Light Industrial" or type = "Employment Heavy Industrial" or type = "Employment Industrial Office" or
			type = "Employment Industrial Commercial" {
				color <- #green;
			} else if type = "Commercial Residential Employment" or type = "Commercial Local" or type = "Commercial Residential" {
				color <- #lime;
			} else if type = "Open Space" or type = "Open Space Recreation" or type = "Open Space Natural" {
				color <- #yellow;
			} else if type = "Institutional School" or type = "Institutional Education" {
				color <- #orange;
			} else if type = "Institutional Place of Worship" {
				color <- #maroon;
			} else if type = "Institutional General" {
				color <- #aqua;
			} else if type = "Institutional Hospital" {
				color <- #red;
			} }

		create building from: churches_shapefile {
			type <- "Institutional Place of Worship";
			color <- #maroon;
		}

		list<building> residential_buildings <- building where (each.type = "Residential" or each.type = "Residential Detached" or each.type = "Residential Apartment" or
		each.type = "Residential Multiple Dwelling" or each.type = "Residential Apartment Commercial" or each.type = "Residential Semi Detached" or
		each.type = "Residential Townhouse");
		list<building> employement_buildings <- building where (each.type = "Employment Industrial" or each.type = "Employment Light Industrial" or
		each.type = "Employment Heavy Industrial" or each.type = "Employment Industrial Office" or each.type = "Employment Industrial Commercial");
		list<building> commercial_buildings <- building where (each.type = "Commercial Residential Employment" or each.type = "Commercial Local" or
		each.type = "Commercial Residential");
		list<building> open_space_buildings <- building where (each.type = "Open Space" or each.type = "Open Space Recreation" or each.type = "Open Space Natural");
		list<building> education_buildings <- building where (each.type = "Institutional School" or each.type = "Institutional Education");
		list<building> worship_buildings <- building where (each.type = "Institutional Place of Worship");
		list<building> government_buildings <- building where (each.type = "Institutional General");
		list<building> hospital_buildings <- building where (each.type = "Institutional Hospital");

		// Weighted road network 
		create road from: roads_shapefile with: [weight::float(read("weight"))];
		map<road, float> weights_map <- road as_map (each::each.weight);
		//write weights_map;  // check - it works! 
		road_network <- as_edge_graph(road) with_weights weights_map;

		// Create ADULTS
		create people number: int(number_S * 0.70) {
			recovery_time <- gauss(mean_recovery, variance_recovery);
			speed <- rnd(min_speed, max_speed);
			adult <- true;
			start_work <- rnd(min_work_start, max_work_start);
			end_work <- rnd(min_work_end, max_work_end);
			start_worship <- rnd(min_worship_start, max_worship_start);
			end_worship <- start_worship + 1;
			worship_place <- one_of(worship_buildings);
			living_place <- one_of(residential_buildings);
			working_place <- one_of(employement_buildings + commercial_buildings + hospital_buildings + government_buildings + education_buildings);
			stuff_place_1 <- one_of(commercial_buildings + open_space_buildings);
			stuff_place_2 <- one_of(commercial_buildings + open_space_buildings);
			objective <- "resting";
			location <- any_location_in(living_place);
			is_susceptible <- true;
			is_infected <- false;
			is_immune <- false;
			color <- #green;
		}

		create people number: int(number_S * 0.15) {
			recovery_time <- gauss(mean_recovery, variance_recovery);
			speed <- rnd(min_speed, max_speed);
			senior <- true;
			dismission_time <- 30 * 24;
			stuff_place_1 <- one_of(commercial_buildings + open_space_buildings);
			stuff_place_2 <- one_of(commercial_buildings + open_space_buildings);
			start_work <- rnd(9, 12);
			end_work <- rnd(15, 18);
			start_worship <- rnd(min_worship_start, max_worship_start);
			end_worship <- start_worship + 1;
			worship_place <- one_of(worship_buildings);
			living_place <- one_of(residential_buildings);
			objective <- "resting";
			location <- any_location_in(living_place);
			is_susceptible <- true;
			is_infected <- false;
			is_immune <- false;
			color <- #green;
		}

		create people number: int(number_S * 0.15) {
			recovery_time <- gauss(mean_recovery, variance_recovery);
			speed <- rnd(min_speed, max_speed);
			juvenile <- true;
			stuff_place_1 <- one_of(commercial_buildings + open_space_buildings);
			stuff_place_2 <- one_of(commercial_buildings + open_space_buildings);
			school <- one_of(education_buildings);
			start_worship <- rnd(min_worship_start, max_worship_start);
			end_worship <- start_worship + 1;
			worship_place <- one_of(worship_buildings);
			start_work <- 9;
			end_work <- 16;
			living_place <- one_of(residential_buildings);
			working_place <- one_of(employement_buildings);
			objective <- "resting";
			location <- any_location_in(living_place);
			is_susceptible <- true;
			is_infected <- false;
			is_immune <- false;
			color <- #green;
		}

		create people number: number_I {
			recovery_time <- gauss(mean_recovery, variance_recovery);
			if (flip(0.8)) {
				adult <- true;
			} else if (flip(0.1)) {
				juvenile <- true;
			} else {
				senior <- true;
			}

			speed <- rnd(min_speed, max_speed);
			start_work <- rnd(min_work_start, max_work_start);
			end_work <- rnd(min_work_end, max_work_end);
			start_worship <- rnd(min_worship_start, max_worship_start);
			end_worship <- start_worship + 1;
			worship_place <- one_of(worship_buildings);
			living_place <- one_of(residential_buildings);
			working_place <- one_of(employement_buildings + commercial_buildings + hospital_buildings + government_buildings + education_buildings);
			objective <- "resting";
			location <- any_location_in(living_place);
			is_susceptible <- false;
			is_infected <- true;
			is_immune <- false;
			color <- #red;
		}

		create people number: number_R {
			recovery_time <- gauss(mean_recovery, variance_recovery);
			speed <- rnd(min_speed, max_speed);
			start_work <- rnd(min_work_start, max_work_start);
			end_work <- rnd(min_work_end, max_work_end);
			start_worship <- rnd(min_worship_start, max_worship_start);
			end_worship <- start_worship + 1;
			worship_place <- one_of(worship_buildings);
			living_place <- one_of(residential_buildings);
			working_place <- one_of(employement_buildings);
			objective <- "resting";
			location <- any_location_in(living_place);
			living_place <- one_of(residential_buildings);
			location <- any_location_in(living_place);
			is_susceptible <- false;
			is_infected <- false;
			is_immune <- true;
			color <- #fuchsia;
		} } }

species building {
	string type;
	bool is_residential <- false;
	bool is_toobig <- false;
	rgb color <- #gray;
	float infection_time;
	list<people> inhabitants;
	list<people> people_in_building update: people inside self; // ci serve per controllare se e` dentro al building in quello step
	list<list<people>> families; // suddividiamo in gruppetti persone che hanno lo stesso living_place a init
	list<list<people>> groups; // suddividiamo in gruppetti persone che hanno lo stesso working_place a init
	int n_inf <- 0 update: self.people_in_building count (each.is_infected and !each.is_dead and !each.is_hospitalized); //and !each.is_dead and !each.is_hospitalized);
	int n_tot <- 0 update: length(self.people_in_building);

	aspect base {
		draw shape color: color;
	}

	//  Save buildings location, run once 


	action group {
		loop person over: people {
			if (person.working_place = self or person.worship_place = self or person.stuff_place_1 = self or person.stuff_place_2 = self or person.school = self) {
				add person to: self.inhabitants;
			}

		}

		people personlink <- nil;
		int index1 <- 0;
		loop while: (index1 < length(inhabitants) - 1) {
			int a <- rnd(2, 7);
			list<people> group <- nil;
			if (personlink != nil) {
				add personlink to: group;
				personlink <- nil;
			}

			loop index2 from: index1 to: index1 + a - 1 step: 1 {
				if (length(inhabitants) - 1 >= index1 + index2) {
					add self.inhabitants[index1 + index2] to: group;
					if (flip(0.1)) {
						personlink <- self.inhabitants[index1 + index2];
					}

				}

			}

			index1 <- index1 + a;
			add group to: self.groups;
		}

	}
	action families {
		loop person over: people {
			if (person.living_place = self) {
				add person to: self.inhabitants;
			}

		}

		int index1 <- 0;
		loop while: (index1 < length(inhabitants) - 1) {
			int a <- rnd(1, 8);
			list<people> family <- nil;
			loop index2 from: index1 to: index1 + a - 1 step: 1 {
				if (length(inhabitants) - 1 >= index1 + index2) {
					add self.inhabitants[index1 + index2] to: family;
				}

			}

			index1 <- index1 + a;
			add family to: self.families;
		}

	}

	reflex group when: !is_residential and cycle = 1 {
		do group();
	}

	reflex families when: is_residential and cycle = 1 {
		do families();
	}

	
	reflex infect_families when: (is_residential and time > 1.0 and n_inf > 0 and current_date.hour = 0) {
		loop index from: 0 to: length(families) - 1 step: 1 {
			loop indexg from: 0 to: length(families[index]) - 1 step: 1 {
				if (families[index][indexg].is_infected and people_in_building contains families[index][indexg]) {
					loop indexf from: 0 to: length(families[index]) - 1 step: 1 {
						if (families[index][indexf].is_susceptible and people_in_building contains families[index][indexf] and flip(beta * 1.25)) {
							//TODO: in versione finale deve essere 1.25
							families[index][indexf].is_infected <- true;
							families[index][indexf].is_susceptible <- false;
							families[index][indexf].is_immune <- false;
							families[index][indexf].infection_time <- time;
						}

					}

				}

			}

		}

	}

	reflex infect when: !is_residential {
		loop index from: 0 to: length(groups) - 1 step: 1 {
			loop indexg from: 0 to: length(groups[index]) - 1 step: 1 {
				if (groups[index][indexg].is_infected and groups[index][indexg].can_infect and people_in_building contains groups[index][indexg]) {
					groups[index][indexg].can_infect <- false;
					loop indexf from: 0 to: length(groups[index]) - 1 step: 1 {
						if (groups[index][indexf].is_susceptible and people_in_building contains groups[index][indexf] and flip(beta)) {
							groups[index][indexf].is_infected <- true;
							groups[index][indexf].is_susceptible <- false;
							groups[index][indexf].is_immune <- false;
							groups[index][indexf].infection_time <- time;
						}

					}

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
//ToDo -> Implementare groups e classes per buildings e schools
//Creare view e variabili a lato piu` carine
//Implementare headless
species people skills: [moving] {
// Aspect
	rgb color <- #fuchsia;

	// Movement
	float speed;
	int staying_counter;
	bool is_locked <- false;

	// Age
	bool adult <- false; // 18-60
	bool senior <- false; // 60+
	bool juvenile <- false; // 6-18

	// Faith
	bool believer <- flip(0.3);

	// Locations
	building living_place <- nil;
	building working_place <- nil;
	building school <- nil;
	building worship_place <- nil;
	building stuff_place_1 <- nil;
	building stuff_place_2 <- nil;

	// Epidemiological Times
	float recovery_time;
	float infection_time;
	float hospitalization_time;

	// Schedule times
	int start_worship;
	int end_worship;
	int start_work;
	int end_work;
	string objective;
	point target <- nil;
	int dismission_time <- 14 * 24;

	// Booleans to represent the state of the host agent
	bool is_susceptible <- false;
	bool is_infected <- false;
	bool is_immune <- false;
	bool can_infect <- true;
	// Booleans to restrict movement and immunization
	bool is_dead <- false;
	bool is_hospitalized <- false;
	bool can_recover <- true;

	// Qua si possono metter diversi reflex in base a quali posti
	// vogliamo far visitare all'agente: chiesa, parco... con orari precisi o 
	// probabilità associata all'azione in base all'ora / giorno 
//	reflex initialize_data when: cycle = 1 {
//		save "@" to: "results/people/" + self.name + ".txt" type: csv rewrite: false;
//		save "@" + string(beta) to: "results/people/" + self.name + ".txt" type: csv rewrite: false;
//		save "@" + string(working_place) + " / " + string(living_place) to: "results/people/" + self.name + ".txt" type: csv rewrite: false;
//	}
	reflex lock when: curfew and cycle = curfew_delay*24 {
		if (flip(lockfrequency)) {
			is_locked <- true;
		}
	}
	reflex write_data when: current_date.hour = 0 {
		save [cycle, string(beta), string(working_place), string(living_place), self.is_infected, self.is_immune, self.is_dead] to: "results/people/" + self.name + ".txt" type: csv rewrite: false;
	}
	

	reflex time_to_work when: !is_locked and !is_dead and !is_hospitalized and adult and current_date.hour >= start_work and objective = "resting" {
		objective <- "working";
		target <- any_location_in(working_place);
	}

	reflex refresh_infection when: current_date.hour = 1 or current_date.hour = 13 {
		can_infect <- true;
	}

	reflex time_to_study when: !lockschools and !is_dead and !is_hospitalized and juvenile and current_date.hour >= start_work and objective = "resting" {
		objective <- "working";
		target <- any_location_in(school);
	}

	reflex time_to_go_home when: (current_date.hour >= end_work or (curfew and (current_date.hour >= curfew_time or current_date.hour <= 6))) and (objective = "working" or senior) {
		objective <- "resting";
		target <- any_location_in(living_place);
	}

	reflex time_to_go_worship when: !lockchurches and (senior or believer) and current_date.day_of_week = 7 and current_date.hour >= 10 and objective = "resting" {
		objective <- "resting";
		target <- any_location_in(worship_place);
	}

	reflex staying when: target = nil and objective != "working" {
		staying_counter <- staying_counter + 1;
		if (!curfew) {
			if flip(staying_counter / staying_coeff) {
				target <- !is_locked ? any_location_in(one_of(stuff_place_1, stuff_place_2)) : any_location_in(stuff_place_1);
			}
		} else if (current_date.hour >= curfew_time  or current_date.hour <= 6) {
			target <- any_location_in(living_place);
			objective <- "resting";
		}

	}
	
	
	reflex when: curfew and (current_date.hour >= curfew_time or current_date.hour <= 6) {
		target <- any_location_in(living_place);
		objective <- "resting";
	}

	// Importante, in questo modo salviamo i cammini di ogni agente!!
	// sarebbe bene impostare abitudini (ad esempio, stesso posto per andare a lavoro 
	// e stessa casa) 	
	reflex move when: !is_dead and !is_hospitalized and target != nil {
		path path_to_store <- goto(target: target, on: road_network, return_path: true);
		//write path_to_store; // check - it works! 
		if (location = target) {
			target <- nil;
			staying_counter <- 0;
		} }

		//Reflex to make the agent recovered if it is infected and if it success the probability
	reflex become_immune when: is_infected and ((time - infection_time) > (recovery_time) * 3600) {
		if (can_recover and flip(delta)) {
			is_susceptible <- false;
			is_infected <- false;
			is_hospitalized <- false;
			is_immune <- true;
			can_recover <- false;
		} else {
			if ((time - infection_time) < min_hosp_time * 3600) {
				can_recover <- false;
			} else {
				is_hospitalized <- true;
				is_infected <- true;
				is_immune <- false;
				can_recover <- false;
				hospitalization_time <- time;
			}

		}

	}

	reflex dismissed when: is_hospitalized and ((time - hospitalization_time) > dismission_time * 3600) {
		if (flip(1 - nu)) {
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

	aspect base {
		draw triangle(10) color: color border: #fuchsia;
	} }

	// Costruzione interfaccia grafica
experiment main_experiment type: gui {
	parameter "Number of people agents" var: nb_people category: "People";
	parameter "Number of Susceptible" var: number_S; // The number of susceptible
	parameter "Number of Infected" var: number_I; // The number of infected
	parameter "Number of Resistant" var: number_R; // The number of removed
	parameter "Beta (S->I)" var: beta; // The parameter Beta
	parameter "Beta Baseline (S->I)" var: beta_baseline; // The baseline modifier for beta ground noise
	parameter "Mortality (I->D)" var: nu; // The parameter Nu
	parameter "Delta (I->R)" var: delta; // The parameter Delta
	parameter "Mean Recovery Time (hours)" var: mean_recovery; // The mean recovery
	parameter "Variance Recovery Time (hours)" var: variance_recovery; // The varianceof recovery
	parameter "Curfew time" var: curfew_time;
	parameter "Curfew?" var: curfew;
	parameter "Lockdown?" var: lockdown;
	parameter "Earliest hour to start work" var: min_work_start category: "People" min: 2 max: 8;
	parameter "Latest hour to start work" var: max_work_start category: "People" min: 8 max: 12;
	parameter "Earliest hour to end work" var: min_work_end category: "People" min: 12 max: 16;
	parameter "Latest hour to end work" var: max_work_end category: "People" min: 16 max: 23;
	parameter "minimal speed" var: min_speed category: "People" min: 0.1 #km / #h;
	parameter "maximal speed" var: max_speed category: "People" max: 5 #km / #h;
	output {
		layout #split;
		display map {
			species building aspect: base;
			species road aspect: geom;
			species people aspect: base;
		}

		display chart_people refresh: every(1 #cycles) {
			chart "People" type: series background: #lightgray style: exploded {
				data "infectedp" value: people count (each.is_infected) color: #red;
				data "immunep" value: people count (each.is_immune) color: #blue;
				data "deadp" value: people count (each.is_dead) color: #purple;
				data "hospitalizedp" value: people count (each.is_hospitalized) color: #green;
			}

		}

		display chart_building refresh: every(10 #cycles) {
			chart "Buildings" type: series background: #lightgray style: exploded {
				data "infectedb" value: building count (each.n_inf > 0) color: #red;
			}

		}

		display chart_age_groups refresh: every(10 #cycles) {
			chart "People" type: series background: #lightgray style: exploded {
				data "infecteda" value: people count (each.is_infected and each.adult) color: #red;
				data "infecteds" value: people count (each.is_infected and each.senior) color: #blue;
				data "infectedj" value: people count (each.is_infected and each.juvenile) color: #purple;
			}

		}

		display chart_building_types refresh: every(1 #cycles) {
			chart "Buildings" type: series background: #lightgray style: exploded {
				data "infectedresidential" value: building count (each.n_inf > 0 and (each.type = "Residential" or each.type = "Residential Detached" or each.type = "Residential Apartment"
				or each.type = "Residential Multiple Dwelling" or each.type = "Residential Apartment Commercial" or each.type = "Residential Semi Detached" or
				each.type = "Residential Townhouse")) color: #blue;
				data "infectedemployment" value: building count (each.n_inf > 0 and (each.type = "Employment Industrial" or each.type = "Employment Light Industrial" or
				each.type = "Employment Heavy Industrial" or each.type = "Employment Industrial Office" or each.type = "Employment Industrial Commercial")) color: #green;
				data "infectedopen" value: building count (each.n_inf > 0 and (each.type = "Open Space" or each.type = "Open Space Recreation" or each.type = "Open Space Natural")) color:
				#yellow;
				data "infectedhospital" value: building count (each.n_inf > 0 and (each.type = "Institutional Hospital")) color: #red;
				data "infectedchurch" value: building count (each.n_inf > 0 and each.type = "Institutional Place of Worship") color: #maroon;
				data "infectedschool" value: building count (each.n_inf > 0 and (each.type = "Institutional School" or each.type = "Institutional Education")) color: #orange;
				data "infectedcommercial" value: building count (each.n_inf > 0 and (each.type = "Commercial Residential Employment" or each.type = "Commercial Local" or
				each.type = "Commercial Residential")) color: #lime;
			}

		}

	}

}

experiment tuning_batch repeat: 30 type: batch until: cycle > 120*24 keep_seed: true {
	parameter 'Infection Probability' var: beta among: [0.001, 0.005, 0.01, 0.02, 0.03, 0.04, 0.05];
	//TODO: curfew dev'essere false!!
}
    
    





