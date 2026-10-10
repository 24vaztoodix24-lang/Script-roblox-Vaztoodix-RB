-- PARTIE 9/9 - RSPY / Dex / Auto-Farm / Objets
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local p = Players.LocalPlayer

getgenv().VAZ = getgenv().VAZ or {}
local VAZ = getgenv().VAZ

-- ============================================================
-- CHARGEMENT DEX
-- ============================================================
local function LoadDex()
    local urls = {
        "https://raw.githubusercontent.com/peyton2465/Dex/master/out.lua",
        "https://raw.githubusercontent.com/LorekeeperZinnia/Dex/main/out.lua",
        "https://raw.githubusercontent.com/richie0866/dark-dex/main/DarkDex.lua"
    }
    for _, u in ipairs(urls) do
        local ok = pcall(function() loadstring(game:HttpGet(u))() end)
        if ok then if VAZ.NotifyUI then VAZ.NotifyUI("Dex chargé") end return end
    end
    if VAZ.NotifyUI then VAZ.NotifyUI("Échec chargement Dex") end
end
VAZ.LoadDex = LoadDex

-- ============================================================
-- CHARGEMENT REMOTE SPY
-- ============================================================
local function LoadRemoteSpy()
    local urls = {
        "https://raw.githubusercontent.com/WhyIsEveryoneTakingUsernames/SimpleSpy/main/SimpleSpy.lua",
        "https://raw.githubusercontent.com/NotDSF/SimpleSpy/main/SimpleSpy.lua",
        "https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpy.lua"
    }
    for _, u in ipairs(urls) do
        local ok = pcall(function() loadstring(game:HttpGet(u))() end)
        if ok then if VAZ.NotifyUI then VAZ.NotifyUI("Remote Spy chargé") end return end
    end
    if VAZ.NotifyUI then VAZ.NotifyUI("Échec chargement Remote Spy") end
end
VAZ.LoadRemoteSpy = LoadRemoteSpy

-- ============================================================
-- AUTO-COLLECT (objets au sol)
-- ============================================================
local autoCollect = false
local collectConn = nil

local function StartAutoCollect()
    if autoCollect then return end
    autoCollect = true
    collectConn = RunService.Heartbeat:Connect(function()
        if not autoCollect then return end
        local char = p.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj ~= hrp and obj.Parent ~= char then
                local n = string.lower(obj.Name)
                if n:find("coin") or n:find("gem") or n:find("cash") or n:find("money")
                   or n:find("drop") or n:find("item") or n:find("fruit") or n:find("seed")
                   or n:find("pet") or n:find("egg") or n:find("chest") or n:find("bag") then
                    pcall(function() obj.CFrame = hrp.CFrame end)
                end
            end
        end
    end)
    if VAZ.NotifyUI then VAZ.NotifyUI("Auto-Collect ON") end
end

local function StopAutoCollect()
    autoCollect = false
    if collectConn then collectConn:Disconnect() collectConn = nil end
    if VAZ.NotifyUI then VAZ.NotifyUI("Auto-Collect OFF") end
end

local function ToggleAutoCollect()
    if autoCollect then StopAutoCollect() else StartAutoCollect() end
end
VAZ.ToggleAutoCollect = ToggleAutoCollect

-- ============================================================
-- AUTO-FARM COMPLET
-- ============================================================
local autoFarm = false
local farmConn = nil

local function StartAutoFarm()
    if autoFarm then return end
    autoFarm = true
    StartAutoCollect()
    farmConn = RunService.Heartbeat:Connect(function()
        if not autoFarm then return end
        local char = p.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= char then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 and not Players:GetPlayerFromCharacter(obj) then
                    local eHrp = obj:FindFirstChild("HumanoidRootPart")
                    if eHrp and (eHrp.Position - hrp.Position).Magnitude < 30 then
                        pcall(function()
                            local tool = char:FindFirstChildOfClass("Tool")
                            if tool then tool:Activate() end
                        end)
                    end
                end
            end
        end
    end)
    if VAZ.NotifyUI then VAZ.NotifyUI("Auto-Farm ON") end
end

local function StopAutoFarm()
    autoFarm = false
    if farmConn then farmConn:Disconnect() farmConn = nil end
    StopAutoCollect()
    if VAZ.NotifyUI then VAZ.NotifyUI("Auto-Farm OFF") end
end

local function ToggleAutoFarm()
    if autoFarm then StopAutoFarm() else StartAutoFarm() end
end
VAZ.ToggleAutoFarm = ToggleAutoFarm

-- ============================================================
-- RÉCUPÉRATION DE TOUS LES OUTILS (Tools)
-- ============================================================
local function CollectAllTools()
    local count = 0
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("Tool") then
            local clone = obj:Clone()
            clone.Parent = p.Backpack
            count = count + 1
        end
    end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj.Parent ~= p.Character then
            pcall(function() obj.Parent = p.Backpack count = count + 1 end)
        end
    end
    if VAZ.NotifyUI then VAZ.NotifyUI(count .. " outils récupérés") end
end
VAZ.CollectAllTools = CollectAllTools

