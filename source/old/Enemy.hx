// source/Enemy.hx
package;

import flixel.FlxG;

class Enemy extends Character
{
	public var experienceReward:Int = 10;
	public var goldReward:Int = 5;
	public var aiType:String = "aggressive"; // aggressive, defensive, balanced

	public function new(x:Float, y:Float, type:String = "normal")
	{
		super(x, y);

		// Default stats
		maxHealth = 50;
		health = maxHealth;
		atk = 8;
		def = 3;
		spd = 3;

		setupType(type);
	}

	private function setupType(type:String):Void
	{
		switch (type)
		{
			case "normal":
				makeGraphic(16, 16, 0xff3333aa);
				aiType = "balanced";
			case "strong":
				makeGraphic(20, 20, 0xff6633aa);
				maxHealth = 80;
				health = maxHealth;
				atk = 12;
				def = 6;
				aiType = "aggressive";
				experienceReward = 20;
				goldReward = 10;
			case "fast":
				makeGraphic(12, 12, 0xff33aa66);
				maxHealth = 30;
				health = maxHealth;
				spd = 10;
				atk = 6;
				aiType = "aggressive";
				experienceReward = 15;
				goldReward = 8;
			case "tank":
				makeGraphic(18, 18, 0xff663333);
				maxHealth = 100;
				health = maxHealth;
				def = 10;
				spd = 2;
				aiType = "defensive";
				experienceReward = 18;
				goldReward = 12;
		}
	}

	public function takeTurn(players:Array<Player>):Void
	{
		// Simple AI based on aiType
		var target = selectTarget(players);

		if (target == null)
			return;

		switch (aiType)
		{
			case "aggressive":
				attack(target);
			case "defensive":
				if (health < maxHealth * 0.3 || FlxG.random.bool(25))
				{
					defend();
				}
				else
				{
					attack(target);
				}
			case "balanced":
				if (health < maxHealth * 0.5 && FlxG.random.bool(50))
				{
					defend();
				}
				else
				{
					attack(target);
				}
			default:
				attack(target);
		}
	}

	private function selectTarget(players:Array<Player>):Player
	{
		// For now, just target a random living player
		var livingPlayers = players.filter(function(p) return p.alive);

		if (livingPlayers.length == 0)
			return null;

		return livingPlayers[FlxG.random.int(0, livingPlayers.length - 1)];
	}
}
