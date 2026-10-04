local ADDON, ns = ...

ns.Data = ns.Data or {}

-- =========================================================================
-- GUÍAS MAESTRAS DE PROFESIONES Y MATERIALES (WoW Forever / Classic 1-300)
-- Obtenidas y verificadas de: https://www.wow-professions.com/forever
-- =========================================================================
ns.Data.ProfessionGuides = {
    -- ---------------------------------------------------------------------
    -- 1. PELETERÍA (LEATHERWORKING)
    -- ---------------------------------------------------------------------
    ["Leatherworking"] = {
        key = "Leatherworking",
        name = "Peletería",
        category = "Fabricación",
        icon = "Interface\\Icons\\inv_misc_armorkit_17",
        guideUrl = "https://www.wow-professions.com/forever/leatherworking-leveling-guide",
        partnerProf = "Skinning",
        partnerProfName = "Desuello",
        summary = "Guía de subida más económica 1-300 para WoW Forever. Combina a la perfección con Desuello.",
        trainers = {
            alliance = "Adele Fielder (Elwynn), Randal Worth (Ventormenta), Gretta Finespindle (Forjaz), Telonis (Experto en Darnassus), Drakk Stonehand (Artesano en Tierras del Interior).",
            horde = "Chaw Stronghide (Mulgore), Shelene Rhobart (Tirisfal), Karolek (Orgrimmar), Una (Experta en Cima del Trueno), Hahrana Ironhide (Artesana en Feralas)."
        },
        brackets = {
            ["1-75"] = {
                key = "1-75",
                name = "1 - 75 · Aprendiz",
                skillRange = "1 - 75",
                minSkill = 1,
                maxSkill = 75,
                reqLevel = 1,
                trainerTip = "Disponible desde nivel 1 con cualquier instructor en capitales o zonas de inicio.",
                materials = {
                    { id = 2934, name = "Retales de cuero estropeados", count = 100, alternative = "60x Cuero ligero si compras en subasta", source = "Desuello en zonas de inicio (1-12) / Subasta", zone = "Bosque de Elwynn / Dun Morogh / Durotar / Mulgore" },
                    { id = 2318, name = "Cuero ligero", count = 50, alternative = "Se obtiene al juntar los retales", source = "Desuello bestias nivel 5-15 / Subasta", zone = "Páramos de Poniente / Los Baldíos / Argénteos" },
                    { id = 2320, name = "Hilo burdo", count = 20, isVendor = true, source = "Vendedores de suministros de peletería y sastrería", zone = "Cualquier capital o puesto avanzado" },
                },
                recipes = {
                    { range = "1 - 30",  name = "Cuero ligero (x33)", mats = "100x Retales de cuero estropeados", tip = "Se vuelve amarillo a 20. Si compraste Cuero ligero directamente, puedes empezar fabricando Parches ligeros." },
                    { range = "30 - 45", name = "Parche para armadura ligero (x20)", mats = "20x Cuero ligero", tip = "Amarillo desde 30, puedes requerir 2 o 3 parches extra." },
                    { range = "45 - 55", name = "Guantes de cuero repujados (x10)", mats = "30x Cuero ligero, 20x Hilo burdo", tip = "Compra el hilo burdo en el vendedor de suministros junto a tu instructor." },
                    { range = "55 - 75", name = "Guantes de cuero repujados (x20)", mats = "60x Cuero ligero, 40x Hilo burdo", tip = "Los últimos 5 puntos se vuelven amarillos pero es la opción más económica." },
                },
                farmingRoute = {
                    title = "Farmeo de Cuero Ligero y Retales",
                    zoneName = "Bosque de Elwynn / Dun Morogh",
                    uiMapID = 1429,
                    steps = {
                        { x = 42.5, y = 64.0, title = "1. Claros de Villadorada", instruction = "Caza y desuella jabalíes y lobos en los llanos." },
                        { x = 52.0, y = 52.0, title = "2. Lago Espejo", instruction = "Desuella osos y lobos alrededor del lago." },
                    }
                }
            },
            ["75-150"] = {
                key = "75-150",
                name = "75 - 150 · Oficial",
                skillRange = "75 - 150",
                minSkill = 75,
                maxSkill = 150,
                reqLevel = 10,
                trainerTip = "Aprende Oficial con Simon Tanner (Ventormenta) o Karolek (Orgrimmar). Requiere nivel 10 y habilidad 50.",
                materials = {
                    { id = 2318, name = "Cuero ligero", count = 150, alternative = "Comprar en subasta o farmear", source = "Desuello bestias nivel 10-20", zone = "Páramos de Poniente / Los Baldíos / Bosque de Argénteos" },
                    { id = 4232, name = "Pellejo medio", count = 25, alternative = "Ruta sin pellejo: 270x Cuero medio", source = "Desuello bestias nivel 18-30 / Subasta", zone = "Laderas de Trabalomas / Crestagrana / Los Baldíos" },
                    { id = 4289, name = "Sal salada", count = 25, isVendor = true, source = "Vendedores de suministros de peletería", zone = "Capitales" },
                    { id = 2319, name = "Cuero medio", count = 150, alternative = "Se obtiene desollando o transformando cuero ligero", source = "Desuello bestias nivel 18-32", zone = "Laderas de Trabalomas / Sierra Espolón / Las Mil Agujas" },
                    { id = 2604, name = "Tinte gris", count = 25, isVendor = true, source = "Vendedores de peletería y sastrería", zone = "Capitales" },
                    { id = 2321, name = "Hilo fino", count = 50, isVendor = true, source = "Vendedores de suministros", zone = "Capitales" },
                },
                recipes = {
                    { range = "55 - 80",   name = "Cinturón de cuero refinado (x25)", mats = "150x Cuero ligero, 50x Hilo burdo", tip = "¡Guarda todos los cinturones! Los necesitarás para fabricar los Cinturones de cuero oscuro a nivel 100." },
                    { range = "80 - 100",  name = "Pellejo medio curado (x25)", mats = "25x Pellejo medio, 25x Sal", tip = "Guarda los pellejos curados. Si el Pellejo medio es muy caro en subasta, consulta la ruta alternativa con Cuero medio." },
                    { range = "100 - 125", name = "Cinturón de cuero oscuro (x25)", mats = "25x Cinturón de cuero refinado, 25x Pellejo medio curado, 50x Hilo fino, 25x Tinte gris", tip = "Utiliza los cinturones y pellejos que guardaste anteriormente." },
                    { range = "125 - 130", name = "Cuero pesado (x7)", mats = "35x Cuero medio", tip = "Convierte Cuero medio en Cuero pesado. Detente a 130 porque la receta se vuelve verde." },
                },
                farmingRoute = {
                    title = "Farmeo de Cuero Medio y Pellejo Medio",
                    zoneName = "Laderas de Trabalomas",
                    uiMapID = 1424,
                    steps = {
                        { x = 44.2, y = 58.0, title = "1. Meseta de los Leones", instruction = "Caza y desuella leones de montaña y osos pardos." },
                        { x = 51.5, y = 35.2, title = "2. Cueva de Arañas", instruction = "Desuella bestias en las faldas de las montañas." },
                    }
                }
            },
            ["150-225"] = {
                key = "150-225",
                name = "150 - 225 · Experto",
                skillRange = "150 - 225",
                minSkill = 150,
                maxSkill = 225,
                reqLevel = 20,
                trainerTip = "Aprende Experto con Telonis (Darnassus - Alianza) o Una (Cima del Trueno - Horda). Requiere nivel 20 y habilidad 125. Coste: 50 plata.",
                materials = {
                    { id = 2319, name = "Cuero medio", count = 294, source = "Desuello bestias nivel 20-30", zone = "Trabalomas / Humedales / Mil Agujas" },
                    { id = 4235, name = "Pellejo pesado", count = 20, alternative = "Ruta sin pellejo: 310x Cuero pesado + 15x Ágata de musgo", source = "Desuello bestias nivel 30-42 / Subasta", zone = "Vega de Tuercespina / Trabalomas" },
                    { id = 4234, name = "Cuero pesado", count = 310, source = "Desuello bestias nivel 30-45", zone = "Vega de Tuercespina / Tierras Altas de Arathi / Feralas" },
                    { id = 4304, name = "Cuero grueso", count = 435, source = "Desuello bestias nivel 40-50", zone = "Feralas / Tanaris / Tierras del Interior" },
                    { id = 4291, name = "Hilo de seda", count = 75, isVendor = true, source = "Vendedores de suministros de peletería", zone = "Capitales" },
                },
                recipes = {
                    { range = "150 - 155", name = "Pellejo pesado curado (x20)", mats = "20x Pellejo pesado, 60x Sal salada", tip = "Si no tienes pellejo, fabrica Parches de armadura pesados con Cuero pesado." },
                    { range = "155 - 165", name = "Pantalones de cuero oscuro (x10)", mats = "120x Cuero medio, 10x Pellejo gris curado, 10x Hilo fino", tip = "Receta muy eficiente para agotar remanentes de cuero medio." },
                    { range = "165 - 180", name = "Parche para armadura pesado (x15)", mats = "75x Cuero pesado, 15x Hilo de seda", tip = "La receta se vuelve amarilla a 170, pero sigue siendo barata." },
                    { range = "180 - 190", name = "Sobrehombros bárbaros (x10)", mats = "80x Cuero pesado, 10x Pellejo pesado curado, 20x Hilo de seda", tip = "Si no tienes pellejo curado, fabrica Yelmos de cuero oscuro." },
                    { range = "190 - 205", name = "Guantes del anochecer (x15)", mats = "60x Cuero pesado, 15x Hilo de seda, 30x Tinte negro", tip = "Se vuelven amarillos a 200, haz algunos extra si hace falta." },
                    { range = "205 - 225", name = "Cuero grueso (x87)", mats = "435x Cuero pesado", tip = "Transforma cuero pesado en cuero grueso. Sube habilidad prácticamente gratis." },
                },
                farmingRoute = {
                    title = "Farmeo de Cuero Pesado y Pellejo Pesado",
                    zoneName = "Vega de Tuercespina",
                    uiMapID = 1434,
                    steps = {
                        { x = 38.5, y = 49.0, title = "1. Ribera del Río Nazferiti", instruction = "Desuella crocoliscos y panteras jóvenes a lo largo del río." },
                        { x = 44.0, y = 35.0, title = "2. Campamento Kurzen", instruction = "Caza raptores y tigres en las colinas circundantes." },
                    }
                }
            },
            ["225-300"] = {
                key = "225-300",
                name = "225 - 300 · Artesano",
                skillRange = "225 - 300",
                minSkill = 225,
                maxSkill = 300,
                reqLevel = 35,
                trainerTip = "Aprende Artesano con Drakk Stonehand (Pico Nidal, Tierras del Interior - Alianza) o Hahrana Ironhide (Campamento Mojache, Feralas - Horda). Requiere nivel 35 y habilidad 200.",
                materials = {
                    { id = 4304, name = "Cuero grueso", count = 385, source = "Desuello bestias nivel 40-52", zone = "Tierras del Interior / Feralas / Tanaris" },
                    { id = 8170, name = "Cuero basto", count = 480, source = "Desuello bestias nivel 50-60", zone = "Cráter de Un'Goro / Cuna del Invierno / Tierras de la Peste" },
                    { id = 8171, name = "Pellejo basto", count = 10, alternative = "Ruta sin pellejo: 40x Cuero basto extra", source = "Drop raro de bestias nivel 50-60 / Subasta", zone = "Cráter de Un'Goro / Cuna del Invierno" },
                    { id = 14341, name = "Hilo rúnico", count = 115, isVendor = true, source = "Vendedores de suministros de sastrería y peletería", zone = "Capitales y puestos de nivel 50+" },
                    { id = 4340, name = "Tinte negro", count = 30, isVendor = true, source = "Vendedores de suministros", zone = "Capitales" },
                },
                recipes = {
                    { range = "225 - 235", name = "Pantalones de noche (x10)", mats = "140x Cuero grueso, 40x Hilo de seda", tip = "Aprende del instructor artesano." },
                    { range = "235 - 250", name = "Pantalones de noche (x15)", mats = "210x Cuero grueso, 60x Hilo de seda", tip = "La receta se vuelve amarilla a 230, pero el cuero grueso suele ser abundante." },
                    { range = "250 - 260", name = "Parche para armadura basto (x15)", mats = "75x Cuero basto", tip = "Receta extremadamente barata para ingresar al tramo final." },
                    { range = "260 - 275", name = "Guanteletes aterronados (x15)", mats = "120x Cuero basto, 15x Pellejo basto curado, 15x Hilo rúnico", tip = "Si no tienes pellejo basto, fabrica Parches para armadura bastos hasta 270." },
                    { range = "275 - 285", name = "Brazales de cuero perverso (x10)", mats = "80x Cuero basto, 10x Tinte negro, 10x Hilo rúnico", tip = "Patrón vendido por Wark Cueromarrón (Tierras del Interior) o Leonard Porter (Tierras del Interior)." },
                    { range = "285 - 300", name = "Cinturón de cuero perverso (x15)", mats = "180x Cuero basto, 30x Tinte negro, 15x Hilo rúnico", tip = "Patrón drop de mundo. Alternativa: Diadema de cuero perverso." },
                },
                farmingRoute = {
                    title = "Farmeo de Cuero Basto y Pellejo Basto",
                    zoneName = "Cráter de Un'Goro",
                    uiMapID = 1449,
                    steps = {
                        { x = 50.0, y = 30.0, title = "1. Marisma Pantanosa", instruction = "Caza terodáctilos y gorilas en el valle central." },
                        { x = 65.0, y = 60.0, title = "2. Fila de Demosaurios", instruction = "Excelente densidad de bestias para acumular Cuero basto velozmente." },
                    }
                }
            }
        }
    },

    -- ---------------------------------------------------------------------
    -- 2. DESUELLO (SKINNING)
    -- ---------------------------------------------------------------------
    ["Skinning"] = {
        key = "Skinning",
        name = "Desuello",
        category = "Recolección",
        icon = "Interface\\Icons\\inv_misc_leatherscrap_05",
        guideUrl = "https://www.wow-professions.com/classic/skinning-leveling-guide",
        partnerProf = "Leatherworking",
        partnerProfName = "Peletería",
        summary = "Profesión de recolección indispensable para abastecer a Peletería con pieles, cueros y escamas.",
        trainers = {
            alliance = "Helene Pelopellejo (Elwynn), Maris Granger (Ventormenta), Balthus Rompepiedras (Forjaz), Eladriel (Darnassus).",
            horde = "Yarlyn Ambarrocha (Mulgore), Killian Santhon (Tirisfal), Thuong Espinarespinosa (Orgrimmar), Malcomb Wynter (Entrañas)."
        },
        brackets = {
            ["1-75"] = {
                key = "1-75",
                name = "1 - 75 · Aprendiz",
                skillRange = "1 - 75",
                minSkill = 1,
                maxSkill = 75,
                reqLevel = 1,
                trainerTip = "Compra un Cuchillo de desollar en el vendedor de suministros y equípalo en tus bolsas.",
                materials = {
                    { id = 2934, name = "Retales de cuero estropeados", count = 60, source = "Bestias nivel 1-10", zone = "Bosque de Elwynn / Dun Morogh / Durotar / Mulgore" },
                    { id = 2318, name = "Cuero ligero", count = 80, source = "Bestias nivel 8-15", zone = "Páramos de Poniente / Los Baldíos / Argénteos" },
                },
                recipes = {
                    { range = "1 - 50",  name = "Desuello en Zonas de Inicio", mats = "Bestias Nv. 1 a 10", tip = "Lobos, jabalíes y felinos jóvenes. Caza cerca de los campamentos iniciales." },
                    { range = "50 - 75", name = "Desuello en Zonas Secundarias", mats = "Bestias Nv. 10 a 15", tip = "Páramos de Poniente, Los Baldíos, Crestagrana o Costa Oscura." },
                },
                farmingRoute = {
                    title = "Ruta de Desuello Ligero (Páramos)",
                    zoneName = "Páramos de Poniente",
                    uiMapID = 1436,
                    steps = {
                        { x = 45.0, y = 35.0, title = "1. Campos del Norte", instruction = "Desuella jabalíes y buitres alrededor de las granjas." },
                        { x = 50.0, y = 60.0, title = "2. Colinas de Dagger", instruction = "Caza leones y coyotes en las colinas." },
                    }
                }
            },
            ["75-150"] = {
                key = "75-150",
                name = "75 - 150 · Oficial",
                skillRange = "75 - 150",
                minSkill = 75,
                maxSkill = 150,
                reqLevel = 10,
                trainerTip = "Aprende Oficial al llegar a habilidad 50 con cualquier instructor en capitales.",
                materials = {
                    { id = 2319, name = "Cuero medio", count = 120, source = "Bestias nivel 15-28", zone = "Trabalomas / Crestagrana / Los Baldíos / Humedales" },
                    { id = 4232, name = "Pellejo medio", count = 20, source = "Drop raro al desollar bestias nivel 18-30", zone = "Laderas de Trabalomas / Crestagrana" },
                },
                recipes = {
                    { range = "75 - 100",  name = "Bestias Nv. 15 a 20", mats = "Cuero medio y ligero", tip = "Llanuras de Los Baldíos y Crestagrana." },
                    { range = "100 - 150", name = "Bestias Nv. 20 a 28", mats = "Cuero medio abundante", tip = "Laderas de Trabalomas (leones y osos) y Humedales (crocoliscos)." },
                },
                farmingRoute = {
                    title = "Ruta de Cuero Medio (Trabalomas)",
                    zoneName = "Laderas de Trabalomas",
                    uiMapID = 1424,
                    steps = {
                        { x = 44.2, y = 58.0, title = "1. Llanos de los Pumas", instruction = "Caza pumas de montaña y osos pardos." },
                        { x = 55.4, y = 52.8, title = "2. Ribera del Río", instruction = "Desuella arañas y bestias del bosque." },
                    }
                }
            },
            ["150-225"] = {
                key = "150-225",
                name = "150 - 225 · Experto",
                skillRange = "150 - 225",
                minSkill = 150,
                maxSkill = 225,
                reqLevel = 20,
                trainerTip = "Aprende Experto al llegar a 125 con Balthus Rompepiedras (Forjaz) o Thuong (Orgrimmar).",
                materials = {
                    { id = 4234, name = "Cuero pesado", count = 150, source = "Bestias nivel 30-45", zone = "Vega de Tuercespina / Trabalomas / Feralas" },
                    { id = 4235, name = "Pellejo pesado", count = 20, source = "Bestias nivel 30-42", zone = "Vega de Tuercespina / Arathi" },
                    { id = 4304, name = "Cuero grueso", count = 100, source = "Bestias nivel 40-48", zone = "Feralas / Tierras del Interior / Tanaris" },
                },
                recipes = {
                    { range = "150 - 180", name = "Bestias Nv. 28 a 35", mats = "Cuero pesado", tip = "Norte de Vega de Tuercespina y Tierras Altas de Arathi." },
                    { range = "180 - 225", name = "Bestias Nv. 35 a 45", mats = "Cuero pesado y grueso", tip = "Sur de Tuercespina (gorilas y rapaces) y Feralas." },
                },
                farmingRoute = {
                    title = "Ruta de Cuero Pesado (Tuercespina)",
                    zoneName = "Vega de Tuercespina",
                    uiMapID = 1434,
                    steps = {
                        { x = 38.0, y = 50.0, title = "1. Río Nazferiti", instruction = "Cocodrilos del río y tigres jóvenes." },
                        { x = 44.0, y = 40.0, title = "2. Meseta de las Panteras", instruction = "Panteras sombra y rapaces colasable." },
                    }
                }
            },
            ["225-300"] = {
                key = "225-300",
                name = "225 - 300 · Artesano",
                skillRange = "225 - 300",
                minSkill = 225,
                maxSkill = 300,
                reqLevel = 35,
                trainerTip = "Aprende Artesano con Drakk Stonehand (Pico Nidal - Alianza) o Hahrana Ironhide (Campamento Mojache - Horda).",
                materials = {
                    { id = 4304, name = "Cuero grueso", count = 150, source = "Bestias nivel 45-52", zone = "Feralas / Tierras del Interior / Tanaris" },
                    { id = 8170, name = "Cuero basto", count = 200, source = "Bestias nivel 50-60", zone = "Cráter de Un'Goro / Cuna del Invierno" },
                    { id = 8171, name = "Pellejo basto", count = 15, source = "Bestias nivel 52-60", zone = "Cráter de Un'Goro / Cuna del Invierno" },
                },
                recipes = {
                    { range = "225 - 250", name = "Bestias Nv. 45 a 52", mats = "Cuero grueso", tip = "Tierras del Interior (leporinos y búhos) y Feralas." },
                    { range = "250 - 300", name = "Bestias Nv. 52 a 60", mats = "Cuero basto y demosaurio", tip = "Cráter de Un'Goro (dinosaurios) y Cuna del Invierno (quimeras y yetis)." },
                },
                farmingRoute = {
                    title = "Ruta de Cuero Basto (Un'Goro)",
                    zoneName = "Cráter de Un'Goro",
                    uiMapID = 1449,
                    steps = {
                        { x = 50.0, y = 30.0, title = "1. Marismas del Norte", instruction = "Dinosaurios y terodáctilos." },
                        { x = 68.0, y = 55.0, title = "2. Cresta Oriental", instruction = "Gorilas y rapaces del cráter." },
                    }
                }
            }
        }
    },

    -- ---------------------------------------------------------------------
    -- 3. ALQUIMIA (ALCHEMY)
    -- ---------------------------------------------------------------------
    ["Alchemy"] = {
        key = "Alchemy",
        name = "Alquimia",
        category = "Fabricación",
        icon = "Interface\\Icons\\trade_alchemy",
        guideUrl = "https://www.wow-professions.com/forever/alchemy-leveling-guide",
        partnerProf = "Herbalism",
        partnerProfName = "Herboristería",
        summary = "Crea pociones, elixires y frascos indispensables para bandas y mazmorras.",
        trainers = {
            alliance = "Lilyssia Nightbreeze (Ventormenta), Ainethil (Darnassus), Ghok'kah (Forjaz), Kylanna Viento del Viento (Feralas - Artesana).",
            horde = "Doctor Herbert Halsey (Entrañas), Bena Viento Invernal (Cima del Trueno), Yelmak (Orgrimmar), Rogvar (Pantano de las Penas - Artesano)."
        },
        brackets = {
            ["1-75"] = {
                key = "1-75",
                name = "1 - 75 · Aprendiz",
                skillRange = "1 - 75",
                minSkill = 1,
                maxSkill = 75,
                reqLevel = 1,
                trainerTip = "Aprende con cualquier instructor en las ciudades principales.",
                materials = {
                    { id = 2447, name = "Pazguina", count = 59, source = "Herboristería zonas 1-12 / Subasta", zone = "Bosque de Elwynn / Dun Morogh / Durotar / Mulgore" },
                    { id = 765,  name = "Hojaplata", count = 59, source = "Herboristería zonas 1-12 / Subasta", zone = "Bosque de Elwynn / Dun Morogh / Durotar / Mulgore" },
                    { id = 2450, name = "Brezospina", count = 80, source = "Herboristería zonas 10-25 / Subasta", zone = "Páramos de Poniente / Los Baldíos / Argénteos" },
                    { id = 3371, name = "Vial vacío", count = 140, isVendor = true, source = "Vendedores de suministros de alquimia", zone = "Capitales" },
                },
                recipes = {
                    { range = "1 - 60",  name = "Poción de curación menor (x65)", mats = "1x Pazguina, 1x Hojaplata, 1x Vial vacío", tip = "¡Guarda todas estas pociones! Las necesitarás en el paso 110 para fabricar Pociones de curación." },
                    { range = "60 - 75", name = "Poción de curación inferior (x15)", mats = "1x Poción de curación menor, 1x Brezospina", tip = "Combina las pociones guardadas con brezospina." },
                },
                farmingRoute = {
                    title = "Farmeo de Pazguina y Hojaplata",
                    zoneName = "Bosque de Elwynn / Durotar",
                    uiMapID = 1429,
                    steps = {
                        { x = 42.0, y = 65.0, title = "1. Llanos de Villadorada", instruction = "Recoge Pazguina y Hojaplata en prados abiertos." },
                        { x = 55.0, y = 45.0, title = "2. Alrededores de Torre Azora", instruction = "Nodos de hierbas a la orilla del camino." },
                    }
                }
            },
            ["75-150"] = {
                key = "75-150",
                name = "75 - 150 · Oficial",
                skillRange = "75 - 150",
                minSkill = 75,
                maxSkill = 150,
                reqLevel = 10,
                trainerTip = "Aprende Oficial al alcanzar nivel 10 y habilidad 50.",
                materials = {
                    { id = 2450, name = "Brezospina", count = 30, source = "Herboristería zonas 12-25", zone = "Los Baldíos / Páramos / Argénteos" },
                    { id = 2452, name = "Cardopresto", count = 30, source = "Herboristería zonas 15-28", zone = "Los Baldíos / Crestagrana / Trabalomas" },
                    { id = 785,  name = "Hierba cardenal", count = 15, source = "Herboristería zonas 10-20", zone = "Los Baldíos / Costa Oscura / Páramos" },
                    { id = 3356, name = "Sangrerregia", count = 40, source = "Herboristería zonas 25-40", zone = "Laderas de Trabalomas / Humedales" },
                    { id = 3372, name = "Vial plomizo", count = 85, isVendor = true, source = "Vendedores de alquimia", zone = "Capitales" },
                },
                recipes = {
                    { range = "75 - 105",  name = "Poción de curación inferior (x30)", mats = "1x Poción menor, 1x Brezospina", tip = "Termina de usar las pociones menores preparadas." },
                    { range = "105 - 110", name = "Elixir de agilidad menor (x5)", mats = "1x Cardopresto, 1x Hierba cardenal, 1x Vial", tip = "Receta de transición muy barata." },
                    { range = "110 - 140", name = "Poción de curación (x30)", mats = "1x Cardopresto, 1x Brezospina, 1x Vial con plomo", tip = "Poción de curación estándar de nivel 20-30." },
                    { range = "140 - 150", name = "Poción de maná inferior (x10)", mats = "1x Hierba cardenal, 1x Sangrerregia, 1x Vial", tip = "Te lleva cómodamente a habilidad 150." },
                },
                farmingRoute = {
                    title = "Farmeo de Brezospina y Cardopresto",
                    zoneName = "Los Baldíos / Crestagrana",
                    uiMapID = 1413,
                    steps = {
                        { x = 52.0, y = 30.0, title = "1. Cruce de Caminos", instruction = "Abundantes nodos de Brezospina en las raíces." },
                        { x = 45.0, y = 58.0, title = "2. Oasis del Sur", instruction = "Cardopresto en las orillas del agua." },
                    }
                }
            },
            ["150-225"] = {
                key = "150-225",
                name = "150 - 225 · Experto",
                skillRange = "150 - 225",
                minSkill = 150,
                maxSkill = 225,
                reqLevel = 20,
                trainerTip = "Aprende Experto con Ainethil (Darnassus) o Doctor Herbert Halsey (Entrañas). Requiere nivel 20 y habilidad 125.",
                materials = {
                    { id = 3356, name = "Sangrerregia", count = 30, source = "Herboristería zonas 25-40", zone = "Trabalomas / Arathi / Tuercespina" },
                    { id = 3357, name = "Raíz de vida", count = 30, source = "Herboristería riberas y pantanos", zone = "Trabalomas / Humedales" },
                    { id = 3818, name = "Pálida", count = 30, source = "Herboristería zonas 30-45", zone = "Arathi / Vega de Tuercespina / Feralas" },
                    { id = 3821, name = "Espina de oro", count = 30, source = "Herboristería zonas 35-45", zone = "Arathi / Tierras Inhóspitas / Desolace" },
                    { id = 3358, name = "Mostacho de Khadgar", count = 30, source = "Herboristería zonas 35-50", zone = "Arathi / Tierras del Interior / Feralas" },
                },
                recipes = {
                    { range = "150 - 155", name = "Poción de curación (x5)", mats = "1x Cardopresto, 1x Brezospina", tip = "Últimos puntos del rango anterior." },
                    { range = "155 - 175", name = "Poción de curación mayor (x20)", mats = "1x Raíz de vida, 1x Sangrerregia, 1x Vial", tip = "Poción esencial para leveleo intermedio." },
                    { range = "175 - 185", name = "Poción de maná (x10)", mats = "1x Sangrerregia, 1x Mostacho de Khadgar", tip = "Aprende del instructor." },
                    { range = "185 - 205", name = "Elixir de agilidad (x20)", mats = "1x Pálida, 1x Espina de oro, 1x Vial plomizo", tip = "Elixir muy demandado por melés y cazadores." },
                    { range = "205 - 215", name = "Elixir de defensa superior (x10)", mats = "1x Acónito, 1x Espina de oro", tip = "Receta vendida por comerciantes en Darnassus / Entrañas." },
                    { range = "215 - 225", name = "Poción de curación superior (x10)", mats = "1x Soleada, 1x Mostacho de Khadgar", tip = "Te prepara para el rango artesano." },
                },
                farmingRoute = {
                    title = "Farmeo de Sangrerregia y Raíz de Vida",
                    zoneName = "Laderas de Trabalomas",
                    uiMapID = 1424,
                    steps = {
                        { x = 45.0, y = 40.0, title = "1. Valle de Trabalomas", instruction = "Recoge Sangrerregia en las ruinas y colinas." },
                        { x = 58.0, y = 60.0, title = "2. Ribera del Río", instruction = "Raíz de vida abundante pegada al agua." },
                    }
                }
            },
            ["225-300"] = {
                key = "225-300",
                name = "225 - 300 · Artesano",
                skillRange = "225 - 300",
                minSkill = 225,
                maxSkill = 300,
                reqLevel = 35,
                trainerTip = "Aprende Artesano con Kylanna Viento del Viento (Bastión Plumaluna, Feralas - Alianza) o Rogvar (Pantano de las Penas - Horda). Requiere nivel 35 y habilidad 200.",
                materials = {
                    { id = 8838,  name = "Soleada", count = 50, source = "Herboristería zonas 40-52", zone = "Feralas / Tierras del Interior / Tanaris" },
                    { id = 8839,  name = "Flor ciega", count = 40, source = "Herboristería pantanos 40-50", zone = "Pantano de las Penas" },
                    { id = 13464, name = "Sansam dorado", count = 40, source = "Herboristería zonas 45-55", zone = "Feralas / Cráter de Un'Goro / Azshara" },
                    { id = 13467, name = "Silbavellosa", count = 40, source = "Herboristería riscos altos 50-60", zone = "Cuna del Invierno / Silithus / Tierras de la Peste" },
                    { id = 13466, name = "Flor de peste", count = 20, source = "Herboristería zonas 50-60", zone = "Tierras de la Peste del Este / Oeste" },
                    { id = 8925,  name = "Vial de cristal", count = 150, isVendor = true, source = "Vendedores de alquimia", zone = "Capitales" },
                },
                recipes = {
                    { range = "225 - 230", name = "Poción de curación superior (x5)", mats = "1x Soleada, 1x Mostacho de Khadgar", tip = "Termina de usar las hierbas del tramo anterior." },
                    { range = "230 - 250", name = "Elixir de detección de no-muertos (x20)", mats = "1x Flor ciega, 1x Vial de cristal", tip = "¡La forma más barata de subir hasta 250! La Flor ciega es muy abundante." },
                    { range = "250 - 265", name = "Elixir de agilidad excelente (x15)", mats = "1x Soleada, 1x Espina de oro, 1x Vial", tip = "Muy cotizado para consumibles de mazmorra." },
                    { range = "265 - 285", name = "Poción de maná excelente (x20)", mats = "2x Soleada, 2x Flor ciega, 1x Vial", tip = "Patrón vendido por Ulthir (Darnassus) o Algor (Entrañas)." },
                    { range = "285 - 300", name = "Poción de curación mayor (x15)", mats = "2x Sansam dorado, 1x Silbavellosa, 1x Vial", tip = "Patrón vendido por Evie Remolino en Cuna del Invierno. ¡Consumible BiS de banda!" },
                },
                farmingRoute = {
                    title = "Farmeo de Flor Ciega y Soleada",
                    zoneName = "Pantano de las Penas / Feralas",
                    uiMapID = 1435,
                    steps = {
                        { x = 45.0, y = 55.0, title = "1. Pantano Central", instruction = "Flor ciega masiva en los islotes pantanosos." },
                        { x = 60.0, y = 30.0, title = "2. Ruinas de Atal'Hakkar", instruction = "Hierbas de alto nivel alrededor de las charcas." },
                    }
                }
            }
        }
    },

    -- ---------------------------------------------------------------------
    -- 4. HERBORISTERÍA (HERBALISM)
    -- ---------------------------------------------------------------------
    ["Herbalism"] = {
        key = "Herbalism",
        name = "Herboristería",
        category = "Recolección",
        icon = "Interface\\Icons\\spell_nature_naturetouchgrow",
        guideUrl = "https://www.wow-professions.com/classic/herbalism-leveling-guide",
        partnerProf = "Alchemy",
        partnerProfName = "Alquimia",
        summary = "Recolección de plantas y flores del mundo para abastecer Alquimia y Sastrería.",
        trainers = {
            alliance = "Tannysa (Ventormenta), Reyna Stonebranch (Forjaz), Malfurion Stormrage (Darnassus).",
            horde = "Martha Allipso (Entrañas), Jandi (Orgrimmar), Komin Caminarrisco (Cima del Trueno)."
        },
        brackets = {
            ["1-75"] = {
                key = "1-75",
                name = "1 - 75 · Aprendiz",
                skillRange = "1 - 75",
                minSkill = 1,
                maxSkill = 75,
                reqLevel = 1,
                trainerTip = "Activa siempre 'Buscar hierbas' en tu minimapa para ver los nodos cercanos.",
                materials = {
                    { id = 2447, name = "Pazguina", count = 60, source = "Zonas de inicio (Habilidad 1+)", zone = "Elwynn / Dun Morogh / Durotar / Mulgore" },
                    { id = 765,  name = "Hojaplata", count = 60, source = "Zonas de inicio (Habilidad 1+)", zone = "Elwynn / Dun Morogh / Durotar / Mulgore" },
                    { id = 2449, name = "Raíz de tierra", count = 30, source = "Colinas de zonas iniciales (Habilidad 15+)", zone = "Páramos / Los Baldíos / Crestagrana" },
                },
                recipes = {
                    { range = "1 - 50",  name = "Pazguina y Hojaplata", mats = "Nodos 1+", tip = "Recorre los bosques y praderas de tu zona natal." },
                    { range = "50 - 75", name = "Raíz de tierra y Brezospina", mats = "Nodos 15-70", tip = "Busca en riscos rocosos y bajo las copas de los árboles grandes." },
                },
                farmingRoute = {
                    title = "Ruta de Hierbas Iniciales (Elwynn)",
                    zoneName = "Bosque de Elwynn",
                    uiMapID = 1429,
                    steps = {
                        { x = 38.0, y = 62.0, title = "1. Huertos de Villadorada", instruction = "Pazguina y Hojaplata en la pradera sur." },
                        { x = 50.0, y = 50.0, title = "2. Lago Espejo", instruction = "Raíz de tierra en las peñas alrededor del agua." },
                    }
                }
            },
            ["75-150"] = {
                key = "75-150",
                name = "75 - 150 · Oficial",
                skillRange = "75 - 150",
                minSkill = 75,
                maxSkill = 150,
                reqLevel = 10,
                trainerTip = "Aprende Oficial al llegar a habilidad 50 con cualquier instructor.",
                materials = {
                    { id = 785,  name = "Hierba cardenal", count = 50, source = "Zonas nivel 12-25 (Habilidad 50+)", zone = "Páramos de Poniente / Los Baldíos / Costa Oscura" },
                    { id = 2450, name = "Brezospina", count = 60, source = "Bajo raíces de árboles (Habilidad 70+)", zone = "Los Baldíos / Crestagrana / Argénteos" },
                    { id = 2452, name = "Cardopresto", count = 40, source = "Tierras áridas y caminos (Habilidad 100+)", zone = "Los Baldíos / Crestagrana / Trabalomas" },
                    { id = 3355, name = "Acónito de acero salvaje", count = 20, source = "Rocas y acantilados (Habilidad 115+)", zone = "Sierra Espolón / Las Mil Agujas / Trabalomas" },
                },
                recipes = {
                    { range = "75 - 100",  name = "Hierba cardenal y Brezospina", mats = "Habilidad 50-70", tip = "Los Baldíos y Páramos de Poniente ofrecen circuitos planos ideales." },
                    { range = "100 - 150", name = "Cardopresto y Acónito salvaje", mats = "Habilidad 100-115", tip = "Crestagrana y Laderas de Trabalomas." },
                },
                farmingRoute = {
                    title = "Ruta de Hierbas Oficiales (Los Baldíos)",
                    zoneName = "Los Baldíos",
                    uiMapID = 1413,
                    steps = {
                        { x = 52.0, y = 32.0, title = "1. Oasis de los Olvidados", instruction = "Brezospina y Cardopresto alrededor de la charca." },
                        { x = 44.0, y = 55.0, title = "2. Cañón de los Enanos", instruction = "Acónito salvaje en las crestas rocosas." },
                    }
                }
            },
            ["150-225"] = {
                key = "150-225",
                name = "150 - 225 · Experto",
                skillRange = "150 - 225",
                minSkill = 150,
                maxSkill = 225,
                reqLevel = 20,
                trainerTip = "Aprende Experto al alcanzar nivel 20 y habilidad 125 en tu capital.",
                materials = {
                    { id = 3356, name = "Sangrerregia", count = 60, source = "Zonas 25-40 (Habilidad 125+)", zone = "Laderas de Trabalomas / Humedales / Arathi" },
                    { id = 3818, name = "Pálida", count = 40, source = "Zonas sombrías 30-45 (Habilidad 160+)", zone = "Arathi / Vega de Tuercespina / Feralas" },
                    { id = 3358, name = "Mostacho de Khadgar", count = 50, source = "Zonas 35-50 (Habilidad 185+)", zone = "Arathi / Tierras del Interior / Feralas" },
                    { id = 3821, name = "Espina de oro", count = 40, source = "Zonas montañosas (Habilidad 170+)", zone = "Tierras Inhóspitas / Arathi / Desolace" },
                },
                recipes = {
                    { range = "150 - 170", name = "Sangrerregia y Raíz de vida", mats = "Habilidad 125-150", tip = "Laderas de Trabalomas alrededor del río y campos de cultivo." },
                    { range = "170 - 225", name = "Pálida y Mostacho de Khadgar", mats = "Habilidad 160-185", tip = "Tierras Altas de Arathi y norte de Vega de Tuercespina." },
                },
                farmingRoute = {
                    title = "Ruta de Herboristería Experta (Arathi)",
                    zoneName = "Tierras Altas de Arathi",
                    uiMapID = 1417,
                    steps = {
                        { x = 46.0, y = 44.0, title = "1. Llanos de Arathi", instruction = "Sangrerregia y Pálida en los límites de granjas." },
                        { x = 60.0, y = 65.0, title = "2. Círculo de Vinculación", instruction = "Mostacho de Khadgar y Espina de oro en las rocas." },
                    }
                }
            },
            ["225-300"] = {
                key = "225-300",
                name = "225 - 300 · Artesano",
                skillRange = "225 - 300",
                minSkill = 225,
                maxSkill = 300,
                reqLevel = 35,
                trainerTip = "Aprende Artesano con Reyna Stonebranch (Forjaz) o Jandi (Orgrimmar).",
                materials = {
                    { id = 8838,  name = "Soleada", count = 50, source = "Zonas 40-52 (Habilidad 230+)", zone = "Feralas / Tierras del Interior / Tanaris" },
                    { id = 8839,  name = "Flor ciega", count = 40, source = "Zonas pantanosas (Habilidad 235+)", zone = "Pantano de las Penas" },
                    { id = 13463, name = "Hoja de ensueño", count = 50, source = "Zonas 50-60 (Habilidad 270+)", zone = "Felwood / Silithus / Tierras de la Peste" },
                    { id = 13466, name = "Flor de peste", count = 50, source = "Tierras de la Peste (Habilidad 285+)", zone = "Tierras de la Peste del Este y Oeste" },
                    { id = 13467, name = "Silbavellosa", count = 40, source = "Montañas de nivel 55+ (Habilidad 280+)", zone = "Cuna del Invierno / Silithus" },
                    { id = 13468, name = "Loto negro", count = 5, source = "Generación rara en zonas 55+", zone = "Cuna del Invierno / Peste Este / Silithus / Estepas" },
                },
                recipes = {
                    { range = "225 - 245", name = "Soleada y Flor ciega", mats = "Habilidad 230-235", tip = "Feralas y Pantano de las Penas." },
                    { range = "245 - 275", name = "Seta fantasma y Gromsblood", mats = "Habilidad 245-250", tip = "Tierras del Interior y Franja de Felwood." },
                    { range = "275 - 300", name = "Hoja de ensueño y Flor de peste", mats = "Habilidad 270-285", tip = "Tierras de la Peste del Este y Cuna del Invierno." },
                },
                farmingRoute = {
                    title = "Ruta de Hierbas de Banda (Felwood / Peste)",
                    zoneName = "Felwood",
                    uiMapID = 1448,
                    steps = {
                        { x = 40.0, y = 70.0, title = "1. Bosque de la Corrupción", instruction = "Gromsblood y Hoja de ensueño." },
                        { x = 45.0, y = 30.0, title = "2. Cañada de Jaedenar", instruction = "Silbavellosa en las cornisas altas." },
                    }
                }
            }
        }
    },

    -- ---------------------------------------------------------------------
    -- 5. MINERÍA (MINING)
    -- ---------------------------------------------------------------------
    ["Mining"] = {
        key = "Mining",
        name = "Minería",
        category = "Recolección",
        icon = "Interface\\Icons\\trade_mining",
        guideUrl = "https://www.wow-professions.com/classic/mining-leveling-guide",
        partnerProf = "Blacksmithing",
        partnerProfName = "Herrería / Ingeniería",
        summary = "Extrae menas de cobre, estaño, hierro, mitril y torio de las vetas de roca.",
        trainers = {
            alliance = "Gelman Stonehand (Ventormenta), Geofram Bouldertoe (Forjaz), Brock Stoneseeker (Loch Modan).",
            horde = "Makaru (Orgrimmar), Brom Killian (Entrañas), Brek Caminapiedra (Cima del Trueno)."
        },
        brackets = {
            ["1-75"] = {
                key = "1-75",
                name = "1 - 75 · Aprendiz",
                skillRange = "1 - 75",
                minSkill = 1,
                maxSkill = 75,
                reqLevel = 1,
                trainerTip = "Compra un Pico de minero en el intendente de suministros y equípalo en tus bolsas.",
                materials = {
                    { id = 2770, name = "Mena de cobre", count = 100, source = "Filones de cobre en zonas 1-12", zone = "Elwynn / Dun Morogh / Durotar / Mulgore" },
                    { id = 2835, name = "Piedra tosca", count = 60, source = "Subproducto de picar cobre", zone = "Zonas de inicio" },
                },
                recipes = {
                    { range = "1 - 65",  name = "Picar Filones de Cobre", mats = "Filones de cobre", tip = "Bordea las paredes rocosas y cuevas de tu zona natal." },
                    { range = "65 - 75", name = "Fundir Barra de cobre", mats = "1x Mena de cobre", tip = "Funde en la forja de la ciudad para subir los últimos 10 puntos al instante." },
                },
                farmingRoute = {
                    title = "Circuito de Cobre (Bosque de Elwynn)",
                    zoneName = "Bosque de Elwynn",
                    uiMapID = 1429,
                    steps = {
                        { x = 42.0, y = 70.0, title = "1. Mina Cerrohojalata", instruction = "Pica los filones de cobre dentro y fuera de la mina." },
                        { x = 60.0, y = 50.0, title = "2. Mina Jaspe", instruction = "Recorre la pared rocosa exterior de la cantera." },
                    }
                }
            },
            ["75-150"] = {
                key = "75-150",
                name = "75 - 150 · Oficial",
                skillRange = "75 - 150",
                minSkill = 75,
                maxSkill = 150,
                reqLevel = 10,
                trainerTip = "Aprende Oficial al llegar a 50 en cualquier capital.",
                materials = {
                    { id = 2771, name = "Mena de estaño", count = 80, source = "Filones de estaño en zonas 15-28", zone = "Los Baldíos / Páramos / Crestagrana / Loch Modan" },
                    { id = 2775, name = "Mena de plata", count = 20, source = "Filones raros en zonas 15-30", zone = "Los Baldíos / Crestagrana / Trabalomas" },
                    { id = 2841, name = "Barra de bronce", count = 80, source = "Fundir 1x Cobre + 1x Estaño", zone = "Forjas de capitales" },
                },
                recipes = {
                    { range = "75 - 115",  name = "Picar Estaño y Plata", mats = "Filones de estaño y plata", tip = "Páramos de Poniente y Los Baldíos ofrecen una enorme densidad." },
                    { range = "115 - 125", name = "Fundir Barra de bronce", mats = "1x Cobre, 1x Estaño", tip = "La fundición sube puntos de manera garantizada hasta 125." },
                    { range = "125 - 150", name = "Filones de Hierro", mats = "Filones de hierro (Habilidad 125+)", tip = "Empieza a picar los primeros filones de hierro en Trabalomas y Arathi." },
                },
                farmingRoute = {
                    title = "Circuito de Estaño (Páramos de Poniente)",
                    zoneName = "Páramos de Poniente",
                    uiMapID = 1436,
                    steps = {
                        { x = 32.0, y = 45.0, title = "1. Costa de las Rocas", instruction = "Filones de estaño a lo largo de las peñas costeras." },
                        { x = 45.0, y = 70.0, title = "2. Cañón de Moonbrook", instruction = "Estaño abundante rodeando la entrada a las minas." },
                    }
                }
            },
            ["150-225"] = {
                key = "150-225",
                name = "150 - 225 · Experto",
                skillRange = "150 - 225",
                minSkill = 150,
                maxSkill = 225,
                reqLevel = 20,
                trainerTip = "Aprende Experto al alcanzar nivel 20 y habilidad 125.",
                materials = {
                    { id = 2772, name = "Mena de hierro", count = 120, source = "Filones de hierro en zonas 28-40", zone = "Laderas de Trabalomas / Arathi / Mil Agujas" },
                    { id = 2776, name = "Mena de oro", count = 20, source = "Filones raros en zonas 30-45", zone = "Tierras Inhóspitas / Arathi / Desolace" },
                    { id = 3858, name = "Mena de mitril", count = 60, source = "Filones de mitril en zonas 40-50", zone = "Tierras Inhóspitas / Tanaris / Tierras del Interior" },
                },
                recipes = {
                    { range = "150 - 175", name = "Filones de Hierro", mats = "Filones de hierro", tip = "Trabalomas y Tierras Altas de Arathi." },
                    { range = "175 - 200", name = "Filones de Mitril", mats = "Filones de mitril (Habilidad 175+)", tip = "Tierras Inhóspitas: rodea la pared montañosa completa de la zona." },
                    { range = "200 - 225", name = "Fundir Barra de mitril", mats = "1x Mena de mitril", tip = "Funde en la forja para alcanzar el corte de Artesano cómodamente." },
                },
                farmingRoute = {
                    title = "Circuito de Mitril (Tierras Inhóspitas)",
                    zoneName = "Tierras Inhóspitas",
                    uiMapID = 1418,
                    steps = {
                        { x = 25.0, y = 45.0, title = "1. Cañón Occidental", instruction = "Filones de hierro y oro en las paredes rocosas." },
                        { x = 65.0, y = 55.0, title = "2. Valle de los Dragones", instruction = "Gran concentración de filones de mitril." },
                    }
                }
            },
            ["225-300"] = {
                key = "225-300",
                name = "225 - 300 · Artesano",
                skillRange = "225 - 300",
                minSkill = 225,
                maxSkill = 300,
                reqLevel = 35,
                trainerTip = "Aprende Artesano con Gelman Stonehand (Ventormenta) o Brom Killian (Entrañas).",
                materials = {
                    { id = 3858,  name = "Mena de mitril", count = 100, source = "Filones de mitril en zonas 40-50", zone = "Tanaris / Tierras del Interior / Feralas" },
                    { id = 10620, name = "Mena de torio", count = 200, source = "Filones de torio pequeño y rico", zone = "Cráter de Un'Goro / Cuna del Invierno / Silithus" },
                    { id = 7911,  name = "Mena de veraplata", count = 20, source = "Filones raros en zonas 40-55", zone = "Tanaris / Cráter de Un'Goro" },
                    { id = 12365, name = "Piedra densa", count = 40, source = "Subproducto de picar torio", zone = "Zonas de nivel 50+" },
                },
                recipes = {
                    { range = "225 - 245", name = "Filones de Mitril y Veraplata", mats = "Mitril y Veraplata", tip = "Tanaris y Tierras del Interior." },
                    { range = "245 - 275", name = "Filones de Torio Pequeño", mats = "Torio pequeño (Habilidad 245+)", tip = "Cráter de Un'Goro y Franja de Felwood." },
                    { range = "275 - 300", name = "Filones de Torio Rico", mats = "Torio rico (Habilidad 275+)", tip = "Cuna del Invierno, Silithus y Tierras de la Peste del Este." },
                },
                farmingRoute = {
                    title = "Circuito de Torio Rico (Cuna del Invierno)",
                    zoneName = "Cuna del Invierno",
                    uiMapID = 1452,
                    steps = {
                        { x = 60.0, y = 40.0, title = "1. Garganta de las Quimeras", instruction = "Torio pequeño y rico en los bordes helados." },
                        { x = 68.0, y = 70.0, title = "2. Aldea de los Yetis", instruction = "Cuevas con densa presencia de vetas de torio rico." },
                    }
                }
            }
        }
    },

    -- ---------------------------------------------------------------------
    -- 6. HERRERÍA (BLACKSMITHING)
    -- ---------------------------------------------------------------------
    ["Blacksmithing"] = {
        key = "Blacksmithing",
        name = "Herrería",
        category = "Fabricación",
        icon = "Interface\\Icons\\trade_blacksmithing",
        guideUrl = "https://www.wow-professions.com/forever/blacksmithing-leveling-guide",
        partnerProf = "Mining",
        partnerProfName = "Minería",
        summary = "Forja armaduras de placas y cotas de malla, armas legendarias y piedras de afilar.",
        trainers = {
            alliance = "Therum Deepforge (Ventormenta), Bengus Deepforge (Forjaz), Brikk Keencraft (Booty Bay - Artesano).",
            horde = "Sarut Steelfury (Orgrimmar), James Van Brunt (Entrañas), Brikk Keencraft (Booty Bay - Artesano)."
        },
        brackets = {
            ["1-75"] = {
                key = "1-75",
                name = "1 - 75 · Aprendiz",
                skillRange = "1 - 75",
                minSkill = 1,
                maxSkill = 75,
                reqLevel = 1,
                trainerTip = "Necesitas equipar un Martillo de herrero en tus bolsas para forjar.",
                materials = {
                    { id = 2835, name = "Piedra tosca", count = 130, source = "Filones de cobre / Subasta", zone = "Zonas de inicio" },
                    { id = 2840, name = "Barra de cobre", count = 150, source = "Fundir mineral de cobre", zone = "Capitales" },
                    { id = 2836, name = "Piedra burda", count = 5, source = "Filones de estaño", zone = "Zonas 15-25" },
                },
                recipes = {
                    { range = "1 - 25",  name = "Piedra de afilar tosca (x25)", mats = "1x Piedra tosca", tip = "La receta más barata de todo el juego." },
                    { range = "25 - 65", name = "Piedra de contrapeso tosca (x40)", mats = "1x Piedra tosca, 1x Paño de lino", tip = "Sube hasta 65 usando piedras toscas sobrantes." },
                    { range = "65 - 75", name = "Brazales de cobre refinados (x10)", mats = "2x Barra de cobre", tip = "Requiere barras de cobre y fundición." },
                },
                farmingRoute = {
                    title = "Farmeo de Cobre y Piedra Tosca",
                    zoneName = "Dun Morogh / Durotar",
                    uiMapID = 1426,
                    steps = {
                        { x = 50.0, y = 45.0, title = "1. Cantera de Gol'Bolar", instruction = "Pica todas las vetas de cobre." },
                    }
                }
            },
            ["75-150"] = {
                key = "75-150",
                name = "75 - 150 · Oficial",
                skillRange = "75 - 150",
                minSkill = 75,
                maxSkill = 150,
                reqLevel = 10,
                trainerTip = "Aprende Oficial con Bengus Deepforge (Forjaz) o Sarut Steelfury (Orgrimmar).",
                materials = {
                    { id = 2836, name = "Piedra burda", count = 120, source = "Filones de estaño", zone = "Páramos / Los Baldíos" },
                    { id = 2842, name = "Barra de plata", count = 5, source = "Fundir plata", zone = "Subasta / Minería" },
                    { id = 2841, name = "Barra de bronce", count = 150, source = "Fundir 1x Cobre + 1x Estaño", zone = "Capitales" },
                    { id = 2838, name = "Piedra pesada", count = 30, source = "Filones de hierro", zone = "Trabalomas / Arathi" },
                },
                recipes = {
                    { range = "75 - 90",   name = "Piedra de afilar burda (x15)", mats = "1x Piedra burda", tip = "Gasta las piedras burdas acumuladas." },
                    { range = "90 - 100",  name = "Varilla de plata (x10)", mats = "1x Barra de plata, 2x Piedra burda", tip = "Excelente venta a encantadores." },
                    { range = "100 - 125", name = "Brazales de bronce refinados (x25)", mats = "5x Barra de bronce, 2x Piedra burda", tip = "Receta clave del tramo intermedio de bronce." },
                    { range = "125 - 150", name = "Piedra de afilar pesada (x25)", mats = "1x Piedra pesada", tip = "Sube 25 puntos de habilidad casi regalados." },
                },
                farmingRoute = {
                    title = "Farmeo de Estaño y Bronce",
                    zoneName = "Los Baldíos",
                    uiMapID = 1413,
                    steps = {
                        { x = 45.0, y = 40.0, title = "1. Cordillera Este", instruction = "Estaño en abundancia en las colinas." },
                    }
                }
            },
            ["150-225"] = {
                key = "150-225",
                name = "150 - 225 · Experto",
                skillRange = "150 - 225",
                minSkill = 150,
                maxSkill = 225,
                reqLevel = 20,
                trainerTip = "Aprende Experto al llegar a nivel 20 y habilidad 125.",
                materials = {
                    { id = 2838,  name = "Piedra pesada", count = 100, source = "Filones de hierro", zone = "Trabalomas / Arathi" },
                    { id = 3575,  name = "Barra de hierro", count = 150, source = "Fundir mena de hierro", zone = "Capitales" },
                    { id = 2324,  name = "Tinte verde", count = 20, isVendor = true, source = "Vendedores de sastrería", zone = "Capitales" },
                    { id = 3859,  name = "Barra de acero", count = 80, source = "Fundir 1x Hierro + 1x Carbón", zone = "Forjas" },
                    { id = 7912,  name = "Piedra sólida", count = 120, source = "Filones de mitril", zone = "Badlands / Tanaris" },
                    { id = 3860,  name = "Barra de mitril", count = 110, source = "Fundir mineral de mitril", zone = "Capitales" },
                },
                recipes = {
                    { range = "150 - 155", name = "Varilla dorada (x5)", mats = "1x Barra de oro, 2x Piedra pesada", tip = "Vende estas varillas a los encantadores del reino." },
                    { range = "155 - 165", name = "Grebas de hierro verdes (x10)", mats = "8x Barra de hierro, 1x Piedra pesada, 1x Tinte verde", tip = "Pieza con gran valor de desencanto." },
                    { range = "165 - 190", name = "Brazales de hierro verdes (x25)", mats = "6x Barra de hierro, 1x Tinte verde", tip = "La receta más eficiente en consumo de hierro." },
                    { range = "190 - 200", name = "Brazales de escamas doradas (x10)", mats = "5x Barra de acero, 2x Piedra pesada", tip = "Consumo moderado de barras de acero." },
                    { range = "200 - 210", name = "Piedra de afilar sólida (x10)", mats = "1x Piedra sólida", tip = "Gasta piedras sólidas para subir 10 puntos de golpe." },
                    { range = "210 - 225", name = "Guanteletes de placas pesados (x15)", mats = "6x Barra de mitril, 4x Paño de tejido mágico", tip = "Te introduce en la era de mitril." },
                },
                farmingRoute = {
                    title = "Farmeo de Hierro y Piedra Sólida",
                    zoneName = "Tierras Altas de Arathi",
                    uiMapID = 1417,
                    steps = {
                        { x = 50.0, y = 50.0, title = "1. Minas de Arathi", instruction = "Hierro y carbón en las colinas." },
                    }
                }
            },
            ["225-300"] = {
                key = "225-300",
                name = "225 - 300 · Artesano",
                skillRange = "225 - 300",
                minSkill = 225,
                maxSkill = 300,
                reqLevel = 35,
                trainerTip = "Aprende Artesano exclusivamente con Brikk Keencraft en Bahía del Botín (Vega de Tuercespina). Requiere nivel 35 y habilidad 200.",
                materials = {
                    { id = 3860,  name = "Barra de mitril", count = 120, source = "Fundir mineral de mitril", zone = "Tierras Inhóspitas / Tanaris" },
                    { id = 12365, name = "Piedra densa", count = 20, source = "Filones de torio", zone = "Un'Goro / Cuna del Invierno" },
                    { id = 12359, name = "Barra de torio", count = 420, source = "Fundir mineral de torio", zone = "Capitales" },
                    { id = 7909,  name = "Rubí estrella", count = 4, source = "Drop en filones de torio y mitril", zone = "Subasta / Minería" },
                },
                recipes = {
                    { range = "225 - 235", name = "Brazales de escamas de mitril (x10)", mats = "8x Barra de mitril", tip = "Termina las barras de mitril que tengas." },
                    { range = "235 - 250", name = "Botas de mitril pesadas (x15)", mats = "14x Barra de mitril", tip = "Último escalón antes de pasar a torio." },
                    { range = "250 - 260", name = "Piedra de afilar densa (x15)", mats = "1x Piedra densa", tip = "Sube 10 puntos de manera prácticamente gratuita." },
                    { range = "260 - 275", name = "Brazales de torio imperiales (x15)", mats = "12x Barra de torio", tip = "Patrón vendido por Derotain en Gadgetzan." },
                    { range = "275 - 290", name = "Yelmo de torio imperial (x15)", mats = "16x Barra de torio", tip = "Aprende mediante la misión de armadura imperial." },
                    { range = "290 - 300", name = "Botas de torio pesadas (x10)", mats = "20x Barra de torio", tip = "Te corona en nivel 300 de herrería." },
                },
                farmingRoute = {
                    title = "Farmeo de Torio Rico",
                    zoneName = "Cuna del Invierno / Silithus",
                    uiMapID = 1452,
                    steps = {
                        { x = 60.0, y = 35.0, title = "1. Garganta de las Quimeras", instruction = "Nodos de torio en la pared montañosa." },
                    }
                }
            }
        }
    },

    -- ---------------------------------------------------------------------
    -- 7. INGENIERÍA (ENGINEERING)
    -- ---------------------------------------------------------------------
    ["Engineering"] = {
        key = "Engineering",
        name = "Ingeniería",
        category = "Fabricación",
        icon = "Interface\\Icons\\trade_engineering",
        guideUrl = "https://www.wow-professions.com/forever/engineering-leveling-guide",
        partnerProf = "Mining",
        partnerProfName = "Minería",
        summary = "Crea bombas, gafas, artilugios y teletransportadores BiS para PvP y bandas.",
        trainers = {
            alliance = "Lilliam Sparkspindle (Ventormenta), Trixie Shatterfix (Forjaz), Buzzek Bracketswing (Tanaris - Artesano).",
            horde = "Thund (Orgrimmar), Graham Van Talen (Entrañas), Buzzek Bracketswing (Tanaris - Artesano)."
        },
        brackets = {
            ["1-75"] = {
                key = "1-75",
                name = "1 - 75 · Aprendiz",
                skillRange = "1 - 75",
                minSkill = 1,
                maxSkill = 75,
                reqLevel = 1,
                trainerTip = "Aprende con cualquier instructor en las ciudades principales.",
                materials = {
                    { id = 2835, name = "Piedra tosca", count = 60, source = "Filones de cobre / Subasta", zone = "Zonas de inicio" },
                    { id = 2840, name = "Barra de cobre", count = 66, source = "Fundir mineral de cobre", zone = "Capitales" },
                    { id = 2589, name = "Paño de lino", count = 50, source = "Humanoides nivel 5-15", zone = "Páramos / Los Baldíos" },
                },
                recipes = {
                    { range = "1 - 30",  name = "Pólvora tosca (x60)", mats = "1x Piedra tosca", tip = "¡Guarda toda la pólvora! La usarás para crear bombas más adelante." },
                    { range = "30 - 50", name = "Puñado de pernos de cobre (x30)", mats = "1x Barra de cobre", tip = "Guarda también los pernos para las siguientes recetas." },
                    { range = "50 - 51", name = "Llave de tuercas arcoluz (x1)", mats = "6x Barra de cobre", tip = "¡Herramienta permanente! Consérvala siempre en tus bolsas." },
                    { range = "51 - 75", name = "Bomba de cobre tosca (x30)", mats = "1x Barra de cobre, 1x Pernos de cobre, 2x Pólvora tosca, 1x Paño de lino", tip = "Excelente recurso de aturdimiento en área para leveleo." },
                },
                farmingRoute = {
                    title = "Farmeo de Cobre y Lino",
                    zoneName = "Bosque de Elwynn / Durotar",
                    uiMapID = 1429,
                    steps = {
                        { x = 40.0, y = 65.0, title = "1. Mina Cerrohojalata", instruction = "Cobre y piedra tosca de los filones." },
                        { x = 50.0, y = 40.0, title = "2. Campamento Defias", instruction = "Lino en los bandidos humanoides." },
                    }
                }
            },
            ["75-150"] = {
                key = "75-150",
                name = "75 - 150 · Oficial",
                skillRange = "75 - 150",
                minSkill = 75,
                maxSkill = 150,
                reqLevel = 10,
                trainerTip = "Aprende Oficial al llegar a 50 con cualquier instructor.",
                materials = {
                    { id = 2836, name = "Piedra burda", count = 60, source = "Filones de estaño", zone = "Páramos / Los Baldíos" },
                    { id = 2842, name = "Barra de plata", count = 5, source = "Fundir mineral de plata", zone = "Subasta / Minería" },
                    { id = 2841, name = "Barra de bronce", count = 110, source = "Fundir cobre y estaño", zone = "Capitales" },
                    { id = 2880, name = "Fundente débil", count = 25, isVendor = true, source = "Vendedores de ingeniería", zone = "Capitales" },
                    { id = 1206, name = "Ágata de musgo", count = 10, source = "Filones de estaño y hierro / Subasta", zone = "Trabalomas / Arathi" },
                    { id = 2838, name = "Piedra pesada", count = 30, source = "Filones de hierro", zone = "Trabalomas / Arathi" },
                    { id = 2592, name = "Paño de lana", count = 60, source = "Humanoides nivel 18-30", zone = "Trabalomas / Minas de la Muerte" },
                },
                recipes = {
                    { range = "75 - 90",   name = "Pólvora burda (x60)", mats = "1x Piedra burda", tip = "Guarda la pólvora para las bombas." },
                    { range = "90 - 100",  name = "Contacto de plata (x5)", mats = "1x Barra de plata", tip = "Requisito para muchas recetas avanzadas." },
                    { range = "100 - 105", name = "Ganzúa de práctica (x5)", mats = "1x Barra de bronce, 2x Fundente débil", tip = "Económica para ganar 5 puntos." },
                    { range = "105 - 120", name = "Gafas de tigre volador (x15)", mats = "6x Barra de bronce, 2x Paño de lana", tip = "Gafas útiles de cabeza." },
                    { range = "120 - 125", name = "Tubo de bronce (x5)", mats = "2x Barra de bronce, 1x Fundente débil", tip = "Aprende del instructor." },
                    { range = "125 - 150", name = "Pólvora pesada (x30)", mats = "1x Piedra pesada", tip = "Sube 25 puntos con piedras pesadas." },
                },
                farmingRoute = {
                    title = "Farmeo de Estaño y Lana",
                    zoneName = "Páramos de Poniente / Humedales",
                    uiMapID = 1436,
                    steps = {
                        { x = 45.0, y = 60.0, title = "1. Costa de Moonbrook", instruction = "Estaño en las colinas." },
                        { x = 55.0, y = 30.0, title = "2. Minas de la Muerte", instruction = "Paño de lana de los Defias." },
                    }
                }
            },
            ["150-225"] = {
                key = "150-225",
                name = "150 - 225 · Experto",
                skillRange = "150 - 225",
                minSkill = 150,
                maxSkill = 225,
                reqLevel = 20,
                trainerTip = "Aprende Experto al alcanzar nivel 20 y habilidad 125.",
                materials = {
                    { id = 3859, name = "Barra de acero", count = 4, source = "Fundir hierro + carbón", zone = "Capitales" },
                    { id = 7912, name = "Piedra sólida", count = 120, source = "Filones de mitril", zone = "Badlands / Tanaris" },
                    { id = 3860, name = "Barra de mitril", count = 74, source = "Fundir mena de mitril", zone = "Capitales" },
                    { id = 4338, name = "Paño de tejido mágico", count = 20, source = "Humanoides nivel 40-52", zone = "Tanaris / Zul'Farrak" },
                    { id = 4306, name = "Paño de seda", count = 20, source = "Humanoides nivel 28-40", zone = "Monasterio Escarlata" },
                    { id = 3575, name = "Barra de hierro", count = 20, source = "Fundir mena de hierro", zone = "Capitales" },
                },
                recipes = {
                    { range = "150 - 160", name = "Bomba de bronce pesada (x10)", mats = "2x Pólvora pesada, 3x Barra de bronce, 1x Lana", tip = "Termina los materiales de bronce." },
                    { range = "160 - 175", name = "Artilugio de bronce zumbante (x15)", mats = "2x Barra de bronce, 1x Lana", tip = "Consérvalos para recetas futuras." },
                    { range = "175 - 200", name = "Granada de hierro (x25)", mats = "1x Barra de hierro, 1x Pólvora pesada, 1x Seda", tip = "¡La granada PvP más famosa y eficiente del juego!" },
                    { range = "200 - 215", name = "Pólvora sólida (x20)", mats = "2x Piedra sólida", tip = "Guarda la pólvora sólida para el tramo 225." },
                    { range = "215 - 225", name = "Detonador inestable (x10)", mats = "1x Barra de mitril, 1x Paño de tejido mágico, 1x Pólvora sólida", tip = "Te corona en el rango Artesano." },
                },
                farmingRoute = {
                    title = "Farmeo de Hierro y Piedra Sólida",
                    zoneName = "Tierras Inhóspitas",
                    uiMapID = 1418,
                    steps = {
                        { x = 30.0, y = 45.0, title = "1. Valle Pedregoso", instruction = "Hierro y piedra sólida de los filones." },
                    }
                }
            },
            ["225-300"] = {
                key = "225-300",
                name = "225 - 300 · Artesano",
                skillRange = "225 - 300",
                minSkill = 225,
                maxSkill = 300,
                reqLevel = 35,
                trainerTip = "Aprende Artesano con Buzzek Bracketswing en Gadgetzan (Tanaris). Requiere nivel 35 y habilidad 200.",
                materials = {
                    { id = 3860,  name = "Barra de mitril", count = 84, source = "Fundir mineral de mitril", zone = "Tanaris / Badlands" },
                    { id = 12365, name = "Piedra densa", count = 60, source = "Filones de torio", zone = "Un'Goro / Cuna del Invierno" },
                    { id = 12359, name = "Barra de torio", count = 130, source = "Fundir mineral de torio", zone = "Capitales" },
                    { id = 14047, name = "Paño rúnico", count = 30, source = "Humanoides nivel 50-60", zone = "Tierras de la Peste / Silithus" },
                },
                recipes = {
                    { range = "225 - 235", name = "Carcasa de mitril (x10)", mats = "3x Barra de mitril", tip = "Consérvalas para crear bombas de alta potencia." },
                    { range = "235 - 250", name = "Bomba de alto explosivo (x15)", mats = "2x Carcasa de mitril, 1x Detonador inestable, 2x Pólvora sólida", tip = "Excelente daño y aturdimiento para bandas." },
                    { range = "250 - 260", name = "Pólvora densa (x20)", mats = "2x Piedra densa", tip = "Receta muy barata de subida." },
                    { range = "260 - 285", name = "Artilugio de torio (x25)", mats = "3x Barra de torio, 1x Paño rúnico", tip = "Subida directa y limpia con torio." },
                    { range = "285 - 300", name = "Granada de torio (x15)", mats = "2x Barra de torio, 1x Pólvora densa, 1x Paño rúnico", tip = "Granada BiS para incursiones y batallas de banda." },
                },
                farmingRoute = {
                    title = "Farmeo de Torio y Paño Rúnico",
                    zoneName = "Cráter de Un'Goro / Silithus",
                    uiMapID = 1449,
                    steps = {
                        { x = 50.0, y = 40.0, title = "1. Paredes de Un'Goro", instruction = "Vetas de torio rico alrededor del borde del cráter." },
                        { x = 70.0, y = 45.0, title = "2. Campamento Crepuscular", instruction = "Paño rúnico de los cultores." },
                    }
                }
            }
        }
    },

    -- ---------------------------------------------------------------------
    -- 8. SASTRERÍA (TAILORING)
    -- ---------------------------------------------------------------------
    ["Tailoring"] = {
        key = "Tailoring",
        name = "Sastrería",
        category = "Fabricación",
        icon = "Interface\\Icons\\trade_tailoring",
        guideUrl = "https://www.wow-professions.com/forever/tailoring-leveling-guide",
        partnerProf = "Enchanting",
        partnerProfName = "Encantamiento",
        summary = "Teje armaduras de tela, capas, camisas y las vitales bolsas de 6 a 16 casillas.",
        trainers = {
            alliance = "Lawrence Schneider (Ventormenta), Jannos Ironwill (Forjaz), Timothy Worthington (Polvocegante - Artesano).",
            horde = "Magar (Orgrimmar), Victor Ward (Entrañas), Daryl Stack (Laderas de Trabalomas - Artesano)."
        },
        brackets = {
            ["1-75"] = {
                key = "1-75",
                name = "1 - 75 · Aprendiz",
                skillRange = "1 - 75",
                minSkill = 1,
                maxSkill = 75,
                reqLevel = 1,
                trainerTip = "No necesitas herramientas especiales; solo paño e hilos.",
                materials = {
                    { id = 2589, name = "Paño de lino", count = 160, source = "Humanoides nivel 1-15", zone = "Elwynn / Dun Morogh / Durotar / Páramos" },
                    { id = 2320, name = "Hilo burdo", count = 40, isVendor = true, source = "Vendedores de sastrería", zone = "Capitales" },
                    { id = 2605, name = "Tinte rojo", count = 20, isVendor = true, source = "Vendedores de sastrería", zone = "Capitales" },
                },
                recipes = {
                    { range = "1 - 45",  name = "Madeja de paño de lino (x80)", mats = "2x Paño de lino", tip = "¡Guarda todas las madejas! Las necesitarás para las siguientes prendas." },
                    { range = "45 - 70", name = "Guantes de lino pesados (x25)", mats = "2x Madeja de lino, 1x Hilo burdo", tip = "Receta óptima para subir a Oficial." },
                    { range = "70 - 75", name = "Camisa de lino roja (x5)", mats = "4x Madeja de lino, 1x Tinte rojo, 1x Hilo burdo", tip = "Camisa muy solicitada en el mercado." },
                },
                farmingRoute = {
                    title = "Farmeo de Paño de Lino",
                    zoneName = "Páramos de Poniente / Los Baldíos",
                    uiMapID = 1436,
                    steps = {
                        { x = 50.0, y = 35.0, title = "1. Granjas del Norte", instruction = "Humanoides bandidos Defias sueltan lino constantemente." },
                    }
                }
            },
            ["75-150"] = {
                key = "75-150",
                name = "75 - 150 · Oficial",
                skillRange = "75 - 150",
                minSkill = 75,
                maxSkill = 150,
                reqLevel = 10,
                trainerTip = "Aprende Oficial al llegar a 50 con cualquier instructor.",
                materials = {
                    { id = 2592, name = "Paño de lana", count = 180, source = "Humanoides nivel 18-30", zone = "Minas de la Muerte / Castillo Colmillo Oscuro / Trabalomas" },
                    { id = 2604, name = "Tinte gris", count = 20, isVendor = true, source = "Vendedores de sastrería", zone = "Capitales" },
                    { id = 2321, name = "Hilo fino", count = 40, isVendor = true, source = "Vendedores de sastrería", zone = "Capitales" },
                },
                recipes = {
                    { range = "75 - 105",  name = "Madeja de paño de lana (x60)", mats = "3x Paño de lana", tip = "Guarda las madejas de lana." },
                    { range = "105 - 120", name = "Camisa de lana gris (x15)", mats = "2x Madeja de lana, 1x Tinte gris, 1x Hilo fino", tip = "Sube 15 puntos directos." },
                    { range = "120 - 145", name = "Sobrehombros de lana de doble costura (x25)", mats = "3x Madeja de lana, 2x Hilo fino", tip = "Excelente pieza para desencantar o vender." },
                    { range = "145 - 150", name = "Madeja de paño de seda (x15)", mats = "4x Paño de seda", tip = "Convierte seda para entrar a Experto." },
                },
                farmingRoute = {
                    title = "Farmeo de Paño de Lana",
                    zoneName = "Laderas de Trabalomas",
                    uiMapID = 1424,
                    steps = {
                        { x = 35.0, y = 55.0, title = "1. Campos de Trabalomas", instruction = "Humanoides en las granjas y campamentos del Sindicato." },
                    }
                }
            },
            ["150-225"] = {
                key = "150-225",
                name = "150 - 225 · Experto",
                skillRange = "150 - 225",
                minSkill = 150,
                maxSkill = 225,
                reqLevel = 20,
                trainerTip = "Aprende Experto al llegar a nivel 20 y habilidad 125.",
                materials = {
                    { id = 4306, name = "Paño de seda", count = 500, source = "Humanoides nivel 28-40", zone = "Monasterio Escarlata / Mil Agujas" },
                    { id = 2325, name = "Lejía", count = 20, isVendor = true, source = "Vendedores de sastrería", zone = "Capitales" },
                    { id = 2606, name = "Tinte azul", count = 20, isVendor = true, source = "Vendedores de sastrería", zone = "Capitales" },
                    { id = 2321, name = "Hilo fino", count = 60, isVendor = true, source = "Vendedores de sastrería", zone = "Capitales" },
                    { id = 4338, name = "Paño de tejido mágico", count = 60, source = "Humanoides nivel 40-52", zone = "Zul'Farrak / Tanaris" },
                },
                recipes = {
                    { range = "150 - 160", name = "Madeja de paño de seda (x100)", mats = "4x Paño de seda", tip = "Crea madejas para los siguientes pasos." },
                    { range = "160 - 170", name = "Cinta de seda (x10)", mats = "3x Madeja de seda, 2x Hilo fino", tip = "Pieza barata de cabeza." },
                    { range = "170 - 175", name = "Camisa blanca formal (x5)", mats = "3x Madeja de seda, 2x Lejía, 1x Hilo fino", tip = "Camisa de vestir muy popular." },
                    { range = "175 - 185", name = "Madeja de paño de tejido mágico (x15)", mats = "4x Paño de tejido mágico", tip = "Comienza la transición a tejido mágico." },
                    { range = "185 - 200", name = "Jubón de seda carmesí (x15)", mats = "4x Madeja de seda, 2x Tinte rojo, 2x Hilo fino", tip = "Aprende del instructor." },
                    { range = "200 - 225", name = "Pantalones de seda carmesí (x25)", mats = "4x Madeja de seda, 2x Tinte rojo, 2x Hilo de seda", tip = "Te posiciona listo para el rango Artesano." },
                },
                farmingRoute = {
                    title = "Farmeo de Paño de Seda (Monasterio)",
                    zoneName = "Monasterio Escarlata",
                    uiMapID = 1420,
                    steps = {
                        { x = 40.0, y = 50.0, title = "1. Ala de Cementerio y Biblioteca", instruction = "La mayor densidad de paño de seda de todo Azeroth." },
                    }
                }
            },
            ["225-300"] = {
                key = "225-300",
                name = "225 - 300 · Artesano",
                skillRange = "225 - 300",
                minSkill = 225,
                maxSkill = 300,
                reqLevel = 35,
                trainerTip = "Aprende Artesano con Timothy Worthington (Marjal Revolcafango - Alianza) o Daryl Stack (Molino Tarren, Trabalomas - Horda). Requiere nivel 35 y habilidad 200.",
                materials = {
                    { id = 4338,  name = "Paño de tejido mágico", count = 400, source = "Humanoides nivel 40-52", zone = "Tanaris / Zul'Farrak / Feralas" },
                    { id = 4291,  name = "Hilo de seda", count = 60, isVendor = true, source = "Vendedores de sastrería", zone = "Capitales" },
                    { id = 14047, name = "Paño rúnico", count = 750, source = "Humanoides nivel 50-60", zone = "Tierras de la Peste / Silithus" },
                    { id = 14341, name = "Hilo rúnico", count = 50, isVendor = true, source = "Vendedores de sastrería", zone = "Capitales" },
                    { id = 8170,  name = "Cuero basto", count = 20, source = "Desuello bestias nivel 50+", zone = "Un'Goro / Cuna del Invierno" },
                },
                recipes = {
                    { range = "225 - 230", name = "Guantes de tejido mágico negros (x5)", mats = "2x Madeja de tejido mágico, 2x Hilo de seda", tip = "Aprende del instructor artesano." },
                    { range = "230 - 250", name = "Cinta de tejido mágico negra (x20)", mats = "3x Madeja de tejido mágico, 2x Hilo de seda", tip = "Receta clave y muy barata hasta 250." },
                    { range = "250 - 260", name = "Madeja de paño rúnico (x150)", mats = "5x Paño rúnico", tip = "Transforma tu paño rúnico acumulado." },
                    { range = "260 - 275", name = "Cinturón de paño rúnico (x15)", mats = "3x Madeja de paño rúnico, 1x Hilo rúnico", tip = "El cinturón más económico para subir." },
                    { range = "275 - 280", name = "Guantes de paño rúnico (x5)", mats = "4x Madeja de paño rúnico, 2x Cuero basto, 1x Hilo rúnico", tip = "Patrón vendido por Qia en Cuna del Invierno." },
                    { range = "280 - 300", name = "Cinta de paño rúnico (x20)", mats = "6x Madeja de paño rúnico, 2x Hilo rúnico", tip = "Patrón vendido por Qia en Cuna del Invierno. ¡Te lleva a 300!" },
                },
                farmingRoute = {
                    title = "Farmeo de Tejido Mágico y Paño Rúnico",
                    zoneName = "Zul'Farrak / Tierras de la Peste",
                    uiMapID = 1422,
                    steps = {
                        { x = 50.0, y = 50.0, title = "1. Zul'Farrak (Tanaris)", instruction = "Trolls en masa sueltan tejido mágico sin parar." },
                        { x = 45.0, y = 35.0, title = "2. Andorhal (Peste del Oeste)", instruction = "No-muertos humanoides sueltan Paño rúnico abundantemente." },
                    }
                }
            }
        }
    },

    -- ---------------------------------------------------------------------
    -- 9. ENCANTAMIENTO (ENCHANTING)
    -- ---------------------------------------------------------------------
    ["Enchanting"] = {
        key = "Enchanting",
        name = "Encantamiento",
        category = "Fabricación",
        icon = "Interface\\Icons\\trade_engraving",
        guideUrl = "https://www.wow-professions.com/forever/enchanting-leveling-guide",
        partnerProf = "Tailoring",
        partnerProfName = "Sastrería",
        summary = "Desencanta objetos mágicos para obtener polvos, esencias y esquirlas que potencian armas y armaduras.",
        trainers = {
            alliance = "Lucan Cordell (Ventormenta), Gimble Cardobobina (Forjaz), Kithas (Darnassus), Annora (Uldaman - Artesana).",
            horde = "Vance Bajoelárbol (Tirisfal), Tegashi (Orgrimmar), Malcomb Wynter (Entrañas), Annora (Uldaman - Artesana)."
        },
        brackets = {
            ["1-75"] = {
                key = "1-75",
                name = "1 - 75 · Aprendiz",
                skillRange = "1 - 75",
                minSkill = 1,
                maxSkill = 75,
                reqLevel = 1,
                trainerTip = "Aprende Desencantar y utiliza tu Vara de cobre con runas como catalizador.",
                materials = {
                    { id = 6217,  name = "Vara de cobre", count = 1, isVendor = true, source = "Vendedores de suministros de encantamiento", zone = "Capitales" },
                    { id = 10940, name = "Polvo extraño", count = 133, source = "Desencantar equipo verde nivel 5-15", zone = "Mazmorras iniciales / Subasta" },
                    { id = 10938, name = "Esencia mágica inferior", count = 4, source = "Desencantar equipo verde nivel 5-15", zone = "Mazmorras iniciales / Subasta" },
                },
                recipes = {
                    { range = "1 - 2",   name = "Vara de cobre con runas (x1)", mats = "1x Vara de cobre, 1x Polvo extraño, 1x Esencia mágica inferior", tip = "¡Herramienta permanente! Necesaria para todos los encantamientos iniciales." },
                    { range = "2 - 75",  name = "Encantar capa: desvío menor (x73)", mats = "1x Polvo extraño", tip = "La forma más económica de subir: solo 1 Polvo extraño por intento." },
                },
                farmingRoute = {
                    title = "Desencanto Inicial",
                    zoneName = "Minas de la Muerte / Cavernas de Brazanegra",
                    uiMapID = 1436,
                    steps = {
                        { x = 50.0, y = 50.0, title = "1. Objetos verdes nivel 5-15", instruction = "Desencanta todo el botín no ligable o fabricado con sastrería." },
                    }
                }
            },
            ["75-150"] = {
                key = "75-150",
                name = "75 - 150 · Oficial",
                skillRange = "75 - 150",
                minSkill = 75,
                maxSkill = 150,
                reqLevel = 10,
                trainerTip = "Aprende Oficial con Lucan Cordell (Ventormenta) o Tegashi (Orgrimmar).",
                materials = {
                    { id = 6338,  name = "Vara de plata", count = 1, source = "Herrería (fabricada por herreros) / Subasta", zone = "Capitales" },
                    { id = 1210,  name = "Gema de sombras", count = 1, source = "Filones de estaño / Subasta", zone = "Minería" },
                    { id = 10940, name = "Polvo extraño", count = 20, source = "Desencantar equipo nivel 15-20", zone = "Subasta" },
                    { id = 10998, name = "Esencia astral inferior", count = 20, source = "Desencantar equipo nivel 15-25", zone = "Subasta" },
                    { id = 11083, name = "Polvo de alma", count = 57, source = "Desencantar equipo nivel 21-30", zone = "Subasta" },
                },
                recipes = {
                    { range = "75 - 80",   name = "Vara de plata con runas (x1)", mats = "1x Vara de plata, 1x Gema de sombras, 3x Esencia mágica superior, 6x Polvo extraño", tip = "Vara requerida para encantar equipo de mayor nivel." },
                    { range = "80 - 100",  name = "Encantar brazales: agilidad menor (x20)", mats = "2x Esencia astral inferior", tip = "Sube 20 puntos con esencias astrales." },
                    { range = "100 - 110", name = "Encantar pechera: salud superior (x10)", mats = "3x Polvo extraño", tip = "Aprovecha el polvo extraño restante." },
                    { range = "110 - 135", name = "Encantar capa: agilidad menor (x25)", mats = "1x Esencia astral inferior", tip = "Muy económica." },
                    { range = "135 - 150", name = "Encantar brazales: fortaleza inferior (x15)", mats = "2x Polvo de alma", tip = "Te introduce al uso de Polvo de alma." },
                },
                farmingRoute = {
                    title = "Desencanto Oficial",
                    zoneName = "Castillo Colmillo Oscuro / Gnomeregan",
                    uiMapID = 1421,
                    steps = {
                        { x = 45.0, y = 50.0, title = "1. Botín mágico nivel 16-28", instruction = "Desencanta para acumular Polvo de alma y Esencias astrales." },
                    }
                }
            },
            ["150-225"] = {
                key = "150-225",
                name = "150 - 225 · Experto",
                skillRange = "150 - 225",
                minSkill = 150,
                maxSkill = 225,
                reqLevel = 20,
                trainerTip = "Aprende Experto al llegar a nivel 20 y habilidad 125.",
                materials = {
                    { id = 11128, name = "Vara de oro", count = 1, source = "Herrería / Subasta", zone = "Capitales" },
                    { id = 5500,  name = "Perla iridiscente", count = 1, source = "Almejas de zonas costeras / Subasta", zone = "Costas" },
                    { id = 11082, name = "Esencia astral superior", count = 1, source = "Desencantar equipo nivel 25-30", zone = "Subasta" },
                    { id = 11083, name = "Polvo de alma", count = 22, source = "Desencantar equipo nivel 21-30", zone = "Subasta" },
                    { id = 11137, name = "Polvo de visión", count = 56, source = "Desencantar equipo nivel 31-40", zone = "Monasterio Escarlata" },
                    { id = 11134, name = "Esencia mística inferior", count = 15, source = "Desencantar equipo nivel 30-40", zone = "Subasta" },
                },
                recipes = {
                    { range = "150 - 155", name = "Vara de oro con runas (x1)", mats = "1x Vara de oro, 1x Perla iridiscente, 2x Esencia astral superior, 2x Polvo de alma", tip = "Nueva vara de encantamiento de nivel experto." },
                    { range = "155 - 165", name = "Encantar brazales: fortaleza inferior (x10)", mats = "2x Polvo de alma", tip = "Termina el polvo de alma." },
                    { range = "165 - 180", name = "Encantar brazales: espíritu (x15)", mats = "1x Esencia astral inferior", tip = "Sube rápido y con mínimo gasto." },
                    { range = "180 - 200", name = "Encantar brazales: fuerza (x20)", mats = "1x Polvo de visión", tip = "Excelente receta: solo 1 Polvo de visión por punto." },
                    { range = "200 - 225", name = "Encantar brazales: fortaleza superior (x25)", mats = "2x Polvo de visión", tip = "Te prepara para el rango artesano en Uldaman." },
                },
                farmingRoute = {
                    title = "Desencanto Experto (Monasterio)",
                    zoneName = "Monasterio Escarlata",
                    uiMapID = 1420,
                    steps = {
                        { x = 50.0, y = 50.0, title = "1. Mazmorra Monasterio Escarlata", instruction = "Gran afluencia de objetos verdes nivel 30-40 para Polvo de visión." },
                    }
                }
            },
            ["225-300"] = {
                key = "225-300",
                name = "225 - 300 · Artesano",
                skillRange = "225 - 300",
                minSkill = 225,
                maxSkill = 300,
                reqLevel = 35,
                trainerTip = "Aprende Artesano EXCLUSIVAMENTE con Annora en el interior de la mazmorra de Uldaman. Requiere nivel 35 y habilidad 200.",
                materials = {
                    { id = 11144, name = "Vara de veraplata", count = 1, source = "Herrería / Subasta", zone = "Capitales" },
                    { id = 7971,  name = "Perla negra", count = 1, source = "Almejas de nivel 40+ / Subasta", zone = "Tanaris" },
                    { id = 11135, name = "Esencia mística superior", count = 2, source = "Desencantar equipo nivel 35-45", zone = "Subasta" },
                    { id = 16206, name = "Vara de arcanita", count = 1, source = "Herrería (fabricada con barras de arcanita) / Subasta", zone = "Capitales" },
                    { id = 13926, name = "Perla dorada", count = 1, source = "Almejas gigantes en costas de nivel 50+ / Subasta", zone = "Azshara / Tanaris" },
                    { id = 11137, name = "Polvo de visión", count = 75, source = "Desencantar equipo nivel 35-45", zone = "Subasta" },
                    { id = 11176, name = "Polvo de ensueño", count = 212, source = "Desencantar equipo nivel 41-50", zone = "Zul'Farrak / Maraudon" },
                    { id = 16204, name = "Polvo de ilusión", count = 50, source = "Desencantar equipo nivel 51-60", zone = "Stratholme / Scholomance" },
                    { id = 16203, name = "Esencia eterna superior", count = 4, source = "Desencantar armas nivel 51-60", zone = "Subasta" },
                    { id = 14344, name = "Esquirla brillante grande", count = 2, source = "Desencantar equipo azul nivel 51-60", zone = "Mazmorras de nivel 60" },
                },
                recipes = {
                    { range = "225 - 230", name = "Vara de veraplata con runas (x1)", mats = "1x Vara de veraplata, 1x Perla negra, 2x Esencia mística superior, 2x Polvo de visión", tip = "Aprende de Annora en Uldaman." },
                    { range = "230 - 235", name = "Encantar botas: agilidad (x5)", mats = "2x Esencia astral superior", tip = "Termina las esencias anteriores." },
                    { range = "235 - 245", name = "Encantar pechera: salud excelente (x10)", mats = "6x Polvo de visión", tip = "Sube hasta 245 de forma constante." },
                    { range = "245 - 265", name = "Encantar brazales: intelecto superior (x20)", mats = "3x Esencia mística inferior", tip = "Muy demandado por taumaturgos." },
                    { range = "265 - 290", name = "Encantar escudo: fortaleza mayor (x25)", mats = "10x Polvo de ensueño", tip = "Fórmula vendida por Daniel Bartlett (Entrañas) o Mythrin'dir (Darnassus)." },
                    { range = "290 - 291", name = "Vara de arcanita con runas (x1)", mats = "1x Vara de arcanita, 1x Perla dorada, 10x Polvo de ilusión, 4x Esencia eterna superior, 2x Esquirla brillante grande", tip = "Fórmula vendida por Lorelae Canción Invernal en Claro de la Luna." },
                    { range = "291 - 300", name = "Encantar capa: defensa superior (x9)", mats = "8x Polvo de ilusión", tip = "Aprende de Lorelae en Claro de la Luna. ¡Te lleva al ansiado nivel 300!" },
                },
                farmingRoute = {
                    title = "Desencanto Artesano (Zul'Farrak y Maraudon)",
                    zoneName = "Zul'Farrak / Maraudon",
                    uiMapID = 1422,
                    steps = {
                        { x = 50.0, y = 50.0, title = "1. Mazmorras de nivel 44-52", instruction = "Polvo de ensueño masivo de las piezas verdes." },
                    }
                }
            }
        }
    },

    -- ---------------------------------------------------------------------
    -- 10. COCINA (COOKING)
    -- ---------------------------------------------------------------------
    ["Cooking"] = {
        key = "Cooking",
        name = "Cocina",
        category = "Secundaria",
        icon = "Interface\\Icons\\inv_misc_food_15",
        guideUrl = "https://www.wow-professions.com/classic/cooking-leveling-guide",
        partnerProf = "Fishing",
        partnerProfName = "Pesca",
        summary = "Prepara comida para restaurar salud, maná y otorgar poderosos beneficios de estadísticas.",
        trainers = {
            alliance = "Stephen Ryback (Ventormenta), Daryl Riknussun (Forjaz), Alegorn (Darnassus).",
            horde = "Zamja (Orgrimmar), Eunice Burch (Entrañas), Aska Caminaniebla (Cima del Trueno)."
        },
        brackets = {
            ["1-75"] = {
                key = "1-75",
                name = "1 - 75 · Aprendiz",
                skillRange = "1 - 75",
                minSkill = 1,
                maxSkill = 75,
                reqLevel = 1,
                trainerTip = "Aprende de cualquier instructor de cocina y compra especias en el comerciante.",
                materials = {
                    { id = 769,  name = "Trozo de carne de jabalí", count = 40, source = "Jabalíes nivel 1-10", zone = "Elwynn / Durotar / Dun Morogh" },
                    { id = 2672, name = "Carne de lobo fibrosa", count = 40, source = "Lobos nivel 1-10", zone = "Elwynn / Dun Morogh / Mulgore" },
                },
                recipes = {
                    { range = "1 - 50",  name = "Carne de jabalí asada (x50)", mats = "1x Trozo de carne de jabalí", tip = "Caza jabalíes en zonas iniciales." },
                    { range = "50 - 75", name = "Carne de lobo condimentada (x25)", mats = "1x Carne de lobo, 1x Especias", tip = "Compra especias en el intendente de cocina." },
                },
                farmingRoute = {
                    title = "Farmeo de Carnes Iniciales",
                    zoneName = "Bosque de Elwynn / Durotar",
                    uiMapID = 1429,
                    steps = {
                        { x = 40.0, y = 60.0, title = "1. Campos de Villadorada", instruction = "Jabalíes y lobos jóvenes." },
                    }
                }
            },
            ["75-150"] = {
                key = "75-150",
                name = "75 - 150 · Oficial",
                skillRange = "75 - 150",
                minSkill = 75,
                maxSkill = 150,
                reqLevel = 10,
                trainerTip = "Aprende Oficial al alcanzar nivel 10 y habilidad 50.",
                materials = {
                    { id = 2674, name = "Carne de cangrejo", count = 40, source = "Cangrejos costeros", zone = "Páramos / Costa Oscura / Durotar" },
                    { id = 2675, name = "Carne de reptador", count = 40, source = "Reptadores de marismas", zone = "Páramos / Los Baldíos" },
                    { id = 5503, name = "Carne de almeja", count = 40, source = "Almejas de costas", zone = "Costas nivel 15-25" },
                },
                recipes = {
                    { range = "75 - 100",  name = "Pastel de cangrejo (x25)", mats = "1x Carne de cangrejo, 1x Especias", tip = "Receta vendida en Páramos y Los Baldíos." },
                    { range = "100 - 150", name = "Sopa de almejas (x50)", mats = "2x Carne de almeja, 1x Leche fría", tip = "Compra leche con cualquier tabernero." },
                },
                farmingRoute = {
                    title = "Farmeo de Almejas y Cangrejos",
                    zoneName = "Páramos de Poniente",
                    uiMapID = 1436,
                    steps = {
                        { x = 30.0, y = 50.0, title = "1. Playa de las Almejas", instruction = "Marea de cangrejos y almejas." },
                    }
                }
            },
            ["150-225"] = {
                key = "150-225",
                name = "150 - 225 · Experto",
                skillRange = "150 - 225",
                minSkill = 150,
                maxSkill = 225,
                reqLevel = 20,
                trainerTip = "Compra el libro 'Cocina para expertos' a Shandrina (Ashenvale - Alianza) o Wulan (Desolace - Horda).",
                materials = {
                    { id = 12202, name = "Lomo de lobo magro", count = 50, source = "Lobos nivel 30-40", zone = "Trabalomas / Humedales" },
                    { id = 12184, name = "Carne de raptor", count = 50, source = "Raptores nivel 30-42", zone = "Arathi / Tuercespina" },
                    { id = 7974,  name = "Carne de almeja gigante", count = 30, source = "Almejas de nivel 35+", zone = "Tanaris / Tuercespina" },
                },
                recipes = {
                    { range = "150 - 175", name = "Filete de lobo magro (x25)", mats = "1x Lomo de lobo magro", tip = "Trabalomas y Laderas de Alterac." },
                    { range = "175 - 225", name = "Raptor asado (x50)", mats = "1x Carne de raptor, 1x Pimiento picante", tip = "Tierras Altas de Arathi." },
                },
                farmingRoute = {
                    title = "Farmeo de Carne de Raptor",
                    zoneName = "Tierras Altas de Arathi",
                    uiMapID = 1417,
                    steps = {
                        { x = 50.0, y = 60.0, title = "1. Llanura de Raptores", instruction = "Caza raptores en las colinas." },
                    }
                }
            },
            ["225-300"] = {
                key = "225-300",
                name = "225 - 300 · Artesano",
                skillRange = "225 - 300",
                minSkill = 225,
                maxSkill = 300,
                reqLevel = 35,
                trainerTip = "Completa la misión de la Almeja Sorpresa en Tanaris con Dirge Hoquick para desbloquear Artesano.",
                materials = {
                    { id = 12203, name = "Carne de lobo tierna", count = 50, source = "Lobos nivel 45-55", zone = "Tierras del Interior / Feralas" },
                    { id = 20424, name = "Carne de gusano de arena", count = 50, source = "Gusanos de arena en Silithus", zone = "Silithus" },
                    { id = 13759, name = "Pargo nocturno crudo", count = 40, source = "Pesca nocturna (18:00 - 06:00)", zone = "Feralas / Azshara / Felwood" },
                },
                recipes = {
                    { range = "225 - 275", name = "Filete de lobo tierno (x50)", mats = "1x Carne de lobo tierna", tip = "Lobos en Feralas y Tierras del Interior." },
                    { range = "275 - 300", name = "Sopa de pargo nocturno (x25)", mats = "1x Pargo nocturno crudo, 1x Agua de manantial", tip = "Comida de maná BiS para sanadores en bandas." },
                },
                farmingRoute = {
                    title = "Farmeo de Carne de Lobo Tierna",
                    zoneName = "Tierras del Interior",
                    uiMapID = 1425,
                    steps = {
                        { x = 45.0, y = 50.0, title = "1. Bosques de los Enanos", instruction = "Lobos y leporinos de gran nivel." },
                    }
                }
            }
        }
    },

    -- ---------------------------------------------------------------------
    -- 11. PESCA (FISHING)
    -- ---------------------------------------------------------------------
    ["Fishing"] = {
        key = "Fishing",
        name = "Pesca",
        category = "Secundaria",
        icon = "Interface\\Icons\\trade_fishing",
        guideUrl = "https://www.wow-professions.com/forever/fishing-and-cooking-leveling-guide",
        partnerProf = "Cooking",
        partnerProfName = "Cocina",
        summary = "Pesca peces, restos y cofres por todo Azeroth. Sube paralelamente con Cocina para maximizar comida y bufos.",
        trainers = {
            alliance = "Lee Brown (Villadorada / Elwynn), Catherine Leland (Ventormenta), Grimnur Stonebrand (Forjaz), Astaia (Darnassus). Experto: Viejo Heming (Bahía del Botín - Libro). Artesano: Nat Pagle (Marjal Revolcafango - Misión).",
            horde = "Uthan Stillwater (Poblado Pezuña de Sangre / Mulgore), Lumak (Orgrimmar), Armand Cromwell (Entrañas), Kah Mistrunner (Cima del Trueno). Experto: Viejo Heming (Bahía del Botín - Libro). Artesano: Nat Pagle (Marjal Revolcafango - Misión)."
        },
        brackets = {
            ["1-75"] = {
                key = "1-75",
                name = "1 - 75 · Aprendiz",
                skillRange = "1 - 75",
                minSkill = 1,
                maxSkill = 75,
                reqLevel = 1,
                trainerTip = "Aprende Aprendiz con Uthan Stillwater (Mulgore) o Lee Brown (Elwynn). Compra una Caña de pescar y Bolas de brillo.",
                materials = {
                    { id = 6256, name = "Caña de pescar", count = 1, isVendor = true, source = "Vendedores de pesca", zone = "Cualquier lago o capital inicial" },
                    { id = 6529, name = "Bola de brillo (+25 pesca)", count = 15, isVendor = true, source = "Vendedores de pesca", zone = "Villadorada / Pezuña de Sangre" },
                    { id = 6291, name = "Pez pequeño brillante crudo", count = 60, source = "Pesca en lago inicial", zone = "Lago Cristal (Elwynn) / Lago Toro de Piedra (Mulgore)" },
                    { id = 6289, name = "Pargo de fango boquicorto crudo", count = 25, source = "Pesca en lago inicial", zone = "Bosque de Elwynn / Mulgore / Durotar" },
                    { id = 6325, name = "Receta: pez pequeño brillante", count = 1, isVendor = true, source = "Tharynn Bouden (Elwynn) / Harn Longcast (Mulgore)", zone = "Villadorada / Pezuña de Sangre" },
                    { id = 6328, name = "Receta: pargo de fango boquicorto", count = 1, isVendor = true, source = "Tharynn Bouden (Elwynn) / Harn Longcast (Mulgore)", zone = "Villadorada / Pezuña de Sangre" },
                },
                recipes = {
                    { range = "1 - 50",  name = "Pesca en aguas iniciales (~60 peces)", mats = "Caña de pescar + Bola de brillo", tip = "Pesca en el Lago Cristal o Lago Toro de Piedra. Cocina los peces pequeños brillantes para subir Cocina a 50." },
                    { range = "50 - 75", name = "Pesca de pargos y avance a Oficial (~30 peces)", mats = "Caña de pescar + Bola de brillo", tip = "Al llegar a 50 de habilidad y nivel 10 de personaje, aprende Oficial de pesca con tu instructor." },
                },
                farmingRoute = {
                    title = "Pesca de Aprendiz (Lagos Iniciales)",
                    zoneName = "Bosque de Elwynn / Mulgore",
                    uiMapID = 1429,
                    steps = {
                        { x = 46.8, y = 61.2, title = "1. Lago Cristal (Elwynn)", instruction = "Pesca con Lee Brown al este de Villadorada. Usa Bola de brillo para no perder capturas.", uiMapID = 1429, zoneName = "Bosque de Elwynn" },
                        { x = 47.5, y = 60.5, title = "2. Lago Toro de Piedra (Mulgore)", instruction = "Pesca al sur de Pezuña de Sangre con Uthan Stillwater.", uiMapID = 1412, zoneName = "Mulgore" },
                    }
                }
            },
            ["75-150"] = {
                key = "75-150",
                name = "75 - 150 · Oficial",
                skillRange = "75 - 150",
                minSkill = 75,
                maxSkill = 150,
                reqLevel = 10,
                trainerTip = "Aprende Oficial con Catherine Leland (Ventormenta) o Naal Mistrunner (Cima del Trueno). Requiere nivel 10 y habilidad 50.",
                materials = {
                    { id = 6365, name = "Caña de pescar fuerte (+5)", count = 1, isVendor = true, source = "Vendedores de pesca (9 plata)", zone = "Ventormenta / Cima del Trueno" },
                    { id = 6530, name = "Lombrices de noche (+50 pesca)", count = 20, isVendor = true, source = "Vendedores de suministros de pesca", zone = "Capitales" },
                    { id = 6289, name = "Pargo de fango boquicorto crudo", count = 60, source = "Pesca en canales y lagos", zone = "Canales de Ventormenta / Cima del Trueno" },
                    { id = 6308, name = "Siluro bigotudo crudo", count = 30, source = "Pesca en canales y lagos", zone = "Ventormenta / Cima del Trueno / Los Baldíos" },
                    { id = 6330, name = "Receta: siluro bigotudo", count = 1, isVendor = true, source = "Catherine Leland (Ventormenta) / Naal Mistrunner (Cima del Trueno)", zone = "Ventormenta / Cima del Trueno" },
                    { id = 8932, name = "Queso suizo de Alterac", count = 20, isVendor = true, source = "Ben Trias (Ventormenta) / Posadera Sikewa (Desolace)", zone = "¡Cómpralo ya para la misión de Artesano de cocina!" },
                },
                recipes = {
                    { range = "75 - 130",  name = "Pesca urbana en capitales (~70 capturas)", mats = "Caña fuerte + Lombrices", tip = "Pesca en los canales de Ventormenta o el estanque de la subasta de Cima del Trueno hasta 130." },
                    { range = "130 - 150", name = "Pesca de siluros bigotudos (~35 capturas)", mats = "Caña fuerte + Cebo", tip = "Sube a 150 pescando siluros. Cocínalos para subir tu Cocina paralelamente hacia 125+." },
                },
                farmingRoute = {
                    title = "Pesca en Canales y Estanques de Capitales",
                    zoneName = "Ciudad de Ventormenta / Cima del Trueno",
                    uiMapID = 1453,
                    steps = {
                        { x = 55.4, y = 69.8, title = "1. Canales de Ventormenta (Comercio)", instruction = "Pesca en los canales centrales cerca de Catherine Leland y Ben Trias.", uiMapID = 1453, zoneName = "Ciudad de Ventormenta" },
                        { x = 45.0, y = 56.0, title = "2. Estanque de Cima del Trueno", instruction = "Pesca en el estanque central junto a la Casa de Subastas.", uiMapID = 1456, zoneName = "Cima del Trueno" },
                    }
                }
            },
            ["150-225"] = {
                key = "150-225",
                name = "150 - 225 · Experto",
                skillRange = "150 - 225",
                minSkill = 150,
                maxSkill = 225,
                reqLevel = 20,
                trainerTip = "No hay instructor. Compra el libro 'Pesca para expertos: tú y el róbalo' (1 oro) al Viejo Heming en Bahía del Botín (Vega de Tuercespina). Requiere nivel 20 y habilidad 125.",
                materials = {
                    { id = 16083, name = "Pesca para expertos: tú y el róbalo", count = 1, isVendor = true, source = "Viejo Heming en Bahía del Botín (1 oro)", zone = "Vega de Tuercespina" },
                    { id = 17062, name = "Receta: trucha cabeza de mitril", count = 1, isVendor = true, source = "Kelsey Yance (Muelle de Bahía del Botín)", zone = "Vega de Tuercespina" },
                    { id = 13941, name = "Receta: filete de agallas rojas", count = 1, isVendor = true, source = "Kelsey Yance (Muelle de Bahía del Botín)", zone = "Vega de Tuercespina" },
                    { id = 16072, name = "Libro de cocina para expertos", count = 1, isVendor = true, source = "Shandrina (Lago Mystral, Vallefresno) / Wulan (Desolace)", zone = "Vallefresno / Desolace" },
                    { id = 6308,  name = "Siluro bigotudo crudo", count = 145, source = "Pesca en aguas dulces nivel 20-30", zone = "Refugio Roca del Sol / Lago Mystral" },
                    { id = 8365,  name = "Trucha cabeza de mitril cruda", count = 70, source = "Pesca en aguas continentales nivel 35-45", zone = "Marjal Revolcafango / Trabalomas" },
                    { id = 6532,  name = "Bola de brillo brillante (+75 pesca)", count = 15, isVendor = true, source = "Vendedores de pesca", zone = "Bahía del Botín / Gadgetzan" },
                },
                recipes = {
                    { range = "130 - 205", name = "Pesca en aguas medias (~100 capturas)", mats = "Sierra Espolón (Horda) / Lago Mystral (Alianza)", tip = "Horda en Refugio Roca del Sol; Alianza en Lago Mystral. Atrapa Siluro bigotudo y Pargo boquicorto." },
                    { range = "205 - 225", name = "Pesca en Marjal Revolcafango (~35 capturas)", mats = "Aguas interiores de Marjal", tip = "Pesca en aguas dulces interiores (evita el mar abierto) hasta alcanzar 225. ¡Guarda las Truchas de mitril!" },
                },
                farmingRoute = {
                    title = "Libro en Bahía del Botín y Pesca de Experto",
                    zoneName = "Vega de Tuercespina / Marjal Revolcafango",
                    uiMapID = 1434,
                    steps = {
                        { x = 27.4, y = 77.0, title = "1. Bahía del Botín (Viejo Heming)", instruction = "Compra 'Pesca para expertos' por 1g y las recetas a Kelsey Yance en el muelle.", uiMapID = 1434, zoneName = "Vega de Tuercespina" },
                        { x = 50.0, y = 62.0, title = "2. Lago Mystral / Sierra Espolón", instruction = "Pesca en aguas interiores hasta nivel 205 con cebos +50 o +75.", uiMapID = 1440, zoneName = "Vallefresno / Sierra Espolón" },
                        { x = 58.5, y = 59.9, title = "3. Marjal Revolcafango (Aguas dulces)", instruction = "Pesca en lagos y ríos interiores hasta alcanzar 225 de habilidad.", uiMapID = 1445, zoneName = "Marjal Revolcafango" },
                    }
                }
            },
            ["225-300"] = {
                key = "225-300",
                name = "225 - 300 · Artesano",
                skillRange = "225 - 300",
                minSkill = 225,
                maxSkill = 300,
                reqLevel = 35,
                trainerTip = "Misión 'Nat Pagle, pescador del extremo' con Nat Pagle en Marjal Revolcafango (58.5, 59.9). Requiere nivel 35 y habilidad 225. Atrapa los 4 peces raros por el mundo para desbloquear hasta 300.",
                materials = {
                    { id = 16967, name = "Ahi de Feralas", count = 1, isQuest = true, source = "Pesca en el Río Verdantis", zone = "Feralas" },
                    { id = 16970, name = "Mahi Mahi de Junco Brumoso", count = 1, isQuest = true, source = "Pesca en costa este", zone = "Pantano de las Penas" },
                    { id = 16968, name = "Luchador de Sar'theris", count = 1, isQuest = true, source = "Pesca en costa oeste (Costa Sar'theris)", zone = "Desolace" },
                    { id = 16969, name = "Pez vela azul de Costa Salvaje", count = 1, isQuest = true, source = "Pesca en Costa Salvaje (sur)", zone = "Vega de Tuercespina" },
                    { id = 13759, name = "Pargo dardo nocturno crudo", count = 60, source = "Pesca en aguas dulces (noche 18:00-06:00)", zone = "Feralas / Azshara" },
                    { id = 13756, name = "Salmón escama solar crudo", count = 60, source = "Pesca en aguas dulces (día 06:00-18:00)", zone = "Feralas / Azshara" },
                    { id = 13758, name = "Agallas rojas crudas", count = 40, source = "Pesca en ríos interiores", zone = "Feralas / Frondavil" },
                    { id = 13889, name = "Salmón escama blanca crudo", count = 25, source = "Pesca en ríos interiores", zone = "Feralas / Tierras de la Peste" },
                    { id = 6533,  name = "Atractor de peces acodinámico (+100)", count = 10, isVendor = true, source = "Ingeniería / Vendedores de pesca", zone = "¡Imprescindible para no perder capturas en Feralas!" },
                },
                recipes = {
                    { range = "225 - 255", name = "Misión de Nat Pagle + Marjal (~45 capturas)", mats = "4 Peces de misión + Caña y cebos", tip = "Pesca los 4 peces de misión, entrégala a Nat Pagle para aprender Artesano y pesca en Marjal hasta 255." },
                    { range = "255 - 300", name = "Pesca en aguas dulces de Feralas (~110 capturas)", mats = "Atractor de peces acodinámico (+100)", tip = "Pesca en ríos y lagos de Feralas (excepto Lago Jademir). Usa atractores +100 para evitar que los peces escapen." },
                },
                farmingRoute = {
                    title = "Misión de Nat Pagle y Pesca en Feralas 300",
                    zoneName = "Marjal / Feralas / Zonas de Misión",
                    uiMapID = 1445,
                    steps = {
                        { x = 58.5, y = 59.9, title = "1. Nat Pagle (Cala Furia de la Marea)", instruction = "Acepta la misión 'Nat Pagle, pescador del extremo' (Requiere Nv 35 y Pesca 225).", uiMapID = 1445, zoneName = "Marjal Revolcafango" },
                        { x = 62.0, y = 51.0, title = "2. Feralas (Río Verdantis)", instruction = "Captura el 'Ahi de Feralas' en el río.", uiMapID = 1443, zoneName = "Feralas" },
                        { x = 90.0, y = 45.0, title = "3. Pantano de las Penas (Costa este)", instruction = "Captura el 'Mahi Mahi de Junco Brumoso' en el océano este.", uiMapID = 1438, zoneName = "Pantano de las Penas" },
                        { x = 25.0, y = 70.0, title = "4. Desolace (Costa Sar'theris)", instruction = "Captura el 'Luchador de Sar'theris' en la costa suroeste.", uiMapID = 1442, zoneName = "Desolace" },
                        { x = 33.0, y = 32.0, title = "5. Vega de Tuercespina (Costa Salvaje)", instruction = "Captura el 'Pez vela azul de Costa Salvaje'. Regresa con Nat Pagle para aprender Artesano.", uiMapID = 1434, zoneName = "Vega de Tuercespina" },
                        { x = 51.0, y = 55.0, title = "6. Feralas (Aguas dulces interiores)", instruction = "Usa Atractor +100 y pesca Pargos nocturnos y Salmones escama solar hasta alcanzar 300.", uiMapID = 1443, zoneName = "Feralas" },
                    }
                }
            }
        }
    },

    -- ---------------------------------------------------------------------
    -- 12. PRIMEROS AUXILIOS (FIRST AID)
    -- ---------------------------------------------------------------------
    ["First Aid"] = {
        key = "First Aid",
        name = "Primeros Auxilios",
        category = "Secundaria",
        icon = "Interface\\Icons\\spell_holy_sealofsacrifice",
        guideUrl = "https://www.wow-professions.com/classic/first-aid-leveling-guide",
        partnerProf = "None",
        partnerProfName = "Universal",
        summary = "Fabrica vendas de emergencia para restaurar salud en combate sin gastar maná.",
        trainers = {
            alliance = "Doctor Gustaf VanHowzen (Theramore - Artesano), Nissa Rompefuego (Forjaz), Shaina Fuller (Ventormenta).",
            horde = "Doctor Gregory Victor (Sentinela de la Venganza - Artesano), Mary Edras (Entrañas), Arnok (Orgrimmar)."
        },
        brackets = {
            ["1-75"] = {
                key = "1-75",
                name = "1 - 75 · Aprendiz",
                skillRange = "1 - 75",
                minSkill = 1,
                maxSkill = 75,
                reqLevel = 1,
                trainerTip = "Aprende de cualquier instructor en capitales o zonas de inicio.",
                materials = {
                    { id = 2589, name = "Paño de lino", count = 150, source = "Humanoides nivel 1-15", zone = "Zonas de inicio / Mazmorras" },
                },
                recipes = {
                    { range = "1 - 40",  name = "Venda de lino (x50)", mats = "1x Paño de lino", tip = "Cura básica sin tiempo de reutilización." },
                    { range = "40 - 75", name = "Venda de lino pesada (x45)", mats = "2x Paño de lino", tip = "Sube fácilmente a 75." },
                },
                farmingRoute = {
                    title = "Farmeo de Lino",
                    zoneName = "Páramos de Poniente / Los Baldíos",
                    uiMapID = 1436,
                    steps = {
                        { x = 50.0, y = 40.0, title = "1. Granjas Defias", instruction = "Humanoides bandidos en masa." },
                    }
                }
            },
            ["75-150"] = {
                key = "75-150",
                name = "75 - 150 · Oficial",
                skillRange = "75 - 150",
                minSkill = 75,
                maxSkill = 150,
                reqLevel = 10,
                trainerTip = "Aprende Oficial al llegar a 50 en cualquier capital.",
                materials = {
                    { id = 2592, name = "Paño de lana", count = 120, source = "Humanoides nivel 18-30", zone = "Minas de la Muerte / Colmillo Oscuro / Trabalomas" },
                },
                recipes = {
                    { range = "75 - 80",   name = "Venda de lino pesada (x10)", mats = "2x Paño de lino", tip = "Gasta el lino restante." },
                    { range = "80 - 115",  name = "Venda de lana (x40)", mats = "1x Paño de lana", tip = "Cura intermedia de gran valor." },
                    { range = "115 - 150", name = "Venda de lana pesada (x45)", mats = "2x Paño de lana", tip = "Te lleva a 150 rápidamente." },
                },
                farmingRoute = {
                    title = "Farmeo de Lana",
                    zoneName = "Minas de la Muerte / Trabalomas",
                    uiMapID = 1424,
                    steps = {
                        { x = 40.0, y = 50.0, title = "1. Minas de Trabalomas", instruction = "Mineros del Sindicato." },
                    }
                }
            },
            ["150-225"] = {
                key = "150-225",
                name = "150 - 225 · Experto",
                skillRange = "150 - 225",
                minSkill = 150,
                maxSkill = 225,
                reqLevel = 20,
                trainerTip = "Compra los manuales de Primeros Auxilios a Deneb Walker (Castillo de Stromgarde, Arathi - Alianza) o Balai Lok'Wein (Pantano Revolcafango - Horda).",
                materials = {
                    { id = 4306, name = "Paño de seda", count = 150, source = "Humanoides nivel 28-40", zone = "Monasterio Escarlata" },
                    { id = 4338, name = "Paño de tejido mágico", count = 80, source = "Humanoides nivel 40-52", zone = "Zul'Farrak / Tanaris" },
                },
                recipes = {
                    { range = "150 - 180", name = "Venda de seda (x40)", mats = "1x Paño de seda", tip = "Aprende con el manual de primeros auxilios." },
                    { range = "180 - 210", name = "Venda de seda pesada (x40)", mats = "2x Paño de seda", tip = "Aprende con el manual de seda pesada." },
                    { range = "210 - 225", name = "Venda de tejido mágico (x20)", mats = "1x Paño de tejido mágico", tip = "Aprende con el manual de tejido mágico." },
                },
                farmingRoute = {
                    title = "Farmeo de Seda (Monasterio)",
                    zoneName = "Monasterio Escarlata",
                    uiMapID = 1420,
                    steps = {
                        { x = 50.0, y = 50.0, title = "1. Cruzados Escarlata", instruction = "Paño de seda a montones." },
                    }
                }
            },
            ["225-300"] = {
                key = "225-300",
                name = "225 - 300 · Artesano",
                skillRange = "225 - 300",
                minSkill = 225,
                maxSkill = 300,
                reqLevel = 35,
                trainerTip = "Completa la misión 'Triaje' con el Doctor Gustaf VanHowzen (Theramore - Alianza) o el Doctor Gregory Victor (Sentinela de la Venganza - Horda). Requiere nivel 35 y habilidad 225.",
                materials = {
                    { id = 4338,  name = "Paño de tejido mágico", count = 90, source = "Humanoides nivel 40-52", zone = "Zul'Farrak / Tanaris" },
                    { id = 14047, name = "Paño rúnico", count = 150, source = "Humanoides nivel 50-60", zone = "Tierras de la Peste" },
                },
                recipes = {
                    { range = "225 - 260", name = "Venda de tejido mágico pesada (x45)", mats = "2x Paño de tejido mágico", tip = "Aprende del instructor tras completar el triaje." },
                    { range = "260 - 290", name = "Venda de paño rúnico (x40)", mats = "1x Paño rúnico", tip = "Venda de combate indispensable." },
                    { range = "290 - 300", name = "Venda de paño rúnico pesada (x15)", mats = "2x Paño rúnico", tip = "La venda más poderosa del juego. ¡Cura 2000 p. de salud en 8 segundos!" },
                },
                farmingRoute = {
                    title = "Farmeo de Paño Rúnico",
                    zoneName = "Tierras de la Peste del Oeste",
                    uiMapID = 1422,
                    steps = {
                        { x = 45.0, y = 40.0, title = "1. Campos del Azote (Andorhal)", instruction = "No-muertos humanoides con alta tasa de paño rúnico." },
                    }
                }
            }
        }
    }
}

-- Mapeo retrocompatible con las rutas existentes de GuideHUD / TomTom
ns.Data.Farming = ns.Data.Farming or {}
for profKey, profData in pairs(ns.Data.ProfessionGuides) do
    if profData.brackets then
        for bracketKey, bracketData in pairs(profData.brackets) do
            if bracketData.farmingRoute then
                local r = bracketData.farmingRoute
                if r.steps then
                    for _, s in ipairs(r.steps) do
                        s.uiMapID = s.uiMapID or r.uiMapID
                        s.zoneName = s.zoneName or r.zoneName
                    end
                end
                local routeKey = string.lower(profKey .. "_" .. bracketKey)
                ns.Data.Farming[routeKey] = {
                    id = routeKey,
                    title = r.title,
                    category = profData.name,
                    profession = profKey,
                    requiredSkill = bracketData.minSkill,
                    skillRange = bracketData.skillRange,
                    level = "Recomendado Nv. " .. bracketData.reqLevel .. "+",
                    zoneName = r.zoneName,
                    uiMapID = r.uiMapID,
                    icon = profData.icon,
                    steps = r.steps
                }
            end
        end
    end
end
