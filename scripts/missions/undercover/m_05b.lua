----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- World Parameters --------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

world:SetLevelName("miamiclassic")
world:SetEnvironmentName("day_clear")
SetMusicName("la_day")

MISSION.LoadingScreen = "resources/loadingscreen_mcd.res"

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Pre-Init Scenery --------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.SpawnSceneryCars()						-- Spawning NPC cars for scenery, pre-init
	local car1 = gameses:CreateCar("NPC_mcd_traffic01", CAR_TYPE_NORMAL)
	car1:SetOrigin( Vector3D.new(1577,0.7,-230) )
	car1:SetAngles( Vector3D.new(180,90,180) )			-- Scenery items coords
	car1:Enable(false)
	car1:Spawn()
	car1:SetColorScheme(5)
	
	local car2 = gameses:CreateCar("NPC_mcd_traffic01", CAR_TYPE_NORMAL)
	car2:SetOrigin( Vector3D.new(1577,0.7,-223) )
	car2:SetAngles( Vector3D.new(180,-90,180) )
	car2:Enable(false)
	car2:Spawn()
	car2:SetColorScheme(3)

	local car3 = gameses:CreateCar("NPC_mcd_traffic01", CAR_TYPE_NORMAL)
	car3:SetOrigin( Vector3D.new(1577,0.7,-239) )
	car3:SetAngles( Vector3D.new(180,-90,180) )
	car3:Enable(false)
	car3:Spawn()
	car3:SetColorScheme(2)
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Mission Init ------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

MISSION.Init = function()									-- Preparing Introduction
	MISSION.Data = {		-- Targets Positions
		targetPosition = Vector3D.new(224,0.7,-387),
	}
	
	MISSION.Settings.EnableCops = true						-- Cops are disabled

	--MISSION.SpawnSceneryCars()

	local playerCar = gameses:CreateCar(Miami_GetPlayerCarName(), CAR_TYPE_NORMAL)	-- Create player car
	
	MISSION.playerCar = playerCar	-- Define spawned car above as player car for mission
	
	playerCar:SetMaxDamage(12.0)
	--playerCar:SetOrigin( Vector3D.new(1577,0.7,-235) )						--Player car properties
	--DEVTESTplayerCar:SetOrigin( Vector3D.new(-119,0.70,-1115) )	
	--playerCar:SetAngles( Vector3D.new(180,-90,180) )
	playerCar:Spawn()
	playerCar:SetColorScheme( 1 )

	local restoreData = RestoreMissionCompletionData("mcd05a_playerCar")
	
	if restoreData ~= nil then	
		playerCar:SetOrigin(toVector(restoreData.position))
		playerCar:SetAngles(toVector(restoreData.angles))
		playerCar:SetDamage(restoreData.damage)
		playerCar:SetBodyDamage(restoreData.bodyDamage)
		--playerCar:SetFelony(restoreData.felony)
	end

	-- For the load time, set player car
	gameses:SetPlayerCar( playerCar )
	
	playerCar:Lock(true)

	gameHUD:Enable(false)								-- HUD disabled
	gameHUD:FadeIn(false, 0.5)								-- Screen Fade-In (Duration)
	gameHUD:ShowScreenMessage("CASE FOR A KEY (continued..)", 3.5)				-- Classic title text (Duration)
	--gameHUD:ShowAlert("THE BANK JOB", 3.5, HUD_ALERT_NORMAL)		-- Syndicate title message (Duration)

	MISSION.StartPause()	-- Starting Introduction FlyBy Cutscene 
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Phase1 Start ------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.Phase1Start()
	
	local playerCar = MISSION.playerCar		-- Define player car for current phase
	
	SetMusicState(MUSIC_STATE_PURSUIT)

	MISSION.Settings.EnableCops = true
	MISSION.Settings.StopCops = true
	MISSION.Settings.StopCopsRadius = 300
	MISSION.Settings.StopCopsPosition = MISSION.Data.targetPosition
	
	gameHUD:Enable(true)
	playerCar:Lock(false)

	MISSION.finalTarget = 1
	
	MISSION.targetHandle = gameHUD:AddMapTargetPoint(MISSION.Data.targetPosition)

	-- Here we start
	missionmanager:SetRefreshFunc( MISSION.Phase1Update )

	gameHUD:ShowScreenMessage("Make the exchange.", 3.5)
	
	missionmanager:EnableTimeout( true, 95 ) -- Enable, time
