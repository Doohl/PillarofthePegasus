atom/movable/proc/PixelMove(dx, dy)
	/*var/d = 0
	if(dx) d |= (dx>0) ? EAST : WEST
	if(dy) d |= (dy>0) ? NORTH : SOUTH
	if(abs(dx) >= abs(dy)*2) d &= 3
	else if(abs(dy) >= abs(dx)*2) d &= 12*/
	Move(loc, dir, step_x+dx, step_y+dy)

proc/get_dir_adv(atom/ref, atom/target)
	//Written by Lummox JR
	//Returns the direction between two atoms more accurately than get_dir()

	if(target.z > ref.z) return UP
	if(target.z < ref.z) return DOWN

	. = get_dir(ref, target)
	if(. & . - 1)        // diagonal
		var/ax = abs(ref.x - target.x)
		var/ay = abs(ref.y - target.y)
		if(ax >= (ay << 1))      return . & (EAST | WEST)   // keep east/west (4 and 8)
		else if(ay >= (ax << 1)) return . & (NORTH | SOUTH) // keep north/south (1 and 2)
	return .

// Faster version of range(), provided by Jittai
// Uses block() for calculation
proc/trange(Range=0,atom/Center=null)
	if(Center==null) return
	var/_x1y1 = locate(clamp(Center.x-Range, 1, world.maxx), clamp(Center.y-Range, 1, world.maxy), Center.z)
	var/_x2y2 = locate(clamp(Center.x+Range, 1, world.maxx), clamp(Center.y+Range, 1, world.maxy), Center.z)
	return block(_x1y1,_x2y2)

proc/distance(atom/M,atom/N)
	return sqrt((N.x-M.x)**2 + (N.y-M.y)**2)

proc/distance2(x1, y1, x2, y2)
	return sqrt((x2-x1)**2 + (y2-y1)**2)

proc/getring(atom/M,radius)
	var/list/ring=list()
	var/turf/T
	for(T as turf in trange(radius+1,M))
		if(abs(distance(T,M)-radius) <0.5) ring += T
	return ring