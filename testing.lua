--[[
    🔥 RIOTESTTING - FISH IT! DIAGNOSTIK FIX
    ✅ ERROR "MouseButton1Click is not a valid member of TextLabel" FIXED
    ✅ DETEKSI ROD LEBIH AGRESIF
    ✅ UI SEMUA PAKAI TEXTBUTTON
    ✅ TAMPILKAN INSTRUKSI JIKA ROD TIDAK ADA
]]

-- ========== [1. INISIALISASI] ==========
repeat task.wait() until game:IsLoaded()

local Player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

-- ========== [2. DEBUG CONSOLE] ==========
print("========== RIOTESTTING DIAGNOSTIK FIX ==========")
print("🔍 Mencari tool dengan CastEvent...")

-- ========== [3. DETEKSI ROD SUPER AGRESIF] ==========
local function FindAnyCastEvent()
    local results = {}
    
    -- CEK CHARACTER (TANGAN) - SEMUA TOOL
    if Player.Character then
        for _, item in ipairs(Player.Character:GetChildren()) do
            if item:IsA("Tool") then
                local cast = item:FindFirstChild("CastEvent") or 
                            item:FindFirstChild("Cast") or 
                            item:FindFirstChild("Fish") or
                            item:FindFirstChildWhichIsA("RemoteEvent")
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
            local cast = item:FindFirstChild("CastEvent") or 
                        item:FindFirstChild("Cast") or 
                        item:FindFirstChild("Fish") or
                        item:FindFirstChildWhichIsA("RemoteEvent")
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
    
    -- CEK SEMUA DESCENDANTS PLAYER (FALLBACK)
    for _, item in ipairs(Player:GetDescendants()) do
        if item:IsA("Tool") and not table.find(results, item) then
            local cast = item:FindFirstChild("CastEvent") or 
                        item:FindFirstChild("Cast") or 
                        item:FindFirstChild("Fish") or
                        item:FindFirstChildWhichIsA("RemoteEvent")
            if cast then
                table.insert(results, {
                    item = item,
                    cast = cast,
                    location = "Lainnya",
                    name = item.Name
                })
            end
        end
    end
    
    return results
end

local detectedRods = FindAnyCastEvent()
print("🎣 Ditemukan " .. #detectedRods .. " tool dengan CastEvent/RemoteEvent:")
for i, rod in ipairs(detectedRods) do
    print("   " .. i .. ". " .. rod.name .. " (" .. rod.location .. ")")
end

-- Pilih rod pertama jika ada
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
    print("   ➤ Pastikan kamu sudah MEMBELI dan MEMEGANG Fishing Rod.")
    print("   ➤ Jika sudah, coba EQUIP rod ke tangan.")
    print("   ➤ Nama rod yang umum: Starter Rod, Luck Rod, Carbon Rod, dll.")
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

-- ========== [5. UI FIX - SEMUA TEXTBUTTON] ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RioTestting_Fix"
ScreenGui.Parent = Player.PlayerGui or game:GetService("CoreGui")

-- Frame utama
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 380, 0, 500)
Frame.Position = UDim2.new(0.5, -190, 0.5, -250)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(255, 50, 50)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

-- Judul
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
Title.Text = "🔥 RIOTESTTING - DIAGNOSTIK FIX"
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.Parent = Frame

-- Status Rod
local RodStatus = Instance.new("TextLabel")
RodStatus.Size = UDim2.new(1, -20, 0, 45)
RodStatus.Position = UDim2.new(0, 10, 0, 50)
RodStatus.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
RodStatus.BackgroundTransparency = 0.5
RodStatus.Text = "🎣 ROD: " .. CurrentRodName
RodStatus.TextColor3 = CastEvent and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
RodStatus.TextScaled = true
RodStatus.Font = Enum.Font.Gotham
RodStatus.Parent = Frame

-- Tombol Refresh Rod (TEXTBUTTON)
local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0.45, -10, 0, 40)
RefreshBtn.Position = UDim2.new(0, 10, 0, 105)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
RefreshBtn.Text = "🔄 REFRESH ROD (U)"
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

-- Tombol Pilih Rod Manual (TEXTBUTTON)
local SelectRodBtn = Instance.new("TextButton")
SelectRodBtn.Size = UDim2.new(0.45, -10, 0, 40)
SelectRodBtn.Position = UDim2.new(0.55, -5, 0, 105)
SelectRodBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
SelectRodBtn.Text = "📋 PILIH ROD"
SelectRodBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectRodBtn.TextScaled = true
SelectRodBtn.Font = Enum.Font.GothamBold
SelectRodBtn.BorderSizePixel = 0
SelectRodBtn.Parent = Frame

-- Frame untuk daftar rod (muncul saat tombol Pilih diklik)
local RodListFrame = Instance.new("Frame")
RodListFrame.Size = UDim2.new(1, -20, 0, 150)
RodListFrame.Position = UDim2.new(0, 10, 0, 155)
RodListFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
RodListFrame.BorderSizePixel = 1
RodListFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
RodListFrame.Visible = false
RodListFrame.Parent = Frame

