package au.com.clinman.events
{
	import flash.events.Event;
	
	public class GetStudentsBySearchStrForFormCompleteEvent extends Event
	{
		public function GetStudentsBySearchStrForFormCompleteEvent(type:String, results:XML, bubbles:Boolean=false, cancelable:Boolean=false)
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
			return new GetStudentsBySearchStrForFormCompleteEvent(type, results, bubbles, cancelable);
		}
		
		public static const DATA_READY:String = "GetStudentsBySearchStrForFormCompleteEvent.DATA_READY";
		
		private var _results:XML;
	}
}