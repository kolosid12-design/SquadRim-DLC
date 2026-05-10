-- SWILL | SquadRim DLC PRO | v12.1 | БЕЗ БЛОКИРОВКИ МЕНЮ
-- Telegram: t.me/squadrim1
-- Insert = Меню | F7 = FreeCam | End = UNLOAD

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local Clipboard = game:GetService("Clipboard")
local TweenService = game:GetService("TweenService")

-- ========== ПЕРЕМЕННЫЕ СОСТОЯНИЯ ==========
local state = {
    menu = true,
    version = "1.0",
    theme = "dark",
    authorized = false, -- Флаг авторизации
    rage = {silent = false, fov = 150},
    legit = {aimbot = false, fov = 150, smoothness = 8},
    triggerbot = {enabled = false},
    visuals = {
        enabled = true, box = true, name = true, tracers = true,
        health = true, distance = true, chams = true, tracerOrigin = "Bottom"
    },
    misc = {freecam = false, bhop = false, fly = false, noclip = false}
}

local connections = {}
local bodyVel = nil
local flyActive = false
local isUnloaded = false
local isFreeCam = false
local camSpeed = 2.0
local lookSensitivity = 0.5
local moveState = {forward = 0, backward = 0, left = 0, right = 0, up = 0, down = 0}
local freecamBodyVelocity = nil

-- ========== FOV КРУГ ==========
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Transparency = 0.5

-- ========== ESP STORAGE ==========
local Storage = {}
local espFolder = Instance.new("Folder")
espFolder.Name = "SquadRim_ESP"
espFolder.Parent = CoreGui

local function Clean(player)
    if Storage[player] then
        for _, obj in pairs(Storage[player]) do
            pcall(function() 
                if typeof(obj) == "Instance" then obj:Destroy() else obj:Remove() end 
            end)
        end
        Storage[player] = nil
    end
end

local function Create(class, props)
    local d = Drawing.new(class)
    for i, v in pairs(props) do pcall(function() d[i] = v end) end
    return d
end

local function UpdateESP()
    if isFreeCam then return end
    if not state.visuals.enabled then 
        for _, player in pairs(Players:GetPlayers()) do Clean(player) end
        return 
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        
        if hrp and hum and hum.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            
            if onScreen then
                if not Storage[player] then
                    Storage[player] = {
                        Box = Create("Square", {Thickness = 1, Filled = false, Transparency = 1, Color = Color3.new(1,1,1)}),
                        Tracer = Create("Line", {Thickness = 1, Transparency = 0.7, Color = Color3.new(1,1,0)}),
                        Name = Create("Text", {Size = 14, Center = true, Outline = true, Color = Color3.new(1,1,1)}),
                        Dist = Create("Text", {Size = 13, Center = true, Outline = true, Color = Color3.new(0.8,0.8,0.8)}),
                        HBarOut = Create("Square", {Thickness = 1, Filled = true, Transparency = 0.5, Color = Color3.new(0,0,0)}),
                        HBar = Create("Square", {Thickness = 1, Filled = true, Transparency = 1}),
                        Highlight = Instance.new("Highlight")
                    }
                    Storage[player].Highlight.Parent = espFolder
                end
                
                local s = Storage[player]
                local sizeX = 2000 / pos.Z
                local sizeY = 3000 / pos.Z
                local x, y = pos.X - sizeX / 2, pos.Y - sizeY / 2
                
                s.Box.Visible = state.visuals.box
                s.Box.Position = Vector2.new(x, y)
                s.Box.Size = Vector2.new(sizeX, sizeY)
                
                s.Name.Visible = state.visuals.name
                s.Name.Position = Vector2.new(pos.X, y - 16)
                s.Name.Text = player.Name
                
                s.Dist.Visible = state.visuals.distance
                s.Dist.Position = Vector2.new(pos.X, y + sizeY + 2)
                s.Dist.Text = math.floor(pos.Z) .. "m"
                
                local hp = hum.Health / hum.MaxHealth
                s.HBarOut.Visible = state.visuals.health
                s.HBarOut.Position = Vector2.new(x - 6, y)
                s.HBarOut.Size = Vector2.new(4, sizeY)
                
                s.HBar.Visible = state.visuals.health
                s.HBar.Position = Vector2.new(x - 5, y + (sizeY * (1 - hp)))
                s.HBar.Size = Vector2.new(2, sizeY * hp)
                s.HBar.Color = Color3.new(1,0,0):Lerp(Color3.new(0,1,0), hp)
                
                s.Tracer.Visible = state.visuals.tracers
                local origin = state.visuals.tracerOrigin
                s.Tracer.From = origin == "Bottom" and Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y) or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                s.Tracer.To = Vector2.new(pos.X, pos.Y + (sizeY/2))
                
                s.Highlight.Enabled = state.visuals.chams
                s.Highlight.Adornee = char
                s.Highlight.FillTransparency = 0.5
                s.Highlight.OutlineTransparency = 0
            else
                Clean(player)
            end
        else
            Clean(player)
        end
    end
