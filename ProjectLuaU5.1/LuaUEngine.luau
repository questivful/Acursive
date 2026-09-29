local Icons = {
	Keyword = "rbxassetid://138943211585672",
	Function = "rbxassetid://127323245193020",
	Global = "rbxassetid://131643180461501",
	Library = "rbxassetid://90462068188809",
	Class = "rbxassetid://87746604961029",
	Constructor = "rbxassetid://131992096470555",
	Variable = "rbxassetid://109933348812399",
	ScrollArrow = "rbxassetid://5279719038",
	FindTopChevron = "rbxassetid://81817462736641",
	FindBottomChevron = "rbxassetid://81817462736641",
	FindPrev = "rbxassetid://123393842142851",
	FindNext = "rbxassetid://71631858247362",
	FindClose = "rbxassetid://80750399461762",
	FindMatchCase = "rbxassetid://108524879613542",
	FindWholeWord = "rbxassetid://137472614441080",
	FindRegex = "rbxassetid://79087075619950",
	Fold = "rbxassetid://5642383285"
}

local Baseline = {
	Instances = {},
	Clipboard = ""
}

Baseline.__index = Baseline

local GlobalSettings = {
	MultiLine = true,
	Wrapped = false,
	SmoothBlinker = true,
	Minimap = true,
	Text = "",
	TextSize = 14,
	Font = Enum.Font.Code,
	TextColor3 = Color3.new(1, 1, 1),
	BlinkerColor3 = Color3.new(1, 1, 1),
	HighlightColor = Color3.fromRGB(37, 100, 200),
	PlaceholderText = 'Print("Paper Client :D")',
	PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
	PasswordMode = false,
	ReadOnly = false,
	HideScrollbars = false,
	TabIndex = 0,
	Lines = true,
	LineNumberColor3 = Color3.fromRGB(130, 130, 130),
	AutoHeight = false,
	BackgroundColor3 = Color3.fromRGB(30, 30, 30),
	BackgroundTransparency = 0,
	StrokeColor3 = Color3.fromRGB(0, 0, 0),
	StrokeTransparency = 0.92,
	StrokeThickness = 0,
	IndentGuideColor3 = Color3.fromRGB(58, 58, 58),
	IndentGuideTransparency = 0.35,
	IndentGuideThickness = 1,
	ScrollBarTrackColor3 = Color3.fromRGB(35, 35, 35),
	ScrollBarTrackTransparency = 0,
	ScrollBarThumbColor3 = Color3.fromRGB(60, 60, 60),
	ScrollBarThumbTransparency = 0,
	ScrollBarHoverColor3 = Color3.fromRGB(75, 75, 75),
	ScrollBarPressColor3 = Color3.fromRGB(40, 40, 40),
	ScrollBarImageColor3 = Color3.fromRGB(160, 160, 160),
	ScrollBarStrokeColor3 = Color3.fromRGB(33, 33, 33),
	ScrollBarStrokeTransparency = 0
}

local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local KeyMaps = {
	Operators = {
		["+"] = "op_add", ["-"] = "op_sub", ["*"] = "op_mul", ["/"] = "op_div",
		["^"] = "op_pow", ["%"] = "op_mod", ["=="] = "op_eq", ["~="] = "op_neq",
		["<="] = "op_le", [">="] = "op_ge", ["<"] = "op_lt", [">"] = "op_gt",
		["="] = "op_assign", [".."] = "op_concat", ["#"] = "op_len",
		[":"] = "op_colon", ["&"] = "op_ampersand", ["|"] = "op_pipe", ["?"] = "op_question"
	},
	Shift = {
		[Enum.KeyCode.One] = "!", [Enum.KeyCode.Two] = "@", [Enum.KeyCode.Three] = "#",
		[Enum.KeyCode.Four] = "$", [Enum.KeyCode.Five] = "%", [Enum.KeyCode.Six] = "^",
		[Enum.KeyCode.Seven] = "&", [Enum.KeyCode.Eight] = "*", [Enum.KeyCode.Nine] = "(",
		[Enum.KeyCode.Zero] = ")", [Enum.KeyCode.Minus] = "_", [Enum.KeyCode.Equals] = "+",
		[Enum.KeyCode.LeftBracket] = "{", [Enum.KeyCode.RightBracket] = "}",
		[Enum.KeyCode.BackSlash] = "|", [Enum.KeyCode.Semicolon] = ":",
		[Enum.KeyCode.Quote] = '\"', [Enum.KeyCode.Comma] = "<",
		[Enum.KeyCode.Period] = ">", [Enum.KeyCode.Slash] = "?", [Enum.KeyCode.Backquote] = "~"
	},
	Unshift = {
		[Enum.KeyCode.One] = "1", [Enum.KeyCode.Two] = "2", [Enum.KeyCode.Three] = "3",
		[Enum.KeyCode.Four] = "4", [Enum.KeyCode.Five] = "5", [Enum.KeyCode.Six] = "6",
		[Enum.KeyCode.Seven] = "7", [Enum.KeyCode.Eight] = "8", [Enum.KeyCode.Nine] = "9",
		[Enum.KeyCode.Zero] = "0", [Enum.KeyCode.Minus] = "-", [Enum.KeyCode.Equals] = "=",
		[Enum.KeyCode.LeftBracket] = "[", [Enum.KeyCode.RightBracket] = "]",
		[Enum.KeyCode.BackSlash] = "\\", [Enum.KeyCode.Semicolon] = ";",
		[Enum.KeyCode.Quote] = "'", [Enum.KeyCode.Comma] = ",",
		[Enum.KeyCode.Period] = ".", [Enum.KeyCode.Slash] = "/",
		[Enum.KeyCode.Backquote] = "`", [Enum.KeyCode.Space] = " ",
		[Enum.KeyCode.KeypadOne] = "1", [Enum.KeyCode.KeypadTwo] = "2",
		[Enum.KeyCode.KeypadThree] = "3", [Enum.KeyCode.KeypadFour] = "4",
		[Enum.KeyCode.KeypadFive] = "5", [Enum.KeyCode.KeypadSix] = "6",
		[Enum.KeyCode.KeypadSeven] = "7", [Enum.KeyCode.KeypadEight] = "8",
		[Enum.KeyCode.KeypadNine] = "9", [Enum.KeyCode.KeypadZero] = "0",
		[Enum.KeyCode.KeypadDivide] = "/", [Enum.KeyCode.KeypadMultiply] = "*",
		[Enum.KeyCode.KeypadMinus] = "-", [Enum.KeyCode.KeypadPlus] = "+"
	},
	SinkKeys = {
		Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
		Enum.KeyCode.Space, Enum.KeyCode.Up, Enum.KeyCode.Down,
		Enum.KeyCode.Left, Enum.KeyCode.Right, Enum.KeyCode.I,
		Enum.KeyCode.O, Enum.KeyCode.Backspace, Enum.KeyCode.Return,
		Enum.KeyCode.C, Enum.KeyCode.V, Enum.KeyCode.X, Enum.KeyCode.Z,
		Enum.KeyCode.Y, Enum.KeyCode.Home, Enum.KeyCode.End,
		Enum.KeyCode.PageUp, Enum.KeyCode.PageDown, Enum.KeyCode.Tab
	}
}

local Utils = {}
Utils.AutocompleteKeywords = {}

local function generateKeywords(list, typeName, iconId)
	for _, word in ipairs(list) do
		table.insert(Utils.AutocompleteKeywords, {word = word, type = typeName, icon = iconId})
	end
end

generateKeywords({"and", "break", "do", "else", "elseif", "end", "false", "for", "function", "if", "in", "local", "nil", "not", "or", "repeat", "return", "then", "true", "until", "while"}, "Keyword", Icons.Keyword)
generateKeywords({"print", "warn", "error", "assert", "require"}, "Function", Icons.Function)
generateKeywords({"game", "workspace", "script", "shared", "_G", "plugin"}, "Global", Icons.Global)
generateKeywords({"math", "string", "table", "task", "coroutine", "os", "debug", "utf8"}, "Library", Icons.Library)
generateKeywords({"math.abs", "math.acos", "math.asin", "math.atan", "math.atan2", "math.ceil", "math.clamp", "math.cos", "math.cosh", "math.deg", "math.exp", "math.floor", "math.fmod", "math.frexp", "math.ldexp", "math.log", "math.log10", "math.max", "math.min", "math.modf", "math.noise", "math.pi", "math.pow", "math.rad", "math.random", "math.randomseed", "math.round", "math.sign", "math.sin", "math.sinh", "math.sqrt", "math.tan", "math.tanh"}, "Function", Icons.Function)
generateKeywords({"table.concat", "table.insert", "table.remove", "table.sort", "table.create", "table.find", "table.clear", "table.pack", "table.unpack", "table.foreach", "table.foreachi", "table.getn"}, "Function", Icons.Function)
generateKeywords({"string.byte", "string.char", "string.find", "string.format", "string.gmatch", "string.gsub", "string.len", "string.lower", "string.match", "string.pack", "string.packsize", "string.rep", "string.reverse", "string.split", "string.sub", "string.unpack", "string.upper"}, "Function", Icons.Function)
generateKeywords({"task.spawn", "task.defer", "task.delay", "task.wait", "task.cancel"}, "Function", Icons.Function)
generateKeywords({"coroutine.create", "coroutine.resume", "coroutine.running", "coroutine.status", "coroutine.wrap", "coroutine.yield", "coroutine.isyieldable", "coroutine.close"}, "Function", Icons.Function)
generateKeywords({"Instance", "Vector3", "Vector2", "CFrame", "Color3", "UDim2", "UDim", "Ray", "TweenInfo", "Enum", "ColorSequence", "NumberSequence", "NumberRange", "Rect", "Faces", "Axes"}, "Class", Icons.Class)
generateKeywords({"Instance.new", "Vector3.new", "Vector3.zero", "Vector3.one", "Vector3.xAxis", "Vector3.yAxis", "Vector3.zAxis", "Vector2.new", "Vector2.zero", "Vector2.one", "Vector2.xAxis", "Vector2.yAxis", "CFrame.new", "CFrame.Angles", "CFrame.lookAt", "CFrame.identity", "Color3.new", "Color3.fromRGB", "Color3.fromHSV", "Color3.fromHex", "UDim2.new", "UDim2.fromOffset", "UDim2.fromScale", "UDim.new", "TweenInfo.new", "Ray.new"}, "Constructor", Icons.Constructor)

function Utils.getWordBeforeCursor(text, cursorIndex)
	local before = text:sub(1, cursorIndex)
	local word = before:match("[%w_%.]+$")
	return word or ""
end

function Utils.needsEnd(line)
	if line:match("if%s+.*then%s*$") then return true end
	if line:match("elseif%s+.*then%s*$") then return true end
	if line:match("while%s+.*do%s*$") then return true end
	if line:match("for%s+.*do%s*$") then return true end
	if line:match("function%s*.*%(.*%)%s*$") then return true end
	if line:match("^%s*do%s*$") then return true end
	return false
end

Utils.DummyLabel = Instance.new("TextLabel")

function Utils.getTextSize(text, size, font, limit)
	if typeof(font) == "Font" then
		Utils.DummyLabel.Text = text
		Utils.DummyLabel.TextSize = size
		Utils.DummyLabel.FontFace = font
		Utils.DummyLabel.Size = UDim2.new(0, limit.X, 0, limit.Y)
		return Utils.DummyLabel.TextBounds
	else
		return TextService:GetTextSize(text, size, font, limit)
	end
end

function Utils.getCharacter(keyCode, isShiftDown)
	if keyCode.Value >= Enum.KeyCode.A.Value and keyCode.Value <= Enum.KeyCode.Z.Value then
		local keyString = UserInputService:GetStringForKeyCode(keyCode)
		if isShiftDown then
			return keyString:upper()
		else
			return keyString:lower()
		end
	end
	if isShiftDown and KeyMaps.Shift[keyCode] then return KeyMaps.Shift[keyCode] end
	if KeyMaps.Unshift[keyCode] then return KeyMaps.Unshift[keyCode] end
	return ""
end

function Utils.escapeRichText(rawString)
	local s = string.gsub(rawString, "&", "&amp;")
	s = string.gsub(s, "<", "&lt;")
	s = string.gsub(s, ">", "&gt;")
	return s
end

function Utils.getNextWordBoundary(text, index)
	if index >= #text then return #text end
	local startCharacter = text:sub(index + 1, index + 1)
	local startIsWord = startCharacter:match("[%w_]") ~= nil
	for i = index + 1, #text do
		local character = text:sub(i, i)
		local isWord = character:match("[%w_]") ~= nil
		if isWord ~= startIsWord then return i - 1 end
	end
	return #text
end

function Utils.getPrevWordBoundary(text, index)
	if index <= 0 then return 0 end
	local startCharacter = text:sub(index, index)
	local startIsWord = startCharacter:match("[%w_]") ~= nil
	for i = index, 1, -1 do
		local character = text:sub(i, i)
		local isWord = character:match("[%w_]") ~= nil
		if isWord ~= startIsWord then return i end
	end
	return 0
end

function Utils.getWordAtIndex(text, index)
	local startIdx = index
	local endIdx = index
	while startIdx > 0 and text:sub(startIdx, startIdx):match("[%w_]") do
		startIdx = startIdx - 1
	end
	while endIdx < #text and text:sub(endIdx + 1, endIdx + 1):match("[%w_]") do
		endIdx = endIdx + 1
	end
	return startIdx, endIdx
end

function Utils.findWrapPoint(text, startIdx, endIdx, textSize, font, limit, defaultHeight)
	local lowBound = startIdx
	local highBound = endIdx
	local bestPoint = startIdx
	while lowBound <= highBound do
		local midPoint = math.floor((lowBound + highBound) / 2)
		local segmentSize = Utils.getTextSize(text:sub(startIdx, midPoint), textSize, font, limit)
		if segmentSize.Y <= defaultHeight then
			bestPoint = midPoint
			lowBound = midPoint + 1
		else
			highBound = midPoint - 1
		end
	end
	return bestPoint
end

function Utils.countWord(str, word)
	local count = 0
	for _ in str:gmatch("%f[%w]" .. word .. "%f[%W]") do count = count + 1 end
	return count
end

function Utils.getBlockDelta(lineStr)
	local cleanLine = lineStr:gsub('".-"', ''):gsub("'.-'", ''):gsub("%-%-.*", "")
	local opens = 0
	opens = opens + Utils.countWord(cleanLine, "if")
	opens = opens + Utils.countWord(cleanLine, "while")
	opens = opens + Utils.countWord(cleanLine, "for")
	opens = opens + Utils.countWord(cleanLine, "function")
	opens = opens + Utils.countWord(cleanLine, "repeat")
	if cleanLine:match("^%s*do%f[%W]") then opens = opens + 1 end
	local _, openBraces = cleanLine:gsub("{", "")
	opens = opens + openBraces
	local closes = Utils.countWord(cleanLine, "end") + Utils.countWord(cleanLine, "until")
	local _, closeBraces = cleanLine:gsub("}", "")
	closes = closes + closeBraces
	return opens - closes
end

local ScrollBar = {}
ScrollBar.__index = ScrollBar

local function makeArrowButton(parent, rotation, isVertical, bgColor, imgColor, bgTrans, strokeColor, strokeTrans)
	local SCROLLBAR_SIZE = 18
	local ARROW_COLOR = imgColor or Color3.fromRGB(160, 160, 160)
	local btn = Instance.new("ImageButton")
	btn.Size = isVertical and UDim2.new(1, 0, 0, SCROLLBAR_SIZE) or UDim2.new(0, SCROLLBAR_SIZE, 1, 0)
	btn.BackgroundColor3 = bgColor or Color3.fromRGB(35, 35, 35)
	btn.BorderColor3 = strokeColor or Color3.fromRGB(33, 33, 33)
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.Image = ""
	btn.ZIndex = 101
	btn.Parent = parent
	btn.BackgroundTransparency = bgTrans or 0
	local icon = Instance.new("ImageLabel")
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Size = UDim2.new(0, 12, 0, 12)
	icon.Position = UDim2.new(0.5, 0, 0.5, 0)
	icon.BackgroundTransparency = 1
	icon.Image = Icons.ScrollArrow
	icon.ImageColor3 = ARROW_COLOR
	icon.Rotation = rotation
	icon.ZIndex = 102
	icon.Parent = btn
	return btn, icon
end

