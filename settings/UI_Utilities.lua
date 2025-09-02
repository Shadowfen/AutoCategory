--local SF = LibSFUtils

--local L = GetString

function AC_UI.divider()
	return {
		type = "divider",
		width = "full", --or "half" (optional)
		height = 10,
		alpha = 0.5,
	}
end

function AC_UI.header(strId)
	return {
		type = "header",
		name = strId,
		width = "full",
	}
end

function AC_UI.description(textId, titleId)
	return
		{
			type = "description",
			text = textId, -- text or string id or function returning a string
			title = titleId, -- or string id or function returning a string (optional)
			width = "full", --or "half" (optional)
		}
end