end

Players.PlayerRemoving:Connect(Clean)

-- ========== AIMBOT ФУНКЦИИ ==========
local function GetClosestPlayer()
    local target = nil
    local closestDist = state.legit.fov
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        target = plr
                    end
                end
            end
        end
    end
    return target, closestDist
end

-- Silent Aim
local function SetupSilentAim()
    pcall(function()
        local mt = getrawmetatable(game)
        if mt then
            local oldIndex = mt.__index
            setreadonly(mt, false)
            mt.__index = function(self, key)
                if state.rage.silent and self == Mouse and key == "Hit" then
                    local target = GetClosestPlayer()
                    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                        return target.Character.HumanoidRootPart.CFrame
                    end
                end
                return oldIndex(self, key)
            end
            setreadonly(mt, true)
        end
    end)
end

-- Legit Aimbot
local aimbotConnection = nil
local function SetupLegitAimbot()
    if aimbotConnection then aimbotConnection:Disconnect() end
    
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not state.legit.aimbot then return end
        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
        
        local target, dist = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and dist <= state.legit.fov then
            local targetPos = target.Character.HumanoidRootPart.Position
            local currentCF = Camera.CFrame
            local newCF = CFrame.new(currentCF.Position, targetPos)
            local smoothness = state.legit.smoothness / 100
            Camera.CFrame = currentCF:Lerp(newCF, smoothness)
        end
    end)
    table.insert(connections, aimbotConnection)
end

-- Triggerbot
local function SetupTriggerbot()
    table.insert(connections, RunService.RenderStepped:Connect(function()
        if not state.triggerbot.enabled then return end
        local target = GetClosestPlayer()
        if target then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            task.wait(0.02)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
    end))
end

-- ========== FREECAM ==========
local function toggleFreeCam()
    isFreeCam = not isFreeCam
    state.misc.freecam = isFreeCam
    
    if isFreeCam then
        Camera.CameraType = Enum.CameraType.Scriptable
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            freecamBodyVelocity = Instance.new("BodyVelocity")
            freecamBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            freecamBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            freecamBodyVelocity.Parent = char.HumanoidRootPart
        end
    else
        Camera.CameraType = Enum.CameraType.Custom
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        
        if freecamBodyVelocity then freecamBodyVelocity:Destroy() end
        freecamBodyVelocity = nil
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F7 then toggleFreeCam() end
    
    if isFreeCam then
        if input.KeyCode == Enum.KeyCode.W then moveState.forward = 1 end
        if input.KeyCode == Enum.KeyCode.S then moveState.backward = 1 end
        if input.KeyCode == Enum.KeyCode.A then moveState.left = 1 end
        if input.KeyCode == Enum.KeyCode.D then moveState.right = 1 end
        if input.KeyCode == Enum.KeyCode.E then moveState.up = 1 end
        if input.KeyCode == Enum.KeyCode.Q then moveState.down = 1 end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then moveState.forward = 0 end
    if input.KeyCode == Enum.KeyCode.S then moveState.backward = 0 end
    if input.KeyCode == Enum.KeyCode.A then moveState.left = 0 end
    if input.KeyCode == Enum.KeyCode.D then moveState.right = 0 end
    if input.KeyCode == Enum.KeyCode.E then moveState.up = 0 end
    if input.KeyCode == Enum.KeyCode.Q then moveState.down = 0 end
end)

local function SetupFreeCam()
    table.insert(connections, RunService.RenderStepped:Connect(function()
        if not isFreeCam then return end
        
        local lookVector = Camera.CFrame.LookVector
        local rightVector = Camera.CFrame.RightVector
        local upVector = Vector3.new(0, 1, 0)
        
        local driveVector = (lookVector * (moveState.forward - moveState.backward)) +
                            (rightVector * (moveState.right - moveState.left)) +
                            (upVector * (moveState.up - moveState.down))
        
        if driveVector.Magnitude > 0 then
            Camera.CFrame = Camera.CFrame + (driveVector * camSpeed)
        end
    end))
    
    table.insert(connections, UserInputService.InputChanged:Connect(function(input)
        if isFreeCam and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Delta
            local yaw = -math.rad(delta.X * lookSensitivity)
            local pitch = -math.rad(delta.Y * lookSensitivity)
            Camera.CFrame = CFrame.new(Camera.CFrame.Position) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0)
        end
    end))
