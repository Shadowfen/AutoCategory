--====API====--

-- Convert a ZOS bagId into AutoCategory bag_type_id
-- returns the bag_type_id enum value 
--       or nil if bagId is not recognized
local function convert2BagTypeId(bagId)
	local bag_type_id = nil
	if bagId == BAG_BACKPACK or bagId == BAG_WORN then
		bag_type_id = AC_BAG_TYPE_BACKPACK
	elseif bagId == BAG_BANK or bagId == BAG_SUBSCRIBER_BANK then
		bag_type_id = AC_BAG_TYPE_BANK
	elseif bagId == BAG_VIRTUAL then
		bag_type_id = AC_BAG_TYPE_CRAFTBAG
	elseif bagId == BAG_GUILDBANK then
		bag_type_id = AC_BAG_TYPE_GUILDBANK
	elseif bagId == BAG_HOUSE_BANK_ONE or bagId == BAG_HOUSE_BANK_TWO or bagId == BAG_HOUSE_BANK_THREE 
			or bagId == BAG_HOUSE_BANK_FOUR or bagId == BAG_HOUSE_BANK_FIVE or bagId == BAG_HOUSE_BANK_SIX 
			or bagId == BAG_HOUSE_BANK_SEVEN or bagId == BAG_HOUSE_BANK_EIGHT then
		bag_type_id = AC_BAG_TYPE_HOUSEBANK
	end
	return bag_type_id
end

-- see if we find a category rule match for the item passed in.
--     i.e. execute the rule on the specific inventory item
-- returns
--   boolean - was a match found?
--   string  - name of rule matched combined with additionCategoryName
--   number  - priority of rule
--   enum    - bag type id
--   boolean - is entry hidden?
function AutoCategory:MatchCategoryRules( bagId, slotIndex, specialType )
	AutoCategory.LazyInit()

	self.checkingItemBagId = bagId
	self.checkingItemSlotIndex = slotIndex
	local bag_type_id
	if specialType then
		bag_type_id = specialType
	else 
		bag_type_id = convert2BagTypeId(bagId)
	end
	if not bag_type_id then
		-- invalid bag
		return false, "", 0, nil, nil
	end
	
	--local logger = LibDebugLogger("AutoCategory")
	--logger:SetEnabled(true)
	
	local needCheck = false
	local bag = AutoCategory.saved.bags[bag_type_id]
	for i = 1, #bag.rules do
		local entry = bag.rules[i] 
		local rule = AutoCategory.GetRuleByName(entry.name)
		if rule and rule.damaged ~= true then
			if rule.rule == nil then
				rule.damaged = true 
			else
				local ruleCode = AutoCategory.compiledRules[entry.name]
				if not ruleCode or type(ruleCode) ~= "function" then
					rule.damaged = true 
					AutoCategory.compiledRules[entry.name] = nil
				else 
					setfenv( ruleCode, AutoCategory.Environment )
					AutoCategory.AdditionCategoryName = ""
					local ok, res = pcall( ruleCode )
					if ok then
						if res == true then
							return true, rule.name .. AutoCategory.AdditionCategoryName, entry.priority, bag_type_id, entry.isHidden
						end 
					else
						--logger:Error("Error2: " .. res)
						rule.damaged = true 
						AutoCategory.compiledRules[entry.name] = nil
					end
				end
			end
		end
	end
	--logger:SetEnabled(false)
	
	return false, "", 0, bag_type_id
end 