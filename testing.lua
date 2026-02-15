-- Script untuk Game Fish It (Roblox) dengan Library Sirius
-- Menggunakan event yang sudah diidentifikasi

-- Load library Sirius
local Sirius = loadstring(game:HttpGet("https://raw.githubusercontent.com/sirius-lua/sirius/main/sirius.lua"))()
local ui = Sirius.new()

-- Variables
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Network utilities
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Net = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

-- Remote references
local RemoteEvents = {
    EquipRod = Net:WaitForChild("RE/EquipToolFromHotbar"),
    SellAll = Net:WaitForChild("RF/SellAllItems"),
    ChargeFishing = Net:WaitForChild("RF/ChargeFishingRod"),
    RequestMinigame = Net:WaitForChild("RF/RequestFishingMinigameStarted"),
    CatchFish = Net:WaitForChild("RF/CatchFishCompleted"),
    PurchaseItem = Net:WaitForChild("RF/PurchaseMarketItem"),
    CancelFishing = Net:WaitForChild("RF/CancelFishingInputs")
}

-- Status toggle
local settings = {
    autoFishing = false,
    blatant = false,
    autoSell = false,
    autoShop = false,
    autoUseRod = false,
    autoBuyLuck = false,
    autoBuyShiny = false,
    teleportEnabled = false
}

-- Create main window
local mainWindow = ui:Window({
    Title = "Fish It Script",
    SubTitle = "by OxyX",
    Size = UDim2.new(0, 500, 0, 450)
})

-- Auto Fishing Tab
local fishingTab = mainWindow:Tab("Auto Fishing")
local fishingSection = fishingTab:Section("Main Settings")

fishingSection:Toggle({
    Text = "Auto Fishing",
    Flag = "auto_fish",
    Default = false,
    Callback = function(value)
        settings.autoFishing = value
        if value then
            startAutoFishing()
        end
    end
})

fishingSection:Toggle({
    Text = "Skip Animation (Instant Catch)",
    Flag = "instant_catch",
    Default = true,
    Callback = function(value)
        settings.instantCatch = value
    end
})

fishingSection:Button({
    Text = "Charge Fishing Rod",
    Callback = function()
        chargeFishingRod()
    end
})

fishingSection:Button({
    Text = "Cancel Fishing",
    Callback = function()
        cancelFishing()
    end
})

-- Blatant Tab
local blatantTab = mainWindow:Tab("Blatant")
local blatantSection = blatantTab:Section("Blatant Features")

blatantSection:Toggle({
    Text = "Blatant Mode",
    Flag = "blatant",
    Default = false,
    Callback = function(value)
        settings.blatant = value
    end
})

blatantSection:Button({
    Text = "Instant Catch Fish",
    Callback = function()
        instantCatchFish()
    end
})

-- Teleport Tab (perlu disesuaikan dengan koordinat pulau di game)
local teleportTab = mainWindow:Tab("Teleport")
local teleportSection = teleportTab:Section("Island Teleports")

-- Ganti koordinat ini dengan posisi pulau yang sebenarnya di game
local islands = {
    {name = "Main Island", position = Vector3.new(0, 50, 0)},
    {name = "Desert Island", position = Vector3.new(500, 50, 500)},
    {name = "Snow Island", position = Vector3.new(-500, 50, -500)},
    {name = "Jungle Island", position = Vector3.new(500, 50, -500)},
    {name = "Volcano Island", position = Vector3.new(-500, 50, 500)}
}

for _, island in ipairs(islands) do
    teleportSection:Button({
        Text = "🚀 Teleport to " .. island.name,
        Callback = function()
            teleportToIsland(island.position)
        end
    })
end

-- Auto Sell Tab
local sellTab = mainWindow:Tab("Auto Sell")
local sellSection = sellTab:Section("Sell Settings")

sellSection:Toggle({
    Text = "Auto Sell All Items",
    Flag = "auto_sell",
    Default = false,
    Callback = function(value)
        settings.autoSell = value
        if value then
            startAutoSell()
        end
    end
})

sellSection:Button({
    Text = "Sell All Now",
    Callback = function()
        sellAllItems()
    end
})

-- Auto Shop Tab
local shopTab = mainWindow:Tab("Auto Shop")
local shopSection = shopTab:Section("Market Purchases")

shopSection:Toggle({
    Text = "Auto Buy Luck (ID: 5)",
    Flag = "auto_luck",
    Default = false,
    Callback = function(value)
        settings.autoBuyLuck = value
        if value then
            startAutoBuyLuck()
        end
    end
})

shopSection:Toggle({
    Text = "Auto Buy Shiny (ID: 7)",
    Flag = "auto_shiny",
    Default = false,
    Callback = function(value)
        settings.autoBuyShiny = value
        if value then
            startAutoBuyShiny()
        end
    end
})