end

----------------------------------------------------------------------------------------------
-- Phase1 Update -----------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

MISSION.Phase1Update = function( delta )

	local playerCar = MISSION.playerCar		-- Define player car for current phase

	local distToTarget = length(playerCar:GetOrigin() - MISSION.Data.targetPosition)
	
	if MISSION.finalTarget then
	
		if distToTarget < 50 then	-- Cops are disabled when player enters % meters objective radius
			
			if distToTarget < 50 then	-- If player enters % meters radius while pursued, then..
				if playerCar:GetPursuedCount() > 0 then
					gameHUD:ShowScreenMessage("#LOSE_TAIL_MESSAGE", 1.5)	--.. Lost tail message on screen
				elseif distToTarget < 5 then	-- If player enters % meter objective radius, then..
					
					MISSION.OnCompleted()		-- ..Mission completed
				end
			end
		end
	end
	
	return MISSION.UpdateAll(delta)
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Phases Mission Mechanics ------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.OnDone()						-- Marker disappears after reached by player
	local playerCar = MISSION.playerCar
	
	gameHUD:RemoveTrackingObject(MISSION.targetHandle)

	playerCar:Lock(true)						-- Car is locked after reaching marker
	
	return true
end

function MISSION.OnCompleted()					-- Mission completed after all objectives are done

	local playerCar = MISSION.playerCar

	MISSION.OnDone()
	
	missionmanager:SetRefreshFunc( function() 
		return false 
	end ) 
	
	-- when game gets paused after completion it will store our car position
	gameses:SignalMissionStatus( MIS_STATUS_SUCCESS, 2.5, function()
		-- setup mission completion data
		StoreMissionCompletionData("mcd05b_playerCar", {
			position = playerCar:GetOrigin(),
			angles = playerCar:GetAngles(),
			damage = playerCar:GetDamage(),
			bodyDamage = playerCar:GetBodyDamage(),
			felony = playerCar:GetFelony()
		})
	end)
	
end

function MISSION.StartPause()						-- Marker disappears after reached by player
	local playerCar = MISSION.playerCar

	playerCar:Lock(true)						-- Car is locked after reaching marker
	
	gameHUD:Enable(true)
	
	missionmanager:ScheduleEvent( MISSION.Phase1Start, 2 ) 

	return true
end

MISSION.UpdateAll = function(delta)

	local camera = world:GetView()
	
	local playerCar = MISSION.playerCar		-- Define player car for current phase
	
	UpdateCops( playerCar, delta )

	-- Check player vehicle is wrecked
	if CheckVehicleIsWrecked( playerCar, MISSION.Data, delta ) then		-- If player car is wrecked, then..
		gameHUD:ShowAlert("#WRECKED_VEHICLE_MESSAGE", 3.5, HUD_ALERT_DANGER)	--.. Display wrecked message
		
		MISSION.OnDone()	-- Game Over
		
		missionmanager:SetRefreshFunc( function() 
			return false 
		end ) 

		gameses:SignalMissionStatus( MIS_STATUS_FAILED, 4.0 )
		return false
	end
	
	-- Check player's time is out
	if missionmanager:IsTimedOut() then		-- If player time is out, then..

		--gameHUD:ShowAlert("#TIME_UP_MESSAGE", 3.5, HUD_ALERT_DANGER)	--.. Display timeout message
		gameHUD:ShowScreenMessage("Too late. Mission is failed.", 3.5)	--.. Display classic timeout text

		MISSION.OnDone()	-- Game Over
		
		missionmanager:SetRefreshFunc( function() 
			return false 
		end ) 
		
		gameses:SignalMissionStatus( MIS_STATUS_FAILED, 4.0 )
		return false
	end
	
	return true
end