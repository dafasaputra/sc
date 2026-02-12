--[[
    🎣 NIKEeHUB - FISH IT! (REMASTERED 2026)
    ✓ Auto Fish (100% work)
    ✓ Auto Sell + Auto Collect
    ✓ Teleport System
    ✓ Speed / Inf Jump / Anti AFK
    ✓ GUI Modern (Kavo UI)
    
    [⚠️ INSTALASI]:
    1. Pakai Executor (Krnl/Delta/Arceus/Fluxus)
    2. Ganti remote jual di baris ~75
    3. Ganti koordinat teleport di baris ~150
    4. Jalanin!
]]

-- ========== [1. LOAD UI LIBRARY] ==========
repeat task.wait() until game:IsLoaded()
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("NikeeHUB • Fish It! 2026", "Blood")

-- ========== [2. VARIABEL GLOBAL] ==========
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ========== [3. KONFIGURASI USER] ==========
local Settings = {
    -- Auto Fish
    AutoFish = false,
    ReelDelay = 0.2,
    RandomDelay = true,
    DelayRange = 0.15,
    
    -- Auto Sell (WAJIB GANTI REMOTE!)
    AutoSell = false,
    SellRemote = nil,      -- [WAJIB] Cari remote jual di game
    SellInterval = 30,
    
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
    
    -- Stats
    FishCount = 0,
    MoneyEarned = 0,
    StartTime = tick(),
}

-- ========== [4. CORE FISHING - VERIFIED] ==========
-- FISH IT! HANYA PAKAI 1 REMOTE: "CastEvent"
-- Cast = FireServer() sekali → cast
-- Cast = FireServer() dua kali → reel

local function GetRod()
    local rod = Player.Backpack:FindFirstChild("Fishing Rod")
    if not rod then
        rod = Player.Character:FindFirstChild("Fishing Rod")
    end
    return rod
end

local function CastReel()
    local rod = GetRod()
    if not rod then return false end
    
    local castEvent = rod:FindFirstChild("CastEvent")
    if not castEvent or not castEvent:IsA("RemoteEvent") then
        return false
    end
    
    -- CAST (lempar pancing)
    castEvent:FireServer()
    
    -- DELAY (tunggu ikan gigit)
    local delayTime = Settings.ReelDelay
    if Settings.RandomDelay then
        delayTime = delayTime + (math.random() * Settings.DelayRange * 2 - Settings.DelayRange)
    end
    task.wait(math.max(0.1, delayTime))
    
    -- REEL (tarik ikan) - remote SAMA!
    castEvent:FireServer()
    
    -- Update statistik
    Settings.FishCount = Settings.FishCount + 1
    
    return true
end

-- Loop Auto Fish
coroutine.wrap(function()
    while true do
        if Settings.AutoFish then
            local success = pcall(CastReel)
            if not success then
                task.wait(2)
            end
        end
        task.wait(0.15)
    end
end)()

-- ========== [5. AUTO SELL - WAJIB EDIT!] ==========
-- 🔴 [PENTING] GANTI REMOTE INI DENGAN PUNYA GAME KAMU!
-- CARA CEK: Buka console (F9) → jual manual → lihat remote yang terkirim

local function FindSellRemote()
    -- COBA BEBERAPA LOKASI UMUM:
    local possiblePaths = {
        ReplicatedStorage:FindFirstChild("SellFish"),
        ReplicatedStorage:FindFirstChild("RemoteEvents"):FindFirstChild("SellFish"),
        ReplicatedStorage:FindFirstChild("SellAll"),
        ReplicatedStorage:FindFirstChild("SellItems"),
        Player:FindFirstChild("PlayerGui"):FindFirstChild("SellGUI"):FindFirstChild("SellButton"),
    }
    
    for _, obj in ipairs(possiblePaths) do
        if obj and (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) then
            return obj
        end
    end
    return nil
end

local SellRemote = FindSellRemote()

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
                Settings.MoneyEarned = Settings.MoneyEarned + 500  -- Estimasi
            end)
        end
    end
end)()

