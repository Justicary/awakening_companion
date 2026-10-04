-- =========================================================================
-- Awakening Companion - Data/SecretsData.lua
-- Base de datos de secretos clásicos, cadenas de viaje y recompensas únicas
-- Guía exhaustiva del Saco de Dormir Acogedor (Cozy Sleeping Bag) según Wowhead
-- =========================================================================
local ADDON, ns = ...

ns.Data = ns.Data or {}

-- -------------------------------------------------------------------------
-- PASOS PARA LA ALIANZA: COZY SLEEPING BAG (7 HITOS COMPLETOS)
-- -------------------------------------------------------------------------
ns.Data.SleepingBagStepsAlliance = {
    [1] = {
        stepNum = 1,
        title = "1. Carreta Calcinada (Páramos de Poniente)",
        instruction = "Ve a la Granja Alexston en Páramos de Poniente (37.5, 50.8). En los restos de la carreta calcinada, interactúa con los 'Restos calcinados' para obtener la misión inicial: '...y esa nota que encontraste'.",
        uiMapID = 1436, -- Westfall
        zoneName = "Páramos de Poniente",
        x = 37.5,
        y = 50.8,
        questID = 79008,
        action = "Aceptar misión inicial",
        tip = "Consejo Wowhead: La nota apunta a que los viajeros venían o se dirigían a Los Baldíos con suministros.",
        icon = "Interface\\Icons\\spell_fire_fire"
    },
    [2] = {
        stepNum = 2,
        title = "2. Torre Calcinada (Los Baldíos)",
        instruction = "Sigue el camino al sur del Campamento Taurajo en Los Baldíos (46.4, 73.9). En los escombros de la torre vigía destruida, interactúa con los 'Restos calcinados' para entregar '...y esa nota que encontraste' y acepta 'Peldaños de piedra'.",
        uiMapID = 1413, -- The Barrens
        zoneName = "Los Baldíos",
        x = 46.4,
        y = 73.9,
        questID = 79008,
        nextQuestID = 79192,
        action = "Entregar 79008 y aceptar 79192",
        tip = "Alerta Alianza: Taurajo es territorio Horda. Pasa con precaución por las colinas al este para evitar a los guardias.",
        icon = "Interface\\Icons\\inv_misc_note_01"
    },
    [3] = {
        stepNum = 3,
        title = "3. Campamento en la Cima (Sierra Espolón)",
        instruction = "Toma la senda oculta al noreste de Refugio Roca del Sol (50.9, 52.3) y sube hasta el campamento abandonado (40.6, 52.4). Clic en la 'Basura de bolsillo' sobre una caja para entregar 'Peldaños de piedra' y aceptar 'Trepar'.",
        uiMapID = 1440, -- Stonetalon Mountains
        zoneName = "Sierra Espolón",
        x = 40.6,
        y = 52.4,
        trailX = 50.9,
        trailY = 52.3,
        questID = 79192,
        nextQuestID = 79980,
        action = "Entregar 79192 y aceptar 79980",
        tip = "Recompensa: 1x Forraje de estudiante (+4 barras de Exp descansada) + Madera y Yesca. Opcional: Enciende la fogata para completar 'Reavivar' (80001).",
        icon = "Interface\\Icons\\inv_misc_food_pinenut"
    },
    [4] = {
        stepNum = 4,
        title = "4. Salto al Risco (Sierra Espolón)",
        instruction = "Desde el campamento, camina al norte hacia el borde del precipicio (39.6, 49.8). Salta con cuidado a la cornisa del risco e interactúa con el 'Montículo de tierra' para entregar 'Trepar' y aceptar 'Trabajo húmedo'.",
        uiMapID = 1440, -- Stonetalon Mountains
        zoneName = "Sierra Espolón",
        x = 39.6,
        y = 49.8,
        questID = 79980,
        nextQuestID = 79974,
        action = "Entregar 79980 y aceptar 79974",
        tip = "Recompensa: ¡Fiambrera resistente (bolsa de 12 casillas)! Cuidado al saltar para no caer al vacío.",
        icon = "Interface\\Icons\\inv_box_01"
    },
    [5] = {
        stepNum = 5,
        title = "5. Presa de las Tres Cabezas (Loch Modan)",
        instruction = "Viaja a la gran presa de Loch Modan (49.4, 12.9). Camina sobre las cabezas talladas en la pared exterior mirando a Los Humedales. Haz clic en la 'Estatuilla de águila' para entregar 'Trabajo húmedo' y aceptar 'Puño del Águila'.",
        uiMapID = 1432, -- Loch Modan
        zoneName = "Loch Modan",
        x = 49.4,
        y = 12.9,
        questID = 79974,
        nextQuestID = 79975,
        action = "Entregar 79974 y aceptar 79975",
        tip = "Recompensa: Otro Forraje de estudiante (+4 barras de Exp descansada).",
        icon = "Interface\\Icons\\inv_misc_statue_01"
    },
    [6] = {
        stepNum = 6,
        title = "6. Muralla de Thoradin - Parkour (Trabalomas)",
        instruction = "En la Muralla de Thoradin al este de Trabalomas (87.3, 49.6), salta sobre la carreta rota y trepa por los bloques caídos a la sala superior del muro. Clic en la 'Bolsa de mensajero' colgada para entregar 'Puño del Águila' y aceptar 'Este debe ser el lugar'.",
        uiMapID = 1424, -- Hillsbrad Foothills
        zoneName = "Laderas de Trabalomas",
        x = 87.3,
        y = 49.6,
        questID = 79975,
        nextQuestID = 79976,
        action = "Entregar 79975 y aceptar 79976",
        tip = "Parkour: Salta sin montura sobre la carreta, luego al borde roto del pilar para acceder a la sala del muro.",
        icon = "Interface\\Icons\\inv_misc_bag_07"
    },
    [7] = {
        stepNum = 7,
        title = "7. Reclamar el Saco Acogedor (Muralla de Thoradin)",
        instruction = "En el suelo de esa misma sala de la Muralla de Thoradin, justo debajo de la bolsa de mensajero, haz clic en el 'Fardo enrollado a toda prisa'. ¡Entrega la misión final para reclamar tu Saco de dormir acogedor!",
        uiMapID = 1424, -- Hillsbrad Foothills
        zoneName = "Laderas de Trabalomas",
        x = 87.3,
        y = 49.6,
        questID = 79976,
        action = "Completar cadena y recibir el Saco",
        tip = "¡Conseguido! Úsalo al aire libre y descansa encima: otorga +1% de Exp acumulada por minuto de sueño (máximo +3% por 2 horas).",
        icon = "Interface\\Icons\\inv_misc_bag_bigbagofenchantments"
    }
}

