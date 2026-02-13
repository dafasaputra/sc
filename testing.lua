--[[
    🔥 RIOTESTTING - FISH IT! DIAGNOSTIK EDITION
    ✅ FORCE DETEKSI ROD - CARI APAPUN YANG PUNYA CASTEVENT
    ✅ DEBUG LENGKAP - LIHAT DI CONSOLE
    ✅ UI SEDERHANA - TOMBOL MANUAL
    ✅ TANPA ASUMSI NAMA ROD - DETEKSI OTOMATIS
]]

-- ========== [1. INISIALISASI] ==========
repeat task.wait() until game:IsLoaded()

local Player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

-- ========== [2. DEBUG MODE - LIHAT SEMUA] ==========
print("========== RIOTESTTING DIAGNOSTIK ==========")
print("🔍 Mencari tool dengan CastEvent...")

-- ========== [3. DETEKSI ROD UNIVERSAL] ==========
local function FindAnyCastEvent()
    local results = {}
    
    -- CEK CHARACTER (TANGAN)
    if Player.Character then
        for _, item in ipairs(Player.Character:GetChildren()) do
            if item:IsA("Tool") then
                local cast = item:FindFirstChild("CastEvent")
                if cast then
                    table.insert(results, {
                        item = item,
                        cast = cast,
                        location = "Tangan",
                        name = item.Name
                    })
                end
            end
        end
    end
    
    -- CEK BACKPACK (TAS)
    for _, item in ipairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            local cast = item:FindFirstChild("CastEvent")
            if cast then
                table.insert(results, {
                    item = item,
                    cast = cast,
                    location = "Tas",
                    name = item.Name
                })
            end
        end
    end
    
    return results
end

local detectedRods = FindAnyCastEvent()
print("🎣 Ditemukan " .. #detectedRods .. " tool dengan CastEvent:")
for i, rod in ipairs(detectedRods) do
    print("   " .. i .. ". " .. rod.name .. " (" .. rod.location .. ")")
end

-- Pilih rod pertama yang ditemukan, atau nil
local CurrentRod = nil
local CastEvent = nil
local CurrentRodName = "Tidak Ada"

if #detectedRods > 0 then
    CurrentRod = detectedRods[1].item
    CastEvent = detectedRods[1].cast
    CurrentRodName = detectedRods[1].name .. " (" .. detectedRods[1].location .. ")"
    print("✅ Menggunakan: " .. CurrentRodName)
else
    print("❌ TIDAK ADA TOOL DENGAN CASTEVENT!")
    print("   Pastikan kamu sudah membeli dan memegang Fishing Rod.")
end

-- Fungsi manual pilih rod
local function SelectRod(index)
    if index >= 1 and index <= #detectedRods then
        CurrentRod = detectedRods[index].item
        CastEvent = detectedRods[index].cast
        CurrentRodName = detectedRods[index].name .. " (" .. detectedRods[index].location .. ")"
        return true
    end
    return false
end

-- Fungsi refresh rod
local function RefreshRod()
    detectedRods = FindAnyCastEvent()
    if #detectedRods > 0 then
        SelectRod(1)
        return true
    else
        CurrentRod = nil
        CastEvent = nil
        CurrentRodName = "Tidak Ada"
        return false
    end
end

-- ========== [4. AUTO FISH] ==========
local Settings = {
    AutoFish = false,
    FishCount = 0,
    BlatantMode = true,
    ReelDelay = 0.01,
    CycleDelay = 0.01,
    MultiCast = 3,
}

local function FishCycle()
    if not CastEvent then return false end
    
    local reelDelay = Settings.BlatantMode and 0.01 or 0.3
    local multiCast = Settings.BlatantMode and 3 or 1
    
    for i = 1, multiCast do
        pcall(function()
            CastEvent:FireServer()
            task.wait(reelDelay)
            CastEvent:FireServer()
        end)
        Settings.FishCount = Settings.FishCount + 1
        task.wait(0.01)
    end
    return true
end

task.spawn(function()
    while true do
        if Settings.AutoFish and CastEvent then
            pcall(FishCycle)
            task.wait(Settings.BlatantMode and 0.01 or 0.5)
        else
            task.wait(0.2)
        end
    end
end)

-- ========== [5. UI SUPER SEDERHANA - PASTI WORK] ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RioTestting_Diagnostic"
ScreenGui.Parent = Player.PlayerGui or game.CoreGui

-- Frame utama
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 350, 0, 400)
Frame.Position = UDim2.new(0.5, -175, 0.5, -200)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(255, 50, 50)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

-- Judul
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
Title.Text = "🔥 RIOTESTTING - DIAGNOSTIK"
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.Parent = Frame

