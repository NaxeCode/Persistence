package;

import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.util.FlxSignal;

/**
 * Manages music timing and beat detection
 */
class RhythmConductor
{
    // Song data
    public var bpm:Float; // Beats per minute
    public var crochet:Float; // Time for one beat in seconds
    
    // Timing variables
    public var songPosition:Float = 0; // Current position in the song (in seconds)
    public var lastBeat:Float = 0;     // Time of the last beat
    public var beatsElapsed:Int = 0;   // Number of beats that have passed
    
    // Music playback
    public var music:FlxSound;
    public var songEnded:Bool = false;
    
    // Signals
    public var onBeat:FlxTypedSignal<Void->Void> = new FlxTypedSignal<Void->Void>();
    
    // For testing without music
    private var lastTime:Float = 0;
    private var usingTestMode:Bool = true;
    
    public function new(bpm:Float, songPath:String = null)
    {
        this.bpm = bpm;
        this.crochet = 60 / bpm;
        
        // If a song path is provided, load the music
        if (songPath != null) {
            music = FlxG.sound.load(songPath);
            usingTestMode = false;
        }
    }
    
    public function startSong():Void
    {
        lastTime = FlxG.game.ticks / 1000;
        
        if (!usingTestMode && music != null) {
            music.play();
        }
    }
    
    public function stopSong():Void
    {
        if (!usingTestMode && music != null) {
            music.stop();
        }
        
        songEnded = true;
    }
    
    public function update():Void
    {
        // Update song position
        if (usingTestMode) {
            // In test mode, we manually track time
            var currentTime = FlxG.game.ticks / 1000;
            var elapsed = currentTime - lastTime;
            songPosition += elapsed;
            lastTime = currentTime;
            
            // For testing, end song after 30 seconds
            if (songPosition > 30) {
                songEnded = true;
            }
        }
        else {
            // Use music's actual position
            songPosition = music.time / 1000;
            
            if (music.playing != true && music.time > music.length) {
                songEnded = true;
            }
        }
        
        // Check for beats
        var currentBeat = Math.floor(songPosition / crochet);
        if (currentBeat > beatsElapsed) {
            beatsElapsed = currentBeat;
            onBeat.dispatch();
        }
    }
}