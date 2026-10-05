-- =========================================================================
-- Awakening Companion - Core/ItemValidator.lua
-- Validador Canónico de Ranuras, Competencias y Requisitos de Objetos BiS
-- Compatible con WoW Classic Era, WoW Forever Beta y cliente moderno 1.15+
-- =========================================================================
local _, addon = ...
addon = addon or {}
addon.Validator = {}

local ns = addon
if _G.AwakeningData then
    AwakeningData.Validator = addon.Validator
end

-- =========================================================================
-- CONSTANTES Y TABLAS DE COMPETENCIA CANÓNICA
-- =========================================================================

-- Matriz de armaduras permitidas según clase (UnitClassBase("player"))
-- Matriz de armaduras permitidas según clase (UnitClassBase("player"))
-- Nota: Cazadores y Chamanes usan Cuero hasta Nivel 39 (Malla a partir de Nivel 40).
-- Guerreros y Paladines usan Malla hasta Nivel 39 (Placas a partir de Nivel 40).
local CLASS_ARMOR_PROFICIENCY = {
    ["PRIEST"]  = { ["Cloth"] = true, ["Miscellaneous"] = true },
    ["MAGE"]    = { ["Cloth"] = true, ["Miscellaneous"] = true },
    ["WARLOCK"] = { ["Cloth"] = true, ["Miscellaneous"] = true },
    ["ROGUE"]   = { ["Cloth"] = false, ["Leather"] = true, ["Miscellaneous"] = true },
    ["DRUID"]   = { ["Cloth"] = true, ["Leather"] = true, ["Miscellaneous"] = true },
    ["HUNTER"]  = { ["Cloth"] = false, ["Leather"] = true, ["Mail"] = false },
    ["SHAMAN"]  = { ["Cloth"] = true, ["Leather"] = true, ["Mail"] = false },
    ["WARRIOR"] = { ["Cloth"] = false, ["Leather"] = true, ["Mail"] = true },
    ["PALADIN"] = { ["Cloth"] = true, ["Leather"] = true, ["Mail"] = true },
}

-- Matriz canónica de armaduras óptimas permitidas según Especialización y Rol
-- En WoW Classic:
-- - Clases/specs físicas (Guerrero, Pícaro, Cazador, Druida Feral, Chamán Mejora, Paladín Ret/Prot)
--   NUNCA deben llevar piezas de Tela en ranuras de armadura (Casco, Hombros, Pechera, Guantes, Pantalones, etc.).
-- - Las capas (Back / CLOAK) son la única excepción ya que en el motor de Classic son todas clasificadas como Tela.
local SPEC_ARMOR_RESTRICTIONS = {
    ["PRIEST"]  = { default = { ["Cloth"] = true, ["Miscellaneous"] = true } },
    ["MAGE"]    = { default = { ["Cloth"] = true, ["Miscellaneous"] = true } },
    ["WARLOCK"] = { default = { ["Cloth"] = true, ["Miscellaneous"] = true } },
    ["ROGUE"]   = { default = { ["Leather"] = true, ["Miscellaneous"] = true } },
    ["HUNTER"]  = { default = { ["Leather"] = true, ["Mail"] = true, ["Miscellaneous"] = true } },
    ["WARRIOR"] = { default = { ["Leather"] = true, ["Mail"] = true, ["Plate"] = true, ["Miscellaneous"] = true } },
    ["PALADIN"] = {
        ["holy"]        = { ["Cloth"] = true, ["Leather"] = true, ["Mail"] = true, ["Plate"] = true, ["Miscellaneous"] = true },
        ["retribution"] = { ["Leather"] = true, ["Mail"] = true, ["Plate"] = true, ["Miscellaneous"] = true },
        ["ret"]         = { ["Leather"] = true, ["Mail"] = true, ["Plate"] = true, ["Miscellaneous"] = true },
        ["prot"]        = { ["Mail"] = true, ["Plate"] = true, ["Miscellaneous"] = true },
        default         = { ["Leather"] = true, ["Mail"] = true, ["Plate"] = true, ["Miscellaneous"] = true },
    },
    ["SHAMAN"] = {
        ["enhancement"] = { ["Leather"] = true, ["Mail"] = true, ["Miscellaneous"] = true },
        ["resto"]       = { ["Cloth"] = true, ["Leather"] = true, ["Mail"] = true, ["Miscellaneous"] = true },
        ["elemental"]   = { ["Cloth"] = true, ["Leather"] = true, ["Mail"] = true, ["Miscellaneous"] = true },
        default         = { ["Leather"] = true, ["Mail"] = true, ["Miscellaneous"] = true },
    },
    ["DRUID"] = {
        ["feral_cat"]   = { ["Leather"] = true, ["Miscellaneous"] = true }, -- Druida Feral: EXCLUSIVAMENTE Cuero
        ["feral_bear"]  = { ["Leather"] = true, ["Miscellaneous"] = true },
        ["feral"]       = { ["Leather"] = true, ["Miscellaneous"] = true },
        ["resto"]       = { ["Cloth"] = true, ["Leather"] = true, ["Miscellaneous"] = true },
        ["balance"]     = { ["Cloth"] = true, ["Leather"] = true, ["Miscellaneous"] = true },
        default         = { ["Leather"] = true, ["Miscellaneous"] = true },
    },
}

-- Mapeo de roles de combate para evitar mezcla de especializaciones incongruentes
local SPEC_ROLES = {
    ["feral_cat"]     = "MELEE",
    ["feral_bear"]    = "TANK",
    ["feral"]         = "MELEE",
    ["resto"]         = "HEALER",
    ["balance"]       = "CASTER",
    ["fury"]          = "MELEE",
    ["arms"]          = "MELEE",
    ["prot"]          = "TANK",
    ["protection"]    = "TANK",
    ["holy"]          = "HEALER",
    ["retribution"]   = "MELEE",
    ["ret"]           = "MELEE",
    ["shadow"]        = "CASTER",
    ["discipline"]    = "HEALER",
    ["disc"]          = "HEALER",
    ["elemental"]     = "CASTER",
    ["enhancement"]   = "MELEE",
    ["frost"]         = "CASTER",
    ["fire"]          = "CASTER",
    ["arcane"]        = "CASTER",
    ["affliction"]    = "CASTER",
    ["destruction"]   = "CASTER",
    ["demonology"]    = "CASTER",
    ["combat"]        = "MELEE",
    ["assassination"] = "MELEE",
    ["subtlety"]      = "MELEE",
    ["marksman"]      = "RANGED",
    ["bm"]            = "RANGED",
    ["survival"]      = "RANGED",
}

