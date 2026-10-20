local alion = {}
if getgenv().Alion and type(getgenv().Alion) == "table" and getgenv().Alion.cleanup then
	pcall(function() getgenv().Alion:cleanup() end)
end
getgenv().Alion = alion
alion.__index = alion
alion.version = "2.0.3"
alion._debug = true
alion._connections = {}
alion._keybinds = {}
alion._accentbindings = {}
alion._themebindings = {}
alion._notifcounter = 0
alion._notiflower = false
alion._capturingkeybind = nil
alion._activetheme = "dark"
alion._customaccent = nil
alion._windows = {}
alion._gui = nil

local players = game:GetService("Players")
local tweenservice = game:GetService("TweenService")
local input = game:GetService("UserInputService")
local runservice = game:GetService("RunService")
local coregui = game:GetService("CoreGui")
local player = players.LocalPlayer

local iconsheet = "rbxassetid://89989658646441"
local iconnames = {
	"home","sliders","user","search","sword","eye","globe","folder",
	"info","close","minimize","check","chevron-down","chevron-up","chevron-right","chevron-left",
	"plus","square","star","heart","bell","lock","palette","code",
	"bolt","drop","shield","cursor","keyboard","list","trash","refresh",
	"moon","sun","copy","key","bookmark","target","layers","edit",
	"settings","zap","gauge","gear","grid","rotate","camera","play",
}
local iconcell = 64
local iconcols = 8
local iconindex = {}
for i,name in ipairs(iconnames) do iconindex[name] = i - 1 end

local presets = {
	dark = {
		name = "dark",
		background = Color3.fromRGB(28,28,28),
		card = Color3.fromRGB(38,38,38),
		cardtrans = 0.10,
		control = Color3.fromRGB(50,50,50),
		controlhover = Color3.fromRGB(62,62,62),
		input = Color3.fromRGB(24,24,24),
		stroke = Color3.fromRGB(74,74,74),
		strokelight = Color3.fromRGB(102,102,102),
		divider = Color3.fromRGB(56,56,56),
		text = Color3.fromRGB(242,242,242),
		subtext = Color3.fromRGB(165,165,165),
		muted = Color3.fromRGB(120,120,120),
		accent = Color3.fromRGB(255,140,50),
		accenttext = Color3.fromRGB(0,0,0),
		danger = Color3.fromRGB(196,43,28),
		nav = Color3.fromRGB(24,24,24),
	},
	light = {
		name = "light",
		background = Color3.fromRGB(243,243,243),
		card = Color3.fromRGB(255,255,255),
		cardtrans = 0.00,
		control = Color3.fromRGB(240,240,240),
		controlhover = Color3.fromRGB(226,226,226),
		input = Color3.fromRGB(251,251,251),
		stroke = Color3.fromRGB(216,216,216),
		strokelight = Color3.fromRGB(186,186,186),
		divider = Color3.fromRGB(232,232,232),
		text = Color3.fromRGB(28,28,28),
		subtext = Color3.fromRGB(96,96,96),
		muted = Color3.fromRGB(140,140,140),
		accent = Color3.fromRGB(0,120,212),
		accenttext = Color3.fromRGB(255,255,255),
		danger = Color3.fromRGB(196,43,28),
		nav = Color3.fromRGB(250,250,250),
	},
	midnight = {
		name = "midnight",
		background = Color3.fromRGB(15,17,26),
		card = Color3.fromRGB(24,27,40),
		cardtrans = 0.05,
		control = Color3.fromRGB(34,38,56),
		controlhover = Color3.fromRGB(44,49,71),
		input = Color3.fromRGB(12,14,22),
		stroke = Color3.fromRGB(46,52,76),
		strokelight = Color3.fromRGB(72,82,118),
		divider = Color3.fromRGB(34,38,56),
		text = Color3.fromRGB(232,236,248),
		subtext = Color3.fromRGB(150,160,190),
		muted = Color3.fromRGB(100,110,140),
		accent = Color3.fromRGB(94,154,255),
		accenttext = Color3.fromRGB(255,255,255),
		danger = Color3.fromRGB(220,70,70),
		nav = Color3.fromRGB(11,13,20),
	},
	nord = {
		name = "nord",
		background = Color3.fromRGB(46,52,64),
		card = Color3.fromRGB(59,66,82),
		cardtrans = 0.05,
		control = Color3.fromRGB(67,76,94),
		controlhover = Color3.fromRGB(76,86,106),
		input = Color3.fromRGB(36,41,51),
		stroke = Color3.fromRGB(76,86,106),
		strokelight = Color3.fromRGB(94,106,130),
		divider = Color3.fromRGB(67,76,94),
		text = Color3.fromRGB(236,239,244),
		subtext = Color3.fromRGB(180,190,205),
		muted = Color3.fromRGB(130,140,155),
		accent = Color3.fromRGB(136,192,208),
		accenttext = Color3.fromRGB(46,52,64),
		danger = Color3.fromRGB(191,97,106),
		nav = Color3.fromRGB(40,45,56),
	},
	rose = {
		name = "rose",
		background = Color3.fromRGB(30,20,25),
		card = Color3.fromRGB(42,28,35),
		cardtrans = 0.05,
		control = Color3.fromRGB(56,38,47),
		controlhover = Color3.fromRGB(70,48,58),
		input = Color3.fromRGB(24,16,20),
		stroke = Color3.fromRGB(78,52,62),
		strokelight = Color3.fromRGB(108,74,88),
		divider = Color3.fromRGB(56,38,47),
		text = Color3.fromRGB(245,232,238),
		subtext = Color3.fromRGB(190,165,178),
		muted = Color3.fromRGB(140,118,130),
		accent = Color3.fromRGB(232,106,148),
		accenttext = Color3.fromRGB(30,20,25),
		danger = Color3.fromRGB(220,70,90),
		nav = Color3.fromRGB(24,16,20),
	},
}

local theme = {}
for k,v in pairs(presets.dark) do theme[k] = v end
alion.theme = theme
alion.themes = presets
alion.accent = theme.accent

alion.settings = {
	theme = "dark",
	navposition = "left",
	showprofile = true,
	showfooter = true,
	transparency = 0.06,
	scale = 1,
	showsettingstab = true,
}

local function dbg(...)
	if alion._debug == false then return end
	local n = select("#",...)
	local parts = {}
	for i = 1,n do parts[i] = tostring(select(i,...)) end
	print("[alion] " .. table.concat(parts," "))
end

local function new(class,props,children)
	local inst = Instance.new(class)
	local parent
	for k,v in pairs(props or {}) do
		if k == "Parent" then parent = v else inst[k] = v end
	end
	for _,child in ipairs(children or {}) do child.Parent = inst end
	if parent then inst.Parent = parent end
	return inst
end

local function ti(time,style,dir,delay)
	return TweenInfo.new(time or 0.25,style or Enum.EasingStyle.Quint,dir or Enum.EasingDirection.Out,0,false,delay or 0)
end

local function tween(inst,info,props)
	if not inst or not inst.Parent then return nil end
	local tw = tweenservice:Create(inst,info,props)
	tw:Play()
	return tw
end

local function corner(parent,r)
	return new("UICorner",{CornerRadius = UDim.new(0,r),Parent = parent})
end

