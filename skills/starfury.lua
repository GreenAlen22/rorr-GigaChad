-- V, Star Fury: a rush of punches ahead of him and a heavy last blow that
-- throws enemies back, invulnerable while it lasts. Attack speed quickens the
-- rush, as it does Eviscerate's: the same damage, sooner, and less time immune.
-- Under Ancient Scepter: Cosmic Radiance, more and wider punches.
--
-- 2.x: 80 hits of 20% and 3 s of invulnerability every 10 s, about twice what
-- a vanilla special deals (HAN-D's is 500%, PLAN.md).

local S      = GIGACHAD.Assets.sprites
local Sounds = GIGACHAD.Assets.sounds
local Attack = GIGACHAD.Attack

local ANIM      = 0.45   -- 41 frames: about 90 game frames at base attack speed
local START     = 5      -- the rush starts on this frame of shoot4.png
local INTERVAL  = 3      -- game frames between punches at base attack speed
local PROC_EVERY = 3     -- every third punch carries item effects
local ORA_EVERY = 10     -- the "ORA" line every tenth punch

local VARIANTS = {
    -- finisher: the last blow, in the same units as damage (3.0 = 300%)
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
        -- Every state enters as activity_type 1, which lets him jump out of
        -- it (scr_actor_phy.gml:114); 3 holds him, as Acrid's teleport does
        -- (scr_ror_init_survivor_acrid_alts.gml:263).
        actor.activity_type = 3
        data.hits = 0
        data.wait = 0
    end)

    Callback.add(state.on_step, function(actor, data)
        actor:skill_util_fix_hspeed()
        actor:actor_animation_set(S.starfury, ANIM)

        -- Immune only while the skill runs; it drops two frames after.
        if (tonumber(actor.invincible) or 0) < 2 then actor.invincible = 2 end
        -- The cooldown waits for the rush to end, as Eviscerate's does
        -- (scr_ror_init_survivor_merc.gml:104). Left running, four Alien Heads
        -- bring it back before it ends: invulnerable for good.
        actor:get_active_skill(Skill.Slot.SPECIAL):freeze_cooldown()

        -- One punch per INTERVAL frames of base attack speed: the debt is
        -- paid off by attack_speed each frame, so faster hands punch sooner.
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

        -- The punches outlast the animation at low attack speed, or fall
        -- short at high; the state ends when both are done.
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
