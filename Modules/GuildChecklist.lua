local _, addon = ...

local REQUIRED_GUILD = "Awakening"

-- Estado activo de la interfaz
local currentMainTab = 1 -- 1: Secretos (Free), 2: Farmeo (Free), 3: Hermandad (Guild)
local currentGuildSubTab = 1 -- 1: Raid Prep, 2: Roster interno

-- Consumibles para el Raid Prep
local RAID_CONSUMABLES = {
    { id = 929,   name = "Poción de sanación",      minCount = 5,  icon = "Interface\\Icons\\inv_potion_52" },
    { id = 3385,  name = "Poción de maná menor",    minCount = 5,  icon = "Interface\\Icons\\inv_potion_76" },
    { id = 3825,  name = "Elixir de agilidad",      minCount = 2,  icon = "Interface\\Icons\\inv_potion_93" },
    { id = 858,   name = "Poción de claridad",      minCount = 1,  icon = "Interface\\Icons\\inv_potion_20" },
    { id = 1251,  name = "Carne cocinada (Buff)",   minCount = 10, icon = "Interface\\Icons\\inv_misc_food_15" },
    { id = 14529, name = "Vendas de seda",          minCount = 10, icon = "Interface\\Icons\\inv_misc_bandage_01" }
}

-- 1. Marco Principal centrado en pantalla (idéntico a Olympus)
local mainFrame = CreateFrame("Frame", "AwakeningMainFrame", UIParent, "BackdropTemplate")
mainFrame:SetSize(460, 480)
mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0) -- Perfectamente centrado
mainFrame:SetMovable(true)
mainFrame:EnableMouse(true)
mainFrame:RegisterForDrag("LeftButton")
mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
mainFrame:Hide()

mainFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 24,
    insets = { left = 6, right = 6, top = 6, bottom = 6 }
})

-- Botón Cerrar (X) superior derecha
local closeBtn = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -4, -4)

-- 2. Barra de Título Superior y Escudo Circular
local topBar = CreateFrame("Frame", nil, mainFrame)
topBar:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 12, -10)
topBar:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -36, -10)
topBar:SetHeight(75)

-- Emblema circular en la esquina superior izquierda
local crest = topBar:CreateTexture(nil, "ARTWORK")
crest:SetSize(54, 54)
crest:SetPoint("TOPLEFT", topBar, "TOPLEFT", 4, 0)
crest:SetTexture("Interface\\Icons\\spell_holy_magicalsentry")

-- Título central "Awakening"
local mainTitle = topBar:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
mainTitle:SetPoint("TOP", topBar, "TOP", 20, -2)
mainTitle:SetText("|cFFFFD100Awakening|r")

-- Subtítulo métricas estilo Olympus: "3,592 soldiers / 332 online..."
local subMetric = topBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
subMetric:SetPoint("TOP", mainTitle, "BOTTOM", 0, -2)
subMetric:SetText("|cFFFFCC00Guías & Comunidad Hispana|r")

local subStatus = topBar:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
subStatus:SetPoint("TOP", subMetric, "BOTTOM", 0, -2)
subStatus:SetText("WoW Forever Beta · Updated now · Servidor Activo")

