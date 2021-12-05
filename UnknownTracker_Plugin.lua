-- A simple plugin for Unknown Tracker
--

AutoCategory_UnknownTracker = {
    RuleFunc = {},
}

-- language strings
-- The default language set of strings must contain ALL of the string definitions for the plugin.
-- For other language sets here, if a string is not defined then the english version is used
-- For any language that is not supported (i.e. not here), "en" is used.
local localization_strings = {
    en = {
        SI_AC_DEFAULT_CATEGORY_UT_ALL_UNKNOWN = "Unknown to someone",
        SI_AC_DEFAULT_CATEGORY_UT_ALL_UNKNOWN_DESC = "All recipes, motifs, outfit styles, etc that are not known by all toons",
        SI_AC_DEFAULT_CATEGORY_UT_RECIPE_UNKNOWN = "Unknown Recipes",
        SI_AC_DEFAULT_CATEGORY_UT_RECIPE_UNKNOWN_DESC = "Unknown Food and Drink Recipes",
        SI_AC_DEFAULT_CATEGORY_UT_FURNISHING_UNKNOWN = "Unknown Furnishing Recipes",
        SI_AC_DEFAULT_CATEGORY_UT_FURNISHING_UNKNOWN_DESC = "Unknown Furnishing Recipes of all types",
        SI_AC_DEFAULT_CATEGORY_UT_MOTIF_UNKNOWN = "Unknown Motifs",
        SI_AC_DEFAULT_CATEGORY_UT_MOTIF_UNKNOWN_DESC = "Unknown Motifs",
        SI_AC_DEFAULT_CATEGORY_UT_STYLE_UNKNOWN = "Unknown Outfit Styles",
        SI_AC_DEFAULT_CATEGORY_UT_STYLE_UNKNOWN_DESC = "Unknown Outfit Styles",
        
        SI_AC_DEFAULT_CATEGORY_UT_UNKNOWN_TO_ME = "Unknown to Me",
        SI_AC_DEFAULT_CATEGORY_UT_UNKNOWN_TO_ME_DESC = "All recipes, motifs, outfit styles, etc that are not known by the current toon",
    },
}
-- must load strings before we define the rules that use them
AutoCategory.LoadLanguage(localization_strings,"en")

local L = GetString

AutoCategory_UnknownTracker.predefinedRules = {
    {
        ["tag"] = "UnknownTracker",
        ["rule"] = "isUnknown()",
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_UT_ALL_UNKNOWN_DESC),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_UT_ALL_UNKNOWN),
    },
    {
        ["tag"] = "UnknownTracker",
        ["rule"] = "isUnknown(\"me\")",
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_UT_UNKNOWN_TO_ME_DESC),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_UT_UNKNOWN_TO_ME),
    },
    {
        ["tag"] = "UnknownTracker",
        ["rule"] = "isRecipeUnknown()",
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_UT_RECIPE_UNKNOWN_DESC),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_UT_RECIPE_UNKNOWN),
    },
    {
        ["tag"] = "UnknownTracker",
        ["rule"] = "isMotifUnknown()",
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_UT_MOTIF_UNKNOWN_DESC),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_UT_MOTIF_UNKNOWN),
    },
    {
        ["tag"] = "UnknownTracker",
        ["rule"] = "isFurnishingUnknown()",
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_UT_FURNISHING_UNKNOWN_DESC),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_UT_FURNISHING_UNKNOWN),
    },
    {
        ["tag"] = "UnknownTracker",
        ["rule"] = "isStyleUnknown()",
        ["description"] = L(SI_AC_DEFAULT_CATEGORY_UT_STYLE_UNKNOWN_DESC),
        ["name"] = L(SI_AC_DEFAULT_CATEGORY_UT_STYLE_UNKNOWN),
    },
}

-- separated out to allow for offline testing since localization_strings is local
function AutoCategory_UnknownTracker.LoadLanguage(defaultlang)
    if defaultlang == nil then defaultlang = "en" end
    
    -- initialize strings
    AutoCategory.LoadLanguage(localization_strings,"en")
end

