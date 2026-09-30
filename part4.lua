-- PARTIE 4/4 - Modules + Paramètres + Fonctions Admin + Lancement
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local p = Players.LocalPlayer
local rs = RunService
local uis = UserInputService

getgenv().VAZ = getgenv().VAZ or {}
local VAZ = getgenv().VAZ

VAZ.SHOW_NOTIFS = true
VAZ.UI_SIZE = "Moyenne"
VAZ.THEME = "Rouge/Violet"
VAZ.SAVE_POS = false
VAZ.GRAVITY = workspace.Gravity or 196.2
VAZ.TIME_SCALE = 1

repeat task.wait() until _G.VaztoodixUI or getgenv().VaztoodixUI

local UI = _G.VaztoodixUI or getgenv().VaztoodixUI
local ui = UI.new({ Title = "Vaztoodix ™", Version = "v6.0" })

-- ============================================================
-- ACCUEIL
-- ============================================================
ui:AddTab("home", "Bienvenue")
ui:AddModule("home", "Bienvenue", {
    name = "Vaztoodix ™ Ultimate v6",
    desc = "Interface unique avec admin + paramètres",
    callback = function() ui:Notify("Bienvenue !") end
})
ui:AddModule("home", "Bienvenue", {
    name = "Aide",
    desc = "T = téléport | Fly = WASD + Espace/Shift",
    callback = function() ui:Notify("T = téléport | Fly = WASD") end
})

-- ============================================================
-- ARMES
-- ============================================================
ui:AddTab("sword", "Armes 1-hit")
ui:AddModule("sword", "Armes 1-hit", { name = "zizi Tranchant", desc = "Portée 500", toggle = true, default = true, callback = function() if not p.Backpack:FindFirstChild("zizi Tranchant") then VAZ.CreerArmeRoblox("zizi Tranchant", "93136674", 500) end end })
ui:AddModule("sword", "Armes 1-hit", { name = "Micha Minivichi", desc = "Portée 600", toggle = true, default = true, callback = function() if not p.Backpack:FindFirstChild("Micha Minivichi") then VAZ.CreerArmeRoblox("Micha Minivichi", "12187319", 600) end end })
ui:AddModule("sword", "Armes 1-hit", { name = "Loucybel_Facher ★", desc = "Marteau explosif", toggle = true, default = true, callback = function() if not p.Backpack:FindFirstChild("Loucybel_Facher") then VAZ.CreerArmeMarteau("478707595", "334753747") end end })
ui:AddModule("sword", "Armes 1-hit", { name = "istadyxx26 ★", desc = "Arme spéciale", toggle = true, default = true, callback = function() if not p.Backpack:FindFirstChild("istadyxx26") then VAZ.CreerArmeSpecial() end end })
ui:AddModule("sword", "Armes 1-hit", { name = "Épées orbitales", desc = "6 épées tournoyantes", toggle = true, default = true, callback = function() VAZ.SWORDS_ACTIVE = not VAZ.SWORDS_ACTIVE if VAZ.SWORDS_ACTIVE then VAZ.CreerSwords() else for _, s in pairs(VAZ.swords) do s:Destroy() end VAZ.swords = {} end end })

-- ============================================================
-- MOUVEMENT
-- ============================================================
ui:AddTab("move", "Déplacements")
ui:AddModule("move", "Déplacements", { name = "Vol (Fly)", desc = "WASD + Espace + Shift", toggle = true, callback = function() VAZ.ToggleFly() end })
ui:AddModule("move", "Déplacements", { name = "Speed Boost", desc = "Vitesse 50", toggle = true, callback = function() VAZ.ToggleSpeed() end })
ui:AddModule("move", "Déplacements", { name = "Jump Boost", desc = "Saut 100", toggle = true, callback = function() VAZ.ToggleJump() end })
ui:AddModule("move", "Déplacements", { name = "Téléport (T)", desc = "À la souris", toggle = true, default = true, callback = function() VAZ.TELEPORT_ACTIVE = not VAZ.TELEPORT_ACTIVE end })
ui:AddModule("move", "Déplacements", { name = "Noclip", desc = "Traverser les murs", toggle = true, callback = function() VAZ.ToggleNoclip() end })
ui:AddSlider("move", "Déplacements", "Vitesse de marche", 16, 300, 16, function(v)
    local char = p.Character
    if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = v end
    VAZ.WALK_SPEED = v
end)
ui:AddSlider("move", "Déplacements", "Vitesse de vol", 50, 500, 50, function(v) VAZ.FLY_SPEED = v end)
ui:AddTextBox("move", "Déplacements", "Entrer la vitesse de marche", "16", "16", function(v)
    local char = p.Character
    if char and char:FindFirstChild("Humanoid") then char.Humanoid.WalkSpeed = v end
end)
ui:AddTextBox("move", "Déplacements", "Entrer la vitesse de saut", "50", "50", function(v)
    local char = p.Character
    if char and char:FindFirstChild("Humanoid") then char.Humanoid.JumpPower = v end
end)

