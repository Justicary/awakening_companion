local ADDON, ns = ...

-- =========================================================================
-- CONSTANTES Y METADATOS CORE (Inspirado en Olympus Core.lua)
-- =========================================================================
ns.NAME = "Awakening: Companion"
ns.SHORT_NAME = "Awakening"
ns.VERSION = "1.0.0"
ns.COLOR_HEX = "00FFCC"
ns.COLOR_GOLD = "FFD100"
ns.REQUIRED_GUILD = "Awakening"
ns.DISCORD_URL = "https://discord.gg/awakening"

-- Tabla para almacenar módulos y datos
ns.Modules = ns.Modules or {}
ns.Data = ns.Data or {}

-- =========================================================================
-- UTILIDADES GLOBALES Y FORMATEO
-- =========================================================================
function ns.Print(msg)
    print(string.format("|cFF%s[%s]:|r %s", ns.COLOR_HEX, ns.SHORT_NAME, tostring(msg or "")))
end

function ns.Gold(text)
    return string.format("|cFF%s%s|r", ns.COLOR_GOLD, tostring(text or ""))
end

function ns.Green(text)
    return string.format("|cFF40FF40%s|r", tostring(text or ""))
end

function ns.Red(text)
    return string.format("|cFFFF4040%s|r", tostring(text or ""))
end

function ns.Grey(text)
    return string.format("|cFF9D9D9D%s|r", tostring(text or ""))
end

function ns.Cyan(text)
    return string.format("|cFF%s%s|r", ns.COLOR_HEX, tostring(text or ""))
end

-- Verificación de pertenencia a la hermandad exclusiva
function ns.IsAwakeningGuildMember()
    local guildName = GetGuildInfo("player")
    return guildName == ns.REQUIRED_GUILD
end

-- Ejecución segura (Protección contra errores de interfaz)
function ns.SafeCall(tag, func, ...)
    local ok, err = pcall(func, ...)
    if not ok then
        ns.Print(string.format("|cFFFF4444Error en [%s]:|r %s", tostring(tag), tostring(err)))
    end
    return ok, err
end

-- =========================================================================
-- MANEJO SEGURO DE COMBATE (Blizzard Lockdown Protection)
-- =========================================================================
local combatDeferredQueue = {}
local combatFrame = CreateFrame("Frame")
combatFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
combatFrame:SetScript("OnEvent", function()
    while #combatDeferredQueue > 0 do
        local task = table.remove(combatDeferredQueue, 1)
        if type(task) == "function" then
            pcall(task)
        end
    end
end)

function ns.QueueOutOfCombat(task)
    if InCombatLockdown() then
        table.insert(combatDeferredQueue, task)
        ns.Print("Acción encolada para cuando salgas de combate.")
    else
        task()
    end
end

-- =========================================================================
-- DETECCIÓN Y NORMALIZACIÓN DE PROFESIONES
-- =========================================================================
local PROFESSION_MAP = {
    ["minería"] = "Mining",
    ["mineria"] = "Mining",
    ["mining"] = "Mining",
    ["smelting"] = "Mining",
    ["fundición"] = "Mining",
    ["fundicion"] = "Mining",
    ["herboristería"] = "Herbalism",
    ["herboristeria"] = "Herbalism",
    ["herbalism"] = "Herbalism",
    ["desuello"] = "Skinning",
    ["skinning"] = "Skinning",
    ["pesca"] = "Fishing",
    ["fishing"] = "Fishing",
    ["sastrería"] = "Tailoring",
    ["sastreria"] = "Tailoring",
    ["tailoring"] = "Tailoring",
    ["peletería"] = "Leatherworking",
    ["peleteria"] = "Leatherworking",
    ["leatherworking"] = "Leatherworking",
    ["alquimia"] = "Alchemy",
    ["alchemy"] = "Alchemy",
    ["herrería"] = "Blacksmithing",
    ["herreria"] = "Blacksmithing",
    ["blacksmithing"] = "Blacksmithing",
    ["ingeniería"] = "Engineering",
    ["ingenieria"] = "Engineering",
    ["engineering"] = "Engineering",
    ["encantamiento"] = "Enchanting",
    ["enchanting"] = "Enchanting",
    ["cocina"] = "Cooking",
    ["cooking"] = "Cooking",
    ["primeros auxilios"] = "First Aid",
    ["first aid"] = "First Aid",
}

function ns.NormalizeProfession(name)
    if not name then return nil end
    local clean = name:lower():gsub("^%s+", ""):gsub("%s+$", "")
    return PROFESSION_MAP[clean] or name
end

