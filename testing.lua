--[[
    🔥 RIOTESTTING - FISH IT! BLATANT EDITION
    ✅ DETEKSI ROD DI TANGAN (PRIORITAS) + BACKPACK
    ✅ BLATANT MODE ON/OFF (TOGGLE)
    ✅ UI MODERN - DRAGGABLE, TRANSPARAN, WARNA MERAH-HITAM
    ✅ TANPA LIBRARY - TANPA ERROR NIL
    ✅ KEYBIND LENGKAP
]]

-- ========== [1. INISIALISASI] ==========
repeat task.wait() until game:IsLoaded()

local Player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

-- ========== [2. KONFIGURASI] ==========
local Settings = {
    -- AUTO FISH
    AutoFish = false,
    FishCount = 0,
    TotalEarnings = 0,
    StartTime = tick(),
    
    -- BLATANT MODE (DEFAULT ON)
    BlatantMode = true,
    
    -- DELAY (BLATANT = 0.01, LEGIT = 0.3)
    ReelDelay = 0.01,
    CycleDelay = 0.01,
    MultiCast = 3,
    
    -- AUTO SELL
    AutoSell = false,
    SellDelay = 5,
    
    -- AUTO COLLECT
    AutoCollect = false,
    CollectRadius = 100,
    
    -- SPEED
    SpeedBoost = false,
    WalkSpeed = 250,
    JumpPower = 250,
    InfJump = false,
    
    -- ANTI AFK
    AntiAFK = true,
}

-- ========== [3. DAFTAR NAMA ROD RESMI] ==========
local ROD_NAMES = {
    "Starter Rod", "Luck Rod", "Carbon Rod", "Toy Rod",
    "Grass Rod", "Demascus Rod", "Ice Rod", "Lava Rod",
    "Lucky Rod", "Midnight Rod", "Steampunk Rod", "Chrome Rod",
    "Fluorescent Rod", "Astral Rod", "Hazmat Rod",
    "Ares Rod", "Angler Rod", "Ghostfinn Rod", "Bamboo Rod",
    "Element Rod", "Angelic Rod", "Gold Rod", "Hyper Rod"
}

-- ========== [4. AUTO DETEKSI ROD (PRIORITAS TANGAN)] ==========
local CastEvent = nil
local CurrentRod = nil
local CurrentRodName = "Tidak Ditemukan"
local RodInHand = false

local function FindRod()
    -- PRIORITAS 1: CEK DI TANGAN (CHARACTER)
    if Player.Character then
        for _, item in ipairs(Player.Character:GetChildren()) do
            if item:IsA("Tool") then
                for _, name in ipairs(ROD_NAMES) do
                    if item.Name == name then
                        local event = item:FindFirstChild("CastEvent")
                        if event then
                            return item, event, name, true
                        end
                    end
                end
            end
        end
    end
    
    -- PRIORITAS 2: CEK DI BACKPACK
    for _, item in ipairs(Player.Backpack:GetChildren()) do
        for _, name in ipairs(ROD_NAMES) do
            if item.Name == name then
                local event = item:FindFirstChild("CastEvent")
                if event then
                    return item, event, name, false
                end
            end
        end
    end
    
    return nil, nil, "Tidak Ditemukan", false
end

local function UpdateRod()
    local rod, event, name, inHand = FindRod()
    if rod and event then
        CurrentRod = rod
        CastEvent = event
        CurrentRodName = name
        RodInHand = inHand
        return true
    else
        CurrentRod = nil
        CastEvent = nil
        CurrentRodName = "Tidak Ditemukan"
        RodInHand = false
        return false
    end
end

-- Update pertama
UpdateRod()

-- Auto update tiap 2 detik
task.spawn(function()
    while true do
        task.wait(2)
        UpdateRod()
    end
end)

-- ========== [5. AUTO FISH - BLATANT / LEGIT] ==========
local function FishCycle()
    if not CastEvent then return false end
    
    local reelDelay = Settings.BlatantMode and 0.01 or 0.3
    local multiCast = Settings.BlatantMode and 3 or 1
    local cycleDelay = Settings.BlatantMode and 0.01 or 0.5
    
    for i = 1, multiCast do
        pcall(function()
            CastEvent:FireServer()
            task.wait(reelDelay)
            CastEvent:FireServer()
        end)
        Settings.FishCount = Settings.FishCount + 1
        task.wait(0.01)
    end
    
    task.wait(cycleDelay)
    return true
end

task.spawn(function()
    while true do
        if Settings.AutoFish and CastEvent then
            pcall(FishCycle)
        else
            task.wait(0.1)
        end
    end
end)

