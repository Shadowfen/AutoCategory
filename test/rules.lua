require "AutoCategory.test.zos"
require "AutoCategory.test.tk"
local TK = TestKit

local TR = test_run
local d = print

require "LibSFUtils.LibSFUtils_Global"
require "LibSFUtils.SFUtils_Color"
require "LibSFUtils.LibSFUtils"
require "LibSFUtils.SFUtils_LoadLanguage"
require "LibSFUtils.SFUtils_Tables"

local SF=LibSFUtils
require "AutoCategory.AutoCategory_Global"

local AC = AutoCategory

AC.acctRules= { rules = {} }
AC["srules"] = 
    {
        [1] = 
        {
            ["rule"] = "filtertype(\"alchemy\")",
            ["name"] = "Alchemy",
            ["tag"] = "Materials",
            ["description"] = "",
         },
        [2] = 
        {
            ["rule"] = "fco_ismarked()",
            ["name"] = "All Marks",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [3] = 
        {
            ["rule"] = "isunknown()",
            ["name"] = "All Unknown",
            ["tag"] = "General Items",
            ["description"] = "",
        },
        [4] = 
        {
            ["rule"] = "alphagear(\"1\", \"2\", \"3\", \"4\", \"5\", \"6\", \"7\", \"8\", \"9\", \"10\", \"11\", \"12\", \"13\", \"14\", \"15\", \"16\")",
            ["name"] = "AlphaGear",
            ["tag"] = "Gears",
            ["description"] = "",
        },
        [5] = 
        {
            ["rule"] = "type(\"armor\") \nand not equiptype(\"neck\", \"ring\")",
            ["name"] = "Armor",
            ["tag"] = "Gears",
            ["description"] = "",
        },
        [6] = 
        {
            ["rule"] = "filtertype(\"blacksmithing\")",
            ["name"] = "Blacksmithing",
            ["tag"] = "Materials",
            ["description"] = "",
        },
        [7] = 
        {
            ["rule"] = "boundtype(\"on_equip\") and not isbound() and not keepresearch()",
            ["name"] = "BoE",
            ["tag"] = "Gears",
            ["description"] = "BoE gears for selling",
        },
        [8] = 
        {
            ["rule"] = "isboptradeable()",
            ["name"] = "BoP Tradeable",
            ["tag"] = "Gears",
            ["description"] = "Gears are tradeable within a limited time",
        },
        [9] = 
        {
            ["rule"] = "ischarbound()",
            ["name"] = "CharBound",
            ["tag"] = "Gears",
            ["description"] = "",
        },
        [10] = 
        {
            ["rule"] = "ck_isknowncat() and not ck_isknown(\"Shade Windwalker\")",
            ["name"] = "CharKnowledge",
            ["tag"] = "Gears",
            ["description"] = "",
        },
        [11] = 
        {
            ["rule"] = "type(\"armor\") and armortype(\"light\",\"medium\")",
            ["name"] = "Cloth",
            ["tag"] = "Materials",
            ["description"] = "",
        },
        [12] = 
        {
            ["rule"] = "filtertype(\"clothing\")",
            ["name"] = "Clothing",
            ["tag"] = "Materials",
            ["description"] = "",
        },
        [13] = 
        {
            ["rule"] = "iscompaniononly()",
            ["name"] = "Companion",
            ["tag"] = "Gears",
            ["description"] = "",
        },
        [14] = 
        {
            ["rule"] = "type(\"food\", \"drink\", \"potion\")",
            ["name"] = "Consumables",
            ["tag"] = "General Items",
            ["description"] = "Food, Drink, Potion",
        },
        [15] = 
        {
            ["rule"] = "type(\"container\",\"container_currency\")",
            ["name"] = "Container",
            ["tag"] = "General Items",
            ["description"] = "",
        },
        [16] = 
        {
            ["rule"] = "type(\"container\",\"container_currency\")",
            ["name"] = "Container1",
            ["tag"] = "General Items",
            ["description"] = "",
        },
        [17] = 
        {
            ["rule"] = "type(\"crown_item\")",
            ["name"] = "Crown",
            ["tag"] = "General Items",
            ["description"] = "",
        },
        [18] = 
        {
            ["rule"] = "sptype(\"siege_ballista\", \"siege_battle_standard\", \"siege_catapult\", \"siege_oil\", \"siege_ram\", \"siege_trebuchet\", \"siege_lancer\", \"siege_graveyard\", \"siege_universal\", \"recall_stone_keep\", \"ava_repair\")",
            ["name"] = "Cyrodiil",
            ["tag"] = "General Items",
            ["description"] = "",
        },
        [19] = 
        {
            ["rule"] = "not cannotdecon()\nand not islocked()\nand  ( \n    im_ismarked(\"Destroy\", \"Decon\")\n    or  ( type(\"weapon\") and not isset() )\n    or  ( type(\"armor\") and traitstring(\"intricate\",\"invigorating\",\"training\") )\n    or  ( type(\"armor\") and equiptype(\"head\",\"shoulders\") and getquality() < 3 )\n )",
            ["name"] = "Decon",
            ["tag"] = "Gears",
            ["description"] = "",
        },
        [20] = 
        {
            ["rule"] = "isinbackpack() \r\n  and not ismonsterset() \r\n  and \r\n    (\r\n\t  im_ismarked(\"Decon\") \r\n\t  or istracked(\"Sell/Decon\") \r\n\t  or (\r\n\t    type(\"armor\") and\r\n\t    traitstring(\"intricate\",\"invigorating\",\"training\")\r\n\t  ) \r\n\t  or (type(\"armor\", \"weapon\") and not isset()) \r\n\t  or (\r\n\t    equiptype(\"head\",\"shoulders\") and\r\n\t    traitstring(\"intricate\",\"invigorating\",\"training\") \r\n\t  )\r\n\t)",
            ["name"] = "DeconInv",
            ["tag"] = "Gears",
            ["description"] = "",
        },
        [21] = 
        {
            ["rule"] = "isinbackpack() \r and not islocked() and not isset() \rand not  im_ismarked(\"Sell\")  and type(\"armor\", weapon)",
            ["name"] = "DeconJunkArmor",
            ["tag"] = "Gears",
            ["description"] = "",
        },
        [22] = 
        {
            ["rule"] = "isinbank() and not ismonsterset() \nand (\n  im_ismarked(\"Decon\") \n  or istracked(\"Sell/Decon\") \n  or (\n    type(\"armor\") and not isset() \n   and traitstring(\"intricate\",\"invigorating\",\"training\") \n  )  or (type(\"weapon\") and not isset()\n  )  or (\n    equiptype(\"head\",\"shoulders\") \n    and  traitstring(\"intricate\",\"invigorating\",\"training\") \n  ))",
            ["name"] = "Deconstruct_From_Bank",
            ["tag"] = "Gears",
            ["description"] = "",
        },
        [23] = 
        {
            ["rule"] = "ismarked(\"deconstruction\")",
            ["name"] = "Deconstruction Mark",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [24] = 
        {
            ["rule"] = "im_ismarked(\"Destroy\")",
            ["name"] = "Destroy",
            ["tag"] = "Gears",
            ["description"] = "",
        },
        [25] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_1\")",
            ["name"] = "Dynamic 1",
            ["tag"] = "FCOIS",
            ["description"] = "",
            
        },
        [26] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_2\")",
            ["name"] = "Dynamic 2",
            ["tag"] = "FCOIS",
            ["description"] = "",
            
        },
        [27] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_3\")",
            ["name"] = "Dynamic 3",
            ["tag"] = "FCOIS",
            ["description"] = "",
            
        },
        [28] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_4\")",
            ["name"] = "Dynamic 4",
            ["tag"] = "FCOIS",
            ["description"] = "",
            
        },
        [29] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_5\")",
            ["name"] = "Dynamic 5",
            ["tag"] = "FCOIS",
            ["description"] = "",
            
        },
        [30] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_6\")",
            ["name"] = "Dynamic 6",
            ["tag"] = "FCOIS",
            ["description"] = "",
            
        },
        [31] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_7\")",
            ["name"] = "Dynamic 7",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [32] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_8\")",
            ["name"] = "Dynamic 8",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [33] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_9\")",
            ["name"] = "Dynamic 9",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [34] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_10\")",
            ["name"] = "Dynamic 10",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [35] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_11\")",
            ["name"] = "Dynamic 11",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [36] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_12\")",
            ["name"] = "Dynamic 12",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [37] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_13\")",
            ["name"] = "Dynamic 13",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [38] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_14\")",
            ["name"] = "Dynamic 14",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [39] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_15\")",
            ["name"] = "Dynamic 15",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [40] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_16\")",
            ["name"] = "Dynamic 16",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [41] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_17\")",
            ["name"] = "Dynamic 17",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [42] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_18\")",
            ["name"] = "Dynamic 18",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [43] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_19\")",
            ["name"] = "Dynamic 19",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [44] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_20\")",
            ["name"] = "Dynamic 20",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [45] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_21\")",
            ["name"] = "Dynamic 21",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [46] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_22\")",
            ["name"] = "Dynamic 22",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [47] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_23\")",
            ["name"] = "Dynamic 23",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [48] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_24\")",
            ["name"] = "Dynamic 24",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [49] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_25\")",
            ["name"] = "Dynamic 25",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [50] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_26\")",
            ["name"] = "Dynamic 26",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [51] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_27\")",
            ["name"] = "Dynamic 27",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [52] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_28\")",
            ["name"] = "Dynamic 28",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [53] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_29\")",
            ["name"] = "Dynamic 29",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [54] = 
        {
            ["rule"] = "fco_ismarked(\"dynamic_30\")",
            ["name"] = "Dynamic 30",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [55] = 
        {
            ["rule"] = "filtertype(\"enchanting\")",
            ["name"] = "Enchanting",
            ["tag"] = "Materials",
            ["description"] = "",
        },
        [56] = 
        {
            ["rule"] = "isequipping()",
            ["name"] = "Equipping",
            ["tag"] = "Gears",
            ["description"] = "Currently equipping gears (Gamepad Only)",
        },
        [57] = 
        {
            ["rule"] = " isunknown(\"Cara Windwalker\") or (ck_isknowncat() and not ck_isknown(\"Cara Windwalker\"))",
            ["name"] = "For Cara",
            ["tag"] = "UnknownTrackers",
            ["description"] = "",
        },
        [58] = 
        {
            ["rule"] = "isunknown(\"Kethry Ravenborn\")",
            ["name"] = "For Kethry",
            ["tag"] = "UnknownTracker",
            ["description"] = "",
        },
        [59] = 
        {
            ["rule"] = " isunknown(\"River Windwalker\") or (ck_isknowncat() and not ck_isknown(\"River Windwalker\"))",
            ["name"] = "For River",
            ["tag"] = "UnknownTrackers",
            ["description"] = "",
        },
        [60] = 
        {
            ["rule"] = "getpricemm() >5000",
            ["name"] = "For Sale",
            ["tag"] = "Materials",
            ["description"] = "",
        },
        [61] = 
        {
            ["rule"] = " isunknown(\"Ezabi keeps items for you\") or (ck_isknowncat() and not ck_isknown(\"Ezabi keeps items for you\"))",
            ["name"] = "ForEzabi",
            ["tag"] = "UnknownTrackers",
            ["description"] = "",
        },
        [62] = 
        {
            ["rule"] = " isunknown(\"Shade Windwalker\") or (ck_isknowncat() and not ck_isknown(\"Shade Windwalker\"))\n",
            ["name"] = "ForShade",
            ["tag"] = "UnknownTrackers",
            ["description"] = "",
        },
        [63] = 
        {
            ["rule"] = "sptype(\"trophy_runebox_fragment\")",
            ["name"] = "Fragments",
            ["tag"] = "Materials",
            ["description"] = "",
        },
        [64] = 
        {
            ["rule"] = "filtertype(\"furnishing\")",
            ["name"] = "Furnishing",
            ["tag"] = "General Items",
            ["description"] = "",
        },
        [65] = 
        {
            ["rule"] = "fco_ismarked(\"gear_1\")",
            ["name"] = "Gear 1",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [66] = 
        {
            ["rule"] = "fco_ismarked(\"gear_2\")",
            ["name"] = "Gear 2",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [67] = 
        {
            ["rule"] = "fco_ismarked(\"gear_3\")",
            ["name"] = "Gear 3",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [68] = 
        {
            ["rule"] = "fco_ismarked(\"gear_4\")",
            ["name"] = "Gear 4",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [69] = 
        {
            ["rule"] = "fco_ismarked(\"gear_5\")",
            ["name"] = "Gear 5",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [70] = 
        {
            ["rule"] = "itemname(\"geode\")",
            ["name"] = "Geodes",
            ["tag"] = "Materials",
            ["description"] = "",
        },
        [71] = 
        {
            ["rule"] = "type(\"soul_gem\", \"glyph_armor\", \"glyph_jewelry\", \"glyph_weapon\")",
            ["name"] = "Glyphs & Gems",
            ["tag"] = "General Items",
            ["description"] = "",
        },
        [72] = 
        {
            ["rule"] = "fco_ismarked(\"improvement\")",
            ["name"] = "Improvement Mark",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [73] = 
        {
            ["rule"] = "fco_ismarked(\"intricate\")",
            ["name"] = "Intricate Mark",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [74] = 
        {
            ["rule"] = " ck_isknowncat()  and not ck_isknown(\"Nyanna Windwalker\")",
            ["name"] = "isKnownCat",
            ["tag"] = "UnknownTrackers",
            ["description"] = "",
        },
        [75] = 
        {
            ["rule"] = "equiptype(\"neck\",\"ring\")",
            ["name"] = "Jewelry",
            ["tag"] = "Gears",
            ["description"] = "",
        },
        [76] = 
        {
            ["rule"] = "filtertype(\"jewelrycrafting\")",
            ["name"] = "Jewelry Crafting",
            ["tag"] = "Materials",
            ["description"] = "",
        },
        [77] = 
        {
            ["rule"] = "type(\"armor\", \"weapon\")  \r\nand not islocked() \nand (quality(\"white\", \"green\") or not isset())",
            ["name"] = "Junk Gear",
            ["tag"] = "Gears",
            ["description"] = "",
        },
        [78] = 
        {
            ["rule"] = "type(\"armor\", \"weapon\") and (\n  (level() > 1 and level() < charlevel()) \n  or (cp() <160 and cp() < charcp())\n)",
            ["name"] = "LessThan",
            ["tag"] = "Gears",
            ["description"] = "Gears below me",
        },
        [79] = 
        {
            ["rule"] = "fco_ismarked(\"lock\")",
            ["name"] = "Lock Mark",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [80] = 
        {
            ["rule"] = "islockpick()",
            ["name"] = "Lockpicks",
            ["tag"] = "General Items",
            ["description"] = "",
        },
        [81] = 
        {
            ["rule"] = "level() > 1 and cp() < 160 and type(\"armor\", \"weapon\")",
            ["name"] = "Low Level",
            ["tag"] = "Gears",
            ["description"] = "Gears below cp 160",
        },
        [82] = 
        {
            ["rule"] = "sptype(\"trophy_survey_report\", \"trophy_treasure_map\")",
            ["name"] = "Maps & Surveys",
            ["tag"] = "General Items",
            ["description"] = "Treasure maps and survey reports",
        },
        [83] = 
        {
            ["rule"] = "itemname(\" Writ\")",
            ["name"] = "Master Writs",
            ["tag"] = "General Items",
            ["description"] = "",
        },
        [84] = 
        {
            ["rule"] = "ismonsterset()",
            ["name"] = "MonsterSet",
            ["tag"] = "Gears",
            ["description"] = "",
        },
        [85] = 
        {
            ["rule"] = "quality(\"orange\")",
            ["name"] = "Mythic",
            ["tag"] = "General Items",
            ["description"] = "",
        },
        [86] = 
        {
            ["rule"] = "equiptype(\"neck\")",
            ["name"] = "Necklace",
            ["tag"] = "Gears",
            ["description"] = "",
        },
        [87] = 
        {
            ["rule"] = "isnew()",
            ["name"] = "New",
            ["tag"] = "General Items",
            ["description"] = "Items that are received recently",
        },
        [88] = 
        {
            ["rule"] = "isnotcollected() and not islocked()",
            ["name"] = "NotCollected",
            ["tag"] = "Gears",
            ["description"] = "",
        },
        [89] = 
        {
            ["rule"] = "type(\"poison\")",
            ["name"] = "Poison",
            ["tag"] = "General Items",
            ["description"] = "",
        },
        [90] = 
        {
            ["rule"] = "filtertype(\"provisioning\")",
            ["name"] = "Provisioning",
            ["tag"] = "Materials",
            ["description"] = "",
        },
        [91] = 
        {
            ["rule"] = "isinquickslot()",
            ["name"] = "Quickslots",
            ["tag"] = "General Items",
            ["description"] = "Equipped in quickslots",
        },
        [92] = 
        {
            ["rule"] = "type(\"recipe\",\"racial_style_motif\") or sptype(\"trophy_recipe_fragment\")",
            ["name"] = "Recipes & Motifs",
            ["tag"] = "General Items",
            ["description"] = "All recipes, motifs and recipe fragments.",
        },
        [93] = 
        {
            ["rule"] = "type(\"tool\",\"crown_repair\") and not islockpick()",
            ["name"] = "Repair Kits",
            ["tag"] = "General Items",
            ["description"] = "",
        },
        [94] = 
        {
            ["rule"] = "fco_ismarked(\"research\")",
            ["name"] = "Research Mark",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [95] = 
        {
            ["rule"] = "keepresearch()",
            ["name"] = "Researchable",
            ["tag"] = "Gears",
            ["description"] = "Gears that keep for research purpose, only keep the low quality, low level one.",
        },
        [96] = 
        {
            ["rule"] = "equiptype(\"ring\")",
            ["name"] = "Ring",
            ["tag"] = "Gears",
            ["description"] = "",
        },
        [97] = 
        {
            ["rule"] = "fco_ismarked(\"sell_at_guildstore\")",
            ["name"] = "Sell At GuildStore Mark",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [98] = 
        {
            ["rule"] = "fco_ismarked(\"sell\")",
            ["name"] = "Sell Mark",
            ["tag"] = "FCOIS",
            ["description"] = "",
        },
        [99] = 
        {
            ["rule"] = "traittype(\"ornate\") \nor sptype(\"collectible_monster_trophy\") or type(\"trash\") or istreasure() \nor im_ismarked(\"Sell\") or (type(\"poison\",\"potion\") and getmaxtraits() ==0) or (iscompaniononly() and quality(\"normal\"))",
            ["name"] = "Selling",
            ["tag"] = "General Items",
            ["description"] = "",
        },
        [100] = 
        {
            ["rule"] = "autoset()",
            ["name"] = "Set",
            ["tag"] = "Gears",
            ["description"] = "Auto categorize set gears",
        },
        [101] = 
        {
            ["rule"] = "setindex(1)",
            ["name"] = "Set#1",
            ["tag"] = "Iakoni's Gear Changer",
            ["description"] = "#1 Set from Iakoni's Gear Changer",
        },
        [102] = 
        {
            ["rule"] = "setindex(2)",
            ["name"] = "Set#2",
            ["tag"] = "Iakoni's Gear Changer",
            ["description"] = "#2 Set from Iakoni's Gear Changer",
        },
        [103] = 
        {
            ["rule"] = "setindex(3)",
            ["name"] = "Set#3",
            ["tag"] = "Iakoni's Gear Changer",
            ["description"] = "#3 Set from Iakoni's Gear Changer",
        },
        [104] = 
        {
            ["rule"] = "setindex(4)",
            ["name"] = "Set#4",
            ["tag"] = "Iakoni's Gear Changer",
            ["description"] = "#4 Set from Iakoni's Gear Changer",
        },
        [105] = 
        {
            ["rule"] = "setindex(5)",
            ["name"] = "Set#5",
            ["tag"] = "Iakoni's Gear Changer",
            ["description"] = "#5 Set from Iakoni's Gear Changer",
        },
        [106] = 
        {
            ["rule"] = "setindex(6)",
            ["name"] = "Set#6",
            ["tag"] = "Iakoni's Gear Changer",
            ["description"] = "#6 Set from Iakoni's Gear Changer",
        },
        [107] = 
        {
            ["rule"] = "setindex(7)",
            ["name"] = "Set#7",
            ["tag"] = "Iakoni's Gear Changer",
            ["description"] = "#7 Set from Iakoni's Gear Changer",
        },
        [108] = 
        {
            ["rule"] = "setindex(8)",
            ["name"] = "Set#8",
            ["tag"] = "Iakoni's Gear Changer",
            ["description"] = "#8 Set from Iakoni's Gear Changer",
        },
        [109] = 
        {
            ["rule"] = "setindex(9)",
            ["name"] = "Set#9",
            ["tag"] = "Iakoni's Gear Changer",
            ["description"] = "#9 Set from Iakoni's Gear Changer",
        },
        [110] = 
        {
            ["rule"] = "setindex(10)",
            ["name"] = "Set#10",
            ["tag"] = "Iakoni's Gear Changer",
            ["description"] = "#10 Set from Iakoni's Gear Changer",
        },
        [111] = 
        {
            ["rule"] = "stacksize() == 200",
            ["name"] = "stacksz",
            ["tag"] = "Materials",
            ["description"] = "",
        },
        [112] = 
        {
            ["rule"] = "type(\"potion\") and itemname(\"stamina\")",
            ["name"] = "StamPotions",
            ["tag"] = "Materials",
            ["description"] = "",
        },
        [113] = 
        {
            ["rule"] = "isstolen()",
            ["name"] = "Stolen",
            ["tag"] = "General Items",
            ["description"] = "",
        },
        [114] = 
        {
            ["rule"] = "istag('tools', 'artwork')",
            ["name"] = "Tags",
            ["tag"] = "General Items",
            ["description"] = "",
        },
        [115] = 
        {
            ["rule"] = "(ck_isknowncat() and not ck_isknown(\"Shade Windwalker\", \"Ezabi keeps items for you\"))",
            ["name"] = "testmulti",
            ["tag"] = "UnknownTrackers",
            ["description"] = "",
        },
        [116] = 
        {
            ["rule"] = "islockpick() or isitemid(73753, 73754, 71779, 79504)",
            ["name"] = "Thief Supplies",
            ["tag"] = "General Items",
            ["description"] = "",
        },
        [117] = 
        {
            ["rule"] = "type(\"armor\") and traittype(\"armor_training\")",
            ["name"] = "Training",
            ["tag"] = "Traits",
            ["description"] = "",
        },
        [118] = 
        {
            ["rule"] = "type(\"armor\") and traittype(\"armor_training\")",
            ["name"] = "Training Armor",
            ["tag"] = "Gears",
            ["description"] = "",
        },
        [119] = 
        {
            ["rule"] = "filtertype(\"trait_items\", \"style_materials\")",
            ["name"] = "Trait/Style Gems",
            ["tag"] = "Materials",
            ["description"] = "",
        },
        [120] = 
        {
            ["rule"] = "istreasure() or type(\"treasure\")",
            ["name"] = "Treasure",
            ["tag"] = "Materials",
            ["description"] = "",
        },
        [121] = 
        {
            ["rule"] = "istreasure()",
            ["name"] = "Treasure1",
            ["tag"] = "General Items",
            ["description"] = "",
        },
        [122] = 
        {
            ["rule"] = "type(\"armor\", \"weapon\",\"jewelry\") and not isbound()",
            ["name"] = "Unbound",
            ["tag"] = "Gears",
            ["description"] = "",
        },
        [123] = 
        {
            ["rule"] = "isunknown()",
            ["name"] = "Unknown",
            ["tag"] = "UnknownTrackers",
            ["description"] = "",
        },
        [124] = 
        {
            ["rule"] = "isfurnishingunknown()",
            ["name"] = "Unknown Furnishing Recipes",
            ["tag"] = "UnknownTracker",
            ["description"] = "Unknown Furnishing Recipes of all types",
            
        },
        [125] = 
        {
            ["rule"] = "ismotifunknown()",
            ["name"] = "Unknown Motifs",
            ["tag"] = "UnknownTracker",
            ["description"] = "Unknown Motifs",
            
        },
        [126] = 
        {
            ["rule"] = "isstyleunknown()",
            ["name"] = "Unknown Outfit Styles",
            ["tag"] = "UnknownTracker",
            ["description"] = "Unknown Outfit Styles",
            
        },
        [127] = 
        {
            ["rule"] = "isrecipeunknown()",
            ["name"] = "Unknown Recipes",
            ["tag"] = "UnknownTracker",
            ["description"] = "Unknown Food and Drink Recipes",
            
        },
        [128] = 
        {
            ["rule"] = "isunknown(\"me\")",
            ["name"] = "Unknown to Me",
            ["tag"] = "UnknownTracker",
            ["description"] = "All recipes, motifs, outfit styles, etc that are not known by the current toon",
            
        },
        [129] = 
        {
            ["rule"] = "isunknown()",
            ["name"] = "Unknown to someone",
            ["tag"] = "UnknownTracker",
            ["description"] = "All recipes, motifs, outfit styles, etc that are not known by all toons",
            
        },
        [130] = 
        {
            ["rule"] = "isunknown(\"me\") or (ck_isknowncat() and not ck_isknown())",
            ["name"] = "UnknownByMe",
            ["tag"] = "UnknownTrackers",
            ["description"] = "",
        },
        [131] = 
        {
            ["rule"] = "itemname(\"Verse\")",
            ["name"] = "Verses",
            ["tag"] = "General Items",
            ["description"] = "",
        },
        [132] = 
        {
            ["rule"] = "type(\"weapon\") \nand not isset() \nand not traittype(\"weapon_ornate\")",
            ["name"] = "Weapon",
            ["tag"] = "Gears",
            ["description"] = "",
        },
        [133] = 
        {
            ["rule"] = "filtertype(\"woodworking\")",
            ["name"] = "Woodworking",
            ["tag"] = "Materials",
            ["description"] = "",
        },
        [134] = 
        {
            ["rule"] = "type(\"master_writ\")",
            ["name"] = "Writs",
            ["tag"] = "Pages",
            ["description"] = "",
        },
    }

AC["predefinedRules"] =  {
        {
            ["rule"] = "type(\"armor\") and not equiptype(\"neck\",\"ring\")",
            ["tag"] = "Gears",
            ["name"] = "Armor",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "boundtype(\"on_equip\") and not isbound() and not keepresearch()",
            ["tag"] = "Gears",
            ["name"] = "BoE",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "isboptradeable()",
            ["tag"] = "Gears",
            ["name"] = "BoP Tradeable",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "traitstring(\"intricate\")",
            ["tag"] = "Gears",
            ["name"] = "Deconstruct",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "isequipping()",
            ["tag"] = "Gears",
            ["name"] = "Equipping",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "level() > 1 and cp() < 160 and type(\"armor\", \"weapon\")",
            ["tag"] = "Gears",
            ["name"] = "Low Level",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "equiptype(\"neck\")",
            ["tag"] = "Gears",
            ["name"] = "Necklace",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "keepresearch()",
            ["tag"] = "Gears",
            ["name"] = "Researchable",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "equiptype(\"ring\")",
            ["tag"] = "Gears",
            ["name"] = "Ring",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "autoset()",
            ["tag"] = "Gears",
            ["name"] = "Set",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "type(\"weapon\")",
            ["tag"] = "Gears",
            ["name"] = "Weapon",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "type(\"food\", \"drink\", \"potion\")",
            ["tag"] = "General Items",
            ["name"] = "Consumables",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "type(\"container\")",
            ["tag"] = "General Items",
            ["name"] = "Container",
            ["description"] = "",
        ["pred"] = 1,
       },
        {
            ["rule"] = "filtertype(\"furnishing\")",
            ["tag"] = "General Items",
            ["name"] = "Furnishing",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "type(\"soul_gem\", \"glyph_armor\", \"glyph_jewelry\", \"glyph_weapon\")",
            ["tag"] = "General Items",
            ["name"] = "Glyphs & Gems",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "isnew()",
            ["tag"] = "General Items",
            ["name"] = "New",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "type(\"poison\")",
            ["tag"] = "General Items",
            ["name"] = "Poison",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "isinquickslot()",
            ["tag"] = "General Items",
            ["name"] = "Quickslots",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "type(\"recipe\",\"racial_style_motif\") or sptype(\"trophy_recipe_fragment\")",
            ["tag"] = "General Items",
            ["name"] = "Recipes & Motifs",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "traitstring(\"ornate\") or sptype(\"collectible_monster_trophy\") or type(\"trash\")",
            ["tag"] = "General Items",
            ["name"] = "Selling",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "isstolen()",
            ["tag"] = "General Items",
            ["name"] = "Stolen",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "sptype(\"trophy_survey_report\", \"trophy_treasure_map\")",
            ["tag"] = "General Items",
            ["name"] = "Maps & Surveys",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "filtertype(\"alchemy\")",
            ["tag"] = "Materials",
            ["name"] = "Alchemy",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "filtertype(\"blacksmithing\")",
            ["tag"] = "Materials",
            ["name"] = "Blacksmithing",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "filtertype(\"clothing\")",
            ["tag"] = "Materials",
            ["name"] = "Clothing",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "filtertype(\"enchanting\")",
            ["tag"] = "Materials",
            ["name"] = "Enchanting",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "filtertype(\"jewelrycrafting\")",
            ["tag"] = "Materials",
            ["name"] = "Jewelry Crafting",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "filtertype(\"provisioning\")",
            ["tag"] = "Materials",
            ["name"] = "Provisioning",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "filtertype(\"trait_items\", \"style_materials\")",
            ["tag"] = "Materials",
            ["name"] = "Trait/Style Gems",
            ["description"] = "",
        ["pred"] = 1,
        },
        {
            ["rule"] = "filtertype(\"woodworking\")",
            ["tag"] = "Materials",
            ["name"] = "Woodworking",
            ["description"] = "",
        ["pred"] = 1,
        },
    }


AC["FCOIS_predefinedRules"] = {
      {
          ["tag"] = "FCOIS",
          ["rule"] = "ismarked(\"deconstruction\")",
          ["description"] = "",
          ["name"] = "Deconstruction Mark",
      },
      {
          ["tag"] = "FCOIS",
          ["rule"] = "fco_ismarked(\"dynamic_1\")",
          ["name"] = "Dynamic 1",
          ["description"] = "",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 2",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_2\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 3",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_3\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 4",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_4\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 5",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_5\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 6",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_6\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 7",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_7\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 8",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_8\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 9",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_9\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 10",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_10\")",
      },
      {
          ["tag"] = "FCOIS",
          ["rule"] = "fco_ismarked(\"gear_1\")",
          ["name"] =  "Gear 1",
          ["description"] = "",
      },
      {
          ["tag"] = "FCOIS",
          ["rule"] = "fco_ismarked(\"gear_2\")", 
          ["name"] =  "Gear 2",
          ["description"] = "",
      },
      {
          ["tag"] = "FCOIS",
          ["rule"] = "fco_ismarked(\"gear_3\")", 
          ["name"] =  "Gear 3",
          ["description"] = "",
      },
      {
          ["tag"] = "FCOIS",
          ["rule"] = "fco_ismarked(\"gear_4\")", 
          ["name"] =  "Gear 4",
          ["description"] = "",
      },
      {
          ["tag"] = "FCOIS",
          ["rule"] = "fco_ismarked(\"gear_5\")", 
          ["name"] =  "Gear 5",
          ["description"] = "",
      },
      {
          ["tag"] = "FCOIS",
          ["rule"] = "fco_ismarked(\"improvement\")",
          ["description"] = "",
          ["name"] = "Improvement Mark",
      },
      {
          ["tag"] = "FCOIS",
          ["rule"] = "fco_ismarked(\"intricate\")",
          ["description"] = "",
          ["name"] = "Intricate Mark",
      },
      {
          ["tag"] = "FCOIS",
          ["rule"] = "fco_ismarked(\"research\")",
          ["description"] = "",
          ["name"] = "Research Mark",
      },
      {
          ["tag"] = "FCOIS",
          ["rule"] = "fco_ismarked(\"sell_at_guildstore\")",
          ["description"] = "",
          ["name"] = "Sell At GuildStore Mark",
      },
      {
          ["tag"] = "FCOIS",
          ["rule"] = "fco_ismarked(\"sell\")",
          ["description"] = "",
          ["name"] = "Sell Mark",
      },
      {
          ["tag"] = "FCOIS",
          ["rule"] = "fco_ismarked(\"lock\")",
          ["description"] = "",
          ["name"] = "Lock Mark",
      },
      {
          ["tag"] = "FCOIS",
          ["rule"] = "fco_ismarked()",
          ["description"] = "",
          ["name"] = "All Marks",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 11",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_11\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 12",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_12\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 13",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_13\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 14",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_14\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 15",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_15\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 16",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_16\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 17",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_17\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 18",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_18\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 19",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_19\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 20",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_20\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 21",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_21\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 22",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_22\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 23",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_23\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 24",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_24\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 25",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_25\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 26",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_26\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 27",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_27\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 28",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_28\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 29",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_29\")",
      },
      {
          ["tag"] = "FCOIS",
          ["name"] = "Dynamic 30",
          ["description"] = "",
          ["rule"] = "fco_ismarked(\"dynamic_30\")",
      },
    }
  




AutoCategory.cache = {
    rulesByName = {}, -- [name] rule#
    rulesByTag_svt = {}, -- [tag] {choices{rule.name}, choicesTooltips{rule.desc/name}}
    compiledRules = AC.compiledRules, -- [name] function
    tags = {}, -- [#] tagname
    bags_svt = {}, -- {choices{bagname}, choicesValues{bagid}, choicesTooltips{bagname}} -- for the bags themselves
    entriesByBag = {}, -- [bagId] {choices{ico rule.name (pri)}, choicesValues{rule.name}, choicesTooltips{rule.desc/name or missing}} --
    entriesByName = {}, -- [bagId][rulename] {runpriority, showpriority, isHidden}
	collapses = {},
}
local cache = AutoCategory.cache


-- find and return the rule referenced by name
-- returns nil if can't find rule
function AutoCategory.GetRuleByName(name)
    if not name then
        return nil
    end

    local ndx = cache.rulesByName[name]
    if not ndx then
        return nil
    end

	return AC.rules[ndx]
end


-- based on the requested rule name, create a name that
-- is not already in use (rule names must be unique)
function AutoCategory.GetUsableRuleName(name)
	local testName = name
	local index = 1
	while AC.cache.rulesByName[testName] ~= nil do
		testName = name .. index
		index = index + 1
	end
	return testName
end

-- ----------------------------------------
-- when we add a new rule to AC.rules, also add it to the various lookups and dropdowns
-- returns nil on success or error message
function AutoCategory.cache.AddRule(rule)
    if not rule or not rule.name then
        return "AddRule: Rule or name of rule was nil"
    end -- can't use a nil rule
	
	--local mt = { __index = AC.rulefuncs, }
	--setmetatable(rule, mt)

	if not rule.tag or rule.tag == "" then
        rule.tag = AC_EMPTY_TAG_NAME
    end
	
    if cache.rulesByTag_svt[rule.tag] == nil then
        cache.rulesByTag_svt[rule.tag] = {choices = {}, choicesValues = {}, choicesTooltips = {}}
    end

	local rule_ndx = cache.rulesByName[rule.name]
  if rule_ndx then
		-- rule already exists
		-- save overwritten rule??
		
		-- overwrite rule with new one
		--saved.rules[rule_ndx] = rule
		--AC.rules[rule_ndx] = rule
     
	else
		-- add the new rule
		if rule.pred and rule.pred == 1 then 
			--AC.logger:Debug("[AddRule] Adding rule to predefinedRules ".. rule.name)
			--table.insert(AC.predefinedRules, rule) 
			
		else
			AC.logger:Debug("[AddRule] Adding rule to acctRules ".. rule.name)
			table.insert(AC.acctRules.rules, rule)
		end
    AC.logger:Debug("[AddRule] Adding rule to AC.rules ".. rule.name)
		table.insert(AC.rules, rule)
		rule_ndx = #AC.rules
		cache.rulesByName[rule.name] = rule_ndx

		table.insert(cache.rulesByTag_svt[rule.tag].choices, rule.name)
		table.insert(cache.rulesByTag_svt[rule.tag].choicesValues, rule.name)
		table.insert(cache.rulesByTag_svt[rule.tag].choicesTooltips, rule:getDesc())
    end

	--rule:compile()
end





-- add rules from a list to AC.rules (if not dupe), remove them from the original list if notdel == false/nii
local function addTableRules(tbl, tblname, notdel, ispredef)
	AC.logger:Info("Adding rules from table "..(tblname or "unknown").." with "..SF.GetSize(tbl.rules))
	local r, rndx, newName
	if not tbl.rules then 
		AC.logger:Info("No rules available from table "..(tblname or "unknown"))
		return 
	end
	
	for k, v in pairs(tbl.rules) do
		--AC.logger:Info("Processing rule "..k..". "..v.name.." from "..(tblname or "unknown"))
		if notdel == false then
      --AC.logger:Info("Removing rule "..k..". "..v.name.." from original list "..(tblname or "unknown"))
			table.remove(tbl.rules,k)
		end
		
		rndx = cache.rulesByName[v.name]
		if rndx then
			--AC.logger:Warn("Found duplicate rule name - "..v.name)
			r = AC.GetRuleByName(v.name)
			-- already have one
			if v.rule == r.rule then
				-- same rule def, so remove from input table
				AC.logger:Warn("1 Dropped duplicate rule - "..v.name.."  from AC.rules sourced "..(tblname or "unknown"))
				
			else
				-- rename different rule
				newName = AC.GetUsableRuleName(v.name)
				AC.logger:Warn("Renaming rule "..v.name.." to "..newName)
				v.name = newName
				--AC.logger:Info("Adding renamed rule "..v.name.." to AC.rules")
				table.insert(AC.rules, v)
				if v.pred and v.pred == 1 then 
					--table.insert(AC.predefinedRules, v) 
				else
					table.insert(AC.acctRules.rules, v)
				end
				--AC.logger:Debug("!AC.rules now = "..#AC.rules)
				cache.rulesByName[v.name] = #AC.rules
        if notdel == false then
          table.remove(tbl.rules, k)
          table.insert(tbl.rules, v)
        end
				--AC.logger:Info("Inserting renamed rule "..v.name.." to "..(tblname or "unknown"))
			end
			
		else
			if (v.pred and v.pred == 1) or ispredef then 
        if tbl.rules ~= AC.predefinedRules then
          table.insert(AC.predefinedRules, v) 
        end
      
      else
          if tbl.rules ~= AC.acctRules.rules then
            table.insert(AC.acctRules.rules, v)
          end
        end
        table.insert(AC.rules, v)
        --AC.logger:Debug("!AC.rules now = "..#AC.rules)
        AC.logger:Info("Adding rule "..v.name.." to AC.rules")
        cache.rulesByName[v.name] = #AC.rules
      end
    end
end

-- -------------------------------------------------------------
-- -------------------------------------------------------------
		-- combine the user-defined and pre-defined into a single set for use
	AC.rules = SF.safeClearTable(AutoCategory.rules) -- start empty
	
	-- add pre-defined rules first
	local pred = { rules = AC.predefinedRules, }
	print("1 predefined "..#AC.predefinedRules)
  addTableRules(pred, "AC.predefinedRules", true)
	local fpred = { rules = AC.FCOIS_predefinedRules, }
  print("FCOIS_predefined "..#AC.FCOIS_predefinedRules)
  addTableRules(fpred, "AC.FCOIS_predefinedRules", true, true)

	-- load lookup for predefines
	local lpred = {}
	for k, v in pairs(AC.predefinedRules) do
		if lpred[v.name] then
			AC.logger:Info("Found duplicate predefine: "..v.name.." ("..k..") - original k = "..lpred[v.name])
		else
			lpred[v.name] = k
		end
	end
	
--print("lpred "..#lpred)
print("2 predefined "..#AC.predefinedRules)
print ("srules "..#AC.srules)
print ("rules "..#AC.rules)
print ("acctRules "..#AC.acctRules.rules)

  -- prune base pre-defines
	local asv = SF.GetSize(AC.srules)
	for k,v in pairs(AC.srules) do
		if lpred[v.name] then
			-- delete dupe
			AC.logger:Warn("Deleting base pre-def from srules: "..v.name)
			table.remove(AC.srules, k)
		end
	end
	AC.logger:Info("srule # went from "..asv.." to "..SF.GetSize(AC.srules))
	--[[
	if AC.charSaved.rules then
		local csv = SF.GetSize(AC.charSaved.rules)
		for k,v in pairs(AC.charSaved.rules) do
			if lpred[v.name] then
				-- delete dupe
				AC.logger:Warn("Deleting base pre-def from charSaved.rules: "..v.name)
				table.remove(AC.charSaved.rules, k)
			end
		end
		AC.logger:Info("charSaved.rule # went from "..csv.." to "..SF.GetSize(AC.charSaved.rules))
	end
  --]]
	
	-- add user-defined rules next
	--addR(AC.acctRules, "AC.acctRules.rules", true)
  local sr = { rules = AC.srules }
	addTableRules(sr, "AC.srules")
	--addR(AC.acctSaved, "AC.acctSaved.rules")
	--addR(AC.charSaved, "AC.charSaved.rules")

--for k,v in pairs(lpred) do
 --   print("lpredrules["..k.."] = "..v)
--end

--for k,v in pairs(AC.srules) do
--    print("srules["..k.."] = "..v.name)
--end

--for k,v in pairs(AC.rules) do
--    print("combrules["..k.."] = "..v.name)
--end

--for k,v in pairs(AC.acctRules.rules) do
--    print("acctRules["..k.."] = "..v.name)
--end

--print("lpred "..#lpred)
print("3 predefined "..#AC.predefinedRules)
print ("srules "..#AC.srules)
print ("rules "..#AC.rules)
print ("acctRules "..#AC.acctRules.rules)