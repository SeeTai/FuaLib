---====
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui", 10)

local iOSLauncherUI = {}
iOSLauncherUI.__index = iOSLauncherUI

-- Настройки стиля iOS Launcher
local STYLE = {
    MainSize = UDim2.new(0, 400, 0, 400), -- Квадратный главный фрейм
    IconSize = UDim2.new(0, 80, 0, 80), -- Размер иконок секций
    Corner = 12,
    Padding = 10,
    Font = Enum.Font.Gotham,
    BgColor = Color3.fromRGB(28, 37, 38), -- Тёмный фон
    ElementBg = Color3.fromRGB(44, 47, 51), -- Тёмно-серый для элементов
    Accent = Color3.fromRGB(0, 122, 255), -- Синий акцент
    TextColor = Color3.fromRGB(255, 255, 255), -- Белый текст
    ShadowColor = Color3.fromRGB(0, 0, 0), -- Цвет тени
    Transparency = 0.3 -- Прозрачность фона
}

-- Вспомог: rounded corner
local function addCorner(inst, radius)
    if not inst then return end
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = inst
end

-- Вспомог: add shadow
local function addShadow(inst)
    if not inst then return end
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = STYLE.ShadowColor
    stroke.Transparency = 0.7
    stroke.Parent = inst
end

-- Вспомог: create label
local function createLabel(text, size, font, textSize)
    if not text then return end
    local lbl = Instance.new("TextLabel")
    lbl.Size = size or UDim2.new(1, 0, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = font or STYLE.Font
    lbl.TextSize = textSize or 14
    lbl.TextColor3 = STYLE.TextColor
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.ClipsDescendants = true
    return lbl
end

-- Создать окно
function iOSLauncherUI:CreateWindow(title)
    if not PlayerGui then
        error("PlayerGui not initialized")
        return
    end

    local selfObj = setmetatable({}, iOSLauncherUI)
    local screen = Instance.new("ScreenGui")
    screen.Name = "iOSLauncherUI"
    screen.ResetOnSpawn = false
    screen.Parent = PlayerGui

    local main = Instance.new("Frame")
    main.Name = "MainWindow"
    main.Size = STYLE.MainSize
    main.Position = UDim2.new(0.5, -STYLE.MainSize.X.Offset/2, 0.5, -STYLE.MainSize.Y.Offset/2)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = STYLE.BgColor
    main.BackgroundTransparency = STYLE.Transparency
    main.Parent = screen
    addCorner(main, STYLE.Corner)
    addShadow(main)

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 37, 38)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(44, 47, 51))
    })
    gradient.Rotation = 90
    gradient.Parent = main

    -- Title
    local titleLabel = createLabel(title or "Launcher", UDim2.new(1, -20, 0, 40), STYLE.Font, 18)
    titleLabel.Position = UDim2.new(0, 10, 0, 10)
    titleLabel.Parent = main

    -- Grid layout for sections
    local grid = Instance.new("UIGridLayout")
    grid.CellSize = STYLE.IconSize
    grid.CellPadding = UDim2.new(0, STYLE.Padding, 0, STYLE.Padding)
    grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    grid.VerticalAlignment = Enum.VerticalAlignment.Top
    grid.Parent = main
    grid.FillDirectionMaxCells = 3 -- 3 иконки в ряд

    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 60) -- Отступ от заголовка
    contentPadding.Parent = main

    selfObj.screen = screen
    selfObj.main = main
    selfObj.grid = grid
    selfObj.sections = {}

    -- Open animation
    main.Position = UDim2.new(0.5, -STYLE.MainSize.X.Offset/2, 0.6, 0)
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(main, tweenInfo, {Position = UDim2.new(0.5, -STYLE.MainSize.X.Offset/2, 0.5, -STYLE.MainSize.Y.Offset/2)}):Play()

    -- Toggle visibility with Insert
    local toggleConnection
    toggleConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.Insert then
            if main.Visible then
                local tween = TweenService:Create(main, tweenInfo, {Position = UDim2.new(0.5, -STYLE.MainSize.X.Offset/2, 0.6, 0)})
                tween:Play()
                tween.Completed:Connect(function()
                    main.Visible = false
                end)
            else
                main.Visible = true
                TweenService:Create(main, tweenInfo, {Position = UDim2.new(0.5, -STYLE.MainSize.X.Offset/2, 0.5, -STYLE.MainSize.Y.Offset/2)}):Play()
            end
        end
    end)

    screen.Destroying:Connect(function()
        if toggleConnection then toggleConnection:Disconnect() end
    end)

    return selfObj
end

