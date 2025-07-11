-- A very simple plugin for ItemMarker which only has
-- a single rule function to register.
--
-- No strings or predefined rules to load.

AutoCategory_ItemMarker = {
    RuleFunc = {},
}

--Initialize plugin for Auto Category - Item Marker
function AutoCategory_ItemMarker.Initialize()
	if not ItemMarker then
        AutoCategory.AddRuleFunc("im_ismarked", AutoCategory.dummyRuleFunc)
        return
    end
    
    -- load supporting rule functions
    AutoCategory.AddRuleFunc("im_ismarked", AutoCategory_ItemMarker.RuleFunc.IsMarkedIM)
    
end

-- Implement im_ismarked() check function for Item Marker
function AutoCategory_ItemMarker.RuleFunc.IsMarkedIM( ... )
	local fn = "im_ismarked"
	if ItemMarker == nil then
		return false
	end
	local ac = select( '#', ... ) 
	local checkMarks = {}
	for ax = 1, ac do
		
		local arg = select( ax, ... )
		if not arg then
			error( string.format("error: %s():  argument is nil." , fn))
		end
		checkMarks[arg]=true
	end
	
	local ismarked, markName = ItemMarker_IsItemMarked(AutoCategory.checkingItemBagId,
										AutoCategory.checkingItemSlotIndex)
	if ismarked == true then
		--local name = GetItemName(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
		--AutoCategory.logger:Debug("im_marked return positive for "..markName.." on "..name.."  ac = "..ac)
		if ac > 0 then
			if checkMarks[markName] then
				--AutoCategory.logger:Debug("In checkMarks")
				return true
			end
			--AutoCategory.logger:Debug("Not in checkMarks")
			return false
			
		else
			--AutoCategory.logger:Debug("Matched")
			return true
		end
	end
	return ismarked	
end

-- Register this plugin with AutoCategory to be initialized and used when AutoCategory loads.
AutoCategory.RegisterPlugin("ItemMarker", AutoCategory_ItemMarker.Initialize, nil)