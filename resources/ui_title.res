panel
{
	position 		0 0;
	size 			640 480;	// map hud size to 640x480

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

	child image "game_logo_sub"
	{
		path		"ui/syndiclassic_logo_sub";
		position	340 0;
		size		140 40;		//49

		align		hcenter;// vcenter;

		scaling		aspecth;
	}

	child label "title"
	{
		position	0 70;
		size		640 20;
		//anchors		right bottom;
		scaling		aspecth;

		align		bottom hcenter;
		textAlign	center;

		font			"Roboto Condensed" italic bold;

		label		"#MENU_TITLE_PRESS_ENTER";
		fontScale	18 18;
	}

	child label "copyright"
	{
		position	0 30;
		size		640 14;
		//anchors		right bottom;
		scaling		aspecth;
		align		bottom hcenter;

		textAlign	center;

		font		"Roboto" 30;

		label		"#INSCOPYRIGHT";
		fontScale	12 12;
	}

	child panel "fade"
	{
		position 		0 0;
		size 			640 480;	// map hud size to 640x480
		scaling			inherit;
		color			0 0 0 1;
	}
}