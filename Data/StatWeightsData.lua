-- =========================================================================
-- Awakening Companion - Data/StatWeightsData.lua
-- Motor de Puntuación de Estadísticas (Stat Weights / Equivalency Points)
-- Basado en metodología de Sixty Upgrades & Classic BiS Weights
-- =========================================================================
local addonName, ns = ...
ns = ns or {}
ns.Data = ns.Data or {}

AwakeningData = AwakeningData or {}

-- -------------------------------------------------------------------------
-- PONDERACIONES DE ESTADÍSTICAS (STAT WEIGHTS / EP) POR CLASE Y SPEC
-- -------------------------------------------------------------------------
AwakeningData.StatWeights = {
    ["WARRIOR"] = {
        ["fury"] = {
            name = "Furia (DPS Dual/2H)",
            weights = {
                STR = 2.0, AGI = 1.4, AP = 1.0, CRIT = 14.0, HIT = 18.0,
                STA = 0.2, ARMOR = 0.05, WEAPON_DPS = 10.0,
            }
        },
        ["arms"] = {
            name = "Armas (PvE / PvP)",
            weights = {
                STR = 2.0, AGI = 1.3, AP = 1.0, CRIT = 15.0, HIT = 18.0,
                STA = 0.35, ARMOR = 0.05, WEAPON_DPS = 12.0,
            }
        },
        ["prot"] = {
            name = "Protección (Tanque)",
            weights = {
                DEFENSE = 2.5, STA = 2.0, ARMOR = 0.3, AGI = 1.0, STR = 0.8,
                BLOCK_VALUE = 0.6, BLOCK = 1.2, PARRY = 1.8, DODGE = 1.8, HIT = 8.0,
            }
        },
    },
    ["PALADIN"] = {
        ["retribution"] = {
            name = "Retribución (DPS)",
            weights = {
                STR = 2.0, AGI = 1.2, AP = 1.0, SPELL_DMG = 0.5, CRIT = 13.0, HIT = 16.0,
                STA = 0.3, INT = 0.4, WEAPON_DPS = 10.0,
            }
        },
        ["holy"] = {
            name = "Sagrado (Sanador)",
            weights = {
                HEAL = 1.0, SPELL_POWER = 1.0, INT = 0.7, MP5 = 3.5, SPIRIT = 0.4,
                SPELL_CRIT = 8.0, STA = 0.2,
            }
        },
        ["protection"] = {
            name = "Protección (Tanque)",
            weights = {
                STA = 2.0, ARMOR = 0.3, DEFENSE = 2.2, SPELL_DMG = 0.8,
                BLOCK_VALUE = 0.8, BLOCK = 1.5, DODGE = 1.6, PARRY = 1.6, STR = 0.6, INT = 0.4,
            }
        },
    },
    ["HUNTER"] = {
        ["marksman"] = {
            name = "Puntería (DPS)",
            weights = {
                AGI = 2.5, RAP = 1.0, AP = 0.5, CRIT = 14.0, HIT = 16.0,
                STA = 0.3, INT = 0.4, WEAPON_DPS = 14.0,
            }
        },
        ["bm"] = {
            name = "Dominio de Bestias (DPS)",
            weights = {
                AGI = 2.2, RAP = 1.0, AP = 0.6, CRIT = 12.0, HIT = 15.0,
                STA = 0.4, INT = 0.3, WEAPON_DPS = 12.0,
            }
        },
        ["surv"] = {
            name = "Supervivencia (DPS)",
            weights = {
                AGI = 2.7, RAP = 1.0, AP = 0.5, CRIT = 15.0, HIT = 16.0,
                STA = 0.4, INT = 0.3, WEAPON_DPS = 14.0,
            }
        },
    },
    ["ROGUE"] = {
        ["sword"] = {
            name = "Combate Espadas (DPS)",
            weights = {
                AGI = 2.0, STR = 1.1, AP = 1.0, CRIT = 13.0, HIT = 20.0,
                STA = 0.2, WEAPON_DPS = 11.0,
            }
        },
        ["dagger"] = {
            name = "Asesinato / Dagas (DPS)",
            weights = {
                AGI = 2.1, STR = 1.1, AP = 1.0, CRIT = 15.0, HIT = 18.0,
                STA = 0.2, WEAPON_DPS = 12.0,
            }
        },
        ["subtlety"] = {
            name = "Sutileza (PvP / DPS)",
            weights = {
                AGI = 2.2, AP = 1.0, STR = 1.0, CRIT = 14.0, HIT = 17.0,
                STA = 0.4, WEAPON_DPS = 11.0,
            }
        },
    },
    ["PRIEST"] = {
        ["holy"] = {
            name = "Sagrado (Sanador)",
            weights = {
                HEAL = 1.0, SPELL_POWER = 1.0, INT = 0.65, MP5 = 3.8, SPIRIT = 0.7,
                SPELL_CRIT = 6.0, STA = 0.2,
            }
        },
        ["shadow"] = {
            name = "Sombras (DPS)",
            weights = {
                SPELL_SHADOW = 1.0, SPELL_DMG = 1.0, SPELL_HIT = 14.0, SPELL_CRIT = 7.0,
                INT = 0.35, SPIRIT = 0.1, STA = 0.25, MP5 = 1.5,
            }
        },
        ["discipline"] = {
            name = "Disciplina (Soporte)",
            weights = {
                HEAL = 1.0, SPELL_POWER = 1.0, INT = 0.75, MP5 = 3.5, SPIRIT = 0.6,
                SPELL_CRIT = 7.0, STA = 0.3,
            }
        },
    },
    ["SHAMAN"] = {
        ["resto"] = {
            name = "Restauración (Sanador)",
            weights = {
                HEAL = 1.0, SPELL_POWER = 1.0, INT = 0.65, MP5 = 3.5, SPIRIT = 0.2,
                SPELL_CRIT = 7.5, STA = 0.2,
            }
        },
        ["elemental"] = {
            name = "Elemental (Cáster DPS)",
            weights = {
                SPELL_NATURE = 1.0, SPELL_DMG = 1.0, SPELL_HIT = 13.0, SPELL_CRIT = 9.0,
                INT = 0.5, MP5 = 2.0, STA = 0.25,
            }
        },
        ["enhancement"] = {
            name = "Mejora (DPS Melee)",
            weights = {
                STR = 2.0, AGI = 1.7, AP = 1.0, CRIT = 14.0, HIT = 16.0,
                SPELL_DMG = 0.4, INT = 0.4, STA = 0.3, WEAPON_DPS = 10.0,
            }
        },
    },
    ["MAGE"] = {
        ["frost"] = {
            name = "Escarcha (DPS Control)",
            weights = {
                SPELL_FROST = 1.0, SPELL_DMG = 1.0, SPELL_HIT = 12.0, SPELL_CRIT = 8.0,
                INT = 0.4, MP5 = 0.8, STA = 0.2,
            }
        },
        ["fire"] = {
            name = "Fuego (DPS Ráfaga)",
            weights = {
                SPELL_FIRE = 1.0, SPELL_DMG = 1.0, SPELL_HIT = 14.0, SPELL_CRIT = 10.0,
                INT = 0.4, MP5 = 0.8, STA = 0.2,
            }
        },
        ["arcane"] = {
            name = "Arcano (DPS / Utilidad)",
            weights = {
                SPELL_ARCANE = 1.0, SPELL_DMG = 1.0, SPELL_HIT = 11.0, SPELL_CRIT = 8.5,
                INT = 0.5, MP5 = 1.2, STA = 0.2,
            }
        },
    },
    ["WARLOCK"] = {
        ["affliction"] = {
            name = "Aflicción (DoTs / DPS)",
            weights = {
                SPELL_SHADOW = 1.0, SPELL_DMG = 1.0, SPELL_HIT = 14.0, SPELL_CRIT = 6.5,
                INT = 0.35, STA = 0.5, SPIRIT = 0.1, MP5 = 0.5,
            }
        },
        ["destruction"] = {
            name = "Destrucción (DPS Fuego)",
            weights = {
                SPELL_FIRE = 1.0, SPELL_SHADOW = 0.8, SPELL_DMG = 1.0, SPELL_HIT = 14.0, SPELL_CRIT = 9.0,
                INT = 0.4, STA = 0.4,
            }
        },
        ["demonology"] = {
            name = "Demonología (DPS)",
            weights = {
                SPELL_DMG = 1.0, STA = 0.7, INT = 0.4, SPELL_HIT = 12.0, SPELL_CRIT = 7.0,
            }
        },
    },
    ["DRUID"] = {
        ["feral_cat"] = {
            name = "Feral Felino (DPS)",
            weights = {
                AGI = 2.4, STR = 2.4, AP = 1.0, CRIT = 15.0, HIT = 18.0,
                STA = 0.3,
            }
        },
        ["feral_bear"] = {
            name = "Feral Oso (Tanque)",
            weights = {
                STA = 2.5, ARMOR = 0.6, AGI = 1.5, STR = 1.0, DODGE = 2.0,
                DEFENSE = 1.5, HIT = 8.0,
            }
        },
        ["resto"] = {
            name = "Restauración (Sanador)",
            weights = {
                HEAL = 1.0, SPELL_POWER = 1.0, INT = 0.6, MP5 = 3.5, SPIRIT = 0.6,
                SPELL_CRIT = 5.0, STA = 0.2,
            }
        },
        ["balance"] = {
            name = "Equilibrio (Pollo DPS)",
            weights = {
                SPELL_NATURE = 1.0, SPELL_ARCANE = 1.0, SPELL_DMG = 1.0, SPELL_HIT = 13.0,
                SPELL_CRIT = 8.5, INT = 0.5, MP5 = 1.5, STA = 0.25,
            }
        },
    },
}

