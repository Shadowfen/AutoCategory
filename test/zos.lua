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
_G["d"] = function(...)
    local argv 
    for i=1,#arg do
        argv= select(1,...)
        if type(argv) == "number" then
            print tostring(argv)
        elseif type(argv) == "boolean" then
            print tostring(argv)
        elseif type(argv) == "string" then
            print argv
        elseif type(argv) == "table" then
        end
    end
end

ZOS ={}

-- localization functions
EsoStrings = {}
EsoStringVersions = {}
ZOS.nextCustomId = 1

function ZO_CreateStringId(stringId, stringToAdd)
    _G[stringId] = ZOS.nextCustomId
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

function GetTimeStamp()
    return os.time()
end

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

function ZO_ShallowTableCopy(source, dest)
    dest = dest or {}
    
    for k, v in pairs(source) do
        dest[k] = v
    end
    
    return dest
end

function ZO_DeepTableCopy(source, dest)
    dest = dest or {}
     setmetatable (dest, getmetatable(source))
    
    for k, v in pairs(source) do
        if type(v) == "table" then
            dest[k] = ZO_DeepTableCopy(v)
        else
            dest[k] = v
        end
    end
    
    return dest
end

function zo_strformat( fmt, ... )
    print(fmt, ...)
end

function zo_loadstring(...)
    return loadstring(...)
end

function GetCVar(var)
    if var == "language.2" then
        return "en"
    end
    return nil
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
