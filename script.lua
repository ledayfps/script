local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TeleportPlayers"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Botão para abrir/fechar
local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(0, 42, 0, 42)
openButton.Position = UDim2.new(0, 15, 0.5, -21)
openButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
openButton.Text = "☰"
openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openButton.TextSize = 22
openButton.Font = Enum.Font.GothamBold
openButton.Parent = gui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(0, 12)
openCorner.Parent = openButton

-- Painel
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 190, 0, 245)
frame.Position = UDim2.new(0, 65, 0.5, -122)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BorderSizePixel = 0
frame.Visible = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = frame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 38)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1
title.Text = "Teleport"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 17
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- Botão fechar
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 28, 0, 28)
closeButton.Position = UDim2.new(1, -35, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
closeButton.Text = "×"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 20
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Lista
local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, -20, 1, -52)
list.Position = UDim2.new(0, 10, 0, 47)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 3
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.Parent = list

-- Atualizar lista
local function atualizar()
    for _, obj in ipairs(list:GetChildren()) do
        if obj:IsA("TextButton") then
            obj:Destroy()
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then

            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, -5, 0, 32)
            button.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
            button.BorderSizePixel = 0
            button.Text = player.DisplayName
            button.TextColor3 = Color3.fromRGB(235, 235, 235)
            button.TextSize = 13
            button.Font = Enum.Font.GothamMedium
            button.Parent = list

            local buttonCorner = Instance.new("UICorner")
            buttonCorner.CornerRadius = UDim.new(0, 8)
            buttonCorner.Parent = button

            button.MouseButton1Click:Connect(function()
                local character = LocalPlayer.Character
                local target = player.Character

                if character and target then
                    local myRoot = character:FindFirstChild("HumanoidRootPart")
                    local targetRoot = target:FindFirstChild("HumanoidRootPart")

                    if myRoot and targetRoot then
                        myRoot.CFrame = targetRoot.CFrame + Vector3.new(3, 0, 0)
                    end
                end
            end)
        end
    end

    task.wait()
    list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 5)
end

-- Abrir/fechar
openButton.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

closeButton.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

Players.PlayerAdded:Connect(atualizar)
Players.PlayerRemoving:Connect(atualizar)

atualizar()