--[[
	DRAGON ADMIN v4
	Mais opções + Click Fling
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")

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

local flySpeed, walkSpeed, jumpPower = 60, 16, 50
local savedCFrame, spectateTarget = nil, nil
local clickDelay = 0.05

local flying, noclip, infJump, fullbright, invisible, godmode = false, false, false, false, false, false
local clickTP, espEnabled, spinEnabled, antiAFK, autoClick, clickFling = false, false, false, false, false, false
local antiFling, rainbow, xray, clickDelete, freezeSelf, shiftLock = false, false, false, false, false, false
local bodyVelocity, bodyGyro = nil, nil
local goingUp, goingDown = false, false
local noclipConn, godConn, spinConn, afkConn, clickConn, antiFlingConn, rainbowConn = nil, nil, nil, nil, nil, nil, nil
local isFlinging = false

local THEME = Color3.fromRGB(170, 45, 70)
local CARD = Color3.fromRGB(28, 18, 30)
local ON = Color3.fromRGB(40, 150, 85)
local OFF = Color3.fromRGB(42, 26, 36)

local function notify(t)
	pcall(function()
		StarterGui:SetCore("SendNotification", {Title = "🐉 Dragon", Text = t, Duration = 2})
	end)
end

local gui = Instance.new("ScreenGui")
gui.Name = "DragonAdmin"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 470, 0, 345)
main.Position = UDim2.new(0.5, -235, 0.5, -172)
main.BackgroundColor3 = Color3.fromRGB(10, 8, 16)
main.BackgroundTransparency = 0.08
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 16)

local stroke = Instance.new("UIStroke")
stroke.Color = THEME
stroke.Thickness = 1.6
stroke.Transparency = 0.25
stroke.Parent = main

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 34)
header.BackgroundColor3 = Color3.fromRGB(22, 12, 20)
header.BackgroundTransparency = 0.15
header.BorderSizePixel = 0
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 16)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -70, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🐉  DRAGON ADMIN  v4"
title.TextColor3 = Color3.fromRGB(255, 205, 190)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 26, 0, 26)
closeBtn.Position = UDim2.new(1, -30, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(175, 40, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 7)

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 108, 1, -44)
sidebar.Position = UDim2.new(0, 8, 0, 40)
sidebar.BackgroundColor3 = Color3.fromRGB(16, 12, 22)
sidebar.BackgroundTransparency = 0.2
sidebar.BorderSizePixel = 0
sidebar.Parent = main
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 12)

local sideLayout = Instance.new("UIListLayout")
sideLayout.Padding = UDim.new(0, 5)
sideLayout.Parent = sidebar
local sidePad = Instance.new("UIPadding")
sidePad.PaddingTop = UDim.new(0, 7)
sidePad.PaddingLeft = UDim.new(0, 6)
sidePad.PaddingRight = UDim.new(0, 6)
sidePad.Parent = sidebar

local function sideBtn(text)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 30)
	b.BackgroundColor3 = CARD
	b.BackgroundTransparency = 0.15
	b.Text = text
	b.TextColor3 = Color3.fromRGB(195, 175, 185)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 11
	b.Parent = sidebar
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
	return b
end

local btnMain, btnTeleport, btnAdmin, btnVisual, btnExtra, btnWorld, btnPlayer =
	sideBtn("Main"), sideBtn("Teleport"), sideBtn("Admin"), sideBtn("Visual"), sideBtn("Extra"), sideBtn("World"), sideBtn("Player")
btnMain.BackgroundColor3 = THEME
btnMain.TextColor3 = Color3.fromRGB(255, 255, 255)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -128, 1, -50)
content.Position = UDim2.new(0, 122, 0, 42)
content.BackgroundTransparency = 1
content.Parent = main

local function page()
	local p = Instance.new("Frame")
	p.Size = UDim2.new(1, 0, 1, 0)
	p.BackgroundTransparency = 1
	p.Visible = false
	p.Parent = content
	return p
end

local pageMain, pageTeleport, pageAdmin, pageVisual, pageExtra, pageWorld, pagePlayer =
	page(), page(), page(), page(), page(), page(), page()
pageMain.Visible = true

local tabs = {
	{pageMain, btnMain}, {pageTeleport, btnTeleport}, {pageAdmin, btnAdmin},
	{pageVisual, btnVisual}, {pageExtra, btnExtra}, {pageWorld, btnWorld}, {pagePlayer, btnPlayer}
}

local function switch(pg, active)
	for _, t in ipairs(tabs) do
		t[1].Visible = t[1] == pg
		t[2].BackgroundColor3 = CARD
		t[2].TextColor3 = Color3.fromRGB(195, 175, 185)
	end
	active.BackgroundColor3 = THEME
	active.TextColor3 = Color3.fromRGB(255, 255, 255)
