local ADDON, ns = ...

ns.Data = ns.Data or {}

-- =========================================================================
-- BASE DE DATOS DE ENTRENADORES DE PROFESIONES (WoW Classic Forever 1-300)
-- Scrapeado y verificado de: https://www.wow-professions.com/forever
-- Organizado por profesión, facción (Alliance / Horde) y tramo de habilidad.
-- =========================================================================
ns.Data.ProfessionTrainers = {

    ["Leatherworking"] = {
        ["Alliance"] = {
            ["1-75"] = {
                { name = "Adele Fielder", zone = "Bosque de Elwynn", uiMapID = 1429, x = 46.4, y = 62.1, rank = "Aprendiz" },
                { name = "Gretta Finespindle", zone = "Forjaz", uiMapID = 1455, x = 39.0, y = 32.7, rank = "Aprendiz" },
                { name = "Randal Worth", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 72.2, y = 62.8, rank = "Aprendiz" },
                { name = "Darianna", zone = "Darnassus", uiMapID = 1457, x = 64.5, y = 21.0, rank = "Aprendiz" },
                { name = "Nadyia Maneweaver", zone = "Teldrassil", uiMapID = 1438, x = 41.8, y = 49.4, rank = "Aprendiz" },
            },
            ["75-150"] = {
                { name = "Simon Tanner", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 71.7, y = 62.9, rank = "Oficial" },
                { name = "Fimble Finespindle", zone = "Forjaz", uiMapID = 1455, x = 40.2, y = 33.7, rank = "Oficial" },
                { name = "Faldron", zone = "Darnassus", uiMapID = 1457, x = 64.9, y = 21.6, rank = "Oficial" },
                { name = "Aayndia Floralwind", zone = "Vallefresno", uiMapID = 1440, x = 36.0, y = 52.1, rank = "Oficial" },
            },
            ["150-225"] = {
                { name = "Telonis", zone = "Darnassus", uiMapID = 1457, x = 64.4, y = 21.5, rank = "Experto" },
            },
            ["225-300"] = {
                { name = "Drakk Stonehand", zone = "Tierras del Interior", uiMapID = 1425, x = 13.4, y = 43.3, rank = "Artesano" },
            },
        },
        ["Horde"] = {
            ["1-75"] = {
                { name = "Kamari", zone = "Orgrimmar", uiMapID = 1454, x = 63.2, y = 44.6, rank = "Aprendiz" },
                { name = "Mak", zone = "Cima del Trueno", uiMapID = 1456, x = 42.2, y = 43.1, rank = "Aprendiz" },
                { name = "Dan Golthas", zone = "Entrañas", uiMapID = 1458, x = 70.8, y = 58.6, rank = "Aprendiz" },
                { name = "Chaw Stronghide", zone = "Mulgore", uiMapID = 1412, x = 45.0, y = 61.5, rank = "Aprendiz" },
                { name = "Shelene Rhobart", zone = "Claros de Tirisfal", uiMapID = 1420, x = 65.4, y = 60.1, rank = "Aprendiz" },
            },
            ["75-150"] = {
                { name = "Karolek", zone = "Orgrimmar", uiMapID = 1454, x = 62.7, y = 44.4, rank = "Oficial" },
                { name = "Tarn", zone = "Cima del Trueno", uiMapID = 1456, x = 42.5, y = 42.9, rank = "Oficial" },
                { name = "Arthur Moore", zone = "Entrañas", uiMapID = 1458, x = 70.2, y = 57.6, rank = "Oficial" },
                { name = "Krulmoo Fullmoon", zone = "Los Baldíos", uiMapID = 1413, x = 44.8, y = 59.4, rank = "Oficial" },
            },
            ["150-225"] = {
                { name = "Una", zone = "Cima del Trueno", uiMapID = 1456, x = 41.7, y = 42.7, rank = "Experta" },
            },
            ["225-300"] = {
                { name = "Hahrana Ironhide", zone = "Feralas", uiMapID = 1444, x = 74.4, y = 43.1, rank = "Artesana" },
            },
        },
    },

    ["Tailoring"] = {
        ["Alliance"] = {
            ["1-75"] = {
                { name = "Lawrence Schneider", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 53.5, y = 81.7, rank = "Aprendiz" },
                { name = "Uthrar Threx", zone = "Forjaz", uiMapID = 1455, x = 43.7, y = 28.2, rank = "Aprendiz" },
                { name = "Trianna", zone = "Darnassus", uiMapID = 1457, x = 63.6, y = 21.3, rank = "Aprendiz" },
                { name = "Eldrin", zone = "Bosque de Elwynn", uiMapID = 1429, x = 79.3, y = 69.0, rank = "Aprendiz" },
                { name = "Grondal Moonbreeze", zone = "Teldrassil", uiMapID = 1438, x = 38.2, y = 40.5, rank = "Aprendiz" },
            },
            ["75-150"] = {
                { name = "Sellandus", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 52.3, y = 83.4, rank = "Oficial" },
                { name = "Jormund Stonebrow", zone = "Forjaz", uiMapID = 1455, x = 43.3, y = 28.9, rank = "Oficial" },
                { name = "Me'lynn", zone = "Darnassus", uiMapID = 1457, x = 63.2, y = 22.3, rank = "Oficial" },
            },
            ["150-225"] = {
                { name = "Georgio Bolero", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 53.3, y = 81.5, rank = "Experto" },
            },
            ["225-300"] = {
                { name = "Timothy Worthington", zone = "Marjal Revolcafango", uiMapID = 1428, x = 66.2, y = 51.8, rank = "Artesano" },
            },
        },
        ["Horde"] = {
            ["1-75"] = {
                { name = "Snang", zone = "Orgrimmar", uiMapID = 1454, x = 62.9, y = 49.4, rank = "Aprendiz" },
                { name = "Vhan", zone = "Cima del Trueno", uiMapID = 1456, x = 44.0, y = 44.6, rank = "Aprendiz" },
                { name = "Victor Ward", zone = "Entrañas", uiMapID = 1458, x = 70.2, y = 29.7, rank = "Aprendiz" },
                { name = "Kil'hala", zone = "Los Baldíos", uiMapID = 1413, x = 52.2, y = 31.7, rank = "Aprendiz" },
                { name = "Bowen Brisboise", zone = "Claros de Tirisfal", uiMapID = 1420, x = 52.6, y = 55.6, rank = "Aprendiz" },
            },
            ["75-150"] = {
                { name = "Magar", zone = "Orgrimmar", uiMapID = 1454, x = 63.5, y = 50.0, rank = "Oficial" },
                { name = "Tepa", zone = "Cima del Trueno", uiMapID = 1456, x = 44.4, y = 45.1, rank = "Oficial" },
                { name = "Rhiannon Davis", zone = "Entrañas", uiMapID = 1458, x = 70.1, y = 30.1, rank = "Oficial" },
                { name = "Mahani", zone = "Los Baldíos", uiMapID = 1413, x = 44.9, y = 59.4, rank = "Oficial" },
            },
            ["150-225"] = {
                { name = "Josef Gregorian", zone = "Entrañas", uiMapID = 1458, x = 70.6, y = 30.4, rank = "Experto" },
            },
            ["225-300"] = {
                { name = "Daryl Stack", zone = "Laderas de Trabalomas", uiMapID = 1424, x = 63.7, y = 20.8, rank = "Artesano" },
            },
        },
    },

    ["Blacksmithing"] = {
        ["Alliance"] = {
            ["1-75"] = {
                { name = "Dane Lindgren", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 64.1, y = 37.1, rank = "Aprendiz" },
                { name = "Groum Stonebeard", zone = "Forjaz", uiMapID = 1455, x = 52.1, y = 41.9, rank = "Aprendiz" },
                { name = "Smith Argus", zone = "Bosque de Elwynn", uiMapID = 1429, x = 41.7, y = 65.6, rank = "Aprendiz" },
                { name = "Tognus Flintfire", zone = "Dun Morogh", uiMapID = 1426, x = 45.3, y = 52.0, rank = "Aprendiz" },
            },
            ["75-150"] = {
                { name = "Therum Deepforge", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 63.6, y = 36.8, rank = "Oficial" },
                { name = "Rotgath Stonebeard", zone = "Forjaz", uiMapID = 1455, x = 51.9, y = 42.4, rank = "Oficial" },
                { name = "Clarise Gnarltree", zone = "Bosque del Ocaso", uiMapID = 1431, x = 74.0, y = 48.5, rank = "Oficial" },
            },
            ["150-225"] = {
                { name = "Bengus Deepforge", zone = "Forjaz", uiMapID = 1455, x = 52.4, y = 41.2, rank = "Experto" },
            },
            ["225-300"] = {
                { name = "Brikk Keencraft", zone = "Vega de Tuercespina", uiMapID = 1434, x = 29.0, y = 75.5, rank = "Artesano" },
                { name = "Grumnus Steelshaper", zone = "Forjaz", uiMapID = 1455, x = 50.2, y = 42.7, rank = "Artesano Armero" },
                { name = "Ironus Coldsteel", zone = "Forjaz", uiMapID = 1455, x = 50.9, y = 43.2, rank = "Artesano Forjador" },
            },
        },
        ["Horde"] = {
            ["1-75"] = {
                { name = "Ug'thok", zone = "Orgrimmar", uiMapID = 1454, x = 80.7, y = 23.6, rank = "Aprendiz" },
                { name = "Thrag Stonehoof", zone = "Cima del Trueno", uiMapID = 1456, x = 39.2, y = 56.4, rank = "Aprendiz" },
                { name = "Basil Frye", zone = "Entrañas", uiMapID = 1458, x = 60.0, y = 28.9, rank = "Aprendiz" },
                { name = "Dwukk", zone = "Durotar", uiMapID = 1411, x = 52.1, y = 40.7, rank = "Aprendiz" },
                { name = "Guillaume Sorouy", zone = "Claros de Tirisfal", uiMapID = 1420, x = 43.2, y = 41.0, rank = "Aprendiz" },
            },
            ["75-150"] = {
                { name = "Snarl", zone = "Orgrimmar", uiMapID = 1454, x = 79.7, y = 23.4, rank = "Oficial" },
                { name = "Karn Stonehoof", zone = "Cima del Trueno", uiMapID = 1456, x = 39.2, y = 55.4, rank = "Oficial" },
                { name = "James Van Brunt", zone = "Entrañas", uiMapID = 1458, x = 61.5, y = 30.3, rank = "Oficial" },
                { name = "Traugh", zone = "Los Baldíos", uiMapID = 1413, x = 51.3, y = 28.9, rank = "Oficial" },
            },
            ["150-225"] = {
                { name = "Saru Steelfury", zone = "Orgrimmar", uiMapID = 1454, x = 82.2, y = 23.0, rank = "Experto" },
            },
            ["225-300"] = {
                { name = "Brikk Keencraft", zone = "Vega de Tuercespina", uiMapID = 1434, x = 29.0, y = 75.5, rank = "Artesano" },
                { name = "Okothos Ironrager", zone = "Orgrimmar", uiMapID = 1454, x = 79.9, y = 23.6, rank = "Artesano Armero" },
                { name = "Borgosh Corebender", zone = "Orgrimmar", uiMapID = 1454, x = 79.7, y = 23.4, rank = "Artesano Forjador" },
            },
        },
    },

    ["Alchemy"] = {
        ["Alliance"] = {
            ["1-75"] = {
                { name = "Tel'Athir", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 55.6, y = 85.7, rank = "Aprendiz" },
                { name = "Vosur Brakthel", zone = "Forjaz", uiMapID = 1455, x = 66.5, y = 55.4, rank = "Aprendiz" },
                { name = "Milla Fairancora", zone = "Darnassus", uiMapID = 1457, x = 55.3, y = 22.8, rank = "Aprendiz" },
                { name = "Alchemist Mallory", zone = "Bosque de Elwynn", uiMapID = 1429, x = 39.9, y = 48.3, rank = "Aprendiz" },
                { name = "Cyndra Kindwhisper", zone = "Teldrassil", uiMapID = 1438, x = 57.6, y = 60.7, rank = "Aprendiz" },
            },
            ["75-150"] = {
                { name = "Lilyssia Nightbreeze", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 55.7, y = 86.1, rank = "Oficial" },
                { name = "Tally Berryfizz", zone = "Forjaz", uiMapID = 1455, x = 66.6, y = 55.3, rank = "Oficial" },
                { name = "Sylvanna Forestmoon", zone = "Darnassus", uiMapID = 1457, x = 56.1, y = 24.1, rank = "Oficial" },
                { name = "Kylanna", zone = "Vallefresno", uiMapID = 1440, x = 50.8, y = 67.1, rank = "Oficial" },
            },
            ["150-225"] = {
                { name = "Ainethil", zone = "Darnassus", uiMapID = 1457, x = 54.9, y = 24.0, rank = "Experto" },
            },
            ["225-300"] = {
                { name = "Kylanna Windwhisper", zone = "Feralas", uiMapID = 1444, x = 32.6, y = 43.8, rank = "Artesana" },
            },
        },
        ["Horde"] = {
            ["1-75"] = {
                { name = "Whuut", zone = "Orgrimmar", uiMapID = 1454, x = 55.9, y = 33.1, rank = "Aprendiz" },
                { name = "Kray", zone = "Cima del Trueno", uiMapID = 1456, x = 46.8, y = 34.4, rank = "Aprendiz" },
                { name = "Doctor Martin Felben", zone = "Entrañas", uiMapID = 1458, x = 46.4, y = 74.1, rank = "Aprendiz" },
                { name = "Miao'zan", zone = "Durotar", uiMapID = 1411, x = 55.4, y = 74.0, rank = "Aprendiz" },
                { name = "Carolai Anise", zone = "Claros de Tirisfal", uiMapID = 1420, x = 59.5, y = 52.2, rank = "Aprendiz" },
            },
            ["75-150"] = {
                { name = "Yelmak", zone = "Orgrimmar", uiMapID = 1454, x = 56.7, y = 33.2, rank = "Oficial" },
                { name = "Bena Winterhoof", zone = "Cima del Trueno", uiMapID = 1456, x = 46.6, y = 33.2, rank = "Oficial" },
                { name = "Doctor Marsh", zone = "Entrañas", uiMapID = 1458, x = 51.3, y = 74.2, rank = "Oficial" },
                { name = "Serge Hinott", zone = "Laderas de Trabalomas", uiMapID = 1424, x = 61.6, y = 19.2, rank = "Oficial" },
            },
            ["150-225"] = {
                { name = "Doctor Herbert Halsey", zone = "Entrañas", uiMapID = 1458, x = 47.8, y = 73.2, rank = "Experto" },
            },
            ["225-300"] = {
                { name = "Rogvar", zone = "Pantano de las Penas", uiMapID = 1435, x = 48.5, y = 55.8, rank = "Artesano" },
            },
        },
    },

    ["Enchanting"] = {
        ["Alliance"] = {
            ["1-75"] = {
                { name = "Betty Quin", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 53.1, y = 73.8, rank = "Aprendiz" },
                { name = "Thonys Pillarstone", zone = "Forjaz", uiMapID = 1455, x = 60.4, y = 44.9, rank = "Aprendiz" },
                { name = "Lalina Summermoon", zone = "Darnassus", uiMapID = 1457, x = 58.9, y = 12.8, rank = "Aprendiz" },
                { name = "Alanna Raveneye", zone = "Teldrassil", uiMapID = 1438, x = 36.8, y = 34.2, rank = "Aprendiz" },
            },
            ["75-150"] = {
                { name = "Lucan Cordell", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 53.1, y = 74.3, rank = "Oficial" },
                { name = "Gimble Thistlefuzz", zone = "Forjaz", uiMapID = 1455, x = 59.8, y = 45.5, rank = "Oficial" },
                { name = "Taladan", zone = "Darnassus", uiMapID = 1457, x = 58.6, y = 13.2, rank = "Oficial" },
            },
            ["150-225"] = {
                { name = "Kitta Firewind", zone = "Bosque de Elwynn", uiMapID = 1429, x = 64.9, y = 70.6, rank = "Experta" },
                { name = "Xylinnia Starshine", zone = "Feralas", uiMapID = 1444, x = 31.5, y = 44.2, rank = "Experta" },
            },
            ["225-300"] = {
                { name = "Annora", zone = "Tierras Altas de Arathi", uiMapID = 1417, x = 43.0, y = 62.0, rank = "Artesana (Mazmorra Uldaman)" },
            },
        },
        ["Horde"] = {
            ["1-75"] = {
                { name = "Jhag", zone = "Orgrimmar", uiMapID = 1454, x = 53.5, y = 38.4, rank = "Aprendiz" },
                { name = "Mot Dawnstrider", zone = "Cima del Trueno", uiMapID = 1456, x = 44.9, y = 39.0, rank = "Aprendiz" },
                { name = "Malcomb Wynn", zone = "Entrañas", uiMapID = 1458, x = 62.4, y = 60.8, rank = "Aprendiz" },
                { name = "Vance Undergloom", zone = "Claros de Tirisfal", uiMapID = 1420, x = 61.8, y = 51.6, rank = "Aprendiz" },
            },
            ["75-150"] = {
                { name = "Godan", zone = "Orgrimmar", uiMapID = 1454, x = 53.8, y = 38.5, rank = "Oficial" },
                { name = "Teg Dawnstrider", zone = "Cima del Trueno", uiMapID = 1456, x = 44.9, y = 37.7, rank = "Oficial" },
                { name = "Lavinia Crowe", zone = "Entrañas", uiMapID = 1458, x = 62.4, y = 61.6, rank = "Oficial" },
            },
            ["150-225"] = {
                { name = "Hgarth", zone = "Sierra Espolón", uiMapID = 1442, x = 49.2, y = 57.1, rank = "Experto" },
            },
            ["225-300"] = {
                { name = "Annora", zone = "Tierras Altas de Arathi", uiMapID = 1417, x = 43.0, y = 62.0, rank = "Artesana (Mazmorra Uldaman)" },
            },
        },
    },

    ["Engineering"] = {
        ["Alliance"] = {
            ["1-75"] = {
                { name = "Sprite Jumpsprocket", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 61.9, y = 30.7, rank = "Aprendiz" },
                { name = "Jemma Quikswitch", zone = "Forjaz", uiMapID = 1455, x = 67.8, y = 44.2, rank = "Aprendiz" },
                { name = "Bronk Guzzlegear", zone = "Dun Morogh", uiMapID = 1426, x = 50.2, y = 50.4, rank = "Aprendiz" },
            },
            ["75-150"] = {
                { name = "Lilliam Sparkspindle", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 62.2, y = 30.4, rank = "Oficial" },
                { name = "Trixie Quikswitch", zone = "Forjaz", uiMapID = 1455, x = 67.6, y = 43.1, rank = "Oficial" },
                { name = "Finbus Geargrind", zone = "Bosque del Ocaso", uiMapID = 1431, x = 77.4, y = 48.5, rank = "Oficial" },
            },
            ["150-225"] = {
                { name = "Springspindle Fizzlegear", zone = "Forjaz", uiMapID = 1455, x = 68.5, y = 43.5, rank = "Experto" },
            },
            ["225-300"] = {
                { name = "Buzzek Bracketswing", zone = "Tanaris", uiMapID = 1446, x = 52.3, y = 27.7, rank = "Artesano" },
                { name = "Tinkmaster Overspark", zone = "Forjaz", uiMapID = 1455, x = 69.8, y = 50.7, rank = "Ingeniero Gnómico" },
                { name = "Nixx Sprocketspring", zone = "Tanaris", uiMapID = 1446, x = 52.5, y = 27.3, rank = "Ingeniero Goblin" },
            },
        },
        ["Horde"] = {
            ["1-75"] = {
                { name = "Thund", zone = "Orgrimmar", uiMapID = 1454, x = 75.8, y = 24.4, rank = "Aprendiz" },
                { name = "Graham Van Talen", zone = "Entrañas", uiMapID = 1458, x = 75.3, y = 72.7, rank = "Aprendiz" },
                { name = "Mukdrak", zone = "Durotar", uiMapID = 1411, x = 52.2, y = 40.8, rank = "Aprendiz" },
                { name = "Twizwick Sprocketgrind", zone = "Mulgore", uiMapID = 1412, x = 58.7, y = 39.5, rank = "Aprendiz" },
            },
            ["75-150"] = {
                { name = "Nogg", zone = "Orgrimmar", uiMapID = 1454, x = 75.8, y = 25.4, rank = "Oficial" },
                { name = "Franklin Lloyd", zone = "Entrañas", uiMapID = 1458, x = 76.3, y = 73.3, rank = "Oficial" },
                { name = "Tinkerwiz", zone = "Los Baldíos", uiMapID = 1413, x = 62.7, y = 36.3, rank = "Oficial" },
            },
            ["150-225"] = {
                { name = "Roxxik", zone = "Orgrimmar", uiMapID = 1454, x = 76.0, y = 25.1, rank = "Experto" },
            },
            ["225-300"] = {
                { name = "Buzzek Bracketswing", zone = "Tanaris", uiMapID = 1446, x = 52.3, y = 27.7, rank = "Artesano" },
                { name = "Oglethorpe Obnoticus", zone = "Vega de Tuercespina", uiMapID = 1434, x = 28.3, y = 76.3, rank = "Ingeniero Gnómico" },
                { name = "Nixx Sprocketspring", zone = "Tanaris", uiMapID = 1446, x = 52.5, y = 27.3, rank = "Ingeniero Goblin" },
            },
        },
    },

    ["Cooking"] = {
        ["Alliance"] = {
            ["1-75"] = {
                { name = "Stephen Ryback", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 78.2, y = 53.2, rank = "Aprendiz" },
                { name = "Daryl Riknussun", zone = "Forjaz", uiMapID = 1455, x = 60.0, y = 36.7, rank = "Aprendiz" },
                { name = "Alegorn", zone = "Darnassus", uiMapID = 1457, x = 48.9, y = 21.2, rank = "Aprendiz" },
                { name = "Tomas", zone = "Bosque de Elwynn", uiMapID = 1429, x = 44.3, y = 66.0, rank = "Aprendiz" },
                { name = "Cook Ghilm", zone = "Dun Morogh", uiMapID = 1426, x = 68.5, y = 54.5, rank = "Aprendiz" },
            },
            ["75-150"] = {
                { name = "Stephen Ryback", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 78.2, y = 53.2, rank = "Oficial" },
                { name = "Daryl Riknussun", zone = "Forjaz", uiMapID = 1455, x = 60.0, y = 36.7, rank = "Oficial" },
                { name = "Alegorn", zone = "Darnassus", uiMapID = 1457, x = 48.9, y = 21.2, rank = "Oficial" },
            },
            ["150-225"] = {
                { name = "Shandrina", zone = "Vallefresno", uiMapID = 1440, x = 49.5, y = 67.1, rank = "Experto (Vendedora Libro)" },
            },
            ["225-300"] = {
                { name = "Dirge Quikcleave", zone = "Tanaris", uiMapID = 1446, x = 52.6, y = 28.1, rank = "Artesano (Misión Almejas)" },
            },
        },
        ["Horde"] = {
            ["1-75"] = {
                { name = "Zamja", zone = "Orgrimmar", uiMapID = 1454, x = 57.5, y = 53.9, rank = "Aprendiz" },
                { name = "Aska Mistrunner", zone = "Cima del Trueno", uiMapID = 1456, x = 50.8, y = 52.7, rank = "Aprendiz" },
                { name = "Eunice Burch", zone = "Entrañas", uiMapID = 1458, x = 62.3, y = 44.7, rank = "Aprendiz" },
                { name = "Cook Torka", zone = "Durotar", uiMapID = 1411, x = 51.1, y = 42.5, rank = "Aprendiz" },
                { name = "Pyall Silentstride", zone = "Mulgore", uiMapID = 1412, x = 45.0, y = 61.7, rank = "Aprendiz" },
            },
            ["75-150"] = {
                { name = "Zamja", zone = "Orgrimmar", uiMapID = 1454, x = 57.5, y = 53.9, rank = "Oficial" },
                { name = "Aska Mistrunner", zone = "Cima del Trueno", uiMapID = 1456, x = 50.8, y = 52.7, rank = "Oficial" },
                { name = "Eunice Burch", zone = "Entrañas", uiMapID = 1458, x = 62.3, y = 44.7, rank = "Oficial" },
                { name = "Duhng", zone = "Los Baldíos", uiMapID = 1413, x = 55.3, y = 31.8, rank = "Oficial" },
            },
            ["150-225"] = {
                { name = "Wulan", zone = "Mapa 1443", uiMapID = 1443, x = 26.1, y = 69.7, rank = "Experto (Vendedor Libro)" },
            },
            ["225-300"] = {
                { name = "Dirge Quikcleave", zone = "Tanaris", uiMapID = 1446, x = 52.6, y = 28.1, rank = "Artesano (Misión Almejas)" },
            },
        },
    },

    ["First Aid"] = {
        ["Alliance"] = {
            ["1-75"] = {
                { name = "Shaina Fuller", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 53.0, y = 44.7, rank = "Aprendiz" },
                { name = "Nissa Firestone", zone = "Forjaz", uiMapID = 1455, x = 54.9, y = 58.5, rank = "Aprendiz" },
                { name = "Dannelor", zone = "Darnassus", uiMapID = 1457, x = 51.7, y = 12.5, rank = "Aprendiz" },
                { name = "Michelle Belle", zone = "Bosque de Elwynn", uiMapID = 1429, x = 43.4, y = 65.6, rank = "Aprendiz" },
                { name = "Thamner Pol", zone = "Dun Morogh", uiMapID = 1426, x = 47.2, y = 52.5, rank = "Aprendiz" },
            },
            ["75-150"] = {
                { name = "Shaina Fuller", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 53.0, y = 44.7, rank = "Oficial" },
                { name = "Nissa Firestone", zone = "Forjaz", uiMapID = 1455, x = 54.9, y = 58.5, rank = "Oficial" },
                { name = "Dannelor", zone = "Darnassus", uiMapID = 1457, x = 51.7, y = 12.5, rank = "Oficial" },
            },
            ["150-225"] = {
                { name = "Deneb Walker", zone = "Tierras Altas de Arathi", uiMapID = 1417, x = 27.1, y = 58.8, rank = "Experto (Vendedor Libros)" },
            },
            ["225-300"] = {
                { name = "Doctor Gustaf VanHowzen", zone = "Desolace", uiMapID = 1445, x = 67.8, y = 49.0, rank = "Artesano (Misión Triaje)" },
            },
        },
        ["Horde"] = {
            ["1-75"] = {
                { name = "Arnok", zone = "Orgrimmar", uiMapID = 1454, x = 34.2, y = 84.5, rank = "Aprendiz" },
                { name = "Pand Stonebinder", zone = "Cima del Trueno", uiMapID = 1456, x = 29.6, y = 21.3, rank = "Aprendiz" },
                { name = "Mary Edras", zone = "Entrañas", uiMapID = 1458, x = 73.4, y = 55.7, rank = "Aprendiz" },
                { name = "Rawrk", zone = "Durotar", uiMapID = 1411, x = 54.2, y = 42.0, rank = "Aprendiz" },
                { name = "Vira Younghoof", zone = "Mulgore", uiMapID = 1412, x = 46.1, y = 63.9, rank = "Aprendiz" },
            },
            ["75-150"] = {
                { name = "Arnok", zone = "Orgrimmar", uiMapID = 1454, x = 34.2, y = 84.5, rank = "Oficial" },
                { name = "Pand Stonebinder", zone = "Cima del Trueno", uiMapID = 1456, x = 29.6, y = 21.3, rank = "Oficial" },
                { name = "Mary Edras", zone = "Entrañas", uiMapID = 1458, x = 73.4, y = 55.7, rank = "Oficial" },
            },
            ["150-225"] = {
                { name = "Balai Lok'Wein", zone = "Marjal Revolcafango", uiMapID = 1428, x = 36.5, y = 30.4, rank = "Experto (Vendedor Libros)" },
            },
            ["225-300"] = {
                { name = "Doctor Gregory Victor", zone = "Tierras Altas de Arathi", uiMapID = 1417, x = 73.4, y = 36.8, rank = "Artesano (Misión Triaje)" },
            },
        },
    },

    ["Fishing"] = {
        ["Alliance"] = {
            ["1-75"] = {
                { name = "Arnold Leland", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 55.0, y = 69.6, rank = "Aprendiz" },
                { name = "Grimnur Stonebrand", zone = "Forjaz", uiMapID = 1455, x = 48.1, y = 6.5, rank = "Aprendiz" },
                { name = "Astaia", zone = "Darnassus", uiMapID = 1457, x = 47.8, y = 56.7, rank = "Aprendiz" },
                { name = "Lee Brown", zone = "Bosque de Elwynn", uiMapID = 1429, x = 47.6, y = 62.3, rank = "Aprendiz" },
            },
            ["75-150"] = {
                { name = "Arnold Leland", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 55.0, y = 69.6, rank = "Oficial" },
                { name = "Grimnur Stonebrand", zone = "Forjaz", uiMapID = 1455, x = 48.1, y = 6.5, rank = "Oficial" },
                { name = "Astaia", zone = "Darnassus", uiMapID = 1457, x = 47.8, y = 56.7, rank = "Oficial" },
            },
            ["150-225"] = {
                { name = "Old Man Heming", zone = "Vega de Tuercespina", uiMapID = 1434, x = 27.5, y = 77.1, rank = "Experto (Vendedor Libro)" },
            },
            ["225-300"] = {
                { name = "Nat Pagle", zone = "Marjal Revolcafango", uiMapID = 1428, x = 58.6, y = 60.1, rank = "Artesano (Misión Pesca)" },
            },
        },
        ["Horde"] = {
            ["1-75"] = {
                { name = "Lumak", zone = "Orgrimmar", uiMapID = 1454, x = 69.8, y = 29.2, rank = "Aprendiz" },
                { name = "Kah Mistrunner", zone = "Cima del Trueno", uiMapID = 1456, x = 56.1, y = 46.7, rank = "Aprendiz" },
                { name = "Armand Cromwell", zone = "Entrañas", uiMapID = 1458, x = 80.9, y = 31.1, rank = "Aprendiz" },
                { name = "Lau'Tiki", zone = "Durotar", uiMapID = 1411, x = 53.3, y = 81.6, rank = "Aprendiz" },
                { name = "Uthan Stillwater", zone = "Mulgore", uiMapID = 1412, x = 44.2, y = 63.7, rank = "Aprendiz" },
            },
            ["75-150"] = {
                { name = "Lumak", zone = "Orgrimmar", uiMapID = 1454, x = 69.8, y = 29.2, rank = "Oficial" },
                { name = "Kah Mistrunner", zone = "Cima del Trueno", uiMapID = 1456, x = 56.1, y = 46.7, rank = "Oficial" },
                { name = "Armand Cromwell", zone = "Entrañas", uiMapID = 1458, x = 80.9, y = 31.1, rank = "Oficial" },
            },
            ["150-225"] = {
                { name = "Old Man Heming", zone = "Vega de Tuercespina", uiMapID = 1434, x = 27.5, y = 77.1, rank = "Experto (Vendedor Libro)" },
            },
            ["225-300"] = {
                { name = "Nat Pagle", zone = "Marjal Revolcafango", uiMapID = 1428, x = 58.6, y = 60.1, rank = "Artesano (Misión Pesca)" },
            },
        },
    },

    ["Mining"] = {
        ["Alliance"] = {
            ["1-75"] = {
                { name = "Gelman Stonehand", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 59.2, y = 37.8, rank = "Aprendiz" },
                { name = "Geofram Bouldertoe", zone = "Forjaz", uiMapID = 1455, x = 50.2, y = 26.1, rank = "Aprendiz" },
                { name = "Kelsey Fargo", zone = "Bosque de Elwynn", uiMapID = 1429, x = 47.2, y = 32.2, rank = "Aprendiz" },
                { name = "Sally Swiftwrench", zone = "Dun Morogh", uiMapID = 1426, x = 28.8, y = 67.8, rank = "Aprendiz" },
            },
            ["75-150"] = {
                { name = "Gelman Stonehand", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 59.2, y = 37.8, rank = "Oficial" },
                { name = "Geofram Bouldertoe", zone = "Forjaz", uiMapID = 1455, x = 50.2, y = 26.1, rank = "Oficial" },
            },
            ["150-225"] = {
                { name = "Gelman Stonehand", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 59.2, y = 37.8, rank = "Experto" },
                { name = "Geofram Bouldertoe", zone = "Forjaz", uiMapID = 1455, x = 50.2, y = 26.1, rank = "Experto" },
            },
            ["225-300"] = {
                { name = "Gelman Stonehand", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 59.2, y = 37.8, rank = "Artesano" },
                { name = "Geofram Bouldertoe", zone = "Forjaz", uiMapID = 1455, x = 50.2, y = 26.1, rank = "Artesano" },
            },
        },
        ["Horde"] = {
            ["1-75"] = {
                { name = "Makaru", zone = "Orgrimmar", uiMapID = 1454, x = 73.1, y = 26.4, rank = "Aprendiz" },
                { name = "Brek Stonehoof", zone = "Cima del Trueno", uiMapID = 1456, x = 34.6, y = 57.6, rank = "Aprendiz" },
                { name = "Brom Killian", zone = "Entrañas", uiMapID = 1458, x = 56.0, y = 37.1, rank = "Aprendiz" },
                { name = "Norzsh", zone = "Durotar", uiMapID = 1411, x = 40.5, y = 68.1, rank = "Aprendiz" },
            },
            ["75-150"] = {
                { name = "Makaru", zone = "Orgrimmar", uiMapID = 1454, x = 73.1, y = 26.4, rank = "Oficial" },
                { name = "Brek Stonehoof", zone = "Cima del Trueno", uiMapID = 1456, x = 34.6, y = 57.6, rank = "Oficial" },
                { name = "Brom Killian", zone = "Entrañas", uiMapID = 1458, x = 56.0, y = 37.1, rank = "Oficial" },
            },
            ["150-225"] = {
                { name = "Makaru", zone = "Orgrimmar", uiMapID = 1454, x = 73.1, y = 26.4, rank = "Experto" },
                { name = "Brek Stonehoof", zone = "Cima del Trueno", uiMapID = 1456, x = 34.6, y = 57.6, rank = "Experto" },
            },
            ["225-300"] = {
                { name = "Makaru", zone = "Orgrimmar", uiMapID = 1454, x = 73.1, y = 26.4, rank = "Artesano" },
                { name = "Brek Stonehoof", zone = "Cima del Trueno", uiMapID = 1456, x = 34.6, y = 57.6, rank = "Artesano" },
            },
        },
    },

    ["Herbalism"] = {
        ["Alliance"] = {
            ["1-75"] = {
                { name = "Shylamiir", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 31.4, y = 63.0, rank = "Aprendiz" },
                { name = "Reyna Stonebranch", zone = "Forjaz", uiMapID = 1455, x = 55.7, y = 59.0, rank = "Aprendiz" },
                { name = "Firodren Mooncaller", zone = "Darnassus", uiMapID = 1457, x = 47.9, y = 68.6, rank = "Aprendiz" },
                { name = "Nancy Songflower", zone = "Bosque de Elwynn", uiMapID = 1429, x = 52.2, y = 43.4, rank = "Aprendiz" },
            },
            ["75-150"] = {
                { name = "Tannysa", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 54.4, y = 84.0, rank = "Oficial" },
                { name = "Reyna Stonebranch", zone = "Forjaz", uiMapID = 1455, x = 55.7, y = 59.0, rank = "Oficial" },
                { name = "Firodren Mooncaller", zone = "Darnassus", uiMapID = 1457, x = 47.9, y = 68.6, rank = "Oficial" },
            },
            ["150-225"] = {
                { name = "Tannysa", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 54.4, y = 84.0, rank = "Experto" },
                { name = "Firodren Mooncaller", zone = "Darnassus", uiMapID = 1457, x = 47.9, y = 68.6, rank = "Experto" },
            },
            ["225-300"] = {
                { name = "Tannysa", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 54.4, y = 84.0, rank = "Artesano" },
                { name = "Firodren Mooncaller", zone = "Darnassus", uiMapID = 1457, x = 47.9, y = 68.6, rank = "Artesano" },
            },
        },
        ["Horde"] = {
            ["1-75"] = {
                { name = "Jandi", zone = "Orgrimmar", uiMapID = 1454, x = 55.5, y = 39.7, rank = "Aprendiz" },
                { name = "Komin Winterhoof", zone = "Cima del Trueno", uiMapID = 1456, x = 50.0, y = 40.1, rank = "Aprendiz" },
                { name = "Martha Alliestar", zone = "Entrañas", uiMapID = 1458, x = 54.3, y = 49.6, rank = "Aprendiz" },
                { name = "Mishiki", zone = "Durotar", uiMapID = 1411, x = 55.5, y = 75.1, rank = "Aprendiz" },
            },
            ["75-150"] = {
                { name = "Jandi", zone = "Orgrimmar", uiMapID = 1454, x = 55.5, y = 39.7, rank = "Oficial" },
                { name = "Komin Winterhoof", zone = "Cima del Trueno", uiMapID = 1456, x = 50.0, y = 40.1, rank = "Oficial" },
                { name = "Martha Alliestar", zone = "Entrañas", uiMapID = 1458, x = 54.3, y = 49.6, rank = "Oficial" },
            },
            ["150-225"] = {
                { name = "Jandi", zone = "Orgrimmar", uiMapID = 1454, x = 55.5, y = 39.7, rank = "Experto" },
                { name = "Komin Winterhoof", zone = "Cima del Trueno", uiMapID = 1456, x = 50.0, y = 40.1, rank = "Experto" },
            },
            ["225-300"] = {
                { name = "Jandi", zone = "Orgrimmar", uiMapID = 1454, x = 55.5, y = 39.7, rank = "Artesano" },
                { name = "Komin Winterhoof", zone = "Cima del Trueno", uiMapID = 1456, x = 50.0, y = 40.1, rank = "Artesano" },
            },
        },
    },

    ["Skinning"] = {
        ["Alliance"] = {
            ["1-75"] = {
                { name = "Maris Granger", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 72.2, y = 62.5, rank = "Aprendiz" },
                { name = "Balthus Stoneflayer", zone = "Forjaz", uiMapID = 1455, x = 39.7, y = 32.3, rank = "Aprendiz" },
                { name = "Eladriel", zone = "Darnassus", uiMapID = 1457, x = 64.2, y = 22.1, rank = "Aprendiz" },
                { name = "Helene Peltskinner", zone = "Bosque de Elwynn", uiMapID = 1429, x = 46.3, y = 62.3, rank = "Aprendiz" },
            },
            ["75-150"] = {
                { name = "Maris Granger", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 72.2, y = 62.5, rank = "Oficial" },
                { name = "Balthus Stoneflayer", zone = "Forjaz", uiMapID = 1455, x = 39.7, y = 32.3, rank = "Oficial" },
                { name = "Eladriel", zone = "Darnassus", uiMapID = 1457, x = 64.2, y = 22.1, rank = "Oficial" },
            },
            ["150-225"] = {
                { name = "Maris Granger", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 72.2, y = 62.5, rank = "Experto" },
                { name = "Balthus Stoneflayer", zone = "Forjaz", uiMapID = 1455, x = 39.7, y = 32.3, rank = "Experto" },
                { name = "Eladriel", zone = "Darnassus", uiMapID = 1457, x = 64.2, y = 22.1, rank = "Experto" },
            },
            ["225-300"] = {
                { name = "Maris Granger", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 72.2, y = 62.5, rank = "Artesano" },
                { name = "Balthus Stoneflayer", zone = "Forjaz", uiMapID = 1455, x = 39.7, y = 32.3, rank = "Artesano" },
                { name = "Eladriel", zone = "Darnassus", uiMapID = 1457, x = 64.2, y = 22.1, rank = "Artesano" },
            },
        },
        ["Horde"] = {
            ["1-75"] = {
                { name = "Thuwd", zone = "Orgrimmar", uiMapID = 1454, x = 63.2, y = 45.4, rank = "Aprendiz" },
                { name = "Mooranta", zone = "Cima del Trueno", uiMapID = 1456, x = 44.5, y = 43.0, rank = "Aprendiz" },
                { name = "Killian Hagey", zone = "Entrañas", uiMapID = 1458, x = 70.2, y = 59.1, rank = "Aprendiz" },
                { name = "Kagil", zone = "Durotar", uiMapID = 1411, x = 40.8, y = 67.9, rank = "Aprendiz" },
                { name = "Yonn Deepcut", zone = "Mulgore", uiMapID = 1412, x = 45.0, y = 61.4, rank = "Aprendiz" },
            },
            ["75-150"] = {
                { name = "Thuwd", zone = "Orgrimmar", uiMapID = 1454, x = 63.2, y = 45.4, rank = "Oficial" },
                { name = "Mooranta", zone = "Cima del Trueno", uiMapID = 1456, x = 44.5, y = 43.0, rank = "Oficial" },
                { name = "Killian Hagey", zone = "Entrañas", uiMapID = 1458, x = 70.2, y = 59.1, rank = "Oficial" },
            },
            ["150-225"] = {
                { name = "Thuwd", zone = "Orgrimmar", uiMapID = 1454, x = 63.2, y = 45.4, rank = "Experto" },
                { name = "Mooranta", zone = "Cima del Trueno", uiMapID = 1456, x = 44.5, y = 43.0, rank = "Experto" },
                { name = "Killian Hagey", zone = "Entrañas", uiMapID = 1458, x = 70.2, y = 59.1, rank = "Experto" },
            },
            ["225-300"] = {
                { name = "Thuwd", zone = "Orgrimmar", uiMapID = 1454, x = 63.2, y = 45.4, rank = "Artesano" },
                { name = "Mooranta", zone = "Cima del Trueno", uiMapID = 1456, x = 44.5, y = 43.0, rank = "Artesano" },
                { name = "Killian Hagey", zone = "Entrañas", uiMapID = 1458, x = 70.2, y = 59.1, rank = "Artesano" },
            },
        },
    },

}


