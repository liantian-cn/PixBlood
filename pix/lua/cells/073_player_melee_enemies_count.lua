-- 只统计可观察姓名板；秘密或 nil 射程不计入，不代表全部附近敌人。
local addonName, addonTable = ...

local insert = table.insert
local random = math.random

local CreateFrame = CreateFrame
local After = C_Timer.After
local IsSpellInRange = C_Spell.IsSpellInRange
local DoesSpellExist = C_Spell.DoesSpellExist
local issecretvalue = issecretvalue
local UnitExists = UnitExists
local UnitCanAttack = UnitCanAttack
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitAffectingCombat = UnitAffectingCombat

local Cell = addonTable.Cell
local UIInitFuncs = addonTable.UIInitFuncs

local X = 73
local SPELL_ID = 49998
local COMBAT_ONLY = false
local NAMEPLATE_LIMIT = 40
local UPDATE_INTERVAL = 0.2
local cell
local eventFrame = CreateFrame("Frame")

local function Update()
    if not cell then return end
    if not DoesSpellExist(SPELL_ID) then
        cell:clearCell()
        return
    end

    local count = 0
    for index = 1, NAMEPLATE_LIMIT do
        local unit = "nameplate" .. index
        if UnitExists(unit)
            and UnitCanAttack("player", unit)
            and not UnitIsDeadOrGhost(unit)
            and (not COMBAT_ONLY or UnitAffectingCombat(unit))
        then
            local inRange = IsSpellInRange(SPELL_ID, unit)
            if not issecretvalue(inRange) and inRange == true then
                count = count + 1
            end
        end
    end
    local value = count / NAMEPLATE_LIMIT
    cell:setCellRGBA(value, value, value)
end

local function Initialize()
    cell = Cell:New({ x = X })
    Update()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
eventFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
eventFrame:SetScript("OnEvent", function()
    After(0, Update)
end)

local elapsedTime = -random() * UPDATE_INTERVAL
eventFrame:SetScript("OnUpdate", function(_, elapsed)
    elapsedTime = elapsedTime + elapsed
    if elapsedTime >= UPDATE_INTERVAL then
        elapsedTime = elapsedTime % UPDATE_INTERVAL
        Update()
    end
end)
insert(UIInitFuncs, Initialize)
