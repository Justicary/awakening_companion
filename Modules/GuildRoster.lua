local ADDON, ns = ...

local GuildRoster = {}
ns.GuildRoster = GuildRoster

local containerFrame = nil
local scrollFrame = nil
local contentFrame = nil
local memberRows = {}
local rosterSummary = nil

-- =========================================================================
-- CONSTRUCCIÓN DE LA VISTA ROSTER INTERNO
-- =========================================================================
function GuildRoster:Build(parent)
    if containerFrame then return containerFrame end

    containerFrame = CreateFrame("Frame", nil, parent)
    containerFrame:SetAllPoints(parent)
    containerFrame:Hide()

    -- Resumen superior
    local headerBar = CreateFrame("Frame", nil, containerFrame, "BackdropTemplate")
    headerBar:SetSize(424, 26)
    headerBar:SetPoint("TOPLEFT", containerFrame, "TOPLEFT", 4, -4)
    headerBar:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    headerBar:SetBackdropColor(0.06, 0.06, 0.08, 0.85)

    rosterSummary = headerBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    rosterSummary:SetPoint("LEFT", headerBar, "LEFT", 10, 0)
    rosterSummary:SetText("Miembros: Consultando...")

    local btnRefreshRoster = CreateFrame("Button", nil, headerBar, "UIPanelButtonTemplate")
    btnRefreshRoster:SetSize(100, 20)
    btnRefreshRoster:SetPoint("RIGHT", headerBar, "RIGHT", -4, 0)
    btnRefreshRoster:SetText("Escanear Roster")
    btnRefreshRoster:SetScript("OnClick", function()
        if C_GuildInfo and C_GuildInfo.GuildRoster then
            C_GuildInfo.GuildRoster()
        elseif _G.GuildRoster then
            _G.GuildRoster()
        end
        GuildRoster:Update()
    end)

    -- ScrollFrame para listar miembros
    scrollFrame = CreateFrame("ScrollFrame", "AwakeningRosterScroll", containerFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", containerFrame, "TOPLEFT", 4, -34)
    scrollFrame:SetPoint("BOTTOMRIGHT", containerFrame, "BOTTOMRIGHT", -26, 4)

    contentFrame = CreateFrame("Frame", nil, scrollFrame)
    contentFrame:SetSize(394, 10)
    scrollFrame:SetScrollChild(contentFrame)

    -- Evento para actualizar cuando el servidor envíe datos de hermandad
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("GUILD_ROSTER_UPDATE")
    eventFrame:SetScript("OnEvent", function()
        if containerFrame:IsShown() then
            GuildRoster:Update()
        end
    end)

    return containerFrame
end

-- =========================================================================
-- POBLAR Y ACTUALIZAR MIEMBROS DEL ROSTER
-- =========================================================================
function GuildRoster:Update()
    if not containerFrame or not containerFrame:IsShown() then return end

    if not IsInGuild() then
        if rosterSummary then
            rosterSummary:SetText("No perteneces a ninguna hermandad.")
        end
        for _, r in ipairs(memberRows) do r:Hide() end
        return
    end

    local totalMembers = GetNumGuildMembers() or 0
    local onlineCount = 0
    local visibleIndex = 0
    local yOffset = 0

    for i = 1, totalMembers do
        local name, rankName, rankIndex, level, classDisplayName, zone, publicNote, officerNote, isOnline, status, classFileName = GetGuildRosterInfo(i)
        
        if isOnline then
            onlineCount = onlineCount + 1
            visibleIndex = visibleIndex + 1

            local row = memberRows[visibleIndex]
            if not row then
                row = CreateFrame("Frame", nil, contentFrame, "BackdropTemplate")
                row:SetSize(394, 26)
                row:SetBackdrop({
                    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                    tile = true, tileSize = 8, edgeSize = 8,
                    insets = { left = 2, right = 2, top = 2, bottom = 2 }
                })
                row:SetBackdropColor(0.08, 0.08, 0.12, 0.75)

                local nameLabel = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                nameLabel:SetPoint("LEFT", row, "LEFT", 8, 0)
                nameLabel:SetWidth(130)
                nameLabel:SetJustifyH("LEFT")

                local levelLabel = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                levelLabel:SetPoint("LEFT", nameLabel, "RIGHT", 4, 0)
                levelLabel:SetWidth(40)
                levelLabel:SetJustifyH("CENTER")

                local zoneLabel = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                zoneLabel:SetPoint("LEFT", levelLabel, "RIGHT", 8, 0)
                zoneLabel:SetWidth(120)
                zoneLabel:SetJustifyH("LEFT")

                local rankLabel = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
                rankLabel:SetPoint("RIGHT", row, "RIGHT", -8, 0)
                rankLabel:SetWidth(80)
                rankLabel:SetJustifyH("RIGHT")

                row.nameLabel = nameLabel
                row.levelLabel = levelLabel
                row.zoneLabel = zoneLabel
                row.rankLabel = rankLabel
                memberRows[visibleIndex] = row
            end

            -- Nombre con color de clase nativo
            local cleanName = (name or ""):gsub("%-.*$", "")
            local classColor = classFileName and RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFileName]
            if classColor then
                row.nameLabel:SetText(string.format("|c%s%s|r", classColor.colorStr or "ffffffff", cleanName))
            else
                row.nameLabel:SetText(cleanName)
            end

            row.levelLabel:SetText(tostring(level or "-"))
            row.zoneLabel:SetText(zone or "Desconocida")
            row.rankLabel:SetText(rankName or "-")

            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, yOffset)
            row:Show()

            yOffset = yOffset - 28
        end
    end

    -- Ocultar filas sobrantes
    for j = visibleIndex + 1, #memberRows do
        memberRows[j]:Hide()
    end

    contentFrame:SetHeight(math.max(10, -yOffset))

    if rosterSummary then
        rosterSummary:SetText(string.format("Miembros en línea: %s / %s registrados", ns.Green(tostring(onlineCount)), ns.Gold(tostring(totalMembers))))
    end
end

function GuildRoster:Show()
    if containerFrame then
        containerFrame:Show()
        self:Update()
    end
end

function GuildRoster:Hide()
    if containerFrame then
        containerFrame:Hide()
    end
end
