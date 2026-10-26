-- Удар зоной для всех навыков: владелец, Shadow Clone, Heaven Cracker.
-- Бьёт только владелец актёра, fire_explosion рассылает остальным.

local SHADOW_CLONE = Buff.find("shadowClone", "ror")

local Attack = {}

-- 1 вправо, -1 влево.
function Attack.dir(actor)
    return (tonumber(actor:skill_util_facing_direction()) == 180) and -1 or 1
end

function Attack.is_owner(actor)
    return Util.bool(actor:is_authority())
end

local function crit_data(actor)
    return Instance.get_data(actor, "crit", _ENV["!guid"])
end

-- Заряд A Moment: следующий удар зоной за frames кадров — крит.
-- Ставится везде, тратит владелец.
function Attack.charge_crit(actor, frames)
    crit_data(actor).until_frame = Global._current_frame + frames
end

-- Взрыв w x h на dx px впереди, по разу на стак Shadow Clone + 1.
-- Тратит заряд крита. Возвращает атаки (пусто не у владельца).
-- Эффект в центре рисует навык через Fx: спрайт fire_explosion не смотрит влево.
-- opts:
--   dy        сдвиг центра по вертикали
--   sparks    спрайт на каждом задетом
--   proc      false — без эффектов предметов (по умолчанию true)
--   primary   true — может сработать Heaven Cracker
--   stun      1 = 1,5 с
--   knockback отброс в сторону взгляда
--   max_hit   врагов за удар (0 — без предела)
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
