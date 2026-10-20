-- https://github.com/questivful/Acursive
--[[
	Acursive
	V3.15 ~

	[+] Windows: multiple draggable / dockable windows with drag bar
	[+] Tabs: bar nav (top/bottom) or wheel nav (left/right)
	[+] Sections: collapsible groups with per-tab search bar
	[+] Controls: toggle, slider, button, dropdown, multidropdown,
	              colorpicker, keybind, textbox, label, paragraph,
	              divider, image, progressbar, numberstepper,
	              radiogroup, searchbox
	[+] Themes: orange, blue, green, purple, pink, red, cyan, yellow,
	            white, dark + rgb mode + custom accent + custom theme
	[+] Docking: dock tabs to sides with resizable stacked panels
	[+] Focus Mode: blur, hide player guis + roblox guis, fov drop
	[+] Notifications: stacked list with progress bars and accents
	[+] Config: save / load toggles and last tab
	[+] CleanUpCrew: every conn, thread, tween tracked and cleaned on destroy
	[+] Fail Feedback: safe pcall wrapping for user callbacks
	[+] Modularity: per-window style overrides on top of global style
	[+] Profile: rotating viewport character with account info kindve broken
]]

local acursive = {}
acursive.__index = acursive

local players = game:GetService("Players")
local coregui = game:GetService("CoreGui")
local tween = game:GetService("TweenService")
local input = game:GetService("UserInputService")
local run = game:GetService("RunService")
local http = game:GetService("HttpService")
local lighting = game:GetService("Lighting")
local starter = game:GetService("StarterGui")

local player = players.LocalPlayer

local themes = {
	orange = {main = Color3.fromRGB(255, 140, 50), light = Color3.fromRGB(255, 240, 225)},
	blue = {main = Color3.fromRGB(80, 160, 255), light = Color3.fromRGB(220, 240, 255)},
	green = {main = Color3.fromRGB(80, 220, 120), light = Color3.fromRGB(215, 255, 225)},
	purple = {main = Color3.fromRGB(180, 100, 255), light = Color3.fromRGB(240, 220, 255)},
	pink = {main = Color3.fromRGB(255, 100, 180), light = Color3.fromRGB(255, 220, 240)},
	red = {main = Color3.fromRGB(255, 80, 80), light = Color3.fromRGB(255, 220, 220)},
	cyan = {main = Color3.fromRGB(80, 220, 220), light = Color3.fromRGB(220, 255, 255)},
	yellow = {main = Color3.fromRGB(255, 220, 80), light = Color3.fromRGB(255, 245, 215)},
	white = {main = Color3.fromRGB(240, 240, 240), light = Color3.fromRGB(255, 255, 255)},
	dark = {main = Color3.fromRGB(90, 90, 100), light = Color3.fromRGB(150, 150, 160)},
}

local palette = {
	panel = Color3.fromRGB(14, 14, 14),
	row = Color3.fromRGB(20, 20, 20),
	rowhover = Color3.fromRGB(26, 26, 26),
	rowactive = Color3.fromRGB(32, 32, 32),
	edge = Color3.fromRGB(32, 32, 32),
	shadow = Color3.fromRGB(0, 0, 0),
	txt = Color3.fromRGB(210, 210, 210),
	txtbright = Color3.fromRGB(255, 255, 255),
	muted = Color3.fromRGB(120, 120, 120),
	field = Color3.fromRGB(16, 16, 16),
	dark = Color3.fromRGB(10, 10, 10),
}

acursive.themes = themes
acursive.palette = palette
acursive.version = "2.1.0"
acursive.author = "Quest"

local accent = themes.orange.main
local accentlight = themes.orange.light
local curtheme = "orange"
local rgbmode = false
local rgbhue = 0

local acctargets = {}
local acgradients = {}
local keybinds = {}
local keycap = nil
local cons = {}
local threads = {}
local tweens = {}
local winlist = {}
local gui
local notifbox
local notifid = 0

local focus = {
	on = false,
	blur = nil,
	pgui = nil,
	parts = {},
	con = nil,
	fov = nil,
	hpguid = {},
	hrgui = {},
	states = {},
	depth = 0,
}

local function tostr(v)
	if v == nil then return "" end
	return tostring(v)
end

local function track(c)
	if c then table.insert(cons, c) end
	return c
end

local function trackthread(t)
	if t then table.insert(threads, t) end
	return t
end

local function tracktween(t)
	if t then table.insert(tweens, t) end
	return t
end

local function safecall(fn, ...)
	if type(fn) ~= "function" then return false end
	local ok, err = pcall(fn, ...)
	if not ok then warn("[Acursive] callback error: " .. tostring(err)) end
	return ok
end

local function istyping()
	return input:GetFocusedTextBox() ~= nil
end

local function tw(inst, time, props, style, dir)
	if not inst or not inst.Parent then return nil end
	local t = tween:Create(
		inst,
		TweenInfo.new(time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out),
		props
	)
	t:Play()
	table.insert(tweens, t)
	return t
end

local function regaccent(inst, prop)
	table.insert(acctargets, {inst = inst, prop = prop or "BackgroundColor3"})
end

local function regaccentfn(fn)
	table.insert(acctargets, {apply = fn})
end

local function applyaccent(color, light)
	accent = color
	accentlight = light or color:Lerp(Color3.new(1, 1, 1), 0.7)
	for _, e in ipairs(acctargets) do
		if e.apply then
			pcall(e.apply)
		elseif e.inst then
			pcall(function() e.inst[e.prop] = accent end)
		end
	end
	for _, g in ipairs(acgradients) do
		if g and g.Parent then
			pcall(function()
				g.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, accent),
					ColorSequenceKeypoint.new(0.5, accentlight),
					ColorSequenceKeypoint.new(1, accent),
				})
			end)
		end
	end
end

local function makegrad(parent)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, accent),
		ColorSequenceKeypoint.new(0.5, accentlight),
		ColorSequenceKeypoint.new(1, accent),
	})
	g.Parent = parent
	table.insert(acgradients, g)
	return g
end

local function pruneaccent()
	for i = #acctargets, 1, -1 do
		local e = acctargets[i]
		if e.inst and not e.inst.Parent then
			table.remove(acctargets, i)
		end
	end
	for i = #acgradients, 1, -1 do
		local g = acgradients[i]
		if not g or not g.Parent then
			table.remove(acgradients, i)
		end
	end
end

function acursive:getaccent()   return accent end
function acursive:gettheme()    return curtheme end
function acursive:isrgb()       return rgbmode end
function acursive:getbinds()    return keybinds end
function acursive:getversion()  return acursive.version end
function acursive:getauthor()   return acursive.author end

function acursive:setaccent(color, light)
	rgbmode = false
	curtheme = nil
	applyaccent(color, light)
end

function acursive:settheme(name)
	local t = themes[name]
	if not t then return end
	rgbmode = false
	curtheme = name
	applyaccent(t.main, t.light)
end

function acursive:setrgb(enabled)
	rgbmode = enabled and true or false
end

local function hostgui()
	if gui and gui.Parent then return gui.Parent end
	local ok, roblox = pcall(function()
		if coregui:FindFirstChild("RobloxGui") then return coregui.RobloxGui end
		return nil
	end)
	if ok and roblox then return roblox end
	return player:WaitForChild("PlayerGui")
end

function focus:_createparts()
	if self.pgui then return end
	local host = hostgui()
	local sg = Instance.new("ScreenGui")
	sg.Name = "AcursiveFocus"
	sg.ResetOnSpawn = false
	sg.IgnoreGuiInset = true
	sg.DisplayOrder = -1
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	sg.Parent = host
	self.pgui = sg

	for i = 1, 22 do
		local size = math.random(3, 9)
		local p = Instance.new("Frame")
		p.Name = "part_" .. i
		p.Size = UDim2.new(0, size, 0, size)
		p.Position = UDim2.new(math.random(), 0, math.random(), 0)
		p.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		p.BackgroundTransparency = 0.72 + math.random() * 0.22
		p.BorderSizePixel = 0
		p.ZIndex = 0
		p.Parent = sg

		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(1, 0)
		c.Parent = p

		local vx = (math.random() - 0.5) * 0.035
		local vy = (math.random() - 0.5) * 0.035
		if math.abs(vx) < 0.008 then vx = 0.012 end
		if math.abs(vy) < 0.008 then vy = 0.012 end
		p:SetAttribute("vx", vx)
		p:SetAttribute("vy", vy)
		p:SetAttribute("base", p.BackgroundTransparency)

		table.insert(self.parts, p)
	end

	self.con = run.Heartbeat:Connect(function(dt)
		for _, p in ipairs(self.parts) do
			if p and p.Parent then
				local pos = p.Position
				local vx = p:GetAttribute("vx") or 0
				local vy = p:GetAttribute("vy") or 0
				local nx = pos.X.Scale + vx * dt
				local ny = pos.Y.Scale + vy * dt
				if nx < -0.05 then nx = 1.05 end
				if nx > 1.05 then nx = -0.05 end
				if ny < -0.05 then ny = 1.05 end
				if ny > 1.05 then ny = -0.05 end
				p.Position = UDim2.new(nx, 0, ny, 0)
				local wave = math.sin(tick() * 0.8 + p.AbsoluteSize.X) * 0.06
				local base = p:GetAttribute("base") or 0.8
				p.BackgroundTransparency = math.clamp(base + wave, 0.6, 0.95)
			end
		end
	end)
end

function focus:_destroy_parts()
	if self.con then
		pcall(function() self.con:Disconnect() end)
		self.con = nil
	end
	for _, p in ipairs(self.parts) do
		if p then pcall(function() p:Destroy() end) end
	end
	self.parts = {}
	if self.pgui then
		pcall(function() self.pgui:Destroy() end)
		self.pgui = nil
	end
end

function focus:_hideguis()
	local pg = player:FindFirstChild("PlayerGui")
	if pg then
		for _, c in ipairs(pg:GetChildren()) do
			if c:IsA("ScreenGui") and c ~= gui and c.Name ~= "AcursiveFocus" then
				if c.Enabled then
					self.hpguid[c] = true
					c.Enabled = false
				end
			end
		end
	end
	local rg
	pcall(function()
		if coregui:FindFirstChild("RobloxGui") then rg = coregui.RobloxGui end
	end)
	if rg then
		for _, c in ipairs(rg:GetChildren()) do
			if c ~= gui and c:IsA("GuiObject") and c.Visible then
				self.hrgui[c] = true
				c.Visible = false
			end
		end
	end
	local ok, types = pcall(function() return Enum.CoreGuiType:GetEnumItems() end)
	if ok and types then
		for _, t in ipairs(types) do
			local okget, state = pcall(function() return starter:GetCoreGuiEnabled(t) end)
			if okget and state then
				self.states[t] = true
				pcall(function() starter:SetCoreGuiEnabled(t, false) end)
			end
		end
	end
end

function focus:_restoreguis()
	for c in pairs(self.hpguid) do
		if c and c.Parent then pcall(function() c.Enabled = true end) end
	end
	table.clear(self.hpguid)
	for c in pairs(self.hrgui) do
		if c and c.Parent then pcall(function() c.Visible = true end) end
	end
	table.clear(self.hrgui)
	for t in pairs(self.states) do
		pcall(function() starter:SetCoreGuiEnabled(t, true) end)
	end
	table.clear(self.states)
end

function focus:enable()
	self.depth = self.depth + 1
	if self.on then return end
	self.on = true

	local cam = workspace.CurrentCamera
	if cam then
		self.fov = cam.FieldOfView
		local target = math.max(40, self.fov - 15)
		tracktween(tween:Create(cam, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {FieldOfView = target}))
		tween:Create(cam, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {FieldOfView = target}):Play()
	end

	if self.blur then pcall(function() self.blur:Destroy() end) end
	local blur = Instance.new("BlurEffect")
	blur.Name = "AcursiveBlur"
	blur.Size = 0
	blur.Parent = lighting
	tracktween(tween:Create(blur, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = 14}))
	tween:Create(blur, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = 14}):Play()
	self.blur = blur

	self:_createparts()
	self:_hideguis()
end

function focus:disable()
	self.depth = self.depth - 1
	if self.depth > 0 then return end
	self.depth = 0
	if not self.on then return end
	self.on = false

	local cam = workspace.CurrentCamera
	if cam and self.fov then
		local t = tween:Create(cam, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {FieldOfView = self.fov})
		t:Play()
		table.insert(tweens, t)
	end

	if self.blur then
		local b = self.blur
		self.blur = nil
		local t = tween:Create(b, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = 0})
		t:Play()
		table.insert(tweens, t)
		trackthread(task.delay(0.45, function() if b then pcall(function() b:Destroy() end) end end))
	end

	trackthread(task.delay(0.32, function() self:_destroy_parts() end))
	self:_restoreguis()
end

function acursive:setfocus(on)
	if on then focus:enable() else focus:disable() end
end

function acursive:isfocus()
	return focus.on
end

function acursive:cleanup()
	for _, c in ipairs(cons) do
		pcall(function()
			if typeof(c) == "RBXScriptConnection" and c.Connected then c:Disconnect() end
		end)
	end
	table.clear(cons)

	for _, t in ipairs(threads) do pcall(function() task.cancel(t) end) end
	table.clear(threads)

	for _, t in ipairs(tweens) do
		pcall(function() if t and t.PlaybackState then t:Cancel() end end)
	end
	table.clear(tweens)

	table.clear(winlist)
	table.clear(acctargets)
	table.clear(acgradients)
	table.clear(keybinds)
	keycap = nil

	if focus.on or focus.depth > 0 then
		focus.depth = 0
		focus:disable()
	end
	focus:_destroy_parts()

	if notifbox then pcall(function() notifbox:Destroy() end) end
	notifbox = nil

	if gui then pcall(function() gui:Destroy() end) end
	gui = nil
	notifid = 0
end

function acursive:destroy() self:cleanup() end

track(input.InputBegan:Connect(function(i, processed)
	if processed then return end
	if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
	if keycap then
		local cb = keycap
		keycap = nil
		safecall(cb, i.KeyCode)
		return
	end
	if istyping() then return end
	for _, e in ipairs(keybinds) do
		if e.key == i.KeyCode and e.callback then
			safecall(e.callback)
			break
		end
	end
end))

track(run.Heartbeat:Connect(function(dt)
	local t = tick()
	local offset = ((t * 0.35) % 2) - 1
	for _, g in ipairs(acgradients) do
		if g.Parent then g.Offset = Vector2.new(offset, 0) end
	end
	if rgbmode then
		rgbhue = (rgbhue + dt * 0.15) % 1
		local c = Color3.fromHSV(rgbhue, 0.85, 1)
		applyaccent(c, c:Lerp(Color3.new(1, 1, 1), 0.7))
	end
end))

local function getgui()
	if gui and gui.Parent then return gui end
	local sg = Instance.new("ScreenGui")
	sg.Name = "Acursive"
	sg.ResetOnSpawn = false
	sg.IgnoreGuiInset = true
	sg.DisplayOrder = 100
	sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local parented = false
	pcall(function()
		if coregui:FindFirstChild("RobloxGui") then
			sg.Parent = coregui.RobloxGui
			parented = true
		end
	end)
	if not parented then sg.Parent = player:WaitForChild("PlayerGui") end
	gui = sg
	return sg
end

local function getnotif()
	if notifbox and notifbox.Parent then return notifbox end
	local sg = getgui()
	local c = Instance.new("Frame")
	c.Name = "AcursiveNotifications"
	c.AnchorPoint = Vector2.new(1, 1)
	c.Position = UDim2.new(1, -16, 1, -16)
	c.Size = UDim2.new(0, 240, 0, 0)
	c.AutomaticSize = Enum.AutomaticSize.Y
	c.BackgroundTransparency = 1
	c.Parent = sg
	local l = Instance.new("UIListLayout")
	l.Padding = UDim.new(0, 6)
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.VerticalAlignment = Enum.VerticalAlignment.Bottom
	l.HorizontalAlignment = Enum.HorizontalAlignment.Right
	l.Parent = c
	notifbox = c
	return c
