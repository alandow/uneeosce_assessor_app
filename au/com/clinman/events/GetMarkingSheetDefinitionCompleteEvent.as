package au.com.clinman.events
{
	import flash.events.Event;
	
	public class GetMarkingSheetDefinitionCompleteEvent extends Event
	{
		public function GetMarkingSheetDefinitionCompleteEvent(type:String, results:XML, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			this._results = results;
			super(type, bubbles, cancelable);
		}
		
		
		public function get results():XML
		{
			return this._results;
		}
		
		override public function clone():Event
		{
			return new GetMarkingSheetDefinitionCompleteEvent(type, results, bubbles, cancelable);
		}
		
		public static const DATA_READY:String = "GetMarkingSheetDefinitionCompleteEvent.DATA_READY";
		
		private var _results:XML;
	}
}