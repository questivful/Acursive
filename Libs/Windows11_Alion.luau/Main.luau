local Alion = {}
Alion.Version = "2.0.2"
Alion.__index = Alion

if getgenv and type(getgenv().Alion) == "table" and getgenv().Alion.Cleanup then
    pcall(function() getgenv().Alion:Cleanup() end)
    task.wait(0.1)
end

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

local ICON_SHEET = "rbxassetid://89989658646441"
local ICON_NAMES = {
    "home", "sliders", "user", "search", "sword", "eye", "globe", "folder",
    "info", "close", "minimize", "check", "chevron-down", "chevron-up", "chevron-right", "chevron-left",
    "plus", "square", "star", "heart", "bell", "lock", "palette", "code",
    "bolt", "drop", "shield", "cursor", "keyboard", "list", "trash", "refresh",
    "moon", "sun", "copy", "key", "bookmark", "target", "layers", "edit",
    "settings", "zap", "gauge", "gear", "grid", "rotate", "camera", "play",
}
local ICON_CELL = 64
local ICON_COLS = 8
local ICON_INDEX = {}
for i, name in ipairs(ICON_NAMES) do ICON_INDEX[name] = i - 1 end

local ThemePresets = {
    Dark = {
        Name = "Dark",
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
        Nav          = Color3.fromRGB(24, 24, 24),
    },
    Light = {
        Name = "Light",
        Background   = Color3.fromRGB(243, 243, 243),
        Card         = Color3.fromRGB(255, 255, 255),
        CardTrans    = 0.00,
        Control      = Color3.fromRGB(240, 240, 240),
        ControlHover = Color3.fromRGB(226, 226, 226),
        Input        = Color3.fromRGB(251, 251, 251),
        Stroke       = Color3.fromRGB(216, 216, 216),
        StrokeLight  = Color3.fromRGB(186, 186, 186),
        Divider      = Color3.fromRGB(232, 232, 232),
        Text         = Color3.fromRGB(28, 28, 28),
        SubText      = Color3.fromRGB(96, 96, 96),
        Muted        = Color3.fromRGB(140, 140, 140),
        Accent       = Color3.fromRGB(0, 120, 212),
        AccentText   = Color3.fromRGB(255, 255, 255),
        Danger       = Color3.fromRGB(196, 43, 28),
        Nav          = Color3.fromRGB(250, 250, 250),
    },
    Midnight = {
        Name = "Midnight",
        Background   = Color3.fromRGB(15, 17, 26),
        Card         = Color3.fromRGB(24, 27, 40),
        CardTrans    = 0.05,
        Control      = Color3.fromRGB(34, 38, 56),
        ControlHover = Color3.fromRGB(44, 49, 71),
        Input        = Color3.fromRGB(12, 14, 22),
        Stroke       = Color3.fromRGB(46, 52, 76),
        StrokeLight  = Color3.fromRGB(72, 82, 118),
        Divider      = Color3.fromRGB(34, 38, 56),
        Text         = Color3.fromRGB(232, 236, 248),
        SubText      = Color3.fromRGB(150, 160, 190),
        Muted        = Color3.fromRGB(100, 110, 140),
        Accent       = Color3.fromRGB(94, 154, 255),
        AccentText   = Color3.fromRGB(255, 255, 255),
        Danger       = Color3.fromRGB(220, 70, 70),
        Nav          = Color3.fromRGB(11, 13, 20),
    },
    Nord = {
        Name = "Nord",
        Background   = Color3.fromRGB(46, 52, 64),
        Card         = Color3.fromRGB(59, 66, 82),
        CardTrans    = 0.05,
        Control      = Color3.fromRGB(67, 76, 94),
        ControlHover = Color3.fromRGB(76, 86, 106),
        Input        = Color3.fromRGB(36, 41, 51),
        Stroke       = Color3.fromRGB(76, 86, 106),
        StrokeLight  = Color3.fromRGB(94, 106, 130),
        Divider      = Color3.fromRGB(67, 76, 94),
        Text         = Color3.fromRGB(236, 239, 244),
        SubText      = Color3.fromRGB(180, 190, 205),
        Muted        = Color3.fromRGB(130, 140, 155),
        Accent       = Color3.fromRGB(136, 192, 208),
        AccentText   = Color3.fromRGB(46, 52, 64),
        Danger       = Color3.fromRGB(191, 97, 106),
        Nav          = Color3.fromRGB(40, 45, 56),
    },
    Rose = {
        Name = "Rose",
        Background   = Color3.fromRGB(30, 20, 25),
        Card         = Color3.fromRGB(42, 28, 35),
        CardTrans    = 0.05,
        Control      = Color3.fromRGB(56, 38, 47),
        ControlHover = Color3.fromRGB(70, 48, 58),
        Input        = Color3.fromRGB(24, 16, 20),
        Stroke       = Color3.fromRGB(78, 52, 62),
        StrokeLight  = Color3.fromRGB(108, 74, 88),
        Divider      = Color3.fromRGB(56, 38, 47),
        Text         = Color3.fromRGB(245, 232, 238),
        SubText      = Color3.fromRGB(190, 165, 178),
        Muted        = Color3.fromRGB(140, 118, 130),
        Accent       = Color3.fromRGB(232, 106, 148),
        AccentText   = Color3.fromRGB(30, 20, 25),
        Danger       = Color3.fromRGB(220, 70, 90),
        Nav          = Color3.fromRGB(24, 16, 20),
    },
}

local T = {}
for k, v in pairs(ThemePresets.Dark) do T[k] = v end

Alion.Theme          = T
Alion.Themes         = ThemePresets
Alion.Accent         = T.Accent
Alion._gui           = nil
Alion._connections   = {}
Alion._keybinds      = {}
Alion._accentBindings = {}
Alion._themeBindings = {}
Alion._notifCounter  = 0
Alion._notifLower    = false
Alion._capturingKeybind = nil
Alion._activeTheme   = "Dark"
Alion._customAccent  = nil
Alion._windows       = {}

Alion.Settings = {
    Theme           = "Dark",
    NavPosition     = "Left",
    ShowProfile     = true,
    ShowFooter      = true,
    Transparency    = 0.06,
    Scale           = 1,
    ShowSettingsTab = true,
}

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

local function registerTheme(inst, prop, key)
    table.insert(Alion._themeBindings, { inst = inst, prop = prop, key = key })
end

local function applyAccentColor(color)
    Alion.Accent = color
    for _, b in ipairs(Alion._accentBindings) do
        if b.fn then pcall(b.fn)
        elseif b.inst and b.inst.Parent then pcall(function() b.inst[b.prop] = color end) end
    end
end

