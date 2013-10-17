var/PI = 3.141592653

proc/atan2(x, y)
	if(!x && !y) return 0
	return y >= 0 ? arccos(x / sqrt(x * x + y * y)) : -arccos(x / sqrt(x * x + y * y))

proc/get_angle(atom/movable/a, atom/movable/b)
	if(!a || !b) return 0
	if(!istype(b, /turf))
		return atan2((b.y+b.step_y) - (a.y+a.step_y), (b.x+b.step_x) - (a.x+a.step_x))
	else
		return atan2(b.y - a.y, b.x - a.x)

proc/ceil(x) return -round(-x)

//	c% of the way from a to b
proc/lerp(a, b, c) return a * (1 - c) + b * c

//  c% of the way from a to b with cosine trigonometric curvature
proc/cerp(a, b, c)
	var/f = (1-cos(c*PI)) * 0.5
	return a*(1-f)+b*f

//	a random number (rand(a, b) returns an integer)
proc/randn(a, b) return lerp(a, b, rand())

proc/clamp(n, low, high)
	return min(max(n, low), high)

proc/avg(a, b)
	return round((a/b)*2,1)

// Not case sensitive:
proc/replacetext(haystack, needle, replace)
	var
		pos = findtext(haystack, needle)
		needleLen = length(needle)
		replaceLen = length(replace)
	while(pos)
		haystack = copytext(haystack, 1, pos) + replace + \
			copytext(haystack, pos+needleLen)
		pos = findtext(haystack, needle, pos+replaceLen)
	return haystack

// Case sensitive:
proc/replaceText(haystack, needle, replace)
	var
		pos = findtextEx(haystack, needle)
		needleLen = length(needle)
		replaceLen = length(replace)
	while(pos)
		haystack = copytext(haystack, 1, pos) + replace + \
			copytext(haystack, pos+needleLen)
		pos = findtextEx(haystack, needle, pos+replaceLen)
	return haystack