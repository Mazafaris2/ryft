--[[
  Slourite Packet
  Purple UI · solid title · small panel
  Instant stop · soft reconnect on disable

  + LPH anti-tamper stubs
  + Anti-GUI-copier (ghost name · Archivable=false · namecall hook · hidden root)
]]

-- =====================================================================
-- (1) LPH / LUARMOR ANTI-TAMPER STUBS (polsec / Luraph safe)
-- Same style as fixed SlouriteHub — no macro aliases.
-- =====================================================================
pcall(function()
	if rawget(_G, "LPH_OBFUSCATED") then
		return
	end
	local function _pass(x)
		return x
	end
	local function _passFn(f)
		return f
	end
	if type(rawget(_G, "LPH_ENCNUM")) ~= "function" then
		rawset(_G, "LPH_ENCNUM", function(n) return n end)
	end
	if type(rawget(_G, "LPH_NUMENC")) ~= "function" then
		rawset(_G, "LPH_NUMENC", function(n) return n end)
	end
	if type(rawget(_G, "LPH_ENCSTR")) ~= "function" then
		rawset(_G, "LPH_ENCSTR", function(s) return s end)
	end
	if type(rawget(_G, "LPH_STRENC")) ~= "function" then
		rawset(_G, "LPH_STRENC", function(s) return s end)
	end
	if type(rawget(_G, "LPH_ENCFUNC")) ~= "function" then
		rawset(_G, "LPH_ENCFUNC", function(f) return f end)
	end
	if type(rawget(_G, "LPH_FUNCENC")) ~= "function" then
		rawset(_G, "LPH_FUNCENC", function(f) return f end)
	end
	if type(rawget(_G, "LPH_JIT")) ~= "function" then
		rawset(_G, "LPH_JIT", _passFn)
	end
	if type(rawget(_G, "LPH_JIT_MAX")) ~= "function" then
		rawset(_G, "LPH_JIT_MAX", _passFn)
	end
	if type(rawget(_G, "LPH_NO_VIRTUALIZE")) ~= "function" then
		rawset(_G, "LPH_NO_VIRTUALIZE", _passFn)
	end
	if type(rawget(_G, "LPH_NO_UPVALUES")) ~= "function" then
		rawset(_G, "LPH_NO_UPVALUES", _passFn)
	end
	if type(rawget(_G, "LPH_CRASH")) ~= "function" then
		rawset(_G, "LPH_CRASH", function() return nil end)
	end
end)

pcall(function()
	if type(rawget(_G, "LRM_INIT_SCRIPT")) ~= "function" then
		rawset(_G, "LRM_INIT_SCRIPT", function(f)
			if type(f) == "function" then return f() end
		end)
	end
end)

pcall(function()
	if getgenv then getgenv().__SLPACKET_LUARMOR = true end
end)

-- =====================================================================
-- (2) IMPORTS
-- =====================================================================
local UIS = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local LP = Players.LocalPlayer
local playerGui = LP:WaitForChild("PlayerGui", 10)

local CONFIG_FILE = "SlouritePacket_Config.json"

local config = {
	keybindKb = "G",
	keybindGp = "ButtonR2",
	power = 8000,
	posX = nil,
	posY = nil,
	posXS = 0.5,
	posYS = 0.5,
}

local function saveConfig()
	if writefile then
		pcall(function()
			writefile(CONFIG_FILE, HttpService:JSONEncode(config))
		end)
	end
end

pcall(function()
	if isfile and readfile and isfile(CONFIG_FILE) then
		local ok, data = pcall(function()
			return HttpService:JSONDecode(readfile(CONFIG_FILE))
		end)
		if ok and type(data) == "table" then
			if type(data.keybindKb) == "string" then config.keybindKb = data.keybindKb end
			if type(data.keybindGp) == "string" then config.keybindGp = data.keybindGp end
			if tonumber(data.power) then
				config.power = math.clamp(math.floor(data.power), 1, 100000)
			end
			local px, py = tonumber(data.posX), tonumber(data.posY)
			if px and py and px > 10 and py > 10 then
				config.posX, config.posY = px, py
				config.posXS = tonumber(data.posXS) or 0
				config.posYS = tonumber(data.posYS) or 0
			end
		end
	end
end)

