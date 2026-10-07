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
-- -------------------------------------------------------------------------
-- PASOS PARA LA ALIANZA: COZY SLEEPING BAG (RUTA COMPLETA MULTIMODAL: 16 PASOS)
-- Combina los 7 hitos de misión con las transiciones de viaje intercontinentales
-- -------------------------------------------------------------------------
ns.Data.SleepingBagStepsAlliance = {
    -- HITO 1: INICIO EN PÁRAMOS DE PONIENTE
    [1] = {
        stepNum = 1,
        title = "1. Carreta Calcinada (Páramos de Poniente)",
        instruction = "Ve a la Granja Alexston en Páramos de Poniente (37.5, 50.8). En los restos de la carreta calcinada, interactúa con los 'Restos calcinados' para obtener la misión inicial: '...y esa nota que encontraste'.",
        uiMapID = 1436, -- Westfall
        zoneName = "Páramos de Poniente",
        x = 37.5,
        y = 50.8,
        questID = 79008,
        isMilestone = true,
        milestone = 1,
        action = "Aceptar misión inicial",
        tip = "Consejo Wowhead: La nota apunta a que los viajeros venían o se dirigían a Los Baldíos con suministros.",
        icon = "Interface\\Icons\\spell_fire_fire",
    },

    -- TRAMO DE VIAJE: TRASLADO A KALIMDOR
    [2] = {
        stepNum = 2,
        title = "Viaje: Puerto de Ventormenta (Barco a Auberdine)",
        instruction = "Dirígete a la dársena sur del Puerto de Ventormenta (22.7, 56.0). Aborda el gran barco intercontinental rumbo a Auberdine (Costa Oscura, Kalimdor).",
        uiMapID = 1453, -- Stormwind City
        zoneName = "Ciudad de Ventormenta",
        x = 22.7,
        y = 56.0,
        isTravelStep = true,
        forMilestone = 2,
        tip = "Ruta Forever: Este barco conecta directamente Ventormenta con Costa Oscura sin necesidad de viajar a Menethil.",
        icon = "Interface\\Icons\\ability_druid_travelform",
    },
    [3] = {
        stepNum = 3,
        title = "Viaje: Muelle de Auberdine (Costa Oscura)",
        instruction = "Desembarca en Auberdine (30.7, 41.0). Toma el camino de la costa hacia el sur rumbo a Vallefresno. Si dispones de maestro de vuelo, vuela hacia Astranaar.",
        uiMapID = 1439, -- Darkshore
        zoneName = "Costa Oscura",
        x = 30.7,
        y = 41.0,
        isTravelStep = true,
        forMilestone = 2,
        tip = "Punto de Vuelo: Recuerda sintonizar a Caylais Brisa Lunar en Auberdine (36.3, 45.6) si aún no lo tienes descubierto.",
        icon = "Interface\\Icons\\inv_misc_map_01",
    },
    [4] = {
        stepNum = 4,
        title = "Viaje: Paso Fronterizo hacia Los Baldíos",
        instruction = "Desde Vallefresno, cruza la frontera sur hacia Los Baldíos (49.3, 16.5). Sigue la calzada principal hacia el sur en dirección a Campamento Taurajo.",
        uiMapID = 1413, -- The Barrens
        zoneName = "Los Baldíos",
        x = 49.3,
        y = 16.5,
        isTravelStep = true,
        forMilestone = 2,
        tip = "Alerta Territorio Horda: Mantente alejado de El Cruce y Campamento Taurajo bordeando por las colinas orientales.",
        icon = "Interface\\Icons\\inv_misc_compass_01",
    },

    -- HITO 2: TORRE CALCINADA EN LOS BALDÍOS
    [5] = {
        stepNum = 5,
        title = "2. Torre Calcinada (Los Baldíos)",
        instruction = "Sigue el camino al sur del Campamento Taurajo en Los Baldíos (46.4, 73.9). En los escombros de la torre vigía destruida, interactúa con los 'Restos calcinados' para entregar '...y esa nota que encontraste' y acepta 'Peldaños de piedra'.",
        uiMapID = 1413, -- The Barrens
        zoneName = "Los Baldíos",
        x = 46.4,
        y = 73.9,
        questID = 79008,
        nextQuestID = 79192,
        isMilestone = true,
        milestone = 2,
        action = "Entregar 79008 y aceptar 79192",
        tip = "Alerta Alianza: Taurajo es base Horda. Pasa con precaución por las colinas al este para evitar a los guardias.",
        icon = "Interface\\Icons\\inv_misc_note_01",
    },

    -- TRAMO DE VIAJE: ASCENSO A SIERRA ESPOLÓN
    [6] = {
        stepNum = 6,
        title = "Viaje: Paso de los Carromatos (Sierra Espolón)",
        instruction = "Regresa hacia el noroeste de Los Baldíos y sube por la rampa rocosa hacia Sierra Espolón (42.1, 44.5 en Los Baldíos).",
        uiMapID = 1413, -- The Barrens
        zoneName = "Los Baldíos",
        x = 42.1,
        y = 44.5,
        isTravelStep = true,
        forMilestone = 3,
        tip = "Camino seguro: Sigue la empinada senda de tierra que sube entre los cañones hacia Sierra Espolón.",
        icon = "Interface\\Icons\\ability_mount_ridinghorse",
    },
    [7] = {
        stepNum = 7,
        title = "Viaje: Senda Oculta del Campamento",
        instruction = "Al noreste de Refugio Roca del Sol en Sierra Espolón (50.9, 52.3), localiza la senda oculta entre los árboles y rocas que asciende a la cima de la montaña.",
        uiMapID = 1440, -- Stonetalon Mountains
        zoneName = "Sierra Espolón",
        x = 50.9,
        y = 52.3,
        isTravelStep = true,
        forMilestone = 3,
        tip = "Referencia visual: Busca el sendero angosto que serpentea entre los abetos bordeando el acantilado hacia el noroeste.",
        icon = "Interface\\Icons\\inv_misc_map_02",
    },

    -- HITO 3: CAMPAMENTO EN LA CIMA
    [8] = {
        stepNum = 8,
        title = "3. Campamento en la Cima (Sierra Espolón)",
        instruction = "Sube hasta el campamento abandonado en la cima (40.6, 52.4). Clic en la 'Basura de bolsillo' sobre una caja para entregar 'Peldaños de piedra' y aceptar 'Trepar'.",
        uiMapID = 1440, -- Stonetalon Mountains
        zoneName = "Sierra Espolón",
        x = 40.6,
        y = 52.4,
        trailX = 50.9,
        trailY = 52.3,
        questID = 79192,
        nextQuestID = 79980,
        isMilestone = true,
        milestone = 3,
        action = "Entregar 79192 y aceptar 79980",
        tip = "Recompensa: 1x Forraje de estudiante (+4 barras de Exp descansada) + Madera y Yesca. Opcional: Enciende la fogata para completar 'Reavivar' (80001).",
        icon = "Interface\\Icons\\inv_misc_food_pinenut",
    },

    -- HITO 4: SALTO AL RISCO (LOCAL EN SIERRA ESPOLÓN)
    [9] = {
        stepNum = 9,
        title = "4. Salto al Risco (Sierra Espolón)",
        instruction = "Desde el campamento, camina al norte hacia el borde del precipicio (39.6, 49.8). Salta con cuidado a la cornisa del risco e interactúa con el 'Montículo de tierra' para entregar 'Trepar' y aceptar 'Trabajo húmedo'.",
        uiMapID = 1440, -- Stonetalon Mountains
        zoneName = "Sierra Espolón",
        x = 39.6,
        y = 49.8,
        questID = 79980,
        nextQuestID = 79974,
        isMilestone = true,
        milestone = 4,
        action = "Entregar 79980 y aceptar 79974",
        tip = "Recompensa: ¡Fiambrera resistente (bolsa de 12 casillas)! Cuidado al saltar para no caer al vacío.",
        icon = "Interface\\Icons\\inv_box_01",
    },

    -- TRAMO DE VIAJE: RETORNO A LOS REINOS DEL ESTE Y LOCH MODAN
    [10] = {
        stepNum = 10,
        title = "Viaje: Barco a Puerto de Menethil",
        instruction = "Regresa al embarcadero sur de Auberdine en Costa Oscura (32.4, 43.8) y toma el barco hacia el Puerto de Menethil en Los Humedales (Reinos del Este). (Alternativa: Piedra de Hogar a Forjaz o Ventormenta si está lista).",
        uiMapID = 1439, -- Darkshore
        zoneName = "Costa Oscura",
        x = 32.4,
        y = 43.8,
        isTravelStep = true,
        forMilestone = 5,
        tip = "Coordenadas de atraque en Menethil: 4.7, 57.2 en Los Humedales.",
        icon = "Interface\\Icons\\inv_misc_ticket_tarot_portal_01",
    },
    [11] = {
        stepNum = 11,
        title = "Viaje: Túneles de Dun Algaz a Loch Modan",
        instruction = "Desde Los Humedales (53.6, 70.8), asciende por el camino sur y atraviesa los túneles orcos de Dun Algaz que conducen a Loch Modan (22.1, 14.5).",
        uiMapID = 1437, -- Wetlands
        zoneName = "Los Humedales",
        x = 53.6,
        y = 70.8,
        isTravelStep = true,
        forMilestone = 5,
        tip = "Camino seguro: Sigue el camino adoquinado enano a través de las dos puertas fortificadas.",
        icon = "Interface\\Icons\\inv_misc_compass_01",
    },

    -- HITO 5: PRESA DE LAS TRES CABEZAS EN LOCH MODAN
    [12] = {
        stepNum = 12,
        title = "5. Presa de las Tres Cabezas (Loch Modan)",
        instruction = "Viaja a la gran presa de Loch Modan (49.4, 12.9). Camina sobre las cabezas talladas en la pared exterior mirando a Los Humedales. Haz clic en la 'Estatuilla de águila' para entregar 'Trabajo húmedo' y aceptar 'Puño del Águila'.",
        uiMapID = 1432, -- Loch Modan
        zoneName = "Loch Modan",
        x = 49.4,
        y = 12.9,
        questID = 79974,
        nextQuestID = 79975,
        isMilestone = true,
        milestone = 5,
        action = "Entregar 79974 y aceptar 79975",
        tip = "Recompensa: Otro Forraje de estudiante (+4 barras de Exp descansada).",
        icon = "Interface\\Icons\\inv_misc_statue_01",
    },

    -- TRAMO DE VIAJE: HACIA TIERRAS ALTAS DE ARATHI Y TRABALOMAS
    [13] = {
        stepNum = 13,
        title = "Viaje: Viaducto Thandol (Humedales a Arathi)",
        instruction = "Baja de nuevo a Los Humedales y sigue la carretera real norte a través del Viaducto Thandol (50.1, 11.2) para cruzar a las Tierras Altas de Arathi (40.1, 88.5).",
        uiMapID = 1437, -- Wetlands
        zoneName = "Los Humedales",
        x = 50.1,
        y = 11.2,
        isTravelStep = true,
        forMilestone = 6,
        tip = "Cruce seguro: Cruza por el gran puente de piedra central sin caerte al foso.",
        icon = "Interface\\Icons\\ability_mount_ridinghorse",
    },
    [14] = {
        stepNum = 14,
        title = "Viaje: Muralla de Thoradin (Acceso este)",
        instruction = "En Arathi, cabalga por el camino hacia el oeste en dirección a Trabalomas hasta llegar a la brecha de la Muralla de Thoradin (14.8, 48.0 en Arathi / 87.3, 49.6 en Trabalomas).",
        uiMapID = 1417, -- Arathi Highlands
        zoneName = "Tierras Altas de Arathi",
        x = 14.8,
        y = 48.0,
        isTravelStep = true,
        forMilestone = 6,
        tip = "Precaución: Evita llamar la atención de las patrullas del Sindicato a los lados de la calzada.",
        icon = "Interface\\Icons\\inv_misc_map_01",
    },

    -- HITO 6: MURALLA DE THORADIN - PARKOUR
    [15] = {
        stepNum = 15,
        title = "6. Muralla de Thoradin - Parkour (Trabalomas)",
        instruction = "En la Muralla de Thoradin (87.3, 49.6 en Trabalomas), desmóntate. Salta sobre la carreta rota y trepa por los bloques caídos a la sala superior del muro. Clic en la 'Bolsa de mensajero' colgada para entregar 'Puño del Águila' y aceptar 'Este debe ser el lugar'.",
        uiMapID = 1424, -- Hillsbrad Foothills
        zoneName = "Laderas de Trabalomas",
        x = 87.3,
        y = 49.6,
        questID = 79975,
        nextQuestID = 79976,
        isMilestone = true,
        milestone = 6,
        action = "Entregar 79975 y aceptar 79976",
        tip = "Parkour: Salta sin montura sobre la carreta inclinada, toma impulso y brinca a la cornisa del pilar para acceder a la sala.",
        icon = "Interface\\Icons\\inv_misc_bag_07",
    },

    -- HITO 7: RECLAMAR EL SACO DE DORMIR ACOGEDOR
    [16] = {
        stepNum = 16,
        title = "7. Reclamar el Saco Acogedor (Muralla de Thoradin)",
        instruction = "En el suelo de esa misma sala de la Muralla de Thoradin, justo debajo de la bolsa de mensajero, haz clic en el 'Fardo enrollado a toda prisa'. ¡Entrega la misión final para reclamar tu Saco de dormir acogedor!",
        uiMapID = 1424, -- Hillsbrad Foothills
        zoneName = "Laderas de Trabalomas",
        x = 87.3,
        y = 49.6,
        questID = 79976,
        isMilestone = true,
        milestone = 7,
        action = "Completar cadena y recibir el Saco",
        tip = "¡Conseguido! Úsalo al aire libre y descansa encima: otorga +1% de Exp acumulada por minuto de sueño (máximo +3% por 2 horas).",
        icon = "Interface\\Icons\\inv_misc_bag_bigbagofenchantments",
    },
}