-- ========== [6. AUTO SELL] ==========
local SellRemote = nil
local function FindSellRemote()
    for _, v in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if v.Name:lower():find("sell") and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
            return v
        end
    end
    return nil
end

task.spawn(function()
    task.wait(3)
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

-- ========== [7. AUTO COLLECT] ==========
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
                        Player.Character.HumanoidRootPart.CFrame = CFrame.new(v.Position + Vector3.new(0,3,0))
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

-- ========== [8. SPEED & INF JUMP] ==========
RunService.Heartbeat:Connect(function()
    if Settings.SpeedBoost and Player.Character and Player.Character.Humanoid then
        Player.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
        Player.Character.Humanoid.JumpPower = Settings.JumpPower
    end
end)

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

-- ========== [10. UI MODERN - DRAGGABLE, GLASS EFFECT] ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RioTestting_UI"
ScreenGui.Parent = Player.PlayerGui or Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false

-- Frame utama
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 260)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -130)  -- Tengah layar
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Bayangan
local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.Position = UDim2.new(0, -5, 0, -5)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://1316045217"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.8
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.Parent = MainFrame

-- Border glow merah
local Border = Instance.new("Frame")
Border.Size = UDim2.new(1, 0, 1, 0)
Border.BackgroundTransparency = 1
Border.BorderSizePixel = 3
Border.BorderColor3 = Color3.fromRGB(255, 50, 50)
Border.Parent = MainFrame

-- Top bar (draggable)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 35)
TopBar.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
TopBar.BackgroundTransparency = 0.2
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

-- Judul
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔥 RIOTESTTING - BLATANT"
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Tombol close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 2.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseBtn.BackgroundTransparency = 0.5
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = TopBar
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Tombol minimize
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -70, 0, 2.5)
MinBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
MinBtn.BackgroundTransparency = 0.5
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextScaled = true
MinBtn.Font = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.Parent = TopBar
MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    task.wait(0.1)
    MainFrame.Visible = true  -- toggle, sederhananya sembunyikan
    -- Implementasi minimize bisa lebih kompleks, sederhanakan
end)

-- Draggable
local dragging = false
local dragInput, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Konten
local ContentY = 45

-- Status Auto Fish
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.5, -10, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, ContentY)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "⚡ AUTO FISH: OFF"
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- Tombol toggle Auto Fish (F)
local FishBtn = Instance.new("TextButton")
FishBtn.Size = UDim2.new(0, 80, 0, 30)
FishBtn.Position = UDim2.new(0.5, -40, 0, ContentY)
FishBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
FishBtn.BackgroundTransparency = 0.3
FishBtn.Text = "F: OFF"
FishBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FishBtn.TextScaled = true
FishBtn.Font = Enum.Font.GothamBold
FishBtn.BorderSizePixel = 0
FishBtn.Parent = MainFrame
FishBtn.MouseButton1Click:Connect(function()
    Settings.AutoFish = not Settings.AutoFish
    FishBtn.Text = Settings.AutoFish and "F: ON" or "F: OFF"
    FishBtn.BackgroundColor3 = Settings.AutoFish and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(255, 50, 50)
end)

ContentY = ContentY + 40

-- Status Rod
local RodLabel = Instance.new("TextLabel")
RodLabel.Size = UDim2.new(0.7, -10, 0, 30)
RodLabel.Position = UDim2.new(0, 10, 0, ContentY)
RodLabel.BackgroundTransparency = 1
RodLabel.Text = "🎣 ROD: Mencari..."
RodLabel.TextColor3 = Color3.fromRGB(255, 200, 200)
RodLabel.TextScaled = true
RodLabel.Font = Enum.Font.Gotham
RodLabel.TextXAlignment = Enum.TextXAlignment.Left
RodLabel.Parent = MainFrame

