AC_BAG_TYPE_BACKPACK = 1
AC_BAG_TYPE_BANK = 2
AC_BAG_TYPE_GUILDBANK = 3
AC_BAG_TYPE_CRAFTBAG = 4
AC_BAG_TYPE_CRAFTSTATION = 5
AC_BAG_TYPE_HOUSEBANK = 6
 
AutoCategory = {}

AutoCategory.RuleFunc = {}
AutoCategory.Inited = false
AutoCategory.Enabled = true

AutoCategory.name = "AutoCategory";
AutoCategory.version = "1.37";
AutoCategory.settingName = "Auto Category"
AutoCategory.settingDisplayName = "AutoCategory - Wrathstone"
AutoCategory.author = "RockingDice, crafty35, Shadowfen"
AutoCategory.localizefunc = function ( loc_key ) 
	return GetString( loc_key )
end