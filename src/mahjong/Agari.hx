package mahjong;

import mahjong.Utils.find_isolated_tile_indices;
import mahjong.Types.Tiles34;

class Agari {
	
	public function new() {}
	
	public function is_agari(tiles:Tiles34, ?open_sets:Array<Tiles34>):Bool {
		/* Determine was it win or not */
		var tiles = tiles.copy();
		
		if (open_sets != null) {
			var isolated_tiles = find_isolated_tile_indices(tiles);
			for (meld in open_sets) {
				if (isolated_tiles.length == 0) break;
				var isolated_tile = isolated_tiles.pop();
				
				tiles[meld[0]] -= 1;
				tiles[meld[1]] -= 1;
				tiles[meld[2]] -= 1;
				tiles[isolated_tile] = 3;
			}
		}
		
		var j = (1 << tiles[27]) | (1 << tiles[28]) | (1 << tiles[29]) | (1 << tiles[30]) | (1 << tiles[31]) | (1 << tiles[32]) | (1 << tiles[33]);
		
		if (j >= 0x10) return false;
		
		//13 orphans
		if (j & 3 == 2
			&& (tiles[0] * tiles[8] * tiles[9] * tiles[17] * tiles[18] *
			tiles[26] * tiles[27] * tiles[28] * tiles[29] * tiles[30] *
			tiles[31] * tiles[32] * tiles[33] == 2)
		) return true;
		
		//seven pairs
		if (j & 10 == 0) {
			var sum = 0;
			for (i in 0...34) if (tiles[i] == 2) sum++;
			if (sum == 7) return true;
		}
		
		if (j & 2 != 0) return false;
		
		var n00 = tiles[0] + tiles[3] + tiles[6];
		var n01 = tiles[1] + tiles[4] + tiles[7];
		var n02 = tiles[2] + tiles[5] + tiles[8];
		
		var n10 = tiles[9] + tiles[12] + tiles[15];
		var n11 = tiles[10] + tiles[13] + tiles[16];
		var n12 = tiles[11] + tiles[14] + tiles[17];
		
		var n20 = tiles[18] + tiles[21] + tiles[24];
		var n21 = tiles[19] + tiles[22] + tiles[25];
		var n22 = tiles[20] + tiles[23] + tiles[26];
		
		var n0 = (n00 + n01 + n02) % 3;
		if (n0 == 1) return false;
		
		var n1 = (n10 + n11 + n12) % 3;
		if (n1 == 1) return false;
		
		var n2 = (n20 + n21 + n22) % 3;
		if (n2 == 1) return false;
		
		var count = 0;
		if (n0 == 2) count++;
		if (n1 == 2) count++;
		if (n2 == 2) count++;
		for (i in 27...34) if (tiles[i] == 2) count++;
		if (count != 1) return false;
		
		var nn0 = (n00 * 1 + n01 * 2) % 3;
		var m0 = to_meld(tiles, 0);
		var nn1 = (n10 * 1 + n11 * 2) % 3;
		var m1 = to_meld(tiles, 9);
		var nn2 = (n20 * 1 + n21 * 2) % 3;
		var m2 = to_meld(tiles, 18);
		
		if (j & 4 != 0) return (n0 | nn0 | n1 | nn1 | n2 | nn2 == 0) && is_mentsu(m0) && is_mentsu(m1) && is_mentsu(m2);
		
		if (n0 == 2) return (n1 | nn1 | n2 | nn2 == 0) && is_mentsu(m1) && is_mentsu(m2) && is_atama_mentsu(nn0, m0);
		
		if (n1 == 2) return (n2 | nn2 | n0 | nn0 == 0) && is_mentsu(m2) && is_mentsu(m0) && is_atama_mentsu(nn1, m1);
		
		if (n2 == 2) return (n0 | nn0 | n1 | nn1 == 0) && is_mentsu(m0) && is_mentsu(m1) && is_atama_mentsu(nn2, m2);
		
		return false;
	}
	
	function is_mentsu(m:Int):Bool { //is set
		var a = m & 7;
		var b = 0;
		var c = 0;
		if (a == 1 || a == 4) {
			b = c = 1;
		} else if (a == 2) {
			b = c = 2;
		}
		m >>= 3;
		a = (m & 7) - b;
		if (a < 0) return false;
		
		var is_not_mentsu = false;
		for (x in 0...6) {
			b = c;
			c = 0;
			if (a == 1 || a == 4) {
				b += 1;
				c += 1;
			} else if (a == 2) {
				b += 2;
				c += 2;
			}
			m >>= 3;
			a = (m & 7) - b;
			if (a < 0) {
				is_not_mentsu = true;
				break;
			}
		}
		
		if (is_not_mentsu) return false;
		m >>= 3;
		a = (m & 7) - c;
		return a == 0 || a == 3;
	}
	
	function is_atama_mentsu(nn:Int, m:Int):Bool { //is pair set
		if (nn == 0) {
			if ((m & (7 << 6)) >= (2 << 6) && is_mentsu(m - (2 << 6))) return true;
			if ((m & (7 << 15)) >= (2 << 15) && is_mentsu(m - (2 << 15))) return true;
			if ((m & (7 << 24)) >= (2 << 24) && is_mentsu(m - (2 << 24))) return true;
		} else if (nn == 1) {
			if ((m & (7 << 3)) >= (2 << 3) && is_mentsu(m - (2 << 3))) return true;
			if ((m & (7 << 12)) >= (2 << 12) && is_mentsu(m - (2 << 12))) return true;
			if ((m & (7 << 21)) >= (2 << 21) && is_mentsu(m - (2 << 21))) return true;
		} else if (nn == 2) {
			if ((m & (7 << 0)) >= (2 << 0) && is_mentsu(m - (2 << 0))) return true;
			if ((m & (7 << 9)) >= (2 << 9) && is_mentsu(m - (2 << 9))) return true;
			if ((m & (7 << 18)) >= (2 << 18) && is_mentsu(m - (2 << 18))) return true;
		}
		return false;
	}
	
	function to_meld(tiles:Tiles34, d:Int):Int { //to opened set
		var result = 0;
		for (i in 0...9) result |= (tiles[d + i] << i * 3);
		return result;
	}
	
}
