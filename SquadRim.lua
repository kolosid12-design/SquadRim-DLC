-- SWILL | SquadRim DLC PRO | v7.0 | FULL ESP + ALL FUNCTIONS + UNLOAD
-- Telegram: t.me/squadrim1
-- Insert = Меню | End = UNLOAD (полное удаление)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

-- ========== СОСТОЯНИЯ ==========
local state = {
    menu = true,
    rage = {silent = false, fov = 150},
    legit = {trigger = false, aimbot = false},
    visuals = {
        esp = false, tracers = false, arrows = false, fly = false, noclip = false,
        skeleton = false, healthBar = true, showName = true, showDistance = true,
        showItems = false, showArmor = false, showIcons = true
    },
    extra = {bhop = false}
}

local connections = {}
local bodyVel = nil
local flyActive = false
local isUnloaded = false

-- ========== UNLOAD ФУНКЦИЯ ==========
local function UnloadCheat()
    if isUnloaded then return end
    isUnloaded = true
    
    for _, conn in pairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    
    pcall(function() if screenGui then screenGui:Destroy() end end)
    pcall(function() if espFolder then espFolder:Destroy() end end)
    pcall(function() if HUD then HUD:Destroy() end end)
    pcall(function() if FOVCircle then FOVCircle:Remove() end end)
    pcall(function() if bodyVel then bodyVel:Destroy() end end)
    
    if LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function() part.CanCollide = true end)
            end
        end
    end
    
    print("SQUADRIM DLC | UNLOADED")
end

-- ========== FOV КРУГ ==========
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.Transparency = 0.5

-- ========== ESP СИСТЕМА (полная) ==========
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

-- Функция для получения скелета
local function GetSkeletonPoints(character)
    local points = {}
    local root = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    local leftArm = character:FindFirstChild("LeftArm")
    local rightArm = character:FindFirstChild("RightArm")
    local leftLeg = character:FindFirstChild("LeftLeg")
    local rightLeg = character:FindFirstChild("RightLeg")
    local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    
    if root and head then
        table.insert(points, {root, head})
    end
    if torso and leftArm then
        table.insert(points, {torso, leftArm})
        table.insert(points, {leftArm, head})
    end
    if torso and rightArm then
        table.insert(points, {torso, rightArm})
        table.insert(points, {rightArm, head})
    end
    if torso and leftLeg then
        table.insert(points, {torso, leftLeg})
    end
    if torso and rightLeg then
        table.insert(points, {torso, rightLeg})
    end
    return points
end

