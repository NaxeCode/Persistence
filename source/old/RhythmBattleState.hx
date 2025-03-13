package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class RhythmBattleState extends FlxState
{
	// Song and rhythm management
	public static var songPosition:Float = 0;
	public static var songBPM:Float = 173; // Beats per minute
	public static var conductor:RhythmConductor;

	// Game objects
	public var player:Player;
	public var enemy:Enemy;

	// UI elements
	private var playerSprite:FlxSprite;
	private var enemySprite:FlxSprite;
	private var healthBar:FlxSprite;
	private var enemyHealthBar:FlxSprite;
	private var comboText:FlxText;
	private var feedbackText:FlxText;
	private var scoreText:FlxText;

	// Note system
	private var notes:FlxTypedGroup<Note>;
	private var hitLines:Array<FlxSprite> = [];
	private var noteLanes:Array<String> = ["D", "F", "J", "K"]; // Default key bindings

	// Game state
	private var score:Int = 0;
	private var combo:Int = 0;
	private var maxCombo:Int = 0;
	private var health:Float = 100;
	private var enemyHealth:Float = 100;
	private var battleOver:Bool = false;
	private var battleWon:Bool = false;

	override public function create():Void
	{
		super.create();

		// Initialize conductor to manage song timing
		var songPath = AssetPaths.honestly_music__ogg;
		conductor = new RhythmConductor(songBPM, songPath);
		conductor.onBeat.add(onBeat);

		// Create the player and enemy (from the previous state)
		if (player == null)
		{
			player = new Player(0, 0);
		}

		if (enemy == null)
		{
			enemy = new Enemy(0, 0);
		}

		setupBattleScene();
		generateNotes();

		// Start the music
		conductor.startSong();
	}

	private function setupBattleScene():Void
	{
		// Background
		var bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF222222);
		add(bg);

		// Create note lanes and hit lines
		for (i in 0...4)
		{
			// Lane background
			var lane = new FlxSprite(100 + (i * 75), 0);
			lane.makeGraphic(50, FlxG.height, 0xFF333333);
			add(lane);

			// Hit line
			var hitLine = new FlxSprite(100 + (i * 75), FlxG.height - 100);
			hitLine.makeGraphic(50, 5, 0xFFFFFFFF);
			add(hitLine);
			hitLines.push(hitLine);

			// Key hint text
			var keyText = new FlxText(100 + (i * 75) + 15, FlxG.height - 80, 50, noteLanes[i]);
			keyText.setFormat(null, 16, FlxColor.WHITE, "center");
			add(keyText);
		}

		// Character sprites
		playerSprite = new FlxSprite(20, 150);
		playerSprite.makeGraphic(80, 150, FlxColor.BLUE);
		add(playerSprite);

		enemySprite = new FlxSprite(FlxG.width - 120, 150);
		enemySprite.makeGraphic(80, 150, FlxColor.RED);
		add(enemySprite);

		// Health bars
		var healthBarBg = new FlxSprite(20, 30).makeGraphic(200, 20, 0xFF333333);
		add(healthBarBg);

		healthBar = new FlxSprite(20, 30).makeGraphic(200, 20, 0xFF00FF00);
		add(healthBar);

		var enemyHealthBarBg = new FlxSprite(FlxG.width - 220, 30).makeGraphic(200, 20, 0xFF333333);
		add(enemyHealthBarBg);

		enemyHealthBar = new FlxSprite(FlxG.width - 220, 30).makeGraphic(200, 20, 0xFFFF0000);
		add(enemyHealthBar);

		// UI Text elements
		comboText = new FlxText(0, 60, FlxG.width, "COMBO: 0");
		comboText.setFormat(null, 16, FlxColor.WHITE, "center");
		add(comboText);

		feedbackText = new FlxText(0, 100, FlxG.width, "");
		feedbackText.setFormat(null, 32, FlxColor.WHITE, "center");
		add(feedbackText);

		scoreText = new FlxText(0, 10, FlxG.width, "SCORE: 0");
		scoreText.setFormat(null, 16, FlxColor.WHITE, "center");
		add(scoreText);

		// Initialize the notes group
		notes = new FlxTypedGroup<Note>();
		add(notes);
	}

	/**
	 * Generate note pattern for the battle
	 * In a full game, this would be based on song data or patterns
	 */
	private function generateNotes():Void
	{
		// Simple test pattern - one note every half second
		var startTime = 1; // Start after 1 second
		var endTime = 30.0; // 30 second battle
		var interval = 60 / songBPM; // Time between beats

		for (time in startTime...Std.int(endTime))
		{
			// Generate 1-3 notes per beat
			var notesToGenerate = FlxG.random.int(1, 3);

			for (i in 0...notesToGenerate)
			{
				var lane = FlxG.random.int(0, 3);
				var noteTime = time + (i * (interval / notesToGenerate));

				var note = new Note(lane, noteTime);
				notes.add(note);
			}
		}
	}

	/**
	 * Called on each beat of the song
	 */
	private function onBeat():Void
	{
        trace("Beat!");
		// Make characters bob to the beat
		FlxTween.tween(playerSprite, {y: playerSprite.y - 10}, 0.15, {
			onComplete: function(_)
			{
				FlxTween.tween(playerSprite, {y: playerSprite.y + 10}, 0.15);
			}
		});

		FlxTween.tween(enemySprite, {y: enemySprite.y - 10}, 0.15, {
			onComplete: function(_)
			{
				FlxTween.tween(enemySprite, {y: enemySprite.y + 10}, 0.15);
			}
		});
	}

	/**
	 * Check for note hits
	 */
	private function checkNoteHits():Void
	{
		// Check key presses for each lane
		for (i in 0...noteLanes.length)
		{
			var keyPressed = false;

			switch (noteLanes[i])
			{
				case "D":
					keyPressed = FlxG.keys.justPressed.D;
				case "F":
					keyPressed = FlxG.keys.justPressed.F;
				case "J":
					keyPressed = FlxG.keys.justPressed.J;
				case "K":
					keyPressed = FlxG.keys.justPressed.K;
			}

			if (keyPressed)
			{
				// Flash the hit line
				hitLines[i].color = 0xFFFFFF00;
				FlxTween.color(hitLines[i], 0.2, 0xFFFFFF00, 0xFFFFFFFF);

				// Check for any hittable notes in this lane
				var hitNote = false;

				notes.forEachAlive(function(note:Note)
				{
					if (!hitNote && note.lane == i && note.canBeHit && !note.wasHit)
					{
						var judgement = note.judge();
						processNoteHit(judgement);
						hitNote = true;

						// Visual feedback
						if (judgement > 0)
						{
							FlxTween.tween(note, {alpha: 0, y: note.y - 20}, 0.3, {
								onComplete: function(_)
								{
									note.kill();
								}
							});
						}
					}
				});

				// If no note was hit, it's a miss
				if (!hitNote)
				{
					// processNoteHit(0);
				}
			}
		}
	}

	/**
	 * Process a note hit based on judgement
	 * @param judgement 0 = miss, 1 = ok, 2 = good, 3 = perfect
	 */
	private function processNoteHit(judgement:Int):Void
	{
		var pointsToAdd:Int = 0;
		var damageToEnemy:Float = 0;
		var feedback:String = "";

		switch (judgement)
		{
			case 0: // Miss
				combo = 0;
				health -= 2; // Player takes damage on miss
				feedback = "MISS";
				feedbackText.color = FlxColor.RED;

				// Shake player sprite
				FlxTween.tween(playerSprite, {x: playerSprite.x - 5}, 0.05, {
					onComplete: function(_)
					{
						FlxTween.tween(playerSprite, {x: playerSprite.x + 10}, 0.1, {
							onComplete: function(_)
							{
								FlxTween.tween(playerSprite, {x: playerSprite.x - 5}, 0.05);
							}
						});
					}
				});

			case 1: // OK
				combo++;
				pointsToAdd = 50 * combo;
				damageToEnemy = player.atk * 0.5;
				feedback = "OK";
				feedbackText.color = FlxColor.YELLOW;

			case 2: // Good
				combo++;
				pointsToAdd = 100 * combo;
				damageToEnemy = player.atk * 0.75;
				feedback = "GOOD";
				feedbackText.color = FlxColor.LIME;

			case 3: // Perfect
				combo++;
				pointsToAdd = 200 * combo;
				damageToEnemy = player.atk * 1.0;
				feedback = "PERFECT!";
				feedbackText.color = FlxColor.CYAN;

				// Special visual effect for perfect hits
				var perfectFlash = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x66FFFFFF);
				add(perfectFlash);
				FlxTween.tween(perfectFlash, {alpha: 0}, 0.3, {
					onComplete: function(_)
					{
						remove(perfectFlash);
					}
				});
		}

		// Update game state
		score += pointsToAdd;

		if (combo > maxCombo)
			maxCombo = combo;

		// Update UI
		comboText.text = "COMBO: " + combo;
		scoreText.text = "SCORE: " + score;
		feedbackText.text = feedback;

		// Reset feedback text after a delay
		new FlxTimer().start(0.5, function(_)
		{
			feedbackText.text = "";
		});

		// Deal damage to enemy if applicable
		if (damageToEnemy > 0)
		{
			enemyHealth -= damageToEnemy;

			// Attack animation
			var attackSprite = new FlxSprite(playerSprite.x + 80, playerSprite.y + 50);
			attackSprite.makeGraphic(20, 20, FlxColor.WHITE);
			add(attackSprite);

			FlxTween.tween(attackSprite, {x: enemySprite.x}, 0.2, {
				onComplete: function(_)
				{
					// Shake enemy sprite
					FlxTween.tween(enemySprite, {x: enemySprite.x - 5}, 0.05, {
						onComplete: function(_)
						{
							FlxTween.tween(enemySprite, {x: enemySprite.x + 10}, 0.1, {
								onComplete: function(_)
								{
									FlxTween.tween(enemySprite, {x: enemySprite.x - 5}, 0.05);
									remove(attackSprite);
								}
							});
						}
					});
				}
			});

			// Damage text
			var damageText = new FlxText(enemySprite.x + 40, enemySprite.y, 100, Std.string(Math.floor(damageToEnemy)));
			damageText.setFormat(null, 16, FlxColor.RED);
			add(damageText);

			FlxTween.tween(damageText, {y: damageText.y - 20, alpha: 0}, 0.5, {
				onComplete: function(_)
				{
					remove(damageText);
				}
			});
		}

		// Check for battle end
		checkBattleEnd();
	}

	/**
	 * Mark missed notes and apply penalties
	 */
	private function checkMissedNotes():Void
	{
		notes.forEachAlive(function(note:Note)
		{
			if (note.tooLate && !note.wasHit)
			{
				note.wasHit = true; // Mark as hit so we don't count it again
				processNoteHit(0); // Count as a miss

				FlxTween.tween(note, {alpha: 0}, 0.3, {
					onComplete: function(_)
					{
						note.kill();
					}
				});
			}
		});
	}

	private function checkBattleEnd():Void
	{
		if (battleOver)
			return;

		// Update health bars
		healthBar.scale.x = Math.max(0, health / 100);
		enemyHealthBar.scale.x = Math.max(0, enemyHealth / 100);

		// Check if player or enemy is defeated
		if (health <= 0)
		{
			battleOver = true;
			battleWon = false;
			endBattle();
		}
		else if (enemyHealth <= 0)
		{
			battleOver = true;
			battleWon = true;
			endBattle();
		}

		// Check if song ended
		if (conductor.songEnded && notes.countLiving() == 0)
		{
			battleOver = true;
			battleWon = (enemyHealth < health);
			endBattle();
		}
	}

	private function endBattle():Void
	{
		// Stop the music
		conductor.stopSong();

		// Show results
		var resultText = new FlxText(0, FlxG.height / 2 - 50, FlxG.width, battleWon ? "VICTORY!" : "DEFEAT!");
		resultText.setFormat(null, 48, battleWon ? FlxColor.GREEN : FlxColor.RED, "center");
		add(resultText);

		var statsText = new FlxText(0, FlxG.height / 2 + 20, FlxG.width, 'Score: $score\nMax Combo: $maxCombo');
		statsText.setFormat(null, 24, FlxColor.WHITE, "center");
		add(statsText);

		// Award experience if won
		if (battleWon)
		{
			var expGained = Math.floor(score / 10) + enemy.experienceReward;
			player.gainExperience(expGained);

			var expText = new FlxText(0, FlxG.height / 2 + 80, FlxG.width, 'Experience gained: $expGained');
			expText.setFormat(null, 18, FlxColor.YELLOW, "center");
			add(expText);
		}

		// Return to world after delay
		new FlxTimer().start(3, function(_)
		{
			FlxG.switchState(() -> new PlayState());
		});
	}

	private function restartGame():Void
	{
		if (FlxG.keys.justPressed.R)
			FlxG.switchState(() -> new RhythmBattleState());
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (battleOver)
			return;

        conductor.update();

		// Update song position
		songPosition = conductor.songPosition;

		// Check for note hits
		checkNoteHits();

		// Check for missed notes
		checkMissedNotes();

        restartGame();
	}
}
