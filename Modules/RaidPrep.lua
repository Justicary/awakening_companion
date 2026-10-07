local ADDON, ns = ...

local RaidPrep = {}
ns.RaidPrep = RaidPrep

-- =========================================================================
-- ESPECIALIZACIONES Y ROLES POR CLASE (WoW Classic)
-- =========================================================================
local SPECS_BY_CLASS = {
    ["WARRIOR"] = {
        { key = "fury",       name = "Guerrero Furia",       role = "MELEE_DPS" },
        { key = "arms",       name = "Guerrero Armas",       role = "MELEE_DPS" },
        { key = "protection", name = "Guerrero Protección",  role = "TANK" },
    },
    ["PALADIN"] = {
        { key = "retribution", name = "Paladín Reprensión",  role = "MELEE_DPS" },
        { key = "protection",  name = "Paladín Protección",  role = "TANK" },
        { key = "holy",        name = "Paladín Sagrado",     role = "HEALER" },
    },
    ["HUNTER"] = {
        { key = "marksmanship", name = "Cazador Puntería",     role = "MELEE_DPS" },
        { key = "beastmastery", name = "Cazador Bestias",      role = "MELEE_DPS" },
        { key = "survival",     name = "Cazador Supervivencia", role = "MELEE_DPS" },
    },
    ["ROGUE"] = {
        { key = "combat",       name = "Pícaro Combate",     role = "MELEE_DPS" },
        { key = "assassination", name = "Pícaro Asesinato",   role = "MELEE_DPS" },
        { key = "subtlety",     name = "Pícaro Sutileza",    role = "MELEE_DPS" },
    },
    ["PRIEST"] = {
        { key = "shadow",     name = "Sacerdote Sombra",     role = "CASTER_DPS" },
        { key = "holy",       name = "Sacerdote Sagrado",    role = "HEALER" },
        { key = "discipline", name = "Sacerdote Disciplina", role = "HEALER" },
    },
    ["SHAMAN"] = {
        { key = "enhancement", name = "Chamán Mejora",       role = "MELEE_DPS" },
        { key = "elemental",   name = "Chamán Elemental",    role = "CASTER_DPS" },
        { key = "restoration", name = "Chamán Restauración", role = "HEALER" },
    },
    ["MAGE"] = {
        { key = "frost",  name = "Mago Escarcha", role = "CASTER_DPS" },
        { key = "fire",   name = "Mago Fuego",    role = "CASTER_DPS" },
        { key = "arcane", name = "Mago Arcano",   role = "CASTER_DPS" },
    },
    ["WARLOCK"] = {
        { key = "affliction",   name = "Brujo Aflicción",   role = "CASTER_DPS" },
        { key = "destruction",  name = "Brujo Destrucción",  role = "CASTER_DPS" },
        { key = "demonology",   name = "Brujo Demonología", role = "CASTER_DPS" },
    },
    ["DRUID"] = {
        { key = "feral_cat",  name = "Druida Feral Gato",     role = "MELEE_DPS" },
        { key = "feral_bear", name = "Druida Feral Oso",      role = "TANK" },
        { key = "balance",    name = "Druida Equilibrio",     role = "CASTER_DPS" },
        { key = "resto",      name = "Druida Restauración",   role = "HEALER" },
    },
}

-- =========================================================================
-- ESCALAS DE CONSUMIBLES BASADAS EN CAMELOT (WoW Forever / Classic Era)
-- =========================================================================
local CAMELOT_WATER_LADDER = {
    { minLevel = 55, id = 19300, name = "Agua de Cuna del Invierno embotellada", effect = "Restaura 2934 Maná en 30 s", minCount = 20, icon = "Interface\\Icons\\inv_drink_10", source = "Vendedores en Cuna del Invierno" },
    { minLevel = 45, id = 8766,  name = "Rocío de gloria matutina",              effect = "Restaura 2934 Maná en 30 s", minCount = 20, icon = "Interface\\Icons\\inv_drink_10", source = "Taberneros y vendedores" },
    { minLevel = 35, id = 1645,  name = "Zumo de baya lunar",                     effect = "Restaura 1992 Maná en 27 s", minCount = 20, icon = "Interface\\Icons\\inv_drink_09", source = "Taberneros y vendedores" },
    { minLevel = 25, id = 1708,  name = "Néctar dulce",                          effect = "Restaura 1344 Maná en 24 s", minCount = 20, icon = "Interface\\Icons\\inv_drink_08", source = "Taberneros y vendedores" },
    { minLevel = 15, id = 1205,  name = "Zumo de melón",                         effect = "Restaura 835 Maná en 21 s",  minCount = 15, icon = "Interface\\Icons\\inv_drink_07", source = "Taberneros y vendedores" },
    { minLevel = 5,  id = 1179,  name = "Leche fría",                            effect = "Restaura 435 Maná en 18 s",  minCount = 15, icon = "Interface\\Icons\\inv_drink_07", source = "Taberneros y vendedores" },
    { minLevel = 1,  id = 159,   name = "Agua refrescante",                      effect = "Restaura 150 Maná en 18 s",  minCount = 15, icon = "Interface\\Icons\\inv_drink_06", source = "Taberneros y vendedores" },
}

local CAMELOT_MANA_POTIONS = {
    { minLevel = 49, id = 13444, name = "Poción de maná excelente", effect = "+1350 a 2250 Maná", minCount = 8, icon = "Interface\\Icons\\inv_potion_76", quality = 2, source = "Alquimia (295) / Flor de ensueño" },
    { minLevel = 41, id = 13443, name = "Poción de maná superior",  effect = "+900 a 1500 Maná",  minCount = 8, icon = "Interface\\Icons\\inv_potion_76", quality = 2, source = "Alquimia (260) / Solea" },
    { minLevel = 31, id = 6149,  name = "Poción de maná mayor",     effect = "+700 a 900 Maná",   minCount = 8, icon = "Interface\\Icons\\inv_potion_76", quality = 1, source = "Alquimia (205) / Solea" },
    { minLevel = 22, id = 3827,  name = "Poción de maná",           effect = "+455 a 585 Maná",   minCount = 6, icon = "Interface\\Icons\\inv_potion_76", quality = 1, source = "Alquimia (160) / Corona real" },
    { minLevel = 14, id = 3385,  name = "Poción de maná inferior",  effect = "+280 a 360 Maná",   minCount = 6, icon = "Interface\\Icons\\inv_potion_76", quality = 1, source = "Alquimia (120) / Marregal" },
    { minLevel = 5,  id = 2455,  name = "Poción de maná menor",     effect = "+140 a 180 Maná",   minCount = 6, icon = "Interface\\Icons\\inv_potion_76", quality = 1, source = "Alquimia (25) / Hojaplata" },
}

local CAMELOT_HEALING_POTIONS = {
    { minLevel = 45, id = 13446, name = "Poción de sanación excelente", effect = "+1050 a 1750 Salud", minCount = 5, icon = "Interface\\Icons\\inv_potion_54", quality = 2, source = "Alquimia (275) / Mostacho dorado" },
    { minLevel = 35, id = 3928,  name = "Poción de sanación mayor",     effect = "+700 a 900 Salud",   minCount = 5, icon = "Interface\\Icons\\inv_potion_52", quality = 1, source = "Alquimia (230) / Solea" },
    { minLevel = 21, id = 1710,  name = "Poción de sanación superior",  effect = "+455 a 585 Salud",   minCount = 5, icon = "Interface\\Icons\\inv_potion_52", quality = 1, source = "Alquimia (175) / Corona real" },
    { minLevel = 12, id = 929,   name = "Poción de sanación",           effect = "+280 a 360 Salud",   minCount = 5, icon = "Interface\\Icons\\inv_potion_52", quality = 1, source = "Alquimia (110) / Brezoespina" },
    { minLevel = 3,  id = 858,   name = "Poción de sanación inferior",  effect = "+140 a 180 Salud",   minCount = 5, icon = "Interface\\Icons\\inv_potion_52", quality = 1, source = "Alquimia (1) / Vendedores" },
    { minLevel = 1,  id = 118,   name = "Poción de sanación menor",     effect = "+70 a 90 Salud",     minCount = 5, icon = "Interface\\Icons\\inv_potion_52", quality = 1, source = "Alquimia (1) / Vendedores" },
}

local CAMELOT_BANDAGES = {
    { minLevel = 55, id = 14530, name = "Venda de paño rúnico pesada", effect = "Sana 2000 Salud en 8 s", minCount = 10, icon = "Interface\\Icons\\inv_misc_bandage_12", quality = 1, source = "Primeros auxilios (290) / Paño rúnico" },
    { minLevel = 45, id = 14529, name = "Venda de paño rúnico",        effect = "Sana 1360 Salud en 8 s", minCount = 10, icon = "Interface\\Icons\\inv_misc_bandage_11", quality = 1, source = "Primeros auxilios (260) / Paño rúnico" },
    { minLevel = 35, id = 6451,  name = "Venda de seda pesada",        effect = "Sana 640 Salud en 8 s",  minCount = 10, icon = "Interface\\Icons\\inv_misc_bandage_01", quality = 1, source = "Primeros auxilios (180) / Paño de seda" },
    { minLevel = 20, id = 3531,  name = "Venda de lana pesada",        effect = "Sana 301 Salud en 8 s",  minCount = 10, icon = "Interface\\Icons\\inv_misc_bandage_19", quality = 1, source = "Primeros auxilios (115) / Paño de lana" },
    { minLevel = 1,  id = 2581,  name = "Venda de lino pesada",        effect = "Sana 114 Salud en 8 s",  minCount = 10, icon = "Interface\\Icons\\inv_misc_bandage_15", quality = 1, source = "Primeros auxilios (40) / Paño de lino" },
}

