# Rule Function Page

## Item Type
```
type("arg1", ...)
```

Match item by item type arg1, OR arg2, OR ...

*Available Add-on Version:	1.03, 3.6.6, 4.0*

**Available Values:**

additive
armor
armor_booster
armor_trait
ava_repair
blacksmithing_booster
blacksmithing_material
blacksmithing_raw_material
clothier_booster
clothier_material
clothier_raw_material
collectible
container
container_currency
costume
crown_item
crown_repair
deprecated
disguise
drink
dye_stamp

enchanting_rune - (matches aspect, essence, or potency)
enchanting_rune_aspect
enchanting_rune_essence
enchanting_rune_potency
enchantment_booster
fish
flavoring
food
furnishing
furnishing_material
glyph - (matches armor, jewelry, or weapon)
glyph_armor
glyph_jewelry
glyph_weapon
grimoire
group_repair
ingredient

jewelry_booster
jewelry_material
jewelry_raw_booster
jewelry_raw_material
jewelry_raw_trait
jewelry_trait
lockpick
lure
master_writ
mount
none
plug
poison
poison_base
potion
potion_base
racial_style_motif
raw_material
reagent
recall_stone
recipe

scrbing
scribing_ink
siege
soul_gem
spellcrafting_tablet
spice
style_material
tabard
tool
trash
treasure
trophy
weapon
weapon_booster
weapon_trait
woodworking_booster
woodworking_material
woodworking_raw_material

## Specialized Item Type
```
sptype("arg1", ...)
```

Match item by item specialized type arg1, OR arg2, OR ...

*Available Add-on Version:	1.03, 4.0*

**Available Values:**
additive
armor
armor_booster
armor_trait
ava_repair
blacksmithing_booster
blacksmithing_material
blacksmithing_raw_material
clothier_booster
clothier_material
clothier_raw_material

collectible_monster_trophy
collectible_rare_fish
collectible_style_page
container
container_currency
container_event
container_style_page
costume
crown_item
crown_repair
disguise
drink_alcoholic
drink_cordial_tea
drink_distillate
drink_liqueur
drink_tea
drink_tincture
drink_tonic
drink_unique
dye_stamp

enchanting_rune_aspect
enchanting_rune_essence
enchanting_rune_potency
enchantment_booster
fish
flavoring
food_entremet
food_fruit
food_gourmet
food_meat
food_ragout
food_savoury
food_unique
food_vegetable

furnishing_attunable_crafting_station
furnishing_crafting_station
furnishing_light
furnishing_material_alchemy
furnishing_material_blacksmithing
furnishing_material_clothier
furnishing_material_enchanting
furnishing_material_jewelry
furnishing_material_provisioning
furnishing_material_woodworking
furnishing_ornamental
furnishing_seating
furnishing_target_dummy

glyph (matches glyph_armor, glyph_jewelry, or glyph_weapon)
glyph_armor
glyph_jewelry
glyph_weapon
holiday_writ
ingredient_alcohol
ingredient_drink_additive
ingredient_food_additive
ingredient_fruit
ingredient_meat
ingredient_rare
ingredient_tea
ingredient_tonic
ingredient_vegetable

jewelry_booster
jewelry_material
jewelry_raw_booster
jewelry_raw_material
jewelry_raw_trait
jewelry_trait
lockpick
lure
master_writ
mount
none
plug
poison
poison_base
potion
potion_base
racial_style_motif_book
racial_style_motif_chapter
raw_material
reagent_animal_part
reagent_fungus
reagent_herb
recall_stone_keep

recipe_alchemy_formula_furnishing
recipe_blacksmithing_diagram_furnishing
recipe_clothier_pattern_furnishing
recipe_enchanting_schematic_furnishing
recipe_jewelry_sketch_furnishing
recipe_provisioning_design_furnishing
recipe_provisioning_standard_drink
recipe_provisioning_standard_food
recipe_woodworking_blueprint_furnishing

scribing_ink
script
script_affix
script_focus
script_signature
siege_ballista
siege_battle_standard
siege_catapult
siege_graveyard
siege_lancer
siege_monster
siege_oil
siege_ram
siege_trebuchet
siege_universal

soul_gem
spice
style_material
tabard
tool
trash
treasure

