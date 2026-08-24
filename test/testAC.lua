package.path = package.path .. ";C:/Users/scott/Documents/SFAddons/TK/?.lua;C:/Users/scott/Documents/Elder Scrolls Online/live/AddOns/LibSFUtils/?.lua"

require "zos"
require "tk"
local TK = TestKit

TK.init()

local d = print

require "LibSFUtils_Global"
require "SFUtils_Color"
require "LibSFUtils"
require "SFUtils_Tables"
require "SFUtils_Events"
require "SFUtils_HookManager"
require "SFUtils_LoadLanguage"
require "SFUtils_Logger"
local SF = LibSFUtils

-- Set this so that the individual test files don't try to run
-- immediately on loading and instead wait until called from here.
Suite=true


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
require "settings.UI_Utilities"
require "settings.BagSet"
require "settings.CategorySettings"
require "AddonMenu"

local AC = AutoCategory

local mn = "AutoCategory"

--[[
AC.compiledRules = {}
AutoCategory.saved= { 
    rules = {},             -- [#] rule {name, tag, description, rule, damaged}
    bags = {},              -- [bagId] {rules{name, priority}, isHidden}
}
AutoCategory.cache = {
    rulesByName = {},       -- [name] rule#
    rulesByTag = {},        -- [tag] {showNames{rule.name}, tooltips{rule.desc/name}}
    compiledRules = AutoCategory.compiledRules, -- [name] function
    tags = {},              -- [#] tagname
    
    bags = {},              -- {showNames{bagname}, values{bagid}, tooltips{bagname}} -- for the bags themselves
    entriesByBag = {},      -- [bagId] {showNames{ico pri rule.name}, values{rule.name}, tooltips{rule.desc/name or missing}} --
    entriesByName = {},     -- [bagId][rulename] {priority, isHidden}
}
AutoCategory.cache.bags.showNames = {}
AutoCategory.cache.bags.values = {}
AutoCategory.cache.bags.tooltips = {}
--]]
--AutoCategory.Environment = {}

require "AddonMenu"

local saved = AutoCategory.saved
local cache = AutoCategory.cache

local AC_EMPTY_TAG_NAME = "unknown"

local TR = {}
function TR.printRule(r)
    d(SF.str("name = ",r.name))
    d(SF.str("tag = ",r.tag))
    d(SF.str("rule = ",r.rule))
end

  
function TR.printTable(tbl)
    for k,v in pairs(tbl) do
        if type(v) == table then
            for kk, vv in pairs(v) do
                d("k="..k.." kk="..kk.." vv="..vv)
            end
        else
            d("k="..k.." v="..v)
        end
    end
end


AutoCategory.acctRules = {
  rules = {},
}



AutoCategory.dictionary = {
    { 
        ["or"] = true,
        ["and"] = true,
        ["not"] = true,
    },
    {
        head = true,
        shoulders = true,
    },
    { armor = true, },
    { intricate = true,},
    { type = true, traitstyle = true, isset = true, ismonsterset = true, },
}

function testCheckRule()
    local tn = "testCheckRule"
    TK.printSuite(mn,tn)

  
  local function checkKeywords(str)
     local result = {}
      for w in string.gmatch(str, "%a+") do
          local found = false
          if AC.Environment[w] then
              found = true
          else
              for i=1, #AC.dictionary do
                  if AC.dictionary[i][w] then
                      found = true
                      break;
                  end
              end
          end
          if found == false then
              table.insert(result, "Unrecognized: "..w)
          end
      end
     return result
  end

  local function checkCurrentRule(rule)
      ruleCheckStatus = {}
      if rule == nil then
          ruleCheckStatus.err = nil
          ruleCheckStatus.good = nil
          return ruleCheckStatus
      end
      
      local func,err = zo_loadstring(string.format("return(%s)", rule.rule))
      if not func then
          ruleCheckStatus.err = err
          ruleCheckStatus.good = nil
      
      else
          local errt = checkKeywords(rule)
          if #errt == 0 then
              ruleCheckStatus.err = nil
              ruleCheckStatus.good = true
          
          else
              ruleCheckStatus.err = errt[1]
              ruleCheckStatus.good = nil
          end
      end
      return ruleCheckStatus
  end


  local rule = "traitstyle(\"intricate\") or not isset() or (type(\"head\",\"shoulders\") and not ismonsterset())"
  local rcs = checkCurrentRule(rule)
  TK.assertNotNil(rcs.good, "rule is good")
  local badrule = "traitstyle(\"intricte\") or not isset() or (type(\"head\",\"shoulders\") and not ismonsterset())"
  rcs = checkCurrentRule(badrule)
  TK.assertNil(rcs.good, "badrule is not good")
end



require "test.ACCache_test"
require "test.AutoCat_Test"
require "test.BagRuleApi_Test"
require "test.BagSet_Test"
require "test.BaseUI_Test"
require "test.CVT_Test"
require "test.FCOIS_test"
require "test.Iakoni_test"
require "test.misc"
require "test.Misc_test"
require "test.PluginAPI_test"
require "test.PluginsAPI_test"
require "test.RuleApi_Test"
require "test.RuleList_Test"

-- --------------------------------------------------------------------------
function TestAC_runAll()
    testAutoCat_runAll()
    BagRuleApi_runTests()
    --testBagSet_runAll()
    TestBaseUI_runAll()
    TestCVT_runAll()
    Cache_runTests()
    FCOIS_runTests()
    Iakoni_runTests()
    
    PluginsAPI_runTests()
    runPluginAPITests()
    
    test_RuleApi_runAll()
    TestRuleList_runAll()
    misc_runTests()

    testCheckRule()
    --Misc_runTests()
end

TK.init()

TestAC_runAll()

TK.showResult("AC Tests")
