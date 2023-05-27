-- A complex plugin for GearChangerByIakoni which has
-- multiple sets of localization strings, predefined rules,
-- two rule functions, and a hook into GearChangerByIakoni as well.
--

AutoCategory_Iakoni = {
    RuleFunc = {},
}

local L = GetString

-- language strings
-- The default language set of strings must contain ALL of the string definitions for the plugin.
-- For other language sets here, if a string is not defined then the english version is used
-- For any language that is not supported (i.e. not here), "en" is used.
local localization_strings = {
    de = {
        AC_IAKONI_TAG= "Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_1= "Set#1",
        AC_IAKONI_CATEGORY_SET_1_DESC= "#1 Set aus dem AddOn Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_2= "Set#2",
        AC_IAKONI_CATEGORY_SET_2_DESC= "#2 Set aus dem AddOn Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_3= "Set#3",
        AC_IAKONI_CATEGORY_SET_3_DESC= "#3 Set aus dem AddOn Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_4= "Set#4",
        AC_IAKONI_CATEGORY_SET_4_DESC= "#4 Set aus dem AddOn Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_5= "Set#5",
        AC_IAKONI_CATEGORY_SET_5_DESC= "#5 Set aus dem AddOn Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_6= "Set#6",
        AC_IAKONI_CATEGORY_SET_6_DESC= "#6 Set aus dem AddOn Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_7= "Set#7",
        AC_IAKONI_CATEGORY_SET_7_DESC= "#7 Set aus dem AddOn Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_8= "Set#8",
        AC_IAKONI_CATEGORY_SET_8_DESC= "#8 Set aus dem AddOn Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_9= "Set#9",
        AC_IAKONI_CATEGORY_SET_9_DESC= "#9 Set aus dem AddOn Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_10= "Set#10",
        AC_IAKONI_CATEGORY_SET_10_DESC= "#10 Set aus dem AddOn Iakoni's Gear Changer",
        },
    
    en = {
        AC_IAKONI_TAG= "Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_1= "Set#1",
        AC_IAKONI_CATEGORY_SET_1_DESC= "#1 Set from Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_2= "Set#2",
        AC_IAKONI_CATEGORY_SET_2_DESC= "#2 Set from Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_3= "Set#3",
        AC_IAKONI_CATEGORY_SET_3_DESC= "#3 Set from Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_4= "Set#4",
        AC_IAKONI_CATEGORY_SET_4_DESC= "#4 Set from Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_5= "Set#5",
        AC_IAKONI_CATEGORY_SET_5_DESC= "#5 Set from Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_6= "Set#6",
        AC_IAKONI_CATEGORY_SET_6_DESC= "#6 Set from Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_7= "Set#7",
        AC_IAKONI_CATEGORY_SET_7_DESC= "#7 Set from Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_8= "Set#8",
        AC_IAKONI_CATEGORY_SET_8_DESC= "#8 Set from Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_9= "Set#9",
        AC_IAKONI_CATEGORY_SET_9_DESC= "#9 Set from Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_10= "Set#10",
        AC_IAKONI_CATEGORY_SET_10_DESC= "#10 Set from Iakoni's Gear Changer",
    },
    
    fr = {
        AC_IAKONI_TAG= "Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_1= "Set#1",
        AC_IAKONI_CATEGORY_SET_1_DESC= "Iakoni's Gear Changer #1",
        AC_IAKONI_CATEGORY_SET_2= "Set#2",
        AC_IAKONI_CATEGORY_SET_2_DESC= "Iakoni's Gear Changer #2",
        AC_IAKONI_CATEGORY_SET_3= "Set#3",
        AC_IAKONI_CATEGORY_SET_3_DESC= "Iakoni's Gear Changer #3",
        AC_IAKONI_CATEGORY_SET_4= "Set#4",
        AC_IAKONI_CATEGORY_SET_4_DESC= "Iakoni's Gear Changer #4",
        AC_IAKONI_CATEGORY_SET_5= "Set#5",
        AC_IAKONI_CATEGORY_SET_5_DESC= "Iakoni's Gear Changer #5",
        AC_IAKONI_CATEGORY_SET_6= "Set#6",
        AC_IAKONI_CATEGORY_SET_6_DESC= "Iakoni's Gear Changer #6",
        AC_IAKONI_CATEGORY_SET_7= "Set#7",
        AC_IAKONI_CATEGORY_SET_7_DESC= "Iakoni's Gear Changer #7",
        AC_IAKONI_CATEGORY_SET_8= "Set#8",
        AC_IAKONI_CATEGORY_SET_8_DESC= "Iakoni's Gear Changer #8",
        AC_IAKONI_CATEGORY_SET_9= "Set#9",
        AC_IAKONI_CATEGORY_SET_9_DESC= "Iakoni's Gear Changer #9",
        AC_IAKONI_CATEGORY_SET_10= "Set#10",
        AC_IAKONI_CATEGORY_SET_10_DESC= "Iakoni's Gear Changer #10",
    },
    
    zh = {
        AC_IAKONI_TAG= "Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_1= "装备配置#1",
        AC_IAKONI_CATEGORY_SET_1_DESC= "#1 号装备配置 Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_2= "装备配置#2",
        AC_IAKONI_CATEGORY_SET_2_DESC= "#2 号装备配置 Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_3= "装备配置#3",
        AC_IAKONI_CATEGORY_SET_3_DESC= "#3 号装备配置 Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_4= "装备配置#4",
        AC_IAKONI_CATEGORY_SET_4_DESC= "#4 号装备配置 Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_5= "装备配置#5",
        AC_IAKONI_CATEGORY_SET_5_DESC= "#5 号装备配置 Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_6= "装备配置#6",
        AC_IAKONI_CATEGORY_SET_6_DESC= "#6 号装备配置 Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_7= "装备配置#7",
        AC_IAKONI_CATEGORY_SET_7_DESC= "#7 号装备配置 Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_8= "装备配置#8",
        AC_IAKONI_CATEGORY_SET_8_DESC= "#8 号装备配置 Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_9= "装备配置#9",
        AC_IAKONI_CATEGORY_SET_9_DESC= "#9 号装备配置 Iakoni's Gear Changer",
        AC_IAKONI_CATEGORY_SET_10= "装备配置#10",
        AC_IAKONI_CATEGORY_SET_10_DESC= "#10 号装备配置 Iakoni's Gear Changer",
    },
}
AutoCategory.LoadLanguage(localization_strings,"en") -- initialize strings before use in rules

