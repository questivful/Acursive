local Alion = {}
Alion.Version = "1.0.0"
Alion.__index = Alion

if getgenv and type(getgenv().Alion) == "table" and getgenv().Alion.Cleanup then
    pcall(function() getgenv().Alion:Cleanup() end)
    task.wait(0.1)
end

local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local CoreGui           = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local ICON_SHEET = "rbxassetid://89989658646441"
local ICON_NAMES = {
    "home", "sliders", "user", "search", "sword", "eye", "globe", "folder",
    "info", "close", "minimize", "check", "chevron-down", "chevron-up", "chevron-right", "chevron-left",
    "plus", "square", "star", "heart", "bell", "lock", "palette", "code",
    "bolt", "drop", "shield", "cursor", "keyboard", "list", "trash", "refresh",
    "moon", "sun", "copy", "key", "bookmark", "target", "layers", "edit",
}
local ICON_CELL = 64
local ICON_COLS = 8
local ICON_INDEX = {}
for i, name in ipairs(ICON_NAMES) do ICON_INDEX[name] = i - 1 end
ICON_INDEX["settings"] = ICON_INDEX["sliders"]
ICON_INDEX["zap"]      = ICON_INDEX["bolt"]
ICON_INDEX["gauge"]    = ICON_INDEX["bolt"]
ICON_INDEX["gear"]     = ICON_INDEX["sliders"]

local T = {
    Background   = Color3.fromRGB(28, 28, 28),
    Card         = Color3.fromRGB(38, 38, 38),
    CardTrans    = 0.10,
    Control      = Color3.fromRGB(50, 50, 50),
    ControlHover = Color3.fromRGB(62, 62, 62),
    Input        = Color3.fromRGB(24, 24, 24),
    Stroke       = Color3.fromRGB(74, 74, 74),
    StrokeLight  = Color3.fromRGB(102, 102, 102),
    Divider      = Color3.fromRGB(56, 56, 56),
    Text         = Color3.fromRGB(242, 242, 242),
    SubText      = Color3.fromRGB(165, 165, 165),
    Muted        = Color3.fromRGB(120, 120, 120),
    Accent       = Color3.fromRGB(255, 140, 50),
    AccentText   = Color3.fromRGB(0, 0, 0),
    Danger       = Color3.fromRGB(196, 43, 28),
}

Alion.Theme             = T
Alion.Accent            = T.Accent
Alion._gui              = nil
Alion._connections      = {}
Alion._keybinds         = {}
Alion._accentBindings   = {}
Alion._notifCounter     = 0
Alion._notifLower       = false
Alion._capturingKeybind = nil

local function new(class, props, children)
    local inst = Instance.new(class)
    local parent
    for k, v in pairs(props or {}) do
        if k == "Parent" then parent = v else inst[k] = v end
    end
    for _, child in ipairs(children or {}) do child.Parent = inst end
    if parent then inst.Parent = parent end
    return inst
end

local function ti(time, style, dir, delay)
    return TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out, 0, false, delay or 0)
end

local function tween(inst, info, props)
    if not inst or not inst.Parent then return nil end
    local t = TweenService:Create(inst, info, props)
    t:Play()
    return t
end

local function corner(parent, r)
    return new("UICorner", { CornerRadius = UDim.new(0, r), Parent = parent })
end

local function stroke(parent, color, thickness, transparency)
    return new("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function shadow(parent, blur, offsetY, transparency)
    local ok, s = pcall(Instance.new, "UIShadow")
    if not ok or not s then return nil end
    pcall(function() s.Color = Color3.new(0, 0, 0) end)
    pcall(function() s.BlurRadius = UDim.new(0, blur) end)
    pcall(function() s.Offset = UDim2.fromOffset(0, offsetY) end)
    pcall(function() s.Spread = UDim2.fromOffset(0, 0) end)
    pcall(function() s.Transparency = transparency end)
    pcall(function() s.ShowBehindParent = true end)
    pcall(function() s.Enabled = true end)
    s.Parent = parent
    return s
end

local function label(props)
    local p = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Font = Enum.Font.BuilderSansMedium,
        TextSize = 14,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Text = "",
    }
    for k, v in pairs(props) do p[k] = v end
    return new("TextLabel", p)
end

local function applyIcon(img, name, color)
    if typeof(name) ~= "string" or name == "" then img.Visible = false return end
    if name:find("rbxasset") then
        img.Image = name
        img.ImageRectSize = Vector2.zero
        img.ImageRectOffset = Vector2.zero
    else
        local idx = ICON_INDEX[name]
        if not idx then img.Visible = false return end
        img.Image = ICON_SHEET
        img.ImageRectSize = Vector2.new(ICON_CELL, ICON_CELL)
        img.ImageRectOffset = Vector2.new((idx % ICON_COLS) * ICON_CELL, math.floor(idx / ICON_COLS) * ICON_CELL)
    end
    img.Visible = true
    if color then img.ImageColor3 = color end
end

local function icon(props, name, color)
    local p = { BackgroundTransparency = 1, BorderSizePixel = 0 }
    for k, v in pairs(props) do p[k] = v end
    local img = new("ImageLabel", p)
    applyIcon(img, name, color)
    return img
end

local function fire(cb, ...)
    if type(cb) ~= "function" then return end
    local args = table.pack(...)
    task.spawn(function()
        local ok, err = pcall(cb, table.unpack(args, 1, args.n))
        if not ok then warn("[Alion] " .. tostring(err)) end
    end)
end

local function toKeyCode(v)
    if typeof(v) == "EnumItem" and v.EnumType == Enum.KeyCode then return v end
    if type(v) == "string" then
        local ok, kc = pcall(function() return Enum.KeyCode[v] end)
        if ok and kc then return kc end
    end
    return Enum.KeyCode.E
end

local function getGuiParent()
    local ok, ui = pcall(function() return gethui and gethui() end)
    if ok and ui then return ui end
    local ok2, core = pcall(function()
        local c = CoreGui
        local probe = Instance.new("Folder")
        probe.Parent = c
        probe:Destroy()
        return c
    end)
    if ok2 and core then return core end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function getGui()
    if Alion._gui and Alion._gui.Parent then return Alion._gui end
    local parent = getGuiParent()
    for _, child in ipairs(parent:GetChildren()) do
        if child.Name == "Alion" then pcall(function() child:Destroy() end) end
    end
    local gui = new("ScreenGui", {
        Name = "Alion",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        DisplayOrder = 1000,
        Parent = parent,
    })
    Alion._gui = gui
    return gui
end

local function track(conn)
    if conn then table.insert(Alion._connections, conn) end
    return conn
end

local function registerAccent(inst, prop, fn)
    table.insert(Alion._accentBindings, { inst = inst, prop = prop or "BackgroundColor3", fn = fn })
end

local function applyAccentColor(color)
    Alion.Accent = color
    for _, b in ipairs(Alion._accentBindings) do
        if b.fn then pcall(b.fn)
        elseif b.inst and b.inst.Parent then pcall(function() b.inst[b.prop] = color end) end
    end
end

function Alion:SetAccent(color) applyAccentColor(color) end
function Alion:GetAccent() return Alion.Accent end
function Alion:SetNotificationLower(v) self._notifLower = v and true or false end

function Alion:Cleanup()
    for _, c in ipairs(self._connections or {}) do pcall(function() c:Disconnect() end) end
    self._connections = {}
    self._keybinds = {}
    self._accentBindings = {}
    self._capturingKeybind = nil
    if self._gui then pcall(function() self._gui:Destroy() end) end
    self._gui = nil
    if getgenv and getgenv().Alion == self then getgenv().Alion = nil end
end

