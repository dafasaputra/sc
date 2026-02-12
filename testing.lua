-- Load Rayfield UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("NikeeHUB", "Ocean")

-- Create Window
local Window = Rayfield:CreateWindow({
    Name = "NikeeHUB | Enhanced",
    LoadingTitle = "NikeeHUB",
    LoadingSubtitle = "by Nikee",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "NikeeHUB",
        FileName = "Config"
    },
    KeySystem = false
})

-- ==================== CONFIGURATION ====================
local Config = {
    -- Fishing settings
    FishingEnabled = false,
    CompleteDelay = 0.7,
    CastDelay = 0.1,
    ClaimAmount = 3,
    RandomizeDelay = true,
    DelayVariance = 0.15,
    
    -- Auto Sell settings
    AutoSellEnabled = false,
    SellThreshold = 80,          -- Sell when inventory slots >= 80% full
    SellInterval = 60,          -- seconds between sell checks
    
    -- Anti AFK settings
    AntiAfkEnabled = false,
    
    -- Status
    FishCaught = 0,
    CurrentStatus = "Idle",
    
    -- Internal flags
    FishingThread = nil,
    AntiAfkThread = nil,
    AutoSellThread = nil
}

-- ==================== REMOTE PATHS ====================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- Robust remote loading with error handling
local function getRemotes()
    local netPackage = ReplicatedStorage:FindFirstChild("Packages")
    if not netPackage then return nil end
    
    local indexFolder = netPackage:FindFirstChild("_Index")
    if not indexFolder then return nil end
    
    local netPath = nil
    for _, v in pairs(indexFolder:GetChildren()) do
        if v.Name:find("sleitnick_net") then
            netPath = v:FindFirstChild("net")
            if netPath then break end
        end
    end
    
    if not netPath then
        Rayfield:Notify({Title = "Error", Content = "Net library not found!", Duration = 5})
        return nil
    end
    
    local remotes = {
        Charge = netPath:FindFirstChild("RF/ChargeFishingRod"),
        Request = netPath:FindFirstChild("RF/RequestFishingMinigameStarted"),
        Cancel = netPath:FindFirstChild("RF/CancelFishingInputs"),
        Claim = netPath:FindFirstChild("RF/CatchFishCompleted")
    }
    
    -- Verify all remotes exist
    for name, remote in pairs(remotes) do
        if not remote then
            Rayfield:Notify({Title = "Error", Content = "Remote " .. name .. " not found!", Duration = 5})
            return nil
        end
    end
    
    return remotes
end

local Remotes = getRemotes()
if not Remotes then return end

-- ==================== UI TABS ====================
local MainTab = Window:CreateTab("Fishing", 4483362458)
local SellTab = Window:CreateTab("Auto Sell", 6026568198)  -- Example icon ID
local MiscTab = Window:CreateTab("Misc", 6034818372)      -- Example icon ID
local StatusTab = Window:CreateTab("Status", 6034849626)

-- ==================== UI ELEMENTS ====================
-- Main Tab
MainTab:CreateToggle({
    Name = "Auto Fish",
    CurrentValue = false,
    Flag = "AutoFishToggle",
    Callback = function(Value)
        Config.FishingEnabled = Value
        if Value then
            Config.CurrentStatus = "Fishing"
            startFishingCycle()
        else
            Config.CurrentStatus = "Stopped"
            stopFishingCycle()
        end
    end
})

MainTab:CreateSlider({
    Name = "Complete Delay (seconds)",
    Range = {0.1, 3.0},
    Increment = 0.01,
    Suffix = "s",
    CurrentValue = Config.CompleteDelay,
    Flag = "CompleteDelaySlider",
    Callback = function(Value)
        Config.CompleteDelay = Value
    end
})

MainTab:CreateSlider({
    Name = "Cast Delay (seconds)",
    Range = {0.05, 2.0},
    Increment = 0.01,
    Suffix = "s",
    CurrentValue = Config.CastDelay,
    Flag = "CastDelaySlider",
    Callback = function(Value)
        Config.CastDelay = Value
    end
})

MainTab:CreateSlider({
    Name = "Claim Amount per Fish",
    Range = {1, 10},
    Increment = 1,
    Suffix = "x",
    CurrentValue = Config.ClaimAmount,
    Flag = "ClaimAmountSlider",
    Callback = function(Value)
        Config.ClaimAmount = Value
    end
})

