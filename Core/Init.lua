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
-- UI STYLING & TEXTURAS (Inspirado en Chairfaces Casino)
-- =========================================================================
local TAVERN_TEX = "Interface\\AddOns\\AwakeningCompanion\\Media\\Textures\\lobby_bg"
local TAVERN_ASPECT = 720 / 490

local function tavernCover(tex, frame)
    local w, h = frame:GetWidth(), frame:GetHeight()
    if not w or not h or w <= 0 or h <= 0 then return end
    local frameAspect = w / h
    if frameAspect > TAVERN_ASPECT then
        local vis = TAVERN_ASPECT / frameAspect
        local crop = (1 - vis) / 2
        tex:SetTexCoord(0, 1, crop, 1 - crop)
    else
        local vis = frameAspect / TAVERN_ASPECT
        local crop = (1 - vis) / 2
        tex:SetTexCoord(crop, 1 - crop, 0, 1)
    end
end

function ns.ApplyTavernBackground(frame, opts)
    if not frame or frame.__tavernBg then return frame and frame.__tavernBg end
    opts = opts or {}
    local texPath = opts.texture or TAVERN_TEX
    
    if frame.SetBackdropColor then
        frame:SetBackdropColor(0.06, 0.05, 0.07, 0.97)
    end
    local art = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
    art:SetPoint("TOPLEFT", 3, -3)
    art:SetPoint("BOTTOMRIGHT", -3, 3)
    art:SetTexture(texPath)
    
    local scrim = frame:CreateTexture(nil, "BACKGROUND", nil, 2)
    scrim:SetAllPoints(art)
    scrim:SetColorTexture(0.03, 0.02, 0.05, opts.scrim or 0.65)
    
    frame.__tavernBg = art
    frame.__tavernScrim = scrim
    
    local function refresh() tavernCover(art, frame) end
    refresh()
    frame:HookScript("OnSizeChanged", refresh)
    frame:HookScript("OnShow", refresh)
    return art
end

function ns.CreateGameButton(parent, name, text, width, height)
    local btn = CreateFrame("Button", name, parent, "BackdropTemplate")
    btn:SetSize(width or 120, height or 28)
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    btn:SetBackdropColor(0.12, 0.25, 0.15, 0.9)
    btn:SetBackdropBorderColor(0.3, 0.7, 0.3, 0.9)

    local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    btnText:SetPoint("CENTER")
    btnText:SetText(text or "")
    btn.text = btnText

    btn:SetScript("OnEnter", function(self)
        if self:IsEnabled() then
            self:SetBackdropColor(0.2, 0.5, 0.2, 1)
            self:SetBackdropBorderColor(0.4, 1.0, 0.4, 1)
            if self.text then self.text:SetTextColor(1, 1, 1, 1) end
        end
    end)

    btn:SetScript("OnLeave", function(self)
        if self:IsEnabled() then
            if self.highlighted then
                self:SetBackdropColor(0.35, 0.28, 0.1, 1)
                self:SetBackdropBorderColor(0.8, 0.65, 0.2, 1)
            else
                self:SetBackdropColor(0.12, 0.25, 0.15, 0.9)
                self:SetBackdropBorderColor(0.3, 0.7, 0.3, 0.9)
            end
            if self.text then self.text:SetTextColor(0.9, 0.9, 0.9, 1) end
        end
    end)

    btn:SetScript("OnDisable", function(self)
        self:SetBackdropColor(0.1, 0.1, 0.1, 0.6)
        self:SetBackdropBorderColor(0.25, 0.25, 0.25, 0.6)
        if self.text then self.text:SetTextColor(0.5, 0.5, 0.5, 1) end
    end)

    btn:SetScript("OnEnable", function(self)
        self:SetBackdropColor(0.12, 0.25, 0.15, 0.9)
        self:SetBackdropBorderColor(0.3, 0.7, 0.3, 0.9)
        if self.text then self.text:SetTextColor(1, 1, 1, 1) end
    end)

    return btn
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
-- UTILIDADES DE NAVEGACIÓN Y COORDENADAS FÍSICAS (Adaptado de Mapzeroth)
-- =========================================================================
ns.MAP_SCALE = 1000 -- Factor de escala para distancia aproximada en mapa 2D

-- Atan2 compatible con Lua 5.1
function ns.Atan2(y, x)
    if math.atan2 then
        return math.atan2(y, x)
    end
    if x > 0 then
        return math.atan(y / x)
    elseif x < 0 and y >= 0 then
        return math.atan(y / x) + math.pi
    elseif x < 0 and y < 0 then
        return math.atan(y / x) - math.pi
    elseif x == 0 and y > 0 then
        return math.pi / 2
    elseif x == 0 and y < 0 then
        return -math.pi / 2
    end
    return 0