track(UserInputService.InputBegan:Connect(function(input, processed)
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if Alion._capturingKeybind then
        local cb = Alion._capturingKeybind
        Alion._capturingKeybind = nil
        pcall(cb, input.KeyCode)
        return
    end
    if UserInputService:GetFocusedTextBox() then return end
    for _, entry in ipairs(Alion._keybinds) do
        if entry.key == input.KeyCode and entry.cb then
            fire(entry.cb)
            break
        end
    end
end))

function Alion:Notify(o)
    o = o or {}
    local gui = getGui()
    local holder = gui:FindFirstChild("Notifications")
    if not holder then
        holder = new("Frame", {
            Name = "Notifications",
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -20, 1, -20),
            Size = UDim2.new(0, 320, 1, -40),
            BackgroundTransparency = 1,
            Parent = gui,
        })
        new("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            HorizontalAlignment = Enum.HorizontalAlignment.Right,
            Parent = holder,
        })
    end
    self._notifCounter = (self._notifCounter or 0) + 1
    local duration = o.Duration or 4
    local wrap = new("Frame", {
        Size = UDim2.new(1, 0, 0, 72),
        BackgroundTransparency = 1,
        LayoutOrder = self._notifCounter,
        Parent = holder,
    })
    local card = new("Frame", {
        Position = UDim2.new(1, 80, 0, 0),
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BackgroundTransparency = 0.06,
        Parent = wrap,
    })
    corner(card, 8)
    stroke(card, T.Stroke, 1, 0.15)
    shadow(card, 26, 8, 0.55)
    icon({ Position = UDim2.fromOffset(16, 14), Size = UDim2.fromOffset(20, 20), Parent = card }, o.Icon or "bell", Alion.Accent)
    label({
        Position = UDim2.fromOffset(48, 12),
        Size = UDim2.new(1, -64, 0, 20),
        Text = o.Title or "Notification",
        Font = Enum.Font.BuilderSansBold,
        TextSize = 14,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = card,
    })
    label({
        Position = UDim2.fromOffset(48, 32),
        Size = UDim2.new(1, -64, 0, 26),
        Text = o.Content or "",
        Font = Enum.Font.BuilderSans,
        TextSize = 12,
        TextColor3 = T.SubText,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = card,
    })
    local rail = new("Frame", {
        Position = UDim2.new(0, 12, 1, -6),
        Size = UDim2.new(1, -24, 0, 2),
        BackgroundColor3 = Color3.fromRGB(62, 62, 62),
        BorderSizePixel = 0,
        Parent = card,
    })
    corner(rail, 100)
    local fill = new("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Alion.Accent,
        BorderSizePixel = 0,
        Parent = rail,
    })
    corner(fill, 100)
    registerAccent(fill)
    tween(card, ti(0.5), { Position = UDim2.new(0, 0, 0, 0) })
    tween(fill, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 1, 0) })
    task.delay(duration, function()
        if not card.Parent then return end
        tween(card, ti(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Position = UDim2.new(1, 80, 0, 0) })
        task.wait(0.35)
        if wrap.Parent then
            local t = tween(wrap, ti(0.3), { Size = UDim2.new(1, 0, 0, 0) })
            if t then t.Completed:Wait() end
            wrap:Destroy()
        end
    end)
end

local Window = {}
Window.__index = Window
local Tab = {}
Tab.__index = Tab
local Section = {}
Section.__index = Section

local function makeDraggable(win, handles)
    local dragging, dragStart, startPos
    for _, handle in ipairs(handles) do
        track(handle.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = win.Root.Position
                local c
                c = input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        c:Disconnect()
                    end
                end)
            end
        end))
    end
    track(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            tween(win.Root, TweenInfo.new(0.08, Enum.EasingStyle.Sine), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y),
            })
        end
    end))
end

local function styleNav(tab, active)
    tween(tab.Button, ti(0.25), { BackgroundTransparency = active and 0.90 or 1 })
    tween(tab.IconImg, ti(0.25), { ImageColor3 = active and Alion.Accent or Color3.fromRGB(205, 205, 205) })
    tween(tab.NameLabel, ti(0.25), { TextColor3 = active and T.Text or Color3.fromRGB(205, 205, 205) })
end

function Alion:CreateWindow(opts)
    opts = opts or {}
    local gui = getGui()
    local camera = workspace.CurrentCamera
    local vp = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local size = opts.Size
    local width = size and size.X.Offset or math.min(620, vp.X - 40)
    local height = size and size.Y.Offset or math.min(520, vp.Y - 40)

    local win = setmetatable({
        Tabs = {},
        Flags = {},
        ToggleKey = toKeyCode(opts.ToggleKey or Enum.KeyCode.RightShift),
        _open = false,
        _token = 0,
        _destroyed = false,
    }, Window)

    local root = new("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.fromOffset(width, height),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = gui,
    })
    local scale = new("UIScale", { Scale = 0.9, Parent = root })
    local body = new("Frame", {
        Name = "Body",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = T.Background,
        BackgroundTransparency = 1,
        Parent = root,
    })
    corner(body, 8)
    local bodyStroke = stroke(body, Color3.fromRGB(80, 80, 80), 1, 1)
    local bodyShadow = shadow(body, 40, 14, 1)
    local content = new("CanvasGroup", {
        Name = "Content",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        GroupTransparency = 1,
        Parent = body,
    })
    corner(content, 8)

    local sidebar = new("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 216, 1, 0),
        BackgroundTransparency = 1,
        Parent = content,
    })
    local sideDrag = new("Frame", {
        Size = UDim2.new(1, 0, 0, 72),
        BackgroundTransparency = 1,
        Active = true,
        Parent = sidebar,
    })
    local avatar = new("ImageLabel", {
        Size = UDim2.fromOffset(40, 40),
        Position = UDim2.fromOffset(16, 16),
        BackgroundColor3 = Color3.fromRGB(62, 62, 62),
        Image = "",
        Parent = sidebar,
    })
    corner(avatar, 100)
    stroke(avatar, T.StrokeLight, 1, 0.3)
    task.spawn(function()
        local ok, img = pcall(function()
            return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok and avatar.Parent then avatar.Image = img end
    end)
    label({
        Position = UDim2.fromOffset(64, 16),
        Size = UDim2.new(1, -76, 0, 20),
        Text = LocalPlayer.DisplayName,
        Font = Enum.Font.BuilderSansBold,
        TextSize = 15,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = sidebar,
    })
    label({
        Position = UDim2.fromOffset(64, 36),
        Size = UDim2.new(1, -76, 0, 18),
        Text = opts.Title or "Alion",
        Font = Enum.Font.BuilderSans,
        TextSize = 12,
        TextColor3 = T.SubText,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = sidebar,
    })
    local nav = new("Frame", {
        Name = "Nav",
        Position = UDim2.fromOffset(8, 80),
        Size = UDim2.new(1, -16, 1, -124),
        BackgroundTransparency = 1,
        Parent = sidebar,
    })
    local indicator = new("Frame", {
        Size = UDim2.fromOffset(3, 16),
        Position = UDim2.fromOffset(0, 11),
        BackgroundColor3 = Alion.Accent,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 5,
        Parent = nav,
    })
    corner(indicator, 100)
    registerAccent(indicator)
    label({
        Position = UDim2.new(0, 16, 1, -34),
        Size = UDim2.new(1, -32, 0, 18),
        Text = "Alion v" .. Alion.Version,
        Font = Enum.Font.BuilderSans,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(120, 120, 120),
        Parent = sidebar,
    })

    local main = new("Frame", {
        Name = "Main",
        Position = UDim2.fromOffset(216, 0),
        Size = UDim2.new(1, -216, 1, 0),
        BackgroundTransparency = 1,
        Parent = content,
    })
    local header = new("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundTransparency = 1,
        Active = true,
        Parent = main,
    })
    local titleLabel = label({
        Position = UDim2.fromOffset(24, 0),
        Size = UDim2.new(1, -130, 1, 0),
        Text = "",
        Font = Enum.Font.BuilderSansBold,
        TextSize = 24,
        Parent = header,
    })

    local function ctrlButton(iconName, xOff, hoverColor, hoverTransparency)
        local b = new("TextButton", {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, xOff, 0, 0),
            Size = UDim2.fromOffset(46, 36),
            BackgroundColor3 = hoverColor,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            Parent = header,
        })
        icon({
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(14, 14),
            Parent = b,
        }, iconName, T.Text)
        track(b.MouseEnter:Connect(function() tween(b, ti(0.15), { BackgroundTransparency = hoverTransparency }) end))
        track(b.MouseLeave:Connect(function() tween(b, ti(0.15), { BackgroundTransparency = 1 }) end))
        return b
    end

    local closeButton = ctrlButton("close", 0, T.Danger, 0)
    local minButton = ctrlButton("minimize", -46, Color3.new(1, 1, 1), 0.92)

    local pages = new("Frame", {
        Name = "Pages",
        Position = UDim2.fromOffset(0, 56),
        Size = UDim2.new(1, 0, 1, -56),
        BackgroundTransparency = 1,
        Parent = main,
    })

    win.Root = root
    win.Scale = scale
    win.Body = body
    win.BodyStroke = bodyStroke
    win.Shadow = bodyShadow
    win.Content = content
    win.Nav = nav
    win.Pages = pages
    win.Indicator = indicator
    win.TitleLabel = titleLabel

    makeDraggable(win, { header, sideDrag })

    track(minButton.Activated:Connect(function()
        win:Close()
        Alion:Notify({ Title = "Window hidden", Content = "Press " .. win.ToggleKey.Name .. " to open it again.", Icon = "info", Duration = 3 })
    end))
    track(closeButton.Activated:Connect(function() win:Destroy() end))

    track(UserInputService.InputBegan:Connect(function(input, processed)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if input.KeyCode == win.ToggleKey then
            if UserInputService:GetFocusedTextBox() then return end
            win:Toggle()
        end
    end))

    win:Open()
    return win
