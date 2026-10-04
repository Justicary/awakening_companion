local ADDON, ns = ...

local MinimapButton = {}
ns.MinimapButton = MinimapButton

local CREST_TEXTURE = "Interface\\AddOns\\AwakeningCompanion\\Media\\Icons\\awakening_crest.tga"
local DEFAULT_ANGLE = 205

local btn = nil

-- =========================================================================
-- POSICIONAMIENTO Y CÁLCULO ANGULAR EN EL MINIMAPA (Idéntico a Olympus)
-- =========================================================================
local function UpdatePosition(angle)
    if not btn or not Minimap then return end
    local currentAngle = angle or (ns.db and ns.db.minimapAngle) or DEFAULT_ANGLE
    local rad = math.rad(currentAngle)
    
    -- En el anillo del minimapa, idéntico a Olympus y Blizzard: 5 píxeles más allá del borde
    local radius = (Minimap:GetWidth() / 2) + 5
    local x = math.cos(rad) * radius
    local y = math.sin(rad) * radius
    
    btn:ClearAllPoints()
    btn:SetPoint("CENTER", Minimap, "CENTER", x, y)
end
MinimapButton.UpdatePosition = UpdatePosition

-- =========================================================================
-- CREACIÓN DEL BOTÓN DE MINIMAPA
-- =========================================================================
function MinimapButton:Init()
    if btn or not Minimap then return end

    -- Dimensiones oficiales estándar de botón de minimapa en WoW (Inspirado en Olympus MakeRoundButton)
    btn = CreateFrame("Button", "AwakeningMinimapButton", Minimap)
    btn:SetSize(31, 31)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(8)
    btn:SetClampedToScreen(true)
    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:RegisterForDrag("LeftButton")

    -- Fondo oscuro dentro del anillo (Geometría exacta de Olympus: 20x20 en 7, -5)
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetSize(20, 20)
    bg:SetPoint("TOPLEFT", btn, "TOPLEFT", 7, -5)
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")

    -- Icono del tabardo/emblema (Geometría exacta de Olympus: 18x18 en 8, -6, centrado en el disco)
    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetSize(18, 18)
    icon:SetPoint("TOPLEFT", btn, "TOPLEFT", 8, -6)
    icon:SetTexture(CREST_TEXTURE)
    
    -- Aplicar máscara circular nativa de Blizzard para recortar perfectamente los bordes
    if btn.CreateMaskTexture and icon.AddMaskTexture then
        local mask = btn:CreateMaskTexture()
        mask:SetSize(18, 18)
        mask:SetPoint("TOPLEFT", btn, "TOPLEFT", 8, -6)
        mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        icon:AddMaskTexture(mask)
    elseif icon.SetMask then
        pcall(icon.SetMask, icon, "Interface\\CharacterFrame\\TempPortraitAlphaMask")
    end

    -- Borde de seguimiento circular dorado oficial de WoW (53x53 @ TOPLEFT)
    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetSize(53, 53)
    border:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, 0)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

    -- Resaltado al pasar el ratón (Estilo Olympus)
    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    -- Arrastre fluido circular alrededor del minimapa
    btn:SetScript("OnDragStart", function(self)
        self:LockHighlight()
        self:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local px, py = GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            px, py = px / scale, py / scale
            
            local angle = math.deg(math.atan2(py - my, px - mx))
            if angle < 0 then angle = angle + 360 end
            
            if ns.db then
                ns.db.minimapAngle = angle
            end
            UpdatePosition(angle)
        end)
    end)

    btn:SetScript("OnDragStop", function(self)
        self:UnlockHighlight()
        self:SetScript("OnUpdate", nil)
    end)

    -- Interacciones de Clic
    btn:SetScript("OnClick", function(self, mouseBtn)
        if mouseBtn == "RightButton" then
            if ns.GuideHUD then
                ns.GuideHUD:Toggle()
            end
        else
            if ns.MainUI then
                ns.MainUI:Toggle()
            end
        end
    end)

    -- Tooltip informativo estilo Olympus
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("|cFF00FFCCAwakening: Companion|r", 1, 1, 1)
        GameTooltip:AddLine(string.format("Versión %s", ns.VERSION or "1.0.0"), 0.6, 0.6, 0.6)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cFFFFD100Clic izquierdo:|r Abrir / Cerrar menú principal", 0.9, 0.9, 0.9)
        GameTooltip:AddLine("|cFFFFD100Clic derecho:|r Alternar HUD de navegación", 0.9, 0.9, 0.9)
        GameTooltip:AddLine("|cFF888888Arrastrar:|r Mover icono alrededor del minimapa", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Cargar posición guardada
    local savedAngle = (ns.db and ns.db.minimapAngle) or DEFAULT_ANGLE
    UpdatePosition(savedAngle)

    if ns.db and ns.db.hideMinimapButton then
        btn:Hide()
    else
        btn:Show()
    end

    MinimapButton.frame = btn
end

-- =========================================================================
-- MÉTODOS PÚBLICOS
-- =========================================================================
function MinimapButton:Show()
    if btn then btn:Show() end
    if ns.db then ns.db.hideMinimapButton = false end
end

function MinimapButton:Hide()
    if btn then btn:Hide() end
    if ns.db then ns.db.hideMinimapButton = true end
end

function MinimapButton:Toggle()
    if btn and btn:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

-- Inicialización al iniciar sesión
local loadFrame = CreateFrame("Frame")
loadFrame:RegisterEvent("PLAYER_LOGIN")
loadFrame:SetScript("OnEvent", function()
    MinimapButton:Init()
end)
