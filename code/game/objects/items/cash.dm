// Type for a "stack" of money, used for both holochips and cash bundles.
// Has support for a few basic logged operations (splitting and merging).
// This is intended to be an abstract type -- use subtypes!
/obj/item/money_stack
	name = "money"
	desc = "If you can see this, please make a bug report. Mappers should use subtypes!"
	icon = 'icons/obj/economy.dmi'
	icon_state = "credit0"
	w_class = WEIGHT_CLASS_TINY

	/// If you want the stack's value, use get_item_credit_value() instead!
	VAR_PROTECTED/value = 0
	var/merge_split_type

/obj/item/money_stack/Initialize(mapload, amount)
	. = ..()
	if(amount)
		value = amount
	format_log_econ(ECON_LOG_EVENT_MONEY_CREATED, list(
		"REF" = REF(src),
		"TYPE" = type,
		"VALUE" = value,
		"LOC" = AREACOORD(src)
	))
	update_appearance()

/obj/item/money_stack/Destroy(...)
	// on the off chance somebody manages to interact with this after it gets qdeleted...
	value = 0
	return ..()

/obj/item/money_stack/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It contains [value] credit[(value > 1) ? "s" : ""].</span>\n"+\
	"<span class='notice'>Alt-Click to split.</span>"

// Used by external code to get the stack's value.
/obj/item/money_stack/get_item_credit_value()
	return value

/obj/item/money_stack/AltClick(mob/living/user)
	return split_stack_popup(user)

/obj/item/money_stack/attack_self(mob/user)
	return split_stack_popup(user)

/obj/item/money_stack/attackby(obj/item/W, mob/user)
	var/did_merge = merge_from(W, user)
	if(did_merge)
		return TRUE
	else
		return ..()

/obj/item/money_stack/attack_hand(mob/user)
	if(user.get_inactive_held_item() == src)
		var/new_stack = split_into(user.loc, 1)
		user.put_in_hands(new_stack)
	else
		. = ..()

/// Alters the value of the stack, updating its appearance and possibly qdeleting it.
/// Amount passed must be a whole number. Additionally, if it is negative, its magnitude must be
/// equal to or less than that of the stack's current value (to prevent drawing more than the stack contains).
/// Logging can also be prevented by passing log = FALSE; this should only be done if it would create a duplicate log.
/// Returns TRUE if the alteration was successful, and FALSE otherwise.
/obj/item/money_stack/proc/alter_value(amount, log = TRUE)
	if(amount != round(amount) || (amount < 0 && value < (-amount)))
		return FALSE
	value += amount
	if(value > 0)
		update_appearance()
	else
		qdel(src)

	if(log)
		format_log_econ(ECON_LOG_EVENT_MONEY_ALTERED, list(
			"REF" = REF(src),
			"TYPE" = type,
			"AMT" = amount,
			"FINAL_VALUE" = value
		))

	return TRUE

/// Merges the passed money stack S into src, so long as it is a subtype of src.merge_split_type.
/// Has an optional "user" arg for feedback messages.
/// Returns TRUE if successful, FALSE otherwise.
/obj/item/money_stack/proc/merge_from(obj/item/money_stack/S, mob/user)
	if(!istype(S, merge_split_type))
		to_chat(user, "<span class='warning'>[S] cannot be merged into [src].</span>")
		return FALSE

	format_log_econ(ECON_LOG_EVENT_MONEY_MERGED, list(
		"FINAL_REF" = REF(src),
		"FINAL_TYPE" = type,
		"SOURCE_REF" = REF(S),
		"SOURCE_TYPE" = S.type,
		"TRANSFER_AMT" = S.value,
		"NEW_FINAL_VALUE" = value + S.value,
	))

	alter_value(S.value, log = FALSE)
	to_chat(user, "<span class='notice'>You add [S.value] credits worth of money to [src].<br>It now holds [value] credits.</span>")

	qdel(S)
	return TRUE

