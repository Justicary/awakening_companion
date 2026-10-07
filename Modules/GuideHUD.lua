local ADDON, ns = ...

local GuideHUD = {}
ns.GuideHUD = GuideHUD

local currentGuide = nil
local currentStepIndex = 1
local activeTomTomUID = nil
local lastArrivedSoundTime = 0
local lastAutoAdvanceTime = 0

-- =========================================================================
-- INTEGRACIÓN Y CONTROL DEL COMPÁS 3D DE TOMTOM
-- =========================================================================
function GuideHUD:HasTomTom()
    return _G.TomTom and type(_G.TomTom.AddWaypoint) == "function"
end

-- Centra la Crazy Arrow de TomTom horizontalmente en la parte superior de la pantalla
function GuideHUD:PositionTomTomArrow()
    if not self:HasTomTom() then return end

    if _G.TomTomCrazyArrow then
        _G.TomTomCrazyArrow:ClearAllPoints()
        _G.TomTomCrazyArrow:SetPoint("TOP", UIParent, "TOP", 0, -50)
        _G.TomTomCrazyArrow:Show()
    end

    -- Sincronizar también en la configuración persistente de TomTom si existe
    if _G.TomTom and _G.TomTom.profile and _G.TomTom.profile.arrow then
        _G.TomTom.profile.arrow.position = { "TOP", nil, "TOP", 0, -50 }
        _G.TomTom.profile.arrow.enable = true
    end

    if _G.TomTom and _G.TomTom.ShowHideCrazyArrow then
        pcall(_G.TomTom.ShowHideCrazyArrow, _G.TomTom)
    end
end

function GuideHUD:ClearTomTomWaypoint()
    if activeTomTomUID and self:HasTomTom() then
        pcall(_G.TomTom.RemoveWaypoint, _G.TomTom, activeTomTomUID)
        activeTomTomUID = nil
    end
end

function GuideHUD:SyncTomTomWaypoint(step)
    self:ClearTomTomWaypoint()

    if not self:HasTomTom() or not step then
        return false
    end

    local mapID = step.uiMapID or (currentGuide and currentGuide.uiMapID)
    if not mapID or not step.x or not step.y then
        return false
    end

    local title = string.format("[Awakening] %s", step.title or "Objetivo")
    local desc = step.instruction or ""

    local ok, uid = pcall(_G.TomTom.AddWaypoint, _G.TomTom, mapID, step.x / 100, step.y / 100, {
        title = title,
        desc = desc,
        from = "Awakening",
        persistent = false,
        minimap = true,
        world = true,
        crazy = true, -- Asigna el compás 3D de TomTom a este hito
        cleardistance = 15,
        callbacks = {
            arrival = function()
                GuideHUD:OnStepArrived(true)
            end
        }
    })

    if ok and uid then
        activeTomTomUID = uid
        self:PositionTomTomArrow()
        if _G.TomTom.SetCrazyArrow then
            pcall(_G.TomTom.SetCrazyArrow, _G.TomTom, uid, 15, title)
        end
        if _G.TomTomCrazyArrow then
            _G.TomTomCrazyArrow:Show()
        end
        return true
    end

    return false
end

-- =========================================================================
-- CREACIÓN DEL MARCO FLOTANTE (TARJETA DE RASTREO CONTEXTUAL PREMIUM)
-- =========================================================================
local hud = CreateFrame("Frame", "AwakeningNavHUD", UIParent, "BackdropTemplate")
hud:SetSize(450, 76) -- Altura base proporcional (se autoajusta dinámicamente al contenido)
hud:SetPoint("TOP", UIParent, "TOP", 0, -165) -- Posición predeterminada debajo del compás 3D de TomTom
hud:SetMovable(true)
hud:EnableMouse(true)
hud:RegisterForDrag("LeftButton")
hud:SetClampedToScreen(true)
hud:SetScript("OnDragStart", hud.StartMoving)
hud:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    if GuideHUD.SavePosition then
        GuideHUD:SavePosition()
    end
end)
hud:Hide()

hud:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
hud:SetBackdropColor(0.03, 0.03, 0.05, 0.95)
hud:SetBackdropBorderColor(0.78, 0.62, 0.22, 0.90) -- Acabado dorado clásico elegante

