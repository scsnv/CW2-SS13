GLOBAL_DATUM_INIT(loot_objects, /datum/loot_table/objects, new())

/obj/structure/closet/crate/loot/objects
	name = "item crate"
	icon_state = "closed_supply"
	icon_closed = "closed_supply"
	icon_opened = "open_supply"

/obj/structure/closet/crate/loot/objects/Initialize()
	. = ..()
	possible_items = GLOB.loot_objects

/datum/loot_table/objects/New()
	. = ..()
	for(var/i in subtypesof(/datum/loot_entry/object))
		var/datum/loot_entry/object/W = i
		if(initial(W.abstract_type) == i)
			continue

		if(!(initial(W.rarity) in rarities))
			stack_trace("Invalid rarity value from [W]. Rarity not found in rarities variable.")
			continue

		table[initial(W.rarity)] += new W()

/datum/loot_entry/object
	name = "object item"
	var/item_to_spawn

/datum/loot_entry/object/spawn_item(var/atom/spawn_location)
	if(!item_to_spawn)
		return
	new item_to_spawn(spawn_location)

/datum/loot_entry/object/multiple
	name = "multiple items"
	abstract_type = /datum/loot_entry/object/multiple

/datum/loot_entry/object/multiple/spawn_item(atom/spawn_location)
	if(!item_to_spawn)
		return
	for(var/i in item_to_spawn)
		new i(spawn_location)



/*
  STIMS ITEMS
*/

/datum/loot_entry/object/stim_speed
	name = "Speed Stimulant Pouch"
	item_to_spawn = /obj/item/storage/pouch/stimulant_injector/speed
	rarity = LOOT_RARE

/datum/loot_entry/object/stim_brain
	name = "Speed Stimulant Pouch"
	item_to_spawn = /obj/item/storage/pouch/stimulant_injector/brain
	rarity = LOOT_RARE

/*
  Armour Plates
*/

/datum/loot_entry/object/ceramic_plate
	name = "Ceramic Plate"
	item_to_spawn = /obj/item/clothing/accessory/health/ceramic
	rarity = LOOT_LEGENDARY

/datum/loot_entry/object/kevlar_plate
	name = "Kevlar Plate"
	item_to_spawn = /obj/item/clothing/accessory/health/kevlar
	rarity = LOOT_VERY_RARE

/datum/loot_entry/object/metal_plate
	name = "Metal Plate"
	item_to_spawn = /obj/item/clothing/accessory/health/metal
	rarity = LOOT_COMMON

/*
  Implants, custom spawn
*/

/datum/loot_entry/object/implants
	name = "Implants"
	rarity = LOOT_RARE
	var/amount_to_spawn = 2
	var/list/possible_implants = list(
		/obj/item/device/implanter/rejuv,
		/obj/item/device/implanter/agility,
		/obj/item/device/implanter/subdermal_armor
	)

/datum/loot_entry/object/implants/spawn_item(atom/spawn_location)
	var/obj/item/storage/box/implant/B = new(spawn_location)
	B.storage_slots = amount_to_spawn
	for(var/i in 1 to amount_to_spawn)
		var/to_spawn = pick(possible_implants)
		new to_spawn(B)

/*
  Special armours
*/

/datum/loot_entry/object/multiple/marsoc_armor
	name = "MARSOC Armor"
	item_to_spawn = list(
		/obj/item/clothing/suit/storage/marine/marsoc,
		/obj/item/clothing/head/helmet/marine/marsoc/nvg
	)
	rarity = LOOT_LEGENDARY

/datum/loot_entry/object/multiple/b18_armor
	name = "B18 Armor"
	item_to_spawn = list(
		/obj/item/clothing/gloves/marine/specialist,
		/obj/item/clothing/head/helmet/marine/specialist,
		/obj/item/clothing/suit/storage/marine/specialist
	)
	rarity = LOOT_VERY_RARE


/datum/loot_entry/object/fire_armor
	name = "Fire Armor"
	item_to_spawn = /obj/item/clothing/suit/storage/marine/M35
	rarity = LOOT_COMMON

/datum/loot_entry/object/rpg_armor
	name = "RPG Armor"
	item_to_spawn = /obj/item/clothing/suit/storage/marine/M3T
	rarity = LOOT_COMMON

/datum/loot_entry/object/scout_armor
	name = "Scout Armor"
	item_to_spawn = /obj/item/clothing/suit/storage/marine/M3S
	rarity = LOOT_COMMON


/*
  Special items
*/

/datum/loot_entry/object/holy_hand_grenade
	name = "Holy Hand Grenade"
	item_to_spawn = /obj/item/explosive/grenade/HE/holy_hand_grenade
	rarity = LOOT_LEGENDARY

/datum/loot_entry/object/m2c_kit
	name = "M2C Machinegun Kit"
	item_to_spawn = /obj/item/storage/box/kit/machinegunner
	rarity = LOOT_RARE
