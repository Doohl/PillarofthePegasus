// Useful constants
#define STAGNANT_WEATHER 0
#define WEAK_WEATHER 1
#define NORMAL_WEATHER 2
#define ACTIVE_WEATHER 3
#define HYPER_WEATHER 4
#define CATACLYSMIC_WEATHER 5

#define STAGNANT_TECTONICS 0
#define WEAK_TECTONICS 1
#define NORMAL_TECTONICS 2
#define ACTIVE_TECTONICS 3
#define HYPER_TECTONICS 4
#define CATACLYSMIC_TECTONICS 5

#define DESERT_PLANET 0
#define MOUNTAIN_PLANET 1
#define FLAT_PLANET 2
#define OCEANIC_PLANET 3
#define ICE_PLANET 4
#define VOLCANIC_PLANET 5
#define EARTHLIKE_PLANET 6
#define JUNGLE_PLANET 7
#define GAS_PLANET 8
#define GAS_GIANT 9


/* Planet Class
	- Planets are the primary geographic feature of star systems
	- Can support atmospheres, life, galaxies, etc.
*/

Planet
	var
		name = "Planet X"

		// Geographic variables
		list/atmosphere = list()	// the atmosphereic composition
									// associative index of substance datum, value between 1.0 and 0.001
		atmos_pressure				// the total atmosphereic pressure in kPa
		surface_temp				// the surface temperature of the planet in Kelvin
		orbital_dist				// the orbital distance from the star to the planet in tiles
		resources					// how rich the planet is in resources (1-10)
		diameter					// planet's diameter in km
		tilt						// the planet's axial tilt
		weather						// the planet's weather class
		tectonics					// the planet's tectonics class
		class = 0					// the planet's biome class

		Star/Star					// the star this planet is orbiting

		// Other variables
		Race/occupying_race			// the primary occupying race of the planet
		list/races = list()			// associative container, index is race, value is control from 1-100
									// 1-10 = early colonies
									// 11-30 = established colonies
									// 31-50 = established global cities
									// 51-70 = high planetary control
									// 70-90 = almost total planetary control
									// 100 = total planetary control

		list/cities = list()		// the cities occupying this planet

		obj/Planet/physical			// the current physical planet representing this planet

	proc/Init(homeworld = 0)
		surface_temp = round(sqrt(Star.surface_temp) / (orbital_dist/3)*8)
		tilt = round(randn(0, 300), 0.01)

		if(homeworld)
			class = rand(DESERT_PLANET, JUNGLE_PLANET)
		else
			if(prob(55)) class = pick(GAS_PLANET, GAS_GIANT)
			else class = rand(DESERT_PLANET, JUNGLE_PLANET)

		// Assign the tectonics type
		if(class != GAS_GIANT)
			var/list/tectonic_types = list(STAGNANT_TECTONICS, WEAK_TECTONICS, NORMAL_TECTONICS, ACTIVE_TECTONICS, HYPER_TECTONICS, CATACLYSMIC_TECTONICS)
			if(homeworld) tectonic_types.Remove(CATACLYSMIC_TECTONICS)
			if(class == MOUNTAIN_PLANET || class == VOLCANIC_PLANET) tectonic_types.Remove(STAGNANT_TECTONICS, WEAK_TECTONICS)
			if(class == FLAT_PLANET) tectonic_types = list(STAGNANT_TECTONICS, WEAK_TECTONICS)
			tectonics = pick(tectonic_types)
		else
			tectonics = STAGNANT_TECTONICS

		// Assign the weather type
		if(class != GAS_GIANT && class != GAS_PLANET)
			var/list/weather_types = list(STAGNANT_WEATHER, WEAK_WEATHER, NORMAL_WEATHER, ACTIVE_WEATHER, HYPER_WEATHER, CATACLYSMIC_WEATHER)
			if(homeworld && prob(85)) weather_types.Remove(CATACLYSMIC_WEATHER)
			weather = pick(weather_types)
		else
			weather = pick(ACTIVE_WEATHER, HYPER_WEATHER, CATACLYSMIC_WEATHER)

		if(homeworld)
			diameter = rand(5000, 12000)
			atmos_pressure = rand(70, 200)

		else
			if(class == GAS_GIANT)
				diameter = rand(30000, 350000)
				atmos_pressure = rand(450, 700)
				RandAtmos()
			else if(class == GAS_PLANET)
				atmos_pressure = rand(200, 400)
				diameter = rand(5000, 30000)
				RandAtmos()
			else
				diameter = rand(800, 30000)
				if(diameter >= 3000)
					RandAtmos()
				else
					atmos_pressure = 0
	proc/RandAtmos()
		var/list/t = list()
		if(class == VOLCANIC_PLANET)
			t[/Substance/SulphurDioxide] = rand(60, 100)
		if(class == OCEANIC_PLANET && prob(75))
			t[/Substance/DihydrogenMonoxide] = rand(1, 5)

		var/list/substances = typesof(/Substance) - /Substance
		for(var/x in substances)
			var/Substance/S = new x
			if(!S.natural)
				substances.Remove(x)
		for(var/i = 1, i <= rand(1,6), i++)
			var/Substance/possible = pick(substances)
			if(!(possible in atmosphere))
				t[possible] = rand(20, 100)
			else
				i-- // try again asshole
		var/total = 0
		for(var/index in t)
			total += t[index]
		for(var/index in t)
			atmosphere[index] = t[index]/total
		..()

/* Planet object class
	- Fake planet representation of the real planet metadata
*/

obj/Planet
	icon = 'stellar.dmi'
	icon_state = "planet"
	var
		Planet/metaplanet

	Click(location, control, params)
		..()

/* Planet HUD class
	- Displayed on the hud for easy access
*/

obj/PlanetHUD
	icon = 'stellar.dmi'
	icon_state = "planet"
	layer = HUD_EFFECTS+2
	var
		Planet/metaplanet

	Click(location, control, params)
		..()
		usr.loc = metaplanet.physical.loc
		usr.step_x = 0
		usr.step_y = 0


proc/planet_bubble_sort(list/sorted)
	sorted = sorted.Copy()
	for(var/index = sorted.len; index >= 1; index--)
		for(var/item = 1; item < index; item++)
			var/Planet/this = sorted[item]
			var/Planet/next = sorted[item+1]
			if(this.orbital_dist < next.orbital_dist)
				sorted.Swap(item, item+1)
	return sorted



