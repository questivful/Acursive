local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Slate = {}

local registry = getgenv()._SlateRegistry
if type(registry) ~= "table" then registry = {} end
registry.groups = type(registry.groups) == "table" and registry.groups or {}
registry.previews = type(registry.previews) == "table" and registry.previews or {}
registry.previewSlices = type(registry.previewSlices) == "table" and registry.previewSlices or {}
registry.activeDocks = type(registry.activeDocks) == "table" and registry.activeDocks or {}
if type(registry.zCounter) ~= "number" then registry.zCounter = 10 end
getgenv()._SlateRegistry = registry

local ICONS = {
	Close = "rbxassetid://83769040357829",
	Expand = "rbxassetid://129057205615084",
	DockRight = "rbxassetid://126120665892815",
	Minimize = "rbxassetid://102901485129507",
}

local COLORS = {
	Background = Color3.fromRGB(28, 28, 30),
	TopBar = Color3.fromRGB(24, 24, 26),
	Border = Color3.fromRGB(52, 52, 56),
	Shadow = Color3.fromRGB(0, 0, 0),
	Text = Color3.fromRGB(230, 230, 235),
	Muted = Color3.fromRGB(150, 150, 158),
	Resize = Color3.fromRGB(70, 70, 76),
	Preview = Color3.fromRGB(110, 110, 118),
	PreviewSlice = Color3.fromRGB(80, 80, 88),
	BevelRim = Color3.fromRGB(0, 0, 0),
	BevelEdge = Color3.fromRGB(35, 35, 35),
	BevelFade = Color3.fromRGB(25, 25, 25),
}

local MIN_W, MIN_H = 220, 140
local DEFAULT_W, DEFAULT_H = 420, 260
local TOPBAR_H = 22
local RESIZE_MARGIN = 5
local DOCK_THRESHOLD = 40
local PREVIEW_THICK = 160
local DOCKED_THICK = 320
local DOCKED_TOP_THICK = 220
local BEVEL_SIZE = 6
local BASE_DOCK_Z = 3
local PREVIEW_Z = 500

local function bringToFront(dock)
	registry.zCounter = registry.zCounter + 1
	if dock.frame then
		dock.frame.ZIndex = registry.zCounter
	end
end

local function ensureGui()
	if registry.gui and registry.gui.Parent then return registry.gui end
	local gui = Instance.new("ScreenGui")
	gui.Name = "Slate"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	pcall(function() gui.Parent = CoreGui end)
	if not gui.Parent then
		local pg = LocalPlayer:FindFirstChild("PlayerGui")
		if pg then gui.Parent = pg end
	end
	registry.gui = gui
	registry.previews = {}
	registry.previewSlices = {}
	registry.previewLayer = nil
	return gui
end

local function ensurePreviewLayer()
	local gui = ensureGui()
	if registry.previewLayer and registry.previewLayer.Parent == gui then
		return registry.previewLayer
	end

	local layer = Instance.new("Frame")
	layer.Name = "PreviewLayer"
	layer.Size = UDim2.new(1, 0, 1, 0)
	layer.BackgroundTransparency = 1
	layer.ZIndex = PREVIEW_Z
	layer.Parent = gui
	registry.previewLayer = layer
	registry.previews = {}

	local function makePreview(name, edge)
		local p = Instance.new("Frame")
		p.Name = "Preview_" .. name
		p.BackgroundColor3 = COLORS.Preview
		p.BorderSizePixel = 0
		p.BackgroundTransparency = 1
		p.Visible = false
		p.ZIndex = PREVIEW_Z + 1
		p.Parent = layer

		if edge == "Left" then
			p.Size = UDim2.new(0, PREVIEW_THICK, 1, 0)
			p.Position = UDim2.new(0, -PREVIEW_THICK, 0, 0)
			p:SetAttribute("Target", UDim2.new(0, 0, 0, 0))
			p:SetAttribute("Hidden", UDim2.new(0, -PREVIEW_THICK, 0, 0))
		elseif edge == "Right" then
			p.Size = UDim2.new(0, PREVIEW_THICK, 1, 0)
			p.Position = UDim2.new(1, PREVIEW_THICK, 0, 0)
			p:SetAttribute("Target", UDim2.new(1, -PREVIEW_THICK, 0, 0))
			p:SetAttribute("Hidden", UDim2.new(1, PREVIEW_THICK, 0, 0))
		elseif edge == "Top" then
			p.Size = UDim2.new(1, 0, 0, PREVIEW_THICK)
			p.Position = UDim2.new(0, 0, 0, -PREVIEW_THICK)
			p:SetAttribute("Target", UDim2.new(0, 0, 0, 0))
			p:SetAttribute("Hidden", UDim2.new(0, 0, 0, -PREVIEW_THICK))
		elseif edge == "Bottom" then
			p.Size = UDim2.new(1, 0, 0, PREVIEW_THICK)
			p.Position = UDim2.new(0, 0, 1, PREVIEW_THICK)
			p:SetAttribute("Target", UDim2.new(0, 0, 1, -PREVIEW_THICK))
			p:SetAttribute("Hidden", UDim2.new(0, 0, 1, PREVIEW_THICK))
		end

		local stroke = Instance.new("UIStroke")
		stroke.Color = COLORS.Preview
		stroke.Thickness = 2
		stroke.Transparency = 1
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = p

		p:SetAttribute("Edge", edge)
		registry.previews[edge] = p
		return p
	end

	makePreview("Left", "Left")
	makePreview("Right", "Right")
	makePreview("Top", "Top")
	makePreview("Bottom", "Bottom")
	return layer
