package kala.math;

import kha.FastFloat;

/**
 * Used for transformations around point.  
 */
class Vec2T {
	
	public var ox:FastFloat;
	public var oy:FastFloat;
		
	public var x:FastFloat;
	public var y:FastFloat;

	public inline function new(x:FastFloat = 0, y:FastFloat = 0, originX:FastFloat = 0, originY:FastFloat = 0) {
		this.x = x;
		this.y = y;
		
		this.ox = originX;
		this.oy = originY;
	}
	
	@:extern
	public inline function set(x:FastFloat = 0, y:FastFloat = 0, originX:FastFloat = 0, originY:FastFloat = 0):Void {
		this.x = x;
		this.y = y;
		
		this.ox = originX;
		this.oy = originY;
	}
	
	@:extern
	public inline function copy(vec:Vec2T):Void {
		this.x = vec.x;
		this.y = vec.y;
	}
	
	@:extern
	public inline function clone():Vec2T {
		return new Vec2T(x, y, ox, oy);
	}
	
	@:extern
	public inline function setXY(x:FastFloat = 0, y:FastFloat = 0):Vec2T {
		this.x = x;
		this.y = y;
		
		return this;
	}
	
	@:extern
	public inline function setOrigin(originX:FastFloat = 0, originY:FastFloat = 0):Vec2T {
		this.ox = originX;
		this.oy = originY;
		
		return this;
	}
	
	@:extern
	public inline function setXBetween(x1:FastFloat, x2:FastFloat, xpercent:Int = 50):Vec2T {
		this.x = x1 + (x2 - x1) * xpercent / 100;
		return this;
	}
	
	@:extern
	public inline function setYBetween(y1:FastFloat, y2:FastFloat, ypercent:Int = 50):Vec2T {
		this.y = y1 + (y2 - y1) * ypercent / 100;
		return this;
	}
	
	@:extern
	public inline function setXYBetween(
		x1:FastFloat, y1:FastFloat, x2:FastFloat, y2:FastFloat,
		xpercent:Int = 50, ypercent:Int = 50
	):Vec2T {
		this.x = x1 + (x2 - x1) * xpercent / 100;
		this.y = y1 + (y2 - y1) * ypercent / 100;
		
		return this;
	}

	@:extern
	public inline function move(x:FastFloat, y:FastFloat):Void {
		this.x += x;
		this.y += y;
	}
	
	@:extern
	public inline function moveOrigin(ox:FastFloat, oy:FastFloat):Void {
		this.ox += ox;
		this.oy += oy;
	}
	
	public inline function toString():String {
		return "Vec2T(x: " + x + ", y: " + y + ", ox: " + ox + ", oy: " + oy + ")" ;
	}
	
}