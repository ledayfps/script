--[[
	DRAGON PANEL - Completo e Otimizado
	Abas: Movement | Teleport | Misc
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Valores
local flySpeed = 60
local walkSpeed = 16
local jumpPower = 50
local fovValue = 70

-- Estados
local flying = false
local noclip = false
local infJump = false
local fullbright = false
local bodyVelocity, bodyGyro = nil, nil
local goingUp, goingDown = false, false
local noclipConnection = nil

-- ======================
-- GUI
-- ======================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DragonPanel"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 260, 0, 390)
main.Position = UDim2.new(0, 12, 0.5, -195)
main.BackgroundColor3 = Color3.fromRGB(12, 10, 20)
main.BackgroundTransparency = 0.08
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = screenGui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(140, 50, 50)
stroke.Thickness = 1.8
stroke.Transparency = 0.25
stroke.Parent = main

-- Fundo Dragão (você pode trocar o ID depois)
local bg = Instance.new("ImageLabel")
bg.Size = UDim2.new(1, 0, 1, 0)
bg.BackgroundTransparency = 1
bg.Image = "rbxassetid://7741161580" -- fundo escuro (troque por um de dragão se quiser)
bg.ImageTransparency = 0.78
bg.ScaleType = Enum.ScaleType.Crop
bg.Parent = main
Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 14)

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundColor3 = Color3.fromRGB(30, 15, 20)
title.BackgroundTransparency = 0.2
title.Text = "🐉  DRAGON PANEL"
title.TextColor3 = Color3.fromRGB(255, 200, 180)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 14)

-- Fechar
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -31, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.Parent = main
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 7)

-- Abas
local function createTab(text, pos)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.333, -8, 0, 26)
	btn.Position = pos
	btn.BackgroundColor3 = Color3.fromRGB(40, 25, 35)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(200, 180, 180)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 12
	btn.Parent = main
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
	return btn
end

local tabMove = createTab("Movement", UDim2.new(0, 6, 0, 42))
local tabTP = createTab("Teleport", UDim2.new(0.333, 3, 0, 42))
local tabMisc = createTab("Misc", UDim2.new(0.666, 0, 0, 42))

tabMove.BackgroundColor3 = Color3.fromRGB(140, 45, 45)
tabMove.TextColor3 = Color3.fromRGB(255, 255, 255)

-- Páginas
local pages = {}
local function createPage()
	local page = Instance.new("Frame")
	page.Size = UDim2.new(1, -12, 1, -78)
	page.Position = UDim2.new(0, 6, 0, 74)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = main
	return page
end

local pageMove = createPage()
local pageTP = createPage()
local pageMisc = createPage()
pageMove.Visible = true

local function switchTab(active)
	pageMove.Visible = active == "move"
	pageTP.Visible = active == "tp"
	pageMisc.Visible = active == "misc"

	tabMove.BackgroundColor3 = active == "move" and Color3.fromRGB(140, 45, 45) or Color3.fromRGB(40, 25, 35)
	tabTP.BackgroundColor3 = active == "tp" and Color3.fromRGB(140, 45, 45) or Color3.fromRGB(40, 25, 35)
	tabMisc.BackgroundColor3 = active == "misc" and Color3.fromRGB(140, 45, 45) or Color3.fromRGB(40, 25, 35)

	tabMove.TextColor3 = active == "move" and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,180,180)
	tabTP.TextColor3 = active == "tp" and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,180,180)
	tabMisc.TextColor3 = active == "misc" and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,180,180)
end

tabMove.MouseButton1Click:Connect(function() switchTab("move") end)
tabTP.MouseButton1Click:Connect(function() switchTab("tp") end)
tabMisc.MouseButton1Click:Connect(function() switchTab("misc") end)

-- ======================
-- FUNÇÕES AUXILIARES DE UI
-- ======================
local function createButton(parent, text, y, color)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 32)
	btn.Position = UDim2.new(0, 0, 0, y)
	btn.BackgroundColor3 = color or Color3.fromRGB(50, 30, 40)
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.Font = Enum.Font.GothamMedium
	btn.TextSize = 13
	btn.Parent = parent
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	return btn
end

local function createLabel(parent, text, y)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, 0, 0, 16)
	lbl.Position = UDim2.new(0, 0, 0, y)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.TextColor3 = Color3.fromRGB(200, 180, 180)
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 11
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = parent
	return lbl
end

