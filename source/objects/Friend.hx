package objects;
import flixel.addons.display.FlxNestedSprite;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;

class Friend extends Character{
  /**
   *  カーソル四方のL字の間隔
   */
  public var cursorSize:FlxRect;

	public var mouseOverlappedMark:FlxNestedSprite;

	public var pickedMark:FlxNestedSprite;

  override public function new(x:Float,y:Float){
    super(x,y);

    mouseOverlappedMark=new FlxNestedSprite();
    mouseOverlappedMark.loadGraphic(AssetPaths.Cursor__png);
    mouseOverlappedMark.visible=false;

    pickedMark=new FlxNestedSprite();
    pickedMark.loadGraphic(AssetPaths.pickedMark__png);
    pickedMark.visible=false;

    cursorSize=new FlxRect().fromTwoPoints(FlxPoint.weak(6,4),FlxPoint.weak(25,28));

    add(mouseOverlappedMark);
    add(pickedMark);
  }

  override public function update(elapsed){
    super.update(elapsed);
  }
}