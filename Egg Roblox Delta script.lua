-- 1. ScriptBlox аналитикасы
pcall(function() 
    loadstring(game:HttpGet("https://scriptblox.com/ingest/clientv2.lua"))("proj_6359c89f56ac", "1.0.0", false) 
end)

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

-- 3. Негізгі скриптті жүктеу функциясы
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

-- 4. Отшашу (Fireworks / Confetti) эффектісі
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
            local startX = particle.Position.X.Offset
            local startY = particle.Position.Y.Offset
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

-- 5. Пароль енгізу интерфейсі (GUI)
local CoreGui = game:GetService("CoreGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NurlykhanHubPass"
ScreenGui.ResetOnSpawn = false

pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 180)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

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
PassBox.PlaceholderText = "Пароль енгізіңіз..."
PassBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
PassBox.Text = ""
PassBox.TextSize = 16
PassBox.Font = Enum.Font.SourceSans
PassBox.Parent = MainFrame

local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 8)
BoxCorner.Parent = PassBox

local SubmitBtn = Instance.new("TextButton")
SubmitBtn.Size = UDim2.new(0.8, 0, 0, 35)
SubmitBtn.Position = UDim2.new(0.1, 0, 0.65, 0)
SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SubmitBtn.Text = "Кіру"
SubmitBtn.TextSize = 18
SubmitBtn.Font = Enum.Font.SourceSansBold
SubmitBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = SubmitBtn

-- 6. Пароль тексеру логикасы
SubmitBtn.MouseButton1Click:Connect(function()
    if PassBox.Text == "1921" then
        ScreenGui:Destroy()
        
        -- Отшашу эффектісі
        createFireworks()
        
        -- Хабарлама шығару
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Nurlykhan HUB 👑",
            Text = "Nurlykhan script жүктелді!",
            Duration = 5
        })
        
        -- Негізгі скриптті іске қосу
        startMainScript()
    else
        SubmitBtn.Text = "Пароль қате!"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        task.wait(1.5)
        SubmitBtn.Text = "Кіру"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    end
end)
