--[[
	DRAGON ADMIN PANEL - VERSÃO COMPLETA
	Muitas funções + visual premium
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local character, humanoid, rootPart
local function updateChar()
	character = player.Character
	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
		rootPart = character:FindFirstChild("HumanoidRootPart")
	end
end
updateChar()

-- Valores
local flySpeed = 60
local walkSpeed = 16
local jumpPower = 50
local savedCFrame = nil

-- Estados
local flying = false
local noclip = false
local infJump = false
local fullbright = false
local invisible = false
local godmode = false
local clickTP = false
local espEnabled = false
local spinEnabled = false
local antiAFK = false
local bodyVelocity, bodyGyro = nil, nil
local goingUp, goingDown = false, false
local noclipConn, godConn, spinConn, afkConn = nil, nil, nil, nil
local espFolder = Instance.new("Folder")
espFolder.Name = "DragonESP"
espFolder.Parent = gui or game.CoreGui

-- ======================
-- GUI
-- ======================
local gui = Instance.new("ScreenGui")
gui.Name = "DragonAdmin"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 520, 0, 230)
main.Position = UDim2.new(0.5, -260, 1, -250)
main.BackgroundColor3 = Color3.fromRGB(10, 8, 16)
main.BackgroundTransparency = 0.18
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(190, 60, 60)
stroke.Thickness = 1.6
stroke.Transparency = 0.3
stroke.Parent = main

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundColor3 = Color3.fromRGB(22, 12, 20)
title.BackgroundTransparency = 0.25
title.Text = "🐉  DRAGON ADMIN  |  FULL"
title.TextColor3 = Color3.fromRGB(255, 200, 180)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 14)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -28, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(170, 35, 35)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.Parent = main
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- Abas
local function createTab(text, x)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 88, 0, 23)
	b.Position = UDim2.new(0, x, 0, 32)
	b.BackgroundColor3 = Color3.fromRGB(32, 20, 30)
	b.BackgroundTransparency = 0.2
	b.Text = text
	b.TextColor3 = Color3.fromRGB(180, 160, 170)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.Parent = main
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	return b
end

local tab1 = createTab("Movement", 6)
local tab2 = createTab("Teleport", 98)
local tab3 = createTab("Admin", 190)
local tab4 = createTab("Visual", 282)
local tab5 = createTab("Extra", 374)

tab1.BackgroundColor3 = Color3.fromRGB(155, 45, 45)
tab1.TextColor3 = Color3.fromRGB(255, 255, 255)

local function createPage()
	local p = Instance.new("Frame")
	p.Size = UDim2.new(1, -14, 1, -62)
	p.Position = UDim2.new(0, 7, 0, 58)
	p.BackgroundTransparency = 1
	p.Visible = false
	p.Parent = main
	return p
end

local page1 = createPage()
local page2 = createPage()
local page3 = createPage()
local page4 = createPage()
local page5 = createPage()
page1.Visible = true

local function switch(n)
	page1.Visible = n == 1
	page2.Visible = n == 2
	page3.Visible = n == 3
	page4.Visible = n == 4
	page5.Visible = n == 5
	local tabs = {tab1, tab2, tab3, tab4, tab5}
	for i, t in ipairs(tabs) do
		if i == n then
			t.BackgroundColor3 = Color3.fromRGB(155, 45, 45)
			t.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			t.BackgroundColor3 = Color3.fromRGB(32, 20, 30)
			t.TextColor3 = Color3.fromRGB(180, 160, 170)
		end
	end
end

tab1.MouseButton1Click:Connect(function() switch(1) end)
tab2.MouseButton1Click:Connect(function() switch(2) end)
tab3.MouseButton1Click:Connect(function() switch(3) end)
tab4.MouseButton1Click:Connect(function() switch(4) end)
tab5.MouseButton1Click:Connect(function() switch(5) end)

-- UI Helpers
local function btn(parent, text, pos, size, color)
	local b = Instance.new("TextButton")
	b.Size = size or UDim2.new(0, 112, 0, 27)
	b.Position = pos
	b.BackgroundColor3 = color or Color3.fromRGB(42, 26, 36)
	b.BackgroundTransparency = 0.18
	b.Text = text
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 11
	b.Parent = parent
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
	return b
