--====API====--
--local SF = LibSFUtils
--local AC = AutoCategory
--local RuleApi = AutoCategory.RuleApi

-- aliases
--local saved = AutoCategory.saved
--local aclogger = AutoCategory.logger

-- For use to tell if AutoCategory has finished its initialization process and
-- is ready for business. The following variable is nil if AutoCategory is
-- still initializing, and changes to true when the initialization is finished.
AutoCategory.Inited = AutoCategory.Inited

-- For use by bulk updaters of inventory (ESPECIALLY the Guild Bank)
-- to not perform sorting for a specific period of time (until the
-- bulk operation is known to be completed).
-- Because the Guild Bank info is requested from the server every single
-- time, it is prone to delays in operation to prevent server spamming.
-- It is hoped that by entering into bulk mode that we do not perform
-- server requests for the guild bank 
function AutoCategory.EnterBulkMode()
	AutoCategory.BulkMode = true
end
function AutoCategory.ExitBulkMode()
	AutoCategory.BulkMode = false
end



-- Convert a ZOS bagId into AutoCategory bag_type_id
-- returns the bag_type_id enum value 
--       or nil if bagId is not recognized
local BagTypeConversion = {
	[BAG_BACKPACK]         = AC_BAG_TYPE_BACKPACK,
	[BAG_WORN]             = AC_BAG_TYPE_BACKPACK,
	[BAG_BANK]             = AC_BAG_TYPE_BANK,
	[BAG_SUBSCRIBER_BANK]  = AC_BAG_TYPE_BANK,
	[BAG_VIRTUAL]          = AC_BAG_TYPE_CRAFTBAG,
	[BAG_GUILDBANK]        = AC_BAG_TYPE_GUILDBANK,
	[BAG_HOUSE_BANK_ONE]   = AC_BAG_TYPE_HOUSEBANK,
	[BAG_HOUSE_BANK_TWO]   = AC_BAG_TYPE_HOUSEBANK,
	[BAG_HOUSE_BANK_THREE] = AC_BAG_TYPE_HOUSEBANK,
	[BAG_HOUSE_BANK_FOUR]  = AC_BAG_TYPE_HOUSEBANK,
	[BAG_HOUSE_BANK_FIVE]  = AC_BAG_TYPE_HOUSEBANK,
	[BAG_HOUSE_BANK_SIX]   = AC_BAG_TYPE_HOUSEBANK,
	[BAG_HOUSE_BANK_SEVEN] = AC_BAG_TYPE_HOUSEBANK,
	[BAG_HOUSE_BANK_EIGHT] = AC_BAG_TYPE_HOUSEBANK,
}
-- convert ZOS bag type to AC bag type
function convert2BagTypeId(bagId, acprimary)
	if acprimary ~= nil then return acprimary end
	if bagId == nil then return nil end
	return BagTypeConversion[bagId]
end

function AutoCategory.validateBagRules(bagId, acprimary)
	return AutoCategory.validateACBagRules(convert2BagTypeId(bagId, acprimary))
end

-- Make sure that all of the rules for this bag are valid/undamaged
-- Do this by bag rather than by rule to avoid repeating this unnecessarily
-- as the bag of rules is evaluated per each item in the bag.
-- Do this up front to save time.
function AutoCategory.validateACBagRules(acBagType)

	if acBagType == nil then return false end

	-- Mark rules as damaged when we find something wrong with them
	-- returns nothing
	local function checkValidRule(name, rule)
		if rule == nil or name == nil then return end
		if rule.name ~= name then 
			AutoCategory.RuleApi.setError(rule, true,"name mismatch between bagrule and backing rule")
			return
		end

		local isValid = true
		if rule.rule == nil then
			AutoCategory.RuleApi.setError(rule,true,"missing rule definition")
			return
		end
		local ruleCode = AutoCategory.compiledRules[rule.name]
		if not ruleCode or type(ruleCode) ~= "function" then
			AutoCategory.RuleApi.setError(rule, true,"invalid compiled rule function")
			AutoCategory.compiledRules[rule.name] = nil
			return
		end
		rule.damaged = nil
		return
	end

	-- Make sure all of the rules in the bag are evaluated if damaged and marked appropriately
	local bag = AutoCategory.saved.bags[acBagType]
	for i = 1, #bag.rules do
		local entry = bag.rules[i] 
		local rule = AutoCategory.BagRuleApi.getBackingRule(entry)
		checkValidRule(entry.name, rule)
	end
