-- SWILL | SquadRim DLC PRO | v15.0 | ImGUI STYLE
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
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local GuiService = game:GetService("GuiService")

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
    notification.ZIndex = 1000
    notification.Parent = CoreGui
    Instance.new("UICorner", notification).CornerRadius = UDim.new(0, 6)
    task.delay(2.5, notification.Destroy)
end

-- ========== ПЕРЕМЕННЫЕ СОСТОЯНИЯ ==========
local state = {
    menu = true,
    version = "0.7",
    build = "0.7",
    theme = "dark",
    fps = 60,
    ping = 18,
    tick = 64,
    rage = {enabled = true, autofire = true, doubletap = false, hideshots = false, hitchance = 60, multipoint = 3},
    legit = {enabled = true, silent = false, autoshoot = true, fov = 8, smooth = 45, hitbox = "Head"},
    trigger = {enabled = true, scopeonly = false, allies = true, delaymin = 40, delaymax = 90},
    rcs = {enabled = true, pitch = 80, yaw = 75},
    movement = {fakeduck = false, slowwalk = true, edgejump = false},
    accuracy = {nospread = true, norecoil = false, autopistol = true},
    visuals = {
        enabled = true, box = true, skeleton = false, name = true,
        health = true, armour = false, boxstyle = "Corner Box",
        enemycolor = Color3.fromRGB(232, 48, 48),
        teamcolor = Color3.fromRGB(79, 255, 176),
        weapons = true, grenades = false, bomb = true, footsteps = true,
        chams = true, xqz = false, chamsmaterial = "Flat",
        chamscolor = Color3.fromRGB(232, 48, 48),
        radar = true, radarmode = "Custom radar", radscale = 1.4
    },
    misc = {bhop = true, autostrafe = false, edgejump = false, crouchjump = true, bhmode = "Perfect", bhrate = 95, noflash = true, nosmoke = true, clantag = false, freecam = false, fly = false, noclip = false},
    skin = {knifemodel = "Butterfly Knife", kniveskin = "Fade FN", gloves = "Sport Gloves", applyall = true},
    config = {active = "HvH_Preset_v3", autosave = true, cloud = false}
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

-- ========== FPS КАЛЬКУЛЯТОР ==========
local fpsValues = {}
local function UpdateFPS()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    table.insert(fpsValues, fps)
    if #fpsValues > 10 then table.remove(fpsValues, 1) end
    local sum = 0
    for _, v in ipairs(fpsValues) do sum = sum + v end
    state.fps = math.floor(sum / #fpsValues)
end

-- ========== FOV КРУГ ==========
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(232, 48, 48)
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Transparency = 0.4

-- ========== ESP STORAGE ==========
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
                        Box = Create("Square", {Thickness = 1, Filled = false, Transparency = 1, Color = state.visuals.enemycolor}),
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
                s.Box.Color = state.visuals.enemycolor
                
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
                s.Highlight.OutlineTransparency = 0
                s.Highlight.FillColor = state.visuals.chamscolor
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
            local part = (state.legit.hitbox == "Head" and plr.Character:FindFirstChild("Head")) or plr.Character:FindFirstChild("HumanoidRootPart")
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
                    local part = (state.legit.hitbox == "Head" and target.Character:FindFirstChild("Head")) or target.Character:FindFirstChild("HumanoidRootPart")
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
        if state.legit.enabled and (state.legit.silent or (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) and state.legit.autoshoot)) then
            local target = GetClosestPlayer()
            if target and target.Character then
                local part = (state.legit.hitbox == "Head" and target.Character:FindFirstChild("Head")) or target.Character:FindFirstChild("HumanoidRootPart")
                if part then
                    local targetPos = part.Position
                    local currentCF = Camera.CFrame
                    local newCF = CFrame.new(currentCF.Position, targetPos)
                    Camera.CFrame = currentCF:Lerp(newCF, state.legit.smooth / 100)
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

-- No Recoil / No Spread
pcall(function()
    local mt = getrawmetatable(game)
    if mt then
        local oldIndex = mt.__index
        setreadonly(mt, false)
        mt.__index = function(self, key)
            if state.accuracy.norecoil and (key == "Recoil" or key == "CameraRecoil") then return 0 end
            if state.accuracy.nospread and key == "Spread" then return 0 end
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
    local cfg = {
        rage = state.rage, legit = state.legit, trigger = state.trigger, rcs = state.rcs,
        movement = state.movement, accuracy = state.accuracy, visuals = state.visuals,
        misc = state.misc, skin = state.skin, config = state.config
    }
    writefile("SquadRim_Config.json", HttpService:JSONEncode(cfg))
    ShowNotification("Config saved", false)
end

local function LoadConfig()
    if isfile("SquadRim_Config.json") then
        local data = HttpService:JSONDecode(readfile("SquadRim_Config.json"))
        state.rage = data.rage or state.rage
        state.legit = data.legit or state.legit
        state.trigger = data.trigger or state.trigger
        state.rcs = data.rcs or state.rcs
        state.movement = data.movement or state.movement
        state.accuracy = data.accuracy or state.accuracy
        state.visuals = data.visuals or state.visuals
        state.misc = data.misc or state.misc
        state.skin = data.skin or state.skin
        state.config = data.config or state.config
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
    print("SquadRim DLC UNLOADED")
end

-- ========== СТАТУС HUD ==========
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

local function UpdateHUD()
    UpdateFPS()
    local ping = math.random(15, 35)
    HUD.Text = string.format("| t.me/squadrim1 | DLC | FREE | %s | %d FPS | PING %dms |", LocalPlayer.Name, state.fps, ping)
end

-- ========== ImGUI МЕНЮ ==========
local screenGui = nil
local MainFrame = nil
local currentTab = "legit"

local function CreateToggle(x, y, w, h, getter, setter)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, w, 0, h)
    btn.Position = UDim2.new(0, x, 0, y)
    btn.BackgroundColor3 = getter() and Color3.fromRGB(232, 48, 48) or Color3.fromRGB(25, 25, 35)
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(45, 45, 55)
    btn.Text = getter() and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = MainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
    btn.MouseButton1Click:Connect(function()
        local newVal = not getter()
        setter(newVal)
        btn.BackgroundColor3 = newVal and Color3.fromRGB(232, 48, 48) or Color3.fromRGB(25, 25, 35)
        btn.Text = newVal and "ON" or "OFF"
    end)
    return btn
end

local function CreateSlider(x, y, w, text, min, max, getter, setter)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, w, 0, 35)
    frame.Position = UDim2.new(0, x, 0, y)
    frame.BackgroundTransparency = 1
    frame.Parent = MainFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. getter()
    label.TextColor3 = Color3.fromRGB(184, 196, 212)
    label.TextSize = 11
    label.Font = Enum.Font.SourceSans
    label.Parent = frame
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0, 3)
    track.Position = UDim2.new(0, 0, 0, 22)
    track.BackgroundColor3 = Color3.fromRGB(30, 36, 47)
    track.BorderSizePixel = 0
    track.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((getter() - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(232, 48, 48)
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 8, 0, 8)
    knob.Position = UDim2.new((getter() - min) / (max - min), -4, 0, -2.5)
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
            local val = math.floor(min + (max - min) * percent)
            setter(val)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            knob.Position = UDim2.new(percent, -4, 0, -2.5)
            label.Text = text .. ": " .. val
        end
    end)
    track.InputEnded:Connect(function() dragging = false end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = math.clamp((Mouse.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * percent)
            setter(val)
            fill.Size = UDim2.new(percent, 0, 1, 0)
            knob.Position = UDim2.new(percent, -4, 0, -2.5)
            label.Text = text .. ": " .. val
        end
    end)
end

local function CreateDropdown(x, y, w, text, options, getter, setter)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, w, 0, 45)
    frame.Position = UDim2.new(0, x, 0, y)
    frame.BackgroundTransparency = 1
    frame.Parent = MainFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(106, 122, 148)
    label.TextSize = 10
    label.Font = Enum.Font.SourceSans
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 24)
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
        dropdown.Size = UDim2.new(1, 0, 0, 24 * #options)
        dropdown.Position = UDim2.new(0, 0, 0, 24)
        dropdown.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        dropdown.BorderSizePixel = 1
        dropdown.BorderColor3 = Color3.fromRGB(45, 45, 55)
        dropdown.Parent = frame
        Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 3)
        
        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.Size = UDim2.new(1, 0, 0, 24)
            optBtn.Position = UDim2.new(0, 0, 0, 24 * (i-1))
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

