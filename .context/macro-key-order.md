# 宏快捷键优先绑定顺序

日期：2026-09-26。

## 来源与使用约定

来源：[Phantom macro_keys.py](../references/Phantom/phantom/core/macro_keys.py) 的 `MACRO_KEYS`，当前原始列表共148项且无重复。以下序号对应原始列表，不因PixBlood的保留项重新编号。

用户指定这些组合为优先绑定顺序，以降低与玩家键位冲突的概率。使用原有右侧修饰键，按宏声明顺序从首项分配；本项目由Python和Lua手写相同映射，不实现运行时自动分配或同步。

- `RALT-F4`、`RALT-RSHIFT-F4` 在源文件中仅为跳过注释，不属于148项，不占序号。
- PixBlood固定 `reloadUI` 为 `CTRL-F12`，宏文本为 `/reload`，不占用循环宏分配序号。
- 原始第32项 `RCTRL-F12` 保留在下表以忠实记录源顺序，但PixBlood分配时跳过，为固定重载绑定保留位置；其余项相对顺序不变。按本约定可分配147项。
- 当前17个循环宏使用原始前17项（原目标宏沿用前12项中的键位，新增焦点宏依次使用第13—17项），不受F12保留规则影响。

## 原始148项顺序

| 原始序号 | 键位 | PixBlood说明 |
| --- | --- | --- |
| 1 | `RCTRL-NUMPAD1` |  |
| 2 | `RCTRL-NUMPAD2` |  |
| 3 | `RCTRL-NUMPAD3` |  |
| 4 | `RCTRL-NUMPAD4` |  |
| 5 | `RCTRL-NUMPAD5` |  |
| 6 | `RCTRL-NUMPAD6` |  |
| 7 | `RCTRL-NUMPAD7` |  |
| 8 | `RCTRL-NUMPAD8` |  |
| 9 | `RCTRL-NUMPAD9` |  |
| 10 | `RCTRL-NUMPAD0` |  |
| 11 | `RSHIFT-NUMPAD1` |  |
| 12 | `RSHIFT-NUMPAD2` |  |
| 13 | `RSHIFT-NUMPAD3` |  |
| 14 | `RSHIFT-NUMPAD4` |  |
| 15 | `RSHIFT-NUMPAD5` |  |
| 16 | `RSHIFT-NUMPAD6` |  |
| 17 | `RSHIFT-NUMPAD7` |  |
| 18 | `RSHIFT-NUMPAD8` |  |
| 19 | `RSHIFT-NUMPAD9` |  |
| 20 | `RSHIFT-NUMPAD0` |  |
| 21 | `RCTRL-F1` |  |
| 22 | `RCTRL-F2` |  |
| 23 | `RCTRL-F3` |  |
| 24 | `RCTRL-F4` |  |
| 25 | `RCTRL-F5` |  |
| 26 | `RCTRL-F6` |  |
| 27 | `RCTRL-F7` |  |
| 28 | `RCTRL-F8` |  |
| 29 | `RCTRL-F9` |  |
| 30 | `RCTRL-F10` |  |
| 31 | `RCTRL-F11` |  |
| 32 | `RCTRL-F12` | 保留给固定重载绑定；分配时跳过 |
| 33 | `RSHIFT-F1` |  |
| 34 | `RSHIFT-F2` |  |
| 35 | `RSHIFT-F3` |  |
| 36 | `RSHIFT-F4` |  |
| 37 | `RSHIFT-F5` |  |
| 38 | `RSHIFT-F6` |  |
| 39 | `RSHIFT-F7` |  |
| 40 | `RSHIFT-F8` |  |
| 41 | `RSHIFT-F9` |  |
| 42 | `RSHIFT-F10` |  |
| 43 | `RSHIFT-F11` |  |
| 44 | `RSHIFT-F12` |  |
| 45 | `RALT-F1` |  |
| 46 | `RALT-F2` |  |
| 47 | `RALT-F3` |  |
| 48 | `RALT-F5` |  |
| 49 | `RALT-F6` |  |
| 50 | `RALT-F7` |  |
| 51 | `RALT-F8` |  |
| 52 | `RALT-F9` |  |
| 53 | `RALT-F10` |  |
| 54 | `RALT-F11` |  |
| 55 | `RALT-F12` |  |
| 56 | `RALT-NUMPAD1` |  |
| 57 | `RALT-NUMPAD2` |  |
| 58 | `RALT-NUMPAD3` |  |
| 59 | `RALT-NUMPAD4` |  |
| 60 | `RALT-NUMPAD5` |  |
| 61 | `RALT-NUMPAD6` |  |
| 62 | `RALT-NUMPAD7` |  |
| 63 | `RALT-NUMPAD8` |  |
| 64 | `RALT-NUMPAD9` |  |
| 65 | `RALT-NUMPAD0` |  |
| 66 | `RCTRL-,` |  |
| 67 | `RCTRL-.` |  |
| 68 | `RCTRL-/` |  |
| 69 | `RCTRL-;` |  |
| 70 | `RCTRL-'` |  |
| 71 | `RCTRL-[` |  |
| 72 | `RCTRL-]` |  |
| 73 | `RCTRL-=` |  |
| 74 | `RALT-,` |  |
| 75 | `RALT-.` |  |
| 76 | `RALT-/` |  |
| 77 | `RALT-;` |  |
| 78 | `RALT-'` |  |
| 79 | `RALT-[` |  |
| 80 | `RALT-]` |  |
| 81 | `RALT-=` |  |
| 82 | `RSHIFT-,` |  |
| 83 | `RSHIFT-.` |  |
| 84 | `RSHIFT-/` |  |
| 85 | `RSHIFT-;` |  |
| 86 | `RSHIFT-'` |  |
| 87 | `RSHIFT-[` |  |
| 88 | `RSHIFT-]` |  |
| 89 | `RSHIFT-=` |  |
| 90 | `RCTRL-RSHIFT-NUMPAD1` |  |
| 91 | `RCTRL-RSHIFT-NUMPAD2` |  |
| 92 | `RCTRL-RSHIFT-NUMPAD3` |  |
| 93 | `RCTRL-RSHIFT-NUMPAD4` |  |
| 94 | `RCTRL-RSHIFT-NUMPAD5` |  |
| 95 | `RCTRL-RSHIFT-NUMPAD6` |  |
| 96 | `RCTRL-RSHIFT-NUMPAD7` |  |
| 97 | `RCTRL-RSHIFT-NUMPAD8` |  |
| 98 | `RCTRL-RSHIFT-NUMPAD9` |  |
| 99 | `RCTRL-RSHIFT-NUMPAD0` |  |
| 100 | `RALT-RSHIFT-NUMPAD1` |  |
| 101 | `RALT-RSHIFT-NUMPAD2` |  |
| 102 | `RALT-RSHIFT-NUMPAD3` |  |
| 103 | `RALT-RSHIFT-NUMPAD4` |  |
| 104 | `RALT-RSHIFT-NUMPAD5` |  |
| 105 | `RALT-RSHIFT-NUMPAD6` |  |
| 106 | `RALT-RSHIFT-NUMPAD7` |  |
| 107 | `RALT-RSHIFT-NUMPAD8` |  |
| 108 | `RALT-RSHIFT-NUMPAD9` |  |
| 109 | `RALT-RSHIFT-NUMPAD0` |  |
| 110 | `RCTRL-RSHIFT-F1` |  |
| 111 | `RCTRL-RSHIFT-F2` |  |
| 112 | `RCTRL-RSHIFT-F3` |  |
| 113 | `RCTRL-RSHIFT-F4` |  |
| 114 | `RCTRL-RSHIFT-F5` |  |
| 115 | `RCTRL-RSHIFT-F6` |  |
| 116 | `RCTRL-RSHIFT-F7` |  |
| 117 | `RCTRL-RSHIFT-F8` |  |
| 118 | `RCTRL-RSHIFT-F9` |  |
| 119 | `RCTRL-RSHIFT-F10` |  |
| 120 | `RCTRL-RSHIFT-F11` |  |
| 121 | `RCTRL-RSHIFT-F12` |  |
| 122 | `RALT-RSHIFT-F1` |  |
| 123 | `RALT-RSHIFT-F2` |  |
| 124 | `RALT-RSHIFT-F3` |  |
| 125 | `RALT-RSHIFT-F5` |  |
| 126 | `RALT-RSHIFT-F6` |  |
| 127 | `RALT-RSHIFT-F7` |  |
| 128 | `RALT-RSHIFT-F8` |  |
| 129 | `RALT-RSHIFT-F9` |  |
| 130 | `RALT-RSHIFT-F10` |  |
| 131 | `RALT-RSHIFT-F11` |  |
| 132 | `RALT-RSHIFT-F12` |  |
| 133 | `RCTRL-RSHIFT-,` |  |
| 134 | `RCTRL-RSHIFT-.` |  |
| 135 | `RCTRL-RSHIFT-/` |  |
| 136 | `RCTRL-RSHIFT-;` |  |
| 137 | `RCTRL-RSHIFT-'` |  |
| 138 | `RCTRL-RSHIFT-[` |  |
| 139 | `RCTRL-RSHIFT-]` |  |
| 140 | `RCTRL-RSHIFT-=` |  |
| 141 | `RALT-RSHIFT-,` |  |
| 142 | `RALT-RSHIFT-.` |  |
| 143 | `RALT-RSHIFT-/` |  |
| 144 | `RALT-RSHIFT-;` |  |
| 145 | `RALT-RSHIFT-'` |  |
| 146 | `RALT-RSHIFT-[` |  |
| 147 | `RALT-RSHIFT-]` |  |
| 148 | `RALT-RSHIFT-=` |  |

