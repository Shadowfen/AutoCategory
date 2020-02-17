AC_BAG_TYPE_BACKPACK = 1
AC_BAG_TYPE_BANK = 2
AC_BAG_TYPE_GUILDBANK = 3
AC_BAG_TYPE_CRAFTBAG = 4
AC_BAG_TYPE_CRAFTSTATION = 5
AC_BAG_TYPE_HOUSEBANK = 6

local SF = LibSFUtils
 
AutoCategory = {
    name = "AutoCategory",
    version = "2.4.2",
    settingName = "AutoCategory",
    settingDisplayName = "AutoCategory - Revised",
    author = "Shadowfen, crafty35, RockingDice",
}
AutoCategory.settingDisplayName = SF.GetIconized(AutoCategory.settingDisplayName, SF.colors.gold.hex)
AutoCategory.version = SF.GetIconized(AutoCategory.version, SF.colors.gold.hex)
AutoCategory.author = SF.GetIconized(AutoCategory.author, SF.colors.purple.hex)

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
    vc:CheckVersion("LibAddonMenu-2.0", 30)
    vc:CheckVersion("LibMediaProvider-1.0", 12)
    vc:CheckVersion("libChat2", 12)
    vc:CheckVersion("LibSFUtils", 23)
    vc:CheckVersion("LibDebugLogger",128)
    
    --if UnknownTracker then
    --    vc:CheckVersion("UnknownTracker",63)
    --end
end
