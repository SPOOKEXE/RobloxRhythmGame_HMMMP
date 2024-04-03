
export type KeyPressData = {
	Action : number,
	X : number,
	Y : number
}

export type BaseNode = {
	NodeType : number,
	Timestamp : number,
}

export type PressButtonNode = BaseNode & {
	PressType : number,
	Keybinds : { KeyPressData },
}

export type HoldButtonNode = PressButtonNode & {
	Duration : number,
}

export type SliderParams = {
	Action : number,
	PressType : number,
	X : number,
	Y : number
}

export type SliderHoldParams = {
	Action : number,
	PressType : number,
	SX : number,
	SY : number,
	FX : number,
	FY : number,
	Duration : number
}

export type SliderDataNode = {
	NodeType : number,
	Timestamp : number,
	Sliders : { SliderParams | SliderHoldParams }
}

export type SpeedNode = BaseNode & {
	Speed : number,
}

export type SongData = {
	AspectRatio : number,
	Sound : { SoundId : string, Volume : number, TimePosition : number },
	Nodes : { PressButtonNode | HoldButtonNode | SliderDataNode | SpeedNode }
}

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

	TestSong1 = {
		AspectRatio = (1920 / 1080),
		Sound = {
			SoundId = "rbxassetid://-1",
			TimePosition = 0,
			Volume = 0.2,
		},
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
for _, songData in pairs(Module.Songs) do
	table.sort(songData.NoteData, function(A, B)
		return A.Timestamp < B.Timestamp
	end)
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
	-- speedEnum == Module.Enums.SpeedLevel.Normal or 'unknown'
	return Module.GlobalConfig.SpeedMultipliers.Normal
end

function Module.GetExpectedDuration( nodes : { PressButtonNode | HoldButtonNode | SliderDataNode | SpeedNode } ) : (number, number)
	local ExpectedFinish : number = 0
	local Speed : number = 1
	local LastTimestamp : number = 0
	for _, note in ipairs( nodes ) do
		if note.Type == "Speed" then
			Speed = Module.GetSpeedMultiplier(note.Speed)
		elseif note.Type == "Action" then
			ExpectedFinish += (note.Timestamp - LastTimestamp) * (1/Speed)
			LastTimestamp = note.Timestamp
		end
	end
	return ExpectedFinish, nodes[#nodes].Timestamp
end

function Module.GetConfigFromId( songId : string ) : SongData
	return Module.Songs[ songId ]
end

return Module
