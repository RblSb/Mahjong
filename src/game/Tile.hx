package game;

import kha.graphics2.Graphics;
import kha.Image;
import kha.Assets;
import Types.Rect;

class Tile {
	
	static var tilesetW:Int;
	static var tilesetH:Int;
	public static var tileset:Image;
	public var rect:Rect;
	public var type:Int;
	public var opened:Bool;
	//var image:Image;
	var char = "";
	
	public function new(type:Int, opened:Bool=true) {
		this.opened = opened;
		this.type = type;
		init();
	}
	
	public function init():Void {
		if (tileset == null) {
			var tilesNum = 34;
			tilesetW = Math.ceil(Math.sqrt(tilesNum));
			tilesetH = Math.ceil(tilesNum / tilesetW);
			var w = Assets.images.tiles_Front.width;
			var h = Assets.images.tiles_Front.height;
			tileset = Image.createRenderTarget(tilesetW * w, tilesetH * h);
			var g = tileset.g2;
			g.begin(true, 0x0);
			var x = 0;
			var y = 0;
			for (i in 0...35) {
				var image = Assets.images.get("tiles_" + getImageId(i));
				g.drawImage(image, x, y);
				x += w;
				if (x >= tilesetW * w) {
					x = 0;
					y += h;
				}
			}
			g.end();
		}
		
		var num = type % 9 + 1;
		if (type < 9) char = "" + num;
		else if (type >= 9*3 && type < 34) {
			var chars = ["E", "S", "W", "N", "", "", ""];
			//var chars = ["В", "Ю", "З", "С", "", "", ""];
			char = chars[num-1];
		}
		//var imageId = getImageId(type);
		//image = Assets.images.get("tiles_" + imageId);
		resize();
	}
	
	inline function getImageId(type:Int):String {
		var imageId = "";
		var num = type % 9 + 1;
		if (type < 9) imageId = "Man" + num;
		else if (type < 9*2) imageId = "Pin" + num;
		else if (type < 9*3) imageId = "Sou" + num;
		else if (type < 34) {
			//var chars = ["E", "S", "W", "N", "", "", ""];
			var honors = ["Ton", "Nan", "Shaa", "Pei", "Haku", "Hatsu", "Chun"];
			imageId = honors[num-1];
			//char = chars[num-1];
		} else imageId = "Blank";
		return imageId;
	}
	
	public function render(g:Graphics, ?field:Rect):Void {
		var x = rect.x;
		var y = rect.y;
		g.color = 0xFFFFFFFF;
		if (!opened) {
			g.drawImage(Assets.images.tiles_Back, x, y);
			return;
		}
		g.drawImage(Assets.images.tiles_Front, x, y);
		//g.drawImage(image, x, y);
		drawTile(g, x, y);
		
		if (char != "") {
			//g.drawString(char, x + rect.w / 25 + 1, y + 1);
			g.color = 0xFFFF0000;
			g.drawString(char, x + rect.w / 25 + 1, y - 1);
			g.drawString(char, x + rect.w / 25 - 1, y + 1);
			g.drawString(char, x + rect.w / 25 - 1, y - 1);
			g.drawString(char, x + rect.w / 25 + 1, y + 1);
			//g.drawString(char, x + rect.w / 25, y);
		}
	}
	
	inline function drawTile(g:Graphics, x:Float, y:Float) {
		if (type == 9 * 3 + 4) return; //Haku
		var tx = (type % tilesetW) * rect.w;
		var ty = Std.int(type / tilesetW) * rect.h;
		g.drawSubImage(
			tileset, x, y,
			tx, ty, rect.w, rect.h
		);
	}
	
	public function resize():Void {
		var image = Assets.images.tiles_Front;
		rect = {
			x: 0,
			y: 0,
			w: image.width,
			h: image.height
		}
	}
	
}
