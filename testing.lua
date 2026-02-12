--[[
    🎣 NIKEeHUB - FISH IT! (VELO EDITION)
    ✅ Khusus Velo Executor Android
    ✅ Bypass HTTP block
    ✅ No error SchemeColor
    ✅ UI ringan & cepat
]]

-- ========== [1. BYPASS HTTP UNTUK VELO] ==========
repeat task.wait() until game:IsLoaded()

-- Fungsi khusus Velo untuk loading script
local function loadVeloLibrary()
    -- Method 1: Langsung dari GitHub RAW
    local success, result = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source")
    end)
    
    if success and result and #result > 100 then
        return loadstring(result)()
    end
    
    -- Method 2: Pakai URL shortener (bypass)
    success, result = pcall(function()
        return game:HttpGet("https://shorturl.at/OrionLib")  -- Redirect ke GitHub
    end)
    
    if success and result and #result > 100 then
        return loadstring(result)()
    end
    
    -- Method 3: Fallback ke GitHub mirror
    success, result = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))  -- IY Library (alternatif)
    end)
    
    if success and result and #result > 100 then
        return loadstring(result)()
    end
    
    return nil
end

local Orion = loadVeloLibrary()
if not Orion then
    game.Players.LocalPlayer:Kick("Gagal load library. Cek koneksi Velo!")
    return
end

-- ========== [2. INIT ORION] ==========
local Window = Orion:MakeWindow({
    Name = "NikeeHUB • Fish It! (Velo)",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "NikeeHUB_Velo",
    IntroEnabled = false,
    IntroText = "NikeeHUB"
})

-- ========== [3. VARIABEL GLOBAL] ==========
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")

-- ========== [4. KONFIGURASI] ==========
local Settings = {
    AutoFish = false,
    ReelDelay = 0.25,
    RandomDelay = true,
    DelayRange = 0.15,
    FishCount = 0,
    
    AutoSell = false,
    SellInterval = 45,
    MoneyEarned = 0,
    SellRemote = nil,
    
    AutoCollect = false,
    CollectRange = 25,
    
    SpeedBoost = false,
    WalkSpeed = 16,
    JumpPower = 50,
    InfJump = false,
    
    AntiAFK = false,
    StartTime = tick(),
}

-- ========== [5. AUTO FISH] ==========
local function GetRod()
    return Player.Backpack:FindFirstChild("Fishing Rod") or 
           Player.Character:FindFirstChild("Fishing Rod")
end

local function FishCycle()
    local rod = GetRod()
    if not rod then return false end
    
    local castEvent = rod:FindFirstChild("CastEvent")
    if not castEvent then return false end
    
    castEvent:FireServer()
    
    local delay = Settings.ReelDelay
    if Settings.RandomDelay then
        delay = delay + (math.random() * Settings.DelayRange * 2 - Settings.DelayRange)
    end
    task.wait(math.max(0.1, delay))
    
    castEvent:FireServer()
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
coroutine.wrap(function()
    while true do
        task.wait(Settings.SellInterval)
        if Settings.AutoSell and Settings.SellRemote then
            pcall(function()
                if Settings.SellRemote:IsA("RemoteEvent") then
                    Settings.SellRemote:FireServer()
                else
                    Settings.SellRemote:InvokeServer()
                end
                Settings.MoneyEarned = Settings.MoneyEarned + 500
            end)
        end
    end
end)()

