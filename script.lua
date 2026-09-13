--[[
	DRAGON ADMIN v5 - Compacto + Comandos
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
local antiFling, rainbow, xray, clickDel = false, false, false, false
local bv, bg, up, down = nil, nil, false, false
local nC, gC, sC, aC, cC, afC, rC = nil, nil, nil, nil, nil, nil, nil
local flinging = false

local THEME = Color3.fromRGB(170, 45, 70)
local ON, OFF = Color3.fromRGB(40, 145, 80), Color3.fromRGB(38, 24, 34)

local function note(t)
	pcall(function()
		StarterGui:SetCore("SendNotification", {Title="🐉", Text=t, Duration=2})
	end)
end

local gui = Instance.new("ScreenGui")
gui.Name = "DragonAdmin"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = lp:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 400, 0, 300)
main.Position = UDim2.new(0.5, -200, 0.5, -150)
main.BackgroundColor3 = Color3.fromRGB(10, 8, 16)
main.BackgroundTransparency = 0.1
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local st = Instance.new("UIStroke")
st.Color = THEME
st.Thickness = 1.3
st.Transparency = 0.3
st.Parent = main

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 26)
header.BackgroundColor3 = Color3.fromRGB(22, 12, 20)
header.BackgroundTransparency = 0.2
header.BorderSizePixel = 0
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 8, 0, 0)
title.BackgroundTransparency = 1
title.Text = "🐉 DRAGON v5"
title.TextColor3 = Color3.fromRGB(255, 205, 190)
title.Font = Enum.Font.GothamBold
title.TextSize = 12
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 20, 0, 20)
closeBtn.Position = UDim2.new(1, -24, 0, 3)
closeBtn.BackgroundColor3 = Color3.fromRGB(170, 40, 45)
closeBtn.Text = "x"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 11
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 5)

local side = Instance.new("Frame")
side.Size = UDim2.new(0, 78, 1, -62)
side.Position = UDim2.new(0, 6, 0, 30)
side.BackgroundColor3 = Color3.fromRGB(16, 12, 22)
side.BackgroundTransparency = 0.2
side.BorderSizePixel = 0
side.Parent = main
Instance.new("UICorner", side).CornerRadius = UDim.new(0, 8)
Instance.new("UIListLayout", side).Padding = UDim.new(0, 4)
local pad = Instance.new("UIPadding")
pad.PaddingTop = UDim.new(0, 5)
pad.PaddingLeft = UDim.new(0, 5)
pad.PaddingRight = UDim.new(0, 5)
pad.Parent = side

local function sbtn(t)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 22)
	b.BackgroundColor3 = Color3.fromRGB(32, 20, 30)
	b.Text = t
	b.TextColor3 = Color3.fromRGB(190, 170, 180)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 9
	b.Parent = side
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	return b
end

local tMain, tTP, tAdm, tVis, tExt, tWld, tPlr =
	sbtn("Main"), sbtn("Teleport"), sbtn("Admin"), sbtn("Visual"), sbtn("Extra"), sbtn("World"), sbtn("Player")
tMain.BackgroundColor3 = THEME
tMain.TextColor3 = Color3.fromRGB(255,255,255)

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -92, 1, -66)
content.Position = UDim2.new(0, 88, 0, 30)
content.BackgroundTransparency = 1
content.Parent = main

local function page()
	local p = Instance.new("Frame")
	p.Size = UDim2.new(1,0,1,0)
	p.BackgroundTransparency = 1
	p.Visible = false
	p.Parent = content
	return p
end
local pMain, pTP, pAdm, pVis, pExt, pWld, pPlr = page(), page(), page(), page(), page(), page(), page()
pMain.Visible = true

local tabs = {{pMain,tMain},{pTP,tTP},{pAdm,tAdm},{pVis,tVis},{pExt,tExt},{pWld,tWld},{pPlr,tPlr}}
local function sw(pg, act)
	for _, t in ipairs(tabs) do
		t[1].Visible = t[1]==pg
		t[2].BackgroundColor3 = Color3.fromRGB(32,20,30)
		t[2].TextColor3 = Color3.fromRGB(190,170,180)
	end
	act.BackgroundColor3 = THEME
	act.TextColor3 = Color3.fromRGB(255,255,255)
end
tMain.MouseButton1Click:Connect(function() sw(pMain,tMain) end)
tTP.MouseButton1Click:Connect(function() sw(pTP,tTP) end)
tAdm.MouseButton1Click:Connect(function() sw(pAdm,tAdm) end)
tVis.MouseButton1Click:Connect(function() sw(pVis,tVis) end)
tExt.MouseButton1Click:Connect(function() sw(pExt,tExt) end)
tWld.MouseButton1Click:Connect(function() sw(pWld,tWld) end)
tPlr.MouseButton1Click:Connect(function() sw(pPlr,tPlr) end)

