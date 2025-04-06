package objects;

import haxe.macro.Expr.Catch;
import engine.editors.CharacterEditor;
import flixel.FlxG;
import engine.Conductor;
import engine.Paths;
import haxe.Json;
import openfl.Assets;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	public var camOffsets:Array<Float> = [0, 0];

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false, ?data:CharacterData = null)
	{
		animOffsets = new Map<String, Array<Dynamic>>();
		super(x, y);

		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = true;
		
		if (data == null) {
			var str:String = null;

			try {
				str = Assets.getText("assets/data/characters/" + character + ".json");
				data = Json.parse(str);
			} catch(e) {
				trace('$e');
			}
		}

		switch (curCharacter)
		{
			default:
				if (data != null) {
					frames = tex = Paths.getSparrow('characters/${data.imagePath}');

					if (data.antialiasing != null)
						antialiasing = data.antialiasing;

					var position:Array<Float> = [0, 0];
					if (data.positionOffsets != null)
						position = data.positionOffsets;
					setPosition(x + position[0], y + position[1]);
	
					if (data.camOffsets != null)
						camOffsets = data.camOffsets;
	
					if (data.flipX != null)
						flipX = data.flipX;
	
					for (anim in data.animations) {
						var name:String = anim.name;
						var prefix:String = anim.prefix;
						var fps:Int = anim.fps;
	
						var loop:Bool = true;
						if (anim.loop != null)
							loop = anim.loop;
	
						if (anim.indices != null)
							animation.addByIndices(name, prefix, anim.indices, null, fps, loop)
						else
							animation.addByPrefix(name, prefix, fps, loop);
	
						if (anim.offsets != null)
							addOffset(name, anim.offsets[0], anim.offsets[1]);
					}
				}
				else {
					trace('Couldn\'t find the Character! ($character).');
				}

			case 'owata':
				loadGraphic(Paths.getImage("characters/owata"), true, 87, 60);

				animation.add("idle", [0, 1, 2, 3, 3, 3], 12, false);
				animation.add("singRIGHT", [4, 4, 5, 5, 5], 12, false);
				animation.add("singLEFT", [6, 6, 7, 7, 7], 12, false);
				animation.add("singUP", [8, 8, 9, 9, 9], 12, false);
				animation.add("singDOWN", [10, 10, 11, 11, 11], 12, false);
				animation.add("pose", [12, 13, 14, 14, 14], 12, false);
				animation.add("mouth-open", [15, 15], 12, true);
				animation.add("mouth-closed", [16, 16], 12, true);

				antialiasing = false;

				camOffsets[0] = 64;
				camOffsets[1] = -124;

				setGraphicSize(87 * 2);
			
			case 'owata-bf':
				loadGraphic(Paths.getImage("characters/owata-bf"), true, 129, 109);

				animation.add("idle", [0, 1, 2, 3, 3, 3], 12, false);
				animation.add("singRIGHT", [4, 4, 5, 5, 5], 12, false);
				animation.add("singLEFT", [6, 6, 7, 7, 7], 12, false);
				animation.add("singUP", [8, 8, 9, 9, 9], 12, false);
				animation.add("singDOWN", [10, 10, 11, 11, 11], 12, false);

				antialiasing = false;

				camOffsets[0] = -64;
				camOffsets[1] = -75;

				setGraphicSize(129 * 2);
		}

		dance();
	}

	public var dancing:Bool = false;
	override function update(elapsed:Float)
	{
		if (!isPlayer && animation.curAnim != null) {
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 6;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}
		else if (isPlayer && animation.curAnim != null) {
			// Singing Animations CANNOT be looped!
			if (animation.curAnim.name.startsWith('sing') && animation.curAnim.looped == true)
				animation.curAnim.looped = false;
		}

		super.update(elapsed);

		if (animation.curAnim != null) {
			var playingAnims:Bool = animation.curAnim.name == 'idle' || animation.curAnim.name.startsWith('dance');
			
			if (!playingAnims || playingAnims && animation.curAnim.finished)
				dancing = false;
			else
				dancing = true;
		}
	}

	private var danced:Bool = false;
	public function dance()
	{
		if (!debugMode)
		{
			if (animation.exists('danceLeft') && animation.exists('danceRight')) {
				danced = !danced;

				if (danced)
					playAnim('danceRight');
				else
					playAnim('danceLeft');
			}
			else {
				playAnim('idle');
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);
		if (animation.curAnim == null) {
			trace('Animation is null??? wtf???');
			return;
		}

		var daOffset = animOffsets.get(animation.curAnim.name);
		if (animOffsets.exists(animation.curAnim.name))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}

typedef AnimationData =
{
	var name:String;
	var prefix:String;
	var fps:Int;
	var ?loop:Bool;
	var ?offsets:Array<Float>;
	var ?indices:Array<Int>;
}

typedef CharacterData =
{
	var imagePath:String;
	var ?positionOffsets:Array<Float>;
	var ?camOffsets:Array<Float>;
	var animations:Array<AnimationData>;
	var ?flipX:Bool;
	var ?antialiasing:Bool;
}