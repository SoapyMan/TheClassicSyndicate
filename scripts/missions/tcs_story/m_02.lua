----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- World Parameters --------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

world:SetLevelName("miamiclassic")
world:SetEnvironmentName("day_clear")
SetMusicName("frisco_day")

MISSION.LoadingScreen = "resources/loadingscreen_mcd.res"

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Mission Init ------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

MISSION.Init = function()									-- Preparing Introduction
	MISSION.Data = {
		--DEVtargetPosition = Vector3D.new(1560,0.70,1316),			-- Targets Positions
		targetPosition = Vector3D.new(-122,0.70,-725),		
	}
	
	MISSION.Settings.EnableCops = false						-- Cops are disabled
	
	local playerCar = gameses:CreateCar("m_evidence_ios", CAR_TYPE_NORMAL)	-- Create player car
	
	MISSION.playerCar = playerCar	-- Define spawned car above as player car for mission
	
	playerCar:SetMaxDamage(12.0)
	playerCar:SetOrigin( Vector3D.new(1568,0.70,1316) )						--Player car properties
	--DEVTESTplayerCar:SetOrigin( Vector3D.new(-119,0.70,-1115) )	
	playerCar:SetAngles( Vector3D.new(180,-90,-180) )
	playerCar:Spawn()
	playerCar:SetColorScheme( 1 )

	sounds:Precache( "wind.mcd02a" )
	sounds:Precache( "wind.mcd02b" )
	
	-- For the load time, set player car
	gameses:SetPlayerCar( playerCar )
	
	playerCar:Lock(true)

	gameHUD:Enable(false)								-- HUD disabled
	gameHUD:FadeIn(false, 2.5)								-- Screen Fade-In (Duration)
	gameHUD:ShowScreenMessage("HIDE THE EVIDENCE", 3.5)				-- Classic title text (Duration)
	--gameHUD:ShowAlert("HIDE THE EVIDENCE", 3.5, HUD_ALERT_NORMAL)		-- Syndicate title message (Duration)

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
		sounds:Emit( EmitParams.new("wind.mcd02a"), -1 )
	end, 1.5);

	missionmanager:ScheduleEvent( function() 
		sounds:Emit( EmitParams.new("wind.mcd02b"), 0 )
	end, 2.0);
	
	local cutCameras = {
		{
			{ Vector3D.new(1612, 6, 1245), Vector3D.new(5 ,270, 0), 0, 60 },
			{ Vector3D.new(1612, 4, 1245), Vector3D.new(0, 270, 0), 1.0, 60 },
			{ Vector3D.new(1612, 0.4, 1266), Vector3D.new(0, 120, 10), 1.5, 60 },
			{ Vector3D.new(1612, 0.4, 1327), Vector3D.new(0, 220, -20), 2.0, 60 },
			{ Vector3D.new(1607, 0.7, 1337), Vector3D.new(0, 118, 0), 2.5, 60 },
			{ Vector3D.new(1590, 1.5, 1341), Vector3D.new(3, 138, 10), 3.0, 60 },
			{ Vector3D.new(1571, 2, 1331), Vector3D.new(4, 167, 10), 3.5, 60 },
			{ Vector3D.new(1562, 2, 1320), Vector3D.new(11, 230, 10), 4.0, 60 },
			{ Vector3D.new(1561.52, 2.08, 1316), Vector3D.new(11, 270, 0), 4.2, 60 },
			{ Vector3D.new(1561.52, 2.08, 1316), Vector3D.new(11, 270, 0), 4.5, 60 },
			{ Vector3D.new(1561.52, 2.08, 1316), Vector3D.new(0, 270, 0), 4.8, 60 },
			{ Vector3D.new(1561.52, 2.08, 1316), Vector3D.new(0, 270, 0), 6.0, 60 },
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

function MISSION.Phase1Start()
	
	local playerCar = MISSION.playerCar		-- Define player car for current phase
	
	MISSION.Settings.EnableCops = true
	--MISSION.Settings.StopCops = true
	--MISSION.Settings.StopCopsRadius = 150
	--MISSION.Settings.StopCopsPosition = MISSION.Data.targetPosition
	
	gameHUD:Enable(true)
	playerCar:Lock(false)
	playerCar:SetFelony(0.2)

	SetMusicState(MUSIC_STATE_PURSUIT)			-- Force PURSUIT Music

	missionmanager:EnableTimeout(false, 0)		-- Disable countdown timer
	missionmanager:ShowTime( true )				-- Enable countup timer
	
	MISSION.targetHandle = gameHUD:AddMapTargetPoint(MISSION.Data.targetPosition)

	-- Here we start
	missionmanager:SetRefreshFunc( MISSION.Phase1Update )

	gameHUD:ShowScreenMessage("Take it to the breakers.", 3.5)
end

----------------------------------------------------------------------------------------------
-- Phase1 Update -----------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

MISSION.Phase1Update = function( delta )

	local playerCar = MISSION.playerCar		-- Define player car for current phase

	local distToTarget = length(playerCar:GetOrigin() - MISSION.Data.targetPosition)
	local playerSpeed = playerCar:GetSpeed()		-- Check for Player speed

	if distToTarget < 300 then	-- Cops are disabled when player enters % meters objective radius
		MISSION.Settings.EnableCops = false

		if distToTarget < 30.0 then						-- *If player enters % meters radius while pursued, then..
	
			if playerCar:GetPursuedCount() > 0 then
				gameHUD:ShowScreenMessage("#LOSE_TAIL_MESSAGE", 1.5)	-- .. Lose tail message on screen*
			elseif distToTarget < 4.0 then
			
				gameHUD:RemoveTrackingObject(MISSION.targetHandle)		-- Remove marker
				
				playerCar:Lock(true)				-- Player car is locked upon reaching marker (for cutscene)
				
				MISSION.OnCompleted()
			end
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
	
	return true
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Phase1 Update Alt Ending ------------------------------------------------------------------
----------------------------------------------------------------------------------------------

MISSION.Reserve = function( delta )

	local playerCar = MISSION.playerCar		-- Define player car for current phase

	local distToTarget = length(playerCar:GetOrigin() - MISSION.Data.targetPosition)
	local playerSpeed = playerCar:GetSpeed()		-- Check for Player speed

	if distToTarget < 300 then	-- Cops are disabled when player enters % meters objective radius
		MISSION.Settings.EnableCops = false

		if distToTarget < 30.0 then						-- *If player enters % meters radius while pursued, then..
	
			if playerCar:GetPursuedCount() > 0 then
				gameHUD:ShowScreenMessage("#LOSE_TAIL_MESSAGE", 1.5)	-- .. Lose tail message on screen*
			elseif playerSpeed < 60 then				-- **If player speed is higher than %, then ..

				if distToTarget < 4.0 then
			
					gameHUD:RemoveTrackingObject(MISSION.targetHandle)		-- Remove marker
				
					playerCar:Lock(true)				-- Player car is locked upon reaching marker (for cutscene)

					missionmanager:EnableTimeout( false )	-- Disable countdown timer
				
					missionmanager:ScheduleEvent( MISSION.OnCompleted, 0.0 )	-- Going to transition step immediately
																		-- (See MISSION.BankPause below)
					missionmanager:SetRefreshFunc( function() 
						return false 
					end ) 
				end
			else
				gameHUD:ShowScreenMessage("#SLOW_DOWN_MESSAGE", 1.0) -- .. Slow down message on screen**
			end
		end
	end
	
	return MISSION.UpdateAll(delta)
end
