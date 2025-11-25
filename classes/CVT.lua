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
AutoCategory.CVT.USE_TOOLTIPS = 3
AutoCategory.CVT.USE_ALL = 4

local USE_NONE = AutoCategory.CVT.USE_NONE
local USE_VALUES = AutoCategory.CVT.USE_VALUES
local USE_TOOLTIPS = AutoCategory.CVT.USE_TOOLTIPS
local USE_ALL = AutoCategory.CVT.USE_ALL

function AutoCategory.CVT:New(...)
    local obj = ZO_Object.New(self)
    obj:initialize(...)
    return obj
end

function AutoCategory.CVT:initialize(ctlname, ndx, usesFlags)
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
	self.dirty = 1
	self.choices = SF.safeClearTable(self.choices)

    if self.choicesValues then self.choicesValues = SF.safeClearTable(self.choicesValues) end
    if self.choicesTooltips then self.choicesTooltips = SF.safeClearTable(self.choicesTooltips) end

	self.indexValue = nil
end

function AutoCategory.CVT:getControlName()
	return self.controlName
end

-- assign the choices, choicesValues, and choicesTooltips from tblB to self
function AutoCategory.CVT:assign(tblB)
	if not tblB then return end

	if self.choicesValues and not tblB.choicesValues then
		logDebug("[AC_Classes] don't have choicesValues for src tables in assign ", self.controlName)
		return
	end
	if self.choicesTooltips and not tblB.choicesTooltips then
		logDebug("[AC_Classes] don't have choicesTooltips for dest tables in assign ", self.controlName)
		return
	end

	local ndx = self.indexValue
	self.dirty = 1
	self:clear()

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
	if tblB.indexValue then
		self:select(tblB.indexValue)

	elseif ndx then
		self:select(ndx)

	else --if #self.choicesValues > 0 then
		self:select()
	end
end

-- set the current indexValue of the CVT from available values of the dropdown
-- if "value" is a non-empty table, then select the first entry from that table.
-- returns the value selected (may be nil)
function AutoCategory.CVT:select(value)
    local searchtbl = self.choicesValues or self.choices
	if type(value) == "table" then
		if #value > 0 then
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

	if value == "" then value = nil end

	if value and ZO_IsElementInNumericallyIndexedTable(searchtbl, value) then
		-- we have a valid value, so use it
		self.indexValue=value
		return self.indexValue

	elseif self.indexValue and ZO_IsElementInNumericallyIndexedTable(searchtbl, self.indexValue) then
		-- already has a value that is still valid so leave it alone
		return self.indexValue

	elseif searchtbl and #searchtbl > 0 then
		-- fall back to using the initial list value of the CVT
		self.indexValue = searchtbl[1]
		return self.indexValue
	end
	return self.indexValue
end

function AutoCategory.CVT:clearIndex()
	self.indexValue = nil
end


-- append a row selection to the cvt tables
-- returns whether or not it succeeded
function AutoCategory.CVT:append(choice, value, tooltip)
	if not value and self.choicesValues then return false end	-- value required when have choicesValues
	if not tooltip and self.choicesTooltips then return false end	-- tooltip required when have choicesTooltips
	if not choice then return false end	-- choice is mandatory

	self.dirty = 1
	self.choices[#self.choices+1] = choice -- (required)
	if value and self.choicesValues then
		self.choicesValues[#self.choicesValues+1] = value	-- (optional)
	end
	if tooltip and self.choicesTooltips then
		self.choicesTooltips[#self.choicesTooltips+1] = tooltip	-- (optional)
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

	if self.dirty == 1 then
		self.dirty = nil
	else
		-- does not need updating
		return
	end

	logDebug("[AC_Classes] CVT:updateControl: getting control for ", self.controlName)
	local dropdownCtrl = WINDOW_MANAGER:GetControlByName(self.controlName)
    if dropdownCtrl == nil then
        return
    end

	logDebug("[AC_Classes] CVT:updateControl: lists changed - need to update ", self.controlName)
	dropdownCtrl:UpdateChoices(self.choices, self.choicesValues,
		self.choicesTooltips)
end

-- remove an item (by choice) from the dropdown lists (does not update the control)
-- returns the new (maybe new) index value
function AutoCategory.CVT:removeItemChoice(removeItem)
	local removeIndex
    if not self.choices then	-- corrupt cvt
		self.dirty = 1
		self.choices = {}
		self.indexValue = nil
		return nil
	end

	-- find the choice to remove
	local ndx = ZO_IndexOfElementInNumericallyIndexedTable(self.choices, removeItem)
	if not ndx then return self.indexValue end		-- nothing to remove

	removeIndex = ndx
	self.dirty = 1
	local num = #self.choices		-- value BEFORE removal

	-- remove it from lists
	table.remove(self.choices, removeIndex)
	if self.choicesValues and #self.choicesValues > 0 then
		table.remove(self.choicesValues, removeIndex)
	end
	if self.choicesTooltips and #self.choicesTooltips > 0 then
		table.remove(self.choicesTooltips, removeIndex)
	end

	-- choose what the new indexValue (selection) will be
    if removeIndex <= 0 then return self.indexValue end
	if num == 1 then
		--select none
		self.indexValue = nil

	elseif removeIndex == num then
		--no next one, select previous one
		self.indexValue = self.choices[num-1]

	else
		--select next one
		self.indexValue = self.choices[removeIndex]
	end
	return self.indexValue
end

-- remove an item (by choiceValue) from the dropdown lists (does not update the control)
-- returns new selected value/choice or nil if does not have choicesValues table.
function AutoCategory.CVT:removeItemChoiceValue(removeItem)
	local removeIndex
    if not self.choicesValues then return nil end

	-- find the choiceValue to remove
	local ndx = ZO_IndexOfElementInNumericallyIndexedTable(self.choicesValues, removeItem)
	if not ndx then return self.indexValue end		-- nothing to remove

	self.dirty = 1
	removeIndex = ndx
	local num = #self.choicesValues		-- value BEFORE removal
	-- remove it
	table.remove(self.choicesValues, removeIndex) -- not optional here
	table.remove(self.choices, removeIndex)		-- not optional
	if #self.choicesTooltips then
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
