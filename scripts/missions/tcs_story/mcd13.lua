----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- World Parameters --------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

world:SetLevelName("miamiclassic")
world:SetEnvironmentName("day_stormy")
SetMusicName("nyc_day")

MISSION.LoadingScreen = "resources/loadingscreen_mcd.res"

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Pre-Init Scenery --------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.SpawnSceneryCars()						-- Spawning NPC cars for scenery, pre-init
	local car1 = gameses:CreateCar("NPC_mcd_traffic01", CAR_TYPE_NORMAL)
	car1:SetOrigin( Vector3D.new(-84.5,0.77,-1143) )
	car1:SetAngles( Vector3D.new(180,0,180) )			-- Scenery items coords
	car1:Enable(false)
	car1:Spawn()
	car1:SetColorScheme(2)
	
	local car2 = gameses:CreateCar("NPC_mcd_traffic02", CAR_TYPE_NORMAL)
	car2:SetOrigin( Vector3D.new(-91.5,0.77,-1143) )
	car2:SetAngles( Vector3D.new(180,0,180) )
	car2:Enable(false)
	car2:Spawn()
	car2:SetColorScheme(0)
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Mission Init ------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

MISSION.Init = function()									-- Preparing Introduction
	MISSION.Data = {
		targetPosition = Vector3D.new(-352,0.7,-160),			-- Targets Positions
	}
	
	MISSION.Settings.EnableCops = false						-- Cops are disabled

	local playerCar = gameses:CreateCar(McdGetPlayerCarName(), CAR_TYPE_NORMAL)	-- Create player car
	
	MISSION.playerCar = playerCar	-- Define spawned car above as player car for mission

	MISSION.SpawnSceneryCars()
	
	playerCar:SetMaxDamage(12.0)
	playerCar:SetOrigin( Vector3D.new(-88,0.77,-1143) )						--Player car properties
	--DEVTESTplayerCar:SetOrigin( Vector3D.new(-119,0.70,-1115) )	
	playerCar:SetAngles( Vector3D.new(180,0,180) )
	playerCar:Spawn()
	playerCar:SetColorScheme( 1 )

	sounds:Precache( "wind.mcd13a" )
	sounds:Precache( "wind.mcd13b" )
	sounds:Precache( "wind.mcd13c" )

	--sounds:Precache( "door.garage" )

	local metro = WorldEvents:MakeInformantMover()
	MISSION.metro = metro 
	
	-- For the load time, set player car
	gameses:SetPlayerCar( playerCar )
	
	playerCar:Lock(true)

	gameHUD:Enable(false)								-- HUD disabled
	gameHUD:FadeIn(false, 2.5)								-- Screen Fade-In (Duration)
	gameHUD:ShowScreenMessage("THE INFORMANT", 3.5)				-- Classic title text (Duration)

	MISSION.SetupFlybyCutscene()	-- Starting Introduction FlyBy Cutscene 
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- FlyBy Cutscenes ---------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.SetupFlybyCutscene()

	local playerCar = MISSION.playerCar		-- Define player car for current phase

	missionmanager:ScheduleEvent( function() 
		sounds:Emit( EmitParams.new("wind.mcd13a"), 0 )
	end, 0.0);

	missionmanager:ScheduleEvent( function() 
		sounds:Emit( EmitParams.new("wind.mcd13b"), 0 )
	end, 3.0);

	missionmanager:ScheduleEvent( function() 
		sounds:Emit( EmitParams.new("wind.mcd13c"), 0 )
	end, 4.4);

	local targetView = cameraAnimator:GetComputedView()
	cameraAnimator:Update(0, gameses:GetPlayerCar())

	local cutCameras = {
		{
			{ Vector3D.new(-24, 5, -1090), Vector3D.new(-10, 414, 0), -1, 60 },
			{ Vector3D.new(-70, 5, -1090), Vector3D.new(-10, 311, 0), 3.0, 60 },
			{ Vector3D.new(-98, 2, -1090), Vector3D.new(0, 190, 20), 3.5, 60 },
			{ Vector3D.new(-122, 1.75, -1100), Vector3D.new(20, 227, 10), 4.0, 60 },
			{ Vector3D.new(-118, 1.5, -1130), Vector3D.new(10, 247, 0), 4.25, 60 },
			{ Vector3D.new(-105, 1.5, -1140), Vector3D.new(5, 228, -20), 4.5, 60 },
			{ targetView:GetOrigin(), targetView:GetAngles(), 5.0, targetView:GetFOV() },
			{ targetView:GetOrigin(), targetView:GetAngles(), 5.5, targetView:GetFOV() },
			{ targetView:GetOrigin(), targetView:GetAngles(), 6.0, targetView:GetFOV() },
			{ targetView:GetOrigin(), targetView:GetAngles(), 6.5, targetView:GetFOV() }
		}
	}

	McdCutsceneCamera.Start(cutCameras, MISSION.StartPause, 1)

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
function MISSION.CopsSpawnStart()
	local cop1 = gameses:CreateCar("NPC_mcd_defaultpolicecar_black", CAR_TYPE_PURSUER_COP_AI)
	
	local settings = MISSION.Settings
	
	cop1:SetOrigin( Vector3D.new(-185,0.7,-1095) )
	cop1:SetAngles( Vector3D.new(0,-90,0) )
	
	cop1:Spawn()
	SetupCopCarSettings(cop1)
	
	local cop2 = gameses:CreateCar("NPC_mcd_defaultpolicecar_black", CAR_TYPE_PURSUER_COP_AI)
	
	cop2:SetOrigin( Vector3D.new(17,0.7,-1160) )
	cop2:SetAngles( Vector3D.new(0,0,0) )

	cop2:Spawn()
	SetupCopCarSettings(cop2)
	
	ai:TrackCar(cop1)
	ai:TrackCar(cop2)
	
	missionmanager:SetRefreshFunc( function() 
		return false 
	end )
