-- 固定十五槽的打断黑名单；按法术 ID 升序取前十五项，加载失败留空不补位。
local addonName, addonTable = ...

local insert = table.insert
local sort = table.sort
local pairs = pairs
local type = type
local tonumber = tonumber
local floor = math.floor

local CreateFrame = CreateFrame
local After = C_Timer.After
local GetSpellTexture = C_Spell.GetSpellTexture
local RequestLoadSpellData = C_Spell.RequestLoadSpellData

local Config = addonTable.Config
local ConfigRows = addonTable.ConfigRows
local IconTile = addonTable.IconTile
local COLOR = addonTable.COLOR
local UIInitFuncs = addonTable.UIInitFuncs

local X = 5
local SLOT_COUNT = 15
local DEFAULT_IDS = {
    [1241214] = true, -- 地语看护者[大地之箭]
    [1228176] = true, -- 被奴役的萨满 [熔岩箭]
    [371984] = true,  -- [寒冰箭]
    [384194] = true,  -- 拜荒织烬者 [焰烬之箭]
    [1294815] = true, -- 复活的妖术师 [暗影冰霜箭]
}
local config = Config("interrupt_blacklist")
local displays = {}
local configured = {}
local selected = {}
local eventFrame = CreateFrame("Frame")

-- 默认值由先执行的面板初始化应用，已有保存值（包括空表）优先。
insert(ConfigRows, {
    type = "spell_list",
    name = "打断黑名单",
    tooltip = "点击编辑法术 ID 列表；按 ID 升序仅前十五项参与匹配，黄色角标表示黑名单图标。",
    bind_config = config,
    default_value = DEFAULT_IDS,
})

local function Render()
    for index = 1, SLOT_COUNT do
        local display = displays[index]
        if display then
            display:Clear()
            local spellID = selected[index]
            if spellID then
                local texture = GetSpellTexture(spellID)
                -- 这里只处理配置中的普通 ID；失败留黑，不使用备用问号图标。
                if texture and display.Icon:SetTexture(texture) then
                    display.Icon:Show()
                    display:SetBorderColor(COLOR.SPELL_TYPE.INTERRUPTIBLE)
                end
            end
        end
    end
end

local function RefreshConfiguration()
    configured = {}
    selected = {}
    local values = config:get_value()
    if type(values) == "table" then
        for rawID, enabled in pairs(values) do
            local spellID = tonumber(rawID)
            if enabled and spellID and spellID > 0 and spellID == floor(spellID) and not configured[spellID] then
                configured[spellID] = true
                insert(selected, spellID)
            end
        end
    end
    sort(selected)
    -- 每次配置刷新请求一次；不按加载成功数补位，不循环重试。
    for index = 1, #selected do
        RequestLoadSpellData(selected[index])
    end
    Render()
end

local function Initialize()
    for index = 1, SLOT_COUNT do
        displays[index] = IconTile:New(X + index - 1)
    end
    RefreshConfiguration()
end

config:register_callback(RefreshConfiguration)
eventFrame:RegisterEvent("SPELL_DATA_LOAD_RESULT")
eventFrame:SetScript("OnEvent", function(_, _, spellID, success)
    if success and configured[spellID] then
        After(0, function()
            -- 删除后的迟到事件不能恢复旧图标。
            if configured[spellID] then Render() end
        end)
    end
end)
insert(UIInitFuncs, Initialize)
