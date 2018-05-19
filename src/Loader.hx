package;

import kha.Framebuffer;
import kha.graphics2.Graphics;
import kha.System;
import kha.Assets;

class Loader {
	
	public function new() {}
	
	public function init():Void {
		System.notifyOnRender(onRender);
		Assets.loadEverything(loadComplete);
	}
	
	public function loadComplete():Void {
		System.removeRenderListener(onRender);
		
		var sets = Settings.read();
		Screen.init({touch: sets.touchMode});
		if (sets.lang == null) Lang.init();
		else Lang.set(sets.lang);
		Graphics._glyphs = Lang.fontGlyphs;
		
		var game = new game.Game();
		game.show();
		game.init();
	}
	
	function onRender(framebuffer:Framebuffer):Void {
		var g = framebuffer.g2;
		g.begin(true, 0xFFFFFFFF);
		var h = System.windowHeight() / 20;
		var w = Assets.progress * System.windowWidth();
		var y = System.windowHeight() / 2 - h;
		g.color = 0xFF000000;
		g.fillRect(0, y, w, h * 2);
		g.end();
	}
	
}
