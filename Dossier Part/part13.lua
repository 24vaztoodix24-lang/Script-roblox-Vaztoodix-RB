-- PARTIE 13/13 - Descriptions de tous les mods
local Players = game:GetService("Players")
local p = Players.LocalPlayer

getgenv().VAZ = getgenv().VAZ or {}
local VAZ = getgenv().VAZ

local DESCRIPTIONS = {
    -- ARMES
    ["zizi Tranchant"] = "Arme 1-hit avec mesh Gigas. Portée 500 studs. Tue instantanément.",
    ["Micha Minivichi"] = "Arme 1-hit avec mesh Gigas. Portée 600 studs.",
    ["Loucybel_Facher"] = "Marteau explosif qui tue en zone (rayon 15 studs).",
    ["istadyxx26"] = "Arme spéciale avec explosions + particules + secousse caméra.",
    ["Épées orbitales"] = "6 épées tournoyant autour de toi (mesh 13186744598).",

    -- MOUVEMENT
    ["Vol (Fly)"] = "Vol libre avec WASD + Espace (monter) + Shift (descendre).",
    ["Noclip"] = "Traverse les murs et objets solides.",
    ["Téléport (T)"] = "Appuie sur T pour te téléporter à la souris.",
    ["Freecam (ZQSD)"] = "Caméra libre ZQSD pour explorer.",
    ["Spectate joueur"] = "Suis la caméra d'un autre joueur.",
    ["TP Coordonnées"] = "Téléportation vers des coordonnées X,Y,Z.",
    ["Vitesse de marche"] = "Curseur pour régler la vitesse (16-300).",
    ["Vitesse de vol"] = "Curseur pour régler la vitesse de vol (50-500).",

    -- COMBAT
    ["Tuer tous"] = "Élimine instantanément tous les autres joueurs.",
    ["Aimbot"] = "Verrouillage automatique sur la tête du joueur le plus proche (Exunys V3).",
    ["Wallhack / ESP"] = "Affiche les joueurs à travers les murs (highlight + nom + distance).",
    ["Clone"] = "Crée un clone de ton personnage qui te suit et attaque les ennemis.",
    ["Freeze All"] = "Gèle tous les joueurs (ils ne peuvent plus bouger).",
    ["Unfreeze All"] = "Dégèle tous les joueurs.",
    ["Ragdoll All"] = "Met tous les joueurs en ragdoll (ils tombent au sol).",
    ["Goto joueur"] = "Téléporte-toi à la position d'un joueur.",
    ["Bring joueur"] = "Attire un joueur vers toi.",
    ["Freeze joueur"] = "Gèle un joueur spécifique.",
    ["Kick All"] = "Expulse tous les autres joueurs du serveur.",
    ["Kick un joueur"] = "Expulse un joueur spécifique par son nom.",
    ["Sin Dragon"] = "Effet visuel : dragon au-dessus de la tête + mains de chaque côté.",
    ["Sin Dragon (New)"] = "Version à jour de Sin Dragon (GenesisFE) avec fling et options.",
    ["Join Empty Server"] = "Rejoins un nouveau serveur (potentiellement vide).",

    -- DIVERS
    ["Godmode"] = "Santé infinie (tu ne peux pas mourir).",
    ["Invisibilité"] = "Rend ton personnage transparent.",
    ["Auto-click"] = "Clique automatiquement pour toi.",
    ["Anti-AFK"] = "Empêche le kick pour inactivité.",
    ["Particules"] = "Halo de particules colorées autour de toi.",
    ["FullBright"] = "Éclaire toute la scène (comme en plein jour).",
    ["Heal (toi)"] = "Restaure ta santé au maximum.",
    ["Heal joueur"] = "Soigne un autre joueur.",
    ["Générer voiture"] = "Crée un véhicule de test devant toi.",
    ["Heure locale"] = "Change l'heure du jeu (0-24).",
    ["Gravité"] = "Curseur pour régler la gravité du monde.",

    -- EFFETS
    ["Décal"] = "Applique une texture sur tous les murs du jeu.",
    ["Skybox c00lkidd"] = "Change le ciel en c00lkidd.",
    ["Particules c00lkidd"] = "Ajoute des particules c00lkidd sur toutes les têtes.",
    ["Son goofy ahh"] = "Joue le son 'goofy ahh' en boucle.",
    ["Kill All (Effet)"] = "Effet chaotique : tue tous les joueurs.",
    ["Toadroast"] = "Effet chaotique avec des grenouilles géantes.",
    ["Nachos"] = "Effet chaotique avec des nachos qui tombent du ciel.",
    ["666"] = "Effet rouge sur les murs + texte '666' partout.",
    ["Shedletsky"] = "Skybox + particules + son Shedletsky.",

    -- RSPY / DEX
    ["Charger Dex"] = "Ouvre Dex Explorer (explorateur d'objets du jeu).",
    ["Charger Remote Spy"] = "Ouvre SimpleSpy (intercepte les remotes).",
    ["Lister tous les remotes"] = "Affiche tous les RemoteEvent/Function dans la console F9.",
    ["Auto-Farm"] = "Collecte automatiquement les objets + attaque les ennemis.",
    ["Auto-Collect"] = "Téléporte tous les objets ramassables vers toi.",
    ["Récupérer tous les outils"] = "Copie tous les Tools du jeu dans ton Backpack.",
    ["Récupérer les drops"] = "Ramasse les objets au sol (loot).",
    ["Vérifier VIP / Gamepasses"] = "Affiche les infos du jeu et tes passes.",
    ["Voir mon argent"] = "Affiche tes valeurs (leaderstats + PlayerGui).",
    ["Product Faker V2"] = "Simule des achats (gamepass/product) pour les obtenir gratuitement.",
    ["Product Faker Simple"] = "Version simple et légère du Product Faker.",

    -- PARAMÈTRES
    ["Notifications ON/OFF"] = "Active/désactive les pop-ups de notification.",
    ["Taille : Petite"] = "Réduit la fenêtre à 75%.",
    ["Taille : Moyenne"] = "Taille normale (100%).",
    ["Taille : Grande"] = "Agrandit la fenêtre à 125%.",
    ["Fond : Dégradé rouge"] = "Fond avec dégradé rouge/violet.",
    ["Fond : Transparent"] = "Fond transparent (voit le jeu derrière).",
    ["Recentrer l'interface"] = "Remet la fenêtre au centre de l'écran.",
    ["Leaderstat : nom"] = "Change le nom de la stat à modifier.",
    ["Leaderstat : valeur"] = "Change la valeur d'une stat.",
    ["Property Modifier"] = "Modifie n'importe quelle propriété d'un objet.",
    ["Debug Console Lua"] = "Exécute du code Lua personnalisé.",
}

