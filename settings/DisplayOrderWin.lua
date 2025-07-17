local SF = LibSFUtils


local ROW_TYPE_ID 			= 1
local DEFAULT_ROW_HEIGHT 	= 30
local DEFAULT_SCROLL_WIDTH 	= 250
local DEFAULT_SCROLL_HEIGHT = 400


-- create a row for the category order scroll list
local function setupDataRow(rowControl, data, scrollList)
    rowControl:SetText(AutoCategory.BagRuleApi.formatShow(data))
    rowControl:SetFont("ZoFontWinH4")

    -- mouse handler for each row
    local function onMouseUp(ctrl, button, upInside)
        if upInside then
            if button == MOUSE_BUTTON_INDEX_RIGHT then
                -- Show context menu
                ClearMenu()

                -- determine shortname for category (no priorities)
                local selectedData = ctrl.dataEntry.data
                if not selectedData then return end
                local shortname = selectedData.name

                -- Add the varioius menu items to the context menu
                if not AC_UI.BagSet_GetHideCatStatus(shortname) then
                    AddMenuItem(
                        GetString(SI_AC_MENU_BS_HIDE_CAT),
                        function()
                            AC_UI.BagSet.HideCategory(shortname)
                            AC_UI.BagSet_RefreshOrder()
                        end
                    )
                else
                    AddMenuItem(
                        GetString(SI_AC_MENU_BS_SHOW_CAT),
                        function()
                            AC_UI.BagSet.ShowCategory(shortname)
                            AC_UI.BagSet_RefreshOrder()
                        end
                    )
                end
                AddMenuItem(
                    GetString(SI_AC_MENU_BS_RESET_SHOW_PRIOR),
                    function()
                        AC_UI.BagSet.SelectRule(shortname)
                        AC_UI.BagSet_ResetPriority()
                        AC_UI.BagSet_RefreshOrder()
                    end
                )
                AddMenuItem(
                    GetString(SI_AC_MENU_BS_BUTTON_EDIT),
                    function()
                        AC_UI.BagSet.SelectRule(shortname)
                        AC_UI.BagSet_EditCat_LAM.execute()
                        AC_UI.BagSet_RefreshOrder()
                    end
                )
                AddMenuItem(
                    GetString(SI_AC_MENU_BS_BUTTON_REMOVE),
                    function()
                        AC_UI.BagSet.SelectRule(shortname)
                        AC_UI.BagSet_RemoveCat_LAM.execute()
                        AC_UI.BagSet_RefreshOrder()
                    end
                )
                AddMenuItem(
                    GetString(SI_AC_MENU_BS_RESET_ALL_SHOW_PRIOR),
                    function()
                        AC_UI.BagSet_ResetAllPriority()
                        AC_UI.BagSet_RefreshOrder()
                    end
                )

                -- display the context menu
                ShowMenu()

            elseif button == MOUSE_BUTTON_INDEX_LEFT then
                ZO_ScrollList_MouseClick(scrollList, ctrl)
            end
        end
    end
    rowControl:SetHandler("OnMouseUp", onMouseUp)
end

local scrollData = {
    width   = 400,
    height  = 400,
    
    selectTemplate = "ZO_ThinListHighlight",

    scrollList = nil,
}

-- update the rows of the scroll list from the values passed in from the dataTable
local function SelectControl(self, control)
    self.selectedControl = control
end

local function GetSelected(scrollList)
    if not scrollList then return end

    local index = ZO_ScrollList_GetSelectedDataIndex(scrollList) or 1
    local selectedData = ZO_ScrollList_GetSelectedData(scrollList)
    if not selectedData then 
        index = scrollList.scrollData.lastSelectedIndex
        selectedData = scrollList.scrollData.lastSelected
    end
    return index, selectedData
end


local function SetSelected(scrollList, index, data)
   -- AutoCat_Logger():Debug("SetSelected")
    if not scrollList then return end

    scrollList.scrollData.lastSelectedIndex = index
    scrollList.scrollData.lastSelected = data
    scrollList.selectedDataIndex = index
    scrollList.selectedData = data
end


-- Perform action when a row is selected in the scroll list
local function OnRowSelect(previouslySelectedData, selectedData, reselectingDuringRebuild)
    if selectedData then 
        -- Select the Bag Rule in the Bag Settings section
        local shortname = selectedData.name
        local bagrule, index = AutoCategory.GetBagRuleByName(AutoCategory.getCurrentBagId(), shortname)
        if bagrule and bagrule.name then
            SetSelected(scrollData.scrollList, index, bagrule)
        end
    else
        SetSelected(scrollData.scrollList, nil, nil)
    end
    local scrollList = scrollData.scrollList
   if scrollList then
        scrollList.selectedData = selectedData
        if selectedData then
            local control = ZO_ScrollList_GetDataControl(scrollList, selectedData)
            if control then
                SelectControl(scrollList, control)
            end
        end

    end
    
    -- select the bagrule in the Bag Setting section
    if selectedData then
        AC_UI.BagSet.SelectRule(selectedData.name)
        AC_UI.BagSet.updateControls()
    end
