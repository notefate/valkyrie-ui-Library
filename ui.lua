
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local Valkyrie = {}
Valkyrie.__index = Valkyrie

Valkyrie.theme = {
	bg = Color3.fromRGB(13, 14, 17),
	panel = Color3.fromRGB(17, 18, 22),
	panel2 = Color3.fromRGB(22, 23, 27),
	panel3 = Color3.fromRGB(28, 30, 36),
	stroke = Color3.fromRGB(36, 38, 46),
	text = Color3.fromRGB(230, 232, 240),
	muted = Color3.fromRGB(150, 154, 168),
	accent = Color3.fromRGB(255, 215, 0),
	danger = Color3.fromRGB(255, 90, 90),
}

Valkyrie.fonts = {
	thin = Enum.Font.Gotham,
	ui = Enum.Font.Gotham,
	semibold = Enum.Font.GothamSemibold,
	bold = Enum.Font.GothamBold,
}

local function protect_parent(gui)
	local ok = pcall(function()
		gui.Parent = game:GetService("CoreGui")
	end)
	if not ok then
		gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	end
end

local function create(className, props)
	local inst = Instance.new(className)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	return inst
end

local function round(frame, radius)
	create("UICorner", {
		CornerRadius = UDim.new(0, radius or 10),
		Parent = frame,
	})
end

local function stroke(frame, color)
	create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = 1,
		Color = color,
		Transparency = 0,
		Parent = frame,
	})
end

local function get_viewport()
	local cam = workspace.CurrentCamera
	if cam then
		return cam.ViewportSize
	end
	return Vector2.new(1280, 720)
end

local function is_phone()
	local v = get_viewport()
	if UserInputService.TouchEnabled and (v.X <= 750 or v.Y <= 500) then
		return true
	end
	return false
end

local function is_touch_device()
	return UserInputService.TouchEnabled
end

local function clamp_to_viewport(sizeX, sizeY)
	local v = get_viewport()
	local inset = GuiService:GetGuiInset()
	local maxX = math.max(320, v.X - 20)
	local maxY = math.max(240, v.Y - inset.Y - 20)
	return math.clamp(sizeX, 320, maxX), math.clamp(sizeY, 240, maxY)
end

local function safe_disconnect(conn)
	if conn and typeof(conn) == "RBXScriptConnection" then
		pcall(function()
			conn:Disconnect()
		end)
	end
end

local function make_button(parent, text, theme)
	local btn = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = theme.panel2,
		BorderSizePixel = 0,
		Font = Valkyrie.fonts.semibold,
		Text = text or "Button",
		TextColor3 = theme.text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 28),
		Parent = parent,
	})

	round(btn, 4)
	stroke(btn, theme.stroke)

	return btn
end

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Page = {}
Page.__index = Page

local Section = {}
Section.__index = Section

