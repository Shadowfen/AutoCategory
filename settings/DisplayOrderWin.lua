local LS = LibScroll
local SF = LibSFUtils
local aclogger

local function clearList(tlw)
    local scrollList = tlw:GetNamedChild("ScrollList")
    scrollList:Clear()
    tlw.ac_dataList = SF.safeClearTable(tlw.ac_dataList)
end

local function addItem(tlw, msg, r, g, b)
    local coltext
    if not r then 
        coltext = msg
    else
        coltext = SF.ColorText( msg, SF.colorRGBToHex(r, g, b))
    end
    tlw.ac_dataList[#tlw.ac_dataList + 1] = {name = coltext}
end

local function updateScrollList( tlw )
    local scrollList = tlw:GetNamedChild("ScrollList")

    scrollList:Update(tlw.ac_dataList)
end

local function CreateDivider(tlw, prefix)
    local divider = WINDOW_MANAGER:CreateControl(prefix.."Divider", tlw, CT_TEXTURE)
    divider:SetDimensions(4, 8)
    divider:SetAnchor(TOPLEFT, tlw, TOPLEFT, 20, 40)
    divider:SetAnchor(TOPRIGHT, tlw, TOPRIGHT, -20, 40)
    divider:SetTexture("EsoUI/Art/Miscellaneous/horizontalDivider.dds")
    divider:SetTextureCoords(0.181640625, 0.818359375, 0, 1)
end

local function CreateBg(tlw,prefix)
    local bg = WINDOW_MANAGER:CreateControl(prefix.."Bg", tlw, CT_BACKDROP)
    bg:SetAnchor(TOPLEFT, tlw, TOPLEFT, -8, -6)
    bg:SetAnchor(BOTTOMRIGHT, tlw, BOTTOMRIGHT, 4, 4)
    bg:SetEdgeTexture("EsoUI/Art/ChatWindow/chat_BG_edge.dds", 256, 256, 32)
    bg:SetCenterTexture("EsoUI/Art/ChatWindow/chat_BG_center.dds")
    bg:SetInsets(32, 32, -32, -32)
    bg:SetDimensionConstraints(minWidth, minHeight)
end

local function CreateWinLabel(tlw, prefix, labelText, minWidth)
    if labelText and labelText ~= "" then
        local label = WINDOW_MANAGER:CreateControl(prefix.."Label", tlw, CT_LABEL)
        label:SetText(labelText)
        label:SetFont("$(ANTIQUE_FONT)|24")
        label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        local textHeight = label:GetTextHeight()
        label:SetDimensionConstraints(minWidth-60, textHeight, nil, textHeight)
        label:ClearAnchors()
        label:SetAnchor(TOPLEFT, tlw, TOPLEFT, 30, (40-textHeight)/2+5)
        label:SetAnchor(TOPRIGHT, tlw, TOPRIGHT, -30, (40-textHeight)/2+5)
    end
end

local function CreateCloseBtn(tlw, prefix)
    ----- CLOSE BUTTON -----
	local msgWinCloseButton = WINDOW_MANAGER:CreateControl(prefix.."Close", tlw, CT_BUTTON)
	msgWinCloseButton:SetDimensions(40,40)
	msgWinCloseButton:SetAnchor(TOPRIGHT, tlw, TOPRIGHT,0,20)

	msgWinCloseButton:SetNormalTexture("EsoUI/Art/Buttons/closebutton_up.dds")
	msgWinCloseButton:SetPressedTexture("EsoUI/Art/Buttons/closebutton_down.dds")
	msgWinCloseButton:SetMouseOverTexture("EsoUI/Art/Buttons/closebutton_mouseover.dds")
	msgWinCloseButton:SetDisabledTexture("EsoUI/Art/Buttons/closebutton_disabled.dds")
	msgWinCloseButton:SetHandler("OnClicked",function(self)
        tlw:SetHidden(true)
    end)
end

local function setupDataRow(rowControl, data, scrollList)
    -- Do whatever you want/need to setup the control
    rowControl:SetText(data.name)
    rowControl:SetFont("ZoFontWinH4")

        rowControl:SetHandler("OnMouseUp", function()
            ZO_ScrollList_MouseClick(scrollList, rowControl)
    end)

end

-- Create the row selection function (if needed)
local function OnRowSelect(previouslySelectedData, selectedData, reselectingDuringRebuild)
    if not selectedData then return end
    local delim = " %("
    local ss = selectedData.name
    local j = string.find(ss, delim, 1)
    local shortname = ss:sub(1, j - 1)
    --aclogger:Error("shortname: "..shortname)
    
    AC_UI.BagSet.SelectRule(shortname)
    AC_UI.BagSet.updateControls()
end

local scrollData = {
    width   = 400,
    height  = 400,
    
    setupCallback   = setupDataRow,
    selectCallback  = OnRowSelect,
}

local function CreateScrollList(tlw, prefix)
    if scrollData.done  then return end

    scrollData.name = prefix .. "ScrollList"
    scrollData.parent = tlw
    scrollData.done = true

    local scrollList = LS:CreateScrollList(scrollData)
    scrollList:SetAnchor(TOPLEFT, tlw, TOPLEFT, 20, 42)
    scrollList:SetAnchor(BOTTOMRIGHT, tlw, BOTTOMRIGHT, -35, -20)
end

-- -------------------------------------------------------


AC_UI.DspWin = {}

function AC_UI.DspWin:New(uniqueName, labelText, fadeDelay, fadeTime, visible)
    local tlw = WINDOW_MANAGER:CreateTopLevelWindow(uniqueName)

    local minWidth = 220
    local minHeight = 150

    tlw:SetMouseEnabled(true)
    tlw:SetMovable(true)
    tlw:SetHidden(false)
    tlw:SetClampedToScreen(true)
    tlw:SetDimensions(400, 400)
    tlw:SetClampedToScreenInsets(-24)
    tlw:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 1100,50)
    tlw:SetDimensionConstraints(minWidth, minHeight)
    tlw:SetResizeHandleSize(16)

    --[[
    -- Set Fade Delay/Times
    tlw.fadeDelayWindow		= fadeDelay or 0
    tlw.fadeTimeWindow		= fadeTime or 0
    tlw.fadeDelayTextLines 	= tlw.fadeDelayWindow/1000
    tlw.fadeTimeTextLines 	= tlw.fadeTimeWindow/1000

    -- Create window fade timeline/animation
    tlw.timeline = ANIMATION_MANAGER:CreateTimeline()
    tlw.animation = tlw.timeline:InsertAnimation(ANIMATION_ALPHA, tlw, tlw.fadeDelayWindow)
    tlw.animation:SetAlphaValues(1, 0)
    tlw.animation:SetDuration(tlw.fadeTimeWindow)
    tlw.timeline:PlayFromStart()
    --]]

    tlw.ac_dataList = {}

    CreateBg(tlw, uniqueName)
    CreateDivider(tlw, uniqueName)
    CreateScrollList(tlw, uniqueName)
    CreateWinLabel(tlw, uniqueName, labelText, minWidth)
    CreateCloseBtn(tlw, uniqueName)

    -- add in functions for DspWin
    tlw.AddItem = addItem
    tlw.UpdateScrollList = updateScrollList
    tlw.ClearList = clearList

	if visible == true then
		tlw:SetHidden(false)
	else
		tlw:SetHidden(true)
	end
    return tlw
end

-- show a hidden window
function AC_UI.DspWin:ShowMsgWin()
	self:SetHidden(false)
end

-- hide a visible window
function AC_UI.DspWin:HideMsgWin(win)
	self:SetHidden(true)
end

-- toggle a window between visible and hidden
function AC_UI.DspWin:toggleWindow(win)
		if self:IsControlHidden() then
			self:SetHidden(false)
		else
			self:SetHidden(true)
		end
end

function AC_UI.DspWin_Init()
    aclogger = AutoCategory.logger
end
