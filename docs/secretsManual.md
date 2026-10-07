# 📜 Manual de Secretos, Cadenas y Guías Contextuales — Awakening: Companion

> **Documento de arquitectura técnica, estándares de diseño y manual de extensión para asistentes y desarrolladores de Antigravity IDE.**

---

## 1. Filosofía de Diseño: "Cero Ruido e Información Oportuna"

El catálogo de **Guías & Secretos** en Awakening Companion no es una lista estática tradicional de misiones. Funciona como un **sistema de recomendación contextual activo**:

1. **Relevancia por Nivel y Progresión:** Una guía solo se presenta al jugador cuando este se encuentra en la ventana óptima de nivel o habilidad para aprovecharla.
2. **Cero Saturación en Niveles Altos:** Misiones de leveleo temprano (como el *Saco de Dormir Acogedor*, óptimo entre niveles 14 y 28) se ocultan automáticamente si el personaje ya superó el rango o es nivel 60, evitando saturar la interfaz con contenido obsoleto, a menos que el usuario marque explícitamente la casilla *"Mostrar secretos antiguos"*.
3. **Detección Dinámica de Profesiones:** Las guías vinculadas a recetas, libros de aprendizaje o hitos de habilidad solo se activan cuando el jugador posee la profesión y su rango se aproxima al límite de entrenamiento.
4. **Auto-Descarte Definitivo (`autoHideCompleted`):** Ciertas guías (como comprar el libro *Cocina para expertos*) pierden todo sentido una vez aprendidas; en cuanto el jugador alcanza la habilidad superior o usa el libro, la guía desaparece de forma permanente.

---

## 2. Arquitectura de Datos de un Secreto

Cada entrada en `ns.Data.Secrets` se estructura con metadatos de clasificación, restricciones de nivel/profesión, recompensas enriquecidas y la secuencia de pasos:

```lua
ns.Data.Secrets["clave_secreto"] = {
    -- 1. Metadatos de Identificación
    id = "clave_secreto",
    title = "Título Descriptivo en Español",
    titleEn = "English Original Name (para búsquedas)",
    category = "Secreto Clásico" | "Habilidad de Profesión" | "Cofre Oculto" | "Cadena de Mazmorra" | "Runas & Poder",
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

---

## 3. Esquema de Pasos (`steps`)

Cada hito o etapa de viaje dentro de un secreto contiene la información geográfica y contextual necesaria tanto para el catálogo como para el compás 3D y el motor de navegación:

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

---

## 4. Arquitectura Híbrida: Canónica + Dinámica

Awakening Companion combina lo mejor de dos mundos para que el jugador nunca se pierda ni reciba instrucciones incongruentes:

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

1. **`ns.GetSecretMilestoneTargetStep(secretKey, milestone)`:**
   Resuelve el objeto paso exacto del hito objetivo de misión, desacoplando la comprobación de progreso (`1..7`) de la cantidad de pasos de viaje intercontinentales.
2. **`ns.GetSecretMilestoneFirstStep(secretKey, milestone)`:**
   Determina el índice del primer paso del tramo de viaje canónico si se requiere un fallback offline.
3. **`ns.GetDynamicSecretGuide(secretKey, curMilestone)`:**
   Evalúa la posición en tiempo real del jugador (`__player__`). Si se encuentra distante, invoca a `TravelPlanner:CalculateRoute` para generar una combinación multimodal de transportes personalizada y complementada con la entrega de la misión.

---

## 5. Casos de Estudio Implementados

### Caso 1: Saco de Dormir Acogedor (`sleeping_bag`)
* **Propósito:** Cadena de misiones de exploración intercontinental que otorga el Saco de Dormir (+3% Exp descansada), Fiambrera (bolsa de 12 casillas) y 8x Forraje de Estudiante (+32 barras de descanso).
* **Nivel Recomendado:** `minLevel = 14`, `maxLevel = 28`.
* **Comportamiento por Nivel:** Un personaje de nivel 60 ya no requiere Exp descansada de leveleo; el secreto se oculta automáticamente por defecto y solo se muestra si el usuario activa la casilla *"Mostrar secretos antiguos"*.
* **Articulación de Pasos:** 16 pasos completos (7 hitos de misión + tramos de transporte como el Puerto de Ventormenta, Barco a Auberdine, Paso de los Carromatos, Túneles de Dun Algaz, Viaducto Thandol y Muralla de Thoradin).

### Caso 2: Cocina para Expertos (`expert_cooking`)
* **Propósito:** Guía para obtener el libro *Cocina para expertos* (ID `#16072`) que desbloquea el límite de cocina hasta 225, ya que en WoW Clásico ningún instructor entrena este rango.
* **Nivel Recomendado:** `minLevel = 20`, `maxLevel = 45`.
* **Filtro de Profesión:** `requiredProfession = "Cooking"`, `minSkill = 125`, `maxSkill = 150`.
* **Comportamiento Dinámico:**
  1. Si el jugador no tiene Cocina o su habilidad es `< 125`, la guía no aparece para no distraerlo.
  2. Si su habilidad está entre `125` y `150`, la guía aparece recomendándole comprar el libro antes de topar su límite.
  3. Si ya tiene el libro en sus bolsas (`PlayerHasItem(16072)`), la guía avanza automáticamente al Paso 2: *"Usar libro en inventario"*.
  4. Si su habilidad supera `150` o su límite máximo ya es `225` (`maxRank > 150`), el secreto se marca como completado y **se oculta permanentemente** (`autoHideCompleted = true`), liberando espacio en la lista.
