return {
	Name = "stopMusic";
	Aliases = {"stopTheme"};
	Description = "Calls stop on a soundtree. ID required.";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "players";
			Name = "targets";
			Description = "The players affected.";
		},
        {
            Type = "string";
            Name = "SoundTree ID";
            Description = "The soundtree ID";
        },
	};
}