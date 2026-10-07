local ADDON, ns = ...

local SkillsUI = {}
ns.SkillsUI = SkillsUI

local skillsFrame = nil
local activeFilter = "available" -- "available", "upcoming", "all"
local currentSearch = ""
local overriddenSpellsMap = nil

-- =========================================================================
-- CONSTANTES Y UTILIDADES VISUALES (ESTILO OLYMPUS HD / BLIZZARD DARK-GOLD)
-- =========================================================================
local FRAME_W, FRAME_H = 480, 520
local ROW_H = 40
local MAX_ROWS = 9

local function FormatMoney(copper)
    if not copper or copper <= 0 then return "|cFF888888Gratis|r" end
    local gold = math.floor(copper / 10000)
    local silver = math.floor((copper % 10000) / 100)
    local cop = copper % 100
    local str = ""
    if gold > 0 then
        str = str .. string.format("%d|TInterface\\MoneyFrame\\UI-GoldIcon:12:12:2:0|t ", gold)
    end
    if silver > 0 or gold > 0 then
        str = str .. string.format("%d|TInterface\\MoneyFrame\\UI-SilverIcon:12:12:2:0|t ", silver)
    end
    if cop > 0 or (gold == 0 and silver == 0) then
        str = str .. string.format("%d|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:2:0|t", cop)
    end
    return str
end

local function GetSafeSpellInfo(spellID)
    if not spellID or spellID == 0 then return "Hechizo Desconocido", "", "Interface\\Icons\\inv_misc_questionmark" end
    if C_Spell and C_Spell.GetSpellInfo then
        local info = C_Spell.GetSpellInfo(spellID)
        if info then
            local subText = (C_Spell.GetSpellSubtext and C_Spell.GetSpellSubtext(spellID)) or ""
            return info.name or ("Hechizo #" .. spellID), subText, info.iconID or "Interface\\Icons\\inv_misc_questionmark"
        end
    end
    if _G.GetSpellInfo then
        local name, rank, icon = _G.GetSpellInfo(spellID)
        if name then
            local subText = (C_Spell and C_Spell.GetSpellSubtext and C_Spell.GetSpellSubtext(spellID)) or rank or ""
            return name, subText, icon or "Interface\\Icons\\inv_misc_questionmark"
        end
    end
    return ("Hechizo #" .. spellID), "", "Interface\\Icons\\inv_misc_questionmark"
end

-- =========================================================================
-- MOTOR DE REGLAS DE APRENDIZAJE Y ESCANEO (METODOLOGÍA WHATSTRAINING FOREVER)
-- =========================================================================
function SkillsUI:BuildOverriddenSpellsMap(playerClass)
    if overriddenSpellsMap then return overriddenSpellsMap end
    overriddenSpellsMap = {}
    local classData = ns.Data and ns.Data.ClassSkills and ns.Data.ClassSkills[playerClass]
    if classData and classData.overriddenSpells then
        for _, rankList in ipairs(classData.overriddenSpells) do
            for _, sId in ipairs(rankList) do
                overriddenSpellsMap[sId] = rankList
            end
        end
    end
    return overriddenSpellsMap
end

function SkillsUI:IsAbilityKnown(spellID)
    if not spellID or spellID == 0 then return false end

    -- 1. Verificación directa de APIs oficiales de WoW Classic / Forever
    if IsPlayerSpell and IsPlayerSpell(spellID) then return true end
    if C_SpellBook and C_SpellBook.IsSpellKnown and C_SpellBook.IsSpellKnown(spellID, Enum.SpellBookSpellBank.Player) then return true end
    if C_SpellBook and C_SpellBook.IsSpellInSpellBook and C_SpellBook.IsSpellInSpellBook(spellID, Enum.SpellBookSpellBank.Player, false) then return true end
    if IsSpellKnown and IsSpellKnown(spellID) then return true end

    -- 2. Detección de rangos superiores superados (Overridden Spells)
    local _, playerClass = UnitClass("player")
    local rankMap = self:BuildOverriddenSpellsMap(playerClass)
    local ranks = rankMap and rankMap[spellID]
    if ranks then
        local myIndex = 0
        local highestKnownIndex = 0
        for idx, otherID in ipairs(ranks) do
            if otherID == spellID then
                myIndex = idx
            end
            local isOtherKnown = (IsPlayerSpell and IsPlayerSpell(otherID))
                or (C_SpellBook and C_SpellBook.IsSpellKnown and C_SpellBook.IsSpellKnown(otherID, Enum.SpellBookSpellBank.Player))
                or (C_SpellBook and C_SpellBook.IsSpellInSpellBook and C_SpellBook.IsSpellInSpellBook(otherID, Enum.SpellBookSpellBank.Player, false))
                or (IsSpellKnown and IsSpellKnown(otherID))
            if isOtherKnown then
                highestKnownIndex = idx
            end
        end
        if myIndex > 0 and myIndex <= highestKnownIndex then
            return true
        end
    end

    return false
end

