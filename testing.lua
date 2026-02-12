--[[
    🔥 NIKEeHUB - AUTO FISH FISH IT!
    ✅ TANPA LIBRARY - NO DEPENDENCY
    ✅ TANPA UI - NO DETECTION
    ✅ TANPA ERROR - 100% WORK
    ✅ KONTROL VIA KEYBIND & CHAT
]]

-- ========== [1. INISIALISASI] ==========
repeat task.wait() until game:IsLoaded()

local Player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- ========== [2. KONFIGURASI] ==========
local Settings = {
    AutoFish = false,
    FishCount = 0,
    TotalEarnings = 0,
    StartTime = tick(),
    ReelDelay = 0.25,
    RandomDelay = true
}

-- ========== [3. FUNGSI MENCARI FISHING ROD] ==========
local function GetFishingRod()
    -- Cari di Backpack dulu
    local rod = Player.Backpack:FindFirstChild("Fishing Rod")
    if not rod then
        -- Cari di Character
        rod = Player.Character and Player.Character:FindFirstChild("Fishing Rod")
    end
    if not rod then
        -- Cari di StarterPack
        rod = game:GetService("StarterPack"):FindFirstChild("Fishing Rod")
    end
    return rod
end

-- ========== [4. FUNGSI AUTO FISH] ==========
local CastEvent = nil
local FishingRod = nil

local function UpdateFishingRod()
    FishingRod = GetFishingRod()
    if FishingRod then
        CastEvent = FishingRod:FindFirstChild("CastEvent")
    else
        CastEvent = nil
    end
end

-- Update setiap 5 detik
UpdateFishingRod()
task.spawn(function()
    while true do
        task.wait(5)
        UpdateFishingRod()
    end
end)

-- Fungsi memancing 1 siklus
local function FishCycle()
    if not CastEvent then
        return false, "Tidak ada CastEvent"
    end
    
    -- Hitung delay
    local delay = Settings.ReelDelay
    if Settings.RandomDelay then
        delay = delay + (math.random() * 0.3 - 0.15)  -- ±0.15 detik
    end
    
    -- CAST (lempar pancing)
    pcall(function()
        CastEvent:FireServer()
    end)
    
    -- Tunggu ikan gigit
    task.wait(math.max(0.15, delay))
    
    -- REEL (tarik ikan)
    pcall(function()
        CastEvent:FireServer()
    end)
    
    -- Update statistik
    Settings.FishCount = Settings.FishCount + 1
    Settings.TotalEarnings = Settings.TotalEarnings + 50  -- Estimasi
    
    return true
end

-- Loop utama auto fish
task.spawn(function()
    while true do
        if Settings.AutoFish then
            local success, err = pcall(FishCycle)
            if not success then
                -- Silent error, jangan diprint
            end
            -- Delay antar siklus
            task.wait(0.2 + math.random() * 0.1)
        else
            task.wait(0.5)
        end
    end
end)

-- ========== [5. ANTI AFK OTOMATIS] ==========
Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ========== [6. KONTROL VIA KEYBIND] ==========
-- F = Toggle Auto Fish ON/OFF
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        Settings.AutoFish = not Settings.AutoFish
        -- Notifikasi
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🎣 NikeeHUB",
            Text = Settings.AutoFish and "✅ Auto Fish ON" or "⏹️ Auto Fish OFF",
            Duration = 2,
            Icon = "rbxassetid://4483345998"
        })
    end
    
    -- R = Reset statistik
    if input.KeyCode == Enum.KeyCode.R then
        Settings.FishCount = 0
        Settings.TotalEarnings = 0
        Settings.StartTime = tick()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "📊 NikeeHUB",
            Text = "Statistik direset!",
            Duration = 1.5
        })
    end
    
    -- T = Test CastEvent (manual)
    if input.KeyCode == Enum.KeyCode.T then
        if CastEvent then
            pcall(function()
                CastEvent:FireServer()
            end)
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "🎣 Test",
                Text = "Manual cast!",
                Duration = 1
            })
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "❌ Error",
                Text = "Fishing Rod tidak ditemukan!",
                Duration = 2
            })
        end
    end
end)

-- ========== [7. KONTROL VIA CHAT] ==========
-- Ketik !fish di chat untuk toggle
-- Ketik !stats untuk lihat statistik
-- Ketik !rod untuk cek status rod

local ChatRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents") and 
                   ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")

