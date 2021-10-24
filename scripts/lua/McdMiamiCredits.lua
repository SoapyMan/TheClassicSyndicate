--//////////////////////////////////////////////////////////////////////////////////
--// Copyright © Inspiration Byte
--// 2009-2021
--//////////////////////////////////////////////////////////////////////////////////

--------------------------------------------------------------------------------
-- Sequence screens
-- By Shurumov Ilya
-- 03 Feb 2021
--------------------------------------------------------------------------------

SequenceScreenFiles = {
	"scripts/lua/ui/StoryMiamiClassicEndScreen.lua"
}

SequenceScreens = {
	current = nil,
	factory = {}
}

-- Engline callbacks

-- called when engine loads state
function SequenceScreens.OnEnter()
end

-- called when engine leaves state
function SequenceScreens.OnLeave()
end

---------------------------------------------------------------------------------
-- Factory

function SequenceScreens.Create(name)
	local screenFn = SequenceScreens.factory[name]

	if screenFn == nil then
		MsgError("Unknown sequence screen '" .. name .. "'!\n")
		return nil
	end
	
	return screenFn()
end

function SequenceScreens.Register(name, screenClass)
	SequenceScreens.factory[name] = screenClass
end

---------------------------------------------------------------------------------

local TestScreen = class()
	function TestScreen:__init()
		self.schemeName = "resources/ui_story_miamiclassic_end.res"
		self.control = nil
		self.done = false
		self.fade = 0
		self.time = 0
	end

	function TestScreen:InitUIScheme( equiControl )
		self.control = equiControl
		self.bgChild = equi:Cast(self.control:FindChild("fade"), "panel")
		self.bgChild:SetColor(vec4(0, 0, 0, 1))
		
		self.moving = equi:Cast(self.control:FindChild("moving"), "panel")
		
		--util.printObject(self.control)
	end
	
	function TestScreen:Update(delta)
	
		local color = 1.0 - self.fade
	
		self.bgChild:SetColor(vec4(0, 0, 0, color))
		
		if self.done then
			self.fade = self.fade - delta
		else
			self.fade = self.fade + delta
		end

		if self.fade > 1 then
			self.fade = 1
		end
		
		self.time = self.time + delta
		self.moving:SetTransform(vec2(math.sin(self.time * 2) * 150, math.sin(self.time * 4) * 80), vec2(1), 0)
	
		return self.fade > 0
	end
	
	function TestScreen:KeyPress(key, down)
		if key == inputMap["ENTER"] and down == false then
			self.done = true
			SequenceScreens.current = nil
			EqStateMgr.ScheduleNextStateType( GAME_STATE_TITLESCREEN )
		end
		--Msg(string.format("Key! %d %s", key, tostring(down)))
	end
	
	function TestScreen:MouseMove(x, y, deltaX, deltaY)
	end
	
	function TestScreen:MouseClick(x, y, buttons, down)
		--Msg(string.format("Click! %d %d %d %s", x, y, buttons, tostring(down)))
	end

SequenceScreens.Register("test_screen", TestScreen)

loadTableOfFiles(SequenceScreenFiles)