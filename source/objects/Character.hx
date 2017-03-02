package objects;
import flixel.FlxSprite;

class Character extends FlxSprite{

  /**
   *  このキャラクターを選択しているか否か
   */
  public var choosing:Bool=false;
  override public function new(x:Float,y:Float):Void{
    super(x,y);
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

	public function onMouseUp(character:Character){
    choosing=(choosing)?false:true;
	}

	public function onMouseOver(character:Character){
		setGraphicSize(character.graphic.width*2,character.graphic.height*2);
	}

	public function onMouseOut(character:Character){
		character.setGraphicSize(Std.int(character.width),Std.int(character.height));
	}
}