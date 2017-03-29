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
  public var attackTarget:Array<Character>;

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
    attackTarget=new Array();
    chasingRange=120;
    attackRange=25;
    direction=Direction.UP;
    motion=Motion.STAY;
    loadGraphic(AssetPaths.Character__png,true,32,32,true);
    animation.add("StayUp"    ,[0],10,true);
    animation.add("StayDown"  ,[0+4],10,true);
    animation.add("StayLeft"  ,[0+4+4],10,true);
    animation.add("StayRight" ,[0+4+4+4],10,true);
    animation.add("WalkUp"    ,[2,1,2,3],10,true);
    animation.add("WalkDown"  ,[2+4,1+4,2+4,3+4],10,true);
    animation.add("WalkLeft"  ,[2+4+4,1+4+4,2+4+4,3+4+4],10,true);
    animation.add("WalkRight" ,[2+4+4+4,1+4+4+4,2+4+4+4,3+4+4+4],10,true);
    setSize(10,10);
    offset.set(12,12);
    setPosition(x-width/2,y-height/2);
    attackInterval=new FlxTimer();
    health=10;
    FlxG.watch.add(this,"motion");
  }

  override public function update(elapsed:Float):Void{
    super.update(elapsed);
    if(health<1)kill();
    if(!attackTarget.empty()){
      var target=getAttackableTarget();
      if(target!=null){
        motion=COMBAT;
        path.cancel();
        stareAtPoint(target.getMidpoint());
       if(!attackInterval.active)
        attackInterval.start(3,function(a){
           PlayState.makeCollision().configure(
            target.getMidpoint().x,
            target.getMidpoint().y,
            function(character:Character){
              FlxSpriteUtil.flicker(character,0.5);
            },objects.Collision.ColliderType.ONCE);
            target.health-=1;
        });
      }else{
        motion=MOVING;
				moveStart(PlayState.field.findPath(getMidpoint(),attackTarget[0].getMidpoint()));
      }
      attackTarget=[];
    }else{
      attackInterval.cancel();
      if(path.active)motion=MOVING;
      else motion=STAY;
    }
    switch(motion){
      case STAY:
      case MOVING:
        stareAtPoint(path.nodes[path.nodeIndex]);
      case COMBAT:
    }
    switch(direction){
      case UP:
        if(motion==MOVING)animation.play("WalkUp");
        else animation.play("StayUp");
      case RIGHT:
        if(motion==MOVING)animation.play("WalkRight");
        else animation.play("StayRight");
      case DOWN:
        if(motion==MOVING)animation.play("WalkDown");
        else animation.play("StayDown");
      case LEFT:
        if(motion==MOVING)animation.play("WalkLeft");
        else animation.play("StayLeft");
      default: throw Std.string(direction);
    }
    // if(choosing){
    //   this.color=0xFF0000;
    // }else{
    //   this.color=0xFFFFFF;
    // }
  }

  /**
   * キャラクターを移動させる
   @param   dest 目的地 
   @param   keepChoice 選択状態を維持する(true) しない(false) 
   */
  public function moveStart(dest:Array<FlxPoint>,?keepChoice:Bool=false){
    path.cancel();
    if(!keepChoice)choosing=false;
    motion=Motion.MOVING;
    path.onComplete=function(path:FlxPath){motion=Motion.STAY;};
    path.start(dest);
  }

	public function onMouseOver(character:Character){
		setGraphicSize(character.graphic.width*2,character.graphic.height*2);
	}

	public function onMouseOut(character:Character){
		character.setGraphicSize(Std.int(character.width),Std.int(character.height));
	}

  /**
   * 攻撃が届く範囲にいるキャラクターのうち、最も近いものを返す
   * @return  攻撃が届く`Character` または `null`
   */
  public function getAttackableTarget():Character{    
    var min:Character=null;
    for(character in attackTarget.filter(function(a){
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