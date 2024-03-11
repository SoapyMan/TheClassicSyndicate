
-- Setup world data
world:SetLevelName("miamiclassic")
world:SetEnvironmentName("day_clear")
SetMusicName("miami_day")

MISSION.LoadingScreen = "resources/loadingscreen_mcd.res"

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Pre-Init Scenery --------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.SpawnSceneryCars()						-- Spawning NPC cars for scenery, pre-init
	local car1 = gameses:CreateCar("NPC_mcd_traffic01", CAR_TYPE_NORMAL)
	car1:SetOrigin( Vector3D.new(-84.5,0.77,-1143) )
	car1:SetAngles( Vector3D.new(180,0,180) )			-- Scenery items coords
	car1:Enable(false)
	car1:Spawn()
	car1:SetColorScheme(2)
	
	local car2 = gameses:CreateCar("NPC_mcd_traffic02", CAR_TYPE_NORMAL)
	car2:SetOrigin( Vector3D.new(-91.5,0.77,-1143) )
	car2:SetAngles( Vector3D.new(180,0,180) )
	car2:Enable(false)
	car2:Spawn()
	car2:SetColorScheme(0)
end

function MISSION.Init()

	sounds:Precache( "wind.mcd08a" )
	sounds:Precache( "wind.mcd08b" )
	sounds:Precache( "wind.mcd08c" )
	sounds:Precache( "wind.mcd08d" )

	-- setup mission targets
	MISSION.Data = {
		PlayerStart = {
			position = vec3(-88,0.77,-1143),
			angles = vec3(0,180,0),
			car = McdGetPlayerCarName(),
			colorId = 1,
			maxDamage = 12,
			lock = false
		},
	}
	
	MISSION.CurrentTarget = 1

	MISSION.Targets = {
		-- Restaurant 01 - Downtown Center
		{
			position = vec3(-143, 0.7, -453),
			radius = 5,	-- meters
			startMessage = "Get to the first restaurant.",
			timedOutMessage = "#TIME_UP_MESSAGE",
			wreckedMessage = "#WRECKED_VEHICLE_MESSAGE",
			addFelony = 0.015,
			-- add your other data...
		},
		-- Restaurant 02 - Downtown East
		{
			position = vec3(78, 0.7, -447),
			radius = 5,	-- meters
			startMessage = "Take out restaurant two.",
			timedOutMessage = "#TIME_UP_MESSAGE",
			wreckedMessage = "#WRECKED_VEHICLE_MESSAGE",
			addFelony = 0.015,
			-- add your other data...
		},
		-- Restaurant 03 - Downtown Up West
		{
			position = vec3(-336, 0.7, 34),
			radius = 5,	-- meters
			startMessage = "Smash restaurant three.",
			timedOutMessage = "#TIME_UP_MESSAGE",
			wreckedMessage = "#WRECKED_VEHICLE_MESSAGE",
			addFelony = 0.01,
		},
		-- Restaurant 04 - Coral Gables
		{
			position = vec3(-1672, 0.7, -115),
			radius = 5,	-- meters
			startMessage = "Wreck the fourth restaurant.",
			timedOutMessage = "#TIME_UP_MESSAGE",
			wreckedMessage = "#WRECKED_VEHICLE_MESSAGE",
			addFelony = 0.01,
		},
		-- Restaurant 05 - Coconut Grove
		{
			position = vec3(-1384, 0.7, -680),
			radius = 5,	-- meters
			startMessage = "Ram the last restaurant.",
			timedOutMessage = "#TIME_UP_MESSAGE",
			wreckedMessage = "#WRECKED_VEHICLE_MESSAGE",
			addFelony = 0.01,
		},
	}

	MISSION.Settings.EnableCops = false						-- Cops are disabled
	MISSION.SpawnSceneryCars()
	
	-- setup player car (REQUIRED)
	local playerCar = MISSION.InitPlayerCar( MISSION.Data.PlayerStart )
	
	playerCar:Lock(true)

	gameHUD:Enable(false)								-- HUD disabled
	gameHUD:FadeIn(false, 2.5)								-- Screen Fade-In (Duration)
	gameHUD:ShowScreenMessage("PAYBACK", 3.5)				-- Classic title text (Duration)

	-- setup initial state/phase
	MISSION.SetupFlybyCutscene()
end

