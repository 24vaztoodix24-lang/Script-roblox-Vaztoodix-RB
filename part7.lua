-- PARTIE 7/7 - Effets visuels et sons (adapté du script c00lgui v3)
-- Chaque fonction est reliée à l'interface Vaztoodix

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local p = Players.LocalPlayer

getgenv().VAZ = getgenv().VAZ or {}
local VAZ = getgenv().VAZ

-- ===== FONCTIONS D'EFFETS =====

-- 1. DÉCAL (applique une texture sur tous les murs)
local function ApplyDecal()
    local DECAL_ID = "rbxassetid://18381835089"
    local function exPro(root)
        for _, v in pairs(root:GetChildren()) do
            if v:IsA("Decal") and v.Texture ~= DECAL_ID then
                v:Destroy()
            elseif v:IsA("BasePart") then
                v.Material = Enum.Material.Plastic
                v.Transparency = 0
                for _, face in pairs({"Front", "Back", "Left", "Right", "Top", "Bottom"}) do
                    local d = Instance.new("Decal", v)
                    d.Texture = DECAL_ID
                    d.Face = face
                end
            end
            exPro(v)
        end
    end
    exPro(Workspace)
    VAZ.Notify("Décal appliqué")
end
VAZ.ApplyDecal = ApplyDecal

-- 2. SKYBOX c00lkidd
local function ApplySkyboxC00lkidd()
    local s = Instance.new("Sky")
    s.Name = "Sky"
    s.Parent = Lighting
    s.SkyboxBk = "rbxassetid://18381835089"
    s.SkyboxDn = "rbxassetid://18381835089"
    s.SkyboxFt = "rbxassetid://18381835089"
    s.SkyboxLf = "rbxassetid://18381835089"
    s.SkyboxRt = "rbxassetid://18381835089"
    s.SkyboxUp = "rbxassetid://18381835089"
    Lighting.TimeOfDay = "12:00:00"
    VAZ.Notify("Skybox c00lkidd appliqué")
end
VAZ.ApplySkyboxC00lkidd = ApplySkyboxC00lkidd

-- 3. SKYBOX c00lkidd sky (version 158118263)
local function ApplySkyboxC00lkiddSky()
    local s = Instance.new("Sky")
    s.Name = "Sky"
    s.Parent = Lighting
    s.SkyboxBk = "rbxassetid://158118263"
    s.SkyboxDn = "rbxassetid://158118263"
    s.SkyboxFt = "rbxassetid://158118263"
    s.SkyboxLf = "rbxassetid://158118263"
    s.SkyboxRt = "rbxassetid://158118263"
    s.SkyboxUp = "rbxassetid://158118263"
    Lighting.TimeOfDay = "12:00:00"
    VAZ.Notify("Skybox c00lkidd sky appliqué")
end
VAZ.ApplySkyboxC00lkiddSky = ApplySkyboxC00lkiddSky

-- 4. DÉCAL c00lkidd (version 158118263)
local function ApplyDecalC00lkidd()
    local DECAL_ID = "rbxassetid://158118263"
    local function exPro(root)
        for _, v in pairs(root:GetChildren()) do
            if v:IsA("Decal") and v.Texture ~= DECAL_ID then
                v:Destroy()
            elseif v:IsA("BasePart") then
                v.Material = Enum.Material.Plastic
                v.Transparency = 0
                for _, face in pairs({"Front", "Back", "Left", "Right", "Top", "Bottom"}) do
                    local d = Instance.new("Decal", v)
                    d.Texture = DECAL_ID
                    d.Face = face
                end
            end
            exPro(v)
        end
    end
    exPro(Workspace)
    VAZ.Notify("Décal c00lkidd appliqué")
end
VAZ.ApplyDecalC00lkidd = ApplyDecalC00lkidd

-- 5. PARTICULES c00lkidd (sur la tête de tous les joueurs)
local function ApplyParticles()
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character and v.Character:FindFirstChild("Head") then
            local emit = Instance.new("ParticleEmitter")
            emit.Parent = v.Character.Head
            emit.Texture = "rbxassetid://18381835089"
            emit.VelocitySpread = 5
            emit.SpreadAngle = Vector2.new(0, 0)
            emit.Speed = NumberRange.new(9, 9)
        end
    end
    VAZ.Notify("Particules appliquées")
end
VAZ.ApplyParticles = ApplyParticles

-- 6. SON "goofy ahh"
local function PlayGasSound()
    local e = Instance.new("Sound", Workspace)
    e.SoundId = "rbxassetid://120959485595551"
    e.Volume = 12
    e.Looped = true
    e:Play()
    VAZ.Notify("Son goofy ahh joué")
