----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- World Parameters --------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

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

MISSION.replayId = 1

MISSION.PursuitDEVMODE = false

MISSION.Init = function()									-- Preparing Introduction
	MISSION.Data = {
		targetPosition = Vector3D.new(0,0,0),		
	}
	
	MISSION.Settings.EnableCops = false						-- Cops are disabled
	MISSION.Settings.EnableTraffic = false

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

	missionmanager:ScheduleEvent( MISSION.RemoveAllCars, 0 )	-- Going into Phase2Start after 2 seconds

	--gameHUD:Enable(false)
	playerCar:Lock(true)

	gameHUD:Enable(false)								-- HUD disabled
	gameHUD:FadeIn(false, 2.5)								-- Screen Fade-In (Duration)
	gameHUD:ShowScreenMessage("BUST OUT JEAN PAUL", 3.5)				-- Classic title text (Duration)

----------------------------------------------------------------------------------------------
-- Opponent Car ------------------------------------------------------------------------------

	local opponentCar = gameses:CreateCar("mcd_defaultpolicecar_black", CAR_TYPE_NORMAL)
	MISSION.opponentCar = opponentCar
	opponentCar:SetMaxDamage(5000)
	
	-- opponent initial position
	opponentCar:SetOrigin( Vector3D.new(-393, 0.70, -90) )
	opponentCar:SetAngles( Vector3D.new(180, -90, -180) )

	opponentCar:Spawn()
	opponentCar:SetColorScheme( 1 )
	opponentCar:SetInfiniteMass(true)
	opponentCar:SetLight(0, false)
	
	opponentCar:Set("OnCarCollision", MISSION.OpponentHit)
	
	MISSION.Settings.EnableCops = false

	-- for the load time, set player car
	gameses:SetPlayerCar( playerCar )
	gameses:SetLeadCar( opponentCar )
	
	local randomSeed = {
		2,
		1,
		1,
	}
	
	MISSION.RandomSeed = randomSeed[MISSION.replayId]
	MISSION.CurrentReplayId = MISSION.replayId
	MISSION.replayId = MISSION.replayId + 1		-- Every time the suffix of replay file name will change
	
	if MISSION.replayId > 3 then
		MISSION.replayId = 1					-- replay_1, replay_2, etc
	end

	MISSION.SetupFlybyCutscene()	-- Starting Introduction FlyBy Cutscene 
end

MISSION.JeanPaulSartre = function()

	-- replay must be reset
	gameses:LoadCarReplay(MISSION.opponentCar, "replayData/bustout01_" .. MISSION.CurrentReplayId)

	local playerCar = MISSION.playerCar		-- Define player car for current phase
	local opponentCar = MISSION.opponentCar

	missionmanager:ScheduleEvent( MISSION.RemoveAllCars, 0 )	-- Going into Phase2Start after 2 seconds

	sounds:Emit2D( EmitParams.new("goon.frenchcat"), -1 )

	gameHUD:Enable(true)
	playerCar:Lock(false)
	
	MISSION.targetHandle = gameHUD:AddTrackingObject(MISSION.opponentCar, HUD_DOBJ_IS_TARGET + HUD_DOBJ_CAR_DAMAGE)

	missionmanager:EnableTimeout( true, 90 ) -- enable, time

	-- here we start
	missionmanager:SetRefreshFunc( MISSION.Update )
	
	gameHUD:ShowScreenMessage("Ram the armoured car.", 3.5)
end

--------------------------------------------------------------------------------

function MISSION.RemoveAllCars()					-- Mission completed after all objectives are done
	ai:RemoveAllCars()
		--ai:SetTrafficCarsEnabled(false)
end

function MISSION.OnCompleted()					-- Mission completed after all objectives are done

	local playerCar = MISSION.playerCar
	local opponentCar = MISSION.opponentCar

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

	MISSION.ReleaseTarget()

	-- lock all the cars
	playerCar:Lock(true)						-- Car is locked after reaching marker
	opponentCar:Lock(true)

	-- stop the vehicle playing loaded frames
	gameses:StopCarReplay(opponentCar);
	opponentCar:SetInfiniteMass(false)

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

	missionmanager:ScheduleEvent( function() 
		sounds:Emit2D( EmitParams.new("wind.mcd07a"), -1 )
	end, 0.0);

	missionmanager:ScheduleEvent( function() 
		sounds:Emit2D( EmitParams.new("wind.mcd07b"), 0 )
	end, 2.7);

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
			{ Vector3D.new(-350, 2.5, -154.50), Vector3D.new(0, -80, 0), -1, 60 },
			{ Vector3D.new(-350, 1.99, -154.50), Vector3D.new(0, 0, 0), 0.0, 60 },
			{ Vector3D.new(-350, 1.99, -154.50), Vector3D.new(0, 40, 0), 0.25, 60 },
			{ Vector3D.new(-350, 1.99, -154.50), Vector3D.new(0, 0, 0), 0.5, 60 },
			{ Vector3D.new(-350, 1.99, -154.50), Vector3D.new(0, 0, 0), 1.5, 60 },
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
	else -- not alive - completed
		MISSION.OnCompleted()		
	end
	
	return true
end