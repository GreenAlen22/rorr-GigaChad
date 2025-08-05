-- Логгируем загрузку мода по его GUID
log.info("Загрузка мода: " .. _ENV["!guid"] .. ".")
-- Получаем ссылку на модуль LuaENVY и активируем его
local envy = mods["LuaENVY-ENVY"]
envy.auto()
-- Активируем моддинг тулкит с автоматической инициализацией
mods["RoRRModdingToolkit-RoRR_Modding_Toolkit"].auto(true)
-- Путь к папке плагина и неймспейс мода
local PATH = _ENV["!plugins_mod_folder_path"]
local NAMESPACE = "GreenAlen22"
-- ========== Основная инициализация ==========
-- Функция инициализации мода
local initialize = function()
    -- Создаём нового персонажа (Survivor) с уникальным именем и ID
    local gigachad = Survivor.new(NAMESPACE, "Gigachad")


------------------------------------------------------------------------ === SPRITES ===----------------------------------------------------------------------
    -- Загружаем все основные спрайты персонажа в таблицу
    local sprites = {
        idle   = Resources.sprite_load(NAMESPACE, "gigachad_idle", path.combine(PATH, "gigachad", "idle.png"), 7, 36, 52, 0.5), -- Ожидание
        walk   = Resources.sprite_load(NAMESPACE, "gigachad_walk", path.combine(PATH, "gigachad", "walk.png"), 10, 36, 52),     -- Ходьба
        jump   = Resources.sprite_load(NAMESPACE, "gigachad_jump", path.combine(PATH, "gigachad", "jump.png"), 1, 36, 52),     -- Прыжок
        climb  = Resources.sprite_load(NAMESPACE, "gigachad_climb", path.combine(PATH, "gigachad", "climb.png"), 3, 34.25, 52),-- Лазание
        death  = Resources.sprite_load(NAMESPACE, "gigachad_death", path.combine(PATH, "gigachad", "death.png"), 11, 36, 52),  -- Смерть
        -- Этот спрайт используется для "Crudely Drawn Buddy"
        decoy = Resources.sprite_load(NAMESPACE, "gigachad_decoy", path.combine(PATH, "gigachad", "decoy.png"), 1, 55, 50),
        -- Спрайты дрона
        drone_idle  = Resources.sprite_load(NAMESPACE, "gigachad_drone_idle", path.combine(PATH, "gigachad", "drone_idle.png"), 5, 11, 15),
        drone_shoot = Resources.sprite_load(NAMESPACE, "gigachad_drone_shoot", path.combine(PATH, "gigachad", "drone_shoot.png"), 5, 25, 15)
    }

-- Спрайты для атак загружаются отдельно, т.к. они используются непосредственно в коде навыков
    local sprShoot1     = Resources.sprite_load(NAMESPACE, "gigachadshoot1", path.combine(PATH, "gigachad", "shoot1_1.png"), 17, 36, 52)
    local sprShoot1_2   = Resources.sprite_load(NAMESPACE, "gigachad_shoot1_2", path.combine(PATH, "gigachad", "shoot1_2.png"), 11, 36, 52)
    local sprShoot2     = Resources.sprite_load(NAMESPACE, "gigachad_shoot2", path.combine(PATH, "gigachad", "shoot2.png"), 12, 36, 52)
    local sprShoot2_2   = Resources.sprite_load(NAMESPACE, "gigachad_shoot2_2", path.combine(PATH, "gigachad", "shoot2_2.png"), 12, 36, 52)
    local sprShoot3     = Resources.sprite_load(NAMESPACE, "gigachad_shoot3", path.combine(PATH, "gigachad", "shoot3.png"), 17, 36, 52)
    local sprShoot3_2   = Resources.sprite_load(NAMESPACE, "gigachad_shoot3_2", path.combine(PATH, "gigachad", "shoot3_2.png"), 4, 44, 60, 0.3)
    local sprShoot4     = Resources.sprite_load(NAMESPACE, "gigachad_shoot4", path.combine(PATH, "gigachad", "shoot4.png"), 41, 36, 52)
    local sprShoot4_2   = Resources.sprite_load(NAMESPACE, "gigachad_shoot4_2", path.combine(PATH, "gigachad", "shoot4_2.png"), 1, 5, 5)
-- Спрайт, используемый для иконок навыков
    local sprSkills = Resources.sprite_load(NAMESPACE, "gigachad_skills", path.combine(PATH, "gigachad", "skills.png"), 10, 0, 0)
-- Частицы
    local parGigachadSpike     = Resources.sprite_load(NAMESPACE, "gigachad_spike", path.combine(PATH, "gigachad", "par_spike.png"), 20, 180, 80, 0.5, 2, 2, 9, 9)
    local parSparksSpike       = Resources.sprite_load(NAMESPACE, "gigachad_sparks", path.combine(PATH, "gigachad", "par_hitspike.png"), 4, 16, 17)
    local parBigTrollFace      = Resources.sprite_load(NAMESPACE, "gigachad_big_trollface", path.combine(PATH, "gigachad", "par_big_trollface.png"), 22, 30, 68, 0.7)
    local parSmallTrollFace    = Resources.sprite_load(NAMESPACE, "gigachad_small_trollface", path.combine(PATH, "gigachad", "par_small_trollface.png"), 12, 17, 17, 0.7)
    local parJoJo              = Resources.sprite_load(NAMESPACE, "gigachad_jojo", path.combine(PATH, "gigachad", "par_jojo.png"), 1, 16, 16)
    local parExplosion         = Resources.sprite_load(NAMESPACE, "gigachad_sprite_explosion", path.combine(PATH, "gigachad", "par_explosion.png"), 9, 500, 600, 0.7)
    local parMegumin           = Resources.sprite_load(NAMESPACE, "gigachad_megumin", path.combine(PATH, "gigachad", "par_megumin.png"), 1, 14, 22)
    local buff_gigamusic       = Resources.sprite_load(NAMESPACE, "gigachadBuff_music", path.combine(PATH, "gigachad", "par_gigamusic.png"), 20, 16, 16)