-- Mapeo de hitos de misión (1..7) al paso canónico del objetivo en la ruta Alianza
local ALLIANCE_MILESTONE_TARGET_STEP = {
    [1] = 1,  -- Carreta Calcinada (Westfall)
    [2] = 5,  -- Torre Calcinada (Los Baldíos)
    [3] = 8,  -- Campamento Cima (Sierra Espolón)
    [4] = 9,  -- Salto al Risco (Sierra Espolón)
    [5] = 12, -- Presa Tres Cabezas (Loch Modan)
    [6] = 15, -- Muralla Parkour (Trabalomas)
    [7] = 16, -- Reclamar Saco (Trabalomas)
}

-- Primer paso del tramo de viaje hacia cada hito en la ruta Alianza
local ALLIANCE_MILESTONE_FIRST_STEP = {
    [1] = 1,  -- Inicio Westfall
    [2] = 2,  -- Viaje: Puerto Ventormenta
    [3] = 6,  -- Viaje: Paso a Sierra Espolón
    [4] = 9,  -- Salto al Risco
    [5] = 10, -- Viaje: Barco a Menethil
    [6] = 13, -- Viaje: Viaducto Thandol
    [7] = 16, -- Reclamar Saco
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
        icon = "Interface\\Icons\\spell_fire_fire",
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
        icon = "Interface\\Icons\\inv_misc_note_01",
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
        icon = "Interface\\Icons\\inv_misc_food_pinenut",
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
        icon = "Interface\\Icons\\inv_box_01",
    },
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
        icon = "Interface\\Icons\\inv_misc_statue_01",
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
        icon = "Interface\\Icons\\inv_misc_bag_07",
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
        icon = "Interface\\Icons\\inv_misc_bag_bigbagofenchantments",
    },
}

