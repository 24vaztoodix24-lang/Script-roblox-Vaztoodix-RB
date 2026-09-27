-- PARTIE 7/7 - Effets c00lgui (20 fonctionnalités)

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local p = Players.LocalPlayer

getgenv().VAZ = getgenv().VAZ or {}
local VAZ = getgenv().VAZ

-- 1. Décal
local function ApplyDecal()
    local DECAL_ID = "rbxassetid://18381835089"
    local function exPro(root)
        for _, v in pairs(root:GetChildren()) do
            if v:IsA("Decal") and v.Texture ~= DECAL_ID then v:Destroy()
            elseif v:IsA("BasePart") then
                v.Material = Enum.Material.Plastic v.Transparency = 0
                for _, face in pairs({"Front","Back","Left","Right","Top","Bottom"}) do
                    local d = Instance.new("Decal", v) d.Texture = DECAL_ID d.Face = face
                end
            end
            exPro(v)
        end
    end
    exPro(Workspace) VAZ.Notify("Décal appliqué")
end

-- 2. Skybox c00lkidd (18381835089)
local function SkyboxC00lkidd()
    local s = Instance.new("Sky") s.Parent = Lighting
    for _, f in pairs({"Bk","Dn","Ft","Lf","Rt","Up"}) do s["Skybox"..f] = "rbxassetid://18381835089" end
    Lighting.TimeOfDay = "12:00:00" VAZ.Notify("Skybox c00lkidd")
end

-- 3. Skybox c00lkidd sky (158118263)
local function SkyboxC00lkiddSky()
    local s = Instance.new("Sky") s.Parent = Lighting
    for _, f in pairs({"Bk","Dn","Ft","Lf","Rt","Up"}) do s["Skybox"..f] = "rbxassetid://158118263" end
    Lighting.TimeOfDay = "12:00:00" VAZ.Notify("Skybox c00lkidd sky")
end

-- 4. Décal c00lkidd (158118263)
local function DecalC00lkidd()
    local DECAL_ID = "rbxassetid://158118263"
    local function exPro(root)
        for _, v in pairs(root:GetChildren()) do
            if v:IsA("Decal") and v.Texture ~= DECAL_ID then v:Destroy()
            elseif v:IsA("BasePart") then
                v.Material = Enum.Material.Plastic v.Transparency = 0
                for _, face in pairs({"Front","Back","Left","Right","Top","Bottom"}) do
                    local d = Instance.new("Decal", v) d.Texture = DECAL_ID d.Face = face
                end
            end
            exPro(v)
        end
    end
    exPro(Workspace) VAZ.Notify("Décal c00lkidd")
end

-- 5. Particules c00lkidd
local function ParticlesC00lkidd()
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character and v.Character:FindFirstChild("Head") then
            local e = Instance.new("ParticleEmitter") e.Parent = v.Character.Head
            e.Texture = "rbxassetid://18381835089" e.VelocitySpread = 5 e.SpreadAngle = Vector2.new(0,0) e.Speed = NumberRange.new(9,9)
        end
    end
    VAZ.Notify("Particules c00lkidd")
end

-- 6. Son goofy ahh
local function SoundGoofy()
    local e = Instance.new("Sound", Workspace)
    e.SoundId = "rbxassetid://120959485595551" e.Volume = 12 e.Looped = true e:Play()
    VAZ.Notify("Son goofy ahh")
end

-- 7. Spooky Scary Skeletons
local function SoundSpooky()
    local a = Instance.new("Sound", Workspace)
    a.SoundId = "rbxassetid://99986264226275" a.Pitch = 0.2 a.Volume = 12 a.Looped = true a:Play()
    VAZ.Notify("Spooky Scary Skeletons")
end

-- 8. Play theme
local function PlayTheme()
    local s = Instance.new("Sound", Workspace)
    s.SoundId = "rbxassetid://127653283576622" s.Pitch = 0.7 s.Looped = true s.Playing = true
    VAZ.Notify("Play theme")
end

-- 9. Hacker particles
local function HackerParticles()
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character and v.Character:FindFirstChild("Head") then
            local e = Instance.new("ParticleEmitter") e.Parent = v.Character.Head
            e.Texture = "rbxassetid://9585701185" e.VelocitySpread = 5 e.SpreadAngle = Vector2.new(0,0) e.Speed = NumberRange.new(9,9)
        end
    end
    VAZ.Notify("Particules Hacker")
