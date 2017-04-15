package objects;
import flixel.FlxG;
using Lambda;
import flixel.util.FlxPath;
import flixel.util.FlxColor;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import objects.Direction;
import flixel.effects.particles.FlxParticle;
import flixel.addons.util.FlxFSM;
import flixel.addons.display.FlxNestedSprite;

class Character extends FlxNestedSprite{
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
   *  キャラクターのとる状態
   */
  public var fsm:FlxFSM<Character>;

  /**
   *  カーソル四方のL字の間隔
   */
  public var cursorSize:FlxRect;

	public var mouseOverlappedMark:FlxNestedSprite;

	public var pickedMark:FlxNestedSprite;

  public var emotion:Emotion;

  override public function new(x:Float,y:Float,color:FlxColor):Void{
    super(x-width/2,y-height/2);
    path=new FlxPath();
    attackTargets=new Array();
    destinations=new Array<FlxPoint>();
    chasingRange=120;
    attackRange=25;
    emotion=new Emotion(0,0);
    emotion.kill();

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
      animation.add("Attack"+directionStr,[0+motionIndex,1+motionIndex,2+motionIndex,3+motionIndex],10,false);
      motionIndex+=4;
    }
    setSize(11,15);
    offset.set(10,13);
    health=10;

    mouseOverlappedMark=new FlxNestedSprite();
    mouseOverlappedMark.loadGraphic(AssetPaths.Cursor__png);
    add(mouseOverlappedMark);
    pickedMark=new FlxNestedSprite();
    pickedMark.loadGraphic(AssetPaths.pickedMark__png);
    add(pickedMark);
    mouseOverlappedMark.visible=false;
    pickedMark.visible=false;

    emotion.relativeX=8;
    emotion.relativeY=-12;
    add(emotion);

    fsm=new FlxFSM<Character>(this);
    fsm.transitions.add(Idle,Move,function(a){
      return !a.destinations.empty();
    }).add(Move,Idle,function(a){
      if(a.path.finished){
        FlxG.sound.play(AssetPaths.question__wav,0.5);
        emotion.emote("question");
        return true;
      }
      return false;
    }).add(Idle,Chase,function(a){
      return !attackTargets.empty();
    }).add(Move,Chase,function(a){
      return !attackTargets.empty();
    }).add(Chase,Idle,function(a){
      return attackTargets.empty();
    }).add(Chase,Attack,function(a){
      attackTarget=getAttackableTarget();
      return attackTarget!=null;
    }).add(Attack,Chase,function(a){
      return animation.finished || !attackTarget.alive;
    }).start(Idle); 

    cursorSize=new FlxRect().fromTwoPoints(FlxPoint.weak(6,4),FlxPoint.weak(25,28));

    FlxG.watch.add(fsm,"stateClass"); 
  }

  override public function update(elapsed:Float):Void{
    fsm.update(elapsed);
    super.update(elapsed);
    if(health<1)kill();
    attackTargets=[];
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
    owner.path.update(elapsed);
  }

  override public function exit(owner:Character){
    owner.path.cancel();
  }
}

class Chase extends FlxFSMState<Character>{
  override public function enter(owner:Character,fsm:FlxFSM<Character>){
    
  }
  
  override public function update(elapsed:Float,owner:Character,fsm:FlxFSM<Character>){
    if(!owner.attackTargets.empty()){
      owner.animation.play("Move"+Std.string(owner.direction));
      var path=PlayState.field.findPath(owner.getMidpoint(),owner.attackTargets[0].getMidpoint());
      owner.stareAtPoint(path[0]);
      owner.path.start(path);
      owner.path.update(elapsed);
      
    };
  }

  override public function exit(owner:Character){
    owner.path.cancel();
  }
}

class Attack extends FlxFSMState<Character>{
  /**
   *  攻撃間隔
   */
  public var attackInterval:FlxTimer;
  
  override public function new(elapsed:Float){
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
      PlayState.makeCollision().configure(
        owner.attackTarget.getMidpoint().x,
        owner.attackTarget.getMidpoint().y,
        function(character:Character){
          // FlxSpriteUtil.flicker(character,0.5);
        },objects.Collision.ColliderType.ONCE);
      PlayState.particleEmitter.focusOn(owner);
      PlayState.particleEmitter.alpha.set(0,0,255);
      PlayState.particleEmitter.speed.set(60);
      PlayState.particleEmitter.lifespan.set(0.2);
      for (i in 0 ... 10){
        var p = new FlxParticle();
        p.makeGraphic(2,2,FlxColor.YELLOW);
        p.exists = false;
        PlayState.particleEmitter.add(p);
      }
      PlayState.particleEmitter.start(true,0.02,4);
      owner.attackTarget.health-=1;
      owner.attackTarget=null;
    }
  }

  override public function exit(owner:Character){

  }
}