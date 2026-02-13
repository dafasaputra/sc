--[[
    🔥 RIOTESTTING - FISH IT! AUTO FISH (UNIVERSAL)
    ✅ TIDAK ADA ERROR FONT (GothamLight diperbaiki)
    ✅ DETEKSI ROD SUPER AGRESIF - cari semua tool + remote
    ✅ MANUAL SELECT - pilih rod langsung dari daftar
    ✅ AUTO FISH - work dengan remote APA PUN
    ✅ TANPA ASUMSI NAMA REMOTE
]]

-- ========== [1. INISIALISASI] ==========
repeat task.wait() until game:IsLoaded()

local Player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

-- ========== [2. KONFIGURASI] ==========
local Settings = {
    AutoFish = false,
    FishCount = 0,
    BlatantMode = true,
}

-- ========== [3. DETEKSI ROD UNIVERSAL] ==========
local CurrentTool = nil
local CurrentRemote = nil
local CurrentToolName = "Tidak Ada"
local AllTools = {}  -- Semua tool yang ditemukan

local function FindAllTools()
    local tools = {}
    
    -- 1. Character (tangan)
    if Player.Character then
        for _, item in ipairs(Player.Character:GetChildren()) do
            if item:IsA("Tool") then
                table.insert(tools, {item = item, location = "Tangan"})
            end
        end
    end
    
    -- 2. Backpack
    for _, item in ipairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            table.insert(tools, {item = item, location = "Tas"})
        end
    end
    
    -- 3. StarterPack (jika ada)
    local starterPack = game:GetService("StarterPack")
    for _, item in ipairs(starterPack:GetChildren()) do
        if item:IsA("Tool") then
            table.insert(tools, {item = item, location = "StarterPack"})
        end
    end
    
    return tools
end

-- Cari remote APAPUN di dalam tool
local function FindAnyRemote(tool)
    -- Cari RemoteEvent, RemoteFunction, BindableEvent, dll
    local remote = tool:FindFirstChildWhichIsA("RemoteEvent") or
                   tool:FindFirstChildWhichIsA("RemoteFunction") or
                   tool:FindFirstChildWhichIsA("BindableEvent") or
                   tool:FindFirstChild("CastEvent") or
                   tool:FindFirstChild("Cast") or
                   tool:FindFirstChild("Fish")
    return remote
end

-- Update daftar tool dan pilih yang pertama
local function RefreshTools()
    AllTools = FindAllTools()
    
    -- Reset pilihan
    CurrentTool = nil
    CurrentRemote = nil
    CurrentToolName = "Tidak Ada"
    
    -- Cari tool pertama yang punya remote
    for _, t in ipairs(AllTools) do
        local remote = FindAnyRemote(t.item)
        if remote then
            CurrentTool = t.item
            CurrentRemote = remote
            CurrentToolName = t.item.Name .. " (" .. t.location .. ")"
            break
        end
    end
    
    return #AllTools, CurrentTool ~= nil
end

-- Pilih tool secara manual
local function SelectTool(index)
    if index >= 1 and index <= #AllTools then
        local t = AllTools[index]
        CurrentTool = t.item
        CurrentRemote = FindAnyRemote(t.item)  -- Bisa nil
        CurrentToolName = t.item.Name .. " (" .. t.location .. ")"
        return CurrentRemote ~= nil
    end
    return false
end

-- Initial refresh
RefreshTools()

-- ========== [4. AUTO FISH FUNCTION] ==========
local function FishCycle()
    if not CurrentTool then return false end
    
    -- Prioritaskan remote
    if CurrentRemote then
        -- RemoteEvent: FireServer
        if CurrentRemote:IsA("RemoteEvent") then
            pcall(function()
                CurrentRemote:FireServer()
                if Settings.BlatantMode then task.wait(0.01) else task.wait(0.3) end
                CurrentRemote:FireServer()
            end)
        -- RemoteFunction: InvokeServer
        elseif CurrentRemote:IsA("RemoteFunction") then
            pcall(function()
                CurrentRemote:InvokeServer()
                if Settings.BlatantMode then task.wait(0.01) else task.wait(0.3) end
                CurrentRemote:InvokeServer()
            end)
        -- BindableEvent: Fire
        elseif CurrentRemote:IsA("BindableEvent") then
            pcall(function()
                CurrentRemote:Fire()
                if Settings.BlatantMode then task.wait(0.01) else task.wait(0.3) end
                CurrentRemote:Fire()
            end)
        end
    else
        -- Fallback: Activate tool (klik kiri)
        pcall(function()
            CurrentTool:Activate()
            if Settings.BlatantMode then task.wait(0.01) else task.wait(0.3) end
            CurrentTool:Activate()
        end)
    end
    
    Settings.FishCount = Settings.FishCount + 1
    return true