end

local function label(parent, text, pos)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(0, 80, 0, 13)
	l.Position = pos
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = Color3.fromRGB(185, 165, 175)
	l.Font = Enum.Font.Gotham
	l.TextSize = 10
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

local function box(parent, text, pos)
	local t = Instance.new("TextBox")
	t.Size = UDim2.new(0, 54, 0, 23)
	t.Position = pos
	t.BackgroundColor3 = Color3.fromRGB(25, 16, 25)
	t.BackgroundTransparency = 0.2
	t.Text = text
	t.TextColor3 = Color3.fromRGB(255, 255, 255)
	t.Font = Enum.Font.Gotham
	t.TextSize = 11
	t.Parent = parent
	Instance.new("UICorner", t).CornerRadius = UDim.new(0, 6)
	return t
end

-- ===== PAGE 1 - MOVEMENT =====
local flyBtn = btn(page1, "🕊️ Fly: OFF", UDim2.new(0, 0, 0, 0))
local flyBox = box(page1, "60", UDim2.new(0, 120, 0, 2))
label(page1, "Fly Speed", UDim2.new(0, 120, 0, -11))

local speedBox = box(page1, "16", UDim2.new(0, 185, 0, 2))
label(page1, "Walk", UDim2.new(0, 185, 0, -11))

local jumpBox = box(page1, "50", UDim2.new(0, 250, 0, 2))
label(page1, "Jump", UDim2.new(0, 250, 0, -11))

local applyBtn = btn(page1, "Aplicar", UDim2.new(0, 320, 0, 0), UDim2.new(0, 85, 0, 27), Color3.fromRGB(135, 40, 40))

local infBtn = btn(page1, "Inf Jump: OFF", UDim2.new(0, 0, 0, 36))
local noclipBtn = btn(page1, "Noclip: OFF", UDim2.new(0, 120, 0, 36))
local hipBtn = btn(page1, "HipHeight +", UDim2.new(0, 240, 0, 36))
local sitBtn = btn(page1, "Sit", UDim2.new(0, 360, 0, 36), UDim2.new(0, 70, 0, 27))

-- ===== PAGE 2 - TELEPORT =====
local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, 0, 1, 0)
list.BackgroundColor3 = Color3.fromRGB(20, 14, 22)
list.BackgroundTransparency = 0.3
list.BorderSizePixel = 0
list.ScrollBarThickness = 3
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.Parent = page2
Instance.new("UICorner", list).CornerRadius = UDim.new(0, 8)

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.FillDirection = Enum.FillDirection.Horizontal
listLayout.Parent = list

-- ===== PAGE 3 - ADMIN =====
local invisBtn = btn(page3, "Invisível: OFF", UDim2.new(0, 0, 0, 0))
local godBtn = btn(page3, "GodMode: OFF", UDim2.new(0, 120, 0, 0))
local clickBtn = btn(page3, "Click TP: OFF", UDim2.new(0, 240, 0, 0))
local resetBtn = btn(page3, "Reset", UDim2.new(0, 360, 0, 0), UDim2.new(0, 75, 0, 27), Color3.fromRGB(135, 40, 40))

local rejoinBtn = btn(page3, "Rejoin", UDim2.new(0, 0, 0, 36), UDim2.new(0, 100, 0, 27), Color3.fromRGB(135, 40, 40))
local hopBtn = btn(page3, "Server Hop", UDim2.new(0, 110, 0, 36), UDim2.new(0, 110, 0, 27), Color3.fromRGB(90, 40, 100))
local saveBtn = btn(page3, "Save Pos", UDim2.new(0, 230, 0, 36), UDim2.new(0, 90, 0, 27))
local loadBtn = btn(page3, "Load Pos", UDim2.new(0, 330, 0, 36), UDim2.new(0, 90, 0, 27))

