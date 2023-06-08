GLOBAL_VAR_INIT(ship_spawn_enabled, TRUE)

/client/proc/toggle_ship_spawn()
	set name = "Toggle Ship Spawn"
	set category = "Admin"
	set desc = "Toggles the ability of players to create ships via the roundstart screen or shuttle creator."

	if(!holder)
		to_chat(src, "Only administrators may use this command.", confidential = TRUE)
		return
	if(check_rights(R_ADMIN, 1))
		GLOB.ship_spawn_enabled ^= TRUE
		var/message
		if(GLOB.ship_spawn_enabled)
			message = "[key_name_admin(usr)] enabled player ship spawning."
		else
			message = "[key_name_admin(usr)] disabled player ship spawning."
		message_admins(message)
		log_game(message)
