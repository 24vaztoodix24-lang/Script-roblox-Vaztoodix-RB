-- PARTIE 2/4 - Armes 3D + Téléport + Épées orbitales + Marteau

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local p = Players.LocalPlayer
local rs = RunService
local uis = UserInputService
local debris = Debris

-- Variables globales (partagées avec les autres parties)
getgenv().VAZ = getgenv().VAZ or {}
local VAZ = getgenv().VAZ

VAZ.SWORDS_ACTIVE = true
VAZ.TELEPORT_ACTIVE = true
VAZ.swords = {}

-- Changer nom
local function ChangerNom()
    local noms = {"Alpha_99", "Beta_X", "Gamma_7", "Delta_Zero", "Echo_4"}
    p.DisplayName = noms[math.random(1, #noms)] .. tostring(math.random(100, 999))
end
VAZ.ChangerNom = ChangerNom

-- Création du modèle 3D avec mesh
local function CreerModeleArme(tool, couleur, forme, meshId)
    local old = tool:FindFirstChild("Handle")
    if old then old:Destroy() end

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1.2, 0.3, 2.2)
    handle.BrickColor = BrickColor.new(couleur or "Bright red")
    handle.Material = Enum.Material.SmoothPlastic
    handle.Anchored = false
    handle.CanCollide = false
    handle.Parent = tool

    if meshId then
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshId = "rbxassetid://" .. meshId
        mesh.Parent = handle
        mesh.Scale = Vector3.new(1, 1, 1)
    end

    local light = Instance.new("PointLight")
    light.Parent = handle
    light.Range = 8
    light.Brightness = 3
    light.Color = handle.BrickColor.Color

    if not meshId then
        if forme == "spiral" then
            for i = 1, 4 do
                local ring = Instance.new("Part")
                ring.Size = Vector3.new(0.8 + i * 0.15, 0.08, 0.8 + i * 0.15)
                ring.Shape = Enum.PartType.Cylinder
                ring.BrickColor = BrickColor.new(couleur or "Bright red")
                ring.Material = Enum.Material.Neon
                ring.Anchored = false
                ring.CanCollide = false
                ring.Parent = tool
                local w = Instance.new("Weld")
                w.Part0 = handle
                w.Part1 = ring
                w.C0 = CFrame.new(0, i * 0.3 - 0.45, 0) * CFrame.Angles(0, math.rad(i * 30), math.rad(i * 15))
                w.Parent = ring
            end
        elseif forme == "double" then
            for _, off in pairs({{-0.6, 0, 0}, {0.6, 0, 0}}) do
                local blade = Instance.new("Part")
                blade.Size = Vector3.new(0.15, 1.8, 0.15)
                blade.BrickColor = BrickColor.new("Bright blue")
                blade.Material = Enum.Material.Neon
                blade.Anchored = false
                blade.CanCollide = false
                blade.Parent = tool
                local w = Instance.new("Weld")
                w.Part0 = handle
                w.Part1 = blade
                w.C0 = CFrame.new(off[1], off[2] + 0.6, off[3]) * CFrame.Angles(0, 0, math.rad(20))
                w.Parent = blade
            end
        end
    end

    return handle
end

-- Arme normale avec mesh et animation
local function CreerArme(nom, portee, couleur, forme, meshId, animId)
    local t = Instance.new("Tool")
    t.Name = nom
    t.CanBeDropped = false
    t.Parent = p.Backpack

    local handle = CreerModeleArme(t, couleur, forme, meshId)
    t.Handle = handle
    t.RequiresHandle = true

    rs.RenderStepped:Connect(function()
        if t.Parent == p.Backpack or t.Parent == p.Character then
            if t.Handle then
                t.Handle.CFrame = t.Handle.CFrame * CFrame.Angles(0, 0.015, 0)
            end
        end
    end)

    local animator, animTrack
    t.Equipped:Connect(function()
        local char = p.Character
        if char then
            animator = char:FindFirstChildOfClass("Animator")
            if not animator then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then
                    animator = Instance.new("Animator")
                    animator.Parent = humanoid
                end
            end
            if animator and animId then
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://" .. animId
                animTrack = animator:LoadAnimation(anim)
            end
        end
    end)

    t.Activated:Connect(function()
        if animTrack then
            animTrack:Play()
            task.wait(0.8)
            animTrack:Stop()
        end
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

-- Arme spéciale istadyxx26 (sans mesh, effets)
local function CreerArmeSpecial()
    local t = Instance.new("Tool")
    t.Name = "istadyxx26"
    t.CanBeDropped = false
    t.Parent = p.Backpack

    local handle = CreerModeleArme(t, "Bright violet", "double", nil)
    t.Handle = handle
    t.RequiresHandle = true

    rs.RenderStepped:Connect(function()
        if t.Parent == p.Backpack or t.Parent == p.Character then
            if t.Handle then
                t.Handle.CFrame = t.Handle.CFrame * CFrame.Angles(0, 0.02, 0.02)
            end
        end
    end)

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
                        local hrp = v.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            for i = 1, 10 do
                                local e = Instance.new("Explosion")
                                e.Position = hrp.Position + Vector3.new(math.random(-8,8), math.random(-2,5), math.random(-8,8))
                                e.BlastRadius = 7
                                e.BlastPressure = 0
                                e.ExplosionType = Enum.ExplosionType.NoCraters
                                e.Parent = workspace
                            end
                            for i = 1, 20 do
                                local part = Instance.new("Part")
                                part.Size = Vector3.new(0.4, 0.4, 0.4)
                                part.BrickColor = BrickColor.random()
                                part.Material = Enum.Material.Neon
                                part.Anchored = true
                                part.CanCollide = false
                                part.Position = hrp.Position + Vector3.new(math.random(-5,5), math.random(0,5), math.random(-5,5))
                                part.Parent = workspace
                                debris:AddItem(part, 1.5)
                            end
                            pcall(function()
                                local cam = workspace.CurrentCamera
                                local orig = cam.CFrame
                                for i = 1, 10 do
                                    cam.CFrame = cam.CFrame * CFrame.Angles(math.rad(math.random(-4,4)), math.rad(math.random(-4,4)), 0)
                                    task.wait(0.015)
                                end
                                cam.CFrame = orig
                            end)
                        end
                        ChangerNom()
                    end
                end
            end
        end
    end)
    return t
end

-- Arme Marteau (Loucybel_Facher)
local function CreerArmeMarteau(meshId, animId)
    local t = Instance.new("Tool")
    t.Name = "Loucybel_Facher"
    t.CanBeDropped = false
    t.Parent = p.Backpack

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 0.4, 0.8)
    handle.BrickColor = BrickColor.new("Dark stone grey")
    handle.Material = Enum.Material.SmoothPlastic
    handle.Anchored = false
    handle.CanCollide = false
    handle.Parent = t

    if meshId then
        local mesh = Instance.new("SpecialMesh")
        mesh.MeshId = "rbxassetid://" .. meshId
        mesh.Parent = handle
    end

    local head = Instance.new("Part")
    head.Name = "Head"
    head.Size = Vector3.new(1.6, 1.2, 0.8)
    head.BrickColor = BrickColor.new("Bright orange")
    head.Material = Enum.Material.SmoothPlastic
    head.Anchored = false
    head.CanCollide = false
    head.Parent = t
    local weldHead = Instance.new("Weld")
    weldHead.Part0 = handle
    weldHead.Part1 = head
    weldHead.C0 = CFrame.new(0, 0.8, 0)
    weldHead.Parent = head

    local light = Instance.new("PointLight")
    light.Parent = head
    light.Range = 12
    light.Brightness = 5
    light.Color = Color3.new(1, 0.5, 0)

    t.Handle = handle
    t.RequiresHandle = true

    local animator, animTrack
    t.Equipped:Connect(function()
        local char = p.Character
        if char then
            animator = char:FindFirstChildOfClass("Animator")
            if not animator then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then
                    animator = Instance.new("Animator")
                    animator.Parent = humanoid
                end
            end
            if animator and animId then
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://" .. animId
                animTrack = animator:LoadAnimation(anim)
            end
        end
    end)

    t.Activated:Connect(function()
        if animTrack then
            animTrack:Play()
            task.wait(0.8)
            animTrack:Stop()
        end
        local char = p.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local explosion = Instance.new("Explosion")
        explosion.Position = hrp.Position + Vector3.new(0, -2, 0)
        explosion.BlastRadius = 15
        explosion.BlastPressure = 100
        explosion.ExplosionType = Enum.ExplosionType.NoCraters
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

-- Créer toutes les armes
local function CreerToutesArmes()
    local list = {
        {Nom = "zizi Tranchant", Portee = 500, Couleur = "Bright red", Forme = "spiral", MeshId = "12224215", AnimId = "114369154163347"},
        {Nom = "Micha Minivichi", Portee = 600, Couleur = "Bright blue", Forme = "double", MeshId = "115500717736588", AnimId = "91612928120390"},
        {Nom = "Loucybel_Facher", Portee = 0, Couleur = "Bright orange", Forme = "marteau", MeshId = "10468797", AnimId = "334753747", Special = "marteau"},
        {Nom = "istadyxx26", Portee = 600, Special = true}
    }
    for _, a in pairs(list) do
        if not p.Backpack:FindFirstChild(a.Nom) and not p.Character:FindFirstChild(a.Nom) then
            if a.Special == "marteau" then
                CreerArmeMarteau(a.MeshId, a.AnimId)
            elseif a.Special == true then
                CreerArmeSpecial()
            else
                CreerArme(a.Nom, a.Portee, a.Couleur, a.Forme, a.MeshId, a.AnimId)
            end
        end
    end
end
VAZ.CreerToutesArmes = CreerToutesArmes
VAZ.CreerArme = CreerArme
VAZ.CreerArmeSpecial = CreerArmeSpecial
VAZ.CreerArmeMarteau = CreerArmeMarteau

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

-- Épées orbitales
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
        s.Size = Vector3.new(0.2, 1, 0.2)
        s.BrickColor = BrickColor.new("Bright red")
        s.Material = Enum.Material.Neon
        s.Anchored = false
        s.CanCollide = false
        s.Parent = workspace
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

print("✅ Partie 2/4 chargée - Armes 3D + Téléport + Épées + Marteau")