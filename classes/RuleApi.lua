-- -------------------------------------------------
-- collected functions to be applied to a rule
--
-- This functions to be used with rule structures loaded in or created.
AutoCategory.RuleApiMixin = {
	-- check if rule def is valid (required keys all present)
	isValid = function(self)
			return AutoCategory.isValidRule(self)
	end,

	--determine if a rule is marked as pre-defined
	isPredefined = function(self)
	    return self.pred and self.pred ==1
	end,

	-- return the description if the rule has one, otherwise return the name
	getDesc = function(self)
			local tt = self.description
			if not tt or tt == "" then
				tt = self.name
			end
			return tt
		end,

	-- handle error marking for a rule
	setError = function(self, dmg, errm)
			self.damaged = dmg
			self.err = errm
		end,

	clearError = function(self)
			self.damaged = nil
			self.err = nil
		end,

	-- get assigned key for the rule (if nil, returns name)
	key = function(self)
			if self.rkey then
				return self.rkey
			end
			return self.name
		end,

	-- compare a rule to another rule for certain basic equalities
	-- used for converting from acct/char rules to acctwide-only
	-- returns two bools - (name is ~=), (rule def ~=)
	isequiv = function(self, a)
			if not a then return false, false end
			local notname = self.name ~= a.name
			local notrule = self.rule ~= a.rule
			return notname, notrule
		end,

	-- Compile the Rule
	-- Return a string that is either empty (good compile)
	-- or an error string returned from the compile
	--
	-- Stores the compiled rule into AutoCategory.compiledRules table
	compile = function(self)
			if self.name == nil or self.name == "" then
                logDebug("[AutoCategory] compile: rule has no name")
				return "Rule missing name"
			end

			local compiledRules = AutoCategory.compiledRules

			self:clearError()
			local rkey = self:key()
            if not rkey then 
                self:setError(true, "Unable to generate rule key")
                return rule.err
            end
            
			compiledRules[rkey] = nil

			if self.rule == nil or self.rule == "" then
				self:setError(true,"Missing rule definition")
				return self.err
			end

			local rulestr = string.format("return(%s)", self.rule)
			local compiledfunc, err = zo_loadstring(rulestr)
			if not compiledfunc then
				self:setError(true, err)
				return err
			end
			compiledRules[rkey] = compiledfunc
			return ""
		end,
	
	-- returns nil if the rule is not compiled, non-nil if it is compiled
	isCompiled = function(self)
		if self.name == nil or self.name == "" then
			return
		end
		return AutoCategory.compiledRules[self:key()]
	end,
}
