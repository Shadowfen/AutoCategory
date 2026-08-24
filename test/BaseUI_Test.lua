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

--===========================================================
-- BaseUI / BaseDD Tests
--===========================================================

--===========================================================
-- BaseUI
--===========================================================

function TestBaseUI_New()
    TK.printSuite("AutoCategory", "BaseUI New")

    local ui = AutoCategory.BaseUI:New("TestControl")

    TK.assertNotNil(ui,
        "BaseUI creates object")

    TK.assertEquals("TestControl", ui.controlName,
        "BaseUI stores control name")

    TK.assertEquals("TestControl", ui:getControlName(),
        "BaseUI getControlName returns control name")
end


function TestBaseUI_NoControlName()
    TK.printSuite("AutoCategory", "BaseUI no control")

    local ui = AutoCategory.BaseUI:New(nil)

    TK.assertNotNil(ui,
        "BaseUI creates without control name")

    TK.assertNil(ui:getControlName(),
        "BaseUI control name is nil")
end


function TestBaseUI_UpdateValue_NoControl()
    TK.printSuite("AutoCategory", "BaseUI updateValue no control")

    local ui = AutoCategory.BaseUI:New(nil)

    -- getValue is not called because updateValue() returns first.
    ui.getValue = function()
        TK.assertTrue(false, "getValue should not be called without control")
        return 123
    end

    ui:updateValue()

    TK.assertTrue(true,
        "BaseUI updateValue does nothing without control")
end


function TestBaseUI_UpdateValue_NilValue()
    TK.printSuite("AutoCategory", "BaseUI updateValue nil")

    local ui = AutoCategory.BaseUI:New("TestControl")

    ui.getValue = function()
        return nil
    end

    local getControlCalled = false

    local oldGetControlByName = WINDOW_MANAGER.GetControlByName

    WINDOW_MANAGER.GetControlByName = function(self, name)
        getControlCalled = true
        return nil
    end

    ui:updateValue()

    WINDOW_MANAGER.GetControlByName = oldGetControlByName

    TK.assertFalse(getControlCalled,
        "updateValue does not get control when value is nil")
end


function TestBaseUI_UpdateValue_NoControlFound()
    TK.printSuite("AutoCategory", "BaseUI updateValue missing control")

    local ui = AutoCategory.BaseUI:New("MissingControl")

    ui.getValue = function()
        return 123
    end

    local oldGetControlByName = WINDOW_MANAGER.GetControlByName

    WINDOW_MANAGER.GetControlByName = function(self, name)
        return nil
    end

    -- Should simply return without error.
    ui:updateValue()

    WINDOW_MANAGER.GetControlByName = oldGetControlByName

    TK.assertTrue(true,
        "updateValue handles missing control")
end


function TestBaseUI_UpdateValue()
    TK.printSuite("AutoCategory", "BaseUI updateValue")

    local ui = AutoCategory.BaseUI:New("TestControl")

    local updateCalled = false
    local updateFlag
    local updateValue

    ui.getValue = function()
        return 42
    end

    local mockControl = {
        UpdateValue = function(self, flag, value)
            updateCalled = true
            updateFlag = flag
            updateValue = value
        end,
    }

    local oldGetControlByName = WINDOW_MANAGER.GetControlByName

    WINDOW_MANAGER.GetControlByName = function(self, name)
        TK.assertEquals("TestControl", name,
            "BaseUI requests correct control")
        return mockControl
    end

    ui:updateValue()

    WINDOW_MANAGER.GetControlByName = oldGetControlByName

    TK.assertTrue(updateCalled,
        "BaseUI calls UpdateValue")

    TK.assertFalse(updateFlag,
        "BaseUI passes false update flag")

    TK.assertEquals(42, updateValue,
        "BaseUI passes current value")
end


--===========================================================
-- BaseDD construction
--===========================================================

function TestBaseDD_New()
    TK.printSuite("AutoCategory", "BaseDD New")

    local dd = AutoCategory.BaseDD:New("TestDropdown", "initial")

    TK.assertNotNil(dd,
        "BaseDD creates object")

    TK.assertNotNil(dd.cvt,
        "BaseDD creates CVT")

    TK.assertEquals("TestDropdown", dd:getControlName(),
        "BaseDD getControlName")

    TK.assertEquals("initial", dd:getValue(),
        "BaseDD initial value")
