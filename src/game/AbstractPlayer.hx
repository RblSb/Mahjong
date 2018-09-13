package game;

import kha.graphics2.Graphics;
import kha.Image;
import kha.Assets;
import kha.Font;
import Screen.Pointer;
import Types.Rect;
import Types.Position;
import mahjong.Types;
import mahjong.Constants.Wind;
import kha.math.FastMatrix3;
using Utils.MathExtension;

enum State {
	WAIT;
	TAKE_TILE;
	TSUMO;
	CLOSED_KAN;
	DISCARD_TILE;
	RON_ANSWER;
	KAN_ANSWER;
	PON_ANSWER;
	CHI_ANSWER;
}

class AbstractPlayer {
	
	var game:Game;
	var buffer:Image;
	public var forceRender:Bool;
	public var scale:Float;
	
	public var tileCount = 14;
	public var wind:Wind;
	public var points = 30000;
	public var hand:Array<Tile> = [];
	public var melds:Array<Array<Tile>> = [];
	public var discard:Array<Tile> = [];
	public var position:Position;
	public var state:State;
	public var rect:Rect;
	var discardOffsetTop:Float;
	var isKanDiscard = false;
	
	public function new(game:Game, pos:Position) {
		this.game = game;
		position = pos;
		init();
	}
	
	function init() {
		resize();
		buffer = Image.createRenderTarget(Math.ceil(rect.w), Math.ceil(rect.h));
		
		for (i in 0...tileCount-1) takeTile();
		//hand[hand.length-1].opened = false;
		sortHand(hand);
		state = WAIT;
		forceRender = true;
	}
	
	function takeTile():Void {
		var type = game.takeTile();
		var tile = new Tile(type);
		tile.rect.x = tile.rect.w * hand.length;
		tile.rect.y = rect.h - tile.rect.h * 1.75;
		hand.push(tile);
	}
	
	function sortHand(tiles:Array<Tile>) {
		tiles.sort(function(a, b):Int {
			if (a.type < b.type) return -1;
			else if (a.type > b.type) return 1;
			return 0;
		});
		for (i in 0...tiles.length) {
			var tile = tiles[i];
			tile.rect.x = tile.rect.w * i;
			tile.rect.y = rect.h - tile.rect.h * 1.5;
		}
	}
	
	public function update():Void {
		if (hand.length > tileCount) throw hand.length+" "+[for (i in hand) i.type];
		//if (game.turn != position) return;
		
		switch (state) {
		case WAIT:
		case TAKE_TILE:
			takeTile();
			state = TSUMO;
		case TSUMO:
			var hand34 = countTiles(hand);
			if (game.checkWin(hand34)) onTsumo();
			else state = CLOSED_KAN;
		case CLOSED_KAN:
			if (!isPossibleClosedKan()) {
				state = DISCARD_TILE;
				return;
			}
			var hand34 = countTiles(hand);
			for (type in 0...hand34.length) {
				if (hand34[type] == 4) {
					onClosedKan(type);
					state = TSUMO; //check again
					return;
				}
				state = DISCARD_TILE;
			}
		case DISCARD_TILE:
			onDiscardTile();
		case RON_ANSWER:
			if (isRon()) onRonAnswer();
			else game.endAnswer();
		case KAN_ANSWER:
			if (isPossibleKan()) onKanAnswer();
			else game.endAnswer();
		case PON_ANSWER:
			if (isPossiblePon()) onPonAnswer();
			else game.endAnswer();
		case CHI_ANSWER:
			var melds = possibleChis();
			if (melds.length > 0) onChiAnswer(melds);
			else game.endAnswer();
		}
	}
	public function onTsumo():Void {}
	public function onClosedKan(type:Int):Void {}
	public function onDiscardTile():Void {}
	public function onRonAnswer():Void {}
	public function onKanAnswer():Void {}
	public function onPonAnswer():Void {}
	public function onChiAnswer(options:Array<Tiles34>):Void {}
	
	function isRon():Bool {
		var tile = game.lastDiscardedTile().type;
		var hand34 = countTiles(hand);
		hand34[tile]++;
		return game.checkWin(hand34);
	}
	
	function isPossibleClosedKan():Bool {
		if (game.isWallEmpty()) return false;
		for (tile in hand) {
			if (tile.locked) return false;
		}
		return true;
	}
	
