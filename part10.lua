-- PARTIE 10/10 - Product Faker V2 (compatible Delta)
-- Crédits : @vaehz on YouTube
-- Intégré par Vaztoodix

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer

getgenv().VAZ = getgenv().VAZ or {}
local VAZ = getgenv().VAZ

local supportedUrl = "https://loadstring.net/raw/TCiFuJc4kK"
local title = "PRODUCT FAKER V2 : @vaehz on yt"

local asciiCfg = {
    enabled = true,
    textSize = 13,
    padding = 80,
    fps = 30,
    ramp = " .,:;-=+*x#%@",
    color = Color3.fromRGB(255, 255, 255),
    mouse = true,
}

local env = typeof(getgenv) == "function" and getgenv() or _G
local previous = env.__ProductFaker or env.__ProductFakerUI
if previous then
    pcall(previous.Destroy, true)
end

local col = {
    bg = Color3.fromRGB(13, 13, 13),
    panel = Color3.fromRGB(30, 30, 30),
    panelHi = Color3.fromRGB(38, 38, 38),
    button = Color3.fromRGB(56, 56, 56),
    buttonHi = Color3.fromRGB(72, 72, 72),
    active = Color3.fromRGB(84, 84, 84),
    icon = Color3.fromRGB(193, 193, 193),
    dim = Color3.fromRGB(120, 120, 120),
    white = Color3.fromRGB(255, 255, 255),
    red = Color3.fromRGB(255, 57, 57),
    blue = Color3.fromRGB(94, 115, 255),
    yellow = Color3.fromRGB(238, 255, 131),
    green = Color3.fromRGB(110, 255, 150),
}

local roboto = "rbxasset://fonts/families/RobotoCondensed.json"
local fontBold = Font.new(roboto, Enum.FontWeight.Bold, Enum.FontStyle.Normal)
local fontReg = Font.new(roboto, Enum.FontWeight.Regular, Enum.FontStyle.Normal)
local fontItalic = Font.new(roboto, Enum.FontWeight.Regular, Enum.FontStyle.Italic)
local fontInput = Font.new("rbxassetid://16658246179", Enum.FontWeight.Regular, Enum.FontStyle.Normal)

local img = {
    close = "rbxassetid://89309313651390",
    home = "rbxassetid://70573525526341",
    faker = "rbxassetid://117975333704340",
    logger = "rbxassetid://109982256018444",
    supported = "rbxassetid://133954136637154",
    passes = "rbxassetid://84787327728949",
    join = "rbxassetid://88984171145049",
    copy = "rbxassetid://101160281432561",
}

local function getEnum(enum, item)
    local ok, v = pcall(function()
        return Enum[enum][item]
    end)
    return ok and v or nil
end

local strokeInner = getEnum("BorderStrokePosition", "Inner")

local function create(class, props, children)
    local ok, inst = pcall(Instance.new, class)
    if not ok then return nil end
    local parent
    for k, v in pairs(props or {}) do
        if k == "Parent" then
            parent = v
        else
            pcall(function() inst[k] = v end)
        end
    end
    for _, child in pairs(children or {}) do
        child.Parent = inst
    end
    if parent then inst.Parent = parent end
    return inst
end

local function corner(r)
    return create("UICorner", {CornerRadius = UDim.new(0, r or 8)})
end

local function stroke(t)
    return create("UIStroke", {Color = col.white, Transparency = t or 0.86, BorderStrokePosition = strokeInner})
end

local function tween(obj, t, props, style, dir)
    local tw = TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function label(props)
    props.BackgroundTransparency = 1
    props.BorderSizePixel = 0
    props.TextScaled = props.TextScaled ~= false
    props.TextWrapped = true
    props.AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0.5)
    props.FontFace = props.FontFace or fontReg
    props.TextColor3 = props.TextColor3 or col.white
    return create("TextLabel", props)
end

local function isClick(input)
    local t = input.UserInputType
    return t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch
end

