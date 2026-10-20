--[[
	AcursiveDocks
	Created by @Quest 
  Inspired by SSPDocks Aka Moon & Dex docks

	A window management library

            V3.15 ~ 

  [+] Added ImageURLs/gihpys support
  [+] CleanUpCrew Logic
  [+] Fail Feedback 
  [+] Entire Theme Support; Modularity as in you can edit whatever you want UIs Wise.
]]

local dock = {}
if getgenv()._sspdockcontainer then
	pcall(function() getgenv()._sspdockcontainer:cleanup() end)
end
getgenv()._sspdockcontainer = dock
dock.all = {}

local players = game:GetService("Players")
local input = game:GetService("UserInputService")
local tween = game:GetService("TweenService")
local run = game:GetService("RunService")
local coregui = game:GetService("CoreGui")
local http = game:GetService("HttpService")

local player = players.LocalPlayer
local holder = pcall(function() return coregui.Name end) and coregui or player:WaitForChild("PlayerGui")
local isa = game.IsA
local typeof = typeof

local function newstyle()
	return {
		colors = {
			back = Color3.fromRGB(45, 45, 45),
			top = Color3.fromRGB(52, 52, 52),
			topoff = Color3.fromRGB(42, 42, 42),
			topgrad = nil,
			edge = Color3.fromRGB(33, 33, 33),
			border = Color3.fromRGB(33, 33, 33),
			txt = Color3.fromRGB(255, 255, 255),
			txtoff = Color3.fromRGB(160, 160, 160),
			btn = Color3.fromRGB(60, 60, 60),
			btnover = Color3.fromRGB(68, 68, 68),
			btndown = Color3.fromRGB(40, 40, 40),
			grip = Color3.fromRGB(65, 65, 65),
			accent = Color3.fromRGB(0, 170, 255),
			hint = Color3.fromRGB(0, 170, 255),
			ico = Color3.fromRGB(255, 255, 255),
			scroll = Color3.fromRGB(80, 80, 80),
		},
		text = {
			font = Enum.Font.Gotham,
			titlefont = Enum.Font.Gotham,
			titlesize = 14,
			titlealign = Enum.TextXAlignment.Left,
			titlestroke = false,
			titlestrokecolor = Color3.new(0, 0, 0),
		},
		shape = {
			radius = UDim.new(0, 4),
			borderthick = 1,
			topheight = 20,
			gripthick = 5,
			pad = 4,
			dockgap = 4,
			btnsize = 16,
			btnradius = UDim.new(0, 4),
			bevel = false,
			bevellight = Color3.fromRGB(90, 90, 90),
			beveldark = Color3.fromRGB(20, 20, 20),
		},
		chrome = {
			showedge = true,
			edgeimg = "rbxassetid://1427967925",
			showshadow = true,
		},
		titlebar = {
			showclose = true,
			showmini = true,
			showmax = false,
			btnorder = {"mini", "max", "close"},
			btnside = "right",
			dblmini = true,
			textglyph = false,
			closeglyph = "X",
			miniglyph = "-",
			maxglyph = "[]",
			restoreglyph = "[]",
			subtitle = "",
		},
		anim = {
			openstyle = "roll",
			closestyle = "roll",
			minstyle = "roll",
			duration = 0.2,
			easing = Enum.EasingStyle.Quad,
			easingdir = Enum.EasingDirection.Out,
			sideduration = 0.3,
			stepped = false,
			steps = 3,
		},
		docking = {
			leftw = 300,
			rightw = 300,
			minw = 200,
			freew = 200,
			togglew = 16,
			toggleh = 36,
			toggleoff = -36,
		},
		bg = {
			opacity = 1,
			img = nil,
			fps = 30,
			imgtrans = 0,
			scanlines = false,
			scanopacity = 0.15,
			pattern = nil,
		},
		sounds = {
			on = false,
			click = "",
			open = "",
			close = "",
			mini = "",
			error = "",
			vol = 0.5,
		},
		icons = {
			closeicon = "rbxassetid://5054663650",
			miniicon = "rbxassetid://5034768003",
			minirestore = "rbxassetid://5060023708",
			maxicon = "rbxassetid://0",
			restoreicon = "rbxassetid://0",
		},
	}
end

local function retro()
	local s = newstyle()
	s.colors.back = Color3.fromRGB(192, 192, 192)
	s.colors.top = Color3.fromRGB(0, 0, 128)
	s.colors.topoff = Color3.fromRGB(128, 128, 128)
	s.colors.topgrad = {Color3.fromRGB(0, 0, 128), Color3.fromRGB(16, 132, 208)}
	s.colors.edge = Color3.fromRGB(0, 0, 0)
	s.colors.border = Color3.fromRGB(0, 0, 0)
	s.colors.txt = Color3.fromRGB(255, 255, 255)
	s.colors.txtoff = Color3.fromRGB(192, 192, 192)
	s.colors.btn = Color3.fromRGB(192, 192, 192)
	s.colors.btnover = Color3.fromRGB(208, 208, 208)
	s.colors.btndown = Color3.fromRGB(160, 160, 160)
	s.colors.grip = Color3.fromRGB(192, 192, 192)
	s.colors.accent = Color3.fromRGB(0, 0, 128)
	s.colors.hint = Color3.fromRGB(0, 0, 128)
	s.colors.ico = Color3.fromRGB(0, 0, 0)
	s.colors.scroll = Color3.fromRGB(128, 128, 128)
	s.text.font = Enum.Font.Code
	s.text.titlefont = Enum.Font.Code
	s.text.titlesize = 12
	s.shape.radius = UDim.new(0, 0)
	s.shape.borderthick = 2
	s.shape.topheight = 18
	s.shape.gripthick = 4
	s.shape.btnsize = 14
	s.shape.btnradius = UDim.new(0, 0)
	s.shape.bevel = true
	s.shape.bevellight = Color3.fromRGB(255, 255, 255)
	s.shape.beveldark = Color3.fromRGB(64, 64, 64)
	s.titlebar.textglyph = true
	s.titlebar.closeglyph = "X"
	s.titlebar.miniglyph = "_"
	s.titlebar.maxglyph = "[]"
	s.titlebar.restoreglyph = "[]"
	s.anim.openstyle = "instant"
	s.anim.closestyle = "instant"
	s.anim.minstyle = "instant"
	s.anim.duration = 0
	s.anim.stepped = true
	return s
end

local function xp()
	local s = newstyle()
	s.colors.back = Color3.fromRGB(236, 233, 216)
	s.colors.top = Color3.fromRGB(0, 88, 238)
	s.colors.topoff = Color3.fromRGB(148, 187, 233)
	s.colors.topgrad = {Color3.fromRGB(0, 88, 238), Color3.fromRGB(58, 147, 255)}
	s.colors.edge = Color3.fromRGB(0, 60, 180)
	s.colors.border = Color3.fromRGB(0, 60, 180)
	s.colors.txt = Color3.fromRGB(255, 255, 255)
	s.colors.txtoff = Color3.fromRGB(220, 220, 220)
	s.colors.btn = Color3.fromRGB(236, 233, 216)
	s.colors.btnover = Color3.fromRGB(250, 248, 230)
	s.colors.btndown = Color3.fromRGB(210, 206, 188)
	s.colors.grip = Color3.fromRGB(236, 233, 216)
	s.colors.accent = Color3.fromRGB(0, 88, 238)
	s.colors.hint = Color3.fromRGB(0, 88, 238)
	s.colors.ico = Color3.fromRGB(0, 0, 0)
	s.colors.scroll = Color3.fromRGB(160, 160, 160)
	s.text.titlefont = Enum.Font.GothamBold
	s.text.titlesize = 12
	s.shape.radius = UDim.new(0, 8)
	s.shape.topheight = 24
	s.shape.btnsize = 16
	s.shape.btnradius = UDim.new(0, 4)
	s.chrome.showedge = true
	return s
end

local function glass()
	local s = newstyle()
	s.colors.back = Color3.fromRGB(30, 30, 30)
	s.colors.top = Color3.fromRGB(45, 45, 45)
	s.colors.topoff = Color3.fromRGB(35, 35, 35)
	s.colors.edge = Color3.fromRGB(80, 80, 80)
	s.colors.txt = Color3.fromRGB(255, 255, 255)
	s.bg.opacity = 0.85
	s.shape.radius = UDim.new(0, 12)
	s.shape.topheight = 28
	s.chrome.showedge = false
	s.chrome.showshadow = false
	s.text.titlefont = Enum.Font.Gotham
	s.text.titlesize = 13
	return s
end

local function term()
	local s = newstyle()
	s.colors.back = Color3.fromRGB(0, 0, 0)
	s.colors.top = Color3.fromRGB(0, 64, 0)
	s.colors.topoff = Color3.fromRGB(0, 32, 0)
	s.colors.txt = Color3.fromRGB(0, 255, 0)
	s.colors.txtoff = Color3.fromRGB(0, 128, 0)
	s.colors.btn = Color3.fromRGB(0, 32, 0)
	s.colors.btnover = Color3.fromRGB(0, 64, 0)
	s.colors.btndown = Color3.fromRGB(0, 16, 0)
	s.colors.edge = Color3.fromRGB(0, 128, 0)
	s.colors.border = Color3.fromRGB(0, 128, 0)
	s.colors.ico = Color3.fromRGB(0, 255, 0)
	s.colors.scroll = Color3.fromRGB(0, 128, 0)
	s.colors.accent = Color3.fromRGB(0, 255, 0)
	s.colors.hint = Color3.fromRGB(0, 255, 0)
	s.text.font = Enum.Font.Code
	s.text.titlefont = Enum.Font.Code
	s.text.titlesize = 12
	s.shape.radius = UDim.new(0, 0)
	s.shape.borderthick = 1
	s.bg.scanlines = true
	s.bg.scanopacity = 0.15
	return s
