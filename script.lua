--[[
	DRAGON ADMIN - Sidebar Style
	Abas na esquerda + tudo arrastável
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
local flying, noclip, infJump, fullbright, invisible, godmode = false, false, false, false, false, false
local clickTP, espEnabled, spinEnabled, antiAFK = false, false, false, false
local bodyVelocity, bodyGyro = nil, nil
local goingUp, goingDown = false, false
local noclipConn, godConn, spinConn, afkConn = nil, nil, nil, nil

-- ======================
-- GUI
-- ======================
local gui = Instance.new("ScreenGui")
gui.Name = "DragonAdmin"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

-- Painel principal
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 420, 0, 280)
main.Position = UDim2.new(0.5, -210, 0.5, -140)
main.BackgroundColor3 = Color3.fromRGB(12, 10, 18)
main.BackgroundTransparency = 0.15
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true          -- << arrastável
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(180, 55, 55)
stroke.Thickness = 1.5
stroke.Transparency = 0.3
stroke.Parent = main

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(22, 14, 22)
title.BackgroundTransparency = 0.2
title.Text = "🐉  DRAGON ADMIN"
title.TextColor3 = Color3.fromRGB(255, 200, 180)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

-- Fechar
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -30, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(170, 35, 35)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.Parent = main
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

-- ===== SIDEBAR (esquerda) =====
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 110, 1, -36)
sidebar.Position = UDim2.new(0, 6, 0, 34)
sidebar.BackgroundColor3 = Color3.fromRGB(18, 14, 24)
sidebar.BackgroundTransparency = 0.25
sidebar.BorderSizePixel = 0
sidebar.Parent = main
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding = UDim.new(0, 6)
sideLayout.Parent = sidebar

local sidePadding = Instance.new("UIPadding")
sidePadding.PaddingTop = UDim.new(0, 8)
sidePadding.PaddingLeft = UDim.new(0, 6)
sidePadding.PaddingRight = UDim.new(0, 6)
sidePadding.Parent = sidebar

local function createSideBtn(text)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 32)
	b.BackgroundColor3 = Color3.fromRGB(35, 22, 32)
	b.BackgroundTransparency = 0.2
	b.Text = text
	b.TextColor3 = Color3.fromRGB(190, 170, 180)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 12
	b.Parent = sidebar
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
	return b
end

local btnMain     = createSideBtn("Main")
local btnTeleport = createSideBtn("Teleport")
local btnAdmin    = createSideBtn("Admin")
local btnVisual   = createSideBtn("Visual")
local btnExtra    = createSideBtn("Extra")

btnMain.BackgroundColor3 = Color3.fromRGB(150, 45, 45)
btnMain.TextColor3 = Color3.fromRGB(255, 255, 255)

-- ===== CONTEÚDO (direita) =====
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -128, 1, -42)
content.Position = UDim2.new(0, 122, 0, 36)
content.BackgroundTransparency = 1
content.Parent = main

local function createPage()
	local p = Instance.new("Frame")
	p.Size = UDim2.new(1, 0, 1, 0)
	p.BackgroundTransparency = 1
	p.Visible = false
	p.Parent = content
	return p
end

local pageMain     = createPage()
local pageTeleport = createPage()
local pageAdmin    = createPage()
local pageVisual   = createPage()
local pageExtra    = createPage()
pageMain.Visible = true

local function switch(page, activeBtn)
	pageMain.Visible     = page == pageMain
	pageTeleport.Visible = page == pageTeleport
	pageAdmin.Visible    = page == pageAdmin
	pageVisual.Visible   = page == pageVisual
	pageExtra.Visible    = page == pageExtra

	local all = {btnMain, btnTeleport, btnAdmin, btnVisual, btnExtra}
	for _, b in ipairs(all) do
		b.BackgroundColor3 = Color3.fromRGB(35, 22, 32)
		b.TextColor3 = Color3.fromRGB(190, 170, 180)
	end
	activeBtn.BackgroundColor3 = Color3.fromRGB(150, 45, 45)
	activeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end

