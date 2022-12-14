/datum/job/command/tank_crew
	title = JOB_CREWMAN
	total_positions = 1
	spawn_positions = 1
	flags_startup_parameters = ROLE_ADD_TO_DEFAULT|ROLE_ADD_TO_MODE
	gear_preset = "USCM Vehicle Crewman (CRMN) (Cryo)"
	entry_message_body = "Your job is to operate and maintain the ship's armored vehicles. You are in charge of representing the armored presence amongst the marines during the operation, as well as maintaining and repairing your own tank."

AddTimelock(/datum/job/command/tank_crew, list(
	JOB_SQUAD_ROLES = 10 HOURS,
	JOB_ENGINEER_ROLES = 5 HOURS
))

/obj/effect/landmark/start/tank_crew
	name = JOB_CREWMAN
	job = /datum/job/command/tank_crew
