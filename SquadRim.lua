--[[
    SQUADRIM DLC | ImGUI STYLE CHEAT
    Telegram: t.me/squadrim1
    Password: SquadRim2024
    Insert = Menu | End = Unload
]]

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

-- ========== АВТОРИЗАЦИЯ ==========
local function ShowAuth()
    local AuthGui = Instance.new("ScreenGui")
    AuthGui.Name = "SquadRim_Auth"
    AuthGui.Parent = CoreGui
    AuthGui.ResetOnSpawn = false

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 350, 0, 220)
    Frame.Position = UDim2.new(0.5, -175, 0.5, -110)
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    Frame.BorderSizePixel = 2
    Frame.BorderColor3 = Color3.fromRGB(200, 50, 50)
    Frame.Active = true
    Frame.Draggable = true
    Frame.Parent = AuthGui
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 45)
    Title.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
    Title.Text = "SQUADRIM DLC"
    Title.TextColor3 = Color3.fromRGB(200, 50, 50)
    Title.TextSize = 22
    Title.Font = Enum.Font.SourceSansBold
    Title.Parent = Frame
    Title.TextScaled = true

    local Sub = Instance.new("TextLabel")
    Sub.Size = UDim2.new(1, 0, 0, 25)
    Sub.Position = UDim2.new(0, 0, 0, 50)
    Sub.BackgroundTransparency = 1
    Sub.Text = "Введите пароль для доступа"
    Sub.TextColor3 = Color3.fromRGB(180, 180, 200)
    Sub.TextSize = 13
    Sub.Font = Enum.Font.SourceSans
    Sub.Parent = Frame

    local Input = Instance.new("TextBox")
    Input.Size = UDim2.new(0.8, 0, 0, 38)
    Input.Position = UDim2.new(0.1, 0, 0, 85)
    Input.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    Input.BorderSizePixel = 1
    Input.BorderColor3 = Color3.fromRGB(55, 60, 75)
    Input.PlaceholderText = "Пароль..."
    Input.TextColor3 = Color3.fromRGB(255, 255, 255)
    Input.TextSize = 14
    Input.Font = Enum.Font.SourceSans
    Input.Parent = Frame
    Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 5)

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.35, 0, 0, 38)
    Btn.Position = UDim2.new(0.1, 0, 0, 140)
    Btn.Text = "ВОЙТИ"
    Btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 14
    Btn.Font = Enum.Font.SourceSansBold
    Btn.Parent = Frame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)

    local GetKey = Instance.new("TextButton")
    GetKey.Size = UDim2.new(0.35, 0, 0, 38)
    GetKey.Position = UDim2.new(0.55, 0, 0, 140)
    GetKey.Text = "TG ССЫЛКА"
    GetKey.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    GetKey.BorderSizePixel = 1
    GetKey.BorderColor3 = Color3.fromRGB(200, 50, 50)
    GetKey.TextColor3 = Color3.fromRGB(200, 50, 50)
    GetKey.TextSize = 13
    GetKey.Font = Enum.Font.SourceSansBold
    GetKey.Parent = Frame
    Instance.new("UICorner", GetKey).CornerRadius = UDim.new(0, 5)

    local Info = Instance.new("TextLabel")
    Info.Size = UDim2.new(1, 0, 0, 20)
    Info.Position = UDim2.new(0, 0, 0, 195)
    Info.BackgroundTransparency = 1
    Info.Text = "Telegram: t.me/squadrim1"
    Info.TextColor3 = Color3.fromRGB(200, 50, 50)
    Info.TextSize = 11
    Info.Font = Enum.Font.SourceSans
    Info.Parent = Frame

    GetKey.MouseButton1Click:Connect(function()
        if setclipboard then setclipboard("t.me/squadrim1") elseif toclipboard then toclipboard("t.me/squadrim1") end
        local notif = Instance.new("TextLabel", AuthGui)
        notif.Size = UDim2.new(0, 250, 0, 30)
        notif.Position = UDim2.new(0.5, -125, 0.7, 0)
        notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        notif.BackgroundTransparency = 0.5
        notif.Text = "✅ Ссылка скопирована!"
        notif.TextColor3 = Color3.fromRGB(0, 255, 0)
        task.delay(2, function() notif:Destroy() end)
    end)

    Btn.MouseButton1Click:Connect(function()
        if Input.Text == "SquadRim2024" then
            AuthGui:Destroy()
            StartCheat()
        else
            Input.Text = ""
            Input.PlaceholderText = "НЕВЕРНЫЙ ПАРОЛЬ!"
            Input.BackgroundColor3 = Color3.fromRGB(80, 40, 50)
            task.wait(1.5)
            Input.PlaceholderText = "Пароль..."
            Input.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
        end
    end)