btnMain.MouseButton1Click:Connect(function() switch(pageMain, btnMain) end)
btnTeleport.MouseButton1Click:Connect(function() switch(pageTeleport, btnTeleport) end)
btnAdmin.MouseButton1Click:Connect(function() switch(pageAdmin, btnAdmin) end)
btnVisual.MouseButton1Click:Connect(function() switch(pageVisual, btnVisual) end)
btnExtra.MouseButton1Click:Connect(function() switch(pageExtra, btnExtra) end)

-- Helpers
local function makeBtn(parent, text, pos, size, color)
	local b = Instance.new("TextButton")
	b.Size = size or UDim2.new(0, 130, 0, 30)
	b.Position = pos
	b.BackgroundColor3 = color or Color3.fromRGB(42, 26, 36)
	b.BackgroundTransparency = 0.15
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
	l.TextColor3 = Color3.fromRGB(185, 165, 175)
	l.Font = Enum.Font.Gotham
	l.TextSize = 11
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

local function makeBox(parent, text, pos)
	local t = Instance.new("TextBox")
	t.Size = UDim2.new(0, 60, 0, 26)
	t.Position = pos
	t.BackgroundColor3 = Color3.fromRGB(28, 18, 28)
	t.BackgroundTransparency = 0.2
	t.Text = text
	t.TextColor3 = Color3.fromRGB(255, 255, 255)
	t.Font = Enum.Font.Gotham
	t.TextSize = 12
	t.Parent = parent
	Instance.new("UICorner", t).CornerRadius = UDim.new(0, 6)
	return t
end

-- ========== MAIN ==========
local flyBtn = makeBtn(pageMain, "🕊️ Fly: OFF", UDim2.new(0, 0, 0, 0))
local flyBox = makeBox(pageMain, "60", UDim2.new(0, 140, 0, 2))
makeLabel(pageMain, "Fly Speed", UDim2.new(0, 140, 0, -12))

local speedBox = makeBox(pageMain, "16", UDim2.new(0, 215, 0, 2))
makeLabel(pageMain, "Walk", UDim2.new(0, 215, 0, -12))

local jumpBox = makeBox(pageMain, "50", UDim2.new(0, 290, 0, 2))
makeLabel(pageMain, "Jump", UDim2.new(0, 290, 0, -12))

local applyBtn = makeBtn(pageMain, "Aplicar", UDim2.new(0, 0, 0, 40), UDim2.new(0, 100, 0, 30), Color3.fromRGB(140, 40, 40))
local infBtn = makeBtn(pageMain, "Inf Jump: OFF", UDim2.new(0, 110, 0, 40))
local noclipBtn = makeBtn(pageMain, "Noclip: OFF", UDim2.new(0, 0, 0, 80))
local hipBtn = makeBtn(pageMain, "HipHeight +", UDim2.new(0, 140, 0, 80))
local sitBtn = makeBtn(pageMain, "Sit / Unsit", UDim2.new(0, 0, 0, 120))

-- ========== TELEPORT ==========
local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, 0, 1, 0)
list.BackgroundColor3 = Color3.fromRGB(20, 14, 24)
list.BackgroundTransparency = 0.3
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.Parent = pageTeleport
Instance.new("UICorner", list).CornerRadius = UDim.new(0, 8)

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.Parent = list

-- ========== ADMIN ==========
local invisBtn = makeBtn(pageAdmin, "Invisível: OFF", UDim2.new(0, 0, 0, 0))
local godBtn = makeBtn(pageAdmin, "GodMode: OFF", UDim2.new(0, 140, 0, 0))
local clickBtn = makeBtn(pageAdmin, "Click TP: OFF", UDim2.new(0, 0, 0, 40))
local resetBtn = makeBtn(pageAdmin, "Reset Char", UDim2.new(0, 140, 0, 40), UDim2.new(0, 130, 0, 30), Color3.fromRGB(140, 40, 40))
local saveBtn = makeBtn(pageAdmin, "Save Position", UDim2.new(0, 0, 0, 80))
local loadBtn = makeBtn(pageAdmin, "Load Position", UDim2.new(0, 140, 0, 80))
local rejoinBtn = makeBtn(pageAdmin, "Rejoin", UDim2.new(0, 0, 0, 120), UDim2.new(0, 130, 0, 30), Color3.fromRGB(140, 40, 40))
local hopBtn = makeBtn(pageAdmin, "Server Hop", UDim2.new(0, 140, 0, 120), UDim2.new(0, 130, 0, 30), Color3.fromRGB(90, 40, 100))

