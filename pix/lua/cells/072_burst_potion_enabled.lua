-- 独立爆发药水开关：通过现有面板 combo 配置，默认关闭。
local addonName, addonTable = ...

local insert = table.insert
local Cell = addonTable.Cell
local COLOR = addonTable.COLOR
local Config = addonTable.Config
local ConfigRows = addonTable.ConfigRows
local UIInitFuncs = addonTable.UIInitFuncs

local X = 72
local config = Config("burst_potion_enabled")
local cell
config:set_default(false)

insert(ConfigRows, {
    type = "combo",
    name = "爆发药水",
    tooltip = "独立控制轮转使用圣光潜力，不随爆发开关联动。",
    bind_config = config,
    default_value = false,
    options = {
        { k = false, v = "关闭" },
        { k = true, v = "开启" },
    },
})

local function Refresh()
    if not cell then return end
    cell:setCell(config:get_value() == true and COLOR.WHITE or COLOR.BLACK)
end

local function Initialize()
    cell = Cell:New({ x = X })
    Refresh()
end

config:register_callback(Refresh)
insert(UIInitFuncs, Initialize)
