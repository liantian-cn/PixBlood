-- 第 49 格显示目标的血之疫病减益：存在为白色，否则为黑色。
-- 原生光环容器负责匹配与显隐，不读取秘密光环数据。
local addonName, addonTable    = ...

-- Lua 内置方法
local insert                  = table.insert
local ipairs                  = ipairs

-- WoW API
local CreateFrame             = CreateFrame
local After                   = C_Timer.After
local UnitExists              = UnitExists
local UnitCanAssist           = UnitCanAssist

-- 项目引用
local Cell                    = addonTable.Cell
local COLOR                   = addonTable.COLOR
local SIZE                    = addonTable.SIZE
local FrameLevel              = addonTable.FrameLevel
local UIInitFuncs             = addonTable.UIInitFuncs

-- 本地配置与状态
local X                       = 49
local AURA_IDS                = { 55078 }
local eventFrame              = CreateFrame("Frame")
local container

local function Refresh()
    if not container then
        return
    end
    -- 友方减益的身份筛选可能被忽略，只在不可协助目标上显示。
    container:SetShown(UnitExists("target") and not UnitCanAssist("player", "target", true, true))
    container:UpdateAllAuras()
end

local function Initialize()
    local cell = Cell:New({ x = X })
    container = CreateFrame("AuraContainer", nil, cell.Frame, "CustomAuraContainerTemplate")
    container:SetAllPoints(cell.Frame)
    container:SetFrameLevel(FrameLevel.AuraContainer)
    container:SetUnit("target")

    local includeSpellIDs = {}
    for _, spellID in ipairs(AURA_IDS) do
        includeSpellIDs[spellID] = true
    end
    container:AddAuraSlot("aura", "HARMFUL|PLAYER", {
        candidateFilters = { includeSpellIDs = includeSpellIDs },
        initializeFrame = function(frame)
            frame:SetSize(SIZE.CELL, SIZE.CELL)
            frame:SetPoint("TOPLEFT", container, "TOPLEFT")
            frame:SetFrameLevel(FrameLevel.AuraButton)
            local color = COLOR.WHITE
            local overlay = frame:CreateTexture(nil, "OVERLAY")
            overlay:SetAllPoints(frame)
            overlay:SetTexture("Interface\\Buttons\\WHITE8X8")
            overlay:SetVertexColor(color:GetRGBA())
        end,
    })
    Refresh()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
eventFrame:RegisterUnitEvent("UNIT_FACTION", "player", "target")
eventFrame:RegisterUnitEvent("UNIT_FLAGS", "target")
eventFrame:SetScript("OnEvent", function()
    After(0, Refresh)
end)
insert(UIInitFuncs, Initialize)
