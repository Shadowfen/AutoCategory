--====API====--
local SF = LibSFUtils

-- For use by bulk updaters of inventory (ESPECIALLY the Guild Bank)
-- to not perform sorting for a specific period of time (until the
-- bulk operation is known to be completed).
-- Because the Guild Bank info is requested from the server every single
-- time, it is prone to delays in operation to prevent server spamming.
-- It is hoped that by entering into bulk mode that we do not perform
-- server requests for the guild bank 
function AutoCategory.EnterBulkMode()
	AutoCategory.BulkMode(true)
end
function AutoCategory.ExitBulkMode()
	AutoCategory.BulkMode(false)
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

	--local logger = LibDebugLogger("AutoCategory")
	--logger:SetEnabled(true)
	
	-- Mark rules as damaged when we find something wrong with them
	local function checkValidRule(name, rule)
		if rule == nil or name == nil then return end
		
		local isValid = true
		if rule.rule == nil then
			rule.damaged = true 
			return
		end
		local ruleCode = AutoCategory.compiledRules[name]
		if not ruleCode or type(ruleCode) ~= "function" then
			rule.damaged = true 
			AutoCategory.compiledRules[name] = nil
			return
		end
		rule.damaged = false
		return
	end
	
	-- Make sure all of the rules in the bag are evaluated if damaged and marked appropriately
	local bag = AutoCategory.saved.bags[acBagType]
	for i = 1, #bag.rules do
		local entry = bag.rules[i] 
		local rule = AutoCategory.GetRuleByName(entry.name)
		checkValidRule(entry.name, rule)
	end
	--logger:SetEnabled(false)
end

-- see if we find a category rule match for the item passed in.
--     i.e. execute the rule on the specific inventory item
-- runs all the rules assigned to the specific bag type against
--     each item in the bag
--
-- returns
--   boolean - was a match found?
--   string  - name of rule matched combined with additionCategoryName
--   number  - priority of rule
--   enum    - bag type id
--   boolean - is entry hidden?
function AutoCategory:MatchCategoryRules( bagId, slotIndex, specialType )
	local logger = LibDebugLogger("AutoCategory")
	logger:SetEnabled(true)
	
	AutoCategory.LazyInit()

	-- set up bagId and slotIndex to "pass in" to the rule functions
	self.checkingItemBagId = bagId
	self.checkingItemSlotIndex = slotIndex
	self.checkingItemLink = GetItemLink(bagId, slotIndex)

	
	local bag_type_id = convert2BagTypeId(bagId, specialType)
	if not bag_type_id then
		-- invalid bag
		logger:Error("[MatchCategoryRules] invalid bag_type_id for bagId "..bagId.." special type "..(specialType or "nil"))
		return false, "", 0, nil, nil
	end
	
	-- Adjust the name of the category based on the presence of 
	-- an enhancement (set name) and if SHOW_CATEGORY_SET_TITLE is enabled
	local function adjustName(name, enhancement)
		if name == nil or name == "" then 
			name  = AutoCategory.acctSaved.appearance["CATEGORY_OTHER_TEXT"]
			enhancement = ""
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
		logger:Error("[MatchCategoryRules] bag for bag_type_id ("..bag_type_id..") was nil")
		return  false, "", 0, nil, nil
	end
	if not bag.rules then
		logger:Error("[MatchCategoryRules] bag.rules was nil")
		return  false, "", 0, nil, nil
	end
	for i = 1, #bag.rules do
		local entry = bag.rules[i] 
		local rule = AutoCategory.GetRuleByName(entry.name)
		if checkValidRule(entry.name, rule) then
			local ruleCode = AutoCategory.compiledRules[entry.name]
			if ruleCode then
				setfenv( ruleCode, AutoCategory.Environment )
				AutoCategory.AdditionCategoryName = ""	-- this may be changed by autoset() or alphagear
				local exec_ok, res = pcall( ruleCode )
				if exec_ok then
					local catname = adjustName(rule.name,
											AutoCategory.AdditionCategoryName)
					AutoCategory.SetCategoryCollapsed(bag_type_id, catname,
						AutoCategory.IsCategoryCollapsed(bag_type_id, catname))
					if res == true then
						return true, 
							catname, 
							entry.priority, 
							bag_type_id, 
							entry.isHidden
					end
					
				else
					logger:Error("Error2: " .. entry.name.. " - ".. res)
					rule.damaged = true 
					rule.err = res
					AutoCategory.compiledRules[entry.name] = nil
				end
			end
		end
	end
	logger:SetEnabled(false)
	
	return false, "", 0, bag_type_id, false
end 