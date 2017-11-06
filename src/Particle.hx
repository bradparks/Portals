package;

import kha.graphics2.Graphics;
import kha.math.Vector2;
import kha.Color;

class Particle {
	
	var scale:Float;
	var sx:Float;
	var sy:Float;
	var x:Float;
	var y:Float;
	var speed:Vector2;
	var wobble:Vector2;
	var color:Color;
	var stime:Int;
	var time:Int;
	var delay:Int;
	
	public function new(x:Float, y:Float, speed:Vector2, wobble:Vector2, color:Int, time:Int, delay:Int, scale:Float) {
		this.scale = scale;
		sx = this.x = x;
		sy = this.y = y;
		this.speed = speed;
		this.wobble = wobble;
		this.color = color;
		stime = this.time = time;
		this.delay = delay;
	}
	
	public function draw(g:Graphics, cx:Float, cy:Float):Void {
		if (delay > 0) {delay--; return;}
		x += speed.x - wobble.x * 2 * Math.random() + wobble.x;
		y += speed.y - wobble.y * 2 * Math.random() + wobble.y;
		time--;
		color.A = time / stime;
		g.color = color;
		g.fillRect(x + cx, y + cy, scale, scale);
		if (time == 0) {
			time = stime;
			x = sx;
			y = sy;
		}
	}
	
	public static function rescaleAll(particles:Array<Particle>, scale:Float):Void {
		for (i in particles) i.rescale(scale);
	}
	
	public function rescale(scale:Float):Void {
		x = x / this.scale * scale;
		y = y / this.scale * scale;
		sx = sx / this.scale * scale;
		sy = sy / this.scale * scale;
		speed.x = speed.x / this.scale * scale;
		speed.y = speed.y / this.scale * scale;
		wobble.x = wobble.x / this.scale * scale;
		wobble.y = wobble.y / this.scale * scale;
		this.scale = scale;
	}
	
	function drawArr(cx:Float, cy:Float):Void {
		/*for(int i=0;i<l.tsize/2;i++) {
			bit[i][0+c]+=rnd.nextInt(3)-1; //x
			bit[i][1+c]-=rnd.nextInt(3); //y
			if (bit[i][0+c]<bx-5) bit[i][0+c]=bx-5;
			if (bit[i][0+c]>bx+l.tsize+5) bit[i][0+c]=bx+l.tsize+5;

			if (bit[i][1+c]<by-l.tsize/2) {
				//if (rnd.nextInt(5)==0)
				bit[i][0+c]=bx+rnd.nextInt(25);
				bit[i][1+c]=by;
			}
			g.fillRect(bit[i][0+c]-Hero.cx,bit[i][1+c]-Hero.cy,1,1);
		}*/
	}
	
}