end

-- 10. Hint
local function Hint1() local h = Instance.new("Hint", Workspace) h.Text = "Hacked by SheldonGUI v3" VAZ.Notify("Hint") end

-- 11. Hint 2
local function Hint2() local h = Instance.new("Hint", Workspace) h.Text = "DEVS FIX UR GAME 💔🥀🥀" VAZ.Notify("Hint 2") end

-- 12. Message
local function Message1() local m = Instance.new("Message", Workspace) m.Text = "SheldonGUI v3 was here.." VAZ.Notify("Message") end

-- 13. Message 2
local function Message2() local m = Instance.new("Message", Workspace) m.Text = "OH NO YOUR GAME GOT FE BYPASSED BY SHELDONGUI V3" VAZ.Notify("Message 2") end

-- 14. Kill All
local function KillAll()
    for _, v in pairs(Players:GetPlayers()) do if v.Character then v.Character:BreakJoints() end end
    VAZ.Notify("Kill All")
end

-- 15. Toadroast
local function Toadroast()
    task.spawn(function() while true do task.wait(0.3) local s = Instance.new("Sky", Lighting) for _, f in pairs({"Bk","Dn","Ft","Lf","Rt","Up"}) do s["Skybox"..f] = "rbxassetid://201208408" end end end)
    local m = Instance.new("Hint", Workspace) m.Text = "GET TOADROASTED!"
    task.spawn(function() while true do task.wait(0.3) for _, v in pairs(Workspace:GetChildren()) do if v:IsA("Model") then v:Destroy() end end end end)
    local a = Instance.new("Sound", Workspace) a.SoundId = "rbxassetid://6942391979" a.Volume = 58359 a.Looped = true a:Play()
    task.spawn(function() while true do task.wait(0.4) local msg = Instance.new("Message", Workspace) msg.Text = "Get toadroasted by SheldonGUI v3" task.wait(0.4) msg:Destroy() end end)
    local noises = {"rbxassetid://230287740","rbxassetid://271787597","rbxassetid://153752123","rbxassetid://271787503"}
    task.spawn(function() while true do task.wait(10)
        local part = Instance.new("Part", Workspace) part.Name = "Toad"
        local mesh = Instance.new("SpecialMesh", part) part.CanCollide = false part.Size = Vector3.new(440,530,380)
        part.Position = Vector3.new(math.random(-3000,1000), math.random(1,3000), math.random(-3000,3000))
        local snd = Instance.new("Sound", Workspace) snd.SoundId = noises[math.random(1,#noises)] snd:Play() snd.Ended:Connect(function() snd:Destroy() end)
        mesh.MeshType = Enum.MeshType.FileMesh mesh.MeshId = "rbxassetid://7234998844" mesh.TextureId = "rbxassetid://1009824086"
    end end) VAZ.Notify("Toadroast activé")
end

-- 16. Nachos
local function Nachos()
    local SKYBOX = "rbxassetid://116355300471902" local MESH = "rbxassetid://13049164651" local TEX = "rbxassetid://13049164734" local SND = "rbxassetid://110372826701563"
    for _, c in pairs(Lighting:GetChildren()) do if c:IsA("Sky") then c:Destroy() end end
    local sky = Instance.new("Sky") for _, f in pairs({"Bk","Dn","Ft","Lf","Rt","Up"}) do sky["Skybox"..f] = SKYBOX end sky.Parent = Lighting
    Lighting.ChildAdded:Connect(function(c) if c:IsA("Sky") then task.wait(0.1) for _, s in pairs(Lighting:GetChildren()) do if s:IsA("Sky") and s ~= sky then s:Destroy() end end end end)
    task.spawn(function() while true do task.wait(0.3) for _, model in pairs(Workspace:GetChildren()) do if model:IsA("Model") then model:Destroy() end end end end)
    task.spawn(function() local snd = Instance.new("Sound", Workspace) snd.SoundId = SND snd.Name = "NACHOS" snd.Volume = 0.5 snd.Looped = true snd:Play() end)
    task.spawn(function() while true do task.wait(0.033)
        local part = Instance.new("Part", Workspace) part.Name = "Nachos" part.CanCollide = false part.Anchored = false part.Size = Vector3.new(5,5,5)
        part.Position = Vector3.new(math.random(-1000,1000), 500, math.random(-1000,1000))
        local mesh = Instance.new("SpecialMesh", part) mesh.MeshId = MESH mesh.TextureId = TEX mesh.MeshType = Enum.MeshType.FileMesh mesh.Scale = Vector3.new(40,40,40)
        local vel = Instance.new("BodyVelocity", part) vel.Velocity = Vector3.new(0,-200,0) vel.MaxForce = Vector3.new(0, math.huge, 0)
        game:GetService("Debris"):AddItem(vel, 0.5) task.delay(10, function() if part and part.Parent then part:Destroy() end end)
    end end)
    task.spawn(function() while true do task.wait(0.4) local m = Instance.new("Message", Workspace) m.Text = "get Nachoed by SheldonGUI v3" task.wait(0.4) m:Destroy() end end)
    VAZ.Notify("Nachos activé")
end

-- 17. 666
local function SixSixSix()
    for _, v in pairs(Workspace:GetChildren()) do
        if v:IsA("BasePart") then
            local bbg = Instance.new("BillboardGui", v) bbg.Size = UDim2.new(2.5,0,2.5,0)
            local t = Instance.new("TextLabel") t.Text = "666 666 666 666 666 666" t.Font = Enum.Font.SourceSansBold t.FontSize = Enum.FontSize.Size48 t.TextColor3 = Color3.new(1,0,0) t.Size = UDim2.new(1.25,0,1.25,0) t.Position = UDim2.new(-0.125,-22,-1.1,0) t.BackgroundTransparency = 1 t.Parent = bbg
        end
    end
    VAZ.Notify("Effet 666")
end

-- 18. Shedletsky
local function Shedletsky()
    local s = Instance.new("Sky", Lighting) s.SunAngularSize = 0 s.MoonAngularSize = 0
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character and v.Character:FindFirstChild("Head") then
            local e = Instance.new("ParticleEmitter") e.Parent = v.Character.Head e.Texture = "rbxassetid://101389433601746" e.VelocitySpread = 100000 e.Speed = NumberRange.new(9,9)
        end
    end
    local snd = Instance.new("Sound", Workspace) snd.Looped = true snd.Playing = true snd.SoundId = "rbxassetid://101389433601746"
    VAZ.Notify("Shedletsky")
end

-- 19. Anonymous Sky
local function AnonSky()
    local s = Instance.new("Sky", Lighting)
    for _, f in pairs({"Bk","Dn","Ft","Lf","Rt","Up"}) do s["Skybox"..f] = "rbxassetid://18381835089" end
    Lighting.TimeOfDay = "12:00:00" VAZ.Notify("Anonymous Sky")
end

-- 20. Fly Script c00l
local function FlyC00l()
    VAZ.Notify("Fly Script c00l activé (utilise le bouton UP/DOWN)")
end

-- CONSTRUCTION DE L'ONGLET
function VAZ.BuildEffectsTab(ui)
    ui:AddTab("sparkles", "Effets")
    local effects = {
        {"Décal", "Texture sur murs", ApplyDecal},
        {"Skybox c00lkidd", "Ciel c00lkidd", SkyboxC00lkidd},
        {"Skybox c00lkidd sky", "Version 158118263", SkyboxC00lkiddSky},
        {"Décal c00lkidd", "Texture 158118263", DecalC00lkidd},
        {"Particules c00lkidd", "Sur la tête", ParticlesC00lkidd},
        {"Son goofy ahh", "Joue le son", SoundGoofy},
        {"Spooky Scary", "Joue spooky", SoundSpooky},
        {"Play Theme", "Musique thème", PlayTheme},
        {"Particules Hacker", "Hacker", HackerParticles},
        {"Hint", "Hint en haut", Hint1},
        {"Hint 2", "Hint 2", Hint2},
        {"Message", "Message 1", Message1},
        {"Message 2", "Message 2", Message2},
        {"Kill All", "Tue tous", KillAll},
        {"Toadroast", "Effet chaotique", Toadroast},
        {"Nachos", "Effet chaotique", Nachos},
        {"666", "Rouge + 666", SixSixSix},
        {"Shedletsky", "Skybox + particules", Shedletsky},
        {"Anonymous Sky", "Ciel Anon", AnonSky},
        {"Fly Script c00l", "Version c00lgui", FlyC00l},
    }
    for _, e in ipairs(effects) do
        ui:AddModule("sparkles", "Effets", { name = e[1], desc = e[2], callback = e[3] })
    end
end

print("✅ Partie 7/7 chargée - 20 effets c00lgui")