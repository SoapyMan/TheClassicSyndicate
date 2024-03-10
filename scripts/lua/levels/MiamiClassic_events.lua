------------------------------------------------------
-- METRO MOVER
------------------------------------------------------

function metrotest()
	local position = vec3(-62.31, 0.67, -1087.55)

	local pl = gameses:GetPlayerCar()
	pl:SetOrigin(position)
	pl:SetAngles(vec3(0,270,0))
	pl:SetFelony(-0.001)
end

local function ReversePath(path)
	local hasReverse = false
	local newPath = {}
	for i = #path, 1, -1 do
		local v = path[i]
		
		if v == ReversePath then
			hasReverse = true
		else
			-- swap
			table.insert(newPath, {v[2], v[1]})
		end
	end
	
	if hasReverse then
		table.insert(newPath, ReversePath)
	end
	
	return newPath
end

local METRO_MOVER_MODEL = "models/MIAMI/City/mcd_metromover.egf"
local METRO_MOVER_HEIGHT = 7.0
local METRO_MOVER_WAIT_TIME = 5.0

-- sw 40th bt to 2nd ave
local METRO_PATH_1 = {
	{vec3(-52.75, 0.77, -1074.00), vec3(21.68, 0.67, -1073.79)},
	{vec3(30.16, 0.77, -1065.36), vec3(30.16, 0.77, -822.49)}
}

-- 2nd ave to biscaynes bay side
local METRO_PATH_2 = {
	{vec3(38.79, 0.77, -813.76), vec3(113.64, 0.77, -813.93)},
	{vec3(122.04, 0.77, -823.28), vec3(121.97, 0.67, -949.84)},
	{vec3(130.37, 0.67, -957.91), vec3(173.70, 0.77, -957.99)},
}

-- 2nd ave through
local METRO_PATH_3 = {
	{vec3(30.16, 0.67, -799.14), vec3(30.12, 0.67, -506.42)}
}

-- 2nd ave to downtown connection
local METRO_PATH_4 = {
	{vec3(30.16, 0.77, -493.37), vec3(30.16, 0.72, -355.86)}
}

-- to downtown
local METRO_PATH_5 = {
	{vec3(-345.96, 6.2, -148.0), vec3(-345.86, 6.2, -258.15)},
	{vec3(-333.75, 6.2, -265.94), vec3(-234.88, 6.2, -265.96)},
	{vec3(-225.83, 6.2, -274.31), vec3(-225.82, 6.2, -344.71)},
	{vec3(-216.87, 6.2, -354.05), vec3(-142.52, 6.2, -353.86)}, 
	{vec3(-133.98, 6.2, -344.92), vec3(-134.39, 6.2, -246.51)},
	{vec3(-125.14, 6.2, -237.81), vec3(20.61, 6.2, -238.15)},
	{vec3(29.95, 6.2, -247.95), vec3(30.26, 6.2, -346.96)},
}

-- biscayne blvd
local METRO_PATH_6 = {
	{vec3(38.38, 0.77, -498.05), vec3(119.41, 0.77, -498.00)},
	{vec3(122.03, 0.77, -495.30), vec3(121.93, 0.67, -422.29)},
	{vec3(112.82, 0.77, -413.79), vec3(79.10, 0.67, -413.99)},
	{vec3(69.98, 0.77, -405.08), vec3(70.06, 0.67, -362.50)},
	{vec3(61.15, 0.77, -354.06), vec3(39.16, 0.77, -354.68)}
}

-- multi-path
local METRO_CITY_PATH_1 = {
	METRO_PATH_1, METRO_PATH_2, { ReversePath }
}

local METRO_CITY_PATH_2 = {
	ReversePath(METRO_PATH_2), METRO_PATH_3, METRO_PATH_4, ReversePath(METRO_PATH_6), ReversePath(METRO_PATH_3), METRO_PATH_2, { ReversePath }
}

local METRO_CITY_PATH_3 = {
	METRO_PATH_5, ReversePath(METRO_PATH_6), METRO_PATH_4, ReversePath(METRO_PATH_5), { ReversePath }
}

-- MISSION PATH
local METRO_INFORMANT_PATH = {
	METRO_PATH_1, METRO_PATH_3, METRO_PATH_6, ReversePath(METRO_PATH_5)
}

