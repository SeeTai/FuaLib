local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui", 10)

local iOSLikeUI = {}
iOSLikeUI.__index = iOSLikeUI

-- Настройки стиля iOS 16 Dark Mode
local STYLE = {
    WindowSize = UDim2.new(0, 420, 0, 520),
    Corner = 18,
    Padding = 12,
    TitleSize = 20,
    Font = Enum.Font.Gotham, -- Ближайший к San Francisco
    BgColor = Color3.fromRGB(28, 37, 38), -- Чёрный фон iOS 16
    ElementBg = Color3.fromRGB(44, 47, 51), -- Тёмно-серый для кнопок/тогглов
    Accent = Color3.fromRGB(0, 122, 255), -- Синий акцент
    TextColor = Color3.fromRGB(255, 255, 255), -- Белый текст
    SecondaryText = Color3.fromRGB(142, 142, 147) -- Серый для второстепенного текста
}

-- Вспомог: rounded corner
local function addCorner(inst, radius)
    if not inst then return end
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = inst
end

-- Вспомог: create label
local function createLabel(text, size, font, textSize)
    if not text then return end
    local lbl = Instance.new("TextLabel")
    lbl.Size = size or UDim2.new(1, 0, 0, 28)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = font or STYLE.Font
    lbl.TextSize = textSize or 14
    lbl.TextColor3 = STYLE.TextColor
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ClipsDescendants = true
    return lbl
end

-- Создать окно
function iOSLikeUI:CreateWindow(title)
    if not PlayerGui then
        error("PlayerGui not initialized")
        return
    end

    local selfObj = setmetatable({}, iOSLikeUI)
    local screen = Instance.new("ScreenGui")
    screen.Name = "iOSStyleUI"
    screen.ResetOnSpawn = false
    screen.Parent = PlayerGui

    local main = Instance.new("Frame")
    main.Name = "MainWindow"
    main.Size = STYLE.WindowSize
    main.Position = UDim2.new(0.5, -STYLE.WindowSize.X.Offset/2, 0.08, 0)
    main.AnchorPoint = Vector2.new(0.5, 0)
    main.BackgroundColor3 = STYLE.BgColor
    main.BackgroundTransparency = 0.1
    main.Parent = screen
    addCorner(main, STYLE.Corner)

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 56)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = main

    local titleLabel = createLabel(title or "Menu", UDim2.new(1, -24, 1, -12), STYLE.Font, STYLE.TitleSize)
    titleLabel.Position = UDim2.new(0, 12, 0, 12)
    titleLabel.Parent = titleBar

    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0, 13)
    closeButton.BackgroundColor3 = STYLE.ElementBg
    closeButton.Text = "×"
    closeButton.TextColor3 = STYLE.TextColor
    closeButton.TextSize = 20
    closeButton.Font = STYLE.Font
    closeButton.Parent = titleBar
    addCorner(closeButton, 15)

    -- Content holder (Scrolling)
    local scroller = Instance.new("ScrollingFrame")
    scroller.Name = "Content"
    scroller.Size = UDim2.new(1, -24, 1, -76)
    scroller.Position = UDim2.new(0, 12, 0, 64)
    scroller.BackgroundTransparency = 1
    scroller.ScrollBarThickness = 6
    scroller.ScrollBarImageColor3 = STYLE.SecondaryText
    scroller.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroller.Parent = main
    scroller.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
    scroller.ClipsDescendants = true

    local uiList = Instance.new("UIListLayout")
    uiList.Parent = scroller
    uiList.SortOrder = Enum.SortOrder.LayoutOrder
    uiList.Padding = UDim.new(0, STYLE.Padding)

    selfObj.screen = screen
    selfObj.main = main
    selfObj.content = scroller
    selfObj.uiList = uiList

    -- Update canvas size
    local function updateCanvas()
        local total = uiList.AbsoluteContentSize.Y + STYLE.Padding
        scroller.CanvasSize = UDim2.new(0, 0, 0, total)
    end
    uiList.Changed:Connect(updateCanvas)
    scroller:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(updateCanvas)

    -- Open animation
    main.Position = UDim2.new(0.5, -STYLE.WindowSize.X.Offset/2, 0.05, 0)
    local tweenInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(main, tweenInfo, {Position = UDim2.new(0.5, -STYLE.WindowSize.X.Offset/2, 0.08, 0)}):Play()

    -- Close animation
    local closeConnection
    closeConnection = closeButton.MouseButton1Click:Connect(function()
        local tween = TweenService:Create(main, tweenInfo, {Position = UDim2.new(0.5, -STYLE.WindowSize.X.Offset/2, 0.05, 0)})
        tween:Play()
        tween.Completed:Connect(function()
            main.Visible = false
        end)
    end)

    -- Toggle visibility with Insert
    local toggleConnection
    toggleConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.Insert then
            if main.Visible then
                local tween = TweenService:Create(main, tweenInfo, {Position = UDim2.new(0.5, -STYLE.WindowSize.X.Offset/2, 0.05, 0)})
                tween:Play()
                tween.Completed:Connect(function()
                    main.Visible = false
                end)
            else
                main.Visible = true
                TweenService:Create(main, tweenInfo, {Position = UDim2.new(0.5, -STYLE.WindowSize.X.Offset/2, 0.08, 0)}):Play()
            end
        end
    end)

    screen.Destroying:Connect(function()
        if closeConnection then closeConnection:Disconnect() end
        if toggleConnection then toggleConnection:Disconnect() end
    end)

    return selfObj
