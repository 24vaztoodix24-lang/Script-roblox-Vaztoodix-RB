-- PARTIE 1/4 - Interface Vaztoodix UI
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")

if getgenv and getgenv().VAZTOODIXUI_CLEANUP then
    pcall(getgenv().VAZTOODIXUI_CLEANUP)
end

local CONNS = {}
local function keep(c)
    table.insert(CONNS, c)
    return c
end

if getgenv then
    getgenv().VAZTOODIXUI_CLEANUP = function()
        for _, c in ipairs(CONNS) do
            pcall(function() c:Disconnect() end)
        end
        table.clear(CONNS)
    end
end

local Lucide
pcall(function()
    Lucide = loadstring(game:HttpGet("https://raw.githubusercontent.com/mstudio45/lucide-roblox-direct/refs/heads/main/source.lua"))()
end)

local T = {
    root = Color3.fromRGB(24, 24, 24),
    panel = Color3.fromRGB(30, 30, 30),
    inset = Color3.fromRGB(28, 28, 28),
    stroke = Color3.fromRGB(40, 40, 40),
    strokeSoft = Color3.fromRGB(34, 34, 34),
    text = Color3.fromRGB(255, 255, 255),
    sub = Color3.fromRGB(150, 150, 150),
    dim = Color3.fromRGB(108, 108, 108),
    faint = Color3.fromRGB(84, 84, 84),
    descText = Color3.fromRGB(124, 124, 124),
    star = Color3.fromRGB(205, 205, 205),
}

local FAMILIES = {
    ["Builder Sans"] = { Enum.Font.BuilderSans, Enum.Font.BuilderSansMedium, Enum.Font.BuilderSansBold },
    ["Gotham"] = { Enum.Font.Gotham, Enum.Font.GothamMedium, Enum.Font.GothamBold },
    ["Source Sans"] = { Enum.Font.SourceSans, Enum.Font.SourceSansSemibold, Enum.Font.SourceSansBold },
    ["Ubuntu"] = { Enum.Font.Ubuntu, Enum.Font.Ubuntu, Enum.Font.Ubuntu },
}
local FONT_REG, FONT, FONT_BOLD = table.unpack(FAMILIES["Builder Sans"])

local MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local TEXT_SCALE = MOBILE and 1.42 or 1.15
local ROW_H = MOBILE and 78 or 62
local ROW_H_COMPACT = MOBILE and 58 or 44
local CAT_H = MOBILE and 52 or 40
local SEARCH_H = MOBILE and 54 or 42
local LOGO_ROW = MOBILE and 64 or 48
local TOPBAR_H = LOGO_ROW + (MOBILE and 40 or 28)
local HIT = MOBILE and 44 or 32
local GLYPH = MOBILE and 20 or 16
local FAST = 0.1

local function new(className, props)
    local p = Instance.new(className)
    for k, v in pairs(props or {}) do p[k] = v end
    return p
end

local function panel(props, bgTransparency)
    local p = {
        BackgroundColor3 = T.panel,
        BackgroundTransparency = bgTransparency or 0,
        BorderSizePixel = 0,
    }
    for k, v in pairs(props or {}) do p[k] = v end
    return new("Frame", p)
end

local function stroke(parent, color, radius, alpha)
    local s = new("Frame", {
        BackgroundColor3 = color,
        BackgroundTransparency = alpha or 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Position = UDim2.fromScale(0, 0),
        ZIndex = 1,
        Parent = parent,
    })
    if radius then
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius)
        c.Parent = s
    end
    return s
end

