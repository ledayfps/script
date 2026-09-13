--[[
	DRAGON ADMIN PANEL
	Visual premium + várias funções
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

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
local fullbright = false
local invisible = false
local godmode = false
local bodyVelocity, bodyGyro = nil, nil
local goingUp, goingDown = false, false
local noclipConn, godConn = nil, nil

-- ======================
-- GUI PREMIUM
-- ======================
local gui = Instance.new("ScreenGui")
gui.Name = "DragonAdmin"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 480, 0, 195)
main.Position = UDim2.new(0.5, -240, 1, -215)
main.BackgroundColor3 = Color3.fromRGB(12, 10, 18)
main.BackgroundTransparency = 0.22
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(180, 70, 70)
stroke.Thickness = 1.5
stroke.Transparency = 0.35
stroke.Parent = main

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundColor3 = Color3.fromRGB(25, 15, 22)
title.BackgroundTransparency = 0.3
title.Text = "🐉  DRAGON ADMIN"
title.TextColor3 = Color3.fromRGB(255, 200, 180)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 14)

-- Fechar
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -28, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(170, 40, 40)
closeBtn.BackgroundTransparency = 0.15
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.Parent = main
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- Abas
local function createTab(text, x)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 95, 0, 24)
	b.Position = UDim2.new(0, x, 0, 32)
	b.BackgroundColor3 = Color3.fromRGB(35, 22, 32)
	b.BackgroundTransparency = 0.25
	b.Text = text
	b.TextColor3 = Color3.fromRGB(190, 170, 170)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 12
	b.Parent = main
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
	return b
end

local tab1 = createTab("Movement", 8)
local tab2 = createTab("Teleport", 110)
local tab3 = createTab("Admin", 212)
local tab4 = createTab("Visual", 314)

tab1.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
tab1.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Páginas
local function createPage()
	local p = Instance.new("Frame")
	p.Size = UDim2.new(1, -16, 1, -64)
	p.Position = UDim2.new(0, 8, 0, 60)
	p.BackgroundTransparency = 1
	p.Visible = false
	p.Parent = main
	return p
end

local page1 = createPage() -- Movement
local page2 = createPage() -- Teleport
local page3 = createPage() -- Admin
local page4 = createPage() -- Visual
page1.Visible = true

local function switch(n)
	page1.Visible = n == 1
	page2.Visible = n == 2
	page3.Visible = n == 3
	page4.Visible = n == 4

	local tabs = {tab1, tab2, tab3, tab4}
	for i, t in ipairs(tabs) do
		if i == n then
			t.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
			t.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			t.BackgroundColor3 = Color3.fromRGB(35, 22, 32)
			t.TextColor3 = Color3.fromRGB(190, 170, 170)
		end
	end
end

tab1.MouseButton1Click:Connect(function() switch(1) end)
tab2.MouseButton1Click:Connect(function() switch(2) end)
tab3.MouseButton1Click:Connect(function() switch(3) end)
tab4.MouseButton1Click:Connect(function() switch(4) end)

-- Helpers de UI
local function makeBtn(parent, text, pos, size, color)
	local b = Instance.new("TextButton")
	b.Size = size or UDim2.new(0, 115, 0, 28)
	b.Position = pos
	b.BackgroundColor3 = color or Color3.fromRGB(45, 28, 38)
	b.BackgroundTransparency = 0.2
	b.Text = text
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 12
	b.Parent = parent
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
	return b
end

local function makeLabel(parent, text, pos)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(0, 90, 0, 14)
	l.Position = pos
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = Color3.fromRGB(190, 170, 180)
	l.Font = Enum.Font.Gotham
	l.TextSize = 11
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

local function makeBox(parent, text, pos)
	local t = Instance.new("TextBox")
	t.Size = UDim2.new(0, 58, 0, 24)
	t.Position = pos
	t.BackgroundColor3 = Color3.fromRGB(28, 18, 28)
	t.BackgroundTransparency = 0.25
	t.Text = text
	t.TextColor3 = Color3.fromRGB(255, 255, 255)
	t.Font = Enum.Font.Gotham
	t.TextSize = 12
	t.Parent = parent
	Instance.new("UICorner", t).CornerRadius = UDim.new(0, 6)
	return t
