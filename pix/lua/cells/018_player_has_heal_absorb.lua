-- 第 18 格显示玩家治疗吸收量严格超过 250000 的状态。
-- 秘密吸收值直接交给原生进度条，整数阈值以上显示白色。
local addonName, addonTable    = ...

-- Lua 内置方法
local insert                  = table.insert

-- WoW API
local CreateFrame             = CreateFrame
local After                   = C_Timer.After
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs

-- 项目引用
local CellBackplate           = addonTable.CellBackplate
local COLOR                   = addonTable.COLOR
local FrameLevel              = addonTable.FrameLevel
local UIInitFuncs             = addonTable.UIInitFuncs

-- 本地配置与状态
local X                       = 18
local THRESHOLD               = 250000
local eventFrame              = CreateFrame("Frame")
local absorbBar

local function Refresh()
    if not absorbBar then
        return
    end
    local color = COLOR.WHITE
    absorbBar:SetColorFill(color:GetRGBA())
    absorbBar:SetValue(UnitGetTotalHealAbsorbs("player"))
end

local function Initialize()
    local backing = CellBackplate:New({ x = X })
    absorbBar = CreateFrame("StatusBar", nil, backing.Frame)
    absorbBar:SetAllPoints(backing.Frame)
    absorbBar:SetFrameLevel(FrameLevel.Content)
    absorbBar:SetMinMaxValues(THRESHOLD, THRESHOLD + 1)
    Refresh()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", "player")
eventFrame:SetScript("OnEvent", function()
    After(0, Refresh)
end)
insert(UIInitFuncs, Initialize)
