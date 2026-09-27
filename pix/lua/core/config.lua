-- 配置用法
-- Profile 是本文件内的档案管理对象：
--   Profile.current_profile() 返回当前档案名。
--   Profile.switch_profile(name) 切换档案；不存在时创建空档案，并通知已注册配置的回调。
--   Profile._register_config 和 Profile._get_current_data 仅供本文件内部使用。
-- Config 通过 addonTable.Config 提供给其他文件：
--   local config = addonTable.Config("example_key")  -- 同一个 key 始终返回同一对象
--   config:set_default(10)                         -- 当前档案未设置时使用的默认值
--   local value = config:get_value()                -- 读取当前档案值或默认值
--   config:set_value(20)                            -- 写入当前档案并通知回调
--   config:register_callback(function(value) end)  -- 值写入或切换档案时调用；注册时不立即调用
--   config:set_value(nil) 会清除当前档案中的显式值，随后回退到默认值。

local addonName, addonTable = ...

local insert = table.insert
local setmetatable = setmetatable

PixBloodDB = PixBloodDB or {}

local addonSettings = PixBloodDB

addonSettings.profiles = addonSettings.profiles or {}
addonSettings.profiles["default"] = addonSettings.profiles["default"] or {}
addonSettings.current_profile = addonSettings.current_profile or "default"

local all_configs = {}
local Profile = {}

function Profile.current_profile()
    return addonSettings.current_profile
end

function Profile.switch_profile(name)

    if not addonSettings.profiles[name] then
        addonSettings.profiles[name] = {}
    end

    addonSettings.current_profile = name

    for configIndex = 1, #all_configs do
        local config = all_configs[configIndex]
        config:_notify()
    end
end

function Profile._register_config(config)
    insert(all_configs, config)
end

function Profile._get_current_data()
    return addonSettings.profiles[addonSettings.current_profile]
end

local config_cache = {}

local ConfigObj = {}
ConfigObj.__index = ConfigObj

function ConfigObj:new(key)
    local obj = {
        key = key,
        default_value = nil,
        callbacks = {}
    }
    setmetatable(obj, self)
    return obj
end

function ConfigObj:set_default(value)
    self.default_value = value
end

function ConfigObj:get_value()
    local data = Profile._get_current_data()
    if data[self.key] ~= nil then
        return data[self.key]
    end
    return self.default_value
end

function ConfigObj:set_value(value)
    local data = Profile._get_current_data()
    data[self.key] = value
    self:_notify()
end

function ConfigObj:register_callback(func)
    insert(self.callbacks, func)
end

function ConfigObj:_notify()
    local value = self:get_value()
    for callbackIndex = 1, #self.callbacks do
        local callback = self.callbacks[callbackIndex]
        callback(value)
    end
end

local function Config(key)
    if not config_cache[key] then
        config_cache[key] = ConfigObj:new(key)
        Profile._register_config(config_cache[key])
    end
    return config_cache[key]
end

addonTable.Config = Config
addonTable.ConfigRows = {}

--[[
Config 示例（在其他模块中通过 addonTable.Config 获取）：

local duration = addonTable.Config("example_duration")
duration:set_default(5)
duration:register_callback(function(value)
    print("当前提示时长：", value)
end)

local currentValue = duration:get_value() -- 未设置时返回默认值 5
duration:set_value(8)                     -- 写入当前档案并触发回调
duration:set_value(nil)                   -- 清除显式值，回退到默认值并触发回调

Profile 示例（Profile 是本文件的局部对象，只能在此文件内直接调用）：

local profileName = Profile.current_profile()
Profile.switch_profile("raid")           -- 不存在时创建空档案，并通知所有配置回调
local raidDuration = duration:get_value() -- 新档案未设置时返回默认值 5
Profile.switch_profile(profileName)      -- 切回原档案，读取原档案保存的值
]]