function Valkyrie:CreateWindow(opts)
	opts = opts or {}
	local title = opts.Title or opts.title or "Valkyrie"
	local launcherText = opts.LauncherText or opts.launcherText or opts.MobileToggleText or opts.mobileToggleText or "Ironic"

	local gui = create("ScreenGui", {
		Name = "ValkyrieUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	protect_parent(gui)

	local root = create("Frame", {
		Name = "Root",
		BackgroundColor3 = self.theme.bg,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Parent = gui,
	})
	round(root, 10)
	stroke(root, self.theme.stroke)

	local uiScale = create("UIScale", {
		Scale = 1,
		Parent = root,
	})

	local baseX, baseY = 760, 480
	if typeof(opts.Size) == "UDim2" then
		baseX, baseY = opts.Size.X.Offset, opts.Size.Y.Offset
	end

	if is_phone() then
		uiScale.Scale = 0.9
		baseX, baseY = 560, 420
	end
	baseX, baseY = clamp_to_viewport(baseX, baseY)
	root.Size = UDim2.fromOffset(baseX, baseY)

	local topBar = create("Frame", {
		Name = "TopBar",
		BackgroundColor3 = self.theme.panel,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 32),
		Parent = root,
	})
	create("UICorner", { CornerRadius = UDim.new(0, 10), Parent = topBar })

	local titleLabel = create("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Text = title,
		Font = Valkyrie.fonts.semibold,
		TextSize = 12,
		TextColor3 = self.theme.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -120, 1, 0),
		Position = UDim2.new(0, 12, 0, 0),
		Parent = topBar,
	})

	local controls = create("Frame", {
		Name = "Controls",
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 96, 1, 0),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -8, 0, 0),
		Parent = topBar,
	})

	local minimize = create("TextButton", {
		Name = "Minimize",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "-",
		Font = Valkyrie.fonts.bold,
		TextSize = 18,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.fromOffset(44, 26),
		Parent = controls,
	})
	minimize.Position = UDim2.new(0, 0, 0.5, -13)

	local close = create("TextButton", {
		Name = "Close",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "X",
		Font = Valkyrie.fonts.bold,
		TextSize = 16,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.fromOffset(44, 26),
		Parent = controls,
	})
	close.Position = UDim2.new(0, 52, 0.5, -13)

	local divider = create("Frame", {
		Name = "Divider",
		BackgroundColor3 = self.theme.stroke,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 0, 32),
		Parent = root,
	})

	local body = create("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, -33),
		Position = UDim2.new(0, 0, 0, 33),
		Parent = root,
	})

	local sidebar = create("Frame", {
		Name = "Sidebar",
		BackgroundColor3 = self.theme.panel,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 176, 1, 0),
		Parent = body,
	})
	stroke(sidebar, self.theme.stroke)

	local tabsHolder = create("ScrollingFrame", {
		Name = "TabsHolder",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -20, 1, -116),
		Position = UDim2.new(0, 10, 0, 22),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = self.theme.accent,
		Parent = sidebar,
	})
	local tabsLayout = create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = tabsHolder,
	})
	local tabsPadding = create("UIPadding", {
		PaddingTop = UDim.new(0, 2),
		PaddingBottom = UDim.new(0, 2),
		Parent = tabsHolder,
	})
	local function updateTabsCanvas()
		local y = tabsLayout.AbsoluteContentSize.Y + tabsPadding.PaddingTop.Offset + tabsPadding.PaddingBottom.Offset
		tabsHolder.CanvasSize = UDim2.new(0, 0, 0, y)
	end
	tabsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateTabsCanvas)
	updateTabsCanvas()

	local profile = create("Frame", {
		Name = "Profile",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -20, 0, 48),
		Position = UDim2.new(0, 10, 1, -54),
		Parent = sidebar,
	})

	local avatar = create("ImageLabel", {
		Name = "Avatar",
		BackgroundColor3 = self.theme.panel2,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(34, 34),
		Position = UDim2.new(0, 0, 0, 7),
		Image = "",
		ScaleType = Enum.ScaleType.Crop,
		Parent = profile,
	})
	round(avatar, 10)
	stroke(avatar, self.theme.stroke)

	local nameHolder = create("Frame", {
		Name = "NameHolder",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -42, 1, 0),
		Position = UDim2.new(0, 42, 0, 0),
		Parent = profile,
	})

	local usernameLabel = create("TextLabel", {
		Name = "Username",
		BackgroundTransparency = 1,
		Text = "@" .. (LocalPlayer and LocalPlayer.Name or "Player"),
		Font = Valkyrie.fonts.semibold,
		TextSize = 10,
		TextColor3 = self.theme.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 16),
		Position = UDim2.new(0, 0, 0, 8),
		Parent = nameHolder,
	})

	local displayLabel = create("TextLabel", {
		Name = "Displayname",
		BackgroundTransparency = 1,
		Text = (LocalPlayer and LocalPlayer.DisplayName or "DisplayName"),
		Font = Valkyrie.fonts.thin,
		TextSize = 9,
		TextColor3 = self.theme.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 24),
		Position = UDim2.new(0, 0, 0, 22),
		Parent = nameHolder,
	})

	local content = create("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -176, 1, 0),
		Position = UDim2.new(0, 176, 0, 0),
		Parent = body,
	})

	local pagesBar = create("Frame", {
		Name = "PagesBar",
		BackgroundColor3 = self.theme.panel,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 28),
		Visible = true,
		Parent = content,
	})
	stroke(pagesBar, self.theme.stroke)

	local pagesHolder = create("Frame", {
		Name = "PagesHolder",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		Parent = pagesBar,
	})
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		Parent = pagesHolder,
	})

	local pagesContainer = create("Frame", {
		Name = "PagesContainer",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, -28),
		Position = UDim2.new(0, 0, 0, 28),
		Parent = content,
	})

	local resizeHandle = create("Frame", {
		Name = "ResizeHandle",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -8, 1, -8),
		Size = UDim2.fromOffset(22, 22),
		Parent = root,
	})
	for i = 1, 3 do
		create("Frame", {
			BackgroundColor3 = self.theme.muted,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -5, 1, -5 - ((i - 1) * 4)),
			Size = UDim2.fromOffset(11 - ((i - 1) * 2), 1),
			Parent = resizeHandle,
		})
	end

	local window = setmetatable({
		_gui = gui,
		_root = root,
		_body = body,
		_sidebar = sidebar,
		_tabsHolder = tabsHolder,
		_content = content,
		_pagesHolder = pagesHolder,
		_pagesContainer = pagesContainer,
		_minimizeButton = minimize,
		_closeButton = close,
		_uiScale = uiScale,
		_mobileToggle = nil,
		_visible = true,
		_toggleKey = Enum.KeyCode.LeftControl,
		_typing = false,
		_suppressAutoSelect = false,
		_dropdowns = {},
		_notifs = { container = nil },
		_tabs = {},
		_selectedTab = nil,
		_selectedPage = nil,
		theme = self.theme,
	}, Window)

	do
		local holder = create("Frame", {
			Name = "Notifications",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -18, 1, -18),
			Size = UDim2.new(0, 240, 0, 220),
			Parent = gui,
		})
		create("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 8),
			Parent = holder,
		})
		window._notifs.container = holder
	end

	do
		local touch = is_touch_device()
		local toggle = create("ImageButton", {
			Name = "MobileToggle",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			ClipsDescendants = true,
			BorderSizePixel = 0,
			Image = "rbxassetid://90090883306100",
			ScaleType = Enum.ScaleType.Fit,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -16, 1, -16),
			Size = UDim2.fromOffset(320, 56),
			Visible = touch,
			Parent = gui,
		})
		round(toggle, 10)
		window._mobileToggle = toggle
		
		-- Make the toggle button draggable
		local dragging = false
		local dragStart
		local startPos
		
		toggle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = toggle.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		
		UserInputService.InputChanged:Connect(function(input)
			if not dragging then
				return
			end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			local delta = input.Position - dragStart
			toggle.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end)
		
		toggle.Activated:Connect(function()
			window:ToggleVisible()
		end)
	end

	task.spawn(function()
		if not LocalPlayer then
			return
		end
		local ok, contentId = pcall(function()
			return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		if ok and contentId then
			avatar.Image = contentId
		end
	end)

	minimize.Activated:Connect(function()
		window:ToggleVisible()
	end)

	close.Activated:Connect(function()
		gui:Destroy()
	end)

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if is_touch_device() then
			return
		end
		if window._typing then
			return
		end
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == window._toggleKey then
			window:ToggleVisible()
		end
	end)

	do
		local dragging = false
		local dragStart
		local startPos

		topBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = root.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if not dragging then
				return
			end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			local delta = input.Position - dragStart
			root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end)
	end

	do
		local resizing = false
		local startSize
		local startInputPos

		resizeHandle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				resizing = true
				startSize = root.AbsoluteSize
				startInputPos = input.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						resizing = false
					end
				end)
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if not resizing then
				return
			end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			local delta = input.Position - startInputPos
			local newX, newY = clamp_to_viewport(startSize.X + delta.X, startSize.Y + delta.Y)
			root.Size = UDim2.fromOffset(newX, newY)
		end)
	end

	local function updateResponsive()
		if is_phone() then
			window._uiScale.Scale = 0.9
		else
			window._uiScale.Scale = 1
		end
	end
	updateResponsive()
	if workspace.CurrentCamera then
		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsive)
	end

	do
		window._suppressAutoSelect = true
		local settingsTab = window:CreateTab("Settings")
		local settingsPage = settingsTab:CreatePage("Settings")
		
		local streamerSection = settingsPage:CreateSection("Streamer Mode")
		streamerSection:AddToggle("Hide Username/Display", false, function(enabled)
			if enabled then
				usernameLabel.Text = "@Hidden"
				displayLabel.Text = "Hidden"
			else
				usernameLabel.Text = "@" .. (LocalPlayer and LocalPlayer.Name or "Player")
				displayLabel.Text = (LocalPlayer and LocalPlayer.DisplayName or "DisplayName")
			end
		end)
		streamerSection:AddTextbox("Custom Username", "", function(text)
			if text ~= "" then
				usernameLabel.Text = "@" .. text
			else
				usernameLabel.Text = "@" .. (LocalPlayer and LocalPlayer.Name or "Player")
			end
		end)
		streamerSection:AddTextbox("Custom Display Name", "", function(text)
			if text ~= "" then
				displayLabel.Text = text
			else
				displayLabel.Text = (LocalPlayer and LocalPlayer.DisplayName or "DisplayName")
			end
		end)
		
		local controlsSection = settingsPage:CreateSection("Controls")
		controlsSection:AddLabel("Toggle the UI: PC keybind; Touch launcher button.")
		controlsSection:AddKeybind("Toggle Key", window._toggleKey, function(newKey)
			window:SetToggleKey(newKey)
		end)
		controlsSection:AddTextbox("Launcher Text", tostring(launcherText), function(text)
			window:SetLauncherText(text)
		end)
		window._suppressAutoSelect = false
	end

	return window
