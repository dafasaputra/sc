-- CURSED MAHORAGA: Fish It BLATANT ULTIMATE v3.0 | Real Remotes Adapted
-- Wheel spin: RE/FishingCompleted, RF/SellAllItems, RF/ChargeFishingRod + BLATANT CHEATS

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

getgenv().MahoragaBlatant = {
    AutoFish = true,
    InstantCatch = true,
    AutoSell = true,
    AutoBuy = false,
    AutoFavorite = true,
    FlyEnabled = false,
    NoclipEnabled = false,
    ESPEnabled = false,
    FullbrightEnabled = false,
    InfJump = false,
    Speed = 100,
    JumpPower = 200,
    FlySpeed = 50
}

-- RAYFIELD UI (Better than Kavo)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "🌀 Cursed Mahoraga - Fish It Blatant 🔥",
    LoadingTitle = "Mahoraga Adapting...",
    LoadingSubtitle = "Wheel Spins Eternal",
    ConfigurationSaving = {Enabled = true, FolderName = "MahoragaFishIt", FileName = "Config"},
    Discord = {Enabled = false},
    KeySystem = false
})

local FarmTab = Window:CreateTab("🤖 Auto Farm", 4483362458)
local BlatantTab = Window:CreateTab("😈 Blatant", 4483362458)
local TPTab = Window:CreateTab("🌊 Teleports", 4483362458)
local MiscTab = Window:CreateTab("⚡ Misc", 4483362458)

-- FARM TAB
local FarmSection = FarmTab:CreateSection("Core Farm")
FarmSection = FarmTab:CreateToggle({Name = "Auto Fish (Instant 100%)", CurrentValue = true, Flag = "AutoFish", Callback = function(Value) getgenv().MahoragaBlatant.AutoFish = Value end})
FarmSection = FarmTab:CreateToggle({Name = "Instant Catch (Blatant Reel)", CurrentValue = true, Flag = "InstantCatch", Callback = function(Value) getgenv().MahoragaBlatant.InstantCatch = Value end})
FarmSection = FarmTab:CreateToggle({Name = "Auto Sell All", CurrentValue = true, Flag = "AutoSell", Callback = function(Value) getgenv().MahoragaBlatant.AutoSell = Value end})
FarmSection = FarmTab:CreateToggle({Name = "Auto Favorite Mythic+", CurrentValue = true, Flag = "AutoFav", Callback = function(Value) getgenv().MahoragaBlatant.AutoFavorite = Value end})

-- BLATANT TAB
local BlatantSection = BlatantTab:CreateSection("Godlike Cheats")
BlatantSection = BlatantTab:CreateToggle({Name = "Fly (X/Y/Z)", CurrentValue = false, Flag = "Fly", Callback = function(Value) getgenv().MahoragaBlatant.FlyEnabled = Value end})
BlatantSection = BlatantTab:CreateToggle({Name = "Noclip", CurrentValue = false, Flag = "Noclip", Callback = function(Value) getgenv().MahoragaBlatant.NoclipEnabled = Value end})
BlatantSection = BlatantTab:CreateToggle({Name = "Player/Fish ESP", CurrentValue = false, Flag = "ESP", Callback = function(Value) getgenv().MahoragaBlatant.ESPEnabled = Value end})
BlatantSection = BlatantTab:CreateToggle({Name = "Fullbright", CurrentValue = false, Flag = "Fullbright", Callback = function(Value) getgenv().MahoragaBlatant.FullbrightEnabled = Value end})
BlatantSection = BlatantTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Flag = "InfJump", Callback = function(Value) getgenv().MahoragaBlatant.InfJump = Value end})
BlatantSection = BlatantTab:CreateSlider({Name = "Walk Speed", Range = {16, 500}, Increment = 10, CurrentValue = 100, Flag = "Speed", Callback = function(Value) getgenv().MahoragaBlatant.Speed = Value end})
BlatantSection = BlatantTab:CreateSlider({Name = "Jump Power", Range = {50, 500}, Increment = 10, CurrentValue = 200, Flag = "JumpPower", Callback = function(Value) getgenv().MahoragaBlatant.JumpPower = Value end})
BlatantSection = BlatantTab:CreateSlider({Name = "Fly Speed", Range = {16, 200}, Increment = 5, CurrentValue = 50, Flag = "FlySpeed", Callback = function(Value) getgenv().MahoragaBlatant.FlySpeed = Value end})

