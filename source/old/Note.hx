package;

import flixel.FlxSprite;
import flixel.util.FlxColor;

class Note extends FlxSprite
{
    public static inline var NOTE_SPEED:Float = 400;
    
    public var lane:Int = 0; // 0-3 for different lanes
    public var noteType:String = "normal"; // normal, hold, special
    public var hitTime:Float = 0; // When this note should be hit
    public var wasHit:Bool = false;
    public var canBeHit:Bool = false;
    public var tooLate:Bool = false;
    
    // Timing windows in seconds
    public static inline var PERFECT_WINDOW:Float = 0.05;
    public static inline var GOOD_WINDOW:Float = 0.10;
    public static inline var OK_WINDOW:Float = 0.15;
    
    public function new(lane:Int, time:Float)
    {
        super(0, 0);
        
        this.lane = lane;
        this.hitTime = time;
        
        // Create note graphic based on lane
        switch(lane) {
            case 0: makeGraphic(50, 15, FlxColor.RED);
            case 1: makeGraphic(50, 15, FlxColor.BLUE);
            case 2: makeGraphic(50, 15, FlxColor.GREEN);
            case 3: makeGraphic(50, 15, FlxColor.YELLOW);
        }
        
        // Set initial position (off-screen at top)
        x = 100 + (lane * 75);
        y = -height;
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        if (wasHit || tooLate)
            return;
            
        // Move note down the screen
        y += NOTE_SPEED * elapsed;
        
        // Check if note can be hit or is too late
        var timeWindow = RhythmBattleState.songPosition - hitTime;
        canBeHit = (timeWindow > -GOOD_WINDOW && timeWindow < GOOD_WINDOW);
        tooLate = timeWindow > OK_WINDOW;
        
        // If the note passed the hit line and wasn't hit, mark as missed
        if (tooLate && !wasHit) {
            alpha = 0.4;
        }
    }
    
    /**
     * Judge the timing of a note hit
     * @return 0 = miss, 1 = ok, 2 = good, 3 = perfect
     */
    public function judge():Int {
        if (!canBeHit || wasHit || tooLate)
            return 0;
            
        var timeDiff = Math.abs(RhythmBattleState.songPosition - hitTime);
        
        wasHit = true;
        alpha = 0.4;
        
        if (timeDiff < PERFECT_WINDOW)
            return 3; // Perfect
        else if (timeDiff < GOOD_WINDOW)
            return 2; // Good
        else if (timeDiff < OK_WINDOW)
            return 1; // Ok
        else
            return 0; // Miss
    }
}