end


function TestBaseDD_NoControlName()
    TK.printSuite("AutoCategory", "BaseDD no control")

    local dd = AutoCategory.BaseDD:New(nil)

    TK.assertNotNil(dd,
        "BaseDD creates without control name")

    TK.assertNil(dd:getControlName(),
        "BaseDD control name is nil")
end


--===========================================================
-- BaseDD CVT delegation
--===========================================================

function TestBaseDD_Append()
    TK.printSuite("AutoCategory", "BaseDD append")

    local dd = AutoCategory.BaseDD:New("TestDropdown")

    local result = dd:append("One")

    TK.assertTrue(result,
        "BaseDD append succeeds")

    TK.assertEquals(1, dd:size(),
        "BaseDD size after append")

    TK.assertEquals("One", dd.cvt.choices[1],
        "BaseDD appends choice to CVT")
end


function TestBaseDD_AppendValues()
    TK.printSuite("AutoCategory", "BaseDD append values")

    local dd = AutoCategory.BaseDD:New(
        "TestDropdown",
        nil,
        AutoCategory.CVT.USE_VALUES
    )

    local result = dd:append("One", "one")

    TK.assertTrue(result,
        "BaseDD append with value succeeds")

    TK.assertEquals("One", dd.cvt.choices[1],
        "BaseDD choice stored")

    TK.assertEquals("one", dd.cvt.choicesValues[1],
        "BaseDD value stored")
end


function TestBaseDD_Select()
    TK.printSuite("AutoCategory", "BaseDD select")

    local dd = AutoCategory.BaseDD:New(
        "TestDropdown",
        nil,
        AutoCategory.CVT.USE_VALUES
    )

    dd:append("One", "one")
    dd:append("Two", "two")

    local result = dd:select("two")

    TK.assertEquals("two", result,
        "BaseDD select returns selected value")

    TK.assertEquals("two", dd:getValue(),
        "BaseDD getValue returns selected value")
end


function TestBaseDD_ClearIndex()
    TK.printSuite("AutoCategory", "BaseDD clearIndex")

    local dd = AutoCategory.BaseDD:New("TestDropdown", "initial")

    dd:clearIndex()

    TK.assertNil(dd:getValue(),
        "BaseDD clearIndex clears value")
end


function TestBaseDD_Clear()
    TK.printSuite("AutoCategory", "BaseDD clear")

    local dd = AutoCategory.BaseDD:New("TestDropdown", "initial")

    dd:append("One")

    TK.assertEquals(1, dd:size(),
        "BaseDD contains item before clear")

    dd:clear()

    TK.assertEquals(0, dd:size(),
        "BaseDD clear removes choices")

    TK.assertNil(dd:getValue(),
        "BaseDD clear clears selection")

    TK.assertTrue(dd.cvt.dirty,
        "BaseDD clear marks CVT dirty")
end


function TestBaseDD_Assign()
    TK.printSuite("AutoCategory", "BaseDD assign")

    local source = AutoCategory.BaseDD:New(
        "Source",
        nil,
        AutoCategory.CVT.USE_VALUES
    )

    source:append("One", "one")
    source:append("Two", "two")
    source:select("two")

    local dest = AutoCategory.BaseDD:New(
        "Destination",
        nil,
        AutoCategory.CVT.USE_VALUES
    )

    dest:assign(source.cvt)

    TK.assertEquals(2, dest:size(),
        "BaseDD assign copies size")

    TK.assertEquals("One", dest.cvt.choices[1],
        "BaseDD assign copies first choice")

    TK.assertEquals("Two", dest.cvt.choices[2],
        "BaseDD assign copies second choice")

    TK.assertEquals("one", dest.cvt.choicesValues[1],
        "BaseDD assign copies first value")

    TK.assertEquals("two", dest.cvt.choicesValues[2],
        "BaseDD assign copies second value")

    TK.assertEquals("two", dest:getValue(),
        "BaseDD assign copies selected value")
