-- 灰度字节直接表示打断进度阈值，默认30%，范围10%至90%。
local _, addonTable = ...
local config = addonTable.Config("interrupt_progress_threshold")
config:set_default(30)
local cell

local function Refresh()
    if not cell then return end
    local value = math.floor(math.max(10, math.min(90, tonumber(config:get_value()) or 30)) + 0.5)
    local gray = value / 255
    cell:setCellRGBA(gray, gray, gray)
end

table.insert(addonTable.ConfigRows, {
    type = "slider", name = "打断进度（%）",
    tooltip = "焦点和目标的施法或引导已经过进度严格超过此百分比后才允许打断。",
    bind_config = config, default_value = 30, min_value = 10, max_value = 90, step = 1,
})
config:register_callback(Refresh)

table.insert(addonTable.UIInitFuncs, function()
    cell = addonTable.Cell:New({ x = 64 })
    Refresh()
end)
