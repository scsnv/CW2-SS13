/datum/caste_datum/lurker
	caste_type = XENO_CASTE_LURKER
	display_icon = XENO_CASTE_LURKER
	display_name = XENO_CASTE_LURKER
	tier = 2

	melee_damage_lower = XENO_DAMAGE_TIER_4
	melee_damage_upper = XENO_DAMAGE_TIER_4
	max_health = XENO_HEALTH_TIER_5
	plasma_gain = XENO_PLASMA_GAIN_TIER_8
	plasma_max = XENO_PLASMA_TIER_4
	xeno_explosion_resistance = XENO_EXPLOSIVE_ARMOR_TIER_2

	evasion = XENO_EVASION_NONE
	speed = XENO_SPEED_TIER_8

	attack_delay = 2 // VERY high slash damage, but attacks relatively slowly

	behavior_delegate_type = /datum/behavior_delegate/lurker_base

	deevolves_to = XENO_CASTE_RUNNER
	caste_desc = "A fast, powerful backline combatant."
	evolves_to = list(XENO_CASTE_RAVAGER)

	heal_resting = 1.5

/mob/living/carbon/Xenomorph/Lurker
	caste_type = XENO_CASTE_LURKER
	name = XENO_CASTE_LURKER
	desc = "A beefy, fast alien with sharp claws."
	icon_size = 48
	icon_state = "Lurker Walking"
	plasma_types = list(PLASMA_CATECHOLAMINE)
	pixel_x = -12
	old_x = -12
	tier = 2
	base_actions = list(
		/datum/action/xeno_action/onclick/xeno_resting,
		/datum/action/xeno_action/onclick/regurgitate,
		/datum/action/xeno_action/watch_xeno,
		/datum/action/xeno_action/activable/pounce/lurker,
		/datum/action/xeno_action/onclick/lurker_invisibility,
		/datum/action/xeno_action/onclick/lurker_assassinate
		)
	inherent_verbs = list(
		/mob/living/carbon/Xenomorph/proc/vent_crawl,
		)
	mutation_type = LURKER_NORMAL
	claw_type = CLAW_TYPE_SHARP

	tackle_min = 2
	tackle_max = 6

	var/linger_range = 5
	var/linger_deviation = 0

/datum/behavior_delegate/lurker_base
	name = "Base Lurker Behavior Delegate"

	// Config
	var/invis_recharge_time = 150      // 15 seconds to recharge invisibility.
	var/invis_start_time = -1 // Special value for when we're not invisible
	var/invis_duration = 300  // so we can display how long the lurker is invisible to it
	var/buffed_slash_damage_ratio = 1.2
	var/slash_slow_duration = 35

	// State
	var/next_slash_buffed = FALSE
	var/can_go_invisible = TRUE

/datum/behavior_delegate/lurker_base/melee_attack_modify_damage(original_damage, atom/A = null)
	if (!isXenoOrHuman(A))
		return original_damage

	var/mob/living/carbon/H = A
	if (next_slash_buffed)
		to_chat(bound_xeno, SPAN_XENOHIGHDANGER("You significantly strengthen your attack, slowing [H]!"))
		to_chat(H, SPAN_XENOHIGHDANGER("You feel a sharp pain as [bound_xeno] slashes you, slowing you down!"))
		original_damage *= buffed_slash_damage_ratio
		H.SetSuperslowed(get_xeno_stun_duration(H, 3))
		next_slash_buffed = FALSE

	return original_damage

/datum/behavior_delegate/lurker_base/melee_attack_additional_effects_target(atom/A)
	if (!isXenoOrHuman(A))
		return

	var/mob/living/carbon/H = A
	if (H.knocked_down)
		new /datum/effects/xeno_slow(H, bound_xeno, null, null, get_xeno_stun_duration(slash_slow_duration))

	return

/datum/behavior_delegate/lurker_base/melee_attack_additional_effects_self()
	..()

	var/datum/action/xeno_action/onclick/lurker_invisibility/LIA = get_xeno_action_by_type(bound_xeno, /datum/action/xeno_action/onclick/lurker_invisibility)
	if (LIA && istype(LIA))
		LIA.invisibility_off()

// What to do when we go invisible
/datum/behavior_delegate/lurker_base/proc/on_invisibility()
	var/datum/action/xeno_action/activable/pounce/lurker/LPA = get_xeno_action_by_type(bound_xeno, /datum/action/xeno_action/activable/pounce/lurker)
	if (LPA && istype(LPA))
		LPA.knockdown = TRUE // pounce knocks down
		LPA.freeze_self = TRUE
	can_go_invisible = FALSE
	invis_start_time = world.time

/datum/behavior_delegate/lurker_base/proc/on_invisibility_off()
	var/datum/action/xeno_action/activable/pounce/lurker/LPA = get_xeno_action_by_type(bound_xeno, /datum/action/xeno_action/activable/pounce/lurker)
	if (LPA && istype(LPA))
		LPA.knockdown = FALSE // pounce no longer knocks down
		LPA.freeze_self = FALSE

	// SLIGHTLY hacky because we need to maintain lots of other state on the lurker
	// whenever invisibility is on/off CD and when it's active.
	addtimer(CALLBACK(src, .proc/regen_invisibility), invis_recharge_time)

	invis_start_time = -1

/datum/behavior_delegate/lurker_base/proc/regen_invisibility()
	if (can_go_invisible)
		return

	can_go_invisible = TRUE
	if(bound_xeno)
		var/datum/action/xeno_action/onclick/lurker_invisibility/LIA = get_xeno_action_by_type(bound_xeno, /datum/action/xeno_action/onclick/lurker_invisibility)
		if(LIA && istype(LIA))
			LIA.end_cooldown()

/datum/behavior_delegate/lurker_base/append_to_stat()
	. = list()
	var/invis_message = (invis_start_time == -1) ? "N/A" : "[(invis_duration-(world.time - invis_start_time))/10] seconds."
	. += "Invisibility Time Left: [invis_message]"

/mob/living/carbon/Xenomorph/Lurker/init_movement_handler()
	var/datum/xeno_ai_movement/linger/L = new(src)
	L.linger_range = linger_range
	L.linger_deviation = linger_deviation
	return L

/mob/living/carbon/Xenomorph/Lurker/process_ai(delta_time, game_evaluation)
	zone_selected = pick(GLOB.ai_target_limbs)
	return ..()
