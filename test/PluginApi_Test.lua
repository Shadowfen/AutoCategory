package.path = package.path .. ";C:/Users/scott/Documents/SFAddons/TK/?.lua;C:/Users/scott/Documents/Elder Scrolls Online/live/AddOns/LibSFUtils/?.lua"

require "zos"
require "tk"

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
    AutoCategory.Plugins = {}

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
    AutoCategory.Plugins = {}
    AutoCategory.Environment = nil
    -- cleanup
    testZO_ResetStringTables() -- set the string tables back to a pre-loaded state (mostly)
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
    TK.assertNotNil(AutoCategory.dummyRuleFunc, "dummyRuleFunc exists")
    TK.assertFalse(AutoCategory.dummyRuleFunc(), "dummyRuleFunc returns false")
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

        TK.assertEquals(testFunc, AutoCategory.Environment.TestRuleFunc,
            "AddRuleFunc installs supplied function")

        TK.assertTrue(AutoCategory.Environment.TestRuleFunc(),
            "AddRuleFunc installed function executes")

        AutoCategory.Environment.TestRuleFunc = oldFunc
    end


    -- omitted function
    do
        local oldFunc = AutoCategory.Environment.TestDummyRuleFunc

        AutoCategory.AddRuleFunc("TestDummyRuleFunc")

        TK.assertEquals(AutoCategory.dummyRuleFunc, AutoCategory.Environment.TestDummyRuleFunc,
            "AddRuleFunc uses dummyRuleFunc when omitted")

        TK.assertFalse(AutoCategory.Environment.TestDummyRuleFunc(),
            "default rule function returns false")

        AutoCategory.Environment.TestDummyRuleFunc = oldFunc
    end


    -- explicit nil function
    do
        local oldFunc = AutoCategory.Environment.TestNilRuleFunc

        AutoCategory.AddRuleFunc("TestNilRuleFunc", nil)

        TK.assertEquals(AutoCategory.dummyRuleFunc, AutoCategory.Environment.TestNilRuleFunc,
            "AddRuleFunc uses dummyRuleFunc for nil function")

        AutoCategory.Environment.TestNilRuleFunc = oldFunc
    end
end

local function testOverWriteAddRuleFunc()
    TK.printSuite("PluginsApi", "testOverWriteAddRuleFunc")

    AutoCategory.Environment["testfunc"] = AutoCategory.dummyRuleFunc

    TK.assertNotNil(AutoCategory.Environment["testfunc"],
        "testfunc exists before overwrite")
    TK.assertTrue(AutoCategory.Environment["testfunc"] == AutoCategory.dummyRuleFunc,
        "Starting with dummy testfunc")
    TK.assertFalse(AutoCategory.Environment["testfunc"](),
        "dummy testfunc() runs correctly")

    local function fn()
        return true
    end

    AutoCategory.AddRuleFunc("testfunc", fn)

    TK.assertFalse(AutoCategory.Environment["testfunc"] == AutoCategory.dummyRuleFunc,
        "Success overwriting testfunc")
    TK.assertTrue(AutoCategory.Environment["testfunc"](),
        "testfunc() runs correctly")

    AutoCategory.Environment["testfunc"] = nil
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

        TK.assertTrue(result, "[Valid] RegisterPlugin accepts valid plugin")

        local entry = AutoCategory.Plugins.TestPlugin

        TK.assertNotNil(entry, "[Valid] RegisterPlugin creates plugin entry")
        TK.assertEquals(initFunc, entry.init, "[Valid] RegisterPlugin stores init function")
        TK.assertEquals(predefined, entry.predef, "[Valid] RegisterPlugin stores predefined rules")
        TK.assertEquals(1, predefined[1].pred, "[Valid] RegisterPlugin marks first predefined rule")
        TK.assertEquals(1, predefined[2].pred, "[Valid] RegisterPlugin marks second predefined rule")

        AutoCategory.Plugins.TestPlugin = oldPlugin
    end

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

        TK.assertTrue(result, "[Valid] RegisterPlugin accepts valid plugin")

        local entry = AutoCategory.Plugins.TestPlugin

        TK.assertNotNil(entry, "[Valid] RegisterPlugin creates plugin entry")
        TK.assertEquals(initFunc, entry.init, "[Valid] RegisterPlugin stores init function")
        TK.assertEquals(predefined, entry.predef, "[Valid] RegisterPlugin stores predefined rules")
        TK.assertEquals(1, predefined[1].pred, "[Valid] RegisterPlugin marks first predefined rule")
        TK.assertEquals(1, predefined[2].pred, "[Valid] RegisterPlugin marks second predefined rule")

        AutoCategory.Plugins.TestPlugin = oldPlugin
    end



    AutoCategory.Plugins.TestPlugin = oldPlugin
