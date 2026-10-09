# 📜 Manual de Secretos, Cadenas y Guías Contextuales — Awakening: Companion

> **Documento de arquitectura técnica, estándares de diseño, modelos de datos y manual de extensión para asistentes y desarrolladores de Antigravity IDE.**

---

## 1. Filosofía de Diseño: "Cero Ruido e Información Oportuna"

El catálogo de **Guías & Secretos** en Awakening Companion no es una lista estática tradicional de misiones. Funciona como un **sistema de recomendación contextual activo y centro editorial interactivo** dividido en tres grandes familias:

1. **Relevancia por Nivel y Progresión:** Una guía o secreto solo se presenta de forma destacada al jugador cuando este se encuentra en la ventana óptima de nivel o habilidad para aprovecharla.
2. **Cero Saturación en Niveles Altos:** Misiones de leveleo temprano (como el *Saco de Dormir Acogedor*, óptimo entre niveles 14 y 28) se ocultan automáticamente si el personaje ya superó el rango o es nivel 60, evitando saturar la interfaz con contenido obsoleto, a menos que el usuario marque explícitamente la casilla *"Mostrar secretos antiguos"*.
3. **Detección Dinámica de Profesiones:** Las guías vinculadas a recetas, libros de aprendizaje o hitos de habilidad solo se activan cuando el jugador posee la profesión y su rango se aproxima al límite de entrenamiento.
4. **Auto-Descarte Definitivo (`autoHideCompleted`):** Ciertas guías (como comprar el libro *Cocina para expertos*) pierden todo sentido una vez aprendidas; en cuanto el jugador alcanza la habilidad superior o usa el libro, la guía desaparece de forma permanente.
5. **Arquitectura Editorial Tripartita:**
   - **Secretos & Rutas:** Cadenas de misiones de exploración intercontinental, hitos secuenciales y recompensas únicas navegables paso a paso con compás 3D y HUD.
   - **Mazmorras 5-Jug:** Guías editoriales completas estilo Wowhead con resumen, mapa de viaje en tiempo real, catálogo de misiones, tácticas de jefes y tabla de botín.
   - **Consejos Forever:** Guías estratégicas de economía, inventario, diferencias de motor y mecánicas de juego con interfaces interactivas en modo HD, matrices de decisión y checklists persistentes.

---

## 2. Taxonomía de Interfaz y Navegación en MainUI

La interfaz principal en [Modules/MainUI.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Modules/MainUI.lua) organiza el catálogo de guías mediante una barra superior de sub-pestañas pill y una botonera de filtros chips:

### 2.1 Sub-Pestañas Temáticas (`SECRETS_SUBTABS`)
Ubicadas en la parte superior del listado para segmentar el contenido según la intención del jugador:

```lua
local SECRETS_SUBTABS = {
    { id = "secrets",  text = "Secretos & Rutas", icon = "Interface\\Icons\\inv_misc_bag_07" },
    { id = "dungeons", text = "Mazmorras 5-Jug",  icon = "Interface\\Icons\\inv_helmet_08" },
    { id = "tips",     text = "Consejos Forever", icon = "Interface\\Icons\\spell_holy_magicalsentry" },
}
```

* **`secrets` (Secretos & Rutas):** Misiones canónicas de exploración y habilidades especiales (*Saco de Dormir*, *Cocina para expertos*, *Tomos de la Biblioteca*).
* **`dungeons` (Mazmorras 5-Jug):** Fichas de mazmorras de Azeroth (*Sitio de Excavación: Los Humedales*, etc.).
* **`tips` (Consejos Forever):** Artículos estratégicos (*Consejos para Principiantes*, *Gestión de Oro y Bank Alt*).

### 2.2 Filtros Horizontales por Chips (`SECRETS_FILTERS`)
Permiten filtrar dinámicamente las filas visibles en la sub-pestaña seleccionada:

```lua
local SECRETS_FILTERS = {
    { id = "all",       text = "Todos" },
    { id = "level",     text = "Mi Nivel" },
    { id = "pending",   text = "Por Descubrir" },
    { id = "completed", text = "Completados" },
}
```

* **`all`:** Muestra todas las guías de la categoría que no hayan sido suprimidas por reglas estrictas.
* **`level`:** Muestra únicamente guías donde el nivel actual del jugador (`UnitLevel("player")`) esté entre `minLevel` y `maxLevel`.
* **`pending`:** Filtra guías no completadas (`isCompleted == false`).
* **`completed`:** Muestra exclusivamente el historial de guías culminadas con éxito.

