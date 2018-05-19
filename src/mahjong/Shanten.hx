package mahjong;

import mahjong.Types;
import mahjong.Utils.find_isolated_tile_indices;

class Shanten {
	
	public static inline var AGARI_STATE = -1;
	var tiles:Tiles34;
	var number_melds = 0;
	var number_tatsu = 0;
	var number_pairs = 0;
	var number_jidahai = 0;
	var number_characters = 0;
	var number_isolated_tiles = 0;
	var min_shanten = 0;
	
	public function new() {}
	
	public function calculate_shanten(tiles34:Tiles34, ?open_sets:Array<Tiles34>):Int {
		/* Return the count of tiles before tempai */
		var tiles34 = tiles34.copy();
		init(tiles34);
		
		var count_of_tiles = 0;
		for (tile in tiles34) count_of_tiles += tile;
		if (count_of_tiles > 14) return -2;
		
		//With open hand we need to remove open sets from hand and replace them with isolated pon sets
		//it will allow to calculate count of shanten correctly
		if (open_sets != null) {
			var isolated_tiles = find_isolated_tile_indices(tiles34);
			for (meld in open_sets) {
				if (isolated_tiles.length == 0) break;
				var isolated_tile = isolated_tiles.pop();
				
				tiles34[meld[0]] -= 1;
				tiles34[meld[1]] -= 1;
				tiles34[meld[2]] -= 1;
				tiles34[isolated_tile] = 3;
			}
		}
		
		if (open_sets == null) min_shanten = scan_chitoitsu_and_kokushi();
		remove_character_tiles(count_of_tiles);
		
		var init_mentsu = Math.floor((14 - count_of_tiles) / 3);
		scan(init_mentsu);
		
		return min_shanten;
	}
	
	inline function init(tiles:Tiles34):Void {
		this.tiles = tiles;
		number_melds = 0;
		number_tatsu = 0;
		number_pairs = 0;
		number_jidahai = 0;
		number_characters = 0;
		number_isolated_tiles = 0;
		min_shanten = 8;
	}
	
	inline function scan(init_mentsu:Int):Void {
		number_characters = 0;
		for (i in 0...27) number_characters |= (tiles[i] == 4 ? 1 : 0) << i;
		number_melds += init_mentsu;
		run(0);
	}
	
	function run(depth:Int):Void {
		if (min_shanten == AGARI_STATE) return;
		
		while (tiles[depth] == 0) {
			depth += 1;
			if (depth >= 27) break;
		}
		
		if (depth >= 27) return update_result();
		
		var i = depth;
		if (i > 8) i -= 9;
		if (i > 8) i -= 9;
		
		if (tiles[depth] == 4) {
			increase_set(depth);
			if (i < 7 && tiles[depth + 2] != 0) {
				if (tiles[depth + 1] != 0) {
					increase_syuntsu(depth);
					run(depth + 1);
					decrease_syuntsu(depth);
				}
				increase_tatsu_second(depth);
				run(depth + 1);
				decrease_tatsu_second(depth);
			}
			if (i < 8 && tiles[depth + 1] != 0) {
				increase_tatsu_first(depth);
				run(depth + 1);
				decrease_tatsu_first(depth);
			}
			
			increase_isolated_tile(depth);
			run(depth + 1);
			decrease_isolated_tile(depth);
			decrease_set(depth);
			increase_pair(depth);
			
			if (i < 7 && tiles[depth + 2] != 0) {
				if (tiles[depth + 1] != 0) {
					increase_syuntsu(depth);
					run(depth);
					decrease_syuntsu(depth);
				}
				increase_tatsu_second(depth);
				run(depth + 1);
				decrease_tatsu_second(depth);
			}
			if (i < 8 && tiles[depth + 1] != 0) {
				increase_tatsu_first(depth);
				run(depth + 1);
				decrease_tatsu_first(depth);
			}
			decrease_pair(depth);
		}
		
		if (tiles[depth] == 3) {
			increase_set(depth);
			run(depth + 1);
			decrease_set(depth);
			increase_pair(depth);
			
			if (i < 7 && tiles[depth + 1] != 0 && tiles[depth + 2] != 0) {
				increase_syuntsu(depth);
				run(depth + 1);
				decrease_syuntsu(depth);
			} else {
				if (i < 7 && tiles[depth + 2] != 0) {
					increase_tatsu_second(depth);
					run(depth + 1);
					decrease_tatsu_second(depth);
				}
				if (i < 8 && tiles[depth + 1] != 0) {
					increase_tatsu_first(depth);
					run(depth + 1);
					decrease_tatsu_first(depth);
				}
			}
			
			decrease_pair(depth);
			
			if (i < 7 && tiles[depth + 2] >= 2 && tiles[depth + 1] >= 2) {
				increase_syuntsu(depth);
				increase_syuntsu(depth);
				run(depth);
				decrease_syuntsu(depth);
				decrease_syuntsu(depth);
			}
		}
		
		if (tiles[depth] == 2) {
			increase_pair(depth);
			run(depth + 1);
			decrease_pair(depth);
			if (i < 7 && tiles[depth + 2] != 0 && tiles[depth + 1] != 0) {
				increase_syuntsu(depth);
				run(depth);
				decrease_syuntsu(depth);
			}
		}
		
		if (tiles[depth] == 1) {
			if (i < 6 && tiles[depth + 1] == 1 && tiles[depth + 2] != 0 && tiles[depth + 3] != 4) {
				increase_syuntsu(depth);
				run(depth + 2);
				decrease_syuntsu(depth);
			} else {
				increase_isolated_tile(depth);
				run(depth + 1);
				decrease_isolated_tile(depth);
				
				if (i < 7 && tiles[depth + 2] != 0) {
					if (tiles[depth + 1] != 0) {
						increase_syuntsu(depth);
						run(depth + 1);
						decrease_syuntsu(depth);
					}
					increase_tatsu_second(depth);
					run(depth + 1);
					decrease_tatsu_second(depth);
				}
				
				if (i < 8 && tiles[depth + 1] != 0) {
					increase_tatsu_first(depth);
					run(depth + 1);
					decrease_tatsu_first(depth);
				}
			}
		}
	}
	
