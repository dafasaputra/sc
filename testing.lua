-- Script untuk Game Fish It (Roblox) dengan Library Sirius
-- Versi Stabil - Fix error callback

-- Load library Sirius dengan penanganan error
local SiriusLoaded, Sirius = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/sirius-lua/sirius/main/sirius.lua"))()
end)

if not SiriusLoaded then
    -- Fallback jika Sirius gagal load
    local library = loadstring(game:HttpGet('https://pastebin.com/raw/xyz123'))() -- Ganti dengan link cadangan
    Sirius = library
end

local ui = Sirius.new()

-- Variables dengan pengecekan nil
local player = game:GetService("Players").LocalPlayer
local character = player.Character or player.CharacterAdded:Wait(5)
local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

-- Network utilities dengan pengecekan aman
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = ReplicatedStorage:FindFirstChild("Packages") and 
           ReplicatedStorage.Packages:FindFirstChild("_Index") and 
           ReplicatedStorage.Packages._Index:FindFirstChild("sleitnick_net@0.2.0") and 
           ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"]:FindFirstChild("net")

-- Remote references dengan pengecekan
local RemoteEvents = {}
if Net then
    RemoteEvents = {
        EquipRod = Net:FindFirstChild("RE/EquipToolFromHotbar"),
        SellAll = Net:FindFirstChild("RF/SellAllItems"),
        ChargeFishing = Net:FindFirstChild("RF/ChargeFishingRod"),
        RequestMinigame = Net:FindFirstChild("RF/RequestFishingMinigameStarted"),
        CatchFish = Net:FindFirstChild("RF/CatchFishCompleted"),
        PurchaseItem = Net:FindFirstChild("RF/PurchaseMarketItem"),
        CancelFishing = Net:FindFirstChild("RF/CancelFishingInputs")
    }
end

-- Status toggle
local settings = {
    autoFishing = false,
    instantCatch = false,
    autoSell = false,
    autoBuyLuck = false,
    autoBuyShiny = false,
    autoEquipRod = false
}

-- Coroutine handles untuk menghentikan loop
local loops = {
    autoFishing = nil,
    autoSell = nil,
    autoBuyLuck = nil,
    autoBuyShiny = nil
}

-- Create main window dengan error handling
local mainWindow = ui:Window({
    Title = "Fish It Script",
    SubTitle = "by OxyX - Stable",
    Size = UDim2.new(0, 500, 0, 400)
})

-- Auto Fishing Tab
local fishingTab = mainWindow:Tab("Auto Fishing")
local fishingSection = fishingTab:Section("Main Settings")

-- Perbaikan: Gunakan function terpisah untuk callback
fishingSection:Toggle({
    Text = "Auto Fishing",
    Flag = "auto_fish",
    Default = false,
    Callback = function(value)
        local success, err = pcall(function()
            settings.autoFishing = value
            if value then
                startAutoFishing()
            else
                stopLoop("autoFishing")
            end
        end)
        if not success then
            warn("Error in Auto Fishing callback:", err)
        end
    end
})

fishingSection:Toggle({
    Text = "Instant Catch",
    Flag = "instant_catch",
    Default = true,
    Callback = function(value)
        local success, err = pcall(function()
            settings.instantCatch = value
        end)
        if not success then
            warn("Error in Instant Catch callback:", err)
        end
    end
})

fishingSection:Button({
    Text = "Charge Rod",
    Callback = function()
        pcall(function()
            chargeFishingRod()
        end)
    end
})

fishingSection:Button({
    Text = "Cancel Fishing",
    Callback = function()
        pcall(function()
            cancelFishing()
        end)
    end
})

-- Auto Sell Tab
local sellTab = mainWindow:Tab("Auto Sell")
local sellSection = sellTab:Section("Sell Settings")

sellSection:Toggle({
    Text = "Auto Sell",
    Flag = "auto_sell",
    Default = false,
    Callback = function(value)
        pcall(function()
            settings.autoSell = value
            if value then
                startAutoSell()
            else
                stopLoop("autoSell")
            end
        end)
    end
})

sellSection:Button({
    Text = "Sell Now",
    Callback = function()
        pcall(function()
            sellAllItems()
        end)
    end
})

-- Auto Shop Tab
local shopTab = mainWindow:Tab("Auto Shop")
local shopSection = shopTab:Section("Market")

shopSection:Toggle({
    Text = "Auto Buy Luck",
    Flag = "auto_luck",
    Default = false,
    Callback = function(value)
        pcall(function()
            settings.autoBuyLuck = value
            if value then
                startAutoBuy(5, "autoBuyLuck")
            else
                stopLoop("autoBuyLuck")
            end
        end)
    end
})

