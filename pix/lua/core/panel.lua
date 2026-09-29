-- 新增配置行：在界面初始化前向 addonTable.ConfigRows 追加一张表。
-- 三种 type：
--   slider：name、tooltip、bind_config、default_value、min_value、max_value、step。
--   combo：name、tooltip、bind_config、default_value、options；options 是 { { k = 配置值, v = 显示文字 }, ... }。
--   spell_list：name、tooltip、bind_config、default_value；值是以正整数 SpellID 为键、true 为值的表。
-- bind_config 通常取 addonTable.Config("唯一键")；default_value 只在当前档案没有显式值时生效。
-- 行按 ConfigRows 中的顺序创建。三种类型的完整登记示例见文件尾部。

local addonName, addonTable = ...

local ipairs = ipairs
local pairs = pairs
local select = select
local tonumber = tonumber
local tostring = tostring
local type = type
local gsub = string.gsub
local format = string.format
local max = math.max
local insert = table.insert
local floor = math.floor
local find = string.find
local sub = string.sub

local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local UIParent = UIParent
local GetSpellDescription = C_Spell.GetSpellDescription
local GetSpellName = C_Spell.GetSpellName
local GetSpellTexture = C_Spell.GetSpellTexture

local GetUIScaleFactor = addonTable.GetUIScaleFactor
local ConfigRows = addonTable.ConfigRows
local logging = addonTable.logging
local SIZE = addonTable.SIZE
local COLOR = addonTable.COLOR.PANEL
local BurstRemaining = addonTable.BurstRemaining
local InBurst = addonTable.InBurst
local UIInitFuncs = addonTable.UIInitFuncs

local Panel = {}
local FontPath = "Interface\\Addons\\" .. addonName .. "\\core\\panel.ttf"
local Rows = {}
local UI = {}
local OnUpdateFuncs = {}
local DefaultApplied = {}

local eventFrame = CreateFrame("Frame")
local timeElapsed = 0
eventFrame:HookScript("OnUpdate", function(self, elapsed)
    timeElapsed = timeElapsed + elapsed
    if timeElapsed > 0.1 then
        timeElapsed = 0
        for updaterIndex = 1, #OnUpdateFuncs do
            local updater = OnUpdateFuncs[updaterIndex]
            updater()
        end
    end
end)

function UI.ApplyBorderAndFill(frame, borderColor, fillColor, borderSize)
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(frame)
    bg:SetColorTexture(borderColor:GetRGBA())

    local art = frame:CreateTexture(nil, "ARTWORK")
    art:SetPoint("TOPLEFT", frame, "TOPLEFT", borderSize, -borderSize)
    art:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -borderSize, borderSize)
    art:SetColorTexture(fillColor:GetRGBA())

    return bg, art
end

function UI.BindRowHover(row, hoverTexture, title, tooltip)
    local function OnEnter(self)
        hoverTexture:SetColorTexture(COLOR.RowHover:GetRGBA())
        if tooltip and tooltip ~= "" then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT", SIZE.PANEL.MainFrame.Spacing, 0)
            GameTooltip:SetFrameStrata("TOOLTIP")
            GameTooltip:SetFrameLevel(1000)
            GameTooltip:SetText(title, 1, 1, 1, 1, true)
            GameTooltip:AddLine(tooltip, 0.8, 0.8, 0.8, true)
            GameTooltip:Show()
        end
    end

    local function OnLeave()
        hoverTexture:SetColorTexture(0, 0, 0, 0)
        if tooltip and tooltip ~= "" then
            GameTooltip:Hide()
        end
    end

    row:SetScript("OnEnter", OnEnter)
    row:SetScript("OnLeave", OnLeave)
end

function UI.ToggleFrame(frame)
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

function UI.CreateButton(parent, slug, x_pos, y_pos, buttonWidth, buttonHeight, buttonText)
    local button = CreateFrame("Button", addonName .. slug, parent)
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", x_pos, y_pos)
    button:SetSize(buttonWidth, buttonHeight)
    button:EnableMouse(true)

    button.bg = button:CreateTexture(nil, "BACKGROUND")
    button.bg:SetAllPoints()
    button.bg:SetColorTexture(COLOR.ButtonBorder:GetRGBA())

    button.art = button:CreateTexture(nil, "ARTWORK")
    button.art:SetPoint("TOPLEFT", button, "TOPLEFT", SIZE.PANEL.BUTTON.Border, -SIZE.PANEL.BUTTON.Border)
    button.art:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -SIZE.PANEL.BUTTON.Border, SIZE.PANEL.BUTTON.Border)
    button.art:SetColorTexture(COLOR.ButtonMouseUp:GetRGBA())

    button.text = button:CreateFontString(nil, "OVERLAY")
    button.text:SetPoint("CENTER", button, "CENTER")
    button.text:SetFont(FontPath, GetUIScaleFactor(20), "")
    button.text:SetJustifyH("CENTER")
    button.text:SetJustifyV("MIDDLE")
    button.text:SetTextColor(1, 1, 1)
    button.text:SetText(buttonText)

    button:SetScript("OnMouseDown", function()
        button.art:SetColorTexture(COLOR.ButtonMouseDown:GetRGBA())
    end)
    button:SetScript("OnMouseUp", function()
        button.art:SetColorTexture(COLOR.ButtonMouseUp:GetRGBA())
    end)
    button:SetScript("OnEnter", function()
        button.bg:SetColorTexture(COLOR.ButtonHighlight:GetRGBA())
    end)
    button:SetScript("OnLeave", function()
        button.bg:SetColorTexture(COLOR.ButtonBorder:GetRGBA())
    end)
    return button