local function stroke(parent,color,thick,trans)
	return new("UIStroke",{
		Color = color,
		Thickness = thick or 1,
		Transparency = trans or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
end

local function shadow(parent,blur,offsety,trans)
	local ok,s = pcall(Instance.new,"UIShadow")
	if not ok or not s then return nil end
	pcall(function() s.Color = Color3.new(0,0,0) end)
	pcall(function() s.BlurRadius = UDim.new(0,blur) end)
	pcall(function() s.Offset = UDim2.fromOffset(0,offsety) end)
	pcall(function() s.Spread = UDim2.fromOffset(0,0) end)
	pcall(function() s.Transparency = trans end)
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
		TextColor3 = theme.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Text = "",
	}
	for k,v in pairs(props) do p[k] = v end
	return new("TextLabel",p)
end

local function applyicon(img,name,color)
	if typeof(name) ~= "string" or name == "" then img.Visible = false return end
	if name:find("rbxasset") then
		img.Image = name
		img.ImageRectSize = Vector2.zero
		img.ImageRectOffset = Vector2.zero
	else
		local idx = iconindex[name]
		if not idx then img.Visible = false return end
		img.Image = iconsheet
		img.ImageRectSize = Vector2.new(iconcell,iconcell)
		img.ImageRectOffset = Vector2.new((idx % iconcols) * iconcell,math.floor(idx / iconcols) * iconcell)
	end
	img.Visible = true
	if color then img.ImageColor3 = color end
end

local function icon(props,name,color)
	local p = {BackgroundTransparency = 1,BorderSizePixel = 0}
	for k,v in pairs(props) do p[k] = v end
	local img = new("ImageLabel",p)
	applyicon(img,name,color)
	return img
end

local function fire(cb,...)
	if type(cb) ~= "function" then return end
	local args = table.pack(...)
	task.spawn(function()
		local ok,err = pcall(cb,table.unpack(args,1,args.n))
		if not ok then warn("[alion] callback error: " .. tostring(err)) end
	end)
end

local function tokey(v)
	if typeof(v) == "EnumItem" and v.EnumType == Enum.KeyCode then return v end
	if type(v) == "string" then
		local ok,kc = pcall(function() return Enum.KeyCode[v] end)
		if ok and kc then return kc end
	end
	return Enum.KeyCode.E
end

local function getguiparent()
	local ok,ui = pcall(function() return gethui and gethui() end)
	if ok and ui then return ui end
	local ok2,core = pcall(function()
		local c = coregui
		local probe = Instance.new("Folder")
		probe.Parent = c
		probe:Destroy()
		return c
	end)
	if ok2 and core then return core end
	return player:WaitForChild("PlayerGui")
end

local function getgui()
	if alion._gui and alion._gui.Parent then return alion._gui end
	local parent = getguiparent()
	for _,child in ipairs(parent:GetChildren()) do
		if child.Name == "Alion" then pcall(function() child:Destroy() end) end
	end
	local gui = new("ScreenGui",{
		Name = "Alion",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
		DisplayOrder = 1000,
		Parent = parent,
	})
	alion._gui = gui
	return gui
end

local function track(conn)
	if conn then table.insert(alion._connections,conn) end
	return conn
end

local function regaccent(inst,prop,fn)
	table.insert(alion._accentbindings,{inst = inst,prop = prop or "BackgroundColor3",fn = fn})
end

local function regtheme(inst,prop,key)
	table.insert(alion._themebindings,{inst = inst,prop = prop,key = key})
end

local function applyaccent(color)
	alion.accent = color
	for _,b in ipairs(alion._accentbindings) do
		if b.fn then
			pcall(b.fn)
		elseif b.inst and b.inst.Parent then
			pcall(function() b.inst[b.prop] = color end)
		end
	end
end

local function applytheme(name,keep)
	local preset = presets[name]
	if not preset then return end
	alion._activetheme = name
	alion.settings.theme = name
	for k,v in pairs(preset) do
		if k ~= "accent" or not keep then theme[k] = v end
	end
	if not keep then
		theme.accent = preset.accent
		alion.accent = preset.accent
	else
		theme.accent = alion.accent
	end
	for _,b in ipairs(alion._themebindings) do
		if b.inst and b.inst.Parent and theme[b.key] ~= nil then
			pcall(function() b.inst[b.prop] = theme[b.key] end)
		end
	end
	if not keep then applyaccent(theme.accent) end
	for _,w in ipairs(alion._windows) do
		if w and w._refreshtheme then pcall(w._refreshtheme,w) end
	end
end

function alion:setaccent(color)
	self._customaccent = color
	applyaccent(color)
end
function alion:getaccent() return self.accent end
function alion:settheme(name,keep) applytheme(name,keep) end
function alion:gettheme() return self._activetheme end
function alion:getthemelist()
	local t = {}
	for k in pairs(presets) do table.insert(t,k) end
	table.sort(t)
	return t
end
function alion:setnotificationlower(v) self._notiflower = v and true or false end
function alion:setdebug(v) self._debug = v and true or false end
function alion:getdebug() return self._debug ~= false end
function alion:debug(...)
	local n = select("#",...)
	local parts = {}
	for i = 1,n do parts[i] = tostring(select(i,...)) end
	print("[alion debug] " .. table.concat(parts," "))
end
function alion:getinfo()
	return {
		version = self.version,
		theme = self._activetheme,
		accent = self.accent,
		windows = #self._windows,
		themebindings = #self._themebindings,
		accentbindings = #self._accentbindings,
		keybinds = #self._keybinds,
		connections = #self._connections,
		hasgui = self._gui ~= nil and self._gui.Parent ~= nil,
	}
end

function alion:cleanup()
	for _,c in ipairs(self._connections or {}) do pcall(function() c:Disconnect() end) end
	self._connections = {}
	self._keybinds = {}
	self._accentbindings = {}
	self._themebindings = {}
	self._capturingkeybind = nil
	self._windows = {}
	if self._gui then pcall(function() self._gui:Destroy() end) end
	self._gui = nil
	if getgenv and getgenv().Alion == self then getgenv().Alion = nil end
end

track(input.InputBegan:Connect(function(i,processed)
	if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
	if alion._capturingkeybind then
		local cb = alion._capturingkeybind
		alion._capturingkeybind = nil
		pcall(cb,i.KeyCode)
		return
	end
	if input:GetFocusedTextBox() then return end
	for _,e in ipairs(alion._keybinds) do
		if e.key == i.KeyCode and e.cb then fire(e.cb) break end
	end
end))

function alion:notify(o)
	o = o or {}
	local gui = getgui()
	local holder = gui:FindFirstChild("Notifications")
	if not holder then
		holder = new("Frame",{
			Name = "Notifications",
			AnchorPoint = Vector2.new(1,1),
			Position = UDim2.new(1,-20,1,-20),
			Size = UDim2.new(0,320,1,-40),
			BackgroundTransparency = 1,
			Parent = gui,
		})
		new("UIListLayout",{
			Padding = UDim.new(0,10),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Parent = holder,
		})
	end
	self._notifcounter = (self._notifcounter or 0) + 1
	local duration = o.duration or 4
	local wrap = new("Frame",{
		Size = UDim2.new(1,0,0,72),
		BackgroundTransparency = 1,
		LayoutOrder = self._notifcounter,
		Parent = holder,
	})
	local card = new("Frame",{
		Position = UDim2.new(1,80,0,0),
		Size = UDim2.fromScale(1,1),
		BackgroundColor3 = theme.card,
		BackgroundTransparency = 0.06,
		Parent = wrap,
	})
	corner(card,8)
	local cs = stroke(card,theme.stroke,1,0.15)
	regtheme(card,"BackgroundColor3","card")
	regtheme(cs,"Color","stroke")
	shadow(card,26,8,0.55)
	icon({Position = UDim2.fromOffset(16,14),Size = UDim2.fromOffset(20,20),Parent = card},o.icon or "bell",self.accent)
	label({
		Position = UDim2.fromOffset(48,12),
		Size = UDim2.new(1,-64,0,20),
		Text = o.title or "Notification",
		Font = Enum.Font.BuilderSansBold,
		TextSize = 14,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = card,
	})
	local body = label({
		Position = UDim2.fromOffset(48,32),
		Size = UDim2.new(1,-64,0,26),
		Text = o.content or "",
		Font = Enum.Font.BuilderSans,
		TextSize = 12,
		TextColor3 = theme.subtext,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = card,
	})
	regtheme(body,"TextColor3","subtext")
	local rail = new("Frame",{
		Position = UDim2.new(0,12,1,-6),
		Size = UDim2.new(1,-24,0,2),
		BackgroundColor3 = theme.divider,
		BorderSizePixel = 0,
		Parent = card,
	})
	regtheme(rail,"BackgroundColor3","divider")
	corner(rail,100)
	local fill = new("Frame",{
		Size = UDim2.fromScale(1,1),
		BackgroundColor3 = self.accent,
		BorderSizePixel = 0,
		Parent = rail,
	})
	corner(fill,100)
	regaccent(fill)
	tween(card,ti(0.5),{Position = UDim2.new(0,0,0,0)})
	tween(fill,TweenInfo.new(duration,Enum.EasingStyle.Linear),{Size = UDim2.new(0,0,1,0)})
	task.delay(duration,function()
		if not card.Parent then return end
		tween(card,ti(0.4,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{Position = UDim2.new(1,80,0,0)})
		task.wait(0.35)
		if wrap.Parent then
			local t = tween(wrap,ti(0.3),{Size = UDim2.new(1,0,0,0)})
			if t then t.Completed:Wait() end
			wrap:Destroy()
		end
	end)
end

local function sanitizechar(clone)
	if not clone then return nil end
	local ok = pcall(function()
		for _,d in ipairs(clone:GetDescendants()) do
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

local function centermodel(clone,mode)
	if not clone then return end
	if mode == "head" then
		local head = clone:FindFirstChild("Head")
		if head and head:IsA("BasePart") then
			for _,d in ipairs(clone:GetDescendants()) do
				if d:IsA("BasePart") and d ~= head then d.Transparency = 1 end
			end
			pcall(function() clone:PivotTo(head.CFrame - head.Position) end)
		end
	else
		local ok,bcf = pcall(function() return clone:GetBoundingBox() end)
		if ok and bcf then
			local pivot = clone:GetPivot()
			pcall(function() clone:PivotTo(pivot + (Vector3.zero - bcf.Position)) end)
		end
	end
end

local function buildfrommodel(world,model,mode)
	if not model or not model.Parent then return nil end
	local ok,clone = pcall(function() return model:Clone() end)
	if not ok or not clone then return nil end
	clone = sanitizechar(clone)
	if not clone then return nil end
	clone.Parent = world
	centermodel(clone,mode)
	return clone
end

local function buildfromuserid(world,userid,mode)
	local rigs = {Enum.HumanoidRigType.R15,Enum.HumanoidRigType.R6}
	for _,rig in ipairs(rigs) do
		local ok,desc = pcall(function() return players:GetHumanoidDescriptionFromUserId(userid) end)
		if ok and desc then
			local ok2,model = pcall(function() return players:CreateHumanoidModelFromDescription(desc,rig) end)
			if ok2 and model then
				local result = buildfrommodel(world,model,mode)
				pcall(function() model:Destroy() end)
				if result then return result end
			end
		end
	end
	return nil
end

local function buildcharinto(world,target,mode)
	if not target then return nil end
	if typeof(target) == "Instance" then
		if target:IsA("Player") then
			local char = target.Character
			if not char then return nil end
			return buildfrommodel(world,char,mode)
		end
		if target:IsA("Model") then return buildfrommodel(world,target,mode) end
		return nil
	end
	if type(target) == "number" then
		local plr = players:GetPlayerByUserId(target)
		if plr and plr.Character then return buildfrommodel(world,plr.Character,mode) end
		return buildfromuserid(world,target,mode)
	end
	return nil
end

local function lightpoints(world)
	local function add(cf,color,bright,range)
		local p = new("Part",{
			Size = Vector3.new(0.1,0.1,0.1),
			Transparency = 1,
			Anchored = true,
			CanCollide = false,
			CanQuery = false,
			CanTouch = false,
			CFrame = cf,
			Parent = world,
		})
		new("PointLight",{Color = color,Brightness = bright,Range = range,Shadows = true,Parent = p})
	end
	add(CFrame.new(5,7,6),Color3.fromRGB(255,235,205),4,30)
	add(CFrame.new(-6,3,4),Color3.fromRGB(155,185,255),2,30)
	add(CFrame.new(0,5,-7),Color3.fromRGB(255,255,255),3,30)
end

local function makecharview(props)
	props = props or {}
	local mode = props.mode or "full"
	local spin = props.spin ~= false
	local spinspeed = props.spinspeed or 40
	local fov = props.fov or (mode == "head" and 22 or 30)
	local startangle = props.startangle or math.pi

	local vpf = new("ViewportFrame",{
		Name = "AlionViewport",
		Size = props.size or UDim2.fromScale(1,1),
		BackgroundTransparency = 1,
		Ambient = Color3.fromRGB(115,115,115),
		LightColor = Color3.fromRGB(255,250,238),
		LightDirection = Vector3.new(-0.45,-1,-0.35).Unit,
		Parent = props.parent,
	})
	local world = new("WorldModel",{Parent = vpf})
	local cam = new("Camera",{FieldOfView = fov,Parent = vpf})
	vpf.CurrentCamera = cam
	lightpoints(world)

	local model = buildcharinto(world,props.target or player,mode)
	local dist = props.distance
	if not dist and model then
		local ok,_,size = pcall(function() return model:GetBoundingBox() end)
		if ok and size then
			local maxdim = math.max(size.X,size.Y,size.Z)
			if maxdim > 0 then dist = (maxdim * 0.5) / math.tan(math.rad(fov * 0.5)) * 1.25 end
		end
	end
	dist = dist or 12
	local height = props.lookheight or (mode == "head" and 0 or 0.2)

	local angle = startangle
	local spinconn
	if spin then
		spinconn = runservice.RenderStepped:Connect(function(dt)
			if not vpf.Parent then return end
			angle = angle + dt * math.rad(spinspeed)
			local x = math.sin(angle) * dist
			local z = math.cos(angle) * dist
			cam.CFrame = CFrame.lookAt(Vector3.new(x,height + 0.15,z),Vector3.new(0,height,0))
		end)
	else
		local x = math.sin(angle) * dist
		local z = math.cos(angle) * dist
		cam.CFrame = CFrame.lookAt(Vector3.new(x,height + 0.15,z),Vector3.new(0,height,0))
	end

	local api = {instance = vpf,world = world,camera = cam,conn = spinconn}
	function api:destroy()
		if spinconn then spinconn:Disconnect() end
		if vpf.Parent then vpf:Destroy() end
	end
	function api:settarget(target)
		if model and model.Parent then model:Destroy() end
		model = buildcharinto(world,target,mode)
		if model then
			local ok,_,size = pcall(function() return model:GetBoundingBox() end)
			if ok and size then
				local maxdim = math.max(size.X,size.Y,size.Z)
				if maxdim > 0 then dist = (maxdim * 0.5) / math.tan(math.rad(fov * 0.5)) * 1.25 end
			end
		end
	end
	function api:setspeed(v) spinspeed = v end
	return api
end

local window = {}
window.__index = window
local tab = {}
tab.__index = tab
local section = {}
section.__index = section

local function makedraggable(win,handles)
	if win._dragconns then
		for _,c in ipairs(win._dragconns) do pcall(function() c:Disconnect() end) end
	end
	win._dragconns = {}
	local dragging,dragstart,startpos
	for _,handle in ipairs(handles) do
		if handle then
			table.insert(win._dragconns,handle.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
					dragging = true
					dragstart = i.Position
					startpos = win.root.Position
				end
			end))
		end
	end
	table.insert(win._dragconns,input.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local d = i.Position - dragstart
			win.root.Position = UDim2.new(startpos.X.Scale,startpos.X.Offset + d.X,startpos.Y.Scale,startpos.Y.Offset + d.Y)
		end
	end))
	table.insert(win._dragconns,input.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))
end

local function stylenav(tab,active)
	if not tab or not tab.navbtn or not tab.navbtn.Parent then return end
	tween(tab.navbtn,ti(0.25),{BackgroundTransparency = active and 0.90 or 1})
	tween(tab.navicon,ti(0.25),{ImageColor3 = active and alion.accent or theme.subtext})
	tween(tab.navname,ti(0.25),{TextColor3 = active and theme.text or theme.subtext})
end

