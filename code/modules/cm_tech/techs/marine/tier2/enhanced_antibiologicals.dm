/datum/tech/droppod/item/enhanced_antibiologicals
	name = "Enhanced Antibiologicals"
	desc = "Marines get access to limited-use kits that can convert ammo magazines into the specified ammo."
	icon_state = "ammo"
	droppod_name = "Ammo Kits"
	flags = TREE_FLAG_MARINE

	required_points = 25
	tier = /datum/tier/two

	droppod_input_message = "Choose an ammo kit to retrieve from the droppod."

/datum/tech/droppod/item/enhanced_antibiologicals/get_options(mob/living/carbon/human/H, obj/structure/droppod/D)
	. = ..()

	.["Incendiary Buckshot Kit"] = /obj/item/storage/box/shotgun/buckshot
	.["Incendiary Slug Kit"] = /obj/item/storage/box/shotgun/slug
	.["Incendiary Ammo Kit"] = /obj/item/ammo_kit/incendiary
	.["Wall-Piercing Ammo Kit"] = /obj/item/ammo_kit/penetrating
	.["Toxin Ammo Kit"] = /obj/item/ammo_kit/toxin

/obj/item/ammo_kit
	name = "ammo kit"
	icon = 'icons/obj/items/devices.dmi'
	desc = "An ammo kit used to produce ammunition for a weapon."
	icon_state = "kit_generic"

	var/list/convert_map
	var/uses = 5

/obj/item/ammo_kit/Initialize(mapload, ...)
	. = ..()
	convert_map = get_convert_map()

/obj/item/ammo_kit/examine(mob/user)
	. = ..()
	to_chat(user, SPAN_NOTICE("It has [uses] uses remaining."))

/obj/item/ammo_kit/afterattack(atom/target, mob/living/user, proximity_flag, click_parameters)
	if(uses <= 0)
		return ..()

	if(!isitem(target))
		return ..()

	var/amount_to_spawn = 1
	var/type_to_convert_to
	if(isgun(target))
		var/obj/item/weapon/gun/G = target
		var/list/L = G.base_magazines
		if(!length(L))
			return ..()

		if(length(L) == 1)
			type_to_convert_to = L[1]
		else
			var/list/mapping = list()
			for(var/i in L)
				var/atom/A = i
				mapping[initial(A.name)] = i

			type_to_convert_to = tgui_input_list(user, "Select ammo type to retrieve", name, mapping)
			if(uses <= 0 || QDELETED(src) || !type_to_convert_to)
				return ..()

			type_to_convert_to = mapping[type_to_convert_to]

		if(type_to_convert_to in convert_map)
			type_to_convert_to = convert_map[type_to_convert_to]

		amount_to_spawn = G.mags_to_spawn
	else
		if(!(target.type in convert_map))
			return ..()

		if(istype(target, /obj/item/ammo_magazine))
			var/obj/item/ammo_magazine/M = target
			if(M.current_rounds < M.max_rounds)
				to_chat(user, SPAN_WARNING("The magazine needs to be full for you to apply this kit onto it."))
				return

		if(user.l_hand != target && user.r_hand != target)
			to_chat(user, SPAN_WARNING("The object needs to be in your hands for you to apply this kit onto it."))
			return

		type_to_convert_to = convert_map[target.type]
		user.drop_held_item(target)
		QDEL_NULL(target)

	for(var/i in 1 to amount_to_spawn)
		var/obj/M = new type_to_convert_to(get_turf(user))
		user.put_in_any_hand_if_possible(M)
	uses -= 1
	playsound(get_turf(user), "sound/machines/fax.ogg", 5)

	if(uses <= 0)
		user.drop_held_item(src)
		qdel(src)

/obj/item/ammo_kit/proc/get_convert_map()
	return list()

/obj/item/ammo_kit/normal
	name = "regular ammo kit"
	icon_state = "kit_generic"

/obj/item/ammo_kit/incendiary
	name = "incendiary ammo kit"
	icon_state = "kit_incendiary"

/obj/item/ammo_kit/incendiary/get_convert_map()
	. = ..()
	.[/obj/item/ammo_magazine/smg/m39] = /obj/item/ammo_magazine/smg/m39/incendiary
	.[/obj/item/ammo_magazine/rifle] = /obj/item/ammo_magazine/rifle/incendiary
	.[/obj/item/ammo_magazine/rifle/l42a] = /obj/item/ammo_magazine/rifle/l42a/incendiary
	.[/obj/item/ammo_magazine/rifle/m41aMK1] = /obj/item/ammo_magazine/rifle/m41aMK1/incendiary
	.[/obj/item/ammo_magazine/pistol] =  /obj/item/ammo_magazine/pistol/incendiary
	.[/obj/item/ammo_magazine/pistol/vp78] =  /obj/item/ammo_magazine/pistol/vp78/incendiary
	.[/obj/item/ammo_magazine/pistol/mod88] =  /obj/item/ammo_magazine/pistol/mod88/incendiary
	.[/obj/item/ammo_magazine/revolver] =  /obj/item/ammo_magazine/revolver/incendiary
	.[/obj/item/ammo_magazine/handful/shotgun/buckshot] =  /obj/item/ammo_magazine/handful/shotgun/custom_color/incendiary
	.[/obj/item/ammo_magazine/handful/shotgun/slug] =  /obj/item/ammo_magazine/handful/shotgun/incendiary
	.[/obj/item/ammo_magazine/rocket] = /obj/item/ammo_magazine/rocket/wp
	.[/obj/item/ammo_magazine/rifle/m4ra] = /obj/item/ammo_magazine/rifle/m4ra/incendiary


