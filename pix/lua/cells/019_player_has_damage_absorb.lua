-- 第 19 格显示玩家伤害吸收量严格超过 500000 的状态。
-- 秘密吸收值直接交给原生进度条，整数阈值以上显示白色。
local addonName, addonTable    = ...

-- Lua 内置方法
local insert                  = table.insert

-- WoW API
local CreateFrame             = CreateFrame
local After                   = C_Timer.After
local UnitGetTotalAbsorbs     = UnitGetTotalAbsorbs

-- 项目引用
local CellBackplate           = addonTable.CellBackplate
local COLOR                   = addonTable.COLOR
local FrameLevel              = addonTable.FrameLevel
local UIInitFuncs             = addonTable.UIInitFuncs

-- 本地配置与状态
local X                       = 19
local THRESHOLD               = 500000
local eventFrame              = CreateFrame("Frame")
local absorbBar

local function Refresh()
    if not absorbBar then
        return
    end
    local color = COLOR.WHITE
    absorbBar:SetColorFill(color:GetRGBA())
    absorbBar:SetValue(UnitGetTotalAbsorbs("player"))
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
eventFrame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "player")
eventFrame:SetScript("OnEvent", function()
    After(0, Refresh)
end)
insert(UIInitFuncs, Initialize)
