-- 1. ScriptBlox аналитикасы
pcall(function() 
    loadstring(game:HttpGet("https://scriptblox.com/ingest/clientv2.lua"))("proj_6359c89f56ac", "1.0.0", false) 
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local DATABASE_URL = "https://play-lag-default-rtdb.firebaseio.com/ActiveUsers"
local SETTINGS_URL = "https://play-lag-default-rtdb.firebaseio.com/Settings"

local currentPassword = "1921"
local freeEvent = {Enabled = false, Start = 0, End = 0}

-- Базадан пароль мен уақытты жүктеу
pcall(function()
    local passRes = request({ Url = SETTINGS_URL .. "/Password.json", Method = "GET" })
    if passRes and passRes.StatusCode == 200 then
        local pData = HttpService:JSONDecode(passRes.Body)
        if pData and type(pData) == "string" and pData ~= "" then 
            currentPassword = pData 
        end
    end

    local freeRes = request({ Url = SETTINGS_URL .. "/FreeEvent.json", Method = "GET" })
    if freeRes and freeRes.StatusCode == 200 then
        local fData = HttpService:JSONDecode(freeRes.Body)
        if type(fData) == "table" then freeEvent = fData end
    end
end)

-- Қосылатын екі скрипт сілтемелері
local HUB_URL_1 = "https://raw.githubusercontent.com/tienkhanh1/Venyx/main/VenyxHub"
local HUB_URL_2 = "https://api.luarmor.net/files/v4/loaders/7891557d7950ed56a7d1d8f57b66ad4d.lua"

-- Жаңарту экран терезесі (Загрузка және Дисклеймер)
local function showUpdateScreen()
    local CoreGui = game:GetService("CoreGui")
    local UpdGui = Instance.new("ScreenGui")
    UpdGui.Name = "NurlykhanUpdateGui"
    UpdGui.ResetOnSpawn = false

    pcall(function() UpdGui.Parent = CoreGui end)
    if not UpdGui.Parent then UpdGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 420, 0, 280)
    MainFrame.Position = UDim2.new(0.5, -210, 0.5, -140)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = UpdGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.BackgroundTransparency = 1
    Title.Text = "🚨 NURLYKHAN HUB - ЖАҢАРТУ 🚨"
    Title.TextColor3 = Color3.fromRGB(255, 215, 0)
    Title.TextSize = 16
    Title.Font = Enum.Font.SourceSansBold
    Title.Parent = MainFrame

    local Desc = Instance.new("TextLabel")
    Desc.Size = UDim2.new(0.9, 0, 0, 110)
    Desc.Position = UDim2.new(0.05, 0, 0.2, 0)
    Desc.BackgroundTransparency = 1
    Desc.Text = "Бәріңе сәлем ойыншылар!\nСкрипт жаңартылды, қалай, скрипт жақсы ма?\nБірақ жұмыртқа ұшып ұрлайтын істей қалады, оны түзеді бірақ түзелген жоқ, сондықтан ұшатын істемейді.\nЖаңару таңғы 8:00-ге дейін қойылады, оған дейін бұрынғысынша ойнай бересіздер.\nЖаңару ұнаса чатқа 'ұнады' деп жазыңыз!"
    Desc.TextColor3 = Color3.fromRGB(255, 255, 255)
    Desc.TextSize = 12
    Desc.Font = Enum.Font.SourceSans
    Desc.TextWrapped = true
    Desc.Parent = MainFrame

    local UpdateBtn = Instance.new("TextButton")
    UpdateBtn.Size = UDim2.new(0.9, 0, 0, 40)
    UpdateBtn.Position = UDim2.new(0.05, 0, 0.72, 0)
    UpdateBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    UpdateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    UpdateBtn.Text = "🔥 Скриптті жаңарту (Жаңаруды қосу)"
    UpdateBtn.TextSize = 14
    UpdateBtn.Font = Enum.Font.SourceSansBold
    UpdateBtn.Parent = MainFrame
    Instance.new("UICorner", UpdateBtn).CornerRadius = UDim.new(0, 8)

    UpdateBtn.MouseButton1Click:Connect(function()
        UpdateBtn.Visible = false
        
        -- 10 секундтық загрузка (таймер)
        for i = 10, 1, -1 do
            Title.Text = "⏳ Загрузка жүріп жатыр: " .. i .. " сек..."
            task.wait(1)
        end

        UpdGui:Destroy()

        -- Хабарлама
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Nurlykhan HUB 👑",
            Text = "Барлық жаңартылған скриптер қосылды!",
            Duration = 4
        })

        -- 1-ші скриптті іске қосу (Venyx)
        pcall(function()
            local source1 = game:HttpGet(HUB_URL_1)
            if source1 and source1 ~= "" then
                local chunk1 = loadstring(source1)
                if chunk1 then chunk1() end
            end
        end)

        -- 2-ші скриптті қатар іске қосу (Luarmor)
        pcall(function()
            -- Егер key қажет болса келесі жолға жазуға болады:
            -- getgenv().script_key = "KEY"
            local source2 = game:HttpGet(HUB_URL_2)
            if source2 and source2 ~= "" then
                local chunk2 = loadstring(source2)
                if chunk2 then chunk2() end
            end
        end)
    end)
end

local function registerActiveUser()
    task.spawn(function()
        pcall(function()
            request({
                Url = DATABASE_URL .. "/" .. LocalPlayer.UserId .. ".json",
                Method = "PUT",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({Username = LocalPlayer.Name, Time = os.time(), Kick = false, Pause = false})
            })
        end)
    end)
    
    showUpdateScreen()
end

-- Таңғы 8:00-ге дейінгі уақытты тексеру логикасы (08:00-ге дейін еркін ойнай береді)
local currentHour = tonumber(os.date("%H"))
local isBeforeMorning = false

if currentHour and currentHour < 8 then
    isBeforeMorning = true
end

-- Таңғы 8-ден бұрын болса немесе пароль "NONE" болса — пароль сұрамайды
if isBeforeMorning or currentPassword == "NONE" then
    if isBeforeMorning then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "🌅 ТАҢҒЫ РЕЖИМ!",
            Text = "Таңғы 8:00-ге дейін еркін қосылдыңыз!",
            Duration = 6
        })
    end
    registerActiveUser()
else
    -- Пароль сұрау терезесі
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

    SubmitBtn.MouseButton1Click:Connect(function()
        if PassBox.Text == currentPassword then
            ScreenGui:Destroy()
            registerActiveUser()
        else
            SubmitBtn.Text = "Пароль қате!"
            SubmitBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            task.wait(1.5)
            SubmitBtn.Text = "Кіру"
            SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        end
    end)
end
