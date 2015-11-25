package components
{
	import com.pialabs.eskimo.skins.mobile.ios.ButtonBarFirstButtonSkin;
	import com.pialabs.eskimo.skins.mobile.ios.ButtonBarLastButtonSkin;
	
	import flash.text.engine.SpaceJustifier;
	
	import mx.graphics.SolidColor;
	import mx.styles.IStyleClient;
	
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.Label;
	import spark.components.ToggleButton;
	import spark.components.itemRenderers.IMobileGridCellRenderer;
	import spark.components.supportClasses.ItemRenderer;
	import spark.primitives.Rect;
	
	public class MobileAssessmentLabelItemRenderer extends Group implements IMobileGridCellRenderer
	{
		
		private var _hgroup:HGroup = new HGroup();
		private var _bgrect:Rect = new Rect();
		private var _label:Label = new Label();
		
		private var _data:Object;
		
		public function MobileAssessmentLabelItemRenderer()
		{
			// set up background rectangle
			this._bgrect.fill = new SolidColor(0xFFC8C8);
			this._bgrect.percentHeight = 100;
			this._bgrect.percentWidth = 100;
			this.addElement(_bgrect);
			
			// set up hgroup
			
			// set up label
			this._label.maxDisplayedLines = -1;
			this._label.width = 350;
			this._label.verticalCenter = 0;
			this._label.left = 2;
			this._label.setStyle('lineHeight', "100%");
			//_label.height = 100;
			this._label.setStyle('lineBreak', "toFit");
			
			this.addElement(_label);
			//this.height = 100;
		}
		
		public function set styleProvider(value:IStyleClient):void
		{
		}
		
		public function get canSetContentWidth():Boolean
		{
			return true;
		}
		
		public function get canSetContentHeight():Boolean
		{
			return true;
		}
		
		public function set cssStyleName(value:String):void
		{
		}
		
		/*	public function getPreferredBoundsWidth(postLayoutTransform:Boolean=true):Number
		{
		return 0;
		}
		
		public function getPreferredBoundsHeight(postLayoutTransform:Boolean=true):Number
		{
		return 0;
		}*/
		
		public function get data():Object
		{
			return null;
		}
		
		public function set data(value:Object):void
		{
			this._data = value;
			this._label.text = _data.text;
			//this.height = 200;
			if(this._data.hasOwnProperty('isvalid')){
				if(this._data.isvalid=='true'){
					this._bgrect.fill = new SolidColor(0xC8FFC8);
				}else{
					this._bgrect.fill = new SolidColor(0xFFC8C8);
				}
			}else{
				this._bgrect.fill = new SolidColor(0xFFC8C8);
			}
			validateNow();
		}
	}
}