end

local function CreateSettingRow(title, tooltip)
    local panelFrame = Panel.Frame
    if not panelFrame then
        return nil
    end

    if not panelFrame._rowCount then
        panelFrame._rowCount = 0
        panelFrame._contentHeight = SIZE.PANEL.MainFrame.Spacing * 2
    end

    local rowIndex = panelFrame._rowCount
    local topOffset = panelFrame._topOffset or 0
    local rowY = -SIZE.PANEL.MainFrame.Spacing - topOffset - rowIndex * (SIZE.PANEL.SETTING_LINE.Height + SIZE.PANEL.SETTING_LINE.Spacing)

    local row = CreateFrame("Frame", addonName .. "settingRow" .. rowIndex, panelFrame)
    row:SetPoint("TOPLEFT", panelFrame, "TOPLEFT", SIZE.PANEL.MainFrame.Spacing, rowY)
    row:SetPoint("TOPRIGHT", panelFrame, "TOPRIGHT", -SIZE.PANEL.MainFrame.Spacing, rowY)
    row:SetHeight(SIZE.PANEL.SETTING_LINE.Height)
    row:EnableMouse(true)

    row.bg = row:CreateTexture(nil, "BACKGROUND")
    row.bg:SetAllPoints(row)
    row.bg:SetColorTexture(0, 0, 0, 0)

    row.title = row:CreateFontString(nil, "OVERLAY")
    row.title:SetPoint("LEFT", row, "LEFT", 0, 0)
    row.title:SetSize(SIZE.PANEL.SETTING_LINE.TitleWidth, SIZE.PANEL.SETTING_LINE.Height)
    row.title:SetFont(FontPath, GetUIScaleFactor(20), "")
    row.title:SetJustifyH("LEFT")
    row.title:SetJustifyV("MIDDLE")
    row.title:SetTextColor(COLOR.Text:GetRGBA())
    row.title:SetText(title)

    UI.BindRowHover(row, row.bg, title, tooltip)

    panelFrame._rowCount = rowIndex + 1
    panelFrame._contentHeight = SIZE.PANEL.MainFrame.Spacing * 2
        + (panelFrame._topOffset or 0)
        + panelFrame._rowCount * SIZE.PANEL.SETTING_LINE.Height
        + max(0, panelFrame._rowCount - 1) * SIZE.PANEL.SETTING_LINE.Spacing
    panelFrame:SetHeight(panelFrame._contentHeight)

    return row
end