end

-- ========== НАСТРОЙКИ ==========
local Settings = {
    Legit = {aimbot = false, smooth = 15, fov = 100, drawFov = true, trigger = false, hitbox = "Head"},
    Rage = {silent = false, fov = 300, drawFov = false},
    Visuals = {esp = false, box = false, name = true, health = true, chams = false},
    Misc = {fly = false, noclip = false, speed = 16}
}

local connections = {}
local bodyVel = nil
local flyActive = false

-- ========== FOV КРУГИ ==========
local LegitFOV = Drawing.new("Circle")
LegitFOV.Thickness = 2
LegitFOV.Color = Color3.fromRGB(0, 200, 255)
LegitFOV.Filled = false
LegitFOV.Transparency = 0.5

local RageFOV = Drawing.new("Circle")
RageFOV.Thickness = 2
RageFOV.Color = Color3.fromRGB(255, 50, 50)
RageFOV.Filled = false
RageFOV.Transparency = 0.5

-- ========== ESP ==========
local Storage = {}
local espFolder = Instance.new("Folder", CoreGui)
espFolder.Name = "SquadRim_ESP"

local function ClearESP()
    for _, obj in pairs(Storage) do
        pcall(function()
            if obj.Box then obj.Box:Remove() end
            if obj.Name then obj.Name:Remove() end
            if obj.Health then obj.Health:Remove() end
            if obj.Highlight then obj.Highlight:Destroy() end
        end)
    end
    Storage = {}
end

local function UpdateESP()
    if not Settings.Visuals.esp then ClearESP(); return end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        
        if hrp and hum and hum.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                if not Storage[plr] then
                    Storage[plr] = {
                        Box = Drawing.new("Square"),
                        Name = Drawing.new("Text"),
                        Health = Drawing.new("Square"),
                        Highlight = Instance.new("Highlight")
                    }
                    Storage[plr].Box.Thickness = 1
                    Storage[plr].Box.Filled = false
                    Storage[plr].Name.Size = 13
                    Storage[plr].Name.Center = true
                    Storage[plr].Name.Outline = true
                    Storage[plr].Health.Thickness = 1
                    Storage[plr].Health.Filled = true
                    Storage[plr].Highlight.Parent = espFolder
                end
                
                local s = Storage[plr]
                local sizeX = 2000 / pos.Z
                local sizeY = 2800 / pos.Z
                local x, y = pos.X - sizeX/2, pos.Y - sizeY/1.2
                local hp = hum.Health / hum.MaxHealth
                local hpColor = hp > 0.5 and Color3.new(0,1,0) or (hp > 0.25 and Color3.new(1,0.5,0) or Color3.new(1,0,0))
                
                if Settings.Visuals.box then
                    s.Box.Visible = true
                    s.Box.Position = Vector2.new(x, y)
                    s.Box.Size = Vector2.new(sizeX, sizeY)
                    s.Box.Color = Color3.new(1, 0, 0)
                else
                    s.Box.Visible = false
                end
                
                if Settings.Visuals.name then
                    s.Name.Visible = true
                    s.Name.Position = Vector2.new(pos.X, y - 15)
                    s.Name.Text = plr.Name
                    s.Name.Color = Color3.new(1, 1, 1)
                else
                    s.Name.Visible = false
                end
                
                if Settings.Visuals.health then
                    s.Health.Visible = true
                    s.Health.Position = Vector2.new(x - 6, y + (sizeY * (1 - hp)))
                    s.Health.Size = Vector2.new(3, sizeY * hp)
                    s.Health.Color = hpColor
                else
                    s.Health.Visible = false
                end
                
                if Settings.Visuals.chams then
                    s.Highlight.Enabled = true
                    s.Highlight.Adornee = char
                    s.Highlight.FillColor = Color3.new(1, 0, 0)
                    s.Highlight.FillTransparency = 0.5
                else
                    s.Highlight.Enabled = false
                end
            else
                if Storage[plr] then
                    if Storage[plr].Box then Storage[plr].Box.Visible = false end
                    if Storage[plr].Name then Storage[plr].Name.Visible = false end
                    if Storage[plr].Health then Storage[plr].Health.Visible = false end
                end
            end
        end
    end
