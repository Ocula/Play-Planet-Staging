return function(self)
	local props = self.props
	local textureSize = props.PatternID.Size / 2
	local textureSpeed = props.TextureSpeed or Vector2.new(0, 2)

	local currentOffset = props.ImageRectOffset:get()
	local newOffset = currentOffset + textureSpeed

	if newOffset.X >= textureSize.X or newOffset.Y >= textureSize.Y then
		newOffset = Vector2.new(0, 0)
	end

	props.ImageRectOffset:set(newOffset)
end