-- ========== VISUAL ==========
local fbBtn = makeBtn(pageVisual, "Fullbright: OFF", UDim2.new(0, 0, 0, 0))
local fogBtn = makeBtn(pageVisual, "No Fog: OFF", UDim2.new(0, 140, 0, 0))
local espBtn = makeBtn(pageVisual, "ESP: OFF", UDim2.new(0, 0, 0, 40))
local fovBox = makeBox(pageVisual, "70", UDim2.new(0, 140, 0, 42))
makeLabel(pageVisual, "FOV", UDim2.new(0, 140, 0, 28))
local fovBtn = makeBtn(pageVisual, "Aplicar FOV", UDim2.new(0, 210, 0, 40), UDim2.new(0, 100, 0, 30), Color3.fromRGB(140, 40, 40))

-- ========== EXTRA ==========
local spinBtn = makeBtn(pageExtra, "Spin: OFF", UDim2.new(0, 0, 0, 0))
local afkBtn = makeBtn(pageExtra, "Anti AFK: OFF", UDim2.new(0, 140, 0, 0))
local fpsBtn = makeBtn(pageExtra, "FPS Boost", UDim2.new(0, 0, 0, 40), UDim2.new(0, 130, 0, 30), Color3.fromRGB(90, 40, 100))
local copyBtn = makeBtn(pageExtra, "Copy Position", UDim2.new(0, 140, 0, 40))

-- Botão flutuante (também arrastável)
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 48, 0, 48)
openBtn.Position = UDim2.new(0, 15, 0.5, -24)
openBtn.BackgroundColor3 = Color3.fromRGB(120, 35, 35)
openBtn.BackgroundTransparency = 0.1
openBtn.Text = "🐉"
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 20
openBtn.Visible = false
openBtn.Active = true
openBtn.Draggable = true          -- << arrastável também
openBtn.Parent = gui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

-- Botões de subir/descer do Fly
local upBtn = Instance.new("TextButton")
upBtn.Size = UDim2.new(0, 50, 0, 50)
upBtn.Position = UDim2.new(1, -65, 0.5, -60)
upBtn.BackgroundColor3 = Color3.fromRGB(40, 130, 70)
upBtn.BackgroundTransparency = 0.1
upBtn.Text = "↑"
upBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
upBtn.Font = Enum.Font.GothamBold
upBtn.TextSize = 22
upBtn.Visible = false
upBtn.Parent = gui
Instance.new("UICorner", upBtn).CornerRadius = UDim.new(0, 10)

local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.new(0, 50, 0, 50)
downBtn.Position = UDim2.new(1, -65, 0.5, 15)
downBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
downBtn.BackgroundTransparency = 0.1
downBtn.Text = "↓"
downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
downBtn.Font = Enum.Font.GothamBold
downBtn.TextSize = 22
downBtn.Visible = false
downBtn.Parent = gui
Instance.new("UICorner", downBtn).CornerRadius = UDim.new(0, 10)

-- ======================
-- LÓGICA DAS FUNÇÕES
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

local function savePos()
	updateChar()
	if rootPart then
		savedCFrame = rootPart.CFrame
		pcall(function()
			StarterGui:SetCore("SendNotification", {Title = "Dragon", Text = "Posição salva!", Duration = 2})
		end)
	end
end

