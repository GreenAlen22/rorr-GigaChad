-- RMTtest v1.0.0
-- RoRRModdingToolkit - Umigatari/Miguel

log.info("Successfully loaded ".._ENV["!guid"]..".")
mods["RoRRModdingToolkit-RoRR_Modding_Toolkit"].auto() -- Loading the toolkit 

local PATH = _ENV["!plugins_mod_folder_path"]
local NAMESPACE = "RMT"

local initialize = function()
    local jam = Survivor.new(NAMESPACE, "jamman") -- Create a survivor 

    --[[------------------------------------------
        SECTION SPRITES
    ------------------------------------------]]--
    
    -- Load all of our sprites into a table
    local sprites = {
        idle = Resources.sprite_load(NAMESPACE, "jam_idle", path.combine(PATH, "jam", "idle.png"), 7, 36, 52, 0.5),
        walk = Resources.sprite_load(NAMESPACE, "jam_walk", path.combine(PATH, "jam", "walk.png"), 10, 36, 52),
        jump = Resources.sprite_load(NAMESPACE, "jam_jump", path.combine(PATH, "jam", "jump.png"), 1, 36, 52),
        climb = Resources.sprite_load(NAMESPACE, "jam_climb", path.combine(PATH, "jam", "climb.png"), 3, 34.25, 52),
        death = Resources.sprite_load(NAMESPACE, "jam_death", path.combine(PATH, "jam", "death.png"), 11, 36, 52),
        
        -- This sprite is used by the Crudely Drawn Buddy
        -- If the player doesn't have one, the Commando's sprite will be used instead
        decoy = Resources.sprite_load(NAMESPACE, "jam_decoy", path.combine(PATH, "jam", "decoy.png"), 1, 18, 36),
    }
    
    -- Attack sprites are loaded separately as we'll be using them in our code
    local sprShoot1 = Resources.sprite_load(NAMESPACE, "jam_shoot1", path.combine(PATH, "jam", "shoot1_1.png"), 17, 36, 52)
    local sprShoot1_2 = Resources.sprite_load(NAMESPACE, "jam_shoot1_2", path.combine(PATH, "jam", "shoot1_2.png"), 11, 36, 52)
    local sprShoot2 = Resources.sprite_load(NAMESPACE, "jam_shoot2", path.combine(PATH, "jam", "shoot2.png"), 12, 36, 52)
    local sprShoot3 = Resources.sprite_load(NAMESPACE, "jam_shoot3", path.combine(PATH, "jam", "shoot3.png"), 17, 36, 52)
    local sprShoot4 = Resources.sprite_load(NAMESPACE, "jam_shoot4", path.combine(PATH, "jam", "shoot4.png"), 15, 36, 52)
    
    -- The hit sprite used by our X skill
    local sprSparksJam = Resources.sprite_load(NAMESPACE, "jam_sparks1", path.combine(PATH, "jam", "bullet.png"), 4, 20, 16)
    
    -- The spikes creates by our V skill
    local sprJamSpike = Resources.sprite_load(NAMESPACE, "jam_spike", path.combine(PATH, "jam", "spike.png"), 20, 180, 80, 0.5, 2, 2, 9, 9)
    local sprSparksSpike = Resources.sprite_load(NAMESPACE, "jam_sparks2", path.combine(PATH, "jam", "hitspike.png"), 4, 16, 18)

    -- The sprite used by the skill icons
    local sprSkills = Resources.sprite_load(NAMESPACE, "jam_skills", path.combine(PATH, "jam", "skills.png"), 6, 0, 0)
    
    -- The rgb color of the character's skill names in the character select
    jam:set_primary_color(Color.from_rgb(162, 62, 224))
    
    -- The character's sprite in the selection pod
    jam.sprite_loadout = Resources.sprite_load(NAMESPACE, "sSelectJamman", path.combine(PATH, "jam", "sSelectJamman.png"), 4, 28, 0)

    -- The character's sprite portrait
    jam.sprite_portrait = Resources.sprite_load(NAMESPACE, "sJammanPortrait", path.combine(PATH, "jam", "sJammanPortrait.png"), 3)
    
    -- The character's sprite small portrait
    jam.sprite_portrait_small = Resources.sprite_load(NAMESPACE, "sJammanPortraitSmall", path.combine(PATH, "jam", "sJammanPortraitSmall.png"))

    jam.sprite_title = sprites.walk -- The character's walk animation on the title screen when selected
    jam.sprite_idle = sprites.idle -- The character's idle animation
    jam.sprite_credits = sprites.idle -- The character's idle animation when beating the game

    jam:set_cape_offset(-1, -6, 0, -5) -- Set the Prophet cape offset for the player
    jam:set_animations(sprites) -- Set the player's sprites to those we previously loaded

    --[[------------------------------------------
        SECTION SURVIVOR LOG
    ------------------------------------------]]--

    --  create a new survivor log with the portrait sprite of the survivor as well as the log art
    local log = Survivor_Log.new(jam, jam.sprite_portrait, sprites.jump)

    -- All the log text is in the /elanguage/english.json and is loaded automatically

    --[[------------------------------------------
        SECTION STATS
    ------------------------------------------]]--

    jam:set_stats_base({ -- Set the player's starting stats
        maxhp = 115,
        damage = 10,
        regen = 0.02 -- health regen per frame, so 0.6 per second
    })
    
    jam:set_stats_level({  -- Set the player's leveling stats
        maxhp = 40,
        damage = 3,
        regen = 0.02, -- gain 0.12 health regen per level
        armor = 3
    })

    

    --[[------------------------------------------
        SECTION SKILLS
    ------------------------------------------]]--

    --[[
        Subsection Skill General Setups 
    ]]--
    
    -- Get the default survivor skills
    local skill_stab = jam:get_primary()
    local skill_spikes = jam:get_secondary()
    local skill_roll = jam:get_utility()
    local skill_raspberry = jam:get_special()

    -- Create a new skill for the special skill upgrade
    local skill_raspberryScepter = Skill.new(NAMESPACE, "jammanVBoosted")
    skill_spikes:set_skill_upgrade(skill_raspberryScepter)
    
    -- Set the animation for each skills
    skill_stab:set_skill_animation(sprShoot1)
    skill_spikes:set_skill_animation(sprShoot2)
    skill_roll:set_skill_animation(sprShoot3)
    skill_raspberry:set_skill_animation(sprShoot4)
    skill_raspberryScepter:set_skill_animation(sprShoot4)

    -- Create 1 State for every Skill
    local state_stab = State.new(NAMESPACE, skill_stab.identifier)
    local state_spikes = State.new(NAMESPACE, skill_spikes.identifier)
    local state_roll = State.new(NAMESPACE, skill_roll.identifier)
    local state_raspberry = State.new(NAMESPACE, skill_raspberry.identifier)
    local state_raspberryScepter = State.new(NAMESPACE, skill_raspberryScepter.identifier)

    --[[
        Subsection Primary Skill 
    ]]--

    -- Setup the Primary skill sprite, as well damage and cooldown properties
    skill_stab:set_skill_icon(sprSkills, 0) 
    skill_stab:set_skill_properties(2.5, 15) -- 100% of base damage, 20 frames cooldown

    -- the onActivate callback is called when the player tries to use its primary skill
    skill_stab:onActivate(function(actor, skill, index)
        GM.actor_set_state(actor, state_stab)
    end)

    -- Reset the sprite animation to frame 0 when you enter the state
    state_stab:onEnter(function(actor, data)
        actor.image_index = 0
        data.fired = 0
    end)
    
