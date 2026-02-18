-- CURSED MAHORAGA: Fish It ULTRA BLATANT v5.0 - ALL-IN-ONE MERGED
-- Flood 50x/sec, blatant godmode, error suppression full, real remotes 2026

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- SUPPRESS COMMON ERRORS (asset, trove cleanup, nil index)
hookfunction(game:GetService("ContentProvider").PreloadAsync, function(self, assets, callback)
    if callback then
        task.spawn(function()
            for _, asset in assets do
                callback(asset, Enum.AssetFetchStatus.Success)
            end
        end)
    end
    return true
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if method == "Add" and tostring(self):find("trove") or method == "Cleanup" then
        return -- skip conflicted trove calls
    end
    if method:find("FireServer") or method:find("InvokeServer") then
        pcall(function() return oldNamecall(self, ...) end)
        return
    end
    return oldNamecall(self, ...)
end)

print("🌀 MAHORAGA: All common errors suppressed. Asset & trove bypass active.")

-- CONFIG
getgenv().MahoragaV5 = {
    FloodEnabled = true,
    FloodMultiplier = 50,     -- requests per sec per loop
    AutoSell = true,
    Fly = false,
    Noclip = false,
    ESP = false,
    Fullbright = false,
    InfJump = false,
    Speed = 200,
    JumpPower = 250,
    FlySpeed = 80
}

-- RAYFIELD UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "🌀 MAHORAGA v5.0 - Fish It Godmode 🔥",
    LoadingTitle = "Wheel Spinning Eternal",
    KeySystem = false
})

local MainTab = Window:CreateTab("🌊 Flood & Farm")
MainTab:CreateToggle({Name = "Ultra Flood Fish (10–50+/sec)", CurrentValue = true, Callback = function(v) getgenv().MahoragaV5.FloodEnabled = v end})
MainTab:CreateSlider({Name = "Flood Intensity", Range = {10, 100}, Increment = 5, CurrentValue = 50, Callback = function(v) getgenv().MahoragaV5.FloodMultiplier = v end})
MainTab:CreateToggle({Name = "Auto Sell Every 0.3s", CurrentValue = true, Callback = function(v) getgenv().MahoragaV5.AutoSell = v end})

local BlatantTab = Window:CreateTab("😈 Blatant Godmode")
BlatantTab:CreateToggle({Name = "Fly (WASD + Space/Shift)", CurrentValue = false, Callback = function(v) getgenv().MahoragaV5.Fly = v end})
BlatantTab:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(v) getgenv().MahoragaV5.Noclip = v end})
BlatantTab:CreateToggle({Name = "ESP (Players + Fish)", CurrentValue = false, Callback = function(v) getgenv().MahoragaV5.ESP = v end})
BlatantTab:CreateToggle({Name = "Fullbright", CurrentValue = false, Callback = function(v) getgenv().MahoragaV5.Fullbright = v end})
BlatantTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(v) getgenv().MahoragaV5.InfJump = v end})
BlatantTab:CreateSlider({Name = "Walk Speed", Range = {16, 500}, Increment = 10, CurrentValue = 200, Callback = function(v) getgenv().MahoragaV5.Speed = v end})
BlatantTab:CreateSlider({Name = "Jump Power", Range = {50, 500}, Increment = 10, CurrentValue = 250, Callback = function(v) getgenv().MahoragaV5.JumpPower = v end})
BlatantTab:CreateSlider({Name = "Fly Speed", Range = {20, 200}, Increment = 5, CurrentValue = 80, Callback = function(v) getgenv().MahoragaV5.FlySpeed = v end})

-- REMOTES (real paths 2026)
local net = ReplicatedStorage:WaitForChild("Packages", 5):WaitForChild("_Index", 5):WaitForChild("sleitnick_net@0.2.0", 5):WaitForChild("net", 5)
local Events = {
    Charge = net:WaitForChild("RF/ChargeFishingRod", 5),
    StartMini = net:WaitForChild("RF/RequestFishingMinigameStarted", 5),
    Complete = net:WaitForChild("RE/FishingCompleted", 5),
    Cancel = net:WaitForChild("RF/CancelFishingInputs", 5),
    SellAll = net:WaitForChild("RF/SellAllItems", 5)
}