-- Цвет текста умений в меню выбора персонажа
    gigachad:set_primary_color(Color.from_rgb(115, 88, 85))
-- Спрайт персонажа в капсуле выбора
    gigachad.sprite_loadout        = Resources.sprite_load(NAMESPACE, "sSelectGigachad", path.combine(PATH, "gigachad", "sSelectGigachad.png"), 4, 28, 0)
    gigachad.sprite_portrait       = Resources.sprite_load(NAMESPACE, "sGigachadPortrait", path.combine(PATH, "gigachad", "sGigachadPortrait.png"), 3)
    gigachad.sprite_portrait_small = Resources.sprite_load(NAMESPACE, "sGigachadPortraitSmall", path.combine(PATH, "gigachad", "sGigachadPortraitSmall.png"))
-- Смещение плаща (для визуального позиционирования)
    gigachad:set_cape_offset(-3, -36, 2, -35)
-- Привязка анимаций персонажа к загруженным спрайтам
    gigachad:set_animations(sprites)


------------------------------------------------------------------------ === SURVIVOR LOG DATA ===----------------------------------------------------------------------
-- Спрайт логотипа персонажа (портрет в журнале)
    local spr_log = Resources.sprite_load(NAMESPACE, "sGigachadPortraitLogo", path.combine(PATH, "gigachad", "sGigachadPortraitLogo.png"))
-- Привязка спрайтов персонажа к различным экранам игры
    gigachad.sprite_title   = sprites.walk -- Анимация ходьбы на титульном экране при выборе
    gigachad.sprite_idle    = sprites.idle -- Анимация ожидания персонажа (по умолчанию)
    gigachad.sprite_credits = sprites.idle -- Анимация ожидания в титрах после победы
-- Создаём лог (досье) персонажа с портретом и лог-артом
    local gigachad_log = Survivor_Log.new(gigachad, spr_log, sprites.walk)


------------------------------------------------------------------------ === SOUND DEFINITIONS ===----------------------------------------------------------------------
-- Загружаем все звуковые эффекты персонажа в переменные
    local sound_ora        = Resources.sfx_load(NAMESPACE, "gigachad_ora", path.combine(PATH, "sounds", "snd_ora.ogg"))                 -- Звук "ORA" (вероятно, отсылочка к JoJo)
    local sound_trollface  = Resources.sfx_load(NAMESPACE, "gigachad_trollface", path.combine(PATH, "sounds", "snd_trollface.ogg"))     -- Смех/звук троллфейса
    local sound_explosion  = Resources.sfx_load(NAMESPACE, "gigachad_explosion", path.combine(PATH, "sounds", "snd_skill_explosion.ogg"))-- Взрыв (навык или эффект)
    local sound_gigamusic  = Resources.sfx_load(NAMESPACE, "gigachad_gigamusic", path.combine(PATH, "sounds", "snd_gigamusic.ogg"))     -- Фоновая музыка или эффект "GIGA"


------------------------------------------------------------------------ === BASE AND LEVEL STATS ===----------------------------------------------------------------------
    -- Устанавливаем базовые (стартовые) характеристики персонажа
    gigachad:set_stats_base({
        maxhp  = 122,   -- Максимальное здоровье на первом уровне
        damage = 12,    -- Базовый урон
        regen  = 0.04   -- Восстановление здоровья в секунду
    })
    -- Устанавливаем характеристики, получаемые при каждом повышении уровня
    gigachad:set_stats_level({
        maxhp  = 44,    -- Прирост максимального здоровья
        damage = 3,     -- Прирост урона
        regen  = 0.009, -- Прирост восстановления здоровья
        armor  = 4      -- Прирост брони
    })