-- -------------------------------------------------------------------------
-- PASOS PARA OBTENER LOS TOMOS (WoW Forever Library Books)
-- -------------------------------------------------------------------------
ns.Data.UniqueLibraryBooks = {
    [1] = {
        stepNum = 1,
        title = "Archmage Theocritus' Research Journal",
        instruction = "Recoge el diario en el tercer piso de la Torre de Azora.",
        uiMapID = 1429, -- Bosque de Elwynn
        zoneName = "Bosque de Elwynn",
        x = 65.4,
        y = 70.1,
        questID = 79092,
        itemID = 203755,
        objectID = 386759,
        action = "Despojar libro de biblioteca",
        faction = "Alliance",
        tip = "Dentro de la torre de Azora, sube por las escaleras hasta la mesa de la tercera planta.",
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
        questID = 78142,
        itemID = 209845,
        objectID = 409562,
        action = "Despojar libro de hechizos",
        tip = "Ubicado dentro de Moonbrook, en la primera casa a la izquierda, sobre la estantería.",
        icon = "Interface\\Icons\\inv_misc_book_06"
    },
    [3] = {
        stepNum = 3,
        title = "Rumi of Gnomeregan: The Collected Works",
        instruction = "Recoge el tomo en la posada de Thelsamar (o en Colina del Centinela).",
        uiMapID = 1432, -- Loch Modan
        zoneName = "Loch Modan",
        x = 35.6,
        y = 48.9,
        questID = 79093,
        itemID = 208860,
        objectID = 408014,
        action = "Despojar tomo gnómico",
        faction = "Alliance",
        tip = "Piso superior de la posada de Thelsamar. (También en Páramos de Poniente 52.7, 53.8 tras el tabernero).",
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
        questID = 78147,
        itemID = 209849,
        objectID = 409735,
        action = "Despojar libro de hechizos",
        tip = "Catacumbas de Dawning Wood. Entra por el acceso oeste del cementerio y baja hasta el fondo.",
        icon = "Interface\\Icons\\inv_misc_book_11"
    },
    [5] = {
        stepNum = 5,
        title = "Runes of the Sorcerer-Kings",
        instruction = "Explora la cueva de ogros en Bastión Mo'grosh y despoja el tomo.",
        uiMapID = 1432, -- Loch Modan
        zoneName = "Loch Modan",
        x = 77.5,
        y = 14.1,
        questID = 78148,
        itemID = 209850,
        objectID = 409731,
        action = "Despojar pergaminos",
        tip = "Bastión Mo'Grosh. Dentro de la cueva de ogros, toma el camino de la izquierda custodiado por dos ogros.",
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
        questID = 78146,
        itemID = 209848,
        objectID = 409717,
        action = "Despojar pergaminos",
        tip = "Yacimiento de Whelgar. Dentro de una vasija en el nivel inferior de la excavación.",
        icon = "Interface\\Icons\\inv_misc_note_06"
    },
    [7] = {
        stepNum = 7,
        title = "Archmage Antonidas: The Unabridged Autobiography",
        instruction = "Recoge la autobiografía en la Sala de Expedicionarios.",
        uiMapID = 1455, -- Forjaz
        zoneName = "Forjaz",
        x = 76.3,
        y = 10.8,
        questID = 79091,
        itemID = 203754,
        objectID = 386691,
        action = "Despojar libro de biblioteca",
        faction = "Alliance",
        tip = "Sobre la mesa grande en el centro de la Sala de Expedicionarios de Forjaz.",
        icon = "Interface\\Icons\\inv_misc_book_02"
    },
    [8] = {
        stepNum = 8,
        title = "The Apothecary's Metaphysical Primer",
        instruction = "Recoge el libro en la botica de Remol.",
        uiMapID = 1420, -- Claros de Tirisfal
        zoneName = "Claros de Tirisfal",
        x = 59.5,
        y = 52.3,
        questID = 79095,
        itemID = 208185,
        objectID = 405879,
        action = "Despojar libro",
        faction = "Horde",
        tip = "En Brill/Remol, estantería junto al Boticario Johaan dentro de la tienda de alquimia.",
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
        questID = 78127,
        itemID = 209844,
        objectID = 409501,
        action = "Despojar compendio de Dalaran",
        tip = "Edificio central de Molino de Ámbar. Estantería en la esquina noreste del salón principal.",
        icon = "Interface\\Icons\\inv_misc_book_04"
    },
    [10] = {
        stepNum = 10,
        title = "Ataeric: On Arcane Curiosities",
        instruction = "Recoge el tomo en la tumba de El Sepulcro.",
        uiMapID = 1421, -- Bosque de Argénteos
        zoneName = "Bosque de Argénteos",
        x = 43.4,
        y = 41.2,
        questID = 79096,
        itemID = 210177,
        objectID = 410299,
        action = "Despojar secretos arcanos",
        faction = "Horde",
        tip = "El Sepulcro. Dentro de la cripta, sobre la mesa junto a Sebastian Meloche.",
        icon = "Interface\\Icons\\inv_misc_book_12"
    },
    [11] = {
        stepNum = 11,
        title = "Arcanic Systems Manual",
        instruction = "Sube a la plataforma petrolífera en El Fangal.",
        uiMapID = 1413, -- Los Baldíos
        zoneName = "Los Baldíos",
        x = 56.3,
        y = 8.8,
        questID = 78145,
        itemID = 209847,
        objectID = 409700,
        action = "Despojar manual",
        tip = "En la sala de control en lo más alto de la plataforma petrolífera goblin.",
        icon = "Interface\\Icons\\inv_gizmo_02"
    },
    [12] = {
        stepNum = 12,
        title = "Baxtan: On Destructive Magics",
        instruction = "Recoge el libro en Bahía del Trinquete.",
        uiMapID = 1413, -- Los Baldíos
        zoneName = "Los Baldíos",
        x = 62.7,
        y = 36.3,
        questID = 79097,
        itemID = 208800,
        objectID = 407566,
        action = "Despojar tomo goblin",
        tip = "Edificio de ingeniería de Trinquete, sobre la mesa junto a Gazlowe.",
        icon = "Interface\\Icons\\spell_fire_fire"
    },
    [13] = {
        stepNum = 13,
        title = "Secrets of the Dreamers",
        instruction = "Entra en la Caverna de las Brumas (exterior de Cuevas de los Lamentos).",
        uiMapID = 1413, -- Los Baldíos
        zoneName = "Los Baldíos",
        x = 52.8,
        y = 54.7,
        questID = 78143,
        itemID = 209846,
        objectID = 409562,
        action = "Despojar pergaminos",
        tip = "Entrada en (46.0, 36.5). No cruces el portal de la mazmorra; está en la última sala exterior.",
        icon = "Interface\\Icons\\inv_misc_book_10"
    },
    [14] = {
        stepNum = 14,
        title = "Nar'thalas Almanac, Vol. 74",
        instruction = "Baja a las ruinas de Mathystra en Costa Oscura.",
        uiMapID = 1438, -- Costa Oscura
        zoneName = "Costa Oscura",
        x = 59.6,
        y = 22.2,
        questID = 78124,
        itemID = 209843,
        objectID = 409496,
        action = "Despojar pergaminos",
        tip = "Ruinas de Mathystra. Bajando las escaleras hacia el agua, en el tercer descansillo.",
        icon = "Interface\\Icons\\inv_misc_book_12"
    },
    [15] = {
        stepNum = 15,
        title = "The Lessons of Ta'zo",
        instruction = "Examina la tablilla rúnica en Orgrimmar.",
        uiMapID = 1454, -- Orgrimmar
        zoneName = "Orgrimmar",
        x = 38.7,
        y = 78.4,
        questID = 79094,
        itemID = 207972,
        action = "Calcar mural de Ta'zo",
        faction = "Horde",
        tip = "Valle de los Espíritus, gran tablilla junto al cartel de Darkbriar Lodge.",
        icon = "Interface\\Icons\\inv_misc_stonetablet_02"
    },
    [16] = {
        stepNum = 16,
        title = "Defensive Magics 101",
        instruction = "Recoge el manual en la fortaleza ogra del Rincón de las Horcas.",
        uiMapID = 1416, -- Montañas de Alterac
        zoneName = "Montañas de Alterac",
        x = 48.4,
        y = 57.7,
        questID = 79948,
        itemID = 215815,
        objectID = 423896,
        action = "Despojar manual",
        tip = "Primera torre al entrar a la fortaleza ogra desde Molino Tarren o Strahnbrad.",
        icon = "Interface\\Icons\\inv_misc_book_04"
    },
    [17] = {
        stepNum = 17,
        title = "A Web of Lies: Debunking Myths and Legends",
        instruction = "Recoge los pergaminos en el Poblado Marchamarchita.",
        uiMapID = 1417, -- Tierras Altas de Arathi
        zoneName = "Tierras Altas de Arathi",
        x = 73.6,
        y = 65.2,
        questID = 79949,
        itemID = 215816,
        objectID = 423897,
        action = "Despojar pergaminos",
        tip = "Poblado trol de Marchamarchita. Fuera de una tienda en dirección a la choza.",
        icon = "Interface\\Icons\\inv_misc_note_05"
    },
    [18] = {
        stepNum = 18,
        title = "Mummies: A Guide to the Unsavory Undead",
        instruction = "Explora la cripta en las estribaciones sur de Tierras Inhóspitas.",
        uiMapID = 1418, -- Tierras Inhóspitas
        zoneName = "Tierras Inhóspitas",
        x = 56.7,
        y = 39.9,
        questID = 79951,
        itemID = 215820,
        objectID = 423899,
        action = "Despojar pergaminos",
        tip = "Sube por la senda en (56.0, 45.0) por encima del campamento enano hasta la cripta.",
        icon = "Interface\\Icons\\inv_scroll_01"
    },
    [19] = {
        stepNum = 19,
        title = "Fury of the Land",
        instruction = "Revisa el campamento Tótem Siniestro en Sierra Espolón.",
        uiMapID = 1442, -- Sierra Espolón
        zoneName = "Sierra Espolón",
        x = 74.4,
        y = 85.7,
        questID = 78149,
        itemID = 209851,
        objectID = 409711,
        action = "Despojar pergaminos",
        tip = "Campamento este de Tótem Siniestro. Encima de un barril dentro de una tienda junto al gran tótem.",
        icon = "Interface\\Icons\\spell_nature_earthquake"
    },
    [20] = {
        stepNum = 20,
        title = "Geomancy: The Stone-Cold Truth",
        instruction = "Sube al Pináculo Nuboscuro en Las Mil Agujas.",
        uiMapID = 1441, -- Las Mil Agujas
        zoneName = "Las Mil Agujas",
        x = 34.0,
        y = 40.0,
        questID = 79947,
        itemID = 215683,
        objectID = 423895,
        action = "Despojar pergaminos",
        tip = "Dentro de la choza más grande de Darkcloud Pinnacle. Senda de subida en (31.0, 37.0).",
        icon = "Interface\\Icons\\inv_misc_book_08"
    },
    [21] = {
        stepNum = 21,
        title = "Basilisks: Should Petrification be Feared?",
        instruction = "Inspecciona la Mina Veta de Cristal en Vega de Tuercespina.",
        uiMapID = 1434, -- Vega de Tuercespina
        zoneName = "Vega de Tuercespina",
        x = 41.5,
        y = 50.8,
        questID = 79535,
        itemID = 213165,
        objectID = 421526,
        action = "Despojar notas de investigación",
        tip = "Mina Veta de Cristal. Plataforma de madera a la derecha de la boca de la cueva.",
        icon = "Interface\\Icons\\inv_inscription_scroll"
    },
    [22] = {
        stepNum = 22,
        title = "RwlRwlRwlRwl!",
        instruction = "Encuentra el tomo empapado en Colina de las Brujas.",
        uiMapID = 1445, -- Marjal Revolcafango
        zoneName = "Marjal Revolcafango",
        x = 57.0,
        y = 21.0,
        questID = 79952,
        itemID = 215822,
        objectID = 423900,
        action = "Despojar libro empapado",
        tip = "En el suelo en el borde este del campamento de múrlocs de Witch Hill.",
        icon = "Interface\\Icons\\inv_misc_book_08"
    },
    [23] = {
        stepNum = 23,
        title = "Demons and You",
        instruction = "Entra en la Fortaleza Hacha de Trueno en Desolace.",
        uiMapID = 1443, -- Desolace
        zoneName = "Desolace",
        x = 55.1,
        y = 26.2,
        questID = 79950,
        itemID = 215817,
        objectID = 423898,
        action = "Despojar libro misterioso",
        tip = "Dentro del edificio principal de la fortaleza, sobre un banco apoyado contra la pared.",
        icon = "Interface\\Icons\\inv_misc_book_01"
    },
    [24] = {
        stepNum = 24,
        title = "A Luddite's Guide to Caring for Your Demonic Pet",
        instruction = "Rescata el tomo en el Santuario en Barbecho del Pantano de las Penas.",
        uiMapID = 1435, -- Pantano de las Penas
        zoneName = "Pantano de las Penas",
        x = 61.0,
        y = 22.0,
        questID = 79953,
        itemID = 215824,
        objectID = 423901,
        action = "Despojar libro enjaulado",
        tip = "Dentro de una jaula en Fallow Sanctuary. Mata Perdidos para la Llave oxidada (#216523) o gira la cámara.",
        icon = "Interface\\Icons\\inv_misc_book_10"
    },
    [25] = {
        stepNum = 25,
        title = "Sanguine Sorcery",
        instruction = "Explora el sector este del Pantano de las Penas.",
        uiMapID = 1435, -- Pantano de las Penas
        zoneName = "Pantano de las Penas",
        x = 70.1,
        y = 51.8,
        action = "Despojar libro",
        tip = "En las ruinas orientales rodeadas de agua y bruma.",
        icon = "Interface\\Icons\\inv_misc_book_05"
    },
    [26] = {
        stepNum = 26,
        title = "Everyday Etiquette",
        instruction = "Recoge el libro en las ruinas de Azshara.",
        uiMapID = 1447, -- Azshara
        zoneName = "Azshara",
        x = 20.8,
        y = 62.0,
        action = "Despojar libro",
        tip = "Sobre un podio ceremonial derruido en el sector sudoeste de Azshara.",
        icon = "Interface\\Icons\\inv_misc_book_03"
    },
    [27] = {
        stepNum = 27,
        title = "Venomous Journeys",
        instruction = "Recoge el tomo en las ruinas de Tierras del Interior.",
        uiMapID = 1425, -- Tierras del Interior
        zoneName = "Tierras del Interior",
        x = 36.0,
        y = 72.8,
        action = "Despojar libro",
        tip = "En las inmediaciones de los templos trol sobre una repisa de piedra.",
        icon = "Interface\\Icons\\inv_misc_book_04"
    },
    [28] = {
        stepNum = 28,
        title = "A Mind of Metal",
        instruction = "Revisa los campamentos de la Garganta de Fuego.",
        uiMapID = 1427, -- Garganta de Fuego
        zoneName = "Garganta de Fuego",
        x = 37.8,
        y = 49.3,
        action = "Despojar libro",
        tip = "Campamento de enanos Hierro Negro en el centro de la garganta.",
        icon = "Interface\\Icons\\inv_misc_book_11"
    },
    [29] = {
        stepNum = 29,
        title = "Stonewrought Design",
        instruction = "Explora las Estepas Ardientes cerca de la ladera de la montaña.",
        uiMapID = 1428, -- Estepas Ardientes
        zoneName = "Estepas Ardientes",
        x = 29.1,
        y = 28.9,
        itemID = 220349,
        action = "Despojar libro",
        tip = "Cerca del acceso rocoso en las faldas de la montaña.",
        icon = "Interface\\Icons\\inv_misc_book_11"
    },
    [30] = {
        stepNum = 30,
        title = "Magma or Lava?",
        instruction = "Baja por la cadena de Montaña Roca Negra (exterior).",
        uiMapID = 1428, -- Montaña Roca Negra
        zoneName = "Montaña Roca Negra",
        x = 48.4,
        y = 63.6,
        itemID = 228133,
        action = "Despojar libro",
        tip = "Desde la cámara central baja por la cadena. Puerta a la derecha antes de Lothos Riftwaker; sobre la plataforma.",
        icon = "Interface\\Icons\\inv_misc_book_10"
    },
    [31] = {
        stepNum = 31,
        title = "The Liminal and the Arcane",
        instruction = "Investiga las ruinas de Feralas.",
        uiMapID = 1444, -- Feralas
        zoneName = "Feralas",
        x = 50.6,
        y = 15.7,
        itemID = 220347,
        action = "Despojar libro",
        tip = "Ruinas élficas al norte de Feralas sobre una cornisa de mármol.",
        icon = "Interface\\Icons\\inv_misc_book_08"
    },
    [32] = {
        stepNum = 32,
        title = "Legends of the Tidesages",
        instruction = "Despoja el libro en la costa de Tanaris.",
        uiMapID = 1446, -- Tanaris
        zoneName = "Tanaris",
        x = 72.6,
        y = 47.8,
        action = "Despojar libro",
        tip = "Cala de los Vendezagres, campamento de piratas en la orilla del mar.",
        icon = "Interface\\Icons\\inv_misc_book_12"
    },
    [33] = {
        stepNum = 33,
        title = "Conjurer's Codex",
        instruction = "Localiza el códice en Las Tierras Devastadas.",
        uiMapID = 1419, -- Las Tierras Devastadas
        zoneName = "Las Tierras Devastadas",
        x = 55.4,
        y = 32.2,
        action = "Despojar libro",
        tip = "Cerca de las crestas custodiadas por sirvientes demoníacos.",
        icon = "Interface\\Icons\\inv_misc_book_02"
    },
    [34] = {
        stepNum = 34,
        title = "Northern Kalimdor - A Comprehensive Guide",
        instruction = "Entra en el Bastión Fauces de Madera en Frondavil.",
        uiMapID = 1448, -- Frondavil
        zoneName = "Frondavil",
        x = 65.2,
        y = 3.2,
        itemID = 228134,
        action = "Despojar libro",
        tip = "Dentro del túnel de Timbermaw Hold, junto al puente sobre el intendente.",
        icon = "Interface\\Icons\\inv_misc_book_03"
    },
    [35] = {
        stepNum = 35,
        title = "Undead Potatoes",
        instruction = "Sube a la granja de Janice Felstone en Tierras de la Peste del Oeste.",
        uiMapID = 1422, -- Tierras de la Peste del Oeste
        zoneName = "Tierras de la Peste del Oeste",
        x = 38.3,
        y = 54.6,
        itemID = 228132,
        action = "Despojar libro",
        tip = "Campo de Felstone. Casa de campo de Janice Felstone, arriba de las escaleras.",
        icon = "Interface\\Icons\\inv_misc_book_09"
    },
    [36] = {
        stepNum = 36,
        title = "Necromancy 101",
        instruction = "Sube a la azotea de Scholomance en Caer Darrow (exterior).",
        uiMapID = 1422, -- Tierras de la Peste del Oeste
        zoneName = "Tierras de la Peste del Oeste",
        x = 69.4,
        y = 72.8,
        itemID = 228141,
        action = "Despojar libro",
        tip = "No entres a la mazmorra. Entra al edificio principal de Scholomance, gira a la derecha y sube todas las escaleras hasta la última sala.",
        icon = "Interface\\Icons\\inv_misc_book_06"
    },
    [37] = {
        stepNum = 37,
        title = "A Study of the Light",
        instruction = "Entra a la Capilla de la Esperanza de la Luz.",
        uiMapID = 1423, -- Tierras de la Peste del Este
        zoneName = "Tierras de la Peste del Este",
        x = 73.0,
        y = 65.0,
        itemID = 228135,
        action = "Despojar libro",
        tip = "Dentro de la capilla de Light's Hope, al fondo a la izquierda.",
        icon = "Interface\\Icons\\inv_misc_book_13"
    },
    [38] = {
        stepNum = 38,
        title = "Scourge: Undead Menace or Misunderstood?",
        instruction = "Revisa la mesa exterior antes del puente de Stratholme.",
        uiMapID = 1423, -- Tierras de la Peste del Este
        zoneName = "Tierras de la Peste del Este",
        x = 31.3,
        y = 21.0,
        itemID = 228140,
        action = "Despojar libro",
        tip = "Fuera de la instancia. Antes de cruzar el puente hacia Stratholme, mesa junto a las horcas a la derecha.",
        icon = "Interface\\Icons\\inv_misc_book_01"
    },
    [39] = {
        stepNum = 39,
        title = "The Knight and the Lady",
        instruction = "Explora las ruinas en Tierras de la Peste del Este.",
        uiMapID = 1423, -- Tierras de la Peste del Este
        zoneName = "Tierras de la Peste del Este",
        x = 54.5,
        y = 50.8,
        itemID = 228138,
        action = "Despojar libro",
        tip = "Al este del Cruce de Corin sobre una repisa semidestruida.",
        icon = "Interface\\Icons\\inv_misc_book_04"
    },
    [40] = {
        stepNum = 40,
        title = "Ka-Boom!",
        instruction = "Visita la tienda de alquimia de Vista Eterna en Cuna del Invierno.",
        uiMapID = 1452, -- Cuna del Invierno
        zoneName = "Cuna del Invierno",
        x = 60.7,
        y = 37.7,
        itemID = 228136,
        action = "Despojar libro",
        tip = "Tienda de suministros de alquimia en Everlook, estantería detrás de Evie Whirlbrew.",
        icon = "Interface\\Icons\\inv_misc_book_11"
    },
    [41] = {
        stepNum = 41,
        title = "Entrega de Tomos — Alianza",
        instruction = "Entrega tus tomos a Garion Wendell en la Torre de los Magos.",
        uiMapID = 1453, -- Ciudad de Ventormenta
        zoneName = "Ciudad de Ventormenta",
        x = 49.0,
        y = 86.4,
        npcName = "Garion Wendell",
        action = "Completar entrega de biblioteca",
        faction = "Alliance",
        tip = "Torre de los Magos de Ventormenta. Sube por la rampa espiral hacia los instructores de portales.",
        icon = "Interface\\Icons\\inv_misc_book_09"
    },
    [42] = {
        stepNum = 42,
        title = "Entrega de Tomos — Horda",
        instruction = "Entrega tus tomos a Owen Thadd en el Barrio de la Magia.",
        uiMapID = 1458, -- Entrañas
        zoneName = "Entrañas",
        x = 74.0,
        y = 32.4,
        npcName = "Owen Thadd",
        action = "Completar entrega de biblioteca",
        faction = "Horde",
        tip = "Barrio de la Magia de Entrañas, cerca de los entrenadores de magos y portales.",
        icon = "Interface\\Icons\\inv_misc_book_09"
    }
}

