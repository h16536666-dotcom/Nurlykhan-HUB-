-- 1. ScriptBlox аналитикасы
pcall(function() 
    loadstring(game:HttpGet("https://scriptblox.com/ingest/clientv2.lua"))("proj_6359c89f56ac", "1.0.0", false) 
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local DATABASE_URL = "https://play-lag-default-rtdb.firebaseio.com/ActiveUsers"
local SETTINGS_URL = "https://play-lag-default-rtdb.firebaseio.com/Settings"

-- Әдепкі басты пароль
local currentPassword = "1921"

-- Базадан парольді тексеріп алу
pcall(function()
    local response = request({ Url = SETTINGS_URL .. "/Password.json", Method = "GET" })
    if response and response.StatusCode == 200 then
        local data = HttpService:JSONDecode(response.Body)
        if data and type(data) == "string" then
            currentPassword = data
        end
    end
end)

-- 2. GitHub сілтемесі (Сіз жіберген тура сілтеме)
local HUB_URL = "https://raw.githubusercontent.com/h16536666-dotcom/Egg-Roblox-Delta-script-/refs/heads/main/StealAnEgg.lua"

-- 3. Негізгі скриптті жүктеу функциясы
local function startMainScript()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Nurlykhan HUB 👑",
        Text = "Скрипт жүктелуде...",
        Duration = 3
    })

    local success, err = pcall(function()
        local source = game:HttpGet(HUB_URL)
        if source and source ~= "" then
            local chunk = loadstring(source)
            if chunk then
                chunk()
            else
                error("Loadstring қатесі!")
            end
        else
            error("GitHub файлы табылмады!")
        end
    end)

    if not success then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Қате орын алды ❌",
            Text = tostring(err),
            Duration = 6
        })
    end
end

-- 4. Отшашу (Confetti) эффектісі
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

-- 5. Админ командаларын бақылау
local function listenToAdminCommands()
    task.spawn(function()
        while true do
            task.wait(5)
            pcall(function()
                local response = request({
                    Url = DATABASE_URL .. "/" .. LocalPlayer.UserId .. ".json",
                    Method = "GET"
                })
                if response and response.StatusCode == 200 then
                    local data = HttpService:JSONDecode(response.Body)
                    if type(data) == "table" then
                        if data.Kick == true then
                            LocalPlayer:Kick("Nurlykhan Admin: Ойыннан шығарылдыңыз!")
                        end
                        if data.Notification and data.Notification ~= "" then
                            game:GetService("StarterGui"):SetCore("SendNotification", {
                                Title = "Nurlykhan Admin 👑",
                                Text = tostring(data.Notification),
                                Duration = 6
                            })
                            request({
                                Url = DATABASE_URL .. "/" .. LocalPlayer.UserId .. "/Notification.json",
                                Method = "PUT",
                                Headers = {["Content-Type"] = "application/json"},
                                Body = HttpService:JSONEncode("")
                            })
                        end
                    end
                end
            end)
        end
    end)
end

-- 6. Пароль енгізу GUI
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
PassBox.PlaceholderText = "Пароль енгізіңіз..."
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

-- Пароль тексеру
SubmitBtn.MouseButton1Click:Connect(function()
    if PassBox.Text == currentPassword then
        ScreenGui:Destroy()
        
        -- Firebase-ке кіргенін тіркеу
        task.spawn(function()
            pcall(function()
                request({
                    Url = DATABASE_URL .. "/" .. LocalPlayer.UserId .. ".json",
                    Method = "PUT",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({Username = LocalPlayer.Name, Time = os.time(), Kick = false})
                })
            end)
        end)
        
        listenToAdminCommands()
        createFireworks()
        startMainScript()
    else
        SubmitBtn.Text = "Пароль қате!"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        task.wait(1.5)
        SubmitBtn.Text = "Кіру"
        SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    end
end)
