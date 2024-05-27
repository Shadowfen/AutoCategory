local internal = {
  atname = "@Shadowfen",
  toon = "Shade Windwalker",
  
  guilds = {
  -- id  = {guildname, num_members, guildmaster}
    [1] = {"Ghost Sea Trading", 490, "@epona",}, 
    [2] = {"Eight Shadows of Murder", 25, "@hachh",}, 
    [3] = {"Women of Ebonheart", 90, "@br",}, 
    [4] = {"Dreadlords", 500, "@hades",}, 
    [5] = {"House Mazkein", 480, "@e", },
  }
}

--------------------------------------------------
_G["d"] = print

ZOS ={}

-- localization functions
EsoStrings = {}
EsoStringNames = {}
EsoStringVersions = {}
ZOS.nextCustomId = 1

function testZO_ResetStringTables()
    for k,v in pairs(EsoStringNames) do
        _G[k] = nil
    end
    EsoStrings = {}
    EsoStringVersions = {}
    ZOS.nextCustomId = 1
end

function ZO_CreateStringId(stringName, stringToAdd)
    _G[stringName] = ZOS.nextCustomId
    EsoStringNames[stringName] = ZOS.nextCustomId
    EsoStrings[ZOS.nextCustomId] = stringToAdd
    ZOS.nextCustomId = ZOS.nextCustomId + 1
end

function SafeAddVersion(stringId, stringVersion)
    if(stringId) then
        EsoStringVersions[stringId] = stringVersion
    end
end

function SafeAddString(stringId, stringValue, stringVersion)
    if(stringId) then
        local existingVersion = EsoStringVersions[stringId]
        if((existingVersion == nil) or (existingVersion <= stringVersion)) then
            EsoStrings[stringId] = stringValue
        end
    end
end

function GetString(id)
    return EsoStrings[id]
end
-- end localization functions

function zo_strformat(...)
    local nargs = select('#',...)
    local arg = {}

    for i = 1,nargs do
        local v = select(i,...)
        local t = type(v)
        if(v == nil) then
            arg[#arg+1] = "nil"
        else
            arg[#arg+1] = tostring(v)
        end
    end
    return table.concat(arg," ")
end


function GetCVar(var)
    if var == "language.2" then
        return "en"
    end
    return nil
end

zo_loadstring = loadstring

function GetDisplayName()
  return internal.atname
end


function ZO_DeepTableCopy(source, dest)
    dest = dest or {}
 
    for k, v in pairs(source) do
        if type(v) == "table" then
            dest[k] = ZO_DeepTableCopy(v)
        else
            dest[k] = v
        end
    end
 
    return dest
end

ZO_SavedVars = {}
function ZO_SavedVars:NewAccountWide(vn, ver, nmsp, df)
    local acct = GetDisplayName()
    local tbl = _G[vn].Default[acct]["$AccountWide"]
    if( ver ~= tbl.version ) then
        ZO_DeepTableCopy(df,tbl)
    end
    return tbl
end

function ZO_SavedVars:New(vn, ver, nmsp, df)
    local acct = GetDisplayName()
    local toon = internal.toon
    local tbl = _G[vn].Default[acct][toon]
    if( ver ~= tbl.version ) then
        ZO_DeepTableCopy(df,tbl)
    end
    return tbl
end

function zo_plainstrfind(text, pat)
  return string.find(text, pat)
end

-- guild functions
function GetGuildName(id)
    return internal.guilds[id][1]
end

-- returns number of members, number online, guildmaster
function GetGuildInfo(guildId)
    return internal.guilds[guildId][2], guildId, internal.guilds[guildId][3]
end

-- utilities
function ZO_ClearTable(t)
    for k in pairs(t) do
        t[k] = nil
    end
end

EVENT_MANAGER = {}
function EVENT_MANAGER:UnregisterForEvent()
end
function EVENT_MANAGER:RegisterForEvent()
end

ZO_Object = {}

function ZO_Object:New(template)
    template = template or self
    local newObject = setmetatable ({}, template)
    local mt = getmetatable (newObject)
    mt.__index = template
    
    return newObject
end

function ZO_Object:Subclass()
    return setmetatable({}, {__index = self})
end
