require "AutoCategory.test.zos"
require "AutoCategory.test.tk"
local TK = TestKit

local TR = test_run
local d = print

require "AutoCategory.AutoCategory_Global"
local AC = AutoCategory
require "LibSFUtils.LibSFUtils"
local SF = LibSFUtils
require "AutoCategory.Misc_Plugins"
require "AutoCategory.Plugin_API"

local moduleName = "MiscPlugins"

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
    Misc_testgetPriceTTC()
end