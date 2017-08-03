package objects;

import flixel.FlxG;
using Lambda;
import flixel.util.FlxPath;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import objects.Direction;
using flixel.FlxSprite;
using flixel.util.FlxSpriteUtil;
import flixel.addons.util.FlxFSM;
import flixel.addons.display.FlxNestedSprite;

class Human implements Symbol extends FlxSprite{
   /**
   *  キャラクターの向き
   */
  public var direction:DirectionalVector;  
}