-- ===== PAGE 4 - VISUAL =====
local fbBtn = btn(page4, "Fullbright: OFF", UDim2.new(0, 0, 0, 0))
local fogBtn = btn(page4, "No Fog: OFF", UDim2.new(0, 120, 0, 0))
local espBtn = btn(page4, "ESP: OFF", UDim2.new(0, 240, 0, 0))
local fovBox = box(page4, "70", UDim2.new(0, 365, 0, 2))
label(page4, "FOV", UDim2.new(0, 365, 0, -11))
local fovBtn = btn(page4, "Set FOV", UDim2.new(0, 430, 0, 0), UDim2.new(0, 70, 0, 27), Color3.fromRGB(135, 40, 40))

-- ===== PAGE 5 - EXTRA =====
local spinBtn = btn(page5, "Spin: OFF", UDim2.new(0, 0, 0, 0))
local afkBtn = btn(page5, "Anti AFK: OFF", UDim2.new(0, 120, 0, 0))
local fpsBtn = btn(page5, "FPS Boost", UDim2.new(0, 240, 0, 0), UDim2.new(0, 100, 0, 27), Color3.fromRGB(90, 40, 100))
local copyBtn = btn(page5, "Copy Pos", UDim2.new(0, 350, 0, 0), UDim2.new(0, 90, 0, 27))

-- Botões flutuantes
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 44, 0, 44)
openBtn.Position = UDim2.new(0, 12, 1, -170)
openBtn.BackgroundColor3 = Color3.fromRGB(120, 35, 35)
openBtn.BackgroundTransparency = 0.12
openBtn.Text = "🐉"
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 18
openBtn.Visible = false
openBtn.Parent = gui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

local upBtn = Instance.new("TextButton")
upBtn.Size = UDim2.new(0, 48, 0, 48)
upBtn.Position = UDim2.new(1, -60, 0.5, -58)
upBtn.BackgroundColor3 = Color3.fromRGB(40, 130, 70)
upBtn.BackgroundTransparency = 0.1
upBtn.Text = "↑"
upBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
upBtn.Font = Enum.Font.GothamBold
upBtn.TextSize = 20
upBtn.Visible = false
upBtn.Parent = gui
Instance.new("UICorner", upBtn).CornerRadius = UDim.new(0, 10)

local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.new(0, 48, 0, 48)
downBtn.Position = UDim2.new(1, -60, 0.5, 10)
downBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
downBtn.BackgroundTransparency = 0.1
downBtn.Text = "↓"
downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
downBtn.Font = Enum.Font.GothamBold
downBtn.TextSize = 20
downBtn.Visible = false
downBtn.Parent = gui
Instance.new("UICorner", downBtn).CornerRadius = UDim.new(0, 10)

-- ======================
-- FUNÇÕES
-- ======================
player.CharacterAdded:Connect(function()
	task.wait(0.4)
	updateChar()
	flying = false
	if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
	if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
	flyBtn.Text = "🕊️ Fly: OFF"
	flyBtn.BackgroundColor3 = Color3.fromRGB(42, 26, 36)
	upBtn.Visible = false
	downBtn.Visible = false
	if humanoid then
		humanoid.WalkSpeed = walkSpeed
		humanoid.UseJumpPower = true
		humanoid.JumpPower = jumpPower
	end
end)

-- Fly
local function toggleFly()
	updateChar()
	if not rootPart or not humanoid then return end
	flying = not flying
	if flying then
		flyBtn.Text = "🕊️ Fly: ON"
		flyBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 80)
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		bodyVelocity.Velocity = Vector3.zero
		bodyVelocity.Parent = rootPart
		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		bodyGyro.P = 9999
		bodyGyro.Parent = rootPart
		humanoid.PlatformStand = true
		upBtn.Visible = true
		downBtn.Visible = true
	else
		flyBtn.Text = "🕊️ Fly: OFF"
		flyBtn.BackgroundColor3 = Color3.fromRGB(42, 26, 36)
		if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
		if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
		humanoid.PlatformStand = false
		goingUp = false
		goingDown = false
		upBtn.Visible = false
		downBtn.Visible = false
	end
end

RunService.RenderStepped:Connect(function()
	if flying and bodyVelocity and bodyGyro and rootPart and humanoid then
		local move = humanoid.MoveDirection
		local vel = Vector3.zero
		if move.Magnitude > 0.05 then vel = move * flySpeed end
		if goingUp then vel = vel + Vector3.new(0, flySpeed, 0) end
		if goingDown then vel = vel + Vector3.new(0, -flySpeed, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, flySpeed, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			vel = vel + Vector3.new(0, -flySpeed, 0)
		end
		bodyVelocity.Velocity = vel
		bodyGyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + camera.CFrame.LookVector)
	end
end)