local function UpdateESP()
    ClearESP()
    if not state.visuals.esp then return end
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            local head = plr.Character:FindFirstChild("Head")
            local hum = plr.Character:FindFirstChild("Humanoid")
            
            if root and head and hum and hum.Health > 0 then
                local vec, onScreen = Camera:WorldToViewportPoint(root.Position)
                local headVec, _ = Camera:WorldToViewportPoint(head.Position)
                local dist = math.floor((root.Position - (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.new())).Magnitude)
                local healthPercent = hum.Health / hum.MaxHealth
                local healthColor = healthPercent > 0.5 and Color3.fromRGB(0, 255, 0) or (healthPercent > 0.25 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 0, 0))
                
                if onScreen then
                    local height = headVec.Y - vec.Y
                    local width = height * 0.6
                    local boxX = vec.X - width/2
                    local boxY = vec.Y
                    
                    -- ===== SKELETON =====
                    if state.visuals.skeleton then
                        local skeletonPoints = GetSkeletonPoints(plr.Character)
                        for _, points in ipairs(skeletonPoints) do
                            local p1, onScreen1 = Camera:WorldToViewportPoint(points[1].Position)
                            local p2, onScreen2 = Camera:WorldToViewportPoint(points[2].Position)
                            if onScreen1 and onScreen2 then
                                local line = Drawing.new("Line")
                                line.From = Vector2.new(p1.X, p1.Y)
                                line.To = Vector2.new(p2.X, p2.Y)
                                line.Color = Color3.fromRGB(255, 255, 255)
                                line.Thickness = 1.5
                                line.Visible = true
                                line.ZIndex = 5
                                table.insert(espObjects, line)
                            end
                        end
                    end
                    
                    -- ===== BOX ESP =====
                    local box = Instance.new("Frame")
                    box.Size = UDim2.new(0, math.abs(width), 0, math.abs(height))
                    box.Position = UDim2.new(0, boxX, 0, boxY)
                    box.BackgroundTransparency = 0.85
                    box.BackgroundColor3 = healthColor
                    box.BorderSizePixel = 2
                    box.BorderColor3 = Color3.fromRGB(255, 255, 255)
                    box.Visible = onScreen
                    box.Parent = espFolder
                    table.insert(espObjects, box)
                    
                    -- ===== HEALTH BAR =====
                    if state.visuals.healthBar then
                        local healthBar = Instance.new("Frame")
                        healthBar.Size = UDim2.new(0, 4, healthPercent, 0)
                        healthBar.Position = UDim2.new(0, -6, 1 - healthPercent, 0)
                        healthBar.BackgroundColor3 = healthColor
                        healthBar.BorderSizePixel = 0
                        healthBar.Parent = box
                        table.insert(espObjects, healthBar)
                        
                        local healthText = Instance.new("TextLabel")
                        healthText.Size = UDim2.new(0, 30, 0, 12)
                        healthText.Position = UDim2.new(0, -35, 0, height/2 - 6)
                        healthText.Text = math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
                        healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
                        healthText.TextSize = 9
                        healthText.BackgroundTransparency = 0.5
                        healthText.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                        healthText.Parent = box
                        table.insert(espObjects, healthText)
                    end
                    
                    -- ===== NAME =====
                    if state.visuals.showName then
                        local nameTag = Instance.new("TextLabel")
                        nameTag.Size = UDim2.new(0, width + 20, 0, 16)
                        nameTag.Position = UDim2.new(0, -10, 0, -18)
                        nameTag.Text = plr.Name
                        nameTag.TextColor3 = Color3.fromRGB(255, 255, 255)
                        nameTag.TextSize = 11
                        nameTag.Font = Enum.Font.GothamBold
                        nameTag.BackgroundTransparency = 0.5
                        nameTag.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                        nameTag.Parent = box
                        table.insert(espObjects, nameTag)
                    end
                    
                    -- ===== DISTANCE =====
                    if state.visuals.showDistance then
                        local distTag = Instance.new("TextLabel")
                        distTag.Size = UDim2.new(0, 50, 0, 14)
                        distTag.Position = UDim2.new(0, (width/2) - 25, 0, height + 2)
                        distTag.Text = dist .. "m"
                        distTag.TextColor3 = Color3.fromRGB(200, 200, 200)
                        distTag.TextSize = 10
                        distTag.BackgroundTransparency = 0.5
                        distTag.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                        distTag.Parent = box
                        table.insert(espObjects, distTag)
                    end
                    
                    -- ===== ARMOR =====
                    if state.visuals.showArmor then
                        local armor = plr.Character:FindFirstChild("BodyColors")
                        local armorValue = "None"
                        if armor then armorValue = "Basic" end
                        local armorTag = Instance.new("TextLabel")
                        armorTag.Size = UDim2.new(0, 50, 0, 12)
                        armorTag.Position = UDim2.new(0, width + 5, 0, 5)
                        armorTag.Text = "🛡️ " .. armorValue
                        armorTag.TextColor3 = Color3.fromRGB(100, 200, 255)
                        armorTag.TextSize = 9
                        armorTag.BackgroundTransparency = 1
                        armorTag.Parent = box
                        table.insert(espObjects, armorTag)
                    end
                    
                    -- ===== ICONS (Rank/Team) =====
                    if state.visuals.showIcons then
                        local icon = Instance.new("TextLabel")
                        icon.Size = UDim2.new(0, 20, 0, 20)
                        icon.Position = UDim2.new(0, -22, 0, height/2 - 10)
                        icon.Text = "⭐"
                        icon.TextColor3 = Color3.fromRGB(255, 215, 0)
                        icon.TextSize = 16
                        icon.BackgroundTransparency = 1
                        icon.Parent = box
                        table.insert(espObjects, icon)
                    end
                    
                    -- ===== ITEMS (оружие в руке) =====
                    if state.visuals.showItems then
                        local tool = plr.Character:FindFirstChildWhichIsA("Tool")
                        local itemName = tool and tool.Name or "No weapon"
                        local itemTag = Instance.new("TextLabel")
                        itemTag.Size = UDim2.new(0, 80, 0, 14)
                        itemTag.Position = UDim2.new(0, -10, 0, height + 18)
                        itemTag.Text = "🔫 " .. itemName
                        itemTag.TextColor3 = Color3.fromRGB(255, 200, 100)
                        itemTag.TextSize = 9
                        itemTag.BackgroundTransparency = 0.5
                        itemTag.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                        itemTag.Parent = box
                        table.insert(espObjects, itemTag)
                    end
                end
                
                -- ===== TRACERS =====
                if state.visuals.tracers and onScreen then
                    local tracer = Instance.new("Frame")
                    tracer.Size = UDim2.new(0, 2, 0, vec.Y)
                    tracer.Position = UDim2.new(0, vec.X, 0, 0)
                    tracer.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                    tracer.BackgroundTransparency = 0.3
                    tracer.Parent = espFolder
                    table.insert(espObjects, tracer)
                end
                
                -- ===== ARROWS (off-screen) =====
                if state.visuals.arrows and not onScreen then
                    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
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

-- ========== AIMBOT ==========
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

-- Silent Aim
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
table.insert(connections, RunService.RenderStepped:Connect(function()
    if state.legit.aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetPos = target.Character.HumanoidRootPart.Position
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        end
    end
end))

-- Triggerbot
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

-- ========== FLY ==========
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

-- ========== NOCLIP ==========
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

-- ========== BUNNY HOP ==========
table.insert(connections, RunService.RenderStepped:Connect(function()
    if state.extra.bhop and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum and (UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.D)) and hum.FloorMaterial ~= Enum.Material.Air then
            hum.Jump = true
        end
    end
end))