end

local function clearSlices()
	for _, s in ipairs(registry.previewSlices) do
		pcall(function() s:Destroy() end)
	end
	registry.previewSlices = {}
end

local function getDocksOnEdge(edge)
	local list = {}
	for _, d in ipairs(registry.activeDocks) do
		if d and d.currentDockSide == edge then
			table.insert(list, d)
		end
	end
	return list
end

local function countDocksOnEdge(edge)
	return #getDocksOnEdge(edge)
end

local function reflowEdge(edge)
	local docks = getDocksOnEdge(edge)
	if #docks == 0 then return end
	table.sort(docks, function(a, b)
		return (a.sortKey or 0) < (b.sortKey or 0)
	end)
	local vp = Camera.ViewportSize
	local count = #docks
	local T = TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

	if edge == "Left" then
		local eachH = vp.Y / count
		for i, d in ipairs(docks) do
			TweenService:Create(d.frame, T, {
				Position = UDim2.fromOffset(0, (i - 1) * eachH),
				Size = UDim2.fromOffset(DOCKED_THICK, eachH),
			}):Play()
			d.expandedHeight = eachH
		end
	elseif edge == "Right" then
		local eachH = vp.Y / count
		for i, d in ipairs(docks) do
			TweenService:Create(d.frame, T, {
				Position = UDim2.fromOffset(vp.X - DOCKED_THICK, (i - 1) * eachH),
				Size = UDim2.fromOffset(DOCKED_THICK, eachH),
			}):Play()
			d.expandedHeight = eachH
		end
	elseif edge == "Top" then
		local eachW = vp.X / count
		for i, d in ipairs(docks) do
			TweenService:Create(d.frame, T, {
				Position = UDim2.fromOffset((i - 1) * eachW, 0),
				Size = UDim2.fromOffset(eachW, DOCKED_TOP_THICK),
			}):Play()
			d.expandedHeight = DOCKED_TOP_THICK
		end
	elseif edge == "Bottom" then
		local eachW = vp.X / count
		for i, d in ipairs(docks) do
			TweenService:Create(d.frame, T, {
				Position = UDim2.fromOffset((i - 1) * eachW, vp.Y - DOCKED_TOP_THICK),
				Size = UDim2.fromOffset(eachW, DOCKED_TOP_THICK),
			}):Play()
			d.expandedHeight = DOCKED_TOP_THICK
		end
	end
end

local function findSlotIndexForMouse(edge, mouseLoc)
	local docks = getDocksOnEdge(edge)
	table.sort(docks, function(a, b)
		return (a.sortKey or 0) < (b.sortKey or 0)
	end)
	local vp = Camera.ViewportSize
	local total = #docks + 1
	if edge == "Left" or edge == "Right" then
		local eachH = vp.Y / total
		local idx = math.floor(mouseLoc.Y / eachH) + 1
		return math.clamp(idx, 1, total)
	else
		local eachW = vp.X / total
		local idx = math.floor(mouseLoc.X / eachW) + 1
		return math.clamp(idx, 1, total)
	end
end

local function buildSlices(edge, count)
	clearSlices()
	local p = registry.previews[edge]
	if not p then return end
	local total = count + 1
	local isVertical = (edge == "Left" or edge == "Right")
	for i = 1, total do
		local slice = Instance.new("Frame")
		slice.BackgroundColor3 = COLORS.PreviewSlice
		slice.BackgroundTransparency = 0.6
		slice.BorderSizePixel = 0
		slice.ZIndex = PREVIEW_Z + 2
		slice.Parent = p
		if isVertical then
			slice.Size = UDim2.new(1, 0, 1 / total, -2)
			slice.Position = UDim2.new(0, 0, (i - 1) / total, 0)
		else
			slice.Size = UDim2.new(1 / total, -2, 1, 0)
			slice.Position = UDim2.new((i - 1) / total, 0, 0, 0)
		end
		local stroke = Instance.new("UIStroke")
		stroke.Color = COLORS.Preview
		stroke.Thickness = 1
		stroke.Transparency = 0.5
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = slice
		table.insert(registry.previewSlices, slice)
	end
end

