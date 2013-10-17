mob/player/var
	tmp/HUD/HUD // The main HUD container for all hud data


/* Main HUD Datum
	- Contains all huds in a player's screen and tracks them for dynamic loading and display.
	- Most windows and hud elements are pre-rendered and displayed with invisibility/layering.
*/


HUD
	var
		client/master
		list
			hud_objects = list()	// all hud entities tracked in this container
			buttons = list()		// all clickable entities tracked in this container

			windows = list()		// all windows tracked in this container
			attention = list()		// a queue for windows. len - index determines the offset to WINDOW_LAYER

/* HUD Object Elements
	- Represent hud objects in the client.screen space
	- Contained by the main HUD datum
	- Usually also contained by a parent Window type
*/

obj/hud
	var
		HUD/master					// the main HUD datum containing this hud element
		list/siblings = list()		// all elements associated with this hud element
		atom/hook					// a 'real-world' atomic hook for this hud element, just something to be associated with

		closing
		opening

		del_close = 0				// deletes when closed

	icon = 'UI.dmi'
	layer = WINDOW_PERIPHERALS

	// Closes the window by setting invisibility to 101, can be virtually overloaded for custom behavior

	proc/Close()
		if(closing||opening) return
		closing = 1
		if(istype(src, /obj/hud/Window))
			var/obj/hud/Window/W = src
			master.attention.Remove(src)
			for(var/obj/hud/Window/_w in master.windows)
				_w.layer = WINDOW_LAYER + (master.attention.len - master.attention.Find(_w))
			W.FadeOut()

		master.master.screen -= src
		closing = 0
		if(del_close)
			for(var/x in siblings)
				del(x)
			del(src)

	// Opens the window by adding it back to the screen

	proc/Open()
		if(opening||closing) return
		opening = 1
		master.master.screen += src
		if(istype(src, /obj/hud/Window))
			var/obj/hud/Window/W = src
			master.attention.Insert(1, src)
			for(var/obj/hud/Window/_w in master.windows)
				_w.layer = WINDOW_LAYER + (master.attention.len - master.attention.Find(_w))
			W.FadeIn()
		opening = 0

	/* Main Window Object
		- Contains overlays which are displayed to client.screen
		- Acts as a container for 'sibling' hud elements.
	*/

	Window
		var
			width = 0
			height = 0

			movable = 1	// determines if the window can be moved around

			obj/hud/Button/CloseWindow/Close // button to close the window

		// Constructs and initializes a window object:
			// width and height dictated in tiles - the "header", header takes an additional height. so "true" height implied height+1
			// closebutton - dictates whether or not to draw a close button
			// grab_attention - dictates whether or not to grab the main HUD's "attention"
			// header - if text specified, draw header with text. otherwise, don't draw header.

		New(HUD, widthp = 1, heightp = 1, layerp = WINDOW_LAYER, offx = 0, offy = 0, closebutton = 1, grab_attention = 1, header, s_loc, call_src, call_trg, call_proc)
			..()
			if(header) src.name = header
			src.master = HUD
			src.width = widthp
			src.height = heightp
			src.layer = layerp
			src.pixel_x = offx
			src.pixel_y = offy

			if(s_loc && istype(s_loc, /list) && s_loc:len >= 4)
				src.screen_loc = "[s_loc[1]]:[s_loc[2]],[s_loc[3]]:[s_loc[4]]"

			master.hud_objects.Add(src)
			master.windows.Add(src)

			var/obj/I = new
			I.icon = icon
			I.layer = FLOAT_LAYER

			// Create a Close Window button
			if(closebutton)
				Close = new(src)
				Close.call_src = call_src
				Close.call_trg = call_trg
				Close.call_proc = call_proc

			// Push this window atop the attention queue
			if(grab_attention)
				master.attention.Insert(1, src)
				for(var/obj/hud/Window/W in master.windows)
					W.layer = WINDOW_LAYER + (master.attention.len - master.attention.Find(W))

			// Begin drawing the window frame
			for(var/row = height, row >= 0, row--)
				for(var/column = width, column >= 0, column--)

					if(!column)	// leftmost
						if(!row) // bottomleftmost
							I.icon_state = "bottomleft"
						else
							if(row == height) // topleftmost
								I.icon_state = "topleft"
							else // just a normal left
								I.icon_state = "left"

					else // not the leftmost
						if(column == width) // rightmost
							if(!row) // bottomrightmost
								I.icon_state = "bottomright"
							else
								if(row == height) // toprightmost
									I.icon_state = "topright"
								else // just a normal right
									I.icon_state = "right"

						else // not a rightmost
							if(!row) // the bottom
								I.icon_state = "bottom"
							else
								if(row == height) // the tops, baby
									I.icon_state = "top"
								else // all other conditions failed; most be the middle
									I.icon_state = "middle"

					// Add the overlay for this particular column and row
					I.pixel_x = 32*column
					I.pixel_y = 32*row
					if(header || istext(header)) // we have a header - shift everything down one
						I.pixel_y -= 32
					overlays += I

			//while(src)
			//	pixel_x += rand(-1,1)
			//	sleep(2)

			if(header || istext(header))
				// Begin drawing the header
				for(var/column = width, column >= 0, column--)

					if(!column) // leftmost
						I.icon_state = "headerleft"
					else if(column == width) // rightmost
						I.icon_state = "headerright"
					else // middle
						I.icon_state = "headerm[rand(1,3)]"

					I.pixel_x = 32*column
					I.pixel_y = 32*height
					overlays += I

				// Draw the header
				DrawText("#33CC33", "#005400", 12, (32*height)+3, 32*width, "<center><b>[header]")

			if(closebutton)
				Close.layer = FLOAT_LAYER
				Close.pixel_y = (32*height)+3
				Close.pixel_x = (32*width)+14
				overlays += Close

			if(master)
				master.master.screen += src


		// When the mouse is pressed whilst on top of a window. Default behavior is to begin the window-dragging mechanic.
		MouseDown(location, control, params)
			..()
			var/list/listparam = params2list(params)
			var/press_x = text2num(listparam["icon-x"])
			var/press_y = text2num(listparam["icon-y"])

			var/clicked = 0
			for(var/obj/hud/H in siblings)
				var/boxx = (H.bound_width-H.bound_x) + H.pixel_x
				var/boxy = (H.bound_height-H.bound_y) + H.pixel_y
				if(press_x >= H.pixel_x && press_x <= boxx && press_y >= H.pixel_y && press_y <= boxy)
					H.Click(location, control, params)
					clicked = 1

			if(movable && !clicked)
				usr.client.window_hook_x = press_x-15
				usr.client.window_hook_y = press_y-15
				usr.client.MousePosition(params)
				usr.client.dragging_window = src

				// Push this window atop the attention queue
				master.attention.Remove(src)
				master.attention.Insert(1, src)
				for(var/obj/hud/Window/W in master.windows)
					W.layer = WINDOW_LAYER + (master.attention.len - master.attention.Find(W))

		// Draws divider on window
		proc/DrawDivVert(px, py, pwidth)
			for(var/i = 1, i <= width, i++)
				var/obj/o = new()
				o.layer = FLOAT_LAYER
				if(i == 1)
					o.icon = new/icon(icon, "separatorends", EAST)
				else if(i == width)
					o.icon = new/icon(icon, "separatorends", WEST)
				else
					o.icon = new/icon(icon, "separator", WEST)
				o.pixel_x = px+((i-1)*32)
				o.pixel_y = py
				overlays += o

		// Quick proc to draw text onto the window
		proc/DrawText(forecolor, bgcolor, px, py, pwidth, text)

			// Draw text shadow
			var/obj/o = new()
			o.layer = FLOAT_LAYER
			o.maptext = "<font color=[bgcolor]>[text]"
			o.tag = text
			o.pixel_x = px+1
			o.pixel_y = py-1
			o.maptext_width = 32*width
			overlays += o

			// Draw header text
			var/obj/t = new()
			t.layer = FLOAT_LAYER
			t.maptext = "<font color=[forecolor]>[text]"
			t.tag = text
			t.pixel_x = px
			t.pixel_y = py
			t.maptext_width = 32*width
			overlays += t

			return list(o, t)

		// DrawText() but with a bit more flexibility
		proc/DrawTextAdv(foretext, bgtext, px, py, pwidth)
			// Draw text shadow
			var/obj/o = new()
			o.layer = FLOAT_LAYER
			o.maptext = "[bgtext]"
			o.tag = bgtext
			o.pixel_x = px+1
			o.pixel_y = py-1
			o.maptext_width = 32*width
			overlays += o

			// Draw header text
			var/obj/t = new()
			t.layer = FLOAT_LAYER
			t.maptext = "[foretext]"
			o.tag = foretext
			t.pixel_x = px
			t.pixel_y = py
			t.maptext_width = 32*width
			overlays += t

		// Fade the window into view
		proc/FadeIn()
			alpha = 0
			animate(src, alpha = 255, time = 3)
			sleep(3)
			alpha = 255

		// Fade the window out of view
		proc/FadeOut()
			alpha = 255
			animate(src, alpha = 0, time = 2)
			sleep(2)
			alpha = 0

	/* Game Frame
		- The game frame that surrounds the main display map
	*/
	GameFrame
		layer = HUD_EFFECTS+1

	/* Stellar Margin
		- A black-transparent margin that appears below the visible game map
		- Acts as a dark background to display celestial bodies on the main map
	*/
	StellarMargin
		layer = HUD_EFFECTS
		icon_state = "top_transparent"
		screen_loc = "SOUTH+1,WEST to SOUTH+1,EAST-1"
		del_close = 1
		New(HUD/H)
			..()
			if(!H) return
			master = H
			master.hud_objects.Add(src)
			master.master.screen += src

	/* Space Background
		- A space background for generic use
	*/

	Space_BG
		layer = TURF_LAYER
		icon = 'spacebg.png'
		screen_loc = "SOUTHWEST"
		New(HUD/H)
			..()
			if(!H) return
			master = H
			alpha = 130
			master.hud_objects.Add(src)
			master.master.screen += src

	/* The 'title screen' background'
		- For use in the title screen
	*/

	Title_BG
		layer = TURF_LAYER
		icon = 'introbg.png'
		screen_loc = "SOUTHWEST"
		New(HUD/H)
			..()
			if(!H) return
			master = H
			master.hud_objects.Add(src)
			master.master.screen += src

	/* Button type
		- Performs some operation when clicked
	*/

	Button
		bound_height = 17
		bound_width = 17

		New(obj/hud/Window)
			..()
			if(!Window || !Window.master) return
			siblings.Add(Window)
			Window.siblings.Add(src)

			master = Window.master

			master.hud_objects.Add(src)
			master.buttons.Add(src)

		/* Close Window Button
			- Closes all associated siblings, and those siblings' siblings (not fully recursive)
			- Closes itself
		*/

		CloseWindow
			icon_state = "close"
			var
				call_src
				call_trg
				call_proc
			Click()
				if(call_src && call_proc)
					call(call_src, call_proc)(call_trg)

				for(var/obj/hud/H in siblings)
					for(var/obj/hud/_H in H.siblings)
						_H.Close() // Close the 'cousin' elements
					H.Close() // Close the immediate siblings

		/* Stellar View Button
			- Moves the current view to Stellar view
		*/

		Stellar
			bound_height = 25
			bound_width = 25
			icon_state = "stellar"
			var/Star/Star
			Click()
				if(usr:StarWindow)
					spawn() usr:StarWindow.Close()
				sleep(1)
				usr:selected_star.Deselect(usr)
				usr:StellarView(Star)
				..()

		/* Interstellar View Button
			- Moves the current view to Interstellar view
		*/

		Interstellar
			bound_height = 25
			bound_width = 25
			icon_state = "interstellar"
			var/Star/Star
			Click()
				if(usr:StarWindow)
					spawn() usr:StarWindow.Close()
				sleep(1)
				usr:selected_star.Deselect(usr)
				usr:InterstellarView(Star)
				..()

		/* Start Game button
			- Starts the game.
		*/

		StartGame
			icon_state = "button"
			Click()
				..()
				usr:StartGame()

	/* Bar Type
		- Takes a max and current value and turns it into a bar
	*/
	Bar
		var
			max_val
			cur_val

			fill_color = "#FFFFFF"
			width = 1

			list/segments = list()
			list/fills = list()

			obj/hud/Window/MasterWindow

		New(obj/hud/Window, width, px, py)
			..()
			if(!Window || !Window.master) return
			siblings.Add(Window)
			Window.siblings.Add(src)
			MasterWindow = Window
			src.width = width

			master = Window.master
			master.hud_objects.Add(src)

			for(var/i = 1, i <= width, i++)
				var/obj/hud/BarSeg/B = new(src)
				B.pixel_x = px+((i-1)*32)
				B.pixel_y = py
				B.layer = FLOAT_LAYER
				Window.overlays += B
				segments.Add(B)
				for(var/j = 1, j <= 8, j++)
					var/obj/hud/H = new()
					H.icon_state = "inner_empty"
					H.pixel_x = B.pixel_x+((j-1)*4)
					H.pixel_y = py
					H.layer = FLOAT_LAYER
					Window.overlays += H
					fills.Add(H)
					B.fills.Add(H)

		proc/Draw(mval, cval)
			var/maxbars = mval / fills.len

			for(var/obj/hud/H in fills)
				MasterWindow.overlays -= H
				if(cval > 0)
					H.icon_state = "inner"
					H.color = fill_color
					cval -= maxbars
				else
					H.icon_state = "inner_empty"
					H.color = null

				MasterWindow.overlays += H

		IntegriBar
			fill_color = "#66FF00"

	/* Individual bar segment type */
	BarSeg
		icon_state = "bar"
		var
			Bar_master
			list/fills = list()

		New(obj/hud/Bar)
			..()
			Bar_master = Bar


