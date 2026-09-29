local addonName, addonTable = ...

-- lua缓存
local select = select
local ipairs = ipairs
local print = print
local tostring = tostring
local insert = table.insert -- 表插入


-- wow api缓存
local After                 = C_Timer.After
local SetCVar               = SetCVar
local UIParent              = UIParent
local GetPhysicalScreenSize = GetPhysicalScreenSize
local GetAddOnMetadata      = C_AddOns.GetAddOnMetadata
local GetBuildInfo          = GetBuildInfo
local CreateColor           = CreateColor
local CreateColorCurve      = C_CurveUtil.CreateColorCurve -- 创建剩余冷却颜色曲线
local Linear                = Enum.LuaCurveType.Linear     -- 在相邻节点间线性插值

local debug                 = false
addonTable.DEBUG            = debug

local version               = GetAddOnMetadata(addonName, "Version")
addonTable.VERSION          = version

local function logging(msg)
    print("|cFFFFBB66[" .. addonName .. "]|r" .. tostring(msg))
end
addonTable.logging = logging




local gameBuildVersion, GameBuildNumber, _ = GetBuildInfo()
local fullVersion                          = gameBuildVersion .. "." .. GameBuildNumber
if version ~= fullVersion then
    addonTable.logging("插件版本" .. addonTable.VERSION .. " 游戏版本" .. fullVersion)
    addonTable.logging("插件版本与游戏版本不一致，可能会导致一些问题")
end

local scale = 1
-- 缩放
if debug then -- 按调试开关选择显示倍率
    scale = 8 -- 调试时放大显示以便观察像素布局
end

addonTable.SCALE = scale

local function GetUIScaleFactor(pixelValue)                   -- 将目标物理像素尺寸换算为 UI 尺寸
    local physicalHeight = select(2, GetPhysicalScreenSize()) -- 取物理屏幕高度作为换算基准
    local UI_scale = UIParent:GetScale()                      -- 每次换算时读取根界面的当前缩放
    return pixelValue * 768 / physicalHeight / UI_scale       -- 抵消物理高度差异和父级缩放
end

addonTable.GetUIScaleFactor = GetUIScaleFactor

addonTable.UIInitFuncs      = {}                     -- UI初始化函数表

After(0, function()                                  -- 延后执行，供其他运行时文件先注册 UI 初始化函数
    for _, func in ipairs(addonTable.UIInitFuncs) do -- 执行时读取共享表并按注册顺序遍历
        func()                                       -- 创建该回调负责的界面组件
    end
end)

SetCVar("useUiScale", 0)                            -- 关闭自定义 UI 缩放开关
SetCVar("tooltipShowAuraSpellIDs", 1)               -- 显示光环ID
SetCVar("secretChallengeModeRestrictionsForced", 1) -- 写入挑战模式 Secret 限制强制开关
SetCVar("secretCombatRestrictionsForced", 1)        -- 写入战斗 Secret 限制强制开关
SetCVar("secretEncounterRestrictionsForced", 1)     -- 写入首领战 Secret 限制强制开关
SetCVar("secretMapRestrictionsForced", 1)           -- 写入地图 Secret 限制强制开关
SetCVar("secretPvPMatchRestrictionsForced", 1)      -- 写入 PvP 比赛 Secret 限制强制开关
SetCVar("secretAuraDataRestrictionsForced", 1)      -- 写入光环数据 Secret 限制强制开关
SetCVar("scriptErrors", 1);                         -- 开启 Lua 错误显示
SetCVar("doNotFlashLowHealthWarning", 1);           -- 关闭低生命值闪烁警告
SetCVar("lossOfControl", 0);                        -- 关闭失去控制效果提示
SetCVar("cameraIndirectVisibility", 1);             -- 写入镜头间接可见性配置
SetCVar("cameraIndirectOffset", 10);                -- 写入镜头间接偏移量
SetCVar("targetNearestDistance", 5)                 -- 写入最近目标的距离配置
SetCVar("cameraDistanceMaxZoomFactor", 2.6)         -- 写入镜头最大拉远倍率
SetCVar("CameraReduceUnexpectedMovement", 1)        -- 开启减少意外镜头移动选项
SetCVar("synchronizeSettings", 1)                   -- 写入设置同步开关
SetCVar("synchronizeConfig", 1)                     -- 写入配置同步开关
SetCVar("synchronizeBindings", 1)                   -- 写入按键绑定同步开关
SetCVar("synchronizeMacros", 1)                     -- 写入宏同步开关
SetCVar("LowLatencyMode", 0)                        --低延迟模式 0:关闭 1:内置 2:NVIDIA Reflex 3:NVIDIA Reflex + Boost 4:Intel XeLL
SetCVar("ffxAntiAliasingMode", 0)                   --基于图像的技术 0:无 1:FXAA低 2:FXAA高 3:CMAA 4:CMAA2
SetCVar("MSAAQuality", 0)                           --多重采样技术 0:无 1:色彩 2x / 景深 2x 2:色彩 4x / 景深 4x 3:色彩 8x / 景深 8x
SetCVar("Contrast", 50)                             --对比度 minValue, maxValue, step = 0, 100, 1
SetCVar("Brightness", 50)                           --亮度 minValue, maxValue, step = 0, 100, 1
SetCVar("Gamma", 1)                                 --伽马值 minValue, maxValue, step = .3, 2.8, .1


