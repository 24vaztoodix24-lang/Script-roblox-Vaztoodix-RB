-- PARTIE 3/4 - Fly (vitesse réglable) + Noclip + ESP + Aimbot + Godmode + Clone

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
VAZ.PARTICLES_ACTIVE = false
VAZ.ANTI_AFK_ACTIVE = false
VAZ.CLONE_ACTIVE = false
VAZ.NOCLIP_ACTIVE = false
VAZ.FLY_ACTIVE = false
VAZ.WALK_SPEED = 16
VAZ.FLY_SPEED = 50

-- ============================================================
-- AIMBOT (Exunys Aimbot V3)
-- ============================================================
local function LoadAimbot()
    if VAZ.aimbotModule then return VAZ.aimbotModule end
    local ok, module = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Aimbot-V3/main/src/Aimbot.lua"))()
    end)
    if ok and module then
        VAZ.aimbotModule = module
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
    for _, obj in pairs(VAZ.wallhackObjects or {}) do
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
-- FLY (version Fly.lua - vitesse réglable via VAZ.FLY_SPEED)
-- ============================================================
local flyConnections = {}
local flySpeeds = 1
local flyUpConn = nil
local flyDownConn = nil
local flyActive = false
local flyTpWalking = false

local function ClearFlyConnections()
    for _, c in ipairs(flyConnections) do
        pcall(function() c:Disconnect() end)
    end
    flyConnections = {}
    if flyUpConn then flyUpConn:Disconnect() flyUpConn = nil end
    if flyDownConn then flyDownConn:Disconnect() flyDownConn = nil end
end

local function StartFlyThread(speeds)
    for i = 1, speeds do
        local thr = task.spawn(function()
            local hb = game:GetService("RunService").Heartbeat
            flyTpWalking = true
            local chr = p.Character
            local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
            while flyTpWalking and hb:Wait() and chr and hum and hum.Parent do
                if hum.MoveDirection.Magnitude > 0 then
                    chr:TranslateBy(hum.MoveDirection)
                end
            end
        end)
        table.insert(flyConnections, thr)
    end
end

