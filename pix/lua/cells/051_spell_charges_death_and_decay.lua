-- 充能数直接送入数值条；内容宽度与最大充能量程独立。
local addonName, addonTable    = ...

-- lua 内置方法
local insert = table.insert
local random = math.random
local ipairs = ipairs

-- wow api
local CreateFrame = CreateFrame
local After = C_Timer.After
local IsSpellInSpellBook = C_SpellBook.IsSpellInSpellBook
local GetSpellCharges = C_Spell.GetSpellCharges

-- 项目引用
local COLOR = addonTable.COLOR
local UIInitFuncs = addonTable.UIInitFuncs
local ValueBar = addonTable.ValueBar

-- 本地配置
local X = 51
local WIDTH = 2
local MAX_CHARGES = 2
local SPELL_IDS = { 43265 }
local eventFrame = CreateFrame("Frame")
local bar

local selectedSpellID
local function SelectSpell()
    selectedSpellID = nil
    for _, spellID in ipairs(SPELL_IDS) do
        if IsSpellInSpellBook(spellID) then
            selectedSpellID = spellID
            return
        end
    end
end

local function Refresh()
    if not bar then return end
    local color = COLOR.WHITE
    bar.StatusBar:SetColorFill(color:GetRGBA())
    if selectedSpellID then
        local chargeInfo = GetSpellCharges(selectedSpellID)
        if chargeInfo then
            bar:setValue(chargeInfo.currentCharges)
            return
        end
    end
    bar:setValue(0)
end

local function Initialize()
    bar = ValueBar:New(X, WIDTH)
    bar:setMinMaxValues(0, MAX_CHARGES)
    SelectSpell()
    Refresh()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("SPELLS_CHANGED")
eventFrame:RegisterEvent("SPELL_UPDATE_CHARGES")
eventFrame:RegisterEvent("SPELL_UPDATE_USES")
eventFrame:SetScript("OnEvent", function(_, event)
    After(0, function()
        if event == "PLAYER_ENTERING_WORLD" or event == "SPELLS_CHANGED" then SelectSpell() end
        Refresh()
    end)
end)
local elapsedTime = -random()
eventFrame:SetScript("OnUpdate", function(_, elapsed)
    elapsedTime = elapsedTime + elapsed
    if elapsedTime >= 1 then
        elapsedTime = elapsedTime % 1
        Refresh()
    end
end)
insert(UIInitFuncs, Initialize)