------------------------------------------------------------------------ === SKILL DEFINITIONS ===----------------------------------------------------------------------
    -- Получаем стандартные (основные) навыки персонажа
    local skill_stab     = gigachad:get_primary()   -- Основная атака (кнопка Z)
    local skill_seismic  = gigachad:get_secondary() -- Вторичный навык (кнопка X)
    local skill_moment   = gigachad:get_utility()   -- Утилитарный навык (кнопка C)
    local skill_starfury = gigachad:get_special()   -- Особый навык (кнопка V)
    -- Альтернативные версии навыков
    local skill_sparta     = Skill.new(NAMESPACE, "GigachadZ2")
    gigachad:add_primary(skill_sparta)
    local skill_trolling   = Skill.new(NAMESPACE, "GigachadX2")
    gigachad:add_secondary(skill_trolling)
    local skill_gigamusic  = Skill.new(NAMESPACE, "GigachadC2")
    gigachad:add_utility(skill_gigamusic)
    local skill_explosion  = Skill.new(NAMESPACE, "GigachadV2")
    gigachad:add_special(skill_explosion)
    -- Назначаем спрайты анимаций для стандартных навыков
    skill_stab:set_skill_animation(sprShoot1)
    skill_seismic:set_skill_animation(sprShoot2)
    skill_moment:set_skill_animation(sprShoot3)
    skill_starfury:set_skill_animation(sprShoot4)
    -- Назначаем спрайты для альтернативных навыков
    skill_sparta:set_skill_animation(sprShoot1_2)
    skill_trolling:set_skill_animation(sprShoot2_2)
    skill_gigamusic:set_skill_animation(sprShoot3_2)
    skill_explosion:set_skill_animation(sprShoot4_2)
    -- Создаём улучшенные версии специальных навыков (например, через Scepter)
    local skill_cosmicradScepter = Skill.new(NAMESPACE, "gigachadVBoosted")
    skill_starfury:set_skill_upgrade(skill_cosmicradScepter)
    skill_cosmicradScepter:set_skill_animation(sprShoot4)
    local skill_exuperosScepter = Skill.new(NAMESPACE, "gigachadV2Boosted")
    skill_explosion:set_skill_upgrade(skill_exuperosScepter)
    skill_exuperosScepter:set_skill_animation(sprShoot4_2)
    -- Создаём состояния (State) для каждой из способностей
    -- Стандартные
    local state_stab     = State.new(NAMESPACE, skill_stab.identifier)
    local state_seismic  = State.new(NAMESPACE, skill_seismic.identifier)
    local state_moment   = State.new(NAMESPACE, skill_moment.identifier)
    local state_starfury = State.new(NAMESPACE, skill_starfury.identifier)
    -- Альтернативные
    local state_sparta     = State.new(NAMESPACE, skill_sparta.identifier)
    local state_trolling   = State.new(NAMESPACE, skill_trolling.identifier)
    local state_gigamusic  = State.new(NAMESPACE, skill_gigamusic.identifier)
    local state_explosion  = State.new(NAMESPACE, skill_explosion.identifier)
    -- Усиленные
    local state_cosmicradScepter  = State.new(NAMESPACE, skill_cosmicradScepter.identifier)
    local state_exuperosScepter   = State.new(NAMESPACE, skill_exuperosScepter.identifier)


------------------------------------------------------------------ === Primary "Skill STAB" ===----------------------------------------------------------------------
    -- Настраиваем иконку, урон и перезарядку основного навыка
    skill_stab:set_skill_icon(sprSkills, 0)             -- Иконка с индексом 0 в спрайте навыков
    skill_stab:set_skill_properties(2, 10)              -- Урон: 200% от базового, перезарядка: 10 кадров
-- Колбэк активации навыка — вызывается, когда игрок нажимает кнопку удара (Z)
    skill_stab:onActivate(function(actor, skill, index)
        GM.actor_set_state(actor, state_stab)           -- Переводим игрока в состояние атаки
    end)
    -- Колбэк входа в состояние — вызывается при начале анимации атаки
    state_stab:onEnter(function(actor, data)
        actor.image_index = 0                           -- Устанавливаем анимацию на первый кадр
        data.fired = 0                                  -- Флаг, чтобы скилл сработал только один раз
    end)
-- Основная логика выполнения состояния (кадр за кадром)
    state_stab:onStep(function(actor, data)
        actor:skill_util_fix_hspeed()                   -- Сбросить горизонтальную скорость (предотвращает скольжение)
        actor:actor_animation_set(actor:actor_get_skill_animation(skill_stab), 0.45) -- Анимация атаки
        -- Проверка: если атака ещё не была выполнена и достигнут нужный кадр анимации
        if data.fired == 0 and actor.image_index >= 10.0 then
            local damage = actor:skill_get_damage(skill_stab) -- Получаем урон скилла
            if actor:is_authority() then -- Только хост инициирует атаку (важно в мультиплеере)
                -- Проверка на "heaven cracker"
                if not actor:skill_util_update_heaven_cracker(actor, damage) then
                    local buff_shadow_clone = Buff.find("ror", "shadowClone") -- Бафф зеркального клона
                    -- Запускаем взрыв для каждого клона (или 1 раз, если их нет)
                    for i = 0, GM.get_buff_stack(actor, buff_shadow_clone) do
                        local attack = actor:fire_explosion(
                            actor.x,
                            actor.y,
                            120, 100,                     -- Размеры области поражения
                            damage,                      -- Урон
                            nil,                         -- Спрайт атаки
                            gm.constants.sSparks7,       -- Партиклы при попадании
                            true                         -- Прок шанс 
                        )
                    end
                end
            end
            -- Эффекты при атаке
            actor:screen_shake(2)                                 -- Тряска экрана
            actor:sound_play(gm.constants.wClayShoot1, 1,        -- Звук выстрела
                            0.8 + math.random() * 0.2)
            data.fired = 1                                        -- Скилл больше не сработает до следующего нажатия
        end
        actor:skill_util_exit_state_on_anim_end() -- Автоматический выход из состояния по окончанию анимации
    end)


