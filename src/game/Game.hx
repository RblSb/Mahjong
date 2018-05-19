package game;

import kha.graphics2.Graphics;
import kha.input.KeyCode;
import kha.Canvas;
import kha.System;
import kha.Assets;
import Screen.Pointer;
import Types.Position;
import mahjong.Agari;
import mahjong.Types;

class Game extends Screen {
	
	var agari:Agari;
	var table:Table;
	var players:Array<AbstractPlayer>;
	var playerId:Int;
	var tiles:Array<Int>;
	var deadWall:Array<Tile>;
	var doraIndicator:Int;
	var gameEnded:Bool;
	var dealWinner:Position;
	public var turn:Position;
	
	public function init():Void {
		agari = new Agari();
		table = new Table();
		table.init();
		tiles = [for (i in 0...136) i%34];
		Utils.shuffle(tiles);
		
		players = [];
		players.push(new Bot(this, TOP));
		players.push(new Bot(this, LEFT));
		//players.push(new Player(this, BOTTOM));
		players.push(new Bot(this, BOTTOM));
		players.push(new Bot(this, RIGHT));
		
		var id = Std.random(players.length);
		players[id].isDealer = true;
		players[id].wild = "East";
		players[(id+1)%4].wild = "South";
		players[(id+2)%4].wild = "West";
		players[(id+3)%4].wild = "North";
		turn = players[id].position;
		
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
		deadWall[7 + 2].opened = true;
		doraIndicator = deadWall[7 + 2].type;
		dealWinner = null;
		gameEnded = false;
	}
	
	public function rollDices():Int {
		return 2 + Std.random(11);
	}
	
	public inline function takeTile():Int {
		return tiles.pop();
	}
	
	public function getVisibleTiles():Array<Int> {
		var arr:Array<Int> = [for (i in 0...34) 0];
		for (player in players) {
			for (tile in player.discard) arr[tile.type]++;
			for (meld in player.melds)
				for (tile in meld) arr[tile.type]++;
		}
		for (tile in deadWall)
			if (tile.opened) arr[tile.type]++;
		
		return arr;
	}
	
	inline function isWallEmpty():Bool {
		return tiles.length == 0;
	}
	
	public inline function endTurn():Void {
		if (isWallEmpty()) {
			endDeal();
			return;
		}
		for (player in players) {
			if (player.position == turn) continue;
		}
		turn = nextPlayer(turn);
	}
	
	public inline function nextPlayer(pos:Position):Position {
		return switch (pos) {
			case BOTTOM: RIGHT;
			case RIGHT: TOP;
			case TOP: LEFT;
			case LEFT: BOTTOM;
		}
	}
	
	public inline function checkWin(tiles:Array<Tile>):Bool {
		//var arr:Tiles34.fromArray([for (tile in tiles) tile.type]);
		var arr:Array<Int> = [for (i in 0...34) 0];
		for (tile in tiles) arr[tile.type]++;
		return agari.is_agari(arr);
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
	
	override function onMouseMove(p:Pointer):Void {
		if (turn != players[playerId].position) return;
		players[playerId].onMouseMove(p);
	}
	
	override function onMouseDown(p:Pointer):Void {
		if (turn != players[playerId].position) return;
		players[playerId].onMouseDown(p);
	}
	
	override function onKeyDown(key:KeyCode):Void {
		if (key == R) init();
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
		g.font = Assets.fonts.OpenSans_Regular;
		g.fontSize = 50;
		table.render(g);
		for (player in players) player.render(g);
		drawDeadWall(g);
		g.end();
	}
	
	inline function drawDeadWall(g:Graphics) {
		var scale = players[0].scale;
		var lastTile = deadWall[deadWall.length-1];
		var w = lastTile.rect.x + lastTile.rect.w;
		var h = lastTile.rect.y + lastTile.rect.h;
		g.transformation = Utils.matrix(
			scale, 0, Screen.w/2 - w/2 * scale,
			0, scale, Screen.h/2 - h/2 * scale
		);
		for (tile in deadWall) tile.render(g);
		var left = "Left: " + tiles.length;
		g.drawString(left, w, 0);
		g.drawString("Turn: " + turn, w, g.font.height(g.fontSize));
		if (dealWinner != null) g.drawString(turn + " WIN!", w, g.font.height(g.fontSize)*2);
		else if (gameEnded) g.drawString("DRAFT! R TO RESTART.", w, g.font.height(g.fontSize)*2);
		g.transformation = Utils.matrix();
	}
	
}
