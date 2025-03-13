// source/PlayState.hx
package;

import RhythmBattleState; // Import the new rhythm battle state
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
    public var player:Player;
    public var encounterTimer:Float = 0;
    public var encounterChance:Float = 0.5; // 0.5% chance per frame

    override public function create():Void
    {
        super.create();
        trace("PlayState created");
        
        // Create player
        player = new Player(FlxG.width / 2, FlxG.height / 2);
        add(player);

        // Add instructions
        var instructionsText = new FlxText(0, 10, FlxG.width, 
            "Arrow keys to move\nWalk around to trigger random encounters\nPress B to force battle");
        instructionsText.setFormat(null, 14, FlxColor.WHITE, "center");
        add(instructionsText);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        // Check for random encounters when moving
        if (player.velocity.x != 0 || player.velocity.y != 0)
        {
            if (FlxG.random.float(0, 100) < encounterChance)
            {
                startBattle();
            }
        }

        // Debug: Press B to force battle
        if (FlxG.keys.justPressed.B)
        {
            startBattle();
        }
    }

    private function startBattle():Void
    {
        var battleState = new RhythmBattleState(); // Use the rhythm battle state instead
        battleState.player = player;
        
        // Create a random enemy
        var enemyTypes = ["normal", "strong", "fast", "tank"];
        var type = enemyTypes[FlxG.random.int(0, enemyTypes.length - 1)];
        battleState.enemy = new Enemy(0, 0, type);
        
        FlxG.switchState(() -> battleState);
    }
}