function alion:createwindow(opts)
	opts = opts or {}
	local gui = getgui()
	local camera = workspace.CurrentCamera
	local vp = camera and camera.ViewportSize or Vector2.new(1280,720)
	local size = opts.size
	local width = size and size.X.Offset or math.min(660,vp.X - 40)
	local height = size and size.Y.Offset or math.min(540,vp.Y - 40)

	local win = setmetatable({
		tabs = {},
		flags = {},
		togglekey = tokey(opts.togglekey or Enum.KeyCode.RightShift),
		_open = false,
		_token = 0,
		_destroyed = false,
		_opts = opts,
		_navpos = self.settings.navposition,
		_showprofile = self.settings.showprofile,
		_showfooter = self.settings.showfooter,
		_showsettingstab = (opts.settings ~= false) and self.settings.showsettingstab,
		_transparency = self.settings.transparency,
		_rootscale = self.settings.scale,
		size = Vector2.new(width,height),
		_pos = nil,
	},window)

	table.insert(self._windows,win)

	local root = new("Frame",{
		Name = "Window",
		AnchorPoint = Vector2.new(0.5,0.5),
		Position = UDim2.new(0.5,0,0.5,0),
		Size = UDim2.fromOffset(width,height),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = gui,
	})
	local scale = new("UIScale",{Scale = 0.9 * win._rootscale,Parent = root})
	local body = new("Frame",{
		Name = "Body",
		Size = UDim2.fromScale(1,1),
		BackgroundColor3 = theme.background,
		BackgroundTransparency = 1,
		Parent = root,
	})
	corner(body,8)
	local bodystroke = stroke(body,theme.strokelight,1,1)
	local bodyshadow = shadow(body,40,14,1)
	local content = new("CanvasGroup",{
		Name = "Content",
		Size = UDim2.fromScale(1,1),
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		Parent = body,
	})
	corner(content,8)
	regtheme(body,"BackgroundColor3","background")
	regtheme(bodystroke,"Color","strokelight")

	win.root = root
	win.scale = scale
	win.body = body
	win.bodystroke = bodystroke
	win.shadow = bodyshadow
	win.content = content
	win.navitems = {}

	function win:_refreshtheme() self:_layout() end

	function win:_layout()
		if self._destroyed then return end
		local keeppages = self.pages
		if keeppages then keeppages.Parent = nil end
		for _,c in ipairs(content:GetChildren()) do
			if c ~= keeppages then pcall(function() c:Destroy() end) end
		end
		self.navitems = {}
		self.indicator = nil

		local pos = self._navpos or "left"
		local showprofile = self._showprofile
		local showfooter = self._showfooter
		local sidebarw,navh = 216,56
		local profileframe
		local navframe

		if pos == "left" then
			profileframe = new("Frame",{
				Name = "Sidebar",
				Size = UDim2.new(0,sidebarw,1,0),
				BackgroundTransparency = 1,
				Parent = content,
			})
			new("Frame",{
				Size = UDim2.new(1,0,0,72),
				BackgroundTransparency = 1,
				Active = true,
				Parent = profileframe,
			})
			if showprofile then
				local avatar = new("ImageLabel",{
					Size = UDim2.fromOffset(40,40),
					Position = UDim2.fromOffset(16,16),
					BackgroundColor3 = theme.control,
					Image = "",
					Parent = profileframe,
				})
				corner(avatar,100)
				local avstroke = stroke(avatar,theme.strokelight,1,0.3)
				regtheme(avatar,"BackgroundColor3","control")
				regtheme(avstroke,"Color","strokelight")
				task.spawn(function()
					local ok,img = pcall(function()
						return players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100)
					end)
					if ok and avatar.Parent then avatar.Image = img end
				end)
				local namelbl = label({
					Position = UDim2.fromOffset(64,16),
					Size = UDim2.new(1,-76,0,20),
					Text = player.DisplayName,
					Font = Enum.Font.BuilderSansBold,
					TextSize = 15,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Parent = profileframe,
				})
				local sublbl = label({
					Position = UDim2.fromOffset(64,36),
					Size = UDim2.new(1,-76,0,18),
					Text = opts.title or "Alion",
					Font = Enum.Font.BuilderSans,
					TextSize = 12,
					TextColor3 = theme.subtext,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Parent = profileframe,
				})
				regtheme(namelbl,"TextColor3","text")
				regtheme(sublbl,"TextColor3","subtext")
			end
			navframe = new("Frame",{
				Name = "Nav",
				Position = UDim2.fromOffset(8,80),
				Size = UDim2.new(1,-16,1,showfooter and -124 or -92),
				BackgroundTransparency = 1,
				Parent = profileframe,
			})
			self.indicator = new("Frame",{
				Size = UDim2.fromOffset(3,16),
				Position = UDim2.fromOffset(0,11),
				BackgroundColor3 = self.accent,
				BorderSizePixel = 0,
				Visible = false,
				ZIndex = 5,
				Parent = navframe,
			})
			corner(self.indicator,100)
			regaccent(self.indicator)
			if showfooter then
				local fl = label({
					Position = UDim2.new(0,16,1,-34),
					Size = UDim2.new(1,-32,0,18),
					Text = "Alion v" .. self.version,
					Font = Enum.Font.BuilderSans,
					TextSize = 12,
					TextColor3 = theme.muted,
					Parent = profileframe,
				})
				regtheme(fl,"TextColor3","muted")
			end
		else
			local topbar = new("Frame",{
				Name = "TopBar",
				Position = (pos == "top") and UDim2.fromOffset(0,0) or UDim2.new(0,0,1,-navh),
				Size = UDim2.new(1,0,0,navh),
				BackgroundColor3 = theme.nav,
				BackgroundTransparency = 0.15,
				Parent = content,
			})
			regtheme(topbar,"BackgroundColor3","nav")
			local nvstroke = stroke(topbar,theme.divider,1,0.4)
			regtheme(nvstroke,"Color","divider")
			local navscroll = new("ScrollingFrame",{
				Position = UDim2.fromOffset(showprofile and 210 or 12,0),
				Size = UDim2.new(1,showprofile and -220 or -12,1,0),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ScrollBarThickness = 0,
				CanvasSize = UDim2.new(),
				AutomaticCanvasSize = Enum.AutomaticSize.X,
				ScrollingDirection = Enum.ScrollingDirection.X,
				ElasticBehavior = Enum.ElasticBehavior.Never,
				Parent = topbar,
			})
			new("UIListLayout",{
				Padding = UDim.new(0,4),
				SortOrder = Enum.SortOrder.LayoutOrder,
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Parent = navscroll,
			})
			navframe = navscroll
			if showprofile then
				local pframe = new("Frame",{
					Size = UDim2.fromOffset(196,navh),
					BackgroundTransparency = 1,
					Parent = content,
					Name = "TopBarProfile",
				})
				pframe.Position = (pos == "top") and UDim2.fromOffset(0,0) or UDim2.new(0,0,1,-navh)
				local avatar = new("ImageLabel",{
					Size = UDim2.fromOffset(30,30),
					Position = UDim2.fromOffset(14,(navh - 30) / 2),
					BackgroundColor3 = theme.control,
					Image = "",
					Parent = pframe,
				})
				corner(avatar,100)
				regtheme(avatar,"BackgroundColor3","control")
				task.spawn(function()
					local ok,img = pcall(function()
						return players:GetUserThumbnailAsync(player.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100)
					end)
					if ok and avatar.Parent then avatar.Image = img end
				end)
				label({
					Position = UDim2.fromOffset(52,0),
					Size = UDim2.new(1,-60,1,0),
					Text = player.DisplayName,
					Font = Enum.Font.BuilderSansBold,
					TextSize = 14,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Parent = pframe,
				})
				profileframe = pframe
			end
		end

		local main = new("Frame",{
			Name = "Main",
			Position = UDim2.fromOffset(0,0),
			Size = UDim2.fromScale(1,1),
			BackgroundTransparency = 1,
			Parent = content,
		})
		if pos == "left" then
			main.Position = UDim2.fromOffset(sidebarw,0)
			main.Size = UDim2.new(1,-sidebarw,1,0)
		elseif pos == "top" then
			main.Position = UDim2.fromOffset(0,navh)
			main.Size = UDim2.new(1,0,1,-navh)
		elseif pos == "bottom" then
			main.Position = UDim2.fromOffset(0,0)
			main.Size = UDim2.new(1,0,1,-navh)
		end

		local header = new("Frame",{
			Name = "Header",
			Size = UDim2.new(1,0,0,56),
			BackgroundTransparency = 1,
			Active = true,
			Parent = main,
		})
		local titlelbl = label({
			Position = UDim2.fromOffset(24,0),
			Size = UDim2.new(1,-130,1,0),
			Text = (self.active and self.active.name) or "",
			Font = Enum.Font.BuilderSansBold,
			TextSize = 22,
			Parent = header,
		})
		regtheme(titlelbl,"TextColor3","text")

		if not keeppages then
			keeppages = new("Frame",{
				Name = "Pages",
				BackgroundTransparency = 1,
				Parent = main,
			})
			self.pages = keeppages
		else
			keeppages.Parent = main
		end
		keeppages.Position = UDim2.fromOffset(0,56)
		keeppages.Size = UDim2.new(1,0,1,-56)

		self.nav = navframe
		self.header = header
		self.titlelbl = titlelbl
		self.main = main
		self.profileframe = profileframe

		local function ctrlbutton(iconname,xoff,hovercolor,hovertrans)
			local b = new("TextButton",{
				AnchorPoint = Vector2.new(1,0),
				Position = UDim2.new(1,xoff,0,0),
				Size = UDim2.fromOffset(46,36),
				BackgroundColor3 = hovercolor,
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				Parent = header,
			})
			icon({
				AnchorPoint = Vector2.new(0.5,0.5),
				Position = UDim2.fromScale(0.5,0.5),
				Size = UDim2.fromOffset(14,14),
				Parent = b,
			},iconname,theme.text)
			track(b.MouseEnter:Connect(function() tween(b,ti(0.15),{BackgroundTransparency = hovertrans}) end))
			track(b.MouseLeave:Connect(function() tween(b,ti(0.15),{BackgroundTransparency = 1}) end))
			return b
		end

		local closebtn = ctrlbutton("close",0,theme.danger,0)
		local minbtn = ctrlbutton("minimize",-46,Color3.new(1,1,1),0.92)
		local draghandle = header
		if pos == "left" and profileframe then
			local sb = profileframe:FindFirstChild("Sidebar")
			if sb then draghandle = sb end
		end
		makedraggable(self,{header,draghandle})

		track(minbtn.Activated:Connect(function()
			self:close()
			alion:notify({title = "Window hidden",content = "Press " .. self.togglekey.Name .. " to open it again.",icon = "info",duration = 3})
		end))
		track(closebtn.Activated:Connect(function() self:destroy() end))

		for _,t in ipairs(self.tabs) do self:_buildnavitem(t,pos) end
		if self.active then stylenav(self.active,true) end
		if self.indicator and self.active and pos == "left" then
			self.indicator.Position = UDim2.fromOffset(0,(self.active.index - 1) * 42 + 11)
			self.indicator.Visible = true
		end

		if self._open then
			body.BackgroundTransparency = self._transparency or 0.06
			bodystroke.Transparency = 0.15
			content.GroupTransparency = 0
			if bodyshadow then pcall(function() bodyshadow.Transparency = 0.5 end) end
		else
			body.BackgroundTransparency = 1
			bodystroke.Transparency = 1
			content.GroupTransparency = 1
			if bodyshadow then pcall(function() bodyshadow.Transparency = 1 end) end
		end
	end

	function win:_buildnavitem(t,pos)
		if pos == "left" then
			local wrap = new("CanvasGroup",{
				Name = t.name,
				Size = UDim2.new(1,0,0,38),
				Position = UDim2.fromOffset(-14,(t.index - 1) * 42),
				BackgroundTransparency = 1,
				GroupTransparency = 1,
				Parent = self.nav,
			})
			local navbtn = new("TextButton",{
				Size = UDim2.fromScale(1,1),
				BackgroundColor3 = Color3.new(1,1,1),
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				Parent = wrap,
			})
			corner(navbtn,6)
			local navicon = icon({
				AnchorPoint = Vector2.new(0,0.5),
				Position = UDim2.new(0,14,0.5,0),
				Size = UDim2.fromOffset(20,20),
				Parent = navbtn,
			},t.icon,theme.subtext)
			local navname = label({
				Position = UDim2.fromOffset(46,0),
				Size = UDim2.new(1,-52,1,0),
				Text = t.name,
				TextColor3 = theme.subtext,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = navbtn,
			})
			t.navbtn = navbtn
			t.navicon = navicon
			t.navname = navname
			t.navwrap = wrap
			track(navbtn.MouseEnter:Connect(function()
				if self.active ~= t then tween(navbtn,ti(0.2),{BackgroundTransparency = 0.95}) end
			end))
			track(navbtn.MouseLeave:Connect(function()
				if self.active ~= t then tween(navbtn,ti(0.2),{BackgroundTransparency = 1}) end
			end))
			track(navbtn.Activated:Connect(function() self:selecttab(t) end))
			task.delay(0.3 + (t.index - 1) * 0.06,function()
				if wrap.Parent then
					tween(wrap,ti(0.5),{Position = UDim2.fromOffset(0,(t.index - 1) * 42),GroupTransparency = 0})
				end
			end)
		else
			local navbtn = new("TextButton",{
				Size = UDim2.fromOffset(120,40),
				BackgroundColor3 = Color3.new(1,1,1),
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				LayoutOrder = t.index,
				Parent = self.nav,
			})
			corner(navbtn,6)
			local navicon = icon({
				AnchorPoint = Vector2.new(0,0.5),
				Position = UDim2.new(0,12,0.5,0),
				Size = UDim2.fromOffset(18,18),
				Parent = navbtn,
			},t.icon,theme.subtext)
			local navname = label({
				Position = UDim2.fromOffset(38,0),
				Size = UDim2.new(1,-44,1,0),
				Text = t.name,
				TextSize = 13,
				TextColor3 = theme.subtext,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = navbtn,
			})
			t.navbtn = navbtn
			t.navicon = navicon
			t.navname = navname
			track(navbtn.MouseEnter:Connect(function()
				if self.active ~= t then tween(navbtn,ti(0.2),{BackgroundTransparency = 0.95}) end
			end))
			track(navbtn.MouseLeave:Connect(function()
				if self.active ~= t then tween(navbtn,ti(0.2),{BackgroundTransparency = 1}) end
			end))
			track(navbtn.Activated:Connect(function() self:selecttab(t) end))
		end
	end

	track(input.InputBegan:Connect(function(i,processed)
		if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
		if i.KeyCode == win.togglekey then
			if input:GetFocusedTextBox() then return end
			win:toggle()
		end
	end))

	win:_layout()
	if win._showsettingstab then win:_buildsettingstab() end
	win:open()
	return win