function SkillsUI:ScanSkills()
    local _, playerClass = UnitClass("player")
    local playerLevel = UnitLevel("player") or 1
    local playerFaction = UnitFactionGroup("player") or "Alliance"
    local playerRace = select(3, UnitRace("player"))

    self:BuildOverriddenSpellsMap(playerClass)

    -- ---------------------------------------------------------------------
    -- 1. HABILIDADES DE CLASE
    -- ---------------------------------------------------------------------
    local classAvailable = {}
    local classUpcoming = {}
    local classMissingReqs = {}
    local classAll = {}
    local classAvailableCost = 0

    local classData = ns.Data and ns.Data.ClassSkills and ns.Data.ClassSkills[playerClass]
    if classData and classData.spellsByLevel then
        local sortedLevels = {}
        for lvl in pairs(classData.spellsByLevel) do
            tinsert(sortedLevels, lvl)
        end
        table.sort(sortedLevels)

        for _, lvl in ipairs(sortedLevels) do
            local spellsAtLvl = classData.spellsByLevel[lvl]
            for _, sp in ipairs(spellsAtLvl) do
                -- Filtros de facción y raza
                local passFaction = (sp.faction == nil) or (sp.faction == playerFaction)
                local passRace = true
                if sp.race then
                    passRace = (sp.race == playerRace)
                elseif sp.races then
                    passRace = (sp.races[1] == playerRace or sp.races[2] == playerRace)
                end

                if passFaction and passRace then
                    local isKnown = self:IsAbilityKnown(sp.id)
                    local name, subText, icon = GetSafeSpellInfo(sp.id)

                    local item = {
                        id = sp.id,
                        level = lvl,
                        cost = sp.cost or 0,
                        requiredIds = sp.requiredIds,
                        requiredTalentId = sp.requiredTalentId,
                        name = name,
                        subText = subText,
                        icon = icon,
                        isKnown = isKnown,
                        isWeapon = false,
                    }

                    -- Comprobar si faltan requisitos de rangos previos
                    local hasReqs = true
                    if sp.requiredIds then
                        for _, reqId in ipairs(sp.requiredIds) do
                            if not self:IsAbilityKnown(reqId) then
                                hasReqs = false
                                break
                            end
                        end
                    end

                    -- Comprobar talento previo si aplica
                    local hasTalent = true
                    if sp.requiredTalentId and not self:IsAbilityKnown(sp.requiredTalentId) then
                        hasTalent = false
                    end

                    if isKnown then
                        item.status = "known"
                    elseif lvl <= playerLevel then
                        if hasReqs and hasTalent then
                            item.status = "available"
                            classAvailableCost = classAvailableCost + (sp.cost or 0)
                            tinsert(classAvailable, item)
                        else
                            item.status = "missingReqs"
                            tinsert(classMissingReqs, item)
                        end
                    else
                        -- Próximas habilidades (hitos siguientes)
                        if lvl <= (playerLevel + 4) or (#classUpcoming < 10) then
                            item.status = "upcoming"
                            tinsert(classUpcoming, item)
                        end
                    end

                    tinsert(classAll, item)
                end
            end
        end
    end

    -- ---------------------------------------------------------------------
    -- 2. HABILIDADES CON ARMAS (WEAPON SKILLS - MAESTROS DE ARMAS)
    -- ---------------------------------------------------------------------
    local weaponAvailable = {}
    local weaponUpcoming = {}
    local weaponKnown = {}
    local weaponAll = {}
    local weaponAvailableCost = 0

    if ns.Data and ns.Data.WeaponSkills then
        local weaponOrder = { 196, 197, 198, 199, 201, 202, 1180, 15590, 227, 200, 264, 266, 5011, 2567 }
        for _, wId in ipairs(weaponOrder) do
            local wData = ns.Data.WeaponSkills[wId]
            if wData and wData.classes and wData.classes[playerClass] then
                local isKnown = self:IsAbilityKnown(wId)
                local name, subText, icon = GetSafeSpellInfo(wId)
                if not name or name == ("Hechizo #" .. wId) then
                    name = wData.name
                end
                if not icon or icon == "Interface\\Icons\\inv_misc_questionmark" then
                    icon = wData.icon
                end

                local factionTrainers = (wData.trainers and wData.trainers[playerFaction]) or {}
                local primaryTrainer = factionTrainers[1]
                local trainerSummary = primaryTrainer and string.format("%s (%s)", primaryTrainer.name, primaryTrainer.zone) or "Maestro de Armas"

                local item = {
                    id = wId,
                    name = name,
                    subText = trainerSummary,
                    icon = icon,
                    level = wData.level or 1,
                    cost = wData.cost or 1000,
                    isKnown = isKnown,
                    isWeapon = true,
                    trainers = factionTrainers,
                    primaryTrainer = primaryTrainer,
                    trainerSummary = trainerSummary,
                }

                if isKnown then
                    item.status = "known"
                    tinsert(weaponKnown, item)
                elseif item.level <= playerLevel then
                    item.status = "available"
                    weaponAvailableCost = weaponAvailableCost + item.cost
                    tinsert(weaponAvailable, item)
                else
                    item.status = "upcoming"
                    tinsert(weaponUpcoming, item)
                end

                tinsert(weaponAll, item)
            end
        end
    end

    local totalAvailableCost = classAvailableCost + weaponAvailableCost

    return {
        classAvailable = classAvailable,
        classUpcoming = classUpcoming,
        classMissingReqs = classMissingReqs,
        classAll = classAll,
        classAvailableCost = classAvailableCost,

        weaponAvailable = weaponAvailable,
        weaponUpcoming = weaponUpcoming,
        weaponKnown = weaponKnown,
        weaponAll = weaponAll,
        weaponAvailableCost = weaponAvailableCost,

        totalAvailableCost = totalAvailableCost,
    }
end

-- =========================================================================
-- LOCALIZADOR DE ENTRENADORES Y NAVEGACIÓN 3D
-- =========================================================================
function SkillsUI:GetClassTrainers()
    local _, playerClass = UnitClass("player")
    local playerFaction = UnitFactionGroup("player") or "Alliance"
    local list = ns.Data and ns.Data.Trainers and ns.Data.Trainers[playerClass] and ns.Data.Trainers[playerClass][playerFaction]
    return list or {}
end

function SkillsUI:GetWeaponTrainers()
    local playerFaction = UnitFactionGroup("player") or "Alliance"
    local list = ns.Data and ns.Data.Trainers and ns.Data.Trainers.WEAPONS and ns.Data.Trainers.WEAPONS[playerFaction]
    return list or {}
end

function SkillsUI:FindBestTrainer()
    local trainers = self:GetClassTrainers()
    if #trainers == 0 then return nil end

    local currentMapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    if currentMapID then
        for _, tr in ipairs(trainers) do
            if tr.uiMapID == currentMapID then
                return tr
            end
        end
    end

    return trainers[1]
end

function SkillsUI:FindBestWeaponTrainer()
    local trainers = self:GetWeaponTrainers()
    if #trainers == 0 then return nil end

    local currentMapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    if currentMapID then
        for _, tr in ipairs(trainers) do
            if tr.uiMapID == currentMapID then
                return tr
            end
        end
    end

    return trainers[1]
end

function SkillsUI:GuideToTrainer(trainer, isWeapon)
    if not trainer then
        trainer = isWeapon and self:FindBestWeaponTrainer() or self:FindBestTrainer()
    end
    if not trainer then
        ns.Print("|cFFFF4444No se encontraron entrenadores registrados para tu facción.|r")
        return
    end

    local titlePrefix = isWeapon and "Maestro de Armas" or "Entrenador de Clase"

    -- 1. Sincronización con el compás 3D y HUD de Awakening
    if ns.GuideHUD and ns.GuideHUD.GuideToTrainer then
        ns.GuideHUD:GuideToTrainer(trainer)
    elseif ns.GuideHUD and ns.GuideHUD.StartRoute then
        local guideData = {
            title = titlePrefix .. ": " .. trainer.name,
            category = titlePrefix,
            zoneName = trainer.zone,
            uiMapID = trainer.uiMapID,
            steps = {
                {
                    title = trainer.name,
                    instruction = string.format("Habla con %s en %s (%.1f, %.1f) para aprender nuevas habilidades.", trainer.name, trainer.zone, trainer.x, trainer.y),
                    zoneName = trainer.zone,
                    uiMapID = trainer.uiMapID,
                    x = trainer.x,
                    y = trainer.y,
                }
            }
        }
        ns.GuideHUD:StartRoute(guideData, "trainer_" .. trainer.name, 1)
    end

    -- 2. Waypoint nativo de Blizzard en el mapa del mundo (1.15.5+ / Forever)
    if C_Map and C_Map.SetUserWaypoint and UiMapPoint and UiMapPoint.CreateFromCoordinates then
        pcall(function()
            local point = UiMapPoint.CreateFromCoordinates(trainer.uiMapID, trainer.x / 100, trainer.y / 100)
            C_Map.SetUserWaypoint(point)
            if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
                C_SuperTrack.SetSuperTrackedUserWaypoint(true)
            end
        end)
    end

    -- 3. Waypoint y compás 3D TomTom (Crazy Arrow)
    if _G.TomTom and _G.TomTom.AddWaypoint then
        local title = string.format("[Awakening] %s (%s)", trainer.name, trainer.subText or titlePrefix)
        local ok, uid = pcall(_G.TomTom.AddWaypoint, _G.TomTom, trainer.uiMapID, trainer.x / 100, trainer.y / 100, {
            title = title,
            desc = trainer.zone or "",
            from = "Awakening",
            persistent = false,
            minimap = true,
            world = true,
            crazy = true,
            cleardistance = 15,
        })
        if ok and uid then
            if _G.TomTom.SetCrazyArrow then
                pcall(_G.TomTom.SetCrazyArrow, _G.TomTom, uid, 15, title)
            end
            if ns.GuideHUD and ns.GuideHUD.PositionTomTomArrow then
                ns.GuideHUD:PositionTomTomArrow()
            elseif _G.TomTomCrazyArrow then
                _G.TomTomCrazyArrow:ClearAllPoints()
                _G.TomTomCrazyArrow:SetPoint("TOP", UIParent, "TOP", 0, -50)
                _G.TomTomCrazyArrow:Show()
            end
        end
    end

    PlaySound(SOUNDKIT and SOUNDKIT.IG_QUEST_LOG_OPEN or 844, "Master")
    if isWeapon then
        ns.Print(string.format("Maestro de Armas marcado: |cFFFFD100%s|r en |cFFFFFFFF%s (%.1f, %.1f)|r. ¡Sigue la flecha 3D!", trainer.name, trainer.zone, trainer.x, trainer.y))
    else
        ns.Print(string.format("Entrenador de Clase marcado: |cFFFFD100%s|r en |cFFFFFFFF%s (%.1f, %.1f)|r. ¡Sigue la flecha 3D!", trainer.name, trainer.zone, trainer.x, trainer.y))
    end
end

-- =========================================================================
-- CONSTRUCCIÓN DE LA INTERFAZ DE USUARIO (OLYMPUS HD THEMED MODAL)
-- =========================================================================
function SkillsUI:InitFrame()
    if skillsFrame then return skillsFrame end

    local ok, f = pcall(CreateFrame, "Frame", "AwakeningSkillsFrame", UIParent, "PortraitFrameTemplate")
    if not ok or not f or not f.CloseButton then
        if ok and f then f:Hide() end
        f = CreateFrame("Frame", "AwakeningSkillsFrame", UIParent, "BasicFrameTemplateWithInset")
    else
        f.hasPortrait = true
    end

    f:SetSize(FRAME_W, FRAME_H)
    f:SetPoint("CENTER", UIParent, "CENTER", 40, 20)
    f:SetFrameStrata("HIGH")
    f:SetToplevel(true)
    f:SetClampedToScreen(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()

    tinsert(UISpecialFrames, "AwakeningSkillsFrame")

    -- Título de la ventana
    if f.SetTitle then
        f:SetTitle("|cFFFFD100Habilidades & Armas|r")
    elseif f.TitleText then
        f.TitleText:SetText("|cFFFFD100Habilidades & Armas|r")
    end

    -- Retrato
    if f.hasPortrait then
        local p = f.portrait or f.Portrait or (f.PortraitContainer and f.PortraitContainer.portrait)
        if p then
            p:SetTexture("Interface\\Icons\\inv_misc_book_09")
            p:SetTexCoord(0, 1, 0, 1)
        end
    end

    -- Encabezado estilizado con resumen dinámico
    local hx = f.hasPortrait and 60 or 16
    local headerTitle = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    headerTitle:SetPoint("TOPLEFT", hx, -28)
    headerTitle:SetPoint("RIGHT", f, "RIGHT", -36, 0)
    headerTitle:SetJustifyH("LEFT")
    headerTitle:SetText("|cFFFFD100Habilidades & Armas|r")
    f.headerTitle = headerTitle

    local headerSub = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    headerSub:SetPoint("TOPLEFT", headerTitle, "BOTTOMLEFT", 0, -2)
    headerSub:SetPoint("RIGHT", f, "RIGHT", -36, 0)
    headerSub:SetJustifyH("LEFT")
    headerSub:SetText("Escaneando habilidades disponibles...")
    f.headerSub = headerSub

    -- Inset de lista
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
    listBox:SetPoint("TOPLEFT", 10, -88)
    listBox:SetPoint("BOTTOMRIGHT", -10, 36)
    f.listBox = listBox

    -- Barra de 4 Pestañas: Disponibles | Próximas | Armas | Todas
    local tabsFrame = CreateFrame("Frame", nil, f)
    tabsFrame:SetPoint("TOPLEFT", 10, -60)
    tabsFrame:SetPoint("TOPRIGHT", -10, -60)
    tabsFrame:SetHeight(26)
    f.tabsFrame = tabsFrame

    local tabConfigs = {
        { key = "available", label = "Disponibles" },
        { key = "upcoming",  label = "Próximas" },
        { key = "weapons",   label = "Armas" },
        { key = "all",       label = "Todas" },
    }
    f.tabButtons = {}

    local tabCount = #tabConfigs
    local tabSpacing = 4
    local totalAvailableW = FRAME_W - 20
    local tabW = math.floor((totalAvailableW - (tabSpacing * (tabCount - 1))) / tabCount)

    for i, cfg in ipairs(tabConfigs) do
        local btn = CreateFrame("Button", nil, tabsFrame, "UIPanelButtonTemplate")
        btn:SetSize(tabW, 22)
        btn:SetPoint("LEFT", tabsFrame, "LEFT", (i - 1) * (tabW + tabSpacing), 0)
        btn:SetText(cfg.label)
        btn.filterKey = cfg.key
        btn:SetScript("OnClick", function()
            activeFilter = cfg.key
            SkillsUI:UpdateUI()
            PlaySound(SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or 856, "Master")
        end)
        f.tabButtons[cfg.key] = btn
    end

    -- ScrollFrame estándar de Blizzard (Idéntico a MainUI BiS/Secrets/Farming)
    local scroll = CreateFrame("ScrollFrame", "AwakeningSkillsScroll", listBox, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", listBox, "TOPLEFT", 4, -4)
    scroll:SetPoint("BOTTOMRIGHT", listBox, "BOTTOMRIGHT", -22, 4)
    f.scroll = scroll

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(FRAME_W - 56, 10)
    scroll:SetScrollChild(content)
    f.scrollContent = content

    local emptyLabel = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    emptyLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -40)
    emptyLabel:SetPoint("RIGHT", content, "RIGHT", -10, 0)
    emptyLabel:SetJustifyH("CENTER")
    emptyLabel:SetWordWrap(true)
    emptyLabel:SetText("|cFF888888No hay habilidades registradas en esta categoría para tu nivel.|r")
    emptyLabel:Hide()
    f.emptyLabel = emptyLabel

    f.rowFrames = {}

    -- Barra inferior de botones
    local btnW = (FRAME_W - 32) / 3

    local btnGuide = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    btnGuide:SetSize(btnW, 22)
    btnGuide:SetPoint("BOTTOMLEFT", 10, 8)
    btnGuide:SetText("Ir a Entrenador")
    btnGuide:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btnGuide:SetScript("OnClick", function(selfBtn, button)
        if button == "RightButton" then
            SkillsUI:ShowTrainerMenu(selfBtn)
        else
            SkillsUI:GuideToTrainer()
        end
    end)
    btnGuide:SetScript("OnEnter", function(selfBtn)
        GameTooltip:SetOwner(selfBtn, "ANCHOR_TOP")
        GameTooltip:AddLine("|cFFFFD100Navegación a Entrenadores|r", 1, 0.82, 0)
        GameTooltip:AddLine("Clic izquierdo: Guía automática al entrenador más cercano con compás 3D.", 1, 1, 1, true)
        GameTooltip:AddLine("Clic derecho: Seleccionar un Entrenador de Clase o Maestro de Armas por ciudad.", 0.2, 1, 0.4, true)
        GameTooltip:Show()
    end)
    btnGuide:SetScript("OnLeave", function() GameTooltip:Hide() end)
    f.btnGuide = btnGuide

    local btnRefresh = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    btnRefresh:SetSize(btnW, 22)
    btnRefresh:SetPoint("LEFT", btnGuide, "RIGHT", 4, 0)
    btnRefresh:SetText("Actualizar")
    btnRefresh:SetScript("OnClick", function()
        SkillsUI:UpdateUI()
        PlaySound(SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or 856, "Master")
    end)

    local btnClose = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    btnClose:SetSize(btnW, 22)
    btnClose:SetPoint("LEFT", btnRefresh, "RIGHT", 4, 0)
    btnClose:SetText("Cerrar")
    btnClose:SetScript("OnClick", function()
        f:Hide()
    end)

    skillsFrame = f
    return f
end

-- =========================================================================
-- MENÚ CONTEXTUAL DE ELECCIÓN DE ENTRENADOR POR CIUDAD
-- =========================================================================
function SkillsUI:ShowTrainerMenu(anchorBtn)
    local classTrainers = self:GetClassTrainers()
    local weaponTrainers = self:GetWeaponTrainers()
    if #classTrainers == 0 and #weaponTrainers == 0 then return end

    local menu = {
        { text = "Seleccionar Entrenador", isTitle = true, notCheckable = true },
    }

    if #classTrainers > 0 then
        tinsert(menu, { text = "--- Entrenadores de Clase ---", isTitle = true, notCheckable = true })
        for _, tr in ipairs(classTrainers) do
            tinsert(menu, {
                text = string.format("%s - %s", tr.name, tr.zone),
                notCheckable = true,
                func = function()
                    SkillsUI:GuideToTrainer(tr, false)
                end
            })
        end
    end

    if #weaponTrainers > 0 then
        tinsert(menu, { text = "--- Maestros de Armas ---", isTitle = true, notCheckable = true })
        for _, tr in ipairs(weaponTrainers) do
            tinsert(menu, {
                text = string.format("%s - %s", tr.name, tr.zone),
                notCheckable = true,
                func = function()
                    SkillsUI:GuideToTrainer(tr, true)
                end
            })
        end
    end

    tinsert(menu, { text = "Cancelar", notCheckable = true })

    local drop = CreateFrame("Frame", "AwakeningTrainerDropDown", UIParent, "UIDropDownMenuTemplate")
    EasyMenu(menu, drop, anchorBtn, 0, 0, "MENU")
end

-- =========================================================================
-- RENDERIZADO Y ACTUALIZACIÓN DINÁMICA
-- =========================================================================
function SkillsUI:RenderRows(list)
    if not skillsFrame or not skillsFrame.scrollContent then return end
    local content = skillsFrame.scrollContent
    list = list or {}
    local total = #list

    if total == 0 then
        if skillsFrame.emptyLabel then skillsFrame.emptyLabel:Show() end
        for _, row in ipairs(skillsFrame.rowFrames) do
            row:Hide()
        end
        content:SetHeight(80)
        return
    else
        if skillsFrame.emptyLabel then skillsFrame.emptyLabel:Hide() end
    end

    local yOffset = 0
    for i = 1, total do
        local item = list[i]
        local row = skillsFrame.rowFrames[i]
        if not row then
            row = CreateFrame("Button", nil, content, "BackdropTemplate")
            row:SetBackdrop({
                bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                tile = true, tileSize = 8, edgeSize = 8,
                insets = { left = 2, right = 2, top = 2, bottom = 2 }
            })

            local hl = row:CreateTexture(nil, "HIGHLIGHT")
            hl:SetAllPoints()
            hl:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight")
            hl:SetBlendMode("ADD")
            hl:SetAlpha(0.25)
            row.hl = hl

            -- Elementos para filas normales (hechizo de clase o arma)
            local icon = row:CreateTexture(nil, "ARTWORK")
            icon:SetSize(30, 30)
            icon:SetPoint("LEFT", 6, 0)
            icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            row.icon = icon

            local nameText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            nameText:SetPoint("TOPLEFT", icon, "TOPRIGHT", 8, -2)
            nameText:SetPoint("RIGHT", row, "RIGHT", -120, 0)
            nameText:SetJustifyH("LEFT")
            nameText:SetWordWrap(false)
            row.nameText = nameText

            local subText = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
            subText:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 8, 2)
            subText:SetJustifyH("LEFT")
            row.subText = subText

            local costText = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            costText:SetPoint("TOPRIGHT", -8, -4)
            costText:SetJustifyH("RIGHT")
            row.costText = costText

            local statusText = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            statusText:SetPoint("BOTTOMRIGHT", -8, 4)
            statusText:SetJustifyH("RIGHT")
            row.statusText = statusText

            -- Elementos para filas de cabecera de sección (isHeader)
            local headerBar = row:CreateTexture(nil, "ARTWORK")
            headerBar:SetPoint("TOPLEFT", 2, -2)
            headerBar:SetPoint("BOTTOMLEFT", 6, 2)
            headerBar:SetWidth(4)
            row.headerBar = headerBar

            local headerIcon = row:CreateTexture(nil, "ARTWORK")
            headerIcon:SetSize(16, 16)
            headerIcon:SetPoint("LEFT", headerBar, "RIGHT", 6, 0)
            headerIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            row.headerIcon = headerIcon

            local headerTitle = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            headerTitle:SetPoint("LEFT", headerIcon, "RIGHT", 6, 0)
            headerTitle:SetJustifyH("LEFT")
            row.headerTitle = headerTitle

            local headerBadge = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
            headerBadge:SetPoint("RIGHT", row, "RIGHT", -8, 0)
            headerBadge:SetJustifyH("RIGHT")
            row.headerBadge = headerBadge

            -- Eventos de ratón
            row:SetScript("OnEnter", function(selfRow)
                local data = selfRow.data
                if not data or data.isHeader then return end
                GameTooltip:SetOwner(selfRow, "ANCHOR_RIGHT")
                GameTooltip:ClearLines()

                if data.isWeapon then
                    GameTooltip:AddLine(string.format("|cFFFFD100%s|r", data.name), 1, 0.82, 0)
                    GameTooltip:AddLine("Habilidad con las armas (Maestro de armas)", 0.7, 0.7, 0.8)
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine(string.format("Nivel Requerido: |cFFFFD100%d|r", data.level), 1, 0.82, 0)
                    GameTooltip:AddLine(string.format("Costo de Entrenamiento: %s", FormatMoney(data.cost)), 1, 1, 1)
                    GameTooltip:AddLine(" ")
                    if data.status == "available" then
                        GameTooltip:AddLine("|cFF00FF00¡Disponible para entrenar ahora!|r", 0.2, 1, 0.4)
                    elseif data.status == "upcoming" then
                        GameTooltip:AddLine(string.format("|cFF82C5FFSe desbloqueará al alcanzar nivel %d.|r", data.level), 0.5, 0.8, 1)
                    elseif data.status == "known" then
                        GameTooltip:AddLine("|cFF888888Ya dominas esta habilidad con armas.|r", 0.6, 0.6, 0.6)
                    end
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("|cFFFFD100Entrenadores disponibles:|r", 1, 0.82, 0)
                    if data.trainers and #data.trainers > 0 then
                        for _, tr in ipairs(data.trainers) do
                            GameTooltip:AddLine(string.format("• %s - |cFFFFFFFF%s|r (%.1f, %.1f)", tr.name, tr.zone, tr.x, tr.y), 0.9, 0.9, 0.9)
                        end
                    else
                        GameTooltip:AddLine("• Consulta con los maestros de armas de las capitales.", 0.7, 0.7, 0.7)
                    end
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("|cFF00FF00Haz clic izquierdo para guiar con el compás 3D al Maestro de Armas.|r", 0.2, 1, 0.4)
                else
                    if GameTooltip.SetSpellByID then
                        GameTooltip:SetSpellByID(data.id)
                    else
                        GameTooltip:AddLine(data.name, 1, 1, 1)
                    end
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine(string.format("Nivel Requerido: |cFFFFD100%d|r", data.level), 1, 0.82, 0)
                    GameTooltip:AddLine(string.format("Costo de Entrenamiento: %s", FormatMoney(data.cost)), 1, 1, 1)
                    if data.status == "available" then
                        GameTooltip:AddLine("|cFF00FF00¡Disponible para entrenar ahora!|r", 0.2, 1, 0.4)
                    elseif data.status == "upcoming" then
                        GameTooltip:AddLine(string.format("|cFF82C5FFSe desbloqueará al subir a nivel %d.|r", data.level), 0.5, 0.8, 1)
                    elseif data.status == "missingReqs" then
                        GameTooltip:AddLine("|cFFFF8000Falta aprender el rango previo en tu entrenador.|r", 1, 0.5, 0)
                    elseif data.status == "known" then
                        GameTooltip:AddLine("|cFF888888Ya aprendiste esta habilidad.|r", 0.6, 0.6, 0.6)
                    end
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("|cFF888888Haz clic izquierdo para guiar al entrenador de clase.|r", 0.5, 0.5, 0.5)
                end
                GameTooltip:Show()
            end)
            row:SetScript("OnLeave", function() GameTooltip:Hide() end)

            row:SetScript("OnClick", function(selfRow, btnClick)
                local data = selfRow.data
                if not data or data.isHeader then return end
                if IsModifiedClick("CHATLINK") then
                    local link = GetSpellLink and GetSpellLink(data.id)
                    if link then ChatEdit_InsertLink(link) end
                    return
                end

                if data.isWeapon then
                    local targetTrainer = data.primaryTrainer
                    local currentMap = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
                    if currentMap and data.trainers then
                        for _, tr in ipairs(data.trainers) do
                            if tr.uiMapID == currentMap then
                                targetTrainer = tr
                                break
                            end
                        end
                    end
                    SkillsUI:GuideToTrainer(targetTrainer, true)
                else
                    SkillsUI:GuideToTrainer()
                end
            end)

            skillsFrame.rowFrames[i] = row
        end

        local rowHeight = item.isHeader and 26 or ROW_H
        row:SetHeight(rowHeight)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -yOffset)
        row:SetPoint("TOPRIGHT", content, "TOPRIGHT", 0, -yOffset)
        yOffset = yOffset + rowHeight + 3

        row.data = item

        if item.isHeader then
            row.isHeader = true
            row:EnableMouse(false)
            if row.hl then row.hl:Hide() end
            row.icon:Hide()
            row.nameText:Hide()
            row.subText:Hide()
            row.costText:Hide()
            row.statusText:Hide()

            row.headerBar:Show()
            row.headerIcon:Show()
            row.headerTitle:Show()
            row.headerBadge:Show()

            local c = item.color or { r = 1, g = 0.82, b = 0 }
            row:SetBackdropColor(0.08, 0.09, 0.13, 0.95)
            row:SetBackdropBorderColor(c.r * 0.6, c.g * 0.6, c.b * 0.6, 0.85)

            row.headerBar:SetColorTexture(c.r, c.g, c.b, 1)
            row.headerIcon:SetTexture(item.icon or "Interface\\Icons\\inv_misc_book_09")
            row.headerTitle:SetText(item.title)
            row.headerTitle:SetTextColor(c.r, c.g, c.b)

            if item.cost and item.cost > 0 then
                row.headerBadge:SetText(string.format("|cFFFFFFFF%d disp.|r · %s", item.count or 0, FormatMoney(item.cost)))
            elseif item.count then
                row.headerBadge:SetText(string.format("|cFFFFFFFF%d habilidades|r", item.count))
            else
                row.headerBadge:SetText("")
            end
        else
            row.isHeader = false
            row:EnableMouse(true)
            if row.hl then row.hl:Show() end
            row.headerBar:Hide()
            row.headerIcon:Hide()
            row.headerTitle:Hide()
            row.headerBadge:Hide()

            row.icon:Show()
            row.nameText:Show()
            row.subText:Show()
            row.costText:Show()
            row.statusText:Show()

            row.icon:SetTexture(item.icon)
            row.nameText:SetText(item.name)
            row.costText:SetText(FormatMoney(item.cost))

            if item.isWeapon then
                row.subText:SetText("|cFF82C5FFMaestro:|r " .. (item.trainerSummary or "Maestro de Armas"))
                if item.status == "available" then
                    row.statusText:SetText("|cFF00FF00Aprender con...|r")
                    row:SetBackdropColor(0.04, 0.08, 0.12, 0.85)
                    row:SetBackdropBorderColor(0.2, 0.75, 0.9, 0.85)
                    row.nameText:SetTextColor(1, 1, 1)
                elseif item.status == "upcoming" then
                    row.statusText:SetText(string.format("|cFF82C5FFNv. %d|r", item.level))
                    row:SetBackdropColor(0.06, 0.06, 0.09, 0.85)
                    row:SetBackdropBorderColor(0.3, 0.5, 0.8, 0.7)
                    row.nameText:SetTextColor(0.85, 0.85, 0.9)
                elseif item.status == "known" then
                    row.statusText:SetText("|cFF888888Aprendida|r")
                    row:SetBackdropColor(0.03, 0.03, 0.04, 0.6)
                    row:SetBackdropBorderColor(0.2, 0.25, 0.3, 0.5)
                    row.nameText:SetTextColor(0.6, 0.6, 0.6)
                end
            else
                local sub = item.subText ~= "" and item.subText or string.format("Nv. %d", item.level)
                row.subText:SetText(sub)
                if item.status == "available" then
                    row.statusText:SetText("|cFF00FF00Aprender con...|r")
                    row:SetBackdropColor(0.06, 0.06, 0.09, 0.85)
                    row:SetBackdropBorderColor(0.2, 0.8, 0.3, 0.9)
                    row.nameText:SetTextColor(1, 1, 1)
                elseif item.status == "upcoming" then
                    row.statusText:SetText(string.format("|cFF82C5FFNv. %d|r", item.level))
                    row:SetBackdropColor(0.06, 0.06, 0.09, 0.85)
                    row:SetBackdropBorderColor(0.2, 0.5, 0.8, 0.7)
                    row.nameText:SetTextColor(0.85, 0.85, 0.9)
                elseif item.status == "missingReqs" then
                    row.statusText:SetText("|cFFFF8000Falta Rango|r")
                    row:SetBackdropColor(0.06, 0.06, 0.09, 0.85)
                    row:SetBackdropBorderColor(0.8, 0.5, 0.2, 0.7)
                    row.nameText:SetTextColor(0.9, 0.7, 0.5)
                elseif item.status == "known" then
                    row.statusText:SetText("|cFF888888Aprendida|r")
                    row:SetBackdropColor(0.03, 0.03, 0.04, 0.6)
                    row:SetBackdropBorderColor(0.25, 0.25, 0.3, 0.5)
                    row.nameText:SetTextColor(0.6, 0.6, 0.6)
                end
            end
        end

        row:Show()
    end

    for j = total + 1, #skillsFrame.rowFrames do
        skillsFrame.rowFrames[j]:Hide()
    end

    content:SetHeight(math.max(10, yOffset + 10))
