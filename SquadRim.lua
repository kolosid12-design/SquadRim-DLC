-- SWILL | SquadRim DLC PRO | v15.1 | ПОЛНОЕ МЕНЮ
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
    notification.Position = UDim2.new(0.5, -150, 0.15, 0)
    notification.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    notification.BackgroundTransparency = 0.15
    notification.BorderSizePixel = 1
    notification.BorderColor3 = Color3.fromRGB(232, 48, 48)
    notification.Text = text
    notification.TextColor3 = isError and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 255, 80)
    notification.TextSize = 14
    notification.Font = Enum.Font.SourceSansBold
    notification.Parent = CoreGui
    Instance.new("UICorner", notification).CornerRadius = UDim.new(0, 6)
    task.delay(2.5, function() notification:Destroy() end)
end

-- ========== ПЕРЕМЕННЫЕ ==========
local state = {
    menu = true,
    version = "0.7",
    legit = {aimbot = false, silent = false, autoshoot = true, fov = 8, smooth = 45, hitbox = "Head"},
    trigger = {enabled = false, delaymin = 40, delaymax = 90},
    visuals = {enabled = true, box = true, name = true, health = true, chams = false},
    misc = {bhop = false, freecam = false, fly = false, noclip = false}
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
    if isFreeCam or not state.visuals.enabled then return end
    
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
                        Name = Create("Text", {Size = 14, Center = true, Outline = true, Color = Color3.new(1,1,1)}),
                        Dist = Create("Text", {Size = 13, Center = true, Outline = true, Color = Color3.new(0.8,0.8,0.8)}),
                        HealthBar = Create("Square", {Thickness = 1, Filled = true, Transparency = 0.7}),
                        Highlight = Instance.new("Highlight")
                    }
                    Storage[player].Highlight.Parent = espFolder
                end
                
                local s = Storage[player]
                local sizeX = 2000 / pos.Z
                local sizeY = 3000 / pos.Z
                local x, y = pos.X - sizeX/2, pos.Y - sizeY/2
                local hp = hum.Health / hum.MaxHealth
                local hpColor = hp > 0.5 and Color3.new(0,1,0) or (hp > 0.25 and Color3.new(1,0.5,0) or Color3.new(1,0,0))
                
                s.Box.Visible = state.visuals.box
                s.Box.Position = Vector2.new(x, y)
                s.Box.Size = Vector2.new(sizeX, sizeY)
                
                s.Name.Visible = state.visuals.name
                s.Name.Position = Vector2.new(pos.X, y - 16)
                s.Name.Text = player.Name
                
                s.Dist.Visible = state.visuals.health
                s.Dist.Position = Vector2.new(pos.X, y + sizeY + 2)
                s.Dist.Text = math.floor(pos.Z) .. "m"
                
                s.HealthBar.Visible = state.visuals.health
                s.HealthBar.Position = Vector2.new(x - 6, y + (sizeY * (1 - hp)))
                s.HealthBar.Size = Vector2.new(3, sizeY * hp)
                s.HealthBar.Color = hpColor
                
                s.Highlight.Enabled = state.visuals.chams
                s.Highlight.Adornee = char
                s.Highlight.FillTransparency = 0.5
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

-- Silent Aim
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

-- Legit Aimbot
local function SetupLegitAimbot()
    table.insert(connections, RunService.RenderStepped:Connect(function()
        if state.legit.aimbot and (state.legit.silent or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) then
            local target = GetClosestPlayer()
            if target and target.Character then
                local part = target.Character:FindFirstChild(state.legit.hitbox == "Head" and "Head" or "HumanoidRootPart")
                if part then
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, part.Position), state.legit.smooth / 100)
                end
            end
        end
    end))
end

