--[[
    SQUADRIM DLC LOADER | ADVANCED MENU
    Password: SquadRim2024
]]

-- ========== АВТОРИЗАЦИЯ ==========
local function ShowAuth()
    local AuthGui = Instance.new("ScreenGui")
    AuthGui.Name = "SquadRim_Auth"
    AuthGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    AuthGui.Parent = game:GetService("CoreGui")
    AuthGui.ResetOnSpawn = false

    local Frame = Instance.new("Frame")
    Frame.Name = "Frame"
    Frame.BackgroundColor3 = Color3.fromRGB(17, 18, 20)
    Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Frame.BorderSizePixel = 0
    Frame.Position = UDim2.new(0.5, -200, 0.5, -120)
    Frame.Size = UDim2.new(0, 400, 0, 240)
    Frame.Parent = AuthGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 15)
    UICorner.Parent = Frame

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.BackgroundColor3 = Color3.fromRGB(25, 28, 35)
    Title.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Title.BorderSizePixel = 0
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.FontFace = Font.new("rbxasset://fonts/families/Nunito.json")
    Title.Text = "SQUADRIM DLC"
    Title.TextColor3 = Color3.fromRGB(220, 50, 50)
    Title.TextSize = 28
    Title.TextWrapped = true
    Title.Parent = Frame

    local SubTitle = Instance.new("TextLabel")
    SubTitle.Name = "SubTitle"
    SubTitle.BackgroundColor3 = Color3.fromRGB(17, 18, 20)
    SubTitle.BackgroundTransparency = 1
    SubTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
    SubTitle.BorderSizePixel = 0
    SubTitle.Position = UDim2.new(0, 0, 0, 55)
    SubTitle.Size = UDim2.new(1, 0, 0, 25)
    SubTitle.FontFace = Font.new("rbxasset://fonts/families/Nunito.json")
    SubTitle.Text = "Введите пароль для доступа"
    SubTitle.TextColor3 = Color3.fromRGB(180, 180, 200)
    SubTitle.TextSize = 14
    SubTitle.Parent = Frame

    local PasswordBox = Instance.new("TextBox")
    PasswordBox.Name = "PasswordBox"
    PasswordBox.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
    PasswordBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
    PasswordBox.BorderSizePixel = 0
    PasswordBox.Position = UDim2.new(0.1, 0, 0.38, 0)
    PasswordBox.Size = UDim2.new(0.8, 0, 0, 40)
    PasswordBox.FontFace = Font.new("rbxasset://fonts/families/Nunito.json")
    PasswordBox.PlaceholderText = "Пароль..."
    PasswordBox.Text = ""
    PasswordBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    PasswordBox.TextSize = 16
    PasswordBox.Parent = Frame
    
    local PasswordCorner = Instance.new("UICorner")
    PasswordCorner.CornerRadius = UDim.new(0, 8)
    PasswordCorner.Parent = PasswordBox

    local LoginBtn = Instance.new("TextButton")
    LoginBtn.Name = "LoginBtn"
    LoginBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    LoginBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    LoginBtn.BorderSizePixel = 0
    LoginBtn.Position = UDim2.new(0.1, 0, 0.62, 0)
    LoginBtn.Size = UDim2.new(0.35, 0, 0, 40)
    LoginBtn.FontFace = Font.new("rbxasset://fonts/families/Nunito.json")
    LoginBtn.Text = "ВОЙТИ"
    LoginBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoginBtn.TextSize = 16
    LoginBtn.Parent = Frame
    
    local LoginCorner = Instance.new("UICorner")
    LoginCorner.CornerRadius = UDim.new(0, 8)
    LoginCorner.Parent = LoginBtn

    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Name = "GetKeyBtn"
    GetKeyBtn.BackgroundColor3 = Color3.fromRGB(40, 42, 52)
    GetKeyBtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    GetKeyBtn.BorderSizePixel = 0
    GetKeyBtn.Position = UDim2.new(0.55, 0, 0.62, 0)
    GetKeyBtn.Size = UDim2.new(0.35, 0, 0, 40)
    GetKeyBtn.FontFace = Font.new("rbxasset://fonts/families/Nunito.json")
    GetKeyBtn.Text = "TG ССЫЛКА"
    GetKeyBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
    GetKeyBtn.TextSize = 14
    GetKeyBtn.Parent = Frame
    
    local GetKeyCorner = Instance.new("UICorner")
    GetKeyCorner.CornerRadius = UDim.new(0, 8)
    GetKeyCorner.Parent = GetKeyBtn

    local InfoText = Instance.new("TextLabel")
    InfoText.Name = "InfoText"
    InfoText.BackgroundColor3 = Color3.fromRGB(17, 18, 20)
    InfoText.BackgroundTransparency = 1
    InfoText.BorderColor3 = Color3.fromRGB(0, 0, 0)
    InfoText.BorderSizePixel = 0
    InfoText.Position = UDim2.new(0, 0, 0, 215)
    InfoText.Size = UDim2.new(1, 0, 0, 20)
    InfoText.FontFace = Font.new("rbxasset://fonts/families/Nunito.json")
    InfoText.Text = "Telegram: t.me/squadrim1"
    InfoText.TextColor3 = Color3.fromRGB(200, 50, 50)
    InfoText.TextSize = 12
    InfoText.Parent = Frame

    GetKeyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard("t.me/squadrim1")
        elseif toclipboard then
            toclipboard("t.me/squadrim1")
        end
        local notif = Instance.new("TextLabel")
        notif.Size = UDim2.new(0, 250, 0, 30)
        notif.Position = UDim2.new(0.5, -125, 0.7, 0)
        notif.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        notif.BackgroundTransparency = 0.5
        notif.Text = "✅ Ссылка скопирована!"
        notif.TextColor3 = Color3.fromRGB(0, 255, 0)
        notif.TextSize = 12
        notif.Parent = AuthGui
        task.delay(2, function() notif:Destroy() end)
    end)

    LoginBtn.MouseButton1Click:Connect(function()
        if PasswordBox.Text == "SquadRim2024" then
            AuthGui:Destroy()
            CreateMainMenu()
        else
            PasswordBox.Text = ""
            PasswordBox.PlaceholderText = "НЕВЕРНЫЙ ПАРОЛЬ!"
            PasswordBox.BackgroundColor3 = Color3.fromRGB(80, 40, 40)
            task.wait(1.5)
            PasswordBox.PlaceholderText = "Пароль..."
            PasswordBox.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
        end
    end)