* **PNJ por Facción:**
  * **Alianza:** Shandrina en Vallefresno (Lago Mystral, `50.2, 67.1`, mapa `1440`).
  * **Horda:** Wulan en Desolace (Aldea Cazasombras, `26.2, 69.8`, mapa `1443`).

### Caso 3: Tomos de la Biblioteca (`library_books`) — Collecting Library Books (WoW Forever)
* **Propósito:** Búsqueda y recolección de tomos antiguos, diarios de investigación y pergaminos esparcidos por todo Azeroth para entregarlos al Bibliotecario de Facción. En WoW Forever esta característica se expandió a todas las clases y cuenta con un sistema escalonado de 3 Tiers con recompensas de equipo (cuello, dedos, armas/escudos) y una bonificación exclusiva para magos (*Study*).
* **Nivel Recomendado:** `minLevel = 20`, `maxLevel = 60`.
* **Bibliotecarios de Facción (Puntos de Entrega):**
  * **Alianza:** Garion Wendell (`npc=211033`), Torre de los Magos, Ciudad de Ventormenta (`49.0, 86.4`, mapa `1453`).
  * **Horda:** Owen Thadd (`npc=211022`), Barrio de la Magia, Entrañas (`74.0, 32.4`, mapa `1458`).
* **Estructura Escalonada de Tiers y Recompensas (Canónico Wowhead):**
  
  | Tier | Libros Requeridos | Misión Oficial | Recompensas a Elegir |
  | :---: | :---: | :---: | :--- |
  | **Tier 1** | **10 Libros** | `#78150` *Friend of the Library* | • **Colgante de erudito** (`277203`): +3 Aguante, +2 Espíritu (Caster/Healer)<br>• **Amuleto de erudito** (`277204`): +2 Agilidad, +3 Aguante (Melee/Cazador) |
  | **Tier 2** | **20 Libros** | `#79536` *Greater Friend of the Library* | • **Sortija del investigador de campo** (`281634`): +7 Agilidad, +7 Aguante<br>• **Anillo de filántropo** (`281635`): +5 Intelecto, +10 Daño/Sanación con Hechizos |
  | **Tier 3** | **25 Libros** | `#82208` *Greater Friend of the Library* | • **Arco del buscador de la verdad** (`277254`): Arco 46-87 Daño (23.8 DPS), +7 Agilidad, +3 Aguante<br>• **Blasón de elucidación** (`277258`): Escudo 1580 Armadura, +12 Espíritu, +7 Sanación, +4 Hechizos (Req Nivel 40)<br>• **Luz nocturna del investigador** (`277260`): Mano izquierda / Antorcha: +12 Aguante, +7 Hechizos de Fuego (Req Nivel 40) |

