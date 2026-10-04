import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { BiSLists } from './types.js';
import { SLOT_ORDER } from './config.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export class LuaExporter {
  /**
   * Generates the Lua code content for Data/BiSData.lua
   */
  generateLua(bisLists: BiSLists): string {
    const lines: string[] = [];

    lines.push('-- =========================================================================');
    lines.push('-- Archivo generado automáticamente por tools/bis-scraper');
    lines.push('-- Base de datos Best-in-Slot (BiS) para WoW Forever / Classic');
    lines.push('-- Con soporte para Wowhead Scraper & Enchants Database por Tier');
    lines.push('-- =========================================================================');
    lines.push('local addonName, ns = ...');
    lines.push('ns = ns or {}');
    lines.push('ns.Data = ns.Data or {}');
    lines.push('');
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

    // Load the base data containing leveling gear (15-25, 26-40, 41-52, pre-raid, raid-p1)
    // and the full enchants database (TANK, MELEE_DPS, RANGED_DPS, CASTER_DPS, HEALER across all tiers)
    const baseDataPath = path.join(__dirname, 'base_data.lua');
    let baseData = fs.readFileSync(baseDataPath, 'utf8');

    // Remove the comment header and initial 'local addonName, ns = ...'
    const dungeonCoordsIndex = baseData.indexOf('ns.Data.DungeonCoords = {');
    if (dungeonCoordsIndex !== -1) {
      baseData = baseData.slice(dungeonCoordsIndex);
    }

    // Insert sync block right before ns.Data.EnchantsDatabase starts
    const enchantsIndex = baseData.indexOf('ns.Data.EnchantsDatabase = {');
    if (enchantsIndex !== -1) {
      const partBeforeEnchants = baseData.slice(0, enchantsIndex);
      const partFromEnchants = baseData.slice(enchantsIndex);

      lines.push(partBeforeEnchants.trimEnd());
      lines.push('');
      lines.push(this.getSyncCode().trim());
      lines.push('');
      lines.push(partFromEnchants.trimStart());
    } else {
      lines.push(baseData);
      lines.push(this.getSyncCode().trim());
    }

    return lines.join('\n');
  }

  private getSyncCode(): string {
    return `
-- =========================================================================
-- SINCRONIZACIÓN AUTOMÁTICA DE OBJETOS DESDE AwakeningData.BiSLists
-- Actualiza los conjuntos Pre-Raid y Raid Fase 1 con datos en vivo de Wowhead
-- =========================================================================
if AwakeningData and AwakeningData.BiSLists then
    local slotMap = {
        HEAD = "Head",
        NECK = "Neck",
        SHOULDERS = "Shoulder",
        BACK = "Back",
        CHEST = "Chest",
        WRISTS = "Wrists",
        HANDS = "Hands",
        WAIST = "Waist",
        LEGS = "Legs",
        FEET = "Feet",
        FINGER_1 = "Finger",
        FINGER_2 = "RFinger",
        TRINKET_1 = "Trinket",
        TRINKET_2 = "RTrinket",
        MAIN_HAND = "MainHand",
        OFF_HAND = "SecondaryHand",
        RANGED = "Relic",
    }

    local specKeyMap = {
        ["Fury"] = "fury",
        ["Arms"] = "arms",
        ["Protection"] = "prot",
        ["Retribution"] = "retribution",
        ["Holy"] = "holy",
        ["Beast Mastery"] = "bm",
        ["Marksmanship"] = "marksman",
        ["Survival"] = "surv",
        ["Combat Swords"] = "combat",
        ["Assassination"] = "assassination",
        ["Subtlety"] = "subtlety",
        ["Shadow"] = "shadow",
        ["Discipline"] = "discipline",
        ["Restoration"] = "resto",
        ["Elemental"] = "elem",
        ["Enhancement"] = "enh",
        ["Frost"] = "frost",
        ["Fire"] = "fire",
        ["Arcane"] = "arcane",
        ["Destruction"] = "destro",
        ["Affliction"] = "affli",
        ["Demonology"] = "demo",
        ["Feral DPS"] = "feral_cat",
        ["Feral Tank"] = "feral_bear",
        ["Balance"] = "balance",
    }

    for classKey, classSpecs in pairs(AwakeningData.BiSLists) do
        local cData = ns.Data.BiS[classKey] or ns.Data.BiS[classKey:upper()]
        if cData and cData.sets then
            for specName, specData in pairs(classSpecs) do
                local sKey = specKeyMap[specName] or specName:lower():gsub("%s+", "_")
                
                -- Asegurar que la spec esté registrada en cData.specs
                local found = false
                for _, sInfo in ipairs(cData.specs or {}) do
                    if sInfo.key == sKey then
                        found = true
                        break
                    end
                end
                if not found and cData.specs then
                    table.insert(cData.specs, { key = sKey, name = specName })
                end

                if specData.slots then
                    for slotCode, itemEntry in pairs(specData.slots) do
                        local uiSlot = slotMap[slotCode]
                        if uiSlot and itemEntry.itemId and itemEntry.itemId > 0 then
                            -- Registrar metadatos en ns.Data.BiSItems si no existen
                            if not ns.Data.BiSItems[itemEntry.itemId] then
                                ns.Data.BiSItems[itemEntry.itemId] = {
                                    name = itemEntry.name,
                                    source = itemEntry.source or "Mundo Clásico / Wowhead",
                                    type = "Kill",
                                    zone = "Azeroth",
                                    drop = "BiS",
                                }
                            end

                            -- Actualizar tiers "raid-p1" y "pre-raid" con datos en vivo
                            for _, bracketKey in ipairs({"raid-p1", "pre-raid"}) do
                                if cData.sets[bracketKey] then
                                    if not cData.sets[bracketKey][sKey] then
                                        cData.sets[bracketKey][sKey] = {}
                                    end
                                    cData.sets[bracketKey][sKey][uiSlot] = itemEntry.itemId
                                end
                            end

                            -- Si es una spec nueva que no existía en tiers inferiores, darle un gearSet base
                            for _, bracketKey in ipairs({"15-25", "26-40", "41-52"}) do
                                if cData.sets[bracketKey] and not cData.sets[bracketKey][sKey] then
                                    local firstSpecKey = cData.specs[1] and cData.specs[1].key
                                    if firstSpecKey and cData.sets[bracketKey][firstSpecKey] then
                                        cData.sets[bracketKey][sKey] = cData.sets[bracketKey][firstSpecKey]
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
`;
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
