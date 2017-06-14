package ui;

import flixel.group.FlxSpriteGroup;

class UI extends FlxSpriteGroup{
  private var grid:Grid;
  override public function new(){
    super();
    grid=new Grid();
    add(grid);
  }
}
