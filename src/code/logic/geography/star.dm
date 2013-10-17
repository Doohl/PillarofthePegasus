/* Star Class
	- Stars are the parent organizer of planets and stellar bodies
	- Acts as a spatial organizer for all units/planets/bodies within this star system
*/

Star
	var
		name = "Star X"

		// Star-specific values
		color					// the color of the star, directly relates to the color of the star object in map view
		surface_temp			// the surface temperature of the star in Kelvin
		class					// the Morgan-Keenan spectral classification of the star
		x; y					// galactic/interstellar view coordinates
		obj/physical			// the physical star assigned to metastar
		obj/stellar_phys		// the physical star in stellar space

		constellation			// constellation name
		pre_id					// greek alphabet ID

		has_homeworld			// the planet has a homeworld

		jump_orbit				// the orbital distance in which ships jump into the system

		// Star system containers
		list/tasks = list() 	// all the current task forces in this star system
		list/planets = list() 	// all of the planets in the star system
		list/jumps = list()		// neighboring stars which can be jumped to from this star
		list/lines = list()		// lines associated with this star
		list/locs = list()		// associative container; index is any datum, value is "x,y" position

		list/orbits = list()	// available orbits for this star

	// Set a new x value for something in this star system (or get the x value)
	proc/Posx(unit, newx)
		var/data = locs[unit]
		if(!data)
			return null

		if(newx == null)
			var/x = copytext(data,1,findtext(data,",",1,0))
			return text2num(x)
		else
			var/y = copytext(data,findtext(data,",",1,0)+1,0)
			data = "[newx],[y]"
			locs[unit] = data

	// Set a new y value for something in this star system (or get the y value)
	proc/Posy(unit, newy)
		var/data = locs[unit]
		if(!data)
			return null

		if(newy == null)
			var/y = copytext(data,findtext(data,",",1,0)+1,0)
			return text2num(y)
		else
			var/x = copytext(data,1,findtext(data,",",1,0))
			data = "[x],[newy]"
			locs[unit] = data

	// Sets the unit's position to -1,-1
	proc/PosInit(unit)
		locs[unit] = "-1,-1"

	// Initialize the star and randomly generate it
	proc/Init(rand_intensity, x_halfpoint, y_halfpoint, gen_physical = 1)
		// Pick the star class
		if(!has_homeworld || prob(25))
			class = pick(15; "M", 25; "K", 20; "G", 10; "F", 20; "A", 5; "B", 5;"O")
		else
			class = pick(15; "M", 25; "K", 20; "G", 15; "F", 20; "A", 5; "B")

		for(var/i = 3, i <= 25, i++)
			orbits.Add(i)

		jump_orbit = pick(3, 4, 5, 6, 7)

		// Begin assigning colors and temperatures based off the class selected.
		switch(class)
			if("O")
				surface_temp = rand(33000, 50000)
				var/intensity = rand(200, 255) // the white intensity of the star
				color = rgb(rand(0,150), intensity, 255)
			if("B")
				surface_temp = rand(10000, 30000)
				var/intensity = rand(200, 240)
				color = rgb(intensity, intensity, rand(200,225))
			if("A")
				surface_temp = rand(7000, 10000)
				var/intensity = rand(190, 240)
				color = rgb(intensity, intensity, rand(100,230))
			if("F")
				surface_temp = rand(6000, 7000)
				var/intensity = rand(240, 255)
				color = rgb(intensity, intensity, intensity)
			if("G")
				surface_temp = rand(5200, 6000)
				var/intensity = rand(240, 250)
				color = rgb(intensity, intensity, rand(100,230))
			if("K")
				surface_temp = rand(3700, 5200)
				var/intensity = rand(150, 230)
				color = rgb(intensity, intensity-rand(15, 70), rand(15, 30))
			if("M")
				surface_temp = rand(2000, 3700)
				var/intensity = rand(200, 250)
				color = rgb(intensity, rand(15, 30), rand(15, 30))

		// Generate the physical star object
		if(gen_physical)
			var/obj/Star/S = new()
			S.loc = locate(x_halfpoint+min(x_halfpoint,rand(-rand_intensity, rand_intensity)), y_halfpoint+min(y_halfpoint,rand(-rand_intensity, rand_intensity)), 1)
			S.color = color
			S.metastar = src
			physical = S

			while(1)
				var/found = 0
				for(var/obj/Star/s in range(0, S))
					if(s != S) found = 1
				if(!found) break
				else
					S.loc = locate(x_halfpoint+min(x_halfpoint,rand(-rand_intensity, rand_intensity)), y_halfpoint+min(y_halfpoint,rand(-rand_intensity, rand_intensity)), 1)

		// Begin generating some planets
		var/planet_amt = 0
		if(has_homeworld)
			planet_amt = 1
		planet_amt += rand(0, 12)

		// Iterate through desired planet amount and add populate them if necessary
		for(var/i = 1, i <= planet_amt, i++)
			var/Planet/P = new()
			P.name = "Planet [i]"
			P.Star = src

			if(has_homeworld && i == 1)

				// Space the planets out by star class
				var/dist = 0
				switch(class)
					if("M") dist = 4
					if("K") dist = 5
					if("G") dist = 6
					if("F") dist = 7
					if("A") dist = 8
					if("B") dist = 10
					if("O") dist = 13
				orbits.Remove(dist)
				P.orbital_dist = dist

				// Assign the planet's position as pending, waiting to be generated
				PosInit(P)

				var/Race/R = new()
				R.Init()
				P.atmosphere = R.breath_intake
				P.occupying_race = R
				P.races[R] = 100 // total control
				R.planets.Add(P)

			else
				var/dist = pick(orbits)
				P.orbital_dist = dist
				orbits.Remove(dist)

				// Assign the planet's position as pending, waiting to be generated
				PosInit(P)

			// Finally, intialize the planet
			P.Init(homeworld = (has_homeworld && i == 1))
			planets.Add(P)


	/* Path to the designed star (Breadth-first search) */
	proc/Pathfind(Star/Trg)
		var/list/checked = list()   //keep track of where we've been already
		var/list/checking = list()  //where we still need to check
		var/list/lastnode = list()  //keep track of how we got to each node
		var/list/path  				//used for the final return

		var/Star/cur  				//the currently being checked node

		checking += src //seed the list with our start value
		checked[src] = 1

		while(checking.len) //keep checking as long as we have places to go
			cur = checking[1]
			checking -= cur

			if(cur==Trg)
				//reconstruct the path
				path = list()
				while(cur!=src)
					path.Insert(1,cur)
					cur = lastnode[cur]
				return path

			for(var/Star/n in cur.jumps) //check all neighbors
				if(!checked[n]) //if it's a fresh link
					checking += n
					checked[n] = 1
					lastnode[n] = cur

		return null


