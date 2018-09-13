package game;

import Screen.Pointer;
import Types.Position;
import mahjong.Types;

class Player extends AbstractPlayer {
	
	var waitForAnswer = false;
	
	public function new(game:Game, pos:Position) {
		super(game, pos);
	}
	
	inline function addButton(name:String, func:Void->Void):Void {
		game.addButton(name, function() {
			func();
			game.clearButtons();
			waitForAnswer = false;
		});
	}
	
	inline function addSkipAnswer():Void {
		game.addButton("Skip", function() {
			game.endAnswer();
			game.clearButtons();
			waitForAnswer = false;
		});
	}
	
	override function onTsumo():Void {
		if (waitForAnswer) return;
		waitForAnswer = true;
		addButton("Tsumo", function() {
			game.winDeal(this);
		});
		addSkipAnswer();
	}
	
	override function onClosedKan(type:Int):Void {
		if (waitForAnswer) return;
		waitForAnswer = true;
		addButton('Kan (tileName(type))', function() {
			makeClosedKan(type);
		});
		addButton("Skip", function() {
			state = DISCARD_TILE;
		});
	}
	
	override function onRonAnswer():Void {
		if (waitForAnswer) return;
		waitForAnswer = true;
		addButton("Ron", function() {
			game.winDeal(this);
		});
		addSkipAnswer();
	}
	
	override function onKanAnswer():Void {
		if (waitForAnswer) return;
		waitForAnswer = true;
		var last = game.lastDiscardedTile().type;
		addButton('Kan (${tileName(last)})', function() {
			makeKan([last, last, last, last]);
		});
		addSkipAnswer();
	}
	
	override function onPonAnswer():Void {
		if (waitForAnswer) return;
		waitForAnswer = true;
		var last = game.lastDiscardedTile().type;
		addButton('Pon (${tileName(last)})', function() {
			makePon([last, last, last]);
		});
		addSkipAnswer();
	}
	
	override function onChiAnswer(options:Array<Tiles34>):Void {
		if (waitForAnswer) return;
		waitForAnswer = true;
		trace(options);
		for (meld in options) {
			var name = "" + meld.toArray();
			var arr = name.substr(1, name.length - 2).split(",");
			name = "";
			for (s in arr) name += (Std.parseInt(s) % 9 + 1);
			addButton('Chi ($name)', function() {
				makeChi(meld);
			});
		}
		addSkipAnswer();
	}
	
	function tileName(type:Int):String {
		if (type < 9 * 3) return "" + (type%9+1);
		return switch(type%9) {
			case 0: "East";
			case 1: "South";
			case 2: "West";
			case 3: "North";
			case 4: "Haku";
			case 5: "Hatsu";
			case 6: "Chun";
			default: ""+(type%9+1);
		};
	}
	
	override function onMouseDown(p:Pointer):Void {
		if (state != DISCARD_TILE) return;
		var x = (p.x - rect.x * scale);
		var y = (p.y - rect.y * scale);
		for (i in 0...hand.length) {
			var tile = hand[i];
			if (tile.locked) continue;
			var trect = {
				x: tile.rect.x * scale,
				y: tile.rect.y * scale,
				w: tile.rect.w * scale,
				h: tile.rect.h * scale * 1.5
			}
			if (Utils.AABB(trect, {x:x, y:y, w:0, h:0})) {
				selectTile(i);
				break;
			}
		}
	}
	
	override function onMouseMove(p:Pointer):Void {
		if (state != DISCARD_TILE) return;
		var x = (p.x - rect.x * scale);
		var y = (p.y - rect.y * scale);
		for (tile in hand) {
			var trect = {
				x: tile.rect.x * scale,
				y: tile.rect.y * scale,
				w: tile.rect.w * scale,
				h: tile.rect.h * scale * 1.5
			}
			if (Utils.AABB(trect, {x: x, y: y, w: 0, h: 0})) {
				for (tile in hand) tile.rect.y = rect.h - tile.rect.h * 1.5;
				if (!tile.locked) tile.rect.y = rect.h - tile.rect.h * 1.75;
			}
		}
	}
	
	function selectTile(id:Int):Void {
		discardTile(id);
		sortHand(hand);
		endTurn();
	}
	
}