-- Persistencia de posición del HUD (Inspirado en Mapzeroth)
function GuideHUD:SavePosition()
    local point, _, relativePoint, x, y = hud:GetPoint(1)
    if AwakeningDB then
        AwakeningDB.hudPosition = {
            point = point or "TOP",
            relativePoint = relativePoint or "TOP",
            x = math.floor(x or 0),
            y = math.floor(y or -165),
        }
    end
end

function GuideHUD:RestorePosition()
    local pos = AwakeningDB and AwakeningDB.hudPosition
    hud:ClearAllPoints()
    if pos and pos.point then
        hud:SetPoint(pos.point, UIParent, pos.relativePoint or pos.point, pos.x or 0, pos.y or -165)
    else
        hud:SetPoint("TOP", UIParent, "TOP", 0, -165)
    end
end

-- Menú contextual con clic derecho en el HUD (Inspirado en Mapzeroth GPSNavigator)
local hudMenuFrame = CreateFrame("Frame", "AwakeningHUDContextMenu", UIParent, "UIDropDownMenuTemplate")
local function OpenHUDContextMenu()
    local hasGuide = currentGuide ~= nil
    local totalSteps = (hasGuide and currentGuide.steps) and #currentGuide.steps or 1
    local menuList = {
        { text = "Awakening HUD", isTitle = true, notCheckable = true },
        {
            text = "Paso siguiente",
            notCheckable = true,
            disabled = not (hasGuide and currentStepIndex < totalSteps),
            func = function() GuideHUD:NextStep() end
        },
        {
            text = "Paso anterior",
            notCheckable = true,
            disabled = not (hasGuide and currentStepIndex > 1),
            func = function() GuideHUD:PrevStep() end
        },
        {
            text = "Sincronizar TomTom",
            notCheckable = true,
            func = function()
                GuideHUD:PositionTomTomArrow()
                if currentGuide and currentGuide.steps and currentGuide.steps[currentStepIndex] then
                    GuideHUD:SyncTomTomWaypoint(currentGuide.steps[currentStepIndex])
                end
            end
        },
        {
            text = "Restablecer posición del HUD",
            notCheckable = true,
            func = function()
                hud:ClearAllPoints()
                hud:SetPoint("TOP", UIParent, "TOP", 0, -165)
                GuideHUD:SavePosition()
            end
        },
        {
            text = "Cerrar HUD",
            notCheckable = true,
            func = function() GuideHUD:Hide() end
        },
    }
    if EasyMenu then
        EasyMenu(menuList, hudMenuFrame, "cursor", 0, 0, "MENU")
    end
end

hud:SetScript("OnMouseUp", function(self, button)
    if button == "RightButton" and not (IsMouselooking and IsMouselooking()) then
        OpenHUDContextMenu()
    end
end)

-- Línea superior sutil dorada de acento premium
local topAccent = hud:CreateTexture(nil, "ARTWORK")
topAccent:SetHeight(2)
topAccent:SetPoint("TOPLEFT", hud, "TOPLEFT", 4, -3)
topAccent:SetPoint("TOPRIGHT", hud, "TOPRIGHT", -4, -3)
topAccent:SetColorTexture(0.85, 0.70, 0.25, 0.75)

-- Contenedor del Icono de Hito con marco dorado interactivo
local iconBox = CreateFrame("Frame", nil, hud, "BackdropTemplate")
iconBox:SetSize(40, 40)
iconBox:SetPoint("TOPLEFT", hud, "TOPLEFT", 10, -10)
iconBox:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 8,
    insets = { left = 1, right = 1, top = 1, bottom = 1 }
})
iconBox:SetBackdropColor(0.04, 0.04, 0.07, 0.95)
iconBox:SetBackdropBorderColor(0.85, 0.70, 0.25, 0.90)
iconBox:EnableMouse(true)

local stepIcon = iconBox:CreateTexture(nil, "ARTWORK")
stepIcon:SetPoint("TOPLEFT", iconBox, "TOPLEFT", 2, -2)
stepIcon:SetPoint("BOTTOMRIGHT", iconBox, "BOTTOMRIGHT", -2, 2)
stepIcon:SetTexture("Interface\\Icons\\inv_misc_questionmark")
stepIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

