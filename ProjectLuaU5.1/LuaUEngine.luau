-- LuaUEngine
-- Uh YERANDY made this pls dont edit.
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local CONST = {
    MAX_LINE_CHARS = 25000,
    AUTOC_ROW_H = 22,
    AUTOC_MAX_ROWS = 50,
    AUTOC_MAX_H = 160,
    SCROLLBAR_SIZE = 18,
    SCROLL_STEP = 45,
    KEY_REPEAT_DELAY = 0.4,
    KEY_REPEAT_TICK = 0.04,
    BLINK_INTERVAL = 0.5,
    MINIMAP_DIV = 3,
    TWEEN_SMOOTH = 0.08,
    TWEEN_BLINK = 0.06,
    DOUBLE_CLICK_MS = 0.3,
    PASTE_GAP = 0.25,
    ARROW_ICON_SIZE = 12,
    SCROLL_THUMB_MIN = 24,
    FIND_MIN_WIDTH = 180,
    FIND_MAX_WIDTH = 260,
    RELEASE_POLL = 0.03,
}

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
    Fold = "rbxassetid://5642383285",
}

local Baseline = {
    Instances = {},
    Clipboard = "",
}

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
    ScrollBarStrokeTransparency = 0,
}

local KeyMaps = {
    Operators = {
        ["+"] = "op_add", ["-"] = "op_sub", ["*"] = "op_mul", ["/"] = "op_div",
        ["^"] = "op_pow", ["%"] = "op_mod", ["=="] = "op_eq", ["~="] = "op_neq",
        ["<="] = "op_le", [">="] = "op_ge", ["<"] = "op_lt", [">"] = "op_gt",
        ["="] = "op_assign", [".."] = "op_concat", ["#"] = "op_len",
        [":"] = "op_colon", ["&"] = "op_ampersand", ["|"] = "op_pipe", ["?"] = "op_question",
    },
    Shift = {
        [Enum.KeyCode.One] = "!", [Enum.KeyCode.Two] = "@", [Enum.KeyCode.Three] = "#",
        [Enum.KeyCode.Four] = "$", [Enum.KeyCode.Five] = "%", [Enum.KeyCode.Six] = "^",
        [Enum.KeyCode.Seven] = "&", [Enum.KeyCode.Eight] = "*", [Enum.KeyCode.Nine] = "(",
        [Enum.KeyCode.Zero] = ")", [Enum.KeyCode.Minus] = "_", [Enum.KeyCode.Equals] = "+",
        [Enum.KeyCode.LeftBracket] = "{", [Enum.KeyCode.RightBracket] = "}",
        [Enum.KeyCode.BackSlash] = "|", [Enum.KeyCode.Semicolon] = ":",
        [Enum.KeyCode.Quote] = '"', [Enum.KeyCode.Comma] = "<",
        [Enum.KeyCode.Period] = ">", [Enum.KeyCode.Slash] = "?", [Enum.KeyCode.Backquote] = "~",
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
        [Enum.KeyCode.KeypadMinus] = "-", [Enum.KeyCode.KeypadPlus] = "+",
    },
    SinkKeys = {
        Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D,
        Enum.KeyCode.Space, Enum.KeyCode.Up, Enum.KeyCode.Down,
        Enum.KeyCode.Left, Enum.KeyCode.Right, Enum.KeyCode.I,
        Enum.KeyCode.O, Enum.KeyCode.Backspace, Enum.KeyCode.Return,
        Enum.KeyCode.C, Enum.KeyCode.V, Enum.KeyCode.X, Enum.KeyCode.Z,
        Enum.KeyCode.Y, Enum.KeyCode.Home, Enum.KeyCode.End,
        Enum.KeyCode.PageUp, Enum.KeyCode.PageDown, Enum.KeyCode.Tab,
    },
    SinkSet = {},
}
for _, kc in ipairs(KeyMaps.SinkKeys) do KeyMaps.SinkSet[kc] = true end

local Utils = {}
Utils.AutocompleteKeywords = {}
Utils.DummyLabel = Instance.new("TextLabel")

local generateKeywords
do
    local insert = table.insert
    function generateKeywords(list, typeName, iconId)
        for i = 1, #list do
            insert(Utils.AutocompleteKeywords, { word = list[i], type = typeName, icon = iconId })
        end
    end
end

generateKeywords({"and","break","do","else","elseif","end","false","for","function","if","in","local","nil","not","or","repeat","return","then","true","until","while"},"Keyword",Icons.Keyword)
generateKeywords({"print","warn","error","assert","require"},"Function",Icons.Function)
generateKeywords({"game","workspace","script","shared","_G","plugin"},"Global",Icons.Global)
generateKeywords({"math","string","table","task","coroutine","os","debug","utf8"},"Library",Icons.Library)
generateKeywords({"math.abs","math.acos","math.asin","math.atan","math.atan2","math.ceil","math.clamp","math.cos","math.cosh","math.deg","math.exp","math.floor","math.fmod","math.frexp","math.ldexp","math.log","math.log10","math.max","math.min","math.modf","math.noise","math.pi","math.pow","math.rad","math.random","math.randomseed","math.round","math.sign","math.sin","math.sinh","math.sqrt","math.tan","math.tanh"},"Function",Icons.Function)
generateKeywords({"table.concat","table.insert","table.remove","table.sort","table.create","table.find","table.clear","table.pack","table.unpack","table.foreach","table.foreachi","table.getn"},"Function",Icons.Function)
generateKeywords({"string.byte","string.char","string.find","string.format","string.gmatch","string.gsub","string.len","string.lower","string.match","string.pack","string.packsize","string.rep","string.reverse","string.split","string.sub","string.unpack","string.upper"},"Function",Icons.Function)
generateKeywords({"task.spawn","task.defer","task.delay","task.wait","task.cancel"},"Function",Icons.Function)
generateKeywords({"coroutine.create","coroutine.resume","coroutine.running","coroutine.status","coroutine.wrap","coroutine.yield","coroutine.isyieldable","coroutine.close"},"Function",Icons.Function)
generateKeywords({"Instance","Vector3","Vector2","CFrame","Color3","UDim2","UDim","Ray","TweenInfo","Enum","ColorSequence","NumberSequence","NumberRange","Rect","Faces","Axes"},"Class",Icons.Class)
generateKeywords({"Instance.new","Vector3.new","Vector3.zero","Vector3.one","Vector3.xAxis","Vector3.yAxis","Vector3.zAxis","Vector2.new","Vector2.zero","Vector2.one","Vector2.xAxis","Vector2.yAxis","CFrame.new","CFrame.Angles","CFrame.lookAt","CFrame.identity","Color3.new","Color3.fromRGB","Color3.fromHSV","Color3.fromHex","UDim2.new","UDim2.fromOffset","UDim2.fromScale","UDim.new","TweenInfo.new","Ray.new"},"Constructor",Icons.Constructor)

function Utils.getWordBeforeCursor(text, cursorIndex)
    local before = text:sub(1, cursorIndex)
    return before:match("[%w_%.]+$") or ""
end

function Utils.getTextSize(text, size, font, limit)
    if typeof(font) == "Font" then
        local dl = Utils.DummyLabel
        dl.Text = text
        dl.TextSize = size
        dl.FontFace = font
        dl.Size = UDim2.new(0, limit.X, 0, limit.Y)
        return dl.TextBounds
    end
    return TextService:GetTextSize(text, size, font, limit)
end

function Utils.getCharacter(keyCode, isShiftDown)
    if keyCode.Value >= Enum.KeyCode.A.Value and keyCode.Value <= Enum.KeyCode.Z.Value then
        local s = UserInputService:GetStringForKeyCode(keyCode)
        return isShiftDown and s:upper() or s:lower()
    end
    if isShiftDown and KeyMaps.Shift[keyCode] then return KeyMaps.Shift[keyCode] end
    if KeyMaps.Unshift[keyCode] then return KeyMaps.Unshift[keyCode] end
    return ""
end

do
    local gsub = string.gsub
    function Utils.escapeRichText(s)
        s = gsub(s, "&", "&amp;")
        s = gsub(s, "<", "&lt;")
        s = gsub(s, ">", "&gt;")
        return s
    end
end

function Utils.getNextWordBoundary(text, index)
    if index >= #text then return #text end
    local startIsWord = text:sub(index + 1, index + 1):match("[%w_]") ~= nil
    for i = index + 1, #text do
        local isWord = text:sub(i, i):match("[%w_]") ~= nil
        if isWord ~= startIsWord then return i - 1 end
    end
    return #text
end

function Utils.getPrevWordBoundary(text, index)
    if index <= 0 then return 0 end
    local startIsWord = text:sub(index, index):match("[%w_]") ~= nil
    for i = index, 1, -1 do
        local isWord = text:sub(i, i):match("[%w_]") ~= nil
        if isWord ~= startIsWord then return i end
    end
    return 0
end

function Utils.getWordAtIndex(text, index)
    local s, e = index, index
    while s > 0 and text:sub(s, s):match("[%w_]") do s = s - 1 end
    while e < #text and text:sub(e + 1, e + 1):match("[%w_]") do e = e + 1 end
    return s, e
end

function Utils.findWrapPoint(text, startIdx, endIdx, textSize, font, limit, defaultHeight)
    local lo, hi = startIdx, endIdx
    local best = startIdx
    while lo <= hi do
        local mid = math.floor((lo + hi) / 2)
        local seg = Utils.getTextSize(text:sub(startIdx, mid), textSize, font, limit)
        if seg.Y <= defaultHeight then
            best = mid
            lo = mid + 1
        else
            hi = mid - 1
        end
    end
    return best
end

function Utils.countWord(str, word)
    local count = 0
    for _ in str:gmatch("%f[%w]" .. word .. "%f[%W]") do count = count + 1 end
    return count
end

function Utils.getBlockDelta(lineStr)
    local clean = lineStr:gsub('".-"', ''):gsub("'.-'", ''):gsub("%-%-.*", "")
    local opens = Utils.countWord(clean, "if")
        + Utils.countWord(clean, "while")
        + Utils.countWord(clean, "for")
        + Utils.countWord(clean, "function")
        + Utils.countWord(clean, "repeat")
    if clean:match("^%s*do%f[%W]") then opens = opens + 1 end
    local _, ob = clean:gsub("{", "")
    opens = opens + ob
    local closes = Utils.countWord(clean, "end") + Utils.countWord(clean, "until")
    local _, cb = clean:gsub("}", "")
    closes = closes + cb
    return opens - closes
end

local ScrollBar = {}
ScrollBar.__index = ScrollBar

local function makeArrowButton(parent, rotation, isVertical, bgColor, imgColor, bgTrans, strokeColor)
    local btn = Instance.new("ImageButton")
    btn.Size = isVertical and UDim2.new(1, 0, 0, CONST.SCROLLBAR_SIZE) or UDim2.new(0, CONST.SCROLLBAR_SIZE, 1, 0)
    btn.BackgroundColor3 = bgColor or Color3.fromRGB(35, 35, 35)
    btn.BorderColor3 = strokeColor or Color3.fromRGB(33, 33, 33)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Image = ""
    btn.ZIndex = 101
    btn.BackgroundTransparency = bgTrans or 0
    btn.Parent = parent

    local icon = Instance.new("ImageLabel")
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.Size = UDim2.new(0, CONST.ARROW_ICON_SIZE, 0, CONST.ARROW_ICON_SIZE)
    icon.Position = UDim2.new(0.5, 0, 0.5, 0)
    icon.BackgroundTransparency = 1
    icon.Image = Icons.ScrollArrow
    icon.ImageColor3 = imgColor or Color3.fromRGB(160, 160, 160)
    icon.Rotation = rotation
    icon.ZIndex = 102
    icon.Parent = btn
    return btn, icon
end

function ScrollBar.new(container, isVertical)
    local self = setmetatable({}, ScrollBar)
    self.Container = container
    self.IsVertical = isVertical
    self.ViewSize = 0
    self.ContentSize = 0
    self.ScrollPos = 0
    self.Connections = {}
    self.OnScroll = nil
    self.IsDraggingThumb = false

    local get = container.GetAttribute
    self.TrackColor = get(container, "ScrollBarTrackColor3") or Color3.fromRGB(35, 35, 35)
    self.ThumbColor = get(container, "ScrollBarThumbColor3") or Color3.fromRGB(60, 60, 60)
    self.HoverColor = get(container, "ScrollBarHoverColor3") or Color3.fromRGB(75, 75, 75)
    self.PressColor = get(container, "ScrollBarPressColor3") or Color3.fromRGB(40, 40, 40)
    self.TrackTransparency = get(container, "ScrollBarTrackTransparency") or 0
    self.ThumbTransparency = get(container, "ScrollBarThumbTransparency") or 0
    local imageColor = get(container, "ScrollBarImageColor3") or Color3.fromRGB(160, 160, 160)
    local strokeColor = get(container, "ScrollBarStrokeColor3") or Color3.fromRGB(33, 33, 33)
    local SSZ = CONST.SCROLLBAR_SIZE

    local bar = Instance.new("Frame")
    bar.Name = isVertical and "VScrollBar" or "HScrollBar"
    bar.BackgroundColor3 = self.TrackColor
    bar.BorderColor3 = strokeColor
    bar.BorderSizePixel = 0
    bar.Size = isVertical and UDim2.new(0, SSZ, 1, 0) or UDim2.new(1, -SSZ, 0, SSZ)
    bar.Position = isVertical and UDim2.new(1, -SSZ, 0, 0) or UDim2.new(0, 0, 1, -SSZ)
    bar.ZIndex = 100
    bar.BackgroundTransparency = self.TrackTransparency
    bar.Visible = false
    bar.Parent = container
    self.BarFrame = bar

    self.UpBtn, self.UpIcon = makeArrowButton(bar, isVertical and 180 or 90, isVertical, self.TrackColor, imageColor, self.TrackTransparency, strokeColor)
    self.UpBtn.AnchorPoint = Vector2.new(0, 0)
    self.UpBtn.Position = UDim2.new(0, 0, 0, 0)

    self.DownBtn, self.DownIcon = makeArrowButton(bar, isVertical and 0 or -90, isVertical, self.TrackColor, imageColor, self.TrackTransparency, strokeColor)
    self.DownBtn.AnchorPoint = Vector2.new(isVertical and 0 or 1, isVertical and 1 or 0)
    self.DownBtn.Position = isVertical and UDim2.new(0, 0, 1, 0) or UDim2.new(1, 0, 0, 0)

    local function hookBtn(btn)
        table.insert(self.Connections, btn.MouseEnter:Connect(function() btn.BackgroundColor3 = self.HoverColor end))
        table.insert(self.Connections, btn.MouseLeave:Connect(function() btn.BackgroundColor3 = self.TrackColor end))
        table.insert(self.Connections, btn.MouseButton1Down:Connect(function() btn.BackgroundColor3 = self.PressColor end))
        table.insert(self.Connections, btn.MouseButton1Up:Connect(function() btn.BackgroundColor3 = self.HoverColor end))
    end
    hookBtn(self.UpBtn)
    hookBtn(self.DownBtn)

    local track = Instance.new("Frame")
    track.Name = "Track"
    track.BackgroundColor3 = self.TrackColor
    track.BackgroundTransparency = self.TrackTransparency
    track.BorderSizePixel = 0
    track.Size = isVertical and UDim2.new(1, 0, 1, -SSZ * 2) or UDim2.new(1, -SSZ * 2, 1, 0)
    track.Position = isVertical and UDim2.new(0, 0, 0, SSZ) or UDim2.new(0, SSZ, 0, 0)
    track.ZIndex = 100
    track.Parent = bar
    self.Track = track

    local thumb = Instance.new("Frame")
    thumb.Name = "Thumb"
    thumb.BackgroundColor3 = self.ThumbColor
    thumb.BorderSizePixel = 0
    thumb.Size = isVertical and UDim2.new(1, -2, 0, 30) or UDim2.new(0, 30, 1, -2)
    thumb.Position = isVertical and UDim2.new(0, 1, 0, 0) or UDim2.new(0, 0, 0, 1)
    thumb.ZIndex = 101
    thumb.Visible = false
    thumb.BackgroundTransparency = self.ThumbTransparency
    thumb.Parent = track
    self.Thumb = thumb

    local thumbBtn = Instance.new("TextButton")
    thumbBtn.Size = UDim2.new(1, 0, 1, 0)
    thumbBtn.BackgroundTransparency = 1
    thumbBtn.Text = ""
    thumbBtn.ZIndex = 102
    thumbBtn.Parent = thumb

    local dragStartMouse, dragStartOffset = 0, 0
    table.insert(self.Connections, thumbBtn.MouseEnter:Connect(function() thumb.BackgroundColor3 = self.HoverColor end))
    table.insert(self.Connections, thumbBtn.MouseLeave:Connect(function()
        if not self.IsDraggingThumb then thumb.BackgroundColor3 = self.ThumbColor end
    end))
    table.insert(self.Connections, thumbBtn.MouseButton1Down:Connect(function()
        self.IsDraggingThumb = true
        thumb.BackgroundColor3 = self.HoverColor
        local p = isVertical and UserInputService:GetMouseLocation().Y or UserInputService:GetMouseLocation().X
        dragStartMouse = p
        dragStartOffset = isVertical and thumb.Position.Y.Offset or thumb.Position.X.Offset
    end))

    table.insert(self.Connections, UserInputService.InputChanged:Connect(function(input)
        if self.IsDraggingThumb and input.UserInputType == Enum.UserInputType.MouseMovement then
            local p = isVertical and UserInputService:GetMouseLocation().Y or UserInputService:GetMouseLocation().X
            local delta = p - dragStartMouse
            local trackSize = isVertical and track.AbsoluteSize.Y or track.AbsoluteSize.X
            local thumbSize = isVertical and thumb.AbsoluteSize.Y or thumb.AbsoluteSize.X
            local maxOffset = math.max(0, trackSize - thumbSize)
            local newOffset = math.clamp(dragStartOffset + delta, 0, maxOffset)
            local ratio = maxOffset > 0 and (newOffset / maxOffset) or 0
            local maxScroll = math.max(0, self.ContentSize - self.ViewSize)
            if self.OnScroll then self.OnScroll(ratio * maxScroll) end
        elseif input.UserInputType == Enum.UserInputType.MouseWheel and self.IsVertical and self.BarFrame.Visible then
            local pos = input.Position
            local absPos = self.Container.AbsolutePosition
            local absSize = self.Container.AbsoluteSize
            if pos.X >= absPos.X and pos.X <= absPos.X + absSize.X and pos.Y >= absPos.Y and pos.Y <= absPos.Y + absSize.Y then
                local dir = -math.sign(input.Position.Z)
                local maxScroll = math.max(0, self.ContentSize - self.ViewSize)
                local newScroll = math.clamp(self.ScrollPos + dir * CONST.SCROLL_STEP, 0, maxScroll)
                if self.OnScroll then self.OnScroll(newScroll) end
            end
        end
    end))

    table.insert(self.Connections, UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and self.IsDraggingThumb then
            self.IsDraggingThumb = false
            thumb.BackgroundColor3 = self.ThumbColor
        end
    end))

    local function step(dir)
        local maxScroll = math.max(0, self.ContentSize - self.ViewSize)
        if self.OnScroll then
            self.OnScroll(math.clamp(self.ScrollPos + dir * CONST.SCROLL_STEP, 0, maxScroll))
        end
    end
    local function startRepeat(dir)
        local active = true
        step(dir)
        task.spawn(function()
            task.wait(0.35)
            while active do
                step(dir)
                task.wait(CONST.KEY_REPEAT_TICK)
            end
        end)
        return function() active = false end
    end

    local stopUp, stopDown
    table.insert(self.Connections, self.UpBtn.MouseButton1Down:Connect(function() stopUp = startRepeat(-1) end))
    table.insert(self.Connections, self.UpBtn.MouseButton1Up:Connect(function() if stopUp then stopUp(); stopUp = nil end end))
    table.insert(self.Connections, self.UpBtn.MouseLeave:Connect(function() if stopUp then stopUp(); stopUp = nil end end))
    table.insert(self.Connections, self.DownBtn.MouseButton1Down:Connect(function() stopDown = startRepeat(1) end))
    table.insert(self.Connections, self.DownBtn.MouseButton1Up:Connect(function() if stopDown then stopDown(); stopDown = nil end end))
    table.insert(self.Connections, self.DownBtn.MouseLeave:Connect(function() if stopDown then stopDown(); stopDown = nil end end))

    return self
