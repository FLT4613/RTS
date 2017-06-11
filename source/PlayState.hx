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
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
using flixel.input.mouse.FlxMouseEventManager;

import objects.*;

class PlayState extends FlxState{
	/**
	 * キャラクタープール
	 */
	static var characters:CharacterPool;

	/**
	 * 選択範囲の矩形
	 */
	var selectedRange:FlxSprite;

	/**
	 * 選択範囲の始点
	 */
	var selectedRangeStartPos:FlxPoint;

	/**
	 * グリッド描画領域
	 */
	var grid:FlxSprite;

	/**
	 * 範囲の描画領域
	 */
	var ranges:FlxSprite;

	/**
	 * 選んでるキャラクター
	 */
	var choosings:FlxTypedGroup<Friend>;

	/**
	 * 建物
	 */
	static var buildings:FlxTypedGroup<Building>;

	/**
	 * 正方形グリッドの1辺の長さ
	 */
	public static var gridSize(default,null)=32;


	/**
	 * 地形
	 */
	public static var field:FlxTilemap;

	/**
	 * 当たり判定
	 */
	private static var collisions:FlxTypedGroup<Collision>;

	/**
	 * パーティクル
	 */
	public static var particleEmitter:FlxEmitter;

	/**
	 * クリック地点に発生するパーティクル
	 */
	public static var clickParticles:FlxEmitter;

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


		ranges=new FlxSprite(0,0);
		ranges.makeGraphic(FlxG.width,FlxG.height,0x00000000,true);


		FlxG.plugins.add(new FlxMouseEventManager());
		buildings=new FlxTypedGroup();

		characters=new CharacterPool();

		// 味方キャラクターの定義
		for(i in 0...3){
			var character=new Friend(field.getTileCoordsByIndex(261,true).x,field.getTileCoordsByIndex(261,true).y);
			characters.add(character);
		}
		choosings=new FlxTypedGroup<Friend>();

		// 敵キャラクターの定義
		for(i in 0...1){
			var character=new Enemy(field.getTileCoordsByIndex(128,true).x,field.getTileCoordsByIndex(128,true).y);
			characters.add(character);
		}

		collisions=new FlxTypedGroup<Collision>();

		// 地形描画領域の定義
		selectedRange=new FlxSprite(0,0);
		selectedRange.makeGraphic(FlxG.width,FlxG.height,0x66FFFFFF);
		selectedRange.kill();

		particleEmitter = new FlxEmitter(0, 0);
		clickParticles = new FlxEmitter(0, 0);

		clickParticles.alpha.set(0,0,255);
		clickParticles.speed.set(100);
		clickParticles.lifespan.set(0.2);

