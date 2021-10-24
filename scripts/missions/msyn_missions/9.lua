--//////////////////////////////////////////////////////////////////////////////////
--// Copyright � Inspiration Byte
--// 2009-2019
--//////////////////////////////////////////////////////////////////////////////////

--------------------------------------------------------------------------------
-- By Shurumov Ilya
-- 26 Apr 2019
--------------------------------------------------------------------------------

world:SetLevelName("miamisyndicate2019")
world:SetEnvironmentName("dusk_night_transition")
SetMusicName("miami_night")

----------------------------------------------------------------------------------------------
-- Mission initialization
----------------------------------------------------------------------------------------------

MISSION.Init = function()
	MISSION.Data = {
		targetPosition = Vector3D.new(-644.17,1.01,991.75)
	}
	
	MISSION.Settings.EnableCops = true
	
	local playerCar = gameses:CreateCar("hexed_challengerxs", CAR_TYPE_NORMAL)
	
	MISSION.playerCar = playerCar
	
	playerCar:SetMaxDamage(6.0)
	
	-- real
	playerCar:SetOrigin( Vector3D.new(601.30,0.50,-1285.09) )
	playerCar:SetAngles( Vector3D.new(90.00,85.29,90.00) )

	playerCar:Spawn()
	playerCar:SetColorScheme( 1 )
	playerCar:SetFelony(0.2)

	-- for the load time, set player car
	gameses:SetPlayerCar( playerCar )
	
	playerCar:Lock(true)

	gameHUD:Enable(false)
	gameHUD:FadeIn(false, 2.5)
	gameHUD:ShowAlert("SUPERFLY DRIVE", 3.5, HUD_ALERT_NORMAL)

	-- testing
	--playerCar:SetOrigin( Vector3D.new(286.86, 6.13, 686.26) )
	--playerCar:SetAngles( Vector3D.new(0,90,0) )
	--MISSION.CarsCutscene()

	MISSION.SetupFlybyCutscene()


end

function MISSION.Phase1Start()
	
	local playerCar = MISSION.playerCar
	
	MISSION.Settings.EnableCops = true
	
	gameHUD:Enable(true)
	playerCar:Lock(false)
	
	MISSION.targetHandle = gameHUD:AddMapTargetPoint(MISSION.Data.targetPosition)

	-- here we start
	missionmanager:SetRefreshFunc( MISSION.Update )

	gameHUD:ShowScreenMessage("Take this puppy home.", 3.5)
	
	missionmanager:EnableTimeout( true, 120 ) -- enable, time

end

function MISSION.SetupFlybyCutscene()
	MISSION.cutCameraIndex = 1
	MISSION.cutCameraTime = 0.0
	MISSION.cutCameras = {
		{ Vector3D.new(584.47, 0.98, -1287.14), Vector3D.new(10.44, -70.86, 20.00), -1 },
		{ Vector3D.new(598.89, 0.98, -1287.14), Vector3D.new(3.12, -33.60, 0.00), 1.5 },
		{ Vector3D.new(607.76, 1.97, -1285.10), Vector3D.new(50.0, 90.0, 0.00), 2.0 },
		{ Vector3D.new(607.76, 1.97, -1285.10), Vector3D.new(0.0, 90.0, 0.00), 2.5 },
		{ Vector3D.new(607.76, 1.97, -1285.10), Vector3D.new(-5.0, 90.00, 0.00), 3.0 },
		{ Vector3D.new(607.76, 1.97, -1285.10), Vector3D.new(0.0, 90.00, 0.00), 3.5 },
		{ Vector3D.new(607.76, 1.97, -1285.10), Vector3D.new(0.0, 90.00, 0.00), 4.0 },
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
	
	local disc = length(playerCar:GetOrigin() - MISSION.Data.targetPosition)
	
		if disc < 200 then
			MISSION.Settings.EnableCops = false
			if disc < 100 then
				if playerCar:GetPursuedCount() > 0 then
					gameHUD:ShowScreenMessage("#LOSE_TAIL_MESSAGE", 1.5)
				elseif disc < 4.0 then	
					missionmanager:ScheduleEvent( MISSION.OnCompleted, 0.0 )
				end
			end
		end
	
	return true
end