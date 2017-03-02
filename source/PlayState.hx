package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.group.FlxSpriteGroup;

import flixel.input.mouse.FlxMouseEventManager;
import objects.Character;

class PlayState extends FlxState{
	var characterPool:FlxSpriteGroup;

	override public function create():Void{
		super.create();
		characterPool=new FlxSpriteGroup();
		for(i in 0...9){
			var character=new Character(FlxG.random.int(50,FlxG.width-50),FlxG.random.int(50,FlxG.height-50));
			characterPool.add(character);
			FlxMouseEventManager.add(character,null,null,character.onMouseOver,character.onMouseOut); 
		}
		add(characterPool);
	}

	override public function update(elapsed:Float):Void{
		super.update(elapsed);
	}
}