-- 3. Área Central (Contenedor de Tablas con bordes y fondo oscuro)
local tableContainer = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
tableContainer:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 14, -86)
tableContainer:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -14, 52)
tableContainer:SetBackdrop({
    bgFile = "Interface\\FrameGeneral\\UI-Background-Marble",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 12,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
tableContainer:SetBackdropColor(0.02, 0.02, 0.04, 0.95)

-- Cabeceras de columna estilo WoW
local colHeader1 = CreateFrame("Button", nil, tableContainer, "ColumnHeaderTemplate")
colHeader1:SetPoint("TOPLEFT", tableContainer, "TOPLEFT", 2, -2)
colHeader1:SetSize(210, 22)
_G[colHeader1:GetName().."Text"]:SetText("Nombre / Misión")

local colHeader2 = CreateFrame("Button", nil, tableContainer, "ColumnHeaderTemplate")
colHeader2:SetPoint("LEFT", colHeader1, "RIGHT", -2, 0)
colHeader2:SetSize(110, 22)
_G[colHeader2:GetName().."Text"]:SetText("Zona / Tipo")

local colHeader3 = CreateFrame("Button", nil, tableContainer, "ColumnHeaderTemplate")
colHeader3:SetPoint("LEFT", colHeader2, "RIGHT", -2, 0)
colHeader3:SetSize(106, 22)
_G[colHeader3:GetName().."Text"]:SetText("Estado / Acción")

-- Vistas Intercambiables dentro del Contenedor Central
local viewSecrets = CreateFrame("Frame", nil, tableContainer)
viewSecrets:SetPoint("TOPLEFT", tableContainer, "TOPLEFT", 4, -26)
viewSecrets:SetPoint("BOTTOMRIGHT", tableContainer, "BOTTOMRIGHT", -4, 4)

local viewFarming = CreateFrame("Frame", nil, tableContainer)
viewFarming:SetPoint("TOPLEFT", tableContainer, "TOPLEFT", 4, -26)
viewFarming:SetPoint("BOTTOMRIGHT", tableContainer, "BOTTOMRIGHT", -4, 4)
viewFarming:Hide()

local viewGuild = CreateFrame("Frame", nil, tableContainer)
viewGuild:SetPoint("TOPLEFT", tableContainer, "TOPLEFT", 4, -26)
viewGuild:SetPoint("BOTTOMRIGHT", tableContainer, "BOTTOMRIGHT", -4, 4)
viewGuild:Hide()

-- 4. Pestaña Gratuita 1: Lista de Rutas de Secretos
local secretRows = {}
local function BuildSecretsList()
    local yOffset = 0
    for key, guide in pairs(AwakeningData.Guides or {}) do
        local row = CreateFrame("Frame", nil, viewSecrets, "BackdropTemplate")
        row:SetSize(424, 34)
        row:SetPoint("TOPLEFT", viewSecrets, "TOPLEFT", 0, yOffset)
        row:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 8, edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        row:SetBackdropColor(0.08, 0.08, 0.1, 0.7)

        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(24, 24)
        icon:SetPoint("LEFT", row, "LEFT", 6, 0)
        icon:SetTexture("Interface\\Icons\\inv_misc_bag_07")

        local title = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        title:SetPoint("LEFT", icon, "RIGHT", 8, 0)
        title:SetText(guide.title)

        local zone = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        zone:SetPoint("LEFT", row, "LEFT", 216, 0)
        zone:SetText("Westfall / Loch Modan")

        local btnLoad = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        btnLoad:SetSize(86, 20)
        btnLoad:SetPoint("RIGHT", row, "RIGHT", -6, 0)
        btnLoad:SetText("Cargar HUD")
        btnLoad:SetScript("OnClick", function()
            if AwakeningHUDFrame then
                AwakeningHUDFrame:Show()
                print("|cFF00FFCC[Awakening]:|r Ruta de " .. guide.title .. " cargada.")
            end
        end)

        yOffset = yOffset - 36
    end
end
BuildSecretsList()

-- 5. Pestaña de Hermandad (Bloqueada vs Miembro)
local guildLockedLayer = CreateFrame("Frame", nil, viewGuild)
guildLockedLayer:SetAllPoints(viewGuild)

local lockIcon = guildLockedLayer:CreateTexture(nil, "ARTWORK")
lockIcon:SetSize(48, 48)
lockIcon:SetPoint("CENTER", guildLockedLayer, "CENTER", 0, 40)
lockIcon:SetTexture("Interface\\Icons\\inv_misc_key_03")

local lockText = guildLockedLayer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
lockText:SetPoint("TOP", lockIcon, "BOTTOM", 0, -12)
lockText:SetWidth(320)
lockText:SetText("|cFFFF4444Exclusivo Hermandad Awakening|r\n\nNo perteneces a la hermandad. Los módulos de Raid Prep, inspección y eventos internos se desbloquean al ingresar a |cFF00FFCC<Awakening>|r.")

-- Sub-Panel de Hermandad (Activo para miembros)
local guildActiveContent = CreateFrame("Frame", nil, viewGuild)
guildActiveContent:SetAllPoints(viewGuild)

-- Sub-tabs horizontales internos del Guild
local subTabPrep = CreateFrame("Button", nil, guildActiveContent, "UIPanelButtonTemplate")
subTabPrep:SetSize(110, 22)
subTabPrep:SetPoint("TOPLEFT", guildActiveContent, "TOPLEFT", 6, 22)
subTabPrep:SetText("Raid Prep")

local subTabRoster = CreateFrame("Button", nil, guildActiveContent, "UIPanelButtonTemplate")
subTabRoster:SetPoint("LEFT", subTabPrep, "RIGHT", 4, 0)
subTabRoster:SetSize(110, 22)
subTabRoster:SetText("Roster Interno")

-- Contenedor del Checklist de Consumibles dentro del Guild
local prepRows = {}
local function BuildGuildPrepRows()
    for i, item in ipairs(RAID_CONSUMABLES) do
        local row = CreateFrame("Frame", nil, guildActiveContent, "BackdropTemplate")
        row:SetSize(424, 38)
        row:SetPoint("TOPLEFT", guildActiveContent, "TOPLEFT", 0, -6 - ((i - 1) * 42))
        row:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 8, edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 }
        })
        row:SetBackdropColor(0.08, 0.08, 0.1, 0.7)

        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(28, 28)
        icon:SetPoint("LEFT", row, "LEFT", 8, 0)
        icon:SetTexture(item.icon)

        local name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        name:SetPoint("LEFT", icon, "RIGHT", 10, 0)
        name:SetText(item.name)

        local status = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        status:SetPoint("RIGHT", row, "RIGHT", -12, 0)

        row.itemData = item
        row.status = status
        prepRows[i] = row
    end
