# 🗺️ Manual de Arquitectura de Viaje y Metodología de Navegación

> **Awakening: Companion — Sistema de Planificación de Rutas, Grafo Multimodal y Navegación Inteligente**  
> *Versión del Addon: 1.0.0 · Cliente: World of Warcraft Forever (Interface 16001 / Classic Era)*

---

## 1. Resumen Ejecutivo y Metodología

El **Planeador de Viaje** (*Travel Planner*) de Awakening Companion es un motor de navegación autónomo diseñado para calcular el itinerario óptimo entre cualquier ubicación del jugador (o punto del mundo) y su destino objetivo a lo largo de Azeroth y Kalimdor.

### Principios Fundamentales

1. **Eficiencia Algorítmica con Min-Heap:**  
   Implementa una cola de prioridad basada en montículo binario (`PriorityQueue:min-heap`), adaptada del estándar de ingeniería de navegación de *Mapzeroth*. Esto reduce la complejidad temporal de búsqueda de rutas de un algoritmo ingenuo $\mathcal{O}(V^2)$ a $\mathcal{O}((V + E) \log V)$, asegurando que el cálculo sea instantáneo ($< 2 \text{ ms}$) con cero impacto en los fotogramas por segundo (FPS).
2. **Multimodalidad Total:**  
   Integra todas las redes de transporte del juego: maestros de vuelos (alianza, horda y neutrales), barcos marítimos (intercontinentales y de cabotaje), zepelines, el Tranvía Subterráneo, portales arcanos y senderos peatonales/vías de nado.
3. **Cero Desvíos Innecesarios ("Direct Departure"):**  
   El sistema no obliga al jugador a visitar intermediarios innecesarios (como maestros de vuelo o muelles) si la ruta posterior continúa a pie o aborda un transporte diferente.

---

## 2. Arquitectura del Grafo (`Data/TravelData.lua`)

El grafo maestro está compuesto por una tabla estática de nodos (`travel.nodes`) y una colección de aristas bidireccionales (`travel.edges`).

### Tipos de Nodos

