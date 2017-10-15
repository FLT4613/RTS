package objects.character.state;

using Lambda;
import objects.character.Character;
import flixel.addons.util.FlxFSM;

class Chase extends FlxFSMState<Character>{
  override public function update(elapsed:Float,owner:Character,fsm:FlxFSM<Character>){
    if(!owner.attackTargets.empty()){
      owner.animation.play("Move"+Std.string(owner.direction));
      var path=PlayState.field.findPath(owner.getMidpoint(),owner.attackTargets[0].getMidpoint());
      if(path!=null)owner.stareAtPoint(path[0]);
      owner.path.start(path);
      owner.path.update(elapsed);
    };
  }

  override public function exit(owner:Character){
    owner.path.cancel();
  }
}
