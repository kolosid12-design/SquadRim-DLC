-- SWILL | SquadRim DLC PRO | v6.0 | FULLY WORKING
-- Insert = Меню | Все функции работают

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

-- ========== СОСТОЯНИЯ ==========
local state = {
    menu = true,
    rage = {silent = false, fov = 150},
    legit = {trigger = false, aimbot = false},
    visuals = {esp = false, tracers = false, arrows = false, fly = false, noclip = false},
    extra = {bhop = false, speed = 16}
}

local connections = {}
local bodyVel = nil
local flyActive = false

-- ========== GUI СОЗДАНИЕ ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SquadRim_Menu"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false
screenGui.Enabled = true

-- ========== ESP СИСТЕМА ==========
local espFolder = Instance.new("Folder")
espFolder.Name = "SquadRim_ESP"
espFolder.Parent = CoreGui

local espObjects = {}

local function ClearESP()
    for _, obj in pairs(espObjects) do
        pcall(function() obj:Destroy() end)
    end
    espObjects = {}
end

local function UpdateESP()
    ClearESP()
    if not state.visuals.esp and not state.visuals.tracers and not state.visuals.arrows then return end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            local head = plr.Character:FindFirstChild("Head")
            local hum = plr.Character:FindFirstChild("Humanoid")
            if root and head and hum and hum.Health > 0 then
                local vec, onScreen = Camera:WorldToViewportPoint(root.Position)
                local headVec, _ = Camera:WorldToViewportPoint(head.Position)
                local dist = (root.Position - (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.new())).Magnitude
                
                if state.visuals.esp and onScreen then
                    local height = headVec.Y - vec.Y
                    local width = height * 0.6
                    
                    local box = Instance.new("Frame")
                    box.Size = UDim2.new(0, math.abs(width), 0, math.abs(height))
                    box.Position = UDim2.new(0, vec.X - width/2, 0, vec.Y)
                    box.BackgroundTransparency = 0.8
                    box.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    box.BorderSizePixel = 2
                    box.BorderColor3 = Color3.fromRGB(255, 255, 255)
                    box.Visible = onScreen
                    box.Parent = espFolder
                    table.insert(espObjects, box)
                    
                    local nameTag = Instance.new("TextLabel")
                    nameTag.Size = UDim2.new(0, width + 20, 0, 16)
                    nameTag.Position = UDim2.new(0, -10, 0, -18)
                    nameTag.Text = string.format("%s [%.0fm] [%d%%]", plr.Name, dist, math.floor(hum.Health))
                    nameTag.TextColor3 = hum.Health > 50 and Color3.fromRGB(0, 255, 0) or (hum.Health > 25 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 0, 0))
                    nameTag.TextSize = 10
                    nameTag.Font = Enum.Font.GothamBold
                    nameTag.BackgroundTransparency = 0.5
                    nameTag.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    nameTag.Parent = box
                    table.insert(espObjects, nameTag)
                end
                
                if state.visuals.tracers and onScreen then
                    local tracer = Instance.new("Frame")
                    tracer.Size = UDim2.new(0, 2, 0, vec.Y)
                    tracer.Position = UDim2.new(0, vec.X, 0, 0)
                    tracer.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                    tracer.BackgroundTransparency = 0.3
                    tracer.Parent = espFolder
                    table.insert(espObjects, tracer)
                end
                
                if state.visuals.arrows and not onScreen then
                    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                    local dir = (root.Position - Camera.CFrame.Position).Unit
                    local angle = math.atan2(dir.Y, dir.X)
                    local arrowPos = center + Vector2.new(math.cos(angle), math.sin(angle)) * 100
                    
                    local arrow = Instance.new("TextLabel")
                    arrow.Size = UDim2.new(0, 25, 0, 25)
                    arrow.Position = UDim2.new(0, arrowPos.X - 12, 0, arrowPos.Y - 12)
                    arrow.Text = "⬆️"
                    arrow.TextSize = 20
                    arrow.BackgroundTransparency = 1
                    arrow.TextColor3 = Color3.fromRGB(255, 255, 0)
                    arrow.Parent = espFolder
                    table.insert(espObjects, arrow)
                end
            end
        end
    end
end

-- ========== FOV КРУГ ==========
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Transparency = 0.5

-- ========== AIMBOT ФУНКЦИИ ==========
local function GetClosestPlayer()
    local target = nil
    local closestDist = state.rage.fov
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
    return target
end

-- Silent Aim через Hook
local function SetupSilentAim()
    local mt = getrawmetatable(game)
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

-- Legit Aimbot
local function SetupLegitAimbot()
    table.insert(connections, RunService.RenderStepped:Connect(function()
        if state.legit.aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = GetClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = target.Character.HumanoidRootPart.Position
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            end
        end
    end))
end

-- Triggerbot
local function SetupTriggerbot()
    table.insert(connections, RunService.RenderStepped:Connect(function()
        if state.legit.trigger then
            local target = GetClosestPlayer()
            if target then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.02)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
        end
    end))
end