end

-- Loop Auto Fish
task.spawn(function()
    while true do
        if Settings.AutoFish and CurrentTool then
            pcall(FishCycle)
            task.wait(Settings.BlatantMode and 0.01 or 0.5)
        else
            task.wait(0.2)
        end
    end
end)

-- ========== [5. UI MODERN - TANPA ERROR FONT] ==========
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RioTestting_Universal"
ScreenGui.Parent = Player.PlayerGui or game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

-- Frame utama
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 400, 0, 480)
Frame.Position = UDim2.new(0.5, -200, 0.5, -240)
Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(255, 50, 50)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
Header.BorderSizePixel = 0
Header.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🔥 RIOTESTTING - UNIVERSAL"
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack  -- ← FONT AMAN
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

-- Tombol Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold  -- ← FONT AMAN
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Header
CloseBtn.MouseButton1Click:Connect(function()
    Frame.Visible = false
end)

-- Status Rod
local RodFrame = Instance.new("Frame")
RodFrame.Size = UDim2.new(1, -20, 0, 60)
RodFrame.Position = UDim2.new(0, 10, 0, 50)
RodFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
RodFrame.BorderSizePixel = 0
RodFrame.Parent = Frame

local RodIcon = Instance.new("TextLabel")
RodIcon.Size = UDim2.new(0, 40, 1, 0)
RodIcon.Position = UDim2.new(0, 5, 0, 0)
RodIcon.BackgroundTransparency = 1
RodIcon.Text = "🎣"
RodIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
RodIcon.TextScaled = true
RodIcon.Font = Enum.Font.Gotham  -- ← FONT AMAN
RodIcon.Parent = RodFrame

local RodStatus = Instance.new("TextLabel")
RodStatus.Size = UDim2.new(1, -50, 1, 0)
RodStatus.Position = UDim2.new(0, 45, 0, 0)
RodStatus.BackgroundTransparency = 1
RodStatus.Text = "ROD: " .. CurrentToolName
RodStatus.TextColor3 = CurrentRemote and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
RodStatus.TextScaled = true
RodStatus.Font = Enum.Font.Gotham  -- ← FONT AMAN
RodStatus.TextXAlignment = Enum.TextXAlignment.Left
RodStatus.Parent = RodFrame

-- Tombol Refresh
local RefreshBtn = Instance.new("TextButton")
RefreshBtn.Size = UDim2.new(0.45, -5, 0, 35)
RefreshBtn.Position = UDim2.new(0, 10, 0, 120)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
RefreshBtn.Text = "🔄 REFRESH ROD (U)"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.TextScaled = true
RefreshBtn.Font = Enum.Font.GothamBold  -- ← FONT AMAN
RefreshBtn.BorderSizePixel = 0
RefreshBtn.Parent = Frame
RefreshBtn.MouseButton1Click:Connect(function()
    local total, found = RefreshTools()
    if found then
        RodStatus.Text = "ROD: " .. CurrentToolName
        RodStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        RodStatus.Text = "ROD: TIDAK ADA (PILIH MANUAL)"
        RodStatus.TextColor3 = Color3.fromRGB(255, 200, 0)
    end
end)

-- Tombol Pilih Manual
local SelectBtn = Instance.new("TextButton")
SelectBtn.Size = UDim2.new(0.45, -5, 0, 35)
SelectBtn.Position = UDim2.new(0.55, 0, 0, 120)
SelectBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 50)
SelectBtn.Text = "📋 PILIH ROD"
SelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectBtn.TextScaled = true
SelectBtn.Font = Enum.Font.GothamBold  -- ← FONT AMAN
SelectBtn.BorderSizePixel = 0
SelectBtn.Parent = Frame

