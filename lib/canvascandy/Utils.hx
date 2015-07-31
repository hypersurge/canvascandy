package canvascandy;
import js.Browser;
import js.html.CanvasElement;
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
	
}