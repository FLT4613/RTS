package;

using Lambda;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
using flixel.util.FlxSpriteUtil;
import flixel.FlxState;
import flixel.util.FlxColor;
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
	 * 味方キャラクターのオブジェクトプール
	 */
	var friendsSide:FlxTypedGroup<Character>;

	/**
	 * 敵キャラクターのオブジェクトプール
	 */
	var enemiesSide:FlxTypedGroup<Character>;

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
	
		// 味方キャラクターの定義
		friendsSide=new FlxTypedGroup<Character>();
		for(i in 0...4){
			var character=new Character(field.getTileCoordsByIndex(261,true).x,field.getTileCoordsByIndex(261,true).y,FlxColor.BLUE);
			friendsSide.add(character);
			FlxMouseEventManager.add(character,null,onMouseUp,character.onMouseOver,character.onMouseOut); 
		}
		choosings=new FlxTypedGroup<Character>();

		// 敵キャラクターの定義
		enemiesSide=new FlxTypedGroup<Character>();
		for(i in 0...4){
			var character=new Character(field.getTileCoordsByIndex(38,true).x,field.getTileCoordsByIndex(38,true).y,FlxColor.RED);
			enemiesSide.add(character);
		}

		// 地形描画領域の定義
		selectedRange=new FlxSprite(0,0);
		selectedRange.makeGraphic(FlxG.width,FlxG.height,0x66FFFFFF);
		selectedRange.kill();
	
		// 下位レイヤから加える
		add(field);
		add(fieldArea);
		add(friendsSide);
		add(enemiesSide);
		add(selectedRange);

		FlxG.debugger.toggleKeys=["Q"];
	}

	override public function update(elapsed:Float):Void{
		super.update(elapsed);
		FlxG.watch.addQuick("Grid_XY",FlxG.mouse.getPosition().scale(1/gridSize).floor());
		FlxG.watch.addQuick("Grid_Index",field.getTileIndexByCoords(FlxG.mouse.getPosition()));
		if(FlxG.mouse.justPressed){
			selectedRange.revive();
			selectedRange.clipRect=FlxRect.weak();
			selectedRangeStartPos=FlxG.mouse.getPosition();
		}

		if(FlxG.mouse.justPressedRight){
			friendsSide.forEachAlive(function(character){
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
			var tileCoordX:Int = Math.floor(FlxG.mouse.x / gridSize);
			var tileCoordY:Int = Math.floor(FlxG.mouse.y / gridSize);
			friendsSide.forEachAlive(function(character){
				if(FlxG.swipes[0].distance==0 && character.choosing){
					var path=field.findPath(character.getMidpoint(),FlxPoint.get(tileCoordX*gridSize+gridSize/2,tileCoordY*gridSize+gridSize/2));
					character.moveStart(path,(FlxG.keys.pressed.A)?true:false);
				}
				if(selectedRange.clipRect.containsPoint(character.getMidpoint())){
					choosings.add(character);
					character.choosing=true;
				}
			});
			selectedRange.kill();	
		}
		breakOverlapping(friendsSide);
		breakOverlapping(enemiesSide);
	}

	public function onMouseUp(character:Character){
		if(character.choosing){
			choosings.remove(character);
		}else{
			choosings.add(character);
		}
    character.choosing=(character.choosing)?false:true;
	}

	public function breakOverlapping(characterPool:FlxTypedGroup<Character>){
	  var characterPositions=new Map<Int,Character>();
		var overlappings=new Map<Int,Array<Character>>();

		characterPool.forEachAlive(function(character:Character){
			var index=field.getTileIndexByCoords(character.getMidpoint());
			if(character.motion==Motion.STAY){
				if(characterPositions.exists(index)){
					if(!overlappings.exists(index))overlappings.set(index,new Array<Character>());
					overlappings.get(index).push(character);
				}else{
					characterPositions.set(index,character);
				}
			}
		});

		for(overlapPoint in overlappings.keys()){
			var tileCoord=field.getTileCoordsByIndex(overlapPoint,true);
			var criteria=characterPositions.get(overlapPoint).direction;
			var passableIndexes=new Array<Int>();
			for(direction in [criteria.clockwise().clockwise(),criteria,criteria.antiClockwise().antiClockwise(),criteria.reverse()]){
				var checkingPoint=field.getTileIndexByCoords(direction.toVector().scale(gridSize).addPoint(tileCoord));
				if(field.getTileCollisions((field.getTileByIndex(checkingPoint)))==FlxObject.NONE){
					passableIndexes.push(checkingPoint);
				}
			}
			if(passableIndexes.empty()){
				continue;
			}
			var route=passableIndexes.find(function(index:Int){
				return !characterPositions.exists(index);
			});
			if(route==null){
				var representDir=overlappings.get(overlapPoint)[0].direction;
				for(direction in [representDir.clockwise().clockwise(),representDir,representDir.antiClockwise().antiClockwise(),representDir.reverse()]){
					var checkingPoint=field.getTileIndexByCoords(direction.toVector().scale(gridSize).addPoint(tileCoord));
					if(field.getTileCollisions((field.getTileByIndex(checkingPoint)))==FlxObject.NONE){
						route=checkingPoint;
						break;
					}
				}
			}
			overlappings.get(overlapPoint).iter(function(character:Character){
				character.moveStart(
					field.findPath(character.getMidpoint(),
					field.getTileCoordsByIndex(route,true)),
					true);
			});
		}
	}
}
