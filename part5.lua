-- PARTIE 5/5 - Armes avec textures du jeu Roblox

local Players = game:GetService("Players")
local p = Players.LocalPlayer

getgenv().VAZ = getgenv().VAZ or {}
local VAZ = getgenv().VAZ

-- ============================================================
-- TEXTURES D'ARMES DU JEU ROBLOX (gear IDs)
-- ============================================================
local ARMES_TEXTURES = {
    {
        Nom = "zizi Tranchant",
        GearId = "93136674",  -- Uppercut Sword
        Couleur = "Bright red",
        Portee = 500
    },
    {
        Nom = "Micha Minivichi",
        GearId = "12187319",  -- Sword of the Highlander
        Couleur = "Bright blue",
        Portee = 600
    },
    {
        Nom = "Loucybel_Facher",
        GearId = "478707595",  -- All-Seeing Golem's Hammer (marteau connu)
        Couleur = "Bright orange",
        Portee = 0
    },
    {
        Nom = "istadyxx26",
        GearId = "51757162",  -- Korblox: Berserker's Claymore
        Couleur = "Bright violet",
        Portee = 600
    }
}

-- ============================================================
-- CRÉATION DES ARMES AVEC TEXTURES DU JEU
-- ============================================================
local function CreerArmeAvecTexture(nom, gearId, portee, couleur)
    local t = Instance.new("Tool")
    t.Name = nom
    t.CanBeDropped = false
    t.Parent = p.Backpack

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1.2, 0.3, 2.2)
    handle.BrickColor = BrickColor.new(couleur or "Bright red")
    handle.Material = Enum.Material.SmoothPlastic
    handle.Anchored = false
    handle.CanCollide = false
    handle.Parent = t

    -- Appliquer la texture du gear Roblox
    if gearId then
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshId = "rbxassetid://" .. gearId
        mesh.Parent = handle
    end

    local light = Instance.new("PointLight")
    light.Parent = handle
    light.Range = 8
    light.Brightness = 3
    light.Color = handle.BrickColor.Color

    t.Handle = handle
    t.RequiresHandle = true

    -- Rotation
    game:GetService("RunService").RenderStepped:Connect(function()
        if t.Parent == p.Backpack or t.Parent == p.Character then
            if t.Handle then
                t.Handle.CFrame = t.Handle.CFrame * CFrame.Angles(0, 0.015, 0)
            end
        end
    end)

    -- Attaque
    t.Activated:Connect(function()
        local m = p:GetMouse()
        if not m then return end
        local pos = m.Hit.Position
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= p and v.Character then
                local h = v.Character:FindFirstChild("Humanoid")
                if h and v.Character:FindFirstChild("HumanoidRootPart") then
                    if (v.Character.HumanoidRootPart.Position - pos).Magnitude <= portee then
                        h.Health = 0
                        VAZ.ChangerNom()
                    end
                end
            end
        end
    end)
    return t
end

-- ============================================================
-- CRÉATION DES ÉPÉES ORBITALES (6 épées avec textures)
-- ============================================================
local function CreerSwords()
    if not VAZ.SWORDS_ACTIVE then return end
    for _, s in pairs(VAZ.swords) do s:Destroy() end
    VAZ.swords = {}
    local c = p.Character
    if not c then return end
    local r = c:FindFirstChild("HumanoidRootPart")
    if not r then return end

    -- 6 épées avec textures du jeu
    local swordGearIds = {
        "93136674",  -- Uppercut Sword
        "12187319",  -- Sword of the Highlander
        "87361662",  -- Ice Breaker
        "51757162",  -- Korblox: Berserker's Claymore
        "295461517", -- Viridian Katana
        "67998086"   -- Rising Sun Katana
    }

    for i = 1, 6 do
        local s = Instance.new("Part")
        s.Size = Vector3.new(0.2, 1, 0.2)
        s.BrickColor = BrickColor.new("Bright red")
        s.Material = Enum.Material.Neon
        s.Anchored = false
        s.CanCollide = false
        s.Parent = workspace

        -- Appliquer la texture de l'épée
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshId = "rbxassetid://" .. swordGearIds[i]
        mesh.Parent = s

        local w = Instance.new("Weld")
        w.Part0 = r
        w.Part1 = s
        w.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(i * 60), 0) * CFrame.new(3, 0, 0)
        w.Parent = s

        local tr = Instance.new("Trail")
        tr.Parent = s
        tr.Lifetime = 0.5
        tr.MinLength = 1
        tr.MaxLength = 5
        tr.Color = Color3.new(1, 0, 0)
        tr.Transparency = NumberSequence.new(0, 1)

        table.insert(VAZ.swords, s)
    end
end
VAZ.CreerSwords = CreerSwords

-- ============================================================
-- REMPLACER LES ARMES EXISTANTES
-- ============================================================
local function RemplacerArmes()
    for _, data in ipairs(ARMES_TEXTURES) do
        -- Supprimer l'ancienne arme si elle existe
        local old = p.Backpack:FindFirstChild(data.Nom)
        if old then old:Destroy() end
        old = p.Character and p.Character:FindFirstChild(data.Nom)
        if old then old:Destroy() end

        -- Créer la nouvelle avec texture
        CreerArmeAvecTexture(data.Nom, data.GearId, data.Portee, data.Couleur)
    end
end

-- Remplacer les armes au chargement
task.spawn(function()
    task.wait(3)
    RemplacerArmes()
    print("✅ Armes remplacées par les textures du jeu Roblox")
end)

-- Surveillance pour réappliquer
p.Backpack.ChildAdded:Connect(function(child)
    for _, data in ipairs(ARMES_TEXTURES) do
        if child.Name == data.Nom then
            task.wait(0.5)
            if child:FindFirstChild("Handle") then
                local mesh = child.Handle:FindFirstChildOfClass("SpecialMesh")
                if not mesh then
                    local m = Instance.new("SpecialMesh")
                    m.MeshId = "rbxassetid://" .. data.GearId
                    m.Parent = child.Handle
                end
            end
        end
    end
end)

VAZ.RemplacerArmes = RemplacerArmes
VAZ.CreerArmeAvecTexture = CreerArmeAvecTexture

print("✅ Partie 5/5 chargée - Armes avec textures du jeu Roblox + 6 épées orbitales")