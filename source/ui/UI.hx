package ui;

using Lambda;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import effects.*;

class UI extends FlxSpriteGroup{
  private var grid:Grid;
  private var selectSquare:SelectSquare;
  private var mouseOverlappingMark:MouseOverlappingMark;
  private var chosenMarks:ChosenMarks;
  override public function new(){
    super();
    grid=new Grid();
    mouseOverlappingMark=new MouseOverlappingMark();
    chosenMarks=new ChosenMarks();
    selectSquare=new SelectSquare();
    add(grid);
    add(mouseOverlappingMark);
    add(chosenMarks);
    add(selectSquare);
  }

  override public function update(elapsed){
    super.update(elapsed);

		var nearest=PlayState.friends.getCharactersWithIn(FlxG.mouse.getPosition(),16);

 		if(!nearest.empty()){
			mouseOverlappingMark.cover(nearest[0]);
		}else{
      mouseOverlappingMark.unCover();
    }

    if(FlxG.mouse.justPressed){
      Effects.emitClickEffect(FlxG.mouse.getPosition());
      PlayState.friends.members.filter(function(c){return c.chosen;}).iter(function(c){
        if(!c.alive)return;
        c.moveStart(FlxG.mouse.getPosition());
        c.chosen=false;
      });
      if(!nearest.empty()){
        PlayState.friends.toggleChoice(nearest[0]);
      }
      if(!selectSquare.alive){
       selectSquare.set(FlxG.mouse.x,FlxG.mouse.y);
     }

    }

    if(FlxG.mouse.justReleased){
      if(!selectSquare.clipRect.isEmpty){
        PlayState.friends.forEachAlive(function(c){
          if(selectSquare.clipRect.containsPoint(c.getMidpoint())){
            PlayState.friends.choose(c);
          }
        });
      }
      selectSquare.kill();
    }
  }
}
