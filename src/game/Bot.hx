package game;

import Types.Position;
import mahjong.Types;

class Bot extends AbstractPlayer {
	
	var isOpenHand = false;
	
	public function new(game:Game, pos:Position) {
		super(game, pos);
	}
	
	override function onDiscardTile():Void {
		sortHand(hand);
		discardTile(selectTile());
		sortHand(hand);
		endTurn();
		
		if (isKanDiscard) {
			game.openKandora();
			isKanDiscard = false;
		}
		if (!isOpenHand) isOpenHand = isBuildOpenHand();
	}
	
	override function onTsumo():Void {
		game.winDeal(this);
	}
	
	override function onClosedKan(type:Int):Void {
		makeClosedKan(type);
	}
	
	override function onRonAnswer():Void {
		game.winDeal(this);
	}
	
	override function onKanAnswer():Void {
		if (!isOpenHand) {
			game.endAnswer();
			return;
		}
		var hand34 = countTiles(hand);
		var melds34:Array<Tiles34> = [
			for (meld in melds) [for (tile in meld) tile.type]
		];
		var currentShanten = game.getShanten(hand34, melds34);
		var last = game.lastDiscardedTile().type;
		
		var hand34 = countTiles(hand);
		var meld = [last, last, last, last];
		for (i in 0...3) hand34.remove(last);
		melds34.push(meld); //add temp meld and check shanten
		if (currentShanten >= game.getShanten(hand34, melds34)) {
			makeKan(meld);
			return;
		}
		game.endAnswer();
	}
	
	override function onPonAnswer():Void {
		if (!isOpenHand) {
			game.endAnswer();
			return;
		}
		var hand34 = countTiles(hand);
		var melds34:Array<Tiles34> = [
			for (meld in melds) [for (tile in meld) tile.type]
		];
		var currentShanten = game.getShanten(hand34, melds34);
		var last = game.lastDiscardedTile().type;
		
		var hand34 = countTiles(hand);
		var meld = [last, last, last];
		for (i in 0...2) hand34.remove(last);
		melds34.push(meld); //add temp meld and check shanten
		if (currentShanten >= game.getShanten(hand34, melds34)) {
			makePon(meld);
			return;
		}
		game.endAnswer();
	}
	
	override function onChiAnswer(options:Array<Tiles34>):Void {
		if (!isOpenHand) {
			game.endAnswer();
			return;
		}
		var hand34 = countTiles(hand);
		var melds34:Array<Tiles34> = [
			for (meld in melds) [for (tile in meld) tile.type]
		];
		var currentShanten = game.getShanten(hand34, melds34);
		var last = game.lastDiscardedTile().type;
		
		for (meld in options) {
			var hand34 = countTiles(hand);
			//remove meld tiles from temp hand
			for (type in meld) if (type != last) hand34.remove(type);
			melds34.push(meld); //add temp meld and check shanten
			if (currentShanten >= game.getShanten(hand34, melds34)) {
				makeChi(meld);
				return;
			}
			melds34.pop();
		}
		game.endAnswer();
	}
	
	function isBuildOpenHand():Bool {
		var handCounts = countTiles(hand);
		for (i in 0...handCounts.length) {
			var count = handCounts[i];
			if (i < 9 * 3) {
				if (count > 2) return true;
			} else if (count > 1) {
				//pair of dragons
				if (i >= 9 * 3 + 4) return true;
				//own wind or round wind
				if (i == wind || i == game.roundWind) return true;
			}
		}
		return false;
	}
	
	inline function removeLockedTiles():Void {
		var i = 0;
		while(i < hand.length) {
			var tile = hand[i];
			if (tile.locked) hand.remove(tile);
			else i++;
		}
	}
	
	function selectTile():Int {
		var tempHand = hand.copy();
		for (tile in tempHand) {
			if (tile.locked) hand.remove(tile);
		}
		//removeLockedTiles();
		if (hand.length == 0) {
			trace("dead hand " + [for (tile in hand) tile.type]);
			hand = tempHand; //TODO dead hand
		}
		
		var visible = game.getVisibleTiles();
		var handCounts = countTiles(hand);
		
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
		
		var type = hand[id].type;
		hand = tempHand;
		for (i in 0...hand.length) {
			if (hand[i].type == type) return i;
		}
		trace("unknown id");
		throw id;
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
	
	function deadTiles(visible:Tiles34):Int {
		for (id in 0...hand.length) {
			var type = hand[id].type;
			if (visible[type] != 3) continue;
			if (type >= 9 * 3) return id; //honors
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
			if (type >= 9 * 3) return id; //honors
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
		var tileCounts:Array<Int> = countInts(tiles);
		
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