local function showPreview(edgeName)
	ensurePreviewLayer()
	if registry.activePreview == edgeName then
		buildSlices(edgeName, countDocksOnEdge(edgeName))
		return
	end
	if registry.activePreview then
		local old = registry.previews[registry.activePreview]
		registry.activePreview = nil
		clearSlices()
		if old then
			local hidden = old:GetAttribute("Hidden")
			TweenService:Create(old, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1,
				Position = hidden,
			}):Play()
			local s = old:FindFirstChildOfClass("UIStroke")
			if s then TweenService:Create(s, TweenInfo.new(0.16), { Transparency = 1 }):Play() end
			task.delay(0.18, function()
				if old and old.Parent and registry.activePreview ~= old:GetAttribute("Edge") then
					old.Visible = false
				end
			end)
		end
	end
	if not edgeName then return end
	local p = registry.previews[edgeName]
	if not p then return end
	registry.activePreview = edgeName
	p.Visible = true
	local hidden = p:GetAttribute("Hidden")
	local target = p:GetAttribute("Target")
	p.Position = hidden
	p.BackgroundTransparency = 1
	local s = p:FindFirstChildOfClass("UIStroke")
	if s then s.Transparency = 1 end
	buildSlices(edgeName, countDocksOnEdge(edgeName))
	TweenService:Create(p, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.55,
		Position = target,
	}):Play()
	if s then
		TweenService:Create(s, TweenInfo.new(0.2), { Transparency = 0.25 }):Play()
	end
end

local function hidePreview()
	if not registry.activePreview then return end
	local old = registry.previews[registry.activePreview]
	registry.activePreview = nil
	clearSlices()
	if old then
		local hidden = old:GetAttribute("Hidden")
		TweenService:Create(old, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			BackgroundTransparency = 1,
			Position = hidden,
		}):Play()
		local s = old:FindFirstChildOfClass("UIStroke")
		if s then TweenService:Create(s, TweenInfo.new(0.16), { Transparency = 1 }):Play() end
		task.delay(0.18, function()
			if old and old.Parent and not registry.activePreview then
				old.Visible = false
			end
		end)
	end
end

function Slate.group(name)
	if not registry.groups[name] then
		registry.groups[name] = {
			name = name,
			docks = {},
			cleanups = {},
			version = 1,
		}
	end
	return registry.groups[name]
end

function Slate.clearGroup(name)
	local g = registry.groups[name]
	if not g then return end
	if type(g.cleanups) == "table" then
		for _, fn in ipairs(g.cleanups) do
			pcall(fn)
		end
	end
	if type(g.docks) == "table" then
		for _, d in ipairs(g.docks) do
			pcall(function() d:destroy() end)
		end
	end
	g.docks = {}
	g.cleanups = {}
	g.version = (g.version or 0) + 1
end

function Slate.listGroups()
	local out = {}
	if type(registry.groups) == "table" then
		for n in pairs(registry.groups) do
			table.insert(out, n)
		end
	end
	return out
end

function Slate.onCleanup(groupName, fn)
	local g = Slate.group(groupName)
	table.insert(g.cleanups, fn)
end

local function clamp(n, a, b)
	if n < a then return a end
	if n > b then return b end
	return n
end

local function evaluateZone(mouseLoc)
	local vp = Camera.ViewportSize
	local x = mouseLoc.X
	local y = mouseLoc.Y
	if x <= DOCK_THRESHOLD then return "Left" end
	if x >= vp.X - DOCK_THRESHOLD then return "Right" end
	if y <= DOCK_THRESHOLD + 36 then return "Top" end
	if y >= vp.Y - DOCK_THRESHOLD then return "Bottom" end
	return nil
end

local Dock = {}
Dock.__index = Dock

function Dock:destroy()
	if self.closing then return end
	self.closing = true

	for _, btn in ipairs(self.iconButtons) do
		btn.Active = false
		btn.AutoButtonColor = false
	end
	if self.topBar then self.topBar.Active = false end

	if not self.collapsed then
		self:setCollapsed(true)
	end

	task.wait(0.24)

	local fadeTime = 0.32
	TweenService:Create(self.frame, TweenInfo.new(fadeTime, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1,
	}):Play()
	TweenService:Create(self.topBar, TweenInfo.new(fadeTime, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1,
	}):Play()
	TweenService:Create(self.topBarShadow, TweenInfo.new(fadeTime), { BackgroundTransparency = 1 }):Play()
	TweenService:Create(self.border, TweenInfo.new(fadeTime), { Transparency = 1 }):Play()
	TweenService:Create(self.dockShadow, TweenInfo.new(fadeTime), { Transparency = 1 }):Play()
	TweenService:Create(self.title, TweenInfo.new(fadeTime), { TextTransparency = 1 }):Play()
	TweenService:Create(self.contentPlaceholder, TweenInfo.new(fadeTime), { TextTransparency = 1 }):Play()

	if type(self.bevels) == "table" then
		for _, b in pairs(self.bevels) do
			local rim = b:FindFirstChild("Rim")
			local edgeFrame = b:FindFirstChild("Edge")
			local fade = b:FindFirstChild("Fade")
			if rim then TweenService:Create(rim, TweenInfo.new(fadeTime), { BackgroundTransparency = 1 }):Play() end
			if edgeFrame then TweenService:Create(edgeFrame, TweenInfo.new(fadeTime), { BackgroundTransparency = 1 }):Play() end
			if fade then TweenService:Create(fade, TweenInfo.new(fadeTime), { BackgroundTransparency = 1 }):Play() end
		end
	end

	for _, img in ipairs(self.iconImages) do
		if img and img.Parent then
			TweenService:Create(img, TweenInfo.new(fadeTime), { ImageTransparency = 1 }):Play()
		end
	end

	if type(self.handles) == "table" then
		for _, h in pairs(self.handles) do
			pcall(function() h.Visible = false end)
		end
	end

	task.wait(fadeTime + 0.05)

	if type(self.connections) == "table" then
		for _, c in ipairs(self.connections) do
			pcall(function() c:Disconnect() end)
		end
	end
	self.connections = {}

	local oldEdge = self.currentDockSide
	if self.registeredEntry then
		for i, e in ipairs(registry.activeDocks) do
			if e == self then
				table.remove(registry.activeDocks, i)
				break
			end
		end
		self.registeredEntry = nil
	end
	self.currentDockSide = nil

	if oldEdge then
		reflowEdge(oldEdge)
	end

	pcall(function() self.frame:Destroy() end)