local function btn(par, txt, pos, sz, col)
	local b = Instance.new("TextButton")
	b.Size = sz or UDim2.new(0, 92, 0, 22)
	b.Position = pos
	b.BackgroundColor3 = col or OFF
	b.Text = txt
	b.TextColor3 = Color3.fromRGB(255,255,255)
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 9
	b.Parent = par
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
	return b
end
local function box(par, txt, pos)
	local t = Instance.new("TextBox")
	t.Size = UDim2.new(0, 42, 0, 20)
	t.Position = pos
	t.BackgroundColor3 = Color3.fromRGB(24,16,26)
	t.Text = txt
	t.TextColor3 = Color3.fromRGB(255,255,255)
	t.Font = Enum.Font.Gotham
	t.TextSize = 9
	t.Parent = par
	Instance.new("UICorner", t).CornerRadius = UDim.new(0, 5)
	return t
end
local function tog(b, on, a, o)
	b.Text = on and a or o
	b.BackgroundColor3 = on and ON or OFF
end

-- MAIN
local flyBtn = btn(pMain, "Fly OFF", UDim2.new(0,0,0,0))
local flyBox = box(pMain, "60", UDim2.new(0,100,0,1))
local spdBox = box(pMain, "16", UDim2.new(0,148,0,1))
local jmpBox = box(pMain, "50", UDim2.new(0,196,0,1))
local applyBtn = btn(pMain, "Aplicar", UDim2.new(0,244,0,0), UDim2.new(0,56,0,22), THEME)
local infBtn = btn(pMain, "InfJump OFF", UDim2.new(0,0,0,28))
local ncBtn = btn(pMain, "Noclip OFF", UDim2.new(0,100,0,28))
local hipP = btn(pMain, "Hip+", UDim2.new(0,200,0,28), UDim2.new(0,48,0,22))
local hipM = btn(pMain, "Hip-", UDim2.new(0,252,0,28), UDim2.new(0,48,0,22))
local sitBtn = btn(pMain, "Sit", UDim2.new(0,0,0,56), UDim2.new(0,56,0,22))
local s16 = btn(pMain, "Spd16", UDim2.new(0,62,0,56), UDim2.new(0,52,0,22), THEME)
local s50 = btn(pMain, "Spd50", UDim2.new(0,120,0,56), UDim2.new(0,52,0,22), THEME)
local s100 = btn(pMain, "Spd100", UDim2.new(0,178,0,56), UDim2.new(0,56,0,22), THEME)
local frzBtn = btn(pMain, "Freeze OFF", UDim2.new(0,0,0,84))
local platBtn = btn(pMain, "Plataforma", UDim2.new(0,100,0,84))

-- TP
local refBtn = btn(pTP, "Atualizar", UDim2.new(0,0,0,0), UDim2.new(1,0,0,20), THEME)
local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1,0,1,-24)
list.Position = UDim2.new(0,0,0,24)
list.BackgroundColor3 = Color3.fromRGB(18,12,22)
list.BackgroundTransparency = 0.25
list.BorderSizePixel = 0
list.ScrollBarThickness = 3
list.Parent = pTP
Instance.new("UICorner", list).CornerRadius = UDim.new(0, 7)
Instance.new("UIListLayout", list).Padding = UDim.new(0, 3)

-- ADMIN
local invBtn = btn(pAdm, "Invis OFF", UDim2.new(0,0,0,0))
local godBtn = btn(pAdm, "God OFF", UDim2.new(0,100,0,0))
local ctpBtn = btn(pAdm, "ClickTP OFF", UDim2.new(0,200,0,0))
local flBtn = btn(pAdm, "CFling OFF", UDim2.new(0,0,0,28), nil, Color3.fromRGB(150,40,40))
local afBtn = btn(pAdm, "AntiFling OFF", UDim2.new(0,100,0,28))
local cdBtn = btn(pAdm, "CDelete OFF", UDim2.new(0,200,0,28))
local rstBtn = btn(pAdm, "Reset", UDim2.new(0,0,0,56), UDim2.new(0,56,0,22), THEME)
local svBtn = btn(pAdm, "Save", UDim2.new(0,62,0,56), UDim2.new(0,52,0,22))
local ldBtn = btn(pAdm, "Load", UDim2.new(0,120,0,56), UDim2.new(0,52,0,22))
local rjBtn = btn(pAdm, "Rejoin", UDim2.new(0,178,0,56), UDim2.new(0,56,0,22), THEME)
local hpBtn = btn(pAdm, "Hop", UDim2.new(0,240,0,56), UDim2.new(0,52,0,22), Color3.fromRGB(90,40,110))
local specBtn = btn(pAdm, "Unspectate", UDim2.new(0,0,0,84))
local killSelf = btn(pAdm, "Die", UDim2.new(0,100,0,84), UDim2.new(0,56,0,22), THEME)