end

local winData = {
    title = GetString(SI_AC_TITLE_DSO),
    prefix = "DisplayOrder",
    visible = false,

    minWidth = 220,
    minHeight = 150,
}


local function UpdateScrollList(scrollList, dataTable)
	local dataTableCopy = ZO_DeepTableCopy(dataTable) -- protect savedvars data (bagrules) from bad things
    local selectedIndex, selectedData = GetSelected(scrollList)

    -- empty the scrollList
	ZO_ScrollList_Clear(scrollList)
	local dataList = ZO_ScrollList_GetDataList(scrollList)
	-- Add data items to the list
	for k, dataItem in pairs(dataTableCopy) do
		local entry = ZO_ScrollList_CreateDataEntry(ROW_TYPE_ID, dataItem, nil)
		table.insert(dataList, entry)
	end
    SetSelected(scrollList, selectedIndex, selectedData)

	ZO_ScrollList_Commit(scrollList)
end

--=======================================================--
local function ClearScrollList(self)
    AutoCat_Logger():Debug("ClearScrollList")
	ZO_ScrollList_Clear(self)
	ZO_ScrollList_Commit(self)

    local win = self.parent
    if not win then return end
    AutoCat_Logger():Debug("ClearScrollList - clearing ac_dataList")
    win.ac_dataList = SF.safeClearTable(win.ac_dataList)
end

-- use information from scrollData to create a scroll list 
local function createScrollList(scrollData, prefix)
    AutoCat_Logger():Debug("createScrollList")
    if scrollData.done  then return end     -- run once protection
    scrollData.done = true

    scrollData.name = prefix .. "ScrollList"

	local listName = scrollData.name
	if not listName or type(listName) ~= "string" then return end

	local parent = scrollData.parent
	if not parent then return end

	local scrollList = WINDOW_MANAGER:CreateControlFromVirtual(listName, parent, "ZO_ScrollList")
	if not scrollList then return end

    -- Easy Access References:
	scrollList.scrollData = scrollData
    scrollData.scrollList = scrollList
    scrollList.setupCallback   = setupDataRow
    scrollList.selectCallback  = OnRowSelect

    --scrollList.deselectOnReselect = false  -- controls if selection can be deselected
		
	local listWidth = scrollData.width or DEFAULT_SCROLL_WIDTH
	local listHeight = scrollData.height or DEFAULT_SCROLL_HEIGHT
	scrollList:SetDimensions(listWidth, listHeight)
	
	--local setupCallback = scrollList.setupCallback
	local template = scrollData.rowTemplate or "ZO_SelectableLabel"
	local rowHeight = scrollData.rowHeight or DEFAULT_ROW_HEIGHT

    --ZO_ScrollList_SetAutoSelect(scrollList, true)
	ZO_ScrollList_AddDataType(scrollList, ROW_TYPE_ID, template, rowHeight, 
		setupDataRow, scrollData.hideCallback, scrollData.dataTypeSelectSound, 
		scrollData.resetControlCallback)  
	
    ZO_ScrollList_SetEqualityFunction(scrollList, ROW_TYPE_ID, function(left,right) 
        return left and right and left.name == right.name end)
	
    AutoCat_Logger():Debug("Selections are enabled")
    ZO_ScrollList_EnableSelection(scrollList, "ZO_ThinListHighlight", OnRowSelect)
	
	-- Easy Access Functions:
	scrollList.Clear = ClearScrollList
	scrollList.Update = UpdateScrollList
	
    scrollList:SetAnchor(TOPLEFT, parent, TOPLEFT, 20, 42)
    scrollList:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, -35, -20)
	return scrollList
end


-- -------------------------------------------------------------------------

local function clearList(win)
    local scrollList = win:GetNamedChild("ScrollList")
    scrollList:Clear()
end