-- ============================================================
-- COMBAT
-- ============================================================
ui:AddTab("crosshair", "Attaque")
ui:AddModule("crosshair", "Attaque", { name = "Tuer tous", desc = "Élimine tout le monde", callback = function() for _, v in pairs(Players:GetPlayers()) do if v ~= p and v.Character then local h = v.Character:FindFirstChild("Humanoid") if h then h.Health = 0 local e = Instance.new("Explosion") e.Position = v.Character.HumanoidRootPart.Position e.BlastRadius = 10 e.BlastPressure = 0 e.Parent = workspace end end end VAZ.ChangerNom() ui:Notify("Tous éliminés") end })
ui:AddModule("crosshair", "Attaque", { name = "Aimbot", desc = "Exunys V3", toggle = true, callback = function() VAZ.ToggleAimbot() end })
ui:AddModule("crosshair", "Attaque", { name = "Wallhack / ESP", desc = "Voir à travers les murs", toggle = true, callback = function() VAZ.WALLHACK_ACTIVE = not VAZ.WALLHACK_ACTIVE VAZ.UpdateWallhack() end })
ui:AddModule("crosshair", "Attaque", { name = "Clone (corrigé)", desc = "Clone qui te suit et attaque", toggle = true, callback = function() VAZ.ToggleClone() end })
ui:AddModule("crosshair", "Attaque", { name = "Freeze All", desc = "Geler tous les joueurs", callback = function()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= p and v.Character then
            local hrp = v.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Anchored = true end
        end
    end
    ui:Notify("Tous gelés")
end })
ui:AddModule("crosshair", "Attaque", { name = "Unfreeze All", desc = "Dégeler tous les joueurs", callback = function()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= p and v.Character then
            local hrp = v.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Anchored = false end
        end
    end
    ui:Notify("Tous dégelés")
end })
ui:AddModule("crosshair", "Attaque", { name = "Ragdoll All", desc = "Mettre en ragdoll tous les joueurs", callback = function()
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= p and v.Character then
            local hum = v.Character:FindFirstChild("Humanoid")
            if hum then hum.PlatformStand = true end
        end
    end
    ui:Notify("Ragdoll activé")
end })

-- ============================================================
-- DIVERS
-- ============================================================
ui:AddTab("divers", "Divers")
ui:AddModule("divers", "Divers", { name = "Godmode", desc = "Santé infinie", toggle = true, callback = function() VAZ.ToggleGodmode() end })
ui:AddModule("divers", "Divers", { name = "Invisibilité", desc = "Devenir invisible", toggle = true, callback = function() VAZ.ToggleInvisible() end })
ui:AddModule("divers", "Divers", { name = "Auto-click", desc = "Clic auto", toggle = true, callback = function() VAZ.ToggleAutoClick() end })
ui:AddModule("divers", "Divers", { name = "Anti-AFK", desc = "Éviter le kick", toggle = true, callback = function() VAZ.ToggleAntiAFK() end })
ui:AddModule("divers", "Divers", { name = "Particules", desc = "Halo coloré", toggle = true, callback = function() VAZ.ToggleParticles() end })
ui:AddSlider("divers", "Divers", "Gravité", 0, 500, workspace.Gravity, function(v)
    workspace.Gravity = v
    VAZ.GRAVITY = v
end)
ui:AddTextBox("divers", "Divers", "Entrer la gravité", "196.2", "196.2", function(v) workspace.Gravity = v end)

