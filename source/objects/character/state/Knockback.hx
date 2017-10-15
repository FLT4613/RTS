package objects.character.state;

using Lambda;
import objects.character.Character;
import flixel.addons.util.FlxFSM;

class KnockBack extends FlxFSMState<Character>{
  override public function enter(owner:Character,fsm:FlxFSM<Character>){
    owner.animation.play("DeadLEFT");
  }

  override public function update(elapsed:Float,owner:Character,fsm:FlxFSM<Character>){

  }

  override public function exit(owner:Character){

  }
}