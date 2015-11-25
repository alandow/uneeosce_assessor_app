package au.com.clinman.events
{
	import flash.events.Event;
	
	public class GetExamsForUserCompleteEvent extends Event
	{
		public function GetExamsForUserCompleteEvent(type:String, results:XML, bubbles:Boolean=false, cancelable:Boolean=false)
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
			return new GetExamsForUserCompleteEvent(type, results, bubbles, cancelable);
		}
		
		public static const DATA_READY:String = "GetExamsForUserCompleteEvent.DATA_READY";
		
		private var _results:XML;
	}
}