end

-- see if we find a category rule match for the item passed in.
--     i.e. execute the rule on the specific inventory item
-- runs all the rules assigned to the specific bag type against
--     each item in the bag
--
-- returns
--   boolean - was a match found?
--   string  - name of rule matched combined with additionCategoryName, ex. "Set(godly set)"
--   number  - priority of rule
--   number -  show priority of rule
--   enum    - bag type id
--   boolean - is entry hidden?
function AutoCategory:MatchCategoryRules( bagId, slotIndex, specialType )
	-- set up bagId and slotIndex to "pass in" to the rule functions
	self.checkingItemBagId = bagId
	self.checkingItemSlotIndex = slotIndex
	self.checkingItemLink = GetItemLink(bagId, slotIndex)

	local bag_type_id = convert2BagTypeId(bagId, specialType)
	if not bag_type_id then
		-- invalid bag
		return false, "", 0, 0, nil, nil
	end

	-- Adjust the name of the category based on the presence of 
	-- an enhancement (set name) and if SHOW_CATEGORY_SET_TITLE is enabled
	local function adjustName(name, enhancement)
		if name == nil or name == "" then 
			name  = AutoCategory.acctSaved.appearance["CATEGORY_OTHER_TEXT"]
			return name
		end
		if enhancement == "" then
			-- just use declared category name
			return name

		elseif AutoCategory.saved.general["SHOW_CATEGORY_SET_TITLE"] == false then
			-- just use the set name without the category name
			return enhancement

		end
		-- combine the category and set names
		return name .. string.format(" (%s)", enhancement)
	end

	-- Make sure that we have a valid (and undamaged) rule to run on the item
	local function checkValidRule(name, rule)
		if rule == nil or name == nil then return false end
		if rule.damaged == true then return false end
		-- damage check/rule validation really occurs before the MatchCategoryRules call 
		return true
	end

	local bag = AutoCategory.saved.bags[bag_type_id]
	if not bag then
		return  false, "", 0, 0, nil, nil
	end
	if not bag.rules then
		return  false, "", 0, 0, nil, nil
	end

	-- call the rules for this bag against the entry, stop when one matches
	-- return values from pcall internal func
	local suc = false
	local ename = ""
	local rcatname = "" 
	local priority = 0
	local shopri = 0
	local bagtype_id = bag_type_id 
	local ishidden = nil

	local rs = pcall( function()
		for i = 1, #bag.rules do
			local entry = bag.rules[i]
			shopri = entry.priority
			priority = entry.priority
			ishidden = entry.isHidden
			ename = entry.name

			if ename then
				local rule = AutoCategory.GetRuleByName(ename)
				if rule and checkValidRule(ename, rule) then
					local ruleCode = AutoCategory.compiledRules[ename]
					if ruleCode then
						setfenv( ruleCode, AutoCategory.Environment )
						AutoCategory.AdditionCategoryName = ""	-- this may be changed by autoset() or alphagear
						local res = ruleCode()
						
						--local exec_ok, res = pcall( ruleCode )
						if res then
							rcatname = adjustName(rule.name,
													AutoCategory.AdditionCategoryName)
							AutoCategory.SetCategoryCollapsed(bagtype_id, rcatname,
								AutoCategory.IsCategoryCollapsed(bagtype_id, rcatname))
							suc = true
							return
						--else
						--	AutoCategory.RuleApi.setError(rule, true, "unknown error in rule "..entry.name)
						--	AutoCategory.compiledRules[entry.name] = nil
						end
					end
				end
			end
		end
	end	-- end of anon function
	)
	if suc == true then
		return true, rcatname, priority,shopri,bagtype_id,ishidden
	end

	return false, "", 0, 0, bagtype_id, false
end 