end

dock.presets = {
	dark = newstyle(),
	retro = retro(),
	xp = xp(),
	glass = glass(),
	terminal = term(),
}

dock.style = newstyle()

local function merge(a, b)
	for k, v in pairs(b) do
		if type(v) == "table" and type(a[k]) == "table" then
			merge(a[k], v)
		else
			a[k] = v
		end
	end
	return a
end

local function clone(t)
	local o = {}
	for k, v in pairs(t) do
		if type(v) == "table" and typeof(v) ~= "Color3" then
			o[k] = clone(v)
		else
			o[k] = v
		end
	end
	return o
end

local function encode(v)
	local t = typeof(v)
	if t == "Color3" then
		return {__t = "Color3", r = v.R, g = v.G, b = v.B}
	elseif t == "UDim" then
		return {__t = "UDim", s = v.Scale, o = v.Offset}
	elseif t == "UDim2" then
		return {__t = "UDim2", xs = v.X.Scale, xo = v.X.Offset, ys = v.Y.Scale, yo = v.Y.Offset}
	elseif t == "EnumItem" then
		return {__t = "EnumItem", e = tostring(v)}
	elseif type(v) == "table" then
		local o = {}
		for k, x in pairs(v) do o[k] = encode(x) end
		return o
	end
	return v
end

local function decode(v)
	if type(v) ~= "table" then return v end
	if v.__t == "Color3" then return Color3.new(v.r, v.g, v.b) end
	if v.__t == "UDim" then return UDim.new(v.s, v.o) end
	if v.__t == "UDim2" then return UDim2.new(v.xs, v.xo, v.ys, v.yo) end
	if v.__t == "EnumItem" then
		local en, it = string.match(v.e, "Enum%.([^%.]+)%.(.+)")
		if en and it then
			local ok, item = pcall(function() return Enum[en][it] end)
			if ok then return item end
		end
		return nil
	end
	local o = {}
	for k, x in pairs(v) do o[k] = decode(x) end
	return o
end

local function getvalue(style, role, win)
	if not role then return nil end
	if role == "topcolor" then
		if win and win.focused == false then return style.colors.topoff end
		return style.colors.top
	end
	if role == "titlecolor" then
		if win and win.focused == false then return style.colors.txtoff end
		return style.colors.txt
	end
	local cur = style
	for part in string.gmatch(role, "[^%.]+") do
		if type(cur) ~= "table" then return nil end
		cur = cur[part]
	end
	return cur
end

local function ishover(i)
	return i.UserInputType == Enum.UserInputType.MouseMovement
end

local function ispress(i)
	return i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch
end

local function isrelease(i)
	return i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch
end

local function isdrag(i)
	return i.UserInputType == Enum.UserInputType.MouseMovement
		or i.UserInputType == Enum.UserInputType.Touch
end

local function onself(g)
	if not g then return false end
	local m = input:GetMouseLocation()
	local p = g.AbsolutePosition
	local s = g.AbsoluteSize
	return m.X >= p.X and m.X < p.X + s.X and m.Y >= p.Y and m.Y < p.Y + s.Y
end

local signal = {}
signal.__index = signal

function signal.new()
	local self = setmetatable({}, signal)
	self.cons = {}
	return self
end

