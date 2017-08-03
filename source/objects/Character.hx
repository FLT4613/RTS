package objects;
import flixel.FlxG;
using Lambda;
import flixel.util.FlxPath;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import objects.Direction;
using flixel.util.FlxSpriteUtil;
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
   *  感情アイコン
   */
  public var emotion:Emotion;

  /**
   *  トゥイーン
   */
  public var tween:FlxTween;

  /**
   *  影
   */
  public var shadow:FlxNestedSprite;

  /**
   *  選択中か？
   */
  public var chosen:Bool=false;

  /**
   *  このCharacterにとっての味方
   */
  public var friends:CharacterPool;

  /**
   *  このCharacterにとっての敵
   */
  public var enemies:CharacterPool;

  override public function new(x:Float,y:Float,friends,enemies):Void{
    super(x-width/2,y-height/2);
    path=new FlxPath();
    attackTargets=new Array();
    destinations=new Array<FlxPoint>();
    chasingRange=120;
    attackRange=25;
    emotion=new Emotion(0,0);
    emotion.kill();

    this.friends=friends;
    this.enemies=enemies;

    shadow=new FlxNestedSprite();
    shadow.makeGraphic(32,32,0x00000000).drawEllipse(0,0,14,6,0x33000000);
    shadow.relativeX=9;
    shadow.relativeY=24;
    add(shadow);

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
    animation.add("DeadRIGHT",[32]);
    animation.add("DeadLEFT",[33]);
    setSize(11,15);
    offset.set(10,13);

    emotion.relativeX=8;
    emotion.relativeY=-12;
    add(emotion);

    fsm=new FlxFSM<Character>(this);
    var finishPoint=FlxPoint.weak(x+FlxG.random.float(-100,100),y+FlxG.random.float(-10,10));
    var topPoint=FlxPoint.weak((x+finishPoint.x)/2,y+FlxG.random.float(-100,-50));

    tween=FlxTween.quadMotion(this,x,y,topPoint.x,topPoint.y,finishPoint.x,finishPoint.y,1,true);
    tween.cancel();
    var knockBackCondition=function(character:Character){
      return !character.tween.finished;
    }
    var deadCondition=function(a){
      return health<=0;
    }
    fsm.transitions.add(Idle,Chase,function(a){
      if(enemies.getCharactersWithIn(getMidpoint(),chasingRange)[0]!=null){
        FlxG.sound.play(AssetPaths.attack__wav,0.5);
        emotion.emote("attack");
        return true;
      }
      return false;
    }).add(Chase,Idle,function(a){
      return enemies.getCharactersWithIn(getMidpoint(),chasingRange)[0]==null;
    }).add(Chase,Attack,function(a){
      attackTarget=enemies.getCharactersWithIn(getMidpoint(),attackRange)[0];
      return attackTarget!=null;
    }).add(Attack,Chase,function(a){
      return animation.finished || !attackTarget.alive;
    })
    .add(Attack,Dead,deadCondition)
    .add(Chase,Dead,deadCondition)
    .add(Idle,Dead,deadCondition)
    .add(Dead,Idle,function(a){
      return health>0;
    }).add(Idle,KnockBack,knockBackCondition)
    .add(Chase,KnockBack,knockBackCondition)
    .add(Attack,KnockBack,knockBackCondition)
    .add(KnockBack,Idle,function(a){return tween.finished && attackTargets.empty();})
    .add(KnockBack,Chase,function(a){return tween.finished && !attackTargets.empty();})
    .add(KnockBack,Dead,function(a){return tween.finished && health<=0;})
    .start(Idle);

    FlxG.watch.add(fsm,"stateClass",Type.getClassName(Type.getClass(this)));
    initialize();
  }

  override public function update(elapsed:Float):Void{
    super.update(elapsed);
    fsm.update(elapsed);
    attackTargets=enemies.getCharactersWithIn(getMidpoint(),chasingRange);
  }

  /**
   * キャラクターを移動させる
   @param   dest 目的地
   @param   keepChoice 選択状態を維持する(true) しない(false)
   */
  public function moveStart(point:FlxPoint){
    if(destinations.length>1){
      if(destinations[destinations.length-1].equals(point))return;
    }
    destinations.push(point);
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

  /**
   *  ゲーム中に増減する数値を初期化する
   */
  public function initialize(){
    health=10;
    path.cancel();
    attackTargets=[];
    destinations=[];
    attackTarget=null;
    direction=Direction.DOWN;
  }

  override public function revive(){
    super.revive();
    initialize();
  }

  /**
   *  ノックバックさせる ノックバック中は状態遷移が無効になる。
   */
  public function knockBack(){
    var finishPoint=FlxPoint.weak(x+FlxG.random.float(-100,100),y+FlxG.random.float(-10,10));
    var topPoint=FlxPoint.weak((x+finishPoint.x)/2,y+FlxG.random.float(-100,-50));
    tween=FlxTween.quadMotion(this,x,y,topPoint.x,topPoint.y,finishPoint.x,finishPoint.y,1,true);
  }
}

class KnockBack extends FlxFSMState<Character>{
  override public function enter(owner:Character,fsm:FlxFSM<Character>){
    owner.animation.play("DeadLEFT");
  }

  override public function update(elapsed:Float,owner:Character,fsm:FlxFSM<Character>){

  }

  override public function exit(owner:Character){

  }
}

class Idle extends FlxFSMState<Character>{
  override public function enter(owner:Character,fsm:FlxFSM<Character>){
    owner.animation.play("Idle"+Std.string(owner.direction));
  }

  override public function update(elapsed:Float,owner:Character,fsm:FlxFSM<Character>){
    if(!owner.destinations.empty() && owner.path.finished){
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

class Dead extends FlxFSMState<Character>{
  override public function enter(owner:Character,fsm:FlxFSM<Character>){
    owner.chosen=false;
    owner.kill();
  }
}