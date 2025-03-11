AC = AutoCategory
SF = LibSFUtils

local L = GetString

local divider = AC_UI.divider
--[[
local function divider()
	return {
		type = "divider",
		width = "full", --or "half" (optional)
		height = 10,
		alpha = 0.5,
	}
end
--]]

local description = AC_UI.description
--[[
local function description(textId, titleId)
	return
		{
			type = "description",
			text = textId, -- text or string id or function returning a string
			title = titleId, -- or string id or function returning a string (optional)
			width = "full", --or "half" (optional)
		}
end
--]]



AC_UI.GamepadMenu = {
    type = "submenu",
    name = SI_AC_MENU_SUBMENU_GAMEPAD_SETTING,
    reference = "AC_SUBMENU_GAMEPAD_SETTING",
    controls = {
        description(SF.ColorText(L(SI_AC_MENU_GMS_DESCRIPTION_TIP), SF.hex.mocassin)),
        divider(),

        {
            type = "checkbox",
            name = SI_AC_MENU_GMS_CHECKBOX_ENABLE_GAMEPAD,
            tooltip = SI_AC_MENU_GMS_CHECKBOX_ENABLE_GAMEPAD_TOOLTIP,
            requiresReload = true,
            getFunc = function() return AutoCategory.saved.general["ENABLE_GAMEPAD"] end,
            setFunc = function(value) AutoCategory.saved.general["ENABLE_GAMEPAD"] = value end,
        },

        {
            type = "checkbox",
            name = SI_AC_MENU_GMS_CHECKBOX_EXTENDED_GAMEPAD_SUPPLIES,
            tooltip = SI_AC_MENU_GMS_CHECKBOX_EXTENDED_GAMEPAD_SUPPLIES_TOOLTIP,
            requiresReload = false,
            getFunc = function() return AutoCategory.saved.general["EXTENDED_GAMEPAD_SUPPLIES"] end,
            setFunc = function(value) AutoCategory.saved.general["EXTENDED_GAMEPAD_SUPPLIES"] = value end,
            disabled = function() return AutoCategory.saved.general["ENABLE_GAMEPAD"] == false end,
        },
    },
}