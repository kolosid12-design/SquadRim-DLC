-- SWILL | SquadRim DLC | v16.0 | ТОЛЬКО НУЖНЫЕ ФУНКЦИИ
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
    notification.Size = UDim2.new(0, 280, 0, 30)
    notification.Position = UDim2.new(0.5, -140, 0.2, 0)
    notification.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    notification.BackgroundTransparency = 0.2
    notification.BorderSizePixel = 1
    notification.BorderColor3 = Color3.fromRGB(255, 50, 50)
    notification.Text = text
    notification.TextColor3 = isError and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 255, 80)
    notification.TextSize = 13
    notification.Font = Enum.Font.SourceSansBold
    notification.Parent = CoreGui
    Instance.new("UICorner", notification).CornerRadius = UDim.new(0, 5)
    task.delay(2, function() notification:Destroy() end)
end

-- ========== ПЕРЕМЕННЫЕ ==========
local state = {
    menu = true,
    legit = {aimbot = false, silent = false, fov = 15, smooth = 45, hitbox = "Head"},
    trigger = {enabled = false},
    visuals = {enabled = true, box = true, name = true, health = true},
    misc = {freecam = false, fly = false, noclip = false}
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
    if isFreeCam or not state.visuals.enabled then 
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
                        Box = Create("Square", {Thickness = 1, Filled = false, Transparency = 1, Color = Color3.new(1,0,0)}),
                        Name = Create("Text", {Size = 13, Center = true, Outline = true, Color = Color3.new(1,1,1)}),
                        Dist = Create("Text", {Size = 12, Center = true, Outline = true, Color = Color3.new(0.8,0.8,0.8)}),
                        HealthBar = Create("Square", {Thickness = 1, Filled = true, Transparency = 0.7})
                    }
                end
                
                local s = Storage[player]
                local sizeX = 2000 / pos.Z
                local sizeY = 3000 / pos.Z
                local x, y = pos.X - sizeX/2, pos.Y - sizeY/2
                local hp = hum.Health / hum.MaxHealth
                local hpColor = hp > 0.5 and Color3.new(0,1,0) or (hp > 0.25 and Color3.new(1,0.5,0) or Color3.new(1,0,0))
                
                if state.visuals.box then
                    s.Box.Visible = true
                    s.Box.Position = Vector2.new(x, y)
                    s.Box.Size = Vector2.new(sizeX, sizeY)
                else
                    s.Box.Visible = false
                end
                
                if state.visuals.name then
                    s.Name.Visible = true
                    s.Name.Position = Vector2.new(pos.X, y - 16)
                    s.Name.Text = player.Name
                else
                    s.Name.Visible = false
                end
                
                if state.visuals.health then
                    s.Dist.Visible = true
                    s.Dist.Position = Vector2.new(pos.X, y + sizeY + 2)
                    s.Dist.Text = math.floor(pos.Z) .. "m"
                    s.HealthBar.Visible = true
                    s.HealthBar.Position = Vector2.new(x - 6, y + (sizeY * (1 - hp)))
                    s.HealthBar.Size = Vector2.new(3, sizeY * hp)
                    s.HealthBar.Color = hpColor
                else
                    s.Dist.Visible = false
                    s.HealthBar.Visible = false
                end
            else
                Clean(player)
            end
        else
            Clean(player)
        end
    end
end

Players.PlayerRemoving:Connect(Clean)

-- ========== AIMBOT ==========
local function GetClosestPlayer()
    local target = nil
    local closestDist = state.legit.fov * 10
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local part = plr.Character:FindFirstChild(state.legit.hitbox == "Head" and "Head" or "HumanoidRootPart")
            local hum = plr.Character:FindFirstChild("Humanoid")
            if part and hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
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

