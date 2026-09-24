-- PARTIE 4/4 - Création de l'UI + Modules + Lancement (adapté interface v3)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local p = Players.LocalPlayer
local rs = RunService
local uis = UserInputService

getgenv().VAZ = getgenv().VAZ or {}
local VAZ = getgenv().VAZ

-- Attendre que l'UI soit disponible
repeat task.wait() until _G.VaztoodixUI or getgenv().VaztoodixUI

local UI = _G.VaztoodixUI or getgenv().VaztoodixUI
local ui = UI.new({
    Title = "Vaztoodix ™",
    Version = "v3.0",
})

-- ============================================================
-- CATÉGORIE : ACCUEIL
-- ============================================================
ui:AddTab("home", "Bienvenue")
ui:AddModule("home", "Bienvenue", {
    name = "Vaztoodix ™ Ultimate",
    desc = "Interface unique v3 - glassmorphism, animations, radial menu",
    callback = function()
        ui:Notify("Bienvenue dans Vaztoodix Ultimate !")
    end
})
ui:AddModule("home", "Bienvenue", {
    name = "Aide",
    desc = "Touche T = téléport | WASD en Fly = déplacement",
    callback = function()
        ui:Notify("T = téléport | Fly : WASD + Espace/Shift")
    end
})

-- ============================================================
-- CATÉGORIE : ARMES (icône "sword")
-- ============================================================
ui:AddTab("sword", "Armes 1-hit")
ui:AddModule("sword", "Armes 1-hit", {
    name = "zizi Tranchant",
    desc = "Portée 500 - mesh + animation",
    toggle = true,
    default = true,
    callback = function()
        if not p.Backpack:FindFirstChild("zizi Tranchant") then
            VAZ.CreerArme("zizi Tranchant", 500, "Bright red", "spiral", "12224215", "114369154163347")
        end
    end
})
ui:AddModule("sword", "Armes 1-hit", {
    name = "Micha Minivichi",
    desc = "Portée 600 - mesh + animation",
    toggle = true,
    default = true,
    callback = function()
        if not p.Backpack:FindFirstChild("Micha Minivichi") then
            VAZ.CreerArme("Micha Minivichi", 600, "Bright blue", "double", "115500717736588", "91612928120390")
        end
    end
})
ui:AddModule("sword", "Armes 1-hit", {
    name = "Loucybel_Facher ★",
    desc = "Marteau explosif - zone 15 studs",
    toggle = true,
    default = true,
    callback = function()
        if not p.Backpack:FindFirstChild("Loucybel_Facher") then
            VAZ.CreerArmeMarteau("10468797", "334753747")
        end
    end
})
ui:AddModule("sword", "Armes 1-hit", {
    name = "istadyxx26 ★",
    desc = "Arme spéciale avec effets visuels",
    toggle = true,
    default = true,
    callback = function()
        if not p.Backpack:FindFirstChild("istadyxx26") then
            VAZ.CreerArmeSpecial()
        end
    end
})
ui:AddModule("sword", "Armes 1-hit", {
    name = "Épées orbitales",
    desc = "6 épées tournoyant autour du joueur",
    toggle = true,
    default = true,
    callback = function()
        VAZ.SWORDS_ACTIVE = not VAZ.SWORDS_ACTIVE
        if VAZ.SWORDS_ACTIVE then VAZ.CreerSwords()
        else for _, s in pairs(VAZ.swords) do s:Destroy() end VAZ.swords = {} end
    end
})

-- ============================================================
-- CATÉGORIE : MOUVEMENT (icône "move")
-- ============================================================
ui:AddTab("move", "Déplacements")
ui:AddModule("move", "Déplacements", {
    name = "Vol (Fly)",
    desc = "WASD + Espace (monter) + Shift (descendre)",
    toggle = true,
    callback = function() VAZ.ToggleFly() end
})
ui:AddModule("move", "Déplacements", {
    name = "Speed Boost",
    desc = "Vitesse augmentée à 50",
    toggle = true,
    callback = function() VAZ.ToggleSpeed() end
})
ui:AddModule("move", "Déplacements", {
    name = "Jump Boost",
    desc = "Saut augmenté à 100",
    toggle = true,
    callback = function() VAZ.ToggleJump() end
})
ui:AddModule("move", "Déplacements", {
    name = "Téléport (Touche T)",
    desc = "Téléportation à la souris",
    toggle = true,
    default = true,
    callback = function()
        VAZ.TELEPORT_ACTIVE = not VAZ.TELEPORT_ACTIVE
    end
})
ui:AddModule("move", "Déplacements", {
    name = "Noclip",
    desc = "Traverser les murs",
    toggle = true,
    callback = function() VAZ.ToggleNoclip() end
})