AutoCategory_Iakoni.predefinedRules = {
    {
        ["rule"] = "setindex(1)",
        ["tag"] = L(AC_IAKONI_TAG),
        ["name"] = L(AC_IAKONI_CATEGORY_SET_1),
        ["description"] = L(AC_IAKONI_CATEGORY_SET_1_DESC),
    },
    {
        ["rule"] = "setindex(2)",
        ["tag"] = L(AC_IAKONI_TAG),
        ["name"] = L(AC_IAKONI_CATEGORY_SET_2),
        ["description"] = L(AC_IAKONI_CATEGORY_SET_2_DESC),
    },
    {
        ["rule"] = "setindex(3)",
        ["tag"] = L(AC_IAKONI_TAG),
        ["name"] = L(AC_IAKONI_CATEGORY_SET_3),
        ["description"] = L(AC_IAKONI_CATEGORY_SET_3_DESC),
    },
    {
        ["rule"] = "setindex(4)",
        ["tag"] = L(AC_IAKONI_TAG),
        ["name"] = L(AC_IAKONI_CATEGORY_SET_4),
        ["description"] = L(AC_IAKONI_CATEGORY_SET_4_DESC),
    },
    {
        ["rule"] = "setindex(5)",
        ["tag"] = L(AC_IAKONI_TAG),
        ["name"] = L(AC_IAKONI_CATEGORY_SET_5),
        ["description"] = L(AC_IAKONI_CATEGORY_SET_5_DESC),
    },
    {
        ["rule"] = "setindex(6)",
        ["tag"] = L(AC_IAKONI_TAG),
        ["name"] = L(AC_IAKONI_CATEGORY_SET_6),
        ["description"] = L(AC_IAKONI_CATEGORY_SET_6_DESC),
    },
    {
        ["rule"] = "setindex(7)",
        ["tag"] = L(AC_IAKONI_TAG),
        ["name"] = L(AC_IAKONI_CATEGORY_SET_7),
        ["description"] = L(AC_IAKONI_CATEGORY_SET_7_DESC),
    },
    {
        ["rule"] = "setindex(8)",
        ["tag"] = L(AC_IAKONI_TAG),
        ["name"] = L(AC_IAKONI_CATEGORY_SET_8),
        ["description"] = L(AC_IAKONI_CATEGORY_SET_8_DESC),
    },
    {
        ["rule"] = "setindex(9)",
        ["tag"] = L(AC_IAKONI_TAG),
        ["name"] = L(AC_IAKONI_CATEGORY_SET_9),
        ["description"] = L(AC_IAKONI_CATEGORY_SET_9_DESC),
    },
    {
        ["rule"] = "setindex(10)",
        ["tag"] = L(AC_IAKONI_TAG),
        ["name"] = L(AC_IAKONI_CATEGORY_SET_10),
        ["description"] = L(AC_IAKONI_CATEGORY_SET_10_DESC),
    },
}

