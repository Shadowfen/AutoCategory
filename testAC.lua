test_run = {
}
require "AutoCategory.test.zos"
require "AutoCategory.test.tk"
local TK = TestKit

TK.init()

local TR = test_run
local d = print

require "LibSFUtils.LibSFUtils"
local SF = LibSFUtils
require "AutoCategory.lang.strings"
require "AutoCategory.AutoCategory_Global"
require "AutoCategory.AutoCategory_Defaults"
require "AutoCategory.Plugin_API"
require "AutoCategory.AutoCategory"
local AC = AutoCategory
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
--
require "AutoCategory.AddonMenu"
--]]
local saved = AutoCategory.saved
local cache = AutoCategory.cache

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



-- pretend to load saved variables
AC.acctSaved = SF.deepCopy(AC.defaultAcctSettings)
TK.assertTrue(AC.acctSaved.rules[1].name == AC.defaultAcctSettings.rules[1].name,"prep - using pre-defined rules as default")
AC.charSaved = SF.deepCopy(AC.defaultSettings)
TK.assertTrue(#AutoCategory.acctSaved.rules > 0, "prep - has "..#AutoCategory.acctSaved.rules.." rules")
TK.assertTrue(AC.charSaved.accountWide,"Settings are account-wide")

AutoCategory.UpdateCurrentSavedVars()
TK.assertNotNil(AutoCategory.saved.rules, "testUpdateCurrentSavedVars - saved.rules has entries")
TK.assertNotNil(AutoCategory.compiledRules, "testUpdateCurrentSavedVars - compiled rules has entries")
TK.assertTrue(AC.listcount(saved.rules) == AC.listcount(AC.compiledRules), "testUpdateCurrentSavedVars - #saved.rules == #compiledRules")


require "AutoCategory.test.PluginsAPI_test"
Plugins_runTests()

require "AutoCategory.test.FCOIS_test"
FCOIS_runTests()

require "AutoCategory.test.Iakoni_test"
Iakoni_runTests()

require "AutoCategory.test.ACCache_test"
Cache_runTests()

--require "AutoCategory.AutoCategory_RuleFunc"
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
    
    local func,err = zo_loadstring("return("..rule..")")
    if not func then
        ruleCheckStatus.err = err
        ruleCheckStatus.good = nil
        --fieldData.currentRule.damaged = true 
    else
        local errt = checkKeywords(rule)
        if #errt == 0 then
            ruleCheckStatus.err = nil
            ruleCheckStatus.good = true
            --fieldData.currentRule.damaged = nil
        else
            ruleCheckStatus.err = errt[1]
            ruleCheckStatus.good = nil
            --fieldData.currentRule.damaged = true 
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
d("err[1] = "..(rcs.err or "nil"))



--[[
local function stripParen(s)
    --s:find("\(")
    return s
end

local result = {}
local ins = function(a) table.insert(result,a) end

local function getKeywords(str)
    if not str then return {} end
   --local result = {}
   local regex = "(%S)+" --([^ ]+)"
   for each,_ in str:gsub(regex, ins) do
      --table.insert(result, each)
   end
   return result
end

local function checkCurrentRule()
    if fieldData.currentRule == nil then
        ruleCheckStatus.err = nil
        ruleCheckStatus.good = nil
        return
    end
    
    local func,err = zo_loadstring("return("..fieldData.currentRule.rule..")")
    if not func then
        ruleCheckStatus.err = err
        ruleCheckStatus.good = nil
        fieldData.currentRule.damaged = true 
    else
        ctbl = getKeywords(fieldData.currentRule.rule)
        ruleCheckStatus.err = nil
        ruleCheckStatus.good = true
        fieldData.currentRule.damaged = nil
    end
end

local ctbl = getKeywords(rule)
TR.printTable(ctbl)
--]]
TK.showResult()
 