-- Добавить секцию (иконку)
function iOSLauncherUI:AddSection(name)
    local section = Instance.new("Frame")
    section.Size = STYLE.IconSize
    section.BackgroundColor3 = STYLE.ElementBg
    section.BackgroundTransparency = 0.2
    section.Parent = self.main
    addCorner(section, STYLE.Corner)
    addShadow(section)

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0, 48, 0, 48)
    icon.Position = UDim2.new(0.5, 0, 0, 10)
    icon.AnchorPoint = Vector2.new(0.5, 0)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://6023426945" -- Пример иконки (замени на свою)
    icon.Parent = section

    local label = createLabel(name, UDim2.new(1, 0, 0, 20), STYLE.Font, 12)
    label.Position = UDim2.new(0.5, 0, 1, -20)
    label.AnchorPoint = Vector2.new(0.5, 1)
    label.Parent = section

    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 0, 0)
    content.Position = UDim2.new(0, 10, 1, 10)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = section

    local vlist = Instance.new("UIListLayout")
    vlist.Parent = content
    vlist.SortOrder = Enum.SortOrder.LayoutOrder
    vlist.Padding = UDim.new(0, 5)

    -- Toggle content visibility
    local isOpen = false
    section.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isOpen = not isOpen
            content.Visible = isOpen
            if isOpen then
                local height = vlist.AbsoluteContentSize.Y + 10
                content.Size = UDim2.new(1, -20, 0, height)
                TweenService:Create(content, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Size = UDim2.new(1, -20, 0, height)}):Play()
            else
                content.Size = UDim2.new(1, -20, 0, 0)
            end
        end
    end)

    -- Add elements
    function section:AddToggle(text, default, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 40)
        row.BackgroundTransparency = 1
        row.Parent = content

        local lbl = createLabel(text, UDim2.new(0.7, 0, 1, 0))
        lbl.Position = UDim2.new(0, 0, 0, 6)
        lbl.Parent = row

        local togg = Instance.new("TextButton")
        togg.Size = UDim2.new(0, 50, 0, 28)
        togg.Position = UDim2.new(1, -50, 0, 6)
        togg.BackgroundColor3 = STYLE.ElementBg
        addCorner(togg, STYLE.Corner)
        togg.Parent = row
        togg.Text = ""
        togg.AutoButtonColor = false

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(default and 0.5 or 0.24, -6, 1, -6)
        fill.Position = UDim2.new(default and 0.02 or 0.5, 3, 0, 3)
        fill.BackgroundColor3 = default and STYLE.Accent or STYLE.ElementBg
        addCorner(fill, STYLE.Corner - 2)
        fill.Parent = togg

        local state = default or false

        local function setState(s)
            state = s
            local targetSize = s and UDim2.new(0.5, -6, 1, -6) or UDim2.new(0.24, -6, 1, -6)
            local targetPos = s and UDim2.new(0.02, 3, 0, 3) or UDim2.new(0.5, 3, 0, 3)
            TweenService:Create(fill, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {Size = targetSize, Position = targetPos, BackgroundColor3 = s and STYLE.Accent or STYLE.ElementBg}):Play()
            if callback then pcall(callback, state) end
        end

        togg.MouseButton1Click:Connect(function()
            setState(not state)
        end)
        togg.TouchTap:Connect(function()
            setState(not state)
        end)

        vlist.Changed:Connect(function()
            content.Size = UDim2.new(1, -20, 0, vlist.AbsoluteContentSize.Y + 10)
        end)

        return {Frame = row, Set = setState, Get = function() return state end}
    end

    function section:AddButton(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 38)
        btn.BackgroundColor3 = STYLE.ElementBg
        btn.BackgroundTransparency = 0.2
        addCorner(btn, STYLE.Corner)
        btn.Font = STYLE.Font
        btn.TextSize = 14
        btn.Text = text or "Button"
        btn.TextColor3 = STYLE.TextColor
        btn.Parent = content

        btn.MouseButton1Click:Connect(function()
            local ti = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local t = TweenService:Create(btn, ti, {BackgroundTransparency = 0.4})
            t:Play()
            t.Completed:Wait()
            TweenService:Create(btn, ti, {BackgroundTransparency = 0.2}):Play()
            if callback then pcall(callback) end
        end)

        vlist.Changed:Connect(function()
            content.Size = UDim2.new(1, -20, 0, vlist.AbsoluteContentSize.Y + 10)
        end)

        return btn
    end

    table.insert(selfObj.sections, section)
    return section
end

-- Убрать/скрыть окно
function iOSLauncherUI:Destroy()
    if self.screen then
        local tween = TweenService:Create(self.main, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, -STYLE.MainSize.X.Offset/2, 0.6, 0)})
        tween:Play()
        tween.Completed:Connect(function()
            self.screen:Destroy()
        end)
    end
end

return iOSLauncherUI
