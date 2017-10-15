package objects.character.state;

using Lambda;
import flixel.FlxG;

import flixel.util.FlxTimer;
import objects.character.Character;
import flixel.addons.util.FlxFSM;

class Attack extends FlxFSMState<Character>{
  /**
   *  攻撃間隔
   */
  public var attackInterval:FlxTimer;

  override public function new(){
    super();
    attackInterval=new FlxTimer();
  }

  override public function enter(owner:Character,fsm:FlxFSM<Character>){
    attackInterval.start(1.5);
    owner.stareAtPoint(owner.attackTarget.getMidpoint());
    owner.animation.play("Attack"+Std.string(owner.direction));
    owner.animation.pause();
  }

  override public function update(elapsed:Float,owner:Character,fsm:FlxFSM<Character>){
    if(attackInterval.finished)owner.animation.resume();
    if(owner.animation.finished){
      if(owner.attackTarget.tween.finished){
        FlxG.sound.play(FlxG.random.getObject([AssetPaths.hit1__wav,AssetPaths.hit2__wav,AssetPaths.hit3__wav]));
        owner.attackTarget.health-=1;
        // owner.attackTarget.knockBack();
      }
      owner.attackTarget=null;
    }
  }
}