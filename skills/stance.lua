-- Passive, Stance: while Gigachad attacks, and for a second after, he takes
-- 15% less damage and cannot be stunned or knocked back. He does not back down
-- while he fights; running off or dashing away lets it lapse. An anchor over
-- his head shows it.
--
-- The first take asked him to stand still, which a run of Risk of Rain never
-- allows. Attacks are skill states, and those play on every machine, so each
-- works the stance out the same. Knockback and stun land on the host only
-- (actor_knockback_inflict.gml:8); damage is reduced wherever
-- damager_calculate_damage runs. Both read their own copy, so nothing is sent.
--
-- Loaded after the skills: it reads their states.

local SURVIVOR = GIGACHAD.Survivor.survivor
local S        = GIGACHAD.Assets.sprites

local DAMAGE_TAKEN = 0.85
local LINGER = 60     -- frames the stance holds after an attack ends

-- His attacks. Not A Moment, a way out; not MeguMin, whose spent seconds are
-- meant to leave him open.
local ATTACKS = {}
for _, state in ipairs({
    GIGACHAD.Stab.state, GIGACHAD.Sparta.state,
    GIGACHAD.Seismic.state, GIGACHAD.Trolling.state,
    GIGACHAD.StarFury.state, GIGACHAD.StarFury.state_boosted,
}) do
    ATTACKS[state.value] = true
end

local function data_of(player)
    return Instance.get_data(player, "stance", _ENV["!guid"])
end

-- The icon sits in the stack of buff icons, above the vanilla ones: the game
-- draws them from y - (32 + idle y-origin) upward, 26 px apart
-- (scr_effectDisplay.gml, DrawScript_draw_buffs).
local ICON_BASE, ICON_STEP = 32, 26

local function place(inst, owner)
    local above = ICON_BASE + gm.sprite_get_yoffset(owner.sprite_idle) * owner.image_yscale
    inst.x = owner.x
    inst.y = owner.y - above - ICON_STEP * (tonumber(owner.buff_icon_count) or 0)
    inst.depth = owner.depth - 1
end

local icon = Object.new("gigachadStance")
icon:set_sprite(S.stance)

Callback.add(icon.on_create, function(inst)
    inst.image_speed = 0
    inst.parent = -4
end)

Callback.add(icon.on_step, function(inst)
    local owner = inst.parent
    if not Instance.exists(owner) or not data_of(owner).on then
        inst:destroy()
        return
    end
    place(inst, owner)
end)

local function is_gigachad(actor)
    return actor.object_index == gm.constants.oP and actor.class == SURVIVOR.value
end

Callback.add(Callback.ON_PLAYER_STEP, function(player)
    if not is_gigachad(player) then return end
    local d = data_of(player)

    if ATTACKS[player.actor_state_current_id] then
        d.left = LINGER
    else
        d.left = math.max(0, (d.left or 0) - 1)
    end

    local on = d.left > 0
    if on ~= d.on then
        d.on = on
        -- Players are created with false (init_actor_default.gml:96).
        player.knockback_immune = on
    end

    -- Every machine draws its own: the stance is worked out on each. A stage
    -- change takes the icon with it, so it is recreated rather than kept.
    if on and not (d.icon and Instance.exists(d.icon)) then
        d.icon = icon:create(player.x, player.y)
        d.icon.parent = player
        place(d.icon, player)
    end
end)

DamageCalculate.add(function(api)
    local hit = api.hit
    if not Instance.exists(hit) or not is_gigachad(hit) then return end
    if data_of(hit).on then api.damage_mult(DAMAGE_TAKEN) end
end)

GIGACHAD.Stance = true