-- ========== HUD ==========
local HUD = Instance.new("TextLabel")
HUD.Size = UDim2.new(0, 600, 0, 30)
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
    HUD.Text = string.format("⚡ SQUADRIM DLC | %s | %d FPS | ACTIVE: %d | END = UNLOAD", LocalPlayer.Name, fps, active)
end

-- ========== GUI МЕНЮ ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SquadRim_Menu"
screenGui.Parent = CoreGui
screenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 580)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -290)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 100)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = screenGui
MainFrame.Visible = state.menu

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
Title.Text = "SQUADRIM DLC PRO v7.0"
Title.TextColor3 = Color3.fromRGB(0, 210, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local Scrolling = Instance.new("ScrollingFrame")
Scrolling.Size = UDim2.new(1, -10, 1, -55)
Scrolling.Position = UDim2.new(0, 5, 0, 50)
Scrolling.BackgroundTransparency = 1
Scrolling.CanvasSize = UDim2.new(0, 0, 0, 850)
Scrolling.ScrollBarThickness = 4
Scrolling.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 6)
Layout.Parent = Scrolling

local function MakeCategory(name)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    frame.Parent = Scrolling
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "  「 " .. name .. " 」"
    label.TextColor3 = Color3.fromRGB(0, 200, 255)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
end

local function MakeToggle(text, getter, setter)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 35)
    frame.BackgroundTransparency = 1
    frame.Parent = Scrolling
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.65, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = frame
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 70, 0, 28)
    btn.Position = UDim2.new(0.82, 0, 0.1, 0)
    btn.BackgroundColor3 = getter() and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(70, 70, 85)
    btn.Text = getter() and "ON" or "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = frame
    
    btn.MouseButton1Click:Connect(function()
        local newVal = not getter()
        setter(newVal)
        btn.BackgroundColor3 = newVal and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(70, 70, 85)
        btn.Text = newVal and "ON" or "OFF"
        FOVCircle.Visible = state.rage.silent
    end)
end

local function MakeSlider(text, min, max, getter, setter)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 55)
    frame.BackgroundTransparency = 1
    frame.Parent = Scrolling
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Text = text .. ": " .. getter()
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0.7, 0, 0, 5)
    slider.Position = UDim2.new(0, 0, 0, 28)
    slider.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
    slider.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((getter() - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 180, 200)
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

-- ========== СОЗДАНИЕ МЕНЮ ==========
MakeCategory("RAGE")
MakeToggle("Silent Aim", function() return state.rage.silent end, function(v) state.rage.silent = v end)
MakeSlider("FOV Range", 30, 300, function() return state.rage.fov end, function(v) state.rage.fov = v end)

MakeCategory("LEGIT")
MakeToggle("Triggerbot", function() return state.legit.trigger end, function(v) state.legit.trigger = v end)
MakeToggle("Legit Aimbot", function() return state.legit.aimbot end, function(v) state.legit.aimbot = v end)

MakeCategory("VISUALS")
MakeToggle("ESP Master", function() return state.visuals.esp end, function(v) state.visuals.esp = v end)
MakeToggle(">> Skeleton", function() return state.visuals.skeleton end, function(v) state.visuals.skeleton = v end)
MakeToggle(">> Health Bar", function() return state.visuals.healthBar end, function(v) state.visuals.healthBar = v end)
MakeToggle(">> Show Name", function() return state.visuals.showName end, function(v) state.visuals.showName = v end)
MakeToggle(">> Show Distance", function() return state.visuals.showDistance end, function(v) state.visuals.showDistance = v end)
MakeToggle(">> Show Items", function() return state.visuals.showItems end, function(v) state.visuals.showItems = v end)
MakeToggle(">> Show Armor", function() return state.visuals.showArmor end, function(v) state.visuals.showArmor = v end)
MakeToggle(">> Show Icons", function() return state.visuals.showIcons end, function(v) state.visuals.showIcons = v end)
MakeToggle("Tracers", function() return state.visuals.tracers end, function(v) state.visuals.tracers = v end)
MakeToggle("Offscreen Arrows", function() return state.visuals.arrows end, function(v) state.visuals.arrows = v end)
MakeToggle("Fly Mode", function() return state.visuals.fly end, function(v) state.visuals.fly = v end)
MakeToggle("Noclip Mode", function() return state.visuals.noclip end, function(v) state.visuals.noclip = v end)

MakeCategory("EXTRA")
MakeToggle("Bunny Hop", function() return state.extra.bhop end, function(v) state.extra.bhop = v end)

-- ========== ЗАПУСК ==========
pcall(SetupSilentAim)

-- Основные циклы
table.insert(connections, RunService.RenderStepped:Connect(function()
    UpdateESP()
    UpdateHUD()
    FOVCircle.Visible = state.rage.silent
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = state.rage.fov
end))

-- ========== KEYBINDS ==========
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        state.menu = not state.menu
        MainFrame.Visible = state.menu
    elseif input.KeyCode == Enum.KeyCode.End then
        UnloadCheat()
    end
end)

print("SQUADRIM DLC PRO v7.0 | FULLY LOADED")
print("Insert = Menu | End = UNLOAD | Все функции в меню")
