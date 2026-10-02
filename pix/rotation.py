"""Blood Death Knight priorities from 死亡使者血DK-1.2.1.25 (Version 1.2.1.28)."""

from pix.action import Cast, Idle, Sleep, Use
from pix.context import Context


class Rotation:
    def __init__(self) -> None:
        self.keymap: dict[str, str] = {
            "target灵界打击": "RCTRL-NUMPAD1",
            "焦点心灵冰冻": "RCTRL-NUMPAD2",
            "目标心灵冰冻": "RCTRL-NUMPAD3",
            "target死神印记": "RCTRL-NUMPAD4",
            "符文刃舞": "RCTRL-NUMPAD5",
            "target精髓分裂": "RCTRL-NUMPAD6",
            "target死神的抚摩": "RCTRL-NUMPAD7",
            "圣光潜力": "RCTRL-NUMPAD8",
            "血液沸腾": "RCTRL-NUMPAD9",
            "枯萎凋零": "RCTRL-NUMPAD0",
            "target心脏打击": "RSHIFT-NUMPAD1",
            "亡者复生": "RSHIFT-NUMPAD2",
            "focus灵界打击": "RSHIFT-NUMPAD3",
            "focus死神印记": "RSHIFT-NUMPAD4",
            "focus精髓分裂": "RSHIFT-NUMPAD5",
            "focus心脏打击": "RSHIFT-NUMPAD6",
            "focus死神的抚摩": "RSHIFT-NUMPAD7",
        }

    def main_rotation(self, ctx: Context) -> Cast | Use | Idle | Sleep:
        # 如果 插件未启用
        # => 不执行动作
        if not ctx.enable:
            return Idle("插件未启用")

        # 如果 插件正在延迟
        # => 不执行动作
        if ctx.delaying:
            return Idle("插件延迟中")

        # 如果 玩家不在战斗
        # => 不执行动作
        if not ctx.player_in_combat:
            return Idle("玩家不在战斗")

        # 如果 玩家正在施法或引导（进度大于 0）
        # => 不执行动作
        if ctx.player_cast_progress > 0:
            return Idle("玩家正在施法或引导")

        # 如果 玩家正在蓄力
        # => 不执行动作
        if ctx.player_is_empowering:
            return Idle("玩家正在蓄力")

        # 如果 目标不存在、已死亡或不可攻击（任一条件成立）
        # => 不执行动作
        if not (ctx.target_is_exists and ctx.target_is_alive and ctx.target_can_attack):
            return Idle("目标不可攻击")

        # 每条规则先目标后焦点；均不在对应射程时继续下一条规则。
        focus_valid = ctx.focus_is_exists and ctx.focus_can_attack and ctx.focus_is_alive
        target_melee = ctx.target_in_melee_range
        focus_melee = focus_valid and ctx.focus_in_melee_range
        target_ranged = ctx.target_in_ranged_range
        focus_ranged = focus_valid and ctx.focus_in_ranged_range
        any_melee = target_melee or focus_melee

        # 如果 玩家生命值不高于 55%
        # 如果 符文能量不少于 42 点
        # => 施放 灵界打击
        if ctx.player_health_pct <= 55 and ctx.power_runic_power >= 42:
            if target_melee:
                return Cast("target灵界打击", "第1条：低血量自疗")
            if focus_melee:
                return Cast("focus灵界打击", "第1条：低血量自疗")

        interrupt_progress = ctx.interrupt_progress_threshold

        # 如果 焦点正在进行可打断的施法或引导，且已经过进度严格超过配置阈值
        # 如果 心灵冰冻冷却就绪
        # 如果 焦点存在且存活、可攻击且不可被援助
        # => 对焦点施放 心灵冰冻
        if (ctx.focus_cast_interruptible and ctx.focus_cast_progress > interrupt_progress
                and ctx.spell_cd_mind_freeze == 0
                and ctx.focus_is_exists and ctx.focus_is_alive and ctx.focus_can_attack and not ctx.focus_can_assist):
            return Cast("焦点心灵冰冻")

        # 如果 目标正在进行可打断的施法或引导，且已经过进度严格超过配置阈值
        # 如果 心灵冰冻冷却就绪
        # => 对目标施放 心灵冰冻
        if (ctx.target_cast_interruptible and ctx.target_cast_progress > interrupt_progress
                and ctx.spell_cd_mind_freeze == 0):
            return Cast("目标心灵冰冻")

        # 如果 白骨之盾剩余时间不超过 5 秒或层数不超过 5 层
        # 如果 死神印记冷却就绪
        # => 施放 死神印记
        if (ctx.player_buff_duration_bone_shield <= 5 or ctx.player_buff_stacks_bone_shield <= 5) and (ctx.spell_cd_reapers_mark == 0):
            if target_melee:
                return Cast("target死神印记", "第1条：补充白骨之盾")
            if focus_melee:
                return Cast("focus死神印记", "第1条：补充白骨之盾")

        # 如果 符文刃舞冷却就绪
        # 如果 在爆发状态
        # 如果 目标在近战范围
        # => 施放 符文刃舞
        if ctx.spell_cd_dancing_rune_weapon == 0 and ctx.in_burst and target_melee:
            return Cast("符文刃舞")

        # 如果 白骨之盾剩余时间不超过 5 秒或层数不超过 5 层
        # 如果 符文不少于 3 枚
        # => 施放 精髓分裂
        if (ctx.player_buff_duration_bone_shield <= 5 or ctx.player_buff_stacks_bone_shield <= 5) and (ctx.power_rune >= 3):
            if target_melee:
                return Cast("target精髓分裂", "第1条：补充白骨之盾")
            if focus_melee:
                return Cast("focus精髓分裂", "第1条：补充白骨之盾")

        # 如果 白骨之盾剩余时间不超过 5 秒或层数不超过 5 层
        # 如果 死神的抚摩冷却就绪
        # => 施放 死神的抚摩
        if (ctx.player_buff_duration_bone_shield <= 5 or ctx.player_buff_stacks_bone_shield <= 5) and (ctx.spell_cd_deaths_caress == 0):
            if target_ranged:
                return Cast("target死神的抚摩", "第1条：补充白骨之盾")
            if focus_ranged:
                return Cast("focus死神的抚摩", "第1条：补充白骨之盾")

        # 如果 圣光潜力药水可用
        # 如果 独立爆发药水开关开启
        # => 使用 圣光潜力药水
        if ctx.item_cd_lights_potential and ctx.burst_potion_enabled:
            return Use("圣光潜力")

        # 如果 血债达到 10 层且符文不少于 2 枚
        # => 施放 精髓分裂
        if ctx.player_buff_stacks_blood_debt == 10 and ctx.power_rune >= 2:
            if target_melee:
                return Cast("target精髓分裂", "第2条：血债10层")
            if focus_melee:
                return Cast("focus精髓分裂", "第2条：血债10层")

        # 如果 符文不少于 2 枚
        # 如果 玩家有破灭增益
        # => 施放 精髓分裂
        if ctx.power_rune >= 2 and ctx.player_has_buff_exterminate:
            if target_melee:
                return Cast("target精髓分裂", "第3条：破灭增益")
            if focus_melee:
                return Cast("focus精髓分裂", "第3条：破灭增益")

        # 如果 血液沸腾充能不少于 1 层
        # 如果 目标没有血之疫病减益
        # 如果 目标在近战范围内
        # 如果 沸点回响窗口已经结束
        # => 施放 血液沸腾
        if ctx.spell_charges_blood_boil >= 1 and not ctx.target_has_debuff_blood_plague and ctx.target_in_melee_range and ctx.spec_boiling_point == 0:
            return Cast("血液沸腾", "第1条：补血之疫病")

        # 如果 血液沸腾充能不少于 1 层，玩家有沸点增益且回响窗口已结束
        # => 施放 血液沸腾
        if ctx.spell_charges_blood_boil >= 1 and ctx.player_has_buff_boiling_point and ctx.spec_boiling_point == 0:
            return Cast("血液沸腾", "第2条：沸点增益且回响结束")

        # 如果 死神印记冷却就绪
        # 如果 对应施法对象生命值不低于 20%且在近战范围
        # => 施放 死神印记
        if ctx.spell_cd_reapers_mark == 0:
            if target_melee and ctx.target_health_pct >= 20:
                return Cast("target死神印记", "第2条：目标血量不低于20%")
            if focus_melee and ctx.focus_health_pct >= 20:
                return Cast("focus死神印记", "第2条：焦点血量不低于20%")

        # 如果 符文能量不少于 80 点
        # => 施放 灵界打击
        if ctx.power_runic_power >= 80:
            if target_melee:
                return Cast("target灵界打击", "第2条：符能不少于80")
            if focus_melee:
                return Cast("focus灵界打击", "第2条：符能不少于80")

        # 如果 枯萎凋零充能为 2 层
        # 如果 玩家有赤色天灾增益
        # 如果 有效目标或有效焦点在近战范围
        # => 施放 枯萎凋零
        if ctx.spell_charges_death_and_decay == 2 and ctx.player_has_buff_crimson_scourge and any_melee:
            return Cast("枯萎凋零", "第1条：满充能且赤色天灾")

        # 如果 玩家没有枯萎凋零增益
        # 如果 枯萎凋零充能为 2 层
        # 如果 鼠标指向单位在灵界打击射程内（仍在玩家脚下施放）
        # 如果 有效目标或有效焦点在近战范围
        # => 施放 枯萎凋零
        if not ctx.player_has_buff_death_and_decay and ctx.spell_charges_death_and_decay == 2 and ctx.mouseover_in_melee_range and any_melee:
            return Cast("枯萎凋零", "第2条：满充能且鼠标单位在近战范围")

        # 如果 玩家没有枯萎凋零增益
        # 如果 玩家有赤色天灾增益
        # 如果 玩家不在移动
        # 如果 有效目标或有效焦点在近战范围
        # => 施放 枯萎凋零
        if not ctx.player_has_buff_death_and_decay and ctx.player_has_buff_crimson_scourge and not ctx.player_is_moving and any_melee:
            return Cast("枯萎凋零", "第3条：赤色天灾且未移动")

        # 如果 玩家有午夜舞步增益
        # 如果 符文不少于 1 枚
        # => 施放 心脏打击
        if ctx.player_has_dance_of_midnight and ctx.power_rune >= 1:
            if target_melee:
                return Cast("target心脏打击", "第1条：午夜舞步")
            if focus_melee:
                return Cast("focus心脏打击", "第1条：午夜舞步")

        # 如果 符文不少于 2 枚
        # => 施放 心脏打击
        if ctx.power_rune >= 2:
            if target_melee:
                return Cast("target心脏打击", "第2条：符文不少于2枚")
            if focus_melee:
                return Cast("focus心脏打击", "第2条：符文不少于2枚")

        # 如果 死神的抚摩冷却就绪
        # 如果 白骨之盾层数不超过 9 层
        # => 施放 死神的抚摩
        if ctx.spell_cd_deaths_caress == 0 and ctx.player_buff_stacks_bone_shield <= 9:
            if target_ranged:
                return Cast("target死神的抚摩", "第2条：白骨之盾不超过9层")
            if focus_ranged:
                return Cast("focus死神的抚摩", "第2条：白骨之盾不超过9层")

        # 如果 亡者复生冷却就绪
        # => 施放 亡者复生
        if ctx.spell_cd_raise_dead == 0:
            return Cast("亡者复生")

        # 如果 血液沸腾充能不少于 1 层（参考末尾规则不检查沸点窗口）
        # 如果 玩家近战范围可观察敌人数量不少于 2
        # => 施放 血液沸腾
        if ctx.spell_charges_blood_boil >= 1 and ctx.player_melee_enemies_count >= 2:
            return Cast("血液沸腾", "第3条：兜底血沸，不浪费gcd")

        # 如果 以上规则均未满足
        # => 不执行动作
        return Idle("没有满足条件的动作")
