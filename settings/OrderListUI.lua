-- 
local AC = AutoCategory
local SF = LibSFUtils

local aclogger

AC_UI.BagSet_OrderCat_LAM = AC.BaseUI:New()

-- customization of BaseUI for BagSet_OrderCat_LAM Button
-- ----------------------------------------------------------
function AC_UI.BagSet_OrderCat_LAM:loadList(contentlist)

end

local tmplistEntries = {
	[1] = {
		value = "!!!",
		uniqueKey = 1,
		text  = "Text of this entry",
	},
	[2] = {
		value = "222",
		uniqueKey = 2,
		text  = "Text2 of this entry",
	}
}


function AC_UI.BagSet_OrderCat_LAM:controlDef()
	-- Remove Category from Bag Button
	return
		{
			type = "orderlistbox",
			name = "Categories in execution order",
			tooltip = "List of categories for this bag that are listed in the order that they are run in.",
			listEntries = tmplistEntries,
			rowMaxLineCount = 10,
			getFunc = function() return tmplistEntries end,
			setFunc = function(sortedSortListEntries)         
				--settings.iconSortOrderEntries = sortedSortListEntries
				for idx, data in ipairs(sortedSortListEntries) do
					--settings.icon[data.value].sortOrder = idx
					--settings.iconSortOrder[idx] = data.value
					end
				end,
			minHeight = 300,
			maxHeight = 500,
			width = "full",
			isExtraWide = true,
			rowHeight = 18,
			rowSelectedCallback = function(rowControl, previouslySelectedData, selectedData, reselectingDuringRebuild) end,
			disableDrag = false, -- or function returning a boolean (optional). Disable the drag&drop of the rows
			disableButtons = false, -- or function returning a boolean (optional). 
								-- Disable the move up/move down/move to top/move to bottom buttons
			showPosition = false, -- or function returning a boolean (optional). 
								-- Show the position number in front of the list entry

			showValue = true, -- or function returning a boolean (optional). 
							-- Show the value of the entry after the list entry text, surrounded by []
			--disabled = function() return false end, -- or boolean (optional)
			requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			--default = defaults.var, -- default value or function that returns the default value (optional)
			reference = "BagSet_OrderCat_LAM" -- function returning String, or String unique global reference to control (optional)
		}

end

-- ----------------------------------------------------------

function AC_UI.OrderListInit()
	aclogger = AutoCategory.logger

end