end


function TestBaseDD_Size()
    TK.printSuite("AutoCategory", "BaseDD size")

    local dd = AutoCategory.BaseDD:New("TestDropdown")

    TK.assertEquals(0, dd:size(),
        "empty BaseDD size")

    dd:append("One")
    dd:append("Two")
    dd:append("Three")

    TK.assertEquals(3, dd:size(),
        "BaseDD size reflects choices")
end


function TestBaseDD_RemoveItemChoice()
    TK.printSuite("AutoCategory", "BaseDD remove choice")

    local dd = AutoCategory.BaseDD:New(
        "TestDropdown",
        nil,
        AutoCategory.CVT.USE_VALUES
    )

    dd:append("One", "one")
    dd:append("Two", "two")
    dd:append("Three", "three")

    local result = dd:removeItemChoice("Two")

    TK.assertEquals(2, dd:size(),
        "BaseDD remove choice updates size")

    TK.assertEquals("One", dd.cvt.choices[1],
        "BaseDD remove preserves first choice")

    TK.assertEquals("Three", dd.cvt.choices[2],
        "BaseDD remove shifts following choice")

    TK.assertEquals("three", dd.cvt.choicesValues[2],
        "BaseDD remove keeps parallel values aligned")

    TK.assertEquals("three", result,
        "BaseDD remove returns new selection")
end


function TestBaseDD_RemoveItemChoiceValue()
    TK.printSuite("AutoCategory", "BaseDD remove choice value")

    local dd = AutoCategory.BaseDD:New(
        "TestDropdown",
        nil,
        AutoCategory.CVT.USE_VALUES
    )

    dd:append("One", "one")
    dd:append("Two", "two")
    dd:append("Three", "three")

    local result = dd:removeItemChoiceValue("two")

    TK.assertEquals(2, dd:size(),
        "BaseDD remove value updates size")

    TK.assertEquals("One", dd.cvt.choices[1],
        "BaseDD remove value preserves first choice")

    TK.assertEquals("Three", dd.cvt.choices[2],
        "BaseDD remove value shifts following choice")

    TK.assertEquals("three", dd.cvt.choicesValues[2],
        "BaseDD remove value keeps values aligned")

    TK.assertEquals("three", result,
        "BaseDD remove value returns new selection")
end


--===========================================================
-- BaseDD updateControl
--===========================================================

function TestBaseDD_UpdateControl_NoControl()
    TK.printSuite("AutoCategory", "BaseDD updateControl no control")

    local dd = AutoCategory.BaseDD:New(nil)

    dd:append("One")

    -- Should simply return.
    dd:updateControl()

    TK.assertTrue(true,
        "BaseDD updateControl handles missing control name")
end


function TestBaseDD_UpdateControl_MissingControl()
    TK.printSuite("AutoCategory", "BaseDD updateControl missing control")

    local dd = AutoCategory.BaseDD:New("MissingDropdown")

    dd:append("One")

    local oldGetControlByName = WINDOW_MANAGER.GetControlByName

    WINDOW_MANAGER.GetControlByName = function(self, name)
        TK.assertEquals("MissingDropdown", name,
            "BaseDD requests correct control")
        return nil
    end

    dd:updateControl()

    WINDOW_MANAGER.GetControlByName = oldGetControlByName

    TK.assertTrue(true,
        "BaseDD updateControl handles missing control")
end


function TestBaseDD_UpdateControl_Choices()
    TK.printSuite("AutoCategory", "BaseDD updateControl choices")

    local dd = AutoCategory.BaseDD:New("TestDropdown")

    dd:append("One")
    dd:append("Two")

    local choicesReceived
    local valuesReceived
    local tooltipsReceived
    local updateChoicesCalled = false

    local mockControl = {
        UpdateChoices = function(self, choices, values, tooltips)
            updateChoicesCalled = true
            choicesReceived = choices
            valuesReceived = values
            tooltipsReceived = tooltips
        end,

        UpdateValue = function()
        end,
    }

    local oldGetControlByName = WINDOW_MANAGER.GetControlByName

    WINDOW_MANAGER.GetControlByName = function(self, name)
        TK.assertEquals("TestDropdown", name,
            "BaseDD requests correct control")
        return mockControl
    end

    dd:updateControl()

    WINDOW_MANAGER.GetControlByName = oldGetControlByName

    TK.assertTrue(updateChoicesCalled,
        "BaseDD calls UpdateChoices")

    TK.assertEquals(dd.cvt.choices, choicesReceived,
        "BaseDD passes choices to control")

    TK.assertNil(valuesReceived,
        "BaseDD passes nil values when unused")

    TK.assertNil(tooltipsReceived,
        "BaseDD passes nil tooltips when unused")

    TK.assertNil(dd.cvt.dirty,
        "BaseDD clears dirty flag after updating choices")