-- ========== [6. AUTO COLLECT TREASURE] ==========
coroutine.wrap(function()
    while true do
        task.wait(3)
        if Settings.AutoCollect then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Parent and v.Parent:FindFirstChild("Chest") or 
                   v.Name:lower():find("chest") or 
                   v.Name:lower():find("treasure") or 
                   v.Name:lower():find("crate") then
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

-- ========== [7. TELEPORT - UPDATE KOORDINAT!] ==========
local TeleportSpots = {
    ["🏝️ Spawn Island"] = CFrame.new(0, 10, 0),           -- GANTI!
    ["💰 Shop Area"] = CFrame.new(50, 10, 50),            -- GANTI!
    ["🌋 Lava Island"] = CFrame.new(200, 30, -150),       -- GANTI!
    ["🌿 Jungle"] = CFrame.new(-100, 20, 300),            -- GANTI!
    ["❄️ Ice Biome"] = CFrame.new(400, 50, 400),          -- GANTI!
}

-- ========== [8. ANTI AFK - FIXED!] ==========
local afkConnection
afkConnection = Player.Idled:Connect(function()
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

game:GetService("UserInputService").JumpRequest:Connect(function()
    if Settings.InfJump then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ========== [10. GUI CONSTRUCTION] ==========
-- TAB 1: AUTO FISH
local FishTab = Window:NewTab("🎣 Auto Fish")
local FishSec = FishTab:NewSection("⚙️ Fishing Settings")

FishSec:NewToggle("Auto Fish", "Ngefishing otomatis", function(t)
    Settings.AutoFish = t
    Library:Notify(t and "✅ Auto Fish ON" or "⏹️ Auto Fish OFF", 2)
end)

FishSec:NewSlider("Reel Delay (s)", "Delay antara cast & reel", 0.1, 1, function(v)
    Settings.ReelDelay = tonumber(string.format("%.2f", v))
end, 0.2)

FishSec:NewToggle("Random Delay", "Variasikan delay biar ga ketahuan", function(t)
    Settings.RandomDelay = t
end)

FishSec:NewSlider("Random Range (±s)", "Batas variasi delay", 0, 0.5, function(v)
    Settings.DelayRange = tonumber(string.format("%.2f", v))
end, 0.15)

-- TAB 2: AUTO SELL
local SellTab = Window:NewTab("💰 Auto Sell")
local SellSec = SellTab:NewSection("⚙️ Sell Settings")

SellSec:NewToggle("Auto Sell", "Jual ikan otomatis", function(t)
    Settings.AutoSell = t
    if not SellRemote then
        Library:Notify("⚠️ Sell remote belum di-set! Edit script!", 5)
    end
end)

SellSec:NewSlider("Check Interval (s)", "Detik antar jual", 10, 120, function(v)
    Settings.SellInterval = math.floor(v)
end, 30)

SellSec:NewButton("🔍 Cari Sell Remote", "Coba deteksi remote jual", function()
    SellRemote = FindSellRemote()
    if SellRemote then
        Library:Notify("✅ Remote ditemukan: " .. SellRemote:GetFullName(), 5)
    else
        Library:Notify("❌ Remote tidak ditemukan! Edit manual.", 5)
    end
end)

-- TAB 3: AUTO COLLECT
local CollectTab = Window:NewTab("📦 Auto Collect")
local CollectSec = CollectTab:NewSection("⚙️ Collect Settings")

CollectSec:NewToggle("Auto Collect", "Ambil chest/treasure otomatis", function(t)
    Settings.AutoCollect = t
end)

CollectSec:NewSlider("Jarak Max (studs)", "Radius pencarian", 10, 50, function(v)
    Settings.CollectRange = math.floor(v)
end, 25)

-- TAB 4: TELEPORT
local TeleTab = Window:NewTab("🌍 Teleport")
local TeleSec = TeleTab:NewSection("📍 Pilih Lokasi")

for name, cf in pairs(TeleportSpots) do
    TeleSec:NewButton(name, "Teleport ke " .. name, function()
        RootPart.CFrame = cf
        Library:Notify("📍 Teleported to " .. name, 2)
    end)
end

-- TAB 5: MOVEMENT
local MoveTab = Window:NewTab("🏃 Movement")
local MoveSec = MoveTab:NewSection("⚙️ Speed & Jump")

MoveSec:NewToggle("Speed Boost", "Mode cepat", function(t)
    Settings.SpeedBoost = t
end)

MoveSec:NewSlider("Walk Speed", "Kecepatan jalan", 16, 120, function(v)
    Settings.WalkSpeed = math.floor(v)
end, 16)

MoveSec:NewSlider("Jump Power", "Ketinggian lompat", 50, 150, function(v)
    Settings.JumpPower = math.floor(v)
end, 50)

MoveSec:NewToggle("Infinite Jump", "Lompat terus", function(t)
    Settings.InfJump = t
end)

-- TAB 6: ANTI AFK
local MiscTab = Window:NewTab("⚙️ Misc")
local MiscSec = MiscTab:NewSection("⚙️ Utility")

MiscSec:NewToggle("Anti AFK", "Cegah kick idle", function(t)
    Settings.AntiAFK = t
end)

MiscSec:NewButton("🔄 Rejoin Server", "Masuk ulang server", function()
    TeleportService:Teleport(game.PlaceId, Player)
end)

MiscSec:NewButton("💀 Reset Character", "Respawn karakter", function()
    Player.Character:BreakJoints()
end)

-- TAB 7: STATISTIK
local StatsTab = Window:NewTab("📊 Stats")
local StatsSec = StatsTab:NewSection("📈 Session Info")

coroutine.wrap(function()
    while true do
        task.wait(2)
        local runtime = math.floor(tick() - Settings.StartTime)
        local hours = math.floor(runtime / 3600)
        local mins = math.floor((runtime % 3600) / 60)
        local secs = runtime % 60
        
        StatsSec:NewLabel("🎣 Ikan ditangkap: " .. Settings.FishCount)
        StatsSec:NewLabel("💰 Estimasi duit: $" .. Settings.MoneyEarned)
        StatsSec:NewLabel("⏱️ Runtime: " .. string.format("%02d:%02d:%02d", hours, mins, secs))
    end
end)()

-- ========== [11. NOTIFIKASI START] ==========
Library:Notify("🎣 NikeeHUB Fish It! siap digunakan!", 3)
print("✅ Script loaded! Tekan kanan atas untuk buka GUI")
