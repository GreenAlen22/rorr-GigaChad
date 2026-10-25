-- One way to land a melee hit, so every skill handles ownership, Shadow Clone
-- and Heaven Cracker the same.
--
-- Skill states run on every machine (knowledge/net.md); the hit is fired by the
-- actor's owner only, and fire_explosion syncs it to the rest. 2.x fired some
-- hits outside this check, and online each machine dealt them again.

local SHADOW_CLONE = Buff.find("shadowClone", "ror")

local Attack = {}

-- +1 when facing right, -1 when facing left.
function Attack.dir(actor)
    return (tonumber(actor:skill_util_facing_direction()) == 180) and -1 or 1
end

function Attack.is_owner(actor)
    return Util.bool(actor:is_authority())
end

local function crit_data(actor)
    return Instance.get_data(actor, "crit", _ENV["!guid"])
end

-- A Moment leaves a charge: the next zone hit within `frames` is critical.
-- Set on every machine with the skill state; spent by the owner, who alone
-- fires the hit.
function Attack.charge_crit(actor, frames)
    crit_data(actor).until_frame = Global._current_frame + frames
end

-- Effects at the centre are drawn by the skill with GIGACHAD.Fx: the explosion
-- sprite of fire_explosion would repeat per clone and never face left
-- (gml_Object_oExplosionAttack_Step_1 passes xscale 1).
--
-- Fires a w x h explosion centred dx px ahead of the actor, once per Shadow
-- Clone stack plus one. Spends a crit charge from Attack.charge_crit on every
-- one of them. Returns the attack instances (empty off the owner).
--
-- opts:
--   dy        vertical offset of the centre
--   sparks    sprite drawn on each actor hit
--   proc      false = no item effects (default true)
--   primary   true = Heaven Cracker may replace the hit; it counts primary
--             attacks only, as in vanilla
--   stun      attack_info.stun (1 = 1.5 s, knowledge/mechanics.md)
--   knockback attack_info.knockback, pushed the way the actor faces
--   max_hit   enemies one hit may strike (0 = no limit)
function Attack.zone(actor, damage, dx, w, h, opts)
    opts = opts or {}
    local hits = {}
    if not Attack.is_owner(actor) then return hits end

    if opts.primary and Util.bool(actor:skill_util_update_heaven_cracker(actor, damage)) then
        return hits
    end

    local dir = Attack.dir(actor)
    local proc = opts.proc
    if proc == nil then proc = true end

    local charge = crit_data(actor)
    local crit = (charge.until_frame or -1) >= Global._current_frame
    if crit then charge.until_frame = nil end

    for i = 0, actor:buff_count(SHADOW_CLONE) do
        local inst = actor:fire_explosion(
            actor.x + dx * dir, actor.y + (opts.dy or 0),
            w, h, damage, nil, opts.sparks, proc)
        local info = inst.attack_info
        info.climb = i * 8
        if opts.stun then info.stun = opts.stun end
        if opts.knockback then
            info.knockback = opts.knockback
            info.knockback_direction = dir
        end
        if opts.max_hit then inst.max_hit_number = opts.max_hit end
        if crit then AttackInfo.wrap(info):set_critical(true) end
        hits[#hits + 1] = inst
    end
    return hits
end

GIGACHAD.Attack = Attack