end

function Window:SetVisible(v)
    if self._open == v or (self._destroyed and v) then return end
    self._open = v
    self._token += 1
    local token = self._token
    if v then
        local target = self._pos or self.Root.Position
        self.Root.Position = UDim2.new(target.X.Scale, target.X.Offset, target.Y.Scale, target.Y.Offset + 24)
        self.Root.Visible = true
        local info = ti(0.5)
        tween(self.Root, info, { Position = target })
        tween(self.Scale, info, { Scale = 1 })
        tween(self.Content, ti(0.4), { GroupTransparency = 0 })
        tween(self.Body, ti(0.4), { BackgroundTransparency = 0.06 })
        tween(self.BodyStroke, ti(0.4), { Transparency = 0.15 })
        if self.Shadow then pcall(function() tween(self.Shadow, ti(0.5), { Transparency = 0.5 }) end) end
    else
        local p = self.Root.Position
        self._pos = p
        local info = ti(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        tween(self.Root, info, { Position = UDim2.new(p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset + 24) })
        tween(self.Scale, info, { Scale = 0.92 })
        tween(self.Content, info, { GroupTransparency = 1 })
        tween(self.Body, info, { BackgroundTransparency = 1 })
        tween(self.BodyStroke, info, { Transparency = 1 })
        if self.Shadow then pcall(function() tween(self.Shadow, info, { Transparency = 1 }) end) end
        task.delay(0.32, function()
            if self._token == token then self.Root.Visible = false end
        end)
    end
end

function Window:Toggle() self:SetVisible(not self._open) end
function Window:Open() self:SetVisible(true) end
function Window:Close() self:SetVisible(false) end
function Window:SetToggleKey(key) self.ToggleKey = toKeyCode(key) end
function Window:Notify(o) Alion:Notify(o) end

function Window:Destroy()
    if self._destroyed then return end
    self._destroyed = true
    if self._open then self:SetVisible(false) end
    task.delay(0.45, function() pcall(function() self.Root:Destroy() end) end)
end

function Window:SelectTab(tab)
    if type(tab) == "number" then tab = self.Tabs[tab] end
    if not tab or self.Active == tab then return end
    local prev = self.Active
    self.Active = tab
    if prev then
        styleNav(prev, false)
        tween(prev.Page, ti(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { GroupTransparency = 1 })
        task.delay(0.2, function()
            if self.Active ~= prev then prev.Page.Visible = false end
        end)
    end
    styleNav(tab, true)
    tab.Page.Position = UDim2.fromOffset(0, 18)
    tab.Page.GroupTransparency = 1
    tab.Page.Visible = true
    tab.Scroll.CanvasPosition = Vector2.zero
    tween(tab.Page, ti(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0.08), {
        Position = UDim2.fromOffset(0, 0),
        GroupTransparency = 0,
    })
    local y = (tab.Index - 1) * 42 + 11
    if not prev then
        self.Indicator.Position = UDim2.fromOffset(0, y)
        self.Indicator.Visible = true
    else
        tween(self.Indicator, ti(0.4), { Position = UDim2.fromOffset(0, y) })
    end
    self.TitleLabel.Text = tab.Name
    self.TitleLabel.TextTransparency = 1
    self.TitleLabel.Position = UDim2.fromOffset(38, 0)
    tween(self.TitleLabel, ti(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0.05), {
        TextTransparency = 0,
        Position = UDim2.fromOffset(24, 0),
    })
end

function Window:Tab(opts)
    opts = opts or {}
    local name = opts.Title or opts.Name or "Tab"
    local iconName = opts.Icon or "home"
    local index = #self.Tabs + 1

    local wrap = new("CanvasGroup", {
        Name = name,
        Size = UDim2.new(1, 0, 0, 38),
        Position = UDim2.fromOffset(-14, (index - 1) * 42),
        BackgroundTransparency = 1,
        GroupTransparency = 1,
        Parent = self.Nav,
    })
    local button = new("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = wrap,
    })
    corner(button, 6)
    local iconImg = icon({
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 14, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        Parent = button,
    }, iconName, Color3.fromRGB(205, 205, 205))
    local nameLabel = label({
        Position = UDim2.fromOffset(46, 0),
        Size = UDim2.new(1, -52, 1, 0),
        Text = name,
        TextColor3 = Color3.fromRGB(205, 205, 205),
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = button,
    })

    local page = new("CanvasGroup", {
        Name = name,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        GroupTransparency = 1,
        Visible = false,
        Parent = self.Pages,
    })
    local scroll = new("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Color3.fromRGB(110, 110, 110),
        ScrollBarImageTransparency = 0.3,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ElasticBehavior = Enum.ElasticBehavior.Never,
        Parent = page,
    })
    new("UIPadding", {
        PaddingLeft = UDim.new(0, 24),
        PaddingRight = UDim.new(0, 20),
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 24),
        Parent = scroll,
    })
    new("UIListLayout", {
        Padding = UDim.new(0, 14),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = scroll,
    })

    local tab = setmetatable({
        Window = self,
        Name = name,
        Index = index,
        Page = page,
        Scroll = scroll,
        Content = scroll,
        Button = button,
        IconImg = iconImg,
        NameLabel = nameLabel,
        _order = 1,
        _currentSection = nil,
        Elements = {},
    }, Tab)
    table.insert(self.Tabs, tab)

    track(button.MouseEnter:Connect(function()
        if self.Active ~= tab then tween(button, ti(0.2), { BackgroundTransparency = 0.95 }) end
    end))
    track(button.MouseLeave:Connect(function()
        if self.Active ~= tab then tween(button, ti(0.2), { BackgroundTransparency = 1 }) end
    end))
    track(button.Activated:Connect(function() self:SelectTab(tab) end))

    task.delay(0.3 + (index - 1) * 0.06, function()
        if wrap.Parent then
            tween(wrap, ti(0.5), { Position = UDim2.fromOffset(0, (index - 1) * 42), GroupTransparency = 0 })
        end
    end)

    if index == 1 then self:SelectTab(tab) end
    return tab