/// Splits src into a second stack of type src.merge_split_type -- the stack is created at
/// stack_loc with "amount" credits, which must be less than src.value.
/// If the split brings the stack to 0 credits, it is qdeleted.
/// Returns the new stack if successful, FALSE otherwise.
/obj/item/money_stack/proc/split_into(stack_loc, amount)
	if(amount > value)
		return FALSE

	var/obj/item/money_stack/new_stack = new merge_split_type(stack_loc, amount)

	format_log_econ(ECON_LOG_EVENT_MONEY_SPLIT, list(
		"SOURCE_REF" = REF(src),
		"SOURCE_TYPE" = type,
		"DEST_REF" = REF(new_stack),
		"DEST_TYPE" = new_stack.type,
		"TRANSFER_AMT" = amount,
		"NEW_SOURCE_VALUE" = value - amount,
	))

	alter_value(-amount, log = FALSE)
	return new_stack

/// Wrapper around split_into(), used for interactions.
/obj/item/money_stack/proc/split_stack_popup(mob/living/user)
	var/cashamount = input(user, "How many credits do you want to take? (0 to [value])", "Take Money", 20) as num
	cashamount = round(clamp(cashamount, 0, value))
	if(!cashamount)
		return

	else if(!Adjacent(user))
		to_chat(user, "<span class='warning'>You need to be in arm's reach for that!</span>")
		return

	var/new_stack = split_into(user.loc, cashamount)
	user.put_in_hands(new_stack)

/*
		HOLOCHIPS
 */

/obj/item/money_stack/holochip
	name = "credit holochip"
	desc = "A hard-light chip encoded with an amount of credits. It is a modern replacement for physical money that can be directly converted to virtual currency and vice-versa. Keep away from magnets."
	icon_state = "holochip"
	base_icon_state = "holochip"
	throwforce = 0
	force = 0

	merge_split_type = /obj/item/money_stack/holochip

/obj/item/money_stack/holochip/update_name()
	name = "\improper [value] credit holochip"
	return ..()

/obj/item/money_stack/holochip/update_icon_state()
	var/icon_suffix = ""
	switch(value)
		if(1e3 to (1e6 - 1))
			icon_suffix = "_kilo"
		if(1e6 to (1e9 - 1))
			icon_suffix = "_mega"
		if(1e9 to INFINITY)
			icon_suffix = "_giga"

	icon_state = "[base_icon_state][icon_suffix]"
	return ..()

/obj/item/money_stack/holochip/update_overlays()
	. = ..()
	var/rounded_credits
	switch(value)
		if(0 to (1e3 - 1))
			rounded_credits = round(value)
		if(1e3 to (1e6 - 1))
			rounded_credits = round(value * 1e-3)
		if(1e6 to (1e9 - 1))
			rounded_credits = round(value * 1e-6)
		if(1e9 to INFINITY)
			rounded_credits = round(value * 1e-9)

	var/overlay_color = "#914792"
	switch(value)
		if(0 to 4)
			overlay_color = "#8E2E38"
		if(5 to 9)
			overlay_color = "#914792"
		if(10 to 19)
			overlay_color = "#BF5E0A"
		if(20 to 49)
			overlay_color = "#358F34"
		if(50 to 99)
			overlay_color = "#676767"
		if(100 to 199)
			overlay_color = "#009D9B"
		if(200 to 499)
			overlay_color = "#0153C1"
		if(500 to INFINITY)
			overlay_color = "#2C2C2C"
	var/mutable_appearance/holochip_overlay = mutable_appearance('icons/obj/economy.dmi', "[icon_state]-color")
	holochip_overlay.color = overlay_color
	. += holochip_overlay

/obj/item/money_stack/holochip/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	var/wipe_chance = 60 / severity
	if(prob(wipe_chance))
		visible_message("<span class='warning'>[src] fizzles and disappears!</span>")
		qdel(src) //rip cash

/*
		SPACE CASH
*/

