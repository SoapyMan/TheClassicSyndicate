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
SetMusicName("miami_night")

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
		targetPosition = Vector3D.new(38.26,0.60,-252.90),
		target2Position = Vector3D.new(602.00,0.60,889.88),
		target3Position = Vector3D.new(602.00,0.60,889.88)
	}
	
	MISSION.Settings.EnableCops = false
	
	local playerCar = gameses:CreateCar("dsyn_arvensis", CAR_TYPE_NORMAL)
	
	MISSION.playerCar = playerCar
	
	playerCar:SetMaxDamage(12.0)
	
	-- real
	playerCar:SetOrigin( Vector3D.new(1496.06,0.60,-246.57) )
	playerCar:SetAngles( Vector3D.new(-30.70,-85.19,30.69) )

	playerCar:Spawn()
	playerCar:SetColorScheme( 1 )
	
	MISSION.SpawnSceneryCars()

	-- for the load time, set player car
	gameses:SetPlayerCar( playerCar )
	
	playerCar:Lock(true)

	gameHUD:Enable(false)
	gameHUD:FadeIn(false, 2.5)
	gameHUD:ShowAlert("THE BANK JOB", 3.5, HUD_ALERT_NORMAL)

	-- testing
	--playerCar:SetOrigin( Vector3D.new(286.86, 6.13, 686.26) )
	--playerCar:SetAngles( Vector3D.new(0,90,0) )
	--MISSION.CarsCutscene()

	MISSION.SetupFlybyCutscene()


end

function MISSION.Phase1Start()
	
	local playerCar = MISSION.playerCar
	
	MISSION.Settings.EnableCops = false
	
	gameHUD:Enable(true)
	playerCar:Lock(false)
	
	MISSION.targetHandle = gameHUD:AddMapTargetPoint(MISSION.Data.targetPosition)

	-- here we start
	missionmanager:SetRefreshFunc( MISSION.Phase1Update )

	gameHUD:ShowScreenMessage("Get to the bank.", 3.5)
	
	missionmanager:EnableTimeout( true, 80 ) -- enable, time
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
	
	gameHUD:ShowScreenMessage("Well done!", 3.5)
end

function MISSION.CopsCutscene()
	local cop1 = gameses:CreatePursuerCar("cop_regis", PURSUER_TYPE_COP)
	
	local settings = MISSION.Settings
	
	cop1:SetOrigin( Vector3D.new(54.71,0.60,-137.53) )
	cop1:SetAngles( Vector3D.new(-179.08,55.42,-179.23) )
	
	cop1:Spawn()
	SetupCopCarSettings(cop1)
	
	local cop2 = gameses:CreatePursuerCar("cop_regis", PURSUER_TYPE_COP)
	
	cop2:SetOrigin( Vector3D.new(7.15,0.60,-161.90) )
	cop2:SetAngles( Vector3D.new(-35.32,-85.18,35.30) )

	cop2:Spawn()
	SetupCopCarSettings(cop2)
	
	missionmanager:SetRefreshFunc( function() 
		return false 
	end ) 
	
	-- for recording replays
	--gameses:SetPlayerCar(cop1)
	
	--local maxTime = math.min(replayDuration1,replayDuration2)
	
	missionmanager:ScheduleEvent( MISSION.Phase2Start, 2 )
end

function MISSION.Phase2Start()
	local playerCar = MISSION.playerCar
	playerCar:SetFelony(0.3)
	playerCar:Lock(false)
	
	MISSION.Settings.EnableCops = true
	
	gameHUD:Enable(true)
	
	ai:MakePursued( playerCar )
	
	missionmanager:EnableTimeout(false, 0)
	missionmanager:ShowTime( true )
	
	MISSION.safeHouseTarget = MISSION.Data.target2Position
	MISSION.targetHandle = gameHUD:AddMapTargetPoint(MISSION.safeHouseTarget)
	MISSION.safeHouseCops = false
	MISSION.finalTarget = true
	
	gameHUD:ShowScreenMessage("Get to the lock up.", 3.5)
	
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
				missionmanager:ScheduleEvent( MISSION.CopsCutscene, 2.5 )
			
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

function MISSION.SetUpCops()

	if MISSION.safeHouseCops then
		return
	end
	
	local cop1 = gameses:CreatePursuerCar("cop_regis", PURSUER_TYPE_COP)
	
	cop1:SetOrigin( Vector3D.new(583.60,0.60,444.55) )
	cop1:SetAngles( Vector3D.new(-179.72,33.60,-179.81) )

	cop1:Spawn()
	SetupCopCarSettings(cop1)
	
	local cop2 = gameses:CreatePursuerCar("cop_regis", PURSUER_TYPE_COP)
	
	cop2:SetOrigin( Vector3D.new(249.41,0.57,-26.21) )
	cop2:SetAngles( Vector3D.new(-1.57,46.31,-0.91) )
	
	cop2:Spawn()
	SetupCopCarSettings(cop2)

	MISSION.safeHouseCops = true
end

function MISSION.ChangeTargets()
	gameHUD:ShowScreenMessage("#MI01_NOTSAFE_MESSAGE", 3.5)
	
	gameHUD:RemoveTrackingObject(MISSION.targetHandle)
	
	MISSION.safeHouseTarget = MISSION.Data.target3Position
	MISSION.targetHandle = gameHUD:AddMapTargetPoint(MISSION.safeHouseTarget)
	
	MISSION.finalTarget = true
end

MISSION.Phase2Update = function( delta )

	local playerCar = MISSION.playerCar

	local distToTarget = length(playerCar:GetOrigin() - MISSION.safeHouseTarget)
	
	if MISSION.finalTarget then
	
		if distToTarget < 100 then
			MISSION.Settings.EnableCops = false
			
			if distToTarget < 70 then
				if playerCar:GetPursuedCount() > 0 then
					gameHUD:ShowScreenMessage("#LOSE_TAIL_MESSAGE", 1.5)
				elseif distToTarget < 5 then
					
					MISSION.OnCompleted()
				end
			end
		end
	else
		if distToTarget < 70 then
			-- spawn cop
			MISSION.SetUpCops()
			
			if distToTarget < 25 then
				MISSION.ChangeTargets()
			end
		end
	end
	
	return MISSION.UpdateAll(delta)
end