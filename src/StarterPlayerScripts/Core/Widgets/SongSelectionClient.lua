local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local LocalAssets = LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Assets')
local LocalModules = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Modules"))

local UserInterfaceUtility = LocalModules.Utility.UserInterface

local Interface = LocalPlayer:WaitForChild('PlayerGui'):WaitForChild('Interface')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local SongsConfigModule = ReplicatedModules.Data.Songs

local RemoteService = ReplicatedModules.Services.RemoteService
local SongSelectFunction : RemoteFunction = RemoteService.GetRemote('SongSelectFunction', 'RemoteFunction', false)

local SystemsContainer = {}

-- // Module // --
local Module = {}

Module.IsOpen = nil
Module.WidgetMaid = ReplicatedModules.Modules.Maid.New()

Module.SelectedSongId = nil
Module.SelectedDifficulty = nil
Module.SelectedIndex = nil

function Module.PlaySelectedSong()
	local success, err = SongSelectFunction:InvokeServer( SongsConfigModule.RemoteEnums.Play, Module.SelectedIndex )
	if not success then
		warn(err)
		return
	end

	Module.CloseWidget()
	SystemsContainer.ParentSystems.Gameplay.SongClient.PlaySong( Module.SelectedIndex )
end

function Module.SelectSongByIndex(index : number) : boolean
	local songConfig : {}? = SongsConfigModule.GetConfigFromIndex( index )
	if not songConfig then
		return false
	end
	Module.SelectedSongId = songConfig.SongId
	Module.SelectedDifficulty = songConfig.Difficulty
	Module.SelectedIndex = index
	Module.UpdateWidget()
	return true
end

function Module.SelectSongById(songId : string, difficulty : number) : boolean
	local index : number? = SongsConfigModule.GetSongIndex( songId, difficulty )
	if not index then
		return false
	end
	Module.SelectedSongId = songId
	Module.SelectedDifficulty = difficulty
	Module.SelectedIndex = index
	Module.UpdateWidget()
	return true
end

function Module.GetSongFrame( index : number, difficulty : number )
	local frame = Interface.SelectSongsFrame.Scroll:FindFirstChild(index)
	if not frame then
		frame = LocalAssets.UI.TemplateSongFrame:Clone()
		frame.Name = index
		frame.LayoutOrder = index + (difficulty * 400)

		local button = UserInterfaceUtility.CreateActionButton({Parent = frame})
		button.Activated:Connect(function()
			Module.SelectSongByIndex(index)
		end)

		frame.Parent = Interface.SelectSongsFrame.Scroll
	end
	return frame
end

function Module.UpdateWidget()

end

function Module.OpenWidget()
	if Module.IsOpen then
		return
	end
	Module.IsOpen = true

	for index, songData in SongsConfigModule.Songs do

		local frame = Module.GetSongFrame( index, songData.Difficulty )
		if not frame then
			continue
		end

		-- frame.Visible = filterDifficulty or by filterStarLevel

	end

	task.spawn(Module.SelectSongByIndex, Module.SelectedIndex or 1)
end

function Module.CloseWidget()
	if not Module.IsOpen then
		return
	end
	Module.IsOpen = false

	Module.WidgetMaid:Cleanup()
end

function Module.Start()

	task.spawn(Module.OpenWidget)

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