-- Status Rod
local RodStatus = Instance.new("TextLabel")
RodStatus.Size = UDim2.new(1, -20, 0, 40)
RodStatus.Position = UDim2.new(0, 10, 0, 45)
RodStatus.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
RodStatus.BackgroundTransparency = 0.5
RodStatus.Text = "🎣 ROD: " .. CurrentRodName
RodStatus.TextColor3 = CastEvent and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
RodStatus.TextScaled = true
RodStatus.Font = Enum.Font.Gotham
RodStatus.Parent = Frame

-- Tombol Refresh Rod
local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0.5, -15, 0, 35)
RefreshBtn.Position = UDim2.new(0, 10, 0, 95)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
RefreshBtn.Text = "🔄 REFRESH ROD"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.TextScaled = true
RefreshBtn.Font = Enum.Font.GothamBold
RefreshBtn.BorderSizePixel = 0
RefreshBtn.Parent = Frame
RefreshBtn.MouseButton1Click:Connect(function()
    local found = RefreshRod()
    if found then
        RodStatus.Text = "🎣 ROD: " .. CurrentRodName
        RodStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        RodStatus.Text = "🎣 ROD: TIDAK DITEMUKAN"
        RodStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end)

-- Tombol Pilih Rod Manual
local ManualLabel = Instance.new("TextLabel")
ManualLabel.Size = UDim2.new(0.5, -15, 0, 35)
ManualLabel.Position = UDim2.new(0.5, 5, 0, 95)
ManualLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ManualLabel.Text = "📋 PILIH ROD"
ManualLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
ManualLabel.TextScaled = true
ManualLabel.Font = Enum.Font.Gotham
ManualLabel.Parent = Frame

-- Dropdown sederhana (pakai tombol-tombol)
local RodListFrame = Instance.new("Frame")
RodListFrame.Size = UDim2.new(1, -20, 0, 120)
RodListFrame.Position = UDim2.new(0, 10, 0, 140)
RodListFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
RodListFrame.BorderSizePixel = 1
RodListFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
RodListFrame.Visible = false
RodListFrame.Parent = Frame

