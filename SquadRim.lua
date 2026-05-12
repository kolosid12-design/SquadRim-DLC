-- SquadRim DLC v17.1 – OPTIMIZED (caching, delayed updates, less lag)
-- Original v17 features untouched, only performance improvements
-- Open menu: INSERT | Unload: END

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInput = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- ========== OPTIMIZATION: CACHE SYSTEM ==========
local playerCache = { list = {}, timestamp = 0, cacheTime = 0.2 } -- update every 0.2 sec
local function refreshCache()
    if tick() - playerCache.timestamp < playerCache.cacheTime then return end
    playerCache.timestamp = tick()
    playerCache.list = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            if char and char.Parent then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChild("Humanoid")
                local head = char:FindFirstChild("Head")
                if hrp and hum and hum.Health > 0 then
                    playerCache.list[#playerCache.list+1] = {
                        plr = plr,
                        char = char,
                        hrp = hrp,
                        hum = hum,
                        head = head,
                        team = plr.Team,
                        pos = hrp.Position,
                        vel = hrp.Velocity
                    }
                end
            end
        end
    end
end

local function getCachedPlayers()
    refreshCache()
    return playerCache.list
end

-- Helper functions (unchanged)
local function getChar() return LocalPlayer.Character end
local function getRoot() local c = getChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c = getChar() return c and c:FindFirstChild("Humanoid") end
local function isEnemy(plr)
    if plr == LocalPlayer then return false end
    if LocalPlayer.Team and plr.Team then return LocalPlayer.Team ~= plr.Team end
    return true
end

-- Folders (unchanged)
local ChamsFolder = Instance.new("Folder", CoreGui); ChamsFolder.Name = "SquadRim_Chams"
local PlayerChams = Instance.new("Folder", ChamsFolder); PlayerChams.Name = "PlayerChams"
local ESPFolder = Instance.new("Folder", CoreGui); ESPFolder.Name = "SquadRim_ESP"
local PlayerESP = Instance.new("Folder", ESPFolder); PlayerESP.Name = "PlayerESP"
local ItemESPFolder = Instance.new("Folder", ESPFolder); ItemESPFolder.Name = "ItemESP"
local TracersFolder = Instance.new("Folder", Camera); TracersFolder.Name = "SquadRim_Tracers"

-- Settings (new names) + added ESPUpdateRate
local DefaultSettings = {
    ESP = false, Chams = false, Tracers = false, Fullbright = false, Crosshair = false,
    ChamsStyle = "Neon", ThirdPersonDist = 0, CrosshairStyle = "Cross", CrosshairColor = Color3.new(1,0,0),
    Aimbot = false, AimbotKey = "RightControl", AutoFire = false, Triggerbot = false, AimbotFOV = 100, ShowFOV = true,
    SpeedHack = false, SpeedValue = 50, InfiniteJump = false, Fly = false, Noclip = false, SavedPosition = nil,
    StealTool = false, AntiCrash = false, ChatSpam = false, SpamText = "SquadRim", SpamDelay = 5,
    AutoCollect = false, AutoCollectRadius = 50, BypassAFK = false, InstantRespawn = false,
    Wallbang = false, NoRecoil = false, NoSpread = false,
    Freecam = false, FreecamRadiusKill = 20, FreecamKillMethod = "HealthZero",
    HitboxExtender = false, HitboxSize = 2.5, ItemESP = false, NoFallDamage = false,
    SpawnKill = false, SpawnKillRadius = 20, AutoSprint = false, AntiAFKMove = false,
    NewAim = true, NewAimRMB = true, NewAimFOV = 35, NewAimSmoothness = 0.60,
    NewAimPart = "HumanoidRootPart", NewTeamCheck = true, NewWallCheck = true,
    NewESP = true, NewESPColor = Color3.fromRGB(255, 0, 0),
    ESPUpdateRate = 0.2, -- NEW: seconds between ESP/Chams/Tracers updates
}

local ToggleSettingsList = {
    "ESP", "Chams", "Tracers", "Fullbright", "Crosshair", "Aimbot", "Triggerbot", "AutoFire",
    "SpeedHack", "InfiniteJump", "Fly", "Noclip", "StealTool", "ChatSpam", "AutoCollect",
    "BypassAFK", "InstantRespawn", "Wallbang", "NoRecoil", "NoSpread", "HitboxExtender",
    "ItemESP", "NoFallDamage", "SpawnKill", "AutoSprint", "AntiAFKMove", "NewAim", "NewESP"
}
local BindOverrides = {}
for _, name in pairs(ToggleSettingsList) do BindOverrides[name] = nil end
local DefaultBinds = {
    ESP = "F7", Chams = "F8", Tracers = "F9", Fly = "F1", Noclip = "F2", Freecam = "F3",
    SpeedHack = "F10", InfiniteJump = "F11", AutoCollect = "F12", NewAim = "F4"
}

-- Load/Save
local Settings = {}
pcall(function()
    local d = HttpService:JSONDecode(readfile("SquadRimUltimate.json"))
    for k,v in pairs(d) do
        if DefaultSettings[k] ~= nil then Settings[k] = v
        elseif BindOverrides[k] ~= nil then BindOverrides[k] = v end
    end
end)
for k,v in pairs(DefaultSettings) do if Settings[k]==nil then Settings[k]=v end end
for k,v in pairs(DefaultBinds) do if BindOverrides[k]==nil then BindOverrides[k]=v end end
local function Save()
    local toSave = {}
    for k,v in pairs(Settings) do toSave[k] = v end
    for k,v in pairs(BindOverrides) do toSave[k] = v end
    pcall(function() writefile("SquadRimUltimate.json", HttpService:JSONEncode(toSave)) end)
end

-- ========== ALWAYS VISIBLE HUD (FPS) ==========
local function createFPSHUD()
    local hud = Instance.new("ScreenGui", CoreGui)
    hud.Name = "SquadRimFPSHUD"
    hud.ResetOnSpawn = false
    local label = Instance.new("TextLabel", hud)
    label.Size = UDim2.new(0, 280, 0, 30)
    label.Position = UDim2.new(0, 10, 1, -40)
    label.BackgroundTransparency = 0.75
    label.BackgroundColor3 = Color3.new(0,0,0)
    label.TextColor3 = Color3.new(1,1,1)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = "SquadRim DLC v17.1 | FPS: ---"
    local dragging = false; local dragStart = nil
    label.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = inp.Position end
    end)
    label.InputEnded:Connect(function() dragging = false end)
    label.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - dragStart
            label.Position = label.Position + UDim2.new(0, delta.X, 0, delta.Y)
            dragStart = inp.Position
        end
    end)
    return label
