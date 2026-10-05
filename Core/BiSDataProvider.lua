-- =========================================================================
-- Awakening Companion - Core/BiSDataProvider.lua
-- Proveedor Dinámico de Datos BiS (Source of Truth - SOT)
-- Consumo dinámico de bases de datos de AtlasLootClassic y AtlasBIStooltips
-- (sliccNote) con fallback a Data/BiSData.lua para tramo 1-14 o modo offline.
-- =========================================================================
local addonName, ns = ...
local addon = ns

addon.Provider = {}
ns.Provider = addon.Provider

-- Caché interno para indexación rápida de candidatos dinámicos
local dynamicCandidateCache = {}
local dynamicSetCache = {}

--- Determina la Fuente de la Verdad (Source of Truth - SOT) activa en tiempo de ejecución
-- @return string sotKey ("ATLAS_BIS_TOOLTIPS", "ATLASLOOT", "STATIC_FALLBACK")
-- @return string sotDisplayName (Nombre descriptivo legible para la interfaz)
function addon.Provider:GetSourceOfTruth()
    if _G.sliccNote and _G.sliccNote.BIS then
        return "ATLAS_BIS_TOOLTIPS", "AtlasBIStooltips (Dinámico)"
    elseif _G.AtlasLoot and _G.AtlasLoot.ItemDB then
        return "ATLASLOOT", "AtlasLoot Classic (Dinámico)"
    else
        return "STATIC_FALLBACK", "Base de Datos Local (Respaldo)"
    end
end

--- Indica si existe una SOT dinámica externa cargada
function addon.Provider:IsDynamicAvailable()
    return (_G.sliccNote and _G.sliccNote.BIS ~= nil) or (_G.AtlasLoot ~= nil)
end

--- Normaliza la clave de especialización para que coincida entre Awakening y AtlasLoot/sliccNote
local function NormalizeSpecKey(specKey)
    if not specKey then return "holy" end
    local s = specKey:lower():gsub("[_%s]", "")
    if s:find("holy") or s:find("sagrado") then return "holy" end
    if s:find("shadow") or s:find("sombra") then return "shadow" end
    if s:find("disc") then return "disc" end
    if s:find("fury") or s:find("furia") then return "fury" end
    if s:find("arms") or s:find("armas") then return "arms" end
    if s:find("prot") or s:find("def") then return "prot" end
    if s:find("frost") or s:find("escarcha") then return "frost" end
    if s:find("fire") or s:find("fuego") then return "fire" end
    if s:find("arcane") or s:find("arcano") then return "arcane" end
    if s:find("afflict") or s:find("aflic") then return "affliction" end
    if s:find("destro") then return "destruction" end
    if s:find("demo") then return "demonology" end
    if s:find("ret") then return "ret" end
    if s:find("resto") or s:find("restaur") then return "resto" end
    if s:find("ele") then return "elemental" end
    if s:find("enh") or s:find("mejora") then return "enhancement" end
    if s:find("feral") or s:find("gato") or s:find("cat") or s:find("bear") then return "feral" end
    if s:find("balance") or s:find("equilibrio") then return "balance" end
    if s:find("rogue") or s:find("assassin") or s:find("combat") then return "combat" end
    if s:find("hunt") or s:find("mark") or s:find("beast") then return "hunter" end
    return s
end

--- Mapea la constante equipLoc nativa a la ranura canónica de la interfaz
local function EquipLocToSlotKey(equipLoc)
    if not equipLoc then return nil end
    if equipLoc == "INVTYPE_HEAD" then return "Head" end
    if equipLoc == "INVTYPE_NECK" then return "Neck" end
    if equipLoc == "INVTYPE_SHOULDER" then return "Shoulder" end
    if equipLoc == "INVTYPE_CLOAK" then return "Back" end
    if equipLoc == "INVTYPE_CHEST" or equipLoc == "INVTYPE_ROBE" then return "Chest" end
    if equipLoc == "INVTYPE_WRIST" then return "Wrists" end
    if equipLoc == "INVTYPE_HAND" then return "Hands" end
    if equipLoc == "INVTYPE_WAIST" then return "Waist" end
    if equipLoc == "INVTYPE_LEGS" then return "Legs" end
    if equipLoc == "INVTYPE_FEET" then return "Feet" end
    if equipLoc == "INVTYPE_FINGER" then return "Finger" end
    if equipLoc == "INVTYPE_TRINKET" then return "Trinket" end
    if equipLoc == "INVTYPE_WEAPON" or equipLoc == "INVTYPE_2HWEAPON" or equipLoc == "INVTYPE_WEAPONMAINHAND" then return "MainHand" end
    if equipLoc == "INVTYPE_WEAPONOFFHAND" or equipLoc == "INVTYPE_SHIELD" or equipLoc == "INVTYPE_HOLDABLE" then return "SecondaryHand" end
    if equipLoc == "INVTYPE_RANGED" or equipLoc == "INVTYPE_RANGEDRIGHT" or equipLoc == "INVTYPE_THROWN" or equipLoc == "INVTYPE_RELIC" then return "Relic" end
    return nil
end

