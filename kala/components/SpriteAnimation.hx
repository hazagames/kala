package kala.components;

import haxe.ds.StringMap;
import kala.components.SpriteAnimation.SpriteAnimationData;
import kala.EventHandle.CallbackHandle;
import kala.Kala.TimeUnit;
import kala.math.Rect.RectI;
import kala.objects.Object;
import kala.objects.Sprite;
import kha.FastFloat;
import kha.Image;

@:access(kala.objects.Sprite)
class SpriteAnimation extends Component<Sprite> {

	public var crAnim(default, null):SpriteAnimationData;
	public var crFrame(default, set):Int;
	
	public var onAnimComplete:CallbackHandle<SpriteAnimation->Void>;
	
	private var _animations:StringMap<SpriteAnimationData> = new StringMap<SpriteAnimationData>();
	
	private var _timeLeft:Int;
	
	private var _lastAddedKey:String;
	
	public function new() {
		super();
		onAnimComplete = addCBHandle(new CallbackHandle<SpriteAnimation->Void>());
	}
	
	override public function reset():Void {
		super.reset();
		crAnim = null;
		removeAllAnimations();
	}
	
	override public function destroy():Void {
		super.destroy();
		
		crAnim = null;
		
		removeAllAnimations();
		_animations = null;
		
		onAnimComplete = null;
	}
	
	override public function addTo(object:Sprite):SpriteAnimation {
		super.addTo(object);
		
		object.onPostUpdate.notifyComponentCB(this, update);
		object.animation = this;
		
		return this;
	}
	
	override public function remove():Void {
		if (object != null) {
			object.onPostUpdate.removeComponentCB(this, update);
			object.animation = null;
		}
		
		super.remove();
	}
	
	public function play(?key:String, ?delay:UInt, ?reversed:Bool):SpriteAnimation {
		if (key == null) {
			if (_lastAddedKey == null) return null;
			key = _lastAddedKey;
		}
		
		crAnim = _animations.get(key);
		
		if (crAnim != null) {
			crAnim.delay = _timeLeft = (delay == null) ? crAnim.delay : delay;
			crAnim.reversed = (reversed == null) ? crAnim.reversed : reversed;
			crFrame = crAnim.reversed ? crAnim.frames.length - 1 : 0; 
			if (crAnim.image != null) object.image = crAnim.image;
		} else {
			return null;
		}
		
		return this;
	}
	
	public inline function pause():Void {
		crAnim.delay = -1;
	}
	
	/**
	 * Add a new animation.
	 * 
	 * @param	key				String key used to access animation.
	 * @param	image			Source image contains sprite sheet. If set to null, will use the current image of the owner sprite (set by sprite.loadImage or most preview calling of addAnim). If this argument is null and the component wasn't added to a sprite or the sprite image is null, this method will do nothing and return null.
	 * @param	sheetX			X position of sprite sheet. If set to smaller than 0, will use the current frame x of the owner sprite (set by sprite.loadImage or most preview calling of addAnim). If this argument is set to smaller than 0 and the component wasn't added to a sprite, this method will do nothing and return null.
	 * @param	sheetY			Y position of sprite sheet. If set to smaller than 0, will use the current frame y of the owner sprite (set by sprite.loadImage or most preview calling of addAnim). If this argument is set to to smaller than 0 and the component wasn't added to a sprite, this method will do nothing and return null.
	 * @param	frameWidth		Frame width. If set to 0, will use the current frame width of the owner sprite (set by sprite.loadImage or most preview calling of addAnim). If this argument is set to 0 and the component wasn't added to a sprite, this method will do nothing and return null.
	 * @param	frameHeight		Frame height. If set to 0, will use the current frame height of the owner sprite (set by sprite.loadImage or most preview calling of addAnim). If this argument is set to 0 and the component wasn't added to a sprite, this method will do nothing and return null.
	 * @param	totalFrames		Total number of frames in sprite sheet.
	 * @param	framesPerRow	Number of frames per row. (Last row may have less frames.)
	 * @param	delay			Delay time between frames. In frames or milliseconds depends on Kala.timingUnit.
	 * 
	 * @return					Return this component if success otherwise return null.
	 */
	public function addAnim(
		key:String,
		?image:Image,
		sheetX:Int, sheetY:Int, frameWidth:UInt, frameHeight:UInt,
		totalFrames:UInt,
		framesPerRow:UInt,
		delay:UInt
	):SpriteAnimation {
		if (
			(image == null && (object == null || object.image == null)) ||
			(object == null && (sheetX < 0 || sheetY < 0 || frameWidth == 0 || frameHeight == 0))
		) {
			return null;
		}
		
		if (image == null) image = object.image;
		else object.image = image;
		
		if (sheetX < 0) sheetX = object.frameRect.x;
		else object.frameRect.x = sheetX;
		
		if (sheetY < 0) sheetY = object.frameRect.y;
		else object.frameRect.y = sheetY;
		
		if (frameWidth == 0) frameWidth = object.frameRect.width;
		else object.frameRect.width = frameWidth;
		
		if (frameHeight == 0) frameHeight = object.frameRect.height;
		else object.frameRect.height = frameHeight;
		
		var anim = new SpriteAnimationData(key, image, delay);
		
		var col:UInt = 0;
		var row = 0;
		for (i in 0...totalFrames) {
			anim.addFrame(sheetX + frameWidth * col, sheetY + frameHeight * row, frameWidth, frameHeight);
			
			col++;
			
			if (col == framesPerRow) {
				col = 0;
				row++;
			}
		}
		
		_animations.set(key, anim);
		_lastAddedKey = key;
		
		return this;
	}
	
