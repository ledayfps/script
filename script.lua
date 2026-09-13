--[[
	DRAGON PANEL - Paisagem Real (Bem Baixo)
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
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

-- Estados
local flying = false
local noclip = false
local infJump = false
local fullbrightOn = false
local bodyVelocity, bodyGyro = nil, nil
local goingUp, goingDown = false, false
local noclipConn = nil

-- ======================
-- GUI
-- ======================
local gui = Instance.new("ScreenGui")
gui.Name = "DragonPanel"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 460, 0, 155)
main.Position = UDim2.new(0.5, -230, 1, -175)
main.BackgroundColor3 = Color3.fromRGB(15, 12, 20)
main.BackgroundTransparency = 0.38
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(160, 60, 60)
stroke.Thickness = 1.3
stroke.Transparency = 0.45
stroke.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 24)
title.BackgroundColor3 = Color3.fromRGB(30, 18, 25)
title.BackgroundTransparency = 0.45
title.Text = "🐉 DRAGON PANEL"
title.TextColor3 = Color3.fromRGB(255, 210, 190)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -26, 0, 1)
closeBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
closeBtn.BackgroundTransparency = 0.25
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 11
closeBtn.Parent = main
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- Abas
local function makeTab(name, x)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 90, 0, 22)
	btn.Position = UDim2.new(0, x, 0, 27)
	btn.BackgroundColor3 = Color3.fromRGB(40, 25, 35)
	btn.BackgroundTransparency = 0.35
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(200, 180, 180)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 11
	btn.Parent = main
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	return btn
end

local tabMove = makeTab("Movement", 6)
local tabTP   = makeTab("Teleport", 100)
local tabMisc = makeTab("Misc", 194)

tabMove.BackgroundColor3 = Color3.fromRGB(140, 50, 50)
tabMove.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Páginas
local pageMove = Instance.new("Frame")
pageMove.Size = UDim2.new(1, -12, 1, -54)
pageMove.Position = UDim2.new(0, 6, 0, 52)
pageMove.BackgroundTransparency = 1
pageMove.Parent = main

local pageTP = pageMove:Clone()
pageTP.Visible = false
pageTP.Parent = main

local pageMisc = pageMove:Clone()
pageMisc.Visible = false
pageMisc.Parent = main

local function switch(tab)
	pageMove.Visible = tab == "move"
	pageTP.Visible   = tab == "tp"
	pageMisc.Visible = tab == "misc"

	tabMove.BackgroundColor3 = tab == "move" and Color3.fromRGB(140, 50, 50) or Color3.fromRGB(40, 25, 35)
	tabTP.BackgroundColor3   = tab == "tp"   and Color3.fromRGB(140, 50, 50) or Color3.fromRGB(40, 25, 35)
	tabMisc.BackgroundColor3 = tab == "misc" and Color3.fromRGB(140, 50, 50) or Color3.fromRGB(40, 25, 35)

	tabMove.TextColor3 = tab == "move" and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,180,180)
	tabTP.TextColor3   = tab == "tp"   and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,180,180)
	tabMisc.TextColor3 = tab == "misc" and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,180,180)
end

tabMove.MouseButton1Click:Connect(function() switch("move") end)
tabTP.MouseButton1Click:Connect(function() switch("tp") end)
tabMisc.MouseButton1Click:Connect(function() switch("misc") end)

-- Componentes
local function btn(parent, text, pos, size, color)
	local b = Instance.new("TextButton")
	b.Size = size or UDim2.new(0, 110, 0, 26)
	b.Position = pos
	b.BackgroundColor3 = color or Color3.fromRGB(50, 30, 40)
	b.BackgroundTransparency = 0.28
	b.Text = text
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 11
	b.Parent = parent
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	return b
end

local function label(parent, text, pos)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(0, 90, 0, 14)
	l.Position = pos
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = Color3.fromRGB(200, 180, 180)
	l.Font = Enum.Font.Gotham
	l.TextSize = 10
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