end

function Dock:setCollapsed(state)
	self.collapsed = state
	local targetH
	if state then
		self.expandedHeight = self.frame.Size.Y.Offset
		targetH = TOPBAR_H
		self.content.Visible = false
		self.minimizeImg.Image = ICONS.Expand
	else
		targetH = math.max(self.expandedHeight, MIN_H)
		self.content.Visible = true
		self.minimizeImg.Image = ICONS.Minimize
	end
	TweenService:Create(self.frame, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.new(self.frame.Size.X.Scale, self.frame.Size.X.Offset, 0, targetH),
	}):Play()
end

function Dock:updateHandleVisibility()
	if type(self.handles) ~= "table" then return end
	local hideMap = {}
	if self.currentDockSide == "Left" then
		hideMap = { W = true, NW = true, SW = true }
	elseif self.currentDockSide == "Right" then
		hideMap = { E = true, NE = true, SE = true }
	elseif self.currentDockSide == "Top" then
		hideMap = { N = true, NW = true, NE = true }
	elseif self.currentDockSide == "Bottom" then
		hideMap = { S = true, SW = true, SE = true }
	end
	for _, name in ipairs({ "N", "S", "E", "W", "NW", "NE", "SW", "SE" }) do
		local h = self.handles[name]
		if h then h.Visible = not hideMap[name] end
	end
end