-- VISUAL
local fbBtn = btn(pVis, "FB OFF", UDim2.new(0,0,0,0))
local fogBtn = btn(pVis, "Fog OFF", UDim2.new(0,100,0,0))
local espBtn = btn(pVis, "ESP OFF", UDim2.new(0,200,0,0))
local xrBtn = btn(pVis, "XRay OFF", UDim2.new(0,0,0,28))
local rbBtn = btn(pVis, "RGB OFF", UDim2.new(0,100,0,28))
local fovBox = box(pVis, "70", UDim2.new(0,200,0,29))
local fovBtn = btn(pVis, "FOV", UDim2.new(0,248,0,28), UDim2.new(0,44,0,22), THEME)
local nite = btn(pVis, "Noite", UDim2.new(0,0,0,56), UDim2.new(0,56,0,22))
local day = btn(pVis, "Dia", UDim2.new(0,62,0,56), UDim2.new(0,52,0,22))
local rcam = btn(pVis, "Cam", UDim2.new(0,120,0,56), UDim2.new(0,52,0,22))

-- EXTRA
local spBtn = btn(pExt, "Spin OFF", UDim2.new(0,0,0,0))
local akBtn = btn(pExt, "AFK OFF", UDim2.new(0,100,0,0))
local acBtn = btn(pExt, "AClick OFF", UDim2.new(0,200,0,0))
local fpsBtn = btn(pExt, "FPS+", UDim2.new(0,0,0,28), nil, Color3.fromRGB(90,40,110))
local cpBtn = btn(pExt, "CopyPos", UDim2.new(0,100,0,28))
local hatBtn = btn(pExt, "Hats", UDim2.new(0,200,0,28))
local zmBtn = btn(pExt, "Zoom+", UDim2.new(0,0,0,56))
local clBtn = btn(pExt, "Roupa", UDim2.new(0,100,0,56))
local tlBtn = btn(pExt, "Tools", UDim2.new(0,200,0,56))
local waveBtn = btn(pExt, "Wave", UDim2.new(0,0,0,84), UDim2.new(0,56,0,22))
local danceBtn = btn(pExt, "Dance", UDim2.new(0,62,0,84), UDim2.new(0,56,0,22))
local cheerBtn = btn(pExt, "Cheer", UDim2.new(0,124,0,84), UDim2.new(0,56,0,22))
local laughBtn = btn(pExt, "Laugh", UDim2.new(0,186,0,84), UDim2.new(0,56,0,22))

-- WORLD
local gBox = box(pWld, "196", UDim2.new(0,0,0,4))
local gBtn = btn(pWld, "Grav", UDim2.new(0,50,0,2), UDim2.new(0,48,0,22), THEME)
local moon = btn(pWld, "Lua", UDim2.new(0,104,0,2), UDim2.new(0,48,0,22))
local earth = btn(pWld, "Terra", UDim2.new(0,158,0,2), UDim2.new(0,52,0,22))
local noP = btn(pWld, "NoPart", UDim2.new(0,0,0,30))
local mute = btn(pWld, "Mute", UDim2.new(0,100,0,30))
local now = btn(pWld, "NoWater", UDim2.new(0,200,0,30))
local bright = btn(pWld, "Bright+", UDim2.new(0,0,0,58))
local dark = btn(pWld, "Dark", UDim2.new(0,100,0,58))

-- PLAYER
local info = Instance.new("TextLabel")
info.Size = UDim2.new(1,0,0,70)
info.BackgroundColor3 = Color3.fromRGB(18,12,22)
info.BackgroundTransparency = 0.2
info.Text = "..."
info.TextColor3 = Color3.fromRGB(225,205,215)
info.Font = Enum.Font.Gotham
info.TextSize = 10
info.TextWrapped = true
info.Parent = pPlr
Instance.new("UICorner", info).CornerRadius = UDim.new(0, 7)
local cn = btn(pPlr, "User", UDim2.new(0,0,0,78), UDim2.new(0,70,0,22), THEME)
local ci = btn(pPlr, "Id", UDim2.new(0,76,0,78), UDim2.new(0,60,0,22), THEME)
local cj = btn(pPlr, "JobId", UDim2.new(0,142,0,78), UDim2.new(0,60,0,22))
local rs = btn(pPlr, "Respawn", UDim2.new(0,208,0,78), UDim2.new(0,70,0,22), THEME)

