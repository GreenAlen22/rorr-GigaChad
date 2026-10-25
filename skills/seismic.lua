-- X, Seismic Shift: a stomp that raises stone spikes ahead of him, which hit
-- twice.
--
-- 2.x waited for frames 6, 10 and 14 of a 12-frame animation (the third hit
-- never came) and fired a second, smaller hit behind him on every machine.

local S      = GIGACHAD.Assets.sprites
local Attack = GIGACHAD.Attack
local Fx     = GIGACHAD.Fx

local DAMAGE = 2.5
local ANIM   = 0.35
-- The foot comes down on frame 8 (shoot2.png); the spikes settle by frame 10.
local HIT_FRAMES = { 8, 10 }
local REACH  = 95        -- centre of the spike field, px ahead
local WIDTH, HEIGHT = 220, 120

local skill = GIGACHAD.Survivor.slot(Skill.Slot.SECONDARY)
skill.sprite    = S.skills
skill.subimage  = 1
skill.damage    = DAMAGE
skill.cooldown  = 6 * 60
skill.animation = S.seismic

local state = ActorState.new("GigachadX")

Callback.add(skill.on_activate, function(actor)
    actor:set_state(state)
end)

Callback.add(state.on_enter, function(actor, data)
    actor.image_index = 0
    data.hits = 0
end)

Callback.add(state.on_step, function(actor, data)
    actor:skill_util_fix_hspeed()
    actor:actor_animation_set(S.seismic, ANIM)

    local next_frame = HIT_FRAMES[data.hits + 1]
    if next_frame and actor.image_index >= next_frame then
        data.hits = data.hits + 1
        Attack.zone(actor, actor:skill_get_damage(skill.value), REACH, WIDTH, HEIGHT,
            { sparks = S.spike_sparks })
        -- The spikes rise once, with the first hit; the second hit is the same
        -- field striking again. Drawn here, facing his way, on every machine.
        -- Speed 0.3 is what oEfSparks played in 2.x.
        if data.hits == 1 then
            local dir = Attack.dir(actor)
            Fx.once(S.spike, actor.x + REACH * dir, actor.y, { xscale = dir, speed = 0.3 })
        end
        actor:screen_shake(data.hits == 1 and 4 or 2)
        actor:sound_play(gm.constants.wBoss1Shoot1, 1, 1.2 + math.random() * 0.3)
    end

    actor:skill_util_exit_state_on_anim_end()
end)

GIGACHAD.Seismic = { skill = skill, state = state }
