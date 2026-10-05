# ⚔️ Awakening: Companion

> **Suite integral de asistencia visual, rutas guiadas, optimización de equipo (BiS dinámico) y utilidades de hermandad para World of Warcraft Classic & Forever Beta.**

[![Interface](https://img.shields.io/badge/Interface-16001%20%28Classic%20Forever%20Beta%29-blue.svg)](#)
[![Version](https://img.shields.io/badge/Version-1.0.0-green.svg)](#)
[![Author](https://img.shields.io/badge/Author-justicary-orange.svg)](#)
[![Language](https://img.shields.io/badge/Language-Lua%205.1%20%2F%20WoW%20API-yellow.svg)](#)

---

## 📌 Tabla de Contenidos
1. [Descripción General](#-descripción-general)
2. [Características Principales](#-características-principales)
   - [Módulo BiS Dinámico y Validación Inteligente](#1-módulo-bis-dinámico-best-in-slot-inteligente)
   - [Encantamientos y Refuerzos Óptimos](#2-encantamientos-y-refuerzos-óptimos)
   - [Preparación de Banda y Consumibles (Raid Prep)](#3-preparación-de-banda-y-consumibles-raid-prep)
   - [Rutas de Secretos y Misiones](#4-rutas-de-secretos-y-misiones)
   - [Rutas de Farmeo de Profesiones](#5-rutas-de-farmeo-de-profesiones)
   - [HUD Flotante de Navegación e Integración TomTom](#6-hud-flotante-de-navegación-e-integración-tomtom)
   - [Censo y Utilidades de Hermandad](#7-censo-y-utilidades-de-hermandad)
3. [Comandos de Consola (Slash Commands)](#-comandos-de-consola-slash-commands)
4. [Entorno de Desarrollo y Enlace con el Cliente WoW (Symlink)](#-entorno-de-desarrollo-y-enlace-con-el-cliente-wow-symlink)
   - [Escenario A: Windows (Directo)](#escenario-a-desarrollo-en-windows-directo)
   - [Escenario B: WSL 2 (Ubuntu/Linux) con WoW en Windows](#escenario-b-desarrollo-en-wsl-2-con-wow-en-windows-recomendado)
   - [Escenario C: Linux Nativo (Wine / Lutris / Proton)](#escenario-c-linux-nativo-wine--lutris--proton)
   - [Flujo de Pruebas en Caliente (/reload)](#flujo-de-pruebas-en-caliente)
5. [Estructura del Proyecto](#-estructura-del-proyecto)
6. [Dependencias Opcionales Recomendadas](#-dependencias-opcionales-recomendadas)

---

## 📖 Descripción General

**Awakening: Companion** es un addon modular diseñado desde cero para jugadores de World of Warcraft Classic y Forever Beta, con especial enfoque en la comunidad hispanohablante y los miembros de la hermandad **`<Awakening>`**. 

Su filosofía de diseño es **"Visual-First"**: interfaces limpias, oscuras, centradas y de alto contraste (inspiradas en la estética de addons premium como *Olympus*), priorizando semáforos de colores, iconos nativos del juego y contadores directos sobre bloques densos de texto.

---

## 🚀 Características Principales

### 1. Módulo BiS Dinámico (Best-in-Slot Inteligente)
* **Progresión por Tramos de Nivel:**
  * **Nivel 15-25:** Mazmorras iniciales (*Minas de la Muerte*, *Cueva de los Lamentos*, *Castillo de Colmillo Oscuro*).
  * **Nivel 26-40:** Mazmorras intermedias (*Cavernas de Brazanegra*, *Monasterio Escarlata*, *Gnomeregan*, *Zul'Farrak*).
  * **Nivel 41-52:** Mazmorras avanzadas (*Maraudon*, *Templo Sumergido*).
  * **Pre-Raid Nivel 60:** Mazmorras de nivel máximo (*BRD*, *LBRS*, *UBRS*, *Scholomance*, *Stratholme*).
  * **Raid Nivel 60 (Fase 1):** Botín óptimo de *Molten Core* y *Onyxia's Lair*.
* **Motor de Validación de Objetos (`ItemValidator.lua`):**
  * **Filtrado estricto por Ranura (`equipLoc`):** Impide discrepancias (como asignar armas en casillas de armadura) analizando la metadata instantánea del cliente de WoW (`GetItemInfoInstant`).
  * **Reglas por Rol y Especialización:**
    * **Tanques con Escudo:** Forzado de `SecondaryHand = INVTYPE_SHIELD` y exclusión total de armas de dos manos (`INVTYPE_2HWEAPON`) para especializaciones de protección.
    * **Aislamiento de Ranuras de Armas:** Las armas principales, secundarias y a distancia no se mezclan entre especializaciones dispares (manteniendo armas 2H en Armas, 1H+Escudo en Protección y Dual-Wield en Furia).
  * **Cálculo de Stat Weights / EP:** Ponderación dinámica de estadísticas por clase y rol (Fuerza, Aguante, Poder de Ataque, Golpe, Crítico, Poder de Hechizo, etc.) para calcular el porcentaje estimado de mejora frente al objeto actualmente equipado.
* **Integración con AtlasLoot:** Clic directo en cualquier objeto de la lista para abrir su página correspondiente en AtlasLootClassic.
* **Marcado de Jefes:** Envío instantáneo de coordenadas del jefe a **TomTom** con un solo clic en el botón *«Marcar Jefe»*.

### 2. Encantamientos y Refuerzos Óptimos
* Pestaña dedicada dentro del panel BiS que alterna entre **Equipo BiS** y **Encantamientos Óptimos**.
* Sugiere encantamientos de armas, armaduras y refuerzos de peletería (*Armor Kits*) adaptados exactamente al nivel del personaje y a las estadísticas prioritarias de su especialización.

### 3. Preparación de Banda y Consumibles (Raid Prep)
* Auditoría semafórica de inventario en tiempo real:
  * 🟢 **Verde:** Consumible presente en las bolsas con la cantidad mínima requerida.
  * 🔴 **Rojo:** Consumible ausente o en cantidad insuficiente.
* Escala dinámicamente según el nivel del jugador (tramos 1-19, 20-34, 35-49, 50-59 y 60).
* Incluye pociones de maná/salud, elixires de estadísticas, aceites de armas y comida con bonificaciones de estadísticas.

### 4. Rutas de Secretos y Misiones
* Guías paso a paso para desbloquear los secretos más codiciados de Classic:
  * **Cozy Sleeping Bag:** Cadena completa de misiones para obtener la bolsa de dormir de descanso rápido (+3% exp acumulable).
  * Runas arcanas, cofres ocultos y suministros esenciales.
* Integración fluida con el HUD de navegación.

### 5. Rutas de Farmeo de Profesiones
* Rutas optimizadas de recolección para **Minería**, **Herboristería**, **Desuello** y **Pesca**.
* Clasificadas por rango de habilidad recomendado de la profesión y zonas de mayor densidad de nodos.

### 6. HUD Flotante de Navegación e Integración TomTom
* **Crazy Arrow 3D de TomTom:** Al iniciar cualquier ruta o marcar un jefe, el addon se acopla automáticamente a TomTom, generando waypoints en el mapa mundial, minimapa y la icónica flecha 3D.
* **Confirmación por Proximidad:** Detecta automáticamente la llegada al hito en un radio de 15 metros (`callbacks.arrival`).
* **Compás 2D de Respaldo:** Si TomTom no está instalado o activo, el HUD conmuta de forma transparente a una aguja matemática interna de alta precisión con aceleración y limitador de fotogramas (0.05s throttle) para no impactar los FPS del juego.

### 7. Censo y Utilidades de Hermandad
* Visualizador exclusivo del censo de miembros conectados de `<Awakening>`.
* Colores oficiales de clase (`RAID_CLASS_COLORS`), indicador de zonas y nivel.
* Canal seguro de intercambio de estado de preparación (`AWK_COMP` vía `C_ChatInfo`).

---

## ⌨️ Comandos de Consola (Slash Commands)

Puedes utilizar `/awk` o `/awakening` en el chat del juego:

| Comando | Acción |
| :--- | :--- |
| `/awk` o `/awakening` | Abre o cierra la ventana principal centrada en la pestaña BiS. |
| `/awk bis` | Abre la ventana directamente en la lista de Best-in-Slot según tu nivel actual. |
| `/awk prep` | Abre el módulo de preparación y auditoría de consumibles en tus bolsas. |
| `/awk secretos` | Abre el catálogo de guías y cadenas de secretos. |
| `/awk farmeo` | Abre el catálogo de rutas de profesiones y recolección. |
| `/awk hermandad` | Abre el censo de miembros conectados de la hermandad. |
| `/awk hud` | Muestra u oculta la tarjeta flotante del HUD de navegación. |
| `/awk arrow` | Centra horizontalmente la flecha 3D de TomTom en la parte superior. |
| `/awk reset` | Restablece la posición de la ventana principal al centro de la pantalla. |

---

## 🛠 Entorno de Desarrollo y Enlace con el Cliente WoW (Symlink)

Para desarrollar el addon sin tener que copiar manualmente archivos tras cada cambio, se utiliza un **enlace simbólico (symlink)** desde la carpeta `Interface\AddOns` del cliente de World of Warcraft hacia el directorio de este repositorio.

### Escenario A: Desarrollo en Windows Directo

Si el repositorio está clonado en una ruta nativa de Windows (por ejemplo: `C:\Dev\AwakeningCompanion`):

1. Cierra World of Warcraft si está abierto.
2. Abre **Símbolo del sistema (CMD)** como **Administrador** y ejecuta:
   ```cmd
   mklink /D "C:\World of Warcraft\_classic_era_\Interface\AddOns\AwakeningCompanion" "C:\Dev\AwakeningCompanion"
   ```
   *(Ajusta la ruta a `_classic_era_`, `_classic_beta_` o `_classic_` según tu instalación).*

3. **Alternativa en PowerShell (como Administrador):**
   ```powershell
   New-Item -ItemType SymbolicLink -Path "C:\World of Warcraft\_classic_era_\Interface\AddOns\AwakeningCompanion" -Target "C:\Dev\AwakeningCompanion"
   ```

---

### Escenario B: Desarrollo en WSL 2 con WoW en Windows (Recomendado)

Si desarrollas dentro del entorno Linux de WSL 2 (ej. Ubuntu en `/home/justicary/proyectos/antigravity/AwakeningCompanion`):

1. Windows puede acceder a los archivos de WSL a través de la red local `\\wsl.localhost\Ubuntu\` o `\\wsl$\Ubuntu\`.
2. Abre **CMD como Administrador** en Windows y crea el enlace simbólico hacia la ruta de red de WSL:
   ```cmd
   mklink /D "D:\World of Warcraft\_classic_beta_\Interface\AddOns\AwakeningCompanion" "\\wsl.localhost\Ubuntu\home\justicary\proyectos\antigravity\AwakeningCompanion"
   ```
3. **Alternativa en PowerShell (como Administrador) en Windows:**
   ```powershell
   New-Item -ItemType SymbolicLink -Path "D:\World of Warcraft\_classic_beta_\Interface\AddOns\AwakeningCompanion" -Target "\\wsl.localhost\Ubuntu\home\justicary\proyectos\antigravity\AwakeningCompanion"
   ```
4. **Verificación:** Entra a la carpeta de AddOns en el Explorador de Archivos de Windows; deberías ver la carpeta `AwakeningCompanion` con el icono de flecha de acceso directo, pudiendo explorar los archivos directamente.

---

### Escenario C: Linux Nativo (Wine / Lutris / Proton)

Si ejecutas World of Warcraft directamente en Linux bajo Wine o Bottles:

```bash
ln -s /home/justicary/proyectos/antigravity/AwakeningCompanion ~/.wine/drive_c/Program\ Files\ \(x86\)/World\ of\ Warcraft/_classic_era_/Interface/AddOns/AwakeningCompanion
```

---

### ⚡ Flujo de Pruebas en Caliente

Una vez creado el enlace simbólico:

1. Inicia World of Warcraft y asegúrate de marcar **"Cargar accesorios desactualizados"** (*Load out of date AddOns*) en el menú de Accesorios de la pantalla de selección de personaje si tu versión de interfaz difiere ligeramente.
2. Inicia sesión con cualquier personaje.
3. Cada vez que modifiques código Lua, XML o tablas de datos en tu editor:
   * Guarda el archivo.
   * En el chat del juego escribe:
     ```text
     /reload
     ```
   * El cliente de WoW recargará el código fuente en 1-2 segundos sin necesidad de reiniciar el juego.

---

## 📂 Estructura del Proyecto

```text
AwakeningCompanion/
├── README.md                     # Documentación principal e instrucciones de despliegue
├── AGENT.md                      # Especificación arquitectónica y directrices para agentes
├── AwakeningCompanion.toc        # Manifiesto de carga de Blizzard WoW
├── Core/
│   ├── Init.lua                  # Ciclo de vida, SavedVariables, cola de combate y slash commands
│   ├── BiSDataProvider.lua       # Proveedor y selector reactivo de tablas BiS
│   ├── ItemValidator.lua         # Motor de validación de ranuras, roles y cálculo de EP
│   └── Comms.lua                 # Protocolo de comunicación interna de hermandad (C_ChatInfo)
├── Data/
│   ├── BiSData.lua               # Base de datos de equipamiento BiS y encantamientos por nivel/spec
│   ├── StatWeightsData.lua       # Ponderación de estadísticas (EP) para cálculo de mejoras
│   ├── SecretsData.lua           # Guías de secretos, runas y cadenas de misiones
│   ├── FarmingData.lua           # Rutas optimizadas de recolección y profesiones
│   └── CampingData.lua           # Datos de zonas de descanso y farmeo
├── Modules/
│   ├── MainUI.lua                # Ventana principal centrada con pestañas laterales estilo Olympus
│   ├── GuideHUD.lua              # HUD flotante de navegación con soporte de compás y TomTom
│   ├── RaidPrep.lua              # Auditoría de consumibles en tiempo real con escaneo de bolsas
│   ├── GuildRoster.lua           # Visualizador de miembros de hermandad conectados
│   └── MinimapButton.lua         # Botón arrastrable del minimapa con el blasón de hermandad
├── Media/
│   ├── Icons/
│   │   └── awakening_crest.tga   # Emblema oficial de la hermandad (128x128 TGA)
│   └── Textures/                 # Texturas nativas, fondos y bordes de interfaz
└── tools/
    └── bis-scraper/              # Herramientas de extracción y validación de bases de datos
```

---

## 🧩 Dependencias Opcionales Recomendadas

* **[TomTom](https://www.curseforge.com/wow/addons/tomtom):** Habilita la navegación guiada mediante la Crazy Arrow 3D y waypoints automáticos en el mapa y minimapa.
* **[AtlasLootClassic](https://www.curseforge.com/wow/addons/atlaslootclassic):** Permite inspeccionar tablas de botín completas de mazmorras y bandas haciendo clic directo en los objetos recomendados por Awakening Companion.

---

## ⚖️ Licencia

Distribuido para uso interno de la hermandad **`<Awakening>`** y la comunidad de World of Warcraft Classic. Diseñado cumpliendo rigurosamente las directrices de la API pública de Blizzard Entertainment y los Términos de Servicio (TOS).