function ScrollBar.new(container, isVertical)
	local self = setmetatable({}, ScrollBar)
	local SCROLLBAR_SIZE = 18
	self.Container = container
	self.IsVertical = isVertical
	self.ViewSize = 0
	self.ContentSize = 0
	self.ScrollPos = 0
	self.Connections = {}
	self.OnScroll = nil
	self.TrackColor = container:GetAttribute("ScrollBarTrackColor3") or Color3.fromRGB(35, 35, 35)
	self.ThumbColor = container:GetAttribute("ScrollBarThumbColor3") or Color3.fromRGB(60, 60, 60)
	self.HoverColor = container:GetAttribute("ScrollBarHoverColor3") or Color3.fromRGB(75, 75, 75)
	self.PressColor = container:GetAttribute("ScrollBarPressColor3") or Color3.fromRGB(40, 40, 40)
	self.TrackTransparency = container:GetAttribute("ScrollBarTrackTransparency") or 0
	self.ThumbTransparency = container:GetAttribute("ScrollBarThumbTransparency") or 0
	self.IsDraggingThumb = false
	local imageColor = container:GetAttribute("ScrollBarImageColor3") or Color3.fromRGB(160, 160, 160)
	local strokeColor = container:GetAttribute("ScrollBarStrokeColor3") or Color3.fromRGB(33, 33, 33)
	local strokeTrans = container:GetAttribute("ScrollBarStrokeTransparency") or 0
	self.BarFrame = Instance.new("Frame")
	self.BarFrame.Name = isVertical and "VScrollBar" or "HScrollBar"
	self.BarFrame.BackgroundColor3 = self.TrackColor
	self.BarFrame.BorderColor3 = strokeColor
	self.BarFrame.BorderSizePixel = 0
	self.BarFrame.Size = isVertical and UDim2.new(0, SCROLLBAR_SIZE, 1, 0) or UDim2.new(1, -SCROLLBAR_SIZE, 0, SCROLLBAR_SIZE)
	self.BarFrame.Position = isVertical and UDim2.new(1, -SCROLLBAR_SIZE, 0, 0) or UDim2.new(0, 0, 1, -SCROLLBAR_SIZE)
	self.BarFrame.ZIndex = 100
	self.BarFrame.Parent = container
	self.BarFrame.Visible = false
	self.BarFrame.BackgroundTransparency = self.TrackTransparency
	self.UpBtn, self.UpIcon = makeArrowButton(self.BarFrame, isVertical and 180 or 90, isVertical, self.TrackColor, imageColor, self.TrackTransparency, strokeColor, strokeTrans)
	self.UpBtn.AnchorPoint = Vector2.new(0, 0)
	self.UpBtn.Position = UDim2.new(0, 0, 0, 0)
	self.DownBtn, self.DownIcon = makeArrowButton(self.BarFrame, isVertical and 0 or -90, isVertical, self.TrackColor, imageColor, self.TrackTransparency, strokeColor, strokeTrans)
	self.DownBtn.AnchorPoint = Vector2.new(isVertical and 0 or 1, isVertical and 1 or 0)
	self.DownBtn.Position = isVertical and UDim2.new(0, 0, 1, 0) or UDim2.new(1, 0, 0, 0)
	self.UpBtn.MouseEnter:Connect(function() self.UpBtn.BackgroundColor3 = self.HoverColor end)
	self.UpBtn.MouseLeave:Connect(function() self.UpBtn.BackgroundColor3 = self.TrackColor end)
	self.UpBtn.MouseButton1Down:Connect(function() self.UpBtn.BackgroundColor3 = self.PressColor end)
	self.UpBtn.MouseButton1Up:Connect(function() self.UpBtn.BackgroundColor3 = self.HoverColor end)
	self.DownBtn.MouseEnter:Connect(function() self.DownBtn.BackgroundColor3 = self.HoverColor end)
	self.DownBtn.MouseLeave:Connect(function() self.DownBtn.BackgroundColor3 = self.TrackColor end)
	self.DownBtn.MouseButton1Down:Connect(function() self.DownBtn.BackgroundColor3 = self.PressColor end)
	self.DownBtn.MouseButton1Up:Connect(function() self.DownBtn.BackgroundColor3 = self.HoverColor end)
	self.Track = Instance.new("Frame")
	self.Track.Name = "Track"
	self.Track.BackgroundColor3 = self.TrackColor
	self.Track.BackgroundTransparency = self.TrackTransparency
	self.Track.BorderSizePixel = 0
	self.Track.Size = isVertical and UDim2.new(1, 0, 1, -SCROLLBAR_SIZE * 2) or UDim2.new(1, -SCROLLBAR_SIZE * 2, 1, 0)
	self.Track.Position = isVertical and UDim2.new(0, 0, 0, SCROLLBAR_SIZE) or UDim2.new(0, SCROLLBAR_SIZE, 0, 0)
	self.Track.ZIndex = 100
	self.Track.Parent = self.BarFrame
	self.Thumb = Instance.new("Frame")
	self.Thumb.Name = "Thumb"
	self.Thumb.BackgroundColor3 = self.ThumbColor
	self.Thumb.BorderSizePixel = 0
	self.Thumb.Size = isVertical and UDim2.new(1, -2, 0, 30) or UDim2.new(0, 30, 1, -2)
	self.Thumb.Position = isVertical and UDim2.new(0, 1, 0, 0) or UDim2.new(0, 0, 0, 1)
	self.Thumb.ZIndex = 101
	self.Thumb.Visible = false
	self.Thumb.Parent = self.Track
	self.Thumb.BackgroundTransparency = self.ThumbTransparency
	local thumbBtn = Instance.new("TextButton")
	thumbBtn.Size = UDim2.new(1, 0, 1, 0)
	thumbBtn.BackgroundTransparency = 1
	thumbBtn.Text = ""
	thumbBtn.ZIndex = 102
	thumbBtn.Parent = self.Thumb
	local dragStartMouse = 0
	local dragStartThumbOffset = 0
	thumbBtn.MouseEnter:Connect(function() self.Thumb.BackgroundColor3 = self.HoverColor end)
	thumbBtn.MouseLeave:Connect(function() if not self.IsDraggingThumb then self.Thumb.BackgroundColor3 = self.ThumbColor end end)
	thumbBtn.MouseButton1Down:Connect(function()
		self.IsDraggingThumb = true
		self.Thumb.BackgroundColor3 = self.HoverColor
		local mousePos = isVertical and UserInputService:GetMouseLocation().Y or UserInputService:GetMouseLocation().X
		dragStartMouse = mousePos
		dragStartThumbOffset = isVertical and self.Thumb.Position.Y.Offset or self.Thumb.Position.X.Offset
	end)
	table.insert(self.Connections, UserInputService.InputChanged:Connect(function(input)
		if self.IsDraggingThumb then
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				local mousePos = isVertical and UserInputService:GetMouseLocation().Y or UserInputService:GetMouseLocation().X
				local delta = mousePos - dragStartMouse
				local trackAbsSize = isVertical and self.Track.AbsoluteSize.Y or self.Track.AbsoluteSize.X
				local thumbAbsSize = isVertical and self.Thumb.AbsoluteSize.Y or self.Thumb.AbsoluteSize.X
				local maxOffset = math.max(0, trackAbsSize - thumbAbsSize)
				local newOffset = math.clamp(dragStartThumbOffset + delta, 0, maxOffset)
				local ratio = maxOffset > 0 and (newOffset / maxOffset) or 0
				local maxScroll = math.max(0, self.ContentSize - self.ViewSize)
				if self.OnScroll then self.OnScroll(ratio * maxScroll) end
			end
		elseif input.UserInputType == Enum.UserInputType.MouseWheel then
			if self.IsVertical and self.BarFrame.Visible then
				local pos = input.Position
				local absPos = self.Container.AbsolutePosition
				local absSize = self.Container.AbsoluteSize
				if pos.X >= absPos.X and pos.X <= absPos.X + absSize.X and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y then
					local dir = -math.sign(input.Position.Z)
					local maxScroll = math.max(0, self.ContentSize - self.ViewSize)
					local newScroll = math.clamp(self.ScrollPos + dir * 45, 0, maxScroll)
					if self.OnScroll then self.OnScroll(newScroll) end
				end
			end
		end
	end))
	table.insert(self.Connections, UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if self.IsDraggingThumb then
				self.IsDraggingThumb = false
				self.Thumb.BackgroundColor3 = self.ThumbColor
			end
		end
	end))
	local function scrollStepDir(dir)
		local max = math.max(0, self.ContentSize - self.ViewSize)
		local nP = math.clamp(self.ScrollPos + dir * 45, 0, max)
		if self.OnScroll then self.OnScroll(nP) end
	end
	local function startRepeat(dir)
		local active = true
		scrollStepDir(dir)
		task.spawn(function()
			task.wait(0.35)
			while active do
				scrollStepDir(dir)
				task.wait(0.05)
			end
		end)
		return function() active = false end
	end
	local stopUp, stopDown
	self.UpBtn.MouseButton1Down:Connect(function() stopUp = startRepeat(-1) end)
	self.UpBtn.MouseButton1Up:Connect(function() if stopUp then stopUp() stopUp = nil end end)
	self.UpBtn.MouseLeave:Connect(function() if stopUp then stopUp() stopUp = nil end end)
	self.DownBtn.MouseButton1Down:Connect(function() stopDown = startRepeat(1) end)
	self.DownBtn.MouseButton1Up:Connect(function() if stopDown then stopDown() stopDown = nil end end)
	self.DownBtn.MouseLeave:Connect(function() if stopDown then stopDown() stopDown = nil end end)
	return self
end

function ScrollBar:SetColors(trackColor, thumbColor)
	self.TrackColor = trackColor or Color3.fromRGB(35, 35, 35)
	self.ThumbColor = thumbColor or Color3.fromRGB(60, 60, 60)
	self.HoverColor = thumbColor or Color3.fromRGB(75, 75, 75)
	self.BarFrame.BackgroundColor3 = self.TrackColor
	self.Track.BackgroundColor3 = self.TrackColor
	self.UpBtn.BackgroundColor3 = self.TrackColor
	self.DownBtn.BackgroundColor3 = self.TrackColor
	if not self.IsDraggingThumb then
		self.Thumb.BackgroundColor3 = self.ThumbColor
	end
end

function ScrollBar:UpdateMetrics(viewSize, contentSize, scrollPos)
	self.ViewSize = viewSize
	self.ContentSize = contentSize
	self.ScrollPos = scrollPos
	local trackSize = self.IsVertical and self.Track.AbsoluteSize.Y or self.Track.AbsoluteSize.X
	if contentSize <= viewSize or trackSize <= 0 then
		self.BarFrame.Visible = false
		self.Thumb.Visible = false
		return
	end
	self.BarFrame.Visible = true
	self.Thumb.Visible = true
	local maxScroll = contentSize - viewSize
	local ratio = math.clamp(viewSize / contentSize, 0, 1)
	local thumbSize = math.max(24, ratio * trackSize)
	local scrollRatio = maxScroll > 0 and scrollPos / maxScroll or 0
	local thumbOffset = scrollRatio * (trackSize - thumbSize)
	if self.IsVertical then
		self.Thumb.Size = UDim2.new(1, -2, 0, thumbSize)
		self.Thumb.Position = UDim2.new(0, 1, 0, thumbOffset)
	else
		self.Thumb.Size = UDim2.new(0, thumbSize, 1, -2)
		self.Thumb.Position = UDim2.new(0, thumbOffset, 0, 1)
	end
end

function ScrollBar:Destroy()
	for _, conn in ipairs(self.Connections) do conn:Disconnect() end
	self.BarFrame:Destroy()
end

function Baseline.new(canvasGroup)
	if canvasGroup and canvasGroup:IsA("CanvasGroup") then
		local newFrame = Instance.new("Frame")
		newFrame.Name = canvasGroup.Name
		newFrame.Size = canvasGroup.Size
		newFrame.Position = canvasGroup.Position
		newFrame.AnchorPoint = canvasGroup.AnchorPoint
		newFrame.BackgroundColor3 = canvasGroup:GetAttribute("BackgroundColor3") or canvasGroup.BackgroundColor3
		newFrame.BackgroundTransparency = canvasGroup:GetAttribute("BackgroundTransparency") or canvasGroup.BackgroundTransparency
		newFrame.BorderColor3 = canvasGroup.BorderColor3
		newFrame.BorderSizePixel = 0
		newFrame.ZIndex = canvasGroup.ZIndex
		newFrame.LayoutOrder = canvasGroup.LayoutOrder
		newFrame.ClipsDescendants = true
		newFrame.Parent = canvasGroup.Parent
		for k, v in pairs(canvasGroup:GetAttributes()) do
			newFrame:SetAttribute(k, v)
		end
		for _, child in ipairs(canvasGroup:GetChildren()) do
			child.Parent = newFrame
		end
		canvasGroup:Destroy()
		canvasGroup = newFrame
	end

	local initText = canvasGroup:GetAttribute("Text")
	if initText and initText:match("\t") then
		canvasGroup:SetAttribute("Text", initText:gsub("\t", "    "))
	end

	local self = setmetatable({}, Baseline)
	self.CanvasGroup = canvasGroup
	self.Connections = {}
	self.LinesPool = {}
	self.HighlightPool = {}
	self.LineNumbersPool = {}
	self.MinimapLinesPool = {}
	self.FoldButtonsPool = {}
	self.IndentGuidesPool = {}
	self.FoldedLines = {}
	self.CurrentFoldPairs = {}
	self.SyntaxRules = nil
	self.IsFocused = false
	self.IsDragging = false
	self.DraggingMinimap = false
	self.IsPasting = false
	self.CursorIndex = 0
	self.SelectionStart = 0
	self.ScrollOffset = Vector2.new(0, 0)
	self.MinimapScrollY = 0
	self.DocumentHeight = 0
	self.CachedDocumentWidth = 0
	self.HeldKey = nil
	self.KeyTimer = 0
	self.KeyTick = 0
	self.BlinkTimer = 0
	self.ClickCount = 0
	self.LastClickTime = 0
	self.LastTypedChar = ""
	self.LastTypedTick = 0
	self.History = {{text = "", cursor = 0, sel = 0}}
	self.HistoryIdx = 1
	self.SinkActionName = "BaselineSink_" .. HttpService:GenerateGUID(false)
	self.FindUI = nil
	self.FindMatches = {}
	self.CurrentMatchIndex = 0
	self.FindTextConn = nil
	self.CachedText = nil
	self.CachedTextSize = nil
	self.CachedFont = nil
	self.CachedLimitX = nil
	self.CachedLimitY = nil
	self.CachedLineMap = nil
	self.AutocompleteVisible = false
	self.AutocompleteMatches = {}
	self.AutocompleteIndex = 1
	self.AutocompleteSelectionColor = Color3.fromRGB(37, 75, 122)
	self.AutocompleteBackgroundColor = Color3.fromRGB(30, 30, 30)
	self.AutocompleteTextColor = Color3.fromRGB(220, 220, 220)
	self.AutocompleteSelectedTextColor = Color3.fromRGB(255, 255, 255)

	table.insert(Baseline.Instances, self)

	self.CurrentLineHighlight = Instance.new("Frame")
	self.CurrentLineHighlight.Name = "BaselineCurrentLine"
	self.CurrentLineHighlight.BackgroundColor3 = Color3.fromRGB(53, 55, 65)
	self.CurrentLineHighlight.BackgroundTransparency = 0.5
	self.CurrentLineHighlight.BorderSizePixel = 0
	self.CurrentLineHighlight.ZIndex = 1
	self.CurrentLineHighlight.Visible = false
	self.CurrentLineHighlight.Parent = canvasGroup

	self.LineNumbersContainer = Instance.new("Frame")
	self.LineNumbersContainer.Name = "BaselineLineNumbersContainer"
	self.LineNumbersContainer.BackgroundTransparency = 1
	self.LineNumbersContainer.ClipsDescendants = true
	self.LineNumbersContainer.ZIndex = 11
	self.LineNumbersContainer.Parent = canvasGroup

	self.LineNumbersInner = Instance.new("Frame")
	self.LineNumbersInner.Name = "BaselineLineNumbersInner"
	self.LineNumbersInner.BackgroundTransparency = 1
	self.LineNumbersInner.Size = UDim2.new(1, 0, 0, 0)
	self.LineNumbersInner.Parent = self.LineNumbersContainer

	self.MinimapContainer = Instance.new("Frame")
	self.MinimapContainer.Name = "BaselineMinimap"
	self.MinimapContainer.BackgroundTransparency = 1
	self.MinimapContainer.ClipsDescendants = true
	self.MinimapContainer.ZIndex = 2
	self.MinimapContainer.Parent = canvasGroup

	self.MinimapInner = Instance.new("Frame")
	self.MinimapInner.Name = "BaselineMinimapInner"
	self.MinimapInner.BackgroundTransparency = 1
	self.MinimapInner.Size = UDim2.new(1, 0, 1, 0)
	self.MinimapInner.Parent = self.MinimapContainer

	self.MinimapSlider = Instance.new("Frame")
	self.MinimapSlider.Name = "BaselineMinimapSlider"
	self.MinimapSlider.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
	self.MinimapSlider.BackgroundTransparency = 0.8
	self.MinimapSlider.BorderSizePixel = 0
	self.MinimapSlider.ZIndex = 3
	self.MinimapSlider.Parent = self.MinimapInner

	self.TextContainer = Instance.new("Frame")
	self.TextContainer.Name = "BaselineTextContainer"
	self.TextContainer.BackgroundTransparency = 1
	self.TextContainer.ClipsDescendants = true
	self.TextContainer.ZIndex = 2
	self.TextContainer.Parent = canvasGroup

	self.InnerFrame = Instance.new("Frame")
	self.InnerFrame.Name = "BaselineInnerFrame"
	self.InnerFrame.BackgroundTransparency = 1
	self.InnerFrame.Size = UDim2.new(0, 0, 0, 0)
	self.InnerFrame.Parent = self.TextContainer

	self.IndentGuideContainer = Instance.new("Frame")
	self.IndentGuideContainer.Name = "BaselineIndentGuides"
	self.IndentGuideContainer.BackgroundTransparency = 1
	self.IndentGuideContainer.Size = UDim2.new(0, 0, 0, 0)
	self.IndentGuideContainer.ZIndex = 1
	self.IndentGuideContainer.Parent = self.InnerFrame

	self.PlaceholderLabel = Instance.new("TextLabel")
	self.PlaceholderLabel.Name = "PlaceholderTextLabel"
	self.PlaceholderLabel.Size = UDim2.new(0, 10000, 0, 25)
	self.PlaceholderLabel.Position = UDim2.new(0, 4, 0, 4)
	self.PlaceholderLabel.BackgroundTransparency = 1
	self.PlaceholderLabel.TextWrapped = false
	self.PlaceholderLabel.TextXAlignment = Enum.TextXAlignment.Left
	self.PlaceholderLabel.TextYAlignment = Enum.TextYAlignment.Top
	self.PlaceholderLabel.ZIndex = 1
	self.PlaceholderLabel.Parent = self.InnerFrame

	self.GhostTextLabel = Instance.new("TextLabel")
	self.GhostTextLabel.Name = "GhostTextLabel"
	self.GhostTextLabel.Size = UDim2.new(0, 10000, 0, 25)
	self.GhostTextLabel.BackgroundTransparency = 1
	self.GhostTextLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
	self.GhostTextLabel.TextXAlignment = Enum.TextXAlignment.Left
	self.GhostTextLabel.TextYAlignment = Enum.TextYAlignment.Top
	self.GhostTextLabel.ZIndex = 3
	self.GhostTextLabel.Visible = false
	self.GhostTextLabel.Parent = self.InnerFrame

	self.HighlightContainer = Instance.new("Frame")
	self.HighlightContainer.Name = "BaselineHighlightContainer"
	self.HighlightContainer.Size = UDim2.new(0, 0, 0, 0)
	self.HighlightContainer.Position = UDim2.new(0, 0, 0, 0)
	self.HighlightContainer.BackgroundTransparency = 1
	self.HighlightContainer.ZIndex = 2
	self.HighlightContainer.Parent = self.InnerFrame

	self.Blinker = Instance.new("Frame")
	self.Blinker.Name = "BaselineBlinker"
	self.Blinker.Size = UDim2.new(0, 1, 0, 14)
	self.Blinker.BackgroundColor3 = Color3.new(1, 1, 1)
	self.Blinker.BorderSizePixel = 0
	self.Blinker.Visible = false
	self.Blinker.ZIndex = 4
	self.Blinker.Parent = self.InnerFrame

	self.PasteBox = Instance.new("TextBox")
	self.PasteBox.Name = "BaselinePasteBox"
	self.PasteBox.Size = UDim2.new(1, 0, 1, 0)
	self.PasteBox.BackgroundTransparency = 1
	self.PasteBox.TextTransparency = 1
	self.PasteBox.ClearTextOnFocus = false
	self.PasteBox.MultiLine = true
	self.PasteBox.Text = ""
	self.PasteBox.ZIndex = 10
	self.PasteBox.Parent = self.CanvasGroup

	self.AutocompleteUI = Instance.new("Frame")
	self.AutocompleteUI.Name = "AutocompleteUI"
	self.AutocompleteUI.Size = UDim2.new(0, 260, 0, 160)
	self.AutocompleteUI.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	self.AutocompleteUI.BorderSizePixel = 0
	self.AutocompleteUI.ZIndex = 100
	self.AutocompleteUI.Visible = false
	self.AutocompleteUI.Parent = self.CanvasGroup

	self.AutocompleteScroll = Instance.new("ScrollingFrame")
	self.AutocompleteScroll.Size = UDim2.new(1, 0, 1, 0)
	self.AutocompleteScroll.BackgroundTransparency = 1
	self.AutocompleteScroll.ScrollBarThickness = 2
	self.AutocompleteScroll.ScrollBarImageTransparency = 1
	self.AutocompleteScroll.BorderSizePixel = 0
	self.AutocompleteScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	self.AutocompleteScroll.AutomaticCanvasSize = Enum.AutomaticSize.None
	self.AutocompleteScroll.ZIndex = 101
	self.AutocompleteScroll.Parent = self.AutocompleteUI

	local autocompleteLayout = Instance.new("UIListLayout")
	autocompleteLayout.SortOrder = Enum.SortOrder.LayoutOrder
	autocompleteLayout.Parent = self.AutocompleteScroll

	self.AutocompleteHint = Instance.new("Frame")
	self.AutocompleteHint.Name = "AutocompleteHint"
	self.AutocompleteHint.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	self.AutocompleteHint.BorderSizePixel = 0
	self.AutocompleteHint.Visible = false
	self.AutocompleteHint.ZIndex = 101
	self.AutocompleteHint.Parent = self.AutocompleteUI

	self.AutocompleteHintText = Instance.new("TextLabel")
	self.AutocompleteHintText.Size = UDim2.new(1, -10, 1, 0)
	self.AutocompleteHintText.Position = UDim2.new(0, 5, 0, 0)
	self.AutocompleteHintText.BackgroundTransparency = 1
	self.AutocompleteHintText.TextColor3 = Color3.fromRGB(220, 220, 220)
	self.AutocompleteHintText.Font = Enum.Font.Code
	self.AutocompleteHintText.TextSize = 14
	self.AutocompleteHintText.TextXAlignment = Enum.TextXAlignment.Left
	self.AutocompleteHintText.ZIndex = 102
	self.AutocompleteHintText.Parent = self.AutocompleteHint

	canvasGroup.ClipsDescendants = true
	canvasGroup.Active = true

	local hideScrollbars = canvasGroup:GetAttribute("HideScrollbars")
	if not hideScrollbars then
		self.VScrollBar = ScrollBar.new(canvasGroup, true)
		self.VScrollBar.OnScroll = function(newY)
			self.ScrollOffset = Vector2.new(self.ScrollOffset.X, newY)
			self:UpdateBlinker(false)
		end
		self.HScrollBar = ScrollBar.new(canvasGroup, false)
		self.HScrollBar.OnScroll = function(newX)
			self.ScrollOffset = Vector2.new(newX, self.ScrollOffset.Y)
			self:UpdateBlinker(false)
		end
	end

	table.insert(self.Connections, self.PasteBox:GetPropertyChangedSignal("Text"):Connect(function()
		local text = self.PasteBox.Text
		if text ~= "" then
			task.defer(function()
				if self.PasteBox and self.PasteBox.Text == text then self.PasteBox.Text = "" end
			end)
			if text == "\n" or text == "\r\n" or text == "\r" then return end
			local isManualKeystroke = (#text == 1) and (text == self.LastTypedChar) and ((tick() - self.LastTypedTick) < 0.2)
			if not isManualKeystroke then self:PasteChunked(text) end
		end
	end))

	table.insert(self.Connections, self.PasteBox.FocusLost:Connect(function()
		task.defer(function() if self.IsFocused then self.PasteBox:CaptureFocus() end end)
	end))

	table.insert(self.Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local pos = input.Position
			local function isInside(gui)
				if not gui or not gui.Visible then return false end
				local absPos = gui.AbsolutePosition
				local absSize = gui.AbsoluteSize
				return pos.X >= absPos.X and pos.X <= absPos.X + absSize.X and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y
			end
			if self.VScrollBar and isInside(self.VScrollBar.BarFrame) then return end
			if self.HScrollBar and isInside(self.HScrollBar.BarFrame) then return end
			if self.FindUI and isInside(self.FindUI) then return end
			if self.MinimapContainer and self.MinimapContainer.Visible and isInside(self.MinimapContainer) then
				self.DraggingMinimap = true
				self:ScrollToMinimap(pos.Y)
				return
			end
			if self.LineNumbersContainer and self.LineNumbersContainer.Visible and isInside(self.LineNumbersContainer) then
				self:Focus()
				return
			end
			if self.AutocompleteUI.Visible and (isInside(self.AutocompleteUI) or isInside(self.AutocompleteHint)) then
				return
			end
			local didClickSelf = isInside(self.CanvasGroup)
			if didClickSelf then
				self:Focus()
				self:HideAutocomplete()
				local relativeX = (pos.X - self.InnerFrame.AbsolutePosition.X) - 4
				local relativeY = (pos.Y - self.InnerFrame.AbsolutePosition.Y) - 4
				local isShiftDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
				local closestIndex = self:GetClosestCursorIndex(relativeX, relativeY)
				local currentTime = tick()
				if (currentTime - self.LastClickTime) < 0.3 then
					self.ClickCount = self.ClickCount + 1
				else
					self.ClickCount = 1
				end
				self.LastClickTime = currentTime
				local displayedText = self:GetDisplayText()
				if self.ClickCount == 2 then
					self.SelectionStart, self.CursorIndex = Utils.getWordAtIndex(displayedText, closestIndex)
				elseif self.ClickCount == 3 then
					local textSize = self.CanvasGroup:GetAttribute("TextSize")
					local font = self.CanvasGroup:GetAttribute("Font")
					local lineMap = self:GetLineMapCached(displayedText, textSize, font, self:GetLimit())
					for _, line in ipairs(lineMap) do
						local rEnd = line.renderEndIdx or line.endIdx
						if closestIndex >= (line.startIdx - 1) and closestIndex <= rEnd then
							self.SelectionStart = line.startIdx - 1
							self.CursorIndex = line.endIdx
							break
						end
					end
				elseif isShiftDown then
					self.CursorIndex = closestIndex
				else
					self.SelectionStart = closestIndex
					self.CursorIndex = closestIndex
				end
				self.IsDragging = true
				self:UpdateBlinker(false)
			else
				self:Unfocus()
			end
		elseif input.UserInputType == Enum.UserInputType.Keyboard then
			if not self.IsFocused then return end
			if self.AutocompleteVisible then
				local text = self.CanvasGroup:GetAttribute("Text") or ""
				local word = Utils.getWordBeforeCursor(text, self.CursorIndex)
				local match = self.AutocompleteMatches[self.AutocompleteIndex]

				if input.KeyCode == Enum.KeyCode.Down then
					self.AutocompleteIndex = math.min(self.AutocompleteIndex + 1, #self.AutocompleteMatches)
					self:RenderAutocomplete()
					return
				elseif input.KeyCode == Enum.KeyCode.Up then
					self.AutocompleteIndex = math.max(self.AutocompleteIndex - 1, 1)
					self:RenderAutocomplete()
					return
				elseif input.KeyCode == Enum.KeyCode.Right then
					if self.GhostTextLabel.Visible then
						if self:CommitAutocomplete() then return end
					end
				elseif input.KeyCode == Enum.KeyCode.Tab then
					if self:CommitAutocomplete() then return end
				elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter then
					if match and match.word == word then
						self:HideAutocomplete()
						return
					else
						if self:CommitAutocomplete() then return end
					end
				elseif input.KeyCode == Enum.KeyCode.Escape then
					self:HideAutocomplete()
					return
				end
			end
			local isShiftDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
			local isCtrlDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
			if isCtrlDown and isShiftDown and input.KeyCode == Enum.KeyCode.F then
				self:Format()
				return
			end
			if isCtrlDown and input.KeyCode == Enum.KeyCode.A then
				self.SelectionStart = 0
				self.CursorIndex = #(self:GetDisplayText())
				self:UpdateBlinker(true)
				return
			elseif isCtrlDown and input.KeyCode == Enum.KeyCode.Z then
				self:Undo()
				return
			elseif isCtrlDown and input.KeyCode == Enum.KeyCode.Y then
				self:Redo()
				return
			elseif isCtrlDown and input.KeyCode == Enum.KeyCode.C then
				self:Copy()
				return
			elseif isCtrlDown and input.KeyCode == Enum.KeyCode.X then
				self:Cut()
				return
			elseif isCtrlDown and input.KeyCode == Enum.KeyCode.V then
				self.LastTypedChar = ""
				return
			elseif isCtrlDown and input.KeyCode == Enum.KeyCode.F then
				self:ToggleFindUI()
				return
			end
			local isRepeatable = (input.KeyCode == Enum.KeyCode.Backspace) or
								 (input.KeyCode == Enum.KeyCode.Return) or
								 (input.KeyCode == Enum.KeyCode.KeypadEnter) or
								 (input.KeyCode == Enum.KeyCode.Left) or
								 (input.KeyCode == Enum.KeyCode.Right) or
								 (input.KeyCode == Enum.KeyCode.Up) or
								 (input.KeyCode == Enum.KeyCode.Down) or
								 (input.KeyCode == Enum.KeyCode.Tab) or
								 (Utils.getCharacter(input.KeyCode, isShiftDown) ~= "")
			if isRepeatable then
				self:ProcessKey(input.KeyCode, isShiftDown, isCtrlDown)
				self.HeldKey = input.KeyCode
				self.KeyTimer = 0
				self.KeyTick = 0
			else
				self:ProcessKey(input.KeyCode, isShiftDown, isCtrlDown)
			end
		end
	end))

	table.insert(self.Connections, UserInputService.InputChanged:Connect(function(input)
		if self.DraggingMinimap and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			self:ScrollToMinimap(input.Position.Y)
			return
		end
		if self.IsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local pos = input.Position
			local relativeX = (pos.X - self.InnerFrame.AbsolutePosition.X) - 4
			local relativeY = (pos.Y - self.InnerFrame.AbsolutePosition.Y) - 4
			self.CursorIndex = self:GetClosestCursorIndex(relativeX, relativeY)
			self:UpdateBlinker(true)
		end
	end))

	table.insert(self.Connections, UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == self.HeldKey then
			self.HeldKey = nil
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.IsDragging = false
			self.DraggingMinimap = false
		end
	end))

	table.insert(self.Connections, RunService.RenderStepped:Connect(function(deltaTime)
		if deltaTime > 0.1 then deltaTime = 0 end
		if self.HeldKey then
			self.KeyTimer = self.KeyTimer + deltaTime
			if self.KeyTimer > 0.4 then
				self.KeyTick = self.KeyTick + deltaTime
				if self.KeyTick > 0.04 then
					self.KeyTick = 0
					local isShiftDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
					local isCtrlDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
					self:ProcessKey(self.HeldKey, isShiftDown, isCtrlDown)
				end
			end
		end
		if self.IsFocused then
			if self.SelectionStart == self.CursorIndex then
				self.BlinkTimer = self.BlinkTimer + deltaTime
				if self.BlinkTimer > 0.5 then
					self.BlinkTimer = 0
					self.Blinker.Visible = not self.Blinker.Visible
				end
			else
				self.Blinker.Visible = false
			end
		end
	end))

	table.insert(self.Connections, self.CanvasGroup:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:UpdateBlinker(false)
	end))

	table.insert(self.Connections, canvasGroup.AttributeChanged:Connect(function(attributeName)
		local value = canvasGroup:GetAttribute(attributeName)
		local updateBlinkerAttributes = {
			Text = true, TextSize = true, Font = true, Minimap = true,
			HighlightColor = true, PasswordMode = true, HideScrollbars = true,
			Wrapped = true, Lines = true, LineNumberColor3 = true, TextColor3 = true, AutoHeight = true,
			StrokeColor3 = true, StrokeTransparency = true, StrokeThickness = true,
			IndentGuideColor3 = true, IndentGuideTransparency = true, IndentGuideThickness = true
		}
		if updateBlinkerAttributes[attributeName] then
			self:UpdateBlinker(true)
		elseif attributeName == "BlinkerColor" then
			self.Blinker.BackgroundColor3 = value
		elseif attributeName == "PlaceholderColor3" then
			self.PlaceholderLabel.TextColor3 = value
		elseif attributeName == "PlaceholderText" then
			self.PlaceholderLabel.Text = value
		end
	end))

	local proxyObj = setmetatable({}, {
		__index = function(_, key)
			local attributeValue = canvasGroup:GetAttribute(key)
			if attributeValue ~= nil then return attributeValue end
			if type(self[key]) == "function" then
				return function(_, ...) return self[key](self, ...) end
			end
			return self[key]
		end,
		__newindex = function(_, key, value)
			local allowedAttributes = {
				Text = true, MultiLine = true, Wrapped = true, Minimap = true,
				SmoothBlinker = true, TextSize = true, TextColor3 = true,
				BlinkerColor = true, HighlightColor = true, Font = true,
				PlaceholderText = true, PlaceholderColor3 = true, AutoHeight = true,
				MaxLength = true, PasswordMode = true, ReadOnly = true, HideScrollbars = true,
				TabIndex = true, Lines = true, LineNumberColor3 = true,
				StrokeColor3 = true, StrokeTransparency = true, StrokeThickness = true,
				IndentGuideColor3 = true, IndentGuideTransparency = true, IndentGuideThickness = true,
				ScrollBarTrackColor3 = true, ScrollBarTrackTransparency = true,
				ScrollBarThumbColor3 = true, ScrollBarThumbTransparency = true,
				ScrollBarHoverColor3 = true, ScrollBarPressColor3 = true,
				ScrollBarImageColor3 = true, ScrollBarStrokeColor3 = true,
				ScrollBarStrokeTransparency = true
			}
			if key == "Text" and type(value) == "string" then
				value = value:gsub("\t", "    ")
			end
			if allowedAttributes[key] then
				canvasGroup:SetAttribute(key, value)
			else
				rawset(self, key, value)
			end
		end
	})

	for key, defaultValue in pairs(GlobalSettings) do
		if canvasGroup:GetAttribute(key) == nil then
			proxyObj[key] = defaultValue
		end
	end

	self.PlaceholderLabel.Text = proxyObj.PlaceholderText
	self.PlaceholderLabel.TextColor3 = proxyObj.PlaceholderColor3
	self.PlaceholderLabel.Font = proxyObj.Font
	self.PlaceholderLabel.TextSize = proxyObj.TextSize
	self:UpdateBlinker(true)

	return proxyObj