end

function SkillsUI:UpdateUI()
    local f = self:InitFrame()

    local playerName = UnitName("player") or "Jugador"
    local localizedClass, playerClass = UnitClass("player")
    local playerLevel = UnitLevel("player") or 1

    local scan = self:ScanSkills()

    f.headerTitle:SetText(string.format("|cFFFFD100%s · %s (%d)|r", playerName, localizedClass, playerLevel))

    local totalAvail = #scan.classAvailable + #scan.weaponAvailable
    local totalUpcoming = #scan.classUpcoming + #scan.weaponUpcoming
    local totalWeaponsToLearn = #scan.weaponAvailable + #scan.weaponUpcoming

    if totalAvail > 0 then
        if #scan.weaponAvailable > 0 and #scan.classAvailable > 0 then
            f.headerSub:SetText(string.format("|cFF00FF00%d habilidades listas para entrenar|r (%d de clase, %d de armas) · Costo: %s", totalAvail, #scan.classAvailable, #scan.weaponAvailable, FormatMoney(scan.totalAvailableCost)))
        elseif #scan.weaponAvailable > 0 then
            f.headerSub:SetText(string.format("|cFF00FF00%d habilidades con armas listas|r de Maestros de Armas · Costo: %s", #scan.weaponAvailable, FormatMoney(scan.totalAvailableCost)))
        else
            f.headerSub:SetText(string.format("|cFF00FF00%d habilidades de clase listas|r · Costo: %s", #scan.classAvailable, FormatMoney(scan.totalAvailableCost)))
        end
    else
        if totalWeaponsToLearn > 0 then
            f.headerSub:SetText(string.format("|cFF82C5FFHabilidades de clase al día|r · Faltan %d armas por desbloquear de nivel", totalWeaponsToLearn))
        else
            f.headerSub:SetText("|cFF82C5FFEstás al día|r · Próximas habilidades disponibles al subir de nivel")
        end
    end

    -- Actualizar badges en botones de pestañas
    if f.tabButtons["available"] then
        f.tabButtons["available"]:SetText(string.format("Disponibles (%d)", totalAvail))
    end
    if f.tabButtons["upcoming"] then
        f.tabButtons["upcoming"]:SetText(string.format("Próximas (%d)", totalUpcoming))
    end
    if f.tabButtons["weapons"] then
        f.tabButtons["weapons"]:SetText(string.format("Armas (%d)", totalWeaponsToLearn))
    end
    if f.tabButtons["all"] then
        f.tabButtons["all"]:SetText("Todas")
    end

    -- Resaltar visualmente la pestaña activa
    for key, btn in pairs(f.tabButtons) do
        if key == activeFilter then
            btn:LockHighlight()
            if btn.GetFontString and btn:GetFontString() then
                btn:GetFontString():SetTextColor(1, 0.82, 0)
            end
        else
            btn:UnlockHighlight()
            if btn.GetFontString and btn:GetFontString() then
                btn:GetFontString():SetTextColor(1, 1, 1)
            end
        end
    end

    -- Construir lista según filtro activo con separación visual por cabeceras
    local list = {}

    if activeFilter == "available" then
        if f.emptyLabel then
            f.emptyLabel:SetText("|cFF888888No hay habilidades de clase ni armas disponibles para entrenar en este nivel.|r")
        end

        if #scan.classAvailable > 0 then
            tinsert(list, {
                isHeader = true,
                title = "HABILIDADES DE CLASE DISPONIBLES",
                count = #scan.classAvailable,
                cost = scan.classAvailableCost,
                color = { r = 0.2, g = 1.0, b = 0.35 },
                icon = "Interface\\Icons\\inv_misc_book_09",
            })
            for _, sp in ipairs(scan.classAvailable) do tinsert(list, sp) end
        end

        if #scan.weaponAvailable > 0 then
            tinsert(list, {
                isHeader = true,
                title = "HABILIDADES CON ARMAS DISPONIBLES",
                count = #scan.weaponAvailable,
                cost = scan.weaponAvailableCost,
                color = { r = 0.3, g = 0.85, b = 1.0 },
                icon = "Interface\\Icons\\inv_sword_04",
            })
            for _, wp in ipairs(scan.weaponAvailable) do tinsert(list, wp) end
        end

        if #scan.classMissingReqs > 0 then
            tinsert(list, {
                isHeader = true,
                title = "REQUIEREN RANGO PREVIO O TALENTO",
                count = #scan.classMissingReqs,
                cost = 0,
                color = { r = 1.0, g = 0.65, b = 0.2 },
                icon = "Interface\\Icons\\inv_misc_questionmark",
            })
            for _, sp in ipairs(scan.classMissingReqs) do tinsert(list, sp) end
        end

    elseif activeFilter == "upcoming" then
        if f.emptyLabel then
            f.emptyLabel:SetText("|cFF888888No hay próximas habilidades registradas en este rango de niveles.|r")
        end

        if #scan.classUpcoming > 0 then
            tinsert(list, {
                isHeader = true,
                title = "PRÓXIMAS HABILIDADES DE CLASE",
                count = #scan.classUpcoming,
                color = { r = 0.51, g = 0.77, b = 1.0 },
                icon = "Interface\\Icons\\inv_misc_book_09",
            })
            for _, sp in ipairs(scan.classUpcoming) do tinsert(list, sp) end
        end

        if #scan.weaponUpcoming > 0 then
            tinsert(list, {
                isHeader = true,
                title = "PRÓXIMAS HABILIDADES CON ARMAS",
                count = #scan.weaponUpcoming,
                color = { r = 0.85, g = 0.6, b = 1.0 },
                icon = "Interface\\Icons\\inv_spear_06",
            })
            for _, wp in ipairs(scan.weaponUpcoming) do tinsert(list, wp) end
        end

    elseif activeFilter == "weapons" then
        if f.emptyLabel then
            f.emptyLabel:SetText("|cFF888888No hay habilidades con armas registradas para tu clase.|r")
        end

        if #scan.weaponAvailable > 0 then
            tinsert(list, {
                isHeader = true,
                title = "ARMAS DISPONIBLES PARA APRENDER",
                count = #scan.weaponAvailable,
                cost = scan.weaponAvailableCost,
                color = { r = 0.2, g = 1.0, b = 0.35 },
                icon = "Interface\\Icons\\inv_sword_04",
            })
            for _, wp in ipairs(scan.weaponAvailable) do tinsert(list, wp) end
        end

        if #scan.weaponUpcoming > 0 then
            tinsert(list, {
                isHeader = true,
                title = "ARMAS QUE DESBLOQUEARÁS PRÓXIMAMENTE",
                count = #scan.weaponUpcoming,
                color = { r = 0.51, g = 0.77, b = 1.0 },
                icon = "Interface\\Icons\\inv_spear_06",
            })
            for _, wp in ipairs(scan.weaponUpcoming) do tinsert(list, wp) end
        end

        if #scan.weaponKnown > 0 then
            tinsert(list, {
                isHeader = true,
                title = "HABILIDADES CON ARMAS YA APRENDIDAS",
                count = #scan.weaponKnown,
                color = { r = 0.65, g = 0.65, b = 0.7 },
                icon = "Interface\\Icons\\spell_holy_blessingofagility",
            })
            for _, wp in ipairs(scan.weaponKnown) do tinsert(list, wp) end
        end

    elseif activeFilter == "all" then
        if f.emptyLabel then
            f.emptyLabel:SetText("|cFF888888No hay habilidades registradas.|r")
        end

        if #scan.classAvailable > 0 then
            tinsert(list, { isHeader = true, title = "HABILIDADES DE CLASE DISPONIBLES", count = #scan.classAvailable, cost = scan.classAvailableCost, color = { r = 0.2, g = 1.0, b = 0.35 }, icon = "Interface\\Icons\\inv_misc_book_09" })
            for _, sp in ipairs(scan.classAvailable) do tinsert(list, sp) end
        end
        if #scan.weaponAvailable > 0 then
            tinsert(list, { isHeader = true, title = "HABILIDADES CON ARMAS DISPONIBLES", count = #scan.weaponAvailable, cost = scan.weaponAvailableCost, color = { r = 0.3, g = 0.85, b = 1.0 }, icon = "Interface\\Icons\\inv_sword_04" })
            for _, wp in ipairs(scan.weaponAvailable) do tinsert(list, wp) end
        end
        if #scan.classUpcoming > 0 then
            tinsert(list, { isHeader = true, title = "PRÓXIMAS HABILIDADES DE CLASE", count = #scan.classUpcoming, color = { r = 0.51, g = 0.77, b = 1.0 }, icon = "Interface\\Icons\\inv_misc_book_09" })
            for _, sp in ipairs(scan.classUpcoming) do tinsert(list, sp) end
        end
        if #scan.weaponUpcoming > 0 then
            tinsert(list, { isHeader = true, title = "PRÓXIMAS HABILIDADES CON ARMAS", count = #scan.weaponUpcoming, color = { r = 0.85, g = 0.6, b = 1.0 }, icon = "Interface\\Icons\\inv_spear_06" })
            for _, wp in ipairs(scan.weaponUpcoming) do tinsert(list, wp) end
        end
        if #scan.weaponKnown > 0 then
            tinsert(list, { isHeader = true, title = "HABILIDADES CON ARMAS YA APRENDIDAS", count = #scan.weaponKnown, color = { r = 0.65, g = 0.65, b = 0.7 }, icon = "Interface\\Icons\\spell_holy_blessingofagility" })
            for _, wp in ipairs(scan.weaponKnown) do tinsert(list, wp) end
        end
        if #scan.classMissingReqs > 0 then
            tinsert(list, { isHeader = true, title = "REQUIEREN RANGO PREVIO O TALENTO", count = #scan.classMissingReqs, color = { r = 1.0, g = 0.65, b = 0.2 }, icon = "Interface\\Icons\\inv_misc_questionmark" })
            for _, sp in ipairs(scan.classMissingReqs) do tinsert(list, sp) end
        end
    end

    self.currentFilteredList = list

    if f.scroll and f.scroll.ScrollBar then
        f.scroll.ScrollBar:SetValue(0)
    end

    self:RenderRows(list)
end

function SkillsUI:Toggle()
    local f = self:InitFrame()
    if f:IsShown() then
        f:Hide()
    else
        self:UpdateUI()
        f:Show()
        PlaySound(SOUNDKIT and SOUNDKIT.IG_SPELLBOOK_OPEN or 829, "Master")
    end
end

function SkillsUI:Open()
    local f = self:InitFrame()
    self:UpdateUI()
    f:Show()
    PlaySound(SOUNDKIT and SOUNDKIT.IG_SPELLBOOK_OPEN or 829, "Master")
end

-- =========================================================================
-- EVENTOS REACTIVOS (SUBIDA DE NIVEL Y APRENDIZAJE DE HECHIZOS)
-- =========================================================================
local eventWatcher = CreateFrame("Frame")
eventWatcher:RegisterEvent("PLAYER_LEVEL_UP")
eventWatcher:RegisterEvent("SPELLS_CHANGED")
pcall(eventWatcher.RegisterEvent, eventWatcher, "LEARNED_SPELL_IN_SKILL_LINE")
pcall(eventWatcher.RegisterEvent, eventWatcher, "TRAINER_UPDATE")
eventWatcher:SetScript("OnEvent", function(self, event)
    if skillsFrame and skillsFrame:IsShown() then
        SkillsUI:UpdateUI()
    end
end)
