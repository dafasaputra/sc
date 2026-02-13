--[[
    🔥 RIOTESTTING - FISH IT! AUTO FISH (BLATANT EDITION)
    ✅ BLATANT MODE - MAKSIMAL KECEPATAN
    ✅ AUTO DETEKSI 20+ NAMA ROD RESMI
    ✅ TANPA LIBRARY - TANPA ERROR
    ✅ WORK 100% DI SEMUA ROD
    ✅ TIDAK PEDULI DETEKSI - YOLO!
]]

-- ========== [1. INISIALISASI] ==========
repeat task.wait() until game:IsLoaded()

local Player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

-- ========== [2. KONFIGURASI RIOTESTTING] ==========
local Settings = {
    -- AUTO FISH
    AutoFish = false,
    FishCount = 0,
    TotalEarnings = 0,
    StartTime = tick(),
    
    -- BLATANT MODE SETTINGS
    BlatantMode = true,           -- MODE BLATANT: ON!
    ReelDelay = 0.01,            -- SUPER CEPAT (0.01 detik)
    CycleDelay = 0.01,           -- SUPER CEPAT (0.01 detik)
    MultiCast = 3,              -- Cast 3x per siklus
    IgnoreAntiCheat = true,     -- Abaikan anti-cheat
    
    -- AUTO SELL (BLATANT)
    AutoSell = false,
    SellDelay = 5,              -- Jual setiap 5 detik
    
    -- AUTO COLLECT (BLATANT)
    AutoCollect = false,
    CollectRadius = 100,        -- Ambil dari jarak 100 studs
    
    -- MOVEMENT (BLATANT)
    SpeedBoost = false,
    WalkSpeed = 250,           -- SUPER CEPAT
    JumpPower = 250,           -- SUPER TINGGI
    InfJump = false,
    
    -- ANTI AFK
    AntiAFK = true,
    
    -- DEBUG
    DebugMode = true
}

-- ========== [3. DAFTAR LENGKAP NAMA ROD FISH IT!] ==========
local ROD_NAMES = {
    "Starter Rod", "Luck Rod", "Carbon Rod", "Toy Rod",
    "Grass Rod", "Demascus Rod", "Ice Rod", "Lava Rod",
    "Lucky Rod", "Midnight Rod", "Steampunk Rod", "Chrome Rod",
    "Fluorescent Rod", "Astral Rod", "Hazmat Rod",
    "Ares Rod", "Angler Rod", "Ghostfinn Rod", "Bamboo Rod",
    "Element Rod", "Angelic Rod", "Gold Rod", "Hyper Rod"
}

-- ========== [4. AUTO DETEKSI ROD] ==========
local CastEvent = nil
local CurrentRod = nil
local CurrentRodName = "Tidak Ditemukan"

local function FindAnyRod()
    -- CEK BACKPACK
    for _, item in ipairs(Player.Backpack:GetChildren()) do
        for _, rodName in ipairs(ROD_NAMES) do
            if item.Name == rodName then
                local castEvent = item:FindFirstChild("CastEvent")
                if castEvent then return item, castEvent, rodName end
            end
        end
    end
    
    -- CEK CHARACTER
    if Player.Character then
        for _, item in ipairs(Player.Character:GetChildren()) do
            for _, rodName in ipairs(ROD_NAMES) do
                if item.Name == rodName then
                    local castEvent = item:FindFirstChild("CastEvent")
                    if castEvent then return item, castEvent, rodName end
                end
            end
        end
    end
    
    return nil, nil, "Tidak Ditemukan"
end

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

UpdateRod()
task.spawn(function() while true do task.wait(2) UpdateRod() end end)

-- ========== [5. AUTO FISH - BLATANT MODE] ==========
local function FishCycle_Blatant()
    if not CastEvent then return false end
    
    -- MULTI CAST BLATANT
    for i = 1, Settings.MultiCast do
        pcall(function()
            CastEvent:FireServer()  -- CAST
            task.wait(Settings.ReelDelay)
            CastEvent:FireServer()  -- REEL
        end)
        Settings.FishCount = Settings.FishCount + 1
        task.wait(0.01)  -- SUPER CEPAT
    end
    
    return true
end

-- Loop BLATANT
task.spawn(function()
    while true do
        if Settings.AutoFish and CastEvent then
            pcall(FishCycle_Blatant)
            task.wait(Settings.CycleDelay)
        else
            task.wait(0.1)
        end
    end
end)

-- ========== [6. AUTO SELL - BLATANT] ==========
local SellRemote = nil

local function FindSellRemote()
    -- Cari remote jual di semua lokasi
    for _, v in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if v.Name:lower():find("sell") and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
            return v
        end
    end
    return nil
end

task.spawn(function()
    task.wait(2)
    SellRemote = FindSellRemote()
end)

