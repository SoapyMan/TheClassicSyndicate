------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------- THE CLASSIC SYNDICATE - MODINIT -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ModInit = {
	Title = "The Classic Syndicate",

	CreatedBy = "_matti, Soapy, Nik, ...",
	Version = "1.7.20",
	
	PreBoot = false,

	Conflicts = {}
}

Miami_PrefferedStoryCar = "m_default_ios"
local EQUI_CARSSELECTION_SCHEME_NAME = "ui_mainmenu_storycar"

-----------------------------------------------------------------------
-------- MISSIONS -----------------------------------------------------
-----------------------------------------------------------------------

local MiamiMissionsIndex = -1

local MiamiMissionsList = {
	{
		id = "intro",
		screen = "story_movie_play", 
		args = "render02.mpg" 
	},
	{
		id = "m_00", 
		label = "Interview" 
	},
	{
		id = "m_flat_nextmessage", 
		message = "m_01", 
		label = "The Bank Job (motel intro)"
	},
	{
		id = "m_01", 
		label = "The Bank Job"
	},
	{
		id = "m_flat_nextmessage", 
		message = "m_02", 
		label = "Hide The Evidence (motel intro)"
	},
	{
		id = "m_02", 
		label = "Hide The Evidence" 
	},
	{
		id = "m_flat_nextmessage",
		message = "m_03",
		label = "Ticco's Ride (motel intro)"
	},
	{
		id = "m_03",
		label = "Ticco's Ride" 
	},
	{
		id = "cleanup_movie",
		screen = "story_movie_play",
		args = {"render51.mpg", "message.call_cleanup"} 
	},
	{
		id = "m_04a",
		label = "The Clean Up (Part 1)" 
	},
	{
		id = "m_04b",
		label = "The Clean Up (Part 2)" 
	},
	{
		id = "m_flat_nextmessage",
		message = "m_05a",
		label = "Case For A Key (motel intro)"
	},
	{
		id = "m_05a", 
		label = "Case For A Key"
	},
	{
		id = "boatchase_movie_1",
		screen = "story_movie_play",
		args = "render24.mpg"
	},
	{
		id = "m_05b",
		label = "Case For A Key (Part 2)" 
	},
	{
		id = "boatchase_movie_2",
		screen = "story_movie_play",
		args = "render65.mpg"
	},
	{
		id = "m_05c",
		label = "Case For A Key (Part 3)"
	},
	{
		id = "boatchase_movie_end",
		screen = "story_movie_play",
		args = "render25.mpg"
	},
	{
		id = "m_flat_nextmessage",
		message = "m_06",
		label = "Tanner Meets Rufus (motel intro)"
	},
	{
		id = "m_06", 
		label = "Tanner Meets Rufus" 
	},
	{
		id = "rufus_bustoutjeanpaul_movie", 
		screen = "story_movie_play", 
		args = "render01.mpg"
	},
	{
		id = "m_07a", 
		label = "Bust Out Jean Paul" 
	},
	{
		id = "m_07b", 
		label = "Bust Out Jean Paul (Part 2)"
	},
	{
		id = "m_flat_nextmessage",
		message = "m_08",
		label = "Payback (motel intro)"
	},
	{
		id = "payback_movie",
		screen = "story_movie_play",
		args = {"render59.mpg", "message.call_payback"}
	},
	{
		id = "m_08", 
		label = "Payback" 
	},
	{
		id = "shipment_movie",
		screen = "story_movie_play",
		args = {"render56.mpg", "message.call_shipment"} 
	},
	{
		id = "m_09", 
		label = "A Shipment's Coming In"
	},
	{
		id = "m_flat_nextmessage",
		message = "m_10",
		label = "Superfly Drive (motel intro)"
	},
	{
		id = "m_10",
		label = "Superfly Drive"
	},
	{
		id = "m_flat_nextmessage",
		message = "m_11",
		label = "Take Out Di Angio's Car (motel intro)"
	},
	{
		id = "diangio_movie",
		screen = "story_movie_play",
		args = {"render59.mpg", "message.call_diangio"}
	},
	{
		id = "m_11",
		label = "Take Out Di Angio's Car"
	},
	{
		id = "m_flat_nextmessage",
		message = "m_12",
		label = "Bait for a Trap (motel intro)"
	},
	{
		id = "baitforatrap_movie",
		screen = "story_movie_play",
		args = {"render59.mpg", "message.call_baitforatrap"}
	},
	{
		id = "m_12",
		label = "Bait for a Trap"
	},
	{
		id = "informant_movie",
		screen = "story_movie_play",
		args = "render03.mpg"
	},
	{
		id = "m_13",
		label = "The Informant"
	},
	{
		id = "informant_end",
		screen = "story_movie_play",
		args = "render05.mpg"
	},
	{
		id = "ending", 
		screen = "story_miamiclassic_end"
	}
}

-----------------------------------------------------------------------
-------- LEVELS -------------------------------------------------------
-----------------------------------------------------------------------

local ParkingFileName = "Parking"
local MiamiFileName = "Miami"

local Levels = {
	ParkingFileName,
	MiamiFileName,
}

-----------------------------------------------------------------------
-------- VEHICLES -----------------------------------------------------
-----------------------------------------------------------------------

local Vehicles = {
	{"m_default_ios", "Miami - Default Car (iOS)"},
	{"m_evidence_ios", "Miami - Evidence Car (iOS)"},
}

