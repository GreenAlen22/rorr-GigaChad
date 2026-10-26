-- Z, Stab: замах и удар кулаком впереди.

local S      = GIGACHAD.Assets.sprites
local Attack = GIGACHAD.Attack

local DAMAGE    = 2.0
local HIT_FRAME = 10     -- кулак попадает (кадры 10-13)
local ANIM      = 0.45

local skill = GIGACHAD.Survivor.slot(Skill.Slot.PRIMARY)
skill.sprite     = S.skills
skill.subimage   = 0
skill.damage     = DAMAGE
skill.cooldown   = 10
skill.animation  = S.stab
skill.is_primary = true

local state = ActorState.new("GigachadZ")

Callback.add(skill.on_activate, function(actor)
    actor:set_state(state)
end)

Callback.add(state.on_enter, function(actor, data)
    actor.image_index = 0
    data.fired = 0
end)

Callback.add(state.on_step, function(actor, data)
    actor:skill_util_fix_hspeed()
    actor:actor_animation_set(S.stab, ANIM)

    if data.fired == 0 and actor.image_index >= HIT_FRAME then
        data.fired = 1
        Attack.zone(actor, actor:skill_get_damage(skill.value), 30, 120, 100,
            { sparks = gm.constants.sSparks7, primary = true })
        actor:screen_shake(2)
        actor:sound_play(gm.constants.wClayShoot1, 1, 0.8 + math.random() * 0.2)
    end

    actor:skill_util_exit_state_on_anim_end()
end)

GIGACHAD.Stab = { skill = skill, state = state }
