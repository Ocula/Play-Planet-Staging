return {
	Name = "speed",
	Aliases = { "walkspeed", "ws", "setspeed" },
	Description = "Sets walkspeed of a player.",
	Group = "DefaultAdmin",
	Args = {
		{
			Type = "players",
			Name = "players",
			Description = "Players to set the walkspeed of.",
		},
		{
			Type = "integer",
			Name = "Walkspeed",
			Description = "The speed you want to set these players to.",
		},
	},
}