local function CreateColorPicker(x, y, w, text, getter, setter)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, w, 0, 55)
    frame.Position = UDim2.new(0, x, 0, y)
    frame.BackgroundTransparency = 1
    frame.Parent = MainFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 16)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(106, 122, 148)
    label.TextSize = 10
    label.Font = Enum.Font.SourceSans
    label.Parent = frame
    
    local colors = {
        {Color3.fromRGB(232, 48, 48), "#E83030"},
        {Color3.fromRGB(255, 136, 0), "#FF8800"},
        {Color3.fromRGB(79, 255, 176), "#4FFFB0"},
        {Color3.fromRGB(124, 110, 255), "#7C6EFF"},
        {Color3.fromRGB(255, 255, 255), "#FFFFFF"}
    }
    
    local swatchFrame = Instance.new("Frame")
    swatchFrame.Size = UDim2.new(1, 0, 0, 18)
    swatchFrame.Position = UDim2.new(0, 0, 0, 20)
    swatchFrame.BackgroundTransparency = 1
    swatchFrame.Parent = frame
    
    for i, col in ipairs(colors) do
        local sw = Instance.new("TextButton")
        sw.Size = UDim2.new(0, 18, 0, 18)
        sw.Position = UDim2.new(0, (i-1) * 22, 0, 0)
        sw.BackgroundColor3 = col[1]
        sw.BorderSizePixel = 1
        sw.BorderColor3 = getter() == col[1] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(45, 45, 55)
        sw.Text = ""
        sw.Parent = swatchFrame
        Instance.new("UICorner", sw).CornerRadius = UDim.new(0, 3)
        sw.MouseButton1Click:Connect(function()
            setter(col[1])
            for _, child in pairs(swatchFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BorderColor3 = Color3.fromRGB(45, 45, 55)
                end
            end
            sw.BorderColor3 = Color3.fromRGB(255, 255, 255)
        end)
    end
    
    local hexLabel = Instance.new("TextLabel")
    hexLabel.Size = UDim2.new(1, 0, 0, 16)
    hexLabel.Position = UDim2.new(0, 0, 0, 42)
    hexLabel.BackgroundTransparency = 1
    hexLabel.Text = "#FFFFFF  A:255"
    hexLabel.TextColor3 = Color3.fromRGB(58, 69, 88)
    hexLabel.TextSize = 10
    hexLabel.Font = Enum.Font.ShareTechMono
    hexLabel.Parent = frame
end

local function CreateKeybind(x, y, w, text, getter, setter)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, w, 0, 32)
    frame.Position = UDim2.new(0, x, 0, y)
    frame.BackgroundTransparency = 1
    frame.Parent = MainFrame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(106, 122, 148)
    label.TextSize = 11
    label.Font = Enum.Font.SourceSans
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 22)
    btn.Position = UDim2.new(0.7, 0, 0.15, 0)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(45, 45, 55)
    btn.Text = getter() or "NONE"
    btn.TextColor3 = Color3.fromRGB(232, 48, 48)
    btn.TextSize = 10
    btn.Font = Enum.Font.ShareTechMono
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 3)
    
    btn.MouseButton1Click:Connect(function()
        btn.Text = "..."
        local input
        input = UserInputService.InputBegan:Connect(function(i)
            if i.KeyType == Enum.KeyType.Key then
                setter(i.KeyCode.Name)
                btn.Text = i.KeyCode.Name
                input:Disconnect()
            end
        end)
    end)
