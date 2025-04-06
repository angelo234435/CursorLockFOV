-- LocalScript em StarterPlayerScripts

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local mouse = localPlayer:GetMouse()

-- CONFIG
local fovRadius = 100
local fovVisible = true
local activationKey = Enum.KeyCode.Q
local lockOn = false
local currentTarget = nil

-- GUI
local screenGui = Instance.new("ScreenGui", localPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "CursorLockUI"

-- FOV CIRCLE
local fovCircle = Instance.new("Frame")
fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.new(0, 0, 0, 0)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 0
fovCircle.ZIndex = 10

local circleVisual = Instance.new("ImageLabel", fovCircle)
circleVisual.BackgroundTransparency = 1
circleVisual.Size = UDim2.new(1, 0, 1, 0)
circleVisual.Image = "rbxassetid://3570695787"
circleVisual.ImageColor3 = Color3.fromRGB(255, 0, 0)
circleVisual.ImageTransparency = fovVisible and 0.4 or 1
circleVisual.ZIndex = 10

fovCircle.Parent = screenGui

-- SETTINGS UI
local settingsFrame = Instance.new("Frame", screenGui)
settingsFrame.Size = UDim2.new(0, 160, 0, 120)
settingsFrame.Position = UDim2.new(0, 10, 0, 10)
settingsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
settingsFrame.BorderSizePixel = 0
settingsFrame.BackgroundTransparency = 0.2
settingsFrame.Name = "SettingsFrame"

local function createButton(text, posY)
	local btn = Instance.new("TextButton", settingsFrame)
	btn.Size = UDim2.new(1, -10, 0, 24)
	btn.Position = UDim2.new(0, 5, 0, posY)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = text
	btn.TextScaled = true
	btn.AutoButtonColor = true
	btn.BorderSizePixel = 0
	return btn
end

local toggleFOV = createButton("FOV: ON", 5)
local increaseFOV = createButton("+ FOV", 35)
local decreaseFOV = createButton("- FOV", 65)
local changeKeyBtn = createButton("Tecla: Q", 95)

toggleFOV.MouseButton1Click:Connect(function()
	fovVisible = not fovVisible
	circleVisual.ImageTransparency = fovVisible and 0.4 or 1
	toggleFOV.Text = fovVisible and "FOV: ON" or "FOV: OFF"
end)

increaseFOV.MouseButton1Click:Connect(function()
	fovRadius += 20
	fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
end)

decreaseFOV.MouseButton1Click:Connect(function()
	if fovRadius > 20 then
		fovRadius -= 20
		fovCircle.Size = UDim2.new(0, fovRadius * 2, 0, fovRadius * 2)
	end
end)

changeKeyBtn.MouseButton1Click:Connect(function()
	changeKeyBtn.Text = "Pressione tecla..."
	local connection
	connection = UIS.InputBegan:Connect(function(input, processed)
		if not processed and input.UserInputType == Enum.UserInputType.Keyboard then
			activationKey = input.KeyCode
			changeKeyBtn.Text = "Tecla: " .. input.KeyCode.Name
			connection:Disconnect()
		end
	end)
end)

-- Atualizar posição do círculo em volta do cursor
RS.RenderStepped:Connect(function()
	local mousePos = UIS:GetMouseLocation()
	fovCircle.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y)
end)

-- Encontrar jogador mais próximo do mouse dentro do FOV
local function getClosestPlayer()
	local mousePos = UIS:GetMouseLocation()
	local closest = nil
	local shortestDistance = fovRadius

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = player.Character.HumanoidRootPart
			local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(hrp.Position)

			if onScreen then
				local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
				if dist < shortestDistance then
					closest = player
					shortestDistance = dist
				end
			end
		end
	end

	return closest
end

-- Lock visual (simulado)
RS.RenderStepped:Connect(function()
	if lockOn and currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
		-- Aqui você pode adicionar highlight, câmera, cursor falso, etc.
		-- Neste exemplo só mantém a referência
	else
		currentTarget = nil
	end
end)

-- Tecla de ativação
UIS.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == activationKey and not gameProcessed then
		if not lockOn then
			currentTarget = getClosestPlayer()
			if currentTarget then
				lockOn = true
			end
		else
			lockOn = false
			currentTarget = nil
		end
	end
end)

-- Checa se o alvo morreu
RS.Heartbeat:Connect(function()
	if currentTarget and (not currentTarget.Character or currentTarget.Character:FindFirstChild("Humanoid") and currentTarget.Character.Humanoid.Health <= 0) then
		lockOn = false
		currentTarget = nil
	end
end)