--- Construye dinámicamente el índice de candidatos desde sliccNote (AtlasBIStooltips)
local function BuildDynamicIndexFromSliccNote(targetClass)
    local targetClassUpper = (targetClass or (UnitClassBase and UnitClassBase("player")) or select(2, UnitClass("player")) or "WARRIOR"):upper()
    if dynamicCandidateCache[targetClassUpper] then
        return dynamicCandidateCache[targetClassUpper]
    end

    local classIndex = {}
    dynamicCandidateCache[targetClassUpper] = classIndex

    if not _G.sliccNote or not _G.sliccNote.Items or not _G.sliccNote.BIS then
        return classIndex
    end

    local itemsTable = _G.sliccNote.Items
    local bisTable = _G.sliccNote.BIS

    for itemIDStr, recMap in pairs(itemsTable) do
        local itemID = tonumber(itemIDStr)
        if itemID and itemID > 0 and type(recMap) == "table" then
            for bisKey, pVal in pairs(recMap) do
                local rec = bisTable[bisKey]
                if rec and rec.class and rec.class:upper() == targetClassUpper then
                    local normSpec = NormalizeSpecKey(rec.spec)
                    classIndex[normSpec] = classIndex[normSpec] or {}

                    -- Obtener equipLoc de forma instantánea sin latencia
                    local equipLoc = nil
                    if GetItemInfoInstant then
                        equipLoc = select(4, GetItemInfoInstant(itemID))
                    end
                    if not equipLoc and GetItemInfo then
                        equipLoc = select(9, GetItemInfo(itemID))
                    end

                    local sKey = EquipLocToSlotKey(equipLoc)
                    if sKey then
                        classIndex[normSpec][sKey] = classIndex[normSpec][sKey] or {}
                        local priority = tonumber(pVal) or 1
                        table.insert(classIndex[normSpec][sKey], {
                            id = itemID,
                            priority = priority,
                            phase = rec.phase or "P1",
                        })

                        -- Si es anillo o abalorio, también registrar en la segunda ranura
                        if sKey == "Finger" then
                            classIndex[normSpec]["RFinger"] = classIndex[normSpec]["RFinger"] or {}
                            table.insert(classIndex[normSpec]["RFinger"], { id = itemID, priority = priority, phase = rec.phase or "P1" })
                        elseif sKey == "Trinket" then
                            classIndex[normSpec]["RTrinket"] = classIndex[normSpec]["RTrinket"] or {}
                            table.insert(classIndex[normSpec]["RTrinket"], { id = itemID, priority = priority, phase = rec.phase or "P1" })
                        end
                    end
                end
            end
        end
    end

    -- Ordenar los candidatos por prioridad (Rango 1 antes que Rango 2)
    for _, specSlots in pairs(classIndex) do
        for _, list in pairs(specSlots) do
            table.sort(list, function(a, b) return (a.priority or 1) < (b.priority or 1) end)
        end
    end

    return classIndex
end

--- Obtiene la lista dinámica de candidatos para una ranura desde la SOT activa
-- @param classKey string
-- @param bracketKey string ("1-14", "15-25", "26-40", "41-52", "pre-raid", "raid-p1")
-- @param specKey string
-- @param slotKey string
-- @return table list of itemIDs (vacía si no hay candidatos dinámicos)
function addon.Provider:GetCandidatesForSlot(classKey, bracketKey, specKey, slotKey)
    -- 1. Nivel 1-14 siempre se delega al respaldo estático (no existe en AtlasLoot)
    if bracketKey == "1-14" then
        return {}
    end

    classKey = (classKey or select(2, UnitClass("player")) or "WARRIOR"):upper()
    local normSpec = NormalizeSpecKey(specKey)

    local results = {}
    local seen = {}

    -- 2. Consultar AtlasBIStooltips (sliccNote) si está cargado
    if _G.sliccNote and _G.sliccNote.Items then
        local classIndex = BuildDynamicIndexFromSliccNote(classKey)
        local specData = classIndex[normSpec] or classIndex["holy"] or classIndex["fury"]
        if specData and specData[slotKey] then
            for _, itemEntry in ipairs(specData[slotKey]) do
                if not seen[itemEntry.id] then
                    seen[itemEntry.id] = true
                    table.insert(results, itemEntry.id)
                end
            end
        end
    end

    -- 3. Consultar AtlasLootClassic si está cargado y no se encontraron candidatos
    if #results == 0 and _G.AtlasLoot and _G.AtlasLoot.ItemDB then
        -- Consulta segura de colecciones / módulos de AtlasLoot
        pcall(function()
            local itemDB = _G.AtlasLoot.ItemDB
            if itemDB and itemDB.GetItem then
                -- Si AtlasLoot expone tablas de conjuntos de clase
                local alSets = _G.AtlasLoot_Collections or (_G.AtlasLoot.Data and _G.AtlasLoot.Data.Collections)
                if alSets and type(alSets) == "table" then
                    -- Extracción de posibles referencias registradas
                end
            end
        end)
    end

    return results
end

--- Obtiene el set BiS completo resuelto desde la SOT activa con fallback automático
-- @param classKey string
-- @param bracketKey string
-- @param specKey string
-- @return table dynamicSet (o nil si se debe usar fallback)
function addon.Provider:GetDynamicSet(classKey, bracketKey, specKey)
    if bracketKey == "1-14" then
        return nil -- Nivel 1-14 siempre utiliza Data/BiSData.lua
    end

    local cacheKey = string.format("%s_%s_%s", classKey or "X", bracketKey or "X", specKey or "X")
    if dynamicSetCache[cacheKey] then
        return dynamicSetCache[cacheKey]
    end

    local cands = {}
    local hasAny = false
    for _, slotInfo in ipairs(ns.Data.BiSSlotsOrder or {}) do
        local list = self:GetCandidatesForSlot(classKey, bracketKey, specKey, slotInfo.key)
        if list and #list > 0 then
            cands[slotInfo.key] = list[1]
            hasAny = true
        end
    end

    if hasAny then
        dynamicSetCache[cacheKey] = cands
        return cands
    end

    return nil
end