-- Tombol Update Rod (U)
local UpdateBtn = Instance.new("TextButton")
UpdateBtn.Size = UDim2.new(0, 60, 0, 30)
UpdateBtn.Position = UDim2.new(0.7, 10, 0, ContentY)
UpdateBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
UpdateBtn.BackgroundTransparency = 0.3
UpdateBtn.Text = "U"
UpdateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UpdateBtn.TextScaled = true
UpdateBtn.Font = Enum.Font.GothamBold
UpdateBtn.BorderSizePixel = 0
UpdateBtn.Parent = MainFrame
UpdateBtn.MouseButton1Click:Connect(function()
    local found = UpdateRod()
    if found then
        RodLabel.Text = "🎣 ROD: " .. CurrentRodName .. (RodInHand and " (TANGAN)" or " (TAS)")
        RodLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        RodLabel.Text = "🎣 ROD: TIDAK DITEMUKAN"
        RodLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

ContentY = ContentY + 40

-- Ikan Counter
local FishCountLabel = Instance.new("TextLabel")
FishCountLabel.Size = UDim2.new(0.5, -10, 0, 30)
FishCountLabel.Position = UDim2.new(0, 10, 0, ContentY)
FishCountLabel.BackgroundTransparency = 1
FishCountLabel.Text = "🐟 IKAN: 0"
FishCountLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
FishCountLabel.TextScaled = true
FishCountLabel.Font = Enum.Font.Gotham
FishCountLabel.TextXAlignment = Enum.TextXAlignment.Left
FishCountLabel.Parent = MainFrame

-- Tombol Reset (R)
local ResetBtn = Instance.new("TextButton")
ResetBtn.Size = UDim2.new(0, 60, 0, 30)
ResetBtn.Position = UDim2.new(0.5, -30, 0, ContentY)
ResetBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
ResetBtn.BackgroundTransparency = 0.3
ResetBtn.Text = "R"
ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetBtn.TextScaled = true
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.BorderSizePixel = 0
ResetBtn.Parent = MainFrame
ResetBtn.MouseButton1Click:Connect(function()
    Settings.FishCount = 0
    Settings.TotalEarnings = 0
    FishCountLabel.Text = "🐟 IKAN: 0"
end)

ContentY = ContentY + 40

-- BLATANT MODE TOGGLE
local BlatantLabel = Instance.new("TextLabel")
BlatantLabel.Size = UDim2.new(0.5, -10, 0, 30)
BlatantLabel.Position = UDim2.new(0, 10, 0, ContentY)
BlatantLabel.BackgroundTransparency = 1
BlatantLabel.Text = "⚡ BLATANT MODE: ON"
BlatantLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
BlatantLabel.TextScaled = true
BlatantLabel.Font = Enum.Font.GothamBlack
BlatantLabel.TextXAlignment = Enum.TextXAlignment.Left
BlatantLabel.Parent = MainFrame

local BlatantBtn = Instance.new("TextButton")
BlatantBtn.Size = UDim2.new(0, 80, 0, 30)
BlatantBtn.Position = UDim2.new(0.5, -40, 0, ContentY)
BlatantBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
BlatantBtn.BackgroundTransparency = 0.3
BlatantBtn.Text = "B: ON"
BlatantBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BlatantBtn.TextScaled = true
BlatantBtn.Font = Enum.Font.GothamBold
BlatantBtn.BorderSizePixel = 0
BlatantBtn.Parent = MainFrame
BlatantBtn.MouseButton1Click:Connect(function()
    Settings.BlatantMode = not Settings.BlatantMode
    BlatantBtn.Text = Settings.BlatantMode and "B: ON" or "B: OFF"
    BlatantBtn.BackgroundColor3 = Settings.BlatantMode and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(100, 100, 100)
    BlatantLabel.Text = Settings.BlatantMode and "⚡ BLATANT MODE: ON" or "⚡ BLATANT MODE: OFF"
    BlatantLabel.TextColor3 = Settings.BlatantMode and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(200, 200, 200)
end)

ContentY = ContentY + 40

-- Teleport shortcuts
local TeleportLabel = Instance.new("TextLabel")
TeleportLabel.Size = UDim2.new(1, -20, 0, 25)
TeleportLabel.Position = UDim2.new(0, 10, 0, ContentY)
TeleportLabel.BackgroundTransparency = 1
TeleportLabel.Text = "📍 TELEPORT: 1=Spawn 2=Shop 3=Lava 4=Jungle 5=Ice 6=Pirate 7=Temple 8=Deep"
TeleportLabel.TextColor3 = Color3.fromRGB(200, 200, 0)
TeleportLabel.TextScaled = true
TeleportLabel.Font = Enum.Font.Gotham
TeleportLabel.TextXAlignment = Enum.TextXAlignment.Left
TeleportLabel.Parent = MainFrame

ContentY = ContentY + 30

-- Credit
local CreditLabel = Instance.new("TextLabel")
CreditLabel.Size = UDim2.new(1, -20, 0, 20)
CreditLabel.Position = UDim2.new(0, 10, 0, ContentY)
CreditLabel.BackgroundTransparency = 1
CreditLabel.Text = "🔥 RioTestting - YOLO BLATANT | F:Auto U:Rod B:Blatant R:Reset"
CreditLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CreditLabel.TextScaled = true
CreditLabel.Font = Enum.Font.GothamLight
CreditLabel.TextXAlignment = Enum.TextXAlignment.Left
CreditLabel.Parent = MainFrame

-- ========== [11. UPDATE UI LOOP] ==========
task.spawn(function()
    while true do
        task.wait(0.3)
        -- Update status auto fish
        StatusLabel.Text = Settings.AutoFish and "⚡ AUTO FISH: ON" or "⚡ AUTO FISH: OFF"
        StatusLabel.TextColor3 = Settings.AutoFish and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        FishBtn.Text = Settings.AutoFish and "F: ON" or "F: OFF"
        FishBtn.BackgroundColor3 = Settings.AutoFish and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(255, 50, 50)
        
        -- Update rod status
        if CastEvent then
            RodLabel.Text = "🎣 ROD: " .. CurrentRodName .. (RodInHand and " (TANGAN)" or " (TAS)")
            RodLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            RodLabel.Text = "🎣 ROD: TIDAK DITEMUKAN"
            RodLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
        
        -- Update fish count
        FishCountLabel.Text = "🐟 IKAN: " .. Settings.FishCount
    end
end)

-- ========== [12. KEYBINDS] ==========
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    -- F: TOGGLE AUTO FISH
    if input.KeyCode == Enum.KeyCode.F then
        Settings.AutoFish = not Settings.AutoFish
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🔥 RioTestting",
            Text = Settings.AutoFish and "AUTO FISH ON" or "AUTO FISH OFF",
            Duration = 1
        })
    end
    
    -- U: UPDATE ROD
    if input.KeyCode == Enum.KeyCode.U then
        local found = UpdateRod()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🎣 RioTestting",
            Text = found and "Rod: " .. CurrentRodName or "Rod tidak ditemukan!",
            Duration = 1.5
        })
    end
    
    -- B: TOGGLE BLATANT MODE
    if input.KeyCode == Enum.KeyCode.B then
        Settings.BlatantMode = not Settings.BlatantMode
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "⚡ RioTestting",
            Text = Settings.BlatantMode and "BLATANT MODE ON" or "BLATANT MODE OFF",
            Duration = 1
        })
    end
    
    -- R: RESET COUNTER
    if input.KeyCode == Enum.KeyCode.R then
        Settings.FishCount = 0
        Settings.TotalEarnings = 0
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "📊 RioTestting",
            Text = "Counter direset!",
            Duration = 1
        })
    end
    
    -- H: TOGGLE SPEED BOOST
    if input.KeyCode == Enum.KeyCode.H then
        Settings.SpeedBoost = not Settings.SpeedBoost
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "⚡ RioTestting",
            Text = Settings.SpeedBoost and "SPEED ON" or "SPEED OFF",
            Duration = 1
        })
    end
    
    -- J: TOGGLE AUTO COLLECT
    if input.KeyCode == Enum.KeyCode.J then
        Settings.AutoCollect = not Settings.AutoCollect
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "📦 RioTestting",
            Text = Settings.AutoCollect and "AUTO COLLECT ON" or "AUTO COLLECT OFF",
            Duration = 1
        })
    end
    
    -- K: TOGGLE INF JUMP
    if input.KeyCode == Enum.KeyCode.K then
        Settings.InfJump = not Settings.InfJump
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🦘 RioTestting",
            Text = Settings.InfJump and "INF JUMP ON" or "INF JUMP OFF",
            Duration = 1
        })
    end
