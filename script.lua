-- Painel Bonito + Compacto (Mobile)
-- Abas: Main | Teleport
-- Fly, Speed e Super Pulo reguláveis

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Valores
local flySpeed = 50
local walkSpeed = 16
local jumpPower = 50

-- Estados
local flying = false
local bodyVelocity = nil
local bodyGyro = nil
local goingUp = false
local goingDown = false

-- ======================
-- GUI
-- ======================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UtilityPanel"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame principal
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 355)
mainFrame.Position = UDim2.new(0, 12, 0.5, -177)
mainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 24)
mainFrame.BackgroundTransparency = 0.05
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(100, 80, 200)
mainStroke.Thickness = 1.6
mainStroke.Transparency = 0.3
mainStroke.Parent = mainFrame

-- Imagem de fundo (sutil)
local bgImage = Instance.new("ImageLabel")
bgImage.Size = UDim2.new(1, 0, 1, 0)
bgImage.BackgroundTransparency = 1
bgImage.Image = "rbxassetid://7741161580" -- fundo abstrato escuro
bgImage.ImageTransparency = 0.82
bgImage.ScaleType = Enum.ScaleType.Crop
bgImage.Parent = mainFrame

local bgCorner = Instance.new("UICorner")
bgCorner.CornerRadius = UDim.new(0, 14)
bgCorner.Parent = bgImage

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 36)
title.BackgroundColor3 = Color3.fromRGB(28, 22, 48)
title.BackgroundTransparency = 0.15
title.Text = "⚡  PAINEL"
title.TextColor3 = Color3.fromRGB(230, 220, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 14)
titleCorner.Parent = title

-- Botão fechar
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 26, 0, 26)
closeButton.Position = UDim2.new(1, -31, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(170, 45, 55)
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 13
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 7)
closeCorner.Parent = closeButton

-- Abas
local tabMain = Instance.new("TextButton")
tabMain.Size = UDim2.new(0.5, -12, 0, 28)
tabMain.Position = UDim2.new(0, 8, 0, 42)
tabMain.BackgroundColor3 = Color3.fromRGB(90, 60, 180)
tabMain.Text = "Main"
tabMain.TextColor3 = Color3.fromRGB(255, 255, 255)
tabMain.Font = Enum.Font.GothamBold
tabMain.TextSize = 13
tabMain.Parent = mainFrame
Instance.new("UICorner", tabMain).CornerRadius = UDim.new(0, 8)

local tabTeleport = Instance.new("TextButton")
tabTeleport.Size = UDim2.new(0.5, -12, 0, 28)
tabTeleport.Position = UDim2.new(0.5, 4, 0, 42)
tabTeleport.BackgroundColor3 = Color3.fromRGB(35, 30, 55)
tabTeleport.Text = "Teleport"
tabTeleport.TextColor3 = Color3.fromRGB(200, 200, 220)
tabTeleport.Font = Enum.Font.GothamBold
tabTeleport.TextSize = 13
tabTeleport.Parent = mainFrame
Instance.new("UICorner", tabTeleport).CornerRadius = UDim.new(0, 8)

-- ======================
-- ABA MAIN
-- ======================
local mainPage = Instance.new("Frame")
mainPage.Size = UDim2.new(1, -16, 1, -80)
mainPage.Position = UDim2.new(0, 8, 0, 76)
mainPage.BackgroundTransparency = 1
mainPage.Parent = mainFrame

-- Fly
local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(1, 0, 0, 34)
flyButton.BackgroundColor3 = Color3.fromRGB(45, 40, 75)
flyButton.Text = "🕊️  Fly: OFF"
flyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
flyButton.Font = Enum.Font.GothamMedium
flyButton.TextSize = 14
flyButton.Parent = mainPage
Instance.new("UICorner", flyButton).CornerRadius = UDim.new(0, 9)

