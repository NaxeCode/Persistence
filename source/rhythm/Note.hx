package rhythm;

import flixel.FlxSprite;

class Note extends FlxSprite
{
	public function new(X:Int, Y:Int)
	{
		super(X, Y);

		makeGraphic(50, 15, 0xff0000ff);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
