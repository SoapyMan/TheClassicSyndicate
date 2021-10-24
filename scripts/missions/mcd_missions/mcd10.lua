----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- World Parameters --------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

world:SetLevelName("mattimiamiclassic")
world:SetEnvironmentName("night_clear")
SetMusicName("miami_night")

MISSION.LoadingScreen = "resources/loadingscreen_mcd.res"

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Mission Init ------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

MISSION.Init = function()									-- Preparing Introduction
	MISSION.Data = {
		targetPosition = Vector3D.new(1808,0.7,1118),			-- Targets Positions
	}
	
	MISSION.Settings.EnableCops = false						-- Cops are disabled
	
	
	local playerCar = gameses:CreateCar("mcd_superflydrive", CAR_TYPE_NORMAL)	-- Create player car
	
	MISSION.playerCar = playerCar	-- Define spawned car above as player car for mission
	
	playerCar:SetMaxDamage(3.0)
	playerCar:SetOrigin( Vector3D.new(-1675,0.7,-433) )						--Player car properties
	--DEVTESTplayerCar:SetOrigin( Vector3D.new(-119,0.70,-1115) )	
	playerCar:SetAngles( Vector3D.new(180,180,180) )
	playerCar:Spawn()
	playerCar:SetColorScheme( 1 )

	sounds:Precache( "car.lightswitch" )
	sounds:Precache( "wind.mcd10a" )
	sounds:Precache( "wind.mcd10b" )

	-- For the load time, set player car
	gameses:SetPlayerCar( playerCar )
	
	playerCar:Lock(true)

	gameHUD:Enable(false)								-- HUD disabled
	gameHUD:FadeIn(false, 2.5)								-- Screen Fade-In (Duration)
	gameHUD:ShowScreenMessage("SUPERFLY DRIVE", 3.5)				-- Classic title text (Duration)

	MISSION.SetupFlybyCutscene()	-- Starting Introduction FlyBy Cutscene 
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- FlyBy Cutscenes ---------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.SetupFlybyCutscene()

	local playerCar = MISSION.playerCar		-- Define player car for current phase

	local cutCameras = {
		{
			{ Vector3D.new(-1675,0.8,-410), Vector3D.new(45,180,40), 0, 50 },
			{ Vector3D.new(-1675,0.8,-420), Vector3D.new(-10,180,0), 0.5, 50 },
			{ Vector3D.new(-1675,1.2,-428), Vector3D.new(5,180,0), 1.5, 50 },
			{ Vector3D.new(-1675,1.6,-428), Vector3D.new(10,180,0), 2.8, 50 },
			{ Vector3D.new(-1675,1.6,-428), Vector3D.new(10,320,0), 3.0, 50 },
		},
		{
			{ Vector3D.new(-1677.50,1.0,-436.50), Vector3D.new(2.20,-160,0), -1, 60 },
			{ Vector3D.new(-1677.50,1.0,-436.50), Vector3D.new(2.20,-51,0), 0.2, 60 },
			{ Vector3D.new(-1676.75,1.0,-437.50), Vector3D.new(2.20,-32,0), 1.5, 60 },
			{ Vector3D.new(-1674.99,2.0,-440), Vector3D.new(0,0,10), 1.7, 60 },
			{ Vector3D.new(-1674.99,2.0,-442), Vector3D.new(0,0,-3), 2.2, 60 },
			{ Vector3D.new(-1674.99, 1.92, -439.50), Vector3D.new(0,0,0), 2.5, 60 },
			{ Vector3D.new(-1674.99, 1.92, -439.50), Vector3D.new(0,0,0), 2.7, 60 },
			{ Vector3D.new(-1674.99, 1.92, -439.50), Vector3D.new(0,0,0), 3.2, 60 },
			{ Vector3D.new(-1674.99, 1.92, -439.40), Vector3D.new(0,0,0), 3.5, 60 },
		}
	}

	McdCutsceneCamera.Start(cutCameras, MISSION.StartPause, 1)
	
	missionmanager:ScheduleEvent( function() 
		playerCar:SetLight(CAR_LIGHT_LOWBEAMS, false);
	end, 0.1);

	missionmanager:ScheduleEvent( function() 
		playerCar:SetLight(CAR_LIGHT_LOWBEAMS, true);
	end, 2.0)

	missionmanager:ScheduleEvent( function() 
		sounds:Emit2D( EmitParams.new("car.lightswitch"), -1 )
	end, 2.0);

	missionmanager:ScheduleEvent( function() 
		sounds:Emit2D( EmitParams.new("wind.mcd10a"), 0 )
	end, 0.1);

	missionmanager:ScheduleEvent( function() 
		sounds:Emit2D( EmitParams.new("wind.mcd10b"), -1 )
	end, 2.6);

	missionmanager:ScheduleEvent( function() 
		sounds:Emit2D( EmitParams.new("wind.mcd10a"), 0 )
	end, 4.2);