end

function MISSION.Phase1Start()
	
	local playerCar = MISSION.playerCar		-- Define player car for current phase

	MISSION.CopsSpawnStart()
	
	MISSION.Settings.EnableCops = true
	MISSION.Settings.StopCops = true
	MISSION.Settings.StopCopsRadius = 200
	MISSION.Settings.StopCopsPosition = MISSION.Data.targetPosition
	
	gameHUD:Enable(true)
	playerCar:Lock(false)

	--sounds:Emit( EmitParams.new("goon.go"), -1 )

	MISSION.finalTarget = 1
	
	-- Here we start
	MISSION.metro:Enable(true)

	MISSION.targetHandle = gameHUD:AddTrackingObject(MISSION.metro.object, HUD_DOBJ_IS_TARGET)

	missionmanager:SetRefreshFunc( MISSION.Phase1Update )

	gameHUD:ShowScreenMessage("Catch Jesse.", 3.5)
	
	missionmanager:EnableTimeout( true, 95 ) -- Enable, time
end

----------------------------------------------------------------------------------------------
-- Phase1 Update -----------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

MISSION.Phase1Update = function( delta )

	local playerCar = MISSION.playerCar		-- Define player car for current phase

	--local ep = EmitParams.new( "door.garage", vec3(1461, 0.7, 892) )
	--local sound = sounds:CreateController( ep )

	local distToTarget = length(playerCar:GetOrigin() - MISSION.Data.targetPosition)
	
	if MISSION.finalTarget then
	
		if distToTarget < 50 then	-- Cops are disabled when player enters % meters objective radius
			MISSION.Settings.EnableCops = false

			if playerCar:GetPursuedCount() > 0 then
				gameHUD:ShowScreenMessage("#LOSE_TAIL_MESSAGE", 1.5)	--.. Lost tail message on screen
			
			elseif distToTarget < 8 then	-- If player enters % meters radius while pursued, then..
				MISSION.OnCompleted()		-- ..Mission completed
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

function MISSION.OnFailed()

	local playerCar = MISSION.playerCar		-- Define player car for current phase

	gameses:SignalMissionStatus( MIS_STATUS_FAILED, 4.0 )
	
	MISSION.playerCar:Lock(true)
	
	missionmanager:SetRefreshFunc( function() 
		return false 
	end ) 

end

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
	
	gameses:SignalMissionStatus( MIS_STATUS_SUCCESS, 2.5 )

	-- Trigger MissionSuccess UI
	--gameHUD:ShowAlert("#MENU_GAME_TITLE_MISSION_SUCCESS", 3.5, HUD_ALERT_SUCCESS)		
	
	gameHUD:ShowScreenMessage("Well done!", 3.5)
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

	if (length(playerCar:GetOrigin() - MISSION.metro.object:GetOrigin()) > 125) then	-- Set up function

		gameHUD:ShowScreenMessage("You lost her.", 3.5)
		
		MISSION.OnFailed()
	end
	
	return true
end