end

local function testRegisterPlugin_invalid()
    TK.printSuite("PluginAPI", "RegisterPlugin Invalid")


    -- missing init function
    do
        local oldPlugin = AutoCategory.Plugins.TestInvalidPlugin

        local result = AutoCategory.RegisterPlugin("TestInvalidPlugin", nil)
        TK.assertFalse(result, "[Invalid-missing] RegisterPlugin rejects missing init function")
        TK.assertNil(AutoCategory.Plugins.TestInvalidPlugin,
            "[Invalid-missing] RegisterPlugin creates no entry without init function")

        AutoCategory.Plugins.TestInvalidPlugin = oldPlugin
    end


    do
        local oldPlugin = AutoCategory.Plugins.TestNonFunctionPlugin

        local result = AutoCategory.RegisterPlugin("TestNonFunctionPlugin", "not a function")
        TK.assertFalse(result, "[Invalid-nonfunc] RegisterPlugin rejects non-function init")
        
        TK.assertNil(AutoCategory.Plugins.TestNonFunctionPlugin, 
          "[Invalid-nonfunc] RegisterPlugin creates no entry for non-function init")

        AutoCategory.Plugins.TestNonFunctionPlugin = oldPlugin
    end
    
    -- missing name
    do
        local result = AutoCategory.RegisterPlugin(nil, function() end)

        TK.assertFalse(result, "[Invalid-noname] RegisterPlugin rejects missing name")
    end
    
    -- empty name
    do
        local result = AutoCategory.RegisterPlugin("", function() end)

        TK.assertFalse(result, "[Invalid-noname] RegisterPlugin rejects empty name")
    end
end

local function testRegisterPluginInit()
    TK.printSuite(mn, "RegisterPluginInit")

    local oldEnvironment = AC.Environment
    AC.Environment = {}

    local tempFunc = function()
        return true
    end

    AC.RegisterPlugin("TestPluginNoFunc", function()
            AC.AddRuleFunc("testPluginRule")
        end)

    AC.Plugins.TestPluginNoFunc.init()

    TK.assertNotNil(AC.Environment.testPluginRule,
        "plugin init registers default rule function")

    AC.RegisterPlugin("TestPluginFunc", function()
            AC.AddRuleFunc("testPluginRuleFunc", tempFunc)
        end)

    AC.Plugins.TestPluginFunc.init()

    TK.assertEquals(tempFunc, AC.Environment.testPluginRuleFunc,
        "plugin init registers supplied rule function")

    AC.Environment = oldEnvironment
end

-- ------------------------------------------------------------
-- Run complete AutoCategory API test suite
-- ------------------------------------------------------------

function runPluginAPITests()
    PluginApi_testInit()
    
    testDummyRuleFunc()
    testAddRuleFunc()
    testOverWriteAddRuleFunc()

    testRegisterPlugin()
    testRegisterPlugin_invalid()
    testRegisterPluginInit()
    
    PluginApi_testReset()
end

if not Suite then
    TK.init()
    
    runPluginAPITests()
    
    TK.showResult("PluginAPI Tests")
end
