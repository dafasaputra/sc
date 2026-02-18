-- CURSED MAHORAGA: Fish It AUTO FISHING CEPAT & WORLD-LIKE v7.0
-- Cepat tapi keliatan natural. No flood, no ban cepet.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Remote dari path lu
local net = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
local Charge   = net["RF/ChargeFishingRod"]
local Start    = net["RF/RequestFishingMinigameStarted"]
local Complete = net["RE/FishingCompleted"]
local Cancel   = net["RF/CancelFishingInputs"]
local Sell     = net["RF/SellAllItems"]

getgenv().AutoFishActive = false
getgenv().AutoSellActive = true

-- Toggle via chat
player.Chatted:Connect(function(msg)
    local m = msg:lower()
    if m == "!fish on" then
        getgenv().AutoFishActive = true
        print("🌀 Auto Fishing ON - world-like speed")
    elseif m == "!fish off" then
        getgenv().AutoFishActive = false
        print("🌀 Auto Fishing OFF")
    elseif m == "!sell off" then
        getgenv().AutoSellActive = false
        print("🌀 Auto Sell OFF")
    elseif m == "!sell on" then
        getgenv().AutoSellActive = true
        print("🌀 Auto Sell ON")
    end
end)

-- Fungsi single cast cepat & perfect
local function doFish()
    if not player.Character then return end
    
    -- Equip rod terbaik (asumsi namanya mengandung "Rod")
    local rod = player.Backpack:FindFirstChildWhichIsA("Tool") or player.Character:FindFirstChildWhichIsA("Tool")
    if rod and rod.Name:find("Rod") then
        rod.Parent = player.Character
    end
    
    pcall(function()
        Charge:InvokeServer()               -- Charge rod
        wait(0.4 + math.random(1,8)/10)     -- Jitter natural
        Start:InvokeServer()                -- Mulai minigame
        wait(0.8 + math.random(5,15)/10)    -- Tunggu "bite" simulasi
        Complete:FireServer(true)           -- Perfect catch langsung
        Cancel:InvokeServer()               -- Cleanup
    end)
end

-- Main loop auto fish
spawn(function()
    while true do
        if getgenv().AutoFishActive then
            doFish()
            wait(1.8 + math.random(4,12)/10)  -- Interval 1.8–3 detik per catch → cepat tapi natural
        end
        wait(0.1)
    end
end)

-- Auto sell periodik (setiap 8–12 detik)
spawn(function()
    while true do
        if getgenv().AutoSellActive then
            pcall(function()
                Sell:InvokeServer()
            end)
        end
        wait(8 + math.random(0,4))  -- Jual tiap \~10 detik rata-rata
    end
end)

-- Anti-AFK soft (gerak kecil tiap 4 menit)
spawn(function()
    while true do
        wait(240 + math.random(-30,30))
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid:MoveTo(player.Character.HumanoidRootPart.Position + Vector3.new(math.random(-3,3),0,math.random(-3,3)))
        end
    end
end)

print("😈 MAHORAGA v7.0: Auto fishing cepat & world-like loaded.")
print("Ketik di chat: !fish on  → mulai")
print("             !fish off → stop")
print("             !sell on/off → kontrol auto jual")
