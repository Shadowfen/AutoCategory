package.path = package.path .. ";C:/Users/scott/Documents/SFAddons/TK/?.lua;C:/Users/scott/Documents/Elder Scrolls Online/live/AddOns/LibSFUtils/?.lua"

require "zos"
require "tk"

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
require "lang.strings"
require "AutoCategory_Defaults"
require "Plugin_API"
require "Hooks_Keyboard"
require "classes.CVT"
require "classes.RuleList"
require "classes.RuleApi"
require "classes.BagRuleApi"
require "classes.BaseUI"
require "AutoCategory"
require "AddonMenu"

local AC = AutoCategory
local AutoCat = AutoCategory
local CVT = AutoCategory.CVT

local ZO_PlayerInventory
local saved, cache


local mn, moduleName, class

local function RulesW_testInit()
    ZO_PlayerInventory = {}
    moduleName = "RulesW"
    mn = "RulesW"
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

local function RulesW_testReset()
    ZO_PlayerInventory = {}
    moduleName = ""

    saved = {}
    cache = {}
    AC.saved = {}
    AC.cache = {}
    AutoCategory.Environment = nil
end

local TK = TestKit


--[[ ---------------------------------------------------------------------------
    AutoCat.RulesW unit tests
-----------------------------------------------------------------------------]]

local function resetRulesW()
    AutoCat.RulesW.tags = {}
    AutoCat.RulesW.tagGroups = {}
    AutoCat.RulesW.ruleList = {}
    AutoCat.RulesW.ruleNames = {}
end

local function makeRule(name, tag, desc)
    local rule = {
        name = name,
        tag = tag,
        description = desc or ("Description for " .. (name or "badname")),
    }

    -- Keep compile observable without depending on the real compiler.
    rule.compileCount = 0
    function rule:compile()
        self.compileCount = self.compileCount + 1
    end

    function rule:getDesc()
        return self.description
    end

    return rule
end


--[[ ------------------------- AddTag -------------------------------------- ]]

local function testAddTagCreatesTag()
    TK.printSuite(mn,"AddTagCreatesTag")
    resetRulesW()

    AutoCat.RulesW.AddTag("Junk")

    TK.assertEquals(1, #AutoCat.RulesW.tags,
        "AddTag creates one tag")

    TK.assertEquals("Junk", AutoCat.RulesW.tags[1],
        "AddTag stores tag name")

    TK.assertTrue(AutoCat.RulesW.tagGroups["Junk"] ~= nil,
        "AddTag creates tag CVT")
end


local function testAddTagIsIdempotent()
    TK.printSuite(mn,"AddTagIsIdempotent")
    resetRulesW()

    AutoCat.RulesW.AddTag("Junk")
    local cvt = AutoCat.RulesW.tagGroups["Junk"]

    AutoCat.RulesW.AddTag("Junk")

    TK.assertEquals(1, #AutoCat.RulesW.tags,
        "Adding same tag twice does not duplicate tag")

    TK.assertTrue(AutoCat.RulesW.tagGroups["Junk"] == cvt,
        "Adding same tag twice preserves existing CVT")
end


local function testAddTagNormalizesNil()
    TK.printSuite(mn,"AddTagNormalizesNil")
    resetRulesW()
    local AC_EMPTY_TAG_NAME = "<Empty>"

    AutoCat.RulesW.AddTag(nil)

    TK.assertEquals(1, #AutoCat.RulesW.tags,
        "nil tag creates empty tag")

    TK.assertEquals(AC_EMPTY_TAG_NAME, AutoCat.RulesW.tags[1],
        "nil tag uses empty tag name")

    TK.assertTrue(
        AutoCat.RulesW.tagGroups[AC_EMPTY_TAG_NAME] ~= nil,
        "nil tag creates empty-tag CVT"
    )
end


local function testAddTagNormalizesEmptyString()
    TK.printSuite(mn,"AddTagNormalizesEmptyString")
   resetRulesW()

    local AC_EMPTY_TAG_NAME = "<Empty>"
    AutoCat.RulesW.AddTag("")

    TK.assertEquals(1, #AutoCat.RulesW.tags,
        "empty tag creates one tag")

    TK.assertEquals(AC_EMPTY_TAG_NAME, AutoCat.RulesW.tags[1],
        "empty tag uses empty tag name")

    TK.assertTrue(
        AutoCat.RulesW.tagGroups[AC_EMPTY_TAG_NAME] ~= nil,
        "empty tag creates empty-tag CVT"
    )