-- Restricciones de tipo de equipamiento de armas según especialización
-- Tanques con escudo (Guerrero Prot, Paladín Prot) y Pícaros NUNCA pueden llevar armas de 2 manos (2H).
local SPEC_DISALLOWED_EQUIPLOC = {
    ["prot"]          = { ["INVTYPE_2HWEAPON"] = true },
    ["protection"]    = { ["INVTYPE_2HWEAPON"] = true },
    ["holy"]          = { ["INVTYPE_2HWEAPON"] = true },
    ["combat"]        = { ["INVTYPE_2HWEAPON"] = true },
    ["assassination"] = { ["INVTYPE_2HWEAPON"] = true },
    ["subtlety"]      = { ["INVTYPE_2HWEAPON"] = true },
    ["sword"]         = { ["INVTYPE_2HWEAPON"] = true },
    ["dagger"]        = { ["INVTYPE_2HWEAPON"] = true },
}

-- Mapeo estricto de Ranura UI a constantes equipLoc de Blizzard
local SLOT_TO_EQUIPLOC = {
    ["HEAD"]           = { ["INVTYPE_HEAD"] = true },
    ["Head"]           = { ["INVTYPE_HEAD"] = true },
    ["NECK"]           = { ["INVTYPE_NECK"] = true },
    ["Neck"]           = { ["INVTYPE_NECK"] = true },
    ["SHOULDER"]       = { ["INVTYPE_SHOULDER"] = true },
    ["Shoulder"]       = { ["INVTYPE_SHOULDER"] = true },
    ["SHOULDERS"]      = { ["INVTYPE_SHOULDER"] = true },
    ["CLOAK"]          = { ["INVTYPE_CLOAK"] = true },
    ["Back"]           = { ["INVTYPE_CLOAK"] = true },
    ["BACK"]           = { ["INVTYPE_CLOAK"] = true },
    ["CHEST"]          = { ["INVTYPE_CHEST"] = true, ["INVTYPE_ROBE"] = true },
    ["Chest"]          = { ["INVTYPE_CHEST"] = true, ["INVTYPE_ROBE"] = true },
    ["WRIST"]          = { ["INVTYPE_WRIST"] = true },
    ["Wrists"]         = { ["INVTYPE_WRIST"] = true },
    ["WRISTS"]         = { ["INVTYPE_WRIST"] = true },
    ["HANDS"]          = { ["INVTYPE_HAND"] = true },
    ["Hands"]          = { ["INVTYPE_HAND"] = true },
    ["HAND"]           = { ["INVTYPE_HAND"] = true },
    ["WAIST"]          = { ["INVTYPE_WAIST"] = true },
    ["Waist"]          = { ["INVTYPE_WAIST"] = true },
    ["LEGS"]           = { ["INVTYPE_LEGS"] = true },
    ["Legs"]           = { ["INVTYPE_LEGS"] = true },
    ["FEET"]           = { ["INVTYPE_FEET"] = true },
    ["Feet"]           = { ["INVTYPE_FEET"] = true },
    ["FINGER"]         = { ["INVTYPE_FINGER"] = true },
    ["Finger"]         = { ["INVTYPE_FINGER"] = true },
    ["RFinger"]        = { ["INVTYPE_FINGER"] = true },
    ["FINGER_1"]       = { ["INVTYPE_FINGER"] = true },
    ["FINGER_2"]       = { ["INVTYPE_FINGER"] = true },
    ["TRINKET"]        = { ["INVTYPE_TRINKET"] = true },
    ["Trinket"]        = { ["INVTYPE_TRINKET"] = true },
    ["RTrinket"]       = { ["INVTYPE_TRINKET"] = true },
    ["TRINKET_1"]      = { ["INVTYPE_TRINKET"] = true },
    ["TRINKET_2"]      = { ["INVTYPE_TRINKET"] = true },
    ["MAIN_HAND"]      = { ["INVTYPE_WEAPON"] = true, ["INVTYPE_2HWEAPON"] = true, ["INVTYPE_WEAPONMAINHAND"] = true },
    ["MainHand"]       = { ["INVTYPE_WEAPON"] = true, ["INVTYPE_2HWEAPON"] = true, ["INVTYPE_WEAPONMAINHAND"] = true },
    ["OFF_HAND"]       = { ["INVTYPE_WEAPON"] = true, ["INVTYPE_WEAPONOFFHAND"] = true, ["INVTYPE_SHIELD"] = true, ["INVTYPE_HOLDABLE"] = true },
    ["SecondaryHand"]  = { ["INVTYPE_WEAPON"] = true, ["INVTYPE_WEAPONOFFHAND"] = true, ["INVTYPE_SHIELD"] = true, ["INVTYPE_HOLDABLE"] = true },
    ["RANGED"]         = { ["INVTYPE_RANGED"] = true, ["INVTYPE_RANGEDRIGHT"] = true, ["INVTYPE_THROWN"] = true, ["INVTYPE_RELIC"] = true },
    ["Relic"]          = { ["INVTYPE_RANGED"] = true, ["INVTYPE_RANGEDRIGHT"] = true, ["INVTYPE_THROWN"] = true, ["INVTYPE_RELIC"] = true }
}

-- Normalización de nombres de ranuras para máxima compatibilidad
local function NormalizeSlotKey(slot)
    if not slot then return nil end
    local s = slot:upper():gsub("[_%s]", "")
    if s == "SHOULDER" or s == "SHOULDERS" then return "SHOULDER" end
    if s == "CLOAK" or s == "BACK" then return "CLOAK" end
    if s == "WRIST" or s == "WRISTS" then return "WRIST" end
    if s == "HAND" or s == "HANDS" then return "HANDS" end
    if s == "FINGER" or s == "RFINGER" or s == "FINGER1" or s == "FINGER2" then return "FINGER" end
    if s == "TRINKET" or s == "RTRINKET" or s == "TRINKET1" or s == "TRINKET2" then return "TRINKET" end
    if s == "MAINHAND" or s == "MAINHANDWEAPON" then return "MAIN_HAND" end
    if s == "SECONDARYHAND" or s == "OFFHAND" then return "OFF_HAND" end
    if s == "RANGED" or s == "RELIC" then return "RANGED" end
    return s
end

-- Subclases numéricas de armadura (Enum.ItemArmorSubclass)
local ARMOR_SUBCLASS_MAP = {
    [0] = "Miscellaneous",
    [1] = "Cloth",
    [2] = "Leather",
    [3] = "Mail",
    [4] = "Plate",
    [6] = "Shield",
}

