-- PARTIE 4/4 - Création de l'UI + Modules + Lancement

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
    Version = "v2.0",
})

-- Catégorie : Armes
ui:AddCategory("Armes")
ui:AddTab("Armes", "Armes 1-hit")

ui:AddModule("Armes", "Armes 1-hit", {
    name = "zizi Tranchant",
    desc = "Portée 500 studs - mesh + animation",
    callback = function()
        if not p.Backpack:FindFirstChild("zizi Tranchant") then
            VAZ.CreerArme("zizi Tranchant", 500, "Bright red", "spiral", "12224215", "114369154163347")
        end
    end
})
ui:AddModule("Armes", "Armes 1-hit", {
    name = "Micha Minivichi",
    desc = "Portée 600 studs - mesh + animation",
    callback = function()
        if not p.Backpack:FindFirstChild("Micha Minivichi") then
            VAZ.CreerArme("Micha Minivichi", 600, "Bright blue", "double", "115500717736588", "91612928120390")
        end
    end
})
ui:AddModule("Armes", "Armes 1-hit", {
    name = "Loucybel_Facher ★",
    desc = "Marteau explosif - zone de dégâts 15 studs",
    callback = function()
        if not p.Backpack:FindFirstChild("Loucybel_Facher") then
            VAZ.CreerArmeMarteau("10468797", "334753747")
        end
    end
})
ui:AddModule("Armes", "Armes 1-hit", {
    name = "istadyxx26 ★",
    desc = "Arme spéciale avec effets visuels",
    callback = function()
        if not p.Backpack:FindFirstChild("istadyxx26") then
            VAZ.CreerArmeSpecial()
        end
    end
})
ui:AddModule("Armes", "Armes 1-hit", {
    name = "Épées orbitales",
    desc = "6 épées tournoyant autour du joueur",
    callback = function()
        VAZ.SWORDS_ACTIVE = not VAZ.SWORDS_ACTIVE
        if VAZ.SWORDS_ACTIVE then VAZ.CreerSwords()
        else for _, s in pairs(VAZ.swords) do s:Destroy() end VAZ.swords = {} end
    end
})

-- Catégorie : Mouvement
ui:AddCategory("Mouvement")
ui:AddTab("Mouvement", "Déplacements")

ui:AddModule("Mouvement", "Déplacements", {
    name = "Vol (Fly)",
    desc = "WASD + Espace (monter) + Shift (descendre)",
    callback = function() VAZ.ToggleFly() end
})
ui:AddModule("Mouvement", "Déplacements", {
    name = "Speed Boost",
    desc = "Vitesse augmentée à 50",
    callback = function() VAZ.ToggleSpeed() end
})
ui:AddModule("Mouvement", "Déplacements", {
    name = "Jump Boost",
    desc = "Saut augmenté à 100",
    callback = function() VAZ.ToggleJump() end
})
ui:AddModule("Mouvement", "Déplacements", {
    name = "Téléport (Touche T)",
    desc = "Téléportation à la souris - clic pour activer/désactiver",
    callback = function()
        VAZ.TELEPORT_ACTIVE = not VAZ.TELEPORT_ACTIVE
    end
})
ui:AddModule("Mouvement", "Déplacements", {
    name = "Noclip",
    desc = "Traverser les murs",
    callback = function() VAZ.ToggleNoclip() end
})

-- Catégorie : Combat
ui:AddCategory("Combat")
ui:AddTab("Combat", "Attaque")

ui:AddModule("Combat", "Attaque", {
    name = "Tuer tous",
    desc = "Élimine tous les joueurs",
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
    end
})
ui:AddModule("Combat", "Attaque", {
    name = "Aimbot",
    desc = "Viser automatiquement le joueur le plus proche",
    callback = function()
        VAZ.AIMBOT_ACTIVE = not VAZ.AIMBOT_ACTIVE
    end
})
ui:AddModule("Combat", "Attaque", {
    name = "Wallhack / ESP",
    desc = "Voir les joueurs à travers les murs",
    callback = function()
        VAZ.WALLHACK_ACTIVE = not VAZ.WALLHACK_ACTIVE
        VAZ.UpdateWallhack()
    end
})
ui:AddModule("Combat", "Attaque", {
    name = "Clone",
    desc = "Créer un clone qui attaque les ennemis",
    callback = function() VAZ.ToggleClone() end
})

-- Catégorie : Utilitaires
ui:AddCategory("Utilitaires")
ui:AddTab("Utilitaires", "Divers")

ui:AddModule("Utilitaires", "Divers", {
    name = "Godmode",
    desc = "Santé infinie",
    callback = function() VAZ.ToggleGodmode() end
})
ui:AddModule("Utilitaires", "Divers", {
    name = "Invisibilité",
    desc = "Devenir invisible",
    callback = function() VAZ.ToggleInvisible() end
})
ui:AddModule("Utilitaires", "Divers", {
    name = "Auto-click",
    desc = "Clic automatique",
    callback = function() VAZ.ToggleAutoClick() end
})
ui:AddModule("Utilitaires", "Divers", {
    name = "Anti-AFK",
    desc = "Éviter le kick pour inactivité",
    callback = function() VAZ.ToggleAntiAFK() end
})
ui:AddModule("Utilitaires", "Divers", {
    name = "Particules",
    desc = "Halo de particules colorées",
    callback = function() VAZ.ToggleParticles() end
})
ui:AddModule("Utilitaires", "Divers", {
    name = "Vol de véhicule",
    desc = "Prendre le contrôle du véhicule le plus proche",
    callback = function()
        VAZ.STEAL_VEHICLE_ACTIVE = true
        VAZ.StealVehicle()
    end
})

-- Catégorie : Crédits
ui:AddCategory("Crédits")
ui:AddTab("Crédits", "À propos")
ui:AddModule("Crédits", "À propos", {
    name = "Vaztoodix ™",
    desc = "Antonio Vaztoodix, Micha, Ismaël Daniel, DeepSeek",
    callback = function() end
})

-- Boucles automatiques
rs.Heartbeat:Connect(function()
    if VAZ.AimbotLoop then VAZ.AimbotLoop() end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if VAZ.WALLHACK_ACTIVE then VAZ.UpdateWallhack() end
    end
end)

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

task.spawn(function()
    while task.wait(30) do
        VAZ.ChangerNom()
    end
end)

uis.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.T then
        VAZ.Teleporter()
    end
end)

print("✅ Partie 4/4 chargée - Interface + Modules + Lancement")
print("✅ Vaztoodix ™ Ultimate chargé avec succès !")