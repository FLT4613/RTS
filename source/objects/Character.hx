package objects;
import flixel.FlxSprite;

class Character extends FlxSprite{
  override public function new():Void{
    super();
    makeGraphic(16, 16, 0xFFFFFFFF);
  }
  override public function update(elapsed:Float):Void{
    super.update(elapsed);
  }
}