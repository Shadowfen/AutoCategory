local SF = LibSFUtils


-- --------------------------------------------
-- Create a new Bag Entry (factory)
-- Rule parameter is required, runpriority is optional.
-- If a runpriority is not provided, default to 1000
-- Returns a table {name=, runpriority=, showpriority=} or nil
--
function AutoCategory.CreateBagRule(rule, runpriority, showprior)
    -- validate parameters
	local rulename
	if type(rule) == "string" then
		rulename = rule
		rule = AutoCategory.GetRuleByName(rulename)
	end
	if not rule or not rule.name then
		return nil

	else
		rulename = rule.name
	end

	local ruleRunprior = runpriority or 1000
    showprior = showprior or ruleRunprior

    -- create the bagrule structure
    local bagrule = {
		name = rulename,
		runpriority = ruleRunprior,
		showpriority = showprior,
	}
    setmetatable(bagrule,{__index = AutoCategory.BagRuleApiMixin})
    return bagrule
end


-- -------------------------------------------------------
-- The BagRule class assists in the definition, management, and formatting of
-- bag rules for the collection of them in the Bag Settings Categories dropdown.
-- The minimum that a bagrule has is { name, runpriority, showpriority }.
--
-- This function set to be used with bagrule structures loaded in or created.
-- Note: Even though the table is called a "mixin" you must NOT use
-- it with zo_mixin() because the objects that this set of functions
-- is used with is saved with SaveVariables and cannot have functions 
-- just copied into it.
--
local bagRuleApiMixin = {
	convertPriority = function (self)
			if self.priority then 
				self.runpriority = self.priority
				self.priority = nil
			end
			if not self.showpriority then 
				self.showpriority = self.runpriority
			end
		end,

	isValid = function (self)
			if not self.name or self.name == "" then
				return false
			end
			if not self.runpriority then return false end
			return true
		end,

    formatValue = function (self)
			return self.name
		end,

	-- formatShow() creates a string to represent the bagrule in the UI dropdown.
	-- It combines the name and runpriority and showpriority and optionally marks or colorizes them
	-- based on if the bag rule is marked "hidden" or if the backing Rule has
	-- disappeared (i.e the bag rule is now invalid).
	-- If no priority is passed in then the rule's runpriority is used.
	-- Returns the string for the bagrule dropdown. Format: "name (runpriority/showpriority)"
	formatShow	= function (self)
            local general = AutoCategory.saved.general
            local appearance = AutoCategory.saved.appearance

			local rule = self:getBackingRule()
			self:convertPriority()

			local sn
			if not rule then
				-- missing rule (nil was passed in)
				sn = string.format("|cFF4444(!)|r %s (%d/%d)", self.name, self.runpriority, self.showpriority)

			else
				if self.isHidden then
					-- grey out the "hidden" category header
					local r, g, b = unpack(appearance["HIDDEN_CATEGORY_FONT_COLOR"])
					local hex = "626250"
					if r and not general["ENABLE_GAMEPAD"] then
						--r, g, b = unpack(AutoCategory.saved.appearance["HIDDEN_CATEGORY_FONT_COLOR"])
						hex = SF.colorRGBToHex(r, g, b)
					end
					sn = string.format("|c%s%s (%d/%d)|r", hex, self.name, self.runpriority, self.showpriority)

				else
					if  general["ENABLE_GAMEPAD"] then
						sn = string.format("%s (%d/%d)", self.name, self.runpriority, self.showpriority)
					else
						local r, g, b = unpack(appearance["CATEGORY_FONT_COLOR"])
						local hex = SF.colorRGBToHex(r, g, b)
						sn = string.format("|c%s%s (%d/%d)|r", hex, self.name, self.runpriority, self.showpriority)
					end
				end
			end
			return sn
		end,

	-- Provides a tooltip string for the bag rule which may be displayed
	-- when hovering over the bag rule in the dropdown menu.
	formatTooltip = function (self)
			local tt
			local rule = self:getBackingRule()
			if not rule then
				-- missing rule (nil was passed in)
				tt = L(SI_AC_WARNING_CATEGORY_MISSING)

			else
				tt = rule:getDesc()
			end
			return tt
		end,

	-- Get the rule structure (if it exists) for the bag rule name
	getBackingRule = function (self)
			if not self.name then return nil end
			local rule = AutoCategory.GetRuleByName(self.name)
			return rule
		end,

	-- Allows setting the isHidden value for the bag rule
	-- (translates false into nil to reduce junk in saved variables).
	setHidden = function (self, isHidden)
		if isHidden == false then 
			self.isHidden = nil
			return false
		end
		if self.isHidden == isHidden then return self.isHidden end
		self.isHidden = isHidden
		return self.isHidden
	end,
}
-- make accessible
AutoCategory.BagRuleApiMixin = bagRuleApiMixin
