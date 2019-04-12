package demo.scenes;
import awe6.core.drivers.createjs.extras.gui.Image;
import canvascandy.shine.Shine;
import canvascandy.Utils;

/**
 * @author	Robert Fell
 */

class SceneShine extends AScene 
{
	override function _init():Void 
	{
		super._init();
		addEntity( new Image( _kernel, _kernel.assets.getAsset( Assets.shine_ButtonOver__png ) ), true, 1 );
		addEntity( new Shine( _kernel, _kernel.assets.getAsset( Assets.shine_ButtonShine__png ) ), true, 2 );
		_text.text = "#4 Shine";
	}
}