-- Daftar Tool
local ToolListFrame = Instance.new("Frame")
ToolListFrame.Size = UDim2.new(1, -20, 0, 150)
ToolListFrame.Position = UDim2.new(0, 10, 0, 165)
ToolListFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
ToolListFrame.BorderSizePixel = 1
ToolListFrame.BorderColor3 = Color3.fromRGB(100, 100, 100)
ToolListFrame.Visible = false
ToolListFrame.Parent = Frame

SelectBtn.MouseButton1Click:Connect(function()
    ToolListFrame.Visible = not ToolListFrame.Visible
    -- Bersihkan isi lama
    for _, v in ipairs(ToolListFrame:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    -- Isi daftar tool
    local y = 5
    for i, t in ipairs(AllTools) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 30)
        btn.Position = UDim2.new(0, 5, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        btn.Text = i .. ". " .. t.item.Name .. " (" .. t.location .. ")"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextScaled = true
        btn.Font = Enum.Font.Gotham  -- ← FONT AMAN
        btn.BorderSizePixel = 0
        btn.Parent = ToolListFrame
        btn.MouseButton1Click:Connect(function()
            local success = SelectTool(i)
            if success then
                RodStatus.Text = "ROD: " .. CurrentToolName .. " (REMOTE ✅)"
                RodStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
            else
                RodStatus.Text = "ROD: " .. CurrentToolName .. " (NO REMOTE)"
                RodStatus.TextColor3 = Color3.fromRGB(255, 255, 0)
            end
            ToolListFrame.Visible = false
        end)
        y = y + 35
    end
end)

-- Status Auto Fish
local AutoFishFrame = Instance.new("Frame")
AutoFishFrame.Size = UDim2.new(1, -20, 0, 50)
AutoFishFrame.Position = UDim2.new(0, 10, 0, 325)
AutoFishFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
AutoFishFrame.BorderSizePixel = 0
AutoFishFrame.Parent = Frame

local AutoFishStatus = Instance.new("TextLabel")
AutoFishStatus.Size = UDim2.new(0.6, -5, 1, 0)
AutoFishStatus.Position = UDim2.new(0, 10, 0, 0)
AutoFishStatus.BackgroundTransparency = 1
AutoFishStatus.Text = "⚡ AUTO FISH: OFF"
AutoFishStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
AutoFishStatus.TextScaled = true
AutoFishStatus.Font = Enum.Font.GothamBold  -- ← FONT AMAN
AutoFishStatus.TextXAlignment = Enum.TextXAlignment.Left
AutoFishStatus.Parent = AutoFishFrame

local AutoFishBtn = Instance.new("TextButton")
AutoFishBtn.Size = UDim2.new(0.35, -5, 0, 35)
AutoFishBtn.Position = UDim2.new(0.65, -5, 0, 7.5)
AutoFishBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
AutoFishBtn.Text = "F: OFF"
AutoFishBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AutoFishBtn.TextScaled = true
AutoFishBtn.Font = Enum.Font.GothamBold  -- ← FONT AMAN
AutoFishBtn.BorderSizePixel = 0
AutoFishBtn.Parent = AutoFishFrame
AutoFishBtn.MouseButton1Click:Connect(function()
    Settings.AutoFish = not Settings.AutoFish
    AutoFishStatus.Text = Settings.AutoFish and "⚡ AUTO FISH: ON" or "⚡ AUTO FISH: OFF"
    AutoFishStatus.TextColor3 = Settings.AutoFish and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 100, 100)
    AutoFishBtn.Text = Settings.AutoFish and "F: ON" or "F: OFF"
    AutoFishBtn.BackgroundColor3 = Settings.AutoFish and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 50, 50)
end)

-- Blatant Mode
local BlatantFrame = Instance.new("Frame")
BlatantFrame.Size = UDim2.new(1, -20, 0, 50)
BlatantFrame.Position = UDim2.new(0, 10, 0, 385)
BlatantFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
BlatantFrame.BorderSizePixel = 0
BlatantFrame.Parent = Frame

local BlatantStatus = Instance.new("TextLabel")
BlatantStatus.Size = UDim2.new(0.6, -5, 1, 0)
BlatantStatus.Position = UDim2.new(0, 10, 0, 0)
BlatantStatus.BackgroundTransparency = 1
BlatantStatus.Text = "⚡ BLATANT: ON"
BlatantStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
BlatantStatus.TextScaled = true
BlatantStatus.Font = Enum.Font.GothamBold  -- ← FONT AMAN
BlatantStatus.TextXAlignment = Enum.TextXAlignment.Left
BlatantStatus.Parent = BlatantFrame

