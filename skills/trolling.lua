-- X alt, Trolling: a swing, and a Troll Face that drifts ahead and hits each
-- enemy once for a random 150-600%. Each enemy it kills makes it bigger, so
-- a face sent into a crowd hits more of it.

local S      = GIGACHAD.Assets.sprites
local Sounds = GIGACHAD.Assets.sounds
local Attack = GIGACHAD.Attack
local Fx     = GIGACHAD.Fx

local DAMAGE     = 1.0
local SPAWN_FRAME = 5    -- the punch lands here (shoot2_2.png, frames 5-8)
local ANIM       = 0.35

local FACE_SPEED    = 2.0
local FACE_LIFE     = 150   -- frames: 300 px of travel
local FACE_FADE     = 30    -- last frames spent fading out
local FACE_W, FACE_H = 60, 90
local FACE_MIN, FACE_MAX = 1.5, 6.0
local GROW, GROW_MAX = 0.25, 2.0   -- scale added per kill, and its ceiling

local skill = Skill.new("GigachadX2")
GIGACHAD.Survivor.survivor:add_skill(Skill.Slot.SECONDARY, skill)
skill.sprite    = S.skills
skill.subimage  = 6
skill.damage    = DAMAGE
skill.cooldown  = 5 * 60
skill.animation = S.trolling

-- The face exists on every machine (the skill state plays everywhere); only
-- the owner of the skill deals its damage, and fire_direct sends it on.
local face = Object.new("gigachadTroll")
face:set_sprite(S.troll_face)

-- Faces alive on this machine, by instance id, for the death callback.
local faces = {}

local function remove(inst)
    faces[inst.id] = nil
    inst:destroy()
end

Callback.add(face.on_create, function(inst)
    inst.image_speed = 0
    inst.parent = -4
    local data = Instance.get_data(inst, nil, _ENV["!guid"])
    data.hit   = {}
    data.life  = FACE_LIFE
    data.scale = 1
    faces[inst.id] = inst
end)

-- ON_DEATH runs on every machine and names the killer (knowledge/net.md), so
-- each copy of the face grows by itself. The face's hit is fire_direct from
-- its owner: a death the owner caused among the face's targets is its kill.
Callback.add(Callback.ON_DEATH, function(victim)
    local killer = victim.kill_parent
    if not Instance.exists(killer) then return end
    for id, inst in pairs(faces) do
        if not Instance.exists(inst) then
            faces[id] = nil
        else
            local data = Instance.get_data(inst, nil, _ENV["!guid"])
            local owner = inst.parent
            if data.hit[victim.id] and Instance.exists(owner) and owner.id == killer.id then
                data.scale = math.min(GROW_MAX, data.scale + GROW)
            end
        end
    end
end)

Callback.add(face.on_step, function(inst)
    local owner = inst.parent
    if not Instance.exists(owner) then remove(inst) return end
    local data = Instance.get_data(inst, nil, _ENV["!guid"])

    inst.x = inst.x + data.dir * FACE_SPEED
    data.life = data.life - 1
    if data.life <= 0 then remove(inst) return end
    inst.image_alpha = math.min(1, data.life / FACE_FADE)
    inst.image_xscale = data.dir * data.scale
    inst.image_yscale = data.scale
    if data.life % 8 == 0 then Fx.trail(inst, 0.4) end

    -- A fixed box rather than the sprite's mask: the hit area does not shrink
    -- with the art (2.x drew a 128 px face, and that was its hitbox).
    local w, h = FACE_W * data.scale / 2, FACE_H * data.scale / 2
    local hits = inst:get_collisions_rectangle(gm.constants.pActorCollisionBase,
        inst.x - w, inst.y - h, inst.x + w, inst.y + h)
    for _, part in ipairs(hits) do
        -- A hitbox stands for its owner (attack_collision_resolve.gml): without
        -- this a body and each of its hitboxes were struck as separate enemies.
        local target = GM.attack_collision_resolve(part)
        if Instance.exists(target)
        and not data.hit[target.id] and Util.bool(owner:attack_collision_canhit(target)) then
            data.hit[target.id] = true
            if Attack.is_owner(owner) then
                local roll = FACE_MIN + math.random() * (FACE_MAX - FACE_MIN)
                owner:fire_direct(target, roll, data.dir == 1 and 0 or 180,
                    inst.x, inst.y, S.troll_hit)
            end
            target:sound_play(Sounds.trollface, 0.5, 0.9 + math.random() * 0.2)
        end
    end
end)

local state = ActorState.new("GigachadX2")

Callback.add(skill.on_activate, function(actor)
    actor:set_state(state)
end)

Callback.add(state.on_enter, function(actor, data)
    actor.image_index = 0
    data.fired = 0
end)

Callback.add(state.on_step, function(actor, data)
    actor:skill_util_fix_hspeed()
    actor:actor_animation_set(S.trolling, ANIM)

    if data.fired == 0 and actor.image_index >= SPAWN_FRAME then
        data.fired = 1
        local dir = Attack.dir(actor)

        Attack.zone(actor, actor:skill_get_damage(skill.value), 30, 120, 90)

        local inst = face:create(actor.x + 20 * dir, actor.y - 12)
        inst.parent = actor
        inst.image_xscale = dir
        inst.depth = actor.depth - 1
        Instance.get_data(inst, nil, _ENV["!guid"]).dir = dir

        actor:sound_play(Sounds.trollface, 1, 0.9 + math.random() * 0.2)
        actor:screen_shake(2)
    end

    actor:skill_util_exit_state_on_anim_end()
end)

GIGACHAD.Trolling = { skill = skill, state = state, face = face }
