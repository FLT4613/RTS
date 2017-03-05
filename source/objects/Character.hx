package objects;
import flixel.FlxSprite;
import flixel.util.FlxPath;
import flixel.math.FlxPoint;

class Character extends FlxSprite{

  /**
   *  このキャラクターを選択しているか否か
   */
  public var choosing:Bool=false;

  override public function new(x:Float,y:Float):Void{
    super(x,y);
    path=new FlxPath();
    makeGraphic(16, 16, 0xFFFFFFFF);
  }

  override public function update(elapsed:Float):Void{
    super.update(elapsed);
    if(choosing){
      this.color=0xFF0000;
    }else{
      this.color=0xFFFFFF;
    }
  }

  /**
   * キャラクターを移動させる
   @param   dest 目的地 
   @param   keepChoice 選択状態を維持する(true) しない(false) 
   */
  public function moveStart(dest:FlxPoint,?keepChoice:Bool=false){
    path.cancel();
    if(!keepChoice)choosing=false;
    path.start([dest]);
  }

	public function onMouseOver(character:Character){
		setGraphicSize(character.graphic.width*2,character.graphic.height*2);
	}

	public function onMouseOut(character:Character){
		character.setGraphicSize(Std.int(character.width),Std.int(character.height));
	}
}