local ADDON, ns = ...

-- =========================================================================
-- GRAFO DE VIAJE MAESTRO: VUELOS, TRANVÍA, BARCOS Y ZEPELINES
-- =========================================================================
-- Inspirado en foreverdb.net/travel y enriquecido con metadatos de costes,
-- PNJs maestros de vuelo, iconos de transporte y detección de facción.
--
-- Tipos de nodo:
--   "flightmaster" : Maestro de vuelos oficial con montura aérea.
--   "boat"         : Muelle o embarcadero marítimo (intercontinental o regional).
--   "zeppelin"     : Torre de zepelín goblin / Horda.
--   "tram"         : Tranvía Subterráneo (Ventormenta <-> Forjaz).
--   "alias"        : Ciudad o poblado resuelto caminando al nodo real más cercano.
--   "walk"         : Punto bisagra de conexión a pie o nado comunitario.
--
-- Modos de arista:
--   "flight" | "boat" | "zeppelin" | "tram" | "walk" | "swim"
-- =========================================================================

ns.Data = ns.Data or {}

ns.Data.Travel = {
    -- Iconografía nativa 100% verificada para Classic Era / Beta (previene ASSERT(fileDataID))
    MODE_ICONS = {
        flight_alliance = "Interface\\Icons\\ability_mount_ridinghorse",
        flight_horde    = "Interface\\Icons\\ability_mount_ridinghorse",
        flight_neutral  = "Interface\\Icons\\ability_mount_ridinghorse",
        boat            = "Interface\\Icons\\inv_misc_map_01",
        zeppelin        = "Interface\\Icons\\inv_misc_bag_08",
        tram            = "Interface\\Icons\\inv_misc_gear_01",
        walk            = "Interface\\Icons\\ability_rogue_sprint",
        swim            = "Interface\\Icons\\spell_frost_frostarmor",
        hearthstone     = "Interface\\Icons\\inv_misc_rune_01",
        portal          = "Interface\\Icons\\spell_arcane_teleportstormwind",
    },

    nodes = {
        -- =================================================================
        -- REINOS DEL ESTE — ALIANZA & TRANVÍA
        -- =================================================================
        stormwind = {
            name = "Ciudad de Ventormenta", zoneName = "Ciudad de Ventormenta",
            continent = "Eastern Kingdoms", uiMapID = 1453, x = 71.3, y = 72.3,
            type = "flightmaster", faction = "alliance", npcName = "Dungar Tragalargo",
            levelMin = 1, verified = true,
        },
        goldshire = {
            name = "Villadorada", zoneName = "Bosque de Elwynn",
            continent = "Eastern Kingdoms", uiMapID = 1429, x = 42.6, y = 65.8,
            type = "walk", faction = "alliance",
            levelMin = 1, verified = true,
        },
        sentinel_hill = {
            name = "Colina del Centinela", zoneName = "Páramos de Poniente",
            continent = "Eastern Kingdoms", uiMapID = 1436, x = 56.6, y = 52.6,
            type = "flightmaster", faction = "alliance", npcName = "Thor",
            levelMin = 10, verified = true,
        },
        lakeshire = {
            name = "Villa del Lago", zoneName = "Montañas Crestagrana",
            continent = "Eastern Kingdoms", uiMapID = 1433, x = 25.5, y = 59.4,
            type = "flightmaster", faction = "alliance", npcName = "Ariena Tempestad",
            levelMin = 15, verified = true,
        },
        darkshire = {
            name = "Villa Oscura", zoneName = "Bosque del Ocaso",
            continent = "Eastern Kingdoms", uiMapID = 1431, x = 77.5, y = 44.3,
            type = "flightmaster", faction = "alliance", npcName = "Felicia Maline",
            levelMin = 18, verified = true,
        },
        ironforge = {
            name = "Forjaz", zoneName = "Forjaz",
            continent = "Eastern Kingdoms", uiMapID = 1455, x = 55.5, y = 47.7,
            type = "flightmaster", faction = "alliance", npcName = "Gryth Jardinero",
            levelMin = 1, verified = true,
        },
        thelsamar = {
            name = "Thelsamar", zoneName = "Loch Modan",
            continent = "Eastern Kingdoms", uiMapID = 1432, x = 33.9, y = 50.9,
            type = "flightmaster", faction = "alliance", npcName = "Thorgrum Borrascopico",
            levelMin = 10, verified = true,
        },
        menethil = {
            name = "Puerto de Menethil (Vuelo)", zoneName = "Los Humedales",
            continent = "Eastern Kingdoms", uiMapID = 1437, x = 9.5, y = 59.7,
            type = "flightmaster", faction = "alliance", npcName = "Shellei Brimbles",
            levelMin = 20, verified = true,
        },
        refuge_pointe = {
            name = "Refugio de la Zahúrda", zoneName = "Tierras Altas de Arathi",
            continent = "Eastern Kingdoms", uiMapID = 1417, x = 45.8, y = 46.1,
            type = "flightmaster", faction = "alliance", npcName = "Cedrik Próspero",
            levelMin = 30, verified = true,
        },
        southshore = {
            name = "Costasur", zoneName = "Laderas de Trabalomas",
            continent = "Eastern Kingdoms", uiMapID = 1424, x = 49.3, y = 52.3,
            type = "flightmaster", faction = "alliance", npcName = "Darren Malaespina",
            levelMin = 28, verified = true,
        },
        aerie_peak = {
            name = "Pico Nidal", zoneName = "Tierras del Interior",
            continent = "Eastern Kingdoms", uiMapID = 1425, x = 11.1, y = 46.1,
            type = "flightmaster", faction = "alliance", npcName = "Guthrum Pico Trueno",
            levelMin = 40, verified = true,
        },
        chillwind = {
            name = "Campamento del Orvallo", zoneName = "Tierras de la Peste del Oeste",
            continent = "Eastern Kingdoms", uiMapID = 1422, x = 42.9, y = 85.0,
            type = "flightmaster", faction = "alliance", npcName = "Bibilina Silbaguja",
            levelMin = 50, verified = true,
        },
        morgans_vigil = {
            name = "Vigilia de Morgan", zoneName = "Estepas Ardientes",
            continent = "Eastern Kingdoms", uiMapID = 1428, x = 84.4, y = 68.3,
            type = "flightmaster", faction = "alliance", npcName = "Brakkar",
            levelMin = 50, verified = true,
        },
        nethergarde = {
            name = "Castillo de Nethergarde", zoneName = "Tierras Devastadas",
            continent = "Eastern Kingdoms", uiMapID = 1419, x = 65.5, y = 24.3,
            type = "flightmaster", faction = "alliance", npcName = "Thurman Cortavientos",
            levelMin = 45, verified = true,
        },
        booty_bay_ali = {
            name = "Bahía del Botín (Alianza)", zoneName = "Vega de Tuercespina",
            continent = "Eastern Kingdoms", uiMapID = 1442, x = 27.5, y = 77.8,
            type = "flightmaster", faction = "alliance", npcName = "Gorkas",
            levelMin = 30, verified = true,
        },

        -- TRANVÍA SUBTERRÁNEO (SW <-> IF)
        deeprun_tram_sw = {
            name = "Tranvía (Ventormenta)", zoneName = "Ciudad de Ventormenta",
            continent = "Eastern Kingdoms", uiMapID = 1453, x = 66.7, y = 33.7,
            type = "tram", faction = "alliance", levelMin = 1, verified = true,
        },
        deeprun_tram_if = {
            name = "Tranvía (Forjaz)", zoneName = "Forjaz",
            continent = "Eastern Kingdoms", uiMapID = 1455, x = 76.5, y = 51.5,
            type = "tram", faction = "alliance", levelMin = 1, verified = true,
        },

        -- =================================================================
        -- REINOS DEL ESTE — HORDA & ZEPELINES
        -- =================================================================
        undercity = {
            name = "Entrañas", zoneName = "Entrañas",
            continent = "Eastern Kingdoms", uiMapID = 1458, x = 63.8, y = 48.6,
            type = "flightmaster", faction = "horde", npcName = "Michael Garrett",
            levelMin = 1, verified = true,
        },
        brill = {
            name = "Brill", zoneName = "Claros de Tirisfal",
            continent = "Eastern Kingdoms", uiMapID = 1420, x = 51.0, y = 58.0,
            type = "walk", faction = "horde",
            levelMin = 1, verified = true,
        },
        sepulcher = {
            name = "El Sepulcro", zoneName = "Bosque de Argénteos",
            continent = "Eastern Kingdoms", uiMapID = 1421, x = 45.6, y = 42.6,
            type = "flightmaster", faction = "horde", npcName = "Karos Razok",
            levelMin = 10, verified = true,
        },
        tarren_mill = {
            name = "Molino Tarren", zoneName = "Laderas de Trabalomas",
            continent = "Eastern Kingdoms", uiMapID = 1424, x = 60.1, y = 18.6,
            type = "flightmaster", faction = "horde", npcName = "Zarise",
            levelMin = 20, verified = true,
        },
        revantusk = {
            name = "Poblado Revantusk", zoneName = "Tierras del Interior",
            continent = "Eastern Kingdoms", uiMapID = 1425, x = 78.2, y = 81.3,
            type = "flightmaster", faction = "horde", npcName = "Grik'tha",
            levelMin = 40, verified = true,
        },
        hammerfall = {
            name = "Sentencia", zoneName = "Tierras Altas de Arathi",
            continent = "Eastern Kingdoms", uiMapID = 1417, x = 73.1, y = 32.7,
            type = "flightmaster", faction = "horde", npcName = "Gorrik",
            levelMin = 30, verified = true,
        },
        kargath = {
            name = "Kargath", zoneName = "Tierras Inhóspitas",
            continent = "Eastern Kingdoms", uiMapID = 1418, x = 4.0, y = 44.8,
            type = "flightmaster", faction = "horde", npcName = "Goran",
            levelMin = 35, verified = true,
        },
        flame_crest = {
            name = "Cresta de Fuego", zoneName = "Estepas Ardientes",
            continent = "Eastern Kingdoms", uiMapID = 1428, x = 65.7, y = 24.2,
            type = "flightmaster", faction = "horde", npcName = "Vhaarr",
            levelMin = 50, verified = true,
        },
        gromgol = {
            name = "Campamento Grom'gol (Vuelo)", zoneName = "Vega de Tuercespina",
            continent = "Eastern Kingdoms", uiMapID = 1442, x = 32.5, y = 29.4,
            type = "flightmaster", faction = "horde", npcName = "Nimboya",
            levelMin = 30, verified = true,
        },
        booty_bay_horde = {
            name = "Bahía del Botín (Horda)", zoneName = "Vega de Tuercespina",
            continent = "Eastern Kingdoms", uiMapID = 1442, x = 26.9, y = 77.1,
            type = "flightmaster", faction = "horde", npcName = "Grizlak",
            levelMin = 30, verified = true,
        },

        -- =================================================================
        -- REINOS DEL ESTE — NODOS NEUTRALES
        -- =================================================================
        thorium_point = {
            name = "Puesto del Torio", zoneName = "Garganta de Fuego",
            continent = "Eastern Kingdoms", uiMapID = 1427, x = 37.9, y = 30.9,
            type = "flightmaster", faction = "neutral", npcName = "Lanie Zarzagrís",
            levelMin = 45, verified = true,
        },
        lights_hope = {
            name = "Capilla de la Esperanza de la Luz", zoneName = "Tierras de la Peste del Este",
            continent = "Eastern Kingdoms", uiMapID = 1423, x = 81.6, y = 57.9,
            type = "flightmaster", faction = "neutral", npcName = "Georgia",
            levelMin = 55, verified = true,
        },

        -- =================================================================
        -- KALIMDOR — ALIANZA
        -- =================================================================
        ruttheran = {
            name = "Aldea Rut'theran", zoneName = "Teldrassil",
            continent = "Kalimdor", uiMapID = 1439, x = 58.4, y = 94.0,
            type = "flightmaster", faction = "alliance", npcName = "Vesprystus",
            levelMin = 1, verified = true,
        },
        darnassus = {
            name = "Darnassus", zoneName = "Darnassus",
            continent = "Kalimdor", uiMapID = 1456, x = 48.0, y = 30.0,
            type = "walk", faction = "alliance",
            levelMin = 1, verified = true,
        },
        auberdine = {
            name = "Auberdine (Vuelo)", zoneName = "Costa Oscura",
            continent = "Kalimdor", uiMapID = 1438, x = 36.3, y = 45.6,
            type = "flightmaster", faction = "alliance", npcName = "Caylais Sombraluna",
            levelMin = 10, verified = true,
        },
        astranaar = {
            name = "Astranaar", zoneName = "Vallefresno",
            continent = "Kalimdor", uiMapID = 1440, x = 34.4, y = 48.0,
            type = "flightmaster", faction = "alliance", npcName = "Daelyshia",
            levelMin = 18, verified = true,
        },
        stonetalon_peak = {
            name = "Cima del Espolón", zoneName = "Sierra Espolón",
            continent = "Kalimdor", uiMapID = 1442, x = 36.4, y = 7.2,
            type = "flightmaster", faction = "alliance", npcName = "Thyssiana",
            levelMin = 20, verified = true,
        },
        nijels_point = {
            name = "Puesto de Nijel", zoneName = "Desolace",
            continent = "Kalimdor", uiMapID = 1443, x = 64.7, y = 10.5,
            type = "flightmaster", faction = "alliance", npcName = "Baristol",
            levelMin = 30, verified = true,
        },
        theramore = {
            name = "Isla Theramore (Vuelo)", zoneName = "Marjal Revolcafango",
            continent = "Kalimdor", uiMapID = 1445, x = 67.5, y = 51.3,
            type = "flightmaster", faction = "alliance", npcName = "Baldruc",
            levelMin = 30, verified = true,
        },
        thalanaar = {
            name = "Thalanaar", zoneName = "Feralas",
            continent = "Kalimdor", uiMapID = 1444, x = 89.5, y = 45.9,
            type = "flightmaster", faction = "alliance", npcName = "Kersok Pluma del Viento",
            levelMin = 40, verified = true,
        },
        feathermoon = {
            name = "Bastión Plumaluna", zoneName = "Feralas",
            continent = "Kalimdor", uiMapID = 1444, x = 30.2, y = 43.2,
            type = "flightmaster", faction = "alliance", npcName = "Fyldan",
            levelMin = 40, verified = true,
        },

        -- =================================================================
        -- KALIMDOR — HORDA
        -- =================================================================
        orgrimmar = {
            name = "Orgrimmar", zoneName = "Orgrimmar",
            continent = "Kalimdor", uiMapID = 1454, x = 45.1, y = 63.9,
            type = "flightmaster", faction = "horde", npcName = "Doras",
            levelMin = 1, verified = true,
        },
        razor_hill = {
            name = "Cerco del Filo", zoneName = "Durotar",
            continent = "Kalimdor", uiMapID = 1411, x = 52.0, y = 43.0,
            type = "walk", faction = "horde",
            levelMin = 1, verified = true,
        },
        crossroads = {
            name = "El Cruce", zoneName = "Los Baldíos",
            continent = "Kalimdor", uiMapID = 1413, x = 51.5, y = 30.3,
            type = "flightmaster", faction = "horde", npcName = "Devrak",
            levelMin = 10, verified = true,
        },
        camp_taurajo = {
            name = "Campamento Taurajo", zoneName = "Los Baldíos",
            continent = "Kalimdor", uiMapID = 1413, x = 44.4, y = 59.2,
            type = "flightmaster", faction = "horde", npcName = "Omusa Cuerno de Trueno",
            levelMin = 20, verified = true,
        },
        thunderbluff = {
            name = "Cima del Trueno", zoneName = "Cima del Trueno",
            continent = "Kalimdor", uiMapID = 1457, x = 47.0, y = 49.8,
            type = "flightmaster", faction = "horde", npcName = "Tal",
            levelMin = 1, verified = true,
        },
        bloodhoof = {
            name = "Poblado Pezuña de Sangre", zoneName = "Mulgore",
            continent = "Kalimdor", uiMapID = 1412, x = 47.0, y = 60.0,
            type = "walk", faction = "horde",
            levelMin = 1, verified = true,
        },
        sun_rock = {
            name = "Refugio Roca del Sol", zoneName = "Sierra Espolón",
            continent = "Kalimdor", uiMapID = 1442, x = 47.4, y = 61.6,
            type = "flightmaster", faction = "horde", npcName = "Thrak'gul",
            levelMin = 20, verified = true,
        },
        splintertree = {
            name = "Puesto Rompemaderos", zoneName = "Vallefresno",
            continent = "Kalimdor", uiMapID = 1440, x = 73.2, y = 61.6,
            type = "flightmaster", faction = "horde", npcName = "Vhulga",
            levelMin = 20, verified = true,
        },
        zoramgar = {
            name = "Avanzada Zoram'gar", zoneName = "Vallefresno",
            continent = "Kalimdor", uiMapID = 1440, x = 12.2, y = 33.8,
            type = "flightmaster", faction = "horde", npcName = "Andruk",
            levelMin = 20, verified = true,
        },
        shadowprey = {
            name = "Aldea Cazasombras", zoneName = "Desolace",
            continent = "Kalimdor", uiMapID = 1443, x = 21.6, y = 74.1,
            type = "flightmaster", faction = "horde", npcName = "Brakgul",
            levelMin = 30, verified = true,
        },
        freewind_post = {
            name = "Poblado Viento Libre", zoneName = "Las Mil Agujas",
            continent = "Kalimdor", uiMapID = 1441, x = 42.1, y = 49.0,
            type = "flightmaster", faction = "horde", npcName = "Nyse",
            levelMin = 25, verified = true,
        },
        brackenwall = {
            name = "Poblado Murohelecho", zoneName = "Marjal Revolcafango",
            continent = "Kalimdor", uiMapID = 1445, x = 35.6, y = 31.9,
            type = "flightmaster", faction = "horde", npcName = "Shalas",
            levelMin = 35, verified = true,
        },
        camp_mojache = {
            name = "Campamento Mojache", zoneName = "Feralas",
            continent = "Kalimdor", uiMapID = 1444, x = 75.4, y = 44.3,
            type = "flightmaster", faction = "horde", npcName = "Shyn",
            levelMin = 40, verified = true,
        },

        -- =================================================================
        -- KALIMDOR — NODOS NEUTRALES
        -- =================================================================
        ratchet = {
            name = "Trinquete (Pueblo)", zoneName = "Los Baldíos",
            continent = "Kalimdor", uiMapID = 1413, x = 63.1, y = 37.2,
            type = "boat", faction = "neutral", levelMin = 15, verified = true,
        },
        gadgetzan = {
            name = "Gadgetzan", zoneName = "Tanaris",
            continent = "Kalimdor", uiMapID = 1446, x = 51.5, y = 25.4,
            type = "flightmaster", faction = "neutral", npcName = "Bera Tejehumo",
            levelMin = 40, verified = true,
        },
        marshals_stand = {
            name = "Puesto de Marshal", zoneName = "Cráter de Un'Goro",
            continent = "Kalimdor", uiMapID = 1449, x = 45.2, y = 5.8,
            type = "flightmaster", faction = "neutral", npcName = "Gryfe",
            levelMin = 48, verified = true,
        },
        cenarion_hold = {
            name = "Fuerte Cenarion", zoneName = "Silithus",
            continent = "Kalimdor", uiMapID = 1451, x = 50.6, y = 34.4,
            type = "flightmaster", faction = "neutral", npcName = "Cloud Runner",
            levelMin = 55, verified = true,
        },
        everlook = {
            name = "Vista Eterna", zoneName = "Cuna del Invierno",
            continent = "Kalimdor", uiMapID = 1452, x = 62.3, y = 36.6,
            type = "flightmaster", faction = "neutral", npcName = "Maethrym",
            levelMin = 55, verified = true,
        },

        -- =================================================================
        -- MUELLES, PUERTOS & EMBARCADEROS MARÍTIMOS
        -- =================================================================
        booty_bay_pier = {
            name = "Muelle de Bahía del Botín", zoneName = "Vega de Tuercespina",
            continent = "Eastern Kingdoms", uiMapID = 1442, x = 27.5, y = 76.5,
            type = "boat", faction = "neutral", verified = true,
        },
        ratchet_pier = {
            name = "Muelle de Trinquete", zoneName = "Los Baldíos",
            continent = "Kalimdor", uiMapID = 1413, x = 63.8, y = 38.8,
            type = "boat", faction = "neutral", verified = true,
        },
        menethil_pier = {
            name = "Muelle de Menethil (Barco Auberdine/Costasur)", zoneName = "Los Humedales",
            continent = "Eastern Kingdoms", uiMapID = 1437, x = 4.7, y = 57.2,
            type = "boat", faction = "alliance", verified = true,
        },
        menethil_pier_theramore = {
            name = "Muelle de Menethil (Barco a Theramore)", zoneName = "Los Humedales",
            continent = "Eastern Kingdoms", uiMapID = 1437, x = 5.0, y = 63.5,
            type = "boat", faction = "alliance", verified = true,
        },
        theramore_pier = {
            name = "Muelle de Theramore", zoneName = "Marjal Revolcafango",
            continent = "Kalimdor", uiMapID = 1445, x = 67.2, y = 52.1,
            type = "boat", faction = "alliance", verified = true,
        },
        stormwind_harbor = {
            name = "Puerto de Ventormenta (Barco)", zoneName = "Ciudad de Ventormenta",
            continent = "Eastern Kingdoms", uiMapID = 1453, x = 22.7, y = 56.0,
            type = "boat", faction = "alliance", verified = true,
        },
        auberdine_dock_sw = {
            name = "Muelle Oeste (Auberdine -> Ventormenta)", zoneName = "Costa Oscura",
            continent = "Kalimdor", uiMapID = 1438, x = 30.7, y = 41.0,
            type = "boat", faction = "alliance", verified = true,
        },
        auberdine_dock_south = {
            name = "Muelle Sur (Auberdine -> Menethil/Costasur)", zoneName = "Costa Oscura",
            continent = "Kalimdor", uiMapID = 1438, x = 32.4, y = 43.8,
            type = "boat", faction = "alliance", verified = true,
        },
        auberdine_dock_north = {
            name = "Muelle Norte (Auberdine -> Rut'theran)", zoneName = "Costa Oscura",
            continent = "Kalimdor", uiMapID = 1438, x = 33.2, y = 40.2,
            type = "boat", faction = "alliance", verified = true,
        },
        auberdine_pier = {
            name = "Muelle de Auberdine", zoneName = "Costa Oscura",
            continent = "Kalimdor", uiMapID = 1438, x = 32.4, y = 42.0,
            type = "boat", faction = "alliance", verified = true,
        },
        southshore_pier = {
            name = "Muelle de Costasur (Barco a Menethil/Auberdine)", zoneName = "Laderas de Trabalomas",
            continent = "Eastern Kingdoms", uiMapID = 1424, x = 50.6, y = 69.7,
            type = "boat", faction = "alliance", verified = true,
        },
        ruttheran_pier = {
            name = "Muelle de Rut'theran", zoneName = "Teldrassil",
            continent = "Kalimdor", uiMapID = 1439, x = 55.4, y = 92.2,
            type = "boat", faction = "alliance", verified = true,
        },

        -- =================================================================
        -- TORRES DE ZEPELÍN (HORDA)
        -- =================================================================
        orgrimmar_zep = {
            name = "Torre Zepelín de Orgrimmar", zoneName = "Durotar",
            continent = "Kalimdor", uiMapID = 1454, x = 50.8, y = 14.2,
            type = "zeppelin", faction = "horde", verified = true,
        },
        undercity_zep = {
            name = "Torre Zepelín de Brill", zoneName = "Claros de Tirisfal",
            continent = "Eastern Kingdoms", uiMapID = 1420, x = 60.6, y = 58.8,
            type = "zeppelin", faction = "horde", verified = true,
        },
        gromgol_zep = {
            name = "Torre Zepelín de Grom'gol", zoneName = "Vega de Tuercespina",
            continent = "Eastern Kingdoms", uiMapID = 1442, x = 31.4, y = 29.8,
            type = "zeppelin", faction = "horde", verified = true,
        },

        -- =================================================================
        -- CONECTORES A PIE / NADO COMUNITARIOS
        -- =================================================================
        westfall_coast = {
            name = "Faro de Westfall", zoneName = "Páramos de Poniente",
            continent = "Eastern Kingdoms", uiMapID = 1436, x = 30.0, y = 86.0,
            type = "walk", faction = "alliance", verified = true,
        },

        -- =================================================================
        -- NUEVAS ZONAS INTEGRADAS — WORLD OF WARCRAFT FOREVER
        -- =================================================================
        -- 1. RIVERGLADES (MAP ID 16591, niveles 35-45)
        riverglades_powderfuse = {
            name = "Puerto Powderfuse", zoneName = "Riverglades",
            continent = "Kalimdor", uiMapID = 16591, x = 25.0, y = 72.0,
            type = "boat", faction = "neutral", levelMin = 35, verified = true,
        },
        riverglades_crawglawe = {
            name = "Fuerte Crawglawe (Banda)", zoneName = "Riverglades",
            continent = "Kalimdor", uiMapID = 16591, x = 48.0, y = 45.0,
            type = "walk", faction = "neutral", levelMin = 35, verified = true,
        },
        riverglades_kroldok = {
            name = "Bastión Krol'dok (Mazmorra 40-45)", zoneName = "Riverglades",
            continent = "Kalimdor", uiMapID = 16591, x = 65.0, y = 30.0,
            type = "walk", faction = "neutral", levelMin = 40, verified = true,
        },

        -- 2. ZEPHRAS ISLE (MAP ID 2521, niveles 1-12, Plano Elemental & Cielonatos)
        zephras_spawn = {
            name = "Zona Inicial Cielonato", zoneName = "Zephras Isle",
            continent = "Kalimdor", uiMapID = 2521, x = 60.0, y = 70.0,
            type = "walk", faction = "neutral", levelMin = 1, verified = true,
        },
        zephras_dock_alliance = {
            name = "Muelle Alianza (Zephras Isle)", zoneName = "Zephras Isle",
            continent = "Kalimdor", uiMapID = 2521, x = 65.8, y = 83.4,
            type = "boat", faction = "alliance", levelMin = 12, verified = true,
        },
        zephras_dock_horde = {
            name = "Muelle Horda (Zephras Isle)", zoneName = "Zephras Isle",
            continent = "Kalimdor", uiMapID = 2521, x = 57.9, y = 80.7,
            type = "boat", faction = "horde", levelMin = 12, verified = true,
        },
        mulgore_skywatcher = {
            name = "Meseta Vigía del Cielo (Mulgore)", zoneName = "Mulgore",
            continent = "Kalimdor", uiMapID = 1412, x = 34.3, y = 25.7,
            type = "boat", faction = "horde", levelMin = 10, verified = true,
        },
        dalaran_flying_boat = {
            name = "Barco Volador a Zephras (Dalaran)", zoneName = "Montañas de Alterac",
            continent = "Eastern Kingdoms", uiMapID = 1416, x = 12.7, y = 52.1,
            type = "boat", faction = "alliance", levelMin = 12, verified = true,
        },
        stormwind_wizard_sanctum = {
            name = "Santuario del Mago (Portal a Dalaran)", zoneName = "Ciudad de Ventormenta",
            continent = "Eastern Kingdoms", uiMapID = 1453, x = 49.4, y = 86.9,
            type = "portal", faction = "alliance", levelMin = 12, verified = true,
        },
        dalaran_sanctum_portal = {
            name = "Dalaran (Portal al Santuario del Mago)", zoneName = "Montañas de Alterac",
            continent = "Eastern Kingdoms", uiMapID = 1416, x = 15.0, y = 55.0,
            type = "portal", faction = "alliance", levelMin = 12, verified = true,
        },

        -- 3. MONTE HYJAL (MAP ID 616, nivel 60)
        hyjal_entrance = {
            name = "Entrada a Monte Hyjal", zoneName = "Monte Hyjal",
            continent = "Kalimdor", uiMapID = 616, x = 42.0, y = 65.0,
            type = "walk", faction = "neutral", levelMin = 60, verified = true,
        },
        hyjal_darkwhisper = {
            name = "Desfiladero Susurros Oscuros", zoneName = "Monte Hyjal",
            continent = "Kalimdor", uiMapID = 616, x = 38.0, y = 80.0,
            type = "walk", faction = "neutral", levelMin = 60, verified = true,
        },
        hyjal_summit = {
            name = "Cima Hyjal (Banda 20j)", zoneName = "Monte Hyjal",
            continent = "Kalimdor", uiMapID = 616, x = 55.0, y = 35.0,
            type = "walk", faction = "neutral", levelMin = 60, verified = true,
        },

        -- 4. SHEN'DRALAS (MAP ID 16651, niveles 40-50, Corredor Desolace <-> Mulgore)
        shendralas_outpost = {
            name = "Puesto Shen'dralar", zoneName = "Shen'Dralas",
            continent = "Kalimdor", uiMapID = 16651, x = 50.0, y = 50.0,
            type = "walk", faction = "neutral", levelMin = 40, verified = true,
        },
    },

    -- =====================================================================
    -- ARISTAS Y RUTAS CONECTADAS DEL GRAFO
    -- =====================================================================
    edges = {
        -- ==================== ALIANZA — REINOS DEL ESTE ====================
        { from = "stormwind", to = "sentinel_hill", mode = "flight", minutes = 2.0, costCopper = 80 },
        { from = "stormwind", to = "darkshire",     mode = "flight", minutes = 2.5, costCopper = 90 },
        { from = "stormwind", to = "lakeshire",     mode = "flight", minutes = 2.5, costCopper = 90 },
        { from = "stormwind", to = "ironforge",     mode = "flight", minutes = 3.5, costCopper = 150 },
        { from = "stormwind", to = "menethil",      mode = "flight", minutes = 5.0, costCopper = 220 },
        { from = "stormwind", to = "nethergarde",   mode = "flight", minutes = 3.5, costCopper = 175 },
        { from = "stormwind", to = "morgans_vigil", mode = "flight", minutes = 3.0, costCopper = 140 },

        { from = "sentinel_hill", to = "darkshire", mode = "flight", minutes = 2.0, costCopper = 75 },
        { from = "sentinel_hill", to = "booty_bay_ali", mode = "flight", minutes = 4.0, costCopper = 190 },

        { from = "darkshire", to = "lakeshire",     mode = "flight", minutes = 2.5, costCopper = 90 },
        { from = "darkshire", to = "booty_bay_ali", mode = "flight", minutes = 3.5, costCopper = 160 },
        { from = "darkshire", to = "nethergarde",   mode = "flight", minutes = 3.0, costCopper = 135 },

        { from = "ironforge", to = "thelsamar",     mode = "flight", minutes = 2.0, costCopper = 70 },
        { from = "ironforge", to = "menethil",      mode = "flight", minutes = 3.0, costCopper = 110 },
        { from = "ironforge", to = "southshore",    mode = "flight", minutes = 4.0, costCopper = 170 },
        { from = "ironforge", to = "refuge_pointe", mode = "flight", minutes = 3.5, costCopper = 150 },
        { from = "ironforge", to = "aerie_peak",    mode = "flight", minutes = 4.5, costCopper = 200 },
        { from = "ironforge", to = "thorium_point", mode = "flight", minutes = 2.5, costCopper = 100 },

        { from = "thelsamar", to = "refuge_pointe", mode = "flight", minutes = 3.0, costCopper = 120 },
        { from = "menethil",  to = "refuge_pointe", mode = "flight", minutes = 2.5, costCopper = 95 },
        { from = "menethil",  to = "southshore",    mode = "flight", minutes = 4.5, costCopper = 190 },
        { from = "refuge_pointe", to = "southshore", mode = "flight", minutes = 2.0, costCopper = 80 },
        { from = "refuge_pointe", to = "aerie_peak", mode = "flight", minutes = 2.5, costCopper = 95 },
        { from = "southshore", to = "aerie_peak",    mode = "flight", minutes = 2.5, costCopper = 90 },
        { from = "southshore", to = "chillwind",     mode = "flight", minutes = 2.5, costCopper = 100 },
        { from = "aerie_peak", to = "chillwind",     mode = "flight", minutes = 3.0, costCopper = 120 },
        { from = "chillwind", to = "lights_hope",    mode = "flight", minutes = 3.5, costCopper = 150 },

        { from = "morgans_vigil", to = "thorium_point", mode = "flight", minutes = 2.5, costCopper = 110 },
        { from = "morgans_vigil", to = "nethergarde",   mode = "flight", minutes = 3.0, costCopper = 130 },

        -- Conexiones de camino a pie entre zonas vecinas (Elwynn, Páramos, Crestagrana, Bosque del Ocaso)
        { from = "stormwind",     to = "goldshire",     mode = "walk", minutes = 2.5, costCopper = 0 },
        { from = "goldshire",     to = "lakeshire",     mode = "walk", minutes = 3.5, costCopper = 0 },
        { from = "goldshire",     to = "sentinel_hill", mode = "walk", minutes = 3.0, costCopper = 0 },
        { from = "goldshire",     to = "darkshire",     mode = "walk", minutes = 3.5, costCopper = 0 },
        { from = "lakeshire",     to = "darkshire",     mode = "walk", minutes = 3.0, costCopper = 0 },

        -- Conexiones de camino a pie en Dun Morogh / Loch Modan / Humedales / Arathi
        { from = "ironforge",     to = "thelsamar",     mode = "walk", minutes = 3.0, costCopper = 0 },
        { from = "thelsamar",     to = "menethil",      mode = "walk", minutes = 4.0, costCopper = 0 },
        { from = "menethil",      to = "refuge_pointe", mode = "walk", minutes = 4.5, costCopper = 0 },
        { from = "refuge_pointe", to = "southshore",    mode = "walk", minutes = 3.5, costCopper = 0 },

        -- TRANVÍA SUBTERRÁNEO (SW <-> IF): Instantáneo/1 min, gratuito y seguro
        { from = "stormwind", to = "deeprun_tram_sw", mode = "walk", minutes = 1.0, costCopper = 0 },
        { from = "ironforge", to = "deeprun_tram_if", mode = "walk", minutes = 1.0, costCopper = 0 },
        { from = "deeprun_tram_sw", to = "deeprun_tram_if", mode = "tram", minutes = 1.0, costCopper = 0, faction = "alliance" },

        -- Conectores a muelles y puertos de la Alianza
        { from = "stormwind", to = "stormwind_harbor", mode = "walk", minutes = 1.2, costCopper = 0 },
        { from = "deeprun_tram_sw", to = "stormwind_harbor", mode = "walk", minutes = 1.5, costCopper = 0 },
        { from = "menethil", to = "menethil_pier", mode = "walk", minutes = 0.4, costCopper = 0 },
        { from = "menethil", to = "menethil_pier_theramore", mode = "walk", minutes = 0.5, costCopper = 0 },
        { from = "menethil_pier", to = "menethil_pier_theramore", mode = "walk", minutes = 0.3, costCopper = 0 },
        { from = "southshore", to = "southshore_pier", mode = "walk", minutes = 0.5, costCopper = 0 },
        { from = "booty_bay_ali", to = "booty_bay_pier", mode = "walk", minutes = 0.5, costCopper = 0 },

        -- ==================== HORDA — REINOS DEL ESTE ====================
        { from = "undercity", to = "sepulcher",   mode = "flight", minutes = 1.5, costCopper = 60 },
        { from = "undercity", to = "tarren_mill",  mode = "flight", minutes = 2.5, costCopper = 95 },
        { from = "undercity", to = "hammerfall",   mode = "flight", minutes = 3.5, costCopper = 145 },
        { from = "undercity", to = "revantusk",    mode = "flight", minutes = 4.0, costCopper = 180 },

        { from = "tarren_mill", to = "hammerfall", mode = "flight", minutes = 2.5, costCopper = 90 },
        { from = "tarren_mill", to = "revantusk",  mode = "flight", minutes = 2.5, costCopper = 95 },
        { from = "tarren_mill", to = "kargath",    mode = "flight", minutes = 4.5, costCopper = 190 },

        { from = "hammerfall", to = "revantusk",   mode = "flight", minutes = 2.5, costCopper = 90 },
        { from = "hammerfall", to = "kargath",     mode = "flight", minutes = 3.5, costCopper = 140 },

        { from = "kargath", to = "flame_crest",    mode = "flight", minutes = 2.5, costCopper = 100 },
        { from = "kargath", to = "gromgol",        mode = "flight", minutes = 4.5, costCopper = 210 },
        { from = "kargath", to = "thorium_point",  mode = "flight", minutes = 2.0, costCopper = 80 },

        { from = "flame_crest", to = "thorium_point", mode = "flight", minutes = 2.0, costCopper = 80 },
        { from = "flame_crest", to = "gromgol",       mode = "flight", minutes = 4.0, costCopper = 180 },

        { from = "gromgol", to = "booty_bay_horde",   mode = "flight", minutes = 2.0, costCopper = 70 },
        { from = "gromgol", to = "gromgol_zep",       mode = "walk",   minutes = 0.5, costCopper = 0 },
        { from = "booty_bay_horde", to = "booty_bay_pier", mode = "walk", minutes = 0.5, costCopper = 0 },

        { from = "undercity", to = "undercity_zep",   mode = "walk",   minutes = 1.0, costCopper = 0 },
        { from = "brill",     to = "undercity",       mode = "walk",   minutes = 2.0, costCopper = 0 },
        { from = "brill",     to = "sepulcher",       mode = "walk",   minutes = 3.0, costCopper = 0 },
        { from = "tarren_mill", to = "lights_hope",   mode = "flight", minutes = 4.0, costCopper = 180 },

        -- ==================== ALIANZA — KALIMDOR ====================
        { from = "ruttheran", to = "auberdine",       mode = "flight", minutes = 2.0, costCopper = 70 },
        { from = "ruttheran", to = "ruttheran_pier",  mode = "walk",   minutes = 0.5, costCopper = 0 },
        { from = "darnassus", to = "ruttheran",       mode = "walk",   minutes = 1.0, costCopper = 0 },

        { from = "auberdine", to = "astranaar",    mode = "flight", minutes = 2.0, costCopper = 80 },
        { from = "auberdine", to = "stonetalon_peak", mode = "flight", minutes = 3.0, costCopper = 120 },
        { from = "auberdine", to = "nijels_point", mode = "flight", minutes = 3.5, costCopper = 150 },
        { from = "auberdine", to = "everlook",     mode = "flight", minutes = 4.5, costCopper = 210 },
        { from = "auberdine", to = "auberdine_pier",       mode = "walk", minutes = 0.4, costCopper = 0 },
        { from = "auberdine", to = "auberdine_dock_sw",    mode = "walk", minutes = 0.4, costCopper = 0 },
        { from = "auberdine", to = "auberdine_dock_south", mode = "walk", minutes = 0.4, costCopper = 0 },
        { from = "auberdine", to = "auberdine_dock_north", mode = "walk", minutes = 0.4, costCopper = 0 },
        { from = "auberdine_dock_sw", to = "auberdine_dock_south", mode = "walk", minutes = 0.3, costCopper = 0 },
        { from = "auberdine_dock_sw", to = "auberdine_dock_north", mode = "walk", minutes = 0.3, costCopper = 0 },
        { from = "auberdine_dock_south", to = "auberdine_dock_north", mode = "walk", minutes = 0.4, costCopper = 0 },

        { from = "astranaar", to = "stonetalon_peak", mode = "flight", minutes = 2.0, costCopper = 75 },
        { from = "astranaar", to = "theramore",    mode = "flight", minutes = 4.0, costCopper = 170 },

        { from = "stonetalon_peak", to = "nijels_point", mode = "flight", minutes = 2.5, costCopper = 95 },
        { from = "nijels_point", to = "feathermoon", mode = "flight", minutes = 3.5, costCopper = 155 },
        { from = "nijels_point", to = "thalanaar",  mode = "flight", minutes = 3.0, costCopper = 130 },
        { from = "nijels_point", to = "theramore",  mode = "flight", minutes = 3.5, costCopper = 150 },

        { from = "theramore", to = "thalanaar",    mode = "flight", minutes = 3.0, costCopper = 120 },
        { from = "theramore", to = "gadgetzan",    mode = "flight", minutes = 3.5, costCopper = 150 },
        { from = "theramore", to = "theramore_pier", mode = "walk", minutes = 0.5, costCopper = 0 },

        { from = "thalanaar", to = "feathermoon",  mode = "flight", minutes = 2.5, costCopper = 95 },
        { from = "thalanaar", to = "gadgetzan",    mode = "flight", minutes = 3.0, costCopper = 125 },

        { from = "feathermoon", to = "cenarion_hold", mode = "flight", minutes = 3.5, costCopper = 160 },
        { from = "gadgetzan", to = "marshals_stand", mode = "flight", minutes = 2.5, costCopper = 100 },
        { from = "gadgetzan", to = "cenarion_hold",  mode = "flight", minutes = 3.5, costCopper = 150 },

        -- ==================== HORDA — KALIMDOR ====================
        { from = "orgrimmar", to = "crossroads",   mode = "flight", minutes = 2.5, costCopper = 90 },
        { from = "orgrimmar", to = "thunderbluff", mode = "flight", minutes = 3.5, costCopper = 150 },
        { from = "orgrimmar", to = "splintertree", mode = "flight", minutes = 3.0, costCopper = 120 },
        { from = "orgrimmar", to = "sun_rock",     mode = "flight", minutes = 3.5, costCopper = 145 },
        { from = "orgrimmar", to = "everlook",     mode = "flight", minutes = 4.5, costCopper = 210 },
        { from = "orgrimmar", to = "orgrimmar_zep", mode = "walk",  minutes = 1.0, costCopper = 0 },
        { from = "orgrimmar", to = "razor_hill",    mode = "walk",  minutes = 2.0, costCopper = 0 },
        { from = "razor_hill", to = "crossroads",   mode = "walk",  minutes = 3.5, costCopper = 0 },
        { from = "thunderbluff", to = "bloodhoof",  mode = "walk",  minutes = 2.0, costCopper = 0 },
        { from = "bloodhoof", to = "crossroads",    mode = "walk",  minutes = 4.0, costCopper = 0 },

        { from = "crossroads", to = "camp_taurajo", mode = "flight", minutes = 1.5, costCopper = 60 },
        { from = "crossroads", to = "thunderbluff", mode = "flight", minutes = 2.5, costCopper = 90 },
        { from = "crossroads", to = "splintertree", mode = "flight", minutes = 2.5, costCopper = 95 },
        { from = "crossroads", to = "sun_rock",     mode = "flight", minutes = 2.5, costCopper = 95 },
        { from = "crossroads", to = "ratchet",      mode = "flight", minutes = 1.5, costCopper = 60 },
        { from = "crossroads", to = "freewind_post", mode = "flight", minutes = 3.0, costCopper = 120 },
        { from = "crossroads", to = "brackenwall",  mode = "flight", minutes = 2.5, costCopper = 100 },

        { from = "splintertree", to = "zoramgar",   mode = "flight", minutes = 2.0, costCopper = 70 },
        { from = "splintertree", to = "sun_rock",   mode = "flight", minutes = 2.5, costCopper = 90 },

        { from = "sun_rock", to = "shadowprey",     mode = "flight", minutes = 2.5, costCopper = 95 },
        { from = "sun_rock", to = "camp_taurajo",   mode = "flight", minutes = 2.5, costCopper = 95 },

        { from = "camp_taurajo", to = "freewind_post", mode = "flight", minutes = 2.0, costCopper = 75 },

        { from = "thunderbluff", to = "sun_rock",     mode = "flight", minutes = 2.5, costCopper = 95 },
        { from = "thunderbluff", to = "freewind_post", mode = "flight", minutes = 3.0, costCopper = 120 },
        { from = "thunderbluff", to = "shadowprey",   mode = "flight", minutes = 3.5, costCopper = 150 },
        { from = "thunderbluff", to = "camp_mojache", mode = "flight", minutes = 3.5, costCopper = 150 },

        { from = "freewind_post", to = "gadgetzan",    mode = "flight", minutes = 3.0, costCopper = 120 },
        { from = "freewind_post", to = "camp_mojache", mode = "flight", minutes = 3.0, costCopper = 120 },

        { from = "shadowprey", to = "camp_mojache", mode = "flight", minutes = 3.0, costCopper = 120 },

        { from = "camp_mojache", to = "gadgetzan",     mode = "flight", minutes = 3.5, costCopper = 150 },
        { from = "camp_mojache", to = "cenarion_hold", mode = "flight", minutes = 3.5, costCopper = 160 },

        { from = "brackenwall", to = "camp_taurajo", mode = "flight", minutes = 2.0, costCopper = 80 },

        -- ==================== REDES NEUTRALES / KALIMDOR ====================
        { from = "ratchet", to = "ratchet_pier", mode = "walk", minutes = 0.5, costCopper = 0 },
        { from = "gadgetzan", to = "ratchet",    mode = "flight", minutes = 4.0, costCopper = 180, faction = "neutral" },

        -- ==================== CRUCE INTERCONTINENTAL — BARCOS ====================
        -- Barco neutral Bahía del Botín <-> Trinquete (Goblin)
        { from = "booty_bay_pier", to = "ratchet_pier", mode = "boat", minutes = 4.5, costCopper = 0, faction = "neutral" },

        -- Barcos Alianza (World of Warcraft Forever):
        -- 1. Puerto de Ventormenta <-> Auberdine (Muelle Oeste)
        { from = "stormwind_harbor", to = "auberdine_dock_sw", mode = "boat", minutes = 4.5, costCopper = 0, faction = "alliance" },

        -- 2. Auberdine (Muelle Norte) <-> Rut'theran (Teldrassil / Darnassus)
        { from = "auberdine_dock_north", to = "ruttheran_pier", mode = "boat", minutes = 2.0, costCopper = 0, faction = "alliance" },

        -- 3. Barco con dos escalas: Auberdine (Muelle Sur) <-> Menethil <-> Costasur (Southshore)
        { from = "auberdine_dock_south", to = "menethil_pier", mode = "boat", minutes = 4.5, costCopper = 0, faction = "alliance" },
        { from = "menethil_pier", to = "southshore_pier", mode = "boat", minutes = 3.0, costCopper = 0, faction = "alliance" },

        -- Barco Humedales <-> Theramore (Marjal Revolcafango)
        { from = "menethil_pier_theramore", to = "theramore_pier", mode = "boat", minutes = 5.5, costCopper = 0, faction = "alliance" },
        { from = "menethil_pier",           to = "theramore_pier", mode = "boat", minutes = 5.8, costCopper = 0, faction = "alliance" },

        -- Enlaces de retrocompatibilidad con auberdine_pier
        { from = "auberdine_pier", to = "ruttheran_pier", mode = "boat", minutes = 2.0, costCopper = 0, faction = "alliance" },
        { from = "menethil_pier", to = "auberdine_pier",  mode = "boat", minutes = 4.5, costCopper = 0, faction = "alliance" },

        -- ==================== CRUCE INTERCONTINENTAL — ZEPELINES (HORDA) ====================
        { from = "orgrimmar_zep", to = "undercity_zep", mode = "zeppelin", minutes = 4.5, costCopper = 0, faction = "horde" },
        { from = "orgrimmar_zep", to = "gromgol_zep",   mode = "zeppelin", minutes = 4.5, costCopper = 0, faction = "horde" },
        { from = "undercity_zep", to = "gromgol_zep",   mode = "zeppelin", minutes = 4.5, costCopper = 0, faction = "horde" },

        -- ==================== CONECTOR A PIE / NADO COMUNITARIO ====================
        { from = "sentinel_hill", to = "westfall_coast", mode = "walk", minutes = 2.0, costCopper = 0 },
        {
            from = "westfall_coast", to = "booty_bay_pier", mode = "swim", minutes = 14.0,
            faction = "neutral", costCopper = 0,
            danger = "Moderado: mantente mar adentro al pasar frente al campamento Horda de Grom'gol",
            waypoints = {
                { uiMapID = 1442, x = 20.0, y = 13.0 },
                { uiMapID = 1442, x = 22.0, y = 45.0, danger = "Esquiva la playa y muelles de Grom'gol" },
                { uiMapID = 1442, x = 24.0, y = 72.0 },
            },
        },

        -- ==================== RUTAS DE FOREVER — RIVERGLADES ====================
        -- Red de barcos Steamwheedle (Trinquete / Bahía del Botín <-> Puerto Powderfuse)
        {
            from = "ratchet_pier", to = "riverglades_powderfuse", mode = "boat", minutes = 4.0,
            faction = "neutral", costCopper = 0,
            tip = "Ruta marítima Bonvapor (Steamwheedle) desde Trinquete hacia Riverglades.",
        },
        {
            from = "booty_bay_pier", to = "riverglades_powderfuse", mode = "boat", minutes = 4.5,
            faction = "neutral", costCopper = 0,
            tip = "Ruta marítima Bonvapor (Steamwheedle) desde Bahía del Botín hacia Riverglades.",
        },
        { from = "riverglades_powderfuse", to = "riverglades_crawglawe", mode = "walk", minutes = 2.0, costCopper = 0 },
        { from = "riverglades_crawglawe", to = "riverglades_kroldok",    mode = "walk", minutes = 1.5, costCopper = 0 },

        -- ==================== RUTAS DE FOREVER — ZEPHRAS ISLE & SKYBORNE ====================
        -- Zephras Isle interno
        { from = "zephras_spawn", to = "zephras_dock_alliance", mode = "walk", minutes = 1.0, costCopper = 0 },
        { from = "zephras_spawn", to = "zephras_dock_horde",    mode = "walk", minutes = 1.0, costCopper = 0 },
        { from = "zephras_dock_alliance", to = "zephras_dock_horde", mode = "walk", minutes = 0.8, costCopper = 0 },

        -- Ruta Alianza: Zephras (65.8, 83.4) <-> Barco Volador Dalaran (12.7, 52.1) <-> Portal Ventormenta
        {
            from = "zephras_dock_alliance", to = "dalaran_flying_boat", mode = "boat", minutes = 3.5,
            faction = "alliance", costCopper = 0,
            tip = "Barco Volador entre Zephras Isle (65.8, 83.4) y Montañas de Alterac / Dalaran (12.7, 52.1).",
        },
        { from = "dalaran_flying_boat", to = "dalaran_sanctum_portal", mode = "walk", minutes = 0.4, costCopper = 0 },
        {
            from = "stormwind_wizard_sanctum", to = "dalaran_sanctum_portal", mode = "portal", minutes = 0.1,
            faction = "alliance", costCopper = 0,
            tip = "Portal del Santuario del Mago (Ventormenta 49.4, 86.9) a Dalaran. Exclusivo para la raza Cielonato (Skyborne).",
        },
        { from = "stormwind", to = "stormwind_wizard_sanctum", mode = "walk", minutes = 0.6, costCopper = 0 },

        -- Ruta Horda: Zephras (57.9, 80.7) <-> Mulgore Meseta Vigía del Cielo (34.3, 25.7)
        {
            from = "zephras_dock_horde", to = "mulgore_skywatcher", mode = "boat", minutes = 3.5,
            faction = "horde", costCopper = 0,
            tip = "Desembarco en Mulgore cerca de la Feria de la Luna Negra. Pícaros y druidas pueden infiltrarse con sigilo para evitar guardias.",
        },
        { from = "mulgore_skywatcher", to = "thunderbluff", mode = "walk", minutes = 2.0, costCopper = 0 },
        { from = "mulgore_skywatcher", to = "bloodhoof",    mode = "walk", minutes = 2.5, costCopper = 0 },

        -- ==================== RUTAS DE FOREVER — SHEN'DRALAS (CORREDOR DESOLACE <-> MULGORE) ====================
        {
            from = "shadowprey", to = "shendralas_outpost", mode = "walk", minutes = 3.0, costCopper = 0,
            tip = "Corredor terrestre directo entre Desolace (Aldea Cazasombras) y Shen'Dralas.",
        },
        {
            from = "nijels_point", to = "shendralas_outpost", mode = "walk", minutes = 3.5, costCopper = 0,
            tip = "Corredor terrestre directo entre Desolace (Punta de Nijel) y Shen'Dralas.",
        },
        {
            from = "shendralas_outpost", to = "mulgore_skywatcher", mode = "walk", minutes = 2.5, costCopper = 0,
            tip = "Paso montañoso directo entre Shen'Dralas y Mulgore (Meseta Vigía del Cielo).",
        },
        {
            from = "shendralas_outpost", to = "bloodhoof", mode = "walk", minutes = 3.0, costCopper = 0,
            tip = "Paso montañoso directo entre Shen'Dralas y Mulgore (Poblado Pezuña de Sangre).",
        },

        -- ==================== RUTAS DE FOREVER — MONTE HYJAL (NIVEL 60) ====================
        {
            from = "everlook", to = "hyjal_entrance", mode = "walk", minutes = 2.5, costCopper = 0,
            tip = "Paso terrestre norte desde Cuna del Invierno (Winterspring) hacia Monte Hyjal.",
        },
        { from = "hyjal_entrance", to = "hyjal_darkwhisper", mode = "walk", minutes = 1.5, costCopper = 0 },
        { from = "hyjal_entrance", to = "hyjal_summit",      mode = "walk", minutes = 2.0, costCopper = 0 },
    },

    -- Nodos frecuentes para la rejilla de acceso rápido (Quick Travel Grid)
    POPULAR_HUBS = {
        alliance = {
            { id = "stormwind",    name = "Ventormenta", continent = "Reinos del Este", icon = "Interface\\Icons\\inv_shield_04" },
            { id = "ironforge",    name = "Forjaz",      continent = "Reinos del Este", icon = "Interface\\Icons\\inv_misc_gear_01" },
            { id = "darnassus",    name = "Darnassus",   continent = "Kalimdor",         icon = "Interface\\Icons\\spell_nature_healingtouch" },
            { id = "menethil",     name = "Menethil",    continent = "Reinos del Este", icon = "Interface\\Icons\\inv_misc_map_01" },
            { id = "theramore",    name = "Theramore",   continent = "Kalimdor",         icon = "Interface\\Icons\\spell_holy_magicalsentry" },
            { id = "booty_bay_ali",name = "Bahía Botín", continent = "Reinos del Este", icon = "Interface\\Icons\\inv_misc_coin_01" },
        },
        horde = {
            { id = "orgrimmar",    name = "Orgrimmar",   continent = "Kalimdor",         icon = "Interface\\Icons\\inv_axe_02" },
            { id = "thunderbluff", name = "Cima Trueno", continent = "Kalimdor",         icon = "Interface\\Icons\\ability_racial_warstomp" },
            { id = "undercity",    name = "Entrañas",    continent = "Reinos del Este", icon = "Interface\\Icons\\spell_shadow_requiem" },
            { id = "crossroads",   name = "El Cruce",    continent = "Kalimdor",         icon = "Interface\\Icons\\spell_fire_fire" },
            { id = "gromgol",      name = "Grom'gol",    continent = "Reinos del Este", icon = "Interface\\Icons\\inv_axe_02" },
            { id = "booty_bay_horde", name = "Bahía Botín", continent = "Reinos del Este", icon = "Interface\\Icons\\inv_misc_coin_01" },
        },
    },
}