### 2.3 Medidor Semafórico Superior (Hero Progress Bar)
La cabecera de la vista de secretos incorpora una barra de progreso de alto contraste que calcula dinámicamente:
* Conteo de guías completadas vs totales (`completedCount / totalCount`).
* Porcentaje de progreso (`pct%`) con barra de degradado dorado/verde (`Interface\\Buttons\\WHITE8x8`).
* Etiqueta de resumen conciso: `"X de Y Secretos Descubiertos (Z%)"`.

### 2.4 Botones Adaptativos de la Barra Inferior
Según el elemento seleccionado, los botones de acción inferior (`MainUI:UpdateBottomButtons`) adaptan su texto y funcionalidad:

| Tipo de Entrada | Botón 1 (`OnActionButton1`) | Botón 2 (`OnActionButton2`) | Botón 3 (`OnActionButton3`) |
| :--- | :--- | :--- | :--- |
| **Secreto con Pasos** | `Iniciar Ruta` (Abre GuideHUD / TomTom) | `Planificar Viaje` (Abre pestaña Viajes) | `Habilidades` |
| **Mazmorra 5-Jug** | `Iniciar Ruta` (Coord. Entrada) | `Ver Guía` (Abre GuideViewer HD) | `Habilidades` |
| **Artículo Estratégico** | `Leer Guía` (Abre GuideViewer HD) | `Modo HD` (Abre GuideViewer HD) | `Habilidades` |

---

## 3. Arquitectura y Modelos de Datos

El archivo maestro [Data/SecretsData.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Data/SecretsData.lua) y los archivos complementarios de datos modelan tres esquemas principales:

### 3.1 Modelo de Secreto de Pasos Tradicional
Utilizado para secretos lineales de viaje y obtención de objetos:

```lua
ns.Data.Secrets["clave_secreto"] = {
    -- 1. Metadatos de Identificación
    id = "clave_secreto",
    title = "Título Descriptivo en Español",
    titleEn = "English Original Name (para búsquedas)",
    category = "Secreto Clásico" | "Habilidad de Profesión" | "Cofre Oculto" | "Runas & Poder",
    faction = "Alliance" | "Horde" | "Ambas",
    icon = "Interface\\Icons\\inv_misc_book_11",

    -- 2. Restricciones de Nivel de Personaje
    level = "Nivel 20 - 45",
    minLevel = 20,       -- Nivel mínimo del jugador para que el secreto aparezca
    maxLevel = 45,       -- Nivel máximo tras el cual se considera "antiguo" o se oculta

    -- 3. Restricciones de Profesión y Habilidad (Opcional)
    requiredProfession = "Cooking", -- Clave normalizada de profesión
    minSkill = 125,                  -- Habilidad mínima para mostrar la recomendación
    maxSkill = 150,                  -- Habilidad máxima antes de considerarla completada
    targetSkill = 225,               -- Habilidad objetivo desbloqueada
    autoHideCompleted = true,        -- Si es true, desaparece por completo al completarse

    -- 4. Recompensas e Inspección Visual
    reward = "Resumen conciso de la recompensa",
    rewardItems = {
        {
            itemID = 16072,
            name = "Cocina para expertos",
            quality = 1,
            icon = "Interface\\Icons\\inv_misc_book_11",
            desc = "Libro que enseña el rango Experto de cocina hasta nivel 225."
        }
    },

    -- 5. Secuencia de Pasos
    steps = stepsTable, -- Tabla de pasos o asignación dinámica por facción
}
```

### 3.2 Esquema de Pasos de Viaje (`steps`)
Cada hito dentro de un secreto lineal define coordenadas geográficas y metadatos para el compás 3D:

```lua
{
    stepNum = 1,
    title = "1. Título Conciso del Hito",
    instruction = "Explicación directa de la acción que debe realizar el jugador.",
    uiMapID = 1440,          -- ID oficial de mapa del cliente de WoW (C_Map)
    zoneName = "Vallefresno", -- Nombre de la zona legible
    x = 50.2, y = 67.1,      -- Coordenadas normalizadas (0 a 100)
    npcName = "Nombre del PNJ", -- PNJ o mercader con quien interactuar (si aplica)
    itemID = 16072,          -- ID de objeto para despojar, comprar o usar
    questID = 79008,         -- ID de misión para aceptar o comprobar en el QuestLog
    nextQuestID = 79192,     -- ID de misión subsiguiente
    action = "Comprar libro / Aceptar misión",
    tip = "Consejo estratégico o referencia visual del terreno.",
    icon = "Interface\\Icons\\spell_fire_fire",
    isMilestone = true,      -- true si representa un hito clave de misión
    milestone = 1,           -- Número de hito dentro de la cadena (1..N)
}
```

### 3.3 Modelo Editorial de Mazmorra (`category = "Guía"`)
Estructurado para representar contenido complejo de mazmorras de 5 jugadores consumido por el Visor HD:

```lua
ns.Data.Secrets["excavation_site"] = {
    id = "excavation_site",
    title = "Sitio de Excavación: Los Humedales",
    category = "Guía",
    subCategory = "Mazmorra",
    dungeonType = "dungeon",
    faction = "Ambas",
    level = "Nivel 24 - 30",
    minLevel = 24,
    maxLevel = 30,
    icon = "Interface\\Icons\\inv_helmet_08",
    reward = "Equipo azul raro, misiones de mazmorra y XP masiva",
    rewardItems = { ... },
    steps = {
        {
            stepNum = 1,
            title = "1. Entrada a la Mazmorra",
            instruction = "Dirígete a la entrada del Sitio de Excavación al este de Los Humedales.",
            uiMapID = 1437,
            zoneName = "Los Humedales",
            x = 56.2, y = 40.6,
        }
    },
    guideViewerData = {
        summary = { ... },
        quests = { ... },
        bosses = { ... },
        loot = { ... }
    }
}
```

### 3.4 Modelo de Artículos y Consejos Estratégicos (`isArticle = true`)
Diseñado para guías no lineales centradas en lectura, checklists interactivos y matrices económicas:

```lua
ns.Data.Secrets["beginners_guide"] = {
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
    isArticle = true,
    articleDataKey = "BeginnersGuide", -- Apunta a ns.Data.BeginnersGuide
    badge = "GUÍA OFICIAL FOREVER",
    reward = "7 capítulos: diferencias críticas, checklist interactivo y 10 errores comunes",
}
```

La información detallada de cada artículo se aloja en su archivo modular independiente:
* [Data/BeginnersGuideData.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Data/BeginnersGuideData.lua) -> `ns.Data.BeginnersGuide`
* [Data/BankAltGuideData.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Data/BankAltGuideData.lua) -> `ns.Data.BankAltGuide`

---

## 4. Arquitectura Híbrida: Canónica + Dinámica (TravelPlanner)

Para secretos y rutas de viaje que implican transitar largas distancias o cruzar continentes, Awakening Companion utiliza un despachador híbrido:

```
                  ┌──────────────────────────────────────────────┐
                  │          Jugador inicia un Secreto           │
                  │        (Botón "Iniciar Ruta" o Doble Clic)   │
                  └──────────────────────┬───────────────────────┘
                                         │
                         ¿Dónde está el jugador?
                                         │
                  ┌──────────────────────┴──────────────────────┐
                  │                                             │
      [Misma zona y < 1200 yardas]               [Otra zona o continente]
                  │                                             │
                  ▼                                             ▼
       Guía Local Inmediata                      Llamada a TravelPlanner
    Enfocada directamente en el            CalculateRoute("__player__", targetStep)
        hito de la misión.                                      │
                  │                                             ▼
                  │                              Ruta Multimodal Calculada:
                  │                              1. Caminata al vuelo/puerto
                  │                              2. Vuelo / Barco / Tranvía
                  │                              3. Caminata final
                  │                                             │
                  │                              Coronación de la ruta con el
                  │                              Hito Enriquecido de la misión
                  │                                             │
                  └──────────────────────┬──────────────────────┘
                                         │
                                         ▼
                             ns.GuideHUD:StartRoute
                       • Crazy Arrow 3D de TomTom
                       • Pines en mapa y minimapa
                       • Auto-avance por proximidad
                       • Detección de carga de barco
```