-- Tooltip enriquecido al pasar el cursor sobre el icono principal del hito
iconBox:SetScript("OnEnter", function(self)
    self:SetBackdropBorderColor(1, 0.88, 0.35, 1)
    if not currentGuide then return end
    local step = currentGuide.steps and currentGuide.steps[currentStepIndex]
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(currentGuide.title or "Guía Activa", 1, 0.82, 0)
    if currentGuide.category then
        local cat = currentGuide.category
        if currentGuide.level then cat = cat .. " · " .. currentGuide.level end
        GameTooltip:AddLine(cat, 0.5, 0.8, 1)
    end
    if step and step.title then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(string.format("Hito %d: %s", currentStepIndex, step.title), 1, 1, 1)
        if step.instruction then
            GameTooltip:AddLine(string.format("|cFFDDDDDD%s|r", step.instruction), 0.8, 0.8, 0.8, true)
        end
    end

    local rItems = currentGuide.rewardItems
    if rItems and #rItems > 0 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cFFFFD100Recompensas al completar:|r", 1, 0.82, 0)
        for _, item in ipairs(rItems) do
            local itemName, itemLink, itemQuality, _, _, _, _, _, _, itemTexture = GetItemInfo(item.itemID)
            local iconTex = item.icon or itemTexture or "Interface\\Icons\\inv_misc_questionmark"
            local displayName = itemLink or item.name or ("Objeto #" .. item.itemID)
            local countStr = (item.count and item.count > 1) and string.format(" |cFFFFFFFF(x%d)|r", item.count) or ""
            local r, g, b = 0.2, 1, 0.4
            if itemQuality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[itemQuality] then
                r, g, b = ITEM_QUALITY_COLORS[itemQuality].r, ITEM_QUALITY_COLORS[itemQuality].g, ITEM_QUALITY_COLORS[itemQuality].b
            elseif item.quality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[item.quality] then
                r, g, b = ITEM_QUALITY_COLORS[item.quality].r, ITEM_QUALITY_COLORS[item.quality].g, ITEM_QUALITY_COLORS[item.quality].b
            end
            GameTooltip:AddLine(string.format("|T%s:16:16:0:0:64:64:4:60:4:60|t %s%s", iconTex, displayName, countStr), r, g, b)
            if item.desc then
                GameTooltip:AddLine(string.format("   |cFF88DDFF%s|r", item.desc), 0.75, 0.85, 1, true)
            end
        end
    elseif currentGuide.reward then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(string.format("|cFF00FF00Recompensa:|r %s", currentGuide.reward), 0.2, 1, 0.4, true)
    end
    GameTooltip:Show()
end)
iconBox:SetScript("OnLeave", function(self)
    self:SetBackdropBorderColor(0.85, 0.70, 0.25, 0.90)
    GameTooltip:Hide()
end)

-- Botón Cerrar (X) discreto en la esquina superior derecha
local btnClose = CreateFrame("Button", nil, hud, "UIPanelCloseButton")
btnClose:SetSize(18, 18)
btnClose:SetPoint("TOPRIGHT", hud, "TOPRIGHT", -4, -4)
btnClose:SetScript("OnClick", function()
    GuideHUD:Hide()
end)

-- Título del paso (Línea 1 - Tipografía dorada limpia y legible)
local titleLabel = hud:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")
titleLabel:SetPoint("TOPLEFT", iconBox, "TOPRIGHT", 10, -1)
titleLabel:SetPoint("RIGHT", btnClose, "LEFT", -6, 0)
titleLabel:SetJustifyH("LEFT")
titleLabel:SetWordWrap(false)
titleLabel:SetText("Awakening: Guía Activa")

-- Instrucción del paso (Línea 2 - Flujo limpio sin solapamientos)
local descLabel = hud:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
descLabel:SetPoint("TOPLEFT", titleLabel, "BOTTOMLEFT", 0, -3)
descLabel:SetPoint("RIGHT", hud, "RIGHT", -90, 0)
descLabel:SetJustifyH("LEFT")
descLabel:SetWordWrap(true)
descLabel:SetSpacing(2)
descLabel:SetTextColor(0.92, 0.92, 0.94)
descLabel:SetText("Selecciona una ruta en el menú.")

-- Meta información (Línea 3 - Zona y Coordenadas con formato estilizado)
local metaLabel = hud:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
metaLabel:SetPoint("TOPLEFT", descLabel, "BOTTOMLEFT", 0, -3)
metaLabel:SetPoint("RIGHT", hud, "RIGHT", -90, 0)
metaLabel:SetJustifyH("LEFT")
metaLabel:SetText("")

