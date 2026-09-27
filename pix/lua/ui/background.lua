local addonName, addonTable = ...


local insert = table.insert
local max = math.max
local CreateFrame = CreateFrame
local UIParent = UIParent

local COLOR = addonTable.COLOR
local DEBUG = addonTable.DEBUG
local FrameLevel = addonTable.FrameLevel
local UIInitFuncs = addonTable.UIInitFuncs
local SIZE = addonTable.SIZE

addonTable.GeneralCellLength = 0
addonTable.IconTileLength = 0


-- 初始化背景及角落定位标记。
local function InitBackgroundFrame()
    local bgFrame = CreateFrame("Frame", addonName .. "BackgroundFrame", UIParent)
    if DEBUG then
        bgFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    else
        bgFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
    end
    bgFrame:SetSize(SIZE.CELL * 2, SIZE.CELL * 3)
    bgFrame:SetFrameStrata("TOOLTIP")
    bgFrame:SetFrameLevel(FrameLevel.Canvas)
    bgFrame:Show()

    local bgTexture = bgFrame:CreateTexture(nil, "BACKGROUND")
    bgTexture:SetAllPoints()
    bgTexture:SetColorTexture(COLOR.BLACK:GetRGBA())

    bgTexture:Show()

    -- 创建双色棋盘格定位标记。
    local function CreateMaskFrame(mask_idx)
        --[[
        每个标记位：
            整体一个Cell大小，由4个边长为 SIZE.CELL / 2 的方片组成。颜色不同，使用COLOR.MARK.POINT_0和COLOR.MARK.POINT_1
            排列为:
            0 | 1
            -----
            1 | 0

        ]]

        local _frame = CreateFrame("Frame", addonName .. "MaskFrame" .. mask_idx, bgFrame)
        _frame:SetSize(SIZE.CELL, SIZE.CELL)
        _frame:SetFrameStrata("TOOLTIP")
        _frame:SetFrameLevel(FrameLevel.Marker)
        _frame:Show()

        local cells = {}
        local cell_size = SIZE.CELL / 2
        local colors = {
            COLOR.MARK.POINT_0,
            COLOR.MARK.POINT_1,
        }

        for row = 1, 2 do
            cells[row] = {}
            for col = 1, 2 do
                local _texture = _frame:CreateTexture(nil, "ARTWORK")
                _texture:SetSize(cell_size, cell_size)
                _texture:SetPoint(
                    "TOPLEFT", _frame, "TOPLEFT",
                    (col - 1) * cell_size, -(row - 1) * cell_size
                )

                local color = colors[(row + col) % 2 + 1]
                _texture:SetColorTexture(color:GetRGBA())

                cells[row][col] = _texture
            end
        end
        return _frame
    end

    local top_left_mask = CreateMaskFrame("1")
    top_left_mask:SetPoint("TOPLEFT", bgFrame, "TOPLEFT", 0, 0)
    local bottom_right_mask = CreateMaskFrame("2")
    bottom_right_mask:SetPoint("BOTTOMRIGHT", bgFrame, "BOTTOMRIGHT", 0, 0)

    addonTable.BackgroundFrame = bgFrame
end
insert(UIInitFuncs, InitBackgroundFrame)

-- 按共享区域的最大长度调整背景宽度。
local function BackgroundFrameResize()
    local max_length = max(addonTable.GeneralCellLength, addonTable.IconTileLength)
    addonTable.BackgroundFrame:SetSize(SIZE.CELL * (2 + max_length), SIZE.CELL * 3)
end
addonTable.BackgroundFrameResize = BackgroundFrameResize
