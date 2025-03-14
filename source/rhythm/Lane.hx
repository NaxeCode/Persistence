package rhythm;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class Lane extends FlxTypedSpriteGroup<Note>
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