local function CreatePanelFrame()
    if Panel.ControlFrame then
        return
    end

    local spacing = SIZE.PANEL.MainFrame.Spacing
    local areaWidth = (SIZE.PANEL.MainFrame.Width - spacing * 4) / 3

    local controlFrame = CreateFrame("Frame", addonName .. "controlFrame", UIParent)
    controlFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
    controlFrame:SetSize(SIZE.PANEL.MainFrame.Width, SIZE.PANEL.MainFrame.Height)
    controlFrame:SetFrameStrata("TOOLTIP")
    controlFrame:SetFrameLevel(900)
    controlFrame:SetMovable(true)
    controlFrame:EnableMouse(true)
    controlFrame:RegisterForDrag("LeftButton")
    controlFrame:SetClampedToScreen(true)
    controlFrame:SetScript("OnDragStart", controlFrame.StartMoving)
    controlFrame:SetScript("OnDragStop", controlFrame.StopMovingOrSizing)
    controlFrame:Show()

    controlFrame.bg, controlFrame.art = UI.ApplyBorderAndFill(controlFrame, COLOR.WindowBorder, COLOR.WindowBg, SIZE.PANEL.MainFrame.Border)

    local toggleButton = UI.CreateButton(controlFrame, "toggleButton", spacing, -spacing, areaWidth, SIZE.PANEL.BUTTON.Height, "已停止")

    local statusArea = CreateFrame("Frame", addonName .. "statusArea", controlFrame)
    statusArea:SetPoint("TOPLEFT", controlFrame, "TOPLEFT", spacing * 2 + areaWidth, -spacing)
    statusArea:SetSize(areaWidth, SIZE.PANEL.BUTTON.Height)

    local statusIcon = CreateFrame("Frame", addonName .. "statusIcon", statusArea)
    statusIcon:SetPoint("LEFT", statusArea, "LEFT", 0, 0)
    statusIcon:SetSize(SIZE.PANEL.BUTTON.Height, SIZE.PANEL.BUTTON.Height)
    statusIcon.bg = statusIcon:CreateTexture(nil, "BACKGROUND")
    statusIcon.bg:SetPoint("TOPLEFT", statusIcon, "TOPLEFT", SIZE.PANEL.BUTTON.IconBorder / 2, -SIZE.PANEL.BUTTON.IconBorder / 2)
    statusIcon.bg:SetPoint("BOTTOMRIGHT", statusIcon, "BOTTOMRIGHT", -SIZE.PANEL.BUTTON.IconBorder / 2, SIZE.PANEL.BUTTON.IconBorder / 2)
    statusIcon.bg:SetColorTexture(COLOR.ButtonBorder:GetRGBA())
    statusIcon.art = statusIcon:CreateTexture(nil, "ARTWORK")
    statusIcon.art:SetPoint("TOPLEFT", statusIcon, "TOPLEFT", SIZE.PANEL.BUTTON.IconBorder, -SIZE.PANEL.BUTTON.IconBorder)
    statusIcon.art:SetPoint("BOTTOMRIGHT", statusIcon, "BOTTOMRIGHT", -SIZE.PANEL.BUTTON.IconBorder, SIZE.PANEL.BUTTON.IconBorder)
    statusIcon.art:SetColorTexture(0, 1, 0, 1)

    local statusText = statusArea:CreateFontString(nil, "OVERLAY")
    statusText:SetPoint("LEFT", statusIcon, "RIGHT", spacing, 0)
    statusText:SetPoint("RIGHT", statusArea, "RIGHT", 0, 0)
    statusText:SetFont(FontPath, GetUIScaleFactor(20), "")
    statusText:SetJustifyH("LEFT")
    statusText:SetJustifyV("MIDDLE")
    statusText:SetTextColor(0, 1, 0)
    statusText:SetText("未爆发")

    local configButton = UI.CreateButton(controlFrame, "configButton", spacing * 3 + areaWidth * 2, -spacing, areaWidth, SIZE.PANEL.BUTTON.Height, "配置")

    local settingFrame = CreateFrame("Frame", addonName .. "settingFrame", UIParent)
    settingFrame:SetPoint("TOPLEFT", controlFrame, "BOTTOMLEFT", 0, 0)
    settingFrame:SetSize(SIZE.PANEL.MainFrame.Width, SIZE.PANEL.MainFrame.Height)
    settingFrame:SetFrameStrata("TOOLTIP")
    settingFrame:SetFrameLevel(900)
    settingFrame.bg, settingFrame.art = UI.ApplyBorderAndFill(settingFrame, COLOR.WindowBorder, COLOR.WindowBg, SIZE.PANEL.MainFrame.Border)
    settingFrame:Hide()

    Panel.ControlFrame = controlFrame
    Panel.SettingFrame = settingFrame
    Panel.Frame = settingFrame

    local lastEnabledState = nil

    local function UpdateStatusUI()
        local enabled = addonTable.ENABLE == true
        if lastEnabledState == enabled then
            return
        end
        lastEnabledState = enabled
        if enabled then
            toggleButton.text:SetText("已启动")
            toggleButton.text:SetTextColor(0, 1, 0)
        else
            toggleButton.text:SetText("已停止")
            toggleButton.text:SetTextColor(1, 0, 0)
        end
    end

    local lastBurstState = nil
    local lastBurstText = nil

    local function UpdateBurstUI()
        if InBurst() then
            local remaining = BurstRemaining()

            local currentText = format("%.2f", remaining)

            if lastBurstState ~= true then
                statusIcon.art:SetColorTexture(0, 1, 0, 1)
                statusText:SetTextColor(0, 1, 0)
                lastBurstState = true
            end

            if lastBurstText ~= currentText then
                statusText:SetText(currentText)
                lastBurstText = currentText
            end
        else
            if lastBurstState ~= false then
                statusIcon.art:SetColorTexture(1, 0, 0, 1)
                statusText:SetTextColor(1, 0, 0)
                lastBurstState = false
            end

            if lastBurstText ~= "未爆发" then
                statusText:SetText("未爆发")
                lastBurstText = "未爆发"
            end
        end
    end

    local function ToggleSetting()
        if settingFrame:IsShown() then
            settingFrame:Hide()
            if Panel.SpellListEditorFrame and Panel.SpellListEditorFrame:IsShown() then
                Panel.SpellListEditorFrame:Hide()
            end
        else
            settingFrame:Show()
        end
    end

    toggleButton:HookScript("OnMouseUp", function()
        addonTable.ENABLE = not addonTable.RELOAD_REQUIRED and not addonTable.ENABLE
        UpdateStatusUI()
    end)

    configButton:HookScript("OnMouseUp", function()
        ToggleSetting()
    end)

    UpdateStatusUI()
    UpdateBurstUI()
    insert(OnUpdateFuncs, UpdateStatusUI)
    insert(OnUpdateFuncs, UpdateBurstUI)

    controlFrame.StatusIcon = statusIcon
    controlFrame.StatusText = statusText
    controlFrame.ToggleButton = toggleButton
    controlFrame.ConfigButton = configButton
    controlFrame.ToggleSetting = ToggleSetting
end

local function GetStepDecimals(step)
    local s = tostring(step)
    local dot = find(s, "%.")
    if not dot then
        return 0
    end
    local decimals = #s - dot
    while decimals > 0 and sub(s, -1) == "0" do
        s = sub(s, 1, -2)
        decimals = decimals - 1
    end
    return decimals
end

local function FormatStepValue(value, decimals)
    if decimals <= 0 then
        return format("%d", floor(value + 0.5))
    end
    return format("%." .. decimals .. "f", value)
end

local function ApplyDefaultValue(config, value)
    if not config or not config.key then
        return
    end
    if DefaultApplied[config.key] then
        return
    end
    config:set_default(value)
    DefaultApplied[config.key] = true
end

