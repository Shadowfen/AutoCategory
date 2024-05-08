AC_BAG_TYPE_BACKPACK = 1
AC_BAG_TYPE_BANK = 2
AC_BAG_TYPE_GUILDBANK = 3
AC_BAG_TYPE_CRAFTBAG = 4
AC_BAG_TYPE_CRAFTSTATION = 5
AC_BAG_TYPE_HOUSEBANK = 6
--[[
AC_INVEN_CV ={
	[AC_BAG_TYPE_BACKPACK]=INVENTORY_BACKPACK,
	[AC_BAG_TYPE_BANK]=INVENTORY_BANK,
	[AC_BAG_TYPE_GUILDBANK]=INVENTORY_GUILD_BANK,
	[AC_BAG_TYPE_CRAFTBAG]=INVENTORY_CRAFT_BAG,
	[AC_BAG_TYPE_CRAFTSTATION]=INVENTORY_BACKPACK,
	[AC_BAG_TYPE_HOUSEBANK]=INVENTORY_HOUSE_BANK,
}
--]]
local SF = LibSFUtils
 
AutoCategory = {
    name = "AutoCategory",
    version = "3.6.7",
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
    vc:CheckVersion("LibAddonMenu-2.0", 35)
    vc:CheckVersion("LibMediaProvider-1.0", 27)
    vc:CheckVersion("LibDebugLogger",263)
    vc:CheckVersion("LibSFUtils",49)
    
    if UnknownTracker then
        vc:CheckVersion("UnknownTracker",73)
    end
end


--[[
An implementation of a logger which uses the lua print function
to output the messages.
--]]
local printLibDebug = {
    Error = function(self,...)  print("ERROR: "..string.format(...)) end,
    Warn = function(self,...)  print("WARN: "..string.format(...)) end,
    Info = function(self,...)  print("INFO: "..string.format(...)) end,
    Debug = function(self,...)  print("DEBUG: "..string.format(...)) end,
}
setmetatable(printLibDebug, getmetatable(nilLibDebug))


if LibDebugLogger then
  AutoCategory.logger = LibDebugLogger.Create("AutoCategory")
  AutoCategory.logger:SetEnabled(true)
else
  AutoCategory.logger = printLibDebug
end
