-- requires AutoCategory_Global.lua
-- requires AutoCategory_Defaults.lua

local SF = LibSFUtils       -- We're using the library's LoadLanguage function
local AC = AutoCategory

-- A dummy rule function available for use with dummying out a RuleFunc name
-- so that it can still be "available" (used in user-defined rules when the 
-- associated addon was not loaded.
-- Now automatically used by AddRuleFunc() if another function was not provided.
function AutoCategory.dummyRuleFunc()
    return false
end


-- Add a operation for rules to evaluate
--
-- Parameters: name - (string) the name of the function to use in a rule
--             func - (function) (optional) the actual lua function to execute when this
--                      operation is found in a rule.
--                      If you do not provide this, it will be set to a function that
--                      ALWAYS returns false. 
function AutoCategory.AddRuleFunc(name, func)
    if func == nil then
        AutoCategory.Environment[name] = AutoCategory.dummyRuleFunc
		
    else
        AutoCategory.Environment[name] = func
    end
end

-- Load in localization strings for a plugin
--
-- Parameters: stringtable - (table) Key is the two letter
--                     code for the language, and the value (table) is
--                     a strings table with names and strings.
--              default_language - (2 letter language code) Which language
--                     string table to use as the default if the current
--                     language is not supported (we don't have a table for it).
--                     The default value is "en" if you do not specify.
function AutoCategory.LoadLanguage(stringtable, default_language)
    SF.LoadLanguage(stringtable, default_language)
end

-- Add predefined rules to the saved list. Will not overwrite a rule that
-- already exists in the saved variables rules list.
--
-- Parameters: ruletable - (table) a table of rule entries, each rule entry being a table
--                   containing a name, tag, rule, description, and (optional) lua function
--                   to execute to evaluate the rule. Do NOT use zo_LoadString here!
function AutoCategory.AddPredefinedRules( ruletable )
    local added = 0
    if ruletable == nil or #ruletable == 0 then 
        return 0, {"rule table was nil or empty"}
    end
    local errtbl = {}
    for i=1,#ruletable do
        local ruledef = ruletable[i]
        local rslt, err = AC.isValidRule(ruledef)
        if rslt then
            local err = AutoCategory.cache.AddRule({name=ruledef.name, tag=ruledef.tag, rule=ruledef.rule, description=ruledef.description})
            if err then
                table.insert(errtbl,err)
				
            else
                added = added + 1
            end
			
        else
            table.insert(errtbl,"Rule was invalid. ("..err..")")
        end
    end
    return added,errtbl
end

-- Register the plugin with AutoCategory so that it will be initialized along with
-- everything else on addon startup.
-- (If you don't do this, you don't exist to AutoCategory!)
--
-- Parameters: name - (string) Plugin name
--             initfunc - (function) function to call to initialize the Plugin
function AutoCategory.RegisterPlugin(name, initfunc)
	if not initfunc or type(initfunc) ~= "function" then return end
    
    AutoCategory.Plugins[name] = initfunc
	if AutoCategory.Inited then 
        -- AutoCategory is already loaded so go ahead and load plugin
        initfunc()
    end
end