/* Star object Class
	- The 'fake' star representation of the 'real' Star metadata
	- Virtual interaction with the object reflect datum information
	- Appears in both the interstellar and stellar view
*/

mob/player
	var/obj/Star/selected_star
	var/obj/hud/Window/StarWindow

obj/Star
	icon = 'interstellar.dmi'
	icon_state = "star"
	bound_x = 8
	bound_y = 9
	bound_width = 16
	bound_height = 16
	layer = OBJ_LAYER + 1
	var
		Star/metastar				// the metadata star that is linked to this object
		view = INTERSTELLAR_VIEW	// dictates which level of view this star is in

	proc/Deselect(mob/player/trg)
		trg.selected_star = null
		trg.StarWindow = null
		for(var/Line/L in metastar.lines)
			for(var/obj/LineSeg/_L in L.segments)
				_L.icon_state = "path_idle"

	Click(location, control, params)
		..()

		if(params2list(params)["right"] && usr:selected_star)
			var/list/path = list()
			path = usr:selected_star.metastar.Pathfind(metastar)
			path.Add(usr:selected_star.metastar)

			for(var/Star/S in path)
				for(var/Line/L in S.lines)
					var/correct_line = 1
					for(var/obj/Star/_S in L.atoms)
						if(!(_S.metastar in path))
							correct_line = 0
							break

					if(correct_line)
						for(var/obj/LineSeg/_L in L.segments)
							_L.icon_state = "path_sel"

			return

		if(usr:StarWindow && usr:StarWindow.hook == src) return // we already clicked this star

		// Deselect the old star and its paths and select the new one
		if(usr:selected_star)
			for(var/Line/L in usr:selected_star.metastar.lines)
				for(var/obj/LineSeg/_L in L.segments)
					_L.icon_state = "path_idle"
			//usr:selected_star.icon_state = "star"
		usr:selected_star = src
		//icon_state = "star_sel"
		for(var/Line/L in metastar.lines)
			for(var/obj/LineSeg/_L in L.segments)
				_L.icon_state = "path"

		// Close the old window
		if(usr:StarWindow)
			var/obj/hud/Window/OldWindow = usr:StarWindow
			spawn()
				OldWindow.Close()
				del(OldWindow)

		/* Draw the new window */
		usr.client.MousePosition(params)
		var/m_x = usr.client.mouse_x + 45
		var/m_y = usr.client.mouse_y + 60
		var/tx = round(m_x / 32)
		var/ty = round(m_y / 32)
		var/px = m_x % 32
		var/py = m_y % 32

		var/obj/hud/Window/Window = new(usr:HUD, 6, 4, header = "[metastar.name]", s_loc = list(tx, px, ty, py), call_src = src, call_trg = usr, call_proc = /obj/Star/proc/Deselect)
		usr:StarWindow = Window
		Window.hook = src

		// 15-px delta
		Window.DrawText("#66CC00", "#666600", 8, (Window.height*32)-25, Window.width*32, "Star Classification:")
		Window.DrawText("#56BC80", "#107438", 23, (Window.height*32)-25, Window.width*32, "<span align=\"right\">Class [metastar.class]</span>")
		Window.DrawText("#66CC00", "#666600", 8, (Window.height*32)-40, Window.width*32, "Surface Temp:")
		Window.DrawText("#56BC80", "#107438", 23, (Window.height*32)-40, Window.width*32, "<span align=\"right\">[metastar.surface_temp] K</span>")
		Window.DrawText("#66CC00", "#666600", 8, (Window.height*32)-55, Window.width*32, "Planets:")
		Window.DrawText("#56BC80", "#107438", 23, (Window.height*32)-55, Window.width*32, "<span align=\"right\">[metastar.planets.len]</span>")
		Window.DrawText("#66CC00", "#666600", 8, (Window.height*32)-70, Window.width*32, "Ships:")
		var/self_ships = 0
		var/neutral_ships = 0
		var/enemy_ships = 0
		for(var/TaskForce/T in metastar.tasks)
			for(var/Unit/Ship/S in T.ships)
				if(S.Owner == Meta.Humans) self_ships++
				else neutral_ships++

		Window.DrawTextAdv("<span align=\"right\"><font color=#7B7BFF>[self_ships]<font color=#66CC00>|<font color=#C71010>[enemy_ships]<font color=#66CC00>|<font color=#56BC80>[neutral_ships]",
						"<span align=\"right\"><font color=#030387>[self_ships]<font color=#666600>|<font color=#470000>[enemy_ships]<font color=#666600>|<font color=#107438>[neutral_ships]"
						, 23, (Window.height*32)-70, Window.width*32)

		// Draw divider
		Window.DrawDivVert(15, (Window.height*32)-105, Window.width)

		// Draw the stellar view button
		if(usr:view == INTERSTELLAR_VIEW)
			Window.DrawText("#66CC00", "#666600", (Window.width*16)-55, (Window.height*32)-130, Window.width*32, "View System")
			var/obj/hud/Button/Stellar/S = new(Window)
			S.layer = FLOAT_LAYER
			S.pixel_y = (Window.height*32)-135
			S.pixel_x = 130
			S.Star = metastar
			Window.overlays += S
		// Draw the interstellar view button
		else
			Window.DrawText("#66CC00", "#666600", (Window.width*16)-60, (Window.height*32)-130, Window.width*32, "Interstellar Map")
			var/obj/hud/Button/Interstellar/S = new(Window)
			S.layer = FLOAT_LAYER
			S.pixel_y = (Window.height*32)-135
			S.pixel_x = 140
			S.Star = metastar
			Window.overlays += S

		// Fade the window in
		Window.FadeIn()

		for(var/Planet/x in metastar.planets)
			for(var/Race/R in x.races)
				world << R.name