local function applyTheme(name, keepAccent)
    local preset = ThemePresets[name]
    if not preset then return end
    Alion._activeTheme = name
    Alion.Settings.Theme = name
    for k, v in pairs(preset) do
        if k ~= "Accent" or not keepAccent then T[k] = v end
    end
    if not keepAccent then
        T.Accent = preset.Accent
        Alion.Accent = preset.Accent
    else
        T.Accent = Alion.Accent
    end
    for _, b in ipairs(Alion._themeBindings) do
        if b.inst and b.inst.Parent and T[b.key] ~= nil then
            pcall(function() b.inst[b.prop] = T[b.key] end)
        end
    end
    if not keepAccent then applyAccentColor(T.Accent) end
    for _, w in ipairs(Alion._windows) do
        if w and w._refreshTheme then pcall(w._refreshTheme, w) end
    end
end

function Alion:SetAccent(color)
    Alion._customAccent = color
    applyAccentColor(color)
end
function Alion:GetAccent() return Alion.Accent end
function Alion:SetTheme(name, keepAccent)
    applyTheme(name, keepAccent)
end
function Alion:GetTheme() return Alion._activeTheme end
function Alion:GetThemeList()
    local t = {}
    for k in pairs(ThemePresets) do table.insert(t, k) end
    table.sort(t)
    return t
end
function Alion:SetNotificationLower(v) self._notifLower = v and true or false end