------------------------------------------------------------------ === Secondary "Skill SEISMIC" ===----------------------------------------------------------------------
    -- Настройка вторичного навыка (X): иконка и свойства
    skill_seismic:set_skill_icon(sprSkills, 1)             -- Использует иконку №1 из спрайта
    skill_seismic:set_skill_properties(2.2, 8 * 60)        -- Урон 220%, перезарядка — 8 секунд
    -- Колбэк активации — при нажатии игроком на кнопку X
    skill_seismic:onActivate(function(actor, skill, index)
        GM.actor_set_state(actor, state_seismic)
    end)
    -- Вход в состояние: сброс анимации, установка количества "шипов"
    state_seismic:onEnter(function(actor, data)
        actor.image_index = 0
        data.spikes = 3 -- Кол-во ударов в рамках одного навыка
    end)
    -- Основная логика выполнения навыка (внутри состояния)
    state_seismic:onStep(function(actor, data)
        actor:skill_util_fix_hspeed()
        actor:actor_animation_set(actor:actor_get_skill_animation(skill_seismic.value), 0.35)
        -- Определяем три момента во время анимации, когда создаются взрывы
        if (data.spikes == 3 and actor.image_index >= 6.0)
        or (data.spikes == 2 and actor.image_index >= 10.0)
        or (data.spikes == 1 and (actor.image_index >= 14.0 or actor.image_index >= 13.9)) then
            local damage = actor:skill_get_damage(skill_seismic)
            if actor:is_authority() then
                -- Проверка на эффект "heaven cracker"
                if not actor:skill_util_update_heaven_cracker(actor, damage) then
                    local buff_shadow_clone = Buff.find("ror", "shadowClone")
                    for i = 0, GM.get_buff_stack(actor, buff_shadow_clone) do
                        -- Первый удар: основной взрыв вперёд
                        actor:fire_explosion(
                            actor.x + gm.cos(gm.degtorad(actor:skill_util_facing_direction())) * 95, -- смещение вперёд
                            actor.y,
                            220, 120,               -- Размер взрыва
                            damage,
                            parGigachadSpike,       -- Спрайт взрыва (шип)
                            parSparksSpike,         -- Партиклы попадания
                            true
                        )
                    end
                end
            end
            actor:screen_shake(2)
            actor:sound_play(gm.constants.wBoss1Shoot1, 1, 1.2 + math.random() * 0.3)
            data.spikes = data.spikes - 1 -- Уменьшаем счётчик оставшихся ударов
            -- Дополнительный короткий взрыв с меньшим радиусом за персонажем
            if not actor:skill_util_update_heaven_cracker(actor, damage) then
                local buff_shadow_clone = Buff.find("ror", "shadowClone")
                for i = 0, GM.get_buff_stack(actor, buff_shadow_clone) do
                    actor:fire_explosion(
                        actor.x + gm.cos(gm.degtorad(actor:skill_util_facing_direction())) * -10, -- смещение назад
                        actor.y,
                        80, 100, -- Меньше по размеру
                        damage,
                        nil,     -- Без кастомного спрайта
                        nil,
                        true
                    )
                end
            end
        end
        -- Выход из состояния после завершения анимации
        actor:skill_util_exit_state_on_anim_end()
    end)


------------------------------------------------------------------ === Utility "Skill MOMENT" ===----------------------------------------------------------------------
    -- Настройка утилитарного навыка (C)
    skill_moment:set_skill_icon(sprSkills, 2)           -- Использует иконку №2
    skill_moment:set_skill_properties(1, 5 * 60)        -- Урон: 100%, перезарядка — 5 секунд
    -- Колбэк при активации (нажатии кнопки C)
    skill_moment:onActivate(function(actor, skill, index)
        GM.actor_set_state(actor, state_moment)
    end)
    -- Вход в состояние: определяем направление рывка
    state_moment:onEnter(function(actor, data)
        actor.image_index = 0
        actor.shiftedfrom = actor.y -- Сохраняем начальную позицию по вертикали
        -- Определяем направление рывка в зависимости от нажатой клавиши
        if actor:control("left", 0) then
            data.direction = -1
        elseif actor:control("right", 0) then
            data.direction = 1
        else
            data.direction = GM.cos(GM.degtorad(actor:skill_util_facing_direction()))
        end
        -- Отражаем спрайт персонажа, если направление меняется
        if data.direction ~= GM.cos(GM.degtorad(actor:skill_util_facing_direction())) then
            actor.image_xscale = -actor.image_xscale
        end
    end)
    -- Основная логика рывка
    state_moment:onStep(function(actor, data)
        actor:skill_util_fix_hspeed()
        local animation = actor:actor_get_skill_animation(skill_moment)
        local animation_speed = 1
        -- Масштабируем скорость анимации в зависимости от скорости атаки
        if actor.attack_speed > 0 then
            animation_speed = animation_speed / actor.attack_speed
        end
        actor:actor_animation_set(animation, animation_speed)
        local direction = data.direction or 1
        local buff_shadow_clone = Buff.find("ror", "shadowClone")
        -- Кратковременная неуязвимость
        if actor.invincible < 10 then 
            actor.invincible = 10
        end
        -- Движение вперёд с усиленным горизонтальным импульсом
        actor.pHspeed = direction * actor.pHmax * 4 * math.min(actor.attack_speed, 1.5)
        actor.pVspeed = 0
        actor.y = actor.shiftedfrom -- Удерживаем высоту (без подъёма/спуска)
        -- Создаём шлейфовый эффект
        local trail = GM.instance_create(actor.x, actor.y, gm.constants.oEfTrail)
        trail.sprite_index = sprShoot3
        trail.image_index = actor.image_index - 1
        trail.image_xscale = direction
        trail.image_alpha = actor.image_alpha - 0.25
        trail.depth = actor.depth + 1
        -- Выход из состояния при завершении анимации
        actor:skill_util_exit_state_on_anim_end()
    end)
    -- Завершение рывка
    state_moment:onExit(function(actor, data)
        if actor.invincible <= 10 then
            actor.invincible = 0 -- Снимаем неуязвимость
        end
        actor.pHspeed = 0        -- Останавливаем движение
        data.direction = nil
    end)


