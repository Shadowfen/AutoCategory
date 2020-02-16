-- A very simple plugin for CraftStoreFixedAndImproved that has a single rule function to register.
--
-- No strings or predefined rules to load.

local AC = AutoCategory
local CS = CraftStoreFixedAndImprovedLongClassName

AutoCategory_CraftStoreFAI = {
    RuleFunc = {},
}

--Initialize plugin for Auto Category - CraftStoreFixedAndImproved
function AutoCategory_CraftStoreFAI.Initialize()
	if not CS then
		AC.AddRuleFunc("isstoredforcraftstore", AC.dummyRuleFunc)
	else
        AC.AddRuleFunc("isstoredforcraftstore", AutoCategory_CraftStoreFAI.RuleFunc.IsStoredForCraftStore)
    end
end

-- Implement isstoredforcraftstore() check function for CraftStore Fixed and Improved
function AutoCategory_CraftStoreFAI.RuleFunc.IsStoredForCraftStore( ... )
	if CS == nil then
		return false
	end
	local itemID = Id64ToString(GetItemUniqueId(AC.checkingItemBagId, AC.checkingItemSlotIndex))
	local isStored = CS.IsItemStoredForCraftStore(itemID)
	if isStored then
	  local itemLink = GetItemLink(AC.checkingItemBagId, AC.checkingItemSlotIndex)
	  d("Item Stored for CraftStore : " .. itemLink .. " ID : " .. itemID)
    end
	return isStored
end

-- Register this plugin with AutoCategory to be initialized and used when AutoCategory loads.
AC.RegisterPlugin("CraftStoreFAI", AutoCategory_CraftStoreFAI.Initialize)