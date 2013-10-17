var
	list/flag_cache = list()	// list of cached/garbage-collected metaflags

/* Metaflag geometric object
	- Metaflags are used for representing points/objects in z level 3 that do not actually exist in gameplay.
	- Used for performing geometric functions for datums contained soley in the Metaworld.
*/

Metaflag
	parent_type = /obj

	New(mx, my, mz)
		..()
		loc = locate(mx, my, mz)

	// Add the metaflag back into the cache
	proc/Release()
		flag_cache.Add(src)


/* Get a Metaflag datum at a specific point in z-level 3. Either pull one from flag_cache or create a new one.

	- GetFlag(x, y) 	: returns a flag at (x, y, 3)
	- GetFlag(x, y, z) 	: returns a flag at (x, y, z)

	- GetFlag(turf) 	: returns a flag at turf

*/
proc/GetFlag()
	var
		x
		y
		z = 3

	if(args.len >= 2)
		x = args[1]
		y = args[2]
	if(args.len == 3)
		z = args[3]

	else if(args.len == 1)
		var/turf/T = args[1]
		x = T.x
		y = T.y

	if(length(flag_cache))
		var/Metaflag/flag = flag_cache[1]
		flag_cache.Remove(flag)
		flag.loc = locate(x, y, z)
		return flag
	else
		return new/Metaflag(x, y, z)