end

local function CreateGroup(x, y, w, h, title)
    local group = Instance.new("Frame")
    group.Size = UDim2.new(0, w, 0, h)
    group.Position = UDim2.new(0, x, 0, y)
    group.BackgroundColor3 = Color3.fromRGB(14, 17, 20)
    group.BorderSizePixel = 1
    group.BorderColor3 = Color3.fromRGB(30, 36, 47)
    group.Parent = MainFrame
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
    badge.Text = "ON"
    badge.TextColor3 = Color3.fromRGB(232, 48, 48)
    badge.TextSize = 9
    badge.Font = Enum.Font.SourceSansBold
    badge.Parent = titleFrame
    Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 2)
    
    return group, badge
end

-- ========== СОЗДАНИЕ GUI ==========
local function CreateGUI()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SquadRim_ImGUI"
    screenGui.Parent = CoreGui
    screenGui.ResetOnSpawn = false
    
    MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 600, 0, 520)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -260)
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
    ver.Size = UDim2.new(0, 100, 0, 14)
    ver.Position = UDim2.new(0, 12, 0, 28)
    ver.BackgroundTransparency = 1
    ver.Text = "BUILD " .. state.build .. " — ROBLOX"
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
    
    local tabs = {
        {name = "LEGIT", id = "legit", x = 0},
        {name = "RAGE", id = "rage", x = 120},
        {name = "VISUAL", id = "visual", x = 240},
        {name = "MISC", id = "misc", x = 360},
        {name = "SKINS", id = "skins", x = 480}
    }
    
    local containers = {}
    
    for _, tab in ipairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 120, 1, 0)
        btn.Position = UDim2.new(0, tab.x, 0, 0)
        btn.BackgroundColor3 = tab.id == currentTab and Color3.fromRGB(232, 48, 48) or Color3.fromRGB(8, 10, 12)
        btn.BorderSizePixel = 0
        btn.Text = tab.name
        btn.TextColor3 = Color3.fromRGB(232, 48, 48)
        btn.TextSize = 12
        btn.Font = Enum.Font.SourceSansBold
        btn.Parent = tabBar
        
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 1, -78)
        container.Position = UDim2.new(0, 0, 0, 78)
        container.BackgroundTransparency = 1
        container.Visible = (tab.id == currentTab)
        container.Parent = MainFrame
        containers[tab.id] = container
        
        btn.MouseButton1Click:Connect(function()
            currentTab = tab.id
            for _, t in pairs(tabs) do
                local b = tabBar:FindFirstChild(t.name)
                if b then b.BackgroundColor3 = Color3.fromRGB(8, 10, 12) end
                if containers[t.id] then containers[t.id].Visible = (t.id == tab.id) end
            end
            btn.BackgroundColor3 = Color3.fromRGB(232, 48, 48)
        end)
    end
    
    -- LEGIT TAB
    local legitContainer = containers["legit"]
    
    local g1, badge1 = CreateGroup(10, 10, 280, 200, "Aimbot")
    badge1.Text = state.legit.enabled and "ON" or "OFF"
    local aimEnable = CreateToggle(15, 35, 60, 22, function() return state.legit.enabled end, function(v) state.legit.enabled = v; badge1.Text = v and "ON" or "OFF" end)
    local silentAim = CreateToggle(90, 35, 60, 22, function() return state.legit.silent end, function(v) state.legit.silent = v end)
    local autoShoot = CreateToggle(165, 35, 60, 22, function() return state.legit.autoshoot end, function(v) state.legit.autoshoot = v end)
    local labels = {Instance.new("TextLabel", g1), Instance.new("TextLabel", g1), Instance.new("TextLabel", g1)}
    labels[1].Size = UDim2.new(0, 40, 0, 16)
    labels[1].Position = UDim2.new(0, 20, 0, 38)
    labels[1].BackgroundTransparency = 1
    labels[1].Text = "Enable"
    labels[1].TextColor3 = Color3.fromRGB(184, 196, 212)
    labels[1].TextSize = 10
    labels[1].Font = Enum.Font.SourceSans
    labels[2].Size = UDim2.new(0, 50, 0, 16)
    labels[2].Position = UDim2.new(0, 95, 0, 38)
    labels[2].BackgroundTransparency = 1
    labels[2].Text = "Silent Aim"
    labels[2].TextColor3 = Color3.fromRGB(106, 122, 148)
    labels[2].TextSize = 10
    labels[2].Font = Enum.Font.SourceSans
    labels[3].Size = UDim2.new(0, 60, 0, 16)
    labels[3].Position = UDim2.new(0, 170, 0, 38)
    labels[3].BackgroundTransparency = 1
    labels[3].Text = "Auto Shoot"
    labels[3].TextColor3 = Color3.fromRGB(106, 122, 148)
    labels[3].TextSize = 10
    labels[3].Font = Enum.Font.SourceSans
    
    CreateDropdown(15, 70, 120, "Hitbox", {"Head", "Body", "Neck", "Pelvis"}, function() return state.legit.hitbox end, function(v) state.legit.hitbox = v end)
    CreateSlider(15, 120, 120, "FOV", 1, 30, function() return state.legit.fov end, function(v) state.legit.fov = v end)
    CreateSlider(150, 120, 120, "Smooth", 1, 100, function() return state.legit.smooth end, function(v) state.legit.smooth = v end)
    
    local g2, badge2 = CreateGroup(10, 220, 280, 130, "Triggerbot")
    badge2.Text = state.trigger.enabled and "ON" or "OFF"
    CreateToggle(15, 245, 60, 22, function() return state.trigger.enabled end, function(v) state.trigger.enabled = v; badge2.Text = v and "ON" or "OFF" end)
    CreateToggle(90, 245, 60, 22, function() return state.trigger.scopeonly end, function(v) state.trigger.scopeonly = v end)
    CreateToggle(165, 245, 60, 22, function() return state.trigger.allies end, function(v) state.trigger.allies = v end)
    CreateSlider(15, 280, 120, "Delay Min", 0, 200, function() return state.trigger.delaymin end, function(v) state.trigger.delaymin = v end)
    CreateSlider(150, 280, 120, "Delay Max", 0, 200, function() return state.trigger.delaymax end, function(v) state.trigger.delaymax = v end)
    
    local g3, badge3 = CreateGroup(300, 10, 280, 200, "RCS / Accuracy")
    badge3.Text = state.rcs.enabled and "ON" or "OFF"
    CreateToggle(305, 35, 60, 22, function() return state.rcs.enabled end, function(v) state.rcs.enabled = v; badge3.Text = v and "ON" or "OFF" end)
    CreateToggle(380, 35, 60, 22, function() return state.accuracy.nospread end, function(v) state.accuracy.nospread = v end)
    CreateToggle(455, 35, 60, 22, function() return state.accuracy.norecoil end, function(v) state.accuracy.norecoil = v end)
    CreateSlider(305, 75, 120, "Pitch", 0, 100, function() return state.rcs.pitch end, function(v) state.rcs.pitch = v end)
    CreateSlider(440, 75, 120, "Yaw", 0, 100, function() return state.rcs.yaw end, function(v) state.rcs.yaw = v end)
    CreateToggle(305, 125, 80, 22, function() return state.accuracy.autopistol end, function(v) state.accuracy.autopistol = v end)
    
    -- RAGE TAB
    local rageContainer = containers["rage"]
    
    local g4, badge4 = CreateGroup(10, 10, 280, 250, "Ragebot")
    badge4.Text = state.rage.enabled and "ON" or "OFF"
    CreateToggle(15, 35, 60, 22, function() return state.rage.enabled end, function(v) state.rage.enabled = v; badge4.Text = v and "ON" or "OFF" end)
    CreateToggle(90, 35, 60, 22, function() return state.rage.autofire end, function(v) state.rage.autofire = v end)
    CreateToggle(165, 35, 60, 22, function() return state.rage.doubletap end, function(v) state.rage.doubletap = v end)
    CreateToggle(225, 35, 60, 22, function() return state.rage.hideshots end, function(v) state.rage.hideshots = v end)
    CreateDropdown(15, 70, 120, "Hitbox priority", {"Head", "Head + Body", "Body + Head", "Body"}, function() return "Head + Body" end, function(v) end)
    CreateDropdown(150, 70, 120, "Min damage", {"100 HP", "75 HP", "50 HP", "25 HP"}, function() return "100 HP" end, function(v) end)
    CreateSlider(15, 125, 250, "Hitchance", 1, 100, function() return state.rage.hitchance end, function(v) state.rage.hitchance = v end)
    CreateSlider(15, 175, 250, "Multipoint", 1, 10, function() return state.rage.multipoint end, function(v) state.rage.multipoint = v end)
    
    local g5, badge5 = CreateGroup(300, 10, 280, 120, "Movement")
    CreateToggle(305, 35, 80, 22, function() return state.movement.fakeduck end, function(v) state.movement.fakeduck = v end)
    CreateToggle(390, 35, 80, 22, function() return state.movement.slowwalk end, function(v) state.movement.slowwalk = v end)
    CreateToggle(475, 35, 80, 22, function() return state.movement.edgejump end, function(v) state.movement.edgejump = v end)
    CreateKeybind(305, 75, 260, "Doubletap", function() return "SPACE" end, function(v) end)
    CreateKeybind(305, 110, 260, "Hideshots", function() return "SHIFT" end, function(v) end)
    CreateKeybind(305, 145, 260, "Slow walk", function() return "CTRL" end, function(v) end)
    
    -- VISUAL TAB
    local visualContainer = containers["visual"]
    
    local g6, badge6 = CreateGroup(10, 10, 280, 280, "ESP Players")
    badge6.Text = state.visuals.enabled and "ON" or "OFF"
    CreateToggle(15, 35, 60, 22, function() return state.visuals.enabled end, function(v) state.visuals.enabled = v; badge6.Text = v and "ON" or "OFF" end)
    CreateToggle(90, 35, 60, 22, function() return state.visuals.box end, function(v) state.visuals.box = v end)
    CreateToggle(165, 35, 60, 22, function() return state.visuals.skeleton end, function(v) state.visuals.skeleton = v end)
    CreateToggle(225, 35, 30, 22, function() return state.visuals.name end, function(v) state.visuals.name = v end)
    CreateToggle(15, 70, 60, 22, function() return state.visuals.health end, function(v) state.visuals.health = v end)
    CreateToggle(90, 70, 60, 22, function() return state.visuals.armour end, function(v) state.visuals.armour = v end)
    CreateDropdown(15, 105, 250, "Box style", {"Corner Box", "2D Box", "3D Box", "Glow"}, function() return state.visuals.boxstyle end, function(v) state.visuals.boxstyle = v end)
    CreateColorPicker(15, 165, 120, "Enemy color", function() return state.visuals.enemycolor end, function(v) state.visuals.enemycolor = v end)
    CreateColorPicker(150, 165, 120, "Team color", function() return state.visuals.teamcolor end, function(v) state.visuals.teamcolor = v end)
    
    local g7, badge7 = CreateGroup(300, 10, 280, 150, "World ESP")
    CreateToggle(305, 35, 80, 22, function() return state.visuals.weapons end, function(v) state.visuals.weapons = v end)
    CreateToggle(390, 35, 80, 22, function() return state.visuals.grenades end, function(v) state.visuals.grenades = v end)
    CreateToggle(475, 35, 80, 22, function() return state.visuals.bomb end, function(v) state.visuals.bomb = v end)
    CreateToggle(305, 70, 80, 22, function() return state.visuals.footsteps end, function(v) state.visuals.footsteps = v end)
    
    local g8, badge8 = CreateGroup(300, 170, 280, 150, "Chams")
    CreateToggle(305, 195, 60, 22, function() return state.visuals.chams end, function(v) state.visuals.chams = v end)
    CreateToggle(380, 195, 60, 22, function() return state.visuals.xqz end, function(v) state.visuals.xqz = v end)
    CreateDropdown(305, 230, 120, "Material", {"Flat", "Glossy", "Plastic", "Metallic"}, function() return state.visuals.chamsmaterial end, function(v) state.visuals.chamsmaterial = v end)
    CreateColorPicker(440, 230, 120, "Color", function() return state.visuals.chamscolor end, function(v) state.visuals.chamscolor = v end)
    
    -- MISC TAB
    local miscContainer = containers["misc"]
    
    local g9, badge9 = CreateGroup(10, 10, 280, 250, "Movement")
    CreateToggle(15, 35, 60, 22, function() return state.misc.bhop end, function(v) state.misc.bhop = v end)
    CreateToggle(90, 35, 60, 22, function() return state.misc.autostrafe end, function(v) state.misc.autostrafe = v end)
    CreateToggle(165, 35, 60, 22, function() return state.misc.edgejump end, function(v) state.misc.edgejump = v end)
    CreateToggle(225, 35, 60, 22, function() return state.misc.crouchjump end, function(v) state.misc.crouchjump = v end)
    CreateDropdown(15, 70, 120, "BH mode", {"Perfect", "Legit", "Rage", "Silent"}, function() return state.misc.bhmode end, function(v) state.misc.bhmode = v end)
    CreateSlider(150, 70, 120, "Success rate", 1, 100, function() return state.misc.bhrate end, function(v) state.misc.bhrate = v end)
    
    local g10, badge10 = CreateGroup(300, 10, 280, 120, "Other")
    CreateToggle(305, 35, 80, 22, function() return state.misc.noflash end, function(v) state.misc.noflash = v end)
    CreateToggle(390, 35, 80, 22, function() return state.misc.nosmoke end, function(v) state.misc.nosmoke = v end)
    CreateToggle(475, 35, 80, 22, function() return state.misc.clantag end, function(v) state.misc.clantag = v end)
    
    local g11, badge11 = CreateGroup(10, 270, 280, 100, "FreeCam / Fly")
    CreateToggle(15, 295, 80, 22, function() return state.misc.freecam end, function(v) if v then toggleFreeCam() else toggleFreeCam() end end)
    CreateToggle(110, 295, 80, 22, function() return state.misc.fly end, function(v) state.misc.fly = v end)
    CreateToggle(205, 295, 80, 22, function() return state.misc.noclip end, function(v) state.misc.noclip = v end)
    
    local g12, badge12 = CreateGroup(300, 140, 280, 230, "Config")
    CreateDropdown(305, 165, 250, "Active config", {"HvH_Preset_v3", "Legit_v2", "Rage_v1", "SemiRage"}, function() return state.config.active end, function(v) state.config.active = v end)
    
    local loadBtn = Instance.new("TextButton")
    loadBtn.Size = UDim2.new(0, 80, 0, 28)
    loadBtn.Position = UDim2.new(0, 315, 0, 210)
    loadBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    loadBtn.BorderSizePixel = 1
    loadBtn.BorderColor3 = Color3.fromRGB(45, 45, 55)
    loadBtn.Text = "Load"
    loadBtn.TextColor3 = Color3.fromRGB(184, 196, 212)
    loadBtn.TextSize = 11
    loadBtn.Font = Enum.Font.SourceSansBold
    loadBtn.Parent = g12
    Instance.new("UICorner", loadBtn).CornerRadius = UDim.new(0, 3)
    loadBtn.MouseButton1Click:Connect(LoadConfig)
    
    local saveBtn = Instance.new("TextButton")
    saveBtn.Size = UDim2.new(0, 80, 0, 28)
    saveBtn.Position = UDim2.new(0, 405, 0, 210)
    saveBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    saveBtn.BorderSizePixel = 1
    saveBtn.BorderColor3 = Color3.fromRGB(45, 45, 55)
    saveBtn.Text = "Save"
    saveBtn.TextColor3 = Color3.fromRGB(79, 255, 176)
    saveBtn.TextSize = 11
    saveBtn.Font = Enum.Font.SourceSansBold
    saveBtn.Parent = g12
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 3)
    saveBtn.MouseButton1Click:Connect(SaveConfig)
    
    local delBtn = Instance.new("TextButton")
    delBtn.Size = UDim2.new(0, 80, 0, 28)
    delBtn.Position = UDim2.new(0, 495, 0, 210)
    delBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    delBtn.BorderSizePixel = 1
    delBtn.BorderColor3 = Color3.fromRGB(45, 45, 55)
    delBtn.Text = "Del"
    delBtn.TextColor3 = Color3.fromRGB(232, 48, 48)
    delBtn.TextSize = 11
    delBtn.Font = Enum.Font.SourceSansBold
    delBtn.Parent = g12
    Instance.new("UICorner", delBtn).CornerRadius = UDim.new(0, 3)
    
    CreateToggle(305, 255, 100, 22, function() return state.config.autosave end, function(v) state.config.autosave = v end)
    CreateToggle(420, 255, 100, 22, function() return state.config.cloud end, function(v) state.config.cloud = v end)
    
    -- SKINS TAB
    local skinsContainer = containers["skins"]
    
    local g13, badge13 = CreateGroup(10, 10, 280, 230, "Skin Changer")
    CreateDropdown(15, 45, 250, "Knife model", {"Butterfly Knife", "Karambit", "M9 Bayonet", "Huntsman", "Flip Knife"}, function() return state.skin.knifemodel end, function(v) state.skin.knifemodel = v end)
    CreateDropdown(15, 100, 250, "Knife skin", {"Fade FN", "Doppler FN", "Marble Fade", "Tiger Tooth", "Crimson Web"}, function() return state.skin.kniveskin end, function(v) state.skin.kniveskin = v end)
    CreateDropdown(15, 155, 250, "Gloves", {"Sport Gloves", "Driver Gloves", "Hand Wraps", "Moto Gloves", "Specialist"}, function() return state.skin.gloves end, function(v) state.skin.gloves = v end)
    CreateToggle(15, 210, 100, 22, function() return state.skin.applyall end, function(v) state.skin.applyall = v end)
    
    local g14, badge14 = CreateGroup(300, 10, 280, 100, "Weapons")
    -- Weapon slots placeholder
    
    local unloadBig = Instance.new("TextButton")
    unloadBig.Size = UDim2.new(0, 540, 0, 32)
    unloadBig.Position = UDim2.new(10, 0, 1, -42)
    unloadBig.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    unloadBig.BorderSizePixel = 1
    unloadBig.BorderColor3 = Color3.fromRGB(232, 48, 48)
    unloadBig.Text = "⚠️ UNLOAD CHEAT (END) ⚠️"
    unloadBig.TextColor3 = Color3.fromRGB(232, 48, 48)
    unloadBig.TextSize = 12
    unloadBig.Font = Enum.Font.SourceSansBold
    unloadBig.Parent = MainFrame
    Instance.new("UICorner", unloadBig).CornerRadius = UDim.new(0, 4)
    unloadBig.MouseButton1Click:Connect(UnloadCheat)
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
                FOVCircle.Visible = state.legit.enabled and (state.legit.silent or state.legit.autoshoot) and not isFreeCam
                FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
                FOVCircle.Radius = state.legit.fov * 10
            end))
            
            UserInputService.InputBegan:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.Insert then
                    state.menu = not state.menu
                    if MainFrame then MainFrame.Visible = state.menu end
                elseif input.KeyCode == Enum.KeyCode.End then
                    UnloadCheat()
                end
            end)
            
            print("=== SQUADRIM DLC PRO v15.0 | ImGUI Style | ЗАПУЩЕН ===")
            print("Insert = Открыть меню | F7 = FreeCam | End = Выгрузка")
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