end

-- ========== FLY / NOCLIP / BHOP ==========
local function SetupFly()
    table.insert(connections, RunService.RenderStepped:Connect(function()
        if isFreeCam then return end
        if not state.misc.fly then
            if bodyVel then bodyVel:Destroy() end
            flyActive = false
            return
        end
        
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        
        if not flyActive then
            flyActive = true
            if bodyVel then bodyVel:Destroy() end
            bodyVel = Instance.new("BodyVelocity")
            bodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            bodyVel.Parent = root
        end
        
        local dir = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
        
        if dir.Magnitude > 0 then
            bodyVel.Velocity = dir.Unit * 70
        else
            bodyVel.Velocity = Vector3.new(0, 0, 0)
        end
    end))
end

local function SetupNoclip()
    table.insert(connections, RunService.Stepped:Connect(function()
        if isFreeCam then return end
        if not state.misc.noclip then return end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end))
end

local function SetupBHop()
    table.insert(connections, RunService.RenderStepped:Connect(function()
        if isFreeCam then return end
        if state.misc.bhop and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum and (UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.D)) and hum.FloorMaterial ~= Enum.Material.Air then
                hum.Jump = true
            end
        end
    end))
end

-- ========== CFG СИСТЕМА ==========
local function SaveConfig()
    local cfg = {
        rage = state.rage, legit = state.legit, triggerbot = state.triggerbot,
        visuals = state.visuals, misc = state.misc, theme = state.theme
    }
    writefile("SquadRim_Config.json", HttpService:JSONEncode(cfg))
    local notification = Instance.new("TextLabel")
    notification.Size = UDim2.new(0, 200, 0, 30)
    notification.Position = UDim2.new(0.5, -100, 0.4, 0)
    notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notification.BackgroundTransparency = 0.5
    notification.Text = "✅ Config Saved"
    notification.TextColor3 = Color3.fromRGB(0, 255, 0)
    notification.TextSize = 14
    notification.Font = Enum.Font.GothamBold
    notification.Parent = CoreGui
    task.wait(2)
    notification:Destroy()
end

local function LoadConfig()
    if isfile("SquadRim_Config.json") then
        local data = HttpService:JSONDecode(readfile("SquadRim_Config.json"))
        state.rage = data.rage or state.rage
        state.legit = data.legit or state.legit
        state.triggerbot = data.triggerbot or state.triggerbot
        state.visuals = data.visuals or state.visuals
        state.misc = data.misc or state.misc
        state.theme = data.theme or state.theme
        
        local notification = Instance.new("TextLabel")
        notification.Size = UDim2.new(0, 200, 0, 30)
        notification.Position = UDim2.new(0.5, -100, 0.4, 0)
        notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        notification.BackgroundTransparency = 0.5
        notification.Text = "✅ Config Loaded"
        notification.TextColor3 = Color3.fromRGB(0, 255, 0)
        notification.TextSize = 14
        notification.Font = Enum.Font.GothamBold
        notification.Parent = CoreGui
        task.wait(2)
        notification:Destroy()
        
        if UpdateBindsDisplay then UpdateBindsDisplay() end
    end
end

-- ========== HUD ==========
local HUD = Instance.new("TextLabel")
HUD.Size = UDim2.new(0, 500, 0, 25)
HUD.Position = UDim2.new(0.5, -250, 0.01, 0)
HUD.BackgroundTransparency = 0.6
HUD.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
HUD.TextColor3 = Color3.fromRGB(0, 255, 255)
HUD.TextScaled = true
HUD.Font = Enum.Font.GothamBold
HUD.Parent = CoreGui

local function UpdateHUD()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    local freecamStatus = isFreeCam and " [FREECAM]" or ""
    local authStatus = state.authorized and " 🔓" or " 🔒"
    HUD.Text = string.format("| t.me/squadrim1 | FREE | v%s | %d FPS |%s%s", state.version, fps, freecamStatus, authStatus)
end