end

-- ========== ГЛАВНОЕ МЕНЮ ==========
local function CreateMainMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SquadRim_Loader"
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 999999
    screenGui.IgnoreGuiInset = true

    local frame = Instance.new("Frame")
    frame.Name = "Frame"
    frame.BackgroundColor3 = Color3.fromRGB(17, 18, 20)
    frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    frame.BorderSizePixel = 0
    frame.Position = UDim2.fromScale(0.0883, 0.11)
    frame.Size = UDim2.fromOffset(878, 550)
    frame.Parent = screenGui

    -- Drag functionality
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local dragStart = input.Position
            local frameStart = frame.Position
            local connection
            connection = game:GetService("UserInputService").InputChanged:Connect(function(inputChanged)
                if inputChanged.UserInputType == Enum.UserInputType.MouseMovement then
                    local delta = inputChanged.Position - dragStart
                    frame.Position = UDim2.new(
                        frameStart.X.Scale,
                        frameStart.X.Offset + delta.X,
                        frameStart.Y.Scale,
                        frameStart.Y.Offset + delta.Y
                    )
                end
            end)
            local endConnection
            endConnection = game:GetService("UserInputService").InputEnded:Connect(function(inputEnded)
                if inputEnded.UserInputType == Enum.UserInputType.MouseButton1 then
                    connection:Disconnect()
                    endConnection:Disconnect()
                end
            end)
        end
    end)

    local uICorner = Instance.new("UICorner")
    uICorner.Name = "UICorner"
    uICorner.CornerRadius = UDim.new(0, 25)
    uICorner.Parent = frame

    -- Logo
    local logo = Instance.new("ImageLabel")
    logo.Name = "Logo"
    logo.BackgroundTransparency = 1
    logo.BorderSizePixel = 0
    logo.Image = "rbxassetid://92661965333918"
    logo.Position = UDim2.fromScale(0.755, 0.2)
    logo.AnchorPoint = Vector2.new(0.5, 0.5)
    logo.Size = UDim2.fromOffset(175, 175)
    logo.Parent = frame

    -- Game Buttons
    local games = {
        {name = "Arsenal", pos = 0.0415, script = "https://raw.githubusercontent.com/blackowl1231/Z3US/refs/heads/main/Games/Z3US%20Arsenal%20Beta.lua"},
        {name = "Planks", pos = 0.17786, script = "https://raw.githubusercontent.com/blackowl1231/Z3US/refs/heads/main/Games/Z3US%20Planks.lua"},
        {name = "Counterblox", pos = 0.31422, script = "https://raw.githubusercontent.com/blackowl1231/Z3US/refs/heads/main/Games/Z3US%20Counterblox.lua"},
        {name = "Gunfight Arena", pos = 0.45058, script = "https://raw.githubusercontent.com/blackowl1231/Z3US/refs/heads/main/Games/Z3US%20Gunfight%20Arena.lua"},
        {name = "OneTap", pos = 0.58694, script = "https://api.jnkie.com/api/v1/luascripts/public/2548ffbebdf21063cd4083f93a27ac276d44d1cb6503093d9c3290c3dfd954e3/download"},
        {name = "Universal", pos = 0.7233, script = "https://raw.githubusercontent.com/blackowl1231/Z3US/refs/heads/main/Games/Z3US%20Universal.lua"},
        {name = "Rivals", pos = 0.85966, script = "https://api.junkie-development.de/api/v1/luascripts/public/8be52e21a0145a401c446ca7ab2b5df9bd327ea80b0cf1d2fe99e442edd0f9c9/download"}
    }

    local gameFrames = {}
    local gameStrokes = {}
    local selectedOption = nil
    local selectedColor = Color3.fromRGB(140, 155, 208)
    local defaultColor = Color3.fromRGB(26, 29, 37)
    
    -- Rivals specific toggles
    local autoloadEnabled = true
    local silentloadEnabled = false
    local version = "New"

    for _, game in ipairs(games) do
        local gameFrame = Instance.new("Frame")
        gameFrame.Name = game.name
        gameFrame.BackgroundColor3 = Color3.fromRGB(17, 18, 20)
        gameFrame.BackgroundTransparency = 0.9
        gameFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        gameFrame.BorderSizePixel = 0
        gameFrame.Position = UDim2.fromScale(0.03, game.pos)
        gameFrame.Size = UDim2.fromOffset(330, 65)
        gameFrame.Parent = frame

        local gameStroke = Instance.new("UIStroke")
        gameStroke.Name = "UIStroke"
        gameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        gameStroke.Color = defaultColor
        gameStroke.Thickness = 1.9
        gameStroke.Parent = gameFrame

        local uICornerGame = Instance.new("UICorner")
        uICornerGame.Name = "UICorner"
        uICornerGame.CornerRadius = UDim.new(0, 25)
        uICornerGame.Parent = gameFrame

        local textLabel = Instance.new("TextLabel")
        textLabel.Name = "TextLabel"
        textLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.BackgroundTransparency = 1
        textLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.BorderSizePixel = 0
        textLabel.FontFace = Font.new("rbxasset://fonts/families/Nunito.json")
        textLabel.Position = UDim2.fromScale(0.2, 0.0462)
        textLabel.Size = UDim2.fromOffset(197, 58)
        textLabel.Text = game.name
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextSize = 62
        textLabel.TextWrapped = true
        textLabel.Parent = gameFrame

        gameFrames[game.name] = gameFrame
        gameStrokes[game.name] = gameStroke
    end

    -- Load Button
    local loadbtn = Instance.new("TextButton")
    loadbtn.Name = "Loadbtn"
    loadbtn.BackgroundColor3 = Color3.fromRGB(27, 29, 37)
    loadbtn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    loadbtn.BorderSizePixel = 0
    loadbtn.FontFace = Font.new("rbxasset://fonts/families/Nunito.json")
    loadbtn.Position = UDim2.fromScale(0.527, 0.656)
    loadbtn.Size = UDim2.fromOffset(405, 62)
    loadbtn.Text = "LOAD"
    loadbtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    loadbtn.TextScaled = true
    loadbtn.TextSize = 14
    loadbtn.TextWrapped = true
    loadbtn.Parent = frame

    local uICorner2 = Instance.new("UICorner")
    uICorner2.Name = "UICorner"
    uICorner2.CornerRadius = UDim.new(0, 25)
    uICorner2.Parent = loadbtn

    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    closeButton.BackgroundTransparency = 1
    closeButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    closeButton.BorderSizePixel = 0
    closeButton.FontFace = Font.new("rbxasset://fonts/families/FredokaOne.json")
    closeButton.Position = UDim2.fromScale(0.949, 0.0172)
    closeButton.Size = UDim2.fromOffset(44, 41)
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(58, 67, 98)
    closeButton.TextScaled = true
    closeButton.TextSize = 14
    closeButton.TextWrapped = true
    closeButton.Parent = frame

    -- Bottom Text
    local bottomText = Instance.new("TextLabel")
    bottomText.Name = "BottomText"
    bottomText.BackgroundColor3 = Color3.fromRGB(17, 18, 20)
    bottomText.BorderColor3 = Color3.fromRGB(0, 0, 0)
    bottomText.BorderSizePixel = 0
    bottomText.FontFace = Font.new("rbxasset://fonts/families/Nunito.json")
    bottomText.Position = UDim2.fromScale(0.628, 0.821)
    bottomText.Size = UDim2.fromOffset(200, 50)
    bottomText.Text = "SQUADRIM DLC"
    bottomText.TextColor3 = Color3.fromRGB(200, 50, 50)
    bottomText.TextSize = 34
    bottomText.Parent = frame

    -- Selected Script Text
    local selectedText = Instance.new("TextLabel")
    selectedText.Name = "SelectedText"
    selectedText.BackgroundColor3 = Color3.fromRGB(17, 18, 20)
    selectedText.BorderColor3 = Color3.fromRGB(0, 0, 0)
    selectedText.BorderSizePixel = 0
    selectedText.FontFace = Font.new("rbxasset://fonts/families/Nunito.json")
    selectedText.Position = UDim2.fromScale(0.645, 0.447)
    selectedText.Size = UDim2.fromOffset(200, 50)
    selectedText.Text = "No Script Selected"
    selectedText.TextColor3 = Color3.fromRGB(255, 255, 255)
    selectedText.TextSize = 34
    selectedText.Parent = frame

    -- Confirmation Panel
    local blackidk = Instance.new("Frame")
    blackidk.Name = "blackidk"
    blackidk.Parent = frame
    blackidk.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blackidk.BackgroundTransparency = 0.2
    blackidk.BorderSizePixel = 0
    blackidk.Size = UDim2.new(1, 0, 1, 0)
    blackidk.ZIndex = 8
    blackidk.Visible = false

    local confipanel = Instance.new("Frame")
    confipanel.Name = "confipanel"
    confipanel.Parent = frame
    confipanel.BackgroundColor3 = Color3.fromRGB(17, 18, 20)
    confipanel.BackgroundTransparency = 0
    confipanel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    confipanel.BorderSizePixel = 0
    confipanel.Position = UDim2.new(0.5, -200, 0.5, -75)
    confipanel.Size = UDim2.new(0, 400, 0, 150)
    confipanel.Visible = false
    confipanel.ZIndex = 10

    local confirmCorner = Instance.new("UICorner")
    confirmCorner.CornerRadius = UDim.new(0, 12)
    confirmCorner.Parent = confipanel

    local confirmStroke = Instance.new("UIStroke")
    confirmStroke.Color = Color3.fromRGB(26, 29, 37)
    confirmStroke.Thickness = 2
    confirmStroke.Parent = confipanel

    local confirmText = Instance.new("TextLabel")
    confirmText.Name = "ConfirmText"
    confirmText.Parent = confipanel
    confirmText.BackgroundTransparency = 1
    confirmText.Size = UDim2.new(1, -20, 0, 70)
    confirmText.Position = UDim2.new(0, 10, 0, 10)
    confirmText.FontFace = Font.new("rbxasset://fonts/families/Nunito.json")
    confirmText.Text = "ВНИМАНИЕ: Этот скрипт может быть не защищён!\nВы всё равно хотите его загрузить?"
    confirmText.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmText.TextSize = 18
    confirmText.TextWrapped = true
    confirmText.TextXAlignment = Enum.TextXAlignment.Center

    local confirmYes = Instance.new("TextButton")
    confirmYes.Name = "ConfirmYes"
    confirmYes.Parent = confipanel
    confirmYes.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    confirmYes.Size = UDim2.new(0, 100, 0, 35)
    confirmYes.Position = UDim2.new(0.5, -110, 1, -45)
    confirmYes.FontFace = Font.new("rbxasset://fonts/families/Nunito.json")
    confirmYes.Text = "Да"
    confirmYes.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmYes.TextSize = 18
    local yesCorner = Instance.new("UICorner")
    yesCorner.CornerRadius = UDim.new(0, 8)
    yesCorner.Parent = confirmYes

    local confirmNo = Instance.new("TextButton")
    confirmNo.Name = "ConfirmNo"
    confirmNo.Parent = confipanel
    confirmNo.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    confirmNo.Size = UDim2.new(0, 100, 0, 35)
    confirmNo.Position = UDim2.new(0.5, 10, 1, -45)
    confirmNo.FontFace = Font.new("rbxasset://fonts/families/Nunito.json")
    confirmNo.Text = "Нет"
    confirmNo.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmNo.TextSize = 18
    local noCorner = Instance.new("UICorner")
    noCorner.CornerRadius = UDim.new(0, 8)
    noCorner.Parent = confirmNo

    -- Rivals Toggle Container
    local rivalsToggleContainer = Instance.new("Frame")
    rivalsToggleContainer.Name = "RivalsToggleContainer"
    rivalsToggleContainer.Parent = frame
    rivalsToggleContainer.BackgroundColor3 = Color3.fromRGB(17, 18, 20)
    rivalsToggleContainer.BackgroundTransparency = 0.9
    rivalsToggleContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    rivalsToggleContainer.BorderSizePixel = 0
    rivalsToggleContainer.Position = UDim2.new(0.60, 0, 0.53, 0)
    rivalsToggleContainer.Size = UDim2.new(0, 280, 0, 65)
    rivalsToggleContainer.Visible = false

    local containerStroke = Instance.new("UIStroke")
    containerStroke.Parent = rivalsToggleContainer
    containerStroke.Color = Color3.fromRGB(26, 29, 37)
    containerStroke.Thickness = 2
    containerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local uICornerContainer = Instance.new("UICorner")
    uICornerContainer.CornerRadius = UDim.new(0, 25)
    uICornerContainer.Parent = rivalsToggleContainer

    -- Autoload Toggle
    local autoloadToggle = Instance.new("Frame")
    autoloadToggle.Name = "AutoloadToggle"
    autoloadToggle.Parent = rivalsToggleContainer
    autoloadToggle.BackgroundColor3 = Color3.fromRGB(17, 18, 20)
    autoloadToggle.BackgroundTransparency = 0.9
    autoloadToggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
    autoloadToggle.BorderSizePixel = 0
    autoloadToggle.Position = UDim2.new(0.05, 0, 0.15, 0)
    autoloadToggle.Size = UDim2.new(0, 120, 0, 45)

    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Parent = autoloadToggle
    toggleStroke.Color = Color3.fromRGB(26, 29, 37)
    toggleStroke.Thickness = 2
    toggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local uICornerToggle = Instance.new("UICorner")
    uICornerToggle.CornerRadius = UDim.new(0, 15)
    uICornerToggle.Parent = autoloadToggle

    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Name = "ToggleLabel"
    toggleLabel.Parent = autoloadToggle
    toggleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    toggleLabel.BorderSizePixel = 0
    toggleLabel.Position = UDim2.new(0.05, 0, 0, 0)
    toggleLabel.Size = UDim2.new(0, 70, 0, 45)
    toggleLabel.FontFace = Font.new("rbxasset://fonts/families/Nunito.json")
    toggleLabel.Text = "Autoload:"
    toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleLabel.TextSize = 16
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "ToggleButton"
    toggleButton.Parent = autoloadToggle
    toggleButton.BackgroundColor3 = Color3.fromRGB(140, 155, 208)
    toggleButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    toggleButton.BorderSizePixel = 0
    toggleButton.Position = UDim2.new(0.60, 0, 0.15, 0)
    toggleButton.Size = UDim2.new(0, 40, 0, 30)
    toggleButton.FontFace = Font.new("rbxasset://fonts/families/Nunito.json")
    toggleButton.Text = "ON"
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.TextSize = 14
    toggleButton.TextWrapped = true

    local uICornerToggleBtn = Instance.new("UICorner")
    uICornerToggleBtn.CornerRadius = UDim.new(0, 10)
    uICornerToggleBtn.Parent = toggleButton

    -- Silentload Toggle
    local silentloadToggle = Instance.new("Frame")
    silentloadToggle.Name = "SilentloadToggle"
    silentloadToggle.Parent = rivalsToggleContainer
    silentloadToggle.BackgroundColor3 = Color3.fromRGB(17, 18, 20)
    silentloadToggle.BackgroundTransparency = 0.9
    silentloadToggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
    silentloadToggle.BorderSizePixel = 0
    silentloadToggle.Position = UDim2.new(0.55, 0, 0.15, 0)
    silentloadToggle.Size = UDim2.new(0, 120, 0, 45)

    local silentloadStroke = Instance.new("UIStroke")
    silentloadStroke.Parent = silentloadToggle
    silentloadStroke.Color = Color3.fromRGB(26, 29, 37)
    silentloadStroke.Thickness = 2
    silentloadStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local uICornerSilentload = Instance.new("UICorner")
    uICornerSilentload.CornerRadius = UDim.new(0, 15)
    uICornerSilentload.Parent = silentloadToggle

    local silentloadLabel = Instance.new("TextLabel")
    silentloadLabel.Name = "SilentloadLabel"
    silentloadLabel.Parent = silentloadToggle
    silentloadLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    silentloadLabel.BackgroundTransparency = 1
    silentloadLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    silentloadLabel.BorderSizePixel = 0
    silentloadLabel.Position = UDim2.new(0.05, 0, 0, 0)
    silentloadLabel.Size = UDim2.new(0, 70, 0, 45)
    silentloadLabel.FontFace = Font.new("rbxasset://fonts/families/Nunito.json")
    silentloadLabel.Text = "Silentload:"
    silentloadLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    silentloadLabel.TextSize = 16
    silentloadLabel.TextXAlignment = Enum.TextXAlignment.Left

    local silentloadButton = Instance.new("TextButton")
    silentloadButton.Name = "SilentloadButton"
    silentloadButton.Parent = silentloadToggle
    silentloadButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    silentloadButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    silentloadButton.BorderSizePixel = 0
    silentloadButton.Position = UDim2.new(0.60, 0, 0.15, 0)
    silentloadButton.Size = UDim2.new(0, 40, 0, 30)
    silentloadButton.FontFace = Font.new("rbxasset://fonts/families/Nunito.json")
    silentloadButton.Text = "OFF"
    silentloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    silentloadButton.TextSize = 14
    silentloadButton.TextWrapped = true

    local uICornerSilentloadBtn = Instance.new("UICorner")
    uICornerSilentloadBtn.CornerRadius = UDim.new(0, 10)
    uICornerSilentloadBtn.Parent = silentloadButton

    -- Version Toggle for Counterblox
    local VersionToggle = Instance.new("Frame")
    VersionToggle.Name = "VersionToggle"
    VersionToggle.Parent = frame
    VersionToggle.BackgroundColor3 = Color3.fromRGB(17, 18, 20)
    VersionToggle.BackgroundTransparency = 0.9
    VersionToggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
    VersionToggle.BorderSizePixel = 0
    VersionToggle.Position = UDim2.new(0.60, 0, 0.53, 0)
    VersionToggle.Size = UDim2.new(0, 280, 0, 50)
    VersionToggle.Visible = false

    local versiontoggleStroke = Instance.new("UIStroke")
    versiontoggleStroke.Parent = VersionToggle
    versiontoggleStroke.Color = Color3.fromRGB(26, 29, 37)
    versiontoggleStroke.Thickness = 2
    versiontoggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local uICornerversionToggle = Instance.new("UICorner")
    uICornerversionToggle.CornerRadius = UDim.new(0, 25)
    uICornerversionToggle.Parent = VersionToggle

    local versionLabel = Instance.new("TextLabel")
    versionLabel.Name = "versionLabel"
    versionLabel.Parent = VersionToggle
    versionLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    versionLabel.BackgroundTransparency = 1
    versionLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    versionLabel.BorderSizePixel = 0
    versionLabel.Position = UDim2.new(0.05, 0, 0, 0)
    versionLabel.Size = UDim2.new(0, 160, 0, 50)
    versionLabel.FontFace = Font.new("rbxasset://fonts/families/Nunito.json")
    versionLabel.Text = "Version:"
    versionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    versionLabel.TextSize = 20
    versionLabel.TextXAlignment = Enum.TextXAlignment.Left

    local versionButton = Instance.new("TextButton")
    versionButton.Name = "versionButton"
    versionButton.Parent = VersionToggle
    versionButton.BackgroundColor3 = Color3.fromRGB(140, 155, 208)
    versionButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    versionButton.BorderSizePixel = 0
    versionButton.Position = UDim2.new(0.65, 0, 0.15, 0)
    versionButton.Size = UDim2.new(0, 80, 0, 35)
    versionButton.FontFace = Font.new("rbxasset://fonts/families/Nunito.json")
    versionButton.Text = "New"
    versionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    versionButton.TextSize = 18
    versionButton.TextWrapped = true

    local uICornerversionButton = Instance.new("UICorner")
    uICornerversionButton.CornerRadius = UDim.new(0, 15)
    uICornerversionButton.Parent = versionButton

    -- Functions
    local function updateToggleAppearance()
        if autoloadEnabled then
            toggleButton.BackgroundColor3 = Color3.fromRGB(140, 155, 208)
            toggleButton.Text = "ON"
        else
            toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            toggleButton.Text = "OFF"
        end
        
        if silentloadEnabled then
            silentloadButton.BackgroundColor3 = Color3.fromRGB(140, 155, 208)
            silentloadButton.Text = "ON"
        else
            silentloadButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            silentloadButton.Text = "OFF"
        end

        if version == "New" then
            versionButton.BackgroundColor3 = Color3.fromRGB(140, 155, 208)
            versionButton.Text = "New"
        else
            versionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            versionButton.Text = "Old"
        end
    end

    local function selectScript(scriptFrame, scriptName)
        for name, stroke in pairs(gameStrokes) do
            stroke.Color = defaultColor
        end
        rivalsToggleContainer.Visible = false
        VersionToggle.Visible = false

        if scriptFrame then
            scriptFrame:FindFirstChildOfClass("UIStroke").Color = selectedColor
            selectedOption = scriptName
            selectedText.Text = scriptName

            if scriptName == "Rivals" then
                rivalsToggleContainer.Visible = true
                updateToggleAppearance()
            end

            if scriptName == "Counterblox" then
                VersionToggle.Visible = true
                updateToggleAppearance()
            end
        else 
            selectedOption = nil
            selectedText.Text = "No Script Selected"
        end
    end

    -- Connect game buttons
    for name, gameFrame in pairs(gameFrames) do
        gameFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                selectScript(gameFrame, name)
            end
        end)
    end

    -- Rivals confirmation
    gameFrames["Rivals"].InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            confipanel.Visible = true
            blackidk.Visible = true
        end
    end)

    confirmYes.MouseButton1Click:Connect(function()
        confipanel.Visible = false
        blackidk.Visible = false
        selectScript(gameFrames["Rivals"], "Rivals")
    end)

    confirmNo.MouseButton1Click:Connect(function()
        confipanel.Visible = false
        blackidk.Visible = false
    end)

    -- Toggle buttons
    toggleButton.MouseButton1Click:Connect(function()
        autoloadEnabled = not autoloadEnabled
        updateToggleAppearance()
    end)

    silentloadButton.MouseButton1Click:Connect(function()
        silentloadEnabled = not silentloadEnabled
        updateToggleAppearance()
    end)

    versionButton.MouseButton1Click:Connect(function()
        version = version == "Old" and "New" or "Old"
        updateToggleAppearance()
    end)

    -- Load button
    loadbtn.MouseButton1Click:Connect(function()
        if selectedOption then
            if selectedOption == "Arsenal" then
                loadstring(game:HttpGet("https://raw.githubusercontent.com/blackowl1231/Z3US/refs/heads/main/Games/Z3US%20Arsenal%20Beta.lua"))()
            elseif selectedOption == "Planks" then
                loadstring(game:HttpGet("https://raw.githubusercontent.com/blackowl1231/Z3US/refs/heads/main/Games/Z3US%20Planks.lua"))()
            elseif selectedOption == "OneTap" then
                getgenv().SCRIPT_KEY = ""
                loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/2548ffbebdf21063cd4083f93a27ac276d44d1cb6503093d9c3290c3dfd954e3/download"))()
            elseif selectedOption == "Rivals" then
                repeat task.wait() until game:IsLoaded()
                repeat task.wait() until game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer.Character
                repeat task.wait() until not game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("LoadingScreen")
                getgenv().autoload = autoloadEnabled
                getgenv().silentload = silentloadEnabled
                getgenv().SCRIPT_KEY = ""
                loadstring(game:HttpGet("https://api.junkie-development.de/api/v1/luascripts/public/8be52e21a0145a401c446ca7ab2b5df9bd327ea80b0cf1d2fe99e442edd0f9c9/download"))()
            elseif selectedOption == "Counterblox" then
                if version == "New" then
                    getgenv().SCRIPT_KEY = ""
                    loadstring(game:HttpGet("https://api.junkie-development.de/api/v1/luascripts/public/2438cfd42af811d55492e854318eeda24a73aa5d0b11a403ec1f7542abd8f2f0/download"))()
                else
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/blackowl1231/Z3US/refs/heads/main/Games/Z3US%20Counterblox.lua"))()
                end
            elseif selectedOption == "Gunfight Arena" then
                loadstring(game:HttpGet("https://raw.githubusercontent.com/blackowl1231/Z3US/refs/heads/main/Games/Z3US%20Gunfight%20Arena.lua"))()
            elseif selectedOption == "Universal" then
                loadstring(game:HttpGet("https://raw.githubusercontent.com/blackowl1231/Z3US/refs/heads/main/Games/Z3US%20Universal.lua"))()
            end
        else
            selectedText.Text = "Выберите скрипт!"
            task.wait(2)
            selectedText.Text = "No Script Selected"
        end
    end)

    -- Close button
    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)

    updateToggleAppearance()
end

-- ========== ЗАПУСК ==========
ShowAuth()