trophy_collectible_fragment
trophy_dungeon_buff_ingredient
trophy_key
trophy_key_fragment
trophy_material_upgrader
trophy_museum_piece
trophy_recipe_fragment
trophy_runebox_fragment
trophy_scroll
trophy_survey_report
trophy_toy
trophy_treasure_map
trophy_upgrade_fragment

weapon
weapon_booster
weapon_trait
woodworking_booster
woodworking_material
woodworking_raw_material

## Equip Type
```
equiptype("arg1", ...)
```

Match item by equip type arg1, OR arg2, OR ...

Available Add-on Version:	1.03

Available Values:

chest
costume
feet
hand
head
invalid
legs
main_hand
neck
off_hand
one_hand
poison
ring
shoulders
two_hand
waist

## Filter Type
```
filtertype("arg1", ...)
```

Match item by filter type arg1, OR arg2, OR ...

Available Add-on Version:	1.03, 3.6.6

Available Values:

alchemy
all
armor
blacksmithing
buyback
clothing
collectible
companion
consumable
crafting
damaged
enchanting
furnishing
house_with_template
jewelry
jewelrycrafting
junk
miscellaneous
provisioning
quest
quest_quickslot
quickslot
style_materials
trait_items
weapons
woodworking

## Trait Type
```
traittype("arg1", ...)
```
Match item by trait type arg1, OR arg2, OR ...

Available Add-on Version:	1.03

Available Values:

_**Convenience Values:**_

traittype | Same As
---------|---------
divines | armor_divines
infused | armor_infused or jewelry_infused or weapon_infused_
intricate | any of armor_intricate or jewelry_intricate or weapon_intricate
nirnhoned | any of armor_nirnhoned or weapon_nirnhoned
ornate | any of armor_ornate or jewelry_ornate or weapon_ornate


_**ESO Values:**_

armor_divines
armor_impenetrable
armor_infused
armor_intricate
armor_nirnhoned
armor_ornate
armor_prosperous
armor_reinforced
armor_sturdy
armor_training
armor_well_fitted

armor_aggressive
armor_augmented
armor_bolstered
armor_focused
armor_prolific
armor_quickened
armor_shattering
armor_soothing
armor_vigorous

deprecated

jewelry_arcane
jewelry_bloodthirsty
jewelry_harmony
jewelry_healthy
jewelry_infused
jewelry_intricate
jewelry_ornate
jewelry_protective
jewelry_robust
jewelry_swift
jewelry_triune

jewelry_aggressive
jewelry_augmented
jewelry_bolstered
jewelry_focused
jewelry_prolific
jewelry_quickened
jewelry_shattering
jewelry_soothing
jewelry_vigorous
none

weapon_charged
weapon_decisive
weapon_defending
weapon_infused
weapon_intricate
weapon_nirnhoned
weapon_ornate
weapon_powered
weapon_precise
weapon_sharpened
weapon_training

weapon_aggressive
weapon_augmented
weapon_bolstered
weapon_focused
weapon_prolific
weapon_quickened
weapon_shattering
weapon_soothing
weapon_vigorous

## Armor Type
```
armortype("arg1", ...)
```

Match item by armor type arg1, OR arg2, OR ...

Available Add-on Version:	1.10

Available Values:

heavy
light
medium
none

## Weapon Type
```
weapontype("arg1", ...)
```
Match item by weapon type arg1, OR arg2, OR ...

Available Add-on Version:	1.10

Available Values:

axe
bow
dagger
fire_staff
frost_staff
hammer
healing_staff
lightning_staff
none
rune
shield
sword
two_handed_axe
two_handed_hammer
two_handed_sword

## Is Companion Item
```
iscompaniononly()
```
Match item if the item can only be used by companions.

_Available Add-on Version:	2.19_

## Is Item Id
```
isitemid(itemid, ...)
```
Match the item if the itemId of the item matches one of the itemIds listed in the parameters.

_Available Addon Version: 3.6.7

## Is Tag
```
istag()
```