-- ========== UNLOAD ==========
local function UnloadCheat()
    if isUnloaded then return end
    isUnloaded = true
    for _, conn in pairs(connections) do pcall(function() conn:Disconnect() end) end
    pcall(function() if screenGui then screenGui:Destroy() end end)
    pcall(function() if espFolder then espFolder:Destroy() end end)
    pcall(function() if HUD then HUD:Destroy() end end)
    pcall(function() if FOVCircle then FOVCircle:Remove() end end)
    pcall(function() if bodyVel then bodyVel:Destroy() end end)
    for _, player in pairs(Players:GetPlayers()) do Clean(player) end
    if Camera.CameraType == Enum.CameraType.Scriptable then
        Camera.CameraType = Enum.CameraType.Custom
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
    print("SQUADRIM DLC | UNLOADED")
end

-- ========== GUI МЕНЮ ==========
local screenGui = nil
local MainFrame = nil
local bindsDisplayFrame = nil
local isDraggingBinds = false
local dragStart = nil
local waitingForBind = nil
local binds = {}

local function ShowBindNotification(text, isError)
    local notification = Instance.new("TextLabel")
    notification.Size = UDim2.new(0, 300, 0, 35)
    notification.Position = UDim2.new(0.5, -150, 0.4, 0)
    notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notification.BackgroundTransparency = 0.5
    notification.Text = text
    notification.TextColor3 = isError and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
    notification.TextSize = 14
    notification.Font = Enum.Font.GothamBold
    notification.ZIndex = 20
    notification.Parent = CoreGui
    task.wait(2)
    notification:Destroy()
end

local function SaveBinds()
    local bindsData = {}
    for key, bindData in pairs(binds) do
        if bindData.key then
            bindsData[key] = {name = bindData.name, keyCode = bindData.key.Name}
        end
    end
    writefile("SquadRim_Binds.json", HttpService:JSONEncode(bindsData))
end

local function LoadBinds()
    if isfile("SquadRim_Binds.json") then
        local bindsData = HttpService:JSONDecode(readfile("SquadRim_Binds.json"))
        for _, bindData in pairs(bindsData) do
            if binds[bindData.name] then
                local keyCode = Enum.KeyCode[bindData.keyCode]
                if keyCode then
                    binds[bindData.name].key = keyCode
                end
            end
        end
        UpdateBindsDisplay()
    end
end

local function SetBind(bindName, keyCode)
    for _, existingBind in pairs(binds) do
        if existingBind.key == keyCode and existingBind.name ~= bindName then
            existingBind.key = nil
        end
    end
    binds[bindName].key = keyCode
    SaveBinds()
    ShowBindNotification("✅ " .. bindName .. " привязан к " .. keyCode.Name)
    UpdateBindsDisplay()
end

local function ClearBind(bindName)
    binds[bindName].key = nil
    SaveBinds()
    ShowBindNotification("❌ " .. bindName .. " отвязан")
    UpdateBindsDisplay()
end

local function UpdateBindsDisplay()
    if not bindsDisplayFrame then return end
    local text = "══════════ BINDS ══════════\n"
    for _, bind in pairs(binds) do
        if bind.key then
            text = text .. bind.name .. ": [" .. bind.key.Name .. "] " .. (bind.getter() and "✓" or "✗") .. "\n"
        end
    end
    if not next(binds) then
        text = text .. "No binds set\n"
    end
    text = text .. "══════════════════════════\n[RMB] to bind | [DEL] to unbind"
    bindsDisplayFrame.Text = text
end

