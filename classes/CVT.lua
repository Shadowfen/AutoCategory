local L = GetString
local SF = LibSFUtils

local logDebug = AutoCategory.logDebug

-- -------------------------------------------------------
-- The CVT class manages the choices, choicesValues, and
-- choicesTooltips list for a particular dropdown control.
--
-- Note that the choices, choicesValues, and choicesTooltips
-- are 1-based contiguous lists (or possibly nil for values
-- and tooltips as these are optional).
--
-- A CVT can also be associated with a particular LAM dropdown
-- control by providing the control name (reference= in LAM options).
-- This allows the updateControls() function to refresh the
-- control from (possibly changed) choices, values, and
-- tooltips lists.
--
-- The indexValue field can keep track of the desired "current value"
-- of the CVT and is a value from either the choicesValues list
-- (if it exists) or else a value from the choices list. If you
-- wish to use this, you must ensure that the control setfunc() sets
-- the indexValue appropriately.
-- -------------------------------------------------------

AutoCategory.CVT = ZO_Object:Subclass()

AutoCategory.CVT.USE_NONE = 0
AutoCategory.CVT.USE_VALUES = 1
AutoCategory.CVT.USE_TOOLTIPS = 2
AutoCategory.CVT.USE_ALL = 3

local USE_NONE = AutoCategory.CVT.USE_NONE
local USE_VALUES = AutoCategory.CVT.USE_VALUES
local USE_TOOLTIPS = AutoCategory.CVT.USE_TOOLTIPS
local USE_ALL = AutoCategory.CVT.USE_ALL

function AutoCategory.CVT:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

function AutoCategory.CVT:Initialize(ctlname, ndx, usesFlags)
	if ctlname then
		self.controlName = ctlname
	end

	self.choices = {}		-- mandatory list

	if usesFlags and (usesFlags == USE_VALUES or usesFlags == USE_ALL)  then
		self.choicesValues = {}
    else
        self.choicesValues = nil
	end

	if usesFlags and (usesFlags == USE_TOOLTIPS or usesFlags == USE_ALL) then
		self.choicesTooltips = {}
    else
        self.choicesTooltips = nil
	end

	self.indexValue = ndx
end

-- clear all of the tables in the CVT while preserving the references to the tables themselves
function AutoCategory.CVT:clear()
	self.dirty = true
	self.choices = SF.safeClearTable(self.choices)

    if self.choicesValues then self.choicesValues = SF.safeClearTable(self.choicesValues) end
    if self.choicesTooltips then self.choicesTooltips = SF.safeClearTable(self.choicesTooltips) end

	self.indexValue = nil
end

function AutoCategory.CVT:getControlName()
	return self.controlName
end

