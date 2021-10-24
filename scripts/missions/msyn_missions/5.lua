--//////////////////////////////////////////////////////////////////////////////////
--// Copyright � Inspiration Byte
--// 2009-2019
--//////////////////////////////////////////////////////////////////////////////////

--------------------------------------------------------------------------------
-- By Shurumov Ilya
-- 26 Apr 2019
--------------------------------------------------------------------------------

world:SetLevelName("miamisyndicate2019")
world:SetEnvironmentName("day_clear")
SetMusicName("nyc_day")

----------------------------------------------------------------------------------------------
-- Mission initialization
----------------------------------------------------------------------------------------------

function MISSION.SpawnSceneryCars()
	local car1 = gameses:CreateCar("carla", CAR_TYPE_NORMAL)
	car1:SetOrigin( Vector3D.new(1497.05,0.60,-243.07) )
	car1:SetAngles( Vector3D.new(-14.27,-85.09,14.27) )
	car1:Enable(false)
	car1:Spawn()
	car1:SetColorScheme(2)
	
	local car2 = gameses:CreateCar("torino", CAR_TYPE_NORMAL)
	car2:SetOrigin( Vector3D.new(1497.54,0.60,-250.23) )
	car2:SetAngles( Vector3D.new(-17.56,-84.73,17.53) )
	car2:Enable(false)
	car2:Spawn()
	car2:SetColorScheme(2)
end

MISSION.Init = function()
	MISSION.Data = {
		targetPosition = Vector3D.new(552.54,0.57,-1248.66),
		target2Position = Vector3D.new(1457.72,0.60,-38.94),
		target3Position = Vector3D.new(393.30,16.0,657)
	}
	
	MISSION.Settings.EnableCops = true
	MISSION.Settings.MinCops = 2
	MISSION.Settings.MaxCops = 4
	
	local playerCar = gameses:CreateCar("dsyn_arvensis", CAR_TYPE_NORMAL)
	
	MISSION.playerCar = playerCar
	
	playerCar:SetMaxDamage(12.0)
	
	-- real
	playerCar:SetOrigin( Vector3D.new(1496.06,0.60,-246.57) )
	playerCar:SetAngles( Vector3D.new(-30.70,-85.19,30.69) )
	
	-- testing
	--playerCar:SetOrigin( Vector3D.new(557,0.53,-633) )
	--playerCar:SetAngles( Vector3D.new(0,180,0) )

	playerCar:Spawn()
	playerCar:SetColorScheme( 1 )
	
	MISSION.SpawnSceneryCars()

	-- for the load time, set player car
	gameses:SetPlayerCar( playerCar )
	
	playerCar:Lock(true)

	gameHUD:Enable(false)
	gameHUD:FadeIn(false, 2.5)
	gameHUD:ShowAlert("THE CLEAN UP", 3.5, HUD_ALERT_NORMAL)

	--MISSION.CarsCutscene()

	MISSION.SetupFlybyCutscene()


end

function MISSION.Phase1Start()
	
	local playerCar = MISSION.playerCar
	
	gameHUD:Enable(true)
	playerCar:Lock(false)
	
	MISSION.targetHandle = gameHUD:AddMapTargetPoint(MISSION.Data.targetPosition)

	-- here we start
	missionmanager:SetRefreshFunc( MISSION.Phase1Update )

	gameHUD:ShowScreenMessage("Pickup the car.", 3.5)
	
	missionmanager:EnableTimeout( true, 120 ) -- enable, time
end

