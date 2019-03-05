
local L = AutoCategory.localizefunc
AutoCategory.defaultSettings = {
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
	accountWideSetting = true,
}
 
AutoCategory.defaultAcctSettings = {
	rules = {
		[1] = 
		{
			["rule"] = "type(\"armor\") and not equiptype(\"neck\") and not equiptype(\"ring\")",
			["tag"] = L(SI_AC_DEFAULT_TAG_GEARS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_ARMOR),
			["damaged"] = false,
			["description"] = "",
		},
		[2] = 
		{
			["rule"] = "boundtype(\"on_equip\") and not isbound() and not keepresearch()",
			["tag"] = L(SI_AC_DEFAULT_TAG_GEARS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_BOE),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_BOE_DESC),
		},
		[3] = 
		{
			["rule"] = "isboptradeable()",
			["tag"] = L(SI_AC_DEFAULT_TAG_GEARS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_BOP_TRADEABLE),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_BOP_TRADEABLE_DESC),
		},
		[4] = 
		{
			["rule"] = "traitstring(\"intricate\")",
			["tag"] = L(SI_AC_DEFAULT_TAG_GEARS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT_DESC),
		},
		[5] = 
		{
			["rule"] = "isequipping()",
			["tag"] = L(SI_AC_DEFAULT_TAG_GEARS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_EQUIPPING),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_EQUIPPING_DESC),
		},
		[6] = 
		{
			["rule"] = "cp() < 160 and type(\"armor\", \"weapon\")",
			["tag"] = L(SI_AC_DEFAULT_TAG_GEARS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_LOW_LEVEL),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_LOW_LEVEL_DESC),
		},
		[7] = 
		{
			["rule"] = "equiptype(\"neck\")",
			["tag"] = L(SI_AC_DEFAULT_TAG_GEARS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_NECKLACE),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_NECKLACE_DESC),
		},
		[8] = 
		{
			["rule"] = "keepresearch()",
			["tag"] = L(SI_AC_DEFAULT_TAG_GEARS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_RESEARCHABLE),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_RESEARCHABLE_DESC),
		},
		[9] = 
		{
			["rule"] = "equiptype(\"ring\")",
			["tag"] = L(SI_AC_DEFAULT_TAG_GEARS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_RING),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_RING_DESC),
		},
		[10] = 
		{
			["rule"] = "autoset()",
			["tag"] = L(SI_AC_DEFAULT_TAG_GEARS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_SET),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_SET_DESC),
		},
		[11] = 
		{
			["rule"] = "type(\"weapon\")",
			["tag"] = L(SI_AC_DEFAULT_TAG_GEARS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_WEAPON),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_WEAPON_DESC),
		},
		[12] = 
		{
			["rule"] = "type(\"food\", \"drink\", \"potion\")",
			["tag"] = L(SI_AC_DEFAULT_TAG_GENERAL_ITEMS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_CONSUMABLES),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_CONSUMABLES_DESC),
		},
		[13] = 
		{
			["rule"] = "type(\"container\")",
			["tag"] = L(SI_AC_DEFAULT_TAG_GENERAL_ITEMS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_CONTAINER),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_CONTAINER_DESC),
		},
		[14] = 
		{
			["rule"] = "filtertype(\"furnishing\")",
			["tag"] = L(SI_AC_DEFAULT_TAG_GENERAL_ITEMS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_FURNISHING),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_FURNISHING_DESC),
		},
		[15] = 
		{
			["rule"] = "type(\"soul_gem\", \"glyph_armor\", \"glyph_jewelry\", \"glyph_weapon\")",
			["tag"] = L(SI_AC_DEFAULT_TAG_GENERAL_ITEMS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_GLYPHS_AND_GEMS),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_GLYPHS_AND_GEMS_DESC),
		},
		[16] = 
		{
			["rule"] = "isnew()",
			["tag"] = L(SI_AC_DEFAULT_TAG_GENERAL_ITEMS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_NEW),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_NEW_DESC),
		},
		[17] = 
		{
			["rule"] = "type(\"poison\")",
			["tag"] = L(SI_AC_DEFAULT_TAG_GENERAL_ITEMS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_POISON),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_POISON_DESC),
		},
		[18] = 
		{
			["rule"] = "isinquickslot()",
			["tag"] = L(SI_AC_DEFAULT_TAG_GENERAL_ITEMS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_QUICKSLOTS),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_QUICKSLOTS_DESC),
		},
		[19] = 
		{
			["rule"] = "type(\"recipe\",\"racial_style_motif\") or sptype(\"trophy_recipe_fragment\")",
			["tag"] = L(SI_AC_DEFAULT_TAG_GENERAL_ITEMS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_RECIPES_AND_MOTIFS),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_RECIPES_AND_MOTIFS_DESC),
		},
		[20] = 
		{
			["rule"] = "traitstring(\"ornate\") or sptype(\"collectible_monster_trophy\") or type(\"trash\")",
			["tag"] = L(SI_AC_DEFAULT_TAG_GENERAL_ITEMS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_SELLING),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_SELLING_DESC),
		},
		[21] = 
		{
			["rule"] = "isstolen()",
			["tag"] = L(SI_AC_DEFAULT_TAG_GENERAL_ITEMS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_STOLEN),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_STOLEN_DESC),
		},
		[22] = 
		{
			["rule"] = "sptype(\"trophy_survey_report\", \"trophy_treasure_map\")",
			["tag"] = L(SI_AC_DEFAULT_TAG_GENERAL_ITEMS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_TREASURE_MAPS),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_TREASURE_MAPS_DESC),
		},
		[23] = 
		{
			["rule"] = "setindex(1)",
			["tag"] = L(SI_AC_DEFAULT_TAG_IAKONI_GEAR_CHANGER),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_IAKONI_SET_1),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_IAKONI_SET_1_DESC),
		},
		[24] = 
		{
			["rule"] = "setindex(2)",
			["tag"] = L(SI_AC_DEFAULT_TAG_IAKONI_GEAR_CHANGER),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_IAKONI_SET_2),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_IAKONI_SET_2_DESC),
		},
		[25] = 
		{
			["rule"] = "setindex(3)",
			["tag"] = L(SI_AC_DEFAULT_TAG_IAKONI_GEAR_CHANGER),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_IAKONI_SET_3),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_IAKONI_SET_3_DESC),
		},
		[26] = 
		{
			["rule"] = "setindex(4)",
			["tag"] = L(SI_AC_DEFAULT_TAG_IAKONI_GEAR_CHANGER),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_IAKONI_SET_4),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_IAKONI_SET_4_DESC),
		},
		[27] = 
		{
			["rule"] = "setindex(5)",
			["tag"] = L(SI_AC_DEFAULT_TAG_IAKONI_GEAR_CHANGER),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_IAKONI_SET_5),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_IAKONI_SET_5_DESC),
		},
		[28] = 
		{
			["rule"] = "setindex(6)",
			["tag"] = L(SI_AC_DEFAULT_TAG_IAKONI_GEAR_CHANGER),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_IAKONI_SET_6),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_IAKONI_SET_6_DESC),
		},
		[29] = 
		{
			["rule"] = "setindex(7)",
			["tag"] = L(SI_AC_DEFAULT_TAG_IAKONI_GEAR_CHANGER),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_IAKONI_SET_7),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_IAKONI_SET_7_DESC),
		},
		[30] = 
		{
			["rule"] = "setindex(8)",
			["tag"] = L(SI_AC_DEFAULT_TAG_IAKONI_GEAR_CHANGER),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_IAKONI_SET_8),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_IAKONI_SET_8_DESC),
		},
		[31] = 
		{
			["rule"] = "setindex(9)",
			["tag"] = L(SI_AC_DEFAULT_TAG_IAKONI_GEAR_CHANGER),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_IAKONI_SET_9),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_IAKONI_SET_9_DESC),
		},
		[32] = 
		{
			["rule"] = "setindex(10)",
			["tag"] = L(SI_AC_DEFAULT_TAG_IAKONI_GEAR_CHANGER),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_IAKONI_SET_10),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_IAKONI_SET_10_DESC),
		},
		[33] = 
		{
			["rule"] = "filtertype(\"alchemy\")",
			["tag"] = L(SI_AC_DEFAULT_TAG_MATERIALS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_ALCHEMY),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_ALCHEMY_DESC),
		},
		[34] = 
		{
			["rule"] = "filtertype(\"blacksmithing\")",
			["tag"] = L(SI_AC_DEFAULT_TAG_MATERIALS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_BLACKSMITHING),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_BLACKSMITHING_DESC),
		},
		[35] = 
		{
			["rule"] = "filtertype(\"clothing\")",
			["tag"] = L(SI_AC_DEFAULT_TAG_MATERIALS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_CLOTHING),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_CLOTHING_DESC),
		},
		[36] = 
		{
			["rule"] = "filtertype(\"enchanting\")",
			["tag"] = L(SI_AC_DEFAULT_TAG_MATERIALS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_ENCHANTING),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_ENCHANTING_DESC),
		},
		[37] = 
		{
			["rule"] = "filtertype(\"jewelrycrafting\")",
			["tag"] = L(SI_AC_DEFAULT_TAG_MATERIALS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_JEWELRYCRAFTING),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_JEWELRYCRAFTING_DESC),
		},
		[38] = 
		{
			["rule"] = "filtertype(\"provisioning\")",
			["tag"] = L(SI_AC_DEFAULT_TAG_MATERIALS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_PROVISIONING),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_PROVISIONING_DESC),
		},
		[39] = 
		{
			["rule"] = "filtertype(\"trait_items\", \"style_materials\")",
			["tag"] = L(SI_AC_DEFAULT_TAG_MATERIALS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_TRAIT_OR_STYLE_GEMS),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_TRAIT_OR_STYLE_GEMS_DESC),
		},
		[40] = 
		{
			["rule"] = "filtertype(\"woodworking\")",
			["tag"] = L(SI_AC_DEFAULT_TAG_MATERIALS),
			["name"] = L(SI_AC_DEFAULT_CATEGORY_WOODWORKING),
			["damaged"] = false,
			["description"] = L(SI_AC_DEFAULT_CATEGORY_WOODWORKING_DESC),
		},
		[41] = 
		{
			["tag"] = "FCOIS",
			["rule"] = "ismarked(\"deconstruction\")",
			["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DECONSTRUCTION_MARK_DESC),
			["damaged"] = false,
			["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DECONSTRUCTION_MARK),
		},
		[42] = 
		{
			["tag"] = "FCOIS",
			["rule"] = "ismarked(\"dynamic_1\")",
			["damaged"] = false,
			["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_1),
			["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_1_DESC),
		},
		[43] = 
		{
			["tag"] = "FCOIS",
			["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_2),
			["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_2_DESC),
			["rule"] = "ismarked(\"dynamic_2\")",
			["description"] = "",
		},
		[44] = 
		{
			["tag"] = "FCOIS",
			["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_3),
			["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_3_DESC),
			["rule"] = "ismarked(\"dynamic_3\")",
			["description"] = "",
		},
		[45] = 
		{
			["tag"] = "FCOIS",
			["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_4),
			["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_4_DESC),
			["rule"] = "ismarked(\"dynamic_4\")",
			["description"] = "",
		},
		[46] = 
		{
			["tag"] = "FCOIS",
			["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_5),
			["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_5_DESC),
			["rule"] = "ismarked(\"dynamic_5\")",
			["description"] = "",
		},
		[47] = 
		{
			["tag"] = "FCOIS",
			["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_6),
			["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_6_DESC),
			["rule"] = "ismarked(\"dynamic_6\")",
			["description"] = "",
		},
		[48] = 
		{
			["tag"] = "FCOIS",
			["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_7),
			["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_7_DESC),
			["rule"] = "ismarked(\"dynamic_7\")",
			["description"] = "",
		},
		[49] = 
		{
			["tag"] = "FCOIS",
			["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_8),
			["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_8_DESC),
			["rule"] = "ismarked(\"dynamic_8\")",
			["description"] = "",
		},
		[50] = 
		{
			["tag"] = "FCOIS",
			["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_9),
			["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_9_DESC),
			["rule"] = "ismarked(\"dynamic_9\")",
			["description"] = "",
		},
		[51] = 
		{
			["tag"] = "FCOIS",
			["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_10),
			["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_10_DESC),
			["rule"] = "ismarked(\"dynamic_10\")",
			["description"] = "",
		},
		[52] = 
		{
			["tag"] = "FCOIS",
			["rule"] = "ismarked(\"gear_1\")",
			["damaged"] = false,
			["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_GEAR_1),
			["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_GEAR_1_DESC),
		},
		[53] = 
		{
			["tag"] = "FCOIS",
			["rule"] = "ismarked(\"gear_2\")", 
			["damaged"] = false,
			["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_GEAR_2),
			["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_GEAR_2_DESC),
		},
		[54] = 
		{
			["tag"] = "FCOIS",
			["rule"] = "ismarked(\"gear_3\")", 
			["damaged"] = false,
			["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_GEAR_3),
			["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_GEAR_3_DESC),
		},
		[55] = 
		{
			["tag"] = "FCOIS",
			["rule"] = "ismarked(\"gear_4\")", 
			["damaged"] = false,
			["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_GEAR_4),
			["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_GEAR_4_DESC),
		},
		[56] = 
		{
			["tag"] = "FCOIS",
			["rule"] = "ismarked(\"gear_5\")", 
			["damaged"] = false,
			["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_GEAR_5),
			["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_GEAR_5_DESC),
		},
		[57] = 
		{
			["tag"] = "FCOIS",
			["rule"] = "ismarked(\"improvement\")",
			["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_IMPROVEMENT_MARK_DESC),
			["damaged"] = false,
			["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_IMPROVEMENT_MARK),
		},
		[58] = 
		{
			["tag"] = "FCOIS",
			["rule"] = "ismarked(\"intricate\")",
			["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_INTRICATE_MARK_DESC),
			["damaged"] = false,
			["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_INTRICATE_MARK),
		},
		[59] = 
		{
			["tag"] = "FCOIS",
			["rule"] = "ismarked(\"research\")",
			["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_RESEARCH_MARK_DESC),
			["damaged"] = false,
			["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_RESEARCH_MARK),
		},
		[60] = 
		{
			["tag"] = "FCOIS",
			["rule"] = "ismarked(\"sell_at_guildstore\")",
			["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_SELL_AT_GUILDSTORE_MARK_DESC),
			["damaged"] = false,
			["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_SELL_AT_GUILDSTORE_MARK),
		},
		[61] = 
		{
			["tag"] = "FCOIS",
			["rule"] = "ismarked(\"sell\")",
			["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_SELL_MARK_DESC),
			["damaged"] = false,
			["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_SELL_MARK),
		},
		[62] = 
		{
			["tag"] = "FCOIS",
			["rule"] = "ismarked(\"lock\")",
			["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_LOCK_MARK_DESC),
			["damaged"] = false,
			["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_LOCK_MARK),
		},
		[63] = 
		{
			["tag"] = "FCOIS",
			["rule"] = "ismarked()",
			["description"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_ALL_MARK_DESC),
			["damaged"] = false,
			["name"] = L(SI_AC_DEFAULT_CATEGORY_FCOIS_ALL_MARK),
		},
	},
	bags = {
		[AC_BAG_TYPE_BACKPACK] = {
			rules = {
				[1] = 
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOP_TRADEABLE),
				},
				[2] = 
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NEW),
				},
				[3] = 
				{
					["priority"] = 95,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONTAINER),
				},
				[4] = 
				{
					["priority"] = 90,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SELLING),
				},
				[5] = 
				{
					["priority"] = 85,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_LOW_LEVEL),
				},
				[6] = 
				{
					["priority"] = 80,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT),
				},
				[7] = 
				{
					["priority"] = 70,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOE),
				},
				[8] = 
				{
					["priority"] = 60,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RESEARCHABLE),
				},
				[9] = 
				{
					["priority"] = 50,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_EQUIPPING),
				},
				[10] = 
				{
					["priority"] = 49,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SET),
				},
				[11] = 
				{
					["priority"] = 48,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WEAPON),
				},
				[12] = 
				{
					["priority"] = 47,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_POISON),
				},
				[13] = 
				{
					["priority"] = 46,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ARMOR),
				},
				[14] = 
				{
					["priority"] = 45,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NECKLACE),
				},
				[15] = 
				{
					["priority"] = 45,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RING),
				},
				[16] = 
				{
					["priority"] = 40,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_QUICKSLOTS),
				},
				[17] = 
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONSUMABLES),
				},
				[18] = 
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_GLYPHS_AND_GEMS),
				},
				[19] = 
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RECIPES_AND_MOTIFS),
				},
				[20] = 
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TREASURE_MAPS),
				},
				[21] = 
				{
					["priority"] = 30,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_FURNISHING),
				},
				[22] = 
				{
					["priority"] = 20,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_STOLEN),
				},
				[23] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ALCHEMY),
				},
				[24] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BLACKSMITHING),
				},
				[25] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CLOTHING),
				},
				[26] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ENCHANTING),
				},
				[27] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_PROVISIONING),
				},
				[28] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TRAIT_OR_STYLE_GEMS),
				},
				[29] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WOODWORKING),
				},
			},
		},
		[AC_BAG_TYPE_BANK] = {
			rules = {
				[1] = 
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOP_TRADEABLE),
				},
				[2] = 
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NEW),
				},
				[3] = 
				{
					["priority"] = 95,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONTAINER),
				},
				[4] = 
				{
					["priority"] = 90,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SELLING),
				},
				[5] = 
				{
					["priority"] = 85,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_LOW_LEVEL),
				},
				[6] = 
				{
					["priority"] = 80,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT),
				},
				[7] = 
				{
					["priority"] = 70,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOE),
				},
				[8] = 
				{
					["priority"] = 60,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RESEARCHABLE),
				},
				[9] = 
				{
					["priority"] = 50,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_EQUIPPING),
				},
				[10] = 
				{
					["priority"] = 49,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SET),
				},
				[11] = 
				{
					["priority"] = 48,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WEAPON),
				},
				[12] = 
				{
					["priority"] = 47,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_POISON),
				},
				[13] = 
				{
					["priority"] = 46,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ARMOR),
				},
				[14] = 
				{
					["priority"] = 45,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NECKLACE),
				},
				[15] = 
				{
					["priority"] = 45,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RING),
				},
				[16] = 
				{
					["priority"] = 40,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_QUICKSLOTS),
				},
				[17] = 
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONSUMABLES),
				},
				[18] = 
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_GLYPHS_AND_GEMS),
				},
				[19] = 
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RECIPES_AND_MOTIFS),
				},
				[20] = 
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TREASURE_MAPS),
				},
				[21] = 
				{
					["priority"] = 30,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_FURNISHING),
				},
				[22] = 
				{
					["priority"] = 20,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_STOLEN),
				},
				[23] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ALCHEMY),
				},
				[24] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BLACKSMITHING),
				},
				[25] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CLOTHING),
				},
				[26] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ENCHANTING),
				},
				[27] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_PROVISIONING),
				},
				[28] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TRAIT_OR_STYLE_GEMS),
				},
				[29] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WOODWORKING),
				},
			},
		},
		[AC_BAG_TYPE_GUILDBANK] = {
			rules = {
				[1] = 
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOP_TRADEABLE),
				},
				[2] = 
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NEW),
				},
				[3] = 
				{
					["priority"] = 95,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONTAINER),
				},
				[4] = 
				{
					["priority"] = 90,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SELLING),
				},
				[5] = 
				{
					["priority"] = 85,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_LOW_LEVEL),
				},
				[6] = 
				{
					["priority"] = 80,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT),
				},
				[7] = 
				{
					["priority"] = 70,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOE),
				},
				[8] = 
				{
					["priority"] = 60,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RESEARCHABLE),
				},
				[9] = 
				{
					["priority"] = 50,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_EQUIPPING),
				},
				[10] = 
				{
					["priority"] = 49,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SET),
				},
				[11] = 
				{
					["priority"] = 48,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WEAPON),
				},
				[12] = 
				{
					["priority"] = 47,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_POISON),
				},
				[13] = 
				{
					["priority"] = 46,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ARMOR),
				},
				[14] = 
				{
					["priority"] = 45,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NECKLACE),
				},
				[15] = 
				{
					["priority"] = 45,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RING),
				},
				[16] = 
				{
					["priority"] = 40,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_QUICKSLOTS),
				},
				[17] = 
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONSUMABLES),
				},
				[18] = 
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_GLYPHS_AND_GEMS),
				},
				[19] = 
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RECIPES_AND_MOTIFS),
				},
				[20] = 
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TREASURE_MAPS),
				},
				[21] = 
				{
					["priority"] = 30,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_FURNISHING),
				},
				[22] = 
				{
					["priority"] = 20,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_STOLEN),
				},
				[23] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ALCHEMY),
				},
				[24] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BLACKSMITHING),
				},
				[25] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CLOTHING),
				},
				[26] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ENCHANTING),
				},
				[27] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_PROVISIONING),
				},
				[28] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TRAIT_OR_STYLE_GEMS),
				},
				[29] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WOODWORKING),
				},
			},
		},
		[AC_BAG_TYPE_CRAFTBAG] = {
			rules = {
				[1] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BLACKSMITHING),
				},
				[2] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CLOTHING),
				},
				[3] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WOODWORKING),
				},
				[4] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ALCHEMY),
				},
				[5] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ENCHANTING),
				},
				[6] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_PROVISIONING),
				},
				[7] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TRAIT_OR_STYLE_GEMS),
				},
			},
		},
		[AC_BAG_TYPE_CRAFTSTATION] = {
			rules = {
				[1] = 
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOP_TRADEABLE),
				},
				[2] = 
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NEW),
				},
				[3] = 
				{
					["priority"] = 95,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONTAINER),
				},
				[4] = 
				{
					["priority"] = 90,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SELLING),
				},
				[5] = 
				{
					["priority"] = 85,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_LOW_LEVEL),
				},
				[6] = 
				{
					["priority"] = 80,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT),
				},
				[7] = 
				{
					["priority"] = 70,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOE),
				},
				[8] = 
				{
					["priority"] = 60,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RESEARCHABLE),
				},
				[9] = 
				{
					["priority"] = 50,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_EQUIPPING),
				},
				[10] = 
				{
					["priority"] = 49,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SET),
				},
				[11] = 
				{
					["priority"] = 48,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WEAPON),
				},
				[12] = 
				{
					["priority"] = 47,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_POISON),
				},
				[13] = 
				{
					["priority"] = 46,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ARMOR),
				},
				[14] = 
				{
					["priority"] = 45,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NECKLACE),
				},
				[15] = 
				{
					["priority"] = 45,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RING),
				},
				[16] = 
				{
					["priority"] = 40,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_QUICKSLOTS),
				},
				[17] = 
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONSUMABLES),
				},
				[18] = 
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_GLYPHS_AND_GEMS),
				},
				[19] = 
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RECIPES_AND_MOTIFS),
				},
				[20] = 
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TREASURE_MAPS),
				},
				[21] = 
				{
					["priority"] = 30,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_FURNISHING),
				},
				[22] = 
				{
					["priority"] = 20,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_STOLEN),
				},
				[23] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ALCHEMY),
				},
				[24] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BLACKSMITHING),
				},
				[25] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CLOTHING),
				},
				[26] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ENCHANTING),
				},
				[27] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_PROVISIONING),
				},
				[28] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TRAIT_OR_STYLE_GEMS),
				},
				[29] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WOODWORKING),
				},
			},
		},
		[AC_BAG_TYPE_HOUSEBANK] = {
			rules = {
				[1] = 
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOP_TRADEABLE),
				},
				[2] = 
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NEW),
				},
				[3] = 
				{
					["priority"] = 95,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONTAINER),
				},
				[4] = 
				{
					["priority"] = 90,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SELLING),
				},
				[5] = 
				{
					["priority"] = 85,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_LOW_LEVEL),
				},
				[6] = 
				{
					["priority"] = 80,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT),
				},
				[7] = 
				{
					["priority"] = 70,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOE),
				},
				[8] = 
				{
					["priority"] = 60,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RESEARCHABLE),
				},
				[9] = 
				{
					["priority"] = 50,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_EQUIPPING),
				},
				[10] = 
				{
					["priority"] = 49,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SET),
				},
				[11] = 
				{
					["priority"] = 48,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WEAPON),
				},
				[12] = 
				{
					["priority"] = 47,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_POISON),
				},
				[13] = 
				{
					["priority"] = 46,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ARMOR),
				},
				[14] = 
				{
					["priority"] = 45,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NECKLACE),
				},
				[15] = 
				{
					["priority"] = 45,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RING),
				},
				[16] = 
				{
					["priority"] = 40,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_QUICKSLOTS),
				},
				[17] = 
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONSUMABLES),
				},
				[18] = 
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_GLYPHS_AND_GEMS),
				},
				[19] = 
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RECIPES_AND_MOTIFS),
				},
				[20] = 
				{
					["priority"] = 35,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TREASURE_MAPS),
				},
				[21] = 
				{
					["priority"] = 30,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_FURNISHING),
				},
				[22] = 
				{
					["priority"] = 20,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_STOLEN),
				},
				[23] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ALCHEMY),
				},
				[24] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BLACKSMITHING),
				},
				[25] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CLOTHING),
				},
				[26] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ENCHANTING),
				},
				[27] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_PROVISIONING),
				},
				[28] = 
				{
					["priority"] = 10,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TRAIT_OR_STYLE_GEMS),
				},
				[29] = 
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
		["CATEGORY_FONT_COLOR"] = 
		{
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
}