local PURPLE = Color3.fromRGB(160, 90, 255)
local PURPLE2 = Color3.fromRGB(110, 60, 220)
local PURPLE_SOFT = Color3.fromRGB(200, 160, 255)
local BG = Color3.fromRGB(12, 8, 18)
local CARD = Color3.fromRGB(28, 20, 42)
local WHITE = Color3.fromRGB(245, 240, 255)
local DIM = Color3.fromRGB(150, 130, 175)
local GREEN = Color3.fromRGB(90, 230, 160)
local RED = Color3.fromRGB(255, 95, 115)
local WAIT = Color3.fromRGB(255, 210, 90)
local CYAN = Color3.fromRGB(100, 220, 255)

-- Clean previous runs (both by name AND by stored reference, since the
-- anti-copier renames our GUI to a ghost name).
if getgenv and getgenv().__SlouritePacketScreen then
	pcall(function() getgenv().__SlouritePacketScreen:Destroy() end)
	getgenv().__SlouritePacketScreen = nil
end
pcall(function()
	for _, root in ipairs({ playerGui, CoreGui }) do
		if root then
			for _, n in ipairs({ "SlouritePacket", "IceHubLaggerOmahad", "ZeyHubbPingLagger" }) do
				local o = root:FindFirstChild(n)
				if o then o:Destroy() end
			end
		end
	end
	pcall(function()
		if gethui then
			local h = gethui()
			local o = h:FindFirstChild("SlouritePacket")
			if o then o:Destroy() end
		end
	end)
end)

local function corner(p, r)
	Instance.new("UICorner", p).CornerRadius = UDim.new(0, r or 12)
end

local function stroke(p, col, th, tr)
	local s = Instance.new("UIStroke", p)
	s.Color = col or PURPLE
	s.Thickness = th or 1.3
	s.Transparency = tr or 0.25
	return s
end

local function bindTap(btn, fn)
	btn.Active = true
	local last = 0
	local function fire()
		local now = os.clock()
		if now - last < 0.12 then return end
		last = now
		fn()
	end
	btn.MouseButton1Click:Connect(fire)
	btn.Activated:Connect(fire)
end

local function isGamepad(kc)
	local n = kc.Name
	return n:sub(1, 6) == "Button" or n:sub(1, 10) == "Thumbstick" or n:sub(1, 4) == "DPad"
end

local function resolveKey(name)
	if not name or name == "" or name == "None" then return nil end
	local ok, k = pcall(function() return Enum.KeyCode[name] end)
	return ok and k or nil
end

local Event
local function resolveEvent()
	local ok, net = pcall(function()
		return RS:WaitForChild("Packages", 4):WaitForChild("Net", 4)
	end)
	if ok and net then
		local kids = net:GetChildren()
		if kids[230] and kids[230]:IsA("RemoteEvent") then return kids[230] end
		for i = #kids, 1, -1 do
			if kids[i]:IsA("RemoteEvent") then return kids[i] end
		end
	end
	return nil
end
Event = resolveEvent()

-- =====================================================================
-- (3) ANTI GUI COPIER
-- Installed once per session. Protects whatever GUI is passed to
-- __YEN.protect(). Light 2s scan (not per-frame) so no FPS impact.
-- =====================================================================
local CoreGuiSvc = game:GetService("CoreGui")

local function _gethui()
	local candidates = {}
	pcall(function()
		if type(gethui) == "function" then table.insert(candidates, gethui) end
	end)
	pcall(function()
		if type(getgenv) == "function" then
			local g = getgenv()
			if g and type(g.gethui) == "function" then table.insert(candidates, g.gethui) end
		end
	end)
	pcall(function()
		if type(_G.gethui) == "function" then table.insert(candidates, _G.gethui) end
	end)
	for _, fn in ipairs(candidates) do
		local ok, v = pcall(fn)
		if ok and v ~= nil then return v end
	end
	return CoreGuiSvc
end
local GuiRoot = _gethui()

