package.path = package.path .. ";C:/Users/scott/Documents/SFAddons/TK/?.lua;C:/Users/scott/Documents/Elder Scrolls Online/live/AddOns/LibSFUtils/?.lua"

require "zos"
require "tk"

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
local saved, cache


local mn, moduleName, class

local function RuleList_testInit()
    ZO_PlayerInventory = {}
    moduleName = "RuleList"
    mn = "RuleList"
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

local function RuleList_testReset()
    ZO_PlayerInventory = {}
    moduleName = ""

    saved = {}
    cache = {}
    AC.saved = {}
    AC.cache = {}
    AutoCategory.Environment = nil
end

local TK = TestKit

-- -------------------------------------------------------
-- RuleList tests

local function makeRule(name, rule)
    local r = AutoCategory.CreateRule(name, "test")
    r.rule = rule or "true"
    return r
end

local function makeList(...)
    local rules = {...}
    return AutoCategory.RuleList:New(rules)
end

local function TestRuleList_Init()
    TK.printSuite("AutoCategory", "RuleList Init")

    -- ---------------------------------------------------
    -- New / Initialize

    do
        local r1 = makeRule("Rule1")
        local r2 = makeRule("Rule2")
        local list = makeList(r1, r2)

        TK.assertNotNil(list,
            "RuleList.New returns an object")

        TK.assertEquals(2, list:size(),
            "RuleList contains initial rules")

        TK.assertEquals(r1, list:getRuleByName("Rule1"),
            "initial rule Rule1 is found by name")

        TK.assertEquals(r2, list:getRuleByName("Rule2"),
            "initial rule Rule2 is found by name")
    end
end

local function TestRuleList_size()
    TK.printSuite("AutoCategory", "RuleList size")

    -- ---------------------------------------------------
    -- size

    do
        local list = makeList(
            makeRule("Rule1"),
            makeRule("Rule2"),
            makeRule("Rule3")
        )

        TK.assertEquals(3, list:size(),
            "size returns number of rules")

        list:removeRule(2)

        TK.assertEquals(2, list:size(),
            "size decreases after removeRule")
    end
end

local function TestRuleList_getRuleByName()
    TK.printSuite("AutoCategory", "RuleList getRuleByName")

    -- ---------------------------------------------------
    -- getRuleByName

    do
        local r1 = makeRule("Alpha")
        local r2 = makeRule("Beta")
        local list = makeList(r1, r2)

        TK.assertEquals(r1, list:getRuleByName("Alpha"),
            "getRuleByName finds first rule")

        TK.assertEquals(r2, list:getRuleByName("Beta"),
            "getRuleByName finds second rule")

        TK.assertNil(list:getRuleByName("Missing"),
            "getRuleByName returns nil for missing rule")

        TK.assertNil(list:getRuleByName(nil),
            "getRuleByName returns nil for nil name")

        TK.assertNil(list:getRuleByName(""),
            "getRuleByName returns nil for empty name")
    end
end

local function TestRuleList_getLookup()
    TK.printSuite("AutoCategory", "RuleList getLookup")

    -- ---------------------------------------------------
    -- getLookup

    do
        local r1 = makeRule("Alpha")
        local r2 = makeRule("Beta")
        local list = makeList(r1, r2)

        local lookup = list:getLookup()

        TK.assertNotNil(lookup,
            "getLookup returns lookup table")

        TK.assertEquals(1, lookup.Alpha,
            "lookup contains Alpha index")

        TK.assertEquals(2, lookup.Beta,
            "lookup contains Beta index")
    end
end

local function TestRuleList_AddRule()
    TK.printSuite("AutoCategory", "RuleList AddRule")

    -- ---------------------------------------------------
    -- AddRule

    do
        local r1 = makeRule("Rule1")
        local r2 = makeRule("Rule2")
        local list = makeList(r1)

        list:AddRule(r2)

        TK.assertEquals(2, list:size(),
            "AddRule adds new rule")

        TK.assertEquals(r2, list:getRuleByName("Rule2"),
            "added rule is available by name")

        TK.assertEquals(2, list:getLookup().Rule2,
            "lookup contains index of added rule")
    end

    -- ---------------------------------------------------
    -- AddRule invalid input

    do
        local list = makeList(makeRule("Rule1"))

        list:AddRule(nil)

        TK.assertEquals(1, list:size(),
            "AddRule ignores nil rule")

        list:AddRule({})

        TK.assertEquals(1, list:size(),
            "AddRule ignores rule without name")
    end

    -- ---------------------------------------------------
    -- AddRule duplicate without overwrite

    do
        local original = makeRule("Same")
        local replacement = makeRule("Same")

        original.rule = "original"
        replacement.rule = "replacement"

        local list = makeList(original)

        list:AddRule(replacement)

        TK.assertEquals(1, list:size(),
            "duplicate AddRule does not increase size")

        TK.assertEquals(original, list:getRuleByName("Same"),
            "duplicate AddRule preserves original without overwrite")
    end

    -- ---------------------------------------------------
    -- AddRule duplicate with overwrite

    do
        local original = makeRule("Same")
        local replacement = makeRule("Same")

        original.rule = "original"
        replacement.rule = "replacement"

        local list = makeList(original)

        list:AddRule(replacement, true)

        TK.assertEquals(1, list:size(),
            "overwrite does not increase list size")

        TK.assertEquals(replacement, list:getRuleByName("Same"),
            "overwrite replaces existing rule")

        TK.assertEquals("replacement",
            list:getRuleByName("Same").rule,
            "overwrite stores replacement rule")
    end