end

function ScrollBar:SetColors(trackColor, thumbColor)
    self.TrackColor = trackColor or self.TrackColor
    self.ThumbColor = thumbColor or self.ThumbColor
    self.HoverColor = thumbColor or self.HoverColor
    self.BarFrame.BackgroundColor3 = self.TrackColor
    self.Track.BackgroundColor3 = self.TrackColor
    self.UpBtn.BackgroundColor3 = self.TrackColor
    self.DownBtn.BackgroundColor3 = self.TrackColor
    if not self.IsDraggingThumb then self.Thumb.BackgroundColor3 = self.ThumbColor end
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
    local thumbSize = math.max(CONST.SCROLL_THUMB_MIN, ratio * trackSize)
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
    for i = 1, #self.Connections do self.Connections[i]:Disconnect() end
    table.clear(self.Connections)
    if self.BarFrame then self.BarFrame:Destroy() end
end

local LuaUEngine = {}
LuaUEngine.__index = LuaUEngine

local defaultSyntaxRules = {
    keyword = { color = Color3.fromRGB(255, 123, 114) },
    builtin = { color = Color3.fromRGB(121, 192, 255) },
    string_literal = { color = Color3.fromRGB(165, 214, 255) },
    number = { color = Color3.fromRGB(121, 192, 255) },
    comment_single = { color = Color3.fromRGB(139, 148, 158) },
    comment_multi = { color = Color3.fromRGB(139, 148, 158) },
    op_add = { color = Color3.fromRGB(201, 209, 217) },
    TextColor = { color = Color3.fromRGB(201, 209, 217) },
}

function LuaUEngine.HighlightFrame(parent, text, config)
    config = config or {}
    local rules = config.SyntaxRules or defaultSyntaxRules
    local dummy = setmetatable({ SyntaxRules = rules }, LuaUEngine)
    text = text:gsub("\t", "    ")
    local richText = dummy:ApplySyntax(text, "none")

    local container = Instance.new("Frame")
    container.Name = "SyntaxFrame"
    container.Size = config.Size or UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = config.BackgroundTransparency or 1
    container.BackgroundColor3 = config.BackgroundColor3 or Color3.fromRGB(30, 30, 30)
    container.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.RichText = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.Font = config.Font or Enum.Font.Code
    label.TextSize = config.TextSize or 14
    label.Text = richText
    label.Parent = container

    local strokeThick = config.StrokeThickness or 0
    if strokeThick > 0 then
        local stroke = Instance.new("UIStroke")
        stroke.Name = "TextUIStroke"
        stroke.Color = config.StrokeColor3 or Color3.fromRGB(0, 0, 0)
        stroke.Transparency = config.StrokeTransparency or 0.92
        stroke.Thickness = strokeThick
        stroke.Parent = label
    end

    if config.Copyable then
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, 0, 1, 0)
        box.BackgroundTransparency = 1
        box.TextTransparency = 1
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.TextYAlignment = Enum.TextYAlignment.Top
        box.Font = config.Font or Enum.Font.Code
        box.TextSize = config.TextSize or 14
        box.Text = text
        box.ClearTextOnFocus = false
        box.TextEditable = false
        box.Parent = container
    end

    return container, label
end

