package;

import openfl.utils.Assets;
import flixel.FlxG;
import lime.app.Application;
import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		haxe.Log.trace = function(v:Dynamic, ?infos:haxe.PosInfos) {
			#if (target.threaded)
			sys.thread.Thread.create(() -> {
				var log:String = '${infos.fileName}:${infos.methodName}():${infos.lineNumber}: $v';
				Sys.println(log);
			});
			#else
			var log:String = '${infos.fileName}:${infos.methodName}():${infos.lineNumber}: $v';
			Sys.println(log);
			#end
		};

		// Please keep the Engine name somewhere as credit if you change this, thanks!
		Application.current.window.title = Application.current.window.title + ' - Papaya Engine Refreshed';

		super();

		addChild(new FlxGame(0, 0, TitleState));

		#if debug
		FlxG.autoPause = true; // Causes instability with the editors if turned off
		#else
		FlxG.autoPause = false;
		#end

		engine.Options.init();
		engine.Styles.StyleHandler.init();

		#if debug
		addChild(new FPS(10, 3, 0xFFFFFF));
		#end
	}
}
