local AC = AutoCategory
local SF = LibSFUtils
local LMP = LibMediaProvider

local L = GetString

local dropdownFontStyle	= {
	'none', 'outline', 'thin-outline', 'thick-outline',
	'shadow', 'soft-shadow-thin', 'soft-shadow-thick',
}

local dropdownFontAlignment = {}
dropdownFontAlignment.choices = {
	L(SI_AC_ALIGNMENT_LEFT),
	L(SI_AC_ALIGNMENT_CENTER),
	L(SI_AC_ALIGNMENT_RIGHT)
}
dropdownFontAlignment.choicesValues = {0, 1, 2}



local function divider()
	return {
		type = "divider",
		width = "full", --or "half" (optional)
		height = 10,
		alpha = 0.5,
	}
end

local function description(textId, titleId)
	return
		{
			type = "description",
			text = textId, -- text or string id or function returning a string
			title = titleId, -- or string id or function returning a string (optional)
			width = "full", --or "half" (optional)
		}
end


AC_UI.AppearanceMenu = {
    type = "submenu",
    name = SI_AC_MENU_SUBMENU_APPEARANCE_SETTING,
    reference = "AC_SUBMENU_APPEARANCE_SETTING",
    controls = {
        description(SF.ColorText(L(SI_AC_MENU_AS_DESCRIPTION_REFRESH_TIP), SF.hex.mocassin)),
        
        divider(),

        -- Category Text Font
        {
            type = 'dropdown',
            name = SI_AC_MENU_EC_DROPDOWN_CATEGORY_TEXT_FONT,
            choices = LMP:List('font'),
            getFunc = function()
                return AutoCategory.saved.appearance["CATEGORY_FONT_NAME"]
            end,
            setFunc = function(v)
                AutoCategory.saved.appearance["CATEGORY_FONT_NAME"] = v
                AutoCategory.resetface()
            end,
            scrollable = 7,
        },

        -- Category Text Style
        {
            type = 'dropdown',
            name = SI_AC_MENU_EC_DROPDOWN_CATEGORY_TEXT_STYLE,
            choices = dropdownFontStyle,
            getFunc = function()
                return AutoCategory.saved.appearance["CATEGORY_FONT_STYLE"]
            end,
            setFunc = function(v)
                AutoCategory.saved.appearance["CATEGORY_FONT_STYLE"] = v
            end,
            scrollable = 7,
        },

        -- Category Text Alignment
        {
            type = 'dropdown',
            name = SI_AC_MENU_EC_DROPDOWN_CATEGORY_TEXT_ALIGNMENT,
            choices = dropdownFontAlignment.choices,
            choicesValues = dropdownFontAlignment.choicesValues,
            getFunc = function()
                return AutoCategory.saved.appearance["CATEGORY_FONT_ALIGNMENT"]
            end,
            setFunc = function(v)
                AutoCategory.saved.appearance["CATEGORY_FONT_ALIGNMENT"] = v
            end,
            scrollable = 7,
        },

        -- Category Text Font Size
        {
            type = 'slider',
            name = SI_AC_MENU_EC_DROPDOWN_CATEGORY_TEXT_FONT_SIZE,
            min = 8,
            max = 32,
            getFunc = function()
                return AutoCategory.saved.appearance["CATEGORY_FONT_SIZE"]
            end,
            setFunc = function(v)
                AutoCategory.saved.appearance["CATEGORY_FONT_SIZE"] = v
            end,
        },

        -- Category Text Color
        {
            type = 'colorpicker',
            name = SI_AC_MENU_EC_DROPDOWN_CATEGORY_TEXT_COLOR,
            getFunc = function()
                return unpack(AutoCategory.saved.appearance["CATEGORY_FONT_COLOR"])
            end,
            setFunc = function(r, g, b, a)
                AutoCategory.saved.appearance["CATEGORY_FONT_COLOR"][1] = r
                AutoCategory.saved.appearance["CATEGORY_FONT_COLOR"][2] = g
                AutoCategory.saved.appearance["CATEGORY_FONT_COLOR"][3] = b
                AutoCategory.saved.appearance["CATEGORY_FONT_COLOR"][4] = a
            end,
            widgetRightAlign		= true,
            widgetPositionAndResize	= -15,
        },

        -- Hidden Category Text Color
        {
            type = 'colorpicker',
            name = SI_AC_MENU_EC_DROPDOWN_HIDDEN_CATEGORY_TEXT_COLOR,
            getFunc = function()
                return unpack(AutoCategory.saved.appearance["HIDDEN_CATEGORY_FONT_COLOR"])
            end,
            setFunc = function(r, g, b, a)
                AutoCategory.saved.appearance["HIDDEN_CATEGORY_FONT_COLOR"][1] = r
                AutoCategory.saved.appearance["HIDDEN_CATEGORY_FONT_COLOR"][2] = g
                AutoCategory.saved.appearance["HIDDEN_CATEGORY_FONT_COLOR"][3] = b
                AutoCategory.saved.appearance["HIDDEN_CATEGORY_FONT_COLOR"][4] = a
            end,
            widgetRightAlign		= true,
            widgetPositionAndResize	= -15,
        },

        -- Category Ungrouped Title EditBox
        {
            type = "editbox",
            name = SI_AC_MENU_EC_EDITBOX_CATEGORY_UNGROUPED_TITLE,
            tooltip = SI_AC_MENU_EC_EDITBOX_CATEGORY_UNGROUPED_TITLE_TOOLTIP,
            getFunc = function()
                return AutoCategory.saved.appearance["CATEGORY_OTHER_TEXT"]
            end,
            setFunc = function(value) AutoCategory.saved.appearance["CATEGORY_OTHER_TEXT"] = value end,
            width = "full",
        },

        -- Category Header Height
        {
            type = 'slider',
            name = SI_AC_MENU_EC_SLIDER_CATEGORY_HEADER_HEIGHT,
            min = 1,
            max = 100,
            requiresReload = true,
            getFunc = function()
                return AutoCategory.saved.appearance["CATEGORY_HEADER_HEIGHT"]
            end,
            setFunc = function(v)
                AutoCategory.saved.appearance["CATEGORY_HEADER_HEIGHT"] = v
            end,
            warning = SI_AC_WARNING_NEED_RELOAD_UI,
        },
    },
}