function LuaUEngine.newConsole(container, config)
    config = config or {}
    local console = { Container = container, Config = config }
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
    local dummy = setmetatable({ SyntaxRules = rules }, LuaUEngine)
    local logs = {}
    local lineCount = 0

    function console:Log(text)
        lineCount = lineCount + 1
        local ts = config.TextSize or 14
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, ts + 4)
        frame.BackgroundTransparency = 1
        frame.LayoutOrder = lineCount
        text = text:gsub("\t", "    ")
        local rich = dummy:ApplySyntax(text, "none")
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -8, 1, 0)
        label.Position = UDim2.new(0, 4, 0, 0)
        label.BackgroundTransparency = 1
        label.RichText = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = config.Font or Enum.Font.Code
        label.TextSize = ts
        label.Text = rich
        label.Parent = frame

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
            local box = Instance.new("TextBox")
            box.Size = UDim2.new(1, 0, 1, 0)
            box.BackgroundTransparency = 1
            box.TextTransparency = 1
            box.TextXAlignment = Enum.TextXAlignment.Left
            box.Font = config.Font or Enum.Font.Code
            box.TextSize = ts
            box.Text = text
            box.ClearTextOnFocus = false
            box.TextEditable = false
            box.Parent = frame
        end

        frame.Parent = scroll
        logs[#logs + 1] = frame
        task.defer(function()
            if scroll.Parent then
                scroll.CanvasPosition = Vector2.new(0, scroll.AbsoluteCanvasSize.Y)
            end
        end)
    end

    function console:Clear()
        for i = 1, #logs do logs[i]:Destroy() end
        table.clear(logs)
        lineCount = 0
    end

    return console
end

function LuaUEngine.new(canvasGroup)
    if canvasGroup and canvasGroup:IsA("CanvasGroup") then
        local replacement = Instance.new("Frame")
        replacement.Name = canvasGroup.Name
        replacement.Size = canvasGroup.Size
        replacement.Position = canvasGroup.Position
        replacement.AnchorPoint = canvasGroup.AnchorPoint
        replacement.BackgroundColor3 = canvasGroup:GetAttribute("BackgroundColor3") or canvasGroup.BackgroundColor3
        replacement.BackgroundTransparency = canvasGroup:GetAttribute("BackgroundTransparency") or canvasGroup.BackgroundTransparency
        replacement.BorderColor3 = canvasGroup.BorderColor3
        replacement.BorderSizePixel = 0
        replacement.ZIndex = canvasGroup.ZIndex
        replacement.LayoutOrder = canvasGroup.LayoutOrder
        replacement.ClipsDescendants = true
        replacement.Parent = canvasGroup.Parent
        for k, v in pairs(canvasGroup:GetAttributes()) do
            replacement:SetAttribute(k, v)
        end
        for _, child in ipairs(canvasGroup:GetChildren()) do
            child.Parent = replacement
        end
        canvasGroup:Destroy()
        canvasGroup = replacement
    end

    local initText = canvasGroup:GetAttribute("Text")
    if initText and initText:find("\t", 1, true) then
        canvasGroup:SetAttribute("Text", initText:gsub("\t", "    "))
    end

    local self = setmetatable({}, LuaUEngine)
    self.CanvasGroup = canvasGroup
    self.Connections = {}
    self.Destroyed = false

    self.LinesPool = {}
    self.HighlightPool = {}
    self.LineNumbersPool = {}
    self.MinimapLinesPool = {}
    self.FoldButtonsPool = {}
    self.IndentGuidesPool = {}
    self.AutocompleteRows = {}

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
    self.History = {{ text = "", cursor = 0, sel = 0 }}
    self.HistoryIdx = 1
    self.SinkActionName = "LuaUEngineSink_" .. HttpService:GenerateGUID(false)
    self.FindUI = nil
    self.FindMatches = {}
    self.CurrentMatchIndex = 0
    self.FindTextConn = nil
    self.FindResizeConn = nil

    self.SuppressedKeys = {}
    self.AwaitingRelease = false

    self.CachedText = nil
    self.CachedTextSize = nil
    self.CachedFont = nil
    self.CachedLimitX = nil
    self.CachedLimitY = nil
    self.CachedLineMap = nil

    self.AutocompleteVisible = false
    self.AutocompleteMatches = {}
    self.AutocompleteIndex = 1
    self.AutocompleteSelectionColor = Color3.fromRGB(45, 90, 160)
    self.AutocompleteBackgroundColor = Color3.fromRGB(30, 30, 30)
    self.AutocompleteTextColor = Color3.fromRGB(220, 220, 220)
    self.AutocompleteSelectedTextColor = Color3.fromRGB(255, 255, 255)

    Baseline.Instances[#Baseline.Instances + 1] = self

    do
        local f = Instance.new("Frame")
        f.Name = "LuaUEngineCurrentLine"
        f.BackgroundColor3 = Color3.fromRGB(53, 55, 65)
        f.BackgroundTransparency = 0.5
        f.BorderSizePixel = 0
        f.ZIndex = 1
        f.Visible = false
        f.Parent = canvasGroup
        self.CurrentLineHighlight = f
    end

    do
        local outer = Instance.new("Frame")
        outer.Name = "LuaUEngineLineNumbers"
        outer.BackgroundTransparency = 1
        outer.ClipsDescendants = true
        outer.ZIndex = 11
        outer.Parent = canvasGroup
        self.LineNumbersContainer = outer

        local inner = Instance.new("Frame")
        inner.Name = "LuaUEngineLineNumbersInner"
        inner.BackgroundTransparency = 1
        inner.Size = UDim2.new(1, 0, 0, 0)
        inner.Parent = outer
        self.LineNumbersInner = inner
    end

    do
        local outer = Instance.new("Frame")
        outer.Name = "LuaUEngineMinimap"
        outer.BackgroundTransparency = 1
        outer.ClipsDescendants = true
        outer.ZIndex = 2
        outer.Parent = canvasGroup
        self.MinimapContainer = outer

        local inner = Instance.new("Frame")
        inner.Name = "LuaUEngineMinimapInner"
        inner.BackgroundTransparency = 1
        inner.Size = UDim2.new(1, 0, 1, 0)
        inner.Parent = outer
        self.MinimapInner = inner

        local slider = Instance.new("Frame")
        slider.Name = "LuaUEngineMinimapSlider"
        slider.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        slider.BackgroundTransparency = 0.8
        slider.BorderSizePixel = 0
        slider.ZIndex = 3
        slider.Parent = inner
        self.MinimapSlider = slider
    end

    do
        local c = Instance.new("Frame")
        c.Name = "LuaUEngineTextContainer"
        c.BackgroundTransparency = 1
        c.ClipsDescendants = true
        c.ZIndex = 2
        c.Parent = canvasGroup
        self.TextContainer = c

        local inner = Instance.new("Frame")
        inner.Name = "LuaUEngineInnerFrame"
        inner.BackgroundTransparency = 1
        inner.Size = UDim2.new(0, 0, 0, 0)
        inner.Parent = c
        self.InnerFrame = inner

        local guides = Instance.new("Frame")
        guides.Name = "LuaUEngineIndentGuides"
        guides.BackgroundTransparency = 1
        guides.Size = UDim2.new(0, 0, 0, 0)
        guides.ZIndex = 1
        guides.Parent = inner
        self.IndentGuideContainer = guides
    end

    do
        local ph = Instance.new("TextLabel")
        ph.Name = "PlaceholderTextLabel"
        ph.Size = UDim2.new(0, 10000, 0, 25)
        ph.Position = UDim2.new(0, 4, 0, 4)
        ph.BackgroundTransparency = 1
        ph.TextWrapped = false
        ph.TextXAlignment = Enum.TextXAlignment.Left
        ph.TextYAlignment = Enum.TextYAlignment.Top
        ph.ZIndex = 1
        ph.Parent = self.InnerFrame
        self.PlaceholderLabel = ph
    end

    do
        local g = Instance.new("TextLabel")
        g.Name = "GhostTextLabel"
        g.Size = UDim2.new(0, 10000, 0, 25)
        g.BackgroundTransparency = 1
        g.TextColor3 = Color3.fromRGB(130, 130, 130)
        g.TextXAlignment = Enum.TextXAlignment.Left
        g.TextYAlignment = Enum.TextYAlignment.Top
        g.ZIndex = 3
        g.Visible = false
        g.Parent = self.InnerFrame
        self.GhostTextLabel = g
    end

    do
        local h = Instance.new("Frame")
        h.Name = "LuaUEngineHighlightContainer"
        h.Size = UDim2.new(0, 0, 0, 0)
        h.BackgroundTransparency = 1
        h.ZIndex = 2
        h.Parent = self.InnerFrame
        self.HighlightContainer = h
    end

    do
        local b = Instance.new("Frame")
        b.Name = "LuaUEngineBlinker"
        b.Size = UDim2.new(0, 1, 0, 14)
        b.BackgroundColor3 = Color3.new(1, 1, 1)
        b.BorderSizePixel = 0
        b.Visible = false
        b.ZIndex = 4
        b.Parent = self.InnerFrame
        self.Blinker = b
    end

    do
        local pb = Instance.new("TextBox")
        pb.Name = "LuaUEnginePasteBox"
        pb.Size = UDim2.new(1, 0, 1, 0)
        pb.BackgroundTransparency = 1
        pb.TextTransparency = 1
        pb.ClearTextOnFocus = false
        pb.MultiLine = true
        pb.Text = ""
        pb.ZIndex = 10
        pb.Parent = canvasGroup
        self.PasteBox = pb
    end

    do
        local ui = Instance.new("Frame")
        ui.Name = "AutocompleteUI"
        ui.Size = UDim2.new(0, 240, 0, 160)
        ui.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
        ui.BorderSizePixel = 0
        ui.ZIndex = 100
        ui.Visible = false
        ui.Parent = canvasGroup
        self.AutocompleteUI = ui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = ui

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(0, 0, 0)
        stroke.Transparency = 0.6
        stroke.Thickness = 1
        stroke.Parent = ui

        local scroll = Instance.new("ScrollingFrame")
        scroll.Size = UDim2.new(1, -2, 1, -2)
        scroll.Position = UDim2.new(0, 1, 0, 1)
        scroll.BackgroundTransparency = 1
        scroll.ScrollBarThickness = 2
        scroll.ScrollBarImageTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.None
        scroll.ZIndex = 101
        scroll.Parent = ui
        self.AutocompleteScroll = scroll

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = scroll

        local hint = Instance.new("Frame")
        hint.Name = "AutocompleteHint"
        hint.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
        hint.BorderSizePixel = 0
        hint.Visible = false
        hint.ZIndex = 101
        hint.Parent = ui
        self.AutocompleteHint = hint

        local hc = Instance.new("UICorner")
        hc.CornerRadius = UDim.new(0, 4)
        hc.Parent = hint

        local hs = Instance.new("UIStroke")
        hs.Color = Color3.fromRGB(0, 0, 0)
        hs.Transparency = 0.6
        hs.Thickness = 1
        hs.Parent = hint

        local ht = Instance.new("TextLabel")
        ht.Size = UDim2.new(1, -10, 1, 0)
        ht.Position = UDim2.new(0, 5, 0, 0)
        ht.BackgroundTransparency = 1
        ht.TextColor3 = Color3.fromRGB(200, 200, 210)
        ht.Font = Enum.Font.Code
        ht.TextSize = 12
        ht.TextXAlignment = Enum.TextXAlignment.Left
        ht.ZIndex = 102
        ht.Parent = hint
        self.AutocompleteHintText = ht
    end

    canvasGroup.ClipsDescendants = true
    canvasGroup.Active = true

    if not canvasGroup:GetAttribute("HideScrollbars") then
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
        if text == "" then return end
        task.defer(function()
            if self.PasteBox and self.PasteBox.Text == text then self.PasteBox.Text = "" end
        end)
        if self.AwaitingRelease then return end
        if text == "\n" or text == "\r\n" or text == "\r" then return end
        local isManualKeystroke = (#text == 1) and (text == self.LastTypedChar) and ((tick() - self.LastTypedTick) < CONST.PASTE_GAP)
        if not isManualKeystroke then self:PasteChunked(text) end
    end))

    table.insert(self.Connections, self.PasteBox.FocusLost:Connect(function()
        if not self.IsFocused then return end
        task.defer(function()
            if not self.IsFocused or self.Destroyed or self.AwaitingRelease then return end
            if self.PasteBox then self.PasteBox:CaptureFocus() end
        end)
    end))

    table.insert(self.Connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if self.Destroyed then return end

        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local pos = input.Position
            local function isInside(gui)
                if not gui or not gui.Visible then return false end
                local ap = gui.AbsolutePosition
                local as = gui.AbsoluteSize
                return pos.X >= ap.X and pos.X <= ap.X + as.X and pos.Y >= ap.Y and pos.Y <= ap.Y + as.Y
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

            if isInside(self.CanvasGroup) then
                self:Focus()
                self:HideAutocomplete()

                local relX = (pos.X - self.InnerFrame.AbsolutePosition.X) - 4
                local relY = (pos.Y - self.InnerFrame.AbsolutePosition.Y) - 4
                local shiftDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
                local closestIdx = self:GetClosestCursorIndex(relX, relY)
                local now = tick()
                if (now - self.LastClickTime) < CONST.DOUBLE_CLICK_MS then
                    self.ClickCount = self.ClickCount + 1
                else
                    self.ClickCount = 1
                end
                self.LastClickTime = now

                local dispText = self:GetDisplayText()
                if self.ClickCount == 2 then
                    self.SelectionStart, self.CursorIndex = Utils.getWordAtIndex(dispText, closestIdx)
                elseif self.ClickCount == 3 then
                    local ts = self.CanvasGroup:GetAttribute("TextSize")
                    local font = self.CanvasGroup:GetAttribute("Font")
                    local lm = self:GetLineMapCached(dispText, ts, font, self:GetLimit())
                    for i = 1, #lm do
                        local line = lm[i]
                        local rEnd = line.renderEndIdx or line.endIdx
                        if closestIdx >= (line.startIdx - 1) and closestIdx <= rEnd then
                            self.SelectionStart = line.startIdx - 1
                            self.CursorIndex = line.endIdx
                            break
                        end
                    end
                elseif shiftDown then
                    self.CursorIndex = closestIdx
                else
                    self.SelectionStart = closestIdx
                    self.CursorIndex = closestIdx
                end
                self.IsDragging = true
                self:UpdateBlinker(false)
            else
                self:Unfocus()
            end
        elseif input.UserInputType == Enum.UserInputType.Keyboard then
            if not self.IsFocused then return end

            if self.AwaitingRelease then
                if KeyMaps.SinkSet[input.KeyCode] then
                    self.SuppressedKeys[input.KeyCode] = true
                end
                return
            end

            if gameProcessed and not KeyMaps.SinkSet[input.KeyCode] then return end

            if self.SuppressedKeys[input.KeyCode] then return end

            if self.AutocompleteVisible then
                local text = self.CanvasGroup:GetAttribute("Text") or ""
                local word = Utils.getWordBeforeCursor(text, self.CursorIndex)
                local match = self.AutocompleteMatches[self.AutocompleteIndex]
                local kc = input.KeyCode
                if kc == Enum.KeyCode.Down then
                    self.AutocompleteIndex = math.min(self.AutocompleteIndex + 1, #self.AutocompleteMatches)
                    self:RenderAutocomplete()
                    return
                elseif kc == Enum.KeyCode.Up then
                    self.AutocompleteIndex = math.max(self.AutocompleteIndex - 1, 1)
                    self:RenderAutocomplete()
                    return
                elseif kc == Enum.KeyCode.Right then
                    if self.GhostTextLabel.Visible and self:CommitAutocomplete() then return end
                elseif kc == Enum.KeyCode.Tab then
                    if self:CommitAutocomplete() then return end
                elseif kc == Enum.KeyCode.Return or kc == Enum.KeyCode.KeypadEnter then
                    if match and match.word == word then
                        self:HideAutocomplete()
                        return
                    elseif self:CommitAutocomplete() then
                        return
                    end
                elseif kc == Enum.KeyCode.Escape then
                    self:HideAutocomplete()
                    return
                end
            end

            local shiftDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
            local ctrlDown = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)

            if ctrlDown and shiftDown and input.KeyCode == Enum.KeyCode.F then
                self:Format()
                return
            end
            if ctrlDown and input.KeyCode == Enum.KeyCode.A then
                self.SelectionStart = 0
                self.CursorIndex = #(self:GetDisplayText())
                self:UpdateBlinker(true)
                return
            elseif ctrlDown and input.KeyCode == Enum.KeyCode.Z then
                self:Undo()
                return
            elseif ctrlDown and input.KeyCode == Enum.KeyCode.Y then
                self:Redo()
                return
            elseif ctrlDown and input.KeyCode == Enum.KeyCode.C then
                self:Copy()
                return
            elseif ctrlDown and input.KeyCode == Enum.KeyCode.X then
                self:Cut()
                return
            elseif ctrlDown and input.KeyCode == Enum.KeyCode.V then
                self.LastTypedChar = ""
                return
            elseif ctrlDown and input.KeyCode == Enum.KeyCode.F then
                self:ToggleFindUI()
                return
            end

            local kc = input.KeyCode
            local isRepeatable = kc == Enum.KeyCode.Backspace
                or kc == Enum.KeyCode.Return
                or kc == Enum.KeyCode.KeypadEnter
                or kc == Enum.KeyCode.Left
                or kc == Enum.KeyCode.Right
                or kc == Enum.KeyCode.Up
                or kc == Enum.KeyCode.Down
                or kc == Enum.KeyCode.Tab
                or Utils.getCharacter(kc, shiftDown) ~= ""

            self:ProcessKey(kc, shiftDown, ctrlDown)
            if isRepeatable then
                self.HeldKey = kc
                self.KeyTimer = 0
                self.KeyTick = 0
            end
        end
    end))

    table.insert(self.Connections, UserInputService.InputChanged:Connect(function(input)
        if self.Destroyed then return end
        if self.DraggingMinimap and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            self:ScrollToMinimap(input.Position.Y)
            return
        end
        if self.IsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local pos = input.Position
            local relX = (pos.X - self.InnerFrame.AbsolutePosition.X) - 4
            local relY = (pos.Y - self.InnerFrame.AbsolutePosition.Y) - 4
            self.CursorIndex = self:GetClosestCursorIndex(relX, relY)
            self:UpdateBlinker(true)
        end
    end))

    table.insert(self.Connections, UserInputService.InputEnded:Connect(function(input)
        if self.Destroyed then return end
        if input.KeyCode and self.SuppressedKeys[input.KeyCode] then
            self.SuppressedKeys[input.KeyCode] = nil
        end
        if input.KeyCode == self.HeldKey then
            self.HeldKey = nil
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            self.IsDragging = false
            self.DraggingMinimap = false
        end
    end))

    table.insert(self.Connections, RunService.RenderStepped:Connect(function(dt)
        if self.Destroyed then return end
        if dt > 0.1 then dt = 0 end

        if self.HeldKey then
            self.KeyTimer = self.KeyTimer + dt
            if self.KeyTimer > CONST.KEY_REPEAT_DELAY then
                self.KeyTick = self.KeyTick + dt
                if self.KeyTick > CONST.KEY_REPEAT_TICK then
                    self.KeyTick = 0
                    local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
                    local ctrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
                    self:ProcessKey(self.HeldKey, shift, ctrl)
                end
            end
        end

        if self.IsFocused then
            if self.SelectionStart == self.CursorIndex then
                self.BlinkTimer = self.BlinkTimer + dt
                if self.BlinkTimer > CONST.BLINK_INTERVAL then
                    self.BlinkTimer = 0
                    self.Blinker.Visible = not self.Blinker.Visible
                end
            else
                self.Blinker.Visible = false
            end
        end
    end))

    table.insert(self.Connections, self.CanvasGroup:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if self.Destroyed then return end
        self:UpdateBlinker(false)
    end))

    table.insert(self.Connections, canvasGroup.AttributeChanged:Connect(function(attributeName)
        if self.Destroyed then return end
        local value = canvasGroup:GetAttribute(attributeName)
        local updateAttrs = {
            Text = true, TextSize = true, Font = true, Minimap = true,
            HighlightColor = true, PasswordMode = true, HideScrollbars = true,
            Wrapped = true, Lines = true, LineNumberColor3 = true, TextColor3 = true,
            AutoHeight = true, StrokeColor3 = true, StrokeTransparency = true,
            StrokeThickness = true, IndentGuideColor3 = true,
            IndentGuideTransparency = true, IndentGuideThickness = true,
        }
        if updateAttrs[attributeName] then
            self:UpdateBlinker(true)
        elseif attributeName == "BlinkerColor" or attributeName == "BlinkerColor3" then
            self.Blinker.BackgroundColor3 = value
        elseif attributeName == "PlaceholderColor3" then
            self.PlaceholderLabel.TextColor3 = value
        elseif attributeName == "PlaceholderText" then
            self.PlaceholderLabel.Text = value
        end
    end))

    local proxyObj = setmetatable({}, {
        __index = function(_, key)
            local av = canvasGroup:GetAttribute(key)
            if av ~= nil then return av end
            if type(self[key]) == "function" then
                return function(_, ...) return self[key](self, ...) end
            end
            return self[key]
        end,
        __newindex = function(_, key, value)
            local allowed = {
                Text = true, MultiLine = true, Wrapped = true, Minimap = true,
                SmoothBlinker = true, TextSize = true, TextColor3 = true,
                BlinkerColor = true, BlinkerColor3 = true, HighlightColor = true, Font = true,
                PlaceholderText = true, PlaceholderColor3 = true, AutoHeight = true,
                MaxLength = true, PasswordMode = true, ReadOnly = true, HideScrollbars = true,
                TabIndex = true, Lines = true, LineNumberColor3 = true,
                StrokeColor3 = true, StrokeTransparency = true, StrokeThickness = true,
                IndentGuideColor3 = true, IndentGuideTransparency = true, IndentGuideThickness = true,
                ScrollBarTrackColor3 = true, ScrollBarTrackTransparency = true,
                ScrollBarThumbColor3 = true, ScrollBarThumbTransparency = true,
                ScrollBarHoverColor3 = true, ScrollBarPressColor3 = true,
                ScrollBarImageColor3 = true, ScrollBarStrokeColor3 = true,
                ScrollBarStrokeTransparency = true,
            }
            if key == "Text" and type(value) == "string" then
                value = value:gsub("\t", "    ")
            end
            if allowed[key] then
                canvasGroup:SetAttribute(key, value)
            else
                rawset(self, key, value)
            end
        end,
    })

    for key, def in pairs(GlobalSettings) do
        if canvasGroup:GetAttribute(key) == nil then
            proxyObj[key] = def
        end
    end

    self.PlaceholderLabel.Text = proxyObj.PlaceholderText
    self.PlaceholderLabel.TextColor3 = proxyObj.PlaceholderColor3
    self.PlaceholderLabel.Font = proxyObj.Font
    self.PlaceholderLabel.TextSize = proxyObj.TextSize
    self:UpdateBlinker(true)

    return proxyObj
end

function LuaUEngine:ApplyThemeRules(rules)
    self.SyntaxRules = rules
    if type(rules) == "table" then
        local function setIf(rule, apply)
            if rules[rule] and rules[rule].color then apply(rules[rule].color) end
        end
        setIf("TextColor", function(c)
            self.CanvasGroup:SetAttribute("TextColor3", c)
            self.PlaceholderLabel.TextColor3 = c
        end)
        setIf("BackgroundColor", function(c) self.CanvasGroup.BackgroundColor3 = c end)
        setIf("SelectionBackgroundColor", function(c) self.CanvasGroup:SetAttribute("HighlightColor", c) end)
        setIf("ScriptRulerColor", function(c) self.CanvasGroup:SetAttribute("LineNumberColor3", c) end)
        setIf("CurrentLineHighlightColor", function(c) self.CurrentLineHighlight.BackgroundColor3 = c end)
        setIf("MenuItemBackground", function(c)
            self.AutocompleteUI.BackgroundColor3 = c
            self.AutocompleteHint.BackgroundColor3 = c
            self.AutocompleteBackgroundColor = c
        end)
        setIf("SelectedMenuItemBackground", function(c) self.AutocompleteSelectionColor = c end)
        setIf("MenuPrimaryTextColor", function(c) self.AutocompleteTextColor = c end)
        setIf("MenuSelectedTextColor", function(c) self.AutocompleteSelectedTextColor = c end)
        setIf("MenuSecondaryTextColor", function(c) self.AutocompleteHintText.TextColor3 = c end)
        local scrollBg = rules.ScriptEditorScrollbarBackground and rules.ScriptEditorScrollbarBackground.color
        local scrollHandle = rules.ScriptEditorScrollbarHandle and rules.ScriptEditorScrollbarHandle.color
        if scrollBg or scrollHandle then
            if self.VScrollBar then self.VScrollBar:SetColors(scrollBg, scrollHandle) end
            if self.HScrollBar then self.HScrollBar:SetColors(scrollBg, scrollHandle) end
        end
    end
    self.CachedText = nil
    self:UpdateBlinker(false)
end

function LuaUEngine:ApplyStrokeToLabel(gui)
    if not gui then return end
    local stroke = gui:FindFirstChild("TextUIStroke")
    local thickness = self.CanvasGroup:GetAttribute("StrokeThickness") or 0
    if thickness > 0 then
        if not stroke then
            stroke = Instance.new("UIStroke")
            stroke.Name = "TextUIStroke"
            stroke.Parent = gui
        end
        stroke.Color = self.CanvasGroup:GetAttribute("StrokeColor3") or Color3.fromRGB(0, 0, 0)
        stroke.Transparency = self.CanvasGroup:GetAttribute("StrokeTransparency") or 0.92
        stroke.Thickness = thickness
        stroke.Enabled = true
    elseif stroke then
        stroke.Enabled = false
    end
end