function signal:connect(f)
	local c = {
		sig = self,
		f = f,
		disconnect = function(x)
			local p = table.find(x.sig.cons, x)
			if p then table.remove(x.sig.cons, p) end
		end
	}
	self.cons[#self.cons + 1] = c
	return c
end

function signal:fire(...)
	for _, v in next, self.cons do
		xpcall(coroutine.wrap(v.f), function(e) warn(e .. "\n" .. debug.traceback()) end, ...)
	end
end

local function build(data)
	local insts = {}
	for _, v in pairs(data) do insts[v[1]] = Instance.new(v[2]) end
	for _, v in pairs(data) do
		for prop, val in pairs(v[3]) do
			if type(val) == "table" and val[1] and insts[val[1]] then
				insts[v[1]][prop] = insts[val[1]]
			else
				insts[v[1]][prop] = val
			end
		end
	end
	return insts[1]
end

local shown = {}
local active = nil
local left = {w = 300, wins = {}, cons = {}, hidden = true}
local right = {w = 300, wins = {}, cons = {}, hidden = true}

local toporder = 10
local sideorder = 8
local slide = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local slides = {}
local sides, hint, hintind, ltoggle, rtoggle
local started = false
local redraw
local watchlist = {}

local function watch(i, p, r)
	table.insert(watchlist, {i = i, p = p, r = r})
end

local function updateglobal()
	local st = dock.style
	for _, e in ipairs(watchlist) do
		local v = getvalue(st, e.r)
		if v ~= nil and e.i then
			pcall(function() e.i[e.p] = v end)
		end
	end
	if ltoggle then
		ltoggle.BackgroundColor3 = st.colors.btn
		ltoggle.TextColor3 = st.colors.ico
		ltoggle.BorderColor3 = st.colors.edge
		ltoggle.Size = UDim2.new(0, st.docking.togglew, 0, st.docking.toggleh)
	end
	if rtoggle then
		rtoggle.BackgroundColor3 = st.colors.btn
		rtoggle.TextColor3 = st.colors.ico
		rtoggle.BorderColor3 = st.colors.edge
		rtoggle.Size = UDim2.new(0, st.docking.togglew, 0, st.docking.toggleh)
	end
	if hintind then
		hintind.BackgroundColor3 = st.colors.hint
	end
end

local function playsound(st, key)
	if not st or not st.sounds or not st.sounds.on then return end
	local id = st.sounds[key]
	if not id or id == "" or id == "rbxassetid://0" then return end
	if not sides then return end
	local s = Instance.new("Sound")
	s.SoundId = id
	s.Volume = st.sounds.vol or 0.5
	s.Parent = sides
	s.Ended:Connect(function() if s and s.Parent then s:Destroy() end end)
	s:Play()
	task.delay(6, function() if s and s.Parent then s:Destroy() end end)
end

local function bteffects(btn, cfg)
	local holding = false
	local off = false
	local mode = cfg.mode or 1
	local bevelref = cfg.bevel

	local function st()
		if cfg.getstyle then return cfg.getstyle() end
		return dock.style
	end

	local function startc()
		local s = st()
		if cfg.startrole then return getvalue(s, cfg.startrole) end
		return cfg.startcolor or btn.BackgroundColor3
	end

	local function overcolor()
		local s = st()
		if cfg.hoverrole then return getvalue(s, cfg.hoverrole) end
		return cfg.hovercolor or startc():Lerp(Color3.new(0, 0, 0), 0.2)
	end

	local function downcolor()
		local s = st()
		if cfg.pressrole then return getvalue(s, cfg.pressrole) end
		return cfg.presscolor or startc():Lerp(Color3.new(0, 0, 0), 0.35)
	end

	local function setbevel(pressed)
		if not bevelref then return end
		local s = st()
		if pressed then
			bevelref.set(s.shape.beveldark, s.shape.bevellight)
		else
			bevelref.set(s.shape.bevellight, s.shape.beveldark)
		end
	end

	btn.InputBegan:Connect(function(i)
		if off then return end
		if ishover(i) and not holding then
			if mode == 1 then
				btn.BackgroundTransparency = 0.5
			elseif mode == 2 then
				btn.BackgroundColor3 = overcolor()
			end
		elseif ispress(i) then
			holding = true
			if cfg.presssound then playsound(st(), cfg.presssound) end
			if mode == 1 then
				btn.BackgroundTransparency = 0
			elseif mode == 2 then
				btn.BackgroundColor3 = downcolor()
			end
			setbevel(true)
		end
	end)

	btn.InputEnded:Connect(function(i)
		if off then return end
		if ishover(i) and not holding then
			if mode == 1 then
				btn.BackgroundTransparency = 1
			elseif mode == 2 then
				btn.BackgroundColor3 = startc()
			end
		elseif isrelease(i) then
			if not holding then return end
			holding = false
			if mode == 1 then
				btn.BackgroundTransparency = onself(btn) and 0.5 or 1
			elseif mode == 2 then
				btn.BackgroundColor3 = onself(btn) and overcolor() or startc()
			end
			setbevel(false)
		end
	end)

	local ctrl = {}

	ctrl.disable = function()
		off = true
		holding = false
		if mode == 1 then
			btn.BackgroundTransparency = 1
		elseif mode == 2 then
			btn.BackgroundColor3 = startc()
		end
	end

	ctrl.enable = function()
		off = false
	end

	ctrl.refresh = function()
		if mode == 2 and not holding then
			btn.BackgroundColor3 = startc()
		end
		if bevelref then
			local s = st()
			bevelref.set(s.shape.bevellight, s.shape.beveldark)
		end
	end

	return ctrl
end

local function bevel(parent, initstyle)
	local b = {}
	local s = initstyle or dock.style
	local z = (parent.ZIndex or 1) + 1

	b.top = Instance.new("Frame", parent)
	b.top.Size = UDim2.new(1, 0, 0, 1)
	b.top.BorderSizePixel = 0
	b.top.ZIndex = z

	b.left = Instance.new("Frame", parent)
	b.left.Size = UDim2.new(0, 1, 1, 0)
	b.left.BorderSizePixel = 0
	b.left.ZIndex = z

	b.right = Instance.new("Frame", parent)
	b.right.Size = UDim2.new(0, 1, 1, 0)
	b.right.Position = UDim2.new(1, -1, 0, 0)
	b.right.BorderSizePixel = 0
	b.right.ZIndex = z

	b.bottom = Instance.new("Frame", parent)
	b.bottom.Size = UDim2.new(1, 0, 0, 1)
	b.bottom.Position = UDim2.new(0, 0, 1, -1)
	b.bottom.BorderSizePixel = 0
	b.bottom.ZIndex = z

	function b.set(light, dark)
		b.top.BackgroundColor3 = light
		b.left.BackgroundColor3 = light
		b.right.BackgroundColor3 = dark
		b.bottom.BackgroundColor3 = dark
	end

	b.set(s.shape.bevellight, s.shape.beveldark)
	return b
end

function dock:cleanup()
	for _, d in ipairs(self.all) do
		if d.gui then d.gui:Destroy() end
	end
	if sides then sides:Destroy() end
	if hint then hint:Destroy() end
	for _, t in ipairs(slides) do t:Cancel() end
	table.clear(slides)
	table.clear(self.all)
	table.clear(shown)
	table.clear(left.wins)
	table.clear(right.wins)
	table.clear(watchlist)
	sides, hint, hintind, ltoggle, rtoggle = nil, nil, nil, nil, nil
	active = nil
	started = false
	left.hidden = true
	right.hidden = true
end

function dock.setstyle(s)
	if type(s) == "string" then
		local p = dock.presets[s]
		if not p then return end
		dock.style = clone(p)
	elseif type(s) == "table" then
		dock.style = s
	end
	dock.refreshall()
end

function dock.refreshall()
	updateglobal()
	for _, d in ipairs(dock.all) do
		d:restyle()
	end
	redraw(true)
end

function dock.settheme(c)
	if not c or typeof(c) ~= "Color3" then return end
	local h, s, v = c:ToHSV()
	local st = dock.style
	st.colors.back = c
	st.colors.top = Color3.fromHSV(h, s, math.min(1, v + 0.03))
	st.colors.topoff = Color3.fromHSV(h, s, math.max(0, v - 0.02))
	st.colors.edge = Color3.fromHSV(h, s, math.max(0, v - 0.05))
	st.colors.border = st.colors.edge
	st.colors.btn = Color3.fromHSV(h, s, math.min(1, v + 0.06))
	st.colors.btnover = Color3.fromHSV(h, s, math.min(1, v + 0.09))
	st.colors.btndown = Color3.fromHSV(h, s, math.max(0, v - 0.02))
	st.colors.grip = Color3.fromHSV(h, s, math.min(1, v + 0.08))
	st.colors.accent = c
	st.colors.hint = c
	dock.refreshall()
end

function dock.save()
	return http:JSONEncode(encode(dock.style))
end

function dock.load(json)
	local ok, data = pcall(function() return http:JSONDecode(json) end)
	if not ok or type(data) ~= "table" then return false end
	local st = decode(data)
	if type(st) ~= "table" then return false end
	dock.style = merge(newstyle(), st)
	dock.refreshall()
	return true
end

local function stopanim()
	for i = 1, #slides do slides[i]:Cancel() end
	slides = {}
end

local function front(win)
	local f = table.find(shown, win)
	if f then
		table.remove(shown, f)
		table.insert(shown, 1, win)
	end
	if active ~= win then
		if active and not active.closed then active:setactive(false) end
		active = win
		win:setactive(true)
	end
	redraw()
end

local function hasroom(side, need)
	local maxy = sides.AbsoluteSize.Y - (math.max(0, #side.wins - 1) * 4)
	local inc = 0
	for i, v in pairs(side.wins) do
		inc = inc + (v.miny or 100)
		if inc > maxy - need then return false end
	end
	return true
end

local function insertspot(side, y)
	local pos = #side.wins + 1
	local range = {0, sides.AbsoluteSize.Y}
	for i, v in ipairs(side.wins) do
		local mid = v.py + (v.sy / 2)
		if y <= mid then
			pos = i
			range[2] = mid
			break
		else
			range[1] = mid
		end
	end
	return pos, range
end

local function addfocus(self, o)
	if isa(o, "GuiButton") then
		o.MouseButton1Down:Connect(function() front(self) end)
	elseif isa(o, "TextBox") then
		o.Focused:Connect(function() front(self) end)
	end
end

local function dragresize(self, grip, dir)
	local main = self.parts.main
	grip.InputBegan:Connect(function(i)
		if not self.dragging and not self.resizing and self.canresize and self.innerresize then
			local isv = dir:find("[NS]") and true
			local sx = 0
			if dir:find("W") then sx = -1 elseif dir:find("E") then sx = 1 end
			local sy = 0
			if dir:find("N") then sy = -1 elseif dir:find("S") then sy = 1 end
			if self.mini and isv then return end
			if ishover(i) then
				grip.BackgroundTransparency = 0.5
			elseif ispress(i) then
				front(self)
				local rel, mov
				self.resizing = grip
				grip.BackgroundTransparency = 1
				local ix = i.Position.X
				local iy = i.Position.Y
				local osx = self.sx
				local osy = self.sy
				local opx = main.Position.X.Offset
				local opy = main.Position.Y.Offset
				rel = input.InputEnded:Connect(function(x)
					if isrelease(x) then
						rel:Disconnect()
						mov:Disconnect()
						self.resizing = false
						grip.BackgroundTransparency = 1
					end
				end)
				mov = input.InputChanged:Connect(function(x)
					if self.canresize and self.innerresize and isdrag(x) then
						self:stopanim()
						local dx = x.Position.X - ix
						local dy = x.Position.Y - iy
						local nsx = osx + (dx * sx)
						local nsy = osy + (dy * sy)
						local npx = opx + (sx == -1 and dx or 0)
						local npy = opy + (sy == -1 and dy or 0)
						if nsx < self.minx then
							npx = npx - (self.minx - nsx) * (sx == -1 and 1 or 0)
							nsx = self.minx
						end
						if nsy < self.miny then
							npy = npy - (self.miny - nsy) * (sy == -1 and 1 or 0)
							nsy = self.miny
						end
						self.sx = nsx
						self.sy = nsy
						main.Position = UDim2.new(0, npx, 0, npy)
						main.Size = UDim2.new(0, nsx, 0, self.mini and 20 or nsy)
					end
				end)
			end
		end
	end)
	grip.InputEnded:Connect(function(i)
		if ishover(i) and self.resizing ~= grip then
			grip.BackgroundTransparency = 1
		end
	end)
end

local function movesides(noanim)
	stopanim()
	left.frame.Size = UDim2.new(0, left.w, 1, 0)
	right.frame.Size = UDim2.new(0, right.w, 1, 0)
	left.frame.Resizer.Position = UDim2.new(0, left.w, 0, 0)
	right.frame.Resizer.Position = UDim2.new(0, -5, 0, 0)
	local lh = #left.wins == 0 or left.hidden
	local rh = #right.wins == 0 or right.hidden
	local lp = (lh and UDim2.new(0, -left.w - 10, 0, 0) or UDim2.new(0, 0, 0, 0))
	local rp = (rh and UDim2.new(1, 10, 0, 0) or UDim2.new(1, -right.w, 0, 0))
	ltoggle.Text = lh and ">" or "<"
	rtoggle.Text = rh and "<" or ">"
	if not noanim then
		local function ins(...)
			local t = tween:Create(...)
			slides[#slides + 1] = t
			t:Play()
		end
		ins(left.frame, slide, {Position = lp})
		ins(right.frame, slide, {Position = rp})
		ins(ltoggle, slide, {Position = UDim2.new(0, #left.wins == 0 and -16 or 0, 0, -36)})
		ins(rtoggle, slide, {Position = UDim2.new(1, #right.wins == 0 and 0 or -16, 0, -36)})
	else
		left.frame.Position = lp
		right.frame.Position = rp
		ltoggle.Position = UDim2.new(0, #left.wins == 0 and -16 or 0, 0, -36)
		rtoggle.Position = UDim2.new(1, #right.wins == 0 and 0 or -16, 0, -36)
	end
end

local function sidepos(side)
	local lh = #left.wins == 0 or left.hidden
	local rh = #right.wins == 0 or right.hidden
	if side == left then
		return (lh and UDim2.new(0, -left.w - 10, 0, 0) or UDim2.new(0, 0, 0, 0))
	end
	return (rh and UDim2.new(1, 10, 0, 0) or UDim2.new(1, -right.w, 0, 0))
end

local function sizewindows(side)
	local pos = 0
	local sp = sidepos(side)
	for i, v in pairs(side.wins) do
		v.sx = side.w
		v.parts.main.Size = UDim2.new(0, side.w, 0, v.sy)
		v.parts.main.Position = UDim2.new(sp.X.Scale, sp.X.Offset, 0, pos)
		pos = pos + v.sy + 4
	end
end

local function draggrip(grip, dir, side, p)
	local wins = side.wins
	grip.InputBegan:Connect(function(i)
		if not side.resizing then
			if ishover(i) then
				grip.BackgroundColor3 = dock.style.colors.btnover
			elseif ispress(i) then
				local rel, mov
				side.resizing = grip
				grip.BackgroundColor3 = dock.style.colors.btndown
				local start = dir == "V" and i.Position.Y or i.Position.X
				local osizes = {}
				for k, w in pairs(wins) do osizes[k] = w.sy end
				local owidth = side.w
				rel = input.InputEnded:Connect(function(x)
					if isrelease(x) then
						rel:Disconnect()
						mov:Disconnect()
						side.resizing = false
						grip.BackgroundColor3 = dock.style.colors.grip
					end
				end)
				mov = input.InputChanged:Connect(function(x)
					if not grip.Parent then
						rel:Disconnect()
						mov:Disconnect()
						side.resizing = false
						return
					end
					if isdrag(x) then
						local cur = dir == "V" and x.Position.Y or x.Position.X
						if dir == "V" then
							local d = cur - start
							if d > 0 then
								local need = d
								for k = p + 1, #wins do
									local w = wins[k]
									local os = osizes[k]
									local ns = math.max(os - need, (w.miny or 100))
									need = need - (os - ns)
									w.sy = ns
								end
								wins[p].sy = osizes[p] + math.max(0, d - need)
							else
								local need = -d
								for k = p, 1, -1 do
									local w = wins[k]
									local os = osizes[k]
									local ns = math.max(os - need, (w.miny or 100))
									need = need - (os - ns)
									w.sy = ns
								end
								wins[p + 1].sy = osizes[p + 1] + math.max(0, -d - need)
							end
							movesides()
							sizewindows(side)
						elseif dir == "H" then
							local maxw = math.max(300, sides.AbsoluteSize.X - dock.style.docking.freew)
							local other = (side == left and right or left)
							local d = cur - start
							d = (side == left and d or -d)
							local want = math.max(dock.style.docking.minw, owidth + d)
							if want + other.w <= maxw then
								side.w = want
							else
								local no = maxw - want
								if no >= dock.style.docking.minw then
									side.w = want
									other.w = no
								else
									side.w = maxw - dock.style.docking.minw
									other.w = dock.style.docking.minw
								end
							end
							movesides(true)
							sizewindows(side)
							sizewindows(other)
						end
					end
				end)
			end
		end
	end)
	grip.InputEnded:Connect(function(i)
		if ishover(i) and side.resizing ~= grip then
			grip.BackgroundColor3 = dock.style.colors.grip
		end
	end)
end

local function drawside(side, noanim)
	local pos = 0
	local sp = sidepos(side)
	local tmpl = side.winresizer:Clone()
	for i, v in pairs(side.cons) do v:Disconnect() end
	for i, v in pairs(side.frame:GetChildren()) do if v.Name == "WindowResizer" then v:Destroy() end end
	side.cons = {}
	side.resizing = nil
	for i, v in pairs(side.wins) do
		v.sideidx = i
		local last = i == #side.wins
		local size = UDim2.new(0, side.w, 0, v.sy)
		local p = UDim2.new(sp.X.Scale, sp.X.Offset, 0, pos)
		v.gui.Parent = holder
		if noanim then
			v.parts.main.Size = size
			v.parts.main.Position = p
		else
			local t = tween:Create(v.parts.main, slide, {Size = size, Position = p})
			slides[#slides + 1] = t
			t:Play()
		end
		pos = pos + v.sy + 4
		if not last then
			local nt = tmpl:Clone()
			nt.Position = UDim2.new(0, 0, 0, pos - 4)
			nt.Size = UDim2.new(1, 0, 0, 4)
			side.cons[#side.cons + 1] = v.parts.main:GetPropertyChangedSignal("Size"):Connect(function()
				nt.Position = UDim2.new(0, 0, 0, v.parts.main.Position.Y.Offset + v.parts.main.Size.Y.Offset)
			end)
			side.cons[#side.cons + 1] = v.parts.main:GetPropertyChangedSignal("Position"):Connect(function()
				nt.Position = UDim2.new(0, 0, 0, v.parts.main.Position.Y.Offset + v.parts.main.Size.Y.Offset)
			end)
			draggrip(nt, "V", side, i)
			nt.Parent = side.frame
		end
	end
end

local function fit(side, noanim)
	local wins = side.wins
	if #wins == 0 then return end
	local h = sides.AbsoluteSize.Y - (#wins - 1) * 4
	if h < #wins * 100 then h = #wins * 100 end
	local oh = 0
	for _, v in pairs(wins) do oh = oh + math.max(v.sy, v.miny or 100) end
	local pos = 0
	for i, v in ipairs(wins) do
		local mn = v.miny or 100
		local target
		if i == #wins then
			target = h - pos
		else
			target = math.floor((math.max(v.sy, mn) / oh) * h)
		end
		v.sy = math.max(target, mn)
		pos = pos + v.sy
	end
	drawside(side, noanim)
end

redraw = function(noanim)
	movesides(noanim)
	fit(left, noanim)
	fit(right, noanim)
	local count = 0
	for i = #shown, 1, -1 do
		shown[i].gui.DisplayOrder = toporder + count
		shown[i].gui.Parent = holder
		count = count + 1
	end
	if active and active.closed then active = nil end
	if not active and #shown > 0 then
		local c = shown[1]
		if not c.closed then
			active = c
			c:setactive(true)
		end
	end
end

local methods = {}
local meta = {__index = methods}

local function painttop(top, st, ison)
	local grad = top:FindFirstChild("UIGradient")
	if ison and st.colors.topgrad then
		if not grad then
			grad = Instance.new("UIGradient")
			grad.Name = "UIGradient"
			grad.Rotation = 90
			grad.Parent = top
		end
		local colors = st.colors.topgrad
		local kps = {}
		for i, c in ipairs(colors) do
			local t = (i - 1) / math.max(1, #colors - 1)
			table.insert(kps, ColorSequenceKeypoint.new(t, c))
		end
		grad.Color = ColorSequence.new(kps)
		grad.Enabled = true
		top.BackgroundColor3 = st.colors.top
	else
		if grad then grad.Enabled = false end
		top.BackgroundColor3 = ison and st.colors.top or st.colors.topoff
	end
end

local function scanlines(body, st)
	local e = body:FindFirstChild("Scanlines")
	if not st.bg.scanlines then
		if e then e:Destroy() end
		return
	end
	if not e then
		e = Instance.new("Frame")
		e.Name = "Scanlines"
		e.Size = UDim2.new(1, 0, 1, 0)
		e.BackgroundColor3 = Color3.new(0, 0, 0)
		e.BorderSizePixel = 0
		e.ZIndex = (body.ZIndex or 1) + 50
		e.Parent = body
		local g = Instance.new("UIGradient")
		g.Name = "UIGradient"
		g.Rotation = 90
		g.Parent = e
	end
	local g = e:FindFirstChild("UIGradient")
	if not g then return end
	local stops = 40
	local kps = {}
	for i = 0, stops do
		local t = i / stops
		local a = (i % 2 == 0) and (1 - st.bg.scanopacity) or 0
		table.insert(kps, NumberSequenceKeypoint.new(t, a))
	end
	g.Transparency = NumberSequence.new(kps)
end

local function makegui(self)
	local st = self:getstyle()
	local s = st.shape

	local g = Instance.new("ScreenGui")
	g.Name = "Window"
	g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	self.parts.gui = g

	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Active = true
	main.BackgroundTransparency = 1
	main.BorderSizePixel = 0
	main.Position = UDim2.new(0, 250, 0, 150)
	main.Size = UDim2.new(0, self.sx, 0, self.sy)
	main.ClipsDescendants = false
	main.Parent = g
	self.parts.main = main

	local body = Instance.new("Frame")
	body.Name = "Content"
	body.BackgroundColor3 = st.colors.back
	body.BorderSizePixel = 0
	body.Position = UDim2.new(0, 0, 0, s.topheight)
	body.Size = UDim2.new(1, 0, 1, -s.topheight)
	body.ClipsDescendants = true
	body.Parent = main
	self.parts.body = body
	self.body = body

	local corner = Instance.new("UICorner")
	corner.CornerRadius = s.radius
	corner.Parent = body
	self.parts.corner = corner
	table.insert(self.styles, {i = corner, p = "CornerRadius", r = "shape.radius"})

	local line = Instance.new("Frame")
	line.Name = "Line"
	line.BackgroundColor3 = st.colors.edge
	line.BorderSizePixel = 0
	line.Size = UDim2.new(1, 0, 0, 1)
	line.Parent = body
	self.parts.line = line
	table.insert(self.styles, {i = line, p = "BackgroundColor3", r = "colors.edge"})

	local top = Instance.new("Frame")
	top.Name = "TopBar"
	top.BackgroundColor3 = st.colors.top
	top.BorderSizePixel = 0
	top.Size = UDim2.new(1, 0, 0, s.topheight)
	top.Parent = main
	self.parts.top = top

	local topcorner = Instance.new("UICorner")
	topcorner.CornerRadius = s.radius
	topcorner.Parent = top
	self.parts.topcorner = topcorner
	table.insert(self.styles, {i = topcorner, p = "CornerRadius", r = "shape.radius"})

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Font = st.text.titlefont
	title.Position = UDim2.new(0, 5, 0, 0)
	title.Size = UDim2.new(1, -10, 0, s.topheight)
	title.Text = "Window"
	title.TextColor3 = st.colors.txt
	title.TextSize = st.text.titlesize
	title.TextXAlignment = st.text.titlealign
	title.Parent = top
	self.parts.title = title

	local edge = Instance.new("ImageLabel")
	edge.Name = "Outlines"
	edge.BackgroundTransparency = 1
	edge.BorderSizePixel = 0
	edge.Image = st.chrome.edgeimg
	edge.Position = UDim2.new(0, -5, 0, -5)
	edge.ScaleType = Enum.ScaleType.Slice
	edge.Size = UDim2.new(1, 10, 1, 10)
	edge.SliceCenter = Rect.new(6, 6, 25, 25)
	edge.TileSize = UDim2.new(0, 20, 0, 20)
	edge.Parent = main
	self.parts.edge = edge

	local rc = Instance.new("Frame")
	rc.Name = "ResizeControls"
	rc.BackgroundTransparency = 1
	rc.Position = UDim2.new(0, -5, 0, -5)
	rc.Size = UDim2.new(1, 10, 1, 10)
	rc.Parent = main
	self.parts.rc = rc

	local th = s.gripthick
	local dirs = {
		{name = "North", pos = UDim2.new(0, 5, 0, 0), size = UDim2.new(1, -10, 0, th)},
		{name = "South", pos = UDim2.new(0, 5, 1, -th), size = UDim2.new(1, -10, 0, th)},
		{name = "East", pos = UDim2.new(1, -th, 0, th), size = UDim2.new(0, th, 1, -2 * th)},
		{name = "West", pos = UDim2.new(0, 0, 0, th), size = UDim2.new(0, th, 1, -2 * th)},
		{name = "NorthEast", pos = UDim2.new(1, -th, 0, 0), size = UDim2.new(0, th, 0, th)},
		{name = "NorthWest", pos = UDim2.new(0, 0, 0, 0), size = UDim2.new(0, th, 0, th)},
		{name = "SouthEast", pos = UDim2.new(1, -th, 1, -th), size = UDim2.new(0, th, 0, th)},
		{name = "SouthWest", pos = UDim2.new(0, 0, 1, -th), size = UDim2.new(0, th, 0, th)},
	}
	for _, d in ipairs(dirs) do
		local b = Instance.new("TextButton")
		b.Name = d.name
		b.AutoButtonColor = false
		b.BackgroundColor3 = st.colors.grip
		b.BackgroundTransparency = 1
		b.BorderSizePixel = 0
		b.Font = Enum.Font.Gotham
		b.Position = d.pos
		b.Size = d.size
		b.Text = ""
		b.TextSize = 14
		b.Parent = rc
		table.insert(self.styles, {i = b, p = "BackgroundColor3", r = "colors.grip"})
	end

	local bsize = s.btnsize
	local by = math.floor((s.topheight - bsize) / 2)

	local function makebutton(name)
		local b = Instance.new("TextButton")
		b.Name = name
		b.AutoButtonColor = false
		b.BackgroundColor3 = st.colors.btn
		b.BackgroundTransparency = 1
		b.BorderSizePixel = 0
		b.Font = Enum.Font.GothamBold
		b.Size = UDim2.new(0, bsize, 0, bsize)
		b.Text = ""
		b.TextColor3 = st.colors.ico
		b.TextSize = math.floor(bsize * 0.7)
		b.Parent = top

		local bc = Instance.new("UICorner")
		bc.CornerRadius = s.btnradius
		bc.Parent = b
		table.insert(self.styles, {i = bc, p = "CornerRadius", r = "shape.btnradius"})

		local img = Instance.new("ImageLabel")
		img.Name = "Icon"
		img.BackgroundTransparency = 1
		img.Position = UDim2.new(0, math.floor(bsize * 0.2), 0, math.floor(bsize * 0.2))
		img.Size = UDim2.new(0, math.floor(bsize * 0.6), 0, math.floor(bsize * 0.6))
		img.Parent = b
		self.parts[name .. "Icon"] = img
		return b
	end

	self.parts.close = makebutton("Close")
	self.parts.minimize = makebutton("Minimize")
	self.parts.maximize = makebutton("Maximize")

	if s.bevel then
		self.parts.topbevel = bevel(top, st)
	end

	return g
end

function methods:reg(i, p, r)
	table.insert(self.styles, {i = i, p = p, r = r})
end

function methods:getstyle()
	if self.mystyle then
		local base = clone(dock.style)
		if type(self.mystyle) == "string" then
			local p = dock.presets[self.mystyle]
			if p then merge(base, clone(p)) end
		elseif self.mystyle.__preset then
			local p = dock.presets[self.mystyle.__preset]
			if p then merge(base, clone(p)) end
		else
			merge(base, self.mystyle)
		end
		return base
	end
	return dock.style
end

function methods:setstyle(s)
	if type(s) == "string" then
		if dock.presets[s] then
			self.mystyle = {__preset = s}
		else
			self.mystyle = nil
		end
	elseif type(s) == "table" then
		self.mystyle = s
	else
		self.mystyle = nil
	end
	self:restyle()
end

function methods:restyle()
	local st = self:getstyle()
	local s = st.shape

	for _, e in ipairs(self.styles) do
		local v = getvalue(st, e.r, self)
		if v ~= nil and e.i and e.i.Parent then
			pcall(function() e.i[e.p] = v end)
		end
	end

	self.parts.body.BackgroundTransparency = 1 - (st.bg.opacity or 1)
	self.parts.top.Size = UDim2.new(1, 0, 0, s.topheight)
	self.parts.body.Position = UDim2.new(0, 0, 0, s.topheight)
	self.parts.body.Size = UDim2.new(1, 0, 1, -s.topheight)
	self.parts.line.Size = UDim2.new(1, 0, 0, s.borderthick)
	self.parts.line.BackgroundTransparency = 1
	if self.parts.corner then
		self.parts.corner.CornerRadius = s.radius
	end
	if self.parts.topcorner then
		self.parts.topcorner.CornerRadius = s.radius
	end

	self.parts.edge.Image = st.chrome.edgeimg
	self.parts.edge.Visible = st.chrome.showedge
	self.parts.edge.ImageTransparency = st.chrome.showshadow and 0 or 1

	self.parts.title.TextSize = st.text.titlesize
	self.parts.title.Font = st.text.titlefont
	self.parts.title.TextXAlignment = st.text.titlealign
	self.parts.title.TextStrokeTransparency = st.text.titlestroke and 0.5 or 1
	self.parts.title.TextStrokeColor3 = st.text.titlestrokecolor

	painttop(self.parts.top, st, self.focused ~= false)

	self:placebuttons()
	self:bevelwindow()
	self:fixscrolls()
	scanlines(self.parts.body, st)
end

function methods:placebuttons()
	local st = self:getstyle()
	local s = st.shape
	local bsize = s.btnsize
	local gap = 2
	local y = math.floor((s.topheight - bsize) / 2)
	local side = st.titlebar.btnside

	local vis = {}
	if st.titlebar.showclose then table.insert(vis, "Close") end
	if st.titlebar.showmini then table.insert(vis, "Minimize") end
	if st.titlebar.showmax then table.insert(vis, "Maximize") end

	local order = {}
	for _, name in ipairs(st.titlebar.btnorder) do
		local map = {mini = "Minimize", max = "Maximize", close = "Close"}
		local real = map[name] or name
		for _, c in ipairs(vis) do
			if c == real then table.insert(order, c) break end
		end
	end
	for _, c in ipairs(vis) do
		if not table.find(order, c) then table.insert(order, c) end
	end

	for _, name in ipairs({"Close", "Minimize", "Maximize"}) do
		local b = self.parts[name:lower()]
		if b then b.Visible = false end
	end

	local glyphs = {
		Close = st.titlebar.closeglyph,
		Minimize = st.titlebar.miniglyph,
		Maximize = self.maxi and st.titlebar.restoreglyph or st.titlebar.maxglyph,
	}
	local iconset = {
		Close = st.icons.closeicon,
		Minimize = self.mini and st.icons.minirestore or st.icons.miniicon,
		Maximize = self.maxi and st.icons.restoreicon or st.icons.maxicon,
	}

	for i, name in ipairs(order) do
		local b = self.parts[name:lower()]
		if b then
			b.Visible = true
			b.Size = UDim2.new(0, bsize, 0, bsize)
			b.TextSize = math.floor(bsize * 0.7)
			b.TextColor3 = st.colors.ico
			b.BackgroundColor3 = st.colors.btn
			local xo = 2 + (bsize + gap) * (i - 1)
			if side == "right" then
				b.Position = UDim2.new(1, -(xo + bsize), 0, y)
			else
				b.Position = UDim2.new(0, xo, 0, y)
			end
			local ico = b:FindFirstChild("Icon")
			if st.titlebar.textglyph then
				b.Text = glyphs[name] or ""
				if ico then ico.Visible = false end
			else
				b.Text = ""
				if ico then
					ico.Visible = true
					ico.Image = iconset[name] or ""
					ico.Position = UDim2.new(0, math.floor(bsize * 0.2), 0, math.floor(bsize * 0.2))
					ico.Size = UDim2.new(0, math.floor(bsize * 0.6), 0, math.floor(bsize * 0.6))
					ico.ImageColor3 = st.colors.ico
				end
			end
			local bc = b:FindFirstChildOfClass("UICorner")
			if bc then bc.CornerRadius = s.btnradius end
		end
	end
end

function methods:bevelwindow()
	local st = self:getstyle()
	local s = st.shape
	if not self.parts.topbevel and s.bevel then
		self.parts.topbevel = bevel(self.parts.top, st)
	end
	if self.parts.topbevel then
		if s.bevel then
			self.parts.topbevel.set(s.bevellight, s.beveldark)
			for _, f in ipairs({self.parts.topbevel.top, self.parts.topbevel.left, self.parts.topbevel.right, self.parts.topbevel.bottom}) do
				f.Visible = true
			end
		else
			for _, f in ipairs({self.parts.topbevel.top, self.parts.topbevel.left, self.parts.topbevel.right, self.parts.topbevel.bottom}) do
				f.Visible = false
			end
		end
	end
end

function methods:fixscrolls()
	local st = self:getstyle()
	for _, d in ipairs(self.body:GetDescendants()) do
		if d:IsA("ScrollingFrame") then
			d.ScrollBarImageColor3 = st.colors.scroll
		end
	end
end

function methods:setactive(state)
	if self.focused == state then return end
	self.focused = state
	if self.parts.top then
		local st = self:getstyle()
		painttop(self.parts.top, st, state)
		if self.parts.title then
			self.parts.title.TextColor3 = getvalue(st, "titlecolor", self)
		end
	end
end

function methods:setmini(s, mode)
	local old = self.mini
	local new
	if s == nil then new = not self.mini else new = s end
	self.mini = new
	if not mode then mode = 1 end
	local rc = self.parts.rc
	local hideparts = {"North", "NorthEast", "NorthWest", "South", "SouthEast", "SouthWest"}
	for i = 1, #hideparts do
		local c = rc:FindFirstChild(hideparts[i])
		if c then c.Visible = not new end
	end
	local st = self:getstyle()
	if mode == 1 or mode == 2 then
		self:stopanim()
		if st.anim.minstyle == "instant" then
			self.parts.main.Size = UDim2.new(0, self.sx, 0, new and 20 or self.sy)
			if mode == 2 then
				local maxy = sides.AbsoluteSize.Y
				local py = new and math.min(maxy - 20, self.py + self.sy - 20) or math.max(0, self.py - self.sy + 20)
				self.parts.main.Position = UDim2.new(0, self.px, 0, py)
			end
		elseif mode == 1 then
			self.parts.main:TweenSize(UDim2.new(0, self.sx, 0, new and 20 or self.sy), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, st.anim.duration or 0.25, true)
		else
			local maxy = sides.AbsoluteSize.Y
			local np = UDim2.new(0, self.px, 0, new and math.min(maxy - 20, self.py + self.sy - 20) or math.max(0, self.py - self.sy + 20))
			self.parts.main:TweenPosition(np, Enum.EasingDirection.Out, Enum.EasingStyle.Quart, st.anim.duration or 0.25, true)
			self.parts.main:TweenSize(UDim2.new(0, self.sx, 0, new and 20 or self.sy), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, st.anim.duration or 0.25, true)
		end
	end
	if st.titlebar.textglyph then
		self.parts.minimize.Text = new and st.titlebar.maxglyph or st.titlebar.miniglyph
	else
		local ico = self.parts.minimize:FindFirstChild("Icon")
		if ico then
			ico.Image = new and st.icons.minirestore or st.icons.miniicon
		end
	end
	if old ~= new then
		playsound(st, "mini")
		if new then
			self.minimized:fire()
		else
			self.restored:fire()
		end
	end
end

function methods:setmax(state)
	if state == nil then state = not self.maxi end
	if self.maxi == state then return end
	self.maxi = state
	if state then
		self.premaxx = self.sx
		self.premaxy = self.sy
		self.premaxpx = self.px
		self.premaxpy = self.py
		self.premaxdock = self.docked
		if self.docked then self:setaligned(false) end
		self.parts.main.Position = UDim2.new(0, 0, 0, 0)
		self.parts.main.Size = UDim2.new(1, 0, 1, 0)
	else
		self.parts.main.Position = UDim2.new(0, self.premaxpx or 250, 0, self.premaxpy or 150)
		self.parts.main.Size = UDim2.new(0, self.premaxx or 300, 0, self.premaxy or 300)
		self.sx = self.premaxx or 300
		self.sy = self.premaxy or 300
	end
	self:placebuttons()
end

function methods:resize(x, y)
	self.sx = x or self.sx
	self.sy = y or self.sy
	self.parts.main.Size = UDim2.new(0, self.sx, 0, self.sy)
end

function methods:title(t)
	self.parts.title.Text = t
end

function methods:opacity(o)
	self.opa = o
	local bt = 1 - o
	self.parts.body.BackgroundTransparency = bt
	self.parts.top.BackgroundTransparency = math.clamp(bt - 0.1, 0, 1)
	self.parts.line.BackgroundTransparency = bt
	self.parts.title.TextStrokeTransparency = bt < 1 and 0.5 or 1
	self.parts.title.TextStrokeColor3 = Color3.new(0, 0, 0)
end

function methods:background(data, fps, trans)
	if self.bgframe then self.bgframe:Destroy() end
	if self.gifcon then self.gifcon:Disconnect() end
	local bf = Instance.new("Frame")
	bf.Name = "BackgroundImages"
	bf.Size = UDim2.new(1, 0, 1, 0)
	bf.BackgroundTransparency = 1
	bf.Parent = self.body
	self.bgframe = bf
	local frames = type(data) == "table" and data or {data}
	local imgs = {}
	local function fetch(url, idx)
		if not url:find("http") then return url end
		local fn = url:match("([^/]+)$") or tostring(idx)
		fn = fn:gsub("[^%w%._%-]", "")
		if fn == "" then fn = tostring(idx) .. ".png" end
		local path = "ssp_assets/" .. fn
		if isfolder and not isfolder("ssp_assets") then makefolder("ssp_assets") end
		if isfile and not isfile(path) then writefile(path, game:HttpGet(url)) end
		if getcustomasset and isfile(path) then return getcustomasset(path) end
		return url
	end
	for i, url in ipairs(frames) do
		local a = fetch(url, i)
		local im = Instance.new("ImageLabel")
		im.BackgroundTransparency = 1
		im.Size = UDim2.new(1, 0, 1, 0)
		im.Position = UDim2.new(0, 0, 0, 0)
		im.Image = a
		im.ScaleType = Enum.ScaleType.Crop
		im.ImageTransparency = trans or 0
		im.Visible = (i == 1)
		im.Parent = bf
		table.insert(imgs, im)
	end
	if #imgs > 1 then
		local cur = 1
		local rate = 1 / (fps or 30)
		self.giflast = tick()
		self.gifcon = run.Heartbeat:Connect(function()
			local now = tick()
			if now - self.giflast >= rate then
				self.giflast = now
				imgs[cur].Visible = false
				cur = cur + 1
				if cur > #imgs then cur = 1 end
				imgs[cur].Visible = true
			end
		end)
	end
end

function methods:resizable(v)
	self.canresize = v
	self.parts.rc.Visible = self.canresize and self.innerresize
end

function methods:setinnerresize(v)
	self.innerresize = v
	self.parts.rc.Visible = self.canresize and self.innerresize
end

function methods:setaligned(v)
	self.docked = v
	self:setinnerresize(not v)
	self.parts.main.Active = not v
	self.parts.edge.Visible = not v and self:getstyle().chrome.showedge
	if not v then
		for i, w in pairs(left.wins) do if w == self then table.remove(left.wins, i) break end end
		for i, w in pairs(right.wins) do if w == self then table.remove(right.wins, i) break end end
		if self.freex and self.freey then
			self.sx = self.freex
			self.sy = self.freey
			self.parts.main.Size = UDim2.new(0, self.sx, 0, self.sy)
		end
		if not table.find(shown, self) then table.insert(shown, 1, self) end
		if self.parts.minimizeIcon then
			self.parts.minimizeIcon.Image = self:getstyle().icons.miniicon
		end
		self.side = nil
		redraw()
	else
		if not self.freex then
			self.freex = self.sx
			self.freey = self.sy
		end
		self:setmini(false, 3)
		for i, w in pairs(shown) do if w == self then table.remove(shown, i) break end end
	end
end

function methods:add(o, name)
	if type(o) == "table" and o.gui and o.gui:IsA("GuiObject") then
		o.gui.Parent = self.body
	else
		o.Parent = self.body
	end
	if name then self.items[name] = o end
	self:fixscrolls()
end

function methods:get(name)
	return self.items[name]
end

function methods:sidalign(side, pos, size, silent)
	if table.find(side.wins, self) or self.closed then return end
	if not self.docked then
		self.freex = self.sx
		self.freey = self.sy
	end
	self:setaligned(true)
	self.side = side
	self.sx = side.w
	self.gui.DisplayOrder = sideorder + 1
	for i, v in pairs(side.wins) do v.gui.DisplayOrder = sideorder end
	pos = math.min(#side.wins + 1, pos or 1)
	self.sideidx = pos
	table.insert(side.wins, pos, self)
	local total = #side.wins
	local avail = sides.AbsoluteSize.Y - ((total - 1) * 4)
	local eq = math.floor(math.max(100, avail / total))
	for _, v in ipairs(side.wins) do v.sy = eq end
	if not silent then side.hidden = false end
	redraw(silent)
end

function methods:close()
	if self.closed then return end
	self.closed = true
	self:setinnerresize(false)
	local wasact = (active == self)
	if wasact then active = nil end
	local p
	p = table.find(left.wins, self)
	if p then table.remove(left.wins, p) end
	p = table.find(right.wins, self)
	if p then table.remove(right.wins, p) end
	p = table.find(shown, self)
	if p then table.remove(shown, p) end
	self.closeside = self.side
	self.side = nil
	self.deactivated:fire()
	playsound(self:getstyle(), "close")
	if not self.docked then
		self:stopanim()
		local ct = tick()
		self.lastclose = ct
		self:animate(self.parts.main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, self.sx, 0, 20)})
		task.spawn(function()
			task.wait(0.2)
			if ct == self.lastclose then
				local ti = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				self:animate(self.parts.title, ti, {TextTransparency = 1})
				self:animate(self.parts.top, ti, {BackgroundTransparency = 1})
				if self.parts.edge then
					self:animate(self.parts.edge, ti, {ImageTransparency = 1})
				end
				for _, name in ipairs({"close", "minimize", "maximize"}) do
					local b = self.parts[name]
					if b then self:animate(b, ti, {BackgroundTransparency = 1, TextTransparency = 1}) end
				end
				task.wait(0.15)
				if ct == self.lastclose then
					self.gui.Parent = nil
					if wasact and #shown > 0 then
						local c = shown[1]
						if not c.closed then
							active = c
							c:setactive(true)
						end
					end
					redraw(true)
				end
			end
		end)
	else
		self.gui.Parent = nil
		if wasact and #shown > 0 then
			local c = shown[1]
			if not c.closed then
				active = c
				c:setactive(true)
			end
		end
		redraw(true)
	end
end

function methods:isvisible()
	return not self.closed and ((self.side and not self.side.hidden) or not self.side)
end

function methods:contentvisible()
	return self:isvisible() and not self.mini
end

function methods:focus()
	front(self)
end

function methods:keepin()
	local x, y = self.px, self.py
	local mx, my = sides.AbsoluteSize.X, sides.AbsoluteSize.Y
	x = math.min(x, mx - self.sx)
	y = math.min(y, my - 20)
	self.parts.main.Position = UDim2.new(0, x, 0, y)
end

function methods:animate(...)
	local t = tween:Create(...)
	self.anims[#self.anims + 1] = t
	t:Play()
end

function methods:stopanim()
	for i, v in pairs(self.anims) do v:Cancel() end
	self.anims = {}
end

function methods:show(data)
	data = data or {}
	local al = data.align
	local pos = data.pos
	local size = data.size
	local target = (al == "left" and left) or (al == "right" and right)
	if not self.closed then
		if not self.docked then
			self:setmini(false)
		elseif self.side and not data.silent then
			dock.setside(self.side, true)
		end
		return
	end
	self.closed = false
	self.lastclose = tick()
	self.parts.title.TextTransparency = 0
	self.parts.top.BackgroundTransparency = 0
	self.parts.edge.ImageTransparency = 0
	self.parts.main.Active = true
	self.parts.edge.Visible = self:getstyle().chrome.showedge
	self:setmini(false, 3)
	self:setinnerresize(true)
	local st = self:getstyle()
	for _, name in ipairs({"close", "minimize", "maximize"}) do
		local b = self.parts[name]
		if b then
			b.BackgroundTransparency = 1
			b.TextTransparency = 0
		end
	end
	playsound(st, "open")
	if al then
		self:sidalign(target, pos, size, data.silent)
	else
		if al == nil and self.closeside then
			self:sidalign(self.closeside, self.sideidx, size, true)
			dock.setside(self.closeside, true)
		else
			if table.find(shown, self) then return end
			if size then
				self.sy = size.Y or self.sy
				self.sx = size.X or self.sx
			end
			self.parts.main.Size = UDim2.new(0, self.sx, 0, 20)
			self:stopanim()
			self:animate(self.parts.main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, self.sx, 0, self.sy)})
			table.insert(shown, 1, self)
			redraw()
		end
	end
	self.closeside = nil
	self.activated:fire()
end

function methods:showfocus(data)
	self:show(data)
	run.RenderStepped:Wait()
	self:focus()
end

function dock.toggleside(name)
	local side = (name == "left" and left or right)
	side.hidden = not side.hidden
	for i, v in pairs(side.wins) do
		if side.hidden then
			v.deactivated:fire()
		else
			v.activated:fire()
		end
	end
	redraw()
end

function dock.setside(s, vis)
	local side = (type(s) == "table" and s) or (s == "left" and left or right)
	side.hidden = not vis
	for i, v in pairs(side.wins) do
		if side.hidden then
			v.deactivated:fire()
		else
			v.activated:fire()
		end
	end
	redraw()
end

function dock.start()
	if started then return end
	started = true
	local st = dock.style
	sides = Instance.new("ScreenGui")
	sides.Name = "sspdockcontainer_Sides"
	sides.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local lf = Instance.new("Frame")
	lf.Name = "LeftSide"
	lf.Active = true
	lf.BackgroundColor3 = st.colors.back
	lf.BorderSizePixel = 0
	left.frame = lf

	local lr = Instance.new("TextButton")
	lr.Name = "Resizer"
	lr.AutoButtonColor = false
	lr.BackgroundColor3 = st.colors.grip
	lr.BorderSizePixel = 0
	lr.Size = UDim2.new(0, 5, 1, 0)
	lr.Text = ""
	lr.Parent = lf
	watch(lr, "BackgroundColor3", "colors.grip")

	local ll = Instance.new("Frame")
	ll.Name = "Line"
	ll.BackgroundColor3 = st.colors.edge
	ll.BorderSizePixel = 0
	ll.Size = UDim2.new(0, 1, 1, 0)
	ll.Parent = lr
	watch(ll, "BackgroundColor3", "colors.edge")

	local lw = Instance.new("TextButton")
	lw.Name = "WindowResizer"
	lw.AutoButtonColor = false
	lw.BackgroundColor3 = st.colors.grip
	lw.BorderSizePixel = 0
	lw.Size = UDim2.new(1, 0, 0, 4)
	lw.Text = ""
	lw.Parent = lf
	watch(lw, "BackgroundColor3", "colors.grip")
	left.winresizer = lw

	lw.Parent = nil
	lf.Position = UDim2.new(0, -left.w - 10, 0, 0)
	lf.Parent = sides

	local rf = Instance.new("Frame")
	rf.Name = "RightSide"
	rf.Active = true
	rf.BackgroundColor3 = st.colors.back
	rf.BorderSizePixel = 0
	right.frame = rf

	local rr = Instance.new("TextButton")
	rr.Name = "Resizer"
	rr.AutoButtonColor = false
	rr.BackgroundColor3 = st.colors.grip
	rr.BorderSizePixel = 0
	rr.Size = UDim2.new(0, 5, 1, 0)
	rr.Text = ""
	rr.Parent = rf
	watch(rr, "BackgroundColor3", "colors.grip")

	local rl = Instance.new("Frame")
	rl.Name = "Line"
	rl.BackgroundColor3 = st.colors.edge
	rl.BorderSizePixel = 0
	rl.Position = UDim2.new(0, 4, 0, 0)
	rl.Size = UDim2.new(0, 1, 1, 0)
	rl.Parent = rr
	watch(rl, "BackgroundColor3", "colors.edge")

	local rw = Instance.new("TextButton")
	rw.Name = "WindowResizer"
	rw.AutoButtonColor = false
	rw.BackgroundColor3 = st.colors.grip
	rw.BorderSizePixel = 0
	rw.Size = UDim2.new(1, 0, 0, 4)
	rw.Text = ""
	rw.Parent = rf
	watch(rw, "BackgroundColor3", "colors.grip")
	right.winresizer = rw

	rw.Parent = nil
	rf.Position = UDim2.new(1, 10, 0, 0)
	rf.Parent = sides

	watch(lf, "BackgroundColor3", "colors.back")
	watch(rf, "BackgroundColor3", "colors.back")

	draggrip(lr, "H", left)
	draggrip(rr, "H", right)

	hint = Instance.new("ScreenGui")
	hint.Name = "sspdockcontainer_Indicator"
	hint.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	hint.DisplayOrder = 101000
	local ind = Instance.new("Frame")
	ind.BackgroundColor3 = st.colors.hint
	ind.BorderSizePixel = 0
	ind.BackgroundTransparency = 0.5
	ind.Name = "Indicator"
	local ic = Instance.new("UICorner")
	ic.CornerRadius = UDim.new(0, 10)
	ic.Parent = ind
	ind.Parent = hint
	hintind = ind
	watch(ind, "BackgroundColor3", "colors.hint")

	local lt = Instance.new("TextButton")
	lt.Name = "LeftToggle"
	lt.AutoButtonColor = false
	lt.BackgroundColor3 = st.colors.btn
	lt.BorderColor3 = st.colors.edge
	lt.BorderMode = Enum.BorderMode.Outline
	lt.Font = Enum.Font.GothamBold
	lt.Position = UDim2.new(0, 0, 0, -36)
	lt.Size = UDim2.new(0, st.docking.togglew, 0, st.docking.toggleh)
	lt.Text = "<"
	lt.TextColor3 = st.colors.ico
	lt.TextSize = 14
	lt.Parent = sides

	local rt = lt:Clone()
	rt.Name = "RightToggle"
	rt.Position = UDim2.new(1, -16, 0, -36)
	rt.Parent = sides

	ltoggle = lt
	rtoggle = rt

	bteffects(lt, {mode = 2, startrole = "colors.btn", hoverrole = "colors.btnover", pressrole = "colors.btndown"})
	bteffects(rt, {mode = 2, startrole = "colors.btn", hoverrole = "colors.btnover", pressrole = "colors.btndown"})

	lt.MouseButton1Click:Connect(function() dock.toggleside("left") end)
	rt.MouseButton1Click:Connect(function() dock.toggleside("right") end)

	sides:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local s2 = dock.style
		local mw = math.max(300, sides.AbsoluteSize.X - s2.docking.freew)
		left.w = math.max(s2.docking.minw, math.min(left.w, mw - right.w))
		right.w = math.max(s2.docking.minw, math.min(right.w, mw - left.w))
		for i = 1, #shown do shown[i]:keepin() end
		redraw(true)
	end)

	sides.DisplayOrder = sideorder - 1
	sides.Parent = holder
	movesides()
end

function dock.new(title, x, y)
	dock.start()
	local obj = setmetatable({
		mini = false,
		maxi = false,
		dragging = false,
		resizing = false,
		docked = false,
		draggable = true,
		canresize = true,
		innerresize = true,
		dockable = true,
		snaptoedge = true,
		closed = true,
		focused = false,
		sx = x or 300,
		sy = y or 300,
		minx = 200,
		miny = 200,
		px = 0,
		py = 0,
		parts = {},
		anims = {},
		items = {},
		styles = {},
		mystyle = nil,
		activated = signal.new(),
		deactivated = signal.new(),
		minimized = signal.new(),
		restored = signal.new(),
	}, meta)

	obj.gui = makegui(obj)
	table.insert(dock.all, obj)
	if title then obj:title(title) end

	local st = obj:getstyle()

	local bevels = {}
	if st.shape.bevel then
		for _, name in ipairs({"close", "minimize", "maximize"}) do
			local b = obj.parts[name]
			if b then
				bevels[b] = bevel(b, st)
			end
		end
	end

	bteffects(obj.parts.close, {mode = 1, presssound = "click", bevel = bevels[obj.parts.close]})
	bteffects(obj.parts.minimize, {mode = 1, presssound = "click", bevel = bevels[obj.parts.minimize]})
	bteffects(obj.parts.maximize, {mode = 1, presssound = "click", bevel = bevels[obj.parts.maximize]})

	local top = obj.parts.top
	local main = obj.parts.main

	top.InputBegan:Connect(function(i)
		if ispress(i) and obj.draggable and not obj.closed then
			front(obj)
			local rel, mov
			local ix = i.Position.X
			local iy = i.Position.Y
			local inx = main.Position.X.Offset
			local iny = main.Position.Y.Offset
			local inspos, insside
			if not obj.docked then
				obj.freex = obj.sx
				obj.freey = obj.sy
			end
			rel = input.InputEnded:Connect(function(x)
				if isrelease(x) then
					rel:Disconnect()
					mov:Disconnect()
					hint.Parent = nil
					if insside then
						local ts = (insside == "left" and left) or (insside == "right" and right)
						obj:sidalign(ts, inspos)
					end
				end
			end)
			mov = input.InputChanged:Connect(function(x)
				if isdrag(x) and obj.draggable and not obj.closed then
					if obj.docked then
						if left.resizing or right.resizing then return end
						local dx = x.Position.X - ix
						local dy = x.Position.Y - iy
						if math.sqrt(dx^2 + dy^2) >= 5 then
							obj:setaligned(false)
							inx = x.Position.X - (obj.sx / 2)
							iny = x.Position.Y - 10
							ix = x.Position.X
							iy = x.Position.Y
						end
					else
						local dx = x.Position.X - ix
						local dy = x.Position.Y - iy
						local npx = inx + dx
						local npy = iny + dy
						if npy < 0 then npy = 0 end
						if obj.snaptoedge then
							local mx = sides.AbsoluteSize.X
							local my = sides.AbsoluteSize.Y
							local snap = 20
							if npx < snap then npx = 0 end
							if npy < snap then npy = 0 end
							if npx + obj.sx > mx - snap then npx = mx - obj.sx end
							if npy + obj.sy > my - snap then npy = my - obj.sy end
						end
						main.Position = UDim2.new(0, npx, 0, npy)
						if obj.canresize and obj.dockable then
							local mx = sides.AbsoluteSize.X
							local cx = x.Position.X
							local cy = x.Position.Y
							if cx < 25 then
								if hasroom(left, obj.miny or 100) then
									local ip, range = insertspot(left, cy)
									hintind.Position = UDim2.new(0, 0, 0, range[1])
									hintind.Size = UDim2.new(0, left.w, 0, range[2] - range[1])
									hint.Parent = holder
									inspos = ip
									insside = "left"
									return
								end
							elseif cx >= mx - 25 then
								if hasroom(right, obj.miny or 100) then
									local ip, range = insertspot(right, cy)
									hintind.Position = UDim2.new(0, mx - right.w, 0, range[1])
									hintind.Size = UDim2.new(0, right.w, 0, range[2] - range[1])
									hint.Parent = holder
									inspos = ip
									insside = "right"
									return
								end
							end
						end
						hint.Parent = nil
						inspos = nil
						insside = nil
					end
				end
			end)
		end
	end)

	obj.parts.close.MouseButton1Click:Connect(function()
		if obj.closed then return end
		obj:close()
	end)

	obj.parts.minimize.MouseButton1Click:Connect(function()
		if obj.closed then return end
		if obj.docked then
			obj:setaligned(false)
		else
			obj:setmini()
		end
	end)

	obj.parts.minimize.MouseButton2Click:Connect(function()
		if obj.closed then return end
		if not obj.docked then
			obj:setmini(nil, 2)
			obj.parts.minimize.BackgroundTransparency = 1
		end
	end)

	obj.parts.maximize.MouseButton1Click:Connect(function()
		if obj.closed then return end
		obj:setmax()
	end)

	local lastclick = 0
	top.InputBegan:Connect(function(i)
		if ispress(i) and not obj.closed then
			local now = tick()
			if now - lastclick < 0.3 and obj:getstyle().titlebar.dblmini and not obj.docked then
				obj:setmini()
				lastclick = 0
			else
				lastclick = now
			end
		end
	end)

	main.InputBegan:Connect(function(i)
		if ispress(i) and not obj.docked and not obj.closed then
			front(obj)
		end
	end)

	main:GetPropertyChangedSignal("Position"):Connect(function()
		obj.px = main.Position.X.Offset
		obj.py = main.Position.Y.Offset
	end)

	dragresize(obj, obj.parts.rc.North, "N")
	dragresize(obj, obj.parts.rc.NorthEast, "NE")
	dragresize(obj, obj.parts.rc.East, "E")
	dragresize(obj, obj.parts.rc.SouthEast, "SE")
	dragresize(obj, obj.parts.rc.South, "S")
	dragresize(obj, obj.parts.rc.SouthWest, "SW")
	dragresize(obj, obj.parts.rc.West, "W")
	dragresize(obj, obj.parts.rc.NorthWest, "NW")

	main.Size = UDim2.new(0, obj.sx, 0, obj.sy)

	obj.gui.DescendantAdded:Connect(function(desc)
		addfocus(obj, desc)
		if desc:IsA("ScrollingFrame") then
			desc.ScrollBarImageColor3 = obj:getstyle().colors.scroll
		end
	end)

	local descs = obj.gui:GetDescendants()
	for i = 1, #descs do
		addfocus(obj, descs[i])
		if descs[i]:IsA("ScrollingFrame") then
			descs[i].ScrollBarImageColor3 = obj:getstyle().colors.scroll
		end
	end

	obj:restyle()
	return obj
end

return dock