-- -------------------------------------------------------------------------
-- GUÍA DE PROFESIÓN: COCINA PARA EXPERTOS (Skill 125-150 -> 225)
-- En WoW Clásico ningún instructor entrena Experto; se aprende comprando un libro
-- -------------------------------------------------------------------------
ns.Data.ExpertCookingStepsAlliance = {
    [1] = {
        stepNum = 1,
        title = "1. Comprar 'Cocina para expertos' (Vallefresno)",
        instruction = "Viaja al Lago Mystral en Vallefresno (50.2, 67.1). Encuentra a Shandrina acampando junto a las ruinas y cómprale el libro 'Cocina para expertos' por 1 de oro.",
        uiMapID = 1440, -- Ashenvale
        zoneName = "Vallefresno",
        x = 50.2,
        y = 67.1,
        npcName = "Shandrina",
        action = "Comprar libro por 1 oro",
        tip = "Ubicación: Shandrina está junto a las ruinas al este del Lago Mystral, cerca de la senda hacia Sierra Espolón.",
        icon = "Interface\\Icons\\inv_misc_book_11",
        isMilestone = true,
        milestone = 1,
    },
    [2] = {
        stepNum = 2,
        title = "2. Aprender Cocina Experta (225)",
        instruction = "Abre tus bolsas y haz clic derecho en el libro 'Cocina para expertos' (ID #16072) para desbloquear el límite de habilidad hasta 225.",
        uiMapID = 1440,
        zoneName = "Vallefresno",
        x = 50.2,
        y = 67.1,
        itemID = 16072,
        action = "Usar libro en inventario",
        tip = "Requisito: Requiere tener al menos nivel 20 de personaje y 125 de habilidad en Cocina.",
        icon = "Interface\\Icons\\inv_misc_food_15",
        isMilestone = true,
        milestone = 2,
    },
}

