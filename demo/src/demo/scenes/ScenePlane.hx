package demo.scenes;
import canvascandy.plane.Plane;

/**
 * @author	Robert Fell
 */

class ScenePlane extends AScene 
{
	private var _plane: Plane;
	
	override function _init():Void 
	{
		super._init();
		addEntity( _plane = new Plane( _kernel, _kernel.assets.getAsset( Assets.Circle__png ) ), true, 2 );
		_text.text = "#3 Plane";
	}
	
	override function _updater( p_deltaTime:Int = 0 ):Void 
	{
		super._updater( p_deltaTime );
		var l_point1 = Plane.createPoint( 100 + ( Math.sin( _age / 1000 ) * 100 ), 50 + ( Math.sin( _age / 1100 ) * 20 ) );
		var l_point2 = Plane.createPoint( 600 + ( Math.sin( _age / 900 ) * 50 ), 20 + ( Math.sin( _age / 1500 ) * 10 ) );
		var l_point3 = Plane.createPoint( 650 + ( Math.sin( _age / 2000 ) * 60 ), 350 + ( Math.sin( _age / 9000 ) * 50 ) );
		var l_point4 = Plane.createPoint( 50 + ( Math.sin( _age / 1800 ) * 80 ), 380 + ( Math.sin( _age / 1050 ) * 20 ) );
		_plane.configure( l_point1, l_point2, l_point3, l_point4, true );
	}
}
