-- PARTIE 8/8 - Sin Dragon simplifié (compatible Arceus X Neo)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local p = Players.LocalPlayer

getgenv().VAZ = getgenv().VAZ or {}
local VAZ = getgenv().VAZ

-- ============================================================
-- EFFET SIN DRAGON SIMPLIFIÉ
-- ============================================================
local dragonObjects = {}
local dragonActive = false
local dragonConnection = nil

-- Mesh IDs Roblox existants
local MESH_DRAGON = "rbxassetid://126048806"       -- Dragon générique
local MESH_HAND = "rbxassetid://103389119"          -- Main / gant générique
local MESH_ORB = "rbxassetid://13186744598"         -- Épée orbitale (réutilisée)

local function CreateDragonEffect()
    if dragonActive then return end
    local char = p.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not hrp or not head then return end

    dragonActive = true
    dragonObjects = {}

    -- ============================================================
    -- DRAGON AU-DESSUS DE LA TÊTE
    -- ============================================================
    local dragonPart = Instance.new("Part")
    dragonPart.Name = "SinDragonHead"
    dragonPart.Size = Vector3.new(6, 6, 10)
    dragonPart.BrickColor = BrickColor.new("Really black")
    dragonPart.Material = Enum.Material.Neon
    dragonPart.Anchored = true
    dragonPart.CanCollide = false
    dragonPart.Transparency = 0
    dragonPart.Parent = workspace

    local dragonMesh = Instance.new("SpecialMesh")
    dragonMesh.MeshType = Enum.MeshType.FileMesh
    dragonMesh.MeshId = MESH_DRAGON
    dragonMesh.Scale = Vector3.new(3, 3, 3)
    dragonMesh.Parent = dragonPart

    -- Yeux violets
    local eye1 = Instance.new("Part")
    eye1.Size = Vector3.new(0.5, 0.5, 0.5)
    eye1.BrickColor = BrickColor.new("Bright violet")
    eye1.Material = Enum.Material.Neon
    eye1.Anchored = true
    eye1.CanCollide = false
    eye1.Parent = workspace
    local eye2 = eye1:Clone()
    eye2.Parent = workspace

    -- Aura violette (particules)
    local aura = Instance.new("ParticleEmitter")
    aura.Texture = "rbxassetid://243660364"
    aura.Color = ColorSequence.new(Color3.fromRGB(150, 80, 255))
    aura.Size = NumberSequence.new(1.5)
    aura.Lifetime = NumberRange.new(1)
    aura.Rate = 30
    aura.Speed = NumberRange.new(2)
    aura.SpreadAngle = Vector2.new(180, 180)
    aura.Parent = dragonPart

    table.insert(dragonObjects, dragonPart)
    table.insert(dragonObjects, eye1)
    table.insert(dragonObjects, eye2)

    -- ============================================================
    -- DEUX MAINS DE CHAQUE CÔTÉ
    -- ============================================================
    local hands = {}
    for side = -1, 1, 2 do -- -1 (gauche) et 1 (droite)
        local hand = Instance.new("Part")
        hand.Name = "SinDragonHand"
        hand.Size = Vector3.new(4, 4, 6)
        hand.BrickColor = BrickColor.new("Really black")
        hand.Material = Enum.Material.Neon
        hand.Anchored = true
        hand.CanCollide = false
        hand.Parent = workspace

        local handMesh = Instance.new("SpecialMesh")
        handMesh.MeshType = Enum.MeshType.FileMesh
        handMesh.MeshId = MESH_HAND
        handMesh.Scale = Vector3.new(2, 2, 2)
        handMesh.Parent = hand

        -- Aura violette sur les mains
        local handAura = Instance.new("ParticleEmitter")
        handAura.Texture = "rbxassetid://243660364"
        handAura.Color = ColorSequence.new(Color3.fromRGB(150, 80, 255))
        handAura.Size = NumberSequence.new(1.2)
        handAura.Lifetime = NumberRange.new(0.8)
        handAura.Rate = 20
        handAura.Speed = NumberRange.new(1.5)
        handAura.SpreadAngle = Vector2.new(180, 180)
        handAura.Parent = hand

        table.insert(hands, { part = hand, side = side })
        table.insert(dragonObjects, hand)
    end

    -- ============================================================
    -- FLASH LUMINEUX AU CENTRE (sous le dragon)
    -- ============================================================
    local glow = Instance.new("Part")
    glow.Name = "SinDragonGlow"
    glow.Size = Vector3.new(3, 3, 3)
    glow.Shape = Enum.PartType.Ball
    glow.BrickColor = BrickColor.new("Bright violet")
    glow.Material = Enum.Material.Neon
    glow.Anchored = true
    glow.CanCollide = false
    glow.Transparency = 0.3
    glow.Parent = workspace
    table.insert(dragonObjects, glow)

    -- ============================================================
    -- BOUCLE DE MISE À JOUR (suit le joueur)
    -- ============================================================
    local angle = 0
    dragonConnection = RS.Heartbeat:Connect(function()
        if not dragonActive then return end
        local char = p.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not hrp or not head then return end

        angle = angle + 0.03

        -- Dragon au-dessus de la tête
        dragonPart.CFrame = head.CFrame * CFrame.new(0, 8, 0) * CFrame.Angles(0, angle, 0)
        eye1.CFrame = dragonPart.CFrame * CFrame.new(-1.5, 1, -4)
        eye2.CFrame = dragonPart.CFrame * CFrame.new(1.5, 1, -4)

        -- Mains de chaque côté (tournent légèrement)
        for _, h in ipairs(hands) do
            h.part.CFrame = hrp.CFrame * CFrame.new(h.side * 5, 2, -2) * CFrame.Angles(0, angle * h.side, 0)
        end

        -- Lueur au centre
        glow.CFrame = hrp.CFrame * CFrame.new(0, 0, 0)
    end)

    if VAZ.NotifyUI then VAZ.NotifyUI("Sin Dragon activé !") end
    if ui and ui.Notify then ui:Notify("Sin Dragon activé !") end
