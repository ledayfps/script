--[[
	DRAGON ADMIN v8
	Largo + 2 colunas + mais opções
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TS = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local Http = game:GetService("HttpService")
local VIM = game:GetService("VirtualInputManager")

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()
local cam = workspace.CurrentCamera
local char, hum, root

local function upd()
	char = lp.Character
	if char then
		hum = char:FindFirstChildOfClass("Humanoid")
		root = char:FindFirstChild("HumanoidRootPart")
	end
end
upd()

local flySpeed, walkSpeed, jumpPower, savedCF = 60, 16, 50, nil
local flying, noclip, infJump, fb, invis, god = false, false, false, false, false, false
local clickTP, espOn, spinOn, afkOn, autoClick, clickFling = false, false, false, false, false, false
local antiFling, rainbow, xray, clickDel, blurOff = false, false, false, false, false
local bv, bg, goingUp, goingDown = nil, nil, false, false
local nC, gC, sC, aC, cC, afC, rC
local flinging = false

local THEME = Color3.fromRGB(175, 52, 72)
local SIDE = Color3.fromRGB(26, 18, 30)
local ON = Color3.fromRGB(40, 145, 82)
local OFF = Color3.fromRGB(46, 30, 40)

local function note(t)
	pcall(function()
		StarterGui:SetCore("SendNotification", {Title = "🐉 Dragon", Text = t, Duration = 2})
	end)
end

local gui = Instance.new("ScreenGui")
gui.Name = "DragonAdmin"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = lp:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 620, 0, 300)
main.Position = UDim2.new(0.5, -310, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(13, 10, 18)
main.BackgroundTransparency = 0.04
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)

local stroke = Instance.new("UIStroke")
stroke.Color = THEME
stroke.Thickness = 1.5
stroke.Transparency = 0.25
stroke.Parent = main

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 34)
header.BackgroundColor3 = Color3.fromRGB(24, 14, 22)
header.BorderSizePixel = 0
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -48, 1, 0)
title.Position = UDim2.new(0, 14, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🐉  DRAGON ADMIN"
title.TextColor3 = Color3.fromRGB(255, 210, 195)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -32, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(175, 42, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 7)

local side = Instance.new("ScrollingFrame")
side.Size = UDim2.new(0, 108, 1, -80)
side.Position = UDim2.new(0, 8, 0, 40)
side.BackgroundColor3 = Color3.fromRGB(18, 13, 24)
side.BorderSizePixel = 0
side.ScrollBarThickness = 3
side.AutomaticCanvasSize = Enum.AutomaticSize.Y
side.CanvasSize = UDim2.new(0, 0, 0, 0)
side.Parent = main
Instance.new("UICorner", side).CornerRadius = UDim.new(0, 12)
local sLay = Instance.new("UIListLayout")
sLay.Padding = UDim.new(0, 7)
sLay.Parent = side
local sPad = Instance.new("UIPadding")
sPad.PaddingTop = UDim.new(0, 8)
sPad.PaddingBottom = UDim.new(0, 8)
sPad.PaddingLeft = UDim.new(0, 7)
sPad.PaddingRight = UDim.new(0, 7)
sPad.Parent = side

local function tabBtn(text)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 28)
	b.BackgroundColor3 = SIDE
	b.Text = text
	b.TextColor3 = Color3.fromRGB(205, 185, 192)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 12
	b.Parent = side
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
	return b
end

local tabs = {
	Main = tabBtn("Main"),
	Move = tabBtn("Move"),
	Teleport = tabBtn("Teleport"),
	Admin = tabBtn("Admin"),
	Visual = tabBtn("Visual"),
	Extra = tabBtn("Extra"),
	World = tabBtn("World"),
	Player = tabBtn("Player"),
}
tabs.Main.BackgroundColor3 = THEME
tabs.Main.TextColor3 = Color3.fromRGB(255, 255, 255)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -128, 1, -82)
content.Position = UDim2.new(0, 122, 0, 40)
content.BackgroundTransparency = 1
content.Parent = main

local pages = {}
local function makePage(name)
	local sc = Instance.new("ScrollingFrame")
	sc.Size = UDim2.new(1, 0, 1, 0)
	sc.BackgroundTransparency = 1
	sc.BorderSizePixel = 0
	sc.ScrollBarThickness = 4
	sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
	sc.CanvasSize = UDim2.new(0, 0, 0, 0)
	sc.Visible = name == "Main"
	sc.Parent = content
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0, 228, 0, 32)
	grid.CellPadding = UDim2.new(0, 10, 0, 8)
	grid.FillDirectionMaxCells = 2
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = sc
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 4)
	pad.PaddingRight = UDim.new(0, 8)
	pad.Parent = sc
	pages[name] = sc
	return sc