task.spawn(function()
    while true do
        task.wait(Settings.SellDelay)
        if Settings.AutoSell and SellRemote then
            pcall(function()
                if SellRemote:IsA("RemoteEvent") then
                    SellRemote:FireServer()
                else
                    SellRemote:InvokeServer()
                end
                Settings.TotalEarnings = Settings.TotalEarnings + 1000
            end)
        end
    end
end)

-- ========== [7. AUTO COLLECT - BLATANT] ==========
task.spawn(function()
    while true do
        task.wait(1)
        if Settings.AutoCollect and Player.Character and Player.Character.HumanoidRootPart then
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") and (
                    v.Name:lower():find("chest") or 
                    v.Name:lower():find("treasure") or 
                    v.Name:lower():find("crate") or
                    v.Name:lower():find("loot") or
                    v.Name:lower():find("box")
                ) then
                    local dist = (Player.Character.HumanoidRootPart.Position - v.Position).Magnitude
                    if dist < Settings.CollectRadius then
                        -- TELEPORT BLATANT
                        Player.Character.HumanoidRootPart.CFrame = CFrame.new(v.Position + Vector3.new(0, 3, 0))
                        task.wait(0.05)
                        firetouchinterest(Player.Character.HumanoidRootPart, v, 0)
                        task.wait(0.05)
                        firetouchinterest(Player.Character.HumanoidRootPart, v, 1)
                    end
                end
            end
        end
    end
end)

-- ========== [8. SPEED BLATANT] ==========
RunService.Heartbeat:Connect(function()
    if Settings.SpeedBoost and Player.Character and Player.Character.Humanoid then
        Player.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
        Player.Character.Humanoid.JumpPower = Settings.JumpPower
    end
end)

