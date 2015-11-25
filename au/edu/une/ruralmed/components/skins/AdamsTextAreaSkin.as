package au.edu.une.ruralmed.components.skins
{
  
  
  import au.edu.une.ruralmed.components.skins.assets.TextInput_border;
  
  import flash.display.DisplayObject;
  
  import spark.filters.DropShadowFilter;
  import spark.skins.mobile.TextAreaSkin;
  
  
 
  /**
   * The iOS skin class for the Spark TextInput component
   * @see spark.components.TextInput
   */
  public class AdamsTextAreaSkin extends spark.skins.mobile.TextAreaSkin
  {

    
    public function AdamsTextAreaSkin()
    {
      super();
	  layoutCornerEllipseSize = 0;
	  borderClass = au.edu.une.ruralmed.components.skins.assets.TextInput_border;
     
    }
	
	
    
    override protected function createChildren():void
    {
      super.createChildren();
    }
    
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
      super.layoutContents(unscaledWidth, unscaledHeight);
   
      // position & size the text
      var paddingLeft:Number = getStyle("paddingLeft");
      var paddingRight:Number = getStyle("paddingRight");
      var paddingTop:Number = getStyle("paddingTop");
      var paddingBottom:Number = getStyle("paddingBottom");
      

      var textDisplayWidth:int = unscaledWidth - paddingLeft - paddingRight;
      

      super.textDisplay.width = textDisplayWidth;

    }
  }
}
