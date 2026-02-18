-- SENTOT FISH IT 2026 - VELOCITY + LYNX UI + REMOTES DARI DUMP LU
-- Auto resolve CatchFish / CatchFishCompleted + semua remote lain

-- LYNX UI FULL SOURCE EMBEDDED
local Lynx = {}

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer

local function create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    return obj
end

local function tween(obj, info, props)
    TweenService:Create(obj, info or TweenInfo.new(0.25), props):Play()
end

local function makeDraggable(frame)
    local dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragInput = nil end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    RunService.RenderStepped:Connect(function()
        if dragInput then
            local delta = dragInput.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function Lynx:CreateWindow(title, size)
    size = size or Vector2.new(420, 300)
    local sg = create("ScreenGui", {Name = "SentotLynx", Parent = game.CoreGui, ResetOnSpawn = false})
    local main = create("Frame", {
        Size = UDim2.new(0, size.X, 0, size.Y),
        Position = UDim2.new(0.5, -size.X/2, 0.5, -size.Y/2),
        BackgroundColor3 = Color3.fromRGB(18, 18, 18),
        BorderSizePixel = 0,
        Parent = sg
    })
    create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = main})
    create("UIStroke", {Color = Color3.fromRGB(40, 40, 40), Thickness = 1, Parent = main})

    local titleBar = create("Frame", {Size = UDim2.new(1,0,0,36), BackgroundColor3 = Color3.fromRGB(25,25,25), Parent = main})
    create("UICorner", {CornerRadius = UDim.new(0,10), Parent = titleBar})
    create("TextLabel", {
        Size = UDim2.new(1,-80,1,0), Position = UDim2.new(0,12,0,0),
        BackgroundTransparency = 1, Text = title, TextColor3 = Color3.fromRGB(220,220,220),
        Font = Enum.Font.GothamBold, TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar
    })
    local close = create("TextButton", {
        Size = UDim2.new(0,28,0,28), Position = UDim2.new(1,-38,0,4),
        BackgroundColor3 = Color3.fromRGB(220,60,60), Text = "X", TextColor3 = Color3.new(1,1,1),
        Font = Enum.Font.GothamBold, TextSize = 14, Parent = titleBar
    })
    create("UICorner", {CornerRadius = UDim.new(0,6), Parent = close})
    close.MouseButton1Click:Connect(function() tween(main, nil, {Size=UDim2.new()}) task.delay(0.3, function() sg:Destroy() end) end)

    makeDraggable(titleBar)

    local tabFrame = create("Frame", {Size = UDim2.new(0,140,1,-36), Position = UDim2.new(0,0,0,36), BackgroundTransparency = 1, Parent = main})
    local contentFrame = create("Frame", {Size = UDim2.new(1,-140,1,-36), Position = UDim2.new(0,140,0,36), BackgroundTransparency = 1, Parent = main})

    local window = {}
    local currentContent = nil

    function window:CreateTab(name)
        local btn = create("TextButton", {
            Size = UDim2.new(1,-10,0,34), BackgroundColor3 = Color3.fromRGB(32,32,32),
            Text = name, TextColor3 = Color3.fromRGB(160,160,160), Font = Enum.Font.GothamSemibold, TextSize = 13,
            Parent = tabFrame
        })
        create("UICorner", {CornerRadius = UDim.new(0,6), Parent = btn})

        local tabContent = create("Frame", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false, Parent = contentFrame})
        create("UIPadding", {PaddingLeft = UDim.new(0,12), PaddingRight = UDim.new(0,12), PaddingTop = UDim.new(0,12), Parent = tabContent})

        btn.MouseButton1Click:Connect(function()
            if currentContent then currentContent.Visible = false end
            tabContent.Visible = true
            currentContent = tabContent
            tween(btn, nil, {BackgroundColor3 = Color3.fromRGB(55,55,55), TextColor3 = Color3.new(1,1,1)})
            for _, b in tabFrame:GetChildren() do
                if b:IsA("TextButton") and b ~= btn then
                    tween(b, nil, {BackgroundColor3 = Color3.fromRGB(32,32,32), TextColor3 = Color3.fromRGB(160,160,160)})
                end
            end
        end)

        local tab = {}
        function tab:CreateToggle(name, default, callback)
            local f = create("Frame", {Size = UDim2.new(1,0,0,32), BackgroundTransparency = 1, Parent = tabContent})
            create("TextLabel", {Size = UDim2.new(0.75,0,1,0), BackgroundTransparency = 1, Text = name, TextColor3 = Color3.fromRGB(210,210,210),
                Font = Enum.Font.GothamSemibold, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = f})
            local box = create("Frame", {Size = UDim2.new(0,42,0,22), Position = UDim2.new(1,-52,0.5,-11), BackgroundColor3 = Color3.fromRGB(45,45,45), Parent = f})
            create("UICorner", {CornerRadius = UDim.new(1,0), Parent = box})
            local cir = create("Frame", {Size = UDim2.new(0,18,0,18), Position = UDim2.new(0,2,0.5,-9), BackgroundColor3 = Color3.fromRGB(90,90,90), Parent = box})
            create("UICorner", {CornerRadius = UDim.new(1,0), Parent = cir})

            local state = default or false
            local function upd()
                if state then
                    tween(box, nil, {BackgroundColor3 = Color3.fromRGB(0,170,255)})
                    tween(cir, nil, {Position = UDim2.new(0,22,0.5,-9)})
                else
                    tween(box, nil, {BackgroundColor3 = Color3.fromRGB(45,45,45)})
                    tween(cir, nil, {Position = UDim2.new(0,2,0.5,-9)})
                end
            end
            upd()

            box.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then state = not state upd() callback(state) end end)
        end

        function tab:CreateButton(name, callback)
            local btn = create("TextButton", {
                Size = UDim2.new(1,0,0,36), BackgroundColor3 = Color3.fromRGB(40,40,40), Text = name,
                TextColor3 = Color3.new(1,1,1), Font = Enum.Font.GothamSemibold, TextSize = 14, Parent = tabContent
            })
            create("UICorner", {CornerRadius = UDim.new(0,8), Parent = btn})
            btn.MouseButton1Click:Connect(callback)
        end

        return tab
    end

    return window