end

function acursive:notify(opts)
	if type(opts) == "string" then opts = {title = opts} end
	opts = opts or {}
	local title    = tostr(opts.title or opts.Title or "Notification")
	local content  = tostr(opts.content or opts.Content or opts.text or "")
	local duration = opts.duration or 4
	local color    = opts.accent or accent
	local box      = getnotif()
	notifid = notifid + 1

	local wrap = Instance.new("Frame")
	wrap.Size = UDim2.new(1, 0, 0, 52)
	wrap.BackgroundTransparency = 1
	wrap.ClipsDescendants = true
	wrap.LayoutOrder = notifid
	wrap.Parent = box

	local n = Instance.new("Frame")
	n.Size = UDim2.new(1, 0, 1, 0)
	n.BackgroundColor3 = palette.panel
	n.BorderSizePixel = 0
	n.Parent = wrap

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 3)
	corner.Parent = n

	local stroke = Instance.new("UIStroke")
	stroke.Color = palette.edge
	stroke.Thickness = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = n

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0, 2, 1, -12)
	bar.Position = UDim2.new(0, 5, 0, 6)
	bar.BackgroundColor3 = color
	bar.BorderSizePixel = 0
	bar.Parent = n

	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(1, 0)
	bc.Parent = bar

	local tl = Instance.new("TextLabel")
	tl.Size = UDim2.new(1, -20, 0, 16)
	tl.Position = UDim2.new(0, 14, 0, 8)
	tl.BackgroundTransparency = 1
	tl.Text = title
	tl.TextColor3 = palette.txtbright
	tl.TextSize = 12
	tl.Font = Enum.Font.GothamBold
	tl.TextXAlignment = Enum.TextXAlignment.Left
	tl.Parent = n

	local cl = Instance.new("TextLabel")
	cl.Size = UDim2.new(1, -20, 0, 14)
	cl.Position = UDim2.new(0, 14, 0, 26)
	cl.BackgroundTransparency = 1
	cl.Text = content
	cl.TextColor3 = palette.muted
	cl.TextSize = 11
	cl.Font = Enum.Font.Gotham
	cl.TextXAlignment = Enum.TextXAlignment.Left
	cl.Parent = n

	local pb = Instance.new("Frame")
	pb.Size = UDim2.new(1, -12, 0, 1)
	pb.Position = UDim2.new(0, 6, 1, -5)
	pb.BackgroundColor3 = palette.edge
	pb.BorderSizePixel = 0
	pb.Parent = n

	local pf = Instance.new("Frame")
	pf.Size = UDim2.new(1, 0, 1, 0)
	pf.BackgroundColor3 = color
	pf.BorderSizePixel = 0
	pf.Parent = pb

	n.BackgroundTransparency = 1
	bar.BackgroundTransparency = 1
	tl.TextTransparency = 1
	cl.TextTransparency = 1
	pb.BackgroundTransparency = 1
	pf.BackgroundTransparency = 1

	tw(n, 0.35, {BackgroundTransparency = 0}, Enum.EasingStyle.Quart)
	tw(bar, 0.3, {BackgroundTransparency = 0})
	tw(tl, 0.3, {TextTransparency = 0})
	tw(cl, 0.3, {TextTransparency = 0})
	tw(pb, 0.3, {BackgroundTransparency = 0})
	tw(pf, 0.3, {BackgroundTransparency = 0})
	tw(pf, duration, {Size = UDim2.new(0, 0, 1, 0)}, Enum.EasingStyle.Linear)

	trackthread(task.delay(duration, function()
		if not wrap or not wrap.Parent then return end
		tw(n, 0.3, {BackgroundTransparency = 1}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		tw(bar, 0.3, {BackgroundTransparency = 1}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		tw(tl, 0.3, {TextTransparency = 1}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		tw(cl, 0.3, {TextTransparency = 1}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		tw(pb, 0.3, {BackgroundTransparency = 1}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		tw(pf, 0.3, {BackgroundTransparency = 1}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		task.wait(0.15)
		if not wrap or not wrap.Parent then return end
		tw(wrap, 0.35, {Size = UDim2.new(1, 0, 0, 0)}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		task.wait(0.4)
		if wrap and wrap.Parent then wrap:Destroy() end
	end))
	return n
end

local window = {}
window.__index = window

local tab = {}
tab.__index = tab

local section = {}
section.__index = section

local dock = {}
dock.panels = {}
dock.containers = {}
dock.resize = {active = nil, starty = 0, starth = 0}

function dock:container(side)
	side = side or "right"
	if self.containers[side] and self.containers[side].Parent then
		return self.containers[side]
	end
	local sg = getgui()
	local c = Instance.new("Frame")
	c.Name = "AcursiveDock_" .. side
	if side == "right" then
		c.AnchorPoint = Vector2.new(1, 0)
		c.Position = UDim2.new(1, -14, 0, 14)
	else
		c.AnchorPoint = Vector2.new(0, 0)
		c.Position = UDim2.new(0, 14, 0, 14)
	end
	c.Size = UDim2.new(0, 300, 1, -28)
	c.BackgroundTransparency = 1
	c.ClipsDescendants = false
	c.ZIndex = 15
	c.Parent = sg
	local l = Instance.new("UIListLayout")
	l.SortOrder = Enum.SortOrder.LayoutOrder
	l.Padding = UDim.new(0, 10)
	l.VerticalAlignment = Enum.VerticalAlignment.Top
	l.HorizontalAlignment = Enum.HorizontalAlignment.Center
	l.Parent = c
	self.containers[side] = c
	return c
end

function dock:isdocked(t)
	for _, d in ipairs(self.panels) do
		if d.tab == t then return true end
	end
	return false
end

function dock:usedh(side)
	local h, n = 0, 0
	for _, d in ipairs(self.panels) do
		if d.side == side then
			h = h + (d.panel and d.panel.AbsoluteSize.Y or 320)
			n = n + 1
		end
	end
	if n > 0 then h = h + (n - 1) * 10 end
	return h
end

function dock:chooseside()
	local vy = 800
	if workspace.CurrentCamera then vy = workspace.CurrentCamera.ViewportSize.Y end
	local avail = vy - 28
	local usedr = self:usedh("right")
	if usedr + 330 <= avail then return "right" end
	return "left"
end

function dock:dock(t)
	if self:isdocked(t) then return end
	local side = self:chooseside()
	local cont = self:container(side)

	local p = Instance.new("Frame")
	p.Name = "Dock_" .. t.name
	p.Size = UDim2.new(1, 0, 0, 320)
	p.BackgroundColor3 = palette.panel
	p.BorderSizePixel = 0
	p.LayoutOrder = #self.panels + 1
	p.ZIndex = 16
	p.Parent = cont

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 3)
	corner.Parent = p

	local edge = Instance.new("UIStroke")
	edge.Color = palette.edge
	edge.Thickness = 1
	edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	edge.Parent = p

	local shadow = Instance.new("UIStroke")
	shadow.Color = palette.shadow
	shadow.Thickness = 1
	shadow.Transparency = 0.25
	shadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	shadow.Parent = p

	local head = Instance.new("Frame")
	head.Size = UDim2.new(1, 0, 0, 26)
	head.BackgroundColor3 = palette.dark
	head.BackgroundTransparency = 0.35
	head.BorderSizePixel = 0
	head.ZIndex = 17
	head.Parent = p

	local hc = Instance.new("UICorner")
	hc.CornerRadius = UDim.new(0, 3)
	hc.Parent = head

	local ht = Instance.new("TextLabel")
	ht.Size = UDim2.new(1, -60, 1, 0)
	ht.Position = UDim2.new(0, 12, 0, 0)
	ht.BackgroundTransparency = 1
	ht.Text = string.upper(tostr(t.name))
	ht.TextColor3 = palette.txt
	ht.TextSize = 11
	ht.Font = Enum.Font.GothamBold
	ht.TextXAlignment = Enum.TextXAlignment.Left
	ht.ZIndex = 18
	ht.Parent = head

	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0, 18, 0, 18)
	close.Position = UDim2.new(1, -22, 0.5, -9)
	close.BackgroundTransparency = 1
	close.BackgroundColor3 = palette.row
	close.BorderSizePixel = 0
	close.Text = "×"
	close.TextColor3 = palette.muted
	close.TextSize = 14
	close.Font = Enum.Font.GothamBold
	close.AutoButtonColor = false
	close.ZIndex = 18
	close.Parent = head

	local cc = Instance.new("UICorner")
	cc.CornerRadius = UDim.new(0, 2)
	cc.Parent = close

	local body = Instance.new("Frame")
	body.Size = UDim2.new(1, -8, 1, -38)
	body.Position = UDim2.new(0, 4, 0, 30)
	body.BackgroundTransparency = 1
	body.ClipsDescendants = true
	body.ZIndex = 17
	body.Parent = p

	t.page.Parent = body
	t.page.Size = UDim2.new(1, 0, 1, 0)
	t.page.Visible = true
	t.page.ZIndex = 18
	t.docked = true

	local grip = Instance.new("Frame")
	grip.Size = UDim2.new(1, 0, 0, 8)
	grip.Position = UDim2.new(0, 0, 1, -8)
	grip.BackgroundTransparency = 1
	grip.ZIndex = 30
	grip.Parent = p

	local bar = Instance.new("Frame")
	bar.AnchorPoint = Vector2.new(0.5, 0.5)
	bar.Size = UDim2.new(0, 28, 0, 2)
	bar.Position = UDim2.new(0.5, 0, 0.5, 0)
	bar.BackgroundColor3 = palette.edge
	bar.BorderSizePixel = 0
	bar.ZIndex = 31
	bar.Parent = grip

	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(1, 0)
	bc.Parent = bar

	track(close.MouseEnter:Connect(function()
		tw(close, 0.15, {TextColor3 = accent})
		tw(bar, 0.15, {BackgroundColor3 = accent})
	end))
	track(close.MouseLeave:Connect(function()
		tw(close, 0.15, {TextColor3 = palette.muted})
	end))
	track(close.MouseButton1Click:Connect(function() dock:undock(t) end))
	track(grip.MouseEnter:Connect(function() tw(bar, 0.15, {BackgroundColor3 = accent}) end))
	track(grip.MouseLeave:Connect(function() tw(bar, 0.15, {BackgroundColor3 = palette.edge}) end))

	track(grip.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dock.resize.active = p
			dock.resize.starty = i.Position.Y
			dock.resize.starth = p.AbsoluteSize.Y
		end
	end))

	table.insert(self.panels, {tab = t, panel = p, content = body, side = side})
	p.Size = UDim2.new(1, 0, 0, 0)
	tw(p, 0.3, {Size = UDim2.new(1, 0, 0, 320)}, Enum.EasingStyle.Quart)
end

function dock:undock(t)
	for i, d in ipairs(self.panels) do
		if d.tab == t then
			if d.tab.window and d.tab.window.body then
				t.page.Parent = t.window.body
				t.page.Size = UDim2.new(1, 0, 1, 0)
				t.page.Visible = (t.window.curtab == t.name)
			end
			t.docked = false
			local p = d.panel
			table.remove(self.panels, i)
			tw(p, 0.25, {Size = UDim2.new(1, 0, 0, 0)}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
			trackthread(task.delay(0.3, function()
				if p and p.Parent then p:Destroy() end
			end))
			for j, dd in ipairs(self.panels) do dd.panel.LayoutOrder = j end
			if t.window then t.window:resize(false) end
			return
		end
	end
end

function dock:toggle(t)
	if self:isdocked(t) then self:undock(t) else self:dock(t) end
end

function dock:clearall()
	for _, d in ipairs(self.panels) do
		pcall(function()
			if d.tab.window and d.tab.window.body then
				d.tab.page.Parent = d.tab.window.body
				d.tab.page.Size = UDim2.new(1, 0, 1, 0)
			end
			d.tab.docked = false
			if d.panel then d.panel:Destroy() end
		end)
	end
	table.clear(self.panels)
	for _, c in pairs(self.containers) do
		if c then pcall(function() c:Destroy() end) end
	end
	self.containers = {}
end

track(input.InputChanged:Connect(function(i)
	local p = dock.resize.active
	if not p then return end
	if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
		local dy = i.Position.Y - dock.resize.starty
		local nh = math.clamp(dock.resize.starth + dy, 120, 900)
		if p.Parent then p.Size = UDim2.new(1, 0, 0, nh) end
	end
end))

track(input.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		dock.resize.active = nil
	end
end))

acursive.icons = {
	search  = "rbxassetid://118685771787843",
	close   = "rbxassetid://118685771787843",
	check   = "rbxassetid://118685771787843",
	chevron = "rbxassetid://118685771787843",
}

local function buildchar(viewport)
	for _, c in ipairs(viewport:GetChildren()) do c:Destroy() end

	local world = Instance.new("WorldModel")
	world.Parent = viewport

	local cam = Instance.new("Camera")
	cam.FieldOfView = 30
	cam.CFrame = CFrame.new(Vector3.new(0, 1.5, 5), Vector3.new(0, 1, 0))
	cam.Parent = viewport
	viewport.CurrentCamera = cam

	local current
	local radius, height, angle = 5.0, 1.5, 0

	local function clear()
		if current and current.Parent then pcall(function() current:Destroy() end) end
		current = nil
	end

	local function loadchar(char)
		if not char or not char.Parent then return end
		if not char:IsA("Model") then return end
		if not char:FindFirstChildOfClass("Humanoid") then return end
		if not char:FindFirstChild("HumanoidRootPart") then return end
		pcall(function() char.Archivable = true end)
		local ok, clone = pcall(function() return char:Clone() end)
		if not ok or not clone then return end
		if not clone:IsA("Model") then
			pcall(function() clone:Destroy() end)
			return
		end
		for _, d in ipairs(clone:GetDescendants()) do
			if d:IsA("BasePart") then
				d.Anchored = true
				d.CanCollide = false
			elseif d:IsA("Script") or d:IsA("LocalScript") or d:IsA("Sound")
				or d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Fire")
				or d:IsA("Smoke") or d:IsA("Sparkles") then
				pcall(function() d:Destroy() end)
			end
		end
		local hum = clone:FindFirstChildOfClass("Humanoid")
		if hum then pcall(function() hum:Destroy() end) end
		local anim = clone:FindFirstChild("Animate")
		if anim then pcall(function() anim:Destroy() end) end
		local hrp = clone:FindFirstChild("HumanoidRootPart")
		if hrp then clone.PrimaryPart = hrp end
		clone.Parent = world
		if clone.PrimaryPart then pcall(function() clone:PivotTo(CFrame.new(0, 0, 0)) end) end
		clear()
		current = clone
	end

	task.spawn(function()
		local char = player.Character
		if not char then
			local c
			c = player.CharacterAdded:Connect(function(x) char = x end)
			local timeout = tick() + 10
			while not char and tick() < timeout do task.wait(0.1) end
			if c then c:Disconnect() end
		end
		if char then
			pcall(function()
				char:WaitForChild("Humanoid", 5)
				char:WaitForChild("HumanoidRootPart", 5)
			end)
			task.wait(0.2)
			if viewport and viewport.Parent then loadchar(char) end
		end
	end)

	track(player.CharacterAdded:Connect(function(char)
		task.wait(0.2)
		pcall(function()
			char:WaitForChild("Humanoid", 5)
			char:WaitForChild("HumanoidRootPart", 5)
		end)
		task.wait(0.1)
		if viewport and viewport.Parent then loadchar(char) end
	end))

	track(run.RenderStepped:Connect(function(dt)
		if not cam.Parent or not viewport.Parent then return end
		angle = (angle + dt * 0.5) % (math.pi * 2)
		local x = math.sin(angle) * radius
		local z = math.cos(angle) * radius
		cam.CFrame = CFrame.new(Vector3.new(x, height, z), Vector3.new(0, 1, 0))
	end))

	return cam
end

local function buildprofile(page)
	local vwrap = Instance.new("Frame")
	vwrap.Size = UDim2.new(1, 0, 0, 220)
	vwrap.BackgroundColor3 = palette.dark
	vwrap.BorderSizePixel = 0
	vwrap.LayoutOrder = 1
	vwrap.Parent = page

	local vc = Instance.new("UICorner")
	vc.CornerRadius = UDim.new(0, 3)
	vc.Parent = vwrap

	local vs = Instance.new("UIStroke")
	vs.Color = palette.edge
	vs.Thickness = 1
	vs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	vs.Parent = vwrap

	local vp = Instance.new("ViewportFrame")
	vp.Size = UDim2.new(1, 0, 1, 0)
	vp.BackgroundTransparency = 1
	vp.Ambient = Color3.fromRGB(170, 170, 170)
	vp.LightColor = Color3.fromRGB(255, 255, 255)
	vp.LightDirection = Vector3.new(-0.4, -1, -0.6)
	vp.Parent = vwrap
	buildchar(vp)

	local info = Instance.new("Frame")
	info.Size = UDim2.new(1, 0, 0, 0)
	info.AutomaticSize = Enum.AutomaticSize.Y
	info.BackgroundTransparency = 1
	info.LayoutOrder = 2
	info.Parent = page

	local il = Instance.new("UIListLayout")
	il.SortOrder = Enum.SortOrder.LayoutOrder
	il.Padding = UDim.new(0, 4)
	il.Parent = info

	local function makerow(order, label, value, isaccent)
		local r = Instance.new("Frame")
		r.Size = UDim2.new(1, 0, 0, 22)
		r.BackgroundColor3 = palette.row
		r.BorderSizePixel = 0
		r.LayoutOrder = order
		r.Parent = info

		local rc = Instance.new("UICorner")
		rc.CornerRadius = UDim.new(0, 2)
		rc.Parent = r

		local k = Instance.new("TextLabel")
		k.Size = UDim2.new(0, 120, 1, 0)
		k.Position = UDim2.new(0, 10, 0, 0)
		k.BackgroundTransparency = 1
		k.Text = tostr(label)
		k.TextColor3 = palette.muted
		k.TextSize = 11
		k.Font = Enum.Font.Gotham
		k.TextXAlignment = Enum.TextXAlignment.Left
		k.Parent = r

		local v = Instance.new("TextLabel")
		v.Size = UDim2.new(1, -140, 1, 0)
		v.Position = UDim2.new(0, 130, 0, 0)
		v.BackgroundTransparency = 1
		v.Text = tostr(value)
		v.TextColor3 = isaccent and accent or palette.txt
		v.TextSize = 11
		v.Font = Enum.Font.GothamMedium
		v.TextXAlignment = Enum.TextXAlignment.Left
		v.TextTruncate = Enum.TextTruncate.AtEnd
		v.Parent = r
		if isaccent then regaccent(v, "TextColor3") end
		return v
	end

	makerow(1, "display name", player.DisplayName or player.Name, true)
	makerow(2, "username", "@" .. tostr(player.Name))
	makerow(3, "user id", tostr(player.UserId))
	makerow(4, "account age", tostr(player.AccountAge) .. " days")

	local created = "—"
	pcall(function()
		local c = DateTime.fromUnixTimestamp(os.time() - (player.AccountAge * 86400))
		created = c:FormatLocalTime("YYYY-MM-DD", "en-us")
	end)
	makerow(5, "created", created)

	local shirt = makerow(6, "shirt", "none")
	local pants = makerow(7, "pants", "none")

	local function update()
		local char = player.Character
		if not char then return end
		local s = char:FindFirstChildOfClass("Shirt")
		local p = char:FindFirstChildOfClass("Pants")
		shirt.Text = s and "equipped" or "none"
		pants.Text = p and "equipped" or "none"
	end
	update()
	track(player.CharacterAdded:Connect(function()
		task.wait(0.5)
		update()
	end))
end

local function computenav(w)
	local buttons = {}
	for _, c in ipairs(w.tabcont:GetChildren()) do
		if c:IsA("TextButton") then table.insert(buttons, c) end
	end
	if #buttons == 0 then return nil, buttons end
	local vw = 800
	if workspace.CurrentCamera then vw = workspace.CurrentCamera.ViewportSize.X end
	local maxnav = math.min(vw - 60, 900)
	local pad = 4
	local contpad = 20
	local n = #buttons
	local per = math.clamp((maxnav - contpad - (n - 1) * pad) / n, 48, 100)
	for _, b in ipairs(buttons) do b.Size = UDim2.new(0, per, 0, 22) end
	local navw = n * per + (n - 1) * pad + contpad
	return math.min(navw, maxnav), buttons
end

local wheel = {}
wheel.__index = wheel

function wheel.new(w, side)
	local self = setmetatable({}, wheel)
	self.window = w
	self.side = side
	self.buttons = {}
	self.focus = 1
	self.hovered = false
	self.expanded = false
	self._sel = nil
	self._cons = {}

	local sg = getgui()
	local wrap = Instance.new("Frame")
	wrap.Name = "WheelNav_" .. side
	wrap.BackgroundColor3 = palette.dark
	wrap.BackgroundTransparency = 0.15
	wrap.BorderSizePixel = 0
	wrap.ClipsDescendants = true
	wrap.ZIndex = 40

	if side == "left" then
		wrap.AnchorPoint = Vector2.new(0, 0.5)
		wrap.Position = UDim2.new(0, 8, 0.5, 0)
	else
		wrap.AnchorPoint = Vector2.new(1, 0.5)
		wrap.Position = UDim2.new(1, -8, 0.5, 0)
	end
	wrap.Size = UDim2.new(0, 12, 0, 60)
	wrap.Parent = sg

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = wrap

	local stroke = Instance.new("UIStroke")
	stroke.Color = palette.edge
	stroke.Thickness = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = wrap

	local hint = Instance.new("Frame")
	hint.Name = "HintBar"
	hint.AnchorPoint = Vector2.new(0.5, 0.5)
	hint.Size = UDim2.new(0, 2, 0, 22)
	hint.Position = UDim2.new(0.5, 0, 0.5, 0)
	hint.BackgroundColor3 = accent
	hint.BorderSizePixel = 0
	hint.Parent = wrap
	regaccent(hint)

	local hc = Instance.new("UICorner")
	hc.CornerRadius = UDim.new(1, 0)
	hc.Parent = hint

	local cont = Instance.new("Frame")
	cont.Name = "Container"
	cont.Size = UDim2.new(1, 0, 1, 0)
	cont.BackgroundTransparency = 1
	cont.ClipsDescendants = true
	cont.Parent = wrap

	self.wrap = wrap
	self.stroke = stroke
	self.hint = hint
	self.cont = cont

	track(wrap.MouseEnter:Connect(function() self:sethover(true) end))
	track(wrap.MouseLeave:Connect(function()
		task.defer(function()
			if self.wrap and self.wrap.Parent and not self:_inside() then
				self:sethover(false)
			end
		end)
	end))

	return self
end

function wheel:_inside()
	if not self.wrap or not self.wrap.Parent then return false end
	local m = input:GetMouseLocation()
	local ap = self.wrap.AbsolutePosition
	local as = self.wrap.AbsoluteSize
	return m.X >= ap.X and m.X <= ap.X + as.X and m.Y >= ap.Y and m.Y <= ap.Y + as.Y
end

function wheel:addbtn(name, order)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.AnchorPoint = Vector2.new(0.5, 0.5)
	btn.Position = UDim2.new(0.5, 0, 0.5, 0)
	btn.Size = UDim2.new(0, 0, 0, 20)
	btn.BackgroundColor3 = palette.row
	btn.BackgroundTransparency = 1
	btn.BorderSizePixel = 0
	btn.Text = name
	btn.TextColor3 = palette.muted
	btn.TextSize = 11
	btn.Font = Enum.Font.GothamMedium
	btn.AutoButtonColor = false
	btn.TextTransparency = 1
	btn.ZIndex = 45
	btn.LayoutOrder = order
	btn.Parent = self.cont

	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(0, 3)
	bc.Parent = btn

	table.insert(self.buttons, {name = name, button = btn, order = order})
	table.sort(self.buttons, function(a, b) return a.order < b.order end)

	track(btn.MouseEnter:Connect(function()
		local idx
		for i, e in ipairs(self.buttons) do
			if e.button == btn then idx = i break end
		end
		if idx then self:setfocus(idx, false) end
	end))

	local last = 0
	track(btn.MouseButton1Click:Connect(function()
		local now = tick()
		if now - last < 0.3 then
			last = 0
			local t = self.window.tabobjs[name]
			if t then dock:toggle(t) end
		else
			last = now
			self.window:select(name)
			self:setselected(name)
		end
	end))

	return btn
end

function wheel:setselected(name)
	self._sel = name
	for i, e in ipairs(self.buttons) do
		if e.name == name then self:setfocus(i, true) break end
	end
end

function wheel:setfocus(index, animate)
	if #self.buttons == 0 then return end
	self.focus = math.clamp(index, 1, #self.buttons)
	self:_layout(animate ~= false)
end

function wheel:sethover(h)
	if self.hovered == h then return end
	self.hovered = h
	self.expanded = h
	self:_layout(true)
end

function wheel:_layout(animate)
	local n = #self.buttons
	if n == 0 then return end
	if not self.wrap or not self.wrap.Parent then return end

	local spacing = 34
	local focus = self.focus

	if self.expanded then
		local vh = 600
		if workspace.CurrentCamera then vh = workspace.CurrentCamera.ViewportSize.Y end
		local expandedh = math.clamp(n * 26 + 40, 130, math.min(vh - 80, 420))
		self.wrap.ClipsDescendants = false
		tw(self.wrap, 0.45, {Size = UDim2.new(0, 170, 0, expandedh), BackgroundTransparency = 0}, Enum.EasingStyle.Quart)
		tw(self.hint, 0.3, {BackgroundTransparency = 1, Size = UDim2.new(0, 0, 0, 0)})
		tw(self.stroke, 0.4, {Color = accent})
	else
		self.wrap.ClipsDescendants = true
		tw(self.wrap, 0.35, {Size = UDim2.new(0, 12, 0, 60), BackgroundTransparency = 0.15}, Enum.EasingStyle.Quart)
		tw(self.hint, 0.3, {BackgroundTransparency = 0, Size = UDim2.new(0, 2, 0, 22)})
		tw(self.stroke, 0.4, {Color = palette.edge})
	end

	for i, e in ipairs(self.buttons) do
		if e.button and e.button.Parent then
			local offset = i - focus
			local absoff = math.abs(offset)
			local scale = math.max(0.35, 1 - absoff * 0.18)
			local y = offset * spacing
			local th = 26 * scale
			local tw2 = math.clamp(140 * scale, 30, 150)
			local alpha = math.clamp(1 - absoff * 0.22, 0.12, 1)
			local sel = (self._sel == e.name)

			if self.expanded then
				tw(e.button, 0.42, {
					Position = UDim2.new(0.5, 0, 0.5, y),
					Size = UDim2.new(0, tw2, 0, th),
					TextTransparency = 1 - alpha,
					BackgroundTransparency = 1 - (alpha * 0.85),
					TextColor3 = sel and accent or palette.txt,
					TextSize = math.clamp(11 * scale + 2, 9, 14),
				}, Enum.EasingStyle.Quart)
			else
				tw(e.button, 0.3, {
					Position = UDim2.new(0.5, 0, 0.5, 0),
					Size = UDim2.new(0, 0, 0, th),
					TextTransparency = 1,
					BackgroundTransparency = 1,
				}, Enum.EasingStyle.Quart)
			end
		end
	end
end

function wheel:updatesize() end
function wheel:refresh() self:_layout(true) end

function wheel:destroy()
	self.buttons = {}
	if self.wrap then pcall(function() self.wrap:Destroy() end) end
	self.wrap = nil
	self.stroke = nil
	self.hint = nil
	self.cont = nil
end

local bar = {}
bar.__index = bar

function bar.new(w, pos)
	local self = setmetatable({}, bar)
	self.window = w
	self.pos = pos
	self.buttons = {}

	local sg = getgui()
	local wrap = Instance.new("Frame")
	wrap.Name = "BarNav_" .. pos
	wrap.BackgroundColor3 = palette.dark
	wrap.BackgroundTransparency = 1
	wrap.BorderSizePixel = 0
	wrap.ZIndex = 40

	if pos == "top" then
		wrap.AnchorPoint = Vector2.new(0.5, 0)
		wrap.Position = UDim2.new(0.5, 0, 0, -50)
		wrap.Size = UDim2.new(0, 480, 0, 30)
	else
		wrap.AnchorPoint = Vector2.new(0.5, 1)
		wrap.Position = UDim2.new(0.5, 0, 1, 50)
		wrap.Size = UDim2.new(0, 480, 0, 30)
	end
	wrap.Parent = sg

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 3)
	corner.Parent = wrap

	local stroke = Instance.new("UIStroke")
	stroke.Color = palette.edge
	stroke.Thickness = 1
	stroke.Transparency = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = wrap

	local shadow = Instance.new("UIStroke")
	shadow.Color = palette.shadow
	shadow.Thickness = 1
	shadow.Transparency = 1
	shadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	shadow.Parent = wrap

	local aline = Instance.new("Frame")
	if pos == "top" then
		aline.AnchorPoint = Vector2.new(0.5, 0)
		aline.Size = UDim2.new(0, 60, 0, 1)
		aline.Position = UDim2.new(0.5, 0, 0, 0)
	else
		aline.AnchorPoint = Vector2.new(0.5, 1)
		aline.Size = UDim2.new(0, 60, 0, 1)
		aline.Position = UDim2.new(0.5, 0, 1, 0)
	end
	aline.BackgroundColor3 = accent
	aline.BorderSizePixel = 0
	aline.Parent = wrap
	regaccent(aline)

	local glow = Instance.new("Frame")
	glow.Size = UDim2.new(1, 0, 0, 1)
	if pos == "top" then glow.Position = UDim2.new(0, 0, 0, 1)
	else glow.Position = UDim2.new(0, 0, 1, -1) end
	glow.BackgroundColor3 = accent
	glow.BackgroundTransparency = 0.5
	glow.BorderSizePixel = 0
	glow.Parent = wrap
	regaccent(glow)

	local cont = Instance.new("Frame")
	cont.Size = UDim2.new(1, -20, 1, 0)
	cont.Position = UDim2.new(0, 10, 0, 0)
	cont.BackgroundTransparency = 1
	cont.Parent = wrap

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 4)
	layout.Parent = cont

	local ind = Instance.new("Frame")
	ind.AnchorPoint = Vector2.new(0.5, 1)
	ind.Size = UDim2.new(0, 0, 0, 2)
	if pos == "top" then
		ind.Position = UDim2.new(0, 0, 1, -2)
	else
		ind.AnchorPoint = Vector2.new(0.5, 0)
		ind.Position = UDim2.new(0, 0, 0, 2)
	end
	ind.BackgroundColor3 = accent
	ind.BorderSizePixel = 0
	ind.ZIndex = 3
	ind.Visible = false
	ind.Parent = wrap
	regaccent(ind)

	self.wrap = wrap
	self.stroke = stroke
	self.shadow = shadow
	self.cont = cont
	self.ind = ind
	self.aline = aline
	self.glow = glow

	makegrad(aline)
	makegrad(ind)

	return self
end

function bar:addbtn(name, order)
	local w = self.window
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, w.tabw, 0, 22)
	btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	btn.BackgroundTransparency = 1
	btn.BorderSizePixel = 0
	btn.Text = name
	btn.TextColor3 = palette.muted
	btn.TextSize = 11
	btn.Font = Enum.Font.GothamMedium
	btn.AutoButtonColor = false
	btn.LayoutOrder = order
	btn.TextTruncate = Enum.TextTruncate.AtEnd
	btn.Parent = self.cont

	track(btn.MouseEnter:Connect(function()
		if w.curtab ~= name then tw(btn, 0.15, {TextColor3 = palette.txt}) end
	end))
	track(btn.MouseLeave:Connect(function()
		if w.curtab ~= name then tw(btn, 0.15, {TextColor3 = palette.muted}) end
	end))

	local last = 0
	track(btn.MouseButton1Click:Connect(function()
		local now = tick()
		if now - last < 0.3 then
			last = 0
			local t = w.tabobjs[name]
			if t then dock:toggle(t) end
		else
			last = now
			w:select(name)
		end
	end))

	return btn
end

function bar:updateind(name)
	local w = self.window
	local btn = w.tabs[name]
	if not btn or not btn.Parent then return end
	if not self.wrap or not self.wrap.Parent then return end
	self.ind.Visible = true
	local relx = btn.AbsolutePosition.X - self.wrap.AbsolutePosition.X + btn.AbsoluteSize.X / 2
	if self.pos == "top" then
		tw(self.ind, 0.25, {Position = UDim2.new(0, relx, 1, -2), Size = UDim2.new(0, btn.AbsoluteSize.X - 14, 0, 2)}, Enum.EasingStyle.Quart)
	else
		tw(self.ind, 0.25, {Position = UDim2.new(0, relx, 0, 2), Size = UDim2.new(0, btn.AbsoluteSize.X - 14, 0, 2)}, Enum.EasingStyle.Quart)
	end
end

function bar:updatesize()
	if not self.wrap or not self.wrap.Parent then return end
	local navw = computenav(self.window)
	if navw then self.wrap.Size = UDim2.new(0, navw, 0, 30) end
end

function bar:show()
	if not self.wrap or not self.wrap.Parent then return end
	if self.pos == "top" then
		tw(self.wrap, 0.55, {Position = UDim2.new(0.5, 0, 0, 14), BackgroundTransparency = 0}, Enum.EasingStyle.Quart)
	else
		tw(self.wrap, 0.55, {Position = UDim2.new(0.5, 0, 1, -14), BackgroundTransparency = 0}, Enum.EasingStyle.Quart)
	end
	tw(self.stroke, 0.55, {Transparency = 0})
	tw(self.shadow, 0.55, {Transparency = 0.3})
end

function bar:hide()
	if not self.wrap or not self.wrap.Parent then return end
	if self.pos == "top" then
		tw(self.wrap, 0.4, {Position = UDim2.new(0.5, 0, 0, -50), BackgroundTransparency = 1}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
	else
		tw(self.wrap, 0.4, {Position = UDim2.new(0.5, 0, 1, 50), BackgroundTransparency = 1}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
	end
	tw(self.stroke, 0.4, {Transparency = 1})
	tw(self.shadow, 0.4, {Transparency = 1})
	if self.ind then self.ind.Visible = false end
end

function bar:destroy()
	self.buttons = {}
	if self.wrap then pcall(function() self.wrap:Destroy() end) end
	self.wrap = nil
	self.stroke = nil
	self.shadow = nil
	self.cont = nil
	self.ind = nil
	self.aline = nil
	self.glow = nil
end

function acursive:createwindow(opts)
	opts = opts or {}
	local w = setmetatable({}, window)

	w.title        = tostr(opts.title or "Acursive")
	w.subtitle     = tostr(opts.subtitle or "")
	w.size         = opts.size or UDim2.new(0, 640, 0, 400)
	w.pos          = opts.pos or UDim2.new(0.5, 0, 0, 60)
	w.togglekey    = opts.togglekey or Enum.KeyCode.RightShift
	w.config       = opts.config
	w.draggable    = opts.draggable ~= false
	w.minh         = opts.minh or 90
	w.maxh         = opts.maxh or 640
	w.tabw         = opts.tabw or 90
	w.headerh      = opts.headerh or 16
	w.showbrand    = opts.showbrand ~= false
	w.showprofile  = opts.showprofile ~= false
	w.focuson      = opts.focus ~= false
	w.focusdrop    = opts.focusdrop or 15
	w.focusblur    = opts.focusblur or 14
	w.navpos       = opts.navpos or "top"

	local valid = {top = true, left = true, right = true, bottom = true}
	if not valid[w.navpos] then w.navpos = "top" end

	w.pages        = {}
	w.tabs         = {}
	w.tabobjs      = {}
	w.taborder     = 0
	w.curtab       = nil
	w.visible      = true
	w.toggles      = {}
	w.lasttoggle   = 0
	w.destroyed    = false
	w.focusactive  = false
	w.ownedaccent  = {}
	w.ownedbinds   = {}
	w.ownedgrads   = {}

	if themes[opts.theme or ""] then
		curtheme = opts.theme
		applyaccent(themes[opts.theme].main, themes[opts.theme].light)
	end

	local sg = getgui()
	w.screengui = sg

	local nav
	if w.navpos == "top" or w.navpos == "bottom" then
		nav = bar.new(w, w.navpos)
	else
		nav = wheel.new(w, w.navpos)
	end
	w.nav = nav

	if nav.cont then w.tabcont = nav.cont else w.tabcont = nav.cont end

	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.new(0, w.size.X.Offset, 0, 0)
	main.AnchorPoint = Vector2.new(0.5, 0)
	main.Position = w.pos
	main.BackgroundTransparency = 1
	main.BorderSizePixel = 0
	main.ClipsDescendants = true
	main.ZIndex = 20
	main.Parent = sg
	w.main = main

	local drag = Instance.new("Frame")
	drag.Name = "DragBar"
	drag.Size = UDim2.new(0, 120, 0, 4)
	drag.AnchorPoint = Vector2.new(0.5, 0)
	drag.Position = UDim2.new(0.5, 0, 0, 4)
	drag.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	drag.BorderSizePixel = 0
	drag.ZIndex = 21
	drag.Parent = main
	w.dragbar = drag

	local dc = Instance.new("UICorner")
	dc.CornerRadius = UDim.new(0, 1)
	dc.Parent = drag

	local ds = Instance.new("UIStroke")
	ds.Color = palette.shadow
	ds.Thickness = 1
	ds.Transparency = 0.3
	ds.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	ds.Parent = drag

	local body = Instance.new("Frame")
	body.Size = UDim2.new(1, 0, 1, -w.headerh)
	body.Position = UDim2.new(0, 0, 0, w.headerh)
	body.BackgroundTransparency = 1
	body.ClipsDescendants = true
	body.ZIndex = 21
	body.Parent = main
	w.body = body

	if w.draggable then
		local dragging, dragstart, startpos = false, nil, nil
		track(drag.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragstart = i.Position
				startpos = main.Position
				tw(drag, 0.15, {BackgroundColor3 = accent})
			end
		end))
		track(input.InputChanged:Connect(function(i)
			if dragging and main and main.Parent and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				local d = i.Position - dragstart
				main.Position = UDim2.new(startpos.X.Scale, startpos.X.Offset + d.X, startpos.Y.Scale, startpos.Y.Offset + d.Y)
			end
		end))
		track(input.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging = false
				tw(drag, 0.15, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
			end
		end))
	end

	function w:getconfig() return self.config end

	function w:saveconfig()
		if not self.config then return end
		local data = {
			theme = curtheme,
			rgb = rgbmode,
			accent = {accent.R, accent.G, accent.B},
			lasttab = self.curtab,
			toggles = {},
		}
		for label, e in pairs(self.toggles) do
			if e.save ~= false then
				pcall(function() data.toggles[label] = e.get() end)
			end
		end
		pcall(function()
			if writefile then writefile(self.config, http:JSONEncode(data)) end
		end)
	end

	function w:loadconfig()
		if not self.config then return nil end
		local data
		pcall(function()
			if isfile and isfile(self.config) then
				data = http:JSONDecode(readfile(self.config))
			end
		end)
		return data
	end

	local function computeh()
		if not w.curtab then return w.minh end
		local page = w.pages[w.curtab]
		if not page or not page.Parent then return w.minh end
		if dock:isdocked(w.tabobjs[w.curtab]) then return w.minh end
		local layout = page:FindFirstChildOfClass("UIListLayout")
		if not layout then return w.minh end
		local pad = page:FindFirstChildOfClass("UIPadding")
		local pady = 0
		if pad then pady = pad.PaddingTop.Offset + pad.PaddingBottom.Offset end
		local total = w.headerh + layout.AbsoluteContentSize.Y + pady + 14
		return math.clamp(total, w.minh, w.maxh)
	end
	w.computeh = computeh

	local mt

	function w:resize(instant)
		if not self.visible or self.destroyed then return end
		if not main or not main.Parent then return end
		local target = computeh()
		if mt then mt:Cancel() end
		local ts = UDim2.new(0, self.size.X.Offset, 0, target)
		if instant then main.Size = ts
		else mt = tw(main, 0.3, {Size = ts}, Enum.EasingStyle.Quart) end
	end

	function w:show()
		if self.destroyed or self.visible then return end
		self.visible = true
		local th = computeh()
		if not main or not main.Parent then return end
		main.Visible = true
		for _, c in pairs(dock.containers) do
			if c and c.Parent then c.Visible = true end
		end
		tw(main, 0.55, {Size = UDim2.new(0, self.size.X.Offset, 0, th), Position = UDim2.new(0.5, 0, 0, 60)}, Enum.EasingStyle.Quart)
		if self.nav and self.nav.show then self.nav:show() end
		if self.curtab and self.tabs[self.curtab] and self.nav and self.nav.updateind then
			self.nav:updateind(self.curtab)
		end
		if self.nav and self.nav.setselected then self.nav:setselected(self.curtab) end
		if self.focuson and not self.focusactive then
			self.focusactive = true
			focus:enable()
		end
	end

	function w:hide()
		if not self.visible then return end
		self.visible = false
		if main and main.Parent then
			tw(main, 0.4, {Size = UDim2.new(0, self.size.X.Offset, 0, 0), Position = UDim2.new(0.5, 0, 0, 40)}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		end
		if self.nav and self.nav.hide then self.nav:hide() end
		for _, c in pairs(dock.containers) do
			if c and c.Parent then c.Visible = false end
		end
		if self.focuson and self.focusactive then
			self.focusactive = false
			focus:disable()
		end
	end

	function w:toggle()
		if self.visible then self:hide() else self:show() end
	end

	function w:settogglekey(key) self.togglekey = key end
	function w:settitle(t) self.title = tostr(t) end
	function w:setsubtitle(s) self.subtitle = tostr(s) end
	function w:setpos(p) if main and main.Parent then main.Position = p end end
	function w:setsize(s) self.size = s self:resize(true) end
	function w:isvisible() return self.visible end
	function w:setfocusdrop(v) self.focusdrop = v end
	function w:getnavpos() return self.navpos end

	function w:select(name)
		if not self.tabs[name] then return end
		local tobj = self.tabobjs[name]
		if tobj and dock:isdocked(tobj) then
			for n, b in pairs(self.tabs) do
				if b and b.Parent then
					if n == name then tw(b, 0.2, {TextColor3 = accent})
					else tw(b, 0.2, {TextColor3 = palette.muted}) end
				end
			end
			if self.nav and self.nav.updateind then self.nav:updateind(name) end
			if self.nav and self.nav.setselected then self.nav:setselected(name) end
			self.curtab = name
			return
		end
		if self.curtab == name then return end
		for n, p in pairs(self.pages) do
			local to = self.tabobjs[n]
			if not (to and dock:isdocked(to)) then p.Visible = false end
		end
		if self.pages[name] then self.pages[name].Visible = true end
		for n, b in pairs(self.tabs) do
			if b and b.Parent then
				if n == name then tw(b, 0.2, {TextColor3 = accent})
				else tw(b, 0.2, {TextColor3 = palette.muted}) end
			end
		end
		if self.nav and self.nav.updateind then self.nav:updateind(name) end
		if self.nav and self.nav.setselected then self.nav:setselected(name) end
		self.curtab = name
		self:resize(false)
		self:saveconfig()
	end

	function w:createtab(name, order)
		if self.destroyed then return nil end
		name = tostr(name)
		self.taborder = self.taborder + 1
		local ordernum = order or self.taborder

		local page = Instance.new("ScrollingFrame")
		page.Name = name
		page.Size = UDim2.new(1, 0, 1, 0)
		page.BackgroundTransparency = 1
		page.BorderSizePixel = 0
		page.ScrollBarThickness = 2
		page.ScrollBarImageColor3 = accent
		page.ScrollBarImageTransparency = 0.3
		page.Visible = false
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.ZIndex = 22
		page.Parent = body
		regaccent(page, "ScrollBarImageColor3")

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

		local sb = Instance.new("Frame")
		sb.Size = UDim2.new(1, 0, 0, 26)
		sb.BackgroundColor3 = palette.row
		sb.BorderSizePixel = 0
		sb.LayoutOrder = -1
		sb.ZIndex = 23
		sb.Parent = page

		local sbc = Instance.new("UICorner")
		sbc.CornerRadius = UDim.new(0, 3)
		sbc.Parent = sb

		local sbs = Instance.new("UIStroke")
		sbs.Color = palette.edge
		sbs.Thickness = 1
		sbs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		sbs.Parent = sb

		local si = Instance.new("ImageLabel")
		si.Size = UDim2.new(0, 14, 0, 14)
		si.Position = UDim2.new(0, 8, 0.5, -7)
		si.BackgroundTransparency = 1
		si.Image = acursive.icons.search
		si.ImageColor3 = palette.muted
		si.Parent = sb

		local sbox = Instance.new("TextBox")
		sbox.Size = UDim2.new(1, -60, 1, 0)
		sbox.Position = UDim2.new(0, 28, 0, 0)
		sbox.BackgroundTransparency = 1
		sbox.Text = ""
		sbox.PlaceholderText = "search this tab..."
		sbox.PlaceholderColor3 = palette.muted
		sbox.TextColor3 = palette.txt
		sbox.TextSize = 11
		sbox.Font = Enum.Font.Gotham
		sbox.TextXAlignment = Enum.TextXAlignment.Left
		sbox.ClearTextOnFocus = false
		sbox.Parent = sb

		local clr = Instance.new("TextButton")
		clr.Size = UDim2.new(0, 18, 0, 18)
		clr.Position = UDim2.new(1, -22, 0.5, -9)
		clr.BackgroundTransparency = 1
		clr.Text = "×"
		clr.TextColor3 = palette.muted
		clr.TextSize = 14
		clr.Font = Enum.Font.GothamBold
		clr.AutoButtonColor = false
		clr.Parent = sb

		page:SetAttribute("searchtext", "")

		local function applyfilter(text)
			text = string.lower(text)
			page:SetAttribute("searchtext", text)
			for _, secFrame in ipairs(page:GetChildren()) do
				if secFrame:IsA("Frame") and secFrame ~= sb then
					local bd = secFrame:FindFirstChild("Body")
					local any = false
					if bd then
						for _, row in ipairs(bd:GetChildren()) do
							if row:IsA("GuiObject") and row.LayoutOrder and row.LayoutOrder > 0 then
								local label = row:GetAttribute("RowLabel")
								if label == nil then
									local tl = row:FindFirstChildWhichIsA("TextLabel", true)
									if tl then label = tl.Text end
								end
								if type(label) == "string" and #label > 0 then
									if text == "" or string.find(string.lower(label), text, 1, true) then
										row.Visible = true
										any = true
									else
										row.Visible = false
									end
								else
									row.Visible = true
									any = true
								end
							end
						end
					end
					secFrame.Visible = (text == "") or any
				end
			end
			if self.curtab == name then self:resize(false) end
		end

		track(sbox:GetPropertyChangedSignal("Text"):Connect(function() applyfilter(sbox.Text) end))
		track(clr.MouseButton1Click:Connect(function() sbox.Text = "" applyfilter("") end))
		track(sbox.Focused:Connect(function()
			tw(sbs, 0.15, {Color = accent})
			tw(si, 0.15, {ImageColor3 = accent})
		end))
		track(sbox.FocusLost:Connect(function()
			tw(sbs, 0.15, {Color = palette.edge})
			tw(si, 0.15, {ImageColor3 = palette.muted})
		end))
		track(layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			if not page or not page.Parent then return end
			page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 14)
			if self.curtab == name then self:resize(false) end
		end))

		self.pages[name] = page
		local btn = self.nav:addbtn(name, ordernum)
		self.tabs[name] = btn

		local t = setmetatable({}, tab)
		t.window = self
		t.name = name
		t.page = page
		t.search = sbox
		t._order = 0
		t.sections = {}
		t.destroyed = false
		t.docked = false
		self.tabobjs[name] = t
		if self.nav.updatesize then self.nav:updatesize() end
		if self.nav.refresh then self.nav:refresh() end
		return t
	end

	if not w.curtab then
		trackthread(task.defer(function()
			if w.destroyed then return end
			local first
			for _, b in ipairs(w.tabcont:GetChildren()) do
				if b:IsA("TextButton") then first = b break end
			end
			if first then w:select(first.Text) end
		end))
	end

	if w.togglekey then
		track(input.InputBegan:Connect(function(i, processed)
			if processed then return end
			if w.destroyed then return end
			if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
			if keycap then return end
			if istyping() then return end
			if i.KeyCode == w.togglekey then w:toggle() end
		end))
	end

	track(input.InputChanged:Connect(function()
		if w.destroyed then return end
		if w.nav and w.nav.updatesize then w.nav:updatesize() end
		if w.curtab and w.tabs[w.curtab] and w.nav and w.nav.updateind then
			w.nav:updateind(w.curtab)
		end
	end))

	table.insert(winlist, w)

	trackthread(task.spawn(function()
		run.RenderStepped:Wait()
		run.RenderStepped:Wait()
		if w.destroyed then return end
		local cfg = w:loadconfig()
		if cfg then
			if cfg.theme and themes[cfg.theme] then curtheme = cfg.theme end
			for label, val in pairs(cfg.toggles or {}) do
				local e = w.toggles[label]
				if e and e.set then pcall(function() e.set(val) end) end
			end
			if cfg.rgb then
				rgbmode = true
			elseif cfg.theme and themes[cfg.theme] then
				applyaccent(themes[cfg.theme].main, themes[cfg.theme].light)
			elseif cfg.accent then
				applyaccent(Color3.new(cfg.accent[1], cfg.accent[2], cfg.accent[3]))
			end
			if cfg.lasttab and w.tabs[cfg.lasttab] then w:select(cfg.lasttab) end
		end
		if w.destroyed then return end
		local th = computeh()
		if not main or not main.Parent then return end
		main.Size = UDim2.new(0, w.size.X.Offset, 0, 0)
		if w.nav and w.nav.show then w.nav:show() end
		task.wait(0.15)
		if w.destroyed then return end
		tw(main, 0.6, {Size = UDim2.new(0, w.size.X.Offset, 0, th)}, Enum.EasingStyle.Quart)
		task.wait(0.4)
		if w.destroyed then return end
		if w.curtab and w.tabs[w.curtab] and w.nav and w.nav.updateind then
			w.nav:updateind(w.curtab)
		end
		if w.showbrand then
			acursive:notify({title = w.title, content = "loaded successfully", duration = 4})
		end
	end))

	if w.focuson then
		w.focusactive = true
		task.defer(function() focus:enable() end)
	end

	if w.showprofile then
		task.defer(function()
			if w.destroyed then return end
			local pt = w:createtab("Profile", 0)
			if pt then buildprofile(pt.page) end
		end)
	end

	return w
end

function window:notify(opts) return acursive:notify(opts) end

function window:destroy()
	if self.destroyed then return end
	self.destroyed = true
	pcall(function() self:saveconfig() end)
	for _, d in ipairs(dock.panels) do
		if d.tab and d.tab.window == self then
			pcall(function() if d.panel then d.panel:Destroy() end end)
		end
	end
	local kept = {}
	for _, d in ipairs(dock.panels) do
		if not (d.tab and d.tab.window == self) then table.insert(kept, d) end
	end
	dock.panels = kept
	for i = #keybinds, 1, -1 do
		local e = keybinds[i]
		if e and e.owner == self then table.remove(keybinds, i) end
	end
	for i = #acgradients, 1, -1 do
		local g = acgradients[i]
		if not g or not g.Parent or (self.main and g:IsDescendantOf(self.main)) or (self.nav and self.nav.wrap and g:IsDescendantOf(self.nav.wrap)) then
			if g and g.Parent then pcall(function() g:Destroy() end) end
			table.remove(acgradients, i)
		end
	end
	if self.nav then pcall(function() self.nav:destroy() end) end
	if self.main then pcall(function() self.main:Destroy() end) end
	self.main = nil
	self.body = nil
	self.dragbar = nil
	self.tabs = {}
	self.pages = {}
	self.tabobjs = {}
	self.toggles = {}
	for i = #winlist, 1, -1 do
		if winlist[i] == self then table.remove(winlist, i) end
	end
	if self.focusactive then
		self.focusactive = false
		focus:disable()
	end
	task.defer(pruneaccent)
end

function tab:createsection(title, order)
	if self.destroyed then return nil end
	self._order = self._order + 1
	local ordernum = order or self._order

	local sec = Instance.new("Frame")
	sec.Name = "Section"
	sec.Size = UDim2.new(1, 0, 0, 0)
	sec.AutomaticSize = Enum.AutomaticSize.Y
	sec.BackgroundColor3 = palette.panel
	sec.BorderSizePixel = 0
	sec.LayoutOrder = ordernum
	sec.Parent = self.page

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 3)
	corner.Parent = sec

	local outer = Instance.new("UIStroke")
	outer.Color = palette.shadow
	outer.Thickness = 1
	outer.Transparency = 0.2
	outer.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	outer.Parent = sec

	local edge = Instance.new("UIStroke")
	edge.Color = palette.edge
	edge.Thickness = 1
	edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	edge.Parent = sec

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = sec

	local head = Instance.new("TextLabel")
	head.Size = UDim2.new(1, -24, 0, 22)
	head.BackgroundTransparency = 1
	head.Text = tostr(title)
	head.TextColor3 = palette.muted
	head.TextSize = 11
	head.Font = Enum.Font.GothamMedium
	head.TextXAlignment = Enum.TextXAlignment.Left
	head.LayoutOrder = 1
	head.Parent = sec

	local line = Instance.new("Frame")
	line.Size = UDim2.new(1, -20, 0, 1)
	line.BackgroundColor3 = palette.edge
	line.BorderSizePixel = 0
	line.LayoutOrder = 2
	line.Parent = sec

	local bd = Instance.new("Frame")
	bd.Name = "Body"
	bd.Size = UDim2.new(1, 0, 0, 0)
	bd.AutomaticSize = Enum.AutomaticSize.Y
	bd.BackgroundTransparency = 1
	bd.LayoutOrder = 3
	bd.Parent = sec

	local bl = Instance.new("UIListLayout")
	bl.SortOrder = Enum.SortOrder.LayoutOrder
	bl.Parent = bd

	local bp = Instance.new("UIPadding")
	bp.PaddingTop = UDim.new(0, 4)
	bp.PaddingBottom = UDim.new(0, 6)
	bp.PaddingLeft = UDim.new(0, 6)
	bp.PaddingRight = UDim.new(0, 6)
	bp.Parent = bd

	local s = setmetatable({}, section)
	s._order = 0
	s.window = self.window
	s.tab = self
	s.frame = sec
	s.body = bd
	s.head = head
	s.title = tostr(title)
	s.collapsed = false
	s.destroyed = false
	s.elements = {}

	function s:settitle(t) head.Text = tostr(t) s.title = tostr(t) end
	function s:setvisible(v) sec.Visible = v end
	function s:setcollapsed(v)
		s.collapsed = v
		bd.Visible = not v
		sec.AutomaticSize = v and Enum.AutomaticSize.None or Enum.AutomaticSize.Y
		if v then sec.Size = UDim2.new(1, 0, 0, 24)
		else sec.Size = UDim2.new(1, 0, 0, 0) end
	end
	function s:destroy()
		if s.destroyed then return end
		s.destroyed = true
		for i = #keybinds, 1, -1 do
			local e = keybinds[i]
			if e and e.owner == s then table.remove(keybinds, i) end
		end
		if sec and sec.Parent then pcall(function() sec:Destroy() end) end
		s.elements = {}
	end

	function s:createtoggle(opts)
		opts = opts or {}
		s._order = s._order + 1
		local order = opts.order or s._order
		local label = tostr(opts.name or opts.label or "toggle")
		local state = opts.default or false
		local cb = opts.callback
		local defkey = opts.key or opts.defaultkey
		local nosave = opts.save == false
		local ondouble = opts.ondouble
		local transparent = ondouble ~= nil

		local row = Instance.new("TextButton")
		row.Size = UDim2.new(1, 0, 0, 22)
		row.BackgroundColor3 = palette.row
		row.BackgroundTransparency = transparent and 1 or 0
		row.BorderSizePixel = 0
		row.Text = ""
		row.AutoButtonColor = false
		row.LayoutOrder = order
		row.Parent = bd
		row:SetAttribute("RowLabel", label)

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 2)
		corner.Parent = row

		local rs = Instance.new("UIStroke")
		rs.Color = palette.shadow
		rs.Thickness = 1
		rs.Transparency = transparent and 1 or 0.5
		rs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		rs.Parent = row

		local box = Instance.new("Frame")
		box.Size = UDim2.new(0, 10, 0, 10)
		box.Position = UDim2.new(0, 10, 0.5, -5)
		box.BackgroundColor3 = state and accent or Color3.fromRGB(28, 28, 28)
		box.BorderSizePixel = 0
		box.Parent = row

		local bc = Instance.new("UICorner")
		bc.CornerRadius = UDim.new(0, 1)
		bc.Parent = box

		local bs = Instance.new("UIStroke")
		bs.Color = state and accent or palette.edge
		bs.Thickness = 1
		bs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		bs.Parent = box

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -180, 1, 0)
		lbl.Position = UDim2.new(0, 26, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = label
		lbl.TextColor3 = palette.txt
		lbl.TextSize = 11
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row

		local ind = Instance.new("TextLabel")
		ind.Size = UDim2.new(0, 40, 1, 0)
		ind.Position = UDim2.new(1, -50, 0, 0)
		ind.BackgroundTransparency = 1
		ind.Text = state and "on" or "off"
		ind.TextColor3 = state and accent or palette.muted
		ind.TextSize = 11
		ind.Font = Enum.Font.Gotham
		ind.TextXAlignment = Enum.TextXAlignment.Right
		ind.Parent = row

		local kb = Instance.new("TextButton")
		kb.Size = UDim2.new(0, 55, 0, 14)
		kb.Position = UDim2.new(1, -120, 0.5, -7)
		kb.BackgroundColor3 = palette.field
		kb.BackgroundTransparency = transparent and 1 or 0
		kb.BorderSizePixel = 0
		kb.Text = "bind"
		kb.TextColor3 = palette.muted
		kb.TextSize = 10
		kb.Font = Enum.Font.Gotham
		kb.AutoButtonColor = false
		kb.ZIndex = 2
		kb.Parent = row

		local kbc = Instance.new("UICorner")
		kbc.CornerRadius = UDim.new(0, 2)
		kbc.Parent = kb

		local kbs = Instance.new("UIStroke")
		kbs.Color = palette.edge
		kbs.Thickness = 1
		kbs.Transparency = transparent and 1 or 0
		kbs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		kbs.Parent = kb

		local entry = {key = nil, callback = nil, owner = s}
		table.insert(keybinds, entry)

		local function setstate(v, fire)
			state = v and true or false
			box.BackgroundColor3 = state and accent or Color3.fromRGB(28, 28, 28)
			bs.Color = state and accent or palette.edge
			ind.Text = state and "on" or "off"
			ind.TextColor3 = state and accent or palette.muted
			if fire and cb then safecall(cb, state) end
		end

		regaccentfn(function()
			if not row or not row.Parent then return end
			if state then
				box.BackgroundColor3 = accent
				bs.Color = accent
				ind.TextColor3 = accent
			else
				box.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
				bs.Color = palette.edge
				ind.TextColor3 = palette.muted
			end
		end)

		if defkey then
			entry.key = defkey
			entry.callback = function() setstate(not state, true) s.window:saveconfig() end
			kb.Text = tostr(defkey):gsub("Enum.KeyCode.", "")
		end

		if not transparent then
			track(row.MouseEnter:Connect(function() tw(row, 0.15, {BackgroundColor3 = palette.rowhover}) end))
			track(row.MouseLeave:Connect(function() tw(row, 0.15, {BackgroundColor3 = palette.row}) end))
		end

		if ondouble then
			local pending, last = nil, 0
			track(row.MouseButton1Click:Connect(function()
				local now = tick()
				if now - last < 0.3 then
					if pending then task.cancel(pending) pending = nil end
					last = 0
					safecall(ondouble)
					return
				end
				last = now
				pending = task.delay(0.3, function()
					pending = nil
					setstate(not state, true)
					s.window:saveconfig()
				end)
			end))
		else
			track(row.MouseButton1Click:Connect(function()
				setstate(not state, true)
				s.window:saveconfig()
			end))
		end

		track(kb.MouseEnter:Connect(function()
			tw(kb, 0.15, {TextColor3 = accent, BackgroundColor3 = Color3.fromRGB(24, 24, 24)})
			tw(kbs, 0.15, {Color = accent})
		end))
		track(kb.MouseLeave:Connect(function()
			tw(kb, 0.15, {TextColor3 = palette.muted, BackgroundColor3 = palette.field})
			tw(kbs, 0.15, {Color = palette.edge})
		end))
		track(kb.MouseButton1Click:Connect(function()
			if keycap then return end
			kb.Text = "..."
			keycap = function(key)
				entry.key = key
				entry.callback = function() setstate(not state, true) s.window:saveconfig() end
				kb.Text = tostr(key):gsub("Enum.KeyCode.", "")
			end
		end))

		s.window.toggles[label] = {
			get = function() return state end,
			set = function(v) setstate(v, true) end,
			save = not nosave,
		}

		local el = {
			set = function(v) setstate(v, true) end,
			get = function() return state end,
			setkey = function(k)
				entry.key = k
				entry.callback = function() setstate(not state, true) s.window:saveconfig() end
				kb.Text = tostr(k):gsub("Enum.KeyCode.", "")
			end,
			setvisible = function(v) row.Visible = v end,
			setname = function(t) lbl.Text = tostr(t) row:SetAttribute("RowLabel", tostr(t)) end,
			destroy = function()
				for i = #keybinds, 1, -1 do
					if keybinds[i] == entry then table.remove(keybinds, i) end
				end
				if row and row.Parent then row:Destroy() end
			end,
			row = row,
		}
		table.insert(s.elements, el)
		return el
	end

	function s:createslider(opts)
		opts = opts or {}
		s._order = s._order + 1
		local order = opts.order or s._order
		local label = tostr(opts.name or opts.label or "slider")
		local mn = opts.min or 0
		local mx = opts.max or 100
		local value = opts.default or mn
		local cb = opts.callback
		local dec = opts.decimals or 2
		local suffix = tostr(opts.suffix or "")

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 34)
		row.BackgroundColor3 = palette.row
		row.BorderSizePixel = 0
		row.LayoutOrder = order
		row.Parent = bd
		row:SetAttribute("RowLabel", label)

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 2)
		corner.Parent = row

		local rs = Instance.new("UIStroke")
		rs.Color = palette.shadow
		rs.Thickness = 1
		rs.Transparency = 0.5
		rs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		rs.Parent = row

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -80, 0, 16)
		lbl.Position = UDim2.new(0, 10, 0, 3)
		lbl.BackgroundTransparency = 1
		lbl.Text = label
		lbl.TextColor3 = palette.txt
		lbl.TextSize = 11
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row

		local val = Instance.new("TextLabel")
		val.Size = UDim2.new(0, 70, 0, 16)
		val.Position = UDim2.new(1, -80, 0, 3)
		val.BackgroundTransparency = 1
		val.Text = string.format("%." .. dec .. "f%s", value, suffix)
		val.TextColor3 = palette.muted
		val.TextSize = 11
		val.Font = Enum.Font.Gotham
		val.TextXAlignment = Enum.TextXAlignment.Right
		val.Parent = row

		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(1, -20, 0, 5)
		bar.Position = UDim2.new(0, 10, 0, 23)
		bar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
		bar.BorderSizePixel = 0
		bar.Parent = row

		local barc = Instance.new("UICorner")
		barc.CornerRadius = UDim.new(0, 1)
		barc.Parent = bar

		local fill = Instance.new("Frame")
		fill.Size = UDim2.new((value - mn) / (mx - mn), 0, 1, 0)
		fill.BackgroundColor3 = accent
		fill.BorderSizePixel = 0
		fill.Parent = bar
		regaccent(fill)

		local fc = Instance.new("UICorner")
		fc.CornerRadius = UDim.new(0, 1)
		fc.Parent = fill

		local dragging = false
		local function update(i)
			if not bar.Parent then return end
			local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			value = mn + (mx - mn) * p
			fill.Size = UDim2.new(p, 0, 1, 0)
			val.Text = string.format("%." .. dec .. "f%s", value, suffix)
			if cb then safecall(cb, value) end
		end

		track(bar.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				update(i)
			end
		end))
		track(input.InputChanged:Connect(function(i)
			if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update(i) end
		end))
		track(input.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
		end))

		return {
			set = function(v)
				value = math.clamp(v, mn, mx)
				local p = (value - mn) / (mx - mn)
				fill.Size = UDim2.new(p, 0, 1, 0)
				val.Text = string.format("%." .. dec .. "f%s", value, suffix)
				if cb then safecall(cb, value) end
			end,
			get = function() return value end,
			setvisible = function(v) row.Visible = v end,
			setname = function(t) lbl.Text = tostr(t) row:SetAttribute("RowLabel", tostr(t)) end,
		}
	end

	function s:createbutton(opts)
		opts = opts or {}
		s._order = s._order + 1
		local order = opts.order or s._order
		local label = tostr(opts.name or opts.label or "button")
		local cb = opts.callback

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 22)
		btn.BackgroundColor3 = palette.row
		btn.BorderSizePixel = 0
		btn.Text = label
		btn.TextColor3 = palette.txt
		btn.TextSize = 11
		btn.Font = Enum.Font.GothamMedium
		btn.AutoButtonColor = false
		btn.LayoutOrder = order
		btn.Parent = bd
		btn:SetAttribute("RowLabel", label)

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 2)
		corner.Parent = btn

		local stroke = Instance.new("UIStroke")
		stroke.Color = palette.edge
		stroke.Thickness = 1
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = btn

		track(btn.MouseEnter:Connect(function()
			tw(btn, 0.15, {BackgroundColor3 = palette.rowhover, TextColor3 = accent})
			tw(stroke, 0.15, {Color = accent})
		end))
		track(btn.MouseLeave:Connect(function()
			tw(btn, 0.15, {BackgroundColor3 = palette.row, TextColor3 = palette.txt})
			tw(stroke, 0.15, {Color = palette.edge})
		end))
		track(btn.MouseButton1Click:Connect(function() if cb then safecall(cb) end end))

		return {
			setname = function(t) btn.Text = tostr(t) btn:SetAttribute("RowLabel", tostr(t)) end,
			setvisible = function(v) btn.Visible = v end,
			button = btn,
		}
	end

	function s:createdropdown(opts)
		opts = opts or {}
		s._order = s._order + 1
		local order = opts.order or s._order
		local label = tostr(opts.name or opts.label or "dropdown")
		local options = opts.options or {}
		local selected = opts.default or options[1]
		local cb = opts.callback
		local expanded = false

		local wrap = Instance.new("Frame")
		wrap.Size = UDim2.new(1, 0, 0, 22)
		wrap.BackgroundTransparency = 1
		wrap.ClipsDescendants = true
		wrap.LayoutOrder = order
		wrap.Parent = bd
		wrap:SetAttribute("RowLabel", label)

		local head = Instance.new("TextButton")
		head.Size = UDim2.new(1, 0, 0, 22)
		head.BackgroundColor3 = palette.row
		head.BorderSizePixel = 0
		head.Text = ""
		head.AutoButtonColor = false
		head.Parent = wrap

		local hc = Instance.new("UICorner")
		hc.CornerRadius = UDim.new(0, 2)
		hc.Parent = head

		local hs = Instance.new("UIStroke")
		hs.Color = palette.edge
		hs.Thickness = 1
		hs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		hs.Parent = head

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -100, 1, 0)
		lbl.Position = UDim2.new(0, 10, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = label
		lbl.TextColor3 = palette.txt
		lbl.TextSize = 11
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = head

		local val = Instance.new("TextLabel")
		val.Size = UDim2.new(0, 80, 1, 0)
		val.Position = UDim2.new(1, -90, 0, 0)
		val.BackgroundTransparency = 1
		val.Text = tostr(selected)
		val.TextColor3 = accent
		val.TextSize = 11
		val.Font = Enum.Font.Gotham
		val.TextXAlignment = Enum.TextXAlignment.Right
		val.Parent = head
		regaccent(val, "TextColor3")

		local bod = Instance.new("Frame")
		bod.Size = UDim2.new(1, 0, 0, #options * 20)
		bod.Position = UDim2.new(0, 0, 0, 22)
		bod.BackgroundColor3 = palette.panel
		bod.BorderSizePixel = 0
		bod.Parent = wrap

		local bc = Instance.new("UICorner")
		bc.CornerRadius = UDim.new(0, 2)
		bc.Parent = bod

		local bo = Instance.new("UIStroke")
		bo.Color = palette.edge
		bo.Thickness = 1
		bo.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		bo.Parent = bod

		local list = Instance.new("UIListLayout")
		list.SortOrder = Enum.SortOrder.LayoutOrder
		list.Parent = bod

		local function close()
			expanded = false
			tw(wrap, 0.25, {Size = UDim2.new(1, 0, 0, 22)}, Enum.EasingStyle.Quart)
		end

		local function makeopt(opt, i)
			local o = Instance.new("TextButton")
			o.Size = UDim2.new(1, 0, 0, 20)
			o.BackgroundColor3 = palette.panel
			o.BackgroundTransparency = 1
			o.BorderSizePixel = 0
			o.Text = "   " .. tostr(opt)
			o.TextColor3 = palette.muted
			o.TextSize = 11
			o.Font = Enum.Font.Gotham
			o.TextXAlignment = Enum.TextXAlignment.Left
			o.AutoButtonColor = false
			o.LayoutOrder = i
			o.Parent = bod

			track(o.MouseEnter:Connect(function()
				tw(o, 0.15, {BackgroundTransparency = 0, BackgroundColor3 = palette.rowhover, TextColor3 = palette.txt})
			end))
			track(o.MouseLeave:Connect(function()
				tw(o, 0.15, {BackgroundTransparency = 1, TextColor3 = palette.muted})
			end))
			track(o.MouseButton1Click:Connect(function()
				selected = opt
				val.Text = tostr(opt)
				close()
				if cb then safecall(cb, selected) end
				s.window:saveconfig()
			end))
			return o
		end

		for i, opt in ipairs(options) do makeopt(opt, i) end

		track(head.MouseButton1Click:Connect(function()
			expanded = not expanded
			local target = expanded and UDim2.new(1, 0, 0, 22 + #options * 20) or UDim2.new(1, 0, 0, 22)
			tw(wrap, 0.25, {Size = target}, Enum.EasingStyle.Quart)
		end))

		return {
			select = function(v)
				for _, o in ipairs(options) do
					if o == v then
						selected = v
						val.Text = tostr(v)
						if cb then safecall(cb, selected) end
						break
					end
				end
			end,
			get = function() return selected end,
			setopts = function(no)
				for _, c in ipairs(bod:GetChildren()) do
					if c:IsA("TextButton") then c:Destroy() end
				end
				options = no or {}
				bod.Size = UDim2.new(1, 0, 0, #options * 20)
				for i, opt in ipairs(options) do makeopt(opt, i) end
				if expanded then wrap.Size = UDim2.new(1, 0, 0, 22 + #options * 20) end
			end,
			refresh = function(no)
				if no then
					for _, c in ipairs(bod:GetChildren()) do
						if c:IsA("TextButton") then c:Destroy() end
					end
					options = no
					bod.Size = UDim2.new(1, 0, 0, #options * 20)
					for i, opt in ipairs(options) do makeopt(opt, i) end
					if expanded then wrap.Size = UDim2.new(1, 0, 0, 22 + #options * 20) end
				end
			end,
			setvisible = function(v) wrap.Visible = v end,
			setname = function(t) lbl.Text = tostr(t) wrap:SetAttribute("RowLabel", tostr(t)) end,
		}
	end

	function s:createmulti(opts)
		opts = opts or {}
		s._order = s._order + 1
		local order = opts.order or s._order
		local label = tostr(opts.name or opts.label or "multi")
		local options = opts.options or {}
		local cb = opts.callback
		local selected = {}
		for _, d in ipairs(opts.default or {}) do selected[d] = true end

		local wrap = Instance.new("Frame")
		wrap.Size = UDim2.new(1, 0, 0, 22)
		wrap.BackgroundTransparency = 1
		wrap.ClipsDescendants = true
		wrap.LayoutOrder = order
		wrap.Parent = bd
		wrap:SetAttribute("RowLabel", label)

		local head = Instance.new("TextButton")
		head.Size = UDim2.new(1, 0, 0, 22)
		head.BackgroundColor3 = palette.row
		head.BorderSizePixel = 0
		head.Text = ""
		head.AutoButtonColor = false
		head.Parent = wrap

		local hc = Instance.new("UICorner")
		hc.CornerRadius = UDim.new(0, 2)
		hc.Parent = head

		local hs = Instance.new("UIStroke")
		hs.Color = palette.edge
		hs.Thickness = 1
		hs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		hs.Parent = head

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -100, 1, 0)
		lbl.Position = UDim2.new(0, 10, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = label
		lbl.TextColor3 = palette.txt
		lbl.TextSize = 11
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = head

		local val = Instance.new("TextLabel")
		val.Size = UDim2.new(0, 80, 1, 0)
		val.Position = UDim2.new(1, -90, 0, 0)
		val.BackgroundTransparency = 1
		val.Text = "..."
		val.TextColor3 = accent
		val.TextSize = 11
		val.Font = Enum.Font.Gotham
		val.TextXAlignment = Enum.TextXAlignment.Right
		val.Parent = head
		regaccent(val, "TextColor3")

		local bod = Instance.new("Frame")
		bod.Size = UDim2.new(1, 0, 0, #options * 20)
		bod.Position = UDim2.new(0, 0, 0, 22)
		bod.BackgroundColor3 = palette.panel
		bod.BorderSizePixel = 0
		bod.Parent = wrap

		local bc = Instance.new("UICorner")
		bc.CornerRadius = UDim.new(0, 2)
		bc.Parent = bod

		local bo = Instance.new("UIStroke")
		bo.Color = palette.edge
		bo.Thickness = 1
		bo.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		bo.Parent = bod

		local list = Instance.new("UIListLayout")
		list.SortOrder = Enum.SortOrder.LayoutOrder
		list.Parent = bod

		local function updatetext()
			local n = 0
			for _ in pairs(selected) do n = n + 1 end
			val.Text = n == 0 and "none" or (tostr(n) .. " selected")
		end
		updatetext()

		local function fire()
			local arr = {}
			for k in pairs(selected) do table.insert(arr, k) end
			if cb then safecall(cb, arr) end
		end

		for i, opt in ipairs(options) do
			local o = Instance.new("TextButton")
			o.Size = UDim2.new(1, 0, 0, 20)
			o.BackgroundColor3 = palette.panel
			o.BackgroundTransparency = 1
			o.BorderSizePixel = 0
			o.Text = "   " .. tostr(opt)
			o.TextColor3 = selected[opt] and accent or palette.muted
			o.TextSize = 11
			o.Font = Enum.Font.Gotham
			o.TextXAlignment = Enum.TextXAlignment.Left
			o.AutoButtonColor = false
			o.LayoutOrder = i
			o.Parent = bod

			track(o.MouseEnter:Connect(function()
				tw(o, 0.15, {BackgroundTransparency = 0, BackgroundColor3 = palette.rowhover})
			end))
			track(o.MouseLeave:Connect(function()
				tw(o, 0.15, {BackgroundTransparency = 1})
			end))
			track(o.MouseButton1Click:Connect(function()
				if selected[opt] then
					selected[opt] = nil
					o.TextColor3 = palette.muted
				else
					selected[opt] = true
					o.TextColor3 = accent
				end
				updatetext()
				fire()
			end))
		end

		local expanded = false
		track(head.MouseButton1Click:Connect(function()
			expanded = not expanded
			local target = expanded and UDim2.new(1, 0, 0, 22 + #options * 20) or UDim2.new(1, 0, 0, 22)
			tw(wrap, 0.25, {Size = target}, Enum.EasingStyle.Quart)
		end))

		return {
			get = function()
				local arr = {}
				for k in pairs(selected) do table.insert(arr, k) end
				return arr
			end,
			set = function(arr)
				selected = {}
				for _, v in ipairs(arr) do selected[v] = true end
				updatetext()
				fire()
			end,
			setvisible = function(v) wrap.Visible = v end,
			setname = function(t) lbl.Text = tostr(t) wrap:SetAttribute("RowLabel", tostr(t)) end,
		}
	end

	function s:createcolorpicker(opts)
		opts = opts or {}
		s._order = s._order + 1
		local order = opts.order or s._order
		local label = tostr(opts.name or opts.label or "color")
		local current = opts.default or accent
		local cb = opts.callback

		local hh, ss, vv = Color3.toHSV(current)
		local expanded = false

		local headh   = 26
		local bodypad = 10
		local squareh = 130
		local hueh    = 14
		local hexh    = 22
		local spacing = 6
		local bodyh   = bodypad + squareh + spacing + hueh + spacing + hexh + bodypad
		local exh     = headh + bodyh

		local wrap = Instance.new("Frame")
		wrap.Size = UDim2.new(1, 0, 0, headh)
		wrap.BackgroundTransparency = 1
		wrap.ClipsDescendants = true
		wrap.LayoutOrder = order
		wrap.Parent = bd
		wrap:SetAttribute("RowLabel", label)

		local head = Instance.new("TextButton")
		head.Size = UDim2.new(1, 0, 0, headh)
		head.BackgroundColor3 = palette.row
		head.BorderSizePixel = 0
		head.Text = ""
		head.AutoButtonColor = false
		head.Parent = wrap

		local hc = Instance.new("UICorner")
		hc.CornerRadius = UDim.new(0, 2)
		hc.Parent = head

		local hs = Instance.new("UIStroke")
		hs.Color = palette.edge
		hs.Thickness = 1
		hs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		hs.Parent = head

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -180, 1, 0)
		lbl.Position = UDim2.new(0, 10, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = label
		lbl.TextColor3 = palette.txt
		lbl.TextSize = 11
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = head

		local hexlbl = Instance.new("TextLabel")
		hexlbl.AnchorPoint = Vector2.new(1, 0.5)
		hexlbl.Size = UDim2.new(0, 100, 1, 0)
		hexlbl.Position = UDim2.new(1, -60, 0.5, 0)
		hexlbl.BackgroundTransparency = 1
		hexlbl.Text = ""
		hexlbl.TextColor3 = palette.muted
		hexlbl.TextSize = 11
		hexlbl.Font = Enum.Font.Code
		hexlbl.TextXAlignment = Enum.TextXAlignment.Right
		hexlbl.Parent = head

		local prev = Instance.new("Frame")
		prev.AnchorPoint = Vector2.new(1, 0.5)
		prev.Size = UDim2.new(0, 40, 0, 16)
		prev.Position = UDim2.new(1, -10, 0.5, 0)
		prev.BackgroundColor3 = current
		prev.BorderSizePixel = 0
		prev.Parent = head

		local pc = Instance.new("UICorner")
		pc.CornerRadius = UDim.new(0, 2)
		pc.Parent = prev

		local ps = Instance.new("UIStroke")
		ps.Color = palette.edge
		ps.Thickness = 1
		ps.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		ps.Parent = prev

		local pbod = Instance.new("Frame")
		pbod.Size = UDim2.new(1, 0, 0, bodyh)
		pbod.Position = UDim2.new(0, 0, 0, headh)
		pbod.BackgroundColor3 = palette.panel
		pbod.BorderSizePixel = 0
		pbod.Parent = wrap

		local pbc = Instance.new("UICorner")
		pbc.CornerRadius = UDim.new(0, 2)
		pbc.Parent = pbod

		local pbs = Instance.new("UIStroke")
		pbs.Color = palette.edge
		pbs.Thickness = 1
		pbs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		pbs.Parent = pbod

		local sq = Instance.new("Frame")
		sq.Size = UDim2.new(1, -bodypad * 2, 0, squareh)
		sq.Position = UDim2.new(0, bodypad, 0, bodypad)
		sq.BackgroundColor3 = Color3.fromHSV(hh, 1, 1)
		sq.BorderSizePixel = 0
		sq.Active = true
		sq.Parent = pbod

		local sqc = Instance.new("UICorner")
		sqc.CornerRadius = UDim.new(0, 2)
		sqc.Parent = sq

		local wl = Instance.new("Frame")
		wl.Size = UDim2.new(1, 0, 1, 0)
		wl.BackgroundColor3 = Color3.new(1, 1, 1)
		wl.BorderSizePixel = 0
		wl.Parent = sq
		local wlc = Instance.new("UICorner")
		wlc.CornerRadius = UDim.new(0, 2)
		wlc.Parent = wl
		local wg = Instance.new("UIGradient")
		wg.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
		wg.Parent = wl

		local bl = Instance.new("Frame")
		bl.Size = UDim2.new(1, 0, 1, 0)
		bl.BackgroundColor3 = Color3.new(0, 0, 0)
		bl.BorderSizePixel = 0
		bl.Parent = sq
		local blc = Instance.new("UICorner")
		blc.CornerRadius = UDim.new(0, 2)
		blc.Parent = bl
		local bg2 = Instance.new("UIGradient")
		bg2.Rotation = 90
		bg2.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})
		bg2.Parent = bl

		local cur = Instance.new("Frame")
		cur.Size = UDim2.new(0, 10, 0, 10)
		cur.AnchorPoint = Vector2.new(0.5, 0.5)
		cur.Position = UDim2.new(ss, 0, 1 - vv, 0)
		cur.BackgroundTransparency = 1
		cur.ZIndex = 5
		cur.Parent = sq
		local cc = Instance.new("UICorner")
		cc.CornerRadius = UDim.new(1, 0)
		cc.Parent = cur
		local cco = Instance.new("UIStroke")
		cco.Color = Color3.new(1, 1, 1)
		cco.Thickness = 2
		cco.Parent = cur
		local cci = Instance.new("UIStroke")
		cci.Color = Color3.new(0, 0, 0)
		cci.Thickness = 1
		cci.Parent = cur

		local hue = Instance.new("Frame")
		hue.Size = UDim2.new(1, -bodypad * 2, 0, hueh)
		hue.Position = UDim2.new(0, bodypad, 0, bodypad + squareh + spacing)
		hue.BackgroundColor3 = Color3.new(1, 1, 1)
		hue.BorderSizePixel = 0
		hue.Active = true
		hue.Parent = pbod

		local huc = Instance.new("UICorner")
		huc.CornerRadius = UDim.new(0, 2)
		huc.Parent = hue

		local hg = Instance.new("UIGradient")
		hg.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0/6, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(1/6, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(2/6, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(3/6, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(4/6, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(5/6, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(6/6, Color3.fromRGB(255, 0, 0)),
		})
		hg.Parent = hue

		local hcur = Instance.new("Frame")
		hcur.Size = UDim2.new(0, 3, 1, 4)
		hcur.AnchorPoint = Vector2.new(0.5, 0.5)
		hcur.Position = UDim2.new(hh, 0, 0.5, 0)
		hcur.BackgroundTransparency = 1
		hcur.ZIndex = 5
		hcur.Parent = hue
		local hcc = Instance.new("UICorner")
		hcc.CornerRadius = UDim.new(0, 1)
		hcc.Parent = hcur
		local hco = Instance.new("UIStroke")
		hco.Color = Color3.new(1, 1, 1)
		hco.Thickness = 2
		hco.Parent = hcur
		local hci = Instance.new("UIStroke")
		hci.Color = Color3.new(0, 0, 0)
		hci.Thickness = 1
		hci.Parent = hcur

		local hexbox = Instance.new("TextBox")
		hexbox.Size = UDim2.new(1, -bodypad * 2, 0, hexh)
		hexbox.Position = UDim2.new(0, bodypad, 0, bodypad + squareh + spacing + hueh + spacing)
		hexbox.BackgroundColor3 = palette.field
		hexbox.BorderSizePixel = 0
		hexbox.Text = string.format("#%02X%02X%02X", math.floor(current.R * 255), math.floor(current.G * 255), math.floor(current.B * 255))
		hexbox.TextColor3 = palette.txt
		hexbox.TextSize = 11
		hexbox.Font = Enum.Font.Code
		hexbox.ClearTextOnFocus = false
		hexbox.Parent = pbod

		local hbc = Instance.new("UICorner")
		hbc.CornerRadius = UDim.new(0, 2)
		hbc.Parent = hexbox

		local hbs = Instance.new("UIStroke")
		hbs.Color = palette.edge
		hbs.Thickness = 1
		hbs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		hbs.Parent = hexbox

		local hbp = Instance.new("UIPadding")
		hbp.PaddingLeft = UDim.new(0, 6)
		hbp.Parent = hexbox

		local mag

		local function hextxt()
			return string.format("#%02X%02X%02X", math.floor(current.R * 255), math.floor(current.G * 255), math.floor(current.B * 255))
		end

		local function refresh()
			sq.BackgroundColor3 = Color3.fromHSV(hh, 1, 1)
			cur.Position = UDim2.new(ss, 0, 1 - vv, 0)
			hcur.Position = UDim2.new(hh, 0, 0.5, 0)
			prev.BackgroundColor3 = current
			hexbox.Text = hextxt()
			hexlbl.Text = hextxt()
		end

		local function showmag()
			if not mag then
				local sg = s.window.screengui
				if not sg or not sg.Parent then return end
				mag = Instance.new("Frame")
				mag.Name = "PickerMagnifier"
				mag.Size = UDim2.new(0, 0, 0, 0)
				mag.AnchorPoint = Vector2.new(0.5, 0.5)
				mag.BackgroundColor3 = current
				mag.BorderSizePixel = 0
				mag.ZIndex = 300
				mag.Parent = sg
				local mc = Instance.new("UICorner")
				mc.CornerRadius = UDim.new(1, 0)
				mc.Parent = mag
				local ms = Instance.new("UIStroke")
				ms.Color = Color3.new(1, 1, 1)
				ms.Thickness = 2
				ms.Parent = mag
				tween:Create(mag, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 88, 0, 88)}):Play()
			end
			if mag and mag.Parent then
				mag.BackgroundColor3 = current
				local m = input:GetMouseLocation()
				mag.Position = UDim2.new(0, m.X, 0, m.Y - 75)
			end
		end

		local function hidemag()
			if mag then
				local m = mag
				mag = nil
				tween:Create(m, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
				trackthread(task.delay(0.25, function() if m and m.Parent then pcall(function() m:Destroy() end) end end))
			end
		end

		local dragsq, draghue = false, false

		local function updatess(i)
			if not sq.Parent then return end
			local relx = math.clamp((i.Position.X - sq.AbsolutePosition.X) / sq.AbsoluteSize.X, 0, 1)
			local rely = math.clamp((i.Position.Y - sq.AbsolutePosition.Y) / sq.AbsoluteSize.Y, 0, 1)
			ss = relx
			vv = 1 - rely
			current = Color3.fromHSV(hh, ss, vv)
			refresh()
			if cb then safecall(cb, current) end
		end

		local function updatehue(i)
			if not hue.Parent then return end
			local relx = math.clamp((i.Position.X - hue.AbsolutePosition.X) / hue.AbsoluteSize.X, 0, 1)
			hh = relx
			current = Color3.fromHSV(hh, ss, vv)
			refresh()
			if cb then safecall(cb, current) end
		end

		track(sq.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				dragsq = true
				updatess(i)
				showmag()
			end
		end))
		track(hue.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				draghue = true
				updatehue(i)
			end
		end))
		track(input.InputChanged:Connect(function(i)
			if dragsq and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				updatess(i)
				showmag()
			end
			if draghue and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				updatehue(i)
			end
		end))
		track(input.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				if dragsq then dragsq = false hidemag() s.window:saveconfig() end
				if draghue then draghue = false s.window:saveconfig() end
			end
		end))
		track(hexbox.FocusLost:Connect(function()
			tw(hbs, 0.15, {Color = palette.edge})
			local hex = hexbox.Text:gsub("#", "")
			if #hex == 6 then
				local r = tonumber(hex:sub(1, 2), 16)
				local g = tonumber(hex:sub(3, 4), 16)
				local b = tonumber(hex:sub(5, 6), 16)
				if r and g and b then
					current = Color3.fromRGB(r, g, b)
					hh, ss, vv = Color3.toHSV(current)
					refresh()
					if cb then safecall(cb, current) end
				end
			end
		end))
		track(hexbox.Focused:Connect(function()
			tw(hbs, 0.15, {Color = accent})
		end))

		local function toggleexp()
			expanded = not expanded
			local target = expanded and UDim2.new(1, 0, 0, exh) or UDim2.new(1, 0, 0, headh)
			tw(wrap, 0.28, {Size = target}, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
			tw(hs, 0.2, {Color = expanded and accent or palette.edge})
		end

		track(head.MouseButton1Click:Connect(toggleexp))
		track(head.MouseEnter:Connect(function()
			if not expanded then tw(head, 0.15, {BackgroundColor3 = palette.rowhover}) end
		end))
		track(head.MouseLeave:Connect(function()
			if not expanded then tw(head, 0.15, {BackgroundColor3 = palette.row}) end
		end))

		refresh()

		return {
			get = function() return current end,
			set = function(c)
				current = c
				hh, ss, vv = Color3.toHSV(c)
				refresh()
				if cb then safecall(cb, c) end
			end,
			setvisible = function(v) wrap.Visible = v end,
			setname = function(t) lbl.Text = tostr(t) wrap:SetAttribute("RowLabel", tostr(t)) end,
			expand = function() if not expanded then toggleexp() end end,
			collapse = function() if expanded then toggleexp() end end,
		}
	end

	function s:createkeybind(opts)
		opts = opts or {}
		s._order = s._order + 1
		local order = opts.order or s._order
		local label = tostr(opts.name or opts.label or "keybind")
		local defkey = opts.default or Enum.KeyCode.E
		local cb = opts.callback

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 22)
		row.BackgroundColor3 = palette.row
		row.BorderSizePixel = 0
		row.LayoutOrder = order
		row.Parent = bd
		row:SetAttribute("RowLabel", label)

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 2)
		corner.Parent = row

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -80, 1, 0)
		lbl.Position = UDim2.new(0, 10, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = label
		lbl.TextColor3 = palette.txt
		lbl.TextSize = 11
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row

		local kb = Instance.new("TextButton")
		kb.Size = UDim2.new(0, 55, 0, 14)
		kb.Position = UDim2.new(1, -65, 0.5, -7)
		kb.BackgroundColor3 = palette.field
		kb.BorderSizePixel = 0
		kb.Text = tostr(defkey):gsub("Enum.KeyCode.", "")
		kb.TextColor3 = accent
		kb.TextSize = 10
		kb.Font = Enum.Font.Gotham
		kb.AutoButtonColor = false
		kb.Parent = row

		local kbc = Instance.new("UICorner")
		kbc.CornerRadius = UDim.new(0, 2)
		kbc.Parent = kb

		local kbs = Instance.new("UIStroke")
		kbs.Color = palette.edge
		kbs.Thickness = 1
		kbs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		kbs.Parent = kb

		local entry = {key = defkey, callback = function() if cb then safecall(cb) end end, owner = s}
		table.insert(keybinds, entry)

		track(kb.MouseEnter:Connect(function()
			tw(kb, 0.15, {BackgroundColor3 = Color3.fromRGB(24, 24, 24)})
			tw(kbs, 0.15, {Color = accent})
		end))
		track(kb.MouseLeave:Connect(function()
			tw(kb, 0.15, {BackgroundColor3 = palette.field})
			tw(kbs, 0.15, {Color = palette.edge})
		end))
		track(kb.MouseButton1Click:Connect(function()
			if keycap then return end
			kb.Text = "..."
			keycap = function(key)
				entry.key = key
				kb.Text = tostr(key):gsub("Enum.KeyCode.", "")
			end
		end))

		return {
			get = function() return entry.key end,
			set = function(k) entry.key = k kb.Text = tostr(k):gsub("Enum.KeyCode.", "") end,
			setvisible = function(v) row.Visible = v end,
			setname = function(t) lbl.Text = tostr(t) row:SetAttribute("RowLabel", tostr(t)) end,
		}
	end

	function s:createtextbox(opts)
		opts = opts or {}
		s._order = s._order + 1
		local order = opts.order or s._order
		local label = tostr(opts.name or opts.label or "input")
		local default = tostr(opts.default or "")
		local placeholder = tostr(opts.placeholder or "")
		local cb = opts.callback
		local clearfocus = opts.clearonfocus ~= false

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 22)
		row.BackgroundColor3 = palette.row
		row.BorderSizePixel = 0
		row.LayoutOrder = order
		row.Parent = bd
		row:SetAttribute("RowLabel", label)

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 2)
		corner.Parent = row

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0, 100, 1, 0)
		lbl.Position = UDim2.new(0, 10, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = label
		lbl.TextColor3 = palette.txt
		lbl.TextSize = 11
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row

		local box = Instance.new("TextBox")
		box.Size = UDim2.new(1, -120, 0, 16)
		box.Position = UDim2.new(0, 110, 0.5, -8)
		box.BackgroundColor3 = palette.field
		box.BorderSizePixel = 0
		box.Text = default
		box.PlaceholderText = placeholder
		box.TextColor3 = palette.txt
		box.PlaceholderColor3 = palette.muted
		box.TextSize = 11
		box.Font = Enum.Font.Gotham
		box.ClearTextOnFocus = clearfocus
		box.TextXAlignment = Enum.TextXAlignment.Left
		box.Parent = row

		local bc = Instance.new("UICorner")
		bc.CornerRadius = UDim.new(0, 2)
		bc.Parent = box

		local bs = Instance.new("UIStroke")
		bs.Color = palette.edge
		bs.Thickness = 1
		bs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		bs.Parent = box

		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, 6)
		pad.Parent = box

		track(box.FocusLost:Connect(function()
			tw(bs, 0.15, {Color = palette.edge})
			if cb then safecall(cb, box.Text) end
		end))
		track(box.Focused:Connect(function()
			tw(bs, 0.15, {Color = accent})
		end))

		return {
			get = function() return box.Text end,
			set = function(v) box.Text = tostr(v) if cb then safecall(cb, tostr(v)) end end,
			setvisible = function(v) row.Visible = v end,
			setname = function(t) lbl.Text = tostr(t) row:SetAttribute("RowLabel", tostr(t)) end,
		}
	end

	function s:createlabel(opts)
		opts = opts or {}
		s._order = s._order + 1
		local order = opts.order or s._order
		local text = tostr(opts.name or opts.text or opts.label or "label")
		local color = opts.color or palette.txt
		local size = opts.size or 11
		local align = opts.align or Enum.TextXAlignment.Left

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, 0, 0, 18)
		lbl.BackgroundTransparency = 1
		lbl.Text = text
		lbl.TextColor3 = color
		lbl.TextSize = size
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = align
		lbl.LayoutOrder = order
		lbl.Parent = bd
		lbl:SetAttribute("RowLabel", text)

		return {
			set = function(t) lbl.Text = tostr(t) lbl:SetAttribute("RowLabel", tostr(t)) end,
			get = function() return lbl.Text end,
			setvisible = function(v) lbl.Visible = v end,
		}
	end

	function s:createparagraph(opts)
		opts = opts or {}
		s._order = s._order + 1
		local order = opts.order or s._order
		local title = tostr(opts.title or "info")
		local content = tostr(opts.content or opts.text or "")

		local wrap = Instance.new("Frame")
		wrap.Size = UDim2.new(1, 0, 0, 0)
		wrap.AutomaticSize = Enum.AutomaticSize.Y
		wrap.BackgroundColor3 = palette.row
		wrap.BorderSizePixel = 0
		wrap.LayoutOrder = order
		wrap.Parent = bd
		wrap:SetAttribute("RowLabel", title .. " " .. content)

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 2)
		corner.Parent = wrap

		local stroke = Instance.new("UIStroke")
		stroke.Color = palette.edge
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
		t.TextColor3 = accent
		t.TextSize = 11
		t.Font = Enum.Font.GothamBold
		t.TextXAlignment = Enum.TextXAlignment.Left
		t.LayoutOrder = 1
		t.Parent = wrap
		regaccent(t, "TextColor3")

		local c = Instance.new("TextLabel")
		c.Size = UDim2.new(1, 0, 0, 0)
		c.AutomaticSize = Enum.AutomaticSize.Y
		c.BackgroundTransparency = 1
		c.Text = content
		c.TextColor3 = palette.muted
		c.TextSize = 11
		c.Font = Enum.Font.Gotham
		c.TextXAlignment = Enum.TextXAlignment.Left
		c.TextWrapped = true
		c.TextYAlignment = Enum.TextYAlignment.Top
		c.LayoutOrder = 2
		c.Parent = wrap

		return {
			settitle = function(v) t.Text = tostr(v) wrap:SetAttribute("RowLabel", tostr(v) .. " " .. c.Text) end,
			setcontent = function(v) c.Text = tostr(v) wrap:SetAttribute("RowLabel", t.Text .. " " .. tostr(v)) end,
			setvisible = function(v) wrap.Visible = v end,
		}
	end

	function s:createdivider()
		s._order = s._order + 1
		local line = Instance.new("Frame")
		line.Size = UDim2.new(1, 0, 0, 1)
		line.BackgroundColor3 = palette.edge
		line.BorderSizePixel = 0
		line.LayoutOrder = s._order
		line.Parent = bd
		return {frame = line}
	end

	function s:createimage(opts)
		opts = opts or {}
		s._order = s._order + 1
		local order = opts.order or s._order
		local image = tostr(opts.image or "")
		local h = opts.height or 100

		local img = Instance.new("ImageLabel")
		img.Size = UDim2.new(1, 0, 0, h)
		img.BackgroundColor3 = palette.row
		img.BorderSizePixel = 0
		img.Image = image
		img.ScaleType = opts.scaletype or Enum.ScaleType.Fit
		img.LayoutOrder = order
		img.Parent = bd

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 2)
		corner.Parent = img

		local stroke = Instance.new("UIStroke")
		stroke.Color = palette.edge
		stroke.Thickness = 1
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = img

		return {
			setimage = function(v) img.Image = tostr(v) end,
			setvisible = function(v) img.Visible = v end,
		}
	end

	function s:createprogress(opts)
		opts = opts or {}
		s._order = s._order + 1
		local order = opts.order or s._order
		local label = tostr(opts.name or opts.label or "progress")
		local value = opts.default or 0
		local mx = opts.max or 100
		local showtext = opts.showtext ~= false

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 30)
		row.BackgroundColor3 = palette.row
		row.BorderSizePixel = 0
		row.LayoutOrder = order
		row.Parent = bd
		row:SetAttribute("RowLabel", label)

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 2)
		corner.Parent = row

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -60, 0, 14)
		lbl.Position = UDim2.new(0, 10, 0, 3)
		lbl.BackgroundTransparency = 1
		lbl.Text = label
		lbl.TextColor3 = palette.txt
		lbl.TextSize = 11
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row

		local pct = Instance.new("TextLabel")
		pct.Size = UDim2.new(0, 50, 0, 14)
		pct.Position = UDim2.new(1, -60, 0, 3)
		pct.BackgroundTransparency = 1
		pct.Text = "0%"
		pct.TextColor3 = palette.muted
		pct.TextSize = 11
		pct.Font = Enum.Font.Gotham
		pct.TextXAlignment = Enum.TextXAlignment.Right
		pct.Parent = row

		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(1, -20, 0, 6)
		bar.Position = UDim2.new(0, 10, 0, 20)
		bar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
		bar.BorderSizePixel = 0
		bar.Parent = row

		local barc = Instance.new("UICorner")
		barc.CornerRadius = UDim.new(0, 1)
		barc.Parent = bar

		local fill = Instance.new("Frame")
		fill.Size = UDim2.new(math.clamp(value / mx, 0, 1), 0, 1, 0)
		fill.BackgroundColor3 = accent
		fill.BorderSizePixel = 0
		fill.Parent = bar
		regaccent(fill)

		local fc = Instance.new("UICorner")
		fc.CornerRadius = UDim.new(0, 1)
		fc.Parent = fill

		local function refresh()
			local p = math.clamp(value / mx, 0, 1)
			fill.Size = UDim2.new(p, 0, 1, 0)
			if showtext then pct.Text = string.format("%d%%", math.floor(p * 100 + 0.5))
			else pct.Text = "" end
		end
		refresh()

		return {
			set = function(v) value = math.clamp(v, 0, mx) refresh() end,
			get = function() return value end,
			setmax = function(m) mx = m refresh() end,
			setvisible = function(v) row.Visible = v end,
			setname = function(t) lbl.Text = tostr(t) row:SetAttribute("RowLabel", tostr(t)) end,
		}
	end

	function s:createstepper(opts)
		opts = opts or {}
		s._order = s._order + 1
		local order = opts.order or s._order
		local label = tostr(opts.name or opts.label or "stepper")
		local value = opts.default or 0
		local step = opts.step or 1
		local mn = opts.min or -math.huge
		local mx = opts.max or math.huge
		local dec = opts.decimals or 0
		local cb = opts.callback

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 22)
		row.BackgroundColor3 = palette.row
		row.BorderSizePixel = 0
		row.LayoutOrder = order
		row.Parent = bd
		row:SetAttribute("RowLabel", label)

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 2)
		corner.Parent = row

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -140, 1, 0)
		lbl.Position = UDim2.new(0, 10, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = label
		lbl.TextColor3 = palette.txt
		lbl.TextSize = 11
		lbl.Font = Enum.Font.Gotham
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = row

		local minus = Instance.new("TextButton")
		minus.Size = UDim2.new(0, 16, 0, 16)
		minus.Position = UDim2.new(1, -114, 0.5, -8)
		minus.BackgroundColor3 = palette.field
		minus.BorderSizePixel = 0
		minus.Text = "−"
		minus.TextColor3 = palette.txt
		minus.TextSize = 12
		minus.Font = Enum.Font.GothamBold
		minus.AutoButtonColor = false
		minus.Parent = row

		local mc = Instance.new("UICorner")
		mc.CornerRadius = UDim.new(0, 2)
		mc.Parent = minus

		local val = Instance.new("TextLabel")
		val.Size = UDim2.new(0, 60, 1, 0)
		val.Position = UDim2.new(1, -94, 0, 0)
		val.BackgroundTransparency = 1
		val.Text = string.format("%." .. dec .. "f", value)
		val.TextColor3 = accent
		val.TextSize = 11
		val.Font = Enum.Font.Code
		val.Parent = row
		regaccent(val, "TextColor3")

		local plus = Instance.new("TextButton")
		plus.Size = UDim2.new(0, 16, 0, 16)
		plus.Position = UDim2.new(1, -30, 0.5, -8)
		plus.BackgroundColor3 = palette.field
		plus.BorderSizePixel = 0
		plus.Text = "+"
		plus.TextColor3 = palette.txt
		plus.TextSize = 12
		plus.Font = Enum.Font.GothamBold
		plus.AutoButtonColor = false
		plus.Parent = row

		local pc = Instance.new("UICorner")
		pc.CornerRadius = UDim.new(0, 2)
		pc.Parent = plus

		local function setval(v)
			value = math.clamp(v, mn, mx)
			val.Text = string.format("%." .. dec .. "f", value)
			if cb then safecall(cb, value) end
		end

		track(minus.MouseButton1Click:Connect(function() setval(value - step) end))
		track(plus.MouseButton1Click:Connect(function() setval(value + step) end))
		track(minus.MouseEnter:Connect(function() tw(minus, 0.15, {BackgroundColor3 = palette.rowhover}) end))
		track(minus.MouseLeave:Connect(function() tw(minus, 0.15, {BackgroundColor3 = palette.field}) end))
		track(plus.MouseEnter:Connect(function() tw(plus, 0.15, {BackgroundColor3 = palette.rowhover}) end))
		track(plus.MouseLeave:Connect(function() tw(plus, 0.15, {BackgroundColor3 = palette.field}) end))

		return {
			get = function() return value end,
			set = setval,
			setvisible = function(v) row.Visible = v end,
			setname = function(t) lbl.Text = tostr(t) row:SetAttribute("RowLabel", tostr(t)) end,
		}
	end

	function s:createradio(opts)
		opts = opts or {}
		s._order = s._order + 1
		local order = opts.order or s._order
		local label = tostr(opts.name or opts.label or "radio")
		local options = opts.options or {}
		local selected = opts.default or options[1]
		local cb = opts.callback

		local wrap = Instance.new("Frame")
		wrap.Size = UDim2.new(1, 0, 0, 0)
		wrap.AutomaticSize = Enum.AutomaticSize.Y
		wrap.BackgroundColor3 = palette.row
		wrap.BorderSizePixel = 0
		wrap.LayoutOrder = order
		wrap.Parent = bd
		wrap:SetAttribute("RowLabel", label)

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 2)
		corner.Parent = wrap

		local stroke = Instance.new("UIStroke")
		stroke.Color = palette.edge
		stroke.Thickness = 1
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = wrap

		local layout = Instance.new("UIListLayout")
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = wrap

		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, 4)
		pad.PaddingBottom = UDim.new(0, 4)
		pad.PaddingLeft = UDim.new(0, 8)
		pad.PaddingRight = UDim.new(0, 8)
		pad.Parent = wrap

		local head = Instance.new("TextLabel")
		head.Size = UDim2.new(1, 0, 0, 14)
		head.BackgroundTransparency = 1
		head.Text = label
		head.TextColor3 = palette.txt
		head.TextSize = 11
		head.Font = Enum.Font.GothamMedium
		head.TextXAlignment = Enum.TextXAlignment.Left
		head.LayoutOrder = 0
		head.Parent = wrap

		local dots = {}
		local function update()
			for opt, dot in pairs(dots) do
				if opt == selected then
					dot.BackgroundColor3 = accent
					dot.BackgroundTransparency = 0
				else
					dot.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
					dot.BackgroundTransparency = 0
				end
			end
		end

		for i, opt in ipairs(options) do
			local rowbtn = Instance.new("TextButton")
			rowbtn.Size = UDim2.new(1, 0, 0, 18)
			rowbtn.BackgroundTransparency = 1
			rowbtn.Text = ""
			rowbtn.AutoButtonColor = false
			rowbtn.LayoutOrder = i
			rowbtn.Parent = wrap

			local dot = Instance.new("Frame")
			dot.Size = UDim2.new(0, 8, 0, 8)
			dot.Position = UDim2.new(0, 4, 0.5, -4)
			dot.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			dot.BorderSizePixel = 0
			dot.Parent = rowbtn

			local dc = Instance.new("UICorner")
			dc.CornerRadius = UDim.new(1, 0)
			dc.Parent = dot

			local txt = Instance.new("TextLabel")
			txt.Size = UDim2.new(1, -30, 1, 0)
			txt.Position = UDim2.new(0, 20, 0, 0)
			txt.BackgroundTransparency = 1
			txt.Text = tostr(opt)
			txt.TextColor3 = palette.txt
			txt.TextSize = 11
			txt.Font = Enum.Font.Gotham
			txt.TextXAlignment = Enum.TextXAlignment.Left
			txt.Parent = rowbtn

			dots[opt] = dot

			track(rowbtn.MouseButton1Click:Connect(function()
				selected = opt
				update()
				if cb then safecall(cb, opt) end
			end))
		end

		update()

		return {
			get = function() return selected end,
			set = function(v) selected = v update() if cb then safecall(cb, v) end end,
			setvisible = function(v) wrap.Visible = v end,
		}
	end

	function s:createsearch(opts)
		opts = opts or {}
		s._order = s._order + 1
		local order = opts.order or s._order
		local placeholder = tostr(opts.placeholder or "search...")
		local cb = opts.callback

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 22)
		row.BackgroundColor3 = palette.row
		row.BorderSizePixel = 0
		row.LayoutOrder = order
		row.Parent = bd

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 2)
		corner.Parent = row

		local stroke = Instance.new("UIStroke")
		stroke.Color = palette.edge
		stroke.Thickness = 1
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = row

		local icon = Instance.new("ImageLabel")
		icon.Size = UDim2.new(0, 12, 0, 12)
		icon.Position = UDim2.new(0, 6, 0.5, -6)
		icon.BackgroundTransparency = 1
		icon.Image = acursive.icons.search
		icon.ImageColor3 = palette.muted
		icon.Parent = row

		local box = Instance.new("TextBox")
		box.Size = UDim2.new(1, -30, 1, 0)
		box.Position = UDim2.new(0, 22, 0, 0)
		box.BackgroundTransparency = 1
		box.Text = ""
		box.PlaceholderText = placeholder
		box.PlaceholderColor3 = palette.muted
		box.TextColor3 = palette.txt
		box.TextSize = 11
		box.Font = Enum.Font.Gotham
		box.TextXAlignment = Enum.TextXAlignment.Left
		box.ClearTextOnFocus = false
		box.Parent = row

		track(box:GetPropertyChangedSignal("Text"):Connect(function()
			if cb then safecall(cb, box.Text) end
		end))
		track(box.Focused:Connect(function()
			tw(stroke, 0.15, {Color = accent})
			tw(icon, 0.15, {ImageColor3 = accent})
		end))
		track(box.FocusLost:Connect(function()
			tw(stroke, 0.15, {Color = palette.edge})
			tw(icon, 0.15, {ImageColor3 = palette.muted})
		end))

		return {
			get = function() return box.Text end,
			set = function(v) box.Text = tostr(v) end,
			setvisible = function(v) row.Visible = v end,
		}
	end

	return s
end

function tab:select() self.window:select(self.name) end
function tab:getname() return self.name end

function tab:destroy()
	if self.destroyed then return end
	self.destroyed = true
	for _, sec in ipairs(self.sections) do
		if sec and sec.destroy then sec:destroy() end
	end
	self.sections = {}
	if self.page and self.page.Parent then
		pcall(function() self.page:Destroy() end)
	end
	self.page = nil
	self.search = nil
end

if getgenv then
	getgenv().Acursive = acursive
end

return acursive