end

function Tab:_target()
    if self._currentSection and self._currentSection.Body then
        return self._currentSection.Body
    end
    return self.Content
end

function Tab:_nextOrder()
    if self._currentSection then
        self._currentSection._order = (self._currentSection._order or 0) + 1
        return self._currentSection._order
    end
    self._order = self._order + 1
    return self._order
end

function Tab:Section(opts)
    opts = opts or {}
    local title = opts.Title or opts.Name or ""
    local order = self._order + 1
    self._order = order

    local wrap = new("Frame", {
        Name = "Section",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = order,
        Parent = self.Scroll,
    })
    new("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = wrap,
    })
    if title ~= "" then
        label({
            Name = "Heading",
            Size = UDim2.new(1, 0, 0, 20),
            Text = title,
            Font = Enum.Font.BuilderSansBold,
            TextSize = 15,
            TextColor3 = Alion.Accent,
            LayoutOrder = 0,
            Parent = wrap,
        })
    end
    local card = new("Frame", {
        Name = "Card",
        BackgroundColor3 = T.Card,
        BackgroundTransparency = T.CardTrans,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = true,
        LayoutOrder = 1,
        Parent = wrap,
    })
    corner(card, 6)
    stroke(card, T.Stroke, 1, 0.35)
    local body = new("Frame", {
        Name = "Body",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = card,
    })
    new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = body })

    local sec = setmetatable({
        Tab = self,
        Window = self.Window,
        Frame = wrap,
        Card = card,
        Body = body,
        Title = title,
        _order = 0,
        Elements = {},
    }, Section)
    self._currentSection = sec
    return sec
end

function Section:_row(o, reserve)
    self._order = (self._order or 0) + 1
    local hasDesc = type(o.Desc) == "string" and o.Desc ~= "" or type(o.Description) == "string" and o.Description ~= ""
    local descText = o.Desc or o.Description or ""
    local h = hasDesc and 58 or 48
    local row = new("Frame", {
        Name = "Row",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = self._order,
        Parent = self.Body,
    })
    new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = row })
    if self._order > 1 then
        new("Frame", {
            Name = "Divider",
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = T.Divider,
            BorderSizePixel = 0,
            LayoutOrder = 0,
            Parent = row,
        })
    end
    local header = new("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, h),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = 1,
        Parent = row,
    })
    track(header.MouseEnter:Connect(function() tween(header, ti(0.15), { BackgroundTransparency = 0.96 }) end))
    track(header.MouseLeave:Connect(function() tween(header, ti(0.15), { BackgroundTransparency = 1 }) end))
    local x = 16
    if o.Icon then
        icon({
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 16, 0.5, 0),
            Size = UDim2.fromOffset(20, 20),
            ImageColor3 = Color3.fromRGB(215, 215, 215),
            Parent = header,
        }, o.Icon)
        x = 48
    end
    reserve = reserve or 190
    local title = label({
        Name = "Title",
        Position = hasDesc and UDim2.fromOffset(x, 10) or UDim2.fromOffset(x, 0),
        Size = hasDesc and UDim2.new(1, -(x + reserve), 0, 18) or UDim2.new(1, -(x + reserve), 1, 0),
        Text = o.Title or o.Name or "",
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = header,
    })
    local desc
    if hasDesc then
        desc = label({
            Name = "Description",
            Position = UDim2.fromOffset(x, 30),
            Size = UDim2.new(1, -(x + reserve), 0, 18),
            Text = descText,
            Font = Enum.Font.BuilderSans,
            TextSize = 12,
            TextColor3 = T.SubText,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = header,
        })
    end
    return row, header, title, desc
end

local function finishElement(obj, row, title, desc)
    function obj:SetTitle(text) title.Text = text end
    function obj:SetDescription(text) if desc then desc.Text = text end end
    function obj:Destroy() row:Destroy() end
    return obj
end

local function setFlag(section, o, value)
    if o.Flag and section and section.Window then
        section.Window.Flags[o.Flag] = value
    end
end

function Section:Label(o)
    if type(o) == "string" then o = { Title = o } end
    o = o or {}
    local row, header, title, desc = self:_row(o, 24)
    return finishElement({ Type = "Label" }, row, title, desc)
end

function Section:Button(o)
    o = o or {}
    local row, header, title, desc = self:_row(o, (o.Width or 96) + 40)
    local primary = o.Primary == true
    local base = primary and Alion.Accent or T.Control
    local hover = primary and Color3.fromRGB(122, 214, 255) or T.ControlHover
    local b = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.fromOffset(o.Width or 96, 32),
        BackgroundColor3 = base,
        Text = o.ButtonText or "Run",
        Font = Enum.Font.BuilderSansMedium,
        TextSize = 14,
        TextColor3 = primary and T.AccentText or T.Text,
        AutoButtonColor = false,
        Parent = header,
    })
    corner(b, 4)
    stroke(b, primary and Alion.Accent or T.StrokeLight, 1, primary and 1 or 0.5)
    local uiScale = new("UIScale", { Parent = b })
    track(b.MouseEnter:Connect(function() tween(b, ti(0.15), { BackgroundColor3 = hover }) end))
    track(b.MouseLeave:Connect(function()
        tween(b, ti(0.15), { BackgroundColor3 = base })
        tween(uiScale, ti(0.2), { Scale = 1 })
    end))
    track(b.MouseButton1Down:Connect(function() tween(uiScale, ti(0.12), { Scale = 0.95 }) end))
    track(b.MouseButton1Up:Connect(function() tween(uiScale, ti(0.3, Enum.EasingStyle.Back), { Scale = 1 }) end))
    track(b.Activated:Connect(function() fire(o.Callback) end))
    local obj = { Type = "Button" }
    function obj:SetText(text) b.Text = text end
    return finishElement(obj, row, title, desc)
end

