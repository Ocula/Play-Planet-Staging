local ReplicatedStorage = game:GetService("ReplicatedStorage")
--local Knit = require(ReplicatedStorage.Packages.Knit)

local Roact = require(ReplicatedStorage:FindFirstChild("Roact", true))

local Splash = require(script.Parent.Splash)

return function(target)
	local splashUI = Roact.mount(Roact.createElement(Splash), target)

	return function()
		Roact.unmount(splashUI)
	end
end