if not (getgenv and getgenv().__yenAntiGui) then
	if getgenv then getgenv().__yenAntiGui = true end

	local ZWS = {"\u{200B}", "\u{200C}", "\u{200D}", "\u{FEFF}", "\u{2060}"}
	local protected = {}
	local hiddenRoot = nil

	local function ghost()
		local s = ""
		for _ = 1, 16 + math.random(0, 8) do
			s = s .. ZWS[math.random(#ZWS)]
		end
		return s
	end

	local function mark(inst)
		if not inst then return end
		protected[inst] = true
		pcall(function() inst.Archivable = false end)
		pcall(function()
			for _, d in ipairs(inst:GetDescendants()) do
				protected[d] = true
				pcall(function() d.Archivable = false end)
			end
		end)
	end

	-- namecall hook: blocks GetChildren / GetDescendants / Clone /
	-- FindFirstChild* on protected instances. Install once.
	local function installNamecallHook()
		local getrawmetatable   = getrawmetatable or (getgenv and getgenv().getrawmetatable)
		local setreadonly       = setreadonly or (getgenv and getgenv().setreadonly)
		local getreadonly       = getreadonly or (getgenv and getgenv().getreadonly)
		local getnamecallmethod = getnamecallmethod or (getgenv and getgenv().getnamecallmethod)
		local newcclosure       = newcclosure or (getgenv and getgenv().newcclosure)

		if type(getrawmetatable) ~= "function"
			or type(getnamecallmethod) ~= "function" then
			return false
		end

		local ok, mt = pcall(getrawmetatable, game)
		if not ok or not mt then return false end

		local old = mt.__namecall
		local wasReadOnly = false
		pcall(function()
			if type(getreadonly) == "function" then wasReadOnly = getreadonly(mt) end
		end)
		pcall(function()
			if type(setreadonly) == "function" then setreadonly(mt, false) end
		end)

		local hook = function(self, ...)
			if protected[self] then
				local m = getnamecallmethod()
				-- same as SlouriteHub: only block Clone (GetChildren/FindFirstChild break UI)
				if m == "Clone" then
					return nil
				end
			end
			return old(self, ...)
		end
		if type(newcclosure) == "function" then
			hook = newcclosure(hook)
		end
		mt.__namecall = hook

		pcall(function()
			if type(setreadonly) == "function" then setreadonly(mt, wasReadOnly) end
		end)
		return true
	end

	installNamecallHook()

	local function antiRoot()
		if hiddenRoot and hiddenRoot.Parent then return hiddenRoot end
		local f = Instance.new("Folder")
		f.Name = ghost()
		pcall(function() f.Parent = GuiRoot end)
		if not f.Parent then
			pcall(function() f.Parent = CoreGuiSvc end)
		end
		hiddenRoot = f
		mark(f)
		return f
	end

	local function protectGui(gui)
		if not gui or protected[gui] then return end

		local viaExecutor = false
		pcall(function()
			if syn and syn.protect_gui then
				viaExecutor = syn.protect_gui(gui) ~= false
			end
		end)
		pcall(function()
			if type(protect_gui) == "function" then
				protect_gui(gui); viaExecutor = true
			end
		end)

		mark(gui)
		pcall(function() gui.Name = ghost() end)
		pcall(function() gui.Enabled = true end)

		if not viaExecutor then
			pcall(function() gui.Parent = antiRoot() end)
		end

		pcall(function()
			gui.DescendantAdded:Connect(function(d)
				protected[d] = true
				pcall(function() d.Archivable = false end)
			end)
		end)
	end

	-- Light scan: catch foreign disabled GUIs (dumper trick).
	-- Runs every 2s — intentionally NOT every frame (no FPS impact).
	task.spawn(function()
		while true do
			task.wait(2)
			pcall(function()
				for _, g in ipairs(GuiRoot:GetChildren()) do
					if g:IsA("ScreenGui")
						and not protected[g]
						and g.Enabled == false then
						protectGui(g)
					end
				end
			end)
		end
	end)

	if getgenv then
		getgenv().__YEN = {
			protect    = protectGui,
			antiRoot   = antiRoot,
			antiTamper = function() return installNamecallHook() end,
			unprotect  = function(gui)
				if not gui then return end
				protected[gui] = nil
				pcall(function()
					for _, d in ipairs(gui:GetDescendants()) do
						protected[d] = nil
					end
				end)
			end,
		}
	end
end

-- Legacy aliases for the previously-built integrations (harmless if unused)
do
	getgenv = getgenv or function() return _G end
	if not getgenv().__yenProtectGui then
		getgenv().__yenProtectGui = function(gui)
			pcall(function()
				local api = getgenv().__YEN
				if api and api.protect then api.protect(gui) end
			end)
		end
	end
	if not getgenv().__yenAntiRoot then
		getgenv().__yenAntiRoot = function()
			local api = getgenv().__YEN
			return api and api.antiRoot and api.antiRoot()
		end
	end
end

-- =====================================================================
-- (4) STATE
-- =====================================================================
local active = false
local recovering = false
local lagThread = nil
local lagGen = 0
local payload = nil
local payloadPower = 0

local function getPayload(power)
	power = math.clamp(math.floor(tonumber(power) or 8000), 1, 100000)
	if payload and payloadPower == power then return payload end
	payload = table.create(power, function() end)
	payloadPower = power
	return payload
end

local function stopLagThreads()
	lagGen += 1
	active = false
	if lagThread then
		pcall(task.cancel, lagThread)
		lagThread = nil
	end
end

local function softRecover()
	if recovering then return end
	recovering = true
	stopLagThreads()
	payload = nil
	payloadPower = 0
	pcall(function() settings().Network.IncomingReplicationLag = 0 end)
	pcall(function()
		local nc = game:FindService("NetworkClient")
		if nc and nc.SetOutgoingKBPSLimit then nc:SetOutgoingKBPSLimit(math.huge) end
	end)
	task.wait(0.05)
	pcall(function() RunService.Heartbeat:Wait() end)
	task.wait(0.1)
	recovering = false
end

local function startLag()
	if active or recovering then return active end
	if not Event then Event = resolveEvent() end
	if not Event then return false end
	stopLagThreads()
	active = true
	local myGen = lagGen
	local data = getPayload(config.power)
	lagThread = task.spawn(function()
		while active and lagGen == myGen do
			for _ = 1, 3 do
				if not active or lagGen ~= myGen then break end
				pcall(function() Event:FireServer(data) end)
			end
			task.wait(0.01)
		end
	end)
	return true
end

local function stopLag()
	stopLagThreads()
	task.spawn(softRecover)
end

local listeningFor = nil
local settingsOpen = false

-- =====================================================================
-- (5) SCREEN
-- =====================================================================
local screen = Instance.new("ScreenGui")
screen.Name = "SlouritePacket"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.DisplayOrder = 999999
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.Enabled = true
pcall(function()
	if syn and syn.protect_gui then syn.protect_gui(screen) end
	if gethui then screen.Parent = gethui() end
end)
if not screen.Parent then pcall(function() screen.Parent = CoreGui end) end
if not screen.Parent and playerGui then screen.Parent = playerGui end
if not screen.Parent then screen.Parent = LP:WaitForChild("PlayerGui") end

-- PROTECT THE GUI (ghost name + Archivable=false + namecall hook)
if getgenv then
	pcall(function()
		if getgenv().__YEN and getgenv().__YEN.protect then
			getgenv().__YEN.protect(screen)
		end
	end)
	pcall(function() getgenv().__SlouritePacketScreen = screen end)
end

local MAIN_W, MAIN_H = 228, 118
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(MAIN_W, MAIN_H)
main.BackgroundColor3 = BG
main.BorderSizePixel = 0
main.Active = true
main.Visible = true
main.ClipsDescendants = true
main.Parent = screen
corner(main, 14)
stroke(main, PURPLE, 1.4, 0.2)

local mainGrad = Instance.new("UIGradient", main)
mainGrad.Rotation = 135
mainGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 14, 34)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 6, 16)),
})

