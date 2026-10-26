-- Выживший: меню, спрайты тела, статы, лог.

local S = GIGACHAD.Assets.sprites

local gigachad = Survivor.new("Gigachad")

gigachad.sprite_loadout        = S.loadout
gigachad.sprite_portrait       = S.portrait
gigachad.sprite_portrait_small = S.portrait_small
gigachad.sprite_title          = S.walk
gigachad.sprite_idle           = S.idle
gigachad.sprite_credits        = S.idle
gigachad.primary_color         = Color.from_rgb(115, 88, 85)
-- x, y, x и y на лестнице
gigachad.cape_offset           = Array.new({-3, -36, 2, -35})

Callback.add(gigachad.on_init, function(actor)
    actor.sprite_idle        = S.idle
    actor.sprite_walk        = S.walk
    actor.sprite_jump        = S.jump
    actor.sprite_jump_peak   = S.jump
    actor.sprite_fall        = S.jump
    actor.sprite_climb       = S.climb
    actor.sprite_death       = S.death
    actor.sprite_decoy       = S.decoy
    actor.sprite_drone_idle  = S.drone_idle
    actor.sprite_drone_shoot = S.drone_shoot
end)

-- Игра держит приманку на кадре 0; анимацию запускаем сами (косметика, локально).
local DECOY_SPEED = 0.12

Callback.add(gigachad.on_step, function()
    for _, decoy in ipairs(Instance.find_all(gm.constants.oEfDecoy)) do
        if tonumber(decoy.sprite_index) == S.decoy.value and tonumber(decoy.image_speed) == 0 then
            decoy.image_speed = DECOY_SPEED
        end
    end
end)

-- Рост между Наёмником и HAN-D: есть неуязвимость и Стойка.
-- Ключ health: maxhp ReturnsAPI не читает.
gigachad:set_stats_base({
    health = 120,
    damage = 12,
    regen  = 0.03,
})
gigachad:set_stats_level({
    health = 38,
    damage = 3,
    regen  = 0.003,
    armor  = 3,
})

-- Порядок как в SKINS из art/skins.py; все скины открыты сразу.
gigachad:add_skin(
    { "default", "meme", "slav", "asian", "nordic", "latino", "golden" },
    S.palette, S.palette_portrait, S.palette_loadout)

-- После статов: лог их копирует.
local log_entry = SurvivorLog.new_from_survivor(gigachad)
log_entry.portrait_id = S.log_portrait
-- SurvivorLog.new его не задаёт.
log_entry.portrait_index = 0
log_entry.sprite_id   = S.walk

GIGACHAD.Survivor = {
    survivor = gigachad,
    -- Слоты по умолчанию.
    slot = function(slot) return gigachad:get_skills(slot)[1] end,
}