-- Aliases para retrocompatibilidad
ns.Data.StatWeights = AwakeningData.StatWeights

-- -------------------------------------------------------------------------
-- MAPEO DE ATRIBUTOS DE LA API DE WOW A CLAVES INTERNAS
-- -------------------------------------------------------------------------
local STAT_KEY_MAP = {
    ["ITEM_MOD_STRENGTH_SHORT"] = "STR",
    ["ITEM_MOD_AGILITY_SHORT"] = "AGI",
    ["ITEM_MOD_STAMINA_SHORT"] = "STA",
    ["ITEM_MOD_INTELLECT_SHORT"] = "INT",
    ["ITEM_MOD_SPIRIT_SHORT"] = "SPIRIT",
    ["ITEM_MOD_ARMOR_SHORT"] = "ARMOR",
    ["ITEM_MOD_ATTACK_POWER_SHORT"] = "AP",
    ["ITEM_MOD_RANGED_ATTACK_POWER_SHORT"] = "RAP",
    ["ITEM_MOD_CRIT_RATING_SHORT"] = "CRIT",
    ["ITEM_MOD_CRIT_MELEE_RATING_SHORT"] = "CRIT",
    ["ITEM_MOD_CRIT_RANGED_RATING_SHORT"] = "CRIT",
    ["ITEM_MOD_CRIT_SPELL_RATING_SHORT"] = "SPELL_CRIT",
    ["ITEM_MOD_HIT_RATING_SHORT"] = "HIT",
    ["ITEM_MOD_HIT_MELEE_RATING_SHORT"] = "HIT",
    ["ITEM_MOD_HIT_RANGED_RATING_SHORT"] = "HIT",
    ["ITEM_MOD_HIT_SPELL_RATING_SHORT"] = "SPELL_HIT",
    ["ITEM_MOD_SPELL_POWER_SHORT"] = "SPELL_POWER",
    ["ITEM_MOD_SPELL_DAMAGE_DONE_SHORT"] = "SPELL_DMG",
    ["ITEM_MOD_SPELL_HEALING_DONE_SHORT"] = "HEAL",
    ["ITEM_MOD_DEFENSE_SKILL_RATING_SHORT"] = "DEFENSE",
    ["ITEM_MOD_DODGE_RATING_SHORT"] = "DODGE",
    ["ITEM_MOD_PARRY_RATING_SHORT"] = "PARRY",
    ["ITEM_MOD_BLOCK_RATING_SHORT"] = "BLOCK",
    ["ITEM_MOD_BLOCK_VALUE_SHORT"] = "BLOCK_VALUE",
    ["ITEM_MOD_MANA_REGENERATION_SHORT"] = "MP5",
}

