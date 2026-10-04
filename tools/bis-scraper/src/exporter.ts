import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { BiSLists } from './types.js';
import { SLOT_ORDER } from './config.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export class LuaExporter {
  /**
   * Resolves the location of base_data.lua robustly across different execution environments
   */
  private getBaseDataPath(): string {
    const candidates = [
      path.join(__dirname, 'base_data.lua'),
      path.join(__dirname, '../src/base_data.lua'),
      path.resolve(process.cwd(), 'tools/bis-scraper/src/base_data.lua'),
      path.resolve(process.cwd(), 'src/base_data.lua'),
      path.resolve(process.cwd(), 'base_data.lua'),
    ];

    for (const candidate of candidates) {
      if (fs.existsSync(candidate)) {
        return candidate;
      }
    }

    throw new Error(
      `No se pudo encontrar el archivo base_data.lua. Rutas intentadas:\n  ${candidates.join('\n  ')}`
    );
  }

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
            const safeName = (item.name || '').replace(/\\/g, '\\\\').replace(/"/g, '\\"');
            const safeSource = (item.source || '').replace(/\\/g, '\\\\').replace(/"/g, '\\"');
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

    // Load base data containing dungeon items, leveling tiers (15-25, 26-40, 41-52)
    // and full enchants database (TANK, MELEE_DPS, RANGED_DPS, CASTER_DPS, HEALER across all tiers)
    const baseDataPath = this.getBaseDataPath();
    let baseData = fs.readFileSync(baseDataPath, 'utf8');

    // Remove the comment header and initial 'local addonName, ns = ...'
    const dungeonCoordsIndex = baseData.indexOf('ns.Data.DungeonCoords = {');
    if (dungeonCoordsIndex === -1) {
      throw new Error('Estructura inválida en base_data.lua: No se encontró "ns.Data.DungeonCoords = {"');
    }
    baseData = baseData.slice(dungeonCoordsIndex);

    // Insert sync block right before ns.Data.EnchantsDatabase starts
    const enchantsIndex = baseData.indexOf('ns.Data.EnchantsDatabase = {');
    if (enchantsIndex === -1) {
      throw new Error('Estructura inválida en base_data.lua: No se encontró "ns.Data.EnchantsDatabase = {"');
    }

    const partBeforeEnchants = baseData.slice(0, enchantsIndex);
    const partFromEnchants = baseData.slice(enchantsIndex);

    lines.push(partBeforeEnchants.trimEnd());
    lines.push('');
    lines.push(this.getSyncCode().trim());
    lines.push('');
    lines.push(partFromEnchants.trimStart());

    return lines.join('\n');
  }

  private getSyncCode(): string {
    return `
-- =========================================================================
-- SINCRONIZACIÓN AUTOMÁTICA DE OBJETOS DESDE AwakeningData.BiSLists
-- Actualiza los conjuntos Pre-Raid y Raid Fase 1 con datos en vivo de Wowhead
-- Manteniendo intactos los conjuntos de leveo (15-25, 26-40, 41-52) y encantamientos
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

    -- Mapeo contextual por clase hacia las claves internas del addon
    local classSpecKeyMap = {
        ["WARRIOR"] = {
            ["Fury"] = "fury",
            ["Arms"] = "arms",
            ["Protection"] = "prot",
        },
        ["PALADIN"] = {
            ["Retribution"] = "retribution",
            ["Holy"] = "holy",
            ["Protection"] = "protection",
        },
        ["HUNTER"] = {
            ["Marksmanship"] = "marksman",
            ["Beast Mastery"] = "bm",
            ["Survival"] = "surv",
        },
        ["ROGUE"] = {
            ["Combat Swords"] = "sword",
            ["Assassination"] = "dagger",
            ["Subtlety"] = "subtlety",
        },
        ["PRIEST"] = {
            ["Holy"] = "holy",
            ["Shadow"] = "shadow",
            ["Discipline"] = "discipline",
        },
        ["SHAMAN"] = {
            ["Restoration"] = "resto",
            ["Elemental"] = "elemental",
            ["Enhancement"] = "enhancement",
        },
        ["MAGE"] = {
            ["Frost"] = "frost",
            ["Fire"] = "fire",
            ["Arcane"] = "arcane",
        },
        ["WARLOCK"] = {
            ["Affliction"] = "affliction",
            ["Destruction"] = "destruction",
            ["Demonology"] = "demonology",
        },
        ["DRUID"] = {
            ["Feral DPS"] = "feral_cat",
            ["Feral Tank"] = "feral_bear",
            ["Restoration"] = "resto",
            ["Balance"] = "balance",
        },
    }

    local specNamesEs = {
        ["fury"] = "Furia (DPS Dual/2H)",
        ["arms"] = "Armas (PvE / PvP)",
        ["prot"] = "Protección (Tanque)",
        ["retribution"] = "Retribución (DPS)",
        ["holy"] = "Sagrado (Sanador)",
        ["protection"] = "Protección (Tanque)",
        ["marksman"] = "Puntería (DPS)",
        ["bm"] = "Dominio de Bestias (DPS)",
        ["surv"] = "Supervivencia (DPS)",
        ["sword"] = "Combate Espadas (DPS)",
        ["dagger"] = "Asesinato / Dagas (DPS)",
        ["subtlety"] = "Sutileza (PvP / DPS)",
        ["shadow"] = "Sombras (DPS)",
        ["discipline"] = "Disciplina (Soporte)",
        ["resto"] = "Restauración (Sanador)",
        ["elemental"] = "Elemental (Cáster DPS)",
        ["enhancement"] = "Mejora (DPS Melee)",
        ["frost"] = "Escarcha (DPS Control)",
        ["fire"] = "Fuego (DPS Ráfaga)",
        ["arcane"] = "Arcano (DPS / Utilidad)",
        ["affliction"] = "Aflicción (DoTs / DPS)",
        ["destruction"] = "Destrucción (DPS Fuego)",
        ["demonology"] = "Demonología (DPS)",
        ["feral_cat"] = "Feral Felino (DPS)",
        ["feral_bear"] = "Feral Oso (Tanque)",
        ["balance"] = "Equilibrio (Pollo DPS)",
    }

    for classKey, classSpecs in pairs(AwakeningData.BiSLists) do
        local cData = ns.Data.BiS[classKey] or ns.Data.BiS[classKey:upper()]
        if cData and cData.sets then
            local classMap = classSpecKeyMap[classKey] or classSpecKeyMap[classKey:upper()] or {}

            for specName, specData in pairs(classSpecs) do
                local sKey = classMap[specName] or specName:lower():gsub("%s+", "_")
                local sDisplayName = specNamesEs[sKey] or specName

                -- Asegurar que la spec esté registrada en cData.specs
                local found = false
                for _, sInfo in ipairs(cData.specs or {}) do
                    if sInfo.key == sKey then
                        found = true
                        sInfo.name = sDisplayName
                        break
                    end
                end
                if not found and cData.specs then
                    table.insert(cData.specs, { key = sKey, name = sDisplayName })
                end

                if specData.slots then
                    for slotCode, itemEntry in pairs(specData.slots) do
                        local uiSlot = slotMap[slotCode] or slotMap[slotCode:upper()] or slotCode
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

                            -- Si es una spec que no existía en tiers inferiores, darle un gearSet base
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
  writeToFile(targetPath: string, content: string): boolean {
    const dir = path.dirname(targetPath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    fs.writeFileSync(targetPath, content, 'utf-8');
    const stats = fs.statSync(targetPath);
    if (stats.size === 0) {
      throw new Error(`El archivo generado ${targetPath} está vacío`);
    }
    return true;
  }
}
