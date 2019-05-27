local AC = AutoCategory

-- A very simple plugin for several one-liner addons which only have
-- a single rule function to register.
--
-- No strings or predefined rules to load.

AutoCategory_MiscAddons = {
    RuleFunc = {},
}

--Initialize plugin for Auto Category - Misc Addons
function AutoCategory_MiscAddons.Initialize()
    -- Master Merchant
	AutoCategory.AddRuleFunc("getpricemm", AutoCategory_MiscAddons.RuleFunc.GetPriceMM)
    
    -- Tamriel Trade Center
    AutoCategory.AddRuleFunc("getpricettc", AutoCategory_MiscAddons.RuleFunc.GetPriceTTC)
    
    -- AlphaGear
    if not AG then
        AutoCategory.AddRuleFunc("alphagear", AutoCategory.dummyRuleFunc)   -- always return false
    else
        AutoCategory.AddRuleFunc("alphagear", AutoCategory_MiscAddons.RuleFunc.AlphaGear)
    end
    
    -- SetTracker
    if not SetTrack then
        AutoCategory.AddRuleFunc("istracked", AutoCategory.dummyRuleFunc)    -- always return false
    else
        AutoCategory.AddRuleFunc("istracked", AutoCategory_MiscAddons.RuleFunc.IsTracked)
    end
    
    
end

local function getCurrentItemLink()
	return GetItemLink(AC.checkingItemBagId, AC.checkingItemSlotIndex)
end

-- Implement getpricemm() check function for Master Merchant
function AutoCategory_MiscAddons.RuleFunc.GetPriceMM( ... )
	local fn = "getpricemm"
	if MasterMerchant then
		local itemLink = getCurrentItemLink()
		local mmData = MasterMerchant:itemStats(itemLink, false)
        if (mmData.avgPrice ~= nil) then
            return mmData.avgPrice
        end
	end
	return 0 
end

-- Implement getpricettc() check function for Tamriel Trade Center
function AutoCategory_MiscAddons.RuleFunc.GetPriceTTC( ... )
	local fn = "getpricettc"
	if TamrielTradeCentre and TamrielTradeCentrePrice then
		local itemLink = getCurrentItemLink()
		local priceInfo = TamrielTradeCentrePrice:GetPriceInfo(itemLink)
		if priceInfo then 
			local ac = select( '#', ... ) 
			if ac == 0 then
				--get suggested price
				if priceInfo.SuggestedPrice then
					return priceInfo.SuggestedPrice
				end
			else
				local arg = select( 1, ... )
				if type( arg ) == "string" then
					if arg == "average" then
						if priceInfo.Avg then
							return priceInfo.Avg
						end
					elseif arg == "suggested" then
						if priceInfo.SuggestedPrice then
							return priceInfo.SuggestedPrice
						end
					elseif arg == "both" then
						if priceInfo.SuggestedPrice then
							return priceInfo.SuggestedPrice
						elseif priceInfo.Avg then
							return priceInfo.Avg
						end
					end
				end
			end 
		end
	end
	return 0 
end

-- Implement alphagear() check function for Alpha Gear
function AutoCategory_MiscAddons.RuleFunc.AlphaGear( ... ) 
	if not (AG ) then
		return false
	end
	local fn = "alphagear"
	local ac = select( '#', ... )
	if ac == 0 then
		error( string.format("error: %s(): require arguments." , fn))
	end
	
	local uid = Id64ToString(GetItemUniqueId(AC.checkingItemBagId, AC.checkingItemSlotIndex))
	if not uid then return false end

	for ax = 1, ac do 
		local arg = select( ax, ... )
		local comIndex = -1
		if not arg then
			error( string.format("error: %s():  argument is nil." , fn))
		end
		if type( arg ) == "number" then
			comIndex = arg
		elseif type( arg ) == "string" then
			comIndex = tonumber(arg)
		else
			error( string.format("error: %s(): argument is error." , fn ) )
		end
		
		local nr = comIndex
		if AG.setdata[nr].Set.gear > 0 then
			for slot = 1,14 do
				if AG.setdata[AG.setdata[nr].Set.gear].Gear[slot].id == uid then
					local setName = AG.setdata[nr].Set.text[1]
					AutoCategory.AdditionCategoryName = AutoCategory.AdditionCategoryName .. string.format(" (%s)", setName)
	
					return true
				end
			end
		end 
	end
	
	return false 
end

-- Implement istracked() check function for Set Tracker
function AutoCategory_MiscAddons.RuleFunc.IsTracked( ... )
  local fn = "istracked"
  if SetTrack == nil then
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
  
  local iTrackIndex, sTrackName, sTrackColour, sTrackNotes = SetTrack.GetTrackingInfo(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
  if iTrackIndex >= 0 then
    if ac > 0 then
      if checkSets[sTrackName] ~= nil then
        -- true only if a specified set name is tracked on this item
        return true
      end
      -- item was tracked but not one of the specified sets, so return false
      return false
    else
      -- specific set names weren't given so true if tracked at all
      return true
    end
  end
  -- not a set tracked by SetTrack
  return false  
end


-- Register this plugin with AutoCategory to be initialized and used when AutoCategory loads.
AutoCategory.RegisterPlugin("MiscAddons", AutoCategory_MiscAddons.Initialize)