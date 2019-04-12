package demo;
import awe6.core.*;
import awe6.interfaces.*;
import demo.scenes.*;

/**
 * ...
 * @author	Robert Fell
 */

class Factory extends AFactory 
{
	
	override private function _configurer( p_isPreconfig:Bool = false ):Void 
	{
		if ( p_isPreconfig ) 
		{
			id = "CanvasCandy";
			version = "0.1.0";
			author = "Robert Fell";
			isDecached = true;
			width = 720;
			height = 400;
			bgColor = 0xFF0080FF;
			startingSceneType = AScene.SCENE_PLANE;
			targetFramerate = 30;
			isFixedUpdates = false;
		}
	}
	
	override public function createScene( p_type:EScene ):IScene 
	{
		if ( p_type == AScene.SCENE_BLUR ) return new SceneBlur( _kernel, p_type, true, true );
		if ( p_type == AScene.SCENE_NORMAL_MAPPING ) return new SceneNormalMapping( _kernel, p_type, true, true );
		if ( p_type == AScene.SCENE_PLANE ) return new ScenePlane( _kernel, p_type, true, true );
		if ( p_type == AScene.SCENE_SHINE ) return new SceneShine( _kernel, p_type, true, true );
		return super.createScene( p_type );
	}
	
	override public function createTextStyle( ?p_type:ETextStyle ):ITextStyle 
	{
		return new TextStyle( _kernel.getConfig( Config.settings_font_name ), 20, 0xFFFFFF, ETextAlign.CENTER );
	}
	
}
