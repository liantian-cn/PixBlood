-- 第 6 格显示符文能量比例：零为黑，满为白。
local addonName, addonTable    = ...

-- Lua 内置方法
local insert                   = table.insert

-- WoW API
local CreateFrame              = CreateFrame
local UnitPowerPercent         = UnitPowerPercent
local After                    = C_Timer.After
local RunicPower               = Enum.PowerType.RunicPower

-- 项目引用
local Cell                     = addonTable.Cell
local percentCurve             = addonTable.CURVE.percent
local UIInitFuncs              = addonTable.UIInitFuncs

-- 本地配置与变量
local X                        = 6
local cell
local eventFrame               = CreateFrame("Frame")

local function update()
    if not cell then return end
    local color = UnitPowerPercent("player", RunicPower, false, percentCurve)
    cell:setCell(color)
end

local function initialize()
    cell = Cell:New({ x = X })
    update()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
eventFrame:RegisterUnitEvent("UNIT_MAXPOWER", "player")
eventFrame:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
eventFrame:SetScript("OnEvent", function()
    After(0, update)
end)
insert(UIInitFuncs, initialize)
