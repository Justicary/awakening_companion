local ADDON, ns = ...
local addon = ns

local MainUI = {}
ns.MainUI = MainUI

local mainFrame = nil
local currentTab = 1
local selectedBiSSlot = "Head"
local selectedBiSBracket = nil
local selectedBiSSpec = nil
local selectedBiSMode = "gear" -- "gear" (default) o "enchants"
local selectedEnchantSpec = nil
local selectedSecretKey = "sleeping_bag"
local selectedFarmingKey = nil
local selectedFarmingProfKey = nil
local selectedFarmingBracket = "auto"
local selectedFarmingItemType = nil
local selectedFarmingItemData = nil
local selectedMember = nil
local selectedTravelFrom = nil -- id de nodo, "__player__" o nil
local selectedTravelTo = nil
local selectedTravelMode = "fastest"
local currentTravelPlan = nil

local views = {}
local viewsByKey = {}
local sideTabs = {}
local bottomButtons = {}
local colHeaderButtons = {}

local TABS_CONFIG = {
    { key = "bis",     icon = "Interface\\Icons\\inv_helmet_06",        tooltip = "Best in Slot (BiS)" },
    { key = "secrets", icon = "Interface\\Icons\\inv_misc_book_09",     tooltip = "Guías & Secretos" },
    { key = "farming", icon = "Interface\\Icons\\inv_pick_02",          tooltip = "Profesiones" },
    { key = "prep",    icon = "Interface\\Icons\\inv_potion_92",        tooltip = "Preparación" },
    { key = "travel",  icon = "Interface\\Icons\\inv_misc_map_01",      tooltip = "Planeador de Viaje" },
    { key = "guild",   icon = "Interface\\AddOns\\AwakeningCompanion\\Media\\Icons\\awakening_crest.tga", tooltip = "Hermandad Awakening (Roster)" },
}

local tabIndexByKey = {}
for idx, tab in ipairs(TABS_CONFIG) do
    tabIndexByKey[tab.key] = idx
end

-- Constantes de geometría HUD Principal
local FRAME_W, FRAME_H = 540, 495
local DETAIL_H = 125

-- =========================================================================
-- FUNCIONES AUXILIARES: ACCESO SEGURO A OBJETOS (PREVENCIÓN DE CRASH 1.15.5+)
-- =========================================================================
local function SafeGetItemInfo(itemID)
    if not itemID or itemID == 0 then return nil end
    if C_Item and C_Item.GetItemInfo then
        local ok, name, link, quality, ilvl, reqLvl, class, subclass, maxStack, equipSlot, texture = pcall(C_Item.GetItemInfo, itemID)
        if ok and name then
            return name, link, quality, texture
        end
    end
    if _G.GetItemInfo then
        local ok, name, link, quality, ilvl, reqLvl, class, subclass, maxStack, equipSlot, texture = pcall(_G.GetItemInfo, itemID)
        if ok and name then
            return name, link, quality, texture
        end
    end
    return nil
end

local function SafeGetItemIcon(itemID)
    if not itemID or itemID == 0 then return "Interface\\Icons\\inv_misc_questionmark" end
    if C_Item and C_Item.GetItemIconByID then
        local ok, icon = pcall(C_Item.GetItemIconByID, itemID)
        if ok and icon then return icon end
    end
    if C_Item and C_Item.GetItemInfoInstant then
        local ok, _, _, _, _, icon = pcall(C_Item.GetItemInfoInstant, itemID)
        if ok and icon then return icon end
    end
    if _G.GetItemIcon then
        local ok, icon = pcall(_G.GetItemIcon, itemID)
        if ok and icon then return icon end
    end
    return "Interface\\Icons\\inv_misc_questionmark"
end

-- =========================================================================
-- FUNCIÓN AUXILIAR: CREACIÓN DE BOTONES ESTÁNDAR
-- =========================================================================
local function CreateBlizzButton(parent, text, onClick)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetHeight(22)
    b:SetText(text or "")
    if onClick then b:SetScript("OnClick", onClick) end
    return b
end

-- =========================================================================
-- CABECERAS DE COLUMNA NATIVAS (ESTILO OLYMPUS / WHOFRAME)
-- =========================================================================
local function CreateColumnHeader(parent, index, title, width, xOffset)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width, 20)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, 0)

    btn:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    btn:SetBackdropColor(0.12, 0.12, 0.16, 0.95)
    btn:SetBackdropBorderColor(0.3, 0.3, 0.35, 1)

    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("LEFT", btn, "LEFT", 6, 0)
    label:SetPoint("RIGHT", btn, "RIGHT", -4, 0)
    label:SetJustifyH("LEFT")
    label:SetText(title)
    btn.label = label

    return btn
end

local function SetColumnHeaders(col1Title, col1W, col1X, col2Title, col2W, col2X, col3Title, col3W, col3X, col3Align, col2Align)
    if not colHeaderButtons[1] then return end

    if col1Title and col1W then
        colHeaderButtons[1]:Show()
        colHeaderButtons[1]:SetWidth(col1W)
        colHeaderButtons[1]:ClearAllPoints()
        colHeaderButtons[1]:SetPoint("TOPLEFT", colHeaderButtons[1]:GetParent(), "TOPLEFT", col1X or 0, 0)
        colHeaderButtons[1].label:SetText(col1Title)
        colHeaderButtons[1].label:SetJustifyH("LEFT")
        colHeaderButtons[1].label:ClearAllPoints()
        colHeaderButtons[1].label:SetPoint("LEFT", colHeaderButtons[1], "LEFT", 6, 0)
        colHeaderButtons[1].label:SetPoint("RIGHT", colHeaderButtons[1], "RIGHT", -4, 0)
    end

    if col2Title and col2W then
        colHeaderButtons[2]:Show()
        colHeaderButtons[2]:SetWidth(col2W)
        colHeaderButtons[2]:ClearAllPoints()
        colHeaderButtons[2]:SetPoint("TOPLEFT", colHeaderButtons[2]:GetParent(), "TOPLEFT", col2X or (col1W + 1), 0)
        colHeaderButtons[2].label:SetText(col2Title)
        colHeaderButtons[2].label:SetJustifyH(col2Align or "LEFT")
        colHeaderButtons[2].label:ClearAllPoints()
        if col2Align == "RIGHT" then
            colHeaderButtons[2].label:SetPoint("LEFT", colHeaderButtons[2], "LEFT", 4, 0)
            colHeaderButtons[2].label:SetPoint("RIGHT", colHeaderButtons[2], "RIGHT", -30, 0)
        else
            colHeaderButtons[2].label:SetPoint("LEFT", colHeaderButtons[2], "LEFT", 6, 0)
            colHeaderButtons[2].label:SetPoint("RIGHT", colHeaderButtons[2], "RIGHT", -4, 0)
        end
    end

    if col3Title and col3W then
        colHeaderButtons[3]:Show()
        colHeaderButtons[3]:SetWidth(col3W)
        colHeaderButtons[3]:ClearAllPoints()
        colHeaderButtons[3]:SetPoint("TOPLEFT", colHeaderButtons[3]:GetParent(), "TOPLEFT", col3X or ((col2X or 0) + col2W + 1), 0)
        colHeaderButtons[3].label:SetText(col3Title)
        colHeaderButtons[3].label:SetJustifyH(col3Align or "LEFT")
        colHeaderButtons[3].label:ClearAllPoints()
        if col3Align == "RIGHT" then
            colHeaderButtons[3].label:SetPoint("LEFT", colHeaderButtons[3], "LEFT", 4, 0)
            colHeaderButtons[3].label:SetPoint("RIGHT", colHeaderButtons[3], "RIGHT", -30, 0)
        else
            colHeaderButtons[3].label:SetPoint("LEFT", colHeaderButtons[3], "LEFT", 6, 0)
            colHeaderButtons[3].label:SetPoint("RIGHT", colHeaderButtons[3], "RIGHT", -4, 0)
        end
    else
        if colHeaderButtons[3] then
            colHeaderButtons[3]:Hide()
        end
    end
end

-- =========================================================================
-- INICIALIZACIÓN DEL MARCO PRINCIPAL (PORTRAIT FRAME TEMPLATE)
-- =========================================================================
function MainUI:Init()
    if mainFrame then return end

    -- 1. Ventana con PortraitFrameTemplate oficial de Blizzard (exacto a Olympus)
    local ok, f = pcall(CreateFrame, "Frame", "AwakeningMainFrame", UIParent, "PortraitFrameTemplate")
    if ok and f and f.CloseButton then
        f.hasPortrait = true
    else
        if ok and f then f:Hide() end
        f = CreateFrame("Frame", "AwakeningMainFrame", UIParent, "BasicFrameTemplateWithInset")
    end

    f:SetSize(FRAME_W, FRAME_H)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 40)
    f:SetFrameStrata("MEDIUM")
    f:SetToplevel(true)
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()

    -- Cerrar con la tecla ESC
    tinsert(UISpecialFrames, "AwakeningMainFrame")

    -- Título en la barra superior
    if f.SetTitle then
        f:SetTitle("|cFFFFD100Awakening|r")
    elseif f.TitleText then
        f.TitleText:SetText("|cFFFFD100Awakening|r")
    elseif f.TitleContainer and f.TitleContainer.TitleText then
        f.TitleContainer.TitleText:SetText("|cFFFFD100Awakening|r")
    end

    -- Icono del tabardo en el marco circular superior izquierdo (exacto a Olympus)
    if f.hasPortrait then
        local portrait = f.portrait or f.Portrait or (f.PortraitContainer and f.PortraitContainer.portrait)
        if portrait then
            portrait:SetTexture("Interface\\AddOns\\AwakeningCompanion\\Media\\Icons\\awakening_crest.tga")
            portrait:SetTexCoord(0, 1, 0, 1)
            if portrait.SetMask and not portrait.masked then
                portrait.masked = pcall(portrait.SetMask, portrait, "Interface\\CharacterFrame\\TempPortraitAlphaMask")
            end
        end
    else
        -- Fallback si el cliente no proveyó retrato nativo
        local pBg = f:CreateTexture(nil, "BACKGROUND")
        pBg:SetSize(52, 52)
        pBg:SetPoint("TOPLEFT", -6, 7)
        pBg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
        local p = f:CreateTexture(nil, "ARTWORK")
        p:SetSize(50, 50)
        p:SetPoint("CENTER", pBg, "CENTER", 0, 0)
        p:SetTexture("Interface\\AddOns\\AwakeningCompanion\\Media\\Icons\\awakening_crest.tga")
        if f.CreateMaskTexture and p.AddMaskTexture then
            local mask = f:CreateMaskTexture()
            mask:SetSize(50, 50)
            mask:SetPoint("CENTER", p, "CENTER")
            mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            p:AddMaskTexture(mask)
        end
    end

    -- 2. Hero Header Metric (junto al emblema, estilo Olympus)
    local hx = f.hasPortrait and 60 or 14
    f.heroTitle = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.heroTitle:SetPoint("TOPLEFT", hx, -28)
    f.heroTitle:SetPoint("RIGHT", f, "RIGHT", -36, 0)
    f.heroTitle:SetJustifyH("LEFT")
    f.heroTitle:SetWordWrap(false)
    f.heroTitle:SetText("|cFFFFD1004 Secretos Clásicos|r")

    -- Botón interactivo sobre el título principal para abrir diálogo de Habilidades al hacer doble clic
    local heroTitleBtn = CreateFrame("Button", nil, f)
    heroTitleBtn:SetPoint("TOPLEFT", f.heroTitle, "TOPLEFT", -2, 2)
    heroTitleBtn:SetPoint("BOTTOMRIGHT", f.heroTitle, "BOTTOMRIGHT", 2, -2)
    heroTitleBtn:EnableMouse(true)
    heroTitleBtn:RegisterForClicks("LeftButtonUp")

    local lastHeroClickTime = 0
    heroTitleBtn:SetScript("OnClick", function(selfBtn, button)
        local now = GetTime()
        if (now - lastHeroClickTime) < 0.35 then
            lastHeroClickTime = 0
            if ns.SkillsUI then
                ns.SkillsUI:Toggle()
            end
        else
            lastHeroClickTime = now
        end
    end)
    pcall(function()
        heroTitleBtn:SetScript("OnDoubleClick", function()
            if ns.SkillsUI then
                ns.SkillsUI:Toggle()
            end
        end)
    end)

    heroTitleBtn:SetScript("OnEnter", function(selfBtn)
        local pName = UnitName("player") or "Jugador"
        local locClass = UnitClass("player") or "Aventurero"
        local pLevel = UnitLevel("player") or 1
        GameTooltip:SetOwner(selfBtn, "ANCHOR_BOTTOMLEFT", 0, -4)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(string.format("|cFFFFD100%s · %s (%d)|r", pName, locClass, pLevel), 1, 0.82, 0)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cFF00FFCCDoble clic: Abrir Habilidades de Clase y Entrenador|r", 0.2, 1, 0.4, true)
        GameTooltip:Show()
    end)
    heroTitleBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    f.heroTitleBtn = heroTitleBtn

    f.subStatus = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.subStatus:SetPoint("TOPLEFT", f.heroTitle, "BOTTOMLEFT", 0, -2)
    f.subStatus:SetPoint("RIGHT", f, "RIGHT", -36, 0)
    f.subStatus:SetJustifyH("LEFT")
    f.subStatus:SetWordWrap(false)
    f.subStatus:SetText("Cargando estadísticas...")

    -- Botón interactivo invisible sobre el subtítulo para mostrar el Tooltip detallado de Stat Weights y Caps
    local subBtn = CreateFrame("Button", nil, f)
    subBtn:SetPoint("TOPLEFT", f.subStatus, "TOPLEFT", 0, 4)
    subBtn:SetPoint("BOTTOMRIGHT", f.subStatus, "BOTTOMRIGHT", 0, -4)
    subBtn:EnableMouse(true)
    subBtn:SetScript("OnEnter", function(selfBtn)
        local _, pClass = UnitClass("player")
        local spec = selectedBiSSpec or (ns.GetClassDefaultEnchantSpec and ns.GetClassDefaultEnchantSpec(pClass))
        if ns.ShowStatWeightsTooltip then
            ns.ShowStatWeightsTooltip(selfBtn, pClass, spec)
        end
    end)
    subBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    f.subStatusBtn = subBtn

    -- 3. Inset Superior: Contenedor de Listas y Tablas
    local okBox, listBox = pcall(CreateFrame, "Frame", nil, f, "InsetFrameTemplate")
    if not okBox or not listBox then
        listBox = CreateFrame("Frame", nil, f, "BackdropTemplate")
        listBox:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        listBox:SetBackdropColor(0.02, 0.02, 0.04, 0.95)
    end
    listBox:SetPoint("TOPLEFT", 6, -64)
    listBox:SetPoint("BOTTOMRIGHT", -6, 34 + DETAIL_H + 4)
    f.listBox = listBox

    -- Cabeceras de Columna sobre la lista
    local colHeaderFrame = CreateFrame("Frame", nil, f)
    colHeaderFrame:SetPoint("TOPLEFT", listBox, "TOPLEFT", 2, -2)
    colHeaderFrame:SetPoint("TOPRIGHT", listBox, "TOPRIGHT", -2, -2)
    colHeaderFrame:SetHeight(20)
    f.colHeaderFrame = colHeaderFrame

    colHeaderButtons[1] = CreateColumnHeader(colHeaderFrame, 1, "Misión", 290, 0)
    colHeaderButtons[2] = CreateColumnHeader(colHeaderFrame, 2, "Zona", 125, 291)
    colHeaderButtons[3] = CreateColumnHeader(colHeaderFrame, 3, "Estado", 108, 417)

    -- 4. Inset Inferior: Caja de Detalles (Detail Box estilo Olympus HD)
    local okDetail, detailBox = pcall(CreateFrame, "Frame", nil, f, "InsetFrameTemplate")
    if not okDetail or not detailBox then
        detailBox = CreateFrame("Frame", nil, f, "BackdropTemplate")
        detailBox:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        detailBox:SetBackdropColor(0.02, 0.02, 0.04, 0.95)
    end
    detailBox:SetPoint("BOTTOMLEFT", 6, 32)
    detailBox:SetPoint("BOTTOMRIGHT", -6, 32)
    detailBox:SetHeight(DETAIL_H)
    f.detailBox = detailBox

    local detailTitle = detailBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    detailTitle:SetPoint("TOPLEFT", 8, -6)
    detailTitle:SetPoint("TOPRIGHT", -8, -6)
    detailTitle:SetJustifyH("LEFT")
    detailTitle:SetWordWrap(false)
    f.detailTitle = detailTitle

    -- Contenedor de Recompensas Interactivas (con Tooltip nativo al pasar el mouse)
    local rewardContainer = CreateFrame("Frame", nil, detailBox)
    rewardContainer:SetPoint("TOPLEFT", detailTitle, "BOTTOMLEFT", 0, -4)
    rewardContainer:SetPoint("TOPRIGHT", detailBox, "TOPRIGHT", -8, -26)
    rewardContainer:SetHeight(20)
    rewardContainer:Hide()
    detailBox.rewardContainer = rewardContainer

    local rewardLabel = CreateFrame("Button", nil, rewardContainer)
    rewardLabel:SetPoint("LEFT", rewardContainer, "LEFT", 0, 0)
    rewardLabel:SetHeight(20)
    local rText = rewardLabel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rText:SetPoint("LEFT", rewardLabel, "LEFT", 0, 0)
    rText:SetText("|cFFFFCC00Recompensas:|r")
    rewardLabel:SetWidth(85)
    rewardLabel.text = rText
    rewardContainer.label = rewardLabel

    rewardLabel:SetScript("OnEnter", function(selfLbl)
        if not selfLbl.items or #selfLbl.items == 0 then return end
        GameTooltip:SetOwner(selfLbl, "ANCHOR_RIGHT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine("|cFFFFD100Recompensas registradas:|r", 1, 0.82, 0)
        GameTooltip:AddLine(" ")
        for _, itm in ipairs(selfLbl.items) do
            local itemName, itemLink, itemQuality, itemTexture = SafeGetItemInfo(itm.itemID)
            local icon = itm.icon or itemTexture or SafeGetItemIcon(itm.itemID)
            local name = itemLink or itm.name or itemName or ("Objeto #" .. (itm.itemID or 0))
            local count = (itm.count and itm.count > 1) and (" (x" .. itm.count .. ")") or ""
            GameTooltip:AddLine(string.format("|T%s:16:16:0:0:64:64:4:60:4:60|t %s%s", icon, name, count), 1, 1, 1)
            if itm.desc then
                GameTooltip:AddLine("   |cFF88DDFF" .. itm.desc .. "|r", 0.7, 0.85, 1, true)
            end
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cFF888888Pasa el cursor sobre cada botón para ver las estadísticas individuales.|r", 0.6, 0.6, 0.6, true)
        GameTooltip:Show()
    end)
    rewardLabel:SetScript("OnLeave", function() GameTooltip:Hide() end)

    detailBox.rewardButtons = {}
    for bIdx = 1, 4 do
        local rBtn = CreateFrame("Button", nil, rewardContainer, "BackdropTemplate")
        rBtn:SetHeight(20)
        rBtn:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 8, edgeSize = 8,
            insets = { left = 1, right = 1, top = 1, bottom = 1 }
        })
        rBtn:SetBackdropColor(0.06, 0.06, 0.10, 0.90)
        rBtn:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.8)

        local rHl = rBtn:CreateTexture(nil, "HIGHLIGHT")
        rHl:SetAllPoints()
        rHl:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight")
        rHl:SetBlendMode("ADD")
        rHl:SetAlpha(0.4)

        local rIcon = rBtn:CreateTexture(nil, "ARTWORK")
        rIcon:SetSize(16, 16)
        rIcon:SetPoint("LEFT", rBtn, "LEFT", 2, 0)
        rIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        rBtn.icon = rIcon

        local rBtnText = rBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        rBtnText:SetPoint("LEFT", rIcon, "RIGHT", 4, 0)
        rBtnText:SetPoint("RIGHT", rBtn, "RIGHT", -4, 0)
        rBtnText:SetJustifyH("LEFT")
        rBtnText:SetWordWrap(false)
        rBtn.text = rBtnText

        rBtn:SetScript("OnEnter", function(selfBtn)
            if not selfBtn.itemID and not selfBtn.itemLink and not selfBtn.customDesc then return end
            GameTooltip:SetOwner(selfBtn, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            if selfBtn.isEnchant then
                if selfBtn.title then
                    GameTooltip:AddLine(selfBtn.title, 1, 1, 1)
                end
            elseif selfBtn.itemLink then
                GameTooltip:SetHyperlink(selfBtn.itemLink)
            elseif selfBtn.itemID and selfBtn.itemID > 0 then
                GameTooltip:SetItemByID(selfBtn.itemID)
            end
            if selfBtn.customDesc then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(selfBtn.customDesc, 1, 0.82, 0, true)
            end
            if selfBtn.extraLines then
                for _, line in ipairs(selfBtn.extraLines) do
                    GameTooltip:AddLine(line.text, line.r or 1, line.g or 1, line.b or 1, line.wrap ~= false)
                end
            end
            GameTooltip:Show()
        end)

        rBtn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        rBtn:SetScript("OnClick", function(selfBtn)
            if selfBtn.itemLink and IsModifiedClick("CHATLINK") then
                ChatEdit_InsertLink(selfBtn.itemLink)
            elseif ns.OpenInAtlasLoot and selfBtn.itemID and selfBtn.itemID > 0 then
                local name = selfBtn.itemLink or selfBtn.title or (selfBtn.text and selfBtn.text:GetText())
                ns.OpenInAtlasLoot(name, selfBtn.itemID)
            end
        end)

        rBtn:Hide()
        detailBox.rewardButtons[bIdx] = rBtn
    end

    local detailText = detailBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    detailText:SetPoint("TOPLEFT", detailTitle, "BOTTOMLEFT", 0, -3)
    detailText:SetPoint("BOTTOMRIGHT", -8, 6)
    detailText:SetJustifyH("LEFT")
    detailText:SetJustifyV("TOP")
    detailText:SetSpacing(1)
    f.detailText = detailText

    -- 5. Barra Inferior con 3 Botones Blizzard (Copy/Start, Refresh, Toggle HUD)
    local btnW = (FRAME_W - 20) / 3
    
    local btn1 = CreateBlizzButton(f, "Iniciar Ruta", function()
        MainUI:OnActionButton1()
    end)
    btn1:SetSize(btnW, 22)
    btn1:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 6, 6)
    bottomButtons[1] = btn1

    local btn2 = CreateBlizzButton(f, "Actualizar", function()
        MainUI:OnActionButton2()
    end)
    btn2:SetSize(btnW, 22)
    btn2:SetPoint("LEFT", btn1, "RIGHT", 4, 0)
    bottomButtons[2] = btn2

    local btn3 = CreateBlizzButton(f, "Habilidades", function()
        if ns.SkillsUI then
            ns.SkillsUI:Toggle()
        elseif ns.GuideHUD then
            ns.GuideHUD:Toggle()
        end
    end)
    btn3:SetSize(btnW, 22)
    btn3:SetPoint("LEFT", btn2, "RIGHT", 4, 0)
    bottomButtons[3] = btn3

    -- 6. Pestañas Laterales Derechas (SpellBook Tabs estilo Olympus HD)
    for i, t in ipairs(TABS_CONFIG) do
        local tab = CreateFrame("CheckButton", nil, f)
        tab:SetSize(32, 32)
        tab:SetPoint("TOPLEFT", f, "TOPRIGHT", -2, -56 - ((i - 1) * 44))

        local art = tab:CreateTexture(nil, "BORDER")
        art:SetTexture("Interface\\SpellBook\\SpellBook-SkillLineTab")
        art:SetSize(64, 64)
        art:SetPoint("TOPLEFT", -3, 11)
        tab.Art = art

        local icon = tab:CreateTexture(nil, "ARTWORK", nil, 1)
        icon:SetSize(28, 28)
        icon:SetPoint("CENTER")
        icon:SetTexture(t.icon)
        tab.Icon = icon

        tab:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
        tab:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight", "ADD")
        local chk = tab:GetCheckedTexture()
        if chk then
            chk:SetBlendMode("ADD")
            chk:SetDrawLayer("HIGHLIGHT", 2)
        end

        tab:SetScript("OnEnter", function(selfTab)
            GameTooltip:SetOwner(selfTab, "ANCHOR_RIGHT")
            GameTooltip:SetText(t.tooltip)
            GameTooltip:Show()
        end)
        tab:SetScript("OnLeave", function() GameTooltip:Hide() end)

        tab:SetScript("OnClick", function()
            MainUI:SelectTab(i)
        end)

        sideTabs[i] = tab
    end

    -- Construir Vistas de Contenido dentro del Inset Superior
    self:BuildViews(listBox)

    mainFrame = f
    MainUI.frame = f
    self:UpdateSubtitle()
    MainUI:SelectTab(1)
