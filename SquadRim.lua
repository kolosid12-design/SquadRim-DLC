-- SWILL | SquadRim DLC PRO | v14.0 | ВСЁ ИСПРАВЛЕНО
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

-- ========== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ==========
local function CopyToClipboard(text)
    if setclipboard then setclipboard(text) elseif toclipboard then toclipboard(text) end
end

local function ShowNotification(text, isError)
    local notification = Instance.new("TextLabel")
    notification.Size = UDim2.new(0, 300, 0, 35)
    notification.Position = UDim2.new(0.5, -150, 0.2, 0)
    notification.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    notification.BackgroundTransparency = 0.2
    notification.BorderSizePixel = 0
    notification.Text = text
    notification.TextColor3 = isError and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 255, 80)
    notification.TextSize = 14
    notification.Font = Enum.Font.SourceSansBold
    notification.Parent = CoreGui
    Instance.new("UICorner", notification).CornerRadius = UDim.new(0, 8)
    task.delay(2, notification.Destroy)
end

-- ========== ПЕРЕМЕННЫЕ ==========
local state = {
    menu = true,
    version = "1.0",
    theme = "dark",
    rage = {silent = false, fov = 150},
    legit = {aimbot = false, fov = 150, smoothness = 8},
    triggerbot = {enabled = false},
    visuals = {enabled = true, box = true, name = true, tracers = true, health = true, distance = true, chams = true, tracerOrigin = "Bottom"},
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

-- ========== ESP ==========
local Storage = {}
local espFolder = Instance.new("Folder", CoreGui)
espFolder.Name = "SquadRim_ESP"

local function Clean(player)
    if Storage[player] then
        for _, obj in pairs(Storage[player]) do
            pcall(function() if typeof(obj) == "Instance" then obj:Destroy() else obj:Remove() end end)
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
    if not state.visuals.enabled then return end
    
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
                local x, y = pos.X - sizeX/2, pos.Y - sizeY/2
                
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
                s.Tracer.From = state.visuals.tracerOrigin == "Bottom" and Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y) or Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                s.Tracer.To = Vector2.new(pos.X, pos.Y + sizeY/2)
                
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

-- ========== AIMBOT (НАВОДКА НА ГОЛОВУ) ==========
local function GetClosestPlayer()
    local target = nil
    local closestDist = state.legit.fov
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            local hum = plr.Character:FindFirstChild("Humanoid")
            if head and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
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
    return target
end

-- Silent Aim
pcall(function()
    local mt = getrawmetatable(game)
    if mt then
        local oldIndex = mt.__index
        setreadonly(mt, false)
        mt.__index = function(self, key)
            if state.rage.silent and self == Mouse and key == "Hit" then
                local target = GetClosestPlayer()
                if target and target.Character and target.Character:FindFirstChild("Head") then
                    return target.Character.Head.CFrame
                end
            end
            return oldIndex(self, key)
        end
        setreadonly(mt, true)
    end
end)

-- Legit Aimbot (на голову)
local function SetupLegitAimbot()
    table.insert(connections, RunService.RenderStepped:Connect(function()
        if state.legit.aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = GetClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local targetPos = target.Character.Head.Position
                local currentCF = Camera.CFrame
                local newCF = CFrame.new(currentCF.Position, targetPos)
                Camera.CFrame = currentCF:Lerp(newCF, state.legit.smoothness / 100)
            end
        end
    end))
end

-- Triggerbot
local function SetupTriggerbot()
    table.insert(connections, RunService.RenderStepped:Connect(function()
        if state.triggerbot.enabled then
            local target = GetClosestPlayer()
            if target then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.02)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
        end
    end))
end

-- ========== FREECAM ==========
local function toggleFreeCam()
    isFreeCam = not isFreeCam
    if isFreeCam then
        Camera.CameraType = Enum.CameraType.Scriptable
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            freecamBodyVelocity = Instance.new("BodyVelocity")
            freecamBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            freecamBodyVelocity.Parent = char.HumanoidRootPart
        end
    else
        Camera.CameraType = Enum.CameraType.Custom
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        if freecamBodyVelocity then freecamBodyVelocity:Destroy() end
        freecamBodyVelocity = nil
    end
end

UserInputService.InputBegan:Connect(function(input)
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
            Camera.CFrame = CFrame.new(Camera.CFrame.Position) * CFrame.Angles(0, -math.rad(delta.X * lookSensitivity), 0) * CFrame.Angles(-math.rad(delta.Y * lookSensitivity), 0, 0)
        end
    end))