### Funciones Clave del Motor
1. **`ns.GetSecretMilestoneTargetStep(secretKey, milestone)`:** Resuelve el objeto paso exacto del hito objetivo de misión, desacoplando la comprobación de progreso (`1..N`) de los pasos intermedios de transporte.
2. **`ns.GetSecretMilestoneFirstStep(secretKey, milestone)`:** Determina el índice del primer paso del tramo de viaje canónico en caso de fallback offline.
3. **`ns.GetDynamicSecretGuide(secretKey, curMilestone)`:** Evalúa la posición en tiempo real del jugador (`__player__`). Si se encuentra distante, invoca a `TravelPlanner:CalculateRoute` para generar una combinación multimodal de transportes personalizada y complementada con la entrega de la misión.

---

## 5. Casos de Estudio Implementados

### Caso 1: Saco de Dormir Acogedor (`sleeping_bag`)
* **Propósito:** Cadena de misiones de exploración intercontinental que otorga el Saco de Dormir (+3% Exp descansada), Fiambrera (bolsa de 12 casillas) y 8x Forraje de Estudiante (+32 barras de descanso).
* **Nivel Recomendado:** `minLevel = 14`, `maxLevel = 28`.
* **Comportamiento por Nivel:** Un personaje de nivel 60 ya no requiere Exp descansada de leveleo; el secreto se oculta automáticamente por defecto y solo se muestra si el usuario activa la casilla *"Mostrar secretos antiguos"*.
* **Articulación de Pasos:** 16 pasos completos (7 hitos de misión + tramos de transporte como el Puerto de Ventormenta, Barco a Auberdine, Paso de los Carromatos, Túneles de Dun Algaz, Viaducto Thandol y Muralla de Thoradin).

---

### Caso 2: Cocina para Expertos (`expert_cooking`)
* **Propósito:** Guía para obtener el libro *Cocina para expertos* (ID `#16072`) que desbloquea el límite de cocina hasta 225, ya que en WoW Clásico ningún instructor entrena este rango.
* **Nivel Recomendado:** `minLevel = 20`, `maxLevel = 45`.
* **Filtro de Profesión:** `requiredProfession = "Cooking"`, `minSkill = 125`, `maxSkill = 150`.
* **Comportamiento Dinámico:**
  1. Si el jugador no tiene Cocina o su habilidad es `< 125`, la guía no aparece para no distraerlo.
  2. Si su habilidad está entre `125` y `150`, la guía aparece recomendándole comprar el libro antes de topar su límite.
  3. Si ya tiene el libro en sus bolsas (`PlayerHasItem(16072)`), la guía avanza automáticamente al Paso 2: *"Usar libro en inventario"*.
  4. Si su habilidad supera `150` o su límite máximo ya es `225` (`maxRank > 150`), el secreto se marca como completado y **se oculta permanentemente** (`autoHideCompleted = true`).
* **PNJ por Facción:**
  * **Alianza:** Shandrina en Vallefresno (Lago Mystral, `50.2, 67.1`, mapa `1440`).
  * **Horda:** Wulan en Desolace (Aldea Cazasombras, `26.2, 69.8`, mapa `1443`).

---

### Caso 3: Tomos de la Biblioteca (`library_books`) — Collecting Library Books (WoW Forever)
* **Propósito:** Búsqueda y recolección de tomos antiguos, diarios de investigación y pergaminos esparcidos por todo Azeroth para entregarlos al Bibliotecario de Facción. En WoW Forever esta característica se expandió a todas las clases y cuenta con un sistema escalonado de 3 Tiers con recompensas de equipo y una bonificación exclusiva para magos (*Study*).
* **Nivel Recomendado:** `minLevel = 20`, `maxLevel = 60`.
* **Bibliotecarios de Facción (Puntos de Entrega):**
  * **Alianza:** Garion Wendell (`npc=211033`), Torre de los Magos, Ciudad de Ventormenta (`49.0, 86.4`, mapa `1453`).
  * **Horda:** Owen Thadd (`npc=211022`), Barrio de la Magia, Entrañas (`74.0, 32.4`, mapa `1458`).