local COLOR = {                                                             -- 供其他运行时文件共用的颜色定义
    AURA_TYPE = {                                                           -- 光环
        MAGIC = CreateColor(60 / 255, 100 / 255, 220 / 255, 1),             -- 魔法
        CURSE = CreateColor(100 / 255, 0, 120 / 255, 1),                    -- 诅咒
        DISEASE = CreateColor(160 / 255, 120 / 255, 60 / 255, 1),           -- 疾病
        POISON = CreateColor(154 / 255, 205 / 255, 50 / 255, 1),            -- 中毒
        ENRAGE = CreateColor(230 / 255, 120 / 255, 20 / 255, 1),            -- 激怒
        BLEED = CreateColor(80 / 255, 0, 20 / 255, 1),                      -- 流血
        DEBUFF_ON_FRIENDLY = CreateColor(255 / 255, 60 / 255, 60 / 255, 1), -- 在友方身上的减益,不属于上述状态
        BUFF_ON_FRIENDLY = CreateColor(80 / 255, 220 / 255, 120 / 255, 1),  -- 在友方身上的增益,不属于上述状态
        DEBUFF_ON_ENEMY = CreateColor(105 / 255, 105 / 255, 210 / 255, 1),  -- 在敌方身上的减益,不属于上述状态
    },
    SPELL_TYPE = {                                                          -- 施法状态配色
        PLAYER_SPELL = CreateColor(64 / 255, 158 / 255, 210 / 255, 1),      -- 友方施法
        INTERRUPTIBLE = CreateColor(255 / 255, 255 / 255, 60 / 255, 1),     -- 可打断
        NOT_INTERRUPTIBLE = CreateColor(200 / 255, 0, 0, 1),                -- 不可打断
    },
    NONE = CreateColor(0, 0, 0, 0),                                         -- 无
    RED = CreateColor(255 / 255, 0, 0, 1),                                  -- 红色
    GREEN = CreateColor(0, 255 / 255, 0, 1),                                -- 绿色
    BLUE = CreateColor(0, 0, 255 / 255, 1),                                 -- 蓝色
    BLACK = CreateColor(0, 0, 0, 1),                                        -- 黑色
    WHITE = CreateColor(1, 1, 1, 1),                                        -- 白色
    TRANSPARENT = CreateColor(0, 0, 0, 0),                                  -- 透明
    PANEL = {                                                               -- 面板的UI配色
        Black           = CreateColor(0 / 255, 0 / 255, 0 / 255, 1),        -- 纯黑
        WindowBg        = CreateColor(30 / 255, 30 / 255, 30 / 255, 1),     -- 窗口背景色
        WindowText      = CreateColor(0 / 255, 0 / 255, 0 / 255, 1),        -- 窗口文字色（备用）
        WindowBorder    = CreateColor(83 / 255, 88 / 255, 91 / 255, 1),     -- 窗口边框色
        Base            = CreateColor(255 / 255, 255 / 255, 255 / 255, 1),  -- 基础白
        ButtonBorder    = CreateColor(52 / 255, 52 / 255, 52 / 255, 1),     -- 按钮边框色
        ButtonHighlight = CreateColor(86 / 255, 86 / 255, 86 / 255, 1),     -- 按钮悬停高亮
        ButtonMouseUp   = CreateColor(43 / 255, 43 / 255, 43 / 255, 1),     -- 按钮正常底色
        ButtonMouseDown = CreateColor(37 / 255, 37 / 255, 37 / 255, 1),     -- 按钮按下底色
        SliderLeft      = CreateColor(73 / 255, 179 / 255, 234 / 255, 1),   -- 滑块已填充色
        SliderRight     = CreateColor(159 / 255, 159 / 255, 159 / 255, 1),  -- 滑块未填充色
        RowHover        = CreateColor(50 / 255, 50 / 255, 50 / 255, 1),     -- 行悬停色
        Text            = CreateColor(230 / 255, 230 / 255, 230 / 255, 1),  -- 文本颜色
        DropdownBg      = CreateColor(34 / 255, 34 / 255, 34 / 255, 1),     -- 下拉列表背景色
    }
}



