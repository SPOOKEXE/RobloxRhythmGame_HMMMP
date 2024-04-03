local RunService = game:GetService('RunService')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local SongsConfigData = ReplicatedModules.Data.Songs

local SystemsContainer = {}

-- // Module // --
local Module = {}

Module.ActiveSongId = false
Module.ActiveSongData = false

Module.IsPlaying = false
Module.ActiveTimestamp = 0
Module.SpeedMultiplier = 1
Module.ActiveDataIndex = 1

Module.KeyPressHistory = { }

function Module:SelectSong( songId )
	Module.ActiveSongId = songId
	Module.ActiveSongData = SongsConfigData:GetConfigFromId( songId )
end

function Module:ClearSong()
	Module.ActiveSongId = false
	Module.ActiveSongData = false
end

function Module:StartSong()
	Module.ActiveTimestamp = 0
	Module.ActiveDataIndex = 1
	Module.IsPlaying = true
	Module.KeyPressHistory = { }
	-- reset cutscene
end

function Module:PauseSong()
	Module.IsPlaying = false
end

function Module:ResumeSong()
	Module.IsPlaying = true
end

function Module:StopSong()
	Module.IsPlaying = false
	Module:ClearSong()
	-- clear cutscene
end

function Module:CompleteSong()
	print('complete song; ', Module.ActiveSongId)
	print(Module.KeyPressHistory)
end

function Module:StepSong(deltaTime)
	Module.ActiveTimestamp += deltaTime * Module.SpeedMultiplier

	local _, TimestampDuration = SongsConfigData:GetExpectedDuration( Module.ActiveSongData.NoteData )
	if Module.ActiveTimestamp > TimestampDuration then
		Module:PauseSong()
		Module:CompleteSong()
		return
	end

	print(Module.ActiveTimestamp, TimestampDuration)

	-- step buttons
	local Data = Module.ActiveSongData.NoteData[Module.ActiveDataIndex]
	while Data and Module.ActiveTimestamp > Data.Timestamp do
		if Data.Type == "Speed" then
			print("speed set to ", Data.Speed)
			Module.SpeedMultiplier = Data.Speed
		elseif Data.Type == "Action" then
			print("action key; ", Data)
		end
		Module.ActiveDataIndex += 1
		Data = Module.ActiveSongData.NoteData[Module.ActiveDataIndex]
	end

	-- step cutscene

end

function Module:Start()

	Module:SelectSong( 'TestSong1' )
	Module:StartSong()

	task.delay(1, function()
		Module:PauseSong()
		task.wait(1)
		Module:ResumeSong()
	end)

	RunService.Heartbeat:Connect(function(deltaTime)
		if (not Module.ActiveSongId) or (not Module.IsPlaying) then
			if not Module.IsPlaying then
				print("paused")
			end
			return
		end
		Module:StepSong(deltaTime)
	end)

end

function Module:Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
