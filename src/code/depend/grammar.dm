var

	// Generic
	list/consonants = list("b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "y", "z")
	list/vowels = list("a", "e", "i", "o", "u")
	list/vowel_combinations = list() // generated in world/New()
	list/consonant_combinations = list("th", "ph", "sh", "bl", "br", "thr", "cr", "sk", "pr", "sm", "fl")

	// Star system generator
	list/greek_alphabet = list("Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta")
	list/greek_alphabet_rare = list("Omicron", "Phi", "Tau")

	list/constellations = list("Horigus", "Chentau", "Alrai", "Cephei", "Catana", "Citra", "Goron", "Capsilon",
								"Acubens", "Albion", "Abilon", "Altair", "Cor'vau", "Tureis", "Puppis", "Chi",
								"Galileo", "Foxtot", "Parada", "Eclipti", "Floren", "Catali", "Circini",
								"Tavros", "Cronus", "Draconis", "Ozpho", "Raynet", "Tango", "Pupau", "Karkot",
								"Seitaga", "Valmaso", "Ursae", "Sagitta", "Crusus", "Jenova", "Falayala", "Cox",
								"Erro", "Pete-22", "D02", "GCO", "Xerxes", "Labayo", "Henya", "Auro", "Tau'ri",
								"AR", "Belenos", "Balrog", "Lesath", "Cyth", "Barnard", "Zealae", "Catana", "Lexi",
								"Nord", "Octavius", "Gen'ni", "Ko'rah", "Kzer'ah", "Itch'ka", "Zu'bah", "Leeroy",
								"Jo", "Emperor", "Acat'uh", "Tel'mak", "Ir'ga", "Si'no", "Ji-un", "Ka-so", "Maikito",
								"Centaurion", "Boron", "Newton", "Lord", "Xanadax", "Z")

	// Race name generator (syllables not first-place are lowertext'd)
	list/name_syllables = list("Shi", "Hi", "Goh", "Lee", "Tar", "Th", "Cy", "My", "Con", "Kohr", "Ah", "Kzer", "Za",
								"Tau", "No", "Mi", "Go", "Zee", "Chi", "Mee", "Wee", "Ch", "Mmr", "Nei", "Mai",
								"Ki", "Tu", "Se", "Ph", "Sho", "Goth", "Hect", "Az", "Ari", "Lou", "Scor", "Sa", "Ge",
								"Bio", "Wyy", "Mona", "Arr", "Bozi", "Fole", "Na", "Wri", "Mo", "Ete", "Nia", "No'ko",
								"Cht", "I", "A", "C")

	list/name_last = list("%Un", "%Sun", "%Ah", "%Za", "%Too", "%Took", "%Phi", "%Zi")

	// Religion Generator
	list/study_type = list("Study", "Oracle", "Teachings", "Pastor", "Church", "Assembly", "Congregation", "Cult",
							"Group", "Ring", "Knights", "Templars")


proc/GenRaceName()
	var/n = pick(name_syllables)
	var/three = prob(25)
	var/n2
	if(three)
		if(prob(5)) n += "'"
		n2 = replacetext(pick(name_syllables), "%", pick("'", "'", "-"))
		n += lowertext(n2)
		if(prob(5)) n += "'"
		n2 = replacetext(pick(name_syllables), "%", pick("'", "'", "-"))
		n += lowertext(n2)
	else
		if(prob(5)) n += "'"
		n2 = replacetext(pick(name_syllables), "%", pick("'", "'", "-"))
		n += lowertext(n2)

	return n

proc/GenRandName(length = 5, consonant_first = pick(1,1,1,1,1,0))
	var/n = ""
	var/do_vowel = !consonant_first
	for(var/i = 1, i <= length, i++)
		var/letter
		if(do_vowel)
			if(prob(5))
				n += "'"
			var/list/vo = vowels.Copy()
			if(prob(15)) vo += vowel_combinations
			letter = pick(vo)
		else
			var/list/co = consonants.Copy()
			if(prob(15)) co += consonant_combinations
			letter = pick(co)

		do_vowel = !do_vowel

		if(i == 1)
			letter = uppertext(copytext(letter, 1, 2))+copytext(letter, 2, 0)
		n += letter
		if(lowertext(letter) == "q")
			n += "u"
			i++

	return n

proc/GenReligion()
	var/n = "The "
	n += pick(study_type)
	n += " of "
	n += pick(name_syllables)+lowertext(pick(name_syllables))
	return n