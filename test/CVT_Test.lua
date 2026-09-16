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

local AC = AutoCategory
local CVT = AutoCategory.CVT

local ZO_PlayerInventory
local saved, cache


local mn, moduleName, class

local function TestCVT_Init()
    ZO_PlayerInventory = {}
    moduleName = "CVT"
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

local function TestCVT_Reset()
    ZO_PlayerInventory = {}
    moduleName = ""

    saved = {}
    cache = {}
    AC.saved = {}
    AC.cache = {}
end


-- =========================================================
-- CVT Test helpers
-- =========================================================

local function fillCVT(cvt, choices, values, tooltips)
    for i = 1, #choices do
        cvt:append(
            choices[i],
            values and values[i] or nil,
            tooltips and tooltips[i] or nil
        )
    end
end


-- =========================================================
-- Initialize / construction
-- =========================================================
local function TestCVT_New()
    TK.printSuite(mn,"CVTNew")
    local cvt = {}
    TK.assertFalse(cvt.choices, "cvt has no choices" )
     
    cvt = AC.CVT:New("myControl", nil, AC.CVT.USE_ALL)
    TK.assertTrue(cvt.choices and SF.GetSize(cvt.choices) == 0, "has empty choices")
    TK.assertTrue(cvt.choicesValues and SF.GetSize(cvt.choicesValues) == 0, "has empty values")
    TK.assertTrue(cvt.choicesTooltips and SF.GetSize(cvt.choicesTooltips) == 0, "has empty tooltips")
    TK.assertTrue(cvt.controlName == "myControl", "control name "..cvt.controlName)
end