local function commas(n)
    local s = tostring(math.floor(tonumber(n) or 0))
    return (s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

local function copy(text)
    local fn = setclipboard or toclipboard or set_clipboard or (Clipboard and Clipboard.set)
    return fn ~= nil and (pcall(fn, tostring(text)))
end

local connections = {}
local function bind(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end

local function mount(gui)
    local parents = {}
    if typeof(gethui) == "function" then table.insert(parents, gethui) end
    table.insert(parents, function() return game:GetService("CoreGui") end)
    table.insert(parents, function() return LocalPlayer:WaitForChild("PlayerGui") end)
    for _, get in ipairs(parents) do
        if pcall(function() gui.Parent = get() end) and gui.Parent then return end
    end
end

local fadeProps = {
    {"GuiObject", "BackgroundTransparency"},
    {"TextLabel", "TextTransparency"},
    {"TextButton", "TextTransparency"},
    {"TextBox", "TextTransparency"},
    {"ImageLabel", "ImageTransparency"},
    {"ImageButton", "ImageTransparency"},
    {"ScrollingFrame", "ScrollBarImageTransparency"},
    {"UIStroke", "Transparency"},
    {"UIShadow", "Transparency"},
}

local originals = {}
local fadeExclude = {}

local function getOriginal(inst)
    local o = originals[inst]
    if o then return o end
    o = {}
    for _, pair in ipairs(fadeProps) do
        local okIs, is = pcall(inst.IsA, inst, pair[1])
        if okIs and is then
            local ok, v = pcall(function() return inst[pair[2]] end)
            if ok and type(v) == "number" then o[pair[2]] = v end
        end
    end
    originals[inst] = o
    inst.Destroying:Connect(function() originals[inst] = nil end)
    return o
end

local function isExcluded(inst)
    for _, root in ipairs(fadeExclude) do
        if inst == root or inst:IsDescendantOf(root) then return true end
    end
    return false
end

local function fade(root, alpha, t)
    local list = root:GetDescendants()
    table.insert(list, root)
    for _, inst in ipairs(list) do
        if not isExcluded(inst) then
            local goal
            for prop, v in pairs(getOriginal(inst)) do
                goal = goal or {}
                goal[prop] = v + (1 - v) * (1 - alpha)
            end
            if goal then
                if t and t > 0 then
                    tween(inst, t, goal, Enum.EasingStyle.Quad)
                else
                    for p, v in pairs(goal) do
                        pcall(function() inst[p] = v end)
                    end
                end
            end
        end
    end
end

local glyphs = "!<>-_\\/[]{}=+*^?#@$%&"
local scrambleIds = {}

local function scramble(lbl, text, duration)
    local id = (scrambleIds[lbl] or 0) + 1
    scrambleIds[lbl] = id
    task.spawn(function()
        local start, len = os.clock(), #text
        while lbl.Parent and scrambleIds[lbl] == id do
            local p = (os.clock() - start) / duration
            if p >= 1 then break end
            local revealed = math.floor(p * len)
            local out = table.create(len)
            for i = 1, len do
                local ch = text:sub(i, i)
                if i <= revealed or ch == " " then
                    out[i] = ch
                else
                    local r = math.random(1, #glyphs)
                    out[i] = glyphs:sub(r, r)
                end
            end
            lbl.Text = table.concat(out)
            task.wait(0.03)
        end
        if scrambleIds[lbl] == id then lbl.Text = text end
    end)
end

local ScreenGui = create("ScreenGui", {
    Name = "ProductFakerV2",
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    DisplayOrder = 999,
})
mount(ScreenGui)

local AsciiHolder = create("Frame", {
    Name = "AsciiBackdrop",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    Visible = false,
    ZIndex = 1,
    Parent = ScreenGui,
})

local MainScale = create("UIScale", {Scale = 1})

local Main = create("Frame", {
    Name = "Main",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromScale(0.285, 0.439),
    BackgroundColor3 = col.bg,
    BorderSizePixel = 0,
    Visible = false,
    ZIndex = 2,
    Parent = ScreenGui,
}, {
    corner(),
    create("UIShadow", {Transparency = 0.5, BlurRadius = UDim.new(0, 20)}),
    create("UIStroke", {Color = col.white, Transparency = 0.74}),
    create("UIAspectRatioConstraint", {AspectRatio = 1.2415}),
    create("UISizeConstraint", {MinSize = Vector2.new(380, 306)}),
    MainScale,
})

local idle = {BackgroundColor3 = col.button, ImageColor3 = col.icon}
local hover = {BackgroundColor3 = col.buttonHi, ImageColor3 = col.white}

local function buttonFx(btn, normal, hovered, isActive)
    normal = normal or idle
    hovered = hovered or hover
    local scale = btn:FindFirstChildOfClass("UIScale") or create("UIScale", {Parent = btn})
    local function active()
        return isActive and isActive()
    end
    btn.MouseEnter:Connect(function()
        if not active() then tween(btn, 0.15, hovered) end
    end)
    btn.MouseLeave:Connect(function()
        tween(scale, 0.2, {Scale = 1})
        if not active() then tween(btn, 0.2, normal) end
    end)
    btn.MouseButton1Down:Connect(function() tween(scale, 0.08, {Scale = 0.9}) end)
    btn.MouseButton1Up:Connect(function() tween(scale, 0.35, {Scale = 1}, Enum.EasingStyle.Back) end)
end

local TopBar = create("Frame", {
    Name = "TopBar",
    Size = UDim2.fromScale(1, 0.125),
    BackgroundColor3 = col.panel,
    BorderSizePixel = 0,
    Parent = Main,
}, {
    create("UICorner", {BottomLeftRadius = UDim.new(0, 0), BottomRightRadius = UDim.new(0, 0)}),
})

local Title = label({
    Name = "Title",
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.fromScale(0.034, 0.5),
    Size = UDim2.fromScale(0.8, 0.386),
    Text = title,
    FontFace = fontBold,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = TopBar,
})

local CloseButton = create("ImageButton", {
    Name = "CloseButton",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.948, 0.5),
    Size = UDim2.fromScale(0.069, 0.693),
    BackgroundColor3 = col.button,
    BorderSizePixel = 0,
    Image = img.close,
    ImageColor3 = col.icon,
    AutoButtonColor = false,
    Parent = TopBar,
}, {corner(), stroke(), create("UIScale")})
buttonFx(CloseButton, idle, {BackgroundColor3 = Color3.fromRGB(150, 40, 40), ImageColor3 = col.white})

local BottomBar = create("Frame", {
    Name = "BottomBar",
    AnchorPoint = Vector2.new(0, 1),
    Position = UDim2.fromScale(0, 1),
    Size = UDim2.fromScale(1, 0.125),
    BackgroundColor3 = col.panel,
    BorderSizePixel = 0,
    Parent = Main,
}, {
    create("UICorner", {TopLeftRadius = UDim.new(0, 0), TopRightRadius = UDim.new(0, 0)}),
})

local ButtonContainer = create("Frame", {
    Name = "ButtonContainer",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromScale(0.9588, 0.636),
    BackgroundTransparency = 1,
    Parent = BottomBar,
}, {
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }),
})