end

function Baseline:ApplyThemeRules(rules)
	self.SyntaxRules = rules
	if type(rules) == "table" then
		if rules["TextColor"] and rules["TextColor"].color then
			self.CanvasGroup:SetAttribute("TextColor3", rules["TextColor"].color)
			self.PlaceholderLabel.TextColor3 = rules["TextColor"].color
		end
		if rules["BackgroundColor"] and rules["BackgroundColor"].color then
			self.CanvasGroup.BackgroundColor3 = rules["BackgroundColor"].color
		end
		if rules["SelectionBackgroundColor"] and rules["SelectionBackgroundColor"].color then
			self.CanvasGroup:SetAttribute("HighlightColor", rules["SelectionBackgroundColor"].color)
		end
		if rules["ScriptRulerColor"] and rules["ScriptRulerColor"].color then
			self.CanvasGroup:SetAttribute("LineNumberColor3", rules["ScriptRulerColor"].color)
		end
		if rules["CurrentLineHighlightColor"] and rules["CurrentLineHighlightColor"].color then
			self.CurrentLineHighlight.BackgroundColor3 = rules["CurrentLineHighlightColor"].color
		end
		if rules["MenuItemBackground"] and rules["MenuItemBackground"].color then
			self.AutocompleteUI.BackgroundColor3 = rules["MenuItemBackground"].color
			self.AutocompleteHint.BackgroundColor3 = rules["MenuItemBackground"].color
			self.AutocompleteBackgroundColor = rules["MenuItemBackground"].color
		end
		if rules["SelectedMenuItemBackground"] and rules["SelectedMenuItemBackground"].color then
			self.AutocompleteSelectionColor = rules["SelectedMenuItemBackground"].color
		end
		if rules["MenuPrimaryTextColor"] and rules["MenuPrimaryTextColor"].color then
			self.AutocompleteTextColor = rules["MenuPrimaryTextColor"].color
		end
		if rules["MenuSelectedTextColor"] and rules["MenuSelectedTextColor"].color then
			self.AutocompleteSelectedTextColor = rules["MenuSelectedTextColor"].color
		end
		if rules["MenuSecondaryTextColor"] and rules["MenuSecondaryTextColor"].color then
			self.AutocompleteHintText.TextColor3 = rules["MenuSecondaryTextColor"].color
		end
		local scrollBg = rules["ScriptEditorScrollbarBackground"] and rules["ScriptEditorScrollbarBackground"].color
		local scrollHandle = rules["ScriptEditorScrollbarHandle"] and rules["ScriptEditorScrollbarHandle"].color
		if scrollBg or scrollHandle then
			if self.VScrollBar then self.VScrollBar:SetColors(scrollBg, scrollHandle) end
			if self.HScrollBar then self.HScrollBar:SetColors(scrollBg, scrollHandle) end
		end
	end
	self.CachedText = nil
	self:UpdateBlinker(true)
end

function Baseline:ApplyStrokeToLabel(guiElement)
	if not guiElement then return end
	local stroke = guiElement:FindFirstChild("TextUIStroke")
	local thickness = self.CanvasGroup:GetAttribute("StrokeThickness") or 0
	if thickness > 0 then
		if not stroke then
			stroke = Instance.new("UIStroke")
			stroke.Name = "TextUIStroke"
			stroke.Parent = guiElement
		end
		stroke.Color = self.CanvasGroup:GetAttribute("StrokeColor3") or Color3.fromRGB(0, 0, 0)
		stroke.Transparency = self.CanvasGroup:GetAttribute("StrokeTransparency") or 0.92
		stroke.Thickness = thickness
		stroke.Enabled = true
	else
		if stroke then
			stroke.Enabled = false
		end
	end
end

function Baseline:Format()
	local rawText = self.CanvasGroup:GetAttribute("Text") or ""
	if rawText == "" then return end
	local lines = {}
	local start = 1
	while true do
		local nl = rawText:find("\n", start, true)
		if not nl then
			table.insert(lines, rawText:sub(start))
			break
		end
		table.insert(lines, rawText:sub(start, nl - 1))
		start = nl + 1
	end
	if #lines > 1 and lines[#lines] == "" and rawText:sub(-1) == "\n" then
		table.remove(lines)
	end
	local result = {}
	local indent = 0
	for _, rawLine in ipairs(lines) do
		local trimmed = rawLine:match("^%s*(.-)%s*$") or ""
		if trimmed == "" then
			table.insert(result, "")
		else
			local leadingClose = 0
			local firstWord = trimmed:match("^([%w_]+)")
			if firstWord == "end" or firstWord == "until" or firstWord == "else" or firstWord == "elseif" then
				leadingClose = 1
			elseif trimmed:sub(1, 1):match("[%]%)}]") then
				leadingClose = 1
			end
			local thisIndent = math.max(0, indent - leadingClose)
			table.insert(result, string.rep("    ", thisIndent) .. trimmed)
			indent = math.max(0, indent + Utils.getBlockDelta(trimmed))
		end
	end
	local finalText = table.concat(result, "\n")
	if rawText:sub(-1) == "\n" then finalText = finalText .. "\n" end
	self.CanvasGroup:SetAttribute("Text", finalText)
	self:PushHistory()
	self:UpdateBlinker(true)
end

function Baseline:ScrollToMinimap(mouseY)
	if not self.MinimapContainer or not self.MinimapContainer.Visible then return end
	local relativeY = mouseY - self.MinimapContainer.AbsolutePosition.Y
	local minimapV = self.MinimapContainer.AbsoluteSize.Y
	local editorTextSize = self.CanvasGroup:GetAttribute("TextSize") or 16
	local ratio = 3 / editorTextSize
	local S_mini = self.MinimapScrollY or 0
	local clickYInner = relativeY + S_mini
	local viewportH = self.CanvasGroup.AbsoluteSize.Y - 8
	local sliderH = math.min(minimapV, viewportH * ratio)
	local targetCenterY = clickYInner
	local targetY = targetCenterY - (sliderH / 2)
	local S_main = targetY / ratio
	local maxS_main = math.max(0, self.DocumentHeight - viewportH)
	S_main = math.clamp(S_main, 0, maxS_main)
	self.ScrollOffset = Vector2.new(self.ScrollOffset.X, S_main)
	self:UpdateBlinker(false)
end

function Baseline:ToggleFindUI()
	if self.FindUI then self:CloseFindUI() else self:OpenFindUI() end
end