end

-- ========== PAGE 1 : MOVEMENT ==========
local flyBtn = makeBtn(page1, "🕊️ Fly: OFF", UDim2.new(0, 0, 0, 0))
local flyBox = makeBox(page1, "60", UDim2.new(0, 125, 0, 2))
makeLabel(page1, "Speed", UDim2.new(0, 125, 0, -12))

local speedBox = makeBox(page1, "16", UDim2.new(0, 195, 0, 2))
makeLabel(page1, "Walk", UDim2.new(0, 195, 0, -12))

local jumpBox = makeBox(page1, "50", UDim2.new(0, 265, 0, 2))
makeLabel(page1, "Jump", UDim2.new(0, 265, 0, -12))

local applyBtn = makeBtn(page1, "Aplicar", UDim2.new(0, 335, 0, 0), UDim2.new(0, 90, 0, 28), Color3.fromRGB(130, 45, 45))

local infBtn = makeBtn(page1, "Inf Jump: OFF", UDim2.new(0, 0, 0, 38))
local noclipBtn = makeBtn(page1, "Noclip: OFF", UDim2.new(0, 125, 0, 38))
local hipBtn = makeBtn(page1, "HipHeight +", UDim2.new(0, 250, 0, 38))

-- ========== PAGE 2 : TELEPORT ==========
local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, 0, 1, 0)
list.BackgroundColor3 = Color3.fromRGB(22, 15, 25)
list.BackgroundTransparency = 0.35
list.BorderSizePixel = 0
list.ScrollBarThickness = 3
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.Parent = page2
Instance.new("UICorner", list).CornerRadius = UDim.new(0, 8)

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.FillDirection = Enum.FillDirection.Horizontal
listLayout.Parent = list

-- ========== PAGE 3 : ADMIN ==========
local invisBtn = makeBtn(page3, "Invisível: OFF", UDim2.new(0, 0, 0, 0))
local godBtn = makeBtn(page3, "GodMode: OFF", UDim2.new(0, 125, 0, 0))
local resetBtn = makeBtn(page3, "Reset", UDim2.new(0, 250, 0, 0), UDim2.new(0, 90, 0, 28), Color3.fromRGB(130, 45, 45))
local rejoinBtn = makeBtn(page3, "Rejoin", UDim2.new(0, 350, 0, 0), UDim2.new(0, 90, 0, 28), Color3.fromRGB(130, 45, 45))

local serverHopBtn = makeBtn(page3, "Server Hop", UDim2.new(0, 0, 0, 38), UDim2.new(0, 140, 0, 28), Color3.fromRGB(90, 40, 90))

-- ========== PAGE 4 : VISUAL ==========
local fbBtn = makeBtn(page4, "Fullbright: OFF", UDim2.new(0, 0, 0, 0))
local fogBtn = makeBtn(page4, "No Fog: OFF", UDim2.new(0, 125, 0, 0))
local fovBox = makeBox(page4, "70", UDim2.new(0, 260, 0, 2))
makeLabel(page4, "FOV", UDim2.new(0, 260, 0, -12))
local fovBtn = makeBtn(page4, "Aplicar FOV", UDim2.new(0, 330, 0, 0), UDim2.new(0, 100, 0, 28), Color3.fromRGB(130, 45, 45))

-- Botões flutuantes
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 44, 0, 44)
openBtn.Position = UDim2.new(0, 12, 1, -160)
openBtn.BackgroundColor3 = Color3.fromRGB(110, 35, 35)
openBtn.BackgroundTransparency = 0.15
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
upBtn.BackgroundTransparency = 0.12
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
downBtn.BackgroundTransparency = 0.12
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
	flyBtn.BackgroundColor3 = Color3.fromRGB(45, 28, 38)
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
		flyBtn.BackgroundColor3 = Color3.fromRGB(45, 28, 38)
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

-- Aplicar
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

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
	if infJump and humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

