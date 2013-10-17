/* Unit class
	- Units are objects that can travel between stars and between planets within star systems
	- Characterized by velocity and position
*/

Unit
	var
		name = "Unit X"
		desc = "This is a stationary object in space of unknown origin."

		vel_x = 0		// x-axis velocity of the unit per day
		vel_y = 0		// y-axis velocity of the unit per day
		x; y			// the current location of the unit

		Race/Owner		// the race that owns this unit
		Star/Starloc	// the star that this unit is currently in

		integrity = 0	// the physical integrity of the unit (HP)
		durability = 0	// the maximum integrity of the unit (Max HP)

		dodge = 0		// the amount to reduce the accuracy calcs on this ship
		shield_reduce = 0 // the amount of damage reduction to divide per shield on the ship

		speed = 1		// how many stellar tiles this unit can move per turn


/* Ship Unit class
	- Ships have components and integrity stats. If integrity reaches 0, the ship's dead.
	- Ships are 'powered' by crewmembers unless they use entirely autonomous functions.
*/

Unit/Ship
	name = "Ship X"
	desc = "This is a ship of unknown origin."
	var
		list/loadout = list()		// the components the ship is currently outfitted with
		size = 0					// the maximum loadout size (in tons)
		class = "Ship"

		color

	New()
		..()
		integrity = durability

	// Outfit the ship with weaponry based on type (1 = random, 2 = default)
	proc/Outfit(type = 1)
		..()

	proc/GenName()
		var/n = ""
		for(var/i = 1, i <= 4, i++)
			if(prob(65))
				n += "[rand(0,9)]"
			else
				n += uppertext(pick(consonants+vowels))

		name = replacetext(name, "X", n)

	Fighter
		name = "Fighter X"
		class = "Fighter"
		desc = "A small, fast vessel designed for recon, strategic incursion, or general combat use."
		size = 30	// 30 ton max
		durability = 30
		speed = 4
		color = "#485F08"
		Outfit(type = 1)
			loadout.Add(new/Component/Crew/Tiny)
			if(type == 2)

				// Default Loadout: 30 tons ; 5 crew
				loadout.Add(new/Component/Crew/Tiny)
				loadout.Add(new/Component/Weapon/Gauss/Small)
				loadout.Add(new/Component/Weapon/Gauss/Small)
				loadout.Add(new/Component/EMTargetting/Fighter)
	Corvette
		name = "Corvette X"
		class = "Corvette"
		desc = "A relatively-small and maneuverable ship."
		size = 100  // 100 ton max
		durability = 150
		speed = 2
		color = "#407F00"
	Frigate
		name = "Frigate X"
		class = "Frigate"
		desc = "A general, all-purpose spacecraft designed both combat and noncombat use."
		size = 500	// 500 ton max
		durability = 200
		speed = 1
		color = "#109F10"
	Destroyer
		name = "Destroyer X"
		class = "Destroyer"
		desc = "A heavy-duty ship designed for support and large weapons battery installations."
		size = 800	// 800 ton max
		durability = 300
		color = "#00BF00"
	Battlecruiser
		name = "Battlecruiser X"
		class = "Battlecruiser"
		desc = "An extremely heavy ship fitted for the largest of combat scenarios."
		size = 1000 // 1000 ton max
		durability = 400
		color = "#33FF00"
	Mothership
		name = "Mothership"
		class = "Mothership"
		desc = "The pride of the Ohr, the Pillar of the Pegasus."
		size = 10000 // 10,000 ton max
		durability = 1000
		color = "#FFFF00"


/* Task Force datum
	- Controls subgroups of units traveling together as a fleet
*/
TaskForce
	var
		name = "Taskforce X"

		list/ships = list()		// all ships within this task force
		Race/Race				// the race this task force belongs to
		Star/Star				// the star this task force is in

		heading_to				// the thing that this task force is heading to

		obj/Fleet/physical		// the physical fleet representation

	New(list/L, Race, Star, name)
		..()
		src.ships.Add(L)
		src.Race = Race
		src.Star = Star
		src.name = name

mob/player/var
	list/FleetWindows = list()
	list/ShipWindows = list()