end

local pMain = makePage("Main")
local pMove = makePage("Move")
local pTP = makePage("Teleport")
local pAdm = makePage("Admin")
local pVis = makePage("Visual")
local pExt = makePage("Extra")
local pWld = makePage("World")
local pPlr = makePage("Player")

local function switch(name)
	for n, pg in pairs(pages) do pg.Visible = n == name end
	for n, b in pairs(tabs) do
		if n == name then
			b.BackgroundColor3 = THEME
			b.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			b.BackgroundColor3 = SIDE
			b.TextColor3 = Color3.fromRGB(205, 185, 192)
		end
	end
end
for n, b in pairs(tabs) do
	b.MouseButton1Click:Connect(function() switch(n) end)
end

local function btn(parent, text, color)
	local b = Instance.new("TextButton")
	b.BackgroundColor3 = color or OFF
	b.Text = text
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 13
	b.Parent = parent
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
	return b
end
local function box(parent, text)
	local t = Instance.new("TextBox")
	t.BackgroundColor3 = Color3.fromRGB(28, 18, 30)
	t.Text = text
	t.TextColor3 = Color3.fromRGB(255, 255, 255)
	t.Font = Enum.Font.Gotham
	t.TextSize = 13
	t.Parent = parent
	Instance.new("UICorner", t).CornerRadius = UDim.new(0, 8)
	return t
end
local function tog(b, on, a, o)
	b.Text = on and a or o
	b.BackgroundColor3 = on and ON or OFF
end

-- MAIN
local flyBtn = btn(pMain, "Fly: OFF")
local flyBox = box(pMain, "Fly 60")
local spdBox = box(pMain, "Walk 16")
local jmpBox = box(pMain, "Jump 50")
local applyBtn = btn(pMain, "Aplicar valores", THEME)
local fly30 = btn(pMain, "Fly 30", THEME)
local fly80 = btn(pMain, "Fly 80", THEME)
local fly150 = btn(pMain, "Fly 150", THEME)

-- MOVE
local infBtn = btn(pMove, "Inf Jump: OFF")
local ncBtn = btn(pMove, "Noclip: OFF")
local sitBtn = btn(pMove, "Sit / Unsit")
local frzBtn = btn(pMove, "Freeze: OFF")
local hipP = btn(pMove, "HipHeight +")
local hipM = btn(pMove, "HipHeight -")
local s16 = btn(pMove, "Speed 16", THEME)
local s50 = btn(pMove, "Speed 50", THEME)
local s100 = btn(pMove, "Speed 100", THEME)
local s200 = btn(pMove, "Speed 200", THEME)
local j50 = btn(pMove, "Jump 50")
local j120 = btn(pMove, "Jump 120")
local platBtn = btn(pMove, "Plataforma")
local unsit = btn(pMove, "Anti Sit")

-- TELEPORT usa lista vertical
for _, v in ipairs(pTP:GetChildren()) do if v:IsA("UIGridLayout") then v:Destroy() end end
local tpLay = Instance.new("UIListLayout")
tpLay.Padding = UDim.new(0, 7)
tpLay.Parent = pTP
local refBtn = btn(pTP, "Atualizar lista", THEME)
refBtn.Size = UDim2.new(1, -8, 0, 32)
local list = Instance.new("Frame")
list.Size = UDim2.new(1, -8, 0, 10)
list.AutomaticSize = Enum.AutomaticSize.Y
list.BackgroundTransparency = 1
list.Parent = pTP
Instance.new("UIListLayout", list).Padding = UDim.new(0, 7)

-- ADMIN
local invBtn = btn(pAdm, "Invisivel: OFF")
local godBtn = btn(pAdm, "GodMode: OFF")
local ctpBtn = btn(pAdm, "Click TP: OFF")
local flBtn = btn(pAdm, "Click Fling: OFF", Color3.fromRGB(155, 42, 48))
local afBtn = btn(pAdm, "Anti Fling: OFF")
local cdBtn = btn(pAdm, "Click Delete: OFF")
local svBtn = btn(pAdm, "Save Pos")
local ldBtn = btn(pAdm, "Load Pos")
local rstBtn = btn(pAdm, "Reset Char", THEME)
local rjBtn = btn(pAdm, "Rejoin", THEME)
local hpBtn = btn(pAdm, "Server Hop", Color3.fromRGB(95, 42, 115))
local specBtn = btn(pAdm, "Unspectate")