end

-- =========================================================================
-- CONTENEDOR DE RECOMPENSAS INTERACTIVAS CON TOOLTIPS NATIVOS
-- =========================================================================
function MainUI:ShowDetailRewards(items, labelText)
    if not mainFrame or not mainFrame.detailBox then return end
    local db = mainFrame.detailBox
    local rc = db.rewardContainer
    if not rc then return end

    if not items or #items == 0 then
        rc:Hide()
        if rc.label then rc.label.items = nil end
        if mainFrame.detailText then
            mainFrame.detailText:ClearAllPoints()
            mainFrame.detailText:SetPoint("TOPLEFT", mainFrame.detailTitle, "BOTTOMLEFT", 0, -3)
            mainFrame.detailText:SetPoint("BOTTOMRIGHT", mainFrame.detailBox, "BOTTOMRIGHT", -8, 6)
        end
        return
    end

    if rc.label then
        rc.label.text:SetText(labelText or "|cFFFFCC00Recompensas:|r")
        local lW = rc.label.text:GetStringWidth() or 85
        rc.label:SetWidth(lW + 4)
        rc.label.items = items
    end
    rc:Show()

    local count = math.min(#items, 4)
    local labelW = (rc.label and rc.label:GetWidth()) or 85
    local totalAvail = (FRAME_W - 24) - labelW - (count * 6) - 10
    local maxBtnW = math.floor(totalAvail / count)
    if maxBtnW < 75 then maxBtnW = 75 end

    local prevAnchor = rc.label
    for idx = 1, 4 do
        local btn = db.rewardButtons[idx]
        local itemData = items[idx]
        if itemData and btn then
            local isTable = type(itemData) == "table"
            local itemID = isTable and itemData.itemID or itemData
            local itemName, itemLink, itemQuality, itemTexture = SafeGetItemInfo(itemID)
            local icon = (isTable and itemData.icon) or itemTexture or SafeGetItemIcon(itemID)
            local name = itemLink or (isTable and itemData.name) or itemName or ("Objeto #" .. (itemID or 0))
            local countVal = isTable and itemData.count or nil
            local countStr = (countVal and countVal > 1) and (" (x" .. countVal .. ")") or ""

            btn.itemID = itemID
            btn.itemLink = itemLink
            btn.isEnchant = isTable and itemData.isEnchant
            btn.title = isTable and (itemData.title or itemData.name) or nil
            btn.customDesc = isTable and itemData.desc or nil
            btn.extraLines = isTable and itemData.extraLines or nil
            btn.icon:SetTexture(icon)

            local q = itemQuality or (isTable and itemData.quality) or 1
            local qc = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[q]
            if qc then
                btn:SetBackdropBorderColor(qc.r, qc.g, qc.b, 0.85)
                if not itemLink and not (isTable and itemData.name) then
                    local hex = qc.hex or "|cFFFFFFFF"
                    name = hex .. (itemName or ("Objeto #" .. (itemID or 0))) .. "|r"
                end
            else
                btn:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.8)
            end

            btn.text:SetText(name .. countStr)
            local naturalW = 16 + 8 + btn.text:GetStringWidth() + 6
            local finalW = math.min(naturalW, maxBtnW)
            btn:SetWidth(finalW)

            btn:ClearAllPoints()
            btn:SetPoint("LEFT", prevAnchor, "RIGHT", 6, 0)
            btn:Show()
            prevAnchor = btn
        elseif btn then
            btn:Hide()
        end
    end

    if mainFrame.detailText then
        mainFrame.detailText:ClearAllPoints()
        mainFrame.detailText:SetPoint("TOPLEFT", rc, "BOTTOMLEFT", 0, -3)
        mainFrame.detailText:SetPoint("BOTTOMRIGHT", mainFrame.detailBox, "BOTTOMRIGHT", -8, 6)
    end
end

-- =========================================================================
-- CREACIÓN DINÁMICA DE VISTAS SEGÚN TABS_CONFIG
-- =========================================================================
function MainUI:BuildViews(container)
    for i, t in ipairs(TABS_CONFIG) do
        local v = CreateFrame("Frame", nil, container)
        v:SetPoint("TOPLEFT", container, "TOPLEFT", 2, -22)
        v:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -2, 2)
        v:Hide()
        views[i] = v
        viewsByKey[t.key] = v

        if t.key == "bis" then
            self:BuildBiSList(v)
        elseif t.key == "secrets" then
            self:BuildSecretsList(v)
        elseif t.key == "farming" then
            self:BuildFarmingList(v)
        elseif t.key == "prep" then
            self:BuildRaidPrepList(v)
        elseif t.key == "travel" then
            self:BuildTravelView(v)
        elseif t.key == "guild" then
            self:BuildGuildList(v)
        end
    end
end

-- =========================================================================
-- VISTA 1: BEST IN SLOT (BiS) BASADO EN NIVEL Y CLASE DEL JUGADOR
-- =========================================================================
local bisRowFrames = {}
local bisPreloadBatchID = 0
local currentPreloadState = nil
local bisPreloadTimerFrame = nil

function MainUI:BuildBiSList(parent)
    -- 1. Barra de controles superiores: Selector de Modo (Radio buttons), Tier y Rama
    local controls = CreateFrame("Frame", nil, parent)
    controls:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, 0)
    controls:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -2, 0)
    controls:SetHeight(44)
    parent.controls = controls

    -- Fila 1: Radio Buttons de Selección entre [Equipo BiS] y [Encantamientos Óptimos]
    local okRadioG, radioGear = pcall(CreateFrame, "CheckButton", "AwakeningBiSRadioGear", controls, "UIRadioButtonTemplate")
    if not okRadioG or not radioGear then
        radioGear = CreateFrame("CheckButton", "AwakeningBiSRadioGear", controls, "UICheckButtonTemplate")
    end
    radioGear:SetSize(18, 18)
    radioGear:SetPoint("TOPLEFT", controls, "TOPLEFT", 4, -1)
    radioGear:SetChecked(selectedBiSMode ~= "enchants")
    parent.radioGear = radioGear

    local radioGearText = radioGear:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    radioGearText:SetPoint("LEFT", radioGear, "RIGHT", 4, 1)
    radioGearText:SetText(selectedBiSMode == "gear" and "|cFFFFD100Equipo BiS|r" or "|cFFFFFFFFEquipo BiS|r")
    radioGear.text = radioGearText

    local radioGearHit = CreateFrame("Button", nil, controls)
    radioGearHit:SetPoint("TOPLEFT", radioGear, "TOPLEFT", 0, 0)
    radioGearHit:SetPoint("BOTTOMRIGHT", radioGearText, "BOTTOMRIGHT", 6, 0)
    radioGearHit:SetScript("OnClick", function()
        MainUI:SetBiSMode("gear")
    end)
    radioGear:SetScript("OnClick", function()
        MainUI:SetBiSMode("gear")
    end)
    radioGearHit:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:AddLine("Equipo BiS (Recomendado)", 1, 0.82, 0)
        GameTooltip:AddLine("Muestra el mejor equipamiento (armadura, armas, anillos y abalorios) disponible para tu clase y nivel actual.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    radioGearHit:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local okRadioE, radioEnchants = pcall(CreateFrame, "CheckButton", "AwakeningBiSRadioEnchants", controls, "UIRadioButtonTemplate")
    if not okRadioE or not radioEnchants then
        radioEnchants = CreateFrame("CheckButton", "AwakeningBiSRadioEnchants", controls, "UICheckButtonTemplate")
    end
    radioEnchants:SetSize(18, 18)
    radioEnchants:SetPoint("LEFT", radioGearText, "RIGHT", 24, 0)
    radioEnchants:SetChecked(selectedBiSMode == "enchants")
    parent.radioEnchants = radioEnchants

    local radioEnchantsText = radioEnchants:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    radioEnchantsText:SetPoint("LEFT", radioEnchants, "RIGHT", 4, 1)
    radioEnchantsText:SetText(selectedBiSMode == "enchants" and "|cFFFFD100Encantamientos Óptimos|r" or "|cFFFFFFFFEncantamientos Óptimos|r")
    radioEnchants.text = radioEnchantsText

    local radioEnchantsHit = CreateFrame("Button", nil, controls)
    radioEnchantsHit:SetPoint("TOPLEFT", radioEnchants, "TOPLEFT", 0, 0)
    radioEnchantsHit:SetPoint("BOTTOMRIGHT", radioEnchantsText, "BOTTOMRIGHT", 6, 0)
    radioEnchantsHit:SetScript("OnClick", function()
        MainUI:SetBiSMode("enchants")
    end)
    radioEnchants:SetScript("OnClick", function()
        MainUI:SetBiSMode("enchants")
    end)
    radioEnchantsHit:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:AddLine("Encantamientos Óptimos (Fase 1 / Pre-Raid)", 1, 0.82, 0)
        GameTooltip:AddLine("Muestra los mejores encantamientos, arcanos y mejoras de ingeniería para cada ranura de tu rol y especialización.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    radioEnchantsHit:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local modeBadge = controls:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    modeBadge:SetPoint("RIGHT", controls, "RIGHT", -4, -1)
    modeBadge:SetText(selectedBiSMode == "enchants" and "|cFF00FFCCModo: Encantamientos|r" or "|cFF888888Modo: Equipo|r")
    parent.modeBadge = modeBadge

    -- Fila 2: Botones de Nivel/Tier y Rama/Especialización
    local tierBtn = CreateBlizzButton(controls, "Nivel: Auto", function()
        MainUI:CycleBiSBracket()
    end)
    tierBtn:SetPoint("TOPLEFT", controls, "TOPLEFT", 0, -22)
    tierBtn:SetWidth(218)
    tierBtn:SetHeight(20)
    parent.tierBtn = tierBtn

    local tierArrow = tierBtn:CreateTexture(nil, "OVERLAY")
    tierArrow:SetSize(10, 10)
    tierArrow:SetPoint("RIGHT", tierBtn, "RIGHT", -8, 0)
    tierArrow:SetTexture("Interface\\AddOns\\AwakeningCompanion\\Media\\Icons\\arrow_down.tga")
    tierBtn.arrow = tierArrow

    tierBtn:SetScript("OnEnter", function(selfBtn)
        GameTooltip:SetOwner(selfBtn, "ANCHOR_TOP")
        if selectedBiSMode == "enchants" then
            GameTooltip:AddLine("Fase de Encantamientos", 1, 0.82, 0)
            GameTooltip:AddLine("Fase 1 / Pre-Raid (Nivel 60). Los encantamientos óptimos de Classic para prepararte para bandas.", 1, 1, 1, true)
        else
            GameTooltip:AddLine("Nivel / Tier de Equipo", 1, 0.82, 0)
            GameTooltip:AddLine("Clic para alternar el rango de nivel o tier de mazmorras/raids.", 1, 1, 1, true)
        end
        GameTooltip:Show()
    end)
    tierBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local specBtn = CreateBlizzButton(controls, "Rama: ...", function(selfBtn, mouseBtn)
        MainUI:CycleBiSSpec(mouseBtn == "RightButton")
    end)
    specBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    specBtn:SetPoint("LEFT", tierBtn, "RIGHT", 4, 0)
    specBtn:SetWidth(218)
    specBtn:SetHeight(20)
    parent.specBtn = specBtn

    local specArrow = specBtn:CreateTexture(nil, "OVERLAY")
    specArrow:SetSize(10, 10)
    specArrow:SetPoint("RIGHT", specBtn, "RIGHT", -8, 0)
    specArrow:SetTexture("Interface\\AddOns\\AwakeningCompanion\\Media\\Icons\\arrow_down.tga")
    specBtn.arrow = specArrow

    specBtn:SetScript("OnEnter", function(selfBtn)
        GameTooltip:SetOwner(selfBtn, "ANCHOR_TOP")
        if selectedBiSMode == "enchants" then
            GameTooltip:AddLine("Especialización de Encantamientos", 1, 0.82, 0)
            GameTooltip:AddLine("|cFF00FFCCClic Izquierdo:|r Alternar entre ramas de tu clase actual.", 1, 1, 1, true)
            GameTooltip:AddLine("|cFFFFFFFFClic Derecho:|r Explorar ramas de todas las demás clases.", 0.8, 0.8, 0.8, true)
        else
            GameTooltip:AddLine("Especialización de Equipo", 1, 0.82, 0)
            GameTooltip:AddLine("Clic para alternar entre las ramas de talento de tu clase.", 1, 1, 1, true)
        end
        GameTooltip:Show()
    end)
    specBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- 2. Scroll de ranuras BiS (17 ranuras estándar de equipo)
    local scroll = CreateFrame("ScrollFrame", "AwakeningBiSScroll", parent, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, -46)
    scroll:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -20, 2)
    parent.scroll = scroll

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(440, 10)
    scroll:SetScrollChild(content)
    parent.content = content

    local yOffset = 0
    for idx, slotInfo in ipairs(ns.Data.BiSSlotsOrder or {}) do
        local row = CreateFrame("Button", nil, content, "BackdropTemplate")
        row:SetSize(440, 20)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)

        -- Resaltado hover estilo Olympus
        local hl = row:CreateTexture(nil, "HIGHLIGHT")
        hl:SetAllPoints()
        hl:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight")
        hl:SetBlendMode("ADD")
        hl:SetAlpha(0.35)

        -- Resaltado de selección activa
        local sel = row:CreateTexture(nil, "BORDER")
        sel:SetAllPoints()
        sel:SetColorTexture(1, 0.82, 0, 0.15)
        sel:Hide()
        row.selection = sel

        -- Columna 1: Ranura
        local slotLabel = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        slotLabel:SetPoint("LEFT", row, "LEFT", 4, 0)
        slotLabel:SetPoint("RIGHT", row, "LEFT", 78, 0)
        slotLabel:SetJustifyH("LEFT")
        slotLabel:SetWordWrap(false)
        slotLabel:SetText(slotInfo.name)
        row.slotLabel = slotLabel

        -- Columna 2: Icono + Objeto BiS / Encantamiento
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(16, 16)
        icon:SetPoint("LEFT", row, "LEFT", 82, 0)
        icon:SetTexture("Interface\\Icons\\inv_misc_questionmark")
        row.icon = icon

        local itemLabel = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        itemLabel:SetPoint("LEFT", icon, "RIGHT", 4, 0)
        itemLabel:SetPoint("RIGHT", row, "LEFT", 376, 0)
        itemLabel:SetJustifyH("LEFT")
        itemLabel:SetWordWrap(false)
        itemLabel:SetText("Cargando...")
        row.itemLabel = itemLabel

        -- Columna 3: Estado / Fuente
        local statusLabel = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        statusLabel:SetPoint("LEFT", row, "LEFT", 378, 0)
        statusLabel:SetPoint("RIGHT", row, "RIGHT", -6, 0)
        statusLabel:SetJustifyH("RIGHT")
        statusLabel:SetWordWrap(false)
        statusLabel:SetText("Falta")
        row.statusLabel = statusLabel

        -- Tooltip con metadatos estilo BiSTracker / Encantamientos
        row:SetScript("OnEnter", function(selfRow)
            if selectedBiSMode == "enchants" then
                if selfRow.enchantID and selfRow.enchantID > 0 then
                    local meta = selfRow.enchantMeta or ns.GetEnchantMetadata(selfRow.enchantID)
                    GameTooltip:SetOwner(selfRow, "ANCHOR_RIGHT")
                    GameTooltip:ClearLines()
                    local qc = (meta.quality == 4 and "|cFFA335EE") or (meta.quality == 3 and "|cFF0070DD") or (meta.quality == 2 and "|cFF1EFF00") or "|cFFFFFFFF"
                    GameTooltip:AddLine(qc .. (meta.name or "Encantamiento") .. "|r", 1, 1, 1)
                    GameTooltip:AddDoubleLine("|cFFFFD100Ranura:|r " .. (selfRow.slotName or slotInfo.name), "|cFFFFD100Efecto Óptimo:|r |cFF00FF00" .. meta.effect .. "|r")
                    GameTooltip:AddDoubleLine("|cFFFFD100Tipo de Mejora:|r " .. meta.type, "|cFFFFD100Fase:|r Pre-Raid (Nv. 60)")
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddDoubleLine("|cFFFFD100Fuente / Procedencia:|r", meta.source, 1, 0.82, 0, 1, 1, 1, true)
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("|cFFFFD100Reactivos / Materiales necesarios:|r", 1, 0.82, 0)
                    GameTooltip:AddLine(meta.materials, 0.8, 0.9, 1, true)
                    if meta.desc then
                        GameTooltip:AddLine(" ")
                        GameTooltip:AddLine(meta.desc, 0.8, 0.8, 0.8, true)
                    end
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("|cFF00FFCCClick:|r Ver detalles completos en el panel inferior.", 0.6, 0.6, 0.6)
                    GameTooltip:Show()
                else
                    GameTooltip:SetOwner(selfRow, "ANCHOR_RIGHT")
                    GameTooltip:ClearLines()
                    GameTooltip:AddLine("|cFFFFD100" .. (selfRow.slotName or slotInfo.name) .. "|r", 1, 0.82, 0)
                    if selectedBiSBracket == "1-14" then
                        GameTooltip:AddLine("|cFFFF5555No se recomienda encantar en Nivel 1-14|r", 1, 0.3, 0.3)
                        GameTooltip:AddLine("|cFFCCCCCCDebido a la baja calidad del equipo y a su rápida rotación en estos niveles tempranos, no se recomienda invertir oro en encantamientos. Ahorra para habilidades de clase e inicia los encantamientos a partir de Nivel 15-25.|r", 1, 1, 1, true)
                        GameTooltip:AddLine(" ")
                        GameTooltip:AddLine("|cFF00FFCCClick:|r Ver información en el panel inferior.", 0.6, 0.6, 0.6)
                    else
                        GameTooltip:AddLine("|cFF888888En WoW Classic original no existen encantamientos para esta ranura. Los encantamientos para anillos y ranuras menores se introdujeron en expansiones posteriores (TBC/WotLK).|r", 1, 1, 1, true)
                    end
                    GameTooltip:Show()
                end
                return
            end

            if not selfRow.itemID or selfRow.itemID == 0 then
                if selectedBiSBracket == "1-14" then
                    GameTooltip:SetOwner(selfRow, "ANCHOR_RIGHT")
                    GameTooltip:ClearLines()
                    GameTooltip:AddLine("|cFFFFD100" .. (selfRow.slotName or slotInfo.name) .. "|r", 1, 0.82, 0)
                    GameTooltip:AddLine("|cFF888888Ranura no disponible en Nivel 1-14.|r", 1, 0.82, 0)
                    GameTooltip:AddLine("|cFFCCCCCCEn WoW Classic no hay piezas para esta ranura en niveles 1-14. Se desbloquean a partir del nivel 15-25.|r", 1, 1, 1, true)
                    GameTooltip:Show()
                end
                return
            end
            GameTooltip:SetOwner(selfRow, "ANCHOR_RIGHT")
            if selfRow.itemLink then
                GameTooltip:SetHyperlink(selfRow.itemLink)
            else
                GameTooltip:SetItemByID(selfRow.itemID)
            end

            local meta = ns.GetBiSItemMetadata(selfRow.itemID)
            if meta then
                GameTooltip:AddLine(" ")
                GameTooltip:AddDoubleLine("|cFFFFD100Ranura:|r " .. slotInfo.name, "|cFFFFD100ID:|r |cFFFFFFFF" .. selfRow.itemID .. "|r")
                if meta.type == "Purchase" then
                    GameTooltip:AddDoubleLine("|cFFFFD100Comerciante:|r " .. meta.source, "|cFFFFD100Zona:|r " .. meta.zone)
                    GameTooltip:AddDoubleLine("|cFFFFD100Precio:|r " .. meta.drop, "|cFFFFD100Tipo:|r Venta")
                else
                    GameTooltip:AddDoubleLine("|cFFFFD100Fuente / Jefe:|r " .. meta.source, "|cFFFFD100Zona:|r " .. meta.zone)
                    GameTooltip:AddDoubleLine("|cFFFFD100Tipo:|r " .. meta.type, "|cFFFFD100Probabilidad:|r " .. meta.drop)
                end
                local eq, inB = ns.GetPlayerItemStatus(selfRow.itemID)
                local stStr = eq and "|cFF00FF00Equipado actualmente|r" or (inB and "|cFF00CCFFEn tus bolsas|r" or "|cFFFF5555Pendiente de obtener|r")
                GameTooltip:AddDoubleLine("|cFFFFD100Estado de posesión:|r", stStr)

                if ns.GetSlotUpgrade then
                    local pClass = (UnitClassBase and UnitClassBase("player")) or select(2, UnitClass("player")) or "WARRIOR"
                    local pctUpgrade, _, candScore, eqScore = ns.GetSlotUpgrade(slotInfo.key, selfRow.itemID, pClass, selectedBiSSpec)
                    if pctUpgrade and pctUpgrade > 0 then
                        GameTooltip:AddLine(" ")
                        GameTooltip:AddDoubleLine("|cFF00FF00▲ Mejora (StatWeights):|r", string.format("|cFF00FF00+%.1f%%|r", pctUpgrade))
                        GameTooltip:AddDoubleLine("|cFF888888Puntaje EP Sixty/Pawn:|r", string.format("%.1f vs %.1f equipado", candScore or 0, eqScore or 0))
                    elseif eq then
                        GameTooltip:AddDoubleLine("|cFF00FF00Puntaje BiS (Equipado):|r", string.format("%.1f EP", candScore or 0))
                    end
                end

                if _G.AtlasLoot then
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("|cFF00FFCCAlt+Clic:|r Buscar este objeto en AtlasLoot Classic", 0.6, 0.8, 1)
                end
            end
            GameTooltip:Show()
        end)

        row:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        row:SetScript("OnClick", function(selfRow)
            if IsAltKeyDown() and ns.OpenInAtlasLoot and selfRow.itemID and selfRow.itemID > 0 then
                local meta = ns.GetBiSItemMetadata(selfRow.itemID)
                local name = selfRow.itemLink or (meta and meta.name)
                if ns.OpenInAtlasLoot(name, selfRow.itemID) then
                    return
                end
            end
            MainUI:SelectBiSSlot(slotInfo.key)
        end)

        row:SetScript("OnDoubleClick", function()
            MainUI:SelectBiSSlot(slotInfo.key)
            MainUI:SetBiSWaypoint()
        end)

        bisRowFrames[slotInfo.key] = row
        yOffset = yOffset - 22
    end

    content:SetHeight(math.max(10, -yOffset))

    -- 3. Overlay de carga y precarga asíncrona de objetos BiS
    local loadingOverlay = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    loadingOverlay:SetPoint("TOPLEFT", scroll, "TOPLEFT", 0, 0)
    loadingOverlay:SetPoint("BOTTOMRIGHT", scroll, "BOTTOMRIGHT", 18, 0)
    loadingOverlay:SetFrameLevel(scroll:GetFrameLevel() + 25)
    loadingOverlay:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    loadingOverlay:SetBackdropColor(0.04, 0.06, 0.09, 0.94)
    loadingOverlay:SetBackdropBorderColor(0.0, 0.8, 0.7, 0.7)

    -- Spinner giratorio
    local spinner = loadingOverlay:CreateTexture(nil, "ARTWORK")
    spinner:SetSize(28, 28)
    spinner:SetPoint("CENTER", loadingOverlay, "CENTER", 0, 26)
    spinner:SetTexture("Interface\\Icons\\spell_holy_magicalsentry")
    loadingOverlay.spinner = spinner

    local spinAngle = 0
    loadingOverlay:SetScript("OnUpdate", function(self, elapsed)
        spinAngle = (spinAngle + elapsed * 240) % 360
        if spinner.SetRotation then
            spinner:SetRotation(math.rad(spinAngle))
        end
    end)

    -- Título de carga
    local loadTitle = loadingOverlay:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    loadTitle:SetPoint("TOP", spinner, "BOTTOM", 0, -8)
    loadTitle:SetText("|cFFFFD100Analizando equipamiento y base de datos...|r")
    loadingOverlay.title = loadTitle

    -- Subtítulo / estado
    local loadStatus = loadingOverlay:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    loadStatus:SetPoint("TOP", loadTitle, "BOTTOM", 0, -4)
    loadStatus:SetText("|cFF00FFCCCargando objetos de la base de datos...|r")
    loadingOverlay.status = loadStatus

    -- Barra de progreso
    local progressBar = CreateFrame("StatusBar", nil, loadingOverlay, "BackdropTemplate")
    progressBar:SetSize(260, 10)
    progressBar:SetPoint("TOP", loadStatus, "BOTTOM", 0, -8)
    progressBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    progressBar:SetStatusBarColor(0.0, 0.9, 0.8, 1)
    progressBar:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    progressBar:SetBackdropColor(0.1, 0.12, 0.15, 0.9)
    progressBar:SetBackdropBorderColor(0.2, 0.25, 0.3, 0.8)
    progressBar:SetMinMaxValues(0, 1)
    progressBar:SetValue(0)

    local barText = progressBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    barText:SetPoint("CENTER", progressBar, "CENTER", 0, 0)
    barText:SetText("0%")
    loadingOverlay.bar = progressBar
    loadingOverlay.barText = barText

    loadingOverlay:Hide()
    parent.loadingOverlay = loadingOverlay