-- Controles de navegación en la esquina inferior derecha: [ < ]  1/4  [ > ]
local btnNext = CreateFrame("Button", nil, hud, "UIPanelButtonTemplate")
btnNext:SetSize(22, 20)
btnNext:SetPoint("BOTTOMRIGHT", hud, "BOTTOMRIGHT", -8, 8)
btnNext:SetText(">")
btnNext:SetScript("OnClick", function()
    GuideHUD:NextStep()
end)

local stepCounter = hud:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
stepCounter:SetPoint("RIGHT", btnNext, "LEFT", -4, 0)
stepCounter:SetText("1/1")

local btnPrev = CreateFrame("Button", nil, hud, "UIPanelButtonTemplate")
btnPrev:SetSize(22, 20)
btnPrev:SetPoint("RIGHT", stepCounter, "LEFT", -4, 0)
btnPrev:SetText("<")
btnPrev:SetScript("OnClick", function()
    GuideHUD:PrevStep()
end)

-- Elementos de respaldo (Fallback si TomTom NO está instalado)
local fallbackArrow = hud:CreateTexture(nil, "OVERLAY")
fallbackArrow:SetSize(22, 22)
fallbackArrow:SetPoint("BOTTOMRIGHT", btnPrev, "BOTTOMLEFT", -8, -1)
fallbackArrow:SetTexture("Interface\\WorldMap\\WorldMapArrow")
fallbackArrow:Hide()

local fallbackDist = hud:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
fallbackDist:SetPoint("RIGHT", fallbackArrow, "LEFT", -4, 0)
fallbackDist:SetText("--")
fallbackDist:Hide()

-- =========================================================================
-- AJUSTE DINÁMICO Y PROPORCIONAL DE ALTURA
-- =========================================================================
local function UpdateHUDLayout()
    local titleH = titleLabel:GetStringHeight() or 16
    local descH = descLabel:GetStringHeight() or 14
    local metaH = metaLabel:GetStringHeight() or 12
    
    -- Margen superior (10) + Título + Espacio (3) + Descripción + Espacio (3) + Coordenadas + Margen inferior (10)
    local calculatedH = 10 + titleH + 3 + descH + 3 + metaH + 10
    
    -- La caja de icono (40px) y botones requieren mínimo 68px de altura
    local targetH = math.max(68, math.ceil(calculatedH))
    hud:SetHeight(targetH)
end

-- =========================================================================
-- ACTUALIZACIÓN VISUAL Y SINCRONIZACIÓN
-- =========================================================================
local function RenderActiveStep()
    if not currentGuide or not currentGuide.steps or not currentGuide.steps[currentStepIndex] then
        titleLabel:SetText("|cFFFFD100Sin ruta activa|r")
        descLabel:SetText("Abre el catálogo de guías para iniciar una ruta de secretos o farmeo.")
        metaLabel:SetText("")
        stepIcon:SetTexture("Interface\\Icons\\inv_misc_questionmark")
        stepCounter:SetText("-/-")
        fallbackArrow:Hide()
        fallbackDist:Hide()
        btnPrev:SetEnabled(false)
        btnNext:SetEnabled(false)
        GuideHUD:ClearTomTomWaypoint()
        UpdateHUDLayout()
        return
    end

    local step = currentGuide.steps[currentStepIndex]
    local totalSteps = #currentGuide.steps
    if step and currentGuide then
        step.uiMapID = step.uiMapID or currentGuide.uiMapID
        step.zoneName = step.zoneName or currentGuide.zoneName
    end

    -- Título limpio sin números repetidos (ej. no mostrar "Paso 1: 1. Campamento")
    local rawTitle = step.title or ""
    local cleanTitle = rawTitle:gsub("^%d+%.%s*", "")
    titleLabel:SetText(string.format("|cFFFFD100Paso %d:|r %s", currentStepIndex, cleanTitle))
    
    descLabel:SetText(step.instruction or "")
    
    local zoneText = step.zoneName or (currentGuide.zoneName or "")
    local coordText = (step.x and step.y) and string.format("|cFF00FFCC(%.1f, %.1f)|r", step.x, step.y) or ""
    if zoneText ~= "" and coordText ~= "" then
        metaLabel:SetText(string.format("|cFFFFCC00%s|r  ·  %s", zoneText, coordText))
    elseif zoneText ~= "" then
        metaLabel:SetText(string.format("|cFFFFCC00%s|r", zoneText))
    else
        metaLabel:SetText(coordText)
    end

    stepCounter:SetText(string.format("|cFFFFD100%d|r|cFF888888/|r|cFFFFD100%d|r", currentStepIndex, totalSteps))
    
    -- Icono con fallback seguro
    local iconTex = step.icon or currentGuide.icon or "Interface\\Icons\\inv_misc_questionmark"
    stepIcon:SetTexture(iconTex)

    -- Habilitar/Deshabilitar botones de navegación según posición
    btnPrev:SetEnabled(currentStepIndex > 1)
    btnNext:SetEnabled(currentStepIndex < totalSteps)

    -- Autoajustar la altura proporcional al contenido del paso
    UpdateHUDLayout()
    if C_Timer and C_Timer.After then
        C_Timer.After(0.01, UpdateHUDLayout)
    end

    -- Sincronizar con TomTom (Compás 3D + Pines de mapa)
    local usingTomTom = GuideHUD:SyncTomTomWaypoint(step)
    if usingTomTom then
        fallbackArrow:Hide()
        fallbackDist:Hide()
    else
        fallbackArrow:Show()
        fallbackDist:Show()
    end