do
	local cam = workspace.CurrentCamera
	local vs = (cam and cam.ViewportSize) or Vector2.new(1280, 720)
	local ox, oy = tonumber(config.posX), tonumber(config.posY)
	local xs, ys = tonumber(config.posXS), tonumber(config.posYS)
	local valid = ox and oy and ox > 10 and oy > 10 and ox < (vs.X - 40) and oy < (vs.Y - 40)
	if valid then
		main.Position = UDim2.new(xs or 0, ox, ys or 0, oy)
	else
		main.Position = UDim2.new(0.5, -MAIN_W / 2, 0.5, -MAIN_H / 2)
	end
end

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundTransparency = 1
header.Active = true
header.ZIndex = 5

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1, -90, 0, 18)
title.Position = UDim2.fromOffset(12, 6)
title.BackgroundTransparency = 1
title.Text = "Slourite Packet"
title.TextColor3 = PURPLE_SOFT
title.Font = Enum.Font.GothamBlack
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 6
Instance.new("UIGradient", title).Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 160, 255)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 100, 255)),
})

local sub = Instance.new("TextLabel", header)
sub.Size = UDim2.new(1, -90, 0, 14)
sub.Position = UDim2.fromOffset(12, 22)
sub.BackgroundTransparency = 1
sub.Text = Event and "packet lagger" or "no event found"
sub.TextColor3 = Event and DIM or WAIT
sub.Font = Enum.Font.Gotham
sub.TextSize = 10
sub.TextXAlignment = Enum.TextXAlignment.Left
sub.ZIndex = 6

