-- Script Fish It - Versi Ultra Stabil
-- Tanpa library rumit, menggunakan UI sederhana

-- Variables
local player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Cari Net dengan aman
local Net = nil
local function findNet()
    local packages = ReplicatedStorage:FindFirstChild("Packages")
    if packages then
        local index = packages:FindFirstChild("_Index")
        if index then
            for _, v in pairs(index:GetChildren()) do
                if v.Name:find("sleitnick_net") then
                    local net = v:FindFirstChild("net")
                    if net then
                        return net
                    end
                end
            end
        end
    end
    return nil
end

Net = findNet()

-- Remote events
local Remotes = {}
if Net then
    Remotes = {
        EquipRod = Net:FindFirstChild("RE/EquipToolFromHotbar"),
        SellAll = Net:FindFirstChild("RF/SellAllItems"),
        Charge = Net:FindFirstChild("RF/ChargeFishingRod"),
        Request = Net:FindFirstChild("RF/RequestFishingMinigameStarted"),
        Catch = Net:FindFirstChild("RF/CatchFishCompleted"),
        Purchase = Net:FindFirstChild("RF/PurchaseMarketItem"),
        Cancel = Net:FindFirstChild("RF/CancelFishingInputs")
    }
end

-- Status
local isRunning = {
    autoFishing = false,
    autoSell = false,
    autoBuy = false
}

-- UI Sederhana (ScreenGui)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FishItGUI"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame utama
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Judul
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "Fish It Script by OxyX"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 18
title.Parent = mainFrame

-- Scroll frame untuk buttons
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, -35)
scrollFrame.Position = UDim2.new(0, 0, 0, 35)
scrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
scrollFrame.ScrollBarThickness = 8
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Parent = scrollFrame
layout.Padding = UDim.new(0, 5)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Fungsi membuat button
function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Parent = scrollFrame
    
    btn.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    
    return btn
end

-- Fungsi membuat toggle
function createToggle(text, varName)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.9, 0, 0, 35)
    frame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    frame.Parent = scrollFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, 0, 0.8, 0)
    btn.Position = UDim2.new(0.75, 0, 0.1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = frame
    
    btn.MouseButton1Click:Connect(function()
        pcall(function()
            isRunning[varName] = not isRunning[varName]
            if isRunning[varName] then
                btn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                btn.Text = "ON"
            else
                btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                btn.Text = "OFF"
            end
        end)
    end)
end

-- Buat UI
createToggle("Auto Fishing", "autoFishing")
createToggle("Auto Sell", "autoSell")
createToggle("Auto Buy (Luck/Shiny)", "autoBuy")

-- Separator
local sep = Instance.new("Frame")
sep.Size = UDim2.new(0.9, 0, 0, 2)
sep.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sep.BackgroundTransparency = 0.7
sep.Parent = scrollFrame

-- Buttons
createButton("Charge Rod", function()
    if Remotes.Charge then
        Remotes.Charge:InvokeServer()
    end
end)

createButton("Cancel Fishing", function()
    if Remotes.Cancel then
        Remotes.Cancel:InvokeServer(true)
    end
end)

createButton("Sell All", function()
    if Remotes.SellAll then
        Remotes.SellAll:InvokeServer()
    end
end)

createButton("Buy Luck (ID 5)", function()
    if Remotes.Purchase then
        Remotes.Purchase:InvokeServer(5)
    end
end)

createButton("Buy Shiny (ID 7)", function()
    if Remotes.Purchase then
        Remotes.Purchase:InvokeServer(7)
    end
end)

createButton("Equip Rod (Slot 1)", function()
    if Remotes.EquipRod then
        Remotes.EquipRod:FireServer(1)
    end
end)

-- Auto Fishing Loop
spawn(function()
    while true do
        wait(0.1)
        pcall(function()
            if isRunning.autoFishing and Remotes.Charge and Remotes.Catch then
                Remotes.Charge:InvokeServer()
                wait(0.5)
                Remotes.Catch:InvokeServer()
                wait(0.5)
            end
        end)
    end
end)

-- Auto Sell Loop
spawn(function()
    while true do
        wait(30)
        pcall(function()
            if isRunning.autoSell and Remotes.SellAll then
                Remotes.SellAll:InvokeServer()
            end
        end)
    end
end)

-- Auto Buy Loop (bergantian Luck dan Shiny)
local buyCounter = 0
spawn(function()
    while true do
        wait(60)
        pcall(function()
            if isRunning.autoBuy and Remotes.Purchase then
                buyCounter = buyCounter + 1
                if buyCounter % 2 == 1 then
                    Remotes.Purchase:InvokeServer(5) -- Luck
                else
                    Remotes.Purchase:InvokeServer(7) -- Shiny
                end
            end
        end)
    end
end)

-- Update canvas size
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end)

-- Notifikasi sederhana
local notification = Instance.new("TextLabel")
notification.Size = UDim2.new(0.8, 0, 0, 30)
notification.Position = UDim2.new(0.1, 0, 0.8, 0)
notification.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
notification.BackgroundTransparency = 0.3
notification.Text = "Script Loaded!"
notification.TextColor3 = Color3.fromRGB(0, 0, 0)
notification.Font = Enum.Font.SourceSansBold
notification.TextSize = 16
notification.Parent = screenGui

-- Hilangkan notifikasi setelah 2 detik
wait(2)
notification:Destroy()