-----------------------------------------------------------------------
-------- MISCELLANEOUS ------------------------------------------------
-----------------------------------------------------------------------

local CopSoundsFileName = "scripts/sounds/cmn_police.txt"

function IsMyLevel()
	local levName = string.lower(world:GetLevelName())

	for i,n in ipairs(Levels) do
		if string.lower(n) == levName then
			return true
		end
	end
	
	return false
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------- INITIALIZATION ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function ModInit:Init()
	
	-----------------------------------------------------------------------
	-------- SCRIPTS ------------------------------------------------------
	-----------------------------------------------------------------------
	
	fonts.LoadFontDescriptionFile("resources/additional_fonts.res")

	include("scripts/lua/cmn_cutcam.lua")
	include("scripts/lua/cmn_hud.lua")
--	include("scripts/lua/ui/StoryMiamiClassicEndScreen.lua")
	include("scripts/lua/ui/StoryMoviePlay.lua")
	storySelectionItems = include("scripts/lua/cmn_storycar.lua")

	EmitterSoundRegistry.cmn_vehicles 	= 	"scripts/sounds/cmn_vehicles.txt"
	EmitterSoundRegistry.cmn_voices 	= 	"scripts/sounds/cmn_voices.txt"
	EmitterSoundRegistry.cmn_sfx 		= 	"scripts/sounds/cmn_sfx.txt"
	EmitterSoundRegistry.cmn_messages 	= 	"scripts/sounds/cmn_messages.txt"
	EmitterSoundRegistry.cmn_objects 	= 	"scripts/sounds/cmn_objects.txt"
	
	CopVoiceOver[ParkingFileName] = CopSoundsFileName;
	CopVoiceOver[MiamiFileName] = CopSoundsFileName;
	
	CopVoiceOver[string.lower(ParkingFileName)] = CopSoundsFileName;
	CopVoiceOver[string.lower(MiamiFileName)] = CopSoundsFileName;
	
	-----------------------------------------------------------------------
	-------- MISCELLANEOUS ------------------------------------------------
	-----------------------------------------------------------------------

    OldMakeDefaultMissionSettings = MakeDefaultMissionSettings
    MakeDefaultMissionSettings = function()
    
		local settings = OldMakeDefaultMissionSettings()
		
		settings.KeepPursuitMusic = IsMyLevel()
		
		return settings
	end

	CityTimeOfDayMusic[MiamiFileName] = {
		day_clear = "miami_day",
		day_stormy = "la_day",
		dawn_clear = "frisco_night",
		night_clear = "miami_night",
		night_stormy = "nyc_night"
	}

	-----------------------------------------------------------------------
	-------- LEVELS -------------------------------------------------------
	-----------------------------------------------------------------------

	table.insert(MenuCityList, {MiamiFileName, "Miami"})
	table.insert(MenuCityList, {ParkingFileName, "Parking"})

	-----------------------------------------------------------------------
	-------- VEHICLES -----------------------------------------------------
	-----------------------------------------------------------------------

	for i,v in ipairs(Vehicles) do
		table.insert(MenuCarsList, v)
	end

	-----------------------------------------------------------------------
	-------- MISSIONS -----------------------------------------------------
	-----------------------------------------------------------------------

	missions["undercover"] = MiamiMissionsList

	local MiamiMissionsElems = 
	{
		{
			label = "#MENU_SYNDICATE_NEWGAME",
			isFinal = true,
			onEnter = function(self, stack)
			
				-- Reset and run ladder
				missionladder:Run( "undercover", missions["undercover"] )

				return {}
			end,
		},
	}
	
	MiamiMissionsIndex = table.insert(StoryGameExtraElems, 
		MenuStack.MakeSubMenu("Miami - Missions", storySelectionItems, nil, EQUI_CARSSELECTION_SCHEME_NAME))
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------- DE-INITIALIZATION ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function ModInit:DeInit()

	-----------------------------------------------------------------------
	-------- SCRIPTS ------------------------------------------------------
	-----------------------------------------------------------------------

	EmitterSoundRegistry.cmn_parking 	= 	nil

	EmitterSoundRegistry.cmn_vehicles 	= 	nil
	EmitterSoundRegistry.cmn_voices 	= 	nil
	EmitterSoundRegistry.cmn_sfx 		= 	nil
	EmitterSoundRegistry.cmn_messages 	= 	nil
	EmitterSoundRegistry.cmn_objects 	= 	nil

	cmn_cutcam = nil

	-----------------------------------------------------------------------
	-------- MISSIONS -----------------------------------------------------
	-----------------------------------------------------------------------

	table.remove(StoryGameExtraElems, MiamiMissionsIndex)
	
	missions["undercover"] = nil

	-----------------------------------------------------------------------
	-------- LEVELS -------------------------------------------------------
	-----------------------------------------------------------------------

	for i,v in ipairs(MenuCityList) do
	
		for ii,vv in ipairs(Levels) do
			if v[1] == vv then
				--table.remove( MenuCityList, i)
				MenuCityList[i] = nil
			end
		end
	end

	-----------------------------------------------------------------------
	-------- VEHICLES -----------------------------------------------------
	-----------------------------------------------------------------------

	for i,v in ipairs(MenuCarsList) do
	
		for ii,vv in ipairs(Vehicles) do
			if vv[1] == v[1] then
				--table.remove( MenuCarsList, i)
				MenuCarsList[i] = nil
			end
		end
	end
end

return ModInit
