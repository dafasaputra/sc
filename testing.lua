-- SENTOT FISH IT EXACT REMOTE DUMP - LYNX UI VELOCITY
local RS = game:GetService("ReplicatedStorage")
local net = RS.Packages._Index["sleitnick_net@0.2.0"].net

local Equip = net["RE/EquipToolFromHotbar"]
local SellAll = net["RF/SellAllItems"]
local Charge = net["RF/ChargeFishingRod"]
local Request = net["RF/RequestFishingMinigameStarted"]
local Catch = net["RF/CatchFishCompleted"]
local Cancel = net["RF/CancelFishingInputs"]
local BuyItem = net["RF/PurchaseMarketItem"]

local AutoFishEnabled = false

local argsRequest = {-5718742609204048, -0.397660581386669, 1771146782.714026}

local function equipRod() pcall(Equip.FireServer, Equip, 1) end

local function performCatch()
    pcall(Charge.InvokeServer, Charge)
    task.wait(0.6 + math.random()/5)
    pcall(Request.InvokeServer, Request, unpack(argsRequest))
    task.wait(1.0 + math.random()/3)
    pcall(Catch.InvokeServer, Catch, true)
    pcall(Cancel.InvokeServer, Cancel, true)
end

spawn(function()
    while true do
        if AutoFishEnabled then
            equipRod()
            performCatch()
            task.wait(3.0 + math.random(5,15)/10)
        end
        task.wait(0.05)
    end
end)

spawn(function()
    while true do
        if AutoFishEnabled then
            pcall(SellAll.InvokeServer, SellAll)
        end
        task.wait(10 + math.random(5,10))
    end
end)

-- LYNX UI FULL EMBEDDED
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local function create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do obj[k] = v end
    return obj
end

local function tween(obj, info, props)
    TweenService:Create(obj, info or TweenInfo.new(0.25), props):Play()
end

local function makeDraggable(frame)
    local dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragInput = nil end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    RunService.RenderStepped:Connect(function()
        if dragInput then
            local delta = dragInput.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local sg = create("ScreenGui", {Name = "SentotLynx", Parent = game.CoreGui, ResetOnSpawn = false})
local main = create("Frame", {
    Size = UDim2.new(0, 420, 0, 300),
    Position = UDim2.new(0.5, -210, 0.5, -150),
    BackgroundColor3 = Color3.fromRGB(18, 18, 18),
    BorderSizePixel = 0,
    Parent = sg
})
create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = main})
create("UIStroke", {Color = Color3.fromRGB(40, 40, 40
