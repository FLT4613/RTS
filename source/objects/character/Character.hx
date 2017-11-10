package objects.character;

import flixel.FlxG;
using Lambda;
import flixel.util.FlxPath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import objects.Direction;
using flixel.util.FlxSpriteUtil;
import flixel.addons.util.FlxFSM;
import flixel.addons.display.FlxNestedSprite;

import objects.character.state.*;

class Character extends FlxNestedSprite{
  public var type:CharacterType;
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

  override public function new(x:Float,y:Float,type:CharacterType):Void{
    super(x-width/2,y-height/2);
    this.type=type;
    path=new FlxPath();
    attackTargets=new Array();
    destinations=new Array<FlxPoint>();
    chasingRange=120;
    attackRange=25;
    emotion=new Emotion(0,0);
    emotion.kill();
    health=10;
    attackTarget=null;
    direction=Direction.DOWN;

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

    fsm.transitions.add(Idle,Chase,Transitions.findChaseTarget)
    // .add(Chase,Idle,Transitions.loseChaseTarget)
    // .add(Chase,Attack,Transitions.inAttackRange)
    // .add(Attack,Chase,Transitions.defeatEnemy)
    // .add(Attack,Dead,Transitions.dead)
    // .add(Chase,Dead,Transitions.dead)
    .add(Idle,Dead,Transitions.dead)
    // .add(Idle,KnockBack,knockBackCondition)
    // .add(Chase,KnockBack,knockBackCondition)
    // .add(Attack,KnockBack,knockBackCondition)
    // .add(KnockBack,Idle,function(a){return tween.finished && attackTargets.empty();})
    // .add(KnockBack,Chase,function(a){return tween.finished && !attackTargets.empty();})
    // .add(KnockBack,Dead,function(a){return tween.finished && health<=0;})
    .start(Idle);
  }

  override public function update(elapsed:Float):Void{
    super.update(elapsed);
    fsm.update(elapsed);
    // attackTargets=enemies.getCharactersWithIn(getMidpoint(),chasingRange);
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
   *  ノックバックさせる ノックバック中は状態遷移が無効になる。
   */
  public function knockBack(){
    var finishPoint=FlxPoint.weak(x+FlxG.random.float(-100,100),y+FlxG.random.float(-10,10));
    var topPoint=FlxPoint.weak((x+finishPoint.x)/2,y+FlxG.random.float(-100,-50));
    tween=FlxTween.quadMotion(this,x,y,topPoint.x,topPoint.y,finishPoint.x,finishPoint.y,1,true);
  }
}