end

-- ========== AIMBOT ==========
local function GetTarget(fov, hitbox)
    local target, min = nil, fov
    local hitboxName = hitbox == "Head" and "Head" or "HumanoidRootPart"
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local part = plr.Character:FindFirstChild(hitboxName)
            local hum = plr.Character:FindFirstChild("Humanoid")
            if part and hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if dist < min then
                        min = dist
                        target = part
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
            if Settings.Rage.silent and self == Mouse and key == "Hit" then
                local target = GetTarget(Settings.Rage.fov, "Head")
                if target then return target.CFrame end
            end
            return oldIndex(self, key)
        end
        setreadonly(mt, true)
    end
end)

-- ========== FLY / NOCLIP ==========
local function SetupFly()
    table.insert(connections, RunService.RenderStepped:Connect(function()
        if not Settings.Misc.fly then
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
        
        bodyVel.Velocity = dir.Magnitude > 0 and dir.Unit * Settings.Misc.speed or Vector3.new(0, 0, 0)
    end))
end

local function SetupNoclip()
    table.insert(connections, RunService.Stepped:Connect(function()
        if not Settings.Misc.noclip then return end
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

-- ========== CONFIG ==========
local function SaveConfig()
    writefile("SquadRim_Config.json", HttpService:JSONEncode({
        Legit = Settings.Legit, Rage = Settings.Rage, Visuals = Settings.Visuals, Misc = Settings.Misc
    }))
    local notif = Instance.new("TextLabel", CoreGui)
    notif.Size = UDim2.new(0, 200, 0, 30)
    notif.Position = UDim2.new(0.5, -100, 0.3, 0)
    notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notif.BackgroundTransparency = 0.5
    notif.Text = "✅ Config Saved"
    notif.TextColor3 = Color3.fromRGB(0, 255, 0)
    task.delay(2, function() notif:Destroy() end)
end

local function LoadConfig()
    if isfile("SquadRim_Config.json") then
        local data = HttpService:JSONDecode(readfile("SquadRim_Config.json"))
        Settings.Legit = data.Legit or Settings.Legit
        Settings.Rage = data.Rage or Settings.Rage
        Settings.Visuals = data.Visuals or Settings.Visuals
        Settings.Misc = data.Misc or Settings.Misc
        local notif = Instance.new("TextLabel", CoreGui)
        notif.Size = UDim2.new(0, 200, 0, 30)
        notif.Position = UDim2.new(0.5, -100, 0.3, 0)
        notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        notif.BackgroundTransparency = 0.5
        notif.Text = "✅ Config Loaded"
        notif.TextColor3 = Color3.fromRGB(0, 255, 0)
        task.delay(2, function() notif:Destroy() end)
    end
end

-- ========== HUD ==========
local HUD = Instance.new("TextLabel", CoreGui)
HUD.Size = UDim2.new(0, 400, 0, 26)
HUD.Position = UDim2.new(0.5, -200, 0, 10)
HUD.BackgroundColor3 = Color3.fromRGB(10, 10, 18)
HUD.BackgroundTransparency = 0.2
HUD.BorderSizePixel = 1
HUD.BorderColor3 = Color3.fromRGB(200, 50, 50)
HUD.TextColor3 = Color3.fromRGB(200, 50, 50)
HUD.TextSize = 13
HUD.Font = Enum.Font.SourceSansBold
Instance.new("UICorner", HUD).CornerRadius = UDim.new(0, 4)

local fpsValues = {}
local function UpdateHUD()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    table.insert(fpsValues, fps)
    if #fpsValues > 10 then table.remove(fpsValues, 1) end
    local sum = 0 for _, v in pairs(fpsValues) do sum = sum + v end
    HUD.Text = string.format("| t.me/squadrim1 | DLC | FREE | %s | %d FPS |", LocalPlayer.Name, math.floor(sum / #fpsValues))
end

-- ========== ImGUI МЕНЮ ==========
local MenuGui = nil
local MenuFrame = nil
local currentTab = "Legit"

local function CreateMenu()
    MenuGui = Instance.new("ScreenGui", CoreGui)
    MenuGui.Name = "SquadRim_Menu"
    MenuGui.ResetOnSpawn = false
    
    MenuFrame = Instance.new("Frame", MenuGui)
    MenuFrame.Size = UDim2.new(0, 550, 0, 420)
    MenuFrame.Position = UDim2.new(0.5, -275, 0.5, -210)
    MenuFrame.BackgroundColor3 = Color3.fromRGB(14, 16, 24)
    MenuFrame.BorderSizePixel = 2
    MenuFrame.BorderColor3 = Color3.fromRGB(200, 50, 50)
    MenuFrame.Active = true
    MenuFrame.Draggable = true
    MenuFrame.Visible = false
    Instance.new("UICorner", MenuFrame).CornerRadius = UDim.new(0, 8)
    
    -- Header
    local Header = Instance.new("Frame", MenuFrame)
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
    Header.BorderSizePixel = 0
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)
    
    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, -50, 0, 45)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "SQUADRIM DLC | ImGUI"
    Title.TextColor3 = Color3.fromRGB(200, 50, 50)
    Title.TextSize = 18
    Title.Font = Enum.Font.SourceSansBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -40, 0, 8)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 32, 44)
    CloseBtn.BorderSizePixel = 1
    CloseBtn.BorderColor3 = Color3.fromRGB(60, 65, 80)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)
    CloseBtn.MouseButton1Click:Connect(function() MenuFrame.Visible = false end)
    
    -- Tabs
    local TabBar = Instance.new("Frame", MenuFrame)
    TabBar.Size = UDim2.new(1, 0, 0, 40)
    TabBar.Position = UDim2.new(0, 0, 0, 45)
    TabBar.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
    TabBar.BorderSizePixel = 1
    TabBar.BorderColor3 = Color3.fromRGB(30, 35, 45)
    
    local Tabs = {"Legit", "Rage", "Visuals", "Misc", "Config"}
    local TabBtns = {}
    local Pages = {}
    
    for i, tab in ipairs(Tabs) do
        local Btn = Instance.new("TextButton", TabBar)
        Btn.Size = UDim2.new(0.2, 0, 1, 0)
        Btn.Position = UDim2.new((i-1)/5, 0, 0, 0)
        Btn.BackgroundColor3 = i == 1 and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(10, 12, 20)
        Btn.BorderSizePixel = 0
        Btn.Text = tab
        Btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        Btn.TextSize = 12
        Btn.Font = Enum.Font.SourceSansBold
        TabBtns[tab] = Btn
        
        local Page = Instance.new("ScrollingFrame", MenuFrame)
        Page.Size = UDim2.new(1, -20, 1, -105)
        Page.Position = UDim2.new(0, 10, 0, 95)
        Page.BackgroundTransparency = 1
        Page.Visible = (i == 1)
        Page.CanvasSize = UDim2.new(0, 0, 0, 400)
        Page.ScrollBarThickness = 4
        
        local Layout = Instance.new("UIListLayout", Page)
        Layout.Padding = UDim.new(0, 8)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        
        Pages[tab] = Page
        
        Btn.MouseButton1Click:Connect(function()
            for _, bt in pairs(TabBtns) do bt.BackgroundColor3 = Color3.fromRGB(10, 12, 20) end
            Btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            for _, pg in pairs(Pages) do pg.Visible = false end
            Page.Visible = true
        end)
    end
    
    local function MakeToggle(parent, text, getter, setter)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1, 0, 0, 35)
        btn.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(45, 50, 65)
        btn.Text = text .. ": " .. (getter() and "ON" or "OFF")
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.TextSize = 12
        btn.Font = Enum.Font.SourceSansBold
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseButton1Click:Connect(function()
            local newVal = not getter()
            setter(newVal)
            btn.Text = text .. ": " .. (newVal and "ON" or "OFF")
        end)
    end
    
    local function MakeSlider(parent, text, min, max, getter, setter)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, 0, 0, 55)
        frame.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
        frame.BorderSizePixel = 1
        frame.BorderColor3 = Color3.fromRGB(45, 50, 65)
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
        
        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(0.6, 0, 0, 22)
        label.Position = UDim2.new(0, 8, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(200, 200, 220)
        label.TextSize = 12
        label.Font = Enum.Font.SourceSans
        
        local valueLabel = Instance.new("TextLabel", frame)
        valueLabel.Size = UDim2.new(0.3, 0, 0, 22)
        valueLabel.Position = UDim2.new(0.7, 0, 0, 5)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(getter())
        valueLabel.TextColor3 = Color3.fromRGB(200, 50, 50)
        valueLabel.TextSize = 11
        valueLabel.Font = Enum.Font.ShareTechMono
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        
        local track = Instance.new("Frame", frame)
        track.Size = UDim2.new(0.96, 0, 0, 4)
        track.Position = UDim2.new(0.02, 0, 0, 38)
        track.BackgroundColor3 = Color3.fromRGB(45, 50, 65)
        track.BorderSizePixel = 0
        
        local fill = Instance.new("Frame", track)
        fill.Size = UDim2.new((getter() - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        fill.BorderSizePixel = 0
        
        local knob = Instance.new("Frame", track)
        knob.Size = UDim2.new(0, 10, 0, 10)
        knob.Position = UDim2.new((getter() - min) / (max - min), -5, 0, -3)
        knob.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        knob.BorderSizePixel = 1
        knob.BorderColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        
        local dragging = false
        track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                local percent = math.clamp((Mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * percent)
                setter(val)
                fill.Size = UDim2.new(percent, 0, 1, 0)
                knob.Position = UDim2.new(percent, -5, 0, -3)
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
                knob.Position = UDim2.new(percent, -5, 0, -3)
                valueLabel.Text = tostring(val)
            end
        end)
    end
    
    local function MakeDropdown(parent, text, options, getter, setter)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, 0, 0, 55)
        frame.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
        frame.BorderSizePixel = 1
        frame.BorderColor3 = Color3.fromRGB(45, 50, 65)
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
        
        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, 0, 0, 20)
        label.Position = UDim2.new(0, 8, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(150, 160, 180)
        label.TextSize = 11
        label.Font = Enum.Font.SourceSans
        
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0.96, 0, 0, 30)
        btn.Position = UDim2.new(0.02, 0, 0, 25)
        btn.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(55, 60, 75)
        btn.Text = getter()
        btn.TextColor3 = Color3.fromRGB(200, 50, 50)
        btn.TextSize = 12
        btn.Font = Enum.Font.SourceSansBold
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
        
        local open = false
        local dropdown = nil
        btn.MouseButton1Click:Connect(function()
            if open and dropdown then dropdown:Destroy() end
            open = true
            dropdown = Instance.new("Frame", frame)
            dropdown.Size = UDim2.new(0.96, 0, 0, 30 * #options)
            dropdown.Position = UDim2.new(0.02, 0, 0, 55)
            dropdown.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
            dropdown.BorderSizePixel = 1
            dropdown.BorderColor3 = Color3.fromRGB(55, 60, 75)
            Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 3)
            
            for i, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton", dropdown)
                optBtn.Size = UDim2.new(1, 0, 0, 30)
                optBtn.Position = UDim2.new(0, 0, 0, 30 * (i-1))
                optBtn.BackgroundColor3 = Color3.fromRGB(40, 43, 55)
                optBtn.Text = opt
                optBtn.TextColor3 = Color3.fromRGB(200, 210, 220)
                optBtn.TextSize = 11
                optBtn.Font = Enum.Font.SourceSans
                optBtn.MouseButton1Click:Connect(function()
                    setter(opt)
                    btn.Text = opt
                    dropdown:Destroy()
                    open = false
                end)
            end
        end)
    end
    
    -- LEGIT PAGE
    MakeToggle(Pages["Legit"], "Legit Aimbot", function() return Settings.Legit.aimbot end, function(v) Settings.Legit.aimbot = v end)
    MakeSlider(Pages["Legit"], "Smoothness", 1, 50, function() return Settings.Legit.smooth end, function(v) Settings.Legit.smooth = v end)
    MakeSlider(Pages["Legit"], "FOV", 30, 300, function() return Settings.Legit.fov end, function(v) Settings.Legit.fov = v end)
    MakeToggle(Pages["Legit"], "Draw FOV", function() return Settings.Legit.drawFov end, function(v) Settings.Legit.drawFov = v end)
    MakeToggle(Pages["Legit"], "Triggerbot", function() return Settings.Legit.trigger end, function(v) Settings.Legit.trigger = v end)
    MakeDropdown(Pages["Legit"], "Hitbox", {"Head", "Body"}, function() return Settings.Legit.hitbox end, function(v) Settings.Legit.hitbox = v end)
    
    -- RAGE PAGE
    MakeToggle(Pages["Rage"], "Silent Aim", function() return Settings.Rage.silent end, function(v) Settings.Rage.silent = v end)
    MakeSlider(Pages["Rage"], "Silent FOV", 30, 500, function() return Settings.Rage.fov end, function(v) Settings.Rage.fov = v end)
    MakeToggle(Pages["Rage"], "Draw Silent FOV", function() return Settings.Rage.drawFov end, function(v) Settings.Rage.drawFov = v end)
    
    -- VISUALS PAGE
    MakeToggle(Pages["Visuals"], "ESP Master", function() return Settings.Visuals.esp end, function(v) Settings.Visuals.esp = v end)
    MakeToggle(Pages["Visuals"], "Box ESP", function() return Settings.Visuals.box end, function(v) Settings.Visuals.box = v end)
    MakeToggle(Pages["Visuals"], "Name Tags", function() return Settings.Visuals.name end, function(v) Settings.Visuals.name = v end)
    MakeToggle(Pages["Visuals"], "Health Bar", function() return Settings.Visuals.health end, function(v) Settings.Visuals.health = v end)
    MakeToggle(Pages["Visuals"], "Chams", function() return Settings.Visuals.chams end, function(v) Settings.Visuals.chams = v end)
    
    -- MISC PAGE
    MakeToggle(Pages["Misc"], "Fly Mode", function() return Settings.Misc.fly end, function(v) Settings.Misc.fly = v end)
    MakeToggle(Pages["Misc"], "Noclip", function() return Settings.Misc.noclip end, function(v) Settings.Misc.noclip = v end)
    MakeSlider(Pages["Misc"], "Fly Speed", 10, 120, function() return Settings.Misc.speed end, function(v) Settings.Misc.speed = v end)
    
    -- CONFIG PAGE
    local SaveBtn = Instance.new("TextButton", Pages["Config"])
    SaveBtn.Size = UDim2.new(1, 0, 0, 38)
    SaveBtn.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
    SaveBtn.BorderSizePixel = 1
    SaveBtn.BorderColor3 = Color3.fromRGB(45, 50, 65)
    SaveBtn.Text = "💾 SAVE CONFIG"
    SaveBtn.TextColor3 = Color3.fromRGB(80, 255, 120)
    SaveBtn.TextSize = 13
    SaveBtn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 4)
    SaveBtn.MouseButton1Click:Connect(SaveConfig)
    
    local LoadBtn = Instance.new("TextButton", Pages["Config"])
    LoadBtn.Size = UDim2.new(1, 0, 0, 38)
    LoadBtn.Position = UDim2.new(0, 0, 0, 46)
    LoadBtn.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
    LoadBtn.BorderSizePixel = 1
    LoadBtn.BorderColor3 = Color3.fromRGB(45, 50, 65)
    LoadBtn.Text = "📂 LOAD CONFIG"
    LoadBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
    LoadBtn.TextSize = 13
    LoadBtn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", LoadBtn).CornerRadius = UDim.new(0, 4)
    LoadBtn.MouseButton1Click:Connect(LoadConfig)
    
    local UnloadBtn = Instance.new("TextButton", Pages["Config"])
    UnloadBtn.Size = UDim2.new(1, 0, 0, 38)
    UnloadBtn.Position = UDim2.new(0, 0, 0, 92)
    UnloadBtn.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
    UnloadBtn.BorderSizePixel = 1
    UnloadBtn.BorderColor3 = Color3.fromRGB(200, 50, 50)
    UnloadBtn.Text = "⚠️ UNLOAD (END) ⚠️"
    UnloadBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
    UnloadBtn.TextSize = 13
    UnloadBtn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", UnloadBtn).CornerRadius = UDim.new(0, 4)
    UnloadBtn.MouseButton1Click:Connect(function()
        for _, conn in pairs(connections) do pcall(conn.Disconnect) end
        pcall(function() if MenuGui then MenuGui:Destroy() end end)
        pcall(function() if espFolder then espFolder:Destroy() end end)
        pcall(function() if HUD then HUD:Destroy() end end)
        pcall(function() LegitFOV:Remove() end)
        pcall(function() RageFOV:Remove() end)
        ClearESP()
    end)
