local TweenService = game:GetService("TweenService")

function calculateAverageSize(part)
    return (part.Size.X + part.Size.Y + part.Size.Z) / 3
end 

function rotatePartInCircle(part, speed)
    local angle = 0
    local radius = calculateAverageSize(part)
    
   local center = part.Position + Vector3.new(20, 0, 0)

    while true do
        local xPos = center.X + radius * math.cos(angle)
        local zPos = center.Z + radius * math.sin(angle)
        local newPosition = Vector3.new(xPos, part.Position.Y, zPos)

        local tweenInfo = TweenInfo.new(speed, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

        local tween = TweenService:Create(part, tweenInfo, {Position = newPosition})

        tween:Play()

        tween.Completed:Wait()

        angle = angle + speed
    end
end

rotatePartInCircle(workspace:FindFirstChild("default", true), 0.005)

return {} 