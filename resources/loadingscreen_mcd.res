panel
{
	position 		0 0;
	size 			640 480;	// map hud size to 640x480

	font			"Cooper" 30;
	fontScale		14 14;

	child image "background"
	{
		path		"ui/syndiclassic_bg";
		position	0 0;
		size		920  510;
		align		vcenter hcenter;

		scaling		aspecth;
	}

	child image "game_logo"
	{
		path		"ui/syndiclassic_logo";
		position	0 64;
		size		620 151;

		align		hcenter;// vcenter;

		scaling		aspecth;
	}

	child ProgressBar "progressBar"
	{
		position	10 20;
		size		200 22;

		align		left bottom;
		value		0.5;
		color		0.95 0.6 0.0 1.0;
		
		scaling		uniform;
	}

	child label "loadingLabel"
	{
		position	10 20;
		size		200 45;
		label		"#GAME_IS_LOADING";

		textalign	center;
		
		scaling		aspecth;
		align		left bottom;
		
		fontScale	24 24;
	}
}