--Initialize plugin for Auto Category - Unknown Tracker
function AutoCategory_UnknownTracker.Initialize()
	if not UnknownTracker then
        AutoCategory.AddRuleFunc("isunknown", AutoCategory.dummyRuleFunc)
        AutoCategory.AddRuleFunc("isrecipeunknown", AutoCategory.dummyRuleFunc)
        AutoCategory.AddRuleFunc("isfurnishingunknown", AutoCategory.dummyRuleFunc)
        AutoCategory.AddRuleFunc("ismotifunknown", AutoCategory.dummyRuleFunc)
        AutoCategory.AddRuleFunc("isstyleunknown", AutoCategory.dummyRuleFunc)
        return
    end
    
    -- load predefinedRules
    AutoCategory.AddPredefinedRules(AutoCategory_UnknownTracker.predefinedRules)

    -- load supporting rule functions
    AutoCategory.AddRuleFunc("isunknown", AutoCategory_UnknownTracker.RuleFunc.UT_IsUnknown)
    AutoCategory.AddRuleFunc("isrecipeunknown", AutoCategory_UnknownTracker.RuleFunc.UT_IsRecipeUnknown)
    AutoCategory.AddRuleFunc("isfurnishingunknown", AutoCategory_UnknownTracker.RuleFunc.UT_IsFurnishingUnknown)
    AutoCategory.AddRuleFunc("ismotifunknown", AutoCategory_UnknownTracker.RuleFunc.UT_IsMotifUnknown)
    AutoCategory.AddRuleFunc("isstyleunknown", AutoCategory_UnknownTracker.RuleFunc.UT_IsStyleUnknown)
    
end

local valid_itemtypes = {
  [ITEMTYPE_RACIAL_STYLE_MOTIF] = true,
  [ITEMTYPE_RECIPE] = true,
  [ITEMTYPE_CONTAINER] = true,      -- problem here there are some containers we are not interested in
  [ITEMTYPE_COLLECTIBLE] = true,	-- there are lots of collectibles we are not interested in
}

local function lookupItem(itemLink, characters)
	if UnknownTracker == nil then return false end
	
    -- find out who knows the item
    local isvalid, knownlist = UnknownTracker:IsValidAndWhoKnowsIt(itemLink)
    if not isvalid then
        -- not a real item
        return false 
    end
    --d("item "..itemLink)
    --d("characters")
    --d(characters)
    if not knownlist then 
        -- noone knows it
        return true 
    end
    --d("knownby")
    --d(knownlist)
    -- find out who doesn't know it
    if not knownlist or not next(knownlist) then
        return true
    end
    local allchars,allacct = UnknownTracker:GetCharacterList()
    local fst = next(knownlist)
    local unknowers
    if "@" == string.sub(fst,1,1) then
        --looking for account names
        unknowers = UnknownTracker:RemainsList(allacct, knownlist)
    else    
        unknowers = UnknownTracker:RemainsList(allchars, knownlist)
    end
    --d("unknowers")
    --d(unknowers)
    if not next(unknowers) then
        -- everyone knows it
        return false
    end
    if next(characters) == nil then
        -- not looking for particular character
        return true
    end
    
    -- check against parameter list of toon names
    -- looking for specific toons that don't know
    for charname,v in pairs(unknowers) do
        if characters[charname] ~= nil then
            -- we were looking for toon that does not know
            return true
        end
    end
    -- everyone in our parameter list knows
    return false	
end

local function getCharList(...)
	local ac = select( '#', ... ) 
	local characters = {}
	for ax = 1, ac do
		
		local arg = select( ax, ... )
		if not arg then
            break
		end
        if arg == "me" then
            characters[zo_strformat("<<1>>", GetRawUnitName("player"))] = true
        else
            characters[arg]=true
        end
	end
    return characters
end