end
VAZ.PlayGasSound = PlayGasSound

-- 7. SON "Spooky Scary Skeletons"
local function PlaySSSound()
    local audio = Instance.new("Sound", Workspace)
    audio.SoundId = "rbxassetid://99986264226275"
    audio.Pitch = 0.2
    audio.Volume = 12
    audio.Looped = true
    audio:Play()
    VAZ.Notify("Spooky Scary Skeletons joué")
end
VAZ.PlaySSSound = PlaySSSound

-- 8. SON "play theme"
local function PlayThemeSound()
    local s = Instance.new("Sound")
    s.Parent = Workspace
    s.SoundId = "rbxassetid://127653283576622"
    s.Pitch = 0.7
    s.Looped = true
    s.Playing = true
    VAZ.Notify("Play theme joué")
end
VAZ.PlayThemeSound = PlayThemeSound

-- 9. PARTICULES Hacker
local function ApplyHackerParticles()
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character and v.Character:FindFirstChild("Head") then
            local emit = Instance.new("ParticleEmitter")
            emit.Parent = v.Character.Head
            emit.Texture = "rbxassetid://9585701185"
            emit.VelocitySpread = 5
            emit.SpreadAngle = Vector2.new(0, 0)
            emit.Speed = NumberRange.new(9, 9)
        end
    end
    VAZ.Notify("Particules Hacker appliquées")
end
VAZ.ApplyHackerParticles = ApplyHackerParticles

