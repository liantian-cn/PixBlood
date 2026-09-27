-- 每 0.1 秒重查 mouseover 存在与灵界打击射程；无单位或普通 nil 时清黑。
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
local X = 71
local SPELL_ID = 49998
local cell
local eventFrame = CreateFrame("Frame")

local function Update()
    if not cell then return end
    local inRange = IsSpellInRange(SPELL_ID, "mouseover")
    if not issecretvalue(inRange) and inRange == nil then
        inRange = false
    end
    local rangeColor = EvaluateColorFromBoolean(inRange, COLOR.WHITE, COLOR.BLACK)
    local color = EvaluateColorFromBoolean(UnitExists("mouseover"), rangeColor, COLOR.BLACK)
    cell:setCell(color)
end

local function Initialize()
    cell = Cell:New({ x = X })
    Update()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
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
