local ADDON, ns = ...

-- =========================================================================
-- VISOR DE GUÍAS ENRIQUECIDAS (WOWHEAD STYLE · CHAIRFACES CASINO UI)
-- =========================================================================
ns.GuideViewer = {}
local GV = ns.GuideViewer

local VIEWER_WIDTH = 820
local VIEWER_HEIGHT = 540

local COLORS = {
    gold = { 1, 0.84, 0 },
    bronze = { 0.8, 0.65, 0.2 },
    panelBg = { 0.08, 0.08, 0.1, 0.95 },
    panelBorder = { 0.5, 0.4, 0.2, 1 },
    headerBg = { 0.14, 0.11, 0.07, 1 },
    headerBorder = { 0.8, 0.65, 0.2, 1 },
    tabActiveBg = { 0.35, 0.28, 0.1, 1 },
    tabInactiveBg = { 0.12, 0.10, 0.08, 0.9 },
    tabBorder = { 0.5, 0.4, 0.2, 0.8 },
    cardBg = { 0.06, 0.06, 0.08, 0.85 },
    cardBorder = { 0.35, 0.3, 0.18, 0.8 },
}

local currentGuideKey = "excavation_site"
local activeTab = "overview"
local activeBossIdx = 1

local viewerFrame = nil

-- =========================================================================
-- CREACIÓN DEL MARCO PRINCIPAL
-- =========================================================================
function GV:Init()
    if viewerFrame then return end

    local f = CreateFrame("Frame", "AwakeningGuideViewerFrame", UIParent, "BackdropTemplate")
    f:SetSize(VIEWER_WIDTH, VIEWER_HEIGHT)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 30)
    f:SetFrameStrata("HIGH")
    f:SetToplevel(true)
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()

    -- Cerrar con tecla ESC
    tinsert(UISpecialFrames, "AwakeningGuideViewerFrame")

    -- Borde de marco exterior
    f:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 2,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    f:SetBackdropColor(unpack(COLORS.panelBg))
    f:SetBackdropBorderColor(unpack(COLORS.panelBorder))

    -- Fondo artístico con Scrim (Inspirado en Chairfaces Casino ApplyTavernBackground)
    if ns.ApplyTavernBackground then
        ns.ApplyTavernBackground(f, { scrim = 0.68 })
    end

    -- Cabecera superior con degradado
    local header = CreateFrame("Frame", nil, f, "BackdropTemplate")
    header:SetSize(VIEWER_WIDTH - 6, 42)
    header:SetPoint("TOP", 0, -3)
    header:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    header:SetBackdropColor(unpack(COLORS.headerBg))
    header:SetBackdropBorderColor(unpack(COLORS.headerBorder))

    local headerGlow = header:CreateTexture(nil, "ARTWORK")
    headerGlow:SetTexture("Interface\\Buttons\\WHITE8x8")
    headerGlow:SetPoint("TOPLEFT", 1, -1)
    headerGlow:SetPoint("TOPRIGHT", -1, -1)
    headerGlow:SetHeight(24)
    if headerGlow.SetGradient then
        headerGlow:SetGradient("VERTICAL", CreateColor(0.6, 0.45, 0.1, 0.4), CreateColor(0.6, 0.45, 0.1, 0))
    end

    -- Emblema circular oficial
    local crest = header:CreateTexture(nil, "OVERLAY")
    crest:SetSize(32, 32)
    crest:SetPoint("LEFT", 10, 0)
    crest:SetTexture("Interface\\AddOns\\AwakeningCompanion\\Media\\Icons\\awakening_crest.tga")
    if crest.SetMask then
        pcall(crest.SetMask, crest, "Interface\\CharacterFrame\\TempPortraitAlphaMask")
    end

    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", crest, "RIGHT", 10, 5)
    title:SetText("|cFFFFD100SITIO DE EXCAVACIÓN: LOS HUMEDALES|r")
    if title.SetFont then
        title:SetFont("Fonts\\FRIZQT__.TTF", 15, "OUTLINE")
    end
    f.titleText = title

    local subtitle = header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    subtitle:SetPoint("LEFT", crest, "RIGHT", 10, -9)
    subtitle:SetText("|cFFCCAA66GUÍA OFICIAL DE MAZMORRA · NIVEL 24-30 · LOS HUMEDALES|r")
    f.subtitleText = subtitle

    -- Botón de cerrar superior
    local closeBtn = CreateFrame("Button", nil, header, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    -- Barra horizontal de pestañas (Estilo Chairfaces Casino)
    local tabBar = CreateFrame("Frame", nil, f)
    tabBar:SetSize(VIEWER_WIDTH - 20, 32)
    tabBar:SetPoint("TOP", header, "BOTTOM", 0, -6)
    f.tabBar = tabBar
    f.tabs = {}
    f.tabButtons = {}

    local tabWidth = (VIEWER_WIDTH - 30) / 4
    for i = 1, 4 do
        local tab = CreateFrame("Button", nil, tabBar, "BackdropTemplate")
        tab:SetSize(tabWidth - 4, 28)
        tab:SetPoint("LEFT", (i - 1) * tabWidth + 2, 0)
        tab:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        tab.index = i

        local tIcon = tab:CreateTexture(nil, "ARTWORK")
        tIcon:SetSize(16, 16)
        tIcon:SetPoint("LEFT", 8, 0)
        tab.icon = tIcon

        local tText = tab:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        tText:SetPoint("LEFT", tIcon, "RIGHT", 6, 0)
        tText:SetPoint("RIGHT", -6, 0)
        tText:SetJustifyH("LEFT")
        tab.text = tText

        tab:SetScript("OnClick", function(selfTab)
            if selfTab.tabId then
                GV:SwitchTab(selfTab.tabId)
            end
        end)

        tab:SetScript("OnEnter", function(selfTab)
            if activeTab ~= selfTab.tabId then
                selfTab:SetBackdropColor(0.22, 0.18, 0.12, 1)
                selfTab:SetBackdropBorderColor(0.7, 0.55, 0.2, 1)
            end
        end)

        tab:SetScript("OnLeave", function(selfTab)
            if activeTab ~= selfTab.tabId then
                selfTab:SetBackdropColor(unpack(COLORS.tabInactiveBg))
                selfTab:SetBackdropBorderColor(unpack(COLORS.tabBorder))
            end
        end)

        f.tabButtons[i] = tab
    end

    -- Divisor decorativo horizontal
    local divider = f:CreateTexture(nil, "ARTWORK")
    divider:SetSize(VIEWER_WIDTH - 20, 1)
    divider:SetPoint("TOP", tabBar, "BOTTOM", 0, -4)
    divider:SetColorTexture(0.5, 0.4, 0.2, 0.8)

    -- Contenedor principal de pestañas
    local contentArea = CreateFrame("Frame", nil, f)
    contentArea:SetSize(VIEWER_WIDTH - 24, VIEWER_HEIGHT - 135)
    contentArea:SetPoint("TOP", divider, "BOTTOM", 0, -6)
    f.contentArea = contentArea

    -- Paneles individuales de Mazmorras
    f.panels = {}
    f.panels["overview"]    = GV:CreateOverviewPanel(contentArea)
    f.panels["quests"]      = GV:CreateQuestsPanel(contentArea)
    f.panels["bosses"]      = GV:CreateBossesPanel(contentArea)
    f.panels["loot"]        = GV:CreateLootPanel(contentArea)

    -- Paneles individuales de Consejos y Artículos
    f.panels["differences"] = GV:CreateDifferencesPanel(contentArea)
    f.panels["first_hour"]  = GV:CreateFirstHourPanel(contentArea)
    f.panels["professions"] = GV:CreateProfessionsPanel(contentArea)
    f.panels["mistakes"]    = GV:CreateMistakesPanel(contentArea)

    -- Paneles individuales de Economía & Bank Alt
    f.panels["bank_overview"] = GV:CreateBankOverviewPanel(contentArea)
    f.panels["bank_rules"]    = GV:CreateBankRulesPanel(contentArea)
    f.panels["bank_matrix"]   = GV:CreateBankMatrixPanel(contentArea)
    f.panels["bank_faq"]      = GV:CreateBankFAQPanel(contentArea)

    -- Paneles individuales de Puntos y Talentos Legacy (Method.gg)
    f.panels["legacy_overview"] = GV:CreateLegacyOverviewPanel(contentArea)
    f.panels["legacy_debate"]   = GV:CreateLegacyDebatePanel(contentArea)
    f.panels["legacy_builds"]   = GV:CreateLegacyBuildsPanel(contentArea)
    f.panels["legacy_talents"]  = GV:CreateLegacyTalentsPanel(contentArea)

    -- Barra inferior de botones de acción
    local bottomBar = CreateFrame("Frame", nil, f)
    bottomBar:SetSize(VIEWER_WIDTH - 20, 40)
    bottomBar:SetPoint("BOTTOM", 0, 8)
    f.bottomBar = bottomBar

    local btnNav = ns.CreateGameButton and ns.CreateGameButton(bottomBar, "GVNavBtn", "|TInterface\\Icons\\inv_misc_compass_01:16:16:0:0:64:64:4:60:4:60|t Iniciar Navegación HUD", 220, 30)
    if btnNav then
        btnNav:SetPoint("LEFT", 4, 0)
        btnNav:SetScript("OnClick", function()
            GV:StartNavigation()
        end)
    end
    f.btnNav = btnNav

    local btnTomTom = ns.CreateGameButton and ns.CreateGameButton(bottomBar, "GVTomTomBtn", "|TInterface\\Icons\\spell_nature_astralrecalgroup:16:16:0:0:64:64:4:60:4:60|t Marcar Entrada en TomTom", 220, 30)
    if btnTomTom then
        btnTomTom:SetPoint("LEFT", btnNav, "RIGHT", 10, 0)
        btnTomTom:SetScript("OnClick", function()
            GV:MarkTomTomEntrance()
        end)
    end
    f.btnTomTom = btnTomTom

    local btnClose = ns.CreateGameButton and ns.CreateGameButton(bottomBar, "GVCloseBtn", "Cerrar", 100, 30)
    if btnClose then
        btnClose:SetPoint("RIGHT", -4, 0)
        btnClose:SetScript("OnClick", function()
            f:Hide()
        end)
    end
    f.btnClose = btnClose

    viewerFrame = f
end

-- =========================================================================
-- CONFIGURACIÓN DINÁMICA DE PESTAÑAS (MAZMORRAS VS ARTÍCULOS VS BANK ALT)
-- =========================================================================
local DUNGEON_TAB_DEFS = {
    { id = "overview", text = "Resumen & Viaje", icon = "Interface\\Icons\\inv_misc_map02" },
    { id = "quests",   text = "Misiones de Mazmorra", icon = "Interface\\Icons\\inv_misc_book_11" },
    { id = "bosses",   text = "Jefes & Tácticas", icon = "Interface\\Icons\\inv_sword_04" },
    { id = "loot",     text = "Tabla de Botín", icon = "Interface\\Icons\\inv_misc_coin_01" },
}

local ARTICLE_TAB_DEFS = {
    { id = "differences", text = "Diferencias Classic", icon = "Interface\\Icons\\inv_misc_book_09" },
    { id = "first_hour",  text = "La Primera Hora",    icon = "Interface\\Icons\\trade_engineering" },
    { id = "professions", text = "Profesiones & Fogón", icon = "Interface\\Icons\\trade_herbalism" },
    { id = "mistakes",    text = "10 Errores a Evitar", icon = "Interface\\Icons\\ability_warrior_battleshout" },
}

local BANK_ALT_TAB_DEFS = {
    { id = "bank_overview", text = "Fundamentos & Pilares", icon = "Interface\\Icons\\inv_misc_coin_01" },
    { id = "bank_rules",    text = "Reglas de Gestión",     icon = "Interface\\Icons\\inv_scroll_03" },
    { id = "bank_matrix",   text = "Matriz de Inventario",  icon = "Interface\\Icons\\inv_misc_bag_08" },
    { id = "bank_faq",      text = "Preguntas Frecuentes",  icon = "Interface\\Icons\\inv_misc_questionmark" },
}

local LEGACY_TAB_DEFS = {
    { id = "legacy_overview", text = "Fundamentos & Árboles", icon = "Interface\\Icons\\inv_misc_book_09" },
    { id = "legacy_debate",   text = "Thrill vs Talented",    icon = "Interface\\Icons\\spell_nature_timestop" },
    { id = "legacy_builds",   text = "5 Builds Method",       icon = "Interface\\Icons\\inv_sword_04" },
    { id = "legacy_talents",  text = "Talentos Clave",        icon = "Interface\\Icons\\inv_misc_coin_01" },
}

function GV:SetupTabsForGuide(guideKey)
    if not viewerFrame or not viewerFrame.tabButtons then return end
    local isBankAlt = (guideKey == "bank_alt_guide")
    local isLegacy = (guideKey == "legacy_talents_guide")
    local isArticle = (guideKey == "beginners_guide") or (ns.Data.Secrets and ns.Data.Secrets[guideKey] and ns.Data.Secrets[guideKey].isArticle and not isBankAlt and not isLegacy)
    local defs = isBankAlt and BANK_ALT_TAB_DEFS or (isLegacy and LEGACY_TAB_DEFS or (isArticle and ARTICLE_TAB_DEFS or DUNGEON_TAB_DEFS))

    viewerFrame.tabs = {}
    for i = 1, 4 do
        local tab = viewerFrame.tabButtons[i]
        local def = defs[i]
        if tab and def then
            tab.tabId = def.id
            tab.icon:SetTexture(def.icon)
            tab.text:SetText(def.text)
            viewerFrame.tabs[def.id] = tab
            tab:Show()
        end
    end

    if isBankAlt then
        if viewerFrame.btnNav then
            viewerFrame.btnNav:SetText("|TInterface\\Icons\\inv_misc_book_09:16:16:0:0:64:64:4:60:4:60|t Volver a Guías")
            viewerFrame.btnNav:SetScript("OnClick", function()
                viewerFrame:Hide()
                if ns.MainUI then ns.MainUI:OpenTab("secrets") end
            end)
        end
        if viewerFrame.btnTomTom then
            viewerFrame.btnTomTom:SetText("|TInterface\\Icons\\inv_misc_coin_02:16:16:0:0:64:64:4:60:4:60|t Ver Matriz de Oro")
            viewerFrame.btnTomTom:SetScript("OnClick", function()
                GV:SwitchTab("bank_matrix")
            end)
        end
    elseif isLegacy then
        if viewerFrame.btnNav then
            viewerFrame.btnNav:SetText("|TInterface\\Icons\\inv_misc_book_09:16:16:0:0:64:64:4:60:4:60|t Volver a Guías")
            viewerFrame.btnNav:SetScript("OnClick", function()
                viewerFrame:Hide()
                if ns.MainUI then ns.MainUI:OpenTab("secrets") end
            end)
        end
        if viewerFrame.btnTomTom then
            viewerFrame.btnTomTom:SetText("|TInterface\\Icons\\inv_sword_04:16:16:0:0:64:64:4:60:4:60|t Ver 5 Builds Method")
            viewerFrame.btnTomTom:SetScript("OnClick", function()
                GV:SwitchTab("legacy_builds")
            end)
        end
    elseif isArticle then
        if viewerFrame.btnNav then
            viewerFrame.btnNav:SetText("|TInterface\\Icons\\inv_misc_book_09:16:16:0:0:64:64:4:60:4:60|t Volver a Guías")
            viewerFrame.btnNav:SetScript("OnClick", function()
                viewerFrame:Hide()
                if ns.MainUI then ns.MainUI:OpenTab("secrets") end
            end)
        end
        if viewerFrame.btnTomTom then
            viewerFrame.btnTomTom:SetText("|TInterface\\Icons\\spell_chargepositive:16:16:0:0:64:64:4:60:4:60|t Restablecer Tareas")
            viewerFrame.btnTomTom:SetScript("OnClick", function()
                GV:ResetChecklist()
            end)
        end
    else
        if viewerFrame.btnNav then
            viewerFrame.btnNav:SetText("|TInterface\\Icons\\inv_misc_compass_01:16:16:0:0:64:64:4:60:4:60|t Iniciar Navegación HUD")
            viewerFrame.btnNav:SetScript("OnClick", function()
                GV:StartNavigation()
            end)
        end
        if viewerFrame.btnTomTom then
            viewerFrame.btnTomTom:SetText("|TInterface\\Icons\\spell_nature_astralrecalgroup:16:16:0:0:64:64:4:60:4:60|t Marcar Entrada en TomTom")
            viewerFrame.btnTomTom:SetScript("OnClick", function()
                GV:MarkTomTomEntrance()
            end)
        end
    end
end

-- =========================================================================
-- PANEL 1: RESUMEN Y VIAJE DINÁMICO
-- =========================================================================
function GV:CreateOverviewPanel(parent)
    local p = CreateFrame("Frame", nil, parent)
    p:SetAllPoints()

    -- Tarjeta Izquierda: Información General
    local leftCard = CreateFrame("Frame", nil, p, "BackdropTemplate")
    leftCard:SetSize(385, p:GetHeight())
    leftCard:SetPoint("TOPLEFT", 0, 0)
    leftCard:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    leftCard:SetBackdropColor(unpack(COLORS.cardBg))
    leftCard:SetBackdropBorderColor(unpack(COLORS.cardBorder))

    local leftTitle = leftCard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    leftTitle:SetPoint("TOPLEFT", 12, -12)
    leftTitle:SetText("|cFFFFD100Ficha Técnica de la Mazmorra|r")

    local leftDesc = leftCard:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    leftDesc:SetPoint("TOPLEFT", leftTitle, "BOTTOMLEFT", 0, -8)
    leftDesc:SetPoint("RIGHT", leftCard, "RIGHT", -12, 0)
    leftDesc:SetJustifyH("LEFT")
    leftDesc:SetSpacing(3)
    p.leftDesc = leftDesc

    -- Tarjeta Derecha: Planificación de Viaje Multimodal (TravelPlanner)
    local rightCard = CreateFrame("Frame", nil, p, "BackdropTemplate")
    rightCard:SetSize(385, p:GetHeight())
    rightCard:SetPoint("TOPRIGHT", 0, 0)
    rightCard:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    rightCard:SetBackdropColor(unpack(COLORS.cardBg))
    rightCard:SetBackdropBorderColor(unpack(COLORS.cardBorder))

    local rightTitle = rightCard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    rightTitle:SetPoint("TOPLEFT", 12, -12)
    rightTitle:SetText("|cFF00FFCCTu Itinerario de Viaje en Vivo|r")

    local rightDesc = rightCard:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    rightDesc:SetPoint("TOPLEFT", rightTitle, "BOTTOMLEFT", 0, -8)
    rightDesc:SetPoint("RIGHT", rightCard, "RIGHT", -12, 0)
    rightDesc:SetJustifyH("LEFT")
    rightDesc:SetSpacing(3)
    p.rightDesc = rightDesc

    return p
end

-- =========================================================================
-- PANEL 2: MISIONES DE LA MAZMORRA
-- =========================================================================
function GV:CreateQuestsPanel(parent)
    local p = CreateFrame("Frame", nil, parent)
    p:SetAllPoints()

    -- ScrollFrame de misiones
    local sf = CreateFrame("ScrollFrame", "AwakeningGVQuestsScroll", p, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 0, 0)
    sf:SetPoint("BOTTOMRIGHT", -26, 0)

    local content = CreateFrame("Frame", nil, sf)
    content:SetSize(sf:GetWidth(), 1)
    sf:SetScrollChild(content)
    p.content = content
    p.rows = {}

    return p
end

-- =========================================================================
-- PANEL 3: JEFES Y TÁCTICAS
-- =========================================================================
function GV:CreateBossesPanel(parent)
    local p = CreateFrame("Frame", nil, parent)
    p:SetAllPoints()

    -- Lista lateral izquierda de jefes
    local sideList = CreateFrame("Frame", nil, p, "BackdropTemplate")
    sideList:SetSize(220, p:GetHeight())
    sideList:SetPoint("TOPLEFT", 0, 0)
    sideList:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    sideList:SetBackdropColor(unpack(COLORS.cardBg))
    sideList:SetBackdropBorderColor(unpack(COLORS.cardBorder))
    p.bossButtons = {}

    -- Panel derecho de detalle táctico
    local detailCard = CreateFrame("Frame", nil, p, "BackdropTemplate")
    detailCard:SetSize(p:GetWidth() - 230, p:GetHeight())
    detailCard:SetPoint("TOPRIGHT", 0, 0)
    detailCard:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    detailCard:SetBackdropColor(unpack(COLORS.cardBg))
    detailCard:SetBackdropBorderColor(unpack(COLORS.cardBorder))

    local sf = CreateFrame("ScrollFrame", "AwakeningGVBossDetailScroll", detailCard, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 8, -8)
    sf:SetPoint("BOTTOMRIGHT", -26, 8)

    local sfChild = CreateFrame("Frame", nil, sf)
    sfChild:SetSize(sf:GetWidth(), 1)
    sf:SetScrollChild(sfChild)
    p.detailContent = sfChild

    return p
end

-- =========================================================================
-- PANEL 4: TABLA DE BOTÍN (LOOT TABLE)
-- =========================================================================
function GV:CreateLootPanel(parent)
    local p = CreateFrame("Frame", nil, parent)
    p:SetAllPoints()

    local sf = CreateFrame("ScrollFrame", "AwakeningGVLootScroll", p, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 0, 0)
    sf:SetPoint("BOTTOMRIGHT", -26, 0)

    local content = CreateFrame("Frame", nil, sf)
    content:SetSize(sf:GetWidth(), 1)
    sf:SetScrollChild(content)
    p.content = content
    p.lootCards = {}

    return p
end

-- =========================================================================
-- CONMUTACIÓN DE PESTAÑAS Y ACTUALIZACIÓN VISUAL
-- =========================================================================
function GV:SwitchTab(tabId)
    activeTab = tabId or "overview"

    for id, tab in pairs(viewerFrame.tabs) do
        if id == activeTab then
            tab:SetBackdropColor(unpack(COLORS.tabActiveBg))
            tab:SetBackdropBorderColor(unpack(COLORS.headerBorder))
            tab.text:SetTextColor(1, 1, 1, 1)
        else
            tab:SetBackdropColor(unpack(COLORS.tabInactiveBg))
            tab:SetBackdropBorderColor(unpack(COLORS.tabBorder))
            tab.text:SetTextColor(0.8, 0.7, 0.5, 1)
        end
    end

    for id, panel in pairs(viewerFrame.panels) do
        if id == activeTab then
            panel:Show()
        else
            panel:Hide()
        end
    end

    self:UpdateActiveTab()
end

function GV:UpdateActiveTab()
    local guide = ns.Data.Secrets and ns.Data.Secrets[currentGuideKey]
    if not guide then return end

    if activeTab == "overview" then
        self:UpdateOverview(guide)
    elseif activeTab == "quests" then
        self:UpdateQuests(guide)
    elseif activeTab == "bosses" then
        self:UpdateBosses(guide)
    elseif activeTab == "loot" then
        self:UpdateLoot(guide)
    elseif activeTab == "differences" then
        self:UpdateDifferences()
    elseif activeTab == "first_hour" then
        self:UpdateFirstHour()
    elseif activeTab == "professions" then
        self:UpdateProfessions()
    elseif activeTab == "mistakes" then
        self:UpdateMistakes()
    elseif activeTab == "bank_overview" then
        self:UpdateBankOverview()
    elseif activeTab == "bank_rules" then
        self:UpdateBankRules()
    elseif activeTab == "bank_matrix" then
        self:UpdateBankMatrix()
    elseif activeTab == "bank_faq" then
        self:UpdateBankFAQ()
    elseif activeTab == "legacy_overview" then
        self:UpdateLegacyOverview()
    elseif activeTab == "legacy_debate" then
        self:UpdateLegacyDebate()
    elseif activeTab == "legacy_builds" then
        self:UpdateLegacyBuilds()
    elseif activeTab == "legacy_talents" then
        self:UpdateLegacyTalents()
    end
end

-- =========================================================================
-- ACTUALIZACIÓN: RESUMEN Y VIAJE
-- =========================================================================
function GV:UpdateOverview(guide)
    local p = viewerFrame.panels["overview"]
    if not p then return end

    local ent = guide.entrance or { x = 56.2, y = 40.6, zoneName = "Los Humedales" }

    local leftLines = {
        string.format("|cFFFFD100Mazmorra:|r |cFFFFFFFF%s|r", guide.title),
        string.format("|cFFFFD100Tipo:|r %s   ·   |cFFFFD100Facción:|r %s", guide.dungeonType or "Mazmorra", guide.faction or "Ambas"),
        string.format("|cFFFFD100Rango de Nivel:|r |cFF00FF00%s|r (Mínimo: %d)", guide.level or "24-30", guide.minLevel or 22),
        string.format("|cFFFFD100Zona / Continente:|r %s (Reinos del Este)", ent.zoneName or guide.zone or "Los Humedales"),
        string.format("|cFFFFD100Coordenadas Portal:|r |cFF00FFCC%.1f, %.1f|r (%s)", ent.x, ent.y, ent.name or "Entrada"),
        " ",
        "|cFFFFCC00Descripción General:|r",
        guide.overview or "Explora la nueva mazmorra de WoW Forever y reclama reliquias antiguas.",
        " ",
        "|cFFFF5555Peligros de la Zona (Trash Mobs):|r",
        guide.trashNotes or "Atraviesa con precaución evitando emboscadas.",
    }
    p.leftDesc:SetText(table.concat(leftLines, "\n"))

    -- Cálculo de viaje en tiempo real
    local rightLines = {
        "|cFFFFD100Cálculo Multimodal Autónomo (TravelPlanner):|r",
    }

    local playerLoc = ns.GetPlayerLocation and ns.GetPlayerLocation()
    if playerLoc and ent and ent.uiMapID and ent.x and ent.y and ns.TravelPlanner then
        local plan = ns.TravelPlanner:CalculateRoute("__player__", ent, { routingMode = "fastest" })
        if plan and plan.success then
            table.insert(rightLines, string.format("Tiempo estimado de llegada: |cFF00FF00~%.1f minutos|r (%d etapas)", plan.totalMinutes or 0, #plan.legs))
            table.insert(rightLines, " ")
            table.insert(rightLines, "|cFFFFCC00Itinerario Paso a Paso:|r")
            for idx, leg in ipairs(plan.legs) do
                local modeIcons = {
                    flight = "|TInterface\\Icons\\ability_mount_gryphon:14:14:0:0:64:64:4:60:4:60|t Vuelo",
                    boat   = "|TInterface\\Icons\\inv_misc_coin_01:14:14:0:0:64:64:4:60:4:60|t Barco",
                    tram   = "|TInterface\\Icons\\inv_misc_gear_01:14:14:0:0:64:64:4:60:4:60|t Tranvía",
                    walk   = "|TInterface\\Icons\\inv_boots_01:14:14:0:0:64:64:4:60:4:60|t Caminata",
                }
                local mStr = modeIcons[leg.mode] or leg.mode
                table.insert(rightLines, string.format("  |cFF00FFCC%d.|r %s a |cFFFFFFFF%s|r (~%.1f min)", idx, mStr, leg.toName, leg.minutes))
            end
        else
            table.insert(rightLines, "|cFF888888No se pudo calcular una ruta directa desde tu posición actual.|r")
        end
    else
        table.insert(rightLines, "|cFF888888Ubicación del jugador no disponible en este momento.|r")
    end

    table.insert(rightLines, " ")
    table.insert(rightLines, "|cFFFFD100Rutas Recomendadas por Facción:|r")
    if guide.travelNotes then
        if guide.travelNotes.alliance then
            table.insert(rightLines, "|cFF00CCFFAlianza:|r " .. guide.travelNotes.alliance)
        end
        if guide.travelNotes.horde then
            table.insert(rightLines, "|cFFFF4444Horda:|r " .. guide.travelNotes.horde)
        end
    end

    p.rightDesc:SetText(table.concat(rightLines, "\n"))
end

-- =========================================================================
-- ACTUALIZACIÓN: MISIONES DE LA MAZMORRA
-- =========================================================================
function GV:UpdateQuests(guide)
    local p = viewerFrame.panels["quests"]
    if not p then return end

    local quests = guide.quests or {}
    local content = p.content
    local rows = p.rows

    local yOffset = 0
    for i, q in ipairs(quests) do
        local row = rows[i]
        if not row then
            row = CreateFrame("Frame", nil, content, "BackdropTemplate")
            row:SetSize(content:GetWidth() - 10, 68)
            row:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            row:SetBackdropColor(unpack(COLORS.cardBg))
            row:SetBackdropBorderColor(unpack(COLORS.cardBorder))

            local icon = row:CreateTexture(nil, "ARTWORK")
            icon:SetSize(28, 28)
            icon:SetPoint("LEFT", 10, 0)
            icon:SetTexture("Interface\\Icons\\inv_misc_book_11")
            row.icon = icon

            local title = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, 2)
            row.title = title

            local details = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            details:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
            details:SetPoint("RIGHT", -110, 0)
            details:SetJustifyH("LEFT")
            row.details = details

            local actionBtn = ns.CreateGameButton and ns.CreateGameButton(row, nil, "Marcar /way", 95, 24)
            if actionBtn then
                actionBtn:SetPoint("RIGHT", -10, 0)
                row.actionBtn = actionBtn
            end

            rows[i] = row
        end

        row:SetPoint("TOPLEFT", 5, -yOffset)
        row.title:SetText(string.format("|cFFFFD100[Nv. %d]|r |cFFFFFFFF%s|r (|cFF00FFCC%s|r)", q.minLevel or 24, q.name, q.type or "Misión"))
        
        local giverStr = string.format("Dador: |cFFFFFFFF%s|r (%s%s)", q.npcName or "Varios", q.zone or "Los Humedales", q.x and string.format(" · %.1f, %.1f", q.x, q.y) or "")
        local descStr = q.desc or ""
        row.details:SetText(giverStr .. "\n|cFF88DDFF" .. descStr .. "|r")

        if row.actionBtn then
            row.actionBtn:SetScript("OnClick", function()
                if q.x and q.y and SlashCmdList["TOMTOM_WAY"] then
                    SlashCmdList["TOMTOM_WAY"](string.format("%.1f %.1f %s", q.x, q.y, q.name))
                    ns.Print(string.format("Waypoint añadido a TomTom: |cFFFFD100%s|r (%.1f, %.1f)", q.name, q.x, q.y))
                elseif q.x and q.y and ns.GuideHUD then
                    local step = {
                        uiMapID = guide.uiMapID or 1437,
                        x = q.x,
                        y = q.y,
                        title = q.name,
                        instruction = "Habla con " .. (q.npcName or "el dador de misión"),
                        icon = "Interface\\Icons\\inv_misc_book_11",
                    }
                    ns.GuideHUD:StartRoute({ title = q.name, steps = { step } }, "quest_waypoint", 1)
                end
            end)
        end

        row:Show()
        yOffset = yOffset + 74
    end

    for i = #quests + 1, #rows do
        rows[i]:Hide()
    end

    content:SetHeight(math.max(yOffset, p:GetHeight()))
end

-- =========================================================================
-- ACTUALIZACIÓN: JEFES Y TÁCTICAS
-- =========================================================================
function GV:UpdateBosses(guide)
    local p = viewerFrame.panels["bosses"]
    if not p then return end

    local bosses = guide.bosses or {}
    local bossBtns = p.bossButtons

    local yOffset = 10
    for i, b in ipairs(bosses) do
        local btn = bossBtns[i]
        if not btn then
            btn = CreateFrame("Button", nil, p, "BackdropTemplate")
            btn:SetSize(200, 36)
            btn:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            btn.idx = i

            local icon = btn:CreateTexture(nil, "ARTWORK")
            icon:SetSize(24, 24)
            icon:SetPoint("LEFT", 8, 0)
            btn.icon = icon

            local text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            text:SetPoint("LEFT", icon, "RIGHT", 8, 0)
            text:SetPoint("RIGHT", -6, 0)
            text:SetJustifyH("LEFT")
            btn.text = text

            btn:SetScript("OnClick", function(self)
                activeBossIdx = self.idx
                GV:UpdateBossDetail(guide)
            end)

            bossBtns[i] = btn
        end

        btn:SetPoint("TOPLEFT", 10, -yOffset)
        btn.icon:SetTexture(b.icon or "Interface\\Icons\\inv_sword_04")
        btn.text:SetText(b.name)

        if activeBossIdx == i then
            btn:SetBackdropColor(unpack(COLORS.tabActiveBg))
            btn:SetBackdropBorderColor(unpack(COLORS.headerBorder))
        else
            btn:SetBackdropColor(unpack(COLORS.cardBg))
            btn:SetBackdropBorderColor(unpack(COLORS.cardBorder))
        end

        btn:Show()
        yOffset = yOffset + 42
    end

    for i = #bosses + 1, #bossBtns do
        bossBtns[i]:Hide()
    end

    self:UpdateBossDetail(guide)
end

function GV:UpdateBossDetail(guide)
    local p = viewerFrame.panels["bosses"]
    if not p then return end

    local bosses = guide.bosses or {}
    local b = bosses[activeBossIdx] or bosses[1]
    if not b then return end

    -- Resaltar botón activo
    for i, btn in ipairs(p.bossButtons) do
        if i == activeBossIdx then
            btn:SetBackdropColor(unpack(COLORS.tabActiveBg))
            btn:SetBackdropBorderColor(unpack(COLORS.headerBorder))
        else
            btn:SetBackdropColor(unpack(COLORS.cardBg))
            btn:SetBackdropBorderColor(unpack(COLORS.cardBorder))
        end
    end

    local detail = p.detailContent
    if not detail.headerText then
        detail.headerText = detail:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        detail.headerText:SetPoint("TOPLEFT", 10, -10)

        detail.strategyText = detail:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        detail.strategyText:SetPoint("TOPLEFT", detail.headerText, "BOTTOMLEFT", 0, -10)
        detail.strategyText:SetPoint("RIGHT", detail, "RIGHT", -12, 0)
        detail.strategyText:SetJustifyH("LEFT")
        detail.strategyText:SetSpacing(4)
    end

    detail.headerText:SetText(string.format("|cFFFFD100%s|r  |cFF88DDFF(Nivel %d)|r", b.name, b.level or 25))

    local lines = {
        "|cFFFFCC00Habilidades Principales:|r",
    }
    if b.abilities then
        for _, ab in ipairs(b.abilities) do
            table.insert(lines, string.format("  • |cFF00FFCC%s:|r %s", ab.name, ab.desc))
        end
    end
    table.insert(lines, " ")
    table.insert(lines, "|cFF00FF00Estrategia y Táctica del Encuentro:|r")
    table.insert(lines, b.strategy or "Derrota al jefe coordinando interrupciones y control de masas.")

    detail.strategyText:SetText(table.concat(lines, "\n"))
    detail:SetHeight(detail.strategyText:GetStringHeight() + 80)
end

-- =========================================================================
-- ACTUALIZACIÓN: TABLA DE BOTÍN (LOOT TABLE)
-- =========================================================================
function GV:UpdateLoot(guide)
    local p = viewerFrame.panels["loot"]
    if not p then return end

    local loot = guide.loot or {}
    local content = p.content
    local cards = p.lootCards

    local cardW = (content:GetWidth() - 20) / 2
    local cardH = 58
    local yOffset = 0

    for i, item in ipairs(loot) do
        local card = cards[i]
        if not card then
            card = CreateFrame("Button", nil, content, "BackdropTemplate")
            card:SetSize(cardW, cardH)
            card:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            card:SetBackdropColor(unpack(COLORS.cardBg))
            card:SetBackdropBorderColor(unpack(COLORS.cardBorder))

            local icon = card:CreateTexture(nil, "ARTWORK")
            icon:SetSize(36, 36)
            icon:SetPoint("LEFT", 8, 0)
            card.icon = icon

            local name = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            name:SetPoint("TOPLEFT", icon, "TOPRIGHT", 8, 2)
            name:SetPoint("RIGHT", -8, 0)
            name:SetJustifyH("LEFT")
            card.name = name

            local meta = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            meta:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -3)
            meta:SetPoint("RIGHT", -8, 0)
            meta:SetJustifyH("LEFT")
            card.meta = meta

            card:SetScript("OnEnter", function(self)
                if self.itemID and self.itemID > 0 then
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    local _, link = GetItemInfo(self.itemID)
                    if link then
                        GameTooltip:SetHyperlink(link)
                    elseif GameTooltip.SetItemByID then
                        GameTooltip:SetItemByID(self.itemID)
                    end
                    GameTooltip:Show()
                end
            end)

            card:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            cards[i] = card
        end

        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        card:SetPoint("TOPLEFT", col * (cardW + 8) + 5, -row * (cardH + 8))

        card.itemID = item.itemID
        card.icon:SetTexture(item.icon or "Interface\\Icons\\inv_misc_questionmark")
        
        local qualColor = "|cFF0070DD" -- Azul raro por defecto
        if item.quality == 4 then qualColor = "|cFFA335EE"
        elseif item.quality == 2 then qualColor = "|cFF00FF00" end

        card.name:SetText(string.format("%s%s|r", qualColor, item.name))
        card.meta:SetText(string.format("|cFFFFFFFF%s|r · |cFF88DDFF%s|r (Jefe: %s)", item.type or "Equipo", item.slot or "Varios", item.boss or "Todos"))

        card:Show()
    end

    for i = #loot + 1, #cards do
        cards[i]:Hide()
    end

    local numRows = math.ceil(#loot / 2)
    content:SetHeight(math.max(numRows * (cardH + 8) + 20, p:GetHeight()))
end

-- =========================================================================
-- ACCIONES DE NAVEGACIÓN Y COMPÁS
-- =========================================================================
function GV:StartNavigation()
    local guide = ns.Data.Secrets and ns.Data.Secrets[currentGuideKey]
    if not guide then return end

    if ns.GuideHUD then
        local curMilestone = (ns.GetSecretProgress and ns.GetSecretProgress(currentGuideKey)) or 1
        local guideData, startStep = ns.GetDynamicSecretGuide and ns.GetDynamicSecretGuide(currentGuideKey, curMilestone)
        if not guideData then
            guideData = guide
            startStep = curMilestone
        end
        ns.GuideHUD:StartRoute(guideData, currentGuideKey, startStep)
        ns.Print("Ruta de navegación cargada en el HUD para: " .. guide.title)
    end
end

function GV:MarkTomTomEntrance()
    local guide = ns.Data.Secrets and ns.Data.Secrets[currentGuideKey]
    if not guide then return end

    local ent = guide.entrance or { x = 56.2, y = 40.6, name = "Entrada al Sitio de Excavación" }
    if SlashCmdList["TOMTOM_WAY"] then
        SlashCmdList["TOMTOM_WAY"](string.format("%.1f %.1f %s", ent.x, ent.y, ent.name))
        ns.Print(string.format("Waypoint añadido a TomTom: |cFFFFD100%s|r (%.1f, %.1f)", ent.name, ent.x, ent.y))
    elseif ns.GuideHUD then
        local step = {
            uiMapID = ent.uiMapID or 1437,
            x = ent.x,
            y = ent.y,
            title = ent.name,
            instruction = "Entra a la mazmorra",
            icon = "Interface\\Icons\\inv_misc_key_02",
        }
        ns.GuideHUD:StartRoute({ title = ent.name, steps = { step } }, "entrance_waypoint", 1)
    end
end

-- =========================================================================
-- PANEL 5: DIFERENCIAS CRÍTICAS (WOW FOREVER VS WOW CLASSIC)
-- =========================================================================
function GV:CreateDifferencesPanel(parent)
    local p = CreateFrame("Frame", nil, parent)
    p:SetAllPoints()

    local sf = CreateFrame("ScrollFrame", "AwakeningGVDifferencesScroll", p, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 0, 0)
    sf:SetPoint("BOTTOMRIGHT", -26, 0)

    local content = CreateFrame("Frame", nil, sf)
    content:SetSize(sf:GetWidth(), 1)
    sf:SetScrollChild(content)
    p.content = content
    p.cards = {}

    -- Banner superior
    local banner = CreateFrame("Frame", nil, content, "BackdropTemplate")
    banner:SetSize(760, 48)
    banner:SetPoint("TOPLEFT", 10, -5)
    banner:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    banner:SetBackdropColor(unpack(COLORS.headerBg))
    banner:SetBackdropBorderColor(unpack(COLORS.headerBorder))

    local bTitle = banner:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    bTitle:SetPoint("TOPLEFT", 12, -8)
    bTitle:SetText("|cFFFFD100WoW Forever vs WoW Classic: Comparativa de Sistemas|r")

    local bSub = banner:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bSub:SetPoint("TOPLEFT", bTitle, "BOTTOMLEFT", 0, -4)
    bSub:SetPoint("RIGHT", -12, 0)
    bSub:SetJustifyH("LEFT")
    bSub:SetText("|cFFDDDDDDConoce qué hábitos clásicos se mantienen y qué novedades transforman la experiencia de juego.|r")

    -- Encabezados de tabla
    local thFrame = CreateFrame("Frame", nil, content, "BackdropTemplate")
    thFrame:SetSize(760, 22)
    thFrame:SetPoint("TOPLEFT", banner, "BOTTOMLEFT", 0, -6)
    thFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    thFrame:SetBackdropColor(0.04, 0.04, 0.06, 0.9)
    thFrame:SetBackdropBorderColor(0.4, 0.35, 0.2, 0.8)

    local th1 = thFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    th1:SetPoint("LEFT", 12, 0)
    th1:SetWidth(150)
    th1:SetJustifyH("LEFT")
    th1:SetText("|cFFFFD100Sistema|r")

    local th2 = thFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    th2:SetPoint("LEFT", th1, "RIGHT", 10, 0)
    th2:SetWidth(260)
    th2:SetJustifyH("LEFT")
    th2:SetText("|cFFCCCCCCWoW Classic (Hábito Viejo)|r")

    local th3 = thFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    th3:SetPoint("LEFT", th2, "RIGHT", 10, 0)
    th3:SetPoint("RIGHT", -12, 0)
    th3:SetJustifyH("LEFT")
    th3:SetText("|cFF00FF00WoW Forever (Novedades & Reglas)|r")

    p.thFrame = thFrame
    return p
end

function GV:UpdateDifferences()
    local p = viewerFrame and viewerFrame.panels["differences"]
    if not p then return end

    local diffData = ns.Data.BeginnersGuide and ns.Data.BeginnersGuide.differences
    local tableData = diffData and diffData.table or {}
    local content = p.content

    local yOffset = -82
    for i, item in ipairs(tableData) do
        local card = p.cards[i]
        if not card then
            card = CreateFrame("Frame", nil, content, "BackdropTemplate")
            card:SetSize(760, 52)
            card:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            card:SetBackdropColor(unpack(COLORS.cardBg))
            card:SetBackdropBorderColor(unpack(COLORS.cardBorder))

            local sysText = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            sysText:SetPoint("TOPLEFT", 12, -8)
            sysText:SetWidth(150)
            sysText:SetJustifyH("LEFT")
            card.sysText = sysText

            local statusBadge = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            statusBadge:SetPoint("TOPLEFT", sysText, "BOTTOMLEFT", 0, -3)
            statusBadge:SetJustifyH("LEFT")
            card.statusBadge = statusBadge

            local classicText = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            classicText:SetPoint("TOPLEFT", card, "TOPLEFT", 172, -8)
            classicText:SetWidth(260)
            classicText:SetJustifyH("LEFT")
            classicText:SetSpacing(2)
            card.classicText = classicText

            local foreverText = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            foreverText:SetPoint("TOPLEFT", card, "TOPLEFT", 442, -8)
            foreverText:SetPoint("RIGHT", card, "RIGHT", -12, 0)
            foreverText:SetJustifyH("LEFT")
            foreverText:SetSpacing(2)
            card.foreverText = foreverText

            p.cards[i] = card
        end

        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", content, "TOPLEFT", 10, yOffset)

        card.sysText:SetText("|cFFFFD100" .. item.system .. "|r")
        if item.status == "new" then
            card.statusBadge:SetText("|cFF00FF00[NUEVO]|r")
            card:SetBackdropBorderColor(0.2, 0.6, 0.3, 0.8)
        elseif item.status == "alert" then
            card.statusBadge:SetText("|cFFFF5533[CAMBIO CLAVE]|r")
            card:SetBackdropBorderColor(0.7, 0.4, 0.2, 0.9)
        else
            card.statusBadge:SetText("|cFF88DDFF[REGLA]|r")
            card:SetBackdropBorderColor(unpack(COLORS.cardBorder))
        end

        card.classicText:SetText("|cFF999999" .. item.classic .. "|r")
        card.foreverText:SetText("|cFFFFFFFF" .. item.forever .. "|r")

        card:Show()
        yOffset = yOffset - 58
    end

    content:SetHeight(math.abs(yOffset) + 20)
end

-- =========================================================================
-- PANEL 6: LA PRIMERA HORA (CHECKLIST DE 6 PASOS)
-- =========================================================================
function GV:CreateFirstHourPanel(parent)
    local p = CreateFrame("Frame", nil, parent)
    p:SetAllPoints()

    local sf = CreateFrame("ScrollFrame", "AwakeningGVFirstHourScroll", p, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 0, 0)
    sf:SetPoint("BOTTOMRIGHT", -26, 0)

    local content = CreateFrame("Frame", nil, sf)
    content:SetSize(sf:GetWidth(), 1)
    sf:SetScrollChild(content)
    p.content = content
    p.stepCards = {}

    -- Banner de Progreso (Readiness Gauge)
    local banner = CreateFrame("Frame", nil, content, "BackdropTemplate")
    banner:SetSize(760, 52)
    banner:SetPoint("TOPLEFT", 10, -5)
    banner:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    banner:SetBackdropColor(unpack(COLORS.headerBg))
    banner:SetBackdropBorderColor(unpack(COLORS.headerBorder))

    local bTitle = banner:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    bTitle:SetPoint("TOPLEFT", 14, -8)
    bTitle:SetText("|cFFFFD100Tu Primera Hora: 6 Pasos Indispensables|r")

    local gauge = CreateFrame("StatusBar", nil, banner)
    gauge:SetSize(280, 14)
    gauge:SetPoint("TOPRIGHT", -14, -10)
    gauge:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    gauge:SetMinMaxValues(0, 6)
    gauge:SetValue(0)
    gauge:SetStatusBarColor(0.1, 0.7, 0.3, 1)

    local gBg = gauge:CreateTexture(nil, "BACKGROUND")
    gBg:SetAllPoints()
    gBg:SetColorTexture(0.08, 0.08, 0.1, 0.9)

    local gText = gauge:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    gText:SetPoint("CENTER", gauge, "CENTER", 0, 0)
    gText:SetText("0 / 6 (0%)")
    banner.gauge = gauge
    banner.gaugeText = gText

    local bSub = banner:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bSub:SetPoint("TOPLEFT", bTitle, "BOTTOMLEFT", 0, -5)
    bSub:SetPoint("RIGHT", gauge, "LEFT", -15, 0)
    bSub:SetJustifyH("LEFT")
    bSub:SetText("|cFFDDDDDDMarca las casillas conforme completes cada hito en tus primeros niveles.|r")

    p.banner = banner
    return p
end

function GV:UpdateFirstHour()
    local p = viewerFrame and viewerFrame.panels["first_hour"]
    if not p then return end

    local steps = ns.Data.BeginnersGuide and ns.Data.BeginnersGuide.firstHour and ns.Data.BeginnersGuide.firstHour.steps or {}
    local content = p.content

    AwakeningDB = AwakeningDB or {}
    AwakeningDB.firstHourChecks = AwakeningDB.firstHourChecks or {}

    local doneCount = 0
    for _, s in ipairs(steps) do
        if AwakeningDB.firstHourChecks[s.id] then
            doneCount = doneCount + 1
        end
    end

    if p.banner and p.banner.gauge then
        p.banner.gauge:SetValue(doneCount)
        local pct = math.floor((doneCount / math.max(1, #steps)) * 100)
        p.banner.gaugeText:SetText(string.format("Completado: %d de %d (%d%%)", doneCount, #steps, pct))
        if pct == 100 then
            p.banner.gauge:SetStatusBarColor(0.1, 0.8, 0.2, 1)
        elseif pct >= 50 then
            p.banner.gauge:SetStatusBarColor(0.8, 0.65, 0.1, 1)
        else
            p.banner.gauge:SetStatusBarColor(0.2, 0.5, 0.8, 1)
        end
    end

    local yOffset = -66
    for i, item in ipairs(steps) do
        local card = p.stepCards[i]
        if not card then
            card = CreateFrame("Frame", nil, content, "BackdropTemplate")
            card:SetSize(760, 68)
            card:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            card:SetBackdropColor(unpack(COLORS.cardBg))
            card:SetBackdropBorderColor(unpack(COLORS.cardBorder))

            -- Checkbox interactivo
            local chk = CreateFrame("CheckButton", nil, card, "UICheckButtonTemplate")
            chk:SetSize(24, 24)
            chk:SetPoint("LEFT", card, "LEFT", 10, 0)
            card.chk = chk

            local icon = card:CreateTexture(nil, "ARTWORK")
            icon:SetSize(36, 36)
            icon:SetPoint("LEFT", chk, "RIGHT", 6, 0)
            card.icon = icon

            local title = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 10, 2)
            title:SetPoint("RIGHT", card, "RIGHT", -12, 0)
            title:SetJustifyH("LEFT")
            card.title = title

            local desc = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -3)
            desc:SetPoint("RIGHT", card, "RIGHT", -12, 0)
            desc:SetJustifyH("LEFT")
            desc:SetSpacing(2)
            card.desc = desc

            local tip = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            tip:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -3)
            tip:SetPoint("RIGHT", card, "RIGHT", -12, 0)
            tip:SetJustifyH("LEFT")
            card.tip = tip

            card.itemId = item.id
            chk:SetScript("OnClick", function(selfChk)
                local isChecked = selfChk:GetChecked()
                AwakeningDB.firstHourChecks[item.id] = isChecked
                if PlaySound then
                    PlaySound(isChecked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
                end
                GV:UpdateFirstHour()
            end)

            p.stepCards[i] = card
        end

        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", content, "TOPLEFT", 10, yOffset)

        local isChecked = AwakeningDB.firstHourChecks[item.id] or false
        card.chk:SetChecked(isChecked)
        card.icon:SetTexture(item.icon or "Interface\\Icons\\inv_misc_questionmark")
        card.title:SetText(string.format("%d. %s", item.num, item.title))
        card.desc:SetText(item.desc)
        card.tip:SetText("|cFFFFCC00Consejo:|r " .. item.tip)

        if isChecked then
            card:SetBackdropColor(0.04, 0.12, 0.06, 0.9)
            card:SetBackdropBorderColor(0.2, 0.8, 0.3, 0.9)
            card.title:SetTextColor(0.4, 1.0, 0.5, 1)
        else
            card:SetBackdropColor(unpack(COLORS.cardBg))
            card:SetBackdropBorderColor(unpack(COLORS.cardBorder))
            card.title:SetTextColor(1, 0.84, 0, 1)
        end

        card:Show()
        yOffset = yOffset - 76
    end

    content:SetHeight(math.abs(yOffset) + 20)
end

function GV:ResetChecklist()
    AwakeningDB = AwakeningDB or {}
    AwakeningDB.firstHourChecks = {}
    ns.Print("Checklist de la Primera Hora restablecido.")
    if activeTab == "first_hour" then
        self:UpdateFirstHour()
    end
end

-- =========================================================================
-- PANEL 7: PROFESIONES Y LA REGLA DE ORO DEL CAMPAMENTO
-- =========================================================================
function GV:CreateProfessionsPanel(parent)
    local p = CreateFrame("Frame", nil, parent)
    p:SetAllPoints()

    local sf = CreateFrame("ScrollFrame", "AwakeningGVProfessionsScroll", p, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 0, 0)
    sf:SetPoint("BOTTOMRIGHT", -26, 0)

    local content = CreateFrame("Frame", nil, sf)
    content:SetSize(sf:GetWidth(), 1)
    sf:SetScrollChild(content)
    p.content = content
    p.pairCards = {}

    -- 1. Tarjeta Dorada: La Regla de Oro del Campamento
    local campCard = CreateFrame("Frame", nil, content, "BackdropTemplate")
    campCard:SetSize(760, 95)
    campCard:SetPoint("TOPLEFT", 10, -5)
    campCard:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    campCard:SetBackdropColor(0.14, 0.10, 0.04, 0.95)
    campCard:SetBackdropBorderColor(0.85, 0.70, 0.20, 1)

    local cIcon = campCard:CreateTexture(nil, "ARTWORK")
    cIcon:SetSize(40, 40)
    cIcon:SetPoint("TOPLEFT", 12, -12)
    cIcon:SetTexture("Interface\\Icons\\spell_fire_fire")

    local cTitle = campCard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    cTitle:SetPoint("TOPLEFT", cIcon, "TOPRIGHT", 10, 2)
    cTitle:SetText("|cFFFFD100LA REGLA DE ORO: SIÉNTATE 1 MINUTO = 1 HORA DE BUFO|r")

    local cText = campCard:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    cText:SetPoint("TOPLEFT", cTitle, "BOTTOMLEFT", 0, -4)
    cText:SetPoint("RIGHT", campCard, "RIGHT", -12, 0)
    cText:SetJustifyH("LEFT")
    cText:SetSpacing(2)
    cText:SetText("|cFFFFFFFF• Sentarse cerca de cualquier fogón activo (/sit) durante 60 segundos otorga hasta 1 hora de bufos de combate.\n• Capacidad de objetos: Fogón básico (3 objetos), Fogones avanzados (5 o 10). Los bufos NO solapan con los de clase.\n• Hito de Nivel 20: Sube tu profesión primaria a nivel 20 mientras leveleas para desbloquear tu primer objeto de campamento.|r")
    p.campCard = campCard

    -- 2. Título de Sección: Parejas de Profesiones Recomendadas
    local pSecTitle = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    pSecTitle:SetPoint("TOPLEFT", campCard, "BOTTOMLEFT", 0, -10)
    pSecTitle:SetText("|cFFFFD100Parejas de Profesiones Óptimas para Leveleo (1-60)|r")
    p.pSecTitle = pSecTitle

    return p
end

function GV:UpdateProfessions()
    local p = viewerFrame and viewerFrame.panels["professions"]
    if not p then return end

    local profData = ns.Data.BeginnersGuide and ns.Data.BeginnersGuide.professions
    local pairings = profData and profData.pairings or {}
    local content = p.content

    local cardW = 374
    local cardH = 68
    local startY = -135

    for i, item in ipairs(pairings) do
        local card = p.pairCards[i]
        if not card then
            card = CreateFrame("Frame", nil, content, "BackdropTemplate")
            card:SetSize(cardW, cardH)
            card:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            card:SetBackdropColor(unpack(COLORS.cardBg))
            card:SetBackdropBorderColor(unpack(COLORS.cardBorder))

            local icon = card:CreateTexture(nil, "ARTWORK")
            icon:SetSize(32, 32)
            icon:SetPoint("LEFT", 10, 0)
            card.icon = icon

            local title = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            title:SetPoint("TOPLEFT", icon, "TOPRIGHT", 8, 2)
            title:SetPoint("RIGHT", -8, 0)
            title:SetJustifyH("LEFT")
            card.title = title

            local role = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            role:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)
            role:SetPoint("RIGHT", -8, 0)
            role:SetJustifyH("LEFT")
            card.role = role

            local desc = card:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
            desc:SetPoint("TOPLEFT", role, "BOTTOMLEFT", 0, -2)
            desc:SetPoint("RIGHT", -8, 0)
            desc:SetJustifyH("LEFT")
            desc:SetSpacing(1)
            card.desc = desc

            p.pairCards[i] = card
        end

        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", content, "TOPLEFT", 10 + col * (cardW + 12), startY - row * (cardH + 8))

        card.icon:SetTexture(item.icon or "Interface\\Icons\\trade_engineering")
        card.title:SetText("|cFFFFD100" .. item.pair .. "|r")
        card.role:SetText("|cFF00FFCC" .. item.role .. "|r")
        card.desc:SetText("|cFFDDDDDD" .. item.desc .. "|r")
        card:Show()
    end

    local numRows = math.ceil(#pairings / 2)
    local totalH = math.abs(startY) + (numRows * (cardH + 8)) + 30
    content:SetHeight(totalH)
end

-- =========================================================================
-- PANEL 8: 10 ERRORES COMUNES A EVITAR
-- =========================================================================
function GV:CreateMistakesPanel(parent)
    local p = CreateFrame("Frame", nil, parent)
    p:SetAllPoints()

    local sf = CreateFrame("ScrollFrame", "AwakeningGVMistakesScroll", p, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 0, 0)
    sf:SetPoint("BOTTOMRIGHT", -26, 0)

    local content = CreateFrame("Frame", nil, sf)
    content:SetSize(sf:GetWidth(), 1)
    sf:SetScrollChild(content)
    p.content = content
    p.mistakeCards = {}

    -- Banner
    local banner = CreateFrame("Frame", nil, content, "BackdropTemplate")
    banner:SetSize(760, 48)
    banner:SetPoint("TOPLEFT", 10, -5)
    banner:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    banner:SetBackdropColor(unpack(COLORS.headerBg))
    banner:SetBackdropBorderColor(unpack(COLORS.headerBorder))

    local bTitle = banner:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    bTitle:SetPoint("TOPLEFT", 12, -8)
    bTitle:SetText("|cFFFFD10010 Errores de Novato (y de Veterano de Classic) a Evitar|r")

    local bSub = banner:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bSub:SetPoint("TOPLEFT", bTitle, "BOTTOMLEFT", 0, -4)
    bSub:SetPoint("RIGHT", -12, 0)
    bSub:SetJustifyH("LEFT")
    bSub:SetText("|cFFDDDDDDMuchos jugadores tropiezan aplicando viejos hábitos de Classic o Retail en WoW Forever.|r")

    p.banner = banner
    return p
end

function GV:UpdateMistakes()
    local p = viewerFrame and viewerFrame.panels["mistakes"]
    if not p then return end

    local mistakes = ns.Data.BeginnersGuide and ns.Data.BeginnersGuide.mistakes and ns.Data.BeginnersGuide.mistakes.list or {}
    local content = p.content

    local yOffset = -60
    for i, item in ipairs(mistakes) do
        local card = p.mistakeCards[i]
        if not card then
            card = CreateFrame("Frame", nil, content, "BackdropTemplate")
            card:SetSize(760, 56)
            card:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            card:SetBackdropColor(unpack(COLORS.cardBg))
            card:SetBackdropBorderColor(unpack(COLORS.cardBorder))

            local catPill = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            catPill:SetPoint("TOPRIGHT", -12, -8)
            card.catPill = catPill

            local mistake = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            mistake:SetPoint("TOPLEFT", 12, -8)
            mistake:SetPoint("RIGHT", catPill, "LEFT", -10, 0)
            mistake:SetJustifyH("LEFT")
            card.mistake = mistake

            local better = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            better:SetPoint("TOPLEFT", mistake, "BOTTOMLEFT", 0, -4)
            better:SetPoint("RIGHT", -12, 0)
            better:SetJustifyH("LEFT")
            card.better = better

            p.mistakeCards[i] = card
        end

        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", content, "TOPLEFT", 10, yOffset)

        card.catPill:SetText("|cFF00FFCC[" .. (item.category or "General") .. "]|r")
        card.mistake:SetText("|cFFFF4444❌ Error Clásico:|r " .. item.mistake)
        card.better:SetText("|cFF00FF00✅ Enfoque WoW Forever:|r " .. item.better)

        card:Show()
        yOffset = yOffset - 62
    end

    content:SetHeight(math.abs(yOffset) + 20)
end

-- =========================================================================
-- PANEL: BANK OVERVIEW & 4 PILARES
-- =========================================================================
function GV:CreateBankOverviewPanel(parent)
    local p = CreateFrame("Frame", nil, parent)
    p:SetAllPoints()

    local sf = CreateFrame("ScrollFrame", "AwakeningGVBankOverviewScroll", p, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 0, 0)
    sf:SetPoint("BOTTOMRIGHT", -26, 0)

    local content = CreateFrame("Frame", nil, sf)
    content:SetSize(sf:GetWidth(), 1)
    sf:SetScrollChild(content)
    p.content = content
    p.cards = {}

    local banner = CreateFrame("Frame", nil, content, "BackdropTemplate")
    banner:SetSize(760, 52)
    banner:SetPoint("TOPLEFT", 10, -5)
    banner:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    banner:SetBackdropColor(unpack(COLORS.headerBg))
    banner:SetBackdropBorderColor(unpack(COLORS.headerBorder))

    local bTitle = banner:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    bTitle:SetPoint("TOPLEFT", 12, -8)
    bTitle:SetText("|cFFFFD100¿Por qué un Bank Alt es Vital en el Lanzamiento de WoW Forever?|r")

    local bSub = banner:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bSub:SetPoint("TOPLEFT", bTitle, "BOTTOMLEFT", 0, -4)
    bSub:SetPoint("RIGHT", -12, 0)
    bSub:SetJustifyH("LEFT")
    bSub:SetText("|cFFDDDDDDDurante las primeras semanas, tu recurso más valioso es el tiempo de leveleo. Un alter de banco centraliza tu economía y protege tu inventario sin frenar tu avance.|r")

    p.banner = banner
    return p
end

function GV:UpdateBankOverview()
    local p = viewerFrame and viewerFrame.panels["bank_overview"]
    if not p then return end

    local guideData = ns.Data.BankAltGuide
    local pillars = guideData and guideData.pillars or {}
    local content = p.content

    local cardW = 372
    local cardH = 96
    local startY = -66

    for i, pil in ipairs(pillars) do
        local card = p.cards[i]
        if not card then
            card = CreateFrame("Frame", nil, content, "BackdropTemplate")
            card:SetSize(cardW, cardH)
            card:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            card:SetBackdropColor(unpack(COLORS.cardBg))
            card:SetBackdropBorderColor(unpack(COLORS.cardBorder))

            local icon = card:CreateTexture(nil, "ARTWORK")
            icon:SetSize(28, 28)
            icon:SetPoint("TOPLEFT", 12, -12)
            card.icon = icon

            local title = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            title:SetPoint("LEFT", icon, "RIGHT", 10, 4)
            title:SetPoint("RIGHT", -10, 0)
            title:SetJustifyH("LEFT")
            card.title = title

            local desc = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            desc:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, -8)
            desc:SetPoint("BOTTOMRIGHT", -12, 10)
            desc:SetJustifyH("LEFT")
            desc:SetWordWrap(true)
            desc:SetSpacing(2)
            card.desc = desc

            p.cards[i] = card
        end

        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", content, "TOPLEFT", 10 + col * (cardW + 16), startY - row * (cardH + 12))

        card.icon:SetTexture(pil.icon or "Interface\\Icons\\inv_misc_bag_08")
        card.title:SetText(string.format("|cFF%s%s|r", pil.color or "FFD43B", pil.title))
        card.desc:SetText(pil.desc or "")
        card:Show()
    end

    if not p.goldRuleCard then
        local gr = CreateFrame("Frame", nil, content, "BackdropTemplate")
        gr:SetSize(760, 68)
        gr:SetPoint("TOPLEFT", content, "TOPLEFT", 10, startY - 2 * (cardH + 12) - 8)
        gr:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        gr:SetBackdropColor(0.18, 0.14, 0.05, 0.95)
        gr:SetBackdropBorderColor(1.0, 0.82, 0.0, 1)

        local grTitle = gr:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        grTitle:SetPoint("TOPLEFT", 14, -10)
        grTitle:SetText("|cFFFFD100Regla de Oro del Lanzamiento: Correo Preventivo Instantáneo|r")

        local grDesc = gr:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        grDesc:SetPoint("TOPLEFT", grTitle, "BOTTOMLEFT", 0, -6)
        grDesc:SetPoint("RIGHT", -14, 0)
        grDesc:SetJustifyH("LEFT")
        grDesc:SetText("|cFFFFFFFFEn WoW Forever, el correo entre personajes de tu cuenta no tiene tiempo de espera (0 minutos). Envía menas, hierbas y BoEs en cualquier buzón rural de pueblo para mantener 30+ casillas libres en tus bolsas de leveleo en todo momento.|r")

        p.goldRuleCard = gr
    end

    content:SetHeight(math.abs(startY - 2 * (cardH + 12) - 8) + 80)
end

-- =========================================================================
-- PANEL: BANK RULES (7 REGLAS DE ORO)
-- =========================================================================
function GV:CreateBankRulesPanel(parent)
    local p = CreateFrame("Frame", nil, parent)
    p:SetAllPoints()

    local sf = CreateFrame("ScrollFrame", "AwakeningGVBankRulesScroll", p, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 0, 0)
    sf:SetPoint("BOTTOMRIGHT", -26, 0)

    local content = CreateFrame("Frame", nil, sf)
    content:SetSize(sf:GetWidth(), 1)
    sf:SetScrollChild(content)
    p.content = content
    p.ruleCards = {}

    local banner = CreateFrame("Frame", nil, content, "BackdropTemplate")
    banner:SetSize(760, 48)
    banner:SetPoint("TOPLEFT", 10, -5)
    banner:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    banner:SetBackdropColor(unpack(COLORS.headerBg))
    banner:SetBackdropBorderColor(unpack(COLORS.headerBorder))

    local bTitle = banner:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    bTitle:SetPoint("TOPLEFT", 12, -8)
    bTitle:SetText("|cFFFFD1007 Reglas de Oro para la Gestión Eficiente de un Bank Alt|r")

    local bSub = banner:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bSub:SetPoint("TOPLEFT", bTitle, "BOTTOMLEFT", 0, -4)
    bSub:SetPoint("RIGHT", -12, 0)
    bSub:SetJustifyH("LEFT")
    bSub:SetText("|cFFDDDDDDEstrategias probadas de LootWoW para maximizar oro y eliminar distracciones mientras leveas.|r")

    p.banner = banner
    return p
end

function GV:UpdateBankRules()
    local p = viewerFrame and viewerFrame.panels["bank_rules"]
    if not p then return end

    local guideData = ns.Data.BankAltGuide
    local rules = guideData and guideData.rules or {}
    local content = p.content

    local yOffset = -62
    for i, r in ipairs(rules) do
        local card = p.ruleCards[i]
        if not card then
            card = CreateFrame("Frame", nil, content, "BackdropTemplate")
            card:SetSize(760, 64)
            card:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            card:SetBackdropColor(unpack(COLORS.cardBg))
            card:SetBackdropBorderColor(unpack(COLORS.cardBorder))

            local numBadge = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            numBadge:SetPoint("TOPLEFT", 12, -10)
            card.numBadge = numBadge

            local tag = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            tag:SetPoint("TOPRIGHT", -12, -10)
            card.tag = tag

            local title = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            title:SetPoint("LEFT", numBadge, "RIGHT", 8, 0)
            title:SetPoint("RIGHT", tag, "LEFT", -10, 0)
            title:SetJustifyH("LEFT")
            card.title = title

            local desc = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            desc:SetPoint("TOPLEFT", 12, -32)
            desc:SetPoint("BOTTOMRIGHT", -12, 8)
            desc:SetJustifyH("LEFT")
            desc:SetWordWrap(true)
            desc:SetSpacing(2)
            card.desc = desc

            p.ruleCards[i] = card
        end

        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", content, "TOPLEFT", 10, yOffset)

        card.numBadge:SetText(string.format("|cFFFFD100%d.|r", r.num or i))
        card.tag:SetText(string.format("|cFF%s[%s]|r", r.tagColor or "48C5C5", r.tag or "Estrategia"))
        card.title:SetText(r.title or "")
        card.desc:SetText(r.desc or "")

        card:Show()
        yOffset = yOffset - 72
    end

    content:SetHeight(math.abs(yOffset) + 20)
end

-- =========================================================================
-- PANEL: BANK MATRIX (MATRIZ DE DECISIONES)
-- =========================================================================
function GV:CreateBankMatrixPanel(parent)
    local p = CreateFrame("Frame", nil, parent)
    p:SetAllPoints()

    local sf = CreateFrame("ScrollFrame", "AwakeningGVBankMatrixScroll", p, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 0, 0)
    sf:SetPoint("BOTTOMRIGHT", -26, 0)

    local content = CreateFrame("Frame", nil, sf)
    content:SetSize(sf:GetWidth(), 1)
    sf:SetScrollChild(content)
    p.content = content
    p.matrixCards = {}

    local banner = CreateFrame("Frame", nil, content, "BackdropTemplate")
    banner:SetSize(760, 48)
    banner:SetPoint("TOPLEFT", 10, -5)
    banner:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    banner:SetBackdropColor(unpack(COLORS.headerBg))
    banner:SetBackdropBorderColor(unpack(COLORS.headerBorder))

    local bTitle = banner:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    bTitle:SetPoint("TOPLEFT", 12, -8)
    bTitle:SetText("|cFFFFD100Matriz de Decisiones de Inventario: Primera Semana|r")

    local bSub = banner:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bSub:SetPoint("TOPLEFT", bTitle, "BOTTOMLEFT", 0, -4)
    bSub:SetPoint("RIGHT", -12, 0)
    bSub:SetJustifyH("LEFT")
    bSub:SetText("|cFFDDDDDDCriterios rápidos para saber qué almacenar, qué vender a PNJ y qué guardar para especulación.|r")

    local thFrame = CreateFrame("Frame", nil, content, "BackdropTemplate")
    thFrame:SetSize(760, 22)
    thFrame:SetPoint("TOPLEFT", banner, "BOTTOMLEFT", 0, -6)
    thFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    thFrame:SetBackdropColor(0.04, 0.04, 0.06, 0.9)
    thFrame:SetBackdropBorderColor(0.4, 0.35, 0.2, 0.8)

    local th1 = thFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    th1:SetPoint("LEFT", 12, 0)
    th1:SetWidth(180)
    th1:SetJustifyH("LEFT")
    th1:SetText("|cFFFFD100Tipo de Objeto|r")

    local th2 = thFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    th2:SetPoint("LEFT", th1, "RIGHT", 10, 0)
    th2:SetWidth(200)
    th2:SetJustifyH("LEFT")
    th2:SetText("|cFF00FFCCAcción Recomendada|r")

    local th3 = thFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    th3:SetPoint("LEFT", th2, "RIGHT", 10, 0)
    th3:SetPoint("RIGHT", -12, 0)
    th3:SetJustifyH("LEFT")
    th3:SetText("|cFFFFFFFFRazón Estratégica|r")

    p.banner = banner
    p.thFrame = thFrame
    return p
end

function GV:UpdateBankMatrix()
    local p = viewerFrame and viewerFrame.panels["bank_matrix"]
    if not p then return end

    local guideData = ns.Data.BankAltGuide
    local items = guideData and guideData.inventoryMatrix or {}
    local content = p.content

    local yOffset = -82
    for i, item in ipairs(items) do
        local card = p.matrixCards[i]
        if not card then
            card = CreateFrame("Frame", nil, content, "BackdropTemplate")
            card:SetSize(760, 52)
            card:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            card:SetBackdropColor(unpack(COLORS.cardBg))
            card:SetBackdropBorderColor(unpack(COLORS.cardBorder))

            local icon = card:CreateTexture(nil, "ARTWORK")
            icon:SetSize(22, 22)
            icon:SetPoint("LEFT", 12, 0)
            card.icon = icon

            local tType = card:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            tType:SetPoint("LEFT", icon, "RIGHT", 8, 0)
            tType:SetWidth(150)
            tType:SetJustifyH("LEFT")
            card.tType = tType

            local tAction = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            tAction:SetPoint("LEFT", tType, "RIGHT", 10, 0)
            tAction:SetWidth(200)
            tAction:SetJustifyH("LEFT")
            card.tAction = tAction

            local tReason = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            tReason:SetPoint("LEFT", tAction, "RIGHT", 10, 0)
            tReason:SetPoint("RIGHT", -12, 0)
            tReason:SetJustifyH("LEFT")
            tReason:SetWordWrap(true)
            card.tReason = tReason

            p.matrixCards[i] = card
        end

        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", content, "TOPLEFT", 10, yOffset)

        card.icon:SetTexture(item.icon or "Interface\\Icons\\inv_misc_bag_08")
        card.tType:SetText(string.format("|cFF%s%s|r", item.color or "FFD43B", item.itemType))
        card.tAction:SetText("|cFF00FFCC" .. item.action .. "|r")
        card.tReason:SetText("|cFFCCCCCC" .. item.reason .. "|r")

        card:Show()
        yOffset = yOffset - 58
    end

    content:SetHeight(math.abs(yOffset) + 20)
end

-- =========================================================================
-- PANEL: BANK FAQ (PREGUNTAS FRECUENTES)
-- =========================================================================
function GV:CreateBankFAQPanel(parent)
    local p = CreateFrame("Frame", nil, parent)
    p:SetAllPoints()

    local sf = CreateFrame("ScrollFrame", "AwakeningGVBankFAQScroll", p, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 0, 0)
    sf:SetPoint("BOTTOMRIGHT", -26, 0)

    local content = CreateFrame("Frame", nil, sf)
    content:SetSize(sf:GetWidth(), 1)
    sf:SetScrollChild(content)
    p.content = content
    p.faqCards = {}

    local banner = CreateFrame("Frame", nil, content, "BackdropTemplate")
    banner:SetSize(760, 48)
    banner:SetPoint("TOPLEFT", 10, -5)
    banner:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    banner:SetBackdropColor(unpack(COLORS.headerBg))
    banner:SetBackdropBorderColor(unpack(COLORS.headerBorder))

    local bTitle = banner:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    bTitle:SetPoint("TOPLEFT", 12, -8)
    bTitle:SetText("|cFFFFD100Preguntas Frecuentes sobre Economía & Bank Alts|r")

    local bSub = banner:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bSub:SetPoint("TOPLEFT", bTitle, "BOTTOMLEFT", 0, -4)
    bSub:SetPoint("RIGHT", -12, 0)
    bSub:SetJustifyH("LEFT")
    bSub:SetText("|cFFDDDDDDRespuestas rápidas a las dudas más comunes sobre razas, capitales y correo en WoW Forever.|r")

    p.banner = banner
    return p
end

function GV:UpdateBankFAQ()
    local p = viewerFrame and viewerFrame.panels["bank_faq"]
    if not p then return end

    local guideData = ns.Data.BankAltGuide
    local faqs = guideData and guideData.faq or {}
    local content = p.content

    local yOffset = -62
    for i, item in ipairs(faqs) do
        local card = p.faqCards[i]
        if not card then
            card = CreateFrame("Frame", nil, content, "BackdropTemplate")
            card:SetSize(760, 68)
            card:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            card:SetBackdropColor(unpack(COLORS.cardBg))
            card:SetBackdropBorderColor(unpack(COLORS.cardBorder))

            local qText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            qText:SetPoint("TOPLEFT", 14, -10)
            qText:SetPoint("RIGHT", -14, 0)
            qText:SetJustifyH("LEFT")
            card.qText = qText

            local aText = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            aText:SetPoint("TOPLEFT", qText, "BOTTOMLEFT", 0, -6)
            aText:SetPoint("BOTTOMRIGHT", -14, 8)
            aText:SetJustifyH("LEFT")
            aText:SetWordWrap(true)
            aText:SetSpacing(2)
            card.aText = aText

            p.faqCards[i] = card
        end

        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", content, "TOPLEFT", 10, yOffset)

        card.qText:SetText(string.format("|cFF%s[?] %s|r", item.color or "48C5C5", item.q))
        card.aText:SetText("|cFFFFFFFF" .. item.a .. "|r")

        card:Show()
        yOffset = yOffset - 76
    end

    content:SetHeight(math.abs(yOffset) + 20)
end

-- =========================================================================
-- API PÚBLICA DE CONTROL
-- =========================================================================
function GV:Open(guideKey)
    self:Init()
    currentGuideKey = guideKey or "excavation_site"
    local guide = ns.Data.Secrets and ns.Data.Secrets[currentGuideKey]
    local isBankAlt = (currentGuideKey == "bank_alt_guide")
    local isLegacy = (currentGuideKey == "legacy_talents_guide")
    local isArticle = (currentGuideKey == "beginners_guide") or (guide and (guide.isArticle or guide.category == "Consejos") and not isBankAlt and not isLegacy)

    self:SetupTabsForGuide(currentGuideKey)

    if guide and viewerFrame then
        viewerFrame.titleText:SetText(string.format("|cFFFFD100%s|r", guide.title:upper()))
        if isLegacy then
            viewerFrame.subtitleText:SetText("|cFFCCAA66PROGRESIÓN DE CUENTA · LAS 5 MEJORES BUILDS DEL META · METHOD.GG|r")
        elseif isBankAlt then
            viewerFrame.subtitleText:SetText("|cFFCCAA66ECONOMÍA DE LANZAMIENTO · OPTIMIZACIÓN DE INVENTARIO Y SUBASTA · NIVEL 1-60|r")
        elseif isArticle then
            viewerFrame.subtitleText:SetText("|cFFCCAA66GUÍA ESENCIAL PARA JUGADORES NUEVOS Y VETERANOS · WOW FOREVER|r")
        else
            viewerFrame.subtitleText:SetText(string.format("|cFFCCAA66GUÍA OFICIAL DE MAZMORRA · %s · %s|r", (guide.level or "NIVEL 24-30"):upper(), (guide.zone or "LOS HUMEDALES"):upper()))
        end
    end
    viewerFrame:Show()
    if isLegacy then
        self:SwitchTab("legacy_overview")
    elseif isBankAlt then
        self:SwitchTab("bank_overview")
    elseif isArticle then
        self:SwitchTab("differences")
    else
        self:SwitchTab("overview")
    end
end

function GV:Toggle(guideKey)
    if viewerFrame and viewerFrame:IsShown() then
        viewerFrame:Hide()
    else
        self:Open(guideKey)
    end
end

-- =========================================================================
-- PANELES DE PUNTOS Y TALENTOS LEGACY (METHOD.GG)
-- =========================================================================

-- -------------------------------------------------------------------------
-- PANEL 1: FUNDAMENTOS Y 3 ÁRBOLES
-- -------------------------------------------------------------------------
function GV:CreateLegacyOverviewPanel(parent)
    local p = CreateFrame("Frame", nil, parent)
    p:SetAllPoints()

    local sf = CreateFrame("ScrollFrame", "AwakeningGVLegacyOverviewScroll", p, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 0, 0)
    sf:SetPoint("BOTTOMRIGHT", -26, 0)

    local content = CreateFrame("Frame", nil, sf)
    content:SetSize(sf:GetWidth(), 1)
    sf:SetScrollChild(content)
    p.content = content
    p.cards = {}

    local banner = CreateFrame("Frame", nil, content, "BackdropTemplate")
    banner:SetSize(760, 48)
    banner:SetPoint("TOPLEFT", 10, -5)
    banner:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    banner:SetBackdropColor(unpack(COLORS.headerBg))
    banner:SetBackdropBorderColor(unpack(COLORS.headerBorder))

    local bTitle = banner:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    bTitle:SetPoint("TOPLEFT", 12, -8)
    bTitle:SetText("|cFFFFD100Fundamentos del Sistema Legacy en WoW Forever|r")

    local bSub = banner:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bSub:SetPoint("TOPLEFT", bTitle, "BOTTOMLEFT", 0, -4)
    bSub:SetPoint("RIGHT", -12, 0)
    bSub:SetJustifyH("LEFT")
    bSub:SetText("|cFFDDDDDDFuente: Method.gg · Progresión de cuenta, límite de 16 puntos y los 3 árboles de talentos.|r")

    p.banner = banner
    return p
end

function GV:UpdateLegacyOverview()
    local p = viewerFrame and viewerFrame.panels["legacy_overview"]
    if not p then return end

    local guideData = ns.Data.LegacyTalentsGuide
    local pillars = guideData and guideData.pillars or {}
    local content = p.content

    local cardW = 372
    local cardH = 96
    local startY = -66

    for i, pil in ipairs(pillars) do
        local card = p.cards[i]
        if not card then
            card = CreateFrame("Frame", nil, content, "BackdropTemplate")
            card:SetSize(cardW, cardH)
            card:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            card:SetBackdropColor(unpack(COLORS.cardBg))
            card:SetBackdropBorderColor(unpack(COLORS.cardBorder))

            local icon = card:CreateTexture(nil, "ARTWORK")
            icon:SetSize(28, 28)
            icon:SetPoint("TOPLEFT", 12, -12)
            card.icon = icon

            local title = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            title:SetPoint("LEFT", icon, "RIGHT", 10, 4)
            title:SetPoint("RIGHT", -10, 0)
            title:SetJustifyH("LEFT")
            card.title = title

            local desc = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            desc:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, -8)
            desc:SetPoint("BOTTOMRIGHT", -12, 10)
            desc:SetJustifyH("LEFT")
            desc:SetWordWrap(true)
            desc:SetSpacing(2)
            card.desc = desc

            p.cards[i] = card
        end

        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", content, "TOPLEFT", 10 + col * (cardW + 16), startY - row * (cardH + 12))

        card.icon:SetTexture(pil.icon or "Interface\\Icons\\inv_misc_book_09")
        card.title:SetText(string.format("|cFF%s%s|r", pil.color or "FFD43B", pil.title))
        card.desc:SetText(pil.desc or "")
        card:Show()
    end

    if not p.respecCard then
        local rc = CreateFrame("Frame", nil, content, "BackdropTemplate")
        rc:SetSize(760, 68)
        rc:SetPoint("TOPLEFT", content, "TOPLEFT", 10, startY - 2 * (cardH + 12) - 8)
        rc:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        rc:SetBackdropColor(0.18, 0.14, 0.05, 0.95)
        rc:SetBackdropBorderColor(1.0, 0.82, 0.0, 1)

        local rcTitle = rc:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        rcTitle:SetPoint("TOPLEFT", 14, -10)
        rcTitle:SetText("|cFFFFD100Regla Clave del Meta: Los Puntos se Asignan por Personaje|r")

        local rcDesc = rc:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        rcDesc:SetPoint("TOPLEFT", rcTitle, "BOTTOMLEFT", 0, -6)
        rcDesc:SetPoint("RIGHT", -14, 0)
        rcDesc:SetJustifyH("LEFT")
        rcDesc:SetText("|cFFFFFFFFAunque los puntos se desbloquean a nivel de cuenta, cada personaje los distribuye a conveniencia. Puedes tener un alter enfocado en recolección (+100% materiales raros) y tu personaje principal en reducción de reparación y daño de banda sin conflicto.|r")

        p.respecCard = rc
    end

    content:SetHeight(math.abs(startY - 2 * (cardH + 12) - 8) + 80)
end

-- -------------------------------------------------------------------------
-- PANEL 2: EL GRAN DEBATE (THRILL VS TALENTED)
-- -------------------------------------------------------------------------
function GV:CreateLegacyDebatePanel(parent)
    local p = CreateFrame("Frame", nil, parent)
    p:SetAllPoints()

    local sf = CreateFrame("ScrollFrame", "AwakeningGVLegacyDebateScroll", p, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 0, 0)
    sf:SetPoint("BOTTOMRIGHT", -26, 0)

    local content = CreateFrame("Frame", nil, sf)
    content:SetSize(sf:GetWidth(), 1)
    sf:SetScrollChild(content)
    p.content = content
    p.cards = {}

    local banner = CreateFrame("Frame", nil, content, "BackdropTemplate")
    banner:SetSize(760, 48)
    banner:SetPoint("TOPLEFT", 10, -5)
    banner:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    banner:SetBackdropColor(unpack(COLORS.headerBg))
    banner:SetBackdropBorderColor(unpack(COLORS.headerBorder))

    local bTitle = banner:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    bTitle:SetPoint("TOPLEFT", 12, -8)
    bTitle:SetText("|cFFFFD100El Gran Dilema: Thrill of Adventure vs Talented|r")

    local bSub = banner:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bSub:SetPoint("TOPLEFT", bTitle, "BOTTOMLEFT", 0, -4)
    bSub:SetPoint("RIGHT", -12, 0)
    bSub:SetJustifyH("LEFT")
    bSub:SetText("|cFFDDDDDDAnálisis comparativo de los dos talentos de leveleo más populares de WoW Forever.|r")

    p.banner = banner
    return p
end

function GV:UpdateLegacyDebate()
    local p = viewerFrame and viewerFrame.panels["legacy_debate"]
    if not p then return end

    local guideData = ns.Data.LegacyTalentsGuide
    local debate = guideData and guideData.debate
    local talents = debate and debate.talents or {}
    local content = p.content

    local cardW = 372
    local cardH = 180
    local startY = -66

    for i, tal in ipairs(talents) do
        local card = p.cards[i]
        if not card then
            card = CreateFrame("Frame", nil, content, "BackdropTemplate")
            card:SetSize(cardW, cardH)
            card:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            card:SetBackdropColor(unpack(COLORS.cardBg))
            card:SetBackdropBorderColor(unpack(COLORS.cardBorder))

            local icon = card:CreateTexture(nil, "ARTWORK")
            icon:SetSize(32, 32)
            icon:SetPoint("TOPLEFT", 14, -12)
            card.icon = icon

            local title = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            title:SetPoint("LEFT", icon, "RIGHT", 10, 4)
            title:SetPoint("RIGHT", -10, 0)
            title:SetJustifyH("LEFT")
            card.title = title

            local sub = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            sub:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, -6)
            sub:SetPoint("RIGHT", -14, 0)
            sub:SetJustifyH("LEFT")
            card.sub = sub

            local eff = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            eff:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", 0, -6)
            eff:SetPoint("RIGHT", -14, 0)
            eff:SetJustifyH("LEFT")
            eff:SetWordWrap(true)
            eff:SetSpacing(2)
            card.eff = eff

            local verd = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            verd:SetPoint("TOPLEFT", eff, "BOTTOMLEFT", 0, -6)
            verd:SetPoint("BOTTOMRIGHT", -14, 10)
            verd:SetJustifyH("LEFT")
            verd:SetWordWrap(true)
            verd:SetSpacing(2)
            card.verd = verd

            p.cards[i] = card
        end

        local col = (i - 1) % 2
        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", content, "TOPLEFT", 10 + col * (cardW + 16), startY)

        card.icon:SetTexture(tal.icon or "Interface\\Icons\\inv_misc_questionmark")
        card.title:SetText(string.format("|cFF%s%s|r", tal.color or "FFD43B", tal.name))
        card.sub:SetText(string.format("|cFF88DDFF%s · %s|r", tal.tree or "Aventura", tal.ranks or "5 Rangos"))
        card.eff:SetText(string.format("|cFFFFFFFFEfecto:|r %s", tal.effect or ""))
        card.verd:SetText(string.format("|cFFFFD100Veredicto:|r %s", tal.verdict or ""))
        card:Show()
    end

    if not p.verdictCard then
        local vc = CreateFrame("Frame", nil, content, "BackdropTemplate")
        vc:SetSize(760, 78)
        vc:SetPoint("TOPLEFT", content, "TOPLEFT", 10, startY - cardH - 12)
        vc:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        vc:SetBackdropColor(0.18, 0.14, 0.05, 0.95)
        vc:SetBackdropBorderColor(1.0, 0.82, 0.0, 1)

        local vcTitle = vc:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        vcTitle:SetPoint("TOPLEFT", 14, -10)
        vcTitle:SetText("|cFFFFD100Veredicto Final de Method.gg|r")

        local vcDesc = vc:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        vcDesc:SetPoint("TOPLEFT", vcTitle, "BOTTOMLEFT", 0, -6)
        vcDesc:SetPoint("RIGHT", -14, 0)
        vcDesc:SetJustifyH("LEFT")
        vcDesc:SetWordWrap(true)
        vcDesc:SetSpacing(2)
        vcDesc:SetText(string.format("|cFFFFFFFF%s|r", debate and debate.methodVerdict or ""))

        p.verdictCard = vc
    end

    content:SetHeight(math.abs(startY - cardH - 12 - 78) + 40)
end

-- -------------------------------------------------------------------------
-- PANEL 3: LAS 5 BUILDS DEL META METHOD
-- -------------------------------------------------------------------------
function GV:CreateLegacyBuildsPanel(parent)
    local p = CreateFrame("Frame", nil, parent)
    p:SetAllPoints()

    local sf = CreateFrame("ScrollFrame", "AwakeningGVLegacyBuildsScroll", p, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 0, 0)
    sf:SetPoint("BOTTOMRIGHT", -26, 0)

    local content = CreateFrame("Frame", nil, sf)
    content:SetSize(sf:GetWidth(), 1)
    sf:SetScrollChild(content)
    p.content = content
    p.buildCards = {}

    local banner = CreateFrame("Frame", nil, content, "BackdropTemplate")
    banner:SetSize(760, 48)
    banner:SetPoint("TOPLEFT", 10, -5)
    banner:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    banner:SetBackdropColor(unpack(COLORS.headerBg))
    banner:SetBackdropBorderColor(unpack(COLORS.headerBorder))

    local bTitle = banner:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    bTitle:SetPoint("TOPLEFT", 12, -8)
    bTitle:SetText("|cFFFFD100Las 5 Builds del Meta Oficial de Method.gg (16 Puntos)|r")

    local bSub = banner:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bSub:SetPoint("TOPLEFT", bTitle, "BOTTOMLEFT", 0, -4)
    bSub:SetPoint("RIGHT", -12, 0)
    bSub:SetJustifyH("LEFT")
    bSub:SetText("|cFFDDDDDDDistribuciones exactas de 16 Puntos Legacy según el rol y meta de tu personaje.|r")

    p.banner = banner
    return p
end

function GV:UpdateLegacyBuilds()
    local p = viewerFrame and viewerFrame.panels["legacy_builds"]
    if not p then return end

    local guideData = ns.Data.LegacyTalentsGuide
    local builds = guideData and guideData.builds or {}
    local content = p.content

    local yOffset = -62
    for i, b in ipairs(builds) do
        local card = p.buildCards[i]
        if not card then
            card = CreateFrame("Frame", nil, content, "BackdropTemplate")
            card:SetSize(760, 94)
            card:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            card:SetBackdropColor(unpack(COLORS.cardBg))
            card:SetBackdropBorderColor(unpack(COLORS.cardBorder))

            local icon = card:CreateTexture(nil, "ARTWORK")
            icon:SetSize(28, 28)
            icon:SetPoint("TOPLEFT", 14, -10)
            card.icon = icon

            local title = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            title:SetPoint("LEFT", icon, "RIGHT", 10, 0)
            title:SetPoint("RIGHT", -120, 0)
            title:SetJustifyH("LEFT")
            card.title = title

            local dist = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            dist:SetPoint("TOPRIGHT", -14, -12)
            dist:SetJustifyH("RIGHT")
            card.dist = dist

            local sub = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            sub:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, -4)
            sub:SetPoint("RIGHT", -14, 0)
            sub:SetJustifyH("LEFT")
            card.sub = sub

            local keyT = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            keyT:SetPoint("TOPLEFT", sub, "BOTTOMLEFT", 0, -3)
            keyT:SetPoint("RIGHT", -14, 0)
            keyT:SetJustifyH("LEFT")
            card.keyT = keyT

            local desc = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            desc:SetPoint("TOPLEFT", keyT, "BOTTOMLEFT", 0, -3)
            desc:SetPoint("BOTTOMRIGHT", -14, 6)
            desc:SetJustifyH("LEFT")
            desc:SetWordWrap(true)
            desc:SetSpacing(1)
            card.desc = desc

            p.buildCards[i] = card
        end

        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", content, "TOPLEFT", 10, yOffset)

        card.icon:SetTexture(b.icon or "Interface\\Icons\\inv_misc_questionmark")
        card.title:SetText(string.format("|cFF%s%s|r", b.color or "FFD43B", b.title))
        card.dist:SetText(string.format("|cFF00FFCC%s|r", b.pointsDistribution or ""))
        card.sub:SetText(string.format("|cFF88DDFF%s|r", b.subtitle or ""))
        card.keyT:SetText(string.format("|cFFFFD100Talentos Clave:|r %s", b.keyTalents or ""))
        card.desc:SetText(string.format("|cFFFFFFFF%s|r %s", b.desc or "", (b.notes and "|cFFBBBBBB(" .. b.notes .. ")|r") or ""))

        card:Show()
        yOffset = yOffset - 102
    end

    content:SetHeight(math.abs(yOffset) + 20)
end

-- -------------------------------------------------------------------------
-- PANEL 4: CATÁLOGO DE TALENTOS CLAVE
-- -------------------------------------------------------------------------
function GV:CreateLegacyTalentsPanel(parent)
    local p = CreateFrame("Frame", nil, parent)
    p:SetAllPoints()

    local sf = CreateFrame("ScrollFrame", "AwakeningGVLegacyTalentsScroll", p, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 0, 0)
    sf:SetPoint("BOTTOMRIGHT", -26, 0)

    local content = CreateFrame("Frame", nil, sf)
    content:SetSize(sf:GetWidth(), 1)
    sf:SetScrollChild(content)
    p.content = content
    p.talentCards = {}

    local banner = CreateFrame("Frame", nil, content, "BackdropTemplate")
    banner:SetSize(760, 48)
    banner:SetPoint("TOPLEFT", 10, -5)
    banner:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    banner:SetBackdropColor(unpack(COLORS.headerBg))
    banner:SetBackdropBorderColor(unpack(COLORS.headerBorder))

    local bTitle = banner:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    bTitle:SetPoint("TOPLEFT", 12, -8)
    bTitle:SetText("|cFFFFD100Catálogo de Talentos Legacy Clave Explicados|r")

    local bSub = banner:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bSub:SetPoint("TOPLEFT", bTitle, "BOTTOMLEFT", 0, -4)
    bSub:SetPoint("RIGHT", -12, 0)
    bSub:SetJustifyH("LEFT")
    bSub:SetText("|cFFDDDDDDCostes de puntos, árbol de procedencia y efectos de los talentos más influyentes.|r")

    p.banner = banner
    return p
end

function GV:UpdateLegacyTalents()
    local p = viewerFrame and viewerFrame.panels["legacy_talents"]
    if not p then return end

    local guideData = ns.Data.LegacyTalentsGuide
    local talents = guideData and guideData.talentsList or {}
    local content = p.content

    local cardW = 372
    local cardH = 80
    local startY = -66

    for i, tal in ipairs(talents) do
        local card = p.talentCards[i]
        if not card then
            card = CreateFrame("Frame", nil, content, "BackdropTemplate")
            card:SetSize(cardW, cardH)
            card:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            card:SetBackdropColor(unpack(COLORS.cardBg))
            card:SetBackdropBorderColor(unpack(COLORS.cardBorder))

            local icon = card:CreateTexture(nil, "ARTWORK")
            icon:SetSize(28, 28)
            icon:SetPoint("TOPLEFT", 12, -10)
            card.icon = icon

            local name = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            name:SetPoint("LEFT", icon, "RIGHT", 10, 4)
            name:SetPoint("RIGHT", -80, 0)
            name:SetJustifyH("LEFT")
            card.name = name

            local cost = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            cost:SetPoint("TOPRIGHT", -12, -10)
            cost:SetJustifyH("RIGHT")
            card.cost = cost

            local tree = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            tree:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, -4)
            tree:SetPoint("RIGHT", -12, 0)
            tree:SetJustifyH("LEFT")
            card.tree = tree

            local desc = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            desc:SetPoint("TOPLEFT", tree, "BOTTOMLEFT", 0, -3)
            desc:SetPoint("BOTTOMRIGHT", -12, 6)
            desc:SetJustifyH("LEFT")
            desc:SetWordWrap(true)
            desc:SetSpacing(1)
            card.desc = desc

            p.talentCards[i] = card
        end

        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        card:ClearAllPoints()
        card:SetPoint("TOPLEFT", content, "TOPLEFT", 10 + col * (cardW + 16), startY - row * (cardH + 10))

        card.icon:SetTexture(tal.icon or "Interface\\Icons\\inv_misc_questionmark")
        card.name:SetText(string.format("|cFF%s%s|r", tal.color or "FFD43B", tal.name))
        card.cost:SetText(string.format("|cFFFFD100%s|r", tal.cost or ""))
        card.tree:SetText(string.format("|cFF88DDFFÁrbol: %s|r", tal.tree or "Aventura"))
        card.desc:SetText(string.format("|cFFFFFFFF%s|r", tal.desc or ""))

        card:Show()
    end

    local numRows = math.ceil(#talents / 2)
    content:SetHeight(math.abs(startY - numRows * (cardH + 10)) + 30)
end