-- Normalización multilingüe de subtipos de armadura
local LOCALIZED_ARMOR_NAMES = {
    ["cloth"] = "Cloth",
    ["tela"] = "Cloth",
    ["leather"] = "Leather",
    ["cuero"] = "Leather",
    ["mail"] = "Mail",
    ["malla"] = "Mail",
    ["plate"] = "Plate",
    ["placas"] = "Plate",
    ["miscellaneous"] = "Miscellaneous",
    ["miscelánea"] = "Miscellaneous",
    ["miscelanea"] = "Miscellaneous",
    ["diverso"] = "Miscellaneous",
    ["shield"] = "Shield",
    ["escudos"] = "Shield",
    ["escudo"] = "Shield",
}

-- Matriz de armas permitidas por clase en WoW Classic
local CLASS_WEAPON_PROFICIENCY = {
    ["PRIEST"]  = { ["Daggers"] = true, ["One-Handed Maces"] = true, ["Staves"] = true, ["Wands"] = true },
    ["MAGE"]    = { ["Daggers"] = true, ["One-Handed Swords"] = true, ["Staves"] = true, ["Wands"] = true },
    ["WARLOCK"] = { ["Daggers"] = true, ["One-Handed Swords"] = true, ["Staves"] = true, ["Wands"] = true },
    ["ROGUE"]   = { ["Daggers"] = true, ["One-Handed Swords"] = true, ["One-Handed Maces"] = true, ["Fist Weapons"] = true, ["Bows"] = true, ["Crossbows"] = true, ["Guns"] = true, ["Thrown"] = true },
    ["DRUID"]   = { ["Daggers"] = true, ["One-Handed Maces"] = true, ["Two-Handed Maces"] = true, ["Polearms"] = true, ["Staves"] = true, ["Fist Weapons"] = true, ["Idols"] = true, ["Relics"] = true },
    ["HUNTER"]  = { ["Daggers"] = true, ["One-Handed Swords"] = true, ["Two-Handed Swords"] = true, ["One-Handed Axes"] = true, ["Two-Handed Axes"] = true, ["Polearms"] = true, ["Staves"] = true, ["Fist Weapons"] = true, ["Bows"] = true, ["Crossbows"] = true, ["Guns"] = true },
    ["SHAMAN"]  = { ["Daggers"] = true, ["One-Handed Maces"] = true, ["Two-Handed Maces"] = true, ["One-Handed Axes"] = true, ["Two-Handed Axes"] = true, ["Staves"] = true, ["Fist Weapons"] = true, ["Totems"] = true, ["Relics"] = true },
    ["WARRIOR"] = { ["Daggers"] = true, ["One-Handed Swords"] = true, ["Two-Handed Swords"] = true, ["One-Handed Maces"] = true, ["Two-Handed Maces"] = true, ["One-Handed Axes"] = true, ["Two-Handed Axes"] = true, ["Polearms"] = true, ["Staves"] = true, ["Fist Weapons"] = true, ["Bows"] = true, ["Crossbows"] = true, ["Guns"] = true, ["Thrown"] = true },
    ["PALADIN"] = { ["One-Handed Swords"] = true, ["Two-Handed Swords"] = true, ["One-Handed Maces"] = true, ["Two-Handed Maces"] = true, ["One-Handed Axes"] = true, ["Two-Handed Axes"] = true, ["Polearms"] = true, ["Librams"] = true, ["Relics"] = true },
}

-- Subclases numéricas de armas (Enum.ItemWeaponSubclass)
local WEAPON_SUBCLASS_MAP = {
    [0]  = "One-Handed Axes",
    [1]  = "Two-Handed Axes",
    [2]  = "Bows",
    [3]  = "Guns",
    [4]  = "One-Handed Maces",
    [5]  = "Two-Handed Maces",
    [6]  = "Polearms",
    [7]  = "One-Handed Swords",
    [8]  = "Two-Handed Swords",
    [10] = "Staves",
    [13] = "Fist Weapons",
    [14] = "Miscellaneous",
    [15] = "Daggers",
    [16] = "Thrown",
    [18] = "Crossbows",
    [19] = "Wands",
    [20] = "Fishing Poles",
}

-- Normalización multilingüe de subtipos de armas
local LOCALIZED_WEAPON_NAMES = {
    ["daggers"] = "Daggers",
    ["dagas"] = "Daggers",
    ["one-handed swords"] = "One-Handed Swords",
    ["espadas de una mano"] = "One-Handed Swords",
    ["two-handed swords"] = "Two-Handed Swords",
    ["espadas de dos manos"] = "Two-Handed Swords",
    ["one-handed maces"] = "One-Handed Maces",
    ["mazas de una mano"] = "One-Handed Maces",
    ["two-handed maces"] = "Two-Handed Maces",
    ["mazas de dos manos"] = "Two-Handed Maces",
    ["one-handed axes"] = "One-Handed Axes",
    ["hachas de una mano"] = "One-Handed Axes",
    ["two-handed axes"] = "Two-Handed Axes",
    ["hachas de dos manos"] = "Two-Handed Axes",
    ["staves"] = "Staves",
    ["bastones"] = "Staves",
    ["polearms"] = "Polearms",
    ["armas de asta"] = "Polearms",
    ["bows"] = "Bows",
    ["arcos"] = "Bows",
    ["guns"] = "Guns",
    ["armas de fuego"] = "Guns",
    ["crossbows"] = "Crossbows",
    ["ballestas"] = "Crossbows",
    ["wands"] = "Wands",
    ["varitas"] = "Wands",
    ["fist weapons"] = "Fist Weapons",
    ["armas de puño"] = "Fist Weapons",
    ["thrown"] = "Thrown",
    ["arrojadizas"] = "Thrown",
}

-- =========================================================================
-- TOOLTIP DE ESCANEO OCULTO (SCANNING TOOLTIP)
-- =========================================================================
local scanTooltip = CreateFrame("GameTooltip", "AwakeningItemValidatorScanTooltip", nil, "GameTooltipTemplate")
scanTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")

