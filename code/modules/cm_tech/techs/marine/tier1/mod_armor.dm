/datum/tech/droppod/item/modular_armor_upgrade
	name = "Modular Armor Upgrade Kits"
	desc = {"Marines get access to plates they can put in their uniforms that act as temporary\
			HP. Ceramic plates will have higher temp HP, but break after 1 use; metal plates\
			break into scrap that can be combined to form improvised plates that are almost\
			as good."}
	icon_state = "combat_plates"
	droppod_name = "Armor Plates"

	flags = TREE_FLAG_MARINE

	required_points = 10
	tier = /datum/tier/one

	droppod_input_message = "Choose a plate to retrieve from the droppod."

/datum/tech/droppod/item/modular_armor_upgrade/get_options(mob/living/carbon/human/H, obj/structure/droppod/D)
	. = ..()

	//.["Ceramic Plate"] = /obj/item/clothing/accessory/health/ceramic
	.["Metal Plate"] = /obj/item/clothing/accessory/health/metal

/obj/item/clothing/accessory/health
	name = "abstract plate"
	desc = "This is an abstract item. If you are seeing this, tell a dev"

	icon = 'icons/obj/items/items.dmi'
	var/base_icon_state
	icon_state = "regular"

	slot = ACCESSORY_SLOT_ARMOR_C
	var/armor_health = 10
	var/armor_maxhealth = 10

	var/next_regeneration = 0
	var/no_damage_period = 5 SECONDS
	var/regeneration_per_second = AMOUNT_PER_TIME(10, 10 SECONDS)

	var/take_slash_damage = TRUE
	var/generic_damage_mult = 0.25
	var/slash_durability_mult = 0.25
	var/projectile_durability_mult = 0.1

	var/list/health_states = list(
		0,
		50,
		100
	)

	var/armor_hitsound = 'sound/effects/metalhit.ogg'
	var/armor_shattersound = 'sound/effects/metal_shatter.ogg'

/obj/item/clothing/accessory/health/Initialize(mapload, ...)
	base_icon_state = icon_state
	. = ..()

	update_icon()

/obj/item/clothing/accessory/health/update_icon()
	for(var/health_state in health_states)
		if((armor_health/armor_maxhealth) <= (health_state*0.01))
			icon_state = "[base_icon_state]_[health_state]"
			return

/obj/item/clothing/accessory/health/examine(mob/user)
	. = ..()
	if(armor_health >= armor_maxhealth)
		to_chat(user, SPAN_NOTICE("It is in pristine condition."))
	else if(armor_health >= armor_maxhealth*0.8)
		to_chat(user, SPAN_NOTICE("It is slightly damaged."))
	else if(armor_health >= armor_maxhealth*0.5)
		to_chat(user, SPAN_NOTICE("It is moderately damaged."))
	else if(armor_health >= armor_maxhealth*0.2)
		to_chat(user, SPAN_NOTICE("It is seriously damaged."))
	else if(armor_health > 0)
		to_chat(user, SPAN_NOTICE("It is falling apart!"))
	else
		to_chat(user, SPAN_NOTICE("It is broken."))

/obj/item/clothing/accessory/health/on_attached(obj/item/clothing/S, mob/living/user)
	. = ..()
	if(!.)
		return

	RegisterSignal(S, COMSIG_ITEM_EQUIPPED, .proc/check_to_signal)
	RegisterSignal(S, COMSIG_ITEM_DROPPED, .proc/unassign_signals)

	var/mob/living/carbon/human/H = user
	if(istype(H) && H.w_uniform == S)
		check_to_signal(S, user, WEAR_BODY)

	if(user)
		to_chat(user, SPAN_NOTICE("You attach [src] to [has_suit]."))

/obj/item/clothing/accessory/health/proc/check_to_signal(obj/item/clothing/S, mob/living/user, slot)
	SIGNAL_HANDLER

	if(slot == WEAR_BODY)
		if(take_slash_damage)
			RegisterSignal(user, COMSIG_HUMAN_XENO_ATTACK, .proc/take_slash_damage)
		RegisterSignal(user, COMSIG_HUMAN_BULLET_ACT, .proc/take_bullet_damage)
		RegisterSignal(user, COMSIG_HUMAN_TAKE_DAMAGE, .proc/take_damage_signal)
		RegisterSignal(user, COMSIG_HUMAN_MED_HUD_SET_HEALTH, .proc/update_med_hud)
	else
		unassign_signals(S, user)