-- INFINITE JUMP
UserInputService.JumpRequest:Connect(function()
    if Settings.InfJump and Player.Character and Player.Character.Humanoid then
        Player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ========== [9. ANTI AFK] ==========
Player.Idled:Connect(function()
    if Settings.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- ========== [10. UI RIOTESTTING - MERAH HITAM] ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RioTestting_UI"
ScreenGui.Parent = Player.PlayerGui or Instance.new("ScreenGui")

-- MAIN FRAME
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 320, 0, 240)
Frame.Position = UDim2.new(0, 10, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(20, 0, 0)  -- MERAH TUA
Frame.BackgroundTransparency = 0.2
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

-- BORDER MERAH
local Border = Instance.new("Frame")
Border.Size = UDim2.new(1, 0, 1, 0)
Border.BackgroundTransparency = 1
Border.BorderSizePixel = 3
Border.BorderColor3 = Color3.fromRGB(255, 0, 0)  -- MERAH TERANG
Border.Parent = Frame

-- TITLE
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Title.BackgroundTransparency = 0.5
Title.Text = "🔥 RIOTESTTING - BLATANT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.Parent = Frame

-- STATUS AUTO FISH
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 30)
StatusLabel.Position = UDim2.new(0, 0, 0, 40)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Auto Fish: OFF"
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.Parent = Frame

-- ROD INFO
local RodLabel = Instance.new("TextLabel")
RodLabel.Size = UDim2.new(1, 0, 0, 25)
RodLabel.Position = UDim2.new(0, 0, 0, 75)
RodLabel.BackgroundTransparency = 1
RodLabel.Text = "Rod: Mencari..."
RodLabel.TextColor3 = Color3.fromRGB(255, 200, 200)
RodLabel.TextScaled = true
RodLabel.Font = Enum.Font.Gotham
RodLabel.Parent = Frame

-- FISH COUNT
local FishLabel = Instance.new("TextLabel")
FishLabel.Size = UDim2.new(1, 0, 0, 25)
FishLabel.Position = UDim2.new(0, 0, 0, 105)
FishLabel.BackgroundTransparency = 1
FishLabel.Text = "Ikan: 0"
FishLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
FishLabel.TextScaled = true
FishLabel.Font = Enum.Font.Gotham
FishLabel.Parent = Frame

-- EARNINGS
local MoneyLabel = Instance.new("TextLabel")
MoneyLabel.Size = UDim2.new(1, 0, 0, 25)
MoneyLabel.Position = UDim2.new(0, 0, 0, 135)
MoneyLabel.BackgroundTransparency = 1
MoneyLabel.Text = "Uang: $0"
MoneyLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
MoneyLabel.TextScaled = true
MoneyLabel.Font = Enum.Font.Gotham
FishLabel.Parent = Frame

-- BLATANT MODE STATUS
local BlatantLabel = Instance.new("TextLabel")
BlatantLabel.Size = UDim2.new(1, 0, 0, 25)
BlatantLabel.Position = UDim2.new(0, 0, 0, 165)
BlatantLabel.BackgroundTransparency = 1
BlatantLabel.Text = "BLATANT MODE: ON 🔥"
BlatantLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
BlatantLabel.TextScaled = true
BlatantLabel.Font = Enum.Font.GothamBlack
BlatantLabel.Parent = Frame

-- KEYBINDS
local KeyLabel = Instance.new("TextLabel")
KeyLabel.Size = UDim2.new(1, 0, 0, 20)
KeyLabel.Position = UDim2.new(0, 0, 0, 200)
KeyLabel.BackgroundTransparency = 1
KeyLabel.Text = "F:Fish | G:Sell | H:Speed | J:Collect | K:TP"
KeyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
KeyLabel.TextScaled = true
KeyLabel.Font = Enum.Font.GothamLight
KeyLabel.Parent = Frame

-- CREDIT
local CreditLabel = Instance.new("TextLabel")
CreditLabel.Size = UDim2.new(1, 0, 0, 20)
CreditLabel.Position = UDim2.new(0, 0, 0, 220)
CreditLabel.BackgroundTransparency = 1
CreditLabel.Text = "RioTestting - YOLO BLATANT"
CreditLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
CreditLabel.TextScaled = true
CreditLabel.Font = Enum.Font.GothamBold
CreditLabel.Parent = Frame

-- UPDATE UI
task.spawn(function()
    while true do
        task.wait(0.3)
        StatusLabel.Text = Settings.AutoFish and "Auto Fish: ON 🔥" or "Auto Fish: OFF"
        StatusLabel.TextColor3 = Settings.AutoFish and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        
        RodLabel.Text = "Rod: " .. CurrentRodName
        RodLabel.TextColor3 = CastEvent and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        
        FishLabel.Text = "Ikan: " .. Settings.FishCount
        MoneyLabel.Text = "Uang: $" .. Settings.TotalEarnings
    end
end)

-- ========== [11. TELEPORT BLATANT - SEMUA LOKASI] ==========
local TeleportSpots = {
    ["🔥 SPAWN"] = CFrame.new(0, 10, 0),
    ["💰 SHOP"] = CFrame.new(50, 10, 50),
    ["🌋 LAVA"] = CFrame.new(200, 30, -150),
    ["🌿 JUNGLE"] = CFrame.new(-100, 20, 300),
    ["❄️ ICE"] = CFrame.new(400, 50, 400),
    ["🏴‍☠️ PIRATE"] = CFrame.new(-200, 15, 250),
    ["🗿 TEMPLE"] = CFrame.new(300, 40, -200),
    ["🌊 DEEP SEA"] = CFrame.new(500, 20, 500)
}

-- ========== [12. KEYBINDS LENGKAP] ==========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- F = AUTO FISH TOGGLE
    if input.KeyCode == Enum.KeyCode.F then
        Settings.AutoFish = not Settings.AutoFish
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🔥 RioTestting",
            Text = Settings.AutoFish and "✅ AUTO FISH ON (BLATANT)" or "⏹️ AUTO FISH OFF",
            Duration = 1
        })
    end
    
    -- G = AUTO SELL TOGGLE
    if input.KeyCode == Enum.KeyCode.G then
        Settings.AutoSell = not Settings.AutoSell
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "💰 RioTestting",
            Text = Settings.AutoSell and "✅ AUTO SELL ON" or "⏹️ AUTO SELL OFF",
            Duration = 1
        })
    end
    
    -- H = SPEED BOOST TOGGLE
    if input.KeyCode == Enum.KeyCode.H then
        Settings.SpeedBoost = not Settings.SpeedBoost
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "⚡ RioTestting",
            Text = Settings.SpeedBoost and "✅ SPEED BLATANT ON" or "⏹️ SPEED OFF",
            Duration = 1
        })
    end
    
    -- J = AUTO COLLECT TOGGLE
    if input.KeyCode == Enum.KeyCode.J then
        Settings.AutoCollect = not Settings.AutoCollect
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "📦 RioTestting",
            Text = Settings.AutoCollect and "✅ AUTO COLLECT ON" or "⏹️ AUTO COLLECT OFF",
            Duration = 1
        })
    end
    
    -- K = INFINITE JUMP TOGGLE
    if input.KeyCode == Enum.KeyCode.K then
        Settings.InfJump = not Settings.InfJump
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🦘 RioTestting",
            Text = Settings.InfJump and "✅ INF JUMP ON" or "⏹️ INF JUMP OFF",
            Duration = 1
        })
    end
    
    -- L = RESET COUNTER
    if input.KeyCode == Enum.KeyCode.L then
        Settings.FishCount = 0
        Settings.TotalEarnings = 0
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "📊 RioTestting",
            Text = "Counter direset!",
            Duration = 1
        })
    end
    
    -- U = UPDATE ROD
    if input.KeyCode == Enum.KeyCode.U then
        local found = UpdateRod()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🎣 RioTestting",
            Text = found and "Rod: " .. CurrentRodName or "Rod tidak ditemukan!",
            Duration = 2
        })
    end
    
    -- TELEPORT: 1-9
    for i = 1, 8 do
        if input.KeyCode == Enum.KeyCode["Num" .. i] or input.KeyCode == Enum.KeyCode["One" .. i] then
            local spots = {"Spawn", "Shop", "Lava", "Jungle", "Ice", "Pirate", "Temple", "Deep Sea"}
            local cf = TeleportSpots["🔥 " .. spots[i]] or TeleportSpots["💰 " .. spots[i]] or 
                       TeleportSpots["🌋 " .. spots[i]] or TeleportSpots["🌿 " .. spots[i]] or
                       TeleportSpots["❄️ " .. spots[i]] or TeleportSpots["🏴‍☠️ " .. spots[i]] or
                       TeleportSpots["🗿 " .. spots[i]] or TeleportSpots["🌊 " .. spots[i]]
            
            if cf and Player.Character and Player.Character.HumanoidRootPart then
                Player.Character.HumanoidRootPart.CFrame = cf
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "📍 RioTestting",
                    Text = "Teleport ke " .. spots[i],
                    Duration = 1
                })
            end
        end
    end
    
    -- X = BLATANT MODE SETTINGS
    if input.KeyCode == Enum.KeyCode.X then
        Settings.BlatantMode = not Settings.BlatantMode
        if Settings.BlatantMode then
            Settings.ReelDelay = 0.01
            Settings.CycleDelay = 0.01
            Settings.MultiCast = 3
            Settings.WalkSpeed = 250
            BlatantLabel.Text = "BLATANT MODE: ON 🔥"
        else
            Settings.ReelDelay = 0.25
            Settings.CycleDelay = 0.5
            Settings.MultiCast = 1
            Settings.WalkSpeed = 16
            BlatantLabel.Text = "BLATANT MODE: OFF"
        end
    end
    
    -- Z = REJOIN
    if input.KeyCode == Enum.KeyCode.Z then
        TeleportService:Teleport(game.PlaceId, Player)
    end
