----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- World Parameters --------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

world:SetLevelName("mattimiamiclassichd")
world:SetEnvironmentName("night_stormy_norain")
SetMusicName("frisco_day")

MISSION.LoadingScreen = "resources/loadingscreen_mcd.res"

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Pre-Init Scenery --------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.SpawnSceneryCars()						-- Spawning NPC cars for scenery, pre-init
	local car1 = gameses:CreateCar("hd_scimitar", CAR_TYPE_NORMAL)
	car1:SetOrigin( Vector3D.new(-84.5,0.77,-1143) )
	car1:SetAngles( Vector3D.new(180,0,180) )			-- Scenery items coords
	car1:Enable(false)
	car1:Spawn()
	car1:SetColorScheme(2)
	
	local car2 = gameses:CreateCar("hd_toledosedan", CAR_TYPE_NORMAL)
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
		targetPosition = Vector3D.new(1125,0.70,-790),			-- Targets Positions
		target2Position = Vector3D.new(-88,0.70,-1135),
		--DEVTESTtargetPosition = Vector3D.new(-119,0.70,-1145),		
		--DEVTESTtarget2Position = Vector3D.new(-119,0.70,-1175),
	}
	
	MISSION.Settings.EnableCops = false						-- Cops are disabled

	MISSION.SpawnSceneryCars()
	
	local playerCar = gameses:CreateCar(McdHdGetPlayerCarName(), CAR_TYPE_NORMAL)	-- Create player car
	
	MISSION.playerCar = playerCar	-- Define spawned car above as player car for mission
	
	playerCar:SetMaxDamage(12.0)
	playerCar:SetOrigin( Vector3D.new(-88,0.77,-1143) )						--Player car properties
	--DEVTESTplayerCar:SetOrigin( Vector3D.new(-119,0.70,-1115) )	
	playerCar:SetAngles( Vector3D.new(180,0,180) )
	playerCar:Spawn()
	playerCar:SetColorScheme( 1 )

	sounds:Precache( "wind.mcd09" )
	sounds:Precache( "car.lightswitch" )

	-- For the load time, set player car
	gameses:SetPlayerCar( playerCar )
	
	playerCar:Lock(true)

	gameHUD:Enable(false)								-- HUD disabled
	gameHUD:FadeIn(false, 2.5)								-- Screen Fade-In (Duration)
	gameHUD:ShowScreenMessage("A SHIPMENT'S COMING IN", 3.5)				-- Classic title text (Duration)
	--gameHUD:ShowAlert("THE BANK JOB", 3.5, HUD_ALERT_NORMAL)		-- Syndicate title message (Duration)

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
		playerCar:SetLight(CAR_LIGHT_LOWBEAMS, false);
	end, 0);

	missionmanager:ScheduleEvent( function() 
		playerCar:SetLight(CAR_LIGHT_LOWBEAMS, true);
	end, 3.4)

	missionmanager:ScheduleEvent( function() 
		sounds:Emit2D( EmitParams.new("car.lightswitch"), -1 )
	end, 3.4);

	local cutCameras = {
		{
			{ Vector3D.new(-88.00,6.0,-1136.50), Vector3D.new(40, 180.02, 0), 0.0, 60 },
			{ Vector3D.new(-88.00,2.11,-1136.50), Vector3D.new(0.0, 180.02, 0), 5.0, 60 },
		}
	}

	McdCutsceneCamera.Start(cutCameras, MISSION.StartPause, 1)
	
	missionmanager:ScheduleEvent( function() 
		sounds:Emit2D( EmitParams.new("wind.mcd09"), -1 )
	end, 0.0);
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
	MISSION.Settings.StopCops = false
	MISSION.Settings.StopCopsRadius = 300
	MISSION.Settings.StopCopsPosition = MISSION.Data.targetPosition
		
	gameHUD:Enable(true)
	playerCar:Lock(false)
	
	MISSION.targetHandle = gameHUD:AddMapTargetPoint(MISSION.Data.targetPosition)

	-- Here we start
	missionmanager:SetRefreshFunc( MISSION.Phase1Update )

	gameHUD:ShowScreenMessage("Pick up the hardware.", 3.5)
	
	missionmanager:EnableTimeout( true, 200 ) -- Enable, time