MainTab:CreateToggle({
    Name = "Randomize Delays (Anti-Pattern)",
    CurrentValue = Config.RandomizeDelay,
    Flag = "RandomizeDelayToggle",
    Callback = function(Value)
        Config.RandomizeDelay = Value
    end
})

MainTab:CreateSlider({
    Name = "Delay Variance (±s)",
    Range = {0.0, 0.5},
    Increment = 0.01,
    Suffix = "s",
    CurrentValue = Config.DelayVariance,
    Flag = "DelayVarianceSlider",
    Callback = function(Value)
        Config.DelayVariance = Value
    end
})

-- Sell Tab
SellTab:CreateToggle({
    Name = "Auto Sell Fish",
    CurrentValue = false,
    Flag = "AutoSellToggle",
    Callback = function(Value)
        Config.AutoSellEnabled = Value
        if Value then
            startAutoSell()
        else
            stopAutoSell()
        end
    end
})

SellTab:CreateSlider({
    Name = "Inventory Threshold (%)",
    Range = {10, 100},
    Increment = 5,
    Suffix = "%",
    CurrentValue = Config.SellThreshold,
    Flag = "SellThresholdSlider",
    Callback = function(Value)
        Config.SellThreshold = Value
    end
})

SellTab:CreateSlider({
    Name = "Sell Check Interval (s)",
    Range = {10, 300},
    Increment = 5,
    Suffix = "s",
    CurrentValue = Config.SellInterval,
    Flag = "SellIntervalSlider",
    Callback = function(Value)
        Config.SellInterval = Value
    end
})

-- Misc Tab
MiscTab:CreateToggle({
    Name = "Anti AFK",
    CurrentValue = false,
    Flag = "AntiAfkToggle",
    Callback = function(Value)
        Config.AntiAfkEnabled = Value
        if Value then
            startAntiAfk()
        else
            stopAntiAfk()
        end
    end
})

MiscTab:CreateButton({
    Name = "Reconnect Remotes",
    Callback = function()
        Remotes = getRemotes()
        if Remotes then
            Rayfield:Notify({Title = "Success", Content = "Remotes reloaded", Duration = 3})
        end
    end
})

-- Status Tab
local StatusLabel = StatusTab:CreateLabel("Status: Idle")
local FishCountLabel = StatusTab:CreateLabel("Fish Caught: 0")
local RunTimeLabel = StatusTab:CreateLabel("Runtime: 0s")

-- ==================== FISHING CORE LOGIC ====================
local fishingRunning = false

local function getRandomDelay(base, variance)
    if not Config.RandomizeDelay or variance == 0 then
        return base
    end
    return base + (math.random() * variance * 2 - variance)
end

local function safeInvoke(remote, ...)
    local success, result = pcall(function()
        return remote:InvokeServer(...)
    end)
    return success, result
end

local function doFishingCycle()
    if not Remotes then return end
    
    -- 1. Cancel any ongoing fishing
    safeInvoke(Remotes.Cancel)
    
    -- 2. Charge rod
    safeInvoke(Remotes.Charge)
    task.wait(0.05)  -- small buffer
    
    -- 3. Request minigame with dynamic arguments
    local args = {
        -1.233184814453125 + (math.random() * 0.01 - 0.005),  -- slight variation
        0.0017426679483021346 + (math.random() * 0.0001 - 0.00005),
        tick() + (math.random() * 0.001)  -- precise timestamp
    }
    
    local success = safeInvoke(Remotes.Request, unpack(args))
    if not success then
        task.wait(1)
        return
    end
    
    -- 4. Wait for fish to bite
    local waitTime = getRandomDelay(Config.CompleteDelay, Config.DelayVariance)
    task.wait(waitTime)
    
    -- 5. Claim rewards multiple times (for double/triple claims)
    for i = 1, Config.ClaimAmount do
        local claimSuccess = safeInvoke(Remotes.Claim)
        if claimSuccess then
            Config.FishCaught = Config.FishCaught + 1
        end
        task.wait(0.03)  -- small gap between claims
    end
    
    -- 6. Post-cast delay
    local castWait = getRandomDelay(Config.CastDelay, Config.DelayVariance)
    task.wait(castWait)
