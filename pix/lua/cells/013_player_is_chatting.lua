-- 任意输入框持有键盘焦点时为白色。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local random = math.random


-- WoW API
local CreateFrame = CreateFrame
local After = C_Timer.After
local EvaluateColorFromBoolean = C_CurveUtil.EvaluateColorFromBoolean
local GetCurrentKeyBoardFocus = GetCurrentKeyBoardFocus

-- 项目引用
local Cell = addonTable.Cell
local COLOR = addonTable.COLOR
local UIInitFuncs = addonTable.UIInitFuncs

-- 本地配置
local X = 13

local cell
local eventFrame = CreateFrame("Frame")

local function Update()
    if not cell then return end
    local color = EvaluateColorFromBoolean(GetCurrentKeyBoardFocus() ~= nil, COLOR.WHITE, COLOR.BLACK)
    cell:setCell(color)
end

local function Initialize()
    cell = Cell:New({ x = X })
    Update()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")


eventFrame:SetScript("OnEvent", function()
    After(0, Update)
end)

local elapsedTime = -random() * 0.1
eventFrame:SetScript("OnUpdate", function(_, elapsed)
    elapsedTime = elapsedTime + elapsed
    if elapsedTime >= 0.1 then
        elapsedTime = elapsedTime % 0.1
        Update()
    end
end)
insert(UIInitFuncs, Initialize)

