Line
	var
		list/atoms = list()

		list/segments = list()

		icon/lineicon
		matrix/icon_matrix
		angle
		approx_dir

obj/LineSeg
	icon = 'line.dmi'
	icon_state = "path"


proc/DrawLine(atom/Start, atom/Finish, icon = 'line.dmi', length = 9, icon_state = "path_idle")
	if(Start == Finish || Start.loc == Finish.loc) return
	var/Line/Line = new()
	var/angle = get_angle(Start.loc, Finish.loc)

	Line.icon_matrix = matrix()
	Line.icon_matrix.Turn(angle)
	Line.atoms.Add(Start, Finish)
	Line.angle = angle

	var/i = 2
	var/cancel = 0
	while(i && i<=100 && !cancel)
		var/obj/LineSeg/LineSeg = new(Start.loc)
		//LineSeg.step_x = sin(angle)*length*i
		//LineSeg.step_y = cos(angle)*length*i
		LineSeg.Move(LineSeg.loc, SOUTH, sin(angle)*length*i, cos(angle)*length*i)
		for(var/obj/Star/S in bounds(LineSeg, 1))
			if(S == Finish)
				cancel = 1 // stop drawing but don't delete all segments
			else if(S != Start)
				cancel = 2 // stop drawing and delete all segments

		LineSeg.icon = icon
		LineSeg.icon_state = icon_state
		LineSeg.transform = Line.icon_matrix
		Line.segments.Add(LineSeg)
		i++

	if(cancel == 2)
		for(var/x in Line.segments) del(x)
		del(Line)
		return 0 // failure
	else
		if(istype(Start, /obj/Star))
			var/obj/Star/S = Start
			S.metastar.lines.Add(Line)
		if(istype(Finish, /obj/Star))
			var/obj/Star/S = Finish
			S.metastar.lines.Add(Line)
		return 1 // success

proc/DrawCircle(atom/Ref, icon = 'line.dmi', length = 9, icon_state = "path_idle")
