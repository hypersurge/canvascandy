package demo.scenes;
import awe6.core.drivers.createjs.extras.gui.Text;
import awe6.core.Scene;
import awe6.interfaces.*;

/**
 * A simple test scene
 * @author	Robert Fell
 */

class AScene extends Scene 
{
	public static var SCENE_BLUR = EScene.SUB_TYPE( "SCENE_BLUR" );
	public static var SCENE_NORMAL_MAPPING = EScene.SUB_TYPE( "SCENE_NORMAL_MAPPING" );
	public static var SCENE_SHINE = EScene.SUB_TYPE( "SCENE_SHINE" );
	
	private var _text:Text;
	
	public function new( p_kernel:IKernel, p_type:EScene, p_isPauseable:Bool = false, p_isMuteable:Bool = true, p_isSessionSavedOnNext:Bool = false ) 
	{
		super( p_kernel, p_type, p_isPauseable, p_isMuteable, p_isSessionSavedOnNext );
	}
	
	override function _init():Void 
	{
		super._init();
		_text = new Text( _kernel, _kernel.factory.width, 30, "", _kernel.factory.createTextStyle() );
		_text.setPosition( 0, _kernel.factory.height - _text.height );
		addEntity( _text, true, 10 );
	}
	
	override function _updater( p_deltaTime:Int = 0 ):Void 
	{
		super._updater( p_deltaTime );
		var l_keyboard = _kernel.inputs.keyboard.getIsKeyPress;
		if ( l_keyboard( EKey.NUMBER_1 ) ) _kernel.scenes.setScene( SCENE_BLUR );
		if ( l_keyboard( EKey.NUMBER_2 ) ) _kernel.scenes.setScene( SCENE_NORMAL_MAPPING );
		if ( l_keyboard( EKey.NUMBER_3 ) ) _kernel.scenes.setScene( SCENE_SHINE );
	}
}