local function box(parent, text, pos)
	local t = Instance.new("TextBox")
	t.Size = UDim2.new(0, 60, 0, 22)
	t.Position = pos
	t.BackgroundColor3 = Color3.fromRGB(30, 20, 30)
	t.BackgroundTransparency = 0.3
	t.Text = text
	t.TextColor3 = Color3.fromRGB(255, 255, 255)
	t.Font = Enum.Font.Gotham
	t.TextSize = 11
	t.Parent = parent
	Instance.new("UICorner", t).CornerRadius = UDim.new(0, 5)
	return t
end

-- Movement
local flyBtn     = btn(pageMove, "🕊️ Fly: OFF", UDim2.new(0, 0, 0, 0))
local flyLabel   = label(pageMove, "Fly Speed", UDim2.new(0, 120, 0, 0))
local flyBox     = box(pageMove, "60", UDim2.new(0, 120, 0, 14))

local speedLabel = label(pageMove, "Walk Speed", UDim2.new(0, 200, 0, 0))
local speedBox   = box(pageMove, "16", UDim2.new(0, 200, 0, 14))

local jumpLabel  = label(pageMove, "Super Pulo", UDim2.new(0, 280, 0, 0))
local jumpBox    = box(pageMove, "50", UDim2.new(0, 280, 0, 14))

local applyBtn   = btn(pageMove, "Aplicar", UDim2.new(0, 0, 0, 36), UDim2.new(0, 90, 0, 26), Color3.fromRGB(120, 40, 40))
local infBtn     = btn(pageMove, "Inf Jump: OFF", UDim2.new(0, 100, 0, 36), UDim2.new(0, 110, 0, 26))
local noclipBtn  = btn(pageMove, "Noclip: OFF", UDim2.new(0, 220, 0, 36), UDim2.new(0, 110, 0, 26))

-- Teleport
local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, 0, 1, 0)
list.BackgroundColor3 = Color3.fromRGB(25, 18, 28)
list.BackgroundTransparency = 0.4
list.BorderSizePixel = 0
list.ScrollBarThickness = 3
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.Parent = pageTP
Instance.new("UICorner", list).CornerRadius = UDim.new(0, 7)

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.FillDirection = Enum.FillDirection.Horizontal
listLayout.Parent = list

-- Misc
local fbBtn    = btn(pageMisc, "Fullbright: OFF", UDim2.new(0, 0, 0, 0), UDim2.new(0, 130, 0, 26))
local resetBtn = btn(pageMisc, "Reset", UDim2.new(0, 140, 0, 0), UDim2.new(0, 80, 0, 26), Color3.fromRGB(120, 40, 40))
local fovLabel = label(pageMisc, "FOV", UDim2.new(0, 0, 0, 36))
local fovBox   = box(pageMisc, "70", UDim2.new(0, 0, 0, 50))
local fovBtn   = btn(pageMisc, "Aplicar FOV", UDim2.new(0, 70, 0, 48), UDim2.new(0, 100, 0, 26), Color3.fromRGB(120, 40, 40))

-- Botões flutuantes
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 42, 0, 42)
openBtn.Position = UDim2.new(0, 12, 1, -140)
openBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
openBtn.BackgroundTransparency = 0.2
openBtn.Text = "🐉"
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 17
openBtn.Visible = false
openBtn.Parent = gui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

local upBtn = Instance.new("TextButton")
upBtn.Size = UDim2.new(0, 46, 0, 46)
upBtn.Position = UDim2.new(1, -58, 0.5, -55)
upBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 60)
upBtn.BackgroundTransparency = 0.15
upBtn.Text = "↑"
upBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
upBtn.Font = Enum.Font.GothamBold
upBtn.TextSize = 18
upBtn.Visible = false
upBtn.Parent = gui
Instance.new("UICorner", upBtn).CornerRadius = UDim.new(0, 10)