-- ============================================================
-- CONSTRUCTION DE L'ONGLET DESCRIPTIONS
-- ============================================================
function VAZ.BuildDescriptionsTab(ui)
    ui:AddTab("info", "Descriptions")

    -- Grouper par catégorie
    local categories = {
        {name = "Armes", keys = {"zizi Tranchant", "Micha Minivichi", "Loucybel_Facher", "istadyxx26", "Épées orbitales"}},
        {name = "Mouvement", keys = {"Vol (Fly)", "Noclip", "Téléport (T)", "Freecam (ZQSD)", "Spectate joueur", "TP Coordonnées", "Vitesse de marche", "Vitesse de vol"}},
        {name = "Combat", keys = {"Tuer tous", "Aimbot", "Wallhack / ESP", "Clone", "Freeze All", "Unfreeze All", "Ragdoll All", "Goto joueur", "Bring joueur", "Freeze joueur", "Kick All", "Kick un joueur", "Sin Dragon", "Sin Dragon (New)", "Join Empty Server"}},
        {name = "Divers", keys = {"Godmode", "Invisibilité", "Auto-click", "Anti-AFK", "Particules", "FullBright", "Heal (toi)", "Heal joueur", "Générer voiture", "Heure locale", "Gravité"}},
        {name = "Effets", keys = {"Décal", "Skybox c00lkidd", "Particules c00lkidd", "Son goofy ahh", "Kill All (Effet)", "Toadroast", "Nachos", "666", "Shedletsky"}},
        {name = "RSPY / Dex", keys = {"Charger Dex", "Charger Remote Spy", "Lister tous les remotes", "Auto-Farm", "Auto-Collect", "Récupérer tous les outils", "Récupérer les drops", "Vérifier VIP / Gamepasses", "Voir mon argent", "Product Faker V2", "Product Faker Simple"}},
        {name = "Paramètres", keys = {"Notifications ON/OFF", "Taille : Petite", "Taille : Moyenne", "Taille : Grande", "Fond : Dégradé rouge", "Fond : Transparent", "Recentrer l'interface", "Leaderstat : nom", "Leaderstat : valeur", "Property Modifier", "Debug Console Lua"}},
    }

    for _, cat in ipairs(categories) do
        for _, key in ipairs(cat.keys) do
            local desc = DESCRIPTIONS[key] or "Aucune description disponible."
            ui:AddModule("info", "Descriptions", {
                name = "[" .. cat.name .. "] " .. key,
                desc = desc,
                callback = function() end
            })
        end
    end
end

print("✅ Partie 13/13 chargée - Descriptions des mods")
