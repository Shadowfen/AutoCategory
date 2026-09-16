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
require "classes.RuleApi"
require "classes.RuleList"
require "classes.BagRuleApi"
require "classes.BaseUI"
require "AutoCategory"

local AC = AutoCategory
local CVT = AutoCategory.CVT

local ZO_PlayerInventory
local saved, cache


local mn, moduleName, class

local function RuleApi_testInit()
    ZO_PlayerInventory = {}
    moduleName = "RuleApi"
    mn = "RuleApi"
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

local function RuleApi_testReset()
    ZO_PlayerInventory = {}
    moduleName = ""

    saved = {}
    cache = {}
    AC.saved = {}
    AC.cache = {}
    AutoCategory.Environment = nil
end

local TK = TestKit
--========================================================
-- RuleApi tests
--========================================================

local RuleApi = AutoCategory.RuleApiMixin


-- -------------------------------------------------------
-- Helper: create a fresh rule without depending on the
-- global RulesW/name lookup state.
local function newRule(name, ruledef, description, tag)
    local r = AutoCategory.CreateRule(name, tag)
    local mt = getmetatable(r)
    r.rule = ruledef or "true"
    r.description = description or ""
    return r
end


-- -------------------------------------------------------
function test_RuleApi_isValid()
    TK.printSuite(mn, "isValid")

    local rule = newRule("TestRule", "true", "Test description")

    TK.assertTrue(rule:isValid(),
        "valid rule is valid")

    rule.name = nil
    local valid, err = rule:isValid()
    TK.assertFalse(valid, "rule without name is invalid")
    TK.assertEquals("name is required", err,
        "missing name returns correct error")

    rule.name = "TestRule"
    rule.rule = nil
    valid, err = rule:isValid()
    TK.assertFalse(valid, "rule without rule text is invalid")
    TK.assertEquals("rule text is required", err,
        "missing rule text returns correct error")
    TK.assertTrue(rule.error, "missing rule text marks rule error")

    rule.rule = "true"
    rule.description = 123
    valid, err = rule:isValid()
    TK.assertFalse(valid, "non-string description is invalid")
    TK.assertEquals("non-nil description must be a string", err,
        "invalid description returns correct error")

    rule.description = ""
    rule.tag = 123
    valid, err = rule:isValid()
    TK.assertFalse(valid, "non-string tag is invalid")
    TK.assertEquals("non-nil tag must be a string", err,
        "invalid tag returns correct error")

    rule.tag = nil
    TK.assertTrue(rule:isValid(), "nil optional tag is valid")
end

-- -------------------------------------------------------
function test_RuleApi_isPredefined()
    TK.printSuite(mn, "isPredefined")

    rule = newRule("TestRule")

    TK.assertFalse(rule:isPredefined(),
        "rule without pred is not predefined")

    rule.pred = 0
    TK.assertFalse(rule:isPredefined(),
        "pred zero is not predefined")

    rule.pred = 1
    TK.assertTrue(rule:isPredefined(),
        "pred one is predefined")

    rule.pred = 2
    TK.assertFalse(rule:isPredefined(),
        "pred other than one is not predefined")
end

-- -------------------------------------------------------
function test_RuleApi_GetDesc()
    TK.printSuite(mn, "getDesc")

    rule = newRule("TestRule", "true", "Test description")

    TK.assertEquals("Test description", rule:getDesc(),
        "getDesc returns description")

    rule.description = ""
    TK.assertEquals("TestRule", rule:getDesc(),
        "getDesc falls back to name for empty description")

    rule.description = nil
    TK.assertEquals("TestRule", rule:getDesc(),
        "getDesc falls back to name for nil description")
end

