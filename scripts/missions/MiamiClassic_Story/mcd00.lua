--------------------------------------------------------------------------------
-- Mission script for interview
--------------------------------------------------------------------------------
-- By Shurumov Ilya
-- 11 Mar 2015
--------------------------------------------------------------------------------

world:SetLevelName("parkingclassic")
world:SetEnvironmentName("night_clear")
SetMusicName("nyc_night")

MISSION.LoadingScreen = "resources/loadingscreen_mcd.res"

----------------------------------------------------------------------------------------------
-- Mission initialization
----------------------------------------------------------------------------------------------

MISSION.Hud = "resources/hud/mcd_pkd.res"

MISSION.RotationCheckThreshold = 80		-- degress
MISSION.RotationSphereRadius = 4.0
MISSION.RotationSpherePenaltyRadius = 8.0

MISSION.SetHudVisibleTask = function(itemName)
	local child = MISSION.uiTasksList:FindChild(itemName)
	
	if child ~= nil then
		child:Show()
	end
end

MISSION.Init = function()

	-- init hud
	MISSION.uiTasksList = gameHUD:FindChildElement("tasks")
	
	-- put globals here
	MISSION.Data = {
	
		carName = McdGetPlayerCarName(),
		startPos = Vector3D.new(100,0.70,-120),
		
		waitTime = 1.0,
		
		nextVoiceTime = 1.0,
		
		parkedCars = {
		
			-- cars by left side
			{ "NPC_mcd_traffic02", Vector3D.new(127,0.70,-158), Vector3D.new(122,-90,-122), 0 },
			{ "NPC_mcd_traffic01", Vector3D.new(127,0.70,-162), Vector3D.new(122,-90,-122), 1 },
			{ "NPC_mcd_traffic01", Vector3D.new(90,0.70,-117), 	Vector3D.new(146,-90,-146), 5 },
			{ "NPC_mcd_traffic02", Vector3D.new(110,0.70,-166), Vector3D.new(66,90,66), 2 },
			{ "NPC_mcd_traffic01", Vector3D.new(127,0.70,-124), Vector3D.new(122,-90,-122), 6 },
			{ "NPC_mcd_traffic02", Vector3D.new(127,0.70,-132), Vector3D.new(122,-90,-122), 3 },
			{ "NPC_mcd_traffic01", Vector3D.new(127,0.70,-144), Vector3D.new(122,-90,-122), 3 },
			
			-- cars by right side
			{ "NPC_mcd_traffic01", Vector3D.new(72,0.60,-171), Vector3D.new(72,90,72), 1 },
			{ "NPC_mcd_traffic02", Vector3D.new(72,0.60,-165), Vector3D.new(72,90,72), 4 },
			{ "NPC_mcd_traffic02", Vector3D.new(72,0.60,-161), Vector3D.new(72,90,72), 2 },
			{ "NPC_mcd_traffic01", Vector3D.new(72,0.60,-152), Vector3D.new(72,90,72), 6 },
			{ "NPC_mcd_traffic01", Vector3D.new(72,0.60,-146), Vector3D.new(72,90,72), 5 },
			{ "NPC_mcd_traffic02", Vector3D.new(72,0.60,-132), Vector3D.new(72,90,72), 3 },
			{ "NPC_mcd_traffic01", Vector3D.new(72,0.60,-128), Vector3D.new(72,90,72), 2 },
		},
		
		lapPoints = {
			Vector3D.new(86, 0.57, -112),
			Vector3D.new(80, 0.57, -118),

			Vector3D.new(80, 0.57, -166),
			Vector3D.new(86, 0.57, -172),
			
			Vector3D.new(114, 0.57, -172),
			Vector3D.new(119, 0.57, -166),

			Vector3D.new(119, 0.57, -119),
			Vector3D.new(114, 0.57, -112),
		},
		
		slalomPoints = {
			-- 1
			{
				Vector3D.new(86.36,0.5,-111),
				Vector3D.new(86.36,0.5,-126),
				Vector3D.new(86.36,0.5,-141),
				Vector3D.new(86.36,0.5,-156),
				Vector3D.new(86.36,0.5,-171),
			},
			-- 2
			{
				Vector3D.new(114.50,0.5,-111),
				Vector3D.new(114.50,0.5,-126),
				Vector3D.new(114.50,0.5,-141),
				Vector3D.new(114.50,0.5,-156),
				Vector3D.new(114.50,0.5,-171),
			}
		},
		
		drivenLapPoints = {},
		drivenSlalomPoints = {{},{}},
	
		slalomStartedAt = 0,
		slalomOddEven = 0,
		slalomLastPoint = 0,
		
		degreesRotate = 0,
		rotateStartDir = 0,
		rotateStartPos = nil,
		rotateTime = 0,
		
		turnoverVector = vec3_zero,
		
		collisionCount = 0,
		
		lapDone = false,
		slalomDone = false,
		speedDone = false,
		burnoutDone = false,
		brakeDone = false,
		handbrakeDone = false,
		rotate180 = false,
		rotate360 = false,
		rotateRev180 = false,
		
		wrecked = false,
		testDone = false,
	}

	-- car name		maxdamage	pos ang
	local playerCar = gameses:CreateCar( MISSION.Data.carName, CAR_TYPE_NORMAL )
	MISSION.playerCar = playerCar

	playerCar:SetMaxDamage( 1.0 )
	
	playerCar:SetOrigin( MISSION.Data.startPos )
	playerCar:SetAngles( Vector3D.new(0, 180, 0) )
	playerCar:SetColorScheme( 1 )
	
	playerCar:Set("OnCollide", MISSION.OnPlayerCollide)
	playerCar:Set("OnDeath", MISSION.OnDeath)

	playerCar:Spawn()
	
	playerCar:AlignToGround();
	
	sounds:Precache( "iview.fail" )
	sounds:Precache( "iview.damage" )
	sounds:Precache( "iview.scare" )
	sounds:Precache( "iview.failTime" )
	sounds:Precache( "iview.success" )
	
	gameses:SetPlayerCar( playerCar )

	MissionManager:ScheduleEvent( function() 
		playerCar:SetLight(CAR_LIGHT_LOWBEAMS, true)
	end, 0.0)
	
	-- spawn the cars
	for i,v in ipairs( MISSION.Data.parkedCars ) do
		local parkedCar = gameses:CreateCar( v[1], CAR_TYPE_NORMAL )

		parkedCar:SetOrigin( v[2] )
		parkedCar:SetAngles( v[3] )
		
		parkedCar:Enable(false)

		parkedCar:Spawn()
		parkedCar:AlignToGround();

		parkedCar:SetColorScheme( v[4] )
	end
	
	gameHUD:Enable(false)
	gameHUD:EnableInReplay(true)
	gameHUD:ShowScreenMessage("#IVIEW_TITLE_MESSAGE", 3.5)

	playerCar:Lock( true )
	
	-- here we start
	missionmanager:SetRefreshFunc( MISSION.WaitForStart )
	
	--gameses:LoadCarReplay(playerCar, "slalom3x")
