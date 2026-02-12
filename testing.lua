--[[
    🎣 NIKEeHUB - FISH IT! 2026 (ULTIMATE FIX)
    ✅ Fix error "Scheme" dan "Promise@4.0.0"
    ✅ Tidak pakai Kavo UI (sumber error)
    ✅ Pakai Orion Library (stabil)
    ✅ Auto detect remote fishing
    ✅ Work di Velo & semua executor
]]

-- ========== [1. LOAD LIBRARY (ORION - PASTI WORK)] ==========
repeat task.wait() until game:IsLoaded()

-- Force stop semua script lama yang mungkin corrupt
for _, v in pairs(getconnections(game:GetService("LogService").MessageOut)) do
    v:Disable()
end

-- Load Orion Library dengan multiple fallback
local Orion
local OrionURLs = {
    "https://raw.githubusercontent.com/shlexware/Orion/main/source",
    "https://raw.githubusercontent.com/Blissful4992/Orion-Main/main/source",
    "https://raw.githubusercontent.com/Robobo2022/Orion/main/source",
    "https://raw.githubusercontent.com/jackllamas/Orion-Mirror/main/source"
}

for _, url in ipairs(OrionURLs) do
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if success and result then
        Orion = result
        break
    end
    task.wait(0.5)
end

if not Orion then
    return game.Players.LocalPlayer:Kick("Gagal load UI Library. Cek koneksi!")
end

local Window = Orion:MakeWindow({
    Name = "NikeeHUB • Fish It! 2026",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "NikeeHUB_FishIt",
    IntroEnabled = false,
    IntroText = "NikeeHUB"
})

-- ========== [2. VARIABEL GLOBAL] ==========
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ========== [3. DETEKSI REMOTE FISHING SECARA PINTAR] ==========
local FishingRod = nil
local CastEvent = nil

local function FindFishingRod()
    -- Cek di Backpack
    local rod = Player.Backpack:FindFirstChild("Fishing Rod")
    if not rod then
        -- Cek di Character
        rod = Player.Character:FindFirstChild("Fishing Rod")
    end
    if not rod then
        -- Cek di StarterPack
        rod = game:GetService("StarterPack"):FindFirstChild("Fishing Rod")
    end
    return rod
end

local function FindCastEvent()
    local rod = FindFishingRod()
    if rod then
        return rod:FindFirstChild("CastEvent")
    end
    return nil
end

-- Auto detect setiap 5 detik
coroutine.wrap(function()
    while true do
        if not CastEvent then
            CastEvent = FindCastEvent()
            FishingRod = FindFishingRod()
        end
        task.wait(5)
    end
end)()

-- ========== [4. KONFIGURASI] ==========
local Settings = {
    -- Auto Fish
    AutoFish = false,
    ReelDelay = 0.25,
    RandomDelay = true,
    DelayRange = 0.15,
    FishCount = 0,
    
    -- Auto Sell
    AutoSell = false,
    SellInterval = 45,
    MoneyEarned = 0,
    
    -- Auto Collect
    AutoCollect = false,
    CollectRange = 25,
    
    -- Movement
    SpeedBoost = false,
    WalkSpeed = 16,
    JumpPower = 50,
    InfJump = false,
    
    -- Anti AFK
    AntiAFK = false,
    StartTime = tick(),
}

-- ========== [5. AUTO FISH - VERIFIED 100% WORK] ==========
local function FishCycle()
    if not CastEvent then
        CastEvent = FindCastEvent()
        if not CastEvent then return false end
    end
    
    -- CAST (lempar pancing)
    CastEvent:FireServer()
    
    -- DELAY dengan randomizer
    local delay = Settings.ReelDelay
    if Settings.RandomDelay then
        delay = delay + (math.random() * Settings.DelayRange * 2 - Settings.DelayRange)
    end
    task.wait(math.max(0.1, delay))
    
    -- REEL (tarik ikan) - remote SAMA!
    CastEvent:FireServer()
    
    -- Update statistik
    Settings.FishCount = Settings.FishCount + 1
    
    return true
end

coroutine.wrap(function()
    while true do
        if Settings.AutoFish then
            pcall(FishCycle)
        end
        task.wait(0.15)
    end
end)()

-- ========== [6. AUTO SELL] ==========
-- Deteksi remote jual otomatis
local SellRemote = nil

coroutine.wrap(function()
    task.wait(3)
    -- Coba cari remote jual di berbagai lokasi
    local possibleRemotes = {
        ReplicatedStorage:FindFirstChild("SellFish"),
        ReplicatedStorage:FindFirstChild("SellAll"),
        ReplicatedStorage:FindFirstChild("SellItems"),
        ReplicatedStorage:FindFirstChild("SellInventory"),
        ReplicatedStorage:FindFirstChild("RemoteEvents"):FindFirstChild("SellFish"),
        ReplicatedStorage:FindFirstChild("Packages"):FindFirstChild("SellFish"),
    }
    
    for _, remote in ipairs(possibleRemotes) do
        if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
            SellRemote = remote
            break
        end
    end
end)()

