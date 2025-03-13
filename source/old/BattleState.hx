// source/BattleState.hx
package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class BattleState extends FlxState
{
	// Game objects
	public var players:Array<Player>;
	public var enemies:Array<Enemy>;
	public var turnOrder:Array<Character>;
	public var currentTurnIndex:Int = 0;

	// UI elements
	private var battleMenu:FlxGroup;
	private var attackBtn:FlxButton;
	private var defendBtn:FlxButton;
	private var itemBtn:FlxButton;
	private var runBtn:FlxButton;
	private var statusText:FlxText;
	private var targetButtons:Array<FlxButton>;

	// Battle state
	private var battleActive:Bool = true;
	private var selectingTarget:Bool = false;
	private var selectedAction:String = "";

	override public function create():Void
	{
		super.create();

		// Initialize players array (typically from PlayState)
		if (players == null)
		{
			players = [new Player(50, 200)];
			add(players[0]);
		}

		// Create enemies (would normally depend on encounter)
		generateEnemies();

		// Setup UI
		createBattleUI();

		// Determine turn order based on speed
		calculateTurnOrder();

		// Start first turn
		startNextTurn();
	}

	private function generateEnemies():Void
	{
		enemies = [];

		// Create 1-3 random enemies
		var enemyCount = FlxG.random.int(1, 3);
		var enemyTypes = ["normal", "strong", "fast", "tank"];

		for (i in 0...enemyCount)
		{
			var type = enemyTypes[FlxG.random.int(0, enemyTypes.length - 1)];
			var enemy = new Enemy(300 + (i * 40), 150 + (i * 30), type);
			enemies.push(enemy);
			add(enemy);
		}
	}

	private function createBattleUI():Void
	{
		// Main battle menu
		battleMenu = new FlxGroup();

		attackBtn = new FlxButton(20, FlxG.height - 80, "Attack", onAttackClicked);
		defendBtn = new FlxButton(120, FlxG.height - 80, "Defend", onDefendClicked);
		itemBtn = new FlxButton(20, FlxG.height - 50, "Items", onItemClicked);
		runBtn = new FlxButton(120, FlxG.height - 50, "Run", onRunClicked);

		battleMenu.add(attackBtn);
		battleMenu.add(defendBtn);
		battleMenu.add(itemBtn);
		battleMenu.add(runBtn);

		// Status text
		statusText = new FlxText(20, 20, FlxG.width - 40, "Battle started!");
		statusText.setFormat(null, 14, FlxColor.WHITE, "center");

		add(battleMenu);
		add(statusText);

		// Target selection buttons (initially hidden)
		targetButtons = [];
	}

	private function calculateTurnOrder():Void
	{
		// Combine all characters
		turnOrder = [];
		for (player in players)
		{
			if (player.alive)
				turnOrder.push(player);
		}
		for (enemy in enemies)
		{
			if (enemy.alive)
				turnOrder.push(enemy);
		}

		// Sort by speed (highest first)
		turnOrder.sort((a, b) -> return b.spd - a.spd);

		currentTurnIndex = 0;
	}

	private function startNextTurn():Void
	{
		// Check for battle end
		if (checkBattleEnd())
			return;

		// Get next character
		if (currentTurnIndex >= turnOrder.length)
		{
			// End of round, recalculate turn order
			calculateTurnOrder();
			currentTurnIndex = 0;
		}

		var current = turnOrder[currentTurnIndex];
		current.currentTurn = true;

		if (Std.isOfType(current, Player))
		{
			// Player's turn - show menu
			showBattleMenu();
			statusText.text = "Player's turn! Choose an action.";
		}
		else if (Std.isOfType(current, Enemy))
		{
			// Enemy's turn - AI decides
			statusText.text = "Enemy is taking its turn...";

			// Add small delay before enemy acts
			haxe.Timer.delay(() ->
			{
				var enemy:Enemy = cast current;
				enemy.takeTurn(players);

				haxe.Timer.delay(() -> endCurrentTurn(), 1000); // Delay after enemy action
			}, 1000); // Delay before enemy acts
		}
	}

	private function endCurrentTurn():Void
	{
		if (currentTurnIndex < turnOrder.length)
		{
			var current = turnOrder[currentTurnIndex];
			current.endTurn();
		}

		currentTurnIndex++;
		startNextTurn();
	}

	private function checkBattleEnd():Bool
	{
		// Check if all players are defeated
		var allPlayersDead = true;
		for (player in players)
		{
			if (player.alive)
			{
				allPlayersDead = false;
				break;
			}
		}

		if (allPlayersDead)
		{
			endBattle(false); // Defeat
			return true;
		}

		// Check if all enemies are defeated
		var allEnemiesDead = true;
		for (enemy in enemies)
		{
			if (enemy.alive)
			{
				allEnemiesDead = false;
				break;
			}
		}

		if (allEnemiesDead)
		{
			endBattle(true); // Victory
			return true;
		}

		return false;
	}

	private function endBattle(victory:Bool):Void
	{
		battleActive = false;

		if (victory)
		{
			statusText.text = "Victory! You defeated all enemies!";

			// Calculate rewards
			var totalExp = 0;
			var totalGold = 0;

			for (enemy in enemies)
			{
				totalExp += enemy.experienceReward;
				totalGold += enemy.goldReward;
			}

			// Award experience
			for (player in players)
			{
				if (player.alive)
				{
					player.gainExperience(totalExp);
				}
			}

			// Add delay before returning to world
			haxe.Timer.delay(() -> new PlayState(), 3000);
		}
		else
		{
			statusText.text = "Defeat! Your party was wiped out!";

			// Add delay before game over
			haxe.Timer.delay(() -> new GameOverState(), 3000);
		}
	}

	// UI Handlers
	private function showBattleMenu():Void
	{
		battleMenu.visible = true;
		hideTacticalMenu();
		selectingTarget = false;
	}

	private function hideBattleMenu():Void
	{
		battleMenu.visible = false;
	}

	private function showTargetMenu():Void
	{
		hideBattleMenu();

		// Remove old target buttons if they exist
		for (btn in targetButtons)
		{
			remove(btn);
		}
		targetButtons = [];

		// Create target buttons for each enemy
		for (i in 0...enemies.length)
		{
			if (enemies[i].alive)
			{
				var btn = new FlxButton(enemies[i].x, enemies[i].y - 30, "Target", () -> onTargetSelected(i));
				targetButtons.push(btn);
				add(btn);
			}
		}

		// Add cancel button
		var cancelBtn = new FlxButton(20, FlxG.height - 30, "Cancel", () -> showBattleMenu());
		targetButtons.push(cancelBtn);
		add(cancelBtn);

		selectingTarget = true;
	}

	private function hideTacticalMenu():Void
	{
		for (btn in targetButtons)
		{
			remove(btn);
		}
		targetButtons = [];
	}

	private function onAttackClicked():Void
	{
		selectedAction = "attack";
		statusText.text = "Select a target to attack.";
		showTargetMenu();
	}

	private function onDefendClicked():Void
	{
		var currentPlayer:Player = cast turnOrder[currentTurnIndex];
		currentPlayer.defend();
		statusText.text = "Player is defending!";

		// End turn after defending
		haxe.Timer.delay(() -> endCurrentTurn(), 1000);
	}

	private function onItemClicked():Void
	{
		// TODO: Implement item menu
		statusText.text = "Item system not yet implemented!";
	}

	private function onRunClicked():Void
	{
		// 50% chance to escape
		if (FlxG.random.bool(50))
		{
			statusText.text = "Escaped successfully!";

			haxe.Timer.delay(() -> new PlayState(), 1000);
		}
		else
		{
			statusText.text = "Failed to escape!";

			haxe.Timer.delay(() -> endCurrentTurn(), 1000);
		}
	}

	private function onTargetSelected(enemyIndex:Int):Void
	{
		if (!enemies[enemyIndex].alive)
			return;

		var currentPlayer:Player = cast turnOrder[currentTurnIndex];
		var target:Enemy = enemies[enemyIndex];

		switch (selectedAction)
		{
			case "attack":
				var damage = currentPlayer.attack(target);
				statusText.text = 'Player attacks and deals ${damage} damage!';
				// Add more actions as needed
		}

		hideTacticalMenu();
		selectingTarget = false;

		// End turn after attack
		haxe.Timer.delay(() -> endCurrentTurn(), 1000);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!battleActive)
			return;

		// Handle escape key to cancel targeting
		if (selectingTarget && FlxG.keys.justPressed.ESCAPE)
		{
			showBattleMenu();
		}
	}
}