local statusPill = Instance.new("Frame", header)
statusPill.Size = UDim2.fromOffset(58, 22)
statusPill.Position = UDim2.new(1, -92, 0.5, -11)
statusPill.BackgroundColor3 = CARD
statusPill.BorderSizePixel = 0
statusPill.ZIndex = 6
corner(statusPill, 10)
stroke(statusPill, PURPLE2, 1, 0.35)

local statusLabel = Instance.new("TextLabel", statusPill)
statusLabel.Size = UDim2.fromScale(1, 1)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "OFF"
statusLabel.TextColor3 = DIM
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 10
statusLabel.ZIndex = 7

local settingsBtn = Instance.new("TextButton", header)
settingsBtn.Size = UDim2.fromOffset(26, 26)
settingsBtn.Position = UDim2.new(1, -32, 0.5, -13)
settingsBtn.BackgroundColor3 = CARD
settingsBtn.Text = "⚙"
settingsBtn.TextColor3 = PURPLE_SOFT
settingsBtn.Font = Enum.Font.GothamBold
settingsBtn.TextSize = 13
settingsBtn.AutoButtonColor = false
settingsBtn.ZIndex = 7
corner(settingsBtn, 8)
stroke(settingsBtn, PURPLE2, 1, 0.35)

local activateBtn = Instance.new("TextButton", main)
activateBtn.Size = UDim2.new(1, -20, 0, 34)
activateBtn.Position = UDim2.fromOffset(10, 46)
activateBtn.BackgroundColor3 = Color3.fromRGB(110, 60, 200)
activateBtn.BorderSizePixel = 0
activateBtn.Text = "INACTIVE"
activateBtn.TextColor3 = WHITE
activateBtn.Font = Enum.Font.GothamBlack
activateBtn.TextSize = 13
activateBtn.AutoButtonColor = false
activateBtn.Active = true
activateBtn.ZIndex = 8
corner(activateBtn, 10)
stroke(activateBtn, PURPLE, 1.3, 0.25)

local actGrad = Instance.new("UIGradient", activateBtn)
actGrad.Rotation = 90
actGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 30, 80)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(28, 18, 48)),
})

local infoLabel = Instance.new("TextLabel", main)
infoLabel.Size = UDim2.new(1, -20, 0, 20)
infoLabel.Position = UDim2.fromOffset(10, 86)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "power " .. tostring(config.power)
infoLabel.TextColor3 = DIM
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 10
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.ZIndex = 6

local function refreshInfo()
	local ping = ""
	pcall(function()
		local item = Stats.Network.ServerStatsItem["Data Ping"]
		if item then ping = " · " .. math.floor(item:GetValue()) .. "ms" end
	end)
	infoLabel.Text = "power " .. tostring(config.power) .. ping
end

