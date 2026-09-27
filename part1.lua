-- PARTIE 1/4 - Interface Vaztoodix UI v4 (cartes réduites + scroll horizontal)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")

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

local Lucide
pcall(function()
    Lucide = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/lucide-roblox-direct/refs/heads/main/source.lua"))()
end)

local LOGO_IMAGE = "https://raw.githubusercontent.com/24vaztoodix24-lang/Script-roblox-Vaztoodix-RB/refs/heads/main/vaz_revenge.png"

local T = {
    bg1 = Color3.fromRGB(20, 15, 35), bg2 = Color3.fromRGB(35, 20, 60), bg3 = Color3.fromRGB(15, 10, 25),
    accent = Color3.fromRGB(140, 80, 255), accent2 = Color3.fromRGB(255, 100, 200),
    text = Color3.fromRGB(255, 255, 255), sub = Color3.fromRGB(200, 200, 220),
    dim = Color3.fromRGB(140, 140, 160), card = Color3.fromRGB(45, 35, 75),
    stroke = Color3.fromRGB(100, 70, 180), success = Color3.fromRGB(80, 220, 120),
    danger = Color3.fromRGB(255, 80, 100),
}

local FONT_BOLD = Enum.Font.GothamBold
local FONT = Enum.Font.Gotham

local function new(c, p) local o = Instance.new(c) for k, v in pairs(p or {}) do o[k] = v end return o end
local function tw(o, d, p, style, dir) return TweenService:Create(o, TweenInfo.new(d, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), p) end
local function text(p)
    local d = { BackgroundTransparency = 1, TextColor3 = T.text, TextSize = 12, Font = FONT, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center }
    for k, v in pairs(p or {}) do d[k] = v end
    return new("TextLabel", d)
end

local iconCache = {}
local function setIcon(im, name)
    local a = iconCache[name]
    if a == nil then a = (Lucide and Lucide.GetAsset(name)) or false iconCache[name] = a end
    if a then im.Image = a.Url im.ImageRectOffset = a.ImageRectOffset im.ImageRectSize = a.ImageRectSize end
    return im
end
local function icon(name, p)
    local d = { BackgroundTransparency = 1, ImageColor3 = T.dim, Size = UDim2.fromOffset(18, 18) }
    for k, v in pairs(p or {}) do d[k] = v end
    return setIcon(new("ImageLabel", d), name)
