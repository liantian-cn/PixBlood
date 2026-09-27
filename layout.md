| 完成 | 文件名序号 | 文件名                           | 类型              | 起始位置 | 结束位置 | bar宽度  | 类型              | 说明                                                                      |
| ---- | ---------- | -------------------------------- | ----------------- | -------- | -------- | -------- | ----------------- | ------------------------------------------------------------------------- |
| N    | I01        | player_cast_icon                 | IconTile          | 1        | 1        | -        | 图标              | 玩家的施法图标，脚标永恒为COLOR.SPELL_TYPE.PLAYER_SPELL                   |
| N    | I02        | assisted_combat_icon             | IconTile          | 2        | 2        |          | 图标              | 一件辅助的推荐技能，脚标永恒为COLOR.SPELL_TYPE.PLAYER_SPELL               |
| N    | I03        | target_cast_icon                 | IconTile          | 3        | 3        | -        | 图标              | 目标的施法图标，脚标根据可打断状态改变                                    |
| N    | I04        | focus_cast_icon                  | IconTile          | 4        | 4        | -        | 图标              | 玩家的施法图标，脚标根据可打断状态改变                                    |
| Y    | I05        | interrupt_blacklist              | IconTile          | 5        | 19       | 15槽     | 图标列表          | 面板配置打断黑名单，按法术ID升序取前15项；黄色角标，失败留空不补位；Context过滤None，目标/焦点仅在可打断且图标非空、未命中黑名单时允许打断 |
| 完成 | 文件名序号 | 文件名                           | 类型              | 起始位置 | 结束位置 | bar宽度  | 类型              | 说明                                                                      |
| Y    | 001        | enable                           | Cell              | 1        | 1        | -        | 布尔              | 反应addonTable.ENABLE的状态                                               |
| Y    | 002        | in_burst                         | Cell              | 2        | 2        | -        | 布尔              | 反应addonTable.InBurst()的状态                                            |
| Y    | 003        | delaying                         | Cell              | 3        | 3        | -        | 布尔              | 反应addonTable.Delaying()的状态                                           |
| N    | 004        | player_is_alive                  | Cell              | 4        | 4        |          | 布尔              | 玩家存活                                                                  |
| N    | 005        | player_health_pct                | Cell              | 5        | 5        | -        | Curve曲线         | 玩家生命值（百分比）                                                      |
| N    | 006        | power_runic_power                | Cell              | 6        | 6        | -        | Curve曲线         | 符文能量(百分比)                                                          |
| N    | 007        | power_rune                       | Cell              | 7        | 7        | -        | 浮点              | 符文个数                                                                  |
| N    | 008        | player_in_combat                 | Cell              | 8        | 8        | -        | 布尔              | 玩家是否在状态                                                            |
| N    | 009        | player_is_player_target          | Cell              | 9        | 9        | -        | 布尔              | 玩家的目标是自己                                                          |
| N    | 010        | player_is_moving                 | Cell              | 10       | 10       | -        | 布尔              | 玩家正在移动                                                              |
| N    | 011        | player_in_vehicle                | Cell              | 11       | 11       | -        | 布尔              | 玩家在坐骑/载具上                                                         |
| N    | 012        | player_is_targeting_spell        | Cell              | 12       | 12       |          | 布尔              | 玩家在选取施法目标的状态                                                  |
| N    | 013        | player_is_chatting               | Cell              | 13       | 13       | -        | 布尔              | 玩家在聊天                                                                |
| N    | 014        | ticket_13_ready                  | Cell              | 14       | 14       |          | 布尔              | 一号饰品可用(SLOT 13)                                                     |
| N    | 015        | ticket_14_ready                  | Cell              | 15       | 15       |          | 布尔              | 二号饰品可用(SLOT 13)                                                     |
| N    | 016        | healthstone_ready                | Cell              | 16       | 16       |          | 布尔              | 治疗石可用                                                                |
| N    | 017        | heal_potion_ready                | Cell              | 17       | 17       |          | 布尔              | 治疗药水可用                                                              |
| N    | 018        | player_has_heal_absorb           | CellBackplate     | 18       | 18       |          | 进度条            | 玩家有治疗吸收盾(250,000以上)                                             |
| N    | 019        | player_has_damage_absorb         | CellBackplate     | 19       | 19       |          | 进度条            | 玩家有治疗吸收盾(500,000以上)                                             |
| N    | 020        | player_cast_progress             | Cell              | 20       | 20       | -        | Curve曲线         | 玩家的cast/channel进度                                                    |
| N    | 021        | player_is_empowering             | Cell              | 21       | 21       | -        | 布尔              | 玩家是否在蓄力                                                            |
| N    | 022        | target_is_exists                 | Cell              | 22       | 22       | -        | 布尔              | 目标存在                                                                  |
| N    | 023        | target_is_alive                  | Cell              | 23       | 23       | -        | 布尔              | 目标存活                                                                  |
| N    | 024        | target_can_attack                | Cell              | 24       | 24       | -        | 布尔              | 目标可攻击                                                                |
| N    | 025        | target_can_assist                | Cell              | 25       | 25       | -        | 布尔              | 目标可协助                                                                |
| N    | 026        | target_health_pct                | Cell              | 26       | 26       | -        | Curve曲线         | 目标生命值（百分比）                                                      |
| N    | 027        | target_cast_interruptible        | Cell              | 27       | 27       | -        | 布尔              | 目标可打断                                                                |
| N    | 028        | target_cast_progress             | Cell              | 28       | 28       | -        | Curve曲线         | 目标的cast/channel进度                                                    |
| N    | 029        | target_in_melee_range            | Cell              | 29       | 29       |          | 布尔              | 目标在近战范围(用[灵界打击]。SPELLID:49998判断)                           |
| N    | 030        | target_in_ranged_range           | Cell              | 30       | 30       |          | 布尔              | 目标在远程范围(用[死神的抚摩]。SPELLID:195292判断)                        |
| N    | 031        | target_in_interrupt_range        | Cell              | 31       | 31       |          | 布尔              | 目标在可打断范围(用[心灵冰冻]。SPELLID:47528判断)                         |
| N    | 032        | focus_is_exists                  | Cell              | 32       | 32       | -        | 布尔              | 焦点存在                                                                  |
| N    | 033        | focus_is_alive                   | Cell              | 33       | 33       | -        | 布尔              | 焦点存活                                                                  |
| N    | 034        | focus_can_attack                 | Cell              | 34       | 34       | -        | 布尔              | 焦点可攻击                                                                |
| N    | 035        | focus_can_assist                 | Cell              | 35       | 35       | -        | 布尔              | 焦点可协助                                                                |
| N    | 036        | focus_health_pct                 | Cell              | 36       | 36       | -        | Curve曲线         | 焦点生命值（百分比）                                                      |
| N    | 037        | focus_cast_interruptible         | Cell              | 37       | 37       | -        | 布尔              | 焦点可打断                                                                |
| N    | 038        | focus_cast_progress              | Cell              | 38       | 38       | -        | Curve曲线         | 焦点的cast/channel进度                                                    |
| N    | 039        | focus_in_melee_range             | Cell              | 39       | 39       |          | 布尔              | 焦点在近战范围(用[灵界打击]。SPELLID:49998判断)                           |
| N    | 040        | focus_in_ranged_range            | Cell              | 40       | 40       |          | 布尔              | 焦点在远程范围(用[死神的抚摩]。SPELLID:195292判断)                        |
| N    | 041        | focus_in_interrupt_range         | Cell              | 41       | 41       |          | 布尔              | 焦点在可打断范围(用[心灵冰冻]。SPELLID:47528判断)                         |
| N    | 042        | spell_cd_global_cooldown         | Cell              | 42       | 42       |          | Curve曲线         | [Global Cooldown]。SPELLID:61304 的冷却时间,ignore_gcd = false            |
| N    | 043        | spell_cd_mind_freeze             | Cell              | 43       | 43       |          | Curve曲线         | [心灵冰冻]。SPELLID:47528 的冷却时间,ignore_gcd = true                    |
| N    | 044        | spell_cd_reapers_mark            | Cell              | 44       | 44       |          | Curve曲线         | [死神印记]。SPELLID:439843 的冷却时间,ignore_gcd = true                   |
| N    | 045        | spell_cd_dancing_rune_weapon     | Cell              | 45       | 45       |          | Curve曲线         | [符文刃舞]。SPELLID:49028 的冷却时间,ignore_gcd = true                    |
| N    | 046        | spell_cd_deaths_caress           | Cell              | 46       | 46       |          | Curve曲线         | [死神的抚摩]。SPELLID:195292 的冷却时间,ignore_gcd = true                 |
| N    | 047        | spell_cd_raise_dead              | Cell              | 47       | 47       |          | Curve曲线         | [亡者复生]。SPELLID:46585 的冷却时间,ignore_gcd = true                    |
| N    | 048        | spell_charges_blood_boil         | ValueBar          | 48       | 50       | 2(占用3) | 进度条            | 血液沸腾 spellid [50842]的充能层数，最大值=2                              |
| N    | 051        | spell_charges_death_and_decay    | ValueBar          | 51       | 53       | 2(占用3) | 进度条            | 枯萎凋零 spellid [43265]的充能层数，最大值=2                              |
| N    | 054        | item_cd_lights_potential         | Cell              | 54       | 54       |          | 布尔              | 爆发药水[圣光潜力]冷却就绪 物品id 241308                                  |
| N    | 055        | player_has_dance_of_midnight     | Cell              | 55       | 55       |          | 原生AuraContainer | 玩家有午夜舞步buff, buff的spell id 有[1264351, 1264405, 1264568, 1264407] |
| N    | 056        | player_has_buff_boiling_point    | Cell              | 56       | 56       |          | 原生AuraContainer | 玩家有沸点buff, buff的spell id 有[1265790, 1265982, 1265968]              |
| N    | 057        | player_has_buff_death_and_decay  | Cell              | 57       | 57       |          | 原生AuraContainer | 玩家有枯萎凋零buff, buff的spell id 有[188290]                             |
| N    | 058        | player_has_buff_crimson_scourge  | Cell              | 58       | 58       |          | 原生AuraContainer | 玩家有赤色天灾buff, buff的spell id 有[81141, 81136]                       |
| N    | 059        | player_has_buff_exterminate      | Cell              | 59       | 59       |          | 原生AuraContainer | 玩家有破灭buff, buff的spell id 有[441426, 447954, 441424, 441378, 441416] |
| N    | 060        | player_buff_duration_bone_shield | CellBackplate     | 60       | 60       |          | 原生AuraContainer | buff白骨之盾 [195181] 的剩余时间                                          |
| N    | 061        | player_buff_stacks_bone_shield   | ValueBarBackplate | 61       | 64       | 3(占用4) | 进度条            | buff白骨之盾 [195181] 的层数                                              |
| N    | 065        | target_has_debuff_blood_plague   | Cell              | 65       | 65       |          | 原生AuraContainer | 目标有血之疫病debuff  id 55078                                            |
| N    | 066        | spec_boiling_point              | Cell              | 66       | 66       | -        | 时间戳倒计时      | 非秘密 SPELL_UPDATE_COOLDOWN ID 1265982 触发3秒窗口；每0.1秒刷新，RGB=ceil(剩余秒数×10)/255，Python亮度/10得秒数；重复触发重置，进入世界清零 |
| N    | 067        | player_buff_stacks_blood_debt   | ValueBarBackplate | 67       | 70       | 3(占用4) | 进度条            | 血债 1310372 层数；量程12，实际最多10层；Python比例×12 |
| N    | 071        | mouseover_in_melee_range        | Cell              | 71       | 71       | -        | 布尔              | 每0.1秒查询mouseover存在与灵界打击49998射程；不存在、普通nil或超出范围清黑 |
| N    | 072        | burst_potion_enabled           | Cell              | 72       | 72       | -        | 布尔              | 独立爆发药水开关，现有面板combo控制、默认关闭；白色开启、黑色关闭 |
| Y    | 073        | player_melee_enemies_count      | Cell              | 73       | 73       | -        | 整数灰度          | nameplate1–40中存在、可攻击、存活且灵界打击49998射程为普通true的单位数；COMBAT_ONLY=false，秘密/nil射程不计；仅可观察姓名板；初始化、事件延后刷新及0.2秒轮询，RGB=count/40，Python int(ratio×40+0.5)还原0–40 |