upBtn.MouseButton1Down:Connect(function() goingUp = true end)
upBtn.MouseButton1Up:Connect(function() goingUp = false end)
upBtn.MouseLeave:Connect(function() goingUp = false end)
downBtn.MouseButton1Down:Connect(function() goingDown = true end)
downBtn.MouseButton1Up:Connect(function() goingDown = false end)
downBtn.MouseLeave:Connect(function() goingDown = false end)

local function apply()
	updateChar()
	if not humanoid then return end
	local f = tonumber(flyBox.Text)
	local s = tonumber(speedBox.Text)
	local j = tonumber(jumpBox.Text)
	if f and f > 0 then flySpeed = f end
	if s and s > 0 then walkSpeed = s humanoid.WalkSpeed = s end
	if j and j > 0 then
		jumpPower = j
		humanoid.UseJumpPower = true
		humanoid.JumpPower = j
	end
end

UserInputService.JumpRequest:Connect(function()
	if infJump and humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

local function toggleInf()
	infJump = not infJump
	infBtn.Text = infJump and "Inf Jump: ON" or "Inf Jump: OFF"
	infBtn.BackgroundColor3 = infJump and Color3.fromRGB(40, 140, 80) or Color3.fromRGB(42, 26, 36)
end

local function toggleNoclip()
	noclip = not noclip
	noclipBtn.Text = noclip and "Noclip: ON" or "Noclip: OFF"
	noclipBtn.BackgroundColor3 = noclip and Color3.fromRGB(40, 140, 80) or Color3.fromRGB(42, 26, 36)
	if noclip then
		noclipConn = RunService.Stepped:Connect(function()
			if character then
				for _, p in ipairs(character:GetDescendants()) do
					if p:IsA("BasePart") then p.CanCollide = false end
				end
			end
		end)
	else
		if noclipConn then noclipConn:Disconnect() noclipConn = nil end
	end
end

local function addHip()
	updateChar()
	if humanoid then humanoid.HipHeight = humanoid.HipHeight + 1.5 end
end

local function sit()
	updateChar()
	if humanoid then humanoid.Sit = not humanoid.Sit end
end

-- Invisível
local function toggleInvis()
	updateChar()
	invisible = not invisible
	invisBtn.Text = invisible and "Invisível: ON" or "Invisível: OFF"
	invisBtn.BackgroundColor3 = invisible and Color3.fromRGB(40, 140, 80) or Color3.fromRGB(42, 26, 36)
	if character then
		for _, p in ipairs(character:GetDescendants()) do
			if p:IsA("BasePart") or p:IsA("Decal") then
				p.Transparency = invisible and 1 or 0
			end
		end
	end
end

-- GodMode
local function toggleGod()
	godmode = not godmode
	godBtn.Text = godmode and "GodMode: ON" or "GodMode: OFF"
	godBtn.BackgroundColor3 = godmode and Color3.fromRGB(40, 140, 80) or Color3.fromRGB(42, 26, 36)
	if godmode then
		godConn = RunService.Heartbeat:Connect(function()
			if humanoid and humanoid.Health < humanoid.MaxHealth then
				humanoid.Health = humanoid.MaxHealth
			end
		end)
	else
		if godConn then godConn:Disconnect() godConn = nil end
	end
end

-- Click TP
local function toggleClickTP()
	clickTP = not clickTP
	clickBtn.Text = clickTP and "Click TP: ON" or "Click TP: OFF"
	clickBtn.BackgroundColor3 = clickTP and Color3.fromRGB(40, 140, 80) or Color3.fromRGB(42, 26, 36)
end

mouse.Button1Down:Connect(function()
	if clickTP and rootPart then
		local hit = mouse.Hit
		if hit then
			rootPart.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 0))
		end
	end
end)

