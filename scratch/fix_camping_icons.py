raidprep_path = "/home/justicary/proyectos/antigravity/AwakeningCompanion/Modules/RaidPrep.lua"

with open(raidprep_path, "r", encoding="utf-8") as f:
    text = f.read()

# 1. Fix subBar buttons text
text = text.replace(
    'btnSubConsumables:SetText("|cFFFFD100🧪 Consumibles Personales|r")',
    'btnSubConsumables:SetText("|cFFFFD100|TInterface\\\\Icons\\\\inv_potion_52:14:14:0:0|t Consumibles Personales|r")'
)

text = text.replace(
    'btnSubCamping:SetText("⛺ Campamento Óptimo (Forever)")',
    'btnSubCamping:SetText("|TInterface\\\\Icons\\\\spell_fire_fire:14:14:0:0|t Campamento Óptimo")'
)

# 2. Fix SetSubMode text
text = text.replace(
    'containerFrame.subBar.btnConsumables:SetText("🧪 Consumibles Personales")',
    'containerFrame.subBar.btnConsumables:SetText("|TInterface\\\\Icons\\\\inv_potion_52:14:14:0:0|t Consumibles Personales")'
)

text = text.replace(
    'containerFrame.subBar.btnCamping:SetText("|cFFFFD100⛺ Campamento Óptimo|r")',
    'containerFrame.subBar.btnCamping:SetText("|cFFFFD100|TInterface\\\\Icons\\\\spell_fire_fire:14:14:0:0|t Campamento Óptimo|r")'
)

text = text.replace(
    'containerFrame.subBar.btnConsumables:SetText("|cFFFFD100🧪 Consumibles Personales|r")',
    'containerFrame.subBar.btnConsumables:SetText("|cFFFFD100|TInterface\\\\Icons\\\\inv_potion_52:14:14:0:0|t Consumibles Personales|r")'
)

text = text.replace(
    'containerFrame.subBar.btnCamping:SetText("⛺ Campamento Óptimo (Forever)")',
    'containerFrame.subBar.btnCamping:SetText("|TInterface\\\\Icons\\\\spell_fire_fire:14:14:0:0|t Campamento Óptimo")'
)

# 3. Replace campingControls layout
old_controls_start = "    -- Fila 1: Selector de 5 clases de integrantes del equipo"
old_controls_end = "    campingControls.summaryText = summaryText"

idx1 = text.find(old_controls_start)
idx2 = text.find(old_controls_end)
assert idx1 != -1 and idx2 != -1, "Controls indices not found"
idx2 += len(old_controls_end)