-- Profesiones conocidas y sus palabras clave en español e inglés
local PROFESSION_KEYWORDS = {
    { key = "Engineering",    pattern = "ingenier",     nameEs = "Ingeniería" },
    { key = "Engineering",    pattern = "engineering",  nameEs = "Ingeniería" },
    { key = "Tailoring",      pattern = "sastrer",      nameEs = "Sastrería" },
    { key = "Tailoring",      pattern = "tailoring",    nameEs = "Sastrería" },
    { key = "Leatherworking", pattern = "peleter",      nameEs = "Peletería" },
    { key = "Leatherworking", pattern = "leatherworking", nameEs = "Peletería" },
    { key = "Blacksmithing",  pattern = "herrer",       nameEs = "Herrería" },
    { key = "Blacksmithing",  pattern = "blacksmithing", nameEs = "Herrería" },
    { key = "Alchemy",        pattern = "alquimi",      nameEs = "Alquimia" },
    { key = "Alchemy",        pattern = "alchemy",      nameEs = "Alquimia" },
    { key = "Enchanting",     pattern = "encantamient", nameEs = "Encantamiento" },
    { key = "Enchanting",     pattern = "enchanting",   nameEs = "Encantamiento" },
    { key = "Mining",         pattern = "miner",        nameEs = "Minería" },
    { key = "Mining",         pattern = "mining",       nameEs = "Minería" },
    { key = "Herbalism",      pattern = "herborister",  nameEs = "Herboristería" },
    { key = "Herbalism",      pattern = "herbalism",    nameEs = "Herboristería" },
    { key = "Skinning",       pattern = "desuello",     nameEs = "Desuello" },
    { key = "Skinning",       pattern = "skinning",     nameEs = "Desuello" },
    { key = "First Aid",      pattern = "primeros auxilios", nameEs = "Primeros Auxilios" },
    { key = "First Aid",      pattern = "first aid",    nameEs = "Primeros Auxilios" },
    { key = "Cooking",        pattern = "cocina",       nameEs = "Cocina" },
    { key = "Cooking",        pattern = "cooking",      nameEs = "Cocina" },
    { key = "Fishing",        pattern = "pesca",        nameEs = "Pesca" },
    { key = "Fishing",        pattern = "fishing",      nameEs = "Pesca" },
}

-- =========================================================================
-- MÉTODOS DE DETECCIÓN Y COMPROBACIÓN DE PROFESIONES
-- =========================================================================

--- Comprueba si el jugador posee la profesión activa y el rango requerido
-- @param profKey string (ej. "Engineering", "Tailoring")
-- @param requiredRank number (opcional)
-- @return boolean hasProfession
function addon.Validator:PlayerHasProfession(profKey, requiredRank)
    if not profKey then return true end

    -- 1. Consulta mediante el mapa normalizado de ns.GetPlayerProfessions()
    if ns and ns.GetPlayerProfessions then
        local profs = ns.GetPlayerProfessions()
        if profs and profs[profKey] then
            if requiredRank and requiredRank > 0 then
                return (profs[profKey].rank or 0) >= requiredRank
            end
            return true
        end
    end

    -- 2. Consulta mediante API nativa GetProfessions() / GetProfessionInfo()
    if GetProfessions and GetProfessionInfo then
        local p1, p2, p3, p4, p5, p6 = GetProfessions()
        for _, pIndex in ipairs({ p1, p2, p3, p4, p5, p6 }) do
            if pIndex then
                local pName, _, skillLvl = GetProfessionInfo(pIndex)
                if pName then
                    local norm = ns and ns.NormalizeProfession and ns.NormalizeProfession(pName)
                    if norm == profKey or pName:lower():find(profKey:lower()) then
                        if requiredRank and requiredRank > 0 then
                            return (skillLvl or 0) >= requiredRank
                        end
                        return true
                    end
                end
            end
        end
    end

    -- 3. Consulta en líneas de habilidades clásicas (GetNumSkillLines / GetSkillLineInfo)
    if GetNumSkillLines and GetSkillLineInfo then
        local numSkills = GetNumSkillLines()
        for i = 1, numSkills do
            local skillName, isHeader, _, skillRank = GetSkillLineInfo(i)
            if not isHeader and skillName then
                local norm = ns and ns.NormalizeProfession and ns.NormalizeProfession(skillName)
                if norm == profKey or skillName:lower():find(profKey:lower()) then
                    if requiredRank and requiredRank > 0 then
                        return (skillRank or 0) >= requiredRank
                    end
                    return true
                end
            end
        end
    end

    return false
end

--- Extrae el requisito de profesión de una cadena de texto (ej. "Requiere Ingeniería (150)")
local function ParseProfessionRequirement(text)
    if not text or type(text) ~= "string" then return nil, nil end
    local lower = text:lower()

    if not lower:find("requier") and not lower:find("require") then
        return nil, nil
    end

    for _, entry in ipairs(PROFESSION_KEYWORDS) do
        if lower:find(entry.pattern) then
            local rank = tonumber(lower:match("%((%d+)%)") or lower:match("(%d+)"))
            return entry.key, rank
        end
    end

    return nil, nil
end

--- Escanea los requisitos del objeto mediante ScanningTooltip y metadatos registrados
-- @param itemID number
-- @return boolean meetsRequirements
-- @return string|nil failedReason
function addon.Validator:PlayerMeetsItemRequirements(itemID)
    if not itemID or itemID == 0 then return true end

    -- 1. Verificación rápida contra metadatos en ns.Data.BiSItems
    if ns and ns.Data and ns.Data.BiSItems and ns.Data.BiSItems[itemID] then
        local meta = ns.Data.BiSItems[itemID]
        local sourceText = (meta.source or "") .. " " .. (meta.name or "") .. " " .. (meta.drop or "")
        local pKey, pRank = ParseProfessionRequirement(sourceText)
        if not pKey and meta.source and (meta.source:find("Ingeniería") or meta.source:find("Engineering")) then
            pKey = "Engineering"
            pRank = tonumber(meta.source:match("%((%d+)%)") or meta.source:match("(%d+)"))
        end

        if pKey and not self:PlayerHasProfession(pKey, pRank) then
            return false, "PROFESSION_LOCKED"
        end
    end

    -- 2. Escaneo en vivo con TooltipDataProcessor (Cliente moderno 1.15+)
    if C_TooltipInfo and C_TooltipInfo.GetItemByID then
        local ok, data = pcall(C_TooltipInfo.GetItemByID, itemID)
        if ok and data and data.lines then
            for _, line in ipairs(data.lines) do
                local leftText = line.leftText
                if leftText and type(leftText) == "string" then
                    local pKey, pRank = ParseProfessionRequirement(leftText)
                    if pKey and not self:PlayerHasProfession(pKey, pRank) then
                        return false, "PROFESSION_LOCKED"
                    end
                end
            end
            return true
        end
    end

    -- 3. Escaneo con GameTooltip tradicional (Classic Era / Legacy)
    if scanTooltip then
        scanTooltip:ClearLines()
        if scanTooltip.SetItemByID then
            pcall(scanTooltip.SetItemByID, scanTooltip, itemID)
        else
            pcall(scanTooltip.SetHyperlink, scanTooltip, "item:" .. itemID)
        end

        local numLines = scanTooltip:NumLines() or 0
        for i = 1, numLines do
            local line = _G["AwakeningItemValidatorScanTooltipTextLeft" .. i]
            if line then
                local text = line:GetText()
                if text and text ~= "" then
                    local pKey, pRank = ParseProfessionRequirement(text)
                    if pKey and not self:PlayerHasProfession(pKey, pRank) then
                        return false, "PROFESSION_LOCKED"
                    end
                end
            end
        end
    end

    return true
