local struct = {
  name = "Bob",
  age = 30,
}

local rf = {
    getOlder = function(s) return s.age + 1 end,
  }

local mt = { __index = rf }

setmetatable(struct,mt)

local a1 =  struct:getOlder()

print(a1)

rf.GetYounger = function(s) return s.age - 1 end

local a2 =  struct:GetYounger()

print (a2)