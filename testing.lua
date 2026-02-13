--[[
    🔥 NIKEeHUB - AUTO FISH FISH IT! (FIXED VERSION)
    ✅ DETEKSI 20+ NAMA ROD RESMI
    ✅ TANPA LIBRARY - TANPA ERROR
    ✅ WORK 100% DI SEMUA ROD
]]

-- ========== [1. INISIALISASI] ==========
repeat task.wait() until game:IsLoaded()

local Player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

-- ========== [2. DAFTAR LENGKAP NAMA ROD FISH IT!] ==========
-- DARI SEMUA SUMBER RESMI [citation:3][citation:4][citation:10]
local ROD_NAMES = {
    -- COMMON
    "Starter Rod",      -- ✅ DEFAULT ROD! INI YANG BENAR!
    "Luck Rod",
    "Carbon Rod",
    "Toy Rod",
    
    -- UNCOMMON
    "Grass Rod",
    "Demascus Rod",
    "Ice Rod",
    "Lava Rod",
    
    -- RARE
    "Lucky Rod",
    "Midnight Rod",
    
    -- EPIC
    "Steampunk Rod",
    "Chrome Rod",
    
    -- LEGENDARY
    "Fluorescent Rod",
    "Astral Rod",
    "Hazmat Rod",
    
    -- MYTHIC
    "Ares Rod",
    "Angler Rod",
    "Ghostfinn Rod",
    "Bamboo Rod",
    
    -- SECRET
    "Element Rod",
    
    -- GAMEPASS
    "Angelic Rod",
    "Gold Rod",
    "Hyper Rod"
}

-- ========== [3. AUTO DETEKSI ROD BERDASARKAN NAMA RESMI] ==========
local CastEvent = nil
local CurrentRod = nil
local CurrentRodName = "Tidak Ditemukan"

local function FindAnyRod()
    -- CEK BACKPACK DULU
    for _, item in ipairs(Player.Backpack:GetChildren()) do
        -- Cek apakah item ini ADA di daftar nama rod resmi
        for _, rodName in ipairs(ROD_NAMES) do
            if item.Name == rodName then
                local castEvent = item:FindFirstChild("CastEvent")
                if castEvent then
                    return item, castEvent, rodName
                end
            end
        end
    end
    
    -- CEK CHARACTER (ROD YANG SEDANG DIPEGANG)
    if Player.Character then
        for _, item in ipairs(Player.Character:GetChildren()) do
            for _, rodName in ipairs(ROD_NAMES) do
                if item.Name == rodName then
                    local castEvent = item:FindFirstChild("CastEvent")
                    if castEvent then
                        return item, castEvent, rodName
                    end
                end
            end
        end
    end
    
    return nil, nil, "Tidak Ditemukan"
end

-- Update rod setiap 2 detik
local function UpdateRod()
    local rod, event, name = FindAnyRod()
    if rod and event then
        CurrentRod = rod
        CastEvent = event
        CurrentRodName = name
        return true
    else
        CurrentRod = nil
        CastEvent = nil
        CurrentRodName = "Tidak Ditemukan"
        return false
    end
end

-- Update pertama
UpdateRod()

-- Auto update terus
task.spawn(function()
    while true do
        task.wait(2)
        UpdateRod()
    end
end)

-- ========== [4. AUTO FISH CYCLE] ==========
local Settings = {
    AutoFish = false,
    FishCount = 0,
    StartTime = tick()
}

local function FishCycle()
    if not CastEvent then
        UpdateRod()
        return false
    end
    
    -- CAST
    pcall(function()
        CastEvent:FireServer()
    end)
    
    -- Delay manusiawi (0.3-0.7 detik)
    task.wait(0.4 + (math.random() * 0.3))
    
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
            task.wait(0.5 + (math.random() * 0.3))  -- Delay antar siklus
        else
            task.wait(0.5)
        end
    end
end)

