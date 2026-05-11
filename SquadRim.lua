--[[ 
    SQUADRIM PRESTIGE v18.0 | THE OMNI-UPDATE
    Features: Legit, Rage, Visuals, Misc, Configs, Auth, FreeCam
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
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

-- ========== ГЛОБАЛЬНЫЕ НАСТРОЙКИ ==========
_G.Settings = {
    Auth = false,
    Legit = {Aimbot = false, Smooth = 15, FOV = 100, DrawFOV = true, Trigger = false, Hitbox = "Head"},
    Rage = {Silent = false, FOV = 300, DrawFOV = false},
    Visuals = {ESP = false, Box = false, Chams = false, Skeleton = false, Health = false, Name = false, Distance = false},
    Misc = {Fly = false, Noclip = false, Freecam = false, Speed = 16},
    Binds = {Menu = Enum.KeyCode.Insert, Freecam = Enum.KeyCode.F7}
}

-- ========== ПЕРЕМЕННЫЕ ==========
local connections = {}
local bodyVel = nil
local flyActive = false
local isFreeCam = false
local camSpeed = 2.0
local lookSensitivity = 0.5
local moveState = {forward = 0, backward = 0, left = 0, right = 0, up = 0, down = 0}
local freecamBodyVelocity = nil
local Storage = {}

-- ========== UI ЭЛЕМЕНТЫ (DRAWING) ==========
local L_FOV = Drawing.new("Circle")
L_FOV.Thickness = 2
L_FOV.Color = Color3.fromRGB(0, 200, 255)
L_FOV.Filled = false
L_FOV.Transparency = 0.5

local R_FOV = Drawing.new("Circle")
R_FOV.Thickness = 2
R_FOV.Color = Color3.fromRGB(255, 50, 50)
R_FOV.Filled = false
R_FOV.Transparency = 0.5

-- ========== АВТОРИЗАЦИЯ ==========
local function InitAuth()
    local AuthGui = Instance.new("ScreenGui", CoreGui)
    AuthGui.Name = "SquadRim_Auth"
    
    local Frame = Instance.new("Frame", AuthGui)
    Frame.Size = UDim2.new(0, 350, 0, 220)
    Frame.Position = UDim2.new(0.5, -175, 0.5, -110)
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Frame.BorderSizePixel = 2
    Frame.BorderColor3 = Color3.fromRGB(200, 50, 50)
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)

    local Title = Instance.new("TextLabel", Frame)
    Title.Size = UDim2.new(1, 0, 0, 45)
    Title.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    Title.Text = "SQUADRIM PRESTIGE"
    Title.TextColor3 = Color3.fromRGB(200, 50, 50)
    Title.TextSize = 20
    Title.Font = Enum.Font.SourceSansBold
    Title.TextScaled = true

    local Sub = Instance.new("TextLabel", Frame)
    Sub.Size = UDim2.new(1, 0, 0, 25)
    Sub.Position = UDim2.new(0, 0, 0, 50)
    Sub.BackgroundTransparency = 1
    Sub.Text = "Введите пароль для доступа"
    Sub.TextColor3 = Color3.fromRGB(180, 180, 200)
    Sub.TextSize = 13
    Sub.Font = Enum.Font.SourceSans

    local Input = Instance.new("TextBox", Frame)
    Input.Size = UDim2.new(0.8, 0, 0, 38)
    Input.Position = UDim2.new(0.1, 0, 0, 85)
    Input.PlaceholderText = "Password..."
    Input.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Input.TextColor3 = Color3.fromRGB(255, 255, 255)
    Input.TextSize = 14
    Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 5)

    local Btn = Instance.new("TextButton", Frame)
    Btn.Size = UDim2.new(0.35, 0, 0, 38)
    Btn.Position = UDim2.new(0.1, 0, 0, 140)
    Btn.Text = "ВОЙТИ"
    Btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 14
    Btn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)

    local GetKey = Instance.new("TextButton", Frame)
    GetKey.Size = UDim2.new(0.35, 0, 0, 38)
    GetKey.Position = UDim2.new(0.55, 0, 0, 140)
    GetKey.Text = "TG ССЫЛКА"
    GetKey.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    GetKey.BorderSizePixel = 1
    GetKey.BorderColor3 = Color3.fromRGB(200, 50, 50)
    GetKey.TextColor3 = Color3.fromRGB(200, 50, 50)
    GetKey.TextSize = 13
    GetKey.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", GetKey).CornerRadius = UDim.new(0, 5)

    local Info = Instance.new("TextLabel", Frame)
    Info.Size = UDim2.new(1, 0, 0, 20)
    Info.Position = UDim2.new(0, 0, 0, 195)
    Info.BackgroundTransparency = 1
    Info.Text = "Telegram: t.me/squadrim1"
    Info.TextColor3 = Color3.fromRGB(200, 50, 50)
    Info.TextSize = 11
    Info.Font = Enum.Font.SourceSans

    GetKey.MouseButton1Click:Connect(function()
        if setclipboard then setclipboard("t.me/squadrim1") end
        local notif = Instance.new("TextLabel", AuthGui)
        notif.Size = UDim2.new(0, 250, 0, 30)
        notif.Position = UDim2.new(0.5, -125, 0.7, 0)
        notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        notif.BackgroundTransparency = 0.5
        notif.Text = "✅ Ссылка скопирована!"
        notif.TextColor3 = Color3.fromRGB(0, 255, 0)
        notif.TextSize = 12
        task.delay(2, function() notif:Destroy() end)
    end)

    Btn.MouseButton1Click:Connect(function()
        if Input.Text == "SquadRim2024" then
            _G.Settings.Auth = true
            AuthGui:Destroy()
            print("Welcome to SquadRim Prestige")
            CreateHUD()
            CreateMenu()
            StartFunctions()
        else
            Btn.Text = "НЕВЕРНО"
            Btn.BackgroundColor3 = Color3.fromRGB(150, 30, 30)
            task.wait(1)
            Btn.Text = "ВОЙТИ"
            Btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
    end)