| Tipo | Identificador | Descripción y Comportamiento |
| :--- | :--- | :--- |
| `flightmaster` | Maestro de Vuelos | PNJ oficial con montura aérea. Requiere validación de descubrimiento previo en el cliente (`C_TaxiMap`) y facción permitida. |
| `boat` | Muelle / Embarcadero | Muelle marítimo donde atraca un barco. No tiene coste de cobre y su tiempo representa la travesía real. |
| `tram` | Tranvía Subterráneo | Estaciones del Tranvía Gnomo entre Ciudad de Ventormenta y Forjaz. |
| `zeppelin` | Torre de Zepelín | Plataforma goblin de zepelines de la Horda (Orgrimmar, Grom'gol, Entrañas/Brill). |
| `walk` | Conexión a Pie | Poblados, cruces de caminos o salidas de ciudades conectadas por senderos. |
| `swim` | Nado Seguro | Vías acuáticas estratégicas recomendadas para acortar camino. |
| `portal` | Portal Mágico | Portales estables (ej. Santuario del Mago / Torre de Magos). |

### Estructura de un Nodo

```lua
stormwind_harbor = {
    name = "Puerto de Ventormenta (Barco)",
    zoneName = "Ciudad de Ventormenta",
    continent = "Eastern Kingdoms",
    uiMapID = 1453,
    x = 22.7,
    y = 56.0,
    type = "boat",
    faction = "alliance",
    levelMin = 1,
    verified = true,
}
```

### Estructura de Aristas (`Edges`)

Cada arista define una conexión entre dos nodos con modo de desplazamiento, tiempo estimado en minutos, coste en monedas de cobre y facción:

```lua
{ from = "stormwind_harbor", to = "auberdine_dock_sw", mode = "boat", minutes = 4.5, costCopper = 0, faction = "alliance" },
{ from = "stormwind", to = "goldshire", mode = "walk", minutes = 2.5, costCopper = 0 },
```

* **Simetría Automática:** En `BuildGraph()`, cada arista se inserta en sentido directo e inverso, invirtiendo la secuencia de coordenadas intermedias (`waypoints`) si existen.

---

## 3. Resolución Inteligente de Salida: El Nodo Virtual `__player__`

### El Problema del Enfoque Ingenuo Previo
Si el planificador seleccionaba de forma estática el "nodo más cercano" antes de correr Dijkstra:
* Un jugador en las puertas de Ventormenta o en el Distrito de Comercio quedaba emparejado con Dungar Tragalargo (Maestro de Vuelos).
* Si el destino final era Darnassus (vía barco) o Villadorada (a pie), el itinerario le ordenaba caminar **hacia atrás** al Maestro de Vuelos, y luego desde allí salir al puerto o a la carretera.

### Solución Implementada: Inyección Dinámica de Candidatos

Cuando el origen es `__player__`, el planificador ejecuta:

```
                          ┌───────────────┐
                          │  __player__   │
                          └───────┬───────┘
          ┌───────────────────────┼────────────────────────┐
          ▼                       ▼                        ▼
  [Puerto Ventormenta]    [Maestro Vuelos]         [Villadorada]
     (Barco a Auberdine)     (Vuelo a Lakeshire)      (A pie / Camino)
```

1. **`GetDepartureCandidateNodes(playerMapID, playerX, playerY, factionKey)`:**
   * **Nodos Locales:** Identifica todos los hubs de transporte registrados en el mapa actual del jugador (`node.uiMapID == playerMapID` o mapa padre).
   * **Nodos Adyacentes a Pie (`Adjacent Walk Nodes`):** Detecta los nodos externos que se conectan mediante aristas peatonales (`mode == "walk"`) con la zona del jugador (ej. desde Ventormenta hacia Villadorada; desde Forjaz hacia Thelsamar; desde Orgrimmar hacia Cerrotajo).
   * **Métrica Física en Yardas:** Calcula la distancia euclidiana en el espacio tridimensional del mundo con `ns.GetDistanceAndHeading` y convierte la distancia en minutos de marcha (~420 yardas por minuto a velocidad normal de carrera).
2. **Inyección en el Grafo:**
   * Se crea temporalmente `g["__player__"]` con conexiones directas a todos los candidatos.
   * Tras la ejecución de Dijkstra, `g["__player__"] = nil` se limpia de inmediato para no ensuciar la caché del grafo.
3. **Penalización Anti-Desvío en Dijkstra:**
   * Si una rama de búsqueda propone caminar desde `__player__` a un nodo de transporte (como un maestro de vuelos o un muelle) y desde ese nodo **continuar a pie**, se le aplica una penalización masiva (`+25 min`):
     ```lua
     if currentId ~= "__player__" and edge.mode == "walk" and prevHop[currentId].fromId == "__player__" then
         local nodeCurrent = travel.nodes[currentId]
         if nodeCurrent and (nodeCurrent.type == "flightmaster" or nodeCurrent.type == "boat" or ...) then
             weight = weight + 25.0
         end
     end
     ```
   * Esto garantiza que Dijkstra siempre prefiera la caminata directa desde la posición actual del jugador hacia el destino a pie o hacia el muelle/tranvía correspondiente.
4. **Colapso Universal de Tramos en `BuildGuideFromPath`:**
   * Si por cualquier caso excepcional se encadenan dos tramos peatonales consecutivos (`__player__ -> A (walk)` seguido de `A -> B (walk)`):
     * Si `A` es un nodo de transporte (`flightmaster`, `boat`, `tram`, `zeppelin`), ambos tramos se colapsan instantáneamente en una única caminata directa `__player__ -> B`.
     * El paso hacia el Maestro de Vuelos se elimina de forma limpia del itinerario y del HUD.

---

## 4. Red de Transporte Específica de World of Warcraft Forever

WoW Forever introduce modificaciones clave en la geografía marítima y de transporte respecto al Classic Era original de 2004:

```
[Puerto de Ventormenta] 
         │ (Barco Directo · 4.5 min)
         ▼
[Auberdine · Muelle Oeste]
         │ (Caminata · 0.4 min)
         ▼
[Auberdine · Muelle Norte]
         │ (Barco a Rut'theran · 2.0 min)
         ▼
[Aldea Rut'theran] ───(Portal/Camino)───► [Darnassus]
```

### Puertos y Embarcaderos Registrados

1. **Puerto de Ventormenta (`stormwind_harbor`):**
   * Coordenadas: `(22.7, 56.0)` en Ciudad de Ventormenta (`1453`).
   * Zarpa directamente hacia **Auberdine (Muelle Oeste)** en Costa Oscura.
2. **Puerto de Auberdine (Costa Oscura · 3 Muelles Diferenciados):**
   * **Muelle Oeste (`auberdine_dock_sw` · 30.7, 41.0):** Línea marítima directa con Ciudad de Ventormenta.
   * **Muelle Sur (`auberdine_dock_south` · 32.4, 43.8):** Línea de escala múltiple: Auberdine $\leftrightarrow$ Puerto de Menethil $\leftrightarrow$ Costasur (Hillsbrad).
   * **Muelle Norte (`auberdine_dock_north` · 33.2, 40.2):** Línea directa hacia Aldea Rut'theran (Teldrassil / Darnassus).
3. **Puerto de Menethil y Costasur:**
   * Muelle hacia Auberdine / Costasur: `(4.7, 57.2)` en Los Humedales (`1437`).
   * Muelle hacia Theramore: `(5.0, 63.5)`.
   * Embarcadero de Costasur: `(50.6, 69.7)` en Laderas de Trabalomas (`1424`).
4. **Zonas Integradas (Datamined Forever):**
   * `riverglades_powderfuse` (`uiMapID = 16591`, `31.4, 68.2`): Muelle de barcos goblin Steamwheedle.
   * Nodos regionales de Zephras y Dalaran Flying Sanctuary.

---

## 5. Integración con el HUD y Compás TomTom

El resultado generado por `TravelPlanner:CalculateRoute` se convierte en una guía interactiva estándar para [Modules/GuideHUD.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Modules/GuideHUD.lua):

1. **Crazy Arrow 3D de TomTom:**
   * Cada etapa activa sincroniza sus coordenadas en TomTom (`TomTom:AddWaypoint`) con radio de llegada de 15 yardas.
   * La flecha dorada 3D se ubica de forma centrada en la parte superior (`TOP 0, -50`).
2. **Auto-Avance por Llegada y Transición:**
   * Al llegar a menos de 20 yardas del hito, se emite un sonido de confirmación (`SOUNDKIT.MAP_PING`) y el HUD avanza automáticamente al siguiente paso.
   * Para transiciones en barco, zepelín o tranvía, el HUD escucha los eventos `ZONE_CHANGED_NEW_AREA` y `ZONE_CHANGED`: al detectar que el jugador cargó en el mapa destino, avanza la etapa sin requerir intervención manual.
3. **Persistencia de Ventana:**
   * La posición del HUD flotante se persiste en `AwakeningDB.hudPosition` al terminar de arrastrarlo (`OnDragStop`).
   * Un menú contextual en el clic derecho permite retroceder, avanzar, centrar y re-sincronizar TomTom.

---

## 6. Procedimiento para Agregar Nuevos Nodos y Aristas

Para añadir nuevos puntos o conexiones (por ejemplo, nuevas rutas descubiertas en parches de WoW Forever):

1. **Declarar el Nodo en `Data/TravelData.lua`:**
   ```lua
   mi_nuevo_nodo = {
       name = "Nombre del Lugar",
       zoneName = "Nombre de Zona",
       continent = "Eastern Kingdoms" o "Kalimdor",
       uiMapID = 1234,
       x = 45.0, y = 60.0,
       type = "flightmaster" | "boat" | "walk" | "tram",
       faction = "alliance" | "horde" | "neutral",
       npcName = "Nombre del PNJ (si aplica)",
       verified = true,
   }
   ```
2. **Declarar las Aristas de Conexión:**
   ```lua
   { from = "nodo_origen", to = "mi_nuevo_nodo", mode = "flight", minutes = 2.0, costCopper = 150 },
   ```
3. **Validación Sintáctica:**
   Ejecutar siempre en la terminal de WSL:
   ```bash
   python3 tools/validate_lua.py Data/TravelData.lua
   python3 tools/validate_lua.py Modules/TravelPlanner.lua
   ```
4. **Validación en Cliente:**  
   Ejecutar `/reload` en el chat de World of Warcraft para verificar la ruta en el menú de viaje (`/awk travel`).

---

---

## 7. Reutilización del Motor de Viaje en Guías & Secretos

El catálogo de **Guías & Secretos** ([Modules/MainUI.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Modules/MainUI.lua)) y la base de datos de misiones ([Data/SecretsData.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Data/SecretsData.lua)) aprovechan directamente el motor algorítmico de `TravelPlanner` bajo una arquitectura híbrida canónica + dinámica:

1. **Catálogo Canónico Articulado (`ns.Data.SleepingBagStepsAlliance` - 16 Pasos):**
   * Se complementan los 7 hitos principales de la misión con los tramos geográficos clave para que la guía no sufra vacíos intercontinentales:
     * **Paso 1 (Hito 1):** Granja Alexston en Páramos de Poniente (`79008`).
     * **Pasos 2 al 4 (Viaje):** Puerto de Ventormenta (Barco a Auberdine `22.7, 56.0`), Muelle de Auberdine (`30.7, 41.0`) y Paso fronterizo a Los Baldíos (`49.3, 16.5`).
     * **Paso 5 (Hito 2):** Torre Calcinada en Los Baldíos (`46.4, 73.9`, entregar `79008`, aceptar `79192`).
     * **Pasos 6 y 7 (Viaje):** Paso de los Carromatos (`42.1, 44.5`) y Senda Oculta del Campamento (`50.9, 52.3`).
     * **Paso 8 (Hito 3):** Campamento en la Cima (`40.6, 52.4`, entregar `79192`, aceptar `79980`).
     * **Paso 9 (Hito 4):** Salto al Risco en Sierra Espolón (`39.6, 49.8`, entregar `79980`, aceptar `79974`).
     * **Pasos 10 y 11 (Viaje):** Barco de retorno a Puerto de Menethil (`32.4, 43.8` a `4.7, 57.2`) y Túneles de Dun Algaz (`53.6, 70.8` a `22.1, 14.5`).
     * **Paso 12 (Hito 5):** Presa de las Tres Cabezas en Loch Modan (`49.4, 12.9`, entregar `79974`, aceptar `79975`).
     * **Pasos 13 y 14 (Viaje):** Viaducto Thandol (`50.1, 11.2`) y Carretera a la Muralla de Thoradin (`14.8, 48.0`).
     * **Paso 15 (Hito 6):** Muralla de Thoradin - Parkour (`87.3, 49.6`, entregar `79975`, aceptar `79976`).
     * **Paso 16 (Hito 7):** Reclamar el Saco Acogedor (`87.3, 49.6`, entregar `79976`, recibir saco `211527`).

2. **Resolución Dinámica según Ubicación (`ns.GetDynamicSecretGuide`):**
   * Al pulsar **"Iniciar Ruta"** o hacer doble clic sobre el secreto:
     * Si el jugador ya se encuentra en la misma zona a menos de 1200 yardas del hito, genera una guía local inmediata enfocada directamente en el objetivo.
     * Si el jugador está en otra zona o continente, invoca `TravelPlanner:CalculateRoute("__player__", targetEndpoint)` para resolver la combinación multimodal óptima en tiempo real (vuelos, barcos, tranvías, atajos de caminata) desde sus coordenadas actuales, coronando la ruta con el hito de misión enriquecido.
   * `GuideHUD` recibe las etapas dinámicas con soporte para Crazy Arrow de TomTom, aviso sonoro y auto-avance por radio o transición de mapa.

3. **Mapeo Bidireccional de Hitos (`ns.GetSecretMilestoneTargetStep` y `ns.GetSecretMilestoneFirstStep`):**
   * Desacopla la lógica de verificación de progreso de misiones (`ns.GetSecretProgress`) de la cantidad de pasos de la ruta.
   * La lista principal de `MainUI` muestra la distancia física en tiempo real y el ETA calculado hacia el hito de destino exacto.