end

function Window:Notify(opts)
	opts = opts or {}
	local title = tostring(opts.title or opts.Title or "Valkyrie")
	local text = tostring(opts.text or opts.Text or opts.message or opts.Message or "")
	local duration = tonumber(opts.duration or opts.Duration or 3) or 3

	local container = self._notifs and self._notifs.container
	if not container then
		return
	end

	local theme = self.theme
	local width = 240
	local card = create("Frame", {
		BackgroundColor3 = theme.panel,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(width, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = container,
	})
	round(card, 12)
	stroke(card, theme.stroke)

	local inner = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -18, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(0, 12, 0, 10),
		Parent = card,
	})
	create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = inner,
	})

	create("TextLabel", {
		BackgroundTransparency = 1,
		Text = title,
		Font = Valkyrie.fonts.bold,
		TextSize = 12,
		TextColor3 = theme.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 18),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = inner,
	})

	create("TextLabel", {
		BackgroundTransparency = 1,
		Text = text,
		Font = Valkyrie.fonts.thin,
		TextSize = 12,
		TextColor3 = theme.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 18),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = inner,
	})

	create("UIPadding", { PaddingBottom = UDim.new(0, 10), Parent = card })

	card.BackgroundTransparency = 1
	task.defer(function()
		if not card.Parent then
			return
		end
		local targetY = math.max(52, card.AbsoluteSize.Y)
		card.Size = UDim2.fromOffset(width, 0)
		TweenService:Create(card, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(width, targetY),
			BackgroundTransparency = 0,
		}):Play()
	end)

	task.delay(duration, function()
		if not card.Parent then
			return
		end
		local tween = TweenService:Create(card, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
			Size = UDim2.fromOffset(width, 0),
			BackgroundTransparency = 1,
		})
		tween:Play()
		tween.Completed:Wait()
		pcall(function()
			card:Destroy()
		end)
	end)
end

function Window:SetToggleKey(keyCode)
	if typeof(keyCode) ~= "EnumItem" then
		return
	end
	if keyCode.EnumType ~= Enum.KeyCode then
		return
	end
	self._toggleKey = keyCode
end

function Window:SetVisible(visible)
	self._visible = visible and true or false
	if self._root then
		self._root.Visible = self._visible
	end
	if self._mobileToggle then
		self._mobileToggle.Visible = is_touch_device()
	end
end

function Window:SetLauncherText(text)
	if self._mobileToggle and self._mobileToggle:IsA("TextButton") then
		self._mobileToggle.Text = tostring(text)
	end
end

function Window:ToggleVisible()
	self:SetVisible(not self._visible)
end

function Window:Destroy()
	if self._gui then
		self._gui:Destroy()
	end
end

function Window:SetTitle(text)
	local topBar = self._root:FindFirstChild("TopBar")
	if not topBar then
		return
	end
	local titleLabel = topBar:FindFirstChild("Title")
	if titleLabel and titleLabel:IsA("TextLabel") then
		titleLabel.Text = tostring(text)
	end
end

function Window:CreateTab(name)
	name = tostring(name or "Tab")

	local tab = setmetatable({
		_window = self,
		_name = name,
		_pages = {},
		_button = nil,
		_selectedPage = nil,
	}, Tab)

	local btn = create("TextButton", {
		Name = "TabButton",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = "",
		Size = UDim2.new(1, 0, 0, 35),
		Parent = self._tabsHolder,
	})
	round(btn, 7)

	local btnStroke = create("UIStroke", {
		Color = Color3.fromRGB(23, 23, 29),
		Enabled = false,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = btn,
	})

	local btnLabel = create("TextLabel", {
		Name = "Label",
		BackgroundTransparency = 1,
		Text = name,
		Font = Valkyrie.fonts.semibold,
		TextSize = 14,
		TextColor3 = Color3.fromRGB(72, 72, 73),
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -40, 1, 0),
		Position = UDim2.new(0, 40, 0, 0),
		Parent = btn,
	})
	create("UIPadding", { PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), Parent = btnLabel })

	tab._button = btn
	tab._buttonLabel = btnLabel

	btn.Activated:Connect(function()
		self:SelectTab(tab)
	end)

	table.insert(self._tabs, tab)
	if not self._selectedTab and not self._suppressAutoSelect then
		self:SelectTab(tab)
	end

	return tab
end

