-- PARTIE 3/4 - Fonctionnalités avancées

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local p = Players.LocalPlayer
local rs = RunService
local uis = UserInputService

getgenv().VAZ = getgenv().VAZ or {}
local VAZ = getgenv().VAZ

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

-- FLY
local function ToggleFly()
    VAZ.FLY_ACTIVE = not VAZ.FLY_ACTIVE
    local char = p.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not hrp or not humanoid then return end
    if VAZ.FLY_ACTIVE then
        humanoid.PlatformStand = true
        VAZ.flyPlatformStand = true
        if VAZ.flyBodyVelocity then VAZ.flyBodyVelocity:Destroy() end
        VAZ.flyBodyVelocity = Instance.new("BodyVelocity")
        VAZ.flyBodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
        VAZ.flyBodyVelocity.Parent = hrp
        if VAZ.flyBodyGyro then VAZ.flyBodyGyro:Destroy() end
        VAZ.flyBodyGyro = Instance.new("BodyGyro")
        VAZ.flyBodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
        VAZ.flyBodyGyro.Parent = hrp
        if VAZ.flyConnection then VAZ.flyConnection:Disconnect() end
        VAZ.flyConnection = rs.RenderStepped:Connect(function()
            if not VAZ.FLY_ACTIVE or not hrp or not hrp.Parent then return end
            local move = Vector3.new(0,0,0)
            if uis:IsKeyDown(Enum.KeyCode.W) then move = move + Vector3.new(0,0,-1) end
            if uis:IsKeyDown(Enum.KeyCode.S) then move = move + Vector3.new(0,0,1) end
            if uis:IsKeyDown(Enum.KeyCode.A) then move = move + Vector3.new(-1,0,0) end
            if uis:IsKeyDown(Enum.KeyCode.D) then move = move + Vector3.new(1,0,0) end
            if uis:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
            if uis:IsKeyDown(Enum.KeyCode.LeftShift) then move = move + Vector3.new(0,-1,0) end
            if move.Magnitude > 0 then
                VAZ.flyBodyVelocity.Velocity = move.Unit * 50
                VAZ.flyBodyGyro.CFrame = CFrame.new(Vector3.new(0,0,0), move.Unit)
            else
                VAZ.flyBodyVelocity.Velocity = Vector3.new(0,0,0)
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
        if hrp then hrp.Velocity = Vector3.new(0,0,0) end
    end
end
VAZ.ToggleFly = ToggleFly

-- SPEED
local function ToggleSpeed()
    VAZ.SPEED_ACTIVE = not VAZ.SPEED_ACTIVE
    local char = p.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = VAZ.SPEED_ACTIVE and 50 or 16
    end
end
VAZ.ToggleSpeed = ToggleSpeed

-- JUMP
local function ToggleJump()
    VAZ.JUMP_ACTIVE = not VAZ.JUMP_ACTIVE
    local char = p.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = VAZ.JUMP_ACTIVE and 100 or 50
    end
end
VAZ.ToggleJump = ToggleJump

-- INVISIBLE
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

-- GODMODE
local function ToggleGodmode()
    VAZ.GODMODE_ACTIVE = not VAZ.GODMODE_ACTIVE
    local char = p.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.MaxHealth = VAZ.GODMODE_ACTIVE and math.huge or 100
        char.Humanoid.Health = char.Humanoid.MaxHealth
    end
end
VAZ.ToggleGodmode = ToggleGodmode

-- AUTOCLICK
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

-- AIMBOT
local function AimbotLoop()
    if not VAZ.AIMBOT_ACTIVE or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then return end
    local target, dist = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= p and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local d = (v.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then target, dist = v, d end
        end
    end
    if target then
        local hrp = target.Character.HumanoidRootPart
        p.Character.HumanoidRootPart.CFrame = CFrame.new(p.Character.HumanoidRootPart.Position, hrp.Position)
    end
end
VAZ.AimbotLoop = AimbotLoop

-- WALLHACK
local function UpdateWallhack()
    for _, obj in pairs(VAZ.wallhackObjects) do obj:Destroy() end
    VAZ.wallhackObjects = {}
    if not VAZ.WALLHACK_ACTIVE then return end
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= p and v.Character then
            local hrp = v.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local box = Instance.new("BoxHandleAdornment")
                box.Size = Vector3.new(3, 5, 3)
                box.Color3 = Color3.new(1, 0, 0)
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Adornee = hrp
                box.Parent = hrp
                table.insert(VAZ.wallhackObjects, box)
                local line = Instance.new("LineHandleAdornment")
                line.Length = (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
                line.Color3 = Color3.new(0, 1, 0)
                line.AlwaysOnTop = true
                line.Thickness = 2
                line.Adornee = hrp
                line.Parent = hrp
                table.insert(VAZ.wallhackObjects, line)
            end
        end
    end
end
VAZ.UpdateWallhack = UpdateWallhack

-- VOL VÉHICULE
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

-- PARTICULES
local function ToggleParticles()
    if VAZ.PARTICLES_ACTIVE then
        for _, part in pairs(VAZ.particles) do part:Destroy() end
        VAZ.particles = {}
        return
    end
    for _, part in pairs(VAZ.particles) do part:Destroy() end
    VAZ.particles = {}
    if not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then return end
    for i = 1, 30 do
        local part = Instance.new("Part")
        part.Size = Vector3.new(0.2, 0.2, 0.2)
        part.BrickColor = BrickColor.random()
        part.Material = Enum.Material.Neon
        part.Anchored = false
        part.CanCollide = false
        part.Parent = workspace
        local weld = Instance.new("Weld")
        weld.Part0 = p.Character.HumanoidRootPart
        weld.Part1 = part
        weld.C0 = CFrame.new(0,0,0) * CFrame.Angles(math.rad(math.random(0,360)), math.rad(math.random(0,360)), 0) * CFrame.new(2, math.random(-1,1), 2)
        weld.Parent = part
        table.insert(VAZ.particles, part)
    end
end
VAZ.ToggleParticles = ToggleParticles

-- ANTI-AFK
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

-- CLONE
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
    local humanoid = VAZ.clone:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = 20
        humanoid.JumpPower = 50
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

-- NOCLIP
local function ToggleNoclip()
    VAZ.NOCLIP_ACTIVE = not VAZ.NOCLIP_ACTIVE
    if p.Character then
        for _, part in pairs(p.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not VAZ.NOCLIP_ACTIVE
            end
        end
    end
end
VAZ.ToggleNoclip = ToggleNoclip

print("✅ Partie 3/4 chargée - Fly, Speed, Jump, Aimbot, Wallhack, etc.")