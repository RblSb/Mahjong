package game;

import kha.graphics2.Graphics;
import kha.Image;
import kha.Assets;
import Types.Rect;

class Tile {
	
	public static var w:Int;
	public static var h:Int;
	static var tilesetW:Int;
	static var tilesetH:Int;
	static var tileset:Image;
	public var rect:Rect;
	public var type:Int;
	public var opened:Bool;
	public var linked = false; //meld tile from discard
	public var locked = false; //cant be discarded
	public var rotation = 0;
	var char = "";
	
	public function new(type:Int, opened:Bool=true) {
		this.opened = opened;
		this.type = type;
		
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
	
	public static function init():Void {
		var tilesNum = 34;
		tilesetW = Math.ceil(Math.sqrt(tilesNum));
		tilesetH = Math.ceil(tilesNum / tilesetW);
		var w = Assets.images.tiles_Front.width;
		var h = Assets.images.tiles_Front.height;
		tileset = Image.createRenderTarget(tilesetW * w, tilesetH * h);
		var g = tileset.g2;
		g.begin(true, 0x0);
		g.imageScaleQuality = High;
		var x = 0;
		var y = 0;
		for (i in 0...35) {
			var image = Assets.images.get("tiles_" + getImageId(i));
			g.drawImage(Assets.images.tiles_Front, x, y);
			//g.drawImage(image, x, y);
			g.drawScaledImage(
				image,
				x + image.width / 20,
				y + image.height / 20,
				image.width - image.width / 10,
				image.height - image.height / 10
			);
			x += w;
			if (x >= tilesetW * w) {
				x = 0;
				y += h;
			}
		}
		g.end();
		
		var image = Assets.images.tiles_Front;
		Tile.w = image.width;
		Tile.h = image.height;
	}
	
	static inline function getImageId(type:Int):String {
		var imageId = "";
		var num = type % 9 + 1;
		if (type < 9) imageId = "Man" + num;
		else if (type < 9*2) imageId = "Pin" + num;
		else if (type < 9*3) imageId = "Sou" + num;
		else if (type < 34) {
			var honors = ["Ton", "Nan", "Shaa", "Pei", "Haku", "Hatsu", "Chun"];
			imageId = honors[num-1];
		} else imageId = "Blank";
		return imageId;
	}
	
	public function render(g:Graphics, ?field:Rect):Void {
		g.color = 0xFFFFFFFF;
		drawTile(g, rect.x, rect.y);
	}
	
	inline function drawTile(g:Graphics, x:Float, y:Float):Void {
		//if (type == 9 * 3 + 4) return; //Haku
		if (!opened) {
			g.drawImage(Assets.images.tiles_Back, rect.x, rect.y);
			return;
		}
		var tx = (type % tilesetW) * rect.w;
		var ty = Std.int(type / tilesetW) * rect.h;
		if (linked) g.opacity = 0.75;
		if (locked) g.color = 0xFF808080;
		var tempMatrix = kha.math.FastMatrix3.empty();
		tempMatrix.setFrom(g.transformation);
		if (rotation != 0) g.rotate(rotation * Math.PI / 180, rect.x, rect.y);
		g.drawSubImage(
			tileset, x, y,
			tx, ty, rect.w, rect.h
		);
		if (char != "") {
			g.color = 0xFFFF0000;
			boldString(g, char, rect.x + rect.w / 25, rect.y);
		}
		if (rotation != 1) g.transformation = tempMatrix;
		if (linked) g.opacity = 1;
	}
	
	inline function boldString(g:Graphics, s:String, x:Float, y:Float):Void {
		//g.drawString(s, x + 1, y + 1);
		g.drawString(s, x + 1, y - 1);
		g.drawString(s, x - 1, y + 1);
		g.drawString(s, x - 1, y - 1);
		g.drawString(s, x + 1, y + 1);
		//g.drawString(s, x, y);
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