function Window:SelectTab(tab)
	if self._selectedTab == tab then
		return
	end
	self._selectedTab = tab

	for _, t in ipairs(self._tabs) do
		if t._button then
			local isSelected = (t == tab)
			t._button.BackgroundTransparency = isSelected and 0 or 1
			t._button.BackgroundColor3 = isSelected and self.theme.panel2 or Color3.fromRGB(29, 29, 29)
			if t._buttonLabel then
				t._buttonLabel.TextColor3 = isSelected and self.theme.accent or Color3.fromRGB(72, 72, 73)
			end
		end
	end

	for _, child in ipairs(self._pagesHolder:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	for _, child in ipairs(self._pagesContainer:GetChildren()) do
		if child:IsA("Frame") then
			child.Visible = false
		end
	end

	for _, page in ipairs(tab._pages) do
		page:_attachButton(self._pagesHolder)
	end

	if tab._selectedPage then
		self:SelectPage(tab._selectedPage)
	elseif tab._pages[1] then
		self:SelectPage(tab._pages[1])
	end
end

function Window:SelectPage(page)
	if self._selectedPage == page then
		return
	end
	self._selectedPage = page

	for _, child in ipairs(self._pagesContainer:GetChildren()) do
		if child:IsA("Frame") then
			child.Visible = false
		end
	end

	page._frame.Visible = true

	for _, tab in ipairs(self._tabs) do
		for _, p in ipairs(tab._pages) do
			if p._button then
				local isSelected = (p == page)
				p._button.TextColor3 = isSelected and self.theme.accent or self.theme.text
				if p._underline then
					p._underline.Visible = isSelected
				end
			end
		end
	end
end

function Tab:CreatePage(name)
	name = tostring(name or "Page")

	local pageFrame = create("Frame", {
		Name = "Page_" .. name,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false,
		Parent = self._window._pagesContainer,
	})

	local scroll = create("ScrollingFrame", {
		Name = "Scroll",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = self._window.theme.accent,
		Parent = pageFrame,
	})

	local padding = create("UIPadding", {
		PaddingTop = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		PaddingBottom = UDim.new(0, 12),
		Parent = scroll,
	})

	local columnsHolder = create("Frame", {
		Name = "ColumnsHolder",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = scroll,
	})

	local leftColumn = create("Frame", {
		Name = "LeftColumn",
		BackgroundTransparency = 1,
		Size = UDim2.new(0.5, -6, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(0, 0, 0, 0),
		Parent = columnsHolder,
	})
	create("UIListLayout", {
		Padding = UDim.new(0, 12),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = leftColumn,
	})

	local rightColumn = create("Frame", {
		Name = "RightColumn",
		BackgroundTransparency = 1,
		Size = UDim2.new(0.5, -6, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(0.5, 6, 0, 0),
		Parent = columnsHolder,
	})
	create("UIListLayout", {
		Padding = UDim.new(0, 12),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = rightColumn,
	})

	local function updateCanvas()
		local y = columnsHolder.AbsoluteSize.Y + padding.PaddingTop.Offset + padding.PaddingBottom.Offset
		scroll.CanvasSize = UDim2.new(0, 0, 0, y)
	end
	columnsHolder:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateCanvas)
	updateCanvas()

	local page = setmetatable({
		_tab = self,
		_window = self._window,
		_name = name,
		_frame = pageFrame,
		_scroll = scroll,
		_leftColumn = leftColumn,
		_rightColumn = rightColumn,
		_button = nil,
		_sections = {},
		_sectionCount = 0,
	}, Page)

	table.insert(self._pages, page)
	if not self._selectedPage then
		self._selectedPage = page
		if self._window._selectedTab == self then
			self._window:SelectPage(page)
		end
	end

	return page
end

function Page:_attachButton(parent)
	if self._button then
		self._button:Destroy()
		self._button = nil
	end

	local btn = create("TextButton", {
		Name = "PageButton",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = self._name,
		Font = Valkyrie.fonts.semibold,
		TextSize = 11,
		TextColor3 = self._window.theme.text,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.fromOffset(96, 22),
		Parent = parent,
	})
	local underline = create("Frame", {
		Name = "Underline",
		BackgroundColor3 = self._window.theme.accent,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 0),
		Size = UDim2.new(0.6, 0, 0, 2),
		Visible = false,
		Parent = btn,
	})
	round(underline, 999)

	btn.Activated:Connect(function()
		self._window:SelectPage(self)
		self._tab._selectedPage = self
	end)

	self._button = btn
	self._underline = underline
end

function Page:CreateSection(name)
	name = tostring(name or "Section")

	local targetColumn = (self._sectionCount % 2 == 0) and self._leftColumn or self._rightColumn
	self._sectionCount = self._sectionCount + 1

	local frame = create("Frame", {
		Name = "Section_" .. name,
		BackgroundColor3 = self._window.theme.panel,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = targetColumn,
	})
	round(frame, 10)
	stroke(frame, self._window.theme.stroke)

	local headerRow = create("Frame", {
		Name = "HeaderRow",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -16, 0, 20),
		Position = UDim2.new(0, 8, 0, 8),
		Parent = frame,
	})

	create("Frame", {
		Name = "LeftLine",
		BackgroundColor3 = self._window.theme.stroke,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0.5, -50, 0, 1),
		Parent = headerRow,
	})

	create("Frame", {
		Name = "RightLine",
		BackgroundColor3 = self._window.theme.stroke,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0.5, -50, 0, 1),
		Parent = headerRow,
	})

	create("TextLabel", {
		Name = "Header",
		BackgroundTransparency = 1,
		Text = name,
		Font = Valkyrie.fonts.semibold,
		TextSize = 12,
		TextColor3 = self._window.theme.text,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		Parent = headerRow,
	})

	local holder = create("Frame", {
		Name = "Holder",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -16, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Position = UDim2.new(0, 8, 0, 32),
		Parent = frame,
	})
	create("UIListLayout", {
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = holder,
	})
	create("UIPadding", {
		PaddingBottom = UDim.new(0, 12),
		Parent = holder,
	})

	local section = setmetatable({
		_page = self,
		_window = self._window,
		_name = name,
		_frame = frame,
		_holder = holder,
	}, Section)

	table.insert(self._sections, section)
	return section
end

function Section:AddLabel(text)
	local label = create("TextLabel", {
		BackgroundTransparency = 1,
		Text = tostring(text or "Label"),
		Font = Valkyrie.fonts.thin,
		TextSize = 12,
		TextColor3 = self._window.theme.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Size = UDim2.new(1, 0, 0, 18),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = self._holder,
	})
	return label
end

function Section:AddButton(text, callback)
	local btn = make_button(self._holder, text, self._window.theme)
	btn.Activated:Connect(function()
		if typeof(callback) == "function" then
			callback()
		end
	end)
	return btn