end

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

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

    local mount = game:GetService("CoreGui")
    if getgenv and getgenv().__vaztoodix_gui then pcall(function() getgenv().__vaztoodix_gui:Destroy() end) end

    self.gui = new("ScreenGui", { ResetOnSpawn = false, IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
    pcall(function() protect(self.gui) end)
    self.gui.Parent = mount

    if getgenv then getgenv().__vaztoodix_gui = self.gui getgenv().VAZTOODIXUI = self end

    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
    local inset = GuiService:GetGuiInset()
    local W = math.min(700, vp.X - 60)
    local H = math.min(480, vp.Y - inset.Y - 60)

    self.root = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, inset.Y / 2),
        Size = UDim2.fromOffset(W, H), BackgroundColor3 = T.bg1, BackgroundTransparency = 0.05,
        BorderSizePixel = 0, ZIndex = 2, Parent = self.gui,
    })
    Instance.new("UICorner", self.root).CornerRadius = UDim.new(0, 20)
    local rootGrad = Instance.new("UIGradient")
    rootGrad.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, T.bg1), ColorSequenceKeypoint.new(0.5, T.bg2), ColorSequenceKeypoint.new(1, T.bg3) })
    rootGrad.Rotation = 45
    rootGrad.Parent = self.root
    local rootStroke = Instance.new("UIStroke")
    rootStroke.Color = T.accent rootStroke.Thickness = 1.5 rootStroke.Transparency = 0.3
    rootStroke.Parent = self.root

    self.root.Size = UDim2.fromOffset(1, 1)
    self.root.Rotation = 15
    tw(self.root, 0.4, { Size = UDim2.fromOffset(W, H), Rotation = 0 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out):Play()

    -- Barre supérieure
    local topBar = new("Frame", {
        Size = UDim2.new(1, 0, 0, 46), BackgroundColor3 = T.bg3, BackgroundTransparency = 0.4,
        BorderSizePixel = 0, ZIndex = 3, Parent = self.root,
    })
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 20)

    new("ImageLabel", { Image = LOGO_IMAGE, BackgroundTransparency = 1, Size = UDim2.fromOffset(38, 38), Position = UDim2.fromOffset(8, 4), ZIndex = 4, Parent = topBar })

    self.clock = text({ Text = "00:00:00", Font = FONT_BOLD, TextSize = 13, TextColor3 = T.text, Position = UDim2.new(0.5, -50, 0, 0), Size = UDim2.fromOffset(100, 46), TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 4, Parent = topBar })
    task.spawn(function() while self.glowing do self.clock.Text = os.date("%H:%M:%S") task.wait(1) end end)

    self.counter = text({ Text = "0 actif", Font = FONT_BOLD, TextSize = 11, TextColor3 = T.dim, Position = UDim2.new(1, -200, 0, 0), Size = UDim2.fromOffset(120, 46), TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 4, Parent = topBar })

    local minimizeBtn = new("TextButton", {
        Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -72, 0, 9),
        BackgroundColor3 = Color3.fromRGB(80, 80, 120), BackgroundTransparency = 0.4,
        Text = "—", TextColor3 = T.text, TextSize = 16, Font = FONT_BOLD, ZIndex = 4, Parent = topBar,
    })
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)
    minimizeBtn.MouseButton1Click:Connect(function()
        self.root.Visible = false
        if not self.toggleCircle or not self.toggleCircle.Parent then
            local toggleGui = new("ScreenGui", { Name = "VaztoodixToggle", ResetOnSpawn = false, Parent = p.PlayerGui })
            local circle = new("ImageButton", {
                Size = UDim2.fromOffset(56, 56), Position = UDim2.new(0.02, 0, 0.8, 0),
                BackgroundColor3 = Color3.fromRGB(40, 20, 20), BackgroundTransparency = 0.3,
                BorderSizePixel = 0, Image = LOGO_IMAGE, ZIndex = 10, Parent = toggleGui,
            })
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
            local stroke = Instance.new("UIStroke") stroke.Color = Color3.fromRGB(255, 100, 0) stroke.Thickness = 2 stroke.Transparency = 0.3 stroke.Parent = circle
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
        Size = UDim2.fromOffset(28, 28), Position = UDim2.new(1, -38, 0, 9),
        BackgroundColor3 = T.danger, BackgroundTransparency = 0.5, Text = "", ZIndex = 4, Parent = topBar,
    })
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    icon("x", { Size = UDim2.fromOffset(14, 14), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), ImageColor3 = T.text, ZIndex = 5, Parent = closeBtn })
    closeBtn.MouseButton1Click:Connect(function()
        self.glowing = false
        tw(self.root, 0.3, { Size = UDim2.fromOffset(1, 1), Rotation = -30, Position = UDim2.new(1, 0, 0, 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.In):Play()
        task.wait(0.3)
        self.gui:Destroy()
        if self.toggleCircle then self.toggleCircle.Parent:Destroy() end
        if getgenv then getgenv().VAZTOODIXUI = nil end
    end)

    -- Sidebar (icônes 32x32)
    local sidebarH = H - 46 - 22 - 14
    local sidebar = new("Frame", { Size = UDim2.fromOffset(48, sidebarH), Position = UDim2.fromOffset(0, 46), BackgroundColor3 = T.bg3, BackgroundTransparency = 0.5, BorderSizePixel = 0, ZIndex = 3, Parent = self.root })
    local sidebarScroll = new("ScrollingFrame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = T.accent, CanvasSize = UDim2.new(0, 0, 0, 0), ZIndex = 4, Parent = sidebar })
    new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder, Parent = sidebarScroll })

    self.sidebarButtons = {}
    local sidebarIcons = {
        { name = "home" }, { name = "sword" }, { name = "move" },
        { name = "crosshair" }, { name = "settings" }, { name = "sparkles" }, { name = "info" },
    }
    for i, item in ipairs(sidebarIcons) do
        local btn = new("TextButton", { Size = UDim2.fromOffset(32, 32), BackgroundColor3 = T.card, BackgroundTransparency = 0.5, Text = "", ZIndex = 4, Parent = sidebarScroll, LayoutOrder = i })
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local im = icon(item.name, { Size = UDim2.fromOffset(16, 16), Position = UDim2.fromScale(0.5, 0.5), AnchorPoint = Vector2.new(0.5, 0.5), ImageColor3 = T.sub, ZIndex = 5, Parent = btn })
        btn.MouseEnter:Connect(function() tw(btn, 0.1, { BackgroundTransparency = 0.2, BackgroundColor3 = T.accent }):Play() tw(im, 0.1, { ImageColor3 = T.text }):Play() end)
        btn.MouseLeave:Connect(function() if self.activeCategory ~= item.name then tw(btn, 0.1, { BackgroundTransparency = 0.5, BackgroundColor3 = T.card }):Play() tw(im, 0.1, { ImageColor3 = T.sub }):Play() end end)
        btn.MouseButton1Click:Connect(function() self:SetCategory(item.name) end)
        self.sidebarButtons[item.name] = { btn = btn, icon = im }
    end
    sidebarScroll.CanvasSize = UDim2.new(0, 0, 0, #sidebarIcons * 35 + 8)

    local contentX = 53
    local contentW = W - contentX - 8
    local contentH = H - 46 - 22 - 14
    local contentArea = new("Frame", { Size = UDim2.fromOffset(contentW, contentH), Position = UDim2.fromOffset(contentX, 46), BackgroundTransparency = 1, ZIndex = 3, Parent = self.root })

    -- Scroll HORIZONTAL (gauche à droite)
    self.scroll = new("ScrollingFrame", {
        Size = UDim2.new(1, -6, 1, -12), Position = UDim2.fromOffset(3, 3),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 4, ScrollBarImageColor3 = T.accent,
        ScrollingDirection = Enum.ScrollingDirection.X,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 3, Parent = contentArea,
    })
    -- Grille HORIZONTALE : cartes réduites de 1/4 (130 x 52)
    new("UIGridLayout", {
        CellSize = UDim2.fromOffset(130, 52),
        CellPadding = UDim2.fromOffset(6, 6),
        FillDirectionMaxCells = 3,
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
            if cat == name then tw(data.btn, 0.15, { BackgroundColor3 = T.accent, BackgroundTransparency = 0.2 }):Play() tw(data.icon, 0.15, { ImageColor3 = T.text }):Play()
            else tw(data.btn, 0.15, { BackgroundColor3 = T.card, BackgroundTransparency = 0.5 }):Play() tw(data.icon, 0.15, { ImageColor3 = T.sub }):Play() end
        end
        self:RefreshTabs()
        self:RenderModules()
    end

    function self:AddCategory(name) end

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
                BackgroundTransparency = active and 0.2 or 0.6,
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
        local cat = self.categories[self.activeCategory]
        if not cat then return end
        local tab
        for _, t in ipairs(cat.tabs) do if t.name == cat.currentTab then tab = t break end end
        if not tab then return end

        local count = 0
        for _, mod in ipairs(tab.modules) do
            count = count + 1
            local card = new("TextButton", {
                BackgroundColor3 = T.card, BackgroundTransparency = 0.15,
                Text = "", ZIndex = 3, Parent = self.scroll, AutoButtonColor = false, LayoutOrder = count,
            })
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
            local cardStroke = Instance.new("UIStroke") cardStroke.Color = T.stroke cardStroke.Thickness = 1 cardStroke.Transparency = 0.4 cardStroke.Parent = card

            text({ Text = mod.name, Font = FONT_BOLD, TextSize = 10, TextColor3 = T.text, Position = UDim2.fromOffset(6, 2), Size = UDim2.new(1, -20, 0, 14), ZIndex = 4, Parent = card })
            if mod.desc then
                text({ Text = mod.desc, Font = FONT, TextSize = 8, TextColor3 = T.sub, Position = UDim2.fromOffset(6, 16), Size = UDim2.new(1, -12, 0, 32), TextWrapped = true, ZIndex = 4, Parent = card })
            end
            local dot = new("Frame", { Size = UDim2.fromOffset(8, 8), Position = UDim2.new(1, -12, 0, 4), BackgroundColor3 = T.dim, ZIndex = 4, Parent = card })
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

            card.MouseEnter:Connect(function() tw(card, 0.15, { BackgroundTransparency = 0, BackgroundColor3 = T.card:Lerp(T.accent, 0.15) }):Play() tw(cardStroke, 0.15, { Transparency = 0.1, Color = T.accent }):Play() end)
            card.MouseLeave:Connect(function() tw(card, 0.15, { BackgroundTransparency = 0.15, BackgroundColor3 = T.card }):Play() tw(cardStroke, 0.15, { Transparency = 0.4, Color = T.stroke }):Play() end)
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
        -- Canvas HORIZONTAL : largeur = nombre de colonnes * 136
        local columns = math.ceil(count / 3)
        self.scroll.CanvasSize = UDim2.new(0, columns * 136, 0, 0)
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

    function self:Notify(msg)
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

    task.defer(function() self:SetCategory("home") end)
    return self
end

_G.VaztoodixUI = VaztoodixUI
print("✅ Partie 1/4 chargée - Cartes réduites (130x52) + scroll horizontal")