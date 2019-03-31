local L = GetString

AutoCategory.predefinedRules =  {
    {
        ["rule"] = "type(\"armor\") and not equiptype(\"neck\") and not equiptype(\"ring\")",
        ["tag"] = L(SI_AC_DEFAULT_TAG_GEARS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_ARMOR),
        ["description"] = "",
    },
    {
        ["rule"] = "boundtype(\"on_equip\") and not isbound() and not keepresearch()",
        ["tag"] = L(SI_AC_DEFAULT_TAG_GEARS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_BOE),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_BOE_DESC),
    },
    {
        ["rule"] = "isboptradeable()",
        ["tag"] = L(SI_AC_DEFAULT_TAG_GEARS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_BOP_TRADEABLE),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_BOP_TRADEABLE_DESC),
    },
    {
        ["rule"] = "traitstring(\"intricate\")",
        ["tag"] = L(SI_AC_DEFAULT_TAG_GEARS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT_DESC),
    },
    {
        ["rule"] = "isequipping()",
        ["tag"] = L(SI_AC_DEFAULT_TAG_GEARS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_EQUIPPING),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_EQUIPPING_DESC),
    },
    {
        ["rule"] = "cp() < 160 and type(\"armor\", \"weapon\")",
        ["tag"] = L(SI_AC_DEFAULT_TAG_GEARS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_LOW_LEVEL),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_LOW_LEVEL_DESC),
    },
    {
        ["rule"] = "equiptype(\"neck\")",
        ["tag"] = L(SI_AC_DEFAULT_TAG_GEARS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_NECKLACE),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_NECKLACE_DESC),
    },
    {
        ["rule"] = "keepresearch()",
        ["tag"] = L(SI_AC_DEFAULT_TAG_GEARS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_RESEARCHABLE),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_RESEARCHABLE_DESC),
    },
    {
        ["rule"] = "equiptype(\"ring\")",
        ["tag"] = L(SI_AC_DEFAULT_TAG_GEARS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_RING),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_RING_DESC),
    },
    {
        ["rule"] = "autoset()",
        ["tag"] = L(SI_AC_DEFAULT_TAG_GEARS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_SET),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_SET_DESC),
    },
    {
        ["rule"] = "type(\"weapon\")",
        ["tag"] = L(SI_AC_DEFAULT_TAG_GEARS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_WEAPON),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_WEAPON_DESC),
    },
    {
        ["rule"] = "type(\"food\", \"drink\", \"potion\")",
        ["tag"] = L(SI_AC_DEFAULT_TAG_GENERAL_ITEMS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_CONSUMABLES),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_CONSUMABLES_DESC),
    },
    {
        ["rule"] = "type(\"container\")",
        ["tag"] = L(SI_AC_DEFAULT_TAG_GENERAL_ITEMS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_CONTAINER),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_CONTAINER_DESC),
    },
    {
        ["rule"] = "filtertype(\"furnishing\")",
        ["tag"] = L(SI_AC_DEFAULT_TAG_GENERAL_ITEMS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FURNISHING),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FURNISHING_DESC),
    },
    {
        ["rule"] = "type(\"soul_gem\", \"glyph_armor\", \"glyph_jewelry\", \"glyph_weapon\")",
        ["tag"] = L(SI_AC_DEFAULT_TAG_GENERAL_ITEMS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_GLYPHS_AND_GEMS),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_GLYPHS_AND_GEMS_DESC),
    },
    {
        ["rule"] = "isnew()",
        ["tag"] = L(SI_AC_DEFAULT_TAG_GENERAL_ITEMS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_NEW),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_NEW_DESC),
    },
    {
        ["rule"] = "type(\"poison\")",
        ["tag"] = L(SI_AC_DEFAULT_TAG_GENERAL_ITEMS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_POISON),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_POISON_DESC),
    },
    {
        ["rule"] = "isinquickslot()",
        ["tag"] = L(SI_AC_DEFAULT_TAG_GENERAL_ITEMS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_QUICKSLOTS),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_QUICKSLOTS_DESC),
    },
    {
        ["rule"] = "type(\"recipe\",\"racial_style_motif\") or sptype(\"trophy_recipe_fragment\")",
        ["tag"] = L(SI_AC_DEFAULT_TAG_GENERAL_ITEMS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_RECIPES_AND_MOTIFS),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_RECIPES_AND_MOTIFS_DESC),
    },
    {
        ["rule"] = "traitstring(\"ornate\") or sptype(\"collectible_monster_trophy\") or type(\"trash\")",
        ["tag"] = L(SI_AC_DEFAULT_TAG_GENERAL_ITEMS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_SELLING),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_SELLING_DESC),
    },
    {
        ["rule"] = "isstolen()",
        ["tag"] = L(SI_AC_DEFAULT_TAG_GENERAL_ITEMS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_STOLEN),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_STOLEN_DESC),
    },
    {
        ["rule"] = "sptype(\"trophy_survey_report\", \"trophy_treasure_map\")",
        ["tag"] = L(SI_AC_DEFAULT_TAG_GENERAL_ITEMS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_TREASURE_MAPS),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_TREASURE_MAPS_DESC),
    },
    {
        ["rule"] = "filtertype(\"alchemy\")",
        ["tag"] = L(SI_AC_DEFAULT_TAG_MATERIALS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_ALCHEMY),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_ALCHEMY_DESC),
    },
    {
        ["rule"] = "filtertype(\"blacksmithing\")",
        ["tag"] = L(SI_AC_DEFAULT_TAG_MATERIALS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_BLACKSMITHING),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_BLACKSMITHING_DESC),
    },
    {
        ["rule"] = "filtertype(\"clothing\")",
        ["tag"] = L(SI_AC_DEFAULT_TAG_MATERIALS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_CLOTHING),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_CLOTHING_DESC),
    },
    {
        ["rule"] = "filtertype(\"enchanting\")",
        ["tag"] = L(SI_AC_DEFAULT_TAG_MATERIALS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_ENCHANTING),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_ENCHANTING_DESC),
    },
    {
        ["rule"] = "filtertype(\"jewelrycrafting\")",
        ["tag"] = L(SI_AC_DEFAULT_TAG_MATERIALS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_JEWELRYCRAFTING),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_JEWELRYCRAFTING_DESC),
    },
    {
        ["rule"] = "filtertype(\"provisioning\")",
        ["tag"] = L(SI_AC_DEFAULT_TAG_MATERIALS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_PROVISIONING),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_PROVISIONING_DESC),
    },
    {
        ["rule"] = "filtertype(\"trait_items\", \"style_materials\")",
        ["tag"] = L(SI_AC_DEFAULT_TAG_MATERIALS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_TRAIT_OR_STYLE_GEMS),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_TRAIT_OR_STYLE_GEMS_DESC),
    },
    {
        ["rule"] = "filtertype(\"woodworking\")",
        ["tag"] = L(SI_AC_DEFAULT_TAG_MATERIALS),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_WOODWORKING),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_WOODWORKING_DESC),
    },
    {
        ["tag"] = "FCOIS",
        ["rule"] = "ismarked(\"deconstruction\")",
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DECONSTRUCTION_MARK_DESC),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DECONSTRUCTION_MARK),
    },
    {
        ["tag"] = "FCOIS",
        ["rule"] = "ismarked(\"dynamic_1\")",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_1),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_1_DESC),
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_2),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_2_DESC),
        ["rule"] = "ismarked(\"dynamic_2\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_3),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_3_DESC),
        ["rule"] = "ismarked(\"dynamic_3\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_4),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_4_DESC),
        ["rule"] = "ismarked(\"dynamic_4\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_5),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_5_DESC),
        ["rule"] = "ismarked(\"dynamic_5\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_6),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_6_DESC),
        ["rule"] = "ismarked(\"dynamic_6\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_7),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_7_DESC),
        ["rule"] = "ismarked(\"dynamic_7\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_8),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_8_DESC),
        ["rule"] = "ismarked(\"dynamic_8\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_9),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_9_DESC),
        ["rule"] = "ismarked(\"dynamic_9\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_10),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_10_DESC),
        ["rule"] = "ismarked(\"dynamic_10\")",
    },
    {
        ["tag"] = "FCOIS",
        ["rule"] = "ismarked(\"gear_1\")",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_GEAR_1),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_GEAR_1_DESC),
    },
    {
        ["tag"] = "FCOIS",
        ["rule"] = "ismarked(\"gear_2\")", 
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_GEAR_2),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_GEAR_2_DESC),
    },
    {
        ["tag"] = "FCOIS",
        ["rule"] = "ismarked(\"gear_3\")", 
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_GEAR_3),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_GEAR_3_DESC),
    },
    {
        ["tag"] = "FCOIS",
        ["rule"] = "ismarked(\"gear_4\")", 
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_GEAR_4),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_GEAR_4_DESC),
    },
    {
        ["tag"] = "FCOIS",
        ["rule"] = "ismarked(\"gear_5\")", 
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_GEAR_5),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_GEAR_5_DESC),
    },
    {
        ["tag"] = "FCOIS",
        ["rule"] = "ismarked(\"improvement\")",
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_IMPROVEMENT_MARK_DESC),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_IMPROVEMENT_MARK),
    },
    {
        ["tag"] = "FCOIS",
        ["rule"] = "ismarked(\"intricate\")",
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_INTRICATE_MARK_DESC),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_INTRICATE_MARK),
    },
    {
        ["tag"] = "FCOIS",
        ["rule"] = "ismarked(\"research\")",
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_RESEARCH_MARK_DESC),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_RESEARCH_MARK),
    },
    {
        ["tag"] = "FCOIS",
        ["rule"] = "ismarked(\"sell_at_guildstore\")",
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_SELL_AT_GUILDSTORE_MARK_DESC),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_SELL_AT_GUILDSTORE_MARK),
    },
    {
        ["tag"] = "FCOIS",
        ["rule"] = "ismarked(\"sell\")",
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_SELL_MARK_DESC),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_SELL_MARK),
    },
    {
        ["tag"] = "FCOIS",
        ["rule"] = "ismarked(\"lock\")",
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_LOCK_MARK_DESC),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_LOCK_MARK),
    },
    {
        ["tag"] = "FCOIS",
        ["rule"] = "ismarked()",
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_ALL_MARK_DESC),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_ALL_MARK),
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_11),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_11_DESC),
        ["rule"] = "ismarked(\"dynamic_11\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_12),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_12_DESC),
        ["rule"] = "ismarked(\"dynamic_12\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_13),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_13_DESC),
        ["rule"] = "ismarked(\"dynamic_13\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_14),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_14_DESC),
        ["rule"] = "ismarked(\"dynamic_14\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_15),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_15_DESC),
        ["rule"] = "ismarked(\"dynamic_15\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_16),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_16_DESC),
        ["rule"] = "ismarked(\"dynamic_16\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_17),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_17_DESC),
        ["rule"] = "ismarked(\"dynamic_17\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_18),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_18_DESC),
        ["rule"] = "ismarked(\"dynamic_18\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_19),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_19_DESC),
        ["rule"] = "ismarked(\"dynamic_19\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_20),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_20_DESC),
        ["rule"] = "ismarked(\"dynamic_20\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_21),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_21_DESC),
        ["rule"] = "ismarked(\"dynamic_21\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_22),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_22_DESC),
        ["rule"] = "ismarked(\"dynamic_22\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_23),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_23_DESC),
        ["rule"] = "ismarked(\"dynamic_23\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_24),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_24_DESC),
        ["rule"] = "ismarked(\"dynamic_24\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_25),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_25_DESC),
        ["rule"] = "ismarked(\"dynamic_25\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_26),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_26_DESC),
        ["rule"] = "ismarked(\"dynamic_26\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_27),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_27_DESC),
        ["rule"] = "ismarked(\"dynamic_27\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_28),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_28_DESC),
        ["rule"] = "ismarked(\"dynamic_28\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_29),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_29_DESC),
        ["rule"] = "ismarked(\"dynamic_29\")",
    },
    {
        ["tag"] = "FCOIS",
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_30),
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_30_DESC),
        ["rule"] = "ismarked(\"dynamic_30\")",
    },
}

