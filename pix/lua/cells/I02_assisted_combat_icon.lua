-- 显示一键辅助推荐技能，角标固定为玩家技能颜色。
local addonName, addonTable    = ...

-- lua 内置方法
local insert = table.insert
local random = math.random

-- wow api
local CreateFrame = CreateFrame
local After = C_Timer.After
local GetNextCastSpell = C_AssistedCombat.GetNextCastSpell
local GetSpellTexture = C_Spell.GetSpellTexture

-- 项目引用
local COLOR = addonTable.COLOR
local UIInitFuncs = addonTable.UIInitFuncs
local IconTile = addonTable.IconTile

-- 本地配置
local X = 2
local eventFrame = CreateFrame("Frame")
local display

local function Refresh()
    if not display then return end
    local spellID = GetNextCastSpell(false)
    if spellID == nil then display:Clear(); return end
    local color = COLOR.SPELL_TYPE.PLAYER_SPELL
    display:SetIcon(GetSpellTexture(spellID))
    display:SetBorderColor(color)
end

local function Initialize()
    display = IconTile:New(X)
    Refresh()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("SPELLS_CHANGED")
eventFrame:SetScript("OnEvent", function(_, event)
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
