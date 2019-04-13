package canvascandy;
import js.Browser;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.ImageElement;

/**
 * ...
 * @author	Robert Fell
 */
class Utils
{
	public static function getImage( p_url:String ):ImageElement
	{
		var l_result:ImageElement = cast Browser.document.createElement( "img" );
		l_result.src = p_url;
		return l_result;
	}
	
	public static function createImage( p_width:Int, p_height:Int ):ImageElement
	{
		var l_result:ImageElement = cast Browser.document.createElement( "img" );
		l_result.width = p_width;
		l_result.height = p_height;
		return l_result;
	}
	
	public static function createCanvas( p_width:Int, p_height:Int ):CanvasElement
	{
		var l_result:CanvasElement = cast Browser.document.createElement( "canvas" );
		l_result.width = p_width;
		l_result.height = p_height;
		return l_result;
	}
	
	public static function createCanvasFromImage( p_image:ImageElement ):CanvasElement
	{
		var l_result = createCanvas( p_image.width, p_image.height );
		l_result.getContext2d().drawImage( p_image, 0, 0 );
		return l_result;
	}
	
	public static function resizeImage( p_image:ImageElement, p_scale:Float ):ImageElement
	{
		var l_canvas = createCanvas( Math.round( p_image.width * p_scale ), Math.round( p_image.height * p_scale ) );
		var l_context2d:CanvasRenderingContext2D = l_canvas.getContext2d();
		l_context2d.scale( p_scale, p_scale );
		l_context2d.drawImage( p_image, 0, 0 );
		return getImage( l_canvas.toDataURL() );
	}
	
	public static function createTilesFromImage( p_image:ImageElement, p_cols:Int, p_rows:Int ):Array<Array<ImageElement>>
	{
		var l_tileWidth = Math.round( p_image.width / p_cols );
		var l_tileHeight = Math.round( p_image.height / p_rows );
		var l_x:Float = 0;
		var l_y:Float = 0;
		var l_result:Array<Array<ImageElement>> = [];
		for ( l_row in 0...p_rows )
		{
			var l_resultRow:Array<ImageElement> = [];
			for ( l_col in 0...p_cols )
			{
				var l_canvas = createCanvas( l_tileWidth, l_tileHeight );
				var l_context2d:CanvasRenderingContext2D = l_canvas.getContext2d();
				l_context2d.drawImage( p_image, -l_x, -l_y );
				l_resultRow.push( getImage( l_canvas.toDataURL() ) );
				l_x += l_tileWidth;
			}
			l_result.push( l_resultRow );
			l_x = 0;
			l_y += l_tileHeight;
		}
		return l_result;
	}
}