-- -------------------------------------------------------------------------
-- FUNCIONES DEL MOTOR DE PUNTUACIÓN (STAT WEIGHTS ENGINE)
-- -------------------------------------------------------------------------

--- Obtiene la tabla de pesos para una clase y especialización
function ns.GetStatWeights(classKeyOrSpec, maybeSpecKey)
    local classKey, specKey
    local _, playerClass = UnitClass("player")
    playerClass = (playerClass or "WARRIOR"):upper()

    if maybeSpecKey then
        classKey = (classKeyOrSpec or playerClass):upper()
        specKey = maybeSpecKey
    elseif classKeyOrSpec and AwakeningData.StatWeights[classKeyOrSpec:upper()] then
        classKey = classKeyOrSpec:upper()
        specKey = nil
    else
        classKey = playerClass
        specKey = classKeyOrSpec
    end

    local classTable = AwakeningData.StatWeights[classKey] or AwakeningData.StatWeights["WARRIOR"]
    if not classTable then return nil end

    if specKey and classTable[specKey] then
        return classTable[specKey].weights, classTable[specKey].name
    end

    -- Tomar la primera spec disponible
    for sKey, sData in pairs(classTable) do
        return sData.weights, sData.name
    end
    return nil, nil
end

--- Calcula la puntuación numérica (Item Score / EP) de un objeto
-- @param itemLinkOrID string|number
-- @param classKeyOrSpec string (opcional)
-- @param maybeSpecKey string (opcional)
-- @return number Score total del objeto
function ns.GetItemScore(itemLinkOrID, classKeyOrSpec, maybeSpecKey)
    if not itemLinkOrID or itemLinkOrID == 0 then return 0 end

    local weights = ns.GetStatWeights(classKeyOrSpec, maybeSpecKey)
    if not weights then return 0 end

    local score = 0

    -- 1. Intentar obtener atributos a través de GetItemStats nativo
    local stats = GetItemStats and GetItemStats(tostring(itemLinkOrID))
    if stats then
        for statConst, val in pairs(stats) do
            local mappedKey = STAT_KEY_MAP[statConst]
            if mappedKey and weights[mappedKey] then
                score = score + (val * weights[mappedKey])
            end
        end
    end

    -- 2. Atributos de nivel, calidad y daño base si están disponibles
    local itemLevel, itemQuality, itemEquipLoc
    if GetItemInfo then
        local _, _, q, lvl, _, _, _, _, eqLoc = GetItemInfo(itemLinkOrID)
        itemLevel = lvl
        itemQuality = q
        itemEquipLoc = eqLoc
    end

    -- Si el objeto no tiene stats explícitos (ej. equipo blanco de nivel 1-10 de comerciante),
    -- su valor radica en su nivel de objeto (iLvl), calidad y utilidad básica
    if score == 0 and itemLevel and itemLevel > 0 then
        local qualityMult = (itemQuality == 2 and 1.5) or (itemQuality == 3 and 2.0) or (itemQuality == 4 and 2.8) or 1.0
        score = itemLevel * 0.8 * qualityMult
    end

    return math.floor(score * 10) / 10
