
local ButtonEnums = { Press = 1, Hold = 2, }
local ButtonActions = { Action1 = 1, Action2 = 2, Action3 = 3, Action4 = 4, Action5 = 5, Action6 = 6, }
local SpeedEffects = { FastSpeed4 = 3, FastSpeed3 = 2.5, FastSpeed2 = 2, FastSpeed1 = 1.5, Normal = 1, SlowSpeed1 = 0.8, SlowSpeed2 = 0.6, SlowSpeed3 = 0.4, SlowSpeed4 = 0.2, }
local ButtonRotation = { Up = 0, Right = 1, Down = 2, Left = 3, }

type ButtonData = { Id : string, X : number, Y : number }
type ActionData = { Type : "Action", Timestamp : number, ButtonType : number, Actions : { ButtonData } }
type SpeedEffect = { Type : "Speed", Timestamp : number, Speed : number }
type NoteData = { ActionData | SpeedEffect }
type SongData = { Sound : { SoundId : string, Volume : number, TimePosition : number }, NoteData : NoteData }

local ActionTypeEnums = { Action = 1, Speed = 2, }

local function CreateButtonData( ButtonId : number, Rotation : number, X : number, Y : number ) : ButtonData
	return { Id = ButtonId, Rotation = Rotation, X = X, Y = Y }
end

local function CreateAction( Timestamp : number, ButtonEnum : number, Actions : { ButtonData } ) : ActionData
	return { Type = ActionTypeEnums.Action, Timestamp = Timestamp, ButtonType = ButtonEnum, Actions = Actions }
end

local function CreateSpeed( Timestamp : number, Speed : number ) : SpeedEffect
	return { Type = ActionTypeEnums.Speed, Timestamp = Timestamp, Speed = Speed }
end

-- // Module // --
local Module = {}

Module.ClientConfig = {
	SHOW_ACTION_BUTTON_DURATION = 3, -- (Timestamp - n) is when the button should appear
}

Module.SanityConfig = {
	PERFECT_TIME_THRESHOLD_BUTTON_PRESS = 0.1, -- must be +- this to the timestamp for it to count
	GREAT_TIME_THRESHOLD_BUTTON_PRESS = 0.15, -- must be +- this to the timestamp for it to count
	OKAY_TIME_THRESHOLD_BUTTON_PRESS = 0.2, -- must be +- this to the timestamp for it to count
}

Module.DefaultKeybinds = {
	Left = {Enum.KeyCode.Left, Enum.KeyCode.A},
	Right = {Enum.KeyCode.Right, Enum.KeyCode.D},
	Up = {Enum.KeyCode.Up, Enum.KeyCode.W},
	Down = {Enum.KeyCode.Down, Enum.KeyCode.S},
	SpecialLeft = {Enum.KeyCode.Q},
	SpecialRight = {Enum.KeyCode.E},
}

Module.Songs = {

	TestSong1 = {
		Resolution = Vector2.new(1280, 720),

		Sound = {
			SoundId = "rbxassetid://-1",
			Volume = 0,
			TimePosition = 0,
		},

		--CutsceneData = { },

		NoteData = {
			CreateSpeed( 0, SpeedEffects.FastSpeed2 ),
			CreateAction( 3, ButtonEnums.Press, {
				CreateButtonData(ButtonActions.Action1, ButtonRotation.Up, 0.475, 0.5),
			}),
			CreateAction( 4, ButtonEnums.Press, {
				CreateButtonData(ButtonActions.Action2, ButtonRotation.Right, 0.485, 0.5),
			}),
			CreateAction( 5, ButtonEnums.Press, {
				CreateButtonData(ButtonActions.Action3, ButtonRotation.Down, 0.495, 0.5),
			}),
			CreateAction( 6, ButtonEnums.Press, {
				CreateButtonData(ButtonActions.Action4, ButtonRotation.Left, 0.5, 0.5),
			}),
			CreateSpeed( 7, SpeedEffects.FastSpeed4 ),
			CreateAction( 8, ButtonEnums.Press, {
				CreateButtonData(ButtonActions.Action1, ButtonRotation.Up, 0.475, 0.5),
			}),
			CreateAction( 9, ButtonEnums.Press, {
				CreateButtonData(ButtonActions.Action2, ButtonRotation.Right, 0.485, 0.5),
			}),
			CreateAction( 10, ButtonEnums.Press, {
				CreateButtonData(ButtonActions.Action3, ButtonRotation.Down, 0.495, 0.5),
			}),
			CreateAction( 11, ButtonEnums.Press, {
				CreateButtonData(ButtonActions.Action4, ButtonRotation.Left, 0.5, 0.5),
			}),
			CreateSpeed( 12, SpeedEffects.Normal ),
			CreateAction( 14, ButtonEnums.Press, {
				CreateButtonData(ButtonActions.Action1, ButtonRotation.Up, 0.475, 0.5),
			}),
			CreateAction( 15, ButtonEnums.Press, {
				CreateButtonData(ButtonActions.Action2, ButtonRotation.Right, 0.485, 0.5),
			}),
			CreateAction( 16, ButtonEnums.Press, {
				CreateButtonData(ButtonActions.Action3, ButtonRotation.Down, 0.495, 0.5),
			}),
			CreateAction( 17, ButtonEnums.Press, {
				CreateButtonData(ButtonActions.Action4, ButtonRotation.Left, 0.5, 0.5),
			}),
			CreateAction( 18, ButtonEnums.Press, {
				CreateButtonData(ButtonActions.Action1, ButtonRotation.Up, 0.475, 0.5),
			}),
			CreateAction( 19, ButtonEnums.Press, {
				CreateButtonData(ButtonActions.Action2, ButtonRotation.Right, 0.485, 0.5),
			}),
			CreateAction( 20, ButtonEnums.Press, {
				CreateButtonData(ButtonActions.Action3, ButtonRotation.Down, 0.495, 0.5),
			}),
			CreateAction( 21, ButtonEnums.Press, {
				CreateButtonData(ButtonActions.Action4, ButtonRotation.Left, 0.5, 0.5),
			}),
		},
	},

} :: { SongData }

function Module:GetExpectedDuration( noteData : NoteData ) : (number, number)
	local ExpectedFinish = 0
	local Speed, LastTimestamp = 1, 0
	for _, note in ipairs( noteData ) do
		if note.Type == "Speed" then
			Speed = note.Speed
		elseif note.Type == "Action" then
			ExpectedFinish += (note.Timestamp - LastTimestamp) * (1/Speed)
			LastTimestamp = note.Timestamp
		end
	end
	return ExpectedFinish, noteData[#noteData].Timestamp
end

function Module:GetConfigFromId( songId : string ) : SongData
	return Module.Songs[ songId ]
end

for _, songData in pairs(Module.Songs) do
	table.sort(songData.NoteData, function(A, B)
		return A.Timestamp < B.Timestamp
	end)
end

return Module
