package canvascandy.shine;
import awe6.core.Context;
import awe6.core.Entity;
import awe6.interfaces.IKernel;
import js.html.CanvasElement;
import js.html.CanvasGradient;
import js.html.CanvasRenderingContext2D;
import js.html.ImageElement;

/**
 * ...
 * @author	Robert Fell
 */
	
class Shine extends Entity 
{	
	private var _alphaMask:ImageElement;
	private var _speed:Float;
	private var _context:Context;
	private var _canvas:CanvasElement;
	private var _context2d:CanvasRenderingContext2D;
	private var _width:Int;
	private var _height:Int;
	
	public function new( p_kernel:IKernel, p_alphaMask:ImageElement, p_speed:Float = 1 ) 
	{
		_context = new Context();
		_alphaMask = p_alphaMask;
		_speed = p_speed;
		super( p_kernel, _context );
	}
	
	override private function _init():Void 
	{
		super._init();
		_width = _alphaMask.width;
		_height = _alphaMask.height;
		_context.compositeOperation = "lighter";
		_context.cache( 0, 0, _width, _height );
		_canvas = _context.cacheCanvas;
		_context2d = _canvas.getContext2d();
	}
	
	override private function _updater( p_deltaTime:Int = 0 ):Void 
	{
		super._updater( p_deltaTime );
		_draw();
	}
	
	private function _draw():Void
	{
		if ( !_kernel.isEyeCandy ) return;
		
		_context2d.clearRect( 0, 0, _width, _height );
		_context2d.globalCompositeOperation = "source-out";
		_context2d.drawImage( _alphaMask, 0, 0 );
		
		var l_seed:Float = _speed * _age;
		var l_start = _rotatePoint( _width * .5 * Math.sin( l_seed / 900 ), _height * .5, l_seed / 1000, _width * .5, _height * .5 );
		var l_end = _rotatePoint( _width, ( _height * .5 ) + ( _height * .5 * Math.sin( l_seed / 1300 ) ), l_seed / 1000, _width * .5, _height * .5 );
		var l_linearGradient:CanvasGradient = _context2d.createLinearGradient( l_start.x, l_start.y, l_end.x, l_end.y );
		l_linearGradient.addColorStop( .15, "#000000" );
		l_linearGradient.addColorStop( .3, "#FFFFFF" );
		l_linearGradient.addColorStop( .5, "#333333" );
		l_linearGradient.addColorStop( .78, "#a6a6a6" );
		l_linearGradient.addColorStop( .82, "#bfbfbf" );
		l_linearGradient.addColorStop( .86, "#a6a6a6" );
		l_linearGradient.addColorStop( .88, "#FFFFFF" );
		l_linearGradient.addColorStop( .98, "#000000" );
		
		_context2d.fillStyle = l_linearGradient;
		_context2d.globalCompositeOperation = "source-in";
		_context2d.fillRect( 0, 0, _width, _height );
	}	
	
	private function _rotatePoint( p_x:Float, p_y:Float, p_angle:Float, p_centerX:Float, p_centerY:Float ):{ x:Float, y:Float }
	{
		var l_sin:Float = Math.sin( p_angle );
		var l_cos:Float = Math.cos( p_angle );
		// translate point back to origin:
		p_x -= p_centerX;
		p_y -= p_centerY;
		// rotate point
		var l_x = p_x * l_cos - p_y * l_sin;
		var l_y = p_x * l_sin + p_y * l_cos;
		// translate point back:
		l_x += p_centerX;
		l_y += p_centerY;
		return { x:l_x, y:l_y };
	}
}