end

-- =========================================================================
-- DETECCIÓN DE OBJETOS ÚNICOS Y ÚNICO-EQUIPADOS (UNIQUE / UNIQUE-EQUIPPED)
-- =========================================================================
local uniqueItemCache = {}

--- Determina si un objeto es Único o Único-Equipado (Unique / Unique-Equipped)
-- @param itemID number
-- @return boolean isUnique
function addon.Validator:IsItemUniqueEquipped(itemID)
    if not itemID or itemID == 0 then return false end
    if uniqueItemCache[itemID] ~= nil then
        return uniqueItemCache[itemID]
    end

    -- 1. Verificación rápida en metadatos registrados (Data/BiSData.lua)
    local meta = ns and ns.Data and ns.Data.BiSItems and ns.Data.BiSItems[itemID]
    if meta and (meta.unique == true or meta.uniqueEquipped == true) then
        uniqueItemCache[itemID] = true
        return true
    end

    -- 2. API C_Item.GetItemUniquenessByID (Cliente moderno / Classic Era 1.15+)
    if C_Item and C_Item.GetItemUniquenessByID then
        local ok, isUnique, limitCategoryName, limitCategoryCount = pcall(C_Item.GetItemUniquenessByID, itemID)
        if ok and (isUnique or (limitCategoryCount and limitCategoryCount > 0)) then
            uniqueItemCache[itemID] = true
            return true
        end
    end

    -- 3. Escaneo con C_TooltipInfo (1.15+ TooltipDataProcessor)
    if C_TooltipInfo and C_TooltipInfo.GetItemByID then
        local ok, data = pcall(C_TooltipInfo.GetItemByID, itemID)
        if ok and data and data.lines then
            for _, line in ipairs(data.lines) do
                local text = line.leftText
                if text and type(text) == "string" then
                    local lower = text:lower()
                    if lower:find("unique") or lower:find("único") or lower:find("unico") then
                        uniqueItemCache[itemID] = true
                        return true
                    end
                end
            end
        end
    end

    -- 4. Escaneo clásico mediante GameTooltip oculto
    if scanTooltip then
        scanTooltip:ClearLines()
        local ok = false
        if scanTooltip.SetItemByID then
            ok = pcall(scanTooltip.SetItemByID, scanTooltip, itemID)
        else
            ok = pcall(scanTooltip.SetHyperlink, scanTooltip, "item:" .. itemID)
        end
        if ok then
            local numLines = scanTooltip:NumLines() or 0
            for i = 1, numLines do
                local line = _G["AwakeningItemValidatorScanTooltipTextLeft" .. i]
                if line then
                    local text = line:GetText()
                    if text and text ~= "" then
                        local lower = text:lower()
                        if lower:find("unique") or lower:find("único") or lower:find("unico") then
                            uniqueItemCache[itemID] = true
                            return true
                        end
                    end
                end
            end
        end
    end

    -- Si el objeto ya está en caché del cliente y no arrojó Unique:
    if GetItemInfo and GetItemInfo(itemID) then
        uniqueItemCache[itemID] = false
    end

    return false
end

-- =========================================================================
-- VALIDACIÓN DE COMPETENCIAS DE ARMADURAS Y ARMAS
-- =========================================================================

--- Función auxiliar para normalizar claves de especialización
local function NormalizeSpec(specKey)
    if not specKey then return "" end
    local s = tostring(specKey):lower():gsub("[_%s%-]", "")
    if s:find("cat") or s:find("gato") then return "feral_cat" end
    if s:find("bear") or s:find("oso") then return "feral_bear" end
    if s:find("feral") then return "feral_cat" end
    if s:find("resto") or s:find("restaur") then return "resto" end
    if s:find("balance") or s:find("equilibrio") or s:find("pollo") then return "balance" end
    if s:find("holy") or s:find("sagrado") then return "holy" end
    if s:find("prot") or s:find("def") then return "prot" end
    if s:find("ret") then return "retribution" end
    if s:find("enh") or s:find("mejora") then return "enhancement" end
    if s:find("ele") then return "elemental" end
    if s:find("shadow") or s:find("sombra") then return "shadow" end
    if s:find("disc") then return "discipline" end
    if s:find("mark") or s:find("punter") then return "marksman" end
    if s:find("bm") or s:find("beast") or s:find("bestia") then return "bm" end
    if s:find("surv") or s:find("superv") then return "survival" end
    if s:find("sword") or s:find("combat") then return "combat" end
    if s:find("dagger") or s:find("assassin") or s:find("asesin") then return "assassination" end
    if s:find("sub") or s:find("sutil") then return "subtlety" end
    return s
end

--- Obtiene la matriz de armaduras permitidas según clase, nivel y especialización
function addon.Validator:GetAllowedArmors(playerClass, playerLevel, specKey)
    playerLevel = tonumber(playerLevel) or (UnitLevel and UnitLevel("player")) or 1
    playerClass = (playerClass or (UnitClassBase and UnitClassBase("player")) or select(2, UnitClass("player")) or "WARRIOR"):upper()

    local classRestrictions = SPEC_ARMOR_RESTRICTIONS[playerClass]
    local base = nil
    if classRestrictions then
        local normSpec = NormalizeSpec(specKey)
        base = classRestrictions[normSpec] or classRestrictions.default or classRestrictions
    end

    if not base then
        base = CLASS_ARMOR_PROFICIENCY[playerClass] or { ["Cloth"] = true, ["Miscellaneous"] = true }
    end

    local copy = {}
    for k, v in pairs(base) do
        copy[k] = v
    end

    -- Escalamiento de habilidades por nivel en WoW Classic:
    -- Cazador y Chamán no pueden vestir Malla antes de Nivel 40
    if playerClass == "HUNTER" or playerClass == "SHAMAN" then
        copy["Mail"] = (playerLevel >= 40) and (base["Mail"] == true)
    end

    -- Guerrero y Paladín no pueden vestir Placas antes de Nivel 40
    if playerClass == "WARRIOR" or playerClass == "PALADIN" then
        copy["Plate"] = (playerLevel >= 40) and (base["Plate"] == true)
    end

    return copy