end

-- =========================================================================
-- MANEJO DE LLEGADA AL HITO Y AUTO-AVANCE (Inspirado en Mapzeroth)
-- =========================================================================
function GuideHUD:OnStepArrived(fromTomTom)
    local now = GetTime()
    if (now - lastArrivedSoundTime) > 6 then
        PlaySound(SOUNDKIT and SOUNDKIT.MAP_PING or 3175, "Master")
        lastArrivedSoundTime = now
    end

    if currentGuide and currentGuide.steps and currentGuide.steps[currentStepIndex] then
        local step = currentGuide.steps[currentStepIndex]
        ns.Print(string.format("|cFF00FF00¡Llegaste al hito!|r %s", ns.Gold(step.title)))

        -- Auto-avance inteligente al siguiente paso (Inspirado en GPSNavigator de Mapzeroth)
        local autoAdvance = (AwakeningDB and AwakeningDB.autoAdvanceSteps ~= false)
        if autoAdvance and (now - lastAutoAdvanceTime) > 3.0 and currentStepIndex < #currentGuide.steps then
            lastAutoAdvanceTime = now
            if C_Timer and C_Timer.After then
                C_Timer.After(0.9, function()
                    if currentGuide and currentStepIndex < #currentGuide.steps then
                        GuideHUD:NextStep()
                    end
                end)
            else
                GuideHUD:NextStep()
            end
        end
    end
end

-- Detección de transición de mapa en transporte (barcos, zepelines, tranvía, portales)
hud:RegisterEvent("ZONE_CHANGED_NEW_AREA")
hud:RegisterEvent("ZONE_CHANGED")
hud:HookScript("OnEvent", function(self, event)
    if event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED" then
        if not currentGuide or not currentGuide.steps or not currentGuide.steps[currentStepIndex] then return end
        local step = currentGuide.steps[currentStepIndex]
        local playerMapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
        local targetMapID = step.uiMapID

        -- Si el jugador ha llegado al mapa destino del paso tras una transición de transporte
        if targetMapID and playerMapID and playerMapID == targetMapID and (step.fromMapID and step.fromMapID ~= targetMapID) then
            local now = GetTime()
            if (now - lastAutoAdvanceTime) > 3.0 and currentStepIndex < #currentGuide.steps then
                lastAutoAdvanceTime = now
                ns.Print(string.format("|cFF00FF00Transición completada:|r Llegaste a %s.", ns.Gold(step.title or "destino")))
                if C_Timer and C_Timer.After then
                    C_Timer.After(1.0, function()
                        GuideHUD:NextStep()
                    end)
                else
                    GuideHUD:NextStep()
                end
            end
        end
    end
end)

