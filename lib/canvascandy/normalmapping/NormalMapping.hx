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
 * @author	Robert Fell
 * @author	Jonas Wagner (http://29a.ch/2010/3/24/normal-mapping-with-javascript-and-canvas-tag)
 * @author	Blender rendering refernce (http://andyp123.blogspot.ca/2014/09/rendering-scene-normals-in-blender.html)
 */
	
class NormalMapping extends Entity 
{	
	private static inline var _NORMAL_LEVELS = 256;
	
	private var _texture:ImageElement;
	private var _normal:ImageElement;
	private var _isAutoLight:Bool;
	private var _ambient:Float;
	private var _spotlight:Float;
	private var _shine:Float;
	
	private var _context:Context;
	private var _canvas:CanvasElement;
	private var _context2d:CanvasRenderingContext2D;
	private var _buffer:ImageData;
	
	private var _width:Int;
	private var _height:Int;
	private var _normalData:Array<Int>;
	private var _textureData:Uint8ClampedArray;
	private var _spotlightX:Int;
	private var _spotlightY:Int;
	private var _spotlightZ:Int;
	private var _isDirty:Bool;
	
	public function new( p_kernel:IKernel, p_texture:ImageElement, p_normal:ImageElement, p_isAutoLight:Bool = true, p_ambient:Float = .5, p_spotlight:Float = .5, p_shine:Float = .5 ) 
	{
		_context = new Context();
		_texture = p_texture;
		_normal = p_normal;
		_isAutoLight = p_isAutoLight;
		_ambient = p_ambient;
		_spotlight = p_spotlight;
		_shine = p_shine;
		super( p_kernel, _context );
	}
	
	override private function _init():Void 
	{
		super._init();
		_ambient = _tools.limit( _ambient, 0, 1 );
		_spotlight = _tools.limit( _spotlight, 0, 1 ) * 2;
		_shine = 50 * _tools.limit( _shine, .1, 1 );
		_width = _texture.width;
		_height = _texture.height;
		_context.cache( 0, 0, _width, _height );
		_canvas = _context.cacheCanvas;
		_context2d = _canvas.getContext2d();
		_buffer = _context2d.getImageData( 0, 0, _width, _height );
		_normalData = _precalculateNormalData( _normal );
        _textureData = _getDataFromImage( _texture ).data;
		_spotlightX = 0;
		_spotlightY = 0;
		_spotlightZ = Math.round( Math.sqrt( ( _width * _width ) + ( _height * _height ) ) / 4 );
		configure( .5, .5 );
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
		var l_x = Math.round( p_lx * _width );
		var l_y = Math.round( p_ly * _height );
		_isDirty = ( _spotlightX != l_x ) || ( _spotlightY != l_y );
		_spotlightX = l_x;
		_spotlightY = l_y;
	}
	
	private function _getDataFromImage( p_image:ImageElement ):ImageData
	{
		return Utils.createCanvasFromImage( p_image ).getContext2d().getImageData( 0, 0, p_image.width, p_image.height );
    }
	
	private function _precalculateNormalData( p_normal:ImageElement ):Array<Int>
	{
		var l_result:Array<Int> = [];
		var l_data = _getDataFromImage( _normal ).data;
		var l_nx:Int;
		var l_ny:Int;
		var l_nz:Int;
		var l_magInv:Float;
		var l_i:Int = 0;
		var l_max:Int = _width * _height * 4;
		while ( l_i < l_max )
		{
            l_nx = l_data[l_i];
            l_ny = 255 - l_data[l_i + 1];
            l_nz = l_data[l_i + 2];
            // normalize
            l_magInv = 1 / Math.sqrt( ( l_nx * l_nx ) + ( l_ny * l_ny ) + ( l_nz * l_nz ) );
			if ( !Math.isFinite( l_magInv ) || ( l_magInv > 1000 ) )
			{
				l_magInv = 1000;
			}
            l_nx = Std.int( l_nx * l_magInv * _NORMAL_LEVELS );
            l_ny = Std.int( l_ny * l_magInv * _NORMAL_LEVELS );
            l_nz = Std.int( l_nz * l_magInv * _NORMAL_LEVELS );
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
		if ( !_isDirty ) return;
		if ( !_kernel.isEyeCandy ) return;
		var l_data = _buffer.data;
		var l_i:Int = 0;
		var l_ni:Int = 0;
		var l_nx:Int = 0;
		var l_ny:Int = 0;
		var l_nz:Int = 0;
		var l_dx:Int = 0;
		var l_dy:Int = 0;
		var l_dz:Int = 0;
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
					l_magInv = _NORMAL_LEVELS / Math.sqrt( ( l_dx * l_dx ) + ( l_dy * l_dy ) + ( l_dz * l_dz ) );
					l_dx = Std.int( l_dx * l_magInv );
					l_dy = Std.int( l_dy * l_magInv );
					l_dz = Std.int( l_dz * l_magInv );
					// take the dot product of the direction and the normal to get the amount of shine
					l_dotProduct = ( l_dx * l_nx ) + ( l_dy * l_ny ) + ( l_dz * l_nz );
					l_intensity = ( Math.pow( l_dotProduct / ( _NORMAL_LEVELS * _NORMAL_LEVELS ), _shine ) * _spotlight ) + _ambient;
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
		_context2d.putImageData( _buffer, 0, 0 );
		_isDirty = false;
	}	
}