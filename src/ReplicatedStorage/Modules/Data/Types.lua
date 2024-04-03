
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

return true