end

local function RemoveDragonEffect()
    dragonActive = false
    if dragonConnection then dragonConnection:Disconnect() dragonConnection = nil end
    for _, obj in ipairs(dragonObjects) do
        pcall(function() obj:Destroy() end)
    end
    dragonObjects = {}
    if ui and ui.Notify then ui:Notify("Sin Dragon désactivé") end
end

local function ToggleDragonEffect()
    if dragonActive then RemoveDragonEffect() else CreateDragonEffect() end
end

VAZ.ToggleDragonEffect = ToggleDragonEffect
VAZ.CreateDragonEffect = CreateDragonEffect
VAZ.RemoveDragonEffect = RemoveDragonEffect

-- ============================================================
-- TOUCHES G, C, F (donnent aussi l'arme Sin Dragon)
-- ============================================================
local function DonnerArmeSinDragon()
    local char = p.Character
    if not char then return end
    for _, v in pairs(p.Backpack:GetChildren()) do
        if v:IsA("Tool") and (v.Name:find("Sin") or v.Name:find("Dragon")) then
            v.Parent = char
        end
    end
end
VAZ.DonnerArmeSinDragon = DonnerArmeSinDragon

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.G or input.KeyCode == Enum.KeyCode.C or input.KeyCode == Enum.KeyCode.F then
        DonnerArmeSinDragon()
        if ui and ui.Notify then ui:Notify("Arme Sin Dragon équipée (" .. input.KeyCode.Name .. ")") end
    end
end)

-- ============================================================
-- ONGLET DANS L'INTERFACE
-- ============================================================
function VAZ.BuildSinDragonTab(ui)
    ui:AddTab("crosshair", "Sin Dragon")
    ui:AddModule("crosshair", "Sin Dragon", {
        name = "Activer Sin Dragon",
        desc = "Affiche le dragon + les mains autour de toi",
        toggle = true,
        callback = function() ToggleDragonEffect() end
    })
    ui:AddModule("crosshair", "Sin Dragon", {
        name = "Donner les armes Sin Dragon",
        desc = "Touche G, C ou F pour équiper",
        callback = function()
            DonnerArmeSinDragon()
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
        name = "Désactiver Sin Dragon",
        desc = "Retire le dragon et les mains",
        callback = function() RemoveDragonEffect() end
    })
end

print("✅ Partie 8/8 chargée - Sin Dragon simplifié (compatible Arceus X Neo)")