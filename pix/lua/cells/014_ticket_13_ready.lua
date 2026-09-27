-- 冷却启用且可使用时为白色；沿用参考，不额外检查库存。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local random = math.random


-- WoW API
local CreateFrame = CreateFrame
local After = C_Timer.After
local EvaluateColorFromBoolean = C_CurveUtil.EvaluateColorFromBoolean
local GetItemCooldown = C_Item.GetItemCooldown
local IsUsableItem = C_Item.IsUsableItem
local GetInventoryItemID = GetInventoryItemID

-- 项目引用
local Cell = addonTable.Cell
local COLOR = addonTable.COLOR
local UIInitFuncs = addonTable.UIInitFuncs

-- 本地配置
local X = 14
local SLOT_ID = 13
local cell
local eventFrame = CreateFrame("Frame")

local function Update()
    if not cell then return end
    local itemID = GetInventoryItemID("player", SLOT_ID)
    local color = EvaluateColorFromBoolean(false, COLOR.WHITE, COLOR.BLACK)
    if itemID then
        local _, duration, enabled = GetItemCooldown(itemID)
        local usable, noMana = IsUsableItem(itemID)
        local resourceColor = EvaluateColorFromBoolean(noMana, COLOR.BLACK, COLOR.WHITE)
        local usableColor = EvaluateColorFromBoolean(usable, resourceColor, COLOR.BLACK)
        local cooldownColor = EvaluateColorFromBoolean(duration == 0, usableColor, COLOR.BLACK)
        color = EvaluateColorFromBoolean(enabled, cooldownColor, COLOR.BLACK)
    end
    cell:setCell(color)
end

local function Initialize()
    cell = Cell:New({ x = X })
    Update()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
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