-- =========================================================================
-- BUCLE ONUPDATE DE RESPALDO (SOLO ACTIVO SI NO EXISTE TOMTOM)
-- =========================================================================
local elapsedAccumulator = 0
hud:SetScript("OnUpdate", function(self, elapsed)
    elapsedAccumulator = elapsedAccumulator + elapsed
    if elapsedAccumulator < 0.05 then return end
    elapsedAccumulator = 0

    if not currentGuide or not currentGuide.steps or not currentGuide.steps[currentStepIndex] then
        return
    end

    local step = currentGuide.steps[currentStepIndex]
    local targetMapID = step.uiMapID or (currentGuide and currentGuide.uiMapID)
    local playerMapID = C_Map.GetBestMapForUnit("player")

    if not playerMapID or not targetMapID or playerMapID ~= targetMapID then
        local targetZone = step.zoneName or (currentGuide and currentGuide.zoneName) or "Otra zona"
        fallbackDist:SetText(targetZone)
        fallbackDist:SetTextColor(1, 0.4, 0.4)
        fallbackArrow:SetVertexColor(0.5, 0.5, 0.5, 0.4)
        fallbackArrow:SetRotation(0)
        return
    end

    local pos = C_Map.GetPlayerMapPosition(playerMapID, "player")
    if not pos then return end

    local px, py = pos:GetXY()
    if not px or not py then return end

    local targetX = step.x or 0
    local targetY = step.y or 0

    -- Cálculo de distancia física en yardas y rumbo usando utilidades de Mapzeroth
    local distYards, heading
    if ns.GetDistanceAndHeading then
        distYards, heading = ns.GetDistanceAndHeading(playerMapID, px * 100, py * 100, targetMapID, targetX, targetY)
    end

    local deltaX = (targetX / 100) - px
    local deltaY = (targetY / 100) - py

    if not distYards then
        distYards = math.sqrt(deltaX * deltaX + deltaY * deltaY) * (ns.MAP_SCALE or 1000)
    end

    -- Actualizar distancia física en tiempo real en la línea meta del HUD
    local zoneText = step.zoneName or (currentGuide and currentGuide.zoneName) or ""
    local coordText = (step.x and step.y) and string.format("|cFF00FFCC(%.1f, %.1f)|r", step.x, step.y) or ""
    local distStr = ns.FormatDistance and ns.FormatDistance(distYards) or string.format("%d yd", math.floor(distYards))
    local distBadge = (distYards <= 20) and "|cFF00FF00¡En destino!|r" or ("|cFFFFD100" .. distStr .. "|r")

    if zoneText ~= "" and coordText ~= "" then
        metaLabel:SetText(string.format("|cFFFFCC00%s|r  ·  %s  ·  %s", zoneText, coordText, distBadge))
    elseif zoneText ~= "" then
        metaLabel:SetText(string.format("|cFFFFCC00%s|r  ·  %s", zoneText, distBadge))
    end

    -- Si TomTom está activo y sincronizado, su Crazy Arrow 3D maneja la orientación
    if GuideHUD:HasTomTom() and activeTomTomUID then
        fallbackArrow:Hide()
        fallbackDist:Hide()
        return
    end

    local now = GetTime()
    if distYards <= 20 then
        fallbackDist:SetText("|cFF00FF00¡Llegaste!|r")
        if (now - lastArrivedSoundTime) > 6 then
            GuideHUD:OnStepArrived(false)
        end
    else
        fallbackDist:SetText(distStr)
        fallbackDist:SetTextColor(1, 0.82, 0)
    end

    fallbackArrow:SetVertexColor(1, 1, 1, 1)
    local facing = (GetPlayerFacing and GetPlayerFacing()) or 0
    local angle = math.atan2(-deltaX, -deltaY)
    local relativeAngle = angle - facing
    fallbackArrow:SetRotation(relativeAngle)
end)

