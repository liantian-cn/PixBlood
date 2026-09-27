-- 显示当前施法或引导图标，空闲时清空图标和角标。
local addonName, addonTable    = ...

-- lua 内置方法
local insert = table.insert
local random = math.random

-- wow api
local CreateFrame = CreateFrame
local After = C_Timer.After
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitExists = UnitExists

-- 项目引用
local COLOR = addonTable.COLOR
local UIInitFuncs = addonTable.UIInitFuncs
local IconTile = addonTable.IconTile

-- 本地配置
local X = 1
local eventFrame = CreateFrame("Frame")
local display

local function Refresh()
    if not display then return end
    if not UnitExists("player") then display:Clear(); return end
    local _, _, texture, _, _, _, _, _, _, _, delayTime = UnitCastingInfo("player")
    if delayTime == nil then
        local _, _, channelTexture, _, _, _, _, _, empowered = UnitChannelInfo("player")
        if empowered == nil then display:Clear(); return end
        texture = channelTexture
    end
    local color = COLOR.SPELL_TYPE.PLAYER_SPELL
    display:SetIcon(texture)
    display:SetBorderColor(color)
end

local function Initialize()
    display = IconTile:New(X)
    Refresh()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "player")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "player")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED_QUIET", "player")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", "player")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", "player")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", "player")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", "player")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_UPDATE", "player")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", "player")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", "player")
eventFrame:SetScript("OnEvent", function(_, event)
    After(0, function()
        Refresh()
    end)
end)
local elapsedTime = -random() * 0.1
eventFrame:SetScript("OnUpdate", function(_, elapsed)
    elapsedTime = elapsedTime + elapsed
    if elapsedTime >= 0.1 then
        elapsedTime = elapsedTime % 0.1
        Refresh()
    end
end)
insert(UIInitFuncs, Initialize)