-- -------------------------------------------------------
function test_RuleApi_Errors()
    TK.printSuite(mn, "setError / clearError")

    rule = newRule("TestRule")

    TK.assertNil(rule.damaged, "new rule is not damaged")
    TK.assertNil(rule.err, "new rule has no error")

    rule:setError(true, "test error")

    TK.assertTrue(rule.damaged,
        "setError sets damaged flag")

    TK.assertEquals("test error", rule.err,
        "setError stores error message")

    rule:clearError()

    TK.assertNil(rule.damaged,
        "clearError clears damaged flag")

    TK.assertNil(rule.err,
        "clearError clears error message")

    rule:setError(false, "warning")

    TK.assertFalse(rule.damaged,
        "setError accepts false damaged state")

    TK.assertEquals("warning", rule.err,
        "setError stores error when damaged is false")

    rule:clearError()
end

-- -------------------------------------------------------
function test_RuleApi_Key()
    TK.printSuite(mn, "key")

    rule = newRule("TestRule")

    TK.assertEquals("TestRule", rule:key(),
        "key defaults to rule name")

    rule.rkey = "CustomKey"

    TK.assertEquals("CustomKey", rule:key(),
        "key returns assigned rkey")

    rule.rkey = ""

    TK.assertEquals("", rule:key(),
        "key returns empty rkey when explicitly assigned")

    rule.rkey = nil

    TK.assertEquals("TestRule", rule:key(),
        "key returns name after rkey is cleared")
end

-- -------------------------------------------------------
function test_RuleApi_isEquiv()
    TK.printSuite(mn, "isequiv")

    local ruleA = newRule("RuleA", "itemType == 1")
    local ruleB = newRule("RuleA", "itemType == 1")
    local ruleC = newRule("RuleB", "itemType == 1")
    local ruleD = newRule("RuleA", "itemType == 2")

    local notName, notRule = ruleA:isequiv(ruleB)

    TK.assertFalse(notName, "equivalent rules have same name")
    TK.assertFalse(notRule, "equivalent rules have same rule definition")

    notName, notRule = ruleA:isequiv(ruleC)
    TK.assertTrue(notName, "different rule names are detected")
    TK.assertFalse(notRule, "same rule definition is detected")

    notName, notRule = ruleA:isequiv(ruleD)
    TK.assertFalse(notName, "same rule name is detected")
    TK.assertTrue(notRule, "different rule definitions are detected")

    notName, notRule = ruleA:isequiv(nil)
    TK.assertFalse(notName, "isequiv nil returns false for name difference")
    TK.assertFalse(notRule, "isequiv nil returns false for rule difference")
end

-- -------------------------------------------------------
function test_RuleApi_compile()
    TK.printSuite(mn, "isCompiled / compile")

    -- Make sure the test key starts clean.
    AutoCategory.compiledRules = AutoCategory.compiledRules or {}

    rule = newRule("CompileTestRule",
        "true")

    AutoCategory.compiledRules[rule:key()] = nil

    TK.assertNil(rule:isCompiled(),
        "new rule is not compiled")

    local compileResult = rule:compile()

    TK.assertEquals("", compileResult,
        "valid rule compiles successfully")

    TK.assertNotNil(rule:isCompiled(),
        "compiled rule is returned by isCompiled")

    TK.assertEquals("function", type(rule:isCompiled()),
        "isCompiled returns compiled function")

    TK.assertNil(rule.damaged,
        "successful compile clears damaged state")

    TK.assertNil(rule.err,
        "successful compile clears error state")
end

-- -------------------------------------------------------
function test_RuleApi_compileInvalid()
    TK.printSuite(mn, "compile invalid rule")

    rule = newRule("BadCompileRule",
        "this is not valid Lua !!!")

    AutoCategory.compiledRules[rule:key()] = nil

    compileResult = rule:compile()

    TK.assertNotEquals("", compileResult,
        "invalid rule returns compile error")

    TK.assertTrue(rule.damaged,
        "invalid compile marks rule damaged")

    TK.assertNotNil(rule.err,
        "invalid compile stores error")

    TK.assertNil(AutoCategory.compiledRules[rule:key()],
        "invalid rule is not stored as compiled")

    TK.assertNil(rule:isCompiled(),
        "invalid rule is not compiled")
