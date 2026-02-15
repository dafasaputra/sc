-- AUTO FISH - VERSI FLEKSIBEL (sesuaikan path)
local Player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ===== GANTI PATH INI DENGAN HASIL SCAN =====
local REMOTE_CHARGE = ReplicatedStorage:FindFirstChild("Packages/_Index/sleitnick_net@0.2.0/net/RF/ChargeFishingRod")  -- contoh
local REMOTE_CATCH = ReplicatedStorage:FindFirstChild("Packages/_Index/sleitnick_net@0.2.0/net/RF/CatchFishCompleted")
local REMOTE_SELL = ReplicatedStorage:FindFirstChild("Packages/_Index/sleitnick_net@0.2.0/net/RF/SellAllItems")
-- =============================================

-- GUI minimal
local playerGui = Player:WaitForChild("PlayerGui")
local gui = Instance.new("ScreenGui")
gui.Parent = playerGui
gui.Name = "AutoFish"

local btn = Instance.new("TextButton")
btn.Parent = gui
btn.Size = UDim2.new(0, 200, 0, 50)
btn.Position = UDim2.new(0, 10, 0, 10)
btn.Text = "START FISHING"
btn.BackgroundColor3 = Color3.new(0, 1, 0)
btn.Draggable = true

local status = Instance.new("TextLabel")
status.Parent = gui
status.Position = UDim2.new(0, 10, 0, 70)
status.Size = UDim2.new(0, 200, 0, 30)
status.Text = "Idle"
status.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
status.TextColor3 = Color3.new(1, 1, 0)

local fishing = false
local fishCount = 0

local function safeCall(remote, ...)
    if not remote then return false, "Remote nil" end
    local success, result = pcall(function()
        if remote:IsA("RemoteFunction") then
            return remote:InvokeServer(...)
        else
            remote:FireServer(...)
            return true
        end
    end)
    return success, result
end

btn.MouseButton1Click:Connect(function()
    fishing = not fishing
    btn.Text = fishing and "STOP FISHING" or "START FISHING"
    btn.BackgroundColor3 = fishing and Color3.new(1, 0, 0) or Color3.new(0, 1, 0)
    
    if fishing then
        spawn(function()
            while fishing do
                status.Text = "Charging..."
                safeCall(REMOTE_CHARGE)
                wait(1)
                
                status.Text = "Catching..."
                local ok, res = safeCall(REMOTE_CATCH)
                if ok then
                    fishCount = fishCount + 1
                    status.Text = "Fish caught! Total: " .. fishCount
                else
                    status.Text = "Error: " .. tostring(res)
                end
                wait(1)
                
                -- Auto sell tiap 5 ikan
                if fishCount % 5 == 0 then
                    safeCall(REMOTE_SELL)
                end
                wait(0.5)
            end
        end)
    end
end)
