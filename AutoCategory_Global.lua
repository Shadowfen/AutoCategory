AC_BAG_TYPE_BACKPACK = 1
AC_BAG_TYPE_BANK = 2
AC_BAG_TYPE_GUILDBANK = 3
AC_BAG_TYPE_CRAFTBAG = 4
AC_BAG_TYPE_CRAFTSTATION = 5
AC_BAG_TYPE_HOUSEBANK = 6

local SF = LibSFUtils
 
AutoCategory = {
    name = "AutoCategory",
    version = "2.3.2",
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
    local logger = LibDebugLogger(addonName)
    
    local function versionCheck(libname, version, expectedVersion, isLibStub)
        if not libname or not expectedVersion then return end
        if not isLibStub and not _G[libname] then
            logger:Error("Missing required library %s: was not loaded prior to %s!", libname, addonName)
            return
        end
        if not version or version < expectedVersion then
            logger:Error("Outdated version of %s detected (%d) - possibly embedded in another older addon.", libname, version or -1) 
        end
    end
    
    -- check the libraries that still support LibStub
    -- because there we can get versions through a standard 
    -- mechanism.
    if LibStub then 
        local function checkLS(name, expected)
            local lib, ver
            lib, ver = LibStub:GetLibrary(name)
            versionCheck(name, ver, expected, true)
        end

        checkLS("LibAddonMenu-2.0", 30)
        checkLS("LibMediaProvider-1.0", 12)
    end
    
    -- check libraries that do not use LibStub
    versionCheck("LibSFUtils", LibSFUtils.LibVersion, 20)
    
    logger:Info("Library %s does not provide version information", "LibDebugLogger")
end
