
/obj/item/proc/get_item_credit_value()
	return

#warn double-check money and account value change order-of-operations
#warn for each type, document the conditions under which it should be logged, and the correct order of operations!
#warn make an event for account deletion?
#warn think about sanitizing text / checking types in-proc; would help with consistency later
#warn personal stuff might need a second look
/datum/econ_log_event

/datum/econ_log_event/New(list/fields)
	SHOULD_CALL_PARENT(TRUE)

	var/dat_list = list()
	for(var/field in fields)
		dat_list += "[field]: [fields[field]]"

	log_econ("[type]; [jointext(dat_list, ", ")]")
	. = ..()

/datum/econ_log_event/mission_accepted/New(datum/mission/miss)
	..(list(
		"MISSION_REF" = REF(miss),
		"TYPE" = miss.type,
		"PAYOUT" = miss.value,
		"DURATION" = miss.duration,
		"ACCEPTING_SHIP" = REF(miss.servant)
	))

/datum/econ_log_event/mission_turnedin/New(datum/mission/miss)
	..(list(
		"MISSION_REF" = REF(miss),
		"PAYOUT" = miss.value,
		"TIME_REMAINING" = timeleft(miss.dur_timer)
	))


/datum/econ_log_event/money_created/New(obj/item/money_stack/money)
	..(list(
		"REF" = REF(money),
		"TYPE" = money.type,
		"TURF" = AREACOORD(money),
		"VALUE" = money.get_item_credit_value()
	))

/datum/econ_log_event/money_deleted/New(obj/item/money_stack/money)
	..(list(
		"REF" = REF(money),
		"VALUE" = money.get_item_credit_value()
	))

/// Should be logged after the value has been adjusted!
/datum/econ_log_event/money_altered/New(obj/item/money_stack/money)
	..(list(
		"REF" = REF(money),
		"VALUE" = money.get_item_credit_value()
	))

/// Should be logged AFTER the child has been created with its value and the source has had its value adjusted.
/datum/econ_log_event/money_split/New(obj/item/money_stack/source_money, obj/item/money_stack/child_money)
	..(list(
		"SOURCE_REF" = REF(source_money),
		"CHILD_REF" = REF(child_money),
		"SOURCE_VALUE" = source_money.get_item_credit_value()
	))

/// Should be logged AFTER the value has been added to the eater, but before the eaten has been qdeleted.
/datum/econ_log_event/money_merged/New(obj/item/money_stack/eater, obj/item/money_stack/eaten)
	..(list(
		"EATER_REF" = REF(eater),
		"EATEN_REF" = REF(eaten),
		"EATER_VALUE" = eater.get_item_credit_value()
	))


/datum/econ_log_event/player_ship_spawn/New(mob/char, datum/overmap/ship/controlled/spawn_ship)
	..(list(
		"CHARACTER_REF" = REF(char),
		"SHIP_REF" = REF(spawn_ship)
	))


/// Should be logged after the balance of the account has been set, along with the name of its holder.
/datum/econ_log_event/account_created/New(datum/bank_account/acc, holder)
	..(list(
		"REF" = REF(acc),
		"TYPE" = acc.type,
		"ACCOUNT_ID" = acc.account_id,
		"TOTAL" = acc.account_balance,
		"HOLDER_REF" = REF(holder)
	))

/// Should be logged after the account has had its balance updated.
/datum/econ_log_event/account_updated/New(datum/bank_account/acc, source)
	..(list(
		"REF" = REF(acc),
		"TOTAL" = acc.account_balance,
		"SOURCE" = source
	))

/// Should be logged after both accounts have updated their balances.
/datum/econ_log_event/account_transfer/New(datum/bank_account/to_acc, datum/bank_account/from_acc, source)
	..(list(
		"TO_REF" = REF(to_acc),
		"TO_TOTAL" = to_acc.account_balance,
		"FROM_REF" = REF(from_acc),
		"FROM_TOTAL" = from_acc.account_balance,
		"SOURCE" = source
	))

/datum/econ_log_event/account_absorb/New(datum/bank_account/acc, obj/item/money_stack/money)
	..(list(
		"ACCOUNT_REF" = REF(acc),
		"ITEM_REF" = REF(money),
		"ACCOUNT_TOTAL" = acc.account_balance
	))

/datum/econ_log_event/account_createchip/New(datum/bank_account/acc, obj/item/money_stack/money)
	..(list(
		"ACCOUNT_REF" = REF(acc),
		"ITEM_REF" = REF(money),
		"ACCOUNT_TOTAL" = REF(acc)
	))

/datum/econ_log_event/account_purchase/New(datum/bank_account/acc, purchase_type, price)
	..(list(
		"REF" = REF(acc),
		"PURCHASE_TYPE" = purchase_type,
		"PRICE" = price
	))


/datum/econ_log_event/personal_insert/New(mob/char, atom/target, obj/item/money_stack/insert_item)
	..(list(
		"MOB" = REF(char),
		"TARGET" = REF(target),
		"TARGET_TYPE" = target.type,
		"INSERT_ITEM" = REF(insert_item),
		"INSERT_VALUE" = insert_item.get_item_credit_value()
	))

/datum/econ_log_event/personal_withdraw/New(mob/char, atom/target, obj/item/money_stack/withdraw_item)
	..(list(
		"MOB" = REF(char),
		"TARGET" = REF(target),
		"TARGET_TYPE" = target.type,
		"WITHDRAW_ITEM" = REF(withdraw_item),
		"WITHDRAW_VALUE" = withdraw_item.get_item_credit_value()
	))

/datum/econ_log_event/personal_purchase/New(mob/char, atom/target, purchase_type, price)
	..(list(
		"MOB" = REF(char),
		"TARGET" = REF(target),
		"TARGET_TYPE" = target.type,
		"PURCHASE_TYPE" = purchase_type,
		"PRICE" = price
	))
