-- C alt, Gigamusic: +60% скорости атаки и +40% движения на 8 с.
-- Убийство под музыку: +0,5 с, всего до 16 с.

local S      = GIGACHAD.Assets.sprites
local Sounds = GIGACHAD.Assets.sounds

local DURATION     = 8 * 60
local ATTACK_SPEED = 0.6
local MOVE_SPEED   = 1.4
local NOTE_HEIGHT  = 100   -- px над actor.y
local KILL_BONUS   = 30    -- кадров за убийство
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

-- Убийства видит только хост, таймер баффа хостовый: клиент держит бафф,
-- пока хост не снимет.
Callback.add(Callback.ON_KILL_PROC, function(target, attacker)
    -- У buff_set_time нет своей защиты от клиента.
    if not Net.host then return end
    if not Instance.exists(attacker) or attacker:buff_count(buff) == 0 then return end
    local d = Instance.get_data(attacker, "gigamusic", _ENV["!guid"])
    local add = math.min(KILL_BONUS, MAX_TOTAL - DURATION - (d.extra or 0))
    if add <= 0 then return end
    d.extra = (d.extra or 0) + add
    attacker:buff_set_time(buff, attacker:buff_get_time(buff) + add)
end)

-- Пластинка живёт, пока есть бафф. Первую секунду — всегда: клиенту бафф
-- приходит с задержкой.
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

-- Мгновенно, без своей анимации.
Callback.add(skill.on_activate, function(actor)
    if Net.host then
        Instance.get_data(actor, "gigamusic", _ENV["!guid"]).extra = 0
        actor:buff_apply(buff, DURATION)
        -- buff_apply не обновляет бафф на максимуме стаков.
        actor:buff_set_time(buff, DURATION)
    end

    local inst = note:create(actor.x, actor.y - NOTE_HEIGHT)
    inst.parent = actor

    actor:sound_play(Sounds.gigamusic, 1, 1)
end)

GIGACHAD.Gigamusic = { skill = skill, buff = buff }