* **Estructura Escalonada de Tiers y Recompensas:**
  
  | Tier | Libros Requeridos | Misión Oficial | Recompensas a Elegir |
  | :---: | :---: | :---: | :--- |
  | **Tier 1** | **10 Libros** | `#78150` *Friend of the Library* | • **Colgante de erudito** (`277203`): +3 Aguante, +2 Espíritu<br>• **Amuleto de erudito** (`277204`): +2 Agilidad, +3 Aguante |
  | **Tier 2** | **20 Libros** | `#79536` *Greater Friend of the Library* | • **Sortija del investigador de campo** (`281634`): +7 Agilidad, +7 Aguante<br>• **Anillo de filántropo** (`281635`): +5 Intelecto, +10 Daño/Sanación |
  | **Tier 3** | **25 Libros** | `#82208` *Greater Friend of the Library* | • **Arco del buscador de la verdad** (`277254`): +7 Agilidad, +3 Aguante<br>• **Blasón de elucidación** (`277258`): Escudo 1580 Armadura, +12 Espíritu, +7 Sanación<br>• **Luz nocturna del investigador** (`277260`): +12 Aguante, +7 Hechizos de Fuego |

* **Lógica de Comportamiento Dinámico y Progresión:**
  1. **Escaneo de Bolsas e Historial:** Comprueba libros en posesión (`PlayerHasItem`) y misiones completadas (`IsQuestCompleted`), acumulando `collectedCount`.
  2. **Determinación del Tier Activo:**
     - Si `#82208` está completada: marca 100% (`25/25 Libros`).
     - Si `#79536` está completada: objetivo Tier 3 (25 libros). Si `collectedCount >= 25`, conmuta al bibliotecario.
     - Si `#78150` está completada: objetivo Tier 2 (20 libros). Si `collectedCount >= 20`, conmuta al bibliotecario.
     - Por defecto: objetivo Tier 1 (10 libros). Si `collectedCount >= 10`, conmuta al bibliotecario.
  3. **Catálogo Maestro:** 40 ubicaciones canónicas en Azeroth filtradas por facción para evitar dirigir a jugadores a ciudades enemigas.

---

### Caso 4: Sitio de Excavación: Los Humedales (`excavation_site`) — Guía de Mazmorra Wowhead
* **Propósito:** Guía completa de la mazmorra de 5 jugadores (nivel 24-30) de World of Warcraft: Forever, ubicada en la excavación arqueológica al este de Los Humedales (`56.2, 40.6`).
* **Categoría Cardinal (`category = "Guía"`, `subCategory = "Mazmorra"`):**
  Activa la interfaz horizontal de alta fidelidad **`GuideViewer`** (`820 x 540` px) con las 4 pestañas de mazmorra (`DUNGEON_TAB_DEFS`):
  1. **Resumen & Viaje:** Ficha técnica y panel dinámico en vivo con `TravelPlanner:CalculateRoute("__player__", entrance)`.
  2. **Misiones de Mazmorra:** Las 6 misiones con PNJs dadores, coordenadas `/way`, prerrequisitos y tooltips nativos.
  3. **Jefes & Tácticas:** Peligros de trash (emboscadas Pokémon) y los 3 jefes (*Saltspine*, *Shadetooth* y *Relic Guardian*).
  4. **Tabla de Botín (Loot):** Grid de 10 objetos con marcos de calidad e inspección vía `GameTooltip:SetItemByID`.

---

### Caso 5: Consejos para Principiantes (`beginners_guide`) — Odealo.com
* **Propósito:** Guía estratégica indispensable para iniciar en WoW Forever. Explica los sistemas permanentes del motor, los cambios radicales de balance y previene errores costosos en la economía temprana.
* **Modelo de Datos:** [Data/BeginnersGuideData.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Data/BeginnersGuideData.lua) (`ns.Data.BeginnersGuide`).
* **Pestañas en el Visor HD (`ARTICLE_TAB_DEFS`):**
  1. **Diferencias Críticas:** Comparativa tabular interactiva entre WoW Classic y WoW Forever:
     - *Leveleo & Rutas:* Más de 1,000 nuevas misiones y zonas rediseñadas.
     - *Profesiones:* Más de 600 recetas nuevas; vital subirlas desde nivel 1 para campamentos y planos.
     - *Fogones & Campamentos:* Bufos de 1 hora de descanso y estaciones de trabajo compartidas.
     - *Mazmorras:* 80% de la experiencia proviene de misiones, no de grindear criaturas en bucle.
     - *Estadísticas:* Unificación de Golpe y Crítico; necesidad crucial de Poder con Hechizos.
  2. **La Primera Hora (Checklist de 6 Pasos):** Checklist con checkboxes interactivos y persistencia en `AwakeningDB.firstHourChecks[stepId]`:
     - *Paso 1:* Configuración de interfaz, barras y asignación de teclas.
     - *Paso 2:* Compra de primeras habilidades y balance de maná.
     - *Paso 3:* Uso del Fogón Portátil (`Campfire`) para el bufo de descanso.
     - *Paso 4:* Adquisición de profesiones primarias y secundarias.
     - *Paso 5:* Obtención de bolsas económicas de 6 casillas.
     - *Paso 6:* Vinculación de la Piedra de Hogar en la taberna local.
  3. **Profesiones & Fogón:** Guía de parejas de profesiones recomendadas (Minería/Ingeniería, Desuello/Peletería, etc.) y la regla del nivel 10/habilidad 20.
  4. **10 Errores Comunes:** Lista de los 10 hábitos obsoletos de Classic que arruinan la experiencia en Forever y cómo superarlos.