end

-- ========== HUD ==========
local HUD = nil
local function CreateHUD()
    HUD = Instance.new("ScreenGui", CoreGui)
    HUD.Name = "SquadRim_HUD"
    HUD.ResetOnSpawn = false
    
    local Bar = Instance.new("Frame", HUD)
    Bar.Size = UDim2.new(0, 450, 0, 26)
    Bar.Position = UDim2.new(0.5, -225, 0, 10)
    Bar.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    Bar.BackgroundTransparency = 0.2
    Bar.BorderSizePixel = 1
    Bar.BorderColor3 = Color3.fromRGB(200, 50, 50)
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 4)

    local Label = Instance.new("TextLabel", Bar)
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.TextColor3 = Color3.fromRGB(200, 50, 50)
    Label.TextSize = 13
    Label.Font = Enum.Font.SourceSansBold
    
    local fpsValues = {}
    RunService.RenderStepped:Connect(function()
        local fps = math.floor(1 / RunService.RenderStepped:Wait())
        table.insert(fpsValues, fps)
        if #fpsValues > 10 then table.remove(fpsValues, 1) end
        local sum = 0 for _, v in pairs(fpsValues) do sum = sum + v end
        local avgFps = math.floor(sum / #fpsValues)
        local freecamStatus = isFreeCam and " [FREECAM]" or ""
        Label.Text = string.format("| t.me/squadrim1 | PRESTIGE | FREE | [%d FPS] |%s", avgFps, freecamStatus)
    end)
end

-- ========== ESP FUNCTIONS ==========
local espFolder = Instance.new("Folder", CoreGui)
espFolder.Name = "SquadRim_ESP"

local function ClearESP()
    for _, obj in pairs(Storage) do
        pcall(function()
            if obj.Box then obj.Box:Remove() end
            if obj.Name then obj.Name:Remove() end
            if obj.Dist then obj.Dist:Remove() end
            if obj.Health then obj.Health:Remove() end
            if obj.Highlight then obj.Highlight:Destroy() end
        end)
    end
    Storage = {}
end

local function GetSkeletonPoints(character)
    local points = {}
    local root = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    local leftArm = character:FindFirstChild("LeftArm")
    local rightArm = character:FindFirstChild("RightArm")
    local leftLeg = character:FindFirstChild("LeftLeg")
    local rightLeg = character:FindFirstChild("RightLeg")
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    
    if root and head then table.insert(points, {root, head}) end
    if torso and leftArm then table.insert(points, {torso, leftArm}) table.insert(points, {leftArm, head}) end
    if torso and rightArm then table.insert(points, {torso, rightArm}) table.insert(points, {rightArm, head}) end
    if torso and leftLeg then table.insert(points, {torso, leftLeg}) end
    if torso and rightLeg then table.insert(points, {torso, rightLeg}) end
    return points
end

local function UpdateESP()
    if not _G.Settings.Auth then return end
    if not _G.Settings.Visuals.ESP then 
        ClearESP()
        return 
    end
    
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
                        Dist = Drawing.new("Text"),
                        Health = Drawing.new("Square")
                    }
                    Storage[plr].Box.Thickness = 1
                    Storage[plr].Box.Filled = false
                    Storage[plr].Name.Size = 13
                    Storage[plr].Name.Center = true
                    Storage[plr].Name.Outline = true
                    Storage[plr].Dist.Size = 11
                    Storage[plr].Dist.Center = true
                    Storage[plr].Dist.Outline = true
                end
                
                local s = Storage[plr]
                local sizeX = 2000 / pos.Z
                local sizeY = 2800 / pos.Z
                local x, y = pos.X - sizeX/2, pos.Y - sizeY/1.2
                local hp = hum.Health / hum.MaxHealth
                local hpColor = hp > 0.5 and Color3.new(0,1,0) or (hp > 0.25 and Color3.new(1,0.5,0) or Color3.new(1,0,0))
                
                -- Box ESP
                if _G.Settings.Visuals.Box then
                    s.Box.Visible = true
                    s.Box.Position = Vector2.new(x, y)
                    s.Box.Size = Vector2.new(sizeX, sizeY)
                    s.Box.Color = Color3.new(1, 0, 0)
                else
                    s.Box.Visible = false
                end
                
                -- Name
                if _G.Settings.Visuals.Name then
                    s.Name.Visible = true
                    s.Name.Position = Vector2.new(pos.X, y - 15)
                    s.Name.Text = plr.Name
                    s.Name.Color = Color3.new(1, 1, 1)
                else
                    s.Name.Visible = false
                end
                
                -- Distance
                if _G.Settings.Visuals.Distance then
                    s.Dist.Visible = true
                    s.Dist.Position = Vector2.new(pos.X, y + sizeY + 2)
                    s.Dist.Text = math.floor(pos.Z) .. "m"
                    s.Dist.Color = Color3.new(0.8, 0.8, 0.8)
                else
                    s.Dist.Visible = false
                end
                
                -- Health Bar
                if _G.Settings.Visuals.Health then
                    s.Health.Visible = true
                    s.Health.Position = Vector2.new(x - 6, y + (sizeY * (1 - hp)))
                    s.Health.Size = Vector2.new(3, sizeY * hp)
                    s.Health.Color = hpColor
                    s.Health.Filled = true
                else
                    s.Health.Visible = false
                end
                
                -- Chams
                local highlight = char:FindFirstChild("SR_Highlight")
                if _G.Settings.Visuals.Chams then
                    if not highlight then
                        highlight = Instance.new("Highlight", char)
                        highlight.Name = "SR_Highlight"
                    end
                    highlight.Enabled = true
                    highlight.FillColor = Color3.new(1, 0, 0)
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0
                elseif highlight then
                    highlight.Enabled = false
                end
                
                -- Skeleton
                if _G.Settings.Visuals.Skeleton then
                    if not Storage[plr].Skel then Storage[plr].Skel = {} end
                    local skelPoints = GetSkeletonPoints(char)
                    for i, points in ipairs(skelPoints) do
                        local p1, on1 = Camera:WorldToViewportPoint(points[1].Position)
                        local p2, on2 = Camera:WorldToViewportPoint(points[2].Position)
                        if on1 and on2 then
                            if not Storage[plr].Skel[i] then
                                Storage[plr].Skel[i] = Drawing.new("Line")
                                Storage[plr].Skel[i].Thickness = 1
                                Storage[plr].Skel[i].Color = Color3.new(1,1,1)
                            end
                            Storage[plr].Skel[i].Visible = true
                            Storage[plr].Skel[i].From = Vector2.new(p1.X, p1.Y)
                            Storage[plr].Skel[i].To = Vector2.new(p2.X, p2.Y)
                        elseif Storage[plr].Skel[i] then
                            Storage[plr].Skel[i].Visible = false
                        end
                    end
                elseif Storage[plr].Skel then
                    for _, line in pairs(Storage[plr].Skel) do
                        pcall(function() line.Visible = false end)
                    end
                end
            else
                if Storage[plr] then
                    pcall(function() 
                        if Storage[plr].Box then Storage[plr].Box.Visible = false end
                        if Storage[plr].Name then Storage[plr].Name.Visible = false end
                        if Storage[plr].Dist then Storage[plr].Dist.Visible = false end
                        if Storage[plr].Health then Storage[plr].Health.Visible = false end
                    end)
                end
            end
        end
    end
