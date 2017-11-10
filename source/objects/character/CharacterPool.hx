package objects.character;

using Lambda;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;

import objects.character.state.*;

class CharacterPool extends FlxTypedGroup<Character>{
  public static var positions:Map<Int,Array<Character>>=new Map<Int,Array<Character>>();
	public static var instance(default,null):CharacterPool=new CharacterPool();
  override private function new(){
	  super();
  }

  override public function update(elapsed){
    super.update(elapsed);
		members.sort(function(a,b){
			return Std.int(a.y-b.y);
		});

		updatePositions();
		avoidSymbolsOverlap();
  }

	private function updatePositions(){
		positions=new Map<Int,Array<Character>>();
		forEachAlive(function(character:Character){
			var index=PlayState.field.getTileIndexByCoords(character.getMidpoint());
			if(!positions.exists(index)){
				positions.set(index,[character]);
			}else{
				positions[index].push(character);
			}
		});
	}

	/**
	 * キャラクターの現在位置を更新する
	 * @param   c キャラクター
	 * @param   prevIndex 更新前のindex
	 * @param   nextIndex 更新後のindex
	 */
	public static function notifyPositionUpdate(c:Character,prevIndex:Int,nextIndex:Int){
		positions[prevIndex].remove(c);
		if(positions.exists(nextIndex)){
			positions[nextIndex].push(c);
		}else{
			positions.set(nextIndex,[c]);
		}
	}

  private static function avoidSymbolsOverlap(){
		var overlappings=Lambda.filter(positions,function(x){
			return x.filter(function(c){return c.fsm.stateClass==Idle && !c.path.active;}).length>1;
		});

		if(overlappings.length==0){
			return;
		}

		for(member in overlappings){
			member=member.filter(function(c){return !c.path.active;});
			var tileCoord=PlayState.field.getTileCoordsByIndex(PlayState.field.getTileIndexByCoords(member[0].getMidpoint()),true);
			var criteria=member[0].direction;
			var passableIndexes=new Array<Int>();

			for(direction in [criteria.clockwise().clockwise(),criteria,criteria.antiClockwise().antiClockwise(),criteria.reverse()]){
				var checkingPoint=PlayState.field.getTileIndexByCoords(direction.toVector().scale(PlayState.gridSize).addPoint(tileCoord));
				if(PlayState.field.getTileCollisions((PlayState.field.getTileByIndex(checkingPoint)))==FlxObject.NONE){
					passableIndexes.push(checkingPoint);
				}
			}
			if(passableIndexes.empty()){
				continue;
			}

			var route=passableIndexes.find(function(index:Int){
				return !positions.exists(index);
			});

			if(route==null){
				var representDir=member[0].direction;
				for(direction in [representDir.clockwise().clockwise(),representDir,representDir.antiClockwise().antiClockwise(),representDir.reverse()]){
					var checkingPoint=PlayState.field.getTileIndexByCoords(direction.toVector().scale(PlayState.gridSize).addPoint(tileCoord));
					if(PlayState.field.getTileCollisions((PlayState.field.getTileByIndex(checkingPoint)))==FlxObject.NONE){
						route=checkingPoint;
						break;
					}
				}
			}
			member.shift();
			member.iter(function(character:Character){
				character.moveStart(PlayState.field.getTileCoordsByIndex(route,true));
			});
  	}
	}

	/**
	 * `point`から`range`px内に存在するCharacterの配列を取得
	 *
	 * Array[0]は、`point`から最も近いCharacter、以降距離順に並ぶ
	 *
	 * @param   point 始点
	 * @param   range 距離
	 * @return  `range`内に存在するCharacterの配列
	 */
	public function getCharactersWithIn(point:FlxPoint,range:Float):Array<Character>{
		var withIn=members.filter(function(c){return c.getMidpoint().distanceTo(point)<range && c.alive;});
		withIn.sort(function(a,b){return cast(a.getMidpoint().distanceTo(point)-b.getMidpoint().distanceTo(point),Int);});
		return withIn;
	}

	/**
	 * `range`px内の、最も`point`から近いCharacterを取得
	 * @param   point 始点
	 * @param   range 距離
	 * @return  `range`内、かつ最もpointに近いCharacter
	 */
	public function getNearestCharacterWithIn(point:FlxPoint,range:Float):Character{
		var withIn=getCharactersWithIn(point,range);
		return withIn.empty()?null:withIn[0];
	}

	public function choose(c:Character){
		c.chosen=true;
	}

	public function unChoose(c:Character){
		c.chosen=false;
	}

	public function toggleChoice(c:Character){
		c.chosen=!c.chosen;
	}

	/**
	 *  ある地点`point`にキャラクターを生成する
	 * @param   point 生成地点
	 */
	public function generate(point:FlxPoint,type:CharacterType){
			var character=new Character(point.x,point.y,type);
			add(character);
			return character;
	}

	public function getCharacters(type:CharacterType):Array<Character>{
		return members.filter(function(c:Character){return c.type==type;});
	}
}