This function will allow you to match against one or more of the "Treasure Types" listed in the tooltip window for the item. This can help you to write rules to look for specific item types you need to acquire for some of the crow quests in Clockwork City.
For instance, some of the Treasure Types you might see are:
Artwork, Cosmetics, Dolls, Drinkware, Fishing Supplies, Games, Grooming Items, Musical Instruments, Oddities, Ritual Objects, Statues, Tools, Trifles and Ornaments, Wall Décor
(If your client runs a language other than English you will see language-appropriate versions of the above.)
You can create a rule to look for items that are games or dolls with the rule "istag('dolls','games')".
The tags that you specify must exactly match the name of the tag type (except that upper-case is ignored). "grooming" will not match "grooming Items" because the second word is missing. Also, "Wall Decor" will not match "Wall Décor" (which has a UTF-8 character instead of a plain 'e').
If you do not specify any tags to look for (just "istag()"), then the function will revert back to the istreasure() function's behaviour.
_Available Add-on Version:	3.2_

## Is Treasure
```
istreasure()
```

Check if the item is considered Treasure (i.e. random junk that you can sell for good money).

_Available Add-on Version:	2.6_

## Is New Item
```
isnew()
```

Match item if the item is new.

_Available Add-on Version:	1.03_


## Is Reconstructed Item
```
isreconstructed()
```

Match item if the item was made by reconstruction.

_Available Add-on Version:	2.16_

## Is Transmuted Item
```
istransmuted()
```

Match item if the item has had its trait changed at a transmute station.

_Available Add-on Version:	2.16_

## Is Unbound Item
```
isunbound()
```

Match item if the item is not bound to the character or the account. (convenience function
equivalent to ```not isbound()```)

_Available Add-on Version:	2.16_


## Is Locked
```
islocked()
```

Match item if the item has been locked.

_Available Add-on Version:	1.26_

## Is Lockpick
```
islockpick()
```
Convenience function to detect lockpicks in inventory since, due to a Zenimax bug, lockpicks do not belong to `type("lockpick")`

_Available Addon version: 2.0_

## Is Bound Item
```
isbound()
```

Match item if the item is bound. (Includes character bound items too.)

_Available Add-on Version:	1.03_


## Is CharBound Item
```
ischarbound()
```

Match item if the item is bound to your character.

_Available Add-on Version:	2.1_

 
## Is Unknown Collectible
```
 isunknowncollectible()
```
This function matches style pages, runeboxes and collectible fragments the user hasn't collected yet. Previously this was only possible with Unknown Tracker integration. Code provided by jkhsjdhjs.

_Available Add-on Version:	2.35_

## Is Collected Set Item
```
iscollected()
```

Match item if it is set gear that you have already collected. 
Returns true if the gear is set gear that is collected. 
Returns false if the gear is not set get or it has not yet been collected.

_Available Add-on Version:	2.11_

## Is Not Collected Set Item
```
isnotcollected()
```

Match item if it is set gear that you have not yet collected. 
Returns true if the gear is set gear that is not collected. 
Returns false if the gear is not set get or it has already been collected.

_Available Add-on Version:	2.11_

## Is Stolen Item
```
isstolen()
```

Match item if the item is stolen.

_Available Add-on Version:	1.03_


## Is Treasure Item
```
istreasure()
```

Match item if the item has an item type of treasure, specialized item of treasure, or an item tag description of treasure.

_Available Add-on Version:	2.6_


## Is BoP and Tradeable Item
```
isboptradeable()
```

Match item if the item is Bind on pickup and tradeable.

_Available Add-on Version:	1.03_

## Is Crafted Item
```
iscrafted()
```

Match item if the item is crafted. Now works with potions and poisons as well.

_Available Add-on Version:	1.05, 1.37_

## Is Learnable
```
islearnable()
```


## Is Assigned in Quickslots
```
isinquickslot()
```
Match item if the item is assigned in quick slots.

_Available Add-on Version:	1.03 & fixed in 3.5_

## Cannot Deconstruct
```
cannotdecon()
```
This function will return true or false depending on if the item can be deconstructed or not. 

Examples of things that cannot be deconstructed are: 
* jewelry acquired before the Summerset Chapter was released, 
* companion gear, 
* food, 
* potions, etc. 
Obviously, this is most useful for a rule that picks out items to be deconstructed.

No Arguments

## Item Level
```
level()
```

Get Item's level for testing. Value range [1-50].

_Available Add-on Version:	1.03_

No Arguments, can be used in expression