-- Obtiene el mejor entrenador para una profesión, facción y tramo,
-- priorizando el más cercano al mapa actual del jugador si hay varios.
function ns.GetProfessionTrainer(profKey, bracket, faction)
    local db = ns.Data and ns.Data.ProfessionTrainers and ns.Data.ProfessionTrainers[profKey]
    if not db then return nil end

    faction = faction or (UnitFactionGroup and UnitFactionGroup("player")) or "Alliance"
    local fData = db[faction] or db["Alliance"]
    if not fData then return nil end

    -- Resolver tramo si es "auto"
    bracket = bracket or "auto"
    if bracket == "auto" then
        local pProfs = ns.GetPlayerProfessions and ns.GetPlayerProfessions()
        local pData = pProfs and pProfs[profKey]
        local currentSkill = (pData and pData.rank) or 0
        if currentSkill < 75 then
            bracket = "1-75"
        elseif currentSkill < 150 then
            bracket = "75-150"
        elseif currentSkill < 225 then
            bracket = "150-225"
        else
            bracket = "225-300"
        end
    end

    local list = fData[bracket] or fData["1-75"]
    if not list or #list == 0 then return nil end

    -- Si el jugador está en un mapa específico, buscar el de ese mapa
    local playerMapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    if playerMapID then
        for _, t in ipairs(list) do
            if t.uiMapID == playerMapID then
                return t, bracket
            end
        end
    end

    -- Si no, devolver el primero (capital principal o instructor especializado)
    return list[1], bracket
end
