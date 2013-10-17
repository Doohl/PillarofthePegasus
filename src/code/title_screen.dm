mob/player/proc
	TitleScreen()
		// Draw the fancy title background
		var/obj/hud/Title_BG/T = new(HUD)

		sleep(5)

		animate(T, alpha = 90, time = 18)

		// Draw the main title screen window
		var/obj/hud/Window/Window = new(HUD, 10, 15, header = TITLE, closebutton = 0)

		// Draw the first text
		Window.DrawText("#66CC00", "#666600", 8, (Window.height*32)-25, Window.width*32, "<span align=\"center\"><b>Software Version</b>: [VERSION]</span>")
		// Show the window
		Window.screen_loc = "CENTER-5,CENTER-7:16"

		// Fade the window in
		Window.FadeIn()
		/*
		sleep(5)

		// Begin flickering text

		var/text = "<span align=\"center\"><b>I N I T I A L I Z I N G. . .</b></span>"
		var/list/flicker_container = Window.DrawText("#66CC00", "#666600", 8, (Window.height*32)/2, Window.width*32, text)
		sleep(3)
		for(var/i = 1, i <= rand(1,2), i++)
			for(var/obj/O in flicker_container)
				Window.overlays -= O
			sleep(3)
			for(var/obj/O in flicker_container)
				Window.overlays += O
			sleep(3)
		sleep(8)
		for(var/obj/O in flicker_container)
			Window.overlays -= O
		*/

		// Draw the rest of the title screen
		Window.DrawText("#66CC00", "#666600", 50, (Window.height*32)-100, Window.width*32, "<b>Initiate New Campaign</b>")
		var/obj/hud/Button/StartGame/S = new(Window)
		S.layer = FLOAT_LAYER
		S.pixel_y = (Window.height*32)-100
		S.pixel_x = 230
		Window.overlays += S