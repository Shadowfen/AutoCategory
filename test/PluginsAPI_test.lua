package.path = package.path .. ";C:/Users/scott/Documents/SFAddons/TK/?.lua;C:/Users/scott/Documents/Elder Scrolls Online/live/AddOns/LibSFUtils/?.lua"

require "zos"
require "tk"

local d = print

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

local function PluginsAPI_testInit()
    ZO_PlayerInventory = {}
    moduleName = "PluginsApi"
    mn = "PluginsApi"
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

local function PluginsAPI_testReset()
    ZO_PlayerInventory = {}
    moduleName = ""

    saved = {}
    cache = {}
    AC.saved = {}
    AC.cache = {}
    AutoCategory.Environment = nil
    AutoCategory.LoadLanguage(AutoCategory_localization_strings,"en")
end


local function Plugins_testInitialLoadLanguage()
    local fn = "testInitialLoadLanguage"
    TK.printSuite( "PluginsApi", fn)
    testZO_ResetStringTables() -- set the string tables back to a pre-loaded state (mostly)
    
    AutoCategory.LoadLanguage(AutoCategory_localization_strings,"en")
    local str = GetString(SI_AC_BAGTYPE_SHOWNAME_BACKPACK)
    TK.assertNotNil(str,"found SI_AC_BAGTYPE_SHOWNAME_BACKPACK")
    TK.assertTrue(str == "Backpack", "value is correct")
end


local function Plugins_testPluginLoadLanguage()
    TK.printSuite( "PluginsApi", "testPluginLoadLanguage")
    
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

local function Plugins_testChineseOnlyLoadLanguage()
    local fn = "testChineseOnlyLoadLanguage"
    TK.printSuite("PluginsApi",fn)
    
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

local function Plugins_testChinese2FrenchLoadLanguage()
    local fn = "testChinese2FrenchLoadLanguage"
    TK.printSuite("PluginsApi",fn)
    
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

local function Plugins_testAddRuleFunc()
    local tn = "testAddRuleFunc"
    TK.printSuite("PluginsApi",tn)
    
    TK.assertNil(AutoCategory.Environment["testfunc"],"need to add testfunc")
    
    local function fn() return true end -- the default func returns false, so be different
    AutoCategory.AddRuleFunc("testfunc", fn)
    
    TK.assertNotNil(AutoCategory.Environment["testfunc"], "Success adding testfunc")
    TK.assertTrue(AutoCategory.Environment["testfunc"](), "testfunc() runs correctly")
    AutoCategory.Environment["testfunc"] = nil -- clean up after test
end

local function Plugins_testDefaultAddRuleFunc()
    TK.printSuite("PluginsApi", "testDefaultAddRuleFunc")
    
    TK.assertNil(AutoCategory.Environment["testfunc"],"need to add testfunc")
    
    AutoCategory.AddRuleFunc("testfunc")
    TK.assertNotNil(AutoCategory.Environment["testfunc"], "Success adding testfunc")
    
    TK.assertFalse(AutoCategory.Environment["testfunc"](), "testfunc() runs the dummy function correctly")
    --AutoCategory.Environment["testfunc"] = nil -- DON'T clean up after test
end

local function Plugins_testOverWriteAddRuleFunc()
    TK.printSuite("PluginsApi", "testOverWriteAddRuleFunc")
    
    TK.assertNotNil(AutoCategory.Environment["testfunc"],"do not need to add testfunc")
    
    TK.assertTrue(AutoCategory.Environment["testfunc"] == AutoCategory.dummyRuleFunc, "Starting with dummy testfunc")
    TK.assertFalse(AutoCategory.Environment["testfunc"](), "dummy testfunc() runs correctly")
    
    local function fn() return true end -- the default func returns false, so be different
    AutoCategory.AddRuleFunc("testfunc", fn)
    TK.assertFalse(AutoCategory.Environment["testfunc"] == AutoCategory.dummyRuleFunc, "Success overwriting testfunc")
    TK.assertTrue(AutoCategory.Environment["testfunc"](), "testfunc() runs correctly")
    
    AutoCategory.Environment["testfunc"] = nil -- clean up after test
end

local function Plugins_testRegisterPlugin()
    TK.printSuite("PluginsApi", "testRegisterPlugin")
    
    local plin = {}
    AutoCategory.Plugins = {}
    
    AutoCategory.RegisterPlugin("FCOIS", function() plin[1] = true end)
    TK.assertNotNil(AutoCategory.Plugins["FCOIS"], "Registered testFCOIS")
    
    AutoCategory.Plugins["FCOIS"].init()
    TK.assertTrue(plin[1] == true, "Running the init function worked")
    
    AutoCategory.RegisterPlugin("HAHA", function() AutoCategory.AddRuleFunc("hahaismarked") end)
    AutoCategory.Plugins["HAHA"].init()
    TK.assertNotNil(AutoCategory.Environment["hahaismarked"], "hahaismarked function found in Environment")
    
    local tempfunc = function () return true end
    AutoCategory.RegisterPlugin("HeeHee", function() AutoCategory.AddRuleFunc("heeheismarked", tempfunc) end)
    AutoCategory.Plugins["HeeHee"].init()
    TK.assertNotNil(AutoCategory.Environment["heeheismarked"], "heheismarked function found in Environment")
end

function PluginsAPI_runTests()
    PluginsAPI_testInit()
    
    Plugins_testInitialLoadLanguage()
    Plugins_testPluginLoadLanguage()
    Plugins_testChineseOnlyLoadLanguage()
    Plugins_testChinese2FrenchLoadLanguage()
    Plugins_testAddRuleFunc()
    Plugins_testDefaultAddRuleFunc()
    Plugins_testOverWriteAddRuleFunc()
    Plugins_testRegisterPlugin()
    
    -- cleanup
    testZO_ResetStringTables() -- set the string tables back to a pre-loaded state (mostly)
    PluginsAPI_testReset()
end

if not Suite then
    TK.init()
    
    PluginsAPI_runTests()
    
    TK.showResult("PluginsAPI Tests")
end
