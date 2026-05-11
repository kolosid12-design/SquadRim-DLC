--[[ 
    SQUADRIM PRESTIGE v17.5 | THE OMNI-UPDATE
    Features: Legit, Rage, Visuals, Misc, Configs, Auth
    Password: SquadRim2024
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- ========== ГЛОБАЛЬНЫЕ НАСТРОЙКИ ==========
_G.Settings = {
    Auth = false,
    Legit = {Aimbot = false, Smooth = 15, FOV = 100, DrawFOV = true, Trigger = false},
    Rage = {Silent = false, FOV = 300, DrawFOV = false},
    Visuals = {ESP = false, Box = false, Chams = false, Skelet = false, Health = false},
    Misc = {Fly = false, Noclip = false, Freecam = false, Speed = 16},
    Binds = {Menu = Enum.KeyCode.Insert}
}

-- ========== UI ЭЛЕМЕНТЫ (DRAWING) ==========
local L_FOV = Drawing.new("Circle")
local R_FOV = Drawing.new("Circle")
local Storage = {}

-- ========== АВТОРИЗАЦИЯ ==========
local function InitAuth()
    local AuthGui = Instance.new("ScreenGui", CoreGui)
    local Frame = Instance.new("Frame", AuthGui)
    Frame.Size = UDim2.new(0, 300, 0, 180)
    Frame.Position = UDim2.new(0.5, -150, 0.5, -90)
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Instance.new("UICorner", Frame)

    local Title = Instance.new("TextLabel", Frame)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = "SQUADRIM LOGIN"
    Title.TextColor3 = Color3.new(1, 0, 0)
    Title.BackgroundTransparency = 1

    local Input = Instance.new("TextBox", Frame)
    Input.Size = UDim2.new(0.8, 0, 0, 35)
    Input.Position = UDim2.new(0.1, 0, 0.35, 0)
    Input.PlaceholderText = "Password..."
    Input.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Input.TextColor3 = Color3.new(1,1,1)

    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(0.8, 0, 0, 35)
    Btn.Position = UDim2.new(0.1, 0, 0.65, 0)
    Btn.Text = "ACCESS"
    Btn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    Btn.TextColor3 = Color3.new(1,1,1)

    Btn.MouseButton1Click:Connect(function()
        if Input.Text == "SquadRim2024" then
            _G.Settings.Auth = true
            AuthGui:Destroy()
            print("Welcome to SquadRim")
        else
            Btn.Text = "DENIED"
            task.wait(1)
            Btn.Text = "ACCESS"
        end
    end)
end

-- ========== HUD ==========
local function CreateHUD()
    local Hud = Instance.new("ScreenGui", CoreGui)
    local Bar = Instance.new("Frame", Hud)
    Bar.Size = UDim2.new(0, 400, 0, 26)
    Bar.Position = UDim2.new(0.5, -200, 0, 10)
    Bar.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    
    local Grad = Instance.new("UIGradient", Bar)
    Grad.Color = ColorSequence.new(Color3.fromRGB(255,0,0), Color3.fromRGB(50,0,0))

    local Label = Instance.new("TextLabel", Bar)
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.Font = Enum.Font.Code
    
    RunService.Heartbeat:Connect(function()
        local fps = math.floor(1/RunService.Heartbeat:Wait())
        Label.Text = string.format("| t.me/squadrim1 | FREE | Developer | [%d FPS] |", fps)
    end)
end

-- ========== ФУНКЦИИ VISUALS (ESP/SKELET/CHAMS) ==========
local function CreateESP(plr)
    Storage[plr] = {
        Box = Drawing.new("Square"),
        Skel = {}, -- Тут будут линии для скелета
        Name = Drawing.new("Text")
    }
end

local function UpdateVisuals()
    if not _G.Settings.Auth then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local char = plr.Character
            local hrp = char.HumanoidRootPart
            local hum = char:FindFirstChild("Humanoid")
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            -- Chams Logic
            local highlight = char:FindFirstChild("SR_Highlight")
            if _G.Settings.Visuals.Chams then
                if not highlight then
                    highlight = Instance.new("Highlight", char)
                    highlight.Name = "SR_Highlight"
                end
                highlight.Enabled = true
                highlight.FillColor = Color3.new(1,0,0)
            elseif highlight then
                highlight.Enabled = false
            end

            -- ESP Box Logic
            if not Storage[plr] then CreateESP(plr) end
            local s = Storage[plr]
            if onScreen and _G.Settings.Visuals.Box then
                local size = 2000 / pos.Z
                s.Box.Visible = true
                s.Box.Size = Vector2.new(size, size * 1.5)
                s.Box.Position = Vector2.new(pos.X - size/2, pos.Y - size/0.75)
                s.Box.Color = Color3.new(1,0,0)
            else
                s.Box.Visible = false
            end
        end
    end
end

-- ========== RAGE / LEGIT LOGIC ==========
local function GetTarget(fov, partName)
    local target, min = nil, fov
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild(partName) then
            local p = plr.Character[partName]
            local pos, os = Camera:WorldToViewportPoint(p.Position)
            if os then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if dist < min then
                    min = dist
                    target = p
                end
            end
        end
    end
    return target
end

-- ========== MAIN LOOP ==========
RunService.RenderStepped:Connect(function()
    if not _G.Settings.Auth then return end
    
    -- FOV Rendering
    L_FOV.Visible = _G.Settings.Legit.DrawFOV
    L_FOV.Radius = _G.Settings.Legit.FOV
    L_FOV.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    
    R_FOV.Visible = _G.Settings.Rage.DrawFOV
    R_FOV.Radius = _G.Settings.Rage.FOV
    R_FOV.Position = Vector2.new(Mouse.X, Mouse.Y + 36)

    -- Legit Aimbot
    if _G.Settings.Legit.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t = GetTarget(_G.Settings.Legit.FOV, "Head")
        if t then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, t.Position), (1/(_G.Settings.Legit.Smooth + 1)))
        end
    end

    -- Triggerbot
    if _G.Settings.Legit.Trigger and Mouse.Target then
        local p = Players:GetPlayerFromCharacter(Mouse.Target.Parent)
        if p and p ~= LocalPlayer then mouse1click() end
    end

    UpdateVisuals()
end)

