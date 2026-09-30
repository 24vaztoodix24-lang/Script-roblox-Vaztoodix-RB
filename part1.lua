-- PARTIE 1/4 - Interface Vaztoodix UI v10 (recherche globale + contour vert Sin Dragon)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local p = Players.LocalPlayer

if getgenv and getgenv().VAZTOODIXUI_CLEANUP then
    pcall(getgenv().VAZTOODIXUI_CLEANUP)
end

local CONNS = {}
if getgenv then
    getgenv().VAZTOODIXUI_CLEANUP = function()
        for _, c in ipairs(CONNS) do pcall(function() c:Disconnect() end) end
        table.clear(CONNS)
    end
end

local LOGO_IMAGE = "rbxassetid://85524155379948"

local T = {
    bg1 = Color3.fromRGB(35, 10, 25),
    bg2 = Color3.fromRGB(60, 15, 40),
    bg3 = Color3.fromRGB(15, 5, 15),
    accent = Color3.fromRGB(180, 30, 80),
    accent2 = Color3.fromRGB(255, 100, 50),
    accent3 = Color3.fromRGB(140, 80, 255),
    text = Color3.fromRGB(255, 255, 255),
    sub = Color3.fromRGB(220, 200, 210),
    dim = Color3.fromRGB(150, 130, 140),
    card = Color3.fromRGB(60, 20, 45),
    stroke = Color3.fromRGB(160, 50, 90),
    success = Color3.fromRGB(80, 220, 120),
    danger = Color3.fromRGB(255, 80, 100),
    textbox = Color3.fromRGB(30, 10, 25),
    green = Color3.fromRGB(0, 255, 0),
}

local FONT_BOLD = Enum.Font.GothamBold
local FONT = Enum.Font.Gotham

local function new(c, props)
    local o = Instance.new(c)
    for k, v in pairs(props or {}) do o[k] = v end
    return o
end

