--[[
    CellBackplate 与 Cell 用法：
    两者都通过 :New({ x = 列号 }) 创建，x 是从 1 开始的列号。
    注意：x=0也工作，就是和标记位冲突。x从1起始，是业务编号。
    CellBackplate 只创建无颜色纹理的底板；显示的黑色来自 BackgroundFrame，
    可通过实例的 Frame 放置其他元素。
    Cell 在底板上创建颜色纹理，可用 :setCell(color) 设置颜色（如 addonTable.COLOR.WHITE），
    或用 :setCellRGBA(r, g, b) 传入 RGB 分量；:clearCell() 恢复黑色。

    简要示例：
    local backplate = addonTable.CellBackplate:New({ x = 1 })
    local cell = addonTable.Cell:New({ x = 2 })
    cell:setCell(addonTable.COLOR.WHITE)
    更完整的可复制用例见文件末尾的注释块。
]]

local addonName, addonTable    = ...

local CreateFrame              = CreateFrame
local EvaluateColorFromBoolean = C_CurveUtil.EvaluateColorFromBoolean
local setmetatable             = setmetatable
local max                      = math.max

local SIZE                     = addonTable.SIZE
local COLOR                    = addonTable.COLOR
local FrameLevel               = addonTable.FrameLevel
local BackgroundFrameResize    = addonTable.BackgroundFrameResize

local WHITE_TEXTURE            = "Interface\\Buttons\\WHITE8X8"



---@class CellBackplate
---@field Frame Frame 内容矩形
---@field x integer 坐标
local CellBackplate = {}
CellBackplate.__index = CellBackplate

---@param options table 构造参数
---@return CellBackplate
function CellBackplate:New(options)
    local x = options.x
    local parent = addonTable.BackgroundFrame
    local frame = CreateFrame("Frame", addonName .. "Cell_" .. x, parent)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", x * SIZE.CELL, 0)
    frame:SetFrameStrata("TOOLTIP")
    frame:SetFrameLevel(FrameLevel.Backplate)
    frame:SetSize(SIZE.CELL, SIZE.CELL)
    frame:Show()
    addonTable.GeneralCellLength = max(addonTable.GeneralCellLength, x)
    BackgroundFrameResize()
    return setmetatable({ Frame = frame }, self)
end

addonTable.CellBackplate = CellBackplate


---@class Cell
---@field Backplate CellBackplate 固定黑色背板
---@field Texture Texture 单元格纹理
---@field Frame Frame 单元格框架
---@field x integer X坐标
local Cell = {}
Cell.__index = Cell

---Cell 初始化方法（私有）
---@private
---@param x integer 坐标
function Cell:_initialize(x)
    self.Backplate = CellBackplate:New({ x = x })
    local cellFrame = self.Backplate.Frame
    local cellTexture = cellFrame:CreateTexture(nil, "ARTWORK")
    cellTexture:SetAllPoints(cellFrame)
    cellTexture:SetTexture(WHITE_TEXTURE)
    cellTexture:Show()

    self.Texture = cellTexture
    self.Frame = cellFrame
    self.x = x

    self:setCell(COLOR.BLACK)
end

---使用 RGB 分量设置颜色，透明度固定为 1
---@param r number|string|table 红色分量
---@param g number|string|table 绿色分量
---@param b number|string|table 蓝色分量
function Cell:setCellRGBA(r, g, b)
    self.Texture:SetVertexColor(r, g, b, 1)
end

---设置颜色方法
---@param color colorRGBA 要设置的颜色
function Cell:setCell(color)
    self:setCellRGBA(color:GetRGBA())
end

---Cell 构造函数
---@param options table 构造参数
---@return Cell # 返回初始化后的 Cell 实例
function Cell:New(options)
    local instance = setmetatable({}, self)
    instance:_initialize(options.x)
    return instance
end

---清除颜色方法, 就是恢复默认的黑色
function Cell:clearCell()
    self:setCell(COLOR.BLACK)
end

addonTable.Cell = Cell


-- local function demo()
--     local backplate = CellBackplate:New({ x = 1 })
--     local cell = Cell:New({ x = 2 })
--     cell:setCell(addonTable.COLOR.WHITE)
--     cell:setCellRGBA(1, 1, 0)
-- end
-- table.insert(addonTable.UIInitFuncs, demo)
