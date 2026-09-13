-- Painel de Utilidades (Fly, Teleport, Speed) - Mobile + PC
-- LocalScript → StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Configurações
local FLY_SPEED = 60
local NORMAL_SPEED = 16
local FAST_SPEED = 50

-- Estados
local flying = false
local fastRunning = false
local bodyVelocity = nil
local bodyGyro = nil

-- ======================
-- CRIAR GUI
-- ======================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UtilityPanel"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame principal (semi-transparente)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 380)
mainFrame.Position = UDim2.new(0, 15, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.25
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(100, 100, 160)
stroke.Thickness = 1.5
stroke.Transparency = 0.3
stroke.Parent = mainFrame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 42)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
title.BackgroundTransparency = 0.2
title.Text = "⚡ Painel"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 14)
titleCorner.Parent = title

-- Botão Fly
local flyButton = Instance.new("TextButton")
flyButton.Name = "FlyButton"
flyButton.Size = UDim2.new(1, -20, 0, 42)
flyButton.Position = UDim2.new(0, 10, 0, 55)
flyButton.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
flyButton.BackgroundTransparency = 0.15
flyButton.Text = "🕊️ Fly: OFF"
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.Font = Enum.Font.GothamMedium
flyButton.TextSize = 16
flyButton.Parent = mainFrame

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(0, 10)
flyCorner.Parent = flyButton

-- Botão Speed
local speedButton = Instance.new("TextButton")
speedButton.Name = "SpeedButton"
speedButton.Size = UDim2.new(1, -20, 0, 42)
speedButton.Position = UDim2.new(0, 10, 0, 107)
speedButton.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
speedButton.BackgroundTransparency = 0.15
speedButton.Text = "🏃 Speed: OFF"
speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedButton.Font = Enum.Font.GothamMedium
speedButton.TextSize = 16
speedButton.Parent = mainFrame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 10)
speedCorner.Parent = speedButton

-- Título da lista
local listTitle = Instance.new("TextLabel")
listTitle.Size = UDim2.new(1, -20, 0, 25)
listTitle.Position = UDim2.new(0, 10, 0, 160)
listTitle.BackgroundTransparency = 1
listTitle.Text = "Teleportar para:"
listTitle.TextColor3 = Color3.fromRGB(200, 200, 230)
listTitle.Font = Enum.Font.Gotham
listTitle.TextSize = 14
listTitle.TextXAlignment = Enum.TextXAlignment.Left
listTitle.Parent = mainFrame

-- Lista de jogadores
local playerList = Instance.new("ScrollingFrame")
playerList.Name = "PlayerList"
playerList.Size = UDim2.new(1, -20, 0, 155)
playerList.Position = UDim2.new(0, 10, 0, 190)
playerList.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
playerList.BackgroundTransparency = 0.3
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 5
playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
playerList.Parent = mainFrame

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 10)
listCorner.Parent = playerList

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.Parent = playerList