local function AddSliderRow(row_info)
    local config = row_info.bind_config
    ApplyDefaultValue(config, row_info.default_value)

    local row = CreateSettingRow(row_info.name, row_info.tooltip)
    if not row then
        return nil
    end

    local minValue = row_info.min_value
    local maxValue = row_info.max_value
    local step = row_info.step
    local decimals = GetStepDecimals(step)

    local widget = CreateFrame("Frame", addonName .. "sliderWidget" .. row:GetName(), row)
    widget:SetPoint("LEFT", row.title, "RIGHT", SIZE.PANEL.SETTING_LINE.Spacing, 0)
    widget:SetSize(SIZE.PANEL.SETTING_LINE.WidgetWidth, SIZE.PANEL.SETTING_LINE.Height)
    widget:EnableMouse(true)

    widget.bg = widget:CreateTexture(nil, "BACKGROUND")
    widget.bg:SetAllPoints(widget)
    widget.bg:SetColorTexture(COLOR.ButtonBorder:GetRGBA())

    widget.art = widget:CreateTexture(nil, "ARTWORK")
    widget.art:SetPoint("TOPLEFT", widget, "TOPLEFT", SIZE.PANEL.BUTTON.Border, -SIZE.PANEL.BUTTON.Border)
    widget.art:SetPoint("BOTTOMRIGHT", widget, "BOTTOMRIGHT", -SIZE.PANEL.BUTTON.Border, SIZE.PANEL.BUTTON.Border)
    widget.art:SetColorTexture(COLOR.ButtonMouseUp:GetRGBA())

    local slider = CreateFrame("Slider", addonName .. "slider" .. row:GetName(), widget)
    slider:SetPoint("LEFT", widget, "LEFT", SIZE.PANEL.MainFrame.Spacing, 0)
    slider:SetPoint("RIGHT", widget, "RIGHT", -SIZE.PANEL.MainFrame.Spacing * 2 - SIZE.PANEL.SETTING_LINE.SliderValueWidth, 0)
    slider:SetHeight(SIZE.PANEL.SETTING_LINE.SliderBarHeight)
    slider:SetOrientation("HORIZONTAL")
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)

    local bar = CreateFrame("Frame", addonName .. "sliderBar" .. row:GetName(), widget)
    bar:SetAllPoints(slider)
    bar.left = bar:CreateTexture(nil, "ARTWORK")
    bar.left:SetPoint("LEFT", bar, "LEFT")
    bar.left:SetHeight(SIZE.PANEL.SETTING_LINE.SliderBarHeight)
    bar.left:SetColorTexture(COLOR.SliderLeft:GetRGBA())
    bar.right = bar:CreateTexture(nil, "ARTWORK")
    bar.right:SetPoint("RIGHT", bar, "RIGHT")
    bar.right:SetHeight(SIZE.PANEL.SETTING_LINE.SliderBarHeight)
    bar.right:SetColorTexture(COLOR.SliderRight:GetRGBA())

    local thumb = slider:CreateTexture(nil, "ARTWORK")
    thumb:SetSize(SIZE.PANEL.SETTING_LINE.SliderSquareHeight, SIZE.PANEL.SETTING_LINE.SliderSquareHeight)
    thumb:SetColorTexture(COLOR.Base:GetRGBA())
    slider:SetThumbTexture(thumb)
    local thumbBorder = slider:CreateTexture(nil, "BACKGROUND")
    thumbBorder:SetSize(SIZE.PANEL.SETTING_LINE.SliderSquareHeight + SIZE.PANEL.MainFrame.Border * 2, SIZE.PANEL.SETTING_LINE.SliderSquareHeight + SIZE.PANEL.MainFrame.Border * 2)
    thumbBorder:SetColorTexture(COLOR.ButtonBorder:GetRGBA())
    thumbBorder:SetPoint("CENTER", thumb, "CENTER")

    local valueText = widget:CreateFontString(nil, "OVERLAY")
    valueText:SetPoint("RIGHT", widget, "RIGHT", -SIZE.PANEL.MainFrame.Spacing, 0)
    valueText:SetFont(FontPath, GetUIScaleFactor(20), "")
    valueText:SetJustifyH("RIGHT")
    valueText:SetJustifyV("MIDDLE")
    valueText:SetTextColor(COLOR.Text:GetRGBA())

    local function ApplySliderVisual(value)
        local percent = (value - minValue) / (maxValue - minValue)
        local barWidth = bar:GetWidth()
        local filled = percent * barWidth
        bar.left:SetWidth(filled)
        bar.right:SetWidth(barWidth - filled)
        valueText:SetText(FormatStepValue(value, decimals))
    end

    local function SetSliderValue(value)
        slider:SetValue(value)
        ApplySliderVisual(value)
    end

    slider:SetScript("OnValueChanged", function(sliderFrame, value)
        sliderFrame = sliderFrame or slider
        ApplySliderVisual(sliderFrame:GetValue())
    end)
    slider:SetScript("OnMouseUp", function()
        if config then
            config:set_value(slider:GetValue())
        end
    end)

    local initialValue = row_info.default_value
    if config then
        initialValue = config:get_value()
    end
    SetSliderValue(initialValue)

    if config then
        config:register_callback(function(value)
            SetSliderValue(value)
        end)
    end
    return row
end