function Alion:Cleanup()
    for _, c in ipairs(self._connections or {}) do pcall(function() c:Disconnect() end) end
    self._connections = {}
    self._keybinds = {}
    self._accentBindings = {}
    self._themeBindings = {}
    self._capturingKeybind = nil
    self._windows = {}
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
        BackgroundColor3 = T.Card,
        BackgroundTransparency = 0.06,
        Parent = wrap,
    })
    corner(card, 8)
    local cs = stroke(card, T.Stroke, 1, 0.15)
    registerTheme(card, "BackgroundColor3", "Card")
    registerTheme(cs, "Color", "Stroke")
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
    local bodyLbl = label({
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
    registerTheme(bodyLbl, "TextColor3", "SubText")
    local rail = new("Frame", {
        Position = UDim2.new(0, 12, 1, -6),
        Size = UDim2.new(1, -24, 0, 2),
        BackgroundColor3 = T.Divider,
        BorderSizePixel = 0,
        Parent = card,
    })
    registerTheme(rail, "BackgroundColor3", "Divider")
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

local function sanitizeCharacterClone(clone)
    if not clone then return nil end
    local ok = pcall(function()
        for _, d in ipairs(clone:GetDescendants()) do
            if d:IsA("BaseScript") then d:Destroy() end
            if d:IsA("BasePart") then
                d.Anchored = true
                d.CanCollide = false
            end
        end
    end)
    if not ok then return nil end
    return clone
end

local function centerModel(clone, mode)
    if not clone then return end
    if mode == "Head" then
        local head = clone:FindFirstChild("Head")
        if head and head:IsA("BasePart") then
            for _, d in ipairs(clone:GetDescendants()) do
                if d:IsA("BasePart") and d ~= head then
                    d.Transparency = 1
                end
            end
            pcall(function() clone:PivotTo(head.CFrame - head.Position) end)
        end
    else
        local ok, bcf = pcall(function() return clone:GetBoundingBox() end)
        if ok and bcf then
            local pivot = clone:GetPivot()
            pcall(function() clone:PivotTo(pivot + (Vector3.zero - bcf.Position)) end)
        end
    end
end

local function buildFromModel(world, model, mode)
    if not model or not model.Parent then return nil end
    local ok, clone = pcall(function() return model:Clone() end)
    if not ok or not clone then return nil end
    clone = sanitizeCharacterClone(clone)
    if not clone then return nil end
    clone.Parent = world
    centerModel(clone, mode)
    return clone
end

local function buildFromUserId(world, userId, mode)
    local rigs = { Enum.HumanoidRigType.R15, Enum.HumanoidRigType.R6 }
    for _, rig in ipairs(rigs) do
        local ok, desc = pcall(function() return Players:GetHumanoidDescriptionFromUserId(userId) end)
        if ok and desc then
            local ok2, model = pcall(function() return Players:CreateHumanoidModelFromDescription(desc, rig) end)
            if ok2 and model then
                local result = buildFromModel(world, model, mode)
                pcall(function() model:Destroy() end)
                if result then return result end
            end
        end
    end
    return nil
end

local function buildCharacterInto(world, target, mode)
    if not target then return nil end

    if typeof(target) == "Instance" then
        if target:IsA("Player") then
            local char = target.Character
            if not char then return nil end
            return buildFromModel(world, char, mode)
        end
        if target:IsA("Model") then
            return buildFromModel(world, target, mode)
        end
        return nil
    end

    if type(target) == "number" then
        local plr = Players:GetPlayerByUserId(target)
        if plr and plr.Character then
            return buildFromModel(world, plr.Character, mode)
        end
        return buildFromUserId(world, target, mode)
    end

    return nil
end

local function lightPoints(world)
    local function add(cf, color, brightness, range)
        local p = new("Part", {
            Size = Vector3.new(0.1, 0.1, 0.1),
            Transparency = 1,
            Anchored = true,
            CanCollide = false,
            CanQuery = false,
            CanTouch = false,
            CFrame = cf,
            Parent = world,
        })
        new("PointLight", {
            Color = color,
            Brightness = brightness,
            Range = range,
            Shadows = true,
            Parent = p,
        })
    end
    add(CFrame.new(5, 7, 6),  Color3.fromRGB(255, 235, 205), 4, 30)
    add(CFrame.new(-6, 3, 4), Color3.fromRGB(155, 185, 255), 2, 30)
    add(CFrame.new(0, 5, -7), Color3.fromRGB(255, 255, 255), 3, 30)
end

local function makeCharacterViewport(props)
    props = props or {}
    local mode = props.Mode or "Full"
    local spin = props.Spin ~= false
    local spinSpeed = props.SpinSpeed or 40
    local fov = props.FOV or (mode == "Head" and 22 or 30)
    local startAngle = props.StartAngle or math.pi

    local vpf = new("ViewportFrame", {
        Name = "AlionViewport",
        Size = props.Size or UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Ambient = Color3.fromRGB(115, 115, 115),
        LightColor = Color3.fromRGB(255, 250, 238),
        LightDirection = Vector3.new(-0.45, -1, -0.35).Unit,
        Parent = props.Parent,
    })
    local world = new("WorldModel", { Parent = vpf })
    local cam = new("Camera", { FieldOfView = fov, Parent = vpf })
    vpf.CurrentCamera = cam
    lightPoints(world)

    local model = buildCharacterInto(world, props.Target or LocalPlayer, mode)
    local dist = props.Distance
    if not dist and model then
        local ok, _, size = pcall(function() return model:GetBoundingBox() end)
        if ok and size then
            local maxDim = math.max(size.X, size.Y, size.Z)
            if maxDim > 0 then
                dist = (maxDim * 0.5) / math.tan(math.rad(fov * 0.5)) * 1.25
            end
        end
    end
    dist = dist or 12
    local height = props.LookHeight or (mode == "Head" and 0 or 0.2)

    local angle = startAngle
    local spinConn
    if spin then
        spinConn = RunService.RenderStepped:Connect(function(dt)
            if not vpf.Parent then return end
            angle = angle + dt * math.rad(spinSpeed)
            local x = math.sin(angle) * dist
            local z = math.cos(angle) * dist
            cam.CFrame = CFrame.lookAt(Vector3.new(x, height + 0.15, z), Vector3.new(0, height, 0))
        end)
    else
        local x = math.sin(angle) * dist
        local z = math.cos(angle) * dist
        cam.CFrame = CFrame.lookAt(Vector3.new(x, height + 0.15, z), Vector3.new(0, height, 0))
    end

    local api = { Instance = vpf, World = world, Camera = cam, Conn = spinConn }
    function api:Destroy()
        if spinConn then spinConn:Disconnect() end
        if vpf.Parent then vpf:Destroy() end
    end
    function api:SetTarget(target)
        if model and model.Parent then model:Destroy() end
        model = buildCharacterInto(world, target, mode)
        if model then
            local ok, _, size = pcall(function() return model:GetBoundingBox() end)
            if ok and size then
                local maxDim = math.max(size.X, size.Y, size.Z)
                if maxDim > 0 then
                    dist = (maxDim * 0.5) / math.tan(math.rad(fov * 0.5)) * 1.25
                end
            end
        end
    end
    function api:SetSpeed(v) spinSpeed = v end
    return api
end

local Window = {}
Window.__index = Window
local Tab = {}
Tab.__index = Tab
local Section = {}
Section.__index = Section

local function makeDraggable(win, handles)
    if win._dragConns then
        for _, c in ipairs(win._dragConns) do pcall(function() c:Disconnect() end) end
    end
    win._dragConns = {}

    local dragging, dragStart, startPos
    for _, handle in ipairs(handles) do
        if handle then
            table.insert(win._dragConns, handle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    dragStart = input.Position
                    startPos = win.Root.Position
                end
            end))
        end
    end
    table.insert(win._dragConns, UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            tween(win.Root, TweenInfo.new(0.08, Enum.EasingStyle.Sine), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y),
            })
        end
    end))
    table.insert(win._dragConns, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
end

local function styleNav(tab, active)
    tween(tab.NavBtn, ti(0.25), { BackgroundTransparency = active and 0.90 or 1 })
    tween(tab.NavIcon, ti(0.25), { ImageColor3 = active and Alion.Accent or T.SubText })
    tween(tab.NavName, ti(0.25), { TextColor3 = active and T.Text or T.SubText })
end

function Alion:CreateWindow(opts)
    opts = opts or {}
    local gui = getGui()
    local camera = workspace.CurrentCamera
    local vp = camera and camera.ViewportSize or Vector2.new(1280, 720)
    local size = opts.Size
    local width = size and size.X.Offset or math.min(660, vp.X - 40)
    local height = size and size.Y.Offset or math.min(540, vp.Y - 40)

    local win = setmetatable({
        Tabs = {},
        Flags = {},
        ToggleKey = toKeyCode(opts.ToggleKey or Enum.KeyCode.RightShift),
        _open = false,
        _token = 0,
        _destroyed = false,
        _opts = opts,
        _navPos = Alion.Settings.NavPosition,
        _showProfile = Alion.Settings.ShowProfile,
        _showFooter = Alion.Settings.ShowFooter,
        _showSettingsTab = (opts.Settings ~= false) and Alion.Settings.ShowSettingsTab,
        _transparency = Alion.Settings.Transparency,
        _rootScale = Alion.Settings.Scale,
        Size = Vector2.new(width, height),
    }, Window)

    table.insert(Alion._windows, win)

    local root = new("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.fromOffset(width, height),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = gui,
    })
    local scale = new("UIScale", { Scale = 0.9 * win._rootScale, Parent = root })
    local body = new("Frame", {
        Name = "Body",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = T.Background,
        BackgroundTransparency = 1,
        Parent = root,
    })
    corner(body, 8)
    local bodyStroke = stroke(body, T.StrokeLight, 1, 1)
    local bodyShadow = shadow(body, 40, 14, 1)
    local content = new("CanvasGroup", {
        Name = "Content",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        GroupTransparency = 1,
        Parent = body,
    })
    corner(content, 8)
    registerTheme(body, "BackgroundColor3", "Background")
    registerTheme(bodyStroke, "Color", "StrokeLight")

    win.Root = root
    win.Scale = scale
    win.Body = body
    win.BodyStroke = bodyStroke
    win.Shadow = bodyShadow
    win.Content = content
    win.NavItems = {}

    function win:_refreshTheme()
        self:_layout()
    end

    function win:_layout()
        if self._destroyed then return end

        local keepPages = self.Pages
        for _, c in ipairs(content:GetChildren()) do
            if c ~= keepPages then c:Destroy() end
        end
        self.NavItems = {}

        local pos = self._navPos or "Left"
        local showProfile = self._showProfile
        local showFooter = self._showFooter

        local sidebarW, navH = 216, 56
        local profileFrame
        local navFrame

        if pos == "Left" then
            profileFrame = new("Frame", {
                Name = "Sidebar",
                Size = UDim2.new(0, sidebarW, 1, 0),
                BackgroundTransparency = 1,
                Parent = content,
            })
            new("Frame", {
                Size = UDim2.new(1, 0, 0, 72),
                BackgroundTransparency = 1,
                Active = true,
                Parent = profileFrame,
            })
            if showProfile then
                local avatar = new("ImageLabel", {
                    Size = UDim2.fromOffset(40, 40),
                    Position = UDim2.fromOffset(16, 16),
                    BackgroundColor3 = T.Control,
                    Image = "",
                    Parent = profileFrame,
                })
                corner(avatar, 100)
                local avStroke = stroke(avatar, T.StrokeLight, 1, 0.3)
                registerTheme(avatar, "BackgroundColor3", "Control")
                registerTheme(avStroke, "Color", "StrokeLight")
                task.spawn(function()
                    local ok, img = pcall(function()
                        return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                    end)
                    if ok and avatar.Parent then avatar.Image = img end
                end)
                local nameLbl = label({
                    Position = UDim2.fromOffset(64, 16), Size = UDim2.new(1, -76, 0, 20),
                    Text = LocalPlayer.DisplayName, Font = Enum.Font.BuilderSansBold, TextSize = 15,
                    TextTruncate = Enum.TextTruncate.AtEnd, Parent = profileFrame,
                })
                local subLbl = label({
                    Position = UDim2.fromOffset(64, 36), Size = UDim2.new(1, -76, 0, 18),
                    Text = opts.Title or "Alion", Font = Enum.Font.BuilderSans, TextSize = 12,
                    TextColor3 = T.SubText, TextTruncate = Enum.TextTruncate.AtEnd, Parent = profileFrame,
                })
                registerTheme(nameLbl, "TextColor3", "Text")
                registerTheme(subLbl, "TextColor3", "SubText")
            end
            navFrame = new("Frame", {
                Name = "Nav",
                Position = UDim2.fromOffset(8, 80),
                Size = UDim2.new(1, -16, 1, showFooter and -124 or -92),
                BackgroundTransparency = 1,
                Parent = profileFrame,
            })
            self.Indicator = new("Frame", {
                Size = UDim2.fromOffset(3, 16),
                Position = UDim2.fromOffset(0, 11),
                BackgroundColor3 = Alion.Accent,
                BorderSizePixel = 0, Visible = false, ZIndex = 5,
                Parent = navFrame,
            })
            corner(self.Indicator, 100)
            registerAccent(self.Indicator)
            if showFooter then
                local fl = label({
                    Position = UDim2.new(0, 16, 1, -34), Size = UDim2.new(1, -32, 0, 18),
                    Text = "Alion v" .. Alion.Version, Font = Enum.Font.BuilderSans, TextSize = 12,
                    TextColor3 = T.Muted, Parent = profileFrame,
                })
                registerTheme(fl, "TextColor3", "Muted")
            end
        else
            navFrame = new("Frame", {
                Name = "TopBar",
                Position = (pos == "Top") and UDim2.fromOffset(0, 0) or UDim2.new(0, 0, 1, -navH),
                Size = UDim2.new(1, 0, 0, navH),
                BackgroundColor3 = T.Nav, BackgroundTransparency = 0.15,
                Parent = content,
            })
            registerTheme(navFrame, "BackgroundColor3", "Nav")
            local nvStroke = stroke(navFrame, T.Divider, 1, 0.4)
            registerTheme(nvStroke, "Color", "Divider")

            local navScroll = new("ScrollingFrame", {
                Position = UDim2.fromOffset(showProfile and 210 or 12, 0),
                Size = UDim2.new(1, showProfile and -220 or -12, 1, 0),
                BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0,
                CanvasSize = UDim2.new(),
                AutomaticCanvasSize = Enum.AutomaticSize.X,
                ScrollingDirection = Enum.ScrollingDirection.X,
                ElasticBehavior = Enum.ElasticBehavior.Never,
                Parent = navFrame,
            })
            new("UIListLayout", {
                Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder,
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center, Parent = navScroll,
            })
            navFrame = navScroll

            if showProfile then
                local pFrame = new("Frame", {
                    Size = UDim2.fromOffset(196, navH),
                    BackgroundTransparency = 1,
                    Parent = content,
                    Name = "TopBarProfile",
                })
                pFrame.Position = (pos == "Top") and UDim2.fromOffset(0, 0) or UDim2.new(0, 0, 1, -navH)
                local avatar = new("ImageLabel", {
                    Size = UDim2.fromOffset(30, 30),
                    Position = UDim2.fromOffset(14, (navH - 30) / 2),
                    BackgroundColor3 = T.Control, Image = "", Parent = pFrame,
                })
                corner(avatar, 100)
                registerTheme(avatar, "BackgroundColor3", "Control")
                task.spawn(function()
                    local ok, img = pcall(function()
                        return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                    end)
                    if ok and avatar.Parent then avatar.Image = img end
                end)
                label({
                    Position = UDim2.fromOffset(52, 0), Size = UDim2.new(1, -60, 1, 0),
                    Text = LocalPlayer.DisplayName, Font = Enum.Font.BuilderSansBold,
                    TextSize = 14, TextTruncate = Enum.TextTruncate.AtEnd, Parent = pFrame,
                })
                profileFrame = pFrame
            end
        end

        local main = new("Frame", {
            Name = "Main",
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Parent = content,
        })
        if pos == "Left" then
            main.Position = UDim2.fromOffset(sidebarW, 0)
            main.Size = UDim2.new(1, -sidebarW, 1, 0)
        elseif pos == "Top" then
            main.Position = UDim2.fromOffset(0, navH)
            main.Size = UDim2.new(1, 0, 1, -navH)
        elseif pos == "Bottom" then
            main.Position = UDim2.fromOffset(0, 0)
            main.Size = UDim2.new(1, 0, 1, -navH)
        end

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
            Text = (self.Active and self.Active.Name) or "",
            Font = Enum.Font.BuilderSansBold, TextSize = 22,
            Parent = header,
        })
        registerTheme(titleLabel, "TextColor3", "Text")

        if not keepPages then
            keepPages = new("Frame", {
                Name = "Pages",
                BackgroundTransparency = 1,
                Parent = main,
            })
            self.Pages = keepPages
        else
            keepPages.Parent = main
        end
        keepPages.Position = UDim2.fromOffset(0, 56)
        keepPages.Size = UDim2.new(1, 0, 1, -56)

        self.Nav = navFrame
        self.Header = header
        self.TitleLabel = titleLabel
        self.Main = main
        self.ProfileFrame = profileFrame

        local function ctrlButton(iconName, xOff, hoverColor, hoverTransparency)
            local b = new("TextButton", {
                AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, xOff, 0, 0),
                Size = UDim2.fromOffset(46, 36), BackgroundColor3 = hoverColor,
                BackgroundTransparency = 1, Text = "", AutoButtonColor = false, Parent = header,
            })
            icon({
                AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(14, 14), Parent = b,
            }, iconName, T.Text)
            track(b.MouseEnter:Connect(function() tween(b, ti(0.15), { BackgroundTransparency = hoverTransparency }) end))
            track(b.MouseLeave:Connect(function() tween(b, ti(0.15), { BackgroundTransparency = 1 }) end))
            return b
        end

        local closeButton = ctrlButton("close", 0, T.Danger, 0)
        local minButton = ctrlButton("minimize", -46, Color3.new(1, 1, 1), 0.92)

        makeDraggable(self, { header, profileFrame and profileFrame:FindFirstChild("Sidebar") or header })

        track(minButton.Activated:Connect(function()
            self:Close()
            Alion:Notify({ Title = "Window hidden", Content = "Press " .. self.ToggleKey.Name .. " to open it again.", Icon = "info", Duration = 3 })
        end))
        track(closeButton.Activated:Connect(function() self:Destroy() end))

        for _, t in ipairs(self.Tabs) do
            self:_buildNavItem(t, pos)
        end

        if self.Indicator and self.Active and pos == "Left" then
            self.Indicator.Position = UDim2.fromOffset(0, (self.Active.Index - 1) * 42 + 11)
            self.Indicator.Visible = true
        end
    end

    function win:_buildNavItem(tab, pos)
        if pos == "Left" then
            local wrap = new("CanvasGroup", {
                Name = tab.Name,
                Size = UDim2.new(1, 0, 0, 38),
                Position = UDim2.fromOffset(-14, (tab.Index - 1) * 42),
                BackgroundTransparency = 1,
                GroupTransparency = 1,
                Parent = self.Nav,
            })
            local navBtn = new("TextButton", {
                Size = UDim2.fromScale(1, 1),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false,
                Parent = wrap,
            })
            corner(navBtn, 6)
            local navIcon = icon({
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 14, 0.5, 0),
                Size = UDim2.fromOffset(20, 20),
                Parent = navBtn,
            }, tab.Icon, T.SubText)
            local navName = label({
                Position = UDim2.fromOffset(46, 0),
                Size = UDim2.new(1, -52, 1, 0),
                Text = tab.Name,
                TextColor3 = T.SubText,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = navBtn,
            })
            tab.NavBtn = navBtn
            tab.NavIcon = navIcon
            tab.NavName = navName
            tab.NavWrap = wrap
            track(navBtn.MouseEnter:Connect(function()
                if self.Active ~= tab then tween(navBtn, ti(0.2), { BackgroundTransparency = 0.95 }) end
            end))
            track(navBtn.MouseLeave:Connect(function()
                if self.Active ~= tab then tween(navBtn, ti(0.2), { BackgroundTransparency = 1 }) end
            end))
            track(navBtn.Activated:Connect(function() self:SelectTab(tab) end))
            task.delay(0.3 + (tab.Index - 1) * 0.06, function()
                if wrap.Parent then
                    tween(wrap, ti(0.5), { Position = UDim2.fromOffset(0, (tab.Index - 1) * 42), GroupTransparency = 0 })
                end
            end)
        else
            local navBtn = new("TextButton", {
                Size = UDim2.fromOffset(120, 40),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false,
                LayoutOrder = tab.Index,
                Parent = self.Nav,
            })
            corner(navBtn, 6)
            local navIcon = icon({
                AnchorPoint = Vector2.new(0, 0.5),
                Position = UDim2.new(0, 12, 0.5, 0),
                Size = UDim2.fromOffset(18, 18),
                Parent = navBtn,
            }, tab.Icon, T.SubText)
            local navName = label({
                Position = UDim2.fromOffset(38, 0),
                Size = UDim2.new(1, -44, 1, 0),
                Text = tab.Name,
                TextSize = 13,
                TextColor3 = T.SubText,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = navBtn,
            })
            tab.NavBtn = navBtn
            tab.NavIcon = navIcon
            tab.NavName = navName
            track(navBtn.MouseEnter:Connect(function()
                if self.Active ~= tab then tween(navBtn, ti(0.2), { BackgroundTransparency = 0.95 }) end
            end))
            track(navBtn.MouseLeave:Connect(function()
                if self.Active ~= tab then tween(navBtn, ti(0.2), { BackgroundTransparency = 1 }) end
            end))
            track(navBtn.Activated:Connect(function() self:SelectTab(tab) end))
        end
    end

    track(UserInputService.InputBegan:Connect(function(input, processed)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if input.KeyCode == win.ToggleKey then
            if UserInputService:GetFocusedTextBox() then return end
            win:Toggle()
        end
    end))

    win:_layout()

    if win._showSettingsTab then
        win:_buildSettingsTab()
    end

    win:Open()
    return win