* **Bonificación de Mago (Habilidad 'Estudiar'):**
  Al entregar su primer tomo, los Magos aprenden la habilidad permanente `Estudiar` (*Study*, hechizo `#1302508`). Al canalizarla dentro de una biblioteca consumiendo 1 Pluma ligera (*Light Feather*), genera un fardo de pergaminos con un tiempo de reutilización de 1 día.

* **Catálogo Maestro de Libros en Azeroth (40 Ubicaciones Canónicas):**

  | # | Título del Libro | Zona | Coordenadas | Contenedor / Objeto | Quest ID | Item ID | Facción |
  | :-: | :--- | :--- | :-: | :--- | :-: | :-: | :---: |
  | 1 | Archmage Theocritus' Research Journal | Bosque de Elwynn | `65.4, 70.1` | Libro de biblioteca (386759) | 79092 | 203755 | Alianza |
  | 2 | Bewitchments and Glamours | Páramos de Poniente | `45.4, 70.5` | Libro de hechizos (409562) | 78142 | 209845 | Ambas |
  | 3 | Rumi of Gnomeregan: The Collected Works | Loch Modan / Westfall | `35.6, 48.9` | Tomo gnómico (408014) | 79093 | 208860 | Alianza |
  | 4 | Crimes Against Anatomy | Bosque del Ocaso | `16.7, 28.5` | Libro de hechizos (409735) | 78147 | 209849 | Ambas |
  | 5 | Runes of the Sorcerer-Kings | Loch Modan | `77.5, 14.1` | Pergaminos (409731) | 78148 | 209850 | Ambas |
  | 6 | Goaz Scrolls | Los Humedales | `33.6, 47.9` | Pergaminos (409717) | 78146 | 209848 | Ambas |
  | 7 | Archmage Antonidas: The Unabridged Autobiography | Forjaz | `76.3, 10.8` | Libro de biblioteca (386691) | 79091 | 203754 | Alianza |
  | 8 | The Apothecary's Metaphysical Primer | Claros de Tirisfal | `59.5, 52.3` | Cartilla de Boticario (405879) | 79095 | 208185 | Horda |
  | 9 | The Dalaran Digest, Vol. 23 | Bosque de Argénteos | `63.5, 63.1` | Compendio de Dalaran (409501) | 78127 | 209844 | Ambas |
  | 10 | Ataeric: On Arcane Curiosities | Bosque de Argénteos | `43.4, 41.2` | Secretos arcanos (410299) | 79096 | 210177 | Horda |
  | 11 | Arcanic Systems Manual | Los Baldíos | `56.3, 8.8` | Manual (409700) | 78145 | 209847 | Ambas |
  | 12 | Baxtan: On Destructive Magics | Los Baldíos (Trinquete) | `62.7, 36.3` | Tomo goblin (407566) | 79097 | 208800 | Ambas |
  | 13 | Secrets of the Dreamers | Los Baldíos (Cueva) | `52.8, 54.7` | Pergaminos (409562) | 78143 | 209846 | Ambas |
  | 14 | Nar'thalas Almanac, Vol. 74 | Costa Oscura | `59.6, 22.2` | Pergaminos (409496) | 78124 | 209843 | Ambas |
  | 15 | The Lessons of Ta'zo | Orgrimmar | `38.7, 78.4` | Tablilla rúnica (Mural) | 79094 | 207972 | Horda |
  | 16 | Defensive Magics 101 | Montañas de Alterac | `48.4, 57.7` | Manual (423896) | 79948 | 215815 | Ambas |
  | 17 | A Web of Lies: Debunking Myths and Legends | Tierras Altas de Arathi | `73.6, 65.2` | Pergaminos (423897) | 79949 | 215816 | Ambas |
  | 18 | Mummies: A Guide to the Unsavory Undead | Tierras Inhóspitas | `56.7, 39.9` | Pergaminos (423899) | 79951 | 215820 | Ambas |
  | 19 | Fury of the Land | Sierra Espolón | `74.4, 85.7` | Pergaminos (409711) | 78149 | 209851 | Ambas |
  | 20 | Geomancy: The Stone-Cold Truth | Las Mil Agujas | `34.0, 40.0` | Pergaminos (423895) | 79947 | 215683 | Ambas |
  | 21 | Basilisks: Should Petrification be Feared? | Vega de Tuercespina | `41.5, 50.8` | Notas de investigación (421526) | 79535 | 213165 | Ambas |
  | 22 | RwlRwlRwlRwl! | Marjal Revolcafango | `57.0, 21.0` | Libro empapado (423900) | 79952 | 215822 | Ambas |
  | 23 | Demons and You | Desolace | `55.1, 26.2` | Libro misterioso (423898) | 79950 | 215817 | Ambas |
  | 24 | A Luddite's Guide to Caring for Your Demonic Pet | Pantano de las Penas | `61.0, 22.0` | Libro en jaula (423901) | 79953 | 215824 | Ambas |
  | 25 | Sanguine Sorcery | Pantano de las Penas | `70.1, 51.8` | Libro en ruinas | - | - | Ambas |
  | 26 | Everyday Etiquette | Azshara | `20.8, 62.0` | Libro sobre podio | - | - | Ambas |
  | 27 | Venomous Journeys | Tierras del Interior | `36.0, 72.8` | Libro en ruinas trol | - | - | Ambas |
  | 28 | A Mind of Metal | Garganta de Fuego | `37.8, 49.3` | Libro campamento enano | - | - | Ambas |
  | 29 | Stonewrought Design | Estepas Ardientes | `29.1, 28.9` | Libro sobre repisa | - | 220349 | Ambas |
  | 30 | Magma or Lava? | Montaña Roca Negra | `48.4, 63.6` | Libro exterior BRD | - | 228133 | Ambas |
  | 31 | The Liminal and the Arcane | Feralas | `50.6, 15.7` | Libro ruinas élficas | - | 220347 | Ambas |
  | 32 | Legends of the Tidesages | Tanaris | `72.6, 47.8` | Libro campamento pirata | - | - | Ambas |
  | 33 | Conjurer's Codex | Las Tierras Devastadas | `55.4, 32.2` | Códice en riscos | - | - | Ambas |
  | 34 | Northern Kalimdor - A Comprehensive Guide | Frondavil | `65.2, 3.2` | Libro en Timbermaw | - | 228134 | Ambas |
  | 35 | Undead Potatoes | Tierras de la Peste del Oeste | `38.3, 54.6` | Granja Felstone (escaleras) | - | 228132 | Ambas |
  | 36 | Necromancy 101 | Tierras de la Peste del Oeste | `69.4, 72.8` | Scholomance azotea (mesa) | - | 228141 | Ambas |
  | 37 | A Study of the Light | Tierras de la Peste del Este | `73.0, 65.0` | Capilla Esperanza de la Luz | - | 228135 | Ambas |
  | 38 | Scourge: Undead Menace or Misunderstood? | Tierras de la Peste del Este | `31.3, 21.0` | Mesa exterior Stratholme | - | 228140 | Ambas |
  | 39 | The Knight and the Lady | Tierras de la Peste del Este | `54.5, 50.8` | Ruinas este de Corin | - | 228138 | Ambas |
  | 40 | Ka-Boom! | Cuna del Invierno | `60.7, 37.7` | Tienda alquimia Everlook | - | 228136 | Ambas |

