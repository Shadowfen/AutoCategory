local L = GetString

AutoCategory.predefinedRules =  {
    {
        ["rule"] = "type(\"armor\") and not equiptype(\"neck\",\"ring\")",
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
        ["rule"] = "level() > 1 and cp() < 160 and type(\"armor\", \"weapon\")",
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
	--rules = AutoCategory.predefinedRules,
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
	appearance = {
		["CATEGORY_FONT_NAME"] = "Univers 67",
		["CATEGORY_FONT_STYLE"] = "soft-shadow-thin",
		["CATEGORY_FONT_COLOR"] =  {
			[1] = 1,
			[2] = 1,
			[3] = 1,
			[4] = 1,
		},
		["HIDDEN_CATEGORY_FONT_COLOR"] =  {
			[1] = 125,
			[2] = 125,
			[3] = 125,
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
		["SHOW_CATEGORY_COLLAPSE_ICON"] = true,
		["SAVE_CATEGORY_COLLAPSE_STATUS"] = false,
		["SHOW_CATEGORY_SET_TITLE"] = true,
	},
    collapses = AutoCategory.defaultCollapses,
}
AutoCategory.defaultAcctBagSettings = {
	bags = {
		[AC_BAG_TYPE_BACKPACK] = {
			rules = {
				{
					["priority"] = 1000,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOP_TRADEABLE),
				},
				{
					["priority"] = 1000,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NEW),
				},
				{
					["priority"] = 950,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONTAINER),
				},
				{
					["priority"] = 900,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SELLING),
				},
				{
					["priority"] = 850,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_LOW_LEVEL),
				},
				{
					["priority"] = 800,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT),
				},
				{
					["priority"] = 700,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOE),
				},
				{
					["priority"] = 600,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RESEARCHABLE),
				},
				{
					["priority"] = 500,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_EQUIPPING),
				},
				{
					["priority"] = 490,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SET),
				},
				{
					["priority"] = 480,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WEAPON),
				},
				{
					["priority"] = 470,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_POISON),
				},
				{
					["priority"] = 460,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ARMOR),
				},
				{
					["priority"] = 450,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NECKLACE),
				},
				{
					["priority"] = 450,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RING),
				},
				{
					["priority"] = 400,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_QUICKSLOTS),
				},
				{
					["priority"] = 350,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONSUMABLES),
				},
				{
					["priority"] = 350,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_GLYPHS_AND_GEMS),
				},
				{
					["priority"] = 350,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RECIPES_AND_MOTIFS),
				},
				{
					["priority"] = 350,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TREASURE_MAPS),
				},
				{
					["priority"] = 300,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_FURNISHING),
				},
				{
					["priority"] = 200,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_STOLEN),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ALCHEMY),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BLACKSMITHING),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CLOTHING),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ENCHANTING),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_PROVISIONING),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TRAIT_OR_STYLE_GEMS),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WOODWORKING),
				},
			},
		},
		[AC_BAG_TYPE_BANK] = {
			rules = {
				{
					["priority"] = 1000,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOP_TRADEABLE),
				},
				{
					["priority"] = 1000,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NEW),
				},
				{
					["priority"] = 950,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONTAINER),
				},
				{
					["priority"] = 900,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SELLING),
				},
				{
					["priority"] = 850,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_LOW_LEVEL),
				},
				{
					["priority"] = 800,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT),
				},
				{
					["priority"] = 700,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOE),
				},
				{
					["priority"] = 600,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RESEARCHABLE),
				},
				{
					["priority"] = 500,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_EQUIPPING),
				},
				{
					["priority"] = 490,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SET),
				},
				{
					["priority"] = 480,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WEAPON),
				},
				{
					["priority"] = 470,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_POISON),
				},
				{
					["priority"] = 460,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ARMOR),
				},
				{
					["priority"] = 450,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NECKLACE),
				},
				{
					["priority"] = 450,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RING),
				},
				{
					["priority"] = 400,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_QUICKSLOTS),
				},
				{
					["priority"] = 350,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONSUMABLES),
				},
				{
					["priority"] = 350,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_GLYPHS_AND_GEMS),
				},
				{
					["priority"] = 350,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RECIPES_AND_MOTIFS),
				},
				{
					["priority"] = 350,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TREASURE_MAPS),
				},
				{
					["priority"] = 300,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_FURNISHING),
				},
				{
					["priority"] = 200,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_STOLEN),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ALCHEMY),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BLACKSMITHING),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CLOTHING),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ENCHANTING),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_PROVISIONING),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TRAIT_OR_STYLE_GEMS),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WOODWORKING),
				},
			},
		},
		[AC_BAG_TYPE_GUILDBANK] = {
			rules = {
				{
					["priority"] = 1000,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOP_TRADEABLE),
				},
				{
					["priority"] = 1000,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NEW),
				},
				{
					["priority"] = 950,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONTAINER),
				},
				{
					["priority"] = 900,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SELLING),
				},
				{
					["priority"] = 850,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_LOW_LEVEL),
				},
				{
					["priority"] = 800,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT),
				},
				{
					["priority"] = 700,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOE),
				},
				{
					["priority"] = 600,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RESEARCHABLE),
				},
				{
					["priority"] = 500,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_EQUIPPING),
				},
				{
					["priority"] = 490,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SET),
				},
				{
					["priority"] = 480,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WEAPON),
				},
				{
					["priority"] = 470,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_POISON),
				},
				{
					["priority"] = 460,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ARMOR),
				},
				{
					["priority"] = 450,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NECKLACE),
				},
				{
					["priority"] = 450,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RING),
				},
				{
					["priority"] = 400,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_QUICKSLOTS),
				},
				{
					["priority"] = 350,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONSUMABLES),
				},
				{
					["priority"] = 350,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_GLYPHS_AND_GEMS),
				},
				{
					["priority"] = 350,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RECIPES_AND_MOTIFS),
				},
				{
					["priority"] = 350,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TREASURE_MAPS),
				},
				{
					["priority"] = 300,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_FURNISHING),
				},
				{
					["priority"] = 200,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_STOLEN),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ALCHEMY),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BLACKSMITHING),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CLOTHING),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ENCHANTING),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_PROVISIONING),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TRAIT_OR_STYLE_GEMS),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WOODWORKING),
				},
			},
		},
		[AC_BAG_TYPE_CRAFTBAG] = {
			rules = {
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BLACKSMITHING),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CLOTHING),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WOODWORKING),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ALCHEMY),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ENCHANTING),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_PROVISIONING),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TRAIT_OR_STYLE_GEMS),
				},
			},
		},
		[AC_BAG_TYPE_CRAFTSTATION] = {
			rules = {
				{
					["priority"] = 1000,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOP_TRADEABLE),
				},
				{
					["priority"] = 1000,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NEW),
				},
				{
					["priority"] = 950,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONTAINER),
				},
				{
					["priority"] = 900,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SELLING),
				},
				{
					["priority"] = 850,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_LOW_LEVEL),
				},
				{
					["priority"] = 800,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT),
				},
				{
					["priority"] = 700,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOE),
				},
				{
					["priority"] = 600,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RESEARCHABLE),
				},
				{
					["priority"] = 500,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_EQUIPPING),
				},
				{
					["priority"] = 490,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SET),
				},
				{
					["priority"] = 480,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WEAPON),
				},
				{
					["priority"] = 470,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_POISON),
				},
				{
					["priority"] = 460,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ARMOR),
				},
				{
					["priority"] = 450,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NECKLACE),
				},
				{
					["priority"] = 450,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RING),
				},
				{
					["priority"] = 400,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_QUICKSLOTS),
				},
				{
					["priority"] = 350,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONSUMABLES),
				},
				{
					["priority"] = 350,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_GLYPHS_AND_GEMS),
				},
				{
					["priority"] = 350,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RECIPES_AND_MOTIFS),
				},
				{
					["priority"] = 350,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TREASURE_MAPS),
				},
				{
					["priority"] = 300,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_FURNISHING),
				},
				{
					["priority"] = 200,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_STOLEN),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ALCHEMY),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BLACKSMITHING),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CLOTHING),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ENCHANTING),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_PROVISIONING),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TRAIT_OR_STYLE_GEMS),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WOODWORKING),
				},
			},
		},
		[AC_BAG_TYPE_HOUSEBANK] = {
			rules = {
				{
					["priority"] = 1000,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOP_TRADEABLE),
				},
				{
					["priority"] = 1000,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NEW),
				},
				{
					["priority"] = 950,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONTAINER),
				},
				{
					["priority"] = 900,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SELLING),
				},
				{
					["priority"] = 850,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_LOW_LEVEL),
				},
				{
					["priority"] = 800,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT),
				},
				{
					["priority"] = 700,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BOE),
				},
				{
					["priority"] = 600,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RESEARCHABLE),
				},
				{
					["priority"] = 500,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_EQUIPPING),
				},
				{
					["priority"] = 490,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_SET),
				},
				{
					["priority"] = 480,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WEAPON),
				},
				{
					["priority"] = 470,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_POISON),
				},
				{
					["priority"] = 460,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ARMOR),
				},
				{
					["priority"] = 450,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_NECKLACE),
				},
				{
					["priority"] = 450,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RING),
				},
				{
					["priority"] = 400,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_QUICKSLOTS),
				},
				{
					["priority"] = 350,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CONSUMABLES),
				},
				{
					["priority"] = 350,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_GLYPHS_AND_GEMS),
				},
				{
					["priority"] = 350,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_RECIPES_AND_MOTIFS),
				},
				{
					["priority"] = 350,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TREASURE_MAPS),
				},
				{
					["priority"] = 300,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_FURNISHING),
				},
				{
					["priority"] = 200,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_STOLEN),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ALCHEMY),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_BLACKSMITHING),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_CLOTHING),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_ENCHANTING),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_PROVISIONING),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_TRAIT_OR_STYLE_GEMS),
				},
				{
					["priority"] = 100,
					["name"] = L(SI_AC_DEFAULT_CATEGORY_WOODWORKING),
				},
			},
		},
	}, 
}

AutoCategory.defaultCharSettings = {
	bags = AutoCategory.defaultAcctBagSettings.bags, 
    collapses = AutoCategory.defaultCollapses,
}

