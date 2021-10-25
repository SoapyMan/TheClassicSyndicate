-- ModInit for Syndicate's Classic Mod

local ModInit = {
	Title = "The Classic Syndicate",

	CreatedBy = "_matti, Soapy, Nik",
	Version = "1.7.10",
	
	PreBoot = false,

	Conflicts = {}
}

McdPrefferedStoryCar = "mcd_miamidef"
McdHdPrefferedStoryCar = "hd_arvensis"
local EQUI_CARSSELECTION_SCHEME_NAME = "ui_mainmenu_mcdmissioncar"


-- Missions Index (Menu)

local MiamiMissionsIdx = -1
local MiamiSyndicateMissionsIdx = -1
local TakeARideZikmuSwitchIdx = -1
local MiamiHDMissionsIdx = -1

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

local MiamiHDMissionsList = {
	"hd_mcd00",					-- Interview								O		Playable, Complete
	"hd_mcd_flat_nextmessage",	-- The Bank Job (Message)					O
	"hd_mcd01",					-- The Bank Job								O		Playable, Complete
	"hd_mcd_flat_nextmessage",	-- Hide The Evidence (Message)				O
	"hd_mcd02",					-- Hide The Evidence						O		Playable, Complete
	"hd_mcd_flat_nextmessage",	-- Ticco's Ride (Message)					O
	"hd_mcd03",					-- Ticco's Ride								O		NaU (EndCPath)
	"hd_mcd_flat_nextmessage",	-- The Clean Up (Message)					O
	"hd_mcd04a",				-- The Clean Up (Part 1)					O		Playable, Complete
	"hd_mcd04b",				-- The Clean Up (Part 2)					O		Playable, Complete
	"hd_mcd_flat_nextmessage",	-- Case For A Key (Message)					O
	"hd_mcd05a",				-- Case For A Key							O		Playable, Complete
	"hd_mcd05b",				-- Case For A Key (Part 2)					O		Playable, Complete
	"hd_mcd05c",				-- Case For A Key (Part 3)					O		NaU (EndTPoint&Scenery)
	"hd_mcd_flat_nextmessage",	-- Tanner Meets Rufus (Message)				O
	"hd_mcd06", 				-- Tanner Meets Rufus						O		Playable, Complete
	"hd_mcd07a",				-- Bust Out Jean Paul						O		Playable, Complete
	"hd_mcd07b",				-- Bust Out Jean Paul (Part 2)				O		Playable, Complete
	"hd_mcd_flat_nextmessage",	-- Payback (Message)						O
	"hd_mcd08", 				-- Payback									O		Playable, Complete	
	"hd_mcd_flat_nextmessage",	-- A Shipment's Coming In (Message)			O
	"hd_mcd09", 				-- A Shipment's Coming In					O		NaU (P2Lghts&SndBnk)	
	"hd_mcd_flat_nextmessage",	-- Superfly Drive (Message)					O
	"hd_mcd10",					-- Superfly Drive							O		Playable, Complete	
	"hd_mcd_flat_nextmessage",	-- Take Out Di Angio's Car (Message)		O
	"hd_mcd11", 				-- Take Out Di Angio's Car					O		Playable, Complete	
	"hd_mcd_flat_nextmessage",	-- Bait for a Trap (Message)				O
	"hd_mcd12",					-- Bait for a Trap							O		Playable, Complete
	"hd_mcd13", 				-- The Informant							O		NaU
	{screen = "story_miamiclassic_end"}
}

-- Miami (Syndicate 2019) Missions
local MiamiSyndicateMissionsList = {
	"1",			-- The Bank Job
	"2",			-- Hide The Evidence
	"3",			-- Case For A Key
	"4",			-- Ticco's Ride
	"5",			-- The Clean Up
	"6",			-- Tanner Meets Rufus
	"8",			-- A Shipment's Coming In
	"9",			-- Superfly Drive
}

local MyLevelFileName = "mattimiamiclassic"
local MyHDLevelFileName = "mattimiamiclassichd"
local My2019LevelFileName = "MiamiSyndicate2019"
local MyParkingLevelFileName = "MattiParkingClassic"
local MyLevelFileName2 = "MattiFriscoClassic"

local McdLevelNames = {
	MyLevelFileName,
	MyHDLevelFileName,
	My2019LevelFileName,
	MyParkingLevelFileName,
	MyLevelFileName2,
}