end

-- Obtiene la posición física en el mundo 3D en yardas (world position) a partir de coordenadas de mapa
function ns.GetWorldPosition(mapID, x, y)
    if not mapID or not x or not y then return nil end
    if not (C_Map and C_Map.GetWorldPosFromMapPos and CreateVector2D) then return nil end

    -- Si las coordenadas están en formato porcentaje 0..100, normalizar a 0..1
    local normX = (x > 1) and (x / 100) or x
    local normY = (y > 1) and (y / 100) or y

    local mapPos = CreateVector2D(normX, normY)
    if not mapPos then return nil end

    local ok, _, worldPos = pcall(C_Map.GetWorldPosFromMapPos, mapID, mapPos)
    if ok and worldPos then
        return worldPos
    end
    return nil
end

-- Calcula la distancia en yardas reales y el rumbo (heading) entre dos puntos
function ns.GetDistanceAndHeading(fromMap, fromX, fromY, toMap, toX, toY)
    if not fromMap or not fromX or not fromY or not toMap or not toX or not toY then
        return nil, nil
    end

    local fromWorld = ns.GetWorldPosition(fromMap, fromX, fromY)
    local toWorld = ns.GetWorldPosition(toMap, toX, toY)

    local dx, dy

    if fromWorld and toWorld then
        dx = toWorld.x - fromWorld.x
        dy = toWorld.y - fromWorld.y
    elseif fromMap == toMap then
        local fX = (fromX > 1) and (fromX / 100) or fromX
        local fY = (fromY > 1) and (fromY / 100) or fY
        local tX = (toX > 1) and (toX / 100) or toX
        local tY = (toY > 1) and (toY / 100) or toY
        dx = (tX - fX) * ns.MAP_SCALE
        dy = (tY - fY) * ns.MAP_SCALE
    else
        return nil, nil
    end

    local distance = math.sqrt(dx * dx + dy * dy)
    local heading = ns.Atan2(dy, dx)
    return distance, heading
end

-- Formatea una distancia en yardas o kilómetros con formato limpio
function ns.FormatDistance(distanceYards)
    if not distanceYards then return "--" end
    if distanceYards >= 1000 then
        return string.format("%.1f km", distanceYards / 1000)
    end
    return string.format("%.0f yd", distanceYards)
end

-- Captura la posición actual del jugador
function ns.GetPlayerLocation()
    if not (C_Map and C_Map.GetBestMapForUnit and C_Map.GetPlayerMapPosition) then
        return nil, "API de mapa no disponible"
    end
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then return nil, "Mapa actual no disponible" end

    local pos = C_Map.GetPlayerMapPosition(mapID, "player")
    if not pos then return nil, "Posición en mapa no disponible" end

    local x, y = pos:GetXY()
    return {
        mapID = mapID,
        x = x * 100,
        y = y * 100,
        xNorm = x,
        yNorm = y,
    }
end

-- Actualiza la ubicación de la Piedra de Hogar en la base de datos (Inspirado en Mapzeroth)
function ns.UpdateHearthstoneLocation()
    local bindLoc = (GetBindLocation and GetBindLocation()) or (GetHearthstoneLocation and GetHearthstoneLocation())
    if not bindLoc or bindLoc == "" then return end

    local loc = ns.GetPlayerLocation()
    if not loc then return end

    _G.AwakeningDB = _G.AwakeningDB or {}
    _G.AwakeningDB.hearthstone = {
        mapID = loc.mapID,
        x = loc.x,
        y = loc.y,
        locationName = bindLoc,
        setAt = time and time() or 0,
    }
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
initFrame:RegisterEvent("HEARTHSTONE_BOUND")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

initFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON then
        -- Inicializar base de datos guardada
        _G.AwakeningDB = _G.AwakeningDB or {}
        local db = _G.AwakeningDB
        db.showHUDOnSelect = (db.showHUDOnSelect == nil) and true or db.showHUDOnSelect
        db.soundAlerts = (db.soundAlerts == nil) and true or db.soundAlerts
        db.filterFarmingByProfessions = (db.filterFarmingByProfessions == nil) and true or db.filterFarmingByProfessions
        db.showOldSecrets = (db.showOldSecrets == nil) and false or db.showOldSecrets
        db.autoAdvanceSteps = (db.autoAdvanceSteps == nil) and true or db.autoAdvanceSteps
        db.activeRoute = db.activeRoute or nil
        db.activeStep = db.activeStep or 1
        ns.db = db

        -- Exponer datos retrocompatibles
        _G.AwakeningData = _G.AwakeningData or {}
        _G.AwakeningData.Guides = ns.Data.Secrets
    elseif event == "PLAYER_LOGIN" then
        ns.Print(string.format("v%s cargado. Usa %s o %s para abrir el centro de control.", ns.VERSION, ns.Gold("/awakening"), ns.Gold("/awk")))
    elseif event == "HEARTHSTONE_BOUND" then
        ns.UpdateHearthstoneLocation()
        local bind = (GetBindLocation and GetBindLocation()) or "Taberna"
        ns.Print(string.format("Piedra de Hogar vinculada en |cFF00FFCC%s|r.", bind))
    elseif event == "PLAYER_ENTERING_WORLD" then
        if _G.AwakeningDB and not _G.AwakeningDB.hearthstone then
            ns.UpdateHearthstoneLocation()
        end
    end
end)

-- =========================================================================
-- COMANDOS SLASH
-- =========================================================================
SLASH_AWAKENING1 = "/awakening"
SLASH_AWAKENING2 = "/awk"
SLASH_AWAKENING3 = "/ac"

SlashCmdList["AWAKENING"] = function(msg)
    local cmd = (msg or ""):trim():lower()
    
    if cmd == "skills" or cmd == "habilidades" or cmd == "trainer" or cmd == "entrenador" then
        if ns.SkillsUI then
            ns.SkillsUI:Toggle()
        end
    elseif cmd == "hud" then
        if ns.GuideHUD then
            ns.GuideHUD:Toggle()
        end
    elseif cmd == "guide" or cmd == "guia" or cmd:match("^guia%s") or cmd:match("^guide%s") then
        local guideId = cmd:match("^guia%s+(.+)$") or cmd:match("^guide%s+(.+)$")
        if ns.GuideViewer then
            ns.GuideViewer:Toggle(guideId or "excavation_site")
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
    elseif cmd == "prep" or cmd == "preparacion" then
        if ns.MainUI then
            ns.MainUI:OpenTab("prep")
        end
    elseif cmd == "prephd" or cmd == "prep hd" or cmd == "raidprep" then
        if ns.RaidPrep and ns.RaidPrep.ToggleHD then
            ns.RaidPrep:ToggleHD()
        end
    elseif cmd == "guild" or cmd == "hermandad" then
        if ns.MainUI then
            ns.MainUI:OpenTab("guild")
        end
    elseif cmd:match("^travel%s") or cmd:match("^viaje%s") then
        local from, to = cmd:match("^%a+%s+(.-)%s*%-%s*(.+)$")
        if from and to and ns.TravelPlanner then
            ns.TravelPlanner:PlanAndStart(from, to)
        else
            ns.Print("Uso: /awk travel <origen> - <destino> (ej: /awk travel Goldshire - Auberdine)")
        end
    elseif cmd == "loc" or cmd == "map" or cmd == "coords" or cmd == "pos" then
        local uiMapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
        if not uiMapID then
            ns.Print(ns.Red("No se pudo obtener el uiMapID actual."))
            return
        end
        local mapInfo = C_Map.GetMapInfo and C_Map.GetMapInfo(uiMapID)
        local mapName = mapInfo and mapInfo.name or "Desconocido"
        local parentID = mapInfo and mapInfo.parentMapID or 0
        local pos = C_Map.GetPlayerMapPosition and C_Map.GetPlayerMapPosition(uiMapID, "player")
        local px, py = pos and pos:GetXY() or 0, 0
        local x = math.floor((px or 0) * 1000 + 0.5) / 10
        local y = math.floor((py or 0) * 1000 + 0.5) / 10
        local zone = GetZoneText and GetZoneText() or ""
        local subZone = GetSubZoneText and GetSubZoneText() or ""

        ns.Print(string.format("|cFFFFD100[Inspector de Mapa]|r uiMapID = |cFF00FFFF%d|r (%s, Padre: %d)", uiMapID, mapName, parentID))
        ns.Print(string.format("Zona: |cFFFFFFFF%s|r · Subzona: |cFFFFFFFF%s|r", zone, subZone ~= "" and subZone or "(ninguna)"))
        ns.Print(string.format("Coordenadas: |cFF00FF00x = %.1f, y = %.1f|r", x, y))
        ns.Print(string.format("Formato Lua: |cFF88AAFF{ uiMapID = %d, x = %.1f, y = %.1f }|r", uiMapID, x, y))
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