end


local function testAddTagInitializesTables()
    TK.printSuite(mn,"AddTagInitializesTables")
    AutoCat.RulesW.tags = nil
    AutoCat.RulesW.tagGroups = nil

    AutoCat.RulesW.AddTag("Junk")

    TK.assertTrue(AutoCat.RulesW.tags ~= nil,
        "AddTag initializes tags table")

    TK.assertTrue(AutoCat.RulesW.tagGroups ~= nil,
        "AddTag initializes tagGroups table")

    TK.assertTrue(AutoCat.RulesW.tagGroups["Junk"] ~= nil,
        "AddTag creates CVT after lazy initialization")
end


--[[ ------------------------- AddRule ------------------------------------- ]]

local function testAddRule()
    TK.printSuite(mn,"AddRule")
    resetRulesW()

    local rule = makeRule("Rule One", "Junk")

    AutoCat.RulesW:AddRule(rule)

    TK.assertEquals(1, #AutoCat.RulesW.ruleList,
        "AddRule adds rule to ruleList")

    TK.assertTrue(
        AutoCat.RulesW.ruleList[1] == rule,
        "AddRule stores original rule")

    TK.assertEquals(1, AutoCat.RulesW.ruleNames["Rule One"],
        "AddRule stores rule index")

    TK.assertTrue(
        AutoCat.RulesW.tagGroups["Junk"] ~= nil,
        "AddRule creates missing tag")

    TK.assertEquals(1, rule.compileCount,
        "AddRule compiles new rule")
end


local function testAddRuleMissingName()
    TK.printSuite(mn,"AddRuleMissingName")
    resetRulesW()

    local rule = makeRule(nil, "Junk")

    AutoCat.RulesW:AddRule(rule)

    TK.assertEquals(0, #AutoCat.RulesW.ruleList,
        "Rule without name is ignored")
end


local function testAddRuleNil()
    TK.printSuite(mn,"AddRuleNil")
    resetRulesW()

    AutoCat.RulesW:AddRule(nil)

    TK.assertEquals(0, #AutoCat.RulesW.ruleList,
        "nil rule is ignored")
end


local function testAddRuleNormalizesTag()
    TK.printSuite(mn,"AddRuleNormalizesTag")
    resetRulesW()

    local rule = makeRule("No Tag", "")

    AutoCat.RulesW:AddRule(rule)

    local AC_EMPTY_TAG_NAME = "<Empty>"
    TK.assertEquals(AC_EMPTY_TAG_NAME, rule.tag,
        "empty rule tag is normalized")

    TK.assertTrue(
        AutoCat.RulesW.tagGroups[AC_EMPTY_TAG_NAME] ~= nil,
        "empty rule tag creates empty-tag CVT"
    )
end


local function testAddRuleDuplicateWithoutOverwrite()
    TK.printSuite(mn,"AddRuleDuplicateWithoutOverwrite")
    resetRulesW()

    local rule1 = makeRule("Rule One", "Junk")
    local rule2 = makeRule("Rule One", "Other")

    AutoCat.RulesW:AddRule(rule1)
    AutoCat.RulesW:AddRule(rule2, false)

    TK.assertEquals(1, #AutoCat.RulesW.ruleList,
        "duplicate rule is not added")

    TK.assertTrue(
        AutoCat.RulesW.ruleList[1] == rule1,
        "original rule is retained")

    TK.assertEquals(0, rule2.compileCount,
        "ignored duplicate is not compiled")
end


local function testAddRuleDuplicateWithOverwrite()
    TK.printSuite(mn,"AddRuleDuplicateWithOverwrite")
    resetRulesW()

    local rule1 = makeRule("Rule One", "Junk")
    local rule2 = makeRule("Rule One", "Junk")

    AutoCat.RulesW:AddRule(rule1)
    AutoCat.RulesW:AddRule(rule2, true)

    TK.assertEquals(1, #AutoCat.RulesW.ruleList,
        "overwrite does not increase rule count")

    TK.assertTrue(
        AutoCat.RulesW.ruleList[1] == rule2,
        "overwrite replaces original rule")

    TK.assertEquals(1, AutoCat.RulesW.ruleNames["Rule One"],
        "overwrite preserves rule index")

    TK.assertEquals(1, rule2.compileCount,
        "overwritten rule is compiled")
