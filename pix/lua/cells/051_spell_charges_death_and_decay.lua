-- 单格灰度字节直接表示充能数；本技能为 0–2 次，缺失或零充能为黑色。
-- 秘密充能仅交给 string.format 和 SetText，不调用受执行环境限制的 FormatNumber。
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
local issecretvalue = issecretvalue
local GameFontNormal = GameFontNormal

-- 项目引用
local UIInitFuncs = addonTable.UIInitFuncs
local CellBackplate = addonTable.CellBackplate
local SIZE = addonTable.SIZE

-- 本地配置
local X = 51
local SPELL_IDS = { 43265 }
local eventFrame = CreateFrame("Frame")
local text

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
    if not text then return end
    if selectedSpellID then
        local chargeInfo = GetSpellCharges(selectedSpellID)
        if chargeInfo then
            local value = chargeInfo.currentCharges
            if not issecretvalue(value) and value == nil then
                value = 0
            end
            text:SetText(string.format("|cFF%02X%02X%02X█|r", value, value, value))
            return
        end
    end
    text:SetText("|cFF000000█|r")
end

local function Initialize()
    local backing = CellBackplate:New({ x = X })
    backing.Frame:SetClipsChildren(true)
    local fontPath = GameFontNormal:GetFont()
    text = backing.Frame:CreateFontString(nil, "ARTWORK")
    text:SetFont(fontPath, SIZE.CELL_FONT_SIZE, "")
    text:SetPoint("CENTER", backing.Frame, "CENTER")
    text:SetJustifyH("CENTER")
    text:SetJustifyV("MIDDLE")
    text:SetShadowOffset(0, 0)
    text:SetShadowColor(0, 0, 0, 0)
    text:SetTextColor(1, 1, 1, 1)
    text:SetFixedColor(false)
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
