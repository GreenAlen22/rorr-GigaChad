-- Gigachad: a melee survivor for Risk of Rain Returns.
--
-- The design lives in PLAN.md at the project root. Engine traps live in
-- rorr_cloding/knowledge/.

mods["LuaENVY-ENVY"].auto()
mods["ReturnsAPI-ReturnsAPI"].auto{
    -- Kept from 2.x: SPPModdedSurvivors finds Gigachad under this namespace.
    namespace = "GreenAlen22",
    -- Without it the API greys out the Online button for the whole modpack.
    mp        = true,
}

-- Absolute, and taken here rather than from somebody's global: a relative
-- require resolves against whichever mod the engine credits with the calling
-- closure, and from a deferred callback that was once another plugin's folder.
local PATH = _ENV["!plugins_mod_folder_path"].."\\"

-- Load order (rorr_cloding/knowledge/bootstrap.md): assets before anything
-- that draws or plays them, shared helpers before the skills, the survivor
-- before its skills, which take their slots from it.
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
    -- The passive reads the attack states of the skills above.
    "skills/stance",
}

-- A module fails to load two ways, and both are silent: the file is not at that
-- path (require says nothing and returns), or it throws partway through.
-- io.open catches the first, pcall the second.
local function load(name)
    local file = (PATH..name..".lua"):gsub("/", "\\")

    local f = io.open(file, "r")
    if not f then
        log.warning("Gigachad: file not found -> "..file)
        return false
    end
    f:close()

    -- Not `pcall(require, file)`: there the frame above require is pcall, a C
    -- function with no environment, and the engine credits the module to the
    -- first loaded plugin.
    local ok, err = pcall(function() require(file) end)
    if not ok then
        log.warning("Gigachad: FAILED to load "..name.." -> "..tostring(err))
        return false
    end
    return true
end

-- A successful require proves nothing on its own; modules talk through the
-- global GIGACHAD, so their branches existing is the evidence the code ran.
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
