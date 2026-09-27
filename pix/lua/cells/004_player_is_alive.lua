-- 玩家存活时白色；死亡或灵魂状态为黑色。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local random = math.random


-- WoW API
local CreateFrame = CreateFrame
local After = C_Timer.After
local EvaluateColorFromBoolean = C_CurveUtil.EvaluateColorFromBoolean
local UnitIsDeadOrGhost = UnitIsDeadOrGhost

-- 项目引用
local Cell = addonTable.Cell
local COLOR = addonTable.COLOR
local UIInitFuncs = addonTable.UIInitFuncs

-- 本地配置
local X = 4
local cell
local eventFrame = CreateFrame("Frame")

local function Update()
    if not cell then return end
    local color = EvaluateColorFromBoolean(UnitIsDeadOrGhost("player"), COLOR.BLACK, COLOR.WHITE)
    cell:setCell(color)
end

local function Initialize()
    cell = Cell:New({ x = X })
    Update()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_DEAD")
eventFrame:RegisterEvent("PLAYER_ALIVE")
eventFrame:RegisterEvent("PLAYER_UNGHOST")
eventFrame:RegisterUnitEvent("UNIT_HEALTH", "player")
eventFrame:RegisterUnitEvent("UNIT_FLAGS", "player")
eventFrame:SetScript("OnEvent", function()
    After(0, Update)
end)

local elapsedTime = -random()
eventFrame:SetScript("OnUpdate", function(_, elapsed)
    elapsedTime = elapsedTime + elapsed
    if elapsedTime >= 1 then
        elapsedTime = elapsedTime % 1
        Update()
    end
end)
insert(UIInitFuncs, Initialize)