if debug then                                                   -- 调试模式以高对比度展示定位标记
    COLOR.MARK = {                                              -- 画布定位标记配色
        POINT_0 = CreateColor(0, 255 / 255, 0, 1),              -- 定位标记的第一种颜色：亮绿色
        POINT_1 = CreateColor(255 / 255, 0, 0, 1),              -- 定位标记的第二种颜色：亮红色
    }
else                                                            -- 常规模式降低定位标记的视觉亮度
    COLOR.MARK = {                                              -- 画布定位标记配色
        POINT_0 = CreateColor(15 / 255, 25 / 255, 20 / 255, 1), -- 接近黑色的定位标记
        POINT_1 = CreateColor(25 / 255, 15 / 255, 20 / 255, 1), -- 接近黑色的定位标记
    }
end


addonTable.COLOR = COLOR

-- 冷却时间的亮度曲线
-- 非线性的，冷却时间越短，精度越高。
-- 245秒以上冷却视为和无穷一样。
local spell_cd_remaining_curve = CreateColorCurve()                                      -- 不等距节点构成整体非线性的灰度变化
spell_cd_remaining_curve:SetType(Linear)
spell_cd_remaining_curve:AddPoint(0.0, CreateColor(255 / 255, 255 / 255, 255 / 255, 1))  -- 就绪时纯白
spell_cd_remaining_curve:AddPoint(10.0, CreateColor(155 / 255, 155 / 255, 155 / 255, 1)) -- 0- 10秒区间，10秒范围，占用100个亮度单位，精度0.1秒
spell_cd_remaining_curve:AddPoint(30.0, CreateColor(115 / 255, 115 / 255, 115 / 255, 1)) -- 10秒-30秒区间，20秒范围，占用40个亮度单位，精度0.5秒
spell_cd_remaining_curve:AddPoint(120.0, CreateColor(25 / 255, 25 / 255, 25 / 255, 1))   -- 30秒-120秒区间，90秒范围，占用90个亮度单位，精度1秒
spell_cd_remaining_curve:AddPoint(245.0, CreateColor(0 / 255, 0 / 255, 0 / 255, 1))      -- 120秒-245秒区间，125秒范围，占用25个亮度单位，精度5秒




-- 光环的剩余事件亮度曲线
-- 区别很大
-- 白色=无限期 or 或者还很久
-- 黑色=消失 or 没有
local aura_remaining_curve = CreateColorCurve()                                       -- 不等距节点构成整体非线性的灰度变化
aura_remaining_curve:SetType(Linear)
aura_remaining_curve:AddPoint(0.0, CreateColor(0 / 255, 0 / 255, 0 / 255, 1))         -- 0秒，不存在，皆为黑色
aura_remaining_curve:AddPoint(15.0, CreateColor(150 / 255, 150 / 255, 150 / 255, 1))  -- 0- 15秒区间，15秒范围，占用150个亮度单位，精度0.1秒
aura_remaining_curve:AddPoint(30.0, CreateColor(180 / 255, 180 / 255, 180 / 255, 1))  -- 15秒-30秒区间，15秒范围，占用30个亮度单位，精度0.5秒
aura_remaining_curve:AddPoint(60.0, CreateColor(210 / 255, 210 / 255, 210 / 255, 1))  -- 30秒-60秒区间，30秒范围，占用30个亮度单位，精度1秒
aura_remaining_curve:AddPoint(240.0, CreateColor(255 / 255, 255 / 255, 255 / 255, 1)) -- 60秒-240秒区间，180秒范围，占用45个亮度单位，精度4秒

