-- 第 61–64 格显示白骨之盾层数；内容宽 3 格，12 层填满。
-- 原生光环槽管理层数条，光环消失后露出黑底。
local addonName, addonTable    = ...

-- Lua 内置方法
local insert                  = table.insert
local ipairs                  = ipairs

-- WoW API
local CreateFrame             = CreateFrame
local After                   = C_Timer.After

-- 项目引用
local ValueBarBackplate        = addonTable.ValueBarBackplate
local COLOR                   = addonTable.COLOR
local SIZE                    = addonTable.SIZE
local FrameLevel              = addonTable.FrameLevel
local UIInitFuncs             = addonTable.UIInitFuncs

-- 本地配置与状态
local X                       = 61
local WIDTH                   = 3
local AURA_IDS                = { 195181 }
local MAX_APPLICATIONS        = 12
local eventFrame              = CreateFrame("Frame")
local container

local function Refresh()
    if not container then
        return
    end
    container:UpdateAllAuras()
end

local function Initialize()
    local backing = ValueBarBackplate:New(X, WIDTH)
    container = CreateFrame("AuraContainer", nil, backing.Frame, "CustomAuraContainerTemplate")
    container:SetAllPoints(backing.Frame)
    container:SetFrameLevel(FrameLevel.AuraContainer)
    container:SetUnit("player")

    local includeSpellIDs = {}
    for _, spellID in ipairs(AURA_IDS) do
        includeSpellIDs[spellID] = true
    end
    container:AddAuraSlot("aura", "HELPFUL|PLAYER", {
        candidateFilters = { includeSpellIDs = includeSpellIDs },
        initializeFrame = function(frame)
            frame:SetSize(WIDTH * SIZE.CELL, SIZE.CELL)
            frame:SetPoint("TOPLEFT", container, "TOPLEFT")
            frame:SetFrameLevel(FrameLevel.AuraButton)
            local color = COLOR.WHITE
            local bar = CreateFrame("StatusBar", nil, frame)
            bar:SetAllPoints(frame)
            bar:SetFrameLevel(FrameLevel.AuraContent)
            bar:SetOrientation("HORIZONTAL")
            bar:SetColorFill(color:GetRGBA())
            frame:SetApplicationBar(bar, { maxApplications = MAX_APPLICATIONS })
        end,
    })
    Refresh()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function()
    After(0, Refresh)
end)
insert(UIInitFuncs, Initialize)