end
BuildGuildPrepRows()

local function UpdateGuildPrep()
    for _, row in ipairs(prepRows) do
        local count = GetItemCount(row.itemData.id, false, false) or 0
        if count >= row.itemData.minCount then
            row:SetBackdropBorderColor(0, 1, 0, 0.9)
            row.status:SetText(string.format("|cFF00FF00Listo (%d/%d)|r", count, row.itemData.minCount))
        else
            row:SetBackdropBorderColor(1, 0.1, 0.1, 0.9)
            row.status:SetText(string.format("|cFFFF3333Faltan %d|r", row.itemData.minCount - count))
        end
    end
end

-- 6. Controlador de Cambio de Vistas
local function SwitchMainTab(tabIndex)
    currentMainTab = tabIndex
    viewSecrets:Hide()
    viewFarming:Hide()
    viewGuild:Hide()

    if tabIndex == 1 then
        colHeader1:SetText("Nombre / Misión")
        colHeader2:SetText("Zona / Tipo")
        colHeader3:SetText("Acción")
        viewSecrets:Show()
    elseif tabIndex == 2 then
        colHeader1:SetText("Ruta Farmeo")
        colHeader2:SetText("Nivel / Recurso")
        colHeader3:SetText("Acción")
        viewFarming:Show()
    elseif tabIndex == 3 then
        local guildName = GetGuildInfo("player")
        if guildName ~= REQUIRED_GUILD then
            guildLockedLayer:Show()
            guildActiveContent:Hide()
        else
            guildLockedLayer:Hide()
            guildActiveContent:Show()
            UpdateGuildPrep()
        end
        viewGuild:Show()
    end
end

-- 7. Pestañas Laterales Verticales (Sidebar Olympus)
local sideTabsData = {
    { icon = "Interface\\Icons\\inv_misc_book_09", tooltip = "Rutas de Secretos" },
    { icon = "Interface\\Icons\\inv_misc_map02",    tooltip = "Rutas de Farmeo" },
    { icon = "Interface\\Icons\\achievement_guildperk_massresurrection", tooltip = "Hermandad Awakening (Exclusivo)" }
}

for i, tabData in ipairs(sideTabsData) do
    local tab = CreateFrame("Button", nil, mainFrame)
    tab:SetSize(38, 38)
    tab:SetPoint("TOPLEFT", mainFrame, "TOPRIGHT", -2, -62 - ((i - 1) * 44))

    local icon = tab:CreateTexture(nil, "BACKGROUND")
    icon:SetAllPoints(tab)
    icon:SetTexture(tabData.icon)

    local border = tab:CreateTexture(nil, "OVERLAY")
    border:SetSize(48, 48)
    border:SetPoint("CENTER", tab, "CENTER", 0, 0)
    border:SetTexture("Interface\\Buttons\\UI-Quickslot2")

    tab:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(tabData.tooltip)
        GameTooltip:Show()
    end)
    tab:SetScript("OnLeave", function() GameTooltip:Hide() end)

    tab:SetScript("OnClick", function()
        SwitchMainTab(i)
    end)
end

-- 8. Barra Inferior Estilo Olympus: Botones Copy / Refresh / Report
local btnCopy = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
btnCopy:SetSize(110, 24)
btnCopy:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 18, 14)
btnCopy:SetText("Discord")
btnCopy:SetScript("OnClick", function()
    print("|cFF00FFCC[Awakening]:|r Únete al Discord: https://discord.gg/awakening")
end)

local btnRefresh = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
btnRefresh:SetSize(110, 24)
btnRefresh:SetPoint("LEFT", btnCopy, "RIGHT", 6, 0)
btnRefresh:SetText("Actualizar")
btnRefresh:SetScript("OnClick", function()
    SwitchMainTab(currentMainTab)
end)

local btnBug = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
btnBug:SetSize(110, 24)
btnBug:SetPoint("LEFT", btnRefresh, "RIGHT", 6, 0)
btnBug:SetText("Reportar Bug")

-- Comando /awk abre directamente la ventana principal en el centro
SLASH_AWAKENING1 = "/awakening"
SLASH_AWAKENING2 = "/awk"
SlashCmdList["AWAKENING"] = function()
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
        SwitchMainTab(1)
    end
end

-- Al hacer login, inicializar en pestaña 1
mainFrame:RegisterEvent("PLAYER_LOGIN")
mainFrame:SetScript("OnEvent", function()
    SwitchMainTab(1)
end)