end

local function TestRuleList_removeByIndex()
    TK.printSuite("AutoCategory", "RuleList removeRule by index")

    -- ---------------------------------------------------
    -- removeRule by index

    do
        local r1 = makeRule("Rule1")
        local r2 = makeRule("Rule2")
        local r3 = makeRule("Rule3")

        local list = makeList(r1, r2, r3)

        list:removeRule(2)

        TK.assertEquals(2, list:size(),
            "removeRule decreases size")

        TK.assertEquals(r1, list:getRuleByName("Rule1"),
            "removeRule preserves preceding rule")

        TK.assertEquals(r3, list:getRuleByName("Rule3"),
            "removeRule preserves following rule")

        TK.assertNil(list:getRuleByName("Rule2"),
            "removeRule removes rule from lookup")

        TK.assertEquals(2, list:getLookup().Rule3,
            "removeRule rebuilds shifted lookup index")
    end

    -- ---------------------------------------------------
    -- removeRule invalid indexes

    do
        local list = makeList(
            makeRule("Rule1"),
            makeRule("Rule2")
        )

        list:removeRule(nil)
        TK.assertEquals(2, list:size(),
            "removeRule ignores nil index")

        list:removeRule(0)
        TK.assertEquals(2, list:size(),
            "removeRule ignores zero index")

        list:removeRule(99)
        TK.assertEquals(2, list:size(),
            "removeRule ignores out-of-range index")
    end
end

local function TestRuleList_removeRule_Name()
    TK.printSuite("AutoCategory", "RuleList removeRule by name")

    -- ---------------------------------------------------
    -- removeRuleByName

    do
        local r1 = makeRule("Rule1")
        local r2 = makeRule("Rule2")
        local r3 = makeRule("Rule3")

        local list = makeList(r1, r2, r3)

        list:removeRuleByName("Rule2")

        TK.assertEquals(2, list:size(),
            "removeRuleByName decreases size")

        TK.assertNil(list:getRuleByName("Rule2"),
            "removeRuleByName removes named rule")

        TK.assertEquals(r3, list:getRuleByName("Rule3"),
            "removeRuleByName preserves following rule")

        TK.assertEquals(2, list:getLookup().Rule3,
            "removeRuleByName rebuilds lookup")
    end

    -- ---------------------------------------------------
    -- removeRuleByName invalid names

    do
        local list = makeList(
            makeRule("Rule1"),
            makeRule("Rule2")
        )

        list:removeRuleByName(nil)

        TK.assertEquals(2, list:size(),
            "removeRuleByName ignores nil")

        list:removeRuleByName("Missing")

        TK.assertEquals(2, list:size(),
            "removeRuleByName ignores missing name")
    end
end
local function TestRuleList_rebuildLookup()
    TK.printSuite("AutoCategory", "RuleList rebuildLookup")

    -- ---------------------------------------------------
    -- rebuildLookup

    do
        local r1 = makeRule("Rule1")
        local r2 = makeRule("Rule2")
        local list = makeList(r1, r2)

        -- Deliberately damage the lookup.
        local lookup = list:getLookup()
        lookup.Rule1 = nil
        lookup.Rule2 = 99
        lookup.Extra = 100

        list:rebuildLookup()

        TK.assertEquals(1, lookup.Rule1,
            "rebuildLookup restores Rule1")

        TK.assertEquals(2, lookup.Rule2,
            "rebuildLookup restores Rule2")

        TK.assertNil(lookup.Extra,
            "rebuildLookup removes stale lookup entries")
    end
end