function LuaUEngine:Format()
    local rawText = self.CanvasGroup:GetAttribute("Text") or ""
    if rawText == "" then return end

    local lines = {}
    local start = 1
    while true do
        local nl = rawText:find("\n", start, true)
        if not nl then
            lines[#lines + 1] = rawText:sub(start)
            break
        end
        lines[#lines + 1] = rawText:sub(start, nl - 1)
        start = nl + 1
    end
    if #lines > 1 and lines[#lines] == "" and rawText:sub(-1) == "\n" then
        table.remove(lines)
    end

    local result = {}
    local indent = 0
    for i = 1, #lines do
        local raw = lines[i]
        local trimmed = raw:match("^%s*(.-)%s*$") or ""
        if trimmed == "" then
            result[#result + 1] = ""
        else
            local leadingClose = 0
            local firstWord = trimmed:match("^([%w_]+)")
            if firstWord == "end" or firstWord == "until" or firstWord == "else" or firstWord == "elseif" then
                leadingClose = 1
            elseif trimmed:sub(1, 1):match("[%]%)}]") then
                leadingClose = 1
            end
            local thisIndent = math.max(0, indent - leadingClose)
            result[#result + 1] = string.rep("    ", thisIndent) .. trimmed
            indent = math.max(0, indent + Utils.getBlockDelta(trimmed))
        end
    end
    local finalText = table.concat(result, "\n")
    if rawText:sub(-1) == "\n" then finalText = finalText .. "\n" end
    self.CanvasGroup:SetAttribute("Text", finalText)
    self:PushHistory()
    self:UpdateBlinker(true)
end

function LuaUEngine:ScrollToMinimap(mouseY)
    if not self.MinimapContainer or not self.MinimapContainer.Visible then return end
    local relY = mouseY - self.MinimapContainer.AbsolutePosition.Y
    local miniV = self.MinimapContainer.AbsoluteSize.Y
    local ts = self.CanvasGroup:GetAttribute("TextSize") or 16
    local ratio = CONST.MINIMAP_DIV / ts
    local sMini = self.MinimapScrollY or 0
    local clickY = relY + sMini
    local viewportH = self.CanvasGroup.AbsoluteSize.Y - 8
    local sliderH = math.min(miniV, viewportH * ratio)
    local targetY = clickY - (sliderH / 2)
    local sMain = targetY / ratio
    local maxS = math.max(0, self.DocumentHeight - viewportH)
    sMain = math.clamp(sMain, 0, maxS)
    self.ScrollOffset = Vector2.new(self.ScrollOffset.X, sMain)
    self:UpdateBlinker(false)
end

function LuaUEngine:ToggleFindUI()
    if self.FindUI then self:CloseFindUI() else self:OpenFindUI() end
end

function LuaUEngine:OpenFindUI()
    if self.FindUI then return end

    local template = Instance.new("Frame")
    template.Name = "MainFrame"
    template.Size = UDim2.new(0, 260, 0, 88)
    template.Position = UDim2.new(0.5, -130, 0.3, 0)
    template.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    template.BorderSizePixel = 0
    template.ZIndex = 1
    template.AnchorPoint = Vector2.new(0, 0)

    local pad = Instance.new("UIPadding")
    pad.Parent = template

    local row1 = Instance.new("Frame")
    row1.Name = "Row1_Find"
    row1.Size = UDim2.new(1, 0, 0, 24)
    row1.BackgroundTransparency = 1
    row1.Parent = template

    local toggleBtn = Instance.new("ImageButton")
    toggleBtn.Name = "ToggleExpandBtn"
    toggleBtn.Size = UDim2.new(0, 20, 0, 20)
    toggleBtn.Position = UDim2.new(0, 0, 0, 2)
    toggleBtn.BackgroundTransparency = 1
    toggleBtn.Parent = row1

    local topChev = Instance.new("ImageLabel")
    topChev.Name = "TopChevron"
    topChev.Size = UDim2.new(0, 18, 0, 18)
    topChev.Position = UDim2.new(0.5, 0, 0.27, 0)
    topChev.AnchorPoint = Vector2.new(0.5, 0.5)
    topChev.Rotation = 180
    topChev.BackgroundTransparency = 1
    topChev.Image = Icons.FindTopChevron
    topChev.Parent = toggleBtn

    local botChev = Instance.new("ImageLabel")
    botChev.Name = "BottomChevron"
    botChev.Size = UDim2.new(0, 18, 0, 18)
    botChev.Position = UDim2.new(0.5, 0, 0.62, 0)
    botChev.AnchorPoint = Vector2.new(0.5, 0.5)
    botChev.Rotation = 180
    botChev.BackgroundTransparency = 1
    botChev.Image = Icons.FindBottomChevron
    botChev.Parent = toggleBtn

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
    findBox.Parent = row1

    local findPad = Instance.new("UIPadding")
    findPad.Parent = findBox

    local prevBtn = Instance.new("ImageButton")
    prevBtn.Name = "FindPrevBtn"
    prevBtn.Size = UDim2.new(0, 20, 0, 20)
    prevBtn.Position = UDim2.new(0, 185, 0, 2)
    prevBtn.BackgroundTransparency = 1
    prevBtn.Image = Icons.FindPrev
    prevBtn.Parent = row1

    local nextBtn = Instance.new("ImageButton")
    nextBtn.Name = "FindNextBtn"
    nextBtn.Size = UDim2.new(0, 20, 0, 20)
    nextBtn.Position = UDim2.new(0, 209, 0, 2)
    nextBtn.BackgroundTransparency = 1
    nextBtn.Image = Icons.FindNext
    nextBtn.Parent = row1

    local closeBtn = Instance.new("ImageButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(0, 241, 0, 2)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Image = Icons.FindClose
    closeBtn.Parent = row1

    local row2 = Instance.new("Frame")
    row2.Name = "Row2_Replace"
    row2.Size = UDim2.new(1, 0, 0, 24)
    row2.Position = UDim2.new(0, 0, 0, 28)
    row2.BackgroundTransparency = 1
    row2.Parent = template

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
    replaceBox.Parent = row2

    local replacePad = Instance.new("UIPadding")
    replacePad.Parent = replaceBox

    local replaceNext = Instance.new("ImageButton")
    replaceNext.Name = "ReplaceNextBtn"
    replaceNext.Size = UDim2.new(0, 20, 0, 20)
    replaceNext.Position = UDim2.new(0, 185, 0, 2)
    replaceNext.BackgroundTransparency = 1
    replaceNext.Parent = row2

    local replaceAll = Instance.new("ImageButton")
    replaceAll.Name = "ReplaceAllBtn"
    replaceAll.Size = UDim2.new(0, 20, 0, 20)
    replaceAll.Position = UDim2.new(0, 209, 0, 2)
    replaceAll.BackgroundTransparency = 1
    replaceAll.Parent = row2

    local row3 = Instance.new("Frame")
    row3.Name = "Row3_Options"
    row3.Size = UDim2.new(1, 0, 0, 20)
    row3.Position = UDim2.new(0, 0, 0, 56)
    row3.BackgroundTransparency = 1
    row3.Parent = template

    local matchCase = Instance.new("ImageButton")
    matchCase.Name = "MatchCaseBtn"
    matchCase.Size = UDim2.new(0, 20, 0, 20)
    matchCase.Position = UDim2.new(0, 24, 0, 0)
    matchCase.BackgroundTransparency = 1
    matchCase.Image = Icons.FindMatchCase
    matchCase.Parent = row3

    local matchWord = Instance.new("ImageButton")
    matchWord.Name = "MatchWholeWordBtn"
    matchWord.Size = UDim2.new(0, 20, 0, 20)
    matchWord.Position = UDim2.new(0, 48, 0, 0)
    matchWord.BackgroundTransparency = 1
    matchWord.Image = Icons.FindWholeWord
    matchWord.Parent = row3

    local useRegex = Instance.new("ImageButton")
    useRegex.Name = "UseRegexBtn"
    useRegex.Size = UDim2.new(0, 20, 0, 20)
    useRegex.Position = UDim2.new(0, 72, 0, 0)
    useRegex.BackgroundTransparency = 1
    useRegex.Image = Icons.FindRegex
    useRegex.Parent = row3

    local showLbl = Instance.new("TextLabel")
    showLbl.Name = "Show"
    showLbl.Size = UDim2.new(0.68, 0, 1, 0)
    showLbl.Position = UDim2.new(0.32, 0, 0, 0)
    showLbl.BackgroundTransparency = 1
    showLbl.TextColor3 = Color3.new(1, 1, 1)
    showLbl.TextSize = 14
    showLbl.Font = Enum.Font.RobotoMono
    showLbl.TextXAlignment = Enum.TextXAlignment.Left
    showLbl.Text = ""
    showLbl.Parent = row3

    local uiScale = Instance.new("UIScale")
    uiScale.Parent = template

    local findUI = template:Clone()
    self.FindUI = findUI
    findUI.AnchorPoint = Vector2.new(1, 0)
    findUI.Position = UDim2.new(1, -20, 0, 8)
    findUI.ZIndex = 100
    for _, d in ipairs(findUI:GetDescendants()) do
        if d:IsA("GuiObject") then d.ZIndex = 101 end
    end
    findUI.Parent = self.CanvasGroup

    self.FindMatches = {}
    self.CurrentMatchIndex = 0
    local findOptions = { MatchCase = false, WholeWord = false, Regex = false }
    row2.Visible = false
    row3.Position = UDim2.new(0, 0, 0, 28)
    findUI.Size = UDim2.new(0, 260, 0, 62)

    local function addHover(btn)
        local hov = Instance.new("Frame")
        hov.Name = "HoverFrame"
        hov.Size = UDim2.new(1, 0, 1, 0)
        hov.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
        hov.BackgroundTransparency = 1
        hov.BorderSizePixel = 0
        hov.ZIndex = 1
        hov.Parent = btn
        btn.MouseEnter:Connect(function() hov.BackgroundTransparency = 0.5 end)
        btn.MouseLeave:Connect(function() hov.BackgroundTransparency = 1 end)
    end

    local function updateMatches(query, avoidJump)
        self.FindMatches = {}
        if not query or query == "" then
            showLbl.Text = ""
            if avoidJump then self:UpdateBlinker(false)
            else self.SelectionStart = self.CursorIndex; self:UpdateBlinker(true) end
            return
        end
        local editorText = self.CanvasGroup:GetAttribute("Text") or ""
        local searchStart = 1
        while true do
            local s, e
            if findOptions.Regex then
                local pattern = query
                if not findOptions.MatchCase then pattern = pattern:lower() end
                if findOptions.WholeWord then pattern = "%f[%w_]" .. pattern .. "%f[^%w_]" end
                local target = findOptions.MatchCase and editorText or editorText:lower()
                local ok, rs, re = pcall(function() return target:find(pattern, searchStart, false) end)
                if ok then s, e = rs, re end
            else
                local pattern = query:gsub("([%%%.%+%-%*%?%[%]%^%$%(%)])", "%%%1")
                if not findOptions.MatchCase then pattern = pattern:lower() end
                if findOptions.WholeWord then pattern = "%f[%w_]" .. pattern .. "%f[^%w_]" end
                local target = findOptions.MatchCase and editorText or editorText:lower()
                s, e = target:find(pattern, searchStart, false)
            end
            if not s then break end
            self.FindMatches[#self.FindMatches + 1] = { s = s - 1, e = e }
            searchStart = e + 1
        end
        local count = #self.FindMatches
        if count == 0 then
            showLbl.Text = "No results"
            if avoidJump then self:UpdateBlinker(false)
            else self.SelectionStart = self.CursorIndex; self:UpdateBlinker(true) end
            return
        end
        if not avoidJump then
            self.CurrentMatchIndex = 1
            showLbl.Text = "1 of " .. count .. " matches"
            self.SelectionStart = self.FindMatches[1].s
            self.CursorIndex = self.FindMatches[1].e
            self:UpdateBlinker(true)
        else
            self.CurrentMatchIndex = math.clamp(self.CurrentMatchIndex, 1, count)
            showLbl.Text = self.CurrentMatchIndex .. " of " .. count .. " matches"
            self:UpdateBlinker(false)
        end
    end

    local function jumpTo(idx)
        local count = #self.FindMatches
        if count == 0 then return end
        if idx < 1 then idx = count end
        if idx > count then idx = 1 end
        self.CurrentMatchIndex = idx
        showLbl.Text = idx .. " of " .. count .. " matches"
        self.SelectionStart = self.FindMatches[idx].s
        self.CursorIndex = self.FindMatches[idx].e
        self:UpdateBlinker(true)
    end

    do
        local b
        b = row1:FindFirstChild("CloseBtn")
        if b then addHover(b); b.MouseButton1Click:Connect(function() self:CloseFindUI() end) end
        b = row1:FindFirstChild("FindPrevBtn")
        if b then addHover(b); b.MouseButton1Click:Connect(function() jumpTo(self.CurrentMatchIndex - 1) end) end
        b = row1:FindFirstChild("FindNextBtn")
        if b then addHover(b); b.MouseButton1Click:Connect(function() jumpTo(self.CurrentMatchIndex + 1) end) end

        local tb = row1:FindFirstChild("ToggleExpandBtn")
        if tb then
            addHover(tb)
            local expanded = false
            tb.MouseButton1Click:Connect(function()
                expanded = not expanded
                if topChev then topChev.Rotation = expanded and 180 or 0 end
                if botChev then botChev.Rotation = expanded and 180 or 0 end
                row2.Visible = expanded
                local w = math.clamp(self.CanvasGroup.AbsoluteSize.X - 16, CONST.FIND_MIN_WIDTH, CONST.FIND_MAX_WIDTH)
                if expanded then
                    row3.Position = UDim2.new(0, 0, 0, 56)
                    findUI.Size = UDim2.new(0, w, 0, 88)
                else
                    row3.Position = UDim2.new(0, 0, 0, 28)
                    findUI.Size = UDim2.new(0, w, 0, 62)
                end
            end)
        end

        local sb = row1:FindFirstChild("FindBox")
        if sb then
            sb.MultiLine = false
            sb.ClearTextOnFocus = false
            sb.Focused:Connect(function() self:Unfocus() end)
            sb.FocusLost:Connect(function(enter)
                if enter then
                    jumpTo(self.CurrentMatchIndex + 1)
                    task.defer(function()
                        if sb and self.FindUI then
                            sb:CaptureFocus()
                            sb.CursorPosition = #sb.Text + 1
                        end
                    end)
                elseif not self.FindUI then
                    self:Focus()
                end
            end)
            sb:GetPropertyChangedSignal("Text"):Connect(function()
                local raw = sb.Text
                local clean = raw:gsub("[\n\r]", "")
                if raw ~= clean then sb.Text = clean; return end
                updateMatches(clean, false)
            end)
            if self.SelectionStart ~= self.CursorIndex then
                local s = math.min(self.SelectionStart, self.CursorIndex)
                local e = math.max(self.SelectionStart, self.CursorIndex)
                local editorText = self.CanvasGroup:GetAttribute("Text") or ""
                local selected = editorText:sub(s + 1, e)
                if selected ~= "" then
                    sb.Text = selected:gsub("[\n\r]", "")
                end
            end
            if self.FindTextConn then self.FindTextConn:Disconnect() end
            self.FindTextConn = self.CanvasGroup:GetAttributeChangedSignal("Text"):Connect(function()
                if sb and sb.Parent then updateMatches(sb.Text, true) end
            end)
        end
    end

    do
        local b = row2:FindFirstChild("ReplaceNextBtn"); if b then addHover(b) end
        b = row2:FindFirstChild("ReplaceAllBtn"); if b then addHover(b) end
        local rb = row2:FindFirstChild("ReplaceBox")
        if rb then
            rb.MultiLine = false
            rb.ClearTextOnFocus = false
            rb.Focused:Connect(function() self:Unfocus() end)
            rb:GetPropertyChangedSignal("Text"):Connect(function()
                local raw = rb.Text
                local clean = raw:gsub("[\n\r]", "")
                if raw ~= clean then rb.Text = clean end
            end)
        end
    end

    do
        local sb = row1:FindFirstChild("FindBox")
        local function updateOpt(btn, state)
            if not btn then return end
            btn.ImageColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
        end
        local mc = row3:FindFirstChild("MatchCaseBtn")
        if mc then
            addHover(mc); updateOpt(mc, findOptions.MatchCase)
            mc.MouseButton1Click:Connect(function()
                findOptions.MatchCase = not findOptions.MatchCase
                updateOpt(mc, findOptions.MatchCase)
                if sb then updateMatches(sb.Text, false) end
            end)
        end
        local mw = row3:FindFirstChild("MatchWholeWordBtn")
        if mw then
            addHover(mw); updateOpt(mw, findOptions.WholeWord)
            mw.MouseButton1Click:Connect(function()
                findOptions.WholeWord = not findOptions.WholeWord
                updateOpt(mw, findOptions.WholeWord)
                if sb then updateMatches(sb.Text, false) end
            end)
        end
        local rx = row3:FindFirstChild("UseRegexBtn")
        if rx then
            addHover(rx); updateOpt(rx, findOptions.Regex)
            rx.MouseButton1Click:Connect(function()
                findOptions.Regex = not findOptions.Regex
                updateOpt(rx, findOptions.Regex)
                if sb then updateMatches(sb.Text, false) end
            end)
        end
    end

    self.FindResizeConn = self.CanvasGroup:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if not self.FindUI then return end
        local w = math.clamp(self.CanvasGroup.AbsoluteSize.X - 16, CONST.FIND_MIN_WIDTH, CONST.FIND_MAX_WIDTH)
        local h = self.FindUI.Size.Y.Offset
        self.FindUI.Size = UDim2.new(0, w, 0, h)
    end)
end

function LuaUEngine:CloseFindUI()
    if not self.FindUI then return end
    local menu = self.FindUI
    self.FindUI = nil
    menu:Destroy()
    if self.FindTextConn then self.FindTextConn:Disconnect(); self.FindTextConn = nil end
    if self.FindResizeConn then self.FindResizeConn:Disconnect(); self.FindResizeConn = nil end
    self.FindMatches = {}
    self.CurrentMatchIndex = 0
    self.SelectionStart = self.CursorIndex
    self:UpdateBlinker(true)
end

function LuaUEngine:Import(module)
    if typeof(module) == "string" then
        local sm = self.CanvasGroup:FindFirstChild(module)
        if sm and sm:IsA("ModuleScript") then
            local rules = require(sm)
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

function LuaUEngine:ImportTheme(url)
    task.spawn(function()
        pcall(function()
            local loadFunc = loadstring or (getfenv and getfenv().loadstring)
            local function fetch()
                if getgenv and getgenv().game and getgenv().game.HttpGet then
                    return getgenv().game:HttpGet(url)
                elseif game and game.HttpGet then
                    return game:HttpGet(url)
                end
                return HttpService:GetAsync(url)
            end
            local source = fetch()
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

function LuaUEngine:GetSyntaxStateAt(text, targetIdx, startIdx, startStateStr)
    local i = startIdx or 1
    local state = startStateStr
    while i < targetIdx do
        if state and state ~= "none" then
            local sType, sClose = state:match("^(.-)_(.-)$")
            if not sType then sType, sClose = "comment", "\n" end
            if state == "comment_\\n" then
                local nl = text:find("\n", i, true)
                if nl and nl < targetIdx then i = nl + 1; state = "none" else break end
            elseif sType == "string" and (sClose == '"' or sClose == "'") then
                local endIdx = nil
                local s = i
                while s < targetIdx do
                    local nq = text:find(sClose, s, true)
                    if not nq then break end
                    local bs = 0
                    local bi = nq - 1
                    while bi >= 1 and text:sub(bi, bi) == "\\" do bs = bs + 1; bi = bi - 1 end
                    if (bs % 2) == 0 then endIdx = nq; break else s = nq + 1 end
                end
                if endIdx and endIdx < targetIdx then i = endIdx + 1; state = "none" else break end
            else
                local e = text:find(sClose, i, true)
                if e and (e + #sClose) <= targetIdx then i = e + #sClose; state = "none" else break end
            end
        else
            local nc = text:find('[\"\'%[%-]', i)
            if not nc or nc >= targetIdx then break end
            i = nc
            local c = text:sub(i, i)
            if c == '"' or c == "'" then
                state = "string_" .. c
                i = i + 1
            elseif c == "[" and text:sub(i, i + 20):match("^%[=*%[") then
                local m = text:sub(i, i + 20):match("^%[=*%[")
                state = "string_]" .. string.rep("=", #m - 2) .. "]"
                i = i + #m
            elseif c == "-" and text:sub(i + 1, i + 1) == "-" then
                local m = text:sub(i + 2, i + 22):match("^%[=*%[")
                if m then
                    state = "comment_]" .. string.rep("=", #m - 2) .. "]"
                    i = i + 2 + #m
                else
                    state = "comment_\\n"
                    i = i + 2
                end
            else
                i = i + 1
            end
        end
    end
    return state
end

function LuaUEngine:ApplySyntaxCached(lineData, lineText, startState)
    local key = startState or "none"
    if lineData.richText and lineData.syntaxStateStr == key then
        return lineData.richText
    end
    local rich = self:ApplySyntax(lineText, startState)
    lineData.richText = rich
    lineData.syntaxStateStr = key
    return rich
end

function LuaUEngine:ApplySyntax(lineText, startStateStr)
    if type(self.SyntaxRules) ~= "table" or lineText == "" then
        return Utils.escapeRichText(lineText)
    end
    if #lineText > CONST.MAX_LINE_CHARS then return Utils.escapeRichText(lineText) end

    local results = {}
    local len = #lineText
    local i = 1
    local state = startStateStr
    local function hexOf(rule, default)
        if type(self.SyntaxRules) ~= "table" then return default end
        local r = self.SyntaxRules[rule]
        if r and r.color then
            local c = r.color
            return string.format("#%02X%02X%02X",
                math.floor(c.R * 255 + 0.5),
                math.floor(c.G * 255 + 0.5),
                math.floor(c.B * 255 + 0.5))
        end
        return default
    end
    local commentHex = hexOf("comment_single", "#6272A4")
    local stringHex = hexOf("string_literal", "#F1FA8C")
    local opHex = hexOf("op_add", "#BCBEC8")
    local defaultHex = hexOf("TextColor", "#F8F8F2")

    if state and state ~= "none" then
        local sType, sClose = state:match("^(.-)_(.-)$")
        if not sType then sType, sClose = "comment", "\n" end
        if sClose == "\\n" then
            results[#results + 1] = '<font color="' .. commentHex .. '">' .. Utils.escapeRichText(lineText) .. "</font>"
            return table.concat(results)
        end
        local closeHex = (sType == "comment") and commentHex or stringHex
        local endIdx
        if sType == "string" and (sClose == '"' or sClose == "'") then
            local s = i
            while s <= len do
                local nq = lineText:find(sClose, s, true)
                if not nq then break end
                local bs = 0
                local bi = nq - 1
                while bi >= 1 and lineText:sub(bi, bi) == "\\" do bs = bs + 1; bi = bi - 1 end
                if (bs % 2) == 0 then endIdx = nq; break else s = nq + 1 end
            end
        else
            endIdx = lineText:find(sClose, i, true)
        end
        if endIdx then
            local chunk = lineText:sub(i, (endIdx + #sClose) - 1)
            results[#results + 1] = '<font color="' .. closeHex .. '">' .. Utils.escapeRichText(chunk) .. "</font>"
            i = endIdx + #sClose
            state = "none"
        else
            results[#results + 1] = '<font color="' .. closeHex .. '">' .. Utils.escapeRichText(lineText:sub(i)) .. "</font>"
            return table.concat(results)
        end
    end

    while i <= len do
        local c = lineText:sub(i, i)
        if c:match("[%a_]") then
            local s = i
            while i <= len and lineText:sub(i, i):match("[%w_]") do i = i + 1 end
            local word = lineText:sub(s, i - 1)
            local j = i
            while j <= len and lineText:sub(j, j):match("%s") do j = j + 1 end
            local isCall = j <= len and lineText:sub(j, j) == "("
            local rule = type(self.SyntaxRules) == "table" and self.SyntaxRules[word] or nil
            local hex = defaultHex
            local bold = false
            if rule then
                if rule.color then
                    local cc = rule.color
                    hex = string.format("#%02X%02X%02X",
                        math.floor(cc.R * 255 + 0.5),
                        math.floor(cc.G * 255 + 0.5),
                        math.floor(cc.B * 255 + 0.5))
                end
                if word == "local" or rule.type == "keyword" then bold = true end
            elseif isCall then
                hex = hexOf("function_name", "#50FA7B")
            end
            if bold then
                results[#results + 1] = '<font color="' .. hex .. '" weight="SemiBold">' .. Utils.escapeRichText(word) .. "</font>"
            else
                results[#results + 1] = '<font color="' .. hex .. '">' .. Utils.escapeRichText(word) .. "</font>"
            end
        elseif c:match("%d") then
            local s = i
            while i <= len and lineText:sub(i, i):match("[%d%.]") do i = i + 1 end
            local num = lineText:sub(s, i - 1)
            local hex = hexOf("num_integer", "#FFB86C")
            results[#results + 1] = '<font color="' .. hex .. '">' .. Utils.escapeRichText(num) .. "</font>"
        elseif c == '"' or c == "'" then
            local s = i
            local q = c
            i = i + 1
            while i <= len do
                local nq = lineText:find(q, i, true)
                if not nq then i = len + 1; break end
                local bs = 0
                local bi = nq - 1
                while bi >= (s + 1) and lineText:sub(bi, bi) == "\\" do bs = bs + 1; bi = bi - 1 end
                if (bs % 2) == 0 then i = nq + 1; break end
                i = nq + 1
            end
            local str = lineText:sub(s, i - 1)
            results[#results + 1] = '<font color="' .. stringHex .. '">' .. Utils.escapeRichText(str) .. "</font>"
        elseif c == "[" and lineText:sub(i, i + 20):match("^%[=*%[") then
            local s = i
            local m = lineText:sub(i, i + 20):match("^%[=*%[")
            local closeStr = "]" .. string.rep("=", #m - 2) .. "]"
            local e = lineText:find(closeStr, i + #m, true)
            if e then i = e + #closeStr else i = len + 1 end
            results[#results + 1] = '<font color="' .. stringHex .. '">' .. Utils.escapeRichText(lineText:sub(s, i - 1)) .. "</font>"
        elseif c == "-" and lineText:sub(i + 1, i + 1) == "-" then
            local s = i
            local m = lineText:sub(i + 2, i + 22):match("^%[=*%[")
            if m then
                local closeStr = "]" .. string.rep("=", #m - 2) .. "]"
                local e = lineText:find(closeStr, i + 2 + #m, true)
                if e then i = e + #closeStr else i = len + 1 end
            else
                i = len + 1
            end
            results[#results + 1] = '<font color="' .. commentHex .. '">' .. Utils.escapeRichText(lineText:sub(s, i - 1)) .. "</font>"
        elseif c:match("[%p]") then
            local op2 = lineText:sub(i, i + 1)
            local rule = KeyMaps.Operators[op2]
            local step = 1
            local opStr = c
            if rule then
                step = 2
                opStr = op2
            else
                rule = KeyMaps.Operators[c]
            end
            local hex = opHex
            if rule and type(self.SyntaxRules) == "table" and self.SyntaxRules[rule] then
                local cc = self.SyntaxRules[rule].color
                if cc then
                    hex = string.format("#%02X%02X%02X",
                        math.floor(cc.R * 255 + 0.5),
                        math.floor(cc.G * 255 + 0.5),
                        math.floor(cc.B * 255 + 0.5))
                end
            end
            results[#results + 1] = '<font color="' .. hex .. '">' .. Utils.escapeRichText(opStr) .. "</font>"
            i = i + step
        else
            results[#results + 1] = '<font color="' .. defaultHex .. '">' .. Utils.escapeRichText(c) .. "</font>"
            i = i + 1
        end
    end
    return table.concat(results)
end

function LuaUEngine:GetDisplayText()
    local raw = self.CanvasGroup:GetAttribute("Text") or ""
    if self.CanvasGroup:GetAttribute("PasswordMode") then
        return string.rep(".", utf8.len(raw) or #raw)
    end
    return raw
end

function LuaUEngine:PushHistory()
    local cur = self.CanvasGroup:GetAttribute("Text") or ""
    if self.History[self.HistoryIdx].text == cur then return end
    while #self.History > self.HistoryIdx do table.remove(self.History) end
    self.History[#self.History + 1] = { text = cur, cursor = self.CursorIndex, sel = self.SelectionStart }
    self.HistoryIdx = #self.History
end

function LuaUEngine:Undo()
    if self.HistoryIdx > 1 then
        self.HistoryIdx = self.HistoryIdx - 1
        local s = self.History[self.HistoryIdx]
        self.CanvasGroup:SetAttribute("Text", s.text)
        self.CursorIndex = s.cursor
        self.SelectionStart = s.sel
        self:UpdateBlinker(true)
    end
end

function LuaUEngine:Redo()
    if self.HistoryIdx < #self.History then
        self.HistoryIdx = self.HistoryIdx + 1
        local s = self.History[self.HistoryIdx]
        self.CanvasGroup:SetAttribute("Text", s.text)
        self.CursorIndex = s.cursor
        self.SelectionStart = s.sel
        self:UpdateBlinker(true)
    end
end

function LuaUEngine:Copy()
    if self.SelectionStart ~= self.CursorIndex then
        local s = math.min(self.SelectionStart, self.CursorIndex)
        local e = math.max(self.SelectionStart, self.CursorIndex)
        local text = self.CanvasGroup:GetAttribute("Text") or ""
        Baseline.Clipboard = text:sub(s + 1, e)
        local fn = setclipboard
        if fn then fn(Baseline.Clipboard) end
    end
end

function LuaUEngine:Cut()
    if self.CanvasGroup:GetAttribute("ReadOnly") then return end
    self:Copy()
    self:DeleteSelection()
end

function LuaUEngine:PasteChunked(text)
    if self.CanvasGroup:GetAttribute("ReadOnly") or self.IsPasting then return end
    self.IsPasting = true
    text = text:gsub("\r", ""):gsub("\t", "    ")

    local maxLen = self.CanvasGroup:GetAttribute("MaxLength")
    if maxLen and maxLen > 0 then
        local cur = self.CanvasGroup:GetAttribute("Text") or ""
        local curLen = utf8.len(cur) or 0
        local minI = math.min(self.SelectionStart, self.CursorIndex)
        local maxI = math.max(self.SelectionStart, self.CursorIndex)
        local selLen = utf8.len(cur:sub(minI + 1, maxI)) or 0
        local remaining = maxLen - (curLen - selLen)
        if remaining <= 0 then self.IsPasting = false; return end
        local endOff = utf8.offset(text, remaining + 1)
        if endOff then text = text:sub(1, endOff - 1) end
    end

    task.spawn(function()
        if self.Destroyed then self.IsPasting = false; return end
        if self.SelectionStart ~= self.CursorIndex then self:DeleteSelection() end
        local cur = self.CanvasGroup:GetAttribute("Text") or ""
        local before = cur:sub(1, self.CursorIndex)
        local after = cur:sub(self.CursorIndex + 1)
        self.CursorIndex = self.CursorIndex + #text
        self.SelectionStart = self.CursorIndex
        self.CanvasGroup:SetAttribute("Text", before .. text .. after)
        self:PushHistory()
        self.IsPasting = false
        self:UpdateBlinker(true)
    end)
end

function LuaUEngine:Paste()
    if self.CanvasGroup:GetAttribute("ReadOnly") then return end
    if Baseline.Clipboard and Baseline.Clipboard ~= "" then
        self:PasteChunked(Baseline.Clipboard)
    end
end

function LuaUEngine:Focus()
    if not self.IsFocused then
        self.IsFocused = true
        self.Blinker.Visible = self.SelectionStart == self.CursorIndex
        self.BlinkTimer = 0

        table.clear(self.SuppressedKeys)
        local anyHeld = false
        for kc in pairs(KeyMaps.SinkSet) do
            if UserInputService:IsKeyDown(kc) then
                self.SuppressedKeys[kc] = true
                anyHeld = true
            end
        end

        ContextActionService:BindAction(
            self.SinkActionName,
            function() return Enum.ContextActionResult.Sink end,
            false, unpack(KeyMaps.SinkKeys))

        self.AwaitingRelease = anyHeld
        if anyHeld then
            local pollToken = (self.ReleasePollToken or 0) + 1
            self.ReleasePollToken = pollToken
            task.spawn(function()
                while self.IsFocused and not self.Destroyed and self.ReleasePollToken == pollToken do
                    local stillHeld = false
                    for kc in pairs(KeyMaps.SinkSet) do
                        if UserInputService:IsKeyDown(kc) then
                            self.SuppressedKeys[kc] = true
                            stillHeld = true
                        end
                    end
                    if not stillHeld then break end
                    task.wait(CONST.RELEASE_POLL)
                end
                if self.IsFocused and not self.Destroyed and self.ReleasePollToken == pollToken then
                    self.AwaitingRelease = false
                    if self.PasteBox then self.PasteBox:CaptureFocus() end
                end
            end)
        else
            self.PasteBox:CaptureFocus()
        end
    else
        if not self.AwaitingRelease then
            self.PasteBox:CaptureFocus()
        end
    end
    self:UpdateBlinker(true)
end

function LuaUEngine:Unfocus()
    if not self.IsFocused then return end
    self.IsFocused = false
    self.AwaitingRelease = false
    self.ReleasePollToken = (self.ReleasePollToken or 0) + 1
    self.Blinker.Visible = false
    self.HeldKey = nil
    self.IsDragging = false
    self.DraggingMinimap = false
    self.SelectionStart = self.CursorIndex
    self:HideAutocomplete()
    self:UpdateBlinker(false)
    ContextActionService:UnbindAction(self.SinkActionName)
    self.PasteBox:ReleaseFocus()
end

function LuaUEngine:HideAutocomplete()
    self.AutocompleteVisible = false
    self.AutocompleteUI.Visible = false
    self.AutocompleteHint.Visible = false
    self.GhostTextLabel.Visible = false
    self.AutocompleteMatches = {}
    self.AutocompleteIndex = 1
end

function LuaUEngine:RenderAutocomplete()
    self.AutocompleteVisible = true
    self.AutocompleteUI.Visible = true
    local ROW_H = CONST.AUTOC_ROW_H
    local rows = self.AutocompleteRows
    local needed = #self.AutocompleteMatches
    for i = 1, needed do
        local row = rows[i]
        if not row then
            row = {}
            local rf = Instance.new("Frame")
            rf.Name = "ACRow" .. i
            rf.Size = UDim2.new(1, 0, 0, ROW_H)
            rf.BackgroundColor3 = self.AutocompleteBackgroundColor
            rf.BackgroundTransparency = 1
            rf.BorderSizePixel = 0
            rf.ZIndex = 101
            rf.Parent = self.AutocompleteScroll

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.ZIndex = 102
            btn.Parent = rf

            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.new(0, 14, 0, 14)
            icon.Position = UDim2.new(0, 6, 0.5, 0)
            icon.AnchorPoint = Vector2.new(0, 0.5)
            icon.BackgroundTransparency = 1
            icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
            icon.ZIndex = 102
            icon.Parent = rf

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -26, 1, 0)
            label.Position = UDim2.new(0, 24, 0, 0)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.RobotoMono
            label.TextSize = 13
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.ZIndex = 102
            label.Parent = rf

            row.Frame, row.Button, row.Icon, row.Label = rf, btn, icon, label
            rows[i] = row
            btn.MouseButton1Click:Connect(function()
                if self.Destroyed then return end
                self.AutocompleteIndex = i
                self:CommitAutocomplete()
            end)
        end
        local m = self.AutocompleteMatches[i]
        local sel = (i == self.AutocompleteIndex)
        row.Frame.BackgroundColor3 = sel and self.AutocompleteSelectionColor or self.AutocompleteBackgroundColor
        row.Frame.BackgroundTransparency = sel and 0 or 1
        row.Icon.Image = m.icon
        row.Label.Text = m.word
        row.Label.TextColor3 = sel and self.AutocompleteSelectedTextColor or self.AutocompleteTextColor
        row.Frame.Visible = true
        row.Frame.LayoutOrder = i
    end
    for i = needed + 1, #rows do rows[i].Frame.Visible = false end

    self.AutocompleteScroll.CanvasSize = UDim2.new(0, 0, 0, needed * ROW_H)
    local sp = self.AutocompleteScroll.CanvasPosition.Y
    local selTop = (self.AutocompleteIndex - 1) * ROW_H
    local selBot = selTop + ROW_H
    if selTop < sp then
        self.AutocompleteScroll.CanvasPosition = Vector2.new(0, selTop)
    elseif selBot > sp + self.AutocompleteScroll.AbsoluteWindowSize.Y then
        self.AutocompleteScroll.CanvasPosition = Vector2.new(0, selBot - self.AutocompleteScroll.AbsoluteWindowSize.Y)
    end
end

function LuaUEngine:CommitAutocomplete()
    if not self.AutocompleteVisible or #self.AutocompleteMatches == 0 then return false end
    local m = self.AutocompleteMatches[self.AutocompleteIndex]
    local text = self.CanvasGroup:GetAttribute("Text") or ""
    local word = Utils.getWordBeforeCursor(text, self.CursorIndex)
    local before = text:sub(1, self.CursorIndex - #word)
    local after = text:sub(self.CursorIndex + 1)
    self.CanvasGroup:SetAttribute("Text", before .. m.word .. after)
    self.CursorIndex = #before + #m.word
    self.SelectionStart = self.CursorIndex
    self:PushHistory()
    self:HideAutocomplete()
    self:UpdateBlinker(true)
    return true
end

function LuaUEngine:UpdateAutocompleteUI()
    if not self.IsFocused or self.SelectionStart ~= self.CursorIndex then
        self:HideAutocomplete()
        return
    end
    local text = self.CanvasGroup:GetAttribute("Text") or ""
    local word = Utils.getWordBeforeCursor(text, self.CursorIndex)
    if #word < 1 then self:HideAutocomplete(); return end

    local dynamic = {}
    local sStart = math.max(1, self.CursorIndex - 15000)
    local sEnd = math.min(#text, self.CursorIndex + 15000)
    local chunk = text:sub(sStart, sEnd)
    for name in chunk:gmatch("local%s+([%w_]+)") do dynamic[name] = "Variable" end
    for name in chunk:gmatch("function%s+([%w_]+)") do dynamic[name] = "Function" end
    for name in chunk:gmatch("([%w_]+)%s*=") do
        if not dynamic[name] then dynamic[name] = "Variable" end
    end

    local matches = {}
    local lower = word:lower()
    local added = {}
    local function add(w, t, icon)
        if added[w] then return end
        if w:lower():sub(1, #lower) == lower then
            matches[#matches + 1] = { word = w, type = t, icon = icon }
            added[w] = true
        end
    end
    for w, t in pairs(dynamic) do add(w, t, Icons.Variable) end
    local keywords = Utils.AutocompleteKeywords
    for i = 1, #keywords do
        local item = keywords[i]
        add(item.word, item.type, item.icon)
        if #matches >= CONST.AUTOC_MAX_ROWS then break end
    end
    if #matches == 0 then self:HideAutocomplete(); return end
    if #matches == 1 and matches[1].word == word then self:HideAutocomplete(); return end

    self.AutocompleteMatches = matches
    self.AutocompleteIndex = math.clamp(self.AutocompleteIndex, 1, #matches)
    self:RenderAutocomplete()
end

function LuaUEngine:ProcessKey(keyCode, isShiftDown, isCtrlDown)
    if self.AwaitingRelease then return end
    if self.SuppressedKeys[keyCode] then return end

    local readonly = self.CanvasGroup:GetAttribute("ReadOnly")
    if readonly or self.IsPasting then
        if keyCode ~= Enum.KeyCode.Left and keyCode ~= Enum.KeyCode.Right
            and keyCode ~= Enum.KeyCode.Up and keyCode ~= Enum.KeyCode.Down
            and keyCode ~= Enum.KeyCode.Home and keyCode ~= Enum.KeyCode.End
            and keyCode ~= Enum.KeyCode.PageUp and keyCode ~= Enum.KeyCode.PageDown then
            return
        end
    end

    local dispText = self:GetDisplayText()

    if self.AutocompleteVisible then
        local text = self.CanvasGroup:GetAttribute("Text") or ""
        local word = Utils.getWordBeforeCursor(text, self.CursorIndex)
        local match = self.AutocompleteMatches[self.AutocompleteIndex]
        if keyCode == Enum.KeyCode.Down then
            self.AutocompleteIndex = math.min(self.AutocompleteIndex + 1, #self.AutocompleteMatches)
            self:RenderAutocomplete(); return
        elseif keyCode == Enum.KeyCode.Up then
            self.AutocompleteIndex = math.max(self.AutocompleteIndex - 1, 1)
            self:RenderAutocomplete(); return
        elseif keyCode == Enum.KeyCode.Right then
            if self.GhostTextLabel.Visible and self:CommitAutocomplete() then return end
        elseif keyCode == Enum.KeyCode.Tab then
            if self:CommitAutocomplete() then return end
        elseif keyCode == Enum.KeyCode.Return or keyCode == Enum.KeyCode.KeypadEnter then
            if match and match.word == word then
                self:HideAutocomplete(); return
            elseif self:CommitAutocomplete() then
                return
            end
        elseif keyCode == Enum.KeyCode.Escape then
            self:HideAutocomplete(); return
        end
    end

    if keyCode == Enum.KeyCode.Tab then
        if self.CanvasGroup:GetAttribute("MultiLine") then
            if isShiftDown then
                local txt = self.CanvasGroup:GetAttribute("Text") or ""
                local before = txt:sub(1, self.CursorIndex)
                local after = txt:sub(self.CursorIndex + 1)
                local sp = before:match(" +( *)$")
                if sp then
                    local removeLen = math.min(4, #sp + 1)
                    self.CanvasGroup:SetAttribute("Text", before:sub(1, -(removeLen + 1)) .. after)
                    self.CursorIndex = self.CursorIndex - removeLen
                    self.SelectionStart = self.CursorIndex
                    self:PushHistory()
                end
            else
                self:AppendText("    ")
            end
            self:UpdateBlinker(true)
        else
            local myTab = self.CanvasGroup:GetAttribute("TabIndex") or 0
            local nextInst, bestDist = nil, math.huge
            for i = 1, #Baseline.Instances do
                local inst = Baseline.Instances[i]
                local t = inst.CanvasGroup:GetAttribute("TabIndex") or 0
                if isShiftDown then
                    if t < myTab and (myTab - t) < bestDist then
                        bestDist = myTab - t; nextInst = inst
                    end
                elseif t > myTab and (t - myTab) < bestDist then
                    bestDist = t - myTab; nextInst = inst
                end
            end
            if nextInst then self:Unfocus(); nextInst:Focus() end
        end
        return
    elseif keyCode == Enum.KeyCode.Backspace then
        self:RemoveChar()
    elseif keyCode == Enum.KeyCode.Return or keyCode == Enum.KeyCode.KeypadEnter then
        if self.CanvasGroup:GetAttribute("MultiLine") then
            self.LastTypedChar = "\n"
            self.LastTypedTick = tick()
            if self.SelectionStart ~= self.CursorIndex then self:DeleteSelection() end
            local txt = self.CanvasGroup:GetAttribute("Text") or ""
            local before = txt:sub(1, self.CursorIndex)
            local after = txt:sub(self.CursorIndex + 1)
            local lineBefore = before:match("[^\n]*$") or ""
            local indent = lineBefore:match("^([ \t]*)") or ""
            local prevWord = lineBefore:match("([%w_]+)%s*$")
            local needsEnd = prevWord == "then" or prevWord == "do" or prevWord == "repeat" or prevWord == "function"
            if needsEnd or lineBefore:match("function%s*.*%(.*%)%s*$") or lineBefore:match("^%s*do%s*$") then
                local ins = "\n" .. indent .. "    \n" .. indent .. "end"
                self.CanvasGroup:SetAttribute("Text", before .. ins .. after)
                self.CursorIndex = self.CursorIndex + 1 + #indent + 4
            elseif (lineBefore:match("%{%s*$") and after:sub(1, 1) == "}")
                or (lineBefore:match("%(%s*$") and after:sub(1, 1) == ")")
                or (lineBefore:match("%[%s*$") and after:sub(1, 1) == "]") then
                local ins = "\n" .. indent .. "    \n" .. indent
                self.CanvasGroup:SetAttribute("Text", before .. ins .. after)
                self.CursorIndex = self.CursorIndex + 1 + #indent + 4
            elseif lineBefore:match("%{%s*$") or lineBefore:match("%(%s*$") or lineBefore:match("%[%s*$") then
                local ins = "\n" .. indent .. "    "
                self.CanvasGroup:SetAttribute("Text", before .. ins .. after)
                self.CursorIndex = self.CursorIndex + #ins
            else
                local ins = "\n" .. indent
                self.CanvasGroup:SetAttribute("Text", before .. ins .. after)
                self.CursorIndex = self.CursorIndex + #ins
            end
            self.SelectionStart = self.CursorIndex
            self:PushHistory()
            self:UpdateBlinker(true)
            self:UpdateAutocompleteUI()
        end
    elseif keyCode == Enum.KeyCode.Left then
        if isCtrlDown then
            self.CursorIndex = Utils.getPrevWordBoundary(dispText, self.CursorIndex)
        elseif self.SelectionStart ~= self.CursorIndex and not isShiftDown then
            self.CursorIndex = math.min(self.SelectionStart, self.CursorIndex)
        else
            local off = utf8.offset(dispText, -1, self.CursorIndex + 1)
            if off then self.CursorIndex = off - 1 end
        end
        if not isShiftDown then self.SelectionStart = self.CursorIndex end
        self:HideAutocomplete()
        self:UpdateBlinker(true)
    elseif keyCode == Enum.KeyCode.Right then
        if isCtrlDown then
            self.CursorIndex = Utils.getNextWordBoundary(dispText, self.CursorIndex)
        elseif self.SelectionStart ~= self.CursorIndex and not isShiftDown then
            self.CursorIndex = math.max(self.SelectionStart, self.CursorIndex)
        elseif self.CursorIndex < #dispText then
            local off = utf8.offset(dispText, 2, self.CursorIndex + 1)
            self.CursorIndex = off and (off - 1) or #dispText
        end
        if not isShiftDown then self.SelectionStart = self.CursorIndex end
        self:HideAutocomplete()
        self:UpdateBlinker(true)
    elseif keyCode == Enum.KeyCode.Up then
        local font = self.CanvasGroup:GetAttribute("Font")
        local ts = self.CanvasGroup:GetAttribute("TextSize")
        local lm = self:GetLineMapCached(dispText, ts, font, self:GetLimit())
        local idx = 1
        for i = 1, #lm do
            if self.CursorIndex >= (lm[i].startIdx - 1) and self.CursorIndex <= lm[i].endIdx then
                idx = i; break
            end
        end
        if idx > 1 then
            local prev = lm[idx - 1]
            local rEnd = prev.renderEndIdx or prev.endIdx
            local sub = (prev.startIdx <= self.CursorIndex) and dispText:sub(prev.startIdx, math.min(self.CursorIndex, rEnd)) or ""
            local l = utf8.len(sub) or #sub
            local cw = Utils.getTextSize("A", ts, font, Vector2.new(10000, 10000)).X
            self.CursorIndex = self:GetClosestIndexInLine(prev, l * cw, dispText, ts, font)
        else
            self.CursorIndex = 0
        end
        if not isShiftDown then self.SelectionStart = self.CursorIndex end
        self:HideAutocomplete()
        self:UpdateBlinker(true)
    elseif keyCode == Enum.KeyCode.Down then
        local font = self.CanvasGroup:GetAttribute("Font")
        local ts = self.CanvasGroup:GetAttribute("TextSize")
        local lm = self:GetLineMapCached(dispText, ts, font, self:GetLimit())
        local idx = 1
        for i = 1, #lm do
            if self.CursorIndex >= (lm[i].startIdx - 1) and self.CursorIndex <= lm[i].endIdx then
                idx = i; break
            end
        end
        if idx < #lm then
            local nxt = lm[idx + 1]
            local cur = lm[idx]
            local rEnd = cur.renderEndIdx or cur.endIdx
            local sub = (cur.startIdx <= self.CursorIndex) and dispText:sub(cur.startIdx, math.min(self.CursorIndex, rEnd)) or ""
            local l = utf8.len(sub) or #sub
            local cw = Utils.getTextSize("A", ts, font, Vector2.new(10000, 10000)).X
            self.CursorIndex = self:GetClosestIndexInLine(nxt, l * cw, dispText, ts, font)
        else
            self.CursorIndex = #dispText
        end
        if not isShiftDown then self.SelectionStart = self.CursorIndex end
        self:HideAutocomplete()
        self:UpdateBlinker(true)
    elseif keyCode == Enum.KeyCode.Home then
        if isCtrlDown then
            self.CursorIndex = 0
        else
            local font = self.CanvasGroup:GetAttribute("Font")
            local ts = self.CanvasGroup:GetAttribute("TextSize")
            local lm = self:GetLineMapCached(dispText, ts, font, self:GetLimit())
            for i = 1, #lm do
                if self.CursorIndex >= (lm[i].startIdx - 1) and self.CursorIndex <= lm[i].endIdx then
                    self.CursorIndex = lm[i].startIdx - 1
                    break
                end
            end
        end
        if not isShiftDown then self.SelectionStart = self.CursorIndex end
        self:HideAutocomplete()
        self:UpdateBlinker(true)
    elseif keyCode == Enum.KeyCode.End then
        if isCtrlDown then
            self.CursorIndex = #dispText
        else
            local font = self.CanvasGroup:GetAttribute("Font")
            local ts = self.CanvasGroup:GetAttribute("TextSize")
            local lm = self:GetLineMapCached(dispText, ts, font, self:GetLimit())
            for i = 1, #lm do
                if self.CursorIndex >= (lm[i].startIdx - 1) and self.CursorIndex <= lm[i].endIdx then
                    self.CursorIndex = lm[i].renderEndIdx or lm[i].endIdx
                    break
                end
            end
        end
        if not isShiftDown then self.SelectionStart = self.CursorIndex end
        self:HideAutocomplete()
        self:UpdateBlinker(true)
    elseif keyCode == Enum.KeyCode.PageUp or keyCode == Enum.KeyCode.PageDown then
        local font = self.CanvasGroup:GetAttribute("Font")
        local ts = self.CanvasGroup:GetAttribute("TextSize")
        local lm = self:GetLineMapCached(dispText, ts, font, self:GetLimit())
        local vis = math.max(1, math.floor(self.CanvasGroup.AbsoluteSize.Y / (lm[1] and lm[1].height or 14)))
        local idx = 1
        for i = 1, #lm do
            if self.CursorIndex >= (lm[i].startIdx - 1) and self.CursorIndex <= lm[i].endIdx then
                idx = i; break
            end
        end
        local tgt = (keyCode == Enum.KeyCode.PageUp) and math.max(1, idx - vis) or math.min(#lm, idx + vis)
        self.CursorIndex = lm[tgt].renderEndIdx or lm[tgt].endIdx
        if not isShiftDown then self.SelectionStart = self.CursorIndex end
        self:HideAutocomplete()
        self:UpdateBlinker(true)
    else
        local mapped = Utils.getCharacter(keyCode, isShiftDown)
        if mapped ~= "" then
            self.LastTypedChar = mapped
            self.LastTypedTick = tick()
            self:AppendText(mapped)
        end
    end
end

function LuaUEngine:DeleteSelection()
    if self.SelectionStart == self.CursorIndex then return false end
    local s = math.min(self.SelectionStart, self.CursorIndex)
    local e = math.max(self.SelectionStart, self.CursorIndex)
    local txt = self.CanvasGroup:GetAttribute("Text") or ""
    self.CursorIndex = s
    self.SelectionStart = s
    self.CanvasGroup:SetAttribute("Text", txt:sub(1, s) .. txt:sub(e + 1))
    self:PushHistory()
    return true
end

function LuaUEngine:AppendText(character)
    if character == "\t" then character = "    " end
    local maxLen = self.CanvasGroup:GetAttribute("MaxLength")
    if maxLen and maxLen > 0 then
        local cur = self.CanvasGroup:GetAttribute("Text") or ""
        local curLen = utf8.len(cur) or 0
        local minI = math.min(self.SelectionStart, self.CursorIndex)
        local maxI = math.max(self.SelectionStart, self.CursorIndex)
        local selLen = utf8.len(cur:sub(minI + 1, maxI)) or 0
        if (curLen - selLen) + (utf8.len(character) or 0) > maxLen then return end
    end
    if self.SelectionStart ~= self.CursorIndex then self:DeleteSelection() end

    local txt = self.CanvasGroup:GetAttribute("Text") or ""
    local before = txt:sub(1, self.CursorIndex)
    local after = txt:sub(self.CursorIndex + 1)

    local pairsMap = { ["("] = ")", ["{"] = "}", ["["] = "]" }
    local quoteMap = { ['"'] = '"', ["'"] = "'", ["`"] = "`" }
    local closeSet = { [")"] = true, ["}"] = true, ["]"] = true }

    if (quoteMap[character] or closeSet[character]) and after:sub(1, 1) == character then
        self.CursorIndex = self.CursorIndex + 1
        self.SelectionStart = self.CursorIndex
        self:UpdateBlinker(true)
        self:UpdateAutocompleteUI()
        return
    elseif pairsMap[character] or quoteMap[character] then
        local closeChar = pairsMap[character] or quoteMap[character]
        self.CanvasGroup:SetAttribute("Text", before .. character .. closeChar .. after)
        self.CursorIndex = self.CursorIndex + 1
        self.SelectionStart = self.CursorIndex
        self:PushHistory()
        self:UpdateBlinker(true)
        self:UpdateAutocompleteUI()
        return
    end

    self.CursorIndex = self.CursorIndex + #character
    self.SelectionStart = self.CursorIndex
    local result = before .. character .. after
    self.CanvasGroup:SetAttribute("Text", result)

    local line = result:sub(1, self.CursorIndex):match("[^\n]*$")
    if line and (line:match("^%s*end$") or line:match("^%s*until$")
        or line:match("^%s*else$") or line:match("^%s*elseif.*$")
        or line:match("^%s*%}$") or line:match("^%s*%]$") or line:match("^%s*%)?$")) then
        local sp = line:match("^(%s+)")
        if sp and #sp >= 4 then
            local removeLen = 4
            local b = result:sub(1, self.CursorIndex - #line)
            local un = line:sub(removeLen + 1)
            local a = result:sub(self.CursorIndex + 1)
            self.CanvasGroup:SetAttribute("Text", b .. un .. a)
            self.CursorIndex = self.CursorIndex - removeLen
            self.SelectionStart = self.CursorIndex
        end
    end
    self:PushHistory()
    self:UpdateAutocompleteUI()
end

function LuaUEngine:RemoveChar()
    if self.SelectionStart ~= self.CursorIndex then
        self:DeleteSelection()
        self:UpdateAutocompleteUI()
        return
    end
    local txt = self.CanvasGroup:GetAttribute("Text") or ""
    if self.CursorIndex > 0 then
        local before = txt:sub(1, self.CursorIndex)
        local after = txt:sub(self.CursorIndex + 1)
        local prev = before:sub(-1)
        local nxt = after:sub(1, 1)
        local pairsMap = { ["("] = ")", ["{"] = "}", ["["] = "]" }
        local quoteMap = { ['"'] = '"', ["'"] = "'", ["`"] = "`" }
        if pairsMap[prev] == nxt or (quoteMap[prev] and quoteMap[prev] == nxt) then
            after = after:sub(2)
        end
        local off = utf8.offset(before, -1)
        if off then
            before = before:sub(1, off - 1)
            self.CursorIndex = #before
            self.SelectionStart = self.CursorIndex
            self.CanvasGroup:SetAttribute("Text", before .. after)
            self:PushHistory()
        end
    end
    self:UpdateAutocompleteUI()
end

function LuaUEngine:GetLimit()
    local wrapped = self.CanvasGroup:GetAttribute("Wrapped") or false
    local margin = 0
    if self.CanvasGroup:GetAttribute("Lines") then
        local font = self.CanvasGroup:GetAttribute("Font") or Enum.Font.Code
        local ts = self.CanvasGroup:GetAttribute("TextSize") or 16
        local count = self.CachedLineMap and #self.CachedLineMap or 1000
        local cw = Utils.getTextSize("A", ts, font, Vector2.new(10000, 10000)).X
        local nw = #(tostring(count)) * cw
        margin = math.max(35, nw + 28)
    end
    local maxW = (self.CanvasGroup.AbsoluteSize.X - 8) - margin
    return wrapped and Vector2.new(math.max(10, maxW), 10000) or Vector2.new(10000, 10000)
end

function LuaUEngine:GetLineMapCached(text, ts, font, limit)
    if self.CachedText == text and self.CachedTextSize == ts
        and self.CachedFont == font
        and self.CachedLimitX == limit.X
        and self.CachedLimitY == limit.Y then
        return self.CachedLineMap
    end
    self.CachedText = text
    self.CachedTextSize = ts
    self.CachedFont = font
    self.CachedLimitX = limit.X
    self.CachedLimitY = limit.Y
    self.CachedLineMap = self:GetLineMap(text, ts, font, limit)
    return self.CachedLineMap
end

function LuaUEngine:GetLineMap(text, ts, font, limit)
    local pLines = {}
    local idx = 1
    local len = #text
    while idx <= len do
        local nl = text:find("\n", idx, true)
        local e = nl and (nl - 1) or len
        pLines[#pLines + 1] = { text = text:sub(idx, e), startIdx = idx, endIdx = e }
        idx = nl and (nl + 1) or (len + 1)
    end
    if text:sub(-1) == "\n" then
        pLines[#pLines + 1] = { text = "", startIdx = len + 1, endIdx = len }
    end

    local stack = {}
    local foldPairs = {}
    for i = 1, #pLines do
        local delta = Utils.getBlockDelta(pLines[i].text)
        if delta > 0 then
            for _ = 1, delta do stack[#stack + 1] = i end
        elseif delta < 0 then
            for _ = 1, -delta do
                if #stack > 0 then
                    local si = table.remove(stack)
                    if si < i then foldPairs[si] = i end
                end
            end
        end
    end
    self.CurrentFoldPairs = foldPairs

    local defaultH = Utils.getTextSize("A", ts, font, Vector2.new(10000, 10000)).Y + 4
    if text == "" then
        self.CachedDocumentWidth = 8
        return { { startIdx = 1, endIdx = 0, y = 0, height = defaultH, lineNumber = 1 } }
    end

    local segments = {}
    local y = 0
    local wrapped = limit.X < 10000
    local i = 1
    while i <= #pLines do
        local p = pLines[i]
        local isFolded = self.FoldedLines[i] and foldPairs[i]
        if isFolded then
            local ep = pLines[foldPairs[i]]
            segments[#segments + 1] = {
                startIdx = p.startIdx,
                endIdx = ep.startIdx - 1,
                renderEndIdx = p.endIdx,
                y = y,
                height = defaultH,
                lineNumber = i,
                isFolded = true,
            }
            y = y + defaultH
            i = foldPairs[i]
        else
            if not wrapped then
                segments[#segments + 1] = {
                    startIdx = p.startIdx,
                    endIdx = p.endIdx,
                    y = y, height = defaultH, lineNumber = i,
                }
                y = y + defaultH
            else
                local cs = p.startIdx
                local firstWrap = true
                if cs > p.endIdx then
                    segments[#segments + 1] = {
                        startIdx = cs, endIdx = p.endIdx,
                        y = y, height = defaultH, lineNumber = i,
                    }
                    y = y + defaultH
                else
                    while cs <= p.endIdx do
                        local seg = Utils.getTextSize(text:sub(cs, p.endIdx), ts, font, limit)
                        if seg.Y <= defaultH then
                            segments[#segments + 1] = {
                                startIdx = cs, endIdx = p.endIdx,
                                y = y, height = defaultH,
                                lineNumber = firstWrap and i or nil,
                            }
                            y = y + defaultH
                            break
                        else
                            local wi = Utils.findWrapPoint(text, cs, p.endIdx, ts, font, limit, defaultH)
                            if wi < cs then wi = cs end
                            segments[#segments + 1] = {
                                startIdx = cs, endIdx = wi,
                                y = y, height = defaultH,
                                lineNumber = firstWrap and i or nil,
                            }
                            y = y + defaultH
                            cs = wi + 1
                            firstWrap = false
                        end
                    end
                end
            end
            i = i + 1
        end
    end

    if not wrapped then
        local maxW = 8
        local cw = Utils.getTextSize("A", ts, font, Vector2.new(10000, 10000)).X
        for k = 1, #segments do
            local seg = segments[k]
            local rEnd = seg.renderEndIdx or seg.endIdx
            local s = (seg.startIdx <= rEnd) and text:sub(seg.startIdx, rEnd) or ""
            if seg.isFolded then
                local ind = s:match("^%s*") or ""
                s = s .. "\n" .. ind .. "    ..."
            end
            local maxLine = 0
            for line in string.gmatch(s .. "\n", "(.-)\n") do
                if #line > maxLine then maxLine = #line end
            end
            local w = maxLine * cw
            if w > maxW then maxW = w end
        end
        self.CachedDocumentWidth = maxW + 8
    else
        self.CachedDocumentWidth = limit.X
    end
    return segments
end

function LuaUEngine:GetClosestIndexInLine(lineData, targetX, text, ts, font)
    if targetX < 0 then targetX = 0 end
    local cw = Utils.getTextSize("A", ts, font, Vector2.new(10000, 10000)).X
    if cw <= 0 then cw = 8 end
    local rEnd = lineData.renderEndIdx or lineData.endIdx
    local lineStr = text:sub(lineData.startIdx, rEnd)
    local lineLen = utf8.len(lineStr) or #lineStr
    local clicked = math.floor((targetX / cw) + 0.5)
    if clicked < 0 then clicked = 0 end
    if clicked > lineLen then clicked = lineLen end
    local off = utf8.offset(lineStr, clicked + 1)
    if off then
        return lineData.startIdx - 1 + off - 1
    end
    return rEnd
end

function LuaUEngine:GetClosestCursorIndex(clickX, clickY)
    local text = self:GetDisplayText()
    if text == "" then return 0 end
    local font = self.CanvasGroup:GetAttribute("Font") or Enum.Font.Code
    local ts = self.CanvasGroup:GetAttribute("TextSize") or 16
    local lm = self:GetLineMapCached(text, ts, font, self:GetLimit())
    if #lm == 0 then return 0 end
    local opt = lm[1]
    local minD = math.huge
    for i = 1, #lm do
        local line = lm[i]
        local cy = line.y + (line.height / 2)
        local d = math.abs(cy - clickY)
        if d < minD then minD = d; opt = line end
    end
    return self:GetClosestIndexInLine(opt, clickX, text, ts, font)
end

function LuaUEngine:UpdateBlinker(autoScroll)
    if self.Destroyed then return end
    if autoScroll == nil then autoScroll = true end

    local rawText = self.CanvasGroup:GetAttribute("Text") or ""
    local dispText = self:GetDisplayText()
    local font = self.CanvasGroup:GetAttribute("Font") or Enum.Font.Code
    local ts = self.CanvasGroup:GetAttribute("TextSize") or 16
    local hlColor = self.CanvasGroup:GetAttribute("HighlightColor") or Color3.fromRGB(19, 35, 93)
    local textColor = self.CanvasGroup:GetAttribute("TextColor3") or Color3.new(1, 1, 1)
    local lineNumColor = self.CanvasGroup:GetAttribute("LineNumberColor3") or Color3.fromRGB(130, 130, 130)
    local hasLines = self.CanvasGroup:GetAttribute("Lines") or false
    local hasMinimap = self.CanvasGroup:GetAttribute("Minimap") ~= false
    local guideColor = self.CanvasGroup:GetAttribute("IndentGuideColor3") or Color3.fromRGB(58, 58, 58)
    local guideTrans = self.CanvasGroup:GetAttribute("IndentGuideTransparency")
    if guideTrans == nil then guideTrans = 0.35 end
    local guideThickness = self.CanvasGroup:GetAttribute("IndentGuideThickness") or 1

    if self.CursorIndex > #dispText then self.CursorIndex = #dispText end
    if self.CursorIndex < 0 then self.CursorIndex = 0 end
    if self.SelectionStart > #dispText then self.SelectionStart = #dispText end
    if self.SelectionStart < 0 then self.SelectionStart = 0 end

    self.PlaceholderLabel.TextSize = ts
    self.PlaceholderLabel.Font = font
    self.PlaceholderLabel.Visible = rawText == ""
    self:ApplyStrokeToLabel(self.PlaceholderLabel)

    self.GhostTextLabel.TextSize = ts
    self.GhostTextLabel.Font = font
    self:ApplyStrokeToLabel(self.GhostTextLabel)

    local lineNumMargin = 0
    if hasLines then
        local count = self.CachedLineMap and #self.CachedLineMap or 1000
        local cw = Utils.getTextSize("A", ts, font, Vector2.new(10000, 10000)).X
        local nw = #(tostring(count)) * cw
        lineNumMargin = math.max(35, nw + 28)
    end
    local scrollbarW = (self.VScrollBar and self.VScrollBar.BarFrame.Visible) and CONST.SCROLLBAR_SIZE or 0
    local minimapMargin = hasMinimap and 60 or 0

    self.LineNumbersContainer.Visible = hasLines
    self.LineNumbersContainer.Size = UDim2.new(0, lineNumMargin, 1, 0)
    self.LineNumbersContainer.Position = UDim2.new(0, 0, 0, 0)

    self.MinimapContainer.Visible = hasMinimap
    self.MinimapContainer.Size = UDim2.new(0, minimapMargin, 1, 0)
    self.MinimapContainer.Position = UDim2.new(1, -(minimapMargin + scrollbarW), 0, 0)

    self.TextContainer.Size = UDim2.new(1, -(lineNumMargin + minimapMargin + scrollbarW), 1, 0)
    self.TextContainer.Position = UDim2.new(0, lineNumMargin, 0, 0)

    local limit = self:GetLimit()
    local lm = self:GetLineMapCached(dispText, ts, font, limit)
    local defaultH = lm[1] and lm[1].height or 14
    local lastLine = lm[#lm]
    self.DocumentHeight = (lastLine and (lastLine.y + lastLine.height) or defaultH) + 22

    if self.CanvasGroup:GetAttribute("AutoHeight") then
        local th = self.DocumentHeight + 8
        if self.CanvasGroup.Size.Y.Offset ~= th then
            self.CanvasGroup.Size = UDim2.new(self.CanvasGroup.Size.X.Scale, self.CanvasGroup.Size.X.Offset, 0, th)
        end
    end

    local curX, curY = 0, 0
    local curH = defaultH
    local activeLine = 1
    local lastSeenLine = 1
    if dispText ~= "" then
        for k = 1, #lm do
            local line = lm[k]
            if line.lineNumber then lastSeenLine = line.lineNumber end
            if self.CursorIndex >= (line.startIdx - 1) and self.CursorIndex <= line.endIdx then
                activeLine = lastSeenLine
                local rEnd = line.renderEndIdx or line.endIdx
                local sub = (line.startIdx <= self.CursorIndex) and dispText:sub(line.startIdx, math.min(self.CursorIndex, rEnd)) or ""
                local cw = Utils.getTextSize("A", ts, font, Vector2.new(10000, 10000)).X
                local l = utf8.len(sub) or #sub
                curX = l * cw
                curY = line.y
                curH = line.height
                break
            end
        end
    end

    local viewportW = (self.CanvasGroup.AbsoluteSize.X - 8) - lineNumMargin - minimapMargin - scrollbarW
    local viewportH = self.CanvasGroup.AbsoluteSize.Y - 8
    local soX, soY = math.round(self.ScrollOffset.X), math.round(self.ScrollOffset.Y)
    local docW = self.CachedDocumentWidth or 0

    if autoScroll then
        if curX < soX then soX = curX end
        if curX > ((soX + viewportW) - 2) then soX = (curX - viewportW) + 2 end
        if curY < soY then soY = curY end
        if (curY + curH) > (soY + viewportH) then soY = (curY + curH) - viewportH end
    end
    local maxScrollY = math.max(0, self.DocumentHeight - self.CanvasGroup.AbsoluteSize.Y)
    soY = math.clamp(soY, 0, maxScrollY)
    local maxScrollX = math.max(0, docW - viewportW)
    soX = math.clamp(soX, 0, maxScrollX)
    self.ScrollOffset = Vector2.new(soX, soY)

    self.InnerFrame.Position = UDim2.new(0, -soX, 0, -soY)
    self.LineNumbersInner.Position = UDim2.new(0, 0, 0, -soY)

    if self.VScrollBar then
        self.VScrollBar:UpdateMetrics(self.CanvasGroup.AbsoluteSize.Y, self.DocumentHeight, soY)
    end
    if self.HScrollBar then
        self.HScrollBar:UpdateMetrics(viewportW + 8, docW, soX)
    end

    if hasLines and self.IsFocused then
        self.CurrentLineHighlight.Visible = true
        local targetPos = UDim2.new(0, 0, 0, (4 + curY) - soY)
        local targetSize = UDim2.new(1, 0, 0, curH)
        if self.CanvasGroup:GetAttribute("SmoothBlinker") then
            TweenService:Create(self.CurrentLineHighlight,
                TweenInfo.new(CONST.TWEEN_SMOOTH, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { Position = targetPos, Size = targetSize }):Play()
        else
            self.CurrentLineHighlight.Position = targetPos
            self.CurrentLineHighlight.Size = targetSize
        end
    else
        self.CurrentLineHighlight.Visible = false
    end

    local viewTop = soY
    local viewBot = soY + viewportH + 16
    local firstIdx, lastIdx = 1, #lm
    if #lm > 0 then
        local L, R = 1, #lm
        local bF = 1
        while L <= R do
            local M = math.floor((L + R) / 2)
            if (lm[M].y + lm[M].height) >= viewTop then bF = M; R = M - 1
            else L = M + 1 end
        end
        firstIdx = bF
        local bL = bF
        L, R = bF, #lm
        while L <= R do
            local M = math.floor((L + R) / 2)
            if lm[M].y <= viewBot then bL = M; L = M + 1
            else R = M - 1 end
        end
        lastIdx = bL
    end

    local bracketColor = Color3.fromRGB(80, 80, 80)
    if type(self.SyntaxRules) == "table" and self.SyntaxRules.SelectionBackgroundColor
        and self.SyntaxRules.SelectionBackgroundColor.color then
        bracketColor = self.SyntaxRules.SelectionBackgroundColor.color
    end

    local matchIdx1, matchIdx2
    if self.SelectionStart == self.CursorIndex and self.IsFocused then
        local cc = dispText:sub(self.CursorIndex, self.CursorIndex)
        local ci = self.CursorIndex
        if not cc:match("[%[%(%{%]%)%}]") then
            cc = dispText:sub(self.CursorIndex + 1, self.CursorIndex + 1)
            ci = self.CursorIndex + 1
        end
        if cc:match("[%[%(%{%]%)%}]") then
            local pairsFwd = { ["("] = ")", ["{"] = "}", ["["] = "]" }
            local pairsRev = { [")"] = "(", ["}"] = "{", ["]"] = "[" }
            local dir = pairsFwd[cc] and 1 or -1
            local target = pairsFwd[cc] or pairsRev[cc]
            local depth = 0
            local si = ci
            while si > 0 and si <= #dispText do
                local c = dispText:sub(si, si)
                if c == cc then depth = depth + 1
                elseif c == target then depth = depth - 1 end
                if depth == 0 then
                    matchIdx1 = ci; matchIdx2 = si
                    break
                end
                si = si + dir
            end
        end
    end

    local cw = Utils.getTextSize("A", ts, font, Vector2.new(10000, 10000)).X
    if cw <= 0 then cw = 8 end

    local syntaxState = "none"
    local processedUpTo = 1
    if #lm > 0 and firstIdx > 1 then
        local targetStart = lm[firstIdx].startIdx
        local startParse = math.max(1, targetStart - 10000)
        if startParse > 1 then
            local nl = dispText:find("\n", startParse, true)
            if nl and nl < targetStart then startParse = nl + 1 end
        end
        syntaxState = self:GetSyntaxStateAt(dispText, targetStart, startParse, "none")
        processedUpTo = targetStart
    end

    local visLines, visHighlights, visNums, visFolds, visGuides = 0, 0, 0, 0, 0
    local lastIndentLevel = 0

    local highlightLine
    do
        local highlightContainer = self.HighlightContainer
        local highlightPool = self.HighlightPool
        highlightLine = function(startIdx, endIdx, color, transparency, lineData)
            if endIdx < (lineData.startIdx - 1) or startIdx > lineData.endIdx then return end
            local rEnd = lineData.renderEndIdx or lineData.endIdx
            local hStart = math.max(lineData.startIdx, startIdx + 1)
            local hEnd = math.min(rEnd, endIdx)
            local offX, w = 0, 0
            if hStart <= hEnd then
                local sb = dispText:sub(lineData.startIdx, hStart - 1)
                local bl = utf8.len(sb) or #sb
                offX = bl * cw
                local su = dispText:sub(lineData.startIdx, hEnd)
                local tl = utf8.len(su) or #su
                w = (tl * cw) - offX
            else
                local sb = (lineData.startIdx <= rEnd) and dispText:sub(lineData.startIdx, rEnd) or ""
                local bl = utf8.len(sb) or #sb
                offX = bl * cw
            end
            if endIdx >= lineData.endIdx and lineData.endIdx ~= #dispText then
                if hStart > lineData.endIdx then
                    w = cw
                else
                    w = w + (lineData.isFolded and (4 * cw) or cw)
                end
            elseif lineData.isFolded and endIdx >= rEnd then
                w = w + (4 * cw)
            end
            if w <= 0 then return end
            visHighlights = visHighlights + 1
            local f = highlightPool[visHighlights]
            if not f then
                f = Instance.new("Frame")
                f.BorderSizePixel = 0
                f.ZIndex = 2
                f.Parent = highlightContainer
                highlightPool[visHighlights] = f
            end
            f.BackgroundColor3 = color
            f.BackgroundTransparency = transparency
            f.Position = UDim2.new(0, 4 + offX, 0, 4 + lineData.y)
            f.Size = UDim2.new(0, w, 0, lineData.height)
            f.Visible = true
        end
    end

    for i = firstIdx, lastIdx do
        local lineData = lm[i]
        if lineData then
            syntaxState = self:GetSyntaxStateAt(dispText, lineData.startIdx, processedUpTo, syntaxState)
            processedUpTo = lineData.startIdx
            visLines = visLines + 1

            local label = self.LinesPool[visLines]
            if not label then
                label = Instance.new("TextLabel")
                label.BackgroundTransparency = 1
                label.RichText = true
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.TextYAlignment = Enum.TextYAlignment.Top
                label.ZIndex = 3
                label.Parent = self.InnerFrame
                self.LinesPool[visLines] = label
            end

            local rEnd = lineData.renderEndIdx or lineData.endIdx
            local stringOnLine = (lineData.startIdx <= rEnd) and dispText:sub(lineData.startIdx, rEnd) or ""

            if lineData.lineNumber and not lineData.isFolded then
                local leading = stringOnLine:match("^([ \t]*)") or ""
                lastIndentLevel = math.floor(#leading / 4)
            end
            local effIndent = lineData.isFolded and 0 or lastIndentLevel
            for level = 0, effIndent - 1 do
                local gx = 4 + level * 4 * cw + 1
                visGuides = visGuides + 1
                local guide = self.IndentGuidesPool[visGuides]
                if not guide then
                    guide = Instance.new("Frame")
                    guide.Name = "IndentGuide"
                    guide.BorderSizePixel = 0
                    guide.ZIndex = 1
                    guide.Parent = self.IndentGuideContainer
                    self.IndentGuidesPool[visGuides] = guide
                end
                guide.BackgroundColor3 = guideColor
                guide.BackgroundTransparency = guideTrans
                guide.Position = UDim2.new(0, gx, 0, 4 + lineData.y)
                guide.Size = UDim2.new(0, guideThickness, 0, lineData.height)
                guide.Visible = true
            end

            local ghost = ""
            if self.AutocompleteVisible and self.IsFocused and #self.AutocompleteMatches > 0 then
                local m = self.AutocompleteMatches[self.AutocompleteIndex]
                if m then
                    local curWord = Utils.getWordBeforeCursor(dispText, self.CursorIndex)
                    local after = dispText:sub(self.CursorIndex + 1, self.CursorIndex + 1)
                    if curWord ~= ""
                        and m.word:lower():sub(1, #curWord) == curWord:lower()
                        and #m.word > #curWord
                        and (after == "" or after:match("[%s%p]")) then
                        if self.CursorIndex >= (lineData.startIdx - 1) and self.CursorIndex <= lineData.endIdx then
                            ghost = m.word:sub(#curWord + 1)
                            local cil = self.CursorIndex - lineData.startIdx + 1
                            stringOnLine = stringOnLine:sub(1, cil) .. string.rep(" ", #ghost) .. stringOnLine:sub(cil + 1)
                        end
                    end
                end
            end

            label.Font = font
            label.TextSize = ts
            label.TextColor3 = textColor
            local rich
            if ghost ~= "" then
                rich = self:ApplySyntax(stringOnLine, syntaxState)
            else
                rich = self:ApplySyntaxCached(lineData, stringOnLine, syntaxState)
            end
            if lineData.isFolded then
                rich = rich .. ' <font color="#888888">...</font>'
            end
            label.Text = rich
            label.Position = UDim2.new(0, 4, 0, 4 + lineData.y)
            label.Size = UDim2.new(0, 10000, 0, lineData.height)
            label.Visible = true
            self:ApplyStrokeToLabel(label)

            if hasLines and lineData.lineNumber then
                visNums = visNums + 1
                local numLabel = self.LineNumbersPool[visNums]
                if not numLabel then
                    numLabel = Instance.new("TextLabel")
                    numLabel.BackgroundTransparency = 1
                    numLabel.TextXAlignment = Enum.TextXAlignment.Right
                    numLabel.TextYAlignment = Enum.TextYAlignment.Top
                    numLabel.ZIndex = 3
                    numLabel.Parent = self.LineNumbersInner
                    self.LineNumbersPool[visNums] = numLabel
                end
                numLabel.Font = font
                numLabel.TextSize = ts
                if lineData.lineNumber == activeLine and self.IsFocused then
                    numLabel.TextColor3 = Color3.new(1, 1, 1)
                else
                    numLabel.TextColor3 = lineNumColor
                end
                numLabel.TextTransparency = 0
                numLabel.Text = tostring(lineData.lineNumber)
                numLabel.Position = UDim2.new(0, 0, 0, 4 + lineData.y)
                numLabel.Size = UDim2.new(1, -22, 0, defaultH)
                numLabel.Visible = true
                self:ApplyStrokeToLabel(numLabel)

                if self.CurrentFoldPairs and self.CurrentFoldPairs[lineData.lineNumber] then
                    visFolds = visFolds + 1
                    local fb = self.FoldButtonsPool[visFolds]
                    if not fb then
                        fb = Instance.new("ImageButton")
                        fb.BackgroundTransparency = 1
                        fb.Image = Icons.Fold
                        fb.Size = UDim2.new(0, 16, 0, 16)
                        fb.ZIndex = 12
                        fb.Parent = self.LineNumbersInner
                        fb.MouseEnter:Connect(function()
                            fb:SetAttribute("IsHovered", true)
                            if not self.Destroyed then self:UpdateBlinker(false) end
                        end)
                        fb.MouseLeave:Connect(function()
                            fb:SetAttribute("IsHovered", false)
                            if not self.Destroyed then self:UpdateBlinker(false) end
                        end)
                        fb.MouseButton1Click:Connect(function()
                            if self.Destroyed then return end
                            local ln = fb:GetAttribute("LineNumber")
                            if ln then
                                self.FoldedLines[ln] = not self.FoldedLines[ln]
                                self.CachedText = nil
                                self:UpdateBlinker(false)
                            end
                        end)
                        self.FoldButtonsPool[visFolds] = fb
                    end
                    fb:SetAttribute("LineNumber", lineData.lineNumber)
                    fb.ImageRectOffset = Vector2.new(144, 16)
                    fb.ImageRectSize = Vector2.new(16, 16)
                    fb.Rotation = self.FoldedLines[lineData.lineNumber] and 0 or 90
                    if fb:GetAttribute("IsHovered") or (lineData.lineNumber == activeLine and self.IsFocused) then
                        fb.ImageColor3 = Color3.new(1, 1, 1)
                    else
                        fb.ImageColor3 = lineNumColor
                    end
                    fb.Position = UDim2.new(1, -18, 0, 4 + lineData.y + (defaultH - 16) / 2)
                    fb.Visible = true
                end
            end

            if matchIdx1 and matchIdx1 >= lineData.startIdx and matchIdx1 <= (lineData.renderEndIdx or lineData.endIdx) then
                highlightLine(matchIdx1 - 1, matchIdx1, bracketColor, 0.4, lineData)
            end
            if matchIdx2 and matchIdx2 >= lineData.startIdx and matchIdx2 <= (lineData.renderEndIdx or lineData.endIdx) then
                highlightLine(matchIdx2 - 1, matchIdx2, bracketColor, 0.4, lineData)
            end

            local findMatches = self.FindMatches
            if findMatches and #findMatches > 0 then
                local findColor = Color3.fromRGB(151, 108, 0)
                if type(self.SyntaxRules) == "table" and self.SyntaxRules.FindSelectionBackgroundColor
                    and self.SyntaxRules.FindSelectionBackgroundColor.color then
                    findColor = self.SyntaxRules.FindSelectionBackgroundColor.color
                end
                for j = 1, #findMatches do
                    local m = findMatches[j]
                    if m.e >= (lineData.startIdx - 1) and m.s <= lineData.endIdx then
                        highlightLine(m.s, m.e, findColor, 0.6, lineData)
                    end
                end
            end

            if self.SelectionStart ~= self.CursorIndex then
                local selS = math.min(self.SelectionStart, self.CursorIndex)
                local selE = math.max(self.SelectionStart, self.CursorIndex)
                if selE >= (lineData.startIdx - 1) and selS <= lineData.endIdx then
                    highlightLine(selS, selE, hlColor, 0.4, lineData)
                end
            end
        end
    end

    for i = visLines + 1, #self.LinesPool do self.LinesPool[i].Visible = false end
    for i = visHighlights + 1, #self.HighlightPool do self.HighlightPool[i].Visible = false end
    for i = visFolds + 1, #self.FoldButtonsPool do self.FoldButtonsPool[i].Visible = false end
    for i = visGuides + 1, #self.IndentGuidesPool do self.IndentGuidesPool[i].Visible = false end
    if hasLines then
        for i = visNums + 1, #self.LineNumbersPool do self.LineNumbersPool[i].Visible = false end
    else
        for i = 1, #self.LineNumbersPool do self.LineNumbersPool[i].Visible = false end
    end

    if hasMinimap then
        local ratio = CONST.MINIMAP_DIV / ts
        local H_main = self.DocumentHeight
        local H_mini = H_main * ratio
        local V_main = self.CanvasGroup.AbsoluteSize.Y - 8
        local V_mini = self.MinimapContainer.AbsoluteSize.Y
        local S_main = soY
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

        local mStart = S_mini
        local mEnd = S_mini + V_mini + 10
        local mFirst, mLast = 1, #lm
        if #lm > 0 then
            local L, R = 1, #lm
            local bF = 1
            while L <= R do
                local M = math.floor((L + R) / 2)
                local my = lm[M].y * ratio
                local mh = lm[M].height * ratio
                if (my + mh) >= mStart then bF = M; R = M - 1
                else L = M + 1 end
            end
            mFirst = bF
            local bL = bF
            L, R = bF, #lm
            while L <= R do
                local M = math.floor((L + R) / 2)
                if lm[M].y * ratio <= mEnd then bL = M; L = M + 1
                else R = M - 1 end
            end
            mLast = bL
        end

        local mCount = 0
        local mState = "none"
        local mProcessed = 1
        if #lm > 0 and mFirst > 1 then
            local ts0 = lm[mFirst].startIdx
            local sp = math.max(1, ts0 - 10000)
            if sp > 1 then
                local nl = dispText:find("\n", sp, true)
                if nl and nl < ts0 then sp = nl + 1 end
            end
            mState = self:GetSyntaxStateAt(dispText, ts0, sp, "none")
            mProcessed = ts0
        end
        for i = mFirst, mLast do
            local lineData = lm[i]
            mState = self:GetSyntaxStateAt(dispText, lineData.startIdx, mProcessed, mState)
            mProcessed = lineData.startIdx
            mCount = mCount + 1
            local ml = self.MinimapLinesPool[mCount]
            if not ml then
                ml = Instance.new("TextLabel")
                ml.BackgroundTransparency = 1
                ml.RichText = true
                ml.TextXAlignment = Enum.TextXAlignment.Left
                ml.TextYAlignment = Enum.TextYAlignment.Top
                ml.ZIndex = 2
                ml.Parent = self.MinimapInner
                self.MinimapLinesPool[mCount] = ml
            end
            local rEnd = lineData.renderEndIdx or lineData.endIdx
            local s = (lineData.startIdx <= rEnd) and dispText:sub(lineData.startIdx, rEnd) or ""
            ml.Font = font
            ml.TextSize = 3
            ml.TextColor3 = textColor
            local rich = self:ApplySyntaxCached(lineData, s, mState)
            if lineData.isFolded then
                local ind = s:match("^%s*") or ""
                rich = rich .. '\n' .. ind .. '    <font color="#888888">...</font>'
            end
            ml.Text = rich
            ml.Position = UDim2.new(0, 0, 0, lineData.y * ratio)
            ml.Size = UDim2.new(1, 0, 0, lineData.height * ratio)
            ml.Visible = true
        end
        for i = mCount + 1, #self.MinimapLinesPool do
            self.MinimapLinesPool[i].Visible = false
        end
    end

    local targetPos = UDim2.new(0, 4 + curX, 0, 4 + curY)
    local targetSize = UDim2.new(0, 1, 0, curH)
    if self.CanvasGroup:GetAttribute("SmoothBlinker") then
        TweenService:Create(self.Blinker, TweenInfo.new(CONST.TWEEN_BLINK, Enum.EasingStyle.Linear),
            { Position = targetPos, Size = targetSize }):Play()
    else
        self.Blinker.Position = targetPos
        self.Blinker.Size = targetSize
    end
    self.BlinkTimer = 0
    if self.IsFocused then
        self.Blinker.Visible = self.SelectionStart == self.CursorIndex
    end

    if self.AutocompleteVisible and #self.AutocompleteMatches > 0 then
        local absX = (4 + curX) - soX
        local absY = (4 + curY + curH) - soY + 4
        local dynamicHeight = math.min(#self.AutocompleteMatches * CONST.AUTOC_ROW_H + 2, CONST.AUTOC_MAX_H)
        local panelWidth = 240
        self.AutocompleteUI.Size = UDim2.new(0, panelWidth, 0, dynamicHeight)
        if absY + dynamicHeight > self.CanvasGroup.AbsoluteSize.Y then
            absY = (4 + curY) - soY - dynamicHeight - 4
        end
        self.AutocompleteUI.Position = UDim2.new(0, lineNumMargin + absX, 0, absY)
        local m = self.AutocompleteMatches[self.AutocompleteIndex]
        if m then
            self.AutocompleteHintText.Text = m.type
            local bounds = Utils.getTextSize(m.type, 12, Enum.Font.Code, Vector2.new(1000, 22))
            self.AutocompleteHint.Size = UDim2.new(0, bounds.X + 14, 0, 22)
            local rowRelY = (self.AutocompleteIndex - 1) * CONST.AUTOC_ROW_H - self.AutocompleteScroll.CanvasPosition.Y
            self.AutocompleteHint.Position = UDim2.new(1, 6, 0, rowRelY + 1)
            self.AutocompleteHint.Visible = true

            local curWord = Utils.getWordBeforeCursor(dispText, self.CursorIndex)
            local after = dispText:sub(self.CursorIndex + 1, self.CursorIndex + 1)
            if curWord ~= ""
                and m.word:lower():sub(1, #curWord) == curWord:lower()
                and #m.word > #curWord
                and (after == "" or after:match("[%s%p]")) then
                self.GhostTextLabel.Text = m.word:sub(#curWord + 1)
                self.GhostTextLabel.Position = UDim2.new(0, 4 + curX, 0, 4 + curY)
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

function LuaUEngine:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true

    self:Unfocus()
    self:CloseFindUI()

    for i = 1, #self.Connections do self.Connections[i]:Disconnect() end
    table.clear(self.Connections)

    for i = #Baseline.Instances, 1, -1 do
        if Baseline.Instances[i] == self then
            table.remove(Baseline.Instances, i)
            break
        end
    end

    if self.VScrollBar then self.VScrollBar:Destroy(); self.VScrollBar = nil end
    if self.HScrollBar then self.HScrollBar:Destroy(); self.HScrollBar = nil end

    for _, pool in ipairs({
        self.LinesPool, self.HighlightPool, self.LineNumbersPool,
        self.MinimapLinesPool, self.FoldButtonsPool, self.IndentGuidesPool,
    }) do
        for i = 1, #pool do
            local inst = pool[i]
            if inst and inst.Destroy then inst:Destroy() end
        end
        table.clear(pool)
    end

    for i = 1, #self.AutocompleteRows do
        local row = self.AutocompleteRows[i]
        if row and row.Frame then row.Frame:Destroy() end
    end
    table.clear(self.AutocompleteRows)

    if self.CanvasGroup then
        self.CanvasGroup:ClearAllChildren()
    end
end

return LuaUEngine