local function CreateBindsDisplay()
    bindsDisplayFrame = Instance.new("TextLabel")
    bindsDisplayFrame.Size = UDim2.new(0, 220, 0, 200)
    bindsDisplayFrame.Position = UDim2.new(0.83, 0, 0.02, 0)
    bindsDisplayFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bindsDisplayFrame.BackgroundTransparency = 0.35
    bindsDisplayFrame.BorderSizePixel = 2
    bindsDisplayFrame.BorderColor3 = Color3.fromRGB(0, 200, 255)
    bindsDisplayFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
    bindsDisplayFrame.TextSize = 12
    bindsDisplayFrame.Font = Enum.Font.Gotham
    bindsDisplayFrame.TextXAlignment = Enum.TextXAlignment.Left
    bindsDisplayFrame.TextYAlignment = Enum.TextYAlignment.Top
    bindsDisplayFrame.TextWrapped = true
    bindsDisplayFrame.ZIndex = 10
    bindsDisplayFrame.Parent = CoreGui
    
    bindsDisplayFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingBinds = true
            dragStart = input.Position - Vector2.new(bindsDisplayFrame.AbsolutePosition.X, bindsDisplayFrame.AbsolutePosition.Y)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDraggingBinds and input.UserInputType == Enum.UserInputType.MouseMovement then
            local newPos = input.Position - dragStart
            bindsDisplayFrame.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
        end
    end)
    
    bindsDisplayFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDraggingBinds = false
        end
    end)
    
    bindsDisplayFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            local mousePos = Vector2.new(Mouse.X, Mouse.Y)
            local relativeY = mousePos.Y - bindsDisplayFrame.AbsolutePosition.Y - 20
            local lineIndex = math.floor(relativeY / 16) + 1
            local currentLine = 1
            for _, bind in pairs(binds) do
                if bind.key then
                    if currentLine == lineIndex then
                        waitingForBind = bind.name
                        ShowBindNotification("Нажми клавишу для " .. bind.name .. " (DEL для отвязки)", false)
                        break
                    end
                    currentLine = currentLine + 1
                end
            end
        end
    end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyType == Enum.KeyType.Key then
        local key = input.KeyCode
        
        if waitingForBind then
            local bindName = waitingForBind
            waitingForBind = nil
            if key == Enum.KeyCode.Delete then
                ClearBind(bindName)
            else
                SetBind(bindName, key)
            end
            return
        end
        
        for _, bind in pairs(binds) do
            if bind.key == key then
                bind.toggle(not bind.getter())
                ShowBindNotification("🔄 " .. bind.name .. " -> " .. (bind.getter() and "ON" or "OFF"))
                UpdateBindsDisplay()
                break
            end
        end
    end
end)

