package objects.character.state;

import objects.character.Character;
import flixel.addons.util.FlxFSM;

class Dead extends FlxFSMState<Character>{
  override public function enter(owner:Character,fsm:FlxFSM<Character>){
    owner.chosen=false;
    owner.kill();
  }
}
