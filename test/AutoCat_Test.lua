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
local saved, cache    -- aliases of the corresponding AutoCategory. vars

local moduleName = "BagRule"
local mn, class

local function testBagRuleInit()
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

local function testBagRuleReset()
    ZO_PlayerInventory = {}
    moduleName = ""

    saved = {}
    cache = {} --AutoCategory.cache
    AC.saved = {}
end

-- ===========================================================
local function testBagRuleShowSortingFunction()
    TK.printSuite(mn,"BagRule_ShowSortingFunction")

    local sort = AutoCat_Internal.BagRuleShowSortingFunction

    -- showpriority
    TK.assertTrue(sort(
            {name = "Alpha", showpriority = 200},
            {name = "Beta", showpriority = 100}),
        "higher showpriority first")

    TK.assertFalse(sort(
            {name = "Alpha", showpriority = 100},
            {name = "Beta", showpriority = 200}),
        "lower showpriority second")

    -- equal showpriority: name tiebreaker
    TK.assertTrue(sort(
            {name = "Alpha", showpriority = 100},
            {name = "Beta", showpriority = 100}),
        "alphabetical on equal priority")

    TK.assertFalse(sort(
            {name = "Beta", showpriority = 100},
            {name = "Alpha", showpriority = 100}),
        "reverse alphabetical on equal priority")

    TK.assertFalse(sort(
            {name = "Alpha", showpriority = 100},
            {name = "Alpha", showpriority = 100}),
        "equal rules return false")
end

local function testBagRuleRunSorting_fallback()
    TK.printSuite(mn, "BagRule_RunSorting_fallback")

    local sort = AutoCat_Internal.BagRuleShowSortingFunction

    -- runpriority fallback
    TK.assertTrue(sort(
            {name = "Alpha", runpriority = 200},
            {name = "Beta", runpriority = 100}),
        "falls back to runpriority")

    TK.assertFalse(sort(
            {name = "Alpha", runpriority = 100},
            {name = "Beta", runpriority = 200}),
        "lower runpriority sorts second")

    -- showpriority takes precedence over runpriority
    TK.assertTrue(sort(
            {name = "Alpha", showpriority = 200, runpriority = 1},
            {name = "Beta", showpriority = 100, runpriority = 999}),
        "showpriority takes precedence over runpriority")

    -- mixed explicit/fallback
    TK.assertTrue(sort(
            {name = "Alpha", showpriority = 200},
            {name = "Beta", runpriority = 100}),
        "showpriority sorts against runpriority fallback")

    TK.assertFalse(sort(
            {name = "Alpha", runpriority = 100},
            {name = "Beta", showpriority = 200}),
        "runpriority fallback sorts below showpriority")
end

local function testBagRuleRunSorting_missingPriority()
    TK.printSuite(mn, "BagRule_RunSorting_missingPriority")

    local sort = AutoCat_Internal.BagRuleShowSortingFunction

    -- priority vs no priority
    TK.assertTrue(sort(
            {name = "Alpha", showpriority = 100},
            {name = "Beta"}),
        "prioritized rule sorts before unprioritized rule")

    TK.assertFalse(sort(
            {name = "Alpha"},
            {name = "Beta", showpriority = 100}),
        "unprioritized rule sorts after prioritized rule")
end

local function testBagRule_ShowSorting_tiebreaker()
    TK.printSuite(mn,"BagRule_ShowSorting_tiebreaker")

    local sort = AutoCat_Internal.BagRuleShowSortingFunction

    -- neither rule has priority: name tiebreaker
    TK.assertTrue(sort(
            {name = "Alpha"},
            {name = "Beta"}),
        "both unprioritized rules sort alphabetically")

    TK.assertFalse(sort(
            {name = "Beta"},
            {name = "Alpha"}),
        "both unprioritized rules sort reverse alphabetically")

    TK.assertFalse(sort(
            {name = "Alpha"},
            {name = "Alpha"}),
        "both unprioritized identical names return false")
