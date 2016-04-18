
package kala;

import kha.Canvas;

@:allow(kala.Kala)
class Debug {
	
	#if (debug || kala_debug)
	private static var _drawLayers(default, null):Array<Array<DebugDrawCall>> = new Array<Array<DebugDrawCall>>();
	
	public static var collisionDebug:Bool = false;
	#end

	public static function error(message:String):Void {
		
	}
	
	#if (debug || kala_debug)
	public static function addDrawLayer():Array<DebugDrawCall> {
		var layer = new Array<DebugDrawCall>();
		_drawLayers.push(layer);
		return layer;
	}
	
	static inline function draw():Void {
		var previewCanvas:Canvas = null;
		
		for (layer in _drawLayers) {
			for (call in layer.copy()) {
				layer.remove(call);
				
				if (previewCanvas != call.canvas) {
					if (previewCanvas != null) previewCanvas.g2.end();
					call.canvas.g2.begin(false);
				}
				
				call.exec();
				
				previewCanvas = call.canvas;
			}
		}
		
		if (previewCanvas != null) previewCanvas.g2.end();
	}
	#end
	
}

#if (debug || kala_debug)
class DebugDrawCall {
	
	public var canvas:Canvas;
	public var callback:Canvas->Void;
	
	public inline function new(canvas:Canvas, callback:Canvas->Void) {
		this.canvas = canvas;
		this.callback = callback;
	}
	
	@:extern
	public inline function exec():Void {
		callback(canvas);
	}
	
}
#end