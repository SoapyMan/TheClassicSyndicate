-- Code by Matthias and Shurumov Ilya

McdCutsceneCamera = {
}

local function McdCutsceneCamera_Update(delta)
	local data = CutsceneCamera.Data

	-- initialize
	if data.CameraAppr == nil then
		data.CameraAppr = data.Cameras[data.CameraSet][data.CameraIndex]
	end

	data.CameraTime = data.CameraTime + delta

	local camera = data.Cameras[data.CameraSet][data.CameraIndex]
	local nextCamera = data.Cameras[data.CameraSet][data.CameraIndex+1]
	
	if nextCamera ~= nil then
		if data.CameraTime > nextCamera[3] then
			data.CameraIndex = data.CameraIndex + 1
		end
	else
		data.CameraSet = data.CameraSet + 1
		data.CameraIndex = 1
		data.CameraTime = 0
		
		if data.CameraSet > #data.Cameras then
			CutsceneCamera.End()
		else
			data.CameraAppr = data.Cameras[data.CameraSet][data.CameraIndex]
		end
		
		return
	end
	
	local cameraLerp = RemapValClamp(data.CameraTime, camera[3], nextCamera[3], 0.0, 1.0)
	
	local cameraPos = lerp(camera[1], nextCamera[1], cameraLerp)
	local cameraRot = qslerp(camera[2], nextCamera[2], cameraLerp)
	local cameraFOV = lerp(camera[4], nextCamera[4], cameraLerp)
	
	data.CameraAppr[1] = lerp(data.CameraAppr[1], cameraPos, delta*3.0 )
	data.CameraAppr[2] = qslerp(data.CameraAppr[2], cameraRot, delta*3.0 )
	data.CameraAppr[4] = lerp(data.CameraAppr[4], cameraFOV, delta*3.0 )
	
	local camFinalAngles = qeulersSel(data.CameraAppr[2], QuatRot_zxy)
	
	cameraAnimator:SetOrigin( data.CameraAppr[1] )
	cameraAnimator:SetAngles( VRAD2DEG(vec3(camFinalAngles.y, camFinalAngles.x, camFinalAngles.z)) )
	cameraAnimator:SetFOV( cameraFOV )
	cameraAnimator:SetMode( CAM_MODE_TRIPOD )

	-- target doesn't matter
	cameraAnimator:Update(delta, gameses:GetPlayerCar())
end

-- starts the camera sequence playback
-- once completed, it calls onCompleted after extraWait
function McdCutsceneCamera.Start(cameras, onCompleted, extraWait)
	if CutsceneCamera.isPlaying then
		CutsceneCamera.End()
	end

	CutsceneCamera.origMode = cameraAnimator:GetMode()
	CutsceneCamera.onCompleted = onCompleted
	CutsceneCamera.extraWait = extraWait or 0
	CutsceneCamera.isPlaying = true
	
	-- convert every camera angle to quaternion
	for si, set in ipairs(cameras) do
		for i, v in ipairs(set) do
			set[i][2] = qrotateZXY(v[2].x * Deg2Rad, v[2].y * Deg2Rad, v[2].z * Deg2Rad)
		end
	end
	
	CutsceneCamera.Data = {
		CameraSet = 1,
		CameraIndex = 1,
		CameraTime = 0.0,
		Cameras = cameras,
	}
	
	-- register update
	missionmanager:SetPluginRefreshFunc("CutsceneCamera", McdCutsceneCamera_Update)
	cameraAnimator:SetScripted(true)
end
