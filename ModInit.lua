-- ModInit for Syndicate's Classic Mod

-- Hey man, good luck in the future, both for your game and your own future, see ya ! #_matti

local ModInit = {
	Title = "The Classic Syndicate",

	CreatedBy = "_matti, Soapy, Nik, ...",
	Version = "1.7.20",
	
	PreBoot = false,

	Conflicts = {}
}

McdPrefferedStoryCar = "mcd_miamidef"
local EQUI_CARSSELECTION_SCHEME_NAME = "ui_mainmenu_mcdmissioncar"

-------------------------------------------------------------------------------

-- Mod Vocabulary:

-- dsd		= desert data

-- pkd		= parking data

-- mcd 		= miami classic data
-- mcdpages = miami classic data (mainly for models)

-- sfd		= san francisco data
-- sfdpages	= san francisco data (mainly for models)

-- lad		= los angeles data
-- ladpages = los angeles data (mainly for models)

-- nyd		= new york data
-- nydpages	= new york data (mainly for models)

-------------------------------------------------------------------------------

-- Missions Index (Menu)
local MiamiMissionsIdx = -1

-- Miami (Classic) Missions
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
	--"mcd_flat_nextmessage",	-- A Shipment's Coming In (Message)				O
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

local MyLevelFileName = "MiamiClassic"
local ParkingLevelName = "iviewclassic"
local MyLevelFileName2 = "FriscoClassic"

local McdLevelNames = {
	MyLevelFileName,
	ParkingLevelName,
	MyLevelFileName2,
}

local ClassicCars = {

	{"m_default_ios", "Miami - Default Car (iOS)"},
	{"m_evidence_ios", "Miami - Evidence Car (iOS)"},

	{"mcd_superflydrive", "Miami - Superfly Drive Car"},
	{"mcd_defaultpolicecar_black", "Miami, New York - Police"},
	{"NPC_mcd_traffic01", "Miami - Traffic Car 1"},
	{"NPC_mcd_traffic02", "Miami - Traffic Car 2"},
	{"mcd_miamibetagsx", "Miami - Beta GSX Car"},
	{"mcd_miamicleanup", "Miami - The Clean Up Car"},

	{"sfd_friscodef", "Frisco - Default PSX Car"},
}

local MyCopSoundsFilename = "scripts/sounds/mcd_cops.txt"

function IsMyLevel()
	local levName = string.lower(world:GetLevelName())

	for i,n in ipairs(McdLevelNames) do
		if string.lower(n) == levName then
			return true
		end
	end
	
	return false
end