-- STATS UPDATE
local function updateStats()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        local hum = player.Character.Humanoid
        hum.WalkSpeed = getgenv().MahoragaV5.Speed
        hum.JumpPower = getgenv().MahoragaV5.JumpPower
    end
end
player.CharacterAdded:Connect(updateStats)
updateStats()

-- FLY SYSTEM
local flyBV, flyBG
RunService.Heartbeat:Connect(function()
    if getgenv().MahoragaV5.Fly and player.Character then
        local root = player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            if not flyBV then
                flyBV = Instance.new("BodyVelocity", root) flyBV.MaxForce = Vector3.new(1e9,1e9,1e9)
                flyBG = Instance.new("BodyGyro", root) flyBG.MaxTorque = Vector3.new(1e9,1e9,1e9) flyBG.P = 9e4
            end
            local cam = workspace.CurrentCamera
            flyBG.CFrame = cam.CFrame
            local move = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
            flyBV.Velocity = move.Unit * getgenv().MahoragaV5.FlySpeed * 50
        end
    elseif flyBV then flyBV:Destroy() flyBG:Destroy() flyBV, flyBG = nil, nil end
end)

-- NOCLIP
RunService.Stepped:Connect(function()
    if getgenv().MahoragaV5.Noclip and player.Character then
        for _, part in player.Character:GetDescendants() do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- INF JUMP
UserInputService.JumpRequest:Connect(function()
    if getgenv().MahoragaV5.InfJump and player.Character then
        player.Character.Humanoid:ChangeState("Jumping")
    end
end)

-- FULLBRIGHT
if getgenv().MahoragaV5.Fullbright then
    Lighting.Brightness = 3
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Ambient = Color3.fromRGB(255,255,255)
end

-- ESP
local espTable = {}
RunService.Heartbeat:Connect(function()
    if getgenv().MahoragaV5.ESP then
        for _, plr in Players:GetPlayers() do
            if plr \~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                if not espTable[plr] then
                    local h = Instance.new("Highlight", plr.Character)
                    h.FillColor = Color3.new(1,0,0) h.OutlineColor = Color3.new(1,1,0)
                    espTable[plr] = h
                end
            end
        end
        for _, obj in workspace:GetChildren() do
            if obj.Name:lower():find("fish") and obj:FindFirstChild("HumanoidRootPart") and not obj:FindFirstChild("Highlight") then
                local h = Instance.new("Highlight", obj)
                h.FillColor = Color3.new(0,1,0) h.OutlineColor = Color3.new(1,1,0)
            end
        end
    else
        for _, h in espTable do h:Destroy() end espTable = {}
    end
end)

-- ULTRA FLOOD LOOP
spawn(function()
    while true do
        if getgenv().MahoragaV5.FloodEnabled then
            for i = 1, getgenv().MahoragaV5.FloodMultiplier do
                pcall(function()
                    Events.Charge:InvokeServer()
                    Events.StartMini:InvokeServer()
                    Events.Complete:FireServer(true)
                    Events.Cancel:InvokeServer()
                end)
            end
        end
        wait(0.01)  -- \~100 loops/sec base, multiplier naikkan spam
    end
end)

-- AUTO SELL FLOOD
spawn(function()
    while true do
        if getgenv().MahoragaV5.AutoSell then
            pcall(function()
                Events.SellAll:InvokeServer()
            end)
        end
        wait(0.3)
    end
end)

-- ANTI AFK HARDCORE
spawn(function()
    while true do
        VirtualInputManager:SendKeyEvent(true, "W", false, game)
        wait(0.1)
        VirtualInputManager:SendKeyEvent(false, "W", false, game)
        wait(55)
    end
end)

print("💀 MAHORAGA v5.0 LOADED: Ultra flood + full blatant. Coins infinite. Server dies first. 🌀😈")