end

function MainUI:SetBiSMode(mode)
    selectedBiSMode = mode or "gear"
    local view = viewsByKey["bis"] or views[tabIndexByKey["bis"] or 2]
    if view then
        if view.radioGear then
            view.radioGear:SetChecked(selectedBiSMode == "gear")
            if view.radioGear.text then
                view.radioGear.text:SetText(selectedBiSMode == "gear" and "|cFFFFD100Equipo BiS|r" or "|cFFFFFFFFEquipo BiS|r")
            end
        end
        if view.radioEnchants then
            view.radioEnchants:SetChecked(selectedBiSMode == "enchants")
            if view.radioEnchants.text then
                view.radioEnchants.text:SetText(selectedBiSMode == "enchants" and "|cFFFFD100Encantamientos Óptimos|r" or "|cFFFFFFFFEncantamientos Óptimos|r")
            end
        end
        if view.modeBadge then
            if selectedBiSMode == "enchants" then
                view.modeBadge:SetText("|cFF00FFCCModo: Encantamientos|r")
            else
                view.modeBadge:SetText("|cFF888888Modo: Equipo|r")
            end
        end
    end

    if selectedBiSMode == "enchants" then
        SetColumnHeaders("Ranura", 80, 0, "Encantamiento Óptimo", 295, 81, "Fuente", 142, 378, "RIGHT")
    else
        SetColumnHeaders("Ranura", 80, 0, "Objetos BiS", 295, 81, "Estado", 142, 378, "RIGHT")
    end

    self:UpdateBiSView()
    self:SelectBiSSlot(selectedBiSSlot or "Head")
    self:UpdateBottomButtons()
end

--- Actualiza dinámicamente el subtítulo de la cabecera con la prioridad de estadísticas y caps de la clase
function MainUI:UpdateSubtitle()
    if not mainFrame or not mainFrame.subStatus then return end
    local _, playerClass = UnitClass("player")
    local spec = selectedBiSSpec
    if not spec or spec == "" then
        spec = ns.GetClassDefaultEnchantSpec and ns.GetClassDefaultEnchantSpec(playerClass)
    end
    if ns.GetSpecSubtitle then
        mainFrame.subStatus:SetText(ns.GetSpecSubtitle(playerClass, spec))
    else
        mainFrame.subStatus:SetText("WoW Classic Forever · Servidor Activo")
    end
end

function MainUI:UpdateBiSView()
    local view = viewsByKey["bis"] or views[tabIndexByKey["bis"] or 2]
    if not view then return end

    local _, playerClass = UnitClass("player")
    playerClass = playerClass or "WARRIOR"

    -- ---------------------------------------------------------------------
    -- MODO ENCANTAMIENTOS Y REFUERZOS ÓPTIMOS (WoW Classic)
    -- ---------------------------------------------------------------------
    if selectedBiSMode == "enchants" then
        local localizedClass, playerClassRaw = UnitClass("player")
        localizedClass = localizedClass or playerClassRaw or "Aventurero"
        local playerLevel = UnitLevel("player") or 1

        if not selectedEnchantSpec then
            selectedEnchantSpec = ns.GetClassDefaultEnchantSpec(playerClass)
        end
        if not selectedBiSBracket then
            selectedBiSBracket = ns.GetDefaultBiSBracket(playerLevel)
        end

        local enchantsMap, specInfo, catData = ns.GetEnchantsForSpec(selectedEnchantSpec, selectedBiSBracket)
        local specDisplayName = specInfo and specInfo.name or "Especialización"

        -- Buscar nombre legible del tramo (bracket)
        local bracketDisplayName = selectedBiSBracket
        local bracketShortName = selectedBiSBracket
        for _, b in ipairs(catData and catData.brackets or {}) do
            if b.key == selectedBiSBracket then
                bracketDisplayName = b.name
                bracketShortName = b.short or b.name
                break
            end
        end

        if view.tierBtn then
            view.tierBtn:SetText(bracketShortName)
        end
        if view.specBtn then
            view.specBtn:SetText(specDisplayName:gsub("%s*%(.-%)", ""))
        end

        local playerName = UnitName("player") or "Jugador"
        if mainFrame and mainFrame.heroTitle then
            if selectedBiSBracket == "1-14" then
                mainFrame.heroTitle:SetText(string.format(
                    "|cFFFFD100%s %s (%d)|r · |cFF888888Sin encantamientos (Nv. 1-14)|r",
                    playerName,
                    localizedClass,
                    playerLevel
                ))
            else
                mainFrame.heroTitle:SetText(string.format(
                    "|cFFFFD100%s %s (%d)|r · |cFF00FFCC%s (%s)|r",
                    playerName,
                    localizedClass,
                    playerLevel,
                    specDisplayName,
                    bracketShortName
                ))
            end
        end

        for _, slotInfo in ipairs(ns.Data.BiSSlotsOrder or {}) do
            local rFrame = bisRowFrames[slotInfo.key]
            if rFrame then
                local slotKey = slotInfo.key
                local enchantID = enchantsMap and (enchantsMap[slotKey] or (slotKey == "Relic" and enchantsMap["Ranged"])) or 0
                rFrame.mode = "enchants"
                rFrame.enchantID = enchantID
                rFrame.itemID = (enchantID > 0) and enchantID or nil
                rFrame.slotName = slotInfo.name
                rFrame.slotKey = slotKey
                rFrame.itemLink = nil

                if selectedBiSBracket == "1-14" then
                    rFrame.enchantMeta = nil
                    rFrame.icon:SetTexture("Interface\\PaperDoll\\UI-Backpack-EmptySlot")
                    rFrame.itemLabel:SetText("|cFF777777(No recomendado en Nv. 1-14)|r")
                    rFrame.statusLabel:SetText("|cFF555555N/A|r")
                elseif enchantID and enchantID > 0 then
                    local meta = ns.GetEnchantMetadata(enchantID)
                    rFrame.enchantMeta = meta
                    rFrame.icon:SetTexture(meta.icon or "Interface\\Icons\\spell_holy_magicalsentry")

                    local qc = "|cFFFFFFFF"
                    if meta.quality == 4 then qc = "|cFFA335EE"
                    elseif meta.quality == 3 then qc = "|cFF0070DD"
                    elseif meta.quality == 2 then qc = "|cFF1EFF00"
                    end

                    rFrame.itemLabel:SetText(string.format("%s%s|r |cFFFFD100(%s)|r", qc, meta.name, meta.effect))

                    local shortSrc = "Fórmula"
                    if meta.type:find("Peletería") or meta.type:find("Refuerzo") then
                        shortSrc = "|cFFD28C47Peletería|r"
                    elseif meta.type:find("Arcano") or meta.type:find("Libram") then
                        shortSrc = "|cFF00FFCCLibram|r"
                    elseif meta.type:find("Inscripción") or meta.type:find("Alba") then
                        shortSrc = "|cFF88DDFFAlba Arg.|r"
                    elseif meta.type:find("Raid") then
                        shortSrc = "|cFFFF8000Raid MC|r"
                    elseif meta.type:find("Instructor") then
                        shortSrc = "|cFF00FF00Instructor|r"
                    elseif meta.type:find("Ingeniería") then
                        shortSrc = "|cFFFFAA00Ingeniería|r"
                    else
                        shortSrc = "|cFFFFD100Fórmula|r"
                    end
                    rFrame.statusLabel:SetText(shortSrc)
                else
                    rFrame.enchantMeta = nil
                    rFrame.icon:SetTexture("Interface\\PaperDoll\\UI-Backpack-EmptySlot")
                    rFrame.itemLabel:SetText("|cFF777777Sin encantamiento (WoW Classic)|r")
                    rFrame.statusLabel:SetText("|cFF555555N/A|r")
                end
            end
        end

        MainUI:SelectBiSSlot(selectedBiSSlot or "Head")
        return
    end

    -- ---------------------------------------------------------------------
    -- MODO EQUIPO BiS HABITUAL (VALIDACIÓN CANÓNICA Y PRECARGA ASÍNCRONA)
    -- ---------------------------------------------------------------------
    if view.loadingOverlay then
        view.loadingOverlay:Hide()
    end

    local classData = ns.Data.BiS and (ns.Data.BiS[playerClass] or ns.Data.BiS["WARRIOR"])
    if not classData then return end

    local playerLevel = UnitLevel("player") or 1
    if not selectedBiSBracket then
        selectedBiSBracket = ns.GetDefaultBiSBracket(playerLevel)
    end
    if not selectedBiSSpec then
        selectedBiSSpec = classData.specs[1] and classData.specs[1].key or "fury"
    end

    -- Actualizar etiqueta de botones de selección
    local bracketName = selectedBiSBracket
    local bracketShort = selectedBiSBracket
    for _, b in ipairs(classData.brackets or {}) do
        if b.key == selectedBiSBracket then
            bracketName = b.name
            if b.key == "raid-p1" then
                bracketShort = "Raid Nivel 60"
            elseif b.key == "pre-raid" then
                bracketShort = "Nivel 53-60"
            elseif b.key == "1-14" then
                bracketShort = "Nivel 1-14"
            else
                bracketShort = b.name:gsub("%s*%(.-%)", "")
            end
            break
        end
    end

    local specName = selectedBiSSpec
    for _, s in ipairs(classData.specs or {}) do
        if s.key == selectedBiSSpec then
            specName = s.name
            break
        end
    end

    if view.tierBtn then
        view.tierBtn:SetText(bracketShort)
    end
    if view.specBtn then
        view.specBtn:SetText(specName:gsub("%s*%(.-%)", ""))
    end

    -- Actualizar subtítulo dinámico con prioridad de atributos y caps de la especialización seleccionada
    self:UpdateSubtitle()

    -- Nivel 1-14 o forzado inmediato: no requiere precarga pesada
    if selectedBiSBracket == "1-14" or forceImmediate then
        if view.loadingOverlay then view.loadingOverlay:Hide() end
        self:RenderResolvedBiS(playerClass, selectedBiSBracket, selectedBiSSpec, playerLevel)
        return
    end

    -- Recopilar todos los itemIDs candidatos para este tramo y especialización
    local itemIDs = {}
    local validator = ns.Validator or (addon and addon.Validator) or (_G.AwakeningData and _G.AwakeningData.Validator)
    if validator and validator.GetItemsToPreload then
        itemIDs = validator:GetItemsToPreload(playerClass, selectedBiSBracket, selectedBiSSpec)
    end

    local uncached = {}
    local totalCount = 0
    for _, id in ipairs(itemIDs) do
        if id and id > 0 then
            totalCount = totalCount + 1
            local name = GetItemInfo(id)
            if not name then
                uncached[id] = true
            end
        end
    end

    local uncachedCount = 0
    for _ in pairs(uncached) do uncachedCount = uncachedCount + 1 end

    -- Si todos los objetos están cacheados, renderizar inmediatamente sin demora
    if uncachedCount == 0 then
        if view.loadingOverlay then view.loadingOverlay:Hide() end
        self:RenderResolvedBiS(playerClass, selectedBiSBracket, selectedBiSSpec, playerLevel)
        return
    end

    -- Mostrar la pantalla de carga (overlay)
    if view.loadingOverlay then
        view.loadingOverlay:Show()
        view.loadingOverlay.title:SetText("|cFFFFD100Analizando equipamiento y base de datos...|r")
        view.loadingOverlay.status:SetText(string.format("|cFF00FFCCCargando objetos... (%d restantes)|r", uncachedCount))
        local loaded = totalCount - uncachedCount
        view.loadingOverlay.bar:SetMinMaxValues(0, totalCount)
        view.loadingOverlay.bar:SetValue(loaded)
        local pct = totalCount > 0 and math.floor((loaded / totalCount) * 100) or 0
        view.loadingOverlay.barText:SetText(string.format("%d / %d (%d%%)", loaded, totalCount, pct))
    end

    bisPreloadBatchID = (bisPreloadBatchID or 0) + 1
    local currentBatch = bisPreloadBatchID

    currentPreloadState = {
        batchID = currentBatch,
        uncached = uncached,
        totalCount = totalCount,
        playerClass = playerClass,
        bracket = selectedBiSBracket,
        spec = selectedBiSSpec,
        level = playerLevel,
    }

    -- Solicitar la carga de cada ítem no cargado en memoria mediante C_Item.RequestLoadItemDataByID
    for id in pairs(uncached) do
        if C_Item and C_Item.RequestLoadItemDataByID then
            pcall(C_Item.RequestLoadItemDataByID, id)
        elseif Item and Item.CreateFromItemID then
            pcall(function()
                local itemObj = Item:CreateFromItemID(id)
                if itemObj and itemObj.ContinueOnItemLoad then
                    itemObj:ContinueOnItemLoad(function()
                        if bisPreloadBatchID == currentBatch then
                            MainUI:OnPreloadItemReceived(id)
                        end
                    end)
                end
            end)
        end
    end

    -- Temporizador de seguridad (máximo 2.0s para garantizar fluidez y respuesta)
    if not bisPreloadTimerFrame then
        bisPreloadTimerFrame = CreateFrame("Frame")
    end

    local timerElapsed = 0
    bisPreloadTimerFrame:SetScript("OnUpdate", function(selfFrame, elapsed)
        timerElapsed = timerElapsed + elapsed
        if bisPreloadBatchID ~= currentBatch or not currentPreloadState then
            selfFrame:SetScript("OnUpdate", nil)
            return
        end

        local anyResolved = false
        for id in pairs(currentPreloadState.uncached) do
            local name = GetItemInfo(id)
            if name then
                currentPreloadState.uncached[id] = nil
                anyResolved = true
            end
        end

        local rem = 0
        for _ in pairs(currentPreloadState.uncached) do rem = rem + 1 end

        if anyResolved and view.loadingOverlay and view.loadingOverlay:IsShown() then
            local loaded = currentPreloadState.totalCount - rem
            local tot = currentPreloadState.totalCount
            view.loadingOverlay.bar:SetValue(loaded)
            local pct = tot > 0 and math.floor((loaded / tot) * 100) or 100
            view.loadingOverlay.barText:SetText(string.format("%d / %d (%d%%)", loaded, tot, pct))
            view.loadingOverlay.status:SetText(string.format("|cFF00FFCCCargando objetos... (%d restantes)|r", rem))
        end

        if rem == 0 or timerElapsed >= 2.0 then
            selfFrame:SetScript("OnUpdate", nil)
            if view.loadingOverlay then view.loadingOverlay:Hide() end
            local state = currentPreloadState
            currentPreloadState = nil
            if state then
                MainUI:RenderResolvedBiS(state.playerClass, state.bracket, state.spec, state.level)
            end
        end
    end)
end

--- Recepción asíncrona de evento GET_ITEM_INFO_RECEIVED durante la precarga
function MainUI:OnPreloadItemReceived(itemID)
    if not currentPreloadState or not itemID then return end
    if currentPreloadState.uncached and currentPreloadState.uncached[itemID] then
        currentPreloadState.uncached[itemID] = nil
        local rem = 0
        for _ in pairs(currentPreloadState.uncached) do rem = rem + 1 end

        local view = viewsByKey["bis"] or views[tabIndexByKey["bis"] or 2]
        if view and view.loadingOverlay and view.loadingOverlay:IsShown() then
            local loaded = currentPreloadState.totalCount - rem
            local tot = currentPreloadState.totalCount
            view.loadingOverlay.bar:SetValue(loaded)
            local pct = tot > 0 and math.floor((loaded / tot) * 100) or 100
            view.loadingOverlay.barText:SetText(string.format("%d / %d (%d%%)", loaded, tot, pct))
            view.loadingOverlay.status:SetText(string.format("|cFF00FFCCCargando objetos... (%d restantes)|r", rem))
        end

        if rem == 0 then
            if bisPreloadTimerFrame then bisPreloadTimerFrame:SetScript("OnUpdate", nil) end
            if view and view.loadingOverlay then view.loadingOverlay:Hide() end
            local state = currentPreloadState
            currentPreloadState = nil
            if state then
                self:RenderResolvedBiS(state.playerClass, state.bracket, state.spec, state.level)
            end
        end
    end
end

--- Renderiza la tabla de objetos BiS con los mejores candidatos validados
function MainUI:RenderResolvedBiS(playerClass, bracketKey, specKey, playerLevel)
    local view = viewsByKey["bis"] or views[tabIndexByKey["bis"] or 2]
    if not view then return end

    playerLevel = tonumber(playerLevel) or (UnitLevel and UnitLevel("player")) or 1
    playerClass = (playerClass or (UnitClassBase and UnitClassBase("player")) or select(2, UnitClass("player")) or "WARRIOR"):upper()

    local classData = ns.Data.BiS and (ns.Data.BiS[playerClass] or ns.Data.BiS["WARRIOR"])
    if not classData then return end

    local bracketMaxLevel = 60
    if classData.brackets then
        for _, b in ipairs(classData.brackets) do
            if b.key == bracketKey then
                bracketMaxLevel = b.maxLevel
                break
            end
        end
    end

    -- 1. Evaluar candidatos canónicos con IsItemEligible y seleccionar el mejor por StatWeights
    local resolvedItems = {}
    local assignedUniqueItems = {}
    local validator = ns.Validator or (addon and addon.Validator) or (_G.AwakeningData and _G.AwakeningData.Validator)
    for _, slotInfo in ipairs(ns.Data.BiSSlotsOrder or {}) do
        local bestID, bestScore, bestMeta, reason
        if validator and validator.GetBestItemForSlot then
            bestID, bestScore, bestMeta, reason = validator:GetBestItemForSlot(playerClass, bracketKey, specKey, slotInfo.key, playerLevel, bracketMaxLevel, assignedUniqueItems)
        else
            local bracketSets = classData.sets and (classData.sets[bracketKey] or classData.sets["pre-raid"])
            local activeSet = bracketSets and bracketSets[specKey]
            bestID = activeSet and activeSet[slotInfo.key] or 0
            if assignedUniqueItems[bestID] then
                bestID = 0
            end
        end

        if bestID and bestID > 0 then
            if validator and validator.IsItemUniqueEquipped and validator:IsItemUniqueEquipped(bestID) then
                assignedUniqueItems[bestID] = true
            end
        end

        resolvedItems[slotInfo.key] = {
            itemID = bestID or 0,
            score = bestScore or 0,
            meta = bestMeta,
            reason = reason or "OK"
        }
    end

    -- 2. Detectar si el arma principal es de dos manos para ajustar Secundaria
    local is2HActive = false
    local mhRes = resolvedItems["MainHand"]
    if mhRes and mhRes.itemID and mhRes.itemID > 0 then
        local _, _, _, _, _, _, _, _, mhLoc = GetItemInfo(mhRes.itemID)
        if mhLoc == "INVTYPE_2HWEAPON" then
            is2HActive = true
        end
    end

    -- 3. Métrica Hero superior (Estilo Olympus) calculada sobre ranuras activas reales
    local acquired = 0
    local total = 0
    for _, slotInfo in ipairs(ns.Data.BiSSlotsOrder or {}) do
        local is2HSlot = (slotInfo.key == "SecondaryHand" and is2HActive)
        if not is2HSlot then
            local res = resolvedItems[slotInfo.key]
            if res and res.itemID and res.itemID > 0 then
                total = total + 1
                local eq, inB = ns.GetPlayerItemStatus(res.itemID)
                if eq or inB then
                    acquired = acquired + 1
                end
            elseif selectedBiSBracket ~= "1-14" then
                total = total + 1
            end
        end
    end
    local pct = total > 0 and math.floor((acquired / total) * 100) or 0
    local playerName = UnitName("player") or "Jugador"
    local localizedClass = UnitClass("player") or (classData and classData.name) or playerClass
    if mainFrame and mainFrame.heroTitle then
        mainFrame.heroTitle:SetText(string.format(
            "|cFFFFD100%s %s (%d)|r · |cFFFFFFFF%d/%d (%d%%)|r",
            playerName,
            localizedClass,
            playerLevel,
            acquired,
            total,
            pct
        ))
    end

    -- 4. Renderizado nítido de las filas de la tabla
    for _, slotInfo in ipairs(ns.Data.BiSSlotsOrder or {}) do
        local rFrame = bisRowFrames[slotInfo.key]
        if rFrame then
            local res = resolvedItems[slotInfo.key]
            local itemID = res and res.itemID or 0

            rFrame.mode = "gear"
            rFrame.enchantID = nil
            rFrame.enchantMeta = nil
            rFrame.itemID = (itemID > 0) and itemID or nil
            rFrame.slotName = slotInfo.name
            rFrame.slotKey = slotInfo.key
            rFrame.reason = res and res.reason or "OK"

            if itemID and itemID > 0 then
                local meta = res.meta or ns.GetBiSItemMetadata(itemID)
                local isEquipped, inBags = ns.GetPlayerItemStatus(itemID)
                local _, _, _, _, itemMinLevel = GetItemInfo(itemID)
                if not itemMinLevel and meta and meta.minLevel then
                    itemMinLevel = meta.minLevel
                end
                rFrame.itemMinLevel = itemMinLevel

                -- Texto y color de estado (Equipado, En Bolsas, Req. Nivel, Req. Profesión o % Mejora)
                if isEquipped then
                    rFrame.statusLabel:SetText("|cFF00FF00Equipado|r")
                elseif inBags then
                    rFrame.statusLabel:SetText("|cFF00CCFFEn Bolsas|r")
                elseif res.reason == "PROFESSION_LOCKED" or (res.meta and res.meta.isProfLocked) then
                    rFrame.statusLabel:SetText("|cFFFF8800Req. Profesión|r")
                elseif itemMinLevel and itemMinLevel > playerLevel then
                    rFrame.statusLabel:SetText(string.format("|cFFFFAA00Req. Nv. %d|r", itemMinLevel))
                else
                    local statTxt = "|cFFFF5555Falta|r"
                    if ns.GetSlotUpgrade then
                        local pctUpgrade = ns.GetSlotUpgrade(slotInfo.key, itemID, playerClass, specKey)
                        if pctUpgrade and pctUpgrade > 0 then
                            statTxt = string.format("|cFF00FF00+%.0f%%|r", pctUpgrade)
                        end
                    end
                    rFrame.statusLabel:SetText(statTxt)
                end

                -- Consulta segura: gracias a la precarga previa, la información ya reside en el cliente
                local name, link, quality, texture = SafeGetItemInfo(itemID)
                if not texture then
                    texture = SafeGetItemIcon(itemID)
                end

                if link and texture then
                    rFrame.itemLink = link
                    rFrame.icon:SetTexture(texture)
                    rFrame.itemLabel:SetText(link)
                elseif name and texture then
                    local colorHex = (ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality] and ITEM_QUALITY_COLORS[quality].hex) or "|cFFFFFFFF"
                    local formattedLink = string.format("%s[%s]|r", colorHex, name)
                    rFrame.itemLink = formattedLink
                    rFrame.icon:SetTexture(texture)
                    rFrame.itemLabel:SetText(formattedLink)
                else
                    local fastIcon = SafeGetItemIcon(itemID)
                    rFrame.icon:SetTexture(fastIcon)
                    local fallbackName = meta and meta.name or ("Objeto #" .. itemID)
                    rFrame.itemLabel:SetText("|cFF0070DD[" .. fallbackName .. "]|r")
                end
            else
                local is2H = (slotInfo.key == "SecondaryHand" and is2HActive)
                rFrame.itemMinLevel = nil
                rFrame.icon:SetTexture("Interface\\PaperDoll\\UI-Backpack-EmptySlot")
                if is2H then
                    rFrame.itemLabel:SetText("|cFF888888(Arma 2M equipada)|r")
                elseif selectedBiSBracket == "1-14" then
                    rFrame.itemLabel:SetText("|cFF666666(Sin objeto en Nv. 1-14)|r")
                else
                    rFrame.itemLabel:SetText("|cFF666666(Ranura vacía)|r")
                end
                rFrame.statusLabel:SetText("")
                rFrame.itemLink = nil
            end
        end
    end

    MainUI:SelectBiSSlot(selectedBiSSlot or "Head")