-- -------------------------------------------------------------------------
-- PASOS PARA LA HORDA: COZY SLEEPING BAG (7 HITOS COMPLETOS)
-- -------------------------------------------------------------------------
ns.Data.SleepingBagStepsHorde = {
    [1] = {
        stepNum = 1,
        title = "1. Torre Calcinada (Los Baldíos)",
        instruction = "Sigue el camino al sur del Campamento Taurajo en Los Baldíos (46.4, 73.9). En los escombros de la torre vigía quemada, interactúa con los 'Restos calcinados' para obtener la misión inicial: '...y esa nota que encontraste'.",
        uiMapID = 1413, -- The Barrens
        zoneName = "Los Baldíos",
        x = 46.4,
        y = 73.9,
        questID = 79007,
        action = "Aceptar misión inicial",
        tip = "Consejo Wowhead: La nota menciona un ataque y te dirige hacia la Granja Alexston en Páramos de Poniente.",
        icon = "Interface\\Icons\\spell_fire_fire"
    },
    [2] = {
        stepNum = 2,
        title = "2. Carreta Destruida (Páramos de Poniente)",
        instruction = "Viaja a Páramos de Poniente hasta la Granja Alexston (37.5, 50.8). En los restos calcinados de la carreta volcada, entrega '...y esa nota que encontraste' y acepta la siguiente misión: 'Peldaños de piedra'.",
        uiMapID = 1436, -- Westfall
        zoneName = "Páramos de Poniente",
        x = 37.5,
        y = 50.8,
        questID = 79007,
        nextQuestID = 79192,
        action = "Entregar 79007 y aceptar 79192",
        tip = "Ruta Horda: Toma el zepelín a Bahía del Botín y cabalga hacia el norte por la costa de Páramos de Poniente.",
        icon = "Interface\\Icons\\inv_misc_note_01"
    },
    [3] = ns.Data.SleepingBagStepsAlliance[3],
    [4] = ns.Data.SleepingBagStepsAlliance[4],
    [5] = {
        stepNum = 5,
        title = "5. Presa de las Tres Cabezas (Loch Modan)",
        instruction = "Viaja a Loch Modan y camina sobre la inmensa presa (49.4, 12.9). Salta sobre las cabezas talladas en la pared exterior mirando a Los Humedales. Haz clic en la 'Estatuilla de águila' para entregar 'Trabajo húmedo' y aceptar 'Puño del Águila'.",
        uiMapID = 1432, -- Loch Modan
        zoneName = "Loch Modan",
        x = 49.4,
        y = 12.9,
        questID = 79974,
        nextQuestID = 79975,
        action = "Entregar 79974 y aceptar 79975",
        tip = "Ruta Horda: Desde Tierras Altas de Arathi o Garganta de Fuego. Evita a los guardias enanos de la presa.",
        icon = "Interface\\Icons\\inv_misc_statue_01"
    },
    [6] = ns.Data.SleepingBagStepsAlliance[6],
    [7] = ns.Data.SleepingBagStepsAlliance[7],
}