obj/Fleet
	icon = 'Stellar.dmi'
	icon_state = "fleet"
	var
		fleet_type = "fleet"
		TaskForce/metaforce		// the taskforce this object is assigned to

	Click(location, control, params)

		for(var/obj/hud/Window/W in usr:FleetWindows)
			if(W.hook == src) return

		/* Draw the new window */
		usr.client.MousePosition(params)
		var/m_x = usr.client.mouse_x + 45
		var/m_y = usr.client.mouse_y + 60
		var/tx = round(m_x / 32)
		var/ty = round(m_y / 32)
		var/px = m_x % 32
		var/py = m_y % 32

		var/obj/hud/Window/Window = new(usr:HUD, 7, 4, header = "[metaforce.name]")
		Window.screen_loc = "[tx]:[px],[ty]:[py]"
		Window.del_close = 1

		usr:FleetWindows.Add(Window)
		Window.hook = src

		// 15-px delta
		Window.DrawText("#66CC00", "#666600", 8, (Window.height*32)-25, Window.width*32, "Race:")
		Window.DrawText("#56BC80", "#107438", 23, (Window.height*32)-25, Window.width*32, "<span align=\"right\">[metaforce.Race]</span>")
		Window.DrawText("#66CC00", "#666600", 8, (Window.height*32)-40, Window.width*32, "Ships:")
		Window.DrawText("#56BC80", "#107438", 23, (Window.height*32)-40, Window.width*32, "<span align=\"right\">[length(metaforce.ships)]</span>")
		Window.DrawText("#66CC00", "#666600", 8, (Window.height*32)-60, Window.width*32, "<span align=\"center\">Moving To: \[\]</span>")

		Window.DrawDivVert(15, (Window.height*32)-90, Window.width)

		var/sx = 5
		var/sy = (Window.height*32)-110
		var/w = 8
		var/h = 8
		var/last_type
		for(var/Unit/Ship/S in ship_bubble_sort(metaforce.ships))
			var/obj/hud/Button/Ship/O = new(Window)
			if(!last_type)
				last_type = S.type
			else if(last_type != S.type)
				last_type = S.type
				sy -= h
				sx = 5

			O.icon = icon
			O.bound_width = 7
			O.bound_height = 7
			O.color = S.color
			O.icon_state = "ship_raw"
			O.pixel_x = sx+12
			O.pixel_y = sy+12
			O.layer = FLOAT_LAYER
			O.Ship = S

			Window.overlays += O

			sx += w
			if(sx > (Window.width*32)-w)
				sy -= h
				sx = 5

		// Fade the window in
		Window.FadeIn()


obj/hud/Button/Ship
	var
		Unit/Ship/Ship


	Click(location, control, params)

		for(var/obj/hud/Window/W in usr:ShipWindows)
			if(W.hook == src) return

		/* Draw the new window */
		usr.client.MousePosition(params)
		var/m_x = usr.client.mouse_x + 45
		var/m_y = usr.client.mouse_y + 60
		var/tx = round(m_x / 32)
		var/ty = round(m_y / 32)
		var/px = m_x % 32
		var/py = m_y % 32

		var/obj/hud/Window/Window = new(usr:HUD, 6, 4, header = "[Ship.name]")
		Window.screen_loc = "[tx]:[px],[ty]:[py]"
		Window.del_close = 1

		usr:ShipWindows.Add(Window)
		Window.hook = src

		Window.DrawText("#66CC00", "#666600", 8, (Window.height*32)-25, Window.width*32, "Race:")
		Window.DrawText("#56BC80", "#107438", 23, (Window.height*32)-25, Window.width*32, "<span align=\"right\">[Ship.Owner]</span>")
		Window.DrawText("#66CC00", "#666600", 8, (Window.height*32)-40, Window.width*32, "Ship Class:")
		Window.DrawText("#56BC80", "#107438", 23, (Window.height*32)-40, Window.width*32, "<span align=\"right\">[Ship.class]</span>")
		Window.DrawText("#66CC00", "#666600", 8, (Window.height*32)-55, Window.width*32, "Size:")
		Window.DrawText("#56BC80", "#107438", 23, (Window.height*32)-55, Window.width*32, "<span align=\"right\">[Ship.size] tons</span>")
		Window.DrawText("#66CC00", "#666600", 8, (Window.height*32)-75, Window.width*32, "<span align=\"center\">Structural Integrity:</span>")

		// Draw HP/Integrity
		var/bx = (Window.width*16)-((Window.width-2)*16)+13
		var/by = (Window.height*32)-115
		var/obj/hud/Bar/IntegriBar/B = new(Window, Window.width-2, bx, by)
		B.hook = Ship
		var/obj/hud/BarLeft = new()
		BarLeft.layer = FLOAT_LAYER
		BarLeft.icon_state = "left_bar"
		BarLeft.pixel_x = bx-32
		BarLeft.pixel_y = by
		Window.overlays += BarLeft
		var/obj/hud/BarRight = new()
		BarRight.layer = FLOAT_LAYER
		BarRight.icon_state = "right_bar"
		BarRight.pixel_x = (bx+(32*(Window.width-2)))
		BarRight.pixel_y = by
		Window.overlays += BarRight

		B.Draw(Ship.durability, Ship.integrity)

		// Fade the window in
		Window.FadeIn()


proc/ship_bubble_sort(list/sorted)
	sorted = sorted.Copy()
	for(var/index = sorted.len; index >= 1; index--)
		for(var/item = 1; item < index; item++)
			var/Unit/Ship/this = sorted[item]
			var/Unit/Ship/next = sorted[item+1]
			if(this.size < next.size)
				sorted.Swap(item, item+1)
	return sorted