function Section:Toggle(o)
    o = o or {}
    local hasKeybind = o.Keybind ~= nil
    local reserve = hasKeybind and 130 or 80
    local row, header, title, desc = self:_row(o, reserve)
    local state = o.Value == true or o.Default == true
    local hover, pressed = false, false
    local off = Color3.fromRGB(210, 210, 210)
    local trackFrame = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.fromOffset(40, 20),
        BackgroundColor3 = Alion.Accent,
        BackgroundTransparency = state and 0 or 1,
        Parent = header,
    })
    corner(trackFrame, 100)
    local trackStroke = stroke(trackFrame, state and Alion.Accent or Color3.fromRGB(160, 160, 160), 1, 0)
    local knob = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, state and 24 or 4, 0.5, 0),
        Size = UDim2.fromOffset(12, 12),
        BackgroundColor3 = state and T.AccentText or off,
        Parent = trackFrame,
    })
    corner(knob, 100)
    local hit = new("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = header,
    })

    local function render()
        local w = pressed and 17 or (hover and 14 or 12)
        local h = hover and 14 or 12
        local x = state and (40 - 4 - w) or 4
        local info = ti(0.25)
        tween(knob, info, {
            Size = UDim2.fromOffset(w, h),
            Position = UDim2.new(0, x, 0.5, 0),
            BackgroundColor3 = state and T.AccentText or off,
        })
        tween(trackFrame, info, { BackgroundTransparency = state and 0 or 1 })
        tween(trackStroke, info, { Color = state and Alion.Accent or Color3.fromRGB(160, 160, 160) })
    end

    track(hit.MouseEnter:Connect(function() hover = true render() end))
    track(hit.MouseLeave:Connect(function() hover = false pressed = false render() end))
    track(hit.MouseButton1Down:Connect(function() pressed = true render() end))
    track(hit.MouseButton1Up:Connect(function() pressed = false render() end))

    local obj = { Type = "Toggle", Value = state }
    local function set(v, silent)
        state = v and true or false
        obj.Value = state
        render()
        setFlag(self, o, state)
        if not silent then fire(o.Callback, state) end
    end
    track(hit.Activated:Connect(function() set(not state) end))
    function obj:Set(v) set(v) end
    function obj:Get() return state end
    setFlag(self, o, state)

    if hasKeybind then
        local key = toKeyCode(o.Keybind)
        local chip = new("TextButton", {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -64, 0.5, 0),
            Size = UDim2.fromOffset(48, 20),
            BackgroundColor3 = T.Input,
            Text = key and key.Name or "—",
            Font = Enum.Font.BuilderSansMedium,
            TextSize = 11,
            TextColor3 = T.SubText,
            AutoButtonColor = false,
            Parent = header,
        })
        corner(chip, 4)
        local chipStroke = stroke(chip, T.Stroke, 1, 0.4)
        track(chip.MouseEnter:Connect(function()
            tween(chip, ti(0.15), { BackgroundColor3 = T.ControlHover, TextColor3 = T.Text })
            tween(chipStroke, ti(0.15), { Color = Alion.Accent })
        end))
        track(chip.MouseLeave:Connect(function()
            tween(chip, ti(0.15), { BackgroundColor3 = T.Input, TextColor3 = T.SubText })
            tween(chipStroke, ti(0.15), { Color = T.Stroke })
        end))
        local entry
        local function bindKey(k)
            if entry then
                for i, e in ipairs(Alion._keybinds) do
                    if e == entry then table.remove(Alion._keybinds, i) break end
                end
            end
            key = k
            chip.Text = k.Name
            entry = { key = k, cb = function() set(not state) end }
            table.insert(Alion._keybinds, entry)
        end
        if key then bindKey(key) end
        track(chip.Activated:Connect(function()
            chip.Text = "..."
            Alion._capturingKeybind = function(k)
                if k == Enum.KeyCode.Escape then
                    chip.Text = key and key.Name or "—"
                    return
                end
                bindKey(k)
            end
        end))
        function obj:SetKeybind(k) bindKey(toKeyCode(k)) end
    end

    return finishElement(obj, row, title, desc)
end

function Section:Slider(o)
    o = o or {}
    local val = o.Value
    local min, max, default
    if type(val) == "table" then
        min = val.Min or 0
        max = val.Max or 100
        default = val.Default or min
    else
        min = o.Min or 0
        max = o.Max or 100
        default = o.Default or min
    end
    local inc = o.Increment or 1
    local suffix = o.Suffix or ""
    local value = math.clamp(default, min, max)
    local row, header, title, desc = self:_row(o, 290)
    local valueLabel = label({
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -184, 0.5, 0),
        Size = UDim2.fromOffset(64, 20),
        TextXAlignment = Enum.TextXAlignment.Right,
        TextSize = 13,
        TextColor3 = T.SubText,
        Parent = header,
    })
    local hit = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.fromOffset(160, 28),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = header,
    })
    local rail = new("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 9, 0.5, 0),
        Size = UDim2.new(1, -18, 0, 4),
        BackgroundColor3 = Color3.fromRGB(100, 100, 100),
        BorderSizePixel = 0,
        Parent = hit,
    })
    corner(rail, 100)
    local fill = new("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = Alion.Accent,
        BorderSizePixel = 0,
        Parent = rail,
    })
    corner(fill, 100)
    registerAccent(fill)
    local knob = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromOffset(18, 18),
        BackgroundColor3 = Color3.fromRGB(69, 69, 69),
        Parent = rail,
    })
    corner(knob, 100)
    stroke(knob, Color3.fromRGB(110, 110, 110), 1, 0.2)
    local core = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(10, 10),
        BackgroundColor3 = Alion.Accent,
        BorderSizePixel = 0,
        Parent = knob,
    })
    corner(core, 100)
    registerAccent(core)

    local function fmt(v) return tostring(math.floor(v * 1000 + 0.5) / 1000) .. suffix end
    local function render(animate)
        local rel = (value - min) / math.max(max - min, 1e-9)
        local info = animate and ti(0.12, Enum.EasingStyle.Sine) or ti(0)
        tween(fill, info, { Size = UDim2.fromScale(rel, 1) })
        tween(knob, info, { Position = UDim2.fromScale(rel, 0.5) })
        valueLabel.Text = fmt(value)
    end
    render(false)

    local dragging = false
    local obj = { Type = "Slider", Value = value }
    local function set(v, silent)
        v = math.clamp(min + math.floor((v - min) / inc + 0.5) * inc, min, max)
        if v == value and not silent then return end
        value = v
        obj.Value = v
        render(true)
        setFlag(self, o, v)
        if not silent then fire(o.Callback, v) end
    end
    local function fromInput(x)
        local rel = math.clamp((x - rail.AbsolutePosition.X) / math.max(rail.AbsoluteSize.X, 1), 0, 1)
        set(min + rel * (max - min))
    end
    track(hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            tween(core, ti(0.15), { Size = UDim2.fromOffset(8, 8) })
            fromInput(input.Position.X)
        end
    end))
    track(hit.MouseEnter:Connect(function()
        if not dragging then tween(core, ti(0.15), { Size = UDim2.fromOffset(12, 12) }) end
    end))
    track(hit.MouseLeave:Connect(function()
        if not dragging then tween(core, ti(0.15), { Size = UDim2.fromOffset(10, 10) }) end
    end))
    track(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            fromInput(input.Position.X)
        end
    end))
    track(UserInputService.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            tween(core, ti(0.15), { Size = UDim2.fromOffset(10, 10) })
        end
    end))

    function obj:Set(v) set(v) end
    function obj:Get() return value end
    setFlag(self, o, value)
    return finishElement(obj, row, title, desc)
end