end

--- Mapea nombres de ranuras de interfaz a ranuras de inventario de WoW
local SLOT_TO_INVENTORY_ID = {
    ["Head"]          = 1,
    ["Neck"]          = 2,
    ["Shoulder"]      = 3,
    ["Back"]          = 15,
    ["Chest"]         = 5,
    ["Wrists"]        = 9,
    ["Hands"]         = 10,
    ["Waist"]         = 6,
    ["Legs"]          = 7,
    ["Feet"]          = 8,
    ["Finger"]        = 11,
    ["RFinger"]       = 12,
    ["Trinket"]       = 13,
    ["RTrinket"]      = 14,
    ["MainHand"]      = 16,
    ["SecondaryHand"] = 17,
    ["Relic"]         = 18,
}

--- Mapea tipo de ranura de GetItemInfo a ranura de Awakening
local EQUIPLOC_TO_SLOT = {
    ["INVTYPE_HEAD"]           = "Head",
    ["INVTYPE_NECK"]           = "Neck",
    ["INVTYPE_SHOULDER"]       = "Shoulder",
    ["INVTYPE_CLOAK"]          = "Back",
    ["INVTYPE_CHEST"]          = "Chest",
    ["INVTYPE_ROBE"]           = "Chest",
    ["INVTYPE_WRIST"]          = "Wrists",
    ["INVTYPE_HAND"]           = "Hands",
    ["INVTYPE_WAIST"]          = "Waist",
    ["INVTYPE_LEGS"]           = "Legs",
    ["INVTYPE_FEET"]           = "Feet",
    ["INVTYPE_FINGER"]         = "Finger",
    ["INVTYPE_TRINKET"]        = "Trinket",
    ["INVTYPE_WEAPON"]         = "MainHand",
    ["INVTYPE_SHIELD"]         = "SecondaryHand",
    ["INVTYPE_2HWEAPON"]       = "MainHand",
    ["INVTYPE_WEAPONMAINHAND"] = "MainHand",
    ["INVTYPE_WEAPONOFFHAND"]  = "SecondaryHand",
    ["INVTYPE_HOLDABLE"]       = "SecondaryHand",
    ["INVTYPE_RANGED"]         = "Relic",
    ["INVTYPE_THROWN"]         = "Relic",
    ["INVTYPE_RANGEDRIGHT"]    = "Relic",
    ["INVTYPE_RELIC"]          = "Relic",
}

