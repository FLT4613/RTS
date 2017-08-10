package ui;

using Lambda;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import objects.Character;

class ChosenMarks extends FlxSpriteGroup{
  private var targets:Map<Character,FlxSprite>;
  override public function new(){
    super();
    targets=new Map<Character,FlxSprite>();
  }

  override public function update(elapsed){
    super.update(elapsed);
    PlayState.friends.members.filter(function(c){return c.chosen;}).iter(function(c){
      if(targets.exists(c))return;
      var mark=new ChosenMark();
      targets.set(c,mark);
      add(mark);
    });

    for(c in targets.keys()){
      targets.get(c).setPosition(c.x-c.offset.x,c.y-c.offset.y);
      if(c.chosen==false){
        var rm=targets.get(c);
        members.remove(rm);
        rm.destroy();
        targets.remove(c);
      }
    }
  }
}

class ChosenMark extends FlxSprite{
  override public function new(){
    super();
    loadGraphic(AssetPaths.pickedMark__png);
  }
}