		// 下位レイヤから加える
		add(field);
		add(buildings);
		add(grid);
		add(ranges);
		add(characters);
		add(collisions);
		add(particleEmitter);
		add(clickParticles);
		add(selectedRange);
		FlxG.debugger.toggleKeys=["Q"];
	}

	override public function update(elapsed:Float):Void{
		super.update(elapsed);
		FlxSpriteUtil.fill(ranges, 0x00000000);

		if(FlxG.debugger.visible){
			FlxG.watch.addQuick("Grid_XY",FlxG.mouse.getPosition().scale(1/gridSize).floor());
			FlxG.watch.addQuick("Grid_Index",field.getTileIndexByCoords(FlxG.mouse.getPosition()));
		}

		var nearest:Friend=null;
		characters.forEachOfType(Friend,function(friend){
			if(!friend.alive)return;
			friend.mouseOverlappedMark.visible=false;
			var distance=friend.getMidpoint().distanceTo(FlxG.mouse.getPosition());
			if(distance>16)return;
			if(nearest==null){
				nearest=friend;
				return;
			}
			if(nearest.getMidpoint().distanceTo(FlxG.mouse.getPosition())>distance){
				nearest=friend;
			}
		});
		if(nearest!=null){
			nearest.mouseOverlappedMark.visible=true;
		}

		if(FlxG.mouse.justPressed){
			selectedRange.revive();
			selectedRange.clipRect=FlxRect.weak();
			selectedRangeStartPos=FlxG.mouse.getPosition();
			var tileCoordX:Int = Math.floor(FlxG.mouse.x/gridSize);
			var tileCoordY:Int = Math.floor(FlxG.mouse.y/gridSize);
			if(nearest!=null){
				if(nearest.pickedMark.visible){
					choosings.remove(nearest);
				}else{
					choosings.add(nearest);
				}
				nearest.pickedMark.visible=!nearest.pickedMark.visible;
			}else{
				clickParticles.setPosition(FlxG.mouse.getPosition().x,FlxG.mouse.getPosition().y);
				for (i in 0 ... 10){
					var p = new FlxParticle();
					p.makeGraphic(5,5,FlxColor.WHITE);
					p.exists=false;
					clickParticles.add(p);
				}
				clickParticles.start(true,0,10);
				if(choosings.length>0){
					choosings.forEachAlive(function(choosing){
						choosing.moveStart(FlxPoint.get(tileCoordX*gridSize+gridSize/2,tileCoordY*gridSize+gridSize/2));
						if(!FlxG.keys.pressed.Z){choosing.pickedMark.visible=false;}
					});
					if(!FlxG.keys.pressed.Z){
						choosings.clear();
					}
				}
			}
		}

		if(FlxG.mouse.justPressedRight){
			choosings.forEachAlive(function(choosing){
				choosing.pickedMark.visible=false;
			});
			choosings.clear();
		}

		if(FlxG.mouse.pressed){
			if(FlxG.swipes!=null){
				selectedRange.clipRect=FlxRect.weak(
					(FlxG.mouse.x>selectedRangeStartPos.x)?selectedRangeStartPos.x:FlxG.mouse.x,
					(FlxG.mouse.y>selectedRangeStartPos.y)?selectedRangeStartPos.y:FlxG.mouse.y,
					Std.int(Math.abs(FlxG.mouse.x-selectedRangeStartPos.x)),
					Std.int(Math.abs(FlxG.mouse.y-selectedRangeStartPos.y))
				);
			}
		}

		if(FlxG.mouse.justReleased){
			characters.forEachOfType(Friend,function(friend){
				if(!friend.alive)return;
				if(selectedRange.clipRect.containsPoint(friend.getMidpoint())){
					choosings.add(friend);
					friend.pickedMark.visible=true;
				}
			});

			selectedRange.kill();
		}

		characters.forEachOfType(Friend,function(friend:Character){
			if(friend.fsm.stateClass==objects.Character.Dead)return;
			characters.forEachOfType(Enemy,function(enemy:Character){
				if(enemy.fsm.stateClass==objects.Character.Dead)return;
				if(FlxMath.isDistanceWithin(friend,enemy,friend.chasingRange)){
					friend.attackTargets.push(enemy);
				}
				if(FlxMath.isDistanceWithin(friend,enemy,enemy.chasingRange)){
					enemy.attackTargets.push(friend);
				}
			});
		});

		if(FlxG.keys.justPressed.ONE){
			spawnCharacter(Friend,FlxG.mouse.x,FlxG.mouse.y);
		}

		if(FlxG.keys.justPressed.TWO){
			spawnCharacter(Enemy,FlxG.mouse.x,FlxG.mouse.y);
		}

		if(FlxG.keys.justPressed.THREE){
			spawnBuilding(FlxG.mouse.x,FlxG.mouse.y);
		}
	}


	public static function makeCollision():Collision{
		return collisions.recycle(Collision,Collision.new);
	}

	public static function spawnCharacter(type:Class<Character>,x:Float,y:Float){
			var character=characters.recycle(type,Friend.new.bind(x,y));
			character.revive();
			characters.add(character);
	}

	public static function spawnBuilding(x:Float,y:Float){
			var building=buildings.recycle(Building.new.bind(x,y));
			building.revive();
			buildings.add(building);
	}
}