end

-- ========== AIMBOT FUNCTIONS ==========
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
            if _G.Settings.Rage.Silent and self == Mouse and key == "Hit" then
                local target = GetTarget(_G.Settings.Rage.FOV, "Head")
                if target then return target.CFrame end
            end
            return oldIndex(self, key)
        end
        setreadonly(mt, true)
    end
end)

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
        if HUD then
            for _, child in pairs(HUD:GetChildren()) do
                if child:IsA("TextLabel") then
                    child.Text = child.Text:gsub("%]$", " | FREECAM]")
                end
            end
        end
    else
        Camera.CameraType = Enum.CameraType.Custom
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        if freecamBodyVelocity then freecamBodyVelocity:Destroy() end
        freecamBodyVelocity = nil
        if HUD then
            for _, child in pairs(HUD:GetChildren()) do
                if child:IsA("TextLabel") then
                    child.Text = child.Text:gsub(" | FREECAM", "")
                end
            end
        end
    end
end

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == _G.Settings.Binds.Freecam then toggleFreeCam() end
    
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

-- ========== FLY / NOCLIP ==========
local function SetupFly()
    table.insert(connections, RunService.RenderStepped:Connect(function()
        if isFreeCam then return end
        if not _G.Settings.Misc.Fly then
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
        
        bodyVel.Velocity = dir.Magnitude > 0 and dir.Unit * _G.Settings.Misc.Speed or Vector3.new(0, 0, 0)
    end))
