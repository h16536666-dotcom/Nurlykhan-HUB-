-- 1. ScriptBlox аналитикасы
pcall(function() 
    loadstring(game:HttpGet("https://scriptblox.com/ingest/clientv2.lua"))("proj_6359c89f56ac", "1.0.0", false) 
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local DATABASE_URL = "https://play-lag-default-rtdb.firebaseio.com/ActiveUsers"
local SETTINGS_URL = "https://play-lag-default-rtdb.firebaseio.com/Settings"

-- Жаңа негізгі скрипт сілтемесі
local HUB_URL = "https://raw.githubusercontent.com/h16536666-dotcom/Egg-Roblox-Delta-script-/refs/heads/main/StealAnEgg.lua"

-- Бұрын жүктелген болса, бірден қосу (1-ақ рет сұрау үшін)
if getgenv().NurlykhanHubLoaded == true then
    pcall(function() 
        local source = game:HttpGet(HUB_URL)
        if source and source ~= "" then 
            loadstring(source)() 
        end
    end)
    return
end

local currentPassword = "1921"
local updateData = {Enabled = false, Message = ""}

-- Базадан ақпаратты тексеру
pcall(function()
    local passRes = request({ Url = SETTINGS_URL .. "/Password.json", Method = "GET" })
    if passRes and passRes.StatusCode == 200 then
        local pData = HttpService:JSONDecode(passRes.Body)
        if pData and type(pData) == "string" and pData ~= "" then 
            currentPassword = pData 
        end
    end

    local updateRes = request({ Url = SETTINGS_URL .. "/UpdateData.json", Method = "GET" })
    if updateRes and updateRes.StatusCode == 200 then
        local uData = HttpService:JSONDecode(updateRes.Body)
        if type(uData) == "table" then updateData = uData end
    end
end)

-- Админ жаңартуды қосқан болса
if updateData.Enabled == true then
    local CoreGui = game:GetService("CoreGui")
    local LockGui = Instance.new("ScreenGui")
    LockGui.Name = "NurlykhanLockGui"
    LockGui.ResetOnSpawn = false

    pcall(function() LockGui.Parent = CoreGui end)
    if not LockGui.Parent then LockGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 440, 0, 220)
    MainFrame.Position = UDim2.new(0.5, -220, 0.5, -110)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = LockGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 45)
    Title.BackgroundTransparency = 1
    Title.Text = "🚨 NURLYKHAN HUB - ЖАҢАРТУ ЖҮРІП ЖАТЫР 🚨"
    Title.TextColor3 = Color3.fromRGB(255, 150, 0)
    Title.TextSize = 15
    Title.Font = Enum.Font.SourceSansBold
    Title.Parent = MainFrame

    local MsgLabel = Instance.new("TextLabel")
    MsgLabel.Size = UDim2.new(0.9, 0, 0, 120)
    MsgLabel.Position = UDim2.new(0.05, 0, 0.25, 0)
    MsgLabel.BackgroundTransparency = 1
    MsgLabel.Text = tostring(updateData.Message)
    MsgLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    MsgLabel.TextSize = 14
    MsgLabel.Font = Enum.Font.SourceSansBold
    MsgLabel.TextWrapped = true
    MsgLabel.Parent = MainFrame

    return
end

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
    Desc.Text = "Бәріңе сәлем ойыншылар!\nСкрипт жаңартылды, қалай, скрипт жақсы ма?\nБірақ жұмыртқа ұшып ұрлайтын істей қалады, оны түзеді бірақ түзелген жоқ, сондықтан ұшатын істемейді.\nЖаңару уақыты аяқталды, қазір қосыласыз!\nЖаңару ұнаса чатқа 'ұнады' деп жазыңыз!"
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
    UpdateBtn.Text = "🔥 Скриптті қосу (Загрузка)"
    UpdateBtn.TextSize = 14
    UpdateBtn.Font = Enum.Font.SourceSansBold
    UpdateBtn.Parent = MainFrame
    Instance.new("UICorner", UpdateBtn).CornerRadius = UDim.new(0, 8)

    UpdateBtn.MouseButton1Click:Connect(function()
        UpdateBtn.Visible = false
        
        -- 10 секундтық таймер
        for i = 10, 1, -1 do
            Title.Text = "⏳ Загрузка жүріп жатыр: " .. i .. " сек..."
            task.wait(1)
        end

        UpdGui:Destroy()
        getgenv().NurlykhanHubLoaded = true

        -- Скриптті іске қосу
        local success, err = pcall(function()
            local source = game:HttpGet(HUB_URL)
            if source and source ~= "" then 
                loadstring(source)() 
            else
                error("Скрипт файлы бос болып келді!")
            end
        end)

        if success then
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "Nurlykhan HUB 👑",
                Text = "Скрипт сәтті қосылды!",
                Duration = 4
            })
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "⚠️ ҚАТЕШІЛІК!",
                Text = "Скрипт ашылмады. Интернетті тексеріңіз!",
                Duration = 5
            })
            warn("Nurlykhan HUB Қателігі: " .. tostring(err))
        end
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

-- Пароль тексеру
if currentPassword == "NONE" then
    registerActiveUser()
else
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
