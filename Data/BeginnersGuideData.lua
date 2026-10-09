-- =========================================================================
-- Awakening Companion - Data/BeginnersGuideData.lua
-- Base de datos de la Guía para Principiantes y Consejos Esenciales para WoW Forever
-- Fuente y adaptación: Odealo.com & Comunidad Awakening
-- =========================================================================
local ADDON, ns = ...

ns.Data = ns.Data or {}

ns.Data.BeginnersGuide = {
    id = "beginners_guide",
    title = "Consejos para Principiantes",
    titleEn = "Beginner's Guide & Essential Tips",
    category = "Consejos",
    subCategory = "Guía Estratégica",
    faction = "Ambas",
    level = "Nivel 1 - 60",
    minLevel = 1,
    maxLevel = 60,
    icon = "Interface\\Icons\\inv_misc_book_07",
    badge = "GUÍA OFICIAL FOREVER",
    author = "Odealo & Comunidad Awakening",
    summary = "Aprende qué hábitos de Classic aún funcionan, qué ha cambiado radicalmente (profesiones desde nivel 1, campamentos, mazmorras tácticas) y cómo progresar eficientemente en WoW Forever.",
    
    -- ---------------------------------------------------------------------
    -- SECCIÓN 1: DIFERENCIAS CRÍTICAS WOW FOREVER VS WOW CLASSIC
    -- ---------------------------------------------------------------------
    differences = {
        title = "Diferencias Críticas: WoW Forever vs WoW Classic",
        description = "WoW Forever mantiene la esencia pausada y el viaje 1-60 del juego original, pero introduce sistemas modernos permanentes que cambian por completo la estrategia de juego.",
        table = {
            {
                system = "Leveleo & Rutas",
                classic = "Azeroth 1-60 original y flujo tradicional de misiones.",
                forever = "Mantiene el viaje 1-60 pero añade más de 1,000 nuevas misiones, nuevas zonas, mazmorras rediseñadas y recompensas renovadas.",
                status = "new"
            },
            {
                system = "Estructura Permanente",
                classic = "Reinos anclados a expansiones o fases históricas fijas.",
                forever = "Un Azeroth permanente y en expansión continua, diseñado para recibir nuevo contenido exclusivo de nivel 60 a lo largo del tiempo.",
                status = "new"
            },
            {
                system = "Reinos & Rulesets",
                classic = "Eliges un servidor/reino específico.",
                forever = "Eliges un conjunto de reglas (Ruleset: Normal, JcJ, Rol) en lugar de un servidor tradicional cerrado.",
                status = "keep"
            },
            {
                system = "Profesiones",
                classic = "Útiles, pero muchos jugadores las posponen hasta llegar al nivel 60.",
                forever = "Más de 600 recetas nuevas, objetos para campamentos, bancos de trabajo y planos en mazmorras. Subirlas mientras leveleas es vital.",
                status = "alert"
            },
            {
                system = "Fogones & Campamentos",
                classic = "Una utilidad básica para cocinar carne.",
                forever = "Crean Campamentos compartidos con bufos de 1 hora, bancos de trabajo, comerciantes y reparaciones para todo el grupo.",
                status = "new"
            },
            {
                system = "Mazmorras",
                classic = "Se farmean repetidamente en bucle para subir rápido de nivel mediante XP de criaturas.",
                forever = "La XP de monstruos normales está muy reducida. El 80% de la experiencia proviene de las misiones de mazmorra (hacer 1 pasada completa con misiones).",
                status = "alert"
            },
            {
                system = "Clases & Talentos",
                classic = "Diseño de clases y árboles de talentos clásicos inalterados.",
                forever = "Estructura familiar, pero cada clase ha sido revisada con nuevos talentos, habilidades y nuevas combinaciones de raza/clase.",
                status = "new"
            },
            {
                system = "Estadísticas & Equipo",
                classic = "Separación de Golpe, Crítico y estadísticas rígidas.",
                forever = "Golpe y Crítico unificados (hechizos, cuerpo a cuerpo y a distancia). El daño base de hechizos se redujo: el Poder con Hechizos es crucial.",
                status = "new"
            },
            {
                system = "Sistema Legacy",
                classic = "Toda la progresión está ligada a un solo personaje.",
                forever = "Sistema de cuenta que recompensa exploración, profesiones, mazmorras y logros desbloqueando ventajas para todos tus personajes a nivel 25+.",
                status = "new"
            },
        }
    },

    -- ---------------------------------------------------------------------
    -- SECCIÓN 2: LA PRIMERA HORA (CHECKLIST DE 6 PASOS)
    -- ---------------------------------------------------------------------
    firstHour = {
        title = "Tu Primera Hora: 6 Pasos Indispensables",
        description = "Establece los cimientos correctos desde los primeros minutos para ahorrar horas de viaje y oro en el futuro.",
        steps = {
            {
                id = "fh_ruleset",
                num = 1,
                title = "Elige el Ruleset y Facción con tus Amigos",
                desc = "Asegúrate de que tu hermandad o amigos elijan el mismo conjunto de reglas (Normal o JcJ) y facción antes de empezar.",
                tip = "En WoW Forever los amigos en el mismo ruleset pueden jugar juntos fácilmente.",
                icon = "Interface\\Icons\\achievement_arena_2v2_7"
            },
            {
                id = "fh_professions",
                num = 2,
                title = "Aprende tus Profesiones Inmediatamente",
                desc = "No las pospongas a nivel 60. Aprende 2 profesiones primarias en tu primera aldea o campamento y recolecta mientras avanzas.",
                tip = "Llegar a nivel 20 de profesión desbloquea tu primer objeto de campamento.",
                icon = "Interface\\Icons\\trade_engineering"
            },
            {
                id = "fh_cooking",
                num = 3,
                title = "Aprende Cocina (Habilidad Secundaria)",
                desc = "La cocina te otorga el 'Fogón básico' para el sistema de acampada y comidas que conceden +5% de experiencia por baja de criaturas.",
                tip = "No consume ranura de profesión primaria y acelera tu leveleo.",
                icon = "Interface\\Icons\\inv_misc_food_15"
            },
            {
                id = "fh_camping",
                num = 4,
                title = "Desbloquea la Acampada (The Great Outdoors)",
                desc = "Completa la misión introductoria de campamento en cuanto esté disponible en tu zona inicial para poder colocar objetos de acampada.",
                tip = "Los campamentos benefician a cualquier aventurero cercano.",
                icon = "Interface\\Icons\\spell_fire_fire"
            },
            {
                id = "fh_bags",
                num = 5,
                title = "Consigue Bolsas Adicionales lo Antes Posible",
                desc = "El espacio de inventario es oro en WoW Forever por la gran cantidad de materiales de profesión y objetos de campamento.",
                tip = "Acepta la guía del Saco de Dormir o cómprale bolsas de 6 casillas a los sastres o vendedores locales.",
                icon = "Interface\\Icons\\inv_misc_bag_08"
            },
            {
                id = "fh_flightpaths",
                num = 6,
                title = "Sintoniza Todos los Puntos de Vuelo",
                desc = "No hay monturas voladoras en WoW Forever. Un desvío de 3 minutos para aprender una ruta de vuelo te ahorrará horas enteras de carrera a pie.",
                tip = "Abre el Planeador de Viaje de Awakening Companion para ver conexiones recomendadas.",
                icon = "Interface\\Icons\\ability_mount_gyrocopter"
            },
        }
    },

    -- ---------------------------------------------------------------------
    -- SECCIÓN 3: PROFESIONES Y COMBINACIONES ÓPTIMAS
    -- ---------------------------------------------------------------------
    professions = {
        title = "Profesiones: Mucho más Relevantes en WoW Forever",
        description = "Con más de 600 recetas nuevas y planos exclusivos en jefes de mazmorras, emparejar una profesión de recolección con su correspondiente de fabricación es la mejor decisión.",
        milestoneTip = "Hito Clave: Alcanza 20 puntos de habilidad lo antes posible para desbloquear la primera contribución para Campamentos.",
        pairings = {
            {
                pair = "Herboristería + Alquimia",
                role = "Excelente para todas las clases y magos/sanadores",
                desc = "Recoges tus propias plantas y las conviertes en pociones, elixires y frascos que reducen el tiempo muerto. Provee objetos de campamento regenerativos.",
                icon = "Interface\\Icons\\trade_herbalism"
            },
            {
                pair = "Minería + Herrería",
                role = "Ideal para Guerreros y Paladines",
                desc = "Forja armas y armaduras de placas para ti y tu grupo. La herrería aporta afiladores de armas y bancos de mantenimiento para el campamento.",
                icon = "Interface\\Icons\\trade_blacksmithing"
            },
            {
                pair = "Minería + Ingeniería",
                role = "La reina de la utilidad, JcJ y control de masas",
                desc = "Granadas, dianas mecánicas, gafas y herramientas indispensables. La ingeniería consume muchos minerales, por lo que Minería es obligatoria.",
                icon = "Interface\\Icons\\trade_engineering"
            },
            {
                pair = "Desuello + Peletería",
                role = "Comodísimo para Pícaros, Cazadores y Druidas",
                desc = "Desuellas las bestias que ya estás matando en tus misiones. Fabrica armaduras de cuero y parches de armadura que otorgan estadísticas fijas.",
                icon = "Interface\\Icons\\inv_misc_pelt_wolf_01"
            },
            {
                pair = "Sastrería + Encantamiento",
                role = "La pareja dorada para usuarios de tela (Mago, Brujo, Sacerdote)",
                desc = "Sastrería te permite crear tus propias bolsas y equipo sin depender de nodos de recolección; el equipo sobrante se desencanta para subir Encantamiento.",
                icon = "Interface\\Icons\\trade_tailoring"
            },
            {
                pair = "Doble Recolección (Minería + Desuello)",
                role = "Máxima generación de oro temprano",
                desc = "Buena para financiar tu primera montura rápidamente vendiendo materiales en subasta, aunque pierdes las mejoras de fabricación del campamento.",
                icon = "Interface\\Icons\\inv_misc_coin_02"
            },
        },
        secondaries = {
            {
                name = "Cocina",
                desc = "Crea los kits de fogatas para acampar. En la beta actual, muchas comidas otorgan un 5% adicional de experiencia por muertes.",
                icon = "Interface\\Icons\\inv_misc_food_15"
            },
            {
                name = "Pesca",
                desc = "Apoya a Cocina y cuenta con su propia progresión de campamento (la Pecera otorga un +8% a todas las estadísticas compatible con casi todo).",
                icon = "Interface\\Icons\\trade_fishing"
            },
            {
                name = "Primeros Auxilios",
                desc = "Los vendajes reducen el tiempo entre combates sin gastar maná. Su objeto de campamento temprano otorga Aguante adicional al grupo.",
                icon = "Interface\\Icons\\spell_holy_sealofsacrifice"
            },
        }
    },

    -- ---------------------------------------------------------------------
    -- SECCIÓN 4: LA REGLA DE ORO DEL CAMPAMENTO (CAMPING)
    -- ---------------------------------------------------------------------
    camping = {
        title = "La Regla de Oro del Campamento",
        ruleMinutes = 1,
        buffDurationHours = 1,
        description = "Cada vez que veas un fogón activo mientras exploras o hagas una pausa entre misiones, ¡aprovéchalo!",
        goldenRule = "Siéntate cerca del fogón (/sit) durante 1 minuto para recibir los bufos del campamento durante 1 hora completa de combate.",
        keyPoints = {
            "Un Fogón Básico soporta hasta 3 objetos de profesión; los mejorados hasta 5 o 10.",
            "Cada jugador cercano puede colocar 1 objeto según sus profesiones aprendidas.",
            "Los bufos de campamento NO se acumulan con los bufos de clase equivalentes (ej. Intelecto con Intelecto Arcano), pero sirven para suplir clases que falten en tu grupo.",
            "Coloca campamentos en puntos clave: entradas de mazmorras, antes de misiones de élite o en cruces de caminos transitados.",
        }
    },

    -- ---------------------------------------------------------------------
    -- SECCIÓN 5: MAZMORRAS TÁCTICAS (QUEST-LOADED)
    -- ---------------------------------------------------------------------
    dungeons = {
        title = "Mazmorras Tácticas: La Regla de la Pasada Completa",
        description = "En WoW Forever, hacer 'dungeon grind' matando monstruos una y otra vez es ineficiente: Blizzard redujo fuertemente la XP de los monstruos normales dentro de mazmorras.",
        goldenRule = "Recoge todas las misiones de la mazmorra antes de entrar y realiza 1 pasada completa. Luego regresa al mundo exterior.",
        advantages = {
            "Las misiones de mazmorra otorgan enormes cantidades de experiencia.",
            "El botín de jefes ha sido revisado: los objetos únicos ahora son de calidad Rara (Azul).",
            "Los jefes pueden soltar Planos de Profesión (Blueprints) para objetos avanzados de campamento.",
            "El sistema Legacy otorga desafíos de cuenta por vencer al jefe final de cada franja de nivel.",
            "El combate es pausado: matar un monstruo normal toma 10-15 segundos. Respeta la amenaza del tanque y usa Control de Masas (Polimorfia, Trampa, Miedo, Raíces).",
        }
    },

    -- ---------------------------------------------------------------------
    -- SECCIÓN 6: RUTINA AL VISITAR LA CIUDAD (TOWN ROUTINE)
    -- ---------------------------------------------------------------------
    townRoutine = {
        title = "Rutina Óptima al Visitar la Ciudad",
        description = "Para evitar viajar de ida y vuelta innecesariamente, sigue esta lista cada vez que regreses a un poblado o capital:",
        checklist = {
            "1. Entrena nuevas habilidades de clase en tu instructor.",
            "2. Repara todo tu equipamiento dañado.",
            "3. Vende la basura gris y libera espacio en las bolsas.",
            "4. Visita a tus instructores de profesión para aprender recetas del nuevo tramo.",
            "5. Revisa la Casa de Subastas si buscas armas clave o materiales escasos.",
            "6. Repone consumibles: comida, bebida, munición, venenos y componentes de clase.",
            "7. Sintoniza el Maestro de Vuelo local antes de salir a la naturaleza.",
        }
    },

    -- ---------------------------------------------------------------------
    -- SECCIÓN 7: MATRIZ DE 10 ERRORES COMUNES A EVITAR
    -- ---------------------------------------------------------------------
    mistakes = {
        title = "10 Errores de Novato (y de Veterano de Classic) a Evitar",
        description = "Muchos jugadores tropiezan aplicando hábitos viejos de Classic o de Retail en WoW Forever:",
        list = {
            {
                mistake = "Ignorar las profesiones de fabricación hasta llegar al nivel 60.",
                better = "Súbelas mientras subes de nivel. Desbloquea tu primer objeto de campamento a nivel 20 de profesión.",
                category = "Profesiones"
            },
            {
                mistake = "Pasar de largo frente a los fogones encendidos.",
                better = "Detente 60 segundos (/sit), llévate 1 hora de bufos de combate y sigue tu camino con ventaja.",
                category = "Campamento"
            },
            {
                mistake = "Ignorar Cocina porque 'la comida se puede comprar'.",
                better = "Cocina te da el fogón para acampar y comida con +5% de experiencia por cada baja.",
                category = "Profesiones"
            },
            {
                mistake = "No aprender Pesca ni Primeros Auxilios.",
                better = "Son secundarias gratuitas que aportan bufos de Aguante y estadísticas porcentuales para campamentos.",
                category = "Profesiones"
            },
            {
                mistake = "Hacer spam de la misma mazmorra para subir de nivel farmeando mobs.",
                better = "La XP de trash mobs está reducida. Haz 1 pasada con todas las misiones y vuelve a questear al mundo.",
                category = "Mazmorras"
            },
            {
                mistake = "Entrar a una mazmorra sin haber recogido sus misiones previas.",
                better = "Reúne las misiones de ciudades y cadenas antes de entrar para multiplicar por tres la recompensa.",
                category = "Mazmorras"
            },
            {
                mistake = "Seguir guías viejas de equipo de Classic sin leer los objetos nuevos.",
                better = "WoW Forever rediseñó el botín, estadísticas unificadas y recompensas de misiones. ¡Lee las estadísticas!",
                category = "Equipo"
            },
            {
                mistake = "Hacer pulls masivos estilo Retail esperando que el tanque aguante todo.",
                better = "El combate es táctico y lento (10-15s por mob). Respeta la amenaza y usa control de masas.",
                category = "Combate"
            },
            {
                mistake = "Saltarse rutas de vuelo porque 'el camino a pie parece corto'.",
                better = "No hay monturas voladoras. Una ruta descubierta te ahorrará horas a lo largo del viaje 1-60.",
                category = "Viaje"
            },
            {
                mistake = "Creer que el nivel 60 es el único objetivo que importa.",
                better = "Disfruta el camino: el sistema Legacy, las 1,000 misiones nuevas y la cooperación hacen que el viaje valga la pena.",
                category = "Mentalidad"
            },
        }
    }
}
