import re

raidprep_path = "/home/justicary/proyectos/antigravity/AwakeningCompanion/Modules/RaidPrep.lua"

with open(raidprep_path, "r", encoding="utf-8") as f:
    content = f.read()

# 1. State variables replacement
old_state = """-- Variables de Estado
local containerFrame = nil
local rowFrames = {}
local selectedIndex = 1
local previewRaidMode = false"""

new_state = """-- Variables de Estado
local containerFrame = nil
local rowFrames = {}
local selectedIndex = 1
local previewRaidMode = false

-- =========================================================================
-- VARIABLES Y CONSTANTES DE CAMPAMENTO ÓPTIMO (WOW FOREVER)
-- =========================================================================
RaidPrep.currentSubMode = "consumables" -- "consumables" o "camping"
local _, playerClassInit = UnitClass("player")
playerClassInit = playerClassInit or "WARRIOR"
RaidPrep.partyClasses = { playerClassInit, "PRIEST", "MAGE", "ROGUE", "DRUID" }
RaidPrep.selectedCampfireKey = "journeyman" -- 5 ranuras por defecto (ideal grupo mazmorra)
RaidPrep.selectedCampIndex = 1
local campingRowFrames = {}

local CLASS_CYCLE = {
    "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID", "NONE"
}

local CLASS_NAMES_ES = {
    ["WARRIOR"] = "Guerrero",
    ["PALADIN"] = "Paladín",
    ["HUNTER"]  = "Cazador",
    ["ROGUE"]   = "Pícaro",
    ["PRIEST"]  = "Sacerdote",
    ["SHAMAN"]  = "Chamán",
    ["MAGE"]    = "Mago",
    ["WARLOCK"] = "Brujo",
    ["DRUID"]   = "Druida",
    ["NONE"]    = "(Vacío)",
}

local CLASS_COLORS = {
    ["WARRIOR"] = "C79C6E",
    ["PALADIN"] = "F58CBA",
    ["HUNTER"]  = "ABD473",
    ["ROGUE"]   = "FFF569",
    ["PRIEST"]  = "FFFFFF",
    ["SHAMAN"]  = "0070DE",
    ["MAGE"]    = "69CCF0",
    ["WARLOCK"] = "9482C9",
    ["DRUID"]   = "FF7D0A",
    ["NONE"]    = "888888",
}"""

assert old_state in content, "old_state not found"
content = content.replace(old_state, new_state, 1)

# 2. Add GetOptimizedCampingList right before Build(parent)
target_before_build = """-- =========================================================================
-- CONSTRUCCIÓN DE LA VISTA PREPARACIÓN
-- =========================================================================
function RaidPrep:Build(parent)"""

