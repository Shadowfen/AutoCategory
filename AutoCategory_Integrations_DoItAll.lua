
local function ExtractSlotData(slot)
  return {
    bagId = slot.data.bagId,
    slotIndex = slot.data.slotIndex,
    name = slot.data.name,
    stackCount = slot.data.stackCount
  }
end

function IntegrateDoItAll()
	if DoItAll then
		DoItAll.Slots.Fill = function(self, container, limit) 
			self:Init(limit)
			for _, slot in pairs(container.data) do
				if not slot.data.dataEntry.isHeader then
					--Check if slot is allowed -> Else take the next one
					local allowed = self:CheckAllowed(slot.data.bagId, slot.data.slotIndex)
					if allowed then
						if self.filter == nil or (self.filter ~= nil and not self.filter:Filter(slot)) then
							table.insert(self.slots, ExtractSlotData(slot))
						end
					else
						--Increase the limit by 1 if item is not allowed, to get next item
						self.limit = self.limit + 1
					end
					--Is the limit reached?
					if self:ReachedLimit() then
						break
					end
				end
			end
			return not self:Empty()
		end
	end
end