package objects;

import flixel.math.FlxPoint;
import flixel.math.FlxMath;

enum Direction{
  UP;
  UP_RIGHT;
  RIGHT;
  DOWN_RIGHT;
  DOWN;
  DOWN_LEFT;
  LEFT;
  UP_LEFT;
  UNDEFINED;
}

abstract DirectionalVector(Direction) from Direction to Direction{
  private inline function new(direction:Direction){
    this=direction;
  }

  @:from static public function fromDirection(direction:Direction){
    return new DirectionalVector(direction);
  }

  @:from static public function fromFlxPoint(a:FlxPoint){
    return new DirectionalVector(
      switch ([FlxMath.signOf(Std.int(a.x))*FlxMath.absInt(Std.int(a.x)),FlxMath.signOf(Std.int(a.y))*FlxMath.absInt(Std.int(a.y))]) {
        case [0,-1]   : UP         ;
        case [1,-1]   : UP_RIGHT   ;
        case [1,0]    : RIGHT      ;
        case [1,1]    : DOWN_RIGHT ;
        case [0,1]    : DOWN       ;
        case [-1,1]   : DOWN_LEFT  ;
        case [-1,0]   : LEFT       ;
        case [-1,-1]  : UP_LEFT    ;
        default       : UNDEFINED  ;
      });
  }

  @:to public function toVector():FlxPoint{
    return switch (this) {
      case UP         : FlxPoint.get(0,-1);
      case UP_RIGHT   : FlxPoint.get(1,-1);
      case RIGHT      : FlxPoint.get(1,0);
      case DOWN_RIGHT : FlxPoint.get(1,1);
      case DOWN       : FlxPoint.get(0,1);
      case DOWN_LEFT  : FlxPoint.get(-1,1);
      case LEFT       : FlxPoint.get(-1,0);
      case UP_LEFT    : FlxPoint.get(-1,-1);
      case UNDEFINED  : FlxPoint.get(0,0);
    }
  }

  public inline function isDefined():Bool{
    return this!=UNDEFINED;
  }

  public inline function clockwise():DirectionalVector{
    return switch (this){
      case UP         : UP_RIGHT;
      case UP_RIGHT   : RIGHT;
      case RIGHT      : DOWN_RIGHT;
      case DOWN_RIGHT : DOWN;
      case DOWN       : DOWN_LEFT;
      case DOWN_LEFT  : LEFT;
      case LEFT       : UP_LEFT;
      case UP_LEFT    : UP;
      case UNDEFINED  : UNDEFINED;
    }
  }
  public inline function antiClockwise():DirectionalVector{
    return switch (this){
      case UP         : UP_LEFT;
      case UP_RIGHT   : UP;
      case RIGHT      : UP_RIGHT;
      case DOWN_RIGHT : RIGHT;
      case DOWN       : DOWN_RIGHT;
      case DOWN_LEFT  : DOWN;
      case LEFT       : DOWN_LEFT;
      case UP_LEFT    : LEFT;
      case UNDEFINED  : UNDEFINED;
    }
  }
  public inline function reverse():DirectionalVector{
    return new DirectionalVector(this).clockwise().clockwise().clockwise().clockwise();
  }
}