-- AUTO FISH SUPER CEPAT + AUTO FARM
-- Optimasi maksimal untuk kecepatan farming

local Player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

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

-- Inisialisasi semua event dengan path yang lebih pendek (optimasi)
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
local ultraFast = true -- Mode super cepat
local fishCount = 0
local startTime = tick()

-- GUI Modern
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0, 20, 0, 20)
MainFrame.Size = UDim2.new(0, 320, 0, 280)
MainFrame.Active = true
MainFrame.Draggable = true

-- Shadow effect
local Shadow = Instance.new("ImageLabel")
Shadow.Parent = MainFrame
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0, -5, 0, -5)
Shadow.Size = UDim2.new(1, 10, 1, 10)
Shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5

-- Title bar
local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
TitleBar.Size = UDim2.new(1, 0, 0, 35)
TitleBar.BorderSizePixel = 0

local Title = Instance.new("TextLabel")
Title.Parent = TitleBar
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, -10, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "⚡ AUTO FISH SUPER CEPAT ⚡"
Title.TextColor3 = Color3.fromRGB(100, 200, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
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
    ScreenGui:Destroy()
    autoFishing = false
end)

-- Stats Frame
local StatsFrame = Instance.new("Frame")
StatsFrame.Parent = MainFrame
StatsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
StatsFrame.Position = UDim2.new(0, 10, 0, 45)
StatsFrame.Size = UDim2.new(1, -20, 0, 60)
StatsFrame.BorderSizePixel = 0

local FishCountLabel = Instance.new("TextLabel")
FishCountLabel.Parent = StatsFrame
FishCountLabel.BackgroundTransparency = 1
FishCountLabel.Position = UDim2.new(0, 10, 0, 5)
FishCountLabel.Size = UDim2.new(0.5, -5, 0, 20)
FishCountLabel.Text = "🐟 Ikan: 0"
FishCountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FishCountLabel.Font = Enum.Font.Gotham
FishCountLabel.TextSize = 14
FishCountLabel.TextXAlignment = Enum.TextXAlignment.Left

local TimeLabel = Instance.new("TextLabel")
TimeLabel.Parent = StatsFrame
TimeLabel.BackgroundTransparency = 1
TimeLabel.Position = UDim2.new(0.5, 5, 0, 5)
TimeLabel.Size = UDim2.new(0.5, -15, 0, 20)
TimeLabel.Text = "⏱️ 0:00"
TimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TimeLabel.Font = Enum.Font.Gotham
TimeLabel.TextSize = 14
TimeLabel.TextXAlignment = Enum.TextXAlignment.Right

local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Parent = StatsFrame
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Position = UDim2.new(0, 10, 0, 30)
SpeedLabel.Size = UDim2.new(1, -20, 0, 20)
SpeedLabel.Text = "⚡ Kecepatan: 0 ikan/menit"
SpeedLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextSize = 13
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Control Buttons
local function createButton(text, pos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.BackgroundColor3 = color
    btn.Position = UDim2.new(0, 10, 0, pos)
    btn.Size = UDim2.new(0, 145, 0, 40)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.BorderSizePixel = 0
    btn.MouseButton1Click:Connect(callback)
    
    -- Hover effect
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = btn.BackgroundColor3:Lerp(Color3.fromRGB(255, 255, 255), 0.2)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = color
    end)
    
    return btn
end

local ToggleBtn = createButton("🚀 MULAI AUTO", 115, Color3.fromRGB(0, 150, 0), function()
    autoFishing = not autoFishing
    if autoFishing then
        ToggleBtn.Text = "⏹️ BERHENTI"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        Status.Text = "Status: FARMING ⚡"
        Status.TextColor3 = Color3.fromRGB(0, 255, 0)
        coroutine.wrap(startUltraFastFishing)()
    else
        ToggleBtn.Text = "🚀 MULAI AUTO"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        Status.Text = "Status: Berhenti"
        Status.TextColor3 = Color3.fromRGB(255, 255, 0)
        if Events.Cancel then
            Events.Cancel:InvokeServer(true)
        end
    end
end)

local AutoBuyBtn = createButton("🛒 AUTO BUY: OFF", 165, Color3.fromRGB(80, 80, 80), function()
    autoBuy = not autoBuy
    AutoBuyBtn.Text = autoBuy and "🛒 AUTO BUY: ON" or "🛒 AUTO BUY: OFF"
    AutoBuyBtn.BackgroundColor3 = autoBuy and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(80, 80, 80)
end)

local AutoSellBtn = createButton("💰 AUTO SELL: OFF", 215, Color3.fromRGB(80, 80, 80), function()
    autoSell = not autoSell
    AutoSellBtn.Text = autoSell and "💰 AUTO SELL: ON" or "💰 AUTO SELL: OFF"
    AutoSellBtn.BackgroundColor3 = autoSell and Color3.fromRGB(200, 100, 0) or Color3.fromRGB(80, 80, 80)
end)

-- Status Bar
local Status = Instance.new("TextLabel")
Status.Parent = MainFrame
Status.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Status.Position = UDim2.new(0, 10, 0, 265)
Status.Size = UDim2.new(1, -20, 0, 30)
Status.Text = "Status: Siap ⚡"
Status.TextColor3 = Color3.fromRGB(255, 255, 0)
Status.Font = Enum.Font.Gotham
Status.TextSize = 14
Status.BorderSizePixel = 0

