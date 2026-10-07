# ⚔️ Awakening: Companion — Guía Maestra de Desarrollo y Arquitectura

> **Manual de referencia técnica, patrones de diseño y directrices de código para asistentes y desarrolladores de Antigravity IDE.**

---

## 1. Contexto del Proyecto y Entorno

* **Producto:** **Awakening: Companion**, addon y suite de herramientas integradas para **World of Warcraft Forever** dirigido a nuevos y/o veteranos jugadores de la comunidad hispanohablante.
* **Versión de Interfaz (`## Interface`):** `16001` (WoW Classic Forever Beta).
* **Referencia Visual y Arquitectónica:** Código y recursos del addon local en `D:\World of Warcraft\_classic_beta_\Interface\AddOns\Olympus` (utilizar como estándar para imitar estilos de widgets, jerarquía visual, pestañas y manejo seguro de eventos).

### Modelo Operativo

| Capa | Acceso | Contenido y Módulos |
| :--- | :--- | :--- |
| **Capa Gratuita (Pública)** | Toda la comunidad | Catálogo de rutas, puzles, runas y misiones secretas (ej. *Cozy Sleeping Bag*), rutas de farmeo de profesiones y navegación asistida mediante HUD flotante independiente. |
| **Capa Exclusiva Hermandad** | Solo miembros de `<Awakening>` | Inspección semafórica de preparación para banda (*Raid Prep*), sincronización de rosters internos, avisos de guild y utilidades avanzadas. |

### Infraestructura de Trabajo