AutoCategory.defaultCollapses = {
        [AC_BAG_TYPE_BACKPACK] = {},
        [AC_BAG_TYPE_BANK] = {},
        [AC_BAG_TYPE_GUILDBANK] = {},
        [AC_BAG_TYPE_CRAFTBAG] = {},
        [AC_BAG_TYPE_CRAFTSTATION] = {},
        [AC_BAG_TYPE_HOUSEBANK] = {},
    }

AutoCategory.defaultSettings = {
	rules = AutoCategory.predefinedRules,
	bags = {
		[AC_BAG_TYPE_BACKPACK] = {
			rules = {},
		},
		[AC_BAG_TYPE_BANK] = {
			rules = {},
		},
		[AC_BAG_TYPE_GUILDBANK] = {
			rules = {},
		},
		[AC_BAG_TYPE_CRAFTBAG] = {
			rules = {},
		},
		[AC_BAG_TYPE_CRAFTSTATION] = {
			rules = {},
		},
		[AC_BAG_TYPE_HOUSEBANK] = {
			rules = {},
		},
	}, 
    collapses = AutoCategory.defaultCollapses,
	accountWide = true,
}
 
AutoCategory.defaultAcctSettings = {
	rules = AutoCategory.predefinedRules,
	bags = {
		[AC_BAG_TYPE_BACKPACK] = {
			rules = {
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOP_TRADEABLE),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NEW),
				},
				{
					["priority"] = 95,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONTAINER),
				},
				{
					["priority"] = 90,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SELLING),
				},
				{
					["priority"] = 85,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_LOW_LEVEL),
				},
				{
					["priority"] = 80,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT),
				},
				{
					["priority"] = 70,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOE),
				},
				{
					["priority"] = 60,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RESEARCHABLE),
				},
				{
					["priority"] = 50,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_EQUIPPING),
				},
				{
					["priority"] = 49,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SET),
				},
				{
					["priority"] = 48,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WEAPON),
				},
				{
					["priority"] = 47,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_POISON),
				},
				{
					["priority"] = 46,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ARMOR),
				},
				{
					["priority"] = 45,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NECKLACE),
				},
				{
					["priority"] = 45,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RING),
				},
				{
					["priority"] = 40,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_QUICKSLOTS),
				},
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONSUMABLES),
				},
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_GLYPHS_AND_GEMS),
				},
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RECIPES_AND_MOTIFS),
				},
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TREASURE_MAPS),
				},
				{
					["priority"] = 30,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_FURNISHING),
				},
				{
					["priority"] = 20,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_STOLEN),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ALCHEMY),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BLACKSMITHING),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CLOTHING),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ENCHANTING),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_PROVISIONING),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TRAIT_OR_STYLE_GEMS),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WOODWORKING),
				},
			},
		},
		[AC_BAG_TYPE_BANK] = {
			rules = {
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOP_TRADEABLE),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NEW),
				},
				{
					["priority"] = 95,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONTAINER),
				},
				{
					["priority"] = 90,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SELLING),
				},
				{
					["priority"] = 85,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_LOW_LEVEL),
				},
				{
					["priority"] = 80,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT),
				},
				{
					["priority"] = 70,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOE),
				},
				{
					["priority"] = 60,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RESEARCHABLE),
				},
				{
					["priority"] = 50,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_EQUIPPING),
				},
				{
					["priority"] = 49,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SET),
				},
				{
					["priority"] = 48,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WEAPON),
				},
				{
					["priority"] = 47,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_POISON),
				},
				{
					["priority"] = 46,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ARMOR),
				},
				{
					["priority"] = 45,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NECKLACE),
				},
				{
					["priority"] = 45,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RING),
				},
				{
					["priority"] = 40,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_QUICKSLOTS),
				},
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONSUMABLES),
				},
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_GLYPHS_AND_GEMS),
				},
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RECIPES_AND_MOTIFS),
				},
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TREASURE_MAPS),
				},
				{
					["priority"] = 30,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_FURNISHING),
				},
				{
					["priority"] = 20,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_STOLEN),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ALCHEMY),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BLACKSMITHING),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CLOTHING),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ENCHANTING),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_PROVISIONING),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TRAIT_OR_STYLE_GEMS),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WOODWORKING),
				},
			},
		},
		[AC_BAG_TYPE_GUILDBANK] = {
			rules = {
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOP_TRADEABLE),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NEW),
				},
				{
					["priority"] = 95,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONTAINER),
				},
				{
					["priority"] = 90,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SELLING),
				},
				{
					["priority"] = 85,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_LOW_LEVEL),
				},
				{
					["priority"] = 80,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT),
				},
				{
					["priority"] = 70,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOE),
				},
				{
					["priority"] = 60,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RESEARCHABLE),
				},
				{
					["priority"] = 50,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_EQUIPPING),
				},
				{
					["priority"] = 49,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SET),
				},
				{
					["priority"] = 48,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WEAPON),
				},
				{
					["priority"] = 47,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_POISON),
				},
				{
					["priority"] = 46,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ARMOR),
				},
				{
					["priority"] = 45,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NECKLACE),
				},
				{
					["priority"] = 45,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RING),
				},
				{
					["priority"] = 40,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_QUICKSLOTS),
				},
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONSUMABLES),
				},
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_GLYPHS_AND_GEMS),
				},
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RECIPES_AND_MOTIFS),
				},
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TREASURE_MAPS),
				},
				{
					["priority"] = 30,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_FURNISHING),
				},
				{
					["priority"] = 20,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_STOLEN),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ALCHEMY),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BLACKSMITHING),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CLOTHING),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ENCHANTING),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_PROVISIONING),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TRAIT_OR_STYLE_GEMS),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WOODWORKING),
				},
			},
		},
		[AC_BAG_TYPE_CRAFTBAG] = {
			rules = {
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BLACKSMITHING),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CLOTHING),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WOODWORKING),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ALCHEMY),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ENCHANTING),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_PROVISIONING),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TRAIT_OR_STYLE_GEMS),
				},
			},
		},
		[AC_BAG_TYPE_CRAFTSTATION] = {
			rules = {
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOP_TRADEABLE),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NEW),
				},
				{
					["priority"] = 95,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONTAINER),
				},
				{
					["priority"] = 90,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SELLING),
				},
				{
					["priority"] = 85,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_LOW_LEVEL),
				},
				{
					["priority"] = 80,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT),
				},
				{
					["priority"] = 70,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOE),
				},
				{
					["priority"] = 60,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RESEARCHABLE),
				},
				{
					["priority"] = 50,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_EQUIPPING),
				},
				{
					["priority"] = 49,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SET),
				},
				{
					["priority"] = 48,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WEAPON),
				},
				{
					["priority"] = 47,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_POISON),
				},
				{
					["priority"] = 46,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ARMOR),
				},
				{
					["priority"] = 45,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NECKLACE),
				},
				{
					["priority"] = 45,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RING),
				},
				{
					["priority"] = 40,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_QUICKSLOTS),
				},
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONSUMABLES),
				},
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_GLYPHS_AND_GEMS),
				},
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RECIPES_AND_MOTIFS),
				},
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TREASURE_MAPS),
				},
				{
					["priority"] = 30,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_FURNISHING),
				},
				{
					["priority"] = 20,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_STOLEN),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ALCHEMY),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BLACKSMITHING),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CLOTHING),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ENCHANTING),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_PROVISIONING),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TRAIT_OR_STYLE_GEMS),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WOODWORKING),
				},
			},
		},
		[AC_BAG_TYPE_HOUSEBANK] = {
			rules = {
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOP_TRADEABLE),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NEW),
				},
				{
					["priority"] = 95,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONTAINER),
				},
				{
					["priority"] = 90,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SELLING),
				},
				{
					["priority"] = 85,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_LOW_LEVEL),
				},
				{
					["priority"] = 80,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT),
				},
				{
					["priority"] = 70,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOE),
				},
				{
					["priority"] = 60,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RESEARCHABLE),
				},
				{
					["priority"] = 50,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_EQUIPPING),
				},
				{
					["priority"] = 49,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SET),
				},
				{
					["priority"] = 48,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WEAPON),
				},
				{
					["priority"] = 47,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_POISON),
				},
				{
					["priority"] = 46,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ARMOR),
				},
				{
					["priority"] = 45,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NECKLACE),
				},
				{
					["priority"] = 45,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RING),
				},
				{
					["priority"] = 40,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_QUICKSLOTS),
				},
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONSUMABLES),
				},
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_GLYPHS_AND_GEMS),
				},
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RECIPES_AND_MOTIFS),
				},
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TREASURE_MAPS),
				},
				{
					["priority"] = 30,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_FURNISHING),
				},
				{
					["priority"] = 20,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_STOLEN),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ALCHEMY),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BLACKSMITHING),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CLOTHING),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ENCHANTING),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_PROVISIONING),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TRAIT_OR_STYLE_GEMS),
				},
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WOODWORKING),
				},
			},
		},
	}, 
	appearance = {
		["CATEGORY_FONT_NAME"] = "Univers 67",
		["CATEGORY_FONT_STYLE"] = "soft-shadow-thin",
		["CATEGORY_FONT_COLOR"] =  {
			[1] = 1,
			[2] = 1,
			[3] = 1,
			[4] = 1,
		},
		["CATEGORY_FONT_SIZE"] = 18,
		["CATEGORY_FONT_ALIGNMENT"] = 1,
		["CATEGORY_OTHER_TEXT"] = L(SI_AC_DEFAULT_NAME_CATEGORY_OTHER),
		["CATEGORY_HEADER_HEIGHT"] = 52, 
	},
	general = {
		["SHOW_MESSAGE_WHEN_TOGGLE"] = false,
		["SHOW_CATEGORY_ITEM_COUNT"] = true, 
		["SAVE_CATEGORY_COLLAPSE_STATUS"] = false,
	},
    collapses = AutoCategory.defaultCollapses,
}