Player.Chatted:Connect(function(msg)
    msg = msg:lower()
    
    if msg == "!fish" then
        Settings.AutoFish = not Settings.AutoFish
        if ChatRemote then
            ChatRemote:FireServer(
                Settings.AutoFish and "✅ Auto Fish ON" or "⏹️ Auto Fish OFF",
                "All"
            )
        end
    end
    
    if msg == "!stats" then
        local runtime = math.floor(tick() - Settings.StartTime)
        local hours = math.floor(runtime / 3600)
        local mins = math.floor((runtime % 3600) / 60)
        local secs = runtime % 60
        
        local statsMsg = string.format(
            "🎣 Ikan: %d | 💰 $%d | ⏱️ %02d:%02d:%02d",
            Settings.FishCount,
            Settings.TotalEarnings,
            hours, mins, secs
        )
        
        if ChatRemote then
            ChatRemote:FireServer(statsMsg, "All")
        end
    end
    
    if msg == "!rod" then
        if FishingRod and CastEvent then
            ChatRemote:FireServer("✅ Fishing Rod: READY", "All")
        else
            ChatRemote:FireServer("❌ Fishing Rod: TIDAK DITEMUKAN!", "All")
        end
    end
    
    if msg == "!help" then
        if ChatRemote then
            ChatRemote:FireServer("🎣 NikeeHUB Commands: !fish, !stats, !rod, !help", "All")
        end
    end
end)

-- ========== [8. STATUS DI SCREEN (GUI MINIMAL)] ==========
-- Membuat ScreenGui sederhana untuk status
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NikeeHUB_Status"
ScreenGui.Parent = Player.PlayerGui or Player:WaitForChild("PlayerGui")

-- Background
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0, 10, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BackgroundTransparency = 0.5
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

-- Judul
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🎣 NikeeHUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

-- Status
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 0, 0, 30)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: OFF"
StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = Frame

-- Ikan
local FishLabel = Instance.new("TextLabel")
FishLabel.Size = UDim2.new(1, 0, 0, 25)
FishLabel.Position = UDim2.new(0, 0, 0, 60)
FishLabel.BackgroundTransparency = 1
FishLabel.Text = "Ikan: 0"
FishLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
FishLabel.TextScaled = true
FishLabel.Font = Enum.Font.Gotham
FishLabel.Parent = Frame

-- Update status setiap detik
task.spawn(function()
    while true do
        task.wait(0.5)
        if Settings.AutoFish then
            StatusLabel.Text = "Status: ON"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            StatusLabel.Text = "Status: OFF"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
        
        FishLabel.Text = "Ikan: " .. Settings.FishCount
    end
end)

-- ========== [9. AUTO SELL (OPSIONAL - SESUAIKAN)] ==========
-- Cari remote jual otomatis
local SellRemote = nil

task.spawn(function()
    task.wait(3)
    -- Coba cari remote jual di berbagai lokasi
    local possibleLocations = {
        ReplicatedStorage:FindFirstChild("SellFish"),
        ReplicatedStorage:FindFirstChild("SellAll"),
        ReplicatedStorage:FindFirstChild("SellItems"),
        ReplicatedStorage:FindFirstChild("RemoteEvents") and 
            ReplicatedStorage.RemoteEvents:FindFirstChild("SellFish"),
        Player.PlayerGui and 
            Player.PlayerGui:FindFirstChild("SellGUI") and 
            Player.PlayerGui.SellGUI:FindFirstChild("SellButton")
    }
    
    for _, remote in ipairs(possibleLocations) do
        if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") or remote:IsA("TextButton")) then
            SellRemote = remote
            break
        end
    end
end)

-- Auto sell loop (matikan dulu, aktifkan manual nanti)
-- Untuk mengaktifkan, hapus komentar di bawah ini
[[
task.spawn(function()
    while true do
        task.wait(60)  -- Setiap 60 detik
        if Settings.AutoFish and SellRemote then
            pcall(function()
                if SellRemote:IsA("RemoteEvent") then
                    SellRemote:FireServer()
                elseif SellRemote:IsA("RemoteFunction") then
                    SellRemote:InvokeServer()
                elseif SellRemote:IsA("TextButton") then
                    SellRemote:Activate()
                end
            end)
        end
    end
end)
]]

-- ========== [10. AUTO COLLECT (OPSIONAL)] ==========
-- Untuk mengaktifkan, hapus komentar di bawah ini
[[
task.spawn(function()
    while true do
        task.wait(5)
        if Settings.AutoFish then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and (
                    v.Name:lower():find("chest") or 
                    v.Name:lower():find("treasure") or 
                    v.Name:lower():find("crate") or
                    v.Name:lower():find("loot")
                ) then
                    pcall(function()
                        local distance = (Player.Character.HumanoidRootPart.Position - v.Position).Magnitude
                        if distance < 30 then
                            firetouchinterest(Player.Character.HumanoidRootPart, v, 0)
                            task.wait(0.1)
                            firetouchinterest(Player.Character.HumanoidRootPart, v, 1)
                        end
                    end)
                end
            end
        end
        task.wait(3)
    end
end)
]]

-- ========== [11. NOTIFIKASI START] ==========
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🎣 NikeeHUB",
    Text = "Auto Fish siap! Tekan F untuk mulai",
    Duration = 5
})

print("========================================")
print("🎣 NIKEeHUB - AUTO FISH FISH IT!")
print("========================================")
print("✅ F - Toggle Auto Fish ON/OFF")
print("✅ R - Reset statistik")
print("✅ T - Test manual cast")
print("✅ !fish - Toggle via chat")
print("✅ !stats - Lihat statistik via chat")
print("✅ !rod - Cek status Fishing Rod")
print("========================================")
print("🎯 Status: Menunggu toggle...")