-- Silent Aim (через перехват Mouse.Hit)
pcall(function()
    local mt = getrawmetatable(game)
    if mt then
        local oldIndex = mt.__index
        setreadonly(mt, false)
        mt.__index = function(self, key)
            if state.legit.silent and self == Mouse and key == "Hit" then
                local target = GetClosestPlayer()
                if target and target.Character then
                    local part = target.Character:FindFirstChild(state.legit.hitbox == "Head" and "Head" or "HumanoidRootPart")
                    if part then return part.CFrame end
                end
            end
            return oldIndex(self, key)
        end
        setreadonly(mt, true)
    end
end)

-- Legit Aimbot (плавное наведение)
local function SetupLegitAimbot()
    table.insert(connections, RunService.RenderStepped:Connect(function()
        if not state.legit.aimbot then return end
        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
        
        local target = GetClosestPlayer()
        if target and target.Character then
            local part = target.Character:FindFirstChild(state.legit.hitbox == "Head" and "Head" or "HumanoidRootPart")
            if part then
                local currentCF = Camera.CFrame
                local newCF = CFrame.new(currentCF.Position, part.Position)
                Camera.CFrame = currentCF:Lerp(newCF, state.legit.smooth / 100)
            end
        end
    end))
end

-- Triggerbot
local function SetupTriggerbot()
    table.insert(connections, RunService.RenderStepped:Connect(function()
        if not state.trigger.enabled then return end
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
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end))
end

-- ========== FOV КРУГ ==========
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 50, 50)
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Transparency = 0.4

-- ========== UNLOAD ==========
local function UnloadCheat()
    if isUnloaded then return end
    isUnloaded = true
    
    for _, conn in pairs(connections) do pcall(conn.Disconnect) end
    pcall(function() if screenGui then screenGui:Destroy() end end)
    pcall(function() espFolder:Destroy() end)
    pcall(function() if HUD then HUD:Destroy() end end)
    pcall(function() if FOVCircle then FOVCircle:Remove() end end)
    pcall(function() if bodyVel then bodyVel:Destroy() end end)
    
    for _, player in pairs(Players:GetPlayers()) do Clean(player) end
    
    if Camera.CameraType == Enum.CameraType.Scriptable then
        Camera.CameraType = Enum.CameraType.Custom
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
    end
    
    print("SquadRim DLC | UNLOADED")
end

-- ========== HUD ==========
local HUD = Instance.new("TextLabel")
HUD.Size = UDim2.new(0, 450, 0, 22)
HUD.Position = UDim2.new(0.5, -225, 0.01, 0)
HUD.BackgroundTransparency = 0.65
HUD.BackgroundColor3 = Color3.fromRGB(8, 10, 12)
HUD.BorderSizePixel = 1
HUD.BorderColor3 = Color3.fromRGB(30, 36, 47)
HUD.TextColor3 = Color3.fromRGB(255, 50, 50)
HUD.TextSize = 12
HUD.Font = Enum.Font.SourceSansBold
HUD.Parent = CoreGui
Instance.new("UICorner", HUD).CornerRadius = UDim.new(0, 4)