function MISSION.SetupFlybyCutscene()
	MISSION.cutCameraIndex = 1
	MISSION.cutCameraTime = 0.0
	MISSION.cutCameras = {
		{ Vector3D.new(1481.88,9.23,-276.45), Vector3D.new(-6.08,181.66,0.00), 0 },
		{ Vector3D.new(1481.88,9.23,-276.45), Vector3D.new(-6.08,181.66,0.00), 0.25 },
		{ Vector3D.new(1481.35,5.57,-268.43), Vector3D.new(4.48,117.90,0.00), 2 },
		{ Vector3D.new(1476.16,3.97,-253.93), Vector3D.new(4.12,46.78,0.00), 3.5 },
		{ Vector3D.new(1490.41,1.48,-246.39), Vector3D.new(0,-90,0), 4.5 },
		{ Vector3D.new(1490.41,1.48,-246.39), Vector3D.new(3.76,-90.74,0.00), 6 },
		nil
	}
	
	MISSION.cutCameraAppr = MISSION.cutCameras[MISSION.cutCameraIndex]

	-- setup cameras
	cameraAnimator:SetScripted(true)

	missionmanager:SetRefreshFunc( function(delta)
	
		MISSION.cutCameraTime = MISSION.cutCameraTime + delta
	
		local camera = MISSION.cutCameras[MISSION.cutCameraIndex]
		local nextCamera = MISSION.cutCameras[MISSION.cutCameraIndex+1]
		
		if nextCamera ~= nil then
			if MISSION.cutCameraTime > nextCamera[3] then
				MISSION.cutCameraIndex = MISSION.cutCameraIndex + 1
			end
		else
			Msg("END FLYBY")
			cameraAnimator:SetScripted(false)
			cameraAnimator:SetMode( CAM_MODE_OUTCAR )
			MISSION.Phase1Start()
			return
		end
		
		local cameraLerp = RemapValClamp(MISSION.cutCameraTime, camera[3], nextCamera[3], 0.0, 1.0)
		
		local cameraPos = lerp(camera[1], nextCamera[1], cameraLerp)
		local cameraRot = lerp(camera[2], nextCamera[2], cameraLerp)
		
		MISSION.cutCameraAppr[1] = lerp(MISSION.cutCameraAppr[1], cameraPos, delta*3.0 )
		MISSION.cutCameraAppr[2] = lerp(MISSION.cutCameraAppr[2], cameraRot, delta*3.0 )
		
		cameraAnimator:SetOrigin( MISSION.cutCameraAppr[1] )
		cameraAnimator:SetAngles( MISSION.cutCameraAppr[2] )
		cameraAnimator:SetFOV(60)
		cameraAnimator:SetMode( CAM_MODE_TRIPOD )

		cameraAnimator:Update(delta, MISSION.playerCar)
		
		return true
	end )
end

--------------------------------------------------------------------------------

function MISSION.OnDone()
	local playerCar = MISSION.playerCar
	
	gameHUD:RemoveTrackingObject(MISSION.targetHandle)

	playerCar:Lock(true)
	
	return true
end

function MISSION.OnCompleted()
	MISSION.OnDone()
	
	missionmanager:SetRefreshFunc( function() 
		return false 
	end ) 
	
	gameses:SignalMissionStatus( MIS_STATUS_SUCCESS, 4.0 )
	
	gameHUD:ShowAlert("#MENU_GAME_TITLE_MISSION_SUCCESS", 3.5, HUD_ALERT_SUCCESS)
	
	gameHUD:ShowScreenMessage("Well Done!", 3.5)
end

function MISSION.CarsCutscene()
	
	ai:RemoveAllCars()
	gameHUD:Enable(false)
	
	MISSION.playerCar:SetOrigin( Vector3D.new(552.54,0.57,-1248.66) )
	MISSION.playerCar:SetAngles( Vector3D.new(90.00,89.99,90.00) )
	
	-- spawn some gangs and make the scene done
	MISSION.newPlayerCar = gameses:CreateCar("rollo", CAR_TYPE_NORMAL)

	MISSION.newPlayerCar:SetOrigin( Vector3D.new(546.80,0.57,-1254.97) )
	MISSION.newPlayerCar:SetAngles( Vector3D.new(90.00,89.99,90.00) )
	
	MISSION.newPlayerCar:SetMaxDamage(12.0)
	
	MISSION.newPlayerCar:Spawn()
	
	MISSION.newPlayerCar:SetColorScheme( 8 )

	MISSION.newPlayerCar:SetFelony(0.3)
	
	-- drop old player car
	MISSION.playerCar:Enable(false)
	MISSION.playerCar = MISSION.newPlayerCar
	gameses:SetPlayerCar(MISSION.newPlayerCar)

	local replayDuration1 = gameses:LoadCarReplay(MISSION.newPlayerCar, "replayData/qwert")
	
	-- load replays

	MISSION.cutCameraIndex = 1
	MISSION.cutCameraTime = 0.0
	MISSION.cutCameras = {
		{ Vector3D.new(569.53,0.60,-663.47), Vector3D.new(-5.52, 207.48, 0.0), CAM_MODE_TRIPOD, MISSION.playerCar, 0 },
		{ Vector3D.new(578.81,0.78,-662.83), Vector3D.new(0,150,0), CAM_MODE_TRIPOD, MISSION.playerCar, 4 },
		{ Vector3D.new(547.42,0.53,-673.30), Vector3D.new(-5, -78, 0), CAM_MODE_TRIPOD, MISSION.playerCar, 8 },
		{ Vector3D.new(559.98,1.06,-594.03), Vector3D.new(-1.56, -181.44, 0), CAM_MODE_TRIPOD, MISSION.playerCar, 12 },
		{ Vector3D.new(546.40,0.50, -522.17), Vector3D.new(0), CAM_MODE_TRIPOD_FOLLOW, MISSION.playerCar, 16 },
		{ Vector3D.new(531.46,0.53,-536.45), Vector3D.new(-8, 273, 0), CAM_MODE_TRIPOD, MISSION.playerCar, 22 },
		nil
	}

	-- setup cameras
	cameraAnimator:SetScripted(true)

	missionmanager:SetRefreshFunc( function(delta)
	
		MISSION.cutCameraTime = MISSION.cutCameraTime + delta
	
		local camera = MISSION.cutCameras[MISSION.cutCameraIndex]
		local nextCamera = MISSION.cutCameras[MISSION.cutCameraIndex+1]
		
		if nextCamera ~= nil then
			if MISSION.cutCameraTime > nextCamera[5] then
				MISSION.cutCameraIndex = MISSION.cutCameraIndex + 1
			end
		end
		
		cameraAnimator:SetOrigin( camera[1] )
		cameraAnimator:SetAngles( camera[2] )
		cameraAnimator:SetMode( camera[3] )

		cameraAnimator:Update(delta, camera[4])
		
		return true
	end )
	
	-- schedule mission success
	missionmanager:ScheduleEvent( function()
	
		cameraAnimator:SetScripted(false)
		cameraAnimator:SetMode( CAM_MODE_OUTCAR )
			
		MISSION.Phase2Start()
	end, replayDuration1 )
