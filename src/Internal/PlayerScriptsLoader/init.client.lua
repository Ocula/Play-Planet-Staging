-- TECHNICALLY NOT NECESSARY BUT I'LL LEAVE IT FOR NOW

local PlayerModule = script.Parent:WaitForChild("PlayerModule")

local playerModuleObject = require(PlayerModule)
local cameraModuleObject = playerModuleObject:GetCameras()

--cameraModuleObject:SetTargetUpVector(Vector3.new(-0.5,1,0))
--[[
game:GetService("RunService").Heartbeat:Connect(function(_dt)
	local character = game.Players.LocalPlayer.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")

	if hrp then
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {character}

		local result = workspace:Raycast(hrp.Position, hrp.CFrame.YVector * -10, params)

		if result then
			cameraModuleObject:SetSpinPart(result.Instance)
			cameraModuleObject:SetTargetUpVector(result.Normal)
		end
	end
end)--]]