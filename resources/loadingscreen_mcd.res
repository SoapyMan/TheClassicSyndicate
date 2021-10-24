panel
{
	position 		0 0;
	size 			640 480;	// map hud size to 640x480

	font			"Roboto Condensed" 30;
	fontScale		14 14;

	child image "flickos"
	{
		path		"ui/noflickerzone";
		position	0 0;
		size		1000  1000;
		align		vcenter hcenter;

		scaling		aspecth;
		
		transform
		{
			scale 1.0 1.0;
		}
	}

	child image "background"
	{
		path		"ui/syndiclassic_logo";
		position	0 0;
		size		400  100;
		align		vcenter hcenter;

		scaling		aspecth;
		
		transform
		{
			scale 1.1 1.1;
		}
	}
	
	child label "loadingLabel"
	{
		position	8 20;
		size		200 100;
		label		"#GAME_IS_LOADING";

		font		"Roboto Condensed" 30 italic;
		textalign	center;
		
		scaling		aspecth;
		align		left bottom;
		visible		0;
		
		fontScale	18 18;
	}
}