end

function window:_buildsettingstab()
	if self.settingstab then return end
	local t = self:tab({title = "Alion Settings",icon = "settings"})
	self.settingstab = t
	t.issettings = true

	local general = t:section({title = "Appearance"})
	general:dropdown({
		title = "Theme",
		description = "Overall colour palette",
		icon = "palette",
		options = alion:getthemelist(),
		value = alion._activetheme,
		callback = function(v) if v then alion:settheme(v,false) end end,
	})
	general:colorpicker({
		title = "Accent color",
		description = "Highlight colour used across the UI",
		icon = "drop",
		default = alion.accent,
		callback = function(c) alion:setaccent(c) end,
	})
	general:slider({
		title = "Window transparency",
		description = "How see-through the window body is",
		icon = "eye",
		min = 0,max = 0.5,increment = 0.01,
		value = self._transparency,
		suffix = "",
		callback = function(v)
			self._transparency = v
			alion.settings.transparency = v
			self.body.BackgroundTransparency = v
		end,
	})
	general:slider({
		title = "UI scale",
		description = "Scale the whole window up or down",
		icon = "grid",
		min = 0.7,max = 1.4,increment = 0.05,
		value = self._rootscale,
		callback = function(v)
			self._rootscale = v
			alion.settings.scale = v
			tween(self.scale,ti(0.2),{Scale = (self._open and 1 or 0.92) * v})
		end,
	})

	local navsec = t:section({title = "Layout"})
	navsec:dropdown({
		title = "Nav position",
		description = "Where tab buttons appear",
		icon = "layers",
		options = {"left","top","bottom"},
		value = self._navpos,
		callback = function(v)
			if not v then return end
			self._navpos = v
			alion.settings.navposition = v
			self:_layout()
		end,
	})
	navsec:toggle({
		title = "Show profile panel",
		description = "Avatar and username in the sidebar / header",
		icon = "user",
		value = self._showprofile,
		callback = function(v)
			self._showprofile = v
			alion.settings.showprofile = v
			self:_layout()
		end,
	})
	navsec:toggle({
		title = "Show footer",
		description = "Version label at the bottom of the sidebar",
		icon = "info",
		value = self._showfooter,
		callback = function(v)
			self._showfooter = v
			alion.settings.showfooter = v
			self:_layout()
		end,
	})

	local misc = t:section({title = "Misc"})
	misc:button({
		title = "Reset to defaults",
		description = "Restore theme, accent and layout",
		icon = "refresh",
		buttontext = "Reset",
		callback = function()
			alion.settings.navposition = "left"
			alion.settings.showprofile = true
			alion.settings.showfooter = true
			alion.settings.transparency = 0.06
			alion.settings.scale = 1
			self._navpos = "left"
			self._showprofile = true
			self._showfooter = true
			self._transparency = 0.06
			self._rootscale = 1
			tween(self.scale,ti(0.2),{Scale = self._open and 1 or 0.92})
			self.body.BackgroundTransparency = 0.06
			alion:settheme("dark",false)
			self:_layout()
			alion:notify({title = "Reset",content = "Settings restored to default.",icon = "check"})
		end,
	})
	misc:button({
		title = "Test notification",
		description = "Fire a sample toast",
		icon = "bell",
		buttontext = "Send",
		callback = function()
			alion:notify({title = "Hello!",content = "This is an Alion toast.",icon = "star"})
		end,
	})
end

function window:setvisible(v)
	if self._destroyed then return end
	if self._open == v then return end
	self._open = v
	self._token = self._token + 1
	local token = self._token
	if v then
		local target = self._pos or UDim2.new(0.5,0,0.5,0)
		self.root.Position = UDim2.new(target.X.Scale,target.X.Offset,target.Y.Scale,target.Y.Offset + 24)
		self.root.Visible = true
		local info = ti(0.5)
		tween(self.root,info,{Position = target})
		tween(self.scale,info,{Scale = self._rootscale})
		tween(self.content,ti(0.4),{GroupTransparency = 0})
		tween(self.body,ti(0.4),{BackgroundTransparency = self._transparency or 0.06})
		tween(self.bodystroke,ti(0.4),{Transparency = 0.15})
		if self.shadow then pcall(function() tween(self.shadow,ti(0.5),{Transparency = 0.5}) end) end
	else
		local p = self.root.Position
		self._pos = p
		local info = ti(0.3,Enum.EasingStyle.Quint,Enum.EasingDirection.In)
		tween(self.root,info,{Position = UDim2.new(p.X.Scale,p.X.Offset,p.Y.Scale,p.Y.Offset + 24)})
		tween(self.scale,info,{Scale = 0.92 * self._rootscale})
		tween(self.content,info,{GroupTransparency = 1})
		tween(self.body,info,{BackgroundTransparency = 1})
		tween(self.bodystroke,info,{Transparency = 1})
		if self.shadow then pcall(function() tween(self.shadow,info,{Transparency = 1}) end) end
		task.delay(0.32,function()
			if self._token == token and self.root then self.root.Visible = false end
		end)
	end
end

function window:toggle() self:setvisible(not self._open) end
function window:open() self:setvisible(true) end
function window:close() self:setvisible(false) end
function window:settogglekey(k) self.togglekey = tokey(k) end
function window:notify(o) alion:notify(o) end

function window:destroy()
	if self._destroyed then return end
	self._destroyed = true
	if self._open then self:setvisible(false) end
	if self._dragconns then
		for _,c in ipairs(self._dragconns) do pcall(function() c:Disconnect() end) end
		self._dragconns = nil
	end
	for i,w in ipairs(alion._windows) do
		if w == self then table.remove(alion._windows,i) break end
	end
	task.delay(0.45,function() pcall(function() self.root:Destroy() end) end)
end