-- Botão fechar (X)
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 32, 0, 32)
closeButton.Position = UDim2.new(1, -38, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(190, 50, 50)
closeButton.BackgroundTransparency = 0.1
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Botão flutuante para reabrir no mobile
local openButton = Instance.new("TextButton")
openButton.Name = "OpenButton"
openButton.Size = UDim2.new(0, 55, 0, 55)
openButton.Position = UDim2.new(0, 15, 0.5, -27)
openButton.BackgroundColor3 = Color3.fromRGB(40, 40, 70)
openButton.BackgroundTransparency = 0.2
openButton.Text = "⚡"
openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openButton.Font = Enum.Font.GothamBold
openButton.TextSize = 24
openButton.Visible = false
openButton.Parent = screenGui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(1, 0)
openCorner.Parent = openButton

local openStroke = Instance.new("UIStroke")
openStroke.Color = Color3.fromRGB(120, 120, 200)
openStroke.Thickness = 1.5
openStroke.Parent = openButton

-- ======================
-- FUNÇÕES
-- ======================

local function updateCharacter()
	character = player.Character
	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
		rootPart = character:FindFirstChild("HumanoidRootPart")
	end
end

player.CharacterAdded:Connect(function()
	task.wait(0.3)
	updateCharacter()
	flying = false
	fastRunning = false
	if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
	if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
	flyButton.Text = "🕊️ Fly: OFF"
	flyButton.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
	speedButton.Text = "🏃 Speed: OFF"
	speedButton.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
end)

-- Fly (funciona no mobile + PC)
local function toggleFly()
	updateCharacter()
	if not character or not rootPart or not humanoid then return end

	flying = not flying

	if flying then
		flyButton.Text = "🕊️ Fly: ON"
		flyButton.BackgroundColor3 = Color3.fromRGB(30, 130, 70)

		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bodyVelocity.Velocity = Vector3.zero
		bodyVelocity.Parent = rootPart

		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bodyGyro.P = 9000
		bodyGyro.Parent = rootPart

		humanoid.PlatformStand = true
	else
		flyButton.Text = "🕊️ Fly: OFF"
		flyButton.BackgroundColor3 = Color3.fromRGB(45, 45, 70)

		if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
		if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
		humanoid.PlatformStand = false
	end
end

-- Controle do Fly (Mobile + PC)
RunService.RenderStepped:Connect(function()
	if flying and bodyVelocity and bodyGyro and rootPart and humanoid then
		local cam = workspace.CurrentCamera
		local move = humanoid.MoveDirection
		local velocity = Vector3.zero

		-- Movimento principal (funciona no joystick do mobile e WASD)
		if move.Magnitude > 0.05 then
			velocity = move * FLY_SPEED
		end

		-- Subir / Descer (PC)
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			velocity = velocity + Vector3.new(0, FLY_SPEED, 0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			velocity = velocity + Vector3.new(0, -FLY_SPEED, 0)
		end

		bodyVelocity.Velocity = velocity
		bodyGyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + cam.CFrame.LookVector)
	end
end)

-- Speed
local function toggleSpeed()
	updateCharacter()
	if not humanoid then return end

	fastRunning = not fastRunning

	if fastRunning then
		humanoid.WalkSpeed = FAST_SPEED
		speedButton.Text = "🏃 Speed: ON"
		speedButton.BackgroundColor3 = Color3.fromRGB(30, 130, 70)
	else
		humanoid.WalkSpeed = NORMAL_SPEED
		speedButton.Text = "🏃 Speed: OFF"
		speedButton.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
	end
end

-- Teleport
local function teleportToPlayer(targetPlayer)
	updateCharacter()
	if not rootPart or not targetPlayer.Character then return end

	local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if targetRoot then
		rootPart.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 4)
	end
end

-- Atualizar lista de jogadores
local function refreshPlayerList()
	for _, child in ipairs(playerList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local yOffset = 0
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, -12, 0, 34)
			btn.BackgroundColor3 = Color3.fromRGB(55, 55, 85)
			btn.BackgroundTransparency = 0.2
			btn.Text = plr.DisplayName
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 14
			btn.Parent = playerList

			local btnCorner = Instance.new("UICorner")
			btnCorner.CornerRadius = UDim.new(0, 8)
			btnCorner.Parent = btn

			btn.MouseButton1Click:Connect(function()
				teleportToPlayer(plr)
			end)

			yOffset = yOffset + 40
		end
	end

	playerList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- ======================
-- CONEXÕES
-- ======================
flyButton.MouseButton1Click:Connect(toggleFly)
speedButton.MouseButton1Click:Connect(toggleSpeed)

-- Fechar painel
closeButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	openButton.Visible = true
end)

-- Reabrir painel (mobile)
openButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = true
	openButton.Visible = false
end)

-- Atalho teclado (PC)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.P then
		mainFrame.Visible = not mainFrame.Visible
		openButton.Visible = not mainFrame.Visible
	end
end)

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)

task.spawn(function()
	while true do
		refreshPlayerList()
		task.wait(4)
	end
end)

print("✅ Painel carregado! (Mobile + PC)")