end

function Window:_buildSettingsTab()
    if self.SettingsTab then return end
    local tab = self:Tab({ Title = "Alion Settings", Icon = "settings" })
    self.SettingsTab = tab
    tab.IsSettings = true

    local general = tab:Section({ Title = "Appearance" })
    general:Dropdown({
        Title = "Theme",
        Description = "Overall colour palette",
        Icon = "palette",
        Options = Alion:GetThemeList(),
        Value = Alion._activeTheme,
        Callback = function(v)
            if v then Alion:SetTheme(v, false) end
        end,
    })
    general:ColorPicker({
        Title = "Accent color",
        Description = "Highlight colour used across the UI",
        Icon = "drop",
        Default = Alion.Accent,
        Callback = function(c)
            Alion:SetAccent(c)
        end,
    })
    general:Slider({
        Title = "Window transparency",
        Description = "How see-through the window body is",
        Icon = "eye",
        Min = 0, Max = 0.5, Increment = 0.01,
        Value = self._transparency,
        Suffix = "",
        Callback = function(v)
            self._transparency = v
            self.Body.BackgroundTransparency = v
        end,
    })
    general:Slider({
        Title = "UI scale",
        Description = "Scale the whole window up or down",
        Icon = "grid",
        Min = 0.7, Max = 1.4, Increment = 0.05,
        Value = self._rootScale,
        Callback = function(v)
            self._rootScale = v
            tween(self.Scale, ti(0.2), { Scale = (self._open and 1 or 0.92) * v })
        end,
    })

    local navSec = tab:Section({ Title = "Layout" })
    navSec:Dropdown({
        Title = "Nav position",
        Description = "Where tab buttons appear",
        Icon = "layers",
        Options = { "Left", "Top", "Bottom" },
        Value = self._navPos,
        Callback = function(v)
            if not v then return end
            self._navPos = v
            Alion.Settings.NavPosition = v
            self:_layout()
        end,
    })
    navSec:Toggle({
        Title = "Show profile panel",
        Description = "Avatar and username in the sidebar / header",
        Icon = "user",
        Value = self._showProfile,
        Callback = function(v)
            self._showProfile = v
            Alion.Settings.ShowProfile = v
            self:_layout()
        end,
    })
    navSec:Toggle({
        Title = "Show footer",
        Description = "Version label at the bottom of the sidebar",
        Icon = "info",
        Value = self._showFooter,
        Callback = function(v)
            self._showFooter = v
            Alion.Settings.ShowFooter = v
            self:_layout()
        end,
    })

    local miscSec = tab:Section({ Title = "Misc" })
    miscSec:Button({
        Title = "Reset to defaults",
        Description = "Restore theme, accent and layout",
        Icon = "refresh",
        ButtonText = "Reset",
        Callback = function()
            Alion.Settings.NavPosition = "Left"
            Alion.Settings.ShowProfile = true
            Alion.Settings.ShowFooter = true
            Alion.Settings.Transparency = 0.06
            Alion.Settings.Scale = 1
            self._navPos = "Left"
            self._showProfile = true
            self._showFooter = true
            self._transparency = 0.06
            self._rootScale = 1
            tween(self.Scale, ti(0.2), { Scale = self._open and 1 or 0.92 })
            self.Body.BackgroundTransparency = 0.06
            Alion:SetTheme("Dark", false)
            self:_layout()
            Alion:Notify({ Title = "Reset", Content = "Settings restored to default.", Icon = "check" })
        end,
    })
    miscSec:Button({
        Title = "Test notification",
        Description = "Fire a sample toast",
        Icon = "bell",
        ButtonText = "Send",
        Callback = function()
            Alion:Notify({ Title = "Hello!", Content = "This is an Alion toast.", Icon = "star" })
        end,
    })
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
        tween(self.Scale, info, { Scale = self._rootScale })
        tween(self.Content, ti(0.4), { GroupTransparency = 0 })
        tween(self.Body, ti(0.4), { BackgroundTransparency = self._transparency or 0.06 })
        tween(self.BodyStroke, ti(0.4), { Transparency = 0.15 })
        if self.Shadow then pcall(function() tween(self.Shadow, ti(0.5), { Transparency = 0.5 }) end) end
    else
        local p = self.Root.Position
        self._pos = p
        local info = ti(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        tween(self.Root, info, { Position = UDim2.new(p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset + 24) })
        tween(self.Scale, info, { Scale = 0.92 * self._rootScale })
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
    if self._dragConns then
        for _, c in ipairs(self._dragConns) do pcall(function() c:Disconnect() end) end
        self._dragConns = nil
    end
    for i, w in ipairs(Alion._windows) do
        if w == self then table.remove(Alion._windows, i) break end
    end
    task.delay(0.45, function() pcall(function() self.Root:Destroy() end) end)
end

function Window:SelectTab(target)
    if type(target) == "number" then target = self.Tabs[target] end
    if not target or self.Active == target then return end
    local prev = self.Active
    self.Active = target
    if prev then
        styleNav(prev, false)
        tween(prev.TabPage, ti(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In), { GroupTransparency = 1 })
        task.delay(0.2, function()
            if self.Active ~= prev then prev.TabPage.Visible = false end
        end)
    end
    styleNav(target, true)
    target.TabPage.Position = UDim2.fromOffset(0, 18)
    target.TabPage.GroupTransparency = 1
    target.TabPage.Visible = true
    target.TabScroll.CanvasPosition = Vector2.zero
    tween(target.TabPage, ti(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0.08), {
        Position = UDim2.fromOffset(0, 0),
        GroupTransparency = 0,
    })
    if self.Indicator and self._navPos == "Left" then
        local y = (target.Index - 1) * 42 + 11
        if not prev then
            self.Indicator.Position = UDim2.fromOffset(0, y)
            self.Indicator.Visible = true
        else
            tween(self.Indicator, ti(0.4), { Position = UDim2.fromOffset(0, y) })
        end
    end
    if self.TitleLabel then
        self.TitleLabel.Text = target.Name
        self.TitleLabel.TextTransparency = 1
        self.TitleLabel.Position = UDim2.fromOffset(38, 0)
        tween(self.TitleLabel, ti(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0.05), {
            TextTransparency = 0,
            Position = UDim2.fromOffset(24, 0),
        })
    end
end

function Window:Tab(opts)
    opts = opts or {}
    local name = opts.Title or opts.Name or "Tab"
    local iconName = opts.Icon or "home"
    local index = #self.Tabs + 1

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
        Icon = iconName,
        Index = index,
        TabPage = page,
        TabScroll = scroll,
        _order = 1,
        _currentSection = nil,
        Elements = {},
    }, Tab)
    table.insert(self.Tabs, tab)
    if not self._destroyed and self.Nav then
        self:_buildNavItem(tab, self._navPos or "Left")
    end
    if index == 1 and not self.Active then self:SelectTab(tab) end
    return tab
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
        Parent = self.TabScroll,
    })
    new("UIListLayout", {
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = wrap,
    })
    if title ~= "" then
        local h = label({
            Name = "Heading",
            Size = UDim2.new(1, 0, 0, 20),
            Text = title,
            Font = Enum.Font.BuilderSansBold,
            TextSize = 15,
            TextColor3 = Alion.Accent,
            LayoutOrder = 0,
            Parent = wrap,
        })
        registerAccent(h, "TextColor3")
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
    local cs = stroke(card, T.Stroke, 1, 0.35)
    registerTheme(card, "BackgroundColor3", "Card")
    registerTheme(cs, "Color", "Stroke")
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

