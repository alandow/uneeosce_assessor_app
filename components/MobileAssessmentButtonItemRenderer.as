package components
{
	import au.com.clinman.events.MarkQuestionEvent;
	
	import com.pialabs.eskimo.skins.mobile.ios.ButtonBarFirstButtonSkin;
	import com.pialabs.eskimo.skins.mobile.ios.ButtonBarLastButtonSkin;
	
	import flash.events.MouseEvent;
	
	import mx.styles.IStyleClient;
	
	import spark.components.Group;
	import spark.components.HGroup;
	import spark.components.ToggleButton;
	import spark.components.itemRenderers.IMobileGridCellRenderer;
	import spark.components.supportClasses.ItemRenderer;
	
	public class MobileAssessmentButtonItemRenderer extends HGroup implements IMobileGridCellRenderer
	{
		
		private var _but0:ToggleButton = new ToggleButton();
		private var _but1:ToggleButton = new ToggleButton();
		
		private var _data:Object;
		
		private var _value:String = "";
		
		public function MobileAssessmentButtonItemRenderer()
		{
			// set up buttons and add them to the renderer
			_but0.label = "Satisfactory";
			_but1.label = "Unsatisfactory";
			_but0.setStyle('skinClass', ButtonBarFirstButtonSkin);
			_but1.setStyle('skinClass', ButtonBarLastButtonSkin);
			_but0.height = 40;
			_but1.height = 40;
			_but0.percentWidth = 50;
			_but1.percentWidth = 50;
			_but0.addEventListener(MouseEvent.CLICK, select);
			_but1.addEventListener(MouseEvent.CLICK, select);
			this.addElement(_but0);
			this.addElement(_but1);
			this.height = 50;
			// set up a background
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
		

		// make the buttons work like a button bar 
		private function select(event:MouseEvent):void{
			// send teh data out
			var value:String = "";
			if(event.target == this._but0){
				this._but1.selected = false;
				value = "1";
			}else{
				this._but0.selected = false;
				value = "0";
			}
			dispatchEvent(new MarkQuestionEvent(MarkQuestionEvent.EVENT, _data.id, value, true));
		}
		
		
		public function get data():Object
		{
			return this._data;
		}
		
		public function set data(value:Object):void
		{
			_data = value;
			if(_data.hasOwnProperty('value')){
				trace('got a value of'+_data.value)
				if(_data.value == '1'){
					this._but0.selected = true;
					this._but1.selected = false;
					value = "1";
				}else{
					this._but0.selected = false;
					this._but1.selected = true;
					value = "0";
				}
			}else{
				this._but1.selected = false;
				this._but0.selected = false;
			}
		}
	}
}