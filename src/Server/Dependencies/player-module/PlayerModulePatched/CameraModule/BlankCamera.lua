-- @ocula 2023
-- Replacing workspace.CurrentCamera so we can fake updates.

local Camera = workspace.CurrentCamera --:Clone()

-- set hum
local player = game.Players.LocalPlayer

--[[player.CharacterAdded:Connect(function()
    local hum = player.Character:WaitForChild("Humanoid") 
   -- local hrp = chr:WaitForChild("HumanoidRootPart") 
    Camera.CameraSubject = hum 
    --Camera.CameraType = "Custom"
end)--]]

--[[{
    CoordinateFrame = CFrame.new();
    CFrame = CFrame.new(); 
    Focus = CFrame.new(); 
    CameraSubject = nil; 
    FOV = 120; 
}; --]]

return Camera 