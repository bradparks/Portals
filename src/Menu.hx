package;

import haxe.Constraints.Function;
//import haxe.Timer;
import kha.Framebuffer;
import kha.graphics2.Graphics;
import kha.input.KeyCode;
import kha.System;
import kha.Image;
import kha.Assets;
import kha.Color;
import kha.Font;
import kha.SuperString;
import game.Game;
import editor.Editor;
import kha.math.Vector2;
import Types.Point;
import Types.Rect;

class Menu extends Screen {
	
	var items:Array<MenuButton> = [];
	public static var font:Font;
	public static var fontSize:Int;
	static var bgscale = 1.0;
	var particles:Array<Particle> = [];
	var current:Int;
	//var checker:Timer;
	var confirm:{yes:Function, no:Function};
	var githubLink = "https://github.com/RblSb/Portals";
	
	public function new() {
		super();
	}
	
	public function init(id=0):Void {
		for(i in 0...50) {
			var x = (- Assets.images.menubg.width + 47 + 31 * Math.random()) * bgscale;
			var y = (- Assets.images.menubg.height + 28) * bgscale;
			particles.push(new Particle(
				x, y,
				new Vector2(0, -0.5).mult(bgscale),
				new Vector2(0.5, 0).mult(bgscale),
				0xFF000000, 60, 60 + Std.random(360), bgscale
			));
		}
		
		font = Assets.fonts.OpenSans_Regular;
		setMenu(id);
	}
	
	inline function createMenu(id:Int):Array<String> {
		var menu:Array<String> = [];
		switch(id) {
		case -1:
			menu = [
				"/"+Lang.get("are_you_sure"),
				"yes",
				"no"
			];
		case 0:
			menu = [
				"game",
				"level_editor",
				"settings",
				"info",
				#if sys "exit" #end
			];
		case 1:
			var isNew = Settings.read().levelProgress < 2;
			menu = [
				isNew ? "/"+Lang.get("continue") : "continue",
				"new_game",
				"level_select",
				"/"+Lang.get("levels_online"),
				"back"
			];
		case 12:
			menu = [
				"/"+Lang.get("play_traning"),
				"yes",
				"no"
			];
		case 13:
			menu = ["training"];
			var i = 1;
			var end = Settings.read().levelProgress;
			while(i <= end) { //Lvl.exists(i)
				menu.push(Lang.get("level")+" "+i);
				i++;
			}
			menu.push("back");
		case 2:
			menu = [
				"path",
				"width",
				"height",
				"create",
				"continue",
				"back"
			];
		case 3:
			var sets = Settings.read();
			var ch = ": ";
			menu = [
				"/"+Lang.get("music") + ch + 0, //sets.musicVolume,
				"/"+Lang.get("control_type") + ch + sets.controlType,
				Lang.get("language") + ch + Lang.iso.toUpperCase(),
				"/"+Lang.get("touch") + ch + state(Screen.touch),
				Lang.get("other"),
				Lang.get("back")
			];
		case 35:
			menu = [
				"reset_data",
				"back"
			];
		case 4:
			menu = [
				"about_game",
				"about_editor",
				"about_authors",
				"github",
				"back"
			];
		default:
			menu = ["back"];
		}
		return menu;
	}
	
	inline function state(flag:Bool):String {
		if (flag) return Lang.get("on");
		return Lang.get("off");
	}
	
