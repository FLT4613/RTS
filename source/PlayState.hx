package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;

import flixel.input.mouse.FlxMouseEventManager;
import objects.Character;

class PlayState extends FlxState{
	/**
	 * キャラクターのオブジェクトプール
	 */
	var characterPool:FlxTypedGroup<Character>;

	/**
	 * 選択範囲の矩形
	 */
	var selectedRange:FlxSprite;

	/**
	 * 選択範囲の始点
	 */
	var selectedRangeStartPos:FlxPoint;

	override public function create():Void{
		super.create();
		characterPool=new FlxTypedGroup<Character>();
		selectedRange=new FlxSprite(0,0);
		selectedRange.makeGraphic(FlxG.width,FlxG.height,0x66FFFFFF);
		selectedRange.kill();

		for(i in 0...9){
			var character=new Character(FlxG.random.int(50,FlxG.width-50),FlxG.random.int(50,FlxG.height-50));
			characterPool.add(character);
			FlxMouseEventManager.add(character,null,character.onMouseUp,character.onMouseOver,character.onMouseOut); 
		}
		add(characterPool);
		add(selectedRange);
	}

	override public function update(elapsed:Float):Void{
		if(FlxG.mouse.justPressed){
			selectedRange.revive();
			selectedRange.clipRect=FlxRect.weak();
			selectedRangeStartPos=FlxG.mouse.getPosition();
		}
		if(FlxG.mouse.justPressedRight){
			characterPool.forEachAlive(function(character){
				character.choosing=false;
			});			
		}
		if(FlxG.mouse.pressed){
			selectedRange.clipRect=FlxRect.weak(
				(FlxG.mouse.x>selectedRangeStartPos.x)?selectedRangeStartPos.x:FlxG.mouse.x,
				(FlxG.mouse.y>selectedRangeStartPos.y)?selectedRangeStartPos.y:FlxG.mouse.y,
				Std.int(Math.abs(FlxG.mouse.x-selectedRangeStartPos.x)),
				Std.int(Math.abs(FlxG.mouse.y-selectedRangeStartPos.y))
			);
		}
		if(FlxG.mouse.justReleased){
			characterPool.forEachAlive(function(character){
				if(selectedRange.clipRect.containsPoint(character.getMidpoint())){
					character.choosing=true;
				}
			});
			selectedRange.kill();	
		}
		super.update(elapsed);
	}
}
