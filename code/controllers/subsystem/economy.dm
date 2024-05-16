SUBSYSTEM_DEF(economy)
	name = "Economy"
	init_order = INIT_ORDER_ECONOMY
	flags = SS_NO_FIRE
	runlevels = RUNLEVEL_GAME

	///List of normal accounts (not ship accounts)
	var/list/bank_accounts = list()
	///Total amount of physical money in the game
	var/physical_money = 0
	///Total amount of money in bank accounts
	var/bank_money = 0

/datum/controller/subsystem/economy/stat_entry(msg)
	msg += "{"
	msg += "PH: [physical_money]|"
	msg += "BN: [bank_money]|"
	msg += "TOT: [physical_money + bank_money]"
	msg += "}"
	return ..()

// Logged on bank account creation
#define ECON_LOG_EVENT_ACCOUNT_CREATED "ACCOUNT_CREATED"
// Used to log direct, account-to-account money transfer.
#define ECON_LOG_EVENT_ACCOUNT_TRANSFER "ACCOUNT_TRANSFER"
// Used to log generic transfers of money to or from an account.
#define ECON_LOG_EVENT_ACCOUNT_UPDATED "ACCOUNT_UPDATED"
// Used to log adding money to an account via cash
#define ECON_LOG_EVENT_ACCOUNT_ABSORB "ACCOUNT_ABSORB"
// Used to log removal of money from an account via the creation of holochips.
#define ECON_LOG_EVENT_ACCOUNT_CREATECHIP "ACCOUNT_CREATECHIP"



// logged when a mission is accepted
#define ECON_LOG_EVENT_MISSION_ACCEPTED "MISSION_ACCEPTED"
// logged when a mission is turned-in on time
#define ECON_LOG_EVENT_MISSION_TURNEDIN "MISSION_TURNEDIN"
