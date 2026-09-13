-- Painel de Utilidades (Fly, Teleport, Speed)
-- LocalScript → StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Configurações
local FLY_SPEED = 50
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
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 280, 0, 380)
mainFrame.Position = UDim2.new(0, 20, 0.5, -190)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 80, 120)
stroke.Thickness = 2
stroke.Parent = mainFrame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
title.Text = "⚡ Painel de Utilidades"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = title

-- Botão Fly
local flyButton = Instance.new("TextButton")
flyButton.Name = "FlyButton"
flyButton.Size = UDim2.new(1, -20, 0, 40)
flyButton.Position = UDim2.new(0, 10, 0, 55)
flyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
flyButton.Text = "🕊️ Fly: OFF"
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.Font = Enum.Font.Gotham
flyButton.TextSize = 16
flyButton.Parent = mainFrame

local flyCorner = Instance.new("UICorner")
flyCorner.CornerRadius = UDim.new(0, 8)
flyCorner.Parent = flyButton

-- Botão Speed
local speedButton = Instance.new("TextButton")
speedButton.Name = "SpeedButton"
speedButton.Size = UDim2.new(1, -20, 0, 40)
speedButton.Position = UDim2.new(0, 10, 0, 105)
speedButton.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
speedButton.Text = "🏃 Correr Rápido: OFF"
speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedButton.Font = Enum.Font.Gotham
speedButton.TextSize = 16
speedButton.Parent = mainFrame

local speedCorner = Instance.new("UICorner")
speedCorner.CornerRadius = UDim.new(0, 8)
speedCorner.Parent = speedButton

-- Título da lista de jogadores
local listTitle = Instance.new("TextLabel")
listTitle.Size = UDim2.new(1, -20, 0, 25)
listTitle.Position = UDim2.new(0, 10, 0, 160)
listTitle.BackgroundTransparency = 1
listTitle.Text = "Teleportar para:"
listTitle.TextColor3 = Color3.fromRGB(200, 200, 220)
listTitle.Font = Enum.Font.Gotham
listTitle.TextSize = 14
listTitle.TextXAlignment = Enum.TextXAlignment.Left
listTitle.Parent = mainFrame

-- ScrollingFrame com lista de jogadores
local playerList = Instance.new("ScrollingFrame")
playerList.Name = "PlayerList"
playerList.Size = UDim2.new(1, -20, 0, 160)
playerList.Position = UDim2.new(0, 10, 0, 190)
playerList.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 6
playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
playerList.Parent = mainFrame

local listCorner = Instance.new("UICorner")
listCorner.CornerRadius = UDim.new(0, 8)
listCorner.Parent = playerList

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = playerList

-- Botão fechar
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 16
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

-- ======================
-- FUNÇÕES
-- ======================

local function updateCharacter()
	character = player.Character
	if character then
		humanoid = character:WaitForChild("Humanoid")
		rootPart = character:WaitForChild("HumanoidRootPart")
	end
end

player.CharacterAdded:Connect(function()
	updateCharacter()
	flying = false
	fastRunning = false
	if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
	if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
	flyButton.Text = "🕊️ Fly: OFF"
	flyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
	speedButton.Text = "🏃 Correr Rápido: OFF"
	speedButton.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
end)

-- Fly
local function toggleFly()
	updateCharacter()
	if not character or not rootPart then return end

	flying = not flying

	if flying then
		flyButton.Text = "🕊️ Fly: ON"
		flyButton.BackgroundColor3 = Color3.fromRGB(40, 140, 80)

		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bodyVelocity.Velocity = Vector3.zero
		bodyVelocity.Parent = rootPart

		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bodyGyro.P = 10000
		bodyGyro.Parent = rootPart

		humanoid.PlatformStand = true
	else
		flyButton.Text = "🕊️ Fly: OFF"
		flyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 80)

		if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
		if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
		humanoid.PlatformStand = false
	end
end

-- Controle do Fly
RunService.RenderStepped:Connect(function()
	if flying and bodyVelocity and bodyGyro and rootPart then
		local cam = workspace.CurrentCamera
		local moveDirection = Vector3.zero

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			moveDirection = moveDirection + cam.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			moveDirection = moveDirection - cam.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			moveDirection = moveDirection - cam.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			moveDirection = moveDirection + cam.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			moveDirection = moveDirection + Vector3.new(0, 1, 0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
			moveDirection = moveDirection - Vector3.new(0, 1, 0)
		end

		if moveDirection.Magnitude > 0 then
			moveDirection = moveDirection.Unit * FLY_SPEED
		end

		bodyVelocity.Velocity = moveDirection
		bodyGyro.CFrame = cam.CFrame
	end
end)

-- Speed
local function toggleSpeed()
	updateCharacter()
	if not humanoid then return end

	fastRunning = not fastRunning

	if fastRunning then
		humanoid.WalkSpeed = FAST_SPEED
		speedButton.Text = "🏃 Correr Rápido: ON"
		speedButton.BackgroundColor3 = Color3.fromRGB(40, 140, 80)
	else
		humanoid.WalkSpeed = NORMAL_SPEED
		speedButton.Text = "🏃 Correr Rápido: OFF"
		speedButton.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
	end
end

-- Teleport
local function teleportToPlayer(targetPlayer)
	updateCharacter()
	if not rootPart or not targetPlayer.Character then return end

	local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if targetRoot then
		rootPart.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3) -- 3 studs atrás
	end
end

-- Atualizar lista de jogadores
local function refreshPlayerList()
	-- Limpar lista
	for _, child in ipairs(playerList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local yOffset = 0
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, -10, 0, 32)
			btn.BackgroundColor3 = Color3.fromRGB(60, 60, 90)
			btn.Text = plr.Name
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 14
			btn.Parent = playerList

			local btnCorner = Instance.new("UICorner")
			btnCorner.CornerRadius = UDim.new(0, 6)
			btnCorner.Parent = btn

			btn.MouseButton1Click:Connect(function()
				teleportToPlayer(plr)
			end)

			yOffset = yOffset + 37
		end
	end

	playerList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- ======================
-- CONEXÕES
-- ======================
flyButton.MouseButton1Click:Connect(toggleFly)
speedButton.MouseButton1Click:Connect(toggleSpeed)

closeButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

-- Atualizar lista quando jogadores entram/saem
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)

-- Atualizar lista periodicamente (caso alguém mude de nome ou etc)
task.spawn(function()
	while true do
		refreshPlayerList()
		task.wait(3)
	end
end)

-- Atalho para abrir/fechar o painel (tecla P)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.P then
		mainFrame.Visible = not mainFrame.Visible
	end
end)

print("✅ Painel de Utilidades carregado! Pressione P para abrir/fechar.")