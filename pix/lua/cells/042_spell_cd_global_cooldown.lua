-- 使用共享非线性剩余时间曲线显示冷却，就绪白色，不可用黑色。
local addonName, addonTable    = ...

-- lua 内置方法
local insert                   = table.insert
local random                   = math.random

-- wow api
local CreateFrame              = CreateFrame
local After                    = C_Timer.After
local GetSpellCooldownDuration = C_Spell.GetSpellCooldownDuration

-- 项目引用
local COLOR                    = addonTable.COLOR
local UIInitFuncs              = addonTable.UIInitFuncs
local Cell                     = addonTable.Cell
local remainingCurve           = addonTable.CURVE.SpellColddownRemaining

-- 本地配置
local X                        = 42
local SPELL_IDS                = { 61304 }
local eventFrame               = CreateFrame("Frame")
local cell

local function Refresh()
    if not cell then return end
    local color = COLOR.BLACK
    -- GCD 监测技能不依赖法术书条目。
    local duration = GetSpellCooldownDuration(SPELL_IDS[1], false)
    if duration then color = duration:EvaluateRemainingDuration(remainingCurve) end
    cell:setCell(color)
end

local function Initialize()
    cell = Cell:New({ x = X })
    Refresh()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("SPELLS_CHANGED")
eventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
eventFrame:SetScript("OnEvent", function()
    After(0, function()
        Refresh()
    end)
end)
local elapsedTime = -random() * 0.1
eventFrame:SetScript("OnUpdate", function(_, elapsed)
    elapsedTime = elapsedTime + elapsed
    if elapsedTime >= 0.1 then
        elapsedTime = elapsedTime % 0.1
        Refresh()
    end
end)
insert(UIInitFuncs, Initialize)