local function tw(o, d, props, style, dir)
    return TweenService:Create(o, TweenInfo.new(d, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
end

local function text(props)
    local d = { BackgroundTransparency = 1, TextColor3 = T.text, TextSize = 10, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center }
    for k, v in pairs(props or {}) do d[k] = v end
    return new("TextLabel", d)
end

local VaztoodixUI = {}
VaztoodixUI.__index = VaztoodixUI

function VaztoodixUI.new(cfg)
    cfg = cfg or {}
    local self = setmetatable({}, VaztoodixUI)
    self.categories = {}
    self.activeCategory = nil
    self.statusList = {}
    self.toggleCircle = nil
    self.glowing = true
    self.uiScale = 1
    self.bgMode = 1
    self.searchMode = false

    local mount = game:GetService("CoreGui")
    if getgenv and getgenv().__vaztoodix_gui then pcall(function() getgenv().__vaztoodix_gui:Destroy() end) end

    self.gui = new("ScreenGui", { ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
    pcall(function() protect(self.gui) end)
    self.gui.Parent = mount
    if getgenv then getgenv().__vaztoodix_gui = self.gui getgenv().VAZTOODIXUI = self end

    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
    local inset = GuiService:GetGuiInset()
    local W = math.min(720, vp.X - 60)
    local H = math.min(500, vp.Y - inset.Y - 60)

    self.bgFrame = new("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = T.bg1,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        ZIndex = 1,
        Parent = self.gui,
    })

    self.root = new("Frame", {
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.new(0.5, -W/2, 0.5, -H/2 + inset.Y/2),
        Size = UDim2.fromOffset(W, H),
        BackgroundColor3 = T.bg1,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Active = true,
        Draggable = true,
        ZIndex = 2,
        Parent = self.gui,
    })
    Instance.new("UICorner", self.root).CornerRadius = UDim.new(0, 20)
    self.rootGrad = Instance.new("UIGradient")
    self.rootGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, T.bg1),
        ColorSequenceKeypoint.new(0.35, T.accent),
        ColorSequenceKeypoint.new(0.6, T.accent2),
        ColorSequenceKeypoint.new(1, T.bg3),
    })
    self.rootGrad.Rotation = 45
    self.rootGrad.Parent = self.root
    local rootStroke = Instance.new("UIStroke")
    rootStroke.Color = T.accent rootStroke.Thickness = 1.5 rootStroke.Transparency = 0.3
    rootStroke.Parent = self.root

    self.root.Size = UDim2.fromOffset(1, 1)
    self.root.Rotation = 15
    tw(self.root, 0.4, { Size = UDim2.fromOffset(W, H), Rotation = 0 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()

    local topBar = new("Frame", {
        Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = T.bg3, BackgroundTransparency = 0.4,
        BorderSizePixel = 0, ZIndex = 3, Parent = self.root,
    })
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 20)

    new("ImageLabel", { Image = LOGO_IMAGE, BackgroundTransparency = 1, Size = UDim2.fromOffset(38, 38), Position = UDim2.fromOffset(8, 4), ZIndex = 4, Parent = topBar })

    self.clock = text({ Text = "00:00:00", Font = FONT_BOLD, TextSize = 13, TextColor3 = T.text, Position = UDim2.new(0.5, -50, 0, 0), Size = UDim2.fromOffset(100, 46), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 4, Parent = topBar })
    task.spawn(function() while self.glowing do self.clock.Text = os.date("%H:%M:%S") task.wait(1) end end)

    self.counter = text({ Text = "0 actif", Font = FONT_BOLD, TextSize = 11, TextColor3 = T.dim, Position = UDim2.new(1, -210, 0, 0), Size = UDim2.fromOffset(130, 46), TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 4, Parent = topBar })

    local minimizeBtn = new("TextButton", {
        Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -110, 0, 9),
        BackgroundColor3 = Color3.fromRGB(120, 40, 60), BackgroundTransparency = 0.3,
        Text = "—", TextColor3 = T.text, TextSize = 18, Font = FONT_BOLD, ZIndex = 4, Parent = topBar,
    })
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)

    minimizeBtn.MouseButton1Click:Connect(function()
        self.root.Visible = false
        if not self.toggleCircle or not self.toggleCircle.Parent then
            local toggleGui = new("ScreenGui", { Name = "VaztoodixToggle", ResetOnSpawn = false, Parent = p:WaitForChild("PlayerGui") })
            local circle = new("ImageButton", {
                Size = UDim2.fromOffset(56, 56), Position = UDim2.new(0.02, 0, 0.75, 0),
                BackgroundColor3 = Color3.fromRGB(80, 20, 40), BackgroundTransparency = 0.2,
                BorderSizePixel = 0, Image = LOGO_IMAGE, ZIndex = 10, Parent = toggleGui,
            })
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
            local stroke = Instance.new("UIStroke") stroke.Color = T.accent2 stroke.Thickness = 2 stroke.Transparency = 0.2 stroke.Parent = circle
            local dragging, dragInput, dragStart, startPos, dragMoved = false, nil, nil, nil, false
            circle.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging, dragMoved, dragStart, startPos = true, false, input.Position, circle.Position end end)
            circle.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
            circle.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input == dragInput then
                    local delta = input.Position - dragStart
                    if delta.Magnitude > 5 then dragMoved = true end
                    circle.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
            circle.MouseButton1Click:Connect(function()
                if not dragMoved then self.root.Visible = true toggleGui:Destroy() self.toggleCircle = nil end
            end)
            self.toggleCircle = circle
        end
    end)

    local closeBtn = new("TextButton", {
        Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -42, 0, 9),
        BackgroundColor3 = T.danger, BackgroundTransparency = 0.5, Text = "✕", TextColor3 = T.text,
        TextSize = 14, Font = FONT_BOLD, ZIndex = 4, Parent = topBar,
    })
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.MouseButton1Click:Connect(function()
        self.glowing = false
        tw(self.root, 0.3, { Size = UDim2.fromOffset(1, 1), Rotation = -30, Position = UDim2.new(1, 0, 0, 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.In):Play()
        task.wait(0.3)
        self.gui:Destroy()
        if self.toggleCircle then self.toggleCircle.Parent:Destroy() end
        if getgenv then getgenv().VAZTOODIXUI = nil end
    end)

    local sidebarH = H - 46 - 22 - 14
    local sidebar = new("Frame", { Size = UDim2.fromOffset(48, sidebarH), Position = UDim2.fromOffset(0, 46), BackgroundColor3 = T.bg3, BackgroundTransparency = 0.5, BorderSizePixel = 0, ZIndex = 3, Parent = self.root })
    local sidebarScroll = new("ScrollingFrame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = T.accent, CanvasSize = UDim2.new(0, 0, 0, 0), ZIndex = 4, Parent = sidebar })
    new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = sidebarScroll })

    self.sidebarButtons = {}
    local sidebarIcons = {
        { name = "home", emoji = "🏠" },
        { name = "sword", emoji = "⚔️" },
        { name = "move", emoji = "🏃" },
        { name = "crosshair", emoji = "🎯" },
        { name = "divers", emoji = "🎮" },
        { name = "sparkles", emoji = "✨" },
        { name = "settings", emoji = "⚙️" },
        { name = "info", emoji = "ℹ️" },
    }
    for i, item in ipairs(sidebarIcons) do
        local btn = new("TextButton", { Size = UDim2.fromOffset(34, 34), BackgroundColor3 = T.card, BackgroundTransparency = 0.4, Text = item.emoji, TextSize = 20, Font = FONT_BOLD, ZIndex = 4, Parent = sidebarScroll, LayoutOrder = i })
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btn.MouseEnter:Connect(function() tw(btn, 0.1, { BackgroundTransparency = 0.1, BackgroundColor3 = T.accent }):Play() end)
        btn.MouseLeave:Connect(function() if self.activeCategory ~= item.name then tw(btn, 0.1, { BackgroundTransparency = 0.4, BackgroundColor3 = T.card }):Play() end end)
        btn.MouseButton1Click:Connect(function() self:SetCategory(item.name) end)
        self.sidebarButtons[item.name] = { btn = btn, emoji = item.emoji }
    end
    sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, #sidebarIcons * 37 + 8)

    local contentX = 53
    local contentW = W - contentX - 8
    local contentH = H - 46 - 22 - 14
    local contentArea = new("Frame", { Size = UDim2.fromOffset(contentW, contentH), Position = UDim2.fromOffset(contentX, 46), BackgroundTransparency = 1, ZIndex = 3, Parent = self.root })

    self.catTitle = text({
        Text = "🏠 Accueil",
        Font = FONT_BOLD, TextSize = 14, TextColor3 = T.text,
        Position = UDim2.fromOffset(8, 5), Size = UDim2.new(1, -16, 0, 18),
        ZIndex = 4, Parent = contentArea,
    })
    self.catDesc = text({
        Text = "Bienvenue sur Vaztoodix",
        Font = FONT, TextSize = 10, TextColor3 = T.sub,
        Position = UDim2.fromOffset(8, 22), Size = UDim2.new(1, -16, 0, 12),
        ZIndex = 4, Parent = contentArea,
    })

    self.searchBar = new("Frame", {
        Size = UDim2.new(1, -16, 0, 22),
        Position = UDim2.fromOffset(8, 38),
        BackgroundColor3 = T.textbox,
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = contentArea,
    })
    Instance.new("UICorner", self.searchBar).CornerRadius = UDim.new(0, 6)
    local searchStroke = Instance.new("UIStroke")
    searchStroke.Color = T.stroke
    searchStroke.Thickness = 1
    searchStroke.Transparency = 0.4
    searchStroke.Parent = self.searchBar

    self.searchBox = new("TextBox", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.fromOffset(8, 0),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = T.text,
        Font = FONT,
        TextSize = 10,
        PlaceholderText = "🔍 Rechercher dans toutes les catégories...",
        PlaceholderColor3 = T.dim,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 5,
        Parent = self.searchBar,
    })

    self.scroll = new("ScrollingFrame", {
        Size = UDim2.new(1, -6, 1, -70),
        Position = UDim2.fromOffset(3, 64),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 6, ScrollBarImageColor3 = T.accent,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 3, Parent = contentArea,
    })

    self.gridNormal = new("UIGridLayout", {
        CellSize = UDim2.fromOffset(130, 56),
        CellPadding = UDim2.fromOffset(6, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.scroll,
    })

    local bottomTabs = new("Frame", {
        Size = UDim2.new(1, -53, 0, 20), Position = UDim2.new(0, 53, 1, -23),
        BackgroundColor3 = T.bg3, BackgroundTransparency = 0.6, BorderSizePixel = 0, ZIndex = 3, Parent = self.root,
    })
    new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 4), Parent = bottomTabs })
    self.bottomTabsFrame = bottomTabs

    local statusBar = new("Frame", {
        Size = UDim2.new(1, -53, 0, 14), Position = UDim2.new(0, 53, 1, -14),
        BackgroundColor3 = T.bg3, BackgroundTransparency = 0.7, BorderSizePixel = 0, ZIndex = 3, Parent = self.root,
    })
    self.statusLabel = text({ Text = "Prêt", Font = FONT, TextSize = 9, TextColor3 = T.sub, Position = UDim2.fromOffset(6, 0), Size = UDim2.new(1, -12, 1, 0), ZIndex = 4, Parent = statusBar })

    local CAT_INFO = {
        home = { title = "🏠 Accueil", desc = "Bienvenue sur Vaztoodix ™" },
        sword = { title = "⚔️ Armes", desc = "Armes 1-hit et épées" },
        move = { title = "🏃 Mouvement", desc = "Fly, Speed, Jump, Noclip" },
        crosshair = { title = "🎯 Combat / PvP", desc = "Aimbot, ESP, Kill All" },
        divers = { title = "🎮 Divers", desc = "Godmode, Invisible, Gravité" },
        sparkles = { title = "✨ Effets", desc = "20 effets c00lgui" },
        settings = { title = "⚙️ Paramètres", desc = "Taille, Fond, Notifications" },
        info = { title = "ℹ️ Crédits", desc = "Antonio, Micha, Ismaël, DeepSeek" },
    }

    function self:UpdateCounter()
        local active = 0
        for _, v in pairs(self.statusList) do if v then active = active + 1 end end
        self.counter.Text = active .. " actif"
        self.counter.TextColor3 = (active > 0) and T.success or T.dim
    end

    function self:UpdateStatus()
        local parts = {}
        for name, state in pairs(self.statusList) do table.insert(parts, name .. ": " .. (state and "ON" or "OFF")) end
        self.statusLabel.Text = (#parts > 0) and table.concat(parts, " | ") or "Prêt"
    end

    function self:SetCategory(name)
        self.activeCategory = name
        for cat, data in pairs(self.sidebarButtons) do
            if cat == name then tw(data.btn, 0.15, { BackgroundColor3 = T.accent, BackgroundTransparency = 0.1 }):Play()
            else tw(data.btn, 0.15, { BackgroundColor3 = T.card, BackgroundTransparency = 0.4 }):Play() end
        end
        local info = CAT_INFO[name] or { title = name, desc = "" }
        self.catTitle.Text = info.title
        self.catDesc.Text = info.desc
        self:RefreshTabs()
        self:RenderModules()
    end

    function self:AddTab(category, tabName)
        if not self.categories[category] then self.categories[category] = { tabs = {}, currentTab = tabName } end
        table.insert(self.categories[category].tabs, { name = tabName, modules = {} })
        if not self.categories[category].currentTab then self.categories[category].currentTab = tabName end
        self:RefreshTabs()
    end

    function self:RefreshTabs()
        for _, child in ipairs(self.bottomTabsFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local cat = self.categories[self.activeCategory]
        if not cat then return end
        for _, tab in ipairs(cat.tabs) do
            local active = (tab.name == cat.currentTab)
            local btn = new("TextButton", {
                Size = UDim2.fromOffset(85, 16),
                BackgroundColor3 = active and T.accent or T.card,
                BackgroundTransparency = active and 0.1 or 0.6,
                Text = tab.name, TextColor3 = T.text, Font = FONT_BOLD, TextSize = 9,
                ZIndex = 4, Parent = self.bottomTabsFrame, AutoButtonColor = false,
            })
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
            btn.MouseButton1Click:Connect(function() cat.currentTab = tab.name self:RefreshTabs() self:RenderModules() end)
        end
    end

    function self:SetTab(category, tabName)
        local cat = self.categories[category]
        if cat then cat.currentTab = tabName end
        self:RefreshTabs()
        self:RenderModules()
    end

    function self:RenderModules()
        for _, child in ipairs(self.scroll:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
        end

        local searchText = string.lower(self.searchBox.Text)
        local isSearching = (searchText ~= "")
        self.searchMode = isSearching

        -- Construction de la liste des modules à afficher
        local modulesToShow = {}

        if isSearching then
            -- RECHERCHE GLOBALE : parcourt toutes les catégories et tous les onglets
            self.catTitle.Text = "🔍 Résultats de recherche"
            self.catDesc.Text = "Recherche dans toutes les catégories"
            for catName, catData in pairs(self.categories) do
                for _, tabData in ipairs(catData.tabs) do
                    for _, mod in ipairs(tabData.modules) do
                        local match = string.find(string.lower(mod.name), searchText, 1, true)
                        if not match and mod.desc then
                            match = string.find(string.lower(mod.desc), searchText, 1, true)
                        end
                        if match then
                            table.insert(modulesToShow, { mod = mod, cat = catName, tab = tabData.name })
                        end
                    end
                end
            end
        else
            -- AFFICHAGE NORMAL : seulement l'onglet actif
            local cat = self.categories[self.activeCategory]
            if not cat then return end
            local tab
            for _, t in ipairs(cat.tabs) do if t.name == cat.currentTab then tab = t break end end
            if not tab then return end
            for _, mod in ipairs(tab.modules) do
                table.insert(modulesToShow, { mod = mod, cat = self.activeCategory, tab = tab.name })
            end
        end

        local count = 0
        for _, entry in ipairs(modulesToShow) do
            local mod = entry.mod
            count = count + 1

            -- Détection du contour vert (Effets OU Sin Dragon)
            local isGreen = (entry.cat == "sparkles") or (entry.tab == "Sin Dragon")

            local card = new("TextButton", {
                BackgroundColor3 = T.card, BackgroundTransparency = 0.15,
                Text = "", ZIndex = 3, Parent = self.scroll, AutoButtonColor = false, LayoutOrder = count,
            })
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

            local cardStroke = Instance.new("UIStroke")
            if isGreen then
                cardStroke.Color = T.green
                cardStroke.Thickness = 3
                cardStroke.Transparency = 0
            else
                cardStroke.Color = T.stroke
                cardStroke.Thickness = 1
                cardStroke.Transparency = 0.4
            end
            cardStroke.Parent = card

            -- Affichage du nom (avec indication de catégorie en mode recherche)
            local displayName = mod.name
            if isSearching then
                displayName = mod.name .. " [" .. entry.cat .. "]"
            end

            text({ Text = displayName, Font = FONT_BOLD, TextSize = 10, TextColor3 = T.text, Position = UDim2.fromOffset(6, 3), Size = UDim2.new(1, -22, 0, 14), TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4, Parent = card })
            if mod.desc and not mod.textbox and not mod.slider then
                text({ Text = mod.desc, Font = FONT, TextSize = 8, TextColor3 = T.sub, Position = UDim2.fromOffset(6, 18), Size = UDim2.new(1, -12, 0, 20), TextWrapped = true, ZIndex = 4, Parent = card })
            end

            if mod.textbox then
                local tb = new("TextBox", {
                    Size = UDim2.new(1, -12, 0, 18), Position = UDim2.fromOffset(6, 34),
                    BackgroundColor3 = T.textbox, TextColor3 = T.text, Font = FONT, TextSize = 9,
                    PlaceholderText = mod.placeholder or "...", PlaceholderColor3 = T.dim,
                    Text = tostring(mod.value or ""), ClearTextOnFocus = false,
                    ZIndex = 4, Parent = card,
                })
                Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 4)
                tb.FocusLost:Connect(function()
                    local val = tb.Text
                    local num = tonumber(val)
                    if mod.callback then mod.callback(num or val) end
                end)
            elseif mod.slider then
                local sliderBar = new("Frame", { Size = UDim2.new(1, -12, 0, 5), Position = UDim2.fromOffset(6, 36), BackgroundColor3 = T.bg3, BorderSizePixel = 0, ZIndex = 4, Parent = card })
                Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(1, 0)
                local fill = new("Frame", { Size = UDim2.new((mod.value - mod.min) / (mod.max - mod.min), 0, 1, 0), BackgroundColor3 = T.accent, BorderSizePixel = 0, ZIndex = 5, Parent = sliderBar })
                Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
                local knob = new("Frame", { Size = UDim2.fromOffset(10, 10), Position = UDim2.new((mod.value - mod.min) / (mod.max - mod.min), -5, 0.5, -5), BackgroundColor3 = T.text, BorderSizePixel = 0, ZIndex = 6, Parent = sliderBar })
                Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
                local dragging = false
                sliderBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true end end)
                UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local ratio = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
                        local value = math.floor(mod.min + (mod.max - mod.min) * ratio)
                        mod.value = value
                        fill.Size = UDim2.new(ratio, 0, 1, 0)
                        knob.Position = UDim2.new(ratio, -5, 0.5, -5)
                        if mod.callback then pcall(mod.callback, value) end
                    end
                end)
            else
                local dot = new("Frame", { Size = UDim2.fromOffset(8, 8), Position = UDim2.new(1, -12, 0, 4), BackgroundColor3 = T.dim, ZIndex = 4, Parent = card })
                Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
                card.MouseButton1Click:Connect(function()
                    if mod.callback then pcall(mod.callback) end
                    if mod.toggle then
                        local state = not self.statusList[mod.name]
                        self.statusList[mod.name] = state
                        dot.BackgroundColor3 = state and T.success or T.dim
                        self:UpdateCounter()
                        self:UpdateStatus()
                    end
                end)
                if mod.default then self.statusList[mod.name] = true dot.BackgroundColor3 = T.success end
            end

            card.MouseEnter:Connect(function()
                tw(card, 0.15, { BackgroundTransparency = 0, BackgroundColor3 = T.card:Lerp(T.accent, 0.2) }):Play()
                if isGreen then
                    tw(cardStroke, 0.15, { Transparency = 0, Color = T.green, Thickness = 3 }):Play()
                else
                    tw(cardStroke, 0.15, { Transparency = 0.1, Color = T.accent }):Play()
                end
            end)
            card.MouseLeave:Connect(function()
                tw(card, 0.15, { BackgroundTransparency = 0.15, BackgroundColor3 = T.card }):Play()
                if isGreen then
                    tw(cardStroke, 0.15, { Transparency = 0, Color = T.green, Thickness = 3 }):Play()
                else
                    tw(cardStroke, 0.15, { Transparency = 0.4, Color = T.stroke }):Play()
                end
            end)
        end

        local nbRows = math.ceil(count / 4)
        self.scroll.CanvasSize = UDim2.new(0, 0, 0, nbRows * 62 + 10)
        self:UpdateCounter()
    end

    function self:AddModule(category, tabName, mod)
        if not self.categories[category] then self.categories[category] = { tabs = {}, currentTab = tabName } end
        local found = false
        for _, t in ipairs(self.categories[category].tabs) do
            if t.name == tabName then table.insert(t.modules, mod) found = true break end
        end
        if not found then table.insert(self.categories[category].tabs, { name = tabName, modules = { mod } }) end
        self:RenderModules()
    end

    function self:AddSlider(category, tabName, name, min, max, default, callback)
        if not self.categories[category] then self.categories[category] = { tabs = {}, currentTab = tabName } end
        local tab
        for _, t in ipairs(self.categories[category].tabs) do if t.name == tabName then tab = t break end end
        if not tab then table.insert(self.categories[category].tabs, { name = tabName, modules = {} }) tab = self.categories[category].tabs[#self.categories[category].tabs] end
        table.insert(tab.modules, { name = name, desc = "", slider = true, min = min, max = max, value = default, callback = callback })
        self:RenderModules()
    end

    function self:AddTextBox(category, tabName, name, placeholder, default, callback)
        if not self.categories[category] then self.categories[category] = { tabs = {}, currentTab = tabName } end
        local tab
        for _, t in ipairs(self.categories[category].tabs) do if t.name == tabName then tab = t break end end
        if not tab then table.insert(self.categories[category].tabs, { name = tabName, modules = {} }) tab = self.categories[category].tabs[#self.categories[category].tabs] end
        table.insert(tab.modules, { name = name, desc = "", textbox = true, placeholder = placeholder, value = default, callback = callback })
        self:RenderModules()
    end

    function self:SetBackground(mode)
        self.bgMode = mode
        if mode == 1 then
            self.bgFrame.BackgroundTransparency = 0.7
            self.bgFrame.BackgroundColor3 = T.bg1
        else
            self.bgFrame.BackgroundTransparency = 1
        end
    end

    function self:SetScale(scale)
        self.uiScale = scale
        local vp = workspace.CurrentCamera.ViewportSize
        local inset = GuiService:GetGuiInset()
        local baseW = math.min(720, vp.X - 60)
        local baseH = math.min(500, vp.Y - inset.Y - 60)
        local newW = baseW * scale
        local newH = baseH * scale
        tw(self.root, 0.2, { Size = UDim2.fromOffset(newW, newH) }):Play()
    end

    function self:Notify(msg)
        if VAZ and VAZ.SHOW_NOTIFS == false then return end
        local notif = new("TextLabel", {
            Text = msg, Font = FONT_BOLD, TextSize = 12, TextColor3 = T.text,
            BackgroundColor3 = T.accent, BackgroundTransparency = 0.2,
            Size = UDim2.fromOffset(280, 32), Position = UDim2.new(0.5, -140, 0, -40),
            TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 10, Parent = self.root,
        })
        Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
        tw(notif, 0.3, { Position = UDim2.new(0.5, -140, 0, 8) }):Play()
        task.wait(2)
        tw(notif, 0.3, { Position = UDim2.new(0.5, -140, 0, -40) }):Play()
        task.wait(0.3)
        notif:Destroy()
    end

    self.searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        self:RenderModules()
    end)

    task.defer(function() self:SetCategory("home") end)
    return self
end

_G.VaztoodixUI = VaztoodixUI
print("✅ Partie 1/4 chargée - Recherche globale + contour vert Sin Dragon + Effets")
