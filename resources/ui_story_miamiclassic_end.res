panel
{
	position 		0 0;
	size 			640 480;	// map hud size to 640x480
	
	//font			Roboto 30;

	font			"Roboto Condensed" 30 italic;
	fontScale		16 16;
	
	child image "background"
	{
		path		"ui/syndiclassic_bg";
		position	0 15;
		size		1000  500;
		align		vcenter hcenter;

		scaling		aspecth;
	}

	child label "message1"
	{
		position	0 150;
		size		640 120;
		//anchors		right bottom;
		scaling		aspecth;

		align		top hcenter;
		textAlign	center;

		font		"Roboto Condensed" italic bold;

		label
"You have completed &#00CDFF;Miami Classic&; story missions!";
		
		fontScale	22 22;
	}
	
	child label "message2"
	{
		position	0 270;
		size		640 420;
		//anchors		right bottom;
		scaling		aspecth;

		align		top hcenter;
		textAlign	center;

		font		"Roboto Condensed" italic bold;

		label
"Thank you for playing!
Looking for more mods? Feel free to visit &#FF8000;The Driver Syndicate&; website!";
		
		fontScale	18 18;
	}
	
		child label "message3"
	{
		position	0 360;
		size		640 420;
		//anchors		right bottom;
		scaling		aspecth;

		align		top hcenter;
		textAlign	center;

		font		"Roboto Condensed" italic bold;

		label
"Driver-Syndicate.com";
		
		fontScale	18 18;
	}

	child panel "fade"
	{
		position 		0 0;
		size 			640 480;	// map hud size to 640x480
		scaling			inherit;
	}
}