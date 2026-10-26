-- C, A Moment: рывок на одной высоте, неуязвим. Следующий удар — крит.

local S  = GIGACHAD.Assets.sprites
local Fx = GIGACHAD.Fx
local Attack = GIGACHAD.Attack

-- В единицах pHmax; от скорости атаки не зависит.
local SPEED = 5
local TRAIL_EVERY = 2    -- кадров между шлейфами
local CRIT_WINDOW = 90   -- кадров после рывка, когда удар критует

local skill = GIGACHAD.Survivor.slot(Skill.Slot.UTILITY)
skill.sprite     = S.skills
skill.subimage   = 2
skill.damage     = 1
skill.cooldown   = 5 * 60
skill.animation  = S.moment
skill.is_utility = true

local state = ActorState.new("GigachadC")

Callback.add(skill.on_activate, function(actor)
    actor:set_state(state)
end)

Callback.add(state.on_enter, function(actor, data)
    actor.image_index = 0
    data.y = actor.y
    data.t = 0

    -- Направление игра шлёт с навыком — одинаково на всех машинах.
    data.dir = Attack.dir(actor)
end)

Callback.add(state.on_step, function(actor, data)
    actor:skill_util_fix_hspeed()
    -- Без скорости атаки: длина рывка постоянная.
    actor:actor_animation_set(S.moment, 1, false)

    if (tonumber(actor.invincible) or 0) < 2 then actor.invincible = 2 end

    actor.pHspeed = data.dir * actor.pHmax * SPEED
    actor.pVspeed = 0
    actor.y = data.y

    data.t = data.t + 1
    if data.t % TRAIL_EVERY == 0 then Fx.trail(actor, 0.5) end

    actor:skill_util_exit_state_on_anim_end()
end)

Callback.add(state.on_exit, function(actor, data)
    actor.pHspeed = 0
    Attack.charge_crit(actor, CRIT_WINDOW)
end)

GIGACHAD.Moment = { skill = skill, state = state }
