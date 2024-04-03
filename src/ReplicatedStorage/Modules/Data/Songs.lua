
--[[
	TODO:
	- create data for choosing where a keybind/slider item floats in from
]]

local Types = require(script.Parent.Types)
type KeyPressData = Types.KeyPressData
type BaseNode = Types.BaseNode
type PressButtonNode = Types.PressButtonNode
type HoldButtonNode = Types.HoldButtonNode
type SliderParams = Types.SliderParams
type SliderHoldParams = Types.SliderHoldParams
type SliderDataNode = Types.SliderDataNode
type SpeedNode = Types.SpeedNode
type SongData = Types.SongData

-- // Module // --
local Module = {}

Module.DefaultKeybinds = {
	Action1 = Enum.KeyCode.Left,
	Action2 = Enum.KeyCode.Right,
	Action3 = Enum.KeyCode.Up,
	Action4 = Enum.KeyCode.Down,
	Action5 = Enum.KeyCode.Q,
	Action6 = Enum.KeyCode.E,
}

Module.RemoteEnums = {
	Play = 1,
	Cancel = 2,
	Validate = 3,
}

Module.ButtonIconSets = {
	Arrows0 = {
		Action1 = 'rbxassetid://-1',
		Action2 = 'rbxassetid://-1',
		Action3 = 'rbxassetid://-1',
		Action4 = 'rbxassetid://-1',
		Action5 = 'rbxassetid://-1',
		Action6 = 'rbxassetid://-1',
	},

	WASD0 = {
		Action1 = 'rbxassetid://-1',
		Action2 = 'rbxassetid://-1',
		Action3 = 'rbxassetid://-1',
		Action4 = 'rbxassetid://-1',
		Action5 = 'rbxassetid://-1',
		Action6 = 'rbxassetid://-1',
	},

	Gamepad0 = {
		Action1 = 'rbxassetid://-1',
		Action2 = 'rbxassetid://-1',
		Action3 = 'rbxassetid://-1',
		Action4 = 'rbxassetid://-1',
		Action5 = 'rbxassetid://-1',
		Action6 = 'rbxassetid://-1',
	},

	Joystick0 = {
		Action1 = 'rbxassetid://-1',
		Action2 = 'rbxassetid://-1',
		Action3 = 'rbxassetid://-1',
		Action4 = 'rbxassetid://-1',
		Action5 = 'rbxassetid://-1',
		Action6 = 'rbxassetid://-1',
	},
}

Module.Enums = {
	Difficulty = {
		Easy = 1,
		Normal = 2,
		Hard = 3,
		Extreme = 4,
	},
	NodeType = {
		Button = 1,
		Speed = 2,
		Slider = 3,
	},
	PressTypes = {
		Press = 1,
		Hold = 2,
	},
	ButtonEnums = {
		Action1 = 1,
		Action2 = 2,
		Action3 = 3,
		Action4 = 4,
		Action5 = 5,
		Action6 = 6,
	},
	SpeedLevel = {
		Slow1 = 1,
		Slow2 = 2,
		Slow3 = 3,
		Normal = 4,
		Fast1 = 5,
		Fast2 = 6,
		Fast3 = 7,
		Fast4 = 8,
	},
}

Module.GlobalConfig = {
	-- display this button (buttonTime - n)
	-- seconds from when it should be pressed.
	ButtonDisplayOffset = 3,

	-- must be +/- this to the timestamp
	ButtonThresholds = {
		Perfect = 0.1,
		Great = 0.15,
		Okay = 0.2,
		Pass = 0.3,
		Miss = 0.4,
	},

	-- maps to Module.Enums.SpeedLevel
	SpeedMultipliers = {
		Slow1 = 0.25,
		Slow2 = 0.5,
		Slow3 = 0.75,
		Normal = 1,
		Fast1 = 1.5,
		Fast2 = 2,
		Fast3 = 2.5,
		Fast4 = 3,
	},

	-- default key hold duration
	DefaultKeyHoldDuration = 5,
	DefaultSliderHoldDuration = 2,
}

Module.PointValues = {
	Press = {
		Action0 = {100, 75, 50, 0},
		Action1 = {100, 75, 50, 0},
		Action2 = {100, 75, 50, 0},
		Action3 = {100, 75, 50, 0},
		Action4 = {100, 75, 50, 0},
		Action5 = {100, 75, 50, 0},
		Action6 = {100, 75, 50, 0},
	},

	Hold = {
		Action0 = 2500,
		Action1 = 2500,
		Action2 = 2500,
		Action3 = 2500,
		Action4 = 2500,
		Action5 = 2500,
	},
}

