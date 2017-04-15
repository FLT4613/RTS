package objects;
import flixel.FlxG;
using Lambda;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxNestedSprite;

class Emotion extends FlxNestedSprite{
  private var timer:FlxTimer;

  override public function new(x:Float,y:Float){
    super(x,y);
    timer=new FlxTimer();
  }

  override public function update(elapsed){
    super.update(elapsed);
  }

  public function emote(emotion:String){
    revive();
    switch(emotion){
      case "question":loadGraphic(AssetPaths.question__png);
      case "attack":loadGraphic(AssetPaths.attack__png);
      case "exclamation":loadGraphic(AssetPaths.exclamation__png);
    }
    timer.start(1,function(a){kill();});
  }
}