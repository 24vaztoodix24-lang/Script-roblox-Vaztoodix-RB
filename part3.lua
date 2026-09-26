-- PARTIE 3/4 - Fonctionnalités avancées (corrigées)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local p = Players.LocalPlayer
local rs = RunService
local uis = UserInputService

getgenv().VAZ = getgenv().VAZ or {}
local VAZ = getgenv().VAZ

-- Variables
VAZ.AIMBOT_ACTIVE = false
VAZ.WALLHACK_ACTIVE = false
VAZ.STEAL_VEHICLE_ACTIVE = false
VAZ.PARTICLES_ACTIVE = false
VAZ.ANTI_AFK_ACTIVE = false
VAZ.CLONE_ACTIVE = false
VAZ.NOCLIP_ACTIVE = false
VAZ.FLY_ACTIVE = false
VAZ.SPEED_ACTIVE = false
VAZ.JUMP_ACTIVE = false
VAZ.INVISIBLE_ACTIVE = false
VAZ.GODMODE_ACTIVE = false
VAZ.AUTOCLICK_ACTIVE = false
VAZ.particles = {}
VAZ.clone = nil
VAZ.wallhackObjects = {}
VAZ.flyConnection = nil
VAZ.flyBodyVelocity = nil
VAZ.flyBodyGyro = nil
VAZ.flyPlatformStand = false
VAZ.autoClickConnection = nil
VAZ.antiAFK_conn = nil
VAZ.noclipConn = nil
VAZ.aimbotModule = nil

-- ============================================================
-- AIMBOT (Exunys Aimbot V3) + Interface Mobile
-- ============================================================
local function LoadAimbot()
    if VAZ.aimbotModule then return VAZ.aimbotModule end
    local ok, module = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Aimbot-V3/main/src/Aimbot.lua"))()
    end)
    if ok and module then
        VAZ.aimbotModule = module
        -- Configuration
        pcall(function()
            module.DeveloperSettings.TeamCheckOption = "TeamColor"
            module.Settings.Enabled = true
            module.Settings.TeamCheck = false
            module.Settings.AliveCheck = true
            module.Settings.WallCheck = true
            module.Settings.LockMode = 1
            module.Settings.LockPart = "Head"
            module.Settings.TriggerKey = Enum.UserInputType.MouseButton2
            module.Settings.Toggle = true
            module.FOVSettings.Enabled = true
            module.FOVSettings.Visible = true
            module.FOVSettings.Radius = 180
            module.ClosestPlayerTracer.Enabled = true
        end)
        return module
    end
    return nil
end

local function ToggleAimbot()
    VAZ.AIMBOT_ACTIVE = not VAZ.AIMBOT_ACTIVE
    local module = LoadAimbot()
    if module then
        if VAZ.AIMBOT_ACTIVE then
            pcall(function() module.Load() end)
        else
            pcall(function() module.Exit(module) end)
            VAZ.aimbotModule = nil
        end
    end
end
VAZ.ToggleAimbot = ToggleAimbot

-- Interface mobile pour Aimbot
local function CreateAimbotMobileUI()
    local sg = Instance.new("ScreenGui")
    sg.Name = "VaztoodixAimbotMobile"
    sg.ResetOnSpawn = false
    sg.Parent = p.PlayerGui

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(80, 40)
    btn.Position = UDim2.new(1, -90, 0.5, -20)
    btn.BackgroundColor3 = Color3.fromRGB(140, 80, 255)
    btn.Text = "AIM"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = sg
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(function()
        VAZ.AIMBOT_ACTIVE = not VAZ.AIMBOT_ACTIVE
        local module = LoadAimbot()
        if module then
            if VAZ.AIMBOT_ACTIVE then
                pcall(function() module.Load() end)
                btn.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
            else
                pcall(function() module.Exit(module) end)
                btn.BackgroundColor3 = Color3.fromRGB(140, 80, 255)
            end
        end
    end)
end
CreateAimbotMobileUI()

