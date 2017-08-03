package ui;

using Lambda;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import objects.Character;

class MouseOverlappingMark extends FlxSprite{
  private var target:Character=null;
  override public function new(){
    super();
    loadGraphic(AssetPaths.Cursor__png);
    kill();
  }

  override public function update(elapsed){
    super.update(elapsed);
    setPosition(target.x,target.y);
  }

  public function cover(c:Character){
    revive();
    target=c;
    setPosition(target.x,target.y);
  }

  public function unCover(){
    kill();
    target=null;
  }
}