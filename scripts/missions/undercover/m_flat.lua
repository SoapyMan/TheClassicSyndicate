
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- World Parameters --------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

world:SetLevelName("flatsclassic")
world:SetEnvironmentName("day_clear")
SetMusicName("")

MISSION.LoadingScreen = "resources/loadingscreen_mcd.res"

MISSION.cutCameras = {
	{
		{ Vector3D.new(-57.50, 0.50, 33), Vector3D.new(6, 360, 20), -5, 50 },
		{ Vector3D.new(-59.50, 1.40, 38.0), Vector3D.new(10 ,372, -5), 4, 50 },	
	},
	{
		{ Vector3D.new(-59.50, 1.40, 38.0), Vector3D.new(10 ,372, -5), 0, 50 },	
		{ Vector3D.new(-59.50, 1.40, 38.0), Vector3D.new(10 ,372, -5), 60, 50 },	
	}
}

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Pre-Init Scenery --------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.SpawnSceneryCars()						-- Spawning NPC cars for scenery, pre-init
	
	local car2 = gameses:CreateCar("NPC_mcd_traffic01", CAR_TYPE_NORMAL)
	car2:SetOrigin( Vector3D.new(-62.8,0.77,44.5) )
	car2:SetAngles( Vector3D.new(180,0,180) )
	car2:Enable(false)
	car2:Spawn()
	car2:SetColorScheme(4)

	local car3 = gameses:CreateCar(Miami_GetPlayerCarName(), CAR_TYPE_NORMAL)
	car3:SetOrigin( Vector3D.new(-60.5,0.77,44.5) )
	car3:SetAngles( Vector3D.new(180,0,180) )
	car3:Enable(false)
	car3:Spawn()
	car3:SetColorScheme(1)
	
	gameses:SetPlayerCar(car3)
	car3:Lock(true)
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Mission Init ------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

MISSION.Init = function()									-- Preparing Introduction
	MISSION.Data = {
		targetPosition = Vector3D.new(-54,0.70,69),			-- Targets Positions
		target2Position = Vector3D.new(1719,0.70,-603),
		--DEVTESTtargetPosition = Vector3D.new(-119,0.70,-1145),		
		--DEVTESTtarget2Position = Vector3D.new(-119,0.70,-1175),
	}
	
	MISSION.Settings.EnableCops = false						-- Cops are disabled
	MISSION.Settings.EnableTraffic = false

	MISSION.SpawnSceneryCars()

	-- precache sounds
	sounds:Precache( "d3.citynoise" )
	sounds:Precache( "wind.msg01" )

	gameHUD:Enable(false)								-- HUD disabled
	gameHUD:FadeIn(true, 0.60)							-- Screen Fade-In (Duration)

	missionmanager:ScheduleEvent( function() 
		-- first signall ladder about completion
		-- for retrieving next mission
		missionladder:OnMissionCompleted()
		
		sounds:Emit( EmitParams.new("wind.msg01"), -1 )
		sounds:Emit( EmitParams.new("d3.citynoise", Vector3D.new(-88,0.77,-1143)), -1 )
		
		local messageId = missionladder:GetCurrentMission().message
		local message = MISSION.MessageList[messageId]

		-- set the message
		MISSION.MessageScript = message.script
		MISSION.MessageLength = message.length
		MISSION.MessageDelay = message.delay
		MISSION.AnsweringMachinePosition = if_then_else(message.flatId ~= nil, MISSION.AnsweringMachines[message.flatId], MISSION.AnsweringMachines[1])
		
		world:SetEnvironmentName(message.environment or "day_clear")
		world:InitEnvironment()
		
		-- re-signal
		gameses:SignalMissionStatus( MIS_STATUS_SUCCESS, MISSION.MessageLength or 10 )

		sounds:Precache( MISSION.MessageScript )
	end, 0)

	MISSION.SetupFlybyCutscene()	-- Starting Introduction FlyBy Cutscene 
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- FlyBy Cutscenes ---------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.SetupFlybyCutscene()

	missionmanager:ScheduleEvent( function()
		local emitParams = EmitParams.new(MISSION.MessageScript, MISSION.AnsweringMachinePosition)

		sounds:Emit( emitParams )
	end, MISSION.MessageDelay or 1)

	local playerCar = gameses:GetPlayerCar()

	cmn_cutcam.Start(MISSION.cutCameras, nil, 1000) -- make wait forever
end