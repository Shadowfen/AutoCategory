--Integration with Iakoni's Gear Changer
function IntegrateIakoniGearChanger()
	if GearChangerByIakoni then
		local function GearChangerByIakoni_DoRefresh(list)
			local a=GearChangerByIakoni.savedVariables.ArraySet
			local b=GearChangerByIakoni.savedVariables.ArraySetSavedFlag

			--loop through the currently shown inventory items
			for _,v in pairs(list.activeControls) do
				local bag = v.dataEntry.data.bagId
				local slot = v.dataEntry.data.slotIndex
				if bag ~= nil and slot ~= nil then
					local itemID = Id64ToString(GetItemUniqueId(bag, slot))
					local marker = v:GetNamedChild("GCBISet")
					if not marker then
						marker = GearChangerByIakoni.CreateControlMarker(v)
					end
					marker:SetHidden(true)
					
					local itemType = GetItemType(bag, slot)
					
					if itemType == ITEMTYPE_ARMOR or itemType == ITEMTYPE_WEAPON then
						local founditem = false

						for i=1, 10 do
							if b[i] == 1 then --check only if the set is saved
								for _,u in pairs(GearChangerByIakoni.WornArray) do
									if itemID==a[i][u] then
										marker:SetHidden(false)
										founditem = true
										break
									end
								end
							end
							
							if founditem then
								break
							end
						end
					end
				end 
			end 
		end
		GearChangerByIakoni.DoRefresh = GearChangerByIakoni_DoRefresh
	end
end


