-- ============================================
-- AUTO FISH UNTUK GAME "FISH IT"
-- Menggunakan remote persis dari file EVENT.docx
-- Dilengkapi penanganan error 429 (server sibuk)
-- ============================================

local Player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playerGui = Player:WaitForChild("PlayerGui")

-- ============================================
-- FUNGSI MENDAPATKAN REMOTE (PERSIS PATH)
-- ============================================
local function getRemote(path)
    local success, remote = pcall(function()
        local parts = string.split(path, "/")
        local current = ReplicatedStorage
        for i, part in ipairs(parts) do
            current = current:WaitForChild(part, 3) -- tunggu max 3 detik
        end
        return current
    end)
    return success and remote or nil
end

-- Daftar remote dari file EVENT.docx
local remotes = {
    EquipRod = {
        path = "Packages/_Index/sleitnick_net@0.2.0/net/RE/EquipToolFromHotbar",
        type = "RemoteEvent",
        args = {1}
    },
    SellAll = {
        path = "Packages/_Index/sleitnick_net@0.2.0/net/RF/SellAllItems",
        type = "RemoteFunction",
        args = {}
    },
    ChargeRod = {
        path = "Packages/_Index/sleitnick_net@0.2.0/net/RF/ChargeFishingRod",
        type = "RemoteFunction",
        args = {}
    },
    RequestMinigame = {
        path = "Packages/_Index/sleitnick_net@0.2.0/net/RF/RequestFishingMinigameStarted",
        type = "RemoteFunction",
        args = {-0.5718742609024048, 0.397660581382669, 1771146782.714026}
    },
    CatchFish = {
        path = "Packages/_Index/sleitnick_net@0.2.0/net/RF/CatchFishCompleted",
        type = "RemoteFunction",
        args = {}
    },
    BuyLuck = {
        path = "Packages/_Index/sleitnick_net@0.2.0/net/RF/PurchaseMarketItem",
        type = "RemoteFunction",
        args = {5}
    },
    BuyShiny = {
        path = "Packages/_Index/sleitnick_net@0.2.0/net/RF/PurchaseMarketItem",
        type = "RemoteFunction",
        args = {7}
    },
    CancelFishing = {
        path = "Packages/_Index/sleitnick_net@0.2.0/net/RF/CancelFishingInputs",
        type = "RemoteFunction",
        args = {true}
    }
}

-- Cek ketersediaan remote dan simpan yang ditemukan
local availableRemotes = {}
for name, data in pairs(remotes) do
    local remote = getRemote(data.path)
    if remote then
        availableRemotes[name] = {
            remote = remote,
            type = data.type,
            args = data.args
        }
        print("✅ " .. name .. " ditemukan")
    else
        print("❌ " .. name .. " TIDAK ditemukan")
    end
end

-- ============================================
-- FUNGSI PANGGIL REMOTE DENGAN HANDLING 429
-- ============================================
local function callRemote(name, ...)
    local data = availableRemotes[name]
    if not data then
        return nil, "Remote tidak tersedia"
    end
    
    local remote = data.remote
    local args = data.args
    if select('#', ...) > 0 then
        args = {...} -- jika ada argumen override
    end
    
    local maxRetry = 10
    local baseDelay = 5
    local attempt = 1
    
    while attempt <= maxRetry do
        local success, result = pcall(function()
            if data.type == "RemoteEvent" then
                remote:FireServer(unpack(args))
                return true
            else
                return remote:InvokeServer(unpack(args))
            end
        end)
        
        if success then
            return result, nil
        else
            local errMsg = tostring(result)
            -- Deteksi error 429
            if string.find(errMsg, "429") or string.find(errMsg, "Too Many Requests") then
                local waitTime = baseDelay * (2 ^ (attempt - 1))
                print("⚠️ [429] Server sibuk, percobaan ke-" .. attempt .. ", tunggu " .. waitTime .. " detik")
                wait(waitTime)
            else
                -- Error lain, tunggu sebentar lalu coba lagi
                print("⚠️ Error lain: " .. errMsg .. ", coba lagi...")
                wait(2)
            end
            attempt = attempt + 1
        end
    end
    
    return nil, "Gagal setelah " .. maxRetry .. " percobaan"