end

btnMain.MouseButton1Click:Connect(function() switch(pageMain, btnMain) end)
btnTeleport.MouseButton1Click:Connect(function() switch(pageTeleport, btnTeleport) end)
btnAdmin.MouseButton1Click:Connect(function() switch(pageAdmin, btnAdmin) end)
btnVisual.MouseButton1Click:Connect(function() switch(pageVisual, btnVisual) end)
btnExtra.MouseButton1Click:Connect(function() switch(pageExtra, btnExtra) end)
btnWorld.MouseButton1Click:Connect(function() switch(pageWorld, btnWorld) end)
btnPlayer.MouseButton1Click:Connect(function() switch(pagePlayer, btnPlayer) end)

local function makeBtn(parent, text, pos, size, color)
	local b = Instance.new("TextButton")
	b.Size = size or UDim2.new(0, 155, 0, 28)
	b.Position = pos
	b.BackgroundColor3 = color or OFF
	b.BackgroundTransparency = 0.08
	b.Text = text
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 11
	b.Parent = parent
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
	return b
end

local function makeLabel(parent, text, pos)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(0, 90, 0, 13)
	l.Position = pos
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = Color3.fromRGB(190, 170, 180)
	l.Font = Enum.Font.Gotham
	l.TextSize = 10
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

local function makeBox(parent, text, pos)
	local t = Instance.new("TextBox")
	t.Size = UDim2.new(0, 54, 0, 24)
	t.Position = pos
	t.BackgroundColor3 = Color3.fromRGB(24, 16, 26)
	t.Text = text
	t.TextColor3 = Color3.fromRGB(255, 255, 255)
	t.Font = Enum.Font.Gotham
	t.TextSize = 11
	t.Parent = parent
	Instance.new("UICorner", t).CornerRadius = UDim.new(0, 6)
	return t
end

local function setToggle(btn, on, onT, offT)
	btn.Text = on and onT or offT
	btn.BackgroundColor3 = on and ON or OFF
end

-- MAIN
local flyBtn = makeBtn(pageMain, "🕊️ Fly: OFF", UDim2.new(0, 0, 0, 0))
local flyBox = makeBox(pageMain, "60", UDim2.new(0, 165, 0, 2))
makeLabel(pageMain, "Fly", UDim2.new(0, 165, 0, -11))
local speedBox = makeBox(pageMain, "16", UDim2.new(0, 228, 0, 2))
makeLabel(pageMain, "Walk", UDim2.new(0, 228, 0, -11))
local jumpBox = makeBox(pageMain, "50", UDim2.new(0, 291, 0, 2))
makeLabel(pageMain, "Jump", UDim2.new(0, 291, 0, -11))
local applyBtn = makeBtn(pageMain, "Aplicar", UDim2.new(0, 0, 0, 36), UDim2.new(0, 90, 0, 28), THEME)
local infBtn = makeBtn(pageMain, "Inf Jump: OFF", UDim2.new(0, 100, 0, 36))
local noclipBtn = makeBtn(pageMain, "Noclip: OFF", UDim2.new(0, 0, 0, 72))
local hipBtn = makeBtn(pageMain, "Hip +", UDim2.new(0, 165, 0, 72), UDim2.new(0, 80, 0, 28))
local hipMinus = makeBtn(pageMain, "Hip -", UDim2.new(0, 253, 0, 72), UDim2.new(0, 80, 0, 28))
local sitBtn = makeBtn(pageMain, "Sit", UDim2.new(0, 0, 0, 108), UDim2.new(0, 80, 0, 28))
local speed50 = makeBtn(pageMain, "Speed 50", UDim2.new(0, 90, 0, 108), UDim2.new(0, 80, 0, 28), THEME)
local speed100 = makeBtn(pageMain, "Speed 100", UDim2.new(0, 178, 0, 108), UDim2.new(0, 85, 0, 28), THEME)
local speedReset = makeBtn(pageMain, "Speed 16", UDim2.new(0, 271, 0, 108), UDim2.new(0, 70, 0, 28))
local freezeBtn = makeBtn(pageMain, "Freeze: OFF", UDim2.new(0, 0, 0, 144))

-- TELEPORT
local refreshBtn = makeBtn(pageTeleport, "Atualizar lista", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 28), THEME)
local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, 0, 1, -36)
list.Position = UDim2.new(0, 0, 0, 34)
list.BackgroundColor3 = Color3.fromRGB(18, 12, 22)
list.BackgroundTransparency = 0.25
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.Parent = pageTeleport
Instance.new("UICorner", list).CornerRadius = UDim.new(0, 10)
Instance.new("UIListLayout", list).Padding = UDim.new(0, 5)

