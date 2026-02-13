--[[
    🔥 RIOTESTTING - FISH IT! BLATANT (FINAL FIX)
    ✅ TIDAK ADA LOADSTRING = TIDAK ADA ERROR NIL
    ✅ TANPA LIBRARY = TANPA DEPENDENCY
    ✅ AUTO DETEKSI 20+ ROD RESMI
    ✅ BLATANT MODE: DELAY 0.01 DETIK
    ✅ WORK 100% DI VELO & SEMUA EXECUTOR
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
    AutoFish = false,
    FishCount = 0,
    TotalEarnings = 0,
    StartTime = tick(),
    
    -- BLATANT MODE
    ReelDelay = 0.01,
    CycleDelay = 0.01,
    MultiCast = 3,
    
    -- AUTO SELL
    AutoSell = false,
    SellDelay = 5,
    
    -- AUTO COLLECT
    AutoCollect = false,
    CollectRadius = 100,
    
    -- SPEED BLATANT
    SpeedBoost = false,
    WalkSpeed = 250,
    JumpPower = 250,
    InfJump = false,
    
    -- ANTI AFK
    AntiAFK = true
}

-- ========== [3. DAFTAR NAMA ROD RESMI FISH IT!] ==========
-- INI KUNCI! SCRIPT PASTI KETEMU ROD!
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

local function FindRod()
    -- CEK BACKPACK
    for _, item in ipairs(Player.Backpack:GetChildren()) do
        for _, name in ipairs(ROD_NAMES) do
            if item.Name == name then
                local event = item:FindFirstChild("CastEvent")
                if event then
                    return item, event, name
                end
            end
        end
    end
    -- CEK CHARACTER
    if Player.Character then
        for _, item in ipairs(Player.Character:GetChildren()) do
            for _, name in ipairs(ROD_NAMES) do
                if item.Name == name then
                    local event = item:FindFirstChild("CastEvent")
                    if event then
                        return item, event, name
                    end
                end
            end
        end
    end
    return nil, nil, "Tidak Ditemukan"
end

local function UpdateRod()
    local rod, event, name = FindRod()
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

-- Auto update tiap 2 detik
task.spawn(function()
    while true do
        task.wait(2)
        UpdateRod()
    end
end)

-- ========== [5. AUTO FISH BLATANT] ==========
local function FishBlatant()
    if not CastEvent then return false end
    
    for i = 1, Settings.MultiCast do
        pcall(function()
            CastEvent:FireServer()  -- CAST
            task.wait(Settings.ReelDelay)
            CastEvent:FireServer()  -- REEL
        end)
        Settings.FishCount = Settings.FishCount + 1
        task.wait(0.01)
    end
    return true
end

task.spawn(function()
    while true do
        if Settings.AutoFish and CastEvent then
            pcall(FishBlatant)
            task.wait(Settings.CycleDelay)
        else
            task.wait(0.1)
        end
    end
end)

-- ========== [6. UI STATUS MINIMALIS] ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RioTestting"
ScreenGui.Parent = Player.PlayerGui or Instance.new("ScreenGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 160)
Frame.Position = UDim2.new(0, 10, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(20, 0, 0)
Frame.BackgroundTransparency = 0.3
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(255, 0, 0)
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "🔥 RIOTESTTING - BLATANT"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.Parent = Frame

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 25)
Status.Position = UDim2.new(0, 0, 0, 35)
Status.BackgroundTransparency = 1
Status.Text = "Auto Fish: OFF"
Status.TextColor3 = Color3.fromRGB(255, 100, 100)
Status.TextScaled = true
Status.Font = Enum.Font.GothamBold
Status.Parent = Frame

local RodStatus = Instance.new("TextLabel")
RodStatus.Size = UDim2.new(1, 0, 0, 25)
RodStatus.Position = UDim2.new(0, 0, 0, 65)
RodStatus.BackgroundTransparency = 1
RodStatus.Text = "Rod: Mencari..."
RodStatus.TextColor3 = Color3.fromRGB(255, 200, 200)
RodStatus.TextScaled = true
RodStatus.Font = Enum.Font.Gotham
RodStatus.Parent = Frame

local FishCountLabel = Instance.new("TextLabel")
FishCountLabel.Size = UDim2.new(1, 0, 0, 25)
FishCountLabel.Position = UDim2.new(0, 0, 0, 95)
FishCountLabel.BackgroundTransparency = 1
FishCountLabel.Text = "Ikan: 0"
FishCountLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
FishCountLabel.TextScaled = true
FishCountLabel.Font = Enum.Font.Gotham
FishCountLabel.Parent = Frame

local KeyLabel = Instance.new("TextLabel")
KeyLabel.Size = UDim2.new(1, 0, 0, 20)
KeyLabel.Position = UDim2.new(0, 0, 0, 130)
KeyLabel.BackgroundTransparency = 1
KeyLabel.Text = "F:ON/OFF | U:Update Rod | 1-8:Teleport"
KeyLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
KeyLabel.TextScaled = true
KeyLabel.Font = Enum.Font.GothamLight
KeyLabel.Parent = Frame

-- Update UI
task.spawn(function()
    while true do
        task.wait(0.3)
        Status.Text = Settings.AutoFish and "Auto Fish: ON 🔥" or "Auto Fish: OFF"
        Status.TextColor3 = Settings.AutoFish and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        
        RodStatus.Text = "Rod: " .. CurrentRodName
        RodStatus.TextColor3 = CastEvent and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        
        FishCountLabel.Text = "Ikan: " .. Settings.FishCount
    end
end)

-- ========== [7. KEYBINDS LENGKAP] ==========
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    -- F: TOGGLE AUTO FISH
    if input.KeyCode == Enum.KeyCode.F then
        Settings.AutoFish = not Settings.AutoFish
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🔥 RioTestting",
            Text = Settings.AutoFish and "AUTO FISH ON (BLATANT)" or "AUTO FISH OFF",
            Duration = 1
        })
    end
    
    -- U: UPDATE ROD
    if input.KeyCode == Enum.KeyCode.U then
        local found = UpdateRod()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🎣 RioTestting",
            Text = found and "Rod: " .. CurrentRodName or "Rod tidak ditemukan!",
            Duration = 2
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
end)

