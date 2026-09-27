-- 第 5 格显示玩家预测生命值比例：零为黑，满为白。
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
local X                        = 5
local cell
local eventFrame               = CreateFrame("Frame")

local function update()
    if not cell then return end
    local color = COLOR.BLACK
    if UnitExists("player") then
        color = UnitHealthPercent("player", true, percentCurve)
    end
    cell:setCell(color)
end

local function initialize()
    cell = Cell:New({ x = X })
    update()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterUnitEvent("UNIT_HEALTH", "player")
eventFrame:RegisterUnitEvent("UNIT_MAXHEALTH", "player")
eventFrame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", "player")
eventFrame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "player")
eventFrame:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", "player")
eventFrame:SetScript("OnEvent", function()
    After(0, update)
end)
insert(UIInitFuncs, initialize)