local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.new(0, 46, 0, 46)
downBtn.Position = UDim2.new(1, -58, 0.5, 8)
downBtn.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
downBtn.BackgroundTransparency = 0.15
downBtn.Text = "↓"
downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
downBtn.Font = Enum.Font.GothamBold
downBtn.TextSize = 18
downBtn.Visible = false
downBtn.Parent = gui
Instance.new("UICorner", downBtn).CornerRadius = UDim.new(0, 10)

-- ======================
-- LÓGICA
-- ======================
player.CharacterAdded:Connect(function()
	task.wait(0.35)
	updateChar()
	flying = false
	if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
	if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
	flyBtn.Text = "🕊️ Fly: OFF"
	flyBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 40)
	upBtn.Visible = false
	downBtn.Visible = false
	if humanoid then
		humanoid.WalkSpeed = walkSpeed
		humanoid.UseJumpPower = true
		humanoid.JumpPower = jumpPower
	end
end)

local function toggleFly()
	updateChar()
	if not rootPart or not humanoid then return end

	flying = not flying
	if flying then
		flyBtn.Text = "🕊️ Fly: ON"
		flyBtn.BackgroundColor3 = Color3.fromRGB(40, 130, 70)

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
		flyBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 40)
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

local function applyValues()
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
	infBtn.BackgroundColor3 = infJump and Color3.fromRGB(40, 130, 70) or Color3.fromRGB(50, 30, 40)
end

local function toggleNoclip()
	noclip = not noclip
	noclipBtn.Text = noclip and "Noclip: ON" or "Noclip: OFF"
	noclipBtn.BackgroundColor3 = noclip and Color3.fromRGB(40, 130, 70) or Color3.fromRGB(50, 30, 40)

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
			b.Size = UDim2.new(0, 100, 0, 24)
			b.BackgroundColor3 = Color3.fromRGB(50, 30, 40)
			b.BackgroundTransparency = 0.25
			b.Text = plr.DisplayName
			b.TextColor3 = Color3.fromRGB(255, 255, 255)
			b.Font = Enum.Font.Gotham
			b.TextSize = 11
			b.Parent = list
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
			b.MouseButton1Click:Connect(function() tpTo(plr) end)
			x = x + 106
		end
	end
	list.CanvasSize = UDim2.new(0, x, 0, 0)
end

local function toggleFB()
	fullbrightOn = not fullbrightOn
	fbBtn.Text = fullbrightOn and "Fullbright: ON" or "Fullbright: OFF"
	fbBtn.BackgroundColor3 = fullbrightOn and Color3.fromRGB(40, 130, 70) or Color3.fromRGB(50, 30, 40)

	if fullbrightOn then
		Lighting.Brightness = 3
		Lighting.ClockTime = 12
		Lighting.FogEnd = 9e9
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
		Lighting.Ambient = Color3.fromRGB(150, 150, 150)
	else
		Lighting.Brightness = 1
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = true
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
		Lighting.Ambient = Color3.fromRGB(0, 0, 0)
	end
end

local function applyFOV()
	local v = tonumber(fovBox.Text)
	if v and v >= 1 and v <= 120 then
		camera.FieldOfView = v
		task.spawn(function()
			for i = 1, 6 do
				camera.FieldOfView = v
				task.wait(0.04)
			end
		end)
	end
end

-- Conexões
flyBtn.MouseButton1Click:Connect(toggleFly)
applyBtn.MouseButton1Click:Connect(applyValues)
infBtn.MouseButton1Click:Connect(toggleInf)
noclipBtn.MouseButton1Click:Connect(toggleNoclip)
fbBtn.MouseButton1Click:Connect(toggleFB)
resetBtn.MouseButton1Click:Connect(function() if humanoid then humanoid.Health = 0 end end)
fovBtn.MouseButton1Click:Connect(applyFOV)

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

print("✅ Dragon Panel Paisagem carregado!")