function Tab:_curSection()
    if not self._currentSection then self:Section({}) end
    return self._currentSection
end

function Tab:Toggle(o) return self:_curSection():Toggle(o) end
function Tab:Dropdown(o) return self:_curSection():Dropdown(o) end
function Tab:Slider(o) return self:_curSection():Slider(o) end
function Tab:Keybind(o) return self:_curSection():Keybind(o) end
function Tab:Button(o) return self:_curSection():Button(o) end
function Tab:Input(o) return self:_curSection():Input(o) end
function Tab:ColorPicker(o) return self:_curSection():ColorPicker(o) end
function Tab:Label(o) return self:_curSection():Label(o) end
function Tab:Textbox(o) return self:_curSection():Input(o) end
function Tab:Paragraph(o) return self:_curSection():Paragraph(o) end
function Tab:Divider(o) return self:_curSection():Divider(o) end
function Tab:ProgressBar(o) return self:_curSection():ProgressBar(o) end
function Tab:CharacterPreview(o) return self:_curSection():CharacterPreview(o) end
function Tab:CharacterButton(o) return self:_curSection():CharacterButton(o) end
function Tab:AvatarGrid(o) return self:_curSection():AvatarGrid(o) end

function Section:_row(o, reserve)
    self._order = (self._order or 0) + 1
    local descText = o.Desc or o.Description or ""
    local hasDesc = type(descText) == "string" and descText ~= ""
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
        local div = new("Frame", {
            Name = "Divider",
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = T.Divider,
            BorderSizePixel = 0,
            LayoutOrder = 0,
            Parent = row,
        })
        registerTheme(div, "BackgroundColor3", "Divider")
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
    registerTheme(title, "TextColor3", "Text")
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
        registerTheme(desc, "TextColor3", "SubText")
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

