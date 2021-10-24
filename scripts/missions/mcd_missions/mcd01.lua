----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- World Parameters --------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

world:SetLevelName("mattimiamiclassic")
world:SetEnvironmentName("day_clear")
SetMusicName("miami_night")

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
		targetPosition = Vector3D.new(-54,0.70,69),			-- Targets Positions
		target2Position = Vector3D.new(1719,0.70,-603),
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

	sounds:Precache( "wind.mcd01" )
	sounds:Precache( "bank.jobalarm" )
	sounds:Precache( "goon.go" )
	sounds:Precache( "goon.losetail" )

	-- For the load time, set player car
	gameses:SetPlayerCar( playerCar )
	
	playerCar:Lock(true)

	gameHUD:Enable(false)								-- HUD disabled
	gameHUD:FadeIn(false, 2.5)								-- Screen Fade-In (Duration)
	gameHUD:ShowScreenMessage("THE BANK JOB", 3.5)				-- Classic title text (Duration)
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

	local cutCameras = {
		{
			{ vec3(-90, 6, -1128), vec3(-15.88,26.68, 0), 0, 50 },
			{ vec3(-90, 4.3, -1128), vec3(-15.88,26.68, 0), 2, 50 },
		},
		{
			{ vec3(-93.16,3.83,-1141.87), vec3(5.36, 64.56, 0), -1, 40 },
			{ vec3(-92.70,3.83,-1141.15), vec3(5.36, 57.56, 0), 1.8, 40 },
			{ vec3(-92.70,3.83,-1141.15), vec3(32.36, 240.56, 0), 2, 40 },
		},
		{
			{ vec3(-90.80,0.98,-1139.65), vec3(-22.56, 140.44, 0), -0.7, 60 },
			{ vec3(-90.80,0.98,-1139.65), vec3(3.56, 234.44, 0), -0.5, 60 },
			{ vec3(-89.53,0.98,-1138.33), vec3(3.56, 206.68, 0), 2, 60 },
			{ vec3(-88.00,2.11,-1136.50), vec3(0.0, 180.02, 0), 2.2, 60 },
			{ vec3(-88.00,2.11,-1136.50), vec3(0.0, 180.02, 0), 2.6, 60 },
			{ vec3(-88.00,2.11,-1136.50), vec3(0.0, 180.02, 0), 3.0, 60 },
			{ vec3(-88.00,2.11,-1136.50), vec3(0.0, 180.02, 0), 3.5, 60 },
		}
	}
		
	McdCutsceneCamera.Start(cutCameras, MISSION.StartPause, 1)
	
	-- apply sound effects
	missionmanager:ScheduleEvent( function() 
		sounds:Emit2D( EmitParams.new("wind.mcd01"), -1 )
	end, 3.8)

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
	
	MISSION.Settings.EnableCops = false
	
	gameHUD:Enable(true)
	playerCar:Lock(false)
	
	MISSION.targetHandle = gameHUD:AddMapTargetPoint(MISSION.Data.targetPosition)

	-- Here we start
	missionmanager:SetRefreshFunc( MISSION.Phase1Update )

	gameHUD:ShowScreenMessage("Get to the bank.", 3.5)
	
	missionmanager:EnableTimeout( true, 70 ) -- Enable, time
end

----------------------------------------------------------------------------------------------
-- Phase1 Update -----------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

MISSION.Phase1Update = function( delta )

	local playerCar = MISSION.playerCar		-- Define player car for current phase

	local remainingTime = missionmanager:GetMissionTime()
	local distToTarget = length(playerCar:GetOrigin() - MISSION.Data.targetPosition)
	local playerSpeed = playerCar:GetSpeed()		-- Check for Player speed

	if distToTarget < 15.0 then						-- If player enters % meters radius, then..
	
		if remainingTime > 15 then					-- ..If timer is above 15 seconds, then..
			gameHUD:ShowScreenMessage("Too early. Come back later.", 1.5)	-- .. Too early message on screen
			playerCar:SetFelony(playerCar:GetFelony() + 0.1 * delta) -- 10 percent per second
		elseif playerSpeed < 60 then				-- **If player speed is higher than %, then ..

			if distToTarget < 4.0 then

				if remainingTime < 15 then
			
				gameHUD:RemoveTrackingObject(MISSION.targetHandle)		-- Remove marker
				
				playerCar:Lock(true)				-- Player car is locked upon reaching marker (for cutscene)

				missionmanager:EnableTimeout( false, 80 )	-- Disable countdown timer
				
				missionmanager:SetRefreshFunc( MISSION.BankPrePause )	-- Going to transition step immediately
				end
			end
		else
			gameHUD:ShowScreenMessage("Slow down!", 1.0) -- .. Slow down message on screen**
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
	
	gameses:SignalMissionStatus( MIS_STATUS_SUCCESS, 4.0 )

	-- Trigger MissionSuccess UI
	--gameHUD:ShowAlert("#MENU_GAME_TITLE_MISSION_SUCCESS", 3.5, HUD_ALERT_SUCCESS)		
	
	gameHUD:ShowScreenMessage("Well done!", 3.5)