	function isPossibleKan():Bool {
		var last = game.lastDiscardedTile().type;
		var handCounts = countTiles(hand);
		return handCounts[last] == 3;
	}
	
	function isPossiblePon():Bool {
		var last = game.lastDiscardedTile().type;
		var handCounts = countTiles(hand);
		return handCounts[last] > 1;
	}
	
	function possibleChis():Array<Tiles34> {
		var last = game.lastDiscardedTile().type;
		if (last >= 9 * 3) return [];
		var options:Array<Tiles34> = [];
		var handCounts = countTiles(hand);
		
		if (isOneType(last, last + 2) && handCounts[last + 1] > 0 && handCounts[last + 2] > 0)
			options.push([last, last + 1, last + 2]);
		if (isOneType(last, last - 2) && handCounts[last - 1] > 0 && handCounts[last - 2] > 0)
			options.push([last, last - 2, last - 1]);
		if (isOneType(last - 1, last + 1) && handCounts[last - 1] > 0 && handCounts[last + 1] > 0)
			options.push([last, last - 1, last + 1]);
		return options;
	}
	
	inline function countTiles(tiles:Array<Tile>):Array<Int> {
		var handCounts:Array<Int> = [for (i in 0...34) 0];
		for (tile in tiles) handCounts[tile.type]++;
		return handCounts;
	}
	
	inline function countInts(tiles:Array<Int>):Array<Int> {
		var handCounts:Array<Int> = [for (i in 0...34) 0];
		for (type in tiles) handCounts[type]++;
		return handCounts;
	}
	
	inline function isOneType(type:Int, type2:Int):Bool {
		return Math.floor(type / 9) == Math.floor(type2 / 9);
	}
	
	public function onMouseMove(p:Pointer):Void {}
	public function onMouseDown(p:Pointer):Void {}
	
	function discardTile(id:Int):Void {
		var tile = hand.splice(id, 1)[0];
		var tileCount = 10;
		var x = discard.length % tileCount;
		var y = Std.int(discard.length / tileCount);
		tile.rect.x = tile.rect.w * x;
		tile.rect.y = tile.rect.h * y + discardOffsetTop;
		discard.push(tile);
	}
	
	
	function getTileByType(type:Int):Tile {
		for (tile in hand) if (tile.type == type) return tile;
		throw "not found";
	}
	
	function makeClosedKan(type:Int):Void {
		for (i in 0...3) hand.remove(getTileByType(type));
		makeMeld([type, type, type, type]);
		
		var meld = melds[melds.length-1];
		meld[0].opened = false;
		meld[3].opened = false;
		game.afterClosedKan(this);
	}
	
	function makeKan(meld34:Tiles34):Void {
		var last = game.lastDiscardedTile();
		last.linked = true;
		for (i in 0...3) hand.remove(getTileByType(last.type));
		makeMeld(meld34);
		isKanDiscard = true;
		game.afterKan(this);
	}
	
	function makePon(meld34:Tiles34):Void {
		var last = game.lastDiscardedTile();
		last.linked = true;
		for (i in 0...2) hand.remove(getTileByType(last.type));
		for (tile in hand) {
			if (tile.type == last.type) {
				tile.locked = true;
				break;
			}
		}
		makeMeld(meld34);
		game.afterMeld(this);
	}
	
	function makeChi(meld34:Tiles34):Void {
		var last = game.lastDiscardedTile();
		if (last.linked) throw "linked "+position+" "+meld34.toArray()+" "+last;
		last.linked = true;
		for (type in meld34) {
			if (type != last.type) hand.remove(getTileByType(type));
		}
		var max = meld34[0];
		var min = meld34[0];
		for (type in meld34) {
			if (type > max) max = type;
			if (type < min) min = type;
		}
		var edge = -1;
		if (last.type == max && min > 1) edge = min - 1;
		if (last.type == min && max < 9) edge = max + 1;
		
		for (tile in hand) {
			if (tile.type == last.type) tile.locked = true;
			else if (tile.type == edge) tile.locked = true;
		}
		
		makeMeld(meld34);
		game.afterMeld(this);
	}
	
