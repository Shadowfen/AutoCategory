require "AutoCategory.test.zos-ac"
require "AutoCategory.test.tk"
local TK = TestKit
local d = print

require "LibSFUtils.LibSFUtils_Global"
require "LibSFUtils.SFUtils_Color"
require "LibSFUtils.LibSFUtils"
require "LibSFUtils.SFUtils_LoadLanguage"
local SF = LibSFUtils
require "AutoCategory.AutoCategory_Global"
require "AutoCategory.Plugin_API"
require "AutoCategory.lang.strings"
require "AutoCategory.lang.zh"
require "AutoCategory.lang.fr"
require "AutoCategory.FCOIS_Plugin"

local mn = "PluginsAPI"
AutoCategory.Environment = {}   -- Actually defined in AutoCategory_RuleFunc

local function Plugins_testInitialLoadLanguage()
    local fn = "testInitialLoadLanguage"
    TK.printSuite(mn,fn)
    testZO_ResetStringTables() -- set the string tables back to a pre-loaded state (mostly)
    
    AutoCategory.LoadLanguage(AutoCategory_localization_strings,"en")
    local str = GetString(SI_AC_BAGTYPE_SHOWNAME_BACKPACK)
    TK.assertNotNil(str,"found SI_AC_BAGTYPE_SHOWNAME_BACKPACK")
    TK.assertTrue(str == "Backpack", "value is correct")
end


local function Plugins_testPluginLoadLanguage()
    local fn = "testPluginLoadLanguage"
    TK.printSuite(mn,fn)
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
    TK.printSuite(mn,fn)
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
    TK.printSuite(mn,fn)
    local getcv = GetCVar
    GetCVar = function(var)
        return "fr"
    end
    testZO_ResetStringTables()
    AutoCategory.LoadLanguage(AutoCategory_localization_strings,"zh")
    local str = GetString(SI_AC_BAGTYPE_SHOWNAME_BACKPACK)
    TK.assertNotNil(str,"found SI_AC_BAGTYPE_SHOWNAME_BACKPACK")
    TK.assertTrue(str == "Sac","Got french version of Backpack")
    GetCVar = getcv
end

local function Plugins_testAddRuleFunc()
    local tn = "testAddRuleFunc"
    TK.printSuite(mn,tn)
    TK.assertNil(AutoCategory.Environment["testfunc"],"need to add testfunc")
    local function fn() return true end -- the default func returns false, so be different
    AutoCategory.AddRuleFunc("testfunc", fn)
    TK.assertNotNil(AutoCategory.Environment["testfunc"], "Success adding testfunc")
    TK.assertTrue(AutoCategory.Environment["testfunc"](), "testfunc() runs correctly")
    AutoCategory.Environment["testfunc"] = nil -- clean up after test
end

local function Plugins_testDefaultAddRuleFunc()
    local tn = "testDefaultAddRuleFunc"
    TK.printSuite(mn,tn)
    TK.assertNil(AutoCategory.Environment["testfunc"],"need to add testfunc")
    AutoCategory.AddRuleFunc("testfunc")
    TK.assertNotNil(AutoCategory.Environment["testfunc"], "Success adding testfunc")
    TK.assertFalse(AutoCategory.Environment["testfunc"](), "testfunc() runs the dummy function correctly")
    --AutoCategory.Environment["testfunc"] = nil -- DON'T clean up after test
end

local function Plugins_testOverWriteAddRuleFunc()
    local tn = "testOverWriteAddRuleFunc"
    TK.printSuite(mn,tn)
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
    local tn = "testRegisterPlugin"
    TK.printSuite(mn,tn)
    local plin = {}
    AutoCategory.Plugins = {}
    AutoCategory.RegisterPlugin("FCOIS", function() plin[1] = true end)
    TK.assertNotNil(AutoCategory.Plugins["FCOIS"], "Registered testFCOIS")
    AutoCategory.Plugins["FCOIS"]()
    TK.assertTrue(plin[1] == true, "Running the init function worked")
    AutoCategory.RegisterPlugin("HAHA", function() AutoCategory.AddRuleFunc("hahaismarked") end)
    AutoCategory.Plugins["HAHA"]()
    TK.assertNotNil(AutoCategory.Environment["hahaismarked"], "hahaismarked function found in Environment")
    local tempfunc = function () return true end
    AutoCategory.RegisterPlugin("HeeHee", function() AutoCategory.AddRuleFunc("heeheismarked", tempfunc) end)
    AutoCategory.Plugins["HeeHee"]()
    TK.assertNotNil(AutoCategory.Environment["heeheismarked"], "heheismarked function found in Environment")
end


--function Plugins_runTests()
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
    AutoCategory.LoadLanguage(AutoCategory_localization_strings,"en")

--end

