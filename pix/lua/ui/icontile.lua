--[[
    IconTileBackplate 与 IconTile 用法：
    两者都通过 :New(x) 创建，x 是从 1 开始的槽位编号，每槽宽两个 Cell。
    IconTileBackplate 只创建背板框体，可通过实例的 Frame 放置其他元素。
    IconTile 会自行创建背板；用 :SetIcon(iconID) 显示图标，
    用 :SetBorderColor(color) 显示着色角标，:Clear() 隐藏图标和角标但保留背板。
    调用前须已创建 addonTable.BackgroundFrame。

    简要示例：
    local backplate = addonTable.IconTileBackplate:New(1)
    local tile = addonTable.IconTile:New(2)
    tile:SetIcon(237581)
    tile:SetBorderColor(addonTable.COLOR.SPELL_TYPE.INTERRUPTIBLE)
    更完整的可运行用例见文件末尾。
]]

local addonName, addonTable = ...


local CreateFrame = CreateFrame
local setmetatable = setmetatable
local max = math.max

local SIZE = addonTable.SIZE
local FrameLevel = addonTable.FrameLevel
local BackgroundFrameResize = addonTable.BackgroundFrameResize

--[[  logical code  ]]
---@class IconTileBackplate
---@field Frame Frame 内容矩形
local IconTileBackplate = {}
IconTileBackplate.__index = IconTileBackplate

---@param x integer 从 1 开始的槽位编号
---@return IconTileBackplate
function IconTileBackplate:New(x)
    local parent = addonTable.BackgroundFrame
    local iconSize = 2 * SIZE.CELL
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(iconSize, iconSize)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", SIZE.CELL + (x - 1) * iconSize, -1 * SIZE.CELL)
    frame:SetFrameStrata("TOOLTIP")
    frame:SetFrameLevel(FrameLevel.Backplate)
    addonTable.IconTileLength = max(addonTable.IconTileLength, x * 2)
    BackgroundFrameResize()
    return setmetatable({ Frame = frame }, self)
end

addonTable.IconTileBackplate = IconTileBackplate


---@class IconTile
---@field Backplate IconTileBackplate 固定黑色背板
---@field Frame Frame 图标框体
---@field Background Texture 背景纹理
---@field Icon Texture 图标纹理
---@field Border Texture 边框纹理
---@field BorderColor ColorMixin 边框颜色
local IconTile = {}
IconTile.__index = IconTile

---IconTile 初始化方法（私有）
---@private
---@param x integer 从 1 开始的 IconTile 槽位编号
function IconTile:_initialize(x)
    self.Backplate = IconTileBackplate:New(x)
    local backgroundFrame = self.Backplate.Frame

    -- 图标层
    local icon = backgroundFrame:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints(backgroundFrame)
    icon:Hide()

    -- 边框层
    local border = backgroundFrame:CreateTexture(nil, "OVERLAY")
    border:SetAllPoints(backgroundFrame)
    border:SetTexture("Interface/AddOns/" .. addonName .. "/ui/aura_border_32_4px.tga")
    border:SetVertexColor(0, 0, 0, 0)
    border:Hide()

    self.Frame = backgroundFrame
    self.Icon = icon
    self.Border = border
    self.BorderColor = CreateColor(0, 0, 0, 0)
end

---创建图标槽位；调用前须已创建 addonTable.BackgroundFrame
---@param x integer 从 1 开始的 IconTile 槽位编号，每槽宽两个 Cell
---@return IconTile # 返回IconTile实例
function IconTile:New(x)
    local instance = setmetatable({}, self)
    instance:_initialize(x)
    return instance
end

---设置图标纹理
---@param iconID number|string 图标ID或纹理路径
function IconTile:SetIcon(iconID)
    self.Icon:SetTexture(iconID)
    self.Icon:Show()
end

---设置边框颜色
---@param color ColorMixin 颜色对象
function IconTile:SetBorderColor(color)
    self.BorderColor = color
    self.Border:SetVertexColor(color:GetRGBA())
    self.Border:Show()
end

---隐藏图标与角标，保留黑底和槽位占位
function IconTile:Clear()
    self.Icon:Hide()
    self.Border:Hide()
end

addonTable.IconTile = IconTile


-- local function demo()
--     local backplate = IconTileBackplate:New(1)
--     local tile = IconTile:New(2)
--     tile:SetIcon(237581)
--     tile:SetBorderColor(addonTable.COLOR.SPELL_TYPE.INTERRUPTIBLE)
-- end
-- table.insert(addonTable.UIInitFuncs, demo)
