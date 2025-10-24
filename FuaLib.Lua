-- ModuleScript: iOSLikeUI
-- Простая iOS-подобная GUI-библиотека: окна, секции, кнопки, тоги, слайдер
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local iOSLikeUI = {}
iOSLikeUI.__index = iOSLikeUI

-- Настройки стиля (можно расширять)
local STYLE = {
    WindowSize = UDim2.new(0, 420, 0, 520),
    Corner = 18,
    Padding = 12,
    TitleSize = 20,
    Font = Enum.Font.Gotham,
    BgColor = Color3.fromRGB(245,245,247),
    Accent = Color3.fromRGB(0,122,255),
    TextColor = Color3.fromRGB(30,30,30)
}

-- Вспомог: rounded corner
local function addCorner(inst, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = inst
end

-- Вспомог: create label
local function createLabel(text, size)
    local lbl = Instance.new("TextLabel")
    lbl.Size = size or UDim2.new(1, 0, 0, 28)
    lbl.BackgroundTransparency = 1
    lbl.Text = text or ""
    lbl.Font = STYLE.Font
    lbl.TextSize = 14
    lbl.TextColor3 = STYLE.TextColor
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ClipsDescendants = true
    return lbl
end

-- Создать окно
function iOSLikeUI:CreateWindow(title)
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
    main.Parent = screen
    addCorner(main, STYLE.Corner)

    -- Title bar
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 56)
    titleBar.BackgroundTransparency = 1
    titleBar.Parent = main

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Parent = titleBar
    titleLabel.Size = UDim2.new(1, -24, 1, -12)
    titleLabel.Position = UDim2.new(0, 12, 0, 12)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "Menu"
    titleLabel.Font = STYLE.Font
    titleLabel.TextSize = STYLE.TitleSize
    titleLabel.TextColor3 = STYLE.TextColor
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Content holder (Scrolling)
    local scroller = Instance.new("ScrollingFrame")
    scroller.Name = "Content"
    scroller.Size = UDim2.new(1, -24, 1, -76)
    scroller.Position = UDim2.new(0, 12, 0, 64)
    scroller.BackgroundTransparency = 1
    scroller.ScrollBarThickness = 6
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

    -- helper to update canvas size
    local function updateCanvas()
        local total = uiList.AbsoluteContentSize.Y
        scroller.CanvasSize = UDim2.new(0, 0, 0, total + STYLE.Padding)
    end
    uiList.Changed:Connect(function() updateCanvas() end)
    scroller:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(updateCanvas)

    -- open animation
    main.Position = main.Position - UDim2.new(0,0,0.05,0)
    main.AnchorPoint = Vector2.new(0.5, 0)
    local tweenInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(main, tweenInfo, {Position = UDim2.new(0.5, -STYLE.WindowSize.X.Offset/2, 0.08, 0)}):Play()

    return selfObj
end

