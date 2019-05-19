require "AutoCategory.test.zos"
require "AutoCategory.test.tk"
local TK = TestKit

local TR = test_run
local d = print

require "LibSFUtils.LibSFUtils"
local SF = LibSFUtils
require "AutoCategory.FCOIS_Plugin"

local moduleName = "FCOIS"

local function FCOIS_testLoadLanguage()
    local fn = "testLoadLanguage"
    TK.printSuite(moduleName,fn)
    AutoCategory_FCOIS.LoadLanguage("en")
    local str = GetString(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_1)
    --d("SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_1 = "..str)
    TK.assertNotNil(str, "FCOIS_testLoadLanguage: found FCOIS_DYNAMIC_1 string")
    TK.assertTrue(str == "Dynamic 1","FCOIS_testLoadLanguage: FCOIS_DYNAMIC_1 value is correct")
    local L = GetString
    str = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DECONSTRUCTION_MARK)
    --d("SI_AC_DEFAULT_CATEGORY_FCOIS_DECONSTRUCTION_MARK = "..str)
    TK.assertNotNil(str, "FCOIS_testLoadLanguage: found FCOIS_DECONSTRUCTION_MARK string")
    TK.assertTrue(str == "Deconstruction Mark","FCOIS_testLoadLanguage: FCOIS_DECONSTRUCTION_MARK value is correct")
end

-- make sure the entire list of predefinedRules for FCOIS gets loaded without any
-- reported errors.
local function FCOIS_testPredefines()
    local fn = "testPredefines"
    TK.printSuite(moduleName,fn)
    local added, errtbl = AutoCategory.AddPredefinedRules(AutoCategory_FCOIS.predefinedRules)
    d("added = "..added)
    TR.printTable(errtbl)
    TK.assertTrue(added == 43,"testAddPredefineRule - Successfully added 43 rules")
    TK.assertTrue(#errtbl == 0,"testAddPredefineRule - returned error table was empty")
    --d("")
end

function FCOIS_runTests()
    FCOIS_testLoadLanguage()
    FCOIS_testPredefines()
end