	public function addAnimFromSpriteData(?key:String, ?image:Image, data:SpriteData, delay:Int):SpriteAnimation {
		if (key == null) key = data.key;
		
		if (image == null) {
			if (data.image == null) {
				image = object.image;
			} else {
				image = data.image;
			}
		}
			
		object.image = image;
		object.frameRect.copy(data.frames[0]);
		
		var anim = new SpriteAnimationData(key, image, delay);
		
		for (frame in data.frames) {
			anim.addFrameRect(frame);
		}
		
		_animations.set(key, anim);
		_lastAddedKey = key;
		
		return this;
	}
	
	public function removeAnim(key:String):SpriteAnimation {
		_animations.remove(key);
		if (_lastAddedKey == key) _lastAddedKey = null;
		
		return this;
	}
	
	public function getAnimations():Array<SpriteAnimationData> {
		var array = new Array<SpriteAnimationData>();
		for (key in _animations.keys()) {
			array.push(_animations.get(key));
		}
		return array;
	}
	
	public function removeAllAnimations():Void {
		for (key in _animations.keys()) _animations.remove(key);
	}
	
	function update(obj:Object, delta:FastFloat):Void {
		if (crAnim != null && crAnim.delay > -1) {
			if (Kala.timingUnit == TimeUnit.FRAME) {
				_timeLeft--;
			} else {
				_timeLeft -= Std.int(delta * 1000);
			}
			
			if (_timeLeft <= 0) {
				_timeLeft = crAnim.delay;
				
				if (!crAnim.reversed) {
					if (crFrame < crAnim.frames.length - 1) {
						crFrame++;
					} else {
						crFrame = 0;
						for (callback in onAnimComplete) callback.cbFunction(this);
					}
				} else {
					if (crFrame > 0) {
						crFrame--;
					} else {
						crFrame = crAnim.frames.length - 1;
						for (callback in onAnimComplete) callback.cbFunction(this);
					}
				}

			}
		}
	}
	
	inline function set_crFrame(value:Int):Int {
		object.frameRect.copy(crAnim.frames[crFrame = value]);
		return value;
	}

}

class SpriteAnimationData {
	
	public var key(default, null):String;
	public var image:Image;
	public var frames:Array<RectI>;
	public var delay:Int;
	public var reversed:Bool;
	
	public inline function new(key:String, image:Image, delay:UInt) {
		this.key = key;
		this.image = image;
		this.delay = delay;
		
		frames = new Array<RectI>();
		reversed = false;
	}

	@:extern
	public inline function addFrame(x:UInt, y:UInt, width:UInt, height:UInt):SpriteAnimationData {
		frames.push(new RectI(x, y, width, height));
		return this;
	}
	
	@:extern
	public inline function addFrameRect(rect:RectI):SpriteAnimationData {
		frames.push(rect.clone());
		return this;
	}
	
	@:extern
	public inline function removeFrame(index:Int):SpriteAnimationData {
		frames.splice(index, 1);
		return this;
	}
	
}