local function TestCVT_Initialize()
    TK.printSuite(mn, "CVT Initialize")

    do
        local cvt = AutoCategory.CVT:New()

        TK.assertNotNil(cvt, "CVT creates object")
        TK.assertNotNil(cvt.choices, "choices list created")
        TK.assertEquals(0, #cvt.choices, "initial choices list is empty")
        TK.assertNil(cvt.choicesValues, "choicesValues absent by default")
        TK.assertNil(cvt.choicesTooltips, "choicesTooltips absent by default")
        TK.assertNil(cvt.indexValue, "initial indexValue is nil")
    end

    do
        local cvt = AutoCategory.CVT:New("TestControl", "initial", AutoCategory.CVT.USE_VALUES)

        TK.assertEquals("TestControl", cvt:getControlName(), "control name assigned")
        TK.assertEquals("initial", cvt.indexValue, "initial indexValue assigned")
        TK.assertNotNil(cvt.choicesValues, "choicesValues created when requested")
        TK.assertNil(cvt.choicesTooltips, "choicesTooltips absent when not requested")
    end

    do
        local cvt = AutoCategory.CVT:New("TestControl", "initial", AutoCategory.CVT.USE_TOOLTIPS)

        TK.assertNil(cvt.choicesValues, "choicesValues absent for tooltip-only CVT")
        TK.assertNotNil(cvt.choicesTooltips, "choicesTooltips created for tooltip CVT")
    end

    do
        local cvt = AutoCategory.CVT:New("TestControl", "initial", AutoCategory.CVT.USE_ALL)

        TK.assertNotNil(cvt.choicesValues, "USE_ALL creates choicesValues")
        TK.assertNotNil(cvt.choicesTooltips, "USE_ALL creates choicesTooltips")
    end
end



local function TestCVT_GetUses()
    TK.printSuite(mn, "CVT GetUses")

    do
        local cvt = CVT:New()
        TK.assertEquals(CVT.USE_NONE, cvt:GetUses(),
            "choices only returns USE_NONE")
    end

    do
        local cvt = CVT:New(nil, nil, CVT.USE_VALUES)
        TK.assertEquals(CVT.USE_VALUES, cvt:GetUses(),
            "values returns USE_VALUES")
    end

    do
        local cvt = CVT:New(nil, nil, CVT.USE_TOOLTIPS)
        TK.assertEquals(CVT.USE_TOOLTIPS, cvt:GetUses(),
            "tooltips returns USE_TOOLTIPS")
    end

    do
        local cvt = CVT:New(nil, nil, CVT.USE_ALL)
        TK.assertEquals(CVT.USE_ALL, cvt:GetUses(),
            "values and tooltips returns USE_ALL")
    end
end

-- =========================================================
-- size / control name
-- =========================================================

local function TestCVT_BasicAccessors()
    TK.printSuite(mn, "CVT Basic Accessors")

    local cvt = AutoCategory.CVT:New()

    TK.assertEquals(0, cvt:size(), "initial size is zero")

    cvt:append("One")
    TK.assertEquals(1, cvt:size(), "size after one append")

    cvt:append("Two")
    TK.assertEquals(2, cvt:size(), "size after two appends")

    cvt:setControlName("MyDropdown")
    TK.assertEquals("MyDropdown", cvt:getControlName(), "setControlName changes control name")
end


-- =========================================================
-- append
-- =========================================================

local function TestCVT_Append()
    TK.printSuite(mn, "CVT append")

    do
        local cvt = AutoCategory.CVT:New()

        TK.assertTrue(cvt:append("One"), "[choice only] append accepts choice")
        TK.assertEquals(1, #cvt.choices, "[choice only] choice appended")
        TK.assertEquals("One", cvt.choices[1], "[choice only] choice stored at index 1")
        TK.assertTrue(cvt.dirty, "[choice only] append marks CVT dirty")
    end

    do
        local cvt = AutoCategory.CVT:New(nil, nil, AutoCategory.CVT.USE_VALUES)

        TK.assertFalse(cvt:append("One"), "[values] value required when choicesValues enabled")
        TK.assertEquals(0, cvt:size(), "[values] failed append does not add choice")
        TK.assertTrue(cvt:append("One", 101), "[values] choice and value accepted")
        TK.assertEquals("One", cvt.choices[1], "[values] choice stored")
        TK.assertEquals(101, cvt.choicesValues[1], "[values] value stored")
    end

    do
        local cvt = AutoCategory.CVT:New(nil, nil, AutoCategory.CVT.USE_TOOLTIPS)

        TK.assertFalse(cvt:append("One"), "[tooltips] tooltip required when tooltips enabled")
        TK.assertTrue(cvt:append("One", nil, "Tooltip"), "[tooltips] choice and tooltip accepted")
        TK.assertEquals("One", cvt.choices[1], "[tooltips] tooltip CVT stores choice")
        TK.assertEquals("Tooltip", cvt.choicesTooltips[1], "[tooltips] tooltip stored")
    end

    do
        local cvt = AutoCategory.CVT:New(nil, nil, AutoCategory.CVT.USE_ALL)

        TK.assertFalse(cvt:append(nil, 1, "tip"), "[all] nil choice rejected")
        TK.assertFalse(cvt:append("One", nil, "tip"), "[all] nil value rejected")
        TK.assertFalse(cvt:append("One", 1, nil), "[all] nil tooltip rejected")
        TK.assertTrue(cvt:append("One", 1, "tip"), "[all] complete USE_ALL row accepted")
    end

    do
        local cvt = AutoCategory.CVT:New(nil, nil, AutoCategory.CVT.USE_ALL)

        TK.assertTrue(cvt:append("Empty", "", ""), "[all] empty strings are valid append values")
        TK.assertEquals("", cvt.choicesValues[1], "[all] empty value preserved")
        TK.assertEquals("", cvt.choicesTooltips[1], "[all] empty tooltip preserved")
    end
end

local function CVT_testAppend()
    TK.printSuite(mn, "testCVTAppend")
    local cvt = AC.CVT:New("myControl3",nil,AC.CVT.USE_VALUES)
    TK.assertTrue(cvt.controlName == "myControl3", "cvt.controlName == myControl3")
    cvt.indexValue = "four"
    TK.assertNotNil(cvt.indexValue,"indexValue ~= nil")
    local newvals = AC.CVT:New(nil,nil,AC.CVT.USE_VALUES)
    fillCVT(newvals, { 1, 2, 4 },{"one","two","four"})
    newvals.indexValue = "two"
    cvt:assign(newvals)
    cvt:append( 3, "three", "")
    cvt.indexValue = "two"
    TK.assertTrue(cvt.choices[4] == 3, "choices[4] == three")
    TK.assertTrue(cvt.choicesValues[4] == "three", "choicesValues[4] == three")
    TK.assertNil(cvt.choicesTooltips,"no choicesTooltips")
    TK.assertTrue(cvt.indexValue == "two", "indexValue == "..cvt.indexValue)
    TK.assertTrue(cvt.controlName == "myControl3", "cvt.controlName = "..cvt.controlName)
end


-- =========================================================
-- clear
-- =========================================================

local function TestCVT_Clear()
    TK.printSuite(mn, "CVT clear")

    local cvt = AutoCategory.CVT:New(nil, "selected", AutoCategory.CVT.USE_ALL)

    cvt:append("One", 1, "Tip")
    cvt:append("Two", 2, "Tip2")

    local choicesRef = cvt.choices
    local valuesRef = cvt.choicesValues
    local tooltipsRef = cvt.choicesTooltips

    cvt:clear()

    TK.assertEquals(0, #cvt.choices,
        "clear removes choices")

    TK.assertEquals(0, #cvt.choicesValues,
        "clear removes values")

    TK.assertEquals(0, #cvt.choicesTooltips,
        "clear removes tooltips")

    TK.assertNil(cvt.indexValue,
        "clear removes selection")

    TK.assertTrue(cvt.dirty,
        "clear marks CVT dirty")

    TK.assertTrue(choicesRef == cvt.choices,
        "clear preserves choices table reference")

    TK.assertTrue(valuesRef == cvt.choicesValues,
        "clear preserves values table reference")

    TK.assertTrue(tooltipsRef == cvt.choicesTooltips,
        "clear preserves tooltips table reference")
end


-- =========================================================
-- select
-- =========================================================

local function TestCVT_Select()
    TK.printSuite(mn, "CVT select")

    do
        local cvt = AutoCategory.CVT:New()

        cvt:append("One")
        cvt:append("Two")

        TK.assertEquals("One", cvt:select(), "select with no value chooses first choice")
        TK.assertEquals("Two", cvt:select("Two"), "valid choice selected")
        TK.assertEquals("Two", cvt:select("NotPresent"), "invalid value retains current valid selection")
        TK.assertEquals("Two", cvt:select(""), "empty string retains current valid selection")
    end

    do
        local cvt = AutoCategory.CVT:New()

        cvt:append("One")
        cvt:append("Two")

        local result = cvt:select({"NotPresent"})

        TK.assertEquals("NotPresent", result,
            "table selection accepts supplied value without validation")
        TK.assertEquals("NotPresent", cvt.indexValue,
            "table selection does not validate supplied value")
    end

    do
        local cvt = AutoCategory.CVT:New()

        cvt:append("One")
        cvt:append("Two")

        TK.assertEquals("One", cvt:select({}), "empty table selects first choice")
        TK.assertEquals("One", cvt:select({nil}), "table with nil first value selects first choice")
    end

    do
        local cvt = AutoCategory.CVT:New(nil, nil, AutoCategory.CVT.USE_VALUES)

        cvt:append("One", 101)
        cvt:append("Two", 102)

        TK.assertEquals(101, cvt:select(), "values list controls default selection")
        TK.assertEquals(102, cvt:select(102), "valid choice value selected")
        TK.assertEquals(102, cvt:select(999), "invalid choice value retains current selection")
    end

    do
        local cvt = AutoCategory.CVT:New()

        TK.assertNil(cvt:select(), "empty CVT has no selection")
        TK.assertNil(cvt:select("anything"), "selection remains nil when CVT is empty")
    end
end


-- =========================================================
-- clearIndex
-- =========================================================

local function TestCVT_ClearIndex()
    TK.printSuite(mn, "CVT clearIndex")

    local cvt = AutoCategory.CVT:New(nil, "selected")

    TK.assertEquals("selected", cvt.indexValue,
        "initial index value set")

    cvt:clearIndex()

    TK.assertNil(cvt.indexValue,
        "clearIndex clears selection")
end


-- =========================================================
-- assign
-- =========================================================

local function TestCVT_Assign_Incompatible()
    TK.printSuite(mn,"CVT Assign Incompatibles")
    local src = AutoCategory.CVT:New(nil, 2, AutoCategory.CVT.USE_VALUES)
    src:append(1, "one")
    src:append(2, "two")
    src:append(4, "four")
    
    local cvt = AutoCategory.CVT:New("myControl", nil, AutoCategory.CVT.USE_ALL)
    TK.assertFalse(cvt:assign(src), "assignment failed - incompatible VALUES with ALL")
    
    local cvt1 = AutoCategory.CVT:New("myControl", nil, AutoCategory.CVT.USE_TOOLTIPS)
    TK.assertFalse(cvt1:assign(src), "assignment failed - incompatible VALUES with TOOLTIPS")
    
    local cvt2 = AutoCategory.CVT:New("myControl", nil)
    TK.assertFalse(cvt2:assign(src), "assignment failed - incompatible VALUES with CHOICES")
end


local function TestCVT_Assign()
    TK.printSuite(mn, "CVT assign")

    do
        local src = AutoCategory.CVT:New(nil, 2, AutoCategory.CVT.USE_ALL)
        src:append("One", 1, "Tip1")
        src:append("Two", 2, "Tip2")

        local dst = AutoCategory.CVT:New(nil, 1, AutoCategory.CVT.USE_ALL)
        dst:append("Old", 99, "OldTip")

        local choicesRef = dst.choices
        local valuesRef = dst.choicesValues
        local tooltipsRef = dst.choicesTooltips

        dst:assign(src)

        TK.assertEquals(2, #dst.choices, "assign copies choices")
        TK.assertEquals(2, #dst.choicesValues, "assign copies values")
        TK.assertEquals(2, #dst.choicesTooltips, "assign copies tooltips")

        TK.assertEquals("Two", dst.choices[2], "assigned choice is correct")
        TK.assertEquals(2, dst.choicesValues[2], "assigned value is correct")

        TK.assertEquals("Tip2", dst.choicesTooltips[2], "assigned tooltip is correct")
        TK.assertEquals(2, dst.indexValue, "source selection copied")

        TK.assertTrue(choicesRef == dst.choices, "assign preserves choices table")
        TK.assertTrue(valuesRef == dst.choicesValues, "assign preserves values table")
        TK.assertTrue(tooltipsRef == dst.choicesTooltips, "assign preserves tooltips table")
    end

    do
        local src = AutoCategory.CVT:New()
        src:append("One")

        local dst = AutoCategory.CVT:New(nil, nil, AutoCategory.CVT.USE_VALUES)
        dst:append("Old", 99)

        local oldValue = dst.choicesValues[1]

        dst:assign(src)

        TK.assertEquals(99, dst.choicesValues[1],
            "assign aborted when source lacks required values")
    end

    do
        local cvt = AutoCategory.CVT:New()
        cvt:append("One")

        local before = cvt.choices[1]

        cvt:assign(cvt)

        TK.assertEquals(before, cvt.choices[1],
            "assign to self does nothing")
    end

    do
        local dst = AutoCategory.CVT:New()
        dst:append("One")

        local before = dst.choices[1]

        dst:assign(nil)

        TK.assertEquals(before, dst.choices[1],
            "assign nil does nothing")
    end
end



local function TestCVT_Assign3()
    TK.printSuite(mn, "CVTAssign3")
    local cvt = AC.CVT:New("myControl2", "two", AC.CVT.USE_VALUES)
    
    cvt:select( "four" )
    TK.assertNil(cvt.indexValue,"indexValue = nil for 'four'")
    local newvals = AC.CVT:New(nil,nil,AC.CVT.USE_VALUES)
    fillCVT(newvals, { 1, 2, 4 },{"one","two","four"})
    newvals.indexValue = "two"
    cvt:assign(newvals)
    TK.assertTrue(cvt.choices[2] == 2, "choices[2] == 2")
    TK.assertTrue(cvt.choicesValues[2] == "two", "choicesValues[2] == two")
    TK.assertNil(cvt.choicesTooltips,"no such choicesTooltips")
    TK.assertTrue(cvt.indexValue == "two", "indexValue == "..(cvt.indexValue or ""))
    cvt:select( "four" )
    TK.assertTrue(cvt.indexValue == "four", "indexValue == "..(cvt.indexValue or ""))
    TK.assertTrue(cvt.controlName == "myControl2", "cvt.controlName = "..cvt.controlName)
end

-- =========================================================
-- removeItemChoice
-- =========================================================

local function TestCVT_RemoveItemChoice()
    TK.printSuite(mn, "CVT removeItemChoice")

    local cvt = AutoCategory.CVT:New(nil, nil, AutoCategory.CVT.USE_ALL)

    TK.assertNotNil(cvt.choicesValues, "USE_ALL creates choicesValues")

    cvt:append("One", 1, "Tip1")
    cvt:append("Two", 2, "Tip2")
    cvt:append("Three", 3, "Tip3")

    TK.assertEquals(3, #cvt.choices, "three choices before removal")
    TK.assertEquals(3, #cvt.choicesValues, "three values before removal")
    TK.assertEquals(1, cvt.choicesValues[1], "first value is 1")
    TK.assertEquals(2, cvt.choicesValues[2], "second value is 2")
    TK.assertEquals(3, cvt.choicesValues[3], "third value is 3")

    cvt:select(1)

    TK.assertEquals(1, cvt.indexValue, "first value initially selected")

    local result = cvt:removeItemChoice("One")

    TK.assertEquals(2, result, "removing first item selects next item")
    TK.assertEquals(2, cvt.indexValue, "next value becomes current selection")
    TK.assertEquals(2, #cvt.choices, "one choice removed")
    TK.assertEquals(2, #cvt.choicesValues, "one value removed")

    TK.assertEquals("Two", cvt.choices[1], "second choice moves to first position")
    TK.assertEquals(2, cvt.choicesValues[1], "second value moves to first position")
    TK.assertEquals("Tip2", cvt.choicesTooltips[1], "second tooltip moves to first position")

    TK.assertTrue(cvt.dirty, "removal marks CVT dirty")
    
    do
      local cvt = CVT:New(nil, 2, CVT.USE_ALL)

      cvt:append("One", 1, "Tip1")
      cvt:append("Two", 2, "Tip2")
      local ndx = cvt.indexValue
      cvt.dirty = false
      local result = cvt:removeItemChoice("Missing")

      TK.assertTrue(result == ndx, "removing missing choice returns prev index")

      TK.assertEquals(2, #cvt.choices, "removing missing choice leaves choices unchanged")
      TK.assertEquals(2, cvt.indexValue, "removing missing choice preserves selection")

      TK.assertFalse(cvt.dirty, "removing missing choice does not dirty CVT")
  end
end

-- =========================================================
-- removeItemChoiceValue
-- =========================================================

local function TestCVT_RemoveItemChoiceValue()
    TK.printSuite(mn, "CVT removeItemChoiceValue")

    do
        local cvt = AutoCategory.CVT:New(nil, nil, AutoCategory.CVT.USE_ALL)

        cvt:append("One", 1, "Tip1")
        cvt:append("Two", 2, "Tip2")
        cvt:append("Three", 3, "Tip3")

        cvt:select(1)

        TK.assertEquals(2, cvt:removeItemChoiceValue(1), "removing first value selects next value")
        TK.assertEquals("Two", cvt.choices[1], "choice removed with value")
        TK.assertEquals(2, cvt.choicesValues[1], "value list shifted")
        TK.assertEquals("Tip2", cvt.choicesTooltips[1], "tooltip list shifted")
    end

    do
        local cvt = AutoCategory.CVT:New(nil, nil, AutoCategory.CVT.USE_VALUES)

        cvt:append("One", 1)
        cvt:append("Two", 2)
        cvt:append("Three", 3)

        cvt:select(2)

        TK.assertEquals(3, cvt:removeItemChoiceValue(2), "removing middle value selects following value")
    end

    do
        local cvt = AutoCategory.CVT:New(nil, nil, AutoCategory.CVT.USE_VALUES)

        cvt:append("One", 1)
        cvt:append("Two", 2)
        cvt:append("Three", 3)

        cvt:select(3)

        TK.assertEquals(2, cvt:removeItemChoiceValue(3),
            "removing last value selects previous value")
    end

    do
        local cvt = AutoCategory.CVT:New(nil, nil, AutoCategory.CVT.USE_VALUES)
        cvt:append("Only", 1)
        cvt:select(1)

        TK.assertNil(cvt:removeItemChoiceValue(1),
            "removing only value clears selection")
        TK.assertEquals(0, cvt:size(),
            "removing only value leaves empty CVT")
    end

    do
        local cvt = AutoCategory.CVT:New(nil, 2, AutoCategory.CVT.USE_VALUES)

        cvt:append("One", 1)
        cvt:append("Two", 2)

        TK.assertEquals(2, cvt:removeItemChoiceValue(999),
            "missing value preserves selection")
    end

    do
        local cvt = AutoCategory.CVT:New()

        cvt:append("One")

        TK.assertNil(cvt:removeItemChoiceValue("One"),
            "remove by value returns nil without values list")
        TK.assertEquals(1, cvt:size(),
            "remove by value does nothing without values list")
    end
end


-- =========================================================
-- updateControl
-- =========================================================

local function TestCVT_UpdateControl()
    TK.printSuite(mn, "CVT updateControl")

    local oldWindowManager = WINDOW_MANAGER

    local requestedName = nil
    local updateCount = 0
    local receivedChoices = nil
    local receivedValues = nil
    local receivedTooltips = nil

    local fakeControl = {
        UpdateChoices = function(self, choices, values, tooltips)
            updateCount = updateCount + 1
            receivedChoices = choices
            receivedValues = values
            receivedTooltips = tooltips
        end,
    }

    WINDOW_MANAGER = {
        GetControlByName = function(self, name)
            requestedName = name
            return fakeControl
        end,
    }

    -- ---------------------------------------------------
    -- dirty CVT updates the control
    -- ---------------------------------------------------

    do
        requestedName = nil
        updateCount = 0
        receivedChoices = nil
        receivedValues = nil
        receivedTooltips = nil

        local cvt = AutoCategory.CVT:New("TestDropdown")

        cvt:append("One")
        cvt:updateControl()

        TK.assertEquals("TestDropdown", requestedName,
            "updateControl requests correct control")
        TK.assertEquals(1, updateCount,
            "updateControl calls UpdateChoices once")
        TK.assertTrue(receivedChoices == cvt.choices,
            "UpdateChoices receives choices list")

        TK.assertNil(receivedValues, "UpdateChoices receives nil values")
        TK.assertNil(receivedTooltips, "UpdateChoices receives nil tooltips")
        TK.assertNil(cvt.dirty, "updateControl clears dirty flag")
    end

    -- ---------------------------------------------------
    -- clean CVT does nothing
    -- ---------------------------------------------------

    do
        requestedName = nil
        updateCount = 0

        local cvt = AutoCategory.CVT:New("TestDropdown")

        cvt:updateControl()

        TK.assertNil(requestedName, "clean CVT does not request control")
        TK.assertEquals(0, updateCount, "clean CVT does not update control")
    end

    -- ---------------------------------------------------
    -- missing control
    -- ---------------------------------------------------

    do
        requestedName = nil
        updateCount = 0

        WINDOW_MANAGER.GetControlByName = function(self, name)
            requestedName = name
            return nil
        end

        local cvt = AutoCategory.CVT:New("MissingControl")

        cvt:append("One")
        cvt:updateControl()

        TK.assertEquals("MissingControl", requestedName, "missing control is requested")
        TK.assertEquals(0, updateCount, "missing control is not updated")
        TK.assertTrue(cvt.dirty, "dirty remains set when control is missing")
    end
    
    do
        requestedName = nil
        updateCount = 0
        
        WINDOW_MANAGER = {
            GetControlByName = function(self, name)
                requestedName = name
                return fakeControl
            end,
        }
        
        local cvt = CVT:New("TestDropdown")

        cvt:append("One")
        cvt:append("Two")
        cvt:append("Three")

        cvt:updateControl()

        TK.assertEquals(1, updateCount, "multiple changes before update produce one control update")
    end

    WINDOW_MANAGER = oldWindowManager
end


-- =========================================================
-- Corrupt CVT handling
-- =========================================================

local function TestCVT_CorruptChoices()
    TK.printSuite(mn, "CVT corrupt choices")

    local cvt = AutoCategory.CVT:New()

    cvt.choices = nil
    cvt.indexValue = "old"

    TK.assertNil(cvt:removeItemChoice("anything"),
        "corrupt choices returns nil")

    TK.assertNotNil(cvt.choices,
        "corrupt choices replaced with table")

    TK.assertEquals(0, #cvt.choices,
        "replacement choices table is empty")

    TK.assertNil(cvt.indexValue,
        "corrupt choices clears index")

    TK.assertTrue(cvt.dirty,
        "corrupt choices marks CVT dirty")
end


-- =========================================================
-- Run CVT tests
-- =========================================================

local function TestCVT_SetControlName()
    TK.printSuite(mn, "SetControlName")
    local cvt = AC.CVT:New()
    TK.assertNil(cvt.controlName, "cvt.controlName == nil")
    cvt:setControlName("myNewControl")
    TK.assertTrue(cvt.controlName == "myNewControl", "cvt.controlName = "..cvt.controlName)
end


function TestCVT_runAll()
    TestCVT_Init()
    
    TestCVT_New()
    TestCVT_Initialize()
    TestCVT_GetUses()
    TestCVT_BasicAccessors()
    TestCVT_SetControlName()
    TestCVT_Append()
    CVT_testAppend()
    TestCVT_Clear()
    TestCVT_Select()
    TestCVT_ClearIndex()
    TestCVT_Assign_Incompatible()
    TestCVT_Assign()
    TestCVT_Assign3()
    TestCVT_RemoveItemChoice()
    TestCVT_RemoveItemChoiceValue()
    TestCVT_UpdateControl()
    TestCVT_CorruptChoices()
    TestCVT_Reset()
end

if not Suite then
    TK.init()
    
    TestCVT_runAll()
    
    TK.showResult("CVT Tests")
end
