-- ULTRA SIMPLE FISH IT SCRIPT
-- Tanpa loadstring, tanpa HTTP request, tanpa library external

-- Anti-error wrapper
local function protect(func)
    return function(...)
        local success, result = pcall(func, ...)
        return success and result or nil
    end
end

-- Hapus GUI lama dengan aman
protect(function()
    local oldGui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("FishItGUI")
    if oldGui then oldGui:Destroy() end
end)()

-- Variables aman
local player = game:GetService("Players").LocalPlayer
local rs = game:GetService("ReplicatedStorage")

-- Cari remote dengan aman (tanpa error)
local function findRemotes()
    local remotes = {}
    local success = pcall(function()
        local packages = rs:FindFirstChild("Packages")
        if not packages then return end
        
        local index = packages:FindFirstChild("_Index")
        if not index then return end
        
        for _, folder in pairs(index:GetChildren()) do
            if type(folder.Name) == "string" and folder.Name:find("sleitnick_net") then
                local net = folder:FindFirstChild("net")
                if net then
                    for _, remote in pairs(net:GetChildren()) do
                        remotes[remote.Name] = remote
                    end
                end
                break
            end
        end
    end)
    return remotes
end

local Remotes = findRemotes()

-- UI Sederhana (Roblox native, tanpa external)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FishItGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 300)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BackgroundTransparency = 0.1
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Text = "Fish It - Simple"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = mainFrame

-- Status indicator
local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -10, 0, 20)
statusText.Position = UDim2.new(0, 5, 0, 35)
statusText.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
statusText.Text = "Status: Ready"
statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
statusText.Font = Enum.Font.SourceSans
statusText.TextSize = 14
statusText.Parent = mainFrame

-- Auto Fishing Toggle
local autoFishBtn = Instance.new("TextButton")
autoFishBtn.Size = UDim2.new(1, -20, 0, 35)
autoFishBtn.Position = UDim2.new(0, 10, 0, 65)
autoFishBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
autoFishBtn.Text = "Auto Fishing: OFF"
autoFishBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoFishBtn.Font = Enum.Font.SourceSansBold
autoFishBtn.TextSize = 16
autoFishBtn.Parent = mainFrame

-- Auto Sell Toggle
local autoSellBtn = Instance.new("TextButton")
autoSellBtn.Size = UDim2.new(1, -20, 0, 35)
autoSellBtn.Position = UDim2.new(0, 10, 0, 105)
autoSellBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
autoSellBtn.Text = "Auto Sell: OFF"
autoSellBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoSellBtn.Font = Enum.Font.SourceSansBold
autoSellBtn.TextSize = 16
autoSellBtn.Parent = mainFrame

-- Auto Buy Toggle
local autoBuyBtn = Instance.new("TextButton")
autoBuyBtn.Size = UDim2.new(1, -20, 0, 35)
autoBuyBtn.Position = UDim2.new(0, 10, 0, 145)
autoBuyBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
autoBuyBtn.Text = "Auto Buy: OFF"
autoBuyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBuyBtn.Font = Enum.Font.SourceSansBold
autoBuyBtn.TextSize = 16
autoBuyBtn.Parent = mainFrame

-- Manual Buttons
local chargeBtn = Instance.new("TextButton")
chargeBtn.Size = UDim2.new(0.45, -5, 0, 30)
chargeBtn.Position = UDim2.new(0, 10, 0, 190)
chargeBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
chargeBtn.Text = "Charge"
chargeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
chargeBtn.Font = Enum.Font.SourceSans
chargeBtn.TextSize = 14
chargeBtn.Parent = mainFrame

local sellBtn = Instance.new("TextButton")
sellBtn.Size = UDim2.new(0.45, -5, 0, 30)
sellBtn.Position = UDim2.new(0.55, -5, 0, 190)
sellBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
sellBtn.Text = "Sell All"
sellBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
sellBtn.Font = Enum.Font.SourceSans
sellBtn.TextSize = 14
sellBtn.Parent = mainFrame

local luckBtn = Instance.new("TextButton")
luckBtn.Size = UDim2.new(0.45, -5, 0, 30)
luckBtn.Position = UDim2.new(0, 10, 0, 225)
luckBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
luckBtn.Text = "Buy Luck"
luckBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
luckBtn.Font = Enum.Font.SourceSans
luckBtn.TextSize = 14
luckBtn.Parent = mainFrame

local shinyBtn = Instance.new("TextButton")
shinyBtn.Size = UDim2.new(0.45, -5, 0, 30)
shinyBtn.Position = UDim2.new(0.55, -5, 0, 225)
shinyBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
shinyBtn.Text = "Buy Shiny"
shinyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
shinyBtn.Font = Enum.Font.SourceSans
shinyBtn.TextSize = 14
shinyBtn.Parent = mainFrame

local equipBtn = Instance.new("TextButton")
equipBtn.Size = UDim2.new(1, -20, 0, 30)
equipBtn.Position = UDim2.new(0, 10, 0, 260)
equipBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
equipBtn.Text = "Equip Rod (Slot 1)"
equipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
equipBtn.Font = Enum.Font.SourceSans
equipBtn.TextSize = 14
equipBtn.Parent = mainFrame