-- Save / Load Position
local function savePos()
	updateChar()
	if rootPart then
		savedCFrame = rootPart.CFrame
		StarterGui:SetCore("SendNotification", {Title = "Dragon", Text = "Posição salva!", Duration = 2})
	end
end

local function loadPos()
	updateChar()
	if rootPart and savedCFrame then
		for i = 1, 8 do
			rootPart.CFrame = savedCFrame
			rootPart.AssemblyLinearVelocity = Vector3.zero
			task.wait()
		end
	end
end

-- Teleport players
local function tpTo(plr)
	updateChar()
	if not rootPart or not plr.Character then return end
	local target = plr.Character:FindFirstChild("HumanoidRootPart")
	if not target then return end
	local cf = target.CFrame * CFrame.new(0, 0, 3.5)
	for i = 1, 12 do
		rootPart.CFrame = cf
		rootPart.AssemblyLinearVelocity = Vector3.zero
		task.wait()
	end
end

local function refresh()
	for _, c in ipairs(list:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	local x = 0
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(0, 105, 0, 26)
			b.BackgroundColor3 = Color3.fromRGB(48, 28, 40)
			b.BackgroundTransparency = 0.15
			b.Text = plr.DisplayName
			b.TextColor3 = Color3.fromRGB(255, 255, 255)
			b.Font = Enum.Font.Gotham
			b.TextSize = 11
			b.Parent = list
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
			b.MouseButton1Click:Connect(function() tpTo(plr) end)
			x = x + 112
		end
	end
	list.CanvasSize = UDim2.new(0, x, 0, 0)
end

-- Fullbright
local function toggleFB()
	fullbright = not fullbright
	fbBtn.Text = fullbright and "Fullbright: ON" or "Fullbright: OFF"
	fbBtn.BackgroundColor3 = fullbright and Color3.fromRGB(40, 140, 80) or Color3.fromRGB(42, 26, 36)
	if fullbright then
		Lighting.Brightness = 4
		Lighting.ClockTime = 12
		Lighting.FogEnd = 9e9
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.fromRGB(210, 210, 210)
		Lighting.Ambient = Color3.fromRGB(170, 170, 170)
	else
		Lighting.Brightness = 1
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = true
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
		Lighting.Ambient = Color3.fromRGB(0, 0, 0)
	end
end

local function toggleFog()
	local on = fogBtn.Text:find("ON")
	fogBtn.Text = on and "No Fog: OFF" or "No Fog: ON"
	fogBtn.BackgroundColor3 = on and Color3.fromRGB(42, 26, 36) or Color3.fromRGB(40, 140, 80)
	Lighting.FogEnd = on and 100000 or 9e9
end

-- ESP simples
local function clearESP()
	for _, v in ipairs(espFolder:GetChildren()) do v:Destroy() end
end

local function toggleESP()
	espEnabled = not espEnabled
	espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
	espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(40, 140, 80) or Color3.fromRGB(42, 26, 36)
	if not espEnabled then clearESP() end
end

RunService.RenderStepped:Connect(function()
	if not espEnabled then return end
	clearESP()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local bill = Instance.new("BillboardGui")
			bill.Size = UDim2.new(0, 100, 0, 30)
			bill.AlwaysOnTop = true
			bill.StudsOffset = Vector3.new(0, 3, 0)
			bill.Adornee = plr.Character.HumanoidRootPart
			bill.Parent = espFolder

			local txt = Instance.new("TextLabel")
			txt.Size = UDim2.new(1, 0, 1, 0)
			txt.BackgroundTransparency = 1
			txt.Text = plr.DisplayName
			txt.TextColor3 = Color3.fromRGB(255, 80, 80)
			txt.TextStrokeTransparency = 0.3
			txt.Font = Enum.Font.GothamBold
			txt.TextSize = 13
			txt.Parent = bill
		end
	end
end)

-- FOV
local function applyFOV()
	local v = tonumber(fovBox.Text)
	if v and v >= 1 and v <= 120 then
		camera.FieldOfView = v
		task.spawn(function()
			for i = 1, 8 do camera.FieldOfView = v task.wait(0.03) end
		end)
	end
end

-- Spin
local function toggleSpin()
	spinEnabled = not spinEnabled
	spinBtn.Text = spinEnabled and "Spin: ON" or "Spin: OFF"
	spinBtn.BackgroundColor3 = spinEnabled and Color3.fromRGB(40, 140, 80) or Color3.fromRGB(42, 26, 36)
	if spinEnabled then
		spinConn = RunService.RenderStepped:Connect(function()
			if rootPart then
				rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(12), 0)
			end
		end)
	else
		if spinConn then spinConn:Disconnect() spinConn = nil end
	end
