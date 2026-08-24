package.path = package.path .. ";C:/Users/scott/Documents/SFAddons/TK/?.lua;C:/Users/scott/Documents/Elder Scrolls Online/live/AddOns/LibSFUtils/?.lua"

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

local saved = {} --AutoCategory.saved
local cache = {} --AutoCategory.cache

local TK = TestKit

-- ===========================================================
local function testBagRuleShowSortingFunction()

    TK.assertTrue(AutoCat_Internal.BagRuleShowSortingFunction(
            {name = "Alpha", showpriority = 200},
            {name = "Beta", showpriority = 100}),
        "BagRuleShowSortingFunction higher priority first")

    TK.assertFalse(AutoCat_Internal.BagRuleShowSortingFunction(
            {name = "Alpha", showpriority = 100},
            {name = "Beta", showpriority = 200}),
        "BagRuleShowSortingFunction lower priority second")

    TK.assertTrue(AutoCat_Internal.BagRuleShowSortingFunction(
            {name = "Alpha", showpriority = 100},
            {name = "Beta", showpriority = 100}),
        "BagRuleShowSortingFunction alphabetical on equal priority")

    TK.assertFalse(AutoCat_Internal.BagRuleShowSortingFunction(
            {name = "Beta", showpriority = 100},
            {name = "Alpha", showpriority = 100}),
        "BagRuleShowSortingFunction reverse alphabetical on equal priority")

    TK.assertFalse(AutoCat_Internal.BagRuleShowSortingFunction(
            {name = "Alpha", showpriority = 100},
            {name = "Alpha", showpriority = 100}),
        "BagRuleShowSortingFunction equal rules return false")

    -- showpriority fallback
    TK.assertTrue(AutoCat_Internal.BagRuleShowSortingFunction(
            {name = "Alpha", runpriority = 200},
            {name = "Beta", runpriority = 100}),
        "BagRuleShowSortingFunction falls back to runpriority")

    -- mixed explicit/fallback
    TK.assertTrue(AutoCat_Internal.BagRuleShowSortingFunction(
            {name = "Alpha", showpriority = 200},
            {name = "Beta", runpriority = 100}),
        "BagRuleShowSortingFunction mixes showpriority and runpriority")

    -- invalid inputs
    TK.assertFalse(AutoCat_Internal.BagRuleShowSortingFunction(nil, {name = "Beta", showpriority = 100}),
        "BagRuleShowSortingFunction rejects nil left rule")

    TK.assertFalse(AutoCat_Internal.BagRuleShowSortingFunction({name = "Alpha", showpriority = 100}, nil),
        "BagRuleShowSortingFunction rejects nil right rule")

    TK.assertFalse(AutoCat_Internal.BagRuleShowSortingFunction({}, {name = "Beta", showpriority = 100}),
        "BagRuleShowSortingFunction rejects nameless left rule")

    TK.assertFalse(AutoCat_Internal.BagRuleShowSortingFunction(
            {name = "Alpha", showpriority = 100},
            {name = "Beta"}),
        "BagRuleShowSortingFunction rejects missing priority"
    )
end

local function testBagRuleRunSortingFunction()
    TK.printSuite("AutoCategory", "BagRuleRunSortingFunction")

    local sortFn = AutoCat_Internal.BagRuleRunSortingFunction

    -- Higher runpriority sorts first
    local low = { name = "Low", runpriority = 100 }
    local high = { name = "High", runpriority = 500 }

    TK.assertTrue(sortFn(high, low),
        "Higher runpriority sorts before lower")

    TK.assertFalse(sortFn(low, high),
        "Lower runpriority does not sort before higher")

    -- Same priority: alphabetical name determines order
    local alpha = { name = "Alpha", runpriority = 100 }
    local beta = { name = "Beta", runpriority = 100 }

    TK.assertTrue(sortFn(alpha, beta),
        "Same priority sorts alphabetically")

    TK.assertFalse(sortFn(beta, alpha),
        "Same priority reverse alphabetical does not sort first")

    -- Same name/priority
    local same1 = { name = "Same", runpriority = 100 }
    local same2 = { name = "Same", runpriority = 100 }

    TK.assertFalse(sortFn(same1, same2),
        "Identical rules do not sort before each other")

    TK.assertFalse(sortFn(same2, same1),
        "Identical rules reverse comparison is also false")

    -- Missing arguments
    TK.assertFalse(sortFn(nil, low),
        "Nil left rule returns false")

    TK.assertFalse(sortFn(high, nil),
        "Nil right rule returns false")

    TK.assertFalse(sortFn(nil, nil),
        "Both rules nil returns false")

    -- Missing name
    TK.assertFalse(sortFn({ runpriority = 100 }, low),
        "Missing left name returns false")

    TK.assertFalse(sortFn(high, { runpriority = 100 }),
        "Missing right name returns false")

    -- Missing priority
    TK.assertFalse(sortFn({ name = "A" }, low),
        "Missing left runpriority returns false")

    TK.assertFalse(sortFn(high, { name = "B" }),
        "Missing right runpriority returns false")

    -- Zero is valid in Lua and should be sortable
    local zero = { name = "Zero", runpriority = 0 }

    TK.assertTrue(sortFn(low, zero),
        "Positive priority sorts before zero")

    TK.assertFalse(sortFn(zero, low),
        "Zero priority sorts after positive priority")
end

function testAutoCat_runAll()
    testBagRuleShowSortingFunction()
    testBagRuleRunSortingFunction()
end

if not Suite then
    TK.init()
    
    testAutoCat_runAll()
    
    TK.showResult("AutoCat Tests")
end