end

----------------------------------------------------------------------------------------------
-- Bank PrePause -----------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.BankPrePause()

	local playerCar = MISSION.playerCar

	local ep = EmitParams.new( "bank.jobalarm", vec3(-53, 1.0, 58) )
	local sound = sounds:CreateController( ep )
	sound:Play()

	gameHUD:Enable(false)
	playerCar:Lock(true)

	missionmanager:SetRefreshFunc( function() 
		return false 
	end ) 

	missionmanager:ScheduleEvent( MISSION.BankPause, 2 )	-- Going into Phase2Start after 2 seconds
end

----------------------------------------------------------------------------------------------
-- Bank Pause --------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.BankPause()				-- Transition between Phase1Update and Phase2Start

	local playerCar = MISSION.playerCar

	playerCar:SetOrigin( Vector3D.new(-53,0.7,68) )	
	playerCar:SetAngles( Vector3D.new(180,-90,-180) )

	local ped1 = gameses:CreatePedestrian("models/characters/mcd_pedrobber.egf", -1)
	ped1:SetOrigin(vec3(-54.02,0.7,60.87))
	ped1:Spawn()
	ped1:SetBodyGroups(1 + 2)		-- 2 to make briefcase
	
	-- two ways of initialize array
	local walkingPeds = {
		--ped1,
		--ped2
	}
	
	table.insert(walkingPeds, ped1)
	
	for i in range(1,2) do 
		missionmanager:ScheduleEvent( function() 
			local ped = gameses:CreatePedestrian("models/characters/mcd_pedrobber.egf", -1)
			ped:SetOrigin(vec3(-54.02,0.7,60.87))
			ped:Spawn()
			ped:SetBodyGroups(1)		-- 2 to make briefcase
			
			table.insert(walkingPeds, ped)
		end, 0.4 * i )
	end
	
	missionmanager:SetPluginRefreshFunc( "pedswalk", function()
	
		local run = true
		
		for i,ped in ipairs(walkingPeds) do 
			if PedWalkToTarget(ped, gameses:GetPlayerCar():GetOrigin(), run) < 1.2 then
				
				-- remove pedestrian from world and table
				ped:Remove()
				table.remove(walkingPeds, i)
			end
			
			-- no more pedestrians to walk?
			if #walkingPeds == 0 then
				missionmanager:SetPluginRefreshFunc( "pedswalk", nil)
			end
		end

	end)

	local cutCameras = {
		{
			{ Vector3D.new(-62.37,1.80,61.60), Vector3D.new(4.48, 277.43, 0), 0, 40 },
			{ Vector3D.new(-62.25,1.80,63.53), Vector3D.new(3.76, 300.03, 0), 2, 40 },
		}
	}
	
	McdCutsceneCamera.Start(cutCameras, MISSION.Phase2Start, 1)
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
-- Phase2 Start ------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

function MISSION.Phase2Start()
	local playerCar = MISSION.playerCar			-- Define what the player car is for this phase

	local felony = playerCar:GetFelony()
	if felony < 0.5 then
	  felony = 0.5
	end
	playerCar:SetFelony(felony)

	playerCar:Lock(false)						-- Unlock player's car after robbery (MISSION.BankPause)
	
	MISSION.Settings.EnableCops = true			-- Enable cops
	MISSION.Settings.MaxCops = 1
	
	sounds:Emit2D( EmitParams.new("goon.go"), -1 )

	SetMusicState(MUSIC_STATE_PURSUIT)			-- Force PURSUIT Music

	gameHUD:Enable(true)						-- HUD enabled
		
	missionmanager:EnableTimeout(false, 0)		-- Disable countdown timer
	missionmanager:ShowTime( true )				-- Enable countup timer
	
	MISSION.safeHouseTarget = MISSION.Data.target2Position
	MISSION.targetHandle = gameHUD:AddMapTargetPoint(MISSION.safeHouseTarget)
	MISSION.safeHouseCops = false
	MISSION.finalTarget = true
	
	-- Show objective message (Duration)
	gameHUD:ShowScreenMessage("Get to the lock up.", 3.5)
	
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
			sounds:Emit2D( EmitParams.new("goon.losetail"), -1 )
		end
	end
	
	if MISSION.finalTarget then
	
		if distToTarget < 300 then	-- Cops are disabled when player enters % meters objective radius
			MISSION.Settings.EnableCops = false
			
			if distToTarget < 50 then	-- If player enters % meters radius while pursued, then..
				if playerCar:GetPursuedCount() > 0 then
					gameHUD:ShowScreenMessage("#LOSE_TAIL_MESSAGE", 1.5)	--.. Lost tail message on screen
					sounds:Emit2D( EmitParams.new("goon.losetail"), -1 )
				elseif distToTarget < 5 then	-- If player enters % meter objective radius, then..
					
					MISSION.OnCompleted()		-- ..Mission completed
				end
			end
		end
	end
	
	return MISSION.UpdateAll(delta)
end