-- ============================================================
-- RÉCUPÉRATION D'OBJETS SPÉCIFIQUES (drop au sol)
-- ============================================================
local function CollectDrops()
    local count = 0
    local char = p.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Parent ~= char then
            local n = string.lower(obj.Name)
            if n:find("drop") or n:find("item") or n:find("reward") or n:find("loot") then
                pcall(function() obj.CFrame = hrp.CFrame count = count + 1 end)
            end
        end
    end
    if VAZ.NotifyUI then VAZ.NotifyUI(count .. " objets récupérés") end
end
VAZ.CollectDrops = CollectDrops

-- ============================================================
-- DÉTECTION VIP / GAMEPASSES
-- ============================================================
local function CheckVIP()
    local results = { OwnedPasses = {} }
    pcall(function()
        local MPS = game:GetService("MarketplaceService")
        local info = MPS:GetProductInfo(game.PlaceId)
        results.GameName = info.Name
        results.Creator = info.Creator and info.Creator.Name or "Inconnu"
        local passes = MPS:GetGamePasses(game.PlaceId)
        results.TotalPasses = #passes
        for _, pass in ipairs(passes) do
            local ok, owns = pcall(function() return MPS:UserOwnsGamePassAsync(p.UserId, pass.Id) end)
            if ok and owns then table.insert(results.OwnedPasses, pass.Name) end
        end
    end)
    if VAZ.NotifyUI then
        VAZ.NotifyUI("Jeu : " .. (results.GameName or "?") .. " | Passes : " .. #results.OwnedPasses .. "/" .. (results.TotalPasses or 0))
    end
    return results
end
VAZ.CheckVIP = CheckVIP

-- ============================================================
-- AFFICHER L'ARGENT DU JOUEUR
-- ============================================================
local function GetMoney()
    local str = ""
    local ls = p:FindFirstChild("leaderstats")
    if ls then
        for _, stat in pairs(ls:GetChildren()) do
            str = str .. stat.Name .. ": " .. tostring(stat.Value) .. " | "
        end
    end
    for _, gui in pairs(p.PlayerGui:GetDescendants()) do
        if gui:IsA("TextLabel") then
            local n = string.lower(gui.Name)
            if n:find("cash") or n:find("money") or n:find("gold") then
                str = str .. gui.Name .. ": " .. gui.Text .. " | "
            end
        end
    end
    if VAZ.NotifyUI then VAZ.NotifyUI(str ~= "" and str or "Aucune valeur trouvée") end
    return str
end
VAZ.GetMoney = GetMoney

-- ============================================================
-- TOUS LES REMOTES DU JEU (lister)
-- ============================================================
local function ListAllRemotes()
    local remotes = {}
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            table.insert(remotes, obj:GetFullName())
        end
    end
    if VAZ.NotifyUI then VAZ.NotifyUI(#remotes .. " remotes trouvés (voir console F9)") end
    for _, r in ipairs(remotes) do print("[VAZ REMOTE] " .. r) end
    return remotes
end
VAZ.ListAllRemotes = ListAllRemotes

-- ============================================================
-- INTERFACE : ONGLET RSPY/DEX
-- ============================================================
function VAZ.BuildRSPYTab(ui)
    -- Onglet 1 : Explorer
    ui:AddTab("rspy", "Explorer")
    ui:AddModule("rspy", "Explorer", { name = "Charger Dex", desc = "Explorateur d'objets du jeu", callback = function() LoadDex() end })
    ui:AddModule("rspy", "Explorer", { name = "Lister tous les remotes", desc = "Affiche les RemoteEvent/Function dans F9", callback = function() ListAllRemotes() end })

    -- Onglet 2 : Spy
    ui:AddTab("rspy", "Spy")
    ui:AddModule("rspy", "Spy", { name = "Charger Remote Spy", desc = "Intercepte les remotes (SimpleSpy)", callback = function() LoadRemoteSpy() end })

    -- Onglet 3 : Auto-Farm
    ui:AddTab("rspy", "Auto-Farm")
    ui:AddModule("rspy", "Auto-Farm", { name = "Auto-Farm (ON/OFF)", desc = "Collecte + attaque auto", toggle = true, callback = function() ToggleAutoFarm() end })
    ui:AddModule("rspy", "Auto-Farm", { name = "Auto-Collect (objets)", desc = "Ramasse tous les objets au sol", toggle = true, callback = function() ToggleAutoCollect() end })

    -- Onglet 4 : Objets
    ui:AddTab("rspy", "Objets")
    ui:AddModule("rspy", "Objets", { name = "Récupérer tous les outils", desc = "Copie tous les Tools dans le Backpack", callback = function() CollectAllTools() end })
    ui:AddModule("rspy", "Objets", { name = "Récupérer les drops", desc = "Ramasse les drops (loot, item)", callback = function() CollectDrops() end })

    -- Onglet 5 : Infos
    ui:AddTab("rspy", "Infos")
    ui:AddModule("rspy", "Infos", { name = "Vérifier VIP / Gamepasses", desc = "Affiche les infos du jeu", callback = function() CheckVIP() end })
    ui:AddModule("rspy", "Infos", { name = "Voir mon argent", desc = "Affiche les valeurs (leaderstats)", callback = function() GetMoney() end })
end

print("✅ Partie 9/9 chargée - RSPY / Dex / Auto-Farm / Objets")