function Section:Paragraph(o)
    o = o or {}
    local text = o.Content or o.Text or ""
    local title = o.Title
    local h = title and 22 or 0
    local order = (self._order or 0) + 1
    self._order = order
    local row = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = order,
        Parent = self.Body,
    })
    new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = row })
    if order > 1 then
        local div = new("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = T.Divider,
            BorderSizePixel = 0,
            LayoutOrder = 0,
            Parent = row,
        })
        registerTheme(div, "BackgroundColor3", "Divider")
    end
    new("UIPadding", {
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = row,
    })
    if title then
        local tl = label({
            Size = UDim2.new(1, 0, 0, 18),
            Text = title,
            Font = Enum.Font.BuilderSansBold,
            TextSize = 14,
            LayoutOrder = 1,
            Parent = row,
        })
        registerTheme(tl, "TextColor3", "Text")
    end
    local body = label({
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Text = text,
        Font = Enum.Font.BuilderSans,
        TextSize = 13,
        TextColor3 = T.SubText,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        LayoutOrder = 2,
        Parent = row,
    })
    registerTheme(body, "TextColor3", "SubText")
    return { Type = "Paragraph", Instance = body }
end

function Section:Divider(o)
    o = o or {}
    local order = (self._order or 0) + 1
    self._order = order
    local pad = o.Padding or 8
    local wrap = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, pad * 2 + 1),
        LayoutOrder = order,
        Parent = self.Body,
    })
    local line = new("Frame", {
        Position = UDim2.fromOffset(16, pad),
        Size = UDim2.new(1, -32, 0, 1),
        BackgroundColor3 = T.Divider,
        BorderSizePixel = 0,
        Parent = wrap,
    })
    registerTheme(line, "BackgroundColor3", "Divider")
    return { Type = "Divider" }
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
    local bs = stroke(b, primary and Alion.Accent or T.StrokeLight, 1, primary and 1 or 0.5)
    if not primary then
        registerTheme(b, "BackgroundColor3", "Control")
        registerTheme(bs, "Color", "StrokeLight")
    else
        registerAccent(b)
    end
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
        registerTheme(chip, "BackgroundColor3", "Input")
        registerTheme(chip, "TextColor3", "SubText")
        registerTheme(chipStroke, "Color", "Stroke")
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
        default = o.Default or (type(val) == "number" and val or min)
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
    registerTheme(valueLabel, "TextColor3", "SubText")
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

