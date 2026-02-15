-- SCRIPT AUTO FISH PALING SEDERHANA
-- TANPA ERROR "attempt to call nil value"

local Player = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Tunggu hingga game benar-benar load
wait(5)

print("🚀 Mencoba memuat script auto fish...")

-- Coba cari event dengan berbagai kemungkinan path
local function findEvent(...)
    local paths = {...}
    for _, path in ipairs(paths) do
        local obj = ReplicatedStorage
        local found = true
        for part in string.gmatch(path, "[^/]+") do
            obj = obj:FindFirstChild(part)
            if not obj then
                found = false
                break
            end
        end
        if found then
            return obj
        end
    end
    return nil
end

-- Cari event dengan multiple path possibilities
local ChargeRod = findEvent(
    "Packages/_Index/sleitnick_net@0.2.0/net/RF/ChargeFishingRod",
    "Packages/_Index/sleitnick_net/net/RF/ChargeFishingRod",
    "Packages/net/RF/ChargeFishingRod"
)

local CatchFish = findEvent(
    "Packages/_Index/sleitnick_net@0.2.0/net/RF/CatchFishCompleted",
    "Packages/_Index/sleitnick_net/net/RF/CatchFishCompleted",
    "Packages/net/RF/CatchFishCompleted"
)

local SellAll = findEvent(
    "Packages/_Index/sleitnick_net@0.2.0/net/RF/SellAllItems",
    "Packages/_Index/sleitnick_net/net/RF/SellAllItems",
    "Packages/net/RF/SellAllItems"
)

-- CEK EVENT YANG DITEMUKAN
print("📡 ChargeRod:", ChargeRod and "✅" or "❌")
print("📡 CatchFish:", CatchFish and "✅" or "❌")
print("📡 SellAll:", SellAll and "✅" or "❌")

-- UI SEDERHANA (TANPA FUNGSI KOMPLEKS)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 200, 0, 150)
Frame.Position = UDim2.new(0, 50, 0, 50)
Frame.BackgroundColor3 = Color3.new(0, 0, 0)
Frame.BackgroundTransparency = 0.3
Frame.Active = true
Frame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "AUTO FISH"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)

local Status = Instance.new("TextLabel")
Status.Parent = Frame
Status.Position = UDim2.new(0, 0, 0, 35)
Status.Size = UDim2.new(1, 0, 0, 30)
Status.Text = "Status: SIAP"
Status.TextColor3 = Color3.new(0, 1, 0)
Status.BackgroundTransparency = 1

local StartBtn = Instance.new("TextButton")
StartBtn.Parent = Frame
StartBtn.Position = UDim2.new(0, 10, 0, 70)
StartBtn.Size = UDim2.new(0, 80, 0, 30)
StartBtn.Text = "MULAI"
StartBtn.BackgroundColor3 = Color3.new(0, 0.5, 0)

local StopBtn = Instance.new("TextButton")
StopBtn.Parent = Frame
StopBtn.Position = UDim2.new(0, 100, 0, 70)
StopBtn.Size = UDim2.new(0, 80, 0, 30)
StopBtn.Text = "STOP"
StopBtn.BackgroundColor3 = Color3.new(0.5, 0, 0)

local SellBtn = Instance.new("TextButton")
SellBtn.Parent = Frame
SellBtn.Position = UDim2.new(0, 10, 0, 110)
SellBtn.Size = UDim2.new(0, 170, 0, 30)
SellBtn.Text = "JUAL SEMUA"
SellBtn.BackgroundColor3 = Color3.new(0.8, 0.4, 0)

-- VARIABEL
local fishing = false

-- FUNGSI DENGAN PENGECEKAN
local function safeInvoke(event)
    if event and typeof(event) == "Instance" and event:IsA("RemoteFunction") then
        local success, result = pcall(function()
            return event:InvokeServer()
        end)
        return success
    elseif event and typeof(event) == "Instance" and event:IsA("RemoteEvent") then
        pcall(function()
            event:FireServer()
        end)
        return true
    end
    return false
end

-- LOOP FISHING SEDERHANA
local function fishingLoop()
    while fishing do
        Status.Text = "Status: FISHING..."
        
        -- Charge
        safeInvoke(ChargeRod)
        wait(1)
        
        -- Catch
        safeInvoke(CatchFish)
        wait(0.5)
        
        Status.Text = "Status: DAPET IKAN"
        wait(1)
    end
end

-- EVENT BUTTON
StartBtn.MouseButton1Click:Connect(function()
    if not fishing then
        fishing = true
        Status.Text = "Status: MULAI"
        coroutine.wrap(fishingLoop)()
    end
end)

StopBtn.MouseButton1Click:Connect(function()
    fishing = false
    Status.Text = "Status: STOP"
end)

SellBtn.MouseButton1Click:Connect(function()
    Status.Text = "Status: MENJUAL..."
    safeInvoke(SellAll)
    wait(1)
    Status.Text = "Status: SIAP"
end)

print("✅ Script sederhana loaded - Semoga tidak error!")