local function CreateDropdownControl(row, options, defaultValue, config)
    if not row then
        return nil
    end
    local ownerFrame = Panel.Frame or row:GetParent()

    local widget = CreateFrame("Frame", addonName .. "dropdownWidget" .. row:GetName(), row)
    widget:SetPoint("LEFT", row.title, "RIGHT", SIZE.PANEL.SETTING_LINE.Spacing, 0)
    widget:SetSize(SIZE.PANEL.SETTING_LINE.WidgetWidth, SIZE.PANEL.SETTING_LINE.Height)
    widget:EnableMouse(true)

    widget.bg = widget:CreateTexture(nil, "BACKGROUND")
    widget.bg:SetAllPoints(widget)
    widget.bg:SetColorTexture(COLOR.ButtonBorder:GetRGBA())

    widget.art = widget:CreateTexture(nil, "ARTWORK")
    widget.art:SetPoint("TOPLEFT", widget, "TOPLEFT", SIZE.PANEL.BUTTON.Border, -SIZE.PANEL.BUTTON.Border)
    widget.art:SetPoint("BOTTOMRIGHT", widget, "BOTTOMRIGHT", -SIZE.PANEL.BUTTON.Border, SIZE.PANEL.BUTTON.Border)
    widget.art:SetColorTexture(COLOR.ButtonMouseUp:GetRGBA())

    local valueText = widget:CreateFontString(nil, "OVERLAY")
    valueText:SetPoint("LEFT", widget, "LEFT", SIZE.PANEL.MainFrame.Spacing, 0)
    valueText:SetPoint("RIGHT", widget, "RIGHT", -SIZE.PANEL.MainFrame.Spacing, 0)
    valueText:SetFont(FontPath, GetUIScaleFactor(20), "")
    valueText:SetJustifyH("LEFT")
    valueText:SetJustifyV("MIDDLE")
    valueText:SetTextColor(COLOR.Text:GetRGBA())

    local listFrame = CreateFrame("Frame", addonName .. "dropdownList" .. row:GetName(), ownerFrame)
    listFrame:SetPoint("TOPLEFT", widget, "BOTTOMLEFT", 0, -SIZE.PANEL.SETTING_LINE.Spacing / 2)
    listFrame:SetPoint("TOPRIGHT", widget, "BOTTOMRIGHT", 0, -SIZE.PANEL.SETTING_LINE.Spacing / 2)
    listFrame:SetHeight(#options * SIZE.PANEL.SETTING_LINE.Height)
    listFrame:SetFrameStrata("TOOLTIP")
    listFrame:SetFrameLevel(920)
    listFrame:Hide()

    listFrame.bg, listFrame.art = UI.ApplyBorderAndFill(listFrame, COLOR.ButtonBorder, COLOR.DropdownBg, SIZE.PANEL.MainFrame.Border)

    local function FindIndexByValue(value)
        for i, option in ipairs(options) do
            if option.k == value then
                return i
            end
        end
        return nil
    end

    local function SetDropdownValue(value, fromUser)
        local index = FindIndexByValue(value) or 1
        local option = options[index]
        if not option then
            return
        end
        valueText:SetText(option.v)
        if fromUser and config then
            config:set_value(option.k)
        end
    end

    for i, option in ipairs(options) do
        local item = CreateFrame("Frame", addonName .. "dropdownItem" .. row:GetName() .. i, listFrame)
        item:SetPoint("TOPLEFT", listFrame, "TOPLEFT", SIZE.PANEL.MainFrame.Border, -SIZE.PANEL.MainFrame.Border - (i - 1) * SIZE.PANEL.SETTING_LINE.Height)
        item:SetPoint("TOPRIGHT", listFrame, "TOPRIGHT", -SIZE.PANEL.MainFrame.Border, -SIZE.PANEL.MainFrame.Border - (i - 1) * SIZE.PANEL.SETTING_LINE.Height)
        item:SetHeight(SIZE.PANEL.SETTING_LINE.Height)
        item:EnableMouse(true)

        item.bg = item:CreateTexture(nil, "BACKGROUND")
        item.bg:SetAllPoints(item)
        item.bg:SetColorTexture(0, 0, 0, 0)

        item.text = item:CreateFontString(nil, "OVERLAY")
        item.text:SetPoint("LEFT", item, "LEFT", SIZE.PANEL.MainFrame.Spacing, 0)
        item.text:SetPoint("RIGHT", item, "RIGHT", -SIZE.PANEL.MainFrame.Spacing, 0)
        item.text:SetFont(FontPath, GetUIScaleFactor(20), "")
        item.text:SetJustifyH("LEFT")
        item.text:SetJustifyV("MIDDLE")
        item.text:SetTextColor(COLOR.Text:GetRGBA())
        item.text:SetText(option.v)

        item:SetScript("OnEnter", function()
            item.bg:SetColorTexture(COLOR.RowHover:GetRGBA())
        end)
        item:SetScript("OnLeave", function()
            item.bg:SetColorTexture(0, 0, 0, 0)
        end)
        item:SetScript("OnMouseDown", function()
            SetDropdownValue(option.k, true)
            listFrame:Hide()
        end)
    end

    local function ToggleList()
        if #options <= 0 then
            return
        end
        UI.ToggleFrame(listFrame)
    end

    row:SetScript("OnMouseDown", ToggleList)
    widget:SetScript("OnMouseDown", ToggleList)

    SetDropdownValue(defaultValue, false)
    return widget, SetDropdownValue
end

local function AddComboRow(row_info)
    local config = row_info.bind_config
    ApplyDefaultValue(config, row_info.default_value)

    local row = CreateSettingRow(row_info.name, row_info.tooltip)
    if not row then
        return nil
    end

    local setValue = select(2, CreateDropdownControl(row, row_info.options, row_info.default_value, config))
    if config then
        setValue(config:get_value(), false)
        config:register_callback(function(value)
            setValue(value, false)
        end)
    end
    return row
end

local function NormalizeSpellID(value)
    local numberValue = tonumber(value)
    if not numberValue then
        return nil
    end
    numberValue = floor(numberValue)
    if numberValue <= 0 then
        return nil
    end
    return numberValue
end

local function CopySpellList(source)
    local copy = {}
    if type(source) ~= "table" then
        return copy
    end
    for rawSpellID, enabled in pairs(source) do
        if enabled then
            local spellID = NormalizeSpellID(rawSpellID)
            if spellID then
                copy[spellID] = true
            end
        end
    end
    return copy
end

local function CollectSpellIDs(spellList)
    local spellIDs = {}
    if type(spellList) ~= "table" then
        return spellIDs
    end
    for rawSpellID, enabled in pairs(spellList) do
        if enabled then
            local spellID = NormalizeSpellID(rawSpellID)
            if spellID then
                insert(spellIDs, spellID)
            end
        end
    end
    return spellIDs
end

local function EnsureSpellListEditorFrame()
    if Panel.SpellListEditorFrame then
        return Panel.SpellListEditorFrame
    end
    if not Panel.Frame then
        return nil
    end

    local scale = 4
    local maxRows = 15
    local lineHeight = SIZE.PANEL.SETTING_LINE.Height
    local panelWidth = GetUIScaleFactor(scale * 120)
    local panelHeight = GetUIScaleFactor(scale * 152) + lineHeight
    local spacing = SIZE.PANEL.MainFrame.Spacing
    local border = SIZE.PANEL.MainFrame.Border
    local iconFallback = 61304

    local frame = CreateFrame("Frame", addonName .. "spellListEditorFrame", UIParent)
    frame:SetPoint("TOPLEFT", Panel.Frame, "TOPRIGHT", 0, 0)
    frame:SetSize(panelWidth, panelHeight)
    frame:SetFrameStrata("TOOLTIP")
    frame:SetFrameLevel(905)
    frame:Hide()

    frame.bg, frame.art = UI.ApplyBorderAndFill(frame, COLOR.WindowBorder, COLOR.WindowBg, SIZE.PANEL.MainFrame.Border)

    local contentWidth = panelWidth - spacing * 2
    local actionButtonWidth = GetUIScaleFactor(64)
    local actionGap = spacing
    local inputWidth = contentWidth - actionButtonWidth * 2 - actionGap * 2
    local addButtonX = spacing
    local deleteButtonX = addButtonX + actionButtonWidth + actionGap
    local inputX = deleteButtonX + actionButtonWidth + actionGap
    local inputRowY = -(spacing * 2 + lineHeight)
    local listTopY = -(spacing * 3 + lineHeight * 2)

    frame.titleText = frame:CreateFontString(nil, "OVERLAY")
    frame.titleText:SetPoint("TOPLEFT", frame, "TOPLEFT", spacing, -spacing)
    frame.titleText:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -spacing, -spacing)
    frame.titleText:SetHeight(lineHeight)
    frame.titleText:SetFont(FontPath, GetUIScaleFactor(20), "")
    frame.titleText:SetJustifyH("CENTER")
    frame.titleText:SetJustifyV("MIDDLE")
    frame.titleText:SetTextColor(COLOR.Text:GetRGBA())
    frame.titleText:SetText("法术列表")

    frame.spellIDBox = CreateFrame("EditBox", addonName .. "spellListInputBox", frame)
    frame.spellIDBox:SetPoint("TOPLEFT", frame, "TOPLEFT", inputX, inputRowY)
    frame.spellIDBox:SetSize(inputWidth, lineHeight)
    frame.spellIDBox:SetFont(FontPath, GetUIScaleFactor(20), "")
    frame.spellIDBox:SetJustifyH("LEFT")
    frame.spellIDBox:SetJustifyV("MIDDLE")
    frame.spellIDBox:SetTextColor(COLOR.Text:GetRGBA())
    frame.spellIDBox:SetAutoFocus(false)
    frame.spellIDBox:SetMultiLine(false)
    frame.spellIDBox:SetTextInsets(spacing, spacing, 0, 0)

    frame.spellIDBox.bg = frame.spellIDBox:CreateTexture(nil, "BACKGROUND")
    frame.spellIDBox.bg:SetAllPoints(frame.spellIDBox)
    frame.spellIDBox.bg:SetColorTexture(COLOR.ButtonBorder:GetRGBA())

    frame.spellIDBox.art = frame.spellIDBox:CreateTexture(nil, "ARTWORK")
    frame.spellIDBox.art:SetPoint("TOPLEFT", frame.spellIDBox, "TOPLEFT", SIZE.PANEL.BUTTON.Border, -SIZE.PANEL.BUTTON.Border)
    frame.spellIDBox.art:SetPoint("BOTTOMRIGHT", frame.spellIDBox, "BOTTOMRIGHT", -SIZE.PANEL.BUTTON.Border, SIZE.PANEL.BUTTON.Border)
    frame.spellIDBox.art:SetColorTexture(COLOR.ButtonMouseUp:GetRGBA())

    frame.spellIDBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    frame.spellIDBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    frame.addButton = UI.CreateButton(frame, "spellListAddButton", addButtonX, inputRowY, actionButtonWidth, SIZE.PANEL.BUTTON.Height, "新增")
    frame.deleteButton = UI.CreateButton(frame, "spellListDeleteButton", deleteButtonX, inputRowY, actionButtonWidth, SIZE.PANEL.BUTTON.Height, "删除")

    frame.listFrame = CreateFrame("Frame", addonName .. "spellListListFrame", frame)
    frame.listFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", spacing, listTopY)
    frame.listFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -spacing, spacing)
    frame.listFrame:EnableMouseWheel(true)
    frame.listFrame.bg, frame.listFrame.art = UI.ApplyBorderAndFill(frame.listFrame, COLOR.ButtonBorder, COLOR.DropdownBg, border)

    frame.emptyText = frame.listFrame:CreateFontString(nil, "OVERLAY")
    frame.emptyText:SetPoint("CENTER", frame.listFrame, "CENTER")
    frame.emptyText:SetFont(FontPath, GetUIScaleFactor(20), "")
    frame.emptyText:SetJustifyH("CENTER")
    frame.emptyText:SetJustifyV("MIDDLE")
    frame.emptyText:SetTextColor(0.65, 0.65, 0.65)
    frame.emptyText:SetText("暂无数据")
    frame.emptyText:Hide()

    frame.rows = {}
    for i = 1, maxRows do
        local row = CreateFrame("Frame", addonName .. "spellListRow" .. i, frame.listFrame)
        row:SetPoint("TOPLEFT", frame.listFrame, "TOPLEFT", border, -border - (i - 1) * lineHeight)
        row:SetPoint("TOPRIGHT", frame.listFrame, "TOPRIGHT", -border, -border - (i - 1) * lineHeight)
        row:SetHeight(lineHeight)
        row:EnableMouse(true)
        row:EnableMouseWheel(true)

        row.bg = row:CreateTexture(nil, "BACKGROUND")
        row.bg:SetAllPoints(row)
        row.bg:SetColorTexture(0, 0, 0, 0)

        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetPoint("LEFT", row, "LEFT", spacing, 0)
        row.icon:SetSize(lineHeight - border * 2, lineHeight - border * 2)
        row.icon:SetTexture(iconFallback)

        row.idText = row:CreateFontString(nil, "OVERLAY")
        row.idText:SetPoint("RIGHT", row, "RIGHT", -spacing, 0)
        row.idText:SetFont(FontPath, GetUIScaleFactor(18), "")
        row.idText:SetJustifyH("RIGHT")
        row.idText:SetJustifyV("MIDDLE")
        row.idText:SetTextColor(COLOR.Text:GetRGBA())

        row.nameText = row:CreateFontString(nil, "OVERLAY")
        row.nameText:SetPoint("LEFT", row.icon, "RIGHT", spacing, 0)
        row.nameText:SetPoint("RIGHT", row.idText, "LEFT", -spacing, 0)
        row.nameText:SetFont(FontPath, GetUIScaleFactor(20), "")
        row.nameText:SetJustifyH("LEFT")
        row.nameText:SetJustifyV("MIDDLE")
        row.nameText:SetTextColor(COLOR.Text:GetRGBA())

        frame.rows[i] = row
    end

    function frame:_ClampScrollOffset()
        local total = self._spellIDs and #self._spellIDs or 0
        local maxOffset = max(0, total - maxRows)
        if not self._scrollOffset then
            self._scrollOffset = 0
        end
        if self._scrollOffset < 0 then
            self._scrollOffset = 0
        elseif self._scrollOffset > maxOffset then
            self._scrollOffset = maxOffset
        end
    end

    function frame:_SetRowVisual(row)
        if row._spellID and self._selectedSpellID == row._spellID then
            row.bg:SetColorTexture(73 / 255, 179 / 255, 234 / 255, 0.35)
            return
        end
        if row._hovered then
            row.bg:SetColorTexture(COLOR.RowHover:GetRGBA())
            return
        end
        row.bg:SetColorTexture(0, 0, 0, 0)
    end

    function frame:RefreshList()
        self._spellIDs = CollectSpellIDs(self._currentData)
        self:_ClampScrollOffset()
        if #self._spellIDs == 0 then
            self.emptyText:Show()
        else
            self.emptyText:Hide()
        end

        for index, row in ipairs(self.rows) do
            local listIndex = (self._scrollOffset or 0) + index
            local spellID = self._spellIDs[listIndex]

            row._spellID = spellID
            row._hovered = false
            if spellID then
                local spellName = GetSpellName(spellID) or ""
                local iconID = GetSpellTexture(spellID) or iconFallback
                row.icon:SetTexture(iconID)
                row.nameText:SetText(spellName)
                row.idText:SetText(tostring(spellID))
                row:Show()
            else
                row.icon:SetTexture(iconFallback)
                row.nameText:SetText("")
                row.idText:SetText("")
                row:Hide()
            end
            self:_SetRowVisual(row)
        end
    end

    function frame:BindSetting(setting)
        self._currentSetting = setting
        if self.titleText then
            local title = "法术列表"
            if type(setting) == "table" then
                title = tostring(setting.name or setting.key or title)
            end
            self.titleText:SetText(title)
        end
        if type(setting) ~= "table" or not setting.bind_config then
            self._currentData = {}
        else
            self._currentData = CopySpellList(setting.bind_config:get_value())
        end
        self._selectedSpellID = nil
        self._scrollOffset = 0
        self.spellIDBox:SetText("")
        self:RefreshList()
    end

    function frame:PersistCurrentValue()
        if type(self._currentSetting) ~= "table" then
            return
        end
        local config = self._currentSetting.bind_config
        if not config then
            return
        end
        config:set_value(CopySpellList(self._currentData))
        self._currentData = CopySpellList(config:get_value())
    end

    local function GetInputSpellID()
        local text = frame.spellIDBox:GetText() or ""
        text = gsub(text, "%s+", "")
        return NormalizeSpellID(text)
    end

    frame.addButton:HookScript("OnMouseUp", function()
        if type(frame._currentSetting) ~= "table" then
            return
        end

        local spellID = GetInputSpellID()
        if not spellID then
            return
        end

        frame._currentData[spellID] = true
        frame._selectedSpellID = spellID
        frame.spellIDBox:SetText(tostring(spellID))
        frame:PersistCurrentValue()
        frame:RefreshList()
    end)

    frame.deleteButton:HookScript("OnMouseUp", function()
        if type(frame._currentSetting) ~= "table" then
            return
        end

        local spellID = GetInputSpellID()
        if not spellID then
            return
        end

        frame._currentData[spellID] = nil
        if frame._selectedSpellID == spellID then
            frame._selectedSpellID = nil
        end
        frame:PersistCurrentValue()
        frame:RefreshList()
    end)

    frame.listFrame:SetScript("OnMouseWheel", function(listFrame, delta)
        local editorFrame = listFrame:GetParent()
        if delta > 0 then
            editorFrame._scrollOffset = (editorFrame._scrollOffset or 0) - 1
        else
            editorFrame._scrollOffset = (editorFrame._scrollOffset or 0) + 1
        end
        editorFrame:_ClampScrollOffset()
        editorFrame:RefreshList()
    end)

    for rowIndex = 1, #frame.rows do
        local row = frame.rows[rowIndex]
        row:SetScript("OnMouseDown", function(self)
            if not self._spellID then
                return
            end
            frame._selectedSpellID = self._spellID
            frame.spellIDBox:SetText(tostring(self._spellID))
            frame:RefreshList()
        end)
        row:SetScript("OnEnter", function(self)
            if not self._spellID then
                return
            end
            self._hovered = true
            frame:_SetRowVisual(self)

            local spellID = self._spellID
            local spellName = GetSpellName(spellID) or "未知技能"
            local description = GetSpellDescription(spellID)
            if not description or description == "" then
                description = "无描述"
            end

            GameTooltip:SetOwner(self, "ANCHOR_RIGHT", spacing, 0)
            GameTooltip:SetFrameStrata("TOOLTIP")
            GameTooltip:SetFrameLevel(1000)
            GameTooltip:SetText("SpellID: " .. tostring(spellID), 1, 1, 1, 1, true)
            GameTooltip:AddLine(spellName, 0.9, 0.9, 0.9, true)
            GameTooltip:AddLine(description, 0.8, 0.8, 0.8, true)
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function(self)
            self._hovered = false
            frame:_SetRowVisual(self)
            GameTooltip:Hide()
        end)
        row:SetScript("OnMouseWheel", function(rowFrame, delta)
            local listMouseWheelScript = frame.listFrame:GetScript("OnMouseWheel")
            if listMouseWheelScript then
                listMouseWheelScript(rowFrame:GetParent(), delta)
            end
        end)
    end

    Panel.SpellListEditorFrame = frame
    return frame
