#define ACCOUNT_CIV "CIV"
#define ACCOUNT_CIV_NAME "Civil Budget"
#define ACCOUNT_ENG "ENG"
#define ACCOUNT_ENG_NAME "Engineering Budget"
#define ACCOUNT_SCI "SCI"
#define ACCOUNT_SCI_NAME "Scientific Budget"
#define ACCOUNT_MED "MED"
#define ACCOUNT_MED_NAME "Medical Budget"
#define ACCOUNT_SRV "SRV"
#define ACCOUNT_SRV_NAME "Service Budget"
#define ACCOUNT_CAR "CAR"
#define ACCOUNT_CAR_NAME "Cargo Budget"
#define ACCOUNT_SEC "SEC"
#define ACCOUNT_SEC_NAME "Defense Budget"

#define NO_FREEBIES "commies go home"

#warn make sure all of these are actually used
// Logged when a player spawns onto a ship, so that per-ship finances can be tracked.
#define ECON_LOG_EVENT_PLAYER_SHIP_SPAWN "PLAYER_SHIP_SPAWN"

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

// Logged when physical money (holochips or space cash) initializes
#define ECON_LOG_EVENT_MONEY_CREATED "MONEY_CREATED"
// Logged when physical money (holochips / space cash) is merged with another -- i.e., combining two holochips
#define ECON_LOG_EVENT_MONEY_MERGED "MONEY_MERGED"
// Logged when physical money (holochips / space cash) is split -- i.e., taking part of the value of a holochip out into a second chip.
#define ECON_LOG_EVENT_MONEY_SPLIT "MONEY_SPLIT"

// logged when a mission is accepted
#define ECON_LOG_EVENT_MISSION_ACCEPTED "MISSION_ACCEPTED"
// logged when a mission is turned-in on time
#define ECON_LOG_EVENT_MISSION_TURNEDIN "MISSION_TURNEDIN"

// logged when an account purchases something (cargo, vending machines)
#define ECON_LOG_EVENT_ACCOUNT_PURCHASE "ACCOUNT_PURCHASE"
// logged when a mob purchases something (think black markets -- note that this is much harder to fully track)
#define ECON_LOG_EVENT_PERSONAL_PURCHASE "PERSONAL_PURCHASE"