-- =========================================================================
-- MÉTODOS PÚBLICOS DEL HUD
-- =========================================================================
function GuideHUD:StartRoute(guideData, guideKey, startStep)
    if not guideData or not guideData.steps or #guideData.steps == 0 then return end
    currentGuide = guideData

    -- Asegurar que cada paso herede uiMapID y zoneName si no los tiene definidos individualmente
    local defaultMapID = guideData.uiMapID
    local defaultZone = guideData.zoneName
    for _, s in ipairs(guideData.steps) do
        if not s.uiMapID and defaultMapID then
            s.uiMapID = defaultMapID
        end
        if not s.zoneName and defaultZone then
            s.zoneName = defaultZone
        end
    end

    if not startStep and not guideData.isDynamicTravel and guideKey and ns.GetSecretProgress then
        startStep = ns.GetSecretProgress(guideKey)
    end
    currentStepIndex = startStep or 1
    if currentStepIndex < 1 or currentStepIndex > #guideData.steps then
        currentStepIndex = 1
    end
    
    if ns.db then
        ns.db.activeRoute = guideKey
        ns.db.activeStep = currentStepIndex
    end

    RenderActiveStep()
    hud:Show()
    
    local tomtomNote = self:HasTomTom() and " |cFF00FF00(Compás 3D TomTom centrado)|r" or ""
    ns.Print(string.format("Ruta activa: %s (Hito %d/%d)%s", ns.Gold(guideData.title), currentStepIndex, #guideData.steps, tomtomNote))
end

function GuideHUD:NextStep()
    if currentGuide and currentGuide.steps and currentStepIndex < #currentGuide.steps then
        currentStepIndex = currentStepIndex + 1
        if ns.db then ns.db.activeStep = currentStepIndex end
        RenderActiveStep()
        PlaySound(SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or 856, "Master")
    end
end

function GuideHUD:PrevStep()
    if currentStepIndex > 1 then
        currentStepIndex = currentStepIndex - 1
        if ns.db then ns.db.activeStep = currentStepIndex end
        RenderActiveStep()
        PlaySound(SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF or 857, "Master")
    end
end

function GuideHUD:Toggle()
    if hud:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

function GuideHUD:Show()
    RenderActiveStep()
    hud:Show()
end

function GuideHUD:Hide()
    self:ClearTomTomWaypoint()
    hud:Hide()
end

function GuideHUD:IsShown()
    return hud:IsShown()
end

function GuideHUD:GuideToTrainer(trainer)
    if not trainer then return end
    local guideData = {
        title = "Entrenador: " .. (trainer.name or "Clase"),
        category = "Entrenador de Clase",
        zoneName = trainer.zone or "Zona",
        uiMapID = trainer.uiMapID,
        steps = {
            {
                title = trainer.name or "Entrenador",
                instruction = string.format("Visita a %s en %s (%.1f, %.1f) para aprender nuevas habilidades de clase.", trainer.name or "tu entrenador", trainer.zone or "", trainer.x or 0, trainer.y or 0),
                zoneName = trainer.zone,
                uiMapID = trainer.uiMapID,
                x = trainer.x,
                y = trainer.y,
            }
        }
    }
    self:StartRoute(guideData, "trainer_" .. (trainer.name or "class"), 1)
end

GuideHUD.frame = hud

-- Vigilancia reactiva para avanzar automáticamente de hito al aceptar/entregar misiones
local secretWatcher = CreateFrame("Frame")
secretWatcher:RegisterEvent("QUEST_LOG_UPDATE")
secretWatcher:RegisterEvent("QUEST_ACCEPTED")
secretWatcher:RegisterEvent("QUEST_TURNED_IN")
secretWatcher:RegisterEvent("BAG_UPDATE_DELAYED")
secretWatcher:SetScript("OnEvent", function(self, event)
    if currentGuide and currentGuide.id and ns.GetSecretProgress then
        local targetStep, isDone = ns.GetSecretProgress(currentGuide.id)
        if targetStep and targetStep ~= currentStepIndex then
            currentStepIndex = targetStep
            if ns.db then ns.db.activeStep = targetStep end
            RenderActiveStep()
            local note = isDone and " |cFF00FF00(¡Completado! Recompensa obtenida)|r" or string.format(" (Avanzado a Hito %d/%d)", targetStep, #currentGuide.steps)
            ns.Print(string.format("Ruta actualizada: %s%s", ns.Gold(currentGuide.title), note))
            if ns.MainUI and ns.MainUI.UpdateSecretsView then
                ns.MainUI:UpdateSecretsView()
            end
        end
    end
end)

-- Restaurar posición guardada y centrar el compás de TomTom al cargar el jugador
local initTimer = CreateFrame("Frame")
initTimer:RegisterEvent("PLAYER_LOGIN")
initTimer:SetScript("OnEvent", function()
    if GuideHUD.RestorePosition then
        GuideHUD:RestorePosition()
    end
    GuideHUD:PositionTomTomArrow()
end)