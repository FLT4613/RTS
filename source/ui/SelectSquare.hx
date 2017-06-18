package ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

class SelectSquare extends FlxSprite{
  private var startPos:FlxPoint;
  override public function new(){
    super();
    makeGraphic(FlxG.width,FlxG.height,0x66FFFFFF);
    clipRect=FlxRect.weak(x,y,0,0);
    kill();
  }

  override public function update(elapsed){
    super.update(elapsed);
    if(FlxG.mouse.pressed){
      clipRect=FlxRect.weak(
        (FlxG.mouse.x>startPos.x)?startPos.x:FlxG.mouse.x,
        (FlxG.mouse.y>startPos.y)?startPos.y:FlxG.mouse.y,
        Std.int(Math.abs(FlxG.mouse.x-startPos.x)),
        Std.int(Math.abs(FlxG.mouse.y-startPos.y))
			);
    }
  }

  public function set(x:Float,y:Float){
    startPos=FlxPoint.weak(x,y);
    clipRect=FlxRect.weak(x,y,0,0);
    revive();
  }
}