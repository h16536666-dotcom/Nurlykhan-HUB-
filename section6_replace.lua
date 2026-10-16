-- 1. ScriptBlox аналитикасы
pcall(function() 
    loadstring(game:HttpGet("https://scriptblox.com/ingest/clientv2.lua"))("proj_6359c89f56ac", "1.0.0", false) 
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local DATABASE_URL = "https://play-lag-default-rtdb.firebaseio.com/NurlykhanAdmin"

-- 2. Скрипттер сілтемесі
local SAE = "https://raw.githubusercontent.com/h16536666-dotcom/Egg-Roblox-Delta-script-/refs/heads/main/StealAnEgg.lua"
local RAP = "https://api.luarmor.net/files/v4/loaders/0dbcaa9e992477523d38a8284d7dbdef.lua"
local JFA = "https://raw.githubusercontent.com/tienkhanh1/Chilli-Hub-Script/refs/heads/main/JumpForAnimals"
local SAB = "https://raw.githubusercontent.com/tienkhanh1/spicy/refs/heads/main/Steal-a-Brainrot"
local MM2 = "https://api.luarmor.net/files/v4/loaders/2bf348894416e1d3deee40be756d42ff.lua"
local BROOK = "https://api.luarmor.net/files/v4/loaders/89190a03fd337349cef140d576357ba3.lua"

local byGameId = {
    [10563114921] = SAE,
    [10035204815] = RAP,
    [10690360998] = JFA,
    [7709344486] = SAB,
    [66654135] = MM2,
    [1686885941] = BROOK,
}

local byPlaceId = {
    [107778070777162] = SAE,
    [124216119978534] = RAP,
    [126870639873289] = JFA,
    [109983668079237] = SAB,
    [142823291] = MM2,
    [4924922222] = BROOK,
}

local function startMainScript()
    local gameId = game.GameId
    while gameId == 0 and game.PlaceId == 0 do
        task.wait()
        gameId = game.GameId
    end

    local url = byGameId[gameId] or byPlaceId[game.PlaceId]
    if not url then return end

    for _ = 1, 3 do
        local ok, source = pcall(game.HttpGet, game, url)
        if ok and type(source) == "string" and source ~= "" then
            local chunk = loadstring(source)
            if chunk then chunk() end
            return
        end
        task.wait(0.5)
    end
end

-- Отшашу эффектісі
local function createFireworks()
    local player = game.Players.LocalPlayer
    local pgui = player:WaitForChild("PlayerGui")
    
    local fxGui = Instance.new("ScreenGui")
    fxGui.Name = "FireworksEffect"
    fxGui.ResetOnSpawn = false
    fxGui.Parent = pgui

    local colors = {
        Color3.fromRGB(255, 50, 50),
        Color3.fromRGB(50, 255, 50),
        Color3.fromRGB(50, 150, 255),
        Color3.fromRGB(255, 220, 50),
        Color3.fromRGB(255, 50, 255)
    }

    for i = 1, 40 do
        local particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, math.random(8, 14), 0, math.random(8, 14))
        particle.Position = UDim2.new(0.5, 0, 0.5, 0)
        particle.BackgroundColor3 = colors[math.random(1, #colors)]
        particle.BorderSizePixel = 0
        particle.Parent = fxGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = particle

        local angle = math.rad(math.random(0, 360))
        local speed = math.random(150, 450)
        local vx = math.cos(angle) * speed
        local vy = math.sin(angle) * speed

        task.spawn(function()
            local t = 0
            while t < 1 do
                t = t + task.wait(0.02)
                particle.Position = UDim2.new(0.5, vx * t, 0.5, vy * t + (t * t * 100))
                particle.BackgroundTransparency = t
            end
            particle:Destroy()
        end)
    end

    task.delay(1.5, function()
        fxGui:Destroy()
    end)
end

-- Админ панелін ашатын батырма мен интерфейсті құру
local function createAdminPanel()
    local adminGui = Instance.new("ScreenGui")
    adminGui.Name = "NurlykhanAdminGui"
    adminGui.ResetOnSpawn = false
    
    pcall(function() adminGui.Parent = game:GetService("CoreGui") end)
    if not adminGui.Parent then adminGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- Экранда тұратын кішігірім Админ түймесі
    local OpenBtn = Instance.new("TextButton")
    OpenBtn.Size = UDim2.new(0, 120, 0, 35)
    OpenBtn.Position = UDim2.new(0, 10, 0.5, -60)
    OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    OpenBtn.TextColor3 = Color3.fromRGB(20, 20, 30)
    OpenBtn.Text = "👑 Admin Panel"
    OpenBtn.TextSize, OpenBtn.Font = 13, Enum.Font.SourceSansBold
    OpenBtn.Active = true
    OpenBtn.Draggable = true
    OpenBtn.Parent = adminGui
    Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 8)

    -- Негізгі Админ панель терезесі (Бастапқыда жабық тұрады)
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 350, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Visible = false
    MainFrame.Parent = adminGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

    OpenBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = not MainFrame.Visible
    end)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = "Nurlykhan Script Qoldanyp Jtqandar"
    Title.TextColor3 = Color3.fromRGB(255, 215, 0)
    Title.TextSize = 14
    Title.Font = Enum.Font.SourceSansBold
    Title.Parent = MainFrame

    local RefreshBtn = Instance.new("TextButton")
    RefreshBtn.Size = UDim2.new(0.9, 0, 0, 30)
    RefreshBtn.Position = UDim2.new(0.05, 0, 0.12, 0)
    RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RefreshBtn.Text = "🔄 Тізімді жаңарту"
    RefreshBtn.TextSize, RefreshBtn.Font = 13, Enum.Font.SourceSansBold
    RefreshBtn.Parent = MainFrame
    Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 8)

    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(0.9, 0, 0.5, 0)
    ScrollFrame.Position = UDim2.new(0.05, 0, 0.22, 0)
    ScrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollFrame.Parent = MainFrame
    Instance.new("UICorner", ScrollFrame).CornerRadius = UDim.new(0, 8)

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = ScrollFrame

    local ControlFrame = Instance.new("Frame")
    ControlFrame.Size = UDim2.new(0.9, 0, 0.22, 0)
    ControlFrame.Position = UDim2.new(0.05, 0, 0.75, 0)
    ControlFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    ControlFrame.BorderSizePixel = 0
    ControlFrame.Parent = MainFrame
    Instance.new("UICorner", ControlFrame).CornerRadius = UDim.new(0, 8)

    local SelectedLabel = Instance.new("TextLabel")
    SelectedLabel.Size = UDim2.new(1, 0, 0, 25)
    SelectedLabel.BackgroundTransparency = 1
    SelectedLabel.Text = "Ойыншы таңдалған жоқ"
    SelectedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    SelectedLabel.TextSize, SelectedLabel.Font = 12, Enum.Font.SourceSansItalic
    SelectedLabel.Parent = ControlFrame

    local TimeBtn = Instance.new("TextButton")
    TimeBtn.Size = UDim2.new(0.47, 0, 0, 30)
    TimeBtn.Position = UDim2.new(0.02, 0, 0.5, 0)
    TimeBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    TimeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TimeBtn.Text = "⏳ Уақыт беру (1 апта)"
    TimeBtn.TextSize, TimeBtn.Font = 11, Enum.Font.SourceSansBold
    TimeBtn.Parent = ControlFrame
    Instance.new("UICorner", TimeBtn).CornerRadius = UDim.new(0, 6)

    local KickBtn = Instance.new("TextButton")
    KickBtn.Size = UDim2.new(0.47, 0, 0, 30)
    KickBtn.Position = UDim2.new(0.51, 0, 0.5, 0)
    KickBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    KickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    KickBtn.Text = "🚫 Ойыннан шығару"
    KickBtn.TextSize, KickBtn.Font = 11, Enum.Font.SourceSansBold
    KickBtn.Parent = ControlFrame
    Instance.new("UICorner", KickBtn).CornerRadius = UDim.new(0, 6)

    local selectedUserKey = nil
    local selectedUserName = ""

    local function fetchActiveUsers()
        for _, child in ipairs(ScrollFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        pcall(function()
            local response = request({
                Url = DATABASE_URL .. "/ActiveUsers.json",
                Method = "GET"
            })
            if response and response.StatusCode == 200 then
                local data = HttpService:JSONDecode(response.Body)
                if type(data) == "table" then
                    local count = 0
                    for uid, info in pairs(data) do
                        count = count + 1
                        local pBtn = Instance.new("TextButton")
                        pBtn.Size = UDim2.new(1, -10, 0, 35)
                        pBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
                        pBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                        pBtn.Text = "  ⚡ " .. tostring(info.Username)
                        pBtn.TextXAlignment = Enum.TextXAlignment.Left
                        pBtn.TextSize = 13
                        pBtn.Font = Enum.Font.SourceSansBold
                        pBtn.Parent = ScrollFrame
                        Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 6)

                        pBtn.MouseButton1Click:Connect(function()
                            selectedUserKey = uid
                            selectedUserName = tostring(info.Username)
                            SelectedLabel.Text = "Таңдалды: " .. selectedUserName
                        end)
                    end
                    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, count * 40)
                end
            end
        end)
    end

    RefreshBtn.MouseButton1Click:Connect(fetchActiveUsers)
    fetchActiveUsers()

    TimeBtn.MouseButton1Click:Connect(function()
        if selectedUserKey then
            pcall(function()
                request({
                    Url = DATABASE_URL .. "/ActiveUsers/" .. selectedUserKey .. "/Access.json",
                    Method = "PUT",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode("1_week")
                })
            end)
            SelectedLabel.Text = selectedUserName .. " уақыты ұзартылды!"
        end
    end)

    KickBtn.MouseButton1Click:Connect(function()
        if selectedUserKey then
            pcall(function()
                request({
                    Url = DATABASE_URL .. "/ActiveUsers/" .. selectedUserKey .. "/Kick.json",
                    Method = "PUT",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode(true)
                })
            end)
            SelectedLabel.Text = selectedUserName .. " команда жіберілді!"
        end
    end)