## 第三版本次分配

按 [旧鲜血TOML](../references/Phantom/rotations/死亡骑士-鲜血.toml) 的宏声明顺序分配。第三版计划书包含完整规则和宏文本。

| 顺序 | 宏名 | 键位 | 动作类型 |
| --- | --- | --- | --- |
| 1 | 灵界打击 | `RCTRL-NUMPAD1` | Cast |
| 2 | 焦点心灵冰冻 | `RCTRL-NUMPAD2` | Cast |
| 3 | 目标心灵冰冻 | `RCTRL-NUMPAD3` | Cast |
| 4 | 死神印记 | `RCTRL-NUMPAD4` | Cast |
| 5 | 符文刃舞 | `RCTRL-NUMPAD5` | Cast |
| 6 | 精髓分裂 | `RCTRL-NUMPAD6` | Cast |
| 7 | 死神的抚摩 | `RCTRL-NUMPAD7` | Cast |
| 8 | 圣光潜力 | `RCTRL-NUMPAD8` | Use |
| 9 | 血液沸腾 | `RCTRL-NUMPAD9` | Cast |
| 10 | 枯萎凋零 | `RCTRL-NUMPAD0` | Cast |
| 11 | 心脏打击 | `RSHIFT-NUMPAD1` | Cast |
| 12 | 亡者复生 | `RSHIFT-NUMPAD2` | Cast |

固定辅助绑定：`reloadUI` → `CTRL-F12` → `/reload`，保留在Lua宏列表中，不加入Rotation循环keymap。

后续新增宏继续按上述顺序选择未使用且未保留的项，并手写更新 `pix/rotation.py` 和 `pix/lua/macro.lua` 的对应关系。
