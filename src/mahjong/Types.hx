package mahjong;

abstract Tiles34(Array<Int>) from Array<Int> {
	
	inline public function new(i:Array<Int>) {
		this = i;
	}
	
	public inline function iterator():Iterator<Int> {
		return this.iterator();
	}
	
	public inline function copy():Array<Int> {
		return this.copy();
	}
	
	@:arrayAccess
	public inline function get(key:Int):Int {
		return this[key];
	}
	@:arrayAccess
	public inline function set(k:Int, v:Int):Int {
		this[k] = v;
		return v;
	}
	
	public function toTiles136():Tiles136 {
		var temp = [];
		var results = [];
		for (x in 0...34) {
			if (this[x] != 0) {
				var temp_value = [for (i in 0...this[x]) x * 4];
				for (tile in temp_value) {
					if (results.indexOf(tile) != -1) {
						var count_of_tiles = [for (x in temp) if (x == tile) x].length;
						var new_tile = tile + count_of_tiles;
						results.push(new_tile);
						temp.push(tile);
					} else {
						results.push(tile);
						temp.push(tile);
					}
				}	
			}
		}
		return results;
	}
	
	public static function fromString(data:StringTiles):Tiles34 {
		return Tiles136.fromString(data).toTiles34();
	}
	
	public static function fromArray(tiles:Array<Int>):Tiles34 {
		var arr:Array<Int> = [for (i in 0...34) 0];
		for (type in tiles) arr[type]++;
		return arr;
	}
	
	public inline function toArray():Array<Int> {
		return this;
	}
	
	public function toString():String {
		return (this:Tiles34).toTiles136().toString();
	}
	
}

typedef StringTiles = {
	?sou:String,
	?pin:String,
	?man:String,
	?honors:String
}

abstract Tiles136(Array<Int>) from Array<Int> {
	
	inline public function new(i:Array<Int>) {
		this = i;
	}
	
	public static function fromString(data:StringTiles):Tiles136 {
		function split_string(string:Null<String>, offset:Int):Array<Int> {
			var data:Array<Int> = [];
			var temp:Array<Int> = [];
			if (string == null) return [];
			
			for (i in string.split("")) {
				var tile = offset + (Std.parseInt(i) - 1) * 4;
				if (data.indexOf(tile) != -1) {
					var count_of_tiles = [for (x in temp) if (x == tile) x].length;
					var new_tile = tile + count_of_tiles;
					data.push(new_tile);
					temp.push(tile);
				} else {
					data.push(tile);
					temp.push(tile);
				}
			}
			return data;
		}
		
		var results = split_string(data.man, 0);
		results = results.concat(split_string(data.pin, 36));
		results = results.concat(split_string(data.sou, 72));
		results = results.concat(split_string(data.honors, 108));
		return results;
	}
	
	public function toTiles34():Tiles34 {
		var results = [for (i in 0...34) 0];
		for (tile in this) {
			var id = Std.int(tile / 4);
			results[id] += 1;
		}
		return results;
	}
	
	public inline function toArray():Array<Int> {
		return this;
	}
	
	public function toString():String {
		var tiles = this.copy();
		tiles.sort(function(a, b):Int {
			if (a < b) return -1;
			else if (a > b) return 1;
			return 0;
		});
		
		var man = [for (t in tiles) if (t < 36) t];
		
		var pin = [for (t in tiles) if (36 <= t && t < 72) t];
		pin = [for (t in pin) t - 36];
		
		var sou = [for (t in tiles) if (72 <= t && t < 108) t];
		sou = [for (t in sou) t - 72];
		
		var honors = [for (t in tiles) if (t >= 108) t];
		honors = [for (t in honors) t - 108];
		
		return ""
		+ (if (man.length != 0) [for (i in man) (Std.int(i / 4) + 1)].join("") + 'm' else '')
		+ (if (pin.length != 0) [for (i in pin) (Std.int(i / 4) + 1)].join("") + 'p' else '')
		+ (if (sou.length != 0) [for (i in sou) (Std.int(i / 4) + 1)].join("") + 's' else '')
		+ (if (honors.length != 0) [for (i in honors) (Std.int(i / 4) + 1)].join("") + 'z' else '');
	}
	
}