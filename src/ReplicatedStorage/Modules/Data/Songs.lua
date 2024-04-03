
type KeyPressData = { Id : number, X : number, Y : number }

type BaseNode = { NodeType : number, Timestamp : number, }

type ButtonNode = BaseNode & { PressType : number, Keybinds : { KeyPressData }, }
type PressButtonNode = ButtonNode
type HoldButtonNode = ButtonNode & { Duration : number, }

type SliderNode = { PressType : number, Id : string, X : number, Y : number }
type SliderHoldNode = { PressType : number, Id : string, SX : number, SY : number, FX : number, FY : number, Duration : number }

type SpeedNode = BaseNode & { Speed : number, }

type SongData = {
	AspectRatio : number,
	Sound : { SoundId : string, Volume : number, TimePosition : number },
	Nodes : { PressButtonNode | HoldButtonNode | SliderNode | SliderHoldNode | SpeedNode }
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

	-- Module.Enums.SpeedLevel
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
		Action0 = 100,
		Action1 = 100,
		Action2 = 100,
		Action3 = 100,
		Action4 = 100,
		Action5 = 100,
		Action6 = 100,
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

local function CreateButtonData( Id : number, Rotation : number, X : number, Y : number ) : KeyPressData
	return { Id = Id, Rotation = Rotation, X = X, Y = Y }
end

local function CreateSpeed( timestamp : number, speed : number ) : SpeedNode
	return { NodeType = Module.Enums.NodeType.Speed, Timestamp = timestamp, Speed = speed, }
end

local function KeyPress( timestamp : number, keybinds : { KeyPressData } ) : PressButtonNode
	return { NodeType = Module.Enums.NodeType.Button, PressType = Module.Enums.PressTypes.Press, Timestamp = timestamp, Keybinds = keybinds, }
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

local function CreateSliderPress( actionButton : number, x : number, y : number ) : SliderNode
	return { Id = actionButton, NodeType = Module.Enums.NodeType.Slider, PressType = Module.Enums.PressTypes.Press, X = x, Y = y, }
end

local function CreateSliderHold( actionButton : number, sx : number, sy : number, fx : number, fy : number, duration : number ) : SliderHoldNode
	return {
		Id = actionButton,
		NodeType = Module.Enums.NodeType.Slider,
		PressType = Module.Enums.PressTypes.Hold,
		SX = sx,
		SY = sy,
		FX = fx,
		FY = fy,
		Duration = Module.DefaultSliderHoldDuration or duration,
	}
end

local function SliderData( timestamp : number, sliders : { SliderNode | SliderHoldNode } )
	return { NodeType = Module.Enums.NodeType.Slider, Timestamp = timestamp, Sliders = sliders, }
end

Module.Songs = {

	TestSong1 = {
		AspectRatio = (1920 / 1080),
		Sound = { SoundId = "rbxassetid://-1", TimePosition = 0, },
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
			SliderData(45, {
				CreateSliderPress( Module.Enums.ButtonEnums.Action5, 350, 400 ),
			}),
			SliderData(48, {
				CreateSliderPress( Module.Enums.ButtonEnums.Action6, 350, 450 ),
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
			SliderData(45, {
				CreateSliderPress( Module.Enums.ButtonEnums.Action5, 350, 400 ),
			}),
			SliderData(48, {
				CreateSliderPress( Module.Enums.ButtonEnums.Action6, 350, 450 ),
			}),
			-- single key hold tests
			KeyHold( 33, {
				CreateButtonData(Module.Enums.ButtonEnums.Action1, 500, 450),
			}),
			KeyHold( 36, {
				CreateButtonData(Module.Enums.ButtonEnums.Action2, 550, 400),
			}),
			KeyHold( 39, {
				CreateButtonData(Module.Enums.ButtonEnums.Action3, 500, 400),
			}),
			KeyHold( 42, {
				CreateButtonData(Module.Enums.ButtonEnums.Action4, 450, 400),
			}),
			SliderData(45, {
				CreateSliderHold( Module.Enums.ButtonEnums.Action5, 350, 400, 400, 400, 4 ),
			}),
			SliderData(48, {
				CreateSliderHold( Module.Enums.ButtonEnums.Action6, 350, 450, 400, 450, 4 ),
			}),
			-- multi-key hold test
			KeyHold( 45, {
				CreateButtonData(Module.Enums.ButtonEnums.Action1, 450, 400),
				CreateButtonData(Module.Enums.ButtonEnums.Action2, 550, 400),
			}),
			KeyHold( 48, {
				CreateButtonData(Module.Enums.ButtonEnums.Action3, 500, 450),
				CreateButtonData(Module.Enums.ButtonEnums.Action4, 500, 400),
			}),
			KeyHold( 51, {
				CreateButtonData(Module.Enums.ButtonEnums.Action1, 450, 400),
				CreateButtonData(Module.Enums.ButtonEnums.Action2, 550, 400),
			}),
			KeyHold( 54, {
				CreateButtonData(Module.Enums.ButtonEnums.Action3, 500, 450),
				CreateButtonData(Module.Enums.ButtonEnums.Action4, 500, 400),
			}),
			KeyHold( 57, {
				CreateButtonData(Module.Enums.ButtonEnums.Action1, 500, 450),
				CreateButtonData(Module.Enums.ButtonEnums.Action2, 550, 400),
				CreateButtonData(Module.Enums.ButtonEnums.Action3, 500, 400),
				CreateButtonData(Module.Enums.ButtonEnums.Action4, 450, 400),
			}),
			SliderData(30, {
				CreateSliderHold( Module.Enums.ButtonEnums.Action5, 350, 400, 400, 400, 4 ),
				CreateSliderHold( Module.Enums.ButtonEnums.Action6, 350, 450, 400, 450, 4 ),
			}),
			SliderData(30, {
				CreateSliderHold( Module.Enums.ButtonEnums.Action5, 350, 400, 400, 400, 4 ),
				CreateSliderHold( Module.Enums.ButtonEnums.Action6, 350, 450, 400, 450, 4 ),
			}),
		},
	},

}

return Module
