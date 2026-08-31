package.path = package.path .. ";C:/Users/scott/Documents/SFAddons/TK/?.lua;C:/Users/scott/Documents/Elder Scrolls Online/live/AddOns/LibSFUtils/?.lua"

require "zos"
require "tk"
local TK = TestKit

--local TR = test_run
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
require "AutoCategory_API"
require "AutoCategory"

require "Plugin_API"
require "plugins.Misc_Plugins"

local AC = AutoCategory
local CVT = AutoCategory.CVT

local ZO_PlayerInventory
local saved, cache


local mn, moduleName, class

local function MiscPlugins_testInit()
    ZO_PlayerInventory = {}
    moduleName = "Misc Plugins"
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


    saved = AutoCategory.saved
    cache = AutoCategory.cache
end

local function MiscPlugins_testReset()
    ZO_PlayerInventory = {}
    moduleName = ""

    saved = {}
    cache = {}
    AC.saved = {}
    AC.cache = {}
end

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
    TK.printSuite("MiscPlugins", fn)
    
    AutoCategory:setChecking(1, 5)

    TK.assertTrue(AutoCategory_MiscAddons.RuleFunc.GetPriceTTC("average") == 8, "Got TTC average price")
    TK.assertTrue(AutoCategory_MiscAddons.RuleFunc.GetPriceTTC("suggested") == 10, "Got TTC suggested price")
end

function Misc_runTests()
  MiscPlugins_testInit()
  
  Misc_testgetPriceTTC()
  
  MiscPlugins_testReset()
end

if not Suite then
    TK.init()
    
    Misc_testgetPriceTTC()
    
    TK.showResult("Misc TTC Tests")
end
