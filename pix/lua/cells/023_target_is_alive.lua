-- 单位状态直接交给布尔颜色消费者。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local random = math.random


-- WoW API
local CreateFrame = CreateFrame
local After = C_Timer.After
local EvaluateColorFromBoolean = C_CurveUtil.EvaluateColorFromBoolean
local UnitExists = UnitExists
local UnitIsDeadOrGhost = UnitIsDeadOrGhost

-- 项目引用
local Cell = addonTable.Cell
local COLOR = addonTable.COLOR
local UIInitFuncs = addonTable.UIInitFuncs

-- 本地配置
local X = 23
local cell
local eventFrame = CreateFrame("Frame")

local function Update()
    if not cell then return end
    local stateColor = EvaluateColorFromBoolean(UnitIsDeadOrGhost("target"), COLOR.BLACK, COLOR.WHITE)
    local color = EvaluateColorFromBoolean(UnitExists("target"), stateColor, COLOR.BLACK)
    cell:setCell(color)
end

local function Initialize()
    cell = Cell:New({ x = X })
    Update()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
eventFrame:RegisterUnitEvent("UNIT_FLAGS", "target")
eventFrame:RegisterUnitEvent("UNIT_FACTION", "target")
eventFrame:RegisterUnitEvent("UNIT_HEALTH", "target")
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

