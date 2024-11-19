log.info("Successfully loaded ".._ENV["!guid"]..".")
mods["RoRRModdingToolkit-RoRR_Modding_Toolkit"].auto() -- Loading the toolkit 

local PATH = _ENV["!plugins_mod_folder_path"]
local NAMESPACE = "RMT"

local initialize = function()
    local gigachad = Survivor.new(NAMESPACE, "Gigachad") -- Create a survivor 

    --[[------------------------------------------
        SECTION SPRITES
    ------------------------------------------]]--
    
    -- Load all of our sprites into a table
    local sprites = {
        idle = Resources.sprite_load(NAMESPACE, "gigachad_idle", path.combine(PATH, "gigachad", "idle.png"), 7, 36, 52, 0.5),
        walk = Resources.sprite_load(NAMESPACE, "gigachad_walk", path.combine(PATH, "gigachad", "walk.png"), 10, 36, 52),
        jump = Resources.sprite_load(NAMESPACE, "gigachad_jump", path.combine(PATH, "gigachad", "jump.png"), 1, 36, 52),
        climb = Resources.sprite_load(NAMESPACE, "gigachad_climb", path.combine(PATH, "gigachad", "climb.png"), 3, 34.25, 52),
        death = Resources.sprite_load(NAMESPACE, "gigachad_death", path.combine(PATH, "gigachad", "death.png"), 11, 36, 52),
        
        -- This sprite is used by the Crudely Drawn Buddy
        -- If the player doesn't have one, the Commando's sprite will be used instead
        decoy = Resources.sprite_load(NAMESPACE, "gigachad_decoy", path.combine(PATH, "gigachad", "decoy.png"), 1, 18, 36),
    }
    
    -- Attack sprites are loaded separately as we'll be using them in our code
    local sprShoot1 = Resources.sprite_load(NAMESPACE, "gigachadshoot1", path.combine(PATH, "gigachad", "shoot1_1.png"), 17, 36, 52)
    local sprShoot1_2 = Resources.sprite_load(NAMESPACE, "gigachad_shoot1_2", path.combine(PATH, "gigachad", "shoot1_2.png"), 11, 36, 52)
    local sprShoot2 = Resources.sprite_load(NAMESPACE, "gigachad_shoot2", path.combine(PATH, "gigachad", "shoot2.png"), 12, 36, 52)
    local sprShoot3 = Resources.sprite_load(NAMESPACE, "gigachad_shoot3", path.combine(PATH, "gigachad", "shoot3.png"), 17, 36, 52)
    local sprShoot4 = Resources.sprite_load(NAMESPACE, "gigachad_shoot4", path.combine(PATH, "gigachad", "shoot4.png"), 41, 36, 52)
    
    -- The hit sprite used by our X skill
    local sprSparksGigachad= Resources.sprite_load(NAMESPACE, "gigachad_sparks1", path.combine(PATH, "gigachad", "bullet.png"), 4, 20, 16)
    
    -- The spikes creates by our V skill
    local sprGigachadSpike = Resources.sprite_load(NAMESPACE, "gigachad_spike", path.combine(PATH, "gigachad", "spike.png"), 20, 180, 80, 0.5, 2, 2, 9, 9)
    local sprSparksSpike = Resources.sprite_load(NAMESPACE, "gigachad_sparks2", path.combine(PATH, "gigachad", "hitspike.png"), 4, 16, 17)

    -- The sprite used by the skill icons
    local sprSkills = Resources.sprite_load(NAMESPACE, "gigachad_skills", path.combine(PATH, "gigachad", "skills.png"), 6, 0, 0)
    
    -- The rgb color of the character's skill names in the character select
    gigachad:set_primary_color(Color.from_rgb(115, 88, 85))
    
    -- The character's sprite in the selection pod
    gigachad.sprite_loadout = Resources.sprite_load(NAMESPACE, "sSelectGigachad", path.combine(PATH, "gigachad", "sSelectGigachad.png"), 4, 28, 0)

    -- The character's sprite portrait
    gigachad.sprite_portrait = Resources.sprite_load(NAMESPACE, "sGigachadPortrait", path.combine(PATH, "gigachad", "sGigachadPortrait.png"), 3)

    -- The character's sprite small portrait
    gigachad.sprite_portrait_small = Resources.sprite_load(NAMESPACE, "sGigachadPortraitSmall", path.combine(PATH, "gigachad", "sGigachadPortraitSmall.png"))
    
    -- The character's sprite logo portrait
    gigachad.sprite_portrait_logo = Resources.sprite_load(NAMESPACE, "sGigachadPortraitLogo", path.combine(PATH, "gigachad", "sGigachadPortraitLogo.png"))


    gigachad.sprite_title = sprites.walk -- The character's walk animation on the title screen when selected
    gigachad.sprite_idle = sprites.idle -- The character's idle animation
    gigachad.sprite_credits = sprites.idle -- The character's idle animation when beating the game

    gigachad:set_cape_offset(-1, -6, 0, -5) -- Set the Prophet cape offset for the player
    gigachad:set_animations(sprites) -- Set the player's sprites to those we previously loaded

    --[[------------------------------------------
        SECTION SURVIVOR LOG
    ------------------------------------------]]--

    --  create a new survivor log with the portrait sprite of the survivor as well as the log art
    local log = Survivor_Log.new(gigachad, gigachad.sprite_portrait, sprites.jump)

    -- All the log text is in the /elanguage/english.json and is loaded automatically

    --[[------------------------------------------
        SECTION STATS
    ------------------------------------------]]--

    gigachad:set_stats_base({ -- Set the player's starting stats
        maxhp = 115,
        damage = 13,
        regen = 0.0008 -- health regen per frame, so 0.6 per second
    })
    
    gigachad:set_stats_level({  -- Set the player's leveling stats
        maxhp = 40,
        damage = 3,
        regen = 0.0008, -- gain 0.12 health regen per level
        armor = 3
    })

    

    --[[------------------------------------------
        SECTION SKILLS
    ------------------------------------------]]--
    --[[
        Subsection Skill General Setups 
    ]]--
    
    -- Get the default survivor skills
    local skill_stab = gigachad:get_primary()
    local skill_seismic = gigachad:get_secondary()
    local skill_moment = gigachad:get_utility()
    local skill_starfury = gigachad:get_special()

    -- Create a new skill for the special skill upgrade
    local skill_cosmicradScepter = Skill.new(NAMESPACE, "gigachadVBoosted")
    skill_seismic:set_skill_upgrade(skill_cosmicradScepter)
    
    -- Set the animation for each skills
    skill_stab:set_skill_animation(sprShoot1)
    skill_seismic:set_skill_animation(sprShoot2)
    skill_moment:set_skill_animation(sprShoot3)
    skill_starfury:set_skill_animation(sprShoot4)
    skill_cosmicradScepter:set_skill_animation(sprShoot4)

    -- Create 1 State for every Skill
    local state_stab = State.new(NAMESPACE, skill_stab.identifier)
    local state_seismic = State.new(NAMESPACE, skill_seismic.identifier)
    local state_moment = State.new(NAMESPACE, skill_moment.identifier)
    local state_starfury = State.new(NAMESPACE, skill_starfury.identifier)
    local state_cosmicradScepter = State.new(NAMESPACE, skill_cosmicradScepter.identifier)

    --[[
        Subsection Primary Skill 
    ]]--

    -- Setup the Primary skill sprite, as well damage and cooldown properties
    skill_stab:set_skill_icon(sprSkills, 0) 
    skill_stab:set_skill_properties(2.5, 15) -- 250% of base damage, 15 frames cooldown

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
                    
                    --работае без проков
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
    skill_seismic:set_skill_icon(sprSkills, 1)
    skill_seismic:set_skill_properties(4, 8 * 60)

    -- Called when the player tries to use its Secondary skill
    skill_seismic:onActivate(function(actor, skill, index)
        GM.actor_set_state(actor, state_seismic)
    end)

    -- Reset the sprite animation to frame 0
    state_seismic:onEnter(function(actor, data)
        actor.image_index = 0
        data.spikes = 3
    end)
    
    -- Implement the actual mechanics of the skill
    state_seismic:onStep(function(actor, data)
        actor:skill_util_fix_hspeed()
        
        actor:actor_animation_set(actor:actor_get_skill_animation(skill_seismic.value), 0.35)

        if (data.spikes == 3 and actor.image_index >= 6.0) or (data.spikes == 2 and actor.image_index >= 10.0) or (data.spikes == 1 and (actor.image_index >= 14.0 or actor.image_index >= 13.9)) then
            local damage = actor:skill_get_damage(skill_seismic)
            
            if actor:is_authority() then
                if not actor:skill_util_update_heaven_cracker(actor, damage) then
                    local buff_shadow_clone = Buff.find("ror", "shadowClone")
                    for i=0, GM.get_buff_stack(actor, buff_shadow_clone) do
                        -- Calculate the offset from the player
                        local pos = (((actor.image_index - 2) / 4) * 60 + i * 20)

                        -- Create the spike
                        local attack = GM._mod_attack_fire_explosion(actor, actor.x + GM.cos(GM.degtorad(actor:skill_util_facing_direction())) * pos, actor.y, 80, 120, damage, sprGigachadSpike, sprSparksSpike)
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
    skill_moment:set_skill_icon(sprSkills, 2)
    skill_moment:set_skill_properties(0, 4.5 * 60)

    -- Called when the player tries to use its utility skill
    skill_moment:onActivate(function(actor, skill, index)
        GM.actor_set_state(actor, state_moment)
    end)

    -- Reset the sprite animation to frame 0
    state_moment:onEnter(function(actor, data)
        actor.image_index = 0
        data.dodged = 0
    end)
    
    -- Implement the actual mechanics of the skill
    state_moment:onStep(function(actor, data)
        actor:skill_util_fix_hspeed()
        
        actor.sprite_index = actor:actor_get_skill_animation(skill_moment)
        actor.image_speed = 0.35

        if data.dodged == 0 and actor.image_index >= 6.0 then
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
    skill_starfury:set_skill_icon(sprSkills, 3) 
    skill_starfury:set_skill_properties(0.2, 9*60)

    -- the onActivate callback is called when the player tries to use its primary skill
    skill_starfury:onActivate(function(actor, skill, index)
        GM.actor_set_state(actor, state_starfury)
    end)

    -- Reset the sprite animation to frame 0 when you enter the state
    state_starfury:onEnter(function(actor, data)
        actor.image_index = 0
        data.fired = 0
    end)
    
    -- Implement the actual mechanics of the skill inside of the state
    state_starfury:onStep(function(actor, data)
        -- Fix the horizontal speed of the survivor (maybe when it switches states?)
        actor:skill_util_fix_hspeed()
        
        -- Get the animation from the skill and set it for this state with a custom speed
        actor:actor_animation_set(actor:actor_get_skill_animation(skill_starfury), 0.45)

        -- Get the damage coeff from the skill
        local damage = actor:skill_get_damage(skill_starfury)
        
        -- Check if the actor is the host (sometimes used if we only want the host to trigger it)
        -- (mostly for networked things)
        if actor:is_authority() then
            
            -- Check if we are not firing the heaven cracker
            if not actor:skill_util_update_heaven_cracker(actor, damage) then
                
                -- Get the shattered mirror buff
                local buff_shadow_clone = Buff.find("ror", "shadowClone")
                
                local function fire_special_attack(actor, buff_shadow_clone, damage)
                    -- barrier
                    actor:add_barrier(damage*1.7)

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
                        actor:sound_play(gm.constants.wClayShoot1, 0.6, 0.8 + math.random() * 0.2)
                    end
                end   
                    fire_special_attack(actor, buff_shadow_clone, damage) -- пример вызова функци
                end
            end

        -- Auto exit the state when the animation is finished
        actor:skill_util_exit_state_on_anim_end()
    end)











    --[[
        Subsection Special Upgraded Skill 
    ]]--
    -- Setup the Primary skill sprite, as well damage and cooldown properties
    skill_cosmicradScepter:set_skill_icon(sprSkills, 4) 
    skill_cosmicradScepter:set_skill_properties(0.31, 9*60)

    -- the onActivate callback is called when the player tries to use its primary skill
    skill_cosmicradScepter:onActivate(function(actor, skill, index)
        GM.actor_set_state(actor, state_cosmicradScepter)
    end)

    -- Reset the sprite animation to frame 0 when you enter the state
    state_cosmicradScepter:onEnter(function(actor, data)
        actor.image_index = 0
        data.fired = 0
    end)
    
    -- Implement the actual mechanics of the skill inside of the state
    state_cosmicradScepter:onStep(function(actor, data)
        -- Fix the horizontal speed of the survivor (maybe when it switches states?)
        actor:skill_util_fix_hspeed()
        
        -- Get the animation from the skill and set it for this state with a custom speed
        actor:actor_animation_set(actor:actor_get_skill_animation(skill_cosmicradScepter), 0.45)

        -- Get the damage coeff from the skill
        local damage = actor:skill_get_damage(skill_cosmicradScepter)
        
        -- Check if the actor is the host (sometimes used if we only want the host to trigger it)
        -- (mostly for networked things)
        if actor:is_authority() then
            
            -- Check if we are not firing the heaven cracker
            if not actor:skill_util_update_heaven_cracker(actor, damage) then
                
                -- Get the shattered mirror buff
                local buff_shadow_clone = Buff.find("ror", "shadowClone")
                
                local function fire_special_attack(actor, buff_shadow_clone, damage)
                    -- invincible
                    actor.invincible = 5

                    -- Fire an attack for each clone of the survivor (from shattered mirror)
                    for i = 0, GM.get_buff_stack(actor, buff_shadow_clone) do
                        -- Fire an explosion from the survivor
                        local attack = GM._mod_attack_fire_explosion(
                            actor,
                            actor.x + gm.cos(gm.degtorad(actor:skill_util_facing_direction())) * 25,
                            actor.y,
                            140, -- explosion radius
                            180, -- explosion force
                            damage, -- damage amount
                            -1, -- unknown parameter, likely "team" or "type"
                            gm.constants.sSparks7 -- visual effect
                        )
            
                        -- Specify how many enemies should be hit by the explosion
                        attack.max_hit_number = 10
            
                        -- Offset the displayed damage number for each clone
                        attack.attack_info.climb = i * 8
            
                        -- Play a sound at the player's location
                        -- (sound_id, volume, pitch)
                        actor:sound_play(gm.constants.wClayShoot1, 0.6, 0.8 + math.random() * 0.2)
                    end
                end   
                    fire_special_attack(actor, buff_shadow_clone, damage) -- пример вызова функци
                end
            end

        -- Auto exit the state when the animation is finished
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