function MISSION.SetupFlybyCutscene()

	local playerCar = MISSION.playerCar		-- Define player car for current phase

	missionmanager:ScheduleEvent( function() 
		sounds:Emit( EmitParams.new("wind.mcd08a"), -1 )
	end, 0.0);

	missionmanager:ScheduleEvent( function() 
		sounds:Emit( EmitParams.new("wind.mcd08b"), 0 )
	end, 1.3);

	missionmanager:ScheduleEvent( function() 
		sounds:Emit( EmitParams.new("wind.mcd08c"), -1 )
	end, 1.5);

	missionmanager:ScheduleEvent( function() 
		sounds:Emit( EmitParams.new("wind.mcd08d"), 0 )
	end, 3.0);

	missionmanager:ScheduleEvent( function() 
		sounds:Emit( EmitParams.new("wind.mcd08b"), -1 )
	end, 3.8);

	local targetView = cameraAnimator:GetComputedView()
	cameraAnimator:Update(0, gameses:GetPlayerCar())

	local cutCameras = {
		{
			{ Vector3D.new(-126, 6, -945), Vector3D.new(6, 270, 0), 0, 60 },
			{ Vector3D.new(-126, 2.5, -945), Vector3D.new(2, 270, 0), 1.5, 60 },
			{ Vector3D.new(-126, 2.5, -945), Vector3D.new(2, 120, -30), 1.75, 60 },
			{ Vector3D.new(-126, 2.5, -945), Vector3D.new(6, 180, 0), 2.0, 60 },
			{ Vector3D.new(-126, 2.5, -1100), Vector3D.new(8, 180, 0), 3.0, 60 },
			{ Vector3D.new(-114, 2.5, -1140), Vector3D.new(8, 220, 30), 3.5, 60 },
			{ Vector3D.new(-94, 2.25, -1140), Vector3D.new(6, 280, 0), 4.0, 60 },
			{ targetView:GetOrigin(), targetView:GetAngles() + vec3(4, 0, 0), 4.25, targetView:GetFOV() },
			{ targetView:GetOrigin(), targetView:GetAngles() + vec3(2, 0, 0), 4.5, targetView:GetFOV() },
			{ targetView:GetOrigin(), targetView:GetAngles(), 5.0, targetView:GetFOV() },
			{ targetView:GetOrigin(), targetView:GetAngles(), 6.0, targetView:GetFOV() }
		}
	}
	
	McdCutsceneCamera.Start(cutCameras, MISSION.StartTheMadness, 1)
end

function MISSION.StartTheMadness()
	local playerCar = gameses:GetPlayerCar()

	-- with slight pause
	missionmanager:ScheduleEvent( function()
		playerCar:Lock(false)
		gameHUD:Enable(true)
		MISSION.Settings.EnableCops = true
		
		missionmanager:EnableTimeout( true, 70 ) -- enable, time

		MISSION.StartTarget(MISSION.Targets[MISSION.CurrentTarget])
	end, 1)


end

function MISSION.OnCarCollision(go) -- go stands for "game object"
	local playerCar = gameses:GetPlayerCar()
	local targetData = MISSION.Targets[MISSION.CurrentTarget]

	if MISSION.InWreckZone and MISSION.WreckObjs[go] == nil then
		MISSION.WreckObjs[go] = true

		MISSION.WreckCounter = MISSION.WreckCounter + 1

		local addTime = 1.0 + MISSION.WreckCounter * 0.3
		missionmanager:AddSeconds(addTime)

		gameHUD:ShowScreenMessage(string.format("+%.1f sec", addTime), 1.0)

		local newFelony = playerCar:GetFelony() + targetData.addFelony
		playerCar:SetFelony(newFelony)

		if newFelony > 0.1 and MISSION.MusicState ~= MUSIC_STATE_PURSUIT then
			SetMusicState(MUSIC_STATE_PURSUIT)
		end
	end
	-- remove callback
	go:Set("OnCarCollision", nil)
end

function MISSION.GotoNextTarget()
	MISSION.CurrentTarget = MISSION.CurrentTarget + 1
	
	local targetData = MISSION.Targets[MISSION.CurrentTarget]
	
	if targetData ~= nil then
		MISSION.StartTarget(MISSION.Targets[MISSION.CurrentTarget])
	else
		MISSION.CompleteMission()
	end
end

function MISSION.SetupWreckZone(targetData)
	MISSION.InWreckZone = true
	MISSION.WreckCounter = 0
	MISSION.WreckObjs = {}
	
	objects:QueryObjects(targetData.radius, targetData.position, function(go)
		if go:GetType() == GO_DEBRIS then
			-- setup collision callback for debris objects
			go:Set("OnCarCollision", function() 
				MISSION.OnCarCollision(go)
			end)
		end
		return true
	end)
