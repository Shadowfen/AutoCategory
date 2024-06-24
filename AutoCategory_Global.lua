AC_BAG_TYPE_BACKPACK = 1
AC_BAG_TYPE_BANK = 2
AC_BAG_TYPE_GUILDBANK = 3
AC_BAG_TYPE_CRAFTBAG = 4
AC_BAG_TYPE_CRAFTSTATION = 5
AC_BAG_TYPE_HOUSEBANK = 6

local SF = LibSFUtils
 
AutoCategory = {
    name = "AutoCategory",
    version = "4.0",
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


--[[
An implementation of a logger which uses the lua print function
to output the messages.

Generally used for out-of-game testing.
--]]
local printLibDebug = {
    Error = function(self,...)  print("ERROR: "..string.format(...)) end,
    Warn = function(self,...)  print("WARN: "..string.format(...)) end,
    Info = function(self,...)  print("INFO: "..string.format(...)) end,
    Debug = function(self,...)  print("DEBUG: "..string.format(...)) end,
}
setmetatable(printLibDebug,  { __call = function(self, name) 
            self.addonName = name 
            return self
        end
    })

-- initialize the logger for AutoCategory
if LibDebugLogger then
  AutoCategory.logger = LibDebugLogger.Create("AutoCategory")
  AutoCategory.logger:SetEnabled(true)
  
else
  AutoCategory.logger = printLibDebug
end

-- checks the versions of libraries (where possible) and warn in
-- debug logger if we detect out of date libraries.
function AutoCategory.checkLibraryVersions()
    if not LibDebugLogger then return end

    local addonName = AutoCategory.name
    local vc = SF.VersionChecker(addonName)
    local logger = LibDebugLogger.Create(addonName)
    vc:Enable(logger)
    vc:CheckVersion("LibAddonMenu-2.0", 36)
    vc:CheckVersion("LibMediaProvider-1.0", 30)
    vc:CheckVersion("LibDebugLogger",263)
    vc:CheckVersion("LibSFUtils",52)

    if UnknownTracker then
        vc:CheckVersion("UnknownTracker",75)
    end
end