-- -------------------------------------------------------------------------
-- PASOS PARA OBTENER LOS TOMOS (WoW Forever Library Books)
-- -------------------------------------------------------------------------
ns.Data.UniqueLibraryBooks = {
    [1] = {
        stepNum = 1,
        title = "Archmage Theocritus's Research Journal",
        instruction = "Recoge el diario en el tercer piso de la Torre de Azora.",
        uiMapID = 1429, -- Bosque de Elwynn
        zoneName = "Bosque de Elwynn",
        x = 65.4,
        y = 70.1,
        questID = 79001,
        action = "Despojar libro",
        tip = "Dentro de la torre, sube por las escaleras hasta la mesa de la tercera planta.",
        icon = "Interface\\Icons\\inv_misc_book_09"
    },
    [2] = {
        stepNum = 2,
        title = "Bewitchments and Glamours",
        instruction = "Recoge el libro en la primera casa entrando a Arroyo de la Luna.",
        uiMapID = 1436, -- Páramos de Poniente
        zoneName = "Páramos de Poniente",
        x = 45.4,
        y = 70.5,
        questID = 79002,
        action = "Despojar libro",
        tip = "Ubicado dentro de Moonbrook, en la casa del lado este.",
        icon = "Interface\\Icons\\inv_misc_book_06"
    },
    [3] = {
        stepNum = 3,
        title = "Rumi of Gnomeregan: The Collected Works",
        instruction = "Recoge el tomo en la posada de Colina del Centinela (o en Thelsamar).",
        uiMapID = 1436, -- Páramos de Poniente
        zoneName = "Páramos de Poniente",
        x = 52.7,
        y = 53.8,
        questID = 79003,
        action = "Despojar libro",
        tip = "Está detrás del tabernero. Nota: Comparte ID con la copia de Loch Modan (35.6, 48.9); solo puedes despojar uno de los dos.",
        icon = "Interface\\Icons\\inv_misc_book_07"
    },
    [4] = {
        stepNum = 4,
        title = "Crimes Against Anatomy",
        instruction = "Entra a la cripta de Colina del Cuervo y recoge el libro sobre el banco.",
        uiMapID = 1431, -- Bosque del Ocaso
        zoneName = "Bosque del Ocaso",
        x = 16.7,
        y = 28.5,
        questID = 79004,
        action = "Despojar libro",
        tip = "Entra por el acceso más al oeste del cementerio y baja las escaleras hasta el fondo.",
        icon = "Interface\\Icons\\inv_misc_book_11"
    },
    [5] = {
        stepNum = 5,
        title = "Runes of the Sorcerer-Kings",
        instruction = "Explora la cueva de ogros en Loch Modan y despoja el tomo.",
        uiMapID = 1432, -- Loch Modan
        zoneName = "Loch Modan",
        x = 77.5,
        y = 14.1,
        questID = 79005,
        action = "Despojar libro",
        tip = "Dentro de la cueva toma el camino de la izquierda custodiado por dos ogros.",
        icon = "Interface\\Icons\\spell_holy_magicalsentry"
    },
    [6] = {
        stepNum = 6,
        title = "Goaz Scrolls",
        instruction = "Despoja los pergaminos en el sitio de excavación de Los Humedales.",
        uiMapID = 1437, -- Los Humedales
        zoneName = "Los Humedales",
        x = 33.6,
        y = 47.9,
        questID = 79006,
        action = "Despojar pergamino",
        tip = "Nivel inferior del yacimiento; pégate al muro de la derecha al descender.",
        icon = "Interface\\Icons\\inv_misc_note_06"
    },
    [7] = {
        stepNum = 7,
        title = "Archmage Antonidas: The Unabridged Autobiography",
        instruction = "Recoge la autobiografía en la Sala de Expedicionarios.",
        uiMapID = 1455, -- Forjaz
        zoneName = "Forjaz",
        x = 75.7,
        y = 10.5,
        questID = 79007,
        action = "Despojar libro",
        tip = "Sobre la mesa grande en la Sala de Expedicionarios (puedes necesitar sigilo/cuerpo a tierra si eres Horda).",
        icon = "Interface\\Icons\\inv_misc_book_02"
    },
    [8] = {
        stepNum = 8,
        title = "The Apothecary's Metaphysical Primer",
        instruction = "Recoge el libro en la tienda de alquimia de Remol.",
        uiMapID = 1420, -- Claros de Tirisfal
        zoneName = "Claros de Tirisfal",
        x = 59.4,
        y = 52.3,
        questID = 79008,
        action = "Despojar libro",
        tip = "En Brill/Remol, sobre la estantería nada más cruzar la puerta de la tienda de alquimia.",
        icon = "Interface\\Icons\\inv_potion_51"
    },
    [9] = {
        stepNum = 9,
        title = "The Dalaran Digest, Vol. 23",
        instruction = "Recoge el ejemplar en el Molino de Ámbar.",
        uiMapID = 1421, -- Bosque de Argénteos
        zoneName = "Bosque de Argénteos",
        x = 63.5,
        y = 63.1,
        questID = 79009,
        action = "Despojar libro",
        tip = "Edificio central amurallado de Amber Mill. Para la Alianza los PNJ son neutrales.",
        icon = "Interface\\Icons\\inv_misc_book_04"
    },
    [10] = {
        stepNum = 10,
        title = "Arcanic Systems Manual",
        instruction = "Sube a la plataforma petrolífera en Los Baldíos.",
        uiMapID = 1413, -- Los Baldíos
        zoneName = "Los Baldíos",
        x = 56.3,
        y = 8.8,
        questID = 79010,
        action = "Despojar manual",
        tip = "En la sala de control en lo más alto de la plataforma.",
        icon = "Interface\\Icons\\inv_gizmo_02"
    },
    [11] = {
        stepNum = 11,
        title = "Baxtan: On Destructive Magics",
        instruction = "Recoge el libro en Bahía del Trinquete.",
        uiMapID = 1413, -- Los Baldíos
        zoneName = "Los Baldíos",
        x = 62.7,
        y = 36.3,
        questID = 79011,
        action = "Despojar libro",
        tip = "Edificio de ingeniería cerca de Gazlowe, sobre la mesa detrás del Maestro de Vuelo.",
        icon = "Interface\\Icons\\spell_fire_fire"
    },
    [12] = {
        stepNum = 12,
        title = "Secrets of the Dreamers",
        instruction = "Entra en la Caverna de las Brumas (exterior de Cuevas de los Lamentos).",
        uiMapID = 1413, -- Los Baldíos
        zoneName = "Los Baldíos",
        x = 52.8,
        y = 54.7,
        questID = 79012,
        action = "Despojar libro",
        tip = "Entrada en (46.0, 36.5). No cruces el portal de la mazmorra; está en la última sala exterior.",
        icon = "Interface\\Icons\\inv_misc_book_10"
    },
    [13] = {
        stepNum = 13,
        title = "Nar'thalas Almanac, Vol. 74",
        instruction = "Baja a las ruinas de Costa Oscura.",
        uiMapID = 1438, -- Costa Oscura
        zoneName = "Costa Oscura",
        x = 59.6,
        y = 22.2,
        questID = 79013,
        action = "Despojar almanaque",
        tip = "Baja las escaleras de las ruinas; está antes de pisar el nivel inferior inundado.",
        icon = "Interface\\Icons\\inv_misc_book_12"
    },
    [14] = {
        stepNum = 14,
        title = "Fury of the Land",
        instruction = "Revisa el campamento este en Sierra Espolón.",
        uiMapID = 1425, -- Sierra Espolón
        zoneName = "Sierra Espolón",
        x = 74.4,
        y = 85.7,
        questID = 79014,
        action = "Despojar libro",
        tip = "Encima de un barril dentro de la tienda de campaña junto al tótem grande.",
        icon = "Interface\\Icons\\spell_nature_earthquake"
    },
    [15] = {
        stepNum = 15,
        title = "The Lessons of Ta'zo",
        instruction = "Examina la tablilla rúnica en Orgrimmar.",
        uiMapID = 1454, -- Orgrimmar
        zoneName = "Orgrimmar",
        x = 38.6,
        y = 78.4,
        questID = 79015,
        action = "Interactuar con objeto",
        tip = "En Darkbriar Lodge (zona a la que llegas tras el teletransporte de mago a Orgrimmar).",
        icon = "Interface\\Icons\\inv_misc_stonetablet_02"
    },
    [16] = {
        stepNum = 16,
        title = "Entrega de los 10 Tomos (Alianza)",
        instruction = "Entrega los libros a Garion Wendell en la Torre de Magos.",
        uiMapID = 1453, -- Ciudad de Ventormenta
        zoneName = "Ciudad de Ventormenta",
        x = 37.6,
        y = 80.8,
        questID = 79000,
        action = "Completar Friend of the Library",
        tip = "Recompensa: Escoge entre Scholarly Pendant (+6 Agu, +4 Esp) o Erudite's Amulet (+4 Agi, +6 Agu).",
        icon = "Interface\\Icons\\inv_jewelry_necklace_12"
    },
    [17] = {
        stepNum = 17,
        title = "Entrega de los 10 Tomos (Horda)",
        instruction = "Entrega los libros a Owen Thadd en el Barrio de los Magos.",
        uiMapID = 1458, -- Entrañas
        zoneName = "Entrañas",
        x = 73.4,
        y = 33.0,
        questID = 79000,
        action = "Completar Friend of the Library",
        tip = "Recompensa: Escoge entre Scholarly Pendant (+6 Agu, +4 Esp) o Erudite's Amulet (+4 Agi, +6 Agu).",
        icon = "Interface\\Icons\\inv_jewelry_necklace_12"
    }
}

