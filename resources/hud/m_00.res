base "defaulthud.res";

font	"Cooper" 30;

child Container "main"
{
	child ProgressBar "tcs_DamageBar"
	{
		visible 	0;
	}

	child ProgressBar tcs_FelonyBar"
	{
		visible 	0;
	}

	child image "map"
	{
		visible 	0;
	}

	// items found by Lua GUI API
	child image "timer_gauge"
	{
		atlas		"ui/m_00/stopwatch" "stopwatch";
		position	25 5;
		size		120 150;
		
		scaling		inherit_min;
		/*
		child image "timer_arrow"
		{
			atlas		"ui/m_00/stopwatch" "stopwatch_arrow";
			position	0 0;
			size		100 100;
		}*/
	}

	child Timer "timer"
	{
		position	40 58;
		size		85 85;
		
		scaling		inherit_min;

		font		"Roboto Condensed" 30;
		fontScale	30 30;
		textcolor	0 0 0 1;
		
		type		1;	// set timer type to have arrow
	}

	child image "tasks"
	{
		atlas		"ui/m_00/tasklist" "tasklist";
		
		align		right top;
		position	25 5;
		
		size		200 200;
		scaling		inherit_min;
		
		// damage
		child image "marker_hit_1"
		{
			atlas		"ui/m_00/tasklist" "marker_x1";
			position	85 10;
			size		16 16;
			scaling		inherit;
			visible 	0;
		}
		
		child image "marker_hit_2"
		{
			atlas		"ui/m_00/tasklist" "marker_x2";
			position	100 10;
			size		16 16;
			scaling		inherit;
			visible 	0;
		}
		
		child image "marker_hit_3"
		{
			atlas		"ui/m_00/tasklist" "marker_x3";
			position	115 10;
			size		16 16;
			scaling		inherit;
			visible 	0;
		}
		
		child image "marker_hit_4"
		{
			atlas		"ui/m_00/tasklist" "marker_x4";
			position	130 10;
			size		16 16;
			scaling		inherit;
			visible 	0;
		}
		
		// completion
		child image "marker_burnout"
		{
			atlas		"ui/m_00/tasklist" "marker_strike";
			position	75 32;
			size		60 8;
			scaling		inherit;
			visible 	0;
		}
		
		child image "marker_handbrake"
		{
			atlas		"ui/m_00/tasklist" "marker_strike";
			position	78 48;
			size		76 8;
			scaling		inherit;
			visible 	0;
		}
		
		child image "marker_slalom"
		{
			atlas		"ui/m_00/tasklist" "marker_strike";
			position	65 66;
			size		58 8;
			scaling		inherit;
			visible 	0;
		}
		
		child image "marker_180"
		{
			atlas		"ui/m_00/tasklist" "marker_strike";
			position	80 84;
			size		35 8;
			scaling		inherit;
			visible 	0;
		}
		
		child image "marker_360"
		{
			atlas		"ui/m_00/tasklist" "marker_strike";
			position	76 101;
			size		45 8;
			scaling		inherit;
			visible 	0;
		}

		child image "marker_rev180"
		{
			atlas		"ui/m_00/tasklist" "marker_strike";
			position	68 120;
			size		76 8;
			scaling		inherit;
			visible 	0;
		}
		
		child image "marker_speed"
		{
			atlas		"ui/m_00/tasklist" "marker_strike";
			position	78 138;
			size		44 8;
			scaling		inherit;
			visible 	0;
		}
		
		child image "marker_brake"
		{
			atlas		"ui/m_00/tasklist" "marker_strike";
			position	76 154;
			size		80 8;
			scaling		inherit;
			visible 	0;
		}
		
		child image "marker_lap"
		{
			atlas		"ui/m_00/tasklist" "marker_strike";
			position	84 172;
			size		36 8;
			scaling		inherit;
			visible 	0;
		}
	}
}