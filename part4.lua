-- PARTIE 4/4 - Création de l'UI + Modules + Lancement
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local p = Players.LocalPlayer
local rs = RunService
local uis = UserInputService

getgenv().VAZ = getgenv().VAZ or {}
local VAZ = getgenv().VAZ

repeat task.wait() until _G.VaztoodixUI or getgenv().VaztoodixUI

local UI = _G.VaztoodixUI or getgenv().VaztoodixUI
local ui = UI.new({ Title = "Vaztoodix ™", Version = "v4.0" })

-- ACCUEIL
ui:AddTab("home", "Bienvenue")
ui:AddModule("home", "Bienvenue", {
    name = "Vaztoodix ™ Ultimate", desc = "Interface unique v4",
    callback = function() ui:Notify("Bienvenue !") end
})

-- ARMES
ui:AddTab("sword", "Armes 1-hit")
ui:AddModule("sword", "Armes 1-hit", { name = "zizi Tranchant", desc = "Portée 500", toggle = true, default = true, callback = function() if not p.Backpack:FindFirstChild("zizi Tranchant") then VAZ.CreerArme("zizi Tranchant", 500, "Bright red", "spiral", "12224215", "114369154163347") end end })
ui:AddModule("sword", "Armes 1-hit", { name = "Micha Minivichi", desc = "Portée 600", toggle = true, default = true, callback = function() if not p.Backpack:FindFirstChild("Micha Minivichi") then VAZ.CreerArme("Micha Minivichi", 600, "Bright blue", "double", "115500717736588", "91612928120390") end end })
ui:AddModule("sword", "Armes 1-hit", { name = "Loucybel_Facher ★", desc = "Marteau explosif", toggle = true, default = true, callback = function() if not p.Backpack:FindFirstChild("Loucybel_Facher") then VAZ.CreerArmeMarteau("10468797", "334753747") end end })
ui:AddModule("sword", "Armes 1-hit", { name = "istadyxx26 ★", desc = "Arme spéciale", toggle = true, default = true, callback = function() if not p.Backpack:FindFirstChild("istadyxx26") then VAZ.CreerArmeSpecial() end end })
ui:AddModule("sword", "Armes 1-hit", { name = "Épées orbitales", desc = "6 épées tournoyantes", toggle = true, default = true, callback = function() VAZ.SWORDS_ACTIVE = not VAZ.SWORDS_ACTIVE if VAZ.SWORDS_ACTIVE then VAZ.CreerSwords() else for _, s in pairs(VAZ.swords) do s:Destroy() end VAZ.swords = {} end end })

-- MOUVEMENT
ui:AddTab("move", "Déplacements")
ui:AddModule("move", "Déplacements", { name = "Vol (Fly)", desc = "WASD + Espace + Shift", toggle = true, callback = function() VAZ.ToggleFly() end })
ui:AddModule("move", "Déplacements", { name = "Speed Boost", desc = "Vitesse 50", toggle = true, callback = function() VAZ.ToggleSpeed() end })
ui:AddModule("move", "Déplacements", { name = "Jump Boost", desc = "Saut 100", toggle = true, callback = function() VAZ.ToggleJump() end })
ui:AddModule("move", "Déplacements", { name = "Téléport (T)", desc = "À la souris", toggle = true, default = true, callback = function() VAZ.TELEPORT_ACTIVE = not VAZ.TELEPORT_ACTIVE end })
ui:AddModule("move", "Déplacements", { name = "Noclip", desc = "Traverser les murs", toggle = true, callback = function() VAZ.ToggleNoclip() end })

-- COMBAT
ui:AddTab("crosshair", "Attaque")
ui:AddModule("crosshair", "Attaque", { name = "Tuer tous", desc = "Élimine tout le monde", callback = function() for _, v in pairs(Players:GetPlayers()) do if v ~= p and v.Character then local h = v.Character:FindFirstChild("Humanoid") if h then h.Health = 0 local e = Instance.new("Explosion") e.Position = v.Character.HumanoidRootPart.Position e.BlastRadius = 10 e.BlastPressure = 0 e.Parent = workspace end end end VAZ.ChangerNom() ui:Notify("Tous éliminés") end })
ui:AddModule("crosshair", "Attaque", { name = "Aimbot", desc = "Exunys V3", toggle = true, callback = function() VAZ.ToggleAimbot() end })
ui:AddModule("crosshair", "Attaque", { name = "Wallhack / ESP", desc = "Voir à travers les murs", toggle = true, callback = function() VAZ.WALLHACK_ACTIVE = not VAZ.WALLHACK_ACTIVE VAZ.UpdateWallhack() end })
ui:AddModule("crosshair", "Attaque", { name = "Clone", desc = "Clone qui attaque", toggle = true, callback = function() VAZ.ToggleClone() end })

-- UTILITAIRES
ui:AddTab("settings", "Divers")
ui:AddModule("settings", "Divers", { name = "Godmode", desc = "Santé infinie", toggle = true, callback = function() VAZ.ToggleGodmode() end })
ui:AddModule("settings", "Divers", { name = "Invisibilité", desc = "Devenir invisible", toggle = true, callback = function() VAZ.ToggleInvisible() end })
ui:AddModule("settings", "Divers", { name = "Auto-click", desc = "Clic auto", toggle = true, callback = function() VAZ.ToggleAutoClick() end })
ui:AddModule("settings", "Divers", { name = "Anti-AFK", desc = "Éviter le kick", toggle = true, callback = function() VAZ.ToggleAntiAFK() end })
ui:AddModule("settings", "Divers", { name = "Particules", desc = "Halo coloré", toggle = true, callback = function() VAZ.ToggleParticles() end })

-- EFFETS (Partie 7 - c00lgui)
if VAZ.BuildEffectsTab then VAZ.BuildEffectsTab(ui) end

-- CRÉDITS
ui:AddTab("info", "À propos")
ui:AddModule("info", "À propos", { name = "Vaztoodix ™ v4", desc = "Antonio Vaztoodix, Micha, Ismaël Daniel, DeepSeek", callback = function() end })

-- BOUCLES
rs.Heartbeat:Connect(function() if VAZ.AimbotLoop then VAZ.AimbotLoop() end end)
task.spawn(function() while true do task.wait(1) if VAZ.WALLHACK_ACTIVE then VAZ.UpdateWallhack() end end end)
task.spawn(function() while task.wait(30) do VAZ.ChangerNom() end end)
uis.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.T then VAZ.Teleporter() end
end)

print("✅ Partie 4/4 chargée - Interface + modules + Effets (c00lgui)")