end


local function testAddRuleOverwriteChangesTag()
    TK.printSuite(mn,"AddRuleOverwriteChangesTag")
    resetRulesW()

    local rule1 = makeRule("Rule One", "Junk")
    local rule2 = makeRule("Rule One", "Materials")

    AutoCat.RulesW:AddRule(rule1)
    AutoCat.RulesW:AddRule(rule2, true)

    local oldCvt = AutoCat.RulesW.tagGroups["Junk"]
    local newCvt = AutoCat.RulesW.tagGroups["Materials"]

    TK.assertTrue(oldCvt ~= nil,
        "old tag CVT exists")

    TK.assertTrue(newCvt ~= nil,
        "new tag CVT exists")

    TK.assertEquals(1, #AutoCat.RulesW.ruleList,
        "tag-changing overwrite keeps one rule")

    TK.assertTrue(
        AutoCat.RulesW.ruleList[1] == rule2,
        "tag-changing overwrite stores new rule")
end


local function testAddRuleOverwriteSameTag()
    TK.printSuite(mn,"AddRuleOverwriteSameTag")
    resetRulesW()

    local rule1 = makeRule("Rule One", "Junk", "old description")
    local rule2 = makeRule("Rule One", "Junk", "new description")

    AutoCat.RulesW:AddRule(rule1)
    local cvt = AutoCat.RulesW.tagGroups["Junk"]

    AutoCat.RulesW:AddRule(rule2, true)

    TK.assertTrue(
        AutoCat.RulesW.tagGroups["Junk"] == cvt,
        "same-tag overwrite preserves CVT")
end


local function testAddRuleCreatesMissingTag()
    TK.printSuite(mn,"AddRuleCreatesMissingTag")
    resetRulesW()

    local rule = makeRule("Rule One", "NewTag")

    TK.assertTrue(
        AutoCat.RulesW.tagGroups["NewTag"] == nil,
        "tag does not initially exist"
    )

    AutoCat.RulesW:AddRule(rule)

    TK.assertTrue(
        AutoCat.RulesW.tagGroups["NewTag"] ~= nil,
        "AddRule creates missing tag"
    )

    TK.assertEquals("NewTag", AutoCat.RulesW.tags[1],
        "created tag is added to tag list")
end


local function testAddRuleDuplicateDoesNotCreateTag()
    TK.printSuite(mn,"AddRuleDuplicateDoesNotCreateTag")
    resetRulesW()

    local rule1 = makeRule("Rule One", "Junk")
    local rule2 = makeRule("Rule One", "NewTag")

    AutoCat.RulesW:AddRule(rule1)

    local tagCount = #AutoCat.RulesW.tags

    AutoCat.RulesW:AddRule(rule2, false)

    TK.assertEquals(tagCount, #AutoCat.RulesW.tags,
        "ignored duplicate does not create new tag")

    TK.assertTrue(
        AutoCat.RulesW.tagGroups["NewTag"] == nil,
        "ignored duplicate does not create new tag CVT"
    )
end


--[[ ------------------------- Test runner -------------------------------- ]]

local function runRulesWTests()
    RulesW_testInit()
    testAddTagCreatesTag()
    testAddTagIsIdempotent()
    testAddTagNormalizesNil()
    testAddTagNormalizesEmptyString()
    testAddTagInitializesTables()

    testAddRule()
    testAddRuleMissingName()
    testAddRuleNil()
    testAddRuleNormalizesTag()
    testAddRuleDuplicateWithoutOverwrite()
    testAddRuleDuplicateWithOverwrite()
    testAddRuleOverwriteChangesTag()
    testAddRuleOverwriteSameTag()
    testAddRuleCreatesMissingTag()
    testAddRuleDuplicateDoesNotCreateTag()
    RulesW_testReset()
end

TK.init()
runRulesWTests()
TK.showResult(mn)