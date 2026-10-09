local ADDON, ns = ...

-- =========================================================================
-- GUÍA ESTRATÉGICA: LA MEJOR FORMA DE GASTAR PUNTOS LEGACY EN WOW FOREVER
-- Basada en el análisis meta y builds oficiales de Method.gg
-- Fuente: https://www.method.gg/wow-forever/the-best-way-to-spend-your-legacy-points-in-wow-forever-best-legacy-talent-builds
-- =========================================================================

ns.Data = ns.Data or {}
ns.Data.LegacyTalentsGuide = {
    meta = {
        id = "legacy_talents_guide",
        title = "Guía de Puntos y Talentos Legacy",
        titleEn = "The Best Way to Spend Your Legacy Points in WoW Forever",
        category = "Consejos",
        subCategory = "Talentos & Progresión",
        source = "Method.gg · Meta Builds & Legacy Analysis",
        badge = "GUÍA METHOD FOREVER",
        level = "Nivel 1 - 60",
        minLevel = 1,
        maxLevel = 60,
        summary = "Los Puntos Legacy proporcionan progresión a nivel de cuenta (Account-wide) que desbloquea talentos únicos para todos tus personajes. Cada personaje puede gastar hasta 16 puntos de forma independiente en 3 árboles (Aventura, Profesiones e Ingenio). Descubre los fundamentos del sistema, la comparativa Thrill vs Talented y las 5 builds óptimas diseñadas por Method.",
    },

    -- 4 PILARES Y REGLAS DEL SISTEMA LEGACY (TARJETAS HERO)
    pillars = {
        {
            id = "account_progression",
            title = "Progresión de Cuenta",
            icon = "Interface\\Icons\\inv_misc_book_09",
            color = "48C5C5",
            desc = "Los puntos ganados se desbloquean a nivel de cuenta para todos tus personajes, pero cada personaje los invierte y distribuye según su propia clase, rol y objetivo de juego.",
        },
        {
            id = "cap_16_points",
            title = "Límite de 16 Puntos",
            icon = "Interface\\Icons\\inv_misc_coin_01",
            color = "FFD43B",
            desc = "Al lanzamiento puedes gastar un máximo de 16 Puntos Legacy por personaje. Desbloquear el talento final de un árbol exige 10 puntos previos + 1 punto final (11 en total).",
        },
        {
            id = "respec_rules",
            title = "Reseteo en Instructor",
            icon = "Interface\\Icons\\spell_nature_timestop",
            color = "C8A2FF",
            desc = "Puedes reiniciar tus talentos Legacy en cualquier instructor de clase en una capital por una tarifa de 10 de Oro. Ideal para adaptar tu build al alcanzar el nivel 60.",
        },
        {
            id = "three_trees",
            title = "Los 3 Árboles",
            icon = "Interface\\Icons\\inv_misc_map02",
            color = "FF6B6B",
            desc = "Aventura (leveleo y regeneración), Profesiones (recolección y recetas) e Ingenio (reputación, coste de consumibles, velocidad en muerte y reducción de reparación).",
        },
    },

    -- EL GRAN DEBATE: THRILL OF ADVENTURE VS TALENTED
    debate = {
        title = "El Gran Debate: Thrill of Adventure vs Talented",
        description = "La decisión más importante al desbloquear tus primeros Puntos Legacy. Ambos talentos son los máximos aspirantes para acelerar tu leveleo, pero tienen filosofías opuestas.",
        talents = {
            {
                name = "Thrill of Adventure (Emoción de la Aventura)",
                tree = "Adventure (Aventura)",
                ranks = "5 Rangos (1 punto por rango)",
                effect = "Regenera 1% de salud y maná por rango (5% a rango 5) durante 10 segundos tras matar un enemigo no trivial (que otorgue XP u honor) en mundo abierto.",
                verdict = "La opción #1 recomendada por Method para iniciar. Elimina casi todo el tiempo de descanso (downtime) entre combates y sigue siendo útil a nivel 60 al farmear en exteriores.",
                color = "00FF00",
                icon = "Interface\\Icons\\spell_nature_reincarnation",
            },
            {
                name = "Talented (Talentoso)",
                tree = "Adventure (Aventura)",
                ranks = "5 Rangos (Requiere 5 pts en Well Rested)",
                effect = "Otorga puntos de talento normales hasta 5 niveles antes de tiempo (por ejemplo, a nivel 55 ya dispones de los 51 talentos en vez de esperar al 60).",
                verdict = "Pico de potencia brutal en servidores PvP para ganar duelos de mundo abierto. Sin embargo, requiere 10 puntos en total y a nivel 60 pierde su efecto, exigiendo un reseteo de 10g.",
                color = "FFD43B",
                icon = "Interface\\Icons\\spell_holy_blessingofstrength",
            },
        },
        methodVerdict = "Method recomienda invertir tus primeros 5 Puntos Legacy en Thrill of Adventure para asegurar un flujo constante y cómodo de regeneración. Solo opta por Talented si juegas en un servidor JcJ muy disputado o estás armando un personaje secundario para twinking.",
    },

    -- LAS 5 BUILDS DEL META METHOD
    builds = {
        {
            id = "pure_leveling",
            title = "1. Leveleo Puro (Speed Leveling)",
            subtitle = "Aventura Completa · Regeneración Constante & Talentos Tempranos",
            color = "48C5C5",
            icon = "Interface\\Icons\\inv_boots_02",
            pointsDistribution = "Aventura: 16 | Profesiones: 0 | Ingenio: 0",
            keyTalents = "5 Thrill of Adventure + 5 Well Rested + 5 Talented + 1 Field Medicine",
            desc = "La build definitiva para subir del 1 al 60 a toda velocidad. Maximiza tu supervivencia con la regeneración pasiva tras cada muerte, acelera la ganancia de experiencia descansada y te otorga talentos clave 5 niveles antes de lo normal.",
            notes = "Al alcanzar nivel 60, debes visitar a tu instructor de clase para resetear Talented por 10g, ya que pierde su efecto al nivel máximo.",
        },
        {
            id = "leveling_professions",
            title = "2. Leveleo + Profesiones (Crafters)",
            subtitle = "Aventura & Artesanía · Desarrollo Simultáneo de Oficios",
            color = "FFD43B",
            icon = "Interface\\Icons\\trade_engineering",
            pointsDistribution = "Aventura: 11 | Profesiones: 5 | Ingenio: 0",
            keyTalents = "5 Thrill of Adventure + 5 Working Overtime (o Bountiful Harvest) + Field Medicine / Field Guide / Frequent Flier",
            desc = "Diseñada para jugadores que no quieren posponer sus profesiones. Working Overtime permite subir oficios difíciles (como Encantamiento) sin depender de recetas naranjas costosas, mientras Thrill of Adventure mantiene intacto tu ritmo de misiones.",
            notes = "Si tus profesiones son de recolección en lugar de artesanía, cambia Working Overtime por Bountiful Harvest.",
        },
        {
            id = "gatherer_alt",
            title = "3. Recolector & Extractor (Gatherer Alt)",
            subtitle = "Profesiones al Máximo · El Motor Económico de la Hermandad",
            color = "00FFCC",
            icon = "Interface\\Icons\\inv_misc_gem_bloodstone_01",
            pointsDistribution = "Profesiones: 15 | Ingenio: 1 | Aventura: 0",
            keyTalents = "5 Bountiful Harvest + 5 Bartering + Dedicated Study + Master Chef / Luremaster + 1 The Quick and the Dead",
            desc = "Bountiful Harvest otorga hasta +100% de materiales escasos (Pristine Leather en Desuello, Pyrite en Minería). Bartering reduce precios de vendedores y Dedicated Study otorga Esencia Elemental diaria gratuita cuando alcanzas 300 en las 5 profesiones.",
            notes = "Tener un alter dedicado con esta build es una de las mayores fuentes de oro y reactivos raros en WoW Forever.",
        },
        {
            id = "pvp_progression",
            title = "4. Jugador contra Jugador (PvP Meta)",
            subtitle = "Campos de Batalla & Mundo Abierto · Detección de Sigilo y Honor",
            color = "FF6B6B",
            icon = "Interface\\Icons\\inv_bannerpvp_02",
            pointsDistribution = "Ingenio: 11 | Aventura: 5 | Profesiones: 0",
            keyTalents = "For Great Honor (+10% Honor en BGs) + Diplomat (+10% Reputación) + High Alert (Detección de Sigilo) + Thrill of Adventure / Talented",
            desc = "Maximiza la ganancia de puntos de honor y reputaciones de facciones PvP (Garganta Grito de Guerra, Cuenca de Arathi). High Alert te otorga ventaja crítica para detectar Pícaros y Druidas en sigilo en el mundo abierto.",
            notes = "En personajes Twink de niveles 19, 29, 39 o 49, Talented es obligatorio para desbloquear talentos de rangos superiores.",
        },
        {
            id = "raiding_dungeons",
            title = "5. Mazmorras & Bandas (Raiding & PvE)",
            subtitle = "Optimización de Banda · Menos Gastos de Reparación y Bufos Más Largos",
            color = "C8A2FF",
            icon = "Interface\\Icons\\inv_shield_06",
            pointsDistribution = "Ingenio: 16 | Profesiones: 0 | Aventura: 0",
            keyTalents = "Reinforce (Ahorro en reparación) + Diplomat (+Reputación de Raid) + The Quick and the Dead (Velocidad como fantasma) + Reagent Economy & Gourmand",
            desc = "Enfocada en el contenido de nivel 60. Reduce drásticamente las facturas de reparación durante noches de progresión de banda, abarata el coste de reactivos para bufos de grupo y extiende la duración de comidas y frascos con Gourmand.",
            notes = "The Quick and the Dead reduce sustancialmente el tiempo de caminata de vuelta al jefe tras cada wipe.",
        },
    },

    -- CATÁLOGO DE TALENTOS CLAVE EXPLICADOS
    talentsList = {
        {
            name = "Thrill of Adventure",
            tree = "Adventure",
            cost = "5 Pts",
            desc = "Regenera 1-5% de salud y maná durante 10s tras matar un objetivo no trivial en mundo abierto.",
            color = "48C5C5",
            icon = "Interface\\Icons\\spell_nature_reincarnation",
        },
        {
            name = "Talented",
            tree = "Adventure",
            cost = "5 Pts (Req 5 en Well Rested)",
            desc = "Otorga puntos de talento de clase hasta 5 niveles antes. Pierde efecto a nivel 60.",
            color = "FFD43B",
            icon = "Interface\\Icons\\spell_holy_blessingofstrength",
        },
        {
            name = "Bountiful Harvest",
            tree = "Professions",
            cost = "5 Pts",
            desc = "Hasta +100% de obtención de materiales raros y escasos en Minería, Herboristería y Desuello.",
            color = "00FFCC",
            icon = "Interface\\Icons\\inv_misc_gem_bloodstone_01",
        },
        {
            name = "Dedicated Study",
            tree = "Professions",
            cost = "1 Pt (Req 10 Pts + Bartering)",
            desc = "Mejora habilidades artesanales y otorga Esencia Elemental diaria con las 5 profesiones al 300.",
            color = "C8A2FF",
            icon = "Interface\\Icons\\inv_misc_book_11",
        },
        {
            name = "Reinforce",
            tree = "Resourcefulness",
            cost = "3 Pts",
            desc = "Reduce significativamente el daño a la durabilidad y los costes de reparación por muerte.",
            color = "FF6B6B",
            icon = "Interface\\Icons\\inv_shield_06",
        },
        {
            name = "The Quick and the Dead",
            tree = "Resourcefulness",
            cost = "1 Pt",
            desc = "Aumenta la velocidad de movimiento en forma de espíritu tras morir en cualquier zona.",
            color = "48C5C5",
            icon = "Interface\\Icons\\spell_shadow_haunting",
        },
        {
            name = "Diplomat",
            tree = "Resourcefulness",
            cost = "5 Pts",
            desc = "Aumenta la ganancia de reputación hasta en un 10% con todas las facciones de Azeroth.",
            color = "FFD43B",
            icon = "Interface\\Icons\\inv_scroll_03",
        },
        {
            name = "Gourmand & Reagent Economy",
            tree = "Resourcefulness",
            cost = "5 Pts",
            desc = "Extiende la duración de comidas de campamento y reduce los reactivos necesarios para bufos de banda.",
            color = "00FFCC",
            icon = "Interface\\Icons\\inv_misc_food_15",
        },
    },
}