-- Fly Speed
local flySpeedLabel = Instance.new("TextLabel")
flySpeedLabel.Size = UDim2.new(1, 0, 0, 18)
flySpeedLabel.Position = UDim2.new(0, 0, 0, 42)
flySpeedLabel.BackgroundTransparency = 1
flySpeedLabel.Text = "Fly Speed: 50"
flySpeedLabel.TextColor3 = Color3.fromRGB(180, 170, 220)
flySpeedLabel.Font = Enum.Font.Gotham
flySpeedLabel.TextSize = 12
flySpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
flySpeedLabel.Parent = mainPage

local flySpeedBox = Instance.new("TextBox")
flySpeedBox.Size = UDim2.new(1, 0, 0, 28)
flySpeedBox.Position = UDim2.new(0, 0, 0, 60)
flySpeedBox.BackgroundColor3 = Color3.fromRGB(30, 26, 50)
flySpeedBox.Text = "50"
flySpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
flySpeedBox.Font = Enum.Font.Gotham
flySpeedBox.TextSize = 13
flySpeedBox.Parent = mainPage
Instance.new("UICorner", flySpeedBox).CornerRadius = UDim.new(0, 8)

-- Walk Speed
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, 0, 0, 18)
speedLabel.Position = UDim2.new(0, 0, 0, 96)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Walk Speed: 16"
speedLabel.TextColor3 = Color3.fromRGB(180, 170, 220)
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 12
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = mainPage

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(1, 0, 0, 28)
speedBox.Position = UDim2.new(0, 0, 0, 114)
speedBox.BackgroundColor3 = Color3.fromRGB(30, 26, 50)
speedBox.Text = "16"
speedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 13
speedBox.Parent = mainPage
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 8)

-- Jump
local jumpLabel = Instance.new("TextLabel")
jumpLabel.Size = UDim2.new(1, 0, 0, 18)
jumpLabel.Position = UDim2.new(0, 0, 0, 150)
jumpLabel.BackgroundTransparency = 1
jumpLabel.Text = "Super Pulo: 50"
jumpLabel.TextColor3 = Color3.fromRGB(180, 170, 220)
jumpLabel.Font = Enum.Font.Gotham
jumpLabel.TextSize = 12
jumpLabel.TextXAlignment = Enum.TextXAlignment.Left
jumpLabel.Parent = mainPage

local jumpBox = Instance.new("TextBox")
jumpBox.Size = UDim2.new(1, 0, 0, 28)
jumpBox.Position = UDim2.new(0, 0, 0, 168)
jumpBox.BackgroundColor3 = Color3.fromRGB(30, 26, 50)
jumpBox.Text = "50"
jumpBox.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpBox.Font = Enum.Font.Gotham
jumpBox.TextSize = 13
jumpBox.Parent = mainPage
Instance.new("UICorner", jumpBox).CornerRadius = UDim.new(0, 8)

-- Aplicar
local applyButton = Instance.new("TextButton")
applyButton.Size = UDim2.new(1, 0, 0, 34)
applyButton.Position = UDim2.new(0, 0, 0, 210)
applyButton.BackgroundColor3 = Color3.fromRGB(70, 50, 160)
applyButton.Text = "Aplicar Valores"
applyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
applyButton.Font = Enum.Font.GothamBold
applyButton.TextSize = 14
applyButton.Parent = mainPage
Instance.new("UICorner", applyButton).CornerRadius = UDim.new(0, 9)

-- ======================
-- ABA TELEPORT
-- ======================
local teleportPage = Instance.new("Frame")
teleportPage.Size = UDim2.new(1, -16, 1, -80)
teleportPage.Position = UDim2.new(0, 8, 0, 76)
teleportPage.BackgroundTransparency = 1
teleportPage.Visible = false
teleportPage.Parent = mainFrame

local listTitle = Instance.new("TextLabel")
listTitle.Size = UDim2.new(1, 0, 0, 20)
listTitle.BackgroundTransparency = 1
listTitle.Text = "Clique para teleportar:"
listTitle.TextColor3 = Color3.fromRGB(180, 170, 220)
listTitle.Font = Enum.Font.Gotham
listTitle.TextSize = 12
listTitle.TextXAlignment = Enum.TextXAlignment.Left
listTitle.Parent = teleportPage

