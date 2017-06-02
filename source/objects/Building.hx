package objects;
import flixel.FlxG;
using Lambda;
import flixel.util.FlxPath;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import objects.Direction;
using flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flixel.addons.util.FlxFSM;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxTimer;

class Building extends FlxSprite{
  public var timer:FlxTimer;
  override public function new(x:Float,y:Float){
    super(x,y);
    timer=new FlxTimer();
    makeGraphic(32,64,FlxColor.BROWN);
    timer.start(1);
    timer.onComplete=function(a){
      PlayState.spawnCharacter(objects.Friend,x,y);
      timer.reset();
    }
  }

  override public function update(elapsed){
    super.update(elapsed);
  }
}