local function ToggleFly()
    flyActive = not flyActive
    local speaker = game:GetService("Players").LocalPlayer
    local chr = speaker.Character
    if not chr then return end
    local hum = chr:FindFirstChildWhichIsA("Humanoid")
    if not hum then return end

    if not flyActive then
        flyTpWalking = false
        flyUpConn = nil
        flyDownConn = nil
        ClearFlyConnections()
        for _, st in ipairs({
            Enum.HumanoidStateType.Climbing, Enum.HumanoidStateType.FallingDown,
            Enum.HumanoidStateType.Flying, Enum.HumanoidStateType.Freefall,
            Enum.HumanoidStateType.GettingUp, Enum.HumanoidStateType.Jumping,
            Enum.HumanoidStateType.Landed, Enum.HumanoidStateType.Physics,
            Enum.HumanoidStateType.PlatformStanding, Enum.HumanoidStateType.Ragdoll,
            Enum.HumanoidStateType.Running, Enum.HumanoidStateType.RunningNoPhysics,
            Enum.HumanoidStateType.Seated, Enum.HumanoidStateType.StrafingNoPhysics,
            Enum.HumanoidStateType.Swimming
        }) do
            pcall(function() hum:SetStateEnabled(st, true) end)
        end
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics) end)
        pcall(function() chr.Animate.Disabled = false end)
        pcall(function() hum.PlatformStand = false end)
        return
    end

    StartFlyThread(flySpeeds)
    pcall(function() chr.Animate.Disabled = true end)
    local Char = speaker.Character
    local Hum = Char:FindFirstChildOfClass("Humanoid") or Char:FindFirstChildOfClass("AnimationController")
    for _, v in next, Hum:GetPlayingAnimationTracks() do
        v:AdjustSpeed(0)
    end

    for _, st in ipairs({
        Enum.HumanoidStateType.Climbing, Enum.HumanoidStateType.FallingDown,
        Enum.HumanoidStateType.Flying, Enum.HumanoidStateType.Freefall,
        Enum.HumanoidStateType.GettingUp, Enum.HumanoidStateType.Jumping,
        Enum.HumanoidStateType.Landed, Enum.HumanoidStateType.Physics,
        Enum.HumanoidStateType.PlatformStanding, Enum.HumanoidStateType.Ragdoll,
        Enum.HumanoidStateType.Running, Enum.HumanoidStateType.RunningNoPhysics,
        Enum.HumanoidStateType.Seated, Enum.HumanoidStateType.StrafingNoPhysics,
        Enum.HumanoidStateType.Swimming
    }) do
        pcall(function() hum:SetStateEnabled(st, false) end)
    end
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Swimming) end)

    if hum.RigType == Enum.HumanoidRigType.R6 then
        local plr = speaker
        local torso = plr.Character:FindFirstChild("Torso")
        if not torso then return end
        local ctrl = {f = 0, b = 0, l = 0, r = 0}
        local lastctrl = {f = 0, b = 0, l = 0, r = 0}
        local speed = 0
        local bg = Instance.new("BodyGyro", torso)
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.cframe = torso.CFrame
        local bv = Instance.new("BodyVelocity", torso)
        bv.velocity = Vector3.new(0, 0.1, 0)
        bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        if flyActive then
            plr.Character.Humanoid.PlatformStand = true
        end
        local conn = game:GetService("RunService").RenderStepped:Connect(function()
            if not flyActive then
                bg:Destroy() bv:Destroy()
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    plr.Character.Humanoid.PlatformStand = false
                    plr.Character.Animate.Disabled = false
                end
                return
            end
            local maxspeed = VAZ.FLY_SPEED or 50
            if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                speed = speed + .5 + (speed / maxspeed)
                if speed > maxspeed then speed = maxspeed end
            elseif speed ~= 0 then
                speed = speed - 1
                if speed < 0 then speed = 0 end
            end
            if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                bv.velocity = ((workspace.CurrentCamera.CFrame.lookVector * (ctrl.f + ctrl.b)) + ((workspace.CurrentCamera.CFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * .2, 0).p) - workspace.CurrentCamera.CFrame.p)) * speed
                lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
            elseif speed ~= 0 then
                bv.velocity = ((workspace.CurrentCamera.CFrame.lookVector * (lastctrl.f + lastctrl.b)) + ((workspace.CurrentCamera.CFrame * CFrame.new(lastctrl.l + lastctrl.r, (lastctrl.f + lastctrl.b) * .2, 0).p) - workspace.CurrentCamera.CFrame.p)) * speed
            else
                bv.velocity = Vector3.new(0, 0, 0)
            end
            bg.cframe = workspace.CurrentCamera.CFrame * CFrame.Angles(-math.rad((ctrl.f + ctrl.b) * 50 * speed / maxspeed), 0, 0)
        end)
        table.insert(flyConnections, conn)

        table.insert(flyConnections, uis.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.W then ctrl.f = 1 end
            if input.KeyCode == Enum.KeyCode.S then ctrl.b = -1 end
            if input.KeyCode == Enum.KeyCode.A then ctrl.l = -1 end
            if input.KeyCode == Enum.KeyCode.D then ctrl.r = 1 end
        end))
        table.insert(flyConnections, uis.InputEnded:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.W then ctrl.f = 0 end
            if input.KeyCode == Enum.KeyCode.S then ctrl.b = 0 end
            if input.KeyCode == Enum.KeyCode.A then ctrl.l = 0 end
            if input.KeyCode == Enum.KeyCode.D then ctrl.r = 0 end
        end))
        table.insert(flyConnections, uis.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.Space then
                flyUpConn = game:GetService("RunService").Heartbeat:Connect(function()
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        p.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 1, 0)
                    end
                end)
            end
            if input.KeyCode == Enum.KeyCode.LeftShift then
                flyDownConn = game:GetService("RunService").Heartbeat:Connect(function()
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        p.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, -1, 0)
                    end
                end)
            end
        end))
        table.insert(flyConnections, uis.InputEnded:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.Space and flyUpConn then
                flyUpConn:Disconnect() flyUpConn = nil
            end
            if input.KeyCode == Enum.KeyCode.LeftShift and flyDownConn then
                flyDownConn:Disconnect() flyDownConn = nil
            end
        end))
    else
        local plr = speaker
        local UpperTorso = plr.Character:FindFirstChild("UpperTorso")
        if not UpperTorso then return end
        local ctrl = {f = 0, b = 0, l = 0, r = 0}
        local lastctrl = {f = 0, b = 0, l = 0, r = 0}
        local speed = 0
        local bg = Instance.new("BodyGyro", UpperTorso)
        bg.P = 9e4
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.cframe = UpperTorso.CFrame
        local bv = Instance.new("BodyVelocity", UpperTorso)
        bv.velocity = Vector3.new(0, 0.1, 0)
        bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        if flyActive then
            plr.Character.Humanoid.PlatformStand = true
        end
        local conn = game:GetService("RunService").RenderStepped:Connect(function()
            if not flyActive then
                bg:Destroy() bv:Destroy()
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    plr.Character.Humanoid.PlatformStand = false
                    plr.Character.Animate.Disabled = false
                end
                return
            end
            local maxspeed = VAZ.FLY_SPEED or 50
            if ctrl.l + ctrl.r ~= 0 or ctrl.f + ctrl.b ~= 0 then
                speed = speed + .5 + (speed / maxspeed)
                if speed > maxspeed then speed = maxspeed end
            elseif speed ~= 0 then
                speed = speed - 1
                if speed < 0 then speed = 0 end
            end
            if (ctrl.l + ctrl.r) ~= 0 or (ctrl.f + ctrl.b) ~= 0 then
                bv.velocity = ((workspace.CurrentCamera.CFrame.lookVector * (ctrl.f + ctrl.b)) + ((workspace.CurrentCamera.CFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * .2, 0).p) - workspace.CurrentCamera.CFrame.p)) * speed
                lastctrl = {f = ctrl.f, b = ctrl.b, l = ctrl.l, r = ctrl.r}
            elseif speed ~= 0 then
                bv.velocity = ((workspace.CurrentCamera.CFrame.lookVector * (lastctrl.f + lastctrl.b)) + ((workspace.CurrentCamera.CFrame * CFrame.new(lastctrl.l + lastctrl.r, (lastctrl.f + lastctrl.b) * .2, 0).p) - workspace.CurrentCamera.CFrame.p)) * speed
            else
                bv.velocity = Vector3.new(0, 0, 0)
            end
            bg.cframe = workspace.CurrentCamera.CFrame * CFrame.Angles(-math.rad((ctrl.f + ctrl.b) * 50 * speed / maxspeed), 0, 0)
        end)
        table.insert(flyConnections, conn)

        table.insert(flyConnections, uis.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.W then ctrl.f = 1 end
            if input.KeyCode == Enum.KeyCode.S then ctrl.b = -1 end
            if input.KeyCode == Enum.KeyCode.A then ctrl.l = -1 end
            if input.KeyCode == Enum.KeyCode.D then ctrl.r = 1 end
        end))
        table.insert(flyConnections, uis.InputEnded:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.W then ctrl.f = 0 end
            if input.KeyCode == Enum.KeyCode.S then ctrl.b = 0 end
            if input.KeyCode == Enum.KeyCode.A then ctrl.l = 0 end
            if input.KeyCode == Enum.KeyCode.D then ctrl.r = 0 end
        end))
        table.insert(flyConnections, uis.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.Space then
                flyUpConn = game:GetService("RunService").Heartbeat:Connect(function()
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        p.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 1, 0)
                    end
                end)
            end
            if input.KeyCode == Enum.KeyCode.LeftShift then
                flyDownConn = game:GetService("RunService").Heartbeat:Connect(function()
                    if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        p.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, -1, 0)
                    end
                end)
            end
        end))
        table.insert(flyConnections, uis.InputEnded:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.Space and flyUpConn then
                flyUpConn:Disconnect() flyUpConn = nil
            end
            if input.KeyCode == Enum.KeyCode.LeftShift and flyDownConn then
                flyDownConn:Disconnect() flyDownConn = nil
            end
        end))
    end