---

### Caso 6: Gestión de Oro y Bank Alt (`bank_alt_guide`) — LootWoW Launch Economy
* **Propósito:** Guía de economía y administración de inventario diseñada para proteger el tiempo de juego del personaje principal durante el lanzamiento de WoW Forever.
* **Modelo de Datos:** [Data/BankAltGuideData.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Data/BankAltGuideData.lua) (`ns.Data.BankAltGuide`).
* **Pestañas en el Visor HD (`BANK_ALT_TAB_DEFS`):**
  1. **4 Pilares Fundamentales:**
     - *Bolsas de Leveleo Limpias:* Cero casillas ocupadas por reactivos o menas en el personaje principal.
     - *Subasta Centralizada:* Un único personaje gestiona ventas, ahorrando cancelaciones y traslados.
     - *Control de Reserva de Oro:* El 80% de los ahorros se mantiene en el alter para garantizar el oro de la montura a nivel 40.
     - *Cero Pérdida de Tiempo:* El correo entre personajes de la misma cuenta es instantáneo en WoW Forever.
  2. **7 Reglas de Oro de Gestión:**
     - Regla 1: Envío preventivo de materiales desde cualquier buzón rural.
     - Regla 2: Ventas centralizadas en un solo personaje.
     - Regla 3: Separación psicológica de la rese      | **Reserva de Oro** | Mantener Separado en Alter | Barrera psicológica contra compras impulsivas. |
      | **Objetos de Bajo Valor / Basura** | Vender a PNJ Inmediatamente | Evita pagar costes de correo y saturar casillas. |
      | **Materiales Especulativos** | Guardar Selectivamente | Espera a que maduren las profesiones del servidor. |

   4. **Preguntas Frecuentes (FAQ):** Selección óptima de raza/ciudad (Tauren en Cima del Trueno como la mejor opción por proximidad banco-subasta-buzón), costes de casillas y correo entre cuentas.

---

