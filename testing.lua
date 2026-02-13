--[[
    🔥 NIKEeHUB - AUTO FISH FISH IT! (UNIVERSAL)
    ✅ AUTO DETEKSI ROD DENGAN NAMA APAPUN
    ✅ TANPA LIBRARY - TANPA ERROR
    ✅ WORK DI SEMUA SERVER
]]

-- ========== [1. INISIALISASI] ==========
repeat task.wait() until game:IsLoaded()

local Player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

-- ========== [2. KONFIGURASI] ==========
local Settings = {
    AutoFish = false,
    FishCount = 0,
    StartTime = tick()
}

-- ========== [3. AUTO DETEKSI ROD - INI KUNCI UTAMA!] ==========
local CastEvent = nil
local FishingRod = nil

local function FindAnyFishingRod()
    -- Method 1: Cari di Backpack semua item yang punya CastEvent
    for _, item in ipairs(Player.Backpack:GetChildren()) do
        if item:FindFirstChild("CastEvent") then
            return item, item.CastEvent
        end
    end
    
    -- Method 2: Cari di Character
    if Player.Character then
        for _, item in ipairs(Player.Character:GetChildren()) do
            if item:FindFirstChild("CastEvent") then
                return item, item.CastEvent
            end
        end
    end
    
    -- Method 3: Cari berdasarkan tool yang bisa di-equip
    for _, item in ipairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") and item:FindFirstChild("CastEvent") then
            return item, item.CastEvent
        end
    end
    
    return nil, nil
end

-- Fungsi untuk update rod
local function UpdateRod()
    local rod, event = FindAnyFishingRod()
    if rod and event then
        FishingRod = rod
        CastEvent = event
        return true
    else
        FishingRod = nil
        CastEvent = nil
        return false
    end
end

-- Update pertama kali
UpdateRod()

-- Auto update setiap 3 detik
task.spawn(function()
    while true do
        task.wait(3)
        local found = UpdateRod()
        if found and not Settings.RodFound then
            Settings.RodFound = true
            -- Notifikasi rod ditemukan
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "🎣 NikeeHUB",
                Text = "Rod ditemukan: " .. FishingRod.Name,
                Duration = 3
            })
        end
    end
end)

-- ========== [4. AUTO FISH CYCLE] ==========
local function FishCycle()
    if not CastEvent then
        UpdateRod()
        return false
    end
    
    -- CAST
    pcall(function()
        CastEvent:FireServer()
    end)
    
    -- Delay
    task.wait(0.25 + (math.random() * 0.2))
    
    -- REEL
    pcall(function()
        CastEvent:FireServer()
    end)
    
    Settings.FishCount = Settings.FishCount + 1
    return true
end

-- Loop utama
task.spawn(function()
    while true do
        if Settings.AutoFish then
            pcall(FishCycle)
            task.wait(0.2 + (math.random() * 0.1))
        else
            task.wait(0.5)
        end
    end
end)

-- ========== [5. ANTI AFK] ==========
Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ========== [6. UI STATUS MINIMAL] ==========
-- Buat ScreenGui sederhana
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NikeeHUB_Status"
ScreenGui.Parent = Player.PlayerGui or Instance.new("ScreenGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 120)
Frame.Position = UDim2.new(0, 10, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BackgroundTransparency = 0.6
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "🎣 NikeeHUB - Auto Fish"
Title.TextColor3 = Color3.fromRGB(255, 255, 0)
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

-- Rod Status
local RodLabel = Instance.new("TextLabel")
RodLabel.Size = UDim2.new(1, 0, 0, 25)
RodLabel.Position = UDim2.new(0, 0, 0, 60)
RodLabel.BackgroundTransparency = 1
RodLabel.Text = "Rod: Mencari..."
RodLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
RodLabel.TextScaled = true
RodLabel.Font = Enum.Font.Gotham
RodLabel.Parent = Frame

-- Fish Count
local FishLabel = Instance.new("TextLabel")
FishLabel.Size = UDim2.new(1, 0, 0, 25)
FishLabel.Position = UDim2.new(0, 0, 0, 90)
FishLabel.BackgroundTransparency = 1
FishLabel.Text = "Ikan: 0"
FishLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
FishLabel.TextScaled = true
FishLabel.Font = Enum.Font.Gotham
FishLabel.Parent = Frame

-- Update UI setiap 0.5 detik
task.spawn(function()
    while true do
        task.wait(0.5)
        
        -- Update status
        StatusLabel.Text = Settings.AutoFish and "Status: ON 🟢" or "Status: OFF 🔴"
        StatusLabel.TextColor3 = Settings.AutoFish and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        
        -- Update rod status
        if CastEvent then
            RodLabel.Text = "Rod: " .. (FishingRod and FishingRod.Name or "Unknown")
            RodLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            RodLabel.Text = "Rod: TIDAK DITEMUKAN! ❌"
            RodLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
        
        -- Update fish count
        FishLabel.Text = "Ikan: " .. Settings.FishCount
    end
end)

-- ========== [7. KONTROL KEYBIND] ==========
-- F = Toggle Auto Fish
-- R = Reset counter
-- U = Force update rod

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        Settings.AutoFish = not Settings.AutoFish
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🎣 NikeeHUB",
            Text = Settings.AutoFish and "✅ Auto Fish ON" or "⏹️ Auto Fish OFF",
            Duration = 2
        })
    end
    
    if input.KeyCode == Enum.KeyCode.R then
        Settings.FishCount = 0
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "📊 NikeeHUB",
            Text = "Counter direset!",
            Duration = 1.5
        })
    end
    
    if input.KeyCode == Enum.KeyCode.U then
        local found = UpdateRod()
        if found then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "✅ Update",
                Text = "Rod ditemukan: " .. FishingRod.Name,
                Duration = 2
            })
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "❌ Update",
                Text = "Rod tidak ditemukan!",
                Duration = 2
            })
        end
    end
