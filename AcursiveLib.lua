local Acursive = {}
Acursive.__index = Acursive

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local THEMES = {
	Orange = { primary = Color3.fromRGB(255, 140, 50), light = Color3.fromRGB(255, 240, 225) },
	Blue = { primary = Color3.fromRGB(80, 160, 255), light = Color3.fromRGB(220, 240, 255) },
	Green = { primary = Color3.fromRGB(80, 220, 120), light = Color3.fromRGB(215, 255, 225) },
	Purple = { primary = Color3.fromRGB(180, 100, 255), light = Color3.fromRGB(240, 220, 255) },
	Pink = { primary = Color3.fromRGB(255, 100, 180), light = Color3.fromRGB(255, 220, 240) },
	Red = { primary = Color3.fromRGB(255, 80, 80), light = Color3.fromRGB(255, 220, 220) },
	Cyan = { primary = Color3.fromRGB(80, 220, 220), light = Color3.fromRGB(220, 255, 255) },
	Yellow = { primary = Color3.fromRGB(255, 220, 80), light = Color3.fromRGB(255, 245, 215) },
	White = { primary = Color3.fromRGB(240, 240, 240), light = Color3.fromRGB(255, 255, 255) },
	Dark = { primary = Color3.fromRGB(90, 90, 100), light = Color3.fromRGB(150, 150, 160) },
}

local Palette = {
	Panel = Color3.fromRGB(14, 14, 14),
	Row = Color3.fromRGB(20, 20, 20),
	RowHover = Color3.fromRGB(26, 26, 26),
	RowActive = Color3.fromRGB(32, 32, 32),
	Outline = Color3.fromRGB(32, 32, 32),
	Shadow = Color3.fromRGB(0, 0, 0),
	Text = Color3.fromRGB(210, 210, 210),
	TextBright = Color3.fromRGB(255, 255, 255),
	Muted = Color3.fromRGB(120, 120, 120),
	Input = Color3.fromRGB(16, 16, 16),
	Dark = Color3.fromRGB(10, 10, 10),
}

Acursive.Themes = THEMES
Acursive.Palette = Palette
Acursive.Version = "1.1.0"

local Accent = THEMES.Orange.primary
local AccentLight = THEMES.Orange.light
local CurrentTheme = "Orange"
local RGBMode = false
local RGBHue = 0
local accentTargets = {}
local accentGradients = {}
local activeKeybinds = {}
local keyCapture = nil

local function isTyping()
	return UserInputService:GetFocusedTextBox() ~= nil
end

local function tween(inst, time, props, style, dir)
	local t = TweenService:Create(inst, TweenInfo.new(time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function registerAccent(inst, prop)
	table.insert(accentTargets, { inst = inst, prop = prop or "BackgroundColor3" })
end

local function registerAccentFn(fn)
	table.insert(accentTargets, { apply = fn })
end

local function applyAccent(color, light)
	Accent = color
	AccentLight = light or color:Lerp(Color3.new(1, 1, 1), 0.7)
	for _, entry in ipairs(accentTargets) do
		if entry.apply then
			pcall(entry.apply)
		elseif entry.inst then
			pcall(function() entry.inst[entry.prop] = Accent end)
		end
	end
	for _, grad in ipairs(accentGradients) do
		if grad and grad.Parent then
			pcall(function()
				grad.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Accent),
					ColorSequenceKeypoint.new(0.5, AccentLight),
					ColorSequenceKeypoint.new(1, Accent),
				})
			end)
		end
	end
end

function Acursive:GetAccent()
	return Accent
end

function Acursive:GetTheme()
	return CurrentTheme
end

function Acursive:SetAccent(color, light)
	RGBMode = false
	CurrentTheme = nil
	applyAccent(color, light)
end

function Acursive:SetTheme(name)
	local t = THEMES[name]
	if not t then return end
	RGBMode = false
	CurrentTheme = name
	applyAccent(t.primary, t.light)
end

function Acursive:SetRGB(enabled)
	RGBMode = enabled
end

function Acursive:IsRGB()
	return RGBMode
end

function Acursive:GetRegistry()
	return activeKeybinds
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	if keyCapture then
		local cb = keyCapture
		keyCapture = nil
		cb(input.KeyCode)
		return
	end
	if isTyping() then return end
	for _, entry in ipairs(activeKeybinds) do
		if entry.key == input.KeyCode then
			entry.callback()
			break
		end
	end
end)

RunService.Heartbeat:Connect(function(dt)
	local t = tick()
	local offset = ((t * 0.35) % 2) - 1
	for _, grad in ipairs(accentGradients) do
		if grad.Parent then grad.Offset = Vector2.new(offset, 0) end
	end
	if RGBMode then
		RGBHue = (RGBHue + dt * 0.15) % 1
		local c = Color3.fromHSV(RGBHue, 0.85, 1)
		applyAccent(c, c:Lerp(Color3.new(1, 1, 1), 0.7))
	end
end)

local screenGui

local function getScreenGui()
	if screenGui and screenGui.Parent then return screenGui end
	local sg = Instance.new("ScreenGui")
	sg.Name = "Acursive"
	sg.ResetOnSpawn = false
	sg.IgnoreGuiInset = true
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local parented = false
	pcall(function()
		if CoreGui:FindFirstChild("RobloxGui") then
			sg.Parent = CoreGui.RobloxGui
			parented = true
		end
	end)
	if not parented then
		sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
	screenGui = sg
	return sg
end

local notifContainer
local notifCounter = 0

local function getNotifContainer()
	if notifContainer and notifContainer.Parent then return notifContainer end
	local sg = getScreenGui()
	local c = Instance.new("Frame")
	c.Name = "AcursiveNotifications"
	c.AnchorPoint = Vector2.new(1, 1)
	c.Position = UDim2.new(1, -16, 1, -16)
	c.Size = UDim2.new(0, 240, 0, 0)
	c.AutomaticSize = Enum.AutomaticSize.Y
	c.BackgroundTransparency = 1
	c.ClipsDescendants = false
	c.Parent = sg
	local l = Instance.new("UIListLayout")
	l.Padding = UDim.new(0, 6)
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.VerticalAlignment = Enum.VerticalAlignment.Bottom
	l.HorizontalAlignment = Enum.HorizontalAlignment.Right
	l.Parent = c
	notifContainer = c
	return c
end

