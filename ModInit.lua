-- ModInit for Syndicate's Classic Mod

-- Hey man, good luck in the future, both for your game and your own future, see ya ! #_matti

local ModInit = {
	Title = "The Classic Syndicate",

	CreatedBy = "_matti, Soapy, Nik",
	Version = "1.7.14",
	
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
	"mcd00",				-- Interview									O		Playable, Complete
	"mcd_flat_nextmessage",	-- The Bank Job (Message)						O
	"mcd01",				-- The Bank Job									O		Playable, Complete
	"mcd_flat_nextmessage",	-- Hide The Evidence (Message)					O
	"mcd02",				-- Hide The Evidence							O		Playable, Complete
	"mcd_flat_nextmessage",	-- Ticco's Ride (Message)						O
	"mcd03",				-- Ticco's Ride									O		NaU (EndCPath)
	"mcd_flat_nextmessage",	-- The Clean Up (Message)						O
	"mcd04a",				-- The Clean Up (Part 1)						O		Playable, Complete
	"mcd04b",				-- The Clean Up (Part 2)						O		Playable, Complete
	"mcd_flat_nextmessage",	-- Case For A Key (Message)						O
	"mcd05a",				-- Case For A Key								O		Playable, Complete
	"mcd05b",				-- Case For A Key (Part 2)						O		Playable, Complete
	"mcd05c",				-- Case For A Key (Part 3)						O		NaU (EndTPoint&Scenery)
	"mcd_flat_nextmessage",	-- Tanner Meets Rufus (Message)					O
	"mcd06", 				-- Tanner Meets Rufus							O		Playable, Complete
	"mcd07a",				-- Bust Out Jean Paul							O		Playable, Complete
	"mcd07b",				-- Bust Out Jean Paul (Part 2)					O		Playable, Complete
	"mcd_flat_nextmessage",	-- Payback (Message)							O
	"mcd08", 				-- Payback										O		Playable, Complete	
	"mcd_flat_nextmessage",	-- A Shipment's Coming In (Message)				O
	"mcd09", 				-- A Shipment's Coming In						O		NaU (P2Lghts&SndBnk)	
	"mcd_flat_nextmessage",	-- Superfly Drive (Message)						O
	"mcd10",				-- Superfly Drive								O		Playable, Complete	
	"mcd_flat_nextmessage",	-- Take Out Di Angio's Car (Message)			O
	"mcd11", 				-- Take Out Di Angio's Car						O		Playable, Complete	
	"mcd_flat_nextmessage",	-- Bait for a Trap (Message)					O
	"mcd12",				-- Bait for a Trap								O		Playable, Complete
	"mcd13", 				-- The Informant								O		NaU
	{screen = "story_miamiclassic_end"}
}

local MyLevelFileName = "MiamiClassic"
local MyParkingLevelFileName = "ParkingClassic"
local MyLevelFileName2 = "FriscoClassic"

local McdLevelNames = {
	MyLevelFileName,
	MyParkingLevelFileName,
	MyLevelFileName2,
}

local ClassicCars = {
	{"mcd_miamidef", "Miami - Default PSX Car"},
	{"mcd_superflydrive", "Miami - Superfly Drive Car"},			-- TODO: unlock with cheats or completion of story
	{"mcd_defaultpolicecar_black", "Miami, New York - Police"},		-- TODO: unlock with cheats or completion of story
	{"NPC_mcd_traffic01", "Miami - Traffic Car 1"},					-- TODO: unlock with cheats or completion of story
	{"NPC_mcd_traffic02", "Miami - Traffic Car 2"},					-- TODO: unlock with cheats or completion of story
	{"mcd_miamibetagsx", "Miami - Beta GSX Car"},					-- TODO: unlock with cheats or completion of story
	{"mcd_miamievidence", "Miami - Hide The Evidence Car"},			-- TODO: unlock with cheats or completion of story
	{"mcd_miamidef_PC", "Miami - Default PC Car"},
	{"mcd_miamicleanup", "Miami - The Clean Up Car"},				-- TODO: unlock with cheats or completion of story
	{"mcd_miamidef_iphone", "Miami - Default iPhone Car"},
	{"mcd_miamidef_mini", "Miami - Default PSX Car (MINI)"},		-- TODO: unlock with cheats or completion of story

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
	storySelectionItems = include("scripts/lua/McdStoryCarSelection.lua")


	EmitterSoundRegistry.MCDEngine = "scripts/sounds/mcd_engine.txt"				-- Driver 1 engine sounds
	EmitterSoundRegistry.MCDVoices = "scripts/sounds/mcd_missions_vo.txt"			-- Driver 1 original mission voices
	EmitterSoundRegistry.MCDSfx = "scripts/sounds/mcd_csfx.txt"						-- SFX for cameras / transitions
	EmitterSoundRegistry.MCDMessages = "scripts/sounds/mcd_missions_messages.txt"	-- Vocal messages
	EmitterSoundRegistry.MCDObjects = "scripts/sounds/mcd_objects.txt"				-- Objects SFX
	
	CopVoiceOver[MyLevelFileName] = MyCopSoundsFilename;	-- Define what cop sounds script a level uses
	CopVoiceOver[MyLevelFileName2] = MyCopSoundsFilename;
	CopVoiceOver[MyParkingLevelFileName] = MyCopSoundsFilename;
	
	CopVoiceOver[string.lower(MyLevelFileName)] = MyCopSoundsFilename;
	CopVoiceOver[string.lower(MyLevelFileName2)] = MyCopSoundsFilename;
	CopVoiceOver[string.lower(MyParkingLevelFileName)] = MyCopSoundsFilename;
	
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
	table.insert(MenuCityList, {MyLevelFileName, "Miami (Classic)"})				-- Miami Classic
	--table.insert(MenuCityList, {MyParkingLevelFileName, "Parking (Classic)"})		-- Parking Classic
	table.insert(MenuCityList, {MyLevelFileName2, "Frisco (Classic)"})				-- Miami Classic

	-- add cars
	for i,v in ipairs(ClassicCars) do
		table.insert(MenuCarsList, v)
	end

	-- Add missions
	missions["MiamiClassic_Story"] = MiamiMissionsList

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
				missionladder:Run( "MiamiClassic_Story", missions["MiamiClassic_Story"] )

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

	missions["MiamiClassic_Story"] = nil		-- Remove Miami (Classic) missions

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