end

-- Anti AFK
local function toggleAFK()
	antiAFK = not antiAFK
	afkBtn.Text = antiAFK and "Anti AFK: ON" or "Anti AFK: OFF"
	afkBtn.BackgroundColor3 = antiAFK and Color3.fromRGB(40, 140, 80) or Color3.fromRGB(42, 26, 36)
	if antiAFK then
		afkConn = RunService.Heartbeat:Connect(function()
			pcall(function()
				game:GetService("VirtualUser"):CaptureController()
				game:GetService("VirtualUser"):ClickButton2(Vector2.new())
			end)
		end)
	else
		if afkConn then afkConn:Disconnect() afkConn = nil end
	end
end

-- FPS Boost básico
local function fpsBoost()
	pcall(function()
		settings().Rendering.QualityLevel = 1
		UserSettings():GetService("UserGameSettings").SavedQualityLevel = 1
	end)
	StarterGui:SetCore("SendNotification", {Title = "Dragon", Text = "FPS Boost aplicado!", Duration = 2})
end

-- Copy Position
local function copyPos()
	updateChar()
	if rootPart then
		local p = rootPart.Position
		setclipboard(string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z))
		StarterGui:SetCore("SendNotification", {Title = "Dragon", Text = "Posição copiada!", Duration = 2})
	end
end

-- Rejoin / Hop
local function rejoin()
	TeleportService:Teleport(game.PlaceId, player)
end

local function serverHop()
	local ok, data = pcall(function()
		return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
	end)
	if ok and data and data.data then
		for _, s in ipairs(data.data) do
			if s.playing < s.maxPlayers and s.id ~= game.JobId then
				TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, player)
				break
			end
		end
	end
end

-- Conexões
flyBtn.MouseButton1Click:Connect(toggleFly)
applyBtn.MouseButton1Click:Connect(apply)
infBtn.MouseButton1Click:Connect(toggleInf)
noclipBtn.MouseButton1Click:Connect(toggleNoclip)
hipBtn.MouseButton1Click:Connect(addHip)
sitBtn.MouseButton1Click:Connect(sit)
invisBtn.MouseButton1Click:Connect(toggleInvis)
godBtn.MouseButton1Click:Connect(toggleGod)
clickBtn.MouseButton1Click:Connect(toggleClickTP)
resetBtn.MouseButton1Click:Connect(function() if humanoid then humanoid.Health = 0 end end)
rejoinBtn.MouseButton1Click:Connect(rejoin)
hopBtn.MouseButton1Click:Connect(serverHop)
saveBtn.MouseButton1Click:Connect(savePos)
loadBtn.MouseButton1Click:Connect(loadPos)
fbBtn.MouseButton1Click:Connect(toggleFB)
fogBtn.MouseButton1Click:Connect(toggleFog)
espBtn.MouseButton1Click:Connect(toggleESP)
fovBtn.MouseButton1Click:Connect(applyFOV)
spinBtn.MouseButton1Click:Connect(toggleSpin)
afkBtn.MouseButton1Click:Connect(toggleAFK)
fpsBtn.MouseButton1Click:Connect(fpsBoost)
copyBtn.MouseButton1Click:Connect(copyPos)

closeBtn.MouseButton1Click:Connect(function()
	main.Visible = false
	openBtn.Visible = true
end)
openBtn.MouseButton1Click:Connect(function()
	main.Visible = true
	openBtn.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.P then
		main.Visible = not main.Visible
		openBtn.Visible = not main.Visible
	end
end)

Players.PlayerAdded:Connect(refresh)
Players.PlayerRemoving:Connect(refresh)
task.spawn(function()
	while true do refresh() task.wait(4) end
end)

print("✅ Dragon Admin FULL carregado!")