/obj/item/storage/box/shotgun
	name = "incendiary shotgun kit"
	desc = "A kit containing incendiary shotgun shells."
	icon_state = "incenbuck"
	storage_slots = 5
	var/amount = 5
	var/to_hold

/obj/item/storage/box/shotgun/fill_preset_inventory()
	if(to_hold)
		for(var/i in 1 to amount)
			new to_hold(src)

/obj/item/storage/box/shotgun/buckshot
	name = "incendiary buckshot kit"
	desc = "A box containing 5 handfuls of incendiary buckshot."
	can_hold = list(
		/obj/item/ammo_magazine/handful/shotgun/custom_color/incendiary
	)
	to_hold = /obj/item/ammo_magazine/handful/shotgun/custom_color/incendiary

/obj/item/storage/box/shotgun/slug
	name = "incendiary slug kit"
	desc = "A box containing 5 handfuls of incendiary slugs."
	icon_state = "incenslug"
	can_hold = list(
		/obj/item/ammo_magazine/handful/shotgun/incendiary
	)
	to_hold = /obj/item/ammo_magazine/handful/shotgun/incendiary

/obj/item/ammo_kit/penetrating
	name = "wall-piercing ammo kit"
	icon_state = "kit_penetrating"
	desc = "Converts magazines into wall-piercing ammo."

/obj/item/ammo_kit/penetrating/get_convert_map()
	. = ..()
	.[/obj/item/ammo_magazine/smg/m39] = /obj/item/ammo_magazine/smg/m39/penetrating
	.[/obj/item/ammo_magazine/rifle] = /obj/item/ammo_magazine/rifle/penetrating
	.[/obj/item/ammo_magazine/rifle/l42a] = /obj/item/ammo_magazine/rifle/l42a/penetrating
	.[/obj/item/ammo_magazine/rifle/m41aMK1] = /obj/item/ammo_magazine/rifle/m41aMK1/penetrating
	.[/obj/item/ammo_magazine/pistol] =  /obj/item/ammo_magazine/pistol/penetrating
	.[/obj/item/ammo_magazine/pistol/vp78] =  /obj/item/ammo_magazine/pistol/vp78/penetrating
	.[/obj/item/ammo_magazine/pistol/mod88] =  /obj/item/ammo_magazine/pistol/mod88/penetrating
	.[/obj/item/ammo_magazine/revolver] =  /obj/item/ammo_magazine/revolver/penetrating
	.[/obj/item/ammo_magazine/rocket] = /obj/item/ammo_magazine/rocket/ap

/obj/item/ammo_kit/toxin
	name = "toxin ammo kit"
	icon_state = "kit_toxin"
	desc = "Converts magazines into toxin ammo."

/obj/item/ammo_kit/toxin/get_convert_map()
	. = ..()
	.[/obj/item/ammo_magazine/smg/m39] = /obj/item/ammo_magazine/smg/m39/toxin
	.[/obj/item/ammo_magazine/rifle] = /obj/item/ammo_magazine/rifle/toxin
	.[/obj/item/ammo_magazine/rifle/l42a] = /obj/item/ammo_magazine/rifle/l42a/toxin
	.[/obj/item/ammo_magazine/rifle/m41aMK1] = /obj/item/ammo_magazine/rifle/m41aMK1/toxin
	.[/obj/item/ammo_magazine/pistol] =  /obj/item/ammo_magazine/pistol/toxin
	.[/obj/item/ammo_magazine/pistol/vp78] =  /obj/item/ammo_magazine/pistol/vp78/toxin
	.[/obj/item/ammo_magazine/pistol/mod88] =  /obj/item/ammo_magazine/pistol/mod88/toxin
	.[/obj/item/ammo_magazine/revolver] =  /obj/item/ammo_magazine/revolver/toxin
	.[/obj/item/ammo_magazine/rocket] = /obj/item/ammo_magazine/rocket/ap

/obj/item/ammo_kit/ap
	name = "armor-piercing ammo kit"
	icon_state = "kit_ap"
	desc = "Converts magazines into armor-piercing ammo."

/obj/item/ammo_kit/ap/get_convert_map()
	. = ..()
	.[/obj/item/ammo_magazine/smg/m39] = /obj/item/ammo_magazine/smg/m39/ap
	.[/obj/item/ammo_magazine/rifle] = /obj/item/ammo_magazine/rifle/ap
	.[/obj/item/ammo_magazine/rifle/l42a] = /obj/item/ammo_magazine/rifle/l42a/ap
	.[/obj/item/ammo_magazine/pistol] =  /obj/item/ammo_magazine/pistol/ap
	.[/obj/item/ammo_magazine/revolver] =  /obj/item/ammo_magazine/revolver/marksman
	.[/obj/item/ammo_magazine/rocket] = /obj/item/ammo_magazine/rocket/ap
	.[/obj/item/ammo_magazine/rifle/m40_sd] = /obj/item/ammo_magazine/rifle/m40_sd/ap
	.[/obj/item/ammo_magazine/rifle/m4ra] = /obj/item/ammo_magazine/rifle/m4ra/impact
	.[/obj/item/explosive/grenade/HE] = /obj/item/explosive/grenade/HE/m15
	.[/obj/item/explosive/grenade/HE/m15] = /obj/item/explosive/grenade/HE/PMC