ManualLabel.MouseButton1Click:Connect(function()
    RodListFrame.Visible = not RodListFrame.Visible
    -- Update daftar rod
    for _, v in ipairs(RodListFrame:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    local y = 5
    for i, rod in ipairs(detectedRods) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 25)
        btn.Position = UDim2.new(0, 5, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        btn.Text = i .. ". " .. rod.name .. " (" .. rod.location .. ")"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextScaled = true
        btn.Font = Enum.Font.Gotham
        btn.BorderSizePixel = 0
        btn.Parent = RodListFrame
        btn.MouseButton1Click:Connect(function()
            SelectRod(i)
            RodStatus.Text = "🎣 ROD: " .. CurrentRodName
            RodStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
            RodListFrame.Visible = false
        end)
        y = y + 30
    end
end)

-- Status Auto Fish
local AutoFishStatus = Instance.new("TextLabel")
AutoFishStatus.Size = UDim2.new(0.6, -10, 0, 35)
AutoFishStatus.Position = UDim2.new(0, 10, 0, 270)
AutoFishStatus.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
AutoFishStatus.Text = "⚡ AUTO FISH: OFF"
AutoFishStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
AutoFishStatus.TextScaled = true
AutoFishStatus.Font = Enum.Font.GothamBold
AutoFishStatus.Parent = Frame

-- Tombol Auto Fish
local AutoFishBtn = Instance.new("TextButton")
AutoFishBtn.Size = UDim2.new(0.35, -10, 0, 35)
AutoFishBtn.Position = UDim2.new(0.65, -5, 0, 270)
AutoFishBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
AutoFishBtn.Text = "F: OFF"
AutoFishBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoFishBtn.TextScaled = true
AutoFishBtn.Font = Enum.Font.GothamBold
AutoFishBtn.BorderSizePixel = 0
AutoFishBtn.Parent = Frame
AutoFishBtn.MouseButton1Click:Connect(function()
    Settings.AutoFish = not Settings.AutoFish
    AutoFishStatus.Text = Settings.AutoFish and "⚡ AUTO FISH: ON" or "⚡ AUTO FISH: OFF"
    AutoFishStatus.TextColor3 = Settings.AutoFish and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
    AutoFishBtn.Text = Settings.AutoFish and "F: ON" or "F: OFF"
    AutoFishBtn.BackgroundColor3 = Settings.AutoFish and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
end)

-- Blatant Mode
local BlatantLabel = Instance.new("TextLabel")
BlatantLabel.Size = UDim2.new(0.6, -10, 0, 35)
BlatantLabel.Position = UDim2.new(0, 10, 0, 315)
BlatantLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
BlatantLabel.Text = "⚡ BLATANT: ON"
BlatantLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
BlatantLabel.TextScaled = true
BlatantLabel.Font = Enum.Font.GothamBold
BlatantLabel.Parent = Frame

local BlatantBtn = Instance.new("TextButton")
BlatantBtn.Size = UDim2.new(0.35, -10, 0, 35)
BlatantBtn.Position = UDim2.new(0.65, -5, 0, 315)
BlatantBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
BlatantBtn.Text = "B: ON"
BlatantBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BlatantBtn.TextScaled = true
BlatantBtn.Font = Enum.Font.GothamBold
BlatantBtn.BorderSizePixel = 0
BlatantBtn.Parent = Frame
BlatantBtn.MouseButton1Click:Connect(function()
    Settings.BlatantMode = not Settings.BlatantMode
    BlatantLabel.Text = Settings.BlatantMode and "⚡ BLATANT: ON" or "⚡ BLATANT: OFF"
    BlatantLabel.TextColor3 = Settings.BlatantMode and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(200, 200, 200)
    BlatantBtn.Text = Settings.BlatantMode and "B: ON" or "B: OFF"
    BlatantBtn.BackgroundColor3 = Settings.BlatantMode and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(100, 100, 100)
end)

-- Ikan Counter
local FishLabel = Instance.new("TextLabel")
FishLabel.Size = UDim2.new(1, -20, 0, 35)
FishLabel.Position = UDim2.new(0, 10, 0, 360)
FishLabel.BackgroundColor3 = Color3.fromRGB(0, 50, 50)
FishLabel.Text = "🐟 IKAN: 0"
FishLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
FishLabel.TextScaled = true
FishLabel.Font = Enum.Font.Gotham
FishLabel.Parent = Frame

-- Tombol Reset
local ResetBtn = Instance.new("TextButton")
ResetBtn.Size = UDim2.new(0.3, -5, 0, 30)
ResetBtn.Position = UDim2.new(0.7, -5, 0, 365)
ResetBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
ResetBtn.Text = "R"
ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetBtn.TextScaled = true
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.BorderSizePixel = 0
ResetBtn.Parent = Frame
ResetBtn.MouseButton1Click:Connect(function()
    Settings.FishCount = 0
    FishLabel.Text = "🐟 IKAN: 0"
end)

-- Update UI loop
task.spawn(function()
    while true do
        task.wait(0.3)
        FishLabel.Text = "🐟 IKAN: " .. Settings.FishCount
    end
end)

-- ========== [6. KEYBINDS] ==========
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if input.KeyCode == Enum.KeyCode.F then
        Settings.AutoFish = not Settings.AutoFish
        AutoFishStatus.Text = Settings.AutoFish and "⚡ AUTO FISH: ON" or "⚡ AUTO FISH: OFF"
        AutoFishStatus.TextColor3 = Settings.AutoFish and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
        AutoFishBtn.Text = Settings.AutoFish and "F: ON" or "F: OFF"
        AutoFishBtn.BackgroundColor3 = Settings.AutoFish and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
    end
    
    if input.KeyCode == Enum.KeyCode.B then
        Settings.BlatantMode = not Settings.BlatantMode
        BlatantLabel.Text = Settings.BlatantMode and "⚡ BLATANT: ON" or "⚡ BLATANT: OFF"
        BlatantLabel.TextColor3 = Settings.BlatantMode and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(200, 200, 200)
        BlatantBtn.Text = Settings.BlatantMode and "B: ON" or "B: OFF"
        BlatantBtn.BackgroundColor3 = Settings.BlatantMode and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(100, 100, 100)
    end
    
    if input.KeyCode == Enum.KeyCode.R then
        Settings.FishCount = 0
        FishLabel.Text = "🐟 IKAN: 0"
    end
    
    if input.KeyCode == Enum.KeyCode.U then
        local found = RefreshRod()
        if found then
            RodStatus.Text = "🎣 ROD: " .. CurrentRodName
            RodStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            RodStatus.Text = "🎣 ROD: TIDAK DITEMUKAN"
            RodStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
    end
end)

-- ========== [7. TELEPORT SEDERHANA] ==========
local TeleportSpots = {
    [Enum.KeyCode.One] = CFrame.new(0, 10, 0),
    [Enum.KeyCode.Two] = CFrame.new(50, 10, 50),
    [Enum.KeyCode.Three] = CFrame.new(200, 30, -150),
}

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    local cf = TeleportSpots[input.KeyCode]
    if cf and Player.Character and Player.Character.HumanoidRootPart then
        Player.Character.HumanoidRootPart.CFrame = cf
    end
end)

-- ========== [8. NOTIFIKASI] ==========
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🔥 RIOTESTTING - DIAGNOSTIK",
    Text = "Cek console (F9) untuk debug rod!",
    Duration = 5
})

print("========== RIOTESTTING READY ==========")
print("✅ UI sudah muncul, cek rod di layar.")
print("🎣 Jika rod tidak terdeteksi, tekan REFRESH atau pilih manual.")
print("📢 LAPORKAN KE SAYA: Apakah rod muncul di console? Ada CastEvent?")
