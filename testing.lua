-- AUTO FISH SCRIPT WITH 429 ERROR HANDLING
local Player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Tunggu PlayerGui
local playerGui = Player:WaitForChild("PlayerGui", 10)
if not playerGui then
    warn("❌ PlayerGui tidak ditemukan!")
    return
end

-- Event dengan cache
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

-- Inisialisasi event
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

-- CEK APAKAH EVENT TERSEDIA
for name, event in pairs(Events) do
    if not event then
        warn("⚠️ Event " .. name .. " tidak ditemukan! Mungkin game berbeda?")
    else
        print("✅ Event " .. name .. " ditemukan")
    end
end

-- ============================================
-- SAFE INVOKE FUNCTION (ANTI 429)
-- ============================================
local function safeInvoke(event, ...)
    if not event then return nil end
    
    local maxRetry = 10
    local baseDelay = 5
    local args = {...}
    
    for attempt = 1, maxRetry do
        local success, result = pcall(function()
            return event:InvokeServer(unpack(args))
        end)
        
        if success then
            return result
        else
            local errorMsg = tostring(result)
            print("⚠️ Attempt " .. attempt .. " failed: " .. errorMsg)
            
            -- Deteksi error 429
            if string.find(errorMsg, "429") or string.find(errorMsg, "Too Many Requests") then
                local waitTime = baseDelay * (2 ^ (attempt - 1)) -- Exponential: 5, 10, 20, 40...
                print("🕒 Server sibuk (429), tunggu " .. waitTime .. " detik...")
                wait(waitTime)
            elseif string.find(errorMsg, "500") or string.find(errorMsg, "Timeout") then
                wait(10) -- Server error, tunggu 10 detik
            else
                wait(2) -- Error lain, tunggu 2 detik
            end
        end
    end
    
    print("❌ Gagal setelah " .. maxRetry .. " percobaan")
    return nil
end

-- FireServer tidak perlu retry sebanyak InvokeServer
local function safeFire(event, ...)
    if not event then return end
    
    pcall(function()
        event:FireServer(...)
    end)
end

-- ============================================
-- VARIABEL KONTROL
-- ============================================
local autoFishing = false
local autoBuy = false
local autoSell = false
local fishCount = 0
local startTime = tick()
local serverBusy = false

-- ============================================
-- FUNGSI FISHING DENGAN SAFE INVOKE
-- ============================================
local function equipRod()
    safeFire(Events.EquipTool, 1)
end

local function chargeRod()
    safeInvoke(Events.ChargeRod)
end

local function startMinigame()
    local args = {-0.5, 0.4, tick() * 1000}
    safeInvoke(Events.RequestMinigame, unpack(args))
end

local function catchFishNow()
    local success = safeInvoke(Events.CatchComplete)
    if success then
        fishCount = fishCount + 1
    end
    return success
end

local function sellAll()
    if autoSell then
        safeInvoke(Events.SellAll)
    end
end

local function buyBoosts()
    if autoBuy then
        safeInvoke(Events.Purchase, 5) -- Luck
        wait(1)
        safeInvoke(Events.Purchase, 7) -- Shiny
    end
end

-- ============================================
-- CREATE UI SEDERHANA (TIDAK ERROR)
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFishGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.Size = UDim2.new(0, 300, 0, 200)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "🎣 AUTO FISH (429 PROTECTED)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 16

-- Status server
local ServerStatus = Instance.new("TextLabel")
ServerStatus.Parent = MainFrame
ServerStatus.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ServerStatus.Position = UDim2.new(0, 10, 0, 40)
ServerStatus.Size = UDim2.new(1, -20, 0, 25)
ServerStatus.Text = "🟢 Server: Normal"
ServerStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
ServerStatus.Font = Enum.Font.SourceSans
ServerStatus.TextSize = 14

-- Tombol Start/Stop
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent = MainFrame
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
ToggleBtn.Position = UDim2.new(0, 10, 0, 75)
ToggleBtn.Size = UDim2.new(0, 135, 0, 35)
ToggleBtn.Text = "🚀 START AUTO"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 16

-- Tombol Auto Buy
local BuyBtn = Instance.new("TextButton")
BuyBtn.Parent = MainFrame
BuyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
BuyBtn.Position = UDim2.new(0, 155, 0, 75)
BuyBtn.Size = UDim2.new(0, 135, 0, 35)
BuyBtn.Text = "🛒 AUTO BUY: OFF"
BuyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BuyBtn.Font = Enum.Font.SourceSans
BuyBtn.TextSize = 14