-- VISUAL
local fbBtn = btn(pVis, "Fullbright: OFF")
local fogBtn = btn(pVis, "No Fog: OFF")
local espBtn = btn(pVis, "ESP: OFF")
local xrBtn = btn(pVis, "XRay: OFF")
local rbBtn = btn(pVis, "Rainbow: OFF")
local fovBox = box(pVis, "FOV 70")
local fovBtn = btn(pVis, "Aplicar FOV", THEME)
local nite = btn(pVis, "Noite")
local day = btn(pVis, "Dia")
local rcam = btn(pVis, "Reset Cam")
local noBlur = btn(pVis, "No Blur")
local noShadow = btn(pVis, "No Shadows")

-- EXTRA
local spBtn = btn(pExt, "Spin: OFF")
local akBtn = btn(pExt, "Anti AFK: OFF")
local acBtn = btn(pExt, "AutoClick: OFF")
local fpsBtn = btn(pExt, "FPS Boost", Color3.fromRGB(95, 42, 115))
local cpBtn = btn(pExt, "Copy Pos")
local hatBtn = btn(pExt, "Rem Hats")
local clBtn = btn(pExt, "Rem Roupa")
local tlBtn = btn(pExt, "Rem Tools")
local zmBtn = btn(pExt, "Zoom Inf")
local faceBtn = btn(pExt, "Rem Face")
local waveBtn = btn(pExt, "Wave")
local danceBtn = btn(pExt, "Dance")
local cheerBtn = btn(pExt, "Cheer")
local laughBtn = btn(pExt, "Laugh")

-- WORLD
local gBox = box(pWld, "196.2")
local gBtn = btn(pWld, "Set Gravity", THEME)
local moon = btn(pWld, "Lua 30")
local earth = btn(pWld, "Terra 196")
local noP = btn(pWld, "No Particles")
local mute = btn(pWld, "Mute Sounds")
local now = btn(pWld, "No Water")
local bright = btn(pWld, "Bright+")
local dark = btn(pWld, "Dark")
local noAtm = btn(pWld, "No Atmosphere")

-- PLAYER
local copyUser = btn(pPlr, "Copiar User", THEME)
local copyId = btn(pPlr, "Copiar UserId", THEME)
local copyJob = btn(pPlr, "Copiar JobId")
local copyPlace = btn(pPlr, "Copiar PlaceId")
local respawn = btn(pPlr, "Respawn", THEME)
local fp = btn(pPlr, "1a Pessoa")
local tpv = btn(pPlr, "3a Pessoa")

-- CMD
local cmd = Instance.new("TextBox")
cmd.Size = UDim2.new(1, -16, 0, 28)
cmd.Position = UDim2.new(0, 8, 1, -36)
cmd.BackgroundColor3 = Color3.fromRGB(22, 15, 26)
cmd.PlaceholderText = ";fly  ;speed 50  ;tp nome  ;help"
cmd.Text = ""
cmd.TextColor3 = Color3.fromRGB(255, 255, 255)
cmd.PlaceholderColor3 = Color3.fromRGB(145, 125, 135)
cmd.Font = Enum.Font.Gotham
cmd.TextSize = 12
cmd.ClearTextOnFocus = false
cmd.Parent = main
Instance.new("UICorner", cmd).CornerRadius = UDim.new(0, 8)

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 46, 0, 46)
openBtn.Position = UDim2.new(0, 12, 0.5, -23)
openBtn.BackgroundColor3 = THEME
openBtn.Text = "🐉"
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 17
openBtn.Visible = false
openBtn.Active = true
openBtn.Draggable = true
openBtn.Parent = gui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

local upB = Instance.new("TextButton")
upB.Size = UDim2.new(0, 44, 0, 44)
upB.Position = UDim2.new(1, -56, 0.5, -52)
upB.BackgroundColor3 = Color3.fromRGB(40, 130, 70)
upB.Text = "↑"
upB.TextColor3 = Color3.fromRGB(255, 255, 255)
upB.Font = Enum.Font.GothamBold
upB.TextSize = 17
upB.Visible = false
upB.Parent = gui
Instance.new("UICorner", upB).CornerRadius = UDim.new(0, 10)

local dnB = Instance.new("TextButton")
dnB.Size = UDim2.new(0, 44, 0, 44)
dnB.Position = UDim2.new(1, -56, 0.5, 10)
dnB.BackgroundColor3 = Color3.fromRGB(150, 42, 48)
dnB.Text = "↓"
dnB.TextColor3 = Color3.fromRGB(255, 255, 255)
dnB.Font = Enum.Font.GothamBold
dnB.TextSize = 17
dnB.Visible = false
dnB.Parent = gui
Instance.new("UICorner", dnB).CornerRadius = UDim.new(0, 10)

