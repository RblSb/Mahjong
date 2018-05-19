package mahjong;

class Constants {
	
	//1 and 9
	public static var TERMINAL_INDICES = [0, 8, 9, 17, 18, 26];
	
	//dragons and winds
	public static inline var EAST = 27;
	public static inline var SOUTH = 28;
	public static inline var WEST = 29;
	public static inline var NORTH = 30;
	public static inline var HAKU = 31;
	public static inline var HATSU = 32;
	public static inline var CHUN = 33;
	
	public static var WINDS = [EAST, SOUTH, WEST, NORTH];
	public static var HONOR_INDICES = [EAST, SOUTH, WEST, NORTH, HAKU, HATSU, CHUN];
	
	public static inline var FIVE_RED_MAN = 16;
	public static inline var FIVE_RED_PIN = 52;
	public static inline var FIVE_RED_SOU = 88;
	
	public static var AKA_DORA_LIST = [FIVE_RED_MAN, FIVE_RED_PIN, FIVE_RED_SOU];
	
	//@:enum abstract DISPLAY_WINDS(String) to String
	public static var DISPLAY_WINDS = {
		EAST: 'East',
		SOUTH: 'South',
		WEST: 'West',
		NORTH: 'North'
	}
	
}
