return {
	Name = "debug menu";
	Aliases = {"dbm", "debugmenu"};
	Description = "Opens or closes the debug menu.";
	Group = "DefaultDebug";
	Args = {
        {
			Type = "player";
			Name = "player";
			Description = "The player to toggle debug menu on.";
		},
    };

}