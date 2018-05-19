package game;

import kha.graphics2.Graphics;
import kha.Image;
import kha.Assets;
import kha.Font;
import Screen.Pointer;
import Types.Rect;
import Types.Position;
import kha.math.FastMatrix3;
using Utils.MathExtension;

private enum State {
	WAIT;
	TAKE_TILE;
	DISCARD_TILE;
}

class AbstractPlayer {
	
	var game:Game;
	var buffer:Image;
	public var forceRender:Bool;
	public var scale:Float;
	
	public var tileCount = 14;
	public var isDealer = false;
	public var wild = "None";
	public var points = 30000;
	public var hand:Array<Tile> = [];
	public var melds:Array<Array<Tile>> = [];
	public var discard:Array<Tile> = [];
	public var position:Position;
	var state:State;
	var rect:Rect;
	
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
		tile.rect.x =(tile.rect.w + 1) * hand.length;
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
			tile.rect.x = (tile.rect.w + 1) * i;
			tile.rect.y = rect.h - tile.rect.h * 1.5;
		}
	}
	
	public function update():Void {
		if (hand.length > tileCount) throw hand;
		if (game.turn != position) return;
		switch (state) {
		case WAIT:
			state = TAKE_TILE;
		case TAKE_TILE:
			takeTile();
			state = DISCARD_TILE;
		case DISCARD_TILE:
			onDiscardTile();
		}
	}
	
	public function onDiscardTile():Void {}
	
	public function onMouseMove(p:Pointer):Void {}
	public function onMouseDown(p:Pointer):Void {}
	
	public function discardTile(id:Int):Void {
		var tile = hand.splice(id, 1)[0];
		var x = discard.length % tileCount;
		var y = Std.int(discard.length / tileCount);
		tile.rect.x = (tile.rect.w + 1) * x;
		tile.rect.y = tile.rect.h * y + tile.rect.h / 2;
		discard.push(tile);
	}
	
	function endTurn():Void {
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
		
		g.color = 0xFFFFFFFF;
		if (isDealer) g.drawString(wild + " (dealer)", 0, 0);
		else g.drawString(wild, 0, 0);
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
			w: (kha.Assets.images.tiles_Back.width + 1) * tileCount,
			h: kha.Assets.images.tiles_Back.height * 5
		}
		scale = min / rect.w;
		if (position != BOTTOM) scale *= 0.75;
		
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
	}
	
}