/* Window dragging mechanics
	- Allows windows to be dragged and dropped dynamically into new locations on the client screen
*/


atom/MouseDrag(over_object, src_location, over_location, src_control, over_control, params)
	..()
	usr.client.MousePosition(params)
	usr.client.UpdateMouse()


atom/MouseEntered(location, control, params)
	..()
	usr.client.MousePosition(params)
	usr.client.UpdateMouse()

atom/MouseMove(location, control, params)
	..()
	usr.client.MousePosition(params)
	usr.client.UpdateMouse()

// Release the window being held
atom/MouseUp(location, control, params)
	..()
	usr.client.window_hook_x = 0
	usr.client.window_hook_y = 0
	if(usr.client.dragging_window)

		usr.client.MousePosition(params)
		usr.client.dragging_window.alpha = 255
		usr.client.dragging_window = null

client
	var
		// Mouse location values
		mouse_x
		mouse_y
		mouse_screen_loc

		obj/hud/Window/dragging_window

		// The approximate relative location in the window where it was originally clicked
		window_hook_x = 0
		window_hook_y = 0

	proc
		// Fish the mouse_x and mouse_y values out of the "screen-loc" parameter (credits go to Ter and Kaiochao)
		MousePosition(params)
			var/s = params2list(params)["screen-loc"]
			var/x = 0
			var/y = 0

			var/s1 = copytext(s,1,findtext(s,",",1,0))
			var/s2 = copytext(s,length(s1)+2,0)

			var/colon1 = findtext(s1,":",1,0)
			var/colon2 = findtext(s1,":",colon1+1,0)

			if(colon2)
				x = (text2num(copytext(s1,colon1+1,colon2))-1) *32
				x += text2num(copytext(s1,colon2+1,0))-1

			else
				x = (text2num(copytext(s1,1,colon1))-1) * 32
				x += text2num(copytext(s1,colon1+1,0))-1

			colon2 = findtext(s2,":",1,0)
			y = (text2num(copytext(s2,1,colon2))-1) * 32
			y += text2num(copytext(s2,colon2+1,0))-1

			mouse_screen_loc = s
			mouse_x = x
			mouse_y = y

		// Update the mouse for dragging purposes
		UpdateMouse()
			if(dragging_window)

				if(dragging_window.alpha==255) dragging_window.alpha = 200

				var/tx = round(mouse_x / 32) - round(window_hook_x/32)
				var/ty = round(mouse_y / 32) - round(window_hook_y/32)
				var/px = mouse_x % 32
				var/py = mouse_y % 32
				dragging_window.screen_loc = "[tx]:[px],[ty]:[py]"