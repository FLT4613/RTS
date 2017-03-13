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
import flixel.tile.FlxTilemap;
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
	public var gridSize(default,null)=32;

	/**
	 * 地形 
	 */
	var field:FlxTilemap;

	override public function create():Void{
		super.create();
		field=new FlxTilemap();
		field.loadMapFromCSV(AssetPaths.map__csv,AssetPaths.tiles__png,32);
		// 地形描画領域の定義
		field.setTileProperties(0,FlxObject.ANY);
		field.setTileProperties(1,FlxObject.ANY);
		field.setTileProperties(2,FlxObject.NONE);
		field.setTileProperties(3,FlxObject.NONE);
		field.setTileProperties(4,FlxObject.ANY);
		field.setTileProperties(5,FlxObject.ANY);

		fieldArea=new FlxSprite(0,0);
		fieldArea.makeGraphic(FlxG.width,FlxG.height,0x00000000);

		// グリッド縦ライン
		for(i in 0...Std.int(FlxG.width/gridSize)+1){
			FlxSpriteUtil.drawLine(fieldArea,i*gridSize,0,i*gridSize,FlxG.height);
		}
		// グリッド横ライン
		for(i in 0...Std.int(FlxG.height/gridSize)+1){
			FlxSpriteUtil.drawLine(fieldArea,0,i*gridSize,FlxG.width,i*gridSize);
		}

		// FlxMouseEventManager.add(field,function(f:FlxObject){
		// 	trace(field.getTile(tileCoordX,tileCoordY));

		// 	choosings.forEachAlive(function(character){

		// 	});
		// });

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
		add(field);
		add(fieldArea);
		add(characterPool);
		add(selectedRange);
	}

	override public function update(elapsed:Float):Void{
		super.update(elapsed);
		if(FlxG.mouse.justPressed){
			var tileCoordX:Int = Math.floor(FlxG.mouse.x / gridSize);
			var tileCoordY:Int = Math.floor(FlxG.mouse.y / gridSize);
			characterPool.forEachAlive(function(character:Character){
				if(character.choosing){
					var path=field.findPath(character.getMidpoint(),FlxPoint.get(tileCoordX * gridSize + gridSize/2, tileCoordY * gridSize + gridSize/2));
					character.moveStart(path,(FlxG.keys.pressed.A)?true:false);
				}
			});
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
		// 同時に同座標に停止時、重複を回避する動作
		overlappings.forEachAlive(function(character:Character){
			var gridPos=FlxPoint.get(Math.ceil(character.x/gridSize),Math.ceil(character.y/gridSize));
			if(!characterPositions.exists(function(point:FlxPoint){
				return character.direction.clockwise().clockwise().toVector().addPoint(gridPos).equals(point);
			})){
				gridPos.addPoint(character.direction.clockwise().clockwise().toVector());
			}else{
				gridPos.addPoint(character.direction.toVector());
			}
			character.moveStart([gridPos.scale(gridSize).subtract((gridSize/2),(gridSize/2))],true);
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