end

-- -------------------------------------------------------
function test_RuleApi_missingRule()
    TK.printSuite(mn, "compile missing rule")

    rule = newRule("MissingDefinitionRule",
        "")

    AutoCategory.compiledRules[rule:key()] = nil

    compileResult = rule:compile()

    TK.assertEquals("Missing rule definition", compileResult,
        "missing rule definition returns expected error")

    TK.assertTrue(rule.damaged,
        "missing rule definition marks rule damaged")

    TK.assertEquals("Missing rule definition", rule.err,
        "missing rule definition stores error")

    TK.assertNil(rule:isCompiled(),
        "missing rule definition is not compiled")
end

-- -------------------------------------------------------
function test_RuleApi_missingName()
    TK.printSuite(mn, "compile missing name")

    rule = newRule(nil,
        "true")

    compileResult = rule:compile()

    TK.assertEquals("Rule missing name", compileResult,
        "missing name returns expected compile error")
end

-- -------------------------------------------------------
function test_RuleApi_compileClears()
    TK.printSuite(mn, "compile clears previous error")

    rule = newRule("RecoverableRule", "true")

    rule:setError(true, "old error")

    compileResult = rule:compile()

    TK.assertEquals("", compileResult,
        "previously damaged rule can compile successfully")

    TK.assertNil(rule.damaged,
        "successful compile clears previous damaged state")

    TK.assertNil(rule.err,
        "successful compile clears previous error")

    TK.assertNotNil(rule:isCompiled(),
        "successfully recovered rule is compiled")
end

-- -------------------------------------------------------
function test_RuleApi_compileReplaces()
    TK.printSuite(mn, "compile replaces previous compiled rule")

    rule = newRule("ReplaceCompileRule",
        "true")

    rule:compile()

    local firstCompiled = rule:isCompiled()

    TK.assertNotNil(firstCompiled,
        "first compilation creates compiled function")

    rule.rule = "false"

    compileResult = rule:compile()

    local secondCompiled = rule:isCompiled()

    TK.assertEquals("", compileResult,
        "rule recompiles successfully")

    TK.assertNotNil(secondCompiled,
        "second compilation creates compiled function")

    TK.assertNotEquals(firstCompiled, secondCompiled,
        "recompile replaces previous compiled function")
end

-- -------------------------------------------------------
function test_RuleApi_compiledExec()
    TK.printSuite(mn, "compiled rule execution")

    rule = newRule("ExecutionTrueRule", "true")

    rule:compile()

    local compiled = rule:isCompiled()

    local ok, result = SF.safeCall(compiled)

    TK.assertTrue(ok,
        "compiled true rule executes successfully")

    TK.assertTrue(result,
        "compiled true rule returns true")

    rule = newRule("ExecutionFalseRule",
        "false")

    rule:compile()

    compiled = rule:isCompiled()

    ok, result = SF.safeCall(compiled)

    TK.assertTrue(ok,
        "compiled false rule executes successfully")

    TK.assertFalse(result,
        "compiled false rule returns false")
end

function test_RuleApi_runAll()
    RuleApi_testInit()
    test_RuleApi_isValid()
    test_RuleApi_isPredefined()
    test_RuleApi_GetDesc()
    test_RuleApi_Errors()
    test_RuleApi_Key()
    test_RuleApi_isEquiv()
    test_RuleApi_compile()
    test_RuleApi_compileInvalid()
    test_RuleApi_missingRule()
    test_RuleApi_missingName()
    test_RuleApi_compileClears()
    test_RuleApi_compileReplaces()
    test_RuleApi_compiledExec()
    RuleApi_testReset()
end

if not Suite then
    TK.init()
    
    test_RuleApi_runAll()
    
    TK.showResult("RuleAPI Tests")
end