end

-- ========== FLY ==========
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
        bodyVel.Velocity = dir.Magnitude > 0 and dir.Unit * 70 or Vector3.new(0, 0, 0)
    end))
end

-- ========== NOCLIP ==========
local function SetupNoclip()
    table.insert(connections, RunService.Stepped:Connect(function()
        if isFreeCam then return end
        if not state.misc.noclip then return end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end))
end

-- ========== BUNNY HOP ==========
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

-- ========== CFG ==========
local function SaveConfig()
    writefile("SquadRim_Config.json", HttpService:JSONEncode({
        rage = state.rage, legit = state.legit, triggerbot = state.triggerbot,
        visuals = state.visuals, misc = state.misc, theme = state.theme
    }))
    ShowNotification("✅ Конфиг сохранён", false)
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
        ShowNotification("✅ Конфиг загружен", false)
    end
end

-- ========== HUD ==========
local HUD = Instance.new("TextLabel")
HUD.Size = UDim2.new(0, 550, 0, 25)
HUD.Position = UDim2.new(0.5, -275, 0.01, 0)
HUD.BackgroundTransparency = 0.6
HUD.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
HUD.TextColor3 = Color3.fromRGB(0, 255, 255)
HUD.TextScaled = true
HUD.Font = Enum.Font.SourceSansBold
HUD.Parent = CoreGui

local function UpdateHUD()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    HUD.Text = string.format("| t.me/squadrim1 | FREE | v%s | %d FPS |", state.version, fps)
end

-- ========== UNLOAD ==========
local function UnloadCheat()
    if isUnloaded then return end
    isUnloaded = true
    for _, conn in pairs(connections) do pcall(conn.Disconnect) end
    pcall(function() if screenGui then screenGui:Destroy() end end)
    pcall(function() espFolder:Destroy() end)
    pcall(function() HUD:Destroy() end)
    pcall(function() FOVCircle:Remove() end)
    pcall(function() if bodyVel then bodyVel:Destroy() end end)
    for _, player in pairs(Players:GetPlayers()) do Clean(player) end
    if Camera.CameraType == Enum.CameraType.Scriptable then
        Camera.CameraType = Enum.CameraType.Custom
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
    print("UNLOADED")
end

-- ========== GUI МЕНЮ ==========
local screenGui = nil
local MainFrame = nil
local binds = {}
local waitingForBind = nil

local function UpdateBindsDisplay()
    -- функция обновления отображения биндов
end

local function CreateBindsDisplay()
    -- функция создания панели биндов