SelectRodBtn.MouseButton1Click:Connect(function()
    RodListFrame.Visible = not RodListFrame.Visible
    -- Bersihkan isi lama
    for _, v in ipairs(RodListFrame:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    -- Isi dengan daftar rod terkini
    local y = 5
    for i, rod in ipairs(detectedRods) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 30)
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
        y = y + 35
    end
end)

-- INSTRUKSI JIKA TIDAK ADA ROD
local WarningLabel = Instance.new("TextLabel")
WarningLabel.Size = UDim2.new(1, -20, 0, 40)
WarningLabel.Position = UDim2.new(0, 10, 0, 210)
WarningLabel.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
WarningLabel.BackgroundTransparency = 0.3
WarningLabel.Text = "⚠️ TIDAK ADA ROD TERDETEKSI! ⚠️\nBeli rod di shop, lalu equip!"
WarningLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
WarningLabel.TextScaled = true
WarningLabel.Font = Enum.Font.GothamBold
WarningLabel.Visible = (#detectedRods == 0)
WarningLabel.Parent = Frame

-- Auto Fish Status
local AutoFishStatus = Instance.new("TextLabel")
AutoFishStatus.Size = UDim2.new(0.6, -10, 0, 40)
AutoFishStatus.Position = UDim2.new(0, 10, 0, 260)
AutoFishStatus.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
AutoFishStatus.Text = "⚡ AUTO FISH: OFF"
AutoFishStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
AutoFishStatus.TextScaled = true
AutoFishStatus.Font = Enum.Font.GothamBold
AutoFishStatus.Parent = Frame

-- Tombol Auto Fish (TEXTBUTTON)
local AutoFishBtn = Instance.new("TextButton")
AutoFishBtn.Size = UDim2.new(0.35, -10, 0, 40)
AutoFishBtn.Position = UDim2.new(0.65, -5, 0, 260)
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
BlatantLabel.Size = UDim2.new(0.6, -10, 0, 40)
BlatantLabel.Position = UDim2.new(0, 10, 0, 310)
BlatantLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
BlatantLabel.Text = "⚡ BLATANT: ON"
BlatantLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
BlatantLabel.TextScaled = true
BlatantLabel.Font = Enum.Font.GothamBold
BlatantLabel.Parent = Frame

-- Tombol Blatant (TEXTBUTTON)
local BlatantBtn = Instance.new("TextButton")
BlatantBtn.Size = UDim2.new(0.35, -10, 0, 40)
BlatantBtn.Position = UDim2.new(0.65, -5, 0, 310)
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
FishLabel.Size = UDim2.new(0.7, -10, 0, 40)
FishLabel.Position = UDim2.new(0, 10, 0, 360)
FishLabel.BackgroundColor3 = Color3.fromRGB(0, 50, 50)
FishLabel.Text = "🐟 IKAN: 0"
FishLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
FishLabel.TextScaled = true
FishLabel.Font = Enum.Font.Gotham
FishLabel.Parent = Frame

-- Tombol Reset (TEXTBUTTON)
local ResetBtn = Instance.new("TextButton")
ResetBtn.Size = UDim2.new(0.25, -10, 0, 40)
ResetBtn.Position = UDim2.new(0.75, -5, 0, 360)
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

-- Credit
local CreditLabel = Instance.new("TextLabel")
CreditLabel.Size = UDim2.new(1, -20, 0, 25)
CreditLabel.Position = UDim2.new(0, 10, 0, 415)
CreditLabel.BackgroundTransparency = 1
CreditLabel.Text = "🔥 RioTestting | F:Auto U:Rod B:Blatant R:Reset"
CreditLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
CreditLabel.TextScaled = true
CreditLabel.Font = Enum.Font.GothamLight
CreditLabel.Parent = Frame

-- Update UI loop
task.spawn(function()
    while true do
        task.wait(0.3)
        FishLabel.Text = "🐟 IKAN: " .. Settings.FishCount
        -- Update peringatan rod
        WarningLabel.Visible = (#detectedRods == 0)
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
    [Enum.KeyCode.Four] = CFrame.new(-100, 20, 300),
    [Enum.KeyCode.Five] = CFrame.new(400, 50, 400),
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
    Title = "🔥 RIOTESTTING - FIX",
    Text = "Error MouseButton1Click diperbaiki!",
    Duration = 5
})

print("========== RIOTESTTING FIX READY ==========")
print("✅ Error 'MouseButton1Click' sudah diperbaiki.")
print("🎣 Jika rod tidak terdeteksi, beli dan equip rod dulu!")
print("🔄 Tekan U atau tombol REFRESH untuk cek ulang.")
print("📢 LAPORAN: Apakah sekarang rod terdeteksi?")
