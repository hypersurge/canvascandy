package canvascandy.plane;
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
	
private typedef _TPoint =
{
	x: Float,
	y: Float,
}

private typedef _TTextureCoordinate =
{
	u: Float,
	v: Float,
}

private typedef _TTriangle =
{
	p0: _TPoint,
	p1: _TPoint,
	p2: _TPoint,
	t0: _TTextureCoordinate,
	t1: _TTextureCoordinate,
	t2: _TTextureCoordinate,
	isInsideBounds: Bool,
}

private typedef _TBounds =
{
	topLeft: _TPoint,
	bottomRight: _TPoint,
}
 
/**
 * based on: http://jsfiddle.net/mrbendel/6rbtde5t/1/
 * which is based on: http://tulrich.com/geekstuff/canvas/perspective.html
 */
 
class Plane extends Entity 
{	
	private var _texture:ImageElement;
	private var _width:Int;
	private var _height:Int;
	private var _subs:Int;
	private var _divs:Int;
	private var _edgeBleed:Float;
	private var _isBoundsEnabled:Bool;
	private var _context:Context;
	private var _textureWidth:Int;
	private var _textureHeight:Int;
	private var _divWidth:Float;
	private var _subHeight:Float;
	private var _canvas:CanvasElement;
	private var _context2d:CanvasRenderingContext2D;
	
	private var _triangles: Array<_TTriangle> = [];
	
	public function new( p_kernel:IKernel, p_texture:ImageElement, ?p_width:Int, ?p_height: Int, p_subs:Int = 7, p_divs:Int = 7, p_edgeBleed:Float = .02, p_isBoundsEnabled: Bool = false )
	{
		_context = new Context();
		_texture = p_texture;
		_width = p_width != null ? p_width : p_kernel.factory.width;
		_height = p_height != null ? p_height : p_kernel.factory.height;
		_subs = p_subs > 0 ? p_subs : 1;
		_divs = p_divs > 0 ? p_divs : 1;
		_edgeBleed = p_edgeBleed;
		_isBoundsEnabled = p_isBoundsEnabled;
		super( p_kernel, _context );
	}
	
	override private function _init():Void 
	{
		super._init();
		_textureWidth = _texture.width;
		_textureHeight = _texture.height;
		_context.cache( 0, 0, _width, _height );
		_canvas = _context.cacheCanvas;
		_context2d = _canvas.getContext2d();
		_context2d.imageSmoothingEnabled = false;
		_divWidth = Math.ceil( _textureWidth / _divs );
		_subHeight = Math.ceil( _textureHeight / _subs );
	}
	
	public function configure( p_point1: _TPoint, p_point2: _TPoint, p_point3: _TPoint, p_point4: _TPoint, p_isWireframe:Bool = false ):Void
	{
		_context2d.save();
		_context2d.setTransform( 1, 0, 0, 1, 0, 0 );
		_context2d.clearRect( 0, 0, _canvas.width, _canvas.height );
		_calculateGeometry( p_point1, p_point2, p_point3, p_point4 );
		if ( _isBoundsEnabled ) _calculateBounds( createPoint( 0, 0 ), createPoint( _width, _height ) );
		for ( l_triangle in _triangles ) _draw( l_triangle, _texture, p_isWireframe );
		_context2d.restore();
	}
	
	private function _draw( p_triangle:_TTriangle, p_texture: ImageElement, p_isWireframe: Bool = false ):Void
	{
		if ( p_isWireframe )
		{
			_context2d.strokeStyle = "black";
			_context2d.beginPath();
			_context2d.moveTo( p_triangle.p0.x, p_triangle.p0.y );
			_context2d.lineTo( p_triangle.p1.x, p_triangle.p1.y );
			_context2d.lineTo( p_triangle.p2.x, p_triangle.p2.y );
			_context2d.lineTo( p_triangle.p0.x, p_triangle.p0.y );
			_context2d.stroke();
			_context2d.closePath();
	    }
		if ( !p_triangle.isInsideBounds ) return;
	    _drawTriangle(
			_context2d, p_texture,
			p_triangle.p0.x, p_triangle.p0.y,
			p_triangle.p1.x, p_triangle.p1.y,
			p_triangle.p2.x, p_triangle.p2.y,
			p_triangle.t0.u, p_triangle.t0.v,
			p_triangle.t1.u, p_triangle.t1.v,
			p_triangle.t2.u, p_triangle.t2.v,
			_edgeBleed
		);
	}
	