end

local function testBagRule_ShowSorting_invalid()
    TK.printSuite(mn,"BagRule_ShowSorting_invalid")

    local sort = AutoCat_Internal.BagRuleShowSortingFunction

    -- invalid inputs
    TK.assertFalse(sort(nil, {name = "Beta", showpriority = 100}),
        "rejects nil left rule")

    TK.assertFalse(sort( {name = "Alpha", showpriority = 100}, nil),
        "rejects nil right rule")

    TK.assertFalse(sort({}, {name = "Beta", showpriority = 100}),
        "rejects nameless left rule")

    TK.assertFalse(sort({name = "Alpha", showpriority = 100}, {}),
        "rejects nameless right rule")
end

local function testBagRuleRunSortingFunction()
    TK.printSuite(mn, "BagRule_RunSortingFunction")

    local sortFn = AutoCat_Internal.BagRuleRunSortingFunction

    -- Higher runpriority sorts first
    local low = { name = "Low", runpriority = 100 }
    local high = { name = "High", runpriority = 500 }

    TK.assertTrue(sortFn(high, low),
        "Higher runpriority sorts before lower")

    TK.assertFalse(sortFn(low, high),
        "Lower runpriority does not sort before higher")
end

local function testBagRuleRunSorting_identical()
    TK.printSuite(mn, "BagRule_RunSorting_identical")

    local sortFn = AutoCat_Internal.BagRuleRunSortingFunction

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
end

local function testBagRuleRunSorting_missing()
    TK.printSuite(mn, "BagRule_RunSorting_missing")

    local sortFn = AutoCat_Internal.BagRuleRunSortingFunction

    local low = { name = "Low", runpriority = 100 }
    local high = { name = "High", runpriority = 500 }

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

    -- Missing priority: unprioritized rules sort after prioritized rules
    TK.assertFalse(sortFn({ name = "A" }, low),
        "Unprioritized left rule sorts after prioritized rule")

    TK.assertTrue(sortFn(high, { name = "B" }),
        "Prioritized left rule sorts before unprioritized rule")

    -- Both missing priority: alphabetical ordering
    TK.assertTrue(sortFn(
            { name = "Alpha" },
            { name = "Beta" }),
        "Two unprioritized rules sort alphabetically")
end

local function testBagRuleRunSorting_zero()
    TK.printSuite(mn, "BagRule_RunSorting_zero")

    local sortFn = AutoCat_Internal.BagRuleRunSortingFunction

    local low = { name = "Low", runpriority = 100 }
    local high = { name = "High", runpriority = 500 }

    TK.assertFalse(sortFn(
            { name = "Beta" },
            { name = "Alpha" }),
        "Two unprioritized rules sort reverse alphabetically")
      
    -- Zero is valid in Lua and should be sortable
    local zero = { name = "Zero", runpriority = 0 }

    TK.assertTrue(sortFn(low, zero),
        "Positive priority sorts before zero")

    TK.assertFalse(sortFn(zero, low),
        "Zero priority sorts after positive priority")
      
    local none = { name = "None" }

    TK.assertTrue(sortFn(zero, none),
        "Zero priority sorts before missing priority")

    TK.assertFalse(sortFn(none, zero),
        "Missing priority sorts after zero priority")
end

function testAutoCat_runAll()
    testBagRuleInit()
    
    testBagRuleShowSortingFunction()
    testBagRuleRunSorting_fallback()
    testBagRuleRunSorting_missingPriority()
    testBagRule_ShowSorting_tiebreaker()
    testBagRule_ShowSorting_invalid()
    
    testBagRuleRunSortingFunction()
    testBagRuleRunSorting_identical()
    testBagRuleRunSorting_missing()
    testBagRuleRunSorting_zero()
    
    testBagRuleReset()
end

if not Suite then
    TK.init()
    
    testAutoCat_runAll()
    
    TK.showResult("AutoCat Tests")
end