function Baseline:OpenFindUI()
	local function createFindMenu()
		local mainFrame = Instance.new("Frame")
		mainFrame.Name = "MainFrame"
		mainFrame.Size = UDim2.new(0, 260, 0, 88)
		mainFrame.Position = UDim2.new(0.5, -130, 0.3, 0)
		mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		mainFrame.BorderSizePixel = 0
		mainFrame.ZIndex = 1
		mainFrame.AnchorPoint = Vector2.new(0, 0)

		local mainPadding = Instance.new("UIPadding")
		mainPadding.Name = "UIPadding"
		mainPadding.Parent = mainFrame

		local row1Find = Instance.new("Frame")
		row1Find.Name = "Row1_Find"
		row1Find.Size = UDim2.new(1, 0, 0, 24)
		row1Find.Position = UDim2.new(0, 0, 0, 0)
		row1Find.BackgroundTransparency = 1
		row1Find.Parent = mainFrame

		local toggleExpandBtn = Instance.new("ImageButton")
		toggleExpandBtn.Name = "ToggleExpandBtn"
		toggleExpandBtn.Size = UDim2.new(0, 20, 0, 20)
		toggleExpandBtn.Position = UDim2.new(0, 0, 0, 2)
		toggleExpandBtn.BackgroundTransparency = 1
		toggleExpandBtn.Parent = row1Find

		local topChevron = Instance.new("ImageLabel")
		topChevron.Name = "TopChevron"
		topChevron.Size = UDim2.new(0, 18, 0, 18)
		topChevron.Position = UDim2.new(0.5, 0, 0.27, 0)
		topChevron.AnchorPoint = Vector2.new(0.5, 0.5)
		topChevron.Rotation = 180
		topChevron.BackgroundTransparency = 1
		topChevron.Image = Icons.FindTopChevron
		topChevron.Parent = toggleExpandBtn

		local bottomChevron = Instance.new("ImageLabel")
		bottomChevron.Name = "BottomChevron"
		bottomChevron.Size = UDim2.new(0, 18, 0, 18)
		bottomChevron.Position = UDim2.new(0.5, 0, 0.62, 0)
		bottomChevron.AnchorPoint = Vector2.new(0.5, 0.5)
		bottomChevron.Rotation = 180
		bottomChevron.BackgroundTransparency = 1
		bottomChevron.Image = Icons.FindBottomChevron
		bottomChevron.Parent = toggleExpandBtn

		local findBox = Instance.new("TextBox")
		findBox.Name = "FindBox"
		findBox.Size = UDim2.new(0, 155, 1, 0)
		findBox.Position = UDim2.new(0, 24, 0, 0)
		findBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		findBox.TextColor3 = Color3.fromRGB(204, 204, 204)
		findBox.BorderSizePixel = 0
		findBox.TextSize = 14
		findBox.Font = Enum.Font.RobotoMono
		findBox.TextXAlignment = Enum.TextXAlignment.Left
		findBox.PlaceholderText = "Find..."
		findBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
		findBox.ClearTextOnFocus = false
		findBox.Text = ""
		findBox.Parent = row1Find

		local findBoxPadding = Instance.new("UIPadding")
		findBoxPadding.Name = "UIPadding"
		findBoxPadding.Parent = findBox

		local findPrevBtn = Instance.new("ImageButton")
		findPrevBtn.Name = "FindPrevBtn"
		findPrevBtn.Size = UDim2.new(0, 20, 0, 20)
		findPrevBtn.Position = UDim2.new(0, 185, 0, 2)
		findPrevBtn.BackgroundTransparency = 1
		findPrevBtn.Image = Icons.FindPrev
		findPrevBtn.Parent = row1Find

		local findNextBtn = Instance.new("ImageButton")
		findNextBtn.Name = "FindNextBtn"
		findNextBtn.Size = UDim2.new(0, 20, 0, 20)
		findNextBtn.Position = UDim2.new(0, 209, 0, 2)
		findNextBtn.BackgroundTransparency = 1
		findNextBtn.Image = Icons.FindNext
		findNextBtn.Parent = row1Find

		local closeBtn = Instance.new("ImageButton")
		closeBtn.Name = "CloseBtn"
		closeBtn.Size = UDim2.new(0, 20, 0, 20)
		closeBtn.Position = UDim2.new(0, 241, 0, 2)
		closeBtn.BackgroundTransparency = 1
		closeBtn.Image = Icons.FindClose
		closeBtn.Parent = row1Find

		local row2Replace = Instance.new("Frame")
		row2Replace.Name = "Row2_Replace"
		row2Replace.Size = UDim2.new(1, 0, 0, 24)
		row2Replace.Position = UDim2.new(0, 0, 0, 28)
		row2Replace.BackgroundTransparency = 1
		row2Replace.Parent = mainFrame

		local replaceBox = Instance.new("TextBox")
		replaceBox.Name = "ReplaceBox"
		replaceBox.Size = UDim2.new(0, 155, 1, 0)
		replaceBox.Position = UDim2.new(0, 24, 0, 0)
		replaceBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
		replaceBox.TextColor3 = Color3.fromRGB(204, 204, 204)
		replaceBox.BorderSizePixel = 0
		replaceBox.TextSize = 14
		replaceBox.Font = Enum.Font.RobotoMono
		replaceBox.TextXAlignment = Enum.TextXAlignment.Left
		replaceBox.PlaceholderText = "Replace..."
		replaceBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
		replaceBox.ClearTextOnFocus = false
		replaceBox.Text = ""
		replaceBox.Parent = row2Replace

		local replaceBoxPadding = Instance.new("UIPadding")
		replaceBoxPadding.Name = "UIPadding"
		replaceBoxPadding.Parent = replaceBox

		local replaceNextBtn = Instance.new("ImageButton")
		replaceNextBtn.Name = "ReplaceNextBtn"
		replaceNextBtn.Size = UDim2.new(0, 20, 0, 20)
		replaceNextBtn.Position = UDim2.new(0, 185, 0, 2)
		replaceNextBtn.BackgroundTransparency = 1
		replaceNextBtn.Parent = row2Replace

		local replaceAllBtn = Instance.new("ImageButton")
		replaceAllBtn.Name = "ReplaceAllBtn"
		replaceAllBtn.Size = UDim2.new(0, 20, 0, 20)
		replaceAllBtn.Position = UDim2.new(0, 209, 0, 2)
		replaceAllBtn.BackgroundTransparency = 1
		replaceAllBtn.Parent = row2Replace

		local row3Options = Instance.new("Frame")
		row3Options.Name = "Row3_Options"
		row3Options.Size = UDim2.new(1, 0, 0, 20)
		row3Options.Position = UDim2.new(0, 0, 0, 56)
		row3Options.BackgroundTransparency = 1
		row3Options.Parent = mainFrame

		local matchCaseBtn = Instance.new("ImageButton")
		matchCaseBtn.Name = "MatchCaseBtn"
		matchCaseBtn.Size = UDim2.new(0, 20, 0, 20)
		matchCaseBtn.Position = UDim2.new(0, 24, 0, 0)
		matchCaseBtn.BackgroundTransparency = 1
		matchCaseBtn.Image = Icons.FindMatchCase
		matchCaseBtn.Parent = row3Options

		local matchWholeWordBtn = Instance.new("ImageButton")
		matchWholeWordBtn.Name = "MatchWholeWordBtn"
		matchWholeWordBtn.Size = UDim2.new(0, 20, 0, 20)
		matchWholeWordBtn.Position = UDim2.new(0, 48, 0, 0)
		matchWholeWordBtn.BackgroundTransparency = 1
		matchWholeWordBtn.Image = Icons.FindWholeWord
		matchWholeWordBtn.Parent = row3Options

		local useRegexBtn = Instance.new("ImageButton")
		useRegexBtn.Name = "UseRegexBtn"
		useRegexBtn.Size = UDim2.new(0, 20, 0, 20)
		useRegexBtn.Position = UDim2.new(0, 72, 0, 0)
		useRegexBtn.BackgroundTransparency = 1
		useRegexBtn.Image = Icons.FindRegex
		useRegexBtn.Parent = row3Options

		local showLabel = Instance.new("TextLabel")
		showLabel.Name = "Show"
		showLabel.Size = UDim2.new(0.68, 0, 1, 0)
		showLabel.Position = UDim2.new(0.32, 0, 0, 0)
		showLabel.BackgroundTransparency = 1
		showLabel.TextColor3 = Color3.new(1, 1, 1)
		showLabel.TextSize = 14
		showLabel.Font = Enum.Font.RobotoMono
		showLabel.TextXAlignment = Enum.TextXAlignment.Left
		showLabel.Text = ""
		showLabel.Parent = row3Options

		local uiScale = Instance.new("UIScale")
		uiScale.Name = "UIScale"
		uiScale.Parent = mainFrame

		return mainFrame
	end

	local templateMenu = createFindMenu()
	if self.FindUI or not templateMenu then return end

	local findUI = templateMenu:Clone()
	self.FindUI = findUI
	findUI.AnchorPoint = Vector2.new(1, 0)
	findUI.Position = UDim2.new(1, -20, 0, 8)
	findUI.ZIndex = 100
	for _, desc in ipairs(findUI:GetDescendants()) do
		if desc:IsA("GuiObject") then
			desc.ZIndex = 101
		end
	end
	findUI.Parent = self.CanvasGroup

	self.FindMatches = {}
	self.CurrentMatchIndex = 0

	local row2 = findUI:FindFirstChild("Row2_Replace")
	local row3 = findUI:FindFirstChild("Row3_Options")
	local isMenuExpanded = false
	local findOptions = { MatchCase = false, WholeWord = false, Regex = false }

	if row2 then row2.Visible = false end
	if row3 then row3.Position = UDim2.new(0, 0, 0, 28) end
	findUI.Size = UDim2.new(0, 260, 0, 62)

	local function addHoverEffect(button)
		local hoverFrame = Instance.new("Frame")
		hoverFrame.Name = "HoverFrame"
		hoverFrame.Size = UDim2.new(1, 0, 1, 0)
		hoverFrame.Position = UDim2.new(0, 0, 0, 0)
		hoverFrame.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
		hoverFrame.BackgroundTransparency = 1
		hoverFrame.BorderSizePixel = 0
		hoverFrame.ZIndex = 1
		hoverFrame.Parent = button
		button.MouseEnter:Connect(function() hoverFrame.BackgroundTransparency = 0.5 end)
		button.MouseLeave:Connect(function() hoverFrame.BackgroundTransparency = 1 end)
	end

	local showMatchLabel = row3 and row3:FindFirstChild("Show")

	local function updateMatches(queryText, avoidJumping)
		self.FindMatches = {}
		if not showMatchLabel then return end
		if not queryText or queryText == "" then
			showMatchLabel.Text = ""
			if not avoidJumping then
				self.SelectionStart = self.CursorIndex
				self:UpdateBlinker(true)
			else
				self:UpdateBlinker(false)
			end
			return
		end
		local currentEditorText = self.CanvasGroup:GetAttribute("Text") or ""
		local queryTrimmed = queryText:match("^(.-)%s*$")
		if not queryTrimmed or queryTrimmed == "" then queryTrimmed = queryText end
		local searchStart = 1
		while true do
			local startPos, endPos
			if findOptions.Regex then
				local pattern = queryText
				if not findOptions.MatchCase then pattern = pattern:lower() end
				if findOptions.WholeWord then pattern = "%f[%w_]" .. pattern .. "%f[^%w_]" end
				local targetText = findOptions.MatchCase and currentEditorText or currentEditorText:lower()
				local success, s, e = pcall(function() return targetText:find(pattern, searchStart, false) end)
				if success then startPos, endPos = s, e end
			else
				local pattern = queryText:gsub("([%%%.%+%-%*%?%[%]%^%$%(%)])", "%%%1")
				if not findOptions.MatchCase then pattern = pattern:lower() end
				if findOptions.WholeWord then pattern = "%f[%w_]" .. pattern .. "%f[^%w_]" end
				local targetText = findOptions.MatchCase and currentEditorText or currentEditorText:lower()
				startPos, endPos = targetText:find(pattern, searchStart, false)
			end

			if not startPos then break end
			table.insert(self.FindMatches, {s = startPos - 1, e = endPos})
			searchStart = endPos + 1
		end
		local matchCount = #self.FindMatches
		if matchCount == 0 then
			showMatchLabel.Text = "No results"
			if not avoidJumping then
				self.SelectionStart = self.CursorIndex
				self:UpdateBlinker(true)
			else
				self:UpdateBlinker(false)
			end
			return
		end
		if not avoidJumping then
			self.CurrentMatchIndex = 1
			showMatchLabel.Text = "1 of " .. matchCount .. " matches"
			self.SelectionStart = self.FindMatches[1].s
			self.CursorIndex = self.FindMatches[1].e
			self:UpdateBlinker(true)
		else
			if self.CurrentMatchIndex > matchCount then self.CurrentMatchIndex = matchCount end
			if self.CurrentMatchIndex < 1 then self.CurrentMatchIndex = 1 end
			showMatchLabel.Text = self.CurrentMatchIndex .. " of " .. matchCount .. " matches"
			self:UpdateBlinker(false)
		end
	end

	local function jumpToMatch(index)
		local matchCount = #self.FindMatches
		if matchCount == 0 then return end
		if index < 1 then index = matchCount end
		if index > matchCount then index = 1 end
		self.CurrentMatchIndex = index
		if showMatchLabel then showMatchLabel.Text = index .. " of " .. matchCount .. " matches" end
		self.SelectionStart = self.FindMatches[index].s
		self.CursorIndex = self.FindMatches[index].e
		self:UpdateBlinker(true)
	end

	local row1 = findUI:FindFirstChild("Row1_Find")
	if row1 then
		local btnClose = row1:FindFirstChild("CloseBtn")
		if btnClose then
			addHoverEffect(btnClose)
			btnClose.MouseButton1Click:Connect(function() self:CloseFindUI() end)
		end
		local btnFindPrev = row1:FindFirstChild("FindPrevBtn")
		if btnFindPrev then
			addHoverEffect(btnFindPrev)
			btnFindPrev.MouseButton1Click:Connect(function() jumpToMatch(self.CurrentMatchIndex - 1) end)
		end
		local btnFindNext = row1:FindFirstChild("FindNextBtn")
		if btnFindNext then
			addHoverEffect(btnFindNext)
			btnFindNext.MouseButton1Click:Connect(function() jumpToMatch(self.CurrentMatchIndex + 1) end)
		end
		local btnToggleExpand = row1:FindFirstChild("ToggleExpandBtn")
		if btnToggleExpand then
			addHoverEffect(btnToggleExpand)
			local iconTopChevron = btnToggleExpand:FindFirstChild("TopChevron")
			local iconBottomChevron = btnToggleExpand:FindFirstChild("BottomChevron")
			btnToggleExpand.MouseButton1Click:Connect(function()
				isMenuExpanded = not isMenuExpanded
				if iconTopChevron then iconTopChevron.Rotation = isMenuExpanded and 180 or 0 end
				if iconBottomChevron then iconBottomChevron.Rotation = isMenuExpanded and 180 or 0 end
				if row2 then row2.Visible = isMenuExpanded end
				local currentWidthVal = math.min(260, self.CanvasGroup.AbsoluteSize.X - 16)
				if currentWidthVal < 180 then currentWidthVal = 180 end
				if isMenuExpanded then
					if row3 then row3.Position = UDim2.new(0, 0, 0, 56) end
					findUI.Size = UDim2.new(0, currentWidthVal, 0, 88)
				else
					if row3 then row3.Position = UDim2.new(0, 0, 0, 28) end
					findUI.Size = UDim2.new(0, currentWidthVal, 0, 62)
				end
			end)
		end
		local searchInputBox = row1:FindFirstChild("FindBox")
		if searchInputBox then
			searchInputBox.MultiLine = false
			searchInputBox.ClearTextOnFocus = false
			searchInputBox.Focused:Connect(function()
				self:Unfocus()
			end)
			searchInputBox.FocusLost:Connect(function(enterPressed)
				if enterPressed then
					jumpToMatch(self.CurrentMatchIndex + 1)
					task.defer(function()
						if searchInputBox and self.FindUI then
							searchInputBox:CaptureFocus()
							searchInputBox.CursorPosition = #searchInputBox.Text + 1
						end
					end)
				elseif not self.FindUI then
					self:Focus()
				end
			end)
			searchInputBox:GetPropertyChangedSignal("Text"):Connect(function()
				local rawSearchText = searchInputBox.Text
				local cleanSearchText = rawSearchText:gsub("[\n\r]", "")
				if rawSearchText ~= cleanSearchText then
					searchInputBox.Text = cleanSearchText
					return
				end
				updateMatches(cleanSearchText, false)
			end)
			if self.SelectionStart ~= self.CursorIndex then
				local selStart = math.min(self.SelectionStart, self.CursorIndex)
				local selEnd = math.max(self.SelectionStart, self.CursorIndex)
				local editorFullText = self.CanvasGroup:GetAttribute("Text") or ""
				local selectedString = editorFullText:sub(selStart + 1, selEnd)
				if selectedString ~= "" then
					local cleanedSelectedString = selectedString:gsub("[\n\r]", "")
					searchInputBox.Text = cleanedSelectedString
				end
			end
			self.FindTextConn = self.CanvasGroup:GetAttributeChangedSignal("Text"):Connect(function()
				if searchInputBox then updateMatches(searchInputBox.Text, true) end
			end)
		end
	end

	if row2 then
		local btnReplaceNext = row2:FindFirstChild("ReplaceNextBtn")
		if btnReplaceNext then addHoverEffect(btnReplaceNext) end
		local btnReplaceAll = row2:FindFirstChild("ReplaceAllBtn")
		if btnReplaceAll then addHoverEffect(btnReplaceAll) end
		local replaceInputBox = row2:FindFirstChild("ReplaceBox")
		if replaceInputBox then
			replaceInputBox.MultiLine = false
			replaceInputBox.ClearTextOnFocus = false
			replaceInputBox.Focused:Connect(function()
				self:Unfocus()
			end)
			replaceInputBox:GetPropertyChangedSignal("Text"):Connect(function()
				local rawReplaceText = replaceInputBox.Text
				local cleanReplaceText = rawReplaceText:gsub("[\n\r]", "")
				if rawReplaceText ~= cleanReplaceText then replaceInputBox.Text = cleanReplaceText end
			end)
		end
	end

	if row3 then
		local function updateOptionBtn(btn, state)
			if not btn then return end
			btn.ImageColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
		end
		local searchInputBox = row1 and row1:FindFirstChild("FindBox")

		local btnMatchCase = row3:FindFirstChild("MatchCaseBtn")
		if btnMatchCase then
			addHoverEffect(btnMatchCase)
			updateOptionBtn(btnMatchCase, findOptions.MatchCase)
			btnMatchCase.MouseButton1Click:Connect(function()
				findOptions.MatchCase = not findOptions.MatchCase
				updateOptionBtn(btnMatchCase, findOptions.MatchCase)
				if searchInputBox then updateMatches(searchInputBox.Text, false) end
			end)
		end

		local btnMatchWholeWord = row3:FindFirstChild("MatchWholeWordBtn")
		if btnMatchWholeWord then
			addHoverEffect(btnMatchWholeWord)
			updateOptionBtn(btnMatchWholeWord, findOptions.WholeWord)
			btnMatchWholeWord.MouseButton1Click:Connect(function()
				findOptions.WholeWord = not findOptions.WholeWord
				updateOptionBtn(btnMatchWholeWord, findOptions.WholeWord)
				if searchInputBox then updateMatches(searchInputBox.Text, false) end
			end)
		end

		local btnUseRegex = row3:FindFirstChild("UseRegexBtn")
		if btnUseRegex then
			addHoverEffect(btnUseRegex)
			updateOptionBtn(btnUseRegex, findOptions.Regex)
			btnUseRegex.MouseButton1Click:Connect(function()
				findOptions.Regex = not findOptions.Regex
				updateOptionBtn(btnUseRegex, findOptions.Regex)
				if searchInputBox then updateMatches(searchInputBox.Text, false) end
			end)
		end
	end

	self.FindResizeConn = self.CanvasGroup:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if not self.FindUI then return end
		local updatedWidth = math.min(260, self.CanvasGroup.AbsoluteSize.X - 16)
		if updatedWidth < 180 then updatedWidth = 180 end
		local currentMenuHeight = self.FindUI.Size.Y.Offset
		self.FindUI.Size = UDim2.new(0, updatedWidth, 0, currentMenuHeight)
	end)
end

function Baseline:CloseFindUI()
	if not self.FindUI then return end
	local menuToClose = self.FindUI
	self.FindUI = nil
	menuToClose:Destroy()
	if self.FindTextConn then
		self.FindTextConn:Disconnect()
		self.FindTextConn = nil
	end
	if self.FindResizeConn then
		self.FindResizeConn:Disconnect()
		self.FindResizeConn = nil
	end
	self.FindMatches = {}
	self.CurrentMatchIndex = 0
	self.SelectionStart = self.CursorIndex
	self:UpdateBlinker(true)
end

function Baseline:Import(module)
	if typeof(module) == "string" then
		local syntaxModule = self.CanvasGroup:FindFirstChild(module)
		if syntaxModule and syntaxModule:IsA("ModuleScript") then
			local rules = require(syntaxModule)
			if type(rules) == "function" then rules = rules() end
			self:ApplyThemeRules(rules)
		end
	elseif typeof(module) == "Instance" and module:IsA("ModuleScript") then
		local rules = require(module)
		if type(rules) == "function" then rules = rules() end
		self:ApplyThemeRules(rules)
	elseif type(module) == "table" then
		self:ApplyThemeRules(module)
	end
end

function Baseline:ImportTheme(url)
	task.spawn(function()
		pcall(function()
			local source = ""
			local loadFunc = loadstring or (getfenv and getfenv().loadstring)
			local function fetchUrl()
				if getgenv and getgenv().game and getgenv().game.HttpGet then
					return getgenv().game:HttpGet(url)
				elseif game and game.HttpGet then
					return game:HttpGet(url)
				else
					return HttpService:GetAsync(url)
				end
			end
			source = fetchUrl()
			if loadFunc then
				local fn = loadFunc(source)
				if fn then
					local result = fn()
					local rules = type(result) == "function" and result() or result
					self:ApplyThemeRules(rules)
				end
			end
		end)
	end)
end