ns.Data.ExpertCookingStepsHorde = {
    [1] = {
        stepNum = 1,
        title = "1. Comprar 'Cocina para expertos' (Desolace)",
        instruction = "Viaja a la Aldea Cazasombras en Desolace (26.2, 69.8). Habla con Wulan cerca de los muelles y cómprale el libro 'Cocina para expertos' por 1 de oro.",
        uiMapID = 1443, -- Desolace
        zoneName = "Desolace",
        x = 26.2,
        y = 69.8,
        npcName = "Wulan",
        action = "Comprar libro por 1 oro",
        tip = "Ubicación: Wulan es un vendedor tauren ubicado frente a las cabañas de pesca en Aldea Cazasombras.",
        icon = "Interface\\Icons\\inv_misc_book_11",
        isMilestone = true,
        milestone = 1,
    },
    [2] = {
        stepNum = 2,
        title = "2. Aprender Cocina Experta (225)",
        instruction = "Abre tus bolsas y haz clic derecho en el libro 'Cocina para expertos' (ID #16072) para desbloquear el límite de habilidad hasta 225.",
        uiMapID = 1443,
        zoneName = "Desolace",
        x = 26.2,
        y = 69.8,
        itemID = 16072,
        action = "Usar libro en inventario",
        tip = "Requisito: Requiere tener al menos nivel 20 de personaje y 125 de habilidad en Cocina.",
        icon = "Interface\\Icons\\inv_misc_food_15",
        isMilestone = true,
        milestone = 2,
    },
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
    ["expert_cooking"] = {
        id = "expert_cooking",
        title = "Cocina para Expertos (Libro 150-225)",
        titleEn = "Expert Cookbook",
        category = "Habilidad de Profesión",
        faction = "Ambas",
        level = "Nivel 20 - 45",
        minLevel = 20,
        maxLevel = 45,
        requiredProfession = "Cooking",
        minSkill = 125,
        maxSkill = 150,
        targetSkill = 225,
        autoHideCompleted = true,
        reward = "Desbloquea rango Cocina Experta (habilidad hasta 225)",
        rewardItems = {
            { itemID = 16072, name = "Cocina para expertos", quality = 1, icon = "Interface\\Icons\\inv_misc_book_11", desc = "Libro que enseña a cocinar hasta nivel 225. Requiere nivel 20 y habilidad 125." },
        },
        icon = "Interface\\Icons\\inv_misc_book_11",
        steps = ns.Data.ExpertCookingStepsAlliance -- Se ajusta dinámicamente según la facción
    },
    ["library_books"] = {
        id = "library_books",
        title = "Tomos de la Biblioteca (Collecting Library Books)",
        titleEn = "Collecting Library Books",
        category = "Secreto Clásico",
        faction = "Ambas",
        level = "Nivel 20 - 60",
        minLevel = 20,
        maxLevel = 60,
        reward = "Collares (10 libros), Sortijas (20 libros) y Armas/Escudos (25 libros)",
        rewardItems = {
            -- Tier 1: 10 Tomos (Misión #78150 - Friend of the Library)
            { itemID = 277203, name = "Colgante de erudito", quality = 2, icon = "Interface\\Icons\\inv_jewelry_necklace_11", desc = "[Tier 1 · 10 Libros] Cuello: +3 Aguante, +2 Espíritu." },
            { itemID = 277204, name = "Amuleto de erudito", quality = 2, icon = "Interface\\Icons\\inv_jewelry_necklace_01", desc = "[Tier 1 · 10 Libros] Cuello: +2 Agilidad, +3 Aguante." },
            -- Tier 2: 20 Tomos (Misión #79536 - Greater Friend of the Library)
            { itemID = 281634, name = "Sortija del investigador de campo", quality = 3, icon = "Interface\\Icons\\inv_jewelry_ring_02", desc = "[Tier 2 · 20 Libros] Dedo: +7 Agilidad, +7 Aguante." },
            { itemID = 281635, name = "Anillo de filántropo", quality = 3, icon = "Interface\\Icons\\inv_jewelry_ring_14", desc = "[Tier 2 · 20 Libros] Dedo: +5 Intelecto, +10 Daño/Sanación con Hechizos." },
            -- Tier 3: 25 Tomos (Misión #82208 - Greater Friend of the Library)
            { itemID = 277254, name = "Arco del buscador de la verdad", quality = 3, icon = "Interface\\Icons\\inv_weapon_bow_01", desc = "[Tier 3 · 25 Libros] Arco: 46-87 Daño (23.8 DPS), +7 Agilidad, +3 Aguante." },
            { itemID = 277258, name = "Blasón de elucidación", quality = 3, icon = "Interface\\Icons\\spell_holy_powerwordshield", desc = "[Tier 3 · 25 Libros] Escudo: 1580 Armadura, +12 Espíritu, +7 Sanación, +4 Hechizos (Req Nivel 40)." },
            { itemID = 277260, name = "Luz nocturna del investigador", quality = 3, icon = "Interface\\Icons\\inv_torch_lit", desc = "[Tier 3 · 25 Libros] Mano izquierda / Antorcha: +12 Aguante, +7 Hechizos de Fuego (Req Nivel 40)." },
        },
        mageBonus = {
            spellID = 1302508,
            name = "Estudiar (Study)",
            icon = "Interface\\Icons\\trade_archaeology_silverscrollcase",
            desc = "Exclusivo de Mago: Al entregar tu primer libro al bibliotecario aprendes 'Estudiar'. Al canalizarlo en una biblioteca consume 1 Pluma ligera y otorga un fardo de pergaminos diarios."
        },
        deliveryNPCs = {
            alliance = { name = "Garion Wendell", zone = "Ciudad de Ventormenta", location = "Torre de los Magos", x = 49.0, y = 86.4, uiMapID = 1453 },
            horde    = { name = "Owen Thadd", zone = "Entrañas", location = "Barrio de la Magia", x = 74.0, y = 32.4, uiMapID = 1458 },
        },
        tiers = {
            [1] = { requiredBooks = 10, questID = 78150, title = "Friend of the Library" },
            [2] = { requiredBooks = 20, questID = 79536, title = "Greater Friend of the Library" },
            [3] = { requiredBooks = 25, questID = 82208, title = "Greater Friend of the Library" },
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

--- Comprueba si el jugador ya posee un objeto específico en su inventario
local function PlayerHasItem(itemID)
    if not itemID or itemID <= 0 then return false end
    if GetItemCount and GetItemCount(itemID, true) > 0 then
        return true
    end
    for bag = 0, 4 do
        local slots = (C_Container and C_Container.GetContainerNumSlots and C_Container.GetContainerNumSlots(bag))
            or (GetContainerNumSlots and GetContainerNumSlots(bag)) or 0
        for slot = 1, slots do
            local id = (C_Container and C_Container.GetContainerItemID and C_Container.GetContainerItemID(bag, slot))
                or (GetContainerItemID and GetContainerItemID(bag, slot))
            if id == itemID then return true end
        end
    end
    return false
end

--- Comprueba si el jugador ya posee el Saco de Dormir en sus bolsas
local function HasSleepingBagItem()
    return PlayerHasItem(211527)
end

--- Comprueba el estado del libro de Cocina para Expertos (ID #16072)
-- Retorna: stepNum, isCompleted, isEligible, currentSkill
local function GetExpertCookingProgress()
    local profs = ns.GetPlayerProfessions and ns.GetPlayerProfessions()
    local cook = profs and profs["Cooking"]

    if not cook or not cook.rank or cook.rank == 0 then
        return 1, false, false, 0
    end

    local rank = cook.rank or 0
    local maxRank = cook.maxRank or 150

    -- Si ya superó el rango oficial de 150 (maxRank 225 o skill > 150):
    -- Ya no necesita el libro; la guía se marca completada y se auto-oculta
    if rank > 150 or maxRank > 150 then
        return 2, true, false, rank
    end

    -- Si ya tiene el libro en sus bolsas pero aún no lo ha usado:
    if PlayerHasItem(16072) then
        return 2, false, true, rank -- Paso 2 (Aprender libro)
    end

    -- Si su nivel de cocina está en el rango óptimo (125 a 150):
    if rank >= 125 and rank <= 150 then
        return 1, false, true, rank -- Paso 1 (Comprar libro)
    end

    -- Menor a 125: aún no está en el rango recomendado
    return 1, false, false, rank
end

--- Devuelve el hito activo del secreto y si está completado al 100%
function ns.GetSecretProgress(secretKey)
    local faction = UnitFactionGroup("player") or "Alliance"
    local isAlliance = (faction == "Alliance")

    if secretKey == "expert_cooking" then
        return GetExpertCookingProgress()

    elseif secretKey == "sleeping_bag" then
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
        local turnInStep = isAlliance and 41 or 42
        local books = ns.Data.UniqueLibraryBooks or {}

        -- 1. Evaluar si ya completó los 3 Tiers de misiones oficiales de WoW Forever
        if IsQuestCompleted(82208) then
            -- Ha completado el Tier 3 (25 libros). Misión final superada.
            return turnInStep, true, 25, 3, 25
        end

        -- 2. Determinar el Tier activo y su meta de libros
        local currentTier = 1
        local targetCount = 10
        local tierQuestID = 78150

        if IsQuestCompleted(79536) then
            currentTier = 3
            targetCount = 25
            tierQuestID = 82208
        elseif IsQuestCompleted(78150) then
            currentTier = 2
            targetCount = 20
            tierQuestID = 79536
        else
            currentTier = 1
            targetCount = 10
            tierQuestID = 78150
        end

        -- 3. Contar libros únicos obtenidos (bolsas o quest completada/activa)
        local collectedCount = 0
        local firstIncomplete = nil

        for i = 1, 40 do
            local book = books[i]
            if book then
                local isCollected = false
                if book.itemID and PlayerHasItem(book.itemID) then
                    isCollected = true
                elseif book.questID and (IsQuestCompleted(book.questID) or IsQuestActive(book.questID)) then
                    isCollected = true
                end

                if isCollected then
                    collectedCount = collectedCount + 1
                else
                    -- Solo sugerir si está permitido para la facción del jugador
                    local factionOk = not book.faction or (book.faction == faction)
                    if factionOk and not firstIncomplete then
                        firstIncomplete = i
                    end
                end
            end
        end

        -- 4. Si el jugador ya tiene los libros necesarios para el tier activo, o tiene la quest de entrega activa:
        if collectedCount >= targetCount or IsQuestActive(tierQuestID) then
            return turnInStep, false, collectedCount, currentTier, targetCount
        end

        -- 5. Si aún le faltan libros, sugerir el siguiente libro de su facción
        return (firstIncomplete or 1), false, collectedCount, currentTier, targetCount

    elseif secretKey == "shadowforge_key" then
        if PlayerHasItem(11000) or IsQuestCompleted(4001) then
            return 3, true
        end
        return 1, false

    elseif secretKey == "sunken_chest" then
        if PlayerHasItem(5571) then
            return 2, true
        end
        return 1, false

    elseif secretKey == "tanaris_pirates" then
        if PlayerHasItem(9276) then
            return 2, true
        end
        return 1, false
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
    elseif key == "expert_cooking" then
        local faction = UnitFactionGroup("player") or "Alliance"
        secret.steps = (faction == "Horde") and ns.Data.ExpertCookingStepsHorde or ns.Data.ExpertCookingStepsAlliance
        local curStep, isDone, isEligible, rank = ns.GetSecretProgress("expert_cooking")
        secret.currentStep = curStep
        secret.isCompleted = isDone
        secret.isEligible = isEligible
        secret.currentSkill = rank
    elseif key == "library_books" then
        local faction = UnitFactionGroup("player") or "Alliance"
        local isAlliance = (faction == "Alliance")
        secret.steps = ns.Data.UniqueLibraryBooks
        local curStep, isDone, count, tier, targetCount = ns.GetSecretProgress("library_books")
        secret.currentStep = curStep
        secret.isCompleted = isDone
        secret.collectedCount = count
        secret.currentTier = tier or 1
        secret.targetCount = targetCount or 10

        -- Enriquecer dinámicamente el paso de entrega si está activo
        local step = secret.steps and secret.steps[curStep]
        if step and (curStep == 41 or curStep == 42) then
            local tierQuest = (secret.currentTier == 1 and 78150) or (secret.currentTier == 2 and 79536) or 82208
            local tierName = (secret.currentTier == 1 and "Friend of the Library") or "Greater Friend of the Library"
            step.questID = tierQuest
            step.title = string.format("Entrega Tier %d (%d/%d Tomos) — %s", secret.currentTier, secret.collectedCount or 0, secret.targetCount or 10, isAlliance and "Alianza" or "Horda")
            step.instruction = string.format("Lleva tus tomos a %s en %s para completar '%s' (#%d).",
                isAlliance and "Garion Wendell (Torre de los Magos)" or "Owen Thadd (Barrio de la Magia)",
                isAlliance and "Ciudad de Ventormenta" or "Entrañas", tierName, tierQuest)
        end
    else
        local curStep, isDone = ns.GetSecretProgress(key)
        secret.currentStep = curStep or 1
        secret.isCompleted = isDone or false
    end

    return secret
end

--- Devuelve el paso que representa el hito de destino real de una misión o secreto
function ns.GetSecretMilestoneTargetStep(secretKey, milestone)
    local secret = ns.GetSecret and ns.GetSecret(secretKey)
    if not secret or not secret.steps then return nil end
    local m = tonumber(milestone) or secret.currentStep or 1

    if secretKey == "sleeping_bag" then
        local faction = UnitFactionGroup("player") or "Alliance"
        if faction == "Alliance" then
            local targetIdx = ALLIANCE_MILESTONE_TARGET_STEP[m] or 1
            return ns.Data.SleepingBagStepsAlliance[targetIdx] or ns.Data.SleepingBagStepsAlliance[1]
        else
            return ns.Data.SleepingBagStepsHorde[m] or ns.Data.SleepingBagStepsHorde[1]
        end
    elseif secretKey == "expert_cooking" then
        local faction = UnitFactionGroup("player") or "Alliance"
        local steps = (faction == "Horde") and ns.Data.ExpertCookingStepsHorde or ns.Data.ExpertCookingStepsAlliance
        return steps[m] or steps[1]
    end

    return secret.steps[m] or secret.steps[1]
end

--- Devuelve el índice del primer paso del tramo de viaje hacia un hito
function ns.GetSecretMilestoneFirstStep(secretKey, milestone)
    local m = tonumber(milestone) or 1
    if secretKey == "sleeping_bag" then
        local faction = UnitFactionGroup("player") or "Alliance"
        if faction == "Alliance" then
            return ALLIANCE_MILESTONE_FIRST_STEP[m] or 1
        end
    end
    return m
end

--- Genera una guía dinámica adaptada a la ubicación en tiempo real del usuario
-- Si el usuario está lejos o en otro continente, calcula la ruta multimodal óptima usando TravelPlanner
-- y la complementa con el hito de misión enriquecido. Si está en la zona, devuelve la guía local enfocada.
function ns.GetDynamicSecretGuide(secretKey, curMilestone)
    local secret = ns.GetSecret and ns.GetSecret(secretKey)
    if not secret then return nil end

    local milestone = curMilestone or (ns.GetSecretProgress and ns.GetSecretProgress(secretKey)) or 1
    local targetStep = ns.GetSecretMilestoneTargetStep(secretKey, milestone)
    if not targetStep then
        local defaultFirst = ns.GetSecretMilestoneFirstStep(secretKey, milestone)
        return secret, defaultFirst
    end

    local playerLoc = ns.GetPlayerLocation and ns.GetPlayerLocation()
    if not playerLoc or not ns.TravelPlanner then
        local defaultFirst = ns.GetSecretMilestoneFirstStep(secretKey, milestone)
        return secret, defaultFirst
    end

    -- Si el jugador ya se encuentra en el mismo mapa del hito a corta distancia (< 1200 yardas):
    local directDist = ns.GetDistanceAndHeading and ns.GetDistanceAndHeading(playerLoc.mapID, playerLoc.x, playerLoc.y, targetStep.uiMapID, targetStep.x, targetStep.y)
    if directDist and directDist < 1200 and playerLoc.mapID == targetStep.uiMapID then
        local guideData = {
            title = string.format("%s · Hito %d", secret.title, milestone),
            category = secret.category or "Misión Secreta",
            icon = targetStep.icon or secret.icon,
            reward = secret.reward,
            steps = { targetStep },
            isDynamicTravel = true,
            secretKey = secretKey,
            milestone = milestone,
        }
        return guideData, 1
    end

    -- Calcular la ruta multimodal más eficiente desde la posición actual del jugador hacia el hito del secreto:
    local targetEndpoint = {
        uiMapID = targetStep.uiMapID,
        x = targetStep.x,
        y = targetStep.y,
        name = targetStep.title or secret.title,
        zoneName = targetStep.zoneName,
    }

    local plan = ns.TravelPlanner:CalculateRoute("__player__", targetEndpoint, { routingMode = "fastest" })
    if plan and plan.success and plan.guideData and plan.guideData.steps and #plan.guideData.steps > 0 then
        local dynamicSteps = {}
        local planSteps = plan.guideData.steps

        -- Insertamos las etapas de tránsito calculadas (vuelos, barcos, tranvías, caminatas intermedias)
        for i = 1, #planSteps - 1 do
            table.insert(dynamicSteps, planSteps[i])
        end

        -- Coronamos la guía con el hito de la misión enriquecido con instrucciones y recompensa
        table.insert(dynamicSteps, {
            stepNum = #dynamicSteps + 1,
            title = targetStep.title,
            instruction = targetStep.instruction,
            uiMapID = targetStep.uiMapID,
            zoneName = targetStep.zoneName,
            x = targetStep.x,
            y = targetStep.y,
            questID = targetStep.questID,
            nextQuestID = targetStep.nextQuestID,
            action = targetStep.action,
            tip = targetStep.tip,
            icon = targetStep.icon or "Interface\\Icons\\inv_misc_bag_bigbagofenchantments",
            isMilestone = true,
            milestone = milestone,
        })

        local legsDesc = (#plan.legs == 1) and "1 etapa directa" or string.format("%d etapas", #plan.legs)
        local guideData = {
            title = string.format("%s · Hito %d (~%.1f min)", secret.title, milestone, plan.totalMinutes or 0),
            category = "Ruta Dinámica · " .. (secret.category or "Secreto"),
            icon = targetStep.icon or secret.icon,
            reward = string.format("~%.1f min (%s)", plan.totalMinutes or 0, legsDesc),
            steps = dynamicSteps,
            isDynamicTravel = true,
            secretKey = secretKey,
            milestone = milestone,
        }

        return guideData, 1
    end

    -- Fallback canónico si no se generó ruta multimodal
    local defaultFirst = ns.GetSecretMilestoneFirstStep(secretKey, milestone)
    return secret, defaultFirst
end

--- Devuelve una estructura de punto final compatible con TravelPlanner para el hito del secreto
function ns.GetSecretTargetEndpoint(secretKey, stepIdx)
    local secret = ns.GetSecret and ns.GetSecret(secretKey)
    if not secret then return nil end
    local idx = stepIdx or secret.currentStep or 1
    local step = ns.GetSecretMilestoneTargetStep and ns.GetSecretMilestoneTargetStep(secretKey, idx)
    if not step then
        step = (secret.steps and secret.steps[idx]) or (secret.steps and secret.steps[1])
    end
    if not step then return nil end
    return {
        uiMapID = step.uiMapID,
        x = step.x,
        y = step.y,
        name = step.title or secret.title,
        zoneName = step.zoneName,
        secretKey = secretKey,
        stepNum = step.stepNum or idx,
    }
end

-- Inicialización inicial de pasos según facción
local function InitFactionSteps()
    local faction = UnitFactionGroup("player") or "Alliance"
    if ns.Data.Secrets and ns.Data.Secrets["sleeping_bag"] then
        ns.Data.Secrets["sleeping_bag"].steps = (faction == "Horde") and ns.Data.SleepingBagStepsHorde or ns.Data.SleepingBagStepsAlliance
    end
    if ns.Data.Secrets and ns.Data.Secrets["expert_cooking"] then
        ns.Data.Secrets["expert_cooking"].steps = (faction == "Horde") and ns.Data.ExpertCookingStepsHorde or ns.Data.ExpertCookingStepsAlliance
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