local function setUI(on, recoveringState)
	if recoveringState then
		activateBtn.Text = "RECOVERING..."
		statusLabel.Text = "..."
		statusLabel.TextColor3 = CYAN
		statusPill.BackgroundColor3 = Color3.fromRGB(20, 40, 55)
		actGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 70, 100)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 40, 60)),
		})
		sub.Text = "flushing connection"
		sub.TextColor3 = CYAN
		return
	end
	if on then
		activateBtn.Text = "ACTIVE"
		statusLabel.Text = "ON"
		statusLabel.TextColor3 = GREEN
		statusPill.BackgroundColor3 = Color3.fromRGB(25, 50, 35)
		actGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 90, 60)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 55, 40)),
		})
		sub.Text = "packet lagger"
		sub.TextColor3 = GREEN
	else
		activateBtn.Text = "INACTIVE"
		statusLabel.Text = "OFF"
		statusLabel.TextColor3 = DIM
		statusPill.BackgroundColor3 = CARD
		actGrad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(130, 70, 230)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 45, 180)),
		})
		sub.Text = Event and "packet lagger" or "no event found"
		sub.TextColor3 = Event and DIM or WAIT
	end
	refreshInfo()
end

local function flip()
	if recovering then return end
	if active then
		setUI(false, true)
		stopLag()
		task.spawn(function()
			local t0 = os.clock()
			while recovering and os.clock() - t0 < 2 do task.wait(0.05) end
			setUI(false, false)
		end)
	else
		if startLag() then
			setUI(true, false)
		else
			activateBtn.Text = "NO EVENT"
			sub.Text = "remote not found"
			sub.TextColor3 = WAIT
			task.delay(1, function()
				if not active then setUI(false, false) end
			end)
		end
	end
end

bindTap(activateBtn, flip)

local dragging, dragStart, startPos
header.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = i.Position
		startPos = main.Position
	end
end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		if dragging then
			dragging = false
			config.posX = main.Position.X.Offset
			config.posY = main.Position.Y.Offset
			config.posXS = main.Position.X.Scale
			config.posYS = main.Position.Y.Scale
			saveConfig()
		end
	end
end)
UIS.InputChanged:Connect(function(i)
	if not dragging then return end
	if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
		local d = i.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
end)

local SET_W, SET_H = 210, 270
local settings = Instance.new("Frame")
settings.Name = "Settings"
settings.Size = UDim2.fromOffset(SET_W, SET_H)
settings.Position = UDim2.new(0.5, -SET_W / 2, 0.5, -SET_H / 2)
settings.BackgroundColor3 = BG
settings.BorderSizePixel = 0
settings.Visible = false
settings.Active = true
settings.ClipsDescendants = true
settings.ZIndex = 40
settings.Parent = screen
corner(settings, 14)
stroke(settings, PURPLE, 1.4, 0.2)
Instance.new("UIGradient", settings).Rotation = 140
settings:FindFirstChildOfClass("UIGradient").Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 14, 34)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 6, 16)),
})

local sHeader = Instance.new("Frame", settings)
sHeader.Size = UDim2.new(1, 0, 0, 36)
sHeader.BackgroundTransparency = 1
sHeader.Active = true
sHeader.ZIndex = 41

local sTitle = Instance.new("TextLabel", sHeader)
sTitle.Size = UDim2.new(1, -40, 1, 0)
sTitle.Position = UDim2.fromOffset(12, 0)
sTitle.BackgroundTransparency = 1
sTitle.Text = "SETTINGS"
sTitle.TextColor3 = PURPLE_SOFT
sTitle.Font = Enum.Font.GothamBlack
sTitle.TextSize = 13
sTitle.TextXAlignment = Enum.TextXAlignment.Left
sTitle.ZIndex = 42

local sClose = Instance.new("TextButton", sHeader)
sClose.Size = UDim2.fromOffset(24, 24)
sClose.Position = UDim2.new(1, -32, 0.5, -12)
sClose.BackgroundColor3 = CARD
sClose.Text = "✕"
sClose.TextColor3 = PURPLE_SOFT
sClose.Font = Enum.Font.GothamBold
sClose.TextSize = 12
sClose.AutoButtonColor = false
sClose.ZIndex = 42
corner(sClose, 7)

local function openSettings() settingsOpen = true; settings.Visible = true end
local function closeSettings() settingsOpen = false; listeningFor = nil; settings.Visible = false end
bindTap(settingsBtn, function() if settingsOpen then closeSettings() else openSettings() end end)
bindTap(sClose, closeSettings)

