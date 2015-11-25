package au.com.clinman.events
{
	import flash.events.Event;
	
	public class LogonCompleteEvent extends Event
	{
		public function LogonCompleteEvent(type:String, results:XML, bubbles:Boolean=false, cancelable:Boolean=false)
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
			return new LogonCompleteEvent(type, results, bubbles, cancelable);
		}
		
		public static const COMPLETE:String = "LogonCompleteEvent.COMPLETE";
		
		private var _results:XML;
	}
}