-- LOGIC
lp.CharacterAdded:Connect(function()
	task.wait(0.4)
	upd()
	flying, flinging = false, false
	if bv then bv:Destroy() bv = nil end
	if bg then bg:Destroy() bg = nil end
	tog(flyBtn, false, "Fly: ON", "Fly: OFF")
	upB.Visible, dnB.Visible = false, false
	if hum then
		hum.WalkSpeed = walkSpeed
		hum.UseJumpPower = true
		hum.JumpPower = jumpPower
	end
end)

local function setFly(state)
	upd()
	if not root or not hum then return end
	flying = state
	tog(flyBtn, flying, "Fly: ON", "Fly: OFF")
	if flying then
		bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		bv.Velocity = Vector3.zero
		bv.Parent = root
		bg = Instance.new("BodyGyro")
		bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		bg.P = 9999
		bg.Parent = root
		hum.PlatformStand = true
		upB.Visible, dnB.Visible = true, true
	else
		if bv then bv:Destroy() bv = nil end
		if bg then bg:Destroy() bg = nil end
		hum.PlatformStand = false
		goingUp, goingDown = false, false
		upB.Visible, dnB.Visible = false, false
	end
end

RS.RenderStepped:Connect(function()
	if flying and bv and bg and root and hum then
		local m = hum.MoveDirection
		local v = Vector3.zero
		if m.Magnitude > 0.05 then v = m * flySpeed end
		if goingUp then v += Vector3.new(0, flySpeed, 0) end
		if goingDown then v += Vector3.new(0, -flySpeed, 0) end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then v += Vector3.new(0, flySpeed, 0) end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then v += Vector3.new(0, -flySpeed, 0) end
		bv.Velocity = v
		bg.CFrame = CFrame.new(root.Position, root.Position + cam.CFrame.LookVector)
	end
end)
upB.MouseButton1Down:Connect(function() goingUp = true end)
upB.MouseButton1Up:Connect(function() goingUp = false end)
upB.MouseLeave:Connect(function() goingUp = false end)
dnB.MouseButton1Down:Connect(function() goingDown = true end)
dnB.MouseButton1Up:Connect(function() goingDown = false end)
dnB.MouseLeave:Connect(function() goingDown = false end)

local function setSpeed(n)
	upd()
	if hum then walkSpeed = n hum.WalkSpeed = n spdBox.Text = "Walk "..n end
end
local function setJump(n)
	upd()
	if hum then jumpPower = n hum.UseJumpPower = true hum.JumpPower = n jmpBox.Text = "Jump "..n end
end
local function setFlySpd(n)
	flySpeed = n
	flyBox.Text = "Fly "..n
end

local function setNoclip(state)
	noclip = state
	tog(ncBtn, noclip, "Noclip: ON", "Noclip: OFF")
	if noclip then
		nC = RS.Stepped:Connect(function()
			if char then
				for _, p in ipairs(char:GetDescendants()) do
					if p:IsA("BasePart") then p.CanCollide = false end
				end
			end
		end)
	elseif nC then nC:Disconnect() nC = nil end
end

local function setGod(state)
	god = state
	tog(godBtn, god, "GodMode: ON", "GodMode: OFF")
	if god then
		gC = RS.Heartbeat:Connect(function()
			if hum and hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
		end)
	elseif gC then gC:Disconnect() gC = nil end
end

local function tpTo(plr)
	upd()
	if not root or not plr.Character then return end
	local t = plr.Character:FindFirstChild("HumanoidRootPart")
	if not t then return end
	local cf = t.CFrame * CFrame.new(0, 0, 3.5)
	for i = 1, 10 do
		root.CFrame = cf
		root.AssemblyLinearVelocity = Vector3.zero
		task.wait()
	end
end

local function findPlr(name)
	name = string.lower(name or "")
	for _, p in ipairs(Players:GetPlayers()) do
		if string.find(string.lower(p.Name), name, 1, true) or string.find(string.lower(p.DisplayName), name, 1, true) then
			return p
		end
	end
end

