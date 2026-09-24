-- PARTIE 1/4 - Interface Vaztoodix UI v3 (version unique)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")

-- Nettoyage
if getgenv and getgenv().VAZTOODIXUI_CLEANUP then
    pcall(getgenv().VAZTOODIXUI_CLEANUP)
end

local CONNS = {}
local function keep(c) table.insert(CONNS, c) return c end

if getgenv then
    getgenv().VAZTOODIXUI_CLEANUP = function()
        for _, c in ipairs(CONNS) do pcall(function() c:Disconnect() end) end
        table.clear(CONNS)
    end
end

-- Lucide
local Lucide
pcall(function()
    Lucide = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/lucide-roblox-direct/refs/heads/main/source.lua"))()
end)

-- Thème unique (glassmorphism + dégradé violet)
local T = {
    bg1 = Color3.fromRGB(20, 15, 35),
    bg2 = Color3.fromRGB(35, 20, 60),
    bg3 = Color3.fromRGB(15, 10, 25),
    accent = Color3.fromRGB(140, 80, 255),
    accent2 = Color3.fromRGB(255, 100, 200),
    accent3 = Color3.fromRGB(80, 200, 255),
    glass = Color3.fromRGB(255, 255, 255),
    text = Color3.fromRGB(255, 255, 255),
    sub = Color3.fromRGB(180, 180, 200),
    dim = Color3.fromRGB(120, 120, 140),
    card = Color3.fromRGB(40, 30, 65),
    cardHover = Color3.fromRGB(55, 40, 90),
    stroke = Color3.fromRGB(100, 70, 180),
    success = Color3.fromRGB(80, 220, 120),
    danger = Color3.fromRGB(255, 80, 100),
}

local FONT_BOLD = Enum.Font.GothamBold
local FONT = Enum.Font.Gotham
local FONT_REG = Enum.Font.Gotham

local function new(c, p)
    local o = Instance.new(c)
    for k, v in pairs(p or {}) do o[k] = v end
    return o
end

local function tw(o, d, p, style, dir)
    return TweenService:Create(o, TweenInfo.new(d, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), p)
end

local function text(p)
    local d = {
        BackgroundTransparency = 1,
        TextColor3 = T.text,
        TextSize = 14,
        Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }
    for k, v in pairs(p or {}) do d[k] = v end
    return new("TextLabel", d)
end

local iconCache = {}
local function setIcon(im, name)
    local a = iconCache[name]
    if a == nil then
        a = (Lucide and Lucide.GetAsset(name)) or false
        iconCache[name] = a
    end
    if a then
        im.Image = a.Url
        im.ImageRectOffset = a.ImageRectOffset
        im.ImageRectSize = a.ImageRectSize
    end
    return im
end

local function icon(name, p)
    local d = {
        BackgroundTransparency = 1,
        ImageColor3 = T.dim,
        Size = UDim2.fromOffset(24, 24)
    }
    for k, v in pairs(p or {}) do d[k] = v end
    return setIcon(new("ImageLabel", d), name)
end

-- Effet de flou (Blur)
local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting
local function setBlur(size)
    tw(blur, 0.3, { Size = size }):Play()
end

-- ===== CLASSE UI =====
local VaztoodixUI = {}
VaztoodixUI.__index = VaztoodixUI

