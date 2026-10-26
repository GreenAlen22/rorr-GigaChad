-- V, Star Fury: серия ударов и добивающий с отбросом, неуязвим всё время.
-- - Скорость атаки ускоряет серию: тот же урон раньше, меньше неуязвимости.
-- - Скипетр, Cosmic Radiance: больше и шире удары.

local S      = GIGACHAD.Assets.sprites
local Sounds = GIGACHAD.Assets.sounds
local Attack = GIGACHAD.Attack

local ANIM      = 0.45   -- 41 кадр: ~90 кадров игры при базовой скорости
local START     = 5      -- кадр начала серии
local INTERVAL  = 3      -- кадров между ударами при базовой скорости
local PROC_EVERY = 3     -- эффекты предметов каждый третий удар
local ORA_EVERY = 10     -- «ORA» каждый десятый удар

local VARIANTS = {
    -- finisher: добивающий, в единицах damage (3.0 = 300%)
    normal  = { id = "GigachadV",        subimage = 3, damage = 0.3, punches = 25,
                finisher = 3.0, w = 120, h = 100 },
    boosted = { id = "GigachadVBoosted", subimage = 4, damage = 0.4, punches = 35,
                finisher = 5.0, w = 240, h = 200 },
}

local function setup(skill, v)
    skill.sprite    = S.skills
    skill.subimage  = v.subimage
    skill.damage    = v.damage
    skill.cooldown  = 8 * 60
    skill.animation = S.starfury

    local state = ActorState.new(v.id)

    Callback.add(skill.on_activate, function(actor)
        actor:set_state(state)
    end)

    Callback.add(state.on_enter, function(actor, data)
        actor.image_index = 0
        -- activity_type 3: из состояния не выпрыгнуть (как телепорт Акрида).
        actor.activity_type = 3
        data.hits = 0
        data.wait = 0
    end)

    Callback.add(state.on_step, function(actor, data)
        actor:skill_util_fix_hspeed()
        actor:actor_animation_set(S.starfury, ANIM)

        -- Неуязвим, пока идёт навык; снимается через 2 кадра.
        if (tonumber(actor.invincible) or 0) < 2 then actor.invincible = 2 end
        -- Перезарядка ждёт конца серии, иначе Alien Head дают вечную неуязвимость.
        actor:get_active_skill(Skill.Slot.SPECIAL):freeze_cooldown()

        -- Удар раз в INTERVAL кадров; скорость атаки сокращает ожидание.
        if actor.image_index >= START and data.hits <= v.punches then
            data.wait = data.wait - (tonumber(actor.attack_speed) or 1)
            if data.wait <= 0 then
                data.wait = data.wait + INTERVAL
                data.hits = data.hits + 1
                local damage = actor:skill_get_damage(skill.value)

                if data.hits <= v.punches then
                    Attack.zone(actor, damage, 25, v.w, v.h, {
                        sparks  = S.jojo,
                        proc    = data.hits % PROC_EVERY == 0,
                        max_hit = 20,
                    })
                    if data.hits % ORA_EVERY == 1 then
                        actor:sound_play(Sounds.ora, 1, 0.9 + math.random() * 0.2)
                    end
                    if data.hits % 2 == 0 then actor:screen_shake(1) end
                else
                    Attack.zone(actor, damage * v.finisher / v.damage, 35, v.w * 1.2, v.h, {
                        sparks    = S.jojo,
                        knockback = 8,
                        max_hit   = 20,
                    })
                    actor:sound_play(Sounds.ora, 1, 0.75)
                    actor:screen_shake(6)
                end
            end
        end

        -- Удары и анимация расходятся по скорости атаки; выход, когда кончились оба.
        if data.hits > v.punches then
            actor:skill_util_exit_state_on_anim_end()
        elseif actor.image_index >= 35 then
            actor.image_index = 30
        end
    end)

    return state
end

local skill   = GIGACHAD.Survivor.slot(Skill.Slot.SPECIAL)
local boosted = Skill.new(VARIANTS.boosted.id)
skill.upgrade_skill = boosted

GIGACHAD.StarFury = {
    skill   = skill,
    boosted = boosted,
    state   = setup(skill, VARIANTS.normal),
    state_boosted = setup(boosted, VARIANTS.boosted),
}