------------------------------------------------------------------ === Special "Skill STARFURY" ===----------------------------------------------------------------------
    -- Настройка специального навыка (V)
    skill_starfury:set_skill_icon(sprSkills, 3)           -- Использует иконку №3 из набора
    skill_starfury:set_skill_properties(0.2, 10 * 60)     -- Урон: 20%, перезарядка — 10 секунд
    -- Колбэк при активации навыка
    skill_starfury:onActivate(function(actor, skill, index)
        GM.actor_set_state(actor, state_starfury)
    end)
    -- Вход в состояние: сброс анимации, установка переменных, выдача неуязвимости
    state_starfury:onEnter(function(actor, data)
        actor.image_index = 0
        data.fired = 0          
        data.cooldown = 0        -- Кулдаун между ударами внутри навыка
        actor.invincible = 180   -- 3 секунды неуязвимости
    end)
    -- Логика выполнения многократных ударов
    state_starfury:onStep(function(actor, data)
        actor:skill_util_fix_hspeed()
        actor:actor_animation_set(actor:actor_get_skill_animation(skill_starfury), 0.45)
        local total_hits = 80 -- Общее количество ударов за время действия навыка
        -- Обновляем внутренний кулдаун между атаками
        if data.cooldown > 0 then
            data.cooldown = data.cooldown - 1
        end
        -- Выполняем атаку, если не достигнут предел и кулдаун прошёл
        if data.fired < total_hits and data.cooldown <= 0 then
            if actor:is_authority() then
                local damage = actor:skill_get_damage(skill_starfury)
                -- Проверка на heaven cracker
                if not actor:skill_util_update_heaven_cracker(actor, damage) then
                    local buff_shadow_clone = Buff.find("ror", "shadowClone")
                    for i = 0, GM.get_buff_stack(actor, buff_shadow_clone) do
                        local attack = actor:fire_explosion(
                            actor.x + gm.cos(gm.degtorad(actor:skill_util_facing_direction())) * 25, -- Смещение вперёд
                            actor.y,
                            120, 100,    -- Размеры зоны поражения
                            damage,
                            nil,
                            parJoJo,     -- Партикл/эффект JoJo
                            false        -- Не применять эффекты типа "on-hit"
                        )
                        actor:screen_shake(2)          -- Визуальный эффект
                        attack.max_hit_number = 20     -- Максимум попаданий по врагу
                        attack.attack_info.climb = i * 8
                        -- Воспроизводим звук ORA! каждые 10 ударов
                        if data.fired % 10 == 9 then
                            actor:sound_play(sound_ora, 1, 0.9 + math.random() * 0.2)
                        end
                    end
                end
            end
            data.fired = data.fired + 1      -- +1 к количеству ударов
            data.cooldown = 1               -- Минимальная задержка между ударами (1 кадр)
        end
        -- Завершение навыка после всех ударов
        if data.fired >= total_hits then
            actor:skill_util_exit_state_on_anim_end()
        end
    end)

    
------------------------------------------------------------------ === UPG Special "Skill COSMICRAD" ===----------------------------------------------------------------------
    -- Иконка и параметры скилла
    skill_cosmicradScepter:set_skill_icon(sprSkills, 4)              -- Иконка №4
    skill_cosmicradScepter:set_skill_properties(0.4, 10 * 60)        -- Урон: 40%, перезарядка: 10 секунд
    -- Активация навыка
    skill_cosmicradScepter:onActivate(function(actor, skill, index)
        GM.actor_set_state(actor, state_cosmicradScepter)
    end)
    -- Вход в состояние: сброс, подготовка, неуязвимость
    state_cosmicradScepter:onEnter(function(actor, data)
        actor.image_index = 0
        data.fired = 0
        data.cooldown = 0
        actor.invincible = 240 -- 4 секунды неуязвимости (увеличена по сравнению с базовой версией)
    end)
    -- Основная логика усиленного спама-удара
    state_cosmicradScepter:onStep(function(actor, data)
        actor:skill_util_fix_hspeed()
        actor:actor_animation_set(actor:actor_get_skill_animation(skill_cosmicradScepter), 0.45)
        local total_hits = 100 -- Больше ударов, чем в обычной версии (80 → 100)
        if data.cooldown > 0 then
            data.cooldown = data.cooldown - 1
        end
        if data.fired < total_hits and data.cooldown <= 0 then
            if actor:is_authority() then
                local damage = actor:skill_get_damage(skill_cosmicradScepter)

                if not actor:skill_util_update_heaven_cracker(actor, damage) then
                    local buff_shadow_clone = Buff.find("ror", "shadowClone")
                    for i = 0, GM.get_buff_stack(actor, buff_shadow_clone) do
                        local attack = actor:fire_explosion(
                            actor.x + gm.cos(gm.degtorad(actor:skill_util_facing_direction())) * 25,
                            actor.y,
                            240, 200,    -- Увеличенная зона поражения
                            damage,
                            nil,
                            parJoJo,     -- Визуальный эффект: партикл JoJo
                            false
                        )
                        actor:screen_shake(2)
                        attack.max_hit_number = 50               -- Больше попаданий по цели
                        attack.attack_info.climb = i * 8         -- Смещение по вертикали
                        -- Эффектный звук каждые 10 атак
                        if data.fired % 10 == 9 then
                            actor:sound_play(sound_ora, 1, 0.9 + math.random() * 0.2)
                        end
                    end
                end
            end

            data.fired = data.fired + 1 -- +1 к количеству ударов
            data.cooldown = 1          -- Минимальная задержка между атаками 1 кадр
        end
        -- Выход из состояния после завершения всей серии ударов
        if data.fired >= total_hits then
            actor:skill_util_exit_state_on_anim_end()
        end
    end)