function Acursive:Notify(opts)
	if type(opts) == "string" then opts = { Title = opts } end
	opts = opts or {}
	local title = opts.Title or "Notification"
	local content = opts.Content or opts.Text or ""
	local duration = opts.Duration or 4
	local accentColor = opts.Accent or Accent
	local container = getNotifContainer()
	notifCounter = notifCounter + 1

	local wrapper = Instance.new("Frame")
	wrapper.Size = UDim2.new(1, 0, 0, 52)
	wrapper.BackgroundTransparency = 1
	wrapper.ClipsDescendants = false
	wrapper.LayoutOrder = notifCounter
	wrapper.Parent = container

	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(1, 0, 1, 0)
	notif.Position = UDim2.new(0, 0, 0, 0)
	notif.BackgroundColor3 = Palette.Panel
	notif.BorderSizePixel = 0
	notif.Parent = wrapper

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 3)
	corner.Parent = notif

	local stroke = Instance.new("UIStroke")
	stroke.Color = Palette.Outline
	stroke.Thickness = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = notif

	local accentBar = Instance.new("Frame")
	accentBar.Size = UDim2.new(0, 2, 1, -12)
	accentBar.Position = UDim2.new(0, 5, 0, 6)
	accentBar.BackgroundColor3 = accentColor
	accentBar.BorderSizePixel = 0
	accentBar.Parent = notif

	local abCorner = Instance.new("UICorner")
	abCorner.CornerRadius = UDim.new(1, 0)
	abCorner.Parent = accentBar

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, -20, 0, 16)
	titleLbl.Position = UDim2.new(0, 14, 0, 8)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = title
	titleLbl.TextColor3 = Palette.TextBright
	titleLbl.TextSize = 12
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Parent = notif

	local contentLbl = Instance.new("TextLabel")
	contentLbl.Size = UDim2.new(1, -20, 0, 14)
	contentLbl.Position = UDim2.new(0, 14, 0, 26)
	contentLbl.BackgroundTransparency = 1
	contentLbl.Text = content
	contentLbl.TextColor3 = Palette.Muted
	contentLbl.TextSize = 11
	contentLbl.Font = Enum.Font.Gotham
	contentLbl.TextXAlignment = Enum.TextXAlignment.Left
	contentLbl.Parent = notif

	local progressBg = Instance.new("Frame")
	progressBg.Size = UDim2.new(1, -12, 0, 1)
	progressBg.Position = UDim2.new(0, 6, 1, -5)
	progressBg.BackgroundColor3 = Palette.Outline
	progressBg.BorderSizePixel = 0
	progressBg.Parent = notif

	local progressFill = Instance.new("Frame")
	progressFill.Size = UDim2.new(1, 0, 1, 0)
	progressFill.BackgroundColor3 = accentColor
	progressFill.BorderSizePixel = 0
	progressFill.Parent = progressBg

	notif.BackgroundTransparency = 1
	accentBar.BackgroundTransparency = 1
	titleLbl.TextTransparency = 1
	contentLbl.TextTransparency = 1
	progressBg.BackgroundTransparency = 1
	progressFill.BackgroundTransparency = 1

	tween(notif, 0.35, { BackgroundTransparency = 0 }, Enum.EasingStyle.Quart)
	tween(accentBar, 0.3, { BackgroundTransparency = 0 })
	tween(titleLbl, 0.3, { TextTransparency = 0 })
	tween(contentLbl, 0.3, { TextTransparency = 0 })
	tween(progressBg, 0.3, { BackgroundTransparency = 0 })
	tween(progressFill, 0.3, { BackgroundTransparency = 0 })
	tween(progressFill, duration, { Size = UDim2.new(0, 0, 1, 0) }, Enum.EasingStyle.Linear)

	task.delay(duration, function()
		tween(notif, 0.35, { Position = UDim2.new(0, 320, 0, 0), BackgroundTransparency = 1 }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		tween(titleLbl, 0.35, { TextTransparency = 1 }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		tween(contentLbl, 0.35, { TextTransparency = 1 }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		tween(accentBar, 0.35, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		tween(progressBg, 0.35, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		tween(progressFill, 0.35, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		task.wait(0.4)
		wrapper:Destroy()
	end)
	return notif
end

local WindowClass = {}
WindowClass.__index = WindowClass

local SectionClass = {}
SectionClass.__index = SectionClass

local TabClass = {}
TabClass.__index = TabClass

function Acursive:CreateWindow(opts)
	opts = opts or {}
	local self_ = setmetatable({}, WindowClass)

	self_.Title = opts.Title or "Acursive"
	self_.Subtitle = opts.Subtitle or ""
	self_.Size = opts.Size or UDim2.new(0, 640, 0, 400)
	self_.Position = opts.Position or UDim2.new(0.5, 0, 0, 60)
	self_.ToggleKey = opts.ToggleKey or Enum.KeyCode.RightShift
	self_.ConfigFile = opts.ConfigFile
	self_.Draggable = opts.Draggable ~= false
	self_.MinHeight = opts.MinHeight or 90
	self_.MaxHeight = opts.MaxHeight or 640
	self_.TabWidth = opts.TabWidth or 90
	self_.HeaderHeight = opts.HeaderHeight or 16
	self_.ShowBranding = opts.ShowBranding ~= false

	self_.Pages = {}
	self_.Tabs = {}
	self_.TabOrder = 0
	self_.CurrentTab = nil
	self_.Visible = true
	self_.Toggles = {}
	self_.LastToggleTime = 0

	if THEMES[opts.Theme or ""] then
		CurrentTheme = opts.Theme
		applyAccent(THEMES[opts.Theme].primary, THEMES[opts.Theme].light)
	end

	local sg = getScreenGui()
	self_.ScreenGui = sg

	local NavWrap = Instance.new("Frame")
	NavWrap.Name = "TopNav"
	NavWrap.AnchorPoint = Vector2.new(0.5, 0)
	NavWrap.Position = UDim2.new(0.5, 0, 0, -50)
	NavWrap.Size = UDim2.new(0, 480, 0, 30)
	NavWrap.BackgroundColor3 = Palette.Dark
	NavWrap.BackgroundTransparency = 1
	NavWrap.BorderSizePixel = 0
	NavWrap.Parent = sg
	self_.NavWrap = NavWrap

	local NavCorner = Instance.new("UICorner")
	NavCorner.CornerRadius = UDim.new(0, 3)
	NavCorner.Parent = NavWrap

	local NavStroke = Instance.new("UIStroke")
	NavStroke.Color = Palette.Outline
	NavStroke.Thickness = 1
	NavStroke.Transparency = 1
	NavStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	NavStroke.Parent = NavWrap

	local NavShadow = Instance.new("UIStroke")
	NavShadow.Color = Palette.Shadow
	NavShadow.Thickness = 1
	NavShadow.Transparency = 1
	NavShadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	NavShadow.Parent = NavWrap

	local NavAccent = Instance.new("Frame")
	NavAccent.AnchorPoint = Vector2.new(0.5, 0)
	NavAccent.Size = UDim2.new(0, 60, 0, 1)
	NavAccent.Position = UDim2.new(0.5, 0, 0, 0)
	NavAccent.BackgroundColor3 = Accent
	NavAccent.BorderSizePixel = 0
	NavAccent.Parent = NavWrap
	registerAccent(NavAccent)

	local NavGlow = Instance.new("Frame")
	NavGlow.Size = UDim2.new(1, 0, 0, 1)
	NavGlow.Position = UDim2.new(0, 0, 0, 1)
	NavGlow.BackgroundColor3 = Accent
	NavGlow.BackgroundTransparency = 0.5
	NavGlow.BorderSizePixel = 0
	NavGlow.Parent = NavWrap
	registerAccent(NavGlow)

	local TabContainer = Instance.new("Frame")
	TabContainer.Size = UDim2.new(1, 0, 1, 0)
	TabContainer.BackgroundTransparency = 1
	TabContainer.Parent = NavWrap
	self_.TabContainer = TabContainer

	local TabLayout = Instance.new("UIListLayout")
	TabLayout.FillDirection = Enum.FillDirection.Horizontal
	TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	TabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TabLayout.Padding = UDim.new(0, 4)
	TabLayout.Parent = TabContainer

	local TabIndicator = Instance.new("Frame")
	TabIndicator.AnchorPoint = Vector2.new(0.5, 1)
	TabIndicator.Size = UDim2.new(0, 0, 0, 2)
	TabIndicator.Position = UDim2.new(0, 0, 1, -2)
	TabIndicator.BackgroundColor3 = Accent
	TabIndicator.BorderSizePixel = 0
	TabIndicator.ZIndex = 3
	TabIndicator.Visible = false
	TabIndicator.Parent = NavWrap
	registerAccent(TabIndicator)
	self_.TabIndicator = TabIndicator

	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.new(0, self_.Size.X.Offset, 0, 0)
	Main.AnchorPoint = Vector2.new(0.5, 0)
	Main.Position = self_.Position
	Main.BackgroundTransparency = 1
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = true
	Main.Parent = sg
	self_.Main = Main

	local DragBar = Instance.new("Frame")
	DragBar.Name = "DragBar"
	DragBar.Size = UDim2.new(0, 120, 0, 4)
	DragBar.AnchorPoint = Vector2.new(0.5, 0)
	DragBar.Position = UDim2.new(0.5, 0, 0, 4)
	DragBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	DragBar.BorderSizePixel = 0
	DragBar.Parent = Main

	local DragCorner = Instance.new("UICorner")
	DragCorner.CornerRadius = UDim.new(0, 1)
	DragCorner.Parent = DragBar

	local DragShadow = Instance.new("UIStroke")
	DragShadow.Color = Palette.Shadow
	DragShadow.Thickness = 1
	DragShadow.Transparency = 0.3
	DragShadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	DragShadow.Parent = DragBar
	self_.DragBar = DragBar

	local Content = Instance.new("Frame")
	Content.Size = UDim2.new(1, 0, 1, -self_.HeaderHeight)
	Content.Position = UDim2.new(0, 0, 0, self_.HeaderHeight)
	Content.BackgroundTransparency = 1
	Content.ClipsDescendants = true
	Content.Parent = Main
	self_.Content = Content

	if self_.Draggable then
		local dragging, dragStart, startPos = false, nil, nil
		DragBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = Main.Position
				tween(DragBar, 0.15, { BackgroundColor3 = Accent })
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - dragStart
				Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
	end

	local function makeGradient(parent)
		local grad = Instance.new("UIGradient")
		grad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Accent),
			ColorSequenceKeypoint.new(0.5, AccentLight),
			ColorSequenceKeypoint.new(1, Accent),
		})
		grad.Parent = parent
		table.insert(accentGradients, grad)
		return grad
	end
	makeGradient(NavAccent)
	makeGradient(TabIndicator)

	function self_:GetConfigFile()
		return self_.ConfigFile
	end

	function self_:SaveConfig()
		if not self_.ConfigFile then return end
		local data = {
			theme = CurrentTheme,
			rgbMode = RGBMode,
			accent = { Accent.R, Accent.G, Accent.B },
			lastTab = self_.CurrentTab,
			toggles = {},
		}
		for label, entry in pairs(self_.Toggles) do
			if entry.save ~= false then
				pcall(function() data.toggles[label] = entry.get() end)
			end
		end
		pcall(function()
			if writefile then writefile(self_.ConfigFile, HttpService:JSONEncode(data)) end
		end)
	end

	function self_:LoadConfig()
		if not self_.ConfigFile then return nil end
		local data
		pcall(function()
			if isfile and isfile(self_.ConfigFile) then
				data = HttpService:JSONDecode(readfile(self_.ConfigFile))
			end
		end)
		return data
	end

	local function computeHeight()
		if not self_.CurrentTab then return self_.MinHeight end
		local page = self_.Pages[self_.CurrentTab]
		if not page or not page.Parent then return self_.MinHeight end
		local layout = page:FindFirstChildOfClass("UIListLayout")
		if not layout then return self_.MinHeight end
		local pad = page:FindFirstChildOfClass("UIPadding")
		local padY = 0
		if pad then padY = pad.PaddingTop.Offset + pad.PaddingBottom.Offset end
		local total = self_.HeaderHeight + layout.AbsoluteContentSize.Y + padY + 14
		return math.clamp(total, self_.MinHeight, self_.MaxHeight)
	end
	self_.ComputeHeight = computeHeight

	local mainTween

	function self_:Resize(instant)
		if not self_.Visible then return end
		local target = computeHeight()
		if mainTween then mainTween:Cancel() end
		local targetSize = UDim2.new(0, self_.Size.X.Offset, 0, target)
		if instant then
			Main.Size = targetSize
		else
			mainTween = tween(Main, 0.3, { Size = targetSize }, Enum.EasingStyle.Quart)
		end
	end

	function self_:Show()
		if self_.Visible then return end
		self_.Visible = true
		local targetH = computeHeight()
		Main.Visible = true
		NavWrap.Visible = true
		tween(Main, 0.55, { Size = UDim2.new(0, self_.Size.X.Offset, 0, targetH), Position = UDim2.new(0.5, 0, 0, 60) }, Enum.EasingStyle.Quart)
		tween(NavWrap, 0.55, { Position = UDim2.new(0.5, 0, 0, 14), BackgroundTransparency = 0 }, Enum.EasingStyle.Quart)
		tween(NavStroke, 0.55, { Transparency = 0 })
		tween(NavShadow, 0.55, { Transparency = 0.3 })
		if self_.CurrentTab and self_.Tabs[self_.CurrentTab] then
			local t = self_.Tabs[self_.CurrentTab]
			local relX = t.AbsolutePosition.X - NavWrap.AbsolutePosition.X + t.AbsoluteSize.X / 2
			TabIndicator.Position = UDim2.new(0, relX, 1, -2)
			TabIndicator.Size = UDim2.new(0, t.AbsoluteSize.X - 14, 0, 2)
			TabIndicator.Visible = true
		end
	end

	function self_:Hide()
		if not self_.Visible then return end
		self_.Visible = false
		tween(Main, 0.4, { Size = UDim2.new(0, self_.Size.X.Offset, 0, 0), Position = UDim2.new(0.5, 0, 0, 40) }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		tween(NavWrap, 0.4, { Position = UDim2.new(0.5, 0, 0, -50), BackgroundTransparency = 1 }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		tween(NavStroke, 0.4, { Transparency = 1 })
		tween(NavShadow, 0.4, { Transparency = 1 })
		TabIndicator.Visible = false
	end

	function self_:Toggle()
		if self_.Visible then self_:Hide() else self_:Show() end
	end

	function self_:SetToggleKey(key)
		self_.ToggleKey = key
	end

	function self_:SetTitle(title)
		self_.Title = title
	end

	function self_:SetSubtitle(subtitle)
		self_.Subtitle = subtitle
	end

	function self_:SetPosition(pos)
		Main.Position = pos
	end

	function self_:SetSize(size)
		self_.Size = size
		self_:Resize(true)
	end

	function self_:SelectTab(name)
		if not self_.Tabs[name] or self_.CurrentTab == name then return end
		for _, p in pairs(self_.Pages) do p.Visible = false end
		if self_.Pages[name] then self_.Pages[name].Visible = true end
		for n, b in pairs(self_.Tabs) do
			if n == name then
				tween(b, 0.2, { TextColor3 = Accent })
			else
				tween(b, 0.2, { TextColor3 = Palette.Muted })
			end
		end
		local btn = self_.Tabs[name]
		TabIndicator.Visible = true
		local relX = btn.AbsolutePosition.X - NavWrap.AbsolutePosition.X + btn.AbsoluteSize.X / 2
		tween(TabIndicator, 0.3, {
			Position = UDim2.new(0, relX, 1, -2),
			Size = UDim2.new(0, btn.AbsoluteSize.X - 14, 0, 2),
		}, Enum.EasingStyle.Quart)
		self_.CurrentTab = name
		self_:Resize(false)
		self_:SaveConfig()
	end

	function self_:CreateTab(name, order)
		self_.TabOrder = self_.TabOrder + 1
		local orderNum = order or self_.TabOrder

		local page = Instance.new("ScrollingFrame")
		page.Name = name
		page.Size = UDim2.new(1, 0, 1, 0)
		page.BackgroundTransparency = 1
		page.BorderSizePixel = 0
		page.ScrollBarThickness = 2
		page.ScrollBarImageColor3 = Accent
		page.ScrollBarImageTransparency = 0.3
		page.Visible = false
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.Parent = Content
		registerAccent(page, "ScrollBarImageColor3")

		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, 4)
		pad.PaddingBottom = UDim.new(0, 4)
		pad.PaddingLeft = UDim.new(0, 6)
		pad.PaddingRight = UDim.new(0, 6)
		pad.Parent = page

		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Vertical
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, 8)
		layout.Parent = page

		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 14)
			if self_.CurrentTab == name then self_:Resize(false) end
		end)

		self_.Pages[name] = page

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, self_.TabWidth, 0, 22)
		btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		btn.BackgroundTransparency = 1
		btn.BorderSizePixel = 0
		btn.Text = name
		btn.TextColor3 = Palette.Muted
		btn.TextSize = 11
		btn.Font = Enum.Font.GothamMedium
		btn.AutoButtonColor = false
		btn.LayoutOrder = orderNum
		btn.Parent = TabContainer
		self_.Tabs[name] = btn

		btn.MouseEnter:Connect(function()
			if self_.CurrentTab ~= name then
				tween(btn, 0.15, { TextColor3 = Palette.Text })
			end
		end)
		btn.MouseLeave:Connect(function()
			if self_.CurrentTab ~= name then
				tween(btn, 0.15, { TextColor3 = Palette.Muted })
			end
		end)
		btn.MouseButton1Click:Connect(function()
			self_:SelectTab(name)
		end)

		local tab = setmetatable({}, TabClass)
		tab.Window = self_
		tab.Name = name
		tab.Page = page
		tab._order = 0
		tab.Sections = {}
		return tab
	end

	if not self_.CurrentTab then
		task.defer(function()
			local first
			for _, b in ipairs(TabContainer:GetChildren()) do
				if b:IsA("TextButton") then first = b break end
			end
			if first then self_:SelectTab(first.Text) end
		end)
	end

	if self_.ToggleKey then
		UserInputService.InputBegan:Connect(function(input, processed)
			if processed then return end
			if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
			if keyCapture then return end
			if isTyping() then return end
			if input.KeyCode == self_.ToggleKey then
				local now = tick()
				if now - self_.LastToggleTime < 0.25 then return end
				self_.LastToggleTime = now
				self_:Toggle()
			end
		end)
	end

	task.spawn(function()
		RunService.RenderStepped:Wait()
		RunService.RenderStepped:Wait()
		local cfg = self_:LoadConfig()
		if cfg then
			if cfg.theme and THEMES[cfg.theme] then
				CurrentTheme = cfg.theme
			end
			for label, val in pairs(cfg.toggles or {}) do
				local entry = self_.Toggles[label]
				if entry and entry.set then
					pcall(function() entry.set(val) end)
				end
			end
			if cfg.rgbMode then
				RGBMode = true
			elseif cfg.theme and THEMES[cfg.theme] then
				applyAccent(THEMES[cfg.theme].primary, THEMES[cfg.theme].light)
			elseif cfg.accent then
				applyAccent(Color3.new(cfg.accent[1], cfg.accent[2], cfg.accent[3]))
			end
			if cfg.lastTab and self_.Tabs[cfg.lastTab] then
				self_:SelectTab(cfg.lastTab)
			end
		end
		local targetH = computeHeight()
		Main.Size = UDim2.new(0, self_.Size.X.Offset, 0, 0)
		tween(NavWrap, 0.55, { Position = UDim2.new(0.5, 0, 0, 14), BackgroundTransparency = 0 }, Enum.EasingStyle.Quart)
		tween(NavStroke, 0.55, { Transparency = 0 })
		tween(NavShadow, 0.55, { Transparency = 0.3 })
		task.wait(0.15)
		tween(Main, 0.6, { Size = UDim2.new(0, self_.Size.X.Offset, 0, targetH) }, Enum.EasingStyle.Quart)
		task.wait(0.4)
		if self_.CurrentTab and self_.Tabs[self_.CurrentTab] then
			local t = self_.Tabs[self_.CurrentTab]
			local relX = t.AbsolutePosition.X - NavWrap.AbsolutePosition.X + t.AbsoluteSize.X / 2
			TabIndicator.Position = UDim2.new(0, relX, 1, -2)
			TabIndicator.Size = UDim2.new(0, t.AbsoluteSize.X - 14, 0, 2)
			TabIndicator.Visible = true
		end
		if self_.ShowBranding then
			Acursive:Notify({ Title = self_.Title, Content = "Loaded successfully", Duration = 4 })
		end
	end)

	return self_
