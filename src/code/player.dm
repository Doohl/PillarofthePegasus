var
	generating = 0

mob/player
	var
		view = INTERSTELLAR_VIEW

	Login()
		..()
		loc = locate(40,40,1)
		Init()


	proc/Init()
		// Padding all around the screen to catch void tiles should they appear (thanks to Kaiochao for writing this)
		client.screen += new /atom/movable {
			name = ""
			layer = -1.#INF
			mouse_opacity = 2
			screen_loc = "SOUTHWEST to NORTHEAST"
		}

		// Initialize the HUD object
		HUD = new()
		HUD.master = client

		// Draw the main HUD frame
		for(var/i = 1, i <= 8, i++)
			var/obj/hud/GameFrame/frame = new()
			if(i == 1)
				frame.icon = new/icon('UI.dmi', "hud_frame", EAST)
				frame.screen_loc = "WEST,SOUTH+1 to WEST,NORTH-1"
			else if(i == 2)
				frame.icon = new/icon('UI.dmi', "hud_frame", WEST)
				frame.screen_loc = "EAST,SOUTH+1 to EAST,NORTH-1"
			else if(i == 3)
				frame.icon = new/icon('UI.dmi', "hud_frame", SOUTH)
				frame.screen_loc = "WEST+1,NORTH to EAST-1,NORTH"
			else if(i == 4)
				frame.icon = new/icon('UI.dmi', "hud_frame", NORTH)
				frame.screen_loc = "WEST+1,SOUTH to EAST-1,SOUTH"
			else if(i == 5)
				frame.icon = new/icon('UI.dmi', "hud_frame", NORTHEAST)
				frame.screen_loc = "WEST,SOUTH"
			else if(i == 6)
				frame.icon = new/icon('UI.dmi', "hud_frame", SOUTHEAST)
				frame.screen_loc = "WEST,NORTH"
			else if(i == 7)
				frame.icon = new/icon('UI.dmi', "hud_frame", NORTHWEST)
				frame.screen_loc = "EAST,SOUTH"
			else if(i == 8)
				frame.icon = new/icon('UI.dmi', "hud_frame", SOUTHWEST)
				frame.screen_loc = "EAST,NORTH"
			client.screen += frame
			HUD.hud_objects.Add(frame)

		TitleScreen()

	verb/Show()

		world << "Race: [GenRaceName()]"
		world << "Name: [GenRandName(rand(2,7))]"

	proc/StartGame()
		if(generating) return
		generating = 1

		new/obj/hud/Space_BG(HUD)

		Meta.GenerateStars(35)
		var/obj/S = Meta.GenerateStart()
		S.icon_state = "star_sel"
		loc = S.loc

		for(var/obj/hud/Window/W in HUD.windows)
			W.Close()
		for(var/obj/hud/Title_BG/T in HUD.hud_objects)
			client.screen -= T
			del(T)