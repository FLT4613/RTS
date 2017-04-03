package objects;
import flixel.FlxG;
import flixel.FlxSprite;
using Lambda;
import flixel.util.FlxPath;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import objects.Direction;
import flixel.effects.particles.FlxParticle;
import flixel.addons.util.FlxFSM;
class Character extends FlxSprite{
  /**
   *  キャラクターの向き
   */
  public var direction:DirectionalVector;

  /**
   * 到達予定の目的地
   * 先頭要素が最も早く指定された目的地、以降時系列順に格納
   */
  public var destinations:Array<FlxPoint>;

  /**
   *  攻撃開始範囲の半径
   */
  public var chasingRange:Int;

  /**
   *  攻撃範囲
   */
  public var attackRange:Int;

  /**
   *  攻撃範囲に補足しているキャラクター
   */
  public var attackTargets:Array<Character>;

  /**
   *  攻撃対象とするキャラクター
   */
  public var attackTarget:Character;

  /**
   *  攻撃間隔
   */
  public var attackInterval:FlxTimer;

  /**
   *  キャラクターのとる状態
   */
  public var fsm:FlxFSM<Character>;

  override public function new(x:Float,y:Float,color:FlxColor):Void{
    super();
    path=new FlxPath();
    attackTargets=new Array();
    destinations=new Array<FlxPoint>();
    chasingRange=120;
    attackRange=25;
    direction=Direction.UP;
    loadGraphic(AssetPaths.Character__png,true,32,32,true);
    animation.add("IdleUP"    ,[0],10,true);
    animation.add("IdleDOWN"  ,[0+4],10,true);
    animation.add("IdleLEFT"  ,[0+4+4],10,true);
    animation.add("IdleRIGHT" ,[0+4+4+4],10,true);
    var motionIndex=0;
    for(directionStr in ["UP","DOWN","LEFT","RIGHT"]){
      animation.add("Move"+directionStr,[2+motionIndex,1+motionIndex,2+motionIndex,3+motionIndex],10,true);
      motionIndex+=4;
    }
    for(directionStr in ["UP","DOWN","LEFT","RIGHT"]){
      animation.add("ATTACK"+directionStr,[0+motionIndex,1+motionIndex,2+motionIndex,3+motionIndex],10,false);
      motionIndex+=4;
    }
    setSize(11,15);
    offset.set(10,13);
    setPosition(x-width/2,y-height/2);
    attackInterval=new FlxTimer();
    health=10;

    fsm=new FlxFSM<Character>(this);
    fsm.transitions.add(Idle,Move,function(a){
      return !a.destinations.empty();
    }).add(Move,Idle,function(a){
      return a.path.finished;
    }).start(Idle); 
  }

  override public function update(elapsed:Float):Void{
    fsm.update(elapsed);
    super.update(elapsed);
    if(health<1)kill();
    // if(!attackTargets.empty()){
    //   attackTarget=getAttackableTarget();
    //   if(attackTarget!=null){
    //     motion=ATTACK;
    //     path.cancel();
    //     stareAtPoint(attackTarget.getMidpoint());
    //   }else{
    //     motion=WALK;
    //   }
    //   attackTargets=[];
    // }else{
    //   attackInterval.cancel();
    //   if(path.active)motion=WALK;
    //   else motion=STAY;
    // }

    // switch(motion){
    //   case STAY:
        
    //   case WALK:
    //     stareAtPoint(path.nodes[path.nodeIndex]);
    //     animation.play(Std.string(motion)+Std.string(direction));
    //   case ATTACK:
    //     if(attackInterval.active)animation.play("STAY"+Std.string(direction));        
    //     else{
    //       if(animation.curAnim!=animation.getByName("ATTACK"+Std.string(direction))){
    //         animation.play(Std.string(motion)+Std.string(direction));
    //       }else if(animation.finished){
    //         PlayState.makeCollision().configure(
    //           attackTarget.getMidpoint().x,
    //           attackTarget.getMidpoint().y,
    //           function(character:Character){
    //             // FlxSpriteUtil.flicker(character,0.5);
    //           },objects.Collision.ColliderType.ONCE);
    //           PlayState.particleEmitter.focusOn(this);
    //           PlayState.particleEmitter.alpha.set(0,0,255);
    //           PlayState.particleEmitter.speed.set(60);
    //           PlayState.particleEmitter.lifespan.set(0.2);
    //           for (i in 0 ... 10){
    //             var p = new FlxParticle();
    //             p.makeGraphic(2,2,FlxColor.YELLOW);
    //             p.exists = false;
    //             PlayState.particleEmitter.add(p);
    //           }
    //           PlayState.particleEmitter.start(true,0.02,4);
    //         attackTarget.health-=1;
    //         attackInterval.start(1.5);
    //       } 
    //     }
    // }
  }

  /**
   * キャラクターを移動させる
   @param   dest 目的地 
   @param   keepChoice 選択状態を維持する(true) しない(false) 
   */
  public function moveStart(point:FlxPoint){
    destinations.push(point);
  }

  /**
   * 攻撃が届く範囲にいるキャラクターのうち、最も近いものを返す
   * @return  攻撃が届く`Character` または `null`
   */
  public function getAttackableTarget():Character{    
    var min:Character=null;
    for(character in attackTargets.filter(function(a){
      return getMidpoint().distanceTo(a.getMidpoint())<attackRange;
      })){
      if(min==null){
        min=character;
        continue;
      }
      if(getMidpoint().distanceTo(character.getMidpoint())<getMidpoint().distanceTo(min.getMidpoint()))min=character;
    }
    return min;
  }

  /**
   * フィールドマップ上のある一点に相対するよう向きを変える
   * 
   * ただし、その点と重なっている場合は、方向を変えない
   * @param point 目標座標
   * @return 向いた方向
   */
  public function stareAtPoint(point:FlxPoint):Direction{
    if(!getMidpoint().equals(point)){
      switch(getMidpoint().angleBetween(point)){
        case value if(-45<=value && value<45): direction=UP;
        case value if(45<=value && value<=135): direction=RIGHT;
        case value if(-45>=value && value>=-135): direction=LEFT;
        case value if(-135>value || value>135): direction=DOWN;
      }
    }
    return direction;
  }
}

// class Conditions{
//   public static function 
// }

class Idle extends FlxFSMState<Character>{
  override public function enter(owner:Character,fsm:FlxFSM<Character>){
    owner.animation.play("Idle"+Std.string(owner.direction));
  }
}

class Move extends FlxFSMState<Character>{
  override public function enter(owner:Character,fsm:FlxFSM<Character>){
    var path=PlayState.field.findPath(owner.getMidpoint(),owner.destinations.shift());
    owner.path.start(path);
  }
  
  override public function update(elapsed:Float,owner:Character,fsm:FlxFSM<Character>){
    owner.animation.play("Move"+Std.string(owner.direction));
    owner.stareAtPoint(owner.path.nodes[owner.path.nodeIndex]);
  }

  override public function exit(owner:Character){
    owner.path.cancel();
  }
}