function Dock:updateBevels(side)
	if type(self.bevels) ~= "table" then return end
	local targetEdge = nil
	if side == "Left" then targetEdge = "Right"
	elseif side == "Right" then targetEdge = "Left"
	elseif side == "Top" then targetEdge = "Bottom"
	elseif side == "Bottom" then targetEdge = "Top" end

	for edge, b in pairs(self.bevels) do
		local shouldShow = (edge == targetEdge)
		local rim = b:FindFirstChild("Rim")
		local edgeFrame = b:FindFirstChild("Edge")
		local fade = b:FindFirstChild("Fade")
		if shouldShow then
			b.Visible = true
			if rim then
				rim.BackgroundTransparency = 1
				TweenService:Create(rim, TweenInfo.new(0.22), { BackgroundTransparency = 0.4 }):Play()
			end
			if edgeFrame then
				edgeFrame.BackgroundTransparency = 1
				TweenService:Create(edgeFrame, TweenInfo.new(0.22), { BackgroundTransparency = 0 }):Play()
			end
			if fade then
				fade.BackgroundTransparency = 1
				TweenService:Create(fade, TweenInfo.new(0.22), { BackgroundTransparency = 0.45 }):Play()
			end
		else
			if rim then TweenService:Create(rim, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play() end
			if edgeFrame then TweenService:Create(edgeFrame, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play() end
			if fade then TweenService:Create(fade, TweenInfo.new(0.2), { BackgroundTransparency = 1 }):Play() end
			task.delay(0.24, function()
				if b and b.Parent and self.currentDockSide ~= side then
					b.Visible = false
				end
			end)
		end
	end
end

function Dock:dockTo(zone, mouseLoc)
	local wasDocked = self.currentDockSide
	if wasDocked then
		for i, e in ipairs(registry.activeDocks) do
			if e == self then
				table.remove(registry.activeDocks, i)
				break
			end
		end
		self.registeredEntry = nil
	end

	local sorted = getDocksOnEdge(zone)
	table.sort(sorted, function(a, b)
		return (a.sortKey or 0) < (b.sortKey or 0)
	end)

	local vp = Camera.ViewportSize
	local total = #sorted + 1
	local each = (zone == "Left" or zone == "Right") and (vp.Y / total) or (vp.X / total)
	local axisMouse = (zone == "Left" or zone == "Right") and mouseLoc.Y or mouseLoc.X

	local insertIndex = math.clamp(math.floor(axisMouse / each) + 1, 1, total)

	local sortedAxis = {}
	for _, d in ipairs(sorted) do
		table.insert(sortedAxis, d.sortKey or 0)
	end
	table.insert(sortedAxis, insertIndex, axisMouse)

	for i, d in ipairs(sorted) do
		d.sortKey = sortedAxis[i + (i >= insertIndex and 1 or 0)] or d.sortKey
	end

	self.sortKey = axisMouse
	self.currentDockSide = zone
	table.insert(registry.activeDocks, self)
	self.registeredEntry = true

	bringToFront(self)
	self:updateBevels(zone)
	self:updateHandleVisibility()

	if wasDocked and wasDocked ~= zone then
		reflowEdge(wasDocked)
	end
	reflowEdge(zone)
end

function Dock:undock()
	local oldEdge = self.currentDockSide
	if not oldEdge then return end
	for i, e in ipairs(registry.activeDocks) do
		if e == self then
			table.remove(registry.activeDocks, i)
			break
		end
	end
	self.registeredEntry = nil
	self.currentDockSide = nil
	self:updateBevels(nil)
	self:updateHandleVisibility()

	local targetSize = self.preDockSize or UDim2.fromOffset(DEFAULT_W, DEFAULT_H)
	local tw = targetSize.X.Offset
	local th = targetSize.Y.Offset
	TweenService:Create(self.frame, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(tw, th),
	}):Play()
	self.expandedHeight = th

	reflowEdge(oldEdge)
end

function Slate.new(opts)
	opts = opts or {}
	local groupName = opts.group or "default"
	local titleText = opts.title or "Slate"
	local size = opts.size or UDim2.fromOffset(DEFAULT_W, DEFAULT_H)
	local position = opts.position or UDim2.fromOffset(200, 200)

	local group = Slate.group(groupName)
	local gui = ensureGui()
	ensurePreviewLayer()

	local self = setmetatable({}, Dock)
	self.group = group
	self.connections = {}
	self.bevels = {}
	self.handles = {}
	self.iconButtons = {}
	self.iconImages = {}
	self.collapsed = false
	self.closing = false
	self.currentDockSide = nil
	self.preDockSize = nil
	self.registeredEntry = nil
	self.sortKey = 0

	local function track(c)
		table.insert(self.connections, c)
		return c
	end

	local frame = Instance.new("Frame")
	frame.Name = "Slate_" .. groupName
	frame.Size = size
	frame.Position = position
	frame.BackgroundColor3 = COLORS.Background
	frame.BorderSizePixel = 0
	frame.BackgroundTransparency = 1
	frame.ClipsDescendants = true
	frame.ZIndex = BASE_DOCK_Z
	frame.Parent = gui
	self.frame = frame

	local dockShadow = Instance.new("UIShadow")
	dockShadow.Color = COLORS.Shadow
	dockShadow.Transparency = 1
	dockShadow.BlurRadius = UDim.new(0, 14)
	dockShadow.Spread = UDim2.new(0, 0, 0, 0)
	dockShadow.Offset = UDim2.new(0, 0, 0, 3)
	dockShadow.ZIndex = 0
	dockShadow.Enabled = true
	dockShadow.Parent = frame
	self.dockShadow = dockShadow

	local border = Instance.new("UIStroke")
	border.Color = COLORS.Border
	border.Thickness = 1
	border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	border.Transparency = 1
	border.Parent = frame
	self.border = border

	local function makeBevel(edge)
		local b = Instance.new("Frame")
		b.Name = "Bevel_" .. edge
		b.BackgroundTransparency = 1
		b.BorderSizePixel = 0
		b.ZIndex = 8
		b.Visible = false
		b.Parent = frame

		local rim = Instance.new("Frame")
		rim.Name = "Rim"
		rim.BackgroundColor3 = COLORS.BevelRim
		rim.BorderSizePixel = 0
		rim.BackgroundTransparency = 1
		rim.ZIndex = 8
		rim.Parent = b

		local edgeFrame = Instance.new("Frame")
		edgeFrame.Name = "Edge"
		edgeFrame.BackgroundColor3 = COLORS.BevelEdge
		edgeFrame.BorderSizePixel = 0
		edgeFrame.BackgroundTransparency = 1
		edgeFrame.ZIndex = 8
		edgeFrame.Parent = b

		local fade = Instance.new("Frame")
		fade.Name = "Fade"
		fade.BackgroundColor3 = COLORS.BevelFade
		fade.BorderSizePixel = 0
		fade.BackgroundTransparency = 1
		fade.ZIndex = 8
		fade.Parent = b

		if edge == "Left" then
			b.Size = UDim2.new(0, BEVEL_SIZE, 1, 0)
			b.Position = UDim2.new(0, 0, 0, 0)
			rim.Size = UDim2.new(0, 1, 1, 0)
			rim.Position = UDim2.new(0, 0, 0, 0)
			edgeFrame.Size = UDim2.new(0, 2, 1, 0)
			edgeFrame.Position = UDim2.new(0, 1, 0, 0)
			fade.Size = UDim2.new(0, 3, 1, 0)
			fade.Position = UDim2.new(0, 3, 0, 0)
		elseif edge == "Right" then
			b.Size = UDim2.new(0, BEVEL_SIZE, 1, 0)
			b.Position = UDim2.new(1, -BEVEL_SIZE, 0, 0)
			rim.Size = UDim2.new(0, 1, 1, 0)
			rim.Position = UDim2.new(1, -1, 0, 0)
			edgeFrame.Size = UDim2.new(0, 2, 1, 0)
			edgeFrame.Position = UDim2.new(1, -3, 0, 0)
			fade.Size = UDim2.new(0, 3, 1, 0)
			fade.Position = UDim2.new(1, -6, 0, 0)
		elseif edge == "Top" then
			b.Size = UDim2.new(1, 0, 0, BEVEL_SIZE)
			b.Position = UDim2.new(0, 0, 0, 0)
			rim.Size = UDim2.new(1, 0, 0, 1)
			rim.Position = UDim2.new(0, 0, 0, 0)
			edgeFrame.Size = UDim2.new(1, 0, 0, 2)
			edgeFrame.Position = UDim2.new(0, 0, 0, 1)
			fade.Size = UDim2.new(1, 0, 0, 3)
			fade.Position = UDim2.new(0, 0, 0, 3)
		elseif edge == "Bottom" then
			b.Size = UDim2.new(1, 0, 0, BEVEL_SIZE)
			b.Position = UDim2.new(0, 0, 1, -BEVEL_SIZE)
			rim.Size = UDim2.new(1, 0, 0, 1)
			rim.Position = UDim2.new(0, 0, 1, -1)
			edgeFrame.Size = UDim2.new(1, 0, 0, 2)
			edgeFrame.Position = UDim2.new(0, 0, 1, -3)
			fade.Size = UDim2.new(1, 0, 0, 3)
			fade.Position = UDim2.new(0, 0, 1, -6)
		end

		self.bevels[edge] = b
		return b
	end

	makeBevel("Left")
	makeBevel("Right")
	makeBevel("Top")
	makeBevel("Bottom")

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(1, 0, 1, -TOPBAR_H)
	content.Position = UDim2.new(0, 0, 0, TOPBAR_H)
	content.BackgroundTransparency = 1
	content.ClipsDescendants = true
	content.ZIndex = 1
	content.Parent = frame
	self.content = content

	local contentPlaceholder = Instance.new("TextLabel")
	contentPlaceholder.Size = UDim2.new(1, 0, 1, 0)
	contentPlaceholder.BackgroundTransparency = 1
	contentPlaceholder.Text = "content area"
	contentPlaceholder.TextColor3 = COLORS.Muted
	contentPlaceholder.TextSize = 12
	contentPlaceholder.Font = Enum.Font.Gotham
	contentPlaceholder.TextTransparency = 1
	contentPlaceholder.ZIndex = 1
	contentPlaceholder.Parent = content
	self.contentPlaceholder = contentPlaceholder

	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, TOPBAR_H)
	topBar.BackgroundColor3 = COLORS.TopBar
	topBar.BorderSizePixel = 0
	topBar.BackgroundTransparency = 1
	topBar.ZIndex = 2
	topBar.Parent = frame
	self.topBar = topBar

	local topBarShadow = Instance.new("Frame")
	topBarShadow.Name = "TopBarShadow"
	topBarShadow.Size = UDim2.new(1, 0, 0, 8)
	topBarShadow.Position = UDim2.new(0, 0, 1, 0)
	topBarShadow.BackgroundColor3 = COLORS.Shadow
	topBarShadow.BorderSizePixel = 0
	topBarShadow.BackgroundTransparency = 1
	topBarShadow.ZIndex = 1
	topBarShadow.Parent = topBar
	self.topBarShadow = topBarShadow

	local topBarShadowGrad = Instance.new("UIGradient")
	topBarShadowGrad.Rotation = 90
	topBarShadowGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.7),
		NumberSequenceKeypoint.new(0.5, 0.92),
		NumberSequenceKeypoint.new(1, 1),
	})
	topBarShadowGrad.Parent = topBarShadow

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -110, 1, 0)
	title.Position = UDim2.new(0, 10, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = titleText
	title.TextColor3 = COLORS.Text
	title.TextSize = 12
	title.Font = Enum.Font.GothamMedium
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextTransparency = 1
	title.ZIndex = 2
	title.Parent = topBar
	self.title = title

	local buttonBar = Instance.new("Frame")
	buttonBar.AnchorPoint = Vector2.new(1, 0)
	buttonBar.Size = UDim2.new(0, 80, 1, 0)
	buttonBar.Position = UDim2.new(1, -4, 0, 0)
	buttonBar.BackgroundTransparency = 1
	buttonBar.ZIndex = 3
	buttonBar.Parent = topBar

	local buttonLayout = Instance.new("UIListLayout")
	buttonLayout.FillDirection = Enum.FillDirection.Horizontal
	buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	buttonLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
	buttonLayout.Padding = UDim.new(0, 4)
	buttonLayout.Parent = buttonBar

	local function makeIconButton(order, iconId, name)
		local btn = Instance.new("TextButton")
		btn.Name = name or "IconBtn"
		btn.Size = UDim2.new(0, 20, 0, 20)
		btn.BackgroundColor3 = COLORS.TopBar
		btn.BackgroundTransparency = 1
		btn.BorderSizePixel = 0
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.LayoutOrder = order
		btn.ZIndex = 3
		btn.Parent = buttonBar

		local img = Instance.new("ImageLabel")
		img.Size = UDim2.new(0, 14, 0, 14)
		img.Position = UDim2.new(0.5, 0, 0.5, 0)
		img.AnchorPoint = Vector2.new(0.5, 0.5)
		img.BackgroundTransparency = 1
		img.Image = iconId or ""
		img.ImageColor3 = COLORS.Muted
		img.ImageTransparency = 0
		img.ScaleType = Enum.ScaleType.Fit
		img.ZIndex = 3
		img.Parent = btn

		table.insert(self.iconImages, img)
		table.insert(self.iconButtons, btn)

		track(btn.MouseEnter:Connect(function()
			TweenService:Create(img, TweenInfo.new(0.12), { ImageColor3 = COLORS.Text }):Play()
		end))
		track(btn.MouseLeave:Connect(function()
			TweenService:Create(img, TweenInfo.new(0.12), { ImageColor3 = COLORS.Muted }):Play()
		end))

		return btn, img
	end

	local dockRightBtn, dockRightImg = makeIconButton(1, ICONS.DockRight, "DockRightBtn")
	local minimizeBtn, minimizeImg = makeIconButton(2, ICONS.Minimize, "MinimizeBtn")
	local closeBtn, closeImg = makeIconButton(3, ICONS.Close, "CloseBtn")
	self.minimizeImg = minimizeImg

	self.expandedHeight = frame.Size.Y.Offset

	track(minimizeBtn.MouseButton1Click:Connect(function()
		if self.closing then return end
		self:setCollapsed(not self.collapsed)
	end))

	track(closeBtn.MouseButton1Click:Connect(function()
		self:destroy()
	end))

	track(dockRightBtn.MouseButton1Click:Connect(function()
		if self.closing then return end
		if not self.currentDockSide then
			self.preDockSize = UDim2.fromOffset(frame.Size.X.Offset, frame.Size.Y.Offset)
		end
		local vp = Camera.ViewportSize
		local mouseLoc = Vector2.new(vp.X - DOCKED_THICK / 2, (frame.AbsolutePosition.Y + frame.AbsoluteSize.Y / 2))
		self:dockTo("Right", mouseLoc)
	end))

	local handles = self.handles
	local dirs = {
		{ name = "N", anchor = Vector2.new(0.5, 0), pos = UDim2.new(0.5, 0, 0, 0), size = UDim2.new(1, -12, 0, RESIZE_MARGIN) },
		{ name = "S", anchor = Vector2.new(0.5, 1), pos = UDim2.new(0.5, 0, 1, 0), size = UDim2.new(1, -12, 0, RESIZE_MARGIN) },
		{ name = "W", anchor = Vector2.new(0, 0.5), pos = UDim2.new(0, 0, 0.5, 0), size = UDim2.new(0, RESIZE_MARGIN, 1, -12) },
		{ name = "E", anchor = Vector2.new(1, 0.5), pos = UDim2.new(1, 0, 0.5, 0), size = UDim2.new(0, RESIZE_MARGIN, 1, -12) },
		{ name = "NW", anchor = Vector2.new(0, 0), pos = UDim2.new(0, 0, 0, 0), size = UDim2.new(0, RESIZE_MARGIN + 4, 0, RESIZE_MARGIN + 4) },
		{ name = "NE", anchor = Vector2.new(1, 0), pos = UDim2.new(1, 0, 0, 0), size = UDim2.new(0, RESIZE_MARGIN + 4, 0, RESIZE_MARGIN + 4) },
		{ name = "SW", anchor = Vector2.new(0, 1), pos = UDim2.new(0, 0, 1, 0), size = UDim2.new(0, RESIZE_MARGIN + 4, 0, RESIZE_MARGIN + 4) },
		{ name = "SE", anchor = Vector2.new(1, 1), pos = UDim2.new(1, 0, 1, 0), size = UDim2.new(0, RESIZE_MARGIN + 4, 0, RESIZE_MARGIN + 4) },
	}

	for _, d in ipairs(dirs) do
		local h = Instance.new("TextButton")
		h.Name = "Resize_" .. d.name
		h.AnchorPoint = d.anchor
		h.Position = d.pos
		h.Size = d.size
		h.BackgroundTransparency = 1
		h.BackgroundColor3 = COLORS.Resize
		h.BorderSizePixel = 0
		h.Text = ""
		h.AutoButtonColor = false
		h.ZIndex = 5
		h.Parent = frame
		handles[d.name] = h
	end

	local function setupResize(handle, dir)
		local draggingResize = false
		local startMouse
		local startPos
		local startSize

		track(handle.MouseEnter:Connect(function()
			handle.BackgroundTransparency = 0.5
		end))
		track(handle.MouseLeave:Connect(function()
			if not draggingResize then
				handle.BackgroundTransparency = 1
			end
		end))

		track(handle.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			if self.collapsed or self.closing then return end
			draggingResize = true
			startMouse = input.Position
			startPos = frame.Position
			startSize = frame.Size
			handle.BackgroundTransparency = 0.2
		end))

		track(UserInputService.InputChanged:Connect(function(input)
			if not draggingResize then return end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
			local dx = input.Position.X - startMouse.X
			local dy = input.Position.Y - startMouse.Y

			local sw = startSize.X.Offset
			local sh = startSize.Y.Offset
			local sx = startPos.X.Offset
			local sy = startPos.Y.Offset

			local nw, nh = sw, sh
			local nx, ny = sx, sy

			if dir:find("E") then nw = clamp(sw + dx, MIN_W, 4000) end
			if dir:find("S") then nh = clamp(sh + dy, MIN_H, 4000) end
			if dir:find("W") then
				local newW = clamp(sw - dx, MIN_W, 4000)
				nx = sx + (sw - newW)
				nw = newW
			end
			if dir:find("N") then
				local newH = clamp(sh - dy, MIN_H, 4000)
				ny = sy + (sh - newH)
				nh = newH
			end

			if self.currentDockSide == "Left" and dir:find("E") then
				frame.Size = UDim2.new(0, nw, 0, nh)
			elseif self.currentDockSide == "Right" and dir:find("W") then
				frame.Position = UDim2.new(0, nx, 0, ny)
				frame.Size = UDim2.new(0, nw, 0, nh)
			elseif self.currentDockSide == "Top" and dir:find("S") then
				frame.Size = UDim2.new(0, nw, 0, nh)
			elseif self.currentDockSide == "Bottom" and dir:find("N") then
				frame.Position = UDim2.new(0, nx, 0, ny)
				frame.Size = UDim2.new(0, nw, 0, nh)
			else
				frame.Position = UDim2.new(0, nx, 0, ny)
				frame.Size = UDim2.new(0, nw, 0, nh)
			end

			if dir:find("S") or dir:find("N") then
				self.expandedHeight = nh
			end
		end))

		track(UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and draggingResize then
				draggingResize = false
				handle.BackgroundTransparency = 1
			end
		end))
	end

	for _, name in ipairs({ "N", "S", "E", "W", "NW", "NE", "SW", "SE" }) do
		setupResize(handles[name], name)
	end

	local dragging = false
	local dragStart
	local dragStartAbs

	track(topBar.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if self.closing then return end

		bringToFront(self)

		if self.currentDockSide then
			self:undock()
			task.wait(0.02)
		end

		dragging = true
		dragStart = input.Position
		dragStartAbs = Vector2.new(frame.AbsolutePosition.X, frame.AbsolutePosition.Y)
	end))

	track(UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
		local dx = input.Position.X - dragStart.X
		local dy = input.Position.Y - dragStart.Y
		frame.Position = UDim2.fromOffset(dragStartAbs.X + dx, dragStartAbs.Y + dy)

		local mouseLoc = UserInputService:GetMouseLocation()
		local zone = evaluateZone(mouseLoc)

		if zone then
			showPreview(zone)
		else
			hidePreview()
		end
	end))

	track(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if not dragging then return end
		dragging = false

		local mouseLoc = UserInputService:GetMouseLocation()
		local zone = evaluateZone(mouseLoc)

		hidePreview()

		if zone then
			if not self.currentDockSide then
				self.preDockSize = UDim2.fromOffset(frame.Size.X.Offset, frame.Size.Y.Offset)
			end
			self:dockTo(zone, mouseLoc)
		end
	end))

	task.spawn(function()
		task.wait()
		TweenService:Create(frame, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
		TweenService:Create(topBar, TweenInfo.new(0.28, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
		TweenService:Create(topBarShadow, TweenInfo.new(0.35), { BackgroundTransparency = 0 }):Play()
		TweenService:Create(border, TweenInfo.new(0.35), { Transparency = 0 }):Play()
		TweenService:Create(dockShadow, TweenInfo.new(0.35), { Transparency = 0.45 }):Play()
		TweenService:Create(title, TweenInfo.new(0.35), { TextTransparency = 0 }):Play()
		TweenService:Create(contentPlaceholder, TweenInfo.new(0.45), { TextTransparency = 0 }):Play()
	end)

	table.insert(group.docks, self)

	return self
end

return Slate
