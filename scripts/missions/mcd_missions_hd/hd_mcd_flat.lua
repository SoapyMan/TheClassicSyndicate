
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- World Parameters --------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

world:SetLevelName("mattimiamiclassichd")
world:SetEnvironmentName("day_clear")
SetMusicName("")

MISSION.LoadingScreen = "resources/loadingscreen_mcd.res"

MISSION.cutCameras = {
	{
		{ Vector3D.new(-84, 0.50, -1154), Vector3D.new(-5, 30, 0), -2, 50 },
		{ Vector3D.new(-86, 1.60, -1150), Vector3D.new(16 ,26, 0), 4, 50 },	
	},
	{
		{ Vector3D.new(-86, 1.60, -1150), Vector3D.new(16 ,26, 0), 0, 50 },	
		{ Vector3D.new(-86, 1.60, -1150), Vector3D.new(16 ,26, 0), 60, 50 },	
	}
}

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Pre-Init Scenery --------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.SpawnSceneryCars()						-- Spawning NPC cars for scenery, pre-init
	local car1 = gameses:CreateCar("hd_toledosedan", CAR_TYPE_NORMAL)
	car1:SetOrigin( Vector3D.new(-85,0.77,-1143) )
	car1:SetAngles( Vector3D.new(180,0,180) )			-- Scenery items coords
	car1:Enable(false)
	car1:Spawn()
	car1:SetColorScheme(3)
	
	local car2 = gameses:CreateCar("hd_scimitar", CAR_TYPE_NORMAL)
	car2:SetOrigin( Vector3D.new(-91,0.77,-1143) )
	car2:SetAngles( Vector3D.new(180,0,180) )
	car2:Enable(false)
	car2:Spawn()
	car2:SetColorScheme(4)

	local car3 = gameses:CreateCar(McdHdGetPlayerCarName(), CAR_TYPE_NORMAL)
	car3:SetOrigin( Vector3D.new(-88,0.77,-1143) )
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
	gameHUD:FadeIn(true, 0.25)							-- Screen Fade-In (Duration)

	missionmanager:ScheduleEvent( function() 
		-- first signall ladder about completion
		-- for retrieving next mission
		missionladder:OnMissionCompleted()
		
		sounds:Emit2D( EmitParams.new("wind.msg01"), -1 )
		sounds:Emit( EmitParams.new("d3.citynoise", Vector3D.new(-88,0.77,-1143)), -1 )
		
		local nextMissionId = missionladder:GetNextMission().id
		local message = MISSION.MessageList[nextMissionId]

		-- set the message
		MISSION.MessageScript = message.script
		MISSION.MessageLength = message.length
		MISSION.MessageDelay = message.delay
		
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
		sounds:Emit2D( EmitParams.new(MISSION.MessageScript), -1 )
	end, MISSION.MessageDelay or 1)

	local playerCar = gameses:GetPlayerCar()

	McdCutsceneCamera.Start(MISSION.cutCameras, nil, 1000) -- make wait forever
end