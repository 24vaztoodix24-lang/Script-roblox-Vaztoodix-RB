-- PARTIE 11/11 - Product Faker Simple (compatible Delta)
-- Source : https://pastefy.app/yVlxzwk8/raw
-- Intégré par Vaztoodix

getgenv().VAZ = getgenv().VAZ or {}
local VAZ = getgenv().VAZ

local ProductFakerSimple = {}
local isOpen, destroyed = false, false

local function CreateFakerGUI()
    if destroyed then return end
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ProductFakerSimple"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not ScreenGui.Parent then ScreenGui.Parent = game.Players.LocalPlayer.PlayerGui end

    -- Title Bar
    local TitleBar = Instance.new("TextButton")
    TitleBar.Font = Enum.Font.GothamBold
    TitleBar.Text = "Product Faker (Simple)"
    TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleBar.TextSize = 16
    TitleBar.AutoButtonColor = false
    TitleBar.BackgroundColor3 = Color3.fromRGB(46, 46, 46)
    TitleBar.BorderSizePixel = 0
    TitleBar.Position = UDim2.new(0.35, 0, 0.3, 0)
    TitleBar.Size = UDim2.new(0, 252, 0, 35)
    TitleBar.Parent = ScreenGui
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 6)

    -- Minimize
    local MinButton = Instance.new("TextButton")
    MinButton.Text = "-"
    MinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinButton.TextSize = 18
    MinButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    MinButton.BorderSizePixel = 0
    MinButton.Position = UDim2.new(0, 2, 0, 2.5)
    MinButton.Size = UDim2.new(0, 30, 0, 30)
    MinButton.Parent = TitleBar
    Instance.new("UICorner", MinButton).CornerRadius = UDim.new(0, 6)

    -- Close (cache au lieu de détruire)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 18
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.BorderSizePixel = 0
    CloseButton.Position = UDim2.new(1, -32, 0, 2.5)
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Parent = TitleBar
    Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 6)

    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.BackgroundColor3 = Color3.fromRGB(46, 46, 46)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0, 0, 1, 2)
    MainFrame.Size = UDim2.new(0, 252, 0, 441)
    MainFrame.Parent = TitleBar
    Instance.new("UICorner", MainFrame)
    local FrameStroke = Instance.new("UIStroke", MainFrame)
    FrameStroke.Color = Color3.fromRGB(113, 113, 113)

    -- Global Buy All
    local GlobalBuyButton = Instance.new("TextButton")
    GlobalBuyButton.Text = "Loading..."
    GlobalBuyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    GlobalBuyButton.TextSize = 12
    GlobalBuyButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    GlobalBuyButton.BorderSizePixel = 0
    GlobalBuyButton.Position = UDim2.new(0.025, 0, 0.015, 0)
    GlobalBuyButton.Size = UDim2.new(0.95, 0, 0, 30)
    GlobalBuyButton.Parent = MainFrame
    Instance.new("UICorner", GlobalBuyButton).CornerRadius = UDim.new(0, 6)

    -- Scrolling
    local ScrollingFrame = Instance.new("ScrollingFrame")
    ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollingFrame.ScrollBarThickness = 5
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.BorderSizePixel = 0
    ScrollingFrame.Position = UDim2.new(0, 0, 0, 38)
    ScrollingFrame.Size = UDim2.new(1, 0, 1, -38)
    ScrollingFrame.Parent = MainFrame
    local ListLayout = Instance.new("UIListLayout", ScrollingFrame)

    local MarketplaceService = game:GetService("MarketplaceService")
    local TweenService = game:GetService("TweenService")
    local LocalPlayer = game.Players.LocalPlayer

    local success, developerProducts = pcall(function()
        return MarketplaceService:GetDeveloperProductsAsync():GetCurrentPage()
    end)
    if not success then developerProducts = {} end

    GlobalBuyButton.Text = "Buy All Products (" .. #developerProducts .. ")"

    for _, product in pairs(developerProducts) do
        local row = Instance.new("Frame")
        row.BackgroundTransparency = 1
        row.Size = UDim2.new(1, 0, 0, 85)
        row.Parent = ScrollingFrame

        local HoverBg = Instance.new("Frame", row)
        HoverBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        HoverBg.BackgroundTransparency = 1
        HoverBg.Size = UDim2.new(1, 0, 1, 0)
        Instance.new("UICorner", HoverBg).CornerRadius = UDim.new(0, 6)

        local NameLabel = Instance.new("TextLabel", row)
        NameLabel.Text = "Name: " .. (product.Name or "N/A")
        NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        NameLabel.TextSize = 14
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.BackgroundTransparency = 1
        NameLabel.Position = UDim2.new(0.048, 0, 0.15, 0)
        NameLabel.Size = UDim2.new(0, 200, 0, 21)

        local IDLabel = Instance.new("TextLabel", row)
        IDLabel.Text = "ID: " .. (product.ProductId or "N/A")
        IDLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        IDLabel.TextSize = 14
        IDLabel.TextXAlignment = Enum.TextXAlignment.Left
        IDLabel.BackgroundTransparency = 1
        IDLabel.Position = UDim2.new(0.048, 0, 0.4, 0)
        IDLabel.Size = UDim2.new(0, 108, 0, 21)

        local PriceLabel = Instance.new("TextLabel", row)
        PriceLabel.Text = "Price: " .. (product.PriceInRobux or "N/A")
        PriceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        PriceLabel.TextSize = 14
        PriceLabel.TextXAlignment = Enum.TextXAlignment.Left
        PriceLabel.BackgroundTransparency = 1
        PriceLabel.Position = UDim2.new(0.048, 0, 0.65, 0)
        PriceLabel.Size = UDim2.new(0, 108, 0, 21)

        local CopyButton = Instance.new("TextButton", row)
        CopyButton.Text = "Copy ID"
        CopyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        CopyButton.TextSize = 11
        CopyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        CopyButton.BorderSizePixel = 0
        CopyButton.Position = UDim2.new(0.65, 0, 0.12, 0)
        CopyButton.Size = UDim2.new(0, 80, 0, 20)
        Instance.new("UICorner", CopyButton).CornerRadius = UDim.new(0, 4)

        local AutoBuyButton = Instance.new("TextButton", row)
        AutoBuyButton.Text = "Auto Buy"
        AutoBuyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        AutoBuyButton.TextSize = 11
        AutoBuyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        AutoBuyButton.BorderSizePixel = 0
        AutoBuyButton.Position = UDim2.new(0.65, 0, 0.41, 0)
        AutoBuyButton.Size = UDim2.new(0, 80, 0, 20)
        Instance.new("UICorner", AutoBuyButton).CornerRadius = UDim.new(0, 4)

        local BuyButton = Instance.new("TextButton", row)
        BuyButton.Text = "Buy Product"
        BuyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        BuyButton.TextSize = 11
        BuyButton.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        BuyButton.BorderSizePixel = 0
        BuyButton.Position = UDim2.new(0.65, 0, 0.70, 0)
        BuyButton.Size = UDim2.new(0, 80, 0, 20)
        Instance.new("UICorner", BuyButton).CornerRadius = UDim.new(0, 4)

        -- Copy ID
        CopyButton.MouseButton1Click:Connect(function()
            pcall(function() setclipboard(tostring(product.ProductId)) end)
            CopyButton.Text = "Copied!"
            CopyButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
            task.wait(1)
            CopyButton.Text = "Copy ID"
            CopyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        end)

        -- Buy Product
        BuyButton.MouseButton1Click:Connect(function()
            BuyButton.Text = "Buying.."
            MarketplaceService:SignalPromptProductPurchaseFinished(LocalPlayer.UserId, product.ProductId, true)
            task.wait(1)
            BuyButton.Text = "Buy Product"
        end)

        -- Auto Buy Toggle
        local autoActive = false
        AutoBuyButton.MouseButton1Click:Connect(function()
            autoActive = not autoActive
            if autoActive then
                AutoBuyButton.Text = "Auto: ON"
                AutoBuyButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
                task.spawn(function()
                    while autoActive and row.Parent do
                        MarketplaceService:SignalPromptProductPurchaseFinished(LocalPlayer.UserId, product.ProductId, true)
                        task.wait(0.1)
                    end
                end)
            else
                AutoBuyButton.Text = "Auto Buy"
                AutoBuyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
            end
        end)
    end

    -- Global Buy All
    GlobalBuyButton.MouseButton1Click:Connect(function()
        GlobalBuyButton.Text = "Processing..."
        for _, product in pairs(developerProducts) do
            MarketplaceService:SignalPromptProductPurchaseFinished(LocalPlayer.UserId, product.ProductId, true)
            task.wait(0.01)
        end
        GlobalBuyButton.Text = "Done!"
        task.wait(3)
        GlobalBuyButton.Text = "Buy All Products (" .. #developerProducts .. ")"
    end)

    -- Minimize
    MinButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
        MinButton.Text = MainFrame.Visible and "-" or "+"
    end)

    -- Close (cache)
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui.Enabled = false
    end)

    -- Drag
    local dragging, dragInput, mousePos, framePos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = TitleBar.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            TitleBar.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)

    return ScreenGui
end

local fakerGui = nil

function ProductFakerSimple.Toggle()
    if destroyed then return end
    if fakerGui and fakerGui.Parent then
        fakerGui.Enabled = not fakerGui.Enabled
        isOpen = fakerGui.Enabled
    else
        fakerGui = CreateFakerGUI()
        isOpen = true
    end
end

-- Intégration Vaztoodix
function VAZ.BuildFakerSimpleTab(ui)
    ui:AddModule("rspy", "Explorer", {
        name = "Product Faker Simple",
        desc = "Version simple et légère (compatible Delta mobile)",
        callback = function()
            ProductFakerSimple.Toggle()
        end
    })
end

if VAZ.NotifyUI then VAZ.NotifyUI("Product Faker Simple prêt") end
print("✅ Partie 11/11 chargée - Product Faker Simple (Delta)")
