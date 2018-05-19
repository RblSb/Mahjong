package game;

import Screen.Pointer;
import Types.Position;

class Player extends AbstractPlayer {
	
	public function new(game:Game, pos:Position) {
		super(game, pos);
	}
	
	override function onMouseDown(p:Pointer):Void {
		var x = (p.x - rect.x * scale);
		var y = (p.y - rect.y * scale);
		for (i in 0...hand.length) {
			var tile = hand[i];
			var trect = {
				x: tile.rect.x * scale,
				y: tile.rect.y * scale,
				w: tile.rect.w * scale,
				h: tile.rect.h * scale
			}
			if (Utils.AABB(trect, {x:x, y:y, w:0, h:0})) {
				selectTile(i);
				break;
			}
		}
	}
	
	override function onMouseMove(p:Pointer):Void {
		var x = (p.x - rect.x * scale);
		var y = (p.y - rect.y * scale);
		for (tile in hand) {
			var trect = {
				x: tile.rect.x * scale,
				y: tile.rect.y * scale,
				w: tile.rect.w * scale,
				h: tile.rect.h * scale
			}
			if (Utils.AABB(trect, {x: x, y: y, w: 0, h: 0})) {
				for (tile in hand) tile.rect.y = rect.h - tile.rect.h * 1.5;
				tile.rect.y = rect.h - tile.rect.h * 1.75;
			}
		}
	}
	
	function selectTile(id:Int):Void {
		discardTile(id);
		sortHand(hand);
		endTurn();
	}
	
}