function Section:Dropdown(o)
    o = o or {}
    local multi = o.Multi == true
    local options = o.Options or {}
    local selected = {}
    local single = nil
    local def = o.Value ~= nil and o.Value or o.Default
    if multi then
        for _, v in ipairs(def or {}) do selected[v] = true end
    else
        single = def
    end
    local row, header, title, desc = self:_row(o, 214)
    local box = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.fromOffset(180, 32),
        BackgroundColor3 = T.Control,
        Text = "",
        AutoButtonColor = false,
        Parent = header,
    })
    corner(box, 4)
    local boxStroke = stroke(box, T.StrokeLight, 1, 0.5)
    local valueLabel = label({
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -38, 1, 0),
        TextSize = 13,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = box,
    })
    local chevron = icon({
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -10, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        Parent = box,
    }, "chevron-down", Color3.fromRGB(210, 210, 210))
    local list = new("Frame", {
        Name = "List",
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = T.Input,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = 2,
        Parent = row,
    })
    corner(list, 6)
    local scroll = new("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Color3.fromRGB(110, 110, 110),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = list,
    })
    new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = scroll })
    new("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = scroll,
    })

    local entries = {}
    local open = false
    local obj = { Type = "Dropdown" }

    local function isSelected(opt)
        if multi then return selected[opt] == true end
        return single == opt
    end
    local function currentValue()
        if multi then
            local t = {}
            for _, v in ipairs(options) do if selected[v] then table.insert(t, v) end end
            return t
        end
        return single
    end
    local function display()
        if multi then
            local t = currentValue()
            local names = {}
            for _, v in ipairs(t) do table.insert(names, tostring(v)) end
            valueLabel.Text = #names > 0 and table.concat(names, ", ") or "None"
        else
            valueLabel.Text = single ~= nil and tostring(single) or "Select"
        end
        obj.Value = currentValue()
    end
    local function listHeight() return math.min(#options * 34 + 6, 196) end
    local function paint()
        for opt, e in pairs(entries) do
            local sel = isSelected(opt)
            tween(e.Bar, ti(0.25), { Size = UDim2.fromOffset(3, sel and 16 or 0) })
            tween(e.Text, ti(0.25), { TextColor3 = sel and Alion.Accent or T.Text })
            tween(e.Check, ti(0.25), { ImageTransparency = sel and 0 or 1 })
            tween(e.Button, ti(0.2), { BackgroundTransparency = sel and 0.93 or 1 })
        end
    end
    local function setOpen(v)
        open = v
        tween(list, ti(0.35), { Size = UDim2.new(1, 0, 0, v and listHeight() or 0) })
        tween(chevron, ti(0.35), { Rotation = v and 180 or 0 })
        tween(boxStroke, ti(0.25), { Color = v and Alion.Accent or T.StrokeLight, Transparency = v and 0.2 or 0.5 })
    end
    local function choose(opt)
        if multi then selected[opt] = not selected[opt] or nil
        else single = opt setOpen(false) end
        display()
        paint()
        setFlag(self, o, currentValue())
        fire(o.Callback, currentValue())
    end
    local function build()
        for _, e in pairs(entries) do e.Button:Destroy() end
        entries = {}
        for i, opt in ipairs(options) do
            local b = new("TextButton", {
                Name = tostring(opt),
                LayoutOrder = i,
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false,
                Parent = scroll,
            })
            corner(b, 4)
            local bar = new("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 0, 0.5, 0),
                Size = UDim2.fromOffset(3, 0),
                BackgroundColor3 = Alion.Accent,
                BorderSizePixel = 0,
                Parent = b,
            })
            corner(bar, 100)
            registerAccent(bar)
            local txt = label({
                Position = UDim2.fromOffset(14, 0),
                Size = UDim2.new(1, -44, 1, 0),
                Text = tostring(opt),
                TextSize = 13,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = b,
            })
            local check = icon({
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -12, 0.5, 0),
                Size = UDim2.fromOffset(14, 14),
                ImageTransparency = 1,
                Parent = b,
            }, "check", Alion.Accent)
            registerAccent(check, "ImageColor3")
            entries[opt] = { Button = b, Bar = bar, Text = txt, Check = check }
            track(b.MouseEnter:Connect(function()
                if not isSelected(opt) then tween(b, ti(0.15), { BackgroundTransparency = 0.95 }) end
            end))
            track(b.MouseLeave:Connect(function()
                tween(b, ti(0.15), { BackgroundTransparency = isSelected(opt) and 0.93 or 1 })
            end))
            track(b.Activated:Connect(function() choose(opt) end))
        end
        display()
        paint()
        if open then tween(list, ti(0.3), { Size = UDim2.new(1, 0, 0, listHeight()) }) end
    end

    track(box.MouseEnter:Connect(function() tween(box, ti(0.15), { BackgroundColor3 = T.ControlHover }) end))
    track(box.MouseLeave:Connect(function() tween(box, ti(0.15), { BackgroundColor3 = T.Control }) end))
    track(box.Activated:Connect(function() setOpen(not open) end))

    build()

    function obj:Set(v)
        if multi then
            selected = {}
            for _, x in ipairs(v or {}) do selected[x] = true end
        else single = v end
        display()
        paint()
        setFlag(self, o, currentValue())
        fire(o.Callback, currentValue())
    end
    function obj:Get() return currentValue() end
    function obj:Refresh(newOptions, keep)
        options = newOptions or {}
        if not keep then selected = {} single = nil end
        build()
    end
    setFlag(self, o, currentValue())
    return finishElement(obj, row, title, desc)
end

function Section:Input(o)
    o = o or {}
    local width = o.Width or 200
    local row, header, title, desc = self:_row(o, width + 40)
    local box = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.fromOffset(width, 32),
        BackgroundColor3 = T.Input,
        ClipsDescendants = true,
        Parent = header,
    })
    corner(box, 4)
    local boxStroke = stroke(box, T.StrokeLight, 1, 0.4)
    local tb = new("TextBox", {
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -20, 1, -2),
        BackgroundTransparency = 1,
        Text = tostring(o.Value or o.Default or ""),
        PlaceholderText = o.Placeholder or "Type here...",
        PlaceholderColor3 = Color3.fromRGB(125, 125, 125),
        TextColor3 = T.Text,
        Font = Enum.Font.BuilderSans,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = box,
    })
    local line = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.fromScale(0.5, 1),
        Size = UDim2.new(0, 0, 0, 2),
        BackgroundColor3 = Alion.Accent,
        BorderSizePixel = 0,
        Parent = box,
    })
    registerAccent(line)
    track(tb.Focused:Connect(function()
        tween(line, ti(0.35), { Size = UDim2.new(1, 0, 0, 2) })
        tween(boxStroke, ti(0.25), { Transparency = 0, Color = Alion.Accent })
    end))
    track(tb.FocusLost:Connect(function(enter)
        tween(line, ti(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { Size = UDim2.new(0, 0, 0, 2) })
        tween(boxStroke, ti(0.25), { Transparency = 0.4, Color = T.StrokeLight })
        setFlag(self, o, tb.Text)
        fire(o.Callback, tb.Text, enter)
    end))
    if o.Numeric then
        track(tb:GetPropertyChangedSignal("Text"):Connect(function()
            local cleaned = tb.Text:gsub("[^%d%.%-]", "")
            if cleaned ~= tb.Text then tb.Text = cleaned end
        end))
    end
    local obj = { Type = "Textbox" }
    function obj:Set(v) tb.Text = tostring(v) setFlag(self, o, tb.Text) end
    function obj:Get() return tb.Text end
    setFlag(self, o, tb.Text)
    return finishElement(obj, row, title, desc)
end

function Section:Keybind(o)
    o = o or {}
    local key = toKeyCode(o.Value or o.Default or Enum.KeyCode.E)
    local row, header, title, desc = self:_row(o, 170)
    local btn = new("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.fromOffset(120, 32),
        BackgroundColor3 = T.Control,
        Text = key.Name,
        Font = Enum.Font.BuilderSansMedium,
        TextSize = 13,
        TextColor3 = T.Text,
        AutoButtonColor = false,
        Parent = header,
    })
    corner(btn, 4)
    local btnStroke = stroke(btn, T.StrokeLight, 1, 0.5)
    local listening = false
    track(btn.MouseEnter:Connect(function() tween(btn, ti(0.15), { BackgroundColor3 = T.ControlHover }) end))
    track(btn.MouseLeave:Connect(function() tween(btn, ti(0.15), { BackgroundColor3 = T.Control }) end))
    track(btn.Activated:Connect(function()
        listening = true
        btn.Text = "Press a key..."
        tween(btnStroke, ti(0.2), { Color = Alion.Accent, Transparency = 0 })
    end))
    local obj = { Type = "Keybind", Value = key }
    track(UserInputService.InputBegan:Connect(function(input, processed)
        if listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                if input.KeyCode ~= Enum.KeyCode.Escape then
                    key = input.KeyCode
                    obj.Value = key
                    setFlag(self, o, key)
                    fire(o.Callback, key)
                end
                btn.Text = key.Name
                tween(btnStroke, ti(0.2), { Color = T.StrokeLight, Transparency = 0.5 })
            end
        elseif input.KeyCode == key then
            if UserInputService:GetFocusedTextBox() then return end
            fire(o.Callback, key)
            if o.OnPress then fire(o.OnPress) end
        end
    end))
    function obj:Set(k)
        key = toKeyCode(k)
        obj.Value = key
        btn.Text = key.Name
        setFlag(self, o, key)
    end
    function obj:Get() return key end
    setFlag(self, o, key)
    return finishElement(obj, row, title, desc)