--[[ `CVT:assign(tblB)`

	Copies the dropdown choice lists and current selection from another CVT into this CVT.

	The destination CVT retains its existing table structure and table references. The contents 
	of the source lists are shallow-copied into the destination lists.

	### Parameters
		`tblB` - `CVT` - Source CVT from which the choices, values, tooltips, and current selection are copied.

	Behavior
		If `tblB` is `nil`, or if `tblB` is the same CVT as the destination, no action is taken.

		Before copying, `assign()` verifies that the source provides every optional list required by the destination:
			* If the destination has `choicesValues`, the source must also have `choicesValues`.
			* If the destination has `choicesTooltips`, the source must also have `choicesTooltips`.

		If a required source list is missing, the assignment is aborted and a debug message is logged.

		The destination is then cleared and marked dirty. The contents of the source lists are shallow-copied 
		into the destination:
			* `choices`
			* `choicesValues`, when used by the destination
			* `choicesTooltips`, when used by the destination

		The list tables themselves are retained rather than replaced, so existing references to the destination 
		lists remain valid.

	Selection
		After the lists are copied, the destination's `indexValue` is selected in this order:
			1. The source CVT's `indexValue`, if it is not `nil`.
			2. The destination's previous `indexValue`, if it is not `nil`.
			3. The normal `select()` fallback behavior.

		`select()` determines whether the selected value is valid for the destination's active selection list.

		This means that an invalid source selection does not necessarily become the destination's `indexValue`; 
		`select()` can retain the previous destination selection or fall back to the first available value.

	Notes
		* `assign()` performs a **shallow copy**. The list entries themselves are not recursively copied.
		* The source and destination CVTs must have compatible optional-list configurations. `assign()` does 
			not add or remove `choicesValues` or `choicesTooltips` tables from the destination.
--]]
function AutoCategory.CVT:assign(tblB)
	if not tblB then return end
	if tblB == self then return end

	if self.choicesValues and not tblB.choicesValues then
		logDebug("[AC_Classes] don't have choicesValues for src tables in assign ", self.controlName)
		return
	end
	if self.choicesTooltips and not tblB.choicesTooltips then
		logDebug("[AC_Classes] don't have choicesTooltips for dest tables in assign ", self.controlName)
		return
	end

	local ndx = self.indexValue
	self:clear()	-- also marks as dirty

	-- 1-based and contiguous, remember?
	-- may return empty table
	local function shallowcpy(src, dest)
        dest = dest or {}
		if not src then return dest end
		for k=1, #src do
			dest[k] = src[k]
		end
		return dest
	end

	self.choices = shallowcpy(tblB.choices, self.choices)
    if self.choicesValues then self.choicesValues = shallowcpy(tblB.choicesValues, self.choicesValues) end
	if self.choicesTooltips then self.choicesTooltips = shallowcpy(tblB.choicesTooltips, self.choicesTooltips) end

	-- select the first value as the "current" value
	if tblB.indexValue ~= nil then
		self:select(tblB.indexValue)

	elseif ndx ~= nil then
		self:select(ndx)

	else --if #self.choicesValues > 0 then
		self:select()
	end
end

--[[ `CVT:select(value)`

	Sets the current `indexValue` for the CVT using the supplied value or, when no valid value is 
	supplied, an appropriate value from the CVT's active selection list.

	The active selection list is:
		* `choicesValues`, when present.
		* `choices`, otherwise.

	Parameters
		`value` - any  - Optional value to select. A table may also be supplied; in that case, its first 
							non-nil entry is selected. An empty string is treated as `nil`. 

	Behavior
		Table value
			If `value` is a table:

			1. If the table is non-empty and its first entry is non-nil, that entry becomes `indexValue`.
			2. If the table is empty, the first value from the active selection list is selected.
			3. If the active selection list is empty, `indexValue` is set to `nil`.

			The first entry supplied in a table is selected **without validating it against the active selection list**.

		Non-table value
			If `value` is an empty string, it is treated as `nil`.

		For all other values:
			1. If `value` is non-nil and exists in the active selection list, it becomes `indexValue`.
			2. Otherwise, if the current `indexValue` is non-nil and still exists in the active selection list, it is retained.
			3. Otherwise, if the active selection list contains values, its first value becomes `indexValue`.
			4. If the active selection list is empty, `indexValue` is set to `nil`.

	Return Value
		Returns the resulting `indexValue`.
		The return value may be `nil` when the CVT has no available selection.
--]]
function AutoCategory.CVT:select(value)
	local searchtbl = self.choicesValues or self.choices

	if type(value) == "table" then
		if #value > 0 and value[1] ~= nil then
			self.indexValue = value[1]
			return self.indexValue
		end

		if #searchtbl > 0 then
			self.indexValue = searchtbl[1]
			return self.indexValue
		end

		self.indexValue = nil
		return nil
	end

	-- not a table

	if value == "" then
		value = nil
	end

	if value ~= nil
		and ZO_IsElementInNumericallyIndexedTable(searchtbl, value) then

		self.indexValue = value
		return self.indexValue

	elseif self.indexValue ~= nil
		and ZO_IsElementInNumericallyIndexedTable(searchtbl, self.indexValue) then

		return self.indexValue

	elseif #searchtbl > 0 then
		self.indexValue = searchtbl[1]
		return self.indexValue
	end

	self.indexValue = nil
	return nil
end

function AutoCategory.CVT:clearIndex()
	self.indexValue = nil
end

