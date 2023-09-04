--//////////////////////////////////////////////////////////////////////////////////
--// Copyright © Inspiration Byte
--// 2009-2021
--//////////////////////////////////////////////////////////////////////////////////

local ID_MOVIE_AUDIO = 0

local StoryMoviePlay = class()

	SequenceScreens.Register("story_movie_play", StoryMoviePlay)
	
	StoryMoviePlay.schemeName = "resources/ui_story_movie.res"

	function StoryMoviePlay:__init( args ) 
		self.control = nil
		self.done = false
		self.endDelay = 0
		self.startDelay = 0.0
		if type(args) == "table" then
			self.movieName = args[1]
			self.audioName = args[2]
		else
			self.movieName = args
		end
		
		Msg(string.format("Movie name %s\n", self.movieName))
	end
	
	function StoryMoviePlay:OnEnter()
		self.startDelay = 0.05
		self.endDelay = 0.5
		self.audioStarted = false
		
		self.moviePlayer = CLuaMoviePlayer.new("story_movie")
		self.audioObject = sounds:CreateObject()

		sounds:LoadScript(EmitterSoundRegistry.cmn_messages)
		if self.audioName ~= nil then
			sounds:Precache(self.audioName)
		end
	end
	
	function StoryMoviePlay:OnLeave()
		sounds:RemoveObject(self.audioObject)
		self.audioObject = nil
		
		self.moviePlayer:Destroy()
		self.moviePlayer = nil
	end

	function StoryMoviePlay:InitUIScheme( equiControl )
		self.control = equiControl		
	end
	
	function StoryMoviePlay:Update(delta)
		if self.startDelay > 0 then
			self.startDelay = self.startDelay - delta
			if self.startDelay <= 0 then
				if not self.moviePlayer:Init("resources/media/"..self.movieName) then
					return false
				end
				sounds:Precache("message.story_movie")
				
				-- start video and sound
				self.moviePlayer:Start()
				
				-- TODO: audio object
				self.audioObject:Emit( ID_MOVIE_AUDIO, EmitParams.new("message.story_movie") )
			end
			return true
		end
		
		self.moviePlayer:Present()

		if self.audioStarted and self.audioObject:GetEmitterState(ID_MOVIE_AUDIO) == EMITTER_STOPPED then
			self:Close()
		end

		if not self.moviePlayer:IsPlaying() and not self.done then
			if self.audioName ~= nil then
				-- TODO: audio object
				if not self.audioStarted then
					self.audioObject:Emit( ID_MOVIE_AUDIO, EmitParams.new(self.audioName) )
					self.audioStarted = true
				end
				return true
			else
				self:Close()
			end
		end
	
		if self.done then
			self.endDelay = self.endDelay - delta
		end

		return self.endDelay > 0
	end
	
	function StoryMoviePlay:Close()
		if not self.done then
			SequenceScreens.current = nil
			missionladder:OnMissionCompleted()
			missionladder:RunContinue()
		end
		self.done = true
	end
	
	function StoryMoviePlay:KeyPress(key, down)
		local allowedKeys = {
			[inputMap["ENTER"]] = true,
			[inputMap["ESCAPE"]] = true, 
			[inputMap["SPACE"]] = true,
			[inputMap["JOY_A"]] = true
		}
		if allowedKeys[key] ~= nil and down == false then
			self:Close()
		end
	end
	
	function StoryMoviePlay:MouseClick(x, y, buttons, down)
		if buttons == inputMap["MOUSE1"] then
			self:Close()
		end
	end
	