panel
{
	position 		0 0;
	size 			640 480;	// map hud size to 640x480
	
	//font			Roboto 30;

	font			"Roboto Condensed" 30 italic;
	fontScale		16 16;

	child image "background"
	{
		path		"ui/ui_menu_bg4";
		position	0 0;
		size		1100 500;
		align		vcenter hcenter;

		scaling		aspecth;
	}
	
	child container "menu_bg_top"
	{
		align			bottom left;
		scaling			uniform;
		position 		-350 0;
		size 			800 600;	// map hud size to 640x480

		transform
		{
			rotate 15;
			translate 0 0;
		}
		
		child panel "items_bg"
		{
			color		0.08 0.08 0.08 1;
			position 	0 0;
			size		500 2000;
			align		left vcenter;
			scaling		aspecth;
		}
		
		child image "lines_bg"
		{
			color		0.08 0.08 0.08 1;
			path		"ui/lines";
			position	490 15;
			size		300 2000;
			align		left vcenter;

		
			scaling		aspecth;
		}
	}

	child HudElement "Menu"
	{
		position	40 0;
		
		size		200 200;
		scaling		uniform;
		
		textalign	left;
		align		vcenter left;

		fontScale	14 14;
	}
	
			child image "game_logo_sub"
	{
	path		"ui/syndiclassic_logo_sub";
	position	340 0;
	size		140 40;		//49

	align		hcenter;// vcenter;
	
	scaling		aspecth;
	}
	
	child container "controls_return"
	{
		align			bottom left;
		scaling			uniform;
		position 		40 10;
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
		align			bottom right;
		scaling			uniform;
		position 		10 10;
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
	}
}