--[[ `CVT:append(choice, value, tooltip)`
	Appends one dropdown row to the CVT's `choices` list and, when enabled, its corresponding `choicesValues` and `choicesTooltips` lists.

	All three lists remain 1-based and contiguous, with corresponding entries at the same index representing a single dropdown row.

	Parameters
		`choice`  - any - The display text/value for the new dropdown row. Required.
		`value`   - any - The underlying selection value. Required when the CVT has a `choicesValues` list; otherwise ignored.
		`tooltip` - any - The tooltip for the new dropdown row. Required when the CVT has a `choicesTooltips` list; otherwise ignored.

		`nil` is treated as "not supplied." Other values, including `false`, `0`, and an empty string, are valid.

	Behavior
		The append operation fails and returns `false` if:
			* `choice` is `nil`.
			* The CVT has a `choicesValues` list but `value` is `nil`.
			* The CVT has a `choicesTooltips` list but `tooltip` is `nil`.

		If validation succeeds:
			1. The CVT is marked dirty.
			2. `choice` is appended to `choices`.
			3. `value` is appended to `choicesValues` when that list is enabled.
			4. `tooltip` is appended to `choicesTooltips` when that list is enabled.

		The same index is used for all enabled lists.

	Return Value
		Returns:
			* `true` if the row was successfully appended.
			* `false` if any required argument is missing.


	Updating the Control

		`append()` does not directly update the associated LAM dropdown control. 
		It marks the CVT as dirty so that a subsequent `updateControl()` can refresh the control.
--]]
function AutoCategory.CVT:append(choice, value, tooltip)
	if choice == nil then return false end
	if self.choicesValues and value == nil then return false end
	if self.choicesTooltips and tooltip == nil then return false end

	self.dirty = true

	local n = #self.choices + 1
	self.choices[n] = choice

	if self.choicesValues then
		self.choicesValues[n] = value
	end

	if self.choicesTooltips then
		self.choicesTooltips[n] = tooltip
	end

	return true
end

-- set the name of the associated control for these lists (if there is one)	--	not currently used
function AutoCategory.CVT:setControlName(fld)
	self.controlName = fld
end

-- returns the size of the required list for the CVT
--  (when other lists are used they must also have the same size!)
function AutoCategory.CVT:size()
	return #self.choices
end


-- update the dropdown control with the new/current list values
-- only works if a controlName was assigned to this CVT.
function AutoCategory.CVT:updateControl()
	if not self.controlName then return end
	if not self.dirty then return end

	logDebug("[AC_Classes] CVT:updateControl: getting control for ", self.controlName)
	local dropdownCtrl = WINDOW_MANAGER:GetControlByName(self.controlName)
	if not dropdownCtrl then return end

	self.dirty = nil

	logDebug("[AC_Classes] CVT:updateControl: lists changed - need to update ", self.controlName)
	dropdownCtrl:UpdateChoices(
		self.choices,
		self.choicesValues,
		self.choicesTooltips
	)
end

--[[ `CVT:removeItemChoice(removeItem)`
	Removes a dropdown row from the CVT by its display choice and updates all associated parallel lists.

	The associated dropdown control is **not** updated by this method. The CVT is marked dirty so that 
	a later `updateControl()` can refresh the control.

	Parameters
		`removeItem` - any - The value to search for in the `choices` list.

	Behavior
		The method searches `choices` for `removeItem`.

		If the item is not found, no lists are changed and the current `indexValue` is returned.

		If the item is found, the row at that index is removed from:
			* `choices`
			* `choicesValues`, when present
			* `choicesTooltips`, when present

		Because the lists are parallel, the same index is removed from each list.

		If `choices` is missing, the CVT is considered corrupt. The method replaces `choices` with 
		an empty table, clears `indexValue`, marks the CVT dirty, and returns `nil`.

	Selection After Removal
		After a row is removed, the new `indexValue` is selected as follows:
			* If the removed row was the only row, `indexValue` is cleared.
			* If the removed row was the last row, the previous row is selected.
			* Otherwise, the row that followed the removed row is selected.

		When `choicesValues` exists, the new selection is taken from `choicesValues`. Otherwise, it is taken from `choices`.

		The selection is passed through `select()`, so the normal CVT selection rules are applied.

	Return Value
		Returns the resulting `indexValue`.

	The return value is:
		* `nil` when the CVT has no remaining choices.
		* The newly selected value when a different selection is made.
		* The existing `indexValue` when `removeItem` was not found.

	Notes
		* `removeItemChoice()` removes the **first matching occurrence** found by 
			`ZO_IndexOfElementInNumericallyIndexedTable()`.
		* The method does not call `updateControl()`. Call `updateControl()` after making 
			all desired list changes to update the associated dropdown efficiently.
--]]
function AutoCategory.CVT:removeItemChoice(removeItem)
	if not self.choices then	-- corrupt cvt
		self.dirty = true
		self.choices = {}
		self.indexValue = nil
		return nil
	end

	-- find the choice to remove
	local removeIndex = ZO_IndexOfElementInNumericallyIndexedTable(self.choices, removeItem)
	if not removeIndex then
		return self.indexValue
	end

	self.dirty = true
	local num = #self.choices		-- value BEFORE removal

	-- remove it from lists
	table.remove(self.choices, removeIndex)

	if self.choicesValues ~= nil and #self.choicesValues > 0 then
		table.remove(self.choicesValues, removeIndex)
	end

	if self.choicesTooltips ~= nil and #self.choicesTooltips > 0 then
		table.remove(self.choicesTooltips, removeIndex)
	end

	-- choose what the new indexValue (selection) will be
	if num == 1 then
		self:clearIndex()

	else
		local choices = self.choicesValues or self.choices

		if removeIndex == num then
			-- no next one, select previous one
			self:select(choices[num - 1])
		else
			-- select next one
			self:select(choices[removeIndex])
		end
	end
	return self.indexValue
