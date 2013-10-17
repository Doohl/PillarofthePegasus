var/Metaworld/Meta = new()

/* Main Metaworld Datum
	- Handles all logic in the game both within player perspective and outside
	- Logic is handled in Process()
*/

Metaworld

	// Global logic data containers/trackers
	var
		// Geographical containers:
		list/stars = list()		// all stars in the galaxy
		list/planets = list()	// all planets in the galaxy

		// Structural and organizational containers:
		list/entities = list()  // all groups (or, entities) in the galaxy
		list/relations = list() // relationship datums in the galaxy
								// accounts for entity/entity relationships, as well as entity/religion
		list/battles = list()	// all battles in the galaxy currently happening
		list/battle_rep = list()// all battles that have taken place in the galaxy

		// Miscellaneous containers:
		list/units = list()		// all units/ships in the galaxy
		list/task_forces = list()// all stask forces in the galaxy

		// Time values
		current_time			// the current time from 0 in days.
		last_time				// the last time that was process()'d.

		// ID containers
		list/star_const = list()// associative container for stars
		max_constellations = 10 // 10 max constellations
		constel_count = 0		// current constellation count

		// Settings
		AI_normal = 50			// 50% of AI will be normal
		AI_hostile = 10			// 10% of AI will be hostile and evil
		AI_random = 40			// 30% of AI will be completely random
		AI_Races = 10			// How many aliums to generate
		Start_fighter = 20		// starts with 20 fighters
		Start_corvette = 5		// starts with 5 corvettes
		Start_frigate = 3		// starts with 3 frigates
		Start_destroyer = 2		// starts with 2 destroyers
		Start_battlecruiser = 1 // starts with 1 battlecruisers

		// Other datums for player reference
		Race/Humans				// humans of the Ohr-Confederate Stars
		Unit/Ship/Mothership/Mothership
		list/discovered_stars = list()		// stars discovered by the humans
		list/discovered_races = list()		// list of discovered races

	// Initialize values that need to be initilaized
	New()
		..()

	/* Process(dt) handles all game/metaworld logic.
		- dt dictates the delta time, how much time to increment this 'turn'
		- The time iteration will be interrupted if noteworthy events happen, giving the player a chance to respond.
	*/
	proc/Process(dt)
		..()

	/* Generate the human race and fleet */

	proc/GenerateStart()
		Humans = new()
		Humans.name = "Human"
		Humans.bio_base = CARBON_BASE
		Humans.mechanic_limbs = 2
		Humans.movement_limbs = 2
		Humans.ears = 2
		Humans.eyes = 2
		Humans.sensors = (SEES|HEARS|SMELLS|TASTES)
		Humans.personality = new() // use all of the default parameter values; see race.dm Personality class constructor method
		Humans.government = THEOCRACY
		Humans.government_props = (THEO_TOTAL|INDOCTRINATE)
		Humans.leader_spots = 1
		Humans.leader_title = "Vindicator"
		Humans.religion = "The Prophecy of the Ohr"
		Humans.breath_intake = list(/Substance/Nitrogen = 0.7, /Substance/Oxygen = 0.3)
		Humans.breath_outtake = list(/Substance/CarbonDioxide = 0.9, /Substance/Nitrogen = 0.1)
		Humans.poison = list(/Substance/CarbonMonoxide, /Substance/HydrogenSulfide)
		Humans.memory = list("Log" = {"
										Back on Earth it is the year 3225, we left for the Pegasus Galaxy on the year 3215. The
										intergalactic journey has taken us 15 years, but we have finally made it. We have come upon
										this unblessed cesspool of all that is unrighteous, and we are here to take it under the
										name of the Ascended Ones. May they guide us to purity in this new frontier, and allow our
										sacrifices to not have been for naught.
									"})

		// Populate the human fleet
		var/list/mothership_fleet = list()
		for(var/i = 1, i <= Start_fighter, i++)
			var/Unit/Ship/Fighter/F = new()
			F.Owner = Humans
			F.GenName()
			F.Outfit(2)
			mothership_fleet.Add(F)
		for(var/i = 1, i <= Start_corvette, i++)
			var/Unit/Ship/Corvette/F = new()
			F.Owner = Humans
			F.GenName()
			F.Outfit(2)
			mothership_fleet.Add(F)
		for(var/i = 1, i <= Start_frigate, i++)
			var/Unit/Ship/Frigate/F = new()
			F.Owner = Humans
			F.GenName()
			F.Outfit(2)
			mothership_fleet.Add(F)
		for(var/i = 1, i <= Start_destroyer, i++)
			var/Unit/Ship/Destroyer/F = new()
			F.Owner = Humans
			F.GenName()
			F.Outfit(2)
			mothership_fleet.Add(F)
		for(var/i = 1, i <= Start_battlecruiser, i++)
			var/Unit/Ship/Battlecruiser/F = new()
			F.Owner = Humans
			F.GenName()
			F.Outfit(2)
			mothership_fleet.Add(F)

		Mothership = new()
		Mothership.name = "Pillar of the Pegasus"
		Mothership.Owner = Humans
		Mothership.Outfit(2)
		mothership_fleet.Add(Mothership)

		// Select a star
		var/obj/Star/selected
		var/Metaflag/flag = GetFlag(round(world.maxx / 2), round(world.maxy / 2), 1)

		for(var/i = 1, i <= 15, i++)
			for(var/obj/Star/S in range(i, flag))
				if(!S.metastar.has_homeworld)
					selected = S
			if(selected) break

		flag.Release()

		// Construct the task force
		var/TaskForce/T = new(mothership_fleet, Humans, selected.metastar, "Mothership Fleet")
		Humans.task_forces.Add(T)
		selected.metastar.tasks.Add(T)
		selected.metastar.PosInit(T)

		// Look for the proper spot to place the task force
		flag = GetFlag(round(world.maxx / 2), round(world.maxy / 2))
		var/Metaflag/flag2 = GetFlag( pick(getring(flag, selected.metastar.jump_orbit)) ) // get a random position at the jump orbital

		selected.metastar.Posx(T, flag2.x)
		selected.metastar.Posy(T, flag2.y)

		// Get rid of the temporary flags
		flag.Release()
		flag2.Release()

		return selected

	/* Generate a random star in the galaxy */
	proc/GenerateStars(starcount)
		// Generate constellations
		for(var/x in constellations)
			star_const[x] = greek_alphabet + greek_alphabet_rare

		var/rand_intensity = round(starcount/3)
		var/x_halfpoint = round(world.maxx / 2)
		var/y_halfpoint = round(world.maxy / 2)

		// Generate the stars
		for(var/i = 1, i <= starcount-AI_Races, i++)
			var/Star/S = new()
			S.Init(rand_intensity, x_halfpoint, y_halfpoint)
			stars.Add(S)

		for(var/i = 1, i <= AI_Races, i++)
			var/Star/S = new()
			S.has_homeworld = 1
			S.Init(rand_intensity, x_halfpoint, y_halfpoint)
			stars.Add(S)

		// Assign star values that are relative and associated with neighboring stars
		for(var/Star/S in stars)
			GenerateNeighbors(S)	// construct the jumps list
			GenerateNames(S)		// construct the name string; neighboring stars share constellations


	proc/GenerateNeighbors(Star/S)
		for(var/i = 1, i <= 7, i++)
			if(S.jumps.len >= 4) break
			for(var/obj/Star/st in range(i, S.physical))
				if(st.metastar != S)
					if(S.jumps.len >= 4) break
					if(st.metastar.jumps.len >= 4) continue
					if(!(st.metastar in S.jumps) && !(S in st.metastar.jumps))
						if(DrawLine(S.physical, st))
							S.jumps.Add(st.metastar)
							st.metastar.jumps.Add(S)

	proc/GenerateNames(Star/S)
		if(S.constellation) return
		var/constellation = pick(constellations)
		constellations -= constellation

		if(prob(85))
			for(var/i = 1, i <= 3, i++)
				for(var/obj/Star/st in range(i, S.physical) | S.jumps)
					var/Star/Star = st.metastar
					if(Star.constellation) continue
					Star.constellation = constellation
					var/list/available = star_const[Star.constellation]
					Star.pre_id = available[1]
					available.Remove(Star.pre_id)
					star_const[Star.constellation] = available

					Star.name = "[Star.pre_id] [Star.constellation] System"

		else
			S.constellation = constellation
			S.name = "[S.constellation] System"






