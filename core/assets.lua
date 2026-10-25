-- Every sprite and sound of the mod, loaded in one place.
--
-- Sprite.new on a bad path calls log.error, which throws: one broken file
-- would cut off every load after it. Each load is wrapped, failures are
-- collected and printed once, so the cause is not buried under the fallout.
--
-- Identifiers carried over from 2.x stay as they were: SPPModdedSurvivors looks
-- some of them up by name.

local PATH = _ENV["!plugins_mod_folder_path"]

local A = { sprites = {}, sounds = {} }
local failed = {}

-- key = { identifier, file, frames, x_origin, y_origin, speed }
-- The body sprites share an origin: 36, 52 puts the feet 11 px under actor.y,
-- where the game expects them.
local SPRITES = {
    idle          = { "gigachad_idle",            "idle.png",             7, 36, 52, 0.5 },
    walk          = { "gigachad_walk",            "walk.png",            10, 36, 52 },
    jump          = { "gigachad_jump",            "jump.png",             1, 36, 52 },
    -- Seen from behind; x 35 is the rope his hands hold in every frame.
    climb         = { "gigachad_climb",           "climb.png",            6, 35, 52 },
    death         = { "gigachad_death",           "death.png",           11, 36, 52 },
    -- A plush toy of him pressing a barbell, 4 frames of a bounce; the game
    -- would show frame 0 only, survivor.lua starts the animation.
    decoy         = { "gigachad_decoy",           "decoy.png",            4, 16, 20 },
    -- Artificer's player drone with his beard and swept hair on the body,
    -- as vanilla drones carry one detail of their survivor (art/build_droneA.py).
    -- Frames and origins of sDronePlayerArtiIdle / Shoot.
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
    -- Buff icon frame (sBuffs: 36x28, centred), drawn by art/stance_icon.py.
    stance        = { "gigachad_stance",          "stance_icon.png",      1, 18, 14 },

    -- Skins: a column each, column 0 is the default (colours as drawn).
    -- Body, portraits and character select each need their own, built by
    -- art/skins.py. Without a palette ReturnsAPI warns on every spawn and
    -- borrows Commando's.
    palette          = { "gigachad_palette",          "palette.png",          1, 0, 0 },
    palette_portrait = { "gigachad_palette_portrait", "palette_portrait.png", 1, 0, 0 },
    palette_loadout  = { "gigachad_palette_loadout",  "palette_loadout.png",  1, 0, 0 },

    -- Seated, chained, a locked box over his face: a weapon in storage.
    -- Built on sSelectCommando,
    -- powers up over frames 0-2.
    loadout       = { "sSelectGigachad",          "sSelectGigachad.png", 13, 28,  0 },
    portrait      = { "sGigachadPortrait",        "sGigachadPortrait.png", 3, 0, 0 },
    portrait_small= { "sGigachadPortraitSmall",   "sGigachadPortraitSmall.png", 1, 0, 0 },
    log_portrait  = { "sGigachadPortraitLogo",    "sGigachadPortraitLogo.png", 1, 0, 0 },
}

-- key = { identifier, file }. Ogg in the package, wav masters in .sfx-draft:
-- the owner's call of 05.10.2026 (knowledge/mcp.md, "Формат"). Sound.new
-- streams an .ogg from disk, which once crashed a game with forty effects; if
-- that comes back, `sfx_deploy.py --wav` and the extension here change together.
local SOUNDS = {
    ora           = { "gigachad_ora",             "snd_ora.ogg" },
    trollface     = { "gigachad_trollface",       "snd_trollface.ogg" },
    gigamusic     = { "gigachad_gigamusic",       "snd_gigamusic.ogg" },
    megumin_cast  = { "gigachad_megumin_cast",    "snd_megumin_cast.ogg" },
    -- Two takes of the blast, for the owner's ear; skills/explosion.lua picks.
    megumin_blast_a = { "gigachad_megumin_blast_a", "snd_megumin_blast_a.ogg" },
    megumin_blast_b = { "gigachad_megumin_blast_b", "snd_megumin_blast_b.ogg" },
}

-- The game numbers each sprite and sound for the network in the order they
-- are added (scr_ResourceManager.gml, register), and attack sparks travel by
-- that number (write_sparks_sprite). pairs() walks a table in a different
-- order on each machine, so the host drew some other sprite where a client's
-- hit had par_small_trollface. Sorted keys give every machine the same order.
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
    -- Thrown, not logged: a survivor without half its sprites is worse than a
    -- survivor that did not load, and main.lua reports the module as failed.
    error("assets failed to load: "..table.concat(failed, "; "))
end

GIGACHAD.Assets = A