/obj/item/money_stack/cash
	name = "coin?"
	icon_state = "credit20" // just for mappers
	throwforce = 1
	throw_speed = 2
	throw_range = 2
	resistance_flags = FLAMMABLE
	grind_results = list(/datum/reagent/iron = 10)

	merge_split_type = /obj/item/money_stack/cash

// Code borrowed from baycode by way of Eris.
/obj/item/money_stack/cash/update_appearance()
	icon_state = "nothing"
	cut_overlays()
	var/remaining_value = value
	var/iteration = 0
	var/coins_only = TRUE
	var/list/coin_denominations = list(10, 5, 1)
	var/list/banknote_denominations = list(1000, 500, 200, 100, 50, 20)
	for(var/i in banknote_denominations)
		while(remaining_value >= i && iteration < 50)
			remaining_value -= i
			iteration++
			var/image/banknote = image('icons/obj/economy.dmi', "credit[i]")
			var/matrix/M = matrix()
			M.Translate(rand(-6, 6), rand(-4, 8))
			banknote.transform = M
			overlays += banknote
			coins_only = FALSE

	if(remaining_value)
		for(var/i in coin_denominations)
			while(remaining_value >= i && iteration < 50)
				remaining_value -= i
				iteration++
				var/image/coin = image('icons/obj/economy.dmi', "credit[i]")
				var/matrix/M = matrix()
				M.Translate(rand(-6, 6), rand(-4, 8))
				coin.transform = M
				overlays += coin

	if(coins_only)
		if(value == 1)
			name = "one credit coin"
			desc = "Heavier then it looks."
			drop_sound = 'sound/items/handling/coin_drop.ogg'
			pickup_sound =  'sound/items/handling/coin_pickup.ogg'
		else
			name = "[value] credits"
			desc = "Heavier than they look."
			gender = PLURAL
			drop_sound = 'sound/items/handling/coin_drop.ogg'
			pickup_sound =  'sound/items/handling/coin_pickup.ogg'
	else
		if(value <= 3000)
			name = "[value] credits"
			gender = NEUTER
			desc = "Some cold, hard cash."
			drop_sound = 'sound/items/handling/dosh_drop.ogg'
			pickup_sound =  'sound/items/handling/dosh_pickup.ogg'
		else
			name = "[value] credits"
			gender = NEUTER
			desc = "That's a lot of dosh."
			drop_sound = 'sound/items/handling/dosh_drop.ogg'
			pickup_sound =  'sound/items/handling/dosh_pickup.ogg'
	return ..()

/obj/item/money_stack/cash/c1
	value = 1
	icon_state = "credit1"

/obj/item/money_stack/cash/c5
	value = 5
	icon_state = "credit5"

/obj/item/money_stack/cash/c10
	value = 10
	icon_state = "credit10"

/obj/item/money_stack/cash/c20
	value = 20
	icon_state = "credit20"

/obj/item/money_stack/cash/c50
	value = 50
	icon_state = "credit50"

/obj/item/money_stack/cash/c100
	value = 100
	icon_state = "credit100"

/obj/item/money_stack/cash/c200
	value = 200
	icon_state = "credit200"

/obj/item/money_stack/cash/c500
	value = 500
	icon_state = "credit500"

/obj/item/money_stack/cash/c1000
	value = 1000
	icon_state = "credit1000"

/obj/item/money_stack/cash/c10000
	value = 10000
	icon_state = "credit1000"

/obj/item/money_stack/cash/pocketchange/Initialize()
	value = rand(10, 100)
	icon_state = "credit100"
	. = ..()

/obj/item/money_stack/cash/smallrand/Initialize()
	value = rand(100, 500)
	icon_state = "credit200"
	. = ..()

/obj/item/money_stack/cash/mediumrand/Initialize()
	value = rand(500, 3000)
	icon_state = "credit500"
	. = ..()

/obj/item/money_stack/cash/loadsamoney/Initialize()
	value = rand(2500, 6000)
	icon_state = "credit1000"
	. = ..()
