package au.com.clinman.events
{
	import flash.events.Event;
	
	public class eOSCEErrorEvent extends Event
	{
		
		public function eOSCEErrorEvent(type:String, message:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._message = message;
		}
		
		
		private var _message:String = "";
		public function get message():String
		{
			return _message;
		}
				
				
		public static const EVENT:String = "eOSCEErrorEvent.EVENT";
	}
}
