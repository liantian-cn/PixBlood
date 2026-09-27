-- 背景初始化后创建青、洋红、黄定位色块及黑白检测色块；黑白色块每 0.5 秒切换一次。
local addonName, addonTable = ...

local CreateFrame = CreateFrame
local insert = table.insert

local FrameLevel = addonTable.FrameLevel
local SIZE = addonTable.SIZE
local UIInitFuncs = addonTable.UIInitFuncs


local function InitMaskFrames()
    local parent = addonTable.BackgroundFrame

    local cyanFrame = CreateFrame("Frame", nil, parent)
    cyanFrame:SetSize(SIZE.CELL, SIZE.CELL)
    cyanFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -1 * SIZE.CELL)
    cyanFrame:SetFrameStrata("TOOLTIP")
    cyanFrame:SetFrameLevel(FrameLevel.Backplate)
    cyanFrame:Show()

    local cyanTexture = cyanFrame:CreateTexture(nil, "ARTWORK")
    cyanTexture:SetAllPoints(cyanFrame)
    cyanTexture:SetColorTexture(0 / 255, 255 / 255, 255 / 255, 1)
    cyanTexture:Show()

    local magentaFrame = CreateFrame("Frame", nil, parent)
    magentaFrame:SetSize(SIZE.CELL, SIZE.CELL)
    magentaFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -2 * SIZE.CELL)
    magentaFrame:SetFrameStrata("TOOLTIP")
    magentaFrame:SetFrameLevel(FrameLevel.Backplate)
    magentaFrame:Show()

    local magentaTexture = magentaFrame:CreateTexture(nil, "ARTWORK")
    magentaTexture:SetAllPoints(magentaFrame)
    magentaTexture:SetColorTexture(255 / 255, 0 / 255, 255 / 255, 1)
    magentaTexture:Show()

    local yellowFrame = CreateFrame("Frame", nil, parent)
    yellowFrame:SetSize(SIZE.CELL, SIZE.CELL)
    yellowFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 1 * SIZE.CELL)
    yellowFrame:SetFrameStrata("TOOLTIP")
    yellowFrame:SetFrameLevel(FrameLevel.Backplate)
    yellowFrame:Show()

    local yellowTexture = yellowFrame:CreateTexture(nil, "ARTWORK")
    yellowTexture:SetAllPoints(yellowFrame)
    yellowTexture:SetColorTexture(255 / 255, 255 / 255, 0 / 255, 1)
    yellowTexture:Show()

    local flashFrame = CreateFrame("Frame", nil, parent)
    flashFrame:SetSize(SIZE.CELL, SIZE.CELL)
    flashFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 2 * SIZE.CELL)
    flashFrame:SetFrameStrata("TOOLTIP")
    flashFrame:SetFrameLevel(FrameLevel.Backplate)
    flashFrame:Show()

    local flashTexture = flashFrame:CreateTexture(nil, "ARTWORK")
    flashTexture:SetAllPoints(flashFrame)
    flashTexture:SetColorTexture(0, 0, 0, 1)
    flashTexture:Show()


    local flashIsWhite = false
    local eventFrame = CreateFrame("Frame", nil, parent)
    local elapsedTime = 0

    eventFrame:SetScript("OnUpdate", function(self, elapsed)
        elapsedTime = elapsedTime + elapsed

        if elapsedTime < 0.5 then
            return
        end

        elapsedTime = elapsedTime - 0.5


        flashIsWhite = not flashIsWhite

        if flashIsWhite then
            flashTexture:SetColorTexture(1, 1, 1, 1)
        else
            flashTexture:SetColorTexture(0, 0, 0, 1)
        end
    end)
    eventFrame:Show()
end

insert(UIInitFuncs, InitMaskFrames)