end

function Section:AddToggle(text, default, callback)
	local theme = self._window.theme
	local row = create("Frame", {
		BackgroundColor3 = theme.panel2,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 28),
		Parent = self._holder,
	})
	round(row, 4)
	stroke(row, theme.stroke)

	local label = create("TextLabel", {
		BackgroundTransparency = 1,
		Text = tostring(text or "Toggle"),
		Font = Valkyrie.fonts.semibold,
		TextSize = 12,
		TextColor3 = theme.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -56, 1, 0),
		Position = UDim2.new(0, 38, 0, 0),
		Parent = row,
	})

	local state = default and true or false
	local box = create("TextButton", {
		Name = "Box",
		AutoButtonColor = false,
		BackgroundColor3 = theme.panel3,
		BorderSizePixel = 0,
		Text = "",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 10, 0.5, 0),
		Size = UDim2.fromOffset(18, 18),
		Parent = row,
	})
	round(box, 4)
	stroke(box, theme.stroke)

	local check = create("TextLabel", {
		BackgroundTransparency = 1,
		Text = state and "✓" or "",
		Font = Valkyrie.fonts.bold,
		TextSize = 13,
		TextColor3 = theme.accent,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = box,
	})

	local function set(on)
		state = on
		check.Text = state and "✓" or ""
		TweenService:Create(check, TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = state and 0 or 0.35,
		}):Play()
		if typeof(callback) == "function" then
			callback(state)
		end
	end

	box.Activated:Connect(function()
		set(not state)
	end)

	row.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			set(not state)
		end
	end)

	return {
		Set = set,
		Get = function()
			return state
		end,
	}
end

function Section:AddTextbox(text, defaultValue, callback)
	local theme = self._window.theme
	local container = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = self._holder,
	})
	create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = container,
	})

	local label = create("TextLabel", {
		BackgroundTransparency = 1,
		Text = tostring(text or "Textbox"),
		Font = Valkyrie.fonts.semibold,
		TextSize = 12,
		TextColor3 = theme.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -10, 0, 16),
		Parent = container,
	})
	create("UIPadding", { PaddingLeft = UDim.new(0, 5), Parent = label })

	local box = create("TextBox", {
		BackgroundColor3 = theme.panel3,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Text = tostring(defaultValue or ""),
		Font = Valkyrie.fonts.thin,
		TextSize = 12,
		TextColor3 = theme.text,
		PlaceholderText = "Enter...",
		PlaceholderColor3 = theme.muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 28),
		Parent = container,
	})
	round(box, 4)
	stroke(box, theme.stroke)
	create("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = box })

	box.Focused:Connect(function()
		self._window._typing = true
	end)
	box.FocusLost:Connect(function(enterPressed)
		self._window._typing = false
		if typeof(callback) == "function" then
			callback(box.Text, enterPressed)
		end
	end)

	return box
end

function Section:AddSlider(opts)
	opts = opts or {}
	local theme = self._window.theme
	local name = tostring(opts.name or opts.Name or "Slider")
	local min = tonumber(opts.min or opts.Min or 0) or 0
	local max = tonumber(opts.max or opts.Max or 100) or 100
	local step = tonumber(opts.step or opts.Step or 1) or 1
	local suffix = tostring(opts.suffix or opts.Suffix or "")
	local default = tonumber(opts.default or opts.Default or min) or min

	if max <= min then
		max = min + 1
	end

	local function snap(v)
		local s = step
		if s <= 0 then
			return math.clamp(v, min, max)
		end
		local snapped = math.floor(((v - min) / s) + 0.5) * s + min
		return math.clamp(snapped, min, max)
	end

	local value = snap(default)

	local row = create("Frame", {
		BackgroundColor3 = theme.panel2,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 44),
		Parent = self._holder,
	})
	round(row, 4)
	stroke(row, theme.stroke)

	local label = create("TextLabel", {
		BackgroundTransparency = 1,
		Text = name,
		Font = Valkyrie.fonts.semibold,
		TextSize = 12,
		TextColor3 = theme.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -90, 0, 18),
		Position = UDim2.new(0, 10, 0, 6),
		Parent = row,
	})

	local valueLabel = create("TextLabel", {
		BackgroundTransparency = 1,
		Text = tostring(value) .. suffix,
		Font = Valkyrie.fonts.thin,
		TextSize = 12,
		TextColor3 = theme.muted,
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.new(0, 70, 0, 18),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -10, 0, 6),
		Parent = row,
	})

	local track = create("Frame", {
		BackgroundColor3 = theme.panel3,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -20, 0, 8),
		Position = UDim2.new(0, 10, 0, 30),
		Parent = row,
	})
	round(track, 999)

	local fill = create("Frame", {
		BackgroundColor3 = theme.accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
		Parent = track,
	})
	round(fill, 999)

	local function setValue(v, fire)
		value = snap(v)
		valueLabel.Text = tostring(value) .. suffix
		local pct = (value - min) / (max - min)
		TweenService:Create(fill, TweenInfo.new(0.10, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.new(pct, 0, 1, 0),
		}):Play()
		if fire and typeof(opts.callback) == "function" then
			opts.callback(value)
		end
	end

	setValue(value, false)

	local dragging = false
	local function updateFromInput(input)
		local pos = input.Position.X
		local a = track.AbsolutePosition.X
		local w = track.AbsoluteSize.X
		local pct = math.clamp((pos - a) / w, 0, 1)
		local v = min + (max - min) * pct
		setValue(v, true)
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			updateFromInput(input)
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			updateFromInput(input)
		end
	end)

	return {
		Set = function(v)
			value = snap(v)
			valueLabel.Text = tostring(value) .. suffix
			local pct = (value - min) / (max - min)
			fill.Size = UDim2.new(pct, 0, 1, 0)
		end,
		Get = function()
			return value
		end,
	}
end

