require "AutoCategory.test.zos"
require "AutoCategory.test.tk"
local TK = TestKit

local TR = test_run
local d = print

require "LibSFUtils.LibSFUtils"
local SF = LibSFUtils
require "AutoCategory.Iakoni_GearChanger_Plugin"

local moduleName = "Iakoni"

local function Iakoni_testLoadLanguage()
    local fn = "testLoadLanguage"
    TK.printSuite(moduleName,fn)
    AutoCategory_Iakoni.LoadLanguage("en")
    local str = GetString(AC_IAKONI_CATEGORY_SET_1)
    --d("AC_IAKONI_CATEGORY_SET_1 = "..str)
    TK.assertNotNil(str, "found IAKONI_CATEGORY_SET_1 string")
    TK.assertTrue(str == "Set#1","IAKONI_CATEGORY_SET_1 value is correct")
    local L = GetString
    str = L(AC_IAKONI_CATEGORY_SET_8)
    --d("AC_IAKONI_CATEGORY_SET_8 = "..str)
    TK.assertNotNil(str, "found AC_IAKONI_CATEGORY_SET_8 string")
    TK.assertTrue(str == "Set#8","AC_IAKONI_CATEGORY_SET_8 value is correct")
end

-- make sure the entire list of predefinedRules for Iakoni GearChanger gets loaded without any
-- reported errors.
local function Iakoni_testPredefines()
    local fn = "testPredefines"
    TK.printSuite(moduleName,fn)
    local added, errtbl = AutoCategory.AddPredefinedRules(AutoCategory_Iakoni.predefinedRules)
    d("added = "..added)
    TR.printTable(errtbl)
    TK.assertTrue(added == 10,"testAddPredefineRule - Successfully added 10 rules")
    TK.assertTrue(#errtbl == 0,"testAddPredefineRule - returned error table was empty")
    --d("")
end

function Iakoni_runTests()
    Iakoni_testLoadLanguage()
    Iakoni_testPredefines()
end