-- Implement the actual mechanics of the skill inside of the state
state_stab:onStep(function(actor, data)
    -- Fix the horizontal speed of the survivor (maybe when it switches states?)
    actor:skill_util_fix_hspeed()
    
    -- Get the animation from the skill and set it for this state with a custom speed
    actor:actor_animation_set(actor:actor_get_skill_animation(skill_stab), 0.45)
    
    -- Check if we already fired and 
    -- if the animation is frame number is greater or equal to 10
    -- Used to fire only once per activation and at a specific frame
    if data.fired == 0 and actor.image_index >= 10.0 then

        -- Get the damage coeff from the skill
        local damage = actor:skill_get_damage(skill_stab)
        
        -- Check if the actor is the host (sometimes used if we only want the host to trigger it)
        -- (mostly for networked things)
        if actor:is_authority() then

            -- Check if we are not firing the heaven cracker
            if not actor:skill_util_update_heaven_cracker(actor, damage) then

                -- Get the shattered mirror buff
                local buff_shadow_clone = Buff.find("ror", "shadowClone")

                -- Fire an attack for each clone of the survivor (from shattered mirror)
                for i=0, GM.get_buff_stack(actor, buff_shadow_clone) do

                    -- Fire an explosion from the survivor
                    local attack = GM._mod_attack_fire_explosion(actor, actor.x + gm.cos(gm.degtorad(actor:skill_util_facing_direction())) * 25, actor.y, 60, 100, damage, -1, gm.constants.sSparks7)

                    -- You can also use actor:fire_explosion() but it returns a damager (attack-info) instead of an Attack object so I'm not using it for now
                    
                    -- Specify how many enemies should be hit by the explosion
                    attack.max_hit_number = 5

                    -- Offset the displayed damage number for each clone
                    attack.attack_info.climb = i * 8
                end
            end
        end

        -- Play a sound at the player's location
        -- (sound_id, volume, pitch)
        actor:sound_play(gm.constants.wClayShoot1, 1, 0.8 + math.random() * 0.2)

        -- Tell that we fired
        data.fired = 1
    end

    -- Auto exit the state when the animation is finished
    actor:skill_util_exit_state_on_anim_end()
end)







    --[[
        Subsection Secondary Skill 
    ]]--

    -- Setup the Secondary skill sprite, as well damage and cooldown properties
    skill_spikes:set_skill_icon(sprSkills, 1)
    skill_spikes:set_skill_properties(4, 8 * 60)

    -- Called when the player tries to use its Secondary skill
    skill_spikes:onActivate(function(actor, skill, index)
        GM.actor_set_state(actor, state_spikes)
    end)

    -- Reset the sprite animation to frame 0
    state_spikes:onEnter(function(actor, data)
        actor.image_index = 0
        data.spikes = 3
    end)
    
    -- Implement the actual mechanics of the skill
    state_spikes:onStep(function(actor, data)
        actor:skill_util_fix_hspeed()
        
        actor:actor_animation_set(actor:actor_get_skill_animation(skill_spikes.value), 0.35)

        if (data.spikes == 3 and actor.image_index >= 6.0) or (data.spikes == 2 and actor.image_index >= 10.0) or (data.spikes == 1 and (actor.image_index >= 14.0 or actor.image_index >= 13.9)) then
            local damage = actor:skill_get_damage(skill_spikes)
            
            if actor:is_authority() then
                if not actor:skill_util_update_heaven_cracker(actor, damage) then
                    local buff_shadow_clone = Buff.find("ror", "shadowClone")
                    for i=0, GM.get_buff_stack(actor, buff_shadow_clone) do
                        -- Calculate the offset from the player
                        local pos = (((actor.image_index - 2) / 4) * 60 + i * 20)

                        -- Create the spike
                        local attack = GM._mod_attack_fire_explosion(actor, actor.x + GM.cos(GM.degtorad(actor:skill_util_facing_direction())) * pos, actor.y, 80, 120, damage, sprJamSpike, sprSparksSpike)
                        attack.attack_info.climb = i * 8
                    end
                end
            end

            actor:sound_play(gm.constants.wBoss1Shoot1, 1, 1.2 + math.random() * 0.3)          
            data.spikes = data.spikes - 1  
        end
        
        actor:skill_util_exit_state_on_anim_end()
    end)





    --[[
        Subsection Utility Skill 
    ]]--

    -- Setup the Utility skill sprite, as well damage and cooldown properties
    skill_roll:set_skill_icon(sprSkills, 2)
    skill_roll:set_skill_properties(0, 4.5 * 60)

    -- Called when the player tries to use its utility skill
    skill_roll:onActivate(function(actor, skill, index)
        GM.actor_set_state(actor, state_roll)
    end)

    -- Reset the sprite animation to frame 0
    state_roll:onEnter(function(actor, data)
        actor.image_index = 0
        data.dodged = 0
    end)
    
    -- Implement the actual mechanics of the skill
    state_roll:onStep(function(actor, data)
        actor:skill_util_fix_hspeed()
        
        actor.sprite_index = actor:actor_get_skill_animation(skill_roll)
        actor.image_speed = 0.35

        if data.dodged == 0 and actor.image_index >= 4.0 then
            -- Ran on the last frame of the animation

            -- Reset the player's invincibility
            if actor.invincible <= 5 then
                actor.invincible = 0
            end
        else
            -- Ran all other frames of the animation
			
			-- Make the player invincible
			-- Only set the invincibility when below a certain value to make sure we don't override other invincibility effects
            if actor.invincible < 5 then 
                actor.invincible = 5
            end
            
            -- Set the player's horizontal speed
            actor.pHspeed = GM.cos(GM.degtorad(actor:skill_util_facing_direction())) * actor.pHmax * 4.8
        end
        
        actor:skill_util_exit_state_on_anim_end()
    end)














    --[[
        Subsection Special Skill 
    ]]--
    -- Setup the Primary skill sprite, as well damage and cooldown properties
    skill_raspberry:set_skill_icon(sprSkills, 3) 
    skill_raspberry:set_skill_properties(1, 15) -- 100% of base damage, 20 frames cooldown

    -- the onActivate callback is called when the player tries to use its primary skill
    skill_raspberry:onActivate(function(actor, skill, index)
        GM.actor_set_state(actor, state_raspberry)
    end)

    -- Reset the sprite animation to frame 0 when you enter the state
    state_raspberry:onEnter(function(actor, data)
        actor.image_index = 0
        data.fired = 0
    end)
    
