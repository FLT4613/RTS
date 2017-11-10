package ui;

using Lambda;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;

import objects.character.*;

class UI extends FlxGroup{
  private var grid:Grid;
  private var selectSquare:SelectSquare;
  private var mouseOverlappingMark:MouseOverlappingMark;
  private var chosenMarks:ChosenMarks;

	/**
	 * クリック地点に発生するパーティクル
	 */
	public static var clickParticles:FlxEmitter;

  override public function new(){
    super();
    grid=new Grid();
    mouseOverlappingMark=new MouseOverlappingMark();
    chosenMarks=new ChosenMarks();
    selectSquare=new SelectSquare();

		clickParticles = new FlxEmitter(0, 0);
		clickParticles.alpha.set(0,0,255);
		clickParticles.speed.set(100);
		clickParticles.lifespan.set(0.2);
		for (i in 0 ... 100){
			var p = new FlxParticle();
			p.makeGraphic(4,4,0xFFFFFFFF);
			p.exists = false;
			clickParticles.add(p);
		}

    add(grid);
    add(mouseOverlappingMark);
    add(chosenMarks);
    add(selectSquare);
    add(clickParticles);
  }

  override public function update(elapsed){
    super.update(elapsed);

		var nearest:Array<Character>=CharacterPool.instance.getCharactersWithIn(FlxG.mouse.getPosition(),16);

 		if(!nearest.empty()){
			mouseOverlappingMark.cover(nearest[0]);
		}else{
      mouseOverlappingMark.unCover();
    }

    if(FlxG.mouse.justPressed){
      clickParticles.setPosition(FlxG.mouse.x,FlxG.mouse.y);
      clickParticles.start(true,0.1,10);
      CharacterPool.instance.getCharacters(CharacterType.Friend).filter(function(c){return c.chosen;}).iter(function(c){
      if(!c.alive)return;
      c.moveStart(FlxG.mouse.getPosition());
      c.chosen=false;
    });
    if(!nearest.empty()){
      CharacterPool.instance.toggleChoice(nearest[0]);
    }
    if(!selectSquare.alive){
      selectSquare.set(FlxG.mouse.x,FlxG.mouse.y);
    }

    }

    if(FlxG.mouse.justReleased){
      if(!selectSquare.clipRect.isEmpty){
        CharacterPool.instance.forEachAlive(function(c){
          if(c.type==CharacterType.Friend && selectSquare.clipRect.containsPoint(c.getMidpoint())){
            CharacterPool.instance.choose(c);
          }
        });
      }
      selectSquare.kill();
    }
  }
}
