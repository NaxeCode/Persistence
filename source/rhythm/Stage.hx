package rhythm;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class Stage extends FlxTypedSpriteGroup<FlxSprite>
{
	public function new(maxSize:Int = 0)
	{
		super(0, 0, maxSize);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
