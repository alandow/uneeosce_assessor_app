package au.com.clinman.mobile.lib
{
	
	import flash.geom.Point;
	
	import spark.components.BusyIndicator;
	import spark.components.Label;
	import spark.components.SkinnablePopUpContainer;
	import spark.layouts.HorizontalAlign;
	import spark.layouts.VerticalAlign;
	import spark.layouts.VerticalLayout;
	
	/**
	 * A PopUp that contains a BusyIndicator and Label for status updates.
	 *
	 * @author Michael Schmalle
	 * @copyright Teoti Graphix, LLC
	 * @productversion 1.0
	 */
	public class BusyLabelPopUp extends SkinnablePopUpContainer
	{
		//--------------------------------------------------------------------------
		// 
		//  SkinPart :: Variables
		// 
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  busyIndicator
		//----------------------------------
		
		[SkinPart(required="false")]
		
		/**
		 * The busy indicator that notifies the user of indeterminate progress.
		 */
		public var busyIndicator:BusyIndicator;
		
		//----------------------------------
		//  statusDisplay
		//----------------------------------
		
		[SkinPart(required="false")]
		
		/**
		 * The Label that will display the status message if any.
		 */
		public var statusDisplay:Label;
		
		//--------------------------------------------------------------------------
		// 
		//  Public :: Properties
		// 
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  status
		//----------------------------------
		
		/**
		 * @private
		 */
		private var statusChanged:Boolean = false;
		
		/**
		 * @private
		 */
		private var _status:String;
		
		/**
		 * Sets the status message on the popup.
		 */
		public function get status():String
		{
			return _status;
		}
		
		/**
		 * @private
		 */
		public function set status(value:String):void
		{
			if (_status == value)
				return;
			
			_status = value;
			
			statusChanged = true;
			invalidateProperties();
		}
		
		//--------------------------------------------------------------------------
		// 
		//  Constructor
		// 
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor.
		 */
		public function BusyLabelPopUp()
		{
			super();
		}
		
		//--------------------------------------------------------------------------
		// 
		//  Overridden Public :: Methods
		// 
		//--------------------------------------------------------------------------
		
		override public function updatePopUpPosition():void
		{
			// use the owner x, y coords
			var point:Point = new Point(owner.x, owner.y);
			// convert the owner x,y to global so this can be laid out in 
			// nested Views
			point = owner.parent.localToGlobal(point);
			// set the popup's global x,y coords
			x = point.x;
			y = point.y;
			// mirror the owner's width and height onto the popup
			width = owner.width;
			height = owner.height;
		}
		
		//--------------------------------------------------------------------------
		// 
		//  Overridden Protected :: Methods
		// 
		//--------------------------------------------------------------------------
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			if (instance == contentGroup)
			{
				// if the contentGroup has 0 children right now, we know 
				// a custom skin was not applied and we should create the 
				// skinparts programatically
				// this is being 'polite' to future devs that may need an
				// MXML skin implementation adding skinparts declarativly
				if (contentGroup.numElements == 0)
				{
					// update layout knowing we are adding composite skinparts
					updateLayout();
					// create the busyIndicator skinpart
					createBusyIndicator();
					// create the statusDisplay skinpart
					createStatusDisplay();
				}
			}
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (statusChanged)
			{
				// this is optional but smart, create a commit method so your
				// devs that follow have a hook to change your code down the road
				commitStatus();
				statusChanged = false;
			}
		}
		
		//--------------------------------------------------------------------------
		// 
		//  Protected :: Methods
		// 
		//--------------------------------------------------------------------------
		
		protected function updateLayout():void
		{
			// create a nice and simple VerticalLayout that centers both parts
			// in the full layout. Remeber that the skin sets all layout
			// constraints to 0, effectively saying width=100%, height=100%
			var vlayout:VerticalLayout = new VerticalLayout();
			vlayout.horizontalAlign = HorizontalAlign.CENTER;
			vlayout.verticalAlign = VerticalAlign.MIDDLE;
			vlayout.gap = 10;
			layout = vlayout;
		}
		
		protected function createBusyIndicator():void
		{
			// this could also be a factory, for simplicity we create here
			// this is really no different than what the mobile skins do
			busyIndicator = new BusyIndicator();
			// setting the id allows CSS #busyIndicator
			busyIndicator.id = "busyIndicator";
			contentGroup.addElement(busyIndicator);
		}
		
		protected function createStatusDisplay():void
		{
			// this could also be a factory, for simplicity we create here
			// this is really no different than what the mobile skins do
			statusDisplay = new Label();
			// setting the id allows CSS #statusDisplay
			statusDisplay.id = "statusDisplay";
			contentGroup.addElement(statusDisplay);
		}
		
		protected function commitStatus():void
		{
			if (!statusDisplay)
				return;
			// update the status text to show on the user interface
			statusDisplay.text = status;
		}
	}
}