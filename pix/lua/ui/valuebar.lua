--[[
    ValueBarBackplate 与 ValueBar 用法：
    两者都通过 :New(x, width) 创建；x 是包含左侧分隔的占位起点，
    width 是不含两侧红色分隔的黑色内容宽度，单位均为 Cell。
    完整占位宽度为 width + 1 个 Cell。
    ValueBarBackplate 只创建红色分隔与黑色内容背景，可通过 Frame 放置其他元素。
    ValueBar 在背板上创建白色填充条，可通过 :setMinMaxValues(min, max)
    和 :setValue(value) 更新数值；:New(x, width, true) 可反向填充。

    简要示例：
    local bar = addonTable.ValueBar:New(3, 5)
    bar:setValue(25)
    local backplate = addonTable.ValueBarBackplate:New(9, 5)
    实际运行的用例见文件末尾。
]]

local addonName, addonTable = ...

local CreateFrame = CreateFrame
local setmetatable = setmetatable
local max = math.max

local SIZE = addonTable.SIZE
local COLOR = addonTable.COLOR
local FrameLevel = addonTable.FrameLevel
local BackgroundFrameResize = addonTable.BackgroundFrameResize

---@class ValueBarBackplate
---@field Frame Frame 不含分隔的内容矩形
---@field BackgroundTexture Texture 固定黑底
---@field SeparatorFrame Frame 含左右分隔的红底矩形
---@field SeparatorTexture Texture 固定红色分隔
local ValueBarBackplate = {}
ValueBarBackplate.__index = ValueBarBackplate

---@param x integer 含左侧分隔的占位起点，以 Cell 为单位
---@param width number 黑色内容宽度，以 Cell 为单位
---@return ValueBarBackplate
function ValueBarBackplate:New(x, width)
    local parent = addonTable.BackgroundFrame
    local barName = addonName .. "Bar_" .. x
    local separator = CreateFrame("Frame", barName .. "separatorFrame", parent)
    separator:SetPoint("TOPLEFT", parent, "TOPLEFT", x * SIZE.CELL, 0)
    separator:SetFrameStrata("TOOLTIP")
    separator:SetFrameLevel(FrameLevel.Separator)
    separator:SetSize((width + 1) * SIZE.CELL, SIZE.CELL)
    separator:Show()
    local separatorTexture = separator:CreateTexture(nil, "BACKGROUND")
    separatorTexture:SetAllPoints()
    separatorTexture:SetColorTexture(COLOR.RED:GetRGBA())
    local frame = CreateFrame("Frame", barName .. "backgroundFrame", separator)
    frame:SetPoint("TOPLEFT", separator, "TOPLEFT", 0.5 * SIZE.CELL, 0)
    frame:SetPoint("BOTTOMRIGHT", separator, "BOTTOMRIGHT", -0.5 * SIZE.CELL, 0)
    frame:SetFrameStrata("TOOLTIP")
    frame:SetFrameLevel(FrameLevel.Backplate)
    frame:Show()
    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints()
    texture:SetColorTexture(COLOR.BLACK:GetRGBA())
    addonTable.GeneralCellLength = max(addonTable.GeneralCellLength, x + width)
    BackgroundFrameResize()
    return setmetatable({
                            Frame = frame,
                            BackgroundTexture = texture,
                            SeparatorFrame = separator,
                            SeparatorTexture = separatorTexture,
                        }, self)
end

addonTable.ValueBarBackplate = ValueBarBackplate

---@class ValueBar
---@field Backplate ValueBarBackplate 固定黑底与红色分隔
---@field Frame Frame 黑色内容背景框体，不含两侧红色分隔
---@field StatusBar StatusBar 显示当前数值比例的白色填充条
---@field X integer 包含左侧红色分隔的占位起点，以 Cell 为单位
---@field width number 黑白内容宽度，以 Cell 为单位，不含分隔
local ValueBar = {}
ValueBar.__index = ValueBar

---ValueBar 初始化方法（私有）
---@private
---@param x integer 包含左侧分隔的占位起点，以 Cell 为单位
---@param width number 内容宽度，以 Cell 为单位；完整占位为 width + 1
---@param reverse boolean 是否反向填充
function ValueBar:_initialize(x, width, reverse)
    self.Backplate = ValueBarBackplate:New(x, width)
    local backgroundFrame = self.Backplate.Frame
    local bar = CreateFrame("StatusBar", nil, backgroundFrame)
    bar:SetAllPoints(backgroundFrame)
    bar:SetFrameLevel(FrameLevel.Content)
    bar:SetColorFill(COLOR.WHITE:GetRGBA())

    if reverse then
        bar:SetReverseFill(true)
    end
    bar:Show()

    self.Frame = backgroundFrame
    self.X = x
    self.width = width
    self.StatusBar = bar
    self:setMinMaxValues(0, 100)
    self:setValue(50)
end

---创建数值条；调用前须已创建 addonTable.BackgroundFrame
---@param x integer 包含左侧分隔的占位起点，以 Cell 为单位
---@param width number 内容宽度，以 Cell 为单位；完整占位为 width + 1
---@param reverse boolean|nil 仅 true 启用反向填充，省略时使用默认方向
---@return ValueBar # 返回初始化完成的 Bar 实例
function ValueBar:New(x, width, reverse)
    if reverse and (reverse == true) then
        reverse = true
    else
        reverse = false
    end
    local instance = setmetatable({}, self)
    instance:_initialize(x, width, reverse)
    return instance
end

---设置数值条的最小值与最大值
---@param minValue number 数值范围下限
---@param maxValue number 数值范围上限
function ValueBar:setMinMaxValues(minValue, maxValue)
    self.StatusBar:SetMinMaxValues(minValue, maxValue)
end

---设置数值条的当前值
---@param currentValue number 当前数值
function ValueBar:setValue(currentValue)
    self.StatusBar:SetValue(currentValue)
end

addonTable.ValueBar = ValueBar

-- local function demo()
--     local bar = ValueBar:New(3, 5)
--     bar:setValue(25)
--     ValueBarBackplate:New(9, 5)
-- end
-- table.insert(addonTable.UIInitFuncs, demo)
