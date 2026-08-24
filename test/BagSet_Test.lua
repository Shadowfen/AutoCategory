package.path = package.path .. ";C:/Users/scott/Documents/SFAddons/TK/?.lua;C:/Users/scott/Documents/Elder Scrolls Online/live/AddOns/LibSFUtils/?.lua"

local moduleName = "CVT"
local mn = moduleName

require "zos"
require "tk"
local TK = TestKit

local d = print

local AC_DECON = 880
local AC_IMPROV = 881
local UV_DECON = 882

local ZO_PlayerInventory = {}

require "LibSFUtils_Global"
require "SFUtils_Color"
require "LibSFUtils"
require "SFUtils_Tables"
require "SFUtils_Events"
require "SFUtils_HookManager"
require "SFUtils_CallLater"
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
require "settings.UI_Utilities"
require "settings.BagSet"
require "settings.CategorySettings"
--require "settings.DisplayOrderWin"
require "AddonMenu"

local AC = AutoCategory

local saved = {} --AutoCategory.saved
local cache = {} --AutoCategory.cache

AutoCategory.dspWin = {
    SelectItem = function(a, b, c) end,
    ClearList = function() end,
    UpdateScrollList = function() end,
}


--[[---------------------------------------------------------------------------
    AutoCategory BagSet TestKit tests
-----------------------------------------------------------------------------]]

local BAG1 = AC_BAG_TYPE_BACKPACK
local BAG2 = AC_BAG_TYPE_BANK
local BAG3 = AC_BAG_TYPE_GUILDBANK

local RULE1 = "Rule One"
local RULE2 = "Rule Two"
local RULE3 = "Rule Three"


-- ============================================================================
-- Test fixture
-- ============================================================================

local function makeRule(name, runpriority, showpriority, isHidden)
    return {
        name = name,
        runpriority = runpriority,
        showpriority = showpriority,
        isHidden = isHidden,
    }
end


local function makeBag(rules, hidden)
    return {
        isUngroupedHidden = hidden,
        rules = rules,
    }
end


local function setupBagData()
    AC.saved = {
        bags = {
            [BAG1] = makeBag({
                makeRule(RULE1, 10, 20),
                makeRule(RULE2, 30, 40),
            }, false),

            [BAG2] = makeBag({
                makeRule(RULE1, 15, 25),
            }, true),

            [BAG3] = makeBag({
                makeRule(RULE3, 50, 60),
            }, false),
        },
    }

    AC.cache = AC.cache or {}

    AC.cache.entriesByName = {
        [BAG1] = {
            [RULE1] = AC.saved.bags[BAG1].rules[1],
            [RULE2] = AC.saved.bags[BAG1].rules[2],
        },

        [BAG2] = {
            [RULE1] = AC.saved.bags[BAG2].rules[1],
        },

        [BAG3] = {
            [RULE3] = AC.saved.bags[BAG3].rules[1],
        },
    }

    AC.cache.entriesByBag = {
        [BAG1] = {
            choices = { RULE1, RULE2 },
            choicesValues = { RULE1, RULE2 },
            choicesTooltips = { "Rule 1", "Rule 2" },
        },

        [BAG2] = {
            choices = { RULE1 },
            choicesValues = { RULE1 },
            choicesTooltips = { "Rule 1" },
        },

        [BAG3] = {
            choices = { RULE3 },
            choicesValues = { RULE3 },
            choicesTooltips = { "Rule 3" },
        },
    }

    AC.cache.entriesByShowBag = {
        [BAG1] = {
            choices = { RULE1, RULE2 },
            bagrules = { RULE1, RULE2 },
        },

        [BAG2] = {
            choices = { RULE1 },
            bagrules = { RULE1 },
        },

        [BAG3] = {
            choices = { RULE3 },
            bagrules = { RULE3 },
        },
    }
end


local function getRule(bagId, ruleName)
    local bag = AC.saved.bags[bagId]

    if not bag or not bag.rules then
        return nil
    end

    for i = 1, #bag.rules do
        if bag.rules[i].name == ruleName then
            return bag.rules[i]
        end
    end

    return nil
end


local function countRules(bagId)
    return #AC.saved.bags[bagId].rules
end


-- ============================================================================
-- Bag selection
-- ============================================================================

local function testBagSelection()
    TK.printSuite("AutoCategory", "Bag Selection")

    setupBagData()

    AC_UI.BagSet.clear()

    TK.assertNil(AutoCategory.getCurrentBagId(),
        "clear unselects everything")
    TK.assertNil(AC_UI.BagSet_SelectRule_LAM:getValue(),
        "clear clears rule selection")
    TK.assertNil(AC_UI.AddCat_SelectTag_LAM:getValue(),
        "clear clears tag selection")
    TK.assertNil(AC_UI.AddCat_SelectRule_LAM:getValue(),
        "clear clears add-rule selection")


    AC_UI.BagSet.refresh()
    TK.assertEquals(BAG1, AutoCategory.getCurrentBagId(),
        "refresh retains current bag")
    TK.assertEquals(2, AC_UI.BagSet_SelectRule_LAM:size(),
        "refresh populates backpack rules")

    AC_UI.BagSet.refresh()
    AC_UI.BagSet.refresh()

    TK.assertEquals(BAG1, AutoCategory.getCurrentBagId(),
        "repeated refresh is stable")
end


