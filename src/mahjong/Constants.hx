package mahjong;

@:enum abstract Terminal(Int) from Int to Int {
	var Man1 = 0;
	var Man9 = 8;
	var Pin1 = 9;
	var Pin9 = 17;
	var Sou1 = 18;
	var Sou9 = 26;
}

@:enum abstract Wind(Int) from Int to Int {
	var East = 27;
	var South = 28;
	var West = 29;
	var North = 30;
	
	public inline function toString() {
		return switch(this) {
			case East: "East";
			case South: "South";
			case West: "West";
			case North: "North";
			default: throw this;
		}
	}
}

@:enum abstract Dragon(Int) from Int to Int {
	var Chun = 33;
	var Hatsu = 32;
	var Haku = 31;
}

@:enum abstract Akadora(Int) from Int to Int {
	var RedMan5 = 16;
	var RedPin5 = 52;
	var RedSou5 = 88;
}

class Constants {
	public static var TERMINAL_INDICES = [Man1, Man9, Pin1, Pin9, Sou1, Sou9];
	public static var WINDS = [East, South, West, North];
	public static var HONOR_INDICES:Array<Int> = [East, South, West, North, Haku, Hatsu, Chun];
	public static var AKA_DORA_LIST = [RedMan5, RedPin5, RedSou5];
}
