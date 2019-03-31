-- requires AutoCategory_Global.lua
-- requires AutoCategory_Defaults.lua

local SF = LibSFUtils       -- We're using the library's LoadLanguage function
local AC = AutoCategory

-- Add a operation for rules to evaluate
--
-- Parameters: name - (string) the name of the function to use in a rule
--             func - (function) the actual lua function to execute when this
--                      operation is found in a rule
function AutoCategory.AddRuleFunc(name, func)
    AutoCategory.Environment[name] = func
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

-- Add predefined rules specific to the plugin to the master list
--
-- Parameters: ruletable - (table) a table of rule entries, each rule entry being a table
--                   containing a name, tag, rule, description, and (optional) lua function
--                   to execute to evaluate the rule. Do NOT use zo_LoadString here!
function AutoCategory.AddPredefinedRules( ruletable )
    if ruletable == nil or #ruletable == 0 then 
        return
    end
    for i=1,#ruletable do
        --make sure rule is well-formed
        local badrule = false
        if( not ruletable[i].name or type(ruletable[i].name) ~= "string" or ruletable[i].name == ""  ) then
            d("AddPredefinedRules: name is required")
            badrule = true  -- name is required
        end
        if( not ruletable[i].rule or type(ruletable[i].rule) ~= "string" or ruletable[i].rule == ""  ) then
            d("AddPredefinedRules: rule text is required")
            badrule = true  -- rule text is required
        end
        if ruletable.description then   -- description is optional
            if( type(ruletable[i].description) ~= "string" ) then
                d("AddPredefinedRules: description is not a string")
                badrule = true  -- but if provided, must be a string
            end
        end
        if ruletable.tag then   -- tag is optional
            if( type(ruletable[i].tag) ~= "string" ) then
                d("AddPredefinedRules: tag is not a string")
                badrule = true  -- but if provided, must be a string
            end
        end
        if ruletable.compiled then   -- compiled is optional
            if( type(ruletable[i].compiled) ~= "function" ) then
                d("AddPredefinedRules: compiled is not a function")
                badrule = true  -- but if provided, must be a lua function
            end
        end

        if badrule ~= false then
            AutoCategory.masterRules:AddRule(ruletable[i].name, ruletable[i].tag, ruletable[i].rule, ruletable[i].description, "predef")
        end
    end
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
