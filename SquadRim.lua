local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local GuiParent = pcall(function() return CoreGui end) and CoreGui or LocalPlayer:WaitForChild("PlayerGui")

_G.AutoSkip = false
_G.AutoReplay = false
_G.AutoPlace = false
_G.AutoCollect = false
_G.AutoUpgrade = false
_G.AutoAbilities = false
_G.AutoHeal = false
_G.AutoSpeed = false

_G.UnitToPlace = "Cameraman"
_G.DesiredSpeed = 3

local Remotes = {}
local function ScanForRemotes()
    table.clear(Remotes)
    local function check(obj)
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            Remotes[obj.Name:lower()] = obj
        end
    end
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        pcall(check, obj)
    end
    if Workspace:FindFirstChild("Remotes") then
        for _, obj in pairs(Workspace.Remotes:GetDescendants()) do
            pcall(check, obj)
        end
    end
end
pcall(ScanForRemotes)

local function GetActualRemote(possibleNames)
    for _, name in ipairs(possibleNames) do
        local cleaned = name:lower()
        if Remotes[cleaned] then
            return Remotes[cleaned]
        end
    end
    return nil
end

task.spawn(function()
    while task.wait(1) do
        if _G.AutoSkip then
            local event = GetActualRemote({"skipwave", "skip", "skipvote", "voteskip"})
            if event and event:IsA("RemoteEvent") then
                pcall(function() event:FireServer() end)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(2) do
        if _G.AutoReplay then
            local event = GetActualRemote({"replaymatch", "restartgame", "replay", "restart", "retry"})
            if event and event:IsA("RemoteEvent") then
                pcall(function() event:FireServer() end)
            end
        end
    end
end)

local function GetPlacePositions()
    local positions = {}
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and (part.Name:lower():find("slot") or part.Name:lower():find("place") or part.Name:lower():find("tower")) then
            table.insert(positions, part.CFrame)
        end
    end
    if #positions == 0 then
        for x = 1, 5 do
            for z = 1, 5 do
                table.insert(positions, CFrame.new(x * 12, 2, z * 12))
            end
        end
    end
    return positions
end

local placePositions = GetPlacePositions()
local posIndex = 1

task.spawn(function()
    while task.wait(2.5) do
        if _G.AutoPlace then
            local event = GetActualRemote({"placeunit", "buyunit", "spawnunit", "summonunit", "place"})
            if event and event:IsA("RemoteEvent") then
                pcall(function()
                    local targetCFrame = placePositions[posIndex % #placePositions + 1]
                    posIndex = posIndex + 1
                    event:FireServer(_G.UnitToPlace, targetCFrame)
                end)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        if _G.AutoCollect then
            local event = GetActualRemote({"collectmoney", "collect", "gather", "collectcash", "pickup"})
            if event and event:IsA("RemoteEvent") then
                pcall(function() event:FireServer() end)
            end
        end
    end
end)

local function GetMyUnits()
    local myUnits = {}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
            local owner = obj:FindFirstChild("Owner") or obj:FindFirstChild("Player")
            if owner and (owner.Value == LocalPlayer or tostring(owner.Value) == LocalPlayer.Name) then
                table.insert(myUnits, obj)
            end
        end
    end
    return myUnits
end

task.spawn(function()
    while task.wait(3) do
        if _G.AutoUpgrade then
            local event = GetActualRemote({"upgradeunit", "upgrade", "upgradetower"})
            if event and event:IsA("RemoteEvent") then
                local units = GetMyUnits()
                for _, unit in ipairs(units) do
                    pcall(function() 
                        event:FireServer(unit) 
                        task.wait(0.3)
                    end)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if _G.AutoAbilities then
            local event = GetActualRemote({"useability", "castability", "useskill", "activateability"})
            if event and event:IsA("RemoteEvent") then
                pcall(function() event:FireServer() end)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(4) do
        if _G.AutoHeal then
            local event = GetActualRemote({"healbase", "repairbase", "heal", "repair"})
            if event and event:IsA("RemoteEvent") then
                pcall(function() event:FireServer() end)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(3) do
        if _G.AutoSpeed then
            local event = GetActualRemote({"changespeed", "setgamespeed", "togglespeed", "speed"})
            if event and event:IsA("RemoteEvent") then
                pcall(function() event:FireServer(_G.DesiredSpeed) end)
            end
        end
    end
end)

if LocalPlayer then
    pcall(function()
        LocalPlayer.Idled:Connect(function()
            VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
            task.wait(0.2)
            VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        end)
    end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SkibiUltimate_v32"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = GuiParent

local MainPanel = Instance.new("Frame")
MainPanel.Name = "MainPanel"
MainPanel.Size = UDim2.new(0, 360, 0, 480)
MainPanel.Position = UDim2.new(0.5, -180, 0.5, -240)
MainPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
MainPanel.BorderSizePixel = 0
MainPanel.Active = true
MainPanel.Draggable = true
MainPanel.Visible = true
MainPanel.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainPanel

local Border = Instance.new("UIStroke")
Border.Thickness = 2
Border.Color = Color3.fromRGB(255, 65, 65)
Border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Border.Parent = MainPanel

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
Title.Text = "   ⚡ SWILL | SKIBI FARM v3.2 [FIXED]"
Title.TextColor3 = Color3.fromRGB(255, 80, 80)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainPanel

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -20, 1, -95)
Scroll.Position = UDim2.new(0, 10, 0, 55)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 410)
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 65, 65)
Scroll.Parent = MainPanel

local ListLayout = Instance.new("UIListLayout")
ListLayout.Padding = UDim.new(0, 6)
ListLayout.Parent = Scroll

local function CreateToggle(name, globalVar)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -6, 0, 42)
    Frame.BackgroundColor3 = Color3.fromRGB(32, 32, 45)
    Frame.BorderSizePixel = 0
    Frame.Parent = Scroll
    
    local FrameCorner = Instance.new("UICorner")
    FrameCorner.CornerRadius = UDim.new(0, 6)
    FrameCorner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(240, 240, 240)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 14
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 65, 0, 28)
    Button.Position = UDim2.new(1, -75, 0.5, -14)
    Button.BackgroundColor3 = Color3.fromRGB(130, 40, 40)
    Button.Text = "OFF"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.GothamBold
    Button.TextSize = 12
    Button.Parent = Frame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 5)
    BtnCorner.Parent = Button

    Button.MouseButton1Click:Connect(function()
        _G[globalVar] = not _G[globalVar]
        if _G[globalVar] then
            Button.BackgroundColor3 = Color3.fromRGB(40, 130, 40)
            Button.Text = "ON"
        else
            Button.BackgroundColor3 = Color3.fromRGB(130, 40, 40)
            Button.Text = "OFF"
        end
    end)
end

CreateToggle("🎮 Auto Skip Waves", "AutoSkip")
CreateToggle("🔄 Auto Replay Match", "AutoReplay")
CreateToggle("🏹 Auto Place Units", "AutoPlace")
CreateToggle("💰 Auto Collect Resources", "AutoCollect")
CreateToggle("⬆️ Auto Upgrade Units", "AutoUpgrade")
CreateToggle("✨ Auto Use Abilities", "AutoAbilities")
CreateToggle("💚 Auto Heal Base", "AutoHeal")
CreateToggle("⚡ Auto Match Speed", "AutoSpeed")

local StatusBar = Instance.new("TextLabel")
StatusBar.Size = UDim2.new(1, 0, 0, 30)
StatusBar.Position = UDim2.new(0, 0, 1, -30)
StatusBar.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
StatusBar.Text = "🟢 STATUS: BYPASSING CLICK DETECTORS"
StatusBar.TextColor3 = Color3.fromRGB(80, 220, 80)
StatusBar.TextSize = 11
StatusBar.Font = Enum.Font.GothamMedium
StatusBar.Parent = MainPanel

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 10)
StatusCorner.Parent = StatusBar

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        if MainPanel then
            MainPanel.Visible = not MainPanel.Visible
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(15)
        pcall(ScanForRemotes)
    end
end)

print("[SWILL EXPLOIT] Skibi Farm v3.2 initialized successfully!")