------------------------------------------------------------------ === ALT Primary "Skill SPARTA" ===----------------------------------------------------------------------
    -- Настройка альтернативного основного навыка (Z2)
    skill_sparta:set_skill_icon(sprSkills, 5)          -- Иконка №5 из набора
    skill_sparta:set_skill_properties(4, 40)           -- Урон: 400%, перезарядка: 40 кадров
    -- Активация навыка
    skill_sparta:onActivate(function(actor, skill, index)
        GM.actor_set_state(actor, state_sparta)
    end)
    -- Вход в состояние: сброс анимации и флага
    state_sparta:onEnter(function(actor, data)
        actor.image_index = 0
        data.fired = 0
    end)
    -- Основная логика удара
    state_sparta:onStep(function(actor, data)
        actor:skill_util_fix_hspeed()
        actor:actor_animation_set(actor:actor_get_skill_animation(skill_sparta), 0.20)
        -- Выполняем удар на 6 кадре анимации
        if data.fired == 0 and actor.image_index >= 6.0 then
            local damage = actor:skill_get_damage(skill_sparta)
            if actor:is_authority() then
                -- Проверка на heaven cracker
                if not actor:skill_util_update_heaven_cracker(actor, damage) then
                    local buff_shadow_clone = Buff.find("ror", "shadowClone")
                    -- Запускаем мощный взрыв от себя и всех клонов
                    for i = 0, GM.get_buff_stack(actor, buff_shadow_clone) do
                        actor:fire_explosion(
                            actor.x,
                            actor.y,
                            150, 100,      -- Широкая область поражения
                            damage,
                            nil,
                            nil,
                            true          -- Прок эффектов/крита
                        )
                    end
                end
            end
            actor:screen_shake(5) -- Усиленная тряска экрана
            actor:sound_play(gm.constants.wClayShoot1, 1, 0.8 + math.random() * 0.2)

            data.fired = 1
        end
        -- Завершаем состояние при окончании анимации
        actor:skill_util_exit_state_on_anim_end()
    end)


------------------------------------------------------------------ === ALT Secondary "Skill TROLLING" ===----------------------------------------------------------------------
    -- Создание объекта снаряда TrollFace
    local objTrollFace = Object.new(NAMESPACE, "gigachadTroll")
    objTrollFace.obj_sprite = parBigTrollFace
    -- Иконка и свойства навыка (альтернативный X)
    skill_trolling:set_skill_icon(sprSkills, 6)
    skill_trolling:set_skill_properties(1, 5 * 60) -- Урон: 100%, перезарядка: 5 секунды
    -- Активация навыка
    skill_trolling:onActivate(function(actor, skill, index)
        GM.actor_set_state(actor, state_trolling)
    end)
    -- Вход в состояние
    state_trolling:onEnter(function(actor, data)
        actor.image_index = 0
        data.fired = 0
    end)
    -- Поведение при активной фазе навыка
    state_trolling:onStep(function(actor, data)
        actor:skill_util_fix_hspeed()
        actor:actor_animation_set(actor:actor_get_skill_animation(skill_trolling.value), 0.35)
        -- Выпускаем снаряды на 4 кадре
        if actor.image_index >= 4 and data.fired == 0 then
            data.fired = 1
            local damage = actor:skill_get_damage(skill_trolling)
            local buff_shadow_clone = Buff.find("ror", "shadowClone")
            for i = 0, actor:buff_stack_count(buff_shadow_clone) do
                local trollF = objTrollFace:create(actor.x - i * 12 * actor.image_xscale, actor.y)
                trollF.parent = actor
                trollF.team = actor.team
                trollF.direction = actor:skill_util_facing_direction()
                trollF.image_xscale = actor.image_xscale
                trollF.depth = trollF.depth + i
                actor:sound_play(sound_trollface, 1, 0.9 + math.random() * 0.2)
                -- Атака с руки в упор
                actor:fire_explosion(
                    actor.x, 
                    actor.y,
                    150, 
                    100,
                    damage,
                    nil, 
                    nil,
                    true
                )
            end
            actor:screen_shake(2)
        end
        actor:skill_util_exit_state_on_anim_end()
    end)
    -- Очистка всех колбэков объекта (на случай переопределений)
    objTrollFace:clear_callbacks()
    -- Инициализация TrollFace
    objTrollFace:onCreate(function(inst)
        inst.image_speed = 0.25
        inst.speed = 1.5                  -- Скорость полёта
        inst.parent = -4                  -- Привязка к персонажу (может быть ID или объект)
        local data = inst:get_data()
        data.hit_list = {}               -- ID врагов, по которым уже нанесён урон
        data.lifetime = 160              -- Время жизни в кадрах 
    end)
    -- Поведение TrollFace каждый кадр
    objTrollFace:onStep(function(inst)
        if not Instance.exists(inst.parent) then
            inst:destroy()
            return
        end
        local data = inst:get_data()
        -- Движение вперёд
        inst.x = inst.x + gm.cos(gm.degtorad(inst.direction)) * inst.speed
        data.lifetime = data.lifetime - 1
        if data.lifetime < 0 then
            inst:destroy()
            return
        end
        -- Эффект шлейфа каждые 8 кадров
        if data.lifetime % 8 == 0 then
            local trail = GM.instance_create(inst.x, inst.y, gm.constants.oEfTrail)
            trail.sprite_index = inst.sprite_index
            trail.image_index = inst.image_index
            trail.image_xscale = inst.image_xscale
            trail.image_yscale = inst.image_yscale
            trail.depth = inst.depth + 1
        end
        -- Визуальное сжатие троллфейса ближе к исчезновению
        local scale = math.min(1, data.lifetime / 40)
        inst.image_yscale = scale
        -- Проверка столкновений с врагами
        local actors = inst:get_collisions(gm.constants.pActorCollisionBase)
        for _, actor in ipairs(actors) do
            if inst:attack_collision_canhit(actor) and not data.hit_list[actor.id] then
                if gm._mod_net_isHost() then
                    local base_damage = 4
                    local multiplier = math.random() * 1.5 + 0.5 -- 0.5x - 2.0x урон
                    inst.parent:fire_direct(actor, base_damage * multiplier, inst.direction, inst.x, inst.y, parSmallTrollFace)
                end

                actor:sound_play(sound_trollface, 0.5, 0.9 + math.random() * 0.2)
                data.hit_list[actor.id] = true
            end
        end
    end)