-- ADMIN
local invisBtn = makeBtn(pageAdmin, "Invisível: OFF", UDim2.new(0, 0, 0, 0))
local godBtn = makeBtn(pageAdmin, "GodMode: OFF", UDim2.new(0, 165, 0, 0))
local clickBtn = makeBtn(pageAdmin, "Click TP: OFF", UDim2.new(0, 0, 0, 36))
local flingBtn = makeBtn(pageAdmin, "Click Fling: OFF", UDim2.new(0, 165, 0, 36), nil, Color3.fromRGB(160, 40, 40))
local antiFlingBtn = makeBtn(pageAdmin, "Anti Fling: OFF", UDim2.new(0, 0, 0, 72))
local clickDelBtn = makeBtn(pageAdmin, "Click Delete: OFF", UDim2.new(0, 165, 0, 72))
local resetBtn = makeBtn(pageAdmin, "Reset", UDim2.new(0, 0, 0, 108), UDim2.new(0, 75, 0, 28), THEME)
local saveBtn = makeBtn(pageAdmin, "Save Pos", UDim2.new(0, 83, 0, 108), UDim2.new(0, 80, 0, 28))
local loadBtn = makeBtn(pageAdmin, "Load Pos", UDim2.new(0, 171, 0, 108), UDim2.new(0, 80, 0, 28))
local rejoinBtn = makeBtn(pageAdmin, "Rejoin", UDim2.new(0, 259, 0, 108), UDim2.new(0, 75, 0, 28), THEME)
local hopBtn = makeBtn(pageAdmin, "Server Hop", UDim2.new(0, 0, 0, 144), nil, Color3.fromRGB(95, 40, 110))
local specBtn = makeBtn(pageAdmin, "Unspectate", UDim2.new(0, 165, 0, 144))

-- VISUAL
local fbBtn = makeBtn(pageVisual, "Fullbright: OFF", UDim2.new(0, 0, 0, 0))
local fogBtn = makeBtn(pageVisual, "No Fog: OFF", UDim2.new(0, 165, 0, 0))
local espBtn = makeBtn(pageVisual, "ESP: OFF", UDim2.new(0, 0, 0, 36))
local xrayBtn = makeBtn(pageVisual, "XRay: OFF", UDim2.new(0, 165, 0, 36))
local rainbowBtn = makeBtn(pageVisual, "Rainbow: OFF", UDim2.new(0, 0, 0, 72))
local fovBox = makeBox(pageVisual, "70", UDim2.new(0, 165, 0, 74))
makeLabel(pageVisual, "FOV", UDim2.new(0, 165, 0, 60))
local fovBtn = makeBtn(pageVisual, "Set FOV", UDim2.new(0, 228, 0, 72), UDim2.new(0, 90, 0, 28), THEME)
local nightBtn = makeBtn(pageVisual, "Noite", UDim2.new(0, 0, 0, 108), UDim2.new(0, 80, 0, 28))
local dayBtn = makeBtn(pageVisual, "Dia", UDim2.new(0, 88, 0, 108), UDim2.new(0, 80, 0, 28))
local resetCam = makeBtn(pageVisual, "Reset Cam", UDim2.new(0, 176, 0, 108), UDim2.new(0, 90, 0, 28))

-- EXTRA
local spinBtn = makeBtn(pageExtra, "Spin: OFF", UDim2.new(0, 0, 0, 0))
local afkBtn = makeBtn(pageExtra, "Anti AFK: OFF", UDim2.new(0, 165, 0, 0))
local autoClickBtn = makeBtn(pageExtra, "AutoClick: OFF", UDim2.new(0, 0, 0, 36))
local fpsBtn = makeBtn(pageExtra, "FPS Boost", UDim2.new(0, 165, 0, 36), nil, Color3.fromRGB(95, 40, 110))
local copyBtn = makeBtn(pageExtra, "Copy Pos", UDim2.new(0, 0, 0, 72), UDim2.new(0, 100, 0, 28))
local hatsBtn = makeBtn(pageExtra, "Rem Hats", UDim2.new(0, 110, 0, 72), UDim2.new(0, 90, 0, 28))
local zoomBtn = makeBtn(pageExtra, "Zoom Inf", UDim2.new(0, 210, 0, 72), UDim2.new(0, 90, 0, 28))
local clothesBtn = makeBtn(pageExtra, "Rem Roupa", UDim2.new(0, 0, 0, 108))
local toolsBtn = makeBtn(pageExtra, "Rem Tools", UDim2.new(0, 165, 0, 108))
local lockBtn = makeBtn(pageExtra, "ShiftLock: OFF", UDim2.new(0, 0, 0, 144))