* **Lógica de Comportamiento Dinámico y Progresión:**
  1. **Escaneo de Bolsas e Historial:** Se comprueban los libros en posesión (`PlayerHasItem`) y las misiones individuales completadas o activas (`IsQuestCompleted`/`IsQuestActive`), acumulando el conteo de libros únicos (`collectedCount`).
  2. **Determinación del Tier Activo:**
     - Si `#82208` está completada: la guía se marca completada al 100% (`25/25 Libros`).
     - Si `#79536` está completada: el objetivo es Tier 3 (25 libros). Si `collectedCount >= 25` o la quest `#82208` está activa, conmuta al bibliotecario; en caso contrario, guía al siguiente libro pendiente.
     - Si `#78150` está completada: el objetivo es Tier 2 (20 libros). Si `collectedCount >= 20` o la quest `#79536` está activa, conmuta al bibliotecario; en caso contrario, guía al siguiente libro pendiente.
     - Por defecto: objetivo Tier 1 (10 libros). Si `collectedCount >= 10` o la quest `#78150` está activa, conmuta al bibliotecario; en caso contrario, guía al siguiente libro pendiente.
  3. **Filtrado por Facción:** El buscador automático de libros pendientes descarta tomos exclusivos de la facción rival (evitando dirigir a la Alianza a Orgrimmar o a la Horda a Forjaz).
  4. **Paso de Entrega Dinámico:** Cuando el jugador alcanza la cuota del Tier (10, 20 o 25), el paso de entrega adapta su título e instrucción con el nombre exacto de la misión a entregar (`Friend of the Library` o `Greater Friend of the Library`), el PNJ correspondiente (`Garion Wendell` o `Owen Thadd`) y su localización.

