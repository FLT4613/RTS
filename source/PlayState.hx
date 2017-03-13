package;

using Lambda;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
using flixel.util.FlxSpriteUtil;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;
import flixel.input.mouse.FlxMouseEventManager;
import objects.*;

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

	/**
	 * 地形描画領域
	 */
	var fieldArea:FlxSprite;

	/**
	 * 選んでるキャラクター
	 */
	var choosings:FlxTypedGroup<Character>;

	/**
	 * 正方形グリッドの1辺の長さ
	 */
	public var gridSize(default,null)=22;

	override public function create():Void{
		super.create();

		// 地形描画領域の定義
		fieldArea=new FlxSprite(0,0);
		fieldArea.makeGraphic(FlxG.width,FlxG.height,0xFF000000);

		// グリッド縦ライン
		for(i in 0...Std.int(FlxG.width/gridSize)+1){
			FlxSpriteUtil.drawLine(fieldArea,i*gridSize,0,i*gridSize,FlxG.height);
		}
		// グリッド横ライン
		for(i in 0...Std.int(FlxG.height/gridSize)+1){
			FlxSpriteUtil.drawLine(fieldArea,0,i*gridSize,FlxG.width,i*gridSize);
		}


		FlxMouseEventManager.add(fieldArea,function(field:FlxSprite){
			choosings.forEachAlive(function(character){
				if(character.choosing)character.moveStart(FlxG.mouse.getPosition(),(FlxG.keys.pressed.A)?true:false);
			});
		});

		// キャラクターオブジェクトプールの定義
		characterPool=new FlxTypedGroup<Character>();
		for(i in 0...9){
			var character=new Character(FlxG.random.int(50,FlxG.width-50),FlxG.random.int(50,FlxG.height-50));
			characterPool.add(character);
			FlxMouseEventManager.add(character,null,onMouseUp,character.onMouseOver,character.onMouseOut); 
		}
		choosings=new FlxTypedGroup<Character>();

		// 地形描画領域の定義
		selectedRange=new FlxSprite(0,0);
		selectedRange.makeGraphic(FlxG.width,FlxG.height,0x66FFFFFF);
		selectedRange.kill();
	
		// 下位レイヤから加える
		add(fieldArea);
		add(characterPool);
		add(selectedRange);
	}

	override public function update(elapsed:Float):Void{
		super.update(elapsed);
		if(FlxG.mouse.justPressed){
			selectedRange.revive();
			selectedRange.clipRect=FlxRect.weak();
			selectedRangeStartPos=FlxG.mouse.getPosition();
		}
		if(FlxG.mouse.justPressedRight){
			characterPool.forEachAlive(function(character){
				choosings.remove(character);
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
					choosings.add(character);
					character.choosing=true;
				}
			});
			selectedRange.kill();	
		}
	  var characterPositions=new Array<FlxPoint>();
	  var overlappings=new FlxTypedGroup<Character>();
		characterPool.forEachAlive(function(character:Character){
			if(character.motion==Motion.STAY){
				var gridPos=FlxPoint.get(Math.ceil(character.x/gridSize),Math.ceil(character.y/gridSize));
				if(characterPositions.exists(function(point:FlxPoint){
					return point.equals(gridPos);
				})){
					overlappings.add(character);
				}else{
					characterPositions.push(gridPos);
				}
			}
		});
		overlappings.forEachAlive(function(character:Character){
			var gridPos=FlxPoint.get(Math.ceil(character.x/gridSize),Math.ceil(character.y/gridSize));
			if(!characterPositions.exists(function(point:FlxPoint){
				return character.direction.clockwise().clockwise().toVector().addPoint(gridPos).equals(point);
			})){
				gridPos.addPoint(character.direction.clockwise().clockwise().toVector());
			}else{
				gridPos.addPoint(character.direction.toVector());
			}
			character.moveStart(gridPos.scale(gridSize).subtract((gridSize/2),(gridSize/2)),true);
		});
	}

	public function onMouseUp(character:Character){
		if(character.choosing){
			choosings.remove(character);
		}else{
			choosings.add(character);
		}
    character.choosing=(character.choosing)?false:true;
	}
}
