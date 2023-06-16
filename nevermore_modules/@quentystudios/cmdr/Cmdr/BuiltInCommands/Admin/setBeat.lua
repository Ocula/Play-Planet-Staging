return {
	Name = "setBeat";
	Aliases = {"settreebeat"};
	Description = "Sets the beat of a certain sound tree. ID required.";
	Group = "DefaultAdmin";
	Args = {
		{
			Type = "players";
			Name = "targets";
			Description = "The players to set Sound Tree ids on.";
		},
        {
            Type = "string";
            Name = "SoundTree ID";
            Description = "The soundtree ID";
        },
        {
            Type = "number";
            Name = "Beat";
            Description = "The beat you want to set it to.";
        }
	};
}