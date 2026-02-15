-- AUTO FISH SUPER CEPAT (FIXED VERSION)
-- Dengan error handling untuk menghindari "attempt to index nil"

local Player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- TUNGGU PlayerGui SIAP
local playerGui = Player:WaitForChild("PlayerGui", 10)
if not playerGui then
    warn("PlayerGui tidak ditemukan!")
    return
end

-- Fungsi untuk mendapatkan event dengan cache
local EventCache = {}
local function getNetEvent(path)
    if EventCache[path] then
        return EventCache[path]
    end
    
    local parts = string.split(path, "/")
    local current = ReplicatedStorage
    
    for i, part in parts do
        current = current:FindFirstChild(part)
        if not current then
            current = ReplicatedStorage:WaitForChild(part, 5)
        end
        if not current then break end
    end
    
    if current then
        EventCache[path] = current
    end
    return current
end

-- Inisialisasi semua event
local basePath = "Packages/_Index/sleitnick_net@0.2.0/net"
local Events = {
    EquipTool = getNetEvent(basePath .. "/RE/EquipToolFromHotbar"),
    SellAll = getNetEvent(basePath .. "/RF/SellAllItems"),
    ChargeRod = getNetEvent(basePath .. "/RF/ChargeFishingRod"),
    RequestMinigame = getNetEvent(basePath .. "/RF/RequestFishingMinigameStarted"),
    CatchComplete = getNetEvent(basePath .. "/RF/CatchFishCompleted"),
    Purchase = getNetEvent(basePath .. "/RF/PurchaseMarketItem"),
    Cancel = getNetEvent(basePath .. "/RF/CancelFishingInputs")
}

-- Variabel kontrol
local autoFishing = false
local autoBuy = false
local autoSell = false
local fishCount = 0
local startTime = tick()

-- ============================================
-- CREATE UI DENGAN ERROR HANDLING
-- ============================================
local success, ScreenGui = pcall(function()
    local gui = Instance.new("ScreenGui")
    gui.Name = "AutoFishGUI"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui
    return gui
end)

if not success or not ScreenGui then
    warn("Gagal membuat ScreenGui!")
    return
end

-- ============================================
-- MAIN FRAME
-- ============================================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.Size = UDim2.new(0, 320, 0, 280)
MainFrame.Active = true
MainFrame.Draggable = true

-- Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Parent = MainFrame
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0, -5, 0, -5)
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5

-- ============================================
-- TITLE BAR
-- ============================================
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BorderSizePixel = 0

-- TITLE (LINE 179 - SEBELUMNYA ERROR)
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Parent = TitleBar
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -10, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)