## Item Champion Points Level (CP Level)
```
cp()
```

Get Item's CP level for testing. Value range [1-160].

_Available Add-on Version:	1.03_

No Arguments, can be used in expression

## Set Name String
```
set("arg1", "arg2", ...)
```
Match item by testing if it's set gear and its set name contains string arg1, OR arg2, OR ...

_Available Add-on Version:	1.03_

Arguments are strings to be searched, case insensitive

## Auto Set
```
autoset()
```
Auto generate set categories for each set gear.

_Available Add-on Version:	1.03_

No Arguments, will make more than one category

## Combined Auto Set
```
combined_autoset()
```
Auto generate set categories for each set gear. It is similar to autoset except that perfected set gear will be combined into the same category with their related regular set gear.

_Available Add-on Version:	4.0_

No Arguments, will make more than one category



## Is Set
```
isset()
```
Match item if it has a set.

_Available Add-on Version:	1.16_

No Arguments

## Is Monster Set
```
ismonsterset()
```
Match item if it is from any monster set.

_Available Add-on Version:	1.16_

No Arguments

## Trait String
```
traitstring("arg1", "arg2", ...)
```
Match item by testing if the trait type contains string arg1, OR arg2, OR ...

_Available Add-on Version:	1.03_

Arguments are strings to be searched, case insensitive

## Bound Type
```
boundtype("arg1", ...)
```

Match item by bound type arg1, OR arg2, OR ...

_Available Add-on Version:	1.03_

Available Values:

none
on_equip
on_pickup
on_pickup_backpack
unset

## Keep for Researching
```
keepresearch()
```
Match item if the item is researchable.

_Available Add-on Version:	1.03_

No Arguments

## Sell Price

sellprice()
Get item's sell price.

_Available Add-on Version:	1.11_

No Arguments, can be used in expression

## Is In Zone
```
 isinzone() 
```
This function returns true or false if the name of the item in question contains the name of the current zone. (Primarily useful for treasure maps and surveys!)

_Available Add-on Version:	2.26_

## Zone
```
zone()
```
This function returns the name of the current zone.

_Available Add-on Version:	2.26_

## Armory Build
```
armorybuild()
```
This function that categorizes items based on the armory builds set up for the current character. It mimics the AlphaGear integration in behaviour, but instead of grouping items that belong to a AlphaGear set, it groups items that belong to an armory build.

As an example, if you had an armory build called "Testing", the rule

`armorybuild("Testing")`

will group items that are used in this armory build in a category called "-Category name- (Testing)".

_Available Add-on Version:	3.1_

## Stack Size
```
stacksize()
```
Get item's stack size.

_Available Add-on Version:	1.15_

No Arguments, can be used in expression

## Is Learnable
```
islearnable()
```
Match item if the item is unknown by current character. This item can be a recipe or a motif book.

_Available Add-on Version:	1.11_

No Arguments

## Is Equipping Item
```
isequipping()
```
Match item if the item is equipping currently.

_Available Add-on Version:	1.03_

No Arguments

## Is In Backpack
```
isinbackpack()
```
Match item if the item is in your backpack.

_Available Add-on Version:	2.8_

## Is In Bank
```
isinbank()
```
Match item if the item is in the bank.

_Available Add-on Version:	1.15_

No Arguments

## Quality
```
quality("arg1", ...)
```

Match item by quality arg1, OR arg2, OR ...

_Available Add-on Version:	1.12_

Available Values:

trash
normal
magic
arcane
artifact
legendary
mythic
grey - (same as trash)
white - (same as normal)
green - (same as magic)
blue - (same as arcane)
purple - (same as artifact)
gold - (same as legendary)
orange - (same as mythic)

## Get Quality
```
getquality()
```

Get item's quality value.

_Available Add-on Version:	1.13_

No Arguments, need comparison expression with operators <, <=, ==(Equal), ~=(Not Equal), > or >= and with a valid number in range [0, 5]:

| **Quality** | **Value** |
| ----- | - |
| trash | 0 |
| normal | 1 |
|magic | 2
arcane | 3
artifact | 4
legendary | 5

## Get Max Traits
```
getmaxtraits()
```

When used with posions and potions, such as this rule:
```
type("poison","potion") and getmaxtraits() <=2

```
it can tell you which are crafted (i.e. having more than one trait).