end

-- REMOTES RESOLVER (dari dump lu + brute)
local RS = game:GetService("ReplicatedStorage")
local net = RS.Packages._Index["sleitnick_net@0.2.0"].net

local remotes = {}

-- Prioritas dari dump lu
remotes.Equip   = net["RE/EquipToolFromHotbar"]
remotes.SellAll = net["RF/SellAllItems"]
remotes.Charge  = net["RF/ChargeFishingRod"]
remotes.Request = net["RF/RequestFishingMinigameStarted"]
remotes.Catch   = net["RE/CatchFishCompleted"] or net["RE/CatchFish"] or net["RE/CompleteCatch"] or net["RE/FinishFishing"] or net["RE/ReelSuccess"]
remotes.Cancel  = net["RF/CancelFishingInputs"]
remotes.BuyItem = net["RF/PurchaseMarketItem"]

-- Brute scan kalau salah satu nil
if not remotes.Catch then
    for _, child in ipairs(net:GetChildren()) do
        local n = child.Name:lower()
        if (child:IsA("RemoteEvent") or child:IsA("RemoteFunction")) and (n:find("catch") or n:find("complete") or n:find("reel") or n:find("finish") or n:find("success")) then
            remotes.Catch = child
            break
        end
    end
end

local AutoFishEnabled = false

local function equipRod()
    pcall(function() if remotes.Equip then remotes.Equip:FireServer(1) end end)
end

local function performCatch()
    pcall(function()
        if remotes.Charge then remotes.Charge:InvokeServer() end
        task.wait(0.6 + math.random()/5)
        if remotes.Request then remotes.Request:InvokeServer(-5718742609204048, -0.397660581386669, 1771146782.714026) end
        task.wait(1.0 + math.random()/3)
        if remotes.Catch then remotes.Catch:FireServer(true) end
        if remotes.Cancel then remotes.Cancel:InvokeServer(true) end
    end)
end

spawn(function()
    while true do
        if AutoFishEnabled then
            equipRod()
            performCatch()
            task.wait(3.0 + math.random(5,15)/10) -- 3-4.5 detik per catch
        end
        task.wait(0.05)
    end
end)

spawn(function()
    while true do
        if AutoFishEnabled then
            pcall(function() if remotes.SellAll then remotes.SellAll:InvokeServer() end end)
        end
        task.wait(10 + math.random(5,10))
    end
end)

-- UI
local win = Lynx:CreateWindow("Sentot Fish It 2026 - Velocity")

local farmTab = win:CreateTab("Farm")
farmTab:CreateToggle("Auto Fish (Perfect Catch)", false, function(state)
    AutoFishEnabled = state
end)

farmTab:CreateButton("Sell All Now", function()
    pcall(function() if remotes.SellAll then remotes.SellAll:InvokeServer() end end)
end)

local shopTab = win:CreateTab("Shop")
shopTab:CreateButton("Buy Luck (5)", function()
    pcall(function() if remotes.BuyItem then remotes.BuyItem:InvokeServer(5) end end)
end)

shopTab:CreateButton("Buy Shiny (7)", function()
    pcall(function() if remotes.BuyItem then remotes.BuyItem:InvokeServer(7) end end)
end)

print("SENTOT READY - UI muncul. Toggle Auto Fish di Farm tab. Remote auto-resolved dari dump lu.")
