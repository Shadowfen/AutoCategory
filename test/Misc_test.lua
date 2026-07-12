package.path = package.path .. ";C:/Users/scott/Documents/SFAddons/TK/?.lua;C:/Users/scott/Documents/Elder Scrolls Online/live/AddOns/LibSFUtils/?.lua"

require "zos"
require "tk"
local TK = TestKit

local TR = test_run
local d = print

require "LibSFUtils_Global"
require "SFUtils_Color"
require "LibSFUtils"
require "SFUtils_Tables"
require "SFUtils_LoadLanguage"
require "SFUtils_Logger"
require "SFUtils_Events"
require "SFUtils_HookManager"
local SF = LibSFUtils

require "AutoCategory_Global"
require "AutoCategory_Defaults"
require "Hooks_Keyboard"
require "classes.CVT"
require "classes.RuleList"
require "classes.RuleApi"
require "AutoCategory"
require "Plugin_API"
local AC = AutoCategory
require "plugins.Misc_Plugins"

local moduleName = "MiscPlugins"
local mn = moduleName

function GetItemLink()
    return "dummyItemLink"
end

-- make sure the entire list of predefinedRules for Iakoni GearChanger gets loaded without any
-- reported errors.
TamrielTradeCentre = {}
TamrielTradeCentrePrice={}
function TamrielTradeCentrePrice:GetPriceInfo(itemLink)
    local priceinfo = { SuggestedPrice=10, Avg = 8, }
    return priceinfo
end
local function Misc_testgetPriceTTC()
    local fn = "testgetPriceTTC"
    TK.printSuite(moduleName,fn)
    
    TK.assertTrue(AutoCategory_MiscAddons.RuleFunc.GetPriceTTC("average") == 8, "Got TTC average price")
    TK.assertTrue(AutoCategory_MiscAddons.RuleFunc.GetPriceTTC("suggested") == 10, "Got TTC suggested price")
end

function Misc_runTests()
  --Misc_testgetPriceTTC()
end

TK.init()
  
--Misc_testgetPriceTTC()

TK.showResult(mn)