-- -------------------------------------------------------------------------
-- BASE DE DATOS MAESTRA DE SECRETOS
-- -------------------------------------------------------------------------
ns.Data.Secrets = {
    ["sleeping_bag"] = {
        id = "sleeping_bag",
        title = "Saco de Dormir Acogedor (Buff +3% Exp)",
        titleEn = "Cozy Sleeping Bag",
        category = "Secreto Clásico",
        faction = "Ambas",
        level = "Nivel 14 - 28",
        minLevel = 14,
        maxLevel = 28,
        reward = "Saco de dormir (+3% Exp) + Bolsa 12 casillas + 8x Forraje (+32 barras descansadas)",
        rewardItems = {
            { itemID = 211527, name = "Saco de dormir acogedor", quality = 2, icon = "Interface\\Icons\\inv_misc_bag_bigbagofenchantments", desc = "Otorga hasta +3% de Exp descansada mientras descansas en él." },
            { itemID = 211529, name = "Fiambrera resistente", quality = 2, icon = "Interface\\Icons\\inv_box_01", desc = "Bolsa de 12 casillas conseguida en Sierra Espolón." },
            { itemID = 211528, name = "Forraje de estudiante", count = 8, quality = 1, icon = "Interface\\Icons\\inv_misc_food_pinenut", desc = "Consumible: cada uno concede 4 barras de Exp descansada." },
        },
        icon = "Interface\\Icons\\inv_misc_bag_bigbagofenchantments",
        steps = ns.Data.SleepingBagStepsAlliance -- Se ajusta dinámicamente según la facción
    },
    ["library_books"] = {
        id = "library_books",
        title = "Tomos de la Biblioteca (Friend of the Library)",
        titleEn = "WoW Forever Library Books",
        category = "Secreto Clásico",
        faction = "Ambas",
        level = "Nivel 20 - 38",
        minLevel = 20,
        maxLevel = 38,
        reward = "Scholarly Pendant (+6 Agu, +4 Esp) o Erudite's Amulet (+4 Agi, +6 Agu)",
        rewardItems = {
            { itemID = 215437, name = "Colgante de erudito", quality = 3, icon = "Interface\\Icons\\inv_jewelry_necklace_12", desc = "Collar: +6 Aguante, +4 Espíritu." },
            { itemID = 215438, name = "Amuleto de erudito", quality = 3, icon = "Interface\\Icons\\inv_jewelry_necklace_12", desc = "Collar: +4 Agilidad, +6 Aguante." },
        },
        icon = "Interface\\Icons\\inv_misc_book_09",
        steps = ns.Data.UniqueLibraryBooks
    },
    ["ancient_rune"] = {
        id = "ancient_rune",
        title = "Runa de la Iluminación Arcana",
        category = "Runas & Poder",
        faction = "Ambas",
        level = "Nivel 10 - 18",
        minLevel = 10,
        maxLevel = 18,
        reward = "Runa de grabado de clase",
        rewardItems = {
            { itemID = 205423, name = "Runa de grabado arcana", quality = 3, icon = "Interface\\Icons\\spell_arcane_studentofmagic", desc = "Enseña o graba un poder arcano de clase en tu equipo." },
        },
        icon = "Interface\\Icons\\spell_arcane_studentofmagic",
        steps = {
            [1] = {
                stepNum = 1,
                title = "1. Mensajero Misterioso",
                instruction = "Habla con el viajero encapuchado que acampa en las afueras de Bosque de Elwynn (34.2, 58.7).",
                uiMapID = 1429,
                zoneName = "Bosque de Elwynn",
                x = 34.2,
                y = 58.7,
                icon = "Interface\\Icons\\inv_misc_questionmark"
            },
            [2] = {
                stepNum = 2,
                title = "2. Altar Oculto en el Risco",
                instruction = "Canaliza sobre la piedra arcana para revelar el sigilo grabado (52.6, 41.5).",
                uiMapID = 1429,
                zoneName = "Bosque de Elwynn",
                x = 52.6,
                y = 41.5,
                icon = "Interface\\Icons\\spell_holy_magicalsentry"
            }
        }
    },
    ["sunken_chest"] = {
        id = "sunken_chest",
        title = "El Alijo Olvidado de Trabalomas",
        category = "Cofre Oculto",
        faction = "Ambas",
        level = "Nivel 24 - 34",
        minLevel = 24,
        maxLevel = 34,
        reward = "Bolsa de 10 casillas y gemas",
        rewardItems = {
            { itemID = 5571, name = "Bolsa pequeña de seda", quality = 2, icon = "Interface\\Icons\\inv_misc_bag_07", desc = "Contenedor de 10 casillas para tus viajes." },
            { itemID = 1210, name = "Sombraágata", count = 2, quality = 2, icon = "Interface\\Icons\\inv_misc_gem_amethyst_01", desc = "Gema no común para joyería e ingeniería." },
        },
        icon = "Interface\\Icons\\inv_box_01",
        steps = {
            [1] = {
                stepNum = 1,
                title = "1. Naufragio de la Costa Sur",
                instruction = "Bucea en el casco roto del barco cerca de las islas de murlocs en Trabalomas (28.5, 72.1).",
                uiMapID = 1424,
                zoneName = "Laderas de Trabalomas",
                x = 28.5,
                y = 72.1,
                icon = "Interface\\Icons\\inv_misc_fish_02"
            },
            [2] = {
                stepNum = 2,
                title = "2. La Llave de Coral",
                instruction = "Recoge la llave en la almeja gigante sumergida al sur de la costa (31.0, 78.4).",
                uiMapID = 1424,
                zoneName = "Laderas de Trabalomas",
                x = 31.0,
                y = 78.4,
                icon = "Interface\\Icons\\inv_misc_key_03"
            }
        }
    },
    ["tanaris_pirates"] = {
        id = "tanaris_pirates",
        title = "El Alijo de los Piratas Mares del Sur",
        category = "Cofre Oculto",
        faction = "Ambas",
        level = "Nivel 42 - 52",
        minLevel = 42,
        maxLevel = 52,
        reward = "Bolsa de pirata (14 casillas) y gemas valiosas",
        rewardItems = {
            { itemID = 9276, name = "Bolsa de pirata", quality = 2, icon = "Interface\\Icons\\inv_misc_bag_08", desc = "Contenedor de 14 casillas." },
            { itemID = 7910, name = "Diamante de la estrella negra", quality = 2, icon = "Interface\\Icons\\inv_misc_gem_diamond_01", desc = "Gema brillante de gran valor en subasta." },
        },
        icon = "Interface\\Icons\\inv_misc_bag_08",
        steps = {
            [1] = {
                stepNum = 1,
                title = "1. Cala de los Mares del Sur (Tanaris)",
                instruction = "Infíltrate en la Cala de los Mares del Sur (72.8, 45.2) e inspecciona el mapa pirata enrollado sobre un barril de pólvora.",
                uiMapID = 1446, -- Tanaris
                zoneName = "Tanaris",
                x = 72.8,
                y = 45.2,
                icon = "Interface\\Icons\\inv_misc_map_01"
            },
            [2] = {
                stepNum = 2,
                title = "2. Naufragio Pirata Sumergido",
                instruction = "Bucea en el pecio del barco pirata frente a la costa (75.1, 51.4). Abre el Cofre Reforzado en la bodega sumergida.",
                uiMapID = 1446,
                zoneName = "Tanaris",
                x = 75.1,
                y = 51.4,
                icon = "Interface\\Icons\\inv_box_01"
            }
        }
    },
    ["shadowforge_key"] = {
        id = "shadowforge_key",
        title = "La Llave de la Forja Sombría",
        category = "Cadena de Mazmorra",
        faction = "Ambas",
        level = "Nivel 50 - 60",
        minLevel = 50,
        maxLevel = 60,
        reward = "Llave de la Forja Sombría (Acceso directo a BRD)",
        rewardItems = {
            { itemID = 11000, name = "Llave de la Forja Sombría", quality = 3, icon = "Interface\\Icons\\inv_misc_key_05", desc = "Llave permanente para abrir puertas y esclusas de BRD." },
        },
        icon = "Interface\\Icons\\inv_misc_key_05",
        steps = {
            [1] = {
                stepNum = 1,
                title = "1. Santuario de Franclorn Forjador",
                instruction = "Estando en forma de espíritu (muerto) en la Montaña Roca Negra (37.8, 54.2), habla con el fantasma de Franclorn para aceptar 'El legado de los Hierro Negro'.",
                uiMapID = 1428, -- Montaña Roca Negra
                zoneName = "Montaña Roca Negra",
                x = 37.8,
                y = 54.2,
                icon = "Interface\\Icons\\spell_holy_senseundead"
            },
            [2] = {
                stepNum = 2,
                title = "2. Castigador Fin'el (Interior BRD)",
                instruction = "Derrota al Castigador Fin'el en la Cantera Sombría de BRD y despoja el Martillo de Hierro de Franclorn.",
                uiMapID = 1530, -- Blackrock Depths
                zoneName = "Profundidades de Roca Negra",
                x = 42.0,
                y = 50.0,
                icon = "Interface\\Icons\\inv_hammer_01"
            },
            [3] = {
                stepNum = 3,
                title = "3. Santuario de la Forja (Interior BRD)",
                instruction = "Ve al Santuario de Franclorn cerca del Templo de Forjatiniebla dentro de BRD e incrusta el martillo para forjar la llave.",
                uiMapID = 1530,
                zoneName = "Profundidades de Roca Negra",
                x = 46.5,
                y = 62.0,
                icon = "Interface\\Icons\\inv_misc_key_05"
            }
        }
    }
}

