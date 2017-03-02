package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;

import objects.Character;

class PlayState extends FlxState
{
	var player:Character;
	override public function create():Void
	{
		super.create();
		player=new Character();
		add(player);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if(FlxG.keys.pressed.W)player.y--;
		if(FlxG.keys.pressed.A)player.x--;
		if(FlxG.keys.pressed.S)player.y++;
		if(FlxG.keys.pressed.D)player.x++;
	}
}