end

-- Добавить секцию
function iOSLikeUI:AddSection(title)
    local secFrame = Instance.new("Frame")
    secFrame.Size = UDim2.new(1, 0, 0, 44)
    secFrame.BackgroundTransparency = 1
    secFrame.LayoutOrder = #self.content:GetChildren()
    secFrame.Parent = self.content

    local header = createLabel(title, UDim2.new(1, 0, 0, 24), STYLE.Font, 15)
    header.TextColor3 = STYLE.SecondaryText
    header.Parent = secFrame

    local container = Instance.new("Frame")
    container.Name = "SectionBody"
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.Position = UDim2.new(0, 0, 0, 28)
    container.Parent = secFrame

    local vlist = Instance.new("UIListLayout")
    vlist.Parent = container
    vlist.SortOrder = Enum.SortOrder.LayoutOrder
    vlist.Padding = UDim.new(0, 8)

    -- Update section height
    local function updateSectionHeight()
        secFrame.Size = UDim2.new(1, 0, 0, vlist.AbsoluteContentSize.Y + 28 + STYLE.Padding)
    end
    vlist.Changed:Connect(updateSectionHeight)

    function secFrame:AddButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 38)
        btn.BackgroundColor3 = STYLE.ElementBg
        btn.BackgroundTransparency = 0.1
        addCorner(btn, 12)
        btn.Font = STYLE.Font
        btn.TextSize = 14
        btn.Text = text or "Button"
        btn.TextColor3 = STYLE.TextColor
        btn.Parent = container

        btn.MouseButton1Click:Connect(function()
            local ti = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local t = TweenService:Create(btn, ti, {BackgroundTransparency = 0.3})
            t:Play()
            t.Completed:Wait()
            TweenService:Create(btn, ti, {BackgroundTransparency = 0.1}):Play()
            if callback then pcall(callback) end
        end)
        return btn
    end

    function secFrame:AddToggle(text, default, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 40)
        row.BackgroundTransparency = 1
        row.Parent = container

        local lbl = createLabel(text, UDim2.new(0.7, 0, 1, 0))
        lbl.Position = UDim2.new(0, 0, 0, 6)
        lbl.Parent = row

        local togg = Instance.new("TextButton")
        togg.Size = UDim2.new(0, 50, 0, 28)
        togg.Position = UDim2.new(1, -50, 0, 6)
        togg.BackgroundColor3 = STYLE.ElementBg
        addCorner(togg, 14)
        togg.Parent = row
        togg.Text = ""
        togg.AutoButtonColor = false

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(default and 0.5 or 0.24, -6, 1, -6)
        fill.Position = UDim2.new(default and 0.02 or 0.5, 3, 0, 3)
        fill.BackgroundColor3 = default and STYLE.Accent or STYLE.SecondaryText
        addCorner(fill, 12)
        fill.Parent = togg

        local state = default or false

        local function setState(s)
            state = s
            local targetSize = s and UDim2.new(0.5, -6, 1, -6) or UDim2.new(0.24, -6, 1, -6)
            local targetPos = s and UDim2.new(0.02, 3, 0, 3) or UDim2.new(0.5, 3, 0, 3)
            TweenService:Create(fill, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {Size = targetSize, Position = targetPos, BackgroundColor3 = s and STYLE.Accent or STYLE.SecondaryText}):Play()
            if callback then pcall(callback, state) end
        end

        togg.MouseButton1Click:Connect(function()
            setState(not state)
        end)
        togg.TouchTap:Connect(function()
            setState(not state)
        end)

        return {Frame = row, Set = setState, Get = function() return state end}
    end

    function secFrame:AddSlider(text, min, max, default, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 62)
        row.BackgroundTransparency = 1
        row.Parent = container

        local lbl = createLabel(text, UDim2.new(0.7, 0, 0, 24))
        lbl.Parent = row

        local valueLbl = createLabel(tostring(default or min or 0), UDim2.new(0, 60, 0, 24))
        valueLbl.Position = UDim2.new(1, -60, 0, 0)
        valueLbl.TextColor3 = STYLE.SecondaryText
        valueLbl.TextXAlignment = Enum.TextXAlignment.Right
        valueLbl.Parent = row

        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, 0, 0, 8)
        sliderBg.Position = UDim2.new(0, 0, 0, 28)
        sliderBg.BackgroundColor3 = STYLE.ElementBg
        addCorner(sliderBg, 4)
        sliderBg.Parent = row

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.BackgroundColor3 = STYLE.Accent
        addCorner(fill, 4)
        fill.Parent = sliderBg

        local knob = Instance.new("ImageButton")
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new(0, 9, 0.5, 0)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        addCorner(knob, 9)
        knob.Image = ""
        knob.AutoButtonColor = false
        knob.Parent = sliderBg

        local value = default or min or 0
        min = min or 0
        max = max or 100

        local function updateUIFromValue(v)
            local frac = max > min and math.clamp((v - min) / (max - min), 0, 1) or 0
            fill.Size = UDim2.new(frac, 0, 1, 0)
            knob.Position = UDim2.new(frac, 0, 0.5, 0)
            valueLbl.Text = tostring(math.floor(v))
        end

        updateUIFromValue(value)

        local dragging = false
        local beganConnection = knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
            end
        end)
        local endedConnection = knob.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        local changedConnection = UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local abs = sliderBg.AbsolutePosition.X
                local width = sliderBg.AbsoluteSize.X
                local mouseX = input.Position.X
                local rel = math.clamp((mouseX - abs) / width, 0, 1)
                value = math.floor(min + (max - min) * rel)
                updateUIFromValue(value)
                if callback then pcall(callback, value) end
            end
        end)

        row.Destroying:Connect(function()
            if beganConnection then beganConnection:Disconnect() end
            if endedConnection then endedConnection:Disconnect() end
            if changedConnection then changedConnection:Disconnect() end
        end)

        return {Frame = row, Get = function() return value end, Set = function(v) value = math.clamp(math.floor(v), min, max); updateUIFromValue(value) end}
    end

    return secFrame
end

-- Убрать/скрыть окно
function iOSLikeUI:Destroy()
    if self.screen then
        local tween = TweenService:Create(self.main, TweenInfo.new(0.28, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, -STYLE.WindowSize.X.Offset/2, 0.05, 0)})
        tween:Play()
        tween.Completed:Connect(function()
            self.screen:Destroy()
        end)
    end
end

return iOSLikeUI