end

----------------------------------------------------------------------------------------------
-- Phase1 Update -----------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

MISSION.Phase1Update = function( delta )

	local playerCar = MISSION.playerCar		-- Define player car for current phase

	local distToTarget = length(playerCar:GetOrigin() - MISSION.Data.targetPosition)
	local playerSpeed = playerCar:GetSpeed()		-- Check for Player speed

	if distToTarget < 15.0 then						-- If player enters % meters radius, then..

		if playerCar:GetPursuedCount() > 0 then
			gameHUD:ShowScreenMessage("#LOSE_TAIL_MESSAGE", 1.5)	-- .. Lose tail message on screen*
		elseif playerSpeed < 60 then				-- **If player speed is higher than %, then ..

			if distToTarget < 4.0 then
			
				gameHUD:RemoveTrackingObject(MISSION.targetHandle)		-- Remove marker
				
				playerCar:Lock(true)				-- Player car is locked upon reaching marker (for cutscene)

				missionmanager:EnableTimeout( false )	-- Disable countdown timer
				
				missionmanager:SetRefreshFunc( MISSION.KalashPrePause, 2 )	-- Going to transition step immediately
			end
		else
			gameHUD:ShowScreenMessage("Slow down!", 1.0) -- .. Slow down message on screen**
		end
	end
	
	return MISSION.UpdateAll(delta)
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Phase1 Mission Mechanics ------------------------------------------------------------------
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
	
	gameHUD:ShowScreenMessage("Well done!", 3.5)
end

----------------------------------------------------------------------------------------------
-- Kalash PrePause ---------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.KalashPrePause()

	local playerCar = MISSION.playerCar

	--local ep = EmitParams.new( "bank.jobalarm", vec3(-53, 1.0, 58) )
	--local sound = sounds:CreateController( ep )
	--sound:Play()

	gameHUD:Enable(false)
	playerCar:Lock(true)

	missionmanager:SetRefreshFunc( function() 
		return false 
	end ) 

	missionmanager:ScheduleEvent( MISSION.Phase2Start, 2 )	-- Going into Phase2Start after 2 seconds
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Phase2 Start ------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.Phase2Start()
	local playerCar = MISSION.playerCar			-- Define what the player car is for this phase

	local felony = playerCar:GetFelony()
	if felony < 0.3 then
	  felony = 0.2
	end
	playerCar:SetFelony(felony)

	playerCar:Lock(false)						-- Unlock player's car after robbery (MISSION.BankPause)
	
	MISSION.Settings.EnableCops = true			-- Enable cops
	MISSION.Settings.MaxCops = 2

	SetMusicState(MUSIC_STATE_PURSUIT)			-- Force PURSUIT Music

	gameHUD:Enable(true)						-- HUD enabled
	
	missionmanager:EnableTimeout(false, 0)		-- Disable countdown timer
	missionmanager:ShowTime( true )				-- Enable countup timer
	
	MISSION.safeHouseTarget = MISSION.Data.target2Position
	MISSION.targetHandle = gameHUD:AddMapTargetPoint(MISSION.safeHouseTarget)
	MISSION.safeHouseCops = false
	MISSION.finalTarget = true
	
	-- Show objective message (Duration)
	gameHUD:ShowScreenMessage("Get out of there and back to the motel.", 3.5)
	
	missionmanager:SetRefreshFunc( MISSION.Phase2Update )
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

----------------------------------------------------------------------------------------------
-- Phase2 Update -----------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

MISSION.Phase2Update = function( delta )

	local playerCar = MISSION.playerCar		-- Define player car for current phase

	local distToTarget = length(playerCar:GetOrigin() - MISSION.safeHouseTarget)
	
	if MISSION.finalTarget then
	
		if distToTarget < 300 then	-- Cops are disabled when player enters % meters objective radius
			MISSION.Settings.EnableCops = false
			
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