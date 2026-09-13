local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TeleportPlayers"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 300)
frame.Position = UDim2.new(0, 20, 0.5, -150)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "Jogadores"
title.TextScaled = true
title.Parent = frame

local list = Instance.new("ScrollingFrame")
list.Position = UDim2.new(0, 5, 0, 45)
list.Size = UDim2.new(1, -10, 1, -50)
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.Parent = list

local function atualizar()
	for _, v in ipairs(list:GetChildren()) do
		if v:IsA("TextButton") then
			v:Destroy()
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local button = Instance.new("TextButton")
			button.Size = UDim2.new(1, -10, 0, 40)
			button.Text = player.DisplayName .. "  @" .. player.Name
			button.TextScaled = true
			button.Parent = list

			button.MouseButton1Click:Connect(function()
				local meuChar = LocalPlayer.Character
				local alvoChar = player.Character

				if meuChar and alvoChar then
					local meuRoot = meuChar:FindFirstChild("HumanoidRootPart")
					local alvoRoot = alvoChar:FindFirstChild("HumanoidRootPart")

					if meuRoot and alvoRoot then
						meuRoot.CFrame = alvoRoot.CFrame + Vector3.new(3, 0, 0)
					end
				end
			end)
		end
	end

	list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end

Players.PlayerAdded:Connect(atualizar)
Players.PlayerRemoving:Connect(atualizar)

atualizar()