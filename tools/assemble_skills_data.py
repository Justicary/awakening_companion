import os

with open("scratch/generated_skills.lua", "r", encoding="utf-8") as f:
    generated_content = f.read()

trainers_lua = """
-- =========================================================================
-- BASE DE DATOS DE ENTRENADORES DE CLASE Y MAESTROS DE ARMAS (WOW FOREVER)
-- =========================================================================
ns.Data.Trainers = {
    WARRIOR = {
        Alliance = {
            { name = "Wu Shen", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 75.8, y = 49.5, subText = "Entrenador de guerreros" },
            { name = "Lyros Prestransunto", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 75.2, y = 49.2, subText = "Entrenador de guerreros" },
            { name = "Kelstron Partenoche", zone = "Forjaz", uiMapID = 1455, x = 69.8, y = 90.0, subText = "Entrenador de guerreros" },
            { name = "Bilger el Constructor", zone = "Forjaz", uiMapID = 1455, x = 70.4, y = 89.2, subText = "Entrenador de guerreros" },
            { name = "Alyissia", zone = "Darnassus", uiMapID = 1457, x = 57.0, y = 36.2, subText = "Entrenadora de guerreros" },
            { name = "Lyria Du Lac", zone = "Bosque de Elwynn (Villadorada)", uiMapID = 1429, x = 42.6, y = 65.8, subText = "Entrenadora de guerreros" },
            { name = "Thran Khorman", zone = "Dun Morogh (Kharanos)", uiMapID = 1426, x = 46.8, y = 52.4, subText = "Entrenador de guerreros" },
            { name = "Kyra Hoja de Viento", zone = "Teldrassil (Dolanaar)", uiMapID = 1438, x = 56.6, y = 59.8, subText = "Entrenadora de guerreros" },
            { name = "Dan Murph", zone = "Páramos de Poniente (Colina del Centinela)", uiMapID = 1436, x = 52.8, y = 53.6, subText = "Entrenador de guerreros" },
        },
        Horde = {
            { name = "Grezz Puñofuria", zone = "Orgrimmar", uiMapID = 1454, x = 79.8, y = 31.2, subText = "Entrenador de guerreros" },
            { name = "Sorek", zone = "Orgrimmar", uiMapID = 1454, x = 80.2, y = 32.4, subText = "Entrenador de guerreros" },
            { name = "Sark Tótem de Furia", zone = "Cima del Trueno", uiMapID = 1456, x = 57.4, y = 86.8, subText = "Entrenador de guerreros" },
            { name = "Christoph Walker", zone = "Entrañas", uiMapID = 1458, x = 56.4, y = 34.6, subText = "Entrenador de guerreros" },
            { name = "Tarshaw Cicatrizmellada", zone = "Durotar (Cerco del Filo)", uiMapID = 1411, x = 52.4, y = 43.8, subText = "Entrenador de guerreros" },
            { name = "Harutt Cuerno de Trueno", zone = "Mulgore (Pezuña de Sangre)", uiMapID = 1412, x = 47.6, y = 60.8, subText = "Entrenador de guerreros" },
            { name = "Austil de Mon", zone = "Claros de Tirisfal (Brill)", uiMapID = 1420, x = 61.8, y = 52.8, subText = "Entrenador de guerreros" },
            { name = "Ug'thok", zone = "Los Baldíos (El Cruce)", uiMapID = 1413, x = 51.6, y = 30.8, subText = "Entrenador de guerreros" },
        }
    },
    PALADIN = {
        Alliance = {
            { name = "Katherine Carter", zone = "Ciudad de Ventormenta (Catedral)", uiMapID = 1453, x = 39.8, y = 29.8, subText = "Entrenadora de paladines" },
            { name = "Hermano Wilhelm", zone = "Ciudad de Ventormenta (Catedral)", uiMapID = 1453, x = 40.4, y = 30.2, subText = "Entrenador de paladines" },
            { name = "Brandur Martillo de Hierro", zone = "Forjaz (Sala Mística)", uiMapID = 1455, x = 24.2, y = 7.8, subText = "Entrenador de paladines" },
            { name = "Valgar Forjalta", zone = "Forjaz (Sala Mística)", uiMapID = 1455, x = 24.6, y = 8.4, subText = "Entrenador de paladines" },
            { name = "Hermano Danil", zone = "Bosque de Elwynn (Villadorada)", uiMapID = 1429, x = 41.6, y = 66.0, subText = "Entrenador de paladines" },
            { name = "Bromos Grummner", zone = "Dun Morogh (Kharanos)", uiMapID = 1426, x = 46.8, y = 52.2, subText = "Entrenador de paladines" },
        },
        Horde = {
            { name = "Campeón Cyshan", zone = "Orgrimmar (Valle del Honor)", uiMapID = 1454, x = 79.4, y = 31.8, subText = "Entrenador de paladines" },
            { name = "Caballero de Sangre Antheol", zone = "Entrañas (Barrio Militar)", uiMapID = 1458, x = 56.8, y = 34.0, subText = "Entrenador de paladines" },
        }
    },
    ROGUE = {
        Alliance = {
            { name = "Ian Strom", zone = "Ciudad de Ventormenta (Casco Antiguo)", uiMapID = 1453, x = 75.4, y = 59.4, subText = "Entrenador de pícaros" },
            { name = "Osborne el Nocturno", zone = "Ciudad de Ventormenta (Casco Antiguo)", uiMapID = 1453, x = 74.8, y = 58.8, subText = "Entrenador de pícaros" },
            { name = "Hulfdan Barbanegra", zone = "Forjaz (Caverna Forlorn)", uiMapID = 1455, x = 52.8, y = 14.8, subText = "Entrenador de pícaros" },
            { name = "Syurna", zone = "Darnassus (Enclave Cenarion)", uiMapID = 1457, x = 36.6, y = 21.6, subText = "Entrenadora de pícaros" },
            { name = "Keryn Sylvius", zone = "Bosque de Elwynn (Villadorada)", uiMapID = 1429, x = 41.8, y = 66.8, subText = "Entrenador de pícaros" },
            { name = "Rana", zone = "Dun Morogh (Kharanos)", uiMapID = 1426, x = 46.8, y = 52.8, subText = "Entrenadora de pícaros" },
            { name = "Jannok Piedragris", zone = "Teldrassil (Dolanaar)", uiMapID = 1438, x = 56.4, y = 58.8, subText = "Entrenador de pícaros" },
            { name = "Lucius", zone = "Montañas Crestagrana (Villa del Lago)", uiMapID = 1433, x = 27.2, y = 47.0, subText = "Entrenador de pícaros" },
        },
        Horde = {
            { name = "Shenthul", zone = "Orgrimmar (Valle del Honor)", uiMapID = 1454, x = 76.0, y = 24.6, subText = "Entrenador de pícaros" },
            { name = "Gest", zone = "Orgrimmar (Valle del Honor)", uiMapID = 1454, x = 75.6, y = 24.2, subText = "Entrenador de pícaros" },
            { name = "Gregory Charles", zone = "Entrañas (Barrio de Pícaros)", uiMapID = 1458, x = 84.4, y = 73.2, subText = "Entrenador de pícaros" },
            { name = "Miles Dexter", zone = "Entrañas (Barrio de Pícaros)", uiMapID = 1458, x = 84.8, y = 74.0, subText = "Entrenador de pícaros" },
            { name = "Ansekhwa", zone = "Cima del Trueno (Alto de Cazadores)", uiMapID = 1456, x = 60.4, y = 82.2, subText = "Entrenador de pícaros" },
            { name = "Rwag", zone = "Durotar (Cerco del Filo)", uiMapID = 1411, x = 52.6, y = 43.2, subText = "Entrenador de pícaros" },
            { name = "Marion Call", zone = "Claros de Tirisfal (Brill)", uiMapID = 1420, x = 61.8, y = 52.4, subText = "Entrenadora de pícaros" },
            { name = "Kaplak", zone = "Los Baldíos (El Cruce)", uiMapID = 1413, x = 52.0, y = 30.4, subText = "Entrenador de pícaros" },
        }
    },
    HUNTER = {
        Alliance = {
            { name = "Ulbrek Manofuego", zone = "Ciudad de Ventormenta (Distrito Enano)", uiMapID = 1453, x = 62.6, y = 12.8, subText = "Entrenador de cazadores" },
            { name = "Einris Lanzasol", zone = "Ciudad de Ventormenta (Distrito Enano)", uiMapID = 1453, x = 63.2, y = 13.4, subText = "Entrenadora de cazadores" },
            { name = "Daillan Barbafirme", zone = "Forjaz (Sala Militar)", uiMapID = 1455, x = 71.4, y = 90.4, subText = "Entrenador de cazadores" },
            { name = "Jocaste", zone = "Darnassus (Bancal de Artesanos)", uiMapID = 1457, x = 40.2, y = 8.8, subText = "Entrenadora de cazadores" },
            { name = "Grif Corazón Salvaje", zone = "Dun Morogh (Kharanos)", uiMapID = 1426, x = 46.2, y = 53.6, subText = "Entrenador de cazadores" },
            { name = "Dazalar", zone = "Teldrassil (Dolanaar)", uiMapID = 1438, x = 56.4, y = 59.4, subText = "Entrenador de cazadores" },
            { name = "Teron", zone = "Costa Oscura (Auberdine)", uiMapID = 1439, x = 37.8, y = 41.2, subText = "Entrenador de cazadores" },
        },
        Horde = {
            { name = "Ormak Disparogris", zone = "Orgrimmar (Valle del Honor)", uiMapID = 1454, x = 68.8, y = 17.8, subText = "Entrenador de cazadores" },
            { name = "Holt Cuerno de Trueno", zone = "Cima del Trueno (Alto de Cazadores)", uiMapID = 1456, x = 59.4, y = 91.0, subText = "Entrenador de cazadores" },
            { name = "Tiffany Cartier", zone = "Entrañas (Barrio Militar)", uiMapID = 1458, x = 48.0, y = 16.4, subText = "Entrenadora de cazadores" },
            { name = "Thotar", zone = "Durotar (Cerco del Filo)", uiMapID = 1411, x = 52.2, y = 43.4, subText = "Entrenador de cazadores" },
            { name = "Yaw Crinafilada", zone = "Mulgore (Pezuña de Sangre)", uiMapID = 1412, x = 47.8, y = 55.4, subText = "Entrenador de cazadores" },
            { name = "Uthan Aguaserenas", zone = "Los Baldíos (El Cruce)", uiMapID = 1413, x = 51.4, y = 30.2, subText = "Entrenador de cazadores" },
        }
    },
    MAGE = {
        Alliance = {
            { name = "Lucan Cordell", zone = "Ciudad de Ventormenta (Sagrario de Magos)", uiMapID = 1453, x = 48.6, y = 87.4, subText = "Entrenador de magos" },
            { name = "Jennea Cannon", zone = "Ciudad de Ventormenta (Sagrario de Magos)", uiMapID = 1453, x = 49.2, y = 88.0, subText = "Entrenadora de magos" },
            { name = "Dink", zone = "Forjaz (Sala Mística)", uiMapID = 1455, x = 26.6, y = 8.6, subText = "Entrenador de magos" },
            { name = "Zaldimar Tramavacía", zone = "Bosque de Elwynn (Villadorada)", uiMapID = 1429, x = 42.4, y = 66.2, subText = "Entrenador de magos" },
            { name = "Magis Manto Chispas", zone = "Dun Morogh (Kharanos)", uiMapID = 1426, x = 46.8, y = 52.6, subText = "Entrenador de magos" },
        },
        Horde = {
            { name = "Thurston Xane", zone = "Orgrimmar (Valle de los Espíritus)", uiMapID = 1454, x = 38.8, y = 85.6, subText = "Entrenador de magos" },
            { name = "Pephredo", zone = "Orgrimmar (Valle de los Espíritus)", uiMapID = 1454, x = 38.2, y = 86.2, subText = "Entrenador de magos" },
            { name = "Anastasia Hartwell", zone = "Entrañas (Barrio de Magia)", uiMapID = 1458, x = 85.0, y = 15.6, subText = "Entrenadora de magos" },
            { name = "Archimago Unng Ak", zone = "Cima del Trueno (Pozas de las Visiones)", uiMapID = 1456, x = 78.4, y = 28.6, subText = "Entrenador de magos" },
            { name = "Deino", zone = "Durotar (Cerco del Filo)", uiMapID = 1411, x = 52.0, y = 43.6, subText = "Entrenadora de magos" },
            { name = "Cain Cantofuego", zone = "Claros de Tirisfal (Brill)", uiMapID = 1420, x = 61.6, y = 52.2, subText = "Entrenador de magos" },
        }
    },
    PRIEST = {
        Alliance = {
            { name = "Suma Sacerdotisa Laurena", zone = "Ciudad de Ventormenta (Catedral)", uiMapID = 1453, x = 38.6, y = 26.8, subText = "Entrenadora de sacerdotes" },
            { name = "Hermano Joshua", zone = "Ciudad de Ventormenta (Catedral)", uiMapID = 1453, x = 39.2, y = 26.2, subText = "Entrenador de sacerdotes" },
            { name = "Sumo Sacerdote Rohan", zone = "Forjaz (Sala Mística)", uiMapID = 1455, x = 24.2, y = 8.8, subText = "Entrenador de sacerdotes" },
            { name = "Astarii Buscastrellas", zone = "Darnassus (Templo de la Luna)", uiMapID = 1457, x = 36.2, y = 77.2, subText = "Entrenadora de sacerdotes" },
            { name = "Sacerdotisa Josetta", zone = "Bosque de Elwynn (Villadorada)", uiMapID = 1429, x = 41.8, y = 66.4, subText = "Entrenadora de sacerdotes" },
            { name = "Maxan Anvol", zone = "Dun Morogh (Kharanos)", uiMapID = 1426, x = 46.6, y = 52.8, subText = "Entrenador de sacerdotes" },
            { name = "Shanda", zone = "Teldrassil (Dolanaar)", uiMapID = 1438, x = 56.6, y = 60.2, subText = "Entrenadora de sacerdotes" },
        },
        Horde = {
            { name = "Ur'kyo", zone = "Orgrimmar (Valle de los Espíritus)", uiMapID = 1454, x = 35.8, y = 36.8, subText = "Entrenador de sacerdotes" },
            { name = "Padre Atanasio", zone = "Entrañas (Barrio Militar)", uiMapID = 1458, x = 49.6, y = 16.6, subText = "Entrenador de sacerdotes" },
            { name = "Malakai Cross", zone = "Cima del Trueno (Alto Mayor)", uiMapID = 1456, x = 45.4, y = 59.2, subText = "Entrenador de sacerdotes" },
            { name = "Tai'jin", zone = "Durotar (Cerco del Filo)", uiMapID = 1411, x = 52.2, y = 43.8, subText = "Entrenador de sacerdotes" },
            { name = "Padre Lankester", zone = "Claros de Tirisfal (Brill)", uiMapID = 1420, x = 61.6, y = 52.6, subText = "Entrenador de sacerdotes" },
            { name = "Miles Hocico Firme", zone = "Mulgore (Pezuña de Sangre)", uiMapID = 1412, x = 47.6, y = 60.4, subText = "Entrenador de sacerdotes" },
        }
    },
    WARLOCK = {
        Alliance = {
            { name = "Demisette Hendidura", zone = "Ciudad de Ventormenta (Cordero Degollado)", uiMapID = 1453, x = 39.4, y = 84.4, subText = "Entrenadora de brujos" },
            { name = "Sandahl", zone = "Ciudad de Ventormenta (Cordero Degollado)", uiMapID = 1453, x = 39.8, y = 84.8, subText = "Entrenador de brujos" },
            { name = "Zarzal", zone = "Forjaz (Caverna Forlorn)", uiMapID = 1455, x = 52.4, y = 6.2, subText = "Entrenador de brujos" },
            { name = "Gimrizz Sombragranaje", zone = "Forjaz (Caverna Forlorn)", uiMapID = 1455, x = 53.0, y = 6.8, subText = "Entrenador de brujos" },
            { name = "Maximillian Crowe", zone = "Bosque de Elwynn (Villadorada)", uiMapID = 1429, x = 43.4, y = 65.8, subText = "Entrenador de brujos" },
        },
        Horde = {
            { name = "Zevrost", zone = "Orgrimmar (Sima / Hendidura de las Sombras)", uiMapID = 1454, x = 48.6, y = 45.8, subText = "Entrenador de brujos" },
            { name = "Mirket", zone = "Orgrimmar (Hendidura de las Sombras)", uiMapID = 1454, x = 48.2, y = 46.4, subText = "Entrenadora de brujos" },
            { name = "Richard Kerwin", zone = "Entrañas (El Boticario)", uiMapID = 1458, x = 48.2, y = 17.6, subText = "Entrenador de brujos" },
            { name = "Dhug", zone = "Durotar (Cerco del Filo)", uiMapID = 1411, x = 52.6, y = 43.4, subText = "Entrenador de brujos" },
            { name = "Maximillion", zone = "Claros de Tirisfal (Brill)", uiMapID = 1420, x = 61.4, y = 52.6, subText = "Entrenador de brujos" },
        }
    },
    DRUID = {
        Alliance = {
            { name = "Mathrengyl Caminanteoso", zone = "Darnassus (Enclave Cenarion)", uiMapID = 1457, x = 35.4, y = 8.4, subText = "Entrenador de druidas" },
            { name = "Denathar", zone = "Darnassus (Enclave Cenarion)", uiMapID = 1457, x = 35.8, y = 9.0, subText = "Entrenador de druidas" },
            { name = "Sheldras Árbol Lunar", zone = "Ciudad de Ventormenta (El Parque)", uiMapID = 1453, x = 21.8, y = 55.4, subText = "Entrenador de druidas" },
            { name = "Kal", zone = "Teldrassil (Dolanaar)", uiMapID = 1438, x = 56.4, y = 60.8, subText = "Entrenador de druidas" },
            { name = "Loganaar", zone = "Claro de la Luna (Amparo de la Noche)", uiMapID = 1450, x = 52.6, y = 40.6, subText = "Entrenador de druidas" },
        },
        Horde = {
            { name = "Turak Tótem de Runa", zone = "Cima del Trueno (Alto de Ancianos)", uiMapID = 1456, x = 76.6, y = 27.2, subText = "Entrenador de druidas" },
            { name = "Sheal Tótem de Runa", zone = "Cima del Trueno (Alto de Ancianos)", uiMapID = 1456, x = 76.2, y = 27.8, subText = "Entrenadora de druidas" },
            { name = "Gennia Tótem de Runa", zone = "Mulgore (Pezuña de Sangre)", uiMapID = 1412, x = 47.8, y = 60.4, subText = "Entrenadora de druidas" },
            { name = "Loganaar", zone = "Claro de la Luna (Amparo de la Noche)", uiMapID = 1450, x = 52.6, y = 40.6, subText = "Entrenador de druidas" },
        }
    },
    SHAMAN = {
        Alliance = {
            { name = "Kardris Buscasueños", zone = "Orgrimmar (Valle de los Espíritus)", uiMapID = 1454, x = 38.6, y = 35.8, subText = "Entrenador de chamanes" },
        },
        Horde = {
            { name = "Kardris Buscasueños", zone = "Orgrimmar (Valle de los Espíritus)", uiMapID = 1454, x = 38.6, y = 35.8, subText = "Entrenador de chamanes" },
            { name = "Beram Cazacielos", zone = "Cima del Trueno (Alto Mayor)", uiMapID = 1456, x = 40.4, y = 63.6, subText = "Entrenador de chamanes" },
            { name = "Tiggy Peggle", zone = "Cima del Trueno (Alto Mayor)", uiMapID = 1456, x = 40.8, y = 64.2, subText = "Entrenadora de chamanes" },
            { name = "Krenna", zone = "Entrañas (Barrio Militar)", uiMapID = 1458, x = 48.0, y = 16.0, subText = "Entrenadora de chamanes" },
            { name = "Swart", zone = "Durotar (Cerco del Filo)", uiMapID = 1411, x = 52.4, y = 43.6, subText = "Entrenador de chamanes" },
            { name = "Vidente Plumacuervo", zone = "Mulgore (Pezuña de Sangre)", uiMapID = 1412, x = 47.4, y = 60.6, subText = "Entrenador de chamanes" },
            { name = "Boor Baing", zone = "Los Baldíos (Campamento Taurajo)", uiMapID = 1413, x = 44.6, y = 59.2, subText = "Entrenador de chamanes" },
        }
    },
    WEAPONS = {
        Alliance = {
            { name = "Woo Ping", zone = "Ciudad de Ventormenta", uiMapID = 1453, x = 63.9, y = 69.1, subText = "Maestro de armas (Espadas, Bastones, Ballestas, Armas de asta)" },
            { name = "Buliwyf Petramano", zone = "Forjaz", uiMapID = 1455, x = 61.2, y = 89.5, subText = "Maestro de armas (Hachas, Mazas, Armas de puño, Armas de fuego)" },
            { name = "Bixi Tambaleapié", zone = "Forjaz", uiMapID = 1455, x = 62.2, y = 89.6, subText = "Maestro de armas (Dagas, Ballestas, Armas arrojadizas)" },
            { name = "Ilyenia Fuegolunar", zone = "Darnassus", uiMapID = 1457, x = 57.7, y = 46.0, subText = "Maestra de armas (Arcos, Dagas, Armas de puño, Bastones, Arrojadizas)" },
        },
        Horde = {
            { name = "Hanashi", zone = "Orgrimmar", uiMapID = 1454, x = 81.6, y = 19.4, subText = "Maestro de armas (Arcos, Hachas, Bastones, Arrojadizas)" },
            { name = "Sayoc", zone = "Orgrimmar", uiMapID = 1454, x = 81.4, y = 19.2, subText = "Maestro de armas (Dagas, Armas de puño, Hachas 1M)" },
            { name = "Ansekhwa", zone = "Cima del Trueno", uiMapID = 1456, x = 40.8, y = 62.8, subText = "Maestro de armas (Armas de fuego, Mazas, Bastones)" },
            { name = "Archibald", zone = "Entrañas", uiMapID = 1458, x = 57.4, y = 32.8, subText = "Maestro de armas (Ballestas, Dagas, Espadas, Armas de asta)" },
        }
    }
}
"""

final_content = generated_content + "\n" + trainers_lua

with open("Data/SkillsData.lua", "w", encoding="utf-8") as f:
    f.write(final_content)

print("Created Data/SkillsData.lua successfully!")