-- WORLD
local gravBox = makeBox(pageWorld, "196.2", UDim2.new(0, 0, 0, 16))
makeLabel(pageWorld, "Gravity", UDim2.new(0, 0, 0, 0))
local gravBtn = makeBtn(pageWorld, "Aplicar Grav", UDim2.new(0, 64, 0, 14), UDim2.new(0, 100, 0, 28), THEME)
local moonBtn = makeBtn(pageWorld, "Lua", UDim2.new(0, 174, 0, 14), UDim2.new(0, 70, 0, 28))
local earthBtn = makeBtn(pageWorld, "Terra", UDim2.new(0, 252, 0, 14), UDim2.new(0, 70, 0, 28))
local partBtn = makeBtn(pageWorld, "No Particles", UDim2.new(0, 0, 0, 52))
local soundBtn = makeBtn(pageWorld, "Mute Sounds", UDim2.new(0, 165, 0, 52))
local waterBtn = makeBtn(pageWorld, "No Water", UDim2.new(0, 0, 0, 88))

-- PLAYER
local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, 0, 0, 92)
infoLabel.BackgroundColor3 = Color3.fromRGB(18, 12, 22)
infoLabel.BackgroundTransparency = 0.2
infoLabel.Text = "..."
infoLabel.TextColor3 = Color3.fromRGB(230, 210, 220)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 12
infoLabel.TextWrapped = true
infoLabel.Parent = pagePlayer
Instance.new("UICorner", infoLabel).CornerRadius = UDim.new(0, 10)
local copyNameBtn = makeBtn(pagePlayer, "Copiar User", UDim2.new(0, 0, 0, 102), UDim2.new(0, 155, 0, 28), THEME)
local copyIdBtn = makeBtn(pagePlayer, "Copiar UserId", UDim2.new(0, 165, 0, 102), UDim2.new(0, 155, 0, 28), THEME)
local copyJob = makeBtn(pagePlayer, "Copiar JobId", UDim2.new(0, 0, 0, 138))
local respawnBtn = makeBtn(pagePlayer, "Respawn", UDim2.new(0, 165, 0, 138), nil, THEME)

-- FLOAT
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 50, 0, 50)
openBtn.Position = UDim2.new(0, 14, 0.5, -25)
openBtn.BackgroundColor3 = THEME
openBtn.Text = "🐉"
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 20
openBtn.Visible = false
openBtn.Active = true
openBtn.Draggable = true
openBtn.Parent = gui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)

local upBtn = Instance.new("TextButton")
upBtn.Size = UDim2.new(0, 48, 0, 48)
upBtn.Position = UDim2.new(1, -62, 0.5, -58)
upBtn.BackgroundColor3 = Color3.fromRGB(40, 130, 70)
upBtn.Text = "↑"
upBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
upBtn.Font = Enum.Font.GothamBold
upBtn.TextSize = 20
upBtn.Visible = false
upBtn.Parent = gui
Instance.new("UICorner", upBtn).CornerRadius = UDim.new(0, 12)

local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.new(0, 48, 0, 48)
downBtn.Position = UDim2.new(1, -62, 0.5, 12)
downBtn.BackgroundColor3 = Color3.fromRGB(150, 40, 40)
downBtn.Text = "↓"
downBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
downBtn.Font = Enum.Font.GothamBold
downBtn.TextSize = 20
downBtn.Visible = false
downBtn.Parent = gui
Instance.new("UICorner", downBtn).CornerRadius = UDim.new(0, 12)

