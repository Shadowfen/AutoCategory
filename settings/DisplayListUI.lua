-- 
local AC = AutoCategory
local SF = LibSFUtils

local aclogger = AutoCategory.logger

AC_UI.BagSet_DisplayCat_LAM = AC.BaseUI:New()

AC_UI.BagSet_DisplayCat_LAM.dsplistEntries = {
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


-- customization of BaseUI for BagSet_DisplayCat_LAM Button
-- ----------------------------------------------------------
function AC_UI.BagSet_DisplayCat_LAM:loadList()

	local bagId = AC_UI.BagSet_SelectBag_LAM:getValue()
	AutoCategory.acctSaved.displayName = SF.safeTable(AutoCategory.acctSaved.displayName)
	AutoCategory.charSaved.displayName = SF.safeTable(AutoCategory.charSaved.displayName)
	AutoCategory.saved.displayName = SF.safeTable(AutoCategory.saved.displayName)
	if next(AutoCategory.saved.displayName) then
		self.dsplistEntries = SF.safeTable(AutoCategory.saved.displayOrder[bagId])
	else
		self.dsplistEntries = {}
		local u = 1
		local tentry = {}
		local nentry = {}
		local tbl = {}
		local ntbl = {}
		for i, v in pairs(AutoCategory.cache.entriesByBag[bagId].choicesValues) do
			tentry = { 
				value = tostring(v), 
				text = tostring(v), 
				uniqueKey = u,
			}
			table.insert(tbl, tentry )
			nentry = {
				uniqueKey = u,
				showpri = #tbl,
			}
			ntbl[tostring(v)] = nentry
			u = u + 1
		end
		self.dsplistEntries = tbl
		if AutoCategory.charSaved.accountWide then
			AutoCategory.acctSaved.displayOrder[bagId] = self.dsplistEntries
			AutoCategory.acctSaved.displayName[bagId] = ntbl
		else
			AutoCategory.charSaved.displayOrder[bagId] = self.dsplistEntries
			AutoCategory.charSaved.displayName[bagId] = ntbl
		end
		AutoCategory.saved.displayOrder[bagId] = self.dsplistEntries
		AutoCategory.saved.displayName[bagId] = ntbl
	end
	return self.dsplistEntries
end

function AC_UI.BagSet_DisplayCat_LAM:controlDef()
	-- Display the order to show the categories in
	return
		{
			type = "orderlistbox",
			name = "Categories in display order",
			tooltip = "List of categories for this bag that are listed in the order that you want them shown in. Others will always be last and cannot be moved.",
			listEntries = self:loadList(), --self.dsplistEntries,
			rowMaxLineCount = 10,
			getFunc = function() return self.dsplistEntries end,
			setFunc = function(dispListEntries)         
				--settings.iconSortOrderEntries = dispListEntries
				for idx, data in pairs(dispListEntries) do
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
			showRemoveEntryButton = true, -- or function returning a boolean (optional). Show a button to remove the currently selected entry
			askBeforeRemoveEntry = true, -- or function returning a boolean (optional). If showRemoveEntryButton is enabled: Ask via a dialog if the entry should be removed
			--removeEntryCheckFunction = function(orderListBox, selectedIndex, orderListBoxData) return true end, -- (optional) function returning a boolean (true = remove, false = keep) if the entry can be removed or not
			removeEntryCallbackFunction = function(orderListBox, selectedEntry, orderListBoxData) return true end, -- (optional) function returning a boolean (true = removed, false = not removed) called as the entry get's removed,
			--disabled = function() return false end, -- or boolean (optional)
			requiresReload = false, -- boolean, if set to true, the warning text will contain a notice that changes are only applied after an UI reload and any change to the value will make the "Apply Settings" button appear on the panel which will reload the UI when pressed (optional)
			--default = defaults.var, -- function that returns the execution order as the default value (optional)
			reference = "BagSet_DisplayCat_LAM" -- function returning String, or String unique global reference to control (optional)
		}

end

-- ----------------------------------------------------------

function AC_UI.DisplayListInit()
	aclogger = AutoCategory.logger

end