end


--------------------------------------------------------------------------------

MISSION.WaitForStart = function( delta )

	local playerCar = MISSION.playerCar

	if MISSION.Data.waitTime > 0 then
		MISSION.Data.waitTime = MISSION.Data.waitTime - delta
		return false
	else
		missionmanager:SetRefreshFunc( MISSION.Update )
		playerCar:Lock( false )

		missionmanager:EnableTimeout( true, 60 ) -- enable, time
		
		gameHUD:Enable(true)
		-- gameses:BeginGame()
	end
	
	return true
end

--
-- Lap computations
--
MISSION.ProcessLapCondition = function()
	
	local missionData = MISSION.Data
	local playerCar = MISSION.playerCar

	if missionData.lapDone then
		return
	end
	
	local spd = playerCar:GetSpeed()

	local lastPoint = missionData.lapPoints[#missionData.lapPoints]
	
	local anyPointTouched = false
	
	local numPoints = 0
	
	for i,v in ipairs(missionData.lapPoints) do
		debugoverlay:Line3D(lastPoint, v, Vector4D.new(1,1,1,1), Vector4D.new(1,1,1,1), 0.0)

		local pr = lineProjection( lastPoint, v, playerCar:GetOrigin() )
		local posOnLine = lerp(lastPoint, v, pr)
		
		if length(posOnLine-playerCar:GetOrigin()) < 6 then
			debugoverlay:Box3D(posOnLine - Vector3D.new(0.2), posOnLine + Vector3D.new(0.2), Vector4D.new(1,1,0,1), 0.0)

			if length(v-playerCar:GetOrigin()) < 5 then
				table.insertUnique( missionData.drivenLapPoints, i )
				--Msg(string.format("driven lap point %d, total: %d\n", i, #missionData.drivenLapPoints))
			end
			
			anyPointTouched = true
		end
		
		numPoints = numPoints+1
		
		lastPoint = v -- set
	end

	if not anyPointTouched or spd < 10.0 then
		missionData.drivenLapPoints = {}
	else
		if #(missionData.drivenLapPoints) == numPoints then
			--gameHUD:ShowScreenMessage("Lap!", 1)

			missionData.drivenLapPoints = {}
			missionData.lapDone = true
			
			MISSION.SetHudVisibleTask("marker_lap")
			
			MISSION.DoReviewerVoice("iview.scare", 10.0)
		end
	end

end

MISSION.CheckSlalomPassing = function( num )
	local missionData = MISSION.Data
	local playerCar = MISSION.playerCar

	local points = missionData.slalomPoints[num]

	for i,v in ipairs(points) do
		if length(v - playerCar:GetOrigin()) < 6.5 then
			return i == 1 or i == #points -- should be only beginning or ending
		end
	end
	
	return false
end

MISSION.IsInArray = function(a, val)
	for i,v in ipairs(a) do
		if v == val then
			return true
		end
	end
	return false
end

--
-- Slalom computations
--
MISSION.ProcessSlalomCondition = function()

	local missionData = MISSION.Data
	local playerCar = MISSION.playerCar

	if missionData.slalomDone then
		return
	end

	local spd = playerCar:GetSpeed()
	

	if missionData.slalomStartedAt == 0 then

		if MISSION.CheckSlalomPassing( 1 ) then
			missionData.slalomStartedAt = 1
		elseif MISSION.CheckSlalomPassing( 2 ) then
			missionData.slalomStartedAt = 2
		end
		
		missionData.slalomLastPoint = 0
	end
	
	if missionData.slalomStartedAt == 0 then
		return
	else
		local oppositeSlalomCheck = if_then_else(missionData.slalomStartedAt == 1, 2, 1)
	
		if MISSION.CheckSlalomPassing( oppositeSlalomCheck ) then
			missionData.slalomStartedAt = 0
			missionData.drivenSlalomPoints = {{},{}}
			return
		end
	end

	local points = missionData.slalomPoints[ missionData.slalomStartedAt ]

	for i,v in ipairs(points) do
	
		local relativePos = v - playerCar:GetOrigin()

		if length(relativePos) < 6.5 then
		
			local oddEven = 1;
		
			if relativePos:get_x() < 0 then
				oddEven = 2;
			end
			
			if missionData.slalomLastPoint > 0 and math.abs(missionData.slalomLastPoint-i) > 1 then
				missionData.drivenSlalomPoints = {{},{}}
				missionData.slalomStartedAt = 0
				return
			end
			
			-- point is added
			if not MISSION.IsInArray(missionData.drivenSlalomPoints[oddEven], i) and
				((missionData.slalomOddEven ~= oddEven and
				missionData.slalomLastPoint ~= i) or i == 1 or i == #points) then
				
				missionData.slalomLastPoint = i
				missionData.slalomOddEven = oddEven

				if #missionData.drivenSlalomPoints[oddEven] == 0 and (i == 1 or i == #points) then
					if missionData.slalomOddEven == 2 then
						missionData.slalomOddEven = 1
					else
						missionData.slalomOddEven = 2
					end
				end
		
				table.insertUnique( missionData.drivenSlalomPoints[oddEven], i )
			end

		end
	end
	
	--if spd < 0.1 then
	--	missionData.drivenSlalomPoints = {{},{}}
	--	missionData.slalomStartedAt = 0
	--end
	
	if #(missionData.drivenSlalomPoints[1]) == #points and #(missionData.drivenSlalomPoints[2]) == #points then
		--gameHUD:ShowScreenMessage("Slalom!", 1.0)
		missionData.slalomDone = true
		MISSION.SetHudVisibleTask("marker_slalom")
		missionData.slalomLastPoint = 0
		
		MISSION.DoReviewerVoice("iview.scare", 10.0)
	end
end

MISSION.ProcessSpeedConditions = function()

	local missionData = MISSION.Data
	local playerCar = MISSION.playerCar

	local speed = playerCar:GetSpeed()
	local wheelsSpeed = math.abs(playerCar:GetSpeedWheels())

	local traction = playerCar:GetTractionSliding(true)

	if not missionData.burnoutDone then
		if playerCar:IsBurningOut() and traction > 20 and speed < 10 then
			missionData.burnoutDone = true
			MISSION.SetHudVisibleTask("marker_burnout")
			
			MISSION.DoReviewerVoice("iview.scare", 10.0)
		end
	end
	
	if missionData.handbrakeDone == false then
		if playerCar:IsHandbraking() and speed > 10.0 then
			missionData.handbrakeDone = true
			MISSION.SetHudVisibleTask("marker_handbrake")
		end
	end
	
	if missionData.brakeDone == false then
		if playerCar:IsBraking() and speed > 50.0 then
			MISSION.DoReviewerVoice("iview.scare", 10.0)

			missionData.brakeDone = true;
			MISSION.SetHudVisibleTask("marker_brake")
			
		end
	end
	
	if missionData.speedDone == false then
		if playerCar:IsAccelerating() and speed > 70.0 then
			MISSION.DoReviewerVoice("iview.scare", 10.0)

			missionData.speedDone = true
			MISSION.SetHudVisibleTask("marker_speed")
		end
	end
	
	--Msg(string.format("plr speed=%g trac=%g\n", speed, traction));
end

--
-- Quick direction changes
--
MISSION.ProcessTurnoverConditions = function( delta )
	
	local missionData = MISSION.Data
	local playerCar = MISSION.playerCar

	if missionData.rotate360 and missionData.rotate180 and missionData.rotateRev180 then
		return
	end

	local angVel = playerCar:GetAngularVelocity()

	local angularY = math.abs(math.deg(angVel:get_y()))
	
	local spd = playerCar:GetSpeed()
	local fwdSpd = dot( playerCar:GetVelocity(), playerCar:GetForwardVector() )

	if missionData.rotateStartDir == 0 then
	
		missionData.turnoverVector = normalize(playerCar:GetVelocity())
	
		-- initialize movement direction
		if fwdSpd > 0.1 then
			if missionData.rotateStartDir ~= 1 then
				missionData.degreesRotate = 0
				missionData.rotateTime = 0
			end
		
			missionData.rotateStartDir = 1
		elseif fwdSpd < -0.5 then
			if missionData.rotateStartDir ~= -1 then
				missionData.degreesRotate = 0
				missionData.rotateTime = 0
			end
		
			missionData.rotateStartDir = -1
			
		end
	else
		local minAngularVel = 20.0;
		local minAngularVelForStartPoint = 80.0;
		
		-- initialize start position where to perform the trick
		if missionData.rotateStartPos == nil then
			if angularY > minAngularVelForStartPoint then
				missionData.rotateStartPos = playerCar:GetOrigin() + playerCar:GetVelocity() * Vector3D.new(0.3);
			else
				missionData.rotateStartDir = 0
				missionData.rotateTime = 0
				return
			end
		end
		
		missionData.rotateTime = missionData.rotateTime + delta
	
		local distFromStartPoint = length(missionData.rotateStartPos - playerCar:GetOrigin())
		local lateral = math.abs(playerCar:GetLateralSliding())
	
		-- kill the try if player is out of the penalty radius or speed 
		if missionData.rotateStartDir == 1 and distFromStartPoint > MISSION.RotationSpherePenaltyRadius and lateral < 1.0 then
			missionData.rotateStartDir = 0
			missionData.rotateTime = 0
			return
		end
		

		-- check the distance where rotation happens
		-- when running backwards it's not necessary
		if angularY < minAngularVel then
		
			local absResult = math.abs(missionData.degreesRotate)
			
			local dotResult = dot(missionData.turnoverVector, playerCar:GetForwardVector())
			
			--Msg(string.format("dir = %d, dotResult = %g, rot = %d, time: %g sec\n", missionData.rotateStartDir, dotResult, missionData.degreesRotate, missionData.rotateTime));
			
			if missionData.rotateStartDir == 1 then
			
				local diff180 = math.abs(180 - absResult)
				local diff360 = math.abs(360 - absResult)
			
				-- check 180 degress
				if not missionData.rotate180 and dotResult < -0.9 and missionData.rotateTime < 2.0 and diff180 < MISSION.RotationCheckThreshold then
					missionData.rotate180 = true
					MISSION.SetHudVisibleTask("marker_180")
					
					MISSION.DoReviewerVoice("iview.scare", 10.0)
				end
				
				-- check 360 degress
				if not missionData.rotate360 and dotResult > 0.85 and diff360 < MISSION.RotationCheckThreshold then
					missionData.rotate360 = true
					MISSION.SetHudVisibleTask("marker_360")
					
					MISSION.DoReviewerVoice("iview.scare", 10.0)
				end

			else
				local diff180 = math.abs(180 - absResult)
			
				-- check 180 reverse knowing that system cannot go with better numbers :)
				if not missionData.rotateRev180 and dotResult > 0.9 then
					missionData.rotateRev180 = true
					MISSION.SetHudVisibleTask("marker_rev180")
					
					MISSION.DoReviewerVoice("iview.scare", 10.0)
				end
			end

			missionData.rotateStartPos = nil
			missionData.rotateTime = 0
			missionData.rotateStartDir = 0
			missionData.degreesRotate = 0
		else
			missionData.degreesRotate = missionData.degreesRotate + angularY*delta
		end
	end
end

MISSION.FailedDamagedCar = function()

	local missionData = MISSION.Data
	local playerCar = MISSION.playerCar

	playerCar:Lock(true)
	gameHUD:ShowAlert("#FAILED_MESSAGE", 5.0, HUD_ALERT_DANGER)
	gameHUD:ShowScreenMessage("#IVIEW_WRECKED_MESSAGE", 3.5)
	
	MISSION.DoReviewerVoice("iview.fail", 10, true)
	
	missionmanager:SetRefreshFunc( function() 
		return false 
	end ) 

	gameHUD:Enable(false)
	
	missionData.carDamage = playerCar:GetDamage()

	gameses:SignalMissionStatus( MIS_STATUS_FAILED, 5.0 )
end

MISSION.OnPlayerCollide = function( self, collData )

	local missionData = MISSION.Data
	local playerCar = MISSION.playerCar

	if missionData.testDone then
		return
	end

	if collData.impulse < 0.15 then
		return
	end
	
	-- check player vehicle is "wrecked"
	if missionData.collisionCount < 4 and playerCar:GetDamage() < playerCar:GetMaxDamage() then
		gameHUD:ShowScreenMessage("#IVIEW_HIT_MESSAGE", 0.8)
		
		MISSION.DoReviewerVoice("iview.damage", 2.0)

		missionData.collisionCount = missionData.collisionCount + 1;
		MISSION.SetHudVisibleTask("marker_hit_" .. missionData.collisionCount)

	elseif missionData.wrecked == false and missionData.testDone == false then	
		MISSION.FailedDamagedCar()
		missionData.wrecked = true
	end
end

MISSION.OnDeath = function( self, collObject )
	if collObject ~= nil and collObject:GetName() == "trash_cheat" then
		Msg("Cheat counter! ")
	end
end

MISSION.DoReviewerVoice = function(name, nextVoiceTime, force)

	local missionData = MISSION.Data

	if force == nil then
		force = false
	end

	if missionData.nextVoiceTime <= 0.0 or force then
		sounds:Emit2D( EmitParams.new(name), -1 )
		
		missionData.nextVoiceTime = nextVoiceTime
	end
end

-- main mission update
MISSION.Update = function( delta )

	local missionData = MISSION.Data
	local playerCar = MISSION.playerCar

	missionData.nextVoiceTime = missionData.nextVoiceTime - delta

	------------------
	-- logic
	MISSION.ProcessLapCondition()
	MISSION.ProcessSpeedConditions()
	MISSION.ProcessTurnoverConditions( delta )
	MISSION.ProcessSlalomCondition()
	------------------
	
	if 	missionData.lapDone and
		missionData.slalomDone and
		missionData.speedDone and
		missionData.burnoutDone and
		missionData.brakeDone and
		missionData.handbrakeDone and
		missionData.rotate180 and
		missionData.rotate360 and
		missionData.rotateRev180 then
		
		missionmanager:SetRefreshFunc( function() 
			return false 
		end ) 
		
		-- gameHUD:ShowAlert("#SUCCESS_MESSAGE", 6.0, HUD_ALERT_SUCCESS)
		gameHUD:ShowScreenMessage("#IVIEW_SUCCESS_MESSAGE", 6.0)
		
		MISSION.DoReviewerVoice("iview.success", 10, true)
		
		missionData.testDone = true
		
		gameHUD:Enable(false)

		playerCar:Lock(true);
		
		gameses:SignalMissionStatus( MIS_STATUS_SUCCESS, 6.0 )
	end
	
	if missionmanager:IsTimedOut() then
		gameHUD:ShowAlert("#FAILED_MESSAGE", 5.0, HUD_ALERT_DANGER)
		gameHUD:ShowScreenMessage("#IVIEW_TIMEOUT_MESSAGE", 3.5)
	
		MISSION.DoReviewerVoice("iview.failTime", 10)

		missionmanager:SetRefreshFunc( function() 
			return false 
		end ) 
		
		playerCar:Lock(true);
		
		gameHUD:Enable(false)
		
		gameses:SignalMissionStatus( MIS_STATUS_FAILED, 6.0 )
		return false
	end

	return true
end
