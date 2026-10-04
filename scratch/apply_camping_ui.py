import re

raidprep_path = "/home/justicary/proyectos/antigravity/AwakeningCompanion/Modules/RaidPrep.lua"

with open(raidprep_path, "r", encoding="utf-8") as f:
    content = f.read()

marker_start = """-- =========================================================================
-- CONSTRUCCIÓN DE LA VISTA PREPARACIÓN
-- =========================================================================
function RaidPrep:Build(parent)"""

assert marker_start in content, "marker_start not found"
split_index = content.find(marker_start)
base_content = content[:split_index]

new_ui_code = """-- =========================================================================
-- CONSTRUCCIÓN DE LA VISTA PREPARACIÓN
-- =========================================================================
function RaidPrep:Build(parent)
    if containerFrame then return containerFrame end

    containerFrame = CreateFrame("Frame", "AwakeningPrepContainer", parent)
    containerFrame:SetAllPoints(parent)
    parent.prepContainer = containerFrame

    -- 0. Barra superior de Selección de Sub-Modo (Consumibles vs Campamento Óptimo)
    local subBar = CreateFrame("Frame", nil, containerFrame)
    subBar:SetPoint("TOPLEFT", containerFrame, "TOPLEFT", 2, 0)
    subBar:SetPoint("TOPRIGHT", containerFrame, "TOPRIGHT", -2, 0)
    subBar:SetHeight(22)
    containerFrame.subBar = subBar

    local btnSubConsumables = CreateFrame("Button", nil, subBar, "UIPanelButtonTemplate")
    btnSubConsumables:SetPoint("LEFT", subBar, "LEFT", 0, 0)
    btnSubConsumables:SetWidth(218)
    btnSubConsumables:SetHeight(22)
    btnSubConsumables:SetText("|cFFFFD100🧪 Consumibles Personales|r")
    subBar.btnConsumables = btnSubConsumables
    btnSubConsumables:SetScript("OnClick", function()
        RaidPrep:SetSubMode("consumables")
    end)
    btnSubConsumables:SetScript("OnEnter", function(selfBtn)
        GameTooltip:SetOwner(selfBtn, "ANCHOR_TOP")
        GameTooltip:AddLine("Consumibles Personales y de Banda", 1, 0.82, 0)
        GameTooltip:AddLine("Elixires, pociones, comidas, frascos, reactivos de clase y vendas recomendados para tu rol y nivel.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btnSubConsumables:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local btnSubCamping = CreateFrame("Button", nil, subBar, "UIPanelButtonTemplate")
    btnSubCamping:SetPoint("LEFT", btnSubConsumables, "RIGHT", 4, 0)
    btnSubCamping:SetWidth(218)
    btnSubCamping:SetHeight(22)
    btnSubCamping:SetText("⛺ Campamento Óptimo (Forever)")
    subBar.btnCamping = btnSubCamping
    btnSubCamping:SetScript("OnClick", function()
        RaidPrep:SetSubMode("camping")
    end)
    btnSubCamping:SetScript("OnEnter", function(selfBtn)
        GameTooltip:SetOwner(selfBtn, "ANCHOR_TOP")
        GameTooltip:AddLine("Campamento Óptimo (WoW Forever)", 1, 0.82, 0)
        GameTooltip:AddLine("Configura las clases de tu equipo de 1 a 5 jugadores y sugiere la combinación óptima de mejoras de campamento sin solapar ni cancelar beneficios de clase.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btnSubCamping:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- ---------------------------------------------------------------------
    -- SECCIÓN 1: VISTA DE CONSUMIBLES
    -- ---------------------------------------------------------------------
    -- 1. Barra de Controles de Consumibles (Modo Leveleo/Raid y Especialización)
    local controls = CreateFrame("Frame", nil, containerFrame)
    controls:SetPoint("TOPLEFT", containerFrame, "TOPLEFT", 2, -24)
    controls:SetPoint("TOPRIGHT", containerFrame, "TOPRIGHT", -2, -24)
    controls:SetHeight(22)
    containerFrame.controls = controls

    -- Botón 1: Modo / Tramo de Nivel
    local modeBtn = CreateFrame("Button", nil, controls, "UIPanelButtonTemplate")
    modeBtn:SetPoint("LEFT", controls, "LEFT", 0, 0)
    modeBtn:SetWidth(218)
    modeBtn:SetHeight(20)
    modeBtn:SetText("Modo: Leveleo")
    containerFrame.modeBtn = modeBtn

    local modeArrow = modeBtn:CreateTexture(nil, "OVERLAY")
    modeArrow:SetSize(10, 10)
    modeArrow:SetPoint("RIGHT", modeBtn, "RIGHT", -8, 0)
    modeArrow:SetTexture("Interface\\AddOns\\AwakeningCompanion\\Media\\Icons\\arrow_down.tga")
    modeBtn.arrow = modeArrow

    modeBtn:SetScript("OnClick", function()
        local pLvl = UnitLevel("player") or 1
        if pLvl < 60 then
            previewRaidMode = not previewRaidMode
            if previewRaidMode then
                ns.Print("Preparación: Vista previa de consumibles para |cFFFFD100Banda / Raid (Nivel 60)|r activada.")
            else
                ns.Print("Preparación: Restaurado a consumibles de tu nivel actual (|cFF00FFCCLeveleo / Mazmorras|r).")
            end
        else
            ns.Print("Preparación: Nivel máximo alcanzado (60). Lista optimizada para Bandas / Raids.")
        end
        RaidPrep:Update()
    end)

    modeBtn:SetScript("OnEnter", function(selfBtn)
        GameTooltip:SetOwner(selfBtn, "ANCHOR_TOP")
        GameTooltip:AddLine("Modo de Preparación", 1, 0.82, 0)
        local pLvl = UnitLevel("player") or 1
        if pLvl < 60 then
            GameTooltip:AddLine("Clic para alternar entre los consumibles de tu nivel actual y la vista previa de Banda / Raid a nivel 60.", 1, 1, 1, true)
        else
            GameTooltip:AddLine("Tu personaje es nivel 60. Mostrando consumibles y frascos óptimos para Banda (Molten Core, Onyxia, BWL).", 1, 1, 1, true)
        end
        GameTooltip:Show()
    end)
    modeBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Botón 2: Selector de Especialización
    local specBtn = CreateFrame("Button", nil, controls, "UIPanelButtonTemplate")
    specBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    specBtn:SetPoint("LEFT", modeBtn, "RIGHT", 4, 0)
    specBtn:SetWidth(218)
    specBtn:SetHeight(20)
    specBtn:SetText("Rama: ...")
    containerFrame.specBtn = specBtn

    local specArrow = specBtn:CreateTexture(nil, "OVERLAY")
    specArrow:SetSize(10, 10)
    specArrow:SetPoint("RIGHT", specBtn, "RIGHT", -8, 0)
    specArrow:SetTexture("Interface\\AddOns\\AwakeningCompanion\\Media\\Icons\\arrow_down.tga")
    specBtn.arrow = specArrow

    specBtn:SetScript("OnClick", function(_, mouseBtn)
        RaidPrep:CycleSpec(mouseBtn == "RightButton")
    end)

    specBtn:SetScript("OnEnter", function(selfBtn)
        GameTooltip:SetOwner(selfBtn, "ANCHOR_TOP")
        GameTooltip:AddLine("Especialización de Preparación", 1, 0.82, 0)
        GameTooltip:AddLine("|cFF00FFCCClic Izquierdo:|r Alternar entre ramas de tu clase actual.", 1, 1, 1, true)
        GameTooltip:AddLine("|cFFFFFFFFClic Derecho:|r Explorar ramas de todas las clases.", 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    specBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Scroll de Filas de Consumibles
    local scroll = CreateFrame("ScrollFrame", "AwakeningPrepScroll", containerFrame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", containerFrame, "TOPLEFT", 2, -48)
    scroll:SetPoint("BOTTOMRIGHT", containerFrame, "BOTTOMRIGHT", -20, 2)
    containerFrame.scroll = scroll

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(420, 10)
    scroll:SetScrollChild(content)
    containerFrame.content = content

    -- Crear 24 marcos de fila reutilizables
    for i = 1, 24 do
        local row = CreateFrame("Button", nil, content, "BackdropTemplate")
        row:SetSize(420, 22)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -((i - 1) * 23))

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

        -- Columna 1: Icono + Nombre del Consumible
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(16, 16)
        icon:SetPoint("LEFT", row, "LEFT", 4, 0)
        icon:SetTexture("Interface\\Icons\\inv_potion_52")
        row.icon = icon

        local nameLabel = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        nameLabel:SetPoint("LEFT", icon, "RIGHT", 6, 0)
        nameLabel:SetPoint("RIGHT", row, "LEFT", 218, 0)
        nameLabel:SetJustifyH("LEFT")
        nameLabel:SetWordWrap(false)
        row.nameLabel = nameLabel

        -- Columna 2: Categoría / Efecto
        local catLabel = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        catLabel:SetPoint("LEFT", row, "LEFT", 222, 0)
        catLabel:SetPoint("RIGHT", row, "LEFT", 338, 0)
        catLabel:SetJustifyH("LEFT")
        catLabel:SetWordWrap(false)
        row.catLabel = catLabel

        -- Columna 3: Estado en Inventario (Semáforo)
        local statusLabel = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        statusLabel:SetPoint("LEFT", row, "LEFT", 342, 0)
        statusLabel:SetPoint("RIGHT", row, "RIGHT", -4, 0)
        statusLabel:SetJustifyH("RIGHT")
        statusLabel:SetWordWrap(false)
        row.statusLabel = statusLabel

        row:SetScript("OnEnter", function(selfRow)
            if not selfRow.itemData then return end
            local itm = selfRow.itemData
            GameTooltip:SetOwner(selfRow, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()

            local _, link = SafeGetItem(itm.id)
            if link then
                GameTooltip:SetHyperlink(link)
            else
                GameTooltip:SetItemByID(itm.id)
            end

            GameTooltip:AddLine(" ")
            GameTooltip:AddDoubleLine("|cFFFFD100Categoría:|r " .. (itm.category or "Consumible"), "|cFFFFD100Mínimo Recomendado:|r |cFFFFFFFFx" .. itm.minCount .. "|r")
            GameTooltip:AddDoubleLine("|cFFFFD100Efecto:|r |cFF00FF00" .. (itm.effect or "Mejora") .. "|r", "|cFFFFD100ID:|r |cFF888888" .. itm.id .. "|r")
            
            if itm.tip then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("|cFFFFD100Por qué se recomienda:|r", 1, 0.82, 0)
                GameTooltip:AddLine(itm.tip, 0.8, 0.9, 1, true)
            end

            if itm.source then
                GameTooltip:AddLine(" ")
                GameTooltip:AddDoubleLine("|cFFFFD100Obtención:|r", itm.source, 1, 0.82, 0, 1, 1, 1, true)
            end

            local count = GetItemCount(itm.id, false, false) or 0
            local stStr = (count >= itm.minCount) and "|cFF00FF00Completado (" .. count .. "/" .. itm.minCount .. " en bolsas)|r"
                or (count > 0 and "|cFFFFCC00Insuficiente (" .. count .. "/" .. itm.minCount .. " en bolsas)|r"
                or "|cFFFF5555Faltan " .. itm.minCount .. " en tus bolsas|r")
            GameTooltip:AddLine(" ")
            GameTooltip:AddDoubleLine("|cFFFFD100Estado actual:|r", stStr)
            GameTooltip:Show()
        end)

        row:SetScript("OnLeave", function() GameTooltip:Hide() end)

        row:SetScript("OnClick", function(selfRow)
            selectedIndex = i
            RaidPrep:SelectConsumable(selfRow.itemData)
            for idx, r in ipairs(rowFrames) do
                if r.selection then r.selection:SetShown(idx == i) end
            end
        end)

        rowFrames[i] = row
    end

    -- ---------------------------------------------------------------------
    -- SECCIÓN 2: VISTA DE CAMPAMENTO ÓPTIMO (WOW FOREVER)
    -- ---------------------------------------------------------------------
    local campingControls = CreateFrame("Frame", nil, containerFrame)
    campingControls:SetPoint("TOPLEFT", containerFrame, "TOPLEFT", 2, -24)
    campingControls:SetPoint("TOPRIGHT", containerFrame, "TOPRIGHT", -2, -24)
    campingControls:SetHeight(46)
    campingControls:Hide()
    containerFrame.campingControls = campingControls

    -- Fila 1: Selector de 5 clases de integrantes del equipo
    campingControls.slotButtons = {}
    for slotIdx = 1, 5 do
        local slotBtn = CreateFrame("Button", nil, campingControls, "UIPanelButtonTemplate")
        slotBtn:SetSize(55, 20)
        if slotIdx == 1 then
            slotBtn:SetPoint("TOPLEFT", campingControls, "TOPLEFT", 0, 0)
        else
            slotBtn:SetPoint("LEFT", campingControls.slotButtons[slotIdx - 1], "RIGHT", 3, 0)
        end
        slotBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        slotBtn:SetScript("OnClick", function(_, mouseBtn)
            RaidPrep:CycleSlotClass(slotIdx, mouseBtn == "RightButton")
        end)
        slotBtn:SetScript("OnEnter", function(selfBtn)
            GameTooltip:SetOwner(selfBtn, "ANCHOR_TOP")
            local cKey = RaidPrep.partyClasses[slotIdx] or "NONE"
            local cName = CLASS_NAMES_ES[cKey] or cKey
            GameTooltip:AddLine(string.format("Miembro %d del Grupo: %s", slotIdx, cName), 1, 0.82, 0)
            GameTooltip:AddLine("|cFF00FFCCClic Izquierdo:|r Cambiar a la siguiente clase.", 1, 1, 1, true)
            GameTooltip:AddLine("|cFFFF5555Clic Derecho:|r Dejar ranura vacía (NONE).", 0.8, 0.8, 0.8, true)
            GameTooltip:AddLine("El optimizador descarta mejoras que dupliquen bufos de estas clases.", 0.7, 0.7, 0.7, true)
            GameTooltip:Show()
        end)
        slotBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        campingControls.slotButtons[slotIdx] = slotBtn
    end

    -- Botón Auto-Detectar Grupo
    local btnAutoScan = CreateFrame("Button", nil, campingControls, "UIPanelButtonTemplate")
    btnAutoScan:SetPoint("LEFT", campingControls.slotButtons[5], "RIGHT", 4, 0)
    btnAutoScan:SetPoint("RIGHT", campingControls, "RIGHT", 0, 0)
    btnAutoScan:SetHeight(20)
    btnAutoScan:SetText("👥 Auto-Detectar")
    btnAutoScan:SetScript("OnClick", function()
        RaidPrep:ScanParty()
    end)
    btnAutoScan:SetScript("OnEnter", function(selfBtn)
        GameTooltip:SetOwner(selfBtn, "ANCHOR_TOP")
        GameTooltip:AddLine("Auto-Detectar Grupo Actual", 1, 0.82, 0)
        GameTooltip:AddLine("Lee automáticamente a los miembros de tu grupo o banda actual y asigna sus clases a las 5 ranuras.", 1, 1, 1, true)
        GameTooltip:Show()
    end)
    btnAutoScan:SetScript("OnLeave", function() GameTooltip:Hide() end)
    campingControls.btnAutoScan = btnAutoScan

    -- Fila 2: Selector de Kit de Fogón (Cocina) + Resumen de optimización
    local btnCampfire = CreateFrame("Button", nil, campingControls, "UIPanelButtonTemplate")
    btnCampfire:SetPoint("TOPLEFT", campingControls, "TOPLEFT", 0, -24)
    btnCampfire:SetWidth(218)
    btnCampfire:SetHeight(20)
    btnCampfire:SetText("🏕️ Fogón: Oficial (5 ranuras) ▼")
    btnCampfire:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btnCampfire:SetScript("OnClick", function(_, mouseBtn)
        RaidPrep:CycleCampfire(mouseBtn == "RightButton")
    end)
    btnCampfire:SetScript("OnEnter", function(selfBtn)
        GameTooltip:SetOwner(selfBtn, "ANCHOR_TOP")
        GameTooltip:AddLine("Kit de Fogón de Campamento (Cocina)", 1, 0.82, 0)
        GameTooltip:AddLine("El fogón determina cuántas mejoras de campamento pueden colocarse a la vez:", 1, 1, 1, true)
        GameTooltip:AddLine("· |cFFFFFFFFBásico:|r 3 mejoras (Cocina 1)", 0.9, 0.9, 0.9)
        GameTooltip:AddLine("· |cFF1EFF00Oficial:|r 5 mejoras (Cocina 140) - ¡Ideal Mazmorras!", 0.2, 1, 0.2)
        GameTooltip:AddLine("· |cFF0070DDExperto:|r 10 mejoras (Cocina 220) - Para Bandas", 0.4, 0.7, 1)
        GameTooltip:AddLine("Clic para cambiar el tipo de fogón.", 1, 0.82, 0)
        GameTooltip:Show()
    end)
    btnCampfire:SetScript("OnLeave", function() GameTooltip:Hide() end)
    campingControls.btnCampfire = btnCampfire

    local summaryText = campingControls:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    summaryText:SetPoint("LEFT", btnCampfire, "RIGHT", 6, 0)
    summaryText:SetPoint("RIGHT", campingControls, "RIGHT", 0, 0)
    summaryText:SetJustifyH("LEFT")
    summaryText:SetText("|cFF00FF005 miembros|r · |cFFFFD1005 ranuras|r")
    campingControls.summaryText = summaryText

    -- Scroll de Filas de Campamento
    local campingScroll = CreateFrame("ScrollFrame", "AwakeningCampingScroll", containerFrame, "UIPanelScrollFrameTemplate")
    campingScroll:SetPoint("TOPLEFT", containerFrame, "TOPLEFT", 2, -74)
    campingScroll:SetPoint("BOTTOMRIGHT", containerFrame, "BOTTOMRIGHT", -20, 2)
    campingScroll:Hide()
    containerFrame.campingScroll = campingScroll

    local campingContent = CreateFrame("Frame", nil, campingScroll)
    campingContent:SetSize(420, 10)
    campingScroll:SetScrollChild(campingContent)
    containerFrame.campingContent = campingContent

    -- 20 Filas de Campamento Reutilizables
    for i = 1, 20 do
        local row = CreateFrame("Button", nil, campingContent, "BackdropTemplate")
        row:SetSize(420, 22)
        row:SetPoint("TOPLEFT", campingContent, "TOPLEFT", 0, -((i - 1) * 23))

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

        -- Badge de Ranura / Estado ([FOGÓN #1], [EXTRA], [DESC])
        local badge = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        badge:SetPoint("LEFT", row, "LEFT", 2, 0)
        badge:SetWidth(56)
        badge:SetJustifyH("LEFT")
        row.badge = badge

        -- Icono
        local icon = row:CreateTexture(nil, "ARTWORK")
        icon:SetSize(16, 16)
        icon:SetPoint("LEFT", badge, "RIGHT", 2, 0)
        icon:SetTexture("Interface\\Icons\\inv_misc_questionmark")
        row.icon = icon

        -- Nombre del Camp Item
        local nameLabel = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        nameLabel:SetPoint("LEFT", icon, "RIGHT", 4, 0)
        nameLabel:SetPoint("RIGHT", row, "LEFT", 195, 0)
        nameLabel:SetJustifyH("LEFT")
        nameLabel:SetWordWrap(false)
        row.nameLabel = nameLabel

        -- Profesión / Req
        local profLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        profLabel:SetPoint("LEFT", row, "LEFT", 198, 0)
        profLabel:SetPoint("RIGHT", row, "LEFT", 285, 0)
        profLabel:SetJustifyH("LEFT")
        profLabel:SetWordWrap(false)
        row.profLabel = profLabel

        -- Beneficio / Razón / Advertencia de Solapamiento
        local reasonLabel = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        reasonLabel:SetPoint("LEFT", row, "LEFT", 288, 0)
        reasonLabel:SetPoint("RIGHT", row, "RIGHT", -4, 0)
        reasonLabel:SetJustifyH("RIGHT")
        reasonLabel:SetWordWrap(false)
        row.reasonLabel = reasonLabel

        row:SetScript("OnEnter", function(selfRow)
            local itm = selfRow.itemData
            if not itm then return end
            GameTooltip:SetOwner(selfRow, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            local titleColor = itm.isConflicted and "|cFFFF5555" or (itm.isRecommended and "|cFF00FF00" or "|cFFFFD100")
            GameTooltip:AddLine(titleColor .. itm.name .. "|r (" .. itm.profession .. " " .. itm.skillReq .. ")", 1, 0.82, 0)
            GameTooltip:AddLine(itm.effectDesc or itm.effect, 1, 1, 1, true)
            GameTooltip:AddLine(" ")
            if itm.isConflicted then
                GameTooltip:AddLine("|cFFFF5555⚠️ Solapamiento de Buff:|r " .. (itm.conflictReason or "Duplica un beneficio de clase"), 1, 0.3, 0.3, true)
            elseif itm.isRecommended then
                GameTooltip:AddLine(string.format("|cFF00FF00✅ Recomendado para el fogón (Ranura #%d):|r Máxima sinergia para tu grupo.", itm.slotOrder or 1), 0.2, 1, 0.2, true)
            else
                GameTooltip:AddLine("|cFFFFD100Alternativa disponible:|r Sin solapamiento, pero otras mejoras tienen mayor prioridad.", 1, 0.82, 0, true)
            end
            if itm.classCopy then
                GameTooltip:AddLine("|cFF888888Copia menor de:|r " .. itm.classCopy, 0.6, 0.6, 0.6)
            end
            local cnt = GetItemCount(itm.id, false, false) or 0
            GameTooltip:AddLine(cnt > 0 and "|cFF00FF00En tus bolsas: " .. cnt .. "|r" or "|cFFFF5555No lo tienes en tus bolsas|r")
            GameTooltip:Show()
        end)
        row:SetScript("OnLeave", function() GameTooltip:Hide() end)

        row:SetScript("OnClick", function(selfRow)
            RaidPrep.selectedCampIndex = i
            RaidPrep:SelectCampItem(selfRow.itemData)
            for idx, r in ipairs(campingRowFrames) do
                if r.selection then r.selection:SetShown(idx == i) end
            end
        end)

        campingRowFrames[i] = row
    end

    RaidPrep:Update()
    return containerFrame
end

-- =========================================================================
-- ALTERNANCIA DE SUB-MODO (CONSUMIBLES VS CAMPAMENTO ÓPTIMO)
-- =========================================================================
function RaidPrep:SetSubMode(mode)
    self.currentSubMode = mode or "consumables"

    if containerFrame then
        if self.currentSubMode == "camping" then
            containerFrame.controls:Hide()
            containerFrame.scroll:Hide()
            containerFrame.campingControls:Show()
            containerFrame.campingScroll:Show()
            if containerFrame.subBar then
                containerFrame.subBar.btnConsumables:SetText("🧪 Consumibles Personales")
                containerFrame.subBar.btnCamping:SetText("|cFFFFD100⛺ Campamento Óptimo|r")
            end
            self:UpdateCamping()
        else
            containerFrame.controls:Show()
            containerFrame.scroll:Show()
            containerFrame.campingControls:Hide()
            containerFrame.campingScroll:Hide()
            if containerFrame.subBar then
                containerFrame.subBar.btnConsumables:SetText("|cFFFFD100🧪 Consumibles Personales|r")
                containerFrame.subBar.btnCamping:SetText("⛺ Campamento Óptimo (Forever)")
            end
            self:UpdateConsumables()
        end
    end

    if ns.MainUI and ns.MainUI.UpdatePrepTabButtons then
        ns.MainUI:UpdatePrepTabButtons()
    end
end

-- =========================================================================
-- ALTERNANCIA DE CLASES EN LAS 5 RANURAS DE EQUIPO
-- =========================================================================
function RaidPrep:CycleSlotClass(slotIdx, isRightClick)
    if isRightClick then
        self.partyClasses[slotIdx] = "NONE"
    else
        local cur = self.partyClasses[slotIdx] or "NONE"
        local curIdx = 1
        for idx, c in ipairs(CLASS_CYCLE) do
            if c == cur then
                curIdx = idx
                break
            end
        end
        local nextIdx = (curIdx % #CLASS_CYCLE) + 1
        self.partyClasses[slotIdx] = CLASS_CYCLE[nextIdx]
    end
    self.selectedCampIndex = 1
    self:UpdateCamping()
end

-- =========================================================================
-- ALTERNANCIA DE KITS DE FOGÓN (BÁSICO, OFICIAL, EXPERTO)
-- =========================================================================
function RaidPrep:CycleCampfire(isRightClick)
    local fires = { "basic", "journeyman", "expert" }
    local curIdx = 2
    for idx, k in ipairs(fires) do
        if k == self.selectedCampfireKey then
            curIdx = idx
            break
        end
    end
    if isRightClick then
        curIdx = curIdx - 1
        if curIdx < 1 then curIdx = #fires end
    else
        curIdx = (curIdx % #fires) + 1
    end
    self.selectedCampfireKey = fires[curIdx]
    self.selectedCampIndex = 1
    self:UpdateCamping()
end

-- =========================================================================
-- AUTO-DETECCIÓN DE MIEMBROS DE GRUPO / BANDA
-- =========================================================================
function RaidPrep:ScanParty()
    local _, myClass = UnitClass("player")
    self.partyClasses[1] = myClass or "WARRIOR"

    local numMembers = GetNumGroupMembers() or 0
    local detected = 1

    if IsInRaid() and numMembers > 0 then
        local idx = 2
        for i = 1, numMembers do
            local name, _, _, _, _, fileName = GetRaidRosterInfo(i)
            if fileName and not UnitIsUnit("raid" .. i, "player") and idx <= 5 then
                self.partyClasses[idx] = fileName
                idx = idx + 1
                detected = detected + 1
            end
        end
        while idx <= 5 do
            self.partyClasses[idx] = "NONE"
            idx = idx + 1
        end
        ns.Print(string.format("Campamento: |cFF00FF00%d miembros de banda|r escaneados y asignados.", detected))
    elseif numMembers > 0 then
        local idx = 2
        for i = 1, 4 do
            local unit = "party" .. i
            if UnitExists(unit) then
                local _, uClass = UnitClass(unit)
                if uClass then
                    self.partyClasses[idx] = uClass
                    idx = idx + 1
                    detected = detected + 1
                end
            end
        end
        while idx <= 5 do
            self.partyClasses[idx] = "NONE"
            idx = idx + 1
        end
        ns.Print(string.format("Campamento: |cFF00FF00%d miembros de grupo|r escaneados y asignados.", detected))
    else
        for i = 2, 5 do
            self.partyClasses[i] = "NONE"
        end
        ns.Print("Campamento: Jugando en solitario. Ranura 1 asignada a tu clase.")
    end

    self:UpdateCamping()
end

-- =========================================================================
-- TRANSMITIR CAMPAMENTO ÓPTIMO AL CANAL DE GRUPO / BANDA
-- =========================================================================
function RaidPrep:BroadcastCamp()
    local fullList, recommended, discarded, selectedFire, partyCount = self:GetOptimizedCampingList()
    local fireName = selectedFire and selectedFire.name or "Fogón"
    local maxSlots = selectedFire and selectedFire.slots or 5

    local channel = IsInRaid() and "RAID" or (IsInGroup() and "PARTY" or nil)

    if channel then
        SendChatMessage(string.format("=== [Awakening] Campamento Óptimo (%s: %d ranuras) ===", fireName, maxSlots), channel)
        for i, item in ipairs(recommended) do
            SendChatMessage(string.format("%d. %s (%s, req %d): %s", i, item.name, item.profession, item.skillReq or 20, item.effect), channel)
        end
        if #discarded > 0 then
            local discNames = {}
            for _, d in ipairs(discarded) do
                table.insert(discNames, d.name)
            end
            SendChatMessage("Descartados por solapamiento de clase: " .. table.concat(discNames, ", "), channel)
        end
        ns.Print(ns.Green(string.format("Campamento Óptimo transmitido al canal de %s.", channel == "RAID" and "Banda" or "Grupo")))
    else
        ns.Print(ns.Gold(string.format("=== [Awakening] Campamento Óptimo (%s: %d ranuras) ===", fireName, maxSlots)))
        for i, item in ipairs(recommended) do
            ns.Print(string.format("|cFF00FF00%d. %s|r (|cFFFFD100%s|r): %s", i, item.name, item.profession, item.effect))
        end
        if #discarded > 0 then
            local discNames = {}
            for _, d in ipairs(discarded) do
                table.insert(discNames, d.name .. " (" .. (CLASS_NAMES_ES[d.conflictClass] or d.conflictClass) .. ")")
            end
            ns.Print("|cFFFF5555Descartados para evitar solapamientos:|r " .. table.concat(discNames, ", "))
        end
    end
end

-- =========================================================================
-- ACTUALIZACIÓN DINÁMICA DE LA VISTA DE CAMPAMENTO
-- =========================================================================
function RaidPrep:UpdateCamping()
    local fullList, recommended, discarded, selectedFire, partyCount = self:GetOptimizedCampingList()
    local mainFrame = ns.MainUI and ns.MainUI.frame

    -- Actualizar botones de clases de las 5 ranuras
    if containerFrame and containerFrame.campingControls and containerFrame.campingControls.slotButtons then
        for idx = 1, 5 do
            local btn = containerFrame.campingControls.slotButtons[idx]
            local cKey = self.partyClasses[idx] or "NONE"
            local cName = CLASS_NAMES_ES[cKey] or cKey
            local cColor = CLASS_COLORS[cKey] or "FFFFFF"
            local prefix = (idx == 1) and "Tú" or ("P" .. idx)
            btn:SetText(string.format("|cFF%s%s: %s|r", cColor, prefix, cName:sub(1, 4)))
        end

        local fireName = selectedFire and selectedFire.name:gsub("Kit de fogón ", "") or "Oficial"
        local fireSlots = selectedFire and selectedFire.slots or 5
        containerFrame.campingControls.btnCampfire:SetText(string.format("🏕️ Fogón: %s (%d r.) ▼", fireName, fireSlots))

        local conflictCount = #discarded
        containerFrame.campingControls.summaryText:SetText(string.format(
            "|cFF00FF00%d miembros|r · |cFFFFD100%d slots|r · |cFF%s%d solapados evitados|r",
            partyCount,
            fireSlots,
            conflictCount > 0 and "FF5555" or "00FF00",
            conflictCount
        ))
    end

    -- Poblar filas de campamento
    for i, row in ipairs(campingRowFrames) do
        local itemData = fullList[i]
        if itemData then
            row.itemData = itemData
            row:Show()

            local count = GetItemCount(itemData.id, false, false) or 0
            local countTag = count > 0 and "|cFF00FF00✓|r " or ""

            -- Icono
            row.icon:SetTexture(itemData.icon or "Interface\\Icons\\inv_misc_questionmark")

            -- Badge y Colores
            if itemData.isConflicted then
                row.badge:SetText("|cFFFF5555[DESC]|r")
                row.nameLabel:SetText("|cFF888888" .. itemData.name .. "|r")
                row.profLabel:SetText("|cFF888888" .. itemData.profession .. " (" .. itemData.skillReq .. ")|r")
                local confName = CLASS_NAMES_ES[itemData.conflictClass] or itemData.conflictClass or "Clase"
                row.reasonLabel:SetText(string.format("|cFFFF5555⚠️ Solapa con %s|r", confName))
            elseif itemData.isRecommended then
                row.badge:SetText(string.format("|cFF00FF00[FOGÓN #%d]|r", itemData.slotOrder or 1))
                row.nameLabel:SetText(countTag .. "|cFFFFFFFF" .. itemData.name .. "|r")
                row.profLabel:SetText("|cFFFFD100" .. itemData.profession .. " (" .. itemData.skillReq .. ")|r")
                row.reasonLabel:SetText("|cFF00FF00" .. itemData.effect .. "|r")
            else
                row.badge:SetText("|cFFFFCC00[EXTRA]|r")
                row.nameLabel:SetText(countTag .. "|cFFFFFFFF" .. itemData.name .. "|r")
                row.profLabel:SetText("|cFF888888" .. itemData.profession .. " (" .. itemData.skillReq .. ")|r")
                row.reasonLabel:SetText("|cFFFFCC00" .. itemData.effect .. "|r")
            end

            row.selection:SetShown(i == self.selectedCampIndex)
        else
            row.itemData = nil
            row:Hide()
        end
    end

    if containerFrame and containerFrame.campingContent then
        containerFrame.campingContent:SetHeight(math.max(10, #fullList * 23))
    end

    -- Encabezado dinámico Hero estilo Olympus
    if mainFrame and mainFrame.heroTitle then
        local fireName = selectedFire and selectedFire.name or "Fogón"
        mainFrame.heroTitle:SetText(string.format(
            "|cFFFFD100Campamento Óptimo|r · %s (|cFF00FF00%d/%d ranuras|r)",
            fireName,
            #recommended,
            selectedFire and selectedFire.slots or 5
        ))
    end

    -- Actualizar selección en detalle
    if fullList[self.selectedCampIndex] then
        self:SelectCampItem(fullList[self.selectedCampIndex])
    elseif fullList[1] then
        self.selectedCampIndex = 1
        self:SelectCampItem(fullList[1])
    end
end

-- =========================================================================
-- DETALLES DEL ITEM DE CAMPAMENTO EN EL PANEL INFERIOR
-- =========================================================================
function RaidPrep:SelectCampItem(campItem)
    if not campItem then return end
    local mainFrame = ns.MainUI and ns.MainUI.frame
    if not mainFrame then return end

    local count = GetItemCount(campItem.id, false, false) or 0
    local statusStr = (count > 0)
        and string.format("|cFF00FF00En tus bolsas (%d)|r", count)
        or "|cFFFF5555No lo tienes en tus bolsas (craftear o pedir a aliado)|r"

    local name, link, quality, texture = SafeGetItem(campItem.id)
    local nameStr = link or campItem.name or name or ("Objeto #" .. campItem.id)
    local q = quality or 2

    if mainFrame.detailTitle and mainFrame.detailText then
        mainFrame.detailTitle:SetText(string.format("%s · |cFFFFD100%s (Tier %d)|r", nameStr, campItem.profession, campItem.tier or 1))

        local rewardItem = {
            {
                itemID = campItem.id,
                name = nameStr,
                quality = q,
                count = 1,
                desc = string.format("Beneficio: %s · Req: %s (%d)", campItem.effect or "Campamento", campItem.profession, campItem.skillReq or 20),
                extraLines = {
                    { text = "Copia bufo de clase: " .. (campItem.classCopy or "Ninguno"), r = 0.5, g = 0.9, b = 1, wrap = true },
                    { text = campItem.isConflicted and ("⚠️ " .. (campItem.conflictReason or "Solapamiento")) or ("Óptimo: " .. (campItem.effectDesc or campItem.effect)), r = campItem.isConflicted and 1 or 0.2, g = campItem.isConflicted and 0.3 or 1, b = 0.2, wrap = true },
                    { text = "Inventario: " .. statusStr, r = 1, g = 0.82, b = 0, wrap = false }
                }
            }
        }
        if ns.MainUI.ShowDetailRewards then
            ns.MainUI:ShowDetailRewards(rewardItem, "|cFFFFD100Mejora de Campamento:|r")
        end

        local conflictNotice = campItem.isConflicted
            and string.format("|cFFFF5555⚠️ DESCARTADO POR CONFLICTO:|r %s\n", campItem.conflictReason)
            or string.format("|cFF00FF00✅ RECOMENDADO PARA EL FOGÓN:|r No colisiona con ningún bufo de las clases de tu grupo.\n")

        mainFrame.detailText:SetText(string.format(
            "Efecto de Campamento: |cFF00FF00%s|r\n" ..
            "Profesión Requerida: |cFFFFD100%s (Habilidad %d)|r · Fuente: |cFF00FFCC%s|r\n" ..
            "%s" ..
            "Bufo de clase equivalente: |cFFFFFFFF%s|r\n" ..
            "Cómo usarlo: |cFFFFFFFFColócalo junto al fogón y descansa (/sit) o fabrica objetos durante 1 minuto para recibir 1 hora de beneficio.|r\n" ..
            "Estado en bolsas: %s",
            campItem.effect or "Beneficio de campamento",
            campItem.profession or "Profesión",
            campItem.skillReq or 20,
            campItem.source or "Instructor de profesión",
            conflictNotice,
            campItem.classCopy or "Ninguno (Efecto único)",
            statusStr
        ))
    end
end

-- =========================================================================
-- ACTUALIZACIÓN DE CONSUMIBLES PERSONALES
-- =========================================================================
function RaidPrep:UpdateConsumables()
    local list, bracketData, activeSpec = self:GetConsumablesList()
    local mainFrame = ns.MainUI and ns.MainUI.frame

    -- Precarga de datos de objetos
    for _, item in ipairs(list) do
        if SafeGetItem(item.id) == nil and C_Item and C_Item.RequestLoadItemDataByID then
            pcall(C_Item.RequestLoadItemDataByID, item.id)
        end
    end

    local readyCount = 0
    local totalCount = #list

    for i, row in ipairs(rowFrames) do
        local itemData = list[i]
        if itemData then
            row.itemData = itemData
            row:Show()

            local count = GetItemCount(itemData.id, false, false) or 0
            local isReady = (count >= itemData.minCount)
            if isReady then readyCount = readyCount + 1 end

            -- Icono
            local name, link, quality, texture = SafeGetItem(itemData.id)
            row.icon:SetTexture(texture or itemData.icon or "Interface\\Icons\\inv_potion_52")

            -- Calidad y color
            local qc = "|cFFFFFFFF"
            local q = quality or itemData.quality or 1
            if q == 4 then qc = "|cFFA335EE"
            elseif q == 3 then qc = "|cFF0070DD"
            elseif q == 2 then qc = "|cFF1EFF00"
            end

            local displayName = link or (qc .. (name or itemData.name) .. "|r")
            row.nameLabel:SetText(string.format("%s |cFF888888(x%d)|r", displayName, itemData.minCount))

            -- Categoría / Efecto
            local effShort = itemData.effect or itemData.category or "Consumible"
            row.catLabel:SetText("|cFF00FFCC" .. effShort .. "|r")

            -- Estado semafórico
            if isReady then
                row.statusLabel:SetText(string.format("|cFF00FF00Listo (%d/%d)|r", count, itemData.minCount))
            elseif count > 0 then
                row.statusLabel:SetText(string.format("|cFFFFCC00Faltan %d (%d/%d)|r", itemData.minCount - count, count, itemData.minCount))
            else
                row.statusLabel:SetText(string.format("|cFFFF5555Faltan %d (0/%d)|r", itemData.minCount, itemData.minCount))
            end

            row.selection:SetShown(i == selectedIndex)
        else
            row.itemData = nil
            row:Hide()
        end
    end

    if containerFrame and containerFrame.content then
        containerFrame.content:SetHeight(math.max(10, #list * 23))
    end

    -- Actualizar Botones de Control
    if containerFrame then
        local pLvl = UnitLevel("player") or 1
        local modeText = previewRaidMode and "Modo: Banda / Raid (Nv. 60)"
            or (pLvl >= 60 and "Modo: Banda / Raid (Nv. 60)" or ("Modo: Leveleo (" .. bracketData.short .. ")"))
        if containerFrame.modeBtn then
            containerFrame.modeBtn:SetText(modeText)
        end
        if containerFrame.specBtn and activeSpec then
            containerFrame.specBtn:SetText(activeSpec.name:gsub("%s*%(.-%)", ""))
        end
    end

    -- Actualizar Encabezado Dinámico Hero estilo Olympus (Clase y Nivel del Jugador)
    local localizedClass, playerClass = UnitClass("player")
    localizedClass = localizedClass or playerClass or "Aventurero"
    local playerLevel = UnitLevel("player") or 1
    local pct = (totalCount > 0) and math.floor((readyCount / totalCount) * 100) or 0

    if mainFrame and mainFrame.heroTitle then
        mainFrame.heroTitle:SetText(string.format(
            "|cFFFFD100Preparación %s (Nv. %d)|r · |cFFFFFFFF%d/%d (%d%%)|r",
            localizedClass,
            playerLevel,
            readyCount,
            totalCount,
            pct
        ))
    end

    -- Actualizar Selección Activa en la caja de detalles
    if list[selectedIndex] then
        self:SelectConsumable(list[selectedIndex])
    elseif list[1] then
        selectedIndex = 1
        self:SelectConsumable(list[1])
    end
end

-- =========================================================================
-- ROUTER PRINCIPAL DE ACTUALIZACIÓN SEGÚN SUB-MODO
-- =========================================================================
function RaidPrep:Update()
    if self.currentSubMode == "camping" then
        self:UpdateCamping()
    else
        self:UpdateConsumables()
    end
end

-- =========================================================================
-- DETALLES DEL CONSUMIBLE EN EL PANEL INFERIOR
-- =========================================================================
function RaidPrep:SelectConsumable(itemData)
    if not itemData then return end
    local mainFrame = ns.MainUI and ns.MainUI.frame
    if not mainFrame then return end

    local count = GetItemCount(itemData.id, false, false) or 0
    local isReady = (count >= itemData.minCount)
    local statusStr = isReady
        and string.format("|cFF00FF00Completado en tus bolsas (%d/%d)|r", count, itemData.minCount)
        or (count > 0 and string.format("|cFFFFCC00Cantidad insuficiente en bolsas (%d/%d)|r", count, itemData.minCount)
        or string.format("|cFFFF5555Pendiente de conseguir (Faltan %d)|r", itemData.minCount))

    local name, link, quality, texture = SafeGetItem(itemData.id)
    local nameStr = link or itemData.name or name or ("Objeto #" .. itemData.id)
    local q = quality or itemData.quality or 1

    if mainFrame.detailTitle and mainFrame.detailText then
        mainFrame.detailTitle:SetText(string.format("%s · |cFFFFD100%s|r", nameStr, itemData.category or "Consumible"))

        local rewardItem = {
            {
                itemID = itemData.id,
                name = nameStr,
                quality = q,
                count = itemData.minCount,
                desc = string.format("Efecto: %s · Cantidad requerida: %d", itemData.effect or "Mejora", itemData.minCount),
                extraLines = {
                    { text = "Por qué se recomienda: " .. (itemData.tip or "Consumible óptimo para tu rol"), r = 0.5, g = 0.9, b = 1, wrap = true },
                    { text = "Inventario: " .. statusStr, r = 1, g = 0.82, b = 0, wrap = false }
                }
            }
        }
        if ns.MainUI.ShowDetailRewards then
            ns.MainUI:ShowDetailRewards(rewardItem, "|cFFFFD100Consumible Requerido:|r")
        end

        mainFrame.detailText:SetText(string.format(
            "Efecto Óptimo: |cFF00FF00%s|r  ·  Categoría: |cFFFFFFFF%s|r\n" ..
            "Por qué se recomienda: |cFFFFD100%s|r\n" ..
            "Cómo obtenerlo: |cFF00FFCC%s|r\n" ..
            "Estado en bolsas: %s",
            itemData.effect or "Mejora de estadísticas",
            itemData.category or "Consumible",
            itemData.tip or "Recomendado para máxima eficiencia en tu rol.",
            itemData.source or "Alquimia / Cocina / Subasta / Vendedores de suministros",
            statusStr
        ))
    end
end

-- =========================================================================
-- ALTERNANCIA DE RAMAS / ESPECIALIZACIÓN
-- =========================================================================
function RaidPrep:CycleSpec(isRightClick)
    local _, playerClass = UnitClass("player")
    playerClass = playerClass or "WARRIOR"

    local specsList
    if isRightClick then
        specsList = {}
        for _, cSpecs in pairs(SPECS_BY_CLASS) do
            for _, s in ipairs(cSpecs) do
                table.insert(specsList, s)
            end
        end
    else
        specsList = self:GetSpecsForClass(playerClass)
    end

    local currentSpec = self:GetPlayerActiveSpec(playerClass)
    local currentIdx = 1
    for idx, s in ipairs(specsList) do
        if s.key == currentSpec.key then
            currentIdx = idx
            break
        end
    end

    local nextIdx = (currentIdx % #specsList) + 1
    self.selectedSpecKey = specsList[nextIdx].key
    selectedIndex = 1
    self:Update()
end

-- =========================================================================
-- ANUNCIAR ESTADO EN EL CANAL DE HERMANDAD
-- =========================================================================
function RaidPrep:BroadcastStatus()
    local list, bracketData, activeSpec = self:GetConsumablesList()
    local readyCount = 0
    local totalCount = #list

    for _, item in ipairs(list) do
        local count = GetItemCount(item.id, false, false) or 0
        if count >= item.minCount then
            readyCount = readyCount + 1
        end
    end

    local pct = (totalCount > 0) and math.floor((readyCount / totalCount) * 100) or 0

    if ns.Comms and ns.Comms.BroadcastPrepStatus then
        ns.Comms:BroadcastPrepStatus(readyCount, totalCount)
    end

    local specName = activeSpec and activeSpec.name or "Especialización"
    local statusMsg = string.format("Preparación (%s): %d de %d consumibles listos (%d%%).", specName, readyCount, totalCount, pct)
    if readyCount == totalCount then
        ns.Print(ns.Green(statusMsg))
    else
        ns.Print(ns.Gold(statusMsg))
    end
end

function RaidPrep:Show()
    if containerFrame then
        containerFrame:Show()
        self:Update()
    end
end

function RaidPrep:Hide()
    if containerFrame then
        containerFrame:Hide()
    end
end

function RaidPrep:ScanInventory()
    self:Update()
end
"""

with open(raidprep_path, "w", encoding="utf-8") as f:
    f.write(base_content + new_ui_code)

print("RaidPrep.lua UI code updated successfully.")
