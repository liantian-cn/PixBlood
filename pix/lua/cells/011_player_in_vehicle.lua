-- 普通坐骑和载具均视为乘坐状态。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local random = math.random


-- WoW API
local CreateFrame = CreateFrame
local After = C_Timer.After
local EvaluateColorFromBoolean = C_CurveUtil.EvaluateColorFromBoolean
local UnitInVehicle = UnitInVehicle
local IsMounted = IsMounted

-- 项目引用
local Cell = addonTable.Cell
local COLOR = addonTable.COLOR
local UIInitFuncs = addonTable.UIInitFuncs

-- 本地配置
local X = 11
local cell
local eventFrame = CreateFrame("Frame")

local function Update()
    if not cell then return end
    local mountedColor = EvaluateColorFromBoolean(IsMounted(), COLOR.WHITE, COLOR.BLACK)
    local color = EvaluateColorFromBoolean(UnitInVehicle("player"), COLOR.WHITE, mountedColor)
    cell:setCell(color)
end

local function Initialize()
    cell = Cell:New({ x = X })
    Update()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
eventFrame:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
eventFrame:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")
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