------------------------------------------------------------------ === ALT Utility "Skill GIGAMUSIC" ===----------------------------------------------------------------------
    -- Настройка альтернативного утилитарного навыка (C2)
    skill_gigamusic:set_skill_icon(sprSkills, 7)
    skill_gigamusic:set_skill_properties(0, 20 * 60) -- Нет урона, перезарядка 20 сек
    -- Объект визуального эффекта (иконка музыки над головой)
    local objEfGigamusic = Object.new(NAMESPACE, "EfGigamusic")
    objEfGigamusic.obj_sprite = buff_gigamusic
    -- Логика визуального объекта (не взаимодействует с врагами)
    objEfGigamusic:clear_callbacks()
    objEfGigamusic:onStep(function(inst)
        if inst.life then
            inst.life = inst.life - 1
            if inst.life <= 0 then inst:destroy() return end
        end
        if not Instance.exists(inst.parent) then
            inst:destroy()
            return
        end
        inst.x = inst.parent.x
        inst.y = inst.parent.y - 100
        inst.depth = inst.parent.depth - 1
    end)
    -- Активация навыка
    skill_gigamusic:onActivate(function(actor, skill, index)
        GM.actor_set_state(actor, state_gigamusic)
    end)
    -- Вход в состояние применяем бафф, запускаем звук и эффект
    state_gigamusic:onEnter(function(actor, data)
        actor.image_index = 0
        -- Применение баффа гигамузик
        actor:buff_apply(Buff.find("gigachad", "gigamusic"), 8 * 60, 1)
        -- Звук музыки
        gm.audio_play_sound(sound_gigamusic, 1, false)
        -- Визуальный эффект над персонажем
        local fx = objEfGigamusic:create(actor.x, actor.y)
        fx.parent = actor
        fx.image_speed = 0.1
        fx.life = 8 * 60
    end)
    -- Анимация и выход
    state_gigamusic:onStep(function(actor, data)
        actor:skill_util_fix_hspeed()
        actor:actor_animation_set(actor:actor_get_skill_animation(skill_gigamusic), 0.25)
        actor:skill_util_exit_state_on_anim_end()
    end)
    -- Бафф гигамузик
    local buff = Buff.new("gigachad", "gigamusic")
    buff.show_icon = false    
    buff.icon_stack_subimage = false
    buff.max_stack = 1
    buff.is_timed = false             
    buff.is_debuff = false
    -- При применении
    buff:onApply(function(actor, stack)
        local actorData = actor:get_data("gigamusic")
        if not actorData.timers then actorData.timers = {} end
        table.insert(actorData.timers, 8 * 60.0)
        actor.image_blend = Color(0x666666) -- Затемнение при активном баффе
    end)
    -- При каждом шаге
    buff:onPostStep(function(actor, stack)
        local actorData = actor:get_data("gigamusic") or {}
        if actorData.timers then
            for i = #actorData.timers, 1, -1 do
                actorData.timers[i] = actorData.timers[i] - 1
                if actorData.timers[i] <= 0 then
                    table.remove(actorData.timers, i)
                end
            end
        end
        -- Снимаем лишние стаки, если таймеров меньше
        local diff = stack - #(actorData.timers or {})
        if diff > 0 then
            actor:buff_remove(buff, diff)
            actor:recalculate_stats()
        end
    end)
    -- При снятии баффа — возвращаем цвет
    buff:onRemove(function(actor, stacks_removed)
        actor.image_blend = Color(0xFFFFFF)
    end)
    -- Изменения статов
    buff:onStatRecalc(function(actor, stack)
        actor.pHmax = actor.pHmax * 1.4         -- +40% к скорости передвижения
        actor.attack_speed = actor.attack_speed * 1.6 -- +60% к скорости атаки
    end)


