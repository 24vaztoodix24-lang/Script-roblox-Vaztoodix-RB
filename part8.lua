-- PARTIE 8/8 - Sin Dragon (armes + touches G/C/F)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local p = Players.LocalPlayer

getgenv().VAZ = getgenv().VAZ or {}
local VAZ = getgenv().VAZ

pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/gObl00x/Pendulum-Fixed-AND-Others-Scripts/refs/heads/main/Sin%20Dragon"))()
end)

local function DonnerArmesSinDragon()
    local char = p.Character
    if not char then return end
    for _, v in pairs(p.Backpack:GetChildren()) do
        if v:IsA("Tool") and v.Name:find("Sin") then
            v.Parent = char
        end
    end
end

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.G or input.KeyCode == Enum.KeyCode.C or input.KeyCode == Enum.KeyCode.F then
        DonnerArmesSinDragon()
        if VAZ and VAZ.NotifyUI then VAZ.NotifyUI("Armes Sin Dragon données (" .. input.KeyCode.Name .. ")") end
    end
end)

function VAZ.BuildSinDragonTab(ui)
    ui:AddTab("crosshair", "Sin Dragon")
    ui:AddModule("crosshair", "Sin Dragon", {
        name = "Donner les armes Sin Dragon",
        desc = "Touche G, C ou F pour équiper",
        callback = function() DonnerArmesSinDragon() ui:Notify("Armes Sin Dragon données") end
    })
    ui:AddModule("crosshair", "Sin Dragon", { name = "Attaque 1 (G)", desc = "Clic gauche pour frapper", callback = function() end })
    ui:AddModule("crosshair", "Sin Dragon", { name = "Attaque 2 (C)", desc = "Clic gauche pour frapper", callback = function() end })
    ui:AddModule("crosshair", "Sin Dragon", { name = "Attaque 3 (F)", desc = "Clic gauche pour frapper", callback = function() end })
end

VAZ.DonnerArmesSinDragon = DonnerArmesSinDragon
print("✅ Partie 8/8 chargée - Sin Dragon (G / C / F)")