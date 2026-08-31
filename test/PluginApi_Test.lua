package.path = package.path .. ";C:/Users/scott/Documents/SFAddons/TK/?.lua;C:/Users/scott/Documents/Elder Scrolls Online/live/AddOns/LibSFUtils/?.lua"

require "zos"
require "tk"

local d = print

local AC_DECON = 880
local AC_IMPROV = 881
local UV_DECON = 882

require "LibSFUtils_Global"
require "SFUtils_Color"
require "LibSFUtils"
require "SFUtils_Tables"
require "SFUtils_Events"
require "SFUtils_HookManager"
require "SFUtils_LoadLanguage"
require "SFUtils_Logger"
local SF = LibSFUtils

require "AutoCategory_Global"
require "AutoCategory_Defaults"
require "Plugin_API"
require "Hooks_Keyboard"
require "classes.CVT"
require "classes.RuleList"
require "classes.RuleApi"
require "classes.BagRuleApi"
require "classes.BaseUI"
require "AutoCategory"

local AC = AutoCategory
local CVT = AutoCategory.CVT

local ZO_PlayerInventory
local saved, cache


local mn, moduleName, class

local function PluginApi_testInit()
    ZO_PlayerInventory = {}
    moduleName = "PluginApi"
    mn = moduleName
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

    saved = AutoCategory.saved
    cache = AutoCategory.cache
end

local function PluginApi_testReset()
    ZO_PlayerInventory = {}
    moduleName = ""

    saved = {}
    cache = {}
    AC.saved = {}
    AC.cache = {}
    AutoCategory.Environment = nil
end



local TK = TestKit
-- ============================================================
-- Plugin API Tests
-- ============================================================

-- ------------------------------------------------------------
-- dummyRuleFunc tests
-- ------------------------------------------------------------

local function testDummyRuleFunc()
    TK.printSuite("PluginAPI", "DummyRuleFunc")

    TK.assertNotNil(AutoCategory.dummyRuleFunc,
        "dummyRuleFunc exists")

    TK.assertFalse(AutoCategory.dummyRuleFunc(),
        "dummyRuleFunc returns false")
end


-- ------------------------------------------------------------
-- AddRuleFunc tests
-- ------------------------------------------------------------

local function testAddRuleFunc()
    TK.printSuite("PluginAPI", "AddRuleFunc")

    -- supplied function
    do
        local oldFunc = AutoCategory.Environment.TestRuleFunc

        local testFunc = function()
            return true
        end

        AutoCategory.AddRuleFunc("TestRuleFunc", testFunc)

        TK.assertEquals(testFunc,
            AutoCategory.Environment.TestRuleFunc,
            "AddRuleFunc installs supplied function")

        TK.assertTrue(AutoCategory.Environment.TestRuleFunc(),
            "AddRuleFunc installed function executes")

        AutoCategory.Environment.TestRuleFunc = oldFunc
    end


    -- omitted function
    do
        local oldFunc = AutoCategory.Environment.TestDummyRuleFunc

        AutoCategory.AddRuleFunc("TestDummyRuleFunc")

        TK.assertEquals(AutoCategory.dummyRuleFunc,
            AutoCategory.Environment.TestDummyRuleFunc,
            "AddRuleFunc uses dummyRuleFunc when omitted")

        TK.assertFalse(AutoCategory.Environment.TestDummyRuleFunc(),
            "default rule function returns false")

        AutoCategory.Environment.TestDummyRuleFunc = oldFunc
    end


    -- explicit nil function
    do
        local oldFunc = AutoCategory.Environment.TestNilRuleFunc

        AutoCategory.AddRuleFunc("TestNilRuleFunc", nil)

        TK.assertEquals(AutoCategory.dummyRuleFunc,
            AutoCategory.Environment.TestNilRuleFunc,
            "AddRuleFunc uses dummyRuleFunc for nil function")

        AutoCategory.Environment.TestNilRuleFunc = oldFunc
    end
end


-- ------------------------------------------------------------
-- LoadLanguage tests
-- ------------------------------------------------------------

local function testLoadLanguage()
    TK.printSuite("PluginAPI", "LoadLanguage")

    -- explicit default language
    do
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

        TK.assertEquals("TEST_RESULT", result,
            "LoadLanguage returns SF.LoadLanguage result")

        TK.assertEquals(strings, receivedTable,
            "LoadLanguage passes string table")

        TK.assertEquals("fr", receivedDefault,
            "LoadLanguage passes explicit default language")

        SF.LoadLanguage = oldLoadLanguage
    end


    -- default language
    do
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
end


-- ------------------------------------------------------------
-- RegisterPlugin tests
-- ------------------------------------------------------------

local function testRegisterPlugin()
    TK.printSuite("PluginAPI", "RegisterPlugin")

    -- valid plugin with predefined rules
    do
        local oldPlugin = AutoCategory.Plugins.TestPlugin

        local initFunc = function()
            return true
        end

        local predefined = {
            { name = "RuleOne" },
            { name = "RuleTwo" },
        }

        local result = AutoCategory.RegisterPlugin("TestPlugin", initFunc, predefined)

        TK.assertTrue(result, "RegisterPlugin accepts valid plugin")

        local entry = AutoCategory.Plugins.TestPlugin

        TK.assertNotNil(entry, "RegisterPlugin creates plugin entry")
        TK.assertEquals(initFunc, entry.init, "RegisterPlugin stores init function")
        TK.assertEquals(predefined, entry.predef, "RegisterPlugin stores predefined rules")
        TK.assertEquals(1, predefined[1].pred, "RegisterPlugin marks first predefined rule")
        TK.assertEquals(1, predefined[2].pred, "RegisterPlugin marks second predefined rule")

        AutoCategory.Plugins.TestPlugin = oldPlugin
    end


    -- missing init function
    do
        local oldPlugin = AutoCategory.Plugins.TestInvalidPlugin

        local result = AutoCategory.RegisterPlugin("TestInvalidPlugin", nil)
        TK.assertFalse(result, "RegisterPlugin rejects missing init function")
        TK.assertNil(AutoCategory.Plugins.TestInvalidPlugin,
            "RegisterPlugin creates no entry without init function")

        AutoCategory.Plugins.TestInvalidPlugin = oldPlugin
    end


    do
        local oldPlugin = AutoCategory.Plugins.TestNonFunctionPlugin

        local result = AutoCategory.RegisterPlugin("TestNonFunctionPlugin", "not a function")
        TK.assertFalse(result, "RegisterPlugin rejects non-function init")
        
        local entry = AutoCategory.Plugins.TestNonFunctionPlugin
        TK.assertNil(AutoCategory.Plugins.TestNonFunctionPlugin, 
          "RegisterPlugin creates no entry for non-function init")

        AutoCategory.Plugins.TestNonFunctionPlugin = oldPlugin
    end
    
    -- missing name
    do
        local result = AutoCategory.RegisterPlugin(nil, function() end)

        TK.assertFalse(result, "RegisterPlugin rejects missing name")
    end
    
    -- empty name
    do
        local result = AutoCategory.RegisterPlugin("", function() end)

        TK.assertFalse(result, "RegisterPlugin rejects empty name")
    end
end


-- ------------------------------------------------------------
-- Run complete AutoCategory API test suite
-- ------------------------------------------------------------

function runPluginAPITests()
    PluginApi_testInit()
    
    testDummyRuleFunc()
    testAddRuleFunc()
    testLoadLanguage()
    testRegisterPlugin()
    
    PluginApi_testReset()
end

if not Suite then
    TK.init()
    
    runPluginAPITests()
    
    TK.showResult("PluginAPI Tests")
end