local y = 42
local function label(text, yy)
	local l = Instance.new("TextLabel", settings)
	l.Size = UDim2.new(1, -20, 0, 14)
	l.Position = UDim2.fromOffset(12, yy)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = DIM
	l.Font = Enum.Font.GothamBold
	l.TextSize = 10
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.ZIndex = 42
end

label("CHANGE POWER", y)
y = y + 16

local powerBox = Instance.new("TextBox", settings)
powerBox.Size = UDim2.new(1, -76, 0, 28)
powerBox.Position = UDim2.fromOffset(12, y)
powerBox.BackgroundColor3 = CARD
powerBox.BorderSizePixel = 0
powerBox.Text = tostring(config.power)
powerBox.Font = Enum.Font.GothamBold
powerBox.TextSize = 13
powerBox.TextColor3 = PURPLE_SOFT
powerBox.ClearTextOnFocus = false
powerBox.ZIndex = 42
corner(powerBox, 8)
stroke(powerBox, PURPLE2, 1, 0.4)

local function applyPower(v)
	config.power = math.clamp(math.floor(tonumber(v) or config.power), 1, 100000)
	powerBox.Text = tostring(config.power)
	payload = nil
	payloadPower = 0
	if active then
		stopLagThreads()
		active = false
		startLag()
		setUI(true, false)
	end
	refreshInfo()
	saveConfig()
end
powerBox.FocusLost:Connect(function() applyPower(powerBox.Text) end)

local minus = Instance.new("TextButton", settings)
minus.Size = UDim2.fromOffset(28, 28)
minus.Position = UDim2.new(1, -64, 0, y)
minus.BackgroundColor3 = CARD
minus.Text = "−"
minus.TextColor3 = WHITE
minus.Font = Enum.Font.GothamBlack
minus.TextSize = 14
minus.AutoButtonColor = false
minus.ZIndex = 42
corner(minus, 8)
bindTap(minus, function() applyPower(config.power - 1000) end)

local plus = Instance.new("TextButton", settings)
plus.Size = UDim2.fromOffset(28, 28)
plus.Position = UDim2.new(1, -32, 0, y)
plus.BackgroundColor3 = CARD
plus.Text = "+"
plus.TextColor3 = WHITE
plus.Font = Enum.Font.GothamBlack
plus.TextSize = 14
plus.AutoButtonColor = false
plus.ZIndex = 42
corner(plus, 8)
bindTap(plus, function() applyPower(config.power + 1000) end)

y = y + 34
for i, p in ipairs({ { "1K", 1000 }, { "8K", 8000 }, { "15K", 15000 }, { "25K", 25000 } }) do
	local b = Instance.new("TextButton", settings)
	b.Size = UDim2.fromOffset(42, 24)
	b.Position = UDim2.fromOffset(12 + (i - 1) * 48, y)
	b.BackgroundColor3 = CARD
	b.Text = p[1]
	b.TextColor3 = PURPLE_SOFT
	b.Font = Enum.Font.GothamBold
	b.TextSize = 10
	b.AutoButtonColor = false
	b.ZIndex = 42
	corner(b, 7)
	bindTap(b, function() applyPower(p[2]) end)
end

y = y + 32
label("KEYBOARD KEYBIND", y)
y = y + 16
local kbBtn = Instance.new("TextButton", settings)
kbBtn.Size = UDim2.new(1, -48, 0, 28)
kbBtn.Position = UDim2.fromOffset(12, y)
kbBtn.BackgroundColor3 = CARD
kbBtn.Text = config.keybindKb
kbBtn.TextColor3 = WHITE
kbBtn.Font = Enum.Font.GothamBold
kbBtn.TextSize = 12
kbBtn.AutoButtonColor = false
kbBtn.ZIndex = 42
corner(kbBtn, 8)
stroke(kbBtn, PURPLE2, 1, 0.4)

