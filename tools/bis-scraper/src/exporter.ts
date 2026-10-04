import fs from 'fs';
import path from 'path';
import { BiSLists } from './types.js';
import { CLASSES_CONFIG, SLOT_ORDER } from './config.js';

export class LuaExporter {
  /**
   * Generates the Lua code content for Data/BiSData.lua
   */
  generateLua(bisLists: BiSLists): string {
    const lines: string[] = [];

    lines.push('-- =========================================================================');
    lines.push('-- Archivo generado automáticamente por tools/bis-scraper');
    lines.push('-- Base de datos Best-in-Slot (BiS) para WoW Forever / Classic');
    lines.push('-- =========================================================================');
    lines.push('AwakeningData = AwakeningData or {}');
    lines.push('');
    lines.push('AwakeningData.BiSLists = {');

    for (const [className, classData] of Object.entries(bisLists)) {
      lines.push(`    ["${className}"] = {`);
      for (const [specName, specData] of Object.entries(classData)) {
        lines.push(`        ["${specName}"] = {`);
        lines.push(`            phase = ${specData.phase || 1},`);
        lines.push('            slots = {');

        for (const slot of SLOT_ORDER) {
          const item = specData.slots[slot];
          if (item && item.itemId > 0) {
            const safeName = (item.name || '').replace(/"/g, '\\"');
            const safeSource = (item.source || '').replace(/"/g, '\\"');
            if (safeSource) {
              lines.push(
                `                ["${slot}"] = { itemId = ${item.itemId}, name = "${safeName}", source = "${safeSource}" },`
              );
            } else {
              lines.push(
                `                ["${slot}"] = { itemId = ${item.itemId}, name = "${safeName}" },`
              );
            }
          }
        }

        lines.push('            }');
        lines.push('        },');
      }
      lines.push('    },');
    }
    lines.push('}');
    lines.push('');

    // Addon Integration Layer
    lines.push('-- =========================================================================');
    lines.push('-- INTEGRACIÓN CON EL ADDON AWAKENING COMPANION');
    lines.push('-- =========================================================================');
    lines.push('local addonName, ns = ...');
    lines.push('ns = ns or {}');
    lines.push('ns.Data = ns.Data or {}');
    lines.push('');
    lines.push('ns.Data.DungeonCoords = {');
    lines.push('    ["Stratholme"] = { mapID = 1423, x = 27.6, y = 11.6, zone = "Tierras de la Peste del Este" },');
    lines.push('    ["Scholomance"] = { mapID = 1422, x = 69.4, y = 72.8, zone = "Tierras de la Peste del Oeste" },');
    lines.push('    ["Blackrock Spire"] = { mapID = 1428, x = 34.6, y = 84.5, zone = "Garganta de Fuego" },');
    lines.push('    ["Cumbre de Roca Negra"] = { mapID = 1428, x = 34.6, y = 84.5, zone = "Garganta de Fuego" },');
    lines.push('    ["Blackrock Depths"] = { mapID = 1428, x = 34.6, y = 84.5, zone = "Garganta de Fuego" },');
    lines.push('    ["Profundidades de Roca Negra"] = { mapID = 1428, x = 34.6, y = 84.5, zone = "Garganta de Fuego" },');
    lines.push('    ["Scarlet Monastery"] = { mapID = 1420, x = 84.4, y = 32.2, zone = "Claros de Tirisfal" },');
    lines.push('    ["Monasterio Escarlata"] = { mapID = 1420, x = 84.4, y = 32.2, zone = "Claros de Tirisfal" },');
    lines.push('    ["Zul\'Farrak"] = { mapID = 1446, x = 39.2, y = 21.3, zone = "Tanaris" },');
    lines.push('    ["Maraudon"] = { mapID = 1443, x = 29.1, y = 62.4, zone = "Desolace" },');
    lines.push('    ["The Deadmines"] = { mapID = 1436, x = 42.6, y = 72.2, zone = "Páramos de Poniente" },');
    lines.push('    ["Minas de la Muerte"] = { mapID = 1436, x = 42.6, y = 72.2, zone = "Páramos de Poniente" },');
    lines.push('    ["Wailing Caverns"] = { mapID = 1413, x = 46.0, y = 36.5, zone = "Los Baldíos" },');
    lines.push('    ["Cuevas de los Lamentos"] = { mapID = 1413, x = 46.0, y = 36.5, zone = "Los Baldíos" },');
    lines.push('    ["Shadowfang Keep"] = { mapID = 1421, x = 44.8, y = 67.8, zone = "Bosque de Argénteos" },');
    lines.push('    ["Castillo de Colmillo Oscuro"] = { mapID = 1421, x = 44.8, y = 67.8, zone = "Bosque de Argénteos" },');
    lines.push('    ["Blackfathom Deeps"] = { mapID = 1440, x = 14.1, y = 14.4, zone = "Vallefresno" },');
    lines.push('    ["Cavernas de Brazanegra"] = { mapID = 1440, x = 14.1, y = 14.4, zone = "Vallefresno" },');
    lines.push('    ["Gnomeregan"] = { mapID = 1426, x = 24.5, y = 39.8, zone = "Dun Morogh" },');
    lines.push('    ["Razorfen Kraul"] = { mapID = 1413, x = 40.8, y = 89.6, zone = "Los Baldíos" },');
    lines.push('    ["Razorfen Downs"] = { mapID = 1413, x = 47.1, y = 91.2, zone = "Los Baldíos" },');
    lines.push('    ["Uldaman"] = { mapID = 1418, x = 42.4, y = 18.6, zone = "Tierras Inhóspitas" },');
    lines.push('    ["Dire Maul"] = { mapID = 1444, x = 60.5, y = 43.5, zone = "Feralas" },');
    lines.push('    ["La Masacre"] = { mapID = 1444, x = 60.5, y = 43.5, zone = "Feralas" },');
    lines.push('    ["The Temple of Atal\'Hakkar"] = { mapID = 1435, x = 69.8, y = 52.8, zone = "Pantano de las Penas" },');
    lines.push('    ["Templo Sumergido"] = { mapID = 1435, x = 69.8, y = 52.8, zone = "Pantano de las Penas" },');
    lines.push('    ["Molten Core"] = { mapID = 1428, x = 34.6, y = 84.5, zone = "Garganta de Fuego" },');
    lines.push('    ["Onyxia\'s Lair"] = { mapID = 1445, x = 52.6, y = 76.2, zone = "Marjal Revolcafango" },');
    lines.push('}');
    lines.push('');

    lines.push('ns.Data.BiSSlotsOrder = {');
    lines.push('    { key = "Head", name = "Casco" },');
    lines.push('    { key = "Neck", name = "Cuello" },');
    lines.push('    { key = "Shoulder", name = "Hombreras" },');
    lines.push('    { key = "Back", name = "Capa" },');
    lines.push('    { key = "Chest", name = "Pechera" },');
    lines.push('    { key = "Wrists", name = "Brazales" },');
    lines.push('    { key = "Hands", name = "Guantes" },');
    lines.push('    { key = "Waist", name = "Cinturón" },');
    lines.push('    { key = "Legs", name = "Pantalones" },');
    lines.push('    { key = "Feet", name = "Botas" },');
    lines.push('    { key = "Finger", name = "Anillo 1" },');
    lines.push('    { key = "RFinger", name = "Anillo 2" },');
    lines.push('    { key = "Trinket", name = "Abalorio 1" },');
    lines.push('    { key = "RTrinket", name = "Abalorio 2" },');
    lines.push('    { key = "MainHand", name = "Arma Principal" },');
    lines.push('    { key = "SecondaryHand", name = "Secundaria" },');
    lines.push('    { key = "Relic", name = "A Distancia / Reliquia" },');
    lines.push('}');
    lines.push('');

    lines.push('ns.Data.BiSItems = {}');
    lines.push('ns.Data.BiS = {}');
    lines.push('');

    // Mapping slots
    lines.push('local slotMap = {');
    lines.push('    HEAD = "Head",');
    lines.push('    NECK = "Neck",');
    lines.push('    SHOULDERS = "Shoulder",');
    lines.push('    BACK = "Back",');
    lines.push('    CHEST = "Chest",');
    lines.push('    WRISTS = "Wrists",');
    lines.push('    HANDS = "Hands",');
    lines.push('    WAIST = "Waist",');
    lines.push('    LEGS = "Legs",');
    lines.push('    FEET = "Feet",');
    lines.push('    FINGER_1 = "Finger",');
    lines.push('    FINGER_2 = "RFinger",');
    lines.push('    TRINKET_1 = "Trinket",');
    lines.push('    TRINKET_2 = "RTrinket",');
    lines.push('    MAIN_HAND = "MainHand",');
    lines.push('    OFF_HAND = "SecondaryHand",');
    lines.push('    RANGED = "Relic",');
    lines.push('}');
    lines.push('');

    lines.push('local classNamesEs = {');
    for (const [key, cfg] of Object.entries(CLASSES_CONFIG)) {
      lines.push(`    ["${key}"] = "${cfg.displayName}",`);
    }
    lines.push('}');
    lines.push('');

    lines.push('-- Adaptar AwakeningData.BiSLists a la estructura de interfaz ns.Data.BiS');
    lines.push('for classKey, classSpecs in pairs(AwakeningData.BiSLists or {}) do');
    lines.push('    local classData = {');
    lines.push('        name = classNamesEs[classKey] or classKey,');
    lines.push('        brackets = {');
    lines.push('            { key = "15-25",    name = "Nivel 15-25 (Mazmorras Iniciales)",     minLevel = 15, maxLevel = 25 },');
    lines.push('            { key = "26-40",    name = "Nivel 26-40 (Monasterio / Gnomeregan)", minLevel = 26, maxLevel = 40 },');
    lines.push('            { key = "41-52",    name = "Nivel 41-52 (Zul\'Farrak / Maraudon)",   minLevel = 41, maxLevel = 52 },');
    lines.push('            { key = "pre-raid", name = "Nivel 53-60 (Pre-Raid Mazmorras Nv. 60)", minLevel = 53, maxLevel = 60 },');
    lines.push('            { key = "raid-p1",  name = "Nivel 60 (Raid Fase 1 - MC & Onyxia)",  minLevel = 60, maxLevel = 60 },');
    lines.push('        },');
    lines.push('        specs = {},');
    lines.push('        sets = {');
    lines.push('            ["15-25"] = {},');
    lines.push('            ["26-40"] = {},');
    lines.push('            ["41-52"] = {},');
    lines.push('            ["pre-raid"] = {},');
    lines.push('            ["raid-p1"] = {},');
    lines.push('        }');
    lines.push('    }');
    lines.push('');
    lines.push('    for specName, specData in pairs(classSpecs) do');
    lines.push('        local specKey = specName:lower():gsub("%s+", "_")');
    lines.push('        table.insert(classData.specs, { key = specKey, name = specName })');
    lines.push('');
    lines.push('        local gearSet = {}');
    lines.push('        for slotCode, itemEntry in pairs(specData.slots or {}) do');
    lines.push('            local uiSlot = slotMap[slotCode]');
    lines.push('            if uiSlot and itemEntry.itemId and itemEntry.itemId > 0 then');
    lines.push('                gearSet[uiSlot] = itemEntry.itemId');
    lines.push('                if not ns.Data.BiSItems[itemEntry.itemId] then');
    lines.push('                    ns.Data.BiSItems[itemEntry.itemId] = {');
    lines.push('                        name = itemEntry.name,');
    lines.push('                        source = itemEntry.source or "Mundo Clásico",');
    lines.push('                        type = "Kill",');
    lines.push('                        zone = "Azeroth",');
    lines.push('                        drop = "Común",');
    lines.push('                    }');
    lines.push('                end');
    lines.push('            end');
    lines.push('        end');
    lines.push('');
    lines.push('        classData.sets["15-25"][specKey] = gearSet');
    lines.push('        classData.sets["26-40"][specKey] = gearSet');
    lines.push('        classData.sets["41-52"][specKey] = gearSet');
    lines.push('        classData.sets["pre-raid"][specKey] = gearSet');
    lines.push('        classData.sets["raid-p1"][specKey] = gearSet');
    lines.push('    end');
    lines.push('');
    lines.push('    ns.Data.BiS[classKey] = classData');
    lines.push('    ns.Data.BiS[classKey:lower()] = classData');
    lines.push('    ns.Data.BiS[classKey:sub(1,1):upper() .. classKey:sub(2):lower()] = classData');
    lines.push('end');
    lines.push('');

    // Helper functions
    lines.push('--- Determina el bracket BiS por defecto según el nivel del jugador');
    lines.push('function ns.GetDefaultBiSBracket(level)');
    lines.push('    local lvl = level or (UnitLevel and UnitLevel("player")) or 60');
    lines.push('    if lvl <= 25 then return "15-25"');
    lines.push('    elseif lvl <= 40 then return "26-40"');
    lines.push('    elseif lvl <= 52 then return "41-52"');
    lines.push('    elseif lvl < 60 then return "pre-raid"');
    lines.push('    else return "raid-p1" end');
    lines.push('end');
    lines.push('');

    lines.push('--- Verifica si el jugador tiene el objeto equipado o en sus bolsas');
    lines.push('function ns.GetPlayerItemStatus(itemID)');
    lines.push('    if not itemID or itemID == 0 then return false, false end');
    lines.push('');
    lines.push('    -- 1. Escaneo seguro de ranuras equipadas (1 a 19)');
    lines.push('    if GetInventoryItemID then');
    lines.push('        for slot = 1, 19 do');
    lines.push('            local ok, invID = pcall(GetInventoryItemID, "player", slot)');
    lines.push('            if ok and invID == itemID then');
    lines.push('                return true, false');
    lines.push('            end');
    lines.push('        end');
    lines.push('    end');
    lines.push('');
    lines.push('    -- 2. Escaneo seguro de bolsas del jugador (0 a NUM_BAG_SLOTS)');
    lines.push('    local numBags = NUM_BAG_SLOTS or 4');
    lines.push('    for bag = 0, numBags do');
    lines.push('        local numSlots = 0');
    lines.push('        if C_Container and C_Container.GetContainerNumSlots then');
    lines.push('            numSlots = C_Container.GetContainerNumSlots(bag) or 0');
    lines.push('        elseif GetContainerNumSlots then');
    lines.push('            numSlots = GetContainerNumSlots(bag) or 0');
    lines.push('        end');
    lines.push('');
    lines.push('        for slot = 1, numSlots do');
    lines.push('            local id');
    lines.push('            if C_Container and C_Container.GetContainerItemID then');
    lines.push('                id = C_Container.GetContainerItemID(bag, slot)');
    lines.push('            elseif GetContainerItemID then');
    lines.push('                id = GetContainerItemID(bag, slot)');
    lines.push('            end');
    lines.push('');
    lines.push('            if id == itemID then');
    lines.push('                return false, true');
    lines.push('            end');
    lines.push('        end');
    lines.push('    end');
    lines.push('');
    lines.push('    return false, false');
    lines.push('end');
    lines.push('');

    lines.push('--- Obtiene los metadatos de obtención del objeto (Jefe, Zona, Drop, etc.)');
    lines.push('function ns.GetBiSItemMetadata(itemID)');
    lines.push('    if not itemID or itemID == 0 then return nil end');
    lines.push('    local pre = ns.Data.BiSItems and ns.Data.BiSItems[itemID]');
    lines.push('    if pre then return pre end');
    lines.push('');
    lines.push('    local itemName');
    lines.push('    if C_Item and C_Item.GetItemInfo then');
    lines.push('        local ok, n = pcall(C_Item.GetItemInfo, itemID)');
    lines.push('        if ok and n then itemName = n end');
    lines.push('    end');
    lines.push('    if not itemName and _G.GetItemInfo then');
    lines.push('        local ok, n = pcall(_G.GetItemInfo, itemID)');
    lines.push('        if ok and n then itemName = n end');
    lines.push('    end');
    lines.push('');
    lines.push('    return {');
    lines.push('        name = itemName or ("Objeto #" .. itemID),');
    lines.push('        source = "Mundo Clásico",');
    lines.push('        type = "Kill",');
    lines.push('        zone = "Azeroth",');
    lines.push('        drop = "Variable"');
    lines.push('    }');
    lines.push('end');
    lines.push('');

    lines.push('--- Obtiene estadísticas de avance BiS (obtenidos / total)');
    lines.push('function ns.GetBiSProgress(classKey, bracketKey, specKey)');
    lines.push('    classKey = classKey or (UnitClass and select(2, UnitClass("player"))) or "WARRIOR"');
    lines.push('    local classData = ns.Data.BiS and (ns.Data.BiS[classKey] or ns.Data.BiS[classKey:upper()] or ns.Data.BiS["WARRIOR"])');
    lines.push('    if not classData or not classData.sets then return 0, 0, 0 end');
    lines.push('');
    lines.push('    bracketKey = bracketKey or ns.GetDefaultBiSBracket()');
    lines.push('    local bracketSets = classData.sets[bracketKey] or classData.sets["raid-p1"] or classData.sets["pre-raid"]');
    lines.push('    if not bracketSets then return 0, 0, 0 end');
    lines.push('');
    lines.push('    local spec = specKey or (classData.specs and classData.specs[1] and classData.specs[1].key)');
    lines.push('    local set = bracketSets[spec] or (classData.specs and classData.specs[1] and bracketSets[classData.specs[1].key])');
    lines.push('    if not set then return 0, 0, 0 end');
    lines.push('');
    lines.push('    local total = 0');
    lines.push('    local acquired = 0');
    lines.push('    for _, slotInfo in ipairs(ns.Data.BiSSlotsOrder or {}) do');
    lines.push('        local iid = set[slotInfo.key]');
    lines.push('        if iid and iid > 0 then');
    lines.push('            total = total + 1');
    lines.push('            local eq, inB = ns.GetPlayerItemStatus(iid)');
    lines.push('            if eq or inB then');
    lines.push('                acquired = acquired + 1');
    lines.push('            end');
    lines.push('        end');
    lines.push('    end');
    lines.push('    local pct = total > 0 and math.floor((acquired / total) * 100) or 0');
    lines.push('    return acquired, total, pct');
    lines.push('end');
    lines.push('');

    return lines.join('\n');
  }

  /**
   * Writes the generated Lua string directly to TargetFile
   */
  writeToFile(targetPath: string, content: string) {
    const dir = path.dirname(targetPath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    fs.writeFileSync(targetPath, content, 'utf-8');
  }
}
