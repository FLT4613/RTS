package;

using Lambda;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
using flixel.util.FlxSpriteUtil;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
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
	var choosings:FlxTypedGroup<Character>;

	/**
	 * 正方形グリッドの1辺の長さ
	 */
	public var gridSize(default,null)=32;

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

	public var cursor:Cursor;

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

		grid=new FlxSprite(0,0);
		grid.makeGraphic(FlxG.width,FlxG.height,0x00000000,true);

		ranges=new FlxSprite(0,0);
		ranges.makeGraphic(FlxG.width,FlxG.height,0x00000000,true);

		// グリッド縦ライン
		for(i in 0...Std.int(FlxG.width/gridSize)+1){
			FlxSpriteUtil.drawLine(grid,i*gridSize,0,i*gridSize,FlxG.height);
		}
		// グリッド横ライン
		for(i in 0...Std.int(FlxG.height/gridSize)+1){
			FlxSpriteUtil.drawLine(grid,0,i*gridSize,FlxG.width,i*gridSize);
		}
		
		// 味方キャラクターの定義
		friendsSide=new FlxTypedGroup<Character>();
		for(i in 0...3){
			var character=new Character(field.getTileCoordsByIndex(261,true).x,field.getTileCoordsByIndex(261,true).y,FlxColor.BLUE);
			friendsSide.add(character);
		}
		choosings=new FlxTypedGroup<Character>();

		// 敵キャラクターの定義
		enemiesSide=new FlxTypedGroup<Character>();
		for(i in 0...1){
			var character=new Character(field.getTileCoordsByIndex(128,true).x,field.getTileCoordsByIndex(128,true).y,FlxColor.RED);
			enemiesSide.add(character);
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

		cursor=new Cursor();

		// 下位レイヤから加える
		add(field);
		add(grid);
		add(ranges);
		add(friendsSide);
		add(enemiesSide);
		add(collisions);
		add(particleEmitter);
		add(clickParticles);
		add(selectedRange);
		add(cursor);
		FlxG.debugger.toggleKeys=["Q"];
	}

	override public function update(elapsed:Float):Void{
		super.update(elapsed);
		FlxSpriteUtil.fill(ranges, 0x00000000);
		if(FlxG.debugger.visible){
			FlxG.debugger.drawDebug=true;
			friendsSide.forEachAlive(function(character:Character){
				FlxSpriteUtil.drawCircle(ranges,character.getMidpoint().x,character.getMidpoint().y,character.chasingRange,0x33FF0000);
				FlxSpriteUtil.drawCircle(ranges,character.getMidpoint().x,character.getMidpoint().y,character.attackRange,0x33FF0000);
			});
			enemiesSide.forEachAlive(function(character:Character){
				FlxSpriteUtil.drawCircle(ranges,character.getMidpoint().x,character.getMidpoint().y,character.chasingRange,0x550000EE);
			});
			FlxG.watch.addQuick("Grid_XY",FlxG.mouse.getPosition().scale(1/gridSize).floor());
			FlxG.watch.addQuick("Grid_Index",field.getTileIndexByCoords(FlxG.mouse.getPosition()));
		}else{
			FlxG.debugger.drawDebug=false;
		}

		var nearest:Character=null;
		friendsSide.forEachAlive(function(character){
			var distance=character.getMidpoint().distanceTo(FlxG.mouse.getPosition());
			if(distance>16)return;
			if(nearest==null){
				nearest=character;
				return;
			}
			if(nearest.getMidpoint().distanceTo(FlxG.mouse.getPosition())>distance){
				nearest=character;
			}
		});

		if(nearest!=null){
			cursor.visible=true;
			cursor.setPosition(nearest.x-8,nearest.y-8);
		}else{
			cursor.visible=false;
		}

		if(FlxG.mouse.justPressed){
			selectedRange.revive();
			selectedRange.clipRect=FlxRect.weak();
			selectedRangeStartPos=FlxG.mouse.getPosition();
			var tileCoordX:Int = Math.floor(FlxG.mouse.x/gridSize);
			var tileCoordY:Int = Math.floor(FlxG.mouse.y/gridSize);
			if(nearest!=null){
				choosings.add(nearest);
			}else{
				clickParticles.setPosition(FlxG.mouse.getPosition().x,FlxG.mouse.getPosition().y);
				for (i in 0 ... 20){
					var p = new FlxParticle();
					p.makeGraphic(5,5,FlxColor.WHITE);
					p.exists=false;
					clickParticles.add(p);
				}
				clickParticles.start(true,0,10);			
				if(!FlxG.keys.pressed.Z && choosings.length>0){
					choosings.forEachAlive(function(character){
						character.moveStart(FlxPoint.get(tileCoordX*gridSize+gridSize/2,tileCoordY*gridSize+gridSize/2));
					});
					choosings.clear();
				}
			}
		}

		if(FlxG.mouse.justPressedRight){
			friendsSide.forEachAlive(function(character){
				choosings.remove(character);
			});			
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
			friendsSide.forEachAlive(function(character){
				if(selectedRange.clipRect.containsPoint(character.getMidpoint())){
					choosings.add(character);
				}
			});

			selectedRange.kill();	
		}
		charactersCommonSequence(friendsSide);
		charactersCommonSequence(enemiesSide);

		friendsSide.forEachAlive(function(friend:Character){
			enemiesSide.forEachAlive(function(enemy:Character){
				if(FlxMath.isDistanceWithin(friend,enemy,friend.chasingRange)){
					friend.attackTargets.push(enemy);
				}
				if(FlxMath.isDistanceWithin(friend,enemy,enemy.chasingRange)){
					enemy.attackTargets.push(friend);
				}
			});
		});
	}

	public function charactersCommonSequence(characterPool:FlxTypedGroup<Character>){
	  var characterPositions=new Map<Int,Character>();
		var overlappings=new Map<Int,Array<Character>>();

		// キャラクターの表示順序の設定
		characterPool.members.sort(function(a,b){
			return Std.int(a.y-b.y);
		});

		FlxG.overlap(characterPool,collisions,function(character:Character,collision:Collision){
			collision.onHitCallback(character);
		});
		characterPool.forEachAlive(function(character:Character){
			var index=field.getTileIndexByCoords(character.getMidpoint());
			if(character.fsm.stateClass==objects.Character.Idle){
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
				character.moveStart(field.getTileCoordsByIndex(route,true));
			});
		}
	}

	public static function makeCollision():Collision{
		return collisions.recycle(Collision,Collision.new);
	}
}
