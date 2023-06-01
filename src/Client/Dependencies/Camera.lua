local camera = {}
camera.__index = camera

function camera.new()
	local self = setmetatable({}, camera)
	return self
end

function camera:Destroy() end

return camera