local MetroMover = class() 
	function MetroMover:__init( data, enabled, canReverse )
		if type(data[1][1]) == "userdata" then
			--Msg("test of path?\n")
			self.path = data
		else
			--Msg("Multi-path?\n")
			
			self.path = {}
			
			-- build full path out of it
			for i,path in pairs(data) do
				-- iterate path segments
				for ii,seg in pairs(path) do
					table.insert(self.path, seg)
				end
			end
		end
		
		self.enabled = if_then_else(enabled ~= nil, enabled, true)
		self.canReverse = if_then_else(canReverse ~= nil, canReverse, true)
		
		self.strip = 1
		self.speed = 0
		self.position = 0
		self.onCurve = false
		self.firstUpdate = false
		self.waitTime = METRO_MOVER_WAIT_TIME
	end
	
	function MetroMover:Init()
		if self.object == nil then
			self.object = objects:CreateGameObject("object", create_section({}))
			self.object:SetModel(METRO_MOVER_MODEL)
			self.object:Spawn()
		end
	end
	
	function MetroMover:Destroy()
		if self.object ~= nil then
			self.object:Remove()
			self.object = nil
		end
	end
	
	function MetroMover:Enable(value)
		self.enabled = value
	end
	
	function MetroMover:Update( delta )
	
		if not self.enabled and self.firstUpdate then
			return
		end
		
		self.firstUpdate = true
		local MAX_SPEED = 30
		local MAX_SPEED_CURVE = 20
		local DISTANCE_TO_STOP = 15
		local ACCELERATION_FACTOR = 0.85

		local PITCH_ANGLE = 0.4
		local YAW_ROTATION_SCALE = 2.0
		local EXTEND_LENGTH = 6.0
		
		local numStrips = #self.path - 1

		local currStrip = self.path[self.strip]
		local nextStrip = self.path[self.strip + 1]
		
		local pathFunc = nil
		
		if type(nextStrip) == "function" then
			pathFunc = nextStrip
			nextStrip = nil
		end
		
		local pointA = currStrip[1]
		local pointB = currStrip[2]
		
		self.position = self.position + self.speed * delta
		
		local positionVec
		local rotationQuat
		
		if self.onCurve then

			local curveDiameter = length(pointB - nextStrip[1])
		
			-- move on curve
			local curveLength = curveDiameter * math.pi / 2 -- since it is really half of the circle
			
			-- make two direction vectors from current and next strip
			-- to calculate a mid point of our bezier
			local vv1 = normalize(pointB - pointA) * vec3(curveLength * 0.45)
			local vv2 = normalize(nextStrip[1] - nextStrip[2]) * vec3(curveLength * 0.45)
			
			local curveMidPoint = (pointB + vv1 + nextStrip[1] + vv2) * vec3(0.5)
			
			local posNormalized = self.position / curveLength
			
			local points = {pointB, curveMidPoint, nextStrip[1]}
			positionVec = bezierQuadratic3(points[1], points[2], points[3], posNormalized)
			
			-- for calculating forward vector on curve
			local posB = bezierQuadratic3(points[1], points[2], points[3], posNormalized + 0.015)
			
			local forwardVec = normalize(posB - positionVec)
			
			rotationQuat = quat(0, math.atan(forwardVec.z, forwardVec.x) - DEG2RAD(90), 0)
			
			self.speed = math.max(math.min(self.speed, MAX_SPEED_CURVE), 0)
			
			-- if we on the curve end, switch back to strip mode
			if self.position > curveLength then
				self.onCurve = false
				self.position = self.position - curveLength
				self.strip = self.strip + 1
			end
		else
			-- move on straight strip
			local stripLength = length(pointB - pointA)

			local posNormalized = self.position / stripLength
			positionVec = lerp(pointA, pointB, posNormalized)
			
			local forwardVec = normalize(pointB - pointA)
			rotationQuat = quat(0, math.atan(forwardVec.z, forwardVec.x) - DEG2RAD(90), 0)
			
			-- accelerate/decelerate
			if nextStrip ~= nil then
				self.speed = self.speed + ACCELERATION_FACTOR * delta
				self.slowdownSpeed = nil
			elseif self.position > stripLength - DISTANCE_TO_STOP then
				
				local normalizedStopDist = (self.position - (stripLength-DISTANCE_TO_STOP)) / DISTANCE_TO_STOP
				
				if self.slowdownSpeed == nil then
					self.slowdownSpeed = self.speed
				end
				self.speed = self.slowdownSpeed * (1.0 - normalizedStopDist)
			end
				
			self.speed = math.max(math.min(self.speed, MAX_SPEED), 0)
			
			if self.speed < 0.1 and pathFunc then
				self.waitTime = self.waitTime - delta
				
				if self.waitTime <= 0 then
					self.waitTime = METRO_MOVER_WAIT_TIME
					self.path = pathFunc(self.path)
					self.strip = 1
					self.onCurve = false
					self.position = 0
				end
			end
			
			-- if we on the strip end, switch to curve mode
			if posNormalized > 1.0 then
				if nextStrip ~= nil then
					local nextPointA = nextStrip[1]
					local nextPointB = nextStrip[2]
					local nextForwardVec = normalize(nextPointB - nextPointA)
					
					if dot(forwardVec, nextForwardVec) > 0.85 then
						-- advance strip
						self.strip = self.strip + 1
						
						local newPosNormalized = lineProjection(nextPointA, nextPointB, positionVec)
						
						self.position = newPosNormalized * length(nextPointA-nextPointB)
					else
						-- set curve mode
						self.onCurve = true
						self.position = self.position - stripLength
					end
					
					
				end
			end
		end
	
		-- override it's height
		positionVec.y = METRO_MOVER_HEIGHT

		self.object:SetOrigin( positionVec )
		self.object:SetAngles( VRAD2DEG(qeulers(rotationQuat)) )
		
		-- accelerate
		self.speed = math.min(self.speed + ACCELERATION_FACTOR * delta, MAX_SPEED)
	end