-- ============================================================
-- CATÉGORIE : COMBAT (icône "crosshair")
-- ============================================================
ui:AddTab("crosshair", "Attaque")
ui:AddModule("crosshair", "Attaque", {
    name = "Tuer tous",
    desc = "Élimine tous les joueurs instantanément",
    callback = function()
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= p and v.Character then
                local h = v.Character:FindFirstChild("Humanoid")
                if h then
                    h.Health = 0
                    local e = Instance.new("Explosion")
                    e.Position = v.Character.HumanoidRootPart.Position
                    e.BlastRadius = 10
                    e.BlastPressure = 0
                    e.Parent = workspace
                end
            end
        end
        VAZ.ChangerNom()
        ui:Notify("Tous les joueurs éliminés")
    end
})
ui:AddModule("crosshair", "Attaque", {
    name = "Aimbot",
    desc = "Viser automatiquement le joueur le plus proche",
    toggle = true,
    callback = function()
        VAZ.AIMBOT_ACTIVE = not VAZ.AIMBOT_ACTIVE
    end
})
ui:AddModule("crosshair", "Attaque", {
    name = "Wallhack / ESP",
    desc = "Voir les joueurs à travers les murs",
    toggle = true,
    callback = function()
        VAZ.WALLHACK_ACTIVE = not VAZ.WALLHACK_ACTIVE
        VAZ.UpdateWallhack()
    end
})
ui:AddModule("crosshair", "Attaque", {
    name = "Clone",
    desc = "Créer un clone qui attaque les ennemis",
    toggle = true,
    callback = function() VAZ.ToggleClone() end
})

-- ============================================================
-- CATÉGORIE : UTILITAIRES (icône "settings")
-- ============================================================
ui:AddTab("settings", "Divers")
ui:AddModule("settings", "Divers", {
    name = "Godmode",
    desc = "Santé infinie",
    toggle = true,
    callback = function() VAZ.ToggleGodmode() end
})
ui:AddModule("settings", "Divers", {
    name = "Invisibilité",
    desc = "Devenir invisible",
    toggle = true,
    callback = function() VAZ.ToggleInvisible() end
})
ui:AddModule("settings", "Divers", {
    name = "Auto-click",
    desc = "Clic automatique",
    toggle = true,
    callback = function() VAZ.ToggleAutoClick() end
})
ui:AddModule("settings", "Divers", {
    name = "Anti-AFK",
    desc = "Éviter le kick pour inactivité",
    toggle = true,
    callback = function() VAZ.ToggleAntiAFK() end
})
ui:AddModule("settings", "Divers", {
    name = "Particules",
    desc = "Halo de particules colorées",
    toggle = true,
    callback = function() VAZ.ToggleParticles() end
})
ui:AddModule("settings", "Divers", {
    name = "Vol de véhicule",
    desc = "Prendre le contrôle du véhicule le plus proche",
    callback = function()
        VAZ.STEAL_VEHICLE_ACTIVE = true
        VAZ.StealVehicle()
        ui:Notify("Véhicule volé")
    end
})

-- ============================================================
-- CATÉGORIE : CRÉDITS (icône "info")
-- ============================================================
ui:AddTab("info", "À propos")
ui:AddModule("info", "À propos", {
    name = "Vaztoodix ™ v3",
    desc = "Antonio Vaztoodix, Micha, Ismaël Daniel, DeepSeek",
    callback = function() end
})
ui:AddModule("info", "À propos", {
    name = "Interface unique",
    desc = "Glassmorphism, sidebar verticale, onglets en bas, radial menu",
    callback = function()
        ui:Notify("Merci d'utiliser Vaztoodix !")
    end
})

-- ============================================================
-- BOUCLES AUTOMATIQUES
-- ============================================================

-- Aimbot en continu
rs.Heartbeat:Connect(function()
    if VAZ.AimbotLoop then VAZ.AimbotLoop() end
end)

-- Wallhack refresh
task.spawn(function()
    while true do
        task.wait(1)
        if VAZ.WALLHACK_ACTIVE then VAZ.UpdateWallhack() end
    end
end)

-- Réapparition des armes
rs.Heartbeat:Connect(function()
    local list = {
        {Nom = "zizi Tranchant", Portee = 500, Couleur = "Bright red", Forme = "spiral", MeshId = "12224215", AnimId = "114369154163347"},
        {Nom = "Micha Minivichi", Portee = 600, Couleur = "Bright blue", Forme = "double", MeshId = "115500717736588", AnimId = "91612928120390"},
        {Nom = "Loucybel_Facher", Portee = 0, Couleur = "Bright orange", Forme = "marteau", MeshId = "10468797", AnimId = "334753747", Special = "marteau"},
        {Nom = "istadyxx26", Portee = 600, Special = true}
    }
    for _, a in pairs(list) do
        if not p.Backpack:FindFirstChild(a.Nom) and not p.Character:FindFirstChild(a.Nom) then
            if a.Special == "marteau" then
                VAZ.CreerArmeMarteau(a.MeshId, a.AnimId)
            elseif a.Special == true then
                VAZ.CreerArmeSpecial()
            else
                VAZ.CreerArme(a.Nom, a.Portee, a.Couleur, a.Forme, a.MeshId, a.AnimId)
            end
        end
    end
    if VAZ.SWORDS_ACTIVE and #VAZ.swords == 0 and p.Character then VAZ.CreerSwords() end
end)

-- Changement de nom périodique
task.spawn(function()
    while task.wait(30) do
        VAZ.ChangerNom()
    end
end)

-- Touche T pour téléportation
uis.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.T then
        VAZ.Teleporter()
    end
end)

print("✅ Partie 4/4 chargée - Modules + Interface v3 + Lancement")
print("✅ Vaztoodix ™ Ultimate v3 chargé avec succès !")