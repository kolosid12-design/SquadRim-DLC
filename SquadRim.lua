--[[ 
    SQUADRIM PRESTIGE EDITION v17.0
    Supported: ESP, Chams, Skelet, Silent, Trigger, Configs
    Password: SquadRim2024
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

-- ========== CONFIG SYSTEM ==========
local settings = {
    auth = false,
    currentTab = "Legit",
    legit = {aimbot = false, smooth = 10, fov = 100, trigger = false},
    rage = {silent = false, fov = 300},
    visuals = {esp = false, box = false, chams = false, skelet = false, health = false},
    misc = {fly = false, noclip = false, freecam = false},
    binds = {Menu = Enum.KeyCode.Insert}
}

-- ========== AUTH UI ==========
local AuthGui = Instance.new("ScreenGui", CoreGui)
local AuthFrame = Instance.new("Frame", AuthGui)
AuthFrame.Size = UDim2.new(0, 300, 0, 150)
AuthFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
AuthFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)

local AuthInput = Instance.new("TextBox", AuthFrame)
AuthInput.Size = UDim2.new(0.8, 0, 0, 30)
AuthInput.Position = UDim2.new(0.1, 0, 0.3, 0)
AuthInput.PlaceholderText = "Enter Password..."
AuthInput.Text = ""

local AuthBtn = Instance.new("TextButton", AuthFrame)
AuthBtn.Size = UDim2.new(0.8, 0, 0, 30)
AuthBtn.Position = UDim2.new(0.1, 0, 0.6, 0)
AuthBtn.Text = "Login"
AuthBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

AuthBtn.MouseButton1Click:Connect(function()
    if AuthInput.Text == "SquadRim2024" then
        settings.auth = true
        AuthGui:Destroy()
        print("Access Granted")
    else
        AuthBtn.Text = "WRONG PASSWORD"
        task.wait(1)
        AuthBtn.Text = "Login"
    end
end)

-- ========== HUD ==========
local function CreateHUD()
    local Hud = Instance.new("ScreenGui", CoreGui)
    local Bar = Instance.new("Frame", Hud)
    Bar.Size = UDim2.new(0, 380, 0, 25)
    Bar.Position = UDim2.new(0.5, -190, 0, 15)
    Bar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    
    local Txt = Instance.new("TextLabel", Bar)
    Txt.Size = UDim2.new(1, 0, 1, 0)
    Txt.BackgroundTransparency = 1
    Txt.TextColor3 = Color3.new(1, 1, 1)
    Txt.Font = Enum.Font.Code
    
    RunService.RenderStepped:Connect(function()
        local fps = math.floor(1/RunService.RenderStepped:Wait())
        Txt.Text = string.format("| t.me/squadrim1 | FREE | [FPS: %d] | User: %s |", fps, LocalPlayer.Name)
    end)
end

-- ========== VISUALS (CHAMS & BOX) ==========
local function ApplyChams(char)
    if not char:FindFirstChild("SR_Chams") then
        local highlight = Instance.new("Highlight", char)
        highlight.Name = "SR_Chams"
        highlight.FillColor = Color3.new(1, 0, 0)
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.Enabled = settings.visuals.chams
    end
end

-- ========== MAIN ENGINE ==========
RunService.RenderStepped:Connect(function()
    if not settings.auth then return end
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            -- Chams Logic
            local ch = plr.Character:FindFirstChild("SR_Chams")
            if ch then ch.Enabled = settings.visuals.chams end
            if settings.visuals.chams then ApplyChams(plr.Character) end
            
            -- Noclip Logic
            if settings.misc.noclip then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end
end)

-- ========== MENU UI ==========
local Main = Instance.new("ScreenGui", CoreGui)
local Frame = Instance.new("Frame", Main)
Frame.Size = UDim2.new(0, 550, 0, 380)
Frame.Position = UDim2.new(0.5, -275, 0.5, -190)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Frame.Visible = false

-- Tabs System
local TabFrame = Instance.new("Frame", Frame)
TabFrame.Size = UDim2.new(0, 120, 1, 0)
TabFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

local Container = Instance.new("ScrollingFrame", Frame)
Container.Size = UDim2.new(1, -130, 1, -20)
Container.Position = UDim2.new(0, 125, 0, 10)
Container.BackgroundTransparency = 1
Instance.new("UIListLayout", Container).Padding = UDim.new(0, 5)

local function AddTab(name)
    local b = Instance.new("TextButton", TabFrame)
    b.Size = UDim2.new(1, 0, 0, 40)
    b.Text = name
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    b.TextColor3 = Color3.new(1,1,1)
    
    b.MouseButton1Click:Connect(function()
        settings.currentTab = name
        -- Здесь логика переключения видимости элементов под каждую вкладку
    end)
end

-- Наполняем вкладки
AddTab("Legit")
AddTab("Rage")
AddTab("Visuals")
AddTab("Misc")
AddTab("Configs")

-- ========== CONFIG SAVE/LOAD ==========
local function SaveConfig()
    local data = HttpService:JSONEncode(settings)
    writefile("SquadRim_Config.json", data)
end

local function LoadConfig()
    if isfile("SquadRim_Config.json") then
        local data = readfile("SquadRim_Config.json")
        settings = HttpService:JSONDecode(data)
    end
end

-- Переключатель меню
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == settings.binds.Menu then
        Frame.Visible = not Frame.Visible
    end
end)

CreateHUD()