function Section:AddKeybind(text, defaultKey, callback)
	local theme = self._window.theme
	local row = create("Frame", {
		BackgroundColor3 = theme.panel2,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 32),
		Parent = self._holder,
	})
	round(row, 4)
	stroke(row, theme.stroke)

	local label = create("TextLabel", {
		BackgroundTransparency = 1,
		Text = tostring(text or "Keybind"),
		Font = Valkyrie.fonts.semibold,
		TextSize = 12,
		TextColor3 = theme.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(0.55, -10, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		Parent = row,
	})

	local current = defaultKey
	local btn = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = theme.panel3,
		BorderSizePixel = 0,
		Text = current and current.Name or "None",
		Font = Valkyrie.fonts.thin,
		TextSize = 12,
		TextColor3 = theme.text,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0.45, 0, 0, 24),
		Parent = row,
	})
	round(btn, 4)
	stroke(btn, theme.stroke)
	create("UIPadding", { PaddingLeft = UDim.new(0, 8), Parent = btn })

	local awaiting = false
	local function setKey(key, fireCallback)
		current = key
		btn.Text = current and current.Name or "None"
		if fireCallback and typeof(callback) == "function" then
			callback(current)
		end
	end

	btn.Activated:Connect(function()
		if awaiting then
			return
		end
		awaiting = true
		btn.Text = "Press key..."
		local conn
		conn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end
			if input.UserInputType == Enum.UserInputType.Keyboard then
				awaiting = false
				if conn then
					conn:Disconnect()
				end
				setKey(input.KeyCode, true)
			end
		end)
	end)

	return {
		Set = function(key)
			setKey(key, false)
		end,
		Get = function()
			return current
		end,
	}
end

function Section:AddDropdown(opts)
	opts = opts or {}
	local theme = self._window.theme
	local name = tostring(opts.name or opts.Name or "Dropdown")
	local items = opts.items or opts.Items or {}
	local default = opts.default or opts.Default
	local callback = opts.callback or opts.Callback
	local multi = (opts.multi == true) or (opts.Multi == true)
	local width = opts.width or 130

	local selected = default
	local selectedSet = {}
	local selectedList = {}
	local opened = false
	local optionInstances = {}

	if multi and typeof(default) == "table" then
		for _, v in ipairs(default) do
			local key = tostring(v)
			if not selectedSet[key] then
				selectedSet[key] = true
				table.insert(selectedList, key)
			end
		end
	end

	local row = create("Frame", {
		BackgroundColor3 = theme.panel2,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 32),
		Parent = self._holder,
	})
	round(row, 4)
	stroke(row, theme.stroke)

	local label = create("TextLabel", {
		BackgroundTransparency = 1,
		Text = name,
		Font = Valkyrie.fonts.semibold,
		TextSize = 12,
		TextColor3 = theme.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(0.4, -10, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		Parent = row,
	})

	local dropdownBtn = create("TextButton", {
		Name = "DropdownBtn",
		AutoButtonColor = false,
		BackgroundColor3 = theme.panel3,
		BorderSizePixel = 0,
		Font = Valkyrie.fonts.semibold,
		Text = multi and "Select" or (selected or "Select"),
		TextColor3 = theme.text,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Center,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0.6, 0, 0, 24),
		Parent = row,
	})
	round(dropdownBtn, 4)
	stroke(dropdownBtn, theme.stroke)

	dropdownBtn.MouseEnter:Connect(function()
		TweenService:Create(dropdownBtn, TweenInfo.new(0.1), {
			BackgroundColor3 = Color3.fromRGB(
				math.min(255, theme.panel3.R * 255 + 10),
				math.min(255, theme.panel3.G * 255 + 10),
				math.min(255, theme.panel3.B * 255 + 10)
			)
		}):Play()
	end)
	dropdownBtn.MouseLeave:Connect(function()
		TweenService:Create(dropdownBtn, TweenInfo.new(0.1), {
			BackgroundColor3 = theme.panel3
		}):Play()
	end)

	local indicator = create("TextLabel", {
		Name = "Indicator",
		BackgroundTransparency = 1,
		Text = "▼",
		Font = Valkyrie.fonts.bold,
		TextSize = 10,
		TextColor3 = theme.muted,
		TextXAlignment = Enum.TextXAlignment.Right,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -6, 0, 0),
		Size = UDim2.new(0, 16, 1, 0),
		Parent = dropdownBtn,
	})

	local dropdownHolder = create("Frame", {
		Name = "DropdownHolder",
		BackgroundColor3 = theme.panel2,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(0, 0),
		Visible = false,
		ClipsDescendants = true,
		ZIndex = 100,
		Parent = self._window._gui,
	})
	round(dropdownHolder, 4)
	stroke(dropdownHolder, theme.stroke)

	local outline = create("ScrollingFrame", {
		Name = "Outline",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = theme.accent,
		ScrollBarImageTransparency = 0.3,
		ClipsDescendants = true,
		ZIndex = 100,
		Parent = dropdownHolder,
	})
	create("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = outline })
	local outlineLayout = create("UIListLayout", {
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = outline,
	})
	outlineLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		outline.CanvasSize = UDim2.new(0, 0, 0, outlineLayout.AbsoluteContentSize.Y + 12)
	end)

	local function selectionText()
		if not multi then
			return selected or "Select"
		end
		if #selectedList == 0 then
			return "Select"
		end
		return table.concat(selectedList, ", ")
	end

	local function setSelected(value)
		if not multi then
			selected = value
			dropdownBtn.Text = selectionText()
			if typeof(callback) == "function" then
				callback(selected)
			end
			return
		end

		local key = tostring(value)
		local found = false
		for i, v in ipairs(selectedList) do
			if v == key then
				table.remove(selectedList, i)
				selectedSet[key] = nil
				found = true
				break
			end
		end

		if not found then
			table.insert(selectedList, key)
			selectedSet[key] = true
		end

		dropdownBtn.Text = selectionText()
		if typeof(callback) == "function" then
			callback(selectedList)
		end
	end

	local function setVisible(bool)
		if bool then
			dropdownHolder.Visible = true
			dropdownHolder.Position = UDim2.fromOffset(
				dropdownBtn.AbsolutePosition.X,
				dropdownBtn.AbsolutePosition.Y + dropdownBtn.AbsoluteSize.Y + 6
			)
		end

		local maxItems = math.min(6, #items)
		local targetSize = bool and math.min(220, maxItems * 34 + 16) or 0
		
		local sizeTween = TweenService:Create(dropdownHolder, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(dropdownBtn.AbsoluteSize.X, targetSize)
		})
		sizeTween:Play()
		
		TweenService:Create(indicator, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Rotation = bool and 180 or 0
		}):Play()

		if not bool then
			sizeTween.Completed:Connect(function()
				dropdownHolder.Visible = false
			end)
		end
	end

	local function renderOption(text)
		local button = create("TextButton", {
			Name = "OptionButton",
			AutoButtonColor = false,
			BackgroundColor3 = theme.panel3,
			BorderSizePixel = 0,
			Text = text,
			Font = Valkyrie.fonts.semibold,
			TextSize = 12,
			TextColor3 = theme.text,
			TextXAlignment = Enum.TextXAlignment.Center,
			Size = UDim2.new(1, 0, 0, 28),
			ZIndex = 100,
			Parent = outline,
		})
		round(button, 4)
		stroke(button, theme.stroke)

		button.MouseEnter:Connect(function()
			if button.BackgroundColor3 ~= theme.accent then
				TweenService:Create(button, TweenInfo.new(0.1), {
					BackgroundColor3 = Color3.fromRGB(
						math.min(255, theme.panel3.R * 255 + 15),
						math.min(255, theme.panel3.G * 255 + 15),
						math.min(255, theme.panel3.B * 255 + 15)
					)
				}):Play()
			end
		end)
		button.MouseLeave:Connect(function()
			if button.BackgroundColor3 ~= theme.accent then
				TweenService:Create(button, TweenInfo.new(0.1), {
					BackgroundColor3 = theme.panel3
				}):Play()
			end
		end)

		return button
	end

	local ySize = 0

	local function refreshOptions(list)
		ySize = 0
		for _, option in ipairs(optionInstances) do
			option:Destroy()
		end
		optionInstances = {}

		for _, option in ipairs(list) do
			local button = renderOption(option)
			ySize = ySize + button.AbsoluteSize.Y + 6
			table.insert(optionInstances, button)

			local isSelected = false
			if multi then
				isSelected = selectedSet[tostring(option)]
			else
				isSelected = (selected == option)
			end
			
			if isSelected then
				button.BackgroundColor3 = theme.accent
			else
				button.BackgroundColor3 = theme.panel2
			end

			button.Activated:Connect(function()
				if multi then
					setSelected(option)
					for _, btn in ipairs(optionInstances) do
						if selectedSet[tostring(btn.Text)] then
							btn.BackgroundColor3 = theme.accent
						else
							btn.BackgroundColor3 = theme.panel2
						end
					end
				else
					setSelected(option)
					setVisible(false)
					opened = false
					for _, btn in ipairs(optionInstances) do
						if btn.Text == option then
							btn.BackgroundColor3 = theme.accent
						else
							btn.BackgroundColor3 = theme.panel2
						end
					end
				end
			end)
		end
	end

	refreshOptions(items)
	if default then
		setSelected(default)
	end
	dropdownBtn.Text = selectionText()

	local api = {
		SetItems = function(newItems)
			items = newItems or {}
			refreshOptions(items)
		end,
		Set = function(v)
			if not multi then
				selected = v
				dropdownBtn.Text = selectionText()
				refreshOptions(items)
				return
			end
			selectedSet = {}
			selectedList = {}
			if typeof(v) == "table" then
				for _, it in ipairs(v) do
					local key = tostring(it)
					if not selectedSet[key] then
						selectedSet[key] = true
						table.insert(selectedList, key)
					end
				end
			end
			dropdownBtn.Text = selectionText()
			refreshOptions(items)
		end,
		Get = function()
			return multi and selectedList or selected
		end,
		Open = function()
			opened = true
			setVisible(true)
		end,
		Close = function()
			opened = false
			setVisible(false)
		end,
	}

	dropdownBtn.Activated:Connect(function()
		opened = not opened
		setVisible(opened)

		if opened then
			for _, dd in ipairs(self._window._dropdowns) do
				if dd and dd ~= api and dd.Close then
					dd.Close()
				end
			end
		end
	end)

	UserInputService.InputBegan:Connect(function(input)
		if not opened then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local pos = input.Position
			local inHolder = pos.X >= dropdownHolder.AbsolutePosition.X and pos.X <= dropdownHolder.AbsolutePosition.X + dropdownHolder.AbsoluteSize.X
				and pos.Y >= dropdownHolder.AbsolutePosition.Y and pos.Y <= dropdownHolder.AbsolutePosition.Y + dropdownHolder.AbsoluteSize.Y
			local inBtn = pos.X >= dropdownBtn.AbsolutePosition.X and pos.X <= dropdownBtn.AbsolutePosition.X + dropdownBtn.AbsoluteSize.X
				and pos.Y >= dropdownBtn.AbsolutePosition.Y and pos.Y <= dropdownBtn.AbsolutePosition.Y + dropdownBtn.AbsoluteSize.Y

			if not inHolder and not inBtn then
				setVisible(false)
				opened = false
			end
		end
	end)

	table.insert(self._window._dropdowns, api)
	return api