function Baseline:GetSyntaxStateAt(text, targetIndex, startIdx, startStateStr)
	local currentIndex = startIdx or 1
	local currentState = startStateStr
	while currentIndex < targetIndex do
		if currentState and currentState ~= "none" then
			local sType, sClose = currentState:match("^(.-)_(.-)$")
			if not sType then sType = "comment"; sClose = "\n" end
			if currentState == "comment_\\n" then
				local nextNewline = text:find("\n", currentIndex, true)
				if nextNewline and nextNewline < targetIndex then
					currentIndex = nextNewline + 1
					currentState = "none"
				else
					break
				end
			elseif sType == "string" and (sClose == '"' or sClose == "'") then
				local endStringIdx = nil
				local searchIdx = currentIndex
				while searchIdx < targetIndex do
					local nextQuote = text:find(sClose, searchIdx, true)
					if not nextQuote then break end
					local backslashCount = 0
					local backslashIdx = nextQuote - 1
					while backslashIdx >= 1 and text:sub(backslashIdx, backslashIdx) == "\\" do
						backslashCount = backslashCount + 1
						backslashIdx = backslashIdx - 1
					end
					if (backslashCount % 2) == 0 then
						endStringIdx = nextQuote
						break
					else
						searchIdx = nextQuote + 1
					end
				end
				if endStringIdx and endStringIdx < targetIndex then
					currentIndex = endStringIdx + 1
					currentState = "none"
				else
					break
				end
			else
				local endSpecialIdx = text:find(sClose, currentIndex, true)
				if endSpecialIdx and (endSpecialIdx + #sClose) <= targetIndex then
					currentIndex = endSpecialIdx + #sClose
					currentState = "none"
				else
					break
				end
			end
		else
			local nextSpecialChar = text:find('[\"\'%[%-]', currentIndex)
			if not nextSpecialChar or nextSpecialChar >= targetIndex then break end
			currentIndex = nextSpecialChar
			local character = text:sub(currentIndex, currentIndex)
			if character == '"' or character == "'" then
				currentState = "string_" .. character
				currentIndex = currentIndex + 1
			elseif character == "[" and text:sub(currentIndex, currentIndex + 20):match("^%[=*%[") then
				local bracketMatch = text:sub(currentIndex, currentIndex + 20):match("^%[=*%[")
				local closeStr = "]" .. string.rep("=", #bracketMatch - 2) .. "]"
				currentState = "string_" .. closeStr
				currentIndex = currentIndex + #bracketMatch
			elseif character == "-" and text:sub(currentIndex + 1, currentIndex + 1) == "-" then
				local commentMatch = text:sub(currentIndex + 2, currentIndex + 22):match("^%[=*%[")
				if commentMatch then
					local closeStr = "]" .. string.rep("=", #commentMatch - 2) .. "]"
					currentState = "comment_" .. closeStr
					currentIndex = currentIndex + 2 + #commentMatch
				else
					currentState = "comment_\\n"
					currentIndex = currentIndex + 2
				end
			else
				currentIndex = currentIndex + 1
			end
		end
	end
	return currentState
end

function Baseline:ApplySyntaxCached(lineData, lineText, startState)
	local stateKey = startState or "none"
	if lineData.richText and lineData.syntaxStateStr == stateKey then
		return lineData.richText
	end
	local richText = self:ApplySyntax(lineText, startState)
	lineData.richText = richText
	lineData.syntaxStateStr = stateKey
	return richText
end

function Baseline:ApplySyntax(lineText, startStateStr)
	if type(self.SyntaxRules) ~= "table" or lineText == "" then return Utils.escapeRichText(lineText) end
	if #lineText > 25000 then return Utils.escapeRichText(lineText) end
	local resultsTable = {}
	local textLength = #lineText
	local currentIndex = 1
	local currentState = startStateStr
	local function getRuleHexColor(ruleName, defaultHex)
		if type(self.SyntaxRules) ~= "table" then return defaultHex end
		local ruleData = self.SyntaxRules[ruleName]
		if ruleData and ruleData.color then
			return string.format("#%02X%02X%02X", math.floor(ruleData.color.R * 255 + 0.5), math.floor(ruleData.color.G * 255 + 0.5), math.floor(ruleData.color.B * 255 + 0.5))
		end
		return defaultHex
	end
	local commentHexColor = getRuleHexColor("comment_single", "#6272A4")
	local stringHexColor = getRuleHexColor("string_literal", "#F1FA8C")
	local operatorHexColor = getRuleHexColor("op_add", "#BCBEC8")
	local defaultHexColor = getRuleHexColor("TextColor", "#F8F8F2")
	if currentState and currentState ~= "none" then
		local sType, sClose = currentState:match("^(.-)_(.-)$")
		if not sType then sType = "comment"; sClose = "\n" end
		if sClose == "\\n" then
			table.insert(resultsTable, '<font color="' .. commentHexColor .. '">' .. Utils.escapeRichText(lineText) .. "</font>")
			return table.concat(resultsTable)
		end
		local closeColor = (sType == "comment") and commentHexColor or stringHexColor
		local endStateIndex = nil
		if sType == "string" and (sClose == '"' or sClose == "'") then
			local searchIdx = currentIndex
			while searchIdx <= textLength do
				local nextQuoteIdx = lineText:find(sClose, searchIdx, true)
				if not nextQuoteIdx then break end
				local backslashCount = 0
				local backslashIdx = nextQuoteIdx - 1
				while backslashIdx >= 1 and lineText:sub(backslashIdx, backslashIdx) == "\\" do
					backslashCount = backslashCount + 1
					backslashIdx = backslashIdx - 1
				end
				if (backslashCount % 2) == 0 then
					endStateIndex = nextQuoteIdx
					break
				else
					searchIdx = nextQuoteIdx + 1
				end
			end
		else
			endStateIndex = lineText:find(sClose, currentIndex, true)
		end
		if endStateIndex then
			local subWord = lineText:sub(currentIndex, (endStateIndex + #sClose) - 1)
			table.insert(resultsTable, '<font color="' .. closeColor .. '">' .. Utils.escapeRichText(subWord) .. "</font>")
			currentIndex = endStateIndex + #sClose
			currentState = "none"
		else
			table.insert(resultsTable, '<font color="' .. closeColor .. '">' .. Utils.escapeRichText(lineText:sub(currentIndex)) .. "</font>")
			return table.concat(resultsTable)
		end
	end
	while currentIndex <= textLength do
		local character = lineText:sub(currentIndex, currentIndex)
		if character:match("[%a_]") then
			local startWordIdx = currentIndex
			while currentIndex <= textLength and lineText:sub(currentIndex, currentIndex):match("[%w_]") do
				currentIndex = currentIndex + 1
			end
			local wordString = lineText:sub(startWordIdx, currentIndex - 1)
			local isFunctionCall = false
			local nextCharIdx = currentIndex
			while nextCharIdx <= textLength and lineText:sub(nextCharIdx, nextCharIdx):match("%s") do
				nextCharIdx = nextCharIdx + 1
			end
			if nextCharIdx <= textLength and lineText:sub(nextCharIdx, nextCharIdx) == "(" then
				isFunctionCall = true
			end
			local ruleData = type(self.SyntaxRules) == "table" and self.SyntaxRules[wordString] or nil
			local wordHex = defaultHexColor
			local isBold = false
			if ruleData then
				if ruleData.color then
					wordHex = string.format("#%02X%02X%02X", math.floor(ruleData.color.R * 255 + 0.5), math.floor(ruleData.color.G * 255 + 0.5), math.floor(ruleData.color.B * 255 + 0.5))
				end
				if wordString == "local" or ruleData.type == "keyword" then
					isBold = true
				end
			elseif isFunctionCall then
				wordHex = getRuleHexColor("function_name", "#50FA7B")
			end
			if isBold then
				table.insert(resultsTable, '<font color="' .. wordHex .. '" weight="SemiBold">' .. Utils.escapeRichText(wordString) .. "</font>")
			else
				table.insert(resultsTable, '<font color="' .. wordHex .. '">' .. Utils.escapeRichText(wordString) .. "</font>")
			end
		elseif character:match("%d") then
			local startNumIdx = currentIndex
			while currentIndex <= textLength and lineText:sub(currentIndex, currentIndex):match("[%d%.]") do
				currentIndex = currentIndex + 1
			end
			local numberString = lineText:sub(startNumIdx, currentIndex - 1)
			local numberHex = getRuleHexColor("num_integer", "#FFB86C")
			table.insert(resultsTable, '<font color="' .. numberHex .. '">' .. Utils.escapeRichText(numberString) .. "</font>")
		elseif character == '"' or character == "'" then
			local startQuoteIdx = currentIndex
			local quoteChar = character
			currentIndex = currentIndex + 1
			while currentIndex <= textLength do
				local nextQuoteMatch = lineText:find(quoteChar, currentIndex, true)
				if not nextQuoteMatch then
					currentIndex = textLength + 1
					break
				end
				local backslashCount = 0
				local backslashIdx = nextQuoteMatch - 1
				while backslashIdx >= (startQuoteIdx + 1) and lineText:sub(backslashIdx, backslashIdx) == "\\" do
					backslashCount = backslashCount + 1
					backslashIdx = backslashIdx - 1
				end
				if (backslashCount % 2) == 0 then
					currentIndex = nextQuoteMatch + 1
					break
				else
					currentIndex = nextQuoteMatch + 1
				end
			end
			local fullString = lineText:sub(startQuoteIdx, currentIndex - 1)
			table.insert(resultsTable, '<font color="' .. stringHexColor .. '">' .. Utils.escapeRichText(fullString) .. "</font>")
		elseif character == "[" and lineText:sub(currentIndex, currentIndex + 20):match("^%[=*%[") then
			local startBracketIdx = currentIndex
			local bracketMatch = lineText:sub(currentIndex, currentIndex + 20):match("^%[=*%[")
			local closeBracketStr = "]" .. string.rep("=", #bracketMatch - 2) .. "]"
			local endBracketIdx = lineText:find(closeBracketStr, currentIndex + #bracketMatch, true)
			if endBracketIdx then
				currentIndex = endBracketIdx + #closeBracketStr
			else
				currentIndex = textLength + 1
			end
			local multilineString = lineText:sub(startBracketIdx, currentIndex - 1)
			table.insert(resultsTable, '<font color="' .. stringHexColor .. '">' .. Utils.escapeRichText(multilineString) .. "</font>")
		elseif character == "-" and lineText:sub(currentIndex + 1, currentIndex + 1) == "-" then
			local startCommentIdx = currentIndex
			local commentMatch = lineText:sub(currentIndex + 2, currentIndex + 22):match("^%[=*%[")
			if commentMatch then
				local closeCommentStr = "]" .. string.rep("=", #commentMatch - 2) .. "]"
				local endCommentIdx = lineText:find(closeCommentStr, currentIndex + 2 + #commentMatch, true)
				if endCommentIdx then
					currentIndex = endCommentIdx + #closeCommentStr
				else
					currentIndex = textLength + 1
				end
			else
				currentIndex = textLength + 1
			end
			local fullComment = lineText:sub(startCommentIdx, currentIndex - 1)
			table.insert(resultsTable, '<font color="' .. commentHexColor .. '">' .. Utils.escapeRichText(fullComment) .. "</font>")
		elseif character:match("[%p]") then
			local op2 = lineText:sub(currentIndex, currentIndex + 1)
			local ruleName = KeyMaps.Operators[op2]
			local step = 1
			local opStr = character
			if ruleName then
				step = 2
				opStr = op2
			else
				ruleName = KeyMaps.Operators[character]
			end
			local hex = operatorHexColor
			if ruleName and type(self.SyntaxRules) == "table" and self.SyntaxRules[ruleName] then
				local color = self.SyntaxRules[ruleName].color
				if color then
					hex = string.format("#%02X%02X%02X", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
				end
			end
			table.insert(resultsTable, '<font color="' .. hex .. '">' .. Utils.escapeRichText(opStr) .. "</font>")
			currentIndex = currentIndex + step
		else
			table.insert(resultsTable, '<font color="' .. defaultHexColor .. '">' .. Utils.escapeRichText(character) .. "</font>")
			currentIndex = currentIndex + 1
		end
	end
	return table.concat(resultsTable)
end

function Baseline:GetDisplayText()
	local rawText = self.CanvasGroup:GetAttribute("Text") or ""
	if self.CanvasGroup:GetAttribute("PasswordMode") then return string.rep(".", utf8.len(rawText) or #rawText) end
	return rawText
end

function Baseline:PushHistory()
	local currentText = self.CanvasGroup:GetAttribute("Text") or ""
	if self.History[self.HistoryIdx].text == currentText then return end
	while #self.History > self.HistoryIdx do table.remove(self.History) end
	table.insert(self.History, {text = currentText, cursor = self.CursorIndex, sel = self.SelectionStart})
	self.HistoryIdx = #self.History
end

function Baseline:Undo()
	if self.HistoryIdx > 1 then
		self.HistoryIdx = self.HistoryIdx - 1
		local previousState = self.History[self.HistoryIdx]
		self.CanvasGroup:SetAttribute("Text", previousState.text)
		self.CursorIndex = previousState.cursor
		self.SelectionStart = previousState.sel
		self:UpdateBlinker(true)
	end
end

function Baseline:Redo()
	if self.HistoryIdx < #self.History then
		self.HistoryIdx = self.HistoryIdx + 1
		local nextState = self.History[self.HistoryIdx]
		self.CanvasGroup:SetAttribute("Text", nextState.text)
		self.CursorIndex = nextState.cursor
		self.SelectionStart = nextState.sel
		self:UpdateBlinker(true)
	end
end

function Baseline:Copy()
	if self.SelectionStart ~= self.CursorIndex then
		local selStart = math.min(self.SelectionStart, self.CursorIndex)
		local selEnd = math.max(self.SelectionStart, self.CursorIndex)
		local currentText = self.CanvasGroup:GetAttribute("Text") or ""
		Baseline.Clipboard = currentText:sub(selStart + 1, selEnd)
		local clipboardFunction = setclipboard
		if clipboardFunction then clipboardFunction(Baseline.Clipboard) end
	end
end

function Baseline:Cut()
	if self.CanvasGroup:GetAttribute("ReadOnly") then return end
	self:Copy()
	self:DeleteSelection()
end

function Baseline:PasteChunked(text)
	if self.CanvasGroup:GetAttribute("ReadOnly") then return end
	if self.IsPasting then return end
	self.IsPasting = true
	text = text:gsub("\r", ""):gsub("\t", "    ")
	local maxLength = self.CanvasGroup:GetAttribute("MaxLength")
	if maxLength and maxLength > 0 then
		local currentLength = utf8.len(self.CanvasGroup:GetAttribute("Text") or "") or 0
		local minIndex = math.min(self.SelectionStart, self.CursorIndex)
		local maxIndex = math.max(self.SelectionStart, self.CursorIndex)
		local selectedTextLength = utf8.len((self.CanvasGroup:GetAttribute("Text") or ""):sub(minIndex + 1, maxIndex)) or 0
		local remainingSpace = maxLength - (currentLength - selectedTextLength)
		if remainingSpace <= 0 then
			self.IsPasting = false
			return
		end
		local endOffset = utf8.offset(text, remainingSpace + 1)
		if endOffset then text = text:sub(1, endOffset - 1) end
	end
	task.spawn(function()
		if self.SelectionStart ~= self.CursorIndex then self:DeleteSelection() end
		local currentText = self.CanvasGroup:GetAttribute("Text") or ""
		local stringBefore = currentText:sub(1, self.CursorIndex)
		local stringAfter = currentText:sub(self.CursorIndex + 1)
		self.CursorIndex = self.CursorIndex + #text
		self.SelectionStart = self.CursorIndex
		self.CanvasGroup:SetAttribute("Text", stringBefore .. text .. stringAfter)
		self:PushHistory()
		self.IsPasting = false
		self:UpdateBlinker(true)
	end)
end

function Baseline:Paste()
	if self.CanvasGroup:GetAttribute("ReadOnly") then return end
	if Baseline.Clipboard and Baseline.Clipboard ~= "" then self:PasteChunked(Baseline.Clipboard) end
end

function Baseline:Focus()
	if self.IsFocused then return end
	self.IsFocused = true
	self.Blinker.Visible = self.SelectionStart == self.CursorIndex
	self.BlinkTimer = 0
	ContextActionService:BindAction(self.SinkActionName, function() return Enum.ContextActionResult.Sink end, false, unpack(KeyMaps.SinkKeys))
	self.PasteBox:CaptureFocus()
	self:UpdateBlinker(true)
end

function Baseline:Unfocus()
	if not self.IsFocused then return end
	self.IsFocused = false
	self.Blinker.Visible = false
	self.HeldKey = nil
	self.IsDragging = false
	self.DraggingMinimap = false
	self.SelectionStart = self.CursorIndex
	self:HideAutocomplete()
	self:UpdateBlinker(true)
	ContextActionService:UnbindAction(self.SinkActionName)
	self.PasteBox:ReleaseFocus()
end

function Baseline:HideAutocomplete()
	self.AutocompleteVisible = false
	self.AutocompleteUI.Visible = false
	self.AutocompleteHint.Visible = false
	self.GhostTextLabel.Visible = false
	self.AutocompleteMatches = {}
	self.AutocompleteIndex = 1
end

function Baseline:RenderAutocomplete()
	self.AutocompleteVisible = true
	self.AutocompleteUI.Visible = true
	for _, child in ipairs(self.AutocompleteScroll:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end
	local yOffset = 0
	for i, match in ipairs(self.AutocompleteMatches) do
		local isSelected = (i == self.AutocompleteIndex)
		local rowFrame = Instance.new("Frame")
		rowFrame.Size = UDim2.new(1, 0, 0, 24)
		rowFrame.BackgroundColor3 = isSelected and self.AutocompleteSelectionColor or self.AutocompleteBackgroundColor
		rowFrame.BorderSizePixel = 0
		rowFrame.ZIndex = 101
		rowFrame.Parent = self.AutocompleteScroll
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.ZIndex = 102
		btn.Parent = rowFrame
		local icon = Instance.new("ImageLabel")
		icon.Size = UDim2.new(0, 16, 0, 16)
		icon.Position = UDim2.new(0, 6, 0.5, 0)
		icon.AnchorPoint = Vector2.new(0, 0.5)
		icon.BackgroundTransparency = 1
		icon.Image = match.icon
		icon.ResampleMode = Enum.ResamplerMode.Default
		icon.ZIndex = 102
		icon.Parent = rowFrame
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -30, 1, 0)
		label.Position = UDim2.new(0, 28, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = match.word
		label.TextColor3 = isSelected and self.AutocompleteSelectedTextColor or self.AutocompleteTextColor
		label.Font = Enum.Font.RobotoMono
		label.TextSize = 14
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.ZIndex = 102
		label.Parent = rowFrame
		btn.MouseButton1Click:Connect(function()
			self.AutocompleteIndex = i
			self:CommitAutocomplete()
		end)
		yOffset = yOffset + 24
	end
	self.AutocompleteScroll.CanvasSize = UDim2.new(0, 0, 0, yOffset)
	local scrollPos = self.AutocompleteScroll.CanvasPosition.Y
	local btnTop = (self.AutocompleteIndex - 1) * 24
	local btnBottom = btnTop + 24
	if btnTop < scrollPos then
		self.AutocompleteScroll.CanvasPosition = Vector2.new(0, btnTop)
	elseif btnBottom > scrollPos + self.AutocompleteScroll.AbsoluteWindowSize.Y then
		self.AutocompleteScroll.CanvasPosition = Vector2.new(0, btnBottom - self.AutocompleteScroll.AbsoluteWindowSize.Y)
	end
end

function Baseline:CommitAutocomplete()
	if not self.AutocompleteVisible or #self.AutocompleteMatches == 0 then return false end
	local match = self.AutocompleteMatches[self.AutocompleteIndex]
	local currentText = self.CanvasGroup:GetAttribute("Text") or ""
	local word = Utils.getWordBeforeCursor(currentText, self.CursorIndex)
	local stringBefore = currentText:sub(1, self.CursorIndex - #word)
	local stringAfter = currentText:sub(self.CursorIndex + 1)
	self.CanvasGroup:SetAttribute("Text", stringBefore .. match.word .. stringAfter)
	self.CursorIndex = #stringBefore + #match.word
	self.SelectionStart = self.CursorIndex
	self:PushHistory()
	self:HideAutocomplete()
	self:UpdateBlinker(true)
	return true
end

function Baseline:UpdateAutocompleteUI()
	if not self.IsFocused or self.SelectionStart ~= self.CursorIndex then
		self:HideAutocomplete()
		return
	end

	local text = self.CanvasGroup:GetAttribute("Text") or ""
	local word = Utils.getWordBeforeCursor(text, self.CursorIndex)

	if #word < 1 then
		self:HideAutocomplete()
		return
	end

	local dynamicMatches = {}
	local searchStart = math.max(1, self.CursorIndex - 15000)
	local searchEnd = math.min(#text, self.CursorIndex + 15000)
	local searchChunk = text:sub(searchStart, searchEnd)

	for varName in searchChunk:gmatch("local%s+([%w_]+)") do
		dynamicMatches[varName] = "Variable"
	end
	for funcName in searchChunk:gmatch("function%s+([%w_]+)") do
		dynamicMatches[funcName] = "Function"
	end
	for varName in searchChunk:gmatch("([%w_]+)%s*=") do
		if not dynamicMatches[varName] then
			dynamicMatches[varName] = "Variable"
		end
	end

	local matches = {}
	local wordLower = word:lower()
	local added = {}

	local function addMatch(mWord, mType, mIcon)
		if added[mWord] then return end
		if mWord:lower():sub(1, #wordLower) == wordLower then
			table.insert(matches, {word = mWord, type = mType, icon = mIcon})
			added[mWord] = true
		end
	end

	for dWord, dType in pairs(dynamicMatches) do
		addMatch(dWord, dType, Icons.Variable)
	end

	for _, item in ipairs(Utils.AutocompleteKeywords) do
		addMatch(item.word, item.type, item.icon)
		if #matches >= 50 then break end
	end

	if #matches == 0 then
		self:HideAutocomplete()
		return
	end

	if #matches == 1 and matches[1].word == word then
		self:HideAutocomplete()
		return
	end

	self.AutocompleteMatches = matches
	self.AutocompleteIndex = math.clamp(self.AutocompleteIndex, 1, #matches)
	self:RenderAutocomplete()
end

function Baseline:ProcessKey(keyCode, isShiftDown, isCtrlDown)
	if self.CanvasGroup:GetAttribute("ReadOnly") or self.IsPasting then
		if keyCode == Enum.KeyCode.Left or keyCode == Enum.KeyCode.Right or
		   keyCode == Enum.KeyCode.Up or keyCode == Enum.KeyCode.Down or
		   keyCode == Enum.KeyCode.Home or keyCode == Enum.KeyCode.End or
		   keyCode == Enum.KeyCode.PageUp or keyCode == Enum.KeyCode.PageDown then
		else
			return
		end
	end
	local displayedText = self:GetDisplayText()

	if self.AutocompleteVisible then
		local text = self.CanvasGroup:GetAttribute("Text") or ""
		local word = Utils.getWordBeforeCursor(text, self.CursorIndex)
		local match = self.AutocompleteMatches[self.AutocompleteIndex]

		if keyCode == Enum.KeyCode.Down then
			self.AutocompleteIndex = math.min(self.AutocompleteIndex + 1, #self.AutocompleteMatches)
			self:RenderAutocomplete()
			return
		elseif keyCode == Enum.KeyCode.Up then
			self.AutocompleteIndex = math.max(self.AutocompleteIndex - 1, 1)
			self:RenderAutocomplete()
			return
		elseif keyCode == Enum.KeyCode.Right then
			if self.GhostTextLabel.Visible then
				if self:CommitAutocomplete() then return end
			end
		elseif keyCode == Enum.KeyCode.Tab then
			if self:CommitAutocomplete() then return end
		elseif keyCode == Enum.KeyCode.Return or keyCode == Enum.KeyCode.KeypadEnter then
			if match and match.word == word then
				self:HideAutocomplete()
				return
			else
				if self:CommitAutocomplete() then return end
			end
		elseif keyCode == Enum.KeyCode.Escape then
			self:HideAutocomplete()
			return
		end
	end

	if keyCode == Enum.KeyCode.Tab then
		if self.CanvasGroup:GetAttribute("MultiLine") then
			if isShiftDown then
				local txt = self.CanvasGroup:GetAttribute("Text") or ""
				local before = txt:sub(1, self.CursorIndex)
				local after = txt:sub(self.CursorIndex + 1)
				local spaceCount = before:match(" +( *)$")
				if spaceCount then
					local removeLen = math.min(4, #spaceCount + 1)
					self.CanvasGroup:SetAttribute("Text", before:sub(1, -(removeLen + 1)) .. after)
					self.CursorIndex = self.CursorIndex - removeLen
					self.SelectionStart = self.CursorIndex
					self:PushHistory()
				end
			else
				self:AppendText("    ")
			end
			self:UpdateBlinker(true)
			return
		else
			local myTabIndex = self.CanvasGroup:GetAttribute("TabIndex") or 0
			local nextBaseline = nil
			local closestDistance = math.huge
			for _, baselineInstance in ipairs(Baseline.Instances) do
				local tabIndex = baselineInstance.CanvasGroup:GetAttribute("TabIndex") or 0
				if isShiftDown then
					if tabIndex < myTabIndex and (myTabIndex - tabIndex) < closestDistance then
						closestDistance = myTabIndex - tabIndex
						nextBaseline = baselineInstance
					end
				elseif tabIndex > myTabIndex and (tabIndex - myTabIndex) < closestDistance then
						closestDistance = tabIndex - myTabIndex
						nextBaseline = baselineInstance
				end
			end
			if nextBaseline then
				self:Unfocus()
				nextBaseline:Focus()
			end
			return
		end
	elseif keyCode == Enum.KeyCode.Backspace then
		self:RemoveChar()
	elseif keyCode == Enum.KeyCode.Return or keyCode == Enum.KeyCode.KeypadEnter then
		if self.CanvasGroup:GetAttribute("MultiLine") then
			self.LastTypedChar = "\n"
			self.LastTypedTick = tick()
			if self.SelectionStart ~= self.CursorIndex then self:DeleteSelection() end
			local currentText = self.CanvasGroup:GetAttribute("Text") or ""
			local stringBefore = currentText:sub(1, self.CursorIndex)
			local stringAfter = currentText:sub(self.CursorIndex + 1)
			local lineBeforeCursor = stringBefore:match("[^\n]*$") or ""
			local lineIndentation = lineBeforeCursor:match("^([ \t]*)") or ""
			local previousWord = lineBeforeCursor:match("([%w_]+)%s*$")
			local needsEndWord = {["then"]=true, ["do"]=true, ["repeat"]=true, ["function"]=true}
			if needsEndWord[previousWord] or lineBeforeCursor:match("function%s*.*%(.*%)%s*$") or lineBeforeCursor:match("^%s*do%s*$") then
				local insertedString = "\n" .. lineIndentation .. "    \n" .. lineIndentation .. "end"
				self.CanvasGroup:SetAttribute("Text", stringBefore .. insertedString .. stringAfter)
				self.CursorIndex = self.CursorIndex + 1 + #lineIndentation + 4
				self.SelectionStart = self.CursorIndex
				self:PushHistory()
			elseif (lineBeforeCursor:match("%{%s*$") and stringAfter:sub(1,1) == "}") or
				   (lineBeforeCursor:match("%(%s*$") and stringAfter:sub(1,1) == ")") or
				   (lineBeforeCursor:match("%[%s*$") and stringAfter:sub(1,1) == "]") then
				local insertedString = "\n" .. lineIndentation .. "    \n" .. lineIndentation
				self.CanvasGroup:SetAttribute("Text", stringBefore .. insertedString .. stringAfter)
				self.CursorIndex = self.CursorIndex + 1 + #lineIndentation + 4
				self.SelectionStart = self.CursorIndex
				self:PushHistory()
			elseif lineBeforeCursor:match("%{%s*$") or lineBeforeCursor:match("%(%s*$") or lineBeforeCursor:match("%[%s*$") then
				local insertedString = "\n" .. lineIndentation .. "    "
				self.CanvasGroup:SetAttribute("Text", stringBefore .. insertedString .. stringAfter)
				self.CursorIndex = self.CursorIndex + #insertedString
				self.SelectionStart = self.CursorIndex
				self:PushHistory()
			else
				local insertedString = "\n" .. lineIndentation
				self.CanvasGroup:SetAttribute("Text", stringBefore .. insertedString .. stringAfter)
				self.CursorIndex = self.CursorIndex + #insertedString
				self.SelectionStart = self.CursorIndex
				self:PushHistory()
			end
		end
	elseif keyCode == Enum.KeyCode.Left then
		if isCtrlDown then
			self.CursorIndex = Utils.getPrevWordBoundary(displayedText, self.CursorIndex)
		elseif self.SelectionStart ~= self.CursorIndex and not isShiftDown then
			self.CursorIndex = math.min(self.SelectionStart, self.CursorIndex)
		else
			local offsetPosition = utf8.offset(displayedText, -1, self.CursorIndex + 1)
			if offsetPosition then self.CursorIndex = offsetPosition - 1 end
		end
		if not isShiftDown then self.SelectionStart = self.CursorIndex end
		self:HideAutocomplete()
		self:UpdateBlinker(true)
	elseif keyCode == Enum.KeyCode.Right then
		if isCtrlDown then
			self.CursorIndex = Utils.getNextWordBoundary(displayedText, self.CursorIndex)
		elseif self.SelectionStart ~= self.CursorIndex and not isShiftDown then
			self.CursorIndex = math.max(self.SelectionStart, self.CursorIndex)
		elseif self.CursorIndex < #displayedText then
			local offsetPosition = utf8.offset(displayedText, 2, self.CursorIndex + 1)
			self.CursorIndex = offsetPosition and (offsetPosition - 1) or #displayedText
		end
		if not isShiftDown then self.SelectionStart = self.CursorIndex end
		self:HideAutocomplete()
		self:UpdateBlinker(true)
	elseif keyCode == Enum.KeyCode.Up then
		local font = self.CanvasGroup:GetAttribute("Font")
		local textSize = self.CanvasGroup:GetAttribute("TextSize")
		local lineMap = self:GetLineMapCached(displayedText, textSize, font, self:GetLimit())
		local currentLineIndex = 1
		for index, line in ipairs(lineMap) do
			local rEnd = line.renderEndIdx or line.endIdx
			if self.CursorIndex >= (line.startIdx - 1) and self.CursorIndex <= line.endIdx then
				currentLineIndex = index
				break
			end
		end
		if currentLineIndex > 1 then
			local prevLine = lineMap[currentLineIndex - 1]
			local rEndPrev = prevLine.renderEndIdx or prevLine.endIdx
			local subString = (prevLine.startIdx <= self.CursorIndex) and displayedText:sub(prevLine.startIdx, math.min(self.CursorIndex, rEndPrev)) or ""
			local length = utf8.len(subString) or #subString
			local charWidth = Utils.getTextSize("A", textSize, font, Vector2.new(10000, 10000)).X
			local currentX = length * charWidth
			self.CursorIndex = self:GetClosestIndexInLine(prevLine, currentX, displayedText, textSize, font)
		else
			self.CursorIndex = 0
		end
		if not isShiftDown then self.SelectionStart = self.CursorIndex end
		self:HideAutocomplete()
		self:UpdateBlinker(true)
	elseif keyCode == Enum.KeyCode.Down then
		local font = self.CanvasGroup:GetAttribute("Font")
		local textSize = self.CanvasGroup:GetAttribute("TextSize")
		local lineMap = self:GetLineMapCached(displayedText, textSize, font, self:GetLimit())
		local currentLineIndex = 1
		for index, line in ipairs(lineMap) do
			if self.CursorIndex >= (line.startIdx - 1) and self.CursorIndex <= line.endIdx then
				currentLineIndex = index
				break
			end
		end
		if currentLineIndex < #lineMap then
			local nextLine = lineMap[currentLineIndex + 1]
			local currentLineObj = lineMap[currentLineIndex]
			local rEndCur = currentLineObj.renderEndIdx or currentLineObj.endIdx
			local subString = (currentLineObj.startIdx <= self.CursorIndex) and displayedText:sub(currentLineObj.startIdx, math.min(self.CursorIndex, rEndCur)) or ""
			local length = utf8.len(subString) or #subString
			local charWidth = Utils.getTextSize("A", textSize, font, Vector2.new(10000, 10000)).X
			local currentX = length * charWidth
			self.CursorIndex = self:GetClosestIndexInLine(nextLine, currentX, displayedText, textSize, font)
		else
			self.CursorIndex = #displayedText
		end
		if not isShiftDown then self.SelectionStart = self.CursorIndex end
		self:HideAutocomplete()
		self:UpdateBlinker(true)
	elseif keyCode == Enum.KeyCode.Home then
		if isCtrlDown then
			self.CursorIndex = 0
		else
			local font = self.CanvasGroup:GetAttribute("Font")
			local textSize = self.CanvasGroup:GetAttribute("TextSize")
			local lineMap = self:GetLineMapCached(displayedText, textSize, font, self:GetLimit())
			for _, line in ipairs(lineMap) do
				if self.CursorIndex >= (line.startIdx - 1) and self.CursorIndex <= line.endIdx then
					self.CursorIndex = line.startIdx - 1
					break
				end
			end
		end
		if not isShiftDown then self.SelectionStart = self.CursorIndex end
		self:HideAutocomplete()
		self:UpdateBlinker(true)
	elseif keyCode == Enum.KeyCode.End then
		if isCtrlDown then
			self.CursorIndex = #displayedText
		else
			local font = self.CanvasGroup:GetAttribute("Font")
			local textSize = self.CanvasGroup:GetAttribute("TextSize")
			local lineMap = self:GetLineMapCached(displayedText, textSize, font, self:GetLimit())
			for _, line in ipairs(lineMap) do
				if self.CursorIndex >= (line.startIdx - 1) and self.CursorIndex <= line.endIdx then
					self.CursorIndex = line.renderEndIdx or line.endIdx
					break
				end
			end
		end
		if not isShiftDown then self.SelectionStart = self.CursorIndex end
		self:HideAutocomplete()
		self:UpdateBlinker(true)
	elseif keyCode == Enum.KeyCode.PageUp or keyCode == Enum.KeyCode.PageDown then
		local font = self.CanvasGroup:GetAttribute("Font")
		local textSize = self.CanvasGroup:GetAttribute("TextSize")
		local lineMap = self:GetLineMapCached(displayedText, textSize, font, self:GetLimit())
		local visibleLinesCount = math.max(1, math.floor(self.CanvasGroup.AbsoluteSize.Y / (lineMap[1] and lineMap[1].height or 14)))
		local currentLineIndex = 1
		for index, line in ipairs(lineMap) do
			if self.CursorIndex >= (line.startIdx - 1) and self.CursorIndex <= line.endIdx then
				currentLineIndex = index
				break
			end
		end
		local targetLineIndex = (keyCode == Enum.KeyCode.PageUp) and math.max(1, currentLineIndex - visibleLinesCount) or math.min(#lineMap, currentLineIndex + visibleLinesCount)
		self.CursorIndex = lineMap[targetLineIndex].renderEndIdx or lineMap[targetLineIndex].endIdx
		if not isShiftDown then self.SelectionStart = self.CursorIndex end
		self:HideAutocomplete()
		self:UpdateBlinker(true)
	else
		local mappedCharacter = Utils.getCharacter(keyCode, isShiftDown)
		if mappedCharacter ~= "" then
			self.LastTypedChar = mappedCharacter
			self.LastTypedTick = tick()
			self:AppendText(mappedCharacter)
		end
	end
end

function Baseline:DeleteSelection()
	if self.SelectionStart == self.CursorIndex then return false end
	local minIndex = math.min(self.SelectionStart, self.CursorIndex)
	local maxIndex = math.max(self.SelectionStart, self.CursorIndex)
	local currentText = self.CanvasGroup:GetAttribute("Text") or ""
	local stringBefore = currentText:sub(1, minIndex)
	local stringAfter = currentText:sub(maxIndex + 1)
	self.CursorIndex = minIndex
	self.SelectionStart = minIndex
	self.CanvasGroup:SetAttribute("Text", stringBefore .. stringAfter)
	self:PushHistory()
	return true
end

function Baseline:AppendText(character)
	if character == "\t" then character = "    " end
	local maxLength = self.CanvasGroup:GetAttribute("MaxLength")
	if maxLength and maxLength > 0 then
		local currentLength = utf8.len(self.CanvasGroup:GetAttribute("Text") or "")
		local minIndex = math.min(self.SelectionStart, self.CursorIndex)
		local maxIndex = math.max(self.SelectionStart, self.CursorIndex)
		local selectedLength = utf8.len((self.CanvasGroup:GetAttribute("Text") or ""):sub(minIndex + 1, maxIndex))
		if (currentLength - selectedLength) + utf8.len(character) > maxLength then return end
	end
	if self.SelectionStart ~= self.CursorIndex then self:DeleteSelection() end
	local currentText = self.CanvasGroup:GetAttribute("Text") or ""
	local stringBefore = currentText:sub(1, self.CursorIndex)
	local stringAfter = currentText:sub(self.CursorIndex + 1)
	local pairsMap = {["("] = ")", ["{"] = "}", ["["] = "]"}
	local quoteMap = {['\"'] = '\"', ["'"] = "'", ["`"] = "`"}
	local closeMap = {[")"] = true, ["}"] = true, ["]"] = true}
	if (quoteMap[character] or closeMap[character]) and stringAfter:sub(1, 1) == character then
		self.CursorIndex = self.CursorIndex + 1
		self.SelectionStart = self.CursorIndex
		self:UpdateBlinker(true)
		self:UpdateAutocompleteUI()
		return
	elseif pairsMap[character] or quoteMap[character] then
		local closeCharacter = pairsMap[character] or quoteMap[character]
		self.CanvasGroup:SetAttribute("Text", stringBefore .. character .. closeCharacter .. stringAfter)
		self.CursorIndex = self.CursorIndex + 1
		self.SelectionStart = self.CursorIndex
		self:PushHistory()
		self:UpdateBlinker(true)
		self:UpdateAutocompleteUI()
		return
	end
	self.CursorIndex = self.CursorIndex + #character
	self.SelectionStart = self.CursorIndex
	local resultingText = stringBefore .. character .. stringAfter
	self.CanvasGroup:SetAttribute("Text", resultingText)
	local currentLine = resultingText:sub(1, self.CursorIndex):match("[^\n]*$")
	if currentLine and (currentLine:match("^%s*end$") or currentLine:match("^%s*until$") or currentLine:match("^%s*else$") or currentLine:match("^%s*elseif.*$") or currentLine:match("^%s*%}$") or currentLine:match("^%s*%]$") or currentLine:match("^%s*%)?$")) then
		local spaces = currentLine:match("^(%s+)")
		if spaces and #spaces >= 4 then
			local removeLen = 4
			local b = resultingText:sub(1, self.CursorIndex - #currentLine)
			local unindented = currentLine:sub(removeLen + 1)
			local a = resultingText:sub(self.CursorIndex + 1)
			self.CanvasGroup:SetAttribute("Text", b .. unindented .. a)
			self.CursorIndex = self.CursorIndex - removeLen
			self.SelectionStart = self.CursorIndex
		end
	end
	self:PushHistory()
	self:UpdateAutocompleteUI()
end

function Baseline:RemoveChar()
	if self.SelectionStart ~= self.CursorIndex then
		self:DeleteSelection()
		self:UpdateAutocompleteUI()
		return
	end
	local currentText = self.CanvasGroup:GetAttribute("Text") or ""
	if self.CursorIndex > 0 then
		local stringBefore = currentText:sub(1, self.CursorIndex)
		local stringAfter = currentText:sub(self.CursorIndex + 1)
		local previousCharacter = stringBefore:sub(-1)
		local nextCharacter = stringAfter:sub(1, 1)
		local pairsMap = {["("] = ")", ["{"] = "}", ["["] = "]"}
		local quoteMap = {['\"'] = '\"', ["'"] = "'", ["`"] = "`"}
		if pairsMap[previousCharacter] == nextCharacter or (quoteMap[previousCharacter] == nextCharacter and quoteMap[previousCharacter]) then
			stringAfter = stringAfter:sub(2)
		end
		local offsetPosition = utf8.offset(stringBefore, -1)
		if offsetPosition then
			stringBefore = stringBefore:sub(1, offsetPosition - 1)
			self.CursorIndex = #stringBefore
			self.SelectionStart = self.CursorIndex
			self.CanvasGroup:SetAttribute("Text", stringBefore .. stringAfter)
			self:PushHistory()
		end
	end
	self:UpdateAutocompleteUI()
end

function Baseline:GetLimit()
	local isWrapped = self.CanvasGroup:GetAttribute("Wrapped") or false
	local numberMarginWidth = 0
	if self.CanvasGroup:GetAttribute("Lines") then
		local font = self.CanvasGroup:GetAttribute("Font") or Enum.Font.Code
		local textSize = self.CanvasGroup:GetAttribute("TextSize") or 16
		local lineCountEstimate = self.CachedLineMap and #self.CachedLineMap or 1000
		local charWidth = Utils.getTextSize("A", textSize, font, Vector2.new(10000, 10000)).X
		local numberWidth = #(tostring(lineCountEstimate)) * charWidth
		numberMarginWidth = math.max(35, numberWidth + 28)
	end
	local maximumWidth = (self.CanvasGroup.AbsoluteSize.X - 8) - numberMarginWidth
	return isWrapped and Vector2.new(math.max(10, maximumWidth), 10000) or Vector2.new(10000, 10000)
end

function Baseline:GetLineMapCached(text, textSize, font, limitVector)
	if self.CachedText == text and self.CachedTextSize == textSize and self.CachedFont == font and self.CachedLimitX == limitVector.X and self.CachedLimitY == limitVector.Y then
		return self.CachedLineMap
	end
	self.CachedText = text
	self.CachedTextSize = textSize
	self.CachedFont = font
	self.CachedLimitX = limitVector.X
	self.CachedLimitY = limitVector.Y
	self.CachedLineMap = self:GetLineMap(text, textSize, font, limitVector)
	return self.CachedLineMap
end

function Baseline:GetLineMap(text, textSize, font, limitVector)
	local pLines = {}
	local idx = 1
	local textLength = #text
	while idx <= textLength do
		local nl = text:find("\n", idx)
		local e = nl and (nl - 1) or textLength
		table.insert(pLines, {text = text:sub(idx, e), startIdx = idx, endIdx = e})
		idx = nl and (nl + 1) or (textLength + 1)
	end
	if text:sub(-1) == "\n" then
		table.insert(pLines, {text = "", startIdx = textLength + 1, endIdx = textLength})
	end
	local stack = {}
	local foldPairs = {}
	for i, pLine in ipairs(pLines) do
		local delta = Utils.getBlockDelta(pLine.text)
		if delta > 0 then
			for j = 1, delta do table.insert(stack, i) end
		elseif delta < 0 then
			for j = 1, -delta do
				if #stack > 0 then
					local startI = table.remove(stack)
					if startI < i then foldPairs[startI] = i end
				end
			end
		end
	end
	self.CurrentFoldPairs = foldPairs
	local lineSegments = {}
	local defaultTextHeight = Utils.getTextSize("A", textSize, font, Vector2.new(10000, 10000)).Y + 4
	if text == "" then
		self.CachedDocumentWidth = 8
		return {{startIdx = 1, endIdx = 0, y = 0, height = defaultTextHeight, lineNumber = 1}}
	end
	local currentYPosition = 0
	local isWrapped = limitVector.X < 10000
	local i = 1
	while i <= #pLines do
		local pLine = pLines[i]
		local isFolded = self.FoldedLines[i] and foldPairs[i]
		if isFolded then
			local endPLine = pLines[foldPairs[i]]
			table.insert(lineSegments, {
				startIdx = pLine.startIdx,
				endIdx = endPLine.startIdx - 1,
				renderEndIdx = pLine.endIdx,
				y = currentYPosition,
				height = defaultTextHeight,
				lineNumber = i,
				isFolded = true
			})
			currentYPosition = currentYPosition + defaultTextHeight
			i = foldPairs[i]
		else
			if not isWrapped then
				table.insert(lineSegments, {
					startIdx = pLine.startIdx,
					endIdx = pLine.endIdx,
					y = currentYPosition,
					height = defaultTextHeight,
					lineNumber = i
				})
				currentYPosition = currentYPosition + defaultTextHeight
			else
				local currentLineStartIndex = pLine.startIdx
				local isFirstWrapChunk = true
				if currentLineStartIndex > pLine.endIdx then
					table.insert(lineSegments, {
						startIdx = currentLineStartIndex,
						endIdx = pLine.endIdx,
						y = currentYPosition,
						height = defaultTextHeight,
						lineNumber = i
					})
					currentYPosition = currentYPosition + defaultTextHeight
				else
					while currentLineStartIndex <= pLine.endIdx do
						local segmentSize = Utils.getTextSize(text:sub(currentLineStartIndex, pLine.endIdx), textSize, font, limitVector)
						if segmentSize.Y <= defaultTextHeight then
							table.insert(lineSegments, {
								startIdx = currentLineStartIndex,
								endIdx = pLine.endIdx,
								y = currentYPosition,
								height = defaultTextHeight,
								lineNumber = isFirstWrapChunk and i or nil
							})
							currentYPosition = currentYPosition + defaultTextHeight
							break
						else
							local wrapIndex = Utils.findWrapPoint(text, currentLineStartIndex, pLine.endIdx, textSize, font, limitVector, defaultTextHeight)
							if wrapIndex < currentLineStartIndex then
								wrapIndex = currentLineStartIndex
							end
							table.insert(lineSegments, {
								startIdx = currentLineStartIndex,
								endIdx = wrapIndex,
								y = currentYPosition,
								height = defaultTextHeight,
								lineNumber = isFirstWrapChunk and i or nil
							})
							currentYPosition = currentYPosition + defaultTextHeight
							currentLineStartIndex = wrapIndex + 1
							isFirstWrapChunk = false
						end
					end
				end
			end
			i = i + 1
		end
	end
	if not isWrapped then
		local maxWidth = 8
		local charWidth = Utils.getTextSize("A", textSize, font, Vector2.new(10000, 10000)).X
		for _, seg in ipairs(lineSegments) do
			local rEnd = seg.renderEndIdx or seg.endIdx
			local str = (seg.startIdx <= rEnd) and text:sub(seg.startIdx, rEnd) or ""
			if seg.isFolded then
				local indentStr = str:match("^%s*") or ""
				str = str .. "\n" .. indentStr .. "    ..."
			end
			local maxLineLen = 0
			for line in string.gmatch(str .. "\n", "(.-)\n") do
				if #line > maxLineLen then maxLineLen = #line end
			end
			local w = maxLineLen * charWidth
			if w > maxWidth then maxWidth = w end
		end
		self.CachedDocumentWidth = maxWidth + 8
	else
		self.CachedDocumentWidth = limitVector.X
	end
	return lineSegments
end

function Baseline:GetClosestIndexInLine(lineData, targetX, text, textSize, font)
	if targetX < 0 then targetX = 0 end
	local charWidth = Utils.getTextSize("A", textSize, font, Vector2.new(10000, 10000)).X
	if charWidth <= 0 then charWidth = 8 end
	local rEnd = lineData.renderEndIdx or lineData.endIdx
	local lineStr = text:sub(lineData.startIdx, rEnd)
	local lineLength = utf8.len(lineStr) or #lineStr

	local clickedIndex = math.floor((targetX / charWidth) + 0.5)
	if clickedIndex < 0 then clickedIndex = 0 end
	if clickedIndex > lineLength then clickedIndex = lineLength end

	local byteOffset = utf8.offset(lineStr, clickedIndex + 1)
	if byteOffset then
		return lineData.startIdx - 1 + byteOffset - 1
	else
		return rEnd
	end
end

function Baseline:GetClosestCursorIndex(clickX, clickY)
	local displayedText = self:GetDisplayText()
	if displayedText == "" then return 0 end
	local font = self.CanvasGroup:GetAttribute("Font") or Enum.Font.Code
	local textSize = self.CanvasGroup:GetAttribute("TextSize") or 16
	local lineMapData = self:GetLineMapCached(displayedText, textSize, font, self:GetLimit())
	if #lineMapData == 0 then return 0 end
	local optimalLine = lineMapData[1]
	local minDistanceY = math.huge
	for _, line in ipairs(lineMapData) do
		local centerLineY = line.y + (line.height / 2)
		local distanceY = math.abs(centerLineY - clickY)
		if distanceY < minDistanceY then
			minDistanceY = distanceY
			optimalLine = line
		end
	end
	return self:GetClosestIndexInLine(optimalLine, clickX, displayedText, textSize, font)
end

function Baseline:UpdateBlinker(autoScrollEnabled)
	if autoScrollEnabled == nil then autoScrollEnabled = true end
	local rawEditorText = self.CanvasGroup:GetAttribute("Text") or ""
	local displayedText = self:GetDisplayText()
	local editorFont = self.CanvasGroup:GetAttribute("Font") or Enum.Font.Code
	local editorTextSize = self.CanvasGroup:GetAttribute("TextSize") or 16
	local editorHighlightColor = self.CanvasGroup:GetAttribute("HighlightColor") or Color3.fromRGB(19, 35, 93)
	local editorTextColor = self.CanvasGroup:GetAttribute("TextColor3") or Color3.new(1, 1, 1)
	local editorLineNumberColor = self.CanvasGroup:GetAttribute("LineNumberColor3") or Color3.fromRGB(130, 130, 130)
	local hasLineNumbers = self.CanvasGroup:GetAttribute("Lines") or false
	local hasMinimap = self.CanvasGroup:GetAttribute("Minimap") ~= false
	local indentGuideColor = self.CanvasGroup:GetAttribute("IndentGuideColor3") or Color3.fromRGB(58, 58, 58)
	local indentGuideTransparency = self.CanvasGroup:GetAttribute("IndentGuideTransparency")
	if indentGuideTransparency == nil then indentGuideTransparency = 0.35 end
	local indentGuideThickness = self.CanvasGroup:GetAttribute("IndentGuideThickness") or 1
	if self.CursorIndex > #displayedText then self.CursorIndex = #displayedText end
	if self.CursorIndex < 0 then self.CursorIndex = 0 end
	if self.SelectionStart > #displayedText then self.SelectionStart = #displayedText end
	if self.SelectionStart < 0 then self.SelectionStart = 0 end
	self.PlaceholderLabel.TextSize = editorTextSize
	self.PlaceholderLabel.Font = editorFont
	self.PlaceholderLabel.Visible = rawEditorText == ""
	self:ApplyStrokeToLabel(self.PlaceholderLabel)

	self.GhostTextLabel.TextSize = editorTextSize
	self.GhostTextLabel.Font = editorFont
	self:ApplyStrokeToLabel(self.GhostTextLabel)

	local lineNumbersMarginWidth = 0
	if hasLineNumbers then
		local lineCountEstimate = self.CachedLineMap and #self.CachedLineMap or 1000
		local charWidth = Utils.getTextSize("A", editorTextSize, editorFont, Vector2.new(10000, 10000)).X
		local numberWidth = #(tostring(lineCountEstimate)) * charWidth
		lineNumbersMarginWidth = math.max(35, numberWidth + 28)
	end
	local scrollbarWidth = (self.VScrollBar and self.VScrollBar.BarFrame.Visible) and 18 or 0
	local minimapMarginWidth = hasMinimap and 60 or 0
	self.LineNumbersContainer.Visible = hasLineNumbers
	self.LineNumbersContainer.Size = UDim2.new(0, lineNumbersMarginWidth, 1, 0)
	self.LineNumbersContainer.Position = UDim2.new(0, 0, 0, 0)
	self.MinimapContainer.Visible = hasMinimap
	self.MinimapContainer.Size = UDim2.new(0, minimapMarginWidth, 1, 0)
	self.MinimapContainer.Position = UDim2.new(1, -(minimapMarginWidth + scrollbarWidth), 0, 0)
	self.TextContainer.Size = UDim2.new(1, -(lineNumbersMarginWidth + minimapMarginWidth + scrollbarWidth), 1, 0)
	self.TextContainer.Position = UDim2.new(0, lineNumbersMarginWidth, 0, 0)
	local editorLimit = self:GetLimit()
	local editorLineMap = self:GetLineMapCached(displayedText, editorTextSize, editorFont, editorLimit)
	local editorDefaultHeight = editorLineMap[1] and editorLineMap[1].height or 14
	self.DocumentHeight = editorLineMap[#editorLineMap] and (editorLineMap[#editorLineMap].y + editorLineMap[#editorLineMap].height) or editorDefaultHeight
	self.DocumentHeight = self.DocumentHeight + 22
	if self.CanvasGroup:GetAttribute("AutoHeight") then
		local targetHeight = self.DocumentHeight + 8
		if self.CanvasGroup.Size.Y.Offset ~= targetHeight then
			self.CanvasGroup.Size = UDim2.new(self.CanvasGroup.Size.X.Scale, self.CanvasGroup.Size.X.Offset, 0, targetHeight)
		end
	end
	local currentCursorX, currentCursorY = 0, 0
	local currentCursorHeight = editorDefaultHeight
	local activeLineNumber = 1
	local lastSeenLineNumber = 1
	if displayedText ~= "" then
		for _, lineData in ipairs(editorLineMap) do
			if lineData.lineNumber then lastSeenLineNumber = lineData.lineNumber end
			if self.CursorIndex >= (lineData.startIdx - 1) and self.CursorIndex <= lineData.endIdx then
				activeLineNumber = lastSeenLineNumber
				local rEnd = lineData.renderEndIdx or lineData.endIdx
				local cursorSubstring = (lineData.startIdx <= self.CursorIndex) and displayedText:sub(lineData.startIdx, math.min(self.CursorIndex, rEnd)) or ""
				local charWidth = Utils.getTextSize("A", editorTextSize, editorFont, Vector2.new(10000, 10000)).X
				local length = utf8.len(cursorSubstring) or #cursorSubstring
				currentCursorX = length * charWidth
				currentCursorY = lineData.y
				currentCursorHeight = lineData.height
				break
			end
		end
	end
	local viewportWidth = (self.CanvasGroup.AbsoluteSize.X - 8) - lineNumbersMarginWidth - minimapMarginWidth - scrollbarWidth
	local viewportHeight = self.CanvasGroup.AbsoluteSize.Y - 8
	local scrollOffsetX, scrollOffsetY = math.round(self.ScrollOffset.X), math.round(self.ScrollOffset.Y)
	local documentTotalWidth = self.CachedDocumentWidth or 0
	if autoScrollEnabled then
		if currentCursorX < scrollOffsetX then scrollOffsetX = currentCursorX end
		if currentCursorX > ((scrollOffsetX + viewportWidth) - 2) then scrollOffsetX = (currentCursorX - viewportWidth) + 2 end
		if currentCursorY < scrollOffsetY then scrollOffsetY = currentCursorY end
		if (currentCursorY + currentCursorHeight) > (scrollOffsetY + viewportHeight) then
			scrollOffsetY = (currentCursorY + currentCursorHeight) - viewportHeight
		end
	end
	local maximumScrollY = math.max(0, self.DocumentHeight - self.CanvasGroup.AbsoluteSize.Y)
	if scrollOffsetY > maximumScrollY then scrollOffsetY = maximumScrollY end
	if scrollOffsetY < 0 then scrollOffsetY = 0 end
	local maximumScrollX = math.max(0, documentTotalWidth - viewportWidth)
	if scrollOffsetX > maximumScrollX then scrollOffsetX = maximumScrollX end
	if scrollOffsetX < 0 then scrollOffsetX = 0 end
	self.ScrollOffset = Vector2.new(scrollOffsetX, scrollOffsetY)
	self.InnerFrame.Position = UDim2.new(0, -scrollOffsetX, 0, -scrollOffsetY)
	self.LineNumbersInner.Position = UDim2.new(0, 0, 0, -scrollOffsetY)
	if self.VScrollBar then self.VScrollBar:UpdateMetrics(self.CanvasGroup.AbsoluteSize.Y, self.DocumentHeight, scrollOffsetY) end
	if self.HScrollBar then self.HScrollBar:UpdateMetrics(viewportWidth + 8, documentTotalWidth, scrollOffsetX) end
	if hasLineNumbers and self.IsFocused then
		self.CurrentLineHighlight.Visible = true
		local targetHighlightPosition = UDim2.new(0, 0, 0, (4 + currentCursorY) - scrollOffsetY)
		local targetHighlightSize = UDim2.new(1, 0, 0, currentCursorHeight)
		if self.CanvasGroup:GetAttribute("SmoothBlinker") then
			local tweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			TweenService:Create(self.CurrentLineHighlight, tweenInfo, {
				Position = targetHighlightPosition,
				Size = targetHighlightSize
			}):Play()
		else
			self.CurrentLineHighlight.Position = targetHighlightPosition
			self.CurrentLineHighlight.Size = targetHighlightSize
		end
	else
		self.CurrentLineHighlight.Visible = false
	end
	local viewportStartY = scrollOffsetY
	local viewportEndY = scrollOffsetY + viewportHeight + 16
	local visibleLinesCount = 0
	local visibleHighlightsCount = 0
	local visibleLineNumbersCount = 0
	local visibleFoldButtonsCount = 0
	local visibleGuidesCount = 0
	local firstVisibleIdx, lastVisibleIdx = 1, #editorLineMap
	if #editorLineMap > 0 then
		local L, R = 1, #editorLineMap
		local bestFirst = 1
		while L <= R do
			local M = math.floor((L + R) / 2)
			if (editorLineMap[M].y + editorLineMap[M].height) >= viewportStartY then
				bestFirst = M
				R = M - 1
			else
				L = M + 1
			end
		end
		firstVisibleIdx = bestFirst
		local bestLast = bestFirst
		L, R = bestFirst, #editorLineMap
		while L <= R do
			local M = math.floor((L + R) / 2)
			if editorLineMap[M].y <= viewportEndY then
				bestLast = M
				L = M + 1
			else
				R = M - 1
			end
		end
		lastVisibleIdx = bestLast
	end
	local bracketHighlightColor = Color3.fromRGB(80, 80, 80)
	if type(self.SyntaxRules) == "table" and self.SyntaxRules["SelectionBackgroundColor"] and self.SyntaxRules["SelectionBackgroundColor"].color then
		bracketHighlightColor = self.SyntaxRules["SelectionBackgroundColor"].color
	end

	local matchIdx1, matchIdx2 = nil, nil
	if self.SelectionStart == self.CursorIndex and self.IsFocused then
		local checkChar = displayedText:sub(self.CursorIndex, self.CursorIndex)
		local checkIdx = self.CursorIndex
		if not checkChar:match("[%[%(%{%]%)%}]") then
			checkChar = displayedText:sub(self.CursorIndex + 1, self.CursorIndex + 1)
			checkIdx = self.CursorIndex + 1
		end
		if checkChar:match("[%[%(%{%]%)%}]") then
			local pairsMap = {["("]=")", ["{"]="}", ["["]="]"}
			local pairsRev = {[")"]="(", ["}"]="{", ["]"]="["}
			local dir = pairsMap[checkChar] and 1 or -1
			local target = pairsMap[checkChar] or pairsRev[checkChar]
			local depth = 0
			local sIdx = checkIdx
			while sIdx > 0 and sIdx <= #displayedText do
				local c = displayedText:sub(sIdx, sIdx)
				if c == checkChar then depth = depth + 1
				elseif c == target then depth = depth - 1 end
				if depth == 0 then
					matchIdx1 = checkIdx
					matchIdx2 = sIdx
					break
				end
				sIdx = sIdx + dir
			end
		end
	end

	local charWidth = Utils.getTextSize("A", editorTextSize, editorFont, Vector2.new(10000, 10000)).X
	if charWidth <= 0 then charWidth = 8 end

	local syntaxStateStr = "none"
	local processedTextUpTo = 1
	if #editorLineMap > 0 and firstVisibleIdx > 1 then
		local targetStart = editorLineMap[firstVisibleIdx].startIdx
		local startParse = math.max(1, targetStart - 10000)
		if startParse > 1 then
			local nl = displayedText:find("\n", startParse)
			if nl and nl < targetStart then startParse = nl + 1 end
		end
		syntaxStateStr = self:GetSyntaxStateAt(displayedText, targetStart, startParse, "none")
		processedTextUpTo = targetStart
	end
	local lastIndentLevel = 0
	if #editorLineMap > 0 then
		for i = firstVisibleIdx, lastVisibleIdx do
			local lineData = editorLineMap[i]
			if lineData then
				syntaxStateStr = self:GetSyntaxStateAt(displayedText, lineData.startIdx, processedTextUpTo, syntaxStateStr)
				processedTextUpTo = lineData.startIdx
				visibleLinesCount = visibleLinesCount + 1
				local textLabelObj = self.LinesPool[visibleLinesCount]
				if not textLabelObj then
					textLabelObj = Instance.new("TextLabel")
					textLabelObj.BackgroundTransparency = 1
					textLabelObj.RichText = true
					textLabelObj.TextXAlignment = Enum.TextXAlignment.Left
					textLabelObj.TextYAlignment = Enum.TextYAlignment.Top
					textLabelObj.ZIndex = 3
					textLabelObj.Parent = self.InnerFrame
					self.LinesPool[visibleLinesCount] = textLabelObj
				end
				local rEnd = lineData.renderEndIdx or lineData.endIdx
				local stringOnLine = (lineData.startIdx <= rEnd) and displayedText:sub(lineData.startIdx, rEnd) or ""

				if lineData.lineNumber and not lineData.isFolded then
					local leading = stringOnLine:match("^([ \t]*)") or ""
					local indentLevel = math.floor(#leading / 4)
					lastIndentLevel = indentLevel
				end
				local effectiveIndent = lastIndentLevel
				if lineData.isFolded then effectiveIndent = 0 end
				for level = 0, effectiveIndent - 1 do
					local guideX = 4 + level * 4 * charWidth + 1
					visibleGuidesCount = visibleGuidesCount + 1
					local guide = self.IndentGuidesPool[visibleGuidesCount]
					if not guide then
						guide = Instance.new("Frame")
						guide.Name = "IndentGuide"
						guide.BorderSizePixel = 0
						guide.ZIndex = 1
						guide.Parent = self.IndentGuideContainer
						self.IndentGuidesPool[visibleGuidesCount] = guide
					end
					guide.BackgroundColor3 = indentGuideColor
					guide.BackgroundTransparency = indentGuideTransparency
					guide.Position = UDim2.new(0, guideX, 0, 4 + lineData.y)
					guide.Size = UDim2.new(0, indentGuideThickness, 0, lineData.height)
					guide.Visible = true
				end

				local localGhost = ""
				if self.AutocompleteVisible and self.IsFocused and #self.AutocompleteMatches > 0 then
					local match = self.AutocompleteMatches[self.AutocompleteIndex]
					if match then
						local currentWord = Utils.getWordBeforeCursor(displayedText, self.CursorIndex)
						local afterChar = displayedText:sub(self.CursorIndex + 1, self.CursorIndex + 1)
						if currentWord ~= "" and match.word:lower():sub(1, #currentWord) == currentWord:lower() and #match.word > #currentWord and (afterChar == "" or afterChar:match("[%s%p]")) then
							if self.CursorIndex >= (lineData.startIdx - 1) and self.CursorIndex <= lineData.endIdx then
								localGhost = match.word:sub(#currentWord + 1)
								local cursorInLine = self.CursorIndex - lineData.startIdx + 1
								stringOnLine = stringOnLine:sub(1, cursorInLine) .. string.rep(" ", #localGhost) .. stringOnLine:sub(cursorInLine + 1)
							end
						end
					end
				end

				textLabelObj.Font = editorFont
				textLabelObj.TextSize = editorTextSize
				textLabelObj.TextColor3 = editorTextColor
				local richTextStr
				if localGhost ~= "" then
					richTextStr = self:ApplySyntax(stringOnLine, syntaxStateStr)
				else
					richTextStr = self:ApplySyntaxCached(lineData, stringOnLine, syntaxStateStr)
				end
				if lineData.isFolded then
					richTextStr = richTextStr .. ' <font color="#888888">...</font>'
				end
				textLabelObj.Text = richTextStr
				textLabelObj.Position = UDim2.new(0, 4, 0, 4 + lineData.y)
				textLabelObj.Size = UDim2.new(0, 10000, 0, lineData.height)
				textLabelObj.Visible = true
				self:ApplyStrokeToLabel(textLabelObj)
				if hasLineNumbers and lineData.lineNumber then
					visibleLineNumbersCount = visibleLineNumbersCount + 1
					local numberLabelObj = self.LineNumbersPool[visibleLineNumbersCount]
					if not numberLabelObj then
						numberLabelObj = Instance.new("TextLabel")
						numberLabelObj.BackgroundTransparency = 1
						numberLabelObj.TextXAlignment = Enum.TextXAlignment.Right
						numberLabelObj.TextYAlignment = Enum.TextYAlignment.Top
						numberLabelObj.ZIndex = 3
						numberLabelObj.Parent = self.LineNumbersInner
						self.LineNumbersPool[visibleLineNumbersCount] = numberLabelObj
					end
					numberLabelObj.Font = editorFont
					numberLabelObj.TextSize = editorTextSize
					if lineData.lineNumber == activeLineNumber and self.IsFocused then
						numberLabelObj.TextColor3 = Color3.new(1, 1, 1)
					else
						numberLabelObj.TextColor3 = editorLineNumberColor
					end
					numberLabelObj.TextTransparency = 0
					numberLabelObj.Text = tostring(lineData.lineNumber)
					numberLabelObj.Position = UDim2.new(0, 0, 0, 4 + lineData.y)
					numberLabelObj.Size = UDim2.new(1, -22, 0, editorDefaultHeight)
					numberLabelObj.Visible = true
					self:ApplyStrokeToLabel(numberLabelObj)
					if self.CurrentFoldPairs and self.CurrentFoldPairs[lineData.lineNumber] then
						visibleFoldButtonsCount = visibleFoldButtonsCount + 1
						local foldBtn = self.FoldButtonsPool[visibleFoldButtonsCount]
						if not foldBtn then
							foldBtn = Instance.new("ImageButton")
							foldBtn.BackgroundTransparency = 1
							foldBtn.Image = Icons.Fold
							foldBtn.Size = UDim2.new(0, 16, 0, 16)
							foldBtn.ZIndex = 12
							foldBtn.Parent = self.LineNumbersInner
							foldBtn.MouseEnter:Connect(function()
								foldBtn:SetAttribute("IsHovered", true)
								self:UpdateBlinker(false)
							end)
							foldBtn.MouseLeave:Connect(function()
								foldBtn:SetAttribute("IsHovered", false)
								self:UpdateBlinker(false)
							end)
							foldBtn.MouseButton1Click:Connect(function()
								local ln = foldBtn:GetAttribute("LineNumber")
								if ln then
									self.FoldedLines[ln] = not self.FoldedLines[ln]
									self.CachedText = nil
									self:UpdateBlinker(false)
								end
							end)
							self.FoldButtonsPool[visibleFoldButtonsCount] = foldBtn
						end
						foldBtn:SetAttribute("LineNumber", lineData.lineNumber)
						local isFolded = self.FoldedLines[lineData.lineNumber]
						foldBtn.ImageRectOffset = Vector2.new(144, 16)
						foldBtn.ImageRectSize = Vector2.new(16, 16)
						foldBtn.Rotation = isFolded and 0 or 90
						if foldBtn:GetAttribute("IsHovered") or (lineData.lineNumber == activeLineNumber and self.IsFocused) then
							foldBtn.ImageColor3 = Color3.new(1, 1, 1)
						else
							foldBtn.ImageColor3 = editorLineNumberColor
						end
						foldBtn.Position = UDim2.new(1, -18, 0, 4 + lineData.y + (editorDefaultHeight - 16) / 2)
						foldBtn.Visible = true
					end
				end
				local function renderHighlightSelection(startIndex, endIndex, renderColor, renderTransparency)
					if endIndex >= (lineData.startIdx - 1) and startIndex <= lineData.endIdx then
						local rEndLocal = lineData.renderEndIdx or lineData.endIdx
						local highlightStart = math.max(lineData.startIdx, startIndex + 1)
						local highlightEnd = math.min(rEndLocal, endIndex)
						local highlightOffsetX = 0
						local highlightWidth = 0
						if highlightStart <= highlightEnd then
							local stringBeforeHighlight = displayedText:sub(lineData.startIdx, highlightStart - 1)
							local bLen = utf8.len(stringBeforeHighlight) or #stringBeforeHighlight
							highlightOffsetX = bLen * charWidth
							local stringUpToTarget = displayedText:sub(lineData.startIdx, highlightEnd)
							local tLen = utf8.len(stringUpToTarget) or #stringUpToTarget
							highlightWidth = (tLen * charWidth) - highlightOffsetX
						else
							local stringBeforeHighlight = (lineData.startIdx <= rEndLocal) and displayedText:sub(lineData.startIdx, rEndLocal) or ""
							local bLen = utf8.len(stringBeforeHighlight) or #stringBeforeHighlight
							highlightOffsetX = bLen * charWidth
						end
						if endIndex >= lineData.endIdx and lineData.endIdx ~= #displayedText then
							if highlightStart > lineData.endIdx then
								highlightWidth = charWidth
							else
								local dotsWidth = lineData.isFolded and (4 * charWidth) or charWidth
								highlightWidth = highlightWidth + dotsWidth
							end
						elseif lineData.isFolded and endIndex >= rEndLocal then
							local dotsWidth = 4 * charWidth
							highlightWidth = highlightWidth + dotsWidth
						end
						if highlightWidth > 0 then
							visibleHighlightsCount = visibleHighlightsCount + 1
							local highlightFrameObj = self.HighlightPool[visibleHighlightsCount]
							if not highlightFrameObj then
								highlightFrameObj = Instance.new("Frame")
								highlightFrameObj.BorderSizePixel = 0
								highlightFrameObj.ZIndex = 2
								highlightFrameObj.Parent = self.HighlightContainer
								self.HighlightPool[visibleHighlightsCount] = highlightFrameObj
							end
							highlightFrameObj.BackgroundColor3 = renderColor
							highlightFrameObj.BackgroundTransparency = renderTransparency
							highlightFrameObj.Position = UDim2.new(0, 4 + highlightOffsetX, 0, 4 + lineData.y)
							highlightFrameObj.Size = UDim2.new(0, highlightWidth, 0, lineData.height)
							highlightFrameObj.Visible = true
						end
					end
				end
				if matchIdx1 and matchIdx1 >= lineData.startIdx and matchIdx1 <= (lineData.renderEndIdx or lineData.endIdx) then
					renderHighlightSelection(matchIdx1 - 1, matchIdx1, bracketHighlightColor, 0.4)
				end
				if matchIdx2 and matchIdx2 >= lineData.startIdx and matchIdx2 <= (lineData.renderEndIdx or lineData.endIdx) then
					renderHighlightSelection(matchIdx2 - 1, matchIdx2, bracketHighlightColor, 0.4)
				end

				if self.FindMatches then
					local findColor = Color3.fromRGB(151, 108, 0)
					if type(self.SyntaxRules) == "table" and self.SyntaxRules["FindSelectionBackgroundColor"] and self.SyntaxRules["FindSelectionBackgroundColor"].color then
						findColor = self.SyntaxRules["FindSelectionBackgroundColor"].color
					end
					for _, matchData in ipairs(self.FindMatches) do
						if matchData.e >= (lineData.startIdx - 1) and matchData.s <= lineData.endIdx then
							renderHighlightSelection(matchData.s, matchData.e, findColor, 0.6)
						end
					end
				end
				if self.SelectionStart ~= self.CursorIndex then
					local selectionStartIdx = math.min(self.SelectionStart, self.CursorIndex)
					local selectionEndIdx = math.max(self.SelectionStart, self.CursorIndex)
					if selectionEndIdx >= (lineData.startIdx - 1) and selectionStartIdx <= lineData.endIdx then
						renderHighlightSelection(selectionStartIdx, selectionEndIdx, editorHighlightColor, 0.4)
					end
				end
			end
		end
	end
	for i = visibleLinesCount + 1, #self.LinesPool do self.LinesPool[i].Visible = false end
	for i = visibleHighlightsCount + 1, #self.HighlightPool do self.HighlightPool[i].Visible = false end
	for i = visibleFoldButtonsCount + 1, #self.FoldButtonsPool do self.FoldButtonsPool[i].Visible = false end
	for i = visibleGuidesCount + 1, #self.IndentGuidesPool do self.IndentGuidesPool[i].Visible = false end
	if hasLineNumbers then
		for i = visibleLineNumbersCount + 1, #self.LineNumbersPool do self.LineNumbersPool[i].Visible = false end
	else
		for i = 1, #self.LineNumbersPool do self.LineNumbersPool[i].Visible = false end
	end
	if hasMinimap then
		local ratio = 3 / editorTextSize
		local H_main = self.DocumentHeight
		local H_mini = H_main * ratio
		local V_main = self.CanvasGroup.AbsoluteSize.Y - 8
		local V_mini = self.MinimapContainer.AbsoluteSize.Y
		local S_main = scrollOffsetY
		local maxS_main = math.max(0, H_main - V_main)
		local S_mini = 0
		if maxS_main > 0 then
			local maxS_mini = math.max(0, H_mini - V_mini)
			S_mini = (S_main / maxS_main) * maxS_mini
		end
		self.MinimapScrollY = S_mini
		self.MinimapInner.Size = UDim2.new(1, 0, 0, H_mini)
		self.MinimapInner.Position = UDim2.new(0, 0, 0, -S_mini)
		local sliderH = math.min(V_mini, V_main * ratio)
		local sliderY = S_main * ratio
		self.MinimapSlider.Size = UDim2.new(1, 0, 0, sliderH)
		self.MinimapSlider.Position = UDim2.new(0, 0, 0, sliderY)
		local mStartY = S_mini
		local mEndY = S_mini + V_mini + 10
		local mFirstIdx = 1
		local mLastIdx = #editorLineMap
		if #editorLineMap > 0 then
			local L, R = 1, #editorLineMap
			local bestFirst = 1
			while L <= R do
				local M = math.floor((L + R) / 2)
				local mLineY = editorLineMap[M].y * ratio
				local mLineH = editorLineMap[M].height * ratio
				if (mLineY + mLineH) >= mStartY then
					bestFirst = M
					R = M - 1
				else
					L = M + 1
				end
			end
			mFirstIdx = bestFirst
			local bestLast = bestFirst
			L, R = bestFirst, #editorLineMap
			while L <= R do
				local M = math.floor((L + R) / 2)
				local mLineY = editorLineMap[M].y * ratio
				if mLineY <= mEndY then
					bestLast = M
					L = M + 1
				else
					R = M - 1
				end
			end
			mLastIdx = bestLast
		end
		local mLineCount = 0
		local mSyntaxStateStr = "none"
		local mProcessedUpTo = 1
		if #editorLineMap > 0 and mFirstIdx > 1 then
			local targetStart = editorLineMap[mFirstIdx].startIdx
			local startParse = math.max(1, targetStart - 10000)
			if startParse > 1 then
				local nl = displayedText:find("\n", startParse)
				if nl and nl < targetStart then startParse = nl + 1 end
			end
			mSyntaxStateStr = self:GetSyntaxStateAt(displayedText, targetStart, startParse, "none")
			mProcessedUpTo = targetStart
		end
		for i = mFirstIdx, mLastIdx do
			local lineData = editorLineMap[i]
			mSyntaxStateStr = self:GetSyntaxStateAt(displayedText, lineData.startIdx, mProcessedUpTo, mSyntaxStateStr)
			mProcessedUpTo = lineData.startIdx
			mLineCount = mLineCount + 1
			local mLabel = self.MinimapLinesPool[mLineCount]
			if not mLabel then
				mLabel = Instance.new("TextLabel")
				mLabel.BackgroundTransparency = 1
				mLabel.RichText = true
				mLabel.TextXAlignment = Enum.TextXAlignment.Left
				mLabel.TextYAlignment = Enum.TextYAlignment.Top
				mLabel.ZIndex = 2
				mLabel.Parent = self.MinimapInner
				self.MinimapLinesPool[mLineCount] = mLabel
			end
			local rEndMini = lineData.renderEndIdx or lineData.endIdx
			local stringOnLine = (lineData.startIdx <= rEndMini) and displayedText:sub(lineData.startIdx, rEndMini) or ""
			mLabel.Font = editorFont
			mLabel.TextSize = 3
			mLabel.TextColor3 = editorTextColor
			local richTextStr = self:ApplySyntaxCached(lineData, stringOnLine, mSyntaxStateStr)
			if lineData.isFolded then
				local indentStr = stringOnLine:match("^%s*") or ""
				richTextStr = richTextStr .. '\n' .. indentStr .. '    <font color="#888888">...</font>'
			end
			mLabel.Text = richTextStr
			local mLineY = lineData.y * ratio
			local mLineH = lineData.height * ratio
			mLabel.Position = UDim2.new(0, 0, 0, mLineY)
			mLabel.Size = UDim2.new(1, 0, 0, mLineH)
			mLabel.Visible = true
		end
		for i = mLineCount + 1, #self.MinimapLinesPool do
			self.MinimapLinesPool[i].Visible = false
		end
	end
	local targetBlinkerPosition = UDim2.new(0, 4 + currentCursorX, 0, 4 + currentCursorY)
	local targetBlinkerSize = UDim2.new(0, 1, 0, currentCursorHeight)
	if self.CanvasGroup:GetAttribute("SmoothBlinker") then
		local tweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		TweenService:Create(self.Blinker, tweenInfo, {
			Position = targetBlinkerPosition,
			Size = targetBlinkerSize
		}):Play()
	else
		self.Blinker.Position = targetBlinkerPosition
		self.Blinker.Size = targetBlinkerSize
	end
	self.BlinkTimer = 0
	if self.IsFocused then self.Blinker.Visible = self.SelectionStart == self.CursorIndex end

	if self.AutocompleteVisible and #self.AutocompleteMatches > 0 then
		local absX = (4 + currentCursorX) - scrollOffsetX
		local absY = (4 + currentCursorY + currentCursorHeight) - scrollOffsetY + 4

		local dynamicHeight = math.min(#self.AutocompleteMatches * 24, 160)
		self.AutocompleteUI.Size = UDim2.new(0, 260, 0, dynamicHeight)

		if absY + dynamicHeight > self.CanvasGroup.AbsoluteSize.Y then
			absY = (4 + currentCursorY) - scrollOffsetY - dynamicHeight - 4
		end
		self.AutocompleteUI.Position = UDim2.new(0, lineNumbersMarginWidth + absX, 0, absY)
		local match = self.AutocompleteMatches[self.AutocompleteIndex]
		if match then
			self.AutocompleteHintText.Text = match.type
			local bounds = Utils.getTextSize(match.type, 14, Enum.Font.Code, Vector2.new(1000, 24))
			self.AutocompleteHint.Size = UDim2.new(0, bounds.X + 16, 0, 24)
			local rowRelativeY = (self.AutocompleteIndex - 1) * 24 - self.AutocompleteScroll.CanvasPosition.Y
			self.AutocompleteHint.Position = UDim2.new(1, 1, 0, rowRelativeY)
			self.AutocompleteHint.Visible = true

			local currentWord = Utils.getWordBeforeCursor(displayedText, self.CursorIndex)
			local afterChar = displayedText:sub(self.CursorIndex + 1, self.CursorIndex + 1)

			if currentWord ~= "" and match.word:lower():sub(1, #currentWord) == currentWord:lower() and #match.word > #currentWord and (afterChar == "" or afterChar:match("[%s%p]")) then
				local ghostString = match.word:sub(#currentWord + 1)
				self.GhostTextLabel.Text = ghostString
				self.GhostTextLabel.Position = UDim2.new(0, 4 + currentCursorX, 0, 4 + currentCursorY)
				self.GhostTextLabel.Visible = true
			else
				self.GhostTextLabel.Visible = false
			end
		else
			self.GhostTextLabel.Visible = false
		end
	else
		self.AutocompleteHint.Visible = false
		self.GhostTextLabel.Visible = false
	end
end

function Baseline:Destroy()
	self:Unfocus()
	self:CloseFindUI()
	for _, connection in ipairs(self.Connections) do connection:Disconnect() end
	for index, baselineInstance in ipairs(Baseline.Instances) do
		if baselineInstance == self then
			table.remove(Baseline.Instances, index)
			break
		end
	end
	if self.VScrollBar then self.VScrollBar:Destroy() end
	if self.HScrollBar then self.HScrollBar:Destroy() end
	self.CanvasGroup:ClearAllChildren()
end

local defaultSyntaxRules = {
	keyword = { color = Color3.fromRGB(255, 123, 114) },
	builtin = { color = Color3.fromRGB(121, 192, 255) },
	string_literal = { color = Color3.fromRGB(165, 214, 255) },
	number = { color = Color3.fromRGB(121, 192, 255) },
	comment_single = { color = Color3.fromRGB(139, 148, 158) },
	comment_multi = { color = Color3.fromRGB(139, 148, 158) },
	op_add = { color = Color3.fromRGB(201, 209, 217) },
	TextColor = { color = Color3.fromRGB(201, 209, 217) }
}

function Baseline.HighlightFrame(parent, text, config)
	config = config or {}
	local copyable = config.Copyable or false
	local rules = config.SyntaxRules or defaultSyntaxRules
	local dummy = setmetatable({SyntaxRules = rules}, Baseline)
	local state = "none"
	text = text:gsub("\t", "    ")
	local richText = dummy:ApplySyntax(text, state)
	local container = Instance.new("Frame")
	container.Name = "SyntaxFrame"
	container.Size = config.Size or UDim2.new(1, 0, 1, 0)
	container.BackgroundTransparency = config.BackgroundTransparency or 1
	container.BackgroundColor3 = config.BackgroundColor3 or Color3.fromRGB(30, 30, 30)
	container.Parent = parent
	local displayLabel = Instance.new("TextLabel")
	displayLabel.Size = UDim2.new(1, 0, 1, 0)
	displayLabel.BackgroundTransparency = 1
	displayLabel.RichText = true
	displayLabel.TextXAlignment = Enum.TextXAlignment.Left
	displayLabel.TextYAlignment = Enum.TextYAlignment.Top
	displayLabel.Font = config.Font or Enum.Font.Code
	displayLabel.TextSize = config.TextSize or 14
	displayLabel.Text = richText
	displayLabel.Parent = container
	local strokeThick = config.StrokeThickness or 0
	if strokeThick > 0 then
		local stroke = Instance.new("UIStroke")
		stroke.Name = "TextUIStroke"
		stroke.Color = config.StrokeColor3 or Color3.fromRGB(0, 0, 0)
		stroke.Transparency = config.StrokeTransparency or 0.92
		stroke.Thickness = strokeThick
		stroke.Parent = displayLabel
	end
	if copyable then
		local copyBox = Instance.new("TextBox")
		copyBox.Size = UDim2.new(1, 0, 1, 0)
		copyBox.BackgroundTransparency = 1
		copyBox.TextTransparency = 1
		copyBox.TextXAlignment = Enum.TextXAlignment.Left
		copyBox.TextYAlignment = Enum.TextYAlignment.Top
		copyBox.Font = config.Font or Enum.Font.Code
		copyBox.TextSize = config.TextSize or 14
		copyBox.Text = text
		copyBox.ClearTextOnFocus = false
		copyBox.TextEditable = false
		copyBox.Parent = container
	end
	return container, displayLabel
end

function Baseline.newConsole(container, config)
	config = config or {}
	local console = {}
	console.Container = container
	console.Config = config
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.BackgroundTransparency = config.BackgroundTransparency or 0
	scroll.BackgroundColor3 = config.BackgroundColor3 or Color3.fromRGB(15, 15, 15)
	scroll.BorderSizePixel = 0
	scroll.ScrollBarThickness = 6
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Parent = container
	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = scroll
	local rules = config.SyntaxRules or defaultSyntaxRules
	local dummy = setmetatable({SyntaxRules = rules}, Baseline)
	local logs = {}
	local lineCount = 0
	function console:Log(text)
		lineCount = lineCount + 1
		local ts = config.TextSize or 14
		local logFrame = Instance.new("Frame")
		logFrame.Size = UDim2.new(1, 0, 0, ts + 4)
		logFrame.BackgroundTransparency = 1
		logFrame.LayoutOrder = lineCount
		text = text:gsub("\t", "    ")
		local rText = dummy:ApplySyntax(text, "none")
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, -8, 1, 0)
		label.Position = UDim2.new(0, 4, 0, 0)
		label.BackgroundTransparency = 1
		label.RichText = true
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Font = config.Font or Enum.Font.Code
		label.TextSize = ts
		label.Text = rText
		label.Parent = logFrame
		local strokeThick = config.StrokeThickness or 0
		if strokeThick > 0 then
			local stroke = Instance.new("UIStroke")
			stroke.Name = "TextUIStroke"
			stroke.Color = config.StrokeColor3 or Color3.fromRGB(0, 0, 0)
			stroke.Transparency = config.StrokeTransparency or 0.92
			stroke.Thickness = strokeThick
			stroke.Parent = label
		end
		if config.Copyable ~= false then
			local copyBox = Instance.new("TextBox")
			copyBox.Size = UDim2.new(1, 0, 1, 0)
			copyBox.BackgroundTransparency = 1
			copyBox.TextTransparency = 1
			copyBox.TextXAlignment = Enum.TextXAlignment.Left
			copyBox.Font = config.Font or Enum.Font.Code
			copyBox.TextSize = ts
			copyBox.Text = text
			copyBox.ClearTextOnFocus = false
			copyBox.TextEditable = false
			copyBox.Parent = logFrame
		end
		logFrame.Parent = scroll
		table.insert(logs, logFrame)
		task.defer(function()
			scroll.CanvasPosition = Vector2.new(0, scroll.AbsoluteCanvasSize.Y)
		end)
	end
	function console:Clear()
		for _, logFrame in ipairs(logs) do
			logFrame:Destroy()
		end
		logs = {}
		lineCount = 0
	end
	return console
end

return Baseline