UIS.JumpRequest:Connect(function()
	if infJump and hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

local function getTarget()
	local t = mouse.Target
	if t and t.Parent then
		local c = t.Parent:IsA("Model") and t.Parent or t.Parent.Parent
		local r = c and c:FindFirstChild("HumanoidRootPart")
		if r and c ~= lp.Character then return r end
	end
end

local function startFling()
	if not clickFling or flinging then return end
	upd()
	local c, r, h = lp.Character, root, hum
	local target = getTarget()
	if not r or not target then return end
	flinging = true
	local old, oldc = r.CFrame, cam.CFrame
	cam.CameraType = Enum.CameraType.Scriptable
	cam.CFrame = oldc
	for _, p in ipairs(c:GetDescendants()) do
		if p:IsA("BasePart") then
			p.CanCollide = false
			pcall(function() p.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 0, 0, 0) end)
		end
	end
	r.CanCollide = true
	task.spawn(function()
		local t0 = os.clock()
		while os.clock() - t0 < 0.3 do
			RS.Heartbeat:Wait()
			if not target or not target.Parent then break end
			r.CFrame = target.CFrame
			r.RotVelocity = Vector3.new(0, 150000, 0)
			r.Velocity = Vector3.new(30, 0, 30)
		end
		r.Velocity = Vector3.zero
		r.RotVelocity = Vector3.zero
		r.AssemblyLinearVelocity = Vector3.zero
		r.CFrame = old + Vector3.new(0, 2, 0)
		cam.CameraType = Enum.CameraType.Custom
		for _, p in ipairs(c:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = true end
		end
		if h then h:ChangeState(Enum.HumanoidStateType.GettingUp) end
		task.wait(0.2)
		flinging = false
	end)
end

mouse.Button1Down:Connect(function()
	if clickDel then
		local t = mouse.Target
		if t and not t:IsDescendantOf(lp.Character or workspace) then pcall(function() t:Destroy() end) end
	elseif clickTP and root and not clickFling then
		local hit = mouse.Hit
		if hit then root.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 0)) end
	end
end)
UIS.InputBegan:Connect(function(i, p)
	if p or not clickFling then return end
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		startFling()
	end
end)