function Section:ProgressBar(o)
    o = o or {}
    local val = o.Value or 0
    local max = o.Max or 100
    local row, header, title, desc = self:_row(o, 290)
    local valueLabel = label({
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.fromOffset(60, 20),
        TextXAlignment = Enum.TextXAlignment.Right,
        TextSize = 13,
        TextColor3 = T.SubText,
        Parent = header,
    })
    registerTheme(valueLabel, "TextColor3", "SubText")
    local rail = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -84, 0.5, 0),
        Size = UDim2.fromOffset(160, 6),
        BackgroundColor3 = Color3.fromRGB(100, 100, 100),
        BorderSizePixel = 0,
        Parent = header,
    })
    corner(rail, 100)
    local fill = new("Frame", {
        Size = UDim2.fromScale(math.clamp(val / max, 0, 1), 1),
        BackgroundColor3 = Alion.Accent,
        BorderSizePixel = 0,
        Parent = rail,
    })
    corner(fill, 100)
    registerAccent(fill)
    local function render()
        tween(fill, ti(0.25), { Size = UDim2.fromScale(math.clamp(val / max, 0, 1), 1) })
        valueLabel.Text = string.format("%d%%", math.floor(val / max * 100 + 0.5))
    end
    render()
    local obj = { Type = "ProgressBar" }
    function obj:Set(v)
        val = v
        render()
        if o.Callback then fire(o.Callback, v) end
    end
    function obj:Get() return val end
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
    registerTheme(box, "BackgroundColor3", "Control")
    registerTheme(boxStroke, "Color", "StrokeLight")
    local valueLabel = label({
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -38, 1, 0),
        TextSize = 13,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = box,
    })
    registerTheme(valueLabel, "TextColor3", "Text")
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
    registerTheme(list, "BackgroundColor3", "Input")
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
            registerTheme(txt, "TextColor3", "Text")
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
    registerTheme(box, "BackgroundColor3", "Input")
    registerTheme(boxStroke, "Color", "StrokeLight")
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
    registerTheme(tb, "TextColor3", "Text")
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
    registerTheme(btn, "BackgroundColor3", "Control")
    registerTheme(btn, "TextColor3", "Text")
    registerTheme(btnStroke, "Color", "StrokeLight")
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
        local div = new("Frame", {
            Name = "Divider",
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = T.Divider,
            BorderSizePixel = 0,
            LayoutOrder = 0,
            Parent = row,
        })
        registerTheme(div, "BackgroundColor3", "Divider")
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
    registerTheme(titleLbl, "TextColor3", "Text")
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
        registerTheme(descLbl, "TextColor3", "SubText")
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
    local bs = stroke(body, T.Stroke, 1, 0.35)
    registerTheme(body, "BackgroundColor3", "Input")
    registerTheme(bs, "Color", "Stroke")

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
    registerTheme(hexBox, "BackgroundColor3", "Control")
    registerTheme(hexBox, "TextColor3", "Text")
    registerTheme(hbStroke, "Color", "Stroke")
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
    registerTheme(resetBtn, "BackgroundColor3", "Control")
    registerTheme(resetBtn, "TextColor3", "Text")
    registerTheme(rbStroke, "Color", "Stroke")
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

function Section:CharacterPreview(o)
    o = o or {}
    local order = (self._order or 0) + 1
    self._order = order
    local size = o.Size or 140
    local mode = o.Mode or "Head"

    local row = new("Frame", {
        Name = "CharPreviewRow",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = order,
        Parent = self.Body,
    })
    new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = row })
    if order > 1 then
        local div = new("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = T.Divider,
            BorderSizePixel = 0,
            LayoutOrder = 0,
            Parent = row,
        })
        registerTheme(div, "BackgroundColor3", "Divider")
    end
    local header = new("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        Parent = row,
    })
    new("UIPadding", {
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
        Parent = header,
    })
    local titleLbl = label({
        Size = UDim2.new(1, 0, 1, 0),
        Text = o.Title or "Preview",
        TextColor3 = T.Text,
        Parent = header,
    })
    registerTheme(titleLbl, "TextColor3", "Text")

    local holder = new("Frame", {
        Size = UDim2.new(1, 0, 0, size),
        BackgroundTransparency = 1,
        LayoutOrder = 2,
        Parent = row,
    })
    new("UIPadding", {
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
        PaddingBottom = UDim.new(0, 12),
        Parent = holder,
    })
    local canvas = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(size, size),
        BackgroundColor3 = T.Input,
        BackgroundTransparency = 0.35,
        Parent = holder,
    })
    corner(canvas, 8)
    local cs = stroke(canvas, T.Stroke, 1, 0.35)
    registerTheme(canvas, "BackgroundColor3", "Input")
    registerTheme(cs, "Color", "Stroke")

    local vp = makeCharacterViewport({
        Parent = canvas,
        Size = UDim2.new(1, -4, 1, -4),
        Target = o.Target or LocalPlayer,
        Mode = mode,
        Spin = o.Spin ~= false,
        SpinSpeed = o.SpinSpeed or 40,
        StartAngle = o.StartAngle,
        FOV = o.FOV,
        Distance = o.Distance,
        LookHeight = o.LookHeight,
    })
    vp.Instance.Position = UDim2.fromOffset(2, 2)

    local obj = { Type = "CharacterPreview", Viewport = vp }
    function obj:SetTarget(t) vp:SetTarget(t) end
    function obj:SetSpeed(v) vp:SetSpeed(v) end
    function obj:Destroy()
        vp:Destroy()
        row:Destroy()
    end
    return obj
