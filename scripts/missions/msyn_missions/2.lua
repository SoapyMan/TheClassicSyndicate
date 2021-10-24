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
SetMusicName("frisco_day")

----------------------------------------------------------------------------------------------
-- Mission initialization
----------------------------------------------------------------------------------------------

MISSION.Init = function()
	MISSION.Data = {
		targetPosition = Vector3D.new(952.18,0.93,-373.65)
	}
	
	MISSION.Settings.EnableCops = true
	
	local playerCar = gameses:CreateCar("carla", CAR_TYPE_NORMAL)
	
	MISSION.playerCar = playerCar
	
	playerCar:SetMaxDamage(12.0)
	
	-- real
	playerCar:SetOrigin( Vector3D.new(-818.04,0.60,675.2) )
	playerCar:SetAngles( Vector3D.new(0.00,0.01,0.00) )

	playerCar:Spawn()
	playerCar:SetColorScheme( 7 )
	playerCar:SetFelony(0.2)

	-- for the load time, set player car
	gameses:SetPlayerCar( playerCar )
	
	playerCar:Lock(true)

	gameHUD:Enable(false)
	gameHUD:FadeIn(false, 2.5)
	gameHUD:ShowAlert("HIDE THE EVIDENCE", 3.5, HUD_ALERT_NORMAL)

	-- testing
	--playerCar:SetOrigin( Vector3D.new(286.86, 6.13, 686.26) )
	--playerCar:SetAngles( Vector3D.new(0,90,0) )
	--MISSION.CarsCutscene()

	MISSION.SetupFlybyCutscene()


end

function MISSION.Phase1Start()
	
	local playerCar = MISSION.playerCar
	
	MISSION.Settings.EnableCops = true

	MISSION.MusicScript = "frisco_day"
	
	gameHUD:Enable(true)
	playerCar:Lock(false)
	
	MISSION.targetHandle = gameHUD:AddMapTargetPoint(MISSION.Data.targetPosition)

	-- here we start
	missionmanager:SetRefreshFunc( MISSION.Update )

	gameHUD:ShowScreenMessage("Take it to the breakers.", 3.5)
	
	missionmanager:ShowTime( true )

	SetMusicState(MUSIC_STATE_PURSUIT)

end

function MISSION.SetupFlybyCutscene()
	MISSION.cutCameraIndex = 1
	MISSION.cutCameraTime = 0.0
	MISSION.cutCameras = {
		{ Vector3D.new(-813.95, 4.13, 672.73), Vector3D.new(35.50, 58, 0.00), -1 },
		{ Vector3D.new(-815.79, 3.33, 670.96), Vector3D.new(32.0, 29.84, 0.00), 1.5 },
		{ Vector3D.new(-818.04, 2.35, 668.80), Vector3D.new(3.82, 0.01, 0.00), 2 },
		{ Vector3D.new(-818.04, 2.35, 668.80), Vector3D.new(3.82, 0.01, 0.00), 2.5 },
		{ Vector3D.new(-818.04, 2.35, 668.80), Vector3D.new(3.82, 0.01, 0.00), 3 },
		{ Vector3D.new(-818.04, 2.35, 668.80), Vector3D.new(3.82, 0.01, 0.00), 3.5 },
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

function MISSION.OnFailed()
	gameses:SetLeadCar( MISSION.playerCar )
	MISSION.playerCar:Lock(true)
end

-- main mission update
MISSION.Update = function( delta )

	local camera = world:GetView()

	local playerCar = MISSION.playerCar
	
	UpdateCops( playerCar, delta )

	-- check player vehicle is wrecked
	if CheckVehicleIsWrecked( playerCar, MISSION.Data, delta ) then
		gameHUD:ShowAlert("#WRECKED_VEHICLE_MESSAGE", 3.5, HUD_ALERT_DANGER)
		
		MISSION.OnFailed()
		
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
	
	local distToEnd = length(playerCar:GetOrigin() - MISSION.Data.targetPosition)
	
		if distToEnd < 200 then
			MISSION.Settings.EnableCops = false
			if distToEnd < 100 then
				if playerCar:GetPursuedCount() > 0 then
					gameHUD:ShowScreenMessage("#LOSE_TAIL_MESSAGE", 1.5)
				elseif distToEnd < 4.0 then	
					missionmanager:ScheduleEvent( MISSION.OnCompleted, 0.0 )
				end
			end
		end
	
	return true
end