new_controls = r'''    -- Fila 1: Selector de 5 clases de integrantes del equipo (ancho extendido 84px cada una)
    campingControls.slotButtons = {}
    local slotWidth = 84
    local slotSpacing = 4
    for slotIdx = 1, 5 do
        local slotBtn = CreateFrame("Button", nil, campingControls, "UIPanelButtonTemplate")
        slotBtn:SetSize(slotWidth, 20)
        slotBtn:SetPoint("TOPLEFT", campingControls, "TOPLEFT", (slotIdx - 1) * (slotWidth + slotSpacing), 0)
        slotBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        slotBtn:SetScript("OnClick", function(_, mouseBtn)
            RaidPrep:CycleSlotClass(slotIdx, mouseBtn == "RightButton")
        end)
        slotBtn:SetScript("OnEnter", function(selfBtn)
            GameTooltip:SetOwner(selfBtn, "ANCHOR_TOP")
            local cKey = RaidPrep.partyClasses[slotIdx] or "NONE"
            local cName = CLASS_NAMES_ES[cKey] or cKey
            local prefix = (slotIdx == 1) and "Tu Personaje" or string.format("Compañero %d", slotIdx)
            GameTooltip:AddLine(string.format("%s: %s", prefix, cName), 1, 0.82, 0)
            GameTooltip:AddLine("|cFF00FFCCClic Izquierdo:|r Cambiar a la siguiente clase.", 1, 1, 1, true)
            GameTooltip:AddLine("|cFFFF5555Clic Derecho:|r Dejar ranura en (Vacío).", 0.8, 0.8, 0.8, true)
            GameTooltip:AddLine("El optimizador descarta mejoras que dupliquen bufos de estas clases.", 0.7, 0.7, 0.7, true)
            GameTooltip:Show()
        end)
        slotBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        campingControls.slotButtons[slotIdx] = slotBtn
    end

    -- Fila 2: Selector de Kit de Fogón (Cocina) + Botón Auto-Detectar + Resumen de optimización
    local btnCampfire = CreateFrame("Button", nil, campingControls, "UIPanelButtonTemplate")
    btnCampfire:SetPoint("TOPLEFT", campingControls, "TOPLEFT", 0, -23)
    btnCampfire:SetSize(195, 20)
    btnCampfire:SetText("|TInterface\\Icons\\spell_fire_fire:14:14:0:0|t Fogón: Oficial (5 r.)")
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

    local campfireArrow = btnCampfire:CreateTexture(nil, "OVERLAY")
    campfireArrow:SetSize(10, 10)
    campfireArrow:SetPoint("RIGHT", btnCampfire, "RIGHT", -6, 0)
    campfireArrow:SetTexture("Interface\\AddOns\\AwakeningCompanion\\Media\\Icons\\arrow_down.tga")
    btnCampfire.arrow = campfireArrow

    -- Botón Auto-Detectar Grupo
    local btnAutoScan = CreateFrame("Button", nil, campingControls, "UIPanelButtonTemplate")
    btnAutoScan:SetPoint("LEFT", btnCampfire, "RIGHT", 4, 0)
    btnAutoScan:SetSize(115, 20)
    btnAutoScan:SetText("|TInterface\\Icons\\inv_misc_groupneedmore:14:14:0:0|t Auto-Detectar")
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

    local summaryText = campingControls:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    summaryText:SetPoint("LEFT", btnAutoScan, "RIGHT", 4, 0)
    summaryText:SetPoint("RIGHT", campingControls, "RIGHT", 0, 0)
    summaryText:SetJustifyH("RIGHT")
    summaryText:SetText("|cFF00FF005 miembros|r · |cFFFFD1005 slots|r")
    campingControls.summaryText = summaryText'''

text = text[:idx1] + new_controls + text[idx2:]

# 4. Replace slot text formatting in UpdateCamping()
old_slots_code_start = "    -- Actualizar botones de clases de las 5 ranuras"
old_slots_code_end = 'containerFrame.campingControls.btnCampfire:SetText(string.format("🏕️ Fogón: %s (%d r.) ▼", fireName, fireSlots))'
idx3 = text.find(old_slots_code_start)
idx4 = text.find(old_slots_code_end)
assert idx3 != -1 and idx4 != -1, "Slots update indices not found"
idx4 += len(old_slots_code_end)

new_slots_update = r'''    -- Actualizar botones de clases de las 5 ranuras
    if containerFrame and containerFrame.campingControls and containerFrame.campingControls.slotButtons then
        for idx = 1, 5 do
            local btn = containerFrame.campingControls.slotButtons[idx]
            local cKey = self.partyClasses[idx] or "NONE"
            local cName = CLASS_NAMES_ES[cKey] or cKey
            local cColor = CLASS_COLORS[cKey] or "888888"
            if cKey == "NONE" then
                btn:SetText("|cFF888888(Vacío)|r")
            else
                if idx == 1 then
                    btn:SetText(string.format("|cFF%s(Tú) %s|r", cColor, cName))
                else
                    btn:SetText(string.format("|cFF%s%s|r", cColor, cName))
                end
            end
        end

        local fireName = selectedFire and selectedFire.name:gsub("Kit de fogón ", "") or "Oficial"
        local fireSlots = selectedFire and selectedFire.slots or 5
        containerFrame.campingControls.btnCampfire:SetText(string.format("|TInterface\\Icons\\spell_fire_fire:14:14:0:0|t Fogón: %s (%d r.)", fireName, fireSlots))'''

text = text[:idx3] + new_slots_update + text[idx4:]

# 5. Replace emoji checkmark and warning labels in camping rows
text = text.replace(
    'local countTag = count > 0 and "|cFF00FF00✓|r " or ""',
    'local countTag = count > 0 and "|TInterface\\\\RaidFrame\\\\ReadyCheck-Ready:12:12:0:0|t " or ""'
)

text = text.replace(
    'row.reasonLabel:SetText(string.format("|cFFFF5555⚠️ Solapa con %s|r", confName))',
    'row.reasonLabel:SetText(string.format("|cFFFF5555[!] Solapa con %s|r", confName))'
)

