--//////////////////////////////////////////////////////////////////////////////////
--// Copyright � Inspiration Byte
--// 2009-2015
--//////////////////////////////////////////////////////////////////////////////////

--------------------------------------------------------------------------------
-- Cop test script
--------------------------------------------------------------------------------

world:SetLevelName("miamiclassic")
world:SetEnvironmentName("dusk_clear")
SetMusicName("la_day")

----------------------------------------------------------------------------------------------
-- Mission initialization
----------------------------------------------------------------------------------------------

MISSION.Init = function()

	MISSION.Data = {}
	
	-- adjust cops
	MISSION.Settings.EnableCops = true
	MISSION.Settings.EnableRoadBlock = false
	MISSION.Settings.CopAccelerationScale = 2.3
	MISSION.Settings.CopMaxSpeed = 1000;
	MISSION.Settings.MinCops = 10
	MISSION.Settings.MaxCops = 12
	MISSION.Settings.MaxCopDamage = 100000;
	
	
	-- car name		maxdamage	pos ang
	local playerCar = gameses:CreateCar("m_default_ios", CAR_TYPE_NORMAL)
	MISSION.playerCar = playerCar
	
	playerCar:SetOrigin( Vector3D.new(-1445, 0.70, -724) )
	playerCar:SetAngles( Vector3D.new(0, 0, 0) )

	playerCar:SetColorScheme(6)
	playerCar:Spawn()

	gameses:SetPlayerCar( playerCar )
	
	missionmanager:ShowTime( true ) -- enable time display
	
	gameHUD:ShowScreenMessage("#SURVIVAL_TITLE", 3.5)
	
	-- this is temporary to spawn cops
	MISSION.Settings.CopRespawnInterval = 0
	MISSION.Settings.CopWantedRespawnInterval2 = 0
	
	-- here we start
	missionmanager:SetRefreshFunc( function(dt)
	
		-- do first game update frame to spawn cops and adjust params
		ai:MakePursued( playerCar )
		playerCar:SetFelony(1.0)

	
		-- continue with standard update routine
		missionmanager:SetRefreshFunc(MISSION.Update)
		
		return false
	end	)
end

--------------------------------------------------------------------------------

function MISSION.OnFailed()
	gameses:SetLeadCar( MISSION.playerCar )
	MISSION.playerCar:Lock(true)
end

-- main mission update
function MISSION.Update( delta )

	local playerCar = MISSION.playerCar

	UpdateCops( playerCar, delta )
	ai:MakePursued( playerCar )

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
	
	return true
end