local Indicator = create("Frame", {
    Name = "TabIndicator",
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0, 0, 1, -2),
    Size = UDim2.fromOffset(14, 2),
    BackgroundColor3 = col.white,
    BorderSizePixel = 0,
    ZIndex = 3,
    Parent = BottomBar,
}, {corner(1)})

local function navButton(name, image, order)
    return create("ImageButton", {
        Name = name,
        LayoutOrder = order,
        Size = UDim2.fromScale(0.0668, 1),
        BackgroundColor3 = col.button,
        BorderSizePixel = 0,
        Image = image,
        ImageColor3 = col.icon,
        AutoButtonColor = false,
        Parent = ButtonContainer,
    }, {corner(), stroke(), create("UIScale")})
end

local HomeButton = navButton("HomeButton", img.home, 1)
local FakerButton = navButton("FakerButton", img.faker, 2)
local LoggerButton = navButton("LoggerButton", img.logger, 3)
local SupportedButton = navButton("SupportedButton", img.supported, 4)
local PassListButton = navButton("PassListButton", img.passes, 5)

local SectionsContainer = create("Frame", {
    Name = "SectionsContainer",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromScale(0.938, 0.665),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    Parent = Main,
})

local emptyLabels = {}

local function makeScreen(name, scrolling)
    if not scrolling then
        return create("Frame", {
            Name = name,
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = SectionsContainer,
        })
    end
    local sf = create("ScrollingFrame", {
        Name = name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = col.button,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Parent = SectionsContainer,
    }, {
        create("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}),
        create("UIPadding", {PaddingTop = UDim.new(0, 1), PaddingBottom = UDim.new(0, 1), PaddingLeft = UDim.new(0, 1)}),
    })
    local empty = label({
        Name = "Empty",
        AnchorPoint = Vector2.new(0, 0),
        Size = UDim2.new(1, -8, 0, 40),
        Text = "Nothing here yet.",
        TextScaled = false,
        TextSize = 14,
        TextColor3 = col.dim,
        LayoutOrder = -1e9,
        Parent = sf,
    })
    emptyLabels[sf] = empty
    local function refresh()
        for _, child in ipairs(sf:GetChildren()) do
            if child:GetAttribute("IsRow") then
                empty.Visible = false
                return
            end
        end
        empty.Visible = true
    end
    sf.ChildAdded:Connect(refresh)
    sf.ChildRemoved:Connect(refresh)
    return sf
end

local HomeScreen = makeScreen("HomeScreen", false)
local FakerScreen = makeScreen("FakerScreen", false)
local ProductLogger = makeScreen("ProductLogger", true)
local SupportedContainer = makeScreen("SupportedContainer", true)
local GamepassList = makeScreen("GamepassList", true)

local ToastStroke = create("UIStroke", {Color = col.white, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
local Toast = create("TextLabel", {
    Name = "Toast",
    AnchorPoint = Vector2.new(0.5, 1),
    Position = UDim2.new(0.5, 0, 0.875, -6),
    Size = UDim2.fromOffset(0, 26),
    AutomaticSize = Enum.AutomaticSize.X,
    BackgroundColor3 = col.panel,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    FontFace = fontReg,
    TextSize = 14,
    TextColor3 = col.white,
    TextTransparency = 1,
    Text = "",
    ZIndex = 20,
    Parent = Main,
}, {
    corner(13),
    create("UIPadding", {PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)}),
    ToastStroke,
})
table.insert(fadeExclude, Toast)

local toastId = 0
local function toast(text, color)
    toastId += 1
    local id = toastId
    Toast.TextColor3 = color or col.white
    Toast.Position = UDim2.new(0.5, 0, 0.875, 4)
    tween(Toast, 0.3, {BackgroundTransparency = 0, TextTransparency = 0, Position = UDim2.new(0.5, 0, 0.875, -6)})
    tween(ToastStroke, 0.3, {Transparency = 0.8})
    scramble(Toast, text, 0.25)
    task.delay(1.8, function()
        if id ~= toastId then return end
        tween(Toast, 0.3, {BackgroundTransparency = 1, TextTransparency = 1})
        tween(ToastStroke, 0.3, {Transparency = 1})
    end)
end

label({
    Name = "Subhead",
    Text = "Fakes gamepass/product purchases.",
    FontFace = fontItalic,
    Size = UDim2.fromScale(0.824, 0.107),
    Position = UDim2.fromScale(0.5, 0.088),
    Parent = HomeScreen,
})

local function linkLabel(text, color, y, link)
    local lbl = label({
        Name = "Link",
        Text = text,
        TextColor3 = color,
        Size = UDim2.fromScale(0.824, 0.107),
        Position = UDim2.fromScale(0.5, y),
        Active = true,
        Parent = HomeScreen,
    })
    lbl.MouseEnter:Connect(function() tween(lbl, 0.15, {TextColor3 = color:Lerp(col.white, 0.45)}) end)
    lbl.MouseLeave:Connect(function() tween(lbl, 0.2, {TextColor3 = color}) end)
    lbl.InputBegan:Connect(function(input)
        if not isClick(input) then return end
        if copy(link) then toast("Copied " .. link)
        else toast("Clipboard unavailable", col.red) end
    end)
end

linkLabel("YouTube: @vaehz", col.red, 0.297, "https://youtube.com/@vaehz")
linkLabel("Discord: discord.gg/vaehz", col.blue, 0.404, "https://discord.gg/vaehz")
linkLabel("Website: RobloxExploit.org", col.yellow, 0.511, "https://robloxexploit.org")

label({
    Name = "Notice",
    Text = "THIS WONT WORK ON MAJORITY OF GAMES, GET SOME KNOWLEDGE BEFORE COMPLAINING THAT THIS DOESNT WORK. SUPPORTED GAMES LIST CAN BE FOUND AT THE BOTTOM OF THIS UI.",
    Size = UDim2.fromScale(0.824, 0.222),
    Position = UDim2.fromScale(0.4988, 0.833),
    Parent = HomeScreen,
})

local idInputPos = UDim2.fromScale(0.0122, 0)

local IdStroke = stroke()
local IdInput = create("Frame", {
    Name = "IdInput",
    Position = idInputPos,
    Size = UDim2.fromScale(0.5805, 0.1838),
    BackgroundColor3 = col.panel,
    BorderSizePixel = 0,
    Parent = FakerScreen,
}, {corner(), IdStroke})

local InpBox = create("TextBox", {
    Name = "InpBox",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromScale(0.9076, 0.4651),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    FontFace = fontInput,
    PlaceholderText = "Paste ID here",
    PlaceholderColor3 = col.dim,
    Text = "",
    TextColor3 = col.white,
    TextScaled = true,
    TextWrapped = true,
    TextXAlignment = Enum.TextXAlignment.Left,
    ClearTextOnFocus = false,
    Parent = IdInput,
})

InpBox.Focused:Connect(function()
    tween(IdStroke, 0.2, {Transparency = 0.55})
    tween(IdInput, 0.2, {BackgroundColor3 = col.panelHi})
end)

local FakeButton = create("ImageButton", {
    Name = "FakePurchaseBtn",
    Position = UDim2.fromScale(0.5976, 0),
    Size = UDim2.fromScale(0.3878, 0.1838),
    BackgroundColor3 = col.panel,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    ImageTransparency = 1,
    Parent = FakerScreen,
}, {corner(), stroke(), create("UIScale")})

label({
    Name = "Label",
    Text = "Fake it!",
    FontFace = fontBold,
    Size = UDim2.fromScale(0.8176, 0.4651),
    Position = UDim2.fromScale(0.5, 0.5),
    Parent = FakeButton,
})

buttonFx(FakeButton, {BackgroundColor3 = col.panel}, {BackgroundColor3 = col.buttonHi})

label({
    Name = "Notice",
    Text = "Please note that this will NOT work in majority of games. Please do your research before complaining that this script is broken. At the bottom you'll find a list of games this supports.",
    Size = UDim2.fromScale(0.8244, 0.2222),
    Position = UDim2.fromScale(0.4841, 0.8889),
    Parent = FakerScreen,
})

local function shake(obj, base)
    task.spawn(function()
        for _, o in ipairs({7, -6, 4, -3, 2, 0}) do
            tween(obj, 0.04, {Position = base + UDim2.fromOffset(o, 0)}, Enum.EasingStyle.Sine)
            task.wait(0.04)
        end
        obj.Position = base
    end)
end

local function makeRow(list, data, actionImage, onAction)
    local row = create("Frame", {
        Name = "Row",
        Size = UDim2.new(1, -8, 0, 66),
        BackgroundColor3 = col.panel,
        BorderSizePixel = 0,
        LayoutOrder = data.order or 0,
    }, {corner(), stroke()})
    row:SetAttribute("IsRow", true)

    create("ImageLabel", {
        Name = "Icon",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 35, 0.5, 0),
        Size = UDim2.fromOffset(49, 49),
        BackgroundColor3 = col.button,
        BorderSizePixel = 0,
        Image = data.icon or "",
        ScaleType = Enum.ScaleType.Crop,
        Parent = row,
    }, {corner(), stroke()})

    label({
        Name = "Title",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 71, 0, 24),
        Size = UDim2.new(1, -120, 0, 17),
        Text = data.title or "",
        FontFace = fontBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    label({
        Name = "Sub",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 71, 0, 41),
        Size = UDim2.new(1, -120, 0, 17),
        Text = data.sub or "",
        TextColor3 = col.icon,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local action = create("ImageButton", {
        Name = "Action",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(1, -30, 0.5, 0),
        Size = UDim2.fromOffset(32, 32),
        BackgroundColor3 = col.button,
        BorderSizePixel = 0,
        Image = actionImage,
        ImageColor3 = col.icon,
        AutoButtonColor = false,
        Parent = row,
    }, {corner(), stroke(), create("UIScale")})
    buttonFx(action)
    action.MouseButton1Click:Connect(onAction)

    if data.onClick then
        row.InputBegan:Connect(function(input)
            if isClick(input) then data.onClick() end
        end)
    end

    row.MouseEnter:Connect(function() tween(row, 0.15, {BackgroundColor3 = col.panelHi}) end)
    row.MouseLeave:Connect(function() tween(row, 0.2, {BackgroundColor3 = col.panel}) end)

    row.Parent = list

    if list.Visible and Main.Visible then
        fade(row, 0, 0)
        fade(row, 1, 0.3)
    end
    return row
end

local function clearList(list)
    for _, child in ipairs(list:GetChildren()) do
        if child:GetAttribute("IsRow") then child:Destroy() end
    end
end

local function copyId(id)
    if copy(id) then toast("Copied " .. tostring(id), col.green)
    else toast("Clipboard unavailable", col.red) end
end

local tabs = {
    {name = "Home", button = HomeButton, screen = HomeScreen},
    {name = "Faker", button = FakerButton, screen = FakerScreen},
    {name = "Logger", button = LoggerButton, screen = ProductLogger},
    {name = "Supported", button = SupportedButton, screen = SupportedContainer},
    {name = "Passes", button = PassListButton, screen = GamepassList},
}

local navActive = {BackgroundColor3 = col.active, ImageColor3 = col.white}
local currentTab
local scanProducts
local loadSupported

local function moveIndicator(instant)
    if not currentTab then return end
    local btn = tabs[currentTab].button
    local s = MainScale.Scale > 0 and MainScale.Scale or 1
    local x = (btn.AbsolutePosition.X + btn.AbsoluteSize.X / 2 - BottomBar.AbsolutePosition.X) / s
    local pos = UDim2.new(0, x, 1, -2)
    if instant then Indicator.Position = pos
    else tween(Indicator, 0.4, {Position = pos}) end
end

local function setTab(index, instant)
    if index == currentTab then return end
    local prev = currentTab
    local dir = (prev and index < prev) and -1 or 1
    currentTab = index

    for i, tab in ipairs(tabs) do
        local goal = i == index and navActive or idle
        if instant then
            for k, v in pairs(goal) do tab.button[k] = v end
        else
            tween(tab.button, 0.2, goal)
        end
    end
    moveIndicator(instant)

    if prev then
        local old = tabs[prev].screen
        if instant then
            old.Visible = false
        else
            fade(old, 0, 0.15)
            tween(old, 0.25, {Position = UDim2.fromScale(-0.06 * dir, 0)})
            task.delay(0.25, function()
                if tabs[currentTab].screen ~= old then old.Visible = false end
            end)
        end
    end

    local screen = tabs[index].screen
    screen.Visible = true
    if instant then
        screen.Position = UDim2.new()
        fade(screen, 1, 0)
    else
        screen.Position = UDim2.fromScale(0.06 * dir, 0)
        fade(screen, 0, 0)
        tween(screen, 0.4, {Position = UDim2.new()})
        fade(screen, 1, 0.3)
    end
end

local function setTabByName(name)
    for i, tab in ipairs(tabs) do
        if tab.name == name then
            setTab(i)
            return
        end
    end
end

for i, tab in ipairs(tabs) do
    buttonFx(tab.button, idle, hover, function() return currentTab == i end)
    tab.button.MouseButton1Click:Connect(function()
        if currentTab == i and tab.name == "Passes" and scanProducts then
            scanProducts()
        elseif currentTab == i and tab.name == "Supported" and loadSupported then
            loadSupported()
        else
            setTab(i)
        end
    end)
end

BottomBar:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() moveIndicator(true) end)
BottomBar:GetPropertyChangedSignal("AbsolutePosition"):Connect(function() moveIndicator(true) end)

do
    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if not isClick(input) then return end
        dragging, dragStart, startPos = true, input.Position, Main.Position
        local c
        c = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                c:Disconnect()
            end
        end)
    end)
    bind(UserInputService.InputChanged, function(input)
        if not dragging then return end
        local t = input.UserInputType
        if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then
            local d = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

local ascii = {}
do
    local font = Enum.Font.Code
    local huge = Vector2.new(1e5, 1e5)
    local size = asciiCfg.textSize
    local cw = TextService:GetTextSize(string.rep("M", 40), size, font, huge).X / 40
    local h1 = TextService:GetTextSize("M", size, font, huge).Y
    local h11 = TextService:GetTextSize(string.rep("M\n", 10) .. "M", size, font, huge).Y
    local ch = (h11 - h1) / 10
    if cw <= 0 then cw = size * 0.6 end
    if ch <= 0 then ch = size end

    local layers = {
        {min = 0.1, transparency = 0.84},
        {min = 0.4, transparency = 0.62},
        {min = 0.7, transparency = 0.3},
    }

    local labels = {}
    for i in ipairs(layers) do
        labels[i] = create("TextLabel", {
            Name = "Layer" .. i,
            BackgroundTransparency = 1,
            Font = font,
            TextSize = size,
            TextColor3 = asciiCfg.color,
            TextTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = false,
            RichText = false,
            Text = "",
            ZIndex = 1,
            Parent = AsciiHolder,
        })
    end

    local ramp = {}
    for i = 1, #asciiCfg.ramp do ramp[i] = asciiCfg.ramp:sub(i, i) end
    local rampLen = #ramp

    local cols, rows, offX, offY = 0, 0, 0, 0
    local glow = {}
    local bufs = {{}, {}, {}}
    local lines = {{}, {}, {}}

    function ascii.rebuild(area, inner)
        cols = math.max(1, math.floor(area.X / cw))
        rows = math.max(1, math.floor(area.Y / ch))
        offX = (area.X - cols * cw) / 2
        offY = (area.Y - rows * ch) / 2
        for _, l in ipairs(labels) do
            l.Position = UDim2.fromOffset(offX, offY)
            l.Size = UDim2.fromOffset(cols * cw + 4, rows * ch + 4)
        end
        local cx, cy = area.X / 2, area.Y / 2
        local hw, hh = inner.X / 2, inner.Y / 2
        local pad = asciiCfg.padding
        table.clear(glow)
        for y = 0, rows - 1 do
            local qy = math.max(math.abs(offY + (y + 0.5) * ch - cy) - hh, 0)
            for x = 0, cols - 1 do
                local qx = math.max(math.abs(offX + (x + 0.5) * cw - cx) - hw, 0)
                local i = y * cols + x + 1
                if qx == 0 and qy == 0 then
                    glow[i] = -1
                else
                    local g = math.clamp(1 - math.sqrt(qx * qx + qy * qy) / pad, 0, 1)
                    glow[i] = g * g * (3 - 2 * g)
                end
            end
        end
        for _, b in ipairs(bufs) do table.clear(b) end
    end

    local noise, sin, cos, sqrt, exp, floor = math.noise, math.sin, math.cos, math.sqrt, math.exp, math.floor
    local min1, min2, min3 = layers[1].min, layers[2].min, layers[3].min
    local aspect = ch / cw

    function ascii.render(t, alpha, mx, my)
        local mcx, mcy
        if mx then mcx, mcy = (mx - offX) / cw, (my - offY) / ch end
        local b1, b2, b3 = bufs[1], bufs[2], bufs[3]
        local l1, l2, l3 = lines[1], lines[2], lines[3]
        for y = 0, rows - 1 do
            local base = y * cols
            local ny = y * 0.11 - t * 0.35
            local wy = cos(y * 0.21 - t * 0.7)
            for x = 0, cols - 1 do
                local g = glow[base + x + 1]
                local c1, c2, c3 = " ", " ", " "
                if g > 0 then
                    local v = 0.45 + noise(x * 0.055, ny, t * 0.12) * 1.3 + sin(x * 0.12 + t * 1.1) * wy * 0.18
                    if mcx then
                        local dx, dy = x - mcx, (y - mcy) * aspect
                        local d = sqrt(dx * dx + dy * dy)
                        v += sin(d * 0.45 - t * 7) * exp(-d * 0.09) * 0.45
                    end
                    v *= g * alpha
                    if v >= min1 then
                        local idx = math.clamp(floor(v * rampLen) + 1, 2, rampLen)
                        local glyph = ramp[idx]
                        if v >= min3 then c3 = glyph
                        elseif v >= min2 then c2 = glyph
                        else c1 = glyph end
                    end
                end
                b1[x + 1], b2[x + 1], b3[x + 1] = c1, c2, c3
            end
            l1[y + 1] = table.concat(b1, "", 1, cols)
            l2[y + 1] = table.concat(b2, "", 1, cols)
            l3[y + 1] = table.concat(b3, "", 1, cols)
        end
        labels[1].Text = table.concat(l1, "\n", 1, rows)
        labels[2].Text = table.concat(l2, "\n", 1, rows)
        labels[3].Text = table.concat(l3, "\n", 1, rows)
        for i, layer in ipairs(layers) do
            labels[i].TextTransparency = 1 - (1 - layer.transparency) * alpha
        end
    end
end

local asciiAlpha = Instance.new("NumberValue")

do
    local acc, lastArea = 0, nil
    local start = os.clock()
    bind(RunService.RenderStepped, function(dt)
        AsciiHolder.Position = Main.Position
        if not asciiCfg.enabled then return end
        local alpha = asciiAlpha.Value
        if alpha <= 0.001 then return end
        acc += dt
        if acc < 1 / asciiCfg.fps then return end
        acc = 0
        local s = MainScale.Scale > 0 and MainScale.Scale or 1
        local abs = Main.AbsoluteSize
        local inner = Vector2.new(math.floor(abs.X / s + 0.5), math.floor(abs.Y / s + 0.5))
        local area = inner + Vector2.new(asciiCfg.padding * 2, asciiCfg.padding * 2)
        if area ~= lastArea then
            lastArea = area
            AsciiHolder.Size = UDim2.fromOffset(area.X, area.Y)
            ascii.rebuild(area, inner)
        end
        local mx, my
        if asciiCfg.mouse then
            local m = UserInputService:GetMouseLocation() - AsciiHolder.AbsolutePosition
            if m.X >= 0 and m.Y >= 0 and m.X <= area.X and m.Y <= area.Y then
                mx, my = m.X, m.Y
            end
        end
        ascii.render(os.clock() - start, alpha, mx, my)
    end)
end

local UI = {}
local isOpen, destroyed = false, false

local function open()
    if isOpen or destroyed then return end
    isOpen = true
    Main.Visible = true
    AsciiHolder.Visible = asciiCfg.enabled
    MainScale.Scale = 0.88
    fade(Main, 0, 0)
    tween(MainScale, 0.55, {Scale = 1}, Enum.EasingStyle.Back)
    fade(Main, 1, 0.35)
    tween(asciiAlpha, 1, {Value = 1}, Enum.EasingStyle.Sine)
    scramble(Title, title, 0.6)
    task.defer(moveIndicator, true)
end

local function hide(callback)
    if not isOpen then
        if callback then callback() end
        return
    end
    isOpen = false
    tween(MainScale, 0.25, {Scale = 0.9}, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    fade(Main, 0, 0.22)
    tween(asciiAlpha, 0.35, {Value = 0}, Enum.EasingStyle.Quad)
    task.delay(0.36, function()
        if not isOpen then
            Main.Visible = false
            AsciiHolder.Visible = false
        end
        if callback then callback() end
    end)
end

function UI.Toggle()
    if destroyed then return end
    if isOpen then hide() else open() end
end

function UI.Destroy(instant)
    if destroyed then return end
    destroyed = true
    local function finish()
        for _, c in ipairs(connections) do c:Disconnect() end
        asciiAlpha:Destroy()
        ScreenGui:Destroy()
        if env.__ProductFaker == UI then env.__ProductFaker = nil end
    end
    if instant then finish() else hide(finish) end
end

-- Remplace le bouton fermer pour qu'il cache au lieu de détruire
CloseButton.MouseButton1Click:Connect(function()
    if UI and UI.Toggle then UI.Toggle() end
end)

bind(UserInputService.InputBegan, function(input, gpe)
    if not gpe and input.KeyCode == toggleKey then
        if UI and UI.Toggle then UI.Toggle() end
    end
end)

local knownKinds = {}
local infoTypes = {
    Product = getEnum("InfoType", "Product"),
    Gamepass = getEnum("InfoType", "GamePass"),
    Asset = getEnum("InfoType", "Asset"),
    Bundle = getEnum("InfoType", "Bundle"),
    Subscription = getEnum("InfoType", "Subscription"),
}

local infoCache = {}
local function getInfo(kind, id)
    local key = kind .. ":" .. tostring(id)
    if infoCache[key] ~= nil then return infoCache[key] end
    local info = false
    if infoTypes[kind] and tonumber(id) then
        local ok, res = pcall(function()
            return MarketplaceService:GetProductInfo(tonumber(id), infoTypes[kind])
        end)
        if ok and type(res) == "table" then info = res end
    end
    infoCache[key] = info
    return info
end

local function sendToFaker(id)
    InpBox.Text = tostring(id)
    setTabByName("Faker")
    toast("ID loaded: " .. tostring(id))
end

local fire = {
    Product = function(id) MarketplaceService:SignalPromptProductPurchaseFinished(LocalPlayer.UserId, id, true) end,
    Gamepass = function(id) MarketplaceService:SignalPromptGamePassPurchaseFinished(LocalPlayer, id, true) end,
    Asset = function(id) MarketplaceService:SignalPromptPurchaseFinished(LocalPlayer, id, true) end,
    Bundle = function(id) MarketplaceService:SignalPromptBundlePurchaseFinished(LocalPlayer, id, true) end,
}

local function detectKind(id)
    local known = knownKinds[tostring(id)]
    if known and fire[known] then return known end
    for _, kind in ipairs({"Product", "Gamepass", "Asset"}) do
        if getInfo(kind, id) then
            knownKinds[tostring(id)] = kind
            return kind
        end
    end
    return "Product"
end

local function fakePurchase(id)
    local kind = detectKind(id)
    fire[kind](id)
    return kind
end

local function submitFake()
    local id = tonumber((InpBox.Text:gsub("%s", "")):match("^%d+$"))
    if not id then
        shake(IdInput, idInputPos)
        IdStroke.Color = col.red
        IdStroke.Transparency = 0.3
        tween(IdStroke, 0.6, {Color = col.white, Transparency = 0.86})
        toast("Enter a valid ID", col.red)
        return
    end
    local ok, res = pcall(fakePurchase, id)
    if ok then toast("Fired " .. res:lower() .. " " .. id, col.green)
    else warn("[Product Faker] " .. tostring(res)) toast("Error, check console", col.red) end
end

FakeButton.MouseButton1Click:Connect(submitFake)
InpBox.FocusLost:Connect(function(enterPressed)
    tween(IdStroke, 0.2, {Transparency = 0.86})
    tween(IdInput, 0.2, {BackgroundColor3 = col.panel})
    if enterPressed then submitFake() end
end)

-- ... (le reste du fichier reste inchangé) ...

setTab(1, true)
env.__ProductFaker = UI
-- PAS d'open() automatique

function VAZ.BuildFakerTab(ui)
    ui:AddModule("rspy", "Explorer", {
        name = "Product Faker V2",
        desc = "Clique pour ouvrir/fermer le Product Faker",
        callback = function()
            if UI and UI.Toggle then
                UI.Toggle()
            end
        end
    })
end

if VAZ.NotifyUI then VAZ.NotifyUI("Product Faker V2 prêt") end
print("✅ Partie 10/10 chargée - Product Faker V2 (ouverture manuelle)")
