AutoCategory_Master = {}
local ACM = AutoCategory_Master

local SF = LibSFUtils
local color = SF.hex

local ACMmsg = SF.addonChatter:New("AutoCategory")
local debugmode=false
--ACMmsg:enableDebug()

local function dbg(...)	-- mostly because I hate to type
	ACMmsg:debugMsg(...)
end
-- ----------------------------------------------------
-- The Master Rules List object
--   Keeps all of the defined rules, their compiled functions,
--   various methods of lookup and sorting
--
--   This does not get saved into Saved Variables, although
--   some of the contents do.

-- Create a MasterRules object
function ACM:New()
	o = {} 
	setmetatable(o, self)
	self.__index = self
	
    -- note that rule names must be unique in this list
    o.rules = {}        -- list of all master rules
    o.nameLookup = {}   -- table keyed by rule name with value of index into "rules" list, rule names are unique
    o.tags = {}         -- table keyed by tag name with value of list of rule names belonging to that tag
                        -- a rule may belong to only one tag
    return o
end

function ACM:GetRule(name)
    local ndx = self.nameLookup[name]
    if ndx == nil then return nil end
    
    return self.rules[ndx]
end

-- removes the named rule from the master lists and lookups
--
-- returns the master rule that was removed from the tables
--    if no rule with that name existed, returns nil
function ACM:RemoveRule(name)
    if not name then return nil end
    
    local oldndx = self.nameLookup[name]
    if oldndx == nil then return nil end
    
    local oldrule = self.rules[oldndx]
    
    -- Remove from saved variables
    if oldrule.user ~= nil then
        AC.acctSaved.rules[name] = nil
    end
    
    -- remove from rules, and nameLookup
    table.remove(self.rules, oldndx)
    self.nameLookup[name] = nil
    
    -- remove from tag members
    local oldtag = self.tags[oldrule.tag]
    for tndx,tmember in pairs(oldtag.contents) do
        if tmember == name then
            table.remove(oldtag.contents,tndx)
            break
        end
    end
    
    return oldrule
end

local function retFalse()
    return false
end

-- returns a function to evaluate the named rule
-- if there is no such named rule, the returned function will
-- always evaluate to false (no match)
function ACM:GetFunc(name)
    if not name then return retFalse end
    
    local ndx = self:nameLookup(name)
    if ndx == nil then return retFalse end
    
    if self.rules[ndx].func == nil then
        local func,err = zo_loadstring("return("..self.rules[ndx].rule..")")
        if func then
            self.rules[ndx].func = func
        end
    end
    return self.rules[ndx].func
end   

-- creates a base rule entry suitable for saving in SavedVariables
function ACM:CreateBaseRule(name, tag, rule, description)
    if not name then 
        dbg("Rule is required to have a name")
        return 
    end
    rule = {}
    rule.name = name
    rule.tag = tag or GetString(SI_AC_DEFAULT_NAME_EMPTY_TAG)
    rule.rule = rule or "false"
    rule.description = description or ""
end

function ACM:CloneBaseRule(masterrule)
    rule = {}
    if masterrule.user then
        SF.defaultMissing(rule,masterrule.user)
    else
        rule.name = masterrule.name
        rule.tag = masterrule.tag or GetString(SI_AC_DEFAULT_NAME_EMPTY_TAG)
        rule.rule = masterrule.rule or "false"
        rule.description = masterrule.description or ""
    end
    return rule
end

-- add/udpate a rule to the master lists
function ACM:AddRule(name, tag, ruletext, description, source)
    if not name then 
        dbg("Rule is required to have a name")
        return 
    end
    local func = nil
    local err = 0
    
    -- remove old rule
    local oldrule = self:RemoveRule(name)
    
    -- create a new rule
    local newrule = self:CreateBaseRule(name, tag, ruletext, description)
    newrule.func, err = zo_loadstring("return("..newrule.rule..")")
    if newrule.func == nil then
        dbg("Rule "..newrule.name.." failed to compile.")
        dbg("   "..err)
        return
    end
    
    -- the nameLookup table is keyed by name and has the index into the rules list
    -- for the rule corresponding to the name
    newrule.user = nil
    if source == "user" then
        newrule.user = self:CreateBaseRule(name, tag, ruletext, description)
        newrule.source = "user"
    else
        newrule.source = source
    end
    
    local ndx = #self.rules+1
    self.rules[ndx] = newrule
    self.nameLookup[name] = ndx
    AC.acctSaved.rules[name] = newrule.user
    
    -- the tags table is keyed by tag name and contains a "contents" table of rule names
    -- that belong to the tag
    local tagtbl = self.tags[tag]
    if tagtbl == nil then
        self.tags[tag] = { ["tag"]=tag, contents={} }
    else
        for tndx,tmember in pairs(self.tags[tag].contents) do
            if tmember == name then
                table.remove(self.tags[tag].contents,tndx)
                break
            end
        end
    end
    local tndx = #self.tags[tag].contents + 1
    self.tags[tag].contents[tndx] = name
end

-- Get a list of the currently defined tags
function ACM:GetTags()
    local taglst = {}
    for tname, tlst in pairs(self.tags) do
        taglst[#taglst+1]=tname
    end
    return taglst
end

-- Get a list of the names of rules that belong to a particular tag
function ACM:GetTagMembers(tag)
    tag = tag or GetString(SI_AC_DEFAULT_NAME_EMPTY_TAG)
    local memlst = {}
    if self.tags[tag] and self.tags[tag].content then
        for ndx,name in pairs(self.tags[tag].content) do
            memlst[#memlst+1] = name
        end
    end
    return memlst
end