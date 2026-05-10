-- SWILL | SquadRim DLC / UNIT 1968 Style
-- Открытие/закрытие: INSERT
-- HUD: t.me/squadrim1 | DLC | FREE | Ник | FPS
-- Функции: Silent Aim (RAGE), Legit (Trigger + Aimbot), ESP, Tracers, Arrows, Fly, Noclip, Themes, Config

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

-- Глобальные переменные
local menuVisible = true
local currentFPS = 60

-- // HUD (всегда видимый, независимо от меню)
local HUD = Instance.new("TextLabel")
HUD.Size = UDim2.new(0, 450, 0, 30)
HUD.Position = UDim2.new(0.5, -225, 0.02, 0)
HUD.BackgroundTransparency = 0.6
HUD.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
HUD.TextColor3 = Color3.fromRGB(0, 255, 255)
HUD.TextScaled = true
HUD.Font = Enum.Font.GothamBold
HUD.ZIndex = 10
HUD.Parent = CoreGui

-- Обновление HUD
local function UpdateHUD()
    local playerName = LocalPlayer.Name
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    currentFPS = fps
    HUD.Text = string.format("| t.me/squadrim1 | DLC | FREE | %s | %d FPS |", playerName, fps)
end

-- Запуск обновления HUD
spawn(function()
    while true do
        UpdateHUD()
        task.wait(0.2)
    end
end)

-- // СОЗДАНИЕ МЕНЮ (основное)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SquadRim_DLC"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.Enabled = menuVisible

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 500)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 100)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Заголовок
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
Title.Text = "SquadRim DLC | RAGE + LEGIT"
Title.TextColor3 = Color3.fromRGB(255, 200, 100)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- Вкладки
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 35)
TabBar.Position = UDim2.new(0, 0, 0, 40)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local RageTab = Instance.new("TextButton")
RageTab.Size = UDim2.new(0.33, 0, 1, 0)
RageTab.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
RageTab.Text = "RAGE"
RageTab.Parent = TabBar

local LegitTab = Instance.new("TextButton")
LegitTab.Size = UDim2.new(0.33, 0, 1, 0)
LegitTab.Position = UDim2.new(0.33, 0, 0, 0)
LegitTab.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
LegitTab.Text = "LEGIT"
LegitTab.Parent = TabBar

local VisualTab = Instance.new("TextButton")
VisualTab.Size = UDim2.new(0.34, 0, 1, 0)
VisualTab.Position = UDim2.new(0.66, 0, 0, 0)
VisualTab.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
VisualTab.Text = "VISUALS"
VisualTab.Parent = TabBar

-- Контейнеры
local RageContainer = Instance.new("ScrollingFrame")
RageContainer.Size = UDim2.new(1, 0, 1, -85)
RageContainer.Position = UDim2.new(0, 0, 0, 80)
RageContainer.BackgroundTransparency = 1
RageContainer.Visible = true
RageContainer.Parent = MainFrame

local LegitContainer = Instance.new("ScrollingFrame")
LegitContainer.Size = UDim2.new(1, 0, 1, -85)
LegitContainer.Position = UDim2.new(0, 0, 0, 80)
LegitContainer.BackgroundTransparency = 1
LegitContainer.Visible = false
LegitContainer.Parent = MainFrame

local VisualContainer = Instance.new("ScrollingFrame")
VisualContainer.Size = UDim2.new(1, 0, 1, -85)
VisualContainer.Position = UDim2.new(0, 0, 0, 80)
VisualContainer.BackgroundTransparency = 1
VisualContainer.Visible = false
VisualContainer.Parent = MainFrame

for _, container in ipairs({RageContainer, LegitContainer, VisualContainer}) do
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container
end

-- Функции UI
local function MakeSwitch(parent, text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 35)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 60, 0, 25)
    btn.Position = UDim2.new(0.85, 0, 0.15, 0)
    btn.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Parent = frame
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = state and "ON" or "OFF"
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(80,80,90)
        callback(state)
    end)
    return function() return state end
end

local function MakeSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0.95, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = text .. ": " .. default
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200,200,200)
    label.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.8, 0, 0, 8)
    slider.Position = UDim2.new(0, 0, 0, 25)
    slider.BackgroundColor3 = Color3.fromRGB(60,60,70)
    slider.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
    fill.Parent = slider
    
    local value = default
    local dragging = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    slider.MouseMoved:Connect(function()
        if dragging then
            local percent = math.clamp((Mouse.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max-min) * percent)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            label.Text = text .. ": " .. value
            callback(value)
        end
    end)
    return function() return value end
end

-- Состояния
local rage = {silent = false, fov = 30}
local legit = {trigger = false, aimbot = false, smooth = 5}
local visuals = {esp = false, tracers = false, arrows = false, fly = false, noclip = false}
local themes = {current = "Dark", colors = {dark = Color3.fromRGB(25,25,35), light = Color3.fromRGB(240,240,250)}}

-- RAGE
MakeSwitch(RageContainer, "Silent Aim (RAGE)", function(v) rage.silent = v end)
MakeSlider(RageContainer, "Silent FOV", 5, 90, 30, function(v) rage.fov = v end)

