
// things carbon-based life want
var/list/carbon_okay = list(/Substance/Oxygen, /Substance/Oxygen, /Substance/Nitrogen, /Substance/Hydrogen,
							/Substance/Argon, /Substance/CarbonDioxide, /Substance/DihydrogenMonoxide)

// things carbon-based life produce
var/list/carbon_out = list(/Substance/CarbonDioxide, /Substance/CarbonDioxide, /Substance/Ethane, /Substance/Hydrocarbons)

// things carbon-based life find poisonous
var/list/carbon_poison = list(/Substance/Iodine, /Substance/Sulfur, /Substance/Chlorine, /Substance/Deuterium,
							/Substance/CarbonMonoxide, /Substance/Chlorofluorocarbon)

// things arsenic-based life want
var/list/arsenic_okay = list(/Substance/HydrogenSulfide, /Substance/HydrogenSulfide, /Substance/DihydrogenMonoxide,
							/Substance/Iodine, /Substance/Chlorine, /Substance/Bromine, /Substance/Krypton,
							/Substance/Sulfur, /Substance/Argon, /Substance/Phosphorus, /Substance/Oxygen, /Substance/Nitrogen)

// things arsenic-based life produce
var/list/arsenic_out = list(/Substance/SulphurDioxide, /Substance/SulphurDioxide, /Substance/SulphurDioxide,
							/Substance/CarbonMonoxide)

// things arsenic-based life find poisonous
var/list/arsenic_poison = list(/Substance/Hydrocarbons, /Substance/DeuteriumOxide, /Substance/Fluorine)


/* Substance Class
	- Represents a compound/element/alloy prototype
	- Used in atmosphereic compositions
*/

Substance
	var
		name = "Element X"
		desc = "This element is pretty dope yo."

		natural = 0


	/* Diatomic and Monotonic substances */
	// Human-safe
	Oxygen
		desc = "The diatomic substance O2, essential to most carbon-based cellular respiration."
		natural = 1
	Nitrogen
		desc = "The diatomic substance N2, essential to most carbon-based cellular respiration."
		natural = 1
	Hydrogen
		desc = "The diatomic substance H2."
		natural = 1
	Argon
		desc = "The noble gas Argon."
		natural = 1
	// Others
	Krypton
		desc = "The noble gas Krypton."
		natural = 1
	Helium
		desc = "The noble gas Helium."
		natural = 1
	Xenon
		desc = "The noble gas Xenon."
		natural = 1
	Sulfur
		desc = "The common nonmetal Sulphur."
		natural = 1
	Phosphorus
		desc = "The common nonmetal Phosphorus."
		natural = 1
	Fluorine
		desc = "The diatomic substance F2."
		natural = 1
	Iodine
		desc = "The diatomic substance I2."
		natural = 1
	Chlorine
		desc = "The diatomic substance C2."
		natural = 1
	Bromine
		desc = "The diatomic substance Br2."
		natural = 1


	/* Compounds */
	// Human-safe
	CarbonDioxide
		name = "Carbon dioxide"
		desc = "A beneficial byproduct of carbon-based cellular respiration."
	DihydrogenMonoxide
		name = "Dihydrogen monoxide (Water Vapor)"

	// Others
	HydrogenSulfide
		name = "Hydrogen sulfide"
		desc = "A highly poisonous compound to carbon-based life; essential for arsenic-based cellular respiration"
		natural = 1
	SulphurDioxide
		name = "Sulphur dioxide"
		desc = "A volatile compound released in seismic volcanic activity. Byproduct of arsenic-based celluluar respiration."
	Deuterium
		name = "Deuterium"
		desc = "A stable isotope of hydrogen (also known as Heavy Air)."
		natural = 1
	DeuteriumOxide
		name = "Deuterium oxide"
		desc = "A form of H2O that contains the hydrogen isotope Deuterium (also known as Heavy Water)."
	CarbonMonoxide
		name = "Carbon monoxide"
		desc = "A light gas compound comprised of carbon and oxygen."
		natural = 1
	Hydrocarbons
		name = "Hydrocarbons"
		desc = "Trace organic substances comprised of several unique compounds."
	Methane
		desc = "A chemical compound found commonly in environments with carbon-based organic life."
		natural = 1

	// Pollutants
	Chlorofluorocarbon
		name = "Cloroflurocarbon (CFC)"
		desc = "An organic compound containing Chlorine, Fluorine, and Carbon. Common industrial pollutant."
	Ethane
		name = "Ethane"
		desc = "A combination of carbon and hydrogen, common industrial and propellant byproduct."
		natural = 1