end

function MISSION.StartPause()				-- Transition between Phase1Update and Phase2Start

	local playerCar = MISSION.playerCar

	gameHUD:Enable(true)

	missionmanager:SetRefreshFunc( function() 
		return false 
	end ) 

	missionmanager:ScheduleEvent( MISSION.Phase1Start, 1 )	-- Going into Phase2Start after 2 seconds
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Phase1 Start ------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.Phase1Start()
	
	local playerCar = MISSION.playerCar		-- Define player car for current phase
	
	MISSION.Settings.EnableCops = true
	MISSION.Settings.CopMaxSpeed = 155		-- Cops to be slower than player
	MISSION.Settings.StopCops = true
	MISSION.Settings.StopCopsRadius = 300
	MISSION.Settings.StopCopsPosition = MISSION.Data.targetPosition

	playerCar:SetFelony(0.2)
	
	gameHUD:Enable(true)
	playerCar:Lock(false)

	MISSION.finalTarget = 1
	
	MISSION.targetHandle = gameHUD:AddMapTargetPoint(MISSION.Data.targetPosition)

	-- Here we start
	missionmanager:SetRefreshFunc( MISSION.Phase1Update )

	gameHUD:ShowScreenMessage("Take this puppy home.", 3.5)
	
	missionmanager:EnableTimeout( true, 165 ) -- Enable, time
end

----------------------------------------------------------------------------------------------
-- Phase1 Update -----------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

MISSION.Phase1Update = function( delta )

	local playerCar = MISSION.playerCar		-- Define player car for current phase

	local distToTarget = length(playerCar:GetOrigin() - MISSION.Data.targetPosition)
	
	if MISSION.finalTarget then
	
		if distToTarget < 50 then	-- Cops are disabled when player enters % meters objective radius
			
			if distToTarget < 50 then	-- If player enters % meters radius while pursued, then..
				if playerCar:GetPursuedCount() > 0 then
					gameHUD:ShowScreenMessage("#LOSE_TAIL_MESSAGE", 1.5)	--.. Lost tail message on screen
				elseif distToTarget < 5 then	-- If player enters % meter objective radius, then..
					
					MISSION.OnCompleted()		-- ..Mission completed
				end
			end
		end
	end
	
	return MISSION.UpdateAll(delta)
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Phases Mission Mechanics ------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.OnDone()						-- Marker disappears after reached by player
	local playerCar = MISSION.playerCar
	
	gameHUD:RemoveTrackingObject(MISSION.targetHandle)

	playerCar:Lock(true)						-- Car is locked after reaching marker
	
	return true
end

function MISSION.OnCompleted()					-- Mission completed after all objectives are done
	MISSION.OnDone()
	
	missionmanager:SetRefreshFunc( function() 
		return false 
	end ) 
	
	gameses:SignalMissionStatus( MIS_STATUS_SUCCESS, 4.0 )

	-- Trigger MissionSuccess UI
	--gameHUD:ShowAlert("#MENU_GAME_TITLE_MISSION_SUCCESS", 3.5, HUD_ALERT_SUCCESS)		
	
	gameHUD:ShowScreenMessage("Good job!", 3.5)
end

MISSION.UpdateAll = function(delta)

	local camera = world:GetView()
	
	local playerCar = MISSION.playerCar		-- Define player car for current phase
	
	UpdateCops( playerCar, delta )

	-- Check player vehicle is wrecked
	if CheckVehicleIsWrecked( playerCar, MISSION.Data, delta ) then		-- If player car is wrecked, then..
		gameHUD:ShowAlert("#WRECKED_VEHICLE_MESSAGE", 3.5, HUD_ALERT_DANGER)	--.. Display wrecked message
		
		MISSION.OnDone()	-- Game Over
		
		missionmanager:SetRefreshFunc( function() 
			return false 
		end ) 

		gameses:SignalMissionStatus( MIS_STATUS_FAILED, 4.0 )
		return false
	end
	
	-- Check player's time is out
	if missionmanager:IsTimedOut() then		-- If player time is out, then..

		--gameHUD:ShowAlert("#TIME_UP_MESSAGE", 3.5, HUD_ALERT_DANGER)	--.. Display timeout message
		gameHUD:ShowScreenMessage("Too late. Mission is failed.", 3.5)	--.. Display classic timeout text

		MISSION.OnDone()	-- Game Over
		
		missionmanager:SetRefreshFunc( function() 
			return false 
		end ) 
		
		gameses:SignalMissionStatus( MIS_STATUS_FAILED, 4.0 )
		return false
	end
	
	return true
end