Personality
	var
		// Values from 1-10
		conquer				// 1 = wants to conquer everything, 10 = does not
		niceness			// 1 = absolutely evil, relationships easily decline, 10 = saints, forgiving
		predictability		// 1 = deviates from personality a lot, 10 = never does
		xenophobia			// 1 = no xenophobia at all, 10 = violently afraid or bothered by other races
		cooperation			// 1 = will never cooperate, 10 = will cooperate 100% if interests are shared
		cowardice			// 1 = will never retreat or show weakness, 10 = does not do anything dangerous
		aggressivity		// 1 = combat will always be a last resort, 10 = combat will be the first option
		religion			// 1 = does not care about religion at all, 10 = religion is extremely important

	// Default constructor values for personalities are what is considered 'human' or 'normal'
	New(conquer = 5, niceness = 7, predictability = 8, xenophobia = 3, cooperation = 9, cowardice = 5, aggressivity = 4, religion = 10)
		..()
		src.conquer = conquer
		src.niceness = niceness
		src.predictability = predictability
		src.xenophobia = xenophobia
		src.cooperation = cooperation
		src.cowardice = cowardice
		src.aggressivity = aggressivity
		src.religion = religion

Race
	var
		name = "Race X"

		// Biological traits
		bio_base = CARBON_BASE			// the base element this race uses
		mechanic_limbs					// total number of mechanical limbs
		movement_limbs					// total number of movement-related limbs

		sensors = 0						// bitfield describing the types of biological sensory apparatus
		eyes							// total number of eyes
		ears							// total number of ears

		skin							// skin color

		list/breath_intake = list()		// the things that this race must breathe in
		list/poison	= list()			// substances that are extremely poisonous to this race
		list/breath_outtake = list()	// the things that this race breathes out

		// Other organizational traits and values
		Personality/personality			// personality of the race as a whole
		government						// the type of government ruling the race
		government_props = 0			// bitfield describing government in further details
		list/government_leaders = list()// people who lead the government
		leader_spots					// number of leader spots
		leader_title					// the name of the leader title in the race
		list/relationships = list()		// relationships with other races; Race as index, value as 1-100

		list/planets = list() 			// planets which this race is currently inhabiting

		religion						// the current race's primary religion
		list/memory = list()			// associative container for the race's memory. string indexes and values
		list/task_forces = list()		// all task forces belonging to this race

	// Initialize and generate the race
	proc/Init()
		name = GenRaceName()

		// Construct biological variables
		mechanic_limbs = pick(60; 2, 10; 1, 10;3, 10; 4, 10; 0)
		if(prob(70)) // symmetry is preferred
			movement_limbs = mechanic_limbs
		else
			movement_limbs = pick(60; 2, 10; 1, 10;3, 10; 4, 10; 0)

		bio_base = pick(80; CARBON_BASE, 15; ARSENIC_BASE, 5; SILICON_BASE)
		if(bio_base != SILICON_BASE)
			if(prob(75)) sensors |= SEES
			if(prob(75)) sensors |= HEARS
			if(prob(75)) sensors |= SMELLS
			if(prob(75)) sensors |= TASTES
			if(prob(5)) sensors |= EM_SENSES
			if(prob(5)) sensors |= BIO_SENSES
			if(!sensors) sensors |= pick(SEES, HEARS, SMELLS)
			skin = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
		else
			sensors |= SEES
			if(prob(50)) sensors |= HEARS
			if(prob(20)) sensors |= SMELLS
			if(prob(75)) sensors |= EM_SENSES
			if(prob(75)) sensors |= BIO_SENSES

			if(prob(60)) // 60% chance of having grey (metal) skin
				var/intensity = rand(0, 255)
				skin = rgb(intensity, intensity, intensity)
			else
				skin = rgb(rand(0, 255), rand(0, 255), rand(0, 255))

		if(sensors & SEES)
			eyes = pick(60; 2, 20; 1, 10;3, 5; 4, 5; 5)
		if(sensors & HEARS)
			ears = pick(60; 2, 20; 1, 10;3, 5; 4, 5; 5)

		// Decide breath composite if nonsilicon
		if(bio_base != SILICON_BASE)

			var/list/t = list()
			for(var/i = 1, i <= rand(2,5), i++)
				var/Substance/possible
				if(bio_base == CARBON_BASE)
					possible = pick(carbon_okay)
				if(bio_base == ARSENIC_BASE)
					possible = pick(arsenic_okay)

				if(!(possible in t))
					t[possible] = rand(20, 100)
				else
					i-- // try again asshole
			var/total = 0
			for(var/index in t)
				total += t[index]
			for(var/index in t)
				breath_intake[index] = t[index]/total

			// Decide exhale composite
			t = list()
			for(var/i = 1, i <= rand(1,3), i++)
				var/Substance/possible
				if(bio_base == CARBON_BASE)
					possible = pick(carbon_out)
				if(bio_base == ARSENIC_BASE)
					possible = pick(arsenic_out)

				if(!(possible in t))
					t[possible] = rand(20, 100)
				else
					i-- // try again asshole
			total = 0
			for(var/index in t)
				total += t[index]
			for(var/index in t)
				breath_outtake[index] = t[index]/total

			// Decide poison composite
			for(var/i = 1, i <= rand(1,2), i++)
				var/Substance/possible
				if(bio_base == CARBON_BASE)
					possible = pick(carbon_poison)
				if(bio_base == ARSENIC_BASE)
					possible = pick(arsenic_poison)

				if(!(possible in poison))
					poison.Add(possible)
				else
					i-- // try again asshole

		// Construct personality
		var/type = pick(Meta.AI_normal; "normal", Meta.AI_random; "random", Meta.AI_hostile; "hostile")
		switch(type)
			if("normal")
				personality = new(conquer = rand(3,6), niceness = rand(6,10), predictability = rand(5,9), xenophobia = rand(2,4), cooperation = rand(8,10),
								cowardice = rand(1,10), aggressivity = rand(2,6), religion = rand(1,10))
			if("random")
				personality = new(conquer = rand(1,10), niceness = rand(1,10), predictability = rand(1,10), xenophobia = rand(1,10), cooperation = rand(1,10),
								cowardice = rand(1,10), aggressivity = rand(1,10), religion = rand(1,10))
			if("hostile")
				personality = new(conquer = rand(6,10), niceness = rand(1,4), predictability = rand(5,9), xenophobia = rand(7,10), cooperation = rand(1,5),
								cowardice = rand(1,6), aggressivity = rand(7,10), religion = rand(1,10))

		// Construct the government
		government = pick(MONARCHY, DEMOCRACY, DICTATOR, THEOCRACY)
		switch(government)
			if(MONARCHY)
				government_props |= pick(KING_RULE, QUEEN_RULE)

				var/Individual/I = new(src, rand(1,3))
				if(government_props & QUEEN_RULE)
					I.gender = "female"
					I.title = "Queen"
				else
					I.title = "King"
					I.gender = "male"

				government_leaders.Add(I)
				leader_spots = 1

				if(prob(45)) government_props |= PARLIAMENT
				else
					if(prob(60))
						religion = "The [pick(study_type)] of [I.name]"

				personality.religion = avg(I.personality.conquer, I.personality.religion) // the leader's religion affects everyone else

			if(DICTATOR)
				government_props |= pick(DICT_MALE, DICT_FEMALE)
				if(prob(5)) government_props |= COUNCIL
				if(prob(75)) government_props |= DICT_TOTAL

				var/Individual/I = new(src, rand(1,5))
				I.title = "Dictator"
				if(government_props & DICT_FEMALE)
					I.gender = "female"

				government_leaders.Add(I)
				leader_spots = 1

				personality.religion = avg(I.personality.conquer, I.personality.religion) // the leader's religion affects everyone else

			if(THEOCRACY)
				if(prob(75)) government_props |= CONSERVATIVE
				if(prob(45)) government_props |= THEO_TOTAL
				if(prob(50)) government_props |= INDOCTRINATE

				leader_spots = rand(2,30)
				leader_title = pick("Bishop", "Father", "Leader", "His Holiness", "Elder")
				for(var/i = 1, i <= leader_spots, i++)
					var/Individual/I = new(src, rand(1,5))
					I.title = leader_title
					I.gender = pick("male", "female")
					if(I.gender == "female")
						if(I.title == "Father")
							I.title = "Mother"
						else if(I.title == "His Holiness")
							I.title = "Her Holiness"

					government_leaders.Add(I)

				personality.religion = rand(9,10) // maximum religion

			else
				leader_spots = rand(8, 50)
				leader_title = pick("Senator", "Representative", "Councilman")
				for(var/i = 1, i <= leader_spots, i++)
					var/Individual/I = new(src, rand(1,5))
					I.title = leader_title
					I.gender = pick("male", "female")
					if(I.gender == "female")
						if(I.title == "Councilman")
							I.title = "Councilwoman"

					government_leaders.Add(I)
		..()


Individual
	var
		name = "Person X"
		title = "Senator"
		gender = "male"

		Race/race
		Personality/personality

	New(Race/race, deviation)
		..()
		src.name = GenRandName(rand(2,7))
		src.race = race
		var/Personality/P = race.personality
		var/conquer = clamp(P.conquer+rand(-deviation,deviation), 1, 10)
		var/niceness = clamp(P.niceness+rand(-deviation,deviation), 1, 10)
		var/predictability = clamp(P.predictability+rand(-deviation,deviation), 1, 10)
		var/xenophobia = clamp(P.xenophobia+rand(-deviation,deviation), 1, 10)
		var/cooperation = clamp(P.cooperation+rand(-deviation,deviation), 1, 10)
		var/cowardice = clamp(P.cowardice+rand(-deviation,deviation), 1, 10)
		var/aggressivity = clamp(P.aggressivity+rand(-deviation,deviation), 1, 10)
		var/religion = clamp(P.religion+rand(-deviation,deviation), 1, 10)
		personality = new(conquer, niceness, predictability, xenophobia, cooperation, cowardice, aggressivity, religion)
