panel
{
	position 		0 0;
	size 			640 480;	// map hud size to 640x480

	child container "menu_bg_top"
	{
		align			bottom left;
		scaling			uniform;
		position 		-450 0;
		size 			800 600;	// map hud size to 640x480

		transform
		{
			rotate 15;
			translate 0 0;
		}
		
		child panel "items_bg"
		{
			color		0.08 0.08 0.08 0.7;
			position 	0 0;
			size		750 2000;
			align		left vcenter;
			scaling		aspecth;
		}
		
		/*child image "lines_bg"
		{
			color		0.08 0.08 0.08 0.7;
			path		"ui/lines";
			position	750 15;
			size		300 2000;
			align		left vcenter;
		
			scaling		aspecth;
		}*/
	}
	
	font			"Cooper" 30 italic;
	fontScale		16 16;

	child HudElement "Menu"
	{
		position	40 0;//320 240;
		
		size		240 240;
		scaling		uniform;

		fontScale	16 16;
		
		textalign	left;
		align		vcenter left;
	}

	child label "label_missionobjective"
	{
		position	40 100;
		visible		0;
	
		size		540 80;
		scaling		uniform;
		//anchors		all;
		align		top left;
		textalign	left;
		fontScale	14 14;
	
		label		"Secret mission objective text no one will notice that one. You are undercover FBI agent Tohn Janner getting incorporated into syndicate";
		font		"Roboto" 30;
	}

	child HudElement "map"
	{
		position	20 30;
	
		size		500 500;
		scaling		uniform;
		align		vcenter hcenter;
	}
/*
	// may be some graphics?
	child container "controls_return"
	{
		align			bottom hcenter;
		scaling			uniform;
		position 		-150 10;
		size 			200 20;	// map hud size to 640x480
		selfvisible		0;

		child image "key_return"
		{
			position	0 0;
			atlas		"ui/ui_keys" esc;
			size		20 20;
			
			align		bottom left;
			scaling		aspecth;
		}
		
		
		child label "label_return"
		{
			position	24 5;
			visible		1;
		
			size		120 15;
			scaling		uniform;
			align		vcenter left;
			textalign	left;
			fontScale	10 10;
		
			label		"#MENU_HINT_BACK";
		}
	}
	
	child container "controls_navigate"
	{
		align			bottom hcenter;
		scaling			uniform;
		position 		10 10;
		size 			200 20;	// map hud size to 640x480
		selfvisible		0;

		child image "key_up"
		{
			position	0 0;
			atlas		"ui/ui_keys" arrow_up;
			size		20 20;
			
			align		bottom left;
			scaling		aspecth;
		}
		
		child image "key_dn"
		{
			position	20 0;
			atlas		"ui/ui_keys" arrow_dn;
			size		20 20;
			
			align		bottom left;
			scaling		aspecth;
		}
		
		child image "key_lt"
		{
			position	40 0;
			atlas		"ui/ui_keys" arrow_lt;
			size		20 20;
			
			align		bottom left;
			scaling		aspecth;
		}
		
		child image "key_rt"
		{
			position	60 0;
			atlas		"ui/ui_keys" arrow_rt;
			size		20 20;
			
			align		bottom left;
			scaling		aspecth;
		}
		
		child label "label_return"
		{
			position	84 5;
			visible		1;
		
			size		120 15;
			scaling		uniform;
			align		vcenter left;
			textalign	left;
			fontScale	10 10;
		
			label		"#MENU_HINT_NAVIGATE";
		}
	}

	child container "controls_enter"
	{
		align			bottom hcenter;
		scaling			uniform;
		position 		200 10;
		size 			120 20;	// map hud size to 640x480
		selfvisible		0;

		child image "key_enter"
		{
			position	0 0;
			atlas		"ui/ui_keys" enter;
			size		36 20;
			
			align		bottom left;
			scaling		aspecth;
		}
		
		child label "label_enter"
		{
			position	40 5;
			visible		1;
		
			size		120 15;
			scaling		uniform;
			align		vcenter left;
			textalign	left;
			fontScale	10 10;
		
			label		"#MENU_HINT_ACCEPT";
		}
	}*/
}