end

function startFishingCycle()
    if fishingRunning then return end
    if not Config.FishingEnabled then return end
    
    fishingRunning = true
    Config.FishingThread = task.spawn(function()
        while Config.FishingEnabled and fishingRunning and Remotes do
            local success = pcall(doFishingCycle)
            if not success then
                task.wait(2)  -- wait longer on error
            end
            task.wait()  -- yield to prevent 100% CPU
        end
        fishingRunning = false
    end)
end

function stopFishingCycle()
    fishingRunning = false
    Config.FishingThread = nil
end

-- ==================== AUTO SELL ====================
local sellRunning = false

-- Find your inventory or selling NPC – adjust to your game!
local function getInventoryCount()
    -- Placeholder: replace with actual inventory scanning logic
    -- Example: check backpack or a specific folder
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        local count = 0
        for _ in pairs(backpack:GetChildren()) do
            count = count + 1
        end
        return count
    end
    return 0
end

local function getMaxInventory()
    -- Placeholder: adjust based on game
    return 20
end

local function sellFish()
    -- Placeholder: trigger sell action, e.g., remote or NPC proximity
    -- This depends on the game. Example:
    -- local sellRemote = ReplicatedStorage:FindFirstChild("SellFish")
    -- if sellRemote then sellRemote:InvokeServer() end
    Rayfield:Notify({Title = "Auto Sell", Content = "Selling fish...", Duration = 3})
end

function startAutoSell()
    if sellRunning then return end
    sellRunning = true
    Config.AutoSellThread = task.spawn(function()
        while Config.AutoSellEnabled and sellRunning do
            task.wait(Config.SellInterval)
            if not Config.AutoSellEnabled then break end
            
            local invCount = getInventoryCount()
            local maxInv = getMaxInventory()
            if invCount >= maxInv * (Config.SellThreshold / 100) then
                pcall(sellFish)
            end
        end
        sellRunning = false
    end)
end

function stopAutoSell()
    sellRunning = false
    Config.AutoSellThread = nil
end

-- ==================== ANTI AFK ====================
local afkRunning = false

function startAntiAfk()
    if afkRunning then return end
    afkRunning = true
    Config.AntiAfkThread = task.spawn(function()
        while Config.AntiAfkEnabled and afkRunning do
            task.wait(60)  -- every minute
            if not Config.AntiAfkEnabled then break end
            -- Simulate player activity
            LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
            -- Also move camera slightly
            local camera = workspace.CurrentCamera
            if camera then
                camera.CFrame = camera.CFrame * CFrame.Angles(0, math.rad(0.5), 0)
            end
        end
        afkRunning = false
    end)
end

function stopAntiAfk()
    afkRunning = false
    Config.AntiAfkThread = nil
end

-- ==================== STATUS UPDATER ====================
task.spawn(function()
    local startTime = tick()
    while true do
        if Config.FishingEnabled then
            Config.CurrentStatus = "Fishing"
        elseif Config.AutoSellEnabled or Config.AntiAfkEnabled then
            Config.CurrentStatus = "Other"
        else
            Config.CurrentStatus = "Idle"
        end
        
        StatusLabel:Set("Status: " .. Config.CurrentStatus)
        FishCountLabel:Set("Fish Caught: " .. Config.FishCaught)
        
        local runtime = math.floor(tick() - startTime)
        local hours = math.floor(runtime / 3600)
        local minutes = math.floor((runtime % 3600) / 60)
        local seconds = runtime % 60
        RunTimeLabel:Set(string.format("Runtime: %02d:%02d:%02d", hours, minutes, seconds))
        
        task.wait(1)
    end
end)

-- ==================== CLEANUP ON SCRIPT END ====================
-- Not strictly necessary, but good practice
game:GetService("RunService"):BindToClose(function()
    Config.FishingEnabled = false
    Config.AutoSellEnabled = false
    Config.AntiAfkEnabled = false
    fishingRunning = false
    sellRunning = false
    afkRunning = false
end)

Rayfield:Notify({
    Title = "Script Loaded",
    Content = "NikeeHUB Enhanced ready!",
    Duration = 5
})