local fpsValues = {}
local function UpdateFPS()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    table.insert(fpsValues, fps)
    if #fpsValues > 10 then table.remove(fpsValues, 1) end
    local sum = 0
    for _, v in ipairs(fpsValues) do sum = sum + v end
    return math.floor(sum / #fpsValues)
end

local function UpdateHUD()
    local fps = UpdateFPS()
    local freecamText = isFreeCam and " [FREECAM]" or ""
    HUD.Text = string.format("| t.me/squadrim1 | DLC | FREE | %s | %d FPS |%s", LocalPlayer.Name, fps, freecamText)
end

-- ========== СОЗДАНИЕ МЕНЮ ==========
local screenGui = nil
local MainFrame = nil
local currentTab = "legit"

local function CreateGUI()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SquadRim_Menu"
    screenGui.Parent = CoreGui
    screenGui.ResetOnSpawn = false
    
    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 500, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -225)
    MainFrame.BackgroundColor3 = Color3.fromRGB(14, 17, 22)
    MainFrame.BorderSizePixel = 2
    MainFrame.BorderColor3 = Color3.fromRGB(255, 50, 50)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = screenGui
    MainFrame.Visible = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
    
    -- Заголовок
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 45)
    header.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
    header.BorderSizePixel = 0
    header.Parent = MainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 0, 45)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "SQUADRIM DLC"
    title.TextColor3 = Color3.fromRGB(255, 50, 50)
    title.TextSize = 18
    title.Font = Enum.Font.SourceSansBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -38, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
    closeBtn.BorderSizePixel = 1
    closeBtn.BorderColor3 = Color3.fromRGB(60, 65, 80)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)
    closeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)
    
    -- Вкладки
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, 0, 0, 38)
    tabBar.Position = UDim2.new(0, 0, 0, 45)
    tabBar.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
    tabBar.BorderSizePixel = 1
    tabBar.BorderColor3 = Color3.fromRGB(30, 35, 45)
    tabBar.Parent = MainFrame
    
    local tabs = {{name = "LEGIT", id = "legit"}, {name = "VISUAL", id = "visual"}, {name = "MISC", id = "misc"}}
    local containers = {}
    
    for i, tab in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.33, 0, 1, 0)
        btn.Position = UDim2.new((i-1)/3, 0, 0, 0)
        btn.BackgroundColor3 = i == 1 and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(10, 12, 16)
        btn.BorderSizePixel = 0
        btn.Text = tab.name
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.TextSize = 13
        btn.Font = Enum.Font.SourceSansBold
        btn.Parent = tabBar
        
        local container = Instance.new("ScrollingFrame")
        container.Size = UDim2.new(1, -20, 1, -100)
        container.Position = UDim2.new(0, 10, 0, 90)
        container.BackgroundTransparency = 1
        container.Visible = (i == 1)
        container.CanvasSize = UDim2.new(0, 0, 0, 350)
        container.ScrollBarThickness = 4
        container.Parent = MainFrame
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 10)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = container
        
        containers[tab.id] = container
        
        btn.MouseButton1Click:Connect(function()
            for _, t in pairs(tabs) do
                local b = tabBar:FindFirstChild(t.name)
                if b then b.BackgroundColor3 = Color3.fromRGB(10, 12, 16) end
                if containers[t.id] then containers[t.id].Visible = false end
            end
            btn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            containers[tab.id].Visible = true
        end)
    end
    
    local function MakeGroup(parent, title)
        local group = Instance.new("Frame")
        group.Size = UDim2.new(1, 0, 0, 0)
        group.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
        group.BorderSizePixel = 1
        group.BorderColor3 = Color3.fromRGB(30, 35, 45)
        group.Parent = parent
        Instance.new("UICorner", group).CornerRadius = UDim.new(0, 6)
        
        local titleFrame = Instance.new("Frame")
        titleFrame.Size = UDim2.new(1, 0, 0, 28)
        titleFrame.BackgroundColor3 = Color3.fromRGB(22, 25, 35)
        titleFrame.BorderSizePixel = 1
        titleFrame.BorderColor3 = Color3.fromRGB(30, 35, 45)
        titleFrame.Parent = group
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -10, 1, 0)
        titleLabel.Position = UDim2.new(0, 8, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        titleLabel.TextSize = 11
        titleLabel.Font = Enum.Font.SourceSansBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = titleFrame
        
        local badge = Instance.new("TextLabel")
        badge.Size = UDim2.new(0, 40, 0, 18)
        badge.Position = UDim2.new(1, -48, 0, 5)
        badge.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        badge.BorderSizePixel = 0
        badge.Text = "OFF"
        badge.TextColor3 = Color3.fromRGB(255, 50, 50)
        badge.TextSize = 10
        badge.Font = Enum.Font.SourceSansBold
        badge.Parent = titleFrame
        Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 3)
        
        local body = Instance.new("Frame")
        body.Size = UDim2.new(1, -10, 0, 0)
        body.Position = UDim2.new(0, 5, 0, 28)
        body.BackgroundTransparency = 1
        body.Parent = group
        
        return group, body, badge
    end
    
    local function MakeToggle(parent, text, getter, setter, badge)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 32)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(200, 210, 220)
        label.TextSize = 12
        label.Font = Enum.Font.SourceSans
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 55, 0, 24)
        btn.Position = UDim2.new(0.85, 0, 0.12, 0)
        btn.BackgroundColor3 = getter() and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(35, 38, 48)
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(55, 60, 75)
        btn.Text = getter() and "ON" or "OFF"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 11
        btn.Font = Enum.Font.SourceSansBold
        btn.Parent = frame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
        
        btn.MouseButton1Click:Connect(function()
            local newVal = not getter()
            setter(newVal)
            btn.BackgroundColor3 = newVal and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(35, 38, 48)
            btn.Text = newVal and "ON" or "OFF"
            if badge then badge.Text = newVal and "ON" or "OFF" end
        end)
        
        frame.Size = UDim2.new(1, 0, 0, 32)
        return btn
    end
    
    local function MakeSlider(parent, text, min, max, getter, setter)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 50)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(180, 190, 205)
        label.TextSize = 12
        label.Font = Enum.Font.SourceSans
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.3, 0, 0, 20)
        valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(getter())
        valueLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        valueLabel.TextSize = 11
        valueLabel.Font = Enum.Font.ShareTechMono
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = frame
        
        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, 0, 0, 3)
        track.Position = UDim2.new(0, 0, 0, 28)
        track.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
        track.BorderSizePixel = 0
        track.Parent = frame
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((getter() - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        fill.BorderSizePixel = 0
        fill.Parent = track
        
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 10, 0, 10)
        knob.Position = UDim2.new((getter() - min) / (max - min), -5, 0, -3.5)
        knob.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        knob.BorderSizePixel = 1
        knob.BorderColor3 = Color3.fromRGB(255, 255, 255)
        knob.Parent = track
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        
        local dragging = false
        track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                local percent = math.clamp((Mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * percent)
                setter(val)
                fill.Size = UDim2.new(percent, 0, 1, 0)
                knob.Position = UDim2.new(percent, -5, 0, -3.5)
                valueLabel.Text = tostring(val)
            end
        end)
        track.InputEnded:Connect(function() dragging = false end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local percent = math.clamp((Mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * percent)
                setter(val)
                fill.Size = UDim2.new(percent, 0, 1, 0)
                knob.Position = UDim2.new(percent, -5, 0, -3.5)
                valueLabel.Text = tostring(val)
            end
        end)
    end
    
    local function MakeDropdown(parent, text, options, getter, setter)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 52)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 16)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(120, 130, 150)
        label.TextSize = 10
        label.Font = Enum.Font.SourceSans
        label.Parent = frame
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.Position = UDim2.new(0, 0, 0, 18)
        btn.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(55, 60, 75)
        btn.Text = getter()
        btn.TextColor3 = Color3.fromRGB(255, 50, 50)
        btn.TextSize = 11
        btn.Font = Enum.Font.SourceSansBold
        btn.Parent = frame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
        
        local open = false
        local dropdown = nil
        btn.MouseButton1Click:Connect(function()
            if open and dropdown then dropdown:Destroy() end
            open = true
            dropdown = Instance.new("Frame")
            dropdown.Size = UDim2.new(1, 0, 0, 30 * #options)
            dropdown.Position = UDim2.new(0, 0, 0, 30)
            dropdown.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
            dropdown.BorderSizePixel = 1
            dropdown.BorderColor3 = Color3.fromRGB(55, 60, 75)
            dropdown.Parent = frame
            Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 3)
            
            for i, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 30)
                optBtn.Position = UDim2.new(0, 0, 0, 30 * (i-1))
                optBtn.BackgroundColor3 = Color3.fromRGB(40, 43, 55)
                optBtn.Text = opt
                optBtn.TextColor3 = Color3.fromRGB(200, 210, 220)
                optBtn.TextSize = 11
                optBtn.Font = Enum.Font.SourceSans
                optBtn.Parent = dropdown
                optBtn.MouseButton1Click:Connect(function()
                    setter(opt)
                    btn.Text = opt
                    dropdown:Destroy()
                    open = false
                end)
            end
        end)
    end
    
    -- ========== LEGIT TAB ==========
    local legitContainer = containers["legit"]
    
    local g1, body1, badge1 = MakeGroup(legitContainer, "Aimbot")
    MakeToggle(body1, "Legit Aimbot", function() return state.legit.aimbot end, function(v) state.legit.aimbot = v end, badge1)
    MakeToggle(body1, "Silent Aim", function() return state.legit.silent end, function(v) state.legit.silent = v end)
    MakeDropdown(body1, "Hitbox", {"Head", "Body"}, function() return state.legit.hitbox end, function(v) state.legit.hitbox = v end)
    MakeSlider(body1, "FOV", 5, 50, function() return state.legit.fov end, function(v) state.legit.fov = v end)
    MakeSlider(body1, "Smoothness", 1, 100, function() return state.legit.smooth end, function(v) state.legit.smooth = v end)
    g1.Size = UDim2.new(1, 0, 0, body1.AbsoluteSize.Y + 40)
    
    local g2, body2, badge2 = MakeGroup(legitContainer, "Triggerbot")
    MakeToggle(body2, "Triggerbot", function() return state.trigger.enabled end, function(v) state.trigger.enabled = v end, badge2)
    g2.Size = UDim2.new(1, 0, 0, body2.AbsoluteSize.Y + 40)
    
    -- ========== VISUAL TAB ==========
    local visualContainer = containers["visual"]
    
    local g3, body3, badge3 = MakeGroup(visualContainer, "ESP")
    MakeToggle(body3, "ESP Enabled", function() return state.visuals.enabled end, function(v) state.visuals.enabled = v end, badge3)
    MakeToggle(body3, "Box ESP", function() return state.visuals.box end, function(v) state.visuals.box = v end)
    MakeToggle(body3, "Name Tags", function() return state.visuals.name end, function(v) state.visuals.name = v end)
    MakeToggle(body3, "Health Bar & Distance", function() return state.visuals.health end, function(v) state.visuals.health = v end)
    g3.Size = UDim2.new(1, 0, 0, body3.AbsoluteSize.Y + 40)
    
    -- ========== MISC TAB ==========
    local miscContainer = containers["misc"]
    
    local g4, body4, badge4 = MakeGroup(miscContainer, "Movement")
    MakeToggle(body4, "Fly Mode", function() return state.misc.fly end, function(v) state.misc.fly = v end)
    MakeToggle(body4, "Noclip", function() return state.misc.noclip end, function(v) state.misc.noclip = v end)
    MakeToggle(body4, "FreeCam (F7)", function() return state.misc.freecam end, function(v) if v then toggleFreeCam() else toggleFreeCam() end end)
    g4.Size = UDim2.new(1, 0, 0, body4.AbsoluteSize.Y + 40)
    
    local g5, body5, badge5 = MakeGroup(miscContainer, "Config")
    g5.Size = UDim2.new(1, 0, 0, 100)
    
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.45, 0, 0, 32)
    saveBtn.Position = UDim2.new(0.02, 0, 0, 5)
    saveBtn.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
    saveBtn.BorderSizePixel = 1
    saveBtn.BorderColor3 = Color3.fromRGB(55, 60, 75)
    saveBtn.Text = "💾 SAVE"
    saveBtn.TextColor3 = Color3.fromRGB(80, 255, 120)
    saveBtn.TextSize = 12
    saveBtn.Font = Enum.Font.SourceSansBold
    saveBtn.Parent = body5
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 3)
    saveBtn.MouseButton1Click:Connect(function()
        local cfg = {legit = state.legit, trigger = state.trigger, visuals = state.visuals, misc = state.misc}
        writefile("SquadRim_Config.json", HttpService:JSONEncode(cfg))
        ShowNotification("Config saved", false)
    end)
    
    local loadBtn = Instance.new("TextButton")
    loadBtn.Size = UDim2.new(0.45, 0, 0, 32)
    loadBtn.Position = UDim2.new(0.53, 0, 0, 5)
    loadBtn.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
    loadBtn.BorderSizePixel = 1
    loadBtn.BorderColor3 = Color3.fromRGB(55, 60, 75)
    loadBtn.Text = "📂 LOAD"
    loadBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
    loadBtn.TextSize = 12
    loadBtn.Font = Enum.Font.SourceSansBold
    loadBtn.Parent = body5
    Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 3)
    loadBtn.MouseButton1Click:Connect(function()
        if isfile("SquadRim_Config.json") then
            local data = HttpService:JSONDecode(readfile("SquadRim_Config.json"))
            state.legit = data.legit or state.legit
            state.trigger = data.trigger or state.trigger
            state.visuals = data.visuals or state.visuals
            state.misc = data.misc or state.misc
            ShowNotification("Config loaded", false)
        end
    end)
    
    local unloadBtn = Instance.new("TextButton")
    unloadBtn.Size = UDim2.new(0.96, 0, 0, 32)
    unloadBtn.Position = UDim2.new(0.02, 0, 0, 45)
    unloadBtn.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
    unloadBtn.BorderSizePixel = 1
    unloadBtn.BorderColor3 = Color3.fromRGB(255, 50, 50)
    unloadBtn.Text = "⚠️ UNLOAD (END) ⚠️"
    unloadBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
    unloadBtn.TextSize = 12
    unloadBtn.Font = Enum.Font.SourceSansBold
    unloadBtn.Parent = body5
    Instance.new("UICorner", unloadBtn).CornerRadius = UDim.new(0, 3)
    unloadBtn.MouseButton1Click:Connect(UnloadCheat)
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 0, 20)
    infoLabel.Position = UDim2.new(0, 0, 0, 85)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "t.me/squadrim1 | Insert = Menu | F7 = FreeCam"
    infoLabel.TextColor3 = Color3.fromRGB(100, 110, 130)
    infoLabel.TextSize = 9
    infoLabel.Font = Enum.Font.SourceSans
    infoLabel.Parent = body5
