position 		0 0;
size 			640 480;	// map hud size to 640x480

// main is used for hiding HUD elements
// Note that screen alert and message aren't hidden
child Container "main"
{
	position 		0 0;
	size 			640 480;	// map hud size to 640x480
	scaling			inherit;

	child ProgressBar "tcs_DamageBar"
	{
		position	20 30;
		
		size		210 17;
		scaling		inherit_min;

		child label "damageLabel"
		{
			position	5 -5;
			
			size		200 40;
			scaling		uniform;
			
			label		"#HUD_DAMAGE_TITLE";
			font		"Cooper" 30 bold italic;
			fontScale	16 16;
		}
	}

	child ProgressBar tcs_DamageBar2"
	{
		visible		0;
		position	20 30;
		
		size		210 17;
		scaling		inherit_min;

		align		right;

		child label "damageLabel"
		{
			position	5 -5;
			
			size		200 40;
			scaling		uniform;

			align		top right;
			textAlign	right;
			
			label		"#HUD_DAMAGE_TITLE";
			font		"Cooper" 30 bold italic;
			fontScale	16 16;
		}
	}

	child ProgressBar "tcs_FelonyBar"
	{
		position	20 60;
		
		size		210 17;
		scaling		inherit_min;

		child label "felonyLabel"
		{
			position	5 -5;
			
			size		200 40;
			scaling		uniform;
			
			label		"#HUD_FELONY_TITLE";
			font		"Cooper" 30 bold italic;
			fontScale	16 16;
		}
	}

	child Timer "timer"
	{
		position	-20 0;	// -50 because we want center it
		size		220 80;
		
		align		hcenter;
		textAlign	center;
		
		scaling		inherit_min;

		font		"Cooper" 30;
		fontScale	38 38;
		
		visible		0;
	}

	child image "map"
	{
		path		"_hudMap";
		position	20 30;
		align		bottom right;
		
		size		160 120;
		scaling		inherit_min;

		child image "radarColor"
		{
			position 	0 0;
			size 		160 120;
			scaling 	inherit;
			path		"_hudWhite";
		}
	}
}

child label "messageText"
{
	position	0 -50;
	visible		1;
	
	size		400 35;
	scaling		uniform;
	
	align		vcenter hcenter;
	textalign	center;
	
	label		"<message>";
	font		"Cooper" bold;
	fontScale	15 15;
}

// not used in this modbut kept for compatibility
child label "alertText"
{
	position	0 -90;
	visible		1;
	
	size		640 34;
	scaling		uniform;
	
	align		vcenter hcenter;
	textalign	center;
	
	label		"<ALERT TEXT>";
	font		"Cooper" bold italic;
	fontScale	25 25;
}

//---------------------------------------------------------------

child label "WIPText"
{
	position	15 20;
	visible		1;
	
	size		400 14;
	scaling		uniform;
	
	align		bottom left;
	textalign	left;
	
	label		"#GAME_VERSION";
	font		"Roboto" bold italic;
	fontScale	8 8;
}