end)

-- ========== [13. CHAT COMMANDS] ==========
local ChatRemote = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents") and 
                   game.ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")

Player.Chatted:Connect(function(msg)
    msg = msg:lower()
    
    if msg == "!fish" or msg == "!f" then
        Settings.AutoFish = not Settings.AutoFish
        if ChatRemote then
            ChatRemote:FireServer(
                Settings.AutoFish and "🔥 RIOTESTTING: AUTO FISH ON (BLATANT)" or "⏹️ AUTO FISH OFF",
                "All"
            )
        end
    end
    
    if msg == "!rod" or msg == "!r" then
        if CastEvent and CurrentRod then
            ChatRemote:FireServer("🔥 RIOTESTTING ROD: " .. CurrentRodName, "All")
        else
            ChatRemote:FireServer("❌ ROD TIDAK DITEMUKAN! BELI DULU!", "All")
        end
    end
    
    if msg == "!stats" or msg == "!s" then
        local runtime = math.floor(tick() - Settings.StartTime)
        ChatRemote:FireServer(
            string.format("🔥 RIOTESTTING | IKAN: %d | UANG: $%d | ⏱️ %dm",
                Settings.FishCount, Settings.TotalEarnings, math.floor(runtime/60)),
            "All"
        )
    end
    
    if msg == "!blatant" then
        Settings.BlatantMode = not Settings.BlatantMode
        ChatRemote:FireServer(
            Settings.BlatantMode and "🔥 BLATANT MODE: ON (MAX SPEED)" or "BLATANT MODE: OFF",
            "All"
        )
    end
    
    if msg == "!riot" or msg == "!rio" then
        ChatRemote:FireServer("🔥 RIOTESTTING - YOLO BLATANT FISH IT! TEKAN F UNTUK MULAI", "All")
    end
end)

-- ========== [14. DIAGNOSTIK] ==========
print("==========================================")
print("🔥 RIOTESTTING - BLATANT EDITION LOADED!")
print("==========================================")
print("✅ AUTO FISH: F")
print("✅ AUTO SELL: G")
print("✅ SPEED BOOST: H")
print("✅ AUTO COLLECT: J")
print("✅ INFINITE JUMP: K")
print("✅ RESET COUNTER: L")
print("✅ UPDATE ROD: U")
print("✅ TELEPORT: 1-8")
print("✅ TOGGLE BLATANT: X")
print("✅ REJOIN: Z")
print("==========================================")
print("🔥 BLATANT MODE: ON - DELAY 0.01s")
print("🔥 YOLO! TIDAK PEDULI DETEKSI!")
print("==========================================")

-- NOTIFIKASI AWAL
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🔥 RIOTESTTING - BLATANT",
    Text = "Tekan F untuk AUTO FISH!",
    Duration = 5
})