end

-- ========== ЗАПУСК ЧИТА ==========
local function StartCheat()
    CreateMenu()
    SetupFly()
    SetupNoclip()
    
    table.insert(connections, RunService.RenderStepped:Connect(function()
        UpdateESP()
        UpdateHUD()
        
        LegitFOV.Visible = Settings.Legit.drawFov
        LegitFOV.Radius = Settings.Legit.fov
        LegitFOV.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
        
        RageFOV.Visible = Settings.Rage.drawFov
        RageFOV.Radius = Settings.Rage.fov
        RageFOV.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
        
        if Settings.Legit.aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = GetTarget(Settings.Legit.fov, Settings.Legit.hitbox)
            if target then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), 1 / (Settings.Legit.smooth + 1))
            end
        end
        
        if Settings.Legit.trigger and Mouse.Target then
            local plr = Players:GetPlayerFromCharacter(Mouse.Target.Parent)
            if plr and plr ~= LocalPlayer then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.02)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
        end
    end))
    
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Insert then
            if MenuFrame then MenuFrame.Visible = not MenuFrame.Visible end
        elseif input.KeyCode == Enum.KeyCode.End then
            for _, conn in pairs(connections) do pcall(conn.Disconnect) end
            pcall(function() if MenuGui then MenuGui:Destroy() end end)
            pcall(function() if espFolder then espFolder:Destroy() end end)
            pcall(function() if HUD then HUD:Destroy() end end)
            pcall(function() LegitFOV:Remove() end)
            pcall(function() RageFOV:Remove() end)
            ClearESP()
        end
    end)
    
    print("=== SQUADRIM DLC | ImGUI STYLE | ЗАПУЩЕН ===")
    print("Insert = Меню | End = Выгрузка")
end

ShowAuth()