end

-- ============================================
-- UI INFORMATIF
-- ============================================
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = playerGui
screenGui.Name = "FishItAuto"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Parent = screenGui
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BorderSizePixel = 0
frame.Position = UDim2.new(0, 20, 0, 20)
frame.Size = UDim2.new(0, 320, 0, 280)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel")
title.Parent = frame
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🎣 AUTO FISH (EVENT.docx)"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local statusServer = Instance.new("TextLabel")
statusServer.Parent = frame
statusServer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
statusServer.Position = UDim2.new(0, 10, 0, 40)
statusServer.Size = UDim2.new(1, -20, 0, 25)
statusServer.Text = "🟡 Status Server: Memeriksa..."
statusServer.TextColor3 = Color3.fromRGB(255, 255, 0)
statusServer.Font = Enum.Font.Gotham
statusServer.TextSize = 13

local statusRemote = Instance.new("TextLabel")
statusRemote.Parent = frame
statusRemote.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
statusRemote.Position = UDim2.new(0, 10, 0, 70)
statusRemote.Size = UDim2.new(1, -20, 0, 25)
statusRemote.Text = "📡 Remote: " .. table.count(availableRemotes) .. "/" .. table.count(remotes) .. " tersedia"
statusRemote.TextColor3 = #availableRemotes > 0 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
statusRemote.Font = Enum.Font.Gotham
statusRemote.TextSize = 13

local statusFishing = Instance.new("TextLabel")
statusFishing.Parent = frame
statusFishing.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
statusFishing.Position = UDim2.new(0, 10, 0, 100)
statusFishing.Size = UDim2.new(1, -20, 0, 30)
statusFishing.Text = "Status: Siap"
statusFishing.TextColor3 = Color3.fromRGB(255, 255, 0)
statusFishing.Font = Enum.Font.GothamBold
statusFishing.TextSize = 14

local countLabel = Instance.new("TextLabel")
countLabel.Parent = frame
countLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
countLabel.Position = UDim2.new(0, 10, 0, 135)
countLabel.Size = UDim2.new(1, -20, 0, 25)
countLabel.Text = "🐟 Ikan: 0"
countLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
countLabel.Font = Enum.Font.Gotham
countLabel.TextSize = 14

-- Tombol kontrol
local toggleBtn = Instance.new("TextButton")
toggleBtn.Parent = frame
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
toggleBtn.Position = UDim2.new(0, 10, 0, 170)
toggleBtn.Size = UDim2.new(0, 140, 0, 35)
toggleBtn.Text = "🚀 MULAI AUTO"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14

local sellBtn = Instance.new("TextButton")
sellBtn.Parent = frame
sellBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
sellBtn.Position = UDim2.new(0, 160, 0, 170)
sellBtn.Size = UDim2.new(0, 140, 0, 35)
sellBtn.Text = "💰 JUAL SEMUA"
sellBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
sellBtn.Font = Enum.Font.Gotham
sellBtn.TextSize = 14

-- Tombol toggle auto sell/buy (opsional)
local autoSellBtn = Instance.new("TextButton")
autoSellBtn.Parent = frame
autoSellBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
autoSellBtn.Position = UDim2.new(0, 10, 0, 215)
autoSellBtn.Size = UDim2.new(0, 140, 0, 30)
autoSellBtn.Text = "🔄 AUTO SELL: OFF"
autoSellBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoSellBtn.Font = Enum.Font.Gotham
autoSellBtn.TextSize = 12

local autoBuyBtn = Instance.new("TextButton")
autoBuyBtn.Parent = frame
autoBuyBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
autoBuyBtn.Position = UDim2.new(0, 160, 0, 215)
autoBuyBtn.Size = UDim2.new(0, 140, 0, 30)
autoBuyBtn.Text = "🛒 AUTO BUY: OFF"
autoBuyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoBuyBtn.Font = Enum.Font.Gotham
autoBuyBtn.TextSize = 12

-- Variabel kontrol
local autoFishing = false
local autoSell = false
local autoBuy = false
local fishCount = 0