local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(1, 0, 1, -24)
playerList.Position = UDim2.new(0, 0, 0, 22)
playerList.BackgroundColor3 = Color3.fromRGB(25, 22, 42)
playerList.BackgroundTransparency = 0.25
playerList.BorderSizePixel = 0
playerList.ScrollBarThickness = 4
playerList.CanvasSize = UDim2.new(0, 0, 0, 0)
playerList.Parent = teleportPage
Instance.new("UICorner", playerList).CornerRadius = UDim.new(0, 9)

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.Parent = playerList

-- Botão flutuante
local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(0, 48, 0, 48)
openButton.Position = UDim2.new(0, 12, 0.5, -24)
openButton.BackgroundColor3 = Color3.fromRGB(60, 45, 120)
openButton.BackgroundTransparency = 0.1
openButton.Text = "⚡"
openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openButton.Font = Enum.Font.GothamBold
openButton.TextSize = 20
openButton.Visible = false
openButton.Parent = screenGui
Instance.new("UICorner", openButton).CornerRadius = UDim.new(1, 0)

-- Botões de subir/descer
local upButton = Instance.new("TextButton")
upButton.Size = UDim2.new(0, 54, 0, 54)
upButton.Position = UDim2.new(1, -68, 0.5, -68)
upButton.BackgroundColor3 = Color3.fromRGB(50, 130, 80)
upButton.BackgroundTransparency = 0.1
upButton.Text = "↑"
upButton.TextColor3 = Color3.fromRGB(255, 255, 255)
upButton.Font = Enum.Font.GothamBold
upButton.TextSize = 22
upButton.Visible = false
upButton.Parent = screenGui
Instance.new("UICorner", upButton).CornerRadius = UDim.new(0, 12)

local downButton = Instance.new("TextButton")
downButton.Size = UDim2.new(0, 54, 0, 54)
downButton.Position = UDim2.new(1, -68, 0.5, 18)
downButton.BackgroundColor3 = Color3.fromRGB(150, 45, 55)
downButton.BackgroundTransparency = 0.1
downButton.Text = "↓"
downButton.TextColor3 = Color3.fromRGB(255, 255, 255)
downButton.Font = Enum.Font.GothamBold
downButton.TextSize = 22
downButton.Visible = false
downButton.Parent = screenGui
Instance.new("UICorner", downButton).CornerRadius = UDim.new(0, 12)

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
	task.wait(0.4)
	updateCharacter()
	flying = false
	goingUp = false
	goingDown = false
	if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
	if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
	flyButton.Text = "🕊️  Fly: OFF"
	flyButton.BackgroundColor3 = Color3.fromRGB(45, 40, 75)
	upButton.Visible = false
	downButton.Visible = false
	if humanoid then
		humanoid.WalkSpeed = walkSpeed
		humanoid.UseJumpPower = true
		humanoid.JumpPower = jumpPower
	end
end)

local function showMain()
	mainPage.Visible = true
	teleportPage.Visible = false
	tabMain.BackgroundColor3 = Color3.fromRGB(90, 60, 180)
	tabMain.TextColor3 = Color3.fromRGB(255, 255, 255)
	tabTeleport.BackgroundColor3 = Color3.fromRGB(35, 30, 55)
	tabTeleport.TextColor3 = Color3.fromRGB(200, 200, 220)
end

local function showTeleport()
	mainPage.Visible = false
	teleportPage.Visible = true
	tabMain.BackgroundColor3 = Color3.fromRGB(35, 30, 55)
	tabMain.TextColor3 = Color3.fromRGB(200, 200, 220)
	tabTeleport.BackgroundColor3 = Color3.fromRGB(90, 60, 180)
	tabTeleport.TextColor3 = Color3.fromRGB(255, 255, 255)
end

tabMain.MouseButton1Click:Connect(showMain)
tabTeleport.MouseButton1Click:Connect(showTeleport)