end
local fpsLabel = createFPSHUD()
local fpsValues = {}
local lastTime = tick()
RunService.RenderStepped:Connect(function()
    local now = tick()
    local dt = now - lastTime
    if dt > 0 then
        local fps = math.floor(1 / dt)
        table.insert(fpsValues, fps)
        if #fpsValues > 10 then table.remove(fpsValues, 1) end
        local sum = 0; for _,v in pairs(fpsValues) do sum = sum + v end
        local avgFPS = math.floor(sum / #fpsValues)
        fpsLabel.Text = string.format("SquadRim DLC v17.1 | FPS: %d | END unload", avgFPS)
    end
    lastTime = now
end)

-- ========== DRAGGABLE TARGET INFO (UNCHANGED) ==========
local targetInfoGui = Instance.new("ScreenGui", CoreGui)
targetInfoGui.Name = "SquadRimTargetInfo"
targetInfoGui.ResetOnSpawn = false
local targetFrame = Instance.new("Frame", targetInfoGui)
targetFrame.Size = UDim2.new(0, 280, 0, 120)
targetFrame.Position = UDim2.new(0, 10, 0, 50)
targetFrame.BackgroundTransparency = 0.8
targetFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.15)
targetFrame.BorderSizePixel = 2
targetFrame.BorderColor3 = Color3.new(1, 0.2, 0.2)
local corner = Instance.new("UICorner", targetFrame); corner.CornerRadius = UDim.new(0, 8)
local titleTarget = Instance.new("TextLabel", targetFrame)
titleTarget.Size = UDim2.new(1, 0, 0, 24)
titleTarget.Position = UDim2.new(0, 0, 0, 0)
titleTarget.BackgroundTransparency = 1
titleTarget.Text = "🎯 TARGET INFO"
titleTarget.TextColor3 = Color3.new(1, 0.8, 0)
titleTarget.Font = Enum.Font.GothamBold
titleTarget.TextSize = 16
titleTarget.TextXAlignment = Enum.TextXAlignment.Center
local targetText = Instance.new("TextLabel", targetFrame)
targetText.Size = UDim2.new(1, -10, 1, -30)
targetText.Position = UDim2.new(0, 5, 0, 25)
targetText.BackgroundTransparency = 1
targetText.TextColor3 = Color3.new(0.3, 1, 0.3)
targetText.TextStrokeTransparency = 0.5
targetText.Font = Enum.Font.SourceSansBold
targetText.TextSize = 15
targetText.TextXAlignment = Enum.TextXAlignment.Left
targetText.TextYAlignment = Enum.TextYAlignment.Top
targetText.Text = "No target"
local dragInfo = false; local dragInfoStart = nil
targetFrame.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragInfo = true; dragInfoStart = inp.Position end
end)
targetFrame.InputEnded:Connect(function() dragInfo = false end)
targetFrame.InputChanged:Connect(function(inp)
    if dragInfo and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = inp.Position - dragInfoStart
        targetFrame.Position = targetFrame.Position + UDim2.new(0, delta.X, 0, delta.Y)
        dragInfoStart = inp.Position
    end
end)

-- ========== DRAGGABLE BIND LIST (UNCHANGED) ==========
local bindListGui = Instance.new("ScreenGui", CoreGui)
bindListGui.Name = "SquadRimBindList"
bindListGui.ResetOnSpawn = false
local bindFrame = Instance.new("Frame", bindListGui)
bindFrame.Size = UDim2.new(0, 320, 0, 360)
bindFrame.Position = UDim2.new(1, -330, 0, 50)
bindFrame.BackgroundTransparency = 0.85
bindFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 45)
bindFrame.BorderSizePixel = 2
bindFrame.BorderColor3 = Color3.new(1, 0.8, 0)
local cornerBind = Instance.new("UICorner", bindFrame); cornerBind.CornerRadius = UDim.new(0, 10)
local titleBind = Instance.new("TextLabel", bindFrame)
titleBind.Size = UDim2.new(1, 0, 0, 26)
titleBind.Position = UDim2.new(0, 0, 0, 0)
titleBind.BackgroundTransparency = 0.5
titleBind.BackgroundColor3 = Color3.fromRGB(10, 12, 25)
titleBind.Text = "══ BIND LIST ══"
titleBind.TextColor3 = Color3.new(1, 0.9, 0.2)
titleBind.Font = Enum.Font.GothamBold
titleBind.TextSize = 16
local bindListText = Instance.new("TextLabel", bindFrame)
bindListText.Size = UDim2.new(1, -10, 1, -36)
bindListText.Position = UDim2.new(0, 5, 0, 30)
bindListText.BackgroundTransparency = 1
bindListText.TextColor3 = Color3.new(0.9, 0.9, 0.9)
bindListText.Font = Enum.Font.SourceSans
bindListText.TextSize = 12
bindListText.TextXAlignment = Enum.TextXAlignment.Left
bindListText.TextYAlignment = Enum.TextYAlignment.Top
bindListText.TextWrapped = true
local dragBind = false; local dragBindStart = nil
bindFrame.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragBind = true; dragBindStart = inp.Position end
end)
bindFrame.InputEnded:Connect(function() dragBind = false end)
bindFrame.InputChanged:Connect(function(inp)
    if dragBind and inp.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = inp.Position - dragBindStart
        bindFrame.Position = bindFrame.Position + UDim2.new(0, delta.X, 0, delta.Y)
        dragBindStart = inp.Position
    end
end)

