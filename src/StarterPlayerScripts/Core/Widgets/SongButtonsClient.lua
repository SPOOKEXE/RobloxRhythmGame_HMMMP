local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local LocalModules = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Modules"))

local Interface = LocalPlayer:WaitForChild('PlayerGui'):WaitForChild('Interface')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local SystemsContainer = {}

-- // Module // --
local Module = {}

Module.IsOpen = nil
Module.WidgetMaid = ReplicatedModules.Modules.Maid.New()

function Module.OpenWidget()
	if Module.IsOpen then
		return
	end
	Module.IsOpen = true

end

function Module.CloseWidget()
	if not Module.IsOpen then
		return
	end
	Module.IsOpen = false

	Module.WidgetMaid:Cleanup()
end

function Module.Start()

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
