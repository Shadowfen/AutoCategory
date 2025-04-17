-- Necessary OVERWRITES to ZOS code to fix things

--[[
The following functions replicated from ZOS esoui/ingame/fence/keyboard/fence_keyboard.lua are
needed to correct an error in the the original code so that the Launder window works with
AutoCategory category header lines.
--]]
function ZO_Fence_Keyboard:OnEnterLaunder(totalLaunders, laundersUsed)
    self.mode = ZO_MODE_STORE_LAUNDER
    ZO_PlayerInventoryInfoBarAltFreeSlots:SetHidden(false)
    ZO_PlayerInventoryInfoBarAltMoney:SetHidden(true)
    self:UpdateTransactionLabel(totalLaunders, laundersUsed, SI_FENCE_LAUNDER_LIMIT, SI_FENCE_LAUNDER_LIMIT_REACHED)

	-- modified to prevent nil access attempts
    local function ColorCost(control, data, scrollList)
        local priceControl = control:GetNamedChild("SellPrice")
		-- modification: do something intelligent if we could not find the named child
		if not priceControl then 
			-- this row is not a standard item row entry
			-- fall back to default callback behaviour
			local dataEntry = control.dataEntry
			if not data or data == dataEntry.data then
				local dataTypeInfo = GetDataTypeInfo(self, dataEntry.typeId)
				if dataTypeInfo.setupCallback then
					dataTypeInfo.setupCallback(control, dataEntry.data, self)
				end
			end

			return
		end
		-- end modification
        ZO_CurrencyControl_SetCurrencyData(priceControl, CURT_MONEY, data.stackLaunderPrice, CURRENCY_SHOW_ALL, (GetCurrencyAmount(CURT_MONEY, CURRENCY_LOCATION_CHARACTER) < data.stackLaunderPrice))
        ZO_CurrencyControl_SetCurrency(priceControl, ZO_KEYBOARD_CURRENCY_OPTIONS)
    end

    PLAYER_INVENTORY:RefreshBackpackWithFenceData(ColorCost)
    ZO_PlayerInventorySortByPriceName:SetText(GetString(SI_LAUNDER_SORT_TYPE_COST))
    self:RefreshFooter()
end

function ZO_Fence_Manager:OnEnterLaunder()
    self:FireCallbacks("FenceEnterLaunder", self.totalLaunders, self.laundersUsed)
end

FENCE_KEYBOARD.OnEnterLaunder = ZO_Fence_Keyboard.OnEnterLaunder
FENCE_MANAGER:RegisterCallback("FenceEnterLaunder", function(totalLaunders, laundersUsed) 
	FENCE_KEYBOARD:OnEnterLaunder(totalLaunders, laundersUsed) 
	end)

--[[ End of replicated/modified fence_keyboard.lua code from ZOS]]
