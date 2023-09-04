
------------------------------------------------------------
-- Plug-in to handle felony and damage bars

local function AddHudDamageBar()
	-- Damage bar
	local damageBar = gameHUD:FindChildElement("tcs_DamageBar")
	if damageBar == nil then
		return
	end

	damageBar = equi:Cast(damageBar, "progressBar")
	if damageBar == nil then
		MsgError("eqUI cannot cast damageBar to 'progressBar'\n")
		return
	end

	MissionManager:SetPluginRefreshFunc("hudDamageBar", nil)

	local alpha = 1.0
	local oldPercentageValue = 0.0
	local animateDamageBar = 0.0
	local lightsTime = 0
	
	MissionManager:SetPluginRefreshFunc("hudDamageBar", function(dt)
	
		lightsTime = lightsTime + dt

		local percentage = 0

		local playerCar = gameses:GetPlayerCar()
		
		if playerCar ~= nil then
			percentage = playerCar:GetDamage() / playerCar:GetMaxDamage()				
		end

		if percentage > oldPercentageValue then
			animateDamageBar = animateDamageBar + (percentage - oldPercentageValue) * 25.0
			if animateDamageBar > 1.0 then
				animateDamageBar = 1.0
			end
		end
		
		-- same as CGameHUD::DrawPercentageBar computation
		local damageColor = v4d_lerp(vec4(0.6,0.5,0,alpha), vec4(0.6,0,0,alpha), percentage) * vec4(1.5);

		if percentage > 0.85 then
			local flashValue = math.sin(lightsTime*16.0) * 5.0;
			flashValue = clamp(flashValue, 0.0, 1.0);

			damageColor = v4d_lerp(vec4(0.5, 0.0, 0.0, alpha), vec4(0.8, 0.2, 0.2, alpha), flashValue) * vec4(1.5);
		end
		
		if animateDamageBar > 0 then
			damageColor = damageColor + vec4(animateDamageBar)
			animateDamageBar = animateDamageBar - dt
		end
		
		local animateDamageBarShake = math.pow(animateDamageBar, 4)

		damageBar:SetValue(percentage)
		damageBar:SetColor(damageColor)
		damageBar:SetTransform(vec2(math.sin(animateDamageBarShake * 445.0) * 5.0, 0), vec2(1.0 + animateDamageBarShake*0.05), math.sin(animateDamageBarShake * 445.0) * 0.5)
		
		oldPercentageValue = percentage

	end)

end

local function AddHudFelonyBar()
	local felonyBar = gameHUD:FindChildElement("tcs_FelonyBar")
	if felonyBar == nil then
		return
	end

	felonyBar = equi:Cast(felonyBar, "progressBar")
	if felonyBar == nil then
		MsgError("eqUI cannot cast felonyBar to 'progressBar'\n")
		return
	end

	local lightsTime = 0
	MissionManager:SetPluginRefreshFunc("hudFelonyBar", function(dt)
		lightsTime = lightsTime + dt

		local felonyPercent = 0
		local playerCar = gameses:GetPlayerCar()
		
		if playerCar ~= nil then
			felonyPercent = math.abs(playerCar:GetFelony())
			if felonyPercent >= 0.1 then
				local colorValue = clamp(math.sin(lightsTime * 12.0), -1.0, 1.0)

				local v1 = math.pow(-math.min(0.0,colorValue), 2.0)
				local v2 = math.pow(math.max(0.0,colorValue), 2.0)

				local newColor = v4d_lerp(vec4(v1,0,v2,1), vec4(1,1,1,1), 0.15)
				felonyBar:SetColor(newColor)
			else
				felonyBar:SetColor(vec4(0.2,0.2,1,1))
			end
		end
		
		felonyBar:SetValue(felonyPercent)
	end)
end

-- Add game HUD initialization
SetHudInitializedCallback("tcs_HUD", function()
	AddHudDamageBar()
	AddHudFelonyBar()
end)
