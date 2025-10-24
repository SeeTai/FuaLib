local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local FuaiLib = {}
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local windows = {}

local function createFrame(parent, size, position, color)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = position
    frame.BackgroundColor3 = color or Color3.fromRGB(248, 249, 250)
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(229, 231, 235)
    stroke.Thickness = 1
    stroke.Parent = frame

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(248, 249, 250))
    })
    gradient.Rotation = 90
    gradient.Parent = frame

    return frame
end

local function createLabel(parent, text, size, position, font, textSize)
    local label = Instance.new("TextLabel")
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(30, 30, 30)
    label.TextSize = textSize or 18
    label.Font = font or Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local function createToggle(parent, text, callback)
    local container = createFrame(parent, UDim2.new(1, -20, 0, 50), UDim2.new(0, 10, 0, 0))
    container.BackgroundTransparency = 0.2

    createLabel(container, text, UDim2.new(0.7, 0, 1, 0), UDim2.new(0, 10, 0, 0), Enum.Font.Gotham, 16)

    local toggle = createFrame(container, UDim2.new(0, 40, 0, 24), UDim2.new(1, -50, 0.5, -12), Color3.fromRGB(209, 213, 219))
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 12)
    toggleCorner.Parent = toggle

    local knob = createFrame(toggle, UDim2.new(0, 20, 0, 20), UDim2.new(0, 2, 0.5, -10), Color3.fromRGB(255, 255, 255))
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(0, 10)
    knobCorner.Parent = knob

    local isOn = false
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isOn = not isOn
            local targetColor = isOn and Color3.fromRGB(0, 122, 255) or Color3.fromRGB(209, 213, 219)
            local targetPos = isOn and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
            TweenService:Create(toggle, tweenInfo, {BackgroundColor3 = targetColor}):Play()
            TweenService:Create(knob, tweenInfo, {Position = targetPos}):Play()
            callback(isOn)
        end
    end)

    return toggle
end

local function createSlider(parent, text, min, max, default, callback)
    local container = createFrame(parent, UDim2.new(1, -20, 0, 60), UDim2.new(0, 10, 0, 0))
    container.BackgroundTransparency = 0.2

    createLabel(container, text, UDim2.new(1, 0, 0.4, 0), UDim2.new(0, 10, 0, 5), Enum.Font.Gotham, 16)

    local valueLabel = createLabel(container, tostring(default), UDim2.new(1, 0, 0.4, 0), UDim2.new(1, -60, 0, 5), Enum.Font.GothamBold, 14)
    valueLabel.TextColor3 = Color3.fromRGB(0, 122, 255)

    local track = createFrame(container, UDim2.new(1, -20, 0, 4), UDim2.new(0, 10, 0.7, 0), Color3.fromRGB(209, 213, 219))
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 2)
    trackCorner.Parent = track

    local fill = createFrame(track, UDim2.new((default - min) / (max - min), 0, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(0, 122, 255))
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 2)
    fillCorner.Parent = fill

    local thumb = createFrame(track, UDim2.new(0, 20, 0, 20), UDim2.new((default - min) / (max - min), -10, 0.5, -10), Color3.fromRGB(255, 255, 255))
    local thumbCorner = Instance.new("UICorner")
    thumbCorner.CornerRadius = UDim.new(0, 10)
    thumbCorner.Parent = thumb

    local dragging = false
    local currentValue = default

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            currentValue = math.floor(min + (max - min) * relativeX)
            TweenService:Create(fill, TweenInfo.new(0.1), {Size = UDim2.new(relativeX, 0, 1, 0)}):Play()
            TweenService:Create(thumb, TweenInfo.new(0.1), {Position = UDim2.new(relativeX, -10, 0.5, -10)}):Play()
            valueLabel.Text = tostring(currentValue)
            callback(currentValue)
        end
    end)

    return container
end

local function createButton(parent, text, callback)
    local button = createFrame(parent, UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 0, 0), Color3.fromRGB(0, 122, 255))
    button.BackgroundTransparency = 0.1

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 12)
    buttonCorner.Parent = button

    local buttonLabel = createLabel(button, text, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), Enum.Font.GothamBold, 18)
    buttonLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0, 100, 200)}):Play()
            wait(0.1)
            TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0, 122, 255)}):Play()
            callback()
        end
    end)

    return button
end

function FuaiLib:CreateWindow(options)
    options = options or {}
    local title = options.Title or "FuaiLib"

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FuaiLib"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false

    local mainWindow = createFrame(screenGui, UDim2.new(0, 400, 0, 500), UDim2.new(0.5, -200, 0.5, -250), Color3.fromRGB(255, 255, 255))
    mainWindow.BackgroundTransparency = 0.05

    local titleLabel = createLabel(mainWindow, title, UDim2.new(1, 0, 0, 60), UDim2.new(0, 0, 0, 0), Enum.Font.GothamBold, 24)
    titleLabel.BackgroundTransparency = 1

    local closeButton = createFrame(mainWindow, UDim2.new(0, 30, 0, 30), UDim2.new(1, -40, 0, 15), Color3.fromRGB(239, 68, 68))
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 15)
    closeCorner.Parent = closeButton

    local closeLabel = createLabel(closeButton, "×", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), Enum.Font.GothamBold, 24)
    closeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

    closeButton.InputBegan:Connect(function()
        TweenService:Create(mainWindow, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        wait(0.3)
        screenGui:Destroy()
    end)

    local contentFrame = createFrame(mainWindow, UDim2.new(1, -20, 1, -80), UDim2.new(0, 10, 0, 70))
    contentFrame.BackgroundTransparency = 1

    local sections = {}

    local function addSection(name)
        local section = createFrame(contentFrame, UDim2.new(1, 0, 0, 0), UDim2.new(0, 0, #sections * 10, 0))
        local sectionHeader = createLabel(section, name, UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), Enum.Font.GothamSemibold, 20)
        sectionHeader.BackgroundTransparency = 1

        local sectionContent = createFrame(section, UDim2.new(1, 0, 1, -40), UDim2.new(0, 0, 0, 40))
        sectionContent.BackgroundTransparency = 1

        section.Size = UDim2.new(1, 0, 0, sectionContent.AbsoluteSize.Y + 40)

        section:AddToggle = function(text, callback)
            createToggle(sectionContent, text, callback)
        end

        section:AddSlider = function(text, min, max, default, callback)
            createSlider(sectionContent, text, min or 0, max or 100, default or 50, callback)
        end

        section:AddButton = function(text, callback)
            createButton(sectionContent, text, callback)
        end

        table.insert(sections, section)
        return section
    end

    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.Insert then
            mainWindow.Visible = not mainWindow.Visible
        end
    end)

    mainWindow.Visible = false

    windows[title] = {addSection = addSection}
    return windows[title]
end

return FuaiLib
