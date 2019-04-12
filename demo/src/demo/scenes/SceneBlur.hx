package demo.scenes;
import canvascandy.blur.Blur;
import canvascandy.Utils;

/**
 * @author	Robert Fell
 */

class SceneBlur extends AScene 
{
	private var _blur:Blur;
	
	override function _init():Void 
	{
		super._init();
		addEntity( _blur = new Blur( _kernel, _kernel.assets.getAsset( Assets.normalmapping_texture__png ) ), true, 2 );
		_text.text = "#1 Blur";
	}
	
	override private function _updater( p_deltaTime:Int = 0 ):Void 
	{
		super._updater( p_deltaTime );
		_blur.configure( Math.round( _kernel.inputs.mouse.relativeX * 16 ) );
	}
	
	
}
