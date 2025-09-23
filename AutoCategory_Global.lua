AC_BAG_TYPE_BACKPACK = 1
AC_BAG_TYPE_BANK = 2
AC_BAG_TYPE_GUILDBANK = 3
AC_BAG_TYPE_CRAFTBAG = 4
AC_BAG_TYPE_CRAFTSTATION = 5
AC_BAG_TYPE_HOUSEBANK = 6
AC_BAG_TYPE_FURNVAULT = 7

local SF = LibSFUtils
 
AutoCategory = {
    name = "AutoCategory",
    version = SF.colors.gold:Colorize("4.5.3"),
    settingName = "AutoCategory",
    settingDisplayName = SF.colors.gold:Colorize("AutoCategory - Revised"),
    author = SF.colors.purple:Colorize("Shadowfen, crafty35, RockingDice, Friday_the13_rus"),

    RuleFunc = {},  -- internal and plugin rule functions
    Plugins = {},   -- registered plugins

    Inited = false, -- provided for the API so that external users can tell when initialization is completed
    Enabled = true, -- flag to tell if AutoCategory is turned on or off
    compiledRules = {},
    rules = {},	--  [#] rule {rkey, name, tag, description, rule, pred, damaged, err}
    ARW = {},
}

AutoCat_Logger = SF.SafeLoggerFunction(AutoCategory, "logger", "AutoCategory")
AutoCat_Logger():SetDebug(true)


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


