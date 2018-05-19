package game;

import Types.Position;
import mahjong.Types;

class Bot extends AbstractPlayer {
	
	public function new(game:Game, pos:Position) {
		super(game, pos);
	}
	
	override function onDiscardTile():Void {
		if (game.checkWin(hand)) {
			game.winDeal(this);
			return;
		}
		sortHand(hand);
		discardTile(selectTile());
		sortHand(hand);
		endTurn();
	}
	
	function selectTile():Int {
		var visible = game.getVisibleTiles();
		//trace(visible.toArray());
		var handCounts:Array<Int> = [for (i in 0...34) 0];
		for (tile in hand) handCounts[tile.type]++;
		
		var id = deadTiles(visible);
		if (id == -1) id = problemTiles(visible, handCounts);
		if (id == -1) id = deadIncompleteChi(visible, handCounts);
		if (id == -1) id = secondDeadPair(visible, handCounts);
		if (id == -1) id = singleNumber(visible, handCounts);
		if (id == -1) id = singleHonor(visible, handCounts);
		if (id == -1) id = minorNumber(visible, handCounts);
		
		if (id == -1) {
			trace("random tile discard");
			trace(Tiles34.fromArray([for (tile in hand) tile.type]));
			id = Std.random(hand.length);
		}
		return id;
	}
	
	function handWithoutCombos(handCounts:Tiles34):Tiles34 {
		var handCounts = handCounts.copy();
		var hand = [for (tile in hand) tile.type];
		var tiles:Array<Int> = [];
		var hasPair = false;
		var id = 0;
		
		while (id < hand.length) {
			var type = hand[id];
			if (handCounts[type] > 2) { //pon/kan
				for (i in 0...handCounts[type]) tiles.push(hand.splice(id, 1)[0]);
				handCounts[type] = 0;
					
			} else if (handCounts[type] == 2 && !hasPair) { //TODO dora priority
				for (i in 0...2) tiles.push(hand.splice(id, 1)[0]);
				handCounts[type] = 0;
				hasPair = true;
					
			} else if (
				id < 9 * 3 && id + 2 < hand.length &&
			(handCounts[type+1] > 0 && handCounts[type+2] > 0 && isOneType(type, type + 2)) //chi
			) {
					for (i in 0...3) {
						var nextId = hand.indexOf(type + i);
						if (nextId == -1) throw hand + "" + (type + i);
						tiles.push(hand.splice(nextId, 1)[0]);
						handCounts[type+i]--;
					}
				}
			 else id++;
		}
		//trace(hand, tiles);
		return hand;
	}
	
	function consTile(hand:Array<Tile>, id:Int, i:Int):Bool { //consecutive check
		if (id + i > -1 && id + i < hand.length) {
			if (isOneType(hand[id].type, hand[id+i].type))
				if (hand[id+i].type == hand[id].type + i) return true;
		}
		return false;
	}
	
	inline function isOneType(type:Int, type2:Int) {
		return Math.floor(type / 9) == Math.floor(type2 / 9);
	}
	
	function deadTiles(visible:Tiles34):Int {
		for (id in 0...hand.length) {
			var type = hand[id].type;
			if (visible[type] != 3) continue;
			if (type >= 9 * 3) return id; //terminals
			//numbers
			var number = type % 9 + 1;
			if (number == 1) {
				if (visible[type+1] == 4) return id;
			} else if (number == 9) {
				if (visible[type-1] == 4) return id;
			} else {
				if (visible[type-1] == 4 && visible[type+1] == 4) return id;
			}
		}
		return -1;
	}
	
	function problemTiles(visible:Tiles34, handCounts:Tiles34):Int {
		for (id in 0...hand.length) {
			var type = hand[id].type;
			if (handCounts[type] != 1 || visible[type] != 2) continue;
			if (type >= 9 * 3) return id; //terminals
			//numbers
			var number = type % 9 + 1;
			if (number == 1) {
				if (visible[type+1] == 4) return id;
			} else if (number == 9) {
				if (visible[type-1] == 4) return id;
			} else {
				if (visible[type-1] == 4 && visible[type+1] == 4) return id;
			}
		}
		return -1;
	}
	
