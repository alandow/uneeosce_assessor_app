package au.edu.une.ruralmed.components.skins
{
  import au.edu.une.ruralmed.components.skins.assets.Button_down;
  import au.edu.une.ruralmed.components.skins.assets.Button_fill;
  import au.edu.une.ruralmed.components.skins.assets.Button_up;
  
  import flash.display.DisplayObject;
  
  import mx.core.DPIClassification;
  
  import spark.skins.mobile.ButtonSkin;
  
  /**
  * Alpha property for the fill background
  */
  [Style(name = "fillAlpha", inherit = "no", type = "Number")]
  
  /**
   * The iOS skin class for the Spark Button component.
   *
   *  @see spark.components.Button
   */
  public class AltButtonSkin extends spark.skins.mobile.ButtonSkin
  {
    /**
     * Constructor
     */
    public function AltButtonSkin()
    {
      super();
      
      switch (applicationDPI)
      {
        case DPIClassification.DPI_320:
        case DPIClassification.DPI_240:
        default:
        {
          // 160
          layoutBorderSize = 0;
          layoutPaddingTop = 0;
          layoutPaddingBottom = 0;
          layoutPaddingLeft = 10;
          layoutPaddingRight = 10;
          measuredDefaultWidth = 58;
          measuredDefaultHeight = 28;
          
          upBorderSkin = au.edu.une.ruralmed.components.skins.assets.AltButton_up;
          downBorderSkin = au.edu.une.ruralmed.components.skins.assets.AltButton_down;
          fillClass =au.edu.une.ruralmed.components.skins.assets.AltButton_fill;
          
          break;
        }
      }
      
      // beveled buttons do not scale down
      measuredMinHeight = measuredDefaultHeight;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Variables
    //
    //--------------------------------------------------------------------------
    
    /**
     * @private
     */
    private var _fill:DisplayObject;
    
    /**
     * @private
     */
    private var colorized:Boolean;
    
    /**
     * The fill class of the button
     */
    public var fillClass:Class;
    
    //--------------------------------------------------------------------------
    //
    //  Overridden methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */
    override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
    {
      super.layoutContents(unscaledWidth, unscaledHeight);
      
      super.labelDisplayShadow.y = super.labelDisplayShadow.y - 2;
      
      // add separate chromeColor fill graphic as the first layer
      if (!_fill && fillClass)
      {
        _fill = new fillClass();
        addChildAt(_fill, 0);
      }
      
      if (_fill)
      {
        // move to the first layer
        if (getChildIndex(_fill) > 0)
        {
          removeChild(_fill);
          addChildAt(_fill, 0);
        }
        
        setElementSize(_fill, unscaledWidth, unscaledHeight);
      }
    }
    
    /**
     *  @private
     */
    override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
    {
      if (!_fill)
      {
        return;
      }
      
      // omit call to super.drawBackground(), apply tint instead and don't draw fill
      var chromeColor:uint = getStyle("chromeColor");
      
      if (colorized || (chromeColor != 0xCCCCCC))
      {
        // apply tint instead of fill
        applyColorTransform(_fill, 0xCCCCCC, chromeColor);
        
        // if we restore to original color, unset colorized
        colorized = (chromeColor != 0xCCCCCC);
      }
      
      var fillAlpha:Number = getStyle("fillAlpha");
      if (!isNaN(fillAlpha))
      {
        _fill.alpha = fillAlpha;
      }
    }
  
  }
}