/obj/item/clothing/accessory/health/proc/update_med_hud(var/mob/living/carbon/human/H)
	SIGNAL_HANDLER
	var/image/holder = H.hud_list[SHIELD_HUD]
	var/percentage = round((armor_health/armor_maxhealth)*100, 10)
	holder.icon_state = "hudshield[percentage]"

/obj/item/clothing/accessory/health/proc/unassign_signals(obj/item/clothing/S, mob/living/user)
	SIGNAL_HANDLER

	UnregisterSignal(user, list(
		COMSIG_HUMAN_XENO_ATTACK,
		COMSIG_HUMAN_BULLET_ACT,
		COMSIG_HUMAN_MED_HUD_SET_HEALTH
	))

	var/image/holder = user.hud_list[SHIELD_HUD]
	holder.icon_state = "hudblank"

/obj/item/clothing/accessory/health/process(delta_time)
	if(next_regeneration > world.time)
		return

	armor_health = min(armor_health + regeneration_per_second*delta_time, armor_maxhealth)
	update_icon()

	if(armor_health >= armor_maxhealth)
		return PROCESS_KILL


/obj/item/clothing/accessory/health/proc/take_bullet_damage(mob/living/user, damage, ammo_flags)
	SIGNAL_HANDLER
	if(damage <= 0 || (ammo_flags & AMMO_IGNORE_ARMOR))
		return

	if(take_damage(user, damage, projectile_durability_mult))
		return COMPONENT_CANCEL_BULLET_ACT

/obj/item/clothing/accessory/health/proc/take_slash_damage(mob/living/user, damage)
	SIGNAL_HANDLER
	if(take_damage(user, damage, slash_durability_mult))
		return COMPONENT_CANCEL_XENO_ATTACK

/obj/item/clothing/accessory/health/proc/take_damage_signal(mob/living/user, var/list/damage)
	SIGNAL_HANDLER
	if(damage["damage"] <= 0)
		return

	if(take_damage(user, damage["damage"]))
		return COMPONENT_BLOCK_DAMAGE

/obj/item/clothing/accessory/health/proc/take_damage(mob/living/user, damage, damage_mult = src.generic_damage_mult)
	var/damage_to_nullify = armor_health
	armor_health = max(armor_health - damage*damage_mult, 0)

	update_icon()
	if(!armor_health && damage_to_nullify)
		user.show_message(SPAN_WARNING("You feel [src] break apart."), null, null, null, CHAT_TYPE_ARMOR_DAMAGE)
		playsound(user, armor_shattersound, 35, 1)

	next_regeneration = world.time + no_damage_period
	START_PROCESSING(SSobj, src)

	if(damage_to_nullify)
		playsound(user, armor_hitsound, 25, 1)
		return TRUE

/obj/item/clothing/accessory/health/on_removed(mob/living/user, obj/item/clothing/C)
	if(!has_suit)
		return

	unassign_signals(C, user)

	UnregisterSignal(C, list(
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED
	))


	has_suit = null
	if(usr)
		usr.put_in_hands(src)
	else
		src.forceMove(get_turf(src))

/obj/item/clothing/accessory/health/ceramic
	name = "ceramic plate"
	desc = "A very strong and durable plate, stronger than the kevlar and metal variations. Able to resist a lot of damage before breaking. Takes longer to regenerate. Attach it to a uniform to use."

	icon_state = "ceramic2"

	armor_health = 100
	armor_maxhealth = 100
	regeneration_per_second = AMOUNT_PER_TIME(10, 15 SECONDS)

	armor_shattersound = 'sound/effects/ceramic_shatter.ogg'

/obj/item/clothing/accessory/health/kevlar
	name = "kevlar plate"
	desc = "A very durable plate, able to absorb a lot of damage before breaking. Attach it to a uniform to use."
	icon_state = "regular2"
	armor_health = 40
	armor_maxhealth = 40

/obj/item/clothing/accessory/health/metal
	name = "metal plate"
	desc = "A durable plate, able to absorb a lot of damage. Attach it to a uniform to use."
	icon_state = "regular"

	armor_health = 25
	armor_maxhealth = 25

/obj/item/clothing/accessory/health/scrap
	name = "scrap metal"
	desc = "A weak plate, only able to protect from a little bit of damage. Attach it to a uniform to use."

	icon_state = "scrap"
	health_states = list(
		0,
		100
	)

	armor_health = 15
	armor_maxhealth = 15