	// http://jsfiddle.net/mrbendel/6rbtde5t/1/
	private function _calculateGeometry( p_point1: _TPoint, p_point2: _TPoint, p_point3: _TPoint, p_point4: _TPoint ): Void
	{
		_triangles = [];
		var l_point1 = p_point1;
		var l_point2 = p_point2;
		var l_point3 = p_point3;
		var l_point4 = p_point4;
		var l_dx1 = l_point4.x - l_point1.x;
		var l_dy1 = l_point4.y - l_point1.y;
		var l_dx2 = l_point3.x - l_point2.x;
		var l_dy2 = l_point3.y - l_point2.y;
		for ( l_sub in 0..._subs )
		{
			var l_currentRow = l_sub / _subs;
			var l_nextRow = ( l_sub + 1 ) / _subs;
			var l_currentRowX1 = l_point1.x + l_dx1 * l_currentRow;
			var l_currentRowY1 = l_point1.y + l_dy1 * l_currentRow;
			var l_currentRowX2 = l_point2.x + l_dx2 * l_currentRow;
			var l_currentRowY2 = l_point2.y + l_dy2 * l_currentRow;
			var l_nextRowX1 = l_point1.x + l_dx1 * l_nextRow;
			var l_nextRowY1 = l_point1.y + l_dy1 * l_nextRow;
			var l_nextRowX2 = l_point2.x + l_dx2 * l_nextRow;
			var l_nextRowY2 = l_point2.y + l_dy2 * l_nextRow;
			for ( l_div in 0..._divs )
			{
				var l_currentCol = l_div / _divs;
				var l_nextCol = ( l_div + 1 ) / _divs;
				var l_currentRowDx = l_currentRowX2 - l_currentRowX1;
				var l_currentRowDy = l_currentRowY2 - l_currentRowY1;
				var l_nextRowDx = l_nextRowX2 - l_nextRowX1;
				var l_nextRowDy = l_nextRowY2 - l_nextRowY1;
				var l_point1 = createPoint( l_currentRowX1 + l_currentRowDx * l_currentCol, l_currentRowY1 + l_currentRowDy * l_currentCol );
				var l_point2 = createPoint( l_currentRowX1 + (l_currentRowX2 - l_currentRowX1) * l_nextCol, l_currentRowY1 + (l_currentRowY2 - l_currentRowY1) * l_nextCol );
				var l_point3 = createPoint( l_nextRowX1 + l_nextRowDx * l_nextCol, l_nextRowY1 + l_nextRowDy * l_nextCol );
				var l_point4 = createPoint( l_nextRowX1 + l_nextRowDx * l_currentCol, l_nextRowY1 + l_nextRowDy * l_currentCol );
				var l_u1 = l_currentCol * _textureWidth;
				var l_u2 = l_nextCol * _textureWidth;
				var l_v1 = l_currentRow * _textureHeight;
				var l_v2 = l_nextRow * _textureHeight;
				var l_triangle1 = _createTriangle(
					l_point1,
					l_point3,
					l_point4,
					_createTextureCoordinate( l_u1, l_v1 ),
					_createTextureCoordinate( l_u2, l_v2 ),
					_createTextureCoordinate( l_u1, l_v2 ),
					true
				);
				var l_triangle2 = _createTriangle(
					l_point1,
					l_point2,
					l_point3,
					_createTextureCoordinate( l_u1, l_v1 ),
					_createTextureCoordinate( l_u2, l_v1 ),
					_createTextureCoordinate( l_u2, l_v2 ),
					true
				);
				_triangles.push( l_triangle1 );
				_triangles.push( l_triangle2 );
			}
		}
	}
	
	private function _calculateBounds( p_topLeft:_TPoint, p_bottomRight:_TPoint ): Void
	{
		for ( l_triangle in _triangles )
		{
			var l_bounds: _TBounds = {
				topLeft: {
					x: l_triangle.p0.x,
					y: l_triangle.p0.y,
				},
				bottomRight: {
					x: l_triangle.p1.x,
					y: l_triangle.p1.y,
				},
			};
			for ( l_point in [l_triangle.p0, l_triangle.p1, l_triangle.p2] )
			{
				if ( l_point.x < l_bounds.topLeft.x ) l_bounds.topLeft.x = l_point.x;
				if ( l_point.y < l_bounds.topLeft.y ) l_bounds.topLeft.y = l_point.y;
				if ( l_point.x > l_bounds.bottomRight.x ) l_bounds.bottomRight.x = l_point.x;
				if ( l_point.y > l_bounds.bottomRight.y ) l_bounds.bottomRight.y = l_point.y;
			}
			l_triangle.isInsideBounds = ( ( l_bounds.topLeft.x < p_bottomRight.x ) && ( l_bounds.bottomRight.x > p_topLeft.x ) && ( l_bounds.topLeft.y < p_bottomRight.y ) && ( l_bounds.bottomRight.y > p_topLeft.y ) );
		}
	}
	
