package canvascandy.normalmapping;
import awe6.core.Context;
import awe6.core.Entity;
import awe6.interfaces.IKernel;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.ImageData;
import js.html.ImageElement;
import js.html.Uint8ClampedArray;

/**
 * ...
 * @author http://29a.ch/2010/3/24/normal-mapping-with-javascript-and-canvas-tag
 */
	
class NormalMapping extends Entity 
{	
	private var _texture:ImageElement;
	private var _normal:ImageElement;
	private var _isAutoLight:Bool;
	private var _spotlight:Float;
	private var _ambient:Float;
	
	private var _context:Context;
	private var _canvas:CanvasElement;
	private var _context2d:CanvasRenderingContext2D;
	private var _width:Int;
	private var _height:Int;
	private var _normalData:Array<Int>;
	private var _textureData:Uint8ClampedArray;
	private var _spotlightX:Int;
	private var _spotlightY:Int;
	private var _spotlightZ:Int;
	
	public function new( p_kernel:IKernel, p_texture:ImageElement, p_normal:ImageElement, p_isAutoLight:Bool = true, p_spotlight:Float = .5, p_ambient:Float = .5 ) 
	{
		_context = new Context();
		_texture = p_texture;
		_normal = p_normal;
		_isAutoLight = p_isAutoLight;
		_spotlight = p_spotlight;
		_ambient = p_ambient;
		super( p_kernel, _context );
	}
	
	override private function _init():Void 
	{
		super._init();
		_width = _texture.width;
		_height = _texture.height;
		_context.cache( 0, 0, _width, _height );
		_canvas = _context.cacheCanvas;
		_context2d = _canvas.getContext2d();
		_normalData = _precalculateNormalData( _normal );
        _textureData = _getDataFromImage( _texture ).data;
		_spotlightX = 0;
		_spotlightY = 0;
		_spotlightZ = Math.round( Math.sqrt( ( _width * _width ) + ( _height * _height ) ) );
	}
	
	override private function _updater( p_deltaTime:Int = 0 ):Void 
	{
		super._updater( p_deltaTime );
		if ( _isAutoLight )
		{
			configure( _kernel.inputs.mouse.relativeX, _kernel.inputs.mouse.relativeY );
		}
		_draw();
	}
	
	public function configure( p_lx:Float, p_ly:Float ):Void
	{
		_spotlightX = Math.round( p_lx * _width );
		_spotlightY = Math.round( p_ly * _height );
	}
	
	private function _getDataFromImage( p_image:ImageElement ):ImageData
	{
		return Utils.createCanvasFromImage( p_image ).getContext2d().getImageData( 0, 0, p_image.width, p_image.height );
    }
	
	private function _precalculateNormalData( p_normal:ImageElement ):Array<Int>
	{
		var l_result:Array<Int> = [];
		var l_data = _getDataFromImage( _normal ).data;
		var l_i:Int = 0;
		var l_max:Int = _width * _height * 4;
		while ( l_i < l_max )
		{
            var l_nx:Int = l_data[l_i];
            // flip the y value
            var l_ny:Int = 255 - l_data[l_i + 1];
            var l_nz:Int = l_data[l_i + 2];
            // normalize
            var l_magInv:Float = 1 / Math.sqrt( ( l_nx * l_nx ) + ( l_ny * l_ny ) + ( l_nz * l_nz ) );
            l_nx = Math.round( l_nx * l_magInv );
            l_ny = Math.round( l_ny * l_magInv );
            l_nz = Math.round( l_nz * l_magInv );
            l_result.push( l_nx );
            l_result.push( l_ny );
            l_result.push( l_nz );
			l_i += 4;
		}
		return l_result;
	}
	
	private function _clampInt( p_value:Int, p_min:Int, p_max:Int ):Int
	{
		if ( p_value < p_min ) return p_min;
		if ( p_value > p_max ) return p_max - 1;
		return p_value;
	}	
	
	private function _draw():Void
	{
		var l_imgData = _context2d.getImageData( 0, 0, _width, _height );
		var l_data = l_imgData.data;
		var l_i:Int = 0;
		var l_ni:Int = 0;
		var l_nx:Int = 0;
		var l_ny:Int = 0;
		var l_nz:Int = 0;
		var l_dx:Float = 0;
		var l_dy:Float = 0;
		var l_dz:Float = 0;
		var l_magInv:Float = 0;
		var l_dotProduct:Float = 0;
		var l_intensity:Float = _ambient;
		for ( l_y in 0..._height )
		{
			for ( l_x in 0..._width )
			{
				// get surface normal
				l_nx = _normalData[l_ni];
				l_ny = _normalData[l_ni + 1];
				l_nz = _normalData[l_ni + 2];
				// make it a bit faster by only updateing the direction for every other pixel
				if ( _spotlight > 0 || ( l_ni & 1 ) == 0 )
				{
					// calculate the light direction vector
					l_dx = _spotlightX - l_x;
					l_dy = _spotlightY - l_y;
					l_dz = _spotlightZ;
					// normalize it
					l_magInv = 1.0 / Math.sqrt( ( l_dx * l_dx ) + ( l_dy * l_dy ) + ( l_dz * l_dz ) );
					l_dx *= l_magInv;
					l_dy *= l_magInv;
					l_dz *= l_magInv;
					// take the dot product of the direction and the normal to get the amount of shine
					l_dotProduct = ( l_dx * l_nx ) + ( l_dy * l_ny ) + ( l_dz * l_nz );
					l_intensity = ( Math.pow( l_dotProduct, 2 ) * _spotlight ) + _ambient;
				}
				for ( l_channel in 0...3 )
				{
					l_data[l_i + l_channel] = Math.round( _clampInt( Std.int( _textureData[l_i + l_channel] * l_intensity ), 0, 255 ) );
				}
				l_data[l_i + 3] = _textureData[l_i + 3];
				l_i += 4;
				l_ni += 3;
			}
		}
		_context2d.putImageData( l_imgData, 0, 0 );
	}	
}