end

function Section:AddMultiDropdown(opts)
	local o = opts or {}
	o.multi = true
	if o.summary == nil and o.Summary == nil and o.showCount == nil and o.ShowCount == nil then
		o.summary = "count"
	end
	if o.search == nil and o.Search == nil then
		o.search = true
	end
	return self:AddDropdown(o)
end

function Section:AddColorpicker(opts)
	opts = opts or {}
	local theme = self._window.theme
	local name = tostring(opts.name or opts.Name or "Color")
	local default = opts.default or opts.Default or Color3.fromRGB(255, 255, 255)
	local callback = opts.callback or opts.Callback

	local h, s, v = default:ToHSV()
	local currentColor = default

	local row = create("Frame", {
		BackgroundColor3 = theme.panel2,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 32),
		Parent = self._holder,
	})
	round(row, 4)
	stroke(row, theme.stroke)

	local label = create("TextLabel", {
		BackgroundTransparency = 1,
		Text = name,
		Font = Valkyrie.fonts.semibold,
		TextSize = 12,
		TextColor3 = theme.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(0.55, -10, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		Parent = row,
	})

	local colorBox = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = currentColor,
		BorderSizePixel = 0,
		Text = "",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(40, 24),
		Parent = row,
	})
	round(colorBox, 4)
	stroke(colorBox, theme.stroke)

	local pickerFrame = create("Frame", {
		BackgroundColor3 = theme.panel,
		BorderSizePixel = 0,
		Size = UDim2.fromOffset(200, 230),
		Visible = false,
		ZIndex = 100,
		Parent = self._window._gui,
	})
	round(pickerFrame, 8)
	stroke(pickerFrame, theme.stroke)

	local saturationPicker = create("Frame", {
		BackgroundColor3 = Color3.fromHSV(h, 1, 1),
		BorderSizePixel = 0,
		Size = UDim2.new(1, -16, 0, 140),
		Position = UDim2.new(0, 8, 0, 8),
		Parent = pickerFrame,
	})
	round(saturationPicker, 6)

	local whiteCover = create("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = saturationPicker,
	})
	round(whiteCover, 6)
	create("UIGradient", {
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Parent = whiteCover,
	})

	local blackCover = create("Frame", {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = saturationPicker,
	})
	round(blackCover, 6)
	create("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0),
		}),
		Parent = blackCover,
	})

	local satButton = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = currentColor,
		BorderSizePixel = 0,
		Text = "",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(s, 0, 1 - v, 0),
		Size = UDim2.fromOffset(10, 10),
		ZIndex = 101,
		Parent = saturationPicker,
	})
	round(satButton, 999)
	stroke(satButton, Color3.fromRGB(255, 255, 255))

	local hueSlider = create("Frame", {
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Size = UDim2.new(1, -16, 0, 12),
		Position = UDim2.new(0, 8, 0, 156),
		Parent = pickerFrame,
	})
	round(hueSlider, 999)
	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
		}),
		Parent = hueSlider,
	})

	local hueButton = create("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = Color3.fromHSV(h, 1, 1),
		BorderSizePixel = 0,
		Text = "",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(h, 0, 0.5, 0),
		Size = UDim2.fromOffset(10, 10),
		ZIndex = 101,
		Parent = hueSlider,
	})
	round(hueButton, 999)
	stroke(hueButton, Color3.fromRGB(255, 255, 255))

	local rgbLabel = create("TextLabel", {
		BackgroundTransparency = 1,
		Text = string.format("RGB: %d, %d, %d", math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255)),
		Font = Valkyrie.fonts.thin,
		TextSize = 11,
		TextColor3 = theme.text,
		TextXAlignment = Enum.TextXAlignment.Center,
		Size = UDim2.new(1, 0, 0, 20),
		Position = UDim2.new(0, 0, 1, -30),
		Parent = pickerFrame,
	})

	local draggingSat = false
	local draggingHue = false

	local function updateColor()
		currentColor = Color3.fromHSV(h, s, v)
		colorBox.BackgroundColor3 = currentColor
		saturationPicker.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		satButton.BackgroundColor3 = currentColor
		hueButton.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
		rgbLabel.Text = string.format("RGB: %d, %d, %d", math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255))
		if typeof(callback) == "function" then
			callback(currentColor)
		end
	end

	saturationPicker.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSat = true
			local pos = input.Position
			local relX = math.clamp((pos.X - saturationPicker.AbsolutePosition.X) / saturationPicker.AbsoluteSize.X, 0, 1)
			local relY = math.clamp((pos.Y - saturationPicker.AbsolutePosition.Y) / saturationPicker.AbsoluteSize.Y, 0, 1)
			s = relX
			v = 1 - relY
			satButton.Position = UDim2.new(s, 0, 1 - v, 0)
			updateColor()
			input:GetPropertyChangedSignal("UserInputState"):Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					draggingSat = false
				end
			end)
		end
	end)

	hueSlider.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingHue = true
			local pos = input.Position
			local relX = math.clamp((pos.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
			h = relX
			hueButton.Position = UDim2.new(h, 0, 0.5, 0)
			updateColor()
			input:GetPropertyChangedSignal("UserInputState"):Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					draggingHue = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if draggingSat and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local pos = input.Position
			local relX = math.clamp((pos.X - saturationPicker.AbsolutePosition.X) / saturationPicker.AbsoluteSize.X, 0, 1)
			local relY = math.clamp((pos.Y - saturationPicker.AbsolutePosition.Y) / saturationPicker.AbsoluteSize.Y, 0, 1)
			s = relX
			v = 1 - relY
			satButton.Position = UDim2.new(s, 0, 1 - v, 0)
			updateColor()
		elseif draggingHue and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local pos = input.Position
			local relX = math.clamp((pos.X - hueSlider.AbsolutePosition.X) / hueSlider.AbsoluteSize.X, 0, 1)
			h = relX
			hueButton.Position = UDim2.new(h, 0, 0.5, 0)
			updateColor()
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSat = false
			draggingHue = false
		end
	end)

	colorBox.Activated:Connect(function()
		pickerFrame.Visible = not pickerFrame.Visible
		if pickerFrame.Visible then
			pickerFrame.Position = UDim2.fromOffset(
				colorBox.AbsolutePosition.X - 160,
				colorBox.AbsolutePosition.Y + 30
			)
		end
	end)

	UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if pickerFrame.Visible then
				local pos = input.Position
				local inPicker = pos.X >= pickerFrame.AbsolutePosition.X and pos.X <= pickerFrame.AbsolutePosition.X + pickerFrame.AbsoluteSize.X
					and pos.Y >= pickerFrame.AbsolutePosition.Y and pos.Y <= pickerFrame.AbsolutePosition.Y + pickerFrame.AbsoluteSize.Y
				local inButton = pos.X >= colorBox.AbsolutePosition.X and pos.X <= colorBox.AbsolutePosition.X + colorBox.AbsoluteSize.X
					and pos.Y >= colorBox.AbsolutePosition.Y and pos.Y <= colorBox.AbsolutePosition.Y + colorBox.AbsoluteSize.Y
				if not inPicker and not inButton then
					pickerFrame.Visible = false
				end
			end
		end
	end)

	return {
		Set = function(color)
			if typeof(color) == "Color3" then
				h, s, v = color:ToHSV()
				updateColor()
				satButton.Position = UDim2.new(s, 0, 1 - v, 0)
				hueButton.Position = UDim2.new(h, 0, 0.5, 0)
			end
		end,
		Get = function()
			return currentColor
		end,
	}
end

Valkyrie.new = function(_, opts)
	return Valkyrie:CreateWindow(opts)
end

return setmetatable(Valkyrie, Valkyrie)