local function updateBindList()
    local lines = {}
    for _, setting in ipairs(ToggleSettingsList) do
        local state = Settings[setting] and "ON" or "OFF"
        local key = BindOverrides[setting] or "none"
        local stateColor = (state == "ON") and "✓" or "✗"
        lines[#lines+1] = string.format("%s [%s] : %s", setting, stateColor, key)
    end
    lines[#lines+1] = string.format("AimbotKey: %s", Settings.AimbotKey)
    lines[#lines+1] = string.format("NewAimRMB: %s", Settings.NewAimRMB and "ON" or "OFF")
    bindListText.Text = table.concat(lines, "\n")
end

-- ========== NEWAIM TARGET ==========
local newAimTarget = nil

local function updateTargetInfo()
    local target = nil
    if Settings.NewAim and newAimTarget and newAimTarget.Parent then
        local plr = Players:GetPlayerFromCharacter(newAimTarget)
        if plr then target = plr end
    end
    if not target then
        local ray = Camera:ScreenPointToRay(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        local hit = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
        if hit and hit.Parent then
            local plr = Players:GetPlayerFromCharacter(hit.Parent)
            if plr and plr ~= LocalPlayer then target = plr end
        end
    end
    if target and target.Character then
        local hum = target.Character:FindFirstChild("Humanoid")
        local root = target.Character:FindFirstChild("HumanoidRootPart")
        local myRoot = getRoot()
        local dist = myRoot and root and (myRoot.Position - root.Position).magnitude or 0
        local health = hum and math.floor(hum.Health) or 0
        local team = target.Team and target.Team.Name or "None"
        local isEn = isEnemy(target)
        local healthColor = isEn and (health > 50 and Color3.new(0,1,0) or Color3.new(1,0.5,0)) or Color3.new(0,0.8,1)
        targetText.RichText = true
        targetText.Text = string.format("<font color='rgb(255,200,0)'>Name:</font> %s\n<font color='rgb(%d,%d,%d)'>❤ Health:</font> %d\n<font color='rgb(100,200,255)'>📏 Dist:</font> %.1f\n<font color='rgb(200,200,200)'>🏳 Team:</font> %s",
            target.Name, math.floor(healthColor.R*255), math.floor(healthColor.G*255), math.floor(healthColor.B*255), health, dist, team)
    else
        targetText.Text = "❌ No target"
    end
end

-- ========== LEGACY ESP, CHAMS, TRACERS (with caching) ==========
function getTeamColor(plr)
    if not plr or plr == LocalPlayer then return Color3.new(1,1,1) end
    if LocalPlayer.Team and plr.Team then return (LocalPlayer.Team == plr.Team) and Color3.new(0,1,0) or Color3.new(1,0,0) end
    return Color3.new(1,0,0)
end

function CreateESP(plr)
    if not Settings.ESP then return end
    if not plr or plr == LocalPlayer or not plr.Character then return end
    local head = plr.Character:FindFirstChild("Head")
    if not head then return end
    local existing = PlayerESP:FindFirstChild("ESP_"..plr.Name)
    if existing then existing:Destroy() end
    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP_"..plr.Name
    bb.Adornee = head
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0,5,0,5)
    bb.StudsOffset = Vector3.new(0,2.5,0)
    bb.Parent = PlayerESP
    local frame = Instance.new("Frame", bb); frame.BackgroundTransparency = 1; frame.Size = UDim2.new(1,0,1,0)
    local nameL = Instance.new("TextLabel", frame); nameL.Name = "Name"; nameL.BackgroundTransparency = 1
    nameL.Position = UDim2.new(0,0,0,-40); nameL.Size = UDim2.new(1,0,10,0); nameL.Font = Enum.Font.SourceSansBold
    nameL.TextSize = 12; nameL.TextStrokeTransparency = 0.5; nameL.Text = plr.Name
    local distL = nameL:Clone(); distL.Name = "Dist"; distL.Position = UDim2.new(0,0,0,-30)
    local healthL = nameL:Clone(); healthL.Name = "Health"; healthL.Position = UDim2.new(0,0,0,-20)
    distL.Parent = frame; healthL.Parent = frame
end

function UpdateAllESP()
    if not Settings.ESP then PlayerESP:ClearAllChildren() return end
    for _, data in ipairs(getCachedPlayers()) do
        local plr = data.plr
        local esp = PlayerESP:FindFirstChild("ESP_"..plr.Name)
        if not esp then
            CreateESP(plr)
        else
            local dist = (getRoot() and getRoot().Position and data.pos) and (getRoot().Position - data.pos).magnitude or 0
            local visible = dist < 10000 and not Settings.Freecam
            local nameL = esp.Frame:FindFirstChild("Name")
            local distL = esp.Frame:FindFirstChild("Dist")
            local healthL = esp.Frame:FindFirstChild("Health")
            if nameL then nameL.Visible = visible; nameL.TextColor3 = getTeamColor(plr) end
            if distL then distL.Visible = visible; distL.Text = "Dist: "..math.floor(dist); distL.TextColor3 = getTeamColor(plr) end
            if healthL then
                healthL.Visible = visible
                if data.hum and visible then healthL.Text = "HP: "..math.floor(data.hum.Health); healthL.TextColor3 = getTeamColor(plr) end
            end
            local head = data.head
            if head and esp.Adornee ~= head then esp.Adornee = head end
        end
    end
    for _, esp in pairs(PlayerESP:GetChildren()) do
        local name = esp.Name:sub(5)
        if not Players:FindFirstChild(name) then esp:Destroy() end
    end
end

function CreateChams(plr)
    if not Settings.Chams or not plr.Character then return end
    local folder = PlayerChams:FindFirstChild(plr.Name)
    if folder then folder:Destroy() end
    folder = Instance.new("Folder", PlayerChams); folder.Name = plr.Name
    for _, part in pairs(plr.Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            local adorn = Instance.new("BoxHandleAdornment")
            adorn.Size = part.Size; adorn.Adornee = part; adorn.AlwaysOnTop = true; adorn.ZIndex = 5
            adorn.Color3 = getTeamColor(plr)
            if Settings.ChamsStyle == "Neon" then adorn.Transparency = 0.3
            elseif Settings.ChamsStyle == "Glass" then adorn.Transparency = 0.6; adorn.Color3 = Color3.new(0,1,1)
            else adorn.LineThickness = 0.05; adorn.Transparency = 0.1 end
            adorn.Parent = folder
        end
    end
end

function UpdateAllChams()
    if not Settings.Chams then PlayerChams:ClearAllChildren() return end
    for _, data in ipairs(getCachedPlayers()) do
        local plr = data.plr
        local folder = PlayerChams:FindFirstChild(plr.Name)
        if not folder then
            CreateChams(plr)
        elseif folder and data.char then
            for _, adorn in pairs(folder:GetChildren()) do
                if adorn:IsA("BoxHandleAdornment") then
                    adorn.Color3 = getTeamColor(plr)
                    if Settings.ChamsStyle == "Neon" then adorn.Transparency = 0.3
                    elseif Settings.ChamsStyle == "Glass" then adorn.Transparency = 0.6
                    else adorn.Transparency = 0.1 end
                end
            end
        end
    end
end

function CreateTracers(plr)
    if TracersFolder:FindFirstChild(plr.Name) then return end
    local part = Instance.new("Part"); part.Name = plr.Name; part.Material = "Neon"; part.Transparency = 1
    part.Anchored = true; part.CanCollide = false
    local box = Instance.new("BoxHandleAdornment", part); box.Adornee = part; box.AlwaysOnTop = true; box.ZIndex = 5
    part.Parent = TracersFolder
end

function UpdateAllTracers()
    if not Settings.Tracers then TracersFolder:ClearAllChildren() return end
    for _, data in ipairs(getCachedPlayers()) do
        local plr = data.plr
        local tracer = TracersFolder:FindFirstChild(plr.Name)
        if not tracer then
            CreateTracers(plr)
        else
            local root = data.hrp
            local myRoot = getRoot()
            if root and myRoot then
                local start = Camera.CFrame.p; local finish = root.Position - Vector3.new(0,3,0)
                local dist = (start - finish).magnitude
                if dist > 2048 or Settings.Freecam then
                    tracer.BoxHandleAdornment.Transparency = 1
                else
                    tracer.BoxHandleAdornment.Transparency = 0
                    tracer.BoxHandleAdornment.Color3 = getTeamColor(plr)
                    tracer.Size = Vector3.new(0.1,0.1,dist)
                    tracer.CFrame = CFrame.new(start, finish) * CFrame.new(0,0,-dist/2)
                end
            end
        end
    end
end

function updateItemESP()
    if not Settings.ItemESP then ItemESPFolder:ClearAllChildren() return end
    for _, item in pairs(Workspace:GetDescendants()) do
        if item:IsA("BasePart") and (item.Name:lower():find("gun") or item.Name:lower():find("medkit") or item.Name:lower():find("health") or item.Name:lower():find("ammo")) then
            if not ItemESPFolder:FindFirstChild(item.Name..tostring(item)) then
                local bb = Instance.new("BillboardGui")
                bb.Name = "Item_"..item.Name; bb.Adornee = item; bb.AlwaysOnTop = true
                bb.Size = UDim2.new(0,3,0,3); bb.StudsOffset = Vector3.new(0,1,0); bb.Parent = ItemESPFolder
                local label = Instance.new("TextLabel", bb); label.BackgroundTransparency = 1
                label.Text = item.Name; label.TextColor3 = Color3.new(0,1,1); label.TextSize = 12
                label.Size = UDim2.new(1,0,1,0)
            end
        end
    end
    for _, child in pairs(ItemESPFolder:GetChildren()) do
        if not child.Adornee or not child.Adornee.Parent then child:Destroy() end
    end
end

-- ========== NEW AIM & NEW ESP ==========
local newAimFOVCircle = nil
local lastViewportSize = Camera.ViewportSize
local function setupFOVCircle()
    if not Settings.NewAim then
        if newAimFOVCircle then newAimFOVCircle:Remove() end
        return
    end
    if not newAimFOVCircle then
        newAimFOVCircle = Drawing.new("Circle")
        newAimFOVCircle.Visible = true
        newAimFOVCircle.Filled = false
        newAimFOVCircle.Thickness = 1
        newAimFOVCircle.NumSides = 64
        newAimFOVCircle.Color = Color3.fromRGB(90,90,210)
        newAimFOVCircle.Transparency = 1
    end
    -- Only update position/radius if viewport changed
    local currentSize = Camera.ViewportSize
    if currentSize ~= lastViewportSize then
        lastViewportSize = currentSize
        newAimFOVCircle.Position = currentSize / 2
        newAimFOVCircle.Radius = Settings.NewAimFOV * 8
    end
    newAimFOVCircle.Visible = Settings.NewAim and not Settings.Freecam
end

local function updateNewESP()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local highlight = plr.Character:FindFirstChild("NewESPHighlight")
            local textESP = PlayerESP:FindFirstChild("NewText_"..plr.Name)
            if Settings.NewESP and isEnemy(plr) then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "NewESPHighlight"
                    highlight.FillTransparency = 1
                    highlight.OutlineTransparency = 0
                    highlight.OutlineColor = Settings.NewESPColor
                    highlight.Parent = plr.Character
                else
                    highlight.OutlineColor = Settings.NewESPColor
                    highlight.Enabled = true
                end
                if not textESP and plr.Character:FindFirstChild("Head") then
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "NewText_"..plr.Name
                    bb.Adornee = plr.Character.Head
                    bb.AlwaysOnTop = true
                    bb.Size = UDim2.new(0,5,0,5)
                    bb.StudsOffset = Vector3.new(0,2.2,0)
                    bb.Parent = PlayerESP
                    local label = Instance.new("TextLabel", bb)
                    label.BackgroundTransparency = 1
                    label.TextColor3 = Settings.NewESPColor
                    label.TextStrokeTransparency = 0.3
                    label.Font = Enum.Font.GothamBold
                    label.TextSize = 14
                    label.Size = UDim2.new(1,0,1,0)
                end
            else
                if highlight then highlight:Destroy() end
                if textESP then textESP:Destroy() end
            end
            if textESP and textESP.Adornee then
                local hum = plr.Character:FindFirstChild("Humanoid")
                local root = plr.Character:FindFirstChild("HumanoidRootPart")
                local myRoot = getRoot()
                local dist = myRoot and root and (myRoot.Position - root.Position).magnitude or 0
                local health = hum and math.floor(hum.Health) or 0
                local label = textESP:FindFirstChildOfClass("TextLabel")
                if label then
                    label.Text = string.format("%s\nHP: %d | %.0fm", plr.Name, health, dist)
                    label.TextColor3 = Settings.NewESPColor
                end
            end
        end
    end
end

local function getClosestNewAimTarget()
    if not Settings.NewAim then return nil end
    local bestTarget = nil
    local bestAngle = Settings.NewAimFOV
    local myTeam = LocalPlayer.Team
    for _, data in ipairs(getCachedPlayers()) do
        local plr = data.plr
        if Settings.NewTeamCheck and myTeam and plr.Team == myTeam then continue end
        local hum = data.hum
        if not hum or hum.Health <= 0 then continue end
        local targetPart = data.char:FindFirstChild(Settings.NewAimPart) or data.hrp
        if not targetPart then continue end
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end
        local dir = (targetPart.Position - Camera.CFrame.Position).Unit
        local angle = math.deg(math.acos(math.clamp(dir:Dot(Camera.CFrame.LookVector), -1, 1)))
        if angle < bestAngle then
            if Settings.NewWallCheck then
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                local rayResult = Workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position), rayParams)
                if rayResult and rayResult.Instance:IsDescendantOf(data.char) then
                    bestTarget = data.char; bestAngle = angle
                elseif not rayResult then
                    bestTarget = data.char; bestAngle = angle
                end
            else
                bestTarget = data.char; bestAngle = angle
            end
        end
    end
    return bestTarget
end

local function smoothNewAim(targetChar)
    local targetPart = targetChar:FindFirstChild(Settings.NewAimPart) or targetChar:FindFirstChild("HumanoidRootPart")
    if not targetPart then return end
    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
    if not onScreen then return end
    local center = Camera.ViewportSize / 2
    local delta = Vector2.new(screenPos.X - center.X, screenPos.Y - center.Y)
    if delta.Magnitude < 1 then return end
    local moveX = delta.X * Settings.NewAimSmoothness * 0.32
    local moveY = delta.Y * Settings.NewAimSmoothness * 0.32
    moveX = math.clamp(moveX, -40, 40)
    moveY = math.clamp(moveY, -40, 40)
    if mousemoverel then mousemoverel(moveX, moveY) end
end

local rmbPressed = false
UserInput.InputBegan:connect(function(inp, gpe)
    if gpe then return end
    if Settings.NewAimRMB and inp.UserInputType == Enum.UserInputType.MouseButton2 then rmbPressed = true end
end)
UserInput.InputEnded:connect(function(inp)
    if Settings.NewAimRMB and inp.UserInputType == Enum.UserInputType.MouseButton2 then rmbPressed = false; newAimTarget = nil end
end)

RunService.RenderStepped:connect(function()
    setupFOVCircle()
    if Settings.NewAim and rmbPressed then
        if not newAimTarget or not newAimTarget.Parent then newAimTarget = getClosestNewAimTarget() end
        if newAimTarget then
            local hum = newAimTarget:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then smoothNewAim(newAimTarget) else newAimTarget = nil end
        end
    end
    updateNewESP()
end)

Players.PlayerAdded:connect(function(plr)
    if plr == LocalPlayer then return end
    plr.CharacterAdded:connect(function() if newAimTarget == plr.Character then newAimTarget = nil end end)
end)

-- ========== OLD AIMBOT (optimized with cache) ==========
local oldAimKeyPressed = false
local oldFOVCircle = nil
local function updateOldFOVCircle()
    if Settings.ShowFOV and Settings.Aimbot then
        if not oldFOVCircle then
            oldFOVCircle = Instance.new("ScreenGui", CoreGui); oldFOVCircle.Name = "OldAimbotFOV"
            local circle = Instance.new("Frame", oldFOVCircle)
            circle.BackgroundTransparency = 0.8; circle.BorderSizePixel = 1; circle.BorderColor3 = Color3.new(1,0,0)
            circle.BackgroundColor3 = Color3.new(1,1,1); circle.ZIndex = 999
            circle.Size = UDim2.new(0, Settings.AimbotFOV*2, 0, Settings.AimbotFOV*2)
            circle.Position = UDim2.new(0.5, -Settings.AimbotFOV, 0.5, -Settings.AimbotFOV)
        else
            local circle = oldFOVCircle:FindFirstChildOfClass("Frame")
            if circle then
                circle.Size = UDim2.new(0, Settings.AimbotFOV*2, 0, Settings.AimbotFOV*2)
                circle.Position = UDim2.new(0.5, -Settings.AimbotFOV, 0.5, -Settings.AimbotFOV)
            end
        end
    else
        if oldFOVCircle then oldFOVCircle:Destroy(); oldFOVCircle = nil end
    end
end

local function getClosestEnemyInFOV()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local best, bestAngle = nil, math.huge
    for _, data in ipairs(getCachedPlayers()) do
        local plr = data.plr
        if isEnemy(plr) and data.head then
            local screenPos, onScreen = Camera:WorldToViewportPoint(data.head.Position)
            if onScreen then
                local delta = Vector2.new(screenPos.X - center.X, screenPos.Y - center.Y)
                local angle = delta.Magnitude
                if angle < bestAngle and angle < Settings.AimbotFOV then
                    best, bestAngle = plr, angle
                end
            end
        end
    end
    return best
end

RunService:BindToRenderStep("OldAimbotSystem", 1, function()
    updateOldFOVCircle()
    if Settings.Aimbot and oldAimKeyPressed then
        local target = getClosestEnemyInFOV()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local head = target.Character.Head
            Camera.CFrame = CFrame.new(Camera.CFrame.p, head.Position)
            if Settings.AutoFire then pcall(mouse1click) end
        end
    end
    if Settings.Triggerbot then
        local target = getClosestEnemyInFOV()
        if target and target.Character then
            local ray = Camera:ScreenPointToRay(Mouse.X, Mouse.Y)
            local hit = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
            if hit and hit:IsDescendantOf(target.Character) then
                pcall(mouse1click)
                task.wait(0.05)
            end
        end
    end
end)

UserInput.InputBegan:connect(function(i,g) if not g and i.KeyCode.Name == Settings.AimbotKey then oldAimKeyPressed = true end end)
UserInput.InputEnded:connect(function(i) if i.KeyCode.Name == Settings.AimbotKey then oldAimKeyPressed = false end end)

-- ========== MOVEMENT & MISC (optimized loops) ==========
-- Hitbox extender and no fall damage are cheap, keep in RenderStepped
RunService.RenderStepped:connect(function()
    if Settings.HitboxExtender then
        for _, data in ipairs(getCachedPlayers()) do
            if isEnemy(data.plr) and data.head then
                data.head.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
            end
        end
    end
    if Settings.NoFallDamage and getHum() then
        local hum = getHum()
        if hum and hum:GetState() == Enum.HumanoidStateType.FallingDown then hum:ChangeState(Enum.HumanoidStateType.Landed) end
    end
end)

Players.PlayerAdded:connect(function(plr)
    if not Settings.SpawnKill then return end
    task.wait(2)
    if plr.Character then
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        local myRoot = getRoot()
        if root and myRoot and (root.Position - myRoot.Position).magnitude <= Settings.SpawnKillRadius then
            local hum = plr.Character:FindFirstChild("Humanoid")
            if hum then hum.Health = 0; plr.Character:BreakJoints() end
        end
    end
end)

RunService.RenderStepped:connect(function()
    if Settings.AutoSprint and getHum() then
        local hum = getHum()
        if hum and hum.MoveDirection.Magnitude > 0 then hum.WalkSpeed = math.max(hum.WalkSpeed, 50) end
    end
end)

task.spawn(function()
    local angle = 0
    while true do
        task.wait(60)
        if Settings.AntiAFKMove then
            angle = angle + 5
            Camera.CFrame = Camera.CFrame * CFrame.Angles(0, math.rad(5), 0)
        end
    end
end)

local function updateCrosshair()
    local cross = CoreGui:FindFirstChild("SquadCross")
    if Settings.Crosshair then
        if not cross then cross = Instance.new("ScreenGui", CoreGui); cross.Name = "SquadCross"
        else cross:ClearAllChildren() end
        local vp = Camera.ViewportSize
        if Settings.CrosshairStyle == "Cross" then
            local l1 = Instance.new("TextLabel", cross); l1.Size = UDim2.new(0,35,0,1); l1.BackgroundColor3 = Settings.CrosshairColor; l1.BorderSizePixel = 0; l1.Position = UDim2.new(0, vp.X/2-17.5, 0, vp.Y/2)
            local l2 = Instance.new("TextLabel", cross); l2.Size = UDim2.new(0,1,0,35); l2.BackgroundColor3 = Settings.CrosshairColor; l2.BorderSizePixel = 0; l2.Position = UDim2.new(0, vp.X/2, 0, vp.Y/2-17.5)
        elseif Settings.CrosshairStyle == "Dot" then
            local dot = Instance.new("Frame", cross); dot.Size = UDim2.new(0,4,0,4); dot.Position = UDim2.new(0.5,-2,0.5,-2); dot.BackgroundColor3 = Settings.CrosshairColor; dot.BorderSizePixel = 0
        elseif Settings.CrosshairStyle == "Circle" then
            local circle = Instance.new("Frame", cross); circle.Size = UDim2.new(0,15,0,15); circle.Position = UDim2.new(0.5,-7.5,0.5,-7.5); circle.BackgroundTransparency = 0.7; circle.BorderSizePixel = 1; circle.BorderColor3 = Settings.CrosshairColor; circle.BackgroundColor3 = Color3.new(0,0,0)
        end
    else
        if cross then cross:Destroy() end
    end
end

-- Freecam (unchanged)
local freecamCam, freecamBodyPos, freecamBodyGyro = nil, nil, nil
local freecamActive = false
local function startFreecam()
    if freecamActive then return end
    freecamActive = true
    freecamCam = Instance.new("Camera")
    freecamCam.CFrame = Camera.CFrame
    freecamCam.Parent = Workspace
    Camera.CameraType = Enum.CameraType.Scriptable
    Camera.CameraSubject = nil
    Camera.CFrame = freecamCam.CFrame
    local r = getRoot()
    if r then
        freecamBodyPos = Instance.new("BodyPosition")
        freecamBodyPos.MaxForce = Vector3.new(1e6,1e6,1e6)
        freecamBodyPos.P = 10000
        freecamBodyPos.D = 500
        freecamBodyPos.Position = r.Position
        freecamBodyPos.Parent = r
        freecamBodyGyro = Instance.new("BodyGyro")
        freecamBodyGyro.MaxTorque = Vector3.new(1e6,1e6,1e6)
        freecamBodyGyro.CFrame = r.CFrame
        freecamBodyGyro.Parent = r
    end
    local h = getHum()
    if h then h.PlatformStand = true end
end
local function stopFreecam()
    if not freecamActive then return end
    freecamActive = false
    if freecamCam then freecamCam:Destroy() end
    Camera.CameraType = Enum.CameraType.Custom
    if freecamBodyPos then freecamBodyPos:Destroy() end
    if freecamBodyGyro then freecamBodyGyro:Destroy() end
    local h = getHum()
    if h then h.PlatformStand = false end
end
local lastTickFreecam = tick()
RunService.RenderStepped:connect(function()
    if Settings.Freecam then
        if not freecamActive then startFreecam() end
        local now = tick()
        local dt = math.min(0.033, now - lastTickFreecam)
        lastTickFreecam = now
        if freecamCam then
            local mv = Vector3.new(0,0,0)
            if UserInput:IsKeyDown(Enum.KeyCode.W) then mv = mv + Vector3.new(0,0,-1) end
            if UserInput:IsKeyDown(Enum.KeyCode.S) then mv = mv + Vector3.new(0,0,1) end
            if UserInput:IsKeyDown(Enum.KeyCode.A) then mv = mv + Vector3.new(-1,0,0) end
            if UserInput:IsKeyDown(Enum.KeyCode.D) then mv = mv + Vector3.new(1,0,0) end
            if UserInput:IsKeyDown(Enum.KeyCode.Q) then mv = mv + Vector3.new(0,-1,0) end
            if UserInput:IsKeyDown(Enum.KeyCode.E) then mv = mv + Vector3.new(0,1,0) end
            mv = mv * 30 * dt
            local newCF = freecamCam.CFrame + freecamCam.CFrame:VectorToWorldSpace(mv)
            freecamCam.CFrame = newCF
            Camera.CFrame = newCF
        end
    elseif freecamActive then stopFreecam() end
end)

local function killPlayer(plr)
    if not plr or not plr.Character then return end
    local hum = plr.Character:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return end
    if Settings.FreecamKillMethod == "HealthZero" then hum.Health = 0; plr.Character:BreakJoints()
    else
        local rem = ReplicatedStorage:FindFirstChild("DamagePlayer") or ReplicatedStorage:FindFirstChild("TakeDamage")
        if rem and rem:IsA("RemoteEvent") then rem:FireServer(plr, 1000) else hum.Health = 0 end
    end
end

UserInput.InputBegan:connect(function(inp, gpe)
    if gpe then return end
    if Settings.Freecam then
        if inp.KeyCode == Enum.KeyCode.F then
            local center = freecamActive and (freecamCam and freecamCam.CFrame.p) or (getRoot() and getRoot().Position) or Vector3.new(0,0,0)
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local r = p.Character:FindFirstChild("HumanoidRootPart")
                    if r and (r.Position - center).magnitude <= Settings.FreecamRadiusKill then killPlayer(p) end
                end
            end
        elseif inp.KeyCode == Enum.KeyCode.V then
            local ray = Camera:ScreenPointToRay(Mouse.X, Mouse.Y)
            local hit = Workspace:FindPartOnRay(ray, LocalPlayer.Character)
            if hit then
                local plr = Players:GetPlayerFromCharacter(hit.Parent)
                if plr and plr ~= LocalPlayer then killPlayer(plr) end
            end
        end
    end
end)

-- SpeedHack, Fly, Noclip, etc. (unchanged, they are light)
RunService.RenderStepped:connect(function()
    local h = getHum()
    if h then
        if Settings.SpeedHack then h.WalkSpeed = Settings.SpeedValue
        elseif h.WalkSpeed == Settings.SpeedValue then h.WalkSpeed = 16 end
    end
end)

UserInput.InputBegan:connect(function(i,g)
    if g then return end
    if Settings.InfiniteJump and i.KeyCode == Enum.KeyCode.Space then
        local h = getHum()
        if h and h:GetState() == Enum.HumanoidStateType.Landed then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local flyBV, flyConn
local function startFlyLogic()
    if flyConn then flyConn:Disconnect() end
    local r = getRoot()
    if not r then return end
    flyBV = Instance.new("BodyVelocity"); flyBV.MaxForce = Vector3.new(1e5,1e5,1e5); flyBV.Parent = r
    local h = getHum(); if h then h.PlatformStand = true end
    flyConn = RunService.RenderStepped:connect(function()
        if not Settings.Fly then
            if flyBV then flyBV:Destroy() end; if h then h.PlatformStand = false end; flyConn:Disconnect(); flyConn = nil; return
        end
        local mv = Vector3.new(0,0,0)
        if UserInput:IsKeyDown(Enum.KeyCode.W) then mv = mv + Vector3.new(0,0,-50) end
        if UserInput:IsKeyDown(Enum.KeyCode.S) then mv = mv + Vector3.new(0,0,50) end
        if UserInput:IsKeyDown(Enum.KeyCode.A) then mv = mv + Vector3.new(-50,0,0) end
        if UserInput:IsKeyDown(Enum.KeyCode.D) then mv = mv + Vector3.new(50,0,0) end
        if UserInput:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.new(0,50,0) end
        if UserInput:IsKeyDown(Enum.KeyCode.LeftControl) then mv = mv + Vector3.new(0,-50,0) end
        flyBV.Velocity = Camera.CFrame:VectorToWorldSpace(mv)
    end)
end
RunService.RenderStepped:connect(function()
    if Settings.Fly and not flyConn then startFlyLogic()
    elseif not Settings.Fly and flyConn then
        flyConn:Disconnect(); flyConn = nil; if flyBV then flyBV:Destroy() end
        local h = getHum(); if h then h.PlatformStand = false end
    end
end)

local function applyNoclip()
    if Settings.Noclip and getChar() then
        for _, part in pairs(getChar():GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
    end
end
RunService.RenderStepped:connect(applyNoclip)
LocalPlayer.CharacterAdded:connect(function() task.wait(0.1); applyNoclip() end)

RunService.RenderStepped:connect(function()
    if Settings.AutoCollect and getRoot() then
        local r = getRoot()
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("health") or obj.Name:lower():find("pickup")) then
                if (r.Position - obj.Position).magnitude < Settings.AutoCollectRadius then
                    r.CFrame = CFrame.new(obj.Position + Vector3.new(0,3,0)); task.wait(0.05)
                end
            end
        end
    end
end)

task.spawn(function()
    while true do task.wait(30); if Settings.BypassAFK then pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new(0,0)) end) end end
end)

RunService.RenderStepped:connect(function()
    if Settings.InstantRespawn and getHum() and getHum().Health <= 0 then
        local btn = CoreGui:FindFirstChild("RespawnButton", true); if btn and btn:IsA("TextButton") then btn:Click() end
        local err = game:GetService("GuiService"):FindFirstChild("ErrorMessage"); if err then game:GetService("GuiService"):ClearError() end
    end
end)

task.spawn(function()
    while true do task.wait(Settings.SpamDelay); if Settings.ChatSpam and Settings.SpamText ~= "" then LocalPlayer.Chat:Chat(Settings.SpamText) end end
end)

RunService.RenderStepped:connect(function()
    if Settings.NoRecoil then
        Camera.CameraType = Enum.CameraType.Scriptable; Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + Camera.CFrame.LookVector)
    end
    if Settings.NoSpread and getChar() then
        local tool = getChar():FindFirstChildOfClass("Tool")
        if tool then
            local stats = tool:FindFirstChild("Stats") or tool:FindFirstChild("Values")
            if stats then for _, v in pairs(stats:GetChildren()) do if v.Name:lower():find("spread") or v.Name:lower():find("accuracy") then pcall(function() v.Value = 0 end) end end end
        end
    end
end)