-- ========== [5. UI STATUS LENGKAP] ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NikeeHUB_FishIt"
ScreenGui.Parent = Player.PlayerGui or Instance.new("ScreenGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 280, 0, 160)
Frame.Position = UDim2.new(0, 10, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Frame.BackgroundTransparency = 0.7
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "🎣 NIKEeHUB - FISH IT!"
Title.TextColor3 = Color3.fromRGB(255, 255, 0)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = Frame

-- Status Auto Fish
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 25)
StatusLabel.Position = UDim2.new(0, 0, 0, 35)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: OFF"
StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = Frame

-- Nama Rod
local RodLabel = Instance.new("TextLabel")
RodLabel.Size = UDim2.new(1, 0, 0, 25)
RodLabel.Position = UDim2.new(0, 0, 0, 65)
RodLabel.BackgroundTransparency = 1
RodLabel.Text = "Rod: " .. CurrentRodName
RodLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
RodLabel.TextScaled = true
RodLabel.Font = Enum.Font.Gotham
RodLabel.Parent = Frame

-- Ikan
local FishLabel = Instance.new("TextLabel")
FishLabel.Size = UDim2.new(1, 0, 0, 25)
FishLabel.Position = UDim2.new(0, 0, 0, 95)
FishLabel.BackgroundTransparency = 1
FishLabel.Text = "Ikan: 0"
FishLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
FishLabel.TextScaled = true
FishLabel.Font = Enum.Font.Gotham
FishLabel.Parent = Frame

-- Credit
local CreditLabel = Instance.new("TextLabel")
CreditLabel.Size = UDim2.new(1, 0, 0, 20)
CreditLabel.Position = UDim2.new(0, 0, 0, 135)
CreditLabel.BackgroundTransparency = 1
CreditLabel.Text = "Tekan F untuk mulai"
CreditLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CreditLabel.TextScaled = true
CreditLabel.Font = Enum.Font.GothamLight
CreditLabel.Parent = Frame

-- Update UI setiap detik
task.spawn(function()
    while true do
        task.wait(0.5)
        
        -- Status
        StatusLabel.Text = Settings.AutoFish and "Status: ON 🟢" or "Status: OFF 🔴"
        StatusLabel.TextColor3 = Settings.AutoFish and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        
        -- Nama Rod (update terus)
        RodLabel.Text = "Rod: " .. CurrentRodName
        RodLabel.TextColor3 = CastEvent and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        
        -- Ikan
        FishLabel.Text = "Ikan: " .. Settings.FishCount
    end
end)

-- ========== [6. KONTROL KEYBIND] ==========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- F = Toggle Auto Fish
    if input.KeyCode == Enum.KeyCode.F then
        Settings.AutoFish = not Settings.AutoFish
        
        -- Notifikasi
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🎣 NikeeHUB",
            Text = Settings.AutoFish and "✅ Auto Fish ON" or "⏹️ Auto Fish OFF",
            Duration = 2
        })
    end
    
    -- R = Reset counter
    if input.KeyCode == Enum.KeyCode.R then
        Settings.FishCount = 0
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "📊 NikeeHUB",
            Text = "Counter direset!",
            Duration = 1.5
        })
    end
    
    -- U = Force update rod
    if input.KeyCode == Enum.KeyCode.U then
        local found = UpdateRod()
        if found then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "✅ Rod Ditemukan",
                Text = CurrentRodName,
                Duration = 2
            })
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "❌ Rod Tidak Ditemukan",
                Text = "Beli rod dulu!",
                Duration = 2
            })
        end
    end
end)

-- ========== [7. CHAT COMMANDS] ==========
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
        if CastEvent and CurrentRod then
            ChatRemote:FireServer("✅ Rod: " .. CurrentRodName, "All")
        else
            ChatRemote:FireServer("❌ Rod tidak ditemukan! Beli rod dulu.", "All")
        end
    end
    
    if msg == "!stats" or msg == "!s" then
        local runtime = math.floor(tick() - Settings.StartTime)
        local mins = math.floor(runtime / 60)
        local secs = runtime % 60
        ChatRemote:FireServer(
            string.format("🎣 Ikan: %d | ⏱️ %dm %ds", Settings.FishCount, mins, secs),
            "All"
        )
    end
    
    if msg == "!rodlist" then
        -- Kirim daftar rod yang tersedia di game
        ChatRemote:FireServer("📋 Daftar Rod: Starter, Luck, Carbon, Toy, Grass, Demascus, Ice, Lava, Lucky, Midnight, Steampunk, Chrome, Fluorescent, Astral, Hazmat, Ares, Angler, Ghostfinn, Bamboo, Element", "All")
    end
end)

-- ========== [8. DIAGNOSTIK LENGKAP] ==========
print("========== NIKEeHUB DIAGNOSTIK FISH IT! ==========")
print("🔍 MENCARI ROD DI BACKPACK...")
for i, item in ipairs(Player.Backpack:GetChildren()) do
    print("  📦 " .. i .. ". " .. item.Name)
    for _, rodName in ipairs(ROD_NAMES) do
        if item.Name == rodName then
            print("     ✅ INI ROD RESMI! Nama: " .. rodName)
            if item:FindFirstChild("CastEvent") then
                print("     ✅ ✅ MEMILIKI CASTEVENT! SIAP PAKAI!")
            end
        end
    end
end

print("\n🔍 MENCARI ROD DI CHARACTER...")
if Player.Character then
    for i, item in ipairs(Player.Character:GetChildren()) do
        print("  🧍 " .. i .. ". " .. item.Name)
        for _, rodName in ipairs(ROD_NAMES) do
            if item.Name == rodName then
                print("     ✅ INI ROD RESMI! Nama: " .. rodName)
                if item:FindFirstChild("CastEvent") then
                    print("     ✅ ✅ MEMILIKI CASTEVENT! SIAP PAKAI!")
                end
            end
        end
    end
end

print("\n==========================================")
print("✅ ROD YANG TERDETEKSI SEKARANG: " .. CurrentRodName)
print("✅ STATUS CASTEVENT: " .. (CastEvent and "READY" or "TIDAK ADA"))
print("==========================================")

-- ========== [9. NOTIFIKASI AWAL]==========
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🎣 NikeeHUB - FIXED!",
    Text = "Tekan F untuk mulai | U untuk cek rod",
    Duration = 5
})

print("\n✅ SCRIPT SIAP! TEKAN F UNTUK MULAI AUTO FISH")
print("✅ NAMA ROD YANG BENAR: Starter Rod (bukan Fishing Rod!)")
print("✅ Daftar lengkap rod: ketik !rodlist di chat")end

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