-- ========== FLY СИСТЕМА ==========
local function SetupFly()
    table.insert(connections, RunService.RenderStepped:Connect(function()
        if not state.visuals.fly then
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

-- ========== NOCLIP ==========
local function SetupNoclip()
    table.insert(connections, RunService.Stepped:Connect(function()
        if not state.visuals.noclip then return end
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

-- ========== BUNNY HOP ==========
local function SetupBHop()
    table.insert(connections, RunService.RenderStepped:Connect(function()
        if state.extra.bhop and LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum and (UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.D)) and hum.FloorMaterial ~= Enum.Material.Air then
                hum.Jump = true
            end
        end
    end))
end

-- ========== HUD ==========
local HUD = Instance.new("TextLabel")
HUD.Size = UDim2.new(0, 500, 0, 30)
HUD.Position = UDim2.new(0.01, 0, 0.01, 0)
HUD.BackgroundTransparency = 0.6
HUD.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
HUD.TextColor3 = Color3.fromRGB(0, 255, 255)
HUD.TextScaled = true
HUD.Font = Enum.Font.GothamBold
HUD.Parent = CoreGui

local function UpdateHUD()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    local active = 0
    if state.rage.silent then active = active + 1 end
    if state.legit.trigger then active = active + 1 end
    if state.legit.aimbot then active = active + 1 end
    if state.visuals.esp then active = active + 1 end
    if state.visuals.fly then active = active + 1 end
    if state.extra.bhop then active = active + 1 end
    HUD.Text = string.format("⚡ SQUADRIM DLC | %s | %d FPS | ACTIVE: %d", LocalPlayer.Name, fps, active)
end

-- ========== СОЗДАНИЕ GUI МЕНЮ ==========
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 500)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 100)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = screenGui
MainFrame.Visible = true

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
Title.Text = "SQUADRIM DLC PRO v6.0"
Title.TextColor3 = Color3.fromRGB(0, 210, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local Scrolling = Instance.new("ScrollingFrame")
Scrolling.Size = UDim2.new(1, -10, 1, -50)
Scrolling.Position = UDim2.new(0, 5, 0, 45)
Scrolling.BackgroundTransparency = 1
Scrolling.CanvasSize = UDim2.new(0, 0, 0, 600)
Scrolling.ScrollBarThickness = 4
Scrolling.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.Parent = Scrolling

local function MakeToggle(text, getter, setter)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundTransparency = 1
    frame.Parent = Scrolling
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 30)
    btn.Position = UDim2.new(0.8, 0, 0.12, 0)
    btn.BackgroundColor3 = getter() and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(80, 80, 90)
    btn.Text = getter() and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = frame
    
    btn.MouseButton1Click:Connect(function()
        local newVal = not getter()
        setter(newVal)
        btn.BackgroundColor3 = newVal and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(80, 80, 90)
        btn.Text = newVal and "ON" or "OFF"
        FOVCircle.Visible = state.rage.silent
    end)
end

local function MakeSlider(text, min, max, getter, setter)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 60)
    frame.BackgroundTransparency = 1
    frame.Parent = Scrolling
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = text .. ": " .. getter()
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.7, 0, 0, 6)
    slider.Position = UDim2.new(0, 0, 0, 30)
    slider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    slider.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((getter() - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    fill.Parent = slider
    
    local value = getter()
    local dragging = false
    
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    slider.InputEnded:Connect(function()
        dragging = false
    end)
    slider.MouseMoved:Connect(function()
        if dragging then
            local percent = math.clamp((Mouse.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * percent)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            label.Text = text .. ": " .. value
            setter(value)
            FOVCircle.Radius = state.rage.fov
        end
    end)
end

-- ========== СОЗДАНИЕ КНОПОК ==========
MakeToggle("Silent Aim", function() return state.rage.silent end, function(v) state.rage.silent = v end)
MakeSlider("FOV Range", 30, 300, function() return state.rage.fov end, function(v) state.rage.fov = v end)
MakeToggle("Triggerbot", function() return state.legit.trigger end, function(v) state.legit.trigger = v end)
MakeToggle("Legit Aimbot", function() return state.legit.aimbot end, function(v) state.legit.aimbot = v end)
MakeToggle("ESP Box", function() return state.visuals.esp end, function(v) state.visuals.esp = v end)
MakeToggle("Tracers", function() return state.visuals.tracers end, function(v) state.visuals.tracers = v end)
MakeToggle("Arrows", function() return state.visuals.arrows end, function(v) state.visuals.arrows = v end)
MakeToggle("Fly (WASD + Space/Shift)", function() return state.visuals.fly end, function(v) state.visuals.fly = v end)
MakeToggle("Noclip", function() return state.visuals.noclip end, function(v) state.visuals.noclip = v end)
MakeToggle("Bunny Hop", function() return state.extra.bhop end, function(v) state.extra.bhop = v end)

-- ========== ЗАПУСК ВСЕХ СИСТЕМ ==========
pcall(function() SetupSilentAim() end)
SetupLegitAimbot()
SetupTriggerbot()
SetupFly()
SetupNoclip()
SetupBHop()

-- ========== ОСНОВНЫЕ ЦИКЛЫ ==========
table.insert(connections, RunService.RenderStepped:Connect(function()
    UpdateESP()
    UpdateHUD()
    
    FOVCircle.Visible = state.rage.silent
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = state.rage.fov
end))

-- ========== INSERT TOGGLE ==========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        state.menu = not state.menu
        MainFrame.Visible = state.menu
    end
end)

print("SQUADRIM DLC PRO v6.0 | FULLY WORKING | INSERT = Menu")
print("Функции: Silent Aim, Triggerbot, Aimbot, ESP, Tracers, Arrows, Fly, Noclip, BHop")
