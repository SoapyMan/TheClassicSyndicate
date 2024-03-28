----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- World Parameters --------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

-- start _testing/mcd11_activelife

world:SetLevelName("miamiclassic")
world:SetEnvironmentName("night_clear")
SetMusicName("la_night")

MISSION.LoadingScreen = "resources/loadingscreen_mcd.res"

MISSION.PlayerRubberBandingParams = {
	[15.0] = {
		torqueScale = 1.0,
		maxSpeed = 135,
	},
	[40.0] = {
		torqueScale = 1.15,
		maxSpeed = 150,
	},
	[3000.0] = {
		torqueScale = 1.45,
		maxSpeed = 175,
	}
}

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Mission Init ------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

MISSION.Init = function()									-- Preparing Introduction
	MISSION.Data = {
		targetPosition = Vector3D.new(0,0,0),
		
		AITargets = {
			vec3(-472.24, 0.6, -62),
			vec3(-1450, 0.6, -734),
			vec3(1485, 0.5, 1110),
			vec3(-168, 0.5, -1230),
		},
	}
	
	MISSION.Settings.EnableCops = false						-- Cops are disabled

	local playerCar = gameses:CreateCar(McdGetPlayerCarName(), CAR_TYPE_NORMAL)	-- Create player car
	
	MISSION.playerCar = playerCar	-- Define spawned car above as player car for mission
	
	playerCar:SetMaxDamage(12.0)
	playerCar:SetOrigin( Vector3D.new(1860,0.70,-642) )						--Player car properties
	playerCar:SetAngles( Vector3D.new(0,-45,0) )
	playerCar:Spawn()
	playerCar:SetColorScheme( 1 )
	playerCar:SetMaxSpeed(170)
	playerCar:SetTorqueScale(1.2)

	sounds:Precache( "wind.mcd11a" )

	missionmanager:ScheduleEvent( function() 
		sounds:Emit( EmitParams.new("wind.mcd11a"), 0 )
	end, 1.8);

	--gameHUD:Enable(false)
	playerCar:Lock(true)

	gameHUD:Enable(false)								-- HUD disabled
	gameHUD:FadeIn(false, 2.5)								-- Screen Fade-In (Duration)
	gameHUD:ShowScreenMessage("TAKE OUT DI'ANGIO'S CAR", 3.5)				-- Classic title text (Duration)

----------------------------------------------------------------------------------------------
-- Opponent Car ------------------------------------------------------------------------------

	local opponentCar = gameses:CreateCar("NPC_mcd_traffic02", CAR_TYPE_NORMAL)
	MISSION.opponentCar = opponentCar
	opponentCar:SetMaxDamage(10000)
	
	-- opponent initial position
	opponentCar:SetOrigin( Vector3D.new(1890, 0.70, -606) )
	opponentCar:SetAngles( Vector3D.new(0, 0, 0) )

	opponentCar:Spawn()
	opponentCar:SetColorScheme( 3 )
	opponentCar:SetLight(0, false)
	
	opponentCar.onCarCollision = MISSION.OpponentHit
	
	MISSION.Settings.EnableCops = false

	-- for the load time, set player car
	gameses:SetPlayerCar( playerCar )
	gameses:SetLeadCar( opponentCar )
	
	MISSION.SetupFlybyCutscene()	-- Starting Introduction FlyBy Cutscene 
end

