// source/Player.hx
package;

import flixel.FlxG;
import flixel.FlxObject;

class Player extends Character
{
	// Additional player-specific stats
	public var experience:Int = 0;
	public var experienceToNextLevel:Int = 100;
	public var skillPoints:Int = 0;

	public function new(x:Float, y:Float)
	{
		super(x, y);
		makeGraphic(16, 16, 0xffaa1111);

		// Set base stats
		maxHealth = 100;
		health = maxHealth;
		atk = 15;
		def = 10;
		spd = 8;

		setPhysics();
	}

	function setPhysics()
	{
		this.drag.x = 80;
		this.drag.y = 80;
		this.maxVelocity.x = 80;
		this.maxVelocity.y = 80;
	}

	override public function update(elapsed:Float)
	{
		if (!FlxG.keys.pressed.X)
		{ // Only handle movement when not in battle mode
			handleMovement();
			handleAnimations();
		}

		super.update(elapsed);
	}

	function handleMovement()
	{
		// Reset velocity
		velocity.set(0, 0);

		// Apply horizontal movement
		if (FlxG.keys.pressed.LEFT)
			velocity.x = -80;
		else if (FlxG.keys.pressed.RIGHT)
			velocity.x = 80;

		// Apply vertical movement
		if (FlxG.keys.pressed.UP)
			velocity.y = -80;
		else if (FlxG.keys.pressed.DOWN)
			velocity.y = 80;
	}

	function handleAnimations()
	{
		// Set facing direction based on velocity
		if (velocity.x < 0)
			facing = LEFT;
		else if (velocity.x > 0)
			facing = RIGHT;

		if (velocity.y < 0)
			facing = UP;
		else if (velocity.y > 0)
			facing = DOWN;

		// Set animation based on movement state
		// TODO: Implement animation system
		// animation.play(velocity.x != 0 || velocity.y != 0 ? "walk" : "idle");
	}

	public function gainExperience(amount:Int):Void
	{
		experience += amount;
		if (experience >= experienceToNextLevel)
		{
			levelUp();
		}
	}

	private function levelUp():Void
	{
		level++;
		experience -= experienceToNextLevel;
		experienceToNextLevel = Math.floor(experienceToNextLevel * 1.5);

		// Increase stats
		maxHealth += 10;
		health = maxHealth;
		atk += 2;
		def += 1;
		spd += 1;
		skillPoints++;
	}
}