-- ============================================================================
-- Rule selection
-- ============================================================================

local function testRuleSelection()
    TK.printSuite("AutoCategory", "Rule Selection")

    setupBagData()

    AC_UI.BagSet.refresh()
    AC_UI.BagSet.SelectRule(RULE2)

    TK.assertEquals(RULE2, AC_UI.BagSet_SelectRule_LAM:getValue(),
        "SelectRule selects requested rule")


    local rule = getRule(BAG1, RULE1)

    rule.showpriority = nil

    AC_UI.BagSet.SelectRule(RULE1)

    TK.assertEquals(rule.runpriority, rule.showpriority,
        "SelectRule initializes missing showpriority")
end


-- ============================================================================
-- Category visibility
-- ============================================================================

local function testCategoryVisibility()
    TK.printSuite("AutoCategory", "Category Visibility")

    setupBagData()

    local rule = getRule(BAG1, RULE1)

    rule.isHidden = nil

    AC_UI.BagSet.refresh()
    AC_UI.BagSet.SelectRule(RULE1)

    AC_UI.BagSet.HideCategory(RULE1)

    TK.assertTrue(rule.isHidden,
        "HideCategory sets isHidden")


    AC_UI.BagSet.ShowCategory(RULE1)

    TK.assertFalse(rule.isHidden,
        "ShowCategory clears isHidden")


    rule.isHidden = true

    TK.assertTrue(AC_UI.BagSet_GetHideCatStatus(RULE1),
        "GetHideCatStatus reports hidden category")


    AC_UI.BagSet.ShowCategory(RULE1)

    TK.assertFalse(AC_UI.BagSet_GetHideCatStatus(RULE1),
        "GetHideCatStatus reports visible category")
end


-- ============================================================================
-- Priorities
-- ============================================================================

local function testPriorities()
    TK.printSuite("AutoCategory", "Priorities")

    setupBagData()

    local rule = getRule(BAG1, RULE1)

    rule.runpriority = 75
    rule.showpriority = 200

    AC_UI.BagSet.refresh()
    AC_UI.BagSet.SelectRule(RULE1)

    AC_UI.BagSet_ResetPriority()

    TK.assertEquals(75, rule.showpriority,
        "ResetPriority copies runpriority into show")


    setupBagData()
    
    local rule1 = getRule(BAG1, RULE1)
    local rule2 = getRule(BAG1, RULE2)

    rule1.runpriority = 11
    rule1.showpriority = 91

    rule2.runpriority = 22
    rule2.showpriority = 92

    AC_UI.BagSet_ResetAllPriority()

    TK.assertEquals(11, rule1.showpriority,
        "ResetAllPriority resets first rule "..rule1.showpriority)

    TK.assertEquals(22, rule2.showpriority,
        "ResetAllPriority resets second rule "..rule2.showpriority)
end


-- ============================================================================
-- Add category
-- ============================================================================

local function testAddCategory()
    TK.printSuite("AutoCategory", "Add Category")

    setupBagData()

    -- Missing arguments
    TK.assertNil(AC_UI.AddCat_SelectRule_LAM.filterRules(nil, "someTag"),
        "filterRules rejects missing bag")
    TK.assertNil(AC_UI.AddCat_SelectRule_LAM.filterRules(BAG1, nil),
        "filterRules rejects missing tag")


    -- Missing tag group
    AC.RulesW = AC.RulesW or {}
    AC.RulesW.tagGroups = {}

    local filtered =
        AC_UI.AddCat_SelectRule_LAM.filterRules(BAG1, "missingTag")
    TK.assertNotNil(filtered,
        "filterRules returns CVT for missing tag")
    TK.assertEquals(0, filtered:size(),
        "filterRules returns empty CVT for missing tag")
end


-- ============================================================================
-- Remove category
-- ============================================================================

local function testRemoveCategory()
    TK.printSuite("AutoCategory", "Remove Category")

    setupBagData()

    AC_UI.BagSet.refresh()
    AC_UI.BagSet.SelectRule(RULE2)

    local before = countRules(BAG1)

    AC_UI.BagSet_RemoveCat_LAM:execute()
    TK.assertEquals(before - 1, countRules(BAG1),
        "RemoveCategory removes saved rule")
    TK.assertNil(getRule(BAG1, RULE2),
        "RemoveCategory removes requested rule")
    TK.assertNil(AC.cache.entriesByName[BAG1][RULE2],
        "RemoveCategory removes rule from entriesByName")
end


-- ============================================================================
-- BagSet control updates
-- ============================================================================

local function testBagSetControls()
    TK.printSuite("AutoCategory", "BagSet Controls")

    setupBagData()

    AC_UI.BagSet.updateControls()
    TK.assertNotNil(AC_UI.AddCat_SelectRule_LAM,
        "updateControls retains add-rule control")


    AC_UI.BagSet.clear()
    AC_UI.BagSet.updateControls()
    TK.assertNil(AutoCategory.getCurrentBagId(),
        "updateControls unselects current bag")
end


-- ============================================================================
-- Run tests
-- ============================================================================
function testBagSet_runAll()
    --testBagSelection()
    testCategoryVisibility()
    --testPriorities()
    --testBagSetControls()
    --testRuleSelection()
    --testAddCategory()
    --testRemoveCategory()
end

if not Suite then
    TK.init()
    
    testBagSet_runAll()
    
    TK.showResult("BagSet Tests")
end