end

--- Actualiza de forma ligera los estados de equipo y bolsas sin reiniciar la vista completa
function MainUI:UpdateBiSItemStatuses()
    if selectedBiSMode ~= "gear" then return end
    local playerLevel = UnitLevel("player") or 1
    for _, slotInfo in ipairs(ns.Data.BiSSlotsOrder or {}) do
        local rFrame = bisRowFrames[slotInfo.key]
        if rFrame and rFrame.itemID and rFrame.itemID > 0 then
            local isEquipped, inBags = ns.GetPlayerItemStatus(rFrame.itemID)
            if isEquipped then
                rFrame.statusLabel:SetText("|cFF00FF00Equipado|r")
            elseif inBags then
                rFrame.statusLabel:SetText("|cFF00CCFFEn Bolsas|r")
            elseif rFrame.reason == "PROFESSION_LOCKED" then
                rFrame.statusLabel:SetText("|cFFFF8800Req. Profesión|r")
            elseif rFrame.itemMinLevel and rFrame.itemMinLevel > playerLevel then
                rFrame.statusLabel:SetText(string.format("|cFFFFAA00Req. Nv. %d|r", rFrame.itemMinLevel))
            else
                local statTxt = "|cFFFF5555Falta|r"
                if ns.GetSlotUpgrade then
                    local pctUpgrade = ns.GetSlotUpgrade(slotInfo.key, rFrame.itemID, playerClass, selectedBiSSpec)
                    if pctUpgrade and pctUpgrade > 0 then
                        statTxt = string.format("|cFF00FF00+%.0f%%|r", pctUpgrade)
                    end
                end
                rFrame.statusLabel:SetText(statTxt)
            end
        end
    end
end

function MainUI:SelectBiSSlot(slotKey)
    selectedBiSSlot = slotKey
    for sKey, rFrame in pairs(bisRowFrames) do
        if rFrame.selection then
            rFrame.selection:SetShown(sKey == slotKey)
        end
    end

    local rFrame = bisRowFrames[slotKey]

    -- ---------------------------------------------------------------------
    -- DETALLES PARA MODO ENCANTAMIENTOS
    -- ---------------------------------------------------------------------
    if selectedBiSMode == "enchants" then
        if selectedBiSBracket == "1-14" then
            if mainFrame and mainFrame.detailTitle and mainFrame.detailText then
                mainFrame.detailTitle:SetText(string.format("|cFFFFD100%s · Sin Encantamientos Recomendados (Nv. 1-14)|r", rFrame and rFrame.slotName or slotKey))
                self:ShowDetailRewards(nil)
                mainFrame.detailText:SetText(
                    "|cFFFFFF00En el rango de Nivel 1 a 14 no se recomienda encantar el equipo.|r\n\n" ..
                    "• |cFFFFFFFFRápida rotación de equipo:|r Las piezas obtenidas en estos niveles iniciales se reemplazan con gran velocidad mediante misiones tempranas y botín de mundo.\n" ..
                    "• |cFFFFFFFFPrioridad de economía:|r Se aconseja guardar el dinero para adquirir los nuevos rangos de hechizos y habilidades con tus instructores de clase.\n" ..
                    "• |cFF00FFCCRecomendación:|r Empieza a encantar tu equipo a partir del tramo |cFFFFD100Nivel 15-25|r (con los primeros refuerzos de armadura y las mazmorras iniciales como Minas de la Muerte o Cuevas de los Lamentos)."
                )
            end
            return
        end

        local enchantID = rFrame and rFrame.enchantID
        if not enchantID or enchantID == 0 then
            if mainFrame and mainFrame.detailTitle and mainFrame.detailText then
                mainFrame.detailTitle:SetText(string.format("|cFFFFD100%s · Sin encantamiento en Classic|r", rFrame and rFrame.slotName or slotKey))
                self:ShowDetailRewards(nil)
                mainFrame.detailText:SetText(
                    "Esta ranura de equipo no cuenta con encantamientos disponibles en WoW Classic Fase 1.\n" ..
                    "|cFF888888(Los encantamientos de anillos y ranuras menores fueron introducidos en expansiones posteriores como TBC y WotLK).|r"
                )
            end
            return
        end

        local meta = rFrame.enchantMeta or ns.GetEnchantMetadata(enchantID)
        if mainFrame and mainFrame.detailTitle and mainFrame.detailText then
            local qc = (meta.quality == 4 and "|cFFA335EE") or (meta.quality == 3 and "|cFF0070DD") or (meta.quality == 2 and "|cFF1EFF00") or "|cFFFFFFFF"
            mainFrame.detailTitle:SetText(string.format("%s%s|r · |cFFFFD100%s|r", qc, meta.name, rFrame.slotName or slotKey))

            local enchantReward = {
                {
                    itemID = enchantID,
                    isEnchant = true,
                    title = qc .. meta.name .. "|r",
                    name = qc .. meta.name .. "|r",
                    icon = meta.icon,
                    quality = meta.quality,
                    desc = string.format("Efecto: %s · %s", meta.effect, meta.type),
                    extraLines = {
                        { text = "Fuente: " .. meta.source, r = 1, g = 0.82, b = 0, wrap = true },
                        { text = "Reactivos: " .. meta.materials, r = 0.5, g = 0.9, b = 1, wrap = true }
                    }
                }
            }
            self:ShowDetailRewards(enchantReward, "|cFFFFD100Encantamiento Óptimo:|r")

            mainFrame.detailText:SetText(string.format(
                "Efecto Óptimo: |cFF00FF00%s|r  ·  Tipo: |cFFFFFFFF%s|r\n" ..
                "Fuente / Procedencia: |cFFFFD100%s|r\n" ..
                "Reactivos necesarios: |cFF00FFCC%s|r\n" ..
                "Detalle: |cFFFFFFFF%s|r",
                meta.effect,
                meta.type,
                meta.source,
                meta.materials,
                meta.desc or "Encantamiento óptimo para Fase 1 / Pre-Raid."
            ))
        end
        return
    end

    -- ---------------------------------------------------------------------
    -- DETALLES PARA MODO EQUIPO BiS
    -- ---------------------------------------------------------------------
    if not rFrame or not rFrame.itemID or rFrame.itemID == 0 then
        if mainFrame and mainFrame.detailTitle and mainFrame.detailText then
            if selectedBiSBracket == "1-14" then
                mainFrame.detailTitle:SetText(string.format("|cFFFFD100%s · Sin objeto en Nivel 1-14|r", rFrame and rFrame.slotName or slotKey))
                self:ShowDetailRewards(nil)
                mainFrame.detailText:SetText(
                    "|cFFFFFF00Ranura no disponible en Nivel 1-14.|r\n\n" ..
                    "En WoW Classic original no existen piezas de equipo para esta ranura (Casco, Cuello, Hombreras, Anillos, Abalorios) que se puedan conseguir o equipar entre los niveles 1 y 14.\n\n" ..
                    "|cFF88DDFFConsejo:|r Estas ranuras comenzarán a llenarse a partir del tramo |cFFFFD100Nivel 15-25|r mediante misiones de clase y las primeras mazmorras (Minas de la Muerte, Cuevas de los Lamentos, Castillo de Colmillo Oscuro)."
                )
            else
                mainFrame.detailTitle:SetText(string.format("|cFFFFD100%s · Sin opción viable para tu clase/nivel|r", rFrame and rFrame.slotName or slotKey))
                self:ShowDetailRewards(nil)
                mainFrame.detailText:SetText(
                    "|cFFFFFF00No hay objetos Best-in-Slot compatibles disponibles para esta ranura en tu nivel actual.|r\n\n" ..
                    "• El motor de validación canónica ha evaluado los candidatos y filtró piezas incongruentes (ej. armaduras no permitidas para tu clase, ranuras incompatibles o requisitos de profesión activa no cumplidos).\n" ..
                    "• Esta casilla se actualizará automáticamente a medida que subas de nivel o aprendas la profesión correspondiente."
                )
            end
        end
        return
    end

    local itemID = rFrame.itemID
    local meta = ns.GetBiSItemMetadata(itemID)
    local eq, inB = ns.GetPlayerItemStatus(itemID)
    local playerLevel = UnitLevel("player") or 1
    local statusStr = eq and "|cFF00FF00Equipado actualmente en tu personaje|r" or (inB and "|cFF00CCFFEn tus bolsas (listo para usar)|r" or "|cFFFF5555Pendiente de conseguir|r")

    if not eq and not inB then
        if rFrame.reason == "PROFESSION_LOCKED" then
            statusStr = "|cFFFF8800Req. Profesión Activa (ej. Ingeniería)|r"
        elseif rFrame.itemMinLevel and rFrame.itemMinLevel > playerLevel then
            statusStr = string.format("|cFFFFAA00Pendiente de nivel (Requiere Nivel %d)|r", rFrame.itemMinLevel)
        end
    end

    local nameStr = rFrame.itemLink or (meta and meta.name) or ("Objeto #" .. itemID)

    -- Sinergia con AtlasBIStooltips / AtlasLoot Classic Forever si está cargado
    local atlasNote = ""
    if sliccNote and sliccNote.Items and sliccNote.Items[tostring(itemID)] then
        local _, playerClass = UnitClass("player")
        for uKey, pVal in pairs(sliccNote.Items[tostring(itemID)]) do
            local rec = sliccNote.BIS and sliccNote.BIS[uKey]
            if rec and (not rec.class or rec.class:upper() == playerClass) then
                local specClean = (rec.spec or ""):gsub("_P%d$", "")
                atlasNote = string.format(" · |cFF00FF00AtlasLoot: %s (Rango %s)|r", specClean ~= "" and specClean or "BiS", pVal or "1")
                break
            end
        end
    end

    if mainFrame and mainFrame.detailTitle and mainFrame.detailText then
        mainFrame.detailTitle:SetText(string.format("%s · |cFFFFD100%s|r%s", nameStr, rFrame.slotName or "Ranura", atlasNote))
        
        -- Mostrar botón interactivo del objeto BiS en la caja de detalles
        local bisReward = {
            {
                itemID = itemID,
                name = nameStr,
                quality = meta and meta.quality,
                desc = meta and string.format("Fuente: %s (%s) · Probabilidad: %s", meta.source, meta.zone, meta.drop),
                extraLines = {
                    { text = "Estado de posesión: " .. statusStr, r = 1, g = 0.82, b = 0, wrap = false }
                }
            }
        }
        self:ShowDetailRewards(bisReward, "|cFFFFD100Objeto BiS:|r")

        -- Calcular Mejora de StatWeights y formato según tipo de fuente
        local upgradeLine = ""
        if ns.GetSlotUpgrade then
            local pClass = (UnitClassBase and UnitClassBase("player")) or select(2, UnitClass("player")) or "WARRIOR"
            local pctUpgrade, _, newScore, curScore = ns.GetSlotUpgrade(rFrame.slotKey, itemID, pClass, selectedBiSSpec)
            if pctUpgrade and pctUpgrade > 0 then
                upgradeLine = string.format("\n|cFF00FF00▲ Mejora estimada: +%.1f%%|r (Puntaje EP: %.1f vs %.1f equipado)", pctUpgrade, newScore, curScore)
            elseif eq then
                upgradeLine = string.format("\n|cFF00FF00✔ Objeto BiS equipado actualmente.|r (Puntaje EP: %.1f)", newScore or 0)
            end
        end

        local sourceDesc
        if meta and meta.type == "Purchase" then
            sourceDesc = string.format(
                "Tipo: |cFFFFFF00Compra de Comerciante|r  ·  Precio: |cFFFFD100%s|r\nVendedor: |cFFFFFFFF%s|r  ·  Zona: |cFF00FFCC%s|r\nEstado: %s%s\n|cFF88DDFFConsejo (Nivel 1-14):|r El equipamiento de comerciantes de inicio es la forma más rápida y garantizada de optimizar tus estadísticas antes de las primeras mazmorras.",
                meta.drop or "Monedas",
                meta.source or "Vendedor local",
                meta.zone or "Pueblo Inicial",
                statusStr,
                upgradeLine
            )
        else
            sourceDesc = string.format(
                "Jefe / Fuente: |cFFFFD100%s|r (%s)  ·  Zona: |cFFFFFFFF%s|r\nProbabilidad de caída: |cFFFFD100%s|r\nEstado: %s%s",
                meta and meta.source or "Mundo Clásico",
                meta and meta.type or "Kill",
                meta and meta.zone or "Azeroth",
                meta and meta.drop or "Variable",
                statusStr,
                upgradeLine
            )
        end

        if rFrame.reason == "PROFESSION_LOCKED" then
            sourceDesc = sourceDesc .. "\n|cFFFF8800[Requisito de Profesión: Este objeto requiere una profesión específica activa para poder equiparse (ej. Ingeniería). Se sugiere conseguirlo si dispones de la profesión o buscar piezas alternativas]|r"
        elseif rFrame.itemMinLevel and rFrame.itemMinLevel > playerLevel then
            sourceDesc = sourceDesc .. string.format("\n|cFFFFAA00[Nivel Requerido: Nivel %d (Tu nivel actual es %d). Podrás equipar este objeto BiS al alcanzar dicho nivel]|r", rFrame.itemMinLevel, playerLevel)
        end

        local validator = ns.Validator or (addon and addon.Validator) or (_G.AwakeningData and _G.AwakeningData.Validator)
        if validator and validator.IsItemUniqueEquipped and validator:IsItemUniqueEquipped(itemID) then
            sourceDesc = sourceDesc .. "\n|cFF00CCFF[Propiedad: Objeto Único-Equipado (No se pueden equipar dos piezas idénticas simultáneamente)]|r"
        end

        if _G.AtlasLoot then
            sourceDesc = sourceDesc .. "\n|cFF00FFCC[AtlasLoot detectado: Clic en el icono o Alt+Clic en la lista para ver en AtlasLoot]|r"
        end

        mainFrame.detailText:SetText(sourceDesc)
    end
end