-- Добавить секцию (возвращает frame секции)
function iOSLikeUI:AddSection(title)
    local secFrame = Instance.new("Frame")
    secFrame.Size = UDim2.new(1, 0, 0, 44)
    secFrame.BackgroundTransparency = 1
    secFrame.LayoutOrder = #self.content:GetChildren() + 1
    secFrame.Parent = self.content

    local header = createLabel(title, UDim2.new(1, 0, 0, 24))
    header.Font = STYLE.Font
    header.TextSize = 15
    header.Parent = secFrame
    header.Position = UDim2.new(0, 0, 0, 0)

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

    function secFrame:AddButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 38)
        btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
        btn.BackgroundTransparency = 0.03
        addCorner(btn, 12)
        btn.Font = STYLE.Font
        btn.TextSize = 14
        btn.Text = text or "Button"
        btn.TextColor3 = STYLE.TextColor
        btn.Parent = container

        btn.MouseButton1Click:Connect(function()
            -- клип анимации нажатия
            local ti = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local t = TweenService:Create(btn, ti, {BackgroundTransparency = 0.12})
            t:Play()
            t.Completed:Wait()
            TweenService:Create(btn, ti, {BackgroundTransparency = 0.03}):Play()
            if callback then
                pcall(callback)
            end
        end)
        return btn
    end

    function secFrame:AddToggle(text, default, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 40)
        row.BackgroundTransparency = 1
        row.Parent = container

        local lbl = createLabel(text, UDim2.new(0.7, 0, 1, 0))
        lbl.Parent = row
        lbl.Position = UDim2.new(0, 0, 0, 6)

        local togg = Instance.new("TextButton")
        togg.Size = UDim2.new(0, 80, 0, 30)
        togg.Position = UDim2.new(1, -80, 0, 5)
        togg.AnchorPoint = Vector2.new(1, 0)
        togg.BackgroundColor3 = Color3.fromRGB(230,230,235)
        addCorner(togg, 14)
        togg.Parent = row
        togg.Text = ""
        togg.AutoButtonColor = false

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(default and 0.5 or 0.02, -6, 1, -6)
        fill.Position = UDim2.new(default and 0.02 or 0.5, 3, 0, 3)
        fill.BackgroundColor3 = default and STYLE.Accent or Color3.fromRGB(200,200,205)
        addCorner(fill, 12)
        fill.Parent = togg

        local state = default and true or false

        local function setState(s)
            state = s
            local targetSize = s and UDim2.new(0.5, -6, 1, -6) or UDim2.new(0.02, -6, 1, -6)
            local targetPos = s and UDim2.new(0.02, 3, 0, 3) or UDim2.new(0.96, -3, 0, 3)
            TweenService:Create(fill, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {Size = targetSize, Position = targetPos, BackgroundColor3 = s and STYLE.Accent or Color3.fromRGB(200,200,205)}):Play()
            if callback then
                pcall(callback, state)
            end
        end

        togg.MouseButton1Click:Connect(function()
            setState(not state)
        end)

        return {Frame = row, Set = setState, Get = function() return state end}
    end

    function secFrame:AddSlider(text, min, max, default, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 62)
        row.BackgroundTransparency = 1
        row.Parent = container

        local lbl = createLabel(text, UDim2.new(1, 0, 0, 24))
        lbl.Parent = row
        lbl.Position = UDim2.new(0, 0, 0, 0)

        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, 0, 0, 30)
        sliderBg.Position = UDim2.new(0, 0, 0, 28)
        sliderBg.BackgroundColor3 = Color3.fromRGB(230,230,235)
        addCorner(sliderBg, 12)
        sliderBg.Parent = row

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0, 0, 1, 0)
        fill.Position = UDim2.new(0, 0, 0, 0)
        fill.BackgroundColor3 = STYLE.Accent
        addCorner(fill, 12)
        fill.Parent = sliderBg

        local knob = Instance.new("ImageButton")
        knob.Size = UDim2.new(0, 0, 1, -8)
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new(0, 10, 0.5, 0)
        knob.BackgroundTransparency = 1
        knob.Parent = sliderBg
        addCorner(knob, 18)
        knob.Image = ""
        knob.AutoButtonColor = false

        local value = default or min or 0
        min = min or 0
        max = max or 100

        local function updateUIFromValue(v)
            local frac = 0
            if max > min then
                frac = math.clamp((v - min) / (max - min), 0, 1)
            end
            fill.Size = UDim2.new(frac, 0, 1, 0)
            knob.Position = UDim2.new(frac, 10, 0.5, 0)
        end

        updateUIFromValue(value)

        local dragging = false
        knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        knob.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        game:GetService("UserInputService").InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local abs = sliderBg.AbsolutePosition.X
                local width = sliderBg.AbsoluteSize.X
                local mouseX = game:GetService("UserInputService"):GetMouseLocation().X
                local rel = math.clamp((mouseX - abs) / width, 0, 1)
                local newVal = min + (max - min) * rel
                value = newVal
                updateUIFromValue(value)
                if callback then
                    pcall(callback, value)
                end
            end
        end)

        return {Frame = row, Get = function() return value end, Set = function(v) value = math.clamp(v, min, max); updateUIFromValue(value) end}
    end

    return secFrame
end

-- Убрать/скрыть окно
function iOSLikeUI:Destroy()
    if self.screen then
        self.screen:Destroy()
    end
end

return iOSLikeUI