local wallbangConn
RunService.RenderStepped:connect(function()
    if Settings.Wallbang and not wallbangConn then
        wallbangConn = RunService.RenderStepped:connect(function()
            if not Settings.Wallbang then if wallbangConn then wallbangConn:Disconnect(); wallbangConn = nil end return end
            local target = Mouse.Target
            if target and target:IsA("BasePart") and target.CanCollide then target.CanCollide = false; task.wait(0.1); if target then target.CanCollide = true end end
        end)
    elseif not Settings.Wallbang and wallbangConn then wallbangConn:Disconnect(); wallbangConn = nil end
end)

local function applyFullbright()
    if Settings.Fullbright then Lighting.Ambient = Color3.new(1,1,1) else Lighting.Ambient = Color3.new(0,0,0) end
end
RunService.RenderStepped:connect(function() applyFullbright(); updateCrosshair(); updateItemESP() end)

RunService.RenderStepped:connect(function()
    if not Settings.Freecam and Settings.ThirdPersonDist > 0 then
        Camera.CameraType = Enum.CameraType.Scriptable
        local r = getRoot()
        if r then
            local offset = Camera.CFrame.LookVector * -Settings.ThirdPersonDist
            Camera.CFrame = CFrame.new(r.Position + offset, r.Position)
        end
    elseif not Settings.Freecam and Camera.CameraType == Enum.CameraType.Scriptable and Settings.ThirdPersonDist == 0 then
        Camera.CameraType = Enum.CameraType.Custom
    end
end)