-- Fly
local function toggleFly()
	updateCharacter()
	if not character or not rootPart or not humanoid then return end

	flying = not flying
	if flying then
		flyButton.Text = "🕊️  Fly: ON"
		flyButton.BackgroundColor3 = Color3.fromRGB(40, 140, 80)

		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bodyVelocity.Velocity = Vector3.zero
		bodyVelocity.Parent = rootPart

		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bodyGyro.P = 9000
		bodyGyro.Parent = rootPart

		humanoid.PlatformStand = true
		upButton.Visible = true
		downButton.Visible = true
	else
		flyButton.Text = "🕊️  Fly: OFF"
		flyButton.BackgroundColor3 = Color3.fromRGB(45, 40, 75)
		if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
		if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
		humanoid.PlatformStand = false
		goingUp = false
		goingDown = false
		upButton.Visible = false
		downButton.Visible = false
	end
end

RunService.RenderStepped:Connect(function()
	if flying and bodyVelocity and bodyGyro and rootPart and humanoid then
		local cam = workspace.CurrentCamera
		local move = humanoid.MoveDirection
		local velocity = Vector3.zero

		if move.Magnitude > 0.05 then
			velocity = move * flySpeed
		end
		if goingUp then velocity = velocity + Vector3.new(0, flySpeed, 0) end
		if goingDown then velocity = velocity + Vector3.new(0, -flySpeed, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			velocity = velocity + Vector3.new(0, flySpeed, 0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			velocity = velocity + Vector3.new(0, -flySpeed, 0)
		end

		bodyVelocity.Velocity = velocity
		bodyGyro.CFrame = CFrame.new(rootPart.Position, rootPart.Position + cam.CFrame.LookVector)
	end
end)

upButton.MouseButton1Down:Connect(function() goingUp = true end)
upButton.MouseButton1Up:Connect(function() goingUp = false end)
upButton.MouseLeave:Connect(function() goingUp = false end)
downButton.MouseButton1Down:Connect(function() goingDown = true end)
downButton.MouseButton1Up:Connect(function() goingDown = false end)
downButton.MouseLeave:Connect(function() goingDown = false end)

-- Aplicar valores
local function applyValues()
	updateCharacter()
	if not humanoid then return end

	local newFly = tonumber(flySpeedBox.Text)
	local newSpeed = tonumber(speedBox.Text)
	local newJump = tonumber(jumpBox.Text)

	if newFly and newFly > 0 then
		flySpeed = newFly
		flySpeedLabel.Text = "Fly Speed: " .. flySpeed
	end
	if newSpeed and newSpeed > 0 then
		walkSpeed = newSpeed
		humanoid.WalkSpeed = walkSpeed
		speedLabel.Text = "Walk Speed: " .. walkSpeed
	end
	if newJump and newJump > 0 then
		jumpPower = newJump
		humanoid.UseJumpPower = true
		humanoid.JumpPower = jumpPower
		jumpLabel.Text = "Super Pulo: " .. jumpPower
	end
end

-- Teleport mais forte
local function teleportToPlayer(targetPlayer)
	updateCharacter()
	if not rootPart or not targetPlayer.Character then return end

	local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not targetRoot then return end

	local targetCFrame = targetRoot.CFrame * CFrame.new(0, 0, 4)

	for i = 1, 12 do
		rootPart.CFrame = targetCFrame
		rootPart.AssemblyLinearVelocity = Vector3.zero
		rootPart.AssemblyAngularVelocity = Vector3.zero
		task.wait()
	end
end

local function refreshPlayerList()
	for _, child in ipairs(playerList:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	local yOffset = 0
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, -8, 0, 30)
			btn.BackgroundColor3 = Color3.fromRGB(45, 40, 75)
			btn.BackgroundTransparency = 0.1
			btn.Text = plr.DisplayName
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.Font = Enum.Font.Gotham
			btn.TextSize = 13
			btn.Parent = playerList
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)

			btn.MouseButton1Click:Connect(function()
				teleportToPlayer(plr)
			end)
			yOffset = yOffset + 35
		end
	end
	playerList.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

-- Conexões
flyButton.MouseButton1Click:Connect(toggleFly)
applyButton.MouseButton1Click:Connect(applyValues)

closeButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	openButton.Visible = true
end)

openButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = true
	openButton.Visible = false
end)

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

showMain()
print("✅ Painel bonito carregado!")