-- Fungsi update status server secara berkala
spawn(function()
    while true do
        -- Coba panggil remote ringan (misal ChargeRod) untuk cek server
        local _, err = callRemote("ChargeRod")
        if err and string.find(err, "429") then
            statusServer.Text = "🔴 Server SIBUK (429)"
            statusServer.TextColor3 = Color3.fromRGB(255, 0, 0)
        elseif not availableRemotes.ChargeRod then
            statusServer.Text = "⚫ Remote tidak ada"
            statusServer.TextColor3 = Color3.fromRGB(128, 128, 128)
        else
            statusServer.Text = "🟢 Server Normal"
            statusServer.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
        wait(10)
    end
end)

-- Fungsi auto fishing loop
local function autoFishingLoop()
    while autoFishing do
        -- Equip rod
        statusFishing.Text = "Status: Equip rod..."
        local _, err = callRemote("EquipRod")
        if err then
            statusFishing.Text = "Error equip: " .. err
            wait(2)
            goto continue
        end
        wait(0.2)
        
        -- Charge rod
        statusFishing.Text = "Status: Charge..."
        local _, err2 = callRemote("ChargeRod")
        if err2 then
            statusFishing.Text = "Error charge: " .. err2
            wait(2)
            goto continue
        end
        wait(0.3)
        
        -- Request minigame
        statusFishing.Text = "Status: Request minigame..."
        local _, err3 = callRemote("RequestMinigame")
        if err3 then
            statusFishing.Text = "Error request: " .. err3
            wait(2)
            goto continue
        end
        wait(1)
        
        -- Catch fish
        statusFishing.Text = "Status: Menangkap ikan..."
        local result, err4 = callRemote("CatchFish")
        if err4 then
            statusFishing.Text = "Error catch: " .. err4
            wait(2)
            goto continue
        end
        
        -- Jika sukses, tambah counter
        fishCount = fishCount + 1
        countLabel.Text = "🐟 Ikan: " .. fishCount
        statusFishing.Text = "✅ Dapat ikan! Total: " .. fishCount
        wait(0.3)
        
        -- Auto sell setiap 5 ikan
        if autoSell and fishCount % 5 == 0 then
            statusFishing.Text = "Menjual semua..."
            callRemote("SellAll")
            wait(0.5)
        end
        
        -- Auto buy setiap 10 ikan
        if autoBuy and fishCount % 10 == 0 then
            statusFishing.Text = "Membeli luck..."
            callRemote("BuyLuck")
            wait(0.3)
            statusFishing.Text = "Membeli shiny..."
            callRemote("BuyShiny")
            wait(0.3)
        end
        
        ::continue::
        wait(0.5)
    end
end

-- Event tombol
toggleBtn.MouseButton1Click:Connect(function()
    autoFishing = not autoFishing
    if autoFishing then
        toggleBtn.Text = "⏹️ BERHENTI"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        statusFishing.Text = "Status: Memulai..."
        spawn(autoFishingLoop)
    else
        toggleBtn.Text = "🚀 MULAI AUTO"
        toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        statusFishing.Text = "Status: Berhenti"
        callRemote("CancelFishing") -- batalkan jika sedang fishing
    end
end)

sellBtn.MouseButton1Click:Connect(function()
    statusFishing.Text = "Menjual semua..."
    callRemote("SellAll")
    wait(1)
    statusFishing.Text = "Selesai jual"
end)

autoSellBtn.MouseButton1Click:Connect(function()
    autoSell = not autoSell
    autoSellBtn.Text = autoSell and "🔄 AUTO SELL: ON" or "🔄 AUTO SELL: OFF"
    autoSellBtn.BackgroundColor3 = autoSell and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(80, 80, 80)
end)

autoBuyBtn.MouseButton1Click:Connect(function()
    autoBuy = not autoBuy
    autoBuyBtn.Text = autoBuy and "🛒 AUTO BUY: ON" or "🛒 AUTO BUY: OFF"
    autoBuyBtn.BackgroundColor3 = autoBuy and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(80, 80, 80)
end)

-- Info awal
print([[
╔════════════════════════════════════╗
║  AUTO FISH (EVENT.docx) LOADED     ║
║  Remote tersedia: #table.count(availableRemotes)          ║
║  Jika remote tidak ada, periksa game║
╚════════════════════════════════════╝
]])