-- CMD BAR
local cmd = Instance.new("TextBox")
cmd.Size = UDim2.new(1, -12, 0, 22)
cmd.Position = UDim2.new(0, 6, 1, -28)
cmd.BackgroundColor3 = Color3.fromRGB(20, 14, 24)
cmd.PlaceholderText = ";fly  ;speed 50  ;tp nome  ;help"
cmd.Text = ""
cmd.TextColor3 = Color3.fromRGB(255,255,255)
cmd.PlaceholderColor3 = Color3.fromRGB(140,120,130)
cmd.Font = Enum.Font.Gotham
cmd.TextSize = 10
cmd.ClearTextOnFocus = false
cmd.Parent = main
Instance.new("UICorner", cmd).CornerRadius = UDim.new(0, 7)

local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 42, 0, 42)
openBtn.Position = UDim2.new(0, 12, 0.5, -21)
openBtn.BackgroundColor3 = THEME
openBtn.Text = "🐉"
openBtn.TextColor3 = Color3.fromRGB(255,255,255)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 16
openBtn.Visible = false
openBtn.Active = true
openBtn.Draggable = true
openBtn.Parent = gui
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1,0)

local upB = Instance.new("TextButton")
upB.Size = UDim2.new(0, 40, 0, 40)
upB.Position = UDim2.new(1, -52, 0.5, -48)
upB.BackgroundColor3 = Color3.fromRGB(40,130,70)
upB.Text = "↑"
upB.TextColor3 = Color3.fromRGB(255,255,255)
upB.Font = Enum.Font.GothamBold
upB.TextSize = 16
upB.Visible = false
upB.Parent = gui
Instance.new("UICorner", upB).CornerRadius = UDim.new(0, 10)

local dnB = Instance.new("TextButton")
dnB.Size = UDim2.new(0, 40, 0, 40)
dnB.Position = UDim2.new(1, -52, 0.5, 10)
dnB.BackgroundColor3 = Color3.fromRGB(150,40,40)
dnB.Text = "↓"
dnB.TextColor3 = Color3.fromRGB(255,255,255)
dnB.Font = Enum.Font.GothamBold
dnB.TextSize = 16
dnB.Visible = false
dnB.Parent = gui
Instance.new("UICorner", dnB).CornerRadius = UDim.new(0, 10)

-- FUNCS
lp.CharacterAdded:Connect(function()
	task.wait(0.35)
	upd()
	flying, flinging = false, false
	if bv then bv:Destroy() bv=nil end
	if bg then bg:Destroy() bg=nil end
	tog(flyBtn, false, "Fly ON", "Fly OFF")
	upB.Visible, dnB.Visible = false, false
	if hum then hum.WalkSpeed=walkSpeed hum.UseJumpPower=true hum.JumpPower=jumpPower end
end)

local function setFly(state)
	upd()
	if not root or not hum then return end
	flying = state
	tog(flyBtn, flying, "Fly ON", "Fly OFF")
	if flying then
		bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(9e9,9e9,9e9)
		bv.Velocity = Vector3.zero
		bv.Parent = root
		bg = Instance.new("BodyGyro")
		bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
		bg.P = 9999
		bg.Parent = root
		hum.PlatformStand = true
		upB.Visible, dnB.Visible = true, true
	else
		if bv then bv:Destroy() bv=nil end
		if bg then bg:Destroy() bg=nil end
		hum.PlatformStand = false
		up, down = false, false
		upB.Visible, dnB.Visible = false, false
	end
end

RS.RenderStepped:Connect(function()
	if flying and bv and bg and root and hum then
		local m = hum.MoveDirection
		local v = Vector3.zero
		if m.Magnitude > 0.05 then v = m * flySpeed end
		if up then v += Vector3.new(0, flySpeed, 0) end
		if down then v += Vector3.new(0, -flySpeed, 0) end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then v += Vector3.new(0, flySpeed, 0) end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
			v += Vector3.new(0, -flySpeed, 0)
		end
		bv.Velocity = v
		bg.CFrame = CFrame.new(root.Position, root.Position + cam.CFrame.LookVector)
	end
end)
upB.MouseButton1Down:Connect(function() up=true end)
upB.MouseButton1Up:Connect(function() up=false end)
upB.MouseLeave:Connect(function() up=false end)
dnB.MouseButton1Down:Connect(function() down=true end)
dnB.MouseButton1Up:Connect(function() down=false end)
dnB.MouseLeave:Connect(function() down=false end)