-- ============================================================
-- EFFETS
-- ============================================================
if VAZ.BuildEffectsTab then VAZ.BuildEffectsTab(ui) end

-- ============================================================
-- PARAMÈTRES
-- ============================================================
function VAZ.BuildSettingsTab(ui)
    ui:AddTab("settings", "Paramètres")
    ui:AddModule("settings", "Paramètres", {
        name = "Afficher les notifications",
        desc = "Activer/désactiver les pop-ups",
        toggle = true,
        default = true,
        callback = function(state) VAZ.SHOW_NOTIFS = state if state then ui:Notify("Notifications ON") end end
    })
    ui:AddModule("settings", "Paramètres", {
        name = "Taille : Petite",
        desc = "Réduire la fenêtre (75%)",
        callback = function() if ui.SetScale then ui:SetScale(0.75) end ui:Notify("Taille : Petite") end
    })
    ui:AddModule("settings", "Paramètres", {
        name = "Taille : Moyenne",
        desc = "Taille par défaut (100%)",
        callback = function() if ui.SetScale then ui:SetScale(1) end ui:Notify("Taille : Moyenne") end
    })
    ui:AddModule("settings", "Paramètres", {
        name = "Taille : Grande",
        desc = "Agrandir la fenêtre (125%)",
        callback = function() if ui.SetScale then ui:SetScale(1.25) end ui:Notify("Taille : Grande") end
    })
    ui:AddModule("settings", "Paramètres", {
        name = "Fond : Dégradé rouge",
        desc = "Style 1 (par défaut)",
        callback = function() if ui.SetBackground then ui:SetBackground(1) end ui:Notify("Fond : Dégradé rouge") end
    })
    ui:AddModule("settings", "Paramètres", {
        name = "Fond : Transparent",
        desc = "Style 2 (voit le jeu derrière)",
        callback = function() if ui.SetBackground then ui:SetBackground(2) end ui:Notify("Fond : Transparent") end
    })
    ui:AddModule("settings", "Paramètres", {
        name = "Recentrer l'interface",
        desc = "Remettre la fenêtre au centre",
        callback = function()
            if ui.root then
                ui.root.Position = UDim2.new(0.5, -ui.root.AbsoluteSize.X/2, 0.5, -ui.root.AbsoluteSize.Y/2)
            end
            ui:Notify("Interface recentrée")
        end
    })
    ui:AddModule("settings", "Paramètres", {
        name = "Sauvegarder la position",
        desc = "Mémoriser la position de la fenêtre",
        toggle = true,
        default = false,
        callback = function(state) VAZ.SAVE_POS = state ui:Notify("Sauvegarde : " .. (state and "ON" or "OFF")) end
    })
    ui:AddModule("settings", "Paramètres", {
        name = "Thème : Rouge/Violet",
        desc = "Thème actuel",
        callback = function() ui:Notify("Thème : Rouge/Violet") end
    })
end
VAZ.BuildSettingsTab(ui)

-- ============================================================
-- CRÉDITS
-- ============================================================
ui:AddTab("info", "À propos")
ui:AddModule("info", "À propos", { name = "Vaztoodix ™ v6", desc = "Antonio Vaztoodix, Micha, Ismaël Daniel, DeepSeek", callback = function() end })

-- ============================================================
-- BOUCLES AUTOMATIQUES
-- ============================================================
rs.Heartbeat:Connect(function() if VAZ.AimbotLoop then VAZ.AimbotLoop() end end)
task.spawn(function() while true do task.wait(1) if VAZ.WALLHACK_ACTIVE then VAZ.UpdateWallhack() end end end)
task.spawn(function() while task.wait(30) do VAZ.ChangerNom() end end)
uis.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.T then VAZ.Teleporter() end
end)

print("✅ Partie 4/4 chargée - Modules + Paramètres + Admin + TextBox")
print("✅ Vaztoodix ™ v6 chargé avec succès !")