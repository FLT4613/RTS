package ui;

import flixel.FlxG;
import flixel.FlxSprite;
using flixel.util.FlxSpriteUtil;

class Grid extends FlxSprite{
	/**
	 * 正方形グリッドの1辺の長さ
	 */
	public var gridSize(default,null)=32;

  override public function new(){
		super();
		makeGraphic(FlxG.width,FlxG.height,0x00000000,true);
		// グリッド縦ライン
		for(i in 0...Std.int(FlxG.width/gridSize)+1){
			FlxSpriteUtil.drawLine(this,i*gridSize,0,i*gridSize,FlxG.height);
		}
		// グリッド横ライン
		for(i in 0...Std.int(FlxG.height/gridSize)+1){
			FlxSpriteUtil.drawLine(this,0,i*gridSize,FlxG.width,i*gridSize);
		}
  }
}


