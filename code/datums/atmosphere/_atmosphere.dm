/datum/atmosphere
	var/gas_string

	var/list/base_gases = list()// A list of gases to always have
	var/list/normal_gases = list() // A list of allowed gases:base_amount
	var/list/restricted_gases = list() // A list of allowed gases like normal_gases but each can only be selected a maximum of one time
	var/restricted_chance = 0 // Chance per iteration to take from restricted gases

	var/minimum_pressure
	var/maximum_pressure

	var/minimum_temp
	var/maximum_temp

/datum/atmosphere/New()
	generate_gas_string()

/datum/atmosphere/proc/generate_gas_string()
	var/list/spicy_gas = restricted_gases.Copy()
	var/target_pressure = rand(minimum_pressure, maximum_pressure)
	var/pressure_scalar = target_pressure / maximum_pressure

	if(HAS_TRAIT(SSstation, STATION_TRAIT_UNNATURAL_ATMOSPHERE))
		restricted_chance = restricted_chance + 40

	// First let's set up the gasmix and base gases for this template
	// We make the string from a gasmix in this proc because gases need to calculate their pressure
	var/datum/gas_mixture/gasmix = new
	var/list/gaslist = gasmix.gases
	gasmix.temperature = rand(minimum_temp, maximum_temp)
	for(var/i in base_gases)
		ADD_GAS(i, gaslist)
		gaslist[i][MOLES] = base_gases[i]

	// Now let the random choices begin
	var/datum/gas/gastype
	var/amount
	while(gasmix.return_pressure() < target_pressure)
		if(!prob(restricted_chance) || !length(spicy_gas))
			gastype = pick(normal_gases)
			amount = normal_gases[gastype]
		else
			gastype = pick(spicy_gas)
			amount = spicy_gas[gastype]
			spicy_gas -= gastype //You can only pick each restricted gas once

		amount *= rand(50, 200) / 100 // Randomly modifes the amount from half to double the base for some variety
		amount *= pressure_scalar // If we pick a really small target pressure we want roughly the same mix but less of it all
		amount = CEILING(amount, 0.1)

		ASSERT_GAS(gastype, gasmix)
		if(!gaslist[gastype])
			gaslist[gastype] = list()
			gaslist[gastype][MOLES] = 0
		gaslist[gastype][MOLES] += amount

	/* CURRENTLY DISABLED AS I DONT KNOW WHY THIS RUNTIMES AND BREAKS A LOT OF THINGS (cannot read list)
	// That last one put us over the limit, remove some of it
	while(gasmix.return_pressure() > target_pressure)
		gaslist[gastype][MOLES] -= 1
	gaslist[gastype][MOLES] = FLOOR(gaslist[gastype][MOLES], 0.1)
	*/
	gasmix.garbage_collect()

	// Now finally lets make that string
	var/list/gas_string_builder = list()
	for(var/i in gaslist)
		var/list/gas = gaslist[i]
		gas_string_builder += "[gas[GAS_META][META_GAS_ID]]=[gas[MOLES]]"
	gas_string_builder += "TEMP=[gasmix.temperature]"
	gas_string = gas_string_builder.Join(";")