end)

-- ========== [8. CHAT COMMANDS] ==========
local ChatRemote = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents") and 
                   game.ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")

Player.Chatted:Connect(function(msg)
    msg = msg:lower()
    
    if msg == "!fish" or msg == "!f" then
        Settings.AutoFish = not Settings.AutoFish
        if ChatRemote then
            ChatRemote:FireServer(
                Settings.AutoFish and "✅ Auto Fish ON" or "⏹️ Auto Fish OFF",
                "All"
            )
        end
    end
    
    if msg == "!rod" or msg == "!r" then
        if CastEvent and FishingRod then
            ChatRemote:FireServer("✅ Rod: " .. FishingRod.Name, "All")
        else
            ChatRemote:FireServer("❌ Rod tidak ditemukan!", "All")
        end
    end
    
    if msg == "!stats" or msg == "!s" then
        local runtime = math.floor(tick() - Settings.StartTime)
        local msg = string.format("🎣 Ikan: %d | ⏱️ %dm %ds", 
            Settings.FishCount,
            math.floor(runtime/60),
            runtime%60
        )
        if ChatRemote then
            ChatRemote:FireServer(msg, "All")
        end
    end
end)

-- ========== [9. DIAGNOSTIK - CEK SEMUA TOOL] ==========
-- Print semua item di backpack dan character (untuk debugging)
print("========== NIKEeHUB DIAGNOSTIK ==========")
print("📦 BACKPACK ITEMS:")
for i, item in ipairs(Player.Backpack:GetChildren()) do
    print("  " .. i .. ". " .. item.Name .. " (" .. item.ClassName .. ")")
    if item:FindFirstChild("CastEvent") then
        print("     ✅ MEMILIKI CASTEVENT!")
    end
end

print("\n🧍 CHARACTER ITEMS:")
if Player.Character then
    for i, item in ipairs(Player.Character:GetChildren()) do
        if item:IsA("Tool") then
            print("  " .. i .. ". " .. item.Name .. " (" .. item.ClassName .. ")")
            if item:FindFirstChild("CastEvent") then
                print("     ✅ MEMILIKI CASTEVENT!")
            end
        end
    end
end
print("==========================================")

-- ========== [10. AUTO EQUIP ROD PERTAMA KALI] ==========
-- Jika rod ada di backpack tapi tidak di equip, auto equip
task.spawn(function()
    task.wait(2)
    if not CastEvent and Player.Backpack then
        for _, item in ipairs(Player.Backpack:GetChildren()) do
            if item:FindFirstChild("CastEvent") then
                -- Auto equip rod
                pcall(function()
                    Player.Character.Humanoid:EquipTool(item)
                    print("✅ Auto equip: " .. item.Name)
                end)
                break
            end
        end
    end
end)

-- ========== [11. NOTIFIKASI START] ==========
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🎣 NikeeHUB - UNIVERSAL",
    Text = "Tekan F untuk mulai | U untuk cek rod",
    Duration = 5
})

print("\n✅ NIKEeHUB AUTO FISH - UNIVERSAL EDITION")
print("✅ Script siap! Tekan F untuk toggle auto fish")
print("✅ Tekan U untuk update/cek rod manual")
print("✅ Chat: !fish, !rod, !stats\n")
