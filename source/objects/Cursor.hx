package objects;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.group.FlxSpriteGroup;
import objects.Character;

class Cursor extends FlxSpriteGroup{
  private var leftTop:FlxSprite; 
  private var rightTop:FlxSprite;
  private var rightBottom:FlxSprite;
  private var leftBottom:FlxSprite;
  var criteria:FlxPoint;
  public static var lineThickness(default,null):Int=3; 

  override public function new(){
    super();
    leftTop=new FlxSprite().loadGraphic(AssetPaths.Cursor__png);
    rightTop=new FlxSprite().loadGraphic(AssetPaths.Cursor__png);
    rightBottom=new FlxSprite().loadGraphic(AssetPaths.Cursor__png);
    leftBottom=new FlxSprite().loadGraphic(AssetPaths.Cursor__png);
    rightTop.angle=90;
    rightBottom.angle=180;
    leftBottom.angle=270;
    add(leftTop);
    add(rightTop);
    add(leftBottom);
    add(rightBottom);
  }

  public function capture(target:Character){
    criteria=target.getMidpoint().subtractPoint(target.offset).subtractPoint(target.origin).add(target.frameWidth/2,target.frameHeight/2);
    leftTop.setPosition(criteria.x-lineThickness,criteria.y-lineThickness-target.cursorSize.y);
    leftBottom.setPosition(criteria.x-lineThickness,criteria.y-lineThickness-target.cursorSize.y);
    rightBottom.setPosition(criteria.x-lineThickness-target.cursorSize.x,criteria.y-lineThickness-target.cursorSize.y);
    rightTop.setPosition(criteria.x-lineThickness-target.cursorSize.x,criteria.y-lineThickness-target.cursorSize.y);
    trace(criteria);
    trace(target.cursorSize);
  }
}