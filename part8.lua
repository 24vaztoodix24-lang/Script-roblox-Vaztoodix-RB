-- PARTIE 8/8 - Sin Dragon (armes + touches G/C/F)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local p = Players.LocalPlayer

getgenv().VAZ = getgenv().VAZ or {}
local VAZ = getgenv().VAZ

-- Chargement du script Sin Dragon
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/gObl00x/Pendulum-Fixed-AND-Others-Scripts/refs/heads/main/Sin%20Dragon"))()
end)

-- Donner les armes Sin Dragon
local function DonnerArmesSinDragon()
    local char = p.Character
    if not char then return end
    for _, v in pairs(p.Backpack:GetChildren()) do
        if v:IsA("Tool") and (v.Name:find("Sin") or v.Name:find("Dragon")) then
            v.Parent = char
        end
    end
end
VAZ.DonnerArmesSinDragon = DonnerArmesSinDragon

-- Touches G, C, F
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.G or input.KeyCode == Enum.KeyCode.C or input.KeyCode == Enum.KeyCode.F then
        DonnerArmesSinDragon()
        if VAZ and VAZ.NotifyUI then VAZ.NotifyUI("Armes Sin Dragon données (" .. input.KeyCode.Name .. ")") end
    end
end)

-- Construction de l'onglet Sin Dragon dans "crosshair" (Combat / PvP)
function VAZ.BuildSinDragonTab(ui)
    ui:AddTab("crosshair", "Sin Dragon")
    ui:AddModule("crosshair", "Sin Dragon", {
        name = "Donner les armes Sin Dragon",
        desc = "Touche G, C ou F pour équiper",
        callback = function()
            DonnerArmesSinDragon()
            ui:Notify("Armes Sin Dragon données")
        end
    })
    ui:AddModule("crosshair", "Sin Dragon", {
        name = "Attaque 1 (G)",
        desc = "Clic gauche pour frapper",
        callback = function() end
    })
    ui:AddModule("crosshair", "Sin Dragon", {
        name = "Attaque 2 (C)",
        desc = "Clic gauche pour frapper",
        callback = function() end
    })
    ui:AddModule("crosshair", "Sin Dragon", {
        name = "Attaque 3 (F)",
        desc = "Clic gauche pour frapper",
        callback = function() end
    })
    ui:AddModule("crosshair", "Sin Dragon", {
        name = "Info",
        desc = "Sin Dragon = touches G, C, F pour les armes",
        callback = function() ui:Notify("G / C / F = armes Sin Dragon") end
    })
end

print("✅ Partie 8/8 chargée - Sin Dragon (onglet dans Combat)")