local function tw(obj, dur, props)
    return TweenService:Create(obj, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
end

local function text(props)
    local p = {
        BackgroundTransparency = 1,
        TextColor3 = T.text,
        TextSize = 14,
        Font = FONT,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }
    for k, v in pairs(props or {}) do p[k] = v end
    local base = p.TextSize or 14
    p.TextSize = math.floor(base * TEXT_SCALE + 0.5)
    return new("TextLabel", p)
end

local iconCache = {}
local function iconAsset(name)
    local a = iconCache[name]
    if a == nil then
        a = (Lucide and Lucide.GetAsset(name)) or false
        iconCache[name] = a
    end
    return a or nil
end

local function setIcon(im, name)
    local a = iconAsset(name)
    if a then
        im.Image = a.Url
        im.ImageRectOffset = a.ImageRectOffset
        im.ImageRectSize = a.ImageRectSize
    end
    return im
end

local function icon(name, props)
    local p = {
        BackgroundTransparency = 1,
        ImageColor3 = T.dim,
        Size = UDim2.fromOffset(24, 24)
    }
    for k, v in pairs(props or {}) do p[k] = v end
    return setIcon(new("ImageLabel", p), name)
end

local VaztoodixUI = {}
VaztoodixUI.__index = VaztoodixUI

function VaztoodixUI.new(cfg)
    cfg = cfg or {}
    local self = setmetatable({}, VaztoodixUI)
    self.categories = {}
    self.activeCategory = nil
    self.activeTab = nil

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

    local W, H = cfg.Width or 820, cfg.Height or 520
    self.root = panel({
        AnchorPoint = Vector2.new(0, 0),
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromOffset(W, H),
        BackgroundColor3 = T.root,
        ZIndex = 2,
        Parent = self.gui,
    }, 0)
    stroke(self.root, T.strokeSoft, 10, 0.3)

    function self:Recenter()
        local space = self.gui.AbsoluteSize
        if space.X < 1 then
            space = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
        end
        local rw, rh = self.root.AbsoluteSize.X, self.root.AbsoluteSize.Y
        if rw < 1 then rw, rh = W, H end
        local inset = GuiService:GetGuiInset()
        self.root.Position = UDim2.fromOffset(
            math.floor((space.X - rw) / 2 + 0.5),
            inset.Y + math.floor((space.Y - inset.Y - rh) / 2 + 0.5)
        )
    end
    self:Recenter()

    -- Barre supérieure
    local top = panel({
        Size = UDim2.new(1, 0, 0, TOPBAR_H),
        BackgroundColor3 = T.panel,
        ZIndex = 3,
        Parent = self.root,
    })
    stroke(top, T.strokeSoft, 0, 0.3)

    local brandRow = new("Frame", {
        Size = UDim2.fromOffset(0, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        ZIndex = 4,
        Parent = top,
    })
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 12),
        Parent = brandRow,
    })

    text({
        Text = cfg.Title or "Vaztoodix ™",
        Font = FONT_BOLD,
        TextSize = 18,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        LayoutOrder = 1,
        Parent = brandRow,
    })

    local tabHolder = new("Frame", {
        Position = UDim2.fromOffset(22, LOGO_ROW),
        Size = UDim2.new(1, -44, 0, TOPBAR_H - LOGO_ROW),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = top,
    })
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 30),
        Parent = tabHolder,
    })
    self.tabHolder = tabHolder

    -- Icônes de la barre (fermer)
    local winIcons = new("Frame", {
        Size = UDim2.fromOffset(HIT, LOGO_ROW),
        Position = UDim2.new(1, -HIT - 18, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = top,
    })
    local closeBtn = new("TextButton", {
        Size = UDim2.fromOffset(HIT, HIT),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 4,
        Parent = winIcons,
    })
    icon("x", {
        Size = UDim2.fromOffset(GLYPH, GLYPH),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        ImageColor3 = Color3.fromRGB(255, 80, 80),
        Parent = closeBtn,
    })
    closeBtn.MouseButton1Click:Connect(function()
        self.gui:Destroy()
        if getgenv then getgenv().VAZTOODIXUI = nil end
    end)

    -- Corps
    local body = panel({
        Size = UDim2.new(1, 0, 1, -TOPBAR_H),
        Position = UDim2.new(0, 0, 0, TOPBAR_H),
        BackgroundColor3 = T.root,
        ZIndex = 2,
        Parent = self.root,
    })

    -- Sidebar
    local sidebar = panel({
        Size = UDim2.fromOffset(200, 1),
        BackgroundColor3 = T.panel,
        ZIndex = 3,
        Parent = body,
    })
    stroke(sidebar, T.strokeSoft, 0, 0.3)

    local catList = new("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ZIndex = 4,
        Parent = sidebar,
    })
    new("UIListLayout", {
        Padding = UDim.new(0, 2),
        Parent = catList,
    })
    self.catList = catList

    local contentArea = panel({
        Size = UDim2.new(1, -200, 1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = T.root,
        ZIndex = 2,
        Parent = body,
    })

    local moduleContainer = new("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 6,
        ZIndex = 2,
        Parent = contentArea,
    })
    new("UIListLayout", {
        Padding = UDim.new(0, 6),
        Parent = moduleContainer,
    })
    self.moduleContainer = moduleContainer

    function self:AddCategory(name)
        local btn = new("TextButton", {
            Size = UDim2.new(1, -12, 0, CAT_H),
            Position = UDim2.new(0, 6, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = T.sub,
            Font = FONT,
            TextSize = 14 * TEXT_SCALE,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5,
            Parent = self.catList,
            AutoButtonColor = false,
        })
        btn.MouseButton1Click:Connect(function() self:SetCategory(name) end)
        self.categories[name] = { button = btn, tabs = {} }
        if not self.activeCategory then self:SetCategory(name) end
    end

    function self:AddTab(category, tabName)
        local cat = self.categories[category]
        if not cat then return end
        table.insert(cat.tabs, { name = tabName, modules = {} })
        if not self.activeTab then self:SetTab(category, tabName) end
        self:RefreshTabs()
    end

    function self:RefreshTabs()
        for _, child in ipairs(self.tabHolder:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        local cat = self.categories[self.activeCategory]
        if not cat then return end
        for _, tab in ipairs(cat.tabs) do
            local btn = new("TextButton", {
                Size = UDim2.fromOffset(0, TOPBAR_H - LOGO_ROW - 4),
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundTransparency = 1,
                Text = tab.name,
                TextColor3 = (tab.name == self.activeTab) and T.text or T.dim,
                Font = FONT_BOLD,
                TextSize = 14 * TEXT_SCALE,
                ZIndex = 4,
                Parent = self.tabHolder,
                AutoButtonColor = false,
            })
            btn.MouseButton1Click:Connect(function()
                self:SetTab(self.activeCategory, tab.name)
            end)
        end
    end

    function self:SetCategory(name)
        self.activeCategory = name
        for cat, data in pairs(self.categories) do
            data.button.TextColor3 = (cat == name) and T.text or T.sub
        end
        local cat = self.categories[name]
        if cat and #cat.tabs > 0 then
            self:SetTab(name, cat.tabs[1].name)
        end
    end

    function self:SetTab(category, tabName)
        self.activeTab = tabName
        self:RefreshTabs()
        self:RenderModules()
    end

    function self:RenderModules()
        for _, child in ipairs(self.moduleContainer:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        local cat = self.categories[self.activeCategory]
        if not cat then return end
        local tab
        for _, t in ipairs(cat.tabs) do
            if t.name == self.activeTab then tab = t break end
        end
        if not tab then return end
        for _, mod in ipairs(tab.modules) do
            local frame = panel({
                Size = UDim2.new(1, -12, 0, ROW_H),
                Position = UDim2.new(0, 6, 0, 0),
                BackgroundColor3 = T.panel,
                ZIndex = 2,
                Parent = self.moduleContainer,
            })
            Instance.new("UICorner").CornerRadius = UDim.new(0, 6)
            text({
                Text = mod.name,
                Font = FONT_BOLD,
                TextSize = 14,
                Size = UDim2.new(0.6, -12, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                Parent = frame,
            })
            if mod.desc then
                text({
                    Text = mod.desc,
                    Font = FONT_REG,
                    TextSize = 11,
                    TextColor3 = T.descText,
                    Size = UDim2.new(0.6, -12, 0.5, 0),
                    Position = UDim2.new(0, 12, 0.6, 0),
                    Parent = frame,
                })
            end
            local action = new("TextButton", {
                Size = UDim2.fromOffset(90, 30),
                Position = UDim2.new(1, -102, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = T.stroke,
                Text = mod.buttonText or "Exécuter",
                TextColor3 = T.text,
                Font = FONT_BOLD,
                TextSize = 12 * TEXT_SCALE,
                ZIndex = 3,
                Parent = frame,
                AutoButtonColor = false,
            })
            Instance.new("UICorner").CornerRadius = UDim.new(0, 4)
            action.MouseButton1Click:Connect(function()
                if mod.callback then pcall(mod.callback) end
            end)
        end
    end

    function self:AddModule(category, tabName, mod)
        local cat = self.categories[category]
        if not cat then return end
        for _, t in ipairs(cat.tabs) do
            if t.name == tabName then
                table.insert(t.modules, mod)
                break
            end
        end
        self:RenderModules()
    end

    function self:PrevTab()
        local cat = self.categories[self.activeCategory]
        if not cat or #cat.tabs == 0 then return end
        local idx
        for i, t in ipairs(cat.tabs) do
            if t.name == self.activeTab then idx = i break end
        end
        idx = (idx and idx > 1) and idx - 1 or #cat.tabs
        self:SetTab(self.activeCategory, cat.tabs[idx].name)
    end

    function self:NextTab()
        local cat = self.categories[self.activeCategory]
        if not cat or #cat.tabs == 0 then return end
        local idx
        for i, t in ipairs(cat.tabs) do
            if t.name == self.activeTab then idx = i break end
        end
        idx = (idx and idx < #cat.tabs) and idx + 1 or 1
        self:SetTab(self.activeCategory, cat.tabs[idx].name)
    end

    return self
end

_G.VaztoodixUI = VaztoodixUI
print("✅ Partie 1/4 chargée - Interface Vaztoodix UI")