local function applyVals()
	upd()
	if not hum then return end
	local f,s,j = tonumber(flyBox.Text), tonumber(spdBox.Text), tonumber(jmpBox.Text)
	if f and f>0 then flySpeed=f end
	if s and s>0 then walkSpeed=s hum.WalkSpeed=s end
	if j and j>0 then jumpPower=j hum.UseJumpPower=true hum.JumpPower=j end
end

UIS.JumpRequest:Connect(function()
	if infJump and hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

local function setSpeed(n)
	upd()
	if hum then walkSpeed=n hum.WalkSpeed=n spdBox.Text=tostring(n) end
end

local function setNoclip(state)
	noclip = state
	tog(ncBtn, noclip, "Noclip ON", "Noclip OFF")
	if noclip then
		nC = RS.Stepped:Connect(function()
			if char then
				for _,p in ipairs(char:GetDescendants()) do
					if p:IsA("BasePart") then p.CanCollide=false end
				end
			end
		end)
	elseif nC then nC:Disconnect() nC=nil end
end

local function setGod(state)
	god = state
	tog(godBtn, god, "God ON", "God OFF")
	if god then
		gC = RS.Heartbeat:Connect(function()
			if hum and hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
		end)
	elseif gC then gC:Disconnect() gC=nil end
end

local function tpTo(plr)
	upd()
	if not root or not plr.Character then return end
	local t = plr.Character:FindFirstChild("HumanoidRootPart")
	if not t then return end
	local cf = t.CFrame * CFrame.new(0,0,3.5)
	for i=1,10 do
		root.CFrame = cf
		root.AssemblyLinearVelocity = Vector3.zero
		task.wait()
	end
end

local function findPlr(name)
	name = string.lower(name or "")
	for _,p in ipairs(Players:GetPlayers()) do
		if string.find(string.lower(p.Name), name, 1, true) or string.find(string.lower(p.DisplayName), name, 1, true) then
			return p
		end
	end
end

local function playEmote(id)
	upd()
	pcall(function()
		hum:PlayEmote(id)
	end)
	-- fallback animation ids
	pcall(function()
		local a = Instance.new("Animation")
		a.AnimationId = "rbxassetid://"..id
		hum:LoadAnimation(a):Play()
	end)
end

-- Click fling
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
	for _,p in ipairs(c:GetDescendants()) do
		if p:IsA("BasePart") then
			p.CanCollide = false
			pcall(function() p.CustomPhysicalProperties = PhysicalProperties.new(100,0,0,0,0) end)
		end
	end
	r.CanCollide = true
	task.spawn(function()
		local t0 = os.clock()
		while os.clock()-t0 < 0.3 do
			RS.Heartbeat:Wait()
			if not target or not target.Parent then break end
			r.CFrame = target.CFrame
			r.RotVelocity = Vector3.new(0,150000,0)
			r.Velocity = Vector3.new(30,0,30)
		end
		r.Velocity = Vector3.zero
		r.RotVelocity = Vector3.zero
		r.AssemblyLinearVelocity = Vector3.zero
		r.CFrame = old + Vector3.new(0,2,0)
		cam.CameraType = Enum.CameraType.Custom
		for _,p in ipairs(c:GetDescendants()) do
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
		if hit then root.CFrame = CFrame.new(hit.Position + Vector3.new(0,3,0)) end
	end
end)
UIS.InputBegan:Connect(function(i, p)
	if p or not clickFling then return end
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		startFling()
	end
end)

local function refresh()
	for _,c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
	local y=0
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr ~= lp then
			local b = Instance.new("TextButton")
			b.Size = UDim2.new(1,-6,0,20)
			b.BackgroundColor3 = Color3.fromRGB(42,26,38)
			b.Text = plr.DisplayName
			b.TextColor3 = Color3.fromRGB(255,255,255)
			b.Font = Enum.Font.Gotham
			b.TextSize = 9
			b.Parent = list
			Instance.new("UICorner", b).CornerRadius = UDim.new(0,5)
			b.MouseButton1Click:Connect(function() tpTo(plr) end)
			y += 23
		end
	end
	list.CanvasSize = UDim2.new(0,0,0,y)
end

local espF = Instance.new("Folder", gui)
espF.Name="ESP"
RS.RenderStepped:Connect(function()
	for _,v in ipairs(espF:GetChildren()) do v:Destroy() end
	if not espOn then return end
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr~=lp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local bill=Instance.new("BillboardGui")
			bill.Size=UDim2.new(0,90,0,18)
			bill.AlwaysOnTop=true
			bill.StudsOffset=Vector3.new(0,3,0)
			bill.Adornee=plr.Character.HumanoidRootPart
			bill.Parent=espF
			local tx=Instance.new("TextLabel")
			tx.Size=UDim2.new(1,0,1,0)
			tx.BackgroundTransparency=1
			tx.Text=plr.DisplayName
			tx.TextColor3=Color3.fromRGB(255,80,90)
			tx.Font=Enum.Font.GothamBold
			tx.TextSize=10
			tx.Parent=bill
		end
	end
end)

local function runCmd(raw)
	local args = {}
	for w in string.gmatch(string.lower(raw or ""), "%S+") do table.insert(args, w) end
	local c = args[1]
	if not c then return end
	c = c:gsub("^;", "")
	if c=="help" then
		note("fly speed jump tp noclip god rejoin fov grav reset")
	elseif c=="fly" then setFly(not flying)
	elseif c=="speed" then setSpeed(tonumber(args[2]) or 50)
	elseif c=="jump" then
		upd()
		if hum then jumpPower=tonumber(args[2]) or 100 hum.UseJumpPower=true hum.JumpPower=jumpPower end
	elseif c=="tp" and args[2] then
		local p = findPlr(args[2])
		if p then tpTo(p) else note("Player nao achado") end
	elseif c=="noclip" then setNoclip(not noclip)
	elseif c=="god" then setGod(not god)
	elseif c=="rejoin" then TS:Teleport(game.PlaceId, lp)
	elseif c=="fov" then cam.FieldOfView = tonumber(args[2]) or 70
	elseif c=="grav" then workspace.Gravity = tonumber(args[2]) or 196.2
	elseif c=="reset" or c=="die" then if hum then hum.Health=0 end
	elseif c=="invis" then
		invis = not invis
		tog(invBtn, invis, "Invis ON", "Invis OFF")
		upd()
		if char then
			for _,p in ipairs(char:GetDescendants()) do
				if p:IsA("BasePart") or p:IsA("Decal") then p.Transparency = invis and 1 or 0 end
			end
		end
	elseif c=="esp" then
		espOn = not espOn
		tog(espBtn, espOn, "ESP ON", "ESP OFF")
	elseif c=="fb" then
		fbBtn.MouseButton1Click:Fire()
	else
		note("Comando invalido. ;help")
	end
end

cmd.FocusLost:Connect(function(enter)
	if enter then runCmd(cmd.Text) cmd.Text="" end
end)

-- binds
flyBtn.MouseButton1Click:Connect(function() setFly(not flying) end)
applyBtn.MouseButton1Click:Connect(applyVals)
infBtn.MouseButton1Click:Connect(function() infJump=not infJump tog(infBtn,infJump,"InfJump ON","InfJump OFF") end)
ncBtn.MouseButton1Click:Connect(function() setNoclip(not noclip) end)
hipP.MouseButton1Click:Connect(function() upd() if hum then hum.HipHeight+=1.2 end end)
hipM.MouseButton1Click:Connect(function() upd() if hum then hum.HipHeight=math.max(0,hum.HipHeight-1.2) end end)
sitBtn.MouseButton1Click:Connect(function() upd() if hum then hum.Sit=not hum.Sit end end)
s16.MouseButton1Click:Connect(function() setSpeed(16) end)
s50.MouseButton1Click:Connect(function() setSpeed(50) end)
s100.MouseButton1Click:Connect(function() setSpeed(100) end)
frzBtn.MouseButton1Click:Connect(function()
	upd()
	if root then root.Anchored = not root.Anchored tog(frzBtn, root.Anchored, "Freeze ON", "Freeze OFF") end
end)
platBtn.MouseButton1Click:Connect(function()
	upd()
	if root then
		local p = Instance.new("Part")
		p.Size = Vector3.new(8,1,8)
		p.Anchored = true
		p.Position = root.Position - Vector3.new(0,3.2,0)
		p.Color = Color3.fromRGB(40,20,30)
		p.Parent = workspace
		game:GetService("Debris"):AddItem(p, 20)
	end
end)
refBtn.MouseButton1Click:Connect(refresh)
invBtn.MouseButton1Click:Connect(function() runCmd("invis") end)
godBtn.MouseButton1Click:Connect(function() setGod(not god) end)
ctpBtn.MouseButton1Click:Connect(function() clickTP=not clickTP tog(ctpBtn,clickTP,"ClickTP ON","ClickTP OFF") end)
flBtn.MouseButton1Click:Connect(function() clickFling=not clickFling tog(flBtn,clickFling,"CFling ON","CFling OFF") note(clickFling and "Clique no player" or "off") end)
afBtn.MouseButton1Click:Connect(function()
	antiFling=not antiFling
	tog(afBtn,antiFling,"AntiFling ON","AntiFling OFF")
	if antiFling then
		afC=RS.Heartbeat:Connect(function()
			upd()
			if root and root.AssemblyLinearVelocity.Magnitude>180 then
				root.AssemblyLinearVelocity=Vector3.zero
				root.AssemblyAngularVelocity=Vector3.zero
			end
		end)
	elseif afC then afC:Disconnect() afC=nil end
end)
cdBtn.MouseButton1Click:Connect(function() clickDel=not clickDel tog(cdBtn,clickDel,"CDelete ON","CDelete OFF") end)
rstBtn.MouseButton1Click:Connect(function() if hum then hum.Health=0 end end)
killSelf.MouseButton1Click:Connect(function() if hum then hum.Health=0 end end)
svBtn.MouseButton1Click:Connect(function() upd() if root then savedCF=root.CFrame note("salvo") end end)
ldBtn.MouseButton1Click:Connect(function()
	upd()
	if root and savedCF then
		for i=1,8 do root.CFrame=savedCF root.AssemblyLinearVelocity=Vector3.zero task.wait() end
	end
end)
rjBtn.MouseButton1Click:Connect(function() TS:Teleport(game.PlaceId, lp) end)
hpBtn.MouseButton1Click:Connect(function()
	local ok,data=pcall(function()
		return Http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
	end)
	if ok and data and data.data then
		for _,s in ipairs(data.data) do
			if s.playing<s.maxPlayers and s.id~=game.JobId then
				TS:TeleportToPlaceInstance(game.PlaceId,s.id,lp) break
			end
		end
	end
end)
specBtn.MouseButton1Click:Connect(function() if hum then cam.CameraSubject=hum end end)
fbBtn.MouseButton1Click:Connect(function()
	fb=not fb
	tog(fbBtn,fb,"FB ON","FB OFF")
	if fb then
		Lighting.Brightness=4 Lighting.ClockTime=12 Lighting.FogEnd=9e9 Lighting.GlobalShadows=false
		Lighting.OutdoorAmbient=Color3.fromRGB(210,210,210)
	else
		Lighting.Brightness=1 Lighting.ClockTime=14 Lighting.FogEnd=100000 Lighting.GlobalShadows=true
	end
end)
fogBtn.MouseButton1Click:Connect(function()
	local on=fogBtn.Text:find("ON")
	tog(fogBtn, not on, "Fog ON", "Fog OFF")
	Lighting.FogEnd = on and 100000 or 9e9
end)
espBtn.MouseButton1Click:Connect(function() espOn=not espOn tog(espBtn,espOn,"ESP ON","ESP OFF") end)
xrBtn.MouseButton1Click:Connect(function()
	xray=not xray
	tog(xrBtn,xray,"XRay ON","XRay OFF")
	for _,v in ipairs(workspace:GetDescendants()) do
		if v:IsA("BasePart") and not v:IsDescendantOf(lp.Character or workspace) then
			if xray then
				if not v:GetAttribute("OT") then v:SetAttribute("OT", v.Transparency) end
				v.Transparency=math.max(v.Transparency,0.65)
			elseif v:GetAttribute("OT") then v.Transparency=v:GetAttribute("OT") end
		end
	end
end)
rbBtn.MouseButton1Click:Connect(function()
	rainbow=not rainbow
	tog(rbBtn,rainbow,"RGB ON","RGB OFF")
	if rainbow then
		rC=RS.RenderStepped:Connect(function()
			upd()
			if char then
				local h=(tick()*0.3)%1
				for _,p in ipairs(char:GetDescendants()) do
					if p:IsA("BasePart") then p.Color=Color3.fromHSV(h,0.8,1) end
				end
			end
		end)
	elseif rC then rC:Disconnect() rC=nil end
end)
fovBtn.MouseButton1Click:Connect(function() cam.FieldOfView=tonumber(fovBox.Text) or 70 end)
nite.MouseButton1Click:Connect(function() Lighting.ClockTime=0 end)
day.MouseButton1Click:Connect(function() Lighting.ClockTime=14 end)
rcam.MouseButton1Click:Connect(function() cam.CameraType=Enum.CameraType.Custom cam.FieldOfView=70 if hum then cam.CameraSubject=hum end end)
spBtn.MouseButton1Click:Connect(function()
	spinOn=not spinOn
	tog(spBtn,spinOn,"Spin ON","Spin OFF")
	if spinOn then
		sC=RS.RenderStepped:Connect(function() if root then root.CFrame*=CFrame.Angles(0,math.rad(14),0) end end)
	elseif sC then sC:Disconnect() sC=nil end
end)
akBtn.MouseButton1Click:Connect(function()
	afkOn=not afkOn
	tog(akBtn,afkOn,"AFK ON","AFK OFF")
	if afkOn then
		aC=RS.Heartbeat:Connect(function()
			pcall(function()
				local vu=game:GetService("VirtualUser")
				vu:CaptureController() vu:ClickButton2(Vector2.new())
			end)
		end)
	elseif aC then aC:Disconnect() aC=nil end
end)
acBtn.MouseButton1Click:Connect(function()
	autoClick=not autoClick
	tog(acBtn,autoClick,"AClick ON","AClick OFF")
	if autoClick then
		cC=RS.Heartbeat:Connect(function()
			pcall(function()
				VIM:SendMouseButtonEvent(0,0,0,true,game,1)
				VIM:SendMouseButtonEvent(0,0,0,false,game,1)
			end)
			task.wait(0.05)
		end)
	elseif cC then cC:Disconnect() cC=nil end
end)
fpsBtn.MouseButton1Click:Connect(function() pcall(function() settings().Rendering.QualityLevel=1 end) note("FPS+") end)
cpBtn.MouseButton1Click:Connect(function()
	upd()
	if root then pcall(function() setclipboard(string.format("%.1f, %.1f, %.1f", root.Position.X, root.Position.Y, root.Position.Z)) end) end
end)
hatBtn.MouseButton1Click:Connect(function() upd() if char then for _,v in ipairs(char:GetChildren()) do if v:IsA("Accessory") then v:Destroy() end end end end)
zmBtn.MouseButton1Click:Connect(function() lp.CameraMaxZoomDistance=9999 lp.CameraMinZoomDistance=0.5 end)
clBtn.MouseButton1Click:Connect(function() upd() if char then for _,v in ipairs(char:GetChildren()) do if v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") then v:Destroy() end end end end)
tlBtn.MouseButton1Click:Connect(function()
	upd()
	if char then for _,v in ipairs(char:GetChildren()) do if v:IsA("Tool") then v:Destroy() end end end
	if lp:FindFirstChild("Backpack") then for _,v in ipairs(lp.Backpack:GetChildren()) do if v:IsA("Tool") then v:Destroy() end end end
end)
waveBtn.MouseButton1Click:Connect(function() playEmote("wave") end)
danceBtn.MouseButton1Click:Connect(function() playEmote("dance") end)
cheerBtn.MouseButton1Click:Connect(function() playEmote("cheer") end)
laughBtn.MouseButton1Click:Connect(function() playEmote("laugh") end)
gBtn.MouseButton1Click:Connect(function() workspace.Gravity=tonumber(gBox.Text) or 196.2 end)
moon.MouseButton1Click:Connect(function() workspace.Gravity=30 gBox.Text="30" end)
earth.MouseButton1Click:Connect(function() workspace.Gravity=196.2 gBox.Text="196" end)
noP.MouseButton1Click:Connect(function()
	for _,v in ipairs(workspace:GetDescendants()) do
		if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then v.Enabled=false end
	end
end)
mute.MouseButton1Click:Connect(function()
	for _,v in ipairs(workspace:GetDescendants()) do if v:IsA("Sound") then v.Volume=0 end end
end)
now.MouseButton1Click:Connect(function()
	pcall(function() workspace.Terrain.WaterTransparency=1 workspace.Terrain.WaterWaveSize=0 end)
end)
bright.MouseButton1Click:Connect(function() Lighting.Brightness=5 end)
dark.MouseButton1Click:Connect(function() Lighting.Brightness=0.3 Lighting.ClockTime=0 end)
cn.MouseButton1Click:Connect(function() pcall(function() setclipboard(lp.Name) end) end)
ci.MouseButton1Click:Connect(function() pcall(function() setclipboard(tostring(lp.UserId)) end) end)
cj.MouseButton1Click:Connect(function() pcall(function() setclipboard(game.JobId) end) end)
rs.MouseButton1Click:Connect(function() if hum then hum.Health=0 end end)

closeBtn.MouseButton1Click:Connect(function() main.Visible=false openBtn.Visible=true end)
openBtn.MouseButton1Click:Connect(function() main.Visible=true openBtn.Visible=false end)
UIS.InputBegan:Connect(function(i,g)
	if g then return end
	if i.KeyCode==Enum.KeyCode.P then
		main.Visible=not main.Visible
		openBtn.Visible=not main.Visible
	end
end)

local function updInfo()
	info.Text = string.format("%s | %s\nId %s | Players %d", lp.Name, lp.DisplayName, lp.UserId, #Players:GetPlayers())
end
updInfo()
Players.PlayerAdded:Connect(function() refresh() updInfo() end)
Players.PlayerRemoving:Connect(function() refresh() updInfo() end)
task.spawn(function() while true do refresh() updInfo() task.wait(4) end end)

print("✅ Dragon v5")