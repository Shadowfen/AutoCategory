AC_BAG_TYPE_BACKPACK = 1
AC_BAG_TYPE_BANK = 2
AC_BAG_TYPE_GUILDBANK = 3
AC_BAG_TYPE_CRAFTBAG = 4
AC_BAG_TYPE_CRAFTSTATION = 5
AC_BAG_TYPE_HOUSEBANK = 6
AC_BAG_TYPE_FURNVAULT = 7
AC_BAG_TYPE_VENGEANCE = 8

AC_BAG_TYPE_MIN =  AC_BAG_TYPE_BACKPACK
AC_BAG_TYPE_MAX = AC_BAG_TYPE_VENGEANCE

local SF = LibSFUtils
 
AutoCategory = {
    name = "AutoCategory",
    version = SF.colors.gold("4.6.15"),
    settingName = "AutoCategory",
    settingDisplayName = SF.colors.gold("AutoCategory - Revised"),
    author = SF.colors.purple("Shadowfen, crafty35, RockingDice, Friday_the13_rus"),

    RuleFunc = {},  -- collection of internal and plugin rule functions
    Plugins = {},   -- registered plugins

    Inited = false, -- provided for the API so that external users (such as BetterUI) can tell when initialization is completed
    Enabled = true, -- flag to tell if AutoCategory is turned on or off
    compiledRules = {},
    rules = {},	--  [#] rule {rkey, name, tag, description, rule, pred, damaged, err}
    ARW = {},
    BulkMode = false,
}

-- Create the delayed instantiation logger functor and utility functions for AutoCategory.
AutoCat_Logger, AutoCategory.logDebug, AutoCategory.logWouldDebug = 
            SF.InitSafeLogger(AutoCategory, "logger", "AutoCategory")

--[[ The following SetDebug() call is commented out because it severely slows down 
    addon operation. Turning it on does however provide lots and lots of debug logging.
    Never leave this uncommented when releasing!!
--]]
--AutoCat_Logger():SetDebug(true)

-- Namespace for the AutoCategory user interface elements
AC_UI = {}

--[[ AutoCategory.RulesW - Working rule data and lookup tables.
    Singleton. Contains the active rule definitions and supporting lookup structures.

    Fields:
        ruleList - table - Numerically indexed list of rule definitions.
            Each entry is a rule table containing fields such as:
                rkey      - assigned rule key, when applicable
                name      - unique rule name
                tag       - optional rule tag
                description - optional rule description
                rule      - rule expression
                pred      - indicates a predefined rule
                damaged   - indicates the rule has an error
                err       - error associated with the rule

        ruleNames - table - Maps a rule name to its numeric index in ruleList.
            Example:
                RulesW.ruleNames["My Rule"] -> 3

        compiled - table - Compiled rule functions indexed by rule key.
            References AutoCategory.compiledRules.

        tags - table - Numerically indexed list of rule tag names.

        tagGroups - table - Maps a tag name to a CVT containing the rules
            associated with that tag.
            The CVT contains:
                choices         - rule names
                choicesTooltips - rule descriptions or rule names
--]]
AutoCategory.RulesW = {
	ruleList= {},	--  [#] rule {rkey, name, tag, description, rule, pred, damaged, err}
	ruleNames={},	-- [name] index into ruleList
                    -- For every valid entry:  ruleList[ruleNames[name]].name == name
	compiled = AutoCategory.compiledRules,	-- [rule key] compiled function

	tags = {},		-- [#] tagname  -- tags contains each tag exactly once
	tagGroups={},	-- [tag] CVT containing rule names and descriptions
                    --      choices         = rule names
                    --      choicesTooltips = rule descriptions
                    -- tagGroups[tag] exists for every tag in tags
}


-- load in localization strings
SF.LoadLanguage(AutoCategory_localization_strings, "en")

--[[ AutoCategory.foreachBag(func) - Call a function once for every AutoCategory bag type.

    Parameters:
        func - function - callback receiving the AutoCategory bag type ID.

    The callback is invoked for every bag type from AC_BAG_TYPE_MIN
    through AC_BAG_TYPE_MAX, inclusive.

    The callback receives:
        bagId - number - AutoCategory bag type ID.

    Does nothing if func is nil.
    If func is a non-nil non-function, then this function will throw an error.

    Example:
        AutoCategory.foreachBag(function(bagId)
            AutoCategory.validateACBagRules(bagId)
        end)
--]]
function AutoCategory.foreachBag(func)
    if not func then return end
    for bagId = AC_BAG_TYPE_MIN, AC_BAG_TYPE_MAX do
        func(bagId)
    end
end