-- Implement the actual mechanics of the skill inside of the state
state_raspberry:onStep(function(actor, data)
    -- Fix the horizontal speed of the survivor (maybe when it switches states?)
    actor:skill_util_fix_hspeed()
    
    -- Get the animation from the skill and set it for this state with a custom speed
    actor:actor_animation_set(actor:actor_get_skill_animation(skill_raspberry), 0.45)
    
    -- Check if we already fired and 
    -- if the animation is frame number is greater or equal to 10
    -- Used to fire only once per activation and at a specific frame
    if data.fired == 0 and actor.image_index >= 4.0 then

        -- Get the damage coeff from the skill
        local damage = actor:skill_get_damage(skill_raspberry)
        
        -- Check if the actor is the host (sometimes used if we only want the host to trigger it)
        -- (mostly for networked things)
        if actor:is_authority() then

            -- Check if we are not firing the heaven cracker
            if not actor:skill_util_update_heaven_cracker(actor, damage) then
                
                -- Get the shattered mirror buff
                local buff_shadow_clone = Buff.find("ror", "shadowClone")

                --1
                local function fire_special_attack(actor, buff_shadow_clone, damage)
                    -- Fire an attack for each clone of the survivor (from shattered mirror)
                    for i = 0, GM.get_buff_stack(actor, buff_shadow_clone) do
                        -- Fire an explosion from the survivor
                        local attack = GM._mod_attack_fire_explosion(
                            actor,
                            actor.x + gm.cos(gm.degtorad(actor:skill_util_facing_direction())) * 25,
                            actor.y,
                            100, -- explosion radius
                            140, -- explosion force
                            damage, -- damage amount
                            -1, -- unknown parameter, likely "team" or "type"
                            gm.constants.sSparks7 -- visual effect
                        )
            
                        -- Specify how many enemies should be hit by the explosion
                        attack.max_hit_number = 5
            
                        -- Offset the displayed damage number for each clone
                        attack.attack_info.climb = i * 8
            
                        -- Play a sound at the player's location
                        -- (sound_id, volume, pitch)
                        actor:sound_play(gm.constants.wClayShoot1, 1, 0.8 + math.random() * 0.2)
                    end
                end    
                -- не работае
                --Alarm.create(fire_special_attack, 20, actor, buff_shadow_clone, damage)

                -- работает и вызывает функ
                for j=0, 160 do
                     fire_special_attack(actor, buff_shadow_clone, damage) -- пример вызова функции
                end
            end
        end

        -- Tell that we fired
        data.fired = 1
    end

    -- Auto exit the state when the animation is finished
    actor:skill_util_exit_state_on_anim_end()
end)












    --[[
        Subsection Special Upgraded Skill 
    ]]--

    -- Setup the Special Upgrade skill sprite, as well damage and cooldown properties
    skill_raspberryScepter:set_skill_icon(sprSkills, 4)
    skill_raspberryScepter:set_skill_properties(8, 7 * 60)

    -- Called when the player tries to use its special upgrade skill
    skill_raspberryScepter:onActivate(function(actor, skill, index)
        GM.actor_set_state(actor, state_raspberryScepter)
    end)

    -- Reset the sprite animation to frame 0
    state_raspberryScepter:onEnter(function(actor, data)
        actor.image_index = 0
        data.spikes = 3
    end)
    
    -- Implement the actual mechanics of the skill
    state_raspberryScepter:onStep(function(actor, data)
        actor:skill_util_fix_hspeed()
        
        actor:actor_animation_set(actor:actor_get_skill_animation(skill_raspberryScepter), 0.25)

        if (data.spikes == 3 and actor.image_index >= 6.0) or (data.spikes == 2 and actor.image_index >= 10.0) or (data.spikes == 1 and (actor.image_index >= 14.0 or actor.image_index >= 13.9)) then
            local damage = actor:skill_get_damage(skill_raspberryScepter.damage)
            
            if actor:is_authority() then
                if not actor:skill_util_update_heaven_cracker(actor, damage) then
                    local buff_shadow_clone = Buff.find("ror", "shadowClone")
                    for i=0, GM.get_buff_stack(actor, buff_shadow_clone) do
                        -- Calculate the offset from the player
                        local pos = ((actor.image_index - 2) / 4) * 48 + i * 12

                        -- Create the spike
                        local attack1 = GM._mod_attack_fire_explosion(actor, actor.x + GM.cos(GM.degtorad(actor:skill_util_facing_direction())) * pos, actor.y, 80, 120, damage, sprJamSpike, sprSparksSpike)
                        local attack2 = GM._mod_attack_fire_explosion(actor, actor.x - GM.cos(GM.degtorad(actor:skill_util_facing_direction())) * pos, actor.y, 80, 120, damage, sprJamSpike, sprSparksSpike)
                        attack1.attack_info.climb = i * 8
                        attack2.attack_info.climb = i * 8
                    end
                end
            end

            -- Layer sound effects when scepter is active
            actor:sound_play(gm.constants.wGuardDeath, 0.6, 1.2 + math.random() * 0.3)            
            actor:sound_play(gm.constants.wBoss1Shoot1, 1, 1.2 + math.random() * 0.3)
            data.spikes = data.spikes - 1          
        end
        
        actor:skill_util_exit_state_on_anim_end()
    end)
end

-- use this code to hot_reload the mod
if hot_reloading then
    initialize()
else 
    Initialize(initialize)
end
hot_reloading = true