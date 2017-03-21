package objects;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxAngle;
import flixel.util.FlxTimer;

/**
 * 当たり判定の種類
 * @param ONCE 一度当たると消滅
 * @param INTERVAL(t) 一度当たると消滅するが、tフレーム後に再配置
 * @param PERMANENT 永続
 */
enum ColliderType{
  ONCE;
  INTERVAL(interval:Int);
  PERMANENT;
}

/**
 * 汎用的な当たり判定クラス
 * FlxSpriteの拡張
 */
class Collision extends FlxSprite{
  /**
   *  ヒット時の処理
   */
  var callback:Character->Void;

  /**
   *  当たり判定の種類
   */
  var colliderType:ColliderType;

  /**
   *  生存時間
   */
  var livingTime:Float;

  /**
   *  生存時間を計測
   */
  var livingTimer:FlxTimer;

  /**
   * @param   x    左上X座標
   * @param   y    左上Y座標
   * @param   onHit ヒット時の処理
   * @param   colliderType 当たり方(デフォルト:ONCE)
   */
  override public function new(){
    super();
    makeGraphic(16,16,0xAA00FF00);
    livingTimer=new FlxTimer();
  }

  override public function update(elapsed:Float){
    super.update(elapsed);
  }

  public function configure(x:Float,y:Float,onHit:Character->Void,?type:ColliderType,?time:Float=1){
    reset(x-width/2,y-height/2);
    callback=onHit;
    colliderType=type;
    livingTimer.start(time,function(timer:FlxTimer){
      this.kill();
      timer.cancel();
    });
  }

  public function onHitCallback(target:Character){
    callback(target);
    this.kill();
  }
}