-- addItem will add the bagrule to the list of bagrules to create rows from
-- The scrollList WILL NOT be updated from this.
local function addItem(win, bagrule)
    win.ac_dataList[#win.ac_dataList + 1] = bagrule
end

local function updateScrollList( win )
    AutoCat_Logger():Debug("updateScrollList")
    local scrollList = win:GetNamedChild("ScrollList")

    scrollList:Update(win.ac_dataList)
end

local function CreateDivider(win, prefix)
    local divider = WINDOW_MANAGER:CreateControl(prefix.."Divider", win, CT_TEXTURE)
    divider:SetDimensions(4, 8)
    divider:SetAnchor(TOPLEFT, win, TOPLEFT, 20, 40)
    divider:SetAnchor(TOPRIGHT, win, TOPRIGHT, -20, 40)
    divider:SetTexture("EsoUI/Art/Miscellaneous/horizontalDivider.dds")
    divider:SetTextureCoords(0.181640625, 0.818359375, 0, 1)
end

local function CreateBg(win, prefix)
    local bg = WINDOW_MANAGER:CreateControl(prefix.."Bg", win, CT_BACKDROP)
    bg:SetAnchor(TOPLEFT, win, TOPLEFT, -8, -6)
    bg:SetAnchor(BOTTOMRIGHT, win, BOTTOMRIGHT, 4, 4)
    bg:SetEdgeTexture("EsoUI/Art/ChatWindow/chat_BG_edge.dds", 256, 256, 32)
    bg:SetCenterTexture("EsoUI/Art/ChatWindow/chat_BG_center.dds")
    bg:SetInsets(32, 32, -32, -32)
    bg:SetDimensionConstraints(minWidth, minHeight)
end

local function CreateWinLabel(win)  --, prefix, labelText, minWidth)
    if winData.title then
        AutoCat_Logger():Debug("calling CreateWinLabel with "..tostring(winData.title))
        local label = WINDOW_MANAGER:CreateControl(winData.prefix.."Label", win, CT_LABEL)
        label:SetText(winData.title)
        label:SetFont("$(ANTIQUE_FONT)|24")
        label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS)
        local textHeight = label:GetTextHeight()
        label:SetDimensionConstraints(winData.minWidth-60, textHeight, nil, textHeight)
        label:ClearAnchors()
        label:SetAnchor(TOPLEFT, win, TOPLEFT, 30, (40-textHeight)/2+5)
        label:SetAnchor(TOPRIGHT, win, TOPRIGHT, -30, (40-textHeight)/2+5)
    end
end

local function CreateCloseBtn(win, prefix)
    ----- CLOSE BUTTON -----
	local msgWinCloseButton = WINDOW_MANAGER:CreateControl(prefix.."Close", win, CT_BUTTON)
	msgWinCloseButton:SetDimensions(40,40)
	msgWinCloseButton:SetAnchor(TOPRIGHT, win, TOPRIGHT,0,20)

	msgWinCloseButton:SetNormalTexture("EsoUI/Art/Buttons/closebutton_up.dds")
	msgWinCloseButton:SetPressedTexture("EsoUI/Art/Buttons/closebutton_down.dds")
	msgWinCloseButton:SetMouseOverTexture("EsoUI/Art/Buttons/closebutton_mouseover.dds")
	msgWinCloseButton:SetDisabledTexture("EsoUI/Art/Buttons/closebutton_disabled.dds")
	msgWinCloseButton:SetHandler("OnClicked",function(self)
        win:SetHidden(true)
    end)
end

local function selectItem(win, bagId, ruleName)
    local bagrule = AutoCategory.GetBagRuleByName(bagId, ruleName)
    if not bagrule then return end

    local scrollList = win.ac_scrollList
    local indx = ZO_ScrollList_FindDataIndexByDataEntry( scrollList, bagrule)
    if not indx then return end
    local dataitem = ZO_ScrollList_GetDataList(scrollList)[indx]
    if not dataitem then return end

    ZO_ScrollList_SelectDataAndScrollIntoView( scrollList, dataitem.data, nil, true)
end


-- -------------------------------------------------------
AC_UI.DspWin = {}

function AC_UI.DspWin:New()
    local prefix = winData.prefix
    local win = WINDOW_MANAGER:CreateTopLevelWindow(prefix)

    scrollData.parent = win

    local minWidth = winData.minWidth or 220
    local minHeight = winData.minHeight or 150
    local visible = winData.visible or false
    win.winData = winData

    win:SetMouseEnabled(true)
    win:SetMovable(true)
    win:SetHidden(not visible)
    win:SetClampedToScreen(true)
    win:SetDimensions(400, 400)
    win:SetClampedToScreenInsets(-24)
    win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, 1100,50)
    win:SetDimensionConstraints(minWidth, minHeight)
    win:SetResizeHandleSize(16)

    win.ac_dataList = {}
    win.ac_prefix = prefix

    CreateBg(win, prefix)
    CreateDivider(win, prefix)
    local scrollList = createScrollList(scrollData, prefix)
    scrollList.parent = win
    win.ac_scrollList = scrollList
    CreateWinLabel(win) --, prefix, win.title, minWidth)
    CreateCloseBtn(win, prefix)

    -- add in functions for DspWin
    win.AddItem = addItem
    win.UpdateScrollList = updateScrollList
    win.ClearList = clearList
    win.SelectItem = selectItem

    return win
end

function AC_UI.DspWin_Init()

end