end

function WindowClass:Notify(opts)
	return Acursive:Notify(opts)
end

function WindowClass:Destroy()
	pcall(function() self_:SaveConfig() end)
	for _, c in ipairs(accentGradients) do
		pcall(function() c:Destroy() end)
	end
	pcall(function() self_.NavWrap:Destroy() end)
	pcall(function() self_.Main:Destroy() end)
end

function TabClass:CreateSection(title, order)
	self._order = self._order + 1
	local orderNum = order or self._order

	local section = Instance.new("Frame")
	section.Size = UDim2.new(1, 0, 0, 0)
	section.AutomaticSize = Enum.AutomaticSize.Y
	section.BackgroundColor3 = Palette.Panel
	section.BorderSizePixel = 0
	section.LayoutOrder = orderNum
	section.Parent = self.Page

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 3)
	corner.Parent = section

	local outerShadow = Instance.new("UIStroke")
	outerShadow.Color = Palette.Shadow
	outerShadow.Thickness = 1
	outerShadow.Transparency = 0.2
	outerShadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	outerShadow.Parent = section

	local outline = Instance.new("UIStroke")
	outline.Color = Palette.Outline
	outline.Thickness = 1
	outline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	outline.Parent = section

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = section

	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, -24, 0, 22)
	header.BackgroundTransparency = 1
	header.Text = title
	header.TextColor3 = Palette.Muted
	header.TextSize = 11
	header.Font = Enum.Font.GothamMedium
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.LayoutOrder = 1
	header.Parent = section

	local line = Instance.new("Frame")
	line.Size = UDim2.new(1, -20, 0, 1)
	line.BackgroundColor3 = Palette.Outline
	line.BorderSizePixel = 0
	line.LayoutOrder = 2
	line.Parent = section

	local body = Instance.new("Frame")
	body.Size = UDim2.new(1, 0, 0, 0)
	body.AutomaticSize = Enum.AutomaticSize.Y
	body.BackgroundTransparency = 1
	body.LayoutOrder = 3
	body.Parent = section

	local bodyLayout = Instance.new("UIListLayout")
	bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
	bodyLayout.Parent = body

	local bodyPad = Instance.new("UIPadding")
	bodyPad.PaddingTop = UDim.new(0, 4)
	bodyPad.PaddingBottom = UDim.new(0, 6)
	bodyPad.PaddingLeft = UDim.new(0, 6)
	bodyPad.PaddingRight = UDim.new(0, 6)
	bodyPad.Parent = body

	local sec = setmetatable({}, SectionClass)
	sec._order = 0
	sec.Window = self.Window
	sec.Tab = self
	sec.Frame = section
	sec.Body = body
	sec.Header = header
	sec.Title = title
	sec.Collapsed = false

	function sec:SetTitle(t)
		header.Text = t
		sec.Title = t
	end

	function sec:SetVisible(v)
		section.Visible = v
	end

	function sec:SetCollapsed(v)
		sec.Collapsed = v
		body.Visible = not v
		section.AutomaticSize = v and Enum.AutomaticSize.None or Enum.AutomaticSize.Y
		if v then section.Size = UDim2.new(1, 0, 0, 24) else section.Size = UDim2.new(1, 0, 0, 0) end
	end

	function sec:CreateToggle(opts)
		opts = opts or {}
		sec._order = sec._order + 1
		local order = opts.Order or sec._order
		local label = opts.Name or opts.Label or "Toggle"
		local state = opts.Default or false
		local callback = opts.Callback
		local defaultKey = opts.Keybind or opts.DefaultKey
		local noSave = opts.Save == false
		local onDoubleClick = opts.OnDoubleClick

		local row = Instance.new("TextButton")
		row.Size = UDim2.new(1, 0, 0, 22)
		row.BackgroundColor3 = Palette.Row
		row.BorderSizePixel = 0
		row.Text = ""
		row.AutoButtonColor = false
		row.LayoutOrder = order
		row.Parent = body

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 2)
		corner.Parent = row

		local rowShadow = Instance.new("UIStroke")
		rowShadow.Color = Palette.Shadow
		rowShadow.Thickness = 1
		rowShadow.Transparency = 0.5
		rowShadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		rowShadow.Parent = row

		local box = Instance.new("Frame")
		box.Size = UDim2.new(0, 10, 0, 10)
		box.Position = UDim2.new(0, 10, 0.5, -5)
		box.BackgroundColor3 = state and Accent or Color3.fromRGB(28, 28, 28)
		box.BorderSizePixel = 0
		box.Parent = row

		local boxCorner = Instance.new("UICorner")
		boxCorner.CornerRadius = UDim.new(0, 1)
		boxCorner.Parent = box

		local boxStroke = Instance.new("UIStroke")
		boxStroke.Color = state and Accent or Palette.Outline
		boxStroke.Thickness = 1
		boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		boxStroke.Parent = box

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -180, 1, 0)
		lbl.Position = UDim2.new(0, 26, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = label
		lbl.TextColor3 = Palette.Text
		lbl.TextSize = 11
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row

		local ind = Instance.new("TextLabel")
		ind.Size = UDim2.new(0, 40, 1, 0)
		ind.Position = UDim2.new(1, -50, 0, 0)
		ind.BackgroundTransparency = 1
		ind.Text = state and "on" or "off"
		ind.TextColor3 = state and Accent or Palette.Muted
		ind.TextSize = 11
		ind.Font = Enum.Font.Gotham
		ind.TextXAlignment = Enum.TextXAlignment.Right
		ind.Parent = row

		local keyBtn = Instance.new("TextButton")
		keyBtn.Size = UDim2.new(0, 55, 0, 14)
		keyBtn.Position = UDim2.new(1, -120, 0.5, -7)
		keyBtn.BackgroundColor3 = Palette.Input
		keyBtn.BorderSizePixel = 0
		keyBtn.Text = "bind"
		keyBtn.TextColor3 = Palette.Muted
		keyBtn.TextSize = 10
		keyBtn.Font = Enum.Font.Gotham
		keyBtn.AutoButtonColor = false
		keyBtn.ZIndex = 2
		keyBtn.Parent = row

		local kbCorner = Instance.new("UICorner")
		kbCorner.CornerRadius = UDim.new(0, 2)
		kbCorner.Parent = keyBtn

		local kbStroke = Instance.new("UIStroke")
		kbStroke.Color = Palette.Outline
		kbStroke.Thickness = 1
		kbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		kbStroke.Parent = keyBtn

		local keyEntry = { key = nil, callback = nil }
		table.insert(activeKeybinds, keyEntry)

		local function setState(newState, fire)
			state = newState
			box.BackgroundColor3 = state and Accent or Color3.fromRGB(28, 28, 28)
			boxStroke.Color = state and Accent or Palette.Outline
			ind.Text = state and "on" or "off"
			ind.TextColor3 = state and Accent or Palette.Muted
			if fire and callback then callback(state) end
		end

		registerAccentFn(function()
			if state then
				box.BackgroundColor3 = Accent
				boxStroke.Color = Accent
				ind.TextColor3 = Accent
			else
				box.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
				boxStroke.Color = Palette.Outline
				ind.TextColor3 = Palette.Muted
			end
		end)

		if defaultKey then
			keyEntry.key = defaultKey
			keyEntry.callback = function()
				setState(not state, true)
				sec.Window:SaveConfig()
			end
			keyBtn.Text = tostring(defaultKey):gsub("Enum.KeyCode.", "")
		end

		row.MouseEnter:Connect(function()
			tween(row, 0.15, { BackgroundColor3 = Palette.RowHover })
		end)
		row.MouseLeave:Connect(function()
			tween(row, 0.15, { BackgroundColor3 = Palette.Row })
		end)

		if onDoubleClick then
			local pending, lastTime = nil, 0
			row.MouseButton1Click:Connect(function()
				local now = tick()
				if now - lastTime < 0.3 then
					if pending then task.cancel(pending) pending = nil end
					lastTime = 0
					onDoubleClick()
					return
				end
				lastTime = now
				pending = task.delay(0.3, function()
					pending = nil
					setState(not state, true)
					sec.Window:SaveConfig()
				end)
			end)
		else
			row.MouseButton1Click:Connect(function()
				setState(not state, true)
				sec.Window:SaveConfig()
			end)
		end

		keyBtn.MouseEnter:Connect(function()
			tween(keyBtn, 0.15, { TextColor3 = Accent, BackgroundColor3 = Color3.fromRGB(24, 24, 24) })
			tween(kbStroke, 0.15, { Color = Accent })
		end)
		keyBtn.MouseLeave:Connect(function()
			tween(keyBtn, 0.15, { TextColor3 = Palette.Muted, BackgroundColor3 = Palette.Input })
			tween(kbStroke, 0.15, { Color = Palette.Outline })
		end)
		keyBtn.MouseButton1Click:Connect(function()
			if keyCapture then return end
			keyBtn.Text = "..."
			keyCapture = function(keyCode)
				keyEntry.key = keyCode
				keyEntry.callback = function()
					setState(not state, true)
					sec.Window:SaveConfig()
				end
				keyBtn.Text = tostring(keyCode):gsub("Enum.KeyCode.", "")
			end
		end)

		sec.Window.Toggles[label] = {
			get = function() return state end,
			set = function(v) setState(v, true) end,
			save = not noSave,
		}

		return {
			Set = function(v) setState(v, true) end,
			Get = function() return state end,
			SetKeybind = function(key) keyEntry.key = key keyEntry.callback = function() setState(not state, true) sec.Window:SaveConfig() end keyBtn.Text = tostring(key):gsub("Enum.KeyCode.", "") end,
			SetVisible = function(v) row.Visible = v end,
			SetName = function(t) lbl.Text = t end,
			Row = row,
		}
	end

	function sec:CreateSlider(opts)
		opts = opts or {}
		sec._order = sec._order + 1
		local order = opts.Order or sec._order
		local label = opts.Name or opts.Label or "Slider"
		local min = opts.Min or 0
		local max = opts.Max or 100
		local value = opts.Default or min
		local callback = opts.Callback
		local decimals = opts.Decimals or 2
		local suffix = opts.Suffix or ""

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 34)
		row.BackgroundColor3 = Palette.Row
		row.BorderSizePixel = 0
		row.LayoutOrder = order
		row.Parent = body

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 2)
		corner.Parent = row

		local rowShadow = Instance.new("UIStroke")
		rowShadow.Color = Palette.Shadow
		rowShadow.Thickness = 1
		rowShadow.Transparency = 0.5
		rowShadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		rowShadow.Parent = row

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -80, 0, 16)
		lbl.Position = UDim2.new(0, 10, 0, 3)
		lbl.BackgroundTransparency = 1
		lbl.Text = label
		lbl.TextColor3 = Palette.Text
		lbl.TextSize = 11
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row

		local valLbl = Instance.new("TextLabel")
		valLbl.Size = UDim2.new(0, 70, 0, 16)
		valLbl.Position = UDim2.new(1, -80, 0, 3)
		valLbl.BackgroundTransparency = 1
		valLbl.Text = string.format("%." .. decimals .. "f%s", value, suffix)
		valLbl.TextColor3 = Palette.Muted
		valLbl.TextSize = 11
		valLbl.Font = Enum.Font.Gotham
		valLbl.TextXAlignment = Enum.TextXAlignment.Right
		valLbl.Parent = row

		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(1, -20, 0, 5)
		bar.Position = UDim2.new(0, 10, 0, 23)
		bar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
		bar.BorderSizePixel = 0
		bar.Parent = row

		local barCorner = Instance.new("UICorner")
		barCorner.CornerRadius = UDim.new(0, 1)
		barCorner.Parent = bar

		local fill = Instance.new("Frame")
		fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
		fill.BackgroundColor3 = Accent
		fill.BorderSizePixel = 0
		fill.Parent = bar
		registerAccent(fill)

		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(0, 1)
		fillCorner.Parent = fill

		local sliderDrag = false
		local function update(input)
			local pos = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			value = min + (max - min) * pos
			fill.Size = UDim2.new(pos, 0, 1, 0)
			valLbl.Text = string.format("%." .. decimals .. "f%s", value, suffix)
			if callback then callback(value) end
		end

		bar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				sliderDrag = true
				update(input)
			end
		end)
		UserInputService.InputChanged:Connect(function(input)
			if sliderDrag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				update(input)
			end
		end)
		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				sliderDrag = false
			end
		end)

		return {
			Set = function(v)
				value = math.clamp(v, min, max)
				local pos = (value - min) / (max - min)
				fill.Size = UDim2.new(pos, 0, 1, 0)
				valLbl.Text = string.format("%." .. decimals .. "f%s", value, suffix)
				if callback then callback(value) end
			end,
			Get = function() return value end,
			SetVisible = function(v) row.Visible = v end,
			SetName = function(t) lbl.Text = t end,
		}
	end

	function sec:CreateButton(opts)
		opts = opts or {}
		sec._order = sec._order + 1
		local order = opts.Order or sec._order
		local label = opts.Name or opts.Label or "Button"
		local callback = opts.Callback

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 22)
		btn.BackgroundColor3 = Palette.Row
		btn.BorderSizePixel = 0
		btn.Text = label
		btn.TextColor3 = Palette.Text
		btn.TextSize = 11
		btn.Font = Enum.Font.GothamMedium
		btn.AutoButtonColor = false
		btn.LayoutOrder = order
		btn.Parent = body

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 2)
		corner.Parent = btn

		local stroke = Instance.new("UIStroke")
		stroke.Color = Palette.Outline
		stroke.Thickness = 1
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = btn

		btn.MouseEnter:Connect(function()
			tween(btn, 0.15, { BackgroundColor3 = Palette.RowHover, TextColor3 = Accent })
			tween(stroke, 0.15, { Color = Accent })
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, 0.15, { BackgroundColor3 = Palette.Row, TextColor3 = Palette.Text })
			tween(stroke, 0.15, { Color = Palette.Outline })
		end)
		btn.MouseButton1Click:Connect(function()
			if callback then callback() end
		end)

		return {
			SetName = function(t) btn.Text = t end,
			SetVisible = function(v) btn.Visible = v end,
			Button = btn,
		}
	end

	function sec:CreateDropdown(opts)
		opts = opts or {}
		sec._order = sec._order + 1
		local order = opts.Order or sec._order
		local label = opts.Name or opts.Label or "Dropdown"
		local options = opts.Options or {}
		local selected = opts.Default or options[1]
		local callback = opts.Callback
		local expanded = false

		local wrap = Instance.new("Frame")
		wrap.Size = UDim2.new(1, 0, 0, 22)
		wrap.BackgroundTransparency = 1
		wrap.ClipsDescendants = true
		wrap.LayoutOrder = order
		wrap.Parent = body

		local head = Instance.new("TextButton")
		head.Size = UDim2.new(1, 0, 0, 22)
		head.BackgroundColor3 = Palette.Row
		head.BorderSizePixel = 0
		head.Text = ""
		head.AutoButtonColor = false
		head.Parent = wrap

		local headCorner = Instance.new("UICorner")
		headCorner.CornerRadius = UDim.new(0, 2)
		headCorner.Parent = head

		local headStroke = Instance.new("UIStroke")
		headStroke.Color = Palette.Outline
		headStroke.Thickness = 1
		headStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		headStroke.Parent = head

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -100, 1, 0)
		lbl.Position = UDim2.new(0, 10, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = label
		lbl.TextColor3 = Palette.Text
		lbl.TextSize = 11
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = head

		local valLbl = Instance.new("TextLabel")
		valLbl.Size = UDim2.new(0, 80, 1, 0)
		valLbl.Position = UDim2.new(1, -90, 0, 0)
		valLbl.BackgroundTransparency = 1
		valLbl.Text = selected
		valLbl.TextColor3 = Accent
		valLbl.TextSize = 11
		valLbl.Font = Enum.Font.Gotham
		valLbl.TextXAlignment = Enum.TextXAlignment.Right
		valLbl.Parent = head
		registerAccent(valLbl, "TextColor3")

		local bodyFrame = Instance.new("Frame")
		bodyFrame.Size = UDim2.new(1, 0, 0, #options * 20)
		bodyFrame.Position = UDim2.new(0, 0, 0, 22)
		bodyFrame.BackgroundColor3 = Palette.Panel
		bodyFrame.BorderSizePixel = 0
		bodyFrame.Parent = wrap

		local bodyCorner = Instance.new("UICorner")
		bodyCorner.CornerRadius = UDim.new(0, 2)
		bodyCorner.Parent = bodyFrame

		local bodyOutline = Instance.new("UIStroke")
		bodyOutline.Color = Palette.Outline
		bodyOutline.Thickness = 1
		bodyOutline.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		bodyOutline.Parent = bodyFrame

		local list = Instance.new("UIListLayout")
		list.SortOrder = Enum.SortOrder.LayoutOrder
		list.Parent = bodyFrame

		local function closeDropdown()
			expanded = false
			tween(wrap, 0.25, { Size = UDim2.new(1, 0, 0, 22) }, Enum.EasingStyle.Quart)
		end

		for i, opt in ipairs(options) do
			local o = Instance.new("TextButton")
			o.Size = UDim2.new(1, 0, 0, 20)
			o.BackgroundColor3 = Palette.Panel
			o.BackgroundTransparency = 1
			o.BorderSizePixel = 0
			o.Text = "   " .. tostring(opt)
			o.TextColor3 = Palette.Muted
			o.TextSize = 11
			o.Font = Enum.Font.Gotham
			o.TextXAlignment = Enum.TextXAlignment.Left
			o.AutoButtonColor = false
			o.LayoutOrder = i
			o.Parent = bodyFrame

			o.MouseEnter:Connect(function()
				tween(o, 0.15, { BackgroundTransparency = 0, BackgroundColor3 = Palette.RowHover, TextColor3 = Palette.Text })
			end)
			o.MouseLeave:Connect(function()
				tween(o, 0.15, { BackgroundTransparency = 1, TextColor3 = Palette.Muted })
			end)
			o.MouseButton1Click:Connect(function()
				selected = opt
				valLbl.Text = tostring(opt)
				closeDropdown()
				if callback then callback(selected) end
				sec.Window:SaveConfig()
			end)
		end

		head.MouseButton1Click:Connect(function()
			expanded = not expanded
			local target = expanded and UDim2.new(1, 0, 0, 22 + #options * 20) or UDim2.new(1, 0, 0, 22)
			tween(wrap, 0.25, { Size = target }, Enum.EasingStyle.Quart)
		end)

		return {
			Select = function(v)
				for _, o in ipairs(options) do
					if o == v then
						selected = v
						valLbl.Text = tostring(v)
						if callback then callback(selected) end
						break
					end
				end
			end,
			Get = function() return selected end,
			SetOptions = function(newOpts)
				for _, c in ipairs(bodyFrame:GetChildren()) do
					if c:IsA("TextButton") then c:Destroy() end
				end
				options = newOpts
				bodyFrame.Size = UDim2.new(1, 0, 0, #options * 20)
				for i, opt in ipairs(options) do
					local o = Instance.new("TextButton")
					o.Size = UDim2.new(1, 0, 0, 20)
					o.BackgroundColor3 = Palette.Panel
					o.BackgroundTransparency = 1
					o.BorderSizePixel = 0
					o.Text = "   " .. tostring(opt)
					o.TextColor3 = Palette.Muted
					o.TextSize = 11
					o.Font = Enum.Font.Gotham
					o.TextXAlignment = Enum.TextXAlignment.Left
					o.AutoButtonColor = false
					o.LayoutOrder = i
					o.Parent = bodyFrame
					o.MouseEnter:Connect(function()
						tween(o, 0.15, { BackgroundTransparency = 0, BackgroundColor3 = Palette.RowHover, TextColor3 = Palette.Text })
					end)
					o.MouseLeave:Connect(function()
						tween(o, 0.15, { BackgroundTransparency = 1, TextColor3 = Palette.Muted })
					end)
					o.MouseButton1Click:Connect(function()
						selected = opt
						valLbl.Text = tostring(opt)
						closeDropdown()
						if callback then callback(selected) end
					end)
				end
			end,
			SetVisible = function(v) wrap.Visible = v end,
			SetName = function(t) lbl.Text = t end,
		}
	end

	function sec:CreateMultiDropdown(opts)
		opts = opts or {}
		sec._order = sec._order + 1
		local order = opts.Order or sec._order
		local label = opts.Name or opts.Label or "Multi"
		local options = opts.Options or {}
		local callback = opts.Callback
		local selected = {}
		for _, d in ipairs(opts.Default or {}) do selected[d] = true end

		local wrap = Instance.new("Frame")
		wrap.Size = UDim2.new(1, 0, 0, 22)
		wrap.BackgroundTransparency = 1
		wrap.ClipsDescendants = true
		wrap.LayoutOrder = order
		wrap.Parent = body

		local head = Instance.new("TextButton")
		head.Size = UDim2.new(1, 0, 0, 22)
		head.BackgroundColor3 = Palette.Row
		head.BorderSizePixel = 0
		head.Text = ""
		head.AutoButtonColor = false
		head.Parent = wrap

		local hc = Instance.new("UICorner")
		hc.CornerRadius = UDim.new(0, 2)
		hc.Parent = head

		local hs = Instance.new("UIStroke")
		hs.Color = Palette.Outline
		hs.Thickness = 1
		hs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		hs.Parent = head

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -100, 1, 0)
		lbl.Position = UDim2.new(0, 10, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = label
		lbl.TextColor3 = Palette.Text
		lbl.TextSize = 11
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = head

		local valLbl = Instance.new("TextLabel")
		valLbl.Size = UDim2.new(0, 80, 1, 0)
		valLbl.Position = UDim2.new(1, -90, 0, 0)
		valLbl.BackgroundTransparency = 1
		valLbl.Text = "..."
		valLbl.TextColor3 = Accent
		valLbl.TextSize = 11
		valLbl.Font = Enum.Font.Gotham
		valLbl.TextXAlignment = Enum.TextXAlignment.Right
		valLbl.Parent = head
		registerAccent(valLbl, "TextColor3")

		local bodyFrame = Instance.new("Frame")
		bodyFrame.Size = UDim2.new(1, 0, 0, #options * 20)
		bodyFrame.Position = UDim2.new(0, 0, 0, 22)
		bodyFrame.BackgroundColor3 = Palette.Panel
		bodyFrame.BorderSizePixel = 0
		bodyFrame.Parent = wrap

		local bc = Instance.new("UICorner")
		bc.CornerRadius = UDim.new(0, 2)
		bc.Parent = bodyFrame

		local bo = Instance.new("UIStroke")
		bo.Color = Palette.Outline
		bo.Thickness = 1
		bo.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		bo.Parent = bodyFrame

		local list = Instance.new("UIListLayout")
		list.SortOrder = Enum.SortOrder.LayoutOrder
		list.Parent = bodyFrame

		local function updateText()
			local n = 0
			for _ in pairs(selected) do n = n + 1 end
			valLbl.Text = n == 0 and "none" or n .. " selected"
		end
		updateText()

		local function fire()
			local arr = {}
			for k in pairs(selected) do table.insert(arr, k) end
			if callback then callback(arr) end
		end

		for i, opt in ipairs(options) do
			local o = Instance.new("TextButton")
			o.Size = UDim2.new(1, 0, 0, 20)
			o.BackgroundColor3 = Palette.Panel
			o.BackgroundTransparency = 1
			o.BorderSizePixel = 0
			o.Text = "   " .. tostring(opt)
			o.TextColor3 = selected[opt] and Accent or Palette.Muted
			o.TextSize = 11
			o.Font = Enum.Font.Gotham
			o.TextXAlignment = Enum.TextXAlignment.Left
			o.AutoButtonColor = false
			o.LayoutOrder = i
			o.Parent = bodyFrame

			o.MouseEnter:Connect(function()
				tween(o, 0.15, { BackgroundTransparency = 0, BackgroundColor3 = Palette.RowHover })
			end)
			o.MouseLeave:Connect(function()
				tween(o, 0.15, { BackgroundTransparency = 1 })
			end)
			o.MouseButton1Click:Connect(function()
				if selected[opt] then
					selected[opt] = nil
					o.TextColor3 = Palette.Muted
				else
					selected[opt] = true
					o.TextColor3 = Accent
				end
				updateText()
				fire()
			end)
		end

		local expanded = false
		head.MouseButton1Click:Connect(function()
			expanded = not expanded
			local target = expanded and UDim2.new(1, 0, 0, 22 + #options * 20) or UDim2.new(1, 0, 0, 22)
			tween(wrap, 0.25, { Size = target }, Enum.EasingStyle.Quart)
		end)

		return {
			Get = function()
				local arr = {}
				for k in pairs(selected) do table.insert(arr, k) end
				return arr
			end,
			Set = function(arr)
				selected = {}
				for _, v in ipairs(arr) do selected[v] = true end
				updateText()
				fire()
			end,
			SetVisible = function(v) wrap.Visible = v end,
			SetName = function(t) lbl.Text = t end,
		}
	end

	function sec:CreateColorPicker(opts)
		opts = opts or {}
		sec._order = sec._order + 1
		local order = opts.Order or sec._order
		local label = opts.Name or opts.Label or "Color"
		local current = opts.Default or Accent
		local callback = opts.Callback

		local h, s, v = Color3.toHSV(current)

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 26)
		row.BackgroundColor3 = Palette.Row
		row.BorderSizePixel = 0
		row.LayoutOrder = order
		row.Parent = body

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 2)
		corner.Parent = row

		local rowShadow = Instance.new("UIStroke")
		rowShadow.Color = Palette.Shadow
		rowShadow.Thickness = 1
		rowShadow.Transparency = 0.5
		rowShadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		rowShadow.Parent = row

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -70, 1, 0)
		lbl.Position = UDim2.new(0, 10, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = label
		lbl.TextColor3 = Palette.Text
		lbl.TextSize = 11
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row

		local preview = Instance.new("TextButton")
		preview.Size = UDim2.new(0, 40, 0, 16)
		preview.Position = UDim2.new(1, -48, 0.5, -8)
		preview.BackgroundColor3 = current
		preview.BorderSizePixel = 0
		preview.Text = ""
		preview.AutoButtonColor = false
		preview.Parent = row

		local pc = Instance.new("UICorner")
		pc.CornerRadius = UDim.new(0, 2)
		pc.Parent = preview

		local ps = Instance.new("UIStroke")
		ps.Color = Palette.Outline
		ps.Thickness = 1
		ps.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		ps.Parent = preview

		local popup = nil
		local pickerConns = {}

		local function addConn(c)
			table.insert(pickerConns, c)
			return c
		end

		local function cleanupPicker()
			for _, c in ipairs(pickerConns) do
				pcall(function() c:Disconnect() end)
			end
			pickerConns = {}
		end

		local function buildPopup()
			if popup then return end
			local sg = sec.Window.ScreenGui

			popup = Instance.new("Frame")
			popup.Name = "AcursiveColorPicker"
			popup.Size = UDim2.new(0, 200, 0, 220)
			popup.BackgroundColor3 = Palette.Panel
			popup.BorderSizePixel = 0
			popup.ZIndex = 150
			popup.Parent = sg

			local absPos = preview.AbsolutePosition
			local absSize = preview.AbsoluteSize
			popup.Position = UDim2.new(0, absPos.X - 160 + absSize.X, 0, absPos.Y + absSize.Y + 6)

			local pCorner = Instance.new("UICorner")
			pCorner.CornerRadius = UDim.new(0, 3)
			pCorner.Parent = popup

			local pStroke = Instance.new("UIStroke")
			pStroke.Color = Palette.Outline
			pStroke.Thickness = 1
			pStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			pStroke.Parent = popup

			local pShadow = Instance.new("UIStroke")
			pShadow.Color = Palette.Shadow
			pShadow.Thickness = 2
			pShadow.Transparency = 0.3
			pShadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			pShadow.Parent = popup

			local header = Instance.new("TextLabel")
			header.Size = UDim2.new(1, -30, 0, 20)
			header.Position = UDim2.new(0, 10, 0, 5)
			header.BackgroundTransparency = 1
			header.Text = label
			header.TextColor3 = Palette.TextBright
			header.TextSize = 11
			header.Font = Enum.Font.GothamBold
			header.TextXAlignment = Enum.TextXAlignment.Left
			header.ZIndex = 151
			header.Parent = popup

			local closeBtn = Instance.new("TextButton")
			closeBtn.Size = UDim2.new(0, 18, 0, 18)
			closeBtn.Position = UDim2.new(1, -22, 0, 5)
			closeBtn.BackgroundColor3 = Palette.Input
			closeBtn.BorderSizePixel = 0
			closeBtn.Text = "X"
			closeBtn.TextColor3 = Palette.Muted
			closeBtn.TextSize = 10
			closeBtn.Font = Enum.Font.GothamBold
			closeBtn.AutoButtonColor = false
			closeBtn.ZIndex = 151
			closeBtn.Parent = popup

			local cbCorner = Instance.new("UICorner")
			cbCorner.CornerRadius = UDim.new(0, 2)
			cbCorner.Parent = closeBtn

			local satSquare = Instance.new("Frame")
			satSquare.Size = UDim2.new(0, 180, 0, 130)
			satSquare.Position = UDim2.new(0, 10, 0, 30)
			satSquare.BackgroundColor3 = Color3.new(1, 1, 1)
			satSquare.BorderSizePixel = 0
			satSquare.ZIndex = 151
			satSquare.Parent = popup

			local sqCorner = Instance.new("UICorner")
			sqCorner.CornerRadius = UDim.new(0, 2)
			sqCorner.Parent = satSquare

			local gradH = Instance.new("UIGradient")
			gradH.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHSV(h, 0, 1)),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(h, 1, 1)),
			})
			gradH.Parent = satSquare

			local overlay = Instance.new("Frame")
			overlay.Size = UDim2.new(1, 0, 1, 0)
			overlay.BackgroundColor3 = Color3.new(0, 0, 0)
			overlay.BorderSizePixel = 0
			overlay.ZIndex = 152
			overlay.Parent = satSquare

			local ovCorner = Instance.new("UICorner")
			ovCorner.CornerRadius = UDim.new(0, 2)
			ovCorner.Parent = overlay

			local gradV = Instance.new("UIGradient")
			gradV.Rotation = 90
			gradV.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 0),
			})
			gradV.Parent = overlay

			local satCursor = Instance.new("Frame")
			satCursor.Size = UDim2.new(0, 10, 0, 10)
			satCursor.AnchorPoint = Vector2.new(0.5, 0.5)
			satCursor.Position = UDim2.new(s, 0, 1 - v, 0)
			satCursor.BackgroundTransparency = 1
			satCursor.ZIndex = 153
			satCursor.Parent = satSquare

			local scOuter = Instance.new("UIStroke")
			scOuter.Color = Color3.new(1, 1, 1)
			scOuter.Thickness = 2
			scOuter.Parent = satCursor

			local scInner = Instance.new("UIStroke")
			scInner.Color = Color3.new(0, 0, 0)
			scInner.Thickness = 1
			scInner.Parent = satCursor

			local scCorner2 = Instance.new("UICorner")
			scCorner2.CornerRadius = UDim.new(1, 0)
			scCorner2.Parent = satCursor

			local hueSlider = Instance.new("Frame")
			hueSlider.Size = UDim2.new(0, 180, 0, 12)
			hueSlider.Position = UDim2.new(0, 10, 0, 170)
			hueSlider.BackgroundColor3 = Color3.new(1, 0, 0)
			hueSlider.BorderSizePixel = 0
			hueSlider.ZIndex = 151
			hueSlider.Parent = popup

			local hsCorner = Instance.new("UICorner")
			hsCorner.CornerRadius = UDim.new(0, 2)
			hsCorner.Parent = hueSlider

			local hueGrad = Instance.new("UIGradient")
			hueGrad.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0.000, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
				ColorSequenceKeypoint.new(0.500, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
				ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
				ColorSequenceKeypoint.new(1.000, Color3.fromRGB(255, 0, 0)),
			})
			hueGrad.Parent = hueSlider

			local hueCursor = Instance.new("Frame")
			hueCursor.Size = UDim2.new(0, 4, 1, 4)
			hueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
			hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
			hueCursor.BackgroundTransparency = 1
			hueCursor.ZIndex = 153
			hueCursor.Parent = hueSlider

			local hcOuter = Instance.new("UIStroke")
			hcOuter.Color = Color3.new(1, 1, 1)
			hcOuter.Thickness = 2
			hcOuter.Parent = hueCursor

			local hcInner = Instance.new("UIStroke")
			hcInner.Color = Color3.new(0, 0, 0)
			hcInner.Thickness = 1
			hcInner.Parent = hueCursor

			local hcCorner = Instance.new("UICorner")
			hcCorner.CornerRadius = UDim.new(0, 1)
			hcCorner.Parent = hueCursor

			local hexBox = Instance.new("TextBox")
			hexBox.Size = UDim2.new(0, 180, 0, 20)
			hexBox.Position = UDim2.new(0, 10, 0, 190)
			hexBox.BackgroundColor3 = Palette.Input
			hexBox.BorderSizePixel = 0
			hexBox.Text = string.format("#%02X%02X%02X", math.floor(current.R * 255), math.floor(current.G * 255), math.floor(current.B * 255))
			hexBox.TextColor3 = Palette.Text
			hexBox.TextSize = 11
			hexBox.Font = Enum.Font.Code
			hexBox.ClearTextOnFocus = false
			hexBox.ZIndex = 151
			hexBox.Parent = popup

			local hbCorner = Instance.new("UICorner")
			hbCorner.CornerRadius = UDim.new(0, 2)
			hbCorner.Parent = hexBox

			local hbStroke = Instance.new("UIStroke")
			hbStroke.Color = Palette.Outline
			hbStroke.Thickness = 1
			hbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			hbStroke.Parent = hexBox

			local hbPad = Instance.new("UIPadding")
			hbPad.PaddingLeft = UDim.new(0, 6)
			hbPad.Parent = hexBox

			local magnifier = nil

			local function refreshAll()
				satSquare.BackgroundColor3 = Color3.new(1, 1, 1)
				gradH.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(h, 0, 1)),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(h, 1, 1)),
				})
				satCursor.Position = UDim2.new(s, 0, 1 - v, 0)
				hueCursor.Position = UDim2.new(h, 0, 0.5, 0)
				preview.BackgroundColor3 = current
				hexBox.Text = string.format("#%02X%02X%02X", math.floor(current.R * 255), math.floor(current.G * 255), math.floor(current.B * 255))
			end

			local function showMagnifier()
				if not magnifier then
					magnifier = Instance.new("Frame")
					magnifier.Name = "PickerMagnifier"
					magnifier.Size = UDim2.new(0, 0, 0, 0)
					magnifier.AnchorPoint = Vector2.new(0.5, 0.5)
					magnifier.BackgroundColor3 = current
					magnifier.BorderSizePixel = 0
					magnifier.ZIndex = 300
					magnifier.Parent = sec.Window.ScreenGui

					local mCorner = Instance.new("UICorner")
					mCorner.CornerRadius = UDim.new(1, 0)
					mCorner.Parent = magnifier

					local mStroke = Instance.new("UIStroke")
					mStroke.Color = Color3.new(1, 1, 1)
					mStroke.Thickness = 2
					mStroke.Parent = magnifier

					local mShadow = Instance.new("UIStroke")
					mShadow.Color = Color3.new(0, 0, 0)
					mShadow.Thickness = 1
					mShadow.Transparency = 0.4
					mShadow.Parent = magnifier

					local innerDot = Instance.new("Frame")
					innerDot.Size = UDim2.new(0, 5, 0, 5)
					innerDot.AnchorPoint = Vector2.new(0.5, 0.5)
					innerDot.Position = UDim2.new(0.5, 0, 0.5, 0)
					innerDot.BackgroundTransparency = 1
					innerDot.ZIndex = 302
					innerDot.Parent = magnifier

					local idCorner = Instance.new("UICorner")
					idCorner.CornerRadius = UDim.new(1, 0)
					idCorner.Parent = innerDot

					local idOuter = Instance.new("UIStroke")
					idOuter.Color = Color3.new(1, 1, 1)
					idOuter.Thickness = 2
					idOuter.Parent = innerDot

					local idInner = Instance.new("UIStroke")
					idInner.Color = Color3.new(0, 0, 0)
					idInner.Thickness = 1
					idInner.Parent = innerDot

					local glow = Instance.new("UIStroke")
					glow.Color = current
					glow.Thickness = 4
					glow.Transparency = 0.4
					glow.Parent = magnifier

					TweenService:Create(magnifier, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = UDim2.new(0, 88, 0, 88)
					}):Play()
				end

				magnifier.BackgroundColor3 = current
				local mousePos = UserInputService:GetMouseLocation()
				magnifier.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y - 70)

				for _, c in ipairs(magnifier:GetChildren()) do
					if c:IsA("UIStroke") and c.Thickness == 4 then
						c.Color = current
					end
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
						if m then pcall(function() m:Destroy() end) end
					end)
				end
			end

			local draggingSat, draggingHue = false, false

			local function updateFromSat(input)
				local relX = math.clamp((input.Position.X - satSquare.AbsolutePosition.X) / satSquare.AbsoluteSize.X, 0, 1)
				local relY = math.clamp((input.Position.Y - satSquare.AbsolutePosition.Y) / satSquare.AbsoluteSize.Y, 0, 1)
				s = relX
				v = 1 - relY
				current = Color3.fromHSV(h, s, v)
				refreshAll()
				if callback then callback(current) end
			end

			local function updateFromHue(input)
				local relX = math.clamp((input.Position.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
				h = relX
				current = Color3.fromHSV(h, s, v)
				refreshAll()
				if callback then callback(current) end
			end

			satSquare.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					draggingSat = true
					updateFromSat(input)
					showMagnifier()
				end
			end)

			hueSlider.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					draggingHue = true
					updateFromHue(input)
				end
			end)

			addConn(UserInputService.InputChanged:Connect(function(input)
				if draggingSat and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					updateFromSat(input)
					showMagnifier()
				end
				if draggingHue and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
					updateFromHue(input)
				end
			end))

			addConn(UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					if draggingSat then
						draggingSat = false
						hideMagnifier()
						sec.Window:SaveConfig()
					end
					if draggingHue then
						draggingHue = false
						sec.Window:SaveConfig()
					end
				end
			end))

			hexBox.FocusLost:Connect(function()
				local hex = hexBox.Text:gsub("#", "")
				if #hex == 6 then
					local rn = tonumber(hex:sub(1, 2), 16)
					local gn = tonumber(hex:sub(3, 4), 16)
					local bn = tonumber(hex:sub(5, 6), 16)
					if rn and gn and bn then
						current = Color3.fromRGB(rn, gn, bn)
						h, s, v = Color3.toHSV(current)
						refreshAll()
						if callback then callback(current) end
					end
				end
			end)

			local function destroyPopup()
				if magnifier then
					pcall(function() magnifier:Destroy() end)
					magnifier = nil
				end
				cleanupPicker()
				if popup then
					popup:Destroy()
					popup = nil
				end
			end

			closeBtn.MouseButton1Click:Connect(destroyPopup)

			refreshAll()
		end

		preview.MouseButton1Click:Connect(function()
			if popup then
				if magnifier then pcall(function() magnifier:Destroy() end) end
				cleanupPicker()
				popup:Destroy()
				popup = nil
			else
				buildPopup()
			end
		end)

		return {
			Get = function() return current end,
			Set = function(c)
				current = c
				h, s, v = Color3.toHSV(c)
				preview.BackgroundColor3 = c
				if popup then
					pcall(function()
						for _, child in ipairs(popup:GetDescendants()) do
							if child.Name == "PickerMagnifier" then
								child.BackgroundColor3 = c
							end
						end
					end)
				end
				if callback then callback(c) end
			end,
			SetVisible = function(v) row.Visible = v end,
			SetName = function(t) lbl.Text = t end,
		}
	end

	function sec:CreateKeybind(opts)
		opts = opts or {}
		sec._order = sec._order + 1
		local order = opts.Order or sec._order
		local label = opts.Name or opts.Label or "Keybind"
		local defaultKey = opts.Default or Enum.KeyCode.E
		local callback = opts.Callback

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 22)
		row.BackgroundColor3 = Palette.Row
		row.BorderSizePixel = 0
		row.LayoutOrder = order
		row.Parent = body

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 2)
		corner.Parent = row

		local rowShadow = Instance.new("UIStroke")
		rowShadow.Color = Palette.Shadow
		rowShadow.Thickness = 1
		rowShadow.Transparency = 0.5
		rowShadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		rowShadow.Parent = row

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -80, 1, 0)
		lbl.Position = UDim2.new(0, 10, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = label
		lbl.TextColor3 = Palette.Text
		lbl.TextSize = 11
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row

		local keyBtn = Instance.new("TextButton")
		keyBtn.Size = UDim2.new(0, 55, 0, 14)
		keyBtn.Position = UDim2.new(1, -65, 0.5, -7)
		keyBtn.BackgroundColor3 = Palette.Input
		keyBtn.BorderSizePixel = 0
		keyBtn.Text = tostring(defaultKey):gsub("Enum.KeyCode.", "")
		keyBtn.TextColor3 = Accent
		keyBtn.TextSize = 10
		keyBtn.Font = Enum.Font.Gotham
		keyBtn.AutoButtonColor = false
		keyBtn.Parent = row

		local kbCorner = Instance.new("UICorner")
		kbCorner.CornerRadius = UDim.new(0, 2)
		kbCorner.Parent = keyBtn

		local kbStroke = Instance.new("UIStroke")
		kbStroke.Color = Palette.Outline
		kbStroke.Thickness = 1
		kbStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		kbStroke.Parent = keyBtn

		local keyEntry = { key = defaultKey, callback = function() if callback then callback() end end }
		table.insert(activeKeybinds, keyEntry)

		keyBtn.MouseEnter:Connect(function()
			tween(keyBtn, 0.15, { BackgroundColor3 = Color3.fromRGB(24, 24, 24) })
			tween(kbStroke, 0.15, { Color = Accent })
		end)
		keyBtn.MouseLeave:Connect(function()
			tween(keyBtn, 0.15, { BackgroundColor3 = Palette.Input })
			tween(kbStroke, 0.15, { Color = Palette.Outline })
		end)
		keyBtn.MouseButton1Click:Connect(function()
			if keyCapture then return end
			keyBtn.Text = "..."
			keyCapture = function(keyCode)
				keyEntry.key = keyCode
				keyBtn.Text = tostring(keyCode):gsub("Enum.KeyCode.", "")
			end
		end)

		return {
			Get = function() return keyEntry.key end,
			Set = function(k) keyEntry.key = k keyBtn.Text = tostring(k):gsub("Enum.KeyCode.", "") end,
			SetVisible = function(v) row.Visible = v end,
			SetName = function(t) lbl.Text = t end,
		}
	end

	function sec:CreateTextbox(opts)
		opts = opts or {}
		sec._order = sec._order + 1
		local order = opts.Order or sec._order
		local label = opts.Name or opts.Label or "Input"
		local default = opts.Default or ""
		local placeholder = opts.Placeholder or ""
		local callback = opts.Callback
		local clearOnFocus = opts.ClearOnFocus ~= false

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 22)
		row.BackgroundColor3 = Palette.Row
		row.BorderSizePixel = 0
		row.LayoutOrder = order
		row.Parent = body

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 2)
		corner.Parent = row

		local rowShadow = Instance.new("UIStroke")
		rowShadow.Color = Palette.Shadow
		rowShadow.Thickness = 1
		rowShadow.Transparency = 0.5
		rowShadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		rowShadow.Parent = row

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0, 100, 1, 0)
		lbl.Position = UDim2.new(0, 10, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = label
		lbl.TextColor3 = Palette.Text
		lbl.TextSize = 11
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row

		local box = Instance.new("TextBox")
		box.Size = UDim2.new(1, -120, 0, 16)
		box.Position = UDim2.new(0, 110, 0.5, -8)
		box.BackgroundColor3 = Palette.Input
		box.BorderSizePixel = 0
		box.Text = default
		box.PlaceholderText = placeholder
		box.TextColor3 = Palette.Text
		box.PlaceholderColor3 = Palette.Muted
		box.TextSize = 11
		box.Font = Enum.Font.Gotham
		box.ClearTextOnFocus = clearOnFocus
		box.TextXAlignment = Enum.TextXAlignment.Left
		box.Parent = row

		local bc = Instance.new("UICorner")
		bc.CornerRadius = UDim.new(0, 2)
		bc.Parent = box

		local bs = Instance.new("UIStroke")
		bs.Color = Palette.Outline
		bs.Thickness = 1
		bs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		bs.Parent = box

		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, 6)
		pad.Parent = box

		box.FocusLost:Connect(function()
			tween(bs, 0.15, { Color = Palette.Outline })
			if callback then callback(box.Text) end
		end)
		box.Focused:Connect(function()
			tween(bs, 0.15, { Color = Accent })
		end)

		return {
			Get = function() return box.Text end,
			Set = function(v) box.Text = v if callback then callback(v) end end,
			SetVisible = function(v) row.Visible = v end,
			SetName = function(t) lbl.Text = t end,
		}
	end

	function sec:CreateLabel(opts)
		opts = opts or {}
		sec._order = sec._order + 1
		local order = opts.Order or sec._order
		local text = opts.Name or opts.Text or opts.Label or "Label"
		local color = opts.Color or Palette.Text
		local size = opts.Size or 11
		local alignment = opts.Align or Enum.TextXAlignment.Left

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, 0, 0, 18)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.TextColor3 = color
		lbl.TextSize = size
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = alignment
		lbl.LayoutOrder = order
		lbl.Parent = body

		return {
			Set = function(t) lbl.Text = t end,
			Get = function() return lbl.Text end,
			SetVisible = function(v) lbl.Visible = v end,
		}
	end

	function sec:CreateParagraph(opts)
		opts = opts or {}
		sec._order = sec._order + 1
		local order = opts.Order or sec._order
		local title = opts.Title or "Info"
		local content = opts.Content or opts.Text or ""

		local wrap = Instance.new("Frame")
		wrap.Size = UDim2.new(1, 0, 0, 0)
		wrap.AutomaticSize = Enum.AutomaticSize.Y
		wrap.BackgroundColor3 = Palette.Row
		wrap.BorderSizePixel = 0
		wrap.LayoutOrder = order
		wrap.Parent = body

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 2)
		corner.Parent = wrap

		local stroke = Instance.new("UIStroke")
		stroke.Color = Palette.Outline
		stroke.Thickness = 1
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = wrap

		local layout = Instance.new("UIListLayout")
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = wrap

		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, 6)
		pad.PaddingBottom = UDim.new(0, 6)
		pad.PaddingLeft = UDim.new(0, 10)
		pad.PaddingRight = UDim.new(0, 10)
		pad.Parent = wrap

		local t = Instance.new("TextLabel")
		t.Size = UDim2.new(1, 0, 0, 16)
		t.BackgroundTransparency = 1
		t.Text = title
		t.TextColor3 = Accent
		t.TextSize = 11
		t.Font = Enum.Font.GothamBold
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.LayoutOrder = 1
		t.Parent = wrap
		registerAccent(t, "TextColor3")

		local c = Instance.new("TextLabel")
		c.Size = UDim2.new(1, 0, 0, 0)
		c.AutomaticSize = Enum.AutomaticSize.Y
		c.BackgroundTransparency = 1
		c.Text = content
		c.TextColor3 = Palette.Muted
		c.TextSize = 11
		c.Font = Enum.Font.Gotham
		c.TextXAlignment = Enum.TextXAlignment.Left
		c.TextWrapped = true
		c.TextYAlignment = Enum.TextYAlignment.Top
		c.LayoutOrder = 2
		c.Parent = wrap

		return {
			SetTitle = function(v) t.Text = v end,
			SetContent = function(v) c.Text = v end,
			SetVisible = function(v) wrap.Visible = v end,
		}
	end

	function sec:CreateDivider()
		sec._order = sec._order + 1
		local line = Instance.new("Frame")
		line.Size = UDim2.new(1, 0, 0, 1)
		line.BackgroundColor3 = Palette.Outline
		line.BorderSizePixel = 0
		line.LayoutOrder = sec._order
		line.Parent = body
		return { Frame = line }
	end

	function sec:CreateImage(opts)
		opts = opts or {}
		sec._order = sec._order + 1
		local order = opts.Order or sec._order
		local image = opts.Image or ""
		local height = opts.Height or 100

		local img = Instance.new("ImageLabel")
		img.Size = UDim2.new(1, 0, 0, height)
		img.BackgroundColor3 = Palette.Row
		img.BorderSizePixel = 0
		img.Image = image
		img.ScaleType = opts.ScaleType or Enum.ScaleType.Fit
		img.LayoutOrder = order
		img.Parent = body

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 2)
		corner.Parent = img

		local stroke = Instance.new("UIStroke")
		stroke.Color = Palette.Outline
		stroke.Thickness = 1
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = img

		return {
			SetImage = function(v) img.Image = v end,
			SetVisible = function(v) img.Visible = v end,
		}
	end

	return sec
end

function TabClass:Select()
	self.Window:SelectTab(self.Name)
end

function TabClass:GetName()
	return self.Name
end

if getgenv then
	getgenv().Acursive = Acursive
end

return Acursive
