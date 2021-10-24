----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- World Parameters --------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

world:SetLevelName("mattimiamiclassichd")
world:SetEnvironmentName("jeanpaul02_weather")
SetMusicName("nyc_night")

MISSION.LoadingScreen = "resources/loadingscreen_mcd.res"

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Pre-Init Scenery --------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Mission Init ------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

MISSION.Init = function()									-- Preparing Introduction
	MISSION.Data = {
		targetPosition = Vector3D.new(1459,0.7,892),			-- Targets Positions
	}
	
	MISSION.Settings.EnableCops = false						-- Cops are disabled

	local playerCar = gameses:CreateCar(McdHdGetPlayerCarName(), CAR_TYPE_NORMAL)	-- Create player car
	
	MISSION.playerCar = playerCar	-- Define spawned car above as player car for mission
	
	playerCar:SetMaxDamage(12.0)
	playerCar:SetOrigin( Vector3D.new(-88,0.77,-1143) )						--Player car properties
	--DEVTESTplayerCar:SetOrigin( Vector3D.new(-119,0.70,-1115) )	
	playerCar:SetAngles( Vector3D.new(180,0,180) )
	playerCar:Spawn()
	playerCar:SetColorScheme( 1 )

	--sounds:Precache( "door.garage" )
	sounds:Precache( "goon.go" )
	sounds:Precache( "goon.losetail" )

	playerCar:SetFelony(0.25)

	local restoreData = RestoreMissionCompletionData("mcd07a_endData")
	
	if restoreData ~= nil then	
	
		local playerCarData = restoreData.playerCarData
	
		playerCar:SetOrigin(toVector(playerCarData.position))
		playerCar:SetAngles(toVector(playerCarData.angles))
		playerCar:SetDamage(playerCarData.damage)
		playerCar:SetBodyDamage(playerCarData.bodyDamage)
		--playerCar:SetFelony(playerCarData.felony)
		
		local opponentCarData = restoreData.opponentCarData
		
		if opponentCarData ~= nil then -- PARANOID
		
			-- create beaten opponent car
			local opponentCar = gameses:CreateCar("alt_van", CAR_TYPE_NORMAL)

			opponentCar:SetOrigin( toVector(opponentCarData.position) )
			opponentCar:SetAngles( toVector(opponentCarData.angles) )
			opponentCar:SetDamage(opponentCarData.damage)
			opponentCar:SetBodyDamage(opponentCarData.bodyDamage)
			--opponentCar:SetFelony(opponentCarData.felony)

			opponentCar:Spawn()
		end
	end
	
	-- For the load time, set player car
	gameses:SetPlayerCar( playerCar )
	
	playerCar:Lock(true)

	gameHUD:Enable(false)								-- HUD disabled
	gameHUD:FadeIn(false, 0.5)								-- Screen Fade-In (Duration)
	gameHUD:ShowScreenMessage("BUST OUT JEAN PAUL (continued..)", 3.5)				-- Classic title text (Duration)

	MISSION.StartPause()	-- Starting Introduction FlyBy Cutscene 
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
			{ Vector3D.new(-95, 3.7, -1143), Vector3D.new(-20, 299, 0), 0, 60 },
			{ Vector3D.new(-95, 3.7, -1139), Vector3D.new(20, 239, 0), 0.5, 60 },
			{ Vector3D.new(-95, 3.7, -1138.50), Vector3D.new(20, 239, 0), 2.5, 60 },
			{ Vector3D.new(-88, 2.02, -1133.69), Vector3D.new(16, 180, -20), 3.5, 60 },
			{ Vector3D.new(-88, 2.02, -1133.69), Vector3D.new(8, 180, 0), 4.0, 60 },
			{ Vector3D.new(-88, 2.02, -1136.69), Vector3D.new(0, 180, 0), 4.2, 60 },
			{ Vector3D.new(-88, 2.02, -1136.69), Vector3D.new(-1, 180, 0), 4.5, 60 },
			{ Vector3D.new(-88, 2.02, -1136.99), Vector3D.new(0, 180, 0), 5.0, 60 },
			{ Vector3D.new(-88, 2.02, -1136.59), Vector3D.new(0, 180, 0), 5.3, 60 },
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

	missionmanager:ScheduleEvent( MISSION.Phase1Start, 2 )	-- Going into Phase2Start after 2 seconds
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
	--MISSION.Settings.StopCopsRadius = 300
	--MISSION.Settings.StopCopsPosition = MISSION.Data.targetPosition
	
	gameHUD:Enable(true)
	playerCar:Lock(false)

	sounds:Emit2D( EmitParams.new("goon.go"), -1 )

	MISSION.finalTarget = 1
	
	MISSION.targetHandle = gameHUD:AddMapTargetPoint(MISSION.Data.targetPosition)

	-- Here we start
	missionmanager:SetRefreshFunc( MISSION.Phase1Update )

	gameHUD:ShowScreenMessage("Get Jean-Paul out of there.", 3.5)
	
	missionmanager:EnableTimeout(false, 0)		-- Disable countdown timer
	missionmanager:ShowTime( true )				-- Enable countup timer
end

----------------------------------------------------------------------------------------------
-- Phase1 Update -----------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

MISSION.Phase1Update = function( delta )

	local playerCar = MISSION.playerCar		-- Define player car for current phase

	--local ep = EmitParams.new( "door.garage", vec3(1461, 0.7, 892) )
	--local sound = sounds:CreateController( ep )

	local distToTarget = length(playerCar:GetOrigin() - MISSION.Data.targetPosition)

    -- tell player every 20 seconds to lose tail
	if playerCar:GetPursuedCount() > 0 then
		if math.modf(math.fmod(missionmanager:GetMissionTime(), 20)) == 0 then
			sounds:Emit2D( EmitParams.new("goon.losetail"), -1 )
		end
	end
	
	if MISSION.finalTarget then
	
		if distToTarget < 50 then	-- Cops are disabled when player enters % meters objective radius
			MISSION.Settings.EnableCops = false

			if playerCar:GetPursuedCount() > 0 then
				gameHUD:ShowScreenMessage("#LOSE_TAIL_MESSAGE", 1.5)	--.. Lost tail message on screen
				--sound:Play()
				WorldEvents.jeanPaulDoor:Close()
			
			elseif distToTarget < 15 then	-- If player enters % meters radius while pursued, then..

				if playerCar:GetPursuedCount() == 0 then
					--sound:Play()
					WorldEvents.jeanPaulDoor:Open()
				end

				if distToTarget < 3 then
					missionmanager:ScheduleEvent( MISSION.DoorFinal, 1 )
					--sound:Play()
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

function MISSION.DoorFinal()						-- Marker disappears after reached by player
	WorldEvents.jeanPaulDoor:Close()
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