-- Triggerbot
local function SetupTriggerbot()
    table.insert(connections, RunService.RenderStepped:Connect(function()
        if state.trigger.enabled then
            local target = GetClosestPlayer()
            if target then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(state.trigger.delaymin / 1000)
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

-- ========== BHOP ==========
local function SetupBHop()
    table.insert(connections, RunService.RenderStepped:Connect(function()
        if state.misc.bhop and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum and (UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.D)) and hum.FloorMaterial ~= Enum.Material.Air then
                hum.Jump = true
            end
        end
    end))
end

-- ========== CONFIG ==========
local function SaveConfig()
    writefile("SquadRim_Config.json", HttpService:JSONEncode({
        legit = state.legit, trigger = state.trigger, visuals = state.visuals, misc = state.misc
    }))
    ShowNotification("Config saved", false)
end

local function LoadConfig()
    if isfile("SquadRim_Config.json") then
        local data = HttpService:JSONDecode(readfile("SquadRim_Config.json"))
        state.legit = data.legit or state.legit
        state.trigger = data.trigger or state.trigger
        state.visuals = data.visuals or state.visuals
        state.misc = data.misc or state.misc
        ShowNotification("Config loaded", false)
    end
end

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
end

-- ========== HUD ==========
local HUD = Instance.new("TextLabel")
HUD.Size = UDim2.new(0, 450, 0, 22)
HUD.Position = UDim2.new(0.5, -225, 0.01, 0)
HUD.BackgroundTransparency = 0.65
HUD.BackgroundColor3 = Color3.fromRGB(8, 10, 12)
HUD.BorderSizePixel = 1
HUD.BorderColor3 = Color3.fromRGB(30, 36, 47)
HUD.TextColor3 = Color3.fromRGB(232, 48, 48)
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
    HUD.Text = string.format("| t.me/squadrim1 | DLC | FREE | %s | %d FPS |", LocalPlayer.Name, fps)
end

-- ========== FOV КРУГ ==========
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(232, 48, 48)
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Transparency = 0.4

-- ========== СОЗДАНИЕ ГЛАВНОГО МЕНЮ ==========
local screenGui = nil
local MainFrame = nil
local currentTab = "legit"

local function CreateGUI()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SquadRim_Menu"
    screenGui.Parent = CoreGui
    screenGui.ResetOnSpawn = false
    
    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 480)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -240)
    MainFrame.BackgroundColor3 = Color3.fromRGB(8, 10, 12)
    MainFrame.BorderSizePixel = 1
    MainFrame.BorderColor3 = Color3.fromRGB(232, 48, 48)
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = screenGui
    MainFrame.Visible = true
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 42)
    header.BackgroundColor3 = Color3.fromRGB(14, 17, 20)
    header.BorderSizePixel = 0
    header.Parent = MainFrame
    
    local logo = Instance.new("TextLabel")
    logo.Size = UDim2.new(0, 150, 0, 30)
    logo.Position = UDim2.new(0, 12, 0, 6)
    logo.BackgroundTransparency = 1
    logo.Text = "SQUADRIM DLC"
    logo.TextColor3 = Color3.fromRGB(232, 48, 48)
    logo.TextSize = 20
    logo.Font = Enum.Font.SourceSansBold
    logo.TextXAlignment = Enum.TextXAlignment.Left
    logo.Parent = header
    
    local ver = Instance.new("TextLabel")
    ver.Size = UDim2.new(0, 150, 0, 14)
    ver.Position = UDim2.new(0, 12, 0, 28)
    ver.BackgroundTransparency = 1
    ver.Text = "BUILD 0.7 — ROBLOX"
    ver.TextColor3 = Color3.fromRGB(58, 69, 88)
    ver.TextSize = 9
    ver.Font = Enum.Font.ShareTechMono
    ver.TextXAlignment = Enum.TextXAlignment.Left
    ver.Parent = header
    
    local statusActive = Instance.new("TextLabel")
    statusActive.Size = UDim2.new(0, 80, 0, 16)
    statusActive.Position = UDim2.new(1, -180, 0, 8)
    statusActive.BackgroundTransparency = 1
    statusActive.Text = "STATUS ACTIVE"
    statusActive.TextColor3 = Color3.fromRGB(79, 255, 176)
    statusActive.TextSize = 10
    statusActive.Font = Enum.Font.SourceSansBold
    statusActive.Parent = header
    
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(0, 60, 0, 16)
    fpsLabel.Position = UDim2.new(1, -90, 0, 8)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS 144"
    fpsLabel.TextColor3 = Color3.fromRGB(232, 48, 48)
    fpsLabel.TextSize = 10
    fpsLabel.Font = Enum.Font.SourceSansBold
    fpsLabel.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -28, 0, 11)
    closeBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    closeBtn.BorderSizePixel = 1
    closeBtn.BorderColor3 = Color3.fromRGB(45, 45, 55)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(106, 122, 148)
    closeBtn.TextSize = 12
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 3)
    closeBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)
    
    -- Tabs
    local tabBar = Instance.new("Frame")
    tabBar.Size = UDim2.new(1, 0, 0, 36)
    tabBar.Position = UDim2.new(0, 0, 0, 42)
    tabBar.BackgroundColor3 = Color3.fromRGB(8, 10, 12)
    tabBar.BorderSizePixel = 1
    tabBar.BorderColor3 = Color3.fromRGB(30, 36, 47)
    tabBar.Parent = MainFrame
    
    local tabsData = {
        {name = "LEGIT", id = "legit", x = 0},
        {name = "VISUAL", id = "visual", x = 150},
        {name = "MISC", id = "misc", x = 300},
        {name = "CONFIG", id = "config", x = 450}
    }
    
    local containers = {}
    
    for _, tab in ipairs(tabsData) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 150, 1, 0)
        btn.Position = UDim2.new(0, tab.x, 0, 0)
        btn.BackgroundColor3 = tab.id == currentTab and Color3.fromRGB(232, 48, 48) or Color3.fromRGB(8, 10, 12)
        btn.BorderSizePixel = 0
        btn.Text = tab.name
        btn.TextColor3 = Color3.fromRGB(232, 48, 48)
        btn.TextSize = 12
        btn.Font = Enum.Font.SourceSansBold
        btn.Parent = tabBar
        
        local container = Instance.new("ScrollingFrame")
        container.Size = UDim2.new(1, -20, 1, -90)
        container.Position = UDim2.new(0, 10, 0, 85)
        container.BackgroundTransparency = 1
        container.Visible = (tab.id == currentTab)
        container.CanvasSize = UDim2.new(0, 0, 0, 400)
        container.ScrollBarThickness = 4
        container.Parent = MainFrame
        
        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 10)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = container
        
        containers[tab.id] = container
        
        btn.MouseButton1Click:Connect(function()
            currentTab = tab.id
            for _, t in pairs(tabsData) do
                local b = tabBar:FindFirstChild(t.name)
                if b then b.BackgroundColor3 = Color3.fromRGB(8, 10, 12) end
                if containers[t.id] then containers[t.id].Visible = (t.id == tab.id) end
            end
            btn.BackgroundColor3 = Color3.fromRGB(232, 48, 48)
        end)
    end
    
    local function CreateGroup(parent, title)
        local group = Instance.new("Frame")
        group.Size = UDim2.new(1, -20, 0, 0)
        group.BackgroundColor3 = Color3.fromRGB(14, 17, 20)
        group.BorderSizePixel = 1
        group.BorderColor3 = Color3.fromRGB(30, 36, 47)
        group.Parent = parent
        Instance.new("UICorner", group).CornerRadius = UDim.new(0, 4)
        
        local titleFrame = Instance.new("Frame")
        titleFrame.Size = UDim2.new(1, 0, 0, 26)
        titleFrame.BackgroundColor3 = Color3.fromRGB(19, 23, 32)
        titleFrame.BorderSizePixel = 1
        titleFrame.BorderColor3 = Color3.fromRGB(30, 36, 47)
        titleFrame.Parent = group
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -10, 1, 0)
        titleLabel.Position = UDim2.new(0, 8, 0, 0)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = Color3.fromRGB(232, 48, 48)
        titleLabel.TextSize = 11
        titleLabel.Font = Enum.Font.SourceSansBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = titleFrame
        
        local badge = Instance.new("TextLabel")
        badge.Size = UDim2.new(0, 40, 0, 16)
        badge.Position = UDim2.new(1, -48, 0, 5)
        badge.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        badge.BorderSizePixel = 0
        badge.Text = "OFF"
        badge.TextColor3 = Color3.fromRGB(232, 48, 48)
        badge.TextSize = 9
        badge.Font = Enum.Font.SourceSansBold
        badge.Parent = titleFrame
        Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 2)
        
        local body = Instance.new("Frame")
        body.Size = UDim2.new(1, 0, 1, -26)
        body.Position = UDim2.new(0, 0, 0, 26)
        body.BackgroundTransparency = 1
        body.Parent = group
        
        return group, body, badge
    end
    
    local function MakeToggle(parent, text, getter, setter, badge)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 30)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(184, 196, 212)
        label.TextSize = 12
        label.Font = Enum.Font.SourceSans
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 55, 0, 24)
        btn.Position = UDim2.new(0.85, 0, 0.1, 0)
        btn.BackgroundColor3 = getter() and Color3.fromRGB(232, 48, 48) or Color3.fromRGB(25, 25, 35)
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(45, 45, 55)
        btn.Text = getter() and "ON" or "OFF"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 11
        btn.Font = Enum.Font.SourceSansBold
        btn.Parent = frame
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
        
        btn.MouseButton1Click:Connect(function()
            local newVal = not getter()
            setter(newVal)
            btn.BackgroundColor3 = newVal and Color3.fromRGB(232, 48, 48) or Color3.fromRGB(25, 25, 35)
            btn.Text = newVal and "ON" or "OFF"
            if badge then badge.Text = newVal and "ON" or "OFF" end
        end)
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
        label.TextColor3 = Color3.fromRGB(184, 196, 212)
        label.TextSize = 12
        label.Font = Enum.Font.SourceSans
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(0.3, 0, 0, 20)
        valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(getter())
        valueLabel.TextColor3 = Color3.fromRGB(232, 48, 48)
        valueLabel.TextSize = 12
        valueLabel.Font = Enum.Font.ShareTechMono
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        valueLabel.Parent = frame
        
        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, 0, 0, 3)
        track.Position = UDim2.new(0, 0, 0, 28)
        track.BackgroundColor3 = Color3.fromRGB(30, 36, 47)
        track.BorderSizePixel = 0
        track.Parent = frame
        
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((getter() - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(232, 48, 48)
        fill.BorderSizePixel = 0
        fill.Parent = track
        
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 10, 0, 10)
        knob.Position = UDim2.new((getter() - min) / (max - min), -5, 0, -3.5)
        knob.BackgroundColor3 = Color3.fromRGB(232, 48, 48)
        knob.BorderSizePixel = 1
        knob.BorderColor3 = Color3.fromRGB(255, 255, 255)
        knob.Parent = track
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        
        local dragging = false
        track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                local percent = math.clamp((Mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local val = min + (max - min) * percent
                if type(getter()) == "number" and math.floor(getter()) == getter() then val = math.floor(val) end
                setter(val)
                fill.Size = UDim2.new(percent, 0, 1, 0)
                knob.Position = UDim2.new(percent, -5, 0, -3.5)
                valueLabel.Text = type(val) == "number" and (math.floor(val) == val and tostring(val) or string.format("%.1f", val)) or tostring(val)
            end
        end)
        track.InputEnded:Connect(function() dragging = false end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local percent = math.clamp((Mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local val = min + (max - min) * percent
                if type(getter()) == "number" and math.floor(getter()) == getter() then val = math.floor(val) end
                setter(val)
                fill.Size = UDim2.new(percent, 0, 1, 0)
                knob.Position = UDim2.new(percent, -5, 0, -3.5)
                valueLabel.Text = type(val) == "number" and (math.floor(val) == val and tostring(val) or string.format("%.1f", val)) or tostring(val)
            end
        end)
    end
    
    local function MakeDropdown(parent, text, options, getter, setter)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 50)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 16)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(106, 122, 148)
        label.TextSize = 10
        label.Font = Enum.Font.SourceSans
        label.Parent = frame
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 28)
        btn.Position = UDim2.new(0, 0, 0, 20)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(45, 45, 55)
        btn.Text = getter()
        btn.TextColor3 = Color3.fromRGB(232, 48, 48)
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
            dropdown.Size = UDim2.new(1, 0, 0, 28 * #options)
            dropdown.Position = UDim2.new(0, 0, 0, 28)
            dropdown.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
            dropdown.BorderSizePixel = 1
            dropdown.BorderColor3 = Color3.fromRGB(45, 45, 55)
            dropdown.Parent = frame
            Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 3)
            
            for i, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton")
                optBtn.Size = UDim2.new(1, 0, 0, 28)
                optBtn.Position = UDim2.new(0, 0, 0, 28 * (i-1))
                optBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
                optBtn.Text = opt
                optBtn.TextColor3 = Color3.fromRGB(184, 196, 212)
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
    local g1, body1, badge1 = CreateGroup(legitContainer, "Aimbot")
    g1.Size = UDim2.new(1, -20, 0, 180)
    MakeToggle(body1, "Legit Aimbot", function() return state.legit.aimbot end, function(v) state.legit.aimbot = v end, badge1)
    MakeToggle(body1, "Silent Aim", function() return state.legit.silent end, function(v) state.legit.silent = v end)
    MakeToggle(body1, "Auto Shoot", function() return state.legit.autoshoot end, function(v) state.legit.autoshoot = v end)
    MakeDropdown(body1, "Hitbox", {"Head", "Body"}, function() return state.legit.hitbox end, function(v) state.legit.hitbox = v end)
    MakeSlider(body1, "FOV", 1, 30, function() return state.legit.fov end, function(v) state.legit.fov = v end)
    MakeSlider(body1, "Smoothness", 1, 100, function() return state.legit.smooth end, function(v) state.legit.smooth = v end)
    
    local g2, body2, badge2 = CreateGroup(legitContainer, "Triggerbot")
    g2.Size = UDim2.new(1, -20, 0, 120)
    MakeToggle(body2, "Triggerbot", function() return state.trigger.enabled end, function(v) state.trigger.enabled = v end, badge2)
    MakeSlider(body2, "Delay (ms)", 10, 200, function() return state.trigger.delaymin end, function(v) state.trigger.delaymin = v end)
    
    -- ========== VISUAL TAB ==========
    local visualContainer = containers["visual"]
    local g3, body3, badge3 = CreateGroup(visualContainer, "ESP")
    g3.Size = UDim2.new(1, -20, 0, 160)
    MakeToggle(body3, "ESP Enabled", function() return state.visuals.enabled end, function(v) state.visuals.enabled = v end, badge3)
    MakeToggle(body3, "Box ESP", function() return state.visuals.box end, function(v) state.visuals.box = v end)
    MakeToggle(body3, "Name Tags", function() return state.visuals.name end, function(v) state.visuals.name = v end)
    MakeToggle(body3, "Health Bar", function() return state.visuals.health end, function(v) state.visuals.health = v end)
    MakeToggle(body3, "Chams", function() return state.visuals.chams end, function(v) state.visuals.chams = v end)
    
    -- ========== MISC TAB ==========
    local miscContainer = containers["misc"]
    local g4, body4, badge4 = CreateGroup(miscContainer, "Movement")
    g4.Size = UDim2.new(1, -20, 0, 160)
    MakeToggle(body4, "Bunny Hop", function() return state.misc.bhop end, function(v) state.misc.bhop = v end, badge4)
    MakeToggle(body4, "Fly Mode", function() return state.misc.fly end, function(v) state.misc.fly = v end)
    MakeToggle(body4, "Noclip", function() return state.misc.noclip end, function(v) state.misc.noclip = v end)
    MakeToggle(body4, "FreeCam (F7)", function() return state.misc.freecam end, function(v) if v then toggleFreeCam() else toggleFreeCam() end end)
    
    -- ========== CONFIG TAB ==========
    local configContainer = containers["config"]
    local g5, body5, badge5 = CreateGroup(configContainer, "Configuration")
    g5.Size = UDim2.new(1, -20, 0, 120)
    
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0.45, 0, 0, 35)
    saveBtn.Position = UDim2.new(0.02, 0, 0, 0)
    saveBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    saveBtn.BorderSizePixel = 1
    saveBtn.BorderColor3 = Color3.fromRGB(45, 45, 55)
    saveBtn.Text = "💾 SAVE CONFIG"
    saveBtn.TextColor3 = Color3.fromRGB(79, 255, 176)
    saveBtn.TextSize = 12
    saveBtn.Font = Enum.Font.SourceSansBold
    saveBtn.Parent = body5
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 3)
    saveBtn.MouseButton1Click:Connect(SaveConfig)
    
    local loadBtn = Instance.new("TextButton")
    loadBtn.Size = UDim2.new(0.45, 0, 0, 35)
    loadBtn.Position = UDim2.new(0.53, 0, 0, 0)
    loadBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    loadBtn.BorderSizePixel = 1
    loadBtn.BorderColor3 = Color3.fromRGB(45, 45, 55)
    loadBtn.Text = "📂 LOAD CONFIG"
    loadBtn.TextColor3 = Color3.fromRGB(232, 48, 48)
    loadBtn.TextSize = 12
    loadBtn.Font = Enum.Font.SourceSansBold
    loadBtn.Parent = body5
    Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 3)
    loadBtn.MouseButton1Click:Connect(LoadConfig)
    
    local unloadBtn = Instance.new("TextButton")
    unloadBtn.Size = UDim2.new(0.96, 0, 0, 35)
    unloadBtn.Position = UDim2.new(0.02, 0, 0, 50)
    unloadBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    unloadBtn.BorderSizePixel = 1
    unloadBtn.BorderColor3 = Color3.fromRGB(232, 48, 48)
    unloadBtn.Text = "⚠️ UNLOAD CHEAT (END) ⚠️"
    unloadBtn.TextColor3 = Color3.fromRGB(232, 48, 48)
    unloadBtn.TextSize = 12
    unloadBtn.Font = Enum.Font.SourceSansBold
    unloadBtn.Parent = body5
    Instance.new("UICorner", unloadBtn).CornerRadius = UDim.new(0, 3)
    unloadBtn.MouseButton1Click:Connect(UnloadCheat)
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 0, 30)
    infoLabel.Position = UDim2.new(0, 0, 0, 95)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "Telegram: t.me/squadrim1 | Insert = Menu | F7 = FreeCam | End = Unload"
    infoLabel.TextColor3 = Color3.fromRGB(106, 122, 148)
    infoLabel.TextSize = 10
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
    mainFrame.Size = UDim2.new(0, 400, 0, 280)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -140)
    mainFrame.BackgroundColor3 = Color3.fromRGB(8, 10, 12)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.fromRGB(232, 48, 48)
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = authGui
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundColor3 = Color3.fromRGB(14, 17, 20)
    title.Text = "SQUADRIM DLC PRO"
    title.TextColor3 = Color3.fromRGB(232, 48, 48)
    title.TextSize = 24
    title.Font = Enum.Font.SourceSansBold
    title.Parent = mainFrame
    title.TextScaled = true

    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, 0, 0, 25)
    subtitle.Position = UDim2.new(0, 0, 0, 55)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Введите ключ для активации"
    subtitle.TextColor3 = Color3.fromRGB(184, 196, 212)
    subtitle.TextSize = 14
    subtitle.Font = Enum.Font.SourceSans
    subtitle.Parent = mainFrame

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.8, 0, 0, 40)
    textBox.Position = UDim2.new(0.1, 0, 0, 90)
    textBox.BackgroundColor3 = Color3.fromRGB(19, 23, 32)
    textBox.BorderSizePixel = 1
    textBox.BorderColor3 = Color3.fromRGB(45, 45, 55)
    textBox.PlaceholderText = "Введите ключ"
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.TextSize = 16
    textBox.Font = Enum.Font.SourceSans
    textBox.Parent = mainFrame
    Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 6)

    local loginBtn = Instance.new("TextButton")
    loginBtn.Size = UDim2.new(0.35, 0, 0, 38)
    loginBtn.Position = UDim2.new(0.1, 0, 0, 150)
    loginBtn.BackgroundColor3 = Color3.fromRGB(232, 48, 48)
    loginBtn.Text = "ВОЙТИ"
    loginBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    loginBtn.TextSize = 16
    loginBtn.Font = Enum.Font.SourceSansBold
    loginBtn.Parent = mainFrame
    Instance.new("UICorner", loginBtn).CornerRadius = UDim.new(0, 6)

    local getKeyBtn = Instance.new("TextButton")
    getKeyBtn.Size = UDim2.new(0.35, 0, 0, 38)
    getKeyBtn.Position = UDim2.new(0.55, 0, 0, 150)
    getKeyBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    getKeyBtn.BorderSizePixel = 1
    getKeyBtn.BorderColor3 = Color3.fromRGB(232, 48, 48)
    getKeyBtn.Text = "ПОЛУЧИТЬ"
    getKeyBtn.TextColor3 = Color3.fromRGB(232, 48, 48)
    getKeyBtn.TextSize = 14
    getKeyBtn.Font = Enum.Font.SourceSansBold
    getKeyBtn.Parent = mainFrame
    Instance.new("UICorner", getKeyBtn).CornerRadius = UDim.new(0, 6)

    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, 0, 0, 20)
    infoText.Position = UDim2.new(0, 0, 0, 205)
    infoText.BackgroundTransparency = 1
    infoText.Text = "Бесплатный ключ: SquadRim2024"
    infoText.TextColor3 = Color3.fromRGB(106, 122, 148)
    infoText.TextSize = 12
    infoText.Font = Enum.Font.SourceSans
    infoText.Parent = mainFrame

    local tgText = Instance.new("TextLabel")
    tgText.Size = UDim2.new(1, 0, 0, 20)
    tgText.Position = UDim2.new(0, 0, 0, 225)
    tgText.BackgroundTransparency = 1
    tgText.Text = "Telegram: t.me/squadrim1"
    tgText.TextColor3 = Color3.fromRGB(232, 48, 48)
    tgText.TextSize = 12
    tgText.Font = Enum.Font.SourceSans
    tgText.Parent = mainFrame

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
            
            print("=== SQUADRIM DLC PRO v15.1 | ImGUI Style | ЗАПУЩЕН ===")
            print("Insert = Меню | F7 = FreeCam | End = Выгрузка")
        else
            textBox.Text = ""
            textBox.PlaceholderText = "НЕВЕРНЫЙ КЛЮЧ!"
            textBox.BackgroundColor3 = Color3.fromRGB(80, 40, 50)
            ShowNotification("❌ Неверный ключ!", true)
            task.wait(1.5)
            textBox.PlaceholderText = "Введите ключ"
            textBox.BackgroundColor3 = Color3.fromRGB(19, 23, 32)
        end
    end)
end

ShowAuth()