-- ========== OPTIMIZED HEAVY UPDATES (ESP, Chams, Tracers) ==========
local lastHeavyUpdate = 0
RunService.Heartbeat:Connect(function(dt)
    if tick() - lastHeavyUpdate > Settings.ESPUpdateRate then
        lastHeavyUpdate = tick()
        if not Settings.Freecam then
            UpdateAllESP()
            UpdateAllChams()
            UpdateAllTracers()
        end
    end
end)

-- ========== UNIVERSAL BIND HANDLER ==========
UserInput.InputBegan:connect(function(i, gpe)
    if gpe then return end
    local key = i.KeyCode.Name
    for setting, boundKey in pairs(BindOverrides) do
        if boundKey == key and Settings[setting] ~= nil then
            Settings[setting] = not Settings[setting]
            if setting == "Freecam" then
                if Settings.Freecam then startFreecam() else stopFreecam() end
            elseif setting == "NewAim" and not Settings.NewAim then newAimTarget = nil
            elseif setting == "ESP" then
                if Settings.ESP then UpdateAllESP() else PlayerESP:ClearAllChildren() end
            elseif setting == "Chams" then
                if Settings.Chams then for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer then CreateChams(p) end end else PlayerChams:ClearAllChildren() end
            elseif setting == "Tracers" then
                if Settings.Tracers then UpdateAllTracers() else TracersFolder:ClearAllChildren() end
            elseif setting == "Fullbright" then applyFullbright()
            elseif setting == "Crosshair" then updateCrosshair()
            elseif setting == "ItemESP" then updateItemESP()
            elseif setting == "NewESP" then updateNewESP()
            end
            Save()
            updateBindList()
            break
        end
    end
    if key == Settings.AimbotKey then oldAimKeyPressed = true end
    if key == BindOverrides["TeleportSave"] then
        local r = getRoot(); if r then Settings.SavedPosition = r.CFrame; Save() end
    elseif key == BindOverrides["TeleportLoad"] then
        local r = getRoot(); if r and Settings.SavedPosition then r.CFrame = Settings.SavedPosition end
    end
end)
UserInput.InputEnded:connect(function(i)
    if i.KeyCode.Name == Settings.AimbotKey then oldAimKeyPressed = false end
end)