------------------------------------------------------
-- GARAGE DOORS
------------------------------------------------------

function doortest()
	local position = vec3(1471.55, 0.56, 891.99)

	local pl = gameses:GetPlayerCar()
	pl:SetOrigin(position)
	pl:SetAngles(vec3(0,180,0))
	pl:SetFelony(-0.001)
end

function doortest2()
	local position = vec3(-1585,0.7,-404)

	local pl = gameses:GetPlayerCar()
	pl:SetOrigin(position)
	pl:SetAngles(vec3(0,90,0))
	pl:SetFelony(-0.001)
end

local JEANPAUL_GARAGE_DOOR_NAME = "garagedoor_jeanpaul"
local CLEANUP_GARAGE_DOOR_NAME = "garagedoor_cleanup"

local GarageDoor = class()
	function GarageDoor:__init(levelObjectName)
		self.levelObjectName = levelObjectName
		self.gameObject = nil
		self.openValue = 0
		self.open = false
		self.position = vec3(0)
		self.angles = vec3(0)
		
		-- filter for specific game object
		SetObjectSpawnRemoveCallbacks(self.levelObjectName,
			function(go) -- load
				self:SetupObject(go)
			end, 
			function(go) -- unload
				self:Destroy()
			end)
	end
	
	function GarageDoor:SetupObject(go)
		self.gameObject = go
		
		self.position = vecCopy(self.gameObject:GetOrigin())
		self.angles = vecCopy(self.gameObject:GetAngles())
		
		-- init it's position and angles
		--Msg("attached")
	end
	
	function GarageDoor:Destroy()
		self.gameObject = nil
		--Msg("detached")
	end
	
	function GarageDoor:Open()
		self.open = true
	end
	
	function GarageDoor:Close()
		self.open = false
	end
	
	function GarageDoor:Update(delta)
		if self.gameObject == nil then
			return
		end
		local targetValue = if_then_else(self.open, 1, 0)
		self.openValue = approachValue(self.openValue, targetValue, sign(targetValue - self.openValue) * delta * 2) -- use approachValue instead
		
		local ang = VDEG2RAD(self.angles)
		local rotation = Quaternion.new(ang.x, ang.y, ang.z)
		local dvec = qrotate(vec3_forward, rotation)
		
		self.gameObject:SetAngles(VRAD2DEG(qeulers(rotation * Quaternion.new(-self.openValue * 1.2, 0, 0))))
		self.gameObject:SetOrigin(self.position + vec3(0,self.openValue,0) + dvec * vec3(self.openValue))
	end

------------------------------------------------------
-- Events table
------------------------------------------------------

local EventTable = {
	-- setup movers
	moverList = {
		MetroMover(METRO_CITY_PATH_1),
		MetroMover(METRO_CITY_PATH_2),
		MetroMover(METRO_CITY_PATH_3)
	},
	-- setup mission doors
	jeanPaulDoor = GarageDoor(JEANPAUL_GARAGE_DOOR_NAME),
	cleanUpDoor = GarageDoor(CLEANUP_GARAGE_DOOR_NAME)
}

function EventTable:Init()
	-- spawn metro movers and make this city alive
	for k,mover in ipairs(self.moverList) do
		mover:Init()
	end
end

function EventTable:Update(delta)
	-- update movers
	for k,mover in ipairs(self.moverList) do
		mover:Update(delta)
	end
	
	-- update garage door
	self.jeanPaulDoor:Update(delta)
	self.cleanUpDoor:Update(delta)
end

-- this function can be called from mission as WorldEvents:MakeInformantMover()
function EventTable:MakeInformantMover()
	-- remove other movers
	for k,mover in ipairs(self.moverList) do
		mover:Destroy()
	end
	self.moverList = {}
	
	self.informantMetro = MetroMover(METRO_INFORMANT_PATH, false)
	self.informantMetro:Init();

	-- add informant mover
	table.insert(self.moverList, self.informantMetro) 
	
	-- also return new object (just in case)
	return self.informantMetro
end

return EventTable