-- Implement isunknown() check function for UnknownTracker
function AutoCategory_UnknownTracker.RuleFunc.UT_IsUnknown( ... )
	local fn = "isunknown"
	if UnknownTracker == nil then return false end
	
    local isunknown = false
    local characters = getCharList(...)
    
    -- find out who knows it (if UT display setting is true)
    local itemLink = GetItemLink(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
    if not itemLink then return false end
	
	-- it is an item that can be learned
    local itemType,sptype = GetItemLinkItemType(itemLink)
    local islearnable = false
	--if itemType == ITEMTYPE_COLLECTIBLE and sptype == SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE then
    --    return lookupItem(itemLink, characters)
	--end
	if valid_itemtypes[itemType] == true then
        islearnable = true
    end
    if not islearnable then return false end
	
    return lookupItem(itemLink, characters)
end

function AutoCategory_UnknownTracker.RuleFunc.UT_IsRecipeUnknown( ... )
	local fn = "isrecipeunknown"
	if UnknownTracker == nil then return false end
	
    local isunknown = false
    -- who is supposed to know it?
    local characters = getCharList(...)
    
    -- are we interested in the item?
    local itemLink = GetItemLink(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
    if not itemLink then return false end
    local itemType, sptype = GetItemLinkItemType(itemLink)
    if itemType ~= ITEMTYPE_RECIPE then return false end
    if sptype ~= SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_DRINK
        and sptype ~= SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_STANDARD_FOOD then return false end

    -- return true if characters don't know this one
    return lookupItem(itemLink, characters)
end

function AutoCategory_UnknownTracker.RuleFunc.UT_IsMotifUnknown( ... )
	local fn = "ismotifunknown"
	if UnknownTracker == nil then return false end
	
    local isunknown = false
    -- who is supposed to know it?
    local characters = getCharList(...)
    
    -- are we interested in the item?
    local itemLink = GetItemLink(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
    if not itemLink then return false end
    local itemType, sptype = GetItemLinkItemType(itemLink)
    if itemType ~= ITEMTYPE_RACIAL_STYLE_MOTIF then return false end
    if sptype ~= SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_CHAPTER
        and sptype ~= SPECIALIZED_ITEMTYPE_RACIAL_STYLE_MOTIF_BOOK then 
            return false 
    end

    -- return true if characters don't know this one
    return lookupItem(itemLink, characters)
end

local valid_furnishingTypes = {
  [SPECIALIZED_ITEMTYPE_RECIPE_ALCHEMY_FORMULA_FURNISHING] = true,
  [SPECIALIZED_ITEMTYPE_RECIPE_BLACKSMITHING_DIAGRAM_FURNISHING] = true,
  [SPECIALIZED_ITEMTYPE_RECIPE_CLOTHIER_PATTERN_FURNISHING] = true,
  [SPECIALIZED_ITEMTYPE_RECIPE_ENCHANTING_SCHEMATIC_FURNISHING] = true,
  [SPECIALIZED_ITEMTYPE_RECIPE_JEWELRYCRAFTING_SKETCH_FURNISHING] = true,
  [SPECIALIZED_ITEMTYPE_RECIPE_PROVISIONING_DESIGN_FURNISHING] = true,
  [SPECIALIZED_ITEMTYPE_RECIPE_WOODWORKING_BLUEPRINT_FURNISHING] = true,
}

function AutoCategory_UnknownTracker.RuleFunc.UT_IsFurnishingUnknown( ... )
	local fn = "isfurnishingunknown"
	if UnknownTracker == nil then return false end
	
    local isunknown = false
    -- who is supposed to know it?
    local characters = getCharList(...)
    
    -- are we interested in the item?
    local itemLink = GetItemLink(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
    if not itemLink then return false end
	
    local itemType, sptype = GetItemLinkItemType(itemLink)
    if itemType ~= ITEMTYPE_RECIPE then return false end
    if not valid_furnishingTypes[sptype]then return false end

    -- return true if characters don't know this one
    return lookupItem(itemLink, characters)
end

function AutoCategory_UnknownTracker.RuleFunc.UT_IsStyleUnknown( ... )
	local fn = "isstyleunknown"
	if UnknownTracker == nil then return false end
	
    local isunknown = false
    -- who is supposed to know it?
    local characters = getCharList(...)
    
    -- are we interested in the item?
    local itemLink = GetItemLink(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
    if not itemLink then return false end
    local itemType, sptype = GetItemLinkItemType(itemLink)
    if sptype ~= SPECIALIZED_ITEMTYPE_COLLECTIBLE_STYLE_PAGE then return false end

    -- return true if characters don't know this one
    return lookupItem(itemLink, characters)
end



-- Register this plugin with AutoCategory to be initialized and used when AutoCategory loads.
AutoCategory.RegisterPlugin("UnknownTracker", AutoCategory_UnknownTracker.Initialize)