end

function Section:ColorPicker(o)
    o = o or {}
    local order = (self._order or 0) + 1
    self._order = order
    local current = o.Default or o.Value or Alion.Accent
    local initial = current
    local h, s, v = Color3.toHSV(current)
    local expanded = false

    local HEAD_H  = 50
    local SQ_H    = 130
    local HUE_H   = 14
    local HEX_H   = 26
    local BODY_PAD = 12
    local SPACING  = 8
    local BODY_H   = BODY_PAD * 2 + SQ_H + SPACING + HUE_H + SPACING + HEX_H

    local row = new("Frame", {
        Name = "ColorRow",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = order,
        Parent = self.Body,
    })
    new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = row })
    if order > 1 then
        new("Frame", {
            Name = "Divider",
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = T.Divider,
            BorderSizePixel = 0,
            LayoutOrder = 0,
            Parent = row,
        })
    end

    local header = new("TextButton", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, HEAD_H),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = 1,
        Parent = row,
    })
    track(header.MouseEnter:Connect(function()
        if not expanded then tween(header, ti(0.15), { BackgroundTransparency = 0.96 }) end
    end))
    track(header.MouseLeave:Connect(function()
        if not expanded then tween(header, ti(0.15), { BackgroundTransparency = 1 }) end
    end))

    local x = 16
    if o.Icon then
        icon({
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 16, 0.5, 0),
            Size = UDim2.fromOffset(20, 20),
            ImageColor3 = Color3.fromRGB(215, 215, 215),
            Parent = header,
        }, o.Icon)
        x = 48
    end
    local titleLbl = label({
        Position = UDim2.fromOffset(x, o.Desc and 11 or 0),
        Size = o.Desc and UDim2.new(1, -(x + 130), 0, 18) or UDim2.new(1, -(x + 130), 1, 0),
        Text = o.Title or "Color",
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = header,
    })
    local descLbl
    if o.Desc then
        descLbl = label({
            Position = UDim2.fromOffset(x, 31),
            Size = UDim2.new(1, -(x + 130), 0, 18),
            Text = o.Desc,
            Font = Enum.Font.BuilderSans,
            TextSize = 12,
            TextColor3 = T.SubText,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = header,
        })
    end

    local preview = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -46, 0.5, 0),
        Size = UDim2.fromOffset(56, 24),
        BackgroundColor3 = current,
        Parent = header,
    })
    corner(preview, 4)
    stroke(preview, T.StrokeLight, 1, 0.3)

    local arrowWrap = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        BackgroundTransparency = 1,
        Parent = header,
    })
    local arrow = icon({
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(14, 14),
        Parent = arrowWrap,
    }, "chevron-down", Color3.fromRGB(210, 210, 210))

    local body = new("Frame", {
        Name = "Body",
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = T.Input,
        BackgroundTransparency = 0.15,
        ClipsDescendants = true,
        LayoutOrder = 2,
        Parent = row,
    })
    corner(body, 6)
    stroke(body, T.Stroke, 1, 0.35)

    local satSquare = new("Frame", {
        Size = UDim2.new(1, -BODY_PAD * 2, 0, SQ_H),
        Position = UDim2.new(0, BODY_PAD, 0, BODY_PAD),
        BackgroundColor3 = Color3.fromHSV(h, 1, 1),
        BorderSizePixel = 0,
        Active = true,
        Parent = body,
    })
    corner(satSquare, 4)

    local whiteLayer = new("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Parent = satSquare,
    })
    corner(whiteLayer, 4)
    new("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Parent = whiteLayer,
    })

    local blackLayer = new("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        Parent = satSquare,
    })
    corner(blackLayer, 4)
    new("UIGradient", {
        Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        }),
        Parent = blackLayer,
    })

    local satCursor = new("Frame", {
        Size = UDim2.fromOffset(12, 12),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(s, 0, 1 - v, 0),
        BackgroundTransparency = 1,
        ZIndex = 5,
        Parent = satSquare,
    })
    corner(satCursor, 100)
    stroke(satCursor, Color3.new(1, 1, 1), 2, 0)
    stroke(satCursor, Color3.new(0, 0, 0), 1, 0.5)

    local hueSlider = new("Frame", {
        Size = UDim2.new(1, -BODY_PAD * 2, 0, HUE_H),
        Position = UDim2.new(0, BODY_PAD, 0, BODY_PAD + SQ_H + SPACING),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Active = true,
        Parent = body,
    })
    corner(hueSlider, 100)
    new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0 / 6, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(1 / 6, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(2 / 6, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(3 / 6, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(4 / 6, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(5 / 6, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(6 / 6, Color3.fromRGB(255, 0, 0)),
        }),
        Parent = hueSlider,
    })

    local hueCursor = new("Frame", {
        Size = UDim2.new(0, 4, 1, 6),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(h, 0, 0.5, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = hueSlider,
    })
    corner(hueCursor, 100)
    stroke(hueCursor, Color3.new(0, 0, 0), 1, 0.4)

    local hexBox = new("TextBox", {
        Size = UDim2.new(1, -BODY_PAD * 2 - 92, 0, HEX_H),
        Position = UDim2.new(0, BODY_PAD, 0, BODY_PAD + SQ_H + SPACING + HUE_H + SPACING),
        BackgroundColor3 = T.Control,
        BorderSizePixel = 0,
        Text = string.format("#%02X%02X%02X",
            math.floor(current.R * 255),
            math.floor(current.G * 255),
            math.floor(current.B * 255)),
        TextColor3 = T.Text,
        TextSize = 13,
        Font = Enum.Font.BuilderSansMedium,
        ClearTextOnFocus = false,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = body,
    })
    corner(hexBox, 4)
    local hbStroke = stroke(hexBox, T.Stroke, 1, 0.4)
    new("UIPadding", { PaddingLeft = UDim.new(0, 10), Parent = hexBox })

    local resetBtn = new("TextButton", {
        Size = UDim2.new(0, 84, 0, HEX_H),
        Position = UDim2.new(1, -BODY_PAD - 84, 0, BODY_PAD + SQ_H + SPACING + HUE_H + SPACING),
        BackgroundColor3 = T.Control,
        BorderSizePixel = 0,
        Text = "Reset",
        Font = Enum.Font.BuilderSansMedium,
        TextSize = 13,
        TextColor3 = T.Text,
        AutoButtonColor = false,
        Parent = body,
    })
    corner(resetBtn, 4)
    local rbStroke = stroke(resetBtn, T.Stroke, 1, 0.4)
    track(resetBtn.MouseEnter:Connect(function()
        tween(resetBtn, ti(0.15), { BackgroundColor3 = T.ControlHover })
        tween(rbStroke, ti(0.15), { Color = Alion.Accent, Transparency = 0.2 })
    end))
    track(resetBtn.MouseLeave:Connect(function()
        tween(resetBtn, ti(0.15), { BackgroundColor3 = T.Control })
        tween(rbStroke, ti(0.15), { Color = T.Stroke, Transparency = 0.4 })
    end))

    local magnifier

    local function hexText()
        return string.format("#%02X%02X%02X",
            math.floor(current.R * 255),
            math.floor(current.G * 255),
            math.floor(current.B * 255))
    end

    local function refreshAll()
        satSquare.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        satCursor.Position = UDim2.new(s, 0, 1 - v, 0)
        hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
        preview.BackgroundColor3 = current
        hexBox.Text = hexText()
    end

    local function showMagnifier()
        if not magnifier then
            local sg = Alion._gui
            if not sg or not sg.Parent then return end
            magnifier = new("Frame", {
                Name = "AlionPickerMagnifier",
                Size = UDim2.new(0, 0, 0, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = current,
                BorderSizePixel = 0,
                ZIndex = 500,
                Parent = sg,
            })
            corner(magnifier, 100)
            stroke(magnifier, Color3.new(1, 1, 1), 2, 0)
            TweenService:Create(magnifier, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 90, 0, 90),
            }):Play()
        end
        if magnifier and magnifier.Parent then
            magnifier.BackgroundColor3 = current
            local mp = UserInputService:GetMouseLocation()
            magnifier.Position = UDim2.new(0, mp.X, 0, mp.Y - 78)
        end
    end

    local function hideMagnifier()
        if magnifier then
            local m = magnifier
            magnifier = nil
            TweenService:Create(m, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
            }):Play()
            task.delay(0.25, function()
                if m and m.Parent then pcall(function() m:Destroy() end) end
            end)
        end
    end

    local draggingSat, draggingHue = false, false

    local function updateFromSat(input)
        if not satSquare.Parent then return end
        local relX = math.clamp((input.Position.X - satSquare.AbsolutePosition.X) / satSquare.AbsoluteSize.X, 0, 1)
        local relY = math.clamp((input.Position.Y - satSquare.AbsolutePosition.Y) / satSquare.AbsoluteSize.Y, 0, 1)
        s = relX
        v = 1 - relY
        current = Color3.fromHSV(h, s, v)
        refreshAll()
        fire(o.Callback, current)
    end

    local function updateFromHue(input)
        if not hueSlider.Parent then return end
        local relX = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
        h = relX
        current = Color3.fromHSV(h, s, v)
        refreshAll()
        fire(o.Callback, current)
    end

    track(satSquare.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingSat = true
            updateFromSat(input)
            showMagnifier()
        end
    end))

    track(hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingHue = true
            updateFromHue(input)
        end
    end))

    track(UserInputService.InputChanged:Connect(function(input)
        if draggingSat and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromSat(input)
            showMagnifier()
        end
        if draggingHue and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromHue(input)
        end
    end))

    track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if draggingSat then draggingSat = false hideMagnifier() end
            if draggingHue then draggingHue = false end
        end
    end))

    track(hexBox.Focused:Connect(function() tween(hbStroke, ti(0.15), { Color = Alion.Accent, Transparency = 0 }) end))
    track(hexBox.FocusLost:Connect(function()
        tween(hbStroke, ti(0.15), { Color = T.Stroke, Transparency = 0.4 })
        local hex = hexBox.Text:gsub("#", "")
        if #hex == 6 then
            local rn = tonumber(hex:sub(1, 2), 16)
            local gn = tonumber(hex:sub(3, 4), 16)
            local bn = tonumber(hex:sub(5, 6), 16)
            if rn and gn and bn then
                current = Color3.fromRGB(rn, gn, bn)
                h, s, v = Color3.toHSV(current)
                refreshAll()
                fire(o.Callback, current)
            end
        end
    end))

    local function setExpanded(state)
        expanded = state
        local target = expanded and BODY_H or 0
        tween(body, ti(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), { Size = UDim2.new(1, 0, 0, target) })
        tween(arrow, ti(0.3), { Rotation = expanded and 180 or 0 })
    end

    track(header.Activated:Connect(function() setExpanded(not expanded) end))
    track(resetBtn.Activated:Connect(function()
        current = initial
        h, s, v = Color3.toHSV(current)
        refreshAll()
        fire(o.Callback, current)
    end))

    refreshAll()

    local obj = { Type = "ColorPicker", Value = current }
    function obj:Get() return current end
    function obj:Set(c)
        current = c
        h, s, v = Color3.toHSV(c)
        refreshAll()
        fire(o.Callback, c)
    end
    function obj:SetDefault(c) initial = c end
    function obj:Reset() obj:Set(initial) end
    function obj:Expand() if not expanded then setExpanded(true) end end
    function obj:Collapse() if expanded then setExpanded(false) end end
    return finishElement(obj, row, titleLbl, descLbl)