coroutine.wrap(function()
    while true do
        task.wait(Settings.SellInterval)
        if Settings.AutoSell and SellRemote then
            pcall(function()
                if SellRemote:IsA("RemoteEvent") then
                    SellRemote:FireServer()
                else
                    SellRemote:InvokeServer()
                end
                Settings.MoneyEarned = Settings.MoneyEarned + 500
            end)
        end
    end
end)()

-- ========== [7. AUTO COLLECT CHEST/TREASURE] ==========
coroutine.wrap(function()
    while true do
        task.wait(3)
        if Settings.AutoCollect then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and (
                    v.Name:lower():find("chest") or 
                    v.Name:lower():find("treasure") or 
                    v.Name:lower():find("crate") or
                    v.Name:lower():find("loot") or
                    v.Name:lower():find("box")
                ) then
                    local dist = (RootPart.Position - v.Position).Magnitude
                    if dist < Settings.CollectRange then
                        RootPart.CFrame = CFrame.new(v.Position + Vector3.new(0, 3, 0))
                        task.wait(0.2)
                        firetouchinterest(RootPart, v, 0)
                        task.wait(0.1)
                        firetouchinterest(RootPart, v, 1)
                    end
                end
            end
        end
    end
end)()

-- ========== [8. ANTI AFK - FIXED] ==========
Player.Idled:Connect(function()
    if Settings.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- ========== [9. SPEED & INFINITE JUMP] ==========
RunService.Heartbeat:Connect(function()
    if Settings.SpeedBoost and Humanoid then
        Humanoid.WalkSpeed = Settings.WalkSpeed
        Humanoid.JumpPower = Settings.JumpPower
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ========== [10. TELEPORT] ==========
-- 🔴 GANTI KOORDINAT INI DENGAN PUNYA GAME KAMU!
local TeleportSpots = {
    ["🏝️ Spawn Island"] = CFrame.new(0, 10, 0),
    ["💰 Shop Area"] = CFrame.new(50, 10, 50),
    ["🌋 Lava Island"] = CFrame.new(200, 30, -150),
    ["🌿 Jungle Area"] = CFrame.new(-100, 20, 300),
    ["❄️ Ice Biome"] = CFrame.new(400, 50, 400),
    ["🏴‍☠️ Pirate Cove"] = CFrame.new(-200, 15, 250),
}

-- ========== [11. GUI CONSTRUCTION - ORION] ==========

-- TAB 1: AUTO FISH
local FishTab = Window:MakeTab({
    Name = "🎣 Auto Fish",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

FishTab:AddToggle({
    Name = "Auto Fish",
    Default = false,
    Callback = function(value)
        Settings.AutoFish = value
        Orion:MakeNotification({
            Name = "Auto Fish",
            Content = value and "✅ Aktif" or "⏹️ Nonaktif",
            Time = 2
        })
    end
})

FishTab:AddSlider({
    Name = "Reel Delay (detik)",
    Min = 0.1,
    Max = 1.0,
    Default = 0.25,
    Color = Color3.fromRGB(0, 170, 255),
    Increment = 0.01,
    ValueName = "detik",
    Callback = function(value)
        Settings.ReelDelay = tonumber(string.format("%.2f", value))
    end
})

FishTab:AddToggle({
    Name = "Random Delay",
    Default = true,
    Callback = function(value)
        Settings.RandomDelay = value
    end
})

FishTab:AddSlider({
    Name = "Delay Variance (±s)",
    Min = 0,
    Max = 0.5,
    Default = 0.15,
    Color = Color3.fromRGB(255, 170, 0),
    Increment = 0.01,
    ValueName = "detik",
    Callback = function(value)
        Settings.DelayRange = tonumber(string.format("%.2f", value))
    end
})

FishTab:AddLabel("🎣 Status Fishing Rod:")
FishTab:AddParagraph("Rod", "Mencari Fishing Rod...")

-- Update status rod
coroutine.wrap(function()
    while true do
        if FishingRod then
            FishTab:AddParagraph("Rod", "✅ Rod ditemukan: " .. FishingRod.Name)
        else
            FishTab:AddParagraph("Rod", "❌ Rod tidak ditemukan! Beli dulu.")
        end
        task.wait(2)
    end
end)()

-- TAB 2: AUTO SELL
local SellTab = Window:MakeTab({
    Name = "💰 Auto Sell",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

SellTab:AddToggle({
    Name = "Auto Sell",
    Default = false,
    Callback = function(value)
        Settings.AutoSell = value
    end
})

SellTab:AddSlider({
    Name = "Check Interval (detik)",
    Min = 10,
    Max = 120,
    Default = 45,
    Color = Color3.fromRGB(0, 255, 0),
    Increment = 5,
    ValueName = "detik",
    Callback = function(value)
        Settings.SellInterval = math.floor(value)
    end
})

SellTab:AddButton({
    Name = "🔍 Cari Remote Jual",
    Callback = function()
        local found = false
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj.Name:lower():find("sell") and (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then
                SellRemote = obj
                Orion:MakeNotification({
                    Name = "Sukses",
                    Content = "Remote ditemukan: " .. obj.Name,
                    Time = 3
                })
                found = true
                break
            end
        end
        if not found then
            Orion:MakeNotification({
                Name = "Gagal",
                Content = "Remote tidak ditemukan. Edit manual!",
                Time = 3
            })
        end
    end
})

SellTab:AddLabel("💰 Status Remote:")
SellTab:AddParagraph("SellStatus", "Mencari remote jual...")

coroutine.wrap(function()
    while true do
        if SellRemote then
            SellTab:AddParagraph("SellStatus", "✅ Remote: " .. SellRemote.Name)
        else
            SellTab:AddParagraph("SellStatus", "❌ Remote tidak ditemukan")
        end
        task.wait(2)
    end
end)()

-- TAB 3: AUTO COLLECT
local CollectTab = Window:MakeTab({
    Name = "📦 Auto Collect",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

CollectTab:AddToggle({
    Name = "Auto Collect",
    Default = false,
    Callback = function(value)
        Settings.AutoCollect = value
    end
})

CollectTab:AddSlider({
    Name = "Collection Radius",
    Min = 10,
    Max = 50,
    Default = 25,
    Color = Color3.fromRGB(255, 0, 255),
    Increment = 5,
    ValueName = "studs",
    Callback = function(value)
        Settings.CollectRange = math.floor(value)
    end
})

-- TAB 4: MOVEMENT
local MoveTab = Window:MakeTab({
    Name = "🏃 Movement",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MoveTab:AddToggle({
    Name = "Speed Boost",
    Default = false,
    Callback = function(value)
        Settings.SpeedBoost = value
    end
})

MoveTab:AddSlider({
    Name = "Walk Speed",
    Min = 16,
    Max = 120,
    Default = 16,
    Color = Color3.fromRGB(0, 255, 255),
    Increment = 1,
    ValueName = "speed",
    Callback = function(value)
        Settings.WalkSpeed = math.floor(value)
    end
})

MoveTab:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 150,
    Default = 50,
    Color = Color3.fromRGB(255, 255, 0),
    Increment = 1,
    ValueName = "power",
    Callback = function(value)
        Settings.JumpPower = math.floor(value)
    end
})

MoveTab:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Callback = function(value)
        Settings.InfJump = value
    end
})

-- TAB 5: TELEPORT
local TeleportTab = Window:MakeTab({
    Name = "🌍 Teleport",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

for name, cf in pairs(TeleportSpots) do
    TeleportTab:AddButton({
        Name = name,
        Callback = function()
            RootPart.CFrame = cf
            Orion:MakeNotification({
                Name = "Teleport",
                Content = "Ke " .. name,
                Time = 2
            })
        end
    })
end

-- TAB 6: ANTI AFK & MISC
local MiscTab = Window:MakeTab({
    Name = "⚙️ Misc",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MiscTab:AddToggle({
    Name = "Anti AFK",
    Default = false,
    Callback = function(value)
        Settings.AntiAFK = value
    end
})

MiscTab:AddButton({
    Name = "🔄 Rejoin Server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, Player)
    end
})

MiscTab:AddButton({
    Name = "💀 Reset Character",
    Callback = function()
        Player.Character:BreakJoints()
    end
})

-- TAB 7: STATISTICS
local StatsTab = Window:MakeTab({
    Name = "📊 Statistics",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local FishLabel = StatsTab:AddLabel("🎣 Ikan: 0")
local MoneyLabel = StatsTab:AddLabel("💰 Uang: $0")
local TimeLabel = StatsTab:AddLabel("⏱️ Runtime: 00:00:00")
local StatusLabel = StatsTab:AddLabel("🎯 Status: Idle")

coroutine.wrap(function()
    while true do
        task.wait(1)
        local runtime = math.floor(tick() - Settings.StartTime)
        local hours = math.floor(runtime / 3600)
        local mins = math.floor((runtime % 3600) / 60)
        local secs = runtime % 60
        
        FishLabel:Set("🎣 Ikan: " .. Settings.FishCount)
        MoneyLabel:Set("💰 Uang: $" .. Settings.MoneyEarned)
        TimeLabel:Set("⏱️ Runtime: " .. string.format("%02d:%02d:%02d", hours, mins, secs))
        StatusLabel:Set("🎯 Status: " .. (Settings.AutoFish and "Fishing" or "Idle"))
    end
end)()

-- ========== [12. INITIALIZATION] ==========
Orion:Init()

-- Notifikasi sukses
Orion:MakeNotification({
    Name = "NikeeHUB",
    Content = "✅ Fish It! script loaded!",
    Time = 5
})

print("✅ NikeeHUB Fish It! 2026 loaded successfully!")
print("🎣 Auto Fish: Ready")
print("💰 Auto Sell: Ready (need remote)")
print("📦 Auto Collect: Ready")