function window:selecttab(target)
	if type(target) == "number" then target = self.tabs[target] end
	if not target then return end
	if self.active == target then
		stylenav(target,true)
		return
	end
	local prev = self.active
	self.active = target
	if prev and prev.tabpage and prev.tabpage.Parent then
		stylenav(prev,false)
		tween(prev.tabpage,ti(0.18,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{GroupTransparency = 1})
		task.delay(0.2,function()
			if self.active ~= prev and prev.tabpage and prev.tabpage.Parent then
				prev.tabpage.Visible = false
			end
		end)
	end
	if target.tabpage and target.tabpage.Parent then
		stylenav(target,true)
		target.tabpage.Position = UDim2.fromOffset(0,18)
		target.tabpage.GroupTransparency = 1
		target.tabpage.Visible = true
		if target.tabscroll then target.tabscroll.CanvasPosition = Vector2.zero end
		tween(target.tabpage,ti(0.45,Enum.EasingStyle.Quint,Enum.EasingDirection.Out,0.08),{
			Position = UDim2.fromOffset(0,0),
			GroupTransparency = 0,
		})
	end
	if self.indicator and self._navpos == "left" then
		local y = (target.index - 1) * 42 + 11
		if not prev then
			self.indicator.Position = UDim2.fromOffset(0,y)
			self.indicator.Visible = true
		else
			tween(self.indicator,ti(0.4),{Position = UDim2.fromOffset(0,y)})
		end
	end
	if self.titlelbl then
		self.titlelbl.Text = target.name
		self.titlelbl.TextTransparency = 1
		self.titlelbl.Position = UDim2.fromOffset(38,0)
		tween(self.titlelbl,ti(0.45,Enum.EasingStyle.Quint,Enum.EasingDirection.Out,0.05),{
			TextTransparency = 0,
			Position = UDim2.fromOffset(24,0),
		})
	end
end

function window:tab(opts)
	opts = opts or {}
	local name = opts.title or opts.name or "Tab"
	local iconname = opts.icon or "home"
	local index = #self.tabs + 1
	local page = new("CanvasGroup",{
		Name = name,
		Size = UDim2.fromScale(1,1),
		BackgroundTransparency = 1,
		GroupTransparency = 1,
		Visible = false,
		Parent = self.pages,
	})
	local scroll = new("ScrollingFrame",{
		Size = UDim2.fromScale(1,1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Color3.fromRGB(110,110,110),
		ScrollBarImageTransparency = 0.3,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.Never,
		Parent = page,
	})
	new("UIPadding",{
		PaddingLeft = UDim.new(0,24),
		PaddingRight = UDim.new(0,20),
		PaddingTop = UDim.new(0,6),
		PaddingBottom = UDim.new(0,24),
		Parent = scroll,
	})
	new("UIListLayout",{Padding = UDim.new(0,14),SortOrder = Enum.SortOrder.LayoutOrder,Parent = scroll})

	local t = setmetatable({
		window = self,
		name = name,
		icon = iconname,
		index = index,
		tabpage = page,
		tabscroll = scroll,
		_order = 1,
		_currentsection = nil,
		elements = {},
	},tab)
	table.insert(self.tabs,t)
	if not self._destroyed and self.nav then self:_buildnavitem(t,self._navpos or "left") end
	if index == 1 and not self.active then self:selecttab(t) end
	return t
end

function tab:section(opts)
	opts = opts or {}
	local title = opts.title or opts.name or ""
	local order = self._order + 1
	self._order = order
	local wrap = new("Frame",{
		Name = "Section",
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = order,
		Parent = self.tabscroll,
	})
	new("UIListLayout",{Padding = UDim.new(0,6),SortOrder = Enum.SortOrder.LayoutOrder,Parent = wrap})
	if title ~= "" then
		local h = label({
			Name = "Heading",
			Size = UDim2.new(1,0,0,20),
			Text = title,
			Font = Enum.Font.BuilderSansBold,
			TextSize = 15,
			TextColor3 = alion.accent,
			LayoutOrder = 0,
			Parent = wrap,
		})
		regaccent(h,"TextColor3")
	end
	local card = new("Frame",{
		Name = "Card",
		BackgroundColor3 = theme.card,
		BackgroundTransparency = theme.cardtrans,
		Size = UDim2.new(1,0,0,0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = true,
		LayoutOrder = 1,
		Parent = wrap,
	})
	corner(card,6)
	local cs = stroke(card,theme.stroke,1,0.35)
	regtheme(card,"BackgroundColor3","card")
	regtheme(cs,"Color","stroke")
	local body = new("Frame",{
		Name = "Body",
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = card,
	})
	new("UIListLayout",{SortOrder = Enum.SortOrder.LayoutOrder,Parent = body})

	local sec = setmetatable({
		tab = self,
		window = self.window,
		frame = wrap,
		card = card,
		body = body,
		title = title,
		_order = 0,
		elements = {},
	},section)
	self._currentsection = sec
	return sec
end

function tab:_cursection()
	if not self._currentsection then self:section({}) end
	return self._currentsection
end

function tab:toggle(o) return self:_cursection():toggle(o) end
function tab:dropdown(o) return self:_cursection():dropdown(o) end
function tab:slider(o) return self:_cursection():slider(o) end
function tab:keybind(o) return self:_cursection():keybind(o) end
function tab:button(o) return self:_cursection():button(o) end
function tab:input(o) return self:_cursection():input(o) end
function tab:colorpicker(o) return self:_cursection():colorpicker(o) end
function tab:label(o) return self:_cursection():label(o) end
function tab:textbox(o) return self:_cursection():input(o) end
function tab:paragraph(o) return self:_cursection():paragraph(o) end
function tab:divider(o) return self:_cursection():divider(o) end
function tab:progressbar(o) return self:_cursection():progressbar(o) end
function tab:characterpreview(o) return self:_cursection():characterpreview(o) end
function tab:characterbutton(o) return self:_cursection():characterbutton(o) end
function tab:avatargrid(o) return self:_cursection():avatargrid(o) end

function section:_row(o,reserve)
	self._order = (self._order or 0) + 1
	local desc = o.desc or o.description or ""
	local hasdesc = type(desc) == "string" and desc ~= ""
	local h = hasdesc and 58 or 48
	local row = new("Frame",{
		Name = "Row",
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = self._order,
		Parent = self.body,
	})
	new("UIListLayout",{SortOrder = Enum.SortOrder.LayoutOrder,Parent = row})
	if self._order > 1 then
		local div = new("Frame",{
			Name = "Divider",
			Size = UDim2.new(1,0,0,1),
			BackgroundColor3 = theme.divider,
			BorderSizePixel = 0,
			LayoutOrder = 0,
			Parent = row,
		})
		regtheme(div,"BackgroundColor3","divider")
	end
	local header = new("Frame",{
		Name = "Header",
		Size = UDim2.new(1,0,0,h),
		BackgroundColor3 = Color3.new(1,1,1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = 1,
		Parent = row,
	})
	track(header.MouseEnter:Connect(function() tween(header,ti(0.15),{BackgroundTransparency = 0.96}) end))
	track(header.MouseLeave:Connect(function() tween(header,ti(0.15),{BackgroundTransparency = 1}) end))
	local x = 16
	if o.icon then
		icon({
			AnchorPoint = Vector2.new(0,0.5),
			Position = UDim2.new(0,16,0.5,0),
			Size = UDim2.fromOffset(20,20),
			ImageColor3 = Color3.fromRGB(215,215,215),
			Parent = header,
		},o.icon)
		x = 48
	end
	reserve = reserve or 190
	local title = label({
		Name = "Title",
		Position = hasdesc and UDim2.fromOffset(x,10) or UDim2.fromOffset(x,0),
		Size = hasdesc and UDim2.new(1,-(x + reserve),0,18) or UDim2.new(1,-(x + reserve),1,0),
		Text = o.title or o.name or "",
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = header,
	})
	regtheme(title,"TextColor3","text")
	local descinst
	if hasdesc then
		descinst = label({
			Name = "Description",
			Position = UDim2.fromOffset(x,30),
			Size = UDim2.new(1,-(x + reserve),0,18),
			Text = desc,
			Font = Enum.Font.BuilderSans,
			TextSize = 12,
			TextColor3 = theme.subtext,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = header,
		})
		regtheme(descinst,"TextColor3","subtext")
	end
	return row,header,title,descinst
end

local function finishelement(obj,row,title,desc)
	function obj:settitle(text) if title then title.Text = text end end
	function obj:setdescription(text) if desc then desc.Text = text end end
	function obj:destroy() if row then row:Destroy() end end
	return obj
end

local function setflag(sec,o,value)
	if o.flag and sec and sec.window then sec.window.flags[o.flag] = value end
end

function section:label(o)
	if type(o) == "string" then o = {title = o} end
	o = o or {}
	local row,header,title,desc = self:_row(o,24)
	return finishelement({type = "label"},row,title,desc)
end

function section:paragraph(o)
	o = o or {}
	local text = o.content or o.text or ""
	local title = o.title
	local order = (self._order or 0) + 1
	self._order = order
	local row = new("Frame",{
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = order,
		Parent = self.body,
	})
	new("UIListLayout",{SortOrder = Enum.SortOrder.LayoutOrder,Parent = row})
	if order > 1 then
		local div = new("Frame",{
			Size = UDim2.new(1,0,0,1),
			BackgroundColor3 = theme.divider,
			BorderSizePixel = 0,
			LayoutOrder = 0,
			Parent = row,
		})
		regtheme(div,"BackgroundColor3","divider")
	end
	new("UIPadding",{
		PaddingLeft = UDim.new(0,16),
		PaddingRight = UDim.new(0,16),
		PaddingTop = UDim.new(0,10),
		PaddingBottom = UDim.new(0,10),
		Parent = row,
	})
	if title then
		local tl = label({
			Size = UDim2.new(1,0,0,18),
			Text = title,
			Font = Enum.Font.BuilderSansBold,
			TextSize = 14,
			LayoutOrder = 1,
			Parent = row,
		})
		regtheme(tl,"TextColor3","text")
	end
	local body = label({
		Size = UDim2.new(1,0,0,0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = text,
		Font = Enum.Font.BuilderSans,
		TextSize = 13,
		TextColor3 = theme.subtext,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		LayoutOrder = 2,
		Parent = row,
	})
	regtheme(body,"TextColor3","subtext")
	return {type = "paragraph",instance = body}
end

function section:divider(o)
	o = o or {}
	local order = (self._order or 0) + 1
	self._order = order
	local pad = o.padding or 8
	local wrap = new("Frame",{
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,pad * 2 + 1),
		LayoutOrder = order,
		Parent = self.body,
	})
	local line = new("Frame",{
		Position = UDim2.fromOffset(16,pad),
		Size = UDim2.new(1,-32,0,1),
		BackgroundColor3 = theme.divider,
		BorderSizePixel = 0,
		Parent = wrap,
	})
	regtheme(line,"BackgroundColor3","divider")
	return {type = "divider"}
end

function section:button(o)
	o = o or {}
	local row,header,title,desc = self:_row(o,(o.width or 96) + 40)
	local primary = o.primary == true
	local base = primary and alion.accent or theme.control
	local hover = primary and Color3.fromRGB(122,214,255) or theme.controlhover
	local b = new("TextButton",{
		AnchorPoint = Vector2.new(1,0.5),
		Position = UDim2.new(1,-16,0.5,0),
		Size = UDim2.fromOffset(o.width or 96,32),
		BackgroundColor3 = base,
		Text = o.buttontext or "Run",
		Font = Enum.Font.BuilderSansMedium,
		TextSize = 14,
		TextColor3 = primary and theme.accenttext or theme.text,
		AutoButtonColor = false,
		Parent = header,
	})
	corner(b,4)
	local bs = stroke(b,primary and alion.accent or theme.strokelight,1,primary and 1 or 0.5)
	if not primary then
		regtheme(b,"BackgroundColor3","control")
		regtheme(bs,"Color","strokelight")
	else
		regaccent(b)
	end
	local uiscale = new("UIScale",{Parent = b})
	track(b.MouseEnter:Connect(function() tween(b,ti(0.15),{BackgroundColor3 = hover}) end))
	track(b.MouseLeave:Connect(function()
		tween(b,ti(0.15),{BackgroundColor3 = base})
		tween(uiscale,ti(0.2),{Scale = 1})
	end))
	track(b.MouseButton1Down:Connect(function() tween(uiscale,ti(0.12),{Scale = 0.95}) end))
	track(b.MouseButton1Up:Connect(function() tween(uiscale,ti(0.3,Enum.EasingStyle.Back),{Scale = 1}) end))
	track(b.Activated:Connect(function() fire(o.callback) end))
	local obj = {type = "button"}
	function obj:settext(text) b.Text = text end
	return finishelement(obj,row,title,desc)
end

function section:toggle(o)
	o = o or {}
	local haskeybind = o.keybind ~= nil
	local reserve = haskeybind and 130 or 80
	local row,header,title,desc = self:_row(o,reserve)
	local state = o.value == true or o.default == true
	local hover,pressed = false,false
	local off = Color3.fromRGB(210,210,210)
	local trackframe = new("Frame",{
		AnchorPoint = Vector2.new(1,0.5),
		Position = UDim2.new(1,-16,0.5,0),
		Size = UDim2.fromOffset(40,20),
		BackgroundColor3 = alion.accent,
		BackgroundTransparency = state and 0 or 1,
		Parent = header,
	})
	corner(trackframe,100)
	local trackstroke = stroke(trackframe,state and alion.accent or Color3.fromRGB(160,160,160),1,0)
	local knob = new("Frame",{
		AnchorPoint = Vector2.new(0,0.5),
		Position = UDim2.new(0,state and 24 or 4,0.5,0),
		Size = UDim2.fromOffset(12,12),
		BackgroundColor3 = state and theme.accenttext or off,
		Parent = trackframe,
	})
	corner(knob,100)
	local hit = new("TextButton",{
		Size = UDim2.fromScale(1,1),
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
		tween(knob,info,{
			Size = UDim2.fromOffset(w,h),
			Position = UDim2.new(0,x,0.5,0),
			BackgroundColor3 = state and theme.accenttext or off,
		})
		tween(trackframe,info,{BackgroundTransparency = state and 0 or 1})
		tween(trackstroke,info,{Color = state and alion.accent or Color3.fromRGB(160,160,160)})
	end
	track(hit.MouseEnter:Connect(function() hover = true render() end))
	track(hit.MouseLeave:Connect(function() hover = false pressed = false render() end))
	track(hit.MouseButton1Down:Connect(function() pressed = true render() end))
	track(hit.MouseButton1Up:Connect(function() pressed = false render() end))
	local obj = {type = "toggle",value = state}
	local function set(v,silent)
		state = v and true or false
		obj.value = state
		render()
		setflag(self,o,state)
		if not silent then fire(o.callback,state) end
	end
	track(hit.Activated:Connect(function() set(not state) end))
	function obj:set(v) set(v) end
	function obj:get() return state end
	setflag(self,o,state)
	if haskeybind then
		local key = tokey(o.keybind)
		local chip = new("TextButton",{
			AnchorPoint = Vector2.new(1,0.5),
			Position = UDim2.new(1,-64,0.5,0),
			Size = UDim2.fromOffset(48,20),
			BackgroundColor3 = theme.input,
			Text = key and key.Name or "-",
			Font = Enum.Font.BuilderSansMedium,
			TextSize = 11,
			TextColor3 = theme.subtext,
			AutoButtonColor = false,
			Parent = header,
		})
		corner(chip,4)
		local chipstroke = stroke(chip,theme.stroke,1,0.4)
		regtheme(chip,"BackgroundColor3","input")
		regtheme(chip,"TextColor3","subtext")
		regtheme(chipstroke,"Color","stroke")
		track(chip.MouseEnter:Connect(function()
			tween(chip,ti(0.15),{BackgroundColor3 = theme.controlhover,TextColor3 = theme.text})
			tween(chipstroke,ti(0.15),{Color = alion.accent})
		end))
		track(chip.MouseLeave:Connect(function()
			tween(chip,ti(0.15),{BackgroundColor3 = theme.input,TextColor3 = theme.subtext})
			tween(chipstroke,ti(0.15),{Color = theme.stroke})
		end))
		local entry
		local function bindkey(k)
			if entry then
				for i,e in ipairs(alion._keybinds) do
					if e == entry then table.remove(alion._keybinds,i) break end
				end
			end
			key = k
			chip.Text = k.Name
			entry = {key = k,cb = function() set(not state) end}
			table.insert(alion._keybinds,entry)
		end
		if key then bindkey(key) end
		track(chip.Activated:Connect(function()
			chip.Text = "..."
			alion._capturingkeybind = function(k)
				if k == Enum.KeyCode.Escape then
					chip.Text = key and key.Name or "-"
					return
				end
				bindkey(k)
			end
		end))
		function obj:setkeybind(k) bindkey(tokey(k)) end
	end
	return finishelement(obj,row,title,desc)
end

function section:slider(o)
	o = o or {}
	local val = o.value
	local min,max,default
	if type(val) == "table" then
		min = val.min or 0
		max = val.max or 100
		default = val.default or min
	else
		min = o.min or 0
		max = o.max or 100
		default = o.default or (type(val) == "number" and val or min)
	end
	local inc = o.increment or 1
	local suffix = o.suffix or ""
	local value = math.clamp(default,min,max)
	local row,header,title,desc = self:_row(o,290)
	local valuelbl = label({
		AnchorPoint = Vector2.new(1,0.5),
		Position = UDim2.new(1,-184,0.5,0),
		Size = UDim2.fromOffset(64,20),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextSize = 13,
		TextColor3 = theme.subtext,
		Parent = header,
	})
	regtheme(valuelbl,"TextColor3","subtext")
	local hit = new("TextButton",{
		AnchorPoint = Vector2.new(1,0.5),
		Position = UDim2.new(1,-16,0.5,0),
		Size = UDim2.fromOffset(160,28),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = header,
	})
	local rail = new("Frame",{
		AnchorPoint = Vector2.new(0,0.5),
		Position = UDim2.new(0,9,0.5,0),
		Size = UDim2.new(1,-18,0,4),
		BackgroundColor3 = Color3.fromRGB(100,100,100),
		BorderSizePixel = 0,
		Parent = hit,
	})
	corner(rail,100)
	local fill = new("Frame",{
		Size = UDim2.fromScale(0,1),
		BackgroundColor3 = alion.accent,
		BorderSizePixel = 0,
		Parent = rail,
	})
	corner(fill,100)
	regaccent(fill)
	local knob = new("Frame",{
		AnchorPoint = Vector2.new(0.5,0.5),
		Position = UDim2.fromScale(0,0.5),
		Size = UDim2.fromOffset(18,18),
		BackgroundColor3 = Color3.fromRGB(69,69,69),
		Parent = rail,
	})
	corner(knob,100)
	stroke(knob,Color3.fromRGB(110,110,110),1,0.2)
	local core = new("Frame",{
		AnchorPoint = Vector2.new(0.5,0.5),
		Position = UDim2.fromScale(0.5,0.5),
		Size = UDim2.fromOffset(10,10),
		BackgroundColor3 = alion.accent,
		BorderSizePixel = 0,
		Parent = knob,
	})
	corner(core,100)
	regaccent(core)
	local function fmt(v) return tostring(math.floor(v * 1000 + 0.5) / 1000) .. suffix end
	local function render(animate)
		local rel = (value - min) / math.max(max - min,1e-9)
		local info = animate and ti(0.12,Enum.EasingStyle.Sine) or ti(0)
		tween(fill,info,{Size = UDim2.fromScale(rel,1)})
		tween(knob,info,{Position = UDim2.fromScale(rel,0.5)})
		valuelbl.Text = fmt(value)
	end
	render(false)
	local dragging = false
	local obj = {type = "slider",value = value}
	local function set(v,silent)
		v = math.clamp(min + math.floor((v - min) / inc + 0.5) * inc,min,max)
		if v == value and not silent then return end
		value = v
		obj.value = v
		render(true)
		setflag(self,o,v)
		if not silent then fire(o.callback,v) end
	end
	local function frominput(x)
		local rel = math.clamp((x - rail.AbsolutePosition.X) / math.max(rail.AbsoluteSize.X,1),0,1)
		set(min + rel * (max - min))
	end
	track(hit.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			tween(core,ti(0.15),{Size = UDim2.fromOffset(8,8)})
			frominput(i.Position.X)
		end
	end))
	track(hit.MouseEnter:Connect(function()
		if not dragging then tween(core,ti(0.15),{Size = UDim2.fromOffset(12,12)}) end
	end))
	track(hit.MouseLeave:Connect(function()
		if not dragging then tween(core,ti(0.15),{Size = UDim2.fromOffset(10,10)}) end
	end))
	track(input.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			frominput(i.Position.X)
		end
	end))
	track(input.InputEnded:Connect(function(i)
		if dragging and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			tween(core,ti(0.15),{Size = UDim2.fromOffset(10,10)})
		end
	end))
	function obj:set(v) set(v) end
	function obj:get() return value end
	setflag(self,o,value)
	return finishelement(obj,row,title,desc)
end

function section:progressbar(o)
	o = o or {}
	local val = o.value or 0
	local max = o.max or 100
	local row,header,title,desc = self:_row(o,290)
	local valuelbl = label({
		AnchorPoint = Vector2.new(1,0.5),
		Position = UDim2.new(1,-16,0.5,0),
		Size = UDim2.fromOffset(60,20),
		TextXAlignment = Enum.TextXAlignment.Right,
		TextSize = 13,
		TextColor3 = theme.subtext,
		Parent = header,
	})
	regtheme(valuelbl,"TextColor3","subtext")
	local rail = new("Frame",{
		AnchorPoint = Vector2.new(1,0.5),
		Position = UDim2.new(1,-84,0.5,0),
		Size = UDim2.fromOffset(160,6),
		BackgroundColor3 = Color3.fromRGB(100,100,100),
		BorderSizePixel = 0,
		Parent = header,
	})
	corner(rail,100)
	local fill = new("Frame",{
		Size = UDim2.fromScale(math.clamp(val / max,0,1),1),
		BackgroundColor3 = alion.accent,
		BorderSizePixel = 0,
		Parent = rail,
	})
	corner(fill,100)
	regaccent(fill)
	local function render()
		tween(fill,ti(0.25),{Size = UDim2.fromScale(math.clamp(val / max,0,1),1)})
		valuelbl.Text = string.format("%d%%",math.floor(val / max * 100 + 0.5))
	end
	render()
	local obj = {type = "progressbar"}
	function obj:set(v)
		val = v
		render()
		if o.callback then fire(o.callback,v) end
	end
	function obj:get() return val end
	return finishelement(obj,row,title,desc)
end

function section:dropdown(o)
	o = o or {}
	local multi = o.multi == true
	local options = o.options or {}
	local selected = {}
	local single = nil
	local def = o.value ~= nil and o.value or o.default
	if multi then
		for _,v in ipairs(def or {}) do selected[v] = true end
	else
		single = def
	end
	local row,header,title,desc = self:_row(o,214)
	local box = new("TextButton",{
		AnchorPoint = Vector2.new(1,0.5),
		Position = UDim2.new(1,-16,0.5,0),
		Size = UDim2.fromOffset(180,32),
		BackgroundColor3 = theme.control,
		Text = "",
		AutoButtonColor = false,
		Parent = header,
	})
	corner(box,4)
	local boxstroke = stroke(box,theme.strokelight,1,0.5)
	regtheme(box,"BackgroundColor3","control")
	regtheme(boxstroke,"Color","strokelight")
	local valuelbl = label({
		Position = UDim2.fromOffset(12,0),
		Size = UDim2.new(1,-38,1,0),
		TextSize = 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = box,
	})
	regtheme(valuelbl,"TextColor3","text")
	local chevron = icon({
		AnchorPoint = Vector2.new(1,0.5),
		Position = UDim2.new(1,-10,0.5,0),
		Size = UDim2.fromOffset(14,14),
		Parent = box,
	},"chevron-down",Color3.fromRGB(210,210,210))
	local list = new("Frame",{
		Name = "List",
		Size = UDim2.new(1,0,0,0),
		BackgroundColor3 = theme.input,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		LayoutOrder = 2,
		Parent = row,
	})
	corner(list,6)
	regtheme(list,"BackgroundColor3","input")
	local scroll = new("ScrollingFrame",{
		Size = UDim2.fromScale(1,1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Color3.fromRGB(110,110,110),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = list,
	})
	new("UIListLayout",{Padding = UDim.new(0,2),SortOrder = Enum.SortOrder.LayoutOrder,Parent = scroll})
	new("UIPadding",{
		PaddingTop = UDim.new(0,4),
		PaddingBottom = UDim.new(0,4),
		PaddingLeft = UDim.new(0,10),
		PaddingRight = UDim.new(0,10),
		Parent = scroll,
	})
	local entries = {}
	local open = false
	local obj = {type = "dropdown"}
	local function isselected(opt)
		if multi then return selected[opt] == true end
		return single == opt
	end
	local function currentvalue()
		if multi then
			local t = {}
			for _,v in ipairs(options) do if selected[v] then table.insert(t,v) end end
			return t
		end
		return single
	end
	local function display()
		if multi then
			local t = currentvalue()
			local names = {}
			for _,v in ipairs(t) do table.insert(names,tostring(v)) end
			valuelbl.Text = #names > 0 and table.concat(names,", ") or "None"
		else
			valuelbl.Text = single ~= nil and tostring(single) or "Select"
		end
		obj.value = currentvalue()
	end
	local function listheight() return math.min(#options * 34 + 6,196) end
	local function paint()
		for opt,e in pairs(entries) do
			local sel = isselected(opt)
			tween(e.bar,ti(0.25),{Size = UDim2.fromOffset(3,sel and 16 or 0)})
			tween(e.text,ti(0.25),{TextColor3 = sel and alion.accent or theme.text})
			tween(e.check,ti(0.25),{ImageTransparency = sel and 0 or 1})
			tween(e.button,ti(0.2),{BackgroundTransparency = sel and 0.93 or 1})
		end
	end
	local function setopen(v)
		open = v
		tween(list,ti(0.35),{Size = UDim2.new(1,0,0,v and listheight() or 0)})
		tween(chevron,ti(0.35),{Rotation = v and 180 or 0})
		tween(boxstroke,ti(0.25),{Color = v and alion.accent or theme.strokelight,Transparency = v and 0.2 or 0.5})
	end
	local function choose(opt)
		if multi then selected[opt] = not selected[opt] or nil
		else single = opt setopen(false) end
		display()
		paint()
		setflag(self,o,currentvalue())
		fire(o.callback,currentvalue())
	end
	local function build()
		for _,e in pairs(entries) do e.button:Destroy() end
		entries = {}
		for i,opt in ipairs(options) do
			local b = new("TextButton",{
				Name = tostring(opt),
				LayoutOrder = i,
				Size = UDim2.new(1,0,0,32),
				BackgroundColor3 = Color3.new(1,1,1),
				BackgroundTransparency = 1,
				Text = "",
				AutoButtonColor = false,
				Parent = scroll,
			})
			corner(b,4)
			local bar = new("Frame",{
				AnchorPoint = Vector2.new(0,0.5),
				Position = UDim2.new(0,0,0.5,0),
				Size = UDim2.fromOffset(3,0),
				BackgroundColor3 = alion.accent,
				BorderSizePixel = 0,
				Parent = b,
			})
			corner(bar,100)
			regaccent(bar)
			local txt = label({
				Position = UDim2.fromOffset(14,0),
				Size = UDim2.new(1,-44,1,0),
				Text = tostring(opt),
				TextSize = 13,
				TextTruncate = Enum.TextTruncate.AtEnd,
				Parent = b,
			})
			regtheme(txt,"TextColor3","text")
			local check = icon({
				AnchorPoint = Vector2.new(1,0.5),
				Position = UDim2.new(1,-12,0.5,0),
				Size = UDim2.fromOffset(14,14),
				ImageTransparency = 1,
				Parent = b,
			},"check",alion.accent)
			regaccent(check,"ImageColor3")
			entries[opt] = {button = b,bar = bar,text = txt,check = check}
			track(b.MouseEnter:Connect(function()
				if not isselected(opt) then tween(b,ti(0.15),{BackgroundTransparency = 0.95}) end
			end))
			track(b.MouseLeave:Connect(function()
				tween(b,ti(0.15),{BackgroundTransparency = isselected(opt) and 0.93 or 1})
			end))
			track(b.Activated:Connect(function() choose(opt) end))
		end
		display()
		paint()
		if open then tween(list,ti(0.3),{Size = UDim2.new(1,0,0,listheight())}) end
	end
	track(box.MouseEnter:Connect(function() tween(box,ti(0.15),{BackgroundColor3 = theme.controlhover}) end))
	track(box.MouseLeave:Connect(function() tween(box,ti(0.15),{BackgroundColor3 = theme.control}) end))
	track(box.Activated:Connect(function() setopen(not open) end))
	build()
	function obj:set(v)
		if multi then
			selected = {}
			for _,x in ipairs(v or {}) do selected[x] = true end
		else single = v end
		display()
		paint()
		setflag(self,o,currentvalue())
		fire(o.callback,currentvalue())
	end
	function obj:get() return currentvalue() end
	function obj:refresh(newoptions,keep)
		options = newoptions or {}
		if not keep then selected = {} single = nil end
		build()
	end
	setflag(self,o,currentvalue())
	return finishelement(obj,row,title,desc)
end

function section:input(o)
	o = o or {}
	local width = o.width or 200
	local row,header,title,desc = self:_row(o,width + 40)
	local box = new("Frame",{
		AnchorPoint = Vector2.new(1,0.5),
		Position = UDim2.new(1,-16,0.5,0),
		Size = UDim2.fromOffset(width,32),
		BackgroundColor3 = theme.input,
		ClipsDescendants = true,
		Parent = header,
	})
	corner(box,4)
	local boxstroke = stroke(box,theme.strokelight,1,0.4)
	regtheme(box,"BackgroundColor3","input")
	regtheme(boxstroke,"Color","strokelight")
	local tb = new("TextBox",{
		Position = UDim2.fromOffset(10,0),
		Size = UDim2.new(1,-20,1,-2),
		BackgroundTransparency = 1,
		Text = tostring(o.value or o.default or ""),
		PlaceholderText = o.placeholder or "Type here...",
		PlaceholderColor3 = Color3.fromRGB(125,125,125),
		TextColor3 = theme.text,
		Font = Enum.Font.BuilderSans,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
		Parent = box,
	})
	regtheme(tb,"TextColor3","text")
	local line = new("Frame",{
		AnchorPoint = Vector2.new(0.5,1),
		Position = UDim2.fromScale(0.5,1),
		Size = UDim2.new(0,0,0,2),
		BackgroundColor3 = alion.accent,
		BorderSizePixel = 0,
		Parent = box,
	})
	regaccent(line)
	track(tb.Focused:Connect(function()
		tween(line,ti(0.35),{Size = UDim2.new(1,0,0,2)})
		tween(boxstroke,ti(0.25),{Transparency = 0,Color = alion.accent})
	end))
	track(tb.FocusLost:Connect(function(enter)
		tween(line,ti(0.3,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{Size = UDim2.new(0,0,0,2)})
		tween(boxstroke,ti(0.25),{Transparency = 0.4,Color = theme.strokelight})
		setflag(self,o,tb.Text)
		fire(o.callback,tb.Text,enter)
	end))
	if o.numeric then
		track(tb:GetPropertyChangedSignal("Text"):Connect(function()
			local cleaned = tb.Text:gsub("[^%d%.%-]","")
			if cleaned ~= tb.Text then tb.Text = cleaned end
		end))
	end
	local obj = {type = "textbox"}
	function obj:set(v) tb.Text = tostring(v) setflag(self,o,tb.Text) end
	function obj:get() return tb.Text end
	setflag(self,o,tb.Text)
	return finishelement(obj,row,title,desc)
end

function section:keybind(o)
	o = o or {}
	local key = tokey(o.value or o.default or Enum.KeyCode.E)
	local row,header,title,desc = self:_row(o,170)
	local btn = new("TextButton",{
		AnchorPoint = Vector2.new(1,0.5),
		Position = UDim2.new(1,-16,0.5,0),
		Size = UDim2.fromOffset(120,32),
		BackgroundColor3 = theme.control,
		Text = key.Name,
		Font = Enum.Font.BuilderSansMedium,
		TextSize = 13,
		TextColor3 = theme.text,
		AutoButtonColor = false,
		Parent = header,
	})
	corner(btn,4)
	local btnstroke = stroke(btn,theme.strokelight,1,0.5)
	regtheme(btn,"BackgroundColor3","control")
	regtheme(btn,"TextColor3","text")
	regtheme(btnstroke,"Color","strokelight")
	local listening = false
	track(btn.MouseEnter:Connect(function() tween(btn,ti(0.15),{BackgroundColor3 = theme.controlhover}) end))
	track(btn.MouseLeave:Connect(function() tween(btn,ti(0.15),{BackgroundColor3 = theme.control}) end))
	track(btn.Activated:Connect(function()
		listening = true
		btn.Text = "Press a key..."
		tween(btnstroke,ti(0.2),{Color = alion.accent,Transparency = 0})
	end))
	local obj = {type = "keybind",value = key}
	track(input.InputBegan:Connect(function(i,processed)
		if listening then
			if i.UserInputType == Enum.UserInputType.Keyboard then
				listening = false
				if i.KeyCode ~= Enum.KeyCode.Escape then
					key = i.KeyCode
					obj.value = key
					setflag(self,o,key)
					fire(o.callback,key)
				end
				btn.Text = key.Name
				tween(btnstroke,ti(0.2),{Color = theme.strokelight,Transparency = 0.5})
			end
		elseif i.KeyCode == key then
			if input:GetFocusedTextBox() then return end
			fire(o.callback,key)
			if o.onpress then fire(o.onpress) end
		end
	end))
	function obj:set(k)
		key = tokey(k)
		obj.value = key
		btn.Text = key.Name
		setflag(self,o,key)
	end
	function obj:get() return key end
	setflag(self,o,key)
	return finishelement(obj,row,title,desc)
end

function section:colorpicker(o)
	o = o or {}
	local order = (self._order or 0) + 1
	self._order = order
	local current = o.default or o.value or alion.accent
	local initial = current
	local h,s,v = Color3.toHSV(current)
	local expanded = false
	local headh = 50
	local sqh = 130
	local hueh = 14
	local hexh = 26
	local bodypad = 12
	local spacing = 8
	local bodyh = bodypad * 2 + sqh + spacing + hueh + spacing + hexh
	local row = new("Frame",{
		Name = "ColorRow",
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = order,
		Parent = self.body,
	})
	new("UIListLayout",{SortOrder = Enum.SortOrder.LayoutOrder,Parent = row})
	if order > 1 then
		local div = new("Frame",{
			Name = "Divider",
			Size = UDim2.new(1,0,0,1),
			BackgroundColor3 = theme.divider,
			BorderSizePixel = 0,
			LayoutOrder = 0,
			Parent = row,
		})
		regtheme(div,"BackgroundColor3","divider")
	end
	local header = new("TextButton",{
		Name = "Header",
		Size = UDim2.new(1,0,0,headh),
		BackgroundColor3 = Color3.new(1,1,1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		LayoutOrder = 1,
		Parent = row,
	})
	track(header.MouseEnter:Connect(function()
		if not expanded then tween(header,ti(0.15),{BackgroundTransparency = 0.96}) end
	end))
	track(header.MouseLeave:Connect(function()
		if not expanded then tween(header,ti(0.15),{BackgroundTransparency = 1}) end
	end))
	local x = 16
	if o.icon then
		icon({
			AnchorPoint = Vector2.new(0,0.5),
			Position = UDim2.new(0,16,0.5,0),
			Size = UDim2.fromOffset(20,20),
			ImageColor3 = Color3.fromRGB(215,215,215),
			Parent = header,
		},o.icon)
		x = 48
	end
	local titlelbl = label({
		Position = UDim2.fromOffset(x,o.desc and 11 or 0),
		Size = o.desc and UDim2.new(1,-(x + 130),0,18) or UDim2.new(1,-(x + 130),1,0),
		Text = o.title or "Color",
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = header,
	})
	regtheme(titlelbl,"TextColor3","text")
	local desclbl
	if o.desc then
		desclbl = label({
			Position = UDim2.fromOffset(x,31),
			Size = UDim2.new(1,-(x + 130),0,18),
			Text = o.desc,
			Font = Enum.Font.BuilderSans,
			TextSize = 12,
			TextColor3 = theme.subtext,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = header,
		})
		regtheme(desclbl,"TextColor3","subtext")
	end
	local preview = new("Frame",{
		AnchorPoint = Vector2.new(1,0.5),
		Position = UDim2.new(1,-46,0.5,0),
		Size = UDim2.fromOffset(56,24),
		BackgroundColor3 = current,
		Parent = header,
	})
	corner(preview,4)
	stroke(preview,theme.strokelight,1,0.3)
	local arrowwrap = new("Frame",{
		AnchorPoint = Vector2.new(1,0.5),
		Position = UDim2.new(1,-16,0.5,0),
		Size = UDim2.fromOffset(20,20),
		BackgroundTransparency = 1,
		Parent = header,
	})
	local arrow = icon({
		AnchorPoint = Vector2.new(0.5,0.5),
		Position = UDim2.fromScale(0.5,0.5),
		Size = UDim2.fromOffset(14,14),
		Parent = arrowwrap,
	},"chevron-down",Color3.fromRGB(210,210,210))
	local body = new("Frame",{
		Name = "Body",
		Size = UDim2.new(1,0,0,0),
		BackgroundColor3 = theme.input,
		BackgroundTransparency = 0.15,
		ClipsDescendants = true,
		LayoutOrder = 2,
		Parent = row,
	})
	corner(body,6)
	local bstroke = stroke(body,theme.stroke,1,0.35)
	regtheme(body,"BackgroundColor3","input")
	regtheme(bstroke,"Color","stroke")
	local satsquare = new("Frame",{
		Size = UDim2.new(1,-bodypad * 2,0,sqh),
		Position = UDim2.new(0,bodypad,0,bodypad),
		BackgroundColor3 = Color3.fromHSV(h,1,1),
		BorderSizePixel = 0,
		Active = true,
		Parent = body,
	})
	corner(satsquare,4)
	local whitelayer = new("Frame",{
		Size = UDim2.fromScale(1,1),
		BackgroundColor3 = Color3.new(1,1,1),
		BorderSizePixel = 0,
		Parent = satsquare,
	})
	corner(whitelayer,4)
	new("UIGradient",{
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0,0),
			NumberSequenceKeypoint.new(1,1),
		}),
		Parent = whitelayer,
	})
	local blacklayer = new("Frame",{
		Size = UDim2.fromScale(1,1),
		BackgroundColor3 = Color3.new(0,0,0),
		BorderSizePixel = 0,
		Parent = satsquare,
	})
	corner(blacklayer,4)
	new("UIGradient",{
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0,1),
			NumberSequenceKeypoint.new(1,0),
		}),
		Parent = blacklayer,
	})
	local satcursor = new("Frame",{
		Size = UDim2.fromOffset(12,12),
		AnchorPoint = Vector2.new(0.5,0.5),
		Position = UDim2.new(s,0,1 - v,0),
		BackgroundTransparency = 1,
		ZIndex = 5,
		Parent = satsquare,
	})
	corner(satcursor,100)
	stroke(satcursor,Color3.new(1,1,1),2,0)
	stroke(satcursor,Color3.new(0,0,0),1,0.5)
	local hueslider = new("Frame",{
		Size = UDim2.new(1,-bodypad * 2,0,hueh),
		Position = UDim2.new(0,bodypad,0,bodypad + sqh + spacing),
		BackgroundColor3 = Color3.new(1,1,1),
		BorderSizePixel = 0,
		Active = true,
		Parent = body,
	})
	corner(hueslider,100)
	new("UIGradient",{
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0 / 6,Color3.fromRGB(255,0,0)),
			ColorSequenceKeypoint.new(1 / 6,Color3.fromRGB(255,255,0)),
			ColorSequenceKeypoint.new(2 / 6,Color3.fromRGB(0,255,0)),
			ColorSequenceKeypoint.new(3 / 6,Color3.fromRGB(0,255,255)),
			ColorSequenceKeypoint.new(4 / 6,Color3.fromRGB(0,0,255)),
			ColorSequenceKeypoint.new(5 / 6,Color3.fromRGB(255,0,255)),
			ColorSequenceKeypoint.new(6 / 6,Color3.fromRGB(255,0,0)),
		}),
		Parent = hueslider,
	})
	local huecursor = new("Frame",{
		Size = UDim2.new(0,4,1,6),
		AnchorPoint = Vector2.new(0.5,0.5),
		Position = UDim2.new(h,0,0.5,0),
		BackgroundColor3 = Color3.new(1,1,1),
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = hueslider,
	})
	corner(huecursor,100)
	stroke(huecursor,Color3.new(0,0,0),1,0.4)
	local hexbox = new("TextBox",{
		Size = UDim2.new(1,-bodypad * 2 - 92,0,hexh),
		Position = UDim2.new(0,bodypad,0,bodypad + sqh + spacing + hueh + spacing),
		BackgroundColor3 = theme.control,
		BorderSizePixel = 0,
		Text = string.format("#%02X%02X%02X",math.floor(current.R * 255),math.floor(current.G * 255),math.floor(current.B * 255)),
		TextColor3 = theme.text,
		TextSize = 13,
		Font = Enum.Font.BuilderSansMedium,
		ClearTextOnFocus = false,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = body,
	})
	corner(hexbox,4)
	local hbstroke = stroke(hexbox,theme.stroke,1,0.4)
	regtheme(hexbox,"BackgroundColor3","control")
	regtheme(hexbox,"TextColor3","text")
	regtheme(hbstroke,"Color","stroke")
	new("UIPadding",{PaddingLeft = UDim.new(0,10),Parent = hexbox})
	local resetbtn = new("TextButton",{
		Size = UDim2.new(0,84,0,hexh),
		Position = UDim2.new(1,-bodypad - 84,0,bodypad + sqh + spacing + hueh + spacing),
		BackgroundColor3 = theme.control,
		BorderSizePixel = 0,
		Text = "Reset",
		Font = Enum.Font.BuilderSansMedium,
		TextSize = 13,
		TextColor3 = theme.text,
		AutoButtonColor = false,
		Parent = body,
	})
	corner(resetbtn,4)
	local rbstroke = stroke(resetbtn,theme.stroke,1,0.4)
	regtheme(resetbtn,"BackgroundColor3","control")
	regtheme(resetbtn,"TextColor3","text")
	regtheme(rbstroke,"Color","stroke")
	track(resetbtn.MouseEnter:Connect(function()
		tween(resetbtn,ti(0.15),{BackgroundColor3 = theme.controlhover})
		tween(rbstroke,ti(0.15),{Color = alion.accent,Transparency = 0.2})
	end))
	track(resetbtn.MouseLeave:Connect(function()
		tween(resetbtn,ti(0.15),{BackgroundColor3 = theme.control})
		tween(rbstroke,ti(0.15),{Color = theme.stroke,Transparency = 0.4})
	end))
	local magnifier
	local function hextext()
		return string.format("#%02X%02X%02X",math.floor(current.R * 255),math.floor(current.G * 255),math.floor(current.B * 255))
	end
	local function refreshall()
		satsquare.BackgroundColor3 = Color3.fromHSV(h,1,1)
		satcursor.Position = UDim2.new(s,0,1 - v,0)
		huecursor.Position = UDim2.new(h,0,0.5,0)
		preview.BackgroundColor3 = current
		hexbox.Text = hextext()
	end
	local function showmagnifier()
		if not magnifier then
			local sg = alion._gui
			if not sg or not sg.Parent then return end
			magnifier = new("Frame",{
				Name = "AlionPickerMagnifier",
				Size = UDim2.new(0,0,0,0),
				AnchorPoint = Vector2.new(0.5,0.5),
				BackgroundColor3 = current,
				BorderSizePixel = 0,
				ZIndex = 500,
				Parent = sg,
			})
			corner(magnifier,100)
			stroke(magnifier,Color3.new(1,1,1),2,0)
			tweenservice:Create(magnifier,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
				Size = UDim2.new(0,90,0,90),
			}):Play()
		end
		if magnifier and magnifier.Parent then
			magnifier.BackgroundColor3 = current
			local mp = input:GetMouseLocation()
			magnifier.Position = UDim2.new(0,mp.X,0,mp.Y - 78)
		end
	end
	local function hidemagnifier()
		if magnifier then
			local m = magnifier
			magnifier = nil
			tweenservice:Create(m,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{
				Size = UDim2.new(0,0,0,0),
				BackgroundTransparency = 1,
			}):Play()
			task.delay(0.25,function()
				if m and m.Parent then pcall(function() m:Destroy() end) end
			end)
		end
	end
	local draggingsat,dragginghue = false,false
	local function updatefromsat(i)
		if not satsquare.Parent then return end
		local relx = math.clamp((i.Position.X - satsquare.AbsolutePosition.X) / satsquare.AbsoluteSize.X,0,1)
		local rely = math.clamp((i.Position.Y - satsquare.AbsolutePosition.Y) / satsquare.AbsoluteSize.Y,0,1)
		s = relx
		v = 1 - rely
		current = Color3.fromHSV(h,s,v)
		refreshall()
		fire(o.callback,current)
	end
	local function updatefromhue(i)
		if not hueslider.Parent then return end
		local relx = math.clamp((i.Position.X - hueslider.AbsolutePosition.X) / hueslider.AbsoluteSize.X,0,1)
		h = relx
		current = Color3.fromHSV(h,s,v)
		refreshall()
		fire(o.callback,current)
	end
	track(satsquare.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			draggingsat = true
			updatefromsat(i)
			showmagnifier()
		end
	end))
	track(hueslider.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragginghue = true
			updatefromhue(i)
		end
	end))
	track(input.InputChanged:Connect(function(i)
		if draggingsat and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			updatefromsat(i)
			showmagnifier()
		end
		if dragginghue and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			updatefromhue(i)
		end
	end))
	track(input.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			if draggingsat then draggingsat = false hidemagnifier() end
			if dragginghue then dragginghue = false end
		end
	end))
	track(hexbox.Focused:Connect(function() tween(hbstroke,ti(0.15),{Color = alion.accent,Transparency = 0}) end))
	track(hexbox.FocusLost:Connect(function()
		tween(hbstroke,ti(0.15),{Color = theme.stroke,Transparency = 0.4})
		local hex = hexbox.Text:gsub("#","")
		if #hex == 6 then
			local rn = tonumber(hex:sub(1,2),16)
			local gn = tonumber(hex:sub(3,4),16)
			local bn = tonumber(hex:sub(5,6),16)
			if rn and gn and bn then
				current = Color3.fromRGB(rn,gn,bn)
				h,s,v = Color3.toHSV(current)
				refreshall()
				fire(o.callback,current)
			end
		end
	end))
	local function setexpanded(state)
		expanded = state
		local target = expanded and bodyh or 0
		tween(body,ti(0.35,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{Size = UDim2.new(1,0,0,target)})
		tween(arrow,ti(0.3),{Rotation = expanded and 180 or 0})
	end
	track(header.Activated:Connect(function() setexpanded(not expanded) end))
	track(resetbtn.Activated:Connect(function()
		current = initial
		h,s,v = Color3.toHSV(current)
		refreshall()
		fire(o.callback,current)
	end))
	refreshall()
	local obj = {type = "colorpicker",value = current}
	function obj:get() return current end
	function obj:set(c)
		current = c
		h,s,v = Color3.toHSV(c)
		refreshall()
		fire(o.callback,c)
	end
	function obj:setdefault(c) initial = c end
	function obj:reset() obj:set(initial) end
	function obj:expand() if not expanded then setexpanded(true) end end
	function obj:collapse() if expanded then setexpanded(false) end end
	return finishelement(obj,row,titlelbl,desclbl)
end

function section:characterpreview(o)
	o = o or {}
	local order = (self._order or 0) + 1
	self._order = order
	local size = o.size or 140
	local mode = o.mode or "head"
	local row = new("Frame",{
		Name = "CharPreviewRow",
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = order,
		Parent = self.body,
	})
	new("UIListLayout",{SortOrder = Enum.SortOrder.LayoutOrder,Parent = row})
	if order > 1 then
		local div = new("Frame",{
			Size = UDim2.new(1,0,0,1),
			BackgroundColor3 = theme.divider,
			BorderSizePixel = 0,
			LayoutOrder = 0,
			Parent = row,
		})
		regtheme(div,"BackgroundColor3","divider")
	end
	local header = new("Frame",{
		Name = "Header",
		Size = UDim2.new(1,0,0,48),
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = row,
	})
	new("UIPadding",{PaddingLeft = UDim.new(0,16),PaddingRight = UDim.new(0,16),Parent = header})
	local titlelbl = label({
		Size = UDim2.new(1,0,1,0),
		Text = o.title or "Preview",
		TextColor3 = theme.text,
		Parent = header,
	})
	regtheme(titlelbl,"TextColor3","text")
	local holder = new("Frame",{
		Size = UDim2.new(1,0,0,size),
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = row,
	})
	new("UIPadding",{
		PaddingLeft = UDim.new(0,16),
		PaddingRight = UDim.new(0,16),
		PaddingBottom = UDim.new(0,12),
		Parent = holder,
	})
	local canvas = new("Frame",{
		AnchorPoint = Vector2.new(0.5,0.5),
		Position = UDim2.fromScale(0.5,0.5),
		Size = UDim2.fromOffset(size,size),
		BackgroundColor3 = theme.input,
		BackgroundTransparency = 0.35,
		Parent = holder,
	})
	corner(canvas,8)
	local cs = stroke(canvas,theme.stroke,1,0.35)
	regtheme(canvas,"BackgroundColor3","input")
	regtheme(cs,"Color","stroke")
	local vp = makecharview({
		parent = canvas,
		size = UDim2.new(1,-4,1,-4),
		target = o.target or player,
		mode = mode,
		spin = o.spin ~= false,
		spinspeed = o.spinspeed or 40,
		startangle = o.startangle,
		fov = o.fov,
		distance = o.distance,
		lookheight = o.lookheight,
	})
	vp.instance.Position = UDim2.fromOffset(2,2)
	local obj = {type = "characterpreview",viewport = vp}
	function obj:settarget(t) vp:settarget(t) end
	function obj:setspeed(v) vp:setspeed(v) end
	function obj:destroy()
		vp:destroy()
		row:Destroy()
	end
	return obj
end

function section:characterbutton(o)
	o = o or {}
	local row,header,title,desc = self:_row(o,96)
	local size = o.iconsize or 60
	local slot = new("Frame",{
		AnchorPoint = Vector2.new(1,0.5),
		Position = UDim2.new(1,-16,0.5,0),
		Size = UDim2.fromOffset(size,size),
		BackgroundColor3 = theme.input,
		BackgroundTransparency = 0.35,
		Parent = header,
	})
	corner(slot,8)
	local ss = stroke(slot,theme.stroke,1,0.35)
	regtheme(slot,"BackgroundColor3","input")
	regtheme(ss,"Color","stroke")
	local vp = makecharview({
		parent = slot,
		size = UDim2.new(1,-4,1,-4),
		target = o.target or player,
		mode = "head",
		spin = o.spin ~= false,
		spinspeed = o.spinspeed or 40,
		fov = o.fov,
	})
	vp.instance.Position = UDim2.fromOffset(2,2)
	local hit = new("TextButton",{
		Size = UDim2.fromScale(1,1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Parent = header,
	})
	local uiscale = new("UIScale",{Parent = slot})
	track(hit.MouseEnter:Connect(function()
		tween(slot,ti(0.15),{BackgroundTransparency = 0.1})
		tween(uiscale,ti(0.2),{Scale = 1.05})
	end))
	track(hit.MouseLeave:Connect(function()
		tween(slot,ti(0.15),{BackgroundTransparency = 0.35})
		tween(uiscale,ti(0.2),{Scale = 1})
	end))
	track(hit.MouseButton1Down:Connect(function() tween(uiscale,ti(0.12),{Scale = 0.95}) end))
	track(hit.MouseButton1Up:Connect(function() tween(uiscale,ti(0.3,Enum.EasingStyle.Back),{Scale = 1.05}) end))
	track(hit.Activated:Connect(function() fire(o.callback,vp) end))
	local obj = {type = "characterbutton",viewport = vp}
	function obj:settarget(t) vp:settarget(t) end
	function obj:destroy()
		vp:destroy()
		row:Destroy()
	end
	return finishelement(obj,row,title,desc)
end

function section:avatargrid(o)
	o = o or {}
	local order = (self._order or 0) + 1
	self._order = order
	local cols = o.columns or 4
	local cellsize = o.cellsize or 96
	local row = new("Frame",{
		Name = "AvatarGridRow",
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = order,
		Parent = self.body,
	})
	if order > 1 then
		local div = new("Frame",{
			Size = UDim2.new(1,0,0,1),
			BackgroundColor3 = theme.divider,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(0,0),
			Parent = row,
		})
		regtheme(div,"BackgroundColor3","divider")
		new("UIPadding",{PaddingTop = UDim.new(0,1),Parent = row})
	end
	local header = new("Frame",{
		Name = "Header",
		Size = UDim2.new(1,0,0,48),
		BackgroundTransparency = 1,
		Parent = row,
	})
	if o.title then
		new("UIPadding",{PaddingLeft = UDim.new(0,16),PaddingRight = UDim.new(0,16),Parent = header})
		local ht = label({
			Size = UDim2.new(1,0,1,0),
			Text = o.title,
			TextColor3 = theme.text,
			Parent = header,
		})
		regtheme(ht,"TextColor3","text")
	end
	local grid = new("Frame",{
		Position = UDim2.fromOffset(0,o.title and 48 or 0),
		Size = UDim2.new(1,0,0,0),
		BackgroundTransparency = 1,
		Parent = row,
	})
	new("UIPadding",{
		PaddingLeft = UDim.new(0,16),
		PaddingRight = UDim.new(0,16),
		PaddingBottom = UDim.new(0,12),
		Parent = grid,
	})
	local layout = new("UIGridLayout",{
		CellSize = UDim2.fromOffset(cellsize,cellsize + 22),
		CellPadding = UDim2.fromOffset(8,8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = grid,
	})
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		grid.Size = UDim2.new(1,0,0,layout.AbsoluteContentSize.Y + 12)
	end)
	grid.Size = UDim2.new(1,0,0,layout.AbsoluteContentSize.Y + 12)
	row.Size = UDim2.new(1,0,0,(o.title and 48 or 0) + layout.AbsoluteContentSize.Y + 12)
	local cells = {}
	local obj = {type = "avatargrid"}
	local function buildcell(entry,index)
		local cell = new("Frame",{
			LayoutOrder = index,
			BackgroundColor3 = theme.input,
			BackgroundTransparency = 0.35,
			Parent = grid,
		})
		corner(cell,8)
		local cs = stroke(cell,theme.stroke,1,0.35)
		regtheme(cell,"BackgroundColor3","input")
		regtheme(cs,"Color","stroke")
		local target = entry.target or entry.userid or entry
		local vp = makecharview({
			parent = cell,
			size = UDim2.new(1,-4,1,-26),
			target = target,
			mode = "head",
			spin = true,
			spinspeed = 40,
			fov = 22,
		})
		vp.instance.Position = UDim2.fromOffset(2,2)
		local namelbl = label({
			AnchorPoint = Vector2.new(0.5,1),
			Position = UDim2.new(0.5,0,1,-2),
			Size = UDim2.new(1,-8,0,20),
			Text = entry.name or "Player",
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextColor3 = theme.subtext,
			Parent = cell,
		})
		regtheme(namelbl,"TextColor3","subtext")
		local hit = new("TextButton",{
			Size = UDim2.fromScale(1,1),
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			Parent = cell,
		})
		track(hit.MouseEnter:Connect(function() tween(cell,ti(0.15),{BackgroundTransparency = 0.1}) end))
		track(hit.MouseLeave:Connect(function() tween(cell,ti(0.15),{BackgroundTransparency = 0.35}) end))
		track(hit.Activated:Connect(function() fire(o.callback,entry,vp,index) end))
		cells[index] = {frame = cell,viewport = vp,label = namelbl,entry = entry}
		return cells[index]
	end
	function obj:setentries(entries)
		for _,c in ipairs(cells) do
			c.viewport:destroy()
			c.frame:Destroy()
		end
		cells = {}
		for i,e in ipairs(entries or {}) do buildcell(e,i) end
		grid.Size = UDim2.new(1,0,0,layout.AbsoluteContentSize.Y + 12)
		row.Size = UDim2.new(1,0,0,(o.title and 48 or 0) + layout.AbsoluteContentSize.Y + 12)
	end
	function obj:getcells() return cells end
	if o.entries then obj:setentries(o.entries) end
	return obj
end

return alion
