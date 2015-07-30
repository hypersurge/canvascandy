package demo;
import awe6.core.drivers.createjs.extras.gui.Text;
import awe6.core.Scene;
import awe6.interfaces.EScene;
import awe6.interfaces.IKernel;
import canvascandy.normalmapping.NormalMapping;
import canvascandy.Utils;

/**
 * A simple test scene
 * @author	Robert Fell
 */

class Test extends Scene 
{
	private var _text:Text;
	
	public function new( p_kernel:IKernel, p_type:EScene, p_isPauseable:Bool = false, p_isMuteable:Bool = true, p_isSessionSavedOnNext:Bool = false ) 
	{
		super( p_kernel, p_type, p_isPauseable, p_isMuteable, p_isSessionSavedOnNext );
	}
	
	override function _init():Void 
	{
		super._init();
		
		addEntity( new NormalMapping( _kernel, Utils.getImage( Assets.normalmapping_texture__jpg ), Utils.getImage( Assets.normalmapping_normal__jpg ) ), true, 1 );
		
		_text = new Text( _kernel, _kernel.factory.width, 30, "Test", _kernel.factory.createTextStyle() );
		_text.setPosition( 0, _kernel.factory.height - _text.height );
		addEntity( _text, true, 10 );
	}
	
}