------------------------------------------------------------------ === ALT Special "Skill EXPLOSION" ===----------------------------------------------------------------------
    -- Настройка альтернативного специального навыка (V2)
    skill_explosion:set_skill_icon(sprSkills, 8)
    skill_explosion:set_skill_properties(4799, 120 * 60) -- Урон: 479900%, перезарядка: 2 минуты
    -- Активация навыка
    skill_explosion:onActivate(function(actor, skill, index)
        GM.actor_set_state(actor, state_explosion)
    end)
    -- Объект Megumin на месте использования способности 
    local objMegumin = Object.new(NAMESPACE, "gigachadMegumin")
    objMegumin.obj_sprite = parMegumin
    -- Вход в состояние: звук, эффект, инвиз, таймер
    state_explosion:onEnter(function(actor, data)
        actor:sound_play(sound_explosion, 1, 0.8 + math.random() * 0.2)
        actor.image_index = 0
        data.fired = false
        data.timer = 14 * 60           -- 14 секунд подготовки
        actor.invincible = 30 * 60     -- 20 секунд неуязвимости
        -- Появляется Megumin
        local megumin = GM.instance_create(actor.x, actor.y, objMegumin)
    end)
    -- Основная логика взрыва
    state_explosion:onStep(function(actor, data)
        actor:skill_util_fix_hspeed()
        actor:actor_animation_set(actor:actor_get_skill_animation(skill_explosion), 1)
        if data.timer > 0 then
            data.timer = data.timer - 1
        elseif not data.fired then
            if actor:is_authority() then
                local damage = actor:skill_get_damage(skill_explosion)
                -- Проверка на "heaven cracker"
                if not actor:skill_util_update_heaven_cracker(actor, damage) then
                    local buff_shadow_clone = Buff.find("ror", "shadowClone")
                    for i = 0, GM.get_buff_stack(actor, buff_shadow_clone) do
                        local attack = actor:fire_explosion(
                            actor.x,
                            actor.y,
                            1000000, 1000000,  -- Огромная зона (гарантированное попадание по всем)
                            damage,
                            parExplosion,     -- Партикл взрыва
                            nil,
                            true             -- Без проков
                        )
                        attack.attack_info.climb = i * 8
                    end
                end
            end
            actor:screen_shake(20) -- Эпичная тряска экрана
            actor:kill()           -- Самоубийство после взрыва
            data.fired = true
        end
    end)
    -- Megumin стоит на месте
    objMegumin:onStep(function(inst)
        inst.image_speed = 0
    end)


------------------------------------------------------------------ === UPG ALT Special "Skill EXUPEROS" ===----------------------------------------------------------------------
    -- Настройка усиленной альтернативной спецспособности (V2 Boosted)
    skill_exuperosScepter:set_skill_icon(sprSkills, 9)
    skill_exuperosScepter:set_skill_properties(4799, 120 * 60)
    -- Активация
    skill_exuperosScepter:onActivate(function(actor, skill, index)
        GM.actor_set_state(actor, state_exuperosScepter)
    end)
    -- Повторное определение Megumin
    local objMegumin = Object.new(NAMESPACE, "gigachadMegumin")
    objMegumin.obj_sprite = parMegumin
    -- Вход в состояние
    state_exuperosScepter:onEnter(function(actor, data)
        actor:sound_play(sound_explosion, 1, 0.8 + math.random() * 0.2)
        actor.image_index = 0
        data.fired = false
        data.timer = 14 * 60       -- Подготовка: 14 секунд
        actor.invincible = 20 * 60 -- Неуязвимость на время подготовки
        GM.instance_create(actor.x, actor.y, objMegumin)
    end)
    -- Логика взрыва
    state_exuperosScepter:onStep(function(actor, data)
        actor:skill_util_fix_hspeed()
        actor:actor_animation_set(actor:actor_get_skill_animation(skill_exuperosScepter), 1)
        if data.timer > 0 then
            data.timer = data.timer - 1
        elseif not data.fired then
            if actor:is_authority() then
                local damage = actor:skill_get_damage(skill_exuperosScepter)
                if not actor:skill_util_update_heaven_cracker(actor, damage) then
                    local buff_shadow_clone = Buff.find("ror", "shadowClone")
                    for i = 0, GM.get_buff_stack(actor, buff_shadow_clone) do
                        local attack = actor:fire_explosion(
                            actor.x, actor.y,
                            1000000, 1000000,
                            damage,
                            parExplosion,
                            nil,
                            false
                        )
                        attack.attack_info.climb = i * 8
                    end
                end
            end
            actor:screen_shake(20)
            actor.hp = actor.hp * 0.2 -- Оставляем 20% HP вместо смерти
            data.fired = true
            actor:skill_util_exit_state_on_anim_end()
        end
    end)
-- Поведение Megumin
objMegumin:onStep(function(inst)
    inst.image_speed = 0
end)


------------------------------------------------------------------ === END of initialize ===----------------------------------------------------------------------
end -- конец функции initialize

-- Поддержка горячей перезагрузки
if hot_reloading then
    initialize()
else
    Initialize(initialize)
end
hot_reloading = true