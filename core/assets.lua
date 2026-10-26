-- Все спрайты и звуки мода.
-- - Каждая загрузка в pcall: битый файл не обрывает остальные, ошибки — одним списком.
-- - Идентификаторы 2.x не менять: SPPModdedSurvivors ищет по имени.

local PATH = _ENV["!plugins_mod_folder_path"]

local A = { sprites = {}, sounds = {} }
local failed = {}

-- key = { identifier, file, frames, x_origin, y_origin, speed }
-- Тело: начало 36, 52 — ноги на 11 px ниже actor.y.
local SPRITES = {
    idle          = { "gigachad_idle",            "idle.png",             7, 36, 52, 0.5 },
    walk          = { "gigachad_walk",            "walk.png",            10, 36, 52 },
    jump          = { "gigachad_jump",            "jump.png",             1, 36, 52 },
    -- Вид со спины; x 35 — верёвка в руках.
    climb         = { "gigachad_climb",           "climb.png",            6, 35, 52 },
    death         = { "gigachad_death",           "death.png",           11, 36, 52 },
    -- Анимацию запускает survivor.lua.
    decoy         = { "gigachad_decoy",           "decoy.png",            4, 16, 20 },
    -- Дрон Артификатора с бородой; кадры и начало как у sDronePlayerArti*.
    drone_idle    = { "gigachad_drone_idle",      "drone_idle.png",       5, 11, 14 },
    drone_shoot   = { "gigachad_drone_shoot",     "drone_shoot.png",      5, 25, 14 },

    stab          = { "gigachadshoot1",           "shoot1_1.png",        17, 36, 52 },
    sparta        = { "gigachad_shoot1_2",        "shoot1_2.png",        11, 36, 52 },
    seismic       = { "gigachad_shoot2",          "shoot2.png",          12, 36, 52 },
    trolling      = { "gigachad_shoot2_2",        "shoot2_2.png",        12, 36, 52 },
    moment        = { "gigachad_shoot3",          "shoot3.png",          17, 36, 52 },
    starfury      = { "gigachad_shoot4",          "shoot4.png",          41, 36, 52 },

    skills        = { "gigachad_skills",          "skills.png",          10,  0,  0 },

    spike         = { "gigachad_spike",           "par_spike.png",       20, 180, 80, 0.5 },
    spike_sparks  = { "gigachad_sparks",          "par_hitspike.png",     4, 16, 17 },
    troll_face    = { "gigachad_big_trollface",   "par_big_trollface.png", 1, 22, 22 },
    troll_hit     = { "gigachad_small_trollface", "par_small_trollface.png", 12, 20, 17, 0.7 },
    jojo          = { "gigachad_jojo",            "par_jojo.png",         1, 16, 16 },
    megumin       = { "gigachad_megumin",         "par_megumin.png",      1, 14, 22 },
    music         = { "gigachadBuff_music",       "par_gigamusic.png",   20, 16, 16, 0.25 },
    megu_blast    = { "gigachad_megu_blast",      "megu_blast.png",      14, 160, 250, 0.33 },
    -- Иконка баффа 36x28, по центру.
    stance        = { "gigachad_stance",          "stance_icon.png",      1, 18, 14 },

    -- Скины: столбец на скин, 0 — по умолчанию. Без палитры API берёт Коммандо.
    palette          = { "gigachad_palette",          "palette.png",          1, 0, 0 },
    palette_portrait = { "gigachad_palette_portrait", "palette_portrait.png", 1, 0, 0 },
    palette_loadout  = { "gigachad_palette_loadout",  "palette_loadout.png",  1, 0, 0 },

    -- Разгорается на кадрах 0-2.
    loadout       = { "sSelectGigachad",          "sSelectGigachad.png", 13, 28,  0 },
    portrait      = { "sGigachadPortrait",        "sGigachadPortrait.png", 3, 0, 0 },
    portrait_small= { "sGigachadPortraitSmall",   "sGigachadPortraitSmall.png", 1, 0, 0 },
    log_portrait  = { "sGigachadPortraitLogo",    "sGigachadPortraitLogo.png", 1, 0, 0 },
}

-- key = { identifier, file }
-- Ogg — решение владельца 05.10.2026. Вернутся вылеты — `sfx_deploy.py --wav`
-- и расширение здесь.
local SOUNDS = {
    ora           = { "gigachad_ora",             "snd_ora.ogg" },
    trollface     = { "gigachad_trollface",       "snd_trollface.ogg" },
    gigamusic     = { "gigachad_gigamusic",       "snd_gigamusic.ogg" },
    megumin_cast  = { "gigachad_megumin_cast",    "snd_megumin_cast.ogg" },
    -- Два дубля; выбирает skills/explosion.lua.
    megumin_blast_a = { "gigachad_megumin_blast_a", "snd_megumin_blast_a.ogg" },
    megumin_blast_b = { "gigachad_megumin_blast_b", "snd_megumin_blast_b.ogg" },
}

-- Сеть нумерует ресурсы по порядку добавления, искры атак ходят по номеру.
-- У pairs() порядок на машинах разный — сортируем ключи.
local function sorted_keys(t)
    local keys = {}
    for k in pairs(t) do keys[#keys + 1] = k end
    table.sort(keys)
    return keys
end

for _, key in ipairs(sorted_keys(SPRITES)) do
    local s = SPRITES[key]
    local ok, res = pcall(Sprite.new, s[1], path.combine(PATH, "gigachad", s[2]), s[3], s[4], s[5])
    if ok and res then
        if s[6] then res:set_speed(s[6]) end
        A.sprites[key] = res
    else
        failed[#failed + 1] = s[2].." ("..tostring(res)..")"
    end
end

for _, key in ipairs(sorted_keys(SOUNDS)) do
    local s = SOUNDS[key]
    local ok, res = pcall(Sound.new, s[1], path.combine(PATH, "assets", "sounds", s[2]))
    if ok and res then
        A.sounds[key] = res
    else
        failed[#failed + 1] = s[2].." ("..tostring(res)..")"
    end
end

if #failed > 0 then
    -- Ошибка, не лог: выживший без спрайтов хуже незагруженного.
    error("assets failed to load: "..table.concat(failed, "; "))
end

GIGACHAD.Assets = A
