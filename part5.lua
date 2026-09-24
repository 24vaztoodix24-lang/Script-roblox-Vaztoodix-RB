-- PARTIE 5/5 - FE Gun Kit appliqué aux armes Vaztoodix
-- Charge le kit d'armes FE (modèles + animations) et l'associe à zizi Tranchant, Micha Minivichi, Loucybel_Facher, istadyxx26

local Players = game:GetService("Players")
local p = Players.LocalPlayer

getgenv().VAZ = getgenv().VAZ or {}
local VAZ = getgenv().VAZ

-- IDs FE Gun Kit (Snale Edition)
local FE_GUN_KIT = {
    Model = "rbxassetid://8436679939", -- Kit complet (contient les modèles + animations)
    Animations = {
        Idle = "rbxassetid://7219790944",
        Shoot = "rbxassetid://7219789080",
        Reload = "rbxassetid://7219791819",
        Equip = "rbxassetid://7219788371",
    }
}

-- Liste des armes avec leur configuration FE
local ARMES_FE = {
    {
        Nom = "zizi Tranchant",
        Portee = 500,
        MeshId = "12224215",
        Couleur = "Bright red",
        Forme = "spiral",
        FE_Model = nil, -- utiliser le mesh simple
        FE_Anim = FE_GUN_KIT.Animations.Shoot,
    },
    {
        Nom = "Micha Minivichi",
        Portee = 600,
        MeshId = "115500717736588",
        Couleur = "Bright blue",
        Forme = "double",
        FE_Model = nil,
        FE_Anim = FE_GUN_KIT.Animations.Shoot,
    },
    {
        Nom = "Loucybel_Facher",
        Portee = 0,
        MeshId = "10468797",
        Couleur = "Bright orange",
        Forme = "marteau",
        FE_Model = nil,
        FE_Anim = FE_GUN_KIT.Animations.Shoot,
    },
    {
        Nom = "istadyxx26",
        Portee = 600,
        MeshId = nil,
        Couleur = "Bright violet",
        Forme = "double",
        FE_Model = nil,
        FE_Anim = FE_GUN_KIT.Animations.Shoot,
    }
}

-- Fonction pour charger une animation FE sur un tool
local function ApplyFEAnimation(tool, animId)
    local char = p.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid then return end
    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end
    local anim = Instance.new("Animation")
    anim.AnimationId = animId
    local track = animator:LoadAnimation(anim)
    tool.Equipped:Connect(function()
        track:Play()
    end)
    tool.Unequipped:Connect(function()
        track:Stop()
    end)
end

-- Appliquer les animations FE à toutes les armes du joueur
local function ApplyFEToAllWeapons()
    for _, data in pairs(ARMES_FE) do
        local tool = p.Backpack:FindFirstChild(data.Nom) or (p.Character and p.Character:FindFirstChild(data.Nom))
        if tool and data.FE_Anim then
            ApplyFEAnimation(tool, data.FE_Anim)
        end
    end
end

-- Chargement du kit FE Gun (dans un dossier séparé pour ne pas polluer le workspace)
task.spawn(function()
    task.wait(2)
    ApplyFEToAllWeapons()
    print("✅ FE Gun Kit appliqué aux armes Vaztoodix")
end)

-- Surveillance : si une arme est ajoutée plus tard, appliquer l'animation
p.Backpack.ChildAdded:Connect(function(child)
    task.wait(0.5)
    for _, data in pairs(ARMES_FE) do
        if child.Name == data.Nom and data.FE_Anim then
            ApplyFEAnimation(child, data.FE_Anim)
        end
    end
end)

VAZ.ApplyFEToAllWeapons = ApplyFEToAllWeapons
print("✅ Partie 5/5 chargée - FE Gun Kit (animations avancées)")