local kbClear = Instance.new("TextButton", settings)
kbClear.Size = UDim2.fromOffset(28, 28)
kbClear.Position = UDim2.new(1, -32, 0, y)
kbClear.BackgroundColor3 = Color3.fromRGB(50, 22, 28)
kbClear.Text = "X"
kbClear.TextColor3 = RED
kbClear.Font = Enum.Font.GothamBlack
kbClear.TextSize = 11
kbClear.AutoButtonColor = false
kbClear.ZIndex = 42
corner(kbClear, 8)

y = y + 36
label("CONTROLLER KEYBIND", y)
y = y + 16
local gpBtn = Instance.new("TextButton", settings)
gpBtn.Size = UDim2.new(1, -48, 0, 28)
gpBtn.Position = UDim2.fromOffset(12, y)
gpBtn.BackgroundColor3 = CARD
gpBtn.Text = config.keybindGp
gpBtn.TextColor3 = WHITE
gpBtn.Font = Enum.Font.GothamBold
gpBtn.TextSize = 11
gpBtn.AutoButtonColor = false
gpBtn.ZIndex = 42
corner(gpBtn, 8)
stroke(gpBtn, PURPLE2, 1, 0.4)

local gpClear = Instance.new("TextButton", settings)
gpClear.Size = UDim2.fromOffset(28, 28)
gpClear.Position = UDim2.new(1, -32, 0, y)
gpClear.BackgroundColor3 = Color3.fromRGB(50, 22, 28)
gpClear.Text = "X"
gpClear.TextColor3 = RED
gpClear.Font = Enum.Font.GothamBlack
gpClear.TextSize = 11
gpClear.AutoButtonColor = false
gpClear.ZIndex = 42
corner(gpClear, 8)

local function updateBindLabels()
	if listeningFor == "kb" then kbBtn.Text = "..."; kbBtn.TextColor3 = WAIT
	else kbBtn.Text = config.keybindKb; kbBtn.TextColor3 = WHITE end
	if listeningFor == "gp" then gpBtn.Text = "..."; gpBtn.TextColor3 = WAIT
	else gpBtn.Text = config.keybindGp; gpBtn.TextColor3 = WHITE end
end

bindTap(kbBtn, function() listeningFor = (listeningFor == "kb") and nil or "kb"; updateBindLabels() end)
bindTap(gpBtn, function() listeningFor = (listeningFor == "gp") and nil or "gp"; updateBindLabels() end)
bindTap(kbClear, function() config.keybindKb = "None"; listeningFor = nil; updateBindLabels(); saveConfig() end)
bindTap(gpClear, function() config.keybindGp = "None"; listeningFor = nil; updateBindLabels(); saveConfig() end)

do
	local d, s, p
	sHeader.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			d = true; s = i.Position; p = settings.Position
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = false end
	end)
	UIS.InputChanged:Connect(function(i)
		if not d then return end
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
			local delta = i.Position - s
			settings.Position = UDim2.new(p.X.Scale, p.X.Offset + delta.X, p.Y.Scale, p.Y.Offset + delta.Y)
		end
	end)
end

UIS.InputBegan:Connect(function(input, gpe)
	local kc = input.KeyCode
	if kc == Enum.KeyCode.Unknown then return end
	local isGp = isGamepad(kc)
	local isKb = input.UserInputType == Enum.UserInputType.Keyboard
	if listeningFor then
		if kc == Enum.KeyCode.Escape then listeningFor = nil; updateBindLabels(); return end
		if listeningFor == "kb" and isKb and kc ~= Enum.KeyCode.LeftControl then
			config.keybindKb = kc.Name; listeningFor = nil; updateBindLabels(); saveConfig(); return
		end
		if listeningFor == "gp" and isGp then
			config.keybindGp = kc.Name; listeningFor = nil; updateBindLabels(); saveConfig(); return
		end
		return
	end
	if gpe then return end
	if kc == Enum.KeyCode.LeftControl then
		main.Visible = not main.Visible
		if not main.Visible then closeSettings() end
		return
	end
	local kb = resolveKey(config.keybindKb)
	local gp = resolveKey(config.keybindGp)
	if (kb and kc == kb and isKb) or (gp and kc == gp and isGp) then flip() end
end)

task.spawn(function()
	while screen.Parent do
		if main.Visible then refreshInfo() end
		task.wait(1)
	end
end)

setUI(false, false)
main.Visible = true
screen.Enabled = true