--- Compara un objeto candidato con el objeto actualmente equipado en esa ranura
-- @param slotName string Ranura (ej: "Head", "Chest", "MainHand")
-- @param candidateItemID number|string ID o enlace del objeto a evaluar
-- @param classKeyOrSpec string (opcional)
-- @param maybeSpecKey string (opcional)
-- @return number upgradePct Porcentaje de mejora (+25.4%)
-- @return number diff Diferencia en puntos de score
-- @return number candidateScore Score del nuevo objeto
-- @return number equippedScore Score del objeto equipado
function ns.GetSlotUpgrade(slotName, candidateItemID, classKeyOrSpec, maybeSpecKey)
    if not candidateItemID or candidateItemID == 0 then return 0, 0, 0, 0 end

    local invSlotID = SLOT_TO_INVENTORY_ID[slotName] or 0
    local equippedItemID = 0

    if invSlotID > 0 and GetInventoryItemID then
        local ok, id = pcall(GetInventoryItemID, "player", invSlotID)
        if ok and id then
            equippedItemID = id
        end
    end

    local candidateScore = ns.GetItemScore(candidateItemID, classKeyOrSpec, maybeSpecKey)
    local equippedScore = equippedItemID > 0 and ns.GetItemScore(equippedItemID, classKeyOrSpec, maybeSpecKey) or 0

    local diff = candidateScore - equippedScore
    local upgradePct = 0

    if equippedScore > 0 then
        upgradePct = (diff / equippedScore) * 100
    elseif candidateScore > 0 then
        upgradePct = 100 -- Ranura vacía = 100% de mejora directa
    end

    upgradePct = math.floor(upgradePct * 10) / 10
    return upgradePct, diff, candidateScore, equippedScore
end

--- Formatea el texto de mejora con código de colores para la UI
function ns.FormatUpgradeText(upgradePct)
    if upgradePct > 0 then
        return string.format("|cFF00FF00+%.1f%% Mejora|r", upgradePct)
    elseif upgradePct == 0 then
        return "|cFF888888Equivalente|r"
    else
        return string.format("|cFFFF4040%.1f%% Inferior|r", upgradePct)
    end