-- FUNÇÕES
player.CharacterAdded:Connect(function()
	task.wait(0.4)
	updateChar()
	flying = false
	isFlinging = false
	if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
	if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
	setToggle(flyBtn, false, "🕊️ Fly: ON", "🕊️ Fly: OFF")
	upBtn.Visible, downBtn.Visible = false, false
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
	setToggle(flyBtn, flying, "🕊️ Fly: ON", "🕊️ Fly: OFF")
	if flying then
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		bodyVelocity.Velocity = Vector3.zero
		bodyVelocity.Parent = rootPart
		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		bodyGyro.P = 9999
		bodyGyro.Parent = rootPart
		humanoid.PlatformStand = true
		upBtn.Visible, downBtn.Visible = true, true
	else
		if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
		if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
		humanoid.PlatformStand = false
		goingUp, goingDown = false, false
		upBtn.Visible, downBtn.Visible = false, false
	end
end

RunService.RenderStepped:Connect(function()
	if flying and bodyVelocity and bodyGyro and rootPart and humanoid then
		local move = humanoid.MoveDirection
		local vel = Vector3.zero
		if move.Magnitude > 0.05 then vel = move * flySpeed end
		if goingUp then vel += Vector3.new(0, flySpeed, 0) end
		if goingDown then vel += Vector3.new(0, -flySpeed, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel += Vector3.new(0, flySpeed, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			vel += Vector3.new(0, -flySpeed, 0)
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
	local f, s, j = tonumber(flyBox.Text), tonumber(speedBox.Text), tonumber(jumpBox.Text)
	if f and f > 0 then flySpeed = f end
	if s and s > 0 then walkSpeed = s humanoid.WalkSpeed = s end
	if j and j > 0 then jumpPower = j humanoid.UseJumpPower = true humanoid.JumpPower = j end
	notify("Aplicado")
end

UserInputService.JumpRequest:Connect(function()
	if infJump and humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

local function toggleInf()
	infJump = not infJump
	setToggle(infBtn, infJump, "Inf Jump: ON", "Inf Jump: OFF")
end

local function toggleNoclip()
	noclip = not noclip
	setToggle(noclipBtn, noclip, "Noclip: ON", "Noclip: OFF")
	if noclip then
		noclipConn = RunService.Stepped:Connect(function()
			if character then
				for _, p in ipairs(character:GetDescendants()) do
					if p:IsA("BasePart") then p.CanCollide = false end
				end
			end
		end)
	elseif noclipConn then noclipConn:Disconnect() noclipConn = nil end
end

local function setSpeed(n)
	updateChar()
	if humanoid then walkSpeed = n humanoid.WalkSpeed = n speedBox.Text = tostring(n) end
end

local function toggleFreeze()
	updateChar()
	freezeSelf = not freezeSelf
	setToggle(freezeBtn, freezeSelf, "Freeze: ON", "Freeze: OFF")
	if rootPart then rootPart.Anchored = freezeSelf end
end

local function toggleInvis()
	updateChar()
	invisible = not invisible
	setToggle(invisBtn, invisible, "Invisível: ON", "Invisível: OFF")
	if character then
		for _, p in ipairs(character:GetDescendants()) do
			if p:IsA("BasePart") or p:IsA("Decal") then p.Transparency = invisible and 1 or 0 end
		end
	end
end

local function toggleGod()
	godmode = not godmode
	setToggle(godBtn, godmode, "GodMode: ON", "GodMode: OFF")
	if godmode then
		godConn = RunService.Heartbeat:Connect(function()
			if humanoid and humanoid.Health < humanoid.MaxHealth then humanoid.Health = humanoid.MaxHealth end
		end)
	elseif godConn then godConn:Disconnect() godConn = nil end
end

local function toggleClickTP()
	clickTP = not clickTP
	setToggle(clickBtn, clickTP, "Click TP: ON", "Click TP: OFF")
end

mouse.Button1Down:Connect(function()
	if clickDelete then
		local t = mouse.Target
		if t and not t:IsDescendantOf(player.Character or workspace) then
			pcall(function() t:Destroy() end)
		end
	elseif clickTP and rootPart and not clickFling then
		local hit = mouse.Hit
		if hit then rootPart.CFrame = CFrame.new(hit.Position + Vector3.new(0, 3, 0)) end
	end
end)

local SPIN_SPEED, STRIKE_DURATION = 150000, 0.3
local function getFlingTarget()
	local target = mouse.Target
	if target and target.Parent then
		local char = target.Parent:IsA("Model") and target.Parent or target.Parent.Parent
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if root and char ~= player.Character then return root end
	end
end

local function startClickFling()
	if not clickFling or isFlinging then return end
	updateChar()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local target = getFlingTarget()
	if not root or not target then return end
	isFlinging = true
	local originalLocation, originalCamCFrame = root.CFrame, camera.CFrame
	camera.CameraType = Enum.CameraType.Scriptable
	camera.CFrame = originalCamCFrame
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
			pcall(function() part.CustomPhysicalProperties = PhysicalProperties.new(100, 0, 0, 0, 0) end)
		end
	end
	root.CanCollide = true
	task.spawn(function()
		local t0 = os.clock()
		while os.clock() - t0 < STRIKE_DURATION do
			RunService.Heartbeat:Wait()
			if not target or not target.Parent then break end
			root.CFrame = target.CFrame
			root.RotVelocity = Vector3.new(0, SPIN_SPEED, 0)
			root.Velocity = Vector3.new(30, 0, 30)
		end
		root.Velocity = Vector3.zero
		root.RotVelocity = Vector3.zero
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		root.CFrame = originalLocation + Vector3.new(0, 2, 0)
		camera.CameraType = Enum.CameraType.Custom
		for _, v in ipairs(char:GetDescendants()) do
			if v:IsA("BasePart") then v.CanCollide = true end
		end
		if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
		task.wait(0.2)
		isFlinging = false
	end)
end

local function toggleClickFling()
	clickFling = not clickFling
	setToggle(flingBtn, clickFling, "Click Fling: ON", "Click Fling: OFF")
	notify(clickFling and "Clique no jogador" or "Click Fling off")
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed or not clickFling then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		startClickFling()
	end
end)

local function toggleAntiFling()
	antiFling = not antiFling
	setToggle(antiFlingBtn, antiFling, "Anti Fling: ON", "Anti Fling: OFF")
	if antiFling then
		antiFlingConn = RunService.Heartbeat:Connect(function()
			updateChar()
			if rootPart and rootPart.AssemblyLinearVelocity.Magnitude > 180 then
				rootPart.AssemblyLinearVelocity = Vector3.zero
				rootPart.AssemblyAngularVelocity = Vector3.zero
			end
		end)
	elseif antiFlingConn then antiFlingConn:Disconnect() antiFlingConn = nil end
end

local function toggleClickDelete()
	clickDelete = not clickDelete
	setToggle(clickDelBtn, clickDelete, "Click Delete: ON", "Click Delete: OFF")
end

local function unspectate()
	spectateTarget = nil
	camera.CameraSubject = humanoid or player.Character
end

local function savePos()
	updateChar()
	if rootPart then savedCFrame = rootPart.CFrame notify("Salvo") end
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
			b.Text = plr.DisplayName
			b.TextColor3 = Color3.fromRGB(255, 255, 255)
			b.Font = Enum.Font.Gotham
			b.TextSize = 12
			b.Parent = list
			Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
			b.MouseButton1Click:Connect(function()
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
					local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
					if hum then camera.CameraSubject = hum notify("Spectate: "..plr.DisplayName) end
				else
					tpTo(plr)
				end
			end)
			y += 33
		end
	end
	list.CanvasSize = UDim2.new(0, 0, 0, y)
end

local function toggleFB()
	fullbright = not fullbright
	setToggle(fbBtn, fullbright, "Fullbright: ON", "Fullbright: OFF")
	if fullbright then
		Lighting.Brightness = 4 Lighting.ClockTime = 12 Lighting.FogEnd = 9e9
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.fromRGB(210,210,210)
		Lighting.Ambient = Color3.fromRGB(170,170,170)
	else
		Lighting.Brightness = 1 Lighting.ClockTime = 14 Lighting.FogEnd = 100000
		Lighting.GlobalShadows = true
		Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
		Lighting.Ambient = Color3.fromRGB(0,0,0)
	end
end

local function toggleFog()
	local on = fogBtn.Text:find("ON")
	setToggle(fogBtn, not on, "No Fog: ON", "No Fog: OFF")
	Lighting.FogEnd = on and 100000 or 9e9
end

local espFolder = Instance.new("Folder", gui)
espFolder.Name = "ESP"
local function clearESP()
	for _, v in ipairs(espFolder:GetChildren()) do v:Destroy() end
end
local function toggleESP()
	espEnabled = not espEnabled
	setToggle(espBtn, espEnabled, "ESP: ON", "ESP: OFF")
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
			txt.Size = UDim2.new(1,0,1,0)
			txt.BackgroundTransparency = 1
			txt.Text = plr.DisplayName
			txt.TextColor3 = Color3.fromRGB(255,80,90)
			txt.TextStrokeTransparency = 0.2
			txt.Font = Enum.Font.GothamBold
			txt.TextSize = 13
			txt.Parent = bill
		end
	end
end)

local function toggleXRay()
	xray = not xray
	setToggle(xrayBtn, xray, "XRay: ON", "XRay: OFF")
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and not v:IsDescendantOf(player.Character or workspace) then
			if xray then
				if not v:GetAttribute("OldTrans") then v:SetAttribute("OldTrans", v.Transparency) end
				v.Transparency = math.max(v.Transparency, 0.65)
			elseif v:GetAttribute("OldTrans") then
				v.Transparency = v:GetAttribute("OldTrans")
			end
		end
	end
end

local function toggleRainbow()
	rainbow = not rainbow
	setToggle(rainbowBtn, rainbow, "Rainbow: ON", "Rainbow: OFF")
	if rainbow then
		rainbowConn = RunService.RenderStepped:Connect(function()
			updateChar()
			if character then
				local h = (tick() * 0.3) % 1
				for _, p in ipairs(character:GetDescendants()) do
					if p:IsA("BasePart") then p.Color = Color3.fromHSV(h, 0.8, 1) end
				end
			end
		end)
	elseif rainbowConn then rainbowConn:Disconnect() rainbowConn = nil end
end

local function applyFOV()
	local v = tonumber(fovBox.Text)
	if v and v >= 1 and v <= 120 then
		for i = 1, 6 do camera.FieldOfView = v task.wait(0.03) end
	end
end

local function toggleSpin()
	spinEnabled = not spinEnabled
	setToggle(spinBtn, spinEnabled, "Spin: ON", "Spin: OFF")
	if spinEnabled then
		spinConn = RunService.RenderStepped:Connect(function()
			if rootPart then rootPart.CFrame *= CFrame.Angles(0, math.rad(14), 0) end
		end)
	elseif spinConn then spinConn:Disconnect() spinConn = nil end
end

local function toggleAFK()
	antiAFK = not antiAFK
	setToggle(afkBtn, antiAFK, "Anti AFK: ON", "Anti AFK: OFF")
	if antiAFK then
		afkConn = RunService.Heartbeat:Connect(function()
			pcall(function()
				local vu = game:GetService("VirtualUser")
				vu:CaptureController()
				vu:ClickButton2(Vector2.new())
			end)
		end)
	elseif afkConn then afkConn:Disconnect() afkConn = nil end
end

local function toggleAutoClick()
	autoClick = not autoClick
	setToggle(autoClickBtn, autoClick, "AutoClick: ON", "AutoClick: OFF")
	if autoClick then
		clickConn = RunService.Heartbeat:Connect(function()
			pcall(function()
				VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
				VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
			end)
			task.wait(clickDelay)
		end)
	elseif clickConn then clickConn:Disconnect() clickConn = nil end
end

local function fpsBoost()
	pcall(function() settings().Rendering.QualityLevel = 1 end)
	notify("FPS Boost")
end

local function copyPos()
	updateChar()
	if rootPart then
		local p = rootPart.Position
		pcall(function() setclipboard(string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z)) end)
		notify("Pos copiada")
	end
end

local function removeHats()
	updateChar()
	if character then
		for _, v in ipairs(character:GetChildren()) do
			if v:IsA("Accessory") then v:Destroy() end
		end
	end
end

local function removeClothes()
	updateChar()
	if character then
		for _, v in ipairs(character:GetChildren()) do
			if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then v:Destroy() end
		end
	end
end

local function removeTools()
	updateChar()
	if character then
		for _, v in ipairs(character:GetChildren()) do
			if v:IsA("Tool") then v:Destroy() end
		end
	end
	if player:FindFirstChild("Backpack") then
		for _, v in ipairs(player.Backpack:GetChildren()) do
			if v:IsA("Tool") then v:Destroy() end
		end
	end
end

local function toggleShiftLock()
	shiftLock = not shiftLock
	setToggle(lockBtn, shiftLock, "ShiftLock: ON", "ShiftLock: OFF")
	pcall(function()
		UserInputService.MouseBehavior = shiftLock and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
	end)
end

local function updateInfo()
	infoLabel.Text = string.format("User: %s\nDisplay: %s\nUserId: %s\nPlayers: %d\nPlaceId: %s",
		player.Name, player.DisplayName, player.UserId, #Players:GetPlayers(), game.PlaceId)
end
updateInfo()

-- Conexões
flyBtn.MouseButton1Click:Connect(toggleFly)
applyBtn.MouseButton1Click:Connect(apply)
infBtn.MouseButton1Click:Connect(toggleInf)
noclipBtn.MouseButton1Click:Connect(toggleNoclip)
hipBtn.MouseButton1Click:Connect(function() updateChar() if humanoid then humanoid.HipHeight += 1.5 end end)
hipMinus.MouseButton1Click:Connect(function() updateChar() if humanoid then humanoid.HipHeight = math.max(0, humanoid.HipHeight - 1.5) end end)
sitBtn.MouseButton1Click:Connect(function() updateChar() if humanoid then humanoid.Sit = not humanoid.Sit end end)
speed50.MouseButton1Click:Connect(function() setSpeed(50) end)
speed100.MouseButton1Click:Connect(function() setSpeed(100) end)
speedReset.MouseButton1Click:Connect(function() setSpeed(16) end)
freezeBtn.MouseButton1Click:Connect(toggleFreeze)
refreshBtn.MouseButton1Click:Connect(refresh)
invisBtn.MouseButton1Click:Connect(toggleInvis)
godBtn.MouseButton1Click:Connect(toggleGod)
clickBtn.MouseButton1Click:Connect(toggleClickTP)
flingBtn.MouseButton1Click:Connect(toggleClickFling)
antiFlingBtn.MouseButton1Click:Connect(toggleAntiFling)
clickDelBtn.MouseButton1Click:Connect(toggleClickDelete)
resetBtn.MouseButton1Click:Connect(function() if humanoid then humanoid.Health = 0 end end)
saveBtn.MouseButton1Click:Connect(savePos)
loadBtn.MouseButton1Click:Connect(loadPos)
rejoinBtn.MouseButton1Click:Connect(function() TeleportService:Teleport(game.PlaceId, player) end)
hopBtn.MouseButton1Click:Connect(function()
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
end)
specBtn.MouseButton1Click:Connect(unspectate)
fbBtn.MouseButton1Click:Connect(toggleFB)
fogBtn.MouseButton1Click:Connect(toggleFog)
espBtn.MouseButton1Click:Connect(toggleESP)
xrayBtn.MouseButton1Click:Connect(toggleXRay)
rainbowBtn.MouseButton1Click:Connect(toggleRainbow)
fovBtn.MouseButton1Click:Connect(applyFOV)
nightBtn.MouseButton1Click:Connect(function() Lighting.ClockTime = 0 end)
dayBtn.MouseButton1Click:Connect(function() Lighting.ClockTime = 14 end)
resetCam.MouseButton1Click:Connect(function()
	camera.CameraType = Enum.CameraType.Custom
	camera.FieldOfView = 70
	if humanoid then camera.CameraSubject = humanoid end
end)
spinBtn.MouseButton1Click:Connect(toggleSpin)
afkBtn.MouseButton1Click:Connect(toggleAFK)
autoClickBtn.MouseButton1Click:Connect(toggleAutoClick)
fpsBtn.MouseButton1Click:Connect(fpsBoost)
copyBtn.MouseButton1Click:Connect(copyPos)
hatsBtn.MouseButton1Click:Connect(removeHats)
zoomBtn.MouseButton1Click:Connect(function()
	player.CameraMaxZoomDistance = 9999
	player.CameraMinZoomDistance = 0.5
	notify("Zoom infinito")
end)
clothesBtn.MouseButton1Click:Connect(removeClothes)
toolsBtn.MouseButton1Click:Connect(removeTools)
lockBtn.MouseButton1Click:Connect(toggleShiftLock)
gravBtn.MouseButton1Click:Connect(function()
	local g = tonumber(gravBox.Text)
	if g then workspace.Gravity = g end
end)
moonBtn.MouseButton1Click:Connect(function() workspace.Gravity = 30 gravBox.Text = "30" end)
earthBtn.MouseButton1Click:Connect(function() workspace.Gravity = 196.2 gravBox.Text = "196.2" end)
partBtn.MouseButton1Click:Connect(function()
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
			v.Enabled = false
		end
	end
	notify("Particles off")
end)
soundBtn.MouseButton1Click:Connect(function()
	for _, v in ipairs(workspace:GetDescendants()) do
		if v:IsA("Sound") then v.Volume = 0 end
	end
	notify("Sons mutados")
end)
waterBtn.MouseButton1Click:Connect(function()
	pcall(function()
		workspace.Terrain.WaterWaveSize = 0
		workspace.Terrain.WaterWaveSpeed = 0
		workspace.Terrain.WaterTransparency = 1
	end)
end)
copyNameBtn.MouseButton1Click:Connect(function() pcall(function() setclipboard(player.Name) end) notify("User copiado") end)
copyIdBtn.MouseButton1Click:Connect(function() pcall(function() setclipboard(tostring(player.UserId)) end) notify("UserId copiado") end)
copyJob.MouseButton1Click:Connect(function() pcall(function() setclipboard(game.JobId) end) notify("JobId copiado") end)
respawnBtn.MouseButton1Click:Connect(function() if humanoid then humanoid.Health = 0 end end)

closeBtn.MouseButton1Click:Connect(function() main.Visible = false openBtn.Visible = true end)
openBtn.MouseButton1Click:Connect(function() main.Visible = true openBtn.Visible = false end)

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.P then
		main.Visible = not main.Visible
		openBtn.Visible = not main.Visible
	end
end)

Players.PlayerAdded:Connect(function() refresh() updateInfo() end)
Players.PlayerRemoving:Connect(function() refresh() updateInfo() end)
task.spawn(function()
	while true do refresh() updateInfo() task.wait(4) end
end)

print("✅ Dragon Admin v4 carregado!")