-- ========== СОЗДАНИЕ GUI ==========
local function CreateGUI()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SquadRim_Menu"
    screenGui.Parent = CoreGui
    screenGui.ResetOnSpawn = false
    
    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 520, 0, 600)
    MainFrame.Position = UDim2.new(0.5, -260, 0.5, -300)
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.BorderSizePixel = 1
    MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 100)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = screenGui
    MainFrame.Visible = state.menu
    
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = MainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "SQUADRIM DLC PRO v12.1"
    title.TextColor3 = Color3.fromRGB(0, 210, 255)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    local themeBtn = Instance.new("TextButton")
    themeBtn.Size = UDim2.new(0, 50, 0, 30)
    themeBtn.Position = UDim2.new(1, -60, 0, 5)
    themeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    themeBtn.Text = "🌙"
    themeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    themeBtn.TextSize = 16
    themeBtn.Parent = titleBar
    themeBtn.MouseButton1Click:Connect(function()
        state.theme = state.theme == "dark" and "light" or "dark"
        local bgColor = state.theme == "dark" and Color3.fromRGB(18, 18, 28) or Color3.fromRGB(235, 235, 245)
        MainFrame.BackgroundColor3 = bgColor
        themeBtn.Text = state.theme == "dark" and "🌙" or "☀️"
    end)
    
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, 0, 0, 35)
    tabBar.Position = UDim2.new(0, 0, 0, 40)
    tabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
    tabBar.BorderSizePixel = 0
    tabBar.Parent = MainFrame
    
    local tabs = {"VISUALS", "COMBAT", "RAGE", "MISC"}
    local containers = {}
    local tabButtons = {}
    
    for i, tabName in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.25, 0, 1, 0)
        btn.Position = UDim2.new((i-1)/4, 0, 0, 0)
        btn.BackgroundColor3 = i == 1 and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(25, 25, 38)
        btn.Text = tabName
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 13
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = tabBar
        tabButtons[tabName] = btn
        
        local container = Instance.new("ScrollingFrame")
        container.Size = UDim2.new(1, -20, 1, -90)
        container.Position = UDim2.new(0, 10, 0, 85)
        container.BackgroundTransparency = 1
        container.Visible = (i == 1)
        container.CanvasSize = UDim2.new(0, 0, 0, 500)
        container.ScrollBarThickness = 4
        container.Parent = MainFrame
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 8)
        layout.Parent = container
        containers[tabName] = container
        
        btn.MouseButton1Click:Connect(function()
            for _, t in pairs(tabs) do
                tabButtons[t].BackgroundColor3 = t == tabName and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(25, 25, 38)
                containers[t].Visible = (t == tabName)
            end
        end)
    end
    
    local function MakeCard(parent)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 38)
        card.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
        card.BackgroundTransparency = 0.2
        card.BorderSizePixel = 0
        card.Parent = parent
        return card
    end
    
    local function MakeToggle(parent, text, getter, setter, bindName)
        local card = MakeCard(parent)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.5, 0, 1, 0)
        label.Position = UDim2.new(0.02, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = card
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 55, 0, 28)
        btn.Position = UDim2.new(0.7, 0, 0.13, 0)
        btn.BackgroundColor3 = getter() and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(70, 70, 85)
        btn.Text = getter() and "ON" or "OFF"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 12
        btn.Font = Enum.Font.GothamBold
        btn.Parent = card
        
        if bindName then
            local bindBtn = Instance.new("TextButton")
            bindBtn.Size = UDim2.new(0, 40, 0, 28)
            bindBtn.Position = UDim2.new(0.88, 0, 0.13, 0)
            bindBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            bindBtn.Text = "🔗"
            bindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            bindBtn.TextSize = 14
            bindBtn.Parent = card
            
            binds[bindName] = {
                name = bindName, getter = getter, toggle = setter,
                key = nil, btn = bindBtn
            }
            
            bindBtn.MouseButton1Click:Connect(function()
                waitingForBind = bindName
                ShowBindNotification("Нажми клавишу для " .. bindName, false)
            end)
        end
        
        btn.MouseButton1Click:Connect(function()
            local newVal = not getter()
            setter(newVal)
            btn.BackgroundColor3 = newVal and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(70, 70, 85)
            btn.Text = newVal and "ON" or "OFF"
            UpdateBindsDisplay()
        end)
    end
    
    local function MakeSlider(parent, text, min, max, getter, setter)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 55)
        card.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
        card.BackgroundTransparency = 0.2
        card.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Position = UDim2.new(0.02, 0, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. getter()
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextSize = 12
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = card
        
        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(0.7, 0, 0, 4)
        slider.Position = UDim2.new(0.02, 0, 0, 35)
        slider.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
        slider.Parent = card
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((getter() - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(0, 180, 200)
        fill.Parent = slider
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0, 40, 0, 20)
        valueLabel.Position = UDim2.new(0.8, 0, 0, 30)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(getter())
        valueLabel.TextColor3 = Color3.fromRGB(0, 210, 255)
        valueLabel.TextSize = 12
        valueLabel.Font = Enum.Font.GothamBold
        valueLabel.Parent = card
        
        local dragging = false
        local function update(inputPos)
            local percent = math.clamp((inputPos - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * percent)
            setter(val)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            label.Text = text .. ": " .. val
            valueLabel.Text = tostring(val)
        end
        
        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                update(input.Position.X)
            end
        end)
        slider.InputEnded:Connect(function() dragging = false end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                update(input.Position.X)
            end
        end)
    end
    
    local function MakeDropdown(parent, text, options, getter, setter)
        local card = MakeCard(parent)
        card.Size = UDim2.new(1, 0, 0, 45)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.5, 0, 1, 0)
        label.Position = UDim2.new(0.02, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.TextSize = 12
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = card
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 100, 0, 30)
        btn.Position = UDim2.new(0.7, 0, 0.16, 0)
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
        btn.Text = getter()
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 12
        btn.Parent = card
        
        local dropdownOpen = false
        local dropdownFrame = nil
        
        btn.MouseButton1Click:Connect(function()
            if dropdownOpen then
                if dropdownFrame then dropdownFrame:Destroy() end
                dropdownOpen = false
                return
            end
            
            dropdownFrame = Instance.new("Frame")
            dropdownFrame.Size = UDim2.new(0, 100, 0, 28 * #options)
            dropdownFrame.Position = UDim2.new(0.7, 0, 0, 38)
            dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            dropdownFrame.Parent = card
            
            for _, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 26)
                optBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
                optBtn.Text = opt
                optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                optBtn.TextSize = 11
                optBtn.Parent = dropdownFrame
                
                optBtn.MouseButton1Click:Connect(function()
                    setter(opt)
                    btn.Text = opt
                    dropdownFrame:Destroy()
                    dropdownOpen = false
                end)
            end
            dropdownOpen = true
        end)
    end
    
    -- VISUALS TAB
    MakeToggle(containers["VISUALS"], "ESP Enabled", function() return state.visuals.enabled end, function(v) state.visuals.enabled = v end, "ESP")
    MakeToggle(containers["VISUALS"], "Box ESP", function() return state.visuals.box end, function(v) state.visuals.box = v end, "Box")
    MakeToggle(containers["VISUALS"], "Name", function() return state.visuals.name end, function(v) state.visuals.name = v end, "Name")
    MakeToggle(containers["VISUALS"], "Tracers", function() return state.visuals.tracers end, function(v) state.visuals.tracers = v end, "Tracers")
    MakeToggle(containers["VISUALS"], "Health Bar", function() return state.visuals.health end, function(v) state.visuals.health = v end, "Health")
    MakeToggle(containers["VISUALS"], "Distance", function() return state.visuals.distance end, function(v) state.visuals.distance = v end, "Distance")
    MakeToggle(containers["VISUALS"], "Chams", function() return state.visuals.chams end, function(v) state.visuals.chams = v end, "Chams")
    MakeDropdown(containers["VISUALS"], "Tracer Origin", {"Bottom", "Middle"}, function() return state.visuals.tracerOrigin end, function(v) state.visuals.tracerOrigin = v end)
    
    -- COMBAT TAB
    MakeToggle(containers["COMBAT"], "Legit Aimbot", function() return state.legit.aimbot end, function(v) state.legit.aimbot = v; SetupLegitAimbot() end, "Aimbot")
    MakeSlider(containers["COMBAT"], "Aimbot FOV", 30, 300, function() return state.legit.fov end, function(v) state.legit.fov = v end)
    MakeSlider(containers["COMBAT"], "Smoothness", 1, 30, function() return state.legit.smoothness end, function(v) state.legit.smoothness = v end)
    MakeToggle(containers["COMBAT"], "Triggerbot", function() return state.triggerbot.enabled end, function(v) state.triggerbot.enabled = v end, "Trigger")
    
    -- RAGE TAB
    MakeToggle(containers["RAGE"], "Silent Aim", function() return state.rage.silent end, function(v) state.rage.silent = v end, "Silent")
    MakeSlider(containers["RAGE"], "Silent FOV", 30, 300, function() return state.rage.fov end, function(v) state.rage.fov = v end)
    
    -- MISC TAB
    MakeToggle(containers["MISC"], "FreeCam (F7)", function() return state.misc.freecam end, function(v) if v then toggleFreeCam() end end, "FreeCam")
    MakeToggle(containers["MISC"], "Fly Mode", function() return state.misc.fly end, function(v) state.misc.fly = v end, "Fly")
    MakeToggle(containers["MISC"], "Noclip", function() return state.misc.noclip end, function(v) state.misc.noclip = v end, "Noclip")
    MakeToggle(containers["MISC"], "Bunny Hop", function() return state.misc.bhop end, function(v) state.misc.bhop = v end, "BHop")
    
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.45, 0, 0, 35)
    saveBtn.Position = UDim2.new(0.02, 0, 0, 0)
    saveBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    saveBtn.Text = "💾 SAVE CONFIG"
    saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveBtn.TextSize = 12
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.Parent = containers["MISC"]
    saveBtn.MouseButton1Click:Connect(SaveConfig)
    
    local loadBtn = Instance.new("TextButton")
    loadBtn.Size = UDim2.new(0.45, 0, 0, 35)
    loadBtn.Position = UDim2.new(0.53, 0, 0, 0)
    loadBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    loadBtn.Text = "📂 LOAD CONFIG"
    loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadBtn.TextSize = 12
    loadBtn.Font = Enum.Font.GothamBold
    loadBtn.Parent = containers["MISC"]
    loadBtn.MouseButton1Click:Connect(LoadConfig)
    
    local unloadBtn = Instance.new("TextButton")
    unloadBtn.Size = UDim2.new(0.9, 0, 0, 35)
    unloadBtn.Position = UDim2.new(0.05, 0, 0, 45)
    unloadBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    unloadBtn.Text = "⚠️ UNLOAD CHEAT (END) ⚠️"
    unloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    unloadBtn.TextSize = 13
    unloadBtn.Font = Enum.Font.GothamBold
    unloadBtn.Parent = containers["MISC"]
    unloadBtn.MouseButton1Click:Connect(UnloadCheat)
