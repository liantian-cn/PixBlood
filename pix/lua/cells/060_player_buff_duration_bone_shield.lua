-- 第 60 格显示玩家白骨之盾增益的剩余时间：越接近消失越黑，时间越久越白。
-- 原生光环容器负责匹配与显隐，永久增益露出白底，增益消失后露出黑底。
local addonName, addonTable    = ...

-- Lua 内置方法
local insert                  = table.insert
local ipairs                  = ipairs

-- WoW API
local CreateFrame             = CreateFrame
local After                   = C_Timer.After
local GameFontNormal          = GameFontNormal
local CreateDurationTextBinding = C_DurationUtil.CreateDurationTextBinding
local RemainingDuration       = Enum.DurationTextBindingProperty.RemainingDuration

-- 项目引用
local Cell                    = addonTable.Cell
local COLOR                   = addonTable.COLOR
local SIZE                    = addonTable.SIZE
local FrameLevel              = addonTable.FrameLevel
local UIInitFuncs             = addonTable.UIInitFuncs
local AuraRemaining           = addonTable.CURVE.AuraRemaining

-- 本地配置与状态
local X                       = 60
local AURA_IDS                = { 195181 }
local CHARACTER               = "█" -- U+2588：完整方块
local eventFrame              = CreateFrame("Frame")
local container

local function Refresh()
    if not container then
        return
    end
    container:UpdateAllAuras()
end

local function Initialize()
    local cell = Cell:New({ x = X })
    container = CreateFrame("AuraContainer", nil, cell.Frame, "CustomAuraContainerTemplate")
    container:SetAllPoints(cell.Frame)
    container:SetFrameLevel(FrameLevel.AuraContainer)
    container:SetUnit("player")

    local includeSpellIDs = {}
    for _, spellID in ipairs(AURA_IDS) do
        includeSpellIDs[spellID] = true
    end
    container:AddAuraSlot("aura", "HELPFUL|PLAYER", {
        candidateFilters = { includeSpellIDs = includeSpellIDs },
        initializeFrame = function(frame)
            frame:SetSize(SIZE.CELL, SIZE.CELL)
            frame:SetPoint("TOPLEFT", container, "TOPLEFT")
            frame:SetFrameLevel(FrameLevel.AuraButton)
            frame:SetClipsChildren(true)

            -- 白底随槽位显隐；永久增益的零时长文字为空，露出白底。
            local color = COLOR.WHITE
            local background = frame:CreateTexture(nil, "BACKGROUND")
            background:SetAllPoints(frame)
            background:SetTexture("Interface\\Buttons\\WHITE8X8")
            background:SetVertexColor(color:GetRGBA())

            local fontPath = GameFontNormal:GetFont()
            local text = frame:CreateFontString(nil, "ARTWORK")
            text:SetFont(fontPath, SIZE.CELL_FONT_SIZE, "")
            -- 只锚定中心，不限制文字宽高，让槽位裁剪完整字形。
            text:SetPoint("CENTER", frame, "CENTER", 0, 0)
            text:SetJustifyH("CENTER")
            text:SetJustifyV("MIDDLE")
            text:SetShadowOffset(0, 0)
            text:SetShadowColor(0, 0, 0, 0)
            text:SetTextColor(color:GetRGBA())

            local binding = CreateDurationTextBinding()
            binding:SetZeroDurationText("")
            -- 限时增益到期仍保留字符，由曲线的 0 秒黑色覆盖白底。
            binding:SetExpiredText(CHARACTER)
            frame:SetDurationText(text, {
                binding = binding,
                textFormat = { formatString = CHARACTER, components = {} },
                textColor = { curve = AuraRemaining, property = RemainingDuration },
            })
        end,
    })
    Refresh()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function()
    After(0, Refresh)
end)
insert(UIInitFuncs, Initialize)