addonTable.CURVE = {}
addonTable.CURVE.SpellColddownRemaining = spell_cd_remaining_curve
addonTable.CURVE.AuraRemaining = aura_remaining_curve






-- 百分比统一线性映射：零值为黑色，满值为白色。
local percentCurve = CreateColorCurve()
percentCurve:SetType(Linear)
percentCurve:AddPoint(0, COLOR.BLACK)
percentCurve:AddPoint(1, COLOR.WHITE)
addonTable.CURVE.percent = percentCurve

-- 计数格式器只创建一次，供光环层数的原生绑定共享；255 及以上饱和为白色。
-- 规则生成仅处理普通循环变量，秘密计数由原生格式器处理。
local countFormatter = C_StringUtil.CreateNumericRuleFormatter()
local countRules = {}
for count = 0, 255 do
    countRules[#countRules + 1] = {
        threshold = count,
        format = string.format("|cFF%02X%02X%02X█|r", count, count, count),
    }
end
countFormatter:SetBreakpoints(countRules)
addonTable.CountFormatter = countFormatter





addonTable.FrameLevel = { -- 供界面组件统一使用的框架层级
    Canvas = 9500,        -- 共享画布
    Separator = 9550,     -- 数值条红色分隔
    Backplate = 9600,     -- 固定黑色背板
    Content = 9650,       -- 普通数值条与吸收条
    AuraContainer = 9700, -- 光环容器
    AuraButton = 9750,    -- 光环槽位
    AuraContent = 9800,   -- 光环槽位内部数值条
    Overlay = 9850,       -- 预留层级，当前不创建框体
    Marker = 9900,        -- 定位与检测标记

}

addonTable.SIZE = {}                                              -- 尺寸表
local function InitializeSize()                                   -- 初始化尺寸
    local SIZE = addonTable.SIZE                                  -- 执行初始化时取得当前共享尺寸表
    SIZE.CELL = GetUIScaleFactor(scale * 4)                       -- Cell 边长，包含调试显示倍率
    SIZE.CELL_FONT_SIZE = GetUIScaleFactor(12) * scale            -- 实心字符字号，用于覆盖并裁剪到 Cell 内
    SIZE.PANEL = {                                                -- 游戏内设置面板尺寸
        MainFrame = {                                             -- 主框体尺寸
            Width = GetUIScaleFactor(400),                        -- 主框体宽度
            Height = GetUIScaleFactor(16) + GetUIScaleFactor(36), -- 主框体初始高度，由 16 与 36 像素分别换算后相加
            Border = GetUIScaleFactor(1),                         -- 主框体边框
            Spacing = GetUIScaleFactor(8),                        -- 内边距/间距
        },                                                        -- MainFrame 结束
        BUTTON = {                                                -- 按钮尺寸
            Width = GetUIScaleFactor(110),                        -- 按钮宽度
            Height = GetUIScaleFactor(36),                        -- 按钮高度
            Border = GetUIScaleFactor(2),                         -- 按钮边框
            IconBorder = GetUIScaleFactor(8),                     -- 图标边框
        },                                                        -- BUTTON 结束
        SETTING_LINE = {                                          -- 设置行尺寸
            Height = GetUIScaleFactor(36),                        -- 行高
            Spacing = GetUIScaleFactor(8),                        -- 行间距
            TitleWidth = GetUIScaleFactor(172),                   -- 标题宽度
            WidgetWidth = GetUIScaleFactor(204),                  -- 控件宽度
            SliderBarHeight = GetUIScaleFactor(6),                -- 滑块条高度
            SliderSquareHeight = GetUIScaleFactor(16),            -- 滑块方块高度
            SliderValueWidth = GetUIScaleFactor(48),              -- 滑块数值区宽度
        }                                                         -- SETTING_LINE 结束
    }
end
insert(addonTable.UIInitFuncs, InitializeSize) -- 注册尺寸计算，先于后续文件的界面初始化执行
