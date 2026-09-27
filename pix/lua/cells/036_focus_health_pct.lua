-- 第 36 格显示焦点预测生命值比例：零为黑，满为白。
local addonName, addonTable    = ...

-- Lua 内置方法
local insert                   = table.insert

-- WoW API
local CreateFrame              = CreateFrame
local UnitExists               = UnitExists
local UnitHealthPercent        = UnitHealthPercent
local After                    = C_Timer.After

-- 项目引用
local Cell                     = addonTable.Cell
local COLOR                    = addonTable.COLOR
local percentCurve             = addonTable.CURVE.percent
local UIInitFuncs              = addonTable.UIInitFuncs

-- 本地配置与变量
local X                        = 36
local cell
local eventFrame               = CreateFrame("Frame")

local function update()
    if not cell then return end
    local color = COLOR.BLACK
    if UnitExists("focus") then
        color = UnitHealthPercent("focus", true, percentCurve)
    end
    cell:setCell(color)
end

local function initialize()
    cell = Cell:New({ x = X })
    update()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
eventFrame:RegisterUnitEvent("UNIT_HEALTH", "focus")
eventFrame:RegisterUnitEvent("UNIT_MAXHEALTH", "focus")
eventFrame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", "focus")
eventFrame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "focus")
eventFrame:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", "focus")
eventFrame:SetScript("OnEvent", function()
    After(0, update)
end)
insert(UIInitFuncs, initialize)