end

local function AddSpellListRow(row_info)
    local config = row_info.bind_config
    ApplyDefaultValue(config, row_info.default_value)

    local row = CreateSettingRow(row_info.name, row_info.tooltip)
    if not row then
        return nil
    end

    local buttonX = SIZE.PANEL.SETTING_LINE.TitleWidth + SIZE.PANEL.SETTING_LINE.Spacing
    local buttonWidth = SIZE.PANEL.SETTING_LINE.WidgetWidth
    local button = UI.CreateButton(row, "spellListSettingButton" .. row:GetName(), buttonX, 0, buttonWidth, SIZE.PANEL.BUTTON.Height, "编辑")
    button:HookScript("OnMouseUp", function()
        local editor = EnsureSpellListEditorFrame()
        if not editor then
            return
        end
        if editor:IsShown() and editor._currentSetting == row_info then
            editor:Hide()
            return
        end
        editor:Show()
        editor:BindSetting(row_info)
    end)

    return row
end

local function CreatePanelRows()
    for rowIndex = 1, #ConfigRows do
        local row_info = ConfigRows[rowIndex]
        if row_info.type == "slider" then
            AddSliderRow(row_info)
        elseif row_info.type == "combo" then
            AddComboRow(row_info)
        elseif row_info.type == "spell_list" then
            AddSpellListRow(row_info)
        end
    end
end

insert(UIInitFuncs, CreatePanelFrame)
insert(UIInitFuncs, CreatePanelRows)

logging(addonName .. " Panel loaded.")

--[[
新增配置行示例（放在界面初始化前执行的文件中，例如 panel.lua 加载前的模块）：

local Config = addonTable.Config
local ConfigRows = addonTable.ConfigRows

table.insert(ConfigRows, {
    type = "slider",
    name = "提示时长",
    tooltip = "提示持续的秒数",
    bind_config = Config("hint_duration"),
    default_value = 5,
    min_value = 1,
    max_value = 10,
    step = 0.5,
})

table.insert(ConfigRows, {
    type = "combo",
    name = "显示方式",
    tooltip = "选择提示的显示方式",
    bind_config = Config("display_mode"),
    default_value = "text",
    options = {
        { k = "text", v = "文字" },
        { k = "icon", v = "图标" },
    },
})

table.insert(ConfigRows, {
    type = "spell_list",
    name = "关注的法术",
    tooltip = "点击编辑法术 ID 列表",
    bind_config = Config("tracked_spells"),
    default_value = {},
})
]]