end

--- Abre o busca un objeto en AtlasLoot Classic si está instalado
function ns.OpenInAtlasLoot(itemName, itemID)
    if not _G.AtlasLoot then return false end

    -- Limpiar texto enriquecido de WoW para la búsqueda
    local cleanName = itemName or ""
    if type(cleanName) == "string" then
        cleanName = cleanName:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("%[", ""):gsub("%]", ""):gsub("^%s*(.-)%s*$", "%1")
    end

    if _G.AtlasLoot.SlashCommands and cleanName ~= "" then
        pcall(function()
            _G.AtlasLoot.SlashCommands:Run("search " .. cleanName)
        end)
        return true
    end

    if _G.AtlasLoot.GUI and _G.AtlasLoot.GUI.Toggle then
        pcall(function() _G.AtlasLoot.GUI:Toggle() end)
        return true
    end

    return false
end

-- -------------------------------------------------------------------------
-- INTEGRACIÓN CON TOOLTIPS (Soporte Universal para WoW Forever & Classic)
-- -------------------------------------------------------------------------
local function ProcessTooltipItem(selfTooltip, itemLinkOrID)
    if not selfTooltip then return end
    if not itemLinkOrID and selfTooltip.GetItem then
        local _, link = selfTooltip:GetItem()
        itemLinkOrID = link
    end
    if not itemLinkOrID then return end

    local playerClass = select(2, UnitClass("player")) or "WARRIOR"
    local specKey = ns.GetClassDefaultEnchantSpec and ns.GetClassDefaultEnchantSpec(playerClass)
    local weights, specDisplayName = ns.GetStatWeights(playerClass, specKey)

    -- Extraer ranura equipable
    local itemEquipLoc
    if GetItemInfo then
        local _, _, _, _, _, _, _, _, eqLoc = GetItemInfo(itemLinkOrID)
        itemEquipLoc = eqLoc
    end
    if not itemEquipLoc or itemEquipLoc == "" or itemEquipLoc == "INVTYPE_NON_EQUIP" then
        return
    end

    local score = ns.GetItemScore(itemLinkOrID, playerClass, specKey)
    if score and score > 0 then
        selfTooltip:AddLine(" ")
        selfTooltip:AddDoubleLine(
            "|cFF00FFCCAwakening Score:|r",
            string.format("|cFFFFD100%.1f pts|r |cFF888888(%s)|r", score, specDisplayName or "General")
        )

        local slotName = EQUIPLOC_TO_SLOT[itemEquipLoc]
        if slotName and ns.GetSlotUpgrade then
            local pctUpgrade, _, _, eqScore = ns.GetSlotUpgrade(slotName, itemLinkOrID, playerClass, specKey)
            if pctUpgrade and pctUpgrade > 0 then
                selfTooltip:AddDoubleLine(
                    "|cFF00FF00▲ Mejora estimada:|r",
                    string.format("|cFF00FF00+%.1f%%|r |cFF888888(vs actual %.1f)|r", pctUpgrade, eqScore or 0)
                )
            end
        end

        if _G.AtlasLoot then
            selfTooltip:AddLine("|cFF00FFCCAlt+Clic:|r Buscar en AtlasLoot Classic", 0.5, 0.8, 1)
        end

        selfTooltip:Show()
    end
end

pcall(function()
    -- 1. WoW Forever / Classic 1.15+ (TooltipDataProcessor oficial de Blizzard)
    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType and Enum.TooltipDataType.Item then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tt, data)
            if tt and data then
                local item = data.hyperlink or data.id
                ProcessTooltipItem(tt, item)
            end
        end)
        return
    end

    -- 2. WoW Classic Legacy (HookScript seguro comprobando HasScript primero)
    if GameTooltip and GameTooltip.HasScript and GameTooltip:HasScript("OnTooltipSetItem") and GameTooltip.HookScript then
        GameTooltip:HookScript("OnTooltipSetItem", function(selfTooltip)
            ProcessTooltipItem(selfTooltip, nil)
        end)
    end
end)
