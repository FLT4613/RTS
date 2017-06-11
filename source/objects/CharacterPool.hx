package objects;

using Lambda;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;

import objects.*;

class CharacterPool extends FlxTypedGroup<Character>{
  var positions:Map<Int,Array<Character>>;

  override public function new(){
    super();
    positions=new Map<Int,Array<Character>>();
  }

  override public function update(elapsed){
    super.update(elapsed);
		members.sort(function(a,b){
			return Std.int(a.y-b.y);
		});
		updatePositions();
		avoidSymbolsOverlap();
  }

  // 近接するシンボルを算出・通知する
  private function notifyNearSymbols(){

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

  private function avoidSymbolsOverlap(){
		var overlappings=Lambda.filter(positions,function(x){
			return x.filter(function(c){return c.fsm.stateClass==objects.Character.Idle && !c.path.active;}).length>1;
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
				trace("Here is "+PlayState.field.getTileIndexByCoords(character.getMidpoint())+". Go to :"+route);
				character.moveStart(PlayState.field.getTileCoordsByIndex(route,true));
			});
  	}
	}
}