end

--- Comprueba si una clase puede empuñar un tipo de arma
function addon.Validator:IsWeaponAllowed(playerClass, subclassID, itemSubType, equipLoc)
    playerClass = (playerClass or select(2, UnitClass("player")) or "WARRIOR"):upper()
    local allowedWeapons = CLASS_WEAPON_PROFICIENCY[playerClass]
    if not allowedWeapons then return true end

    local canonicalWeapon = WEAPON_SUBCLASS_MAP[subclassID]
    if not canonicalWeapon and itemSubType then
        canonicalWeapon = LOCALIZED_WEAPON_NAMES[itemSubType:lower()] or itemSubType
    end

    if not canonicalWeapon then return true end

    -- Paladines y Sacerdotes no usan arcos ni armas arrojadizas
    if equipLoc == "INVTYPE_RANGED" or equipLoc == "INVTYPE_THROWN" or equipLoc == "INVTYPE_RANGEDRIGHT" then
        if playerClass == "PALADIN" or playerClass == "DRUID" then
            return false
        end
    end

    return allowedWeapons[canonicalWeapon] == true
end

-- =========================================================================
-- VALIDACIÓN CANÓNICA COMPLETA DE ELEGIBILIDAD (API PRINCIPAL)
-- =========================================================================

--- Valida de forma rigurosa si un objeto puede pertenecer a la ranura BiS indicada
-- @param itemID number
-- @param targetSlot string (ej: "HEAD", "Head", "NECK", "Neck", "LEGS", "Legs")
-- @param playerClass string (ej: "PRIEST", "WARRIOR")
-- @param targetLevel number (nivel de evaluación, ej. techo del tramo 25 o nivel del jugador)
-- @param allowProfLocked boolean (opcional, si es true permite retornar objetos con profesión bloqueada)
-- @param specKey string (opcional, especialización activa para filtrado estricto de armadura)
-- @return boolean isEligible
-- @return string reason ("OK", "PROVISIONAL", "NOT_CACHED", "WRONG_SLOT", "INVALID_ARMOR_TYPE", "INVALID_WEAPON_TYPE", "LEVEL_TOO_HIGH", "PROFESSION_LOCKED")
-- @return table|nil itemData ({ name, texture, quality, link, minLevel, isProfLocked, isProvisional })
function addon.Validator:IsItemEligible(itemID, targetSlot, playerClass, targetLevel, allowProfLocked, specKey)
    if not itemID or itemID == 0 then
        return false, "INVALID_ID"
    end

    targetLevel = tonumber(targetLevel) or (UnitLevel and UnitLevel("player")) or 60
    playerClass = (playerClass or (UnitClassBase and UnitClassBase("player")) or select(2, UnitClass("player")) or "WARRIOR"):upper()

    local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
          itemStackCount, equipLoc, itemTexture, sellPrice, classID, subclassID = GetItemInfo(itemID)

    -- 0. Validación preliminar instantánea de ranura con GetItemInfoInstant (evita falsos positivos por latencia de caché)
    if GetItemInfoInstant then
        local _, _, _, instantEquipLoc = GetItemInfoInstant(itemID)
        if instantEquipLoc and instantEquipLoc ~= "" then
            local slotLocs = SLOT_TO_EQUIPLOC[targetSlot] or SLOT_TO_EQUIPLOC[NormalizeSlotKey(targetSlot)]
            if slotLocs and not slotLocs[instantEquipLoc] then
                return false, "WRONG_SLOT"
            end
        end
    end

    if not itemName then
        local meta = ns and ns.Data and ns.Data.BiSItems and ns.Data.BiSItems[itemID]
        if meta then
            return true, "PROVISIONAL", {
                name = meta.name or ("Objeto #" .. itemID),
                link = nil,
                texture = "Interface\\Icons\\INV_Misc_QuestionMark",
                quality = meta.quality or 3,
                itemLevel = 0,
                minLevel = 0,
                isProvisional = true,
            }
        end
        return false, "NOT_CACHED"
    end

    -- 1. Validar que la ranura corresponda exactamente según equipLoc
    local slotLocs = SLOT_TO_EQUIPLOC[targetSlot] or SLOT_TO_EQUIPLOC[NormalizeSlotKey(targetSlot)]
    if not slotLocs or not slotLocs[equipLoc] then
        return false, "WRONG_SLOT"
    end

    local armorClassID = (Enum and Enum.ItemClass and Enum.ItemClass.Armor) or 4
    local weaponClassID = (Enum and Enum.ItemClass and Enum.ItemClass.Weapon) or 2

    -- 2. Validar tipo de armadura para la clase y especialización
    if classID == armorClassID then
        -- Capas: En WoW Classic todas las capas son de Tela (subclassID == 1 / Cloth).
        -- Todo personaje puede equipar capas de tela sin restricción de armadura.
        if equipLoc == "INVTYPE_CLOAK" or targetSlot == "Back" or targetSlot == "CLOAK" then
            -- Capas siempre permitidas
        elseif equipLoc == "INVTYPE_SHIELD" or subclassID == 6 then
            -- Escudos: solo Guerrero, Paladín y Chamán pueden usarlos
            if playerClass ~= "WARRIOR" and playerClass ~= "PALADIN" and playerClass ~= "SHAMAN" then
                return false, "CANNOT_USE_SHIELD"
            end
        else
            local allowedArmors = self:GetAllowedArmors(playerClass, targetLevel, specKey)
            local armorKey = ARMOR_SUBCLASS_MAP[subclassID]
            if not armorKey and itemSubType then
                armorKey = LOCALIZED_ARMOR_NAMES[itemSubType:lower()] or itemSubType
            end

            -- Si es armadura con clasificación (Tela, Cuero, Malla, Placas):
            if armorKey and armorKey ~= "Miscellaneous" and armorKey ~= "Shield" then
                if not allowedArmors or allowedArmors[armorKey] ~= true then
                    return false, "INVALID_ARMOR_TYPE"
                end
            elseif itemSubType and allowedArmors and (allowedArmors[itemSubType] == false) then
                return false, "INVALID_ARMOR_TYPE"
            end
        end
    end

    -- 2b. Validar armas para la clase y restricciones de estilo de combate
    if classID == weaponClassID then
        if not self:IsWeaponAllowed(playerClass, subclassID, itemSubType, equipLoc) then
            return false, "INVALID_WEAPON_TYPE"
        end

        local normSpec = NormalizeSpec(specKey)
        if SPEC_DISALLOWED_EQUIPLOC[normSpec] and SPEC_DISALLOWED_EQUIPLOC[normSpec][equipLoc] then
            return false, "CANNOT_USE_2H_WEAPON"
        end

        if playerClass == "ROGUE" and equipLoc == "INVTYPE_2HWEAPON" then
            return false, "CANNOT_USE_2H_WEAPON"
        end
    end

    -- 2c. Validar que tanques (Guerrero Prot, Paladín Prot) equipen exclusivamente Escudo en mano secundaria
    local normSlot = NormalizeSlotKey(targetSlot)
    if normSlot == "OFF_HAND" or targetSlot == "SecondaryHand" then
        local normSpec = NormalizeSpec(specKey)
        if (normSpec == "prot" or normSpec == "protection") and (playerClass == "WARRIOR" or playerClass == "PALADIN") then
            if equipLoc ~= "INVTYPE_SHIELD" and subclassID ~= 6 then
                return false, "TANK_REQUIRES_SHIELD"
            end
        end
    end

    -- 3. Validar nivel requerido contra el techo del tramo evaluado (targetLevel)
    if itemMinLevel and targetLevel and itemMinLevel > targetLevel then
        return false, "LEVEL_TOO_HIGH"
    end

    -- 4. Validar requerimientos de profesión activa
    local meetsProf = self:PlayerMeetsItemRequirements(itemID)
    if not meetsProf then
        if allowProfLocked then
            return true, "PROFESSION_LOCKED", {
                name = itemName,
                link = itemLink,
                texture = itemTexture,
                quality = itemQuality,
                itemLevel = itemLevel,
                minLevel = itemMinLevel,
                isProfLocked = true,
            }
        end
        return false, "PROFESSION_LOCKED"
    end

    return true, "OK", {
        name = itemName,
        link = itemLink,
        texture = itemTexture,
        quality = itemQuality,
        itemLevel = itemLevel,
        minLevel = itemMinLevel,
    }
