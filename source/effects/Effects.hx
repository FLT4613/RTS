package effects;

import flixel.FlxObject;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;

class Effects extends FlxGroup{
	/**
	 * パーティクル
	 */
	public static var particleEmitter:FlxEmitter;

	/**
	 * クリック地点に発生するパーティクル
	 */
	public static var clickParticles:FlxEmitter;

  override public function new(){
		super();
		particleEmitter = new FlxEmitter(0, 0);
		clickParticles = new FlxEmitter(0, 0);
		clickParticles.alpha.set(0,0,255);
		clickParticles.speed.set(100);
		clickParticles.lifespan.set(0.2);
		for (i in 0 ... 100){
			var p = new FlxParticle();
			p.makeGraphic(4,4,0xFFFFFFFF);
			p.exists = false;
			clickParticles.add(p);
		}
    add(particleEmitter);
    add(clickParticles);
  }

	public static function emitClickEffect(point:FlxPoint){
		clickParticles.setPosition(point.x,point.y);
		clickParticles.start(true,0.1,10);
	}
}