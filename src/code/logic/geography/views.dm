mob/player/proc/StellarView(Star/Trg)
	if(view == STELLAR_VIEW) return
	view = STELLAR_VIEW

	if(world.maxz < 2) world.maxz = 2

	var/obj/flag = new(locate(round(world.maxx / 2), round(world.maxy / 2), 2))
	for(var/obj/O in oview(30, flag))
		del(O)

	var/obj/Star/S = new(flag.loc)
	S.icon = 'star.dmi'
	S.icon_state = ""
	S.pixel_x = -16
	S.pixel_y = -16
	S.icon += Trg.color
	S.metastar = Trg
	Trg.stellar_phys = S

	for(var/obj/hud/Space_BG/B in HUD.hud_objects)
		animate(B, alpha=220, time = 8)


	// Load all of the star objects
	var/list/planets = list()
	for(var/Planet/P in Trg.locs)
		P.physical = new()
		P.physical.metaplanet = P
		if(P.occupying_race) P.physical.icon_state = "homeworld"
		if(Trg.Posx(P) == -1 || Trg.Posy(P) == -1)
			P.physical.loc = pick(getring(Trg.stellar_phys, P.orbital_dist))
			P.physical.dir = get_dir_adv(P.physical, S)
			Trg.Posx(P, P.physical.x)
			Trg.Posy(P, P.physical.y)
		else
			P.physical.loc = locate(Trg.Posx(P), Trg.Posy(P), 2)
			P.physical.dir = get_dir_adv(P.physical, S)

		if(P.diameter >= 30000)
			P.physical.icon_state = "planet_large"

		planets.Add(P)

	// Load all the task forces
	for(var/TaskForce/T in Trg.locs)
		T.physical = new()
		T.physical.metaforce = T
		if(Meta.Mothership in T.ships)
			T.physical.icon_state = "mothership"
			T.physical.fleet_type = "mothership"

		if(T.Race == Meta.Humans)
			T.physical.color += "#3399FF"

		T.physical.loc = locate(Trg.Posx(T), Trg.Posy(T), 2)

	var/list/planet_huds = planet_bubble_sort(planets)
	var/pos = round(planet_huds.len/2)
	for(var/Planet/P in planet_huds)

		var/obj/PlanetHUD/H = new()
		H.icon_state = P.physical.icon_state
		H.metaplanet = P

		H.screen_loc = "CENTER+[pos],SOUTH+1"
		client.screen += H

		pos --

	// Install the star margin
	new/obj/hud/StellarMargin(HUD)

	step_x = 0
	step_y = 0

	loc = flag.loc

mob/player/proc/InterstellarView(Star/Trg)
	if(view == INTERSTELLAR_VIEW) return
	view = INTERSTELLAR_VIEW

	//for(var/Planet/

	for(var/obj/hud/StellarMargin/M in HUD.hud_objects)
		M.Close()

	for(var/obj/PlanetHUD/P in client.screen)
		client.screen -= P

	for(var/obj/hud/Space_BG/B in HUD.hud_objects)
		animate(B, alpha=130, time = 8)

	step_x = 0
	step_y = 0
	loc = Trg.physical.loc