end
VAZ.ToggleFly = ToggleFly

-- ============================================================
-- SPEED / JUMP / INVISIBLE / GODMODE / AUTOCLICK / ANTIAFK / CLONE / PARTICULES
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

local function ToggleGodmode()
    VAZ.GODMODE_ACTIVE = not VAZ.GODMODE_ACTIVE
    local char = p.Character
    if char and char:FindFirstChild("Humanoid") then
        local humanoid = char.Humanoid
        if VAZ.GODMODE_ACTIVE then
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
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
        humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    end
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

local function ToggleParticles()
    if VAZ.PARTICLES_ACTIVE then
        for _, part in pairs(VAZ.particles or {}) do part:Destroy() end
        VAZ.particles = {}
        return
    end
    VAZ.particles = {}
    if not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then return end
    local particlesList = {
        {Size = 0.5, Color = Color3.fromRGB(255, 100, 100), Offset = Vector3.new(2, 0, 0)},
        {Size = 0.4, Color = Color3.fromRGB(100, 255, 100), Offset = Vector3.new(-2, 0, 0)},
        {Size = 0.3, Color = Color3.fromRGB(100, 100, 255), Offset = Vector3.new(0, 0, 2)},
        {Size = 0.6, Color = Color3.fromRGB(255, 255, 100), Offset = Vector3.new(0, 0, -2)},
        {Size = 0.35, Color = Color3.fromRGB(255, 100, 255), Offset = Vector3.new(0, 2, 0)},
        {Size = 0.45, Color = Color3.fromRGB(100, 255, 255), Offset = Vector3.new(0, -1, 0)}
    }
    for _, data in ipairs(particlesList) do
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

print("✅ Partie 3/4 chargée - Fly (vitesse réglable) + Noclip + ESP + Aimbot + Godmode + Clone")