-- ========== NOCLIP & FLY ==========
RunService.Stepped:Connect(function()
    if _G.Settings.Misc.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- ========== МЕНЮ (RESTORED & EXPANDED) ==========
local MainGui = Instance.new("ScreenGui", CoreGui)
local MenuFrame = Instance.new("Frame", MainGui)
MenuFrame.Size = UDim2.new(0, 500, 0, 350)
MenuFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MenuFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MenuFrame.Visible = false
Instance.new("UICorner", MenuFrame)

-- Вкладки (Создаем динамически)
local Tabs = {Legit = {}, Rage = {}, Visuals = {}, Misc = {}, Configs = {}}
local TabContainer = Instance.new("Frame", MenuFrame)
TabContainer.Size = UDim2.new(0, 100, 1, 0)
TabContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)

local PageContainer = Instance.new("Frame", MenuFrame)
PageContainer.Position = UDim2.new(0, 110, 0, 10)
PageContainer.Size = UDim2.new(1, -120, 1, -20)
PageContainer.BackgroundTransparency = 1

local function CreateToggle(parent, text, default, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, 0, 0, 30)
    b.Text = text .. ": " .. (default and "ON" or "OFF")
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    b.TextColor3 = Color3.new(1,1,1)
    local state = default
    b.MouseButton1Click:Connect(function()
        state = not state
        b.Text = text .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)
end

-- Наполнение LEGIT
CreateToggle(PageContainer, "Aimbot", false, function(v) _G.Settings.Legit.Aimbot = v end)
CreateToggle(PageContainer, "Draw FOV", true, function(v) _G.Settings.Legit.DrawFOV = v end)
CreateToggle(PageContainer, "Triggerbot", false, function(v) _G.Settings.Legit.Trigger = v end)

-- Наполнение VISUALS
CreateToggle(PageContainer, "Box ESP", false, function(v) _G.Settings.Visuals.Box = v end)
CreateToggle(PageContainer, "Chams", false, function(v) _G.Settings.Visuals.Chams = v end)

-- Наполнение MISC
CreateToggle(PageContainer, "Noclip", false, function(v) _G.Settings.Misc.Noclip = v end)

-- Открытие меню
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == _G.Settings.Binds.Menu then
        MenuFrame.Visible = not MenuFrame.Visible
    end
end)

InitAuth()
CreateHUD()
