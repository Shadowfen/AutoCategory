-- A very simple plugin for ItemSaver (not FCOIS) which only has
-- a single rule function to register.
--
-- No strings or predefined rules to load.

AutoCategory_ItemSaver = {
    RuleFunc = {},
}
local AC_IS = AutoCategory_ItemSaver

--Initialize plugin for Auto Category - Item Saver
function AC_IS.Initialize()
    if ItemSaver then
        AutoCat_Logger():Info("Initializing Item Saver plugin integration")
        
        -- load supporting rule functions
        AutoCategory.AddRuleFunc("ismarkedis", AC_IS.RuleFunc.IsMarkedIS)
        return
    end

    -- assign dummy rule functions
	AutoCategory.AddRuleFunc("ismarkedis", AutoCategory.dummyRuleFunc)
end

-- Implement ismarkedis() check function for Item Saver
function AutoCategory_ItemSaver.RuleFunc.IsMarkedIS( ... )
	local fn = "ismarkedis"
	if ItemSaver == nil then
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
	local ismarked, setname = ItemSaver_IsItemSaved(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
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
AutoCategory.RegisterPlugin("ItemSaver", AutoCategory_ItemSaver.Initialize)