local function TestRuleList_clear()
    TK.printSuite("AutoCategory", "RuleList clear")

    -- ---------------------------------------------------
    -- clear

    do
        local list = makeList(
            makeRule("Rule1"),
            makeRule("Rule2")
        )

        list:clear()

        TK.assertEquals(0, list:size(),
            "clear removes all rules")

        TK.assertNil(list:getRuleByName("Rule1"),
            "clear removes Rule1 lookup")

        TK.assertNil(list:getRuleByName("Rule2"),
            "clear removes Rule2 lookup")

        TK.assertEquals(0, TK.listcount(list:getLookup()),
            "clear empties lookup table")
    end
end

local function TestRuleList_sort()
    TK.printSuite("AutoCategory", "RuleList sort")

    -- ---------------------------------------------------
    -- sort

    do
        local r1 = makeRule("Charlie")
        local r2 = makeRule("Alpha")
        local r3 = makeRule("Bravo")

        local list = makeList(r1, r2, r3)

        list:sort(function(a, b)
            return a.name < b.name
        end)

        TK.assertEquals(3, list:size(),
            "sort preserves rule count")

        TK.assertEquals("Alpha", list.ruleList[1].name,
            "sort places Alpha first")

        TK.assertEquals("Bravo", list.ruleList[2].name,
            "sort places Bravo second")

        TK.assertEquals("Charlie", list.ruleList[3].name,
            "sort places Charlie third")

        TK.assertEquals(1, list:getLookup().Alpha,
            "sort rebuilds Alpha lookup")

        TK.assertEquals(2, list:getLookup().Bravo,
            "sort rebuilds Bravo lookup")

        TK.assertEquals(3, list:getLookup().Charlie,
            "sort rebuilds Charlie lookup")
    end

    -- ---------------------------------------------------
    -- sort invalid argument

    do
        local list = makeList(
            makeRule("Rule1"),
            makeRule("Rule2")
        )

        list:sort(nil)

        TK.assertEquals(2, list:size(),
            "sort ignores nil sort function")

        list:sort("not a function")

        TK.assertEquals(2, list:size(),
            "sort ignores non-function sort argument")
    end
end

local function TestRuleList_duplicateName()
    TK.printSuite("AutoCategory", "RuleList duplicate name")

    local first = makeRule("Duplicate")
    local second = makeRule("Duplicate")

    first.rule = "first"
    second.rule = "second"

    local list = makeList(first, second)

    TK.assertEquals(2, list:size(),
        "initial duplicate rules remain in list")

    TK.assertEquals(2, list:getLookup().Duplicate,
        "duplicate lookup points to last duplicate")

    local found = list:getRuleByName("Duplicate")

    TK.assertEquals(second, found,
        "duplicate lookup selects last duplicate")

    TK.assertEquals("second", found.rule,
        "duplicate lookup returns last duplicate definition")

    TK.assertNotEquals(first, found,
        "duplicate lookup does not return first duplicate")
end

local function TestRuleList_MixinAssign()
    TK.printSuite("AutoCategory", "RuleList mixin Assignment")

    -- ---------------------------------------------------
    -- Rule API mixin assignment
    --
    -- Existing rules without compile() should receive
    -- RuleMetatable during initialization.

    do
        local rule = {
            name = "PlainRule",
            description = "",
            rule = "true",
        }

        local list = makeList(rule)

        TK.assertNotNil(rule.compile,
            "Initialize adds Rule API to plain rule")

        TK.assertNotNil(rule.isValid,
            "initialized rule has isValid method")

        TK.assertNotNil(rule.getDesc,
            "initialized rule has getDesc method")

        TK.assertNotNil(rule.key,
            "initialized rule has key method")

        TK.assertEquals(rule, list:getRuleByName("PlainRule"),
            "plain rule is available through RuleList")
    end

    -- ---------------------------------------------------
    -- Existing rules with compile() preserve metatable

    do
        local rule = makeRule("Existing")

        local originalCompile = rule.compile
        local list = makeList(rule)

        TK.assertEquals(originalCompile, rule.compile,
            "existing Rule API compile method is preserved")

        TK.assertEquals(rule, list:getRuleByName("Existing"),
            "existing rule remains in RuleList")
    end
end

function TestRuleList_runAll()
    RuleList_testInit()
    TestRuleList_Init()
    TestRuleList_size()
    TestRuleList_getRuleByName()
    TestRuleList_getLookup()
    TestRuleList_AddRule()
    TestRuleList_removeByIndex()
    TestRuleList_removeRule_Name()
    TestRuleList_rebuildLookup()
    TestRuleList_clear()
    TestRuleList_sort()
    TestRuleList_duplicateName()
    TestRuleList_MixinAssign()
    RuleList_testReset()
end

if not Suite then
    TK.init()
    
    TestRuleList_runAll()
    
    TK.showResult("RuleListTests")
end