local function refresh()
	for _, c in ipairs(list:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= lp then
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(1, 0, 0, 32)
			b.BackgroundColor3 = Color3.fromRGB(44, 28, 40)
			b.Text = plr.DisplayName
			b.TextColor3 = Color3.fromRGB(255, 255, 255)
			b.Font = Enum.Font.Gotham
			b.TextSize = 13
			b.Parent = list
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
			b.MouseButton1Click:Connect(function() tpTo(plr) end)
		end
	end
end

local espF = Instance.new("Folder", gui)
espF.Name = "ESP"
RS.RenderStepped:Connect(function()
	for _, v in ipairs(espF:GetChildren()) do v:Destroy() end
	if not espOn then return end
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local bill = Instance.new("BillboardGui")
			bill.Size = UDim2.new(0, 120, 0, 22)
			bill.AlwaysOnTop = true
			bill.StudsOffset = Vector3.new(0, 3, 0)
			bill.Adornee = plr.Character.HumanoidRootPart
			bill.Parent = espF
			local tx = Instance.new("TextLabel")
			tx.Size = UDim2.new(1, 0, 1, 0)
			tx.BackgroundTransparency = 1
			tx.Text = plr.DisplayName
			tx.TextColor3 = Color3.fromRGB(255, 80, 90)
			tx.Font = Enum.Font.GothamBold
			tx.TextSize = 13
			tx.Parent = bill
		end
	end
end)

local function numFrom(boxObj, fallback)
	local n = tonumber((boxObj.Text or ""):match("[%d%.]+"))
	return n or fallback
end

local function runCmd(raw)
	local args = {}
	for w in string.gmatch(string.lower(raw or ""), "%S+") do table.insert(args, w) end
	local c = args[1]
	if not c then return end
	c = c:gsub("^;", "")
	if c == "help" then note("fly speed jump tp noclip god invis esp fov grav rejoin")
	elseif c == "fly" then setFly(not flying)
	elseif c == "speed" then setSpeed(tonumber(args[2]) or 50)
	elseif c == "jump" then setJump(tonumber(args[2]) or 100)
	elseif c == "tp" and args[2] then
		local p = findPlr(args[2]); if p then tpTo(p) else note("nao achado") end
	elseif c == "noclip" then setNoclip(not noclip)
	elseif c == "god" then setGod(not god)
	elseif c == "rejoin" then TS:Teleport(game.PlaceId, lp)
	elseif c == "fov" then cam.FieldOfView = tonumber(args[2]) or 70
	elseif c == "grav" then workspace.Gravity = tonumber(args[2]) or 196.2
	elseif c == "reset" or c == "die" then if hum then hum.Health = 0 end
	elseif c == "invis" then
		invis = not invis
		tog(invBtn, invis, "Invisivel: ON", "Invisivel: OFF")
		upd()
		if char then
			for _, p in ipairs(char:GetDescendants()) do
				if p:IsA("BasePart") or p:IsA("Decal") then p.Transparency = invis and 1 or 0 end
			end
		end
	elseif c == "esp" then
		espOn = not espOn
		tog(espBtn, espOn, "ESP: ON", "ESP: OFF")
	else note("Invalido. ;help") end
end
cmd.FocusLost:Connect(function(enter)
	if enter then runCmd(cmd.Text) cmd.Text = "" end
end)

flyBtn.MouseButton1Click:Connect(function() setFly(not flying) end)
applyBtn.MouseButton1Click:Connect(function()
	upd()
	if not hum then return end
	setFlySpd(numFrom(flyBox, flySpeed))
	setSpeed(numFrom(spdBox, walkSpeed))
	setJump(numFrom(jmpBox, jumpPower))
	note("Aplicado")
end)
fly30.MouseButton1Click:Connect(function() setFlySpd(30) end)
fly80.MouseButton1Click:Connect(function() setFlySpd(80) end)
fly150.MouseButton1Click:Connect(function() setFlySpd(150) end)
infBtn.MouseButton1Click:Connect(function() infJump = not infJump tog(infBtn, infJump, "Inf Jump: ON", "Inf Jump: OFF") end)
ncBtn.MouseButton1Click:Connect(function() setNoclip(not noclip) end)
sitBtn.MouseButton1Click:Connect(function() upd() if hum then hum.Sit = not hum.Sit end end)
unsit.MouseButton1Click:Connect(function() upd() if hum then hum.Sit = false end end)
frzBtn.MouseButton1Click:Connect(function()
	upd()
	if root then root.Anchored = not root.Anchored tog(frzBtn, root.Anchored, "Freeze: ON", "Freeze: OFF") end
end)
hipP.MouseButton1Click:Connect(function() upd() if hum then hum.HipHeight += 1.2 end end)
hipM.MouseButton1Click:Connect(function() upd() if hum then hum.HipHeight = math.max(0, hum.HipHeight - 1.2) end end)
s16.MouseButton1Click:Connect(function() setSpeed(16) end)
s50.MouseButton1Click:Connect(function() setSpeed(50) end)
s100.MouseButton1Click:Connect(function() setSpeed(100) end)
s200.MouseButton1Click:Connect(function() setSpeed(200) end)
j50.MouseButton1Click:Connect(function() setJump(50) end)
j120.MouseButton1Click:Connect(function() setJump(120) end)
platBtn.MouseButton1Click:Connect(function()
	upd()
	if root then
		local p = Instance.new("Part")
		p.Size = Vector3.new(8, 1, 8)
		p.Anchored = true
		p.Position = root.Position - Vector3.new(0, 3.2, 0)
		p.Color = Color3.fromRGB(40, 20, 30)
		p.Parent = workspace
		game:GetService("Debris"):AddItem(p, 20)
	end
end)
refBtn.MouseButton1Click:Connect(refresh)
invBtn.MouseButton1Click:Connect(function() runCmd("invis") end)
godBtn.MouseButton1Click:Connect(function() setGod(not god) end)
ctpBtn.MouseButton1Click:Connect(function() clickTP = not clickTP tog(ctpBtn, clickTP, "Click TP: ON", "Click TP: OFF") end)
flBtn.MouseButton1Click:Connect(function()
	clickFling = not clickFling
	tog(flBtn, clickFling, "Click Fling: ON", "Click Fling: OFF")
	note(clickFling and "Clique no player" or "off")
end)
afBtn.MouseButton1Click:Connect(function()
	antiFling = not antiFling
	tog(afBtn, antiFling, "Anti Fling: ON", "Anti Fling: OFF")
	if antiFling then
		afC = RS.Heartbeat:Connect(function()
			upd()
			if root and root.AssemblyLinearVelocity.Magnitude > 180 then
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
			end
		end)
	elseif afC then afC:Disconnect() afC = nil end
end)
cdBtn.MouseButton1Click:Connect(function() clickDel = not clickDel tog(cdBtn, clickDel, "Click Delete: ON", "Click Delete: OFF") end)
svBtn.MouseButton1Click:Connect(function() upd() if root then savedCF = root.CFrame note("salvo") end end)
ldBtn.MouseButton1Click:Connect(function()
	upd()
	if root and savedCF then
		for i = 1, 8 do root.CFrame = savedCF root.AssemblyLinearVelocity = Vector3.zero task.wait() end
	end
end)
rstBtn.MouseButton1Click:Connect(function() if hum then hum.Health = 0 end end)
rjBtn.MouseButton1Click:Connect(function() TS:Teleport(game.PlaceId, lp) end)
hpBtn.MouseButton1Click:Connect(function()
	local ok, data = pcall(function()
		return Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
	end)
	if ok and data and data.data then
		for _, s in ipairs(data.data) do
			if s.playing < s.maxPlayers and s.id ~= game.JobId then
				TS:TeleportToPlaceInstance(game.PlaceId, s.id, lp)
				break
			end
		end
	end
end)
specBtn.MouseButton1Click:Connect(function() if hum then cam.CameraSubject = hum end end)
fbBtn.MouseButton1Click:Connect(function()
	fb = not fb
	tog(fbBtn, fb, "Fullbright: ON", "Fullbright: OFF")
	if fb then
		Lighting.Brightness = 4 Lighting.ClockTime = 12 Lighting.FogEnd = 9e9 Lighting.GlobalShadows = false
	else
		Lighting.Brightness = 1 Lighting.ClockTime = 14 Lighting.FogEnd = 100000 Lighting.GlobalShadows = true
	end
end)
fogBtn.MouseButton1Click:Connect(function()
	local on = fogBtn.Text:find("ON")
	tog(fogBtn, not on, "No Fog: ON", "No Fog: OFF")
	Lighting.FogEnd = on and 100000 or 9e9
end)
espBtn.MouseButton1Click:Connect(function() espOn = not espOn tog(espBtn, espOn, "ESP: ON", "ESP: OFF") end)
xrBtn.MouseButton1Click:Connect(function()
	xray = not xray
	tog(xrBtn, xray, "XRay: ON", "XRay: OFF")
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and not v:IsDescendantOf(lp.Character or workspace) then
			if xray then
				if not v:GetAttribute("OT") then v:SetAttribute("OT", v.Transparency) end
				v.Transparency = math.max(v.Transparency, 0.65)
			elseif v:GetAttribute("OT") then
				v.Transparency = v:GetAttribute("OT")
			end
		end
	end
end)
rbBtn.MouseButton1Click:Connect(function()
	rainbow = not rainbow
	tog(rbBtn, rainbow, "Rainbow: ON", "Rainbow: OFF")
	if rainbow then
		rC = RS.RenderStepped:Connect(function()
			upd()
			if char then
				local h = (tick() * 0.3) % 1
				for _, p in ipairs(char:GetDescendants()) do
					if p:IsA("BasePart") then p.Color = Color3.fromHSV(h, 0.8, 1) end
				end
			end
		end)
	elseif rC then rC:Disconnect() rC = nil end
end)
fovBtn.MouseButton1Click:Connect(function() cam.FieldOfView = numFrom(fovBox, 70) end)
nite.MouseButton1Click:Connect(function() Lighting.ClockTime = 0 end)
day.MouseButton1Click:Connect(function() Lighting.ClockTime = 14 end)
rcam.MouseButton1Click:Connect(function()
	cam.CameraType = Enum.CameraType.Custom
	cam.FieldOfView = 70
	if hum then cam.CameraSubject = hum end
end)
noBlur.MouseButton1Click:Connect(function()
	for _, v in ipairs(Lighting:GetChildren()) do
		if v:IsA("BlurEffect") then v.Enabled = false end
	end
end)
noShadow.MouseButton1Click:Connect(function() Lighting.GlobalShadows = false end)
spBtn.MouseButton1Click:Connect(function()
	spinOn = not spinOn
	tog(spBtn, spinOn, "Spin: ON", "Spin: OFF")
	if spinOn then
		sC = RS.RenderStepped:Connect(function() if root then root.CFrame *= CFrame.Angles(0, math.rad(14), 0) end end)
	elseif sC then sC:Disconnect() sC = nil end
end)
akBtn.MouseButton1Click:Connect(function()
	afkOn = not afkOn
	tog(akBtn, afkOn, "Anti AFK: ON", "Anti AFK: OFF")
	if afkOn then
		aC = RS.Heartbeat:Connect(function()
			pcall(function()
				local vu = game:GetService("VirtualUser")
				vu:CaptureController()
				vu:ClickButton2(Vector2.new())
			end)
		end)
	elseif aC then aC:Disconnect() aC = nil end
end)
acBtn.MouseButton1Click:Connect(function()
	autoClick = not autoClick
	tog(acBtn, autoClick, "AutoClick: ON", "AutoClick: OFF")
	if autoClick then
		cC = RS.Heartbeat:Connect(function()
			pcall(function()
				VIM:SendMouseButtonEvent(0, 0, 0, true, game, 1)
				VIM:SendMouseButtonEvent(0, 0, 0, false, game, 1)
			end)
			task.wait(0.05)
		end)
	elseif cC then cC:Disconnect() cC = nil end
end)
fpsBtn.MouseButton1Click:Connect(function() pcall(function() settings().Rendering.QualityLevel = 1 end) note("FPS+") end)
cpBtn.MouseButton1Click:Connect(function()
	upd()
	if root then
		pcall(function() setclipboard(string.format("%.1f, %.1f, %.1f", root.Position.X, root.Position.Y, root.Position.Z)) end)
	end
end)
hatBtn.MouseButton1Click:Connect(function()
	upd()
	if char then for _, v in ipairs(char:GetChildren()) do if v:IsA("Accessory") then v:Destroy() end end end
end)
clBtn.MouseButton1Click:Connect(function()
	upd()
	if char then
		for _, v in ipairs(char:GetChildren()) do
			if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then v:Destroy() end
		end
	end
end)
tlBtn.MouseButton1Click:Connect(function()
	upd()
	if char then for _, v in ipairs(char:GetChildren()) do if v:IsA("Tool") then v:Destroy() end end end
	if lp:FindFirstChild("Backpack") then
		for _, v in ipairs(lp.Backpack:GetChildren()) do if v:IsA("Tool") then v:Destroy() end end
	end
end)
zmBtn.MouseButton1Click:Connect(function() lp.CameraMaxZoomDistance = 9999 lp.CameraMinZoomDistance = 0.5 end)
faceBtn.MouseButton1Click:Connect(function()
	upd()
	if char then
		local head = char:FindFirstChild("Head")
		if head then
			for _, v in ipairs(head:GetChildren()) do
				if v:IsA("Decal") then v:Destroy() end
			end
		end
	end
end)
local function emote(n) upd() pcall(function() hum:PlayEmote(n) end) end
waveBtn.MouseButton1Click:Connect(function() emote("wave") end)
danceBtn.MouseButton1Click:Connect(function() emote("dance") end)
cheerBtn.MouseButton1Click:Connect(function() emote("cheer") end)
laughBtn.MouseButton1Click:Connect(function() emote("laugh") end)
gBtn.MouseButton1Click:Connect(function() workspace.Gravity = numFrom(gBox, 196.2) end)
moon.MouseButton1Click:Connect(function() workspace.Gravity = 30 gBox.Text = "30" end)
earth.MouseButton1Click:Connect(function() workspace.Gravity = 196.2 gBox.Text = "196.2" end)
noP.MouseButton1Click:Connect(function()
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then v.Enabled = false end
	end
end)
mute.MouseButton1Click:Connect(function()
	for _, v in ipairs(workspace:GetDescendants()) do if v:IsA("Sound") then v.Volume = 0 end end
end)
now.MouseButton1Click:Connect(function()
	pcall(function() workspace.Terrain.WaterTransparency = 1 workspace.Terrain.WaterWaveSize = 0 end)
end)
bright.MouseButton1Click:Connect(function() Lighting.Brightness = 5 end)
dark.MouseButton1Click:Connect(function() Lighting.Brightness = 0.3 Lighting.ClockTime = 0 end)
noAtm.MouseButton1Click:Connect(function()
	for _, v in ipairs(Lighting:GetChildren()) do
		if v:IsA("Atmosphere") then v:Destroy() end
	end
end)
copyUser.MouseButton1Click:Connect(function() pcall(function() setclipboard(lp.Name) end) note("User") end)
copyId.MouseButton1Click:Connect(function() pcall(function() setclipboard(tostring(lp.UserId)) end) end)
copyJob.MouseButton1Click:Connect(function() pcall(function() setclipboard(game.JobId) end) end)
copyPlace.MouseButton1Click:Connect(function() pcall(function() setclipboard(tostring(game.PlaceId)) end) end)
respawn.MouseButton1Click:Connect(function() if hum then hum.Health = 0 end end)
fp.MouseButton1Click:Connect(function() lp.CameraMode = Enum.CameraMode.LockFirstPerson end)
tpv.MouseButton1Click:Connect(function() lp.CameraMode = Enum.CameraMode.Classic lp.CameraMaxZoomDistance = 128 end)

closeBtn.MouseButton1Click:Connect(function() main.Visible = false openBtn.Visible = true end)
openBtn.MouseButton1Click:Connect(function() main.Visible = true openBtn.Visible = false end)
UIS.InputBegan:Connect(function(i, g)
	if g then return end
	if i.KeyCode == Enum.KeyCode.P then
		main.Visible = not main.Visible
		openBtn.Visible = not main.Visible
	end
end)

Players.PlayerAdded:Connect(refresh)
Players.PlayerRemoving:Connect(refresh)
task.spawn(function()
	while true do refresh() task.wait(4) end
end)

print("✅ Dragon v8")