local McdCars = {
	{"mcd_miamidef", "Miami - Default PSX Car"},
	{"mcd_superflydrive", "Miami - Superfly Drive Car"},
	{"mcd_defaultpolicecar_black", "Miami, New York - Police"},
	{"NPC_mcd_traffic01", "Miami - Traffic Car 1"},
	{"NPC_mcd_traffic02", "Miami - Traffic Car 2"},
	{"mcd_miamibetagsx", "Miami - Beta GSX Car"},
	{"mcd_miamievidence", "Miami - Hide The Evidence Car"},
	{"mcd_miamidef_PC", "Miami - Default PC Car"},
	{"mcd_miamicleanup", "Miami - The Clean Up Car"},
	{"mcd_miamidef_iphone", "Miami - Default iPhone Car"},
	{"mcd_miamidef_mini", "Miami - Default PSX Car (MINI)"},
	--{"dsyn_retaliatorSE", "Driver 3 Inspired Car"},
	--{"dsyn_arvensis", "Hallgarth's First Car"},
	{"hexed_challengerxs", "DSyn - Challenger XS"},
	{"hd_gsx", "Hallgarth - GSX (D1 Retake)"},
}

local MyCopSoundsFilename = "scripts/sounds/mcd_cops.txt"

local OldSetMusicName = nil
local OldSetMusicState = nil

function IsMyLevel()
	local levName = world:GetLevelName()

	for i,n in ipairs(McdLevelNames) do
		if n == levName then
			return true
		end
	end
	
	return false
end

-- Initialization function
function ModInit:Init()
	
	-- make MCD camera available
	include("scripts/lua/McdCinematicCamera.lua")
	include("scripts/lua/ui/StoryMiamiClassicEndScreen.lua")
	storySelectionItems = include("scripts/lua/McdStoryCarSelection.lua")
	HDstorySelectionItems = include("scripts/lua/McdHdStoryCarSelection.lua")


	EmitterSoundRegistry.MCDEngine = "scripts/sounds/mcd_engine.txt"				-- Driver 1 engine sounds
	EmitterSoundRegistry.MCDIview = "scripts/sounds/sounds_iview.txt"				-- Call to default's iview file
	EmitterSoundRegistry.MCDVoices = "scripts/sounds/mcd_missions_vo.txt"			-- Driver 1 original mission voices
	EmitterSoundRegistry.MCDSfx = "scripts/sounds/mcd_csfx.txt"						-- SFX for cameras / transitions
	EmitterSoundRegistry.MCDMessages = "scripts/sounds/mcd_missions_messages.txt"	-- Vocal messages
	EmitterSoundRegistry.MCDObjects = "scripts/sounds/mcd_objects.txt"				-- Objects SFX
	
	CopVoiceOver[MyLevelFileName] = MyCopSoundsFilename;	-- Define what cop sounds script a level uses
	CopVoiceOver[MyLevelFileName2] = MyCopSoundsFilename;
	CopVoiceOver[MyHDLevelFileName] = MyCopSoundsFilename;
	CopVoiceOver[MyParkingLevelFileName] = MyCopSoundsFilename;	
	
	OldSetMusicName = SetMusicName
	
	SetMusicName = function( scriptName )
		if ZikmuEnabled and IsMyLevel() then
			OldSetMusicName(scriptName .. "_mcd")
		else
			OldSetMusicName(scriptName)
		end
	end
	
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

	CityTimeOfDayMusic[MyHDLevelFileName] = {			-- Music selection for Frisco (Classic)
		day_clear = "miami_day",
		day_stormy = "la_day",
		dawn_clear = "frisco_night",
		night_clear = "miami_night",
		night_stormy = "nyc_night"
	}

	CityTimeOfDayMusic[My2019LevelFileName] = {		-- Music selection for Miami (Syndicate 2019)
		day_clear = "miami_day",
		day_stormy = "la_day",
		dawn_clear = "frisco_night",
		night_clear = "miami_night",
		night_stormy = "nyc_night"
	}

	-----------------------------------------------------------
	-- Classic Content (Map / Vehicles / Missions / Minigames) --
	-----------------------------------------------------------

	
	-- add levels
	table.insert(MenuCityList, {MyLevelFileName, "Miami (Classic)"})				-- Miami Classic
	--table.insert(MenuCityList, {MyParkingLevelFileName, "Parking (Classic)"})		-- Parking Classic
	table.insert(MenuCityList, {My2019LevelFileName, "Miami (Syndicate 2019)"})		-- Miami Syndicate (2019)
	table.insert(MenuCityList, {MyLevelFileName2, "Frisco (Classic)"})				-- Miami Classic

	-- add cars
	for i,v in ipairs(McdCars) do
		table.insert(MenuCarsList, v)
	end

	-- Add missions
	missions["mcd_missions"] = MiamiMissionsList
	missions["mcd_missions_hd"] = MiamiHDMissionsList
	missions['msyn_missions'] = MiamiSyndicateMissionsList

	-- Miami (Classic) Minigames
	table.insert(missions["minigame/survival"], {"mcd_srv01", "Miami Classic (Miami Beach)"})
	table.insert(missions["minigame/survival"], {"mcd_srv02", "Miami Classic (Downtown)"})
	table.insert(missions["minigame/survival"], {"mcd_srv03", "Miami Classic (Coral Gables)"})

	-- Miami (Syndicate 2019) Minigames
	table.insert(missions["minigame/survival"], {"msyn_srv03", "Miami Syndicate (Miami Beach)"})
	table.insert(missions["minigame/survival"], {"msyn_srv01", "Miami Syndicate (Bal Harbor)"})
	table.insert(missions["minigame/survival"], {"msyn_srv02", "Miami Syndicate (Downtown)"})

	-- PS1 Music Switch