	function choose(id:Int):Void {
		switch(current) {
		case -1: //areYouSure
			switch(id) {
			case 1:
				confirm.yes();
				confirm = null;
			case 2:
				confirm.no();
				confirm = null;
			}
		case 0: //Main Menu
			switch(id) {
			case 0: setMenu(1);
			case 1:
				var editor = new Editor();
				editor.show();
				editor.init();
				//setMenu(2);
			case 2: setMenu(3);
			case 3: setMenu(4);
			case 4: System.requestShutdown();
			}
		case 1: //Game Menu
			switch(id) {
			case 0:
				var isNew = Settings.read().levelProgress < 2;
				if (isNew) return;
				var game = new Game();
				game.show();
				game.init();
				game.playCompany();
			case 1:
				var newGame = function() setMenu(12);
				var cancel = function() setMenu(1);
				if (Settings.read().levelProgress > 1) areYouSure(newGame, cancel);
				else newGame();
			case 2: setMenu(13);
			case 4: setMenu(0);
			}
		case 12: //Play Training?
			if (id == 0) return;
			if (id == 1) Settings.set({levelProgress: 0});
			else Settings.set({levelProgress: 1});
			var game = new Game();
			game.show();
			game.init();
			game.playCompany();
		case 13: //Level Select
			if (id == items.length-1) setMenu(1);
			else {
				var game = new Game();
				game.show();
				game.init();
				game.playLevel(id);
				//if (id == items.length-2) game.playCompany();
			}
			
		case 2: //Editor
			switch(id) {
			case 0:
				var editor = new Editor();
				editor.show();
				editor.init();
			case 5: setMenu(0);
			}
		case 3: //Settings
			switch(id) {
			case 2:
				for (i in 0...Lang.langs.length) {
					var lang = Lang.langs[i];
					if (lang == Lang.iso) {
						var next = i+1 < Lang.langs.length ? Lang.langs[i+1] : Lang.langs[0];
						Lang.set(next);
						break;
					}
				}
				Settings.set({lang: Lang.iso});
				font.unloadImages();
				setMenu(3);
			case 3:
				/*if (checker == null) checker = Timer.delay(function() {
					Screen.touch = !Screen.touch;
					Settings.set({touchMode: Screen.touch});
					setMenu(3);
					checker = null;
				}, 100);*/
			case 4: setMenu(35);
			case 5: setMenu(0);
			}
		case 35: //Other Settings
			switch(id) {
			case 0: Settings.reset();
			case 1: setMenu(3);
			}
		case 4: //Info
			switch(id) {
			case 0: System.loadUrl(githubLink+"#about-game");
			case 1: System.loadUrl(githubLink+"#about-level-editor");
			case 2: System.loadUrl(githubLink+"#about-authors");
			case 3: System.loadUrl(githubLink);
			case 4: setMenu(0);
			}
			
		default: setMenu(0);
		}
	}
	
	inline function areYouSure(yes:Function, no:Function):Void {
		confirm = {yes: yes, no: no};
		setMenu(-1);
	}
	
	/*inline function newGame():Void {
		var isNew = Settings.read().levelProgress < 2;
		if (isNew) {
			setMenu(12);
			return;
		}
		Settings.set({levelProgress: 1});
		var game = new Game();
		game.show();
		game.init();
		game.playCompany();
	}*/
	
	/*inline function levelSelectMenu():Void {
		var menu:Array<String> = ["training"];
		var i = 1;
		var end = Settings.read().levelProgress;
		while(i <= end) { //Lvl.exists(i)
			menu.push(Lang.get("level")+" "+i);
			i++;
		}
		menu.push("back");
		setCustomMenu(13, menu);
	}*/
	
	function setMenu(id:Int):Void {
		current = id;
		var menu = createMenu(current);
		
		items = [];
		for (i in 0...menu.length) {
			var item = Lang.get(menu[i]);
			items.push(new MenuButton(item, font, 1, {x: 0, y: 0}));
		}
		onResize();
	}
	
	/*function setCustomMenu(id:Int, menu:Array<String>):Void {
		current = id;

		items = [];
		for (i in 0...menu.length) {
			var item = Lang.get(menu[i]);
			items.push(new MenuButton(item, font, 1, {x: 0, y: 0}));
		}
		onResize();
	}*/
	
	override function onMouseMove(id:Int):Void {
		var x = pointers[id].x;
		var y = pointers[id].y;
		var state = true;
		for (i in items) {
			if (i.check(x, y)) {
				i.isOver = state;
				state = false;
			} else i.isOver = false;
		}
	}
	
	override function onMouseDown(id:Int):Void {
		onMouseMove(id);
		if (Screen.touch) return;
		var x = pointers[id].x;
		var y = pointers[id].y;
		for (i in 0...items.length) {
			if (items[i].check(x, y)) {
				choose(i);
				break;
			}
		}
	}
	
	override function onMouseUp(id:Int):Void {
		if (!Screen.touch) return;
		var x = pointers[id].x;
		var y = pointers[id].y;
		for (i in 0...items.length) {
			if (items[i].check(x, y)) {
				choose(i);
				break;
			}
		}
	}
	
