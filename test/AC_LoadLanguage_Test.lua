package.path = package.path .. ";C:/Users/scott/Documents/SFAddons/TK/?.lua;C:/Users/scott/Documents/Elder Scrolls Online/live/AddOns/LibSFUtils/?.lua"

require "zos"
require "tk"

require "LibSFUtils_Global"
require "SFUtils_Color"
require "LibSFUtils"
require "SFUtils_Tables"
require "SFUtils_LoadLanguage"
require "SFUtils_Logger"
local SF = LibSFUtils

require "AutoCategory_Global"
require "classes.CVT"
require "classes.RuleList"
require "classes.RuleApi"
require "classes.BagRuleApi"
require "classes.BaseUI"

require "Plugin_API"
require "lang.strings"
require "lang.zh"
require "lang.fr"
require "plugins.FCOIS_Plugin"

local TK = TestKit
local AC = AutoCategory
local CVT = AutoCategory.CVT

local ZO_PlayerInventory
local saved, cache


local mn, moduleName, class

local function ACLoadLang_testInit()
    ZO_PlayerInventory = {}
    moduleName = "ACLoadLang"
    mn = "ACLoadLang"
    class = moduleName

    AutoCategory.saved = {
        rules = {}, -- obsolete
        bags = {}, 
        general = {},   -- from savedvars
        appearance = {}, -- from savedvars
        collapses = {},  
    }

    AutoCategory.cache = {
        bags_cvt = CVT:New(nil, nil, CVT.USE_VALUES + CVT.USE_TOOLTIPS),
        entriesByBag = {},
        entriesByShowBag = {},
        entriesByName = {},
    }

    AutoCategory.BagRuleEntry = {}
    AutoCategory.Environment = {}
    AutoCategory.Plugins = {}

    saved = AutoCategory.saved
    cache = AutoCategory.cache
end

local function ACLoadLang_testReset()
    ZO_PlayerInventory = {}
    moduleName = ""

    saved = {}
    cache = {}
    AC.saved = {}
    AC.cache = {}
    AutoCategory.Plugins = {}
    AutoCategory.Environment = nil
    AutoCategory.LoadLanguage(AutoCategory_localization_strings,"en")
end


local function ACLoadLang_testInitialLoadLanguage()
    TK.printSuite( mn, "testInitialLoadLanguage")
    testZO_ResetStringTables() -- set the string tables back to a pre-loaded state (mostly)
    
    AutoCategory.LoadLanguage(AutoCategory_localization_strings,"en")
    local str = GetString(SI_AC_BAGTYPE_SHOWNAME_BACKPACK)
    TK.assertNotNil(str,"found SI_AC_BAGTYPE_SHOWNAME_BACKPACK")
    TK.assertTrue(str == "Backpack", "value is correct")
end


local function ACLoadLang_testPluginLoadLanguage()
    TK.printSuite( mn, "testPluginLoadLanguage")
    
    AutoCategory_FCOIS.LoadLanguage("en")
    local str = GetString(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_1)
    --d("SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_1 = "..(str or "nil"))
    TK.assertNotNil(str, "found FCOIS_DYNAMIC_1 string")
    TK.assertTrue(str == "Dynamic 1","FCOIS_DYNAMIC_1 value is correct")
    
    local L = GetString
    str = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DECONSTRUCTION_MARK)
    --d("SI_AC_DEFAULT_CATEGORY_FCOIS_DECONSTRUCTION_MARK = "..(str or "nil"))
    TK.assertNotNil(str, "found FCOIS_DECONSTRUCTION_MARK string")
    TK.assertTrue(str == "Deconstruction Mark","FCOIS_DECONSTRUCTION_MARK value is correct")
end

local function ACLoadLang_testChineseOnlyLoadLanguage()
    TK.printSuite(mn, "testChineseOnlyLoadLanguage")
    
    local getcv = GetCVar
    GetCVar = function(var)
        return "zh"
    end
    testZO_ResetStringTables()
    
    AutoCategory.LoadLanguage(AutoCategory_localization_strings,"zh")
    local str = GetString(SI_AC_BAGTYPE_SHOWNAME_BACKPACK)
    TK.assertNotNil(str,"found SI_AC_BAGTYPE_SHOWNAME_BACKPACK")
    TK.assertTrue(str == "随身背包", "Got chinese version of Backpack")
    GetCVar = getcv
end

local function ACLoadLang_testChinese2FrenchLoadLanguage()
    TK.printSuite(mn, "testChinese2FrenchLoadLanguage")
    
    local getcv = GetCVar     -- save the real one
    GetCVar = function(var)
        return "fr"
    end
    testZO_ResetStringTables()
    
    AutoCategory.LoadLanguage(AutoCategory_localization_strings,"zh")
    local str = GetString(SI_AC_BAGTYPE_SHOWNAME_BACKPACK)
    TK.assertNotNil(str,"found SI_AC_BAGTYPE_SHOWNAME_BACKPACK")
    TK.assertTrue(str == "Inventaire","Got french version of Backpack")
    GetCVar = getcv
end

local function ACLoadLang_testExplicitDefault()
    TK.printSuite(mn, "LoadLanguage_ExplicitDefault")

    -- explicit default language
    local oldLoadLanguage = SF.LoadLanguage
    local receivedTable
    local receivedDefault

    SF.LoadLanguage = function(stringtable, default_language)
            receivedTable = stringtable
            receivedDefault = default_language
            return "TEST_RESULT"
        end

    local strings = {
        en = {
            TEST_STRING = "English",
        },
    }

    local result = AutoCategory.LoadLanguage(strings, "fr")

    TK.assertEquals("TEST_RESULT", result, "LoadLanguage returns SF.LoadLanguage result")
    TK.assertEquals(strings, receivedTable, "LoadLanguage passes string table")
    TK.assertEquals("fr", receivedDefault, "LoadLanguage passes explicit default language")

    SF.LoadLanguage = oldLoadLanguage
end

local function ACLoadLang_testDefaultLanguage()
    TK.printSuite(mn, "LoadLanguage_DefaultLanguage")

     -- default language
    local oldLoadLanguage = SF.LoadLanguage
    local receivedDefault

    SF.LoadLanguage = function(stringtable, default_language)
            receivedDefault = default_language
            return true
        end

    AutoCategory.LoadLanguage({
        en = {
            TEST_STRING = "English",
        },
    })

    TK.assertEquals("en", receivedDefault, "LoadLanguage defaults language to en")

    SF.LoadLanguage = oldLoadLanguage
end


function ACLoadLang_runTests()
    ACLoadLang_testInit()
    
    --
    ACLoadLang_testInitialLoadLanguage()
    ACLoadLang_testPluginLoadLanguage()
    ACLoadLang_testChineseOnlyLoadLanguage()
    ACLoadLang_testChinese2FrenchLoadLanguage()

    ACLoadLang_testExplicitDefault()
    ACLoadLang_testDefaultLanguage()

    -- cleanup
    testZO_ResetStringTables() -- set the string tables back to a pre-loaded state (mostly)
    ACLoadLang_testReset()
end

if not Suite then
    TK.init()
    
    ACLoadLang_runTests()
    
    TK.showResult("PluginsAPI Tests")
end
