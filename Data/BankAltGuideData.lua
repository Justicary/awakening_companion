local ADDON, ns = ...

-- =========================================================================
-- GUÍA ESTRATÉGICA: GESTIÓN DE ORO & PERSONAJE DE BANCO (BANK ALT)
-- Adaptada para World of Warcraft Forever (Semana de Lanzamiento & Nivel 1-60)
-- Fuente: LootWoW Launch Economy & Inventory Management Guide
-- =========================================================================

ns.Data = ns.Data or {}
ns.Data.BankAltGuide = {
    meta = {
        id = "bank_alt_guide",
        title = "Gestión de Oro y Personaje de Banco (Bank Alt)",
        titleEn = "Bank Alt Guide for Launch Week Gold & Inventory Management",
        category = "Consejos",
        subCategory = "Economía & Inventario",
        source = "LootWoW · Launch Economy Analysis",
        level = "Nivel 1 - 60",
        minLevel = 1,
        maxLevel = 60,
        summary = "Un personaje de banco (Bank Alt) es una de las herramientas más valiosas durante el lanzamiento de WoW Forever para proteger tu tiempo de leveleo. Centraliza materiales de profesión, administra ventas en Subasta y separa tu reserva de oro para evitar compras impulsivas sin interrumpir tus rutas de misiones.",
    },

    -- 4 PILARES FUNDAMENTALES (TARJETAS HERO SUPERIORES)
    pillars = {
        {
            id = "clean_bags",
            title = "Bolsas de Leveleo Limpias",
            icon = "Interface\\Icons\\inv_misc_bag_08",
            color = "48C5C5",
            desc = "Tu personaje principal se mantiene enfocado en equipo de combate, comida y consumibles. Cero casillas desperdiciadas con menas, cuero o telas mientras haces misiones.",
        },
        {
            id = "fast_ah",
            title = "Subasta Centralizada",
            icon = "Interface\\Icons\\inv_misc_coin_01",
            color = "C8A2FF",
            desc = "Todas las ventas y compras ocurren en un solo vendedor. No pierdes tiempo recordando dónde guardaste cada material y comparas precios de un vistazo.",
        },
        {
            id = "gold_reserve",
            title = "Control de Reserva de Oro",
            icon = "Interface\\Icons\\inv_misc_coin_02",
            color = "FFD43B",
            desc = "Separa tu capital de ahorro (montura a nivel 40 y habilidades maestras) de tu saldo diario de gastos, creando una barrera psicológica contra compras impulsivas.",
        },
        {
            id = "less_downtime",
            title = "Cero Pérdida de Tiempo",
            icon = "Interface\\Icons\\spell_nature_timestop",
            color = "FF6B6B",
            desc = "Evita viajes largos y costosos a capitales. Deposita tus excedentes en cualquier buzón rural de pueblo mediante correo instantáneo entre personajes de tu cuenta.",
        },
    },

    -- REGLAS DE ORO DE GESTIÓN (7 SECCIONES ESTRATÉGICAS)
    rules = {
        {
            num = 1,
            title = "Envío Preventivo de Materiales",
            tag = "Inventario Activo",
            tagColor = "48C5C5",
            desc = "Recolectar menas, hierbas, cueros y telas durante el leveleo consume espacio rápidamente. Envía estos materiales a tu Bank Alt desde cualquier buzón antes de saturar tus bolsas, evitando tener que tirar objetos valiosos en medio del bosque.",
        },
        {
            num = 2,
            title = "Ventas Centralizadas en un Solo Personaje",
            tag = "Eficiencia de Mercado",
            tagColor = "C8A2FF",
            desc = "Tu personaje principal no debe detener una sesión productiva de mazmorras solo porque tiene 1 stack de lana listo para subasta. Un único vendedor almacena los lotes, compara precios y recolecta el oro de las ventas exitosas.",
        },
        {
            num = 3,
            title = "Separación Psicológica de la Reserva de Oro",
            tag = "Ahorro para Montura",
            tagColor = "FFD43B",
            desc = "Si llevas todo tu oro en el personaje principal, cualquier arma verde o mejora tentadora en subasta parecerá accesible. Al transferir el 70-80% de tus ahorros al alter, tu saldo de gasto diario se mantiene estricto y aseguras el oro para nivel 40.",
        },
        {
            num = 4,
            title = "No lo Conviertas en un Basurero",
            tag = "Organización",
            tagColor = "FF6B6B",
            desc = "Un alter de almacenamiento solo ahorra tiempo si está ordenado. Vende la basura gris y barata a los vendedores PNJs de inmediato. Solo envía lo que tenga valor real de subasta o utilidad artesanal confirmada.",
        },
        {
            num = 5,
            title = "Especulación y Retención Selectiva",
            tag = "Economía de Lanzamiento",
            tagColor = "48C5C5",
            desc = "Ciertos materiales conviene venderlos en la semana 1 por alta demanda inmediata, mientras que otros aumentarán de precio cuando los jugadores avancen sus profesiones. Guarda solo aquello cuya proyección de valor justifique ocupar casillas de banco.",
        },
        {
            num = 6,
            title = "Protección de BoEs Valiosos",
            tag = "Comercio Inteligente",
            tagColor = "C8A2FF",
            desc = "Un objeto que se liga al equipar (BoE) a menudo vale mucho más como oro en subasta que como una mejora transitoria de 2 niveles para tu personaje. Envíalo al banco para revisar su precio antes de equiparlo por impulso.",
        },
        {
            num = 7,
            title = "Revisión en Horarios Fijos (No Constante)",
            tag = "Disciplina de Sesión",
            tagColor = "FFD43B",
            desc = "La microgestión constante arruina el ritmo de leveleo. Establece un horario fijo: revisa tu Bank Alt y la Casa de Subastas solo al inicio o al final de tu sesión de juego (10-15 min dedicados), nunca en mitad de una ruta de misiones.",
        },
    },

    -- MATRIZ DE CLASIFICACIÓN DE OBJETOS
    inventoryMatrix = {
        {
            itemType = "Materiales de Recolección",
            action = "Almacenar o Listar en Subasta",
            reason = "Mantiene el inventario de leveleo limpio sin desperdiciar recursos artesanales.",
            color = "48C5C5",
            icon = "Interface\\Icons\\inv_misc_gem_bloodstone_01",
        },
        {
            itemType = "Equipo BoE Valioso",
            action = "Comprobar Valor en Subasta",
            reason = "Permite comparar su valor de venta contra su utilidad antes de ligarlo por impulso.",
            color = "C8A2FF",
            icon = "Interface\\Icons\\inv_sword_04",
        },
        {
            itemType = "Reserva de Oro",
            action = "Mantener Separado en el Alter",
            reason = "Evita gastos impulsivos en mejoras efímeras y asegura el oro de montura para nivel 40.",
            color = "FFD43B",
            icon = "Interface\\Icons\\inv_misc_coin_02",
        },
        {
            itemType = "Objetos de Bajo Valor / Basura",
            action = "Vender a PNJ Inmediatamente",
            reason = "Evita saturar el banco y el buzón con morralla que solo aporta unos pocos cobres.",
            color = "FF6B6B",
            icon = "Interface\\Icons\\inv_misc_bone_01",
        },
        {
            itemType = "Materiales Especulativos",
            action = "Guardar Selectivamente",
            reason = "Conserva reactivos clave hasta que la economía del servidor madure y paguen más.",
            color = "00FFCC",
            icon = "Interface\\Icons\\inv_fabric_silk_01",
        },
    },

    -- PREGUNTAS FRECUENTES (FAQ)
    faq = {
        {
            q = "¿Cuándo debo crear mi Bank Alt en WoW Forever?",
            a = "Desde el primer día. Crea un personaje secundario inmediatamente, camina a la capital más cercana y estaciónalo junto al Banco, Buzón y Casa de Subastas. Cuanto antes lo tengas, antes empezarás a ahorrar tiempo.",
            color = "48C5C5",
        },
        {
            q = "¿Cuál es la mejor raza y ciudad para un Bank Alt?",
            a = "En la Alianza: Humano en Ventormenta o Enano en Forjaz por su cercanía inmediata entre buzón y subasta. En la Horda: Tauren en Cima del Trueno es la mejor opción del juego (el banco, la subasta y el buzón están al aire libre a 5 metros de distancia y puedes montar).",
            color = "C8A2FF",
        },
        {
            q = "¿Cómo me ayuda a ahorrar para la montura de nivel 40?",
            a = "La mayor causa de falta de oro a nivel 40 son las compras innecesarias de armaduras verdes en subasta durante el leveleo. Separar el 80% de tus ahorros en el alter crea una barrera física y mental contra las compras impulsivas.",
            color = "FFD43B",
        },
        {
            q = "¿Cómo funciona el correo entre personajes de mi cuenta?",
            a = "En WoW Forever, el correo entre personajes de la misma cuenta de juego es instantáneo. Puedes enviar hasta 12 objetos por carta desde cualquier buzón del mundo y retirarlos de inmediato en tu Bank Alt sin tiempo de espera.",
            color = "48C5C5",
        },
        {
            q = "¿Cuántas bolsas y casillas de banco necesito?",
            a = "Empieza con 4 bolsas de 6 u 8 casillas económicas. Con las primeras ganancias de subasta, compra las primeras 2 o 3 casillas de banco para clasificar tus contenedores (un bolso para telas, otro para menas y otro para BoEs).",
            color = "C8A2FF",
        },
    },
}
