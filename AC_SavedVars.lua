AC=AutoCategory

SF=LibSFUtils


function onLogout()
    
    for id, savedVarsManager in pairs(registry) do
        if savedVarsManager.isDefaultsTrimmingEnabled then
            local rawDataTable, _, _, rawSavedVarsTablePath = LSV_SavedVarsManager.LoadRawTableData(savedVarsManager)
            local defaults = savedVarsManager.trimDefaults
            if rawDataTable and defaults then
                trimDefaults(rawDataTable, defaults)
                local nextKey = nil
                repeat
                    nextKey = next(rawDataTable, nextKey)
                until nextKey ~= "version" and nextKey ~= "$LastCharacterName"
                if nextKey == nil then
                    rawDataTable.version = nil
                    rawDataTable["$LastCharacterName"] = nil
                    protected.UnsetPath(savedVarsManager.table, unpack(rawSavedVarsTablePath))
                end
            end
        end
    end
end

function onLogoutCanceled()
    for id, savedVarsManager in pairs(registry) do
        if savedVarsManager.isDefaultsTrimmingEnabled then
            local rawDataTable, _, _, rawSavedVarsTablePath = LSV_SavedVarsManager.LoadRawTableData(savedVarsManager)
            local defaults = savedVarsManager.trimDefaults
            if rawDataTable and defaults then
                fillDefaults(rawDataTable, defaults)
            end
        end
    end
end

function trimDefaults(table, defaults)
    if table == nil or type(table) ~= "table" or defaults == nil then
        return
    end
    for key, defaultValue in pairs(defaults) do
        if type(defaultValue) == "table" then
            if type(table[key]) == "table" then
                trimDefaults(table[key], defaultValue)
                if table[key] and next(table[key]) == nil then
                    table[key] = nil
                end
            end
        elseif table[key] == defaultValue then
            table[key] = nil
        end
    end
end


ZO_PreHook("Logout", onLogout)
ZO_PreHook("Quit", onLogout)
ZO_PreHook("CancelLogout", onLogoutCanceled)