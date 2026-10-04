local ADDON, ns = ...

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

local views = {}
local viewsByKey = {}
local sideTabs = {}
local bottomButtons = {}
local colHeaderButtons = {}

local TABS_CONFIG = {
    { key = "bis",     icon = "Interface\\Icons\\inv_helmet_06",        tooltip = "Best in Slot (BiS)" },
    { key = "secrets", icon = "Interface\\Icons\\inv_misc_book_09",     tooltip = "Secretos Recomendados" },
    { key = "farming", icon = "Interface\\Icons\\inv_pick_02",          tooltip = "Profesiones" },
    { key = "prep",    icon = "Interface\\Icons\\inv_potion_92",        tooltip = "Preparación" },
    { key = "guild",   icon = "Interface\\AddOns\\AwakeningCompanion\\Media\\Icons\\awakening_crest.tga", tooltip = "Hermandad Awakening (Roster)" },
}

local tabIndexByKey = {}
for idx, tab in ipairs(TABS_CONFIG) do
    tabIndexByKey[tab.key] = idx
end

-- Constantes de geometría HUD Principal
local FRAME_W, FRAME_H = 480, 495
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

local function SetColumnHeaders(col1Title, col1W, col1X, col2Title, col2W, col2X, col3Title, col3W, col3X, col3Align)
    if not colHeaderButtons[1] then return end

    if col1Title and col1W then
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
        colHeaderButtons[2]:SetWidth(col2W)
        colHeaderButtons[2]:ClearAllPoints()
        colHeaderButtons[2]:SetPoint("TOPLEFT", colHeaderButtons[2]:GetParent(), "TOPLEFT", col2X or (col1W + 1), 0)
        colHeaderButtons[2].label:SetText(col2Title)
        colHeaderButtons[2].label:SetJustifyH("LEFT")
        colHeaderButtons[2].label:ClearAllPoints()
        colHeaderButtons[2].label:SetPoint("LEFT", colHeaderButtons[2], "LEFT", 6, 0)
        colHeaderButtons[2].label:SetPoint("RIGHT", colHeaderButtons[2], "RIGHT", -4, 0)
    end

    if col3Title and col3W then
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

    f.subStatus = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.subStatus:SetPoint("TOPLEFT", f.heroTitle, "BOTTOMLEFT", 0, -2)
    f.subStatus:SetPoint("RIGHT", f, "RIGHT", -36, 0)
    f.subStatus:SetJustifyH("LEFT")
    f.subStatus:SetWordWrap(false)
    f.subStatus:SetText("WoW Classic Forever · Servidor Activo · v" .. (ns.VERSION or "1.0.0"))

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

    colHeaderButtons[1] = CreateColumnHeader(colHeaderFrame, 1, "Misión", 240, 0)
    colHeaderButtons[2] = CreateColumnHeader(colHeaderFrame, 2, "Zona", 110, 241)
    colHeaderButtons[3] = CreateColumnHeader(colHeaderFrame, 3, "Estado", 113, 352)

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

    local btn3 = CreateBlizzButton(f, "Alternar HUD", function()
        if ns.GuideHUD then ns.GuideHUD:Toggle() end
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
        elseif t.key == "guild" then
            self:BuildGuildList(v)
        end
    end
end

-- =========================================================================
-- VISTA 1: BEST IN SLOT (BiS) BASADO EN NIVEL Y CLASE DEL JUGADOR
-- =========================================================================
local bisRowFrames = {}

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
        itemLabel:SetPoint("RIGHT", row, "LEFT", 324, 0)
        itemLabel:SetJustifyH("LEFT")
        itemLabel:SetWordWrap(false)
        itemLabel:SetText("Cargando...")
        row.itemLabel = itemLabel

        -- Columna 3: Estado / Fuente
        local statusLabel = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        statusLabel:SetPoint("LEFT", row, "LEFT", 326, 0)
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
                    GameTooltip:AddLine("|cFF888888En WoW Classic original no existen encantamientos para esta ranura. Los encantamientos para anillos y ranuras menores se introdujeron en expansiones posteriores (TBC/WotLK).|r", 1, 1, 1, true)
                    GameTooltip:Show()
                end
                return
            end

            if not selfRow.itemID or selfRow.itemID == 0 then return end
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
                    local pctUpgrade, _, candScore, eqScore = ns.GetSlotUpgrade(slotInfo.key, selfRow.itemID, selectedBiSSpec)
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
        SetColumnHeaders("Ranura", 80, 0, "Encantamiento Óptimo", 244, 81, "Fuente", 138, 326, "RIGHT")
    else
        SetColumnHeaders("Ranura", 80, 0, "Objetos BiS", 244, 81, "Estado", 138, 326, "RIGHT")
    end

    self:UpdateBiSView()
    self:SelectBiSSlot(selectedBiSSlot or "Head")
    self:UpdateBottomButtons()
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

        if mainFrame and mainFrame.heroTitle then
            mainFrame.heroTitle:SetText(string.format(
                "|cFFFFD100Encantamientos %s (Nv. %d)|r · |cFF00FFCC%s (%s)|r",
                localizedClass,
                playerLevel,
                specDisplayName,
                bracketShortName
            ))
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

                if enchantID and enchantID > 0 then
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
    -- MODO EQUIPO BiS HABITUAL
    -- ---------------------------------------------------------------------
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

    -- Métrica Hero superior (Estilo Olympus)
    local acquired, total, pct = ns.GetBiSProgress(playerClass, selectedBiSBracket, selectedBiSSpec)
    if mainFrame and mainFrame.heroTitle then
        mainFrame.heroTitle:SetText(string.format(
            "|cFFFFD100BiS %s (Nv. %d)|r · |cFFFFFFFF%d/%d (%d%%)|r",
            classData.name or playerClass,
            playerLevel,
            acquired,
            total,
            pct
        ))
    end

    local bracketSets = classData.sets[selectedBiSBracket] or classData.sets["pre-raid"]
    local activeSet = bracketSets and bracketSets[selectedBiSSpec]

    for _, slotInfo in ipairs(ns.Data.BiSSlotsOrder or {}) do
        local rFrame = bisRowFrames[slotInfo.key]
        if rFrame then
            local itemID = activeSet and activeSet[slotInfo.key]
            rFrame.mode = "gear"
            rFrame.enchantID = nil
            rFrame.enchantMeta = nil
            rFrame.itemID = itemID
            rFrame.slotName = slotInfo.name
            rFrame.slotKey = slotInfo.key

            if itemID and itemID > 0 then
                local meta = ns.GetBiSItemMetadata(itemID)
                local isEquipped, inBags = ns.GetPlayerItemStatus(itemID)

                -- Texto y color de estado (Equipado, En Bolsas, o % Mejora sobre equipo actual)
                if isEquipped then
                    rFrame.statusLabel:SetText("|cFF00FF00Equipado|r")
                elseif inBags then
                    rFrame.statusLabel:SetText("|cFF00CCFFEn Bolsas|r")
                else
                    local statTxt = "|cFFFF5555Falta|r"
                    if ns.GetSlotUpgrade then
                        local pctUpgrade = ns.GetSlotUpgrade(slotInfo.key, itemID, selectedBiSSpec)
                        if pctUpgrade and pctUpgrade > 0 then
                            statTxt = string.format("|cFF00FF00+%.0f%%|r", pctUpgrade)
                        end
                    end
                    rFrame.statusLabel:SetText(statTxt)
                end

                -- Consulta y carga segura de información del objeto
                local name, link, quality, texture = SafeGetItemInfo(itemID)
                local fastIcon = SafeGetItemIcon(itemID)

                if link and texture then
                    rFrame.itemLink = link
                    rFrame.icon:SetTexture(texture)
                    rFrame.itemLabel:SetText(link)
                else
                    rFrame.itemLink = nil
                    rFrame.icon:SetTexture(fastIcon)
                    local fallbackName = meta and meta.name or ("Objeto #" .. itemID)
                    rFrame.itemLabel:SetText("|cFF0070DD" .. fallbackName .. "|r")

                    if Item and Item.CreateFromItemID then
                        pcall(function()
                            local itemObj = Item:CreateFromItemID(itemID)
                            if itemObj and itemObj.ContinueOnItemLoad then
                                itemObj:ContinueOnItemLoad(function()
                                    local n, l, q, t = SafeGetItemInfo(itemID)
                                    if l and rFrame.itemID == itemID and selectedBiSMode == "gear" then
                                        rFrame.itemLink = l
                                        if t then rFrame.icon:SetTexture(t) end
                                        rFrame.itemLabel:SetText(l)
                                        if selectedBiSSlot == slotInfo.key then
                                            MainUI:SelectBiSSlot(slotInfo.key)
                                        end
                                    end
                                end)
                            end
                        end)
                    elseif C_Item and C_Item.RequestLoadItemDataByID then
                        pcall(C_Item.RequestLoadItemDataByID, itemID)
                    end
                end
            else
                rFrame.icon:SetTexture("Interface\\PaperDoll\\UI-Backpack-EmptySlot")
                rFrame.itemLabel:SetText("|cFF666666(Ranura vacía)|r")
                rFrame.statusLabel:SetText("")
                rFrame.itemLink = nil
            end
        end
    end

    MainUI:SelectBiSSlot(selectedBiSSlot or "Head")
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
            mainFrame.detailTitle:SetText("|cFFFFD100Ranura sin objeto asignado|r")
            self:ShowDetailRewards(nil)
            mainFrame.detailText:SetText("No hay objeto Best-in-Slot definido para esta ranura en el tier actual.")
        end
        return
    end

    local itemID = rFrame.itemID
    local meta = ns.GetBiSItemMetadata(itemID)
    local eq, inB = ns.GetPlayerItemStatus(itemID)
    local statusStr = eq and "|cFF00FF00Equipado actualmente en tu personaje|r" or (inB and "|cFF00CCFFEn tus bolsas (listo para usar)|r" or "|cFFFF5555Pendiente de conseguir|r")

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
            local pctUpgrade, _, newScore, curScore = ns.GetSlotUpgrade(rFrame.slotKey, itemID, selectedBiSSpec)
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

    local _, playerClass = UnitClass("player")
    local classData = ns.Data.BiS and (ns.Data.BiS[playerClass] or ns.Data.BiS["WARRIOR"])
    if not classData then return end
    local bracketSets = classData.sets[selectedBiSBracket] or classData.sets["pre-raid"]
    local activeSet = bracketSets and bracketSets[selectedBiSSpec]
    local itemID = activeSet and activeSet[selectedBiSSlot or "Head"]
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
local secretsOrder = { "sleeping_bag", "library_books", "ancient_rune", "sunken_chest", "tanaris_pirates", "shadowforge_key" }

function MainUI:BuildSecretsList(parent)
    local scroll = CreateFrame("ScrollFrame", "AwakeningSecretsScroll", parent, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, -2)
    scroll:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -20, 24)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(440, 10)
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
            row:SetSize(440, 20)
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
            title:SetPoint("RIGHT", row, "LEFT", 248, 0)
            title:SetJustifyH("LEFT")
            title:SetWordWrap(false)
            title:SetText(secret.title)
            row.title = title

            -- Columna 2: Zona
            local zone = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            zone:SetPoint("LEFT", row, "LEFT", 250, 0)
            zone:SetPoint("RIGHT", row, "LEFT", 360, 0)
            zone:SetJustifyH("LEFT")
            zone:SetWordWrap(false)
            zone:SetText(secret.steps[1] and secret.steps[1].zoneName or "Varias")
            row.zone = zone

            -- Columna 3: Hitos / Progreso
            local steps = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            steps:SetPoint("LEFT", row, "LEFT", 362, 0)
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
                    if pClass == "ROGUE" or pClass == "HUNTER" or pClass == "DRUID" or pClass == "WARRIOR" then
                        primaryIndex = 2 -- Amuleto de erudito (+4 Agi, +6 Agu)
                    else
                        primaryIndex = 1 -- Colgante de erudito (+6 Agu, +4 Esp)
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
                    local altHeader = (sKey == "library_books") and "|cFFFFD100Opción alternativa de recompensa:|r" or "|cFFFFD100Otras recompensas al completar:|r"
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
                end

                local stStr
                if isDone then
                    stStr = "|cFF00FF00Completado con éxito|r"
                elseif sKey == "library_books" and s.collectedCount then
                    if s.collectedCount >= 10 then
                        stStr = "|cFF00FFCCListo para entregar (10/10)|r"
                    else
                        stStr = string.format("|cFFFFD100%d de 10 Tomos despojados|r", s.collectedCount)
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
                    local sData = (ns.GetSecret and ns.GetSecret(key)) or secret
                    local curStep = (ns.GetSecretProgress and ns.GetSecretProgress(key)) or 1
                    ns.GuideHUD:StartRoute(sData, key, curStep)
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
            
            -- Lógica de visibilidad progresiva por nivel:
            -- 1. Si el nivel del jugador es inferior al mínimo requerido, el secreto NO aparece todavía.
            -- 2. Si está en el rango de nivel actual, siempre aparece.
            -- 3. Si el jugador superó el rango ("antiguo"):
            --    - Se oculta por defecto para mantener limpia la lista de nivel actual.
            --    - Aparece si la casilla "Mostrar secretos antiguos" está activada.
            local shouldShow = false
            if isTooLow then
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

                local activeStep = secret.steps[curStepIdx] or secret.steps[1]
                row.icon:SetTexture(secret.icon or (activeStep and activeStep.icon) or "Interface\\Icons\\inv_misc_bag_07")
                row.zone:SetText(activeStep and activeStep.zoneName or "Varias")

                if isDone then
                    row.title:SetText(secret.title)
                    row.steps:SetText("|cFF00FF00[Listo]|r")
                elseif key == "library_books" and secret.collectedCount then
                    row.title:SetText(secret.title)
                    if secret.collectedCount >= 10 then
                        row.steps:SetText("|cFF00FFCCEntrega|r")
                    else
                        row.steps:SetText(string.format("|cFFFFD100%d/10|r", secret.collectedCount))
                    end
                elseif isOld then
                    row.title:SetText(string.format("|cFFBBBBBB%s|r", secret.title))
                    row.steps:SetText(string.format("|cFF888888%d/%d|r", curStepIdx, #secret.steps))
                elseif #secret.steps > 1 then
                    row.title:SetText(secret.title)
                    row.steps:SetText(string.format("|cFFFFD100%d/%d|r", curStepIdx, #secret.steps))
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
    local curStep = secret.steps and (secret.steps[curStepIdx] or secret.steps[1])
    local isDone = secret.isCompleted

    -- Actualizar Caja de Detalles inferior (Estilo Olympus)
    if mainFrame and mainFrame.detailTitle and mainFrame.detailText then
        local stBadge
        if isDone then
            stBadge = "|cFF00FF00[Completado]|r"
        elseif key == "library_books" and secret.collectedCount then
            if secret.collectedCount >= 10 then
                stBadge = "|cFF00FFCC[Listo para Entregar]|r"
            else
                stBadge = string.format("|cFFFFD100[%d de 10 Tomos Recolectados]|r", secret.collectedCount)
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

        local lines = {}
        if not secret.rewardItems or #secret.rewardItems == 0 then
            if secret.reward then
                table.insert(lines, "|cFFFFCC00Recompensa:|r " .. secret.reward)
            end
        end
        table.insert(lines, string.format("|cFFFFFFFFUbicación:|r %s   ·   |cFFFFFFFFRango:|r %s", locStr, lvlStr))
        if stepDesc and stepDesc ~= "" then
            table.insert(lines, stepDesc)
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
            title:SetPoint("RIGHT", row, "LEFT", 175, 0)
            title:SetJustifyH("LEFT")
            title:SetWordWrap(false)
            row.title = title

            local prof = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            prof:SetPoint("LEFT", row, "LEFT", 178, 0)
            prof:SetPoint("RIGHT", row, "LEFT", 320, 0)
            prof:SetJustifyH("LEFT")
            prof:SetWordWrap(false)
            row.prof = prof

            local req = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            req:SetPoint("LEFT", row, "LEFT", 324, 0)
            req:SetPoint("RIGHT", row, "RIGHT", -6, 0)
            req:SetJustifyH("RIGHT")
            req:SetWordWrap(false)
            row.req = req

            farmingRowFrames[i] = row
        end

        row.entry = entry
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
        row:SetSize(440, 20)
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
            row.title:SetPoint("RIGHT", row, "LEFT", 175, 0)
            row.prof:ClearAllPoints()
            row.prof:SetPoint("LEFT", row, "LEFT", 178, 0)
            row.prof:SetPoint("RIGHT", row, "LEFT", 320, 0)
            row.req:ClearAllPoints()
            row.req:SetPoint("LEFT", row, "LEFT", 324, 0)
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
-- ACCIONES DE LOS 3 BOTONES INFERIORES
-- =========================================================================
function MainUI:OnActionButton1()
    local currentKey = TABS_CONFIG[currentTab] and TABS_CONFIG[currentTab].key
    if currentKey == "bis" then
        self:SetBiSWaypoint()
    elseif currentKey == "secrets" then
        local secret = (ns.GetSecret and ns.GetSecret(selectedSecretKey)) or (ns.Data.Secrets and ns.Data.Secrets[selectedSecretKey])
        if secret and ns.GuideHUD then
            local curStep = (ns.GetSecretProgress and ns.GetSecretProgress(selectedSecretKey)) or 1
            ns.GuideHUD:StartRoute(secret, selectedSecretKey, curStep)
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
        self:RefreshCurrentView()
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
            SetColumnHeaders("Consumible", 220, 0, "Categoría / Efecto", 120, 221, "Inventario", 122, 342, "RIGHT")
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
        bottomButtons[3]:SetText("Alternar HUD")
    elseif currentKey == "secrets" then
        bottomButtons[1]:SetText("Iniciar Ruta")
        bottomButtons[2]:SetText("Actualizar")
        bottomButtons[3]:SetText("Alternar HUD")
    elseif currentKey == "farming" then
        bottomButtons[1]:SetText("Iniciar Ruta")
        bottomButtons[2]:SetText("Cambiar Tramo")
        bottomButtons[3]:SetText("Alternar HUD")
    elseif currentKey == "prep" then
        if ns.RaidPrep and ns.RaidPrep.currentSubMode == "camping" then
            bottomButtons[1]:SetText("Transmitir Camp")
            bottomButtons[2]:SetText("Escanear Grupo")
        else
            bottomButtons[1]:SetText("Transmitir Prep")
            bottomButtons[2]:SetText("Reescanear")
        end
        bottomButtons[3]:SetText("Alternar HUD")
    elseif currentKey == "guild" then
        bottomButtons[1]:SetText("Copiar Discord")
        bottomButtons[2]:SetText("Sincronizar")
        bottomButtons[3]:SetText("Alternar HUD")
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
            SetColumnHeaders("Ranura", 80, 0, "Encantamiento Óptimo", 244, 81, "Fuente", 138, 326, "RIGHT")
        else
            SetColumnHeaders("Ranura", 80, 0, "Objeto BiS", 244, 81, "Estado", 138, 326, "RIGHT")
        end
        self:UpdateBiSView()
    elseif currentKey == "secrets" then
        mainFrame.heroTitle:SetText("|cFFFFD100Secretos Recomendados|r")
        SetColumnHeaders("Secreto / Misión", 248, 0, "Zona", 112, 249, "Progreso", 102, 362, "RIGHT")
        self:UpdateSecretsView()
    elseif currentKey == "farming" then
        SetColumnHeaders("Material / Paso / Ruta", 176, 0, "Origen / Receta", 144, 177, "Inventario / Requisito", 143, 321, "RIGHT")
        self:ShowDetailRewards(nil)
        self:UpdateFarmingView()
    elseif currentKey == "prep" then
        if ns.RaidPrep and ns.RaidPrep.currentSubMode == "camping" then
            SetColumnHeaders("Mejora de Campamento", 195, 0, "Profesión / Req", 90, 196, "Beneficio / Estado", 177, 287, "RIGHT")
        else
            SetColumnHeaders("Consumible", 220, 0, "Categoría / Efecto", 120, 221, "Inventario", 122, 342, "RIGHT")
        end
        self:UpdateBottomButtons()
        if ns.RaidPrep and ns.RaidPrep.Update then
            ns.RaidPrep:Update()
        end
    elseif currentKey == "guild" then
        mainFrame.heroTitle:SetText("|cFF00FFCCHermandad Awakening|r")
        SetColumnHeaders("Miembro", 220, 0, "Rango", 120, 221, "Nivel", 122, 342, "RIGHT")
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
loadFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        MainUI:Init()
    elseif event == "BAG_UPDATE_DELAYED" or event == "PLAYER_EQUIPMENT_CHANGED" or event == "GET_ITEM_INFO_RECEIVED" then
        local currentKey = TABS_CONFIG[currentTab] and TABS_CONFIG[currentTab].key
        if mainFrame and mainFrame:IsShown() then
            if currentKey == "bis" then
                MainUI:UpdateBiSView()
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
