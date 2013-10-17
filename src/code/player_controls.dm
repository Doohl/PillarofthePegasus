client
	var
		list/keymap = list()
	New()
		..()
		spawn(2)
			LoadKeyMap()
			BuildMacros()


	proc/LoadKeyMap()
		keymap = new

		//	Default movement keys
		keymap["w"] 		=	"north"
		keymap["w+UP"] 		=	"north-up"

		keymap["North"] 	=	"north"
		keymap["North+UP"] 	=	"north-up"

		keymap["s"] 		=	"south"
		keymap["s+UP"] 		=	"south-up"

		keymap["South"] 	=	"south"
		keymap["South+UP"] 	=	"south-up"

		keymap["a"] 		=	"west"
		keymap["a+UP"] 		=	"west-up"

		keymap["West"] 		=	"west"
		keymap["West+UP"] 	=	"west-up"

		keymap["d"] 		=	"east"
		keymap["d+UP"] 		=	"east-up"

		keymap["East"] 		=	"east"
		keymap["East+UP"] 	=	"east-up"

		//	Special keys
		keymap["space"] 	=	"show"

	proc/BuildMacros()
		if(!keymap.len) return

		winset(src,"main","macro=keymap")
		for(var/key_macro in keymap)
			var/command = keymap[key_macro]
			winset(src,"keyMap[key_macro]","parent='keymap';name='[key_macro]';command='[command]'")


mob
	player
		var/tmp
			m_north; m_south; m_east; m_west
			north_time; south_time; east_time; west_time

			moving = 0

		proc/player_movement_loop()

			if(m_north | m_south | m_east | m_west)
				moving = 1
			else
				moving = 0
				return

			var/dx = 0
			var/dy = 0

			if(m_north) dy += step_size
			if(m_south) dy -= step_size
			if(m_east) dx += step_size
			if(m_west) dx -= step_size

			Move(loc, dir, step_x+dx, step_y+dy)

			spawn(world.tick_lag) player_movement_loop()


		verb/north()
			set hidden = 1
			set instant = 1
			m_north = 1
			north_time = world.time
			if(!moving)
				player_movement_loop()
		verb/south()
			set hidden = 1
			set instant = 1
			m_south = 1
			south_time = world.time
			if(!moving)
				player_movement_loop()
		verb/east()
			set hidden = 1
			set instant = 1
			m_east = 1
			east_time = world.time
			if(!moving)
				player_movement_loop()

		verb/west()
			set hidden = 1
			set instant = 1
			m_west = 1
			west_time = world.time
			if(!moving)
				player_movement_loop()

		verb/north_up()
			set hidden = 1
			set instant = 1
			m_north = 0

		verb/south_up()
			set hidden = 1
			set instant = 1
			m_south = 0

		verb/east_up()
			set hidden = 1
			set instant = 1
			m_east = 0

		verb/west_up()
			set hidden = 1
			set instant = 1
			m_west = 0