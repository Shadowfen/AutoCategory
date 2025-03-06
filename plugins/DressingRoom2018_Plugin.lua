AutoCategory_DressingRm = {
    RuleFunc = {},
}

-- language strings
-- The default language set of strings must contain ALL of the string definitions for the plugin.
-- For other language sets here, if a string is not defined then the english version is used
-- For any language that is not supported (i.e. not here), "en" is used.
--local localization_strings = {
--    en = {
--    },
--}

-- must load strings before we define the rules that use them
--AutoCategory.LoadLanguage(localization_strings,"en")

AutoCategory_DressingRm.predefinedRules = {
}

--Initialize plugin for AutoCategory - DressingRoom 2018
function AutoCategory_DressingRm.Initialize()
	if DressingRoom == nil then
        AutoCategory.AddRuleFunc("drm_inset", AutoCategory.dummyRuleFunc)
        return
    end
	AutoCategory.logger:Warn("Initializing DressingRoom 2018 plugin integration")

    -- initialize strings
--    AutoCategory_DressingRm.LoadLanguage("en")

    -- load supporting rule functions
    AutoCategory.AddRuleFunc("drm_inset", AutoCategory_DressingRm.RuleFunc.InSet)
end

function AutoCategory_DressingRm.RuleFunc.InSet( ... )
	local fn = "drm_inset"
	if DressingRoom == nil then
		return false
	end

    local args = {...}
    local gearSet = DressingRoom.sv.gearSet

    if #args == 0 then
        -- TODO
        for i, _ in ipairs(gearSet) do
            args[i] = i
        end
    end

    for _, set in ipairs(args) do
        if type(set) ~= "number" then
            error(string.format("error: drm_inset: argument must be a number"))
        end

        if set <= #gearSet then
            local itemId = GetItemUniqueId(AutoCategory.checkingItemBagId, AutoCategory.checkingItemSlotIndex)
            for item, _ in pairs(gearSet[set]) do
                if item == Id64ToString(itemId) then
                    return true
                end
            end
        end
    end
    return false

end
-----

AutoCategory.RegisterPlugin("DressingRoom2018", 
        AutoCategory_DressingRm.Initialize, AutoCategory_DressingRm.predefinedRules)