* **Código fuente (WSL 2 Ubuntu):** `/home/justicary/proyectos/antigravity/AwakeningCompanion` (`\\wsl.localhost\Ubuntu\home\justicary\proyectos\antigravity\AwakeningCompanion`).
* **Cliente de Juego (Windows 11):** `D:\World of Warcraft\_classic_beta_\`.
* **Enlace Simbólico:** `D:\World of Warcraft\_classic_beta_\Interface\AddOns\AwakeningCompanion` apunta directamente a este repositorio en WSL 2, permitiendo validar cambios en tiempo real con `/reload`.

---

## 2. Principios de Diseño UI/UX ("Visual-First" — Inspirado en Olympus)

### Ventana Principal Centrada
* La ventana primaria ([Modules/MainUI.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Modules/MainUI.lua)) debe levantarse siempre en el centro exacto de la pantalla:
  ```lua
  mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
  ```
* **Integración con ESC:** Registrar el marco en la tabla global de WoW para permitir el cierre inmediato con la tecla Escape:
  ```lua
  tinsert(UISpecialFrames, "AwakeningMainFrame")
  ```
* **Estructura Estética Olympus:**
  1. **Cabecera superior oscura:** Emblema circular o *crest* en la esquina superior izquierda (`spell_holy_magicalsentry`), título dorado prominente (`GameFontNormalHuge`), métricas en color oro (`GameFontHighlightLarge`) y estado del servidor/versión (`GameFontDisableSmall`).
  2. **Contenedor de datos tipo inset:** Fondo oscuro amarmolado (`Interface\FrameGeneral\UI-Background-Marble`) con bordes tooltip (`Interface\Tooltips\UI-Tooltip-Border`) y tinte de alto contraste (`0.02, 0.02, 0.04, 0.95`).
  3. **Barra inferior de 3 botones:** Botones de dimensiones consistentes (ej. `Iniciar Ruta / Marcar`, `Actualizar`, `Habilidades`).

### Sistema de Pestañas Laterales (Right Side Tabs)
* Ancladas verticalmente en el borde lateral derecho de la ventana principal, simulando las pestañas nativas del libro de hechizos o el panel de comunidades de WoW:
  * **Textura base:** `Interface\SpellBook\SpellBook-SkillLineTab`
  * **Resaltado:** `Interface\Buttons\ButtonHilight-Square` con modo de mezcla `"ADD"`
  * **Selección activa:** `Interface\Buttons\CheckButtonHilight`
* **Pestaña 1:** Rutas de Secretos (Acceso público).
* **Pestaña 2:** Rutas de Farmeo (Acceso público).
* **Pestaña 3:** Hermandad Awakening:
  * **No miembros:** Despliega una capa de bloqueo elegante con icono de candado/llave (`inv_misc_key_03`), texto explicativo en color de advertencia y botón de solicitud vía Discord.
  * **Miembros:** Desbloquea un selector de sub-pestañas horizontales (*Raid Prep* y *Roster Interno*).

### Cero Lectura Extensa
* Eliminar bloques de texto denso en favor de interfaces visuales e inmediatas:
  * **Semáforos cromáticos:** Verde (`|cFF00FF00`, borde verde) para requisitos completos; rojo (`|cFFFF3333`, borde rojo) para recursos faltantes.
  * **Iconos oficiales del cliente:** Para cada misión, consumible o nodo de recolección.
  * **Contadores directos:** Formato `(X/Y)` y métricas numéricas concisas.

### Desacoplamiento HUD vs. Menú Principal
* **Menú Principal ([Modules/MainUI.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Modules/MainUI.lua)):** Centro de mando, catálogo de guías y configuración.
* **HUD de Navegación ([Modules/GuideHUD.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Modules/GuideHUD.lua)):** Marco flotante independiente (`AwakeningNavHUD`), compacto, móvil y visible únicamente cuando el jugador sigue una ruta activa o solicita abrirlo expresamente.

### Navegación y Compás con TomTom (Delegación Inteligente)
* **No reinventar la rueda:** En lugar de duplicar o competir con el sistema de compás, Awakening Companion se integra de forma nativa con el addon **TomTom**:
  * Sincroniza cada paso como waypoint en TomTom (`TomTom:AddWaypoint`) activando automáticamente su legendaria **Crazy Arrow 3D** (`crazy = true`), pines en el mapa del mundo (`world = true`) y puntos en el minimapa (`minimap = true`).
  * Utiliza los eventos de proximidad (`callbacks.arrival`) con un radio de 15 metros para confirmar la llegada al hito y notificar al jugador.
  * Incorpora una insignia interactiva `[TomTom]` en el HUD de Awakening que permite re-enfocar el compás 3D con un solo clic.
  * **Fallback Nativo de Respaldo:** Si TomTom estuviera desactivado o ausente, el HUD conmuta de manera transparente a su flecha 2D interna con aceleración matemática y throttle de 0.05s para garantizar que la guía nunca se interrumpa.

---

## 3. Estándares Técnicos y Reglas de Código (Lua & WoW API)

### 1. Gestión Estricta de Namespaces
* Todos los archivos de código deben inicializarse capturando los argumentos del addon:
  ```lua
  local ADDON, ns = ...
  ```
* Queda estrictamente prohibido fugar variables o funciones al entorno global `_G`. Todo método, caché o tabla compartida debe asociarse a `ns` (ej. `ns.MainUI`, `ns.GuideHUD`, `ns.Data`, `ns.Comms`).
* Las únicas variables globales permitidas son:
  * `AwakeningDB` (SavedVariables declarada en el `.toc`).
  * `AwakeningData` (tabla de catálogo expuesta para retrocompatibilidad).
  * Variables de sistema de Blizzard (`SLASH_*`, `SlashCmdList`, `UISpecialFrames`).

### 2. Compatibilidad de Motor y BackdropTemplate
* **No asumir plantillas XML obsoletas:** Plantillas como `ColumnHeaderTemplate` pueden no existir o cambiar entre builds del cliente clásico.
* Toda cabecera o botón personalizado debe crearse especificando explícitamente `"BackdropTemplate"`:
  ```lua
  local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
  ```

### 3. Rutas Multiplataforma en `.toc`
* En [AwakeningCompanion.toc](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/AwakeningCompanion.toc), usar exclusivamente barras inclinadas normales (`/`) para evitar inconsistencias de resolución entre entornos Windows, WSL y Wine:
  ```toc
  Core/Init.lua
  Core/Comms.lua
  Data/SecretsData.lua
  ```

### 4. Rendimiento y FPS Throttle en `OnUpdate`
* En bucles de actualización continua (como la orientación de la flecha y el cálculo de distancias en [Modules/GuideHUD.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Modules/GuideHUD.lua)), acumular el parámetro `elapsed` y limitar la frecuencia de cálculo entre **0.05s y 0.1s** para garantizar cero impacto en los fotogramas por segundo del jugador:
  ```lua
  local elapsedAccumulator = 0
  frame:SetScript("OnUpdate", function(self, elapsed)
      elapsedAccumulator = elapsedAccumulator + elapsed
      if elapsedAccumulator < 0.05 then return end
      elapsedAccumulator = 0
      -- Ejecutar cálculo de distancia y rotación
  end)
  ```

### 5. APIs Modernas de Cartografía
* Utilizar exclusivamente la familia `C_Map`:
  * `C_Map.GetBestMapForUnit("player")` para identificar el mapa actual del jugador.
  * `C_Map.GetPlayerMapPosition(uiMapID, "player")` para consultar el vector de posición.
  * `pos:GetXY()` para extraer las coordenadas normalizadas ($0.0 \dots 1.0$).

### 6. Manejo Seguro de Combate (Lockdown Protection)
* Prohibido realizar alteraciones sobre marcos seguros o llamadas protegidas mientras el jugador se encuentra en combate (`InCombatLockdown() == true`).
* Utilizar la utilidad de encolado diferido `ns.QueueOutOfCombat(task)`, la cual ejecuta las tareas pendientes de forma automática en cuanto se dispara el evento `PLAYER_REGEN_ENABLED`.

### 7. Protocolo de Comunicación de Hermandad
* El intercambio de datos entre miembros utiliza el prefijo `AWK_COMP` registrado mediante `C_ChatInfo.RegisterAddonMessagePrefix`.
* Todas las emisiones usan el canal `"GUILD"` con validación previa de `IsInGuild()`.

### 8. Cumplimiento de Políticas TOS de Blizzard
* Prohibido automatizar acciones de juego, generar pulsaciones de teclado/ratón sintéticas o interactuar con la memoria del cliente. El addon solo ofrece asistencia informativa, cálculo de rutas y visualización de datos.

---

## 4. Estructura de Módulos y Responsabilidades

```
AwakeningCompanion/
├── AGENT.md                     # Guía de arquitectura y estándares (este archivo)
├── AwakeningCompanion.toc       # Registro ordenado de carga
├── Core/
│   ├── Init.lua                 # Inicialización de namespace, SavedVariables, cola de combate y comandos slash
│   └── Comms.lua                # Protocolo de mensajería interna entre miembros de hermandad (C_ChatInfo)
├── Data/
│   ├── BiSData.lua              # Base de datos BiS estructurada por nivel, clase, spec, boss, zona y coordenadas
│   ├── SecretsData.lua          # Base de datos de misiones, runas y secretos paso a paso
│   └── FarmingData.lua          # Rutas optimizadas de minerales, hierbas y suministros
├── Modules/
│   ├── MainUI.lua               # Ventana principal centrada con 5 pestañas estilo Olympus y bloqueo de guild
│   ├── GuideHUD.lua             # Marco flotante desacoplado con aguja indicadora y cálculo de distancia
│   ├── RaidPrep.lua             # Checklist semafórico de consumibles con escaneo de bolsas en tiempo real
│   ├── GuildRoster.lua          # Visualizador interno de miembros conectados con colores de clase
│   └── MinimapButton.lua        # Botón circular oficial del minimapa con icono del tabardo y arrastre
└── Media/
    ├── Icons/
    │   └── awakening_crest.tga  # Emblema oficial del tabardo de la hermandad (128x128 TGA)
    └── Textures/                # Fondos, bordes y recursos visuales
