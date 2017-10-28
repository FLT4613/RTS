package objects.character.state;
import flixel.FlxG;

class Transitions{
  /**
   *  攻撃対象を発見した時の遷移
      @param c owner
   */
  public static function findChaseTarget(c:Character){
    if(c.enemies.getCharactersWithIn(c.getMidpoint(),c.chasingRange)[0]!=null){
      FlxG.sound.play(AssetPaths.attack__wav,0.5);
      c.emotion.emote("attack");
      return true;
    }
    return false;
  }

  /**
   *  攻撃対象を見失った時の遷移
      @param c owner 
   */
  public static function loseChaseTarget(c:Character){
    return c.enemies.getCharactersWithIn(c.getMidpoint(),c.chasingRange)[0]==null;
  }

  /**
   *  攻撃範囲に入った時の遷移
      @param c owner
   */
  public static function inAttackRange(c:Character){
    c.attackTarget=c.enemies.getCharactersWithIn(c.getMidpoint(),c.attackRange)[0];
    return c.attackTarget!=null;
  }

  /**
   *  敵を倒した時の遷移
      @param c owner
   */
  public static function defeatEnemy(c:Character){
    return c.animation.finished || !c.attackTarget.alive;
  }

  /**
   *  死亡した時の遷移
      @param   c owner
   */
  public static function dead(c:Character){
    return c.health<=0;
  }
}