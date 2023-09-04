--//////////////////////////////////////////////////////////////////////////////////
--// Copyright � Inspiration Byte
--// 2009-2020
--//////////////////////////////////////////////////////////////////////////////////

local StoryCarsList = {
	{"m_default_ios", "Miami - Default Car (iOS)"},
}

function Miami_GetPlayerCarName()
	local storyPreferences = RestoreMissionCompletionData("MiamiStoryPreferences")
	if storyPreferences ~= nil then
		Miami_PrefferedStoryCar = storyPreferences.PrefferedStoryCar
	end
	
	-- reset in some paranoid cases
	if Miami_PrefferedStoryCar == nil then
		Miami_PrefferedStoryCar = "m_default_ios"
	end
	
	return Miami_PrefferedStoryCar
end

local function MiamiCarSelectionElementsFunc(equiScheme, stack)

	-- reset car type if mods were disabled
	if MenuStack.FindChoiceIndex(StoryCarsList, Miami_PrefferedStoryCar) == -1 then
		Miami_PrefferedStoryCar = StoryCarsList[1][1]
	end
	
	-- init elements
	local selElem = {}
	local prevElem = {}
	local nextElem = {}

	selElem.ui = equi:Cast(equiScheme:FindChild("carselection_img"), "image")
	selElem.ui:SetMaterial("ui/vehicles/"..Miami_PrefferedStoryCar)

	prevElem.ui = equi:Cast(equiScheme:FindChild("carselection_prev"), "image")
	prevElem.ui:SetMaterial("ui/vehicles/"..Miami_PrefferedStoryCar)

	nextElem.ui = equi:Cast(equiScheme:FindChild("carselection_next"), "image")
	nextElem.ui:SetMaterial("ui/vehicles/"..Miami_PrefferedStoryCar)

	-- make update function to show and hide prev/next items
	local updateItems = function()
		local value = Miami_PrefferedStoryCar
		local choiceIdx = MenuStack.FindChoiceIndex(StoryCarsList, value)
		
		local imageName = "ui/vehicles/"..value
		
		-- check for image existence
		if not fileSystem:FileExist("materials/"..imageName..".mat", SP_MOD) then
			imageName = "ui/vehicles/unknown_vehicle"
		end
		
		selElem.ui:SetMaterial(imageName)
		
		if choiceIdx-1 > 0 then
			value = StoryCarsList[choiceIdx-1][1]
			imageName = "ui/vehicles/"..value
		
			-- check for image existence
			if not fileSystem:FileExist("materials/"..imageName..".mat", SP_MOD) then
				imageName = "ui/vehicles/unknown_vehicle"
			end
		
			prevElem.ui:SetMaterial(imageName)
			prevElem.ui:Show()
		else
			prevElem.ui:Hide()
		end
		
		if choiceIdx+1 <= #StoryCarsList then
			value = StoryCarsList[choiceIdx+1][1]
			
			imageName = "ui/vehicles/"..value
		
			-- check for image existence
			if not fileSystem:FileExist("materials/"..imageName..".mat", SP_MOD) then
				imageName = "ui/vehicles/unknown_vehicle"
			end
			
			nextElem.ui:SetMaterial(imageName)
			nextElem.ui:Show()
		else
			nextElem.ui:Hide()
		end		
	end
	
	updateItems() -- first time update
	
	local movetime = 0
	local movedir = 1

	-- make get/set for both CVar and element
	local currentCarNameGetSet = { 
		get = function()
			return Miami_PrefferedStoryCar
		end,
		set = function(value, dir)
			movetime = 0.25
			movedir = dir
			
			Miami_PrefferedStoryCar = value
			
			updateItems()
		end
	}
	
	-- this updates UI every frame
	stack.updateFunc = function(delta)

		local moveVal = movetime*movetime * 1.0
		local scale = 1.0 - moveVal*4
		selElem.ui:SetTransform(vec2(movetime * movedir * 500, 0), vec2(scale,scale), movedir * movetime * 25.0)
		
		local unselScale = 0.75+movetime
	
		if movedir < 0 then
			nextElem.ui:SetTransform(vec2(movetime * -80, movetime * 80), vec2(unselScale,unselScale), 0)
			prevElem.ui:SetTransform(vec2(0, 0), vec2(0.75,0.75), 0)
		else
			prevElem.ui:SetTransform(vec2(movetime * 80, movetime * 80), vec2(unselScale,unselScale), 0)
			nextElem.ui:SetTransform(vec2(0, 0), vec2(0.75,0.75), 0)
		end
		
		if movetime > 0 then
			movetime = movetime-delta
		end
	end

	-- make menu elements
	-- car selection, city selection and time of day
	local elems = {
		MenuStack.MakeChoiceParam("< %s >", currentCarNameGetSet, StoryCarsList),
		{
			label = "#MENU_SYNDICATE_NEWGAME",
			isFinal = true,
			onEnter = function(self, stack)
			
				-- first store for MCD
				StoreMissionCompletionData("MiamiStoryPreferences", {
					PrefferedStoryCar = Miami_PrefferedStoryCar
				})
							
				-- Reset and run ladder
				missionladder:Run( "undercover", missions["undercover"] )

				return {}
			end,
		},
	}
	
	return elems
end

-- return entire menu item function
return MiamiCarSelectionElementsFunc