---

## 6. Procedimiento para Agregar Nuevas Guías o Secretos

Para registrar un nuevo secreto o guía en el addon:

### Paso 1: Declarar los Pasos en `Data/SecretsData.lua`
```lua
ns.Data.MiNuevaGuiaSteps = {
    [1] = {
        stepNum = 1,
        title = "1. Nombre del Hito",
        instruction = "Instrucción clara de qué hacer.",
        uiMapID = 1429,
        zoneName = "Bosque de Elwynn",
        x = 42.0, y = 65.0,
        action = "Hablar con PNJ",
        tip = "Consejo útil para el jugador.",
        icon = "Interface\\Icons\\inv_misc_gear_01",
    },
}
```

### Paso 2: Registrar en `ns.Data.Secrets`
Añadir la entrada a la tabla maestra con sus restricciones de nivel, profesión y recompensas:
```lua
ns.Data.Secrets["mi_nueva_guia"] = {
    id = "mi_nueva_guia",
    title = "Nombre Visible de la Guía",
    category = "Secreto Clásico",
    faction = "Ambas",
    level = "Nivel 20 - 30",
    minLevel = 20,
    maxLevel = 30,
    reward = "Recompensa principal",
    rewardItems = {
        { itemID = 12345, name = "Objeto Recompensa", quality = 2, icon = "Interface\\Icons\\inv_box_01", desc = "Descripción." }
    },
    icon = "Interface\\Icons\\inv_box_01",
    steps = ns.Data.MiNuevaGuiaSteps,
}
```

### Paso 3: Definir la Función de Progreso en `ns.GetSecretProgress`
En la función `ns.GetSecretProgress(secretKey)` de `Data/SecretsData.lua`, añadir la rama correspondiente:
```lua
elseif secretKey == "mi_nueva_guia" then
    if PlayerHasItem(12345) or IsQuestCompleted(99999) then
        return 1, true -- completado
    end
    return 1, false -- pendiente
```

### Paso 4: Añadir la Clave a la Lista Ordenada en `Modules/MainUI.lua`
Añadir `"mi_nueva_guia"` a la lista `secretsOrder` en `Modules/MainUI.lua` para establecer su posición visual en la tabla:
```lua
local secretsOrder = { "sleeping_bag", "expert_cooking", "mi_nueva_guia", ... }
```

### Paso 5: Validación Sintáctica y en Cliente
Ejecutar en la terminal de WSL:
```bash
python3 tools/validate_lua.py Data/SecretsData.lua
python3 tools/validate_lua.py Modules/MainUI.lua
```
Y luego ejecutar `/reload` en World of Warcraft para comprobar la visibilidad y funcionamiento de la nueva guía.