end)

-- ========== [13. TELEPORT KEYBINDS] ==========
local TeleportLocs = {
    [Enum.KeyCode.One] = CFrame.new(0, 10, 0),
    [Enum.KeyCode.Two] = CFrame.new(50, 10, 50),
    [Enum.KeyCode.Three] = CFrame.new(200, 30, -150),
    [Enum.KeyCode.Four] = CFrame.new(-100, 20, 300),
    [Enum.KeyCode.Five] = CFrame.new(400, 50, 400),
    [Enum.KeyCode.Six] = CFrame.new(-200, 15, 250),
    [Enum.KeyCode.Seven] = CFrame.new(300, 40, -200),
    [Enum.KeyCode.Eight] = CFrame.new(500, 20, 500),
}

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local cf = TeleportLocs[input.KeyCode]
    if cf and Player.Character and Player.Character.HumanoidRootPart then
        Player.Character.HumanoidRootPart.CFrame = cf
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "📍 RioTestting",
            Text = "Teleport!",
            Duration = 0.8
        })
    end
end)

-- ========== [14. NOTIFIKASI START] ==========
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🔥 RIOTESTTING - FINAL",
    Text = "Tekan U cek rod, F auto fish, B blatant!",
    Duration = 5
})

print("==========================================")
print("🔥 RIOTESTTING - BLATANT FISH IT! (FULL GUI)")
print("✅ DETEKSI ROD DI TANGAN + TAS")
print("✅ BLATANT MODE TOGGLE (B)")
print("✅ UI DRAGGABLE + KEYBIND LENGKAP")
print("✅ ROD DEFAULT: Starter Rod (bukan Fishing Rod!)")
print("==========================================")
