package game;

import kha.graphics2.Graphics;
import kha.Color;
import Types.IPoint;
import Types.Point;

class AimMode { //TODO remake it to use in turrels too
	
	var player:Player;
	var lvl:Lvl;
	var tsize(get, never):Int;
	function get_tsize() return lvl.tsize;
	
	public var state:Bool = false;
	var tiles:Array<IPoint>; //in aimline
	var aimLine:{p:Point, p2:Point};
	var sideLine:{p:Point, p2:Point};
	//to portals
	public var tile:IPoint;
	public var side:Int;
	
	public function new(player:Player, lvl:Lvl) {
		this.player = player;
		this.lvl = lvl;
	}
	
	public function draw(g:Graphics, aimType:Int):Void {
		if (!state || tile == null) return;
		var props = lvl.getProps(1, tile.x, tile.y);
		if (!props.portalize) g.color = 0x66808080;
		else {
			var color:Color = Portal.colors[aimType];
			color.A = 0.4; //0x66 / 255
			g.color = color;
			if (sideLine != null)
			g.drawLine(
				sideLine.p.x + lvl.camera.x,
				sideLine.p.y + lvl.camera.y,
				sideLine.p2.x + lvl.camera.x,
				sideLine.p2.y + lvl.camera.y,
				lvl.scale
			);
		}
		#if debug
		/*for (tile in tiles) g.drawRect(
			tile.x * tsize + lvl.camera.x,
			tile.y * tsize + lvl.camera.y,
			tsize, tsize
		);*/
		#end
		if (aimLine == null) return;
		g.drawLine(
			aimLine.p.x + lvl.camera.x,
			aimLine.p.y + lvl.camera.y,
			aimLine.p2.x + lvl.camera.x,
			aimLine.p2.y + lvl.camera.y,
			lvl.scale
		);
	}
	
	public function aim(p:Point, p2:Point):Void {
		tiles = lineOfSight(p, p2);
		if (tiles.length < 2) {
			tile = null;
			return;
		}
		tile = tiles[tiles.length-1];
		var end = checkSides(p, p2, tile);
		if (end == null) aimLine = null;
		else aimLine = {
			p: {x: p.x, y: p.y},
			p2: {x: end.x, y: end.y}
		}
	}
	
	function lineOfSight(p:Point, p2:Point):Array<IPoint> {
		var p = {x: p.x/tsize, y: p.y/tsize};
		var p2 = {x: p2.x/tsize, y: p2.y/tsize};
		var dx = Math.abs(p2.x - p.x);
		var dy = Math.abs(p2.y - p.y);
		var x = Math.floor(p.x);
		var y = Math.floor(p.y);
		var n = 1;
		var x_inc = 0, y_inc = 0;
		var error = 0.0;
		
		if (dx == 0) {
			x_inc = 0;
			error = Math.POSITIVE_INFINITY;
		} else if (p2.x > p.x) {
			x_inc = 1;
			n += Math.floor(p2.x) - x;
			error = (Math.floor(p.x) + 1 - p.x) * dy;
		} else {
			x_inc = -1;
			n += x - Math.floor(p2.x);
			error = (p.x - Math.floor(p.x)) * dy;
		}
		
		if (dy == 0) {
			y_inc = 0;
			error -= Math.POSITIVE_INFINITY;
		} else if (p2.y > p.y) {
			y_inc = 1;
			n += Math.floor(p2.y) - y;
			error -= (Math.floor(p.y) + 1 - p.y) * dx;
		} else {
			y_inc = -1;
			n += y - Math.floor(p2.y);
			error -= (p.y - Math.floor(p.y)) * dx;
		}
		
		var points:Array<IPoint> = [];
		while (n > 0) {
			points.push({x: x, y: y});
			var tile = lvl.getProps(1, x, y);
			if (!tile.permeable) break;
			
			if (error > 0) {
				y += y_inc;
				error -= dx;
			} else {
				x += x_inc;
				error += dy;
			}
			n--;
		}
		return points;
	}
	
	function checkSides(p:Point, p2:Point, tile:IPoint):Point {
		var tx = tile.x * tsize;
		var ty = tile.y * tsize;
		var sides:Array<Array<Point>> = [ //only to get side
			[{x: tx, y: ty}, {x: tx + tsize, y: ty}], //top of tile
			[{x: tx, y: ty + tsize}, {x: tx + tsize, y: ty + tsize}], //bottom
			[{x: tx, y: ty}, {x: tx, y: ty + tsize}], //left
			[{x: tx + tsize, y: ty}, {x: tx + tsize, y: ty + tsize}] //right
		];
		
		for (i in 0...sides.length) {
			if (i == 0 && p.y > ty) continue;
			if (i == 1 && p.y < ty + tsize) continue;
			if (i == 2 && p.x > tx) continue;
			if (i == 3 && p.x < tx + tsize) continue;
			var point = Utils.linesIntersect(p, p2, sides[i][0], sides[i][1]);
			if (point != null) {
				if (i == 0) {sides[i][0].y--; sides[i][1].y--;};
				if (i == 3) {sides[i][0].x++; sides[i][1].x++;};
				
				sideLine = {p: sides[i][0], p2: sides[i][1]};
				side = i;
				return point;
			}
		}
		return null;
	}
	
}
