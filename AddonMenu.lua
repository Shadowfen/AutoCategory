-- aliases
local LAM = LibAddonMenu2
local SF = LibSFUtils


local auBagSet = AC_UI.BagSet
local auCatSet = AC_UI.CatSet
local auAppearanceMenu = AC_UI.AppearanceMenu

-- -------------------------------------------------------
-- function aliases
local divider = AC_UI.divider

-- -------------------------------------------------------

--local currentRule = AutoCategory.CreateNewRule("","")


local AddCat_SelectTag_LAM = AC_UI.AddCat_SelectTag_LAM

local warningDuplicatedName = AC_UI.warningDuplicatedName


local function UpdateDuplicateNameWarning()
	local control = WINDOW_MANAGER:GetControlByName("AC_EDITBOX_EDITRULE_NAME", "")
	if control then
		control:UpdateWarning()
	end
end

-- -------------------------------------------------------
-- Call refresh() on all BaseDD controls
function AC_UI.RefreshDropdownData()

	auBagSet.refresh()
	auCatSet.refresh()
end

-- updates the LAM cvt lists from our BaseDD objects
local RCPending = false
function AC_UI.RefreshControls()
	local waitTime = 500
	if RCPending then return end

	RCPending = true

	zo_callLater(function()
		auBagSet.updateControls()
		auCatSet.updateControls()
		RCPending = false
	end, waitTime)
end


-- ------------------------------------------------------

local function RefreshPanel()
	UpdateDuplicateNameWarning()

	--restore warning
	warningDuplicatedName.warningMessage = nil

end

-- increase the size of the editbox for a rule definition
local doneOnce = false
function AutoCategory.LengthenRuleBox()
	local lines = 10
	if doneOnce then return true end
	-- change lines
	local MIN_HEIGHT = 24
	local control = WINDOW_MANAGER:GetControlByName("AC_EDITBOX_EDITRULE_RULE", "")
	if control == nil or control.container == nil then return false end

	doneOnce = true
	local container = control.container

	container:SetHeight(MIN_HEIGHT * lines)
	control:SetHeight((MIN_HEIGHT * lines) + control.label:GetHeight())

	return true
end

function AC_UI.ToggleSubmenu(typeString, open)
	local control = WINDOW_MANAGER:GetControlByName(typeString, "")
	if control then
		control.open = open
		if control.open then
			control.animation:PlayFromStart()

		else
			control.animation:PlayFromEnd()
		end
	end
end


-- -------------------------------------------------------
local function CreatePanel()
	return {
		type = "panel",
		name = AutoCategory.settingName,
		displayName = AutoCategory.settingDisplayName,
		author = AutoCategory.author,
		version = AutoCategory.version,
        slashCommand = "/ac",
		registerForRefresh = true,
		registerForDefaults = true,
		resetFunc = function()
			AutoCategory.ResetToDefaults()
			AutoCategory.UpdateCurrentSavedVars()	-- needed if swap acctwide on/off
			AutoCategory.cacheInitialize()

			auBagSet.clear()
			auCatSet.clear()

			AC_UI.RefreshDropdownData()
			AC_UI.RefreshControls()
		end,
	}
end


function AutoCategory.debugBagTags()
	AddCat_SelectTag_LAM:assign( { choices=AutoCategory.RulesW.tags })
	d("AddCat_SelectTag_LAM:")
	for k, v in pairs(AddCat_SelectTag_LAM.cvt.choices) do
		if type(v) == "table" then
			for k1,v1 in pairs(v) do
				d("k = "..k.."   k1="..k1.."  v1="..SF.str(v1))
			end
		else
		    d("k = "..k.." v= "..SF.str(v))
		end
	end
end


function AutoCategory.AddonMenu_Init()
    AutoCategory.cacheInitialize()

	AC_UI.BagSet.Init()
	AC_UI.DspWin_Init()
	AC_UI.CatSet_Init()
	AC_UI.AppearanceMenu_Init()

	AC_UI.RefreshDropdownData()
	AC_UI.RefreshControls()

	local panelData = CreatePanel()


	local optionsTable = {
        -- Account Wide
        {
            type = "checkbox",
            name = SI_AC_MENU_BS_CHECKBOX_ACCOUNT_WIDE_SETTING,
            tooltip = SI_AC_MENU_BS_CHECKBOX_ACCOUNT_WIDE_SETTING_TOOLTIP,
            getFunc = function()
                return AutoCategory.charSaved.accountWide
            end,
            setFunc = function(value)
                AutoCategory.charSaved.accountWide = value
                AutoCategory.UpdateCurrentSavedVars()	-- needed if swap acctwide on/off

				auBagSet.clear()
				auCatSet.clear()

                AC_UI.RefreshDropdownData()
				AC_UI.RefreshControls()
            end,
        },
        divider(),
		-- Bag Settings
		auBagSet.controlDef(),

        -- Category Settings
		auCatSet.controlDef(),

        -- General Settings
		AC_UI.GeneralMenu,

        -- Appearance Settings
		auAppearanceMenu.controlDef(),		

		-- Gamepad settings
		AC_UI.GamepadMenu,

	}
    if not LAM then return end
	LAM:RegisterAddonPanel("AC_CATEGORY_SETTINGS", panelData)
	LAM:RegisterOptionControls("AC_CATEGORY_SETTINGS", optionsTable)
	CALLBACK_MANAGER:RegisterCallback("LAM-RefreshPanel", RefreshPanel)
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", AutoCategory.LengthenRuleBox)
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", function() 
		AutoCategory.dspWin:SetHidden(true)
	end)
end