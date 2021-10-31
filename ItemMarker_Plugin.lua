-- A very simple plugin for ItemMarker which only has
-- a single rule function to register.
--
-- No strings or predefined rules to load.

AutoCategory_ItemMarker = {
    RuleFunc = {},
}

--Initialize plugin for Auto Category - Item Saver
function AutoCategory_ItemMarker.Initialize()
	if not ItemMarker then
        AutoCategory.AddRuleFunc("ismarkedim", AutoCategory.dummyRuleFunc)
        return
    end
    
    -- load supporting rule functions
    AutoCategory.AddRuleFunc("ismarkedim", AutoCategory_ItemMarker.RuleFunc.IsMarkedIM)
    
end

-- Implement ismarkedis() check function for Item Marker
function AutoCategory_ItemMarker.RuleFunc.IsMarkedIM( ... )
	local fn = "ismarkedim"
	if ItemMarker == nil then
		return false
	end
	local ac = select( '#', ... ) 
	local checkSets = {}
	for ax = 1, ac do
		
		local arg = select( ax, ... )
		if not arg then
			error( string.format("error: %s():  argument is nil." , fn))
		end
		checkSets[arg]=true
	end
	local ismarked, setname = ItemMarker_IsItemMarked(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
	if ismarked == true then
		if ac > 0 then
			if checkSets[setname] ~= nil then
				return true
			end
			return false
		else
			return true
		end
	end
	return ismarked	
end

-- Register this plugin with AutoCategory to be initialized and used when AutoCategory loads.
AutoCategory.RegisterPlugin("ItemMarker", AutoCategory_ItemMarker.Initialize)