```

### Detalle de Módulos

| Archivo | Responsabilidad Principal | Métodos Clave |
| :--- | :--- | :--- |
| [Core/Init.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Core/Init.lua) | Ciclo de vida del addon, inicialización de `AwakeningDB`, detección de profesiones, helpers de formato, cola diferida fuera de combate y comandos de consola. | `ns.Print()`, `ns.GetPlayerProfessions()`, `ns.GetProfessionDisplayString()`, `ns.IsAwakeningGuildMember()`, `ns.QueueOutOfCombat()` |
| [Core/Comms.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Core/Comms.lua) | Protocolo de red interno para hermandad vía `CHAT_MSG_ADDON`. Transmisión de estados de preparación y solicitud de presencia. | `Comms:SendGuild()`, `Comms:BroadcastPrepStatus()`, `Comms:RegisterCallback()` |
| [Data/BiSData.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Data/BiSData.lua) | Catálogo Best-in-Slot (BiS) adaptado de BiSTracker y LibEquippable para las 9 clases clásicas, con 5 tiers según nivel de jugador (15-25, 26-40, 41-52, Pre-Raid 60, Raid P1), jefes, zonas y coordenadas para TomTom. Incluye base de datos completa de Encantamientos Óptimos y Refuerzos de Peletería (Leatherworking Armor Kits) escalados por tramo de nivel y rol. | `ns.GetDefaultBiSBracket()`, `ns.GetPlayerItemStatus()`, `ns.GetBiSItemMetadata()`, `ns.GetBiSProgress()`, `ns.GetEnchantsForSpec()`, `ns.GetEnchantMetadata()` |
| [Data/SecretsData.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Data/SecretsData.lua) | Definición estructurada de secretos (Cozy Sleeping Bag, runas arcanas, cofres ocultos) con zonas, coordenadas y descripción. | `ns.Data.Secrets`, `AwakeningData.Guides` |
| [Data/FarmingData.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Data/FarmingData.lua) | Catálogo de rutas de recolección (Minería, Herboristería, Desuello, Pesca) etiquetadas por profesión y rangos de habilidad recomendada. | `ns.Data.Farming` |
| [Modules/MainUI.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Modules/MainUI.lua) | Ventana principal estilo Olympus con 5 pestañas laterales (BiS, Secretos, Farmeo, Preparación, Hermandad), métrica hero superior, detalle inferior y botones de acción. | `MainUI:Init()`, `MainUI:OpenTab()`, `MainUI:UpdateBiSView()`, `MainUI:UpdateFarmingView()`, `MainUI:Toggle()`, `MainUI:Show()` |
| [Modules/GuideHUD.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Modules/GuideHUD.lua) | Tarjeta flotante de seguimiento de ruta con delegación a TomTom (Crazy Arrow 3D, pines de mapa y minimapa) y compás nativo de respaldo. | `GuideHUD:StartRoute()`, `GuideHUD:SyncTomTomWaypoint()`, `GuideHUD:ClearTomTomWaypoint()`, `GuideHUD:NextStep()`, `GuideHUD:Toggle()` |
| [Modules/RaidPrep.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Modules/RaidPrep.lua) | Módulo 'Preparación' dinámico según clase, nivel (tramos 1-19, 20-34, 35-49, 50-59, 60) y especialización. Sugiere consumibles, comida y buffs para leveleo, mazmorras y bandas. Encabezado hero dinámico (`Preparación <Clase> (Nv. <Nivel>) · X/Y (Z%)`). | `RaidPrep:Build()`, `RaidPrep:Update()`, `RaidPrep:CycleSpec()`, `RaidPrep:SelectConsumable()`, `RaidPrep:BroadcastStatus()` |
| [Modules/GuildRoster.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Modules/GuildRoster.lua) | Renderizado del censo de miembros en línea de `<Awakening>` con soporte para colores de clase (`RAID_CLASS_COLORS`) y scroll. | `GuildRoster:Build()`, `GuildRoster:Update()` |
| [Modules/MinimapButton.lua](file:///home/justicary/proyectos/antigravity/AwakeningCompanion/Modules/MinimapButton.lua) | Botón circular arrastrable en el minimapa con el emblema `awakening_crest.tga`, clic izquierdo (menú) y clic derecho (HUD). | `MinimapButton:Init()`, `MinimapButton:UpdatePosition()`, `MinimapButton:Toggle()` |

---

## 5. Comandos de Consola (Slash Commands)

El addon registra `/awakening` y `/awk` para interactuar rápidamente desde el chat del juego:

* `/awk` o `/awakening` — Abre o cierra la ventana principal centrada en la pestaña BiS.
* `/awk bis` — Abre directamente la pestaña BiS con el tier correspondiente al nivel del personaje.
* `/awk secretos` o `/awk secrets` — Abre directamente la pestaña de guías de secretos.
* `/awk farmeo` o `/awk farming` — Abre directamente la pestaña de rutas de farmeo.
* `/awk prep` o `/awk preparacion` — Abre directamente la pestaña de auditoría de consumibles y buffs ('Preparación').
* `/awk hermandad` o `/awk guild` — Abre directamente el censo de hermandad.
* `/awk hud` — Alterna la visibilidad del HUD flotante de navegación.
* `/awk arrow` — Centra horizontalmente la Crazy Arrow 3D de TomTom en la parte superior.
* `/awk reset` — Restablece la posición de la ventana principal al centro exacto de la pantalla.

---

## 6. Instrucciones para Sesiones de Trabajo con el Agente

1. **Inspección Previa de Widgets:** Antes de diseñar o ajustar un componente visual, inspeccionar la solución correspondiente en `D:\World of Warcraft\_classic_beta_\Interface\AddOns\Olympus` para emular dimensiones, texturas nativas del juego y estructura de anclajes.
2. **Validación Sintáctica:** Verificar que todo nuevo archivo Lua declare `local ADDON, ns = ...`, utilice `local` en funciones internas y no introduzca fugas globales.
3. **Despliegues Incrementales:** Cada modificación debe poder validarse en el juego inmediatamente mediante `/reload` en el chat del cliente sin necesidad de pasos de compilación intermedios.