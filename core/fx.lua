-- Cosmetic helpers shared by several skills. Every machine runs them for
-- itself: skill states play out everywhere, so nothing here is sent.

local Fx = {}

-- Plays a sprite once and removes it. oEfSparks destroys itself on animation
-- end (gml_Object_oEfSparks_Other_7). Its Create picks a random vertical flip,
-- so yscale is always set here.
--
-- sprite: a Sprite or a vanilla sprite id (the setter unwraps either).
-- opts.speed multiplies the sprite's own speed (image_speed in GameMaker):
-- 1 plays a sprite at the speed set in core/assets.lua.
-- opts: speed, xscale, yscale, depth, alpha, angle
function Fx.once(sprite, x, y, opts)
    opts = opts or {}
    local inst = Instance.create(x, y, gm.constants.oEfSparks)
    inst.sprite_index = sprite
    inst.image_index  = 0
    inst.image_speed  = opts.speed or 0.3
    inst.image_xscale = opts.xscale or 1
    inst.image_yscale = opts.yscale or 1
    inst.image_alpha  = opts.alpha or 1
    inst.image_angle  = opts.angle or 0
    if opts.depth then inst.depth = opts.depth end
    return inst
end

-- An afterimage of the actor's current frame that fades on its own
-- (gml_Object_oEfTrail_Step_2).
function Fx.trail(actor, alpha)
    local trail = Instance.create(actor.x, actor.y, gm.constants.oEfTrail)
    trail.sprite_index = actor.sprite_index
    trail.image_index  = actor.image_index
    trail.image_xscale = actor.image_xscale
    trail.image_alpha  = alpha or 0.6
    trail.depth        = actor.depth + 1
    return trail
end

GIGACHAD.Fx = Fx