local function createBox(parent, text, y)
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, 0, 0, 26)
	box.Position = UDim2.new(0, 0, 0, y)
	box.BackgroundColor3 = Color3.fromRGB(30, 20, 30)
	box.Text = text
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.Font = Enum.Font.Gotham
	box.TextSize = 12
	box.Parent = parent
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 7)
	return box
end

-- ======================
-- ABA MOVEMENT
-- ======================
local flyBtn = createButton(pageMove, "🕊️  Fly: OFF", 0, Color3.fromRGB(50, 30, 40))
local flyLabel = createLabel(pageMove, "Fly Speed: 60", 38)
local flyBox = createBox(pageMove, "60", 54)

local speedLabel = createLabel(pageMove, "Walk Speed: 16", 88)
local speedBox = createBox(pageMove, "16", 104)

local jumpLabel = createLabel(pageMove, "Super Pulo: 50", 138)
local jumpBox = createBox(pageMove, "50", 154)

local applyBtn = createButton(pageMove, "Aplicar Valores", 190, Color3.fromRGB(120, 40, 40))
local infJumpBtn = createButton(pageMove, "Infinite Jump: OFF", 230, Color3.fromRGB(50, 30, 40))
local noclipBtn = createButton(pageMove, "Noclip: OFF", 268, Color3.fromRGB(50, 30, 40))

-- ======================
-- ABA TELEPORT
-- ======================
local tpTitle = createLabel(pageTP, "Clique para teleportar:", 0)
local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(1, 0, 1, -22)
playerList.Position = UDim2.new(0, 0, 0, 20)
playerList.BackgroundColor3 = Color3.fromRGB(25, 15, 25)
playerList.BackgroundTransparency = 0.3
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 4
playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
playerList.Parent = pageTP
Instance.new("UICorner", playerList).CornerRadius = UDim.new(0, 8)

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = playerList

-- ======================
-- ABA MISC
-- ======================
local fullbrightBtn = createButton(pageMisc, "Fullbright: OFF", 0, Color3.fromRGB(50, 30, 40))
local resetBtn = createButton(pageMisc, "Reset Character", 40, Color3.fromRGB(120, 40, 40))
local fovLabel = createLabel(pageMisc, "FOV: 70", 88)
local fovBox = createBox(pageMisc, "70", 104)
local fovApply = createButton(pageMisc, "Aplicar FOV", 140, Color3.fromRGB(120, 40, 40))

-- Botões flutuantes
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 46, 0, 46)
openBtn.Position = UDim2.new(0, 12, 0.5, -23)
openBtn.BackgroundColor3 = Color3.fromRGB(100, 30, 30)
openBtn.Text = "🐉"
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 18
openBtn.Visible = false
openBtn.Parent = screenGui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

local upBtn = Instance.new("TextButton")
upBtn.Size = UDim2.new(0, 52, 0, 52)
upBtn.Position = UDim2.new(1, -66, 0.5, -66)
upBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 60)
upBtn.Text = "↑"
upBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
upBtn.Font = Enum.Font.GothamBold
upBtn.TextSize = 20
upBtn.Visible = false
upBtn.Parent = screenGui
Instance.new("UICorner", upBtn).CornerRadius = UDim.new(0, 11)

local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.new(0, 52, 0, 52)
downBtn.Position = UDim2.new(1, -66, 0.5, 18)
downBtn.BackgroundColor3 = Color3.fromRGB(140, 40, 40)
downBtn.Text = "↓"
downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
downBtn.Font = Enum.Font.GothamBold
downBtn.TextSize = 20
downBtn.Visible = false
downBtn.Parent = screenGui
Instance.new("UICorner", downBtn).CornerRadius = UDim.new(0, 11)

-- ======================
-- LÓGICA
-- ======================
local function updateChar()
	character = player.Character
	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
		rootPart = character:FindFirstChild("HumanoidRootPart")
	end
end

player.CharacterAdded:Connect(function()
	task.wait(0.4)
	updateChar()
	flying = false
	goingUp = false
	goingDown = false
	if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
	if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
	flyBtn.Text = "🕊️  Fly: OFF"
	flyBtn.BackgroundColor3 = Color3.fromRGB(50, 30, 40)
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
		flyBtn.Text = "🕊️  Fly: ON"
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
		flyBtn.Text = "🕊️  Fly: OFF"
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
		local cam = workspace.CurrentCamera
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
		bodyGyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + cam.CFrame.LookVector)
	end
end)