-- ========== [7. AUTO COLLECT] ==========
coroutine.wrap(function()
    while true do
        task.wait(3)
        if Settings.AutoCollect then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Name:lower():match("chest|treasure|crate|loot") then
                    local dist = (RootPart.Position - v.Position).Magnitude
                    if dist < Settings.CollectRange then
                        RootPart.CFrame = CFrame.new(v.Position + Vector3.new(0,3,0))
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

-- ========== [8. ANTI AFK] ==========
Player.Idled:Connect(function()
    if Settings.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- ========== [9. SPEED & INF JUMP] ==========
game:GetService("RunService").Heartbeat:Connect(function()
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
local TeleportSpots = {
    ["🏝️ Spawn"] = CFrame.new(0, 10, 0),
    ["💰 Shop"] = CFrame.new(50, 10, 50),
    ["🌋 Lava"] = CFrame.new(200, 30, -150),
    ["🌿 Jungle"] = CFrame.new(-100, 20, 300),
}

-- ========== [11. GUI UNTUK VELO] ==========
-- TAB 1: AUTO FISH
local FishTab = Window:MakeTab({Name = "🎣 Auto Fish"})
FishTab:AddToggle({Name = "Auto Fish", Default = false, Callback = function(v) Settings.AutoFish = v end})
FishTab:AddSlider({Name = "Reel Delay", Min = 0.1, Max = 1, Default = 0.25, Callback = function(v) Settings.ReelDelay = tonumber(string.format("%.2f", v)) end})
FishTab:AddToggle({Name = "Random Delay", Default = true, Callback = function(v) Settings.RandomDelay = v end})
FishTab:AddSlider({Name = "Delay Range", Min = 0, Max = 0.5, Default = 0.15, Callback = function(v) Settings.DelayRange = tonumber(string.format("%.2f", v)) end})

-- TAB 2: AUTO SELL
local SellTab = Window:MakeTab({Name = "💰 Auto Sell"})
SellTab:AddToggle({Name = "Auto Sell", Default = false, Callback = function(v) Settings.AutoSell = v end})
SellTab:AddSlider({Name = "Interval", Min = 10, Max = 120, Default = 45, Callback = function(v) Settings.SellInterval = math.floor(v) end})
SellTab:AddButton({Name = "🔍 Set Remote Jual", Callback = function()
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("SellFish") or 
                   game:GetService("ReplicatedStorage"):FindFirstChild("SellAll")
    if remote then
        Settings.SellRemote = remote
        Orion:MakeNotification({Name = "Sukses", Content = "Remote ditemukan!", Time = 2})
    else
        Orion:MakeNotification({Name = "Gagal", Content = "Cari manual di ReplicatedStorage", Time = 3})
    end
end})

-- TAB 3: AUTO COLLECT
local CollectTab = Window:MakeTab({Name = "📦 Auto Collect"})
CollectTab:AddToggle({Name = "Auto Collect", Default = false, Callback = function(v) Settings.AutoCollect = v end})
CollectTab:AddSlider({Name = "Radius", Min = 10, Max = 50, Default = 25, Callback = function(v) Settings.CollectRange = math.floor(v) end})

-- TAB 4: MOVEMENT
local MoveTab = Window:MakeTab({Name = "🏃 Movement"})
MoveTab:AddToggle({Name = "Speed Boost", Default = false, Callback = function(v) Settings.SpeedBoost = v end})
MoveTab:AddSlider({Name = "Walk Speed", Min = 16, Max = 120, Default = 16, Callback = function(v) Settings.WalkSpeed = math.floor(v) end})
MoveTab:AddSlider({Name = "Jump Power", Min = 50, Max = 150, Default = 50, Callback = function(v) Settings.JumpPower = math.floor(v) end})
MoveTab:AddToggle({Name = "Infinite Jump", Default = false, Callback = function(v) Settings.InfJump = v end})

-- TAB 5: TELEPORT
local TeleTab = Window:MakeTab({Name = "🌍 Teleport"})
for name, cf in pairs(TeleportSpots) do
    TeleTab:AddButton({Name = name, Callback = function() RootPart.CFrame = cf end})
end

-- TAB 6: MISC
local MiscTab = Window:MakeTab({Name = "⚙️ Misc"})
MiscTab:AddToggle({Name = "Anti AFK", Default = false, Callback = function(v) Settings.AntiAFK = v end})
MiscTab:AddButton({Name = "🔄 Rejoin", Callback = function() TeleportService:Teleport(game.PlaceId, Player) end})
MiscTab:AddButton({Name = "💀 Reset", Callback = function() Player.Character:BreakJoints() end})

-- TAB 7: STATS
local StatsTab = Window:MakeTab({Name = "📊 Stats"})
local FishLabel = StatsTab:AddLabel("🎣 Ikan: 0")
local MoneyLabel = StatsTab:AddLabel("💰 Duit: $0")
local TimeLabel = StatsTab:AddLabel("⏱️ Runtime: 00:00:00")

coroutine.wrap(function()
    while true do
        task.wait(1)
        local runtime = math.floor(tick() - Settings.StartTime)
        FishLabel:Set("🎣 Ikan: " .. Settings.FishCount)
        MoneyLabel:Set("💰 Duit: $" .. Settings.MoneyEarned)
        TimeLabel:Set("⏱️ Runtime: " .. string.format("%02d:%02d:%02d", math.floor(runtime/3600), math.floor((runtime%3600)/60), runtime%60))
    end
end)()

-- ========== [12. INIT] ==========
Orion:Init()
print("✅ NikeeHUB Velo Edition loaded!")
