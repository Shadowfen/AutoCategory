

require "AutoCategory.test.zos"
require "AutoCategory.test.tk"
local TK = TestKit

local d = print
local mn = "Logger"

local printLibDebug = {
    Error = function(self,...)  print("["..self.addonName.."] ERROR: "..string.format(...)) end,
    Warn = function(self,...)   print("["..self.addonName.."] WARN: "..string.format(...)) end,
    Info = function(self,...)   print("["..self.addonName.."] INFO: "..string.format(...)) end,
    Debug = function(self,...)  print("["..self.addonName.."] DEBUG: "..string.format(...)) end,
    Create = function(self,name)
        local o = setmetatable({}, { __index = self})
        --o.__index = self
        o.addonName = name
        return o
        end,
}

local function CreateSFlogger(name)
    -- initialize the logger for AutoCategory
    local logger
    if LibDebugLogger then
--        logger = LibDebugLogger:Create("Postage")
--        logger:SetEnabled(true)
    else
        logger = printLibDebug:Create("Postage")
    end
    return logger
end

local function logger_testNew()
    local tn = "testloggerNew"
    TK.printSuite(mn,tn)
    local logger = {}
    TK.assertFalse(logger.addonName, "logger has no name" )
     
    logger = CreateSFlogger("myControl")
    TK.assertTrue(logger.Debug and type(logger.Debug) == "function", "has Debug function")
    TK.assertTrue(logger.addonName == "Postage", "has name")
    logger:Debug("This is a logger test")
end

logger_testNew()

TK.showResult(mn)