end

function Section:CharacterButton(o)
    o = o or {}
    local row, header, title, desc = self:_row(o, 96)
    local size = o.IconSize or 60

    local slot = new("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.fromOffset(size, size),
        BackgroundColor3 = T.Input,
        BackgroundTransparency = 0.35,
        Parent = header,
    })
    corner(slot, 8)
    local ss = stroke(slot, T.Stroke, 1, 0.35)
    registerTheme(slot, "BackgroundColor3", "Input")
    registerTheme(ss, "Color", "Stroke")

    local vp = makeCharacterViewport({
        Parent = slot,
        Size = UDim2.new(1, -4, 1, -4),
        Target = o.Target or LocalPlayer,
        Mode = "Head",
        Spin = o.Spin ~= false,
        SpinSpeed = o.SpinSpeed or 40,
        FOV = o.FOV,
    })
    vp.Instance.Position = UDim2.fromOffset(2, 2)

    local hit = new("TextButton", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = header,
    })
    local uiScale = new("UIScale", { Parent = slot })
    track(hit.MouseEnter:Connect(function()
        tween(slot, ti(0.15), { BackgroundTransparency = 0.1 })
        tween(uiScale, ti(0.2), { Scale = 1.05 })
    end))
    track(hit.MouseLeave:Connect(function()
        tween(slot, ti(0.15), { BackgroundTransparency = 0.35 })
        tween(uiScale, ti(0.2), { Scale = 1 })
    end))
    track(hit.MouseButton1Down:Connect(function() tween(uiScale, ti(0.12), { Scale = 0.95 }) end))
    track(hit.MouseButton1Up:Connect(function() tween(uiScale, ti(0.3, Enum.EasingStyle.Back), { Scale = 1.05 }) end))
    track(hit.Activated:Connect(function() fire(o.Callback, vp) end))

    local obj = { Type = "CharacterButton", Viewport = vp }
    function obj:SetTarget(t) vp:SetTarget(t) end
    function obj:Destroy()
        vp:Destroy()
        row:Destroy()
    end
    return finishElement(obj, row, title, desc)
end

function Section:AvatarGrid(o)
    o = o or {}
    local order = (self._order or 0) + 1
    self._order = order
    local cols = o.Columns or 4
    local cellSize = o.CellSize or 96

    local row = new("Frame", {
        Name = "AvatarGridRow",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = order,
        Parent = self.Body,
    })
    if order > 1 then
        local div = new("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = T.Divider,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(0, 0),
            Parent = row,
        })
        registerTheme(div, "BackgroundColor3", "Divider")
        new("UIPadding", { PaddingTop = UDim.new(0, 1), Parent = row })
    end
    local header = new("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundTransparency = 1,
        Parent = row,
    })
    if o.Title then
        new("UIPadding", {
            PaddingLeft = UDim.new(0, 16),
            PaddingRight = UDim.new(0, 16),
            Parent = header,
        })
        local ht = label({
            Size = UDim2.new(1, 0, 1, 0),
            Text = o.Title,
            TextColor3 = T.Text,
            Parent = header,
        })
        registerTheme(ht, "TextColor3", "Text")
    end
    local grid = new("Frame", {
        Position = UDim2.fromOffset(0, o.Title and 48 or 0),
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Parent = row,
    })
    new("UIPadding", {
        PaddingLeft = UDim.new(0, 16),
        PaddingRight = UDim.new(0, 16),
        PaddingBottom = UDim.new(0, 12),
        Parent = grid,
    })
    local layout = new("UIGridLayout", {
        CellSize = UDim2.fromOffset(cellSize, cellSize + 22),
        CellPadding = UDim2.fromOffset(8, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = grid,
    })
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        grid.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 12)
    end)
    grid.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 12)
    row.Size = UDim2.new(1, 0, 0, (o.Title and 48 or 0) + layout.AbsoluteContentSize.Y + 12)

    local cells = {}
    local obj = { Type = "AvatarGrid" }

    local function buildCell(entry, index)
        local cell = new("Frame", {
            LayoutOrder = index,
            BackgroundColor3 = T.Input,
            BackgroundTransparency = 0.35,
            Parent = grid,
        })
        corner(cell, 8)
        local cs = stroke(cell, T.Stroke, 1, 0.35)
        registerTheme(cell, "BackgroundColor3", "Input")
        registerTheme(cs, "Color", "Stroke")

        local target = entry.Target or entry.UserId or entry
        local vp = makeCharacterViewport({
            Parent = cell,
            Size = UDim2.new(1, -4, 1, -26),
            Target = target,
            Mode = "Head",
            Spin = true,
            SpinSpeed = 40,
            FOV = 22,
        })
        vp.Instance.Position = UDim2.fromOffset(2, 2)

        local nameLbl = label({
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 1, -2),
            Size = UDim2.new(1, -8, 0, 20),
            Text = entry.Name or "Player",
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextColor3 = T.SubText,
            Parent = cell,
        })
        registerTheme(nameLbl, "TextColor3", "SubText")

        local hit = new("TextButton", {
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            Parent = cell,
        })
        track(hit.MouseEnter:Connect(function()
            tween(cell, ti(0.15), { BackgroundTransparency = 0.1 })
        end))
        track(hit.MouseLeave:Connect(function()
            tween(cell, ti(0.15), { BackgroundTransparency = 0.35 })
        end))
        track(hit.Activated:Connect(function() fire(o.Callback, entry, vp, index) end))

        cells[index] = { Frame = cell, Viewport = vp, Label = nameLbl, Entry = entry }
        return cells[index]
    end

    function obj:SetEntries(entries)
        for _, c in ipairs(cells) do
            c.Viewport:Destroy()
            c.Frame:Destroy()
        end
        cells = {}
        for i, e in ipairs(entries or {}) do buildCell(e, i) end
        grid.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 12)
        row.Size = UDim2.new(1, 0, 0, (o.Title and 48 or 0) + layout.AbsoluteContentSize.Y + 12)
    end
    function obj:GetCells() return cells end

    if o.Entries then obj:SetEntries(o.Entries) end
    return obj
end

if getgenv then getgenv().Alion = Alion end

return Alion