MISSION.JeanPaulSartre = function()

	local playerCar = MISSION.playerCar		-- Define player car for current phase
	local opponentCar = MISSION.opponentCar

	MISSION.currentTarget = (math.floor(math.random(0, #MISSION.Data.AITargets)) % (#MISSION.Data.AITargets)) + 1
	
	local activeLife = opponentCar:AddComponent("ActiveLifeAIComponent")
	activeLife:SetPersonalityType("racer")
	activeLife:SetAllowAutoRepath(true)
	
	missionmanager:ScheduleEvent( function() 
		activeLife:SetTargetPosition(MISSION.Data.AITargets[MISSION.currentTarget])
	end, 2.0)

	missionmanager:ScheduleEvent( function() 
		opponentCar:SetLight(CAR_LIGHT_LOWBEAMS, true);
	end, 1.5)
	
	-- give initial boost but take it away shortly after start
	opponentCar:SetTorqueScale(2.0)
	missionmanager:ScheduleEvent(function()
		opponentCar:SetTorqueScale(1.6)
	end, 2.0)

	gameHUD:Enable(true)
	playerCar:Lock(false)
	
	MISSION.targetHandle = gameHUD:AddTrackingObject(MISSION.opponentCar, HUD_DOBJ_IS_TARGET + HUD_DOBJ_CAR_DAMAGE)

	missionmanager:EnableTimeout( true, 145 ) -- enable, time

	-- here we start
	missionmanager:SetRefreshFunc( MISSION.Update )
	
	gameHUD:ShowScreenMessage("Ram him!", 3.5)
end

--------------------------------------------------------------------------------

function MISSION.OnCompleted()					-- Mission completed after all objectives are done

	local playerCar = MISSION.playerCar
	local opponentCar = MISSION.opponentCar

	-- show message and signal success
	gameHUD:ShowScreenMessage("Good job!", 3.5)

	gameses:SignalMissionStatus( MIS_STATUS_SUCCESS, 2.5, function()
	end)

	MISSION.ReleaseTarget()

	-- lock all the cars
	playerCar:Lock(true)						-- Car is locked after reaching marker
	opponentCar:Lock(true)
	opponentCar:RemoveComponent("ActiveLifeAIComponent")

	-- stop the vehicle playing loaded frames
	gameses:StopCarReplay(opponentCar)

	missionmanager:SetRefreshFunc( function() 
		return false 
	end )
end

function MISSION.OpponentHit(self, props)

	local opponentCar = MISSION.opponentCar
	local playerCar = MISSION.playerCar

	-- if hit by player car, add huge damage number
	if props.hitBy == playerCar and props.velocity > 4 then
		opponentCar:SetDamage(opponentCar:GetDamage() + 1000)
	end
end

function MISSION.ReleaseTarget()
	if MISSION.targetHandle ~= nil then
		gameHUD:RemoveTrackingObject(MISSION.targetHandle)
		MISSION.targetHandle = nil
	end
end

function MISSION.OnFailed()

	local playerCar = MISSION.playerCar		-- Define player car for current phase

	gameses:SignalMissionStatus( MIS_STATUS_FAILED, 4.0 )

	MISSION.ReleaseTarget()
	
	gameses:SetLeadCar( MISSION.playerCar )
	MISSION.playerCar:Lock(true)
	
	missionmanager:SetRefreshFunc( function() 
		return false 
	end ) 

end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- FlyBy Cutscenes ---------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.SetupFlybyCutscene()

	local playerCar = MISSION.playerCar		-- Define player car for current phase

	MISSION.cutCameraSet = 1
	MISSION.cutCameraIndex = 1
	MISSION.cutCameraTime = 0.0
	
	local targetView = cameraAnimator:GetComputedView()
	cameraAnimator:Update(0, gameses:GetPlayerCar())

	MISSION.cutCameras = {
		{
			{ Vector3D.new(1886, 4, -610), Vector3D.new(30, -60, -20), 0, targetView:GetFOV() },
			{ Vector3D.new(1886, 4, -610), Vector3D.new(20, -40, 0), 0.25, targetView:GetFOV() },
			{ Vector3D.new(1886, 1.5, -610), Vector3D.new(6, -40, 0), 2, targetView:GetFOV() },
			{ Vector3D.new(1855, 2.5, -648), Vector3D.new(0, -40, 0), 2.5, targetView:GetFOV() },
			{ targetView:GetOrigin(), targetView:GetAngles(), 3.0, targetView:GetFOV() },
			{ targetView:GetOrigin(), targetView:GetAngles(), 3.5, targetView:GetFOV() },
			{ targetView:GetOrigin(), targetView:GetAngles(), 4.0, targetView:GetFOV() },
			{ targetView:GetOrigin(), targetView:GetAngles(), 4.5, targetView:GetFOV() }
		}
	}

	MISSION.cutCameraAppr = MISSION.cutCameras[MISSION.cutCameraSet][MISSION.cutCameraIndex]

	-- Setup cameras
	cameraAnimator:SetScripted(true)

	missionmanager:SetRefreshFunc( function(delta)
	
		MISSION.cutCameraTime = MISSION.cutCameraTime + delta
	
		local camera = MISSION.cutCameras[MISSION.cutCameraSet][MISSION.cutCameraIndex]
		local nextCamera = MISSION.cutCameras[MISSION.cutCameraSet][MISSION.cutCameraIndex+1]
		
		if nextCamera ~= nil then
			if MISSION.cutCameraTime > nextCamera[3] then
				MISSION.cutCameraIndex = MISSION.cutCameraIndex + 1
			end
		else
			MISSION.cutCameraSet = MISSION.cutCameraSet + 1
			MISSION.cutCameraIndex = 1
			MISSION.cutCameraTime = 0
			
			
			if MISSION.cutCameraSet > #MISSION.cutCameras then
				Msg("END FLYBY")
				cameraAnimator:SetScripted(false)
				cameraAnimator:SetMode( CAM_MODE_OUTCAR )
				MISSION.StartPause()
			else
				MISSION.cutCameraAppr = MISSION.cutCameras[MISSION.cutCameraSet][MISSION.cutCameraIndex]
			end
			
			return
		end
		
		local cameraLerp = RemapValClamp(MISSION.cutCameraTime, camera[3], nextCamera[3], 0.0, 1.0)
		
		local cameraPos = lerp(camera[1], nextCamera[1], cameraLerp)
		local cameraRot = lerp(camera[2], nextCamera[2], cameraLerp)
		
		MISSION.cutCameraAppr[1] = lerp(MISSION.cutCameraAppr[1], cameraPos, delta*3.0 )
		MISSION.cutCameraAppr[2] = lerp(MISSION.cutCameraAppr[2], cameraRot, delta*3.0 )
		
		cameraAnimator:SetOrigin( MISSION.cutCameraAppr[1] )
		cameraAnimator:SetAngles( MISSION.cutCameraAppr[2] )
		cameraAnimator:SetFOV(camera[4])
		cameraAnimator:SetMode( CAM_MODE_TRIPOD )

		cameraAnimator:Update(delta, MISSION.playerCar)
		
		return true
	end )
end

function MISSION.StartPause()				-- Transition between Phase1Update and Phase2Start

	local playerCar = MISSION.playerCar

	gameHUD:Enable(true)

	missionmanager:SetRefreshFunc( function() 
		return false 
	end ) 

	missionmanager:ScheduleEvent( MISSION.JeanPaulSartre, 1 )	-- Going into Phase2Start after 2 seconds
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- JeanPaulSartre Mission Mechanics ----------------------------------------------------------
----------------------------------------------------------------------------------------------

MISSION.Update = function( delta )

	local curView = world:GetView()
	local arrowObject = MISSION.arrowObject
	local opponentCar = MISSION.opponentCar
	local playerCar = MISSION.playerCar

	-- update player rubber banding
	UpdateRubberBanding(playerCar, opponentCar:GetOrigin(), MISSION.PlayerRubberBandingParams)	

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
	
	-- check opponent vehicle is wrecked
	if opponentCar:IsAlive() then
	
		-- check the timer
		if missionmanager:IsTimedOut() then
			gameHUD:ShowScreenMessage("Too late. Mission is failed.", 3.5)
			
			MISSION.OnFailed()
		end
	
		-- check distance between the car and timer
		if (length(playerCar:GetOrigin() - opponentCar:GetOrigin()) > 120) then
			gameHUD:ShowScreenMessage("You lost him.", 3.5)
			MISSION.OnFailed()
		end
		
		-- switch target
		if length(opponentCar:GetOrigin() - MISSION.Data.AITargets[MISSION.currentTarget]) < 45.0 then
			MISSION.currentTarget = (math.floor(math.random(0, #MISSION.Data.AITargets)) % (#MISSION.Data.AITargets)) + 1
			
			local activeLife = opponentCar:GetComponent("ActiveLifeAIComponent")
			activeLife:SetTargetPosition(MISSION.Data.AITargets[MISSION.currentTarget])
		end
	else -- not alive - completed
		MISSION.OnCompleted()		
	end
	
	return true
end
