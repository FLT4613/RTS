package objects;
import flixel.FlxSprite;
using flixel.util.FlxSpriteUtil;
import flixel.util.FlxPath;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.math.FlxAngle;
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

  override public function new(x:Float,y:Float,color:FlxColor):Void{
    super();
    path=new FlxPath();
    direction=Direction.UP;
    motion=Motion.STAY;
    makeGraphic(16, 16, 0xFFFFFFFF,true);
    setPosition(x-width/2,y-height/2);
    FlxSpriteUtil.drawTriangle(this,3,3,10,color);
  }

  override public function update(elapsed:Float):Void{
    super.update(elapsed);
    if(choosing){
      this.color=0xFF0000;
    }else{
      this.color=0xFFFFFF;
    }
    switch(motion){
      case STAY:
      case MOVING:
        switch(path.angle){
          case value if(-45<=value && value<45): direction=UP;
          case value if(45<=value && value<=135): direction=RIGHT;
          case value if(-45>=value && value>=-135): direction=LEFT;
          case value if(-135>value || value>135): direction=DOWN;
          case _: throw FlxAngle.angleBetweenPoint(this,path.head(),true);
        }
      case COMBAT:
    }
    switch(direction){
      case UP:angle=0;
      case RIGHT:angle=90;
      case DOWN:angle=180;
      case LEFT:angle=-90;
      default: throw Std.string(direction);
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
}