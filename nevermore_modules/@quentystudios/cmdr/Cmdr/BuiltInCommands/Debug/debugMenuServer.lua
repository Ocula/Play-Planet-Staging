return function(_, player) 
    -- We implement this here because player position is owned by the client.
    -- No reason to bother the server for this!

    local playerGui = player:WaitForChild("PlayerGui") 
    local debug = playerGui:WaitForChild("Debug") 

    debug.Enabled = not debug.Enabled 

    return "Debug Menu set to "..tostring(debug.Enabled).." on player "..player.Name 
end