-- hook for GearChangerByIakoni
local function GearChangerByIakoni_DoRefresh(list)
    local a=GearChangerByIakoni.savedVariables.ArraySet
    local b=GearChangerByIakoni.savedVariables.ArraySetSavedFlag

    --loop through the currently shown inventory items
    for _,v in pairs(list.activeControls) do
        local bag = v.dataEntry.data.bagId
        local slot = v.dataEntry.data.slotIndex
        if bag ~= nil and slot ~= nil then
            local itemID = Id64ToString(GetItemUniqueId(bag, slot))
            local marker = v:GetNamedChild("GCBISet")
            if not marker then
                marker = GearChangerByIakoni.CreateControlMarker(v)
            end
            marker:SetHidden(true)
            
            local itemType = GetItemType(bag, slot)
            if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON then
                local founditem = false

                for i=1, 10 do
                    if b[i] == 1 then --check only if the set is saved
                        for _,u in pairs(GearChangerByIakoni.WornArray) do
                            if itemID==a[i][u] then
                                marker:SetHidden(false)
                                founditem = true
                                break
                            end
                        end
                    end
                    
                    if founditem then
                        break
                    end
                end
            end
        end 
    end 
end

--Initialize plugin for Auto Category - Iakoni's Gear Changer

-- separated out to allow for offline testing since localization_strings is local
function AutoCategory_Iakoni.LoadLanguage(defaultlang)
    if defaultlang == nil then defaultlang = "en" end
    
    -- initialize strings
    AutoCategory.LoadLanguage(localization_strings,"en")
end

function AutoCategory_Iakoni.Initialize()
	if not GearChangerByIakoni then
        AutoCategory.AddRuleFunc("setindex", AutoCategory.dummyRuleFunc)
        AutoCategory.AddRuleFunc("inset", AutoCategory.dummyRuleFunc)
        return
    end
    
    -- reinitialize strings
    AutoCategory.LoadLanguage(localization_strings,"en")
    
    -- load predefinedRules
    AutoCategory.AddPredefinedRules(AutoCategory_Iakoni.predefinedRules)
    
    -- load supporting rule functions
    AutoCategory.AddRuleFunc("setindex", AutoCategory_Iakoni.RuleFunc.SetIndex)
    AutoCategory.AddRuleFunc("inset", AutoCategory_Iakoni.RuleFunc.InSet)
    
    -- hook into GearChangerByIakoni addon
    GearChangerByIakoni.DoRefresh = GearChangerByIakoni_DoRefresh
end

local function IokaniGearChanger_GetGearSet(bagId, slotIndex)
	local result = {}
	if GearChangerByIakoni and GearChangerByIakoni.savedVariables then
		local itemType = GetItemType(bagId, slotIndex)
		if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON then
			local a=GearChangerByIakoni.savedVariables.ArraySet
			local b=GearChangerByIakoni.savedVariables.ArraySetSavedFlag
			local itemID = Id64ToString(GetItemUniqueId(bagId, slotIndex))
			for i=1, 10 do
				if b[i] == 1 then --check only if the set is saved
					for _,u in pairs(GearChangerByIakoni.WornArray) do
						if itemID==a[i][u] then
							--find gear in set i
							table.insert(result, i)
						end
					end
				end
			end	
		end
	end
	return result
end

-- Implement the GearChanger setindex() check function for rules
function AutoCategory_Iakoni.RuleFunc.SetIndex( ... )
	if not GearChangerByIakoni then return false end
    
	local fn = "setindex"
	local ac = select( '#', ... )
	if ac == 0 then
		error( string.format("error: %s(): require arguments." , fn))
	end
	
	local setIndices = IakoniGearChanger_GetGearSet(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
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
		for i=1, #setIndices do
			local index = setIndices[i]
			if comIndex == index then
				return true
			end
		end 
	end
	
	return false 
end

-- Implement the GearChanger inset() check function for rules
function AutoCategory_Iakoni.RuleFunc.InSet( ... )
	local fn = "inset"
	if not GearChangerByIakoni then return false end
	
	local setIndices = IakoniGearChanger_GetGearSet(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
	return #setIndices ~= 0
end


AutoCategory.RegisterPlugin("IakoniGearChanger", AutoCategory_Iakoni.Initialize)