text = text.replace(
    'GameTooltip:AddLine("|cFFFF5555⚠️ Solapamiento de Buff:|r " .. (itm.conflictReason or "Duplica un beneficio de clase"), 1, 0.3, 0.3, true)',
    'GameTooltip:AddLine("|cFFFF5555[!] Solapamiento de Buff:|r " .. (itm.conflictReason or "Duplica un beneficio de clase"), 1, 0.3, 0.3, true)'
)

text = text.replace(
    'GameTooltip:AddLine(string.format("|cFF00FF00✅ Recomendado para el fogón (Ranura #%d):|r Máxima sinergia para tu grupo.", itm.slotOrder or 1), 0.2, 1, 0.2, true)',
    'GameTooltip:AddLine(string.format("|cFF00FF00[OK] Recomendado para el fogón (Ranura #%d):|r Máxima sinergia para tu grupo.", itm.slotOrder or 1), 0.2, 1, 0.2, true)'
)

text = text.replace(
    '{ text = campItem.isConflicted and ("⚠️ " .. (campItem.conflictReason or "Solapamiento"))',
    '{ text = campItem.isConflicted and ("[!] " .. (campItem.conflictReason or "Solapamiento"))'
)

# 6. Replace SelectCampItem details block
old_det_start = "        local conflictNotice = campItem.isConflicted"
old_det_end = "            statusStr\n        ))"
idx5 = text.find(old_det_start)
idx6 = text.find(old_det_end, idx5)
assert idx5 != -1 and idx6 != -1, "Detail block indices not found"
idx6 += len(old_det_end)

new_det = r'''        local conflictNotice = campItem.isConflicted
            and ("|cFFFF5555[!] DESCARTADO POR CONFLICTO:|r " .. (campItem.conflictReason or "Solapamiento") .. "\n")
            or "|cFF00FF00[OK] RECOMENDADO PARA EL FOGÓN:|r No colisiona con ningún bufo de las clases de tu grupo.\n"

        mainFrame.detailText:SetText(
            "Efecto de Campamento: |cFF00FF00" .. (campItem.effect or "Beneficio de campamento") .. "|r\n" ..
            "Profesión Requerida: |cFFFFD100" .. (campItem.profession or "Profesión") .. " (Habilidad " .. (campItem.skillReq or 20) .. ")|r · Fuente: |cFF00FFCC" .. (campItem.source or "Instructor de profesión") .. "|r\n" ..
            conflictNotice ..
            "Bufo de clase equivalente: |cFFFFFFFF" .. (campItem.classCopy or "Ninguno (Efecto único)") .. "|r\n" ..
            "Cómo usarlo: |cFFFFFFFFColócalo junto al fogón y descansa (/sit) o fabrica objetos durante 1 minuto para recibir 1 hora de beneficio.|r\n" ..
            "Estado en bolsas: " .. statusStr
        )'''

text = text[:idx5] + new_det + text[idx6:]

# 7. Replace SelectConsumable details block
old_cons_start = "        mainFrame.detailText:SetText(string.format(\n            \"Efecto Óptimo: |cFF00FF00%s|r"
old_cons_end = "            statusStr\n        ))"
idx7 = text.find(old_cons_start)
idx8 = text.find(old_cons_end, idx7)
assert idx7 != -1 and idx8 != -1, "Consumable block indices not found"
idx8 += len(old_cons_end)

new_cons = r'''        mainFrame.detailText:SetText(
            "Efecto Óptimo: |cFF00FF00" .. (itemData.effect or "Mejora de estadísticas") .. "|r  ·  Categoría: |cFFFFFFFF" .. (itemData.category or "Consumible") .. "|r\n" ..
            "Por qué se recomienda: |cFFFFD100" .. (itemData.tip or "Recomendado para máxima eficiencia en tu rol.") .. "|r\n" ..
            "Cómo obtenerlo: |cFF00FFCC" .. (itemData.source or "Alquimia / Cocina / Subasta / Vendedores de suministros") .. "|r\n" ..
            "Estado en bolsas: " .. statusStr
        )'''

text = text[:idx7] + new_cons + text[idx8:]

with open(raidprep_path, "w", encoding="utf-8") as f:
    f.write(text)

print("Replacement complete!")