end

function Tab:Toggle(o) return self:Section({}).Toggle(self:Section({}), o) end

local function wrapTabShortcuts(tab)
    local function use(o)
        if not tab._currentSection then
            tab:Section({})
        end
        return tab._currentSection
    end
    tab.Toggle      = function(_, o) return use().Toggle(use(), o) end
    tab.Dropdown    = function(_, o) return use().Dropdown(use(), o) end
    tab.Slider      = function(_, o) return use().Slider(use(), o) end
    tab.Keybind     = function(_, o) return use().Keybind(use(), o) end
    tab.Button      = function(_, o) return use().Button(use(), o) end
    tab.Input       = function(_, o) return use().Input(use(), o) end
    tab.ColorPicker = function(_, o) return use().ColorPicker(use(), o) end
    tab.Label       = function(_, o) return use().Label(use(), o) end
end

local originalTab = Window.Tab
function Window:Tab(opts)
    local t = originalTab(self, opts)
    t.Toggle      = function(self2, o) return self2:Section({}).Toggle(self2._currentSection, o) end
    t.Dropdown    = function(self2, o) return self2._currentSection.Dropdown(self2._currentSection, o) end
    t.Slider      = function(self2, o) return self2._currentSection.Slider(self2._currentSection, o) end
    t.Keybind     = function(self2, o) return self2._currentSection.Keybind(self2._currentSection, o) end
    t.Button      = function(self2, o) return self2._currentSection.Button(self2._currentSection, o) end
    t.Input       = function(self2, o) return self2._currentSection.Input(self2._currentSection, o) end
    t.ColorPicker = function(self2, o) return self2._currentSection.ColorPicker(self2._currentSection, o) end
    t.Label       = function(self2, o) return self2._currentSection.Label(self2._currentSection, o) end

    local origSection = t.Section
    t.Section = function(self2, opts2)
        local s = origSection(self2, opts2)
        return s
    end

    function t:Toggle2() end
    return t
end

function Tab:__call(o) return self:Section(o) end

local mt = getmetatable(Tab)
Tab.__call = nil

function Tab.Toggle(self, o)
    if not self._currentSection then self:Section({}) end
    return self._currentSection.Toggle(self._currentSection, o)
end

function Tab.Dropdown(self, o)
    if not self._currentSection then self:Section({}) end
    return self._currentSection.Dropdown(self._currentSection, o)
end

function Tab.Slider(self, o)
    if not self._currentSection then self:Section({}) end
    return self._currentSection.Slider(self._currentSection, o)
end

function Tab.Keybind(self, o)
    if not self._currentSection then self:Section({}) end
    return self._currentSection.Keybind(self._currentSection, o)
end

function Tab.Button(self, o)
    if not self._currentSection then self:Section({}) end
    return self._currentSection.Button(self._currentSection, o)
end

function Tab.Input(self, o)
    if not self._currentSection then self:Section({}) end
    return self._currentSection.Input(self._currentSection, o)
end

function Tab.ColorPicker(self, o)
    if not self._currentSection then self:Section({}) end
    return self._currentSection.ColorPicker(self._currentSection, o)
end

function Tab.Label(self, o)
    if not self._currentSection then self:Section({}) end
    return self._currentSection.Label(self._currentSection, o)
end

if getgenv then getgenv().Alion = Alion end

return Alion
