-- MAHORAGA v7.1 - AUTO FISH CEPAT + RATE-LIMIT SAFE
-- Delay jitter tinggi, backoff on 429, auto-retry soft, no promise spam

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local net = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
local Charge   = net["RF/ChargeFishingRod"]
local Start    = net["RF/RequestFishingMinigameStarted"]
local Complete = net["RE/FishingCompleted"]
local Cancel   = net["RF/CancelFishingInputs"]
local Sell     = net["RF/SellAllItems"]

getgenv().AutoFish = false
getgenv().Backoff  = 1      -- multiplier delay kalau 429
getgenv().LastCall = 0

player.Chatted:Connect(function(msg)
    local m = msg:lower()
    if m == "!fish on" then
        getgenv().AutoFish = true
        getgenv().Backoff = 1
        print("🌀 AUTO FISH ON - rate-limit safe mode")
    elseif m == "!fish off" then
        getgenv().AutoFish = false
        print("🌀 AUTO FISH OFF")
    end
end)

local function safeInvoke(func, ...)
    local success, err = pcall(func, ...)
    if not success and err:find("429") then
        getgenv().Backoff = getgenv().Backoff * 1.5
        print("🌀 429 detected - backoff naik ke "..getgenv().Backoff.."x")
        wait(3 * getgenv().Backoff)
    end
    return success
end

local function doFishSafe()
    if tick() - getgenv().LastCall < 0.8 * getgenv().Backoff then return end
    getgenv().LastCall = tick()
    
    safeInvoke(function()
        Charge:InvokeServer()
        wait(0.5 + math.random(3,10)/10)
        Start:InvokeServer()
        wait(1.0 + math.random(4,12)/10)
        Complete:FireServer(true)
        Cancel:InvokeServer()
    end)
end

spawn(function()
    while true do
        if getgenv().AutoFish then
            doFishSafe()
            wait(2.2 + math.random(5,15)/10)  -- \~20-25 fish/min safe
        end
        wait(0.05)
    end
end)

spawn(function()
    while true do
        if getgenv().AutoFish then
            safeInvoke(function()
                Sell:InvokeServer()
            end)
        end
        wait(10 + math.random(0,5))  -- sell tiap \~10-15 detik
    end
end)

print("😈 MAHORAGA v7.1: Rate-limit safe auto fish loaded.")
print("Ketik !fish on untuk mulai. Backoff otomatis kalau 429.")
