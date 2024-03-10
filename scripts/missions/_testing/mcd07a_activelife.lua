----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- World Parameters --------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

-- start _testing/mcd07a_activelife

world:SetLevelName("miamiclassic")
world:SetEnvironmentName("day_clear")
SetMusicName("la_day")

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
			vec3(12.4, 0.6, -296),
			vec3(1419, 0.6, -288),
			vec3(1656, 0.5, 986),
			vec3(1777, 0.5, -470),
		},
	}
	
	MISSION.Settings.EnableCops = false						-- Cops are disabled

	local playerCar = gameses:CreateCar(McdGetPlayerCarName(), CAR_TYPE_NORMAL)	-- Create player car
	
	MISSION.playerCar = playerCar	-- Define spawned car above as player car for mission
	
	playerCar:SetMaxDamage(12.0)
	playerCar:SetOrigin( Vector3D.new(-350,0.70,-148) )						--Player car properties
	playerCar:SetAngles( Vector3D.new(180, 180,-180) )
	playerCar:Spawn()
	playerCar:SetColorScheme( 1 )
	--playerCar:SetMaxSpeed(170)
	--playerCar:SetTorqueScale(1.2)

	sounds:Precache( "wind.mcd07a" )
	sounds:Precache( "wind.mcd07b" )

	sounds:Precache( "goon.frenchcat" )

	--gameHUD:Enable(false)
	playerCar:Lock(true)

	gameHUD:Enable(false)								-- HUD disabled
	gameHUD:FadeIn(false, 2.5)								-- Screen Fade-In (Duration)
	gameHUD:ShowScreenMessage("BUST OUT JEAN PAUL", 3.5)				-- Classic title text (Duration)

----------------------------------------------------------------------------------------------
-- Opponent Car ------------------------------------------------------------------------------

	local opponentCar = gameses:CreateCar("mcd_defaultpolicecar_black", CAR_TYPE_NORMAL)
	MISSION.opponentCar = opponentCar
	opponentCar:SetMaxDamage(10000)
	
	-- opponent initial position
	opponentCar:SetOrigin( Vector3D.new(-393, 0.70, -90) )
	opponentCar:SetAngles( Vector3D.new(180, -90, -180) )

	opponentCar:Spawn()
	opponentCar:SetColorScheme( 1 )
	opponentCar:SetLight(0, false)
	
	opponentCar:Set("OnCarCollision", MISSION.OpponentHit)
	
	MISSION.Settings.EnableCops = false

	-- for the load time, set player car
	gameses:SetPlayerCar( playerCar )
	gameses:SetLeadCar( opponentCar )
	
	MISSION.SetupFlybyCutscene()	-- Starting Introduction FlyBy Cutscene 
end

MISSION.JeanPaulSartre = function()

	-- replay must be reset
	local playerCar = MISSION.playerCar		-- Define player car for current phase
	local opponentCar = MISSION.opponentCar
	
	MISSION.currentTarget = (math.floor(math.random(0, #MISSION.Data.AITargets)) % (#MISSION.Data.AITargets)) + 1
	
	local activeLife = opponentCar:AddComponent("ActiveLifeAIComponent")
	activeLife:SetPersonalityType("racer")
	activeLife:SetTargetPosition(MISSION.Data.AITargets[MISSION.currentTarget])

	sounds:Emit( EmitParams.new("goon.frenchcat"), -1 )

	gameHUD:Enable(true)
	playerCar:Lock(false)
	
	-- give initial boost but take it away shortly after start
	opponentCar:SetTorqueScale(2.0)
	missionmanager:ScheduleEvent(function()
		opponentCar:SetTorqueScale(1.0)
		opponentCar:SetSirenEnabled(true)
	end, 2.0)
	
	MISSION.targetHandle = gameHUD:AddTrackingObject(MISSION.opponentCar, HUD_DOBJ_IS_TARGET + HUD_DOBJ_CAR_DAMAGE)

	missionmanager:EnableTimeout( true, 140 ) -- enable, time

	-- here we start
	missionmanager:SetRefreshFunc( MISSION.Update )
	
	gameHUD:ShowScreenMessage("Ram the armoured car.", 3.5)
end

--------------------------------------------------------------------------------

function MISSION.OnCompleted()					-- Mission completed after all objectives are done
	local playerCar = MISSION.playerCar
	local opponentCar = MISSION.opponentCar
	
	MISSION.ReleaseTarget()
	
	-- lock all the cars
	playerCar:Lock(true)						-- Car is locked after reaching marker
	opponentCar:Lock(true)
	opponentCar:Set("OnCarCollision", nil)
	opponentCar:RemoveComponent("ActiveLifeAIComponent")
	
	missionmanager:SetRefreshFunc( function() 
		return false 
	end )

	-- show message and signal success
	gameHUD:ShowScreenMessage("to be continued...", 3.5)

	gameses:SignalMissionStatus( MIS_STATUS_SUCCESS, 2.5, function()
		-- setup mission completion data

		StoreMissionCompletionData("mcd07a_endData", {
			playerCarData = {
				position = playerCar:GetOrigin(),
				angles = playerCar:GetAngles(),
				damage = playerCar:GetDamage(),
				bodyDamage = playerCar:GetBodyDamage(),
				--felony = playerCar:GetFelony(),
			},
			opponentCarData = {
				position = opponentCar:GetOrigin(),
				angles = opponentCar:GetAngles(),
				damage = opponentCar:GetDamage(),
				bodyDamage = opponentCar:GetBodyDamage(),
				--felony = opponentCar:GetFelony(),
			}
		})
	end)
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
	
	gameses:SetLeadCar( nil )
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

	missionmanager:ScheduleEvent( function()
		sounds:Emit( EmitParams.new("wind.mcd07a"), -1 )
	end, 0.0);

	missionmanager:ScheduleEvent( function()
		sounds:Emit( EmitParams.new("wind.mcd07b"), 0 )
	end, 2.7);

	local targetView = cameraAnimator:GetComputedView()
	cameraAnimator:Update(0, gameses:GetPlayerCar())

	local cutCameras = {
		{
			{ Vector3D.new(-412, 12, -88), Vector3D.new(-7, 260, 20), 0, 50 },
			{ Vector3D.new(-412, 4, -88), Vector3D.new(10, 260, 0), 0.5, 50 },
			{ Vector3D.new(-401, 1.2, -88), Vector3D.new(4, 250, 0), 1.0, 50 },
			{ Vector3D.new(-397, 1.2, -88), Vector3D.new(4, 240, 0), 2.0, 50 },
			{ Vector3D.new(-394, 1.2, -88), Vector3D.new(4, 230, 0), 2.8, 50 },
			{ Vector3D.new(-394, 1.2, -88), Vector3D.new(4, 360, 0), 3.0, 50 },
		},
		{
			{ targetView:GetOrigin(), targetView:GetAngles() + vec3(0,-80,0), -1.0, targetView:GetFOV() },
			{ targetView:GetOrigin(), targetView:GetAngles(), 0.0, targetView:GetFOV() },
			{ targetView:GetOrigin(), targetView:GetAngles() + vec3(0,40,0), 0.25, targetView:GetFOV() },
			{ targetView:GetOrigin(), targetView:GetAngles(), 0.5, targetView:GetFOV() },
			{ targetView:GetOrigin(), targetView:GetAngles(), 1.5, targetView:GetFOV() }
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