local CAMELOT_FOOD_HEALER = {
    { minLevel = 45, id = 13931, name = "Sopa de aleta de noche",         effect = "+8 Maná cada 5 s (10 min)",   minCount = 10, icon = "Interface\\Icons\\inv_misc_fish_14", tip = "Regeneración de maná activa mientras lanzas curaciones (Mp5 ininterrumpido).", source = "Cocina (250) / Pargo de noche" },
    { minLevel = 30, id = 25954, name = "Delicia de sabiola",             effect = "+7 Daño Hechizos (15 min) y +5% EXP", minCount = 10, icon = "Interface\\Icons\\inv_misc_fish_21", tip = "Mp5 constante durante el combate (+5% EXP por muertes).", source = "Cocina (175) / Sabiola superior" },
    { minLevel = 15, id = 21072, name = "Sabiola ahumada",                 effect = "+4 Daño Hechizos y +5% EXP", minCount = 10, icon = "Interface\\Icons\\inv_misc_fish_21", tip = "Daño con hechizos (+5% EXP por muertes).", source = "Cocina (80) / Sabiola cruda" },
    { minLevel = 5,  id = 2682,  name = "Pastel de cangrejo",              effect = "+3 Intelecto (15 min) y +5% EXP", minCount = 10, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Comida de Intelecto: +3 Intelecto y +5% de experiencia por muertes.", source = "Cocina (75) / Carne de reptador" },
    { minLevel = 1,  id = 2683,  name = "Pinza de cangrejo cocinada",       effect = "+2 Intelecto (15 min) y +5% EXP", minCount = 10, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Intelecto inicial y +5% de experiencia por muertes.", source = "Cocina (85) / Pinza de reptador" },
}

local CAMELOT_FOOD_CASTER = {
    { minLevel = 45, id = 18254, name = "Sorpresa tubérculo de runn tum", effect = "+10 Intelecto (10 min)",     minCount = 10, icon = "Interface\\Icons\\inv_misc_food_15", tip = "+150 Maná total y mayor probabilidad de golpe crítico con hechizos.", source = "Cocina (275) / La Masacre" },
    { minLevel = 30, id = 25954, name = "Delicia de sabiola",             effect = "+7 Daño Hechizos (15 min) y +5% EXP", minCount = 10, icon = "Interface\\Icons\\inv_misc_fish_21", tip = "Mp5 activo permanente y daño mágico (+5% EXP).", source = "Cocina (175) / Sabiola superior" },
    { minLevel = 10, id = 21072, name = "Sabiola ahumada",                 effect = "+4 Daño Hechizos y +5% EXP", minCount = 10, icon = "Interface\\Icons\\inv_misc_fish_21", tip = "Comida de Daño con hechizos y +5% EXP.", source = "Cocina (80) / Sabiola cruda" },
    { minLevel = 5,  id = 2682,  name = "Pastel de cangrejo",              effect = "+3 Intelecto (15 min) y +5% EXP", minCount = 10, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Comida de Intelecto: +3 Intelecto y +5% de experiencia.", source = "Cocina (75) / Carne de reptador" },
    { minLevel = 1,  id = 2683,  name = "Pinza de cangrejo cocinada",       effect = "+2 Intelecto (15 min) y +5% EXP", minCount = 10, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Intelecto inicial y +5% de experiencia por muertes.", source = "Cocina (85) / Pinza de reptador" },
}

local CAMELOT_FOOD_MELEE = {
    { minLevel = 55, id = 20452, name = "Empanadillas del desierto ahumadas", effect = "+20 Fuerza (15 min)",        minCount = 10, icon = "Interface\\Icons\\inv_misc_food_64", tip = "El buff alimentario de mayor fuerza de Classic.", source = "Cocina (285) / Gusanos de arena (Silithus)" },
    { minLevel = 45, id = 13928, name = "Calamar a la parrilla",          effect = "+10 Agilidad (10 min)",       minCount = 10, icon = "Interface\\Icons\\inv_misc_fish_13", tip = "El mejor consumible alimentario para daño físico y golpe crítico.", source = "Cocina (240) / Calamar de invierno" },
    { minLevel = 35, id = 20074, name = "Guiso pesado de crocolisco",      effect = "+12 Aguante (15 min) y +5% EXP", minCount = 10, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Aumento de aguante para sobrevivir pulls grandes (+5% EXP).", source = "Cocina (200) / Carne de crocolisco" },
    { minLevel = 15, id = 5479,  name = "Cola de lagarto crujiente",       effect = "+6 Agilidad (15 min) y +5% EXP", minCount = 10, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Comida de Agilidad: +6 Agilidad y +5% de experiencia por muertes.", source = "Cocina (100) / Cola de lagarto de hierba" },
    { minLevel = 5,  id = 2687,  name = "Costillas de cerdo secas",        effect = "+3 Fuerza (15 min) y +5% EXP", minCount = 10, icon = "Interface\\Icons\\inv_misc_food_14", tip = "Comida de Fuerza: +3 Fuerza para daño físico y +5% de experiencia por muertes.", source = "Cocina (80) / Costillas de jabalí" },
    { minLevel = 1,  id = 2680,  name = "Carne de jabalí asada",           effect = "+2 Fuerza (15 min) y +5% EXP", minCount = 10, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Comida de Fuerza: +2 Fuerza y +5% de experiencia por muertes.", source = "Cocina (1) / Trozo de carne de jabalí" },
}

local CAMELOT_FOOD_TANK = {
    { minLevel = 55, id = 21023, name = "Albóndigas de quimeroque",        effect = "+25 Aguante (15 min)",        minCount = 10, icon = "Interface\\Icons\\inv_misc_food_15", quality = 3, tip = "El mejor buff alimentario de tanque en todo WoW Classic.", source = "Cocina (300) / Lomo de quimeroque" },
    { minLevel = 45, id = 13935, name = "Salmón al horno",                 effect = "+14 Aguante (15 min)",        minCount = 10, icon = "Interface\\Icons\\inv_misc_fish_20", tip = "Gran aporte de salud para mitigar golpes contundentes.", source = "Cocina (275) / Salmón solescama" },
    { minLevel = 35, id = 20074, name = "Guiso pesado de crocolisco",      effect = "+12 Aguante (15 min) y +5% EXP", minCount = 10, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Aguante sustancial para tanquear mazmorras (+5% EXP).", source = "Cocina (200) / Carne de crocolisco" },
    { minLevel = 15, id = 3665,  name = "Tortilla curiosamente sabrosa",  effect = "+6 Aguante (15 min) y +5% EXP", minCount = 10, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Salud y supervivencia fuera de combate (+5% EXP).", source = "Cocina (130) / Huevos de rapaz" },
    { minLevel = 1,  id = 5525,  name = "Almeja hervida",                  effect = "+4 Aguante (15 min) y +5% EXP", minCount = 10, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Aumenta la salud base del tanque (+5% EXP).", source = "Cocina (50) / Carne de almeja" },
}

-- Matriz Universal de Alimentos WoW Forever / Camelot con Estadísticas para Ponderación de StatWeights
local ALL_CAMELOT_FOODS = {
    -- =========================================================================
    -- NIVEL 55-60+ (Endgame & Raids)
    -- =========================================================================
    { minLevel = 55, id = 21023, name = "Albóndigas de quimeroque",        stats = { STA = 25 }, effect = "+25 Aguante (15 min)",        minCount = 10, quality = 3, icon = "Interface\\Icons\\inv_misc_food_15", tip = "El mejor buff alimentario de tanque en todo WoW Classic.", source = "Cocina (300) / Lomo de quimeroque" },
    { minLevel = 55, id = 20452, name = "Empanadillas del desierto ahumadas", stats = { STR = 20 }, effect = "+20 Fuerza (15 min)",        minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_food_64", tip = "El buff de mayor fuerza de Classic, óptimo para clases físicas basadas en fuerza.", source = "Cocina (285) / Gusanos de arena (Silithus)" },

    -- =========================================================================
    -- NIVEL 45+ (Nivel Alto & Pre-Raid)
    -- =========================================================================
    { minLevel = 45, id = 13810, name = "Frutosol bendito",                stats = { STR = 10 }, effect = "+10 Fuerza (10 min)",        minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_food_11", tip = "Buff alimentario de fuerza para guerreros y paladines.", source = "Amanecer Argenta (Venerado) / Frutosol bendito" },
    { minLevel = 45, id = 13928, name = "Calamar a la parrilla",          stats = { AGI = 10 }, effect = "+10 Agilidad (10 min)",       minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_fish_13", tip = "El mejor consumible alimentario para clases de agilidad y golpe crítico.", source = "Cocina (240) / Calamar de invierno" },
    { minLevel = 45, id = 18254, name = "Sorpresa tubérculo de runn tum", stats = { INT = 10 }, effect = "+10 Intelecto (10 min)",     minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_food_15", tip = "+10 Intelecto para mayor reserva de maná y crítico mágico.", source = "Cocina (275) / La Masacre" },
    { minLevel = 45, id = 13931, name = "Sopa de aleta de noche",         stats = { MP5 = 8 },  effect = "+8 Maná cada 5 s (10 min)",   minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_fish_14", tip = "Regeneración ininterrumpida de maná (Mp5) mientras lanzas curaciones o hechizos.", source = "Cocina (250) / Pargo de noche" },
    { minLevel = 45, id = 13935, name = "Salmón al horno",                 stats = { STA = 14 }, effect = "+14 Aguante (15 min)",        minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_fish_20", tip = "Gran aporte de salud para mitigar golpes contundentes de jefes.", source = "Cocina (275) / Salmón solescama" },

    -- =========================================================================
    -- NIVEL 30-35+ (Leveleo Medio-Avanzado)
    -- =========================================================================
    { minLevel = 35, id = 20074, name = "Guiso pesado de crocolisco",      stats = { STA = 12 }, effect = "+12 Aguante (15 min) y +5% EXP",  minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Aumento de estadísticas para soportar daño sostenido (+5% EXP).", source = "Cocina (200) / Carne de crocolisco" },
    { minLevel = 30, id = 25954, name = "Delicia de sabiola",             stats = { SPELL_POWER = 7 }, effect = "+7 Daño Hechizos (15 min) y +5% EXP",   minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_fish_21", tip = "Mp5 constante durante el combate, acelera la recarga entre hechizos (+5% EXP).", source = "Cocina (175) / Sabiola superior" },

    -- =========================================================================
    -- NIVEL 25+ (Leveleo Intermedio)
    -- =========================================================================
    { minLevel = 25, id = 3728,  name = "Filete de león sabrozo",     stats = { AGI = 10 },  effect = "+10 Agilidad (15 min) y +5% EXP", minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Comida de Fuerza: +8 Fuerza y +5% de experiencia por muertes.", source = "Cocina (125) / Carne de león" },
    { minLevel = 25, id = 12210, name = "Raptor asado",                   stats = { INT = 5} ,  effect = "+5 Intelecto (15 min) y +5% EXP", minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Comida de Agilidad: +8 Agilidad y +5% de experiencia por muertes.", source = "Cocina (175) / Carne de raptor" },
    { minLevel = 25, id = 3400,  name = "Bisqué de tortuga reconfortante", stats = { INT = 8 },  effect = "+8 Intelecto (15 min) y +5% EXP", minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Comida de Intelecto: +8 Intelecto y +5% de experiencia por muertes.", source = "Cocina (175) / Carne de tortuga" },

    -- =========================================================================
    -- NIVEL 15+ (Leveleo Medio)
    -- =========================================================================
    { minLevel = 15, id = 3370,  name = "Filete de crocolisco",            stats = { STR = 6 },  effect = "+6 Fuerza (15 min) y +5% EXP", minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Comida de Fuerza: +6 Fuerza y +5% de experiencia por muertes.", source = "Cocina (80) / Carne de crocolisco" },
    { minLevel = 15, id = 5479,  name = "Cola de lagarto crujiente",       stats = { AGI = 6 },  effect = "+6 Agilidad (15 min) y +5% EXP", minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Comida de Agilidad: +6 Agilidad y +5% de experiencia por muertes.", source = "Cocina (100) / Cola de lagarto de hierba" },
    { minLevel = 15, id = 3665,  name = "Tortilla curiosamente sabrosa",  stats = { STA = 6 },  effect = "+6 Aguante (15 min) y +5% EXP", minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Salud y recuperación sostenida fuera de combate (+5% EXP).", source = "Cocina (130) / Huevos de rapaz" },

    -- =========================================================================
    -- NIVEL 5-10+ (Leveleo Inicial / Mazmorras Tempranas - WoW Forever)
    -- =========================================================================
    -- Strength Food (+Fuerza y +5% EXP)
    { minLevel = 5,  id = 2687,  name = "Costillas de cerdo secas",        stats = { STR = 3 },  effect = "+3 Fuerza (15 min) y +5% EXP", minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_food_14", tip = "Comida de Fuerza: +3 Fuerza para daño físico y +5% de experiencia por muertes.", source = "Cocina (80) / Costillas de jabalí" },
    { minLevel = 5,  id = 3726,  name = "Pechuga de oso",            stats = { STR = 3 },  effect = "+3 Fuerza (15 min) y +5% EXP", minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Comida de Fuerza: +3 Fuerza para daño físico y +5% de experiencia por muertes.", source = "Cocina (110) / Lomo de oso grande" },
    { minLevel = 5,  id = 3220,  name = "Morcilla",                        stats = { STR = 3 },  effect = "+3 Fuerza (15 min) y +5% EXP", minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Comida de Fuerza: +3 Fuerza y +5% de experiencia por muertes.", source = "Cocina (60) / Vísceras de jabalí y carne de oso" },
    { minLevel = 5,  id = 724,   name = "Pastel de hígado de dentosangre", stats = { STR = 3 },  effect = "+3 Fuerza (15 min) y +5% EXP", minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Comida de Fuerza: +3 Fuerza y +5% de experiencia por muertes.", source = "Cocina (50) / Hígado de dentosangre" },

    -- Agility Food (+Agilidad y +5% EXP)
    { minLevel = 5,  id = 2684,  name = "Filete de coyote",                stats = { AGI = 3 },  effect = "+3 Agilidad (15 min) y +5% EXP", minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Comida de Agilidad: +3 Agilidad y +5% de experiencia por muertes.", source = "Cocina (50) / Carne de coyote" },
    { minLevel = 10, id = 5472,  name = "Filete de frenesí",               stats = { AGI = 3 },  effect = "+3 Agilidad (15 min) y +5% EXP", minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_fish_15", tip = "Comida de Agilidad: +3 Agilidad y +5% de experiencia por muertes.", source = "Cocina (50) / Carne de frenesí" },

    -- Intellect Food (+Intelecto y +5% EXP)
    { minLevel = 10, id = 1082,  name = "Gulash de Crestagrana",           stats = { INT = 3 },  effect = "+3 Intelecto (15 min) y +5% EXP", minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Comida de Intelecto: +3 Intelecto para maná/crítico mágico y +5% de experiencia.", source = "Cocina (100) / Carne de araña y hocico" },
    { minLevel = 5,  id = 2682,  name = "Pastel de cangrejo",              stats = { INT = 3 },  effect = "+3 Intelecto (15 min) y +5% EXP", minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Comida de Intelecto: +3 Intelecto y +5% de experiencia por muertes.", source = "Cocina (75) / Carne de reptador" },

    -- Spell Damage Food (+Daño Mágico y +5% EXP)
    { minLevel = 10, id = 21072, name = "Sabiola ahumada",                 stats = { SPELL_POWER = 4 }, effect = "+4 Daño Hechizos y +5% EXP", minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_fish_21", tip = "Daño con hechizos y +5% de experiencia por muertes.", source = "Cocina (80) / Sabiola cruda / Vendedores en las capitales" },

    -- Attack Power Food (+Poder de Ataque y +5% EXP)
    { minLevel = 5,  id = 6289,  name = "Pargo boquilleno",                stats = { AP = 6 },   effect = "+6 Poder de Ataque (15 min) y +5% EXP", minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_fish_15", tip = "Comida de Poder de Ataque: +6 Poder de ataque y +5% de experiencia por muertes.", source = "Cocina (50) / Pargo boquilleno" },

    -- =========================================================================
    -- NIVEL 1+ (Rango Aprendiz - WoW Forever)
    -- =========================================================================
    -- Strength Food
    { minLevel = 1,  id = 2680,  name = "Carne de jabalí asada",           stats = { STR = 1 }, effect = "+1 Fuerza (15 min) y +5% EXP", minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Comida de Fuerza: +2 Fuerza y +5% de experiencia por muertes.", source = "Cocina (1) / Trozo de carne de jabalí" },

    -- Agility Food
    { minLevel = 1,  id = 2679,  name = "Carne de lobo especiada",         stats = { AGI = 1 }, effect = "+1 Agilidad (15 min) y +5% EXP", minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Comida de Agilidad: +2 Agilidad y +5% de experiencia por muertes.", source = "Cocina (10) / Carne de lobo fibrosa" },

    -- Intellect Food
    { minLevel = 1,  id = 2683,  name = "Pinza de cangrejo cocinada",       stats = { INT = 1 }, effect = "+1 Intelecto (15 min) y +5% EXP", minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Comida de Intelecto: +2 Intelecto y +5% de experiencia por muertes.", source = "Cocina (85) / Pinza de reptador" },

    -- Attack Power Food
    { minLevel = 1,  id = 6290,  name = "Pececillo brillante",             stats = { AP = 2 },  effect = "+2 Poder de Ataque (15 min) y +5% EXP", minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_fish_15", tip = "Comida de Poder de Ataque: +4 Poder de ataque y +5% de experiencia por muertes.", source = "Cocina (1) / Pececillo brillante crudo" },

    -- Stamina / Supervivencia
    { minLevel = 1,  id = 8604,  name = "Huevos con hierbas",                  stats = { STA = 1 },  effect = "+1 Aguante (15 min) y +5% EXP", minCount = 10, quality = 1, icon = "Interface\\Icons\\inv_misc_food_15", tip = "Salud y recuperación temprana (+5% EXP).", source = "Cocina (10) / Huevo pequeño" },
}

-- Reagentes de Clase provenientes de Camelot
local CAMELOT_CLASS_REAGENTS = {
    ["DRUID"] = {
        seeds = {
            { minLevel = 60, id = 17038, name = "Semilla de madera férrea", minCount = 5,  category = "Componente", effect = "Renacer (Rango 5)", tip = "Reagente obligatorio para resucitar aliados en combate con Renacer.", source = "Vendedores de suministros de druida", icon = "Interface\\Icons\\inv_misc_herb_ironwoodseed", quality = 1 },
            { minLevel = 50, id = 17037, name = "Semilla de carpe",         minCount = 5,  category = "Componente", effect = "Renacer (Rango 4)", tip = "Reagente obligatorio para resucitar aliados en combate con Renacer.", source = "Vendedores de suministros de druida", icon = "Interface\\Icons\\inv_misc_herb_hornbeamseed", quality = 1 },
            { minLevel = 40, id = 17036, name = "Semilla de fresno",        minCount = 5,  category = "Componente", effect = "Renacer (Rango 3)", tip = "Reagente obligatorio para resucitar aliados en combate con Renacer.", source = "Vendedores de suministros de druida", icon = "Interface\\Icons\\inv_misc_herb_ashwoodseed", quality = 1 },
            { minLevel = 30, id = 17035, name = "Semilla de Tuercespina",   minCount = 5,  category = "Componente", effect = "Renacer (Rango 2)", tip = "Reagente obligatorio para resucitar aliados en combate con Renacer.", source = "Vendedores de suministros de druida", icon = "Interface\\Icons\\inv_misc_herb_stranglethornseed", quality = 1 },
            { minLevel = 20, id = 17034, name = "Semilla de arce",          minCount = 5,  category = "Componente", effect = "Renacer (Rango 1)", tip = "Reagente obligatorio para resucitar aliados en combate con Renacer.", source = "Vendedores de suministros de druida", icon = "Interface\\Icons\\inv_misc_herb_mapleseed", quality = 1 },
        },
        wilds = {
            { minLevel = 60, id = 17026, name = "Raíz de espina salvaje",   minCount = 20, category = "Componente", effect = "Don de lo Salvaje (R2)", tip = "Reagente para aplicar Don de lo Salvaje a toda la banda.", source = "Vendedores de suministros de druida", icon = "Interface\\Icons\\inv_misc_root_01", quality = 1 },
            { minLevel = 50, id = 17021, name = "Bayas salvajes",           minCount = 10, category = "Componente", effect = "Don de lo Salvaje (R1)", tip = "Reagente para aplicar Don de lo Salvaje a todo el grupo.", source = "Vendedores de suministros de druida", icon = "Interface\\Icons\\inv_misc_herb_17", quality = 1 },
        },
    },
    ["PRIEST"] = {
        candles = {
            { minLevel = 60, id = 17029, name = "Vela sagrada",             minCount = 20, category = "Componente", effect = "Rezo de entereza (R2)",  tip = "Reagente para bendecir a toda la banda con Rezo de entereza y Protección sombras.", source = "Vendedores de suministros", icon = "Interface\\Icons\\inv_misc_candle_02", quality = 1 },
            { minLevel = 48, id = 17028, name = "Vela bendita",             minCount = 10, category = "Componente", effect = "Rezo de entereza (R1)",  tip = "Reagente para bendecir al grupo con Rezo de entereza.", source = "Vendedores de suministros", icon = "Interface\\Icons\\inv_misc_candle_01", quality = 1 },
        },
        feather = {
            { minLevel = 34, id = 17056, name = "Pluma ligera",             minCount = 5,  category = "Componente", effect = "Levitar",                tip = "Permite flotar sobre el agua y evitar daño de caída.", source = "Despojo de arpías / aves de presa", icon = "Interface\\Icons\\inv_feather_04", quality = 1 },
        },
    },
    ["MAGE"] = {
        teleport = {
            { minLevel = 40, id = 17032, name = "Runa de portales",         minCount = 5,  category = "Componente", effect = "Apertura de Portales",    tip = "Reagente para abrir portales de transporte para el grupo/banda.", source = "Vendedores de suministros de mago", icon = "Interface\\Icons\\inv_misc_rune_08", quality = 1 },
            { minLevel = 20, id = 17031, name = "Runa de teletransporte",   minCount = 5,  category = "Componente", effect = "Teletransporte propio",  tip = "Reagente para teletransportarte a las capitales.", source = "Vendedores de suministros de mago", icon = "Interface\\Icons\\inv_misc_rune_06", quality = 1 },
        },
        powder = {
            { minLevel = 56, id = 17020, name = "Polvo arcano",             minCount = 20, category = "Componente", effect = "Luminosidad arcana (Banda)", tip = "Reagente para aplicar Intelecto a todo el grupo o banda.", source = "Vendedores de suministros de mago", icon = "Interface\\Icons\\inv_misc_dust_01", quality = 1 },
        },
        feather = {
            { minLevel = 12, id = 17056, name = "Pluma ligera",             minCount = 5,  category = "Componente", effect = "Caída lenta",            tip = "Evita daño por caída durante exploraciones y mazmorras.", source = "Despojo de arpías / aves", icon = "Interface\\Icons\\inv_feather_04", quality = 1 },
        },
    },
    ["PALADIN"] = {
        kings = {
            { minLevel = 52, id = 21177, name = "Símbolo de reyes",         minCount = 20, category = "Componente", effect = "Bendiciones superiores",  tip = "Reagente para otorgar bendiciones grupales de 15 minutos en banda.", source = "Vendedores de suministros de paladín", icon = "Interface\\Icons\\inv_misc_symbolofkings_01", quality = 1 },
        },
        divinity = {
            { minLevel = 30, id = 17033, name = "Símbolo de divinidad",     minCount = 3,  category = "Componente", effect = "Intervención divina",    tip = "Reagente para salvar a un aliado del wipe mediante sacrificio.", source = "Vendedores de suministros", icon = "Interface\\Icons\\inv_misc_symbolofdivinity_01", quality = 1 },
        },
    },
    ["SHAMAN"] = {
        ankh = {
            { minLevel = 30, id = 17030, name = "Anj",                      minCount = 3,  category = "Componente", effect = "Reencarnación",          tip = "Permite resucitar inmediatamente tras morir en combate.", source = "Vendedores de suministros de chamán", icon = "Interface\\Icons\\inv_jewelry_talisman_06", quality = 1 },
        },
        water = {
            { minLevel = 28, id = 17058, name = "Aceite de pescado",        minCount = 5,  category = "Componente", effect = "Caminar sobre el agua",  tip = "Reagente para conceder paso firme sobre aguas.", source = "Despojo de múrlocs y criaturas acuáticas", icon = "Interface\\Icons\\inv_potion_14", quality = 1 },
            { minLevel = 22, id = 17057, name = "Escamas de pez brillante", minCount = 5,  category = "Componente", effect = "Respiración acuática",   tip = "Reagente para respirar bajo el agua indefinidamente.", source = "Despojo de peces y múrlocs", icon = "Interface\\Icons\\inv_misc_fish_02", quality = 1 },
        },
    },
    ["ROGUE"] = {
        tools = {
            { minLevel = 16, id = 5060,  name = "Herramientas de ladrón",    minCount = 1,  category = "Herramienta", effect = "Forzar cerraduras",     tip = "Ganzúas indispensables para abrir cofres cerrados y puertas.", source = "Vendedores de suministros de pícaro", icon = "Interface\\Icons\\inv_misc_gear_03", quality = 1 },
        },
        flash = {
            { minLevel = 22, id = 5140,  name = "Polvo de evaporación",      minCount = 10, category = "Componente", effect = "Esfumarse (Vanish)",     tip = "Reagente indispensable para reiniciar el combate con Esfumarse.", source = "Vendedores de suministros de veneno", icon = "Interface\\Icons\\inv_misc_dust_02", quality = 1 },
        },
        blind = {
            { minLevel = 34, id = 5530,  name = "Polvo cegador",             minCount = 10, category = "Componente", effect = "Cegar (Blind)",          tip = "Reagente obligatorio para usar la habilidad Cegar.", source = "Veneno artesanal / Flor de paz molida", icon = "Interface\\Icons\\inv_misc_dust_02", quality = 1 },
        },
    },
    ["WARLOCK"] = {
        shards = {
            { minLevel = 10, id = 6265,  name = "Fragmento de alma",         minCount = 10, category = "Componente", effect = "Invocaciones y piedras", tip = "Recurso vital extraído de enemigos con Drenar alma para invocar aliados y demonios.", source = "Habilidad Drenar alma en combate", icon = "Interface\\Icons\\inv_misc_gem_amethyst_02", quality = 1 },
        },
        infernal = {
            { minLevel = 50, id = 5565,  name = "Piedra infernal",           minCount = 2,  category = "Componente", effect = "Invocar Infernal",       tip = "Reagente para invocar a un Infernal de combate.", source = "Vendedores de suministros de brujo", icon = "Interface\\Icons\\inv_stone_03", quality = 1 },
        },
        doom = {
            { minLevel = 60, id = 16583, name = "Figurilla demoníaca",       minCount = 2,  category = "Componente", effect = "Ritual de fatalidad",    tip = "Componente obligatorio para invocar al Guardia apocalíptico.", source = "Vendedores de suministros de brujo", icon = "Interface\\Icons\\inv_misc_statue_02", quality = 1 },
        },
    },
}

-- =========================================================================
-- BASE DE DATOS MAESTRA DE CONSUMIBLES POR NIVEL Y ROL (WoW Classic)
-- =========================================================================
local CONSUMABLES_DB = {
    -- ---------------------------------------------------------------------
    -- TRAMO 1: NIVEL 1-19 (Leveleo Inicial y Primeras Mazmorras)
    -- ---------------------------------------------------------------------
    ["1-19"] = {
        name = "Nivel 1-19 · Leveleo Inicial y Mazmorras",
        short = "1-19 (Inicial)",
        isRaid = false,
        roles = {
            ["TANK"] = {
                { id = 858,  name = "Poción de sanación inferior", minCount = 5,  category = "Poción",       effect = "+140 a 180 Salud",             tip = "Supervivencia de emergencia para el tanque en mazmorras iniciales.", source = "Alquimia (1) / Vendedores de suministros", icon = "Interface\\Icons\\inv_potion_52", quality = 1 },
                { id = 2581, name = "Venda de lino pesada",         minCount = 10, category = "Primeros Aux.", effect = "Sana 114 Salud en 8 s",         tip = "Permite curarte rápidamente sin consumir maná ni interrumpir a tu sanador.", source = "Primeros auxilios (40) / Paño de lino", icon = "Interface\\Icons\\inv_misc_bandage_15", quality = 1 },
                { id = 5525, name = "Almeja hervida",               minCount = 10, category = "Comida (Buf)",  effect = "+4 Aguante (15 min) y +5% EXP", tip = "Aumenta tu salud máxima y +5% de experiencia por muertes.", source = "Cocina (50) / Carne de almeja", icon = "Interface\\Icons\\inv_misc_food_15", quality = 1 },
                { id = 2458, name = "Elixir de defensa menor",      minCount = 3,  category = "Elixir",       effect = "+50 Armadura durante 1 h",     tip = "Mitigación pasiva de daño físico contra ataques de monstruos.", source = "Alquimia (90) / Hierba de plata", icon = "Interface\\Icons\\inv_potion_24", quality = 1 },
                { id = 2863, name = "Piedra de afilar gruesa",      minCount = 2,  category = "Arma",         effect = "+3 Daño con arma (30 min)",   tip = "Aumenta la generación de amenaza con daño de ataques blancos.", source = "Herrería (65) / Piedra gruesa", icon = "Interface\\Icons\\inv_stone_sharpeningstone_02", quality = 1 },
            },
            ["MELEE_DPS"] = {
                { id = 858,  name = "Poción de sanación inferior", minCount = 5,  category = "Poción",       effect = "+140 a 180 Salud",             tip = "Recuperación de vida de emergencia al recibir agro.", source = "Alquimia (1) / Vendedores de suministros", icon = "Interface\\Icons\\inv_potion_52", quality = 1 },
                { id = 2581, name = "Venda de lino pesada",         minCount = 10, category = "Primeros Aux.", effect = "Sana 114 Salud en 8 s",         tip = "Cero downtime entre enemigos para optimizar velocidad de leveleo.", source = "Primeros auxilios (40) / Paño de lino", icon = "Interface\\Icons\\inv_misc_bandage_15", quality = 1 },
                { id = 2687, name = "Costillas de cerdo secas",     minCount = 10, category = "Comida (Buf)",  effect = "+3 Fuerza (15 min) y +5% EXP", tip = "+3 Fuerza para optimizar daño físico y +5% de experiencia por muertes.", source = "Cocina (80) / Costillas de jabalí", icon = "Interface\\Icons\\inv_misc_food_14", quality = 1 },
                { id = 2454, name = "Elixir de fuerza de león",     minCount = 3,  category = "Elixir",       effect = "+4 Fuerza durante 1 h",        tip = "Aumenta directamente tu poder de ataque cuerpo a cuerpo.", source = "Alquimia (1) / Flor de paz", icon = "Interface\\Icons\\inv_potion_43", quality = 1 },
                { id = 2863, name = "Piedra de afilar gruesa",      minCount = 2,  category = "Arma",         effect = "+3 Daño con arma (30 min)",   tip = "Acelera el tiempo de muerte de cada monstruo.", source = "Herrería (65) / Piedra gruesa", icon = "Interface\\Icons\\inv_stone_sharpeningstone_02", quality = 1 },
            },
            ["CASTER_DPS"] = {
                { id = 2455,  name = "Poción de maná menor",        minCount = 5,  category = "Poción",       effect = "+140 a 180 Maná",              tip = "Maná instantáneo en combate para rematar pulls complicados.", source = "Alquimia (25) / Hojaplata", icon = "Interface\\Icons\\inv_potion_76", quality = 1 },
                { id = 858,   name = "Poción de sanación inferior", minCount = 5,  category = "Poción",       effect = "+140 a 180 Salud",             tip = "Botón de pánico vital si los monstruos logran alcanzarte.", source = "Alquimia (1) / Vendedores de suministros", icon = "Interface\\Icons\\inv_potion_52", quality = 1 },
                { id = 2581,  name = "Venda de lino pesada",         minCount = 10, category = "Primeros Aux.", effect = "Sana 114 Salud en 8 s",         tip = "Ahorra maná curándote con vendas en lugar de hechizos de curación.", source = "Primeros auxilios (40) / Paño de lino", icon = "Interface\\Icons\\inv_misc_bandage_15", quality = 1 },
                { id = 21072, name = "Sabiola ahumada",             minCount = 10, category = "Comida (Buf)",  effect = "+4 Daño Hechizos y +5% EXP", tip = "Daño con hechizos y +5% de experiencia.", source = "Cocina (80) / Sabiola cruda", icon = "Interface\\Icons\\inv_misc_fish_21", quality = 1 },
                { id = 1205,  name = "Zumo de melón",               minCount = 15, category = "Bebida",       effect = "Restaura 835 Maná en 21 s",    tip = "Bebida indispensable para reducir el tiempo de descanso entre combates.", source = "Taberneros y vendedores de comida", icon = "Interface\\Icons\\inv_drink_07", quality = 1 },
                { id = 3383,  name = "Elixir de sabiduría",          minCount = 3,  category = "Elixir",       effect = "+6 Intelecto durante 1 h",     tip = "+90 de maná total y mayor probabilidad de crítico con hechizos.", source = "Alquimia (90) / Marregal", icon = "Interface\\Icons\\inv_potion_05", quality = 1 },
            },
            ["HEALER"] = {
                { id = 2455,  name = "Poción de maná menor",        minCount = 8,  category = "Poción",       effect = "+140 a 180 Maná",              tip = "Evita que el grupo muera si te quedas sin maná en mazmorras.", source = "Alquimia (25) / Hojaplata", icon = "Interface\\Icons\\inv_potion_76", quality = 1 },
                { id = 858,   name = "Poción de sanación inferior", minCount = 5,  category = "Poción",       effect = "+140 a 180 Salud",             tip = "Autocuración de emergencia sin consumir tu propio maná de sanar.", source = "Alquimia (1) / Vendedores de suministros", icon = "Interface\\Icons\\inv_potion_52", quality = 1 },
                { id = 2581,  name = "Venda de lino pesada",         minCount = 10, category = "Primeros Aux.", effect = "Sana 114 Salud en 8 s",         tip = "Herramienta secundaria para parchar aliados sin gastar maná.", source = "Primeros auxilios (40) / Paño de lino", icon = "Interface\\Icons\\inv_misc_bandage_15", quality = 1 },
                { id = 21072, name = "Sabiola ahumada",             minCount = 10, category = "Comida (Buf)",  effect = "+4 Daño Hechizos y +5% EXP", tip = "Daño con hechizos y +5% de experiencia por muertes.", source = "Cocina (80) / Sabiola cruda", icon = "Interface\\Icons\\inv_misc_fish_21", quality = 1 },
                { id = 1205,  name = "Zumo de melón",               minCount = 20, category = "Bebida",       effect = "Restaura 835 Maná en 21 s",    tip = "Debes tener agua óptima para beber inmediatamente tras cada pull.", source = "Taberneros y vendedores de comida", icon = "Interface\\Icons\\inv_drink_07", quality = 1 },
                { id = 3383,  name = "Elixir de sabiduría",          minCount = 3,  category = "Elixir",       effect = "+6 Intelecto durante 1 h",     tip = "Aumenta tu reserva máxima de maná para aguantar combates prolongados.", source = "Alquimia (90) / Marregal", icon = "Interface\\Icons\\inv_potion_05", quality = 1 },
            },
        },
    },

    -- ---------------------------------------------------------------------
    -- TRAMO 2: NIVEL 20-34 (Leveleo Medio y Mazmorras: BFD, SFK, Gnomeregan, SM)
    -- ---------------------------------------------------------------------
    ["20-34"] = {
        name = "Nivel 20-34 · Leveleo y Mazmorras Intermedias",
        short = "20-34 (Medio)",
        isRaid = false,
        roles = {
            ["TANK"] = {
                { id = 929,  name = "Poción de sanación",          minCount = 5,  category = "Poción",       effect = "+280 a 360 Salud",             tip = "Recuperación de vida inmediata en pulls peligrosos de mazmorra.", source = "Alquimia (110) / Brezoespina", icon = "Interface\\Icons\\inv_potion_52", quality = 1 },
                { id = 3531, name = "Venda de lana pesada",         minCount = 10, category = "Primeros Aux.", effect = "Sana 301 Salud en 8 s",         tip = "Cura rápida tras combates para mantener el ritmo del grupo.", source = "Primeros auxilios (115) / Paño de lana", icon = "Interface\\Icons\\inv_misc_bandage_19", quality = 1 },
                { id = 3665, name = "Tortilla curiosamente sabrosa", minCount = 10, category = "Comida (Buf)",  effect = "+6 Aguante (15 min) y +5% EXP", tip = "Buff continuo de estadísticas (+5% EXP) para soportar más daño.", source = "Cocina (130) / Huevos de rapaz", icon = "Interface\\Icons\\inv_misc_food_15", quality = 1 },
                { id = 3389, name = "Elixir de defensa",            minCount = 3,  category = "Elixir",       effect = "+150 Armadura durante 1 h",    tip = "Mitigación sólida indispensable para jefes de BFD y Monasterio.", source = "Alquimia (130) / Vid salvaje", icon = "Interface\\Icons\\inv_potion_24", quality = 1 },
                { id = 3828, name = "Poción de piel de piedra",     minCount = 3,  category = "Utilidad",     effect = "+1000 Armadura (2 min)",       tip = "Pico de defensa colosal para momentos de daño extremo o adds extras.", source = "Alquimia (165) / Mostacho de Khadgar", icon = "Interface\\Icons\\inv_potion_69", quality = 1 },
                { id = 2871, name = "Piedra de afilar pesada",      minCount = 2,  category = "Arma",         effect = "+4 Daño con arma (30 min)",   tip = "Aumento directo de amenaza física con ataques blancos y habilidades.", source = "Herrería (125) / Piedra pesada", icon = "Interface\\Icons\\inv_stone_sharpeningstone_03", quality = 1 },
            },
            ["MELEE_DPS"] = {
                { id = 929,  name = "Poción de sanación",          minCount = 5,  category = "Poción",       effect = "+280 a 360 Salud",             tip = "Botón de pánico esencial si el tanque pierde el control de un add.", source = "Alquimia (110) / Brezoespina", icon = "Interface\\Icons\\inv_potion_52", quality = 1 },
                { id = 3531, name = "Venda de lana pesada",        minCount = 10, category = "Primeros Aux.", effect = "Sana 301 Salud en 8 s",         tip = "Recuperación rápida sin downtime al hacer misiones en solitario.", source = "Primeros auxilios (115) / Paño de lana", icon = "Interface\\Icons\\inv_misc_bandage_19", quality = 1 },
                { id = 250074, name = "Pechuga de oso",            minCount = 10, category = "Comida",       effect = "+10 Fuerza (15 min) y +5% EXP", tip = "+10 Fuerza para optimizar poder de ataque físico y +5% de experiencia por muertes.", source = "Cocina (175) / Ashenvale Bear", icon = "Interface\\Icons\\inv_misc_food_15", quality = 1 },
                { id = 2685, name = "Costilla de cerdo suculenta", minCount = 10, category = "Comida",       effect = "+5 Fuerza (15 min) y +5% EXP", tip = "+5 Fuerza para optimizar poder de ataque físico y +5% de experiencia por muertes.", source = "Cocina (175) / Ashenvale Bear", icon = "Interface\\Icons\\inv_misc_food_15", quality = 1 },
                { id = 3825, name = "Elixir de agilidad menor",    minCount = 3,  category = "Elixir",       effect = "+8 Agilidad durante 1 h",       tip = "+Poder de ataque, esquive y probabilidad de crítico.", source = "Alquimia (140) / Estranguladora", icon = "Interface\\Icons\\inv_potion_93", quality = 1 },
                { id = 3388, name = "Elixir de sangre de ogro",    minCount = 3,  category = "Elixir",       effect = "+8 Fuerza durante 1 h",         tip = "+Poder de ataque para guerreros, paladines y ferales.", source = "Alquimia (125) / Raíz de tierra", icon = "Interface\\Icons\\inv_potion_20", quality = 1 },
                { id = 2871, name = "Piedra de afilar pesada",     minCount = 2,  category = "Arma",         effect = "+4 Daño con arma (30 min)",   tip = "Mejora el daño base de tu arma principal.", source = "Herrería (125) / Piedra pesada", icon = "Interface\\Icons\\inv_stone_sharpeningstone_03", quality = 1 },
            },
            ["CASTER_DPS"] = {
                { id = 3827,  name = "Poción de maná",              minCount = 6,  category = "Poción",       effect = "+455 a 585 Maná",              tip = "Maná indispensable en mazmorras para no frenar tu rotación de daño.", source = "Alquimia (160) / Corona real", icon = "Interface\\Icons\\inv_potion_76", quality = 1 },
                { id = 929,   name = "Poción de sanación",          minCount = 5,  category = "Poción",       effect = "+280 a 360 Salud",             tip = "Salud de emergencia para casters frágiles.", source = "Alquimia (110) / Brezoespina", icon = "Interface\\Icons\\inv_potion_52", quality = 1 },
                { id = 3531,  name = "Venda de lana pesada",        minCount = 10, category = "Primeros Aux.", effect = "Sana 301 Salud en 8 s",         tip = "Curación sin gastar maná.", source = "Primeros auxilios (115) / Paño de lana", icon = "Interface\\Icons\\inv_misc_bandage_19", quality = 1 },
                { id = 25954, name = "Delicia de sabiola",          minCount = 10, category = "Comida (Buf)",  effect = "+7 Daño Hechizos (15 min) y +5% EXP", tip = "Regeneración de maná y daño mágico (+5% EXP).", source = "Cocina (175) / Sabiola superior", icon = "Interface\\Icons\\inv_misc_fish_21", quality = 1 },
                { id = 1708,  name = "Néctar dulce",                minCount = 15, category = "Bebida",       effect = "Restaura 1344 Maná en 24 s",   tip = "Bebida óptima de nivel 25+ según la progresión oficial de Camelot.", source = "Taberneros y vendedores", icon = "Interface\\Icons\\inv_drink_08", quality = 1 },
                { id = 3383,  name = "Elixir de sabiduría",         minCount = 3,  category = "Elixir",       effect = "+6 Intelecto durante 1 h",     tip = "+90 de maná total y mayor probabilidad de crítico con hechizos.", source = "Alquimia (90) / Marregal", icon = "Interface\\Icons\\inv_potion_05", quality = 1 },
            },
            ["HEALER"] = {
                { id = 3827,  name = "Poción de maná",              minCount = 8,  category = "Poción",       effect = "+455 a 585 Maná",              tip = "Respaldo crítico de maná durante encuentros de jefes largos.", source = "Alquimia (160) / Corona real", icon = "Interface\\Icons\\inv_potion_76", quality = 1 },
                { id = 929,   name = "Poción de sanación",          minCount = 5,  category = "Poción",       effect = "+280 a 360 Salud",             tip = "Salud propia sin interrumpir los casteos sobre el tanque.", source = "Alquimia (110) / Brezoespina", icon = "Interface\\Icons\\inv_potion_52", quality = 1 },
                { id = 3531,  name = "Venda de lana pesada",        minCount = 10, category = "Primeros Aux.", effect = "Sana 301 Salud en 8 s",         tip = "Curación secundaria gratuita.", source = "Primeros auxilios (115) / Paño de lana", icon = "Interface\\Icons\\inv_misc_bandage_19", quality = 1 },
                { id = 12210, name = "Raptor asado",                minCount = 10, category = "Comida",       effect = "+5 Intelecto (15 min) y +5% EXP", tip = "Más intelecto para no quedar sin maná (+5% EXP).", source = "Cocina (175) / Carne de raptor / Vendedor Hammon Karwn(Arathi 46.4, 47.4)", icon = "Interface\\Icons\\inv_misc_fish_21", quality = 1 },
                { id = 1708,  name = "Néctar dulce",                minCount = 20, category = "Bebida",       effect = "Restaura 1344 Maná en 24 s",   tip = "Bebida óptima de nivel 25+ (o Zumo de melón a nivel 15).", source = "Taberneros y vendedores", icon = "Interface\\Icons\\inv_drink_08", quality = 1 },
                { id = 3383,  name = "Elixir de sabiduría",         minCount = 3,  category = "Elixir",       effect = "+6 Intelecto durante 1 h",     tip = "Aumenta la reserva de maná disponible en combates intensos.", source = "Alquimia (90) / Marregal", icon = "Interface\\Icons\\inv_potion_05", quality = 1 },
            },
        },
    },

    -- ---------------------------------------------------------------------
    -- TRAMO 3: NIVEL 35-49 (Leveleo Avanzado: RFD, Uldaman, ZF, Maraudon)
    -- ---------------------------------------------------------------------
    ["35-49"] = {
        name = "Nivel 35-49 · Leveleo Avanzado y Mazmorras",
        short = "35-49 (Avanzado)",
        isRaid = false,
        roles = {
            ["TANK"] = {
                { id = 3928,  name = "Poción de sanación mayor",   minCount = 5,  category = "Poción",       effect = "+700 a 900 Salud",             tip = "Gran inyección de salud en mazmorras como Zul'Farrak y Maraudon.", source = "Alquimia (230) / Solea", icon = "Interface\\Icons\\inv_potion_52", quality = 1 },
                { id = 6451,  name = "Venda de seda pesada",        minCount = 10, category = "Primeros Aux.", effect = "Sana 640 Salud en 8 s",         tip = "Sana una gran porción de vida en segundos.", source = "Primeros auxilios (180) / Paño de seda", icon = "Interface\\Icons\\inv_misc_bandage_01", quality = 1 },
                { id = 20074, name = "Guiso pesado de crocolisco",  minCount = 10, category = "Comida (Buf)",  effect = "+12 Aguante (15 min) y +5% EXP", tip = "Buff sustancial de salud (+5% EXP).", source = "Cocina (200) / Carne de crocolisco", icon = "Interface\\Icons\\inv_misc_food_15", quality = 1 },
                { id = 3826,  name = "Elixir de fortaleza",         minCount = 3,  category = "Elixir",       effect = "+120 Salud máxima (1 h)",      tip = "+1200 puntos de salud acumulables con otros elixires.", source = "Alquimia (175) / Espinela dorada", icon = "Interface\\Icons\\inv_potion_43", quality = 1 },
                { id = 3389,  name = "Elixir de defensa",           minCount = 3,  category = "Elixir",       effect = "+150 Armadura durante 1 h",    tip = "Mitigación básica obligatoria para tanquear mazmorras 40+.", source = "Alquimia (130) / Vid salvaje", icon = "Interface\\Icons\\inv_potion_24", quality = 1 },
                { id = 7964,  name = "Piedra de afilar sólida",     minCount = 2,  category = "Arma",         effect = "+6 Daño con arma (30 min)",   tip = "Aumento de DPS y generación de amenaza en área.", source = "Herrería (200) / Piedra sólida", icon = "Interface\\Icons\\inv_stone_sharpeningstone_04", quality = 1 },
            },
            ["MELEE_DPS"] = {
                { id = 3928,  name = "Poción de sanación mayor",   minCount = 5,  category = "Poción",       effect = "+700 a 900 Salud",             tip = "Salud de emergencia en combates difíciles de mundo abierto o mazmorra.", source = "Alquimia (230) / Solea", icon = "Interface\\Icons\\inv_potion_52", quality = 1 },
                { id = 6451,  name = "Venda de seda pesada",        minCount = 10, category = "Primeros Aux.", effect = "Sana 640 Salud en 8 s",         tip = "Recuperación veloz de vida entre pulls.", source = "Primeros auxilios (180) / Paño de seda", icon = "Interface\\Icons\\inv_misc_bandage_01", quality = 1 },
                { id = 20074, name = "Guiso pesado de crocolisco",  minCount = 10, category = "Comida (Buf)",  effect = "+12 Aguante (15 min) y +5% EXP", tip = "Buff de supervivencia (+5% EXP) para mitigar daño de área.", source = "Cocina (200) / Carne de crocolisco", icon = "Interface\\Icons\\inv_misc_food_15", quality = 1 },
                { id = 8949,  name = "Elixir de agilidad superior", minCount = 3,  category = "Elixir",       effect = "+15 Agilidad durante 1 h",     tip = "Aumenta notablemente el crítico y poder de ataque de pícaros, cazadores y ferales.", source = "Alquimia (210) / Mostacho de Khadgar", icon = "Interface\\Icons\\inv_potion_93", quality = 1 },
                { id = 3382,  name = "Elixir de fuerza de ogro",    minCount = 3,  category = "Elixir",       effect = "+15 Fuerza durante 1 h",       tip = "Poder de ataque contundente para guerreros y paladines.", source = "Alquimia (150) / Espinela dorada", icon = "Interface\\Icons\\inv_potion_20", quality = 1 },
                { id = 7964,  name = "Piedra de afilar sólida",     minCount = 2,  category = "Arma",         effect = "+6 Daño con arma (30 min)",   tip = "Aumenta el daño de tus ataques blancos.", source = "Herrería (200) / Piedra sólida", icon = "Interface\\Icons\\inv_stone_sharpeningstone_04", quality = 1 },
            },
            ["CASTER_DPS"] = {
                { id = 6149,  name = "Poción de maná mayor",        minCount = 6,  category = "Poción",       effect = "+700 a 900 Maná",              tip = "Recuperación de maná de combate para rematar élites y jefes.", source = "Alquimia (205) / Solea", icon = "Interface\\Icons\\inv_potion_76", quality = 1 },
                { id = 3928,  name = "Poción de sanación mayor",   minCount = 5,  category = "Poción",       effect = "+700 a 900 Salud",             tip = "Salud de emergencia.", source = "Alquimia (230) / Solea", icon = "Interface\\Icons\\inv_potion_52", quality = 1 },
                { id = 6451,  name = "Venda de seda pesada",        minCount = 10, category = "Primeros Aux.", effect = "Sana 640 Salud en 8 s",         tip = "Ahorra maná curándote con vendas.", source = "Primeros auxilios (180) / Paño de seda", icon = "Interface\\Icons\\inv_misc_bandage_01", quality = 1 },
                { id = 25954, name = "Delicia de sabiola",          minCount = 10, category = "Comida (Buf)",  effect = "+7 Daño Hechizos (15 min)",    tip = "Daño adicional al lanzar hechizos mágicos.", source = "Cocina (175) / Sabiola superior", icon = "Interface\\Icons\\inv_misc_fish_21", quality = 1 },
                { id = 1645,  name = "Zumo de baya lunar",          minCount = 15, category = "Bebida",       effect = "Restaura 1992 Maná en 27 s",   tip = "Bebida de nivel 35+ según la progresión de Camelot.", source = "Taberneros y vendedores", icon = "Interface\\Icons\\inv_drink_09", quality = 1 },
                { id = 9179,  name = "Elixir de intelecto mayor",   minCount = 3,  category = "Elixir",       effect = "+25 Intelecto durante 1 h",    tip = "+375 maná máximo y mayor crítico mágico.", source = "Alquimia (275) / Loto ciego", icon = "Interface\\Icons\\inv_potion_10", quality = 1 },
            },
            ["HEALER"] = {
                { id = 6149,  name = "Poción de maná mayor",        minCount = 8,  category = "Poción",       effect = "+700 a 900 Maná",              tip = "Maná indispensable durante combates prolongados en mazmorras.", source = "Alquimia (205) / Solea", icon = "Interface\\Icons\\inv_potion_76", quality = 1 },
                { id = 3928,  name = "Poción de sanación mayor",   minCount = 5,  category = "Poción",       effect = "+700 a 900 Salud",             tip = "Autodefensa rápida.", source = "Alquimia (230) / Solea", icon = "Interface\\Icons\\inv_potion_52", quality = 1 },
                { id = 6451,  name = "Venda de seda pesada",        minCount = 10, category = "Primeros Aux.", effect = "Sana 640 Salud en 8 s",         tip = "Soporte secundario gratuito.", source = "Primeros auxilios (180) / Paño de seda", icon = "Interface\\Icons\\inv_misc_bandage_01", quality = 1 },
                { id = 25954, name = "Delicia de sabiola",          minCount = 10, category = "Comida (Buf)",  effect = "+7 Daño Hechizos (15 min)",    tip = "Mp5 activo clave para no secarte en jefes largos.", source = "Cocina (175) / Sabiola superior", icon = "Interface\\Icons\\inv_misc_fish_21", quality = 1 },
                { id = 1645,  name = "Zumo de baya lunar",          minCount = 20, category = "Bebida",       effect = "Restaura 1992 Maná en 27 s",   tip = "Bebida óptima de nivel 35+ para recargar al grupo sin perder tiempo.", source = "Taberneros y vendedores", icon = "Interface\\Icons\\inv_drink_09", quality = 1 },
                { id = 3826,  name = "Elixir de fortaleza",         minCount = 3,  category = "Elixir",       effect = "+120 Salud máxima (1 h)",      tip = "Evita que un add errante te mate de un golpe.", source = "Alquimia (175) / Espinela dorada", icon = "Interface\\Icons\\inv_potion_43", quality = 1 },
            },
        },
    },

    -- ---------------------------------------------------------------------
    -- TRAMO 4: NIVEL 50-59 (Pre-Raid: BRD, LBRS, Stratholme, Scholomance)
    -- ---------------------------------------------------------------------
    ["50-59"] = {
        name = "Nivel 50-59 · Pre-Raid y Mazmorras de Nivel 60",
        short = "50-59 (Pre-Raid)",
        isRaid = false,
        roles = {
            ["TANK"] = {
                { id = 13446, name = "Poción de sanación excelente", minCount = 5,  category = "Poción",       effect = "+1050 a 1750 Salud",           tip = "Sanación masiva requerida para resistir jefes en BRD y Stratholme.", source = "Alquimia (275) / Mostacho dorado", icon = "Interface\\Icons\\inv_potion_54", quality = 2 },
                { id = 14529, name = "Venda de paño rúnico",        minCount = 10, category = "Primeros Aux.", effect = "Sana 1360 Salud en 8 s",        tip = "Recupera más de la mitad de tu barra de vida en segundos.", source = "Primeros auxilios (260) / Paño rúnico", icon = "Interface\\Icons\\inv_misc_bandage_11", quality = 1 },
                { id = 13935, name = "Salmón al horno",             minCount = 10, category = "Comida (Buf)",  effect = "+14 Aguante durante 15 min",   tip = "Buff alimentario de aguante superior para tanquear mazmorras 55+.", source = "Cocina (275) / Salmón solescama", icon = "Interface\\Icons\\inv_misc_fish_20", quality = 1 },
                { id = 13445, name = "Elixir de defensa superior",   minCount = 3,  category = "Elixir",       effect = "+450 Armadura durante 1 h",    tip = "+450 de armadura reduce notablemente el daño aplastante.", source = "Alquimia (265) / Piedraescama", icon = "Interface\\Icons\\inv_potion_24", quality = 2 },
                { id = 3826,  name = "Elixir de fortaleza",         minCount = 3,  category = "Elixir",       effect = "+120 Salud máxima (1 h)",      tip = "+1200 puntos de salud acumulables con otros elixires.", source = "Alquimia (175) / Espinela dorada", icon = "Interface\\Icons\\inv_potion_43", quality = 1 },
                { id = 12404, name = "Piedra de afilar densa",      minCount = 2,  category = "Arma",         effect = "+8 Daño con arma (30 min)",   tip = "Aumenta la amenaza y el daño de tus ataques blancos.", source = "Herrería (250) / Piedra densa", icon = "Interface\\Icons\\inv_stone_sharpeningstone_05", quality = 1 },
            },
            ["MELEE_DPS"] = {
                { id = 13446, name = "Poción de sanación excelente", minCount = 5,  category = "Poción",       effect = "+1050 a 1750 Salud",           tip = "Salud de emergencia al recibir daño en área o cleaves.", source = "Alquimia (275) / Mostacho dorado", icon = "Interface\\Icons\\inv_potion_54", quality = 2 },
                { id = 14529, name = "Venda de paño rúnico",        minCount = 10, category = "Primeros Aux.", effect = "Sana 1360 Salud en 8 s",        tip = "Curación sin coste de tiempo para el sanador.", source = "Primeros auxilios (260) / Paño rúnico", icon = "Interface\\Icons\\inv_misc_bandage_11", quality = 1 },
                { id = 13928, name = "Calamar a la parrilla",       minCount = 10, category = "Comida (Buf)",  effect = "+10 Agilidad durante 10 min",  tip = "El mejor consumible de cocina para daño físico y crítico.", source = "Cocina (240) / Calamar de invierno", icon = "Interface\\Icons\\inv_misc_fish_13", quality = 1 },
                { id = 13452, name = "Elixir del mangosta",         minCount = 3,  category = "Elixir",       effect = "+25 Agilidad y +2% Crítico",   tip = "Elixir rey de daño físico en Classic (acumulable con fuerza de gigantes).", source = "Alquimia (280) / Lágrimas de Arthas", icon = "Interface\\Icons\\inv_potion_93", quality = 2 },
                { id = 9206,  name = "Elixir de los gigantes",      minCount = 3,  category = "Elixir",       effect = "+25 Fuerza durante 1 h",       tip = "+50 poder de ataque para guerreros y ferales.", source = "Alquimia (245) / Loto ciego", icon = "Interface\\Icons\\inv_potion_61", quality = 2 },
                { id = 12404, name = "Piedra de afilar densa",      minCount = 2,  category = "Arma",         effect = "+8 Daño con arma (30 min)",   tip = "Aumento directo de DPS blanco.", source = "Herrería (250) / Piedra densa", icon = "Interface\\Icons\\inv_stone_sharpeningstone_05", quality = 1 },
            },
            ["CASTER_DPS"] = {
                { id = 13444, name = "Poción de maná excelente",     minCount = 6,  category = "Poción",       effect = "+1350 a 2250 Maná",            tip = "Recuperación de maná de combate en mazmorras de nivel 60.", source = "Alquimia (295) / Flor de ensueño", icon = "Interface\\Icons\\inv_potion_76", quality = 2 },
                { id = 13446, name = "Poción de sanación excelente", minCount = 5,  category = "Poción",       effect = "+1050 a 1750 Salud",           tip = "Salud de emergencia.", source = "Alquimia (275) / Mostacho dorado", icon = "Interface\\Icons\\inv_potion_54", quality = 2 },
                { id = 14529, name = "Venda de paño rúnico",        minCount = 10, category = "Primeros Aux.", effect = "Sana 1360 Salud en 8 s",        tip = "Curación sin quemar maná.", source = "Primeros auxilios (260) / Paño rúnico", icon = "Interface\\Icons\\inv_misc_bandage_11", quality = 1 },
                { id = 18254, name = "Sorpresa tubérculo de runn tum", minCount = 10, category = "Comida (Buf)", effect = "+10 Intelecto durante 10 min",  tip = "+150 Maná total y mayor crítico con hechizos mágicos.", source = "Cocina (275) / La Masacre", icon = "Interface\\Icons\\inv_misc_food_15", quality = 1 },
                { id = 8766,  name = "Rocío de gloria matutina",    minCount = 20, category = "Bebida",       effect = "Restaura 2934 Maná en 30 s",   tip = "Agua de nivel 45+ según la escalera de Camelot.", source = "Taberneros y vendedores", icon = "Interface\\Icons\\inv_drink_10", quality = 1 },
                { id = 9155,  name = "Elixir arcano",               minCount = 3,  category = "Elixir",       effect = "+20 Poder con hechizos (30m)", tip = "Aumenta el daño de todos tus hechizos mágicos.", source = "Alquimia (235) / Loto ciego", icon = "Interface\\Icons\\inv_potion_84", quality = 1 },
                { id = 9179,  name = "Elixir de intelecto mayor",   minCount = 3,  category = "Elixir",       effect = "+25 Intelecto durante 1 h",    tip = "+375 maná máximo y mayor crítico mágico.", source = "Alquimia (275) / Loto ciego", icon = "Interface\\Icons\\inv_potion_10", quality = 1 },
            },
            ["HEALER"] = {
                { id = 13444, name = "Poción de maná excelente",     minCount = 8,  category = "Poción",       effect = "+1350 a 2250 Maná",            tip = "Maná indispensable para mantener al grupo vivo en mazmorras 55+.", source = "Alquimia (295) / Flor de ensueño", icon = "Interface\\Icons\\inv_potion_76", quality = 2 },
                { id = 13446, name = "Poción de sanación excelente", minCount = 5,  category = "Poción",       effect = "+1050 a 1750 Salud",           tip = "Autocuración sin distraerte del tanque.", source = "Alquimia (275) / Mostacho dorado", icon = "Interface\\Icons\\inv_potion_54", quality = 2 },
                { id = 14529, name = "Venda de paño rúnico",        minCount = 10, category = "Primeros Aux.", effect = "Sana 1360 Salud en 8 s",        tip = "Curación secundaria gratuita.", source = "Primeros auxilios (260) / Paño rúnico", icon = "Interface\\Icons\\inv_misc_bandage_11", quality = 1 },
                { id = 13931, name = "Sopa de aleta de noche",      minCount = 10, category = "Comida (Buf)",  effect = "+8 Maná cada 5 s (10 min)",     tip = "Mp5 activo continuo para curar sin pausas.", source = "Cocina (250) / Pargo de noche", icon = "Interface\\Icons\\inv_misc_fish_14", quality = 1 },
                { id = 8766,  name = "Rocío de gloria matutina",    minCount = 20, category = "Bebida",       effect = "Restaura 2934 Maná en 30 s",   tip = "Bebida óptima de nivel 45+.", source = "Taberneros y vendedores", icon = "Interface\\Icons\\inv_drink_10", quality = 1 },
                { id = 13447, name = "Elixir de los sabios",        minCount = 3,  category = "Elixir",       effect = "+18 Intelecto y +18 Espíritu",  tip = "La mejor combinación de maná total y Mp5 para sanadores.", source = "Alquimia (270) / Flor de ensueño", icon = "Interface\\Icons\\inv_potion_29", quality = 2 },
            },
        },
    },

    -- ---------------------------------------------------------------------
    -- TRAMO 5: NIVEL 60 (Banda / Raid: Molten Core, Onyxia, Blackwing Lair)
    -- ---------------------------------------------------------------------
    ["60"] = {
        name = "Nivel 60 · Preparación de Banda (Raids de Nivel 60)",
        short = "60 (Raid)",
        isRaid = true,
        roles = {
            ["TANK"] = {
                { id = 13510, name = "Frasco de los titanes",         minCount = 1,  category = "Frasco Raid",  effect = "+1200 Salud máxima (2 h)",     tip = "Frasco de tanque obligatorio: persiste tras morir y evita un golpe letal.", source = "Alquimia (300) / Loto negro / Stratholme", icon = "Interface\\Icons\\inv_potion_62", quality = 4 },
                { id = 13446, name = "Poción de sanación excelente", minCount = 5,  category = "Poción",       effect = "+1050 a 1750 Salud",           tip = "Recuperación de vida instantánea en picos de daño de jefes de raid.", source = "Alquimia (275) / Mostacho dorado", icon = "Interface\\Icons\\inv_potion_54", quality = 2 },
                { id = 13458, name = "Poción prot. fuego superior",   minCount = 5,  category = "Protección",   effect = "Absorbe hasta 3250 Daño Fuego",tip = "Indispensable para mitigar aliento de Onyxia, Magmadar y Ragnaros.", source = "Alquimia (290) / Corazón de fuego", icon = "Interface\\Icons\\inv_potion_24", quality = 2 },
                { id = 13455, name = "Poción armadura piedra mayor", minCount = 5,  category = "Mitigación",   effect = "+2000 Armadura (2 min)",       tip = "Multiplicado por la armadura base ofrece mitigación física récord.", source = "Alquimia (250) / Piedraescama", icon = "Interface\\Icons\\inv_potion_69", quality = 2 },
                { id = 13445, name = "Elixir de defensa superior",   minCount = 3,  category = "Elixir",       effect = "+450 Armadura durante 1 h",    tip = "Mitigación pasiva permanente para combates de banda.", source = "Alquimia (265) / Piedraescama", icon = "Interface\\Icons\\inv_potion_24", quality = 2 },
                { id = 3826,  name = "Elixir de fortaleza",         minCount = 3,  category = "Elixir",       effect = "+120 Salud máxima (1 h)",      tip = "+1200 puntos de vida base acumulables.", source = "Alquimia (175) / Espinela dorada", icon = "Interface\\Icons\\inv_potion_43", quality = 1 },
                { id = 21023, name = "Albóndigas de quimeroque",     minCount = 10, category = "Comida de Raid", effect = "+25 Aguante durante 15 min",  tip = "El mejor buff alimentario de tanque en todo WoW Classic.", source = "Cocina (300) / Lomo de quimeroque", icon = "Interface\\Icons\\inv_misc_food_15", quality = 3 },
                { id = 14530, name = "Venda de paño rúnico pesada", minCount = 15, category = "Primeros Aux.", effect = "Sana 2000 Salud en 8 s",        tip = "Curación sin maná entre fases o silencios.", source = "Primeros auxilios (290) / Paño rúnico", icon = "Interface\\Icons\\inv_misc_bandage_12", quality = 1 },
                { id = 12404, name = "Piedra de afilar densa",      minCount = 4,  category = "Mejora Arma",  effect = "+8 Daño con arma (30 min)",   tip = "Aumenta la amenaza generada por golpes blancos del arma principal.", source = "Herrería (250) / Piedra densa", icon = "Interface\\Icons\\inv_stone_sharpeningstone_05", quality = 1 },
            },
            ["MELEE_DPS"] = {
                { id = 13446, name = "Poción de sanación excelente", minCount = 5,  category = "Poción",       effect = "+1050 a 1750 Salud",           tip = "Sanación de emergencia ante daño en área imprevisto o cleaves.", source = "Alquimia (275) / Mostacho dorado", icon = "Interface\\Icons\\inv_potion_54", quality = 2 },
                { id = 13458, name = "Poción prot. fuego superior",   minCount = 5,  category = "Protección",   effect = "Absorbe hasta 3250 Daño Fuego",tip = "Mitigación indispensable en Molten Core y Onyxia para no morir en área.", source = "Alquimia (290) / Corazón de fuego", icon = "Interface\\Icons\\inv_potion_24", quality = 2 },
                { id = 13452, name = "Elixir del mangosta",         minCount = 5,  category = "Elixir Batalla",effect = "+25 Agilidad y +2% Crítico",   tip = "Elixir primordial para pícaros, guerreros, cazadores y ferales.", source = "Alquimia (280) / Lágrimas de Arthas", icon = "Interface\\Icons\\inv_potion_93", quality = 2 },
                { id = 9206,  name = "Elixir de los gigantes",      minCount = 5,  category = "Elixir Batalla",effect = "+25 Fuerza durante 1 h",       tip = "+50 de poder de ataque acumulable con Elixir del Mangosta.", source = "Alquimia (245) / Loto ciego", icon = "Interface\\Icons\\inv_potion_61", quality = 2 },
                { id = 13928, name = "Calamar a la parrilla",       minCount = 10, category = "Comida de Raid", effect = "+10 Agilidad durante 10 min",  tip = "El alimento de raid con mayor aporte de daño y crítico físico.", source = "Cocina (240) / Calamar de invierno", icon = "Interface\\Icons\\inv_misc_fish_13", quality = 1 },
                { id = 18262, name = "Piedra de afilar elemental",   minCount = 2,  category = "Mejora Arma",  effect = "+2% Crítico físico (30 min)",  tip = "+2% de golpe crítico directo en tu arma principal.", source = "Herrería (300) / Núcleo de lava", icon = "Interface\\Icons\\inv_stone_sharpeningstone_01", quality = 3 },
                { id = 14530, name = "Venda de paño rúnico pesada", minCount = 15, category = "Primeros Aux.", effect = "Sana 2000 Salud en 8 s",        tip = "Curación sin gastar maná del sanador.", source = "Primeros auxilios (290) / Paño rúnico", icon = "Interface\\Icons\\inv_misc_bandage_12", quality = 1 },
                { id = 5634,  name = "Poción de acción libre",      minCount = 3,  category = "Utilidad",     effect = "Inmune a aturdimiento 30 s",    tip = "Permite continuar tu rotación de daño inmune a ralentizaciones y aturdimientos.", source = "Alquimia (150) / Estranguladora", icon = "Interface\\Icons\\inv_potion_04", quality = 1 },
            },
            ["CASTER_DPS"] = {
                { id = 13512, name = "Frasco de poder supremo",      minCount = 1,  category = "Frasco Raid",  effect = "+150 Daño con hechizos (2 h)", tip = "El mayor multiplicador de daño mágico de WoW Classic. Persiste tras morir.", source = "Alquimia (300) / Loto negro / Scholomance", icon = "Interface\\Icons\\inv_potion_41", quality = 4 },
                { id = 13444, name = "Poción de maná excelente",     minCount = 10, category = "Poción",       effect = "+1350 a 2250 Maná",            tip = "Rotación de maná obligatoria en cada enfriamiento para no quedar seco.", source = "Alquimia (295) / Flor de ensueño", icon = "Interface\\Icons\\inv_potion_76", quality = 2 },
                { id = 13458, name = "Poción prot. fuego superior",   minCount = 5,  category = "Protección",   effect = "Absorbe hasta 3250 Daño Fuego",tip = "Mitigación obligatoria contra explosiones y llamaradas de jefes.", source = "Alquimia (290) / Corazón de fuego", icon = "Interface\\Icons\\inv_potion_24", quality = 2 },
                { id = 13454, name = "Elixir arcano mayor",          minCount = 5,  category = "Elixir Batalla",effect = "+35 Daño con hechizos (1 h)",  tip = "Aumento masivo de daño para todas las escuelas mágicas.", source = "Alquimia (285) / Flor de ensueño", icon = "Interface\\Icons\\inv_potion_25", quality = 2 },
                { id = 20749, name = "Aceite de zahorí brillante",   minCount = 2,  category = "Mejora Arma",  effect = "+36 Daño Hechizos + 1% Crítico",tip = "Aplicable a armas: +36 daño con hechizos y +1% crítico durante 30 min.", source = "Encantamiento (300) / Cristal grande brillante", icon = "Interface\\Icons\\inv_potion_105", quality = 3 },
                { id = 13931, name = "Sopa de aleta de noche",      minCount = 10, category = "Comida de Raid", effect = "+8 Maná cada 5 s (10 min)",     tip = "Regeneración activa de maná (Mp5) permanente durante el combate.", source = "Cocina (250) / Pargo de noche", icon = "Interface\\Icons\\inv_misc_fish_14", quality = 1 },
                { id = 8766,  name = "Rocío de gloria matutina",    minCount = 20, category = "Bebida",       effect = "Restaura 2934 Maná en 30 s",   tip = "Bebida requerida para recuperar maná rápidamente entre pulls de banda.", source = "Taberneros y vendedores", icon = "Interface\\Icons\\inv_drink_10", quality = 1 },
                { id = 20520, name = "Runa oscura",                 minCount = 5,  category = "Utilidad Maná",effect = "+900 a 1500 Maná por vida",     tip = "Cooldown independiente de las pociones: maná instantáneo a cambio de salud.", source = "Drop en Scholomance (Nigromantes)", icon = "Interface\\Icons\\spell_shadow_sealofkings", quality = 2 },
                { id = 14530, name = "Venda de paño rúnico pesada", minCount = 15, category = "Primeros Aux.", effect = "Sana 2000 Salud en 8 s",        tip = "Autocuración entre fases sin gastar tu propio maná.", source = "Primeros auxilios (290) / Paño rúnico", icon = "Interface\\Icons\\inv_misc_bandage_12", quality = 1 },
            },
            ["HEALER"] = {
                { id = 13511, name = "Frasco de sabiduría destilada", minCount = 1, category = "Frasco Raid",  effect = "+2000 Maná máximo (2 h)",      tip = "Reserva de maná gigantesca que persiste tras morir, ideal para peleas largas.", source = "Alquimia (300) / Loto negro / Stratholme", icon = "Interface\\Icons\\inv_potion_97", quality = 4 },
                { id = 13444, name = "Poción de maná excelente",     minCount = 12, category = "Poción",       effect = "+1350 a 2250 Maná",            tip = "El consumible más importante del sanador. Beber cada vez que esté disponible.", source = "Alquimia (295) / Flor de ensueño", icon = "Interface\\Icons\\inv_potion_76", quality = 2 },
                { id = 13458, name = "Poción prot. fuego superior",   minCount = 5,  category = "Protección",   effect = "Absorbe hasta 3250 Daño Fuego",tip = "Evita morir en mecánicas de fuego de banda para seguir sanando al grupo.", source = "Alquimia (290) / Corazón de fuego", icon = "Interface\\Icons\\inv_potion_24", quality = 2 },
                { id = 13447, name = "Elixir de los sabios",        minCount = 5,  category = "Elixir Guardián",effect = "+18 Intelecto y +18 Espíritu",  tip = "La mejor combinación de maná total y regeneración por espíritu de Classic.", source = "Alquimia (270) / Flor de ensueño", icon = "Interface\\Icons\\inv_potion_29", quality = 2 },
                { id = 20748, name = "Aceite de maná brillante",    minCount = 2,  category = "Mejora Arma",  effect = "+25 Sanación y +12 Mp5 (30 min)",tip = "Mejora de arma óptima para sanadores: regeneración pasiva y bonus curativo.", source = "Encantamiento (300) / Cristal grande brillante", icon = "Interface\\Icons\\inv_potion_100", quality = 3 },
                { id = 13931, name = "Sopa de aleta de noche",      minCount = 10, category = "Comida de Raid", effect = "+8 Maná cada 5 s (10 min)",     tip = "Mp5 activo continuo para soportar combates largos sin OOM.", source = "Cocina (250) / Pargo de noche", icon = "Interface\\Icons\\inv_misc_fish_14", quality = 1 },
                { id = 8766,  name = "Rocío de gloria matutina",    minCount = 20, category = "Bebida",       effect = "Restaura 2934 Maná en 30 s",   tip = "Bebida indispensable para restaurar tu maná al 100% entre cada intento.", source = "Taberneros y vendedores", icon = "Interface\\Icons\\inv_drink_10", quality = 1 },
                { id = 20520, name = "Runa oscura",                 minCount = 5,  category = "Utilidad Maná",effect = "+900 a 1500 Maná por vida",     tip = "Cooldown independiente de pociones para recuperar maná de emergencia.", source = "Drop en Scholomance (Nigromantes)", icon = "Interface\\Icons\\spell_shadow_sealofkings", quality = 2 },
                { id = 14530, name = "Venda de paño rúnico pesada", minCount = 15, category = "Primeros Aux.", effect = "Sana 2000 Salud en 8 s",        tip = "Permite parcharte o parchar aliados sin gastar maná de curación.", source = "Primeros auxilios (290) / Paño rúnico", icon = "Interface\\Icons\\inv_misc_bandage_12", quality = 1 },
            },
        },
    },
}

-- Variables de Estado
local containerFrame = nil
local rowFrames = {}
local selectedIndex = 1
local previewRaidMode = false

-- =========================================================================
-- VARIABLES Y CONSTANTES DE CAMPAMENTO ÓPTIMO (WOW FOREVER)
-- =========================================================================
RaidPrep.currentSubMode = "consumables" -- "consumables" o "camping"
local _, playerClassInit = UnitClass("player")
playerClassInit = playerClassInit or "WARRIOR"
RaidPrep.partyClasses = { playerClassInit, "PRIEST", "MAGE", "ROGUE", "DRUID" }
RaidPrep.selectedCampfireKey = "journeyman" -- 5 ranuras por defecto (ideal grupo mazmorra)
RaidPrep.selectedCampIndex = 1
local campingRowFrames = {}

local CLASS_CYCLE = {
    "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID", "NONE"
}

local CLASS_NAMES_ES = {
    ["WARRIOR"] = "Guerrero",
    ["PALADIN"] = "Paladín",
    ["HUNTER"]  = "Cazador",
    ["ROGUE"]   = "Pícaro",
    ["PRIEST"]  = "Sacerdote",
    ["SHAMAN"]  = "Chamán",
    ["MAGE"]    = "Mago",
    ["WARLOCK"] = "Brujo",
    ["DRUID"]   = "Druida",
    ["NONE"]    = "(Vacío)",
}

local CLASS_COLORS = {
    ["WARRIOR"] = "C79C6E",
    ["PALADIN"] = "F58CBA",
    ["HUNTER"]  = "ABD473",
    ["ROGUE"]   = "FFF569",
    ["PRIEST"]  = "FFFFFF",
    ["SHAMAN"]  = "0070DE",
    ["MAGE"]    = "69CCF0",
    ["WARLOCK"] = "9482C9",
    ["DRUID"]   = "FF7D0A",
    ["NONE"]    = "888888",
}

-- =========================================================================
-- FUNCIONES AUXILIARES: ACCESO A OBJETOS Y CLASE
-- =========================================================================
local function SafeGetItem(itemID)
    if not itemID or itemID == 0 then return nil end
    if C_Item and C_Item.GetItemInfo then
        local ok, n, l, q, _, _, _, _, _, t = pcall(C_Item.GetItemInfo, itemID)
        if ok and n then return n, l, q, t end
    end
    if GetItemInfo then
        local ok, n, l, q, _, _, _, _, _, t = pcall(GetItemInfo, itemID)
        if ok and n then return n, l, q, t end
    end
    return nil
end

local function GetPlayerBracket(level)
    level = tonumber(level) or UnitLevel("player") or 1
    if previewRaidMode or level >= 60 then
        return "60"
    elseif level >= 50 then
        return "50-59"
    elseif level >= 35 then
        return "35-49"
    elseif level >= 20 then
        return "20-34"
    else
        return "1-19"
    end
end

function RaidPrep:GetSpecsForClass(playerClass)
    playerClass = (playerClass or select(2, UnitClass("player")) or "WARRIOR"):upper()
    return SPECS_BY_CLASS[playerClass] or SPECS_BY_CLASS["WARRIOR"]
end

function RaidPrep:GetPlayerActiveSpec(playerClass)
    playerClass = (playerClass or select(2, UnitClass("player")) or "WARRIOR"):upper()
    if self.selectedSpecKey then
        local classSpecs = self:GetSpecsForClass(playerClass)
        for _, s in ipairs(classSpecs) do
            if s.key == self.selectedSpecKey then
                return s
            end
        end
    end

    -- Detección automática por talentos
    if GetNumTalents and GetTalentTabInfo then
        local maxPts = -1
        local bestTab = 1
        for tabIdx = 1, 3 do
            local ok, _, _, pts = pcall(GetTalentTabInfo, tabIdx)
            if ok and pts and pts > maxPts then
                maxPts = pts
                bestTab = tabIdx
            end
        end
        local classSpecs = self:GetSpecsForClass(playerClass)
        if classSpecs and classSpecs[bestTab] then
            return classSpecs[bestTab]
        end
    end

    local classSpecs = self:GetSpecsForClass(playerClass)
    return classSpecs and classSpecs[1] or { key = "fury", name = "Guerrero Furia", role = "MELEE_DPS" }
end

local function ResolveLadderItem(ladder, level)
    for _, entry in ipairs(ladder) do
        if level >= entry.minLevel then
            return entry
        end
    end
    return ladder[#ladder]
end

--- Recomienda la comida óptima para el nivel, clase y especialización activa basándose en los StatWeights (EP)
function RaidPrep:GetBestFoodForSpec(effLevel, playerClass, specKey, role)
    local weights, specDisplayName
    if ns.GetStatWeights then
        weights, specDisplayName = ns.GetStatWeights(playerClass, specKey)
    end

    local bestFood = nil
    local maxScore = -1

    for _, food in ipairs(ALL_CAMELOT_FOODS) do
        if effLevel >= food.minLevel then
            local score = 0
            if weights and food.stats then
                for statKey, statVal in pairs(food.stats) do
                    local w = weights[statKey] or 0
                    -- Si el alimento otorga MP5 y la spec no tiene peso explícito de MP5, inferir de Sanación o Hechizos
                    if statKey == "MP5" and w == 0 then
                        if weights.HEAL and weights.HEAL > 0 then
                            w = weights.HEAL * 3.0
                        elseif weights.SPELL_POWER and weights.SPELL_POWER > 0 then
                            w = weights.SPELL_POWER * 1.5
                        end
                    end
                    score = score + (statVal * w)
                end
            end

            -- En rol Tanque, premiar supervivencia (Aguante) para garantizar solidez
            if role == "TANK" and food.stats and food.stats.STA then
                score = score + (food.stats.STA * 1.5)
            end

            -- En fase de leveleo (nivel < 55), priorizar alimentos que conceden +5% EXP extra
            if effLevel < 55 and food.effect and food.effect:find("5%% EXP") then
                score = score + 5.0
            end

            if score > maxScore then
                maxScore = score
                bestFood = food
            elseif score == maxScore and bestFood then
                -- Desempate por mayor nivel requerido (tier superior)
                if food.minLevel > bestFood.minLevel then
                    bestFood = food
                end
            end
        end
    end

    if bestFood and maxScore > 0 then
        local res = {}
        for k, v in pairs(bestFood) do res[k] = v end
        if specDisplayName and maxScore > 0 then
            res.tip = (bestFood.tip or "") .. string.format(" [Óptimo para %s: %.1f EP]", specDisplayName, maxScore)
        end
        return res
    end

    -- Fallback si no hay pesos o puntuación positiva
    local foodLadder = (role == "HEALER" and CAMELOT_FOOD_HEALER)
        or (role == "CASTER_DPS" and CAMELOT_FOOD_CASTER)
        or (role == "TANK" and CAMELOT_FOOD_TANK)
        or CAMELOT_FOOD_MELEE
    return ResolveLadderItem(foodLadder, effLevel)
end

-- =========================================================================
-- ESCÁNER DINÁMICO DE TOOLTIP EN TIEMPO REAL (WOW FOREVER SERVIDOR / CLIENTE)
-- =========================================================================
local prepScanTooltip = nil
local function GetPrepScanTooltip()
    if not prepScanTooltip then
        prepScanTooltip = CreateFrame("GameTooltip", "AwakeningPrepScanner", UIParent, "GameTooltipTemplate")
        prepScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    end
    return prepScanTooltip
end

--- Extrae el efecto real y actualizado de un consumible desde los datos en vivo del cliente/servidor
function RaidPrep:GetDynamicItemEffect(itemID)
    if not itemID or itemID == 0 then return nil end
    local tt = GetPrepScanTooltip()
    tt:ClearLines()
    local ok = pcall(tt.SetItemByID, tt, itemID)
    if not ok then
        pcall(tt.SetHyperlink, tt, "item:" .. itemID)
    end
    for i = 1, tt:NumLines() do
        local line = _G["AwakeningPrepScannerTextLeft" .. i]
        if line then
            local text = line:GetText()
            if text and text ~= "" then
                local lower = text:lower()
                -- Buscar la línea donde se especifica el beneficio / Well Fed / EXP
                if lower:find("well fed") or lower:find("bien alimentado") or lower:find("experience") or lower:find("experiencia") then
                    return text
                elseif lower:find("use:") or lower:find("uso:") then
                    local cleaned = text:match("^[Uu]se:%s*(.+)") or text:match("^[Uu]so:%s*(.+)")
                    if cleaned and (cleaned:lower():find("well fed") or cleaned:lower():find("gain") or cleaned:lower():find("obten") or cleaned:lower():find("aumenta")) then
                        return cleaned
                    end
                end
            end
        end
    end
    return nil
end

function RaidPrep:GetConsumablesList()
    local _, playerClass = UnitClass("player")
    playerClass = (playerClass or "WARRIOR"):upper()
    local playerLevel = UnitLevel("player") or 1
    local effLevel = (previewRaidMode or playerLevel >= 60) and 60 or playerLevel
    local bracketKey = GetPlayerBracket(effLevel)
    local bracketData = CONSUMABLES_DB[bracketKey] or CONSUMABLES_DB["1-19"]

    local activeSpec = self:GetPlayerActiveSpec(playerClass)
    local role = activeSpec and activeSpec.role or "MELEE_DPS"

    local baseList = bracketData.roles and (bracketData.roles[role] or bracketData.roles["MELEE_DPS"])
    local list = {}

    -- 1. Copiar y adaptar dinámicamente según nivel exacto y escaleras de Camelot
    if baseList then
        for _, itm in ipairs(baseList) do
            local adapted = {}
            for k, v in pairs(itm) do adapted[k] = v end

            -- Bebidas (Water ladder)
            if adapted.category == "Bebida" then
                local bestWater = ResolveLadderItem(CAMELOT_WATER_LADDER, effLevel)
                if bestWater then
                    adapted.id = bestWater.id
                    adapted.name = bestWater.name
                    adapted.effect = bestWater.effect
                    adapted.icon = bestWater.icon or adapted.icon
                    adapted.source = bestWater.source or adapted.source
                end
            -- Comidas (Food ladders adaptadas por StatWeights de la clase y especialización)
            elseif adapted.category == "Comida (Buf)" or adapted.category == "Comida de Raid" then
                local bestFood = RaidPrep:GetBestFoodForSpec(effLevel, playerClass, activeSpec and activeSpec.key, role)
                if bestFood then
                    adapted.id = bestFood.id
                    adapted.name = bestFood.name
                    adapted.effect = bestFood.effect
                    adapted.icon = bestFood.icon or adapted.icon
                    adapted.tip = bestFood.tip or adapted.tip
                    adapted.source = bestFood.source or adapted.source
                    if bestFood.quality then adapted.quality = bestFood.quality end
                end
            -- Pociones de maná
            elseif adapted.category == "Poción" and (role == "HEALER" or role == "CASTER_DPS") and adapted.id ~= 858 and adapted.id ~= 929 and adapted.id ~= 1710 and adapted.id ~= 3928 and adapted.id ~= 13446 then
                if effLevel < 60 then
                    local bestMana = ResolveLadderItem(CAMELOT_MANA_POTIONS, effLevel)
                    if bestMana then
                        adapted.id = bestMana.id
                        adapted.name = bestMana.name
                        adapted.effect = bestMana.effect
                        adapted.icon = bestMana.icon or adapted.icon
                        adapted.source = bestMana.source or adapted.source
                        if bestMana.quality then adapted.quality = bestMana.quality end
                    end
                end
            -- Pociones de sanación
            elseif adapted.category == "Poción" and (adapted.id == 118 or adapted.id == 858 or adapted.id == 929 or adapted.id == 1710 or adapted.id == 3928 or adapted.id == 13446) then
                if effLevel < 60 then
                    local bestHeal = ResolveLadderItem(CAMELOT_HEALING_POTIONS, effLevel)
                    if bestHeal then
                        adapted.id = bestHeal.id
                        adapted.name = bestHeal.name
                        adapted.effect = bestHeal.effect
                        adapted.icon = bestHeal.icon or adapted.icon
                        adapted.source = bestHeal.source or adapted.source
                        if bestHeal.quality then adapted.quality = bestHeal.quality end
                    end
                end
            -- Vendas (Primeros Auxilios)
            elseif adapted.category == "Primeros Aux." then
                if effLevel < 60 then
                    local bestBandage = ResolveLadderItem(CAMELOT_BANDAGES, effLevel)
                    if bestBandage then
                        adapted.id = bestBandage.id
                        adapted.name = bestBandage.name
                        adapted.effect = bestBandage.effect
                        adapted.icon = bestBandage.icon or adapted.icon
                        adapted.source = bestBandage.source or adapted.source
                        if bestBandage.quality then adapted.quality = bestBandage.quality end
                    end
                end
            end

            -- Si el cliente del juego tiene en caché los datos en vivo del objeto, extraer el efecto real de WoW Forever
            local liveEffect = self:GetDynamicItemEffect(adapted.id)
            if liveEffect then
                adapted.effect = liveEffect
            end

            table.insert(list, adapted)
        end
    end

    -- 2. Inyectar Reagentes de Clase de Camelot según clase y nivel
    local classReagents = CAMELOT_CLASS_REAGENTS[playerClass]
    if classReagents then
        for _, group in pairs(classReagents) do
            local bestReagent = ResolveLadderItem(group, effLevel)
            if bestReagent and effLevel >= bestReagent.minLevel then
                -- Evitar duplicados
                local alreadyPresent = false
                for _, existing in ipairs(list) do
                    if existing.id == bestReagent.id then
                        alreadyPresent = true
                        break
                    end
                end
                if not alreadyPresent then
                    table.insert(list, {
                        id = bestReagent.id,
                        name = bestReagent.name,
                        minCount = bestReagent.minCount,
                        category = bestReagent.category or "Componente",
                        effect = bestReagent.effect,
                        tip = bestReagent.tip,
                        source = bestReagent.source,
                        icon = bestReagent.icon,
                        quality = bestReagent.quality or 1,
                    })
                end
            end
        end
    end

    return list, bracketData, activeSpec
end

-- =========================================================================
-- OPTIMIZADOR DE CAMPAMENTOS PARA GRUPO (WOW FOREVER)
-- =========================================================================
function RaidPrep:GetOptimizedCampingList()
    local db = ns.Data and ns.Data.Camping
    if not db or not db.Items then return {}, {}, {}, nil, 0 end

    -- 1. Obtener el fogón seleccionado
    local selectedFire = nil
    for _, fire in ipairs(db.Campfires) do
        if fire.key == self.selectedCampfireKey then
            selectedFire = fire
            break
        end
    end
    if not selectedFire then selectedFire = db.Campfires[2] end -- Oficial (5 ranuras) por defecto

    -- 2. Analizar la composición del grupo
    local activeClasses = {}
    local hasCasters = false
    local hasMelees = false
    local partyCount = 0

    for i = 1, 5 do
        local c = self.partyClasses[i]
        if c and c ~= "NONE" then
            activeClasses[c] = true
            partyCount = partyCount + 1
            if c == "MAGE" or c == "PRIEST" or c == "WARLOCK" or c == "DRUID" or c == "SHAMAN" then
                hasCasters = true
            end
            if c == "WARRIOR" or c == "ROGUE" or c == "HUNTER" or c == "PALADIN" or c == "DRUID" or c == "SHAMAN" then
                hasMelees = true
            end
        end
    end

    -- 3. Agrupar el mejor ítem de cada profesión (Tier 1 o Tier 2)
    local seenProfs = {}
    for _, item in ipairs(db.Items) do
        local key = item.profKey
        if not seenProfs[key] or (item.tier > seenProfs[key].tier) then
            seenProfs[key] = item
        end
    end

    local evaluated = {}
    local discarded = {}

    for profKey, item in pairs(seenProfs) do
        local entry = {
            id = item.id,
            name = item.name,
            profession = item.profession,
            profKey = item.profKey,
            tier = item.tier,
            skillReq = item.skillReq,
            icon = item.icon,
            effect = item.effect,
            effectDesc = item.effectDesc,
            classCopy = item.classCopy,
            conflictClass = item.conflictClass,
            conflictReason = item.conflictReason,
            source = item.source,
            roleTarget = item.roleTarget,
        }

        -- Verificar si la clase que otorga el bufo nativo está en el grupo
        if item.conflictClass and activeClasses[item.conflictClass] then
            entry.isConflicted = true
            entry.conflictNote = item.conflictReason
            entry.priority = -1
            table.insert(discarded, entry)
        else
            entry.isConflicted = false
            local prio = item.basePriority or 50

            -- Ponderación contextual según roles en grupo
            if profKey == "Fishing" then
                prio = 100 -- Pecera (+8% a todas las estadísticas) es la #1 absoluta si no hay Paladín
            elseif profKey == "First Aid" then
                prio = 95 -- Botiquín (+Aguante) es vital si no hay Sacerdote
            elseif profKey == "Leatherworking" then
                prio = 90 -- Tienda (+5% Rested XP) beneficio universal de leveleo y mazmorras
            elseif profKey == "Engineering" then
                prio = 88 -- Robot de reparación / componentes en la estancia
            elseif profKey == "Cooking" then
                prio = 82 -- Festín de comida de aguante
            elseif profKey == "Skinning" then
                prio = 78 -- +Crítico global
            elseif profKey == "Herbalism" then
                prio = hasCasters and 75 or 55 -- +Intelecto
            elseif profKey == "Alchemy" then
                prio = hasCasters and 72 or 52 -- Mp5 sostenido
            elseif profKey == "Mining" then
                prio = hasMelees and 70 or 48 -- +Melee AP
            elseif profKey == "Blacksmithing" then
                prio = hasMelees and 66 or 45 -- +Fuerza
            elseif profKey == "Enchanting" then
                prio = 60 -- Armadura y Resistencias
            elseif profKey == "Tailoring" then
                prio = hasCasters and 50 or 40 -- +Espíritu
            end

            entry.priority = prio
            table.insert(evaluated, entry)
        end
    end

    -- 4. Ordenar candidatos por prioridad descendente
    table.sort(evaluated, function(a, b)
        return (a.priority or 0) > (b.priority or 0)
    end)

    -- 5. Asignar ranuras del fogón disponible
    local maxSlots = selectedFire and selectedFire.slots or 5
    local recommended = {}
    local alternatives = {}

    for i, entry in ipairs(evaluated) do
        if i <= maxSlots then
            entry.isRecommended = true
            entry.slotOrder = i
            table.insert(recommended, entry)
        else
            entry.isRecommended = false
            entry.isAlternative = true
            table.insert(alternatives, entry)
        end
    end

    -- 6. Construir lista completa (Recomendados -> Alternativas -> Descartados por solapamiento)
    local fullList = {}
    for _, it in ipairs(recommended) do table.insert(fullList, it) end
    for _, it in ipairs(alternatives) do table.insert(fullList, it) end
    for _, it in ipairs(discarded) do table.insert(fullList, it) end

    return fullList, recommended, discarded, selectedFire, partyCount
end

-- =========================================================================
-- CONSTRUCCIÓN DE LA VISTA PREPARACIÓN
-- =========================================================================
function RaidPrep:Build(parent)
    if containerFrame then return containerFrame end

    containerFrame = CreateFrame("Frame", "AwakeningPrepContainer", parent)
    containerFrame:SetAllPoints(parent)
    parent.prepContainer = containerFrame

    -- 0. Barra superior de Selección de Sub-Modo (Consumibles vs Campamento Óptimo)
    local subBar = CreateFrame("Frame", nil, containerFrame)
    subBar:SetPoint("TOPLEFT", containerFrame, "TOPLEFT", 2, 0)
    subBar:SetPoint("TOPRIGHT", containerFrame, "TOPRIGHT", -2, 0)
    subBar:SetHeight(22)
    containerFrame.subBar = subBar

    local btnSubConsumables = CreateFrame("Button", nil, subBar, "UIPanelButtonTemplate")
    btnSubConsumables:SetPoint("LEFT", subBar, "LEFT", 0, 0)
    btnSubConsumables:SetWidth(228)
    btnSubConsumables:SetHeight(22)
    btnSubConsumables:SetText("|cFFFFD100|TInterface\\Icons\\inv_potion_52:14:14:0:0|t Consumibles Personales|r")
    subBar.btnConsumables = btnSubConsumables
    btnSubConsumables:SetScript("OnClick", function()
        RaidPrep:SetSubMode("consumables")
    end)
    btnSubConsumables:SetScript("OnEnter", function(selfBtn)
        GameTooltip:SetOwner(selfBtn, "ANCHOR_TOP")
        GameTooltip:AddLine("Consumibles Personales y de Banda", 1, 0.82, 0)
        GameTooltip:AddLine("Elixires, pociones, comidas, frascos, reactivos de clase y vendas recomendados para tu rol y nivel.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btnSubConsumables:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local btnSubCamping = CreateFrame("Button", nil, subBar, "UIPanelButtonTemplate")
    btnSubCamping:SetPoint("LEFT", btnSubConsumables, "RIGHT", 4, 0)
    btnSubCamping:SetWidth(228)
    btnSubCamping:SetHeight(22)
    btnSubCamping:SetText("|TInterface\\Icons\\spell_fire_fire:14:14:0:0|t Campamento Óptimo")
    subBar.btnCamping = btnSubCamping
    btnSubCamping:SetScript("OnClick", function()
        RaidPrep:SetSubMode("camping")
    end)
    btnSubCamping:SetScript("OnEnter", function(selfBtn)
        GameTooltip:SetOwner(selfBtn, "ANCHOR_TOP")
        GameTooltip:AddLine("Campamento Óptimo (WoW Forever)", 1, 0.82, 0)
        GameTooltip:AddLine("Configura las clases de tu equipo de 1 a 5 jugadores y sugiere la combinación óptima de mejoras de campamento sin solapar ni cancelar beneficios de clase.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btnSubCamping:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- ---------------------------------------------------------------------
    -- SECCIÓN 1: VISTA DE CONSUMIBLES
    -- ---------------------------------------------------------------------
    -- 1. Barra de Controles de Consumibles (Modo Leveleo/Raid y Especialización)
    local controls = CreateFrame("Frame", nil, containerFrame)
    controls:SetPoint("TOPLEFT", containerFrame, "TOPLEFT", 2, -24)
    controls:SetPoint("TOPRIGHT", containerFrame, "TOPRIGHT", -2, -24)
    controls:SetHeight(22)
    containerFrame.controls = controls

    -- Botón 1: Modo / Tramo de Nivel
    local modeBtn = CreateFrame("Button", nil, controls, "UIPanelButtonTemplate")
    modeBtn:SetPoint("LEFT", controls, "LEFT", 0, 0)
    modeBtn:SetWidth(228)
    modeBtn:SetHeight(20)
    modeBtn:SetText("Leveleo")
    containerFrame.modeBtn = modeBtn

    local modeArrow = modeBtn:CreateTexture(nil, "OVERLAY")
    modeArrow:SetSize(10, 10)
    modeArrow:SetPoint("RIGHT", modeBtn, "RIGHT", -8, 0)
    modeArrow:SetTexture("Interface\\AddOns\\AwakeningCompanion\\Media\\Icons\\arrow_down.tga")
    modeBtn.arrow = modeArrow

    modeBtn:SetScript("OnClick", function()
        local pLvl = UnitLevel("player") or 1
        if pLvl < 60 then
            previewRaidMode = not previewRaidMode
            if previewRaidMode then
                ns.Print("Preparación: Vista previa de consumibles para |cFFFFD100Banda / Raid (Nivel 60)|r activada.")
            else
                ns.Print("Preparación: Restaurado a consumibles de tu nivel actual (|cFF00FFCCLeveleo / Mazmorras|r).")
            end
        else
            ns.Print("Preparación: Nivel máximo alcanzado (60). Lista optimizada para Bandas / Raids.")
        end
        RaidPrep:Update()
    end)

    modeBtn:SetScript("OnEnter", function(selfBtn)
        GameTooltip:SetOwner(selfBtn, "ANCHOR_TOP")
        GameTooltip:AddLine("Modo de Preparación", 1, 0.82, 0)
        local pLvl = UnitLevel("player") or 1
        if pLvl < 60 then
            GameTooltip:AddLine("Clic para alternar entre los consumibles de tu nivel actual y la vista previa de Banda / Raid a nivel 60.", 1, 1, 1, true)
        else
            GameTooltip:AddLine("Tu personaje es nivel 60. Mostrando consumibles y frascos óptimos para Banda (Molten Core, Onyxia, BWL).", 1, 1, 1, true)
        end
        GameTooltip:Show()
    end)
    modeBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Botón 2: Selector de Especialización
    local specBtn = CreateFrame("Button", nil, controls, "UIPanelButtonTemplate")
    specBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    specBtn:SetPoint("LEFT", modeBtn, "RIGHT", 4, 0)
    specBtn:SetWidth(228)
    specBtn:SetHeight(20)
    specBtn:SetText("Rama: ...")
    containerFrame.specBtn = specBtn

    local specArrow = specBtn:CreateTexture(nil, "OVERLAY")
    specArrow:SetSize(10, 10)
    specArrow:SetPoint("RIGHT", specBtn, "RIGHT", -8, 0)
    specArrow:SetTexture("Interface\\AddOns\\AwakeningCompanion\\Media\\Icons\\arrow_down.tga")
    specBtn.arrow = specArrow

    specBtn:SetScript("OnClick", function(_, mouseBtn)
        RaidPrep:CycleSpec(mouseBtn == "RightButton")
    end)

    specBtn:SetScript("OnEnter", function(selfBtn)
        GameTooltip:SetOwner(selfBtn, "ANCHOR_TOP")
        GameTooltip:AddLine("Especialización de Preparación", 1, 0.82, 0)
        GameTooltip:AddLine("|cFF00FFCCClic Izquierdo:|r Alternar entre ramas de tu clase actual.", 1, 1, 1, true)
        GameTooltip:AddLine("|cFFFFFFFFClic Derecho:|r Explorar ramas de todas las clases.", 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    specBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Scroll de Filas de Consumibles
    local scroll = CreateFrame("ScrollFrame", "AwakeningPrepScroll", containerFrame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", containerFrame, "TOPLEFT", 2, -48)
    scroll:SetPoint("BOTTOMRIGHT", containerFrame, "BOTTOMRIGHT", -20, 2)
    containerFrame.scroll = scroll

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(440, 10)
    scroll:SetScrollChild(content)
    containerFrame.content = content

    -- Crear 24 marcos de fila reutilizables
    for i = 1, 24 do
        local row = CreateFrame("Button", nil, content, "BackdropTemplate")
        row:SetSize(440, 22)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((i - 1) * 23))

        local hl = row:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints()
        hl:SetTexture("Interface\Buttons\UI-Listbox-Highlight")
        hl:SetBlendMode("ADD")
        hl:SetAlpha(0.35)

        local sel = row:CreateTexture(nil, "BORDER")
        sel:SetAllPoints()
        sel:SetColorTexture(1, 0.82, 0, 0.15)
        sel:Hide()
        row.selection = sel

        -- Columna 1: Icono + Nombre del Consumible (ocupa todo el ancho hasta Inventario)
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(16, 16)
        icon:SetPoint("LEFT", row, "LEFT", 4, 0)
        icon:SetTexture("Interface\\Icons\\inv_potion_52")
        row.icon = icon

        local nameLabel = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        nameLabel:SetPoint("LEFT", icon, "RIGHT", 6, 0)
        nameLabel:SetPoint("RIGHT", row, "RIGHT", -150, 0)
        nameLabel:SetJustifyH("LEFT")
        nameLabel:SetWordWrap(false)
        row.nameLabel = nameLabel

        -- Columna 2 (anteriormente Categoría / Efecto): Oculta en la fila visual, disponible en tooltip
        local catLabel = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        catLabel:Hide()
        row.catLabel = catLabel

        -- Columna 2 visual (anteriormente 3): Estado en Inventario (Semáforo)
        local statusLabel = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        statusLabel:SetPoint("LEFT", row, "RIGHT", -146, 0)
        statusLabel:SetPoint("RIGHT", row, "RIGHT", -6, 0)
        statusLabel:SetJustifyH("RIGHT")
        statusLabel:SetWordWrap(false)
        row.statusLabel = statusLabel

        row:SetScript("OnEnter", function(selfRow)
            if not selfRow.itemData then return end
            local itm = selfRow.itemData
            GameTooltip:SetOwner(selfRow, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()

            local _, link = SafeGetItem(itm.id)
            if link then
                GameTooltip:SetHyperlink(link)
            else
                GameTooltip:SetItemByID(itm.id)
            end

            GameTooltip:AddLine(" ")
            GameTooltip:AddDoubleLine("|cFFFFD100Categoría:|r " .. (itm.category or "Consumible"), "|cFFFFD100Mínimo Recomendado:|r |cFFFFFFFFx" .. itm.minCount .. "|r")
            GameTooltip:AddDoubleLine("|cFFFFD100Efecto:|r |cFF00FF00" .. (itm.effect or "Mejora") .. "|r", "|cFFFFD100ID:|r |cFF888888" .. itm.id .. "|r")
            
            if itm.tip then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("|cFFFFD100Por qué se recomienda:|r", 1, 0.82, 0)
                GameTooltip:AddLine(itm.tip, 0.8, 0.9, 1, true)
            end

            if itm.source then
                GameTooltip:AddLine(" ")
                GameTooltip:AddDoubleLine("|cFFFFD100Obtención:|r", itm.source, 1, 0.82, 0, 1, 1, 1, true)
            end

            local count = GetItemCount(itm.id, false, false) or 0
            local stStr = (count >= itm.minCount) and "|cFF00FF00Completado (" .. count .. "/" .. itm.minCount .. " en bolsas)|r"
                or (count > 0 and "|cFFFFCC00Insuficiente (" .. count .. "/" .. itm.minCount .. " en bolsas)|r"
                or "|cFFFF5555Faltan " .. itm.minCount .. " en tus bolsas|r")
            GameTooltip:AddLine(" ")
            GameTooltip:AddDoubleLine("|cFFFFD100Estado actual:|r", stStr)
            GameTooltip:Show()
        end)

        row:SetScript("OnLeave", function() GameTooltip:Hide() end)

        row:SetScript("OnClick", function(selfRow)
            selectedIndex = i
            RaidPrep:SelectConsumable(selfRow.itemData)
            for idx, r in ipairs(rowFrames) do
                if r.selection then r.selection:SetShown(idx == i) end
            end
        end)

        rowFrames[i] = row
    end

    -- ---------------------------------------------------------------------
    -- SECCIÓN 2: VISTA DE CAMPAMENTO ÓPTIMO (WOW FOREVER)
    -- ---------------------------------------------------------------------
    local campingControls = CreateFrame("Frame", nil, containerFrame)
    campingControls:SetPoint("TOPLEFT", containerFrame, "TOPLEFT", 2, -24)
    campingControls:SetPoint("TOPRIGHT", containerFrame, "TOPRIGHT", -2, -24)
    campingControls:SetHeight(46)
    campingControls:Hide()
    containerFrame.campingControls = campingControls

    -- Fila 1: Selector de 5 clases de integrantes del equipo (ancho extendido 88px cada una)
    campingControls.slotButtons = {}
    local slotWidth = 88
    local slotSpacing = 4
    for slotIdx = 1, 5 do
        local slotBtn = CreateFrame("Button", nil, campingControls, "UIPanelButtonTemplate")
        slotBtn:SetSize(slotWidth, 20)
        slotBtn:SetPoint("TOPLEFT", campingControls, "TOPLEFT", (slotIdx - 1) * (slotWidth + slotSpacing), 0)
        slotBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        slotBtn:SetScript("OnClick", function(_, mouseBtn)
            RaidPrep:CycleSlotClass(slotIdx, mouseBtn == "RightButton")
        end)
        slotBtn:SetScript("OnEnter", function(selfBtn)
            GameTooltip:SetOwner(selfBtn, "ANCHOR_TOP")
            local cKey = RaidPrep.partyClasses[slotIdx] or "NONE"
            local cName = CLASS_NAMES_ES[cKey] or cKey
            local prefix = (slotIdx == 1) and "Tu Personaje" or string.format("Compañero %d", slotIdx)
            GameTooltip:AddLine(string.format("%s: %s", prefix, cName), 1, 0.82, 0)
            GameTooltip:AddLine("|cFF00FFCCClic Izquierdo:|r Cambiar a la siguiente clase.", 1, 1, 1, true)
            GameTooltip:AddLine("|cFFFF5555Clic Derecho:|r Dejar ranura en (Vacío).", 0.8, 0.8, 0.8, true)
            GameTooltip:AddLine("El optimizador descarta mejoras que dupliquen bufos de estas clases.", 0.7, 0.7, 0.7, true)
            GameTooltip:Show()
        end)
        slotBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        campingControls.slotButtons[slotIdx] = slotBtn
    end

    -- Fila 2: Selector de Kit de Fogón (Cocina) + Botón Auto-Detectar + Resumen de optimización
    local btnCampfire = CreateFrame("Button", nil, campingControls, "UIPanelButtonTemplate")
    btnCampfire:SetPoint("TOPLEFT", campingControls, "TOPLEFT", 0, -23)
    btnCampfire:SetSize(200, 20)
    btnCampfire:SetText("|TInterface\\Icons\\spell_fire_fire:14:14:0:0|t Fogón: Oficial (5 r.)")
    btnCampfire:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btnCampfire:SetScript("OnClick", function(_, mouseBtn)
        RaidPrep:CycleCampfire(mouseBtn == "RightButton")
    end)
    btnCampfire:SetScript("OnEnter", function(selfBtn)
        GameTooltip:SetOwner(selfBtn, "ANCHOR_TOP")
        GameTooltip:AddLine("Kit de Fogón de Campamento (Cocina)", 1, 0.82, 0)
        GameTooltip:AddLine("El fogón determina cuántas mejoras de campamento pueden colocarse a la vez:", 1, 1, 1, true)
        GameTooltip:AddLine("· |cFFFFFFFFBásico:|r 3 mejoras (Cocina 1)", 0.9, 0.9, 0.9)
        GameTooltip:AddLine("· |cFF1EFF00Oficial:|r 5 mejoras (Cocina 140) - ¡Ideal Mazmorras!", 0.2, 1, 0.2)
        GameTooltip:AddLine("· |cFF0070DDExperto:|r 10 mejoras (Cocina 220) - Para Bandas", 0.4, 0.7, 1)
        GameTooltip:AddLine("Clic para cambiar el tipo de fogón.", 1, 0.82, 0)
        GameTooltip:Show()
    end)
    btnCampfire:SetScript("OnLeave", function() GameTooltip:Hide() end)
    campingControls.btnCampfire = btnCampfire

    local campfireArrow = btnCampfire:CreateTexture(nil, "OVERLAY")
    campfireArrow:SetSize(10, 10)
    campfireArrow:SetPoint("RIGHT", btnCampfire, "RIGHT", -6, 0)
    campfireArrow:SetTexture("Interface\\AddOns\\AwakeningCompanion\\Media\\Icons\\arrow_down.tga")
    btnCampfire.arrow = campfireArrow

    -- Botón Auto-Detectar Grupo
    local btnAutoScan = CreateFrame("Button", nil, campingControls, "UIPanelButtonTemplate")
    btnAutoScan:SetPoint("LEFT", btnCampfire, "RIGHT", 4, 0)
    btnAutoScan:SetSize(125, 20)
    btnAutoScan:SetText("|TInterface\\Icons\\inv_misc_groupneedmore:14:14:0:0|t Auto-Detectar")
    btnAutoScan:SetScript("OnClick", function()
        RaidPrep:ScanParty()
    end)
    btnAutoScan:SetScript("OnEnter", function(selfBtn)
        GameTooltip:SetOwner(selfBtn, "ANCHOR_TOP")
        GameTooltip:AddLine("Auto-Detectar Grupo Actual", 1, 0.82, 0)
        GameTooltip:AddLine("Lee automáticamente a los miembros de tu grupo o banda actual y asigna sus clases a las 5 ranuras.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btnAutoScan:SetScript("OnLeave", function() GameTooltip:Hide() end)
    campingControls.btnAutoScan = btnAutoScan

    local summaryText = campingControls:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    summaryText:SetPoint("LEFT", btnAutoScan, "RIGHT", 4, 0)
    summaryText:SetPoint("RIGHT", campingControls, "RIGHT", 0, 0)
    summaryText:SetJustifyH("RIGHT")
    summaryText:SetText("|cFF00FF005 miembros|r · |cFFFFD1005 slots|r")
    campingControls.summaryText = summaryText

    -- Scroll de Filas de Campamento
    local campingScroll = CreateFrame("ScrollFrame", "AwakeningCampingScroll", containerFrame, "UIPanelScrollFrameTemplate")
    campingScroll:SetPoint("TOPLEFT", containerFrame, "TOPLEFT", 2, -74)
    campingScroll:SetPoint("BOTTOMRIGHT", containerFrame, "BOTTOMRIGHT", -20, 2)
    campingScroll:Hide()
    containerFrame.campingScroll = campingScroll

    local campingContent = CreateFrame("Frame", nil, campingScroll)
    campingContent:SetSize(440, 10)
    campingScroll:SetScrollChild(campingContent)
    containerFrame.campingContent = campingContent

    -- 20 Filas de Campamento Reutilizables
    for i = 1, 20 do
        local row = CreateFrame("Button", nil, campingContent, "BackdropTemplate")
        row:SetSize(440, 22)
        row:SetPoint("TOPLEFT", campingContent, "TOPLEFT", 0, -((i - 1) * 23))

        local hl = row:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints()
        hl:SetTexture("Interface\Buttons\UI-Listbox-Highlight")
        hl:SetBlendMode("ADD")
        hl:SetAlpha(0.35)

        local sel = row:CreateTexture(nil, "BORDER")
        sel:SetAllPoints()
        sel:SetColorTexture(1, 0.82, 0, 0.15)
        sel:Hide()
        row.selection = sel

        -- Badge de Ranura / Estado ([FOGÓN #1], [EXTRA], [DESC])
        local badge = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        badge:SetPoint("LEFT", row, "LEFT", 2, 0)
        badge:SetWidth(56)
        badge:SetJustifyH("LEFT")
        row.badge = badge

        -- Icono
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(16, 16)
        icon:SetPoint("LEFT", badge, "RIGHT", 2, 0)
        icon:SetTexture("Interface\Icons\inv_misc_questionmark")
        row.icon = icon

        -- Nombre del Camp Item
        local nameLabel = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        nameLabel:SetPoint("LEFT", icon, "RIGHT", 4, 0)
        nameLabel:SetPoint("RIGHT", row, "LEFT", 195, 0)
        nameLabel:SetJustifyH("LEFT")
        nameLabel:SetWordWrap(false)
        row.nameLabel = nameLabel

        -- Profesión / Req
        local profLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        profLabel:SetPoint("LEFT", row, "LEFT", 198, 0)
        profLabel:SetPoint("RIGHT", row, "LEFT", 285, 0)
        profLabel:SetJustifyH("LEFT")
        profLabel:SetWordWrap(false)
        row.profLabel = profLabel

        -- Beneficio / Razón / Advertencia de Solapamiento
        local reasonLabel = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        reasonLabel:SetPoint("LEFT", row, "LEFT", 288, 0)
        reasonLabel:SetPoint("RIGHT", row, "RIGHT", -6, 0)
        reasonLabel:SetJustifyH("RIGHT")
        reasonLabel:SetWordWrap(false)
        row.reasonLabel = reasonLabel

        row:SetScript("OnEnter", function(selfRow)
            local itm = selfRow.itemData
            if not itm then return end
            GameTooltip:SetOwner(selfRow, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            local titleColor = itm.isConflicted and "|cFFFF5555" or (itm.isRecommended and "|cFF00FF00" or "|cFFFFD100")
            GameTooltip:AddLine(titleColor .. itm.name .. "|r (" .. itm.profession .. " " .. itm.skillReq .. ")", 1, 0.82, 0)
            GameTooltip:AddLine(itm.effectDesc or itm.effect, 1, 1, 1, true)
            GameTooltip:AddLine(" ")
            if itm.isConflicted then
                GameTooltip:AddLine("|cFFFF5555[!] Solapamiento de Buff:|r " .. (itm.conflictReason or "Duplica un beneficio de clase"), 1, 0.3, 0.3, true)
            elseif itm.isRecommended then
                GameTooltip:AddLine(string.format("|cFF00FF00[OK] Recomendado para el fogón (Ranura #%d):|r Máxima sinergia para tu grupo.", itm.slotOrder or 1), 0.2, 1, 0.2, true)
            else
                GameTooltip:AddLine("|cFFFFD100Alternativa disponible:|r Sin solapamiento, pero otras mejoras tienen mayor prioridad.", 1, 0.82, 0, true)
            end
            if itm.classCopy then
                GameTooltip:AddLine("|cFF888888Copia menor de:|r " .. itm.classCopy, 0.6, 0.6, 0.6)
            end
            local cnt = GetItemCount(itm.id, false, false) or 0
            GameTooltip:AddLine(cnt > 0 and "|cFF00FF00En tus bolsas: " .. cnt .. "|r" or "|cFFFF5555No lo tienes en tus bolsas|r")
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)

        row:SetScript("OnClick", function(selfRow)
            RaidPrep.selectedCampIndex = i
            RaidPrep:SelectCampItem(selfRow.itemData)
            for idx, r in ipairs(campingRowFrames) do
                if r.selection then r.selection:SetShown(idx == i) end
            end
        end)

        campingRowFrames[i] = row
    end

    RaidPrep:Update()
    return containerFrame
end

-- =========================================================================
-- ALTERNANCIA DE SUB-MODO (CONSUMIBLES VS CAMPAMENTO ÓPTIMO)
-- =========================================================================
function RaidPrep:SetSubMode(mode)
    self.currentSubMode = mode or "consumables"

    if containerFrame then
        if self.currentSubMode == "camping" then
            containerFrame.controls:Hide()
            containerFrame.scroll:Hide()
            containerFrame.campingControls:Show()
            containerFrame.campingScroll:Show()
            if containerFrame.subBar then
                containerFrame.subBar.btnConsumables:SetText("|TInterface\\Icons\\inv_potion_52:14:14:0:0|t Consumibles Personales")
                containerFrame.subBar.btnCamping:SetText("|cFFFFD100|TInterface\\Icons\\spell_fire_fire:14:14:0:0|t Campamento Óptimo|r")
            end
            self:UpdateCamping()
        else
            containerFrame.controls:Show()
            containerFrame.scroll:Show()
            containerFrame.campingControls:Hide()
            containerFrame.campingScroll:Hide()
            if containerFrame.subBar then
                containerFrame.subBar.btnConsumables:SetText("|cFFFFD100|TInterface\\Icons\\inv_potion_52:14:14:0:0|t Consumibles Personales|r")
                containerFrame.subBar.btnCamping:SetText("|TInterface\\Icons\\spell_fire_fire:14:14:0:0|t Campamento Óptimo")
            end
            self:UpdateConsumables()
        end
    end

    if ns.MainUI and ns.MainUI.UpdatePrepTabButtons then
        ns.MainUI:UpdatePrepTabButtons()
    end
end

-- =========================================================================
-- ALTERNANCIA DE CLASES EN LAS 5 RANURAS DE EQUIPO
-- =========================================================================
function RaidPrep:CycleSlotClass(slotIdx, isRightClick)
    if isRightClick then
        self.partyClasses[slotIdx] = "NONE"
    else
        local cur = self.partyClasses[slotIdx] or "NONE"
        local curIdx = 1
        for idx, c in ipairs(CLASS_CYCLE) do
            if c == cur then
                curIdx = idx
                break
            end
        end
        local nextIdx = (curIdx % #CLASS_CYCLE) + 1
        self.partyClasses[slotIdx] = CLASS_CYCLE[nextIdx]
    end
    self.selectedCampIndex = 1
    self:UpdateCamping()
end

-- =========================================================================
-- ALTERNANCIA DE KITS DE FOGÓN (BÁSICO, OFICIAL, EXPERTO)
-- =========================================================================
function RaidPrep:CycleCampfire(isRightClick)
    local fires = { "basic", "journeyman", "expert" }
    local curIdx = 2
    for idx, k in ipairs(fires) do
        if k == self.selectedCampfireKey then
            curIdx = idx
            break
        end
    end
    if isRightClick then
        curIdx = curIdx - 1
        if curIdx < 1 then curIdx = #fires end
    else
        curIdx = (curIdx % #fires) + 1
    end
    self.selectedCampfireKey = fires[curIdx]
    self.selectedCampIndex = 1
    self:UpdateCamping()
end

-- =========================================================================
-- AUTO-DETECCIÓN DE MIEMBROS DE GRUPO / BANDA
-- =========================================================================
function RaidPrep:ScanParty()
    local _, myClass = UnitClass("player")
    self.partyClasses[1] = myClass or "WARRIOR"

    local numMembers = GetNumGroupMembers() or 0
    local detected = 1

    if IsInRaid() and numMembers > 0 then
        local idx = 2
        for i = 1, numMembers do
            local name, _, _, _, _, fileName = GetRaidRosterInfo(i)
            if fileName and not UnitIsUnit("raid" .. i, "player") and idx <= 5 then
                self.partyClasses[idx] = fileName
                idx = idx + 1
                detected = detected + 1
            end
        end
        while idx <= 5 do
            self.partyClasses[idx] = "NONE"
            idx = idx + 1
        end
        ns.Print(string.format("Campamento: |cFF00FF00%d miembros de banda|r escaneados y asignados.", detected))
    elseif numMembers > 0 then
        local idx = 2
        for i = 1, 4 do
            local unit = "party" .. i
            if UnitExists(unit) then
                local _, uClass = UnitClass(unit)
                if uClass then
                    self.partyClasses[idx] = uClass
                    idx = idx + 1
                    detected = detected + 1
                end
            end
        end
        while idx <= 5 do
            self.partyClasses[idx] = "NONE"
            idx = idx + 1
        end
        ns.Print(string.format("Campamento: |cFF00FF00%d miembros de grupo|r escaneados y asignados.", detected))
    else
        for i = 2, 5 do
            self.partyClasses[i] = "NONE"
        end
        ns.Print("Campamento: Jugando en solitario. Ranura 1 asignada a tu clase.")
    end

    self:UpdateCamping()
end

-- =========================================================================
-- TRANSMITIR CAMPAMENTO ÓPTIMO AL CANAL DE GRUPO / BANDA
-- =========================================================================
function RaidPrep:BroadcastCamp()
    local fullList, recommended, discarded, selectedFire, partyCount = self:GetOptimizedCampingList()
    local fireName = selectedFire and selectedFire.name or "Fogón"
    local maxSlots = selectedFire and selectedFire.slots or 5

    local channel = IsInRaid() and "RAID" or (IsInGroup() and "PARTY" or nil)

    if channel then
        SendChatMessage(string.format("=== [Awakening] Campamento Óptimo (%s: %d ranuras) ===", fireName, maxSlots), channel)
        for i, item in ipairs(recommended) do
            SendChatMessage(string.format("%d. %s (%s, req %d): %s", i, item.name, item.profession, item.skillReq or 20, item.effect), channel)
        end
        if #discarded > 0 then
            local discNames = {}
            for _, d in ipairs(discarded) do
                table.insert(discNames, d.name)
            end
            SendChatMessage("Descartados por solapamiento de clase: " .. table.concat(discNames, ", "), channel)
        end
        ns.Print(ns.Green(string.format("Campamento Óptimo transmitido al canal de %s.", channel == "RAID" and "Banda" or "Grupo")))
    else
        ns.Print(ns.Gold(string.format("=== [Awakening] Campamento Óptimo (%s: %d ranuras) ===", fireName, maxSlots)))
        for i, item in ipairs(recommended) do
            ns.Print(string.format("|cFF00FF00%d. %s|r (|cFFFFD100%s|r): %s", i, item.name, item.profession, item.effect))
        end
        if #discarded > 0 then
            local discNames = {}
            for _, d in ipairs(discarded) do
                table.insert(discNames, d.name .. " (" .. (CLASS_NAMES_ES[d.conflictClass] or d.conflictClass) .. ")")
            end
            ns.Print("|cFFFF5555Descartados para evitar solapamientos:|r " .. table.concat(discNames, ", "))
        end
    end
end

-- =========================================================================
-- ACTUALIZACIÓN DINÁMICA DE LA VISTA DE CAMPAMENTO
-- =========================================================================
function RaidPrep:UpdateCamping()
    local fullList, recommended, discarded, selectedFire, partyCount = self:GetOptimizedCampingList()
    local mainFrame = ns.MainUI and ns.MainUI.frame

    -- Actualizar botones de clases de las 5 ranuras
    if containerFrame and containerFrame.campingControls and containerFrame.campingControls.slotButtons then
        for idx = 1, 5 do
            local btn = containerFrame.campingControls.slotButtons[idx]
            local cKey = self.partyClasses[idx] or "NONE"
            local cName = CLASS_NAMES_ES[cKey] or cKey
            local cColor = CLASS_COLORS[cKey] or "888888"
            if cKey == "NONE" then
                btn:SetText("|cFF888888(Vacío)|r")
            else
                if idx == 1 then
                    btn:SetText(string.format("|cFF%s(Tú) %s|r", cColor, cName))
                else
                    btn:SetText(string.format("|cFF%s%s|r", cColor, cName))
                end
            end
        end

        local fireName = selectedFire and selectedFire.name:gsub("Kit de fogón ", "") or "Oficial"
        local fireSlots = selectedFire and selectedFire.slots or 5
        containerFrame.campingControls.btnCampfire:SetText(string.format("|TInterface\\Icons\\spell_fire_fire:14:14:0:0|t Fogón: %s (%d r.)", fireName, fireSlots))

        local conflictCount = #discarded
        containerFrame.campingControls.summaryText:SetText(string.format(
            "|cFF00FF00%d miembros|r · |cFFFFD100%d slots|r · |cFF%s%d solapados evitados|r",
            partyCount,
            fireSlots,
            conflictCount > 0 and "FF5555" or "00FF00",
            conflictCount
        ))
    end

    -- Poblar filas de campamento
    for i, row in ipairs(campingRowFrames) do
        local itemData = fullList[i]
        if itemData then
            row.itemData = itemData
            row:Show()

            local count = GetItemCount(itemData.id, false, false) or 0
            local countTag = count > 0 and "|TInterface\\RaidFrame\\ReadyCheck-Ready:12:12:0:0|t " or ""

            -- Icono
            row.icon:SetTexture(itemData.icon or "Interface\Icons\inv_misc_questionmark")

            -- Badge y Colores
            if itemData.isConflicted then
                row.badge:SetText("|cFFFF5555[DESC]|r")
                row.nameLabel:SetText("|cFF888888" .. itemData.name .. "|r")
                row.profLabel:SetText("|cFF888888" .. itemData.profession .. " (" .. itemData.skillReq .. ")|r")
                local confName = CLASS_NAMES_ES[itemData.conflictClass] or itemData.conflictClass or "Clase"
                row.reasonLabel:SetText(string.format("|cFFFF5555[!] Solapa con %s|r", confName))
            elseif itemData.isRecommended then
                row.badge:SetText(string.format("|cFF00FF00[FOGÓN #%d]|r", itemData.slotOrder or 1))
                row.nameLabel:SetText(countTag .. "|cFFFFFFFF" .. itemData.name .. "|r")
                row.profLabel:SetText("|cFFFFD100" .. itemData.profession .. " (" .. itemData.skillReq .. ")|r")
                row.reasonLabel:SetText("|cFF00FF00" .. itemData.effect .. "|r")
            else
                row.badge:SetText("|cFFFFCC00[EXTRA]|r")
                row.nameLabel:SetText(countTag .. "|cFFFFFFFF" .. itemData.name .. "|r")
                row.profLabel:SetText("|cFF888888" .. itemData.profession .. " (" .. itemData.skillReq .. ")|r")
                row.reasonLabel:SetText("|cFFFFCC00" .. itemData.effect .. "|r")
            end

            row.selection:SetShown(i == self.selectedCampIndex)
        else
            row.itemData = nil
            row:Hide()
        end
    end

    if containerFrame and containerFrame.campingContent then
        containerFrame.campingContent:SetHeight(math.max(10, #fullList * 23))
    end

    -- Encabezado dinámico Hero estilo Olympus
    if mainFrame and mainFrame.heroTitle then
        local fireName = selectedFire and selectedFire.name or "Fogón"
        mainFrame.heroTitle:SetText(string.format(
            "|cFFFFD100Campamento Óptimo|r · %s (|cFF00FF00%d/%d ranuras|r)",
            fireName,
            #recommended,
            selectedFire and selectedFire.slots or 5
        ))
    end

    -- Actualizar selección en detalle
    if fullList[self.selectedCampIndex] then
        self:SelectCampItem(fullList[self.selectedCampIndex])
    elseif fullList[1] then
        self.selectedCampIndex = 1
        self:SelectCampItem(fullList[1])
    end
end

-- =========================================================================
-- DETALLES DEL ITEM DE CAMPAMENTO EN EL PANEL INFERIOR
-- =========================================================================
function RaidPrep:SelectCampItem(campItem)
    if not campItem then return end
    local mainFrame = ns.MainUI and ns.MainUI.frame
    if not mainFrame then return end

    local count = GetItemCount(campItem.id, false, false) or 0
    local statusStr = (count > 0)
        and string.format("|cFF00FF00En tus bolsas (%d)|r", count)
        or "|cFFFF5555No lo tienes en tus bolsas (craftear o pedir a aliado)|r"

    local name, link, quality, texture = SafeGetItem(campItem.id)
    local nameStr = link or campItem.name or name or ("Objeto #" .. campItem.id)
    local q = quality or 2

    if mainFrame.detailTitle and mainFrame.detailText then
        mainFrame.detailTitle:SetText(string.format("%s · |cFFFFD100%s (Tier %d)|r", nameStr, campItem.profession, campItem.tier or 1))

        local rewardItem = {
            {
                itemID = campItem.id,
                name = nameStr,
                quality = q,
                count = 1,
                desc = string.format("Beneficio: %s · Req: %s (%d)", campItem.effect or "Campamento", campItem.profession, campItem.skillReq or 20),
                extraLines = {
                    { text = "Copia bufo de clase: " .. (campItem.classCopy or "Ninguno"), r = 0.5, g = 0.9, b = 1, wrap = true },
                    { text = campItem.isConflicted and ("[!] " .. (campItem.conflictReason or "Solapamiento")) or ("Óptimo: " .. (campItem.effectDesc or campItem.effect)), r = campItem.isConflicted and 1 or 0.2, g = campItem.isConflicted and 0.3 or 1, b = 0.2, wrap = true },
                    { text = "Inventario: " .. statusStr, r = 1, g = 0.82, b = 0, wrap = false }
                }
            }
        }
        if ns.MainUI.ShowDetailRewards then
            ns.MainUI:ShowDetailRewards(rewardItem, "|cFFFFD100Mejora de Campamento:|r")
        end

        local conflictNotice = campItem.isConflicted
            and ("|cFFFF5555[!] DESCARTADO POR CONFLICTO:|r " .. (campItem.conflictReason or "Solapamiento") .. "\n")
            or "|cFF00FF00[OK] RECOMENDADO PARA EL FOGÓN:|r No colisiona con ningún bufo de las clases de tu grupo.\n"

        mainFrame.detailText:SetText(
            "Efecto de Campamento: |cFF00FF00" .. (campItem.effect or "Beneficio de campamento") .. "|r\n" ..
            "Profesión Requerida: |cFFFFD100" .. (campItem.profession or "Profesión") .. " (Habilidad " .. (campItem.skillReq or 20) .. ")|r · Fuente: |cFF00FFCC" .. (campItem.source or "Instructor de profesión") .. "|r\n" ..
            conflictNotice ..
            "Bufo de clase equivalente: |cFFFFFFFF" .. (campItem.classCopy or "Ninguno (Efecto único)") .. "|r\n" ..
            "Cómo usarlo: |cFFFFFFFFColócalo junto al fogón y descansa (/sit) o fabrica objetos durante 1 minuto para recibir 1 hora de beneficio.|r\n" ..
            "Estado en bolsas: " .. statusStr
        )
    end
end

-- =========================================================================
-- ACTUALIZACIÓN DE CONSUMIBLES PERSONALES
-- =========================================================================
function RaidPrep:UpdateConsumables()
    local list, bracketData, activeSpec = self:GetConsumablesList()
    local mainFrame = ns.MainUI and ns.MainUI.frame

    -- Precarga de datos de objetos
    for _, item in ipairs(list) do
        if SafeGetItem(item.id) == nil and C_Item and C_Item.RequestLoadItemDataByID then
            pcall(C_Item.RequestLoadItemDataByID, item.id)
        end
    end

    local readyCount = 0
    local totalCount = #list

    for i, row in ipairs(rowFrames) do
        local itemData = list[i]
        if itemData then
            row.itemData = itemData
            row:Show()

            local count = GetItemCount(itemData.id, false, false) or 0
            local isReady = (count >= itemData.minCount)
            if isReady then readyCount = readyCount + 1 end

            -- Icono
            local name, link, quality, texture = SafeGetItem(itemData.id)
            row.icon:SetTexture(texture or itemData.icon or "Interface\Icons\inv_potion_52")

            -- Calidad y color
            local qc = "|cFFFFFFFF"
            local q = quality or itemData.quality or 1
            if q == 4 then qc = "|cFFA335EE"
            elseif q == 3 then qc = "|cFF0070DD"
            elseif q == 2 then qc = "|cFF1EFF00"
            end

            local displayName = link or (qc .. (name or itemData.name) .. "|r")
            row.nameLabel:SetText(string.format("%s |cFF888888(x%d)|r", displayName, itemData.minCount))

            -- Categoría / Efecto (oculto en la lista de consumibles; disponible en tooltip)
            if row.catLabel then
                row.catLabel:Hide()
            end

            -- Estado semafórico
            if isReady then
                row.statusLabel:SetText(string.format("|cFF00FF00Listo (%d/%d)|r", count, itemData.minCount))
            elseif count > 0 then
                row.statusLabel:SetText(string.format("|cFFFFCC00Faltan %d (%d/%d)|r", itemData.minCount - count, count, itemData.minCount))
            else
                row.statusLabel:SetText(string.format("|cFFFF5555Faltan %d (0/%d)|r", itemData.minCount, itemData.minCount))
            end

            row.selection:SetShown(i == selectedIndex)
        else
            row.itemData = nil
            row:Hide()
        end
    end

    if containerFrame and containerFrame.content then
        containerFrame.content:SetHeight(math.max(10, #list * 23))
    end

    -- Actualizar Botones de Control
    if containerFrame then
        local pLvl = UnitLevel("player") or 1
        local modeText = previewRaidMode and "Modo: Banda / Raid (Nv. 60)"
            or (pLvl >= 60 and "Banda/Raid (60)" or ("Leveleo (" .. bracketData.short .. ")"))
        if containerFrame.modeBtn then
            containerFrame.modeBtn:SetText(modeText)
        end
        if containerFrame.specBtn and activeSpec then
            containerFrame.specBtn:SetText(activeSpec.name:gsub("%s*%(.-%)", ""))
        end
    end

    -- Actualizar Encabezado Dinámico Hero estilo Olympus (Clase y Nivel del Jugador)
    local localizedClass, playerClass = UnitClass("player")
    localizedClass = localizedClass or playerClass or "Aventurero"
    local playerLevel = UnitLevel("player") or 1
    local pct = (totalCount > 0) and math.floor((readyCount / totalCount) * 100) or 0

    if mainFrame and mainFrame.heroTitle then
        mainFrame.heroTitle:SetText(string.format(
            "|cFFFFD100Preparación %s (%d)|r · |cFFFFFFFF%d/%d (%d%%)|r",
            localizedClass,
            playerLevel,
            readyCount,
            totalCount,
            pct
        ))
    end

    -- Actualizar Selección Activa en la caja de detalles
    if list[selectedIndex] then
        self:SelectConsumable(list[selectedIndex])
    elseif list[1] then
        selectedIndex = 1
        self:SelectConsumable(list[1])
    end
end

-- =========================================================================
-- ROUTER PRINCIPAL DE ACTUALIZACIÓN SEGÚN SUB-MODO
-- =========================================================================
function RaidPrep:Update()
    if self.currentSubMode == "camping" then
        self:UpdateCamping()
    else
        self:UpdateConsumables()
    end
end

-- =========================================================================
-- DETALLES DEL CONSUMIBLE EN EL PANEL INFERIOR
-- =========================================================================
function RaidPrep:SelectConsumable(itemData)
    if not itemData then return end
    local mainFrame = ns.MainUI and ns.MainUI.frame
    if not mainFrame then return end

    local count = GetItemCount(itemData.id, false, false) or 0
    local isReady = (count >= itemData.minCount)
    local statusStr = isReady
        and string.format("|cFF00FF00Completado en tus bolsas (%d/%d)|r", count, itemData.minCount)
        or (count > 0 and string.format("|cFFFFCC00Cantidad insuficiente en bolsas (%d/%d)|r", count, itemData.minCount)
        or string.format("|cFFFF5555Pendiente de conseguir (Faltan %d)|r", itemData.minCount))

    local name, link, quality, texture = SafeGetItem(itemData.id)
    local nameStr = link or itemData.name or name or ("Objeto #" .. itemData.id)
    local q = quality or itemData.quality or 1

    local dynEffect = self:GetDynamicItemEffect(itemData.id)
    local effDisplay = dynEffect or itemData.effect or "Mejora de estadísticas"

    if mainFrame.detailTitle and mainFrame.detailText then
        mainFrame.detailTitle:SetText(string.format("%s · |cFFFFD100%s|r", nameStr, itemData.category or "Consumible"))

        local rewardItem = {
            {
                itemID = itemData.id,
                name = nameStr,
                quality = q,
                count = itemData.minCount,
                desc = string.format("Efecto: %s · Cantidad requerida: %d", effDisplay, itemData.minCount),
                extraLines = {
                    { text = "Por qué se recomienda: " .. (itemData.tip or "Consumible óptimo para tu rol"), r = 0.5, g = 0.9, b = 1, wrap = true },
                    { text = "Inventario: " .. statusStr, r = 1, g = 0.82, b = 0, wrap = false }
                }
            }
        }
        if ns.MainUI.ShowDetailRewards then
            ns.MainUI:ShowDetailRewards(rewardItem, "|cFFFFD100Consumible Requerido:|r")
        end

        mainFrame.detailText:SetText(
            "Efecto Óptimo: |cFF00FF00" .. effDisplay .. "|r  ·  Categoría: |cFFFFFFFF" .. (itemData.category or "Consumible") .. "|r\n" ..
            "Por qué se recomienda: |cFFFFD100" .. (itemData.tip or "Recomendado para máxima eficiencia en tu rol.") .. "|r\n" ..
            "Cómo obtenerlo: |cFF00FFCC" .. (itemData.source or "Alquimia / Cocina / Subasta / Vendedores de suministros") .. "|r\n" ..
            "Estado en bolsas: " .. statusStr
        )
    end
end

-- =========================================================================
-- ALTERNANCIA DE RAMAS / ESPECIALIZACIÓN
-- =========================================================================
function RaidPrep:CycleSpec(isRightClick)
    local _, playerClass = UnitClass("player")
    playerClass = playerClass or "WARRIOR"

    local specsList
    if isRightClick then
        specsList = {}
        for _, cSpecs in pairs(SPECS_BY_CLASS) do
            for _, s in ipairs(cSpecs) do
                table.insert(specsList, s)
            end
        end
    else
        specsList = self:GetSpecsForClass(playerClass)
    end

    local currentSpec = self:GetPlayerActiveSpec(playerClass)
    local currentIdx = 1
    for idx, s in ipairs(specsList) do
        if s.key == currentSpec.key then
            currentIdx = idx
            break
        end
    end

    local nextIdx = (currentIdx % #specsList) + 1
    self.selectedSpecKey = specsList[nextIdx].key
    selectedIndex = 1
    self:Update()
end

-- =========================================================================
-- ANUNCIAR ESTADO EN EL CANAL DE HERMANDAD
-- =========================================================================
function RaidPrep:BroadcastStatus()
    local list, bracketData, activeSpec = self:GetConsumablesList()
    local readyCount = 0
    local totalCount = #list

    for _, item in ipairs(list) do
        local count = GetItemCount(item.id, false, false) or 0
        if count >= item.minCount then
            readyCount = readyCount + 1
        end
    end

    local pct = (totalCount > 0) and math.floor((readyCount / totalCount) * 100) or 0

    if ns.Comms and ns.Comms.BroadcastPrepStatus then
        ns.Comms:BroadcastPrepStatus(readyCount, totalCount)
    end

    local specName = activeSpec and activeSpec.name or "Especialización"
    local statusMsg = string.format("Preparación (%s): %d de %d consumibles listos (%d%%).", specName, readyCount, totalCount, pct)
    if readyCount == totalCount then
        ns.Print(ns.Green(statusMsg))
    else
        ns.Print(ns.Gold(statusMsg))
    end
end

function RaidPrep:Show()
    if containerFrame then
        containerFrame:Show()
        self:Update()
    end
end

function RaidPrep:Hide()
    if containerFrame then
        containerFrame:Hide()
    end
end

function RaidPrep:ScanInventory()
    self:Update()
end
