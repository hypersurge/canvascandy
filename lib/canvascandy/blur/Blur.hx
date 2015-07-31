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
	private var _highQuality:Bool;
	private var _context:Context;
	private var _canvas:CanvasElement;
	private var _context2d:CanvasRenderingContext2D;
	private var _width:Int;
	private var _height:Int;
	private var _isDirty:Bool;
	
	public function new( p_kernel:IKernel, p_original:ImageElement, p_blur:Int = 4, p_highQuality:Bool = false )
	{
		_context = new Context();
		_original = p_original;
		_blur = p_blur;
		_highQuality = p_highQuality;
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
		configure( _blur );
	}
	
	public function configure( p_blur:Int ):Void
	{
		if ( p_blur < 1 ) p_blur = 1;
		if ( p_blur > _MAX_BLUR ) p_blur = _MAX_BLUR;
		if ( !_highQuality && ( p_blur % 2 == 1 ) ) p_blur++;
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
		var l_alpha:Float = ( _highQuality ? 1 : 2 ) / _blur;
		_context2d.globalAlpha = l_alpha;
		var i:Int = 1;
		while ( i < _blur )
		{
			_context2d.drawImage( _canvas, -i, -i );
			_context2d.drawImage( _canvas, 0, -i );
			_context2d.drawImage( _canvas, i, -i );
			_context2d.drawImage( _canvas, -i, 0 );
			_context2d.drawImage( _canvas, 0, 0 );
			_context2d.drawImage( _canvas, i, 0 );
			_context2d.drawImage( _canvas, -i, i );
			_context2d.drawImage( _canvas, 0, i );
			_context2d.drawImage( _canvas, i, i );
			i += _highQuality ? 1 : 2;
		}
		_isDirty = false;
	}	
	
}