shopSection:Button({
    Text = "Buy Luck Now (ID: 5)",
    Callback = function()
        purchaseMarketItem(5)
    end
})

shopSection:Button({
    Text = "Buy Shiny Now (ID: 7)",
    Callback = function()
        purchaseMarketItem(7)
    end
})

-- Auto Rod Tab
local rodTab = mainWindow:Tab("Auto Rod")
local rodSection = rodTab:Section("Rod Settings")

rodSection:Toggle({
    Text = "Auto Equip Rod",
    Flag = "auto_equip_rod",
    Default = false,
    Callback = function(value)
        settings.autoUseRod = value
        if value then
            equipRod()
        end
    end
})

rodSection:Button({
    Text = "Equip Rod Now (Slot 1)",
    Callback = function()
        equipRod()
    end
})

-- Functions

function startAutoFishing()
    spawn(function()
        while settings.autoFishing do
            -- Cast/charge fishing rod
            chargeFishingRod()
            wait(1)
            
            -- Request fishing minigame dengan parameter default
            local success, result = pcall(function()
                return RemoteEvents.RequestMinigame:InvokeServer(-0.57, 0.39, 1771146782.71)
            end)
            
            if success and result then
                -- Tunggu sebentar untuk minigame
                wait(0.5)
                
                -- Catch fish
                if settings.instantCatch or settings.blatant then
                    instantCatchFish()
                else
                    catchFishNormal()
                end
            end
            
            wait(0.5)
        end
    end)
end

function chargeFishingRod()
    local success, result = pcall(function()
        return RemoteEvents.ChargeFishing:InvokeServer()
    end)
    
    if success then
        Sirius:Notify({
            Title = "Fishing",
            Content = "Rod charged!",
            Duration = 1
        })
    end
end

function instantCatchFish()
    local success, result = pcall(function()
        return RemoteEvents.CatchFish:InvokeServer()
    end)
    
    if success then
        Sirius:Notify({
            Title = "Success",
            Content = "Fish caught instantly!",
            Duration = 1
        })
    end
end

function catchFishNormal()
    -- Fishing normal tanpa instant
    wait(2) -- Simulasi waktu memancing
    local success, result = pcall(function()
        return RemoteEvents.CatchFish:InvokeServer()
    end)
end

function cancelFishing()
    local args = {true}
    local success, result = pcall(function()
        return RemoteEvents.CancelFishing:InvokeServer(unpack(args))
    end)
    
    if success then
        Sirius:Notify({
            Title = "Cancelled",
            Content = "Fishing cancelled",
            Duration = 2
        })
    end
end

function equipRod()
    -- Equip rod dari hotbar slot 1
    local args = {1} -- Slot hotbar 1
    RemoteEvents.EquipRod:FireServer(unpack(args))
    
    Sirius:Notify({
        Title = "Rod",
        Content = "Rod equipped (Slot 1)",
        Duration = 2
    })
end

function sellAllItems()
    local success, result = pcall(function()
        return RemoteEvents.SellAll:InvokeServer()
    end)
    
    if success then
        Sirius:Notify({
            Title = "Sold",
            Content = "All items sold!",
            Duration = 2
        })
    end
end

function purchaseMarketItem(itemId)
    local args = {itemId}
    local success, result = pcall(function()
        return RemoteEvents.PurchaseItem:InvokeServer(unpack(args))
    end)
    
    if success then
        local itemName = (itemId == 5 and "Luck") or (itemId == 7 and "Shiny") or "Unknown"
        Sirius:Notify({
            Title = "Purchased",
            Content = itemName .. " bought successfully!",
            Duration = 2
        })
    end
end

function startAutoSell()
    spawn(function()
        while settings.autoSell do
            wait(30) -- Jual setiap 30 detik
            sellAllItems()
        end
    end)
end

function startAutoBuyLuck()
    spawn(function()
        while settings.autoBuyLuck do
            wait(60) -- Beli luck setiap 60 detik
            purchaseMarketItem(5)
        end
    end)
end

function startAutoBuyShiny()
    spawn(function()
        while settings.autoBuyShiny do
            wait(60) -- Beli shiny setiap 60 detik
            purchaseMarketItem(7)
        end
    end)
end

function teleportToIsland(position)
    if humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(position)
        
        Sirius:Notify({
            Title = "Teleported",
            Content = "You have been teleported!",
            Duration = 3
        })
    end
end

-- Auto-sell saat inventory penuh (opsional)
player:GetPropertyChangedSignal("Inventory"):Connect(function()
    if settings.autoSell then
        -- Cek inventory penuh dan auto sell
        -- Implementasi tergantung struktur inventory game
    end
end)

-- Initialize UI
ui:Init()

-- Notification
Sirius:Notify({
    Title = "Script Loaded",
    Content = "Fish It Script with valid events loaded!",
    Duration = 3
})
