-- 第 66 格显示沸点事件触发的本地 3 秒窗口，不读取真实光环剩余时间。
-- RGB 字节值为向上取整的剩余十分之一秒（0～30）。
local addonName, addonTable = ...

-- Lua 内置方法
local insert = table.insert
local ceil = math.ceil
local min = math.min
local max = math.max

-- WoW API
local CreateFrame = CreateFrame
local GetTime = GetTime
local issecretvalue = issecretvalue

-- 项目引用
local Cell = addonTable.Cell
local UIInitFuncs = addonTable.UIInitFuncs

local X = 66
local SPELL_ID = 1265982
local DURATION = 3
local deadline = 0
local elapsedTime = 0
local cell
local eventFrame = CreateFrame("Frame")

local function Refresh()
    if not cell then return end
    local remaining = max(0, min(DURATION, deadline - GetTime()))
    local brightness = ceil(remaining * 10) / 255
    cell:setCellRGBA(brightness, brightness, brightness)
end

local function Initialize()
    cell = Cell:New({ x = X })
    Refresh()
end

eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
eventFrame:SetScript("OnEvent", function(_, event, spellID)
    if event == "PLAYER_ENTERING_WORLD" then
        deadline = 0
    else
        if issecretvalue(spellID) or spellID ~= SPELL_ID then return end
        deadline = GetTime() + DURATION
    end
    elapsedTime = 0
    Refresh()
end)
eventFrame:SetScript("OnUpdate", function(_, elapsed)
    elapsedTime = elapsedTime + elapsed
    if elapsedTime >= 0.1 then
        elapsedTime = elapsedTime % 0.1
        Refresh()
    end
end)
insert(UIInitFuncs, Initialize)