-- ============================================================
-- NOCLIP
-- ============================================================
local function ToggleNoclip()
    VAZ.NOCLIP_ACTIVE = not VAZ.NOCLIP_ACTIVE
    if VAZ.NOCLIP_ACTIVE then
        if VAZ.noclipConn then VAZ.noclipConn:Disconnect() end
        VAZ.noclipConn = rs.Stepped:Connect(function()
            if p.Character then
                for _, part in pairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if VAZ.noclipConn then VAZ.noclipConn:Disconnect() VAZ.noclipConn = nil end
        if p.Character then
            for _, part in pairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
end
VAZ.ToggleNoclip = ToggleNoclip

-- ============================================================
-- ESP / WALLHACK
-- ============================================================
local function ClearWallhack()
    for _, obj in pairs(VAZ.wallhackObjects) do
        pcall(function() obj:Destroy() end)
    end
    VAZ.wallhackObjects = {}
end

local function UpdateWallhack()
    ClearWallhack()
    if not VAZ.WALLHACK_ACTIVE then return end
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= p and v.Character then
            local hrp = v.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local hl = Instance.new("Highlight")
                hl.Adornee = v.Character
                hl.FillColor = Color3.fromRGB(255, 60, 60)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.4
                hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Parent = v.Character
                table.insert(VAZ.wallhackObjects, hl)

                local box = Instance.new("BoxHandleAdornment")
                box.Size = Vector3.new(3, 5, 3)
                box.Color3 = Color3.fromRGB(255, 60, 60)
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Adornee = hrp
                box.Parent = hrp
                table.insert(VAZ.wallhackObjects, box)

                local billboard = Instance.new("BillboardGui")
                billboard.Adornee = hrp
                billboard.Size = UDim2.fromOffset(200, 50)
                billboard.StudsOffset = Vector3.new(0, 3.5, 0)
                billboard.AlwaysOnTop = true
                billboard.Parent = hrp
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Size = UDim2.fromScale(1, 1)
                nameLabel.BackgroundTransparency = 1
                nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                nameLabel.TextStrokeTransparency = 0
                nameLabel.Font = Enum.Font.GothamBold
                nameLabel.TextSize = 14
                nameLabel.Text = v.Name .. " [" .. math.floor((hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude) .. "m]"
                nameLabel.Parent = billboard
                table.insert(VAZ.wallhackObjects, billboard)
            end
        end
    end
end
VAZ.UpdateWallhack = UpdateWallhack
VAZ.ClearWallhack = ClearWallhack

-- ============================================================
-- FLY (Version Infinity Yield)
-- ============================================================
local function ToggleFly()
    VAZ.FLY_ACTIVE = not VAZ.FLY_ACTIVE
    local char = p.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end

    if VAZ.FLY_ACTIVE then
        -- Configuration Infinity Yield
        local FLY_SPEED = 50
        local FLY_KEY = Enum.KeyCode.F
        
        humanoid.PlatformStand = true
        VAZ.flyPlatformStand = true

        if VAZ.flyBodyVelocity then VAZ.flyBodyVelocity:Destroy() end
        VAZ.flyBodyVelocity = Instance.new("BodyVelocity")
        VAZ.flyBodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        VAZ.flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        VAZ.flyBodyVelocity.Parent = hrp

        if VAZ.flyBodyGyro then VAZ.flyBodyGyro:Destroy() end
        VAZ.flyBodyGyro = Instance.new("BodyGyro")
        VAZ.flyBodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
        VAZ.flyBodyGyro.CFrame = hrp.CFrame
        VAZ.flyBodyGyro.Parent = hrp

        if VAZ.flyConnection then VAZ.flyConnection:Disconnect() end
        VAZ.flyConnection = rs.RenderStepped:Connect(function()
            if not VAZ.FLY_ACTIVE or not hrp or not hrp.Parent then return end
            local move = Vector3.new(0, 0, 0)
            if uis:IsKeyDown(Enum.KeyCode.W) then move = move + Vector3.new(0, 0, -1) end
            if uis:IsKeyDown(Enum.KeyCode.S) then move = move + Vector3.new(0, 0, 1) end
            if uis:IsKeyDown(Enum.KeyCode.A) then move = move + Vector3.new(-1, 0, 0) end
            if uis:IsKeyDown(Enum.KeyCode.D) then move = move + Vector3.new(1, 0, 0) end
            if uis:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
            if uis:IsKeyDown(Enum.KeyCode.LeftShift) then move = move + Vector3.new(0, -1, 0) end

            if move.Magnitude > 0 then
                VAZ.flyBodyVelocity.Velocity = move.Unit * FLY_SPEED
                VAZ.flyBodyGyro.CFrame = CFrame.new(Vector3.new(0, 0, 0), move.Unit)
            else
                VAZ.flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        end)
    else
        if VAZ.flyConnection then VAZ.flyConnection:Disconnect() VAZ.flyConnection = nil end
        if VAZ.flyBodyVelocity then VAZ.flyBodyVelocity:Destroy() VAZ.flyBodyVelocity = nil end
        if VAZ.flyBodyGyro then VAZ.flyBodyGyro:Destroy() VAZ.flyBodyGyro = nil end
        if humanoid and VAZ.flyPlatformStand then
            humanoid.PlatformStand = false
            VAZ.flyPlatformStand = false
        end
        if hrp then hrp.Velocity = Vector3.new(0, 0, 0) end
    end
end
VAZ.ToggleFly = ToggleFly

-- ============================================================
-- SPEED / JUMP / INVISIBLE / GODMODE / AUTOCLICK / ANTIAFK / CLONE
-- ============================================================
local function ToggleSpeed()
    VAZ.SPEED_ACTIVE = not VAZ.SPEED_ACTIVE
    local char = p.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = VAZ.SPEED_ACTIVE and 50 or 16
    end
end
VAZ.ToggleSpeed = ToggleSpeed

local function ToggleJump()
    VAZ.JUMP_ACTIVE = not VAZ.JUMP_ACTIVE
    local char = p.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = VAZ.JUMP_ACTIVE and 100 or 50
    end
end
VAZ.ToggleJump = ToggleJump

local function ToggleInvisible()
    VAZ.INVISIBLE_ACTIVE = not VAZ.INVISIBLE_ACTIVE
    local char = p.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = VAZ.INVISIBLE_ACTIVE and 1 or 0
            end
        end
    end
end
VAZ.ToggleInvisible = ToggleInvisible

-- GODMODE CORRIGÉ (Infinity Yield style)
local function ToggleGodmode()
    VAZ.GODMODE_ACTIVE = not VAZ.GODMODE_ACTIVE
    local char = p.Character
    if char and char:FindFirstChild("Humanoid") then
        local humanoid = char.Humanoid
        if VAZ.GODMODE_ACTIVE then
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
            -- Ajouter aussi un BodyForce pour résister aux explosions
            local bf = Instance.new("BodyForce")
            bf.Force = Vector3.new(0, 0, 0)
            bf.Parent = char:FindFirstChild("HumanoidRootPart")
            VAZ.godmodeForce = bf
        else
            humanoid.MaxHealth = 100
            humanoid.Health = 100
            if VAZ.godmodeForce then VAZ.godmodeForce:Destroy() VAZ.godmodeForce = nil end
        end
    end
end
VAZ.ToggleGodmode = ToggleGodmode

local function ToggleAutoClick()
    VAZ.AUTOCLICK_ACTIVE = not VAZ.AUTOCLICK_ACTIVE
    if VAZ.AUTOCLICK_ACTIVE then
        VAZ.autoClickConnection = rs.RenderStepped:Connect(function()
            if VAZ.AUTOCLICK_ACTIVE then mouse1click() end
        end)
    else
        if VAZ.autoClickConnection then VAZ.autoClickConnection:Disconnect() VAZ.autoClickConnection = nil end
    end
end
VAZ.ToggleAutoClick = ToggleAutoClick

local function ToggleAntiAFK()
    if VAZ.ANTI_AFK_ACTIVE then
        if VAZ.antiAFK_conn then VAZ.antiAFK_conn:Disconnect() end
        return
    end
    VAZ.antiAFK_conn = rs.Stepped:Connect(function()
        if p.Character and p.Character:FindFirstChild("Humanoid") then
            local h = p.Character.Humanoid
            h.MoveTo(h.RootPart.Position + Vector3.new(0, 0, 0.1))
        end
    end)
end
VAZ.ToggleAntiAFK = ToggleAntiAFK

-- CLONE CORRIGÉ (visible + attaque)
local function ToggleClone()
    if VAZ.CLONE_ACTIVE then
        if VAZ.clone then VAZ.clone:Destroy() end
        VAZ.clone = nil
        return
    end
    if not p.Character then return end
    VAZ.clone = p.Character:Clone()
    VAZ.clone.Parent = workspace
    VAZ.clone.Name = "Clone"
    
    -- Rendre le clone visible et fonctionnel
    local humanoid = VAZ.clone:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 20
        humanoid.JumpPower = 50
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    end
    
    -- S'assurer que toutes les parties sont visibles
    for _, part in pairs(VAZ.clone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Transparency = 0
            part.CanCollide = true
        end
    end

    task.spawn(function()
        while VAZ.clone and VAZ.clone.Parent do
            local target = nil
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= p and v.Character then
                    target = v.Character
                    break
                end
            end
            if target and target:FindFirstChild("HumanoidRootPart") then
                VAZ.clone.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                if (VAZ.clone.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude < 5 then
                    local h = target:FindFirstChild("Humanoid")
                    if h then h.Health = 0 end
                end
            end
            task.wait(0.5)
        end
    end)
end
VAZ.ToggleClone = ToggleClone

-- PARTICULES AMÉLIORÉES (plusieurs accessoires)
local function ToggleParticles()
    if VAZ.PARTICLES_ACTIVE then
        for _, part in pairs(VAZ.particles) do part:Destroy() end
        VAZ.particles = {}
        return
    end
    for _, part in pairs(VAZ.particles) do part:Destroy() end
    VAZ.particles = {}
    if not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then return end

    -- Ajouter plusieurs types de particules
    local particlesList = {
        {Size = 0.5, Color = Color3.fromRGB(255, 100, 100), Offset = Vector3.new(2, 0, 0)},
        {Size = 0.4, Color = Color3.fromRGB(100, 255, 100), Offset = Vector3.new(-2, 0, 0)},
        {Size = 0.3, Color = Color3.fromRGB(100, 100, 255), Offset = Vector3.new(0, 0, 2)},
        {Size = 0.6, Color = Color3.fromRGB(255, 255, 100), Offset = Vector3.new(0, 0, -2)},
        {Size = 0.35, Color = Color3.fromRGB(255, 100, 255), Offset = Vector3.new(0, 2, 0)},
        {Size = 0.45, Color = Color3.fromRGB(100, 255, 255), Offset = Vector3.new(0, -1, 0)}
    }

    for i, data in ipairs(particlesList) do
        for j = 1, 5 do
            local part = Instance.new("Part")
            part.Size = Vector3.new(data.Size, data.Size, data.Size)
            part.BrickColor = BrickColor.new(data.Color)
            part.Material = Enum.Material.Neon
            part.Anchored = false
            part.CanCollide = false
            part.Parent = workspace
            local weld = Instance.new("Weld")
            weld.Part0 = p.Character.HumanoidRootPart
            weld.Part1 = part
            weld.C0 = CFrame.new(data.Offset + Vector3.new(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1))) * CFrame.Angles(math.rad(math.random(0, 360)), math.rad(math.random(0, 360)), 0)
            weld.Parent = part
            table.insert(VAZ.particles, part)
        end
    end
end
VAZ.ToggleParticles = ToggleParticles

local function StealVehicle()
    if not VAZ.STEAL_VEHICLE_ACTIVE then return end
    local vehicle = nil
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("VehicleSeat") and v.Occupant == nil then
            vehicle = v.Parent
            break
        end
    end
    if vehicle and vehicle:FindFirstChildOfClass("BasePart") then
        p.Character.HumanoidRootPart.CFrame = vehicle.PrimaryPart.CFrame
        p.Character.HumanoidRootPart.Parent = vehicle
    end
end
VAZ.StealVehicle = StealVehicle

print("✅ Partie 3/4 chargée - Fly (Infinity Yield) + Godmode + Clone + Particules corrigés + Aimbot Mobile UI")