end


function TestBaseDD_UpdateControl_Value()
    TK.printSuite("AutoCategory", "BaseDD updateControl value")

    local dd = AutoCategory.BaseDD:New(
        "TestDropdown",
        nil,
        AutoCategory.CVT.USE_VALUES
    )

    dd:append("One", "one")
    dd:append("Two", "two")
    dd:select("two")

    local updateValueCalled = false
    local receivedFlag
    local receivedValue

    local mockControl = {
        UpdateChoices = function()
        end,

        UpdateValue = function(self, flag, value)
            updateValueCalled = true
            receivedFlag = flag
            receivedValue = value
        end,
    }

    local oldGetControlByName = WINDOW_MANAGER.GetControlByName

    WINDOW_MANAGER.GetControlByName = function(self, name)
        return mockControl
    end

    dd:updateControl()

    WINDOW_MANAGER.GetControlByName = oldGetControlByName

    TK.assertTrue(updateValueCalled,
        "BaseDD calls UpdateValue")

    TK.assertFalse(receivedFlag,
        "BaseDD passes false to UpdateValue")

    TK.assertEquals("two", receivedValue,
        "BaseDD passes current value")
end


function TestBaseDD_UpdateControl_NotDirty()
    TK.printSuite("AutoCategory", "BaseDD updateControl not dirty")

    local dd = AutoCategory.BaseDD:New("TestDropdown")

    dd.cvt.choices = {"One"}
    dd.cvt.dirty = nil

    local updateChoicesCalled = false
    local updateValueCalled = false

    local mockControl = {
        UpdateChoices = function()
            updateChoicesCalled = true
        end,

        UpdateValue = function()
            updateValueCalled = true
        end,
    }

    local oldGetControlByName = WINDOW_MANAGER.GetControlByName

    WINDOW_MANAGER.GetControlByName = function(self, name)
        return mockControl
    end

    dd:updateControl()

    WINDOW_MANAGER.GetControlByName = oldGetControlByName

    TK.assertFalse(updateChoicesCalled,
        "BaseDD does not update choices when not dirty")

    TK.assertFalse(updateValueCalled,
        "BaseDD does not update value when no selection")
end


--===========================================================
-- Runner
--===========================================================

function TestBaseUI_runAll()
    TestBaseUI_New()
    TestBaseUI_NoControlName()
    TestBaseUI_UpdateValue_NoControl()
    TestBaseUI_UpdateValue_NilValue()
    TestBaseUI_UpdateValue_NoControlFound()
    TestBaseUI_UpdateValue()

    TestBaseDD_New()
    TestBaseDD_NoControlName()
    TestBaseDD_Append()
    TestBaseDD_AppendValues()
    TestBaseDD_Select()
    TestBaseDD_ClearIndex()
    TestBaseDD_Clear()
    TestBaseDD_Assign()
    TestBaseDD_Size()
    TestBaseDD_RemoveItemChoice()
    TestBaseDD_RemoveItemChoiceValue()

    TestBaseDD_UpdateControl_NoControl()
    TestBaseDD_UpdateControl_MissingControl()
    TestBaseDD_UpdateControl_Choices()
    TestBaseDD_UpdateControl_Value()
    TestBaseDD_UpdateControl_NotDirty()
end

if not Suite then
    TK.init()
    
    TestBaseUI_runAll()
    
    TK.showResult("BaseUI / BaseDD Tests")
end