camping_calc_code = """-- =========================================================================
-- OPTIMIZADOR DE CAMPAMENTOS PARA GRUPO (WOW FOREVER)
-- =========================================================================
function RaidPrep:GetOptimizedCampingList()
    local db = ns.Data and ns.Data.Camping
    if not db or not db.Items then return {}, {}, {}, nil, 0 end

    -- 1. Obtener el fogón seleccionado
    local selectedFire = nil
    for _, fire in ipairs(db.Campfires) do
        if fire.key == self.selectedCampfireKey then
            selectedFire = fire
            break
        end
    end
    if not selectedFire then selectedFire = db.Campfires[2] end -- Oficial (5 ranuras) por defecto

    -- 2. Analizar la composición del grupo
    local activeClasses = {}
    local hasCasters = false
    local hasMelees = false
    local partyCount = 0

    for i = 1, 5 do
        local c = self.partyClasses[i]
        if c and c ~= "NONE" then
            activeClasses[c] = true
            partyCount = partyCount + 1
            if c == "MAGE" or c == "PRIEST" or c == "WARLOCK" or c == "DRUID" or c == "SHAMAN" then
                hasCasters = true
            end
            if c == "WARRIOR" or c == "ROGUE" or c == "HUNTER" or c == "PALADIN" or c == "DRUID" or c == "SHAMAN" then
                hasMelees = true
            end
        end
    end

    -- 3. Agrupar el mejor ítem de cada profesión (Tier 1 o Tier 2)
    local seenProfs = {}
    for _, item in ipairs(db.Items) do
        local key = item.profKey
        if not seenProfs[key] or (item.tier > seenProfs[key].tier) then
            seenProfs[key] = item
        end
    end

    local evaluated = {}
    local discarded = {}

    for profKey, item in pairs(seenProfs) do
        local entry = {
            id = item.id,
            name = item.name,
            profession = item.profession,
            profKey = item.profKey,
            tier = item.tier,
            skillReq = item.skillReq,
            icon = item.icon,
            effect = item.effect,
            effectDesc = item.effectDesc,
            classCopy = item.classCopy,
            conflictClass = item.conflictClass,
            conflictReason = item.conflictReason,
            source = item.source,
            roleTarget = item.roleTarget,
        }

        -- Verificar si la clase que otorga el bufo nativo está en el grupo
        if item.conflictClass and activeClasses[item.conflictClass] then
            entry.isConflicted = true
            entry.conflictNote = item.conflictReason
            entry.priority = -1
            table.insert(discarded, entry)
        else
            entry.isConflicted = false
            local prio = item.basePriority or 50

            -- Ponderación contextual según roles en grupo
            if profKey == "Fishing" then
                prio = 100 -- Pecera (+8% a todas las estadísticas) es la #1 absoluta si no hay Paladín
            elseif profKey == "First Aid" then
                prio = 95 -- Botiquín (+Aguante) es vital si no hay Sacerdote
            elseif profKey == "Leatherworking" then
                prio = 90 -- Tienda (+5% Rested XP) beneficio universal de leveleo y mazmorras
            elseif profKey == "Engineering" then
                prio = 88 -- Robot de reparación / componentes en la estancia
            elseif profKey == "Cooking" then
                prio = 82 -- Festín de comida de aguante
            elseif profKey == "Skinning" then
                prio = 78 -- +Crítico global
            elseif profKey == "Herbalism" then
                prio = hasCasters and 75 or 55 -- +Intelecto
            elseif profKey == "Alchemy" then
                prio = hasCasters and 72 or 52 -- Mp5 sostenido
            elseif profKey == "Mining" then
                prio = hasMelees and 70 or 48 -- +Melee AP
            elseif profKey == "Blacksmithing" then
                prio = hasMelees and 66 or 45 -- +Fuerza
            elseif profKey == "Enchanting" then
                prio = 60 -- Armadura y Resistencias
            elseif profKey == "Tailoring" then
                prio = hasCasters and 50 or 40 -- +Espíritu
            end

            entry.priority = prio
            table.insert(evaluated, entry)
        end
    end

    -- 4. Ordenar candidatos por prioridad descendente
    table.sort(evaluated, function(a, b)
        return (a.priority or 0) > (b.priority or 0)
    end)

    -- 5. Asignar ranuras del fogón disponible
    local maxSlots = selectedFire and selectedFire.slots or 5
    local recommended = {}
    local alternatives = {}

    for i, entry in ipairs(evaluated) do
        if i <= maxSlots then
            entry.isRecommended = true
            entry.slotOrder = i
            table.insert(recommended, entry)
        else
            entry.isRecommended = false
            entry.isAlternative = true
            table.insert(alternatives, entry)
        end
    end

    -- 6. Construir lista completa (Recomendados -> Alternativas -> Descartados por solapamiento)
    local fullList = {}
    for _, it in ipairs(recommended) do table.insert(fullList, it) end
    for _, it in ipairs(alternatives) do table.insert(fullList, it) end
    for _, it in ipairs(discarded) do table.insert(fullList, it) end

    return fullList, recommended, discarded, selectedFire, partyCount
end

-- =========================================================================
-- CONSTRUCCIÓN DE LA VISTA PREPARACIÓN
-- =========================================================================
function RaidPrep:Build(parent)"""

assert target_before_build in content, "target_before_build not found"
content = content.replace(target_before_build, camping_calc_code, 1)

with open(raidprep_path, "w", encoding="utf-8") as f:
    f.write(content)

print("First pass applied successfully.")