-- Status variables
local autoFishing = false
local autoSell = false
local autoBuy = false
local buyCounter = 0

-- Fungsi aman untuk invoke remote
local function safeInvoke(remoteName, ...)
    local remote = Remotes[remoteName]
    if remote and remote.ClassName == "RemoteFunction" then
        return pcall(function()
            return remote:InvokeServer(...)
        end)
    elseif remote and remote.ClassName == "RemoteEvent" then
        return pcall(function()
            remote:FireServer(...)
            return true
        end)
    end
    return false, "Remote not found"
end

-- Button callbacks (semua dilindungi pcall)
chargeBtn.MouseButton1Click:Connect(function()
    local success, result = safeInvoke("RF/ChargeFishingRod")
    statusText.Text = success and "Charged!" or "Charge failed"
    statusText.TextColor3 = success and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    wait(1)
    statusText.Text = "Status: Ready"
    statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
end)

sellBtn.MouseButton1Click:Connect(function()
    local success, result = safeInvoke("RF/SellAllItems")
    statusText.Text = success and "Sold!" or "Sell failed"
    statusText.TextColor3 = success and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    wait(1)
    statusText.Text = "Status: Ready"
    statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
end)

luckBtn.MouseButton1Click:Connect(function()
    local success, result = safeInvoke("RF/PurchaseMarketItem", 5)
    statusText.Text = success and "Luck bought!" or "Buy failed"
    statusText.TextColor3 = success and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    wait(1)
    statusText.Text = "Status: Ready"
    statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
end)

shinyBtn.MouseButton1Click:Connect(function()
    local success, result = safeInvoke("RF/PurchaseMarketItem", 7)
    statusText.Text = success and "Shiny bought!" or "Buy failed"
    statusText.TextColor3 = success and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    wait(1)
    statusText.Text = "Status: Ready"
    statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
end)

equipBtn.MouseButton1Click:Connect(function()
    local success, result = safeInvoke("RE/EquipToolFromHotbar", 1)
    statusText.Text = success and "Equipped!" or "Equip failed"
    statusText.TextColor3 = success and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    wait(1)
    statusText.Text = "Status: Ready"
    statusText.TextColor3 = Color3.fromRGB(0, 255, 0)
end)

-- Toggle buttons
autoFishBtn.MouseButton1Click:Connect(function()
    autoFishing = not autoFishing
    autoFishBtn.BackgroundColor3 = autoFishing and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    autoFishBtn.Text = autoFishing and "Auto Fishing: ON" or "Auto Fishing: OFF"
    statusText.Text = autoFishing and "Auto Fishing Started" or "Auto Fishing Stopped"
    wait(1)
    statusText.Text = "Status: Ready"
end)

autoSellBtn.MouseButton1Click:Connect(function()
    autoSell = not autoSell
    autoSellBtn.BackgroundColor3 = autoSell and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    autoSellBtn.Text = autoSell and "Auto Sell: ON" or "Auto Sell: OFF"
end)

autoBuyBtn.MouseButton1Click:Connect(function()
    autoBuy = not autoBuy
    autoBuyBtn.BackgroundColor3 = autoBuy and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    autoBuyBtn.Text = autoBuy and "Auto Buy: ON" or "Auto Buy: OFF"
end)

-- Main loops dengan interval aman
spawn(function()
    while true do
        wait(2) -- Interval 2 detik untuk fishing
        if autoFishing then
            pcall(function()
                safeInvoke("RF/ChargeFishingRod")
                wait(0.5)
                safeInvoke("RF/CatchFishCompleted")
            end)
        end
    end
end)

spawn(function()
    while true do
        wait(30) -- Interval 30 detik untuk sell
        if autoSell then
            pcall(function()
                safeInvoke("RF/SellAllItems")
            end)
        end
    end
end)

spawn(function()
    while true do
        wait(45) -- Interval 45 detik untuk buy
        if autoBuy then
            pcall(function()
                buyCounter = buyCounter + 1
                local itemId = (buyCounter % 2 == 1) and 5 or 7
                safeInvoke("RF/PurchaseMarketItem", itemId)
            end)
        end
    end
end)

-- Info remote status
local remoteStatus = Instance.new("TextLabel")
remoteStatus.Size = UDim2.new(1, -10, 0, 20)
remoteStatus.Position = UDim2.new(0, 5, 1, -25)
remoteStatus.BackgroundTransparency = 1
remoteStatus.Text = #Remotes > 0 and "✅ Remotes: " .. #Remotes .. " found" or "❌ No remotes found"
remoteStatus.TextColor3 = #Remotes > 0 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
remoteStatus.Font = Enum.Font.SourceSans
remoteStatus.TextSize = 12
remoteStatus.TextXAlignment = Enum.TextXAlignment.Left
remoteStatus.Parent = mainFrame

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 60, 0, 25)
closeBtn.Position = UDim2.new(1, -65, 0, 3)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 16
closeBtn.Parent = mainFrame

closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)