-- LEGIT
MakeSwitch(LegitContainer, "Triggerbot (auto shoot)", function(v) legit.trigger = v end)
MakeSwitch(LegitContainer, "Legit Aimbot (smooth)", function(v) legit.aimbot = v end)
MakeSlider(LegitContainer, "Smoothness", 1, 20, 5, function(v) legit.smooth = v end)

-- VISUALS
local flyActive = false
local noclipActive = false

MakeSwitch(VisualContainer, "ESP (Box + Name)", function(v) visuals.esp = v end)
MakeSwitch(VisualContainer, "Tracers", function(v) visuals.tracers = v end)
MakeSwitch(VisualContainer, "Arrows (off-screen)", function(v) visuals.arrows = v end)

-- Fly система
MakeSwitch(VisualContainer, "Fly (WASD + Space/Shift)", function(v)
    visuals.fly = v
    if v then
        if noclipActive then noclipActive = false; visuals.noclip = false end
        flyActive = true
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(1e9,1e9,1e9)
            bv.Parent = char.HumanoidRootPart
            local ctrl
            ctrl = RunService.RenderStepped:Connect(function()
                if not visuals.fly then 
                    if bv then bv:Destroy() end
                    ctrl:Disconnect()
                    return 
                end
                local dir = Vector3.new()
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
                bv.Velocity = dir * 70
            end)
        end
    else
        flyActive = false
    end
end)

-- Noclip система
MakeSwitch(VisualContainer, "Noclip (walk through)", function(v)
    visuals.noclip = v
    if v then
        if flyActive then flyActive = false; visuals.fly = false end
        noclipActive = true
    else
        noclipActive = false
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end
    
    game:GetService("RunService").Stepped:Connect(function()
        if not visuals.noclip then return end
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end)

-- Темы
MakeSwitch(VisualContainer, "Light Theme (else Dark)", function(v)
    MainFrame.BackgroundColor3 = v and Color3.fromRGB(240,240,250) or Color3.fromRGB(25,25,35)
    Title.BackgroundColor3 = v and Color3.fromRGB(200,200,220) or Color3.fromRGB(45,45,60)
    Title.TextColor3 = v and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,200,100)
end)

-- Сохранение/загрузка
local function saveConfig()
    local cfg = {rage = rage, legit = legit, visuals = visuals, theme = themes.current}
    writefile("SquadRim_Config.json", HttpService:JSONEncode(cfg))
    HUD.Text = "| t.me/squadrim1 | DLC | FREE | " .. LocalPlayer.Name .. " | CONFIG SAVED |"
    task.wait(1.5)
end
local function loadConfig()
    if isfile("SquadRim_Config.json") then
        local data = HttpService:JSONDecode(readfile("SquadRim_Config.json"))
        rage = data.rage; legit = data.legit; visuals = data.visuais; themes.current = data.theme
        HUD.Text = "| t.me/squadrim1 | DLC | FREE | " .. LocalPlayer.Name .. " | CONFIG LOADED |"
        task.wait(1.5)
    end
end

MakeSwitch(VisualContainer, "Save Config", function(v) if v then saveConfig() end end)
MakeSwitch(VisualContainer, "Load Config", function(v) if v then loadConfig() end end)

-- === AIMBOT LOGIC ===
local function getClosest()
    local closest, dist = nil, 1e9
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character.Humanoid.Health > 0 then
            local scr = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            local d = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(scr.X, scr.Y)).Magnitude
            if d < dist then closest = plr; dist = d end
        end
    end
    return closest
end

-- Triggerbot
RunService.RenderStepped:Connect(function()
    if legit.trigger and Mouse.Target and Mouse.Target.Parent and Mouse.Target.Parent:FindFirstChild("Humanoid") then
        mouse1click()
    end
end)

-- Legit Aimbot
RunService.RenderStepped:Connect(function()
    if legit.aimbot and UserInputService:IsKeyDown(Enum.KeyCode.RightButton) then
        local target = getClosest()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local aimPos = target.Character.HumanoidRootPart.Position
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, aimPos), 1/legit.smooth)
        end
    end
end)

-- Silent Aim (RAGE)
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local tool = char:FindFirstChildWhichIsA("Tool")
    if tool then
        tool.Activated:Connect(function()
            if rage.silent then
                local target = getClosest()
                if target and target.Character then
                    local targetPos = target.Character.HumanoidRootPart.Position
                    if tool:FindFirstChild("Handle") then
                        tool.Handle.CFrame = CFrame.new(tool.Handle.CFrame.Position, targetPos)
                    end
                end
            end
        end)
    end
end)

-- Переключение вкладок
RageTab.MouseButton1Click:Connect(function()
    RageContainer.Visible = true; LegitContainer.Visible = false; VisualContainer.Visible = false
end)
LegitTab.MouseButton1Click:Connect(function()
    RageContainer.Visible = false; LegitContainer.Visible = true; VisualContainer.Visible = false
end)
VisualTab.MouseButton1Click:Connect(function()
    RageContainer.Visible = false; LegitContainer.Visible = false; VisualContainer.Visible = true
end)

-- === ОТКРЫТИЕ/ЗАКРЫТИЕ ПО INSERT ===
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        menuVisible = not menuVisible
        ScreenGui.Enabled = menuVisible
    end
end)

print("SWILL | SquadRim DLC Loaded. INSERT to toggle menu. HUD updated.")