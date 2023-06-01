return function(_, players, speed)
	for _, player in pairs(players) do
		if player.Character then
			local hum = player.Character:FindFirstChild("Humanoid")

			if hum then
				hum.WalkSpeed = speed
			end
		end
	end

	return ("Set walkspeed of %d players to %d"):format(#players, speed)
end