end

-- ========== КЛЮЧ ==========
local function ShowKeySystem()
    local loginFrame = Instance.new("Frame")
    loginFrame.Size = UDim2.new(0, 400, 0, 250)
    loginFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
    loginFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    loginFrame.BackgroundTransparency = 0.05
    loginFrame.BorderSizePixel = 2
    loginFrame.BorderColor3 = Color3.fromRGB(0, 200, 255)
    loginFrame.ZIndex = 999
    loginFrame.Parent = CoreGui
    
    local loginCorner = Instance.new("UICorner")
    loginCorner.CornerRadius = UDim.new(0, 15)
    loginCorner.Parent = loginFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    title.Text = "SQUADRIM DLC PRO"
    title.TextColor3 = Color3.fromRGB(0, 210, 255)
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.Parent = loginFrame
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 30)
    subtitle.Position = UDim2.new(0, 0, 0, 45)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Введите ключ для активации"
    subtitle.TextColor3 = Color3.fromRGB(220, 220, 220)
    subtitle.TextSize = 14
    subtitle.Font = Enum.Font.Gotham
    subtitle.Parent = loginFrame
    
    local loginTextBox = Instance.new("TextBox")
    loginTextBox.Size = UDim2.new(0.8, 0, 0, 45)
    loginTextBox.Position = UDim2.new(0.1, 0, 0, 85)
    loginTextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    loginTextBox.Text = ""
    loginTextBox.PlaceholderText = "Введите ключ"
    loginTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    loginTextBox.TextSize = 16
    loginTextBox.Font = Enum.Font.Gotham
    loginTextBox.Parent = loginFrame
    
    local textBoxCorner = Instance.new("UICorner")
    textBoxCorner.CornerRadius = UDim.new(0, 10)
    textBoxCorner.Parent = loginTextBox
    
    local submitBtn = Instance.new("TextButton")
    submitBtn.Size = UDim2.new(0.35, 0, 0, 40)
    submitBtn.Position = UDim2.new(0.1, 0, 0, 145)
    submitBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    submitBtn.Text = "▶ ВОЙТИ"
    submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitBtn.TextSize = 16
    submitBtn.Font = Enum.Font.GothamBold
    submitBtn.Parent = loginFrame
    
    local submitCorner = Instance.new("UICorner")
    submitCorner.CornerRadius = UDim.new(0, 10)
    submitCorner.Parent = submitBtn
    
    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Size = UDim2.new(0.35, 0, 0, 40)
    getKeyBtn.Position = UDim2.new(0.55, 0, 0, 145)
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    getKeyBtn.Text = "🔑 ПОЛУЧИТЬ КЛЮЧ"
    getKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    getKeyBtn.TextSize = 14
    getKeyBtn.Font = Enum.Font.GothamBold
    getKeyBtn.Parent = loginFrame
    
    local getKeyCorner = Instance.new("UICorner")
    getKeyCorner.CornerRadius = UDim.new(0, 10)
    getKeyCorner.Parent = getKeyBtn
    
    getKeyBtn.MouseButton1Click:Connect(function()
        Clipboard:set("t.me/squadrim1")
        local notification = Instance.new("TextLabel")
        notification.Size = UDim2.new(0, 250, 0, 35)
        notification.Position = UDim2.new(0.5, -125, 0.7, 0)
        notification.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        notification.BackgroundTransparency = 0.5
        notification.Text = "✅ Ссылка скопирована: t.me/squadrim1"
        notification.TextColor3 = Color3.fromRGB(0, 255, 0)
        notification.TextSize = 14
        notification.Font = Enum.Font.Gotham
        notification.Parent = loginFrame
        task.wait(2)
        notification:Destroy()
    end)
    
    submitBtn.MouseButton1Click:Connect(function()
        local enteredKey = loginTextBox.Text
        if enteredKey == "SquadRim2024" or enteredKey == "freekey" or enteredKey == "squadrim" then
            state.authorized = true
            loginFrame:Destroy()
            StartCheat()
        else
            loginTextBox.Text = ""
            loginTextBox.PlaceholderText = "Неверный ключ!"
            loginTextBox.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
            task.wait(1)
            loginTextBox.PlaceholderText = "Введите ключ"
            loginTextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        end
    end)
end

-- ========== ЗАПУСК ЧИТА ПОСЛЕ АВТОРИЗАЦИИ ==========
local function StartCheat()
    CreateGUI()
    pcall(SetupSilentAim)
    SetupLegitAimbot()
    SetupTriggerbot()
    SetupFreeCam()
    SetupFly()
    SetupNoclip()
    SetupBHop()
    LoadBinds()
    CreateBindsDisplay()
    
    table.insert(connections, RunService.RenderStepped:Connect(function()
        UpdateESP()
        UpdateHUD()
        
        FOVCircle.Visible = state.legit.aimbot and not isFreeCam
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
        FOVCircle.Radius = state.legit.fov
        FOVCircle.Color = state.theme == "dark" and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(200, 0, 0)
    end))
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            state.menu = not state.menu
            MainFrame.Visible = state.menu
        elseif input.KeyCode == Enum.KeyCode.End then
            UnloadCheat()
        end
    end)
    
    print("SQUADRIM DLC PRO v12.1 | FULLY LOADED")
    print("Insert = Menu | F7 = FreeCam | End = UNLOAD")
end

-- ========== ЗАПУСК ==========
ShowKeySystem()