-- Tombol Auto Sell
local SellBtn = Instance.new("TextButton")
SellBtn.Parent = MainFrame
SellBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
SellBtn.Position = UDim2.new(0, 10, 0, 120)
SellBtn.Size = UDim2.new(0, 135, 0, 35)
SellBtn.Text = "💰 AUTO SELL: OFF"
SellBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SellBtn.Font = Enum.Font.SourceSans
SellBtn.TextSize = 14

-- Tombol Manual Sell
local ManualSellBtn = Instance.new("TextButton")
ManualSellBtn.Parent = MainFrame
ManualSellBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
ManualSellBtn.Position = UDim2.new(0, 155, 0, 120)
ManualSellBtn.Size = UDim2.new(0, 135, 0, 35)
ManualSellBtn.Text = "💰 JUAL SEMUA"
ManualSellBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ManualSellBtn.Font = Enum.Font.SourceSans
ManualSellBtn.TextSize = 14

-- Status & Counter
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
StatusLabel.Position = UDim2.new(0, 10, 0, 165)
StatusLabel.Size = UDim2.new(1, -20, 0, 25)
StatusLabel.Text = "🐟 Ikan: 0 | Status: Idle"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.TextSize = 14

-- ============================================
-- MONITOR SERVER STATUS
-- ============================================
spawn(function()
    while true do
        wait(10)
        -- Cek server dengan ping ringan
        local success = pcall(function()
            Events.ChargeRod:InvokeServer()
        end)
        
        if not success then
            serverBusy = true
            ServerStatus.Text = "🔴 Server: Sibuk (Rate Limit)"
            ServerStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
        else
            serverBusy = false
            ServerStatus.Text = "🟢 Server: Normal"
            ServerStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
    end
end)

-- ============================================
-- FISHING LOOP DENGAN ADAPTIVE DELAY
-- ============================================
function startFishing()
    while autoFishing do
        -- Update statistik
        local elapsed = tick() - startTime
        local minutes = math.floor(elapsed / 60)
        local seconds = math.floor(elapsed % 60)
        
        -- Jika server sibuk, delay lebih lama
        local baseDelay = serverBusy and 5 or 0.5
        
        StatusLabel.Text = string.format("🐟 Ikan: %d | ⏱️ %d:%02d | Status: Fishing", 
            fishCount, minutes, seconds)
        
        equipRod()
        wait(0.2)
        
        chargeRod()
        wait(0.3)
        
        startMinigame()
        wait(serverBusy and 3 or 1) -- Tunggu lebih lama jika server sibuk
        
        local caught = catchFishNow()
        
        if caught then
            -- Auto sell setiap 3 ikan
            if fishCount % 3 == 0 and autoSell then
                sellAll()
                wait(0.5)
            end
            
            -- Auto buy setiap 6 ikan
            if fishCount % 6 == 0 and autoBuy then
                buyBoosts()
            end
        end
        
        wait(baseDelay)
    end
end

-- ============================================
-- EVENT HANDLERS
-- ============================================
ToggleBtn.MouseButton1Click:Connect(function()
    autoFishing = not autoFishing
    if autoFishing then
        ToggleBtn.Text = "⏹️ STOP AUTO"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        StatusLabel.Text = "Status: Starting..."
        startTime = tick()
        coroutine.wrap(startFishing)()
    else
        ToggleBtn.Text = "🚀 START AUTO"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        StatusLabel.Text = "Status: Stopped"
        safeInvoke(Events.Cancel, true)
    end
end)

BuyBtn.MouseButton1Click:Connect(function()
    autoBuy = not autoBuy
    BuyBtn.Text = autoBuy and "🛒 AUTO BUY: ON" or "🛒 AUTO BUY: OFF"
    BuyBtn.BackgroundColor3 = autoBuy and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(80, 80, 80)
end)

SellBtn.MouseButton1Click:Connect(function()
    autoSell = not autoSell
    SellBtn.Text = autoSell and "💰 AUTO SELL: ON" or "💰 AUTO SELL: OFF"
    SellBtn.BackgroundColor3 = autoSell and Color3.fromRGB(200, 100, 0) or Color3.fromRGB(80, 80, 80)
end)

ManualSellBtn.MouseButton1Click:Connect(function()
    StatusLabel.Text = "Status: Menjual..."
    sellAll()
    wait(1)
    StatusLabel.Text = "Status: Siap"
end)

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
Player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

print([[
╔════════════════════════════════════╗
║  AUTO FISH WITH 429 PROTECTION     ║
║  ✅ Siap digunakan                 ║
║  🛡️ Anti Rate Limit: ACTIVE        ║
║  ⏱️ Exponential Backoff: ENABLED    ║
╚════════════════════════════════════╝
]])
