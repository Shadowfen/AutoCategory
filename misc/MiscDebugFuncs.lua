local SF = LibSFUtils
local AutoCat = AutoCategory

local saved = AutoCat.saved
local cache = AutoCat.cache

local AddCat_SelectTag_LAM = AC_UI.AddCat_SelectTag_LAM


function AutoCat.debugCache()
    d("User rules: " .. AutoCat.ARW:size()) --#AutoCategory.acctRules.rules)
    d("Saved rules: " .. #saved.rules)						-- should be 0 after conversion
    d("Predefined rules: " .. #AutoCat.predefinedRules)			-- predefined rules from base and plugins
    d("Combined rules: " .. ac_rules:sizeRules())						-- complete list of user rules and predefined rules
    d("Compiled rules: " .. SF.GetSize(ac_rules.compiled))
    d("Rules by Name: " .. SF.GetSize(ac_rules.ruleNames))	-- lookup table for rules by rule name
    d("Rules by Tag: " .. SF.GetSize(ac_rules.tagGroups))	-- actually returns the # of Tags defined
    d("Tags: " .. ac_rules:sizeTags())					-- returns the # of Tags defined
    d("Saved bags: " .. #saved.bags)						-- returns # of bags, collections of bagrules by bagId
    d("Cache bags: " ..cache.bags_cvt:size())			-- CVT of bags for bag id dropdowns, returns 3 for CVT
    d("Entries by Bag: " .. SF.GetSize(cache.entriesByBag))		-- CVT of bagrules by bagid, so always returns # bags
    d("Entries by Name: " .. SF.GetSize(cache.entriesByName))	-- bagrules lookup by bagid and rule name, returns # bags
end

--unused (debug) - Not sure why called "EBT" since it uses entriesByName!!
function AutoCat.debugEBT()
	for k, v in pairs(cache.entriesByName[1]) do
		d("k = "..k)
		if type(v) == "table" then
			for k1,v1 in pairs(v) do
				d("  k1="..k1.."  v1="..SF.str(v1))
			end
		else
		    d("v= "..SF.str(v))
		end
	end
end

--unused (debug)
function AutoCat.debugTags()
	d("RulesW.tags:")
	for k, v in pairs(ac_rules.tags) do
		if type(v) == "table" then
			for k1,v1 in pairs(v) do
				d("k = "..k.."   k1="..k1.."  v1="..SF.str(v1))
			end
		else
		    d("k = "..k.." v= "..SF.str(v))
		end
	end
end


function AutoCategory.debugBagTags()
	AddCat_SelectTag_LAM:assign( { choices=AutoCategory.RulesW.tags })
	d("AddCat_SelectTag_LAM:")
	for k, v in pairs(AddCat_SelectTag_LAM.cvt.choices) do
		if type(v) == "table" then
			for k1,v1 in pairs(v) do
				d("k = "..k.."   k1="..k1.."  v1="..SF.str(v1))
			end
		else
		    d("k = "..k.." v= "..SF.str(v))
		end
	end
end