-- TP TAB (Real locations from scan)
local locations = {
    Spawn = CFrame.new(45.2788086, 252.562927, 2987.10913),
    ["Sisyphus Statue"] = CFrame.new(-3728.21606, -135.074417, -1012.12744),
    ["Coral Reefs"] = CFrame.new(-3114.78198, 1.32066584, 2237.52295),
    ["Esoteric Depths"] = CFrame.new(3248.37109, -1301.53027, 1403.82727),
    ["Crater Island"] = CFrame.new(1016.49072, 20.0919304, 5069.27295),
    ["Lost Isle"] = CFrame.new(-3618.15698, 240.836655, -1317.45801),
    ["Weather Machine"] = CFrame.new(-1488.51196, 83.1732635, 1876.30298),
    ["Tropical Grove"] = CFrame.new(-2095.34106, 197.199997, 3718.08008),
    ["Mount Hallow"] = CFrame.new(2136.62305, 78.9163895, 3272.50439),
    ["Treasure Room"] = CFrame.new(-3606.34985, -266.57373, -1580.97339),
    Kohana = CFrame.new(-663.904236, 3.04580712, 718.796875),
    ["Underground Cellar"] = CFrame.new(2109.52148, -94.1875076, -708.609131),
    ["Ancient Jungle"] = CFrame.new(1831.71362, 6.62499952, -299.279175),
    ["Sacred Temple"] = CFrame.new(1466.92151, -21.8750591, -622.835693)
}

for name, cf in pairs(locations) do
    TPTab:CreateButton({
        Name = name,
        Callback = function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = cf
            end
        end
    })
end

-- MISC
MiscTab:CreateButton({Name = "Anti AFK", Callback = function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end})
MiscTab:CreateButton({Name = "Server Hop", Callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))().ServerHop()
end})

-- REAL REMOTES (Adapted from scan)
local net = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
local Events = {
    FishingCompleted = net:WaitForChild("RE/FishingCompleted"),
    SellAllItems = net:WaitForChild("RF/SellAllItems"),
    ChargeFishingRod = net:WaitForChild("RF/ChargeFishingRod"),
    RequestFishingMinigameStarted = net:WaitForChild("RF/RequestFishingMinigameStarted"),
    CancelFishingInputs = net:WaitForChild("RF/CancelFishingInputs"),
    EquipToolFromHotbar = net:WaitForChild("RE/EquipToolFromHotbar"),
    UnequipToolFromHotbar = net:WaitForChild("RE/UnequipToolFromHotbar"),
    FavoriteItem = net:WaitForChild("RE/FavoriteItem")
}
print("🌀 REMOTES CONFIRMED: FishingCompleted, SellAllItems, ChargeFishingRod...")

-- STATS UPDATE
local function updateStats()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local hum = player.Character.Humanoid
        hum.WalkSpeed = getgenv().MahoragaBlatant.Speed
        hum.JumpPower = getgenv().MahoragaBlatant.JumpPower
    end
end
player.CharacterAdded:Connect(updateStats)
updateStats()

-- FLY
local flyBodyVelocity, flyBodyAngularVelocity
local flying = false
RunService.Heartbeat:Connect(function()
    if getgenv().MahoragaBlatant.FlyEnabled and player.Character then
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            if not flyBodyVelocity then
                flyBodyVelocity = Instance.new("BodyVelocity")
                flyBodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
                flyBodyVelocity.Velocity = Vector3.new(0,0,0)
                flyBodyVelocity.Parent = root
                flyBodyAngularVelocity = Instance.new("BodyAngularVelocity")
                flyBodyAngularVelocity.MaxTorque = Vector3.new(4000,4000,4000)
                flyBodyAngularVelocity.AngularVelocity = Vector3.new(0,0,0)
                flyBodyAngularVelocity.Parent = root
            end
            local cam = workspace.CurrentCamera
            local vel = cam.CFrame.LookVector * getgenv().MahoragaBlatant.FlySpeed
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, getgenv().MahoragaBlatant.FlySpeed, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.new(0, getgenv().MahoragaBlatant.FlySpeed, 0) end
            flyBodyVelocity.Velocity = vel
        end
    elseif flyBodyVelocity then
        flyBodyVelocity:Destroy()
        flyBodyAngularVelocity:Destroy()
        flyBodyVelocity, flyBodyAngularVelocity = nil, nil
    end
end)