_Available Add-on Version:	1.37_

No Arguments, need comparison expression with operator <, <=, ==(Equal), ~=(Not Equal), > or >= and with a valid number

## Char Level
```
charlevel()
```

Pull current character level. Can be used to compare item level to your character level with a custom rule.

_Available Add-on Version:	1.23_

## Char Champion Points
```
charcp()
```

Pull current character CP. Can be used to compare item level to your character CP with a custom rule.

_Available Add-on Version:	1.23_

## Char Name
```
charname(arg1,...)
```

Check if the current character's name matches one of the arguments.
Returns true if the character name contains any of the provided strings (case insensitive), e.g. `charname("Wednesday Addams", "Morticia Addams")` would return false for the character "Pugsley Addams".



## Item Name
```
itemname(arg1,...)
```

Match item if the item's name matches one of the arguments.
Returns true if the item name contains any of the provided strings (case insensitive), e.g. `itemname("Maelstrom", "Alkosh")`

_Available Add-on Version:	1.34_

## Item Style
```
itemstyle(arg1,...)
```
Match item if the style of the item matches one of the arguments. Arguments are motif names (complete with embedded spaces and punctuation where applicable).
Returns true if the item style contains any of the provided strings (case insensitive), e.g. `itemstyle("Dark Brotherhood, "dro-m'athra")`


_Available Add-on Version:	2.3.1_


# Built-in Add-on Support:

## (Iakoni's Gear Changer) Set Slot Index
```
setindex("arg1", ...)
```
Match item if the item is in set slot which index is arg1, OR arg2, OR ...

_Available Add-on Version:	1.03_

Available Value:

1
2
3
4
5
6
7
8
9
10

## (Iakoni's Gear Changer) Is In Set Slot
```
inset()
```
Match item if the item is included in any set slot.

_Available Add-on Version:	1.03_


## (FCO Item Saver) IsMarked
```
fco_ismarked("arg1", ...)
```
Match item if the item is marked as arg1, OR arg2, OR ...

_Available Add-on Version:	1.09_

Available Value:

gear_1
gear_2
gear_3
gear_4
gear_5
sell
lock
research
deconstruction
improvement
sell_at_guildstore
intricate

1-10 | 11-20 | 21-30
---------|----------|---------
dynamic_1 | dynamic_11 | dynamic_21
dynamic_2 | dynamic_12 | dynamic_22
dynamic_3 | dynamic_13 |dynamic_23
dynamic_4 | dynamic_14 | dynamic_24
dynamic_5 | dynamic_15 | dynamic_25
dynamic_6 | dynamic_16 | dynamic_26
dynamic_7 | dynamic_17 | dynamic_27
dynamic_8 | dynamic_18 | dynamic_28
dynamic_9 | dynamic_19 | dynamic_29
dynamic_10 | dynamic_20 | dynamic_30

## (FCO Item Saver) IsProtected
```
fco_isprotected("arg1", ...)
```
Match item if the item is ...

_Available Add-on Version:	1.09_


## (FCO Item Saver) IsGear
```
fco_isgear("arg1", ...)
```
Match item if the item is ...

_Available Add-on Version:	1.09_


## (Item Saver) IsMarkedIS
```
ismarkedis("arg1", ...)
```
Match item if the item is marked as being a part of arg1, OR arg2, OR ...

_Available Add-on Version:	1.27_


## (Alpha Gear) Alpha Gear Set Index
```
alphagear("arg1", ...)
```
Match item if the item is in set which index is arg1, OR arg2, OR ...

_Available Add-on Version:	1.15_

Available Value:[1-16], will make more than one category if there are multiple arguments

## (Tamriel Trade Centre) Market Price
```
ttc_getprice()
ttc_getprice("arg")

```
Get the price from TTC for testing. If no argument is presented, default is "suggested".

_Available Add-on Version:	1.15_

Available Values:
| arg | returns
| --- | -------
"average" | if there's an average price, return it, or return 0.
"suggested" | if there's a suggested price, return it, or return 0.
"both" | if there's a suggested price, return it, or if there's an average price, return it, or return 0.

## (Master Merchant) Market Price
```
mm_getprice()
```
Get the price from MM for testing. If there's no price data, return 0.

