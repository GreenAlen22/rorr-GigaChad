-- V alt, MeguMin: a short chant under a magic circle, a huge blast around
-- him, then he drops to his knees, spent, as Megumin does after Explosion.
-- The blast costs half his health unless it kills ten enemies: fired into a
-- crowd, it pays for itself.
-- Under Ancient Scepter: MeguMax, bigger and harder, costs no health and
-- leaves him spent for less.
--
-- 2.x: 14 s of standing, 479900% over the whole level (the teleporter boss
-- included) and death. The blast sprite was a 1000x1000 airbrushed image of
-- 66 thousand colours that flashed by in 0.2 s, centred 100 px above him, and
-- Megumin stayed on the map until the end of the stage.

local S      = GIGACHAD.Assets.sprites
local Sounds = GIGACHAD.Assets.sounds
local Attack = GIGACHAD.Attack
local Fx     = GIGACHAD.Fx

-- The chant lasts as long as its sound (art/megu_sound.py cuts 2.65 s).
local CAST  = 159
local BLAST_SOUND = Sounds.megumin_blast_a   -- take A; take B is shorter

local VARIANTS = {
    -- 6000% every 45 s: a third above Star Fury's ~105% a second, for the
    -- chant, the spent seconds and the health.
    normal  = { id = "GigachadV2",        subimage = 8, damage = 60, w = 1000, h = 700,
                hp_cost = 0.5, spent = 150 },
    boosted = { id = "GigachadV2Boosted", subimage = 9, damage = 100, w = 1600, h = 1000,
                hp_cost = 0,   spent = 60 },
}

-- Flat colours of the vanilla explosions (sEfTurtleExplosion).
local RED    = Color.from_hex(0xb93527)
local ORANGE = Color.from_hex(0xea974e)
local YELLOW = Color.from_hex(0xf1e878)
local WHITE  = Color.from_hex(0xfffbf1)

local GROUND = 11   -- px from actor.y down to his feet

-- Kills counted for this long after the blast; the health cost comes at the end.
local KILL_WINDOW = 30
local KILLS_FREE  = 10   -- this many kills and the blast costs no health

local function data_of(inst)
    return Instance.get_data(inst, nil, _ENV["!guid"])
end

----------------------------------------------------------------------------
-- Magic circle: drawn with lines, so it stays sharp at any size.

local circle = Object.new("gigachadMeguCircle")

Callback.add(circle.on_create, function(inst)
    inst.parent = -4
    local d = data_of(inst)
    d.t = 0
    d.radius = 70
end)

Callback.add(circle.on_step, function(inst)
    local d = data_of(inst)
    d.t = d.t + 1
    if d.t >= CAST or not Instance.exists(inst.parent) then inst:destroy() return end
    inst.x = inst.parent.x
    inst.y = inst.parent.y
end)

local function ring(x, y, r, col, alpha)
    gm.draw_set_alpha(alpha)
    gm.draw_set_colour(col)
    gm.draw_circle(x, y, r, true)
end

Callback.add(circle.on_draw, function(inst)
    local d = data_of(inst)
    local p = d.t / CAST
    -- Grows over the first 40% of the chant, spins faster towards the end.
    local r = d.radius * (1 - (1 - math.min(1, p / 0.4)) ^ 3)
    local spin = (d.t ^ 1.6) * 0.15
    local cx, cy = inst.x, inst.y - 24
    local alpha = 0.55 + 0.25 * math.sin(d.t * 0.3) + 0.2 * p
    local hot = p > 0.85   -- the last moments burn white

    ring(cx, cy, r,     hot and WHITE or ORANGE, alpha)
    ring(cx, cy, r - 4, hot and YELLOW or RED,   alpha)

    -- Pentagram: each point to the one two steps on.
    gm.draw_set_colour(hot and WHITE or RED)
    local pts = {}
    for i = 0, 4 do
        local a = math.rad(spin + i * 72 - 90)
        pts[i] = { cx + math.cos(a) * (r - 6), cy + math.sin(a) * (r - 6) }
    end
    for i = 0, 4 do
        local a, b = pts[i], pts[(i + 2) % 5]
        gm.draw_line_width(a[1], a[2], b[1], b[2], 1)
    end

    -- Runes: ticks between the rings, turning the other way.
    gm.draw_set_colour(YELLOW)
    for i = 0, 11 do
        local a = math.rad(-spin * 0.7 + i * 30)
        local c, s = math.cos(a), math.sin(a)
        gm.draw_line_width(cx + c * (r - 4), cy + s * (r - 4), cx + c * (r + 6), cy + s * (r + 6), 1)
    end

    -- A flat ring on the ground under him.
    local gy = inst.y + GROUND
    gm.draw_set_colour(hot and WHITE or ORANGE)
    gm.draw_ellipse(cx - r * 1.4, gy - r * 0.22, cx + r * 1.4, gy + r * 0.22, true)

    gm.draw_set_alpha(1)
end)

----------------------------------------------------------------------------
-- Megumin: fades in beside him for the chant, fades out after the blast.

local megumin = Object.new("gigachadMegumin")
megumin:set_sprite(S.megumin)

local MEGUMIN_LIFE, MEGUMIN_FADE = CAST + 40, 20

Callback.add(megumin.on_create, function(inst)
    inst.image_speed = 0
    inst.image_alpha = 0
    data_of(inst).t = 0
end)

Callback.add(megumin.on_step, function(inst)
    local d = data_of(inst)
    d.t = d.t + 1
    if d.t >= MEGUMIN_LIFE then inst:destroy() return end
    inst.image_alpha = math.min(1, d.t / MEGUMIN_FADE, (MEGUMIN_LIFE - d.t) / MEGUMIN_FADE)
end)

