
/* Layer definitions :: Trend - Lowest to Highest layer */

#define LINE_LAYER			TURF_LAYER
#define STAR_LAYER			OBJ_LAYER+1

#define WINDOW_LAYER 		10 // the main window frame
// Window-relative layer definitions
#define WINDOW_PERIPHERALS  FLOAT_LAYER-0.11  // anything in the window not text or frame
#define WINDOW_TEXT_LAYER 	FLOAT_LAYER-0.10  // anything in the window that is maptext

#define HUD_EFFECTS			15 // special hud effects displaying over everything

/* Miscellaneous enumerations and definitions */

#define VERSION	"0.1 (Early Alpha)"
#define TITLE	"Extragalactic Network Relay :: Project Pegasus"

#define INTERSTELLAR_VIEW 1
#define STELLAR_VIEW 2

/* Race flags and statuses */

// Sensory bitflags
#define SEES		(1 << 0)	// uses eyes to see
#define HEARS		(1 << 1)	// uses ears to hear
#define SMELLS		(1 << 2)	// uses smell
#define TASTES		(1 << 3)	// uses taste
#define EM_SENSES	(1 << 4)	// can sense EM activity
#define BIO_SENSES	(1 << 5)	// can sense biologicals

// Type of life
#define CARBON_BASE		0		// normal carbon-based life
#define ARSENIC_BASE 	1		// abnormal arsenic-based life
#define SILICON_BASE	2		// artificial life / silicon 'life'

// Government enumerations
#define MONARCHY	0			// ruled by monarch
#define DEMOCRACY	1			// ruled by the people
#define REPUBLIC	2			// ruled by elected representatives
#define DICTATOR	3			// ruled by a single person
#define THEOCRACY	4			// ruled by religion

// Government subprobs
// MONARCHY
#define KING_RULE	(1 << 0)	// monarchy ruled by King
#define QUEEN_RULE	(1 << 1)	// monarchy ruled by Queen
#define PARLIAMENT	(1 << 2)	// monarchy subgoverned by a Parliament (monarchs' actions can be opposed)

// DICTATOR
#define DICT_MALE	(1 << 0)	// the dictator is male
#define DICT_FEMALE (1 << 1)	// the dictator is female
#define COUNCIL		(1 << 2)	// dictator has advisory council
#define DICT_TOTAL	(1 << 3) 	// dictator controls all aspects of life

// THEOCRACY
#define CONSERVATIVE (1 << 0)	// theocracy values conservative ideals
#define THEO_TOTAL	 (1 << 1)	// theocracy controls all aspects of life
#define INDOCTRINATE (1 << 2)	// theocracy wants to indoctrinate other races, how violently depends on leaders


world
	name = "Pillar of the Pegasus"
	fps = 30
	icon_size = 32

	view = "29x25"		// only show 24x20, acts as a sort of "padding"
	turf = /turf/stellarbg
	mob = /mob/player

	New()
		..()
		for(var/x in vowels)
			for(var/y in vowels)
				if(x != y)
					vowel_combinations.Add("[x][y]")



mob
	step_size = 9

obj
	step_size = 8


turf
	stellarbg
		icon = 'stellar.dmi'
		icon_state = "bg"

	interstellarbg
		icon = 'interstellar.dmi'
		icon_state = "bg"