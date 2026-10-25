-- C, A Moment: a dash at a fixed height, invulnerable throughout. The next
-- hit after it is critical, so the dash is a way in as well as a way out.

local S  = GIGACHAD.Assets.sprites
local Fx = GIGACHAD.Fx
local Attack = GIGACHAD.Attack

-- Speed in units of the actor's own pHmax. 2.x scaled it with attack speed
-- (up to x1.5), so the dash grew longer with Soldier's Syringes; now it is
-- fixed at what 2.x reached at x1.25.
local SPEED = 5
local TRAIL_EVERY = 2    -- frames between afterimages; 2.x made one a frame
local CRIT_WINDOW = 90   -- frames after the dash in which the next hit crits

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

    -- The game turns him to the held direction before the skill starts and
    -- sends that facing with it (scr_skill_system.gml:51-60), so facing is the
    -- same on every machine.
    data.dir = Attack.dir(actor)
end)

Callback.add(state.on_step, function(actor, data)
    actor:skill_util_fix_hspeed()
    -- Not scaled by attack speed: the dash keeps one length.
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
