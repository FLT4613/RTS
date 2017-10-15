package objects.character.state;

using Lambda;
import objects.character.Character;
import flixel.addons.util.FlxFSM;

class Idle extends FlxFSMState<Character>{
  override public function enter(owner:Character,fsm:FlxFSM<Character>){
    owner.animation.play("Idle"+Std.string(owner.direction));
  }

  override public function update(elapsed:Float,owner:Character,fsm:FlxFSM<Character>){
    if(!owner.destinations.empty() && !owner.path.active){
      var path=PlayState.field.findPath(owner.getMidpoint(),owner.destinations.shift());
      owner.path.start(path);
    }
    if(owner.path.active){
      owner.path.update(elapsed);
      owner.animation.play("Move"+Std.string(owner.direction));
      owner.stareAtPoint(owner.path.nodes[owner.path.nodeIndex]);
    }else{
      owner.animation.play("Idle"+Std.string(owner.direction),true);
    }
  }

  override public function exit(owner:Character){
    owner.path.cancel();
  }
}