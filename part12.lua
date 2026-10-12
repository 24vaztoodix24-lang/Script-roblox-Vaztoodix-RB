-- PARTIE 12/12 - Sin Dragon (GenesisFE) + Kick All + Serveur Privé
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local p = Players.LocalPlayer

getgenv().VAZ = getgenv().VAZ or {}
local VAZ = getgenv().VAZ

-- ============================================================
-- SIN DRAGON (GenesisFE)
-- ============================================================
local sinDragonLoaded = false

local function LoadSinDragon()
    if sinDragonLoaded then return end
    local ok = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/GenesisFE/Genesis/refs/heads/main/Loadstrings/Sin%20Dragon"))()
    end)
    if ok then
        sinDragonLoaded = true
        if VAZ.NotifyUI then VAZ.NotifyUI("Sin Dragon chargé") end
    else
        if VAZ.NotifyUI then VAZ.NotifyUI("Échec chargement Sin Dragon") end
    end
end
VAZ.LoadSinDragon = LoadSinDragon

-- ============================================================
-- KICK ALL
-- ============================================================
local function KickAll()
    local count = 0
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= p then
            pcall(function() v:Kick("Serveur privé Vaztoodix ™") end)
            count = count + 1
        end
    end
    if VAZ.NotifyUI then VAZ.NotifyUI(count .. " joueurs kickés") end
end
VAZ.KickAll = KickAll

-- ============================================================
-- KICK UN JOUEUR
-- ============================================================
local function KickPlayer(name)
    local target = Players:FindFirstChild(name)
    if target and target ~= p then
        pcall(function() target:Kick("Vaztoodix ™") end)
        if VAZ.NotifyUI then VAZ.NotifyUI(target.Name .. " kické") end
    else
        if VAZ.NotifyUI then VAZ.NotifyUI("Joueur introuvable") end
    end
end
VAZ.KickPlayer = KickPlayer

-- ============================================================
-- SERVEUR PRIVÉ
-- ============================================================
local function JoinEmptyServer()
    if VAZ.NotifyUI then VAZ.NotifyUI("Recherche serveur vide...") end
    pcall(function()
        TeleportService:Teleport(game.PlaceId, p)
    end)
end
VAZ.JoinEmptyServer = JoinEmptyServer

-- ============================================================
-- ONGLET DANS L'INTERFACE
-- ============================================================
function VAZ.BuildSinDragonNewTab(ui)
    -- Onglet Sin Dragon
    ui:AddTab("crosshair", "Sin Dragon")
    ui:AddModule("crosshair", "Sin Dragon", {
        name = "Charger Sin Dragon",
        desc = "Version à jour de Sin Dragon (GenesisFE)",
        callback = function() LoadSinDragon() end
    })

    -- Onglet Admin Serveur
    ui:AddTab("crosshair", "Admin Serveur")
    ui:AddModule("crosshair", "Admin Serveur", {
        name = "Kick All",
        desc = "Expulse tous les autres joueurs du serveur",
        callback = function() KickAll() end
    })
    ui:AddModule("crosshair", "Admin Serveur", {
        name = "Kick un joueur",
        desc = "Entre le nom du joueur à kicker",
        textbox = true,
        placeholder = "Nom du joueur",
        callback = function(name) KickPlayer(name) end
    })
    ui:AddModule("crosshair", "Admin Serveur", {
        name = "Rejoindre serveur vide",
        desc = "Téléporte dans un nouveau serveur",
        callback = function() JoinEmptyServer() end
    })
end

print("✅ Partie 12/12 chargée - Sin Dragon Genesis + Kick All + Serveur Privé")