	function makeMeld(meld34:Tiles34):Void {
		inline function rotatedId(turn:Position):Int {
			if (turn == position) return -1;
			var next = game.nextPosition(position);
			if (turn == next) return 2;
			if (turn == game.nextPosition(next)) return 1;
			return 0;
		}
		var last = game.lastDiscardedTile();
		var meld:Array<Tile> = [];
		var len = meld34.toArray().length;
		var startX = rect.w - Tile.w * (len - 1) - Tile.h;
		var turn = game.currentTurn();
		if (position == turn) startX = rect.w - Tile.w * len;
		var takenId = rotatedId(turn);
		if (takenId == 2 && len == 4) takenId++;
		
		for (i in 0...len) {
			var type = meld34[i];
			var tile = new Tile(type);
			/*var iy = melds.length > 3 ? 3 : melds.length;
			tile.rect.y = iy * Tile.h + discardOffsetTop;
			if (melds.length > 3) {
				for (i in 3...melds.length) tile.rect.x -= Tile.w * melds[i].length + Tile.w / 2;
			}*/
			//tile.rect.x = rect.w - Tile.w * (len - i);
			tile.rect.y = rect.h - (melds.length+1) * Tile.h - discardOffsetTop;
			tile.rect.x = startX;
			if (i == takenId) {
				tile.rotation = 90;
				tile.rect.x += Tile.h;
				tile.rect.y += Tile.h - Tile.w;
				startX += Tile.h;
			} else startX += Tile.w;
			meld.push(tile);
		}
		melds.push(meld);
		sortHand(hand);
		game.getPlayer(turn).forceRender = true;
		forceRender = true;
	}
	
	function endTurn():Void {
		for (tile in hand) {
			if (tile.locked) tile.locked = false;
		}
		forceRender = true;
		state = WAIT;
		game.endTurn();
	}
	
	public function prerender():Void {
		if (forceRender) forceRender = false;
		else if (state == WAIT) return;
		
		var g = buffer.g2;
		g.begin(0x00000000);
		g.font = Assets.fonts.OpenSans_Regular;
		g.fontSize = 50;
		switch (position) {
		case TOP:
			g.color = 0xFFFF0000;
		case BOTTOM:
			g.color = 0xFFFFFF00;
		case LEFT:
			g.color = 0xFF0000FF;
		case RIGHT:
			g.color = 0xFFFF00FF;
		}
		g.drawRect(1, 2, rect.w-3, rect.h-2, 1/scale);
		for (tile in discard) tile.render(g, rect);
		for (tile in hand) tile.render(g, rect);
		for (meld in melds)
			for (tile in meld) tile.render(g, rect);
		
		g.color = 0xFFFFFFFF;
		g.drawString(wind.toString(), 0, 0);
		var pts = "" + points;
		g.drawString(pts, rect.w - g.font.width(g.fontSize, pts), 0);
		g.end();
	}
	
	public function render(g:Graphics):Void {
		switch (position) {
		case TOP:
			g.transformation = Utils.rotation(180.toRad(), rect.x, rect.y);
		case BOTTOM:
		case LEFT:
			g.transformation = Utils.rotation(90.toRad(), rect.x, rect.y);
		case RIGHT:
			g.transformation = Utils.rotation(270.toRad(), rect.x, rect.y);
		}
		g.transformation = Utils.matrix(scale, 0, 0, 0, scale).multmat(g.transformation);
		g.color = 0xFFFFFFFF;
		g.drawImage(buffer, rect.x, rect.y);
		g.transformation = Utils.matrix();
	}
	
	public function resize():Void {
		var min = Screen.w < Screen.h ? Screen.w : Screen.h;
		rect = {
			x: 0,
			y: 0,
			w: kha.Assets.images.tiles_Back.width * (tileCount+1),
			h: kha.Assets.images.tiles_Back.height * 5
		}
		scale = min / rect.w;
		if (position != BOTTOM) scale *= 0.80;
		else scale *= 1.20;
		
		var fullW = (rect.w + rect.h*2) * scale;
		if (fullW > min) {
			var newScale = Screen.w / (rect.w + rect.h*2);
			if (newScale < scale) scale = newScale;
		}
		
		var w = Screen.w / scale;
		var h = Screen.h / scale;
		switch (position) {
		case TOP:
			rect.x = w/2 + rect.w/2;
			rect.y = rect.h;
		case BOTTOM:
			rect.x = w/2 - rect.w/2;
			rect.y = h - rect.h;
		case LEFT:
			rect.x = rect.h;
			rect.y = h/2 - rect.w/2;
		case RIGHT:
			rect.x = w - rect.h;
			rect.y = h/2 + rect.w/2;
		}
		
		discardOffsetTop = Tile.h / 2;
	}
	
}
