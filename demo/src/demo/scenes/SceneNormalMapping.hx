package demo.scenes;
import canvascandy.normalmapping.NormalMapping;
import canvascandy.Utils;

/**
 * @author	Robert Fell
 */

class SceneNormalMapping extends AScene 
{
	override function _init():Void 
	{
		super._init();
		addEntity( new NormalMapping( _kernel, _kernel.assets.getAsset( Assets.normalmapping_texture__png ), _kernel.assets.getAsset( Assets.normalmapping_normal__png ) ), true, 2 );
		_text.text = "#2 NormalMapping";
	}
}