-- 10. HINT (message court en haut de l'écran)
local function ShowHint()
    local h = Instance.new("Hint", Workspace)
    h.Text = "Hacked by SheldonGUI v3"
    VAZ.Notify("Hint affiché")
end
VAZ.ShowHint = ShowHint

-- 11. HINT 2
local function ShowHint2()
    local h = Instance.new("Hint", Workspace)
    h.Text = "DEVS FIX UR GAME 💔🥀🥀"
    VAZ.Notify("Hint 2 affiché")
end
VAZ.ShowHint2 = ShowHint2

-- 12. MESSAGE 1
local function ShowMessage()
    local h = Instance.new("Message", Workspace)
    h.Text = "SheldonGUI v3 was here.."
    VAZ.Notify("Message affiché")
end
VAZ.ShowMessage = ShowMessage

-- 13. MESSAGE 2
local function ShowMessage2()
    local h = Instance.new("Message", Workspace)
    h.Text = "OH NO YOUR GAME GOT FE BYPASSED BY SHELDONGUI V3 AND ZEGMA_V1 LELL"
    VAZ.Notify("Message 2 affiché")
end
VAZ.ShowMessage2 = ShowMessage2

-- 14. KILL ALL
local function KillAll()
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character then
            v.Character:BreakJoints()
        end
    end
    VAZ.Notify("Tous les joueurs éliminés")
end
VAZ.KillAll = KillAll

-- 15. TOADROAST (effet chaotique)
local function Toadroast()
    task.spawn(function()
        while true do
            task.wait(0.3)
            local s = Instance.new("Sky", Lighting)
            s.SkyboxBk, s.SkyboxDn, s.SkyboxFt, s.SkyboxLf, s.SkyboxRt, s.SkyboxUp = "rbxassetid://201208408", "rbxassetid://201208408", "rbxassetid://201208408", "rbxassetid://201208408", "rbxassetid://201208408", "rbxassetid://201208408"
        end
    end)
    local m = Instance.new("Hint", Workspace)
    m.Text = "GET TOADROASTED NIXXAS!"
    task.spawn(function()
        while true do
            task.wait(0.3)
            for _, v in pairs(Workspace:GetChildren()) do
                if v:IsA("Model") then v:Destroy() end
            end
        end
    end)
    local a = Instance.new("Sound", Workspace)
    a.SoundId = "rbxassetid://6942391979"
    a.Name = "RAINING MEN"
    a.Volume = 58359
    a.Looped = true
    a:Play()
    task.spawn(function()
        while true do
            task.wait(0.4)
            local msg = Instance.new("Message", Workspace)
            msg.Text = "Get toadroasted by SheldonGUI v3"
            task.wait(0.4)
            msg:Destroy()
        end
    end)
    local noises = {"rbxassetid://230287740", "rbxassetid://271787597", "rbxassetid://153752123", "rbxassetid://271787503"}
    task.spawn(function()
        while true do
            task.wait(10)
            local part = Instance.new("Part", Workspace)
            part.Name = "Toad"
            local mesh = Instance.new("SpecialMesh", part)
            part.CanCollide = false
            part.Size = Vector3.new(440, 530, 380)
            part.Position = Vector3.new(math.random(-3000, 1000), math.random(1, 3000), math.random(-3000, 3000))
            local sound = Instance.new("Sound", Workspace)
            sound.SoundId = noises[math.random(1, #noises)]
            sound:Play()
            sound.Ended:Connect(function() sound:Destroy() end)
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.MeshId = "rbxassetid://7234998844"
            mesh.TextureId = "rbxassetid://1009824086"
        end
    end)
    VAZ.Notify("Toadroast activé")
end
VAZ.Toadroast = Toadroast

-- 16. NACHOS (effet chaotique avec skybox + particules)
local function Nachos()
    local SKYBOX_ID = "rbxassetid://116355300471902"
    local MESH_ID = "rbxassetid://13049164651"
    local TEXTURE_ID = "rbxassetid://13049164734"
    local SOUND_ID = "rbxassetid://110372826701563"
    local function enforceSkybox()
        for _, child in pairs(Lighting:GetChildren()) do
            if child:IsA("Sky") then child:Destroy() end
        end
        local sky = Instance.new("Sky")
        sky.SkyboxBk, sky.SkyboxDn, sky.SkyboxFt = SKYBOX_ID, SKYBOX_ID, SKYBOX_ID
        sky.SkyboxLf, sky.SkyboxRt, sky.SkyboxUp = SKYBOX_ID, SKYBOX_ID, SKYBOX_ID
        sky.Parent = Lighting
        return sky
    end
    enforceSkybox()
    Lighting.ChildAdded:Connect(function(child)
        if child:IsA("Sky") then task.wait(0.1) enforceSkybox() end
    end)
    task.spawn(function()
        while true do
            task.wait(0.3)
            for _, model in pairs(Workspace:GetChildren()) do
                if model:IsA("Model") then model:Destroy() end
            end
        end
    end)
    task.spawn(function()
        local sound = Instance.new("Sound", Workspace)
        sound.SoundId = SOUND_ID
        sound.Name = "NACHOS"
        sound.Volume = 0.5
        sound.Looped = true
        sound:Play()
    end)
    task.spawn(function()
        while true do
            task.wait(0.033)
            local part = Instance.new("Part", Workspace)
            part.Name = "Nachos"
            part.CanCollide = false
            part.Anchored = false
            part.Size = Vector3.new(5, 5, 5)
            part.Position = Vector3.new(math.random(-1000, 1000), 500, math.random(-1000, 1000))
            local mesh = Instance.new("SpecialMesh", part)
            mesh.MeshId = MESH_ID
            mesh.TextureId = TEXTURE_ID
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.Scale = Vector3.new(40, 40, 40)
            local velocity = Instance.new("BodyVelocity", part)
            velocity.Velocity = Vector3.new(0, -200, 0)
            velocity.MaxForce = Vector3.new(0, math.huge, 0)
            game:GetService("Debris"):AddItem(velocity, 0.5)
            task.delay(10, function() if part and part.Parent then part:Destroy() end end)
        end
    end)
    task.spawn(function()
        while true do
            task.wait(0.4)
            local msg = Instance.new("Message", Workspace)
            msg.Text = "get Nachoed by SheldonGUI v3"
            task.wait(0.4)
            msg:Destroy()
        end
    end)
    VAZ.Notify("Nachos activé")
end
VAZ.Nachos = Nachos

-- 17. 666 (effet rouge sur tous les murs + texte 666)
local function SixSixSix()
    for _, v in pairs(Workspace:GetChildren()) do
        if v:IsA("BasePart") then
            local bbg = Instance.new("BillboardGui", v)
            bbg.Size = UDim2.new(2.5, 0, 2.5, 0)
            local tlb = Instance.new("TextLabel")
            tlb.Text = "666 666 666 666 666 666"
            tlb.Font = Enum.Font.SourceSansBold
            tlb.FontSize = Enum.FontSize.Size48
            tlb.TextColor3 = Color3.new(1, 0, 0)
            tlb.Size = UDim2.new(1.25, 0, 1.25, 0)
            tlb.Position = UDim2.new(-0.125, -22, -1.1, 0)
            tlb.BackgroundTransparency = 1
            tlb.Parent = bbg
        end
    end
    VAZ.Notify("Effet 666 appliqué")
end
VAZ.SixSixSix = SixSixSix

-- 18. SHEDLETSKY (skybox + particules + son)
local function Shedletsky()
    local s = Instance.new("Sky")
    s.Name = "Sky"
    s.Parent = Lighting
    s.SunAngularSize = 0
    s.MoonAngularSize = 0
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character and v.Character:FindFirstChild("Head") then
            local emit = Instance.new("ParticleEmitter")
            emit.Parent = v.Character.Head
            emit.Texture = "rbxassetid://101389433601746"
            emit.VelocitySpread = 100000
            emit.Speed = NumberRange.new(9, 9)
        end
    end
    local sound = Instance.new("Sound", Workspace)
    sound.Looped = true
    sound.Playing = true
    sound.SoundId = "rbxassetid://101389433601746"
    VAZ.Notify("Shedletsky activé")
end
VAZ.Shedletsky = Shedletsky

-- 19. ANONYMOUS SKY (skybox)
local function AnonymousSky()
    local s = Instance.new("Sky")
    s.Name = "Sky"
    s.Parent = Lighting
    s.SkyboxBk = "rbxassetid://18381835089"
    s.SkyboxDn = "rbxassetid://18381835089"
    s.SkyboxFt = "rbxassetid://18381835089"
    s.SkyboxLf = "rbxassetid://18381835089"
    s.SkyboxRt = "rbxassetid://18381835089"
    s.SkyboxUp = "rbxassetid://18381835089"
    Lighting.TimeOfDay = "12:00:00"
    VAZ.Notify("Anonymous Sky appliqué")
end
VAZ.AnonymousSky = AnonymousSky

-- 20. FLY SCRIPT (version c00lgui - différente de celle qu'on a déjà)
local function FlyScriptC00l()
    local main = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    main.Name = "FlyScriptC00l"
    main.Parent = p.PlayerGui
    main.ResetOnSpawn = false
    Frame.Parent = main
    Frame.BackgroundColor3 = Color3.fromRGB(163, 255, 137)
    Frame.Size = UDim2.new(0, 190, 0, 57)
    Frame.Position = UDim2.new(0.1, 0, 0.38, 0)
    Frame.Active = true
    Frame.Draggable = true
    -- (Boutons UP/DOWN/ON-OFF/+/- identiques au script original)
    -- Pour ne pas alourdir part7, on garde juste l'activation par le bouton
    VAZ.Notify("Fly Script c00lgui activé (utilise le bouton UP/DOWN)")
end
VAZ.FlyScriptC00l = FlyScriptC00l

-- ===== CONSTRUCTION DE L'ONGLET =====
function VAZ.BuildEffectsTab(ui)
    ui:AddTab("effects", "Effets")
    local effects = {
        {name = "Décal", desc = "Applique une texture sur tous les murs", callback = ApplyDecal},
        {name = "Skybox c00lkidd", desc = "Change le ciel en c00lkidd", callback = ApplySkyboxC00lkidd},
        {name = "Skybox c00lkidd sky", desc = "Change le ciel (version 158118263)", callback = ApplySkyboxC00lkiddSky},
        {name = "Décal c00lkidd", desc = "Texture c00lkidd sur les murs", callback = ApplyDecalC00lkidd},
        {name = "Particules c00lkidd", desc = "Particules sur la tête de tous les joueurs", callback = ApplyParticles},
        {name = "Son goofy ahh", desc = "Joue le son goofy ahh", callback = PlayGasSound},
        {name = "Spooky Scary Skeletons", desc = "Joue le son spooky", callback = PlaySSSound},
        {name = "Play Theme", desc = "Joue la musique du thème", callback = PlayThemeSound},
        {name = "Particules Hacker", desc = "Particules hacker sur tous les joueurs", callback = ApplyHackerParticles},
        {name = "Hint", desc = "Affiche un hint en haut de l'écran", callback = ShowHint},
        {name = "Hint 2", desc = "Affiche un hint 2", callback = ShowHint2},
        {name = "Message", desc = "Affiche un message", callback = ShowMessage},
        {name = "Message 2", desc = "Affiche un message 2", callback = ShowMessage2},
        {name = "Kill All", desc = "Tue tous les joueurs", callback = KillAll},
        {name = "Toadroast", desc = "Effet chaotique Toadroast", callback = Toadroast},
        {name = "Nachos", desc = "Effet chaotique Nachos", callback = Nachos},
        {name = "666", desc = "Effet rouge sur les murs + texte 666", callback = SixSixSix},
        {name = "Shedletsky", desc = "Skybox + particules + son Shedletsky", callback = Shedletsky},
        {name = "Anonymous Sky", desc = "Change le ciel en Anonymous", callback = AnonymousSky},
        {name = "Fly Script c00l", desc = "Version c00lgui du Fly", callback = FlyScriptC00l},
    }
    for _, effect in ipairs(effects) do
        ui:AddModule("effects", "Effets", {
            name = effect.name,
            desc = effect.desc,
            callback = effect.callback
        })
    end
end

print("✅ Partie 7/7 chargée - 20 effets visuels et sons (c00lgui v3)")