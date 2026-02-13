--[[
    🔥 RIOTESTTING - STEALTH FISH IT!
    ✅ TANPA UI = TANPA DETEKSI
    ✅ TANPA PRINT = TANPA JEJAK
    ✅ HANYA AUTO FISH + ANTI AFK
    ✅ WORK MESKIPUN ANTI-CHEAT AKTIF
]]

-- ========== [1. TUNGGU 30 DETIK (BYPASS DETEKSI AWAL)] ==========
print("⏳ Menunggu 30 detik untuk menghindari anti-cheat...")
task.wait(30)

-- ========== [2. INISIALISASI] ==========
local Player = game.Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")

-- ========== [3. ANTI AFK (WAJIB)] ==========
Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ========== [4. DETEKSI ROD & AUTO RE-EQUIP] ==========
local function GetRod()
    -- Cek di tangan dulu
    if Player.Character then
        for _, tool in ipairs(Player.Character:GetChildren()) do
            if tool:IsA("Tool") then
                return tool, true
            end
        end
    end
    -- Cek di backpack
    for _, tool in ipairs(Player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            return tool, false
        end
    end
    return nil, false
end

local function EquipRod(tool)
    if tool and Player.Character and Player.Character.Humanoid then
        pcall(function()
            Player.Character.Humanoid:EquipTool(tool)
        end)
    end
end

-- ========== [5. AUTO FISH - PALING STEALTH] ==========
local AutoFish = false
local FishCount = 0
local Blatant = false  -- Ganti ke true kalau mau speed maksimal

-- Toggle via keybind (F = ON/OFF, B = Blatant ON/OFF)
game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        AutoFish = not AutoFish
        -- Notifikasi silent (hanya di console)
        print(AutoFish and "✅ Auto Fish ON" or "⏹️ Auto Fish OFF")
    end
    if input.KeyCode == Enum.KeyCode.B then
        Blatant = not Blatant
        print(Blatant and "⚡ Blatant Mode ON" or "⚡ Blatant Mode OFF")
    end
end)

-- Loop utama
task.spawn(function()
    while true do
        if AutoFish then
            local rod, inHand = GetRod()
            
            -- Jika rod tidak ada di tangan, equip
            if rod and not inHand then
                EquipRod(rod)
                task.wait(0.5)
                rod, inHand = GetRod()
            end
            
            -- Jika rod siap di tangan
            if rod and inHand then
                -- Method 1: Activate() - paling stealth
                pcall(function()
                    rod:Activate()
                    if Blatant then task.wait(0.01) else task.wait(0.4 + math.random()*0.3) end
                    rod:Activate()
                    FishCount = FishCount + 1
                end)
                
                -- Delay antar siklus
                if Blatant then
                    task.wait(0.05)
                else
                    task.wait(0.8 + math.random()*0.7)
                end
            else
                -- Tunggu sampai punya rod
                task.wait(2)
            end
        else
            task.wait(1)
        end
    end
end)

-- ========== [6. STATISTIK VIA CHAT] ==========
-- Ketik !fish untuk lihat jumlah ikan
local ChatRemote = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents") and 
                   game.ReplicatedStorage.DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")

Player.Chatted:Connect(function(msg)
    if msg:lower() == "!fish" then
        if ChatRemote then
            ChatRemote:FireServer("🎣 Ikan ditangkap: " .. FishCount, "All")
        end
    end
end)

-- ========== [7. SELESAI] ==========
print("🔥 RIOTESTTING - STEALTH MODE READY")
print("✅ Tekan F untuk toggle Auto Fish")
print("✅ Tekan B untuk toggle Blatant Mode")
print("✅ Ketik !fish di chat untuk lihat statistik")
