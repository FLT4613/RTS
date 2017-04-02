package objects;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;


class Cursor extends FlxSpriteGroup{
  override public function new(?target:FlxSprite){
    super();
    var lu=new FlxSprite().loadGraphic(AssetPaths.Cursor__png);
    var ru=new FlxSprite().loadGraphic(AssetPaths.Cursor__png);
    var rd=new FlxSprite().loadGraphic(AssetPaths.Cursor__png);
    var ld=new FlxSprite().loadGraphic(AssetPaths.Cursor__png);
    ru.angle=90;
    rd.angle=180;
    ld.angle=270;
    // if(target!=null){
    //   var point=target.getMidpoint();
    //   // lu.setPosition(0,0);
    // }
    add(lu);
    add(ru);
    add(ld);
    add(rd);
  }
}