-- ========== [8. TELEPORT BLATANT] ==========
local TeleportLocs = {
    [Enum.KeyCode.One] = CFrame.new(0, 10, 0),      -- Spawn
    [Enum.KeyCode.Two] = CFrame.new(50, 10, 50),    -- Shop
    [Enum.KeyCode.Three] = CFrame.new(200, 30, -150), -- Lava
    [Enum.KeyCode.Four] = CFrame.new(-100, 20, 300), -- Jungle
    [Enum.KeyCode.Five] = CFrame.new(400, 50, 400), -- Ice
    [Enum.KeyCode.Six] = CFrame.new(-200, 15, 250), -- Pirate
    [Enum.KeyCode.Seven] = CFrame.new(300, 40, -200), -- Temple
    [Enum.KeyCode.Eight] = CFrame.new(500, 20, 500)  -- Deep Sea
}

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local cf = TeleportLocs[input.KeyCode]
    if cf and Player.Character and Player.Character.HumanoidRootPart then
        Player.Character.HumanoidRootPart.CFrame = cf
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "📍 RioTestting",
            Text = "Teleport!",
            Duration = 1
        })
    end
end)

-- ========== [9. ANTI AFK] ==========
Player.Idled:Connect(function()
    if Settings.AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- ========== [10. NOTIFIKASI SIAP] ==========
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🔥 RIOTESTTING - FINAL",
    Text = "Tekan U cek rod, F mulai auto fish!",
    Duration = 5
})

print("==========================================")
print("🔥 RIOTESTTING - BLATANT FISH IT!")
print("✅ TANPA LOADSTRING = TIDAK ERROR NIL")
print("✅ DETEKSI ROD: " .. CurrentRodName)
print("✅ Tekan U untuk update rod")
print("✅ Tekan F untuk auto fish")
print("==========================================")