	function deadIncompleteChi(visible:Tiles34, handCounts:Tiles34):Int {
		if (hand.length < 2) return -1;
		
		for (id in 1...hand.length) {
			var type = hand[id].type;
			if (type >= 9 * 3) continue;
			//not consecutive numbers or different types
			if (!isOneType(type, type - 1) || handCounts[type-1] == 0) continue;
			var startTile = hand[id].type - 2;
			var endTile = hand[id].type + 1;
			//not in hand, all in visible tiles
			if ((isOneType(startTile, type) && visible[startTile] != 4)
				|| (isOneType(endTile, type) && visible[endTile] != 4)) continue;
			//dont discard tile from pair/pon/kan
			if (handCounts[type-1] == 1) return id - 1;
			if (handCounts[type] == 1) return id;
		}
		return -1;
	}
	
	function secondDeadPair(visible:Tiles34, handCounts:Tiles34):Int {
		if (hand.length < 4) return -1;
		//TODO dora/etc pair priority
		var second = false;
		
		for (id in 0...hand.length) {
			var type = hand[id].type;
			if (handCounts[type] != 2 || visible[type] != 2) continue;
			if (!second) second = true;
			else return id;
		}
		return -1;
	}
	
	function singleNumber(visible:Tiles34, handCounts:Tiles34):Int {
		for (id in 0...hand.length) {
			var type = hand[id].type;
			if (type >= 9 * 3) continue;
			if (handCounts[type] > 1) continue;
			if (consTile(hand, id, -1) || consTile(hand, id, 1)
				|| consTile(hand, id, -2) || consTile(hand, id, 2)) continue;
			return id;
		}
		return -1;
	}
	
	function singleHonor(visible:Tiles34, handCounts:Tiles34):Int {
		for (id in 0...hand.length) {
			var type = hand[id].type;
			if (type < 9 * 3) continue;
			if (handCounts[type] == 1) return id;
		}
		return -1;
	}
	
	function minorNumber(visible:Tiles34, handCounts:Tiles34):Int {
		var tiles = handWithoutCombos(handCounts).toArray();
		var tileCounts:Array<Int> = [for (i in 0...34) 0];
		for (type in tiles) tileCounts[type]++;
		
		if (tiles.length == 0) {
			trace("only combos");
			return -1;
		}
		var tileType = -1;
		
		for (id in 0...tiles.length) { //far from chi tiles
			var type = tiles[id];
			if (type >= 9 * 3) continue;
			if (tileCounts[type] > 1) continue;
			if (consTile(hand, id, -1) || consTile(hand, id, 1)
				|| consTile(hand, id, -2) || consTile(hand, id, 2)) continue;
			tileType = type;
			break;
		}
		
		if (tileType == -1) tileType = incompleteChi(tiles, tileCounts);
		if (tileType == -1) tileType = incompletePair(visible, handCounts, tiles, tileCounts);
		if (tileType == -1) {
			trace("dont know what discard here");
			trace([for (tile in hand) tile.type] + " " + tiles);
			tileType = tiles[0];
		}
		
		for (id in 0...hand.length) {
			if (hand[id].type == tileType) return id;
		}
		
		trace("tile " + tileType + " not found");
		trace([for (tile in hand) tile.type] + " " + tiles);
		return -1;
	}
	
	function incompleteChi(tiles:Array<Int>, tileCounts:Tiles34):Int {
		for (id in 0...tiles.length) { //edge
			var type = tiles[id];
			if (type >= 9 * 3) continue;
			if (tileCounts[type] > 1) continue;
			if (consTile(hand, id, -1) || consTile(hand, id, 1)) continue;
			return type;
		}
		
		for (id in 0...tiles.length) { //any
			var type = tiles[id];
			if (type >= 9 * 3) continue;
			if (tileCounts[type] > 1) continue;
			return type;
		}
		
		return -1;
	}
	
	function incompletePair(visible:Tiles34, handCounts:Tiles34, tiles:Array<Int>, tileCounts:Tiles34):Int {
		for (id in 0...tiles.length) { //dead
			var type = tiles[id];
			if (tileCounts[type] != 2 || visible[type] + handCounts[type] != 2) continue;
			return type;
		}
		
		for (id in 0...tiles.length) { //problem
			var type = tiles[id];
			if (tileCounts[type] != 2 || visible[type] + handCounts[type] != 1) continue;
			return type;
		}
		
		for (id in 0...tiles.length) { //any
			var type = tiles[id];
			if (tileCounts[type] != 2) continue;
			return type;
		}
		
		return -1;
	}
	
}
