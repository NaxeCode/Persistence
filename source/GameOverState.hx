// source/GameOverState.hx
package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class GameOverState extends FlxState
{
	override public function create():Void
	{
		super.create();

		var gameOverText = new FlxText(0, FlxG.height / 3, FlxG.width, "GAME OVER");
		gameOverText.setFormat(null, 32, FlxColor.RED, "center");
		add(gameOverText);

		var restartBtn = new FlxButton(FlxG.width / 2 - 40, FlxG.height / 2 + 50, "Restart", function()
		{
			FlxG.switchState(() -> new PlayState());
		});
		add(restartBtn);
	}
}