end

-- =========================================================================
-- RESOLUCIÓN DINÁMICA DE MEJOR CANDIDATO POR RANURA
-- =========================================================================

--- Obtiene la lista de candidatos evaluables para una ranura específica
function addon.Validator:GetCandidateItemsForSlot(classKey, bracketKey, specKey, slotKey)
    classKey = (classKey or select(2, UnitClass("player")) or "WARRIOR"):upper()
    bracketKey = bracketKey or (ns.GetDefaultBiSBracket and ns.GetDefaultBiSBracket()) or "pre-raid"
    local candidates = {}
    local seen = {}

    local function addID(id)
        if id and type(id) == "number" and id > 0 and not seen[id] then
            seen[id] = true
            table.insert(candidates, id)
        end
    end

    local normKey = NormalizeSlotKey(slotKey)
    local normSpec = NormalizeSpec(specKey)
    local myRole = SPEC_ROLES[normSpec] or "GENERAL"

    -- 0. Candidatos dinámicos desde la SOT activa (AtlasBIStooltips / AtlasLoot)
    local provider = addon.Provider or (ns and ns.Provider)
    if provider and provider.GetCandidatesForSlot and bracketKey ~= "1-14" then
        local dynList = provider:GetCandidatesForSlot(classKey, bracketKey, specKey, slotKey)
        if dynList and #dynList > 0 then
            for _, id in ipairs(dynList) do
                addID(id)
            end
        end
    end

    -- 1. Objeto(s) asignados en el activeSet actual (PRIORIDAD MÁXIMA DE LA ESPECIALIZACIÓN)
    local classData = ns.Data and ns.Data.BiS and (ns.Data.BiS[classKey] or ns.Data.BiS[classKey:upper()])
    local bracketSets = classData and classData.sets and classData.sets[bracketKey]
    local activeSet = bracketSets and (bracketSets[specKey] or bracketSets[normSpec] or (classData.specs and classData.specs[1] and bracketSets[classData.specs[1].key]))

    if activeSet then
        local rawVal = activeSet[slotKey] or (normKey and activeSet[normKey])
        if type(rawVal) == "table" then
            for _, id in ipairs(rawVal) do addID(id) end
        elseif type(rawVal) == "number" then
            addID(rawVal)
        end
    end

    -- 2. Candidatos adicionales registrados en ns.Data.BiSCandidates para esta clase/bracket
    if ns.Data and ns.Data.BiSCandidates then
        local classCand = ns.Data.BiSCandidates[classKey] or ns.Data.BiSCandidates[classKey:upper()]
        local bracketCand = classCand and classCand[bracketKey]
        local slotCand = bracketCand and (bracketCand[slotKey] or (normKey and bracketCand[normKey]))
        if type(slotCand) == "table" then
            for _, id in ipairs(slotCand) do addID(id) end
        elseif type(slotCand) == "number" then
            addID(slotCand)
        end
    end

    -- 3. Objetos de otras especializaciones de la misma clase SOLO SI COMPARTEN ROL COMPATIBLE
    -- NUNCA compartir ranuras de armas (MainHand, SecondaryHand, Relic) entre distintas especializaciones,
    -- ya que cada especialización posee un arquetipo propio (ej: 1H+Escudo en Tanque vs 2H en Armas vs Dual-Wield en Furia).
    local isWeaponSlot = (slotKey == "MainHand" or slotKey == "SecondaryHand" or slotKey == "Relic" or slotKey == "Ranged"
        or normKey == "MAIN_HAND" or normKey == "OFF_HAND" or normKey == "RANGED")

    if bracketSets and not isWeaponSlot then
        for sKey, setObj in pairs(bracketSets) do
            if sKey ~= specKey and sKey ~= normSpec and type(setObj) == "table" then
                local otherNorm = NormalizeSpec(sKey)
                local otherRole = SPEC_ROLES[otherNorm] or "OTHER"
                local isCompatible = (myRole == otherRole) or
                    (myRole == "MELEE" and otherRole == "TANK") or
                    (myRole == "TANK" and otherRole == "MELEE")

                -- Solo compartir si son roles compatibles o si es ranura accesoria neutra
                local isAccessorySlot = (slotKey == "Finger" or slotKey == "RFinger" or slotKey == "Trinket" or slotKey == "RTrinket" or slotKey == "Neck" or slotKey == "Back")
                if isCompatible or isAccessorySlot then
                    local otherVal = setObj[slotKey] or (normKey and setObj[normKey])
                    if type(otherVal) == "table" then
                        for _, id in ipairs(otherVal) do addID(id) end
                    elseif type(otherVal) == "number" then
                        addID(otherVal)
                    end
                end
            end
        end
    end

    return candidates