end

local function SetupNoclip()
    table.insert(connections, RunService.Stepped:Connect(function()
        if isFreeCam then return end
        if not _G.Settings.Misc.Noclip then return end
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

-- ========== CONFIG SYSTEM ==========
local function SaveConfig()
    local cfg = {
        Legit = _G.Settings.Legit,
        Rage = _G.Settings.Rage,
        Visuals = _G.Settings.Visuals,
        Misc = _G.Settings.Misc
    }
    writefile("SquadRim_Config.json", HttpService:JSONEncode(cfg))
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
        _G.Settings.Legit = data.Legit or _G.Settings.Legit
        _G.Settings.Rage = data.Rage or _G.Settings.Rage
        _G.Settings.Visuals = data.Visuals or _G.Settings.Visuals
        _G.Settings.Misc = data.Misc or _G.Settings.Misc
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

-- ========== МЕНЮ ==========
local MainGui = nil
local MenuFrame = nil
local currentPage = "Legit"

local function CreateMenu()
    MainGui = Instance.new("ScreenGui", CoreGui)
    MainGui.Name = "SquadRim_Menu"
    MainGui.ResetOnSpawn = false
    
    MenuFrame = Instance.new("Frame", MainGui)
    MenuFrame.Size = UDim2.new(0, 550, 0, 420)
    MenuFrame.Position = UDim2.new(0.5, -275, 0.5, -210)
    MenuFrame.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
    MenuFrame.BorderSizePixel = 2
    MenuFrame.BorderColor3 = Color3.fromRGB(200, 50, 50)
    MenuFrame.Active = true
    MenuFrame.Draggable = true
    MenuFrame.Visible = false
    Instance.new("UICorner", MenuFrame).CornerRadius = UDim.new(0, 8)
    
    -- Header
    local Header = Instance.new("Frame", MenuFrame)
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
    Header.BorderSizePixel = 0
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 8)
    
    local Title = Instance.new("TextLabel", Header)
    Title.Size = UDim2.new(1, -50, 0, 45)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "SQUADRIM PRESTIGE v18.0"
    Title.TextColor3 = Color3.fromRGB(200, 50, 50)
    Title.TextSize = 18
    Title.Font = Enum.Font.SourceSansBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local CloseBtn = Instance.new("TextButton", Header)
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -40, 0, 8)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 32, 42)
    CloseBtn.BorderSizePixel = 1
    CloseBtn.BorderColor3 = Color3.fromRGB(60, 65, 80)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)
    CloseBtn.MouseButton1Click:Connect(function() MenuFrame.Visible = false end)
    
    -- Tab Bar
    local TabBar = Instance.new("Frame", MenuFrame)
    TabBar.Size = UDim2.new(1, 0, 0, 40)
    TabBar.Position = UDim2.new(0, 0, 0, 45)
    TabBar.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
    TabBar.BorderSizePixel = 1
    TabBar.BorderColor3 = Color3.fromRGB(30, 35, 45)
    
    local TabsData = {"Legit", "Rage", "Visuals", "Misc", "Configs"}
    local Pages = {}
    
    for i, tabName in ipairs(TabsData) do
        local Btn = Instance.new("TextButton", TabBar)
        Btn.Size = UDim2.new(0.2, 0, 1, 0)
        Btn.Position = UDim2.new((i-1)/5, 0, 0, 0)
        Btn.BackgroundColor3 = i == 1 and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(10, 12, 18)
        Btn.BorderSizePixel = 0
        Btn.Text = tabName
        Btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        Btn.TextSize = 12
        Btn.Font = Enum.Font.SourceSansBold
        
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
        
        Pages[tabName] = Page
        
        Btn.MouseButton1Click:Connect(function()
            for _, b in pairs(TabBar:GetChildren()) do
                if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(10, 12, 18) end
            end
            Btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            for _, p in pairs(Pages) do p.Visible = false end
            Page.Visible = true
        end)
    end
    
    local function MakeToggle(parent, text, getter, setter)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
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
        frame.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
        frame.BorderSizePixel = 1
        frame.BorderColor3 = Color3.fromRGB(45, 50, 65)
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
        
        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(0.6, 0, 0, 20)
        label.Position = UDim2.new(0, 8, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(200, 200, 220)
        label.TextSize = 12
        label.Font = Enum.Font.SourceSans
        
        local valueLabel = Instance.new("TextLabel", frame)
        valueLabel.Size = UDim2.new(0.3, 0, 0, 20)
        valueLabel.Position = UDim2.new(0.7, 0, 0, 5)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = tostring(getter())
        valueLabel.TextColor3 = Color3.fromRGB(200, 50, 50)
        valueLabel.TextSize = 11
        valueLabel.Font = Enum.Font.ShareTechMono
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        
        local track = Instance.new("Frame", frame)
        track.Size = UDim2.new(0.96, 0, 0, 3)
        track.Position = UDim2.new(0.02, 0, 0, 35)
        track.BackgroundColor3 = Color3.fromRGB(45, 50, 65)
        track.BorderSizePixel = 0
        
        local fill = Instance.new("Frame", track)
        fill.Size = UDim2.new((getter() - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        fill.BorderSizePixel = 0
        
        local knob = Instance.new("Frame", track)
        knob.Size = UDim2.new(0, 10, 0, 10)
        knob.Position = UDim2.new((getter() - min) / (max - min), -5, 0, -3.5)
        knob.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        knob.BorderSizePixel = 1
        knob.BorderColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        
        local dragging = false
        track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                local percent = math.clamp((Mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local val = min + (max - min) * percent
                if type(getter()) == "number" and math.floor(getter()) == getter() then val = math.floor(val) end
                setter(val)
                fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
                knob.Position = UDim2.new((val - min) / (max - min), -5, 0, -3.5)
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
                fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
                knob.Position = UDim2.new((val - min) / (max - min), -5, 0, -3.5)
                valueLabel.Text = type(val) == "number" and (math.floor(val) == val and tostring(val) or string.format("%.1f", val)) or tostring(val)
            end
        end)
    end
    
    local function MakeDropdown(parent, text, options, getter, setter)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, 0, 0, 55)
        frame.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
        frame.BorderSizePixel = 1
        frame.BorderColor3 = Color3.fromRGB(45, 50, 65)
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 4)
        
        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, 0, 0, 16)
        label.Position = UDim2.new(0, 8, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(150, 160, 180)
        label.TextSize = 11
        label.Font = Enum.Font.SourceSans
        
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(0.96, 0, 0, 28)
        btn.Position = UDim2.new(0.02, 0, 0, 22)
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
            dropdown.Size = UDim2.new(0.96, 0, 0, 28 * #options)
            dropdown.Position = UDim2.new(0.02, 0, 0, 50)
            dropdown.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
            dropdown.BorderSizePixel = 1
            dropdown.BorderColor3 = Color3.fromRGB(55, 60, 75)
            Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 3)
            
            for i, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton", dropdown)
                optBtn.Size = UDim2.new(1, 0, 0, 28)
                optBtn.Position = UDim2.new(0, 0, 0, 28 * (i-1))
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
    
    -- ========== LEGIT PAGE ==========
    MakeToggle(Pages["Legit"], "Aimbot", function() return _G.Settings.Legit.Aimbot end, function(v) _G.Settings.Legit.Aimbot = v end)
    MakeSlider(Pages["Legit"], "Smoothness", 1, 50, function() return _G.Settings.Legit.Smooth end, function(v) _G.Settings.Legit.Smooth = v end)
    MakeSlider(Pages["Legit"], "FOV", 30, 300, function() return _G.Settings.Legit.FOV end, function(v) _G.Settings.Legit.FOV = v end)
    MakeToggle(Pages["Legit"], "Draw FOV", function() return _G.Settings.Legit.DrawFOV end, function(v) _G.Settings.Legit.DrawFOV = v end)
    MakeToggle(Pages["Legit"], "Triggerbot", function() return _G.Settings.Legit.Trigger end, function(v) _G.Settings.Legit.Trigger = v end)
    MakeDropdown(Pages["Legit"], "Hitbox", {"Head", "Body"}, function() return _G.Settings.Legit.Hitbox end, function(v) _G.Settings.Legit.Hitbox = v end)
    
    -- ========== RAGE PAGE ==========
    MakeToggle(Pages["Rage"], "Silent Aim", function() return _G.Settings.Rage.Silent end, function(v) _G.Settings.Rage.Silent = v end)
    MakeSlider(Pages["Rage"], "Silent FOV", 30, 500, function() return _G.Settings.Rage.FOV end, function(v) _G.Settings.Rage.FOV = v end)
    MakeToggle(Pages["Rage"], "Draw Silent FOV", function() return _G.Settings.Rage.DrawFOV end, function(v) _G.Settings.Rage.DrawFOV = v end)
    
    -- ========== VISUALS PAGE ==========
    MakeToggle(Pages["Visuals"], "ESP Master", function() return _G.Settings.Visuals.ESP end, function(v) _G.Settings.Visuals.ESP = v end)
    MakeToggle(Pages["Visuals"], "Box ESP", function() return _G.Settings.Visuals.Box end, function(v) _G.Settings.Visuals.Box = v end)
    MakeToggle(Pages["Visuals"], "Name Tags", function() return _G.Settings.Visuals.Name end, function(v) _G.Settings.Visuals.Name = v end)
    MakeToggle(Pages["Visuals"], "Distance", function() return _G.Settings.Visuals.Distance end, function(v) _G.Settings.Visuals.Distance = v end)
    MakeToggle(Pages["Visuals"], "Health Bar", function() return _G.Settings.Visuals.Health end, function(v) _G.Settings.Visuals.Health = v end)
    MakeToggle(Pages["Visuals"], "Chams", function() return _G.Settings.Visuals.Chams end, function(v) _G.Settings.Visuals.Chams = v end)
    MakeToggle(Pages["Visuals"], "Skeleton", function() return _G.Settings.Visuals.Skeleton end, function(v) _G.Settings.Visuals.Skeleton = v end)
    
    -- ========== MISC PAGE ==========
    MakeToggle(Pages["Misc"], "Fly Mode", function() return _G.Settings.Misc.Fly end, function(v) _G.Settings.Misc.Fly = v end)
    MakeToggle(Pages["Misc"], "Noclip", function() return _G.Settings.Misc.Noclip end, function(v) _G.Settings.Misc.Noclip = v end)
    MakeSlider(Pages["Misc"], "Fly Speed", 10, 120, function() return _G.Settings.Misc.Speed end, function(v) _G.Settings.Misc.Speed = v end)
    
    -- ========== CONFIGS PAGE ==========
    local BtnSave = Instance.new("TextButton", Pages["Configs"])
    BtnSave.Size = UDim2.new(1, 0, 0, 38)
    BtnSave.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
    BtnSave.BorderSizePixel = 1
    BtnSave.BorderColor3 = Color3.fromRGB(45, 50, 65)
    BtnSave.Text = "💾 SAVE CONFIG"
    BtnSave.TextColor3 = Color3.fromRGB(80, 255, 120)
    BtnSave.TextSize = 13
    BtnSave.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", BtnSave).CornerRadius = UDim.new(0, 4)
    BtnSave.MouseButton1Click:Connect(SaveConfig)
    
    local BtnLoad = Instance.new("TextButton", Pages["Configs"])
    BtnLoad.Size = UDim2.new(1, 0, 0, 38)
    BtnLoad.Position = UDim2.new(0, 0, 0, 46)
    BtnLoad.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
    BtnLoad.BorderSizePixel = 1
    BtnLoad.BorderColor3 = Color3.fromRGB(45, 50, 65)
    BtnLoad.Text = "📂 LOAD CONFIG"
    BtnLoad.TextColor3 = Color3.fromRGB(200, 50, 50)
    BtnLoad.TextSize = 13
    BtnLoad.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", BtnLoad).CornerRadius = UDim.new(0, 4)
    BtnLoad.MouseButton1Click:Connect(LoadConfig)
    
    local BtnUnload = Instance.new("TextButton", Pages["Configs"])
    BtnUnload.Size = UDim2.new(1, 0, 0, 38)
    BtnUnload.Position = UDim2.new(0, 0, 0, 92)
    BtnUnload.BackgroundColor3 = Color3.fromRGB(25, 28, 38)
    BtnUnload.BorderSizePixel = 1
    BtnUnload.BorderColor3 = Color3.fromRGB(200, 50, 50)
    BtnUnload.Text = "⚠️ UNLOAD CHEAT (END) ⚠️"
    BtnUnload.TextColor3 = Color3.fromRGB(200, 50, 50)
    BtnUnload.TextSize = 13
    BtnUnload.Font = Enum.Font.SourceSansBold
    Instance.new("UICorner", BtnUnload).CornerRadius = UDim.new(0, 4)
    BtnUnload.MouseButton1Click:Connect(function()
        for _, conn in pairs(connections) do pcall(conn.Disconnect) end
        pcall(function() if MainGui then MainGui:Destroy() end end)
        pcall(function() if espFolder then espFolder:Destroy() end end)
        pcall(function() if HUD then HUD:Destroy() end end)
        pcall(function() L_FOV:Remove() end)
        pcall(function() R_FOV:Remove() end)
        for _, plr in pairs(Players:GetPlayers()) do
            if Storage[plr] then
                if Storage[plr].Box then Storage[plr].Box:Remove() end
                if Storage[plr].Name then Storage[plr].Name:Remove() end
                if Storage[plr].Dist then Storage[plr].Dist:Remove() end
                if Storage[plr].Health then Storage[plr].Health:Remove() end
                if Storage[plr].Skel then
                    for _, line in pairs(Storage[plr].Skel) do line:Remove() end
                end
                if Storage[plr].Highlight then Storage[plr].Highlight:Destroy() end
            end
        end
        print("SquadRim Unloaded")
    end)
end

-- ========== START ALL FUNCTIONS ==========
local function StartFunctions()
    SetupFreeCam()
    SetupFly()
    SetupNoclip()
    
    -- Legit Aimbot (RenderStepped)
    table.insert(connections, RunService.RenderStepped:Connect(function()
        if not _G.Settings.Auth then return end
        
        -- FOV Circles
        L_FOV.Visible = _G.Settings.Legit.DrawFOV
        L_FOV.Radius = _G.Settings.Legit.FOV
        L_FOV.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
        L_FOV.Color = Color3.fromRGB(0, 200, 255)
        
        R_FOV.Visible = _G.Settings.Rage.DrawFOV
        R_FOV.Radius = _G.Settings.Rage.FOV
        R_FOV.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
        R_FOV.Color = Color3.fromRGB(255, 50, 50)
        
        -- Legit Aimbot
        if _G.Settings.Legit.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local target = GetTarget(_G.Settings.Legit.FOV, _G.Settings.Legit.Hitbox)
            if target then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.Position), 1 / (_G.Settings.Legit.Smooth + 1))
            end
        end
        
        -- Triggerbot
        if _G.Settings.Legit.Trigger and Mouse.Target then
            local plr = Players:GetPlayerFromCharacter(Mouse.Target.Parent)
            if plr and plr ~= LocalPlayer then
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.02)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
        end
        
        UpdateESP()
    end))
    
    -- Menu Toggle
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == _G.Settings.Binds.Menu then
            if MenuFrame then MenuFrame.Visible = not MenuFrame.Visible end
        elseif input.KeyCode == Enum.KeyCode.End then
            for _, conn in pairs(connections) do pcall(conn.Disconnect) end
            pcall(function() if MainGui then MainGui:Destroy() end end)
            pcall(function() if espFolder then espFolder:Destroy() end end)
            pcall(function() if HUD then HUD:Destroy() end end)
            pcall(function() L_FOV:Remove() end)
            pcall(function() R_FOV:Remove() end)
        end
    end)
end

-- ========== ЗАПУСК ==========
InitAuth()