local function CreateButtonData( action : number, X : number, Y : number ) : KeyPressData
	return {
		Action = action,
		X = X,
		Y = Y
	}
end

local function CreateSpeed( timestamp : number, speed : number ) : SpeedNode
	return {
		NodeType = Module.Enums.NodeType.Speed,
		Timestamp = timestamp,
		Speed = speed,
	}
end

local function KeyPress( timestamp : number, keybinds : { KeyPressData } ) : PressButtonNode
	return {
		NodeType = Module.Enums.NodeType.Button,
		PressType = Module.Enums.PressTypes.Press,
		Timestamp = timestamp,
		Keybinds = keybinds,
	}
end

local function KeyHold( timestamp : number, keybinds : { KeyPressData }, duration : number? ) : HoldButtonNode
	return {
		NodeType = Module.Enums.NodeType.Button,
		PressType = Module.Enums.PressTypes.Hold,
		Timestamp = timestamp,
		Duration = duration or Module.GlobalConfig.DefaultKeyHoldDuration,
		Keybinds = keybinds,
	}
end

local function SliderPress( action : number, x : number, y : number ) : SliderParams
	return {
		Action = action,
		PressType = Module.Enums.PressTypes.Press,
		X = x,
		Y = y,
	}
end

local function SliderHold( action : number, sx : number, sy : number, fx : number, fy : number, duration : number ) : SliderHoldParams
	return {
		Action = action,
		PressType = Module.Enums.PressTypes.Hold,
		SX = sx,
		SY = sy,
		FX = fx,
		FY = fy,
		Duration = Module.DefaultSliderHoldDuration or duration,
	}
end

local function CreateSliderData( timestamp : number, sliders : { SliderParams | SliderHoldParams } ) : SliderDataNode
	return {
		NodeType = Module.Enums.NodeType.Slider,
		Timestamp = timestamp,
		Sliders = sliders,
	}
end