end

--- Selecciona el mejor objeto disponible para una ranura usando filtros y StatWeights
-- @param classKey string
-- @param bracketKey string
-- @param specKey string
-- @param slotKey string
-- @param playerLevel number (opcional)
-- @param bracketMaxLevel number (opcional, techo de nivel del tramo)
-- @param excludedItemIDs table|nil (mapa de itemIDs ya asignados como únicos para evitar duplicidad)
-- @return number bestItemID (0 si ningún candidato es apto)
-- @return number bestScore
-- @return table|nil bestMeta
-- @return string statusReason
function addon.Validator:GetBestItemForSlot(classKey, bracketKey, specKey, slotKey, playerLevel, bracketMaxLevel, excludedItemIDs)
    playerLevel = tonumber(playerLevel) or (UnitLevel and UnitLevel("player")) or 1
    classKey = (classKey or (UnitClassBase and UnitClassBase("player")) or select(2, UnitClass("player")) or "WARRIOR"):upper()

    if not bracketMaxLevel then
        local classData = ns.Data and ns.Data.BiS and (ns.Data.BiS[classKey] or ns.Data.BiS[classKey:upper()])
        if classData and classData.brackets then
            for _, b in ipairs(classData.brackets) do
                if b.key == bracketKey then
                    bracketMaxLevel = b.maxLevel
                    break
                end
            end
        end
    end
    bracketMaxLevel = bracketMaxLevel or (bracketKey == "1-14" and 14) or (bracketKey == "15-25" and 25) or (bracketKey == "26-40" and 40) or (bracketKey == "41-52" and 52) or 60

    local candidates = self:GetCandidateItemsForSlot(classKey, bracketKey, specKey, slotKey)
    local bestItemID = nil
    local bestScore = -1
    local bestMeta = nil
    local bestReason = "OK"
    local lastFailureReason = "NO_CANDIDATES"

    -- Pase 1: Buscar candidato elegible estricto (cumple clase, especialización, ranura, nivel de tramo y profesión)
    -- En caso de objetos únicos, se ignora si ya fue asignado a otra ranura (ej. Abalorio 1 vs Abalorio 2)
    for _, itemID in ipairs(candidates) do
        local isDuplicateUnique = excludedItemIDs and excludedItemIDs[itemID] and self:IsItemUniqueEquipped(itemID)
        if not isDuplicateUnique then
            local eligible, reason, meta = self:IsItemEligible(itemID, slotKey, classKey, bracketMaxLevel, false, specKey)
            if eligible then
                local score = (ns.GetItemScore and ns.GetItemScore(itemID, classKey, specKey)) or 0
                if score > bestScore then
                    bestScore = score
                    bestItemID = itemID
                    bestMeta = meta
                    bestReason = reason or "OK"
                elseif score == bestScore and not bestItemID then
                    bestItemID = itemID
                    bestMeta = meta
                    bestReason = reason or "OK"
                end
            else
                lastFailureReason = reason
            end
        else
            lastFailureReason = "DUPLICATE_UNIQUE"
        end
    end

    -- Pase 2: Si no hubo candidato elegible sin profesión, permitir candidatos bloqueados por profesión (ej. Abalorios o Gafas)
    if not bestItemID then
        for _, itemID in ipairs(candidates) do
            local isDuplicateUnique = excludedItemIDs and excludedItemIDs[itemID] and self:IsItemUniqueEquipped(itemID)
            if not isDuplicateUnique then
                local eligible, reason, meta = self:IsItemEligible(itemID, slotKey, classKey, bracketMaxLevel, true, specKey)
                if eligible and (reason == "PROFESSION_LOCKED" or (meta and meta.isProfLocked)) then
                    local score = (ns.GetItemScore and ns.GetItemScore(itemID, classKey, specKey)) or 0
                    if score > bestScore then
                        bestScore = score
                        bestItemID = itemID
                        bestMeta = meta
                        bestReason = "PROFESSION_LOCKED"
                    elseif not bestItemID then
                        bestItemID = itemID
                        bestMeta = meta
                        bestReason = "PROFESSION_LOCKED"
                    end
                end
            end
        end
    end

    -- Pase 3: Si sigue sin haber candidato pero el set base tenía un itemID > 0 definido:
    if not bestItemID then
        local classData = ns.Data and ns.Data.BiS and (ns.Data.BiS[classKey] or ns.Data.BiS[classKey:upper()])
        local bracketSets = classData and classData.sets and classData.sets[bracketKey]
        local activeSet = bracketSets and (bracketSets[specKey] or (classData.specs and classData.specs[1] and bracketSets[classData.specs[1].key]))
        local normKey = NormalizeSlotKey(slotKey)
        local rawID = activeSet and (activeSet[slotKey] or (normKey and activeSet[normKey]))
        if type(rawID) == "number" and rawID > 0 then
            local isDuplicateUnique = excludedItemIDs and excludedItemIDs[rawID] and self:IsItemUniqueEquipped(rawID)
            if not isDuplicateUnique then
                local eligible, reason, meta = self:IsItemEligible(rawID, slotKey, classKey, bracketMaxLevel, true, specKey)
                if eligible or reason == "NOT_CACHED" or reason == "PROVISIONAL" then
                    return rawID, 0, meta, "PROVISIONAL"
                else
                    lastFailureReason = reason
                end
            else
                lastFailureReason = "DUPLICATE_UNIQUE"
            end
        end
    end

    if bestItemID then
        return bestItemID, bestScore, bestMeta, bestReason
    else
        return 0, 0, nil, lastFailureReason
    end
end

--- Recopila todos los itemIDs candidatos de la clase y nivel que requieren precarga
function addon.Validator:GetItemsToPreload(classKey, bracketKey, specKey)
    classKey = (classKey or select(2, UnitClass("player")) or "WARRIOR"):upper()
    bracketKey = bracketKey or (ns.GetDefaultBiSBracket and ns.GetDefaultBiSBracket()) or "pre-raid"
    local allIDs = {}
    local seen = {}

    for _, slotInfo in ipairs(ns.Data.BiSSlotsOrder or {}) do
        local cands = self:GetCandidateItemsForSlot(classKey, bracketKey, specKey, slotInfo.key)
        for _, id in ipairs(cands) do
            if id and id > 0 and not seen[id] then
                seen[id] = true
                table.insert(allIDs, id)
            end
        end
    end

    return allIDs
end

-- Exportación accesible para módulos
if ns then
    ns.Validator = addon.Validator
end
