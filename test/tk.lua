TestKit = {
  num_tests=0,
  pass = 0,
  fail = 0,  
}

local TK = TestKit

TK.localization_strings = {
  UNKNOWN_STRING = "Unknown localization string",
  SUITE_RESULTS = " results:",
  TK_RESULTS = "TestKit results:",
  TESTS_RUN = "Number of tests run: ",
  PASS = "PASSED: ",
  FAIL = "FAILED: ",
  
}
local ls = TK.localization_strings

local function GetString(id)
  if( not id ) then
    return ls.UNKNOWN_STRING
  end
  return id
end

local function d(...)
    print(...)
end

function TK.printSuite(moduleName, fn)
    print("\n"..moduleName.."_"..fn..":\n")
end

function TK.init()
  TK.num_tests = 0
  TK.pass = 0
  TK.fail = 0
end

function TK.showResult(suitename)
  if( suitename ) then
    d(suitename..GetString(ls.SUITE_RESULTS))
  else
    d(GetString(ls.TK_RESULTS))
  end
  d(string.format("  %-25s %d",ls.TESTS_RUN, TK.num_tests))
  d(string.format("  %-25s %d",ls.PASS, TK.pass))
  d(string.format("  %-25s %d",ls.FAIL, TK.fail))
end
  
  

function TK.assertTrue(c, tname)
  TK.num_tests = TK.num_tests + 1
  if(c) then
    d(string.format("%-10s%s", ls.PASS, tname ))
    TK.pass = TK.pass + 1
  else
    d(string.format("%-10s%s", ls.FAIL, tname ))
    TK.fail = TK.fail + 1
  end
end

function TK.assertFalse(c, tname)
  TK.num_tests = TK.num_tests + 1
  if(not c) then
    d(string.format("%-10s%s", ls.PASS,tname ))
    TK.pass = TK.pass + 1
  else
    d(string.format("%-10s%s", ls.FAIL,tname ))
    TK.fail = TK.fail + 1
  end
end

function TK.assertNil(c, tname)
  TK.num_tests = TK.num_tests + 1
  if( c == nil ) then
    d(string.format("%-10s%s", ls.PASS,tname ))
    TK.pass = TK.pass + 1
  else
    d(string.format("%-10s%s", ls.FAIL,tname ))
    TK.fail = TK.fail + 1
  end
end

function TK.assertNotNil(c, tname)
  TK.num_tests = TK.num_tests + 1
  if( c ~= nil ) then
    d(string.format("%-10s%s", ls.PASS,tname ))
    TK.pass = TK.pass + 1
  else
    d(string.format("%-10s%s", ls.FAIL,tname ))
    TK.fail = TK.fail + 1
  end
end

function TK.listcount(tbl)
    local i = 0
    for k,v in pairs(tbl) do
        i = i + 1
    end
    return i
end

