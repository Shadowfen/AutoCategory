AC_BAG_TYPE_BACKPACK = 1
AC_BAG_TYPE_BANK = 2
AC_BAG_TYPE_GUILDBANK = 3
AC_BAG_TYPE_CRAFTBAG = 4
AC_BAG_TYPE_CRAFTSTATION = 5
AC_BAG_TYPE_HOUSEBANK = 6
AC_BAG_TYPE_FURNVAULT = 7
AC_BAG_TYPE_MIN =  AC_BAG_TYPE_BACKPACK
AC_BAG_TYPE_MAX = AC_BAG_TYPE_FURNVAULT

local SF = LibSFUtils
 
AutoCategory = {
    name = "AutoCategory",
    version = SF.colors.gold:Colorize("4.5.7"),
    settingName = "AutoCategory",
    settingDisplayName = SF.colors.gold("AutoCategory - Revised"),
    author = SF.colors.purple("Shadowfen, crafty35, RockingDice, Friday_the13_rus"),

    RuleFunc = {},  -- internal and plugin rule functions
    Plugins = {},   -- registered plugins

    Inited = false, -- provided for the API so that external users can tell when initialization is completed
    Enabled = true, -- flag to tell if AutoCategory is turned on or off
    compiledRules = {},
    rules = {},	--  [#] rule {rkey, name, tag, description, rule, pred, damaged, err}
    ARW = {},
}

AutoCat_Logger = SF.SafeLoggerFunction(AutoCategory, "logger", "AutoCategory")

--[[
    The following SetDebug() call is commented out because it severely slows down 
    addon operation. Turning it on does however provide lots and lots of debug logging.
    Never leave this uncommented when releasing!!
--]]
AutoCat_Logger():SetDebug(true)

-- convenience function for a call to AutoCat_Logger():Debug(SF.str(...))
-- only done for Debug() because there is no special handling for the other message levels
-- always returns nil
function AutoCategory.logDebug(...)
    local n = select("#", ...)
    if n == 0 then return end

    local logger = AutoCat_Logger()
    -- skip parameter processing if they are not going to be used.
    if not logger.enabled or not logger.SFenableDebug then return end

    if n == 1 then
        logger:Debug(...)

    else
        logger:Debug(SF.str(...))
   end
end


-- Namespace for the AutoCategory user interface elements
AC_UI = {}

AutoCategory.RulesW = {
	ruleList= {},	--  [#] rule {rkey, name, tag, description, rule, pred, damaged, err}
	ruleNames={},	-- [name] rule#
	compiled = AutoCategory.compiledRules,	-- [name] function

	tags = {},		-- [#] tagname
	tagGroups={},	-- [tag] CVT{choices{rule.name}, choicesTooltips{rule.desc/name}}
}


-- load in localization strings
SF.LoadLanguage(AutoCategory_localization_strings, "en")


function AutoCategory.foreachBag(func)
    if not func then return end
    for bagId = AC_BAG_TYPE_MIN, AC_BAG_TYPE_MAX do
        func(bagId)
    end
end
