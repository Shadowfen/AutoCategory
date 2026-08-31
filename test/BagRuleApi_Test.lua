package.path = package.path .. ";C:/Users/scott/Documents/SFAddons/TK/?.lua;C:/Users/scott/Documents/Elder Scrolls Online/live/AddOns/LibSFUtils/?.lua"

require "zos"
require "tk"
local TK = TestKit

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

local moduleName = "BagRuleApi"
local mn, class

local function Test_BagRuleApi_Init()
    ZO_PlayerInventory = {}
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

    saved = AutoCategory.saved
    cache = AutoCategory.cache
end

local function Test_BagRuleApi_Reset()
    ZO_PlayerInventory = {}

    AC.saved = {}
end

-- ============================================================
-- BagRuleApiMixin tests
-- ============================================================

-- ============================================================
-- BagRuleApi tests
-- ============================================================
local function newTestBagRule(name, runpriority, showpriority)
    local bagRule = {
        name = name or "Test Rule",
        runpriority = runpriority or 1000,
        showpriority = showpriority or runpriority or 1000,
    }

    setmetatable(bagRule, {
        __index = AutoCategory.BagRuleApiMixin
    })

    return bagRule
end


-- ============================================================
-- convertPriority
-- ============================================================

function Test_BagRuleApi_convertPriority()
    TK.printSuite("BagRuleApi", "convertPriority")

    local bagRule = newTestBagRule("Test Rule")

    bagRule.priority = 250
    bagRule.runpriority = nil
    bagRule.showpriority = nil

    bagRule:convertPriority()

    TK.assertEqual(250, bagRule.runpriority,
        "priority converted to runpriority")

    TK.assertNil(bagRule.priority,
        "old priority removed")

    TK.assertEqual(250, bagRule.showpriority,
        "showpriority defaults to runpriority")
end


function Test_BagRuleApi_convertPriority_preservesShow()
    local bagRule = newTestBagRule("Test Rule")

    bagRule.priority = 250
    bagRule.runpriority = nil
    bagRule.showpriority = 500

    bagRule:convertPriority()

    TK.assertEqual(250, bagRule.runpriority,
        "priority converted to runpriority")

    TK.assertNil(bagRule.priority,
        "old priority removed")

    TK.assertEqual(500, bagRule.showpriority,
        "existing showpriority preserved")
end


function Test_BagRuleApi_convertPriority_alreadyConverted()
    local bagRule = newTestBagRule("Test Rule", 100, 200)

    bagRule:convertPriority()

    TK.assertEqual(100, bagRule.runpriority,
        "existing runpriority preserved")

    TK.assertEqual(200, bagRule.showpriority,
        "existing showpriority preserved")

    TK.assertNil(bagRule.priority,
        "priority remains nil")
end


-- ============================================================
-- isValid
-- ============================================================

function Test_BagRuleApi_isValid()
    TK.printSuite("BagRuleApi", "isValid")

    local bagRule = newTestBagRule("Test Rule", 100, 200)

    TK.assertTrue(bagRule:isValid(),
        "valid bag rule")
end


function Test_BagRuleApi_isValid_missingName()
    local bagRule = newTestBagRule("Test Rule")

    bagRule.name = nil

    TK.assertFalse(bagRule:isValid(),
        "missing name is invalid")
end


function Test_BagRuleApi_isValid_emptyName()
    local bagRule = newTestBagRule("Test Rule")

    bagRule.name = ""

    TK.assertFalse(bagRule:isValid(),
        "empty name is invalid")
end


function Test_BagRuleApi_isValid_missingPriority()
    local bagRule = newTestBagRule("Test Rule")

    bagRule.runpriority = nil

    TK.assertFalse(bagRule:isValid(),
        "missing runpriority is invalid")
end


function Test_BagRuleApi_isValid_zeroPriority()
    local bagRule = newTestBagRule("Test Rule")

    bagRule.runpriority = 0

    TK.assertTrue(bagRule:isValid(),
        "zero runpriority is valid")
end


-- ============================================================
-- formatValue
-- ============================================================

function Test_BagRuleApi_formatValue()
    TK.printSuite("BagRuleApi", "formatValue")

    local bagRule = newTestBagRule("My Category")

    TK.assertEqual("My Category", bagRule:formatValue(),
        "formatValue returns name")
end


function Test_BagRuleApi_formatValue_changedName()
    local bagRule = newTestBagRule("Original")

    bagRule.name = "Changed"

    TK.assertEqual("Changed", bagRule:formatValue(),
        "formatValue returns current name")
end


-- ============================================================
-- getBackingRule
-- ============================================================

function Test_BagRuleApi_getBackingRule_missingName()
    TK.printSuite("BagRuleApi", "getBackingRule")

    local bagRule = newTestBagRule("Test Rule")

    bagRule.name = nil

    TK.assertNil(bagRule:getBackingRule(),
        "missing name returns nil")
end


function Test_BagRuleApi_getBackingRule_missingRule()
    local bagRule = newTestBagRule("Rule That Does Not Exist")

    TK.assertNil(bagRule:getBackingRule(),
        "missing backing rule returns nil")
end


-- ============================================================
-- setHidden
-- ============================================================

function Test_BagRuleApi_setHidden()
    TK.printSuite("BagRuleApi", "setHidden")

    local bagRule = newTestBagRule("Test Rule")

    local result = bagRule:setHidden(true)

    TK.assertTrue(result,
        "setHidden(true) returns true")

    TK.assertTrue(bagRule.isHidden,
        "isHidden set to true")
end


function Test_BagRuleApi_setHidden_false()
    local bagRule = newTestBagRule("Test Rule")

    bagRule.isHidden = true

    local result = bagRule:setHidden(false)

    TK.assertFalse(result,
        "setHidden(false) returns false")

    TK.assertNil(bagRule.isHidden,
        "false stored as nil")
end


function Test_BagRuleApi_setHidden_falseAlreadyNil()
    local bagRule = newTestBagRule("Test Rule")

    local result = bagRule:setHidden(false)

    TK.assertFalse(result,
        "setHidden(false) returns false when already nil")

    TK.assertNil(bagRule.isHidden,
        "isHidden remains nil")
end


function Test_BagRuleApi_setHidden_sameValue()
    local bagRule = newTestBagRule("Test Rule")

    bagRule.isHidden = true

    local result = bagRule:setHidden(true)

    TK.assertTrue(result,
        "setting same hidden value returns existing value")

    TK.assertTrue(bagRule.isHidden,
        "isHidden remains true")
end

function BagRuleApi_runTests()
    Test_BagRuleApi_Init()
    
    Test_BagRuleApi_convertPriority()
    Test_BagRuleApi_convertPriority_preservesShow()
    Test_BagRuleApi_convertPriority_alreadyConverted()
    Test_BagRuleApi_isValid()
    Test_BagRuleApi_isValid_missingName()
    Test_BagRuleApi_isValid_emptyName()
    Test_BagRuleApi_isValid_missingPriority()
    Test_BagRuleApi_isValid_zeroPriority()
    Test_BagRuleApi_formatValue()
    Test_BagRuleApi_formatValue_changedName()
    Test_BagRuleApi_getBackingRule_missingName()
    Test_BagRuleApi_getBackingRule_missingRule()
    Test_BagRuleApi_setHidden()
    Test_BagRuleApi_setHidden_false()
    Test_BagRuleApi_setHidden_falseAlreadyNil()
    Test_BagRuleApi_setHidden_sameValue()
    
    Test_BagRuleApi_Reset()
end

if not Suite then
    TK.init()
    
    BagRuleApi_runTests()
    
    TK.showResult("AutoCat Tests")
end
