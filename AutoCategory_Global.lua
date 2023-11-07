AC_BAG_TYPE_BACKPACK = 1
AC_BAG_TYPE_BANK = 2
AC_BAG_TYPE_GUILDBANK = 3
AC_BAG_TYPE_CRAFTBAG = 4
AC_BAG_TYPE_CRAFTSTATION = 5
AC_BAG_TYPE_HOUSEBANK = 6

AC_INVEN_CV ={
	[AC_BAG_TYPE_BACKPACK]=INVENTORY_BACKPACK,
	[AC_BAG_TYPE_BANK]=INVENTORY_BANK,
	[AC_BAG_TYPE_GUILDBANK]=INVENTORY_GUILD_BANK,
	[AC_BAG_TYPE_CRAFTBAG]=INVENTORY_CRAFT_BAG,
	[AC_BAG_TYPE_CRAFTSTATION]=INVENTORY_BACKPACK,
	[AC_BAG_TYPE_HOUSEBANK]=INVENTORY_HOUSE_BANK,
}

local SF = LibSFUtils
 
AutoCategory = {
    name = "AutoCategory",
    version = "3.6.5",
    settingName = "AutoCategory",
    settingDisplayName = "AutoCategory - Revised",
    author = "Shadowfen, crafty35, RockingDice, Friday_the13_rus",
}
AutoCategory.settingDisplayName = SF.colors.gold:Colorize(AutoCategory.settingDisplayName)
AutoCategory.version = SF.colors.gold:Colorize(AutoCategory.version)
AutoCategory.author = SF.colors.purple:Colorize(AutoCategory.author)

AutoCategory.RuleFunc = {}
AutoCategory.Plugins = {}
AutoCategory.Inited = false
AutoCategory.Enabled = true

-- load in localization strings
SF.LoadLanguage(AutoCategory_localization_strings, "en")


-- checks the versions of libraries (where possible) and warn in
-- debug logger if we detect out of date libraries.
function AutoCategory.checkLibraryVersions()
    if not LibDebugLogger then return end
    
    local addonName = AutoCategory.name    
    local vc = SF.VersionChecker(addonName)
    local logger = LibDebugLogger.Create(addonName)
    vc:Enable(logger)
    vc:CheckVersion("LibAddonMenu-2.0", 32)
    vc:CheckVersion("LibMediaProvider-1.0", 18)
    vc:CheckVersion("LibSFUtils", 32)
    vc:CheckVersion("LibDebugLogger",217)
    vc:CheckVersion("LibSFUtils",38)
    
    if UnknownTracker then
        vc:CheckVersion("UnknownTracker",71)
    end
end