end

function MISSION.Phase2Start()
	local playerCar = MISSION.playerCar
	playerCar:Lock(false)
	
	gameHUD:Enable(true)
	
	missionmanager:EnableTimeout( false, 0 )
	missionmanager:ShowTime( true )
	
	MISSION.targetHandle = gameHUD:AddMapTargetPoint(MISSION.Data.target2Position)
	
	gameHUD:ShowScreenMessage("Get the hell out of there!", 3.5)
	
	missionmanager:SetRefreshFunc( MISSION.Phase2Update )
end

MISSION.UpdateAll = function(delta)

	local camera = world:GetView()
	
	local playerCar = MISSION.playerCar
	
	UpdateCops( playerCar, delta )

	-- check player vehicle is wrecked
	if CheckVehicleIsWrecked( playerCar, MISSION.Data, delta ) then
		gameHUD:ShowAlert("#WRECKED_VEHICLE_MESSAGE", 3.5, HUD_ALERT_DANGER)
		
		MISSION.OnDone()
		
		missionmanager:SetRefreshFunc( function() 
			return false 
		end ) 

		gameses:SignalMissionStatus( MIS_STATUS_FAILED, 4.0 )
		return false
	end
	
	if missionmanager:IsTimedOut() then
		gameHUD:ShowAlert("#TIME_UP_MESSAGE", 3.5, HUD_ALERT_DANGER)

		MISSION.OnDone()
		
		missionmanager:SetRefreshFunc( function() 
			return false 
		end ) 
		
		gameses:SignalMissionStatus( MIS_STATUS_FAILED, 4.0 )
		return false
	end
	
	return true
end

-- main mission update
MISSION.Phase1Update = function( delta )

	local playerCar = MISSION.playerCar

	local distToTarget = length(playerCar:GetOrigin() - MISSION.Data.targetPosition)
	local playerSpeed = playerCar:GetSpeed()

	if distToTarget < 80.0 then
	
		if playerCar:GetPursuedCount() > 0 then
			gameHUD:ShowScreenMessage("#LOSE_TAIL_MESSAGE", 1.5)
		elseif playerSpeed < 60 then

			if distToTarget < 4.0 then
			
				gameHUD:RemoveTrackingObject(MISSION.targetHandle)
				
				playerCar:Lock(true)
				
				missionmanager:EnableTimeout( false, 80 )
				
				-- TODO: cutscene black bar curtains
				missionmanager:ScheduleEvent( MISSION.CarsCutscene, 2.5 )
			
				missionmanager:SetRefreshFunc( function() 
					return false 
				end ) 
			
				return false
			end
		else
			gameHUD:ShowScreenMessage("#SLOW_DOWN_MESSAGE", 1.0)
		end
	end
	
	return MISSION.UpdateAll(delta)
end

MISSION.Phase2Update = function( delta )

	local playerCar = MISSION.playerCar

	local distToTarget = length(playerCar:GetOrigin() - MISSION.Data.target2Position)
	
	if distToTarget < 70 then
		if playerCar:GetPursuedCount() > 0 then
			gameHUD:ShowScreenMessage("#LOSE_TAIL_MESSAGE", 1.5)
		elseif distToTarget < 5 then
			MISSION.OnCompleted()
		end
	end
	
	return MISSION.UpdateAll(delta)
end