local BlatantBtn = Instance.new("TextButton")
BlatantBtn.Size = UDim2.new(0.35, -5, 0, 35)
BlatantBtn.Position = UDim2.new(0.65, -5, 0, 7.5)
BlatantBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
BlatantBtn.Text = "B: ON"
BlatantBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BlatantBtn.TextScaled = true
BlatantBtn.Font = Enum.Font.GothamBold  -- ← FONT AMAN
BlatantBtn.BorderSizePixel = 0
BlatantBtn.Parent = BlatantFrame
BlatantBtn.MouseButton1Click:Connect(function()
    Settings.BlatantMode = not Settings.BlatantMode
    BlatantStatus.Text = Settings.BlatantMode and "⚡ BLATANT: ON" or "⚡ BLATANT: OFF"
    BlatantStatus.TextColor3 = Settings.BlatantMode and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(200, 200, 200)
    BlatantBtn.Text = Settings.BlatantMode and "B: ON" or "B: OFF"
    BlatantBtn.BackgroundColor3 = Settings.BlatantMode and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(100, 100, 100)
end)

-- Ikan Counter
local FishFrame = Instance.new("Frame")
FishFrame.Size = UDim2.new(1, -20, 0, 50)
FishFrame.Position = UDim2.new(0, 10, 0, 445)
FishFrame.BackgroundColor3 = Color3.fromRGB(0, 30, 30)
FishFrame.BorderSizePixel = 0
FishFrame.Parent = Frame

local FishLabel = Instance.new("TextLabel")
FishLabel.Size = UDim2.new(0.7, -5, 1, 0)
FishLabel.Position = UDim2.new(0, 10, 0, 0)
FishLabel.BackgroundTransparency = 1
FishLabel.Text = "🐟 IKAN: 0"
FishLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
FishLabel.TextScaled = true
FishLabel.Font = Enum.Font.Gotham  -- ← FONT AMAN
FishLabel.TextXAlignment = Enum.TextXAlignment.Left
FishLabel.Parent = FishFrame

local ResetBtn = Instance.new("TextButton")
ResetBtn.Size = UDim2.new(0.25, -5, 0, 35)
ResetBtn.Position = UDim2.new(0.75, -5, 0, 7.5)
ResetBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
ResetBtn.Text = "R"
ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetBtn.TextScaled = true
ResetBtn.Font = Enum.Font.GothamBold  -- ← FONT AMAN
ResetBtn.BorderSizePixel = 0
ResetBtn.Parent = FishFrame
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
        BlatantStatus.Text = Settings.BlatantMode and "⚡ BLATANT: ON" or "⚡ BLATANT: OFF"
        BlatantStatus.TextColor3 = Settings.BlatantMode and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(200, 200, 200)
        BlatantBtn.Text = Settings.BlatantMode and "B: ON" or "B: OFF"
        BlatantBtn.BackgroundColor3 = Settings.BlatantMode and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(100, 100, 100)
    end
    
    if input.KeyCode == Enum.KeyCode.R then
        Settings.FishCount = 0
        FishLabel.Text = "🐟 IKAN: 0"
    end
    
    if input.KeyCode == Enum.KeyCode.U then
        local total, found = RefreshTools()
        if found then
            RodStatus.Text = "ROD: " .. CurrentToolName
            RodStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            RodStatus.Text = "ROD: TIDAK ADA (PILIH MANUAL)"
            RodStatus.TextColor3 = Color3.fromRGB(255, 200, 0)
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

-- ========== [8. NOTIFIKASI AWAL] ==========
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "🔥 RIOTESTTING - UNIVERSAL",
    Text = "Error font diperbaiki! Tekan U untuk refresh rod.",
    Duration = 5
})

print("========== RIOTESTTING UNIVERSAL ==========")
print("✅ Semua error font sudah diperbaiki!")
print("🎣 Tool ditemukan: " .. #AllTools)
print("✅ Gunakan 'PILIH ROD' untuk memilih tool manual.")
print("🔥 Blatant mode siap (toggle B/F).")
print("============================================")