end

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
    MainFrame.Visible = true
    
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    titleBar.Parent = MainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 0, 40)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "SQUADRIM DLC PRO v14.0"
    title.TextColor3 = Color3.fromRGB(0, 210, 255)
    title.TextSize = 18
    title.Font = Enum.Font.SourceSansBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    local themeBtn = Instance.new("TextButton")
    themeBtn.Size = UDim2.new(0, 50, 0, 30)
    themeBtn.Position = UDim2.new(1, -60, 0, 5)
    themeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    themeBtn.Text = "🌙"
    themeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    themeBtn.Font = Enum.Font.SourceSansBold
    themeBtn.Parent = titleBar
    themeBtn.MouseButton1Click:Connect(function()
        state.theme = state.theme == "dark" and "light" or "dark"
        MainFrame.BackgroundColor3 = state.theme == "dark" and Color3.fromRGB(18, 18, 28) or Color3.fromRGB(235, 235, 245)
    end)
    
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, 0, 0, 35)
    tabBar.Position = UDim2.new(0, 0, 0, 40)
    tabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
    tabBar.Parent = MainFrame
    
    local tabs = {"VISUALS", "COMBAT", "RAGE", "MISC"}
    local containers = {}
    
    for i, tabName in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.25, 0, 1, 0)
        btn.Position = UDim2.new((i-1)/4, 0, 0, 0)
        btn.BackgroundColor3 = i == 1 and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(25, 25, 38)
        btn.Text = tabName
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.SourceSansBold
        btn.BorderSizePixel = 0
        btn.Parent = tabBar
        
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
                containers[t].Visible = (t == tabName)
            end
            for _, b in pairs(tabBar:GetChildren()) do
                if b:IsA("TextButton") then
                    b.BackgroundColor3 = b.Text == tabName and Color3.fromRGB(0, 150, 200) or Color3.fromRGB(25, 25, 38)
                end
            end
        end)
    end
    
    local function MakeCard(parent)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 38)
        card.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
        card.BackgroundTransparency = 0.2
        card.Parent = parent
        return card
    end
    
    local function MakeToggle(parent, text, getter, setter, bindName)
        local card = MakeCard(parent)
        
        Instance.new("TextLabel", card).Then(function(l)
            l.Size = UDim2.new(0.5, 0, 1, 0)
            l.Position = UDim2.new(0.02, 0, 0, 0)
            l.BackgroundTransparency = 1
            l.Text = text
            l.TextColor3 = Color3.fromRGB(220, 220, 220)
            l.TextSize = 13
            l.Font = Enum.Font.SourceSans
            l.TextXAlignment = Enum.TextXAlignment.Left
        end)
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 55, 0, 28)
        btn.Position = UDim2.new(0.7, 0, 0.13, 0)
        btn.BackgroundColor3 = getter() and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(70, 70, 85)
        btn.Text = getter() and "ON" or "OFF"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.SourceSansBold
        btn.Parent = card
        
        if bindName then
            local bindBtn = Instance.new("TextButton")
            bindBtn.Size = UDim2.new(0, 40, 0, 28)
            bindBtn.Position = UDim2.new(0.88, 0, 0.13, 0)
            bindBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            bindBtn.Text = "🔗"
            bindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            bindBtn.Font = Enum.Font.SourceSansBold
            bindBtn.Parent = card
            
            binds[bindName] = {name = bindName, getter = getter, toggle = setter, key = nil, btn = bindBtn}
            
            bindBtn.MouseButton1Click:Connect(function()
                waitingForBind = bindName
                ShowNotification("Нажми клавишу для " .. bindName, false)
            end)
        end
        
        btn.MouseButton1Click:Connect(function()
            local newVal = not getter()
            setter(newVal)
            btn.BackgroundColor3 = newVal and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(70, 70, 85)
            btn.Text = newVal and "ON" or "OFF"
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
        label.Font = Enum.Font.SourceSans
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
        valueLabel.Font = Enum.Font.SourceSansBold
        valueLabel.Parent = card
        
        local dragging = false
        slider.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
        end)
        slider.InputEnded:Connect(function() dragging = false end)
        slider.MouseMoved:Connect(function()
            if dragging then
                local percent = math.clamp((Mouse.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * percent)
                setter(val)
                fill.Size = UDim2.new(percent, 0, 1, 0)
                label.Text = text .. ": " .. val
                valueLabel.Text = tostring(val)
            end
        end)
    end
    
    local function MakeDropdown(parent, text, options, getter, setter)
        local card = MakeCard(parent)
        card.Size = UDim2.new(1, 0, 0, 45)
        
        Instance.new("TextLabel", card).Then(function(l)
            l.Size = UDim2.new(0.5, 0, 1, 0)
            l.Position = UDim2.new(0.02, 0, 0, 0)
            l.BackgroundTransparency = 1
            l.Text = text
            l.TextColor3 = Color3.fromRGB(220, 220, 220)
            l.TextSize = 12
            l.Font = Enum.Font.SourceSans
            l.TextXAlignment = Enum.TextXAlignment.Left
        end)
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 100, 0, 30)
        btn.Position = UDim2.new(0.7, 0, 0.16, 0)
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
        btn.Text = getter()
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.SourceSansBold
        btn.Parent = card
        
        btn.MouseButton1Click:Connect(function()
            local dropdown = Instance.new("Frame")
            dropdown.Size = UDim2.new(0, 100, 0, 28 * #options)
            dropdown.Position = UDim2.new(0.7, 0, 0, 38)
            dropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
            dropdown.Parent = card
            
            for _, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 26)
                optBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
                optBtn.Text = opt
                optBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                optBtn.Font = Enum.Font.SourceSans
                optBtn.Parent = dropdown
                optBtn.MouseButton1Click:Connect(function()
                    setter(opt)
                    btn.Text = opt
                    dropdown:Destroy()
                end)
            end
        end)
    end
    
    -- VISUALS
    MakeToggle(containers["VISUALS"], "ESP Enabled", function() return state.visuals.enabled end, function(v) state.visuals.enabled = v end, "ESP")
    MakeToggle(containers["VISUALS"], "Box ESP", function() return state.visuals.box end, function(v) state.visuals.box = v end, "Box")
    MakeToggle(containers["VISUALS"], "Name", function() return state.visuals.name end, function(v) state.visuals.name = v end, "Name")
    MakeToggle(containers["VISUALS"], "Tracers", function() return state.visuals.tracers end, function(v) state.visuals.tracers = v end, "Tracers")
    MakeToggle(containers["VISUALS"], "Health Bar", function() return state.visuals.health end, function(v) state.visuals.health = v end, "Health")
    MakeToggle(containers["VISUALS"], "Distance", function() return state.visuals.distance end, function(v) state.visuals.distance = v end, "Distance")
    MakeToggle(containers["VISUALS"], "Chams", function() return state.visuals.chams end, function(v) state.visuals.chams = v end, "Chams")
    MakeDropdown(containers["VISUALS"], "Tracer Origin", {"Bottom", "Middle"}, function() return state.visuals.tracerOrigin end, function(v) state.visuals.tracerOrigin = v end)
    
    -- COMBAT
    MakeToggle(containers["COMBAT"], "Legit Aimbot (Head)", function() return state.legit.aimbot end, function(v) state.legit.aimbot = v end, "Aimbot")
    MakeSlider(containers["COMBAT"], "Aimbot FOV", 30, 300, function() return state.legit.fov end, function(v) state.legit.fov = v end)
    MakeSlider(containers["COMBAT"], "Smoothness", 1, 30, function() return state.legit.smoothness end, function(v) state.legit.smoothness = v end)
    MakeToggle(containers["COMBAT"], "Triggerbot", function() return state.triggerbot.enabled end, function(v) state.triggerbot.enabled = v end, "Trigger")
    
    -- RAGE
    MakeToggle(containers["RAGE"], "Silent Aim", function() return state.rage.silent end, function(v) state.rage.silent = v end, "Silent")
    MakeSlider(containers["RAGE"], "Silent FOV", 30, 300, function() return state.rage.fov end, function(v) state.rage.fov = v end)
    
    -- MISC
    MakeToggle(containers["MISC"], "Fly Mode", function() return state.misc.fly end, function(v) state.misc.fly = v end, "Fly")
    MakeToggle(containers["MISC"], "Noclip", function() return state.misc.noclip end, function(v) state.misc.noclip = v end, "Noclip")
    MakeToggle(containers["MISC"], "Bunny Hop", function() return state.misc.bhop end, function(v) state.misc.bhop = v end, "BHop")
    
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.45, 0, 0, 35)
    saveBtn.Position = UDim2.new(0.02, 0, 0, 0)
    saveBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    saveBtn.Text = "💾 SAVE CONFIG"
    saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    saveBtn.Font = Enum.Font.SourceSansBold
    saveBtn.Parent = containers["MISC"]
    saveBtn.MouseButton1Click:Connect(SaveConfig)
    
    local loadBtn = Instance.new("TextButton")
    loadBtn.Size = UDim2.new(0.45, 0, 0, 35)
    loadBtn.Position = UDim2.new(0.53, 0, 0, 0)
    loadBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    loadBtn.Text = "📂 LOAD CONFIG"
    loadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadBtn.Font = Enum.Font.SourceSansBold
    loadBtn.Parent = containers["MISC"]
    loadBtn.MouseButton1Click:Connect(LoadConfig)
    
    local unloadBtn = Instance.new("TextButton")
    unloadBtn.Size = UDim2.new(0.9, 0, 0, 35)
    unloadBtn.Position = UDim2.new(0.05, 0, 0, 45)
    unloadBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    unloadBtn.Text = "⚠️ UNLOAD (END) ⚠️"
    unloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    unloadBtn.Font = Enum.Font.SourceSansBold
    unloadBtn.Parent = containers["MISC"]
    unloadBtn.MouseButton1Click:Connect(UnloadCheat)
