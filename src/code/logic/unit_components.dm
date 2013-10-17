Component
	var
		name = "Component X"
		desc = "This component does electronic and mechanical shit."
		size = 0		// the size of the component in tons
		crew_cost = 0	// the amount of crew needed to operate the component
		crew = 0		// crew assigned to this component
		damage = 0		// damage is directly related to size. larger weapons = more durable.

		Unit/Parent		// the parent unit that this component is installed on

		// Special variables
		EM_reading = 0	// the electromagnetic output of this component
		Bio_reading = 0	// the biological output of this component
		tech_level = 0	// the tech level of this component, starting from 1
						// humans start off with Tech 5

		type_req		// the requirement of installation for this component

	proc/CalcPenalty()
		..()

	Targetting
		name = "Targetting Enhancement System"
		desc = "A module which enhances the accuracy of all non-turret-based weaponry by 5%. Maximum of two allowed."
		EM_reading = 1
		tech_level = 5
		crew_cost = 25
		size = 30

		CalcPenalty()
			return lerp(0.1, 5, crew/crew_cost)

	EMTargetting
		name = "EM Targetting System"
		desc = "A module which enhances weaponsfire accuracy by the EM signature of targetted units."
		EM_reading = 1.5
		tech_level = 2
		size = 50
		crew_cost = 30
		Fighter
			name = "Fighter EM Targetting System"
			desc = "An EM Targetting System which can only be outfitted onto fighter craft."
			size = 5
			crew_cost = 1
			EM_reading = 0.3
			type_req = /Unit/Ship/Fighter

	Shields
		name = "Shielding System"
		desc = "A shielding mechanism to protect a ship from all forms of conventional weaponry."
		EM_reading = 1.5
		tech_level = 3
		var
			damage_reduction = 0.25	// amount of damage to reduce
			failure_chance = 5		// chance of failure

		Fighter
			name = "Fighter Shielding System"
			desc = "A compact, simple shield system designed for a fighter craft."
			size = 5
			crew_cost = 1
			damage_reduction = 0.3
			EM_reading = 0.5
		Omicron
			name = "Omicron-Alpha Shielding System"
			desc = "A shielding module which uses a strong electromagnetic pulse to protect a ship."
			size = 30
			crew = 2
			EM_reading = 0.6
		Omicron2
			name = "Omicron-Beta Shielding System"
			desc = "A shielding module which uses a strong electromagnetic pulse to protect a ship."
			size = 60
			crew = 35
			EM_reading = 0.7
			damage_reduction = 0.4
			tech_level = 4
		Phaser
			name = "Phaser Shielding System"
			desc = "An event horizon generator which can displace incoming ordnance and weapons fire."
			size = 100
			crew = 60
			EM_reading = 0.9
			damage_reduction = 0.5
			tech_level = 5
			failure_chance = 10
		Proton
			name = "Proton-Stream Shielding System"
			desc = "A compact shield generator which encompasses a ship in a superconductive proton sheet."
			size = 70
			crew = 100
			EM_reading = 1.5
			damage_reduction = 0.6
			tech_level = 5
			failure_chance = 15
		Quantum
			name = "Displacement Shield System"
			desc = "A quantum displacement shield generator that translates all incoming particles into harmless energy."
			size = 300
			crew = 150
			EM_reading = 2
			damage_reduction = 0.7
			tech_level = 8
			failure_chance = 20
		Omega
			name = "Omega shield System"
			desc = "A super-advanced shield system that identifies incoming threats and atomizes them."
			size = 500
			crew = 300
			EM_reading = 3.5
			damage_reduction = 0.9
			tech_level = 10
			failure_chance = 25

	Crew
		name = "Crew Accomodations"
		desc = "A module which increases the ability for a ship to initiate more crew."
		// crew_cost here actually dictates how much crew capacity is added

		Tiny
			name = "Fighter Cockpit"
			crew_cost = 5
			size = 5
		Small
			name = "Small Compartment"
			crew_cost = 30
			size = 15
		Medium
			name = "Medium Compartment"
			crew_cost = 100
			size = 50
		Large
			name = "Large Compartment"
			crew_cost = 250
			size = 125
		Mothership
			name = "Mothership Compartment"
			crew_cost = 5000
			size = 2500



	Weapon
		var
			damage_power = 0	// how much damage to inflict
			shots_per_turn = 0	// the amount of shots per turn
			accuracy = 0		// the probablity of hitting

			charge = 0			// shots_per_turn added to charge every combat turn, if > 1, fire (accounts for > 1 shots_per_turn)

		/* Guass weapons
			- Standard kinetic weapon, fires at a pretty normal rate of fire.
			- Incredibly high damage on higher models, but much lower accuracy.
		*/
		Gauss
			name = "Gauss Cannon"
			desc = "A cannon which fires simple kinetic ordnance, propulsion powered by a series of magnetic coils."
			tech_level = 1
			shots_per_turn = 1
			accuracy = 75
			Small
				// 2 damage, 3 shots per turn, 2 crew	(6 DPT)
				name = "Small Gauss Cannon"
				size = 10
				damage_power = 2
				shots_per_turn = 3
				crew_cost = 2
				EM_reading = 0.05
				accuracy = 50
			Medium
				// 30 damage, 2 shot per turn, 15 crew	(30 DPT)
				name = "Medium Gauss Cannon"
				size = 30
				damage_power = 15
				shots_per_turn = 2
				crew_cost = 15
				EM_reading = 0.1
				accuracy = 60
				tech_level = 2
			Large
				// 50 damage, 1 shot per turn, 30 crew	(50 DPT)
				name = "Large Gauss Cannon"
				size = 50
				damage_power = 50
				crew_cost = 30
				EM_reading = 0.5
				accuracy = 70
				tech_level = 3
			Huge
				// 300 damage, 1 shot per ~3 turns, 50 crew	(132 DPT)
				name = "Huge Gauss Cannon"
				size = 300
				damage_power = 400
				shots_per_turn = 0.33
				crew_cost = 50
				EM_reading = 1
				accuracy = 85
				tech_level = 5

		/* Plasma Weapons
			- They fire fast and hard, but are incredibly unaccurate and have high EM output.
			- Small, but requires more crewpower.
			- Faster fire rate = less chance to hit overall, but higher shield penetration
		*/
		Plasma
			name = "Plasma Cannon"
			desc = "A fast-firing, compact energy weapon powered by conventional phaser crystals."
			tech_level = 3
			shots_per_turn = 5
			accuracy = 50
			Small
				// 1.5 damage, 10 shots per turn (15 DPT)
				name = "Small Plasma Cannon"
				size = 5
				damage_power = 1.5
				shots_per_turn = 10
				crew_cost = 2
				EM_reading = 0.1
			Medium
				// 4 damage, 10 shots per turn (50 DPT)
				name = "Small Plasma Cannon"
				size = 25
				damage_power = 5
				shots_per_turn = 10
				crew_cost = 20
				EM_reading = 0.5
				accuracy = 35
			Large
				// 25 damage, 4 shots per turn (100 DPT)
				name = "Small Plasma Cannon"
				size = 40
				damage_power = 25
				shots_per_turn = 4
				crew_cost = 40
				EM_reading = 2
				accuracy = 20


		Turret
			name = "Turret"
			desc = "A portable installment which can be mounted with any weapon, highly accurate."
			size = 3
			tech_level = 3
			crew_cost = 0
			EM_reading = 0.5 // turrets give off very high EM readings, combines with the mount EM
			New(Component/Weapon/Mount)
				..()
				if(istype(Mount)) Mount = new Mount

				name = "[Mount.name] (Turret)"
				desc += " Mounted with a [Mount.name]."

				tech_level += Mount.tech_level
				EM_reading += Mount.EM_reading
				Bio_reading += Mount.Bio_reading
				shots_per_turn = Mount.shots_per_turn
				damage_power = round(Mount.damage_power/1.2, 1)
				accuracy = round(lerp(95, Mount.accuracy, 0.5), 1)
				size += Mount.size

