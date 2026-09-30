-- PARTIE 2/4 - Armes avec mesh Gigas + Épées orbitales + Téléport
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

-- IDs des meshes
local MESH_ARME = "432834997"       -- Mesh de l'épée principale
local MESH_ORBITAL = "13186744598"  -- Mesh des épées orbitales

local function ChangerNom()
    local noms = {"Alpha_99", "Beta_X", "Gamma_7", "Delta_Zero", "Echo_4"}
    p.DisplayName = noms[math.random(1, #noms)] .. tostring(math.random(100, 999))
end
VAZ.ChangerNom = ChangerNom

-- ============================================================
-- CRÉATION D'ARME AVEC MESH
-- ============================================================
local function CreerArmeAvecMesh(nom, meshId, portee)
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

    local mesh = Instance.new("SpecialMesh")
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://" .. meshId
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
VAZ.CreerArmeAvecMesh = CreerArmeAvecMesh

-- ============================================================
-- CRÉATION DES 4 ARMES (toutes avec le même mesh Gigas)
-- ============================================================
local function CreerToutesArmes()
    local armes = {
        {Nom = "zizi Tranchant", Mesh = MESH_ARME, Portee = 500},
        {Nom = "Micha Minivichi", Mesh = MESH_ARME, Portee = 600},
        {Nom = "Loucybel_Facher", Mesh = MESH_ARME, Portee = 550},
        {Nom = "istadyxx26", Mesh = MESH_ARME, Portee = 600}
    }
    for _, a in pairs(armes) do
        if not p.Backpack:FindFirstChild(a.Nom) and not p.Character:FindFirstChild(a.Nom) then
            CreerArmeAvecMesh(a.Nom, a.Mesh, a.Portee)
        end
    end
end
VAZ.CreerToutesArmes = CreerToutesArmes

-- ============================================================
-- TÉLÉPORT
-- ============================================================
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

-- ============================================================
-- ÉPÉES ORBITALES (avec mesh 13186744598)
-- ============================================================
local function CreerSwords()
    if not VAZ.SWORDS_ACTIVE then return end
    for _, s in pairs(VAZ.swords) do s:Destroy() end
    VAZ.swords = {}
    local c = p.Character
    if not c then return end
    local r = c:FindFirstChild("HumanoidRootPart")
    if not r then return end

    for i = 1, 6 do
        local s = Instance.new("Part")
        s.Size = Vector3.new(0.3, 3, 0.3)
        s.Transparency = 0
        s.Anchored = false
        s.CanCollide = false
        s.Parent = workspace

        local mesh = Instance.new("SpecialMesh")
        mesh.MeshType = Enum.MeshType.FileMesh
        mesh.MeshId = "rbxassetid://" .. MESH_ORBITAL
        mesh.Scale = Vector3.new(1, 1, 1)
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

-- Rotation des épées
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

print("✅ Partie 2/4 chargée - Armes Gigas (mesh 432834997) + Épées orbitales (mesh 13186744598)")