function ns.GetPlayerProfessions()
    local profs = {}

    -- Método 1: GetNumSkillLines / GetSkillLineInfo (Estándar WoW Classic Era / Forever Beta)
    if GetNumSkillLines and GetSkillLineInfo then
        local numSkills = GetNumSkillLines()
        for i = 1, numSkills do
            local skillName, isHeader, _, skillRank, _, _, skillMaxRank = GetSkillLineInfo(i)
            if not isHeader and skillName then
                local cleanName = skillName:lower():gsub("^%s+", ""):gsub("%s+$", "")
                local normalized = PROFESSION_MAP[cleanName]
                if normalized then
                    profs[normalized] = {
                        name = skillName,
                        key = normalized,
                        rank = skillRank or 0,
                        maxRank = skillMaxRank or 0
                    }
                end
            end
        end
    end

    -- Método 2: GetProfessions + GetProfessionInfo (si la build soporta API moderna)
    if (not next(profs)) and GetProfessions and GetProfessionInfo then
        local p1, p2, p3, p4, p5, p6 = GetProfessions()
        for _, profIndex in ipairs({ p1, p2, p3, p4, p5, p6 }) do
            if profIndex then
                local name, icon, skillLevel, maxSkillLevel = GetProfessionInfo(profIndex)
                if name then
                    local cleanName = name:lower():gsub("^%s+", ""):gsub("%s+$", "")
                    local normalized = PROFESSION_MAP[cleanName] or name
                    profs[normalized] = {
                        name = name,
                        key = normalized,
                        rank = skillLevel or 0,
                        maxRank = maxSkillLevel or 0,
                        icon = icon
                    }
                end
            end
        end
    end

    -- Método 3: Chequeo de hechizos conocidos de recolección en Spellbook (Fail-safe universal)
    local gatheringSpellIDs = {
        { spellID = 2575, key = "Mining", defaultName = "Minería" },
        { spellID = 2366, key = "Herbalism", defaultName = "Herboristería" },
        { spellID = 8613, key = "Skinning", defaultName = "Desuello" },
        { spellID = 7620, key = "Fishing", defaultName = "Pesca" }
    }
    for _, item in ipairs(gatheringSpellIDs) do
        if not profs[item.key] then
            local isKnown = false
            if IsSpellKnown and IsSpellKnown(item.spellID) then
                isKnown = true
            elseif IsPlayerSpell and IsPlayerSpell(item.spellID) then
                isKnown = true
            end
            if isKnown then
                local spellName = (GetSpellInfo and GetSpellInfo(item.spellID)) or item.defaultName
                profs[item.key] = {
                    name = spellName,
                    key = item.key,
                    rank = 0,
                    maxRank = 300
                }
            end
        end
    end

    return profs
end

function ns.GetProfessionDisplayString()
    local profs = ns.GetPlayerProfessions()
    local list = {}
    for _, prof in pairs(profs) do
        if prof.rank and prof.rank > 0 then
            table.insert(list, string.format("%s (%d)", prof.name, prof.rank))
        else
            table.insert(list, prof.name)
        end
    end
    if #list == 0 then
        return ns.Grey("Ninguna detectada")
    end
    return ns.Green(table.concat(list, ", "))
end

-- =========================================================================
-- INICIALIZACIÓN Y SAVEDVARIABLES
-- =========================================================================
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:RegisterEvent("PLAYER_LOGIN")

initFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON then
        -- Inicializar base de datos guardada
        _G.AwakeningDB = _G.AwakeningDB or {}
        local db = _G.AwakeningDB
        db.showHUDOnSelect = (db.showHUDOnSelect == nil) and true or db.showHUDOnSelect
        db.soundAlerts = (db.soundAlerts == nil) and true or db.soundAlerts
        db.filterFarmingByProfessions = (db.filterFarmingByProfessions == nil) and true or db.filterFarmingByProfessions
        db.showOldSecrets = (db.showOldSecrets == nil) and false or db.showOldSecrets
        db.activeRoute = db.activeRoute or nil
        db.activeStep = db.activeStep or 1
        ns.db = db

        -- Exponer datos retrocompatibles
        _G.AwakeningData = _G.AwakeningData or {}
        _G.AwakeningData.Guides = ns.Data.Secrets
    elseif event == "PLAYER_LOGIN" then
        ns.Print(string.format("v%s cargado. Usa %s o %s para abrir el centro de control.", ns.VERSION, ns.Gold("/awakening"), ns.Gold("/awk")))
    end
end)

-- =========================================================================
-- COMANDOS SLASH
-- =========================================================================
SLASH_AWAKENING1 = "/awakening"
SLASH_AWAKENING2 = "/awk"

SlashCmdList["AWAKENING"] = function(msg)
    local cmd = (msg or ""):trim():lower()
    
    if cmd == "hud" then
        if ns.GuideHUD then
            ns.GuideHUD:Toggle()
        end
    elseif cmd == "bis" then
        if ns.MainUI then
            ns.MainUI:OpenTab("bis")
        end
    elseif cmd == "secrets" or cmd == "secretos" then
        if ns.MainUI then
            ns.MainUI:OpenTab("secrets")
        end
    elseif cmd == "farming" or cmd == "farmeo" then
        if ns.MainUI then
            ns.MainUI:OpenTab("farming")
        end
    elseif cmd == "prep" then
        if ns.MainUI then
            ns.MainUI:OpenTab("prep")
        end
    elseif cmd == "guild" or cmd == "hermandad" then
        if ns.MainUI then
            ns.MainUI:OpenTab("guild")
        end
    elseif cmd == "arrow" then
        if ns.GuideHUD then
            ns.GuideHUD:PositionTomTomArrow()
            ns.Print("Compás de TomTom centrado horizontalmente en la parte superior.")
        end
    elseif cmd == "minimap" or cmd == "icon" then
        if ns.MinimapButton then
            ns.MinimapButton:Toggle()
        end
    elseif cmd == "reset" then
        if ns.MainUI and ns.MainUI.frame then
            ns.MainUI.frame:ClearAllPoints()
            ns.MainUI.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        end
        if ns.MinimapButton and ns.MinimapButton.UpdatePosition then
            if ns.db then ns.db.minimapAngle = 205 end
            ns.MinimapButton.UpdatePosition(205)
        end
        ns.Print("Posición de la ventana y botón del minimapa restablecidos.")
    else
        if ns.MainUI then
            ns.MainUI:Toggle()
        end
    end
end