--	local ZikmuSwitchItem = MenuStack.MakeChoiceParam("PS1 Music < %s >", musicGetSet, {
--			{ false, "#MENU_OFF" },
--			{ true, "#MENU_ON" },
--		})

	local MiamiMissionsElems = 
	{
		--ZikmuSwitchItem,
		{
			label = "#MENU_SYNDICATE_NEWGAME",
			isFinal = true,
			onEnter = function(self, stack)
			
				-- Reset and run ladder
				missionladder:Run( "mcd_missions", missions["mcd_missions"] )

				return {}
			end,
		},
	}

	local MiamiSyndicateMissionsElems = 
	{
		--ZikmuSwitchItem,
		{
			label = "#MENU_SYNDICATE_NEWGAME",
			isFinal = true,
			onEnter = function(self, stack)
			
				-- Reset and run ladder
				missionladder:Run( "msyn_missions", missions["msyn_missions"] )

				return {}
			end,
		},
	}

	local MiamiHDMissionsElems = 
	{
		--ZikmuSwitchItem,
		{
			label = "#MENU_SYNDICATE_NEWGAME",
			isFinal = true,
			onEnter = function(self, stack)
			
				-- Reset and run ladder
				missionladder:Run( "mcd_missions_hd", missions["mcd_missions_hd"] )

				return {}
			end,
		},
	}

	TakeARideZikmuSwitchIdx = table.insert(TakeARideExtraElements, ZikmuSwitchItem)

	MiamiMissionsIdx = table.insert(StoryGameExtraElems, 
		MenuStack.MakeSubMenu("Miami - Classic Missions", storySelectionItems, nil, EQUI_CARSSELECTION_SCHEME_NAME))

	MiamiHDMissionsIdx = table.insert(StoryGameExtraElems, 
		MenuStack.MakeSubMenu("Miami - Classic Missions (w/ HD Cars)", HDstorySelectionItems, nil, EQUI_CARSSELECTION_SCHEME_NAME))

	MiamiSyndicateMissionsIdx = table.insert(StoryGameExtraElems, 
		MenuStack.MakeSubMenu("Miami - Syndicate 2019 Missions", MiamiSyndicateMissionsElems, false))
end

-- Deinitialization function
function ModInit:DeInit()							-- Remove sound script(s) usage when mod turned off
	SetLevelLoadCallbacks("MCDZikmu", nil, nil)		-- PSX Driver 1 bugged music
	EmitterSoundRegistry.MCDEngine = nil			-- Driver 1 engine sounds
	EmitterSoundRegistry.MCDIview = nil				-- Default Interview resources
	EmitterSoundRegistry.MCDVoices = nil			-- Driver 1 missions voices
	EmitterSoundRegistry.MCDSfx = nil				-- Cutscenes SFX
	EmitterSoundRegistry.MCDMessages = nil			-- Vocal messages SFX
	EmitterSoundRegistry.MCDObjects = nil			-- Gameplay SFX

	McdCutsceneCamera = nil

-- Deinit - Missions

	table.remove(TakeARideExtraElements, TakeARideZikmuSwitchIdx)
	table.remove(StoryGameExtraElems, MiamiMissionsIdx)
	table.remove(StoryGameExtraElems, MiamiHDMissionsIdx)
	table.remove(StoryGameExtraElems, MiamiSyndicateMissionsIdx)
	
	SetMusicName = OldSetMusicName
	MakeDefaultMissionSettings = OldMakeDefaultMissionSettings
	
	-- Remove Miami (Classic) Minigames
	table.remove(missions["minigame/survival"], mcd_srv01)
	table.remove(missions["minigame/survival"], mcd_srv02)
	table.remove(missions["minigame/survival"], mcd_srv03)

	-- Remove Miami (Syndicate 2019) Minigames
	table.remove(missions["minigame/survival"], msyn_srv01)
	table.remove(missions["minigame/survival"], msyn_srv02)
	table.remove(missions["minigame/survival"], msyn_srv03)
	
	missions["mcd_missions"] = nil		-- Remove Miami (Classic) missions
	missions["mcd_missions_hd"] = nil
	missions["msyn_missions"] = nil		-- Remove Miami (Syndicate 2019) missions

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
	
		for ii,vv in ipairs(McdCars) do
			if vv[1] == v[1] then
				--table.remove( MenuCarsList, i)
				MenuCarsList[i] = nil
			end
		end
	end
end

return ModInit