_Available Add-on Version:	1.15_

## (Set Tracker) Is Tracked
```
istracked(arg1, ...)
```

Match if the item belongs to a defined tracked set in the SetTracker addon.

_Available Add-on Version:	1.32_

Argument(s) is one (or more) names of SetTracker defined sets.

### (LibCharacterKnowledge) CK Is Unknown
```
ck_isunknown()
```

Match if the item is known by your character according to the LibCharacterKnowledge addon.

_Available Add-on Version:	3.3_

### (LibCharacterKnowledge) CK Is Unknown Cat
```
ck_isunknowncat()
```

Match if the category is known by your character according to the LibCharacterKnowledge addon.

_Available Add-on Version:	3.3_

## (Unknown Tracker) Is Unknown
```
isunknown(...)
isunknown("me")
```

Match if the item is known by your character according to the UnknownTracker addon.

Arguments can be zero or more strings to match knowledge of the recipe to the named characters (names are case sensitive). If you use isunknown() without any parameters, it will return true if the learnable item (recipe, etc) is unknown to ANY of your toons. If you use isunknown("me") with the special parameter "me" then it will return true if the learnable item is unknown to the toon that you are currently logged in on. Finally you can specify specific toon names as parameters so you can tell if the learnable item is unknown to your specific "crafter" toons. (Note that the options for Unknown Tracker to turn off displaying for specific types of items will also turn off AutoCategory's ability to detect them with this rule.)

_Available Add-on Version:	2.4_

## (Unknown Tracker) Is Recipe Unknown
```
isrecipeunknown(...)
isrecipeunknown("me")
```

Match if the recipe is known by your character according to the UnknownTracker addon.

Arguments can be zero or more strings to match knowledge of the recipe to the named characters (names are case sensitive). If you use isunknown() without any parameters, it will return true if the recipe is unknown to ANY of your toons. If you use isunknown("me") with the special parameter "me" then it will return true if the recipe is unknown to the toon that you are currently logged in on. Finally you can specify specific toon names as parameters so you can tell if the recipe is unknown to your specific "crafter" toons. (Note that the options for Unknown Tracker to turn off displaying for specific types of items will also turn off AutoCategory's ability to detect them with this rule.)

_Available Add-on Version:	2.4_

## (Unknown Tracker) Is Furnishing Unknown
```
isfurnishingunknown(...)
isfurnishingunknown("me")
```

Match if the recipe is known by your character according to the UnknownTracker addon.

Arguments can be zero or more strings to match knowledge of the furniture pattern to the named characters (names are case sensitive). If you use isunknown() without any parameters, it will return true if the furniture patternis unknown to ANY of your toons. If you use isunknown("me") with the special parameter "me" then it will return true if the furniture pattern is unknown to the toon that you are currently logged in on. Finally you can specify specific toon names as parameters so you can tell if the furniture pattern is unknown to your specific "crafter" toons. (Note that the options for Unknown Tracker to turn off displaying for specific types of items will also turn off AutoCategory's ability to detect them with this rule.)

_Available Add-on Version:	2.4_

## (Unknown Tracker) Is Motif Unknown
```
ismotifunknown(...)
ismotifingunknown("me")
```

Match if the recipe is known by your character according to the UnknownTracker addon.

Arguments can be zero or more strings to match knowledge of the motif to the named characters (names are case sensitive). If you use isunknown() without any parameters, it will return true if the motif is unknown to ANY of your toons. If you use isunknown("me") with the special parameter "me" then it will return true if the motif is unknown to the toon that you are currently logged in on. Finally you can specify specific toon names as parameters so you can tell if the motif is unknown to your specific "crafter" toons. (Note that the options for Unknown Tracker to turn off displaying for specific types of items will also turn off AutoCategory's ability to detect them with this rule.)

_Available Add-on Version:	2.4_


## (Unknown Tracker) Is Style Unknown
```
isstyleunknown(...)
```

Match if the style page is known by your character according to the UnknownTracker addon.

Arguments can be zero or more strings to match knowledge of the stylepage to the named characters (names are case sensitive). 
_Available Add-on Version:	2.33_

--------------------------------------------------------------
_**Acknowledgement: Page is based on the older version by Rockingdice**_