shopSection:Toggle({
    Text = "Auto Buy Shiny",
    Flag = "auto_shiny",
    Default = false,
    Callback = function(value)
        pcall(function()
            settings.autoBuyShiny = value
            if value then
                startAutoBuy(7, "autoBuyShiny")
            else
                stopLoop("autoBuyShiny")
            end
        end)
    end
})

shopSection:Button({
    Text = "Buy Luck",
    Callback = function()
        pcall(function()
            purchaseItem(5)
        end)
    end
})

shopSection:Button({
    Text = "Buy Shiny",
    Callback = function()
        pcall(function()
            purchaseItem(7)
        end)
    end
})

-- Auto Rod Tab
local rodTab = mainWindow:Tab("Auto Rod")
local rodSection = rodTab:Section("Rod")

rodSection:Toggle({
    Text = "Auto Equip Rod",
    Flag = "auto_rod",
    Default = false,
    Callback = function(value)
        pcall(function()
            settings.autoEquipRod = value
            if value then
                startAutoEquipRod()
            else
                stopLoop("autoEquipRod")
            end
        end)
    end
})

rodSection:Button({
    Text = "Equip Rod",
    Callback = function()
        pcall(function()
            equipRod()
        end)
    end
})

-- Functions dengan error handling

function startAutoFishing()
    if loops.autoFishing then
        coroutine.close(loops.autoFishing)
        loops.autoFishing = nil
    end
    
    loops.autoFishing = coroutine.create(function()
        while settings.autoFishing do
            local success = pcall(function()
                chargeFishingRod()
                wait(1)
                
                if RemoteEvents.RequestMinigame then
                    RemoteEvents.RequestMinigame:InvokeServer(-0.57, 0.39, 1771146782.71)
                end
                
                wait(0.5)
                
                if settings.instantCatch and RemoteEvents.CatchFish then
                    RemoteEvents.CatchFish:InvokeServer()
                end
            end)
            
            if not success then
                wait(2) -- Tunggu lebih lama jika error
            end
            
            wait(1)
        end
    end)
    
    coroutine.resume(loops.autoFishing)
end

function chargeFishingRod()
    if RemoteEvents.ChargeFishing then
        RemoteEvents.ChargeFishing:InvokeServer()
    end
end

function cancelFishing()
    if RemoteEvents.CancelFishing then
        RemoteEvents.CancelFishing:InvokeServer(true)
    end
end

function equipRod()
    if RemoteEvents.EquipRod then
        RemoteEvents.EquipRod:FireServer(1)
    end
end

function sellAllItems()
    if RemoteEvents.SellAll then
        RemoteEvents.SellAll:InvokeServer()
    end
end

function purchaseItem(itemId)
    if RemoteEvents.PurchaseItem then
        RemoteEvents.PurchaseItem:InvokeServer(itemId)
    end
end

function startAutoSell()
    if loops.autoSell then
        coroutine.close(loops.autoSell)
        loops.autoSell = nil
    end
    
    loops.autoSell = coroutine.create(function()
        while settings.autoSell do
            pcall(sellAllItems)
            wait(30)
        end
    end)
    
    coroutine.resume(loops.autoSell)
end

function startAutoBuy(itemId, loopName)
    if loops[loopName] then
        coroutine.close(loops[loopName])
        loops[loopName] = nil
    end
    
    loops[loopName] = coroutine.create(function()
        while settings[loopName] do
            pcall(function() purchaseItem(itemId) end)
            wait(60)
        end
    end)
    
    coroutine.resume(loops[loopName])
end

function startAutoEquipRod()
    if loops.autoEquipRod then
        coroutine.close(loops.autoEquipRod)
        loops.autoEquipRod = nil
    end
    
    loops.autoEquipRod = coroutine.create(function()
        while settings.autoEquipRod do
            pcall(equipRod)
            wait(10)
        end
    end)
    
    coroutine.resume(loops.autoEquipRod)
end

function stopLoop(loopName)
    if loops[loopName] then
        coroutine.close(loops[loopName])
        loops[loopName] = nil
    end
end

-- Bersihkan semua loop saat script berhenti
game:GetService("RunService"):Stepped():Connect(function()
    -- Validasi koneksi jika perlu
end)

-- Initialize UI dengan aman
pcall(function()
    ui:Init()
end)

-- Notifikasi
pcall(function()
    Sirius:Notify({
        Title = "Script Loaded",
        Content = "Stable version loaded!",
        Duration = 2
    })
end)