-- -------------------------------------------------------------------------
-- MOTOR DE PROGRESIÓN Y DETECCIÓN AUTOMÁTICA DE HITOS
-- -------------------------------------------------------------------------
--- Comprueba de forma segura si una misión está completada en el historial
local function IsQuestCompleted(questID)
    if not questID or questID <= 0 then return false end
    if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
        return C_QuestLog.IsQuestFlaggedCompleted(questID)
    elseif IsQuestFlaggedCompleted then
        return IsQuestFlaggedCompleted(questID)
    end
    return false
end

--- Comprueba si una misión está activa en el registro actual del jugador
local function IsQuestActive(questID)
    if not questID or questID <= 0 then return false end
    if C_QuestLog and C_QuestLog.IsOnQuest then
        return C_QuestLog.IsOnQuest(questID)
    end
    local num = (C_QuestLog and C_QuestLog.GetNumQuestLogEntries and C_QuestLog.GetNumQuestLogEntries())
        or (GetNumQuestLogEntries and GetNumQuestLogEntries()) or 0
    for i = 1, num do
        local qid = nil
        if C_QuestLog and C_QuestLog.GetInfo then
            local info = C_QuestLog.GetInfo(i)
            qid = info and info.questID
        elseif GetQuestLogTitle then
            local _, _, _, _, _, _, _, id = GetQuestLogTitle(i)
            qid = id
        end
        if qid == questID then return true end
    end
    return false