end

--[[ `CVT:removeItemChoiceValue(removeItem)`
Removes a dropdown row from the CVT by its underlying `choiceValue` and updates all associated parallel lists.

The associated dropdown control is **not** updated by this method. The CVT is marked dirty so 
that a later `updateControl()` can refresh the control.

Parameters
	`removeItem` - any - The value to search for in the `choicesValues` list.

Behavior
	If the CVT does not have a `choicesValues` list, the method returns `nil` without modifying the CVT.
	Otherwise, it searches `choicesValues` for `removeItem`.

	If the value is not found, no lists are changed and the current `indexValue` is returned.
	If the value is found, the row at that index is removed from:
		* `choicesValues`
		* `choices`
		* `choicesTooltips`, when present

	The same index is removed from each list so that the parallel-list relationship is preserved.

Selection After Removal
	After a row is removed, the new `indexValue` is selected as follows:
		* If the removed row was the only row, `indexValue` is cleared.
		* If the removed row was the last row, the previous `choicesValues` entry is selected.
		* Otherwise, the `choicesValues` entry that followed the removed row is selected.

	The new selection is passed through `select()`.

Return Value
	Returns the resulting `indexValue`.

	The return value is:
		* `nil` if the CVT does not have a `choicesValues` list.
		* The existing `indexValue` if `removeItem` was not found.
		* `nil` if the removed row was the only row.
		* The newly selected `choiceValue` otherwise.

### Notes
	`removeItemChoiceValue()` removes the **first matching occurrence** found 
	by `ZO_IndexOfElementInNumericallyIndexedTable()`.

	The method does not call `updateControl()`. This allows multiple changes to be made before 
	refreshing the associated dropdown control.
--]]
function AutoCategory.CVT:removeItemChoiceValue(removeItem)
	local removeIndex
    if self.choicesValues == nil then return nil end

	-- find the choiceValue to remove
	local removeIndex = ZO_IndexOfElementInNumericallyIndexedTable(self.choicesValues, removeItem)
	if not removeIndex then return self.indexValue end		-- nothing to remove

	self.dirty = true
	local num = #self.choicesValues		-- value BEFORE removal

	-- remove it
	table.remove(self.choicesValues, removeIndex) -- not optional here
	table.remove(self.choices, removeIndex)		-- not optional
	if self.choicesTooltips and #self.choicesTooltips > 0 then
		table.remove(self.choicesTooltips, removeIndex)
	end

	-- find the choice to remove
	if num == 1 then
		--select none
		self:clearIndex()

	elseif removeIndex == num then
		--no next one, select previous one
		self:select(self.choicesValues[num-1])

	else
		--select next one
		self:select(self.choicesValues[removeIndex])
	end
	return self.indexValue
end