-- CEK APAKAH TITLE BERHASIL DIBUAT
if Title then
    Title.Text = "⚡ AUTO FISH SUPER CEPAT ⚡"  -- LINE 179 (FIXED)
    Title.TextColor3 = Color3.fromRGB(100, 200, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
else
    warn("Title TextLabel gagal dibuat!")
end

-- CLOSE BUTTON
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = TitleBar
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Size = UDim2.new(0, 30, 0, 25)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.BorderSizePixel = 0
CloseBtn.MouseButton1Click:Connect(function()
    if ScreenGui then
        ScreenGui:Destroy()
    end
    autoFishing = false
end)

-- ============================================
-- STATS FRAME
-- ============================================
local StatsFrame = Instance.new("Frame")
StatsFrame.Name = "StatsFrame"
StatsFrame.Parent = MainFrame
StatsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
StatsFrame.Position = UDim2.new(0, 10, 0, 45)
StatsFrame.Size = UDim2.new(1, -20, 0, 60)
StatsFrame.BorderSizePixel = 0

-- FISH COUNT LABEL (LINE 185 - SEBELUMNYA ERROR)
local FishCountLabel = Instance.new("TextLabel")
FishCountLabel.Name = "FishCountLabel"
FishCountLabel.Parent = StatsFrame
FishCountLabel.BackgroundTransparency = 1
FishCountLabel.Position = UDim2.new(0, 10, 0, 5)
FishCountLabel.Size = UDim2.new(0.5, -5, 0, 20)

-- CEK APAKAH FISHCOUNTLABEL BERHASIL DIBUAT
if FishCountLabel then
    FishCountLabel.Text = "🐟 Ikan: 0"  -- LINE 185 (FIXED)
    FishCountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    FishCountLabel.Font = Enum.Font.Gotham
    FishCountLabel.TextSize = 14
    FishCountLabel.TextXAlignment = Enum.TextXAlignment.Left
else
    warn("FishCountLabel gagal dibuat!")
end

-- TIME LABEL
local TimeLabel = Instance.new("TextLabel")
TimeLabel.Name = "TimeLabel"
TimeLabel.Parent = StatsFrame
TimeLabel.BackgroundTransparency = 1
TimeLabel.Position = UDim2.new(0.5, 5, 0, 5)
TimeLabel.Size = UDim2.new(0.5, -15, 0, 20)
if TimeLabel then
    TimeLabel.Text = "⏱️ 0:00"
    TimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TimeLabel.Font = Enum.Font.Gotham
    TimeLabel.TextSize = 14
    TimeLabel.TextXAlignment = Enum.TextXAlignment.Right
end

-- SPEED LABEL
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Name = "SpeedLabel"
SpeedLabel.Parent = StatsFrame
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Position = UDim2.new(0, 10, 0, 30)
SpeedLabel.Size = UDim2.new(1, -20, 0, 20)
if SpeedLabel then
    SpeedLabel.Text = "⚡ Kecepatan: 0 ikan/menit"
    SpeedLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    SpeedLabel.Font = Enum.Font.Gotham
    SpeedLabel.TextSize = 13
    SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
end

-- ============================================
-- CONTROL BUTTONS
-- ============================================
local function createButton(text, pos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Name = "Button_" .. text:gsub("%s+", "")
    btn.Parent = MainFrame
    btn.BackgroundColor3 = color
    btn.Position = UDim2.new(0, 10, 0, pos)
    btn.Size = UDim2.new(0, 145, 0, 40)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    
    if btn then
        btn.MouseButton1Click:Connect(callback)
        
        -- Hover effect
        btn.MouseEnter:Connect(function()
            if btn then
                btn.BackgroundColor3 = btn.BackgroundColor3:Lerp(Color3.fromRGB(255, 255, 255), 0.2)
            end
        end)
        btn.MouseLeave:Connect(function()
            if btn then
                btn.BackgroundColor3 = color
            end
        end)
    end
    
    return btn
end

local ToggleBtn = createButton("🚀 MULAI AUTO", 115, Color3.fromRGB(0, 150, 0), function()
    autoFishing = not autoFishing
    if ToggleBtn then
        if autoFishing then
            ToggleBtn.Text = "⏹️ BERHENTI"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
            if Status then
                Status.Text = "Status: FARMING ⚡"
                Status.TextColor3 = Color3.fromRGB(0, 255, 0)
            end
            coroutine.wrap(startUltraFastFishing)()
        else
            ToggleBtn.Text = "🚀 MULAI AUTO"
            ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
            if Status then
                Status.Text = "Status: Berhenti"
                Status.TextColor3 = Color3.fromRGB(255, 255, 0)
            end
            if Events.Cancel then
                pcall(function()
                    Events.Cancel:InvokeServer(true)
                end)
            end
        end
    end
end)

local AutoBuyBtn = createButton("🛒 AUTO BUY: OFF", 165, Color3.fromRGB(80, 80, 80), function()
    autoBuy = not autoBuy
    if AutoBuyBtn then
        AutoBuyBtn.Text = autoBuy and "🛒 AUTO BUY: ON" or "🛒 AUTO BUY: OFF"
        AutoBuyBtn.BackgroundColor3 = autoBuy and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(80, 80, 80)
    end
end)

local AutoSellBtn = createButton("💰 AUTO SELL: OFF", 215, Color3.fromRGB(80, 80, 80), function()
    autoSell = not autoSell
    if AutoSellBtn then
        AutoSellBtn.Text = autoSell and "💰 AUTO SELL: ON" or "💰 AUTO SELL: OFF"
        AutoSellBtn.BackgroundColor3 = autoSell and Color3.fromRGB(200, 100, 0) or Color3.fromRGB(80, 80, 80)
    end
end)

-- ============================================
-- STATUS BAR
-- ============================================
local Status = Instance.new("TextLabel")
Status.Name = "Status"
Status.Parent = MainFrame
Status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Status.Position = UDim2.new(0, 10, 0, 265)
Status.Size = UDim2.new(1, -20, 0, 30)
if Status then
    Status.Text = "Status: Siap ⚡"
    Status.TextColor3 = Color3.fromRGB(255, 255, 0)
    Status.Font = Enum.Font.Gotham
    Status.TextSize = 14
    Status.BorderSizePixel = 0
end

-- ============================================
-- QUICK ACTIONS
-- ============================================
local QuickFrame = Instance.new("Frame")
QuickFrame.Name = "QuickFrame"
QuickFrame.Parent = MainFrame
QuickFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
QuickFrame.Position = UDim2.new(0, 165, 0, 115)
QuickFrame.Size = UDim2.new(0, 145, 0, 90)
QuickFrame.BorderSizePixel = 0

local QuickTitle = Instance.new("TextLabel")
QuickTitle.Name = "QuickTitle"
QuickTitle.Parent = QuickFrame
QuickTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
QuickTitle.Size = UDim2.new(1, 0, 0, 20)
if QuickTitle then
    QuickTitle.Text = "⚡ QUICK ACTIONS"
    QuickTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
    QuickTitle.Font = Enum.Font.GothamBold
    QuickTitle.TextSize = 11
end

local function createQuickButton(text, pos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Name = "QuickBtn_" .. text:gsub("%s+", "")
    btn.Parent = QuickFrame
    btn.BackgroundColor3 = color
    btn.Position = UDim2.new(0, 5, 0, pos)
    btn.Size = UDim2.new(0, 135, 0, 20)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    
    if btn then
        btn.MouseButton1Click:Connect(function()
            pcall(callback)
        end)
    end
    
    return btn
end

createQuickButton("JUAL SEMUA", 25, Color3.fromRGB(255, 140, 0), function()
    if Events.SellAll then
        pcall(function()
            Events.SellAll:InvokeServer()
        end)
        if Status then
            Status.Text = "Status: Menjual semua..."
        end
    end
end)

createQuickButton("BELI LUCK", 50, Color3.fromRGB(0, 100, 200), function()
    if Events.Purchase then
        pcall(function()
            Events.Purchase:InvokeServer(5)
        end)
        if Status then
            Status.Text = "Status: Membeli luck boost"
        end
    end
end)

createQuickButton("BELI SHINY", 75, Color3.fromRGB(200, 0, 200), function()
    if Events.Purchase then
        pcall(function()
            Events.Purchase:InvokeServer(7)
        end)
        if Status then
            Status.Text = "Status: Membeli shiny boost"
        end
    end
end)

createQuickButton("BATAL", 100, Color3.fromRGB(200, 0, 0), function()
    if Events.Cancel then
        pcall(function()
            Events.Cancel:InvokeServer(true)
        end)
        if Status then
            Status.Text = "Status: Dibatalkan"
        end
    end
end)

-- ============================================
-- FUNGSI FISHING
-- ============================================
local function equipRod()
    if Events.EquipTool then
        pcall(function()
            Events.EquipTool:FireServer(1)
        end)
    end
end

local function chargeRod()
    if Events.ChargeRod then
        pcall(function()
            Events.ChargeRod:InvokeServer()
        end)
    end
end

local function startMinigame()
    if Events.RequestMinigame then
        pcall(function()
            local args = {-0.5, 0.4, tick() * 1000}
            Events.RequestMinigame:InvokeServer(unpack(args))
        end)
    end
end

local function catchFishNow()
    if Events.CatchComplete then
        pcall(function()
            Events.CatchComplete:InvokeServer()
        end)
        fishCount = fishCount + 1
        if FishCountLabel then
            FishCountLabel.Text = "🐟 Ikan: " .. fishCount
        end
    end
end

local function sellAll()
    if Events.SellAll and autoSell then
        pcall(function()
            Events.SellAll:InvokeServer()
        end)
    end
end

local function buyBoosts()
    if Events.Purchase and autoBuy then
        pcall(function()
            Events.Purchase:InvokeServer(5) -- Luck
            wait(0.05)
            Events.Purchase:InvokeServer(7) -- Shiny
        end)
    end
end

-- FISHING LOOP
function startUltraFastFishing()
    while autoFishing do
        -- Hitung kecepatan
        local elapsed = tick() - startTime
        local rate = elapsed > 0 and math.floor((fishCount / elapsed) * 60) or 0
        if SpeedLabel then
            SpeedLabel.Text = "⚡ Kecepatan: " .. rate .. " ikan/menit"
        end
        
        -- Update waktu
        local minutes = math.floor(elapsed / 60)
        local seconds = math.floor(elapsed % 60)
        if TimeLabel then
            TimeLabel.Text = string.format("⏱️ %d:%02d", minutes, seconds)
        end
        
        -- Fishing steps
        equipRod()
        if Status then Status.Text = "Status: Equip rod..." end
        wait(0.05)
        
        chargeRod()
        if Status then Status.Text = "Status: Ngecharge..." end
        wait(0.05)
        
        startMinigame()
        if Status then Status.Text = "Status: Mancing..." end
        wait(0.1)
        
        catchFishNow()
        if Status then Status.Text = "Status: Dapet ikan! 🐟" end
        
        -- Auto sell setiap 5 ikan
        if fishCount % 5 == 0 and autoSell then
            sellAll()
            if Status then Status.Text = "Status: Jual ikan..." end
        end
        
        -- Auto buy setiap 10 ikan
        if fishCount % 10 == 0 and autoBuy then
            buyBoosts()
            if Status then Status.Text = "Status: Beli boost..." end
        end
        
        wait(0.1)
    end
end

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
Player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

print("✅ AUTO FISH SCRIPT LOADED - FIXED VERSION")
print("📊 UI dibuat dengan error handling")