end

--- Comprueba si el jugador ya posee el Saco de Dormir en sus bolsas
local function HasSleepingBagItem()
    for bag = 0, 4 do
        local slots = (C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerNumSlots(bag))
            or (GetContainerNumSlots and GetContainerNumSlots(bag)) or 0
        for slot = 1, slots do
            local id = (C_Container and C_Container.GetContainerItemID and C_Container.GetContainerItemID(bag, slot))
                or (GetContainerItemID and GetContainerItemID(bag, slot))
            if id == 211527 then return true end
        end
    end
    return false
end

--- Devuelve el hito activo del secreto y si está completado al 100%
function ns.GetSecretProgress(secretKey)
    local faction = UnitFactionGroup("player") or "Alliance"
    local isAlliance = (faction == "Alliance")

    if secretKey == "sleeping_bag" then
        local initQuestID = isAlliance and 79008 or 79007

        -- 1. ¿Ya tiene el Saco de dormir (#211527) o completó la misión final #79976?
        if HasSleepingBagItem() or IsQuestCompleted(79976) then
            return 7, true
        end

        -- 2. ¿Completó #79975 ("Puño del Águila") o tiene activa la misión final #79976 ("Este debe ser el lugar")?
        if IsQuestCompleted(79975) or IsQuestActive(79976) then
            return 7, false
        end

        -- 3. ¿Completó #79974 ("Trabajo húmedo") o tiene activa #79975 ("Puño del Águila")?
        if IsQuestCompleted(79974) or IsQuestActive(79975) then
            return 6, false
        end

        -- 4. ¿Completó #79980 ("Trepar") o tiene activa #79974 ("Trabajo húmedo")?
        if IsQuestCompleted(79980) or IsQuestActive(79974) then
            return 5, false
        end

        -- 5. ¿Completó #79192 ("Peldaños de piedra") o tiene activa #79980 ("Trepar")?
        if IsQuestCompleted(79192) or IsQuestActive(79980) then
            return 4, false
        end

        -- 6. ¿Completó la misión inicial (79008/79007) o ya aceptó #79192 ("Peldaños de piedra")?
        if IsQuestCompleted(initQuestID) or IsQuestActive(79192) then
            return 3, false
        end

        -- 7. REQUISITO EXCLUSIVO: ¿El jugador ya aceptó la misión inicial (79008 o 79007)?
        if IsQuestActive(initQuestID) then
            -- Ya recogió la nota en el Paso 1. Redirigir automáticamente al Paso 2 para viajar y entregarla.
            return 2, false
        end

        -- 8. Por defecto: No tiene la misión inicial. Debe ir al Paso 1 a conseguirla.
        return 1, false

    elseif secretKey == "library_books" then
        local turnInStep = isAlliance and 16 or 17

        -- 1. ¿Ya completó la misión final de entrega #79000 (Friend of the Library)?
        if IsQuestCompleted(79000) then
            return turnInStep, true, 10
        end

        -- 2. Contar libros conseguidos entre los 15 disponibles
        local collectedCount = 0
        local firstIncomplete = nil
        local books = ns.Data.UniqueLibraryBooks or {}

        for i = 1, 15 do
            local book = books[i]
            if book and book.questID then
                if IsQuestCompleted(book.questID) or IsQuestActive(book.questID) then
                    collectedCount = collectedCount + 1
                elseif not firstIncomplete then
                    firstIncomplete = i
                end
            end
        end

        -- 3. Si ya tiene 10 o más libros recolectados, o tiene activa la misión de entrega #79000
        if collectedCount >= 10 or IsQuestActive(79000) then
            return turnInStep, false, collectedCount
        end

        -- 4. Si aún le faltan libros, sugerir el siguiente libro no recolectado
        return (firstIncomplete or 1), false, collectedCount
    end

    return 1, false
end

--- Obtiene los datos del secreto adaptados dinámicamente a la facción y progreso
function ns.GetSecret(key)
    local secret = ns.Data.Secrets and ns.Data.Secrets[key]
    if not secret then return nil end

    if key == "sleeping_bag" then
        local faction = UnitFactionGroup("player") or "Alliance"
        secret.steps = (faction == "Horde") and ns.Data.SleepingBagStepsHorde or ns.Data.SleepingBagStepsAlliance
        local curStep, isDone = ns.GetSecretProgress("sleeping_bag")
        secret.currentStep = curStep
        secret.isCompleted = isDone
    elseif key == "library_books" then
        secret.steps = ns.Data.UniqueLibraryBooks
        local curStep, isDone, count = ns.GetSecretProgress("library_books")
        secret.currentStep = curStep
        secret.isCompleted = isDone
        secret.collectedCount = count
    else
        secret.currentStep = 1
        secret.isCompleted = false
    end

    return secret
end

-- Inicialización inicial de pasos según facción
local function InitFactionSteps()
    local faction = UnitFactionGroup("player") or "Alliance"
    if ns.Data.Secrets and ns.Data.Secrets["sleeping_bag"] then
        ns.Data.Secrets["sleeping_bag"].steps = (faction == "Horde") and ns.Data.SleepingBagStepsHorde or ns.Data.SleepingBagStepsAlliance
    end
    if ns.Data.Secrets and ns.Data.Secrets["library_books"] then
        ns.Data.Secrets["library_books"].steps = ns.Data.UniqueLibraryBooks
    end
end

local fLoader = CreateFrame("Frame")
fLoader:RegisterEvent("PLAYER_LOGIN")
fLoader:SetScript("OnEvent", InitFactionSteps)

-- Compatibilidad legacy
_G.AwakeningData = _G.AwakeningData or {}
_G.AwakeningData.Guides = ns.Data.Secrets