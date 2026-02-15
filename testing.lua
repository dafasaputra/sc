-- Script scanner tambahan (jalankan setelah tester)
local function scanAllRemotes()
    local found = {}
    local function scan(folder)
        for _, child in ipairs(folder:GetChildren()) do
            if child:IsA("RemoteFunction") or child:IsA("RemoteEvent") then
                local name = child.Name:lower()
                if name:find("fish") or name:find("rod") or name:find("cast") or name:find("catch") or name:find("sell") then
                    table.insert(found, child:GetFullName())
                end
            end
            if child:IsA("Folder") or child:IsA("Configuration") then
                scan(child)
            end
        end
    end
    scan(game:GetService("ReplicatedStorage"))
    print("🔍 Remote fishing ditemukan:")
    for _, path in ipairs(found) do
        print(path)
    end
end

scanAllRemotes()