function VaztoodixUI.new(cfg)
    cfg = cfg or {}
    local self = setmetatable({}, VaztoodixUI)
    self.cfg = cfg
    self.categories = {}
    self.activeCategory = nil
    self.activeTab = nil
    self.featureCount = 0
    self.featureList = {}
    self.statusList = {}
    self.glowing = true

    local mount = game:GetService("CoreGui")
    if getgenv and getgenv().__vaztoodix_gui then
        pcall(function() getgenv().__vaztoodix_gui:Destroy() end)
    end

    self.gui = new("ScreenGui", {
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    pcall(function() protect(self.gui) end)
    self.gui.Parent = mount

    if getgenv then
        getgenv().__vaztoodix_gui = self.gui
        getgenv().VAZTOODIXUI = self
    end

    local W, H = cfg.Width or 780, cfg.Height or 520

    -- ===== FENÊTRE PRINCIPALE (coins arrondis + glass) =====
    self.root = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(W, H),
        BackgroundColor3 = T.bg1,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = self.gui,
    })
    local rootCorner = Instance.new("UICorner")
    rootCorner.CornerRadius = UDim.new(0, 20)
    rootCorner.Parent = self.root

    local rootGrad = Instance.new("UIGradient")
    rootGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, T.bg1),
        ColorSequenceKeypoint.new(0.5, T.bg2),
        ColorSequenceKeypoint.new(1, T.bg3),
    })
    rootGrad.Rotation = 45
    rootGrad.Parent = self.root

    local rootStroke = Instance.new("UIStroke")
    rootStroke.Color = T.accent
    rootStroke.Thickness = 1.5
    rootStroke.Transparency = 0.3
    rootStroke.Parent = self.root

    -- Animation d'ouverture (scale + rotation)
    self.root.Size = UDim2.fromOffset(1, 1)
    self.root.Rotation = 15
    tw(self.root, 0.4, { Size = UDim2.fromOffset(W, H), Rotation = 0 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()
    setBlur(8)

    -- ===== BARRE SUPÉRIEURE (logo + horloge + compteur) =====
    local topBar = new("Frame", {
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundColor3 = T.bg3,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = self.root,
    })
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 20)
    topCorner.Parent = topBar

    -- LOGO ANIMÉ "VAZTOODIX"
    self.logo = text({
        Text = "VAZTOODIX ™",
        Font = FONT_BOLD,
        TextSize = 22,
        TextColor3 = T.accent,
        Position = UDim2.fromOffset(20, 0),
        Size = UDim2.fromOffset(200, 55),
        ZIndex = 4,
        Parent = topBar,
    })
    -- Animation de brillance
    task.spawn(function()
        while self.glowing do
            for i = 0, 1, 0.05 do
                self.logo.TextColor3 = T.accent:Lerp(T.accent2, i)
                task.wait(0.05)
            end
            for i = 0, 1, 0.05 do
                self.logo.TextColor3 = T.accent2:Lerp(T.accent, i)
                task.wait(0.05)
            end
        end
    end)

    -- HORLOGE
    self.clock = text({
        Text = "00:00:00",
        Font = FONT_BOLD,
        TextSize = 16,
        TextColor3 = T.text,
        Position = UDim2.new(0.5, -50, 0, 0),
        Size = UDim2.fromOffset(100, 55),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 4,
        Parent = topBar,
    })
    task.spawn(function()
        while self.glowing do
            self.clock.Text = os.date("%H:%M:%S")
            task.wait(1)
        end
    end)

    -- COMPTEUR DE FONCTIONNALITÉS
    self.counter = text({
        Text = "0 active",
        Font = FONT_BOLD,
        TextSize = 14,
        TextColor3 = T.success,
        Position = UDim2.new(1, -180, 0, 0),
        Size = UDim2.fromOffset(120, 55),
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 4,
        Parent = topBar,
    })

    -- BOUTON FERMER (animation repli)
    local closeBtn = new("TextButton", {
        Size = UDim2.fromOffset(35, 35),
        Position = UDim2.new(1, -50, 0, 10),
        BackgroundColor3 = T.danger,
        BackgroundTransparency = 0.7,
        Text = "",
        ZIndex = 4,
        Parent = topBar,
    })
    Instance.new("UICorner").CornerRadius = UDim.new(0, 10)
    local closeIcon = icon("x", {
        Size = UDim2.fromOffset(18, 18),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ImageColor3 = T.text,
        ZIndex = 5,
        Parent = closeBtn,
    })
    closeBtn.MouseEnter:Connect(function() tw(closeBtn, 0.1, { BackgroundTransparency = 0.3 }):Play() end)
    closeBtn.MouseLeave:Connect(function() tw(closeBtn, 0.1, { BackgroundTransparency = 0.7 }):Play() end)
    closeBtn.MouseButton1Click:Connect(function()
        self.glowing = false
        setBlur(0)
        tw(self.root, 0.3, {
            Size = UDim2.fromOffset(1, 1),
            Rotation = -30,
            Position = UDim2.new(1, 0, 0, 0),
        }, Enum.EasingStyle.Back, Enum.EasingDirection.In):Play()
        task.wait(0.3)
        self.gui:Destroy()
        if getgenv then getgenv().VAZTOODIXUI = nil end
    end)

    -- ===== SIDEBAR VERTICALE (icônes uniquement) =====
    local sidebar = new("Frame", {
        Size = UDim2.fromOffset(70, H - 55 - 40),
        Position = UDim2.fromOffset(0, 55),
        BackgroundColor3 = T.bg3,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = self.root,
    })

    self.sidebarButtons = {}
    local sidebarIcons = {
        { name = "home", tooltip = "Accueil" },
        { name = "sword", tooltip = "Armes" },
        { name = "move", tooltip = "Mouvement" },
        { name = "crosshair", tooltip = "Combat" },
        { name = "settings", tooltip = "Utilitaires" },
        { name = "info", tooltip = "Crédits" },
    }
    local sideY = 10
    for i, item in ipairs(sidebarIcons) do
        local btn = new("TextButton", {
            Size = UDim2.fromOffset(50, 50),
            Position = UDim2.fromOffset(10, sideY),
            BackgroundColor3 = T.card,
            BackgroundTransparency = 0.5,
            Text = "",
            ZIndex = 4,
            Parent = sidebar,
        })
        Instance.new("UICorner").CornerRadius = UDim.new(0, 12)
        local im = icon(item.name, {
            Size = UDim2.fromOffset(24, 24),
            Position = UDim2.fromScale(0.5, 0.5),
            AnchorPoint = Vector2.new(0.5, 0.5),
            ImageColor3 = T.sub,
            ZIndex = 5,
            Parent = btn,
        })
        btn.MouseEnter:Connect(function()
            tw(btn, 0.1, { BackgroundTransparency = 0.2, BackgroundColor3 = T.accent }):Play()
            tw(im, 0.1, { ImageColor3 = T.text }):Play()
            tw(btn, 0.1, { Size = UDim2.fromOffset(55, 55) }):Play()
        end)
        btn.MouseLeave:Connect(function()
            if self.activeCategory ~= item.name then
                tw(btn, 0.1, { BackgroundTransparency = 0.5, BackgroundColor3 = T.card }):Play()
                tw(im, 0.1, { ImageColor3 = T.sub }):Play()
            end
            tw(btn, 0.1, { Size = UDim2.fromOffset(50, 50) }):Play()
        end)
        btn.MouseButton1Click:Connect(function()
            self:SetCategory(item.name)
            -- Effet de pulsation
            local pulse = tw(btn, 0.15, { Size = UDim2.fromOffset(60, 60) })
            pulse:Play()
            pulse.Completed:Connect(function()
                tw(btn, 0.15, { Size = UDim2.fromOffset(50, 50) }):Play()
            end)
        end)
        self.sidebarButtons[item.name] = { btn = btn, icon = im, tooltip = item.tooltip }
        sideY = sideY + 58
    end

    -- ===== ZONE DE CONTENU =====
    local contentArea = new("Frame", {
        Size = UDim2.new(1, -80, 1, -95),
        Position = UDim2.fromOffset(80, 55),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = self.root,
    })

    self.scroll = new("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -40),
        Position = UDim2.fromOffset(10, 10),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = T.accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 3,
        Parent = contentArea,
    })
    local grid = new("UIGridLayout", {
        CellSize = UDim2.fromOffset(200, 90),
        CellPadding = UDim2.fromOffset(10, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.scroll,
    })

    -- ===== ONGLETS EN BAS (style mobile) =====
    local bottomTabs = new("Frame", {
        Size = UDim2.new(1, -80, 0, 40),
        Position = UDim2.new(0, 80, 1, -40),
        BackgroundColor3 = T.bg3,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = self.root,
    })
    local tabsLayout = new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 10),
        Parent = bottomTabs,
    })
    self.bottomTabsFrame = bottomTabs

    -- ===== BARRE DE STATUT EN BAS =====
    local statusBar = new("Frame", {
        Size = UDim2.new(1, -80, 0, 20),
        Position = UDim2.new(0, 80, 1, -20),
        BackgroundColor3 = T.bg3,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = self.root,
    })
    self.statusLabel = text({
        Text = "Prêt",
        Font = FONT,
        TextSize = 12,
        TextColor3 = T.sub,
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -20, 1, 0),
        ZIndex = 4,
        Parent = statusBar,
    })

    -- ===== MÉTHODES =====
    function self:UpdateCounter()
        local active = 0
        for _, v in pairs(self.statusList) do
            if v then active = active + 1 end
        end
        self.featureCount = active
        self.counter.Text = active .. " active"
        self.counter.TextColor3 = (active > 0) and T.success or T.dim
    end

    function self:UpdateStatus()
        local parts = {}
        for name, state in pairs(self.statusList) do
            table.insert(parts, name .. ": " .. (state and "ON" or "OFF"))
        end
        self.statusLabel.Text = (#parts > 0) and table.concat(parts, " | ") or "Prêt"
    end

    function self:SetCategory(name)
        self.activeCategory = name
        for cat, data in pairs(self.sidebarButtons) do
            if cat == name then
                tw(data.btn, 0.15, { BackgroundColor3 = T.accent, BackgroundTransparency = 0.2 }):Play()
                tw(data.icon, 0.15, { ImageColor3 = T.text }):Play()
            else
                tw(data.btn, 0.15, { BackgroundColor3 = T.card, BackgroundTransparency = 0.5 }):Play()
                tw(data.icon, 0.15, { ImageColor3 = T.sub }):Play()
            end
        end
        self:RefreshTabs()
    end

    function self:AddCategory(name) end -- déjà géré par sidebar

    function self:AddTab(category, tabName)
        if not self.categories[category] then
            self.categories[category] = { tabs = {}, currentTab = tabName }
        end
        table.insert(self.categories[category].tabs, { name = tabName, modules = {} })
        if not self.categories[category].currentTab then
            self.categories[category].currentTab = tabName
        end
        self:RefreshTabs()
    end

    function self:RefreshTabs()
        for _, child in ipairs(self.bottomTabsFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local cat = self.categories[self.activeCategory]
        if not cat then return end
        for _, tab in ipairs(cat.tabs) do
            local btn = new("TextButton", {
                Size = UDim2.fromOffset(120, 30),
                BackgroundColor3 = (tab.name == cat.currentTab) and T.accent or T.card,
                BackgroundTransparency = (tab.name == cat.currentTab) and 0.2 or 0.6,
                Text = tab.name,
                TextColor3 = T.text,
                Font = FONT_BOLD,
                TextSize = 12,
                ZIndex = 4,
                Parent = self.bottomTabsFrame,
                AutoButtonColor = false,
            })
            Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
            btn.MouseEnter:Connect(function()
                tw(btn, 0.1, { BackgroundTransparency = 0.2 }):Play()
                tw(btn, 0.1, { Size = UDim2.fromOffset(125, 32) }):Play()
            end)
            btn.MouseLeave:Connect(function()
                tw(btn, 0.1, { BackgroundTransparency = (tab.name == cat.currentTab) and 0.2 or 0.6 }):Play()
                tw(btn, 0.1, { Size = UDim2.fromOffset(120, 30) }):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                cat.currentTab = tab.name
                self.activeTab = tab.name
                self:RefreshTabs()
                self:RenderModules()
            end)
        end
    end

    function self:SetTab(category, tabName)
        local cat = self.categories[category]
        if cat then cat.currentTab = tabName end
        self.activeTab = tabName
        self:RefreshTabs()
        self:RenderModules()
    end

    function self:RenderModules()
        for _, child in ipairs(self.scroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        local cat = self.categories[self.activeCategory]
        if not cat then return end
        local tab
        for _, t in ipairs(cat.tabs) do
            if t.name == cat.currentTab then tab = t break end
        end
        if not tab then return end

        local count = 0
        for _, mod in ipairs(tab.modules) do
            count = count + 1
            local card = new("TextButton", {
                BackgroundColor3 = T.card,
                BackgroundTransparency = 0.2,
                Text = "",
                ZIndex = 3,
                Parent = self.scroll,
                AutoButtonColor = false,
                LayoutOrder = count,
            })
            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 12)
            cardCorner.Parent = card
            local cardStroke = Instance.new("UIStroke")
            cardStroke.Color = T.stroke
            cardStroke.Thickness = 1
            cardStroke.Transparency = 0.5
            cardStroke.Parent = card

            text({
                Text = mod.name,
                Font = FONT_BOLD,
                TextSize = 14,
                TextColor3 = T.text,
                Position = UDim2.fromOffset(12, 10),
                Size = UDim2.new(1, -24, 0, 20),
                ZIndex = 4,
                Parent = card,
            })
            if mod.desc then
                text({
                    Text = mod.desc,
                    Font = FONT_REG,
                    TextSize = 10,
                    TextColor3 = T.sub,
                    Position = UDim2.fromOffset(12, 32),
                    Size = UDim2.new(1, -24, 0, 30),
                    TextWrapped = true,
                    ZIndex = 4,
                    Parent = card,
                })
            end
            -- Indicateur ON/OFF (cercle coloré)
            local dot = new("Frame", {
                Size = UDim2.fromOffset(12, 12),
                Position = UDim2.new(1, -20, 0, 12),
                BackgroundColor3 = T.dim,
                ZIndex = 4,
                Parent = card,
            })
            Instance.new("UICorner").CornerRadius = UDim.new(1, 0)

            -- Hover + clic
            card.MouseEnter:Connect(function()
                tw(card, 0.15, { Size = UDim2.fromOffset(210, 95), BackgroundTransparency = 0 }):Play()
                tw(cardStroke, 0.15, { Transparency = 0.2, Color = T.accent }):Play()
            end)
            card.MouseLeave:Connect(function()
                tw(card, 0.15, { Size = UDim2.fromOffset(200, 90), BackgroundTransparency = 0.2 }):Play()
                tw(cardStroke, 0.15, { Transparency = 0.5, Color = T.stroke }):Play()
            end)
            card.MouseButton1Click:Connect(function()
                -- Pulsation
                local pulse = tw(card, 0.1, { Size = UDim2.fromOffset(190, 85) })
                pulse:Play()
                pulse.Completed:Connect(function()
                    tw(card, 0.15, { Size = UDim2.fromOffset(200, 90) }):Play()
                end)

                if mod.callback then
                    pcall(mod.callback)
                end
                -- Mettre à jour l'indicateur si c'est un toggle
                if mod.toggle then
                    local state = not self.statusList[mod.name]
                    self.statusList[mod.name] = state
                    dot.BackgroundColor3 = state and T.success or T.dim
                    self:UpdateCounter()
                    self:UpdateStatus()
                end
            end)
            if mod.default then
                self.statusList[mod.name] = true
                dot.BackgroundColor3 = T.success
            end
        end
        self.scroll.CanvasSize = UDim2.new(0, 0, 0, math.ceil(count / 3) * 100 + 20)
        self:UpdateCounter()
    end

    function self:AddModule(category, tabName, mod)
        if not self.categories[category] then
            self.categories[category] = { tabs = {}, currentTab = tabName }
        end
        local found = false
        for _, t in ipairs(self.categories[category].tabs) do
            if t.name == tabName then
                table.insert(t.modules, mod)
                found = true
                break
            end
        end
        if not found then
            table.insert(self.categories[category].tabs, { name = tabName, modules = { mod } })
        end
        self:RenderModules()
    end

    function self:Notify(msg)
        local notif = text({
            Text = msg,
            Font = FONT_BOLD,
            TextSize = 14,
            TextColor3 = T.text,
            Size = UDim2.fromOffset(300, 40),
            Position = UDim2.new(0.5, -150, 0, -50),
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 10,
            Parent = self.root,
        })
        local nbg = new("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = T.accent,
            BackgroundTransparency = 0.2,
            ZIndex = -1,
            Parent = notif,
        })
        Instance.new("UICorner").CornerRadius = UDim.new(0, 8)
        tw(notif, 0.3, { Position = UDim2.new(0.5, -150, 0, 20) }):Play()
        task.wait(2)
        tw(notif, 0.3, { Position = UDim2.new(0.5, -150, 0, -50) }):Play()
        task.wait(0.3)
        notif:Destroy()
    end

    -- Menu radial (bouton central)
    local radialBtn = new("TextButton", {
        Size = UDim2.fromOffset(50, 50),
        Position = UDim2.new(1, -70, 1, -70),
        BackgroundColor3 = T.accent,
        BackgroundTransparency = 0.2,
        Text = "",
        ZIndex = 6,
        Parent = self.root,
    })
    Instance.new("UICorner").CornerRadius = UDim.new(1, 0)
    icon("plus", {
        Size = UDim2.fromOffset(24, 24),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ImageColor3 = T.text,
        ZIndex = 7,
        Parent = radialBtn,
    })
    radialBtn.MouseButton1Click:Connect(function()
        self:Notify("Fonctionnalités actives : " .. self.featureCount)
    end)

    -- Initialisation
    task.defer(function()
        self:SetCategory("home")
    end)

    return self
end

_G.VaztoodixUI = VaztoodixUI
print("✅ Partie 1/4 chargée - Interface Vaztoodix UI v3 (glass + radial + bottom tabs)")