	function update_result():Void {
		var ret_shanten = 8 - number_melds * 2 - number_tatsu - number_pairs;
		var n_mentsu_kouho = number_melds + number_tatsu;
		if (number_pairs != 0) n_mentsu_kouho += number_pairs - 1;
		else if (number_characters != 0 && number_isolated_tiles != 0) {
			if (number_characters | number_isolated_tiles == number_characters) {
				ret_shanten += 1;
			}
		}
		
		if (n_mentsu_kouho > 4) ret_shanten += n_mentsu_kouho - 4;
			
		if (ret_shanten != AGARI_STATE && ret_shanten < number_jidahai) {
			ret_shanten = number_jidahai;
		}
		
		if (ret_shanten < min_shanten) min_shanten = ret_shanten;
	}
	
	function increase_set(k:Int):Void {
		tiles[k] -= 3;
		number_melds += 1;
	}
	
	function decrease_set(k:Int):Void {
		tiles[k] += 3;
		number_melds -= 1;
	}
	
	function increase_pair(k:Int):Void {
		tiles[k] -= 2;
		number_pairs += 1;
	}
	
	function decrease_pair(k:Int):Void {
		tiles[k] += 2;
		number_pairs -= 1;
	}
	
	function increase_syuntsu(k:Int):Void {
		tiles[k] -= 1;
		tiles[k + 1] -= 1;
		tiles[k + 2] -= 1;
		number_melds += 1;
	}
	
	function decrease_syuntsu(k:Int):Void {
		tiles[k] += 1;
		tiles[k + 1] += 1;
		tiles[k + 2] += 1;
		number_melds -= 1;
	}
	
	function increase_tatsu_first(k:Int):Void {
		tiles[k] -= 1;
		tiles[k + 1] -= 1;
		number_tatsu += 1;
	}
	
	function decrease_tatsu_first(k:Int):Void {
		tiles[k] += 1;
		tiles[k + 1] += 1;
		number_tatsu -= 1;
	}
	
	function increase_tatsu_second(k:Int):Void {
		tiles[k] -= 1;
		tiles[k + 2] -= 1;
		number_tatsu += 1;
	}
	
	function decrease_tatsu_second(k:Int):Void {
		tiles[k] += 1;
		tiles[k + 2] += 1;
		number_tatsu -= 1;
	}
	
	function increase_isolated_tile(k:Int):Void {
		tiles[k] -= 1;
		number_isolated_tiles |= (1 << k);
	}
	
	function decrease_isolated_tile(k:Int):Void {
		tiles[k] += 1;
		number_isolated_tiles |= (1 << k);
	}
	
	function scan_chitoitsu_and_kokushi():Int {
		var shanten = min_shanten;
		
		var indices = [0, 8, 9, 17, 18, 26, 27, 28, 29, 30, 31, 32, 33];
		
		var completed_terminals = 0;
		for (i in indices) if (tiles[i] >= 2) completed_terminals++;
		
		var terminals = 0;
		for (i in indices) if (tiles[i] != 0) terminals++;
		
		indices = [1, 2, 3, 4, 5, 6, 7, 10, 11, 12, 13, 14, 15, 16, 19, 20, 21, 22, 23, 24, 25];
		
		var completed_pairs = completed_terminals;
		for (i in indices) if (tiles[i] >= 2) completed_pairs++;
		
		var pairs = terminals;
		for (i in indices) if (tiles[i] != 0) pairs++;
		
		//var ret_shanten = 6 - completed_pairs + (pairs < 7 && 7 - pairs || 0);
		var temp = (pairs < 7 && 7 - pairs != 0);
		var ret_shanten = 6 - completed_pairs + (temp ? 1 : 0);
		if (ret_shanten < shanten) shanten = ret_shanten;
		
		ret_shanten = 13 - terminals - (completed_terminals != 0 ? 1 : 0);
		if (ret_shanten < shanten) shanten = ret_shanten;
		
		return shanten;
	}
	
	function remove_character_tiles(nc:Int):Void {
		var number = 0;
		var isolated = 0;
		
		for (i in 27...34) {
			if (tiles[i] == 4) {
				number_melds += 1;
				number_jidahai += 1;
				number |= (1 << (i - 27));
				isolated |= (1 << (i - 27));
			}
			
			if (tiles[i] == 3) number_melds += 1;
			if (tiles[i] == 2) number_pairs += 1;
			if (tiles[i] == 1) isolated |= (1 << (i - 27));
		}
		if (number_jidahai != 0 && (nc % 3) == 2) number_jidahai -= 1;
		
		if (isolated != 0) {
			number_isolated_tiles |= (1 << 27);
			if (number | isolated == number) {
				number_characters |= (1 << 27);
			}
		}
	}
	
}
