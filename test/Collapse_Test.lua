package.path = package.path .. ";C:/Users/scott/Documents/SFAddons/TK/?.lua;C:/Users/scott/Documents/Elder Scrolls Online/live/AddOns/LibSFUtils/?.lua"

require "zos"
require "tk"
local TK = TestKit

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

local AutoCat = AutoCategory
local CVT = AutoCategory.CVT

local ZO_PlayerInventory
local saved, cache

local moduleName = "Category"
local mn, moduleName, class

local function testIsCategoryInit()
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

    AutoCategory.BagRuleEntry = {}


    saved = AutoCategory.saved
    cache = AutoCategory.cache
end

local function testIsCategoryReset()
    ZO_PlayerInventory = {}
    moduleName = ""

end

-- ============================================================================
-- Collapse tests
-- ============================================================================

local function resetCollapseTestState()
    AutoCat.saved.collapses = {}
end


function testIsCategoryCollapsed()
    TK.printSuite("Collapse", "IsCategoryCollapsed")
    resetCollapseTestState()

    TK.assertFalse(AutoCat.IsCategoryCollapsed(1, "Test"),
        "missing bag returns false")

    AutoCat.saved.collapses[1] = {}

    TK.assertFalse(AutoCat.IsCategoryCollapsed(1, "Test"),
        "missing category returns false")

    AutoCat.saved.collapses[1].Test = true

    TK.assertTrue(AutoCat.IsCategoryCollapsed(1, "Test"),
        "collapsed category returns true")

    AutoCat.saved.collapses[1].Test = false

    TK.assertFalse(AutoCat.IsCategoryCollapsed(1, "Test"),
        "expanded category returns false")
end


function testIsCategoryCollapsed_invalid()
    TK.printSuite("Collapse", "IsCategoryCollapsed_invalid")
    resetCollapseTestState()

    TK.assertFalse(AutoCat.IsCategoryCollapsed(nil, "Test"),
        "nil bagId returns false")
    TK.assertFalse(AutoCat.IsCategoryCollapsed(1, nil),
        "nil category returns false")
    TK.assertFalse(AutoCat.IsCategoryCollapsed(nil, nil),
        "nil bagId and category return false")
end


function testIsCategoryCollapsed_noCreate()
    TK.printSuite("Collapse", "IsCategoryCollapsed_noCreate")
    resetCollapseTestState()

    AutoCat.IsCategoryCollapsed(123, "Missing")

    TK.assertTrue(AutoCat.saved.collapses[123] == nil,
        "read does not create missing bag table")
end


function testSetCategoryCollapsed()
    TK.printSuite("Collapse", "SetCategoryCollapsed")
    resetCollapseTestState()

    AutoCategory.SetCategoryCollapsed(1, "Test", true)

    TK.assertTrue(AutoCategory.saved.collapses[1] ~= nil,
        "creates bag collapse table")
    TK.assertTrue(AutoCategory.saved.collapses[1].Test == true,
        "stores collapsed state")
    TK.assertTrue(AutoCategory.IsCategoryCollapsed(1, "Test"),
        "stored true state is readable")

    AutoCategory.SetCategoryCollapsed(1, "Test", false)

    TK.assertFalse(AutoCategory.IsCategoryCollapsed(1, "Test"),
        "updated false state is readable")
    TK.assertNil(AutoCategory.saved.collapses[1].Test,
        "does not store nil collapsed state")

end


function testSetCategoryCollapsed_multiple()
    TK.printSuite("Collapse", "SetCategoryCollapsed_multiple")
    resetCollapseTestState()

    AutoCat.SetCategoryCollapsed(1, "First", true)
    AutoCat.SetCategoryCollapsed(1, "Second", false)
    AutoCat.SetCategoryCollapsed(2, "First", true)

    TK.assertTrue(AutoCat.IsCategoryCollapsed(1, "First"),
        "bag 1 First is collapsed")
    TK.assertFalse(AutoCat.IsCategoryCollapsed(1, "Second"),
        "bag 1 Second is expanded")
    TK.assertTrue(AutoCat.IsCategoryCollapsed(2, "First"),
        "bag 2 First is collapsed")
end


function testSetCategoryCollapsed_invalid()
    TK.printSuite("Collapse", "SetCategoryCollapsed_invalid")
    resetCollapseTestState()

    AutoCat.SetCategoryCollapsed(nil, "Test", true)

    TK.assertTrue(next(AutoCat.saved.collapses) == nil,
        "nil bagId does not modify collapse state")

    AutoCat.SetCategoryCollapsed(1, nil, true)

    TK.assertTrue(next(AutoCat.saved.collapses) == nil,
        "nil category does not modify collapse state")
end


function testResetCollapse()
    TK.printSuite("Collapse", "ResetCollapse")
    resetCollapseTestState()

    AutoCat.saved.collapses[1] = {
        First = true,
        Second = false,
    }

    AutoCat.saved.collapses[2] = {
        Third = true,
    }

    AutoCat.ResetCollapse(AutoCat.saved)

    TK.assertNil( next(AutoCat.saved.collapses[1]),
        "clears bag 1 collapse state")
    TK.assertNil(next(AutoCat.saved.collapses[2]),
        "clears bag 2 collapse state")
end

function testPruneCollapse()
    TK.printSuite("Collapse", "PruneCollapse")
    resetCollapseTestState()

    AutoCat.saved.collapses[1] = {
        First = true,
        Second = false,
    }

    AutoCat.saved.collapses[2] = {
        Third = true,
    }

    AutoCat.PruneCollapse(AutoCat.saved)

    TK.assertNotNil( AutoCat.saved.collapses[1].First,
        "preserves bag 1 First collapse state")
    TK.assertNil( AutoCat.saved.collapses[1].Second,
        "clears bag 1 Second collapse state")
    TK.assertNotNil(next(AutoCat.saved.collapses[2]),
        "preserves bag 2 collapse state")
end


function testResetCollapse_preservesTables()
    TK.printSuite("Collapse", "SetCategoryCollapsed_preservesTables")
    resetCollapseTestState()

    local bagcol = {
        First = true,
        Second = true,
    }

    AutoCat.saved.collapses[1] = bagcol

    AutoCat.ResetCollapse(AutoCat.saved)

    TK.assertTrue(AutoCat.saved.collapses[1] == bagcol,
        "preserves collapse table reference")
    TK.assertNil(next(bagcol),
        "clears collapse table in place")
end

-- ============================================================================
-- Run tests
-- ============================================================================
function testCollapse_runAll()
    testIsCategoryInit()
    
    testIsCategoryCollapsed()
    testIsCategoryCollapsed_invalid()
    testIsCategoryCollapsed_noCreate()
    testSetCategoryCollapsed()
    testSetCategoryCollapsed_multiple()
    testSetCategoryCollapsed_invalid()
    testResetCollapse()
    testResetCollapse_preservesTables()
    testPruneCollapse()
    
    testIsCategoryReset()
end

if not Suite then
    TK.init()
    
    testCollapse_runAll()
    
    TK.showResult("Collapse Tests")
end