end

-- ========== БИНДЫ ==========
UserInputService.InputBegan:Connect(function(input)
    if input.KeyType == Enum.KeyType.Key then
        if waitingForBind then
            if input.KeyCode == Enum.KeyCode.Delete then
                if binds[waitingForBind] then binds[waitingForBind].key = nil end
                ShowNotification("❌ " .. waitingForBind .. " отвязан", false)
            else
                for _, b in pairs(binds) do if b.key == input.KeyCode then b.key = nil end end
                if binds[waitingForBind] then binds[waitingForBind].key = input.KeyCode end
                ShowNotification("✅ " .. waitingForBind .. " -> " .. input.KeyCode.Name, false)
            end
            waitingForBind = nil
            return
        end
        
        for _, bind in pairs(binds) do
            if bind.key == input.KeyCode then
                bind.toggle(not bind.getter())
                ShowNotification("🔄 " .. bind.name .. " -> " .. (bind.getter() and "ON" or "OFF"), false)
                break
            end
        end
    end
end)

-- ========== АВТОРИЗАЦИЯ ==========
local function ShowAuth()
    local authGui = Instance.new("ScreenGui")
    authGui.Name = "SquadRim_Auth"
    authGui.Parent = CoreGui
    authGui.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 250)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -125)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(0, 200, 255)
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = authGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    title.Text = "SQUADRIM DLC PRO"
    title.TextColor3 = Color3.fromRGB(0, 210, 255)
    title.TextSize = 22
    title.Font = Enum.Font.SourceSansBold
    title.Parent = mainFrame
    title.TextScaled = true

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 25)
    subtitle.Position = UDim2.new(0, 0, 0, 50)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Введите ключ для активации"
    subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    subtitle.TextSize = 14
    subtitle.Font = Enum.Font.SourceSans
    subtitle.Parent = mainFrame

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.8, 0, 0, 40)
    textBox.Position = UDim2.new(0.1, 0, 0, 85)
    textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    textBox.PlaceholderText = "Введите ключ"
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 16
    textBox.Font = Enum.Font.SourceSans
    textBox.Parent = mainFrame
    Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 8)

    local loginBtn = Instance.new("TextButton")
    loginBtn.Size = UDim2.new(0.35, 0, 0, 38)
    loginBtn.Position = UDim2.new(0.1, 0, 0, 140)
    loginBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    loginBtn.Text = "ВОЙТИ"
    loginBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    loginBtn.Font = Enum.Font.SourceSansBold
    loginBtn.Parent = mainFrame
    Instance.new("UICorner", loginBtn).CornerRadius = UDim.new(0, 8)

    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Size = UDim2.new(0.35, 0, 0, 38)
    getKeyBtn.Position = UDim2.new(0.55, 0, 0, 140)
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    getKeyBtn.Text = "ПОЛУЧИТЬ"
    getKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    getKeyBtn.Font = Enum.Font.SourceSansBold
    getKeyBtn.Parent = mainFrame
    Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 8)

    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, 0, 0, 25)
    infoText.Position = UDim2.new(0, 0, 0, 190)
    infoText.BackgroundTransparency = 1
    infoText.Text = "Бесплатный ключ: SquadRim2024"
    infoText.TextColor3 = Color3.fromRGB(150, 150, 180)
    infoText.TextSize = 12
    infoText.Font = Enum.Font.SourceSans
    infoText.Parent = mainFrame

    getKeyBtn.MouseButton1Click:Connect(function()
        CopyToClipboard("t.me/squadrim1")
        ShowNotification("✅ Ссылка скопирована!", false)
    end)

    loginBtn.MouseButton1Click:Connect(function()
        local key = textBox.Text
        if key == "SquadRim2024" or key == "freekey" or key == "squadrim" then
            authGui:Destroy()
            ShowNotification("✅ Авторизация успешна!", false)
            CreateGUI()
            SetupLegitAimbot()
            SetupTriggerbot()
            SetupFreeCam()
            SetupFly()
            SetupNoclip()
            SetupBHop()
            
            table.insert(connections, RunService.RenderStepped:Connect(function()
                UpdateESP()
                UpdateHUD()
                FOVCircle.Visible = state.legit.aimbot and not isFreeCam
                FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
                FOVCircle.Radius = state.legit.fov
            end))
            
            UserInputService.InputBegan:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.Insert then
                    state.menu = not state.menu
                    if MainFrame then MainFrame.Visible = state.menu end
                elseif input.KeyCode == Enum.KeyCode.End then
                    UnloadCheat()
                end
            end)
            
            print("=== SQUADRIM DLC PRO v14.0 ЗАПУЩЕН ===")
            print("Insert = Меню | F7 = FreeCam | End = UNLOAD")
        else
            textBox.Text = ""
            textBox.PlaceholderText = "НЕВЕРНЫЙ КЛЮЧ!"
            textBox.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
            ShowNotification("❌ Неверный ключ!", true)
            task.wait(1.5)
            textBox.PlaceholderText = "Введите ключ"
            textBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        end
    end)
end

ShowAuth()
