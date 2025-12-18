--====AutoCategory Classes====--

--local L = GetString
--local SF = LibSFUtils

local logDebug = AutoCategory.logDebug


-- --------------------------------------------
AutoCategory.BaseUI = ZO_Object:Subclass()

function AutoCategory.BaseUI:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

function AutoCategory.BaseUI:Initialize(ctlname)
	self.controlName = ctlname
end

function AutoCategory.BaseUI:getControlName()
	return self.controlName
end

function AutoCategory.BaseUI:updateValue()
	if not self.controlName then return end
	local val = self:getValue()
	if not val then return end

    local name = self.controlName

	logDebug("[AC_Classes] updateControl: getting control for ", name)
	local uiCtrl = WINDOW_MANAGER:GetControlByName(name)
    if uiCtrl == nil then
        return
    end

	logDebug("[AC_Classes] updateValue: value changed - need to update ", name)
	uiCtrl:UpdateValue(false, val)
end

-- --------------------------------------------
AutoCategory.BaseDD = ZO_Object:Subclass()

function AutoCategory.BaseDD:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

function AutoCategory.BaseDD:Initialize(ctlname, ndx, usesFlags)
	self.cvt = AutoCategory.CVT:New(ctlname, ndx, usesFlags)
end

function AutoCategory.BaseDD:getControlName()
	return self.cvt.controlName
end

function AutoCategory.BaseDD:select(val)
	self.cvt:select(val)
end

function AutoCategory.BaseDD:clearIndex()
	self.cvt:clearIndex()
end

function AutoCategory.BaseDD:clear()
	self.cvt:clear()
end

function AutoCategory.BaseDD:assign(cvtTbl)
	self.cvt:assign(cvtTbl)
end

function AutoCategory.BaseDD:updateControl()
	if not self.cvt.controlName then return end

	logDebug("[AC_Classes] updateControl: getting control for ", self.cvt.controlName)
	local dropdownCtrl = WINDOW_MANAGER:GetControlByName(self.cvt.controlName)
    if dropdownCtrl == nil then
        return
    end

	if self.cvt.dirty == 1 then		-- only do this if cvt lists have been modified
		logDebug("[AC_Classes] updateControl: dropdown lists changed - updating ", self.cvt.controlName)
		-- only update the choices if we know that the lists contents changed
		self.cvt.dirty = nil
        local numchoices = #self.cvt.choices
        local numvalues = 0
        if self.cvt.choicesValues then numvalues = #self.cvt.choicesValues end
        local numtt = 0
        if self.cvt.choicesTooltips then numtt = #self.cvt.choicesTooltips end
        logDebug("[AC_Classes] #choices=", numchoices, " #choicesValues=", numvalues,
            " #choicesTooltips=", numtt)
		dropdownCtrl:UpdateChoices(self.cvt.choices, self.cvt.choicesValues,
			self.cvt.choicesTooltips)
	end

	if self.cvt.indexValue then
		logDebug("[AC_Classes] updateControl: value changed - need to update ", self.cvt.controlName)
		dropdownCtrl:UpdateValue(false, self.cvt.indexValue)
	end

end

function AutoCategory.BaseDD:size()
  return #self.cvt.choices
end

function AutoCategory.BaseDD:getValue()
  return self.cvt.indexValue
end