function MainUI:CycleBiSBracket()
    if selectedBiSMode == "enchants" then
        local _, playerClass = UnitClass("player")
        playerClass = playerClass or "WARRIOR"
        local _, _, catData = ns.GetEnchantsForSpec(selectedEnchantSpec or ns.GetClassDefaultEnchantSpec(playerClass))
        local bracketsList = catData and catData.brackets
        if not bracketsList or #bracketsList == 0 then
            bracketsList = {
                { key = "1-14",     short = "Nv. 1-14 (Inicial)" },
                { key = "15-25",    short = "Nv. 15-25 (Inicial)" },
                { key = "26-40",    short = "Nv. 26-40 (Medio)" },
                { key = "41-52",    short = "Nv. 41-52 (Avanzado)" },
                { key = "pre-raid", short = "Nv. 53-60 (Pre-Raid)" },
                { key = "raid-p1",  short = "Nv. 60 (Raid MC)" },
            }
        end

        local currentIdx = 1
        for idx, b in ipairs(bracketsList) do
            if b.key == selectedBiSBracket then
                currentIdx = idx
                break
            end
        end

        local nextIdx = (currentIdx % #bracketsList) + 1
        selectedBiSBracket = bracketsList[nextIdx].key
        self:UpdateBiSView()
        self:UpdateBottomButtons()
        return
    end

    local _, playerClass = UnitClass("player")
    local classData = ns.Data.BiS and (ns.Data.BiS[playerClass] or ns.Data.BiS["WARRIOR"])
    if not classData or not classData.brackets then return end

    local currentIdx = 1
    for idx, b in ipairs(classData.brackets) do
        if b.key == selectedBiSBracket then
            currentIdx = idx
            break
        end
    end

    local nextIdx = (currentIdx % #classData.brackets) + 1
    selectedBiSBracket = classData.brackets[nextIdx].key
    self:UpdateBiSView()
    self:UpdateBottomButtons()
end

function MainUI:CycleBiSSpec(isRightClick)
    if selectedBiSMode == "enchants" then
        local _, playerClass = UnitClass("player")
        playerClass = playerClass or "WARRIOR"

        local specsList
        if isRightClick then
            specsList = ns.GetAllEnchantSpecs()
        else
            specsList = ns.GetEnchantSpecsForClass(playerClass)
            local found = false
            for _, k in ipairs(specsList) do
                if k == selectedEnchantSpec then found = true; break end
            end
            if not found then
                specsList = ns.GetAllEnchantSpecs()
            end
        end

        local currentIdx = 1
        for idx, k in ipairs(specsList) do
            if k == selectedEnchantSpec then
                currentIdx = idx
                break
            end
        end

        local nextIdx = (currentIdx % #specsList) + 1
        selectedEnchantSpec = specsList[nextIdx]
        self:UpdateBiSView()
        return
    end

    local _, playerClass = UnitClass("player")
    local classData = ns.Data.BiS and (ns.Data.BiS[playerClass] or ns.Data.BiS["WARRIOR"])
    if not classData or not classData.specs then return end

    local currentIdx = 1
    for idx, s in ipairs(classData.specs) do
        if s.key == selectedBiSSpec then
            currentIdx = idx
            break
        end
    end

    local nextIdx = (currentIdx % #classData.specs) + 1
    selectedBiSSpec = classData.specs[nextIdx].key
    self:UpdateBiSView()
end

function MainUI:SetBiSWaypoint()
    if selectedBiSMode == "enchants" then
        local rFrame = bisRowFrames[selectedBiSSlot or "Head"]
        local enchantID = rFrame and rFrame.enchantID
        if not enchantID or enchantID == 0 then
            ns.Print("Selecciona una ranura con encantamiento válido para ver su procedencia.")
            return
        end
        local meta = rFrame.enchantMeta or ns.GetEnchantMetadata(enchantID)
        if meta then
            ns.Print(string.format("Encantamiento: |cFFFFD100%s|r (%s) — Obtenible en |cFF00FFCC%s|r.", meta.name, meta.effect, meta.source))
        end
        return
    end

    local rFrame = bisRowFrames[selectedBiSSlot or "Head"]
    local itemID = rFrame and rFrame.itemID
    if not itemID or itemID == 0 then
        ns.Print("Selecciona una ranura con objeto válido para marcar ruta.")
        return
    end
    local meta = ns.GetBiSItemMetadata(itemID)
    if not meta or not meta.name then
        ns.Print("Selecciona una ranura con objeto válido para marcar ruta.")
        return
    end

    local zoneName = meta.zone or "Mundo"
    local sourceName = meta.source or "Jefe"
    local itemName = meta.name or "Objeto"

    local cSource = (ns.Cyan and ns.Cyan(sourceName)) or ("|cFF00FFCC" .. sourceName .. "|r")
    local cZone = (ns.Gold and ns.Gold(zoneName)) or ("|cFFFFD100" .. zoneName .. "|r")
    local cItem = (ns.Gold and ns.Gold(itemName)) or ("|cFFFFD100" .. itemName .. "|r")

    local coord = ns.Data.DungeonCoords and (ns.Data.DungeonCoords[zoneName] or ns.Data.DungeonCoords[sourceName])
    if not coord and ns.Data.DungeonCoords then
        for dName, cData in pairs(ns.Data.DungeonCoords) do
            if zoneName:find(dName, 1, true) or dName:find(zoneName, 1, true) then
                coord = cData
                break
            end
        end
    end

    if coord and TomTom and TomTom.AddWaypoint then
        TomTom:AddWaypoint(coord.mapID, coord.x / 100, coord.y / 100, {
            title = "BiS: " .. itemName .. " (" .. sourceName .. ")",
            persistent = false,
            minimap = true,
            world = true
        })
        ns.Print(string.format("Punto TomTom fijado para %s en %s (%.1f, %.1f)", cZone, cSource, coord.x, coord.y))
    else
        ns.Print(string.format("Objeto BiS: %s · Jefe: %s · Ubicación: %s", cItem, cSource, cZone))
    end
end

-- =========================================================================
-- VISTA 1: SECRETOS (LISTA TIPO TABLA CON HOVER Y DETALLES)
-- =========================================================================
local secretRowFrames = {}
local secretsOrder = { "sleeping_bag", "expert_cooking", "library_books", "ancient_rune", "sunken_chest", "tanaris_pirates", "shadowforge_key" }

function MainUI:BuildSecretsList(parent)
    local scroll = CreateFrame("ScrollFrame", "AwakeningSecretsScroll", parent, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, -2)
    scroll:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -20, 24)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(495, 10)
    scroll:SetScrollChild(content)
    parent.content = content
    parent.scroll = scroll

    -- Mensaje de estado vacío cuando no hay secretos para el nivel del jugador
    local emptyLabel = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    emptyLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -40)
    emptyLabel:SetPoint("RIGHT", content, "RIGHT", -10, 0)
    emptyLabel:SetJustifyH("CENTER")
    emptyLabel:SetWordWrap(true)
    emptyLabel:SetSpacing(3)
    emptyLabel:Hide()
    parent.emptyLabel = emptyLabel

    -- Precargar objetos en la caché de WoW para que los tooltips muestren enlaces y estadísticas de inmediato
    for _, key in ipairs(secretsOrder) do
        local secret = ns.Data.Secrets and ns.Data.Secrets[key]
        if secret and secret.rewardItems then
            for _, rItem in ipairs(secret.rewardItems) do
                if rItem.itemID and GetItemInfo then
                    GetItemInfo(rItem.itemID)
                end
            end
        end
    end

    -- Crear los marcos de fila para los secretos
    for _, key in ipairs(secretsOrder) do
        local secret = (ns.GetSecret and ns.GetSecret(key)) or (ns.Data.Secrets and ns.Data.Secrets[key])
        if secret then
            local row = CreateFrame("Button", nil, content, "BackdropTemplate")
            row:SetSize(495, 20)
            row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, 0)

            -- Resaltado hover sutil estilo Olympus
            local hl = row:CreateTexture(nil, "HIGHLIGHT")
            hl:SetAllPoints()
            hl:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight")
            hl:SetBlendMode("ADD")
            hl:SetAlpha(0.35)

            -- Resaltado de selección activa
            local sel = row:CreateTexture(nil, "BORDER")
            sel:SetAllPoints()
            sel:SetColorTexture(1, 0.82, 0, 0.15)
            sel:Hide()
            row.selection = sel

            -- Columna 1: Título e Icono pequeño
            local icon = row:CreateTexture(nil, "ARTWORK")
            icon:SetSize(16, 16)
            icon:SetPoint("LEFT", row, "LEFT", 2, 0)
            icon:SetTexture(secret.icon or (secret.steps[1] and secret.steps[1].icon) or "Interface\\Icons\\inv_misc_bag_07")
            row.icon = icon

            local title = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            title:SetPoint("LEFT", icon, "RIGHT", 4, 0)
            title:SetPoint("RIGHT", row, "LEFT", 260, 0)
            title:SetJustifyH("LEFT")
            title:SetWordWrap(false)
            title:SetText(secret.title)
            row.title = title

            -- Columna 2: Zona y Distancia
            local zone = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            zone:SetPoint("LEFT", row, "LEFT", 262, 0)
            zone:SetPoint("RIGHT", row, "LEFT", 430, 0)
            zone:SetJustifyH("LEFT")
            zone:SetWordWrap(false)
            zone:SetText(secret.steps[1] and secret.steps[1].zoneName or "Varias")
            row.zone = zone

            -- Columna 3: Hitos / Progreso
            local steps = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            steps:SetPoint("LEFT", row, "LEFT", 432, 0)
            steps:SetPoint("RIGHT", row, "RIGHT", -6, 0)
            steps:SetJustifyH("RIGHT")
            steps:SetWordWrap(false)
            steps:SetText(string.format("%d", #secret.steps))
            row.steps = steps

            row.key = key

            -- Tooltip de recompensas con la misma metodología nativa y metadatos de BiS
            row:SetScript("OnEnter", function(selfRow)
                local sKey = selfRow.key
                local s = (ns.GetSecret and ns.GetSecret(sKey)) or (ns.Data.Secrets and ns.Data.Secrets[sKey])
                if not s then return end

                GameTooltip:SetOwner(selfRow, "ANCHOR_RIGHT")
                GameTooltip:ClearLines()

                local rItems = s.rewardItems
                local primaryIndex = 1

                if sKey == "library_books" then
                    local _, pClass = UnitClass("player")
                    local curTier = s.currentTier or 1
                    if curTier == 1 then
                        if pClass == "ROGUE" or pClass == "HUNTER" or pClass == "DRUID" or pClass == "WARRIOR" then
                            primaryIndex = 2 -- Amuleto de erudito (+2 Agi, +3 Agu)
                        else
                            primaryIndex = 1 -- Colgante de erudito (+3 Agu, +2 Esp)
                        end
                    elseif curTier == 2 then
                        if pClass == "MAGE" or pClass == "WARLOCK" or pClass == "PRIEST" or pClass == "DRUID" or pClass == "PALADIN" or pClass == "SHAMAN" then
                            primaryIndex = 4 -- Anillo de filántropo (+5 Int, +10 Hechizos)
                        else
                            primaryIndex = 3 -- Sortija del investigador de campo (+7 Agi, +7 Agu)
                        end
                    else
                        if pClass == "HUNTER" or pClass == "ROGUE" or pClass == "WARRIOR" then
                            primaryIndex = 5 -- Arco del buscador de la verdad (+7 Agi, +3 Agu)
                        elseif pClass == "PALADIN" or pClass == "SHAMAN" or pClass == "WARRIOR" then
                            primaryIndex = 6 -- Blasón de elucidación (+12 Esp, +7 Heal, Escudo)
                        else
                            primaryIndex = 7 -- Luz nocturna del investigador (+12 Agu, +7 Fuego, Mano izq)
                        end
                    end
                end

                local primaryItem = rItems and (rItems[primaryIndex] or rItems[1])
                local hasNativeTooltip = false

                if primaryItem and primaryItem.itemID and primaryItem.itemID > 0 then
                    local _, link = GetItemInfo(primaryItem.itemID)
                    if link then
                        GameTooltip:SetHyperlink(link)
                        hasNativeTooltip = true
                    elseif GameTooltip.SetItemByID then
                        GameTooltip:SetItemByID(primaryItem.itemID)
                        hasNativeTooltip = (GameTooltip:NumLines() > 0)
                    end
                end

                -- Fallback si el cliente aún no tiene el objeto en caché o es un secreto sin ID nativo
                if not hasNativeTooltip then
                    GameTooltip:AddLine(string.format("|cFFFFD100%s|r", s.title), 1, 0.82, 0)
                    if s.category then
                        GameTooltip:AddLine(string.format("%s · %s", s.category, s.level or "Nivel 1-60"), 0.5, 0.8, 1)
                    end
                    if primaryItem then
                        GameTooltip:AddLine(" ")
                        local qualColor = "|cFF00FF00"
                        if primaryItem.quality == 3 then qualColor = "|cFF0070DD"
                        elseif primaryItem.quality == 4 then qualColor = "|cFFA335EE" end
                        GameTooltip:AddLine(string.format("|T%s:18:18:0:0:64:64:4:60:4:60|t %s%s|r", primaryItem.icon or "Interface\\Icons\\inv_misc_questionmark", qualColor, primaryItem.name), 1, 1, 1)
                        if primaryItem.desc then
                            GameTooltip:AddLine("   |cFF88DDFF" .. primaryItem.desc .. "|r", 0.75, 0.85, 1, true)
                        end
                    end
                end

                -- Recompensas adicionales u opciones alternativas (estilo BiSTracker)
                if rItems and #rItems > 1 then
                    GameTooltip:AddLine(" ")
                    local altHeader = (sKey == "library_books") and "|cFFFFD100Opciones de recompensa y tiers:|r" or "|cFFFFD100Otras recompensas al completar:|r"
                    GameTooltip:AddLine(altHeader, 1, 0.82, 0)

                    for i, rItem in ipairs(rItems) do
                        if i ~= primaryIndex then
                            local _, link, qual = GetItemInfo(rItem.itemID)
                            local name = link or rItem.name or ("Objeto #" .. rItem.itemID)
                            local countStr = (rItem.count and rItem.count > 1) and (" |cFFFFFFFF(x" .. rItem.count .. ")|r") or ""
                            local r, g, b = 0.2, 1, 0.4
                            if qual and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[qual] then
                                r, g, b = ITEM_QUALITY_COLORS[qual].r, ITEM_QUALITY_COLORS[qual].g, ITEM_QUALITY_COLORS[qual].b
                            elseif rItem.quality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[rItem.quality] then
                                r, g, b = ITEM_QUALITY_COLORS[rItem.quality].r, ITEM_QUALITY_COLORS[rItem.quality].g, ITEM_QUALITY_COLORS[rItem.quality].b
                            end
                            GameTooltip:AddLine(string.format("|T%s:16:16:0:0:64:64:4:60:4:60|t %s%s", rItem.icon or "Interface\\Icons\\inv_misc_questionmark", name, countStr), r, g, b)
                            if rItem.desc then
                                GameTooltip:AddLine("   |cFF88DDFF" .. rItem.desc .. "|r", 0.75, 0.85, 1, true)
                            end
                        end
                    end
                end

                -- Bonus especial para Magos
                if sKey == "library_books" and select(2, UnitClass("player")) == "MAGE" then
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("|cFF00CCFFHabilidad Extra de Mago: Estudiar (Study)|r", 0, 0.8, 1)
                    GameTooltip:AddLine("   |cFF88DDFFAl entregar el 1er tomo aprendes 'Estudiar' (consume 1 Pluma ligera en una biblioteca para generar pergaminos diarios).|r", 0.7, 0.85, 1, true)
                end

                -- Metadatos de la misión al pie del tooltip (idéntico a la metodología BiS de Awakening)
                GameTooltip:AddLine(" ")
                GameTooltip:AddDoubleLine("|cFFFFD100Secreto:|r " .. s.title, "|cFFFFD100Rango:|r |cFFFFFFFF" .. (s.level or "1-60") .. "|r")
                GameTooltip:AddDoubleLine("|cFFFFD100Categoría:|r " .. (s.category or "Secreto"), "|cFFFFD100Facción:|r " .. (s.faction or "Ambas"))

                local pLvl = UnitLevel("player") or 1
                local curIdx, isDone = (ns.GetSecretProgress and ns.GetSecretProgress(sKey)) or (s.currentStep or 1), s.isCompleted
                local isOld = pLvl > (s.maxLevel or 60)
                local curStep = s.steps and (s.steps[curIdx] or s.steps[1])

                if curStep then
                    local zoneStr = curStep.zoneName or "Varias"
                    local coordStr = (curStep.x and curStep.y) and string.format("(%.1f, %.1f)", curStep.x, curStep.y) or ""
                    GameTooltip:AddDoubleLine("|cFFFFD100Hito actual:|r " .. curIdx .. "/" .. #s.steps, "|cFFFFD100Zona:|r " .. zoneStr .. " " .. coordStr)

                    if curStep.uiMapID and curStep.x and curStep.y and ns.TravelPlanner and ns.TravelPlanner.FindNearestNode then
                        local nearestId, hubDist, nNode = ns.TravelPlanner:FindNearestNode(curStep.uiMapID, curStep.x, curStep.y)
                        if nNode then
                            local hubFmt = hubDist and string.format("%s (a %s)", nNode.name, ns.FormatDistance(hubDist)) or nNode.name
                            GameTooltip:AddDoubleLine("|cFFFFD100Punto de llegada:|r", "|cFF00FFCC" .. hubFmt .. "|r")
                        end
                    end
                end

                local stStr
                if isDone then
                    stStr = "|cFF00FF00Completado con éxito (25/25 Libros)|r"
                elseif sKey == "library_books" and s.collectedCount then
                    local target = s.targetCount or 10
                    local tier = s.currentTier or 1
                    if s.collectedCount >= target then
                        stStr = string.format("|cFF00FFCCListo para entregar Tier %d (%d/%d Tomos)|r", tier, s.collectedCount, target)
                    else
                        stStr = string.format("|cFFFFD100Tier %d: %d de %d Tomos despojados|r", tier, s.collectedCount, target)
                    end
                elseif isOld then
                    stStr = "|cFF888888Pendiente (Nivel superado)|r"
                else
                    stStr = "|cFFFF5555Pendiente de completar|r"
                end
                GameTooltip:AddDoubleLine("|cFFFFD100Estado de misión:|r", stStr)

                GameTooltip:Show()
            end)

            row:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            row:SetScript("OnClick", function()
                MainUI:SelectSecret(key)
            end)
            row:SetScript("OnDoubleClick", function()
                MainUI:SelectSecret(key)
                if ns.GuideHUD then
                    local curMilestone = (ns.GetSecretProgress and ns.GetSecretProgress(key)) or 1
                    local guideData, startStep = ns.GetDynamicSecretGuide and ns.GetDynamicSecretGuide(key, curMilestone)
                    if not guideData then
                        guideData = (ns.GetSecret and ns.GetSecret(key)) or secret
                        startStep = curMilestone
                    end
                    ns.GuideHUD:StartRoute(guideData, key, startStep)
                end
            end)

            secretRowFrames[key] = row
        end
    end

    -- Barra inferior: Casilla de activación "Mostrar secretos antiguos"
    local bottomBar = CreateFrame("Frame", nil, parent)
    bottomBar:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 2, 2)
    bottomBar:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -2, 2)
    bottomBar:SetHeight(20)
    parent.bottomBar = bottomBar

    local chkOld = CreateFrame("CheckButton", "AwakeningOldSecretsCheckbox", bottomBar, "UICheckButtonTemplate")
    chkOld:SetSize(20, 20)
    chkOld:SetPoint("LEFT", bottomBar, "LEFT", 2, 0)
    chkOld:SetChecked((ns.db and ns.db.showOldSecrets) or false)
    parent.chkOld = chkOld

    local chkText = chkOld:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    chkText:SetPoint("LEFT", chkOld, "RIGHT", 4, 0)
    chkText:SetText("Mostrar secretos antiguos")
    chkOld.text = chkText

    chkOld:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()
        if ns.db then
            ns.db.showOldSecrets = isChecked
        end
        MainUI:UpdateSecretsView()
    end)

    chkOld:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Mostrar secretos antiguos", 1, 0.82, 0)
        GameTooltip:AddLine("Muestra los secretos que tu personaje ya superó en nivel y que aún no has completado, para que puedas volver y terminarlos.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    chkOld:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

function MainUI:UpdateSecretsView()
    local parent = viewsByKey and viewsByKey["secrets"]
    local playerLevel = UnitLevel("player") or 1
    local showOld = (ns.db and ns.db.showOldSecrets) or false
    local playerLoc = ns.GetPlayerLocation and ns.GetPlayerLocation()

    if parent and parent.chkOld then
        parent.chkOld:SetChecked(showOld)
    end

    local yOffset = 0
    local visibleCount = 0
    local firstVisibleKey = nil
    local selectedStillVisible = false

    for _, key in ipairs(secretsOrder) do
        local row = secretRowFrames[key]
        local secret = (ns.GetSecret and ns.GetSecret(key)) or (ns.Data.Secrets and ns.Data.Secrets[key])
        
        if row and secret and secret.steps then
            local minLvl = secret.minLevel or 1
            local maxLvl = secret.maxLevel or 60
            local curStepIdx, isDone = (ns.GetSecretProgress and ns.GetSecretProgress(key)) or (secret.currentStep or 1), secret.isCompleted
            
            local isTooLow = (playerLevel < minLvl)
            local isOld = (playerLevel > maxLvl)
            
            -- Lógica de visibilidad progresiva por nivel y requisitos de profesión:
            local shouldShow = false
            if secret.autoHideCompleted and isDone then
                -- Guías que deben desaparecer definitivamente al completarse (ej. libro de cocina ya aprendido)
                shouldShow = false
            elseif secret.requiredProfession then
                if isDone then
                    shouldShow = false
                elseif isEligible == false then
                    shouldShow = false
                else
                    shouldShow = true
                end
            elseif isTooLow then
                shouldShow = false
            elseif not isOld then
                shouldShow = true
            else
                shouldShow = showOld
            end

            if shouldShow then
                visibleCount = visibleCount + 1
                firstVisibleKey = firstVisibleKey or key
                if key == selectedSecretKey then
                    selectedStillVisible = true
                end

                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", row:GetParent(), "TOPLEFT", 0, yOffset)
                row:Show()

                local targetStep = (ns.GetSecretMilestoneTargetStep and ns.GetSecretMilestoneTargetStep(key, curStepIdx)) or (secret.steps and secret.steps[curStepIdx]) or secret.steps[1]
                local activeStep = targetStep
                row.icon:SetTexture(secret.icon or (activeStep and activeStep.icon) or "Interface\\Icons\\inv_misc_bag_07")

                -- Cálculo eficiente de distancia al hito activo reutilizando las funciones de viaje
                local zoneText = activeStep and activeStep.zoneName or "Varias"
                if isDone then
                    row.zone:SetText(zoneText)
                elseif playerLoc and activeStep and activeStep.uiMapID and activeStep.x and activeStep.y then
                    local distYards = ns.GetDistanceAndHeading and ns.GetDistanceAndHeading(playerLoc.mapID, playerLoc.x, playerLoc.y, activeStep.uiMapID, activeStep.x, activeStep.y)
                    if distYards then
                        if distYards < 150 and playerLoc.mapID == activeStep.uiMapID then
                            row.zone:SetText(string.format("%s · |cFF00FF00Aquí (%s)|r", zoneText, ns.FormatDistance(distYards)))
                        elseif distYards < 1500 then
                            row.zone:SetText(string.format("%s · |cFF00FF00%s|r", zoneText, ns.FormatDistance(distYards)))
                        else
                            row.zone:SetText(string.format("%s · |cFFFFD100%s|r", zoneText, ns.FormatDistance(distYards)))
                        end
                    else
                        local nearestId, _, nearestNode = ns.TravelPlanner and ns.TravelPlanner:FindNearestNode(activeStep.uiMapID, activeStep.x, activeStep.y)
                        local contTag = nearestNode and nearestNode.continent
                        if contTag and contTag ~= "" then
                            row.zone:SetText(string.format("%s · |cFF88DDFF%s|r", zoneText, contTag))
                        else
                            row.zone:SetText(zoneText)
                        end
                    end
                else
                    row.zone:SetText(zoneText)
                end

                if isDone then
                    row.title:SetText(secret.title)
                    row.steps:SetText("|cFF00FF00[Listo]|r")
                elseif key == "sleeping_bag" then
                    row.title:SetText(secret.title)
                    row.steps:SetText(string.format("|cFFFFD100Hito %d/7|r", curStepIdx))
                elseif key == "expert_cooking" and secret.currentSkill then
                    row.title:SetText(secret.title)
                    row.steps:SetText(string.format("|cFFFFD100%d/150|r", secret.currentSkill))
                elseif key == "library_books" and secret.collectedCount then
                    row.title:SetText(secret.title)
                    local target = secret.targetCount or 10
                    local tier = secret.currentTier or 1
                    if isDone then
                        row.steps:SetText("|cFF00FF00[Listo (25/25)]|r")
                    elseif secret.collectedCount >= target then
                        row.steps:SetText(string.format("|cFF00FFCCEntrega (T%d)|r", tier))
                    else
                        row.steps:SetText(string.format("|cFFFFD100%d/%d (T%d)|r", secret.collectedCount, target, tier))
                    end
                elseif isOld then
                    row.title:SetText(string.format("|cFFBBBBBB%s|r", secret.title))
                    row.steps:SetText(string.format("|cFF888888Hito %d/%d|r", curStepIdx, #secret.steps))
                elseif #secret.steps > 1 then
                    row.title:SetText(secret.title)
                    row.steps:SetText(string.format("|cFFFFD100Hito %d/%d|r", curStepIdx, #secret.steps))
                else
                    row.title:SetText(secret.title)
                    row.steps:SetText(string.format("%d", #secret.steps))
                end

                yOffset = yOffset - 22
            else
                row:Hide()
            end
        elseif row then
            row:Hide()
        end
    end

    if parent and parent.content then
        parent.content:SetHeight(math.max(10, -yOffset))
    end

    if parent and parent.emptyLabel then
        if visibleCount == 0 then
            parent.emptyLabel:SetText(string.format("|cFF888888No hay secretos activos para tu nivel actual (%d).\n\nActiva la casilla 'Mostrar secretos antiguos' abajo para ver los que dejaste pasar.|r", playerLevel))
            parent.emptyLabel:Show()
        else
            parent.emptyLabel:Hide()
        end
    end

    if not selectedStillVisible and firstVisibleKey then
        selectedSecretKey = firstVisibleKey
    end

    if selectedSecretKey then
        self:SelectSecret(selectedSecretKey)
    end
end

function MainUI:SelectSecret(key)
    selectedSecretKey = key
    local secret = (ns.GetSecret and ns.GetSecret(key)) or (ns.Data.Secrets and ns.Data.Secrets[key])
    if not secret then return end

    -- Actualizar selección visual en la tabla
    for rKey, rFrame in pairs(secretRowFrames) do
        if rFrame.selection then
            rFrame.selection:SetShown(rKey == key)
        end
    end

    local playerLevel = UnitLevel("player") or 1
    local minLvl = secret.minLevel or 1
    local maxLvl = secret.maxLevel or 60
    local isOld = playerLevel > maxLvl
    local curStepIdx = (ns.GetSecretProgress and ns.GetSecretProgress(key)) or (secret.currentStep or 1)
    local curStep = (ns.GetSecretMilestoneTargetStep and ns.GetSecretMilestoneTargetStep(key, curStepIdx)) or (secret.steps and (secret.steps[curStepIdx] or secret.steps[1]))
    local isDone = secret.isCompleted
    local playerLoc = ns.GetPlayerLocation and ns.GetPlayerLocation()

    -- Actualizar Caja de Detalles inferior (Estilo Olympus)
    if mainFrame and mainFrame.detailTitle and mainFrame.detailText then
        local stBadge
        if isDone then
            stBadge = "|cFF00FF00[Completado]|r"
        elseif key == "sleeping_bag" then
            stBadge = string.format("|cFFFFD100[Hito %d de 7]|r", curStepIdx)
        elseif key == "expert_cooking" and secret.currentSkill then
            stBadge = string.format("|cFFFFD100[Cocina %d de 150]|r", secret.currentSkill)
        elseif key == "library_books" and secret.collectedCount then
            local target = secret.targetCount or 10
            local tier = secret.currentTier or 1
            if isDone then
                stBadge = "|cFF00FF00[Completado 25/25]|r"
            elseif secret.collectedCount >= target then
                stBadge = string.format("|cFF00FFCC[Listo para Entregar · Tier %d (%d/%d)]|r", tier, secret.collectedCount, target)
            else
                stBadge = string.format("|cFFFFD100[Tier %d · %d de %d Tomos Recolectados]|r", tier, secret.collectedCount, target)
            end
        elseif isOld then
            stBadge = string.format("|cFF888888[Hito %d/%d · Nivel Superado]|r", curStepIdx, #secret.steps)
        else
            stBadge = string.format("|cFFFFD100[Hito %d de %d]|r", curStepIdx, #secret.steps)
        end

        mainFrame.detailTitle:SetText(string.format("|cFFFFD100%s|r · |cFF00FFCC%s|r %s", secret.title, secret.category or "Misión Secreta", stBadge))

        -- Configurar contenedor interactivo de recompensas con tooltips nativos
        if secret.rewardItems and #secret.rewardItems > 0 then
            self:ShowDetailRewards(secret.rewardItems, "|cFFFFCC00Recompensas:|r")
        else
            self:ShowDetailRewards(nil)
        end

        local stepDesc = curStep and string.format("|cFF00FFCC%s:|r %s", curStep.title, curStep.instruction) or "Sigue las pistas para desvelar el secreto."
        if curStep and curStep.tip then
            stepDesc = stepDesc .. "\n|cFFFFCC00Consejo:|r " .. curStep.tip
        end

        local locStr = curStep and string.format("%s (%.1f, %.1f)", curStep.zoneName or "Mundo", curStep.x or 0, curStep.y or 0) or "Varias"
        local lvlStr = string.format("%s (Tu nivel: %d)", secret.level or (minLvl .. " - " .. maxLvl), playerLevel)

        -- -----------------------------------------------------------------
        -- INTEGRACIÓN AVANZADA CON TRAVEL PLANNER (PUNTO DE LLEGADA Y TIEMPO)
        -- -----------------------------------------------------------------
        local hubInfoStr = nil
        local travelEtaStr = nil

        if curStep and curStep.uiMapID and curStep.x and curStep.y and ns.TravelPlanner then
            local nearestId, hubDistYards, nearestNode = ns.TravelPlanner:FindNearestNode(curStep.uiMapID, curStep.x, curStep.y)
            if nearestNode then
                local typeLabels = {
                    flightmaster = "Vuelo",
                    boat = "Puerto / Barco",
                    tram = "Tranvía",
                    zeppelin = "Zepelín",
                    walk = "Camino",
                }
                local tLabel = typeLabels[nearestNode.type] or "Transporte"
                local distSuffix = hubDistYards and string.format(" · a %s del hito", ns.FormatDistance(hubDistYards)) or ""
                hubInfoStr = string.format("|cFFFFD100Punto de llegada:|r %s (%s%s)", nearestNode.name, tLabel, distSuffix)
            end

            if playerLoc and not isDone then
                local directDist = ns.GetDistanceAndHeading and ns.GetDistanceAndHeading(playerLoc.mapID, playerLoc.x, playerLoc.y, curStep.uiMapID, curStep.x, curStep.y)
                if directDist and directDist < 600 and playerLoc.mapID == curStep.uiMapID then
                    travelEtaStr = string.format("|cFF00FF00Cerca del objetivo:|r A pie: %s (~%.1f min)", ns.FormatDistance(directDist), (directDist / 7) / 60)
                else
                    local plan = ns.TravelPlanner:CalculateRoute("__player__", curStep, { routingMode = "fastest" })
                    if not plan or not plan.success then
                        if nearestId then
                            plan = ns.TravelPlanner:CalculateRoute("__player__", nearestId, { routingMode = "fastest" })
                        end
                    end
                    if plan and plan.success then
                        local legsDesc = (#plan.legs == 1) and "1 etapa directa" or string.format("%d etapas", #plan.legs)
                        local hsNote = (plan.hearthstone and plan.hearthstone.isBeneficial) and " |cFF00FFFF(Atajo con Piedra de Hogar)|r" or ""
                        travelEtaStr = string.format("Viaje estimado: |cFF00FF00~%.1f min|r (%s)%s", plan.totalMinutes or 0, legsDesc, hsNote)
                    end
                end
            end
        end

        local lines = {}
        if not secret.rewardItems or #secret.rewardItems == 0 then
            if secret.reward then
                table.insert(lines, "|cFFFFCC00Recompensa:|r " .. secret.reward)
            end
        end
        table.insert(lines, string.format("|cFFFFFFFFUbicación:|r %s   ·   |cFFFFFFFFRango:|r %s", locStr, lvlStr))

        if hubInfoStr then
            if travelEtaStr then
                table.insert(lines, hubInfoStr .. "   ·   " .. travelEtaStr)
            else
                table.insert(lines, hubInfoStr)
            end
        elseif travelEtaStr then
            table.insert(lines, travelEtaStr)
        end

        if stepDesc and stepDesc ~= "" then
            table.insert(lines, stepDesc)
        end

        if not isDone then
            table.insert(lines, "|cFF888888Pulsa '|cFFFFD100Iniciar Ruta|r' para el compás HUD, o '|cFFFFD100Planificar Viaje|r' para ver vuelos y barcos.|r")
        end

        mainFrame.detailText:SetText(table.concat(lines, "\n"))
    end
end

-- =========================================================================
-- VISTA 2: RUTAS DE FARMEO (CON DETECCIÓN DE PROFESIONES Y DETALLES)
-- =========================================================================
local farmingRowFrames = {}

local FARMING_PROFS = {
    "Leatherworking", "Skinning", "Alchemy", "Herbalism",
    "Mining", "Blacksmithing", "Engineering", "Tailoring",
    "Enchanting", "Cooking", "Fishing", "First Aid"
}

local FARMING_BRACKETS = { "auto", "1-75", "75-150", "150-225", "225-300" }

function MainUI:CycleFarmingProf()
    local curIdx = 1
    for i, key in ipairs(FARMING_PROFS) do
        if key == selectedFarmingProfKey then
            curIdx = i
            break
        end
    end
    local nextIdx = (curIdx % #FARMING_PROFS) + 1
    selectedFarmingProfKey = FARMING_PROFS[nextIdx]
    selectedFarmingItemData = nil
    self:UpdateFarmingView()
end

function MainUI:CycleFarmingBracket()
    local curIdx = 1
    for i, b in ipairs(FARMING_BRACKETS) do
        if b == selectedFarmingBracket then
            curIdx = i
            break
        end
    end
    local nextIdx = (curIdx % #FARMING_BRACKETS) + 1
    selectedFarmingBracket = FARMING_BRACKETS[nextIdx]
    selectedFarmingItemData = nil
    self:UpdateFarmingView()
end

function MainUI:BuildFarmingList(parent)
    -- Barra superior de controles: Selector de Profesión y Selector de Tramo
    local controls = CreateFrame("Frame", nil, parent)
    controls:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, 0)
    controls:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -2, 0)
    controls:SetHeight(28)
    parent.controls = controls

    -- Botón de Profesión
    local profBtn = CreateFrame("Button", "AwakeningFarmingProfBtn", controls, "UIPanelButtonTemplate")
    profBtn:SetSize(195, 22)
    profBtn:SetPoint("LEFT", controls, "LEFT", 2, 0)
    profBtn:SetText("Peletería")
    profBtn:SetScript("OnClick", function()
        MainUI:CycleFarmingProf()
    end)
    profBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:AddLine("Selector de Profesión", 1, 0.82, 0)
        GameTooltip:AddLine("Haz clic para cambiar de profesión.", 1, 1, 1)
        local pProfs = ns.GetPlayerProfessions()
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine("Tus profesiones detectadas:", 0, 1, 0.8)
        local hasAny = false
        for _, pKey in ipairs(FARMING_PROFS) do
            if pProfs[pKey] then
                hasAny = true
                local isCurrent = (pKey == selectedFarmingProfKey) and " |cFF00FF00(Activa)|r" or ""
                GameTooltip:AddLine(string.format(" · %s: %d/%d%s", pProfs[pKey].name or pKey, pProfs[pKey].rank or 0, pProfs[pKey].maxRank or 0, isCurrent), 1, 1, 1)
            end
        end
        if not hasAny then
            GameTooltip:AddLine("  (Ninguna profesión aprendida aún)", 0.7, 0.7, 0.7)
        end
        GameTooltip:Show()
    end)
    profBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    parent.profBtn = profBtn

    -- Botón de Tramo / Nivel
    local bracketBtn = CreateFrame("Button", "AwakeningFarmingBracketBtn", controls, "UIPanelButtonTemplate")
    bracketBtn:SetSize(165, 22)
    bracketBtn:SetPoint("LEFT", profBtn, "RIGHT", 6, 0)
    bracketBtn:SetText("Auto (Según Habilidad)")
    bracketBtn:SetScript("OnClick", function()
        MainUI:CycleFarmingBracket()
    end)
    bracketBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:AddLine("Tramo de Nivel / Habilidad", 1, 0.82, 0)
        GameTooltip:AddLine("Haz clic para alternar entre:", 1, 1, 1)
        GameTooltip:AddLine(" · Auto (Detecta automáticamente tu habilidad actual)", 0, 1, 0.8)
        GameTooltip:AddLine(" · 1 - 75 (Aprendiz)", 1, 1, 1)
        GameTooltip:AddLine(" · 75 - 150 (Oficial)", 1, 1, 1)
        GameTooltip:AddLine(" · 150 - 225 (Experto)", 1, 1, 1)
        GameTooltip:AddLine(" · 225 - 300 (Artesano)", 1, 1, 1)
        GameTooltip:Show()
    end)
    bracketBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    parent.bracketBtn = bracketBtn

    -- Indicador de Modo
    local modeBadge = controls:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    modeBadge:SetPoint("RIGHT", controls, "RIGHT", -30, 0)
    modeBadge:SetText("|cFF00FFCCAuto|r")
    parent.modeBadge = modeBadge

    -- Scroll frame posicionado debajo de la barra superior
    local scroll = CreateFrame("ScrollFrame", "AwakeningFarmingScroll", parent, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, -28)
    scroll:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -22, 2)
    parent.scroll = scroll

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(440, 10)
    scroll:SetScrollChild(content)
    parent.content = content

    self:UpdateFarmingView()
end

function MainUI:UpdateFarmingView()
    local view = viewsByKey["farming"] or views[tabIndexByKey["farming"] or 4]
    if not view or not view.content then return end

    local playerProfs = ns.GetPlayerProfessions()

    if not selectedFarmingProfKey or not (ns.Data.ProfessionGuides and ns.Data.ProfessionGuides[selectedFarmingProfKey]) then
        local candidate = nil
        for _, pKey in ipairs(FARMING_PROFS) do
            if playerProfs[pKey] and ns.Data.ProfessionGuides[pKey] then
                candidate = pKey
                break
            end
        end
        selectedFarmingProfKey = candidate or "Leatherworking"
    end

    local profData = ns.Data.ProfessionGuides and ns.Data.ProfessionGuides[selectedFarmingProfKey]
    if not profData then return end

    local profInfo = playerProfs[selectedFarmingProfKey]
    local profRank = profInfo and profInfo.rank or 0
    local maxRank = profInfo and profInfo.maxRank or 0
    local isLearned = (profInfo ~= nil and profRank > 0)

    -- Determinar el tramo activo
    local activeBracketKey = selectedFarmingBracket
    if activeBracketKey == "auto" then
        if profRank < 75 then
            activeBracketKey = "1-75"
        elseif profRank < 150 then
            activeBracketKey = "75-150"
        elseif profRank < 225 then
            activeBracketKey = "150-225"
        else
            activeBracketKey = "225-300"
        end
    end

    local bracketData = profData.brackets and (profData.brackets[activeBracketKey] or profData.brackets["1-75"])
    if not bracketData then return end

    -- Actualizar botones superiores
    if view.profBtn then
        local rankStr = isLearned and string.format(" (%d/%d)", profRank, maxRank) or " (Sin aprender)"
        view.profBtn:SetText(profData.name .. rankStr)
    end

    if view.bracketBtn then
        local bLabel = bracketData.name or activeBracketKey
        if selectedFarmingBracket == "auto" then
            view.bracketBtn:SetText(string.format("Auto: %s", bLabel:gsub("%s*·.*", "")))
        else
            view.bracketBtn:SetText(string.format("Tramo: %s", bLabel:gsub("%s*·.*", "")))
        end
    end

    if view.modeBadge then
        if selectedFarmingBracket == "auto" then
            view.modeBadge:SetText(isLearned and "|cFF00FFCCAuto|r" or "|cFFFFCC00Auto (Nv. 1)|r")
        else
            view.modeBadge:SetText("|cFFFFD100Modo Manual|r")
        end
    end

    -- Actualizar Hero Title en la cabecera principal
    if mainFrame and mainFrame.heroTitle then
        mainFrame.heroTitle:SetText(string.format(
            "|cFFFFD100Profesiones: %s%s|r · |cFFFFFFFF%s|r",
            profData.name,
            isLearned and string.format(" (%d/%d)", profRank, maxRank) or "",
            bracketData.name or activeBracketKey
        ))
    end

    -- Construir lista plana de elementos a mostrar
    local items = {}

    -- 1. MATERIALES REQUERIDOS
    if bracketData.materials and #bracketData.materials > 0 then
        table.insert(items, {
            type = "header",
            text = "MATERIALES REQUERIDOS (TRAMO " .. (bracketData.skillRange or activeBracketKey) .. ")"
        })
        for _, mat in ipairs(bracketData.materials) do
            table.insert(items, {
                type = "material",
                data = mat,
                profData = profData,
                bracketData = bracketData
            })
        end
    end

    -- 2. RECETAS Y PASOS
    if bracketData.recipes and #bracketData.recipes > 0 then
        table.insert(items, {
            type = "header",
            text = "RECETAS Y PASOS ÓPTIMOS (WoW-Professions Forever)"
        })
        for _, rec in ipairs(bracketData.recipes) do
            table.insert(items, {
                type = "recipe",
                data = rec,
                profData = profData,
                bracketData = bracketData
            })
        end
    end

    -- 3. RUTAS DE FARMEO RECOMENDADAS
    if bracketData.farmingRoute then
        table.insert(items, {
            type = "header",
            text = "RUTAS DE RECOLECCIÓN Y FARMEO RECOMENDADAS"
        })
        table.insert(items, {
            type = "route",
            data = bracketData.farmingRoute,
            profData = profData,
            bracketData = bracketData,
            routeKey = string.lower(selectedFarmingProfKey .. "_" .. activeBracketKey)
        })
    end

    local content = view.content
    local yOffset = 0

    for i, entry in ipairs(items) do
        local row = farmingRowFrames[i]
        if not row then
            row = CreateFrame("Button", nil, content, "BackdropTemplate")
            row:SetSize(440, 20)

            local hl = row:CreateTexture(nil, "HIGHLIGHT")
            hl:SetAllPoints()
            hl:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight")
            hl:SetBlendMode("ADD")
            hl:SetAlpha(0.35)

            local sel = row:CreateTexture(nil, "BORDER")
            sel:SetAllPoints()
            sel:SetColorTexture(1, 0.82, 0, 0.15)
            sel:Hide()
            row.selection = sel

            local headerBg = row:CreateTexture(nil, "BACKGROUND")
            headerBg:SetAllPoints()
            headerBg:SetColorTexture(0.18, 0.14, 0.05, 0.8)
            headerBg:Hide()
            row.headerBg = headerBg

            local icon = row:CreateTexture(nil, "ARTWORK")
            icon:SetSize(16, 16)
            icon:SetPoint("LEFT", row, "LEFT", 2, 0)
            row.icon = icon

            local title = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            title:SetPoint("LEFT", icon, "RIGHT", 4, 0)
            title:SetPoint("RIGHT", row, "LEFT", 210, 0)
            title:SetJustifyH("LEFT")
            title:SetWordWrap(false)
            row.title = title

            local prof = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            prof:SetPoint("LEFT", row, "LEFT", 212, 0)
            prof:SetPoint("RIGHT", row, "LEFT", 372, 0)
            prof:SetJustifyH("LEFT")
            prof:SetWordWrap(false)
            row.prof = prof

            local req = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            req:SetPoint("LEFT", row, "LEFT", 374, 0)
            req:SetPoint("RIGHT", row, "RIGHT", -6, 0)
            req:SetJustifyH("RIGHT")
            req:SetWordWrap(false)
            row.req = req

            farmingRowFrames[i] = row
        end

        row.entry = entry
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
        row:SetSize(490, 20)
        row:Show()

        if entry.type == "header" then
            row.headerBg:Show()
            row.icon:Hide()
            row.title:ClearAllPoints()
            row.title:SetPoint("LEFT", row, "LEFT", 6, 0)
            row.title:SetPoint("RIGHT", row, "RIGHT", -6, 0)
            row.title:SetText("|cFFFFD100" .. entry.text .. "|r")
            row.prof:SetText("")
            row.req:SetText("")
            row.selection:Hide()
            row:EnableMouse(false)
            row:SetHeight(18)
            yOffset = yOffset - 20
        else
            row.headerBg:Hide()
            row.icon:Show()
            row.title:ClearAllPoints()
            row.title:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
            row.title:SetPoint("RIGHT", row, "LEFT", 210, 0)
            row.prof:ClearAllPoints()
            row.prof:SetPoint("LEFT", row, "LEFT", 212, 0)
            row.prof:SetPoint("RIGHT", row, "LEFT", 372, 0)
            row.req:ClearAllPoints()
            row.req:SetPoint("LEFT", row, "LEFT", 374, 0)
            row.req:SetPoint("RIGHT", row, "RIGHT", -6, 0)
            row:EnableMouse(true)
            row:SetHeight(20)

            local isSelected = (selectedFarmingItemData == entry.data)
            row.selection:SetShown(isSelected)

            if entry.type == "material" then
                local mat = entry.data
                local have = GetItemCount(mat.id) or 0
                local need = mat.count or 1
                local itemIcon = GetItemIcon(mat.id) or profData.icon
                row.icon:SetTexture(itemIcon)

                local _, _, itemQuality = GetItemInfo(mat.id)
                local r, g, b = 1, 1, 1
                if itemQuality and ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[itemQuality] then
                    r, g, b = ITEM_QUALITY_COLORS[itemQuality].r, ITEM_QUALITY_COLORS[itemQuality].g, ITEM_QUALITY_COLORS[itemQuality].b
                end
                row.title:SetTextColor(r, g, b)
                row.title:SetText(mat.name)

                row.prof:SetTextColor(0.8, 0.8, 0.8)
                if mat.isVendor then
                    row.prof:SetText("|cFF00FFCCVendedor|r")
                else
                    row.prof:SetText(mat.zone or mat.source or "Mundo")
                end

                if have >= need then
                    row.req:SetText(string.format("|cFF00FF00%d/%d (Listo)|r", have, need))
                elseif have > 0 then
                    row.req:SetText(string.format("|cFFFFCC00%d/%d|r", have, need))
                else
                    row.req:SetText(string.format("|cFFFF44440/%d|r", need))
                end

                row:SetScript("OnClick", function()
                    MainUI:SelectFarmingItem("material", mat, profData, bracketData)
                end)
                row:SetScript("OnDoubleClick", function()
                    MainUI:SelectFarmingItem("material", mat, profData, bracketData)
                end)
                row:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    local _, itemLink = GetItemInfo(mat.id)
                    if itemLink then
                        GameTooltip:SetHyperlink(itemLink)
                    else
                        GameTooltip:SetHyperlink("item:" .. mat.id)
                    end
                    GameTooltip:Show()
                end)
                row:SetScript("OnLeave", function() GameTooltip:Hide() end)

            elseif entry.type == "recipe" then
                local rec = entry.data
                row.icon:SetTexture(profData.icon or "Interface\\Icons\\inv_misc_armorkit_17")
                row.title:SetTextColor(1, 0.82, 0)
                row.title:SetText(string.format("|cFF00FFCC%s|r %s", rec.range, rec.name))
                row.prof:SetTextColor(0.8, 0.8, 0.8)
                row.prof:SetText(rec.mats or "")
                row.req:SetText("|cFF888888Receta|r")

                row:SetScript("OnClick", function()
                    MainUI:SelectFarmingItem("recipe", rec, profData, bracketData)
                end)
                row:SetScript("OnDoubleClick", function()
                    MainUI:SelectFarmingItem("recipe", rec, profData, bracketData)
                end)
                row:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:AddLine(string.format("Receta: %s (%s)", rec.name, rec.range), 1, 0.82, 0)
                    GameTooltip:AddLine(string.format("Materiales: %s", rec.mats or "-"), 1, 1, 1, true)
                    if rec.tip then
                        GameTooltip:AddLine(" ", 1, 1, 1)
                        GameTooltip:AddLine("Guía WoW-Professions:", 0, 1, 0.8)
                        GameTooltip:AddLine(rec.tip, 0.9, 0.9, 0.9, true)
                    end
                    GameTooltip:Show()
                end)
                row:SetScript("OnLeave", function() GameTooltip:Hide() end)

            elseif entry.type == "route" then
                local route = entry.data
                row.icon:SetTexture("Interface\\Icons\\inv_pick_02")
                row.title:SetTextColor(0, 1, 0.8)
                row.title:SetText(route.title)
                row.prof:SetTextColor(0.8, 0.8, 0.8)
                row.prof:SetText(route.zoneName or "Azeroth")
                row.req:SetText(string.format("|cFFFFCC00%d hitos|r", #route.steps))

                row:SetScript("OnClick", function()
                    MainUI:SelectFarmingItem("route", route, profData, bracketData, entry.routeKey)
                end)
                row:SetScript("OnDoubleClick", function()
                    MainUI:SelectFarmingItem("route", route, profData, bracketData, entry.routeKey)
                    if ns.GuideHUD then ns.GuideHUD:StartRoute(route, entry.routeKey) end
                end)
                row:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:AddLine(route.title, 1, 0.82, 0)
                    GameTooltip:AddLine("Zona: " .. (route.zoneName or "Varias"), 1, 1, 1)
                    GameTooltip:AddLine(string.format("Hitos de navegación: %d", #route.steps), 0, 1, 0.8)
                    GameTooltip:AddLine("Doble clic o pulsa 'Iniciar Ruta' para activar la brújula HUD.", 0.7, 0.7, 0.7)
                    GameTooltip:Show()
                end)
                row:SetScript("OnLeave", function() GameTooltip:Hide() end)
            end

            yOffset = yOffset - 22
        end
    end

    for j = #items + 1, #farmingRowFrames do
        farmingRowFrames[j]:Hide()
    end

    content:SetHeight(math.max(10, -yOffset))

    if not selectedFarmingItemData and items[2] and items[2].data then
        local first = items[2]
        self:SelectFarmingItem(first.type, first.data, profData, bracketData, first.routeKey)
    end
end

function MainUI:SelectFarmingItem(itemType, data, profData, bracketData, routeKey)
    selectedFarmingItemType = itemType
    selectedFarmingItemData = data
    if routeKey then selectedFarmingKey = routeKey end

    for _, r in ipairs(farmingRowFrames) do
        if r.selection and r.entry then
            r.selection:SetShown(r.entry.data == data)
        end
    end

    if not mainFrame or not mainFrame.detailTitle or not mainFrame.detailText then return end

    if itemType == "material" then
        local mat = data
        local have = GetItemCount(mat.id) or 0
        local need = mat.count or 1
        self:ShowDetailRewards({ { itemID = mat.id, count = mat.count, name = mat.name } }, "|cFFFFD100Material Requerido:|r")

        mainFrame.detailTitle:SetText(string.format("|cFFFFD100%s|r · |cFF00FFCC%s (%s)|r", mat.name, profData.name, bracketData.name))

        local lines = {}
        local statusStr = (have >= need) and string.format("|cFF00FF00¡Completado! Tienes %d/%d en tus bolsas.|r", have, need)
                           or string.format("|cFFFFCC00En inventario: %d de %d requeridos (%d restantes)|r", have, need, need - have)
        table.insert(lines, statusStr)
        table.insert(lines, "|cFFFFD100Origen / Dónde conseguir:|r " .. (mat.source or "Recolección o Subasta"))
        table.insert(lines, "|cFFFFFFFFZonas recomendadas:|r " .. (mat.zone or " Azeroth"))
        if mat.alternative then
            table.insert(lines, "|cFF00FFCCOpción alternativa (WoW-Professions):|r " .. mat.alternative)
        end
        if mat.isVendor then
            table.insert(lines, "|cFF88AAFFComercio:|r Disponible en el intendente de suministros junto a tu instructor.")
        end
        if bracketData.trainerTip then
            table.insert(lines, "|cFFFFCC00Instructor:|r " .. bracketData.trainerTip)
        end
        mainFrame.detailText:SetText(table.concat(lines, "\n"))

    elseif itemType == "recipe" then
        local rec = data
        self:ShowDetailRewards(nil)
        mainFrame.detailTitle:SetText(string.format("|cFFFFD100Paso %s: %s|r", rec.range, rec.name))

        local lines = {}
        table.insert(lines, string.format("|cFFFFCC00Rango de habilidad:|r %s (%s)", rec.range, profData.name))
        table.insert(lines, "|cFFFFFFFFMateriales por unidad:|r " .. (rec.mats or "-"))
        if rec.tip then
            table.insert(lines, "|cFF00FFCCGuía de subida (WoW-Professions Forever):|r\n" .. rec.tip)
        end
        if bracketData.trainerTip then
            table.insert(lines, "|cFFFFD100Instructor del tramo:|r " .. bracketData.trainerTip)
        end
        mainFrame.detailText:SetText(table.concat(lines, "\n"))

    elseif itemType == "route" then
        local route = data
        self:ShowDetailRewards(nil)
        mainFrame.detailTitle:SetText(string.format("|cFFFFD100%s|r · |cFF00FFCC%s|r", route.title, route.zoneName or "Azeroth"))

        local lines = {}
        table.insert(lines, string.format("|cFFFFCC00Zona:|r %s  ·  |cFFFFFFFFRequerido:|r %s", route.zoneName or "Varias", bracketData.name))
        table.insert(lines, string.format("|cFF00FFCC%d hitos de navegación GuideHUD trazados|r", #route.steps))
        for idx, s in ipairs(route.steps) do
            table.insert(lines, string.format("  |cFFFFD100%d.|r %s: %s", idx, s.title or "Hito", s.instruction or ""))
        end
        table.insert(lines, "\n|cFF88AAFFConsejo:|r Pulsa 'Iniciar Ruta' o haz doble clic para activar la brújula 3D.")
        mainFrame.detailText:SetText(table.concat(lines, "\n"))
    end
end

function MainUI:SelectFarming(key, route)
    selectedFarmingKey = key
    route = route or (ns.Data.Farming and ns.Data.Farming[key])
    if not route then return end
    local profData = ns.Data.ProfessionGuides and ns.Data.ProfessionGuides[route.profession or selectedFarmingProfKey or "Leatherworking"]
    local bracketData = profData and profData.brackets and (profData.brackets["1-75"])
    self:SelectFarmingItem("route", route, profData or { name = route.profession or "Farmeo" }, bracketData or { name = "General" }, key)
end

-- =========================================================================
-- VISTA 3: HERMANDAD AWAKENING (ROSTER)
-- =========================================================================
function MainUI:BuildGuildList(parent)
    local isMember = ns.IsAwakeningGuildMember()
    
    if not isMember then
        local lockText = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        lockText:SetPoint("CENTER", parent, "CENTER", 0, 10)
        lockText:SetWidth(360)
        lockText:SetJustifyH("CENTER")
        lockText:SetText("|cFFFF4444Acceso Exclusivo de Hermandad|r\n\nEl roster interno y herramientas de sincronización están reservados para miembros de |cFF00FFCC<Awakening>|r.\n\nÚnete en nuestro Discord para desbloquearlas.")
        return
    end

    local scroll = CreateFrame("ScrollFrame", "AwakeningGuildScroll", parent, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, -2)
    scroll:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -20, 2)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(440, 10)
    scroll:SetScrollChild(content)
    parent.content = content

    -- Lista de miembros si ns.GuildRoster está cargado
    if ns.GuildRoster and ns.GuildRoster.Build then
        ns.GuildRoster:Build(content)
    end
end

-- =========================================================================
-- VISTA 4: PREPARACIÓN DINÁMICA (LEVELEO, MAZMORRAS Y BANDA)
-- =========================================================================
function MainUI:BuildRaidPrepList(parent)
    if ns.RaidPrep and ns.RaidPrep.Build then
        ns.RaidPrep:Build(parent)
    end
end

-- =========================================================================
-- VISTA: PLANEADOR DE VIAJE (INSPIRADO EN CHAIRFACE'S CASINO)
-- =========================================================================
local travelPicker

local function EnsureTravelPicker()
    if travelPicker then return travelPicker end

    local popup = CreateFrame("Frame", "AwakeningTravelPicker", UIParent, "BackdropTemplate")
    popup:SetSize(300, 360)
    popup:SetFrameStrata("DIALOG")
    popup:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 2,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    popup:SetBackdropColor(0.04, 0.05, 0.07, 0.98)
    popup:SetBackdropBorderColor(0.7, 0.55, 0.2, 1)
    popup:Hide()
    popup:EnableMouse(true)

    local title = popup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", popup, "TOPLEFT", 10, -10)
    title:SetText("|cFFFFD100Seleccionar Destino|r")
    popup.title = title

    local btnClose = CreateFrame("Button", nil, popup, "UIPanelCloseButton")
    btnClose:SetSize(18, 18)
    btnClose:SetPoint("TOPRIGHT", popup, "TOPRIGHT", -4, -4)
    btnClose:SetScript("OnClick", function() popup:Hide() end)

    -- Caja de búsqueda en tiempo real
    local searchBox = CreateFrame("EditBox", nil, popup, "BackdropTemplate")
    searchBox:SetSize(276, 22)
    searchBox:SetPoint("TOPLEFT", popup, "TOPLEFT", 12, -32)
    searchBox:SetAutoFocus(false)
    searchBox:SetFontObject("GameFontHighlightSmall")
    searchBox:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    searchBox:SetBackdropColor(0.08, 0.09, 0.12, 0.9)
    searchBox:SetBackdropBorderColor(0.35, 0.45, 0.55, 0.8)
    searchBox:SetTextInsets(6, 6, 0, 0)
    popup.searchBox = searchBox

    local searchPlaceholder = searchBox:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    searchPlaceholder:SetPoint("LEFT", searchBox, "LEFT", 6, 0)
    searchPlaceholder:SetText("Buscar ciudad o zona...")
    popup.searchPlaceholder = searchPlaceholder

    searchBox:SetScript("OnTextChanged", function(selfBox)
        local text = selfBox:GetText()
        if text and text ~= "" then
            searchPlaceholder:Hide()
        else
            searchPlaceholder:Show()
        end
        if popup.FilterRows then popup:FilterRows(text) end
    end)
    searchBox:SetScript("OnEscapePressed", function(selfBox)
        selfBox:ClearFocus()
        popup:Hide()
    end)

    local scroll = CreateFrame("ScrollFrame", "AwakeningTravelPickerScroll", popup, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", popup, "TOPLEFT", 8, -60)
    scroll:SetPoint("BOTTOMRIGHT", popup, "BOTTOMRIGHT", -26, 8)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(250, 10)
    scroll:SetScrollChild(content)

    popup.scroll = scroll
    popup.content = content
    popup.rows = {}
    popup.allItems = {}

    function popup:FilterRows(filterText)
        local norm = filterText and (tostring(filterText):lower():gsub("^%s+", ""):gsub("%s+$", "")) or ""
        for _, row in ipairs(popup.rows) do row:Hide() end

        local yOffset = 0
        local visibleIndex = 0

        for _, item in ipairs(popup.allItems) do
            local match = true
            if norm ~= "" and not item.isHeader then
                local nName = item.text:lower()
                local nZone = (item.zone or ""):lower()
                match = (nName:find(norm, 1, true) or nZone:find(norm, 1, true))
            end

            if match then
                visibleIndex = visibleIndex + 1
                local row = popup.rows[visibleIndex]
                if not row then
                    row = CreateFrame("Button", nil, popup.content, "BackdropTemplate")
                    row:SetHeight(20)
                    row:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
                    row:SetBackdropColor(0, 0, 0, 0)

                    local hl = row:CreateTexture(nil, "HIGHLIGHT")
                    hl:SetAllPoints(row)
                    hl:SetColorTexture(1, 1, 1, 0.08)

                    local icon = row:CreateTexture(nil, "ARTWORK")
                    icon:SetSize(14, 14)
                    icon:SetPoint("LEFT", row, "LEFT", 4, 0)
                    row.icon = icon

                    local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                    label:SetPoint("LEFT", icon, "RIGHT", 6, 0)
                    label:SetPoint("RIGHT", row, "RIGHT", -4, 0)
                    label:SetJustifyH("LEFT")
                    row.label = label

                    popup.rows[visibleIndex] = row
                end

                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", popup.content, "TOPLEFT", 0, -yOffset)
                row:SetPoint("RIGHT", popup.content, "RIGHT", 0, 0)

                if item.isHeader then
                    row.icon:Hide()
                    row.label:SetPoint("LEFT", row, "LEFT", 4, 0)
                    row.label:SetText("|cFFAAAAAA" .. item.text .. "|r")
                    row:EnableMouse(false)
                else
                    row.icon:Show()
                    row.icon:SetTexture(item.icon or "Interface\\Icons\\inv_misc_map_01")
                    row.label:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
                    row.label:SetText(item.text)
                    row:EnableMouse(true)
                    row:SetScript("OnClick", function()
                        popup:Hide()
                        if popup.onPick then popup.onPick(item.id, item.rawName) end
                    end)
                end

                row:Show()
                yOffset = yOffset + 20
            end
        end

        popup.content:SetHeight(math.max(10, yOffset))
    end

    travelPicker = popup
    return popup
end

local function BuildTravelZoneMenu(anchorBtn, onPick, includePlayerOption)
    local travel = ns.Data and ns.Data.Travel
    if not travel or not travel.nodes then return end

    local popup = EnsureTravelPicker()
    popup.onPick = onPick
    popup.allItems = {}
    if popup.searchBox then
        popup.searchBox:SetText("")
        popup.searchBox:SetFocus()
    end

    if includePlayerOption then
        table.insert(popup.allItems, {
            id = "__player__",
            rawName = "Mi ubicación actual",
            text = "|cFF00FFCCUsar mi ubicación actual|r",
            icon = "Interface\\Icons\\inv_misc_map_01",
            isHeader = false,
        })
    end

    -- Opción de Marcador del mapa (Pin / TomTom) - Inspirado en WaypointService de Mapzeroth
    local hasWaypoint = false
    if C_Map and C_Map.GetUserWaypoint and C_Map.GetUserWaypoint() then
        hasWaypoint = true
    elseif _G.TomTom and _G.TomTom.waypoints and next(_G.TomTom.waypoints) then
        hasWaypoint = true
    end

    table.insert(popup.allItems, {
        id = "__waypoint__",
        rawName = "Marcador del mapa (Pin)",
        text = hasWaypoint and "|cFFFFD100Marcador del mapa (Pin activo)|r" or "|cFF888888Marcador del mapa (Sin pin activo)|r",
        icon = "Interface\\Icons\\inv_misc_map_01",
        isHeader = false,
    })

    -- Opción de Piedra de Hogar
    local hs = AwakeningDB and AwakeningDB.hearthstone
    local hsBind = (hs and hs.locationName) or (GetBindLocation and GetBindLocation())
    if hsBind and hsBind ~= "" then
        table.insert(popup.allItems, {
            id = "__hearthstone__",
            rawName = "Piedra de Hogar: " .. hsBind,
            text = string.format("|cFF00FF00Piedra de Hogar: %s|r", hsBind),
            icon = "Interface\\Icons\\inv_misc_rune_01",
            isHeader = false,
        })
    end

    local byContinent = {}
    local continentOrder = {}
    for id, node in pairs(travel.nodes) do
        local cont = node.continent or "Otros"
        if not byContinent[cont] then
            byContinent[cont] = {}
            table.insert(continentOrder, cont)
        end
        table.insert(byContinent[cont], { id = id, node = node })
    end
    table.sort(continentOrder)
    for _, cont in ipairs(continentOrder) do
        table.sort(byContinent[cont], function(a, b) return a.node.name < b.node.name end)
    end

    for _, cont in ipairs(continentOrder) do
        table.insert(popup.allItems, { text = "--- " .. cont .. " ---", isHeader = true })
        for _, entry in ipairs(byContinent[cont]) do
            local modeIcon = (entry.node.type == "tram") and "Interface\\Icons\\inv_misc_gear_01"
                or (entry.node.type == "boat") and "Interface\\Icons\\inv_misc_map_01"
                or (entry.node.type == "zeppelin") and "Interface\\Icons\\inv_misc_bag_08"
                or "Interface\\Icons\\ability_mount_ridinghorse"

            table.insert(popup.allItems, {
                id = entry.id,
                rawName = entry.node.name,
                zone = entry.node.zoneName,
                text = string.format("%s |cFF888888(%s)|r", entry.node.name, entry.node.zoneName),
                icon = modeIcon,
                isHeader = false,
            })
        end
    end

    popup:FilterRows("")
    popup:ClearAllPoints()
    popup:SetPoint("TOPLEFT", anchorBtn, "BOTTOMLEFT", 0, -4)
    popup:Show()
end

-- =========================================================================
-- CONSTRUCCIÓN DE LA VISTA COMPLETA DE VIAJES (Estilo Casino)
-- =========================================================================
function MainUI:BuildTravelView(parent)
    -- Contenedor izquierdo: Selectores, toggles y accesos rápidos (230px)
    local leftCol = CreateFrame("Frame", nil, parent)
    leftCol:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, -2)
    leftCol:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 2, 2)
    leftCol:SetWidth(230)
    parent.leftCol = leftCol

    -- Contenedor derecho: Previsualización interactiva de etapas/itinerario (288px)
    local rightCol = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    rightCol:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -2, -2)
    rightCol:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -2, 2)
    rightCol:SetWidth(288)
    rightCol:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    rightCol:SetBackdropColor(0.03, 0.04, 0.06, 0.9)
    rightCol:SetBackdropBorderColor(0.25, 0.35, 0.45, 0.8)
    parent.rightCol = rightCol

    -- 1. Botón de Origen (Icono nativo de mapa en lugar de emoji)
    local btnFrom = CreateFrame("Button", nil, leftCol, "BackdropTemplate")
    btnFrom:SetSize(198, 26)
    btnFrom:SetPoint("TOPLEFT", leftCol, "TOPLEFT", 0, -4)
    btnFrom:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    btnFrom:SetBackdropColor(0.08, 0.1, 0.14, 0.95)
    btnFrom:SetBackdropBorderColor(0.3, 0.5, 0.7, 0.9)

    local btnFromText = btnFrom:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btnFromText:SetPoint("LEFT", btnFrom, "LEFT", 6, 0)
    btnFromText:SetPoint("RIGHT", btnFrom, "RIGHT", -6, 0)
    btnFromText:SetJustifyH("LEFT")
    btnFromText:SetWordWrap(false)
    btnFromText:SetText("|TInterface\\Icons\\inv_misc_map_01:13:13:0:0|t |cFF00FFCCOrigen: Mi ubicación|r")
    btnFrom.text = btnFromText
    parent.travelFromBtn = btnFrom

    -- Botón de intercambio de origen/destino [<->]
    local btnSwap = CreateFrame("Button", nil, leftCol, "BackdropTemplate")
    btnSwap:SetSize(26, 26)
    btnSwap:SetPoint("LEFT", btnFrom, "RIGHT", 4, 0)
    btnSwap:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    btnSwap:SetBackdropColor(0.12, 0.12, 0.16, 0.9)
    btnSwap:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.8)
    local swapText = btnSwap:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    swapText:SetPoint("CENTER")
    swapText:SetText("<->")
    btnSwap:SetScript("OnClick", function()
        local tmp = selectedTravelFrom
        selectedTravelFrom = selectedTravelTo
        selectedTravelTo = tmp
        MainUI:UpdateTravelView()
    end)
    btnSwap:SetScript("OnEnter", function(s)
        s:SetBackdropBorderColor(1, 0.84, 0, 1)
        GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
        GameTooltip:SetText("Invertir Origen y Destino")
        GameTooltip:Show()
    end)
    btnSwap:SetScript("OnLeave", function(s)
        s:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.8)
        GameTooltip:Hide()
    end)

    -- 2. Botón de Destino (Icono nativo de estandarte en lugar de emoji)
    local btnTo = CreateFrame("Button", nil, leftCol, "BackdropTemplate")
    btnTo:SetSize(228, 26)
    btnTo:SetPoint("TOPLEFT", btnFrom, "BOTTOMLEFT", 0, -6)
    btnTo:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    btnTo:SetBackdropColor(0.08, 0.1, 0.14, 0.95)
    btnTo:SetBackdropBorderColor(0.7, 0.55, 0.2, 0.9)

    local btnToText = btnTo:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btnToText:SetPoint("LEFT", btnTo, "LEFT", 6, 0)
    btnToText:SetPoint("RIGHT", btnTo, "RIGHT", -6, 0)
    btnToText:SetJustifyH("LEFT")
    btnToText:SetWordWrap(false)
    btnToText:SetText("|TInterface\\Icons\\inv_banner_03:13:13:0:0|t |cFFFFD100Destino: (ninguno)|r")
    btnTo.text = btnToText
    parent.travelToBtn = btnTo

    btnFrom:SetScript("OnClick", function(selfBtn)
        BuildTravelZoneMenu(selfBtn, function(id, label)
            selectedTravelFrom = id
            MainUI:UpdateTravelView()
        end, true)
    end)

    btnTo:SetScript("OnClick", function(selfBtn)
        BuildTravelZoneMenu(selfBtn, function(id, label)
            selectedTravelTo = id
            MainUI:UpdateTravelView()
        end, false)
    end)

    -- 3. Selector de Modo Segmentado (Iconos nativos sprint y escudo)
    local modeLabel = leftCol:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    modeLabel:SetPoint("TOPLEFT", btnTo, "BOTTOMLEFT", 2, -8)
    modeLabel:SetText("Prioridad de ruta:")

    local function makeModeBtn(text, x)
        local b = CreateFrame("Button", nil, leftCol, "BackdropTemplate")
        b:SetSize(112, 22)
        b:SetPoint("TOPLEFT", leftCol, "TOPLEFT", x, -92)
        b:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
        b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        b.text:SetPoint("CENTER")
        b.text:SetText(text)
        return b
    end

    local fastBtn = makeModeBtn("|TInterface\\Icons\\ability_rogue_sprint:13:13:0:0|t Rápido", 0)
    local safeBtn = makeModeBtn("|TInterface\\Icons\\inv_shield_04:13:13:0:0|t Seguro", 116)

    local function paintTravelMode()
        local onBg   = { 0.15, 0.35, 0.2, 1 }
        local onBdr  = { 0.4, 0.9, 0.5, 1 }
        local offBg  = { 0.08, 0.08, 0.1, 0.9 }
        local offBdr = { 0.25, 0.25, 0.3, 0.8 }

        if selectedTravelMode == "fastest" then
            fastBtn:SetBackdropColor(unpack(onBg))
            fastBtn:SetBackdropBorderColor(unpack(onBdr))
            safeBtn:SetBackdropColor(unpack(offBg))
            safeBtn:SetBackdropBorderColor(unpack(offBdr))
        else
            safeBtn:SetBackdropColor(unpack(onBg))
            safeBtn:SetBackdropBorderColor(unpack(onBdr))
            fastBtn:SetBackdropColor(unpack(offBg))
            fastBtn:SetBackdropBorderColor(unpack(offBdr))
        end
    end

    fastBtn:SetScript("OnClick", function()
        selectedTravelMode = "fastest"
        paintTravelMode()
        MainUI:UpdateTravelView()
    end)
    safeBtn:SetScript("OnClick", function()
        selectedTravelMode = "safest"
        paintTravelMode()
        MainUI:UpdateTravelView()
    end)
    paintTravelMode()

    -- 4. Rejilla de Destinos Rápidos (Grid de Capitales ancho: 74px por botón)
    local hubsTitle = leftCol:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hubsTitle:SetPoint("TOPLEFT", leftCol, "TOPLEFT", 2, -122)
    hubsTitle:SetText("|cFFFFD100Destinos Rápidos:|r")

    local hubs = ns.TravelPlanner and ns.TravelPlanner:GetPopularDestinations() or {}
    leftCol.hubButtons = {}

    for i = 1, 6 do
        local hub = hubs[i]
        local row = math.floor((i - 1) / 2)
        local col = (i - 1) % 2

        local hBtn = CreateFrame("Button", nil, leftCol, "BackdropTemplate")
        hBtn:SetSize(112, 26)
        hBtn:SetPoint("TOPLEFT", leftCol, "TOPLEFT", col * 116, -138 - (row * 30))
        hBtn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        hBtn:SetBackdropColor(0.08, 0.08, 0.12, 0.9)
        hBtn:SetBackdropBorderColor(0.3, 0.4, 0.5, 0.8)

        local hIcon = hBtn:CreateTexture(nil, "ARTWORK")
        hIcon:SetSize(18, 18)
        hIcon:SetPoint("LEFT", hBtn, "LEFT", 4, 0)
        if hIcon.SetMask then
            hIcon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask")
        end
        hBtn.icon = hIcon

        local hLabel = hBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        hLabel:SetPoint("LEFT", hIcon, "RIGHT", 4, 0)
        hLabel:SetPoint("RIGHT", hBtn, "RIGHT", -4, 0)
        hLabel:SetJustifyH("LEFT")
        hLabel:SetWordWrap(false)
        hBtn.label = hLabel

        if hub then
            hIcon:SetTexture(hub.icon or "Interface\\Icons\\inv_misc_map_01")
            hLabel:SetText(hub.name)
            hBtn:SetScript("OnEnter", function(s)
                s:SetBackdropColor(0.15, 0.25, 0.18, 1)
                s:SetBackdropBorderColor(0.4, 0.9, 0.5, 1)
                GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
                GameTooltip:AddLine(hub.name, 1, 0.84, 0)
                GameTooltip:AddLine(hub.continent or "", 0.7, 0.7, 0.7)
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("|cFF00FF00Clic Izquierdo:|r Fijar como Destino", 0.9, 0.9, 0.9)
                GameTooltip:AddLine("|cFF00CCFFClic Derecho:|r Fijar como Origen", 0.9, 0.9, 0.9)
                GameTooltip:Show()
            end)
            hBtn:SetScript("OnLeave", function(s)
                s:SetBackdropColor(0.08, 0.08, 0.12, 0.9)
                s:SetBackdropBorderColor(0.3, 0.4, 0.5, 0.8)
                GameTooltip:Hide()
            end)
            hBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
            hBtn:SetScript("OnClick", function(_, btn)
                if btn == "RightButton" then
                    selectedTravelFrom = hub.id
                else
                    selectedTravelTo = hub.id
                end
                MainUI:UpdateTravelView()
            end)
        else
            hBtn:Hide()
        end

        leftCol.hubButtons[i] = hBtn
    end

    -- 5. Columna Derecha: Tarjeta de Itinerario / Etapas
    local rightHeader = rightCol:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rightHeader:SetPoint("TOPLEFT", rightCol, "TOPLEFT", 8, -6)
    rightHeader:SetText("|cFFFFD100Itinerario en Tiempo Real|r")

    local legScroll = CreateFrame("ScrollFrame", "AwakeningTravelLegScroll", rightCol, "UIPanelScrollFrameTemplate")
    legScroll:SetPoint("TOPLEFT", rightCol, "TOPLEFT", 6, -24)
    legScroll:SetPoint("BOTTOMRIGHT", rightCol, "BOTTOMRIGHT", -22, 6)

    local legContent = CreateFrame("Frame", nil, legScroll)
    legContent:SetSize(260, 10)
    legScroll:SetScrollChild(legContent)
    rightCol.legScroll = legScroll
    rightCol.legContent = legContent
    rightCol.legRows = {}

    -- Mensaje de estado cuando no hay ruta calculada
    local emptyMsg = rightCol:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    emptyMsg:SetPoint("CENTER", rightCol, "CENTER", 0, -10)
    emptyMsg:SetWidth(250)
    emptyMsg:SetJustifyH("CENTER")
    emptyMsg:SetText("Elige origen y destino para visualizar los vuelos, barcos, tranvía y tiempos de viaje.")
    rightCol.emptyMsg = emptyMsg
end

-- =========================================================================
-- ACTUALIZACIÓN DINÁMICA DE LA VISTA DE VIAJE (Tarjeta de Embarque)
-- =========================================================================
function MainUI:UpdateTravelView()
    local v = viewsByKey["travel"]
    if not v or not v.leftCol then return end

    local travel = ns.Data and ns.Data.Travel
    local fromNode = travel and travel.nodes and (type(selectedTravelFrom) == "string" and travel.nodes[selectedTravelFrom] or nil)
    local toNode = travel and travel.nodes and (type(selectedTravelTo) == "string" and travel.nodes[selectedTravelTo] or nil)

    -- 1. Actualizar textos de los botones de origen y destino con iconos nativos (cero emojis)
    if v.travelFromBtn and v.travelFromBtn.text then
        if selectedTravelFrom == "__player__" or not selectedTravelFrom then
            v.travelFromBtn.text:SetText("|TInterface\\Icons\\inv_misc_map_01:13:13:0:0|t |cFF00FFCCOrigen: Mi ubicación|r")
            selectedTravelFrom = "__player__"
        elseif selectedTravelFrom == "__waypoint__" then
            v.travelFromBtn.text:SetText("|TInterface\\Icons\\inv_misc_map_01:13:13:0:0|t |cFFFFD100Origen: Marcador (Pin)|r")
        elseif selectedTravelFrom == "__hearthstone__" then
            v.travelFromBtn.text:SetText("|TInterface\\Icons\\inv_misc_rune_01:13:13:0:0|t |cFF00FF00Origen: Piedra de Hogar|r")
        elseif fromNode then
            v.travelFromBtn.text:SetText(string.format("|TInterface\\Icons\\inv_misc_map_01:13:13:0:0|t |cFF00FFCCOrigen: %s|r", fromNode.name))
        else
            v.travelFromBtn.text:SetText("|TInterface\\Icons\\inv_misc_map_01:13:13:0:0|t |cFF888888Origen: (ninguno)|r")
        end
    end

    if v.travelToBtn and v.travelToBtn.text then
        if type(selectedTravelTo) == "table" then
            local label = selectedTravelTo.name or selectedTravelTo.title or "Hito de Secreto"
            v.travelToBtn.text:SetText(string.format("|TInterface\\Icons\\inv_misc_book_09:13:13:0:0|t |cFFFFD100Destino: %s|r", label))
        elseif selectedTravelTo == "__waypoint__" then
            v.travelToBtn.text:SetText("|TInterface\\Icons\\inv_misc_map_01:13:13:0:0|t |cFFFFD100Destino: Marcador (Pin)|r")
        elseif selectedTravelTo == "__hearthstone__" then
            v.travelToBtn.text:SetText("|TInterface\\Icons\\inv_misc_rune_01:13:13:0:0|t |cFF00FF00Destino: Piedra de Hogar|r")
        elseif toNode then
            v.travelToBtn.text:SetText(string.format("|TInterface\\Icons\\inv_banner_03:13:13:0:0|t |cFFFFD100Destino: %s|r", toNode.name))
        else
            v.travelToBtn.text:SetText("|TInterface\\Icons\\inv_banner_03:13:13:0:0|t |cFFFFD100Destino: (ninguno)|r")
        end
    end

    -- 2. Limpiar filas de itinerario
    for _, row in ipairs(v.rightCol.legRows) do row:Hide() end

    -- 3. Calcular la ruta si ambos extremos están definidos
    if selectedTravelFrom and selectedTravelTo then
        currentTravelPlan = ns.TravelPlanner:CalculateRoute(selectedTravelFrom, selectedTravelTo, {
            routingMode = selectedTravelMode or "fastest",
            checkHearthstone = true,
        })
    else
        currentTravelPlan = nil
    end

    local plan = currentTravelPlan

    if plan and plan.success and plan.legs and #plan.legs > 0 then
        v.rightCol.emptyMsg:Hide()

        local yOffset = 0
        local modeNames = {
            flight    = "|cFF88AAFFMaestro de Vuelos|r",
            walk      = "|cFF00FF00A pie / Camino|r",
            tram      = "|cFFFFD100Tranvía Gnomo|r",
            boat      = "|cFF44AAFFBarco marítimo|r",
            zeppelin  = "|cFFFF8844Zepelín Horda|r",
            swim      = "|cFF33CCFFNado seguro|r",
            portal    = "|cFF00FFFFPortal Mágico|r",
        }

        for i, leg in ipairs(plan.legs) do
            local row = v.rightCol.legRows[i]
            if not row then
                row = CreateFrame("Frame", nil, v.rightCol.legContent, "BackdropTemplate")
                row:SetHeight(48)
                row:SetBackdrop({
                    bgFile = "Interface\\Buttons\\WHITE8x8",
                    edgeFile = "Interface\\Buttons\\WHITE8x8",
                    edgeSize = 1,
                })
                row:SetBackdropColor(0.06, 0.07, 0.1, 0.85)
                row:SetBackdropBorderColor(0.2, 0.3, 0.4, 0.8)

                local icon = row:CreateTexture(nil, "ARTWORK")
                icon:SetSize(24, 24)
                icon:SetPoint("LEFT", row, "LEFT", 6, 0)
                if icon.SetMask then
                    icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask")
                end
                row.icon = icon

                -- Fila Superior: Título (Izquierda) y Duración (Derecha)
                local dur = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                dur:SetPoint("TOPRIGHT", row, "TOPRIGHT", -8, -6)
                dur:SetHeight(14)
                dur:SetJustifyH("RIGHT")
                row.dur = dur

                local title = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                title:SetPoint("TOPLEFT", row, "TOPLEFT", 36, -6)
                title:SetPoint("RIGHT", dur, "LEFT", -6, 0)
                title:SetHeight(14)
                title:SetJustifyH("LEFT")
                title:SetWordWrap(false)
                row.title = title

                -- Fila Inferior: Tipo de transporte (Izquierda) y Coste (Derecha)
                local cost = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                cost:SetPoint("BOTTOMRIGHT", row, "BOTTOMRIGHT", -8, 6)
                cost:SetHeight(14)
                cost:SetJustifyH("RIGHT")
                row.cost = cost

                local sub = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
                sub:SetPoint("BOTTOMLEFT", row, "BOTTOMLEFT", 36, 6)
                sub:SetPoint("RIGHT", cost, "LEFT", -6, 0)
                sub:SetHeight(14)
                sub:SetJustifyH("LEFT")
                sub:SetWordWrap(false)
                row.sub = sub

                row:EnableMouse(true)
                row:SetScript("OnEnter", function(s)
                    s:SetBackdropColor(0.12, 0.16, 0.22, 1)
                    s:SetBackdropBorderColor(0.4, 0.6, 0.8, 1)
                    if GameTooltip and s.legData then
                        GameTooltip:SetOwner(s, "ANCHOR_RIGHT")
                        GameTooltip:AddLine(string.format("Etapa %d: %s", s.legIndex or 1, s.legData.toName or ""), 1, 0.84, 0)
                        if s.legData.fromName then
                            GameTooltip:AddLine(string.format("Origen: %s", s.legData.fromName), 0.8, 0.8, 0.8)
                        end
                        GameTooltip:AddLine(string.format("Tiempo estimado: ~%.1f min", s.legData.minutes or 1), 0.7, 0.9, 0.7)
                        if s.legData.costCopper and s.legData.costCopper > 0 then
                            GameTooltip:AddLine("Coste: " .. ns.TravelPlanner:FormatMoney(s.legData.costCopper), 1, 1, 1)
                        end
                        if s.legData.danger then
                            GameTooltip:AddLine("Peligro: " .. s.legData.danger, 1, 0.3, 0.3)
                        end
                        if s.legData.tip then
                            GameTooltip:AddLine(" ")
                            GameTooltip:AddLine("Consejo: " .. s.legData.tip, 0, 1, 0.8, true)
                        end
                        GameTooltip:Show()
                    end
                end)
                row:SetScript("OnLeave", function(s)
                    s:SetBackdropColor(0.06, 0.07, 0.1, 0.85)
                    s:SetBackdropBorderColor(0.2, 0.3, 0.4, 0.8)
                    if GameTooltip then GameTooltip:Hide() end
                end)

                v.rightCol.legRows[i] = row
            end

            row.legData = leg
            row.legIndex = i

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", v.rightCol.legContent, "TOPLEFT", 0, -yOffset)
            row:SetPoint("RIGHT", v.rightCol.legContent, "RIGHT", 0, 0)

            row.icon:SetTexture(leg.icon or "Interface\\Icons\\inv_misc_map_01")
            row.title:SetText(string.format("%d. %s", i, leg.toName))
            row.dur:SetText(string.format("~%.1f min", leg.minutes or 1))

            local costText = (leg.costCopper and leg.costCopper > 0) and ns.TravelPlanner:FormatMoney(leg.costCopper) or "|cFF888888Gratis|r"
            row.cost:SetText(costText)

            local subText = modeNames[leg.mode] or "Transporte"
            if leg.isInitialPlayerHop then
                if leg.toNode and leg.toNode.type == "boat" then
                    subText = "|cFF88CC88A pie / Ir al Puerto|r"
                elseif leg.toNode and leg.toNode.type == "tram" then
                    subText = "|cFF88CC88A pie / Ir al Tranvía|r"
                elseif leg.toNode and leg.toNode.type == "flightmaster" then
                    subText = "|cFF88CC88A pie / Ir al Maestro|r"
                else
                    subText = "|cFF88CC88A pie / Camino|r"
                end
            elseif leg.danger then
                subText = subText .. " |cFFFF5533· Peligro|r"
            end
            row.sub:SetText(subText)

            row:Show()
            yOffset = yOffset + 52
        end

        v.rightCol.legContent:SetHeight(math.max(10, yOffset))

        -- Actualizar la Caja de Detalles (Boarding Pass inferior)
        if mainFrame and mainFrame.detailTitle and mainFrame.detailText then
            mainFrame.detailTitle:SetText(string.format("|cFFFFD100Itinerario:|r %s (%d etapa%s)",
                plan.guideData.title, #plan.legs, (#plan.legs == 1) and "" or "s"))

            local costFmt = ns.TravelPlanner:FormatMoney(plan.totalCostCopper)
            local dangerColor = (plan.dangerRating == "Bajo") and "|cFF00FF00Bajo|r" or "|cFFFF8800Moderado|r"

            local line1 = string.format("Tiempo: |cFF00FF00~%.1f min|r   |   Coste: %s   |   Peligro: %s",
                plan.totalMinutes or 0, costFmt, dangerColor)

            local line2 = "Pulsa '|cFFFFD100Iniciar Guía|r' para sincronizar la Crazy Arrow 3D de TomTom."
            if plan.missingDiscoveries and #plan.missingDiscoveries > 0 then
                line2 = string.format("|cFFFFBB00Nota:|r Habla con el maestro de vuelos en: %s",
                    table.concat(plan.missingDiscoveries, ", "))
            elseif plan.hearthstone and plan.hearthstone.isBeneficial then
                line2 = string.format("|cFF00FF00¡Atajo disponible!|r Usar tu Piedra de Hogar en %s te ahorra |cFFFFD100~%.1f min|r de viaje.",
                    plan.hearthstone.bindLocation or "tu posada", plan.hearthstone.timeSaved or 0)
            elseif plan.hearthstone and plan.hearthstone.available then
                line2 = string.format("|cFF00FFFFPiedra de Hogar lista:|r Vinculada en %s.",
                    plan.hearthstone.bindLocation or "tu posada")
            end

            mainFrame.detailText:SetText(line1 .. "\n" .. line2)
        end
    else
        v.rightCol.emptyMsg:Show()
        if plan and not plan.success then
            v.rightCol.emptyMsg:SetText("|cFFFF4444" .. (plan.error or "No se pudo calcular la ruta.") .. "|r")
        else
            v.rightCol.emptyMsg:SetText("Elige origen y destino para visualizar los vuelos, barcos, tranvía y tiempos de viaje.")
        end

        if mainFrame and mainFrame.detailTitle and mainFrame.detailText then
            mainFrame.detailTitle:SetText("|cFFFFD100Planeador de Viaje|r · Preparado")
            mainFrame.detailText:SetText("Selecciona una ciudad o maestro de vuelo de origen y destino.\nPuedes hacer clic en los 'Destinos Rápidos' de la izquierda para seleccionar al instante.")
        end
    end

    self:UpdateBottomButtons()
end



-- =========================================================================
-- ACCIONES DE LOS 3 BOTONES INFERIORES
-- =========================================================================
function MainUI:OnActionButton1()
    local currentKey = TABS_CONFIG[currentTab] and TABS_CONFIG[currentTab].key
    if currentKey == "bis" then
        self:SetBiSWaypoint()
    elseif currentKey == "secrets" then
        local curMilestone = (ns.GetSecretProgress and ns.GetSecretProgress(selectedSecretKey)) or 1
        local guideData, startStep = ns.GetDynamicSecretGuide and ns.GetDynamicSecretGuide(selectedSecretKey, curMilestone)
        if not guideData then
            guideData = (ns.GetSecret and ns.GetSecret(selectedSecretKey)) or (ns.Data.Secrets and ns.Data.Secrets[selectedSecretKey])
            startStep = curMilestone
        end
        if guideData and ns.GuideHUD then
            ns.GuideHUD:StartRoute(guideData, selectedSecretKey, startStep)

            if guideData.isDynamicTravel then
                ns.Print(string.format("|cFF00FFCCRuta dinámica activa:|r Guiando hacia el hito %d (%s etapas).",
                    curMilestone, (guideData.steps and #guideData.steps) or 1))
            end
        end
    elseif currentKey == "farming" then
        if selectedFarmingItemType == "route" and selectedFarmingItemData and ns.GuideHUD then
            ns.GuideHUD:StartRoute(selectedFarmingItemData, selectedFarmingKey or "farming_route")
        else
            local route = ns.Data.Farming and ns.Data.Farming[selectedFarmingKey]
            if not route then
                local profData = ns.Data.ProfessionGuides and ns.Data.ProfessionGuides[selectedFarmingProfKey or "Leatherworking"]
                local playerProfs = ns.GetPlayerProfessions()
                local profRank = (playerProfs[selectedFarmingProfKey] and playerProfs[selectedFarmingProfKey].rank) or 0
                local activeBracketKey = selectedFarmingBracket
                if activeBracketKey == "auto" then
                    if profRank < 75 then activeBracketKey = "1-75"
                    elseif profRank < 150 then activeBracketKey = "75-150"
                    elseif profRank < 225 then activeBracketKey = "150-225"
                    else activeBracketKey = "225-300" end
                end
                local bracketData = profData and profData.brackets and (profData.brackets[activeBracketKey] or profData.brackets["1-75"])
                route = bracketData and bracketData.farmingRoute
            end
            if route and ns.GuideHUD then
                ns.GuideHUD:StartRoute(route, selectedFarmingKey or "farming_route")
            else
                self:UpdateFarmingView()
            end
        end
    elseif currentKey == "prep" then
        if ns.RaidPrep then
            if ns.RaidPrep.currentSubMode == "camping" then
                if ns.RaidPrep.BroadcastCamp then ns.RaidPrep:BroadcastCamp() end
            else
                if ns.RaidPrep.BroadcastStatus then ns.RaidPrep:BroadcastStatus() end
            end
        end
    elseif currentKey == "travel" then
        if currentTravelPlan and currentTravelPlan.success then
            ns.TravelPlanner:StartPlannedRoute(currentTravelPlan)
        elseif selectedTravelFrom and selectedTravelTo then
            ns.TravelPlanner:PlanAndStart(selectedTravelFrom, selectedTravelTo, { routingMode = selectedTravelMode })
            self:UpdateTravelView()
        else
            ns.Print(ns.Red("Elige un origen y un destino primero."))
        end
    elseif currentKey == "guild" then
        ns.Print("Discord oficial: " .. ns.Gold(ns.DISCORD_URL))
    end
end

function MainUI:OnActionButton2()
    local currentKey = TABS_CONFIG[currentTab] and TABS_CONFIG[currentTab].key
    if currentKey == "bis" then
        if selectedBiSMode == "enchants" then
            self:CycleBiSSpec()
        else
            self:CycleBiSBracket()
        end
    elseif currentKey == "secrets" then
        local secret = (ns.GetSecret and ns.GetSecret(selectedSecretKey)) or (ns.Data.Secrets and ns.Data.Secrets[selectedSecretKey])
        if secret and secret.steps then
            local curStepIdx = (ns.GetSecretProgress and ns.GetSecretProgress(selectedSecretKey)) or (secret.currentStep or 1)
            local curStep = (ns.GetSecretMilestoneTargetStep and ns.GetSecretMilestoneTargetStep(selectedSecretKey, curStepIdx)) or secret.steps[curStepIdx] or secret.steps[1]
            if curStep and curStep.uiMapID and curStep.x and curStep.y then
                selectedTravelFrom = "__player__"
                selectedTravelTo = {
                    uiMapID = curStep.uiMapID,
                    x = curStep.x,
                    y = curStep.y,
                    name = curStep.title or secret.title,
                    zoneName = curStep.zoneName,
                }
                if self.SelectTab then
                    self:SelectTab("travel")
                elseif tabIndexByKey["travel"] then
                    self:OpenTab(tabIndexByKey["travel"])
                end
                ns.Print(string.format("Planificando viaje multimodal hacia el hito %d de |cFFFFD100%s|r...", curStepIdx, secret.title))
            else
                self:RefreshCurrentView()
            end
        else
            self:RefreshCurrentView()
        end
    elseif currentKey == "farming" then
        self:CycleFarmingBracket()
        self:UpdateBottomButtons()
    elseif currentKey == "prep" then
        if ns.RaidPrep then
            if ns.RaidPrep.currentSubMode == "camping" then
                if ns.RaidPrep.ScanParty then ns.RaidPrep:ScanParty() end
            else
                if ns.RaidPrep.ScanInventory then ns.RaidPrep:ScanInventory() end
            end
        end
        self:RefreshCurrentView()
    elseif currentKey == "travel" then
        selectedTravelFrom = nil
        selectedTravelTo = nil
        currentTravelPlan = nil
        self:UpdateTravelView()
    elseif currentKey == "guild" then
        self:RefreshCurrentView()
    end
end

function MainUI:UpdatePrepTabButtons()
    local currentKey = TABS_CONFIG[currentTab] and TABS_CONFIG[currentTab].key
    if currentKey == "prep" then
        if ns.RaidPrep and ns.RaidPrep.currentSubMode == "camping" then
            SetColumnHeaders("Mejora de Campamento", 195, 0, "Profesión / Req", 90, 196, "Beneficio / Estado", 177, 287, "RIGHT")
        else
            SetColumnHeaders("Consumible", 310, 0, "Inventario", 154, 311, nil, nil, nil, nil, "RIGHT")
        end
        self:UpdateBottomButtons()
    end
end

function MainUI:UpdateBottomButtons()
    if not bottomButtons[1] then return end
    local currentKey = TABS_CONFIG[currentTab] and TABS_CONFIG[currentTab].key

    if currentKey == "bis" then
        if selectedBiSMode == "enchants" then
            bottomButtons[1]:SetText("Ver Fuente")
            bottomButtons[2]:SetText("Cambiar Rol")
        else
            bottomButtons[1]:SetText("Marcar Jefe")
            bottomButtons[2]:SetText("Cambiar Tier")
        end
        bottomButtons[3]:SetText("Habilidades")
    elseif currentKey == "secrets" then
        bottomButtons[1]:SetText("Iniciar Ruta")
        bottomButtons[2]:SetText("Planificar Viaje")
        bottomButtons[3]:SetText("Habilidades")
    elseif currentKey == "farming" then
        bottomButtons[1]:SetText("Iniciar Ruta")
        bottomButtons[2]:SetText("Cambiar Tramo")
        bottomButtons[3]:SetText("Habilidades")
    elseif currentKey == "prep" then
        if ns.RaidPrep and ns.RaidPrep.currentSubMode == "camping" then
            bottomButtons[1]:SetText("Transmitir Camp")
            bottomButtons[2]:SetText("Escanear Grupo")
        else
            bottomButtons[1]:SetText("Transmitir Prep")
            bottomButtons[2]:SetText("Reescanear")
        end
        bottomButtons[3]:SetText("Habilidades")
    elseif currentKey == "travel" then
        if currentTravelPlan and currentTravelPlan.success then
            bottomButtons[1]:SetText("Iniciar (" .. math.floor(currentTravelPlan.totalMinutes or 0) .. "m)")
        else
            bottomButtons[1]:SetText("Calcular Ruta")
        end
        bottomButtons[2]:SetText("Limpiar")
        bottomButtons[3]:SetText("Alternar HUD")
    elseif currentKey == "guild" then
        bottomButtons[1]:SetText("Copiar Discord")
        bottomButtons[2]:SetText("Sincronizar")
        bottomButtons[3]:SetText("Habilidades")
    end
end

-- =========================================================================
-- SELECCIÓN DE PESTAÑAS (SIDE TABS ESTILO OLYMPUS)
-- =========================================================================
function MainUI:SelectTab(indexOrKey)
    local index = indexOrKey
    if type(indexOrKey) == "string" then
        index = tabIndexByKey[indexOrKey] or 1
    end
    index = tonumber(index) or 1
    if index < 1 or index > #TABS_CONFIG then index = 1 end

    currentTab = index
    local tabInfo = TABS_CONFIG[index] or TABS_CONFIG[1]
    local currentKey = tabInfo.key

    for i, v in ipairs(views) do
        v:SetShown(i == index)
        if sideTabs[i] then
            sideTabs[i]:SetChecked(i == index)
            local chk = sideTabs[i]:GetCheckedTexture()
            if chk then
                chk:SetBlendMode("ADD")
                chk:SetDrawLayer("HIGHLIGHT", 2)
            end
        end
    end

    if currentKey == "bis" then
        if selectedBiSMode == "enchants" then
            SetColumnHeaders("Ranura", 80, 0, "Encantamiento Óptimo", 295, 81, "Fuente", 142, 378, "RIGHT")
        else
            SetColumnHeaders("Ranura", 80, 0, "Objeto BiS", 295, 81, "Estado", 142, 378, "RIGHT")
        end
        self:UpdateBiSView()
    else
        self:UpdateSubtitle()
    end

    if currentKey == "secrets" then
        mainFrame.heroTitle:SetText("|cFFFFD100Guías & Secretos|r")
        SetColumnHeaders("Secreto / Misión", 260, 0, "Zona / Distancia", 170, 261, "Progreso", 92, 432, "RIGHT")
        self:UpdateSecretsView()
    elseif currentKey == "farming" then
        SetColumnHeaders("Material / Paso / Ruta", 210, 0, "Origen / Receta", 160, 211, "Inventario / Requisito", 152, 372, "RIGHT")
        self:ShowDetailRewards(nil)
        self:UpdateFarmingView()
    elseif currentKey == "prep" then
        if ns.RaidPrep and ns.RaidPrep.currentSubMode == "camping" then
            SetColumnHeaders("Mejora de Campamento", 225, 0, "Profesión / Req", 105, 226, "Beneficio / Estado", 192, 332, "RIGHT")
        else
            SetColumnHeaders("Consumible", 355, 0, "Inventario", 167, 356, nil, nil, nil, nil, "RIGHT")
        end
        self:UpdateBottomButtons()
        if ns.RaidPrep and ns.RaidPrep.Update then
            ns.RaidPrep:Update()
        end
    elseif currentKey == "travel" then
        mainFrame.heroTitle:SetText("|cFFFFD100Planeador de Viaje|r")
        if colHeaderButtons[1] then colHeaderButtons[1]:Hide() end
        if colHeaderButtons[2] then colHeaderButtons[2]:Hide() end
        if colHeaderButtons[3] then colHeaderButtons[3]:Hide() end
        self:ShowDetailRewards(nil)
        self:UpdateTravelView()
    elseif currentKey == "guild" then
        mainFrame.heroTitle:SetText("|cFF00FFCCHermandad Awakening|r")
        SetColumnHeaders("Miembro", 255, 0, "Rango", 135, 256, "Nivel", 132, 392, "RIGHT")
        self:ShowDetailRewards(nil)
        if mainFrame.detailTitle then
            mainFrame.detailTitle:SetText("|cFF00FFCCHermandad Awakening|r · Protocolo Comms Activo")
            mainFrame.detailText:SetText(string.format(
                "Servidor: %s · Estado: En Línea\nCanal Addon: AWK_COMP (Sincronización P2P activa)\nUtiliza la pestaña de Preparación para auditar consumibles del grupo.",
                GetRealmName() or "Beta"
            ))
        end
    end

    self:UpdateBottomButtons()
end

function MainUI:OpenTab(indexOrKey)
    if not mainFrame then self:Init() end
    mainFrame:Show()
    self:SelectTab(indexOrKey)
end

function MainUI:RefreshCurrentView()
    local currentKey = TABS_CONFIG[currentTab] and TABS_CONFIG[currentTab].key
    if currentKey == "bis" then
        self:UpdateBiSView()
    elseif currentKey == "secrets" then
        self:UpdateSecretsView()
    elseif currentKey == "farming" then
        self:UpdateFarmingView()
    elseif currentKey == "prep" then
        if ns.RaidPrep and ns.RaidPrep.Update then
            ns.RaidPrep:Update()
        end
    end
end

function MainUI:Toggle()
    if not mainFrame then self:Init() end
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
    end
end

-- Inicialización limpia y actualización reactiva de eventos
local loadFrame = CreateFrame("Frame")
loadFrame:RegisterEvent("PLAYER_LOGIN")
loadFrame:RegisterEvent("BAG_UPDATE_DELAYED")
loadFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
loadFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
loadFrame:RegisterEvent("QUEST_LOG_UPDATE")
loadFrame:RegisterEvent("QUEST_ACCEPTED")
loadFrame:RegisterEvent("QUEST_TURNED_IN")
loadFrame:RegisterEvent("PLAYER_LEVEL_UP")
loadFrame:SetScript("OnEvent", function(self, event, arg1, arg2)
    if event == "PLAYER_LOGIN" then
        MainUI:Init()
    elseif event == "GET_ITEM_INFO_RECEIVED" then
        MainUI:OnPreloadItemReceived(arg1)
    elseif event == "BAG_UPDATE_DELAYED" or event == "PLAYER_EQUIPMENT_CHANGED" then
        local currentKey = TABS_CONFIG[currentTab] and TABS_CONFIG[currentTab].key
        if mainFrame and mainFrame:IsShown() then
            if currentKey == "bis" then
                MainUI:UpdateBiSItemStatuses()
            elseif currentKey == "secrets" then
                MainUI:UpdateSecretsView()
            elseif currentKey == "prep" then
                if ns.RaidPrep and ns.RaidPrep.Update then
                    ns.RaidPrep:Update()
                end
            end
        end
    elseif event == "QUEST_LOG_UPDATE" or event == "QUEST_ACCEPTED" or event == "QUEST_TURNED_IN" then
        local currentKey = TABS_CONFIG[currentTab] and TABS_CONFIG[currentTab].key
        if mainFrame and mainFrame:IsShown() and currentKey == "secrets" then
            MainUI:UpdateSecretsView()
        end
    elseif event == "PLAYER_LEVEL_UP" then
        if mainFrame and mainFrame:IsShown() then
            MainUI:RefreshCurrentView()
        end
    end
end)