	override function onResize():Void {
		var min = Screen.w < Screen.h ? Screen.w : Screen.h;
		fontSize = Std.int(min/10/2)*2;
		var maxW = 0.0;
		for (item in items) {
			var w = font.width(fontSize, item.text, Lang.fontGlyphs);
			if (maxW < w) maxW = w;
		}
		
		for (i in 0...items.length) {
			var fh = font.height(fontSize, Lang.fontGlyphs);
			var y = (Screen.h - items.length * fh) / 2 + i * fh;
			items[i].rect.x = fh;
			items[i].rect.y = y;
			items[i].rect.w = maxW;
			items[i].rect.h = fh;
			items[i].fontSize = fontSize;
		}
		bgscale = Std.int(min/200);
		if (bgscale < 1) bgscale = 1;
		Particle.rescaleAll(particles, bgscale);
	}
	
	override function onRender(frame:Framebuffer):Void {
		var g = frame.g2;
		g.begin(true, 0xFFBDC3CD);
		drawParticles(g);
		drawBG(g);
		drawMenu(g);
		debugScreen(g);
		g.end();
	}
	
	inline function drawParticles(g:Graphics):Void {
		for (p in particles) p.draw(g, Screen.w, Screen.h);
	}
	
	inline function drawBG(g:Graphics):Void {
		g.color = 0xFFFFFFFF;
		var w = Assets.images.menubg.width * bgscale;
		var h = Assets.images.menubg.height * bgscale;
		g.drawScaledImage(Assets.images.menubg, Screen.w - w, Screen.h - h, w, h);
	}
	
	inline function drawMenu(g:Graphics):Void {
		for (i in items) i.draw(g);
	}
	
}

class MenuButton extends ui.Trigger {
	
	public var text:SuperString;
	public var font:Font;
	public var fontSize:Int;
	public var isOver:Bool;
	public var align:Int;
	
	public function new(text:String, font:Font, size:Int, ?p:Point, ?r:Rect, align=0) {
		this.text = text;
		this.font = font;
		this.fontSize = size;
		this.align = align;
		if (r == null) r = {
			x: p.x, y: p.y,
			w: font.width(size, text, Lang.fontGlyphs),
			h: font.height(size, Lang.fontGlyphs)
		}
		super(r);
	}
	
	public function draw(g:Graphics):Void {
		if (text.substring(0, 1) == "/") {
			drawInactive(g);
			return;
		}
		if (isOver) {
			g.color = 0xFF000000;
			g.fillRect(rect.x, rect.y, rect.w, rect.h);
			g.fillRect(0, rect.y, rect.x, rect.h);
			g.fillTriangle(
				rect.x + rect.w, rect.y,
				rect.x + rect.w, rect.y + rect.h,
				rect.x + rect.w + rect.h, rect.y
			);
			g.color = 0xFFFFFFFF;
		} else g.color = 0xFF000000;
		g.font = font;
		g.fontSize = fontSize;
		g.fontGlyphs = Lang.fontGlyphs;
		var offx = alignment();
		g.drawString(text, rect.x + offx, rect.y);
	}
	
	public function drawInactive(g:Graphics):Void {
		if (isOver) {
			g.color = 0x88000000;
			g.fillRect(rect.x, rect.y, rect.w, rect.h);
			g.fillRect(0, rect.y, rect.x, rect.h);
			g.fillTriangle(
				rect.x + rect.w, rect.y,
				rect.x + rect.w, rect.y + rect.h,
				rect.x + rect.w + rect.h, rect.y
			);
			g.color = 0x88FFFFFF;
		} else g.color = 0x88000000;
		g.font = font;
		g.fontSize = fontSize;
		g.fontGlyphs = Lang.fontGlyphs;
		var offx = alignment();
		g.drawString(text.substring(1), rect.x + offx, rect.y);
	}
	
	inline function alignment():Float {
		var offx = 0.0;
		switch(align) {
		case 1: //center
			var w = font.width(fontSize, text, Lang.fontGlyphs);
			offx = (rect.w - w) / 2;
		case 2: //right
			var w = font.width(fontSize, text, Lang.fontGlyphs);
			offx = (rect.w - w);
		}
		return offx;
	}
	
}
