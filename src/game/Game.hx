package game;

import kha.graphics2.Graphics;
import kha.input.KeyCode;
import kha.Canvas;
import kha.System;
import kha.Assets;
import Screen.Pointer;
import mahjong.Constants.Wind;
import Types.Position;
import mahjong.Shanten;
import mahjong.Agari;
import mahjong.Types;

class Game extends Screen {
	
	var agari:Agari;
	var shanten:Shanten;
	var table:Table;
	var players:Array<AbstractPlayer>;
	var playerId:Int;
	var tiles:Array<Int>;
	public var replayTiles:Array<Int>;
	var deadWall:Array<Tile>;
	public var roundWind:Wind;
	var gameEnded:Bool;
	var dealWinner:Position;
	var turn:Position;
	var buttons:Array<Button>;
	var font = Assets.fonts.OpenSans_Regular;
	var fontSize = 50;
	
	public function init(?customTiles:Array<Int>):Void {
		shanten = new Shanten();
		agari = new Agari();
		table = new Table();
		table.init();
		tiles = [for (i in 0...136) i%34];
		Utils.shuffle(tiles);
		loadCustomTiles(customTiles);
		replayTiles = tiles.copy();
		Tile.init();
		
		buttons = [];
		players = [];
		players.push(new Bot(this, RIGHT));
		players.push(new Bot(this, TOP));
		players.push(new Bot(this, LEFT));
		players.push(new Player(this, BOTTOM));
		//players.push(new Bot(this, BOTTOM));
		
		var id = tiles[0]%4;
		players[id].wind = East;
		players[(id+1)%4].wind = South;
		players[(id+2)%4].wind = West;
		players[(id+3)%4].wind = North;
		setTurn(players[id].position);
		
		for (i in 0...players.length)
			if (players[i].position == BOTTOM) playerId = i;
		
		deadWall = [];
		for (row in 0...2)
		for (i in 0...7) {
			var tile = new Tile(tiles.shift(), false);
			tile.rect.x = tile.rect.w * i;
			if (row == 0) tile.rect.y = tile.rect.h / 10;
			deadWall.push(tile);
		}
		deadWall[7 + 2].opened = true; //indicator 
		roundWind = East;
		dealWinner = null;
		gameEnded = false;
	}
	
	inline function loadCustomTiles(?customTiles:Array<Int>):Void {
		if (customTiles != null) {
			trace(customTiles);
			tiles = customTiles;
			#if kha_html5
			js.Browser.window.location.hash = "#"+tiles;
			#end
		} else {
			#if kha_html5
			var nav = js.Browser.window.location.hash.substr(1);
			if (nav.length == 0) return;
			nav = nav.substr(1, nav.length - 2);
			var arr = nav.split(",");
			tiles = [];
			for (s in arr) tiles.push(Std.parseInt(s));
			#end
		}
	}
	
	public inline function rollDices():Int {
		return 2 + Std.random(11);
	}
	
	public inline function takeTile():Int {
		return tiles.pop();
	}
	
	public function getVisibleTiles():Array<Int> {
		var arr:Array<Int> = [for (i in 0...34) 0];
		for (player in players) {
			for (tile in player.discard)
				if (!tile.linked) arr[tile.type]++;
			for (meld in player.melds)
				for (tile in meld) arr[tile.type]++;
		}
		for (tile in deadWall)
			if (tile.opened) arr[tile.type]++;
		
		return arr;
	}
	
	public function lastDiscardedTile():Tile {
		for (player in players) {
			if (player.position == turn) return player.discard[player.discard.length-1];
		}
		throw "empty discards " + turn;
	}
	
	public inline function isWallEmpty():Bool {
		return tiles.length == 0;
	}
	
	inline function setTurn(pos:Position):Void {
		for (player in players) {
			if (player.position != pos) continue;
			player.state = TAKE_TILE;
			turn = player.position;
		}
	}
	
	public inline function currentTurn():Position {
		return turn;
	}
	
	public function endTurn():Void {
		//start answer iterations
		var player = nextPlayer(turn);
		player.state = RON_ANSWER;
	}
	
	public function endAnswer():Void {
		for (player in players) {
			if (player.state != RON_ANSWER) continue;
			player.state = WAIT;
			
			var player2 = nextPlayer(player.position);
			if (player2.position != turn) player2.state = RON_ANSWER;
			else { //next answer iteration
				var player3 = nextPlayer(player2.position);
				player3.state = KAN_ANSWER;
			}
			return;
		}
		
		if (isWallEmpty()) {
			endDeal();
			return;
		}
		
		for (player in players) {
			if (player.state != KAN_ANSWER) continue;
			player.state = WAIT;
			
			var player2 = nextPlayer(player.position);
			if (player2.position != turn) player2.state = KAN_ANSWER;
			else { //next answer iteration
				var player3 = nextPlayer(player2.position);
				player3.state = PON_ANSWER;
			}
			return;
		}
		
		for (player in players) {
			if (player.state != PON_ANSWER) continue;
			player.state = WAIT;
			
			var player2 = nextPlayer(player.position);
			if (player2.position != turn) {
				player2.state = PON_ANSWER;
				return;
			} //else check for chi
		}
		
		var player = nextPlayer(turn);
		if (player.state != CHI_ANSWER) {
			player.state = CHI_ANSWER;
			return;
		}
		player.state = WAIT;
		setTurn(nextPosition(turn));
	}
	