-- Initialization function
function ModInit:Init()
	
	fonts.LoadFontDescriptionFile("resources/additional_fonts.res")

	-- make MCD camera available
	include("scripts/lua/McdCinematicCamera.lua")
	include("scripts/lua/McdHud.lua")
	include("scripts/lua/ui/StoryMiamiClassicEndScreen.lua")
	include("scripts/lua/ui/StoryMoviePlay.lua")
	storySelectionItems = include("scripts/lua/McdStoryCarSelection.lua")

	EmitterSoundRegistry.MCDEngine = "scripts/sounds/mcd_engine.txt"				-- Driver 1 engine sounds
	EmitterSoundRegistry.MCDVoices = "scripts/sounds/mcd_missions_vo.txt"			-- Driver 1 original mission voices
	EmitterSoundRegistry.MCDSfx = "scripts/sounds/mcd_csfx.txt"						-- SFX for cameras / transitions
	EmitterSoundRegistry.MCDMessages = "scripts/sounds/mcd_missions_messages.txt"	-- Vocal messages
	EmitterSoundRegistry.MCDObjects = "scripts/sounds/mcd_objects.txt"				-- Objects SFX
	
	CopVoiceOver[MyLevelFileName] = MyCopSoundsFilename;	-- Define what cop sounds script a level uses
	CopVoiceOver[MyLevelFileName2] = MyCopSoundsFilename;
	CopVoiceOver[ParkingLevelName] = MyCopSoundsFilename;
	
	CopVoiceOver[string.lower(MyLevelFileName)] = MyCopSoundsFilename;
	CopVoiceOver[string.lower(MyLevelFileName2)] = MyCopSoundsFilename;
	CopVoiceOver[string.lower(ParkingLevelName)] = MyCopSoundsFilename;
	
	-- Change music state logic
    OldMakeDefaultMissionSettings = MakeDefaultMissionSettings
    MakeDefaultMissionSettings = function()
    
		local settings = OldMakeDefaultMissionSettings()
		
		settings.KeepPursuitMusic = IsMyLevel()
		
		return settings
	end

	CityTimeOfDayMusic[MyLevelFileName] = {			-- Music selection for Miami (Classic)
		day_clear = "miami_day",
		day_stormy = "la_day",
		dawn_clear = "frisco_night",
		night_clear = "miami_night",
		night_stormy = "nyc_night"
	}

	CityTimeOfDayMusic[MyLevelFileName2] = {			-- Music selection for Miami (Classic)
		day_clear = "frisco_day",
		day_stormy = "la_day",
		dawn_clear = "frisco_night",
		night_clear = "frisco_night",
		night_stormy = "nyc_night"
	}

	-----------------------------------------------------------
	-- Classic Content (Map / Vehicles / Missions / Minigames) --
	-----------------------------------------------------------

	
	-- add levels
	table.insert(MenuCityList, {MyLevelFileName, "Miami (Classic)"})			-- Miami Classic
	table.insert(MenuCityList, {ParkingLevelName, "Parking (Classic)"})			-- Parking Classic
	table.insert(MenuCityList, {MyLevelFileName2, "Frisco (Classic)"})			-- Miami Classic

	-- add cars
	for i,v in ipairs(ClassicCars) do
		table.insert(MenuCarsList, v)
	end

	-- Add missions
	missions["tcs_story"] = MiamiMissionsList

	-- Miami (Classic) Minigames
	table.insert(missions["minigame/survival"], {"mcd_srv01", "Miami Classic (Miami Beach)"})
	table.insert(missions["minigame/survival"], {"mcd_srv02", "Miami Classic (Downtown)"})
	table.insert(missions["minigame/survival"], {"mcd_srv03", "Miami Classic (Coral Gables)"})

	local MiamiMissionsElems = 
	{
		{
			label = "#MENU_SYNDICATE_NEWGAME",
			isFinal = true,
			onEnter = function(self, stack)
			
				-- Reset and run ladder
				missionladder:Run( "tcs_story", missions["tcs_story"] )

				return {}
			end,
		},
	}
	
	MiamiMissionsIdx = table.insert(StoryGameExtraElems, 
		MenuStack.MakeSubMenu("Miami - Classic Missions", storySelectionItems, nil, EQUI_CARSSELECTION_SCHEME_NAME))
end

-- Deinitialization function
function ModInit:DeInit()							-- Remove sound script(s) usage when mod turned off
	EmitterSoundRegistry.MCDEngine = nil			-- Driver 1 engine sounds
	EmitterSoundRegistry.MCDIview = nil				-- Default Interview resources
	EmitterSoundRegistry.MCDVoices = nil			-- Driver 1 missions voices
	EmitterSoundRegistry.MCDSfx = nil				-- Cutscenes SFX
	EmitterSoundRegistry.MCDMessages = nil			-- Vocal messages SFX
	EmitterSoundRegistry.MCDObjects = nil			-- Gameplay SFX

	McdCutsceneCamera = nil

-- Deinit - Missions

	table.remove(StoryGameExtraElems, MiamiMissionsIdx)
	
	-- Remove Miami (Classic) Minigames
	table.remove(missions["minigame/survival"], mcd_srv01)
	table.remove(missions["minigame/survival"], mcd_srv02)
	table.remove(missions["minigame/survival"], mcd_srv03)

	missions["tcs_story"] = nil		-- Remove Miami (Classic) missions

	-- Deinit - Maps
	for i,v in ipairs(MenuCityList) do
	
		for ii,vv in ipairs(McdLevelNames) do
			if v[1] == vv then
				--table.remove( MenuCityList, i)
				MenuCityList[i] = nil
			end
		end
	end

	-- Deinit - Cars - MIAMI
	for i,v in ipairs(MenuCarsList) do
	
		for ii,vv in ipairs(ClassicCars) do
			if vv[1] == v[1] then
				--table.remove( MenuCarsList, i)
				MenuCarsList[i] = nil
			end
		end
	end
end

return ModInit
