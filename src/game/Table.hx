package game;

import kha.graphics2.Graphics;
import kha.Image;

class Table {
	
	var bg:Image;
	
	public function new() {}
	
	public function init() {
		resize();
	}
	
	public function render(g:Graphics):Void {
		g.color = 0xFFFFFFFF;
		g.drawImage(bg, 0, 0);
	}
	
	public function resize():Void {
		//var colors = buildColorArray(0xFF1C831A, 0xFF1C6818, Screen.h);
		var colors = buildColorArray(0xFF46b641, 0xFF16762b, Screen.h);
		bg = Image.createRenderTarget(Screen.w, Screen.h);
		var g = bg.g2;
		g.begin();
		var alpha = Std.int(255) << 24;
		var n = 0;
		for (c in colors) {
			g.color = c | alpha;
			g.fillRect(0, 0 + n, Screen.w, 1);
			n++;
		}
		g.end();
	}
	
	public static function buildColorArray(startColor:Int, endColor:Int, size:Int):Array<Int> {
		var array:Array<Int> = [];
		
		var r1 = r(startColor);
		var g1 = g(startColor);
		var b1 = b(startColor);
		var r2 = r(endColor);
		var g2 = g(endColor);
		var b2 = b(endColor);
		var rd = r2 - r1; // deltas
		var gd = g2 - g1; // deltas
		var bd = b2 - b1; // deltas
		var ri:Float = rd / (size - 1); // increments
		var gi:Float = gd / (size - 1); // increments
		var bi:Float = bd / (size - 1); // increments
		
		var r:Float = r1;
		var g:Float = g1;
		var b:Float = b1;
		for (n in 0...size) { //cast
			var c = color(r, g, b);
			array.push(c);
			
			r += ri;
			g += gi;
			b += bi;
		}
		
		return array;
	}
	
	public static inline function color(r:Float, g:Float, b:Float):Int {
		return (Math.round(r) << 16) | (Math.round(g) << 8) | Math.round(b);
	}
	
	public static inline function r(c:Int):Int {
		return c >> 16 & 0xFF;
	}
	
	public static inline function g(c:Int):Int {
		return c >> 8 & 0xFF;
	}
	
	public static inline function b(c:Int):Int {
		return c & 0xFF;
	}
	
}
