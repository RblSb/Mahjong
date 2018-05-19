package;

class Lang {

	static var EN:Map<String, String> = [
		"loading" => "Loading...",
		"yes" => "Yes",
		"no" => "No",
		"on" => "On",
		"off" => "Off",
	];
	static var RU:Map<String, String> = [
		"loading" => "Загрузка...",
		"yes" => "Да",
		"no" => "Нет",
		"on" => "Вкл",
		"off" => "Выкл",
	];
	static var current(default, null):Map<String, String>;
	public static var langs(default, null) = ["en", "ru"];
	public static var iso(default, null):String;
	public static var fontGlyphs(default, null):Array<Int>;
	
	public static function init() {
		var iso = "en";
		#if kha_html5
		iso = js.Browser.navigator.language;
		#elseif cpp
		//iso = untyped __cpp__('std::locale("").name()');
		#end
		var exist = false;
		for (lang in langs)
			if (lang == iso) exist = true;
		
		if (!exist) iso = "en";
		iso = iso.substring(0, 2);
		set(iso);
	}
	
	public static function get(id:String) {
		var s = current[id];
		if (s == null) {
			s = EN[id];
			if (s == null) return id;
		}
		return s;
	}
	
	public static function set(id:String) {
		iso = id;
		fontGlyphs = [];
		for (i in 32...256) {
			fontGlyphs.push(i);
		}
		
		switch(iso) {
			case "ru": current = RU;
			for (i in 1024...1106) { //1024...1280
				fontGlyphs.push(i);
			}
			default: current = EN;
		}
	}
	
	public static inline function fastGet(id:String) {
		return current[id];
	}
	
}
