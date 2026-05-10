-- SWILL | SquadRim DLC PRO | v5.0 | FIXED VERSION
-- Insert = Меню | End = UNLOAD

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- ========== НАСТРОЙКИ ==========
local state = {
    menu = true,
    rage = {silent = false, fov = 150},
    visuals = {esp = false, tracers = false, fly = false, noclip = false},
    extra = {bhop = false, speed = 16},
    unloaded = false
}

local connections = {}
local screenGui = Instance.new("ScreenGui", CoreGui)
local espFolder = Instance.new("Folder", workspace); espFolder.Name = "SquadRim_ESP"

-- ========== ФУНКЦИИ МОДУЛЕЙ ==========

-- 1. Silent Aim / FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Filled = false

local function GetClosestPlayer()
    local target = nil
    local dist = state.rage.fov
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local mouseDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mouseDist < dist then
                    dist = mouseDist
                    target = v
                end
            end
        end
    end
    return target
end

-- 2. ESP & Tracers
local function UpdateESP()
    espFolder:ClearAllChildren()
    if not state.visuals.esp then return end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart
            local box = Instance.new("BoxHandleAdornment", espFolder)
            box.Adornee = p.Character
            box.Size = Vector3.new(4, 5, 1)
            box.AlwaysOnTop = true
            box.ZIndex = 5
            box.Transparency = 0.5
            box.Color3 = Color3.fromRGB(255, 0, 0)
        end
    end
end

-- 3. Fly & NoClip
local function HandleMovement()
    if state.visuals.noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
    
    if state.extra.bhop and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.Jump = true
        end
    end
end

-- ========== ГЛАВНОЕ МЕНЮ (INSERT) ==========
local MainFrame = Instance.new("Frame", screenGui)
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "SQUADRIM DLC PRO | v5.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)

local function CreateButton(name, pos, callback)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = pos
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

CreateButton("Toggle Silent Aim", UDim2.new(0.05, 0, 0.2, 0), function()
    state.rage.silent = not state.rage.silent
    print("Silent Aim: " .. tostring(state.rage.silent))
end)

CreateButton("Toggle ESP", UDim2.new(0.05, 0, 0.35, 0), function()
    state.visuals.esp = not state.visuals.esp
end)

CreateButton("Toggle NoClip", UDim2.new(0.05, 0, 0.5, 0), function()
    state.visuals.noclip = not state.visuals.noclip
end)

-- ========== ОБРАБОТЧИКИ СОБЫТИЙ ==========

table.insert(connections, RunService.RenderStepped:Connect(function()
    if state.unloaded then return end
    
    -- FOV Circle update
    FOVCircle.Visible = state.rage.silent
    FOVCircle.Radius = state.rage.fov
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    
    UpdateESP()
    HandleMovement()
end))

-- Silent Aim Logic
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, index)
    if self == Mouse and index == "Hit" and state.rage.silent then
        local target = GetClosestPlayer()
        if target and target.Character then
            return target.Character.HumanoidRootPart.CFrame
        end
    end
    return oldIndex(self, index)
end)

-- Keybinds (Insert & End)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        state.menu = not state.menu
        MainFrame.Visible = state.menu
    elseif input.KeyCode == Enum.KeyCode.End then
        state.unloaded = true
        screenGui:Destroy()
        espFolder:Destroy()
        FOVCircle:Remove()
        for _, c in pairs(connections) do c:Disconnect() end
        print("SQUADRIM UNLOADED")
    end
end)

print("SQUADRIM DLC PRO v5.0 Loaded! [INSERT] for menu.")
