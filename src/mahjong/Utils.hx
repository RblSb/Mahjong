package mahjong;

import mahjong.Constants.Wind;
import mahjong.Constants.Akadora;
import mahjong.Constants.HONOR_INDICES;
import mahjong.Constants.TERMINAL_INDICES;
import mahjong.Types.Tiles34;

class Utils {
	
	public static function find_isolated_tile_indices(hand:Tiles34):Array<Int> {
		/*
		:param hand: array of tiles in 34 tile format
		:return: array of isolated tiles indices
		*/
		var isolated_indices = [];
		for (x in 1...27) {
			// TODO handle 1-9 tiles situation to have more isolated tiles
			if (hand[x] == 0 && hand[x - 1] == 0 && hand[x + 1] == 0) {
				isolated_indices.push(x);
			}
		}
		// for honor tiles we don't need to check nearby tiles
		for (x in HONOR_INDICES) {
			if (hand[x] == 0) isolated_indices.push(x);
		}
		return isolated_indices;
	}
	
}
