/datum/species/humanoid
	name = "Humanoid"
	id = "humanoid"
	flavor_text = "A term used for most sentient bipedal creatures, but most often used to classify those more human-like in nature. Genemodders, or humans with body mods, are often labelled as such."
	default_color = "444"
	species_traits = list(MUTCOLORS,EYECOLOR,LIPS,HAS_FLESH,HAS_BONE,HAIR,FACEHAIR)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	mutant_bodyparts = list()
	default_mutant_bodyparts = list("tail" = "None", "snout" = "None", "ears" = "None", "legs" = "Normal Legs", "wings" = "None", "taur" = "None", "horns" = "None", "neck" = "None")
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	limbs_id = "human"