-- ========== MENU GUI (unchanged) ==========
local menuGui = Instance.new("ScreenGui", CoreGui); menuGui.Name = "SquadRimMenu"
local mainFrame = Instance.new("Frame", menuGui); mainFrame.Size = UDim2.new(0, 800, 0, 700); mainFrame.Position = UDim2.new(0.5, -400, 0.5, -350); mainFrame.BackgroundColor3 = Color3.fromRGB(30,30,40); mainFrame.Draggable = true; mainFrame.Active = true; mainFrame.Visible = false
local title = Instance.new("TextLabel", mainFrame); title.Size = UDim2.new(1,0,0,30); title.BackgroundColor3 = Color3.fromRGB(20,20,30); title.Text = "SquadRim DLC | ALL GAME | FREE"; title.TextColor3 = Color3.new(1,1,1)

local tabs = {"Visuals","Aimbot","Movement","Misc","Freecam","NewAim","BindManager","Extras","Settings"}
local btns, panels = {}, {}
for i, name in ipairs(tabs) do
    local btn = Instance.new("TextButton", mainFrame); btn.Size = UDim2.new(0, 88, 0, 30); btn.Position = UDim2.new(0, (i-1)*88+4, 0, 30)
    btn.Text = name; btn.BackgroundColor3 = Color3.fromRGB(50,50,60); btn.TextColor3 = Color3.new(1,1,1)
    local panel = Instance.new("ScrollingFrame", mainFrame); panel.Size = UDim2.new(1, -20, 1, -80); panel.Position = UDim2.new(0,10,0,65)
    panel.BackgroundTransparency = 1; panel.CanvasSize = UDim2.new(0,0,0,800); panel.ScrollBarThickness = 6; panel.Visible = (i==1)
    btns[name] = btn; panels[name] = panel
    btn.MouseButton1Click:connect(function()
        for _, p in pairs(panels) do p.Visible = false end
        for _, b in pairs(btns) do b.BackgroundColor3 = Color3.fromRGB(50,50,60) end
        panel.Visible = true; btn.BackgroundColor3 = Color3.fromRGB(80,80,100)
    end)
