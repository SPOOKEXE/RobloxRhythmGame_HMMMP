local Players = game:GetService('Players')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local SongsConfigModule = ReplicatedModules.Data.Songs

local RemoteService = ReplicatedModules.Services.RemoteService
local SongSelectFunction : RemoteFunction = RemoteService.GetRemote('SongSelectFunction', 'RemoteFunction', false)
local ActionPressEvent : RemoteEvent = RemoteService.GetRemote('ActionPressEvent', 'RemoteEvent', false)

local SystemsContainer = {}

-- // Module // --
local Module = {}

Module.PlayingSongs = {}

function Module.CanPlayerSelectSong( LocalPlayer : Player, songIndex : number ) : (boolean, string)
	if typeof(songIndex) ~= "number" then
		return false, 'songIndex must be a number.'
	end
	if not SongsConfigModule[songIndex] then
		return false, 'Song does not exist.'
	end
	return true, 'Song can be selected.'
end

function Module.CanPlayerPlaySong( LocalPlayer : Player, songIndex : number ) : (boolean, string)
	if typeof(songIndex) ~= "number" then
		return false, 'songIndex must be a number.'
	end

	if not SongsConfigModule[songIndex] then
		return false, 'Song does not exist.'
	end

	if Module.PlayingSongs[LocalPlayer] then
		return false, 'You are currently playing a song already.'
	end

	local success, err = Module.CanPlayerSelectSong( LocalPlayer, songIndex )
	if not success then
		return false, err
	end

	return true, 'Song can be played.'
end

function Module.AttemptPlayerPlaySong( LocalPlayer : Player, songIndex : number ) : (boolean, string)
	local success, err = Module.CanPlayerPlaySong( LocalPlayer, songIndex )
	if not success then
		return false, err
	end

	-- ignore the speed ones
	local songConfig = SongsConfigModule[songIndex]
	local counter = 1
	while songConfig.Nodes[counter].NodeType == SongsConfigModule.Enums.NodeTypes.Speed do
		counter += 1
	end

	Module.PlayingSongs[LocalPlayer] = {
		Timestamp = tick(),
		Index = songIndex,
		--Counter = counter,
		--Combo = 0,
		--Holding = {},
	}
end

function Module.AttemptPlayerCancelSong( LocalPlayer : Player ) : (boolean, string)
	if Module.PlayingSongs[LocalPlayer] then
		Module.PlayingSongs[LocalPlayer] = nil
	end
	return true, 'Song has been cancelled.'
end

function Module.ValidateSongAttempt( LocalPlayer : Player, songIndex : number, buttonPresses : {number} ) : boolean

end

function Module.HandleOnServerInvoke(LocalPlayer : Player, ...)
	local Args = {...}
	local Job = table.remove(Args, 1)
	if Job == SongsConfigModule.RemoteEnums.Play then
		return Module.AttemptPlayerPlaySong( LocalPlayer, unpack(Args) )
	elseif Job == SongsConfigModule.RemoteEnums.Cancel then
		return Module.AttemptPlayerCancelSong( LocalPlayer )
	elseif Job == SongsConfigModule.RemoteEnums.Validate then
		return Module.ValidateSongAttempt( LocalPlayer, unpack(Args) )
	end
	return false, 'Invalid JobEnum'
end

function Module.Start()
	SongSelectFunction.OnServerInvoke = Module.HandleOnServerInvoke

	Players.PlayerRemoving:Connect(function(LocalPlayer : Player)
		Module.PlayingSongs[LocalPlayer] = nil
	end)
end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
