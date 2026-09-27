-- 技能射程；无单位或普通 nil 结果显示黑色。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local random = math.random


-- WoW API
local CreateFrame = CreateFrame
local After = C_Timer.After
local EvaluateColorFromBoolean = C_CurveUtil.EvaluateColorFromBoolean
local UnitExists = UnitExists
local IsSpellInRange = C_Spell.IsSpellInRange
local issecretvalue = issecretvalue

-- 项目引用
local Cell = addonTable.Cell
local COLOR = addonTable.COLOR
local UIInitFuncs = addonTable.UIInitFuncs

-- 本地配置
local X = 40
local SPELL_ID = 195292
local cell
local eventFrame = CreateFrame("Frame")

local function Update()
    if not cell then return end
    local inRange = IsSpellInRange(SPELL_ID, "focus")
    if not issecretvalue(inRange) and inRange == nil then
        inRange = false
    end
    local rangeColor = EvaluateColorFromBoolean(inRange, COLOR.WHITE, COLOR.BLACK)
    local color = EvaluateColorFromBoolean(UnitExists("focus"), rangeColor, COLOR.BLACK)
    cell:setCell(color)
end

local function Initialize()
    cell = Cell:New({ x = X })
    Update()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
eventFrame:RegisterEvent("SPELLS_CHANGED")

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

