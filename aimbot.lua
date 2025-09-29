-- Configuration
local config = {
    TeamCheck = false,   -- Set to true to only target players on different teams
    FOV = 150,           -- Field of View
    Smoothing = 1,       -- Camera smoothing factor
}

-- Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- GUI
local FOVring = Drawing.new("Circle")
FOVring.Visible = false  -- Скрываем FOV кольцо изначально
FOVring.Thickness = 1.5
FOVring.Radius = config.FOV
FOVring.Transparency = 1
FOVring.Color = Color3.fromRGB(255, 128, 128)
FOVring.Position = workspace.CurrentCamera.ViewportSize / 2

-- Function to get the closest visible player
local function getClosestVisiblePlayer(camera)
    local ray = Ray.new(camera.CFrame.Position, camera.CFrame.LookVector)
    local closestPlayer = nil
    local closestDistance = math.huge
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer then
            local character = player.Character
            if character and character:FindFirstChild("Head") then
                local headPosition = character.Head.Position
                local targetPosition = ray:ClosestPoint(headPosition)
                local distance = (targetPosition - headPosition).Magnitude
                
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer
end

-- Переменные для отслеживания состояния правой кнопки мыши
local isRightMouseDown = false
local aimbotConnection

-- Функция обновления аимбота
local function updateAimbot()
    if isRightMouseDown then
        local currentCamera = workspace.CurrentCamera
        local crosshairPosition = currentCamera.ViewportSize / 2
        local closestPlayer = getClosestVisiblePlayer(currentCamera)
        
        if closestPlayer then
            local headPosition = closestPlayer.Character.Head.Position
            local headScreenPosition = currentCamera:WorldToScreenPoint(headPosition)
            local distanceToCrosshair = (Vector2.new(headScreenPosition.X, headScreenPosition.Y) - crosshairPosition).Magnitude
            
            if distanceToCrosshair < config.FOV then
                currentCamera.CFrame = currentCamera.CFrame:Lerp(CFrame.new(currentCamera.CFrame.Position, headPosition), config.Smoothing)
            end
        end
    end
end

-- Обработчик нажатий кнопок
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton2 then  -- Правая кнопка мыши
        isRightMouseDown = true
        FOVring.Visible = true
        FOVring.Position = workspace.CurrentCamera.ViewportSize / 2
        FOVring.Radius = config.FOV
        
        -- Подключаем функцию обновления аимбота
        if not aimbotConnection then
            aimbotConnection = RunService.RenderStepped:Connect(updateAimbot)
        end
    end
end)

-- Обработчик отпускания кнопок
UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton2 then  -- Правая кнопка мыши
        isRightMouseDown = false
        FOVring.Visible = false
        
        -- Отключаем функцию обновления аимбота
        if aimbotConnection then
            aimbotConnection:Disconnect()
            aimbotConnection = nil
        end
    end
end)