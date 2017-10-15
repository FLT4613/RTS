package;

using Lambda;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
using flixel.util.FlxSpriteUtil;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
using flixel.input.mouse.FlxMouseEventManager;

import objects.*;
import objects.character.*;
import ui.*;
import effects.*;

class PlayState extends FlxState{
	/**
	 * キャラクタープール
	 */
	public static var friends:CharacterPool;

	public static var enemies:CharacterPool;

	/**
	 * 建物
	 */
	static var buildings:FlxTypedGroup<Building>;

	/**
	 * 正方形グリッドの1辺の長さ
	 */
	public static var gridSize(default,null)=32;

	/**
	 *  エフェクト
	 */
	public var effects:Effects;

	/**
	 *  UI
	 */
	public var ui:UI;

	/**
	 * 地形
	 */
	public static var field:FlxTilemap;

	/**
	 * 当たり判定
	 */
	private static var collisions:FlxTypedGroup<Collision>;

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

		effects=new Effects();
		ui=new UI();

		FlxG.plugins.add(new FlxMouseEventManager());
		buildings=new FlxTypedGroup();

		friends=new CharacterPool();
		enemies=new CharacterPool();

		friends.enemies=enemies;
		enemies.enemies=friends;

		// 味方キャラクターの定義
		for(i in 0...3){
			friends.generate(field.getTileCoordsByIndex(261,true));
		}

		// 敵キャラクターの定義
		for(i in 0...1){
			enemies.generate(field.getTileCoordsByIndex(128,true));
		}

		collisions=new FlxTypedGroup<Collision>();

		// 下位レイヤから加える
		add(field);
		add(buildings);
		add(friends);
		add(enemies);
		add(effects);
			// add(collisions);
			// add(emotions)
		add(ui);
		FlxG.debugger.toggleKeys=["Q"];
	}

	override public function update(elapsed:Float):Void{
		super.update(elapsed);

		if(FlxG.debugger.visible){
			FlxG.watch.addQuick("Grid_XY",FlxG.mouse.getPosition().scale(1/gridSize).floor());
			FlxG.watch.addQuick("Grid_Index",field.getTileIndexByCoords(FlxG.mouse.getPosition()));
		}

		if(FlxG.keys.justPressed.ONE){
			friends.generate(FlxG.mouse.getPosition());
		}

		if(FlxG.keys.justPressed.TWO){
			enemies.generate(FlxG.mouse.getPosition());
		}

		if(FlxG.keys.justPressed.THREE){
			spawnBuilding(FlxG.mouse.x,FlxG.mouse.y);
		}
	}


	public static function makeCollision():Collision{
		return collisions.recycle(Collision,Collision.new);
	}

	public static function spawnBuilding(x:Float,y:Float){
			var building=buildings.recycle(Building.new.bind(x,y));
			building.revive();
			buildings.add(building);
	}
}
