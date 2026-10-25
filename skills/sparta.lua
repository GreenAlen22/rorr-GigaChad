-- Z alt, Sparta: a slow, heavy kick ahead that stuns and throws enemies back.
-- Every third kick is THIS IS SPARTA: double damage, a wider reach and twice
-- the throw.

local S      = GIGACHAD.Assets.sprites
local Attack = GIGACHAD.Attack

local DAMAGE    = 3.0
local BIG_EVERY = 3      -- every third kick is the big one
local BIG_MULT  = 2
local HIT_FRAME = 6      -- leg fully out (shoot1_2.png, frames 5-7)
local ANIM      = 0.2

local skill = Skill.new("GigachadZ2")
GIGACHAD.Survivor.survivor:add_skill(Skill.Slot.PRIMARY, skill)
skill.sprite     = S.skills
skill.subimage   = 5
skill.damage     = DAMAGE
skill.cooldown   = 40
skill.animation  = S.sparta
skill.is_primary = true

local state = ActorState.new("GigachadZ2")

Callback.add(skill.on_activate, function(actor)
    actor:set_state(state)
end)

Callback.add(state.on_enter, function(actor, data)
    actor.image_index = 0
    data.fired = 0
    -- The count lives on the actor, not the state, so it carries between
    -- kicks. Every machine plays the state and counts the same; only the
    -- owner's count decides the damage.
    local kicks = Instance.get_data(actor, "sparta", _ENV["!guid"])
    kicks.n = (kicks.n or 0) + 1
    data.big = (kicks.n % BIG_EVERY == 0) and 1 or 0
end)

Callback.add(state.on_step, function(actor, data)
    actor:skill_util_fix_hspeed()
    actor:actor_animation_set(S.sparta, ANIM)

    if data.fired == 0 and actor.image_index >= HIT_FRAME then
        data.fired = 1
        local big = data.big == 1
        local damage = actor:skill_get_damage(skill.value)
        Attack.zone(actor, big and damage * BIG_MULT or damage, 40, big and 160 or 130, 90, {
            sparks    = gm.constants.sSparks7,
            primary   = true,
            stun      = 1,     -- 1.5 s (knowledge/mechanics.md)
            knockback = big and 12 or 6,
        })
        actor:screen_shake(big and 10 or 5)
        actor:sound_play(gm.constants.wClayShoot1, 1,
            (big and 0.55 or 0.7) + math.random() * 0.15)
    end

    actor:skill_util_exit_state_on_anim_end()
end)

GIGACHAD.Sparta = { skill = skill, state = state }
