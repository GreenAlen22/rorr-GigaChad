-- C alt, Gigamusic: +60% attack speed and +40% movement speed for 8 s, with a
-- spinning record over his head. Each kill while it plays adds half a second,
-- up to 16 s in all.
--
-- 2.x kept its own timer table beside the game's, darkened the hero for the
-- whole buff and played the music to every player at full volume.

local S      = GIGACHAD.Assets.sprites
local Sounds = GIGACHAD.Assets.sounds

local DURATION     = 8 * 60
local ATTACK_SPEED = 0.6
local MOVE_SPEED   = 1.4
local NOTE_HEIGHT  = 100   -- px above actor.y
local KILL_BONUS   = 30    -- frames added per kill
local MAX_TOTAL    = 16 * 60

local buff = Buff.new("gigamusic")
buff.show_icon = false
buff.is_timed  = true
buff.is_debuff = false
buff.max_stack = 1

RecalculateStats.add(function(actor, api)
    if actor:buff_count(buff) > 0 then
        api.attack_speed_add(ATTACK_SPEED)
        api.pHmax_mult(MOVE_SPEED)
    end
end)

-- Kills are seen by the host only (ON_KILL_PROC, knowledge/net.md), and the
-- buff is the host's to time: a client keeps it until the host removes it
-- (step_buff.gml:8-12), so the extension reaches it with the removal.
Callback.add(Callback.ON_KILL_PROC, function(target, attacker)
    -- buff_set_time has no client guard of its own (knowledge/net.md).
    if not Net.host then return end
    if not Instance.exists(attacker) or attacker:buff_count(buff) == 0 then return end
    local d = Instance.get_data(attacker, "gigamusic", _ENV["!guid"])
    local add = math.min(KILL_BONUS, MAX_TOTAL - DURATION - (d.extra or 0))
    if add <= 0 then return end
    d.extra = (d.extra or 0) + add
    attacker:buff_set_time(buff, attacker:buff_get_time(buff) + add)
end)

-- The record follows its owner while the buff lasts. The first second it
-- stays regardless: on a client the buff arrives from the host a few frames
-- after the skill.
local GRACE = 60

local note = Object.new("EfGigamusic")
note:set_sprite(S.music)

Callback.add(note.on_create, function(inst)
    inst.parent = -4
    Instance.get_data(inst, nil, _ENV["!guid"]).age = 0
end)

Callback.add(note.on_step, function(inst)
    local owner = inst.parent
    local data = Instance.get_data(inst, nil, _ENV["!guid"])
    data.age = data.age + 1
    if not Instance.exists(owner)
    or (data.age > GRACE and owner:buff_count(buff) == 0) then
        inst:destroy()
        return
    end
    inst.x = owner.x
    inst.y = owner.y - NOTE_HEIGHT
    inst.depth = owner.depth - 1
end)

local skill = Skill.new("GigachadC2")
GIGACHAD.Survivor.survivor:add_skill(Skill.Slot.UTILITY, skill)
skill.sprite     = S.skills
skill.subimage   = 7
skill.damage     = 0
skill.cooldown   = 20 * 60
skill.is_utility = true

-- Using the skill is instant: no animation of its own to stand through.
-- 2.x played shoot3_2.png, four blurry frames cut at a fractional width.
Callback.add(skill.on_activate, function(actor)
    if Net.host then
        Instance.get_data(actor, "gigamusic", _ENV["!guid"]).extra = 0
        actor:buff_apply(buff, DURATION)
        -- buff_apply does not refresh a buff already at max stack
        -- (knowledge/items.md).
        actor:buff_set_time(buff, DURATION)
    end

    local inst = note:create(actor.x, actor.y - NOTE_HEIGHT)
    inst.parent = actor

    actor:sound_play(Sounds.gigamusic, 1, 1)
end)

GIGACHAD.Gigamusic = { skill = skill, buff = buff }
