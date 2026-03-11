local SF = LibSFUtils
local AutoCat = AutoCategory

local saved = AutoCat.saved
local cache = AutoCat.cache

local AddCat_SelectTag_LAM = AC_UI.AddCat_SelectTag_LAM

local logDebug = AutoCategory.logDebug


function AutoCat.debugCache()
    d("User rules: " .. AutoCat.ARW:size()) --#AutoCategory.acctRules.rules)
    d("Saved rules: " .. #saved.rules)						-- should be 0 after conversion
    d("Predefined rules: " .. #AutoCat.predefinedRules)			-- predefined rules from base and plugins
    d("Combined rules: " .. ac_rules:sizeRules())						-- complete list of user rules and predefined rules
    d("Compiled rules: " .. SF.GetSize(ac_rules.compiled))
    d("Rules by Name: " .. SF.GetSize(ac_rules.ruleNames))	-- lookup table for rules by rule name
    d("Rules by Tag: " .. SF.GetSize(ac_rules.tagGroups))	-- actually returns the # of Tags defined
    d("Tags: " .. ac_rules:sizeTags())					-- returns the # of Tags defined
    d("Saved bags: " .. #saved.bags)						-- returns # of bags, collections of bagrules by bagId
    d("Cache bags: " ..cache.bags_cvt:size())			-- CVT of bags for bag id dropdowns, returns 3 for CVT
    d("Entries by Bag: " .. SF.GetSize(cache.entriesByBag))		-- CVT of bagrules by bagid, so always returns # bags
    d("Entries by Name: " .. SF.GetSize(cache.entriesByName))	-- bagrules lookup by bagid and rule name, returns # bags
end

--unused (debug) - Not sure why called "EBT" since it uses entriesByName!!
function AutoCat.debugEBT()
	for k, v in pairs(cache.entriesByName[1]) do
		d("k = "..k)
		if type(v) == "table" then
			for k1,v1 in pairs(v) do
				d("  k1="..k1.."  v1="..SF.str(v1))
			end
		else
		    d("v= "..SF.str(v))
		end
	end
end

--unused (debug)
function AutoCat.debugTags()
	d("RulesW.tags:")
	for k, v in pairs(ac_rules.tags) do
		if type(v) == "table" then
			for k1,v1 in pairs(v) do
				d("k = "..k.."   k1="..k1.."  v1="..SF.str(v1))
			end
		else
		    d("k = "..k.." v= "..SF.str(v))
		end
	end
end


function AutoCategory.debugBagTags()
	AddCat_SelectTag_LAM:assign( { choices=AutoCategory.RulesW.tags })
	d("AddCat_SelectTag_LAM:")
	for k, v in pairs(AddCat_SelectTag_LAM.cvt.choices) do
		if type(v) == "table" then
			for k1,v1 in pairs(v) do
				d("k = "..k.."   k1="..k1.."  v1="..SF.str(v1))
			end
		else
		    d("k = "..k.." v= "..SF.str(v))
		end
	end
end


local specializedItemTypeMap = {
	["additive"] = SPECIALIZED_ITEMTYPE_ADDITIVE,
	["armor"] = SPECIALIZED_ITEMTYPE_ARMOR,
	["armor_booster"] = SPECIALIZED_ITEMTYPE_ARMOR_BOOSTER,
	["armor_trait"] = SPECIALIZED_ITEMTYPE_ARMOR_TRAIT,
	["ava_repair"] = SPECIALIZED_ITEMTYPE_AVA_REPAIR,
	["blacksmithing_booster"] = SPECIALIZED_ITEMTYPE_BLACKSMITHING_BOOSTER,
	["blacksmithing_material"] = SPECIALIZED_ITEMTYPE_BLACKSMITHING_MATERIAL,
	["blacksmithing_raw_material"] = SPECIALIZED_ITEMTYPE_BLACKSMITHING_RAW_MATERIAL,
	["clothier_booster"] = SPECIALIZED_ITEMTYPE_CLOTHIER_BOOSTER,
	["clothier_material"] = SPECIALIZED_ITEMTYPE_CLOTHIER_MATERIAL,
	["clothier_raw_material"] = SPECIALIZED_ITEMTYPE_CLOTHIER_RAW_MATERIAL,
	["collectible_monster_trophy"] = SPECIALIZED_ITEMTYPE_COLLECTIBLE_MONSTER_TROPHY,
	["collectible_rare_fish"] = SPECIALIZED_ITEMTYPE_COLLECTIBLE_RARE_FISH,
	["collectible_style_page"] = SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE,
    ["consumable_ability"] = SPECIALIZED_ITEMTYPE_CONSUMABLE_ABILITY,
	["container"] = SPECIALIZED_ITEMTYPE_CONTAINER,
	["container_currency"] = SPECIALIZED_ITEMTYPE_CONTAINER_CURRENCY,
	["container_event"] = SPECIALIZED_ITEMTYPE_CONTAINER_EVENT,
	["container_style_page"] = SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE,
    ["container_stackable"] = SPECIALIZED_ITEMTYPE_CONTAINER_STACKABLE,
	["costume"] = SPECIALIZED_ITEMTYPE_COSTUME,
    ["crafted_ability"] = SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY,
    ["crafted_ability_script_primary"] = SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_PRIMARY,
    ["crafted_ability_script_secondary"] = SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_SECONDARY,
    ["crafted_ability_script_tertiary"] = SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_TERTIARY,
	["disguise"] = SPECIALIZED_ITEMTYPE_DISGUISE,
	["drink_alcoholic"] = SPECIALIZED_ITEMTYPE_DRINK_ALCOHOLIC,
	["drink_cordial_tea"] = SPECIALIZED_ITEMTYPE_DRINK_CORDIAL_TEA,
	["drink_distillate"] = SPECIALIZED_ITEMTYPE_DRINK_DISTILLATE,
	["drink_liqueur"] = SPECIALIZED_ITEMTYPE_DRINK_LIQUEUR,
	["drink_tea"] = SPECIALIZED_ITEMTYPE_DRINK_TEA,
	["drink_tincture"] = SPECIALIZED_ITEMTYPE_DRINK_TINCTURE,
	["drink_tonic"] = SPECIALIZED_ITEMTYPE_DRINK_TONIC,
	["drink_unique"] = SPECIALIZED_ITEMTYPE_DRINK_UNIQUE,
	["dye_stamp"] = SPECIALIZED_ITEMTYPE_DYE_STAMP,
	["enchanting_rune_aspect"] = SPECIALIZED_ITEMTYPE_ENCHANTING_RUNE_ASPECT,
	["enchanting_rune_essence"] = SPECIALIZED_ITEMTYPE_ENCHANTING_RUNE_ESSENCE,
	["enchanting_rune_potency"] = SPECIALIZED_ITEMTYPE_ENCHANTING_RUNE_POTENCY,
	["enchantment_booster"] = SPECIALIZED_ITEMTYPE_ENCHANTMENT_BOOSTER,
	["fish"] = SPECIALIZED_ITEMTYPE_FISH,
	["flavoring"] = SPECIALIZED_ITEMTYPE_FLAVORING,
	["food_entremet"] = SPECIALIZED_ITEMTYPE_FOOD_ENTREMET,
	["food_fruit"] = SPECIALIZED_ITEMTYPE_FOOD_FRUIT,
	["food_gourmet"] = SPECIALIZED_ITEMTYPE_FOOD_GOURMET,
	["food_meat"] = SPECIALIZED_ITEMTYPE_FOOD_MEAT,
	["food_ragout"] = SPECIALIZED_ITEMTYPE_FOOD_RAGOUT,
	["food_savoury"] = SPECIALIZED_ITEMTYPE_FOOD_SAVOURY,
	["food_unique"] = SPECIALIZED_ITEMTYPE_FOOD_UNIQUE,
	["food_vegetable"] = SPECIALIZED_ITEMTYPE_FOOD_VEGETABLE,
    ["furnishing_attunable_station"] = SPECIALIZED_ITEMTYPE_FURNISHING_ATTUNABLE_STATION,
    ["furnishing_crafting_station"] = SPECIALIZED_ITEMTYPE_FURNISHING_CRAFTING_STATION,
    ["furnishing_light"] = SPECIALIZED_ITEMTYPE_FURNISHING_LIGHT,
	["furnishing_material_alchemy"] = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_ALCHEMY,
	["furnishing_material_blacksmithing"] = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_BLACKSMITHING,
	["furnishing_material_clothier"] = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_CLOTHIER,
	["furnishing_material_enchanting"] = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_ENCHANTING,
	["furnishing_material_jewelry"] = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_JEWELRYCRAFTING,
	["furnishing_material_provisioning"] = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_PROVISIONING,
	["furnishing_material_woodworking"] = SPECIALIZED_ITEMTYPE_FURNISHING_MATERIAL_WOODWORKING,
    ["furnishing_seating"] = SPECIALIZED_ITEMTYPE_FURNISHING_SEATING,
    ["furnishing_ornamental"]= SPECIALIZED_ITEMTYPE_FURNISHING_ORNAMENTAL,
    ["furnishing_target_dummy"]= SPECIALIZED_ITEMTYPE_FURNISHING_TARGET_DUMMY,
	["glyph_armor"] = SPECIALIZED_ITEMTYPE_GLYPH_ARMOR,
	["glyph_jewelry"] = SPECIALIZED_ITEMTYPE_GLYPH_JEWELRY,
	["glyph_weapon"] = SPECIALIZED_ITEMTYPE_GLYPH_WEAPON,
    ["group_repair"] = SPECIALIZED_ITEMTYPE_GROUP_REPAIR,
    ["holiday_writ"] = SPECIALIZED_ITEMTYPE_HOLIDAY_WRIT,
    ["ingredient_alcohol"] = SPECIALIZED_ITEMTYPE_INGREDIENT_ALCOHOL,
	["ingredient_drink_additive"] = SPECIALIZED_ITEMTYPE_INGREDIENT_DRINK_ADDITIVE,
	["ingredient_food_additive"] = SPECIALIZED_ITEMTYPE_INGREDIENT_FOOD_ADDITIVE,
	["ingredient_fruit"] = SPECIALIZED_ITEMTYPE_INGREDIENT_FRUIT,
	["ingredient_meat"] = SPECIALIZED_ITEMTYPE_INGREDIENT_MEAT,
	["ingredient_rare"] = SPECIALIZED_ITEMTYPE_INGREDIENT_RARE,
	["ingredient_tea"] = SPECIALIZED_ITEMTYPE_INGREDIENT_TEA,
	["ingredient_tonic"] = SPECIALIZED_ITEMTYPE_INGREDIENT_TONIC,
	["ingredient_vegetable"] = SPECIALIZED_ITEMTYPE_INGREDIENT_VEGETABLE,
    ["jewelry_booster"] = SPECIALIZED_ITEMTYPE_JEWELRYCRAFTING_BOOSTER,
    ["jewelry_material"] = SPECIALIZED_ITEMTYPE_JEWELRYCRAFTING_MATERIAL,
    ["jewelry_raw_booster"] = SPECIALIZED_ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER,
    ["jewelry_raw_material"] = SPECIALIZED_ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL,
    ["jewelry_raw_trait"] = SPECIALIZED_ITEMTYPE_JEWELRY_RAW_TRAIT,
    ["jewelry_trait"] = SPECIALIZED_ITEMTYPE_JEWELRY_TRAIT,
	["lockpick"] = SPECIALIZED_ITEMTYPE_LOCKPICK,
	["lure"] = SPECIALIZED_ITEMTYPE_LURE,
	["master_writ"] = SPECIALIZED_ITEMTYPE_MASTER_WRIT,
	["mount"] = SPECIALIZED_ITEMTYPE_MOUNT,
	["none"] = SPECIALIZED_ITEMTYPE_NONE,
	["plug"] = SPECIALIZED_ITEMTYPE_PLUG,
	["poison"] = SPECIALIZED_ITEMTYPE_POISON,
	["poison_base"] = SPECIALIZED_ITEMTYPE_POISON_BASE,
	["potion"] = SPECIALIZED_ITEMTYPE_POTION,
	["potion_base"] = SPECIALIZED_ITEMTYPE_POTION_BASE,
	["racial_style_motif_book"] = SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK,
	["racial_style_motif_chapter"] = SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER,
	["raw_material"] = SPECIALIZED_ITEMTYPE_RAW_MATERIAL,
	["reagent_animal_part"] = SPECIALIZED_ITEMTYPE_REAGENT_ANIMAL_PART,
	["reagent_fungus"] = SPECIALIZED_ITEMTYPE_REAGENT_FUNGUS,
	["reagent_herb"] = SPECIALIZED_ITEMTYPE_REAGENT_HERB,
	["recall_stone_keep"] = SPECIALIZED_ITEMTYPE_RECALL_STONE_KEEP,
	["recipe_alchemy_formula_furnishing"] = SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING,
	["recipe_blacksmithing_diagram_furnishing"] = 
		SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING,
	["recipe_clothier_pattern_furnishing"] = SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING,
	["recipe_enchanting_schematic_furnishing"] = 
		SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING,
	["recipe_jewelry_sketch_furnishing"] = 
		SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING,
	["recipe_provisioning_design_furnishing"] = 
		SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING,
	["recipe_provisioning_standard_drink"] = SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK,
	["recipe_provisioning_standard_food"] = SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD,
	["recipe_woodworking_blueprint_furnishing"] = 
		SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING,
	["script"] = SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY,
	["script_focus"] = SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_PRIMARY,
	["script_signature"] = SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_SECONDARY,
	["script_affix"] = SPECIALIZED_ITEMTYPE_CRAFTED_ABILITY_SCRIPT_TERTIARY,
	["scribing ink"] = SPECIALIZED_ITEMTYPE_SCRIBING_INK,
	["siege_ballista"] = SPECIALIZED_ITEMTYPE_SIEGE_BALLISTA,
	["siege_catapult"] = SPECIALIZED_ITEMTYPE_SIEGE_CATAPULT,
	["siege_graveyard"] = SPECIALIZED_ITEMTYPE_SIEGE_GRAVEYARD,
	["siege_lancer"] = SPECIALIZED_ITEMTYPE_SIEGE_LANCER,
	["siege_monster"] = SPECIALIZED_ITEMTYPE_SIEGE_MONSTER,
	["siege_oil"] = SPECIALIZED_ITEMTYPE_SIEGE_OIL,
	["siege_ram"] = SPECIALIZED_ITEMTYPE_SIEGE_RAM,
	["siege_trebuchet"] = SPECIALIZED_ITEMTYPE_SIEGE_TREBUCHET,
	["siege_universal"] = SPECIALIZED_ITEMTYPE_SIEGE_UNIVERSAL,
	["soul_gem"] = SPECIALIZED_ITEMTYPE_SOUL_GEM,
	["spellcrafting_tablet"] = SPECIALIZED_ITEMTYPE_SPELLCRAFTING_TABLET,
	["spice"] = SPECIALIZED_ITEMTYPE_SPICE,
	["style_material"] = SPECIALIZED_ITEMTYPE_STYLE_MATERIAL,
	["tabard"] = SPECIALIZED_ITEMTYPE_TABARD,
	["tool"] = SPECIALIZED_ITEMTYPE_TOOL,
	["trash"] = SPECIALIZED_ITEMTYPE_TRASH,
	["treasure"] = SPECIALIZED_ITEMTYPE_TREASURE,
	["trophy_collectible_fragment"] = SPECIALIZED_ITEMTYPE_TROPHY_COLLECTIBLE_FRAGMENT,
	["trophy_dungeon_buff_ingredient"] = SPECIALIZED_ITEMTYPE_TROPHY_DUNGEON_BUFF_INGREDIENT,
	["trophy_key"] = SPECIALIZED_ITEMTYPE_TROPHY_KEY,
	["trophy_key_fragment"] = SPECIALIZED_ITEMTYPE_TROPHY_KEY_FRAGMENT,
	["trophy_material_upgrader"] = SPECIALIZED_ITEMTYPE_TROPHY_MATERIAL_UPGRADER,
	["trophy_museum_piece"] = SPECIALIZED_ITEMTYPE_TROPHY_MUSEUM_PIECE,
	["trophy_recipe_fragment"] = SPECIALIZED_ITEMTYPE_TROPHY_RECIPE_FRAGMENT,
	["trophy_runebox_fragment"] = SPECIALIZED_ITEMTYPE_TROPHY_RUNEBOX_FRAGMENT,
	["trophy_scroll"] = SPECIALIZED_ITEMTYPE_TROPHY_SCROLL,
	["trophy_survey_report"] = SPECIALIZED_ITEMTYPE_TROPHY_SURVEY_REPORT,
	["trophy_toy"] = SPECIALIZED_ITEMTYPE_TROPHY_TOY,
	["trophy_treasure_map"] = SPECIALIZED_ITEMTYPE_TROPHY_TREASURE_MAP,
    ["trophy_tribute_clue"] = SPECIALIZED_ITEMTYPE_TROPHY_TRIBUTE_CLUE,
    ["trophy_upgrade_fragment"] = SPECIALIZED_ITEMTYPE_TROPHY_UPGRADE_FRAGMENT,	
    ["weapon"] = SPECIALIZED_ITEMTYPE_WEAPON,
	["weapon_booster"] = SPECIALIZED_ITEMTYPE_WEAPON_BOOSTER,
	["weapon_trait"] = SPECIALIZED_ITEMTYPE_WEAPON_TRAIT,
	["woodworking_booster"] = SPECIALIZED_ITEMTYPE_WOODWORKING_BOOSTER,
	["woodworking_material"] = SPECIALIZED_ITEMTYPE_WOODWORKING_MATERIAL,
	["woodworking_raw_material"] = SPECIALIZED_ITEMTYPE_WOODWORKING_RAW_MATERIAL,
}

local function getsptype(spt)
    local sptype = "unknown"
    for k,v in pairs(specializedItemTypeMap) do
        if v == spt then
            sptype = k
            break
        end
    end
    return sptype
end


local itemTypeMap = {
	["additive"] = ITEMTYPE_ADDITIVE,
	["armor"] = ITEMTYPE_ARMOR,
	["armor_booster"] = ITEMTYPE_ARMOR_BOOSTER,
	["armor_trait"] = ITEMTYPE_ARMOR_TRAIT,
	["ava_repair"] = ITEMTYPE_AVA_REPAIR,
	["blacksmithing_booster"] = ITEMTYPE_BLACKSMITHING_BOOSTER,
	["blacksmithing_material"] = ITEMTYPE_BLACKSMITHING_MATERIAL,
	["blacksmithing_raw_material"] = ITEMTYPE_BLACKSMITHING_RAW_MATERIAL,
	["clothier_booster"] = ITEMTYPE_CLOTHIER_BOOSTER,
	["clothier_material"] = ITEMTYPE_CLOTHIER_MATERIAL,
	["clothier_raw_material"] = ITEMTYPE_CLOTHIER_RAW_MATERIAL,
	["collectible"] = ITEMTYPE_COLLECTIBLE,
    ["consumable_ability"] = ITEMTYPE_CONSUMABLE_ABILITY,
	["container"] = ITEMTYPE_CONTAINER,
	["container_currency"] = ITEMTYPE_CONTAINER_CURRENCY,
    ["container_stackable"] = ITEMTYPE_CONTAINER_STACKABLE,
	["costume"] = ITEMTYPE_COSTUME,
    ["crafted_ability"] = ITEMTYPE_CRAFTED_ABILITY,
    ["crafted_ability_script"] = ITEMTYPE_CRAFTED_ABILITY_SCRIPT,
	["crown_item"] = ITEMTYPE_CROWN_ITEM,
	["crown_repair"] = ITEMTYPE_CROWN_REPAIR,
	["deprecated"] = ITEMTYPE_DEPRECATED,
	["deprecated2"] = ITEMTYPE_DEPRECATED_2,	
	["disguise"] = ITEMTYPE_DISGUISE,
	["drink"] = ITEMTYPE_DRINK,
	["dye_stamp"] = ITEMTYPE_DYE_STAMP,
	["enchanting_rune_aspect"] = ITEMTYPE_ENCHANTING_RUNE_ASPECT,
	["enchanting_rune_essence"] = ITEMTYPE_ENCHANTING_RUNE_ESSENCE,
	["enchanting_rune_potency"] = ITEMTYPE_ENCHANTING_RUNE_POTENCY,
	["enchantment_booster"] = ITEMTYPE_ENCHANTMENT_BOOSTER,
	["fish"] = ITEMTYPE_FISH,
	["flavoring"] = ITEMTYPE_FLAVORING,
	["food"] = ITEMTYPE_FOOD,
	["furnishing"] = ITEMTYPE_FURNISHING,
	["furnishing_material"] = ITEMTYPE_FURNISHING_MATERIAL,
	["glyph_armor"] = ITEMTYPE_GLYPH_ARMOR,
	["glyph_jewelry"] = ITEMTYPE_GLYPH_JEWELRY,
	["glyph_weapon"] = ITEMTYPE_GLYPH_WEAPON,
	["group_repair"] = ITEMTYPE_GROUP_REPAIR,
	["ingredient"] = ITEMTYPE_INGREDIENT,
    ["jewelry_booster"] = ITEMTYPE_JEWELRYCRAFTING_BOOSTER,
    ["jewelry_material"] = ITEMTYPE_JEWELRYCRAFTING_MATERIAL,
    ["jewelry_raw_booster"] = ITEMTYPE_JEWELRYCRAFTING_RAW_BOOSTER,
    ["jewelry_raw_material"] = ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL,
    ["jewelry_raw_trait"] = ITEMTYPE_JEWELRY_RAW_TRAIT,
    ["jewelry_trait"] = ITEMTYPE_JEWELRY_TRAIT,
	["lockpick"] = ITEMTYPE_LOCKPICK,
	["lure"] = ITEMTYPE_LURE,
	["master_writ"] = ITEMTYPE_MASTER_WRIT,
	["mount"] = ITEMTYPE_MOUNT,
	["none"] = ITEMTYPE_NONE,
	["plug"] = ITEMTYPE_PLUG,
	["poison"] = ITEMTYPE_POISON,
	["poison_base"] = ITEMTYPE_POISON_BASE,
	["potion"] = ITEMTYPE_POTION,
	["potion_base"] = ITEMTYPE_POTION_BASE,
	["racial_style_motif"] = ITEMTYPE_RACIAL_STYLE_MOTIF,
	["raw_material"] = ITEMTYPE_RAW_MATERIAL,
	["reagent"] = ITEMTYPE_REAGENT,
	["recall_stone"] = ITEMTYPE_RECALL_STONE,
	["recipe"] = ITEMTYPE_RECIPE,
	["grimoire"] = ITEMTYPE_CRAFTED_ABILITY,
	["scribing"] = ITEMTYPE_CRAFTED_ABILITY_SCRIPT,
	["scribing_ink"] = ITEMTYPE_SCRIBING_INK,
	["siege"] = ITEMTYPE_SIEGE,
	["soul_gem"] = ITEMTYPE_SOUL_GEM,
	["spice"] = ITEMTYPE_SPICE,
	["style_material"] = ITEMTYPE_STYLE_MATERIAL,
	["tabard"] = ITEMTYPE_TABARD,
	["tool"] = ITEMTYPE_TOOL,
	["trash"] = ITEMTYPE_TRASH,
	["treasure"] = ITEMTYPE_TREASURE,
	["trophy"] = ITEMTYPE_TROPHY,
	["weapon"] = ITEMTYPE_WEAPON,
	["weapon_booster"] = ITEMTYPE_WEAPON_BOOSTER,
	["weapon_trait"] = ITEMTYPE_WEAPON_TRAIT,
	["woodworking_booster"] = ITEMTYPE_WOODWORKING_BOOSTER,
	["woodworking_material"] = ITEMTYPE_WOODWORKING_MATERIAL,
	["woodworking_raw_material"] = ITEMTYPE_WOODWORKING_RAW_MATERIAL,
}

local function getType(t)
    local type = "unknown"
    for k,v in pairs(itemTypeMap) do
        if v == t then
            type = k
            break
        end
    end
    return type
end



function AutoCategory.displayItem(bagId, slotIndex)
    logDebug("[AC-Debug] bagId ", bagId, " slot ", slotIndex)

    local itemId = GetItemId(bagId, slotIndex)
	local name = GetItemName(bagId, slotIndex)
    logDebug("[AC-Debug] ", name, " (", itemId, ")")

	local link = GetItemLink(bagId, slotIndex)

    local itemType, specializedItemType = GetItemLinkItemType(link)
    local equipType = GetItemLinkEquipType(link) 
	local filterType = GetItemLinkFilterTypeInfo(link)
    logDebug("[AC-Debug] ", "type() = ", itemType, " ", getType(itemType), "  sptype() = ",specializedItemType, " ", getsptype(specializedItemType))
end