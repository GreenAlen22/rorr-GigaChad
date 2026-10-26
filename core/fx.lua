-- Косметика навыков. Каждая машина рисует сама, по сети ничего.

local Fx = {}

-- Спрайт один раз и удалить (oEfSparks).
-- yscale задаётся всегда: Create случайно отражает по вертикали.
-- sprite — Sprite или ванильный id; opts: speed, xscale, yscale, depth, alpha, angle.
-- speed 1 — скорость из core/assets.lua.
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

-- Шлейф: копия текущего кадра, гаснет сама.
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