end

-- 3. Пароль енгізу интерфейсі (GUI)
local CoreGui = game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NurlykhanHubPass"
ScreenGui.ResetOnSpawn = false

pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 180)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "Nurlykhan HUB 👑"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextSize = 20
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local PassBox = Instance.new("TextBox")
PassBox.Size = UDim2.new(0.8, 0, 0, 35)
PassBox.Position = UDim2.new(0.1, 0, 0.35, 0)
PassBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
PassBox.TextColor3 = Color3.fromRGB(255, 255, 255)
PassBox.PlaceholderText = "Пароль енгізіңіз (1921)..."
PassBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
PassBox.Text = ""
PassBox.TextSize = 16
PassBox.Font = Enum.Font.SourceSans
PassBox.Parent = MainFrame
Instance.new("UICorner", PassBox).CornerRadius = UDim.new(0, 8)

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Size = UDim2.new(0.8, 0, 0, 35)
SubmitBtn.Position = UDim2.new(0.1, 0, 0.65, 0)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.Text = "Кіру"
SubmitBtn.TextSize = 18
SubmitBtn.Font = Enum.Font.SourceSansBold
SubmitBtn.Parent = MainFrame
Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 8)

-- 4. Пароль тексеру және тіркеу логикасы
SubmitBtn.MouseButton1Click:Connect(function()
    if PassBox.Text == "1921" then
        ScreenGui:Destroy()
        
        -- Firebase базасына скрипт қолданушысы ретінде тіркелу
        pcall(function()
            request({
                Url = DATABASE_URL .. "/ActiveUsers/" .. LocalPlayer.UserId .. ".json",
                Method = "PUT",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({Username = LocalPlayer.Name, Access = "active", Kick = false})
            })
        end)
        
        createFireworks()
        
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Nurlykhan HUB 👑",
            Text = "Nurlykhan script жүктелді!",
            Duration = 5
        })
        
        -- Админ панелін іске қосу
        createAdminPanel()
        
        -- Негізгі ойын скриптін іске қосу
        startMainScript()
    else
        SubmitBtn.Text = "Пароль қате!"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        task.wait(1.5)
        SubmitBtn.Text = "Кіру"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    end
end)
