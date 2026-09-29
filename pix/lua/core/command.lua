local addonName, addonTable = ...

local GetTime = GetTime           -- 获取当前计时值，用于计算爆发及延迟截止时间

local lower = string.lower        -- 统一命令前缀与命令词大小写
local sub = string.sub            -- 读取插件名的前两位
local match = string.match        -- 分离命令词与可选参数
local tonumber = tonumber         -- 解析正负整数或小数秒数，不附加时长限制
local print = print               -- 将命令帮助输出到聊天窗口
local max = math.max              -- 取较大值，将爆发剩余秒数下限限制为 0
local min = math.min              -- 取较小值，将爆发剩余秒数上限限制为 60

local SlashCmdList = SlashCmdList -- 注册插件聊天命令处理函数


addonTable.ENABLE = not addonTable.RELOAD_REQUIRED -- 待重载时保持关闭


addonTable.BurstTime = GetTime() + 60                          -- 初始化共享爆发截止时间，默认从加载时起持续 60 秒
addonTable.InBurst = function()                                -- 供其他文件查询当前是否处于爆发期
    return addonTable.BurstTime > GetTime()                    -- 截止时间晚于当前时间时仍处于爆发期
end
addonTable.BurstRemaining = function()                         -- 供其他文件查询爆发剩余秒数
    return min(60.0, max(0, addonTable.BurstTime - GetTime())) -- 实时读取共享截止时间，将剩余秒数限制在 0 至 60 秒之间
end

addonTable.DelayTime = GetTime()                    -- 默认不延迟，截止时间等于当前时间
addonTable.Delaying = function()                    -- 供其他文件查询当前是否正在延迟
    return addonTable.DelayTime > GetTime()         -- 截止时间到达时立即结束延迟
end
addonTable.DelayRemaining = function()              -- 供其他文件查询实际延迟剩余秒数
    return max(0, addonTable.DelayTime - GetTime()) -- 仅限制下限，不截断长延迟
end





addonTable.CommandHandler = {}
local CommandHandler = addonTable.CommandHandler

function addonTable.PrintCommandHelp()
    print("PixBlood 命令:")
    print("/pix toggle — 切换启停")
    print("/pix disable — 关闭插件")
    print("/pix burst [秒数] — 爆发窗口，默认 15 秒，0 结束")
    print("/pix delay [秒数] — 设置延迟状态，默认 0.4 秒")
end

function CommandHandler:Dispatch(command)
    if addonTable.RELOAD_REQUIRED then return end

    local func, msg = command:match("^(%S+)%s*(.*)$")

    if not func then
        addonTable.PrintCommandHelp()
        return
    end

    local handler = self[func]

    if type(handler) ~= "function" or func == "Dispatch" then
        print("未知命令: " .. func)
        return
    end

    handler(self, msg)
end

-- 只有匹配当前专精的插件注册统一命令，避免多个 Pix 插件抢占。
if not addonTable.RELOAD_REQUIRED then
    SLASH_PixBlood1 = "/pix"
    SlashCmdList.PixBlood = function(command)
        CommandHandler:Dispatch(command)
    end
end


function CommandHandler:disable(arguments)
    -- 开关命令不接受额外参数
    if arguments ~= "" then
        addonTable.PrintCommandHelp()
        return
    end

    addonTable.ENABLE = false
end

function CommandHandler:toggle(arguments)
    -- 开关命令不接受额外参数
    if arguments ~= "" then
        addonTable.PrintCommandHelp()
        return
    end

    addonTable.ENABLE = not addonTable.RELOAD_REQUIRED and not addonTable.ENABLE
end

local function ParseDuration(arguments, defaultDuration)
    -- 没有参数时使用默认值
    if arguments == "" then
        return defaultDuration
    end

    -- 不允许多个参数
    if arguments:match("%s") then
        return nil
    end

    return tonumber(arguments)
end


function CommandHandler:delay(arguments)
    local duration = ParseDuration(arguments, 0.4)

    if not duration then
        addonTable.PrintCommandHelp()
        return
    end

    addonTable.DelayTime = GetTime() + duration
end

function CommandHandler:burst(arguments)
    local duration = ParseDuration(arguments, 15)

    if not duration then
        addonTable.PrintCommandHelp()
        return
    end

    addonTable.BurstTime = GetTime() + duration
end
