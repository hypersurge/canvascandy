package canvascandy.blur;
import awe6.core.Context;
import awe6.core.Entity;
import awe6.interfaces.IKernel;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.ImageElement;

/**
 * ...
 * @author	Robert Fell
 */
	
class Blur extends Entity 
{	
	private static inline var _MAX_BLUR = 16;
	
	private var _original:ImageElement;
	private var _blur:Int;
	private var _quality:Int;
	private var _context:Context;
	private var _canvas:CanvasElement;
	private var _context2d:CanvasRenderingContext2D;
	private var _width:Int;
	private var _height:Int;
	private var _isDirty:Bool;
	
	/**
	 * Create a blurred image
	 * @param	p_kernel	The kernel
	 * @param	p_original	The image source to be blurred
	 * @param	p_blur	The blur amount - value between 1 (unblurred) and 16 (16 pixel blur)
	 * @param	p_quality	The quality - value between 1 pass (very pixelly) and 6 (somewhat smooth), default of 3
	 */
	public function new( p_kernel:IKernel, p_original:ImageElement, p_blur:Int = 4, p_quality:Int = 3 )
	{
		_context = new Context();
		_original = p_original;
		_blur = p_blur;
		_quality = p_quality;
		super( p_kernel, _context );
	}
	
	override private function _init():Void 
	{
		super._init();
		_width = _original.width;
		_height = _original.height;
		_context.cache( 0, 0, _width, _height );
		_canvas = _context.cacheCanvas;
		_context2d = _canvas.getContext2d();
		_quality = Std.int( _tools.limit( _quality, 1, 6 ) );
		configure( _blur );
	}
	
	/**
	 * Adjust the blur amount
	 * @param	p_blur	The blur amount - value between 1 (inblurred) and 16 (16 pixel blur)
	 */
	public function configure( p_blur:Int ):Void
	{
		if ( p_blur < 1 ) p_blur = 1;
		if ( p_blur > _MAX_BLUR ) p_blur = _MAX_BLUR;
		_isDirty = ( _updates < 1 ) || ( _blur != p_blur );
		_blur = p_blur;
		_draw();
	}
	
	private function _draw():Void
	{
		if ( !_kernel.isEyeCandy ) return;
		if ( !_isDirty ) return;
		_context2d.clearRect( 0, 0, _width, _height );
		_context2d.globalAlpha = 1;
		_context2d.drawImage( _original, 0, 0 );
		if ( _blur < 1 ) return;
		var l_steps:Array<Int> = [];
		for ( i in 0..._quality )
		{
			var l_displace:Int = Math.ceil( _blur * ( ( i + 1 ) / _quality ) );
			if ( l_steps[ l_steps.length - 1 ] != l_displace )
			{
				l_steps.push( l_displace );
			}
		}
		_context2d.globalAlpha = 1 / ( l_steps.length + 1 );
		for ( i in l_steps )
		{
			_context2d.drawImage( _canvas, -i, -i );
			_context2d.drawImage( _canvas, 0, -i );
			_context2d.drawImage( _canvas, i, -i );
			_context2d.drawImage( _canvas, -i, i );
			_context2d.drawImage( _canvas, 0, i );
			_context2d.drawImage( _canvas, i, i );
		}
		_isDirty = false;
	}	
	
}