-- 圣光潜力：非银行库存大于零且冷却结束；不检查额外可用性。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local random = math.random


-- WoW API
local CreateFrame = CreateFrame
local After = C_Timer.After
local EvaluateColorFromBoolean = C_CurveUtil.EvaluateColorFromBoolean
local GetItemCount = C_Item.GetItemCount
local GetItemCooldown = C_Item.GetItemCooldown
local GetTime = GetTime

-- 项目引用
local Cell = addonTable.Cell
local COLOR = addonTable.COLOR
local UIInitFuncs = addonTable.UIInitFuncs

-- 本地配置
local X = 54
local ITEM_ID = 241308
local cell
local eventFrame = CreateFrame("Frame")

local function Update()
    if not cell then return end
    local count = GetItemCount(ITEM_ID, false, false, false, false)
    local start, duration, enabled = GetItemCooldown(ITEM_ID)
    local cooldownReady = duration == 0 or start + duration <= GetTime()
    local cooldownColor = EvaluateColorFromBoolean(cooldownReady, COLOR.WHITE, COLOR.BLACK)
    local enabledColor = EvaluateColorFromBoolean(enabled, cooldownColor, COLOR.BLACK)
    local color = EvaluateColorFromBoolean(count > 0, enabledColor, COLOR.BLACK)
    cell:setCell(color)
end

local function Initialize()
    cell = Cell:New({ x = X })
    Update()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("BAG_UPDATE")
eventFrame:RegisterEvent("BAG_UPDATE_COOLDOWN")
eventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")

eventFrame:SetScript("OnEvent", function()
    After(0, Update)
end)

local elapsedTime = -random()
eventFrame:SetScript("OnUpdate", function(_, elapsed)
    elapsedTime = elapsedTime + elapsed
    if elapsedTime >= 1 then
        elapsedTime = elapsedTime % 1
        Update()
    end
end)
insert(UIInitFuncs, Initialize)

