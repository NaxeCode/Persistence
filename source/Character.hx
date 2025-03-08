// source/Character.hx - Base class for all characters
package;

import flixel.FlxSprite;

class Character extends FlxSprite
{
	// Base stats
	public var level:Int = 1;
	public var health:Float = 100;
	public var maxHealth:Int = 100;
	public var atk:Int = 10;
	public var def:Int = 5;
	public var spd:Int = 5;

	// Battle state
	public var isDefending:Bool = false;
	public var currentTurn:Bool = false;

	public function new(x:Float, y:Float)
	{
		super(x, y);
	}

	public function takeDamage(amount:Int):Float
	{
		var damage = Math.max(1, amount - (isDefending ? def * 2 : def));
		health -= damage;
		if (health <= 0)
		{
			health = 0;
			kill();
		}
		return damage;
	}

	public function attack(target:Character):Float
	{
		return target.takeDamage(atk);
	}

	public function defend():Void
	{
		isDefending = true;
	}

	public function endTurn():Void
	{
		isDefending = false;
		currentTurn = false;
	}
}