### Caso 7: Guía de Puntos y Talentos Legacy (`legacy_talents_guide`) — Method.gg
* **Propósito:** Guía estratégica basada en el análisis y plantillas de Method.gg para optimizar la progresión a nivel de cuenta (Account-wide). Explica cómo distribuir hasta 16 Puntos Legacy en los 3 árboles al lanzamiento.
* **Modelo de Datos:** [Data/LegacyTalentsGuideData.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Data/LegacyTalentsGuideData.lua) (`ns.Data.LegacyTalentsGuide`).
* **Pestañas en el Visor HD (`LEGACY_TAB_DEFS`):**
  1. **Fundamentos & 3 Árboles (`legacy_overview`):**
     - *Progresión de Cuenta:* Los puntos se desbloquean a nivel de cuenta, pero cada personaje los gasta y especializa según su rol (leveled, recolector, crafter o raider).
     - *Límite de 16 Puntos:* Al lanzamiento se dispone de hasta 16 puntos. Desbloquear un talento capstone exige 10 puntos en el árbol + 1 punto final (11 en total).
     - *Reseteo en Instructor:* Reajuste disponible en cualquier instructor de clase en capitales por 10 de Oro.
     - *Los 3 Árboles:* Aventura (leveleo/regeneración), Profesiones (recolección/crafteo) e Ingenio (reputación, coste de consumibles y durabilidad).
  2. **El Gran Debate: Thrill vs Talented (`legacy_debate`):**
     - *Thrill of Adventure:* 1% a 5% de regeneración de salud y maná durante 10s tras matar un objetivo no trivial en mundo abierto. Veredicto de Method: Opción #1 para leveleo fluido con cero paradas.
     - *Talented:* Puntos de talento normales otorgados hasta 5 niveles antes (51 talentos a nivel 55). Veredicto de Method: Poder devastador en PvP de mundo abierto, pero requiere 10 puntos totales (5 en Well Rested) y a nivel 60 pierde su efecto, exigiendo un reseteo de 10g.
  3. **Las 5 Builds del Meta Method (`legacy_builds`):**
     - *Build 1: Speed Leveling (16 Aventura):* 5 Thrill of Adventure + 5 Well Rested + 5 Talented + 1 Field Medicine.
     - *Build 2: Crafter / Artesano (11 Aventura / 5 Profesiones):* 5 Thrill of Adventure + 5 Working Overtime + Field Medicine / Frequent Flier.
     - *Build 3: Gatherer Alt / Recolector (15 Profesiones / 1 Ingenio):* 5 Bountiful Harvest (+100% materiales escasos: Pristine Leather, Pyrite) + 5 Bartering + Dedicated Study (Esencia Elemental diaria al 300) + Master Chef / Luremaster.
     - *Build 4: PvP Meta (11 Ingenio / 5 Aventura):* For Great Honor (+10% Honor) + Diplomat (+10% Reputación en BGs) + High Alert (Detección de Sigilo en exteriores) + Thrill / Talented.
     - *Build 5: Raiding & Mazmorras (16 Ingenio):* Reinforce (reducción sustancial de facturas de reparación por wipes) + Diplomat (+Reputación de Raid) + The Quick and the Dead (mayor velocidad de carrera como espíritu) + Reagent Economy & Gourmand (duración extendida de comidas y bufos).
  4. **Catálogo de Talentos Clave (`legacy_talents`):** Grid de dos columnas con costes, requisitos y efectos desglosados de los talentos más influyentes.

---

## 6. Arquitectura del Visor Interactivo HD (`GuideViewer.lua`)

El módulo [Modules/GuideViewer.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Modules/GuideViewer.lua) implementa una ventana flotante de alta resolución (`820 x 540` px) diseñada con la estética de **Chairfaces Casino**:

```
┌──────────────────────────────────────────────────────────────────────────────┐
│ [Crest]  TÍTULO DE LA GUÍA                                       [X Cerrar]  │
│          Subtítulo descriptivo y metadatos del artículo                      │
├──────────────────────────────────────────────────────────────────────────────┤
│ [ Tab 1: Píldora ]   [ Tab 2: Píldora ]   [ Tab 3: Píldora ]   [ Tab 4: Píldora ] │
├──────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│                               ÁREA DE CONTENIDO                              │
│             (ScrollFrame adaptativo con paneles temáticos en vivo)           │
│                                                                              │
├──────────────────────────────────────────────────────────────────────────────┤
│ [ Iniciar Navegación HUD ]   [ Marcar en TomTom ]              [ Cerrar ]    │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 6.1 Conmutación Dinámica de Conjuntos de Pestañas
El método `GV:SetupTabsForGuide(guideKey)` analiza el `id` y los metadatos de la guía seleccionada para configurar al vuelo la botonera de 4 pestañas:

```lua
local isBankAlt = (guideKey == "bank_alt_guide")
local isLegacy = (guideKey == "legacy_talents_guide")
local isArticle = (guideKey == "beginners_guide") or (ns.Data.Secrets and ns.Data.Secrets[guideKey] and ns.Data.Secrets[guideKey].isArticle and not isBankAlt and not isLegacy)