----------------------------------------------------------------------------
-- White-out: the screen goes white at the blast and clears in 20 frames.

local flash = Object.new("gigachadMeguFlash")
local FLASH_LIFE = 20

Callback.add(flash.on_create, function(inst)
    inst.depth = -100000
    data_of(inst).t = FLASH_LIFE
end)

Callback.add(flash.on_step, function(inst)
    local d = data_of(inst)
    d.t = d.t - 1
    if d.t <= 0 then inst:destroy() end
end)

Callback.add(flash.on_draw, function(inst)
    local d = data_of(inst)
    gm.draw_set_alpha(0.9 * (d.t / FLASH_LIFE) ^ 2)
    gm.draw_set_colour(WHITE)
    -- Bigger than any view: the camera is not needed to cover it.
    gm.draw_rectangle(inst.x - 4000, inst.y - 3000, inst.x + 4000, inst.y + 3000, false)
    gm.draw_set_alpha(1)
end)

----------------------------------------------------------------------------
-- Kill count. ON_DEATH runs on every machine and names the killer
-- (knowledge/net.md), so each machine counts by itself and charges the same
-- health. A client hears of deaths a few frames late; the window covers it.

local function kills_of(actor)
    return Instance.get_data(actor, "megumin", _ENV["!guid"])
end

Callback.add(Callback.ON_DEATH, function(victim)
    local killer = victim.kill_parent
    if not Instance.exists(killer) or killer.object_index ~= gm.constants.oP then return end
    local k = kills_of(killer)
    if k.counting then k.n = k.n + 1 end
end)

----------------------------------------------------------------------------
-- The skill.

local BURSTS, BURST_EVERY = 10, 4
local RISE = { 6, 5, 0 }     -- death.png: standing, rising, kneeling

local function spent_frame(t, spent)
    -- Down in 9 frames, kneel, back up in the last 12.
    if t < 9 then return RISE[math.floor(t / 3) + 1] end
    if t >= spent - 12 then return (t >= spent - 6) and 6 or 5 end
    return 0
end

local function setup(skill, v)
    skill.sprite    = S.skills
    skill.subimage  = v.subimage
    skill.damage    = v.damage
    skill.cooldown  = 45 * 60

    local state = ActorState.new(v.id)

    Callback.add(skill.on_activate, function(actor)
        actor:set_state(state)
    end)

    Callback.add(state.on_enter, function(actor, data)
        actor.image_index = 0
        -- No jumping through the chant or out of being spent: see
        -- skills/starfury.lua on activity_type.
        actor.activity_type = 3
        data.t = 0

        local c = circle:create(actor.x, actor.y)
        c.parent = actor
        c.depth = actor.depth + 1

        local dir = Attack.dir(actor)
        local m = megumin:create(actor.x - 26 * dir, actor.y)
        m.image_xscale = dir
        m.depth = actor.depth + 1

        actor:sound_play(Sounds.megumin_cast, 1, 1)
    end)

    Callback.add(state.on_step, function(actor, data)
        actor:skill_util_fix_hspeed()
        data.t = data.t + 1
        local t = data.t

        if t < CAST then
            actor:actor_animation_set(S.idle, 0.5)
            if (tonumber(actor.invincible) or 0) < 2 then actor.invincible = 2 end
            if t > CAST - 30 then actor:screen_shake(1) end
            return
        end

        if t == CAST then
            Attack.zone(actor, actor:skill_get_damage(skill.value), 0, v.w, v.h, { dy = -20 })

            Fx.once(S.megu_blast, actor.x, actor.y + GROUND, { speed = 1, depth = actor.depth - 2 })
            flash:create(actor.x, actor.y)
            actor:screen_shake(20)
            actor:sound_play(BLAST_SOUND, 1, 1)

            local k = kills_of(actor)
            k.counting = true
            k.n = 0
        end

        if t == CAST + KILL_WINDOW then
            local k = kills_of(actor)
            k.counting = false
            if v.hp_cost > 0 and k.n < KILLS_FREE then
                -- Never lethal. Every machine runs this state and subtracts the
                -- same share (knowledge/net.md, player health).
                actor.hp = math.max(1, actor.hp * (1 - v.hp_cost))
            end
        end

        -- Secondary bursts scattered over the blast area, one every few frames.
        local since = t - CAST
        if since < BURSTS * BURST_EVERY and since % BURST_EVERY == 0 then
            local a = math.random() * math.pi * 2
            local k = 0.3 + math.random() * 0.6
            Fx.once(gm.constants.sEfSuperMissileExplosion,
                actor.x + math.cos(a) * v.w * 0.4 * k,
                actor.y - 20 + math.sin(a) * v.h * 0.35 * k,
                { speed = 0.3, depth = actor.depth - 1 })
        end

        -- Spent: on his knees, open to hits.
        if since < v.spent then
            actor:actor_animation_set(S.death, 0, false)
            actor.image_index = spent_frame(since, v.spent)
        else
            actor:skill_util_reset_activity_state()
        end
    end)

    -- Cut short (death, a stage change): stop counting for this cast.
    Callback.add(state.on_exit, function(actor, data)
        kills_of(actor).counting = false
    end)

    return state
end

local skill = Skill.new("GigachadV2")
GIGACHAD.Survivor.survivor:add_skill(Skill.Slot.SPECIAL, skill)
local boosted = Skill.new(VARIANTS.boosted.id)
skill.upgrade_skill = boosted

GIGACHAD.Explosion = {
    skill   = skill,
    boosted = boosted,
    state   = setup(skill, VARIANTS.normal),
    state_boosted = setup(boosted, VARIANTS.boosted),
}