end

-- ========== АВТОРИЗАЦИЯ ==========
local function ShowAuth()
    local authGui = Instance.new("ScreenGui")
    authGui.Name = "SquadRim_Auth"
    authGui.Parent = CoreGui
    authGui.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 360, 0, 250)
    mainFrame.Position = UDim2.new(0.5, -180, 0.5, -125)
    mainFrame.BackgroundColor3 = Color3.fromRGB(14, 17, 22)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(255, 50, 50)
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = authGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
    title.Text = "SQUADRIM DLC"
    title.TextColor3 = Color3.fromRGB(255, 50, 50)
    title.TextSize = 22
    title.Font = Enum.Font.SourceSansBold
    title.Parent = mainFrame
    title.TextScaled = true

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 25)
    subtitle.Position = UDim2.new(0, 0, 0, 50)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Введите ключ для активации"
    subtitle.TextColor3 = Color3.fromRGB(180, 190, 205)
    subtitle.TextSize = 13
    subtitle.Font = Enum.Font.SourceSans
    subtitle.Parent = mainFrame

    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0.8, 0, 0, 38)
    inputBox.Position = UDim2.new(0.1, 0, 0, 85)
    inputBox.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
    inputBox.BorderSizePixel = 1
    inputBox.BorderColor3 = Color3.fromRGB(55, 60, 75)
    inputBox.PlaceholderText = "Введите ключ"
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.TextSize = 14
    inputBox.Font = Enum.Font.SourceSans
    inputBox.Parent = mainFrame
    Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 5)

    local loginBtn = Instance.new("TextButton")
    loginBtn.Size = UDim2.new(0.35, 0, 0, 36)
    loginBtn.Position = UDim2.new(0.1, 0, 0, 140)
    loginBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    loginBtn.Text = "ВОЙТИ"
    loginBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    loginBtn.TextSize = 14
    loginBtn.Font = Enum.Font.SourceSansBold
    loginBtn.Parent = mainFrame
    Instance.new("UICorner", loginBtn).CornerRadius = UDim.new(0, 5)

    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Size = UDim2.new(0.35, 0, 0, 36)
    getKeyBtn.Position = UDim2.new(0.55, 0, 0, 140)
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
    getKeyBtn.BorderSizePixel = 1
    getKeyBtn.BorderColor3 = Color3.fromRGB(255, 50, 50)
    getKeyBtn.Text = "ПОЛУЧИТЬ"
    getKeyBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
    getKeyBtn.TextSize = 13
    getKeyBtn.Font = Enum.Font.SourceSansBold
    getKeyBtn.Parent = mainFrame
    Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 5)

    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, 0, 0, 20)
    infoText.Position = UDim2.new(0, 0, 0, 195)
    infoText.BackgroundTransparency = 1
    infoText.Text = "Бесплатный ключ: SquadRim2024"
    infoText.TextColor3 = Color3.fromRGB(100, 110, 130)
    infoText.TextSize = 11
    infoText.Font = Enum.Font.SourceSans
    infoText.Parent = mainFrame

    local tgText = Instance.new("TextLabel")
    tgText.Size = UDim2.new(1, 0, 0, 20)
    tgText.Position = UDim2.new(0, 0, 0, 215)
    tgText.BackgroundTransparency = 1
    tgText.Text = "Telegram: t.me/squadrim1"
    tgText.TextColor3 = Color3.fromRGB(255, 50, 50)
    tgText.TextSize = 11
    tgText.Font = Enum.Font.SourceSans
    tgText.Parent = mainFrame

    getKeyBtn.MouseButton1Click:Connect(function()
        CopyToClipboard("t.me/squadrim1")
        ShowNotification("✅ Ссылка скопирована!", false)
    end)

    loginBtn.MouseButton1Click:Connect(function()
        local key = inputBox.Text
        if key == "SquadRim2024" or key == "freekey" or key == "squadrim" then
            authGui:Destroy()
            ShowNotification("✅ Авторизация успешна!", false)
            CreateGUI()
            SetupLegitAimbot()
            SetupTriggerbot()
            SetupFreeCam()
            SetupFly()
            SetupNoclip()
            
            table.insert(connections, RunService.RenderStepped:Connect(function()
                UpdateESP()
                UpdateHUD()
                FOVCircle.Visible = (state.legit.aimbot or state.legit.silent) and not isFreeCam
                FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
                FOVCircle.Radius = state.legit.fov * 10
            end))
            
            UserInputService.InputBegan:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.Insert then
                    if MainFrame then MainFrame.Visible = not MainFrame.Visible end
                elseif input.KeyCode == Enum.KeyCode.End then
                    UnloadCheat()
                end
            end)
            
            print("=== SQUADRIM DLC v16.0 | ЗАПУЩЕН ===")
            print("Insert = Меню | F7 = FreeCam | End = Выгрузка")
        else
            inputBox.Text = ""
            inputBox.PlaceholderText = "НЕВЕРНЫЙ КЛЮЧ!"
            inputBox.BackgroundColor3 = Color3.fromRGB(80, 40, 50)
            ShowNotification("❌ Неверный ключ!", true)
            task.wait(1.5)
            inputBox.PlaceholderText = "Введите ключ"
            inputBox.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
        end
    end)
end

ShowAuth()