local defs = isBankAlt and BANK_ALT_TAB_DEFS or (isLegacy and LEGACY_TAB_DEFS or (isArticle and ARTICLE_TAB_DEFS or DUNGEON_TAB_DEFS))
```

* **`DUNGEON_TAB_DEFS`:** Resumen & Viaje, Misiones de Mazmorra, Jefes & Tácticas, Tabla de Botín.
* **`ARTICLE_TAB_DEFS`:** Diferencias Classic, La Primera Hora, Profesiones & Fogón, 10 Errores a Evitar.
* **`BANK_ALT_TAB_DEFS`:** Fundamentos & Pilares, Reglas de Gestión, Matriz de Inventario, Preguntas Frecuentes.
* **`LEGACY_TAB_DEFS`:** Fundamentos & Árboles, Thrill vs Talented, 5 Builds Method, Talentos Clave.

### 6.2 Persistencia de Checklists Interactivos
En artículos interactivos (como el Checklist de Primera Hora), cada fila genera un `CheckButton` vinculado a la base de datos de usuario:

```lua
local isChecked = (AwakeningDB.firstHourChecks and AwakeningDB.firstHourChecks[step.id]) or false
chk:SetChecked(isChecked)
chk:SetScript("OnClick", function(self)
    AwakeningDB.firstHourChecks = AwakeningDB.firstHourChecks or {}
    AwakeningDB.firstHourChecks[step.id] = self:GetChecked()
end)
```

### 6.3 Directrices de Tipografía y Compatibilidad de Caracteres en WoW Classic
Las fuentes nativas del cliente de World of Warcraft (`FRIZQT__.TTF` y `ARIALN.TTF`) cubren exclusivamente caracteres ASCII y el suplemento latino estándar (acentos en español, diéresis, `ñ`, etc.).

> [!WARNING]
> **Prohibido el uso de símbolos Unicode exóticos o emojis:**
> Símbolos como estrellas (`★`, `☆`), emojis (`❓`, `⚔️`, `💰`) o flechas no estándar carecen de glifo en la tipografía de Blizzard y el motor los dibuja como un **rectángulo vertical hueco** (`.notdef` / tofu).
> 
> **Estándar Oficial para Adornos Visuales:**
> 1. Para iconos decorativos en textos, usar secuencias de escape nativas de textura: `|TInterface\Icons\nombre_icono:16:16:0:0|t` o iconos de objetivo de banda `|TInterface\TargetingFrame\UI-RaidTargetingIcon_1:12:12|t`.
> 2. Para viñetas y listas, usar exclusivamente el punto medio ASCII/Latino-1 estándar `•` (`\149` o `\183`) o guiones directos `-`.
> 3. Mantener los títulos de lista de secretos limpios: `row.title:SetText(secret.title)`.

---

## 7. Procedimiento para Agregar Nuevas Guías o Secretos

### Flujo A: Agregar un Secreto de Pasos Tradicional
1. **Definir Pasos en [Data/SecretsData.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Data/SecretsData.lua):** Declarar la tabla `ns.Data.MiNuevoSecretoSteps` con sus coordenadas y objetivos.
2. **Registrar en `ns.Data.Secrets`:** Añadir la clave a `ns.Data.Secrets["mi_nuevo_secreto"]`.
3. **Definir Progreso en `ns.GetSecretProgress`:** Especificar la condición de completado (`IsQuestCompleted` o `PlayerHasItem`).
4. **Registrar Orden en [Modules/MainUI.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Modules/MainUI.lua):** Añadir la clave al arreglo `secretsOrder`.

### Flujo B: Agregar un Artículo Estratégico o Consejos
1. **Crear Archivo de Datos en `Data/MiGuiaData.lua`:** Declarar la tabla estructurada (metadatos, capítulos, tablas o listas).
2. **Registrar en [AwakeningCompanion.toc](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/AwakeningCompanion.toc):** Incluir la ruta del archivo de datos antes de `Data/SecretsData.lua`.
3. **Registrar en `ns.Data.Secrets`:**
   ```lua
   ns.Data.Secrets["mi_nueva_guia"] = {
       id = "mi_nueva_guia",
       title = "Título del Artículo",
       category = "Consejos",
       isArticle = true,
       articleDataKey = "MiGuiaData",
       icon = "Interface\\Icons\\inv_misc_book_02",
       ...
   }
   ```
4. **Crear Paneles y Pestañas en [Modules/GuideViewer.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Modules/GuideViewer.lua):** Definir el conjunto `MI_GUIA_TAB_DEFS` y sus constructores de panel.
5. **Validar Sintaxis Lua:**
   ```bash
   python3 tools/validate_lua.py Data/MiGuiaData.lua
   python3 tools/validate_lua.py Modules/GuideViewer.lua
   ```
6. **Empaquetar y Probar:** Ejecutar `tools/package_release.sh` y recargar el cliente con `/reload`.

