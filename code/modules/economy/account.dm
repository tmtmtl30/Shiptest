/datum/bank_account
	var/account_holder = "Rusty Venture"
	var/account_balance = 0
	var/list/bank_cards = list()
	var/add_to_accounts = TRUE
	var/account_id

// "owner_name" is used in several spots. "owner_ref" is used purely for logging
/datum/bank_account/New(start_balance = 0, owner_name, owner_ref)
	if(add_to_accounts)
		SSeconomy.bank_accounts += src
	account_balance = start_balance
	account_holder = owner_name
	account_id = rand(111111,999999)

	format_log_econ(ECON_LOG_EVENT_ACCOUNT_CREATED, list(
		"ACCOUNT_ID" = account_id,
		"REF" = REF(src),
		"TYPE" = type,
		"TOTAL" = account_balance,
		"HOLDER_REF" = owner_ref,
		"HOLDER_NAME" = account_holder,
	))

/datum/bank_account/Destroy()
	if(add_to_accounts)
		SSeconomy.bank_accounts -= src
	for(var/obj/item/card/id/id_card as anything in bank_cards)
		id_card.registered_account = null
	return ..()

/// Returns whether the account has greater than or equal to the passed amount of credits.
/datum/bank_account/proc/has_money(amt)
	return account_balance >= amt

/// Internal account adjustment proc, used by the wrappers.
/// Do not call directly, as it lacks logging!
/datum/bank_account/proc/_adjust_money(amt)
	PRIVATE_PROC(TRUE)
	account_balance += amt
	if(account_balance < 0)
		account_balance = 0

/// Public-facing proc for generic account value adjustment.
/// Before using this, consider if transfer_money(), absorb_cash(), or create_holochip()
/// fit your use case, as these have more detailed logging.
/datum/bank_account/proc/adjust_money(amt, source)
	if((amt < 0 && has_money(-amt)) || amt > 0)
		_adjust_money(amt)
		format_log_econ(ECON_LOG_EVENT_ACCOUNT_UPDATED, list(
			"REF" = REF(src),
			"AMOUNT" = amt,
			"NEW_TOTAL" = account_balance,
			"SOURCE" = source
		))
		return TRUE
	return FALSE

/// Public-facing wrapper proc for direct balance transfers between bank accounts.
/// Transfers amount credits from the passed account to this account.
/datum/bank_account/proc/transfer_money(datum/bank_account/from, amount, source)
	if(from.has_money(amount))
		_adjust_money(amount)
		from._adjust_money(-amount)

		format_log_econ(ECON_LOG_EVENT_ACCOUNT_TRANSFER, list(
			"AMOUNT" = amount,
			"TO_REF" = REF(src),
			"NEW_TOTAL_TO" = src.account_balance,
			"FROM_REF" = REF(from),
			"NEW_TOTAL_FROM" = from.account_balance,
			"SOURCE" = source
		))
		return TRUE
	return FALSE

/// Wrapper proc for adding the money contained by space cash, a holochip, or another value-containing item to the account.
/// Will return FALSE if the item does not have an associated value per get_item_credit_value().
/// Otherwise, returns the number of credits added, and qdeletes the item unless qdel_after is set to FALSE.
/datum/bank_account/proc/absorb_cash(obj/item/money_item, qdel_after = TRUE)
	var/item_value = money_item.get_item_credit_value()
	if(!item_value)
		return FALSE

	_adjust_money(item_value)
	format_log_econ(ECON_LOG_EVENT_ACCOUNT_ABSORB, list(
		"ACCOUNT_REF" = REF(src),
		"ITEM_REF" = REF(money_item),
		"ITEM_TYPE" = money_item.type,
		"AMOUNT" = item_value,
		"NEW_TOTAL" = account_balance,
	))

	if(qdel_after)
		qdel(money_item)
	return item_value

/// Using money from this account, creates a holochip at the given location with the specified amount of funds.
/// If the funds are unavailable or the amount passed is invalid (it's <= 0), nothing is deducted or created and the proc returns FALSE.
/// Otherwise, the holochip is created, money is deducted from this account, and a reference to the chip is returned.
/datum/bank_account/proc/create_holochip(location, amount)
	if(!has_money(amount) || amount <= 0)
		return FALSE
	_adjust_money(-amount)

	var/obj/item/money_stack/holochip/holochip = new(location, amount)
	format_log_econ(ECON_LOG_EVENT_ACCOUNT_CREATECHIP, list(
		"ACCOUNT_REF" = REF(src),
		"ITEM_REF" = REF(holochip),
		"AMOUNT" = amount,
		"NEW_TOTAL" = account_balance
	))
	return holochip

/datum/bank_account/proc/bank_card_talk(message, force)
	if(!message || !bank_cards.len)
		return
	for(var/obj/A in bank_cards)
		var/icon_source = A
		if(istype(A, /obj/item/card/id))
			var/obj/item/card/id/id_card = A
			if(id_card.uses_overlays)
				icon_source = id_card.get_cached_flat_icon()
		var/mob/card_holder = recursive_loc_check(A, /mob)
		if(ismob(card_holder)) //If on a mob
			if(!card_holder.client || (!(card_holder.client.prefs.chat_toggles & CHAT_BANKCARD) && !force))
				return

			if(card_holder.can_hear())
				card_holder.playsound_local(get_turf(card_holder), 'sound/machines/twobeep_high.ogg', 50, TRUE)
				to_chat(card_holder, "[icon2html(icon_source, card_holder)] <span class='notice'>[message]</span>")
		else if(isturf(A.loc)) //If on the ground
			var/turf/T = A.loc
			for(var/mob/M in hearers(1,T))
				if(!M.client || (!(M.client.prefs.chat_toggles & CHAT_BANKCARD) && !force))
					continue
				if(M.can_hear())
					M.playsound_local(T, 'sound/machines/twobeep_high.ogg', 50, TRUE)
					to_chat(M, "[icon2html(icon_source, M)] <span class='notice'>[message]</span>")
		else
			var/atom/sound_atom
			for(var/mob/M in A.loc) //If inside a container with other mobs (e.g. locker)
				if(!M.client || (!(M.client.prefs.chat_toggles & CHAT_BANKCARD) && !force))
					continue
				if(!sound_atom)
					sound_atom = A.drop_location() //in case we're inside a bodybag in a crate or something. doing this here to only process it if there's a valid mob who can hear the sound.
				if(M.can_hear())
					M.playsound_local(get_turf(sound_atom), 'sound/machines/twobeep_high.ogg', 50, TRUE)
					to_chat(M, "[icon2html(icon_source, M)] <span class='notice'>[message]</span>")

/datum/bank_account/ship
	add_to_accounts = FALSE

