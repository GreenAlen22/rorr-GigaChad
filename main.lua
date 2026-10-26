-- Gigachad: выживший ближнего боя.

mods["LuaENVY-ENVY"].auto()
mods["ReturnsAPI-ReturnsAPI"].auto{
    -- С 2.x: по нему ищет SPPModdedSurvivors.
    namespace = "GreenAlen22",
    -- Без него API гасит кнопку Online.
    mp        = true,
}

-- Абсолютный путь: относительный require из отложенного колбэка уходит в чужую папку.
local PATH = _ENV["!plugins_mod_folder_path"].."\\"

-- Порядок: ассеты → хелперы → выживший → навыки.
local modules = {
    "core/assets",
    "core/attack",
    "core/fx",
    "survivor",
    "skills/stab",
    "skills/seismic",
    "skills/moment",
    "skills/starfury",
    "skills/sparta",
    "skills/trolling",
    "skills/gigamusic",
    "skills/explosion",
    -- Читает состояния навыков выше.
    "skills/stance",
}

-- Оба провала молчаливые: нет файла (ловит io.open) или ошибка внутри (ловит pcall).
local function load(name)
    local file = (PATH..name..".lua"):gsub("/", "\\")

    local f = io.open(file, "r")
    if not f then
        log.warning("Gigachad: file not found -> "..file)
        return false
    end
    f:close()

    -- Не pcall(require, file): модуль припишется первому загруженному плагину.
    local ok, err = pcall(function() require(file) end)
    if not ok then
        log.warning("Gigachad: FAILED to load "..name.." -> "..tostring(err))
        return false
    end
    return true
end

-- Модуль отработал, если его ветка есть в GIGACHAD.
local expected = {
    "Assets", "Attack", "Fx", "Survivor",
    "Stab", "Seismic", "Moment", "StarFury",
    "Sparta", "Trolling", "Gigamusic", "Explosion", "Stance",
}

Initialize.add_hotloadable(function()
    GIGACHAD = {}

    local loaded = 0
    for _, name in ipairs(modules) do
        if load(name) then loaded = loaded + 1 end
    end

    local missing = {}
    for _, key in ipairs(expected) do
        if not GIGACHAD[key] then missing[#missing + 1] = key end
    end

    if loaded == #modules and #missing == 0 then
        log.info("Gigachad: initialized ("..loaded.."/"..#modules.." modules)")
    else
        log.warning("Gigachad: initialized PARTIALLY ("..loaded.."/"..#modules
            .." modules; missing: "..table.concat(missing, ", ")..")")
    end
end)