Module.Songs = {

	{
		SongId = 'TestSong1',
		Difficulty = Module.Enums.Difficulty.Easy,
		StarLevel = 1,

		Sound = { SoundId = "rbxassetid://-1", TimePosition = 0, Volume = 0.2, },
		AspectRatio = (1920 / 1080),
		Nodes = {
			CreateSpeed( 0, Module.Enums.SpeedLevel.Normal ),
			-- single key press tests
			KeyPress( 3, {
				CreateButtonData(Module.Enums.ButtonEnums.Action1, 500, 450),
			}),
			KeyPress( 5, {
				CreateButtonData(Module.Enums.ButtonEnums.Action2, 550, 400),
			}),
			KeyPress( 7, {
				CreateButtonData(Module.Enums.ButtonEnums.Action3, 500, 400),
			}),
			KeyPress( 9, {
				CreateButtonData(Module.Enums.ButtonEnums.Action4, 450, 400),
			}),
			CreateSliderData(11, {
				SliderPress( Module.Enums.ButtonEnums.Action5, 350, 400 ),
			}),
			CreateSliderData(13, {
				SliderPress( Module.Enums.ButtonEnums.Action6, 350, 450 ),
			}),
			-- multi-key press test
			KeyPress( 15, {
				CreateButtonData(Module.Enums.ButtonEnums.Action1, 450, 400),
				CreateButtonData(Module.Enums.ButtonEnums.Action2, 550, 400),
			}),
			KeyPress( 18, {
				CreateButtonData(Module.Enums.ButtonEnums.Action3, 500, 450),
				CreateButtonData(Module.Enums.ButtonEnums.Action4, 500, 400),
			}),
			KeyPress( 21, {
				CreateButtonData(Module.Enums.ButtonEnums.Action1, 450, 400),
				CreateButtonData(Module.Enums.ButtonEnums.Action2, 550, 400),
			}),
			KeyPress( 24, {
				CreateButtonData(Module.Enums.ButtonEnums.Action3, 500, 450),
				CreateButtonData(Module.Enums.ButtonEnums.Action4, 500, 400),
			}),
			KeyPress( 27, {
				CreateButtonData(Module.Enums.ButtonEnums.Action1, 500, 450),
				CreateButtonData(Module.Enums.ButtonEnums.Action2, 550, 400),
				CreateButtonData(Module.Enums.ButtonEnums.Action3, 500, 400),
				CreateButtonData(Module.Enums.ButtonEnums.Action4, 450, 400),
			}),
			CreateSliderData(30, {
				SliderPress( Module.Enums.ButtonEnums.Action5, 350, 400 ),
			}),
			CreateSliderData(33, {
				SliderPress( Module.Enums.ButtonEnums.Action6, 350, 450 ),
			}),
			-- single key hold tests
			KeyHold( 36, {
				CreateButtonData(Module.Enums.ButtonEnums.Action1, 500, 450),
			}),
			KeyHold( 39, {
				CreateButtonData(Module.Enums.ButtonEnums.Action2, 550, 400),
			}),
			KeyHold( 42, {
				CreateButtonData(Module.Enums.ButtonEnums.Action3, 500, 400),
			}),
			KeyHold( 45, {
				CreateButtonData(Module.Enums.ButtonEnums.Action4, 450, 400),
			}),
			CreateSliderData(48, {
				SliderHold( Module.Enums.ButtonEnums.Action5, 350, 400, 400, 400, 4 ),
			}),
			CreateSliderData(51, {
				SliderHold( Module.Enums.ButtonEnums.Action6, 350, 450, 400, 450, 4 ),
			}),
			-- multi-key hold test
			KeyHold( 54, {
				CreateButtonData(Module.Enums.ButtonEnums.Action1, 450, 400),
				CreateButtonData(Module.Enums.ButtonEnums.Action2, 550, 400),
			}),
			KeyHold( 57, {
				CreateButtonData(Module.Enums.ButtonEnums.Action3, 500, 450),
				CreateButtonData(Module.Enums.ButtonEnums.Action4, 500, 400),
			}),
			KeyHold( 60, {
				CreateButtonData(Module.Enums.ButtonEnums.Action1, 450, 400),
				CreateButtonData(Module.Enums.ButtonEnums.Action2, 550, 400),
			}),
			KeyHold( 63, {
				CreateButtonData(Module.Enums.ButtonEnums.Action3, 500, 450),
				CreateButtonData(Module.Enums.ButtonEnums.Action4, 500, 400),
			}),
			KeyHold( 66, {
				CreateButtonData(Module.Enums.ButtonEnums.Action1, 500, 450),
				CreateButtonData(Module.Enums.ButtonEnums.Action2, 550, 400),
				CreateButtonData(Module.Enums.ButtonEnums.Action3, 500, 400),
				CreateButtonData(Module.Enums.ButtonEnums.Action4, 450, 400),
			}),
			CreateSliderData(69, {
				SliderHold( Module.Enums.ButtonEnums.Action5, 350, 400, 400, 400, 4 ),
				SliderHold( Module.Enums.ButtonEnums.Action6, 350, 450, 400, 450, 4 ),
			}),
			CreateSliderData(72, {
				SliderHold( Module.Enums.ButtonEnums.Action5, 350, 400, 400, 400, 4 ),
				SliderHold( Module.Enums.ButtonEnums.Action6, 350, 450, 400, 450, 4 ),
			}),
		},
	},

}

-- sort nodes by timestamp
for _, data in Module.Songs do
	table.sort(data.Nodes, function(A, B)
		return A.Timestamp < B.Timestamp
	end)
end

function Module.GetSongIndex( songId : string, difficulty : number ) : number?
	for index, data : SongData in Module.Songs do
		if data.SongId == songId and data.Difficulty == difficulty then
			return index
		end
	end
	return nil
end

function Module.GetSpeedMultiplier( speedEnum : number ) : number
	if speedEnum == Module.Enums.SpeedLevel.Slow3 then
		return Module.GlobalConfig.SpeedMultipliers.Slow3
	elseif speedEnum == Module.Enums.SpeedLevel.Slow2 then
		return Module.GlobalConfig.SpeedMultipliers.Slow3
	elseif speedEnum == Module.Enums.SpeedLevel.Slow1 then
		return Module.GlobalConfig.SpeedMultipliers.Slow3
	elseif speedEnum == Module.Enums.SpeedLevel.Fast1 then
		return Module.GlobalConfig.SpeedMultipliers.Fast1
	elseif speedEnum == Module.Enums.SpeedLevel.Fast2 then
		return Module.GlobalConfig.SpeedMultipliers.Fast2
	elseif speedEnum == Module.Enums.SpeedLevel.Fast3 then
		return Module.GlobalConfig.SpeedMultipliers.Fast3
	elseif speedEnum == Module.Enums.SpeedLevel.Fast4 then
		return Module.GlobalConfig.SpeedMultipliers.Fast4
	end
	return Module.GlobalConfig.SpeedMultipliers.Normal
end