upBtn.MouseButton1Down:Connect(function() goingUp = true end)
upBtn.MouseButton1Up:Connect(function() goingUp = false end)
upBtn.MouseLeave:Connect(function() goingUp = false end)
downBtn.MouseButton1Down:Connect(function() goingDown = true end)
downBtn.MouseButton1Up:Connect(function() goingDown = false end)
downBtn.MouseLeave:Connect(function() goingDown = false end)

-- Aplicar valores
local function applyValues()
	updateChar()
	if not humanoid then return end

	local f = tonumber(flyBox.Text)
	local s = tonumber(speedBox.Text)
	local j = tonumber(jumpBox.Text)

	if f and f > 0 then flySpeed = f flyLabel.Text = "Fly Speed: " .. f end
	if s and s > 0 then walkSpeed = s humanoid.WalkSpeed = s speedLabel.Text = "Walk Speed: " .. s end
	if j and j > 0 then
		jumpPower = j
		humanoid.UseJumpPower = true
		humanoid.JumpPower = j
		jumpLabel.Text = "Super Pulo: " .. j
	end
end

-- Infinite Jump
local function toggleInfJump()
	infJump = not infJump
	infJumpBtn.Text = infJump and "Infinite Jump: ON" or "Infinite Jump: OFF"
	infJumpBtn.BackgroundColor3 = infJump and Color3.fromRGB(40, 130, 70) or Color3.fromRGB(50, 30, 40)
end

UserInputService.JumpRequest:Connect(function()
	if infJump and humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- Noclip
local function toggleNoclip()
	noclip = not noclip
	noclipBtn.Text = noclip and "Noclip: ON" or "Noclip: OFF"
	noclipBtn.BackgroundColor3 = noclip and Color3.fromRGB(40, 130, 70) or Color3.fromRGB(50, 30, 40)

	if noclip then
		noclipConnection = RunService.Stepped:Connect(function()
			if character then
				for _, part in ipairs(character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		end)
	else
		if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
	end
end

-- Teleport forte
local function teleportTo(plr)
	updateChar()
	if not rootPart or not plr.Character then return end
	local target = plr.Character:FindFirstChild("HumanoidRootPart")
	if not target then return end

	local cf = target.CFrame * CFrame.new(0, 0, 4)
	for i = 1, 15 do
		rootPart.CFrame = cf
		rootPart.AssemblyLinearVelocity = Vector3.zero
		rootPart.AssemblyAngularVelocity = Vector3.zero
		task.wait()
	end
end

local function refreshList()
	for _, c in ipairs(playerList:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	local y = 0
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, -6, 0, 28)
			btn.BackgroundColor3 = Color3.fromRGB(45, 30, 40)
			btn.Text = plr.DisplayName
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 12
			btn.Parent = playerList
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
			btn.MouseButton1Click:Connect(function() teleportTo(plr) end)
			y = y + 33
		end
	end
	playerList.CanvasSize = UDim2.new(0, 0, 0, y)
end

-- Fullbright
local function toggleFullbright()
	fullbright = not fullbright
	fullbrightBtn.Text = fullbright and "Fullbright: ON" or "Fullbright: OFF"
	fullbrightBtn.BackgroundColor3 = fullbright and Color3.fromRGB(40, 130, 70) or Color3.fromRGB(50, 30, 40)

	if fullbright then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	else
		Lighting.Brightness = 1
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = true
		Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	end
end

-- FOV
local function applyFOV()
	local v = tonumber(fovBox.Text)
	if v and v >= 1 and v <= 120 then
		fovValue = v
		workspace.CurrentCamera.FieldOfView = v
		fovLabel.Text = "FOV: " .. v
	end
end

-- Conexões
flyBtn.MouseButton1Click:Connect(toggleFly)
applyBtn.MouseButton1Click:Connect(applyValues)
infJumpBtn.MouseButton1Click:Connect(toggleInfJump)
noclipBtn.MouseButton1Click:Connect(toggleNoclip)
fullbrightBtn.MouseButton1Click:Connect(toggleFullbright)
resetBtn.MouseButton1Click:Connect(function()
	if humanoid then humanoid.Health = 0 end
end)
fovApply.MouseButton1Click:Connect(applyFOV)

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

Players.PlayerAdded:Connect(refreshList)
Players.PlayerRemoving:Connect(refreshList)
task.spawn(function()
	while true do
		refreshList()
		task.wait(4)
	end
end)

print("✅ Dragon Panel carregado com sucesso!")