local function loadPos()
	updateChar()
	if rootPart and savedCFrame then
		for i = 1, 10 do
			rootPart.CFrame = savedCFrame
			rootPart.AssemblyLinearVelocity = Vector3.zero
			task.wait()
		end
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
	local y = 0
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player then
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(1, -8, 0, 28)
			b.BackgroundColor3 = Color3.fromRGB(45, 28, 40)
			b.BackgroundTransparency = 0.15
			b.Text = plr.DisplayName
			b.TextColor3 = Color3.fromRGB(255, 255, 255)
			b.Font = Enum.Font.Gotham
			b.TextSize = 12
			b.Parent = list
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
			b.MouseButton1Click:Connect(function() tpTo(plr) end)
			y = y + 34
		end
	end
	list.CanvasSize = UDim2.new(0, 0, 0, y)
end

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

local espFolder = Instance.new("Folder", gui)
espFolder.Name = "ESP"

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
			bill.Size = UDim2.new(0, 120, 0, 28)
			bill.AlwaysOnTop = true
			bill.StudsOffset = Vector3.new(0, 3, 0)
			bill.Adornee = plr.Character.HumanoidRootPart
			bill.Parent = espFolder
			local txt = Instance.new("TextLabel")
			txt.Size = UDim2.new(1, 0, 1, 0)
			txt.BackgroundTransparency = 1
			txt.Text = plr.DisplayName
			txt.TextColor3 = Color3.fromRGB(255, 70, 70)
			txt.TextStrokeTransparency = 0.2
			txt.Font = Enum.Font.GothamBold
			txt.TextSize = 13
			txt.Parent = bill
		end
	end
end)

local function applyFOV()
	local v = tonumber(fovBox.Text)
	if v and v >= 1 and v <= 120 then
		camera.FieldOfView = v
		task.spawn(function()
			for i = 1, 8 do camera.FieldOfView = v task.wait(0.03) end
		end)
	end
end

local function toggleSpin()
	spinEnabled = not spinEnabled
	spinBtn.Text = spinEnabled and "Spin: ON" or "Spin: OFF"
	spinBtn.BackgroundColor3 = spinEnabled and Color3.fromRGB(40, 140, 80) or Color3.fromRGB(42, 26, 36)
	if spinEnabled then
		spinConn = RunService.RenderStepped:Connect(function()
			if rootPart then
				rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(14), 0)
			end
		end)
	else
		if spinConn then spinConn:Disconnect() spinConn = nil end
	end
end

local function toggleAFK()
	antiAFK = not antiAFK
	afkBtn.Text = antiAFK and "Anti AFK: ON" or "Anti AFK: OFF"
	afkBtn.BackgroundColor3 = antiAFK and Color3.fromRGB(40, 140, 80) or Color3.fromRGB(42, 26, 36)
	if antiAFK then
		afkConn = RunService.Heartbeat:Connect(function()
			pcall(function()
				local vu = game:GetService("VirtualUser")
				vu:CaptureController()
				vu:ClickButton2(Vector2.new())
			end)
		end)
	else
		if afkConn then afkConn:Disconnect() afkConn = nil end
	end
end

local function fpsBoost()
	pcall(function()
		settings().Rendering.QualityLevel = 1
	end)
	pcall(function()
		StarterGui:SetCore("SendNotification", {Title = "Dragon", Text = "FPS Boost aplicado!", Duration = 2})
	end)
end

local function copyPos()
	updateChar()
	if rootPart then
		local p = rootPart.Position
		pcall(function()
			setclipboard(string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z))
		end)
		pcall(function()
			StarterGui:SetCore("SendNotification", {Title = "Dragon", Text = "Posição copiada!", Duration = 2})
		end)
	end
end

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
saveBtn.MouseButton1Click:Connect(savePos)
loadBtn.MouseButton1Click:Connect(loadPos)
rejoinBtn.MouseButton1Click:Connect(rejoin)
hopBtn.MouseButton1Click:Connect(serverHop)
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
	while true do
		refresh()
		task.wait(4)
	end
end)

print("✅ Dragon Admin (Sidebar) carregado!")