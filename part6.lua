-- PARTIE 6/6 - Module Communauté (Détection des utilisateurs)
-- Envoie un signal au webhook Discord configuré LOCALEMENT

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local p = Players.LocalPlayer

getgenv().VAZ = getgenv().VAZ or {}
local VAZ = getgenv().VAZ

-- === CONFIGURATION (À REMPLIR LOCALEMENT, NE PAS COMMIT SUR GITHUB) ===
local WEBHOOK_URL = "https://discord.com/api/webhooks/1553091419093340190/54jEqsQLk6ZlXvoFjuzUakPpmPWpnjuFmTm6JMgPmHt-o2qt64faWOsLvFPTwNGyIVYd" -- <- Colle ici ton URL de webhook Discord, entre les guillemets

-- === ENVOI DU SIGNAL ===
local function SendSignal()
    if WEBHOOK_URL == "" then
        warn("[Vaztoodix] Webhook URL non configurée. Signal non envoyé.")
        return
    end

    local data = {
        username = "Vaztoodix Tracker",
        embeds = {
            {
                title = "Nouvel utilisateur détecté",
                color = 0x9B59B6,
                fields = {
                    { name = "Nom", value = p.Name, inline = true },
                    { name = "User ID", value = tostring(p.UserId), inline = true },
                    { name = "Serveur (JobId)", value = tostring(game.JobId), inline = false }
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
        }
    }

    local success, err = pcall(function()
        HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
    end)

    if not success then
        warn("[Vaztoodix] Erreur d'envoi du signal : " .. tostring(err))
    else
        print("✅ [Vaztoodix] Signal envoyé au serveur Discord.")
    end
end

task.spawn(SendSignal)

-- === RÉCUPÉRATION DES UTILISATEURS ===
-- La liste est stockée localement pour l'exemple.
-- Pour un vrai système multi-utilisateurs, il faut un serveur qui stocke et renvoie la liste.
local detectedUsers = {}

local function AddDetectedUser(userId, name)
    for _, user in pairs(detectedUsers) do
        if user.UserId == userId then return end
    end
    table.insert(detectedUsers, { UserId = userId, Name = name })
end

AddDetectedUser(p.UserId, p.Name)

-- === FONCTION POUR RÉCUPÉRER L'AVATAR D'UN UTILISATEUR ===
local function GetAvatarUrl(userId)
    local url = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. tostring(userId) .. "&size=420x420&format=Png"
    local ok, response = pcall(function()
        return HttpService:GetAsync(url)
    end)
    if ok then
        local decoded = HttpService:JSONDecode(response)
        if decoded and decoded.data and decoded.data[1] and decoded.data[1].imageUrl then
            return decoded.data[1].imageUrl
        end
    end
    return nil
end

-- === AFFICHAGE DANS L'INTERFACE ===
function VAZ.BuildCommunityTab(ui)
    ui:AddTab("community", "Communauté")
    ui:AddModule("community", "Communauté", {
        name = "Mon profil",
        desc = "Ton UserID : " .. tostring(p.UserId) .. " | Avatar disponible",
        callback = function()
            local avatar = GetAvatarUrl(p.UserId)
            if avatar then
                ui:Notify("Avatar : " .. avatar)
            else
                ui:Notify("Impossible de récupérer l'avatar")
            end
        end
    })
    for _, user in ipairs(detectedUsers) do
        ui:AddModule("community", "Communauté", {
            name = user.Name,
            desc = "ID : " .. tostring(user.UserId),
            callback = function()
                local avatar = GetAvatarUrl(user.UserId)
                if avatar then
                    ui:Notify("Avatar de " .. user.Name .. " : " .. avatar)
                end
            end
        })
    end
end

print("✅ Partie 6/6 chargée - Module Communauté prêt (webhook à configurer localement).")