-- NOCLIP
local noclipConn
noclipConn = RunService.Stepped:Connect(function()
    if getgenv().MahoragaBlatant.NoclipEnabled and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- INF JUMP
UserInputService.JumpRequest:Connect(function()
    if getgenv().MahoragaBlatant.InfJump and player.Character then
        player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

-- FULLBRIGHT
local oldBright = Lighting.Brightness
local oldTech = Lighting.Technology
local oldAmb = Lighting.Ambient
local oldColor = Lighting.ColorShift_Bottom
local oldTop = Lighting.ColorShift_Top
local oldGT = Lighting.GlobalShadows
local oldFog = Lighting.FogEnd
local oldExp = Lighting.ExposureCompensation
Rayfield:CreateToggle({Name = "Fullbright Toggle", CurrentValue = false, Callback = function(state)
    getgenv().MahoragaBlatant.FullbrightEnabled = state
    if state then
        Lighting.Brightness = 3
        Lighting.Technology = Enum.Technology.Compatibility
        Lighting.Ambient = Color3.fromRGB(255,255,255)
        Lighting.ColorShift_Bottom = Color3.fromRGB(255,255,255)
        Lighting.ColorShift_Top = Color3.fromRGB(255,255,255)
        Lighting.GlobalShadows = false
        Lighting.FogEnd = math.huge
        Lighting.ExposureCompensation = 1
    else
        Lighting.Brightness = oldBright
        Lighting.Technology = oldTech
        Lighting.Ambient = oldAmb
        Lighting.ColorShift_Bottom = oldColor
        Lighting.ColorShift_Top = oldTop
        Lighting.GlobalShadows = oldGT
        Lighting.FogEnd = oldFog
        Lighting.ExposureCompensation = oldExp
    end
end})

-- ESP (Simple Highlight)
local espHighlights = {}
RunService.Heartbeat:Connect(function()
    if getgenv().MahoragaBlatant.ESPEnabled then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr \~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local high = espHighlights[plr]
                if not high then
                    high = Instance.new("Highlight")
                    high.FillColor = Color3.new(1,0,0)
                    high.OutlineColor = Color3.new(1,1,1)
                    high.Parent = plr.Character
                    espHighlights[plr] = high
                end
            end
        end
        -- Fish ESP: Highlight workspace fish models
        for _, obj in pairs(workspace:GetChildren()) do
            if obj.Name:find("Fish") and obj:FindFirstChild("HumanoidRootPart") then
                local high = obj:FindFirstChild("Highlight")
                if not high then
                    high = Instance.new("Highlight")
                    high.FillColor = Color3.new(0,1,0)
                    high.OutlineColor = Color3.new(1,1,0)
                    high.Parent = obj
                end
            end
        end
    else
        for _, high in pairs(espHighlights) do high:Destroy() end
        espHighlights = {}
    end
end)

-- ANTI AFK
spawn(function()
    while true do
        VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1)
        wait(1)
        VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1)
        wait(60)
    end
end)

-- MAIN FARM LOOP (Real remotes)
spawn(function()
    while true do
        pcall(function()
            if getgenv().MahoragaBlatant.AutoFish then
                -- Charge & Cast
                Events.ChargeFishingRod:InvokeServer()
                wait(0.5)
                Events.RequestFishingMinigameStarted:InvokeServer()
                
                -- Instant Catch (Blatant)
                if getgenv().MahoragaBlatant.InstantCatch then
                    Events.FishingCompleted:FireServer(true)  -- Perfect catch
                else
                    wait(1)
                    Events.FishingCompleted:FireServer()
                end
                Events.CancelFishingInputs:InvokeServer()
            end
            
            if getgenv().MahoragaBlatant.AutoSell then
                Events.SellAllItems:InvokeServer()
                wait(1)
            end
        end)
        wait(0.1)
    end
end)

print("💀 MAHORAGA BLATANT: Loaded. Fly high, clip through, ESP everything. Wheel eternal. 😈🌀")
