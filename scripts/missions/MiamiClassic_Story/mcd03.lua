----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- World Parameters --------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

world:SetLevelName("miamiclassic")
world:SetEnvironmentName("night_clear")
SetMusicName("frisco_night")

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

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Mission Init ------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

MISSION.Init = function()									-- Preparing Introduction
	MISSION.Data = {
		targetPosition = Vector3D.new(-229,0.70,-189),			-- Targets Positions
		target2Position = Vector3D.new(-1818,0.80,-447),
		--DEVTESTtargetPosition = Vector3D.new(-119,0.70,-1145),		
		--DEVTESTtarget2Position = Vector3D.new(-119,0.70,-1175),
	}
	
	MISSION.Settings.EnableCops = false						-- Cops are disabled

	MISSION.SpawnSceneryCars()

	local playerCar = gameses:CreateCar(McdGetPlayerCarName(), CAR_TYPE_NORMAL)	-- Create player car
	
	MISSION.playerCar = playerCar	-- Define spawned car above as player car for mission
	
	playerCar:SetMaxDamage(12.0)
	playerCar:SetOrigin( Vector3D.new(-88,0.77,-1143) )						--Player car properties
	--DEVTESTplayerCar:SetOrigin( Vector3D.new(-119,0.70,-1115) )	
	playerCar:SetAngles( Vector3D.new(180,0,180) )
	playerCar:Spawn()
	playerCar:SetColorScheme( 1 )

	sounds:Precache( "car.lightswitch" )

	sounds:Precache( "wind.mcd03a" )
	sounds:Precache( "wind.mcd03b" )

	sounds:Precache( "ticco.start" )
	sounds:Precache( "ticco.losetail" )
	sounds:Precache( "ticco.pewpews" )
	sounds:Precache( "ticco.end" )

	-- For the load time, set player car
	gameses:SetPlayerCar( playerCar )
	
	playerCar:Lock(true)

	gameHUD:Enable(false)								-- HUD disabled
	gameHUD:FadeIn(false, 2.5)								-- Screen Fade-In (Duration)
	gameHUD:ShowScreenMessage("TICCO'S RIDE", 3.5)				-- Classic title text (Duration)
	--gameHUD:ShowAlert("THE BANK JOB", 3.5, HUD_ALERT_NORMAL)		-- Syndicate title message (Duration)

	MISSION.SetupFlybyCutscene()	-- Starting Introduction FlyBy Cutscene 
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- FlyBy Cutscenes ---------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.SetupFlybyCutscene()

	local playerCar = MISSION.playerCar		-- Define player car for current phase

	missionmanager:ScheduleEvent( function() 
		sounds:Emit( EmitParams.new("wind.mcd03a"), -1 )
	end, 0.1);

	missionmanager:ScheduleEvent( function() 
		sounds:Emit( EmitParams.new("wind.mcd03b"), 0 )
	end, 1.72);

	missionmanager:ScheduleEvent( function() 
		sounds:Emit( EmitParams.new("car.lightswitch"), -1 )
	end, 3.5);

	missionmanager:ScheduleEvent( function() 
		playerCar:SetLight(CAR_LIGHT_LOWBEAMS, false);
	end, 1);

	missionmanager:ScheduleEvent( function() 
		playerCar:SetLight(CAR_LIGHT_LOWBEAMS, true);
	end, 3.5)

	local cutCameras = {
		{
			{ Vector3D.new(-118, 2, -1022), Vector3D.new(0,0,0), 0, 60 },
			{ Vector3D.new(-118, 2, -1091), Vector3D.new(0,0,0), 1.8, 60 },
			{ Vector3D.new(-118, 2, -1091), Vector3D.new(140,0,0), 2.0, 60 },
		},
		{
			{ Vector3D.new(-86,5,-1139), Vector3D.new(0, 158.25, 0), -2, 60 },
			{ Vector3D.new(-86,5,-1139), Vector3D.new(45, 158.25, 0), 0.2, 60 },
			{ Vector3D.new(-86,4,-1139), Vector3D.new(32, 157.75, 0), 1, 60 },
			{ Vector3D.new(-86,2.69,-1139), Vector3D.new(20, 158, 0), 2, 60 },
			{ Vector3D.new(-88,2.09,-1136), Vector3D.new(0, 180.02, 0), 2.5, 60 },
			{ Vector3D.new(-88,2.09,-1136.50), Vector3D.new(0, 180.02, 0), 2.8, 60 },
			{ Vector3D.new(-88,2.09,-1136.50), Vector3D.new(0, 180.02, 0), 3.1, 60 },
			{ Vector3D.new(-88,2.09,-1136.50), Vector3D.new(0, 180.02, 0), 3.3, 60 },
			{ Vector3D.new(-88,2.09,-1136.50), Vector3D.new(0, 180.02, 0), 4.0, 60 },
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

	missionmanager:ScheduleEvent( MISSION.Phase1Start, 1 )	-- Going into Phase2Start after 2 seconds
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Phase1 Start ------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.Phase1Start()
	
	local playerCar = MISSION.playerCar		-- Define player car for current phase
	
	MISSION.Settings.EnableCops = true
	
	gameHUD:Enable(true)
	playerCar:Lock(false)
	
	MISSION.targetHandle = gameHUD:AddMapTargetPoint(MISSION.Data.targetPosition)

	-- Here we start
	missionmanager:SetRefreshFunc( MISSION.Phase1Update )

	gameHUD:ShowScreenMessage("Pick up Ticco.", 3.5)
	
	missionmanager:EnableTimeout( true, 80 ) -- Enable, time
end

----------------------------------------------------------------------------------------------
-- Phase1 Update -----------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

MISSION.Phase1Update = function( delta )

	local playerCar = MISSION.playerCar		-- Define player car for current phase

	local distToTarget = length(playerCar:GetOrigin() - MISSION.Data.targetPosition)
	local playerSpeed = playerCar:GetSpeed()		-- Check for Player speed

	if distToTarget < 30.0 then						-- *If player enters % meters radius while pursued, then..
	
		if playerCar:GetPursuedCount() > 0 then
			gameHUD:ShowScreenMessage("#LOSE_TAIL_MESSAGE", 1.5)	-- .. Lose tail message on screen*
		elseif playerSpeed < 60 then				-- **If player speed is higher than %, then ..

			if distToTarget < 4.0 then
			
				gameHUD:RemoveTrackingObject(MISSION.targetHandle)		-- Remove marker
				
				playerCar:Lock(true)				-- Player car is locked upon reaching marker (for cutscene)

				missionmanager:EnableTimeout( false, 80 )	-- Disable countdown timer
				
				missionmanager:ScheduleEvent( MISSION.TiccoPause, 0.0 )	-- Going to transition step immediately
																		-- (See MISSION.BankPause below)
				missionmanager:SetRefreshFunc( function() 
					return false 
				end ) 
			
				return false
			end
		else
			gameHUD:ShowScreenMessage("#SLOW_DOWN_MESSAGE", 1.0) -- .. Slow down message on screen**
		end
	end
	
	return MISSION.UpdateAll(delta)
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Phase1 Mission Mechanics ------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.OnDone()						-- Marker disappears after reached by player
	local playerCar = MISSION.playerCar
	
	gameHUD:RemoveTrackingObject(MISSION.targetHandle)

	playerCar:Lock(true)						-- Car is locked after reaching marker
	
	return true
end

function MISSION.OnCompleted()					-- Mission completed after all objectives are done
	MISSION.OnDone()
	
	missionmanager:SetRefreshFunc( function() 
		return false 
	end ) 
	
	gameses:SignalMissionStatus( MIS_STATUS_SUCCESS, 3.3 )

	-- Trigger MissionSuccess UI
	--gameHUD:ShowAlert("#MENU_GAME_TITLE_MISSION_SUCCESS", 3.5, HUD_ALERT_SUCCESS)		
	
	--gameHUD:ShowScreenMessage("Well done!", 3.5)
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.TiccoPause()				-- Transition between Phase1Update and Phase2Start
    local pedestrian = gameses:CreatePedestrian("models/characters/mcd_ticco.egf", -1)
    pedestrian:SetOrigin(vec3(-217.17,0.7,-182.11))
    pedestrian:Spawn()
    pedestrian:SetBodyGroups(1)        -- 2 to make briefcase
    
    missionmanager:SetPluginRefreshFunc( "pedswalk", function()
        local run = true
        if PedWalkToTarget(pedestrian, gameses:GetPlayerCar():GetOrigin(), run) < 1.2 then
			missionmanager:SetPluginRefreshFunc( "pedswalk", nil)
			pedestrian:Remove()
        end
    end)

	missionmanager:SetRefreshFunc( function() 
		return false 
	end ) 

	missionmanager:ScheduleEvent( MISSION.Phase2Start, 2.5 )	-- Going into Phase2Start after 2 seconds
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.TiccoPewPewPREPAUSE()

	local playerCar = MISSION.playerCar

	gameHUD:Enable(false)
	playerCar:Lock(true)

	gameHUD:ShowScreenMessage("Well done!", 3.5)

	missionmanager:SetRefreshFunc( function() 
		return false 
	end ) 

	missionmanager:ScheduleEvent( MISSION.TiccoPewPewPRECAM, 1.5 )	-- Going into Phase2Start after 2 seconds
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.TiccoPewPewPRECAM()				-- Transition between Phase1Update and Phase2Start

	local playerCar = MISSION.playerCar		-- Define player car for current phase

	playerCar:SetOrigin( Vector3D.new(-1820,0.7,-436) )						--Player car properties
	playerCar:SetAngles( Vector3D.new(180,180,180) )

	-- Setup cameras
	cameraAnimator:SetScripted(true)

	local cutCameras = {
		{
			{ Vector3D.new(-1821, 2, -462), Vector3D.new(-2, 320, 0), 0, 40 },
			{ Vector3D.new(-1824, 3, -440), Vector3D.new(2.5, 289, 0), 5, 40 },
		}
	}
	McdCutsceneCamera.Start(cutCameras, MISSION.TiccoPewPew, 0)

	missionmanager:ScheduleEvent( function() 
		sounds:Emit( EmitParams.new("ticco.pewpews"), -1 )
	end, 1.0);

end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.TiccoPewPew()				-- Transition between Phase1Update and Phase2Start

    local pedestrian1 = gameses:CreatePedestrian("models/characters/mcd_ticco.egf", -1)
    pedestrian1:SetOrigin(vec3(-1806, 0.7, -433))
    pedestrian1:Spawn()
    pedestrian1:SetBodyGroups(1)        -- 2 to make briefcase
    
    missionmanager:SetPluginRefreshFunc( "pedswalk2", function()
        local run = true
        if PedWalkToTarget(pedestrian1, gameses:GetPlayerCar():GetOrigin(), run) < 1.2 then
			missionmanager:SetPluginRefreshFunc( "pedswalk2", nil)
			pedestrian1:Remove()
        end
	end)
	
	local playerCar = MISSION.playerCar		-- Define player car for current phase

	local cutCameras = {
		{
			{ Vector3D.new(-1822, 1, -425), Vector3D.new(0, 260, 0), 0, 40 },
			{ Vector3D.new(-1823, 1, -432), Vector3D.new(2, 220, 0), 3, 40 },
			{ Vector3D.new(-1823, 1, -432), Vector3D.new(2, 220, 0), 3.5, 40 },
		}
	}
	McdCutsceneCamera.Start(cutCameras, MISSION.PostTiccoPewPew, 1)

end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.PostTiccoPewPew()
	MISSION.OnCompleted()

	local playerCar = MISSION.playerCar

	gameHUD:Enable(true)
	playerCar:Lock(true)

	missionmanager:ScheduleEvent( function() 
		sounds:Emit( EmitParams.new("ticco.end"), -1 )
	end, 0);

	missionmanager:SetRefreshFunc( function() 
		return false 
	end ) 
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Phase2 Start ------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.Phase2Start()
	local playerCar = MISSION.playerCar			-- Define what the player car is for this phase
	playerCar:Lock(false)						-- Unlock player's car after robbery (MISSION.BankPause)
	
	MISSION.Settings.EnableCops = true			-- Enable cops
	
	sounds:Emit( EmitParams.new("ticco.start"), -1 )

	gameHUD:Enable(true)						-- HUD enabled
	
	missionmanager:EnableTimeout(false, 0)		-- Disable countdown timer
	missionmanager:ShowTime( true )				-- Enable countup timer
	
	MISSION.safeHouseTarget = MISSION.Data.target2Position
	MISSION.targetHandle = gameHUD:AddMapTargetPoint(MISSION.safeHouseTarget)
	MISSION.safeHouseCops = false
	MISSION.finalTarget = true
	
	-- Show objective message (Duration)
	gameHUD:ShowScreenMessage("Take him where he wants to go.", 3.5)
	
	missionmanager:SetRefreshFunc( MISSION.Phase2Update )
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

----------------------------------------------------------------------------------------------
-- Phase2 Update -----------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

MISSION.Phase2Update = function( delta )

	local playerCar = MISSION.playerCar		-- Define player car for current phase

	local distToTarget = length(playerCar:GetOrigin() - MISSION.safeHouseTarget)

	  -- tell player every 20 seconds to lose tail
	if playerCar:GetPursuedCount() > 0 then
		if math.modf(math.fmod(missionmanager:GetMissionTime(), 20)) == 0 then
			sounds:Emit( EmitParams.new("ticco.losetail"), -1 )
		end
	end
	
	if MISSION.finalTarget then
	
		if distToTarget < 300 then	-- Cops are disabled when player enters % meters objective radius
			MISSION.Settings.EnableCops = false
			
			if distToTarget < 50 then	-- If player enters % meters radius while pursued, then..
				if playerCar:GetPursuedCount() > 0 then
					gameHUD:ShowScreenMessage("#LOSE_TAIL_MESSAGE", 1.5)	--.. Lost tail message on screen
				elseif distToTarget < 5 then	-- If player enters % meter objective radius, then..
					
					MISSION.TiccoPewPewPREPAUSE()		-- ..Mission completed
				end
			end
		end
	end
	
	return MISSION.UpdateAll(delta)
end