	function nextPlayer(pos:Position):AbstractPlayer {
		var nextPos = nextPosition(pos);
		for (player in players) {
			if (player.position == nextPos) return player;
		}
		throw "not found next player " + nextPos;
	}
	
	public inline function nextPosition(pos:Position):Position {
		return switch (pos) {
			case BOTTOM: RIGHT;
			case RIGHT: TOP;
			case TOP: LEFT;
			case LEFT: BOTTOM;
		}
	}
	
	public function getPlayer(pos:Position):AbstractPlayer {
		for (player in players) {
			if (player.position == pos) return player;
		}
		throw "not found player " + pos;
	}
	
	public inline function afterClosedKan(player:AbstractPlayer):Void {
		afterKan(player);
		openKandora();
	}
	
	public inline function afterKan(player:AbstractPlayer):Void {
		for (player in players) player.state = WAIT;
		player.state = TAKE_TILE;
		turn = player.position;
	}
	
	public inline function openKandora():Void {
		for (i in 1...5) {
			var tile = deadWall[7 + 2 + i];
			if (!tile.opened) {
				tile.opened = true;
				break;
			}
		}
	}
	
	public inline function afterMeld(player:AbstractPlayer):Void {
		for (player in players) player.state = WAIT;
		player.state = DISCARD_TILE;
		turn = player.position;
	}
	
	public inline function checkWin(tiles:Array<Int>):Bool {
		return agari.is_agari(tiles);
	}
	
	public inline function getShanten(tiles:Tiles34, ?melds:Array<Tiles34>):Int {
		return shanten.calculate_shanten(tiles, melds);
	}
	
	public function winDeal(player:AbstractPlayer):Void {
		dealWinner = player.position;
		trace(dealWinner + " win!");
		trace(Tiles34.fromArray([for (tile in player.hand) tile.type]));
		gameEnded = true;
	}
	
	public function endDeal():Void {
		gameEnded = true;
	}
	
	public function clearButtons():Void {
		buttons = [];
	}
	
	public function addButton(name:String, func:Void->Void):Void {
		var x = Screen.w/2;
		if (buttons.length != 0) {
			var last = buttons.length - 1;
			x = buttons[last].rect.x + buttons[last].rect.w + 10;
		}
		buttons.push(new Button({
			x: x,
			y: Screen.h/2,
			w: font.width(fontSize, name),
			h: font.height(fontSize),
			text: name,
			onDown: func
		}));
	}
	
	override function onMouseMove(p:Pointer):Void {
		if (Button.onMove(this, buttons, p)) return;
		players[playerId].onMouseMove(p);
	}
	
	override function onMouseDown(p:Pointer):Void {
		if (Button.onDown(this, buttons, p)) return;
		players[playerId].onMouseDown(p);
	}
	
	override function onKeyDown(key:KeyCode):Void {
		if (keys[Shift] && key == R) {
			init(replayTiles);
			return;
		}
		if (key == R) {
			#if kha_html5
			var location = js.Browser.window.location;
			if (location.hash.length > 0) location.hash = "";
			#end
			init();
		}
	}
	
	var turnDelayMax = 0;
	var turnDelay = 0;
	override function onUpdate():Void {
		if (gameEnded) return;
		turnDelay++;
		if (turnDelay > turnDelayMax) turnDelay = 0;
		else return;
		for (player in players) player.update();
	}
	
	override function onResize():Void {
		table.resize();
		for (player in players) player.resize();
	}
	
	override function onRender(frame:Canvas):Void {
		for (player in players) player.prerender();
		
		var g = frame.g2;
		g.begin(false);
		g.imageScaleQuality = High;
		g.font = font;
		g.fontSize = fontSize;
		table.render(g);
		for (player in players) player.render(g);
		drawDeadWall(g);
		for (button in buttons) button.draw(g);
		g.end();
	}
	
	inline function drawDeadWall(g:Graphics) {
		var scale = players[1].scale;
		var lastTile = deadWall[deadWall.length-1];
		var w = lastTile.rect.x + lastTile.rect.w;
		var h = lastTile.rect.y + lastTile.rect.h;
		var x = Screen.w/2 - w/2 * scale;
		//var offY = Screen.h - players[1].rect.h * scale - players[3].rect.h * players[3].scale;
		//var y = Screen.h/2 - offY/2;
		//var offY = Screen.h - players[1].rect.h * scale - players[3].rect.h * players[3].scale;
		var y = Screen.h - players[3].rect.h * players[3].scale - lastTile.rect.h * 2 * scale;
		g.transformation = Utils.matrix(
			scale, 0, x,
			0, scale, y
		);
		for (tile in deadWall) tile.render(g);
		var left = "Left: " + tiles.length;
		g.drawString(left, w, 0);
		g.drawString("Turn: " + turn, w, g.font.height(g.fontSize));
		if (gameEnded) {
			var winner = dealWinner == null ? "DRAFT!" : dealWinner + " WIN!";
			if (dealWinner == BOTTOM) winner = "YOU WIN!";
			g.drawString(winner, w, g.font.height(g.fontSize)*2);
			g.drawString("R TO RESTART.", w, g.font.height(g.fontSize)*3);
		}
		g.transformation = Utils.matrix();
	}
	
}