function Module.GetExpectedDuration( nodes : { PressButtonNode | HoldButtonNode | SliderDataNode | SpeedNode } ) : (number, number)
	local ExpectedFinish : number = 0
	local Speed : number = Module.GlobalConfig.SpeedMultipliers.Normal
	local LastTimestamp : number = 0
	for index, note in ipairs( nodes ) do
		if note.NodeType == Module.Enums.NodeType.Speed then
			ExpectedFinish += (note.Timestamp - LastTimestamp) * (1 / Speed)
			Speed = Module.GetSpeedMultiplier(note.Speed)
			LastTimestamp = note.Timestamp
		elseif index == #nodes then
			ExpectedFinish += (note.Timestamp - LastTimestamp) * (1 / Speed)
		end
	end
	return ExpectedFinish, nodes[#nodes].Timestamp
end

function Module.GetPointsFromActionPress( actionEnum : number ) : number
	if actionEnum == Module.Enums.ButtonEnums.Action1 then
		return Module.PointValues.Press.Action1
	elseif actionEnum == Module.Enums.ButtonEnums.Action2 then
		return Module.PointValues.Press.Action2
	elseif actionEnum == Module.Enums.ButtonEnums.Action3 then
		return Module.PointValues.Press.Action3
	elseif actionEnum == Module.Enums.ButtonEnums.Action4 then
		return Module.PointValues.Press.Action4
	elseif actionEnum == Module.Enums.ButtonEnums.Action5 then
		return Module.PointValues.Press.Action5
	elseif actionEnum == Module.Enums.ButtonEnums.Action6 then
		return Module.PointValues.Press.Action6
	end
	return 0
end

function Module.GetPointsFromActionHold( actionEnum : number ) : number
	if actionEnum == Module.Enums.ButtonEnums.Action1 then
		return Module.PointValues.Hold.Action1
	elseif actionEnum == Module.Enums.ButtonEnums.Action2 then
		return Module.PointValues.Hold.Action2
	elseif actionEnum == Module.Enums.ButtonEnums.Action3 then
		return Module.PointValues.Hold.Action3
	elseif actionEnum == Module.Enums.ButtonEnums.Action4 then
		return Module.PointValues.Hold.Action4
	elseif actionEnum == Module.Enums.ButtonEnums.Action5 then
		return Module.PointValues.Hold.Action5
	elseif actionEnum == Module.Enums.ButtonEnums.Action6 then
		return Module.PointValues.Hold.Action6
	end
	return 0
end

function Module.CalculateMaximumPoints( nodes : { PressButtonNode | HoldButtonNode | SliderDataNode | SpeedNode } )
	local maximumPoints : number = 0
	local lastActionCache = {}

	local function CheckOngoingValue(item : { Action : number, Timestamp : number })
		local ongoingAction = lastActionCache[item.Action]
		if not ongoingAction then
			return
		end
		local maxDuration : number = (item.Timestamp - ongoingAction.Timestamp)
		if maxDuration < ongoingAction.Duration then
			-- released early for next item
			local delta = math.clamp( maxDuration / ongoingAction.Duration, 0, 1 )
			local points = Module.GetPointsFromActionPress( item.Action ) * delta
			points = math.round(points)
			maximumPoints += points
		else -- completed the full hold
			maximumPoints += Module.GetPointsFromActionPress( item.Action )
		end
	end

	for _, node in nodes do
		if node.PressType == Module.Enums.PressTypes.Press then
			if node.NodeType == Module.Enums.NodeType.Button then
				for _, key in node.Keybinds do
					maximumPoints += Module.GetPointsFromActionPress( key.Action )
					CheckOngoingValue(key)
					lastActionCache[key.Action] = nil
				end
			elseif node.NodeType == Module.Enums.NodeType.Slider then
				for _, slider in node.Sliders do
					maximumPoints += Module.GetPointsFromActionPress( slider.Action )
					CheckOngoingValue(slider)
					lastActionCache[slider.Action] = nil
				end
			end
		elseif node.PressType == Module.Enums.PressTypes.Hold then
			if node.NodeType == Module.Enums.NodeType.Button then
				for _, key in node.Keybinds do
					CheckOngoingValue(key)
					lastActionCache[key.Action] = key
				end
			elseif node.NodeType == Module.Enums.NodeType.Slider then
				for _, slider in node.Sliders do
					CheckOngoingValue(slider)
					lastActionCache[slider.Action] = slider
				end
			end
		end
	end

	return maximumPoints
end

function Module.GetConfigFromIndex( index : number ) : SongData?
	return Module.Songs[ index ]
end

return Module