end

function MISSION.StartTarget(targetData, onComplete)
	-- change timer, setup HUD target, message
	MISSION.SetupTarget(targetData)
	
	-- reset wreck zone
	MISSION.InWreckZone = false

	-- setup your update function
	-- this will be called each frame of game update
	missionmanager:SetRefreshFunc(function(delta)
		-- do generic updates (cops, timer, damage)
		MISSION.GenericUpdate(targetData, delta)
		
		-- you still can access 'targetData' in this scope		
		-- if player is near target - switch phases
		if MISSION.CheckTargetCompletion(targetData) then
			-- you can process your own condition before really completing target
			MISSION.CompleteTarget(targetData)
			MISSION.SetupWreckZone(targetData)
			
			-- wait a bit to for player to collect his precious seconds
			missionmanager:ScheduleEvent( function()
				MISSION.GotoNextTarget()
			end, 3.0 )
		end
		
		return true -- true means timer is enabled
	end)
end


-----------------------------------------------------------------
-- SERVICE STUFF BELOW

-- reset state
function MISSION.ResetState()
	missionmanager:SetRefreshFunc(function(dt) 
		return false -- false means
	end)
end

-- you can setup any player car with that
function MISSION.InitPlayerCar( start )
	local playerCar = gameses:CreateCar(start.car, CAR_TYPE_NORMAL)
	
	-- setup
	playerCar:SetOrigin( start.position )
	playerCar:SetAngles( start.angles )
	playerCar:SetMaxDamage( start.maxDamage )
	playerCar:Lock(start.lock)
	
	-- FIXME: other params?

	playerCar:Spawn()
	playerCar:SetColorScheme( start.colorId )
	
	-- gain control over car
	gameses:SetPlayerCar( playerCar )
	
	return playerCar
end

-- generic mission state updates
function MISSION.GenericUpdate(targetData, delta)
	local playerCar = gameses:GetPlayerCar()

	-- update cops
	UpdateCops( playerCar, delta )
	
	-- check for timeout
	if targetData.timer ~= nil and missionmanager:IsTimedOut() then
		MISSION.SetFailed(targetData.timedOutMessage)
		return false
	end
	
	-- check if player vehicle is wrecked
	if CheckVehicleIsWrecked( playerCar, MISSION.Data, delta ) then
		MISSION.SetFailed(targetData.wreckedMessage)
		return false
	end
end

-- sets up target marker, timer
function MISSION.SetupTarget(targetData)

	if targetData.startMessage ~= nil then
		gameHUD:ShowScreenMessage(targetData.startMessage, 3.5)
	end

	-- add target on map and 3D world
	targetData.targetHandle = gameHUD:AddMapTargetPoint(targetData.position)
end

-- completes target
function MISSION.CompleteTarget(targetData)
	-- reset update function (in case if we're going use delays with ScheduleEvent)
	MISSION.ResetState()

	-- remove HUD target
	gameHUD:RemoveTrackingObject(targetData.targetHandle)
	
	-- remove timers
	--missionmanager:EnableTimeout( false, 0 )
	--missionmanager:ShowTime(false)
end

-- checks target radius
function MISSION.CheckTargetCompletion(targetData)
	local playerCar = gameses:GetPlayerCar()

	if length(targetData.position - playerCar:GetOrigin()) < targetData.radius then
		return true
	end
	
	return false
end

-- generic FAILURE
function MISSION.SetFailed(reasonText)
	MISSION.ResetState()

	local playerCar = gameses:GetPlayerCar()

	-- lock car, signal mission failure
	playerCar:Lock(true)
	gameses:SignalMissionStatus( MIS_STATUS_FAILED, 4.0 )

	-- show message
	if reasonText ~= nil then
		gameHUD:ShowAlert(reasonText, 3.5, HUD_ALERT_DANGER)
	end
end

-- generic COMPLETION
function MISSION.CompleteMission()
	MISSION.ResetState()

	-- lock car, signal mission completion
	local playerCar = gameses:GetPlayerCar()
	playerCar:Lock(true)
	gameses:SignalMissionStatus( MIS_STATUS_SUCCESS, 4.0 )
	
	-- show messages etc
	gameHUD:ShowScreenMessage("Good job!", 3.5)
end
