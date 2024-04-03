local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService('RunService')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local SongsConfigModule = ReplicatedModules.Data.Songs

local RemoteService = ReplicatedModules.Services.RemoteService
local SongSelectFunction : RemoteFunction = RemoteService.GetRemote('SongSelectFunction', 'RemoteFunction', false)

local SystemsContainer = {}

-- // Module // --
local Module = {}

Module.KeybindsMaid = ReplicatedModules.Modules.Maid.New()
Module.ActiveSongMaid = ReplicatedModules.Modules.Maid.New()

function Module.OnActionKeyPressed( actionEnum : number )

end

function Module.OnActionKeyReleased( actionEnum : number )

end

function Module.EnableKeybinds()

	Module.KeybindsMaid:Give(UserInputService.InputBegan:Connect(function(inputObject, wasProcessed)

	end))

	Module.KeybindsMaid:Give(UserInputService.InputEnded:Connect(function(inputObject, wasProcessed)

	end))

end

function Module.DisableKeybinds()
	Module.KeybindsMaid:Cleanup()
end


function Module.CancelSong()
	local s, e = SongSelectFunction:InvokeServer( SongsConfigModule.RemoteEnums.Cancel )
	if not s then
		warn(e)
	end
	Module.ActiveSongMaid:Cleanup()
	Module.DisableKeybinds()
	SystemsContainer.ParentSystems.SongSelectionClient.Widgets.OpenWidget()
end

function Module.PlaySongFromIndex( index : number )

end

function Module.Update(dt : number)

end

function Module.Start()

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
