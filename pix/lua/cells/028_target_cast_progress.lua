-- 施法和引导经过比例从黑到白，空闲显示黑色。
local addonName, addonTable    = ...

-- lua 内置方法
local insert = table.insert
local random = math.random

-- wow api
local CreateFrame = CreateFrame
local After = C_Timer.After
local UnitExists = UnitExists
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local UnitCastingDuration = UnitCastingDuration
local UnitChannelDuration = UnitChannelDuration
local issecretvalue = issecretvalue

-- 项目引用
local COLOR = addonTable.COLOR
local UIInitFuncs = addonTable.UIInitFuncs
local Cell = addonTable.Cell
local percentCurve = addonTable.CURVE.percent

-- 本地配置
local X = 28
local eventFrame = CreateFrame("Frame")
local cell

local function Refresh()
    if not cell then return end
    local color = COLOR.BLACK
    if UnitExists("target") then
        local _, _, _, _, _, _, _, _, _, _, delayTime = UnitCastingInfo("target")
        local duration
        if delayTime ~= nil then
            duration = UnitCastingDuration("target")
        else
            local _, _, _, _, _, _, _, _, empowered = UnitChannelInfo("target")
            if empowered ~= nil then duration = UnitChannelDuration("target") end
        end
        -- duration 可能为秘密对象，仅对普通 nil 作空闲判断。
        if issecretvalue(duration) or duration ~= nil then
            color = duration:EvaluateElapsedPercent(percentCurve)
        end
    end
    cell:setCell(color)
end

local function Initialize()
    cell = Cell:New({ x = X })
    Refresh()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_START", "target")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "target")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", "target")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", "target")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED_QUIET", "target")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", "target")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "target")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "target")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "target")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", "target")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", "target")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", "target")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_UPDATE", "target")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", "target")
eventFrame:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", "target")
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
