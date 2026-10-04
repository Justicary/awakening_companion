import re

mainui_path = "/home/justicary/proyectos/antigravity/AwakeningCompanion/Modules/MainUI.lua"

with open(mainui_path, "r", encoding="utf-8") as f:
    content = f.read()

# 1. Update OnActionButton1
old_act1 = """    elseif currentKey == "prep" then
        if ns.RaidPrep and ns.RaidPrep.BroadcastStatus then
            ns.RaidPrep:BroadcastStatus()
        end"""

new_act1 = """    elseif currentKey == "prep" then
        if ns.RaidPrep then
            if ns.RaidPrep.currentSubMode == "camping" then
                if ns.RaidPrep.BroadcastCamp then ns.RaidPrep:BroadcastCamp() end
            else
                if ns.RaidPrep.BroadcastStatus then ns.RaidPrep:BroadcastStatus() end
            end
        end"""

assert old_act1 in content, "old_act1 not found"
content = content.replace(old_act1, new_act1, 1)

# 2. Update OnActionButton2
old_act2 = """    elseif currentKey == "prep" then
        if ns.RaidPrep and ns.RaidPrep.ScanInventory then
            ns.RaidPrep:ScanInventory()
        end
        self:RefreshCurrentView()"""

new_act2 = """    elseif currentKey == "prep" then
        if ns.RaidPrep then
            if ns.RaidPrep.currentSubMode == "camping" then
                if ns.RaidPrep.ScanParty then ns.RaidPrep:ScanParty() end
            else
                if ns.RaidPrep.ScanInventory then ns.RaidPrep:ScanInventory() end
            end
        end
        self:RefreshCurrentView()"""

assert old_act2 in content, "old_act2 not found"
content = content.replace(old_act2, new_act2, 1)

# 3. Update UpdateBottomButtons
old_btm = """    elseif currentKey == "prep" then
        bottomButtons[1]:SetText("Transmitir Prep")
        bottomButtons[2]:SetText("Reescanear")
        bottomButtons[3]:SetText("Alternar HUD")"""

new_btm = """    elseif currentKey == "prep" then
        if ns.RaidPrep and ns.RaidPrep.currentSubMode == "camping" then
            bottomButtons[1]:SetText("Transmitir Camp")
            bottomButtons[2]:SetText("Escanear Grupo")
        else
            bottomButtons[1]:SetText("Transmitir Prep")
            bottomButtons[2]:SetText("Reescanear")
        end
        bottomButtons[3]:SetText("Alternar HUD")"""

assert old_btm in content, "old_btm not found"
content = content.replace(old_btm, new_btm, 1)

# 4. Update SelectTab for prep
old_sel = """    elseif currentKey == "prep" then
        SetColumnHeaders("Consumible", 220, 0, "Categoría / Efecto", 120, 221, "Inventario", 102, 342, "RIGHT")
        if ns.RaidPrep and ns.RaidPrep.Update then
            ns.RaidPrep:Update()
        end"""

new_sel = """    elseif currentKey == "prep" then
        if ns.RaidPrep and ns.RaidPrep.currentSubMode == "camping" then
            SetColumnHeaders("Mejora de Campamento", 195, 0, "Profesión / Req", 90, 196, "Beneficio / Estado", 157, 287, "RIGHT")
        else
            SetColumnHeaders("Consumible", 220, 0, "Categoría / Efecto", 120, 221, "Inventario", 102, 342, "RIGHT")
        end
        self:UpdateBottomButtons()
        if ns.RaidPrep and ns.RaidPrep.Update then
            ns.RaidPrep:Update()
        end"""

assert old_sel in content, "old_sel not found"
content = content.replace(old_sel, new_sel, 1)

# 5. Add MainUI:UpdatePrepTabButtons
update_prep_func = """function MainUI:UpdatePrepTabButtons()
    local currentKey = TABS_CONFIG[currentTab] and TABS_CONFIG[currentTab].key
    if currentKey == "prep" then
        if ns.RaidPrep and ns.RaidPrep.currentSubMode == "camping" then
            SetColumnHeaders("Mejora de Campamento", 195, 0, "Profesión / Req", 90, 196, "Beneficio / Estado", 157, 287, "RIGHT")
        else
            SetColumnHeaders("Consumible", 220, 0, "Categoría / Efecto", 120, 221, "Inventario", 102, 342, "RIGHT")
        end
        self:UpdateBottomButtons()
    end
end
"""

target_after_btm = "function MainUI:UpdateBottomButtons()"
assert target_after_btm in content, "target_after_btm not found"
content = content.replace(target_after_btm, update_prep_func + "\n" + target_after_btm, 1)

with open(mainui_path, "w", encoding="utf-8") as f:
    f.write(content)

print("MainUI.lua successfully updated.")