	// http://tulrich.com/geekstuff/canvas/jsgl.js
	private function _drawTriangle( p_context2d: CanvasRenderingContext2D, p_imageElement:ImageElement, p_x0:Float, p_y0:Float, p_x1:Float, p_y1:Float, p_x2:Float, p_y2:Float, p_sx0:Float, p_sy0:Float, p_sx1:Float, p_sy1:Float, p_sx2:Float, p_sy2:Float, p_edgeBleed:Float = 0 ): Void
	{
		p_context2d.save();
		p_context2d.beginPath();
		p_context2d.moveTo( p_x0 + ( ( p_x0 - p_x1 ) * p_edgeBleed ), p_y0 + ( ( p_y0 - p_y1 ) * p_edgeBleed ) );
		p_context2d.lineTo( p_x1 + ( ( p_x1 - p_x2 ) * p_edgeBleed ), p_y1 + ( ( p_y1 - p_y2 ) * p_edgeBleed ) );
		p_context2d.lineTo( p_x2 + ( ( p_x2 - p_x0 ) * p_edgeBleed ), p_y2 + ( ( p_y2 - p_y0 ) * p_edgeBleed ) );
		p_context2d.closePath();
		p_context2d.clip();
		var l_denominator = p_sx0 * ( p_sy2 - p_sy1 ) - p_sx1 * p_sy2 + p_sx2 * p_sy1 + ( p_sx1 - p_sx2 ) * p_sy0;
		if ( l_denominator == 0 ) return;
		var l_m11 = -( p_sy0 * ( p_x2 - p_x1 ) - p_sy1 * p_x2 + p_sy2 * p_x1 + ( p_sy1 - p_sy2 ) * p_x0 ) / l_denominator;
		var l_m12 = ( p_sy1 * p_y2 + p_sy0 * ( p_y1 - p_y2 ) - p_sy2 * p_y1 + ( p_sy2 - p_sy1 ) * p_y0 ) / l_denominator;
		var l_m21 = ( p_sx0 * ( p_x2 - p_x1 ) - p_sx1 * p_x2 + p_sx2 * p_x1 + ( p_sx1 - p_sx2 ) * p_x0 ) / l_denominator;
		var l_m22 = -( p_sx1 * p_y2 + p_sx0 * ( p_y1 - p_y2 ) - p_sx2 * p_y1 + ( p_sx2 - p_sx1 ) * p_y0 ) / l_denominator;
		var l_dx = ( p_sx0 * ( p_sy2 * p_x1 - p_sy1 * p_x2 ) + p_sy0 * ( p_sx1 * p_x2 - p_sx2 * p_x1 ) + ( p_sx2 * p_sy1 - p_sx1 * p_sy2 ) * p_x0 ) / l_denominator;
		var l_dy = ( p_sx0 * ( p_sy2 * p_y1 - p_sy1 * p_y2 ) + p_sy0 * ( p_sx1 * p_y2 - p_sx2 * p_y1 ) + ( p_sx2 * p_sy1 - p_sx1 * p_sy2 ) * p_y0 ) / l_denominator;
		p_context2d.transform( l_m11, l_m12, l_m21, l_m22, l_dx, l_dy );
		p_context2d.drawImage( p_imageElement, p_sx0, p_sy0, _divWidth, _subHeight, p_sx0, p_sy0, _divWidth, _subHeight );
		p_context2d.restore();
	}	
	
	private function _createTextureCoordinate( p_u: Float, p_v: Float ): _TTextureCoordinate
	{
		return {
			u: p_u,
			v: p_v,
		};
	}
	
	private function _createTriangle( p_point0: _TPoint, p_point1: _TPoint, p_point2: _TPoint, p_textureCoordinate0: _TTextureCoordinate, p_textureCoordinate1: _TTextureCoordinate, p_textureCoordinate2: _TTextureCoordinate, p_isInsideBounds: Bool = true ): _TTriangle
	{
		return {
			p0: p_point0,
			p1: p_point1,
			p2: p_point2,
			t0: p_textureCoordinate0,
			t1: p_textureCoordinate1,
			t2: p_textureCoordinate2,
			isInsideBounds: p_isInsideBounds,
		};
	}
	
	public static function createPoint( p_x: Float, p_y: Float ): _TPoint
	{
		return {
			x: p_x,
			y: p_y,
		};
	}
}