-- Quick Actions
local QuickFrame = Instance.new("Frame")
QuickFrame.Parent = MainFrame
QuickFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
QuickFrame.Position = UDim2.new(0, 165, 0, 115)
QuickFrame.Size = UDim2.new(0, 145, 0, 90)
QuickFrame.BorderSizePixel = 0

local QuickTitle = Instance.new("TextLabel")
QuickTitle.Parent = QuickFrame
QuickTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
QuickTitle.Size = UDim2.new(1, 0, 0, 20)
QuickTitle.Text = "⚡ QUICK ACTIONS"
QuickTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
QuickTitle.Font = Enum.Font.GothamBold
QuickTitle.TextSize = 11

local function createQuickButton(text, pos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = QuickFrame
    btn.BackgroundColor3 = color
    btn.Position = UDim2.new(0, 5, 0, pos)
    btn.Size = UDim2.new(0, 135, 0, 20)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.MouseButton1Click:Connect(callback)
    return btn
end

createQuickButton("JUAL SEMUA", 25, Color3.fromRGB(255, 140, 0), function()
    if Events.SellAll then
        Events.SellAll:InvokeServer()
        Status.Text = "Status: Menjual semua..."
    end
end)

createQuickButton("BELI LUCK", 50, Color3.fromRGB(0, 100, 200), function()
    if Events.Purchase then
        Events.Purchase:InvokeServer(5)
        Status.Text = "Status: Membeli luck boost"
    end
end)

createQuickButton("BELI SHINY", 75, Color3.fromRGB(200, 0, 200), function()
    if Events.Purchase then
        Events.Purchase:InvokeServer(7)
        Status.Text = "Status: Membeli shiny boost"
    end
end)

createQuickButton("BATAL", 100, Color3.fromRGB(200, 0, 0), function()
    if Events.Cancel then
        Events.Cancel:InvokeServer(true)
        Status.Text = "Status: Dibatalkan"
    end
end)

-- FUNGSI FISHING SUPER CEPAT
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
            -- Parameter fishing (bisa disesuaikan)
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
        FishCountLabel.Text = "🐟 Ikan: " .. fishCount
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

-- FISHING LOOP SUPER CEPAT
function startUltraFastFishing()
    while autoFishing do
        -- Hitung kecepatan
        local elapsed = tick() - startTime
        local rate = math.floor((fishCount / elapsed) * 60)
        SpeedLabel.Text = "⚡ Kecepatan: " .. rate .. " ikan/menit"
        
        -- Update waktu
        local minutes = math.floor(elapsed / 60)
        local seconds = math.floor(elapsed % 60)
        TimeLabel.Text = string.format("⏱️ %d:%02d", minutes, seconds)
        
        -- Step 1: Equip rod
        equipRod()
        Status.Text = "Status: Equip rod..."
        wait(0.05) -- Delay minimal
        
        -- Step 2: Charge
        chargeRod()
        Status.Text = "Status: Ngecharge..."
        wait(0.05)
        
        -- Step 3: Start minigame
        startMinigame()
        Status.Text = "Status: Mancing..."
        wait(0.1) -- Tunggu sebentar
        
        -- Step 4: Catch fish (langsung catch)
        catchFishNow()
        Status.Text = "Status: Dapet ikan! 🐟"
        
        -- Step 5: Auto sell setiap 5 ikan
        if fishCount % 5 == 0 and autoSell then
            sellAll()
            Status.Text = "Status: Jual ikan..."
        end
        
        -- Step 6: Auto buy setiap 10 ikan
        if fishCount % 10 == 0 and autoBuy then
            buyBoosts()
            Status.Text = "Status: Beli boost..."
        end
        
        -- Delay antar fishing (bisa diatur)
        wait(0.1)
    end
end

-- Auto reconnect event jika terjadi error
local function setupEventMonitoring()
    spawn(function()
        while true do
            wait(5)
            -- Refresh event jika hilang
            for i, event in pairs(Events) do
                if not event or not event.Parent then
                    Events = {
                        EquipTool = getNetEvent(basePath .. "/RE/EquipToolFromHotbar"),
                        SellAll = getNetEvent(basePath .. "/RF/SellAllItems"),
                        ChargeRod = getNetEvent(basePath .. "/RF/ChargeFishingRod"),
                        RequestMinigame = getNetEvent(basePath .. "/RF/RequestFishingMinigameStarted"),
                        CatchComplete = getNetEvent(basePath .. "/RF/CatchFishCompleted"),
                        Purchase = getNetEvent(basePath .. "/RF/PurchaseMarketItem"),
                        Cancel = getNetEvent(basePath .. "/RF/CancelFishingInputs")
                    }
                    break
                end
            end
        end
    end)
end

setupEventMonitoring()

-- Notifikasi startup
print([[ 
╔══════════════════════════════════╗
║   AUTO FISH SUPER CEPAT LOADED   ║
║   Kecepatan: ⚡⚡⚡⚡⚡              ║
║   Siap farming!                   ║
╚══════════════════════════════════╝
]])

-- Tambahkan fitur anti-afk
local VirtualUser = game:GetService("VirtualUser")
Player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)
