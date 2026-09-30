-- PARTIE 2/4 - Armes Roblox existantes + Téléport + Épées + Marteau
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local p = Players.LocalPlayer
local rs = RunService
local uis = UserInputService
local debris = Debris

getgenv().VAZ = getgenv().VAZ or {}
local VAZ = getgenv().VAZ
VAZ.SWORDS_ACTIVE = true
VAZ.TELEPORT_ACTIVE = true
VAZ.swords = {}

local function ChangerNom()
    local noms = {"Alpha_99", "Beta_X", "Gamma_7", "Delta_Zero", "Echo_4"}
    p.DisplayName = noms[math.random(1, #noms)] .. tostring(math.random(100, 999))
end
VAZ.ChangerNom = ChangerNom

-- Arme Roblox existante (gear ID)
local function CreerArmeRoblox(nom, gearId, portee)
    local t = Instance.new("Tool")
    t.Name = nom
    t.CanBeDropped = false
    t.Parent = p.Backpack

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 0.3, 2)
    handle.Transparency = 1
    handle.Anchored = false
    handle.CanCollide = false
    handle.Parent = t

    -- Mesh du gear Roblox
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://" .. gearId
    mesh.Parent = handle

    t.Handle = handle
    t.RequiresHandle = true

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
                        ChangerNom()
                    end
                end
            end
        end
    end)
    return t
end
VAZ.CreerArmeRoblox = CreerArmeRoblox

-- Arme spéciale istadyxx26 (effets)
local function CreerArmeSpecial()
    local t = Instance.new("Tool")
    t.Name = "istadyxx26"
    t.CanBeDropped = false
    t.Parent = p.Backpack
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 0.3, 2)
    handle.BrickColor = BrickColor.new("Bright violet")
    handle.Material = Enum.Material.Neon
    handle.Anchored = false
    handle.CanCollide = false
    handle.Parent = t
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://51757162" -- Korblox: Berserker's Claymore
    mesh.Parent = handle
    t.Handle = handle
    t.RequiresHandle = true

    t.Activated:Connect(function()
        local m = p:GetMouse()
        if not m then return end
        local pos = m.Hit.Position
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= p and v.Character then
                local h = v.Character:FindFirstChild("Humanoid")
                if h and v.Character:FindFirstChild("HumanoidRootPart") then
                    if (v.Character.HumanoidRootPart.Position - pos).Magnitude <= 600 then
                        h.Health = 0
                        local hrp = v.Character.HumanoidRootPart
                        for i = 1, 8 do
                            local e = Instance.new("Explosion")
                            e.Position = hrp.Position + Vector3.new(math.random(-6,6), math.random(-2,4), math.random(-6,6))
                            e.BlastRadius = 7
                            e.BlastPressure = 0
                            e.Parent = workspace
                        end
                        ChangerNom()
                    end
                end
            end
        end
    end)
    return t
end
VAZ.CreerArmeSpecial = CreerArmeSpecial

-- Marteau Loucybel_Facher (gear Roblox connu)
local function CreerArmeMarteau(gearId, animId)
    local t = Instance.new("Tool")
    t.Name = "Loucybel_Facher"
    t.CanBeDropped = false
    t.Parent = p.Backpack
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 0.4, 0.8)
    handle.Transparency = 1
    handle.Anchored = false
    handle.CanCollide = false
    handle.Parent = t
    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://" .. gearId
    mesh.Parent = handle
    t.Handle = handle
    t.RequiresHandle = true

    t.Activated:Connect(function()
        local char = p.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local explosion = Instance.new("Explosion")
        explosion.Position = hrp.Position + Vector3.new(0, -2, 0)
        explosion.BlastRadius = 15
        explosion.BlastPressure = 100
        explosion.Parent = workspace
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= p and v.Character then
                local targetHrp = v.Character:FindFirstChild("HumanoidRootPart")
                if targetHrp and (targetHrp.Position - hrp.Position).Magnitude <= 15 then
                    local h = v.Character:FindFirstChild("Humanoid")
                    if h then h.Health = 0 end
                end
            end
        end
        ChangerNom()
    end)
    return t
end
VAZ.CreerArmeMarteau = CreerArmeMarteau

-- Créer toutes les armes (gear Roblox existants)
local function CreerToutesArmes()
    local list = {
        {Nom = "zizi Tranchant", GearId = "93136674", Portee = 500},      -- Uppercut Sword
        {Nom = "Micha Minivichi", GearId = "12187319", Portee = 600},     -- Sword of the Highlander
        {Nom = "Loucybel_Facher", GearId = "478707595", Portee = 0},      -- All-Seeing Golem's Hammer
        {Nom = "istadyxx26", Special = true}
    }
    for _, a in pairs(list) do
        if not p.Backpack:FindFirstChild(a.Nom) and not p.Character:FindFirstChild(a.Nom) then
            if a.Special then CreerArmeSpecial()
            elseif a.GearId == "478707595" then CreerArmeMarteau(a.GearId, "334753747")
            else CreerArmeRoblox(a.Nom, a.GearId, a.Portee) end
        end
    end
end
VAZ.CreerToutesArmes = CreerToutesArmes

-- Téléport
local function Teleporter()
    if not VAZ.TELEPORT_ACTIVE then return end
    local m = p:GetMouse()
    if not m then return end
    local c = p.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        c:SetPrimaryPartCFrame(CFrame.new(m.Hit.Position))
    end
end
VAZ.Teleporter = Teleporter

-- Épées orbitales (6 épées gear Roblox)
local function CreerSwords()
    if not VAZ.SWORDS_ACTIVE then return end
    for _, s in pairs(VAZ.swords) do s:Destroy() end
    VAZ.swords = {}
    local c = p.Character
    if not c then return end
    local r = c:FindFirstChild("HumanoidRootPart")
    if not r then return end
    local swordGearIds = {
        "93136674", "12187319", "87361662",
        "51757162", "295461517", "67998086"
    }
    for i = 1, 6 do
        local s = Instance.new("Part")
        s.Size = Vector3.new(0.2, 1, 0.2)
        s.Transparency = 1
        s.Anchored = false
        s.CanCollide = false
        s.Parent = workspace
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = "rbxassetid://" .. swordGearIds[i]
        mesh.Parent = s
        local w = Instance.new("Weld")
        w.Part0 = r
        w.Part1 = s
        w.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(i * 60), 0) * CFrame.new(3, 0, 0)
        w.Parent = s
        table.insert(VAZ.swords, s)
    end
end
VAZ.CreerSwords = CreerSwords

rs.Heartbeat:Connect(function()
    if VAZ.SWORDS_ACTIVE and p.Character then
        local r = p.Character:FindFirstChild("HumanoidRootPart")
        if r then
            local ang = 0
            for _, s in pairs(VAZ.swords) do
                local w = s:FindFirstChild("Weld")
                if w and w.Part0 == r then
                    ang = ang + 0.02
                    w.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(0, ang, 0) * CFrame.new(3, 0, 0)
                end
            end
        end
    end
end)

print("✅ Partie 2/4 chargée - Armes Roblox (Uppercut, Highlander, Golem Hammer, Claymore)")