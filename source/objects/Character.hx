package objects;
import flixel.FlxG;
import flixel.FlxSprite;
using flixel.util.FlxSpriteUtil;
using Lambda;
import flixel.util.FlxPath;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import objects.Direction;
import objects.Motion;

class Character extends FlxSprite{

  /**
   *  このキャラクターを選択しているか否か
   */
  public var choosing:Bool=false;

  /**
   *  キャラクターの向き
   */
  public var direction:DirectionalVector;

  /**
   *  キャラクターの現在の行動
   */
  public var motion:Motion;

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
   *  戦闘態勢ならtrue
   *  
   */
  public var fightReadiness:Bool;

  override public function new(x:Float,y:Float,color:FlxColor):Void{
    super();
    path=new FlxPath();
    attackTargets=new Array();
    chasingRange=120;
    attackRange=25;
    direction=Direction.UP;
    motion=Motion.STAY;
    loadGraphic(AssetPaths.Character__png,true,32,32,true);
    animation.add("STAYUP"    ,[0],10,true);
    animation.add("STAYDOWN"  ,[0+4],10,true);
    animation.add("STAYLEFT"  ,[0+4+4],10,true);
    animation.add("STAYRIGHT" ,[0+4+4+4],10,true);
    var motionIndex=0;
    for(directionStr in ["UP","DOWN","LEFT","RIGHT"]){
      animation.add("WALK"+directionStr,[2+motionIndex,1+motionIndex,2+motionIndex,3+motionIndex],10,true);
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
    FlxG.watch.add(this,"motion");
  }

  override public function update(elapsed:Float):Void{
    super.update(elapsed);
    if(health<1)kill();
    if(!attackTargets.empty()){
      attackTarget=getAttackableTarget();
      if(attackTarget!=null){
        motion=ATTACK;
        path.cancel();
        stareAtPoint(attackTarget.getMidpoint());
      }else{
        motion=WALK;
				moveStart(PlayState.field.findPath(getMidpoint(),attackTargets[0].getMidpoint()));
      }
      attackTargets=[];
    }else{
      attackInterval.cancel();
      if(path.active)motion=WALK;
      else motion=STAY;
    }

    switch(motion){
      case STAY:
        animation.play(Std.string(motion)+Std.string(direction));
      case WALK:
        stareAtPoint(path.nodes[path.nodeIndex]);
        animation.play(Std.string(motion)+Std.string(direction));
      case ATTACK:
        if(attackInterval.active)animation.play("STAY"+Std.string(direction));        
        else{
          if(animation.curAnim!=animation.getByName("ATTACK"+Std.string(direction))){
            animation.play(Std.string(motion)+Std.string(direction));
          }else if(animation.finished){
            PlayState.makeCollision().configure(
              attackTarget.getMidpoint().x,
              attackTarget.getMidpoint().y,
              function(character:Character){
                FlxSpriteUtil.flicker(character,0.5);
              },objects.Collision.ColliderType.ONCE);
            attackTarget.health-=1;
            attackInterval.start(1.5);
          } 
        }

      }
  }

  /**
   * キャラクターを移動させる
   @param   dest 目的地 
   @param   keepChoice 選択状態を維持する(true) しない(false) 
   */
  public function moveStart(dest:Array<FlxPoint>,?keepChoice:Bool=false){
    path.cancel();
    if(!keepChoice)choosing=false;
    motion=Motion.WALK;
    path.onComplete=function(path:FlxPath){motion=Motion.STAY;};
    path.start(dest);
  }

	public function onMouseOver(character:Character){
		character.scale.set(2.0,2.0);
	}

	public function onMouseOut(character:Character){
		character.scale.set(1.0,1.0);
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