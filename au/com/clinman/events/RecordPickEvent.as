package au.com.clinman.events
{
	import flash.events.Event;

	public class RecordPickEvent extends Event
	{
		public function RecordPickEvent(type:String, recordID:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._recordID = recordID;
		}
		private var _recordID:String = "";
	
		
		public function get recordID():String
		{
			return this._recordID;
		}
		
		public static const EVENT:String = "RecordPickEvent.EVENT";
	}
}