local function toggleInf()
	infJump = not infJump
	infBtn.Text = infJump and "Inf Jump: ON" or "Inf Jump: OFF"
	infBtn.BackgroundColor3 = infJump and Color3.fromRGB(40, 140, 80) or Color3.fromRGB(45, 28, 38)
end

-- Noclip
local function toggleNoclip()
	noclip = not noclip
	noclipBtn.Text = noclip and "Noclip: ON" or "Noclip: OFF"
	noclipBtn.BackgroundColor3 = noclip and Color3.fromRGB(40, 140, 80) or Color3.fromRGB(45, 28, 38)
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

-- HipHeight
local function addHip()
	updateChar()
	if humanoid then
		humanoid.HipHeight = humanoid.HipHeight + 1.5
	end
end

-- Invisível
local function toggleInvis()
	updateChar()
	invisible = not invisible
	invisBtn.Text = invisible and "Invisível: ON" or "Invisível: OFF"
	invisBtn.BackgroundColor3 = invisible and Color3.fromRGB(40, 140, 80) or Color3.fromRGB(45, 28, 38)
	if character then
		for _, p in ipairs(character:GetDescendants()) do
			if p:IsA("BasePart") or p:IsA("Decal") then
				p.Transparency = invisible and 1 or 0
			end
		end
		if character:FindFirstChild("Head") and character.Head:FindFirstChild("face") then
			character.Head.face.Transparency = invisible and 1 or 0
		end
	end
end

-- GodMode (client)
local function toggleGod()
	godmode = not godmode
	godBtn.Text = godmode and "GodMode: ON" or "GodMode: OFF"
	godBtn.BackgroundColor3 = godmode and Color3.fromRGB(40, 140, 80) or Color3.fromRGB(45, 28, 38)
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

-- Teleport
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
			b.BackgroundColor3 = Color3.fromRGB(50, 30, 42)
			b.BackgroundTransparency = 0.2
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
	fbBtn.BackgroundColor3 = fullbright and Color3.fromRGB(40, 140, 80) or Color3.fromRGB(45, 28, 38)
	if fullbright then
		Lighting.Brightness = 3.5
		Lighting.ClockTime = 12
		Lighting.FogEnd = 9e9
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
		Lighting.Ambient = Color3.fromRGB(160, 160, 160)
	else
		Lighting.Brightness = 1
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = true
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
		Lighting.Ambient = Color3.fromRGB(0, 0, 0)
	end
end

-- No Fog
local function toggleFog()
	local on = fogBtn.Text:find("ON")
	fogBtn.Text = on and "No Fog: OFF" or "No Fog: ON"
	fogBtn.BackgroundColor3 = on and Color3.fromRGB(45, 28, 38) or Color3.fromRGB(40, 140, 80)
	Lighting.FogEnd = on and 100000 or 9e9
end

-- FOV
local function applyFOV()
	local v = tonumber(fovBox.Text)
	if v and v >= 1 and v <= 120 then
		camera.FieldOfView = v
		task.spawn(function()
			for i = 1, 8 do
				camera.FieldOfView = v
				task.wait(0.03)
			end
		end)
	end
end

-- Rejoin / ServerHop
local function rejoin()
	TeleportService:Teleport(game.PlaceId, player)
end

local function serverHop()
	local ok, result = pcall(function()
		return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
	end)
	if ok and result and result.data then
		for _, server in ipairs(result.data) do
			if server.playing < server.maxPlayers and server.id ~= game.JobId then
				TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, player)
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
invisBtn.MouseButton1Click:Connect(toggleInvis)
godBtn.MouseButton1Click:Connect(toggleGod)
resetBtn.MouseButton1Click:Connect(function() if humanoid then humanoid.Health = 0 end end)
rejoinBtn.MouseButton1Click:Connect(rejoin)
serverHopBtn.MouseButton1Click:Connect(serverHop)
fbBtn.MouseButton1Click:Connect(toggleFB)
fogBtn.MouseButton1Click:Connect(toggleFog)
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

print("✅ Dragon Admin Panel carregado!")