end

local function addToggle(parent, y, text, setting)
    local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(0, 300, 0, 30); btn.Position = UDim2.new(0, 15, 0, y)
    btn.Text = text..": "..tostring(Settings[setting]); btn.BackgroundColor3 = Color3.fromRGB(60,60,70); btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:connect(function()
        Settings[setting] = not Settings[setting]
        btn.Text = text..": "..tostring(Settings[setting])
        if setting == "Freecam" then
            if Settings.Freecam then startFreecam() else stopFreecam() end
        elseif setting == "NewAim" and not Settings.NewAim then newAimTarget = nil
        elseif setting == "ESP" then if Settings.ESP then UpdateAllESP() else PlayerESP:ClearAllChildren() end
        elseif setting == "Chams" then if Settings.Chams then for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer then CreateChams(p) end end else PlayerChams:ClearAllChildren() end
        elseif setting == "Tracers" then if Settings.Tracers then UpdateAllTracers() else TracersFolder:ClearAllChildren() end
        elseif setting == "Fullbright" then applyFullbright()
        elseif setting == "Crosshair" then updateCrosshair()
        elseif setting == "ItemESP" then updateItemESP()
        elseif setting == "NewESP" then updateNewESP()
        end
        Save()
        updateBindList()
    end)
    return btn
end

local function addSlider(parent, y, text, minv, maxv, setting, step)
    step = step or (maxv-minv)/10
    local lab = Instance.new("TextLabel", parent); lab.Size = UDim2.new(0,200,0,20); lab.Position = UDim2.new(0,15,0,y)
    lab.BackgroundTransparency = 1; lab.TextColor3 = Color3.new(1,1,1); lab.Text = text..": "..string.format("%.2f", Settings[setting])
    local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(0,200,0,25); btn.Position = UDim2.new(0,15,0,y+20)
    btn.Text = "< "..string.format("%.2f", Settings[setting]).." >"; btn.BackgroundColor3 = Color3.fromRGB(60,60,70); btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:connect(function()
        local new = Settings[setting] + step; if new > maxv then new = minv end
        Settings[setting] = new; lab.Text = text..": "..string.format("%.2f", new); btn.Text = "< "..string.format("%.2f", new).." >"; Save()
    end)
    return btn
end

local function addKeybindForSetting(parent, y, text, setting)
    local btn = Instance.new("TextButton", parent); btn.Size = UDim2.new(0, 300, 0, 30); btn.Position = UDim2.new(0, 15, 0, y)
    local current = BindOverrides[setting] or "none"
    btn.Text = text.." key: "..current; btn.BackgroundColor3 = Color3.fromRGB(60,60,70); btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:connect(function()
        btn.Text = "Press any key..."
        local inp = UserInput.InputBegan:wait()
        local key = inp.KeyCode.Name
        BindOverrides[setting] = key
        btn.Text = text.." key: "..key
        Save()
        updateBindList()
    end)
    return btn
end

-- Visuals tab
local v = panels.Visuals; local y=10
addToggle(v, y, "ESP (legacy)", "ESP"); y=y+35
addToggle(v, y, "Chams", "Chams"); y=y+35
addToggle(v, y, "Tracers", "Tracers"); y=y+35
addToggle(v, y, "Item ESP", "ItemESP"); y=y+35
addToggle(v, y, "Fullbright", "Fullbright"); y=y+35
addToggle(v, y, "Crosshair", "Crosshair"); y=y+35
local styleBtn = Instance.new("TextButton", v); styleBtn.Size = UDim2.new(0,300,0,30); styleBtn.Position = UDim2.new(0,15,0,y)
styleBtn.Text = "Chams Style: "..Settings.ChamsStyle; styleBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
styleBtn.MouseButton1Click:connect(function() local s={"Neon","Glass","Wireframe"} local idx = table.find(s,Settings.ChamsStyle) or 1; Settings.ChamsStyle = s[(idx%3)+1]; styleBtn.Text = "Chams Style: "..Settings.ChamsStyle; if Settings.Chams then for _,p in pairs(Players:GetPlayers()) do if p~=LocalPlayer then CreateChams(p) end end end; Save() end)
y=y+35
addSlider(v, y, "3rd Person Dist", 0, 20, "ThirdPersonDist", 1); y=y+55
local crossStyleBtn = Instance.new("TextButton", v); crossStyleBtn.Size = UDim2.new(0,300,0,30); crossStyleBtn.Position = UDim2.new(0,15,0,y)
crossStyleBtn.Text = "Crosshair Style: "..Settings.CrosshairStyle; crossStyleBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
crossStyleBtn.MouseButton1Click:connect(function() local styles = {"Cross","Dot","Circle"}; local idx = table.find(styles,Settings.CrosshairStyle) or 1; Settings.CrosshairStyle = styles[(idx%3)+1]; crossStyleBtn.Text = "Crosshair Style: "..Settings.CrosshairStyle; updateCrosshair(); Save() end)

-- Aimbot tab
local a = panels.Aimbot; y=10
addToggle(a, y, "Aimbot (old)", "Aimbot"); y=y+35
addToggle(a, y, "Triggerbot", "Triggerbot"); y=y+35
addToggle(a, y, "Auto Fire", "AutoFire"); y=y+35
addToggle(a, y, "Show FOV Circle", "ShowFOV"); y=y+35
addSlider(a, y, "FOV Radius (px)", 20, 300, "AimbotFOV", 10); y=y+55
local keyBtn = Instance.new("TextButton", a); keyBtn.Size = UDim2.new(0,300,0,30); keyBtn.Position = UDim2.new(0,15,0,y)
keyBtn.Text = "Aimbot Key: "..Settings.AimbotKey; keyBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
keyBtn.MouseButton1Click:connect(function() keyBtn.Text = "Press any key..."; local inp = UserInput.InputBegan:wait(); local k = inp.KeyCode.Name; Settings.AimbotKey = k; keyBtn.Text = "Aimbot Key: "..k; Save() end)

-- Movement
local m = panels.Movement; y=10
addToggle(m, y, "SpeedHack", "SpeedHack"); y=y+35
addSlider(m, y, "Speed Value", 16, 500, "SpeedValue", 10); y=y+55
addToggle(m, y, "Infinite Jump", "InfiniteJump"); y=y+35
addToggle(m, y, "Fly", "Fly"); y=y+35
addToggle(m, y, "Noclip", "Noclip"); y=y+35
addToggle(m, y, "Auto Sprint", "AutoSprint")

-- Misc
local misc = panels.Misc; y=10
addToggle(misc, y, "Steal Tool", "StealTool"); y=y+35
addToggle(misc, y, "Chat Spam", "ChatSpam"); y=y+35
addToggle(misc, y, "Auto Collect", "AutoCollect"); y=y+35
addToggle(misc, y, "Bypass AFK", "BypassAFK"); y=y+35
addToggle(misc, y, "Instant Respawn", "InstantRespawn"); y=y+35
addToggle(misc, y, "Wallbang", "Wallbang"); y=y+35
addToggle(misc, y, "No Recoil", "NoRecoil"); y=y+35
addToggle(misc, y, "No Spread", "NoSpread"); y=y+35
addToggle(misc, y, "No Fall Damage", "NoFallDamage"); y=y+35
addToggle(misc, y, "Anti-AFK Move", "AntiAFKMove")

-- Freecam
local free = panels.Freecam; y=10
addToggle(free, y, "Freecam Mode", "Freecam"); y=y+35
addSlider(free, y, "Kill Radius", 10, 30, "FreecamRadiusKill", 2); y=y+55
local methBtn = Instance.new("TextButton", free); methBtn.Size = UDim2.new(0,300,0,30); methBtn.Position = UDim2.new(0,15,0,y)
methBtn.Text = "Kill Method: "..Settings.FreecamKillMethod; methBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
methBtn.MouseButton1Click:connect(function() if Settings.FreecamKillMethod=="HealthZero" then Settings.FreecamKillMethod="RemoteSpam" else Settings.FreecamKillMethod="HealthZero" end; methBtn.Text="Kill Method: "..Settings.FreecamKillMethod; Save() end)

-- NewAim
local na = panels.NewAim; y=10
addToggle(na, y, "NewAim (RMB)", "NewAim"); y=y+35
addToggle(na, y, "Team Check", "NewTeamCheck"); y=y+35
addToggle(na, y, "Wall Check", "NewWallCheck"); y=y+35
addSlider(na, y, "Aim FOV (degrees)", 5, 50, "NewAimFOV", 1); y=y+55
addSlider(na, y, "Smoothness", 0.05, 1.0, "NewAimSmoothness", 0.05); y=y+55
local aimPartBtn = Instance.new("TextButton", na); aimPartBtn.Size = UDim2.new(0,300,0,30); aimPartBtn.Position = UDim2.new(0,15,0,y)
aimPartBtn.Text = "Aim Part: "..Settings.NewAimPart; aimPartBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
aimPartBtn.MouseButton1Click:connect(function()
    if Settings.NewAimPart == "HumanoidRootPart" then Settings.NewAimPart = "Head" else Settings.NewAimPart = "HumanoidRootPart" end
    aimPartBtn.Text = "Aim Part: "..Settings.NewAimPart; Save()
end)
y=y+35
addToggle(na, y, "NewESP (Highlight+Text)", "NewESP"); y=y+35
local colorBtn = Instance.new("TextButton", na); colorBtn.Size = UDim2.new(0,300,0,30); colorBtn.Position = UDim2.new(0,15,0,y)
colorBtn.Text = "ESP Color: Red"; colorBtn.BackgroundColor3 = Color3.fromRGB(60,60,70)
colorBtn.MouseButton1Click:connect(function()
    local colors = {Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(0,0,255), Color3.fromRGB(255,255,0)}
    local idx = table.find(colors, Settings.NewESPColor) or 1
    Settings.NewESPColor = colors[(idx % 4) + 1]
    colorBtn.Text = "ESP Color: "..tostring(Settings.NewESPColor)
    updateNewESP(); Save()
end)

-- Bind Manager
local bm = panels.BindManager; y=10
for _, setting in ipairs(ToggleSettingsList) do
    addKeybindForSetting(bm, y, setting, setting)
    y = y + 35
end
local teleSaveBtn = Instance.new("TextButton", bm); teleSaveBtn.Size = UDim2.new(0,300,0,30); teleSaveBtn.Position = UDim2.new(0,15,0,y)
teleSaveBtn.Text = "Teleport Save key: "..(BindOverrides["TeleportSave"] or "none")
teleSaveBtn.MouseButton1Click:connect(function()
    teleSaveBtn.Text = "Press any key..."
    local inp = UserInput.InputBegan:wait()
    local key = inp.KeyCode.Name
    BindOverrides["TeleportSave"] = key
    teleSaveBtn.Text = "Teleport Save key: "..key
    Save()
    updateBindList()
end)
y=y+35
local teleLoadBtn = Instance.new("TextButton", bm); teleLoadBtn.Size = UDim2.new(0,300,0,30); teleLoadBtn.Position = UDim2.new(0,15,0,y)
teleLoadBtn.Text = "Teleport Load key: "..(BindOverrides["TeleportLoad"] or "none")
teleLoadBtn.MouseButton1Click:connect(function()
    teleLoadBtn.Text = "Press any key..."
    local inp = UserInput.InputBegan:wait()
    local key = inp.KeyCode.Name
    BindOverrides["TeleportLoad"] = key
    teleLoadBtn.Text = "Teleport Load key: "..key
    Save()
    updateBindList()
end)
y=y+35
local resetBinds = Instance.new("TextButton", bm); resetBinds.Size = UDim2.new(0,300,0,30); resetBinds.Position = UDim2.new(0,15,0,y)
resetBinds.Text = "Reset all binds to default"
resetBinds.BackgroundColor3 = Color3.fromRGB(80,40,40)
resetBinds.MouseButton1Click:connect(function()
    for k,v in pairs(DefaultBinds) do BindOverrides[k] = v end
    BindOverrides["TeleportSave"] = nil; BindOverrides["TeleportLoad"] = nil
    Save()
    updateBindList()
    for _, btn in pairs(bm:GetChildren()) do if btn:IsA("TextButton") and btn.Text:find("key:") then btn.Text = btn.Text:gsub("key: .+", "key: "..(BindOverrides[btn.Text:match("(.+) key")] or "none")) end end
end)

-- Extras
local ext = panels.Extras; y=10
addToggle(ext, y, "Hitbox Extender", "HitboxExtender"); y=y+35
addSlider(ext, y, "Hitbox Size", 1.5, 5.0, "HitboxSize", 0.5); y=y+55
addToggle(ext, y, "Spawn Kill", "SpawnKill"); y=y+35
addSlider(ext, y, "Spawn Kill Radius", 10, 100, "SpawnKillRadius", 5)

-- Settings
local set = panels.Settings; y=10
local infoSet = Instance.new("TextLabel", set); infoSet.Size = UDim2.new(0,600,0,600); infoSet.Position = UDim2.new(0,15,0,y)
infoSet.BackgroundTransparency = 1; infoSet.TextColor3 = Color3.new(1,1,1)
infoSet.Text = [[SquadRim DLC v17.1 (Optimized)
- Renamed: Feather → NewAim / NewESP
- Redesigned Bind List (gold border, dark blue)
- Redesigned Target Info (red border, colored health)
- Always visible HUD (draggable FPS)
- Full key rebinding
- OPTIMIZED: Cached player data, delayed ESP updates (reduces lag)
- New setting: ESP Update Rate (in NewFeatures) - increase if still laggy
Press INSERT to open/close menu
Press END to fully unload]]
infoSet.TextXAlignment = "Left"; infoSet.TextYAlignment = "Top"

-- Add ESPUpdateRate slider to Settings tab
y = y + 220
addSlider(set, y, "ESP Update Rate (sec)", 0.05, 0.5, "ESPUpdateRate", 0.01)

-- ========== UPDATE LOOPS ==========
RunService.RenderStepped:connect(function()
    updateTargetInfo()
    updateBindList()
end)

-- ========== OPEN/CLOSE & UNLOAD ==========
UserInput.InputBegan:connect(function(i, gpe)
    if gpe then return end
    if i.KeyCode == Enum.KeyCode.Insert then
        mainFrame.Visible = not mainFrame.Visible
    elseif i.KeyCode == Enum.KeyCode.End then
        menuGui:Destroy()
        targetInfoGui:Destroy()
        bindListGui:Destroy()
        fpsLabel.Parent:Destroy()
        if oldFOVCircle then oldFOVCircle:Destroy() end
        if newAimFOVCircle then newAimFOVCircle:Remove() end
        RunService:UnbindFromRenderStep("OldAimbotSystem")
        if flyConn then flyConn:Disconnect() end; if wallbangConn then wallbangConn:Disconnect() end
        stopFreecam()
        Camera.CameraType = Enum.CameraType.Custom
        local h = getHum(); if h then h.WalkSpeed = 16; h.PlatformStand = false end
        if getChar() then for _, p in pairs(getChar():GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end
        Lighting.Ambient = Color3.new(0,0,0)
        local cross = CoreGui:FindFirstChild("SquadCross"); if cross then cross:Destroy() end
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local h = plr.Character:FindFirstChild("NewESPHighlight")
                if h then h:Destroy() end
            end
        end
        print("SquadRim DLC v17.1 unloaded.")
        while true do wait() end
    end
end)

-- Optional: periodic garbage collection
